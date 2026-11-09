#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP060.CH"

#DEFINE PropriedadeRuralService totvs.protheus.agrobusiness.agd.PropertyRuralService

/*/{Protheus.doc} AGDP060EVT
Classe de eventos do modelo do AGDP060
@type class
@version 12
@author AgroDistribuidor
@since 24/09/2025
/*/
Class AGDP060EVT From FWModelEvent

	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)
	Method InTTS(oModel, cModelId)

End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author AgroDistribuidor
@since 24/09/2025
@return variant, self
/*/
Method New() Class AGDP060EVT
Return Nil


/*/{Protheus.doc} ModelPosVld
Validação do Modelo de Dados
@type method
@version 12
@author AgroDistribuidor
@since 07/01/2026
@param oModel, object, modelo
@param cModelId, character, modelo id
@return logical, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDP060EVT
	Local oModelNEP   := oModel:GetModel("AGDP060_NEP")
	Local oPropSrvc   := Nil
	Local lEstadoSC   := .F.
	Local cDEmptFlds  := ""
	Local nOperation  := oModel:GetOperation()

	if nOperation == MODEL_OPERATION_DELETE
		Return AGDP060Delete()
	endif

	If oModelNEP:GetValue("NEP_PRORUR") == "1" // Propriedade Rural "1"=Sim
		oPropSrvc := PropriedadeRuralService():New()
		lEstadoSC := oPropSrvc:validaUfSc(oModelNEP:GetValue("NEP_CODCLI"), oModelNEP:GetValue("NEP_LOJCLI"))
		FreeObj(oPropSrvc)

		If Empty(oModelNEP:GetValue("NEP_ALTITU")) .And. lEstadoSC
			AGDHELP(STR0007,STR0013, STR0014) // "Ajuda"#" Altitude obrigatória para propriedades de SC."#"Informe o campo Altitude."
			Return .F.
		EndIf

		If ! Empty(cDEmptFlds := gDEmptFlds({"NEP_LATIT", "NEP_LONGI", "NEP_CLIPRO", "NEP_LOJPRO"}, oModelNEP))
			AGDHELP(STR0007, STR0015, STR0016 + cDEmptFlds) //"Ajuda"#"Campo obrigatório não preenchido para ropriedade rural."#"Informe o(s) campo(s) "
			Return .F.
		EndIf
	EndIf

	If oModelNEP:HasField("NEP_ENDNUM")
		If ! Empty(cDEmptFlds := gDEmptFlds({"NEP_END", "NEP_ENDNUM"}, oModelNEP))
			AGDHELP(STR0007, STR0017, STR0018) //"AJUDA", "O padrão utilizado no campo Endereço do cadastro de cliente está incompatível.", "Altere o cadastro do cliente e deixo o endereço no padrão (Logradouro, Número). Exemplo: Av. Brasil, 353"
			Return .F.
		EndIf
	EndIf

	If oModelNEP:HasField("NEP_COOPER")
		if oModelNEP:GetValue("NEP_COOPER") == "1" // Cooperado "1"=Sim
			If oModelNEP:GetValue("NEP_PRORUR") == "1" //Propriedade Rural "1"=Sim
				AGDHELP(STR0007, STR0021, "") //"Ajuda"#"Não é permitido cadastro como Cooperado para cadastros de Propriedade igual a SIM."
				Return .F.
			EndIf

			If Empty(oModelNEP:GetValue("NEP_MATRIC"))
				AGDHELP(STR0007, STR0019, STR0020) //"Ajuda"#"Campo obrigatório não preenchido para cooperado."#"Informe o campo Matrícula do Cooperado. Exemplo: 0000000000000001"
				Return .F.
			EndIf

			If !hasMatriculaCooperado(oModelNEP:GetValue("NEP_MATRIC"), oModelNEP:GetValue("NEP_CODCLI"), oModelNEP:GetValue("NEP_LOJCLI"))
				AGDHELP(STR0007, STR0022, "") //"Ajuda"#"Matrícula já vinculada a outro cooperado."
				Return .F.
			EndIf

			If oModelNEP:HasField("NEP_CODFOR") .AND. (Empty(oModelNEP:GetValue("NEP_CODFOR")) .OR. Empty(oModelNEP:GetValue("NEP_LOJFOR")))
				AGDHELP(STR0007, STR0019, STR0027 + FwX3Titulo("NEP_CODFOR") + " / " + FwX3Titulo("NEP_LOJFOR")) //"Ajuda"#"Campo obrigatório não preenchido para cooperado.""#"Informe o campo "
				Return .F.
			EndIf

		EndIf
	EndIf

	If oModelNEP:HasField("NEP_CODFOR")
		
		If !Empty(oModelNEP:GetValue("NEP_CODFOR")) .AND. Empty(oModelNEP:GetValue("NEP_LOJFOR"))
			AGDHELP(STR0007, STR0028, STR0027 + FwX3Titulo("NEP_LOJFOR")) //"Ajuda"#"Campo obrigatório não preenchido."#"Informe o campo "
			Return .F.
		EndIf

		If !Empty(oModelNEP:GetValue("NEP_CODFOR")) .AND. !Empty(oModelNEP:GetValue("NEP_LOJFOR"))
			//verifica se compartilham do mesmo CPF/CNPJ
			cCGCCliente    := POSICIONE("SA1", 1, xfilial('SA1')+oModelNEP:GetValue("NEP_CODCLI")+oModelNEP:GetValue("NEP_LOJCLI"),"A1_CGC")
			cCGCFornecedor := POSICIONE("SA2", 1, xfilial('SA2')+oModelNEP:GetValue("NEP_CODFOR")+oModelNEP:GetValue("NEP_LOJFOR"),"A2_CGC")
			If cCGCCliente != cCGCFornecedor
				AGDHELP(STR0007, STR0029, STR0030) //"Ajuda"#"Cliente e Fornecedor não compartilham do mesmo CPF/CNPJ."#"Informe um Fornecedor que compartilhe do mesmo CPF/CNPJ do Cliente."
				Return .F.
			EndIf
		ENDIF

	EndIf

