#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#Include "AGDIA010.CH"

#Define MODEL_NAME      "AGDA010"
#Define MODEL_NEA       "AGDA010_NEA"
#Define MODEL_NEB       "AGDA010_NEB"
#Define MODEL_NEE       "AGDA010_NEE"

#Define NAMESPACEAGD totvs.protheus.agrobusiness.agd

/*/{Protheus.doc} AGDIA010
Adapter EAI responsavel pela geracao da mensagem de status da negociacao
Barter (AGDA010) para integracao com o TBDC.
A mensagem utiliza os dados do model MVC ativo, contemplando o cabecalho
da negociacao (NEA), os itens/insumos (NEB) e os locais/contratos (NEE).
@type function
@version 12
@author rodrigo.nsoledade
@since 01/09/2026
@param xEnt, variant, XML/objeto para envio ou recebimento
@param nTypeTrans, numeric, tipo da transacao EAI
@param cTypeMessage, character, tipo da mensagem EAI
@param cVersion, character, versao da mensagem
@param cTransac, character, nome da transacao
@param lEAIObj, logical, .T. para objeto JSON FWEAIObj
@return array, { lResult, xValue, cModelName }
/*/
Function AGDIA010(xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj)
    Local aRet := { .T., "" }
    Local aAux := { .F., "" }

    Default lEAIObj := .F.

    If lEAIObj
        If nTypeTrans == TRANS_SEND
            aAux    := genEAIobj()
            aRet := {aAux[1], aAux[2], MODEL_NAME}
        Else
            aRet := {.F., STR0001, MODEL_NAME} //"Mensagem não implementada."
        EndIf
    Else
        aRet := {.F., STR0002, MODEL_NAME} //"Somente JSON suportado."
    EndIf

Return aRet

/*/{Protheus.doc} genEAIObj
Gera o objeto JSON FWEAIObj para envio dos dados da negociacao ao TBDC.
Os valores sao obtidos prioritariamente dos models MVC ativos para que a
mensagem represente os dados alterados antes da persistencia no banco.
@type static function
@version 12
@author rodrigo.nsoledade
@since 01/09/2026
@return array, { lResult, xValue(oFWEAIObj ou cMsgErro) }
/*/
Static Function genEAIObj()
    Local aReturn     := { .F., Nil }
    Local oFWEAIObj   := Nil
    Local cEvent      := "upsert"
    Local cCodigo     := ""
    Local cVersao     := ""
    Local cInternalId := ""

    // O adapter é executado com a NEA posicionada no registro alterado.
    If Select("NEA") == 0 .Or. NEA->(Eof()) .Or. Empty(NEA->NEA_CODIGO) .Or. Empty(NEA->NEA_VERSAO)
        aReturn[2] := STR0003 //"Negociação não posicionada na tabela NEA."
        Return aReturn
    EndIf

    cCodigo := AllTrim(NEA->NEA_CODIGO)
    cVersao := AllTrim(NEA->NEA_VERSAO)

    cInternalId := cEmpAnt + "|" + NEA->NEA_FILIAL + "|" + cCodigo + "|" + cVersao

    cInternalId := cEmpAnt + "|" + cFilAnt + "|" + cCodigo + "|" + cVersao

    oFWEAIObj := FWEAIObj():New()
    oFWEAIObj:Activate()
    oFWEAIObj:SetEvent(cEvent)

    oFWEAIObj:SetProp("Entity"    , MODEL_NAME)
    oFWEAIObj:SetProp("Event"     , cEvent)
    oFWEAIObj:SetProp("InternalId", cInternalId)
    oFWEAIObj:SetProp("ExternalId", cCodigo + "|" + cVersao)
    oFWEAIObj:SetProp("CompanyId" , cEmpAnt)
    oFWEAIObj:SetProp("BranchId"  , cFilAnt)

    addNEAProps(oFWEAIObj)
    addNEBItems(oFWEAIObj, cCodigo, cVersao)
    addNEEItems(oFWEAIObj, cCodigo, cVersao)

    aReturn[1] := .T.
    aReturn[2] := oFWEAIObj

Return aReturn

