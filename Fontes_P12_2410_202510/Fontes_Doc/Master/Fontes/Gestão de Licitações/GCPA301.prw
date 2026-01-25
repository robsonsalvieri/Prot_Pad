#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include 'GCPA301.CH'

PUBLISH MODEL REST NAME GCPA301 SOURCE GCPA301

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author jose.delmondes
@since 28/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel		:= Nil
               
	G300MdlId(.T., "GCPA301")

	oModel := FwLoadModel("GCPA300")

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author jose.delmondes	
@since 28/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
	Local oView := Nil

	G300MdlId(.T., "GCPA301")

	oView := FWLoadView("GCPA300")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP301Lote()
Verifica se a Ata é por lote

@author jose.delmondes

@since 29/06/2017		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP301Lote( cNumAta , lModel )
	Local lRet	:= .F.

	Local aArea		:= GetArea()
	Local aAreaCX6	:= {}

	Local oModel	:= Nil
	Local oModelCX6	:= Nil

	DEFAULT cNumAta	:= CPH->CPH_NUMATA
	DEFAULT lModel	:= .F.

	If lModel
		oModel := FWModelActive()
		oModelCX6 := oModel:GetModel("CX6DETAIL")
		
		If ValType(oModelCX6) == 'O'
			lRet := .T.
		EndIf
	Else		
		aAreaCX6 := CX6->( GetArea() )
		CX6->(dbSetOrder(1))
		lRet := CX6->(dbSeek( xFilial("CX6") + cNumAta ))		
		RestArea(aAreaCX6)
	EndIf

	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP301GNLT()
Função para gerar nota de empenho de uma ata por lote

@author Filipe Gonçalves
@param 
@since 04/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function GCP301GNLT()
Local aArea		:= GetArea()
Local oModel 	:= FwModelActive()
Local aProd		:= {} //{CODPROD,QUANT}
Local aAta		:= {} //{CODEDT,NUMATA,NUMPRO,{aProd}}
Local aDadosAta	:= {}
Local aFornec	:= {}
Local cAliasSql	:= GetNextAlias()
Local cCodEdt	:= CPH->CPH_CODEDT
Local cNumPro	:= CPH->CPH_NUMPRO
Local cCodFil	:= CPH->CPH_FILIAL
Local cNumAta	:= CPH->CPH_NUMATA
Local cCodPro	:= ""
Local cFilEnt	:= ""
Local cNumSC 	:= ""
Local cItemSC	:= ""
Local cCodOrg	:= ""
Local cCodFor	:= ""
Local cLoja		:= ""
Local cLote		:= ""
Local cCodNe	:= ""
Local nPreco	:= 0	
Local nPos		:= 0
Local nQuant	:= 0
Local nGravou	:= 0
Local nX		:= 0

BeginSQL Alias cAliasSql
	SELECT DISTINCT CPZ.CPZ_NUMATA ,CPZ.CPZ_CODIGO, CPZ.CPZ_LOJA, CPZ.CPZ_LOTE
	FROM 
	%table:CPZ% CPZ
	INNER JOIN %table:CPH% CPH ON CPZ.CPZ_FILIAL = CPH.CPH_FILIAL AND CPZ.CPZ_NUMATA = CPH.CPH_NUMATA AND CPH.D_E_L_E_T_ = ''
	WHERE
	CPH.CPH_CODEDT = %exp:cCodEdt% AND 
	CPH.CPH_NUMPRO = %exp:cNumPro% AND
	CPZ.CPZ_NUMATA = %exp:cNumAta% AND 
	CPZ.CPZ_STATUS = '5' AND 
	CPZ.CPZ_LOTE <> '' AND
	CPZ.%NotDel%
EndSql
			
While (cAliasSql)->(!Eof())
	aAdd(aFornec, {(cAliasSql)->CPZ_NUMATA,(cAliasSql)->CPZ_CODIGO,(cAliasSql)->CPZ_LOJA, (cAliasSql)->CPZ_LOTE})
	(cAliasSql)->(dbSkip())
