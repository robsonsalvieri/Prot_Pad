#INCLUDE "AGDI043.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#DEFINE SOLICITACAO_RECEITA_SERVICE agd.solicitacaoReceitaService.agdSolicitacaoReceitaService
#DEFINE BLOQUEIOFATURAMENTO_SERVICE agd.bloqueioFaturamentoService.agdBloqueioFaturamentoService


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
		aAdd(aReceituario, {OemToAnsi(STR0002),"AGDI043M({SC5->C5_FILIAL, SC5->C5_NUM, 3 })" ,0, 0, 0 ,NIL} ) //#"Solicitar Receita"
		aAdd(aReceituario, {OemToAnsi(STR0003),"AGDI043M({SC5->C5_FILIAL, SC5->C5_NUM, 2 })" ,0, 2, 0 ,NIL} ) //#"Visualizar Receita"
        aAdd(aRotina, {OemToAnsi(STR0001), aReceituario ,0, 0, 0 ,NIL} ) //#"Receituário Agronômico"
    Endif

Return aRotina


/*/{Protheus.doc} AGDI043
Remove o vinculo do pedido com a instrucao de embarque
Rotina Utilizada no MATA410
@type function
@version 12
@author lindembergson.pacheco
@since 27/02/2025
@param cCodPedVen, character, codigo do pedido de venda (SC5->C5_NUM)
/*/
Function AGDI043()
	Local aArea
	
	If SUPERGETMV("MV_SIGAAGD", .F., .F.) .and. FWAliasInDic("NET") 
		aArea := FWgetArea()
		fGerarRec(SC5->C5_NUM)
		FwRestArea(aArea)
	EndIf
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
Static Function fGerarRec(cPedido)
	Local oService
	Local oBloqFatService

	oService := SOLICITACAO_RECEITA_SERVICE():New()
	oService:gerarSolicitacaoReceita(cPedido)

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
		fGerarRec(aInfo[2])
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