/*/{Protheus.doc} addNEAProps
Adiciona ao FWEAIObj os dados do cabecalho da negociacao (NEA).
Os campos de descricao sao tratados por suas relacoes, evitando leitura
de campos visuais como se fossem colunas fisicas da NEA.
@type static function
@version 12
@author rodrigo.nsoledade
@since 01/09/2026
@param oFWEAIObj, object, objeto da mensagem EAI
@return nil
/*/
Static Function addNEAProps(oFWEAIObj)
    Local oNegService  As Object
    Local cCodCliente  := AllTrim(NEA->NEA_CODCLI)
    Local cLojaCliente := AllTrim(NEA->NEA_LOJCLI)
    Local cCodProduto  := AllTrim(NEA->NEA_CODPRO)
    Local cCodVendedor := AllTrim(NEA->NEA_CVEND1)
    Local cDescCliente := ""
    Local cDescProduto := ""
    Local cDescVendedor:= ""
    Local nQtdFaturado := 0
    Local nQtdRecebida := 0

    If !Empty(cCodCliente)
        cDescCliente := AllTrim(Posicione("SA1", 1, xFilial("SA1") + cCodCliente + cLojaCliente, "A1_NOME"))
    EndIf

    If !Empty(cCodProduto)
        cDescProduto := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cCodProduto, "B1_DESC"))
    EndIf

    If !Empty(cCodVendedor)
        cDescVendedor := AllTrim(Posicione("SA3", 1, xFilial("SA3") + cCodVendedor, "A3_NOME"))
    EndIf

    oNegService  := NAMESPACEAGD.BusinessService():New()
    nQtdFaturado := oNegService:getTotalFaturadoBarter(FWxFilial("NEA") + NEA->NEA_CODIGO + NEA->NEA_VERSAO)
    nQtdRecebida := oNegService:getTotalMovimentoNEI(NEA->NEA_CODIGO)

    // Campos principais do cabecalho NEA.
    oFWEAIObj:SetProp("BusinessCode"          , NEA->NEA_CODIGO)
    oFWEAIObj:SetProp("BusinessVersion"       , NEA->NEA_VERSAO)
    oFWEAIObj:SetProp("BusinessStatus"        , NEA->NEA_STATUS)
    oFWEAIObj:SetProp("AuthorizationStatus"   , NEA->NEA_STSAUT)
    oFWEAIObj:SetProp("SellerCode"            , cCodVendedor)
    oFWEAIObj:SetProp("SellerName"            , cDescVendedor)
    oFWEAIObj:SetProp("CustomerCode"          , cCodCliente)
    oFWEAIObj:SetProp("CustomerStore"         , cLojaCliente)
    oFWEAIObj:SetProp("CustomerName"          , cDescCliente)
    oFWEAIObj:SetProp("IssueDate"             , NEA->NEA_EMISSA)
    oFWEAIObj:SetProp("CropCode"              , NEA->NEA_CODSAF)
    oFWEAIObj:SetProp("ProductCode"           , cCodProduto)
    oFWEAIObj:SetProp("ProductDescription"    , cDescProduto)
    oFWEAIObj:SetProp("PriceUnitMeasure"      , NEA->NEA_UMPRC)
    oFWEAIObj:SetProp("Culture"               , NEA->NEA_CULTRA)
    oFWEAIObj:SetProp("ExchangeCurrency"      , NEA->NEA_MOEDRT)
    oFWEAIObj:SetProp("CurrencyIndex"         , NEA->NEA_IDXMOE)
    oFWEAIObj:SetProp("CurrencyRate"          , NEA->NEA_TXMOED)
    oFWEAIObj:SetProp("CurrencyDate"          , NEA->NEA_DTMOED)
    oFWEAIObj:SetProp("ExchangeValue"         , NEA->NEA_VLRRT)
    oFWEAIObj:SetProp("WithheldTax"           , NEA->NEA_IMPOST)
    oFWEAIObj:SetProp("NetExchangeValue"      , NEA->NEA_VLRRTL)
    oFWEAIObj:SetProp("Modality"              , NEA->NEA_MODALI)
    oFWEAIObj:SetProp("FreightType"           , NEA->NEA_TPFRET)
    oFWEAIObj:SetProp("PaymentCondition"      , NEA->NEA_CONDPG)
    oFWEAIObj:SetProp("PriceTableCode"        , NEA->NEA_TABPRC)
    oFWEAIObj:SetProp("ProfitMargin"          , NEA->NEA_MRGLUC)
    oFWEAIObj:SetProp("ValidityDate"          , NEA->NEA_DTVALI)
    oFWEAIObj:SetProp("NegotiatedQuantity"    , NEA->NEA_QTTNEG)
    oFWEAIObj:SetProp("BilledQuantity"        , nQtdFaturado)
    oFWEAIObj:SetProp("DeliveredQuantity"     , nQtdRecebida)

Return Nil

