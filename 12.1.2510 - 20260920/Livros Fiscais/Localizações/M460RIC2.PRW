#INCLUDE "PROTHEUS.CH"
#include "SIGAWIN.CH"        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

#DEFINE X_IMPOSTO    01 //Nombre Impuesto
#DEFINE X_NUMIMP     02 //Subfijo de Impuesto

/*/{Protheus.doc} M460RIC2
	Calculo de Retención de ICA por Item para documentos de salida
	@type function
	@version 12.1.2510
	@author eduardo.manriquez
	@since 8/18/2026
	@param cCalculo, character, Valor a cálcular (A=Alícuota, B=Base, V=Valor).
	@param nItem, numeric, Número de ítem.
	@param aInfo, array, Información de impuestos (Código impuesto, Campo libro fiscal).
	@return xRet, Valor de impuesto.
/*/
Function M460RIC2(cCalculo,nItem,aInfo)

	Local nDesconto	:= 0
	Local lXFis     := .F.
	Local xRet      := Nil
	Local nVal      := 0
	Local cImp      := ""
	Local nAliq     := 0
	Local nImporte	:= 0
	Local cCodMun   := ""
	Local cCatCliFor:= ""
	Local cCodIca	:= ""
	Local cPessoa	:= ""
	Local lCodMun   := .F.       
	Local aImpRef	:= {}
	Local aImpVal	:= {}
	Local nI:=1
	Local nMoeda    := 1
	Local nTaxaMoed := 1	
	Local nMoedSFF  := 1
	Local cFunName  := FunName()
	Local lRICACOL := VALTYPE(M->F2_ESPECIE) =="C"
	Local lInfoCli := (cModulo == 'FAT' .Or. cFunName $ "MATA468N|MATA461")
	Local cImpIncid := ""
	Local cImpLiqui := ""
	Local cImpCalc	:= ""
	Local aImp      := {}
	Local nE        := 0
	Local lExSC6TP	:= SC6->(ColumnPos("C6_TPACTIV")) > 0
	Local lExSC6CM	:= SC6->(ColumnPos("C6_CODMUN")) > 0
	Local cVar 		:=  ReadVar()
	LOCAL nCols		:= 0
	Local nPosTPSC6	:=	0
	Local nPosCMSC6 :=  0
	Local nBaseAUI	:= 0
	Local aAreaSFC := {}
	Local aAreaSFB := {}
	Local aConfTES := {}
	Local aDatosSFF   := Array(5)
	Local cTes     := ""
	Local aItemINFO := {}
	Local cZonFis   := ""
	Local cCfo      := ""
	Local lRet      := .F.
	Local nBase     := 0
	Local cRetICA   := ""
	Local nAliqAUI := SuperGetMv( 'MV_PERAUI' ,.F., 0)
	Local cMvDescSai  := SuperGetMv( 'MV_DESCSAI' , .F., , '1' )
	Local nPosTPSD2  := 0
	Local nPosCMSD2  := 0
	Local cTipoCliFor := ""
	Local cClaveSFF   := ""
	Local nMoedaOri   := 1

	Static lRatVICol := FindFunction("RatVICol")
	Static oJConfImp := JsonObject():New()
	Static lCpoAlqAIU := SA1->(ColumnPos("A1_ALQAIU"))>0 .And. SA2->(ColumnPos("A2_ALQAIU"))>0

	lXfis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

	If !LXFis
		aItemINFO  := ParamIxb[1]
		xRet   := ParamIxb[2]
		cImp:=xRet[1]
		// Busca o CFO do Tes Correspondente - SF4
		dbSelectArea("SF4")
		cCFO := SF4->F4_CF
		cTes := SF4->F4_CODIGO 
		
		IF cFunName $ "MATA468N|MATA461" .OR.  (FwIsInCallStack("fCalImpTES") )
			If lExSC6TP 
				cCodIca := SC6->C6_TPACTIV
			EndIF
			If lExSC6CM
				cCodMun := SC6->C6_CODMUN
			EndIf
		EndIf

	Else
		xRet:=0
		cCFO:= MaFisRet(nItem,"IT_CF")
		cTes:= MaFisRet(nItem,"IT_TES")
		cImp:=aInfo[X_IMPOSTO]
		nCols:=nItem
		IF cFunName $ "MATA410"
			nPosTPSC6	:=	aScan(aHeader,{|x| AllTrim(x[2])=="C6_TPACTIV"}) 
			nPosCMSC6	:=  aScan(aHeader,{|x| AllTrim(x[2])=="C6_CODMUN"})
			If nPosTPSC6 > 0 
				cCodIca	:= aCols[nCols][nPosTPSC6]
			EndIf
			If nPosCMSC6 > 0 
				cCodMun	:= aCols[nCols][nPosCMSC6]
			EndIf	
		Else
			nPosTPSD2	:=	aScan(aHeader,{|x| AllTrim(x[2])=="D2_TPACTIV"}) 
			nPosCMSD2	:=  aScan(aHeader,{|x| AllTrim(x[2])=="D2_CODMUN"})
			If  cVar == "M->D2_TPACTIV"
				cCodIca:= M->D2_TPACTIV
				If nPosCMSD2 > 0 
					cCodMun	:= aCols[nItem][nPosCMSD2]
				EndIf
			ElseIf cVar == "M->D2_CODMUN"
				cCodMun:= M->D2_CODMUN
				If nPosTPSD2 > 0 
					cCodIca	:= aCols[nItem][nPosTPSD2]
				EndIf
			Else
				If nPosTPSD2 > 0 
					cCodIca	:= aCols[nCols][nPosTPSD2]
				EndIf
				If nPosCMSD2 > 0 
					cCodMun	:= aCols[nCols][nPosCMSD2]
				EndIf
			EndIf		
		ENDIF
			
		
		lInfoCli := MaFisRet(,"NF_CLIFOR") == "C"

	Endif

	If lInfoCli
		cTipoCliFor:= SA1->A1_TPESSOA
		cPessoa	   := SA1->A1_PESSOA
		cRetICA    := SA1->A1_RETICA
		cZonfis    := SM0->M0_ESTENT
		cCatCliFor := SA1->A1_TIPO
		lRet:= (SA1->A1_RETICA == "S")
	Else
		cTipoCliFor:= SA2->A2_TPESSOA
		cRetICA    := UPPER(SubStr(GETNEWPAR("MV_AGENTE",""),2,1))
		cPessoa	   := If(SA2->(FieldPos("A2_PESSOA")) > 0,SA2->A2_PESSOA," ")
		cZonFis    := SA2->A2_EST
		cCatCliFor := SA2->A2_TIPO
		lRet:= (SA2->A2_RETICA == "S")	
	Endif

	If lRICACOL 
		IF M->F2_ESPECIE $"NCP|NDI"
			cCatCliFor := SA2->A2_TIPO
			IF cCatCliFor=="4"
				lRet:= .F.
			EndIF
		ENDIF
	Endif

	If lRet
		If !oJConfImp:hasProperty(cImp)
			oJConfImp[cImp] := JsonObject():New()
			oJConfImp[cImp]['FB_ALIQ'] := M460Aliq(cImp) //Obtiene alicuota de tabla SFB
		EndIf

		If !oJConfImp:hasProperty(cTes+cImp)
			aConfTES := VldImpxTES(cTes, cImp) //Obtiene informacion del impuesto configurado en la TES.
			oJConfImp[cTes+cImp] := JsonObject():New()
			oJConfImp[cTes+cImp]['FC_LIQUIDO'] := aConfTES[1]
			oJConfImp[cTes+cImp]['FC_CALCULO'] := aConfTES[2]
			oJConfImp[cTes+cImp]['FC_INCIMP']  := aConfTES[3]
		EndIf
		If Empty(cCodIca)
			nAliq   := oJConfImp[cImp]['FB_ALIQ']  // Aliquota padrao
			lRet    := .T.
		Else
			cClaveSFF := cImp + cCodMun + cCodICA //Impuesto + Municipio + Tipo de actividad
			If !oJConfImp:hasProperty(cClaveSFF)
				aDatosSFF := M460ICASFF(cImp, cCodMun, cCodICA) //Obtiene datos de configuracion de impuestos SFF
				oJConfImp[cClaveSFF]               := JsonObject():New()
				oJConfImp[cClaveSFF]['FF_ALIQ']    := aDatosSFF[1]
				oJConfImp[cClaveSFF]['FF_FLAG']    := aDatosSFF[2]
				oJConfImp[cClaveSFF]['FF_IMPORTE'] := aDatosSFF[3]
				oJConfImp[cClaveSFF]['FF_MOEDA']   := aDatosSFF[4]
				oJConfImp[cClaveSFF]['R_E_C_N_O_'] := aDatosSFF[5]
				If !(oJConfImp[cClaveSFF]['FF_FLAG'] == "1")
					UpdRICASFF(oJConfImp[cClaveSFF]['R_E_C_N_O_']) //Actualiza campo FF_FLAG
				EndIf
			EndIf

			lRet := .F.
			If oJConfImp[cClaveSFF]['R_E_C_N_O_'] > 0
				nAliq    := oJConfImp[cClaveSFF]['FF_ALIQ']
				nImporte := oJConfImp[cClaveSFF]['FF_IMPORTE']
				nMoedSFF := oJConfImp[cClaveSFF]['FF_MOEDA']
				lCodMun  := .T.
				lRet     := .T.
			EndIf
			If !lCodMun											
				nAliq   := oJConfImp[cImp]['FB_ALIQ']  // Aliquota padrao
				lRet    := .T.
			EndIf		
		Endif
		If lRet
			If !lXFis
				aImp := aClone(ParamIxb[2])
				cImpIncid := Alltrim(aImp[10])
				If !Empty(cImpIncid)
					nE := AScan(aItemINFO[6],{|x| x[1]==cImpIncid})
					If nE > 0
						xRet[02]  := nAliq // Alicuota de Zona Fiscal

						If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
							nDesconto	:=	xRet[18]
						Endif
						If Trim(cImpIncid) <> "AUI"  .OR. (Trim(cImpIncid) == "AUI" .And. !lCpoAlqAIU)
							xRet[03]  += aItemINFO[6,nE,4]
						Else
							aAreaSFC := SFC->(GetArea())
							aAreaSFB := SFB->(GetArea())
							SFC->(dbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
							If SFC->(MsSeek(xFilial("SFC")+SF4->F4_CODIGO+"AUI"))
								DbSelectArea("SFB")
								SFB->(DbSetOrder(1))//FB_FILIAL+FB_CODIGO
								If SFB->(MsSeek(xFilial("SFB")+"AUI"))
									nBaseAUI := aItemINFO[3] + aItemInfo[4] + aItemInfo[5]
									If SFC->FC_LIQUIDO=="S"
										nBaseAUI-= nDesconto
									Endif
									nBaseAUI := nBaseAUI * (SFB->FB_ALIQ/100)
									nBaseAUI	:= nBaseAUI * (nAliqAUI/100)
									SFC->(RestArea(aAreaSFC))
									SFB->(RestArea(aAreaSFB))
									FwFreeArray(aAreaSFB)
  									FwFreeArray(aAreaSFC)
									xRet[03]+= nBaseAUI
								EndIF	
							EndIF	
						Endif
						xRet[04]  += round(xRet[03] * ( xRet[02]/1000) ,2)

					EndIf
				Else
					xRet[02]  := nAliq // Alicuota de Zona Fiscal
					xRet[03]  := (aItemINFO[3] - nDesconto) 
					
					xRet[04]  := round(xRet[03] * ( xRet[02]/1000) ,2)
					
					nMoedaOri:= IIf(Type("lPedidos") <> "U" .And. lPedidos , SC5->C5_MOEDA ,Max(SF2->F2_MOEDA,1))
					If xMoeda(xRet[03],nMoedaOri ,1) < xMoeda(nImporte,nMoedSFF,1)
						xRet[04]  := 0
					EndIf
				EndIf
			Else
				Do Case
					Case cCalculo=="B"
						cImpIncid := Alltrim(oJConfImp[cTES+cImp]['FC_INCIMP'])
						cImpLiqui:=Alltrim(oJConfImp[cTES+cImp]['FC_LIQUIDO'])
						cImpCalc :=Alltrim(oJConfImp[cTES+cImp]['FC_CALCULO']) 

						//+---------------------------------------------------------------+
						//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
						//+---------------------------------------------------------------+
						If !Empty(cImpIncid)
							aImpRef:= aClone(MaFisRet(nItem,"IT_DESCIV"))
							aImpVal:= aClone(MaFisRet(nItem,"IT_VALIMP"))
							For nI:=1 to Len(aImpRef)
								If !Empty(aImpRef[nI])
									IF Trim(aImpRef[nI][1])$cImpIncid
										IF Trim(aImpRef[nI][1]) <> "AUI"  .OR. (Trim(aImpRef[nI][1]) == "AUI" .And. !lCpoAlqAIU)
											xRet+=aImpVal[nI]
										Else
											aAreaSFC := SFC->(GetArea())
											aAreaSFB := SFB->(GetArea())
											SFC->(DbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
											If SFC->(MsSeek(xFilial("SFC")+SF4->F4_CODIGO+"AUI"))
												DbSelectArea("SFB")
												SFB->(DbSetOrder(1))//FB_FILIAL+FB_CODIGO
												If SFB->(MsSeek(xFilial("SFB")+"AUI"))
													nBaseAUI := MaFisRet(nItem,"IT_VALMERC") + MaFisRet(nItem,"IT_FRETE") + MaFisRet(nItem,"IT_DESPESA") + MaFisRet(nItem,"IT_SEGURO")
													If cMvDescSai == '1'
														nBaseAUI+= MaFisRet(nItem,"IT_DESCONTO")
													Endif
													If cImpLiqui=="S"
														nBaseAUI-=MaFisRet(nItem,"IT_DESCONTO")
													Endif
													nBaseAUI := nBaseAUI * (SFB->FB_ALIQ/100)
													nBaseAUI	:= nBaseAUI * (nAliqAUI/100)
													SFC->(RestArea(aAreaSFC))
													SFB->(RestArea(aAreaSFB))
													FwFreeArray(aAreaSFB)
 													FwFreeArray(aAreaSFC)
													xRet+= nBaseAUI
												EndIF	
											EndIF	
										Endif
									Endif
								Endif
							Next
						Else
							xRet += MaFisRet(nItem,"IT_VALMERC")
							If cImpLiqui=="S"
								xRet-=If(cImpCalc=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
							Endif
						Endif
					Case cCalculo=="A"
						xRet:=nAliq
					Case cCalculo=="V"         
						SFC->(DbSetOrder(2))//FC_FILIAL+FC_TES+FC_IMPOSTO
						nVal	:= 0
						If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
							nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
							nVal:=0					
							If SFC->FC_CALCULO=="T"
								
								nBase:=MaFisRet(,"NF_BASEIV"+aInfo[X_NUMIMP])+MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
								nVal:=MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2]),.T.)
							Else
								nBase:= MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
								nVal :=	MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
							Endif
						Endif
									
						If Type("M->F1_MOEDA")<>"U" 			   	
							nMoeda := M->F1_MOEDA
							nTaxaMoed := M->F1_TXMOEDA
						ElseIf Type("M->C7_MOEDA")<>"U"
							nMoeda := M->C7_MOEDA
							nTaxaMoed := M->C7_TXMOEDA				
						ElseIf Type("M->F2_MOEDA")<>"U"
							nMoeda := M->F2_MOEDA
							nTaxaMoed := M->F2_TXMOEDA				
						ElseIf Type("M->C5_MOEDA")<>"U" 
							nMoeda := M->C5_MOEDA
							nTaxaMoed := M->C5_TXMOEDA				
						EndIf	        
						
												
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calcula o imposto somente se o valor da base for maior ou igual a base minima    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed) >= xMoeda(nImporte,nMoedSFF,1)
							If lRatVICol .And. SFC->FC_CALCULO == "I"
								xRet := RatVICol(aInfo, nItem, nAliq, nVal, nMoeda, 1000)
							Else
								xRet:=nBase * ( nAliq/1000)
							Endif
						Else
							xRet:= 0
						EndIf
				EndCase
			Endif
			FwFreeArray(aImp)
		EndIf
	EndIf

	FwFreeArray(aDatosSFF)
	FwFreeArray(aConfTES)
	FwFreeArray(aImpRef)
	FwFreeArray(aImpVal)
