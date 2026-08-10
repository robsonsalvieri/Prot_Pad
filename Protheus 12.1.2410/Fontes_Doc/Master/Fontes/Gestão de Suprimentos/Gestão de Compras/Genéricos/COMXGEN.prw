#INCLUDE "PROTHEUS.CH"
#INCLUDE "COMXGEN.CH"

Static lFWPDCanUse 	:= FindFunction("FWPDCanUse") .And. FWPDCanUse(.T.)
Static lPessoal		:= lFWPDCanUse .And. VerSenha(192)
Static lSensivel	:= lFWPDCanUse .And. VerSenha(193)
Static lRTxtLGPD	:= FindFunction("RetTxtLGPD")
Static lOfLGPD		:= FindFunction("OfuscaLGPD")
Static lGestaoEmp	:= (At("E",FWSM0Layout()) > 0)
/*/{Protheus.doc} COMXHDCO()
Monta aHeader a aCols

@param	cAlias		- Alias
@param	aField		- Array com campos a serem apresentados
@param	aNotField	- Arrya com campos que não serão apresentados

@author rodrigo.mpontes
@since 07/10/19
@version 12
/*/
Function COMXHDCO(cAliasTmp,aField,aNotField)   

Local aRetHead		:= {}
Local aAllFields	:= (cAliasTmp)->(DbStruct())
Local lInclui		:= .T.
Local nX			:= 0
Local aAreaSX3		:= SX3->(GetArea())

Default aField		:= {}
Default	aNotField	:= {} 

aAllFields := FWVetByDic(aAllFields,cAliasTmp,.F.)

SX3->(DbSetOrder(2))
For nX := 1 To Len(aAllFields)
	If X3Uso(GetSx3Cache(aAllFields[nX,1],'X3_USADO'))
		lInclui := .T.
		
		If Len(aField) > 0
			lInclui := aScan(aField,{|x| AllTrim(x) == AllTrim(aAllFields[nX,1])}) > 0
		Elseif Len(aNotField) > 0
			lInclui := aScan(aNotField,{|x| AllTrim(x) == AllTrim(aAllFields[nX,1])}) == 0
		Endif
		
		If lInclui
			SX3->(DbSeek(aAllFields[nX,1]))
			aAdd(aRetHead,{ TRIM(X3Titulo()),;
							GetSx3Cache(aAllFields[nX,1],'X3_CAMPO'),;
							GetSx3Cache(aAllFields[nX,1],'X3_PICTURE'),;
							GetSx3Cache(aAllFields[nX,1],'X3_TAMANHO'),;
							GetSx3Cache(aAllFields[nX,1],'X3_DECIMAL'),;
							GetSx3Cache(aAllFields[nX,1],'X3_VALID'),;
							GetSx3Cache(aAllFields[nX,1],'X3_USADO'),;
							GetSx3Cache(aAllFields[nX,1],'X3_TIPO'),;
							GetSx3Cache(aAllFields[nX,1],'X3_F3'),;
							GetSx3Cache(aAllFields[nX,1],'X3_CONTEXT')})
		Endif
	Endif
Next nX

RestArea(aAreaSX3)
FwFreeArray(aAreaSX3)

Return aRetHead

/*/{Protheus.doc} COMTemSXI
	Dado <cEventId> busca na tabela SXI se existe algum cadastro
de usuario que deva receber alerta para o evento.
@author philipe.pompeu
@since 13/12/2019
@return lResult, se existem registros para <cEventId>
@param cEventID, caractere, evento a ser buscado.
/*/
Function COMTemSXI(cEventID,cIdUser)
	Local lResult	:= .F.
	Local cQuerySXI	:= ""
	Local cAliasSXI	:= GetNextAlias()
	
	Default cEventID := 'XXX'
	Default cIdUser	 := ""
	
	cQuerySXI   := "SELECT COUNT(*) AS NREG " 
	cQuerySXI   += "FROM SXI SXI "
	cQuerySXI   += "WHERE SXI.XI_EVENTID='"+ cEventID +"' AND "

	If !Empty(cIdUser)
		cQuerySXI	+= "SXI.XI_USERID = '" + cIdUser + "' AND "
	Endif

	cQuerySXI   += "SXI.D_E_L_E_T_= ' ' "
	cQuerySXI   := ChangeQuery(cQuerySXI)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySXI),cAliasSXI)
	
	lResult := (cAliasSXI)->NREG > 0 
	
	(cAliasSXI)->(dbCloseArea())
Return( lResult )