/*/{Protheus.doc} addNEBItems
Adiciona ao payload os itens/insumos da negociacao existentes no model NEB.
@type static function
@version 12
@author rodrigo.nsoledade
@since 01/09/2026
@param oFWEAIObj, object, objeto da mensagem EAI
@param cCodigo, string, código da negociação
@param cVersao, string, versão da negociação
@return nil
/*/
Static Function addNEBItems(oFWEAIObj, cCodigo, cVersao)
    Local aAreaNEB := NEB->(FWGetArea())
    Local nItemEAI := 0

    DbSelectArea("NEB")
    NEB->(DbSetOrder(1))

    If NEB->(DbSeek(xFilial("NEB") + cCodigo + cVersao))

        While !NEB->(Eof()) ;
            .And. NEB->NEB_FILIAL == xFilial("NEB") ;
            .And. NEB->NEB_CODBRT == cCodigo ;
            .And. NEB->NEB_VERSAO == cVersao

            nItemEAI++

            oFWEAIObj:SetProp("Inputs", {}, "Item", , .T.)

            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("BranchId"         , NEB->NEB_FILIAL)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("BusinessCode"  , NEB->NEB_CODBRT)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("Version"          , NEB->NEB_VERSAO)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("Item"             , NEB->NEB_ITEM)            
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("CustomerCode"     , NEB->NEB_CLIENT)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("CustomerStore"    , NEB->NEB_LOJENT)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("ProductCode"      , NEB->NEB_CODPRO)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("UnitMeasure"      , NEB->NEB_UM)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("CostPrice"        , NEB->NEB_PRCCUS)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("TablePrice"       , NEB->NEB_PRCTAB)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("UnitPrice"        , NEB->NEB_PRCUNI)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("Quantity"         , NEB->NEB_QTDVEN)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("TotalValue"       , NEB->NEB_VALOR)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("AdjustmentPercent", NEB->NEB_PDESAC)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("AdjustmentValue"  , NEB->NEB_VDESAC)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("Warehouse"        , NEB->NEB_LOCAL)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("FiscalOperation"  , NEB->NEB_OPER)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("TES"              , NEB->NEB_TES)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("DeliveryDate"     , NEB->NEB_ENTREG)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("Lot"              , NEB->NEB_LOTCTL)
            oFWEAIObj:GetPropValue("Inputs")[nItemEAI]:SetProp("Parity"           , NEB->NEB_PARID)

            NEB->(DbSkip())
        EndDo

    EndIf

    NEB->(FWRestArea(aAreaNEB))

Return Nil

/*/{Protheus.doc} addNEEItems
Adiciona ao payload os dados de contrato da negociação armazenados na NEE.
@type static function
@version 12
@author rodrigo.nsoledade
@since 08/09/2026
@param oFWEAIObj, object, objeto da mensagem EAI
@param cCodigo, character, código da negociação
@param cVersao, character, versão da negociação
@return nil
/*/
Static Function addNEEItems(oFWEAIObj, cCodigo, cVersao)
    Local aAreaNEE := NEE->(FWGetArea())
    Local nItemEAI := 0

    DbSelectArea("NEE")
    NEE->(DbSetOrder(1))

    If NEE->(DbSeek(xFilial("NEE") + cCodigo + cVersao))

        While !NEE->(Eof()) ;
            .And. NEE->NEE_FILIAL == xFilial("NEE") ;
            .And. NEE->NEE_CODBRT == cCodigo ;
            .And. NEE->NEE_VERSAO == cVersao

            nItemEAI++

            oFWEAIObj:SetProp("Contracts", {},"DeliveryLocation",,.T.)

            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("BranchId"         , NEE->NEE_FILIAL)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("BusinessCode"  , NEE->NEE_CODBRT)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("Version"          , NEE->NEE_VERSAO)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("Item"             , NEE->NEE_ITEM)            
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("PropertyCode"     , NEE->NEE_CDPROP)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("PropertyStore"    , NEE->NEE_LJPROP)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("Quantity"         , NEE->NEE_QTDSAC)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("TES"              , NEE->NEE_TESCTR)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("FiscalOperation"  , NEE->NEE_OPEFIS)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("Warehouse"        , NEE->NEE_LOCAL)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("DeliveryEndDate"  , NEE->NEE_FIMENT)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("DeliveryStartDate", NEE->NEE_INIENT)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("PaymentCondition" , NEE->NEE_CONDPG)
            oFWEAIObj:GetPropValue("Contracts")[nItemEAI]:SetProp("FreightType"      , NEE->NEE_TPFRET)

            NEE->(DbSkip())

        EndDo

    EndIf

    NEE->(FWRestArea(aAreaNEE))

Return Nil