Return .T.

/*/{Protheus.doc} InTTS
Validação do Modelo de Dados. Método chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação.
@author beatriz.dantas
@since 01/07/2026
@version p12
@param oModel, object, modelo
@param cModelId, character, modelo id
@return logical, true/false
/*/
Method InTTS(oModel, cModelId) Class AGDP060EVT
	Local oModelNEP  := oModel:GetModel("AGDP060_NEP")
	Local nOperation := oModel:GetOperation()

	If ( nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE ) .and. oModelNEP:GetValue("NEP_PRORUR") <> "1" .and. ;
			oModelNEP:HasField("NEP_COOPER") .And. oModelNEP:HasField("NEP_LOJCLI") .And. ;
			oModelNEP:GetValue("NEP_COOPER") == "1" .and. !Empty(oModelNEP:GetValue("NEP_MATRIC"))
		upMatriculaProp( oModelNEP:GetValue("NEP_CODCLI"), oModelNEP:GetValue("NEP_LOJCLI"), oModelNEP:GetValue("NEP_MATRIC") )
	EndIf

Return .t.

/*/{Protheus.doc} gDEmptFlds
Obtem as descrições dos campos que estão vazios no modelo.
@type function
@version 12
@author jc.maldonado
@since 29/05/2026
@param aFields, array, Lista de campos a serem verificados.
@param oModel, object, Instância do modelo (FWFormFieldsModel)
@return character, Descrição dos campos vazios separados por virgula.
/*/
Static Function gDEmptFlds(aFields, oModel)
	Local nX         := 0
	Local aEmptyFlds := {}
	Local cFieldDesc := ""

	For nX := 1 To Len(aFields)
		If Empty(oModel:GetValue(aFields[nX]))
			AAdd(aEmptyFlds, RTrim(RetTitle(aFields[nX])))
		EndIf
	Next nX

	If ! Empty(aEmptyFlds)
		cFieldDesc := ArrTokStr(aEmptyFlds, ", ")
	EndIf
Return cFieldDesc

