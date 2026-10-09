#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDI043.CH"

#DEFINE SOLICITACAO_RECEITA_SERVICE    totvs.protheus.agrobusiness.agd.RequestRecipeService
#DEFINE SOLICITACAO_RECEITA_REPOSITORY totvs.protheus.agrobusiness.agd.RequestRecipeRepository
#DEFINE BLOQUEIOFATURAMENTO_SERVICE    totvs.protheus.agrobusiness.agd.SalesLockService
#DEFINE EXTENSAO_PEDIDO_SERVICE        totvs.protheus.agrobusiness.agd.SalesOrderExtensionService
#DEFINE EXTENSAO_PEDIDO_REPOSITORY     totvs.protheus.agrobusiness.agd.SalesOrderExtensionRepository
#DEFINE ENGENHEIROS_REPOSITORIO        totvs.protheus.agrobusiness.agd.EngineersRepository
#DEFINE LOCAL_DESCARTE_REPOSITORIO     totvs.protheus.agrobusiness.agd.DisposalOfPackagesRepository

/** {Protheus.doc} AGDI043SM
Rotina chamada através da Liberacao de Pedido - MATA440
@type function
@version 12
@author agroDistribuidor
@since 09/09/2025
@return variant, nil
**/
Function AGDI043SM(paRotina)
	Local aRotina := paRotina
	Local aReceituario := {}


    If SUPERGETMV("MV_SIGAAGD", .F., .F.) .and. FWAliasInDic("NET") 
		aAdd(aReceituario, {OemToAnsi(STR0002),"AGDI043M({SC5->C5_FILIAL, SC5->C5_NUM, 3, ''})" ,0, 0, 0 ,NIL} ) //#"Solicitar Receita"
		aAdd(aReceituario, {OemToAnsi(STR0003),"AGDI043M({SC5->C5_FILIAL, SC5->C5_NUM, 2, ''})" ,0, 2, 0 ,NIL} ) //#"Visualizar Receita"
		aAdd(aReceituario, {OemToAnsi(STR0008),"AGDA040HT(SC5->C5_FILIAL,  SC5->C5_NUM)" ,0, 8, 0 ,NIL} ) //#"Historico de Solicitações"
        aAdd(aRotina, {OemToAnsi(STR0001), aReceituario ,0, 8, 0 ,NIL} ) //#"Receituário Agronômico"
    Endif

Return aRotina


/*/{Protheus.doc} AGDI043
Gera solicitações de Receita.
Caso a chamada venha de uma alteração de pedido, é removida as solicitações pendentes do pedido.
Rotina Utilizada nos seguintes pontos:
-Durante a gravação de um pedido de Vendas. A410Grava()
-Final da gravação da Liberaçãoo do Pedido. A440Grava() 
@type function
@version 12
@author lindembergson.pacheco
@since 27/02/2025
/*/
Function AGDI043()
	Local aArea    := {}
	Local oService := Nil
	
	If ! SUPERGETMV("MV_SIGAAGD", .F., .F.) .Or. ! FWAliasInDic("NET") 
		Return
	EndIf
	
	aArea := FWgetArea()

	If FWIsInCallStack('A410GRAVA') 
		If INCLUI .Or. ALTERA
			//Insere informações adicionais do pedido de venda para o Agrodistribuidor (Tabela NEQ)
			chkAddNEQ()
		EndIf

		If FWIsInCallStack('A410ALTERA')
			oService := SOLICITACAO_RECEITA_SERVICE():New()
			oService:removeSolicitacoesPendentesPedido(SC5->C5_NUM)
			If ! oService:isSuccess() .and. ! IsBlind()
				AGDHELP(STR0004, STR0007 + oService:getMessageError()) //#"AJUDA", "#Não foi possível remover a solicitação pendente. "
			EndIf
			FwFreeObj(oService)
		EndIf
	EndIF

	fGerarRec(SC5->C5_NUM, "")
	FwRestArea(aArea)
Return

/*/{Protheus.doc} AGDI043M
Remove o vinculo do pedido com a instrucao de embarque
Rotina Utilizada no MATA410
@type function
@version 12
@author lindembergson.pacheco
@since 27/02/2025
@param cCodPedVen, character, codigo do pedido de venda (SC5->C5_NUM)
/*/
Function AGDI043M(aInfo)
	Local aArea
	
	If SUPERGETMV("MV_SIGAAGD", .F., .F.) .and. FWAliasInDic("NET") 
		aArea := FWgetArea()
		if len(aInfo) > 0 
			fMenuRec(aInfo)
		endif
		FwRestArea(aArea)
	EndIf
Return

