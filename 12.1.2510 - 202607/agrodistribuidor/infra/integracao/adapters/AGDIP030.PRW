#Include "AGDIP030.ch"
#Include "TOTVS.ch"
#Include "fwAdapterEAI.ch"
#Include "FWMVCDEF.CH"

#DEFINE MODEL_NAME                    "AGDA030"
#DEFINE TABLE_NAME                    "NEF"
#DEFINE TCODEPARA_SERVICE             totvs.protheus.agrobusiness.agd.TCOFromtoService
#DEFINE TCO_TACDTO                    totvs.protheus.agrobusiness.agd.TCOComercializacaoTACDTO
#DEFINE CONTRATO_ACL_SERVICE          totvs.protheus.agrobusiness.agd.ContractACLService
#DEFINE CONTRATO_ACL_VINCULAR_SERVICE totvs.protheus.agrobusiness.agd.ContractACLBindService
#DEFINE CONTRATO_ORIGINATION_SERVICE  totvs.protheus.agrobusiness.agd.ContractOriginationProtheusService

/*/{Protheus.doc} AGDIP030
Rotina para Interpretação/Geração Mensagem do Adapter EAI - Contrato Barter (JSON)
@type function
@version 12
@author beatriz.dantas
@since 19/03/2026
@param xEnt, variant, Objeto Recebido
@param nTypeTrans, numeric, Recebimento/Envio
@param cTypeMessage, character, Tipo Mensagem
@param cVersion, character, Versão
@param cTransac, character, Tipo Transação
@param lEAIObj, logical, Formato JSON
@return variant, retorno array Padrão
/*/
Function AGDIP030(xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj)
    Local aReturn := {.F., Nil}
    Local aAux    := {.T., ""}

    If lEAIObj
        If nTypeTrans == TRANS_SEND
            aAux    := genEAIobj()
            aReturn := {aAux[1], aAux[2], MODEL_NAME}
        Else
            aReturn := {.F., STR0001, MODEL_NAME} //"Recebimento não implementado"
        EndIf
    Else
        aReturn := {.F., STR0002, MODEL_NAME} //"Somente JSON suportado"
    EndIf

Return aReturn