/*/{Protheus.doc} hasMatriculaCooperado
	(validation) Verifica se já existe um cooperado cadastrado com a mesma matrícula.
	@type  Static Function
	@author beatriz.dantas
	@since 22/06/2026
	@version p12
	@param cMatric, character, matrícula do cooperado
	@param cCliente, character, código do cliente
	@param cLoja, character, código da loja do cliente
	@return logical, true/false
/*/
Static Function hasMatriculaCooperado(cMatric, cCodCli, cLojaCli)
	Local lRet		 		:= .T.
	Local cQuery	 		:= ""
	Local aArea		 		:= GetArea()
	Local oStatement 		:= nil
	Local nParamPos  		:= 1
	Local nQtdMatCooperado 	:= 0

	cQuery := " SELECT"
	cQuery += "		COUNT(NEP_MATRIC) AS QTDMATCOOPERADO"
	cQuery += " FROM "+RetSqlName("NEP") + " NEP "
	cQuery += " WHERE"
	cQuery += " 	NEP.NEP_FILIAL = ?"
	cQuery += "		AND NEP.NEP_MATRIC = ?"
	cQuery += " AND NOT ( "
	cQuery += "				NEP_CODCLI = ?"
	cQuery += " 			AND NEP_LOJCLI = ?"
	cQuery += "			)"
	cQuery += " 	AND NEP.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:SetString(nParamPos++, FWxFilial('NEP'))
	oStatement:SetString(nParamPos++, AllTrim(cMatric))
	oStatement:SetString(nParamPos++, AllTrim(cCodCli))
	oStatement:SetString(nParamPos++, AllTrim(cLojaCli))
	cQuery := oStatement:GetFixQuery()

	nQtdMatCooperado := MPSysExecScalar(cQuery, 'QTDMATCOOPERADO')

	if nQtdMatCooperado > 0
		lRet := .F.
	endif

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} upMatriculaProp
(method) Atualiza a matrícula do cooperado nas propriedades rurais.
@type  Static Function
@author beatriz.dantas
@since 01/07/2026
@version p12
@param cCodCli, character, código do cliente
@param cLojaCli, character, código da loja do cliente
@param cMatric, character, matrícula do cooperado
@return 
/*/
Static Function upMatriculaProp(cCodCli, cLojaCli, cMatric)
	Local cAliasQry	:= GetNextAlias()
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local oModel 	:= Nil
	Local nParamPos	:= 1

	cQuery := " SELECT
	cQuery += " 	R_E_C_N_O_ as RECNEP"
	cQuery += " FROM " + RetSqlName("NEP") + " NEP "
	cQuery += " WHERE
	cQuery += "		NEP.NEP_FILIAL = ?"
	cQuery += "   	AND NEP.NEP_CLIPRO = ?"
	cQuery += "   	AND NEP.NEP_LOJPRO = ?"
	cQuery += "   	AND NEP.NEP_PRORUR = ?"
	cQuery += "   	AND NEP.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:SetString(nParamPos++, FWxFilial('NEP'))
	oStatement:SetString(nParamPos++, AllTrim(cCodCli))
	oStatement:SetString(nParamPos++, AllTrim(cLojaCli))
	oStatement:SetString(nParamPos++, "1")
	cQuery := oStatement:GetFixQuery()
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

	(cAliasQry)->(DbGoTop())
	While !(cAliasQry)->(Eof())

		NEP->(dbGoTo((cAliasQry)->RECNEP))

		oModel := FWLoadModel("AGDP060")
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()

		oModel:GetModel("AGDP060_NEP"):SetValue("NEP_MATRIC", cMatric)

		If oModel:VldData()
			oModel:CommitData()
		EndIf

		oModel:DeActivate()
		oModel:Destroy()

		(cAliasQry)->(DbSkip())

	EndDo

	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)
Return

/*/{Protheus.doc} AGDP060Delete
(Deleta registros do cadastro de Dados Agronegócio caso nao exista movimentação de cotas vinculado ao cliente/cooperado)
@type Static Function
@author beatriz.dantas  
@since 03/07/2026
@version p12
@param param, param_type, param_descr
@return return, return_type, return_description
/*/
Static Function AGDP060Delete()
	Local lRet      := .t.
	Local oModel    := FWModelActive()
	Local oModelNEP := oModel:GetModel("AGDP060_NEP")
	Local cCodCli   := PAD(oModelNEP:GetValue("NEP_CODCLI"), TAMSX3("A1_COD")[1])
	Local cCodLoja  := PAD(oModelNEP:GetValue("NEP_LOJCLI"), TAMSX3("A1_LOJA")[1])

	lRet := !hasCooperadoMoviment(cCodCli, cCodLoja)

	if !lRet
		AGDHELP(STR0007, STR0025, STR0026) //"Exclusão não permitida."#"Não é permitido excluir o cadastro de Dados Agronegócio quando o cliente possui movimentação de cotas vinculada."
	endif

Return lRet

/*/{Protheus.doc} hasCooperadoMoviment
Verifica se o cliente/cooperado possui pedido de venda ou movimentação de cotas
@type Static Function
@author beatriz.dantas  
@since 03/07/2026
@version p12
@param cCodCli, character, código do cliente
@param cCodLoja, character, código da loja do cliente
@return logical, true/false
/*/
Static Function hasCooperadoMoviment(cCodCli, cCodLoja)
Return !Empty(Posicione("SC5",3,FWxFilial("SC5")+cCodCli+cCodLoja,"C5_NUM")) .Or. (TableInDic('NF4') .And. !Empty(Posicione("NF4",1,FWxFilial("NF4")+cCodCli+cCodLoja,"NF4_IDMOV")))