/*/{Protheus.doc} fGerarRec
Gera as solicitações de receita e valida bloqueio de faturamento
@type function
@version  P12
@author lindembergson.pacheco
@since 22/10/2025
@param cPedido, character, Numero do pedido de venda
/*/
Static Function fGerarRec(cPedido, cStatusSol)
	Local oService
	Local oBloqFatService

	oService := SOLICITACAO_RECEITA_SERVICE():New()
	oService:gerarSolicitacaoReceita(cPedido, cStatusSol)

	oBloqFatService := BLOQUEIOFATURAMENTO_SERVICE():New()
	oBloqFatService:validaPedidoBloqueioReceita(cPedido)

	FreeObj(oBloqFatService)
	FreeObj(oService)

return


/*/{Protheus.doc} fMenuRec
Função de relacionamento de Pedido X agroDistribuidor
@type function
@version 12
@author agroDistribuidor
@since 09/09/2025
@return variant, nil
/*/
Static Function fMenuRec(aInfo)
    Local cOperation := ""
	Local oModel    := NIL 
	Local cModel	:= "AGDA040X"

	If !FWAliasInDic("NET")
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		return .T.
	Endif

	If aInfo[3] == 3
		fGerarRec(aInfo[2], aInfo[4])
	Else
		//Verificar se pedido esta aberto
		dbSelectArea('NET')
		NET->(dbSetOrder(2)) //Filial + NUM
		If !NET->(dbSeek(aInfo[1] + aInfo[2])) 
			AGDHELP(STR0004, STR0005) //#"AJUDA" #"Não existe solicitação de receita para o pedido."
			return .T.
		endif
		
		cOperation := MODEL_OPERATION_VIEW
		oModel    := FwLoadModel(cModel)
		oModel:SetOperation(cOperation)
		oModel:Activate()
		FWExecView(STR0006, cModel, cOperation, , , ,0, , , , , oModel) //#"VISUALIZAR"
		oModel:DeActivate()
		oModel:Destroy()
		oModel := NIL
		FreeObj(oModel)

	Endif

Return .T.

/*/{Protheus.doc} chkAddNEQ
Insere informações adicionais do pedido de venda para o Agrodistribuidor
se todas as regras forem verdadeiras:
-Não existe relacionamento do pedido com o Agrodistribuidor (Tabela NEQ)
-Existe Local de Descarte
-Pedido possui necessidade de receita agronômica
@type function
@version 12
@author jc.maldonado
@since 13/05/2026
/*/
Static Function chkAddNEQ()
	Local oRepoOrdEx := Nil
	Local cFilNEQ    := ""
	Local oSrvOrdExt := Nil
	Local cLocDescar := ""
	Local nX         := 0
	Local oRepoSolRe := Nil
	Local nPosProdut := 0
	Local oJsonData  := Nil

	DBSelectArea("NEQ")
	If NEQ->(FieldPos("NEQ_INTEXT")) = 0
		Return
	endIf

	oRepoOrdEx := EXTENSAO_PEDIDO_REPOSITORY():New()
	cFilNEQ    := FWxFilial("NEQ")
	If oRepoOrdEx:existsById(cFilNEQ + M->C5_NUM) .Or. Empty(cLocDescar := LOCAL_DESCARTE_REPOSITORIO():getDefaultDisposalCode())
		FwFreeObj(oRepoOrdEx)
		Return
	EndIf

	FwFreeObj(oRepoOrdEx)
	
	oRepoSolRe := SOLICITACAO_RECEITA_REPOSITORY():New()
	nPosProdut := aScan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})

	For nX := 1 To Len(aCols)
		If oRepoSolRe:IsGeraReceita(aCols[nX, nPosProdut])
			oJsonData := JSONObject():New()
			oJsonData['filial']              := cFilNEQ
			oJsonData['numeroPedido']        := M->C5_NUM
			oJsonData['filialEngenheiro']    := cFilNEQ
			oJsonData['codigoEngenheiro']    := ENGENHEIROS_REPOSITORIO():getEngineerIfOnlyOne()
			oJsonData['filialLocalDescarte'] := cFilNEQ
			oJsonData['codigoLocalDescarte'] := cLocDescar

			oSrvOrdExt := EXTENSAO_PEDIDO_SERVICE():New()
			oSrvOrdExt:registrar(oJsonData)
			If ! oSrvOrdExt:isSuccess()
				AGDHELP(STR0004, oSrvOrdExt:getMessageError()) //#"AJUDA"
			EndIf

			FwFreeObj(oSrvOrdExt)
			Exit
		Endif
	Next nX

	FwFreeObj(oRepoSolRe)
Return
