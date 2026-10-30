#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "AGDP060.CH"

#DEFINE NAMESPACEAGD totvs.protheus.agrobusiness.agd

PUBLISH MODEL REST NAME AGDP060

/*/{Protheus.doc} AGDP060
Cadastro de Propriedade Rural
Relaciona a tabela NEP (Propriedade Rural) ao SA1.
@author  rodrigo.nsoledade
@since   16/09/2025
@version 1.0
/*/
Function AGDP060()
	Local oBrowse := Nil

	If (.Not. TableInDic('NEP'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf

	setFunName("AGDP060")
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('NEP')
	oBrowse:SetDescription(STR0001) //"Dados Agronegócio"
	oBrowse:DisableDetails()
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF.AGDP060"

	ADD OPTION aRotina TITLE STR0002 ACTION cAction OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE STR0003 ACTION cAction OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE STR0004 ACTION cAction OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE STR0005 ACTION cAction OPERATION 5 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStruNEP := FWFormStruct(1, 'NEP')
	Local oEvent   := AGDP060EVT():New()

	// Criação do modelo com validações (se especificadas)
	oModel := MPFormModel():New('AGDP060')

	// Adição dos componentes ao modelo
	oModel:AddFields('AGDP060_NEP', /*cOwner*/, oStruNEP)

	oModel:SetDescription(STR0001) // Descrições dos componentes
	oModel:GetModel('AGDP060_NEP'):SetDescription(STR0006) //"Cadastro Agronegócio"
	oModel:SetPrimaryKey({"NEP_FILIAL", "NEP_CODCLI", "NEP_LOJCLI"})

	oModel:InstallEvent("AGDP060EVT", /*cOwner*/, oEvent)

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel('AGDP060')
	Local oStruNEP := FWFormStruct(2, 'NEP')
	Local oView := FWFormView():New()

	oView:SetModel(oModel)
	oStruNEP:RemoveField("NEP_FILIAL")
	// Adição dos componentes da interface
	oView:AddField('VIEW_NEP', oStruNEP, 'AGDP060_NEP')

	// Criação da estrutura de layout
	oView:CreateHorizontalBox('TELA', 100)
	oView:SetOwnerView('VIEW_NEP', 'TELA')

	oView:AddUserButton(STR0012,"",{|| AGDP070CRM(SA1->A1_COD,SA1->A1_LOJA)},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT ,MODEL_OPERATION_UPDATE} ) //"Grupo Familiar"

	// Habilitação de títulos
	oView:EnableTitleView('VIEW_NEP')

Return oView

/*/{Protheus.doc} IntegDef
IntegDef
@type function
@version 12
@author jc.maldonado
@since 20/10/2025
@param xEnt, variant, xml/obj para envio/recebimento
@param cTypeTrans, character, "0"=TRANS_SEND, "1"=TRANS_RECEIVE
@param cTypeMessage, character, Tipo Mensagem '20'=DEFINE EAI_MESSAGE_BUSINESS, '21'=DEFINE EAI_MESSAGE_RESPONSE, '22'=DEFINE EAI_MESSAGE_RECEIPT, '23'=DEFINE EAI_MESSAGE_WHOIS
@param cVersion, character, Versão
@param cTransaction, character, Nome mensagem unica
@param lEAIObj, logical, EAI Object
@return array, {lResult, xValue(oFWEAIobj ou cMsgErr)}
/*/
Static Function IntegDef(xEnt, cTypeTrans, cTypeMessage, cVersion, cTransaction, lEAIObj)
	Default lEAIObj := .F.
Return AGDIP060(xEnt, cTypeTrans, cTypeMessage, cVersion, cTransaction, lEAIObj)

/*/{Protheus.doc} AGDP060
Tela chamada no cadastro de Cliente para alterar os Dados Agronegócio
@type function
@version 12
@author rodrigo.nsoledade
@since 17/09/2025
@return variant, nil
/*/
Function AGDP060CRM(cCodCli,cCodLoja,nOperation)
	Local aArea     := GetArea()
	Local aAreaSA1  := SA1->(GetArea())
	Local oModel    := nil
	Local oModelNEP := nil

	Default nOperation := 1

	If .Not. TableInDic('NEP')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oModel := FwLoadModel('AGDP060')

	DbSelectArea("NEP")
	DbSetOrder(1)
	If NEP->(DBSeek(FWxFilial("NEP")+cCodCli+cCodLoja))
		if nOperation == MODEL_OPERATION_DELETE
			FWExecView(oModel:GetDescription(), "AGDP060", MODEL_OPERATION_DELETE)
		Else //update
			FWExecView(oModel:GetDescription(), "AGDP060", MODEL_OPERATION_UPDATE, , , ,)
		Endif
	Else
		oModelNEP := oModel:GetModel("AGDP060_NEP")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		//desabilita edição dos campos de cliente e loja
		oModelNEP:GetStruct():SetProperty('NEP_CODCLI', MODEL_FIELD_WHEN, {|| .F.})
		oModelNEP:GetStruct():SetProperty('NEP_LOJCLI', MODEL_FIELD_WHEN, {|| .F.})
		If oModel:Activate()
			oModelNEP:LoadValue('NEP_CODCLI', cCodCli)
			oModelNEP:LoadValue('NEP_LOJCLI', cCodLoja)
			oModelNEP:LoadValue('NEP_NOMCLI', Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_NOME"))
			oModelNEP:LoadValue('NEP_END'   , trataEnd(SA1->A1_END, "L"))
            If oModelNEP:HasField("NEP_ENDNUM")
            	oModelNEP:LoadValue('NEP_ENDNUM', trataEnd(SA1->A1_END, "N"))
            EndIf

			FWExecView(oModel:GetDescription(), "AGDP060", MODEL_OPERATION_INSERT, , , ,0, , , , , oModel)
		Endif
	Endif

	RestArea(aArea)
	RestArea(aAreaSA1)

Return .T.

/*/{Protheus.doc} ValidaGeoLoc
Função para validar coordenadas de Latitude/Longitude 
em graus decimais (ex.: -12.1234).
@author rodrigo.nsoledade
@since 23/09/2025
@return .T. se válido, .F. caso contrário
/*/
Function AgdValGeoLoc()
	Local lRet         := .T.
	Local cReadVar     := ReadVar()
	Local oPropService := NAMESPACEAGD.PropertyRuralService():New()

	If "NEP_LATIT" $ cReadVar
		If !oPropService:validaGeoLocal(M->NEP_LATIT, "LAT")
			AGDHELP(STR0007, STR0008, STR0009) //"Ajuda"#"Latitude inválida."#"Informe um valor entre -90.0000 e 90.0000 graus."
			Return .F.
		EndIf
	ElseIf "NEP_LONGI" $ cReadVar
		If !oPropService:validaGeoLocal(M->NEP_LONGI, "LON")
			AGDHELP(STR0007, STR0010, STR0011) //"Ajuda"#"Longitude inválida."#"Informe um valor entre -180.0000 e 180.0000 graus."
			Return .F.
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} AGDP060REL
Carrega o init Padrao (X3_RELACAO)
@author carlos.augusto
@since 10/10/2025
@return cRetorno, posicione de acordo com a tela aberta
/*/
Function AGDP060REL()
	Local cRetorno := ""

	//Acesso via CRMA980 (cadastro de clientes). Tabela SA1 sempre posicionada
	If FWIsInCallStack("AGDP060CRM")
		cRetorno := POSICIONE("NEX",2,XFILIAL("NEX")+SA1->A1_COD+SA1->A1_LOJA,"NEX_CODGRP")
	Else
		cRetorno := IIF(!INCLUI,POSICIONE("NEX",2,XFILIAL("NEX")+NEP->NEP_CODCLI+NEP->NEP_LOJCLI,"NEX_CODGRP"),"")
	EndIf
Return cRetorno

/*/{Protheus.doc} AGDP060WCoop
Valida permissão de edição dos campos Cooperado e Matrícula.
A alteração só é permitida quando não houver pedido de venda ou movimentação
de cotas vinculada ao cliente/cooperado.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 29/06/2026
@return logical, indica se a alteração é permitida
/*/
Function AGDP060WCoop()
	Local lRet        := .T.
	Local oModel      := FWModelActive()
	Local oModelNEP   := oModel:GetModel("AGDP060_NEP")
	Local cCli        := ""
	Local cLoja       := ""
	Local cCooper     := ""
	Local cMatric     := ""
	Local cOldCooper  := ""
	Local cOldMatric  := ""
	Local lAltCoopNao := .F.

	// Valores atuais em tela
	cCli    := PAD(oModelNEP:GetValue("NEP_CODCLI"),TAMSX3("A1_COD")[1])
	cLoja   := PAD(oModelNEP:GetValue("NEP_LOJCLI"),TAMSX3("A1_LOJA")[1])
	cCooper := PAD(oModelNEP:GetValue("NEP_COOPER"),TAMSX3("NEP_COOPER")[1])
	cMatric := PAD(oModelNEP:GetValue("NEP_MATRIC"),TAMSX3("NEP_MATRIC")[1])

	// Valores gravados no banco
	cOldCooper := NEP->NEP_COOPER
	cOldMatric := NEP->NEP_MATRIC
	lAltCoopNao := (cOldCooper == "1" .And. cCooper == "2")

	// Só valida quando era cooperado e houve alteração de matrícula ou mudança para Não
	If cOldCooper == "1" .Or. lAltCoopNao

		//Verifica se o cliente/cooperado possui pedido de venda ou movimentação de cotas
		If !Empty(Posicione("SC5",3,FWxFilial("SC5")+cCli+cLoja,"C5_NUM")) .Or. !Empty(Posicione("NF4",1,FWxFilial("NF4")+cCli+cLoja,"NF4_IDMOV"))
			lRet := .F.
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} AGDP060VCoop
Valida alteração dos campos Cooperado e Matrícula no cadastro de Dados Agronegócio.
A alteração só é permitida quando não houver pedido de venda ou movimentação
de cotas vinculada ao cliente/cooperado.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 29/06/2026
@return logical, indica se a alteração é permitida
/*/
Function AGDP060VCoop()
	Local lRet        := .T.
	Local oModel      := FWModelActive()
	Local oModelNEP   := oModel:GetModel("AGDP060_NEP")
	Local cCli        := ""
	Local cLoja       := ""
	Local cCooper     := ""
	Local cMatric     := ""
	Local cOldCooper  := ""
	Local cOldMatric  := ""
	Local lAltMatric  := .F.
	Local lAltCoopNao := .F.
	Local oRepoCliEx  := Nil

	// Valores atuais em tela
	cCli    := PAD(oModelNEP:GetValue("NEP_CODCLI"),TAMSX3("A1_COD")[1])
	cLoja   := PAD(oModelNEP:GetValue("NEP_LOJCLI"),TAMSX3("A1_LOJA")[1])
	cCooper := PAD(oModelNEP:GetValue("NEP_COOPER"),TAMSX3("NEP_COOPER")[1])
	cMatric := PAD(oModelNEP:GetValue("NEP_MATRIC"),TAMSX3("NEP_MATRIC")[1])

	// Valores gravados no banco
	cOldCooper := NEP->NEP_COOPER
	cOldMatric := NEP->NEP_MATRIC

	lAltMatric  := (cOldMatric <> cMatric)
	lAltCoopNao := (cOldCooper == "1" .And. cCooper == "2")

	// Bloqueia alteração se existir pedido de venda ou movimentação de cotas
	If (cOldCooper == "1" .And. lAltMatric) .Or. lAltCoopNao

		//Verifica se o cliente/cooperado possui pedido de venda ou movimentação de cotas
		If !Empty(Posicione("SC5",3,FWxFilial("SC5")+cCli+cLoja,"C5_NUM")) .Or. !Empty(Posicione("NF4",1,FWxFilial("NF4")+cCli+cLoja,"NF4_IDMOV"))
			AGDHELP(STR0007, ;
				STR0023, ; //"Alteração não permitida."
			STR0024) //"Não é permitido alterar a matrícula ou o cooperado quando o cliente possui pedido de venda ou movimentação de cotas vinculada."

			lRet := .F.
		EndIf

		// Se mudou Cooperado para Não e não há movimentação, limpa a matrícula em tela
		If lRet .And. lAltCoopNao
			oModelNEP:LoadValue("NEP_MATRIC", "")
		EndIf

	EndIf

	If lRet .And. "NEP_COOPER" $ ReadVar()
		If cCooper == "1" //1=Sim
			If Empty(cOldMatric)
				oRepoCliEx := NAMESPACEAGD.ClientExtensionRepository():New()
				oModelNEP:SetValue("NEP_MATRIC", oRepoCliEx:getNextCoopMatricula())
				FwFreeObj(oRepoCliEx)
			Else
				oModelNEP:SetValue("NEP_MATRIC", cOldMatric)
			endIf
		Else
			oModelNEP:LoadValue("NEP_MATRIC", "")
		EndIf
	EndIf
Return lRet