/*/{Protheus.doc} AjusCNL
//TODO Ajusta registros tabela CNL 
@author fabiano.dantas
@since 24/12/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AjusCNL()

	If FindFunction("AjstCNL")

 		AjstCNL()

	Else

		Alert(STR0006)//("Por favor, realize o download da expedição contínua disponível a partir de Dezembro de 2021 para prosseguir")

	 EndIf

Return

/*/{Protheus.doc} AjustaCNL
//TODO Ajusta registros tabela CNL 
@author fabiano.dantas
@since 24/12/2019
@version 1.0
@return lRet

@type function
/*/         
Function AjustaCNL()

	If FindFunction("CNLAJUSTA")

		CNLAJUSTA()

	Else
		
		 Alert(STR0006)//("Por favor, realize o download da expedição contínua disponível a partir de Dezembro de 2021 para prosseguir")
		
	EndIf

Return

/*/{Protheus.doc} RetTxtLGPD()
Retorna Texto de acordo com o acesso LGPD do Usuário ao campo informado

@param	cTxt		- Texto Atual
@param	cCampo		- Nome do campo a verificar
@param	lTamCpo		- .T. -> Retorna string com tamanho do campo / 
					  .F. -> Limpa caracteres em Branco do final

@author rd.santos
@since 27/12/19
@version 12
/*/

Function RetTxtLGPD(cTxt,cCampo,lTamCpo)
Local aGrupos		:= {}
Local nX			:= 0
Default lTamCpo		:= .F.

If lFWPDCanUse .And. FwProtectedDataUtil():IsFieldInList( cCampo )
	aGrupos := FwProtectedDataUtil():GetFieldGroups( cCampo )
	For nX := 1 To Len(aGrupos)
		If   (aGrupos[nX]:IsPersonal() .And. !lPessoal); 
		.Or. (aGrupos[nX]:IsSensible() .And. !lSensivel)
			cTxt := If(lTamCpo,Padr(cTxt,TamSX3(cCampo)[1],''),Rtrim(cTxt))
			cTxt := FwProtectedDataUtil():ValueAsteriskToAnonymize( cTxt )
			Exit
		Endif
	Next nX
Endif

Return cTxt

/*/{Protheus.doc} OfuscaLGPD()
Ofusca um campo MsGet de acordo com o acesso do Usuário ao campo informado 

@param	oGet		- Objeto do tipo MsGet (TGet)
@param	cCampo		- Campo associado ao campo MsGet

@author rd.santos
@since 27/12/19
@version 12
/*/

Function OfuscaLGPD(oGet,cCampo)
Local aGrupos		:= {}
Local nX			:= 0
Local lRet			:= .F.

If lFWPDCanUse .And. FwProtectedDataUtil():IsFieldInList( cCampo )
	aGrupos := FwProtectedDataUtil():GetFieldGroups( cCampo )
	For nX := 1 To Len(aGrupos)
		If   (aGrupos[nX]:IsPersonal() .And. !lPessoal); 
		.Or. (aGrupos[nX]:IsSensible() .And. !lSensivel)
			If oGet <> NIL
				oGet:lObfuscate := .T.
				oGet:bWhen 		:= { || .F. }
			Endif
			lRet := .T.
			Exit
		Endif
	Next nX
Endif

Return lRet

/*/{Protheus.doc} SuprLGPD()
Verifica se o LGPD deve ser ofuscado para os módulos de Suprimentos 

@author rd.santos
@since 17/01/20
@version 12
/*/
Function SuprLGPD()
Local lRet := .F.

lRet := lRTxtLGPD  	.And. ; // FindFunction("RetTxtLGPD")
		lOfLGPD 	.And. ; // FindFunction("OfuscaLGPD")
		lFWPDCanUse 		// FindFunction("FWPDCanUse") .And. FWPDCanUse(.T.)

Return lRet

/*/{Protheus.doc} ChkNumSC7()
Verifica a existencia do numero do pedido de Compras
O numero do pedido de compras deve ser controlado no modo compartilhado 
devido ao controle por Filial de Entrega.