Return( xRet )   

/*/{Protheus.doc} M460Aliq
Consulta la tabla SFB para obtener la alícuota.
@type function
@version 12.1.2510
@author eduardo.manriquez
@since 5/15/2025
@param  cImpuesto, Character, Código de impuesto.
@return nAliqSFB, Numeric, Alícuota informada en tabla SFB.
/*/
Static Function M460Aliq(cImpuesto)
	Local nAliqSFB := 0
	Local aAreaSFB := {}

	Default cImpuesto := ""

	aAreaSFB := GetArea()
	dbSelectArea("SFB")
	SFB->(DbSetOrder(1))//FB_FILIAL+FB_CODIGO
	If SFB->(MsSeek(xFilial("SFB") + cImpuesto))
		nAliqSFB := SFB->FB_ALIQ //Aliquota
	EndIf
	RestArea(aAreaSFB)
	FwFreeArray(aAreaSFB)

Return nAliqSFB

/*/{Protheus.doc} VldImpxTES
	Obtiene información del impuesto configurado en la TES.
	@type  Function
	@author eduardo.manriquez
	@since 14/08/2026
	@version 12.1.2510
	@param cTES, Character, Código de la TES.
	@param cImpuesto, Character, Código de impuesto.
	@return aConfTES, Array, Configurado en la TES.
	/*/