/*/{Protheus.doc} genEAIobj
Envio da Mensagem EAI em JSON — Contrato Barter
Campos obrigatórios conforme critério de aceite:
  Filial, Moeda, Produto, Modalidade, Quantidade,
  Tipo Frete (Incoterm), Preço, Cotação
Campos opcionais: Safra
Campos não disponíveis na NEA/NEF (pendentes de especificação):
  Fornecedor, Armazém, Porto, Data Entrega Ini/Fim,
  Classe Produto, Análise Qualidade, Condição Logística
@type function
@version 12
@author beatriz.dantas
@since 19/03/2026
@return variant, retorno array {lOk, oFWEAIobj}
/*/
Static Function genEAIobj()
    Local oModel      := FWModelActive()
    Local oFWEAIobj   := Nil
    Local oModelNEF   := Nil
    Local aReturn     := {.F., Nil}
    Local aAreaNEA    := NEA->(FwGetArea())
    Local aAreaNEE    := NEE->(FwGetArea())
    Local cEvent      := ""
    Local cInternaId  := ""
    Local cCodNeg     := ""
    Local cCodVersao  := ""
    // Campos via NEA
    Local nMoedaInt   := ""
    Local cProduto    := ""
    Local cTpFrete    := ""
    Local cSafra      := ""
    Local cUMPreco    := ""
    Local cArmazem    := ""
    Local nPreco      := 0
    Local dDtInicio   
    Local dDtFim      
    Local cExtIdForn  := ""
    Local cCdFornec   := ""
    Local cLjFornec   := ""
    Local cIntIdForn  := ""
    Local cIntProd    := ""
    Local cIdExtProd  := ""
    Local cIntArmaz   := ""
    Local cIdExtArm   := ""
    Local cIntSafra   := ""
    Local cIdExtSaf   := ""
    Local cDataInicio := ""
    Local cDataFim    := ""
    Local nQuantidade := 0

    Local oTCO_DTO       := TCO_TACDTO():New()
    Local cCodeInteg     := oTCO_DTO:getIdentificaoIntegracao()
    Local oTCODEPARAServ := TCODEPARA_SERVICE():New()
    Local oCtrProtheus   := CONTRATO_ORIGINATION_SERVICE():New()

    // Retorna se deve gerar o contrato para o OG Protheus, caso sim, não envia mensagem para o EAI
    If oCtrProtheus:isGerenciaContratoOG()
        Return aReturn
    EndIf

    If oModel == Nil                    ;
            .Or. ValType(oModel) != "O" ;
            .Or. !oModel:IsActive()     ;
            .Or. oModel:GetId() != MODEL_NAME
        aReturn[2] := STR0003 // "Modelo inválido."
        Return aReturn
    EndIf

    Do Case
        Case oModel:nOperation == MODEL_OPERATION_INSERT ; cEvent := "upsert"
        Case oModel:nOperation == MODEL_OPERATION_UPDATE ; cEvent := "upsert"
        Case oModel:nOperation == MODEL_OPERATION_DELETE ; cEvent := "delete"
    EndCase

    oModelNEF 	:= oModel:GetModel("AGDA030_NEF")

    //Obtem os dados do contrato/negociacao

    cCodNeg   	:= Alltrim(NEA->NEA_CODIGO)
    cCodVersao  := Alltrim(NEA->NEA_VERSAO)
    cInternaId  := getIDInt(cCodNeg, Alltrim(oModelNEF:GetValue("NEF_ITECTR")), Alltrim(oModelNEF:GetValue("NEF_ITEM")) )
    nMoedaInt 	:= NEA->NEA_MOEDRT 
    nTaxa       := NEA->NEA_TXMOED
    cProduto    := Alltrim(NEA->NEA_CODPRO) 
    nPreco 		:= NEA->NEA_VLRRT 
    cUMPreco 	:= Alltrim(NEA->NEA_UMPRC)
    cSafra 		:= Alltrim(NEA->NEA_CODSAF)
    nQuantidade := AgdCvQt030(oModelNEF:GetValue("NEF_QUANT"), cUMPreco, NEA->NEA_CODPRO) 

    NEE->(DbSetOrder(1))
    If NEE->(DbSeek(FWxFilial("NEE") + cCodNeg + cCodVersao + oModelNEF:GetValue("NEF_ITECTR")))
        cArmazem 	:= NEE->NEE_LOCAL
        dDtInicio   := NEE->NEE_INIENT
        dDtFim      := NEE->NEE_FIMENT
        cTpFrete 	:= NEE->NEE_TPFRET 
        cCdFornec   := NEE->NEE_CDPROP
        cLjFornec   := NEE->NEE_LJPROP
    EndIf

    //Busca DE/PARA
    cIntIdForn := oTCODEPARAServ:formatInternalIDfornecedor(cEmpAnt, FWxFilial("SA2"), cCdFornec, cLjFornec)
    cExtIdForn := RTRIM(oTCODEPARAServ:getExternalID(cCodeInteg, "SA2", "A2_COD", cIntIdForn))

    if Empty(cExtIdForn)
        cExtIdForn := RTRIM(oTCODEPARAServ:getExternalID(cCodeInteg, "SA1", "A1_COD", cIntIdForn))
    endIf

    cIntProd   := oTCODEPARAServ:formatInternalIdProduto(nil, nil, NEA->NEA_CODPRO)
    cIdExtProd := RTRIM(oTCODEPARAServ:getExternalID(cCodeInteg, "SB1", "B1_COD", cIntProd))

    cIntArmaz   := oTCODEPARAServ:formatInternalIdLocalDeEstoque(cArmazem)
    cIdExtArm := RTRIM(oTCODEPARAServ:getExternalID(cCodeInteg, "NNR", "NNR_CODIGO", cIntArmaz))

    cIntSafra   := oTCODEPARAServ:formatInternalIdSafra(cSafra)
    cIdExtSaf := RTRIM(oTCODEPARAServ:getExternalID(cCodeInteg, "NJU", "NJU_CODSAF", cIntSafra))

    //Fim da Busca DE/PARA

    oFWEAIobj := FWEAIobj():New()
    oFWEAIobj:Activate()
    oFWEAIobj:setEvent(cEvent)

    oFWEAIobj:setProp("Entity"            , MODEL_NAME)
    oFWEAIobj:setProp("Event"             , cEvent)
    oFWEAIobj:setProp("InternalId"        , cInternaId)
    oFWEAIobj:setProp("CompanyId"         , cEmpAnt)
    oFWEAIobj:setProp("BranchId"          , cFilAnt)
    oFWEAIobj:setProp("CompanyInternalId" , cEmpAnt + '|' + cFilAnt)
    oFWEAIobj:setProp("CompanyExternalId" , GetEmpExtId(cEmpAnt, cFilAnt, cCodeInteg))
    oFWEAIobj:setProp("Currency"          , nMoedaInt)
    oFWEAIobj:setProp("ISOCurrencyCode"   , getSimbol(cValToChar(nMoedaInt)))
    oFWEAIobj:setProp("UnitPrice"         , nPreco)
    oFWEAIobj:setProp("LinkedContract"    , oModelNEF:GetValue("NEF_VINCTR"))
    oFWEAIobj:setProp("Harvest"           , cIdExtSaf)
    oFWEAIobj:setProp("Agribusiness"      , Alltrim(oModelNEF:GetValue("NEF_CODBRT")))
    oFWEAIobj:setProp("ItemContract"      , Alltrim(oModelNEF:GetValue("NEF_ITECTR")))
    oFWEAIobj:setProp("ItemSequence"      , Alltrim(oModelNEF:GetValue("NEF_ITEM")))
    oFWEAIobj:setProp("ProductId"         , cIdExtProd)
    oFWEAIobj:setProp("Quantity"          , nQuantidade)
    oFWEAIobj:setProp("Unit"              , cUMPreco)
    oFWEAIobj:setProp("Incoterm"          , cTpFrete)
    oFWEAIobj:setProp("Port"              , "NAO_APLICA")
    oFWEAIobj:setProp("IssueDate"         , FWDateTo8601(Date()))
    oFWEAIobj:setProp("Warehouse"         , cIdExtArm)
    oFWEAIobj:setProp("Vendor"            , cExtIdForn)

    If getSimbol(cValToChar(nMoedaInt)) = "BRL"
        oFWEAIobj:setProp("ExchangeRate"  , getValTaxa())
    else
        oFWEAIobj:setProp("ExchangeRate"  , nTaxa)
    endIf

    If !Empty(dDtInicio) .Or. !Empty(dDtFim)
        cDataInicio := FWDateTo8601(dDtInicio)
        cDataFim    := FWDateTo8601(dDtFim)
    EndIf

    oFWEAIobj:setProp("Period")
    oFWEAIobj:getPropValue("Period"):setProp("dateStart", cDataInicio)
    oFWEAIobj:getPropValue("Period"):setProp("dateEnd",   cDataFim)

    aReturn[1] := .T.
    aReturn[2] := oFWEAIobj
    
    FwRestarea(aAreaNEA)
    FwRestarea(aAreaNEE)

	FreeObj(oTCODEPARAServ)
    FreeObj(oTCO_DTO)