@author rodrigo.mpontes
@since 14/01/21
@version 12
/*/

Function ChkNumSC7(cNumPc,lViewHlp,cEntFil)

Local lRet		:= .F. 
Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->(GetArea())
Local aAreaSM0	:= SM0->(GetArea())
Local lPcFilEnt := SuperGetMV("MV_PCFILEN") 
Local cQuery    := ""
Local cChkSC7	:= ""
Local cCodEmp 	:= Iif( lGestaoEmp .And. (FWModeAccess("SC7",1) == "E"),FWCodEmp(),'')
Local lPCMDNum := SuperGetMV("MV_PCMDNUM",.F.,.F.)

DEFAULT lViewHlp:= .F.
DEFAULT cEntFil	:= "" 

If Type("Inclui") == 'U'
   Inclui := .F.
Endif

If Empty(xFilial("SC7"))
	SC7->(dbSetOrder(1))
	lRet := SC7->(dbSeek(xFilial("SC7")+cNumPc))
	If lViewHlp .And. lRet
		HELP("  ",1,"JAGRAVADO")
	EndIf
Else
	SC7->(dbSetOrder(1))
	If lPcFilEnt
		cChkSC7	:= GetNextAlias()
		cQuery := "Select COUNT(C7_NUM) SC7PED"
		cQuery += " From "+RetSqlName("SC7")+" SC7"
		cQuery += " Where ""
		If lPCMDNum .AND. Inclui
			cQuery += "	SC7.C7_FILIAL BETWEEN '"+cCodEmp+"' AND '"+cCodEmp+Replicate('z',FWSizeFilial()-Len(ccodEmp))+"' "
	    Else
			If Empty(cEntFil)
				cQuery += "   SC7.C7_FILIAL like '"+AllTrim(FWCodFil("SC7"))+"%'"
			Else
				cQuery += "   ( (SC7.C7_FILIAL Like '"+cEntFil+"%' And SC7.C7_FILIAL<>'"+xfilial("SC7")+"') "
				cQuery += " 	OR SC7.C7_FILENT = '" + cEntFil + "')"
			Endif
		Endif
			cQuery += " and SC7.C7_NUM = '"+cNumPc+"'"
			cQuery += " And SC7.D_E_L_E_T_=' '"

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cChkSC7,.T.,.T.)

		If (cChkSC7)->SC7PED > 0
		    lRet:= .T.
		EndIf 
		(cChkSC7)->(DbCloseArea())

		If lViewHlp .And. lRet
			Aviso(STR0001,STR0002+STR0003,{STR0004},2) //"Numero ja gravado"###"Este numero de pedido ja foi utilizado em outra Filial. Selecione outro numero de pedido."###"Voltar"
		EndIf
	Else
		lRet := SC7->(dbSeek(xFilial("SC7")+cNumPc))
		If lViewHlp .And. lRet
			Aviso(STR0001,STR0005+SM0->M0_CODFIL+" - "+AllTrim(SM0->M0_FILIAL)+STR0003,{STR0004},2) //"Numero ja gravado"###"Este numero de pedido ja foi utilizado na Filial : "###" . Selecione outro numero de pedido."###"Voltar"
		EndIf
	EndIf
EndIf

RestArea(aAreaSM0)
RestArea(aAreaSC7)
RestArea(aArea)

Return lRet


/*/{Protheus.doc} COMXHDCO()
Verifica se o campo está marcado como usado.
@param	aCampos		- Array com o campo a ser verificado
nOpc - 1 = retorna campos usados
nOpc - 2 = retorna campos NÃO usados
aRet = retorna o Array com os campos definidos na nOpc
@version 12
/*/
Function COMXVLDCPO(aCampos,nopc)
Local nx := 0
Local aRet := {}
Default aCampos := {}
Default nopc := 1

lRet := .T.
For nx := 1 to len(aCampos)
	If aCampos[nx] $ "D1_DESPESA|D1_SEGURO|D1_DESC|F1_LOJAENT|F1_FORENT" .And. nOpc == 1
		aadd(aRet,aCampos[nx])
	Else
		If X3Uso(GetSx3Cache(Trim(aCampos[nx]),'X3_USADO'))  .And. nOpc == 1
			aadd(aRet,aCampos[nx])
		EndIf
		If !X3Uso(GetSx3Cache(Trim(aCampos[nx]),'X3_USADO'))  .And. nOpc == 2
			aadd(aRet,aCampos[nx])
		EndIf
	Endif	
Next

Return aRet

/*/{Protheus.doc} COMVldMoeda()
Verifica se moeda existe no contabil

@param	nMoeda		- Moeda a ser validada (Tabela CTO)
@author rodrigo.mpontes
@version 12
/*/

Function COMVldMoeda(nMoeda)

Local lRet 		:= .F.
Local cMoeda	:= ""
Local nTamMoed	:= TamSX3("CTO_MOEDA")[1]
Local aCtbMoeda	:= {}

Default nMoeda := 0

cMoeda := StrZero(nMoeda,nTamMoed)

aCtbMoeda := CtbMoeda(cMoeda)

If !Empty(aCtbMoeda[1])
	lRet := .T.
Endif

Return lRet