Static Function VldImpxTES(cTES, cImpuesto)
	Local aAreaSFC := {}
	Local aConfTES := {"","",""} //[1]=FC_LIQUIDO; [2]=FC_CALCULO; [3]=FC_INCIMP

	Default cTES := ""
	Default cImpuesto := ""

	aAreaSFC := GetArea()
	DbSelectArea("SFC")
	SFC->(DbSetOrder(2))//FC_FILIAL+FC_TES+FC_IMPOSTO
	If (SFC->(MsSeek(xFilial("SFC") + cTES + cImpuesto)))
		aConfTES[1] := SFC->FC_LIQUIDO
		aConfTES[2] := SFC->FC_CALCULO
		aConfTES[3] := Alltrim(SFC->FC_INCIMP)
	Endif
	RestArea(aAreaSFC)
	FwFreeArray(aAreaSFC)

Return aClone(aConfTES)

/*/{Protheus.doc} M460ICASFF
	Obtiene la configuracion por impuesto, municipio y tipo de actividad registrada en SFF.
	@type function
	@version 12.1.2510
	@author eduardo.manriquez
	@since 8/13/2025
	@param cImpuesto, character, codigo de impuesto.
	@param cCodMun, character, codigo de municipio.
	@param cCodICA, character, codigo de tipo de actividad.
	@return Array, Valores de los campos: FF_ALIQ, FF_FLAG, FF_IMPORTE, FF_MOEDA y R_E_C_N_O_.
/*/
Static Function M460ICASFF(cImpuesto, cCodMun, cCodICA)
	Local cQuery      := ""
	Local nOrd        := 1
	Local oQryExec := Nil
	Local aDatosSFF := {0, "", 0, 0, 0}
	Local cAlias    := ""

	Default cImpuesto := ""
	Default cCodMun   := ""
	Default cCodICA   := ""

	cQuery := " SELECT "
	cQuery += " SFF.FF_ALIQ, SFF.FF_FLAG, SFF.FF_IMPORTE, SFF.FF_MOEDA, SFF.R_E_C_N_O_ "
	cQuery += " FROM " +  RetSqlName("SFF") + " SFF "
	cQuery += " WHERE "
	cQuery += " SFF.FF_FILIAL = ? "
	cQuery += " AND SFF.FF_IMPOSTO = ? "
	cQuery += " AND SFF.FF_CODMUN = ? "
	cQuery += " AND SFF.FF_COD_TAB = ? "
	cQuery += " AND SFF.D_E_L_E_T_ = ? "

	cQuery := ChangeQuery(cQuery)
	oQryExec := FwExecStatement():New(cQuery)

    oQryExec:SetString(nOrd++, xFilial("SFF")) //Filial
    oQryExec:SetString(nOrd++, cImpuesto) //Impuesto
    oQryExec:SetString(nOrd++, cCodMun) //Municipio
    oQryExec:SetString(nOrd++, cCodICA) //Tipo Actividad
    oQryExec:SetString(nOrd++, ' ') //Delete

	cAlias := oQryExec:OpenAlias()

	aDatosSFF[1] := (cAlias)->FF_ALIQ //Alcuota
	aDatosSFF[2] := (cAlias)->FF_FLAG //Flag
	aDatosSFF[3] := (cAlias)->FF_IMPORTE //Importe
	aDatosSFF[4] := (cAlias)->FF_MOEDA //Moneda
	aDatosSFF[5] := (cAlias)->R_E_C_N_O_ //Recno
	(cAlias)->(DBCloseArea())

	oQryExec:Destroy()
	FwFreeObj(oQryExec)

Return aClone(aDatosSFF)

/*/{Protheus.doc} UpdRICASFF
	Actualizacion del registro en la tabla SFF.
	@type function
	@version 12.1.2510
	@author eduardo.manriquez
	@since 20/08/2026
	@param nRecnoSFF, numeric, Número de recno del registro en SFF.
/*/
Static Function UpdRICASFF(nRecnoSFF)
	Local aAreaSFF := {}

	Default nRecnoSFF := 0

	If nRecnoSFF > 0
		aAreaSFF := GetArea()
		DbSelectArea("SFF")//FF_FILIAL+FF_NUM+FF_ITEM
		SFF->(DbSetOrder(1))
		SFF->(dbGoTo(nRecnoSFF))
		RecLock("SFF",.F.)
			Replace FF_FLAG With "1"
		SFF->(MsUnlock())
		RestArea(aAreaSFF)
	EndIf

	FwFreeArray(aAreaSFF)
	
Return