Return aReturn

/*/{Protheus.doc} getIDInt
Obtém o id de integração a partir do Cod. Negócio e do item
@type function
@version 12
@author beatriz.dantas
@since 10/03/2026
@param cCodNeg, character, código negócio (NEF_CODBRT)
@param cItemNeg, character, item contrato (NEF_ITECTR)
@param cSeqItem, character, sequência item (NEF_ITEM)
@return character, "cEmpresa|cFilial|cCodNeg|cItemNeg|cSeqItem"
/*/
Static Function getIDInt(cCodNeg, cItemNeg, cSeqItem)
Return cEmpAnt + '|' + FWxFilial(TABLE_NAME) + '|' + cCodNeg + '|' + cItemNeg + '|' + cSeqItem


/*/{Protheus.doc} getSimbol
Retorn moeda em ISO-4217
@type function
@version 12
@author carlos.augusto
@since 16/04/2026
/*/
Static Function getSimbol(cMoeda)
    Local cSimbolo := Alltrim(SuperGetMv("MV_SIMB"+cMoeda,.F.,"R$"))
    Local cISO     := ""

    Do Case
        Case cSimbolo == "R$"
            cISO := "BRL" // Real Brasileiro

        Case cSimbolo == "$"
            cISO := "USD" // Dólar Americano

        Case cSimbolo == "US$"
            cISO := "USD"

        Otherwise
            cISO := cSimbolo 
    EndCase

Return cISO
 

/*/{Protheus.doc} GetEmpExtId
Busca o codigo da empresa externa a partir do código da empresa interna
@type function
@version 12
@author carlos.augusto
@since 16/04/2026
@param cCompanyID, character, grupo de empresa no Protheus 
@param cBranchId, character, Filial no Protheus
@param cCodeInteg, character, Referencia de/para com empresa externa
@return character, empresa/filial externa ou vazio se não encontrar
/*/
Static Function GetEmpExtId(cCompanyID, cBranchId, cCodeInteg)
    Local aEmpFilExt := FwEAIEmpFil(cCompanyID, cBranchId, cCodeInteg, .T.) 

    If !Empty(aEmpFilExt)
        Return aEmpFilExt[2]
    EndIf
Return ""


/*/{Protheus.doc} getValTaxa
Retorna taxa do dolar
@type function
@version 12
@author carlos.augusto
@since 16/04/2026
/*/
Static Function getValTaxa()
    Local cSimbolo := ""
	Local nX	   := 0
    Local nMoeda   := 0

	For nX := 1 To MoedFin()
        cSimbolo := getSymbMv(cValToChar(nX))
        If cSimbolo $ "$|US$"
            nMoeda := nX
            Exit
		EndIf
	Next
    nValorMoeda := RecMoeda(Date(),cValToChar(nMoeda))
Return nValorMoeda


/*/{Protheus.doc} getSymbMv
Retorna simbolo da moeda a partir do código da moeda
@type function
@version 12
@author carlos.augusto
@since 16/04/2026
/*/
Static Function getSymbMv(cMoeda)
    Local cSimbolo := Alltrim(SuperGetMv("MV_SIMB"+cMoeda,.F.,""))
Return cSimbolo
 

/*/{Protheus.doc} AgdCvQt030
Converte para a unidade de medida da negociacao
@type function
@version 12
@author carlos.augusto
@since 16/04/2026
/*/
Static Function AgdCvQt030(nQuantContrato, cUMContrato, cCodPro)
    Local aAreaSB1 := SB1->(FwGetArea())

    SB1->(DbSetOrder(1))
    If SB1->(DbSeek(FWxFilial("SB1") + cCodPro))
        If SB1->B1_UM != cUMContrato
            nQuantContrato := AGRX001(SB1->B1_UM, cUMContrato, nQuantContrato, cCodPro)
	        nQuantContrato := round(nQuantContrato, TamSX3("NEE_QTDSAC")[2])
        EndIf
    EndIf
    RestArea(aAreaSB1)

Return nQuantContrato
