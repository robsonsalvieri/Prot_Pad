#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "AGDA150.ch"

#DEFINE NAMESPACEAGD totvs.protheus.agrobusiness.agd

/*/{Protheus.doc} AGDA150EVT
Eventos do modelo MVC da rotina de Atualização de Juros
de Capital Social.
@type class
@version 1.0
@author rodrigo.nsoledade
@since 13/07/2026
/*/
Class AGDA150EVT From FWModelEvent

	private data cJurosAno  as character

	Method New() Public Constructor
	Method VldActivate(oModel, cModelId)
	Method ModelPosVld(oModel, cModelId)
	Method BeforeTTS(oModel)
	Method InTTS(oModel, cModelId)

EndClass

/*/{Protheus.doc} New
Construtor da classe de eventos da rotina AGDA150.
@type method
@version 1.0
@author rodrigo.nsoledade
@since 13/07/2026
@return object, instância da classe
/*/
Method New() Class AGDA150EVT
Return Self

/*/{Protheus.doc} ModelPosVld
Valida os dados obrigatórios antes da confirmação da atualização
de juros de Capital Social.
@type method
@version 1.0
@author rodrigo.nsoledade
@since 13/07/2026
@param oModel, object, modelo principal
@param cModelId, character, identificador do modelo
@return logical, resultado da validação
/*/
Method ModelPosVld(oModel, cModelId) Class AGDA150EVT
	Local lRet      := .T.
	Local oModelNF7 := oModel:GetModel("NF7MASTER")
	Local oRepo     := NAMESPACEAGD.ProcessInterestCapitalRepository():New()
	
	if oModel:GetOperation() <> MODEL_OPERATION_DELETE 
	// Quando gerar demitidos, a data de corte deve ser informada
		If oModelNF7:GetValue("NF7_GERDEM") == "1" .And. Empty(oModelNF7:GetValue("NF7_DTDEMI"))
			AGDHELP(STR0009, STR0007) //"Ajuda"#"Informe a data para geração dos cooperados demitidos."
			lRet := .F.
		EndIf

		//verifica se existe outro para o mesmo ano referencia que não esteja reprovado
		If lRet .and. oRepo:hasProcessoAnoReferencia(oModelNF7:GetValue("NF7_ANOREF"), oModelNF7:GetValue("NF7_CODIGO")) 
			AGDHELP(STR0009, STR0022, STR0023) //"Ajuda" #Existe um processo de juros para o mesmo ano de referência pendente #Verifique a existência de juros para o mesmo ano
			lRet := .F.
		EndIf
	EndIf

	// Ao alterar, retorna o status para Pendente (1)
	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModelNF7:SetValue("NF7_STATUS", "1")
	EndIf
	
	FreeObj(oRepo)

Return lRet

/*/{Protheus.doc} VldActivate
Valida se o registro pode ser ativado para edicao (operacao Alterar).
Permite alteracao somente quando o Status for Pendente de Aprovacao (3)
ou Erro (4). Bloqueia para os demais status.
@type method
@version 1.0
@author felipe.savelar
@since 27/07/2026
@param oModel, object, modelo principal
@param cModelId, character, identificador do modelo
@return logical, .T. para permitir, .F. para bloquear
/*/
Method VldActivate(oModel, cModelId) Class AGDA150EVT
	Local oRepo    := Nil
	Local aAreaNF7 := {}
	Local lRet     := .T.

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		aAreaNF7 := NF7->(FWGetArea())

		oRepo := NAMESPACEAGD.ProcessInterestCapitalRepository():New(xFilial("NF7") + NF7->NF7_CODIGO)
		If !oRepo:isPermitidoAlterar()
			AGDHELP(STR0009, STR0017, STR0018) //"Ajuda"
			lRet := .F.
		EndIf
		FreeObj(oRepo)

		NF7->(FWRestArea(aAreaNF7))
	EndIf

	//verifica se existe titulos gerados para os cooperados no processo de calculo de juros
	If lRet .and. oModel:GetOperation() == MODEL_OPERATION_DELETE
		oRepo := NAMESPACEAGD.ProcessInterestCapitalRepository():New()
		If oRepo:hasFinancialTitles(xFilial("NF7"), NF7->NF7_CODIGO)
			AGDHELP(STR0009, STR0024) //"Ajuda" ##Não é possível excluir este lançamento, pois ele contém títulos financeiros gerados para os cooperados.
			lRet := .F.
		EndIf
		FreeObj(oRepo)
	EndIf

Return lRet

/*/{Protheus.doc} AGDA150EVT::BeforeTTS
Evento  anterior à transação de banco de dados
@type method
@version 1.0
@author scheronlini.martins
@since 17/09/2026
@param oModel, object,modelo
/*/
Method BeforeTTS(oModel) Class AGDA150EVT
	Local oModelNF7 := oModel:GetModel("NF7MASTER")

	::cJurosAno := Posicione("NF7", 1, xFilial("NF7") + oModelNF7:GetValue("NF7_CODIGO"), "NF7_JURANO")

Return

/*/{Protheus.doc} AGDA150EVT::InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém
antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@type method
@version P12
@author claudineia.reinert
@since 24/08/2026
@param oModel, object, Objeto do modelo principal
@param cModelId, character, Id do modelo principal
/*/
Method InTTS(oModel, cModelId) Class AGDA150EVT
	Local aArea      	:= FWGetArea()
	Local nOperation 	:= oModel:GetOperation()
	Local oNF4		 	:= oModel:GetModel("NF4DETAIL")
	Local nX			:= 0
	Local oQuotaRepo	:= nil
	Local oModelNF7 := oModel:GetModel("NF7MASTER")
	Local cOBSHist

	If nOperation == MODEL_OPERATION_DELETE
		// Após commit, verificar os itens excluídos da grid NF4
		For nX := 1 To oNF4:Length()
			oNF4:GoLine( nX )
			oQuotaRepo      := NAMESPACEAGD.QuotaRepository():New()
			oQuotaRepo:updateCooperatorQuotaStatusByMovement(oNF4:GetValue("NF4_CODCOO"), oNF4:GetValue("NF4_LOJCOO"), .F.) //Atualiza cotas
		next nX
		oNF4:GoLine(1)
		FreeObj(oQuotaRepo)
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		//grava historico quando existe alteração de Juros. 
		If oModelNF7:GetValue("NF7_JURANO") <> ::cJurosAno
			cOBSHist := STR0027 +Chr(13)+Chr(10); //"Valor Anterior Juros Ano: "
			+ cValToChar(::cJurosAno) + "%" +Chr(13)+Chr(10);
			+ STR0028 +Chr(13)+Chr(10); //"Valor Atual Juros Ano: "
			+ cValToChar(oModelNF7:GetValue("NF7_JURANO")) + "%" 
			AGDGRAVAHIS("","NF7",xfilial("NF7")+oModel:GetValue("NF7MASTER", "NF7_CODIGO"), STR0029,.F., cOBSHist) //"ALTERACAO"
		EndIf
	elseif oModel:GetOperation() == MODEL_OPERATION_INSERT
		AGDGRAVAHIS("","NF7",xfilial("NF7")+oModel:GetValue("NF7MASTER", "NF7_CODIGO"),STR0030,.F., "") //"INCLUSAO"
	EndIf

	FWRestArea(aArea)

Return nil