End
(cAliasSql)->(DbCloseArea())
		
For nX := 1 To Len(aFornec)
	aProd := {}
	aAta := {}
	aDadosAta := {}
	cCodFor	:= aFornec[nX][2]
	cLoja := aFornec[nX][3]
	cLote := aFornec[nX][4]

	//CPY_FILIAL+CPY_NUMATA+CPY_LOTE+CPY_CODPRO	
	CPY->(DbSetOrder(2))
	If CPY->(DbSeek(cCodFil+aFornec[nX][1]+cLote))
		While CPY->(!EOF()) .And. CPY->CPY_NUMATA == cNumAta .AND. CPY->CPY_LOTE == cLote	
			cCodPro := CPY->CPY_CODPRO
			nPreco := CPY->CPY_VLUNIT
			nQuant := 0	
			CX3->(DbSetOrder(2))//CX3_FILIAL+CX3_NUMATA+CX3_LOTE+CX3_CODPRO
			If CX3->(DbSeek(cCodFil+cNumAta+cLote+cCodPro))
				While CX3->(!EOF()) .AND. CX3->CX3_NUMATA == cNumAta .AND. CX3->CX3_LOTE == cLote .AND. CX3->CX3_CODPRO = cCodPro
					If !CX3->(CX3_EMPENH)
						cNumSC 	:= CX3->CX3_NUMSC
						cItemSC	:= CX3->CX3_ITEMSC
						nQuant 	:= CX3->CX3_QUANT 
						cFilEnt	:= CX3->CX3_FILENT
						nPos := aScan( aProd, {|x| AllTrim(x[1]) == AllTrim(cCodPro)} )
						If  nPos == 0 					
							Aadd(aProd, {cCodPro, nQuant,0,cFilEnt,cNumSC,cItemSC} )
						Else
							aProd[nPos][2] := aProd[nPos][2] + nQuant
						EndIf
					EndIf					
					CX3->(dbSkip())
				EndDo
			
				For nPos := 1 To Len(aProd)
					If aProd[nPos,1] == cCodPro
						aProd[nPos][3] := aProd[nPos][2] * nPreco
					EndIf
				Next nI
			EndIf
			CPY->(dbSkip())
		EndDo
	EndIf
	
	If Len(aProd) == 0
		MsgAlert("Não existem solicitações para serem empenhadas")
	Else 
		aSort(aProd)
		If Len(aProd) > 0
			aAdd(aAta, cCodEdt)
			aAdd(aAta, cNumAta)
			aAdd(aAta, cNumPro)
			aAdd(aAta, aProd)
			
			Aadd(aDadosAta,cCodEdt)
			Aadd(aDadosAta,cNumPro)
			Aadd(aDadosAta,cCodOrg)
			
		EndIf
	
		nGravou := GCPXGeraNE(oModel,,cCodFor,cLoja,.F.,.F.,.T.,aAta,aDadosAta)
		cCodNe	 := CX0->CX0_CODNE
		
		If nGravou != 0 
			Help( "" , 1 , "GCPGENEATA" )
		EndIf
		
		If nGravou == 0
			For nPos := 1 To Len(aProd)
				CX3->(DbSetOrder(1))
				If CX3->(DbSeek(cCodFil+cNumAta+aProd[nPos][1]))
					While CX3->(!EOF()) .AND. CX3->CX3_NUMATA == cNumAta .AND. Alltrim(CX3->CX3_CODPRO) == Alltrim(aProd[nPos][1])
						If !CX3->(CX3_EMPENH)
							RecLock("CX3",.F.)
								CX3->CX3_EMPENH := .T.
								CX3->CX3_CODNE := CX0->CX0_CODNE
								
								If A400GetIt(CX0->CX0_CODNE,(aProd[nPos][1]))
									CX3->CX3_ITEMNE := CX1->CX1_ITEM 	
								EndIf
							MsUnlock()
						EndIf
						CX3->(dbSkip())
					EndDo
				EndIf
			Next
		EndIf	
	EndIf
Next nX

RestArea(aArea)

Return Nil
