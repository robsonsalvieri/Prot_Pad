#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#Include "AGDIP120.CH"
#Define MODEL_NAME  "AGDA120"

/*/{Protheus.doc} AGDIP120
Adapter EAI para envio da Receita/Itens de Receita (AGDA120) ao AgroReceita,
utilizando Mensagem Única em formato JSON.
@type    function
@version 12
@author rodrigo.nsoledade
@since   03/12/2025
@param   xEnt       , variant   , xml/obj para envio/recebimento
@param   cTypeTrans , character , '0'=TRANS_SEND, '1'=TRANS_RECEIVE
@param   cTypeMsg   , character , Tipo Mensagem '20','21','22','23'
@param   cVersion   , character , Versão da mensagem
@param   cTransac   , character , Nome da transação (mensagem única)
@param   lEAIObj    , logical   , .T. = objeto JSON (FWEAIobj)
@return  array, { lResult , xValue(oFWEAIobj ou cMsgErr) , cModelName }
/*/
Function AGDIP120(xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj)
    Local lRet     := .T.
	Local aRet     := { .T., "" }
	Local aAux     := { .F., "" }
    Default lEAIObj := .F.

	If !lEAIObj
		If nTypeTrans == TRANS_RECEIVE

			If cTypeMessage == EAI_MESSAGE_WHOIS
				aAux := { lRet , "1.000"  }
			else
				lRet     := .F.
				aAux := { lRet , 	STR0004 } //"Mensagem Não Implementada"
			EndIf

			aRet := { aAux[ 1 ] , aAux[ 2 ], MODEL_NAME }

		ElseIf nTypeTrans == TRANS_SEND

			lRet     := .F.
			aAux := { lRet , 	STR0005 } //"Mensagem Não Implementada para XML"
			aRet := { aAux[ 1 ] , aAux[ 2 ], MODEL_NAME }

		EndIf

	Else
		//FORMATO JSON
		If nTypeTrans == TRANS_RECEIVE
			If cTypeMessage == EAI_MESSAGE_WHOIS
				aAux := { lRet , "1.000"  }
			else
				lRet     := .F.
				aAux := { lRet , 	STR0004 } //'Mensagem Não Implementada'
			EndIf

			aRet := { aAux[ 1 ] , aAux[ 2 ], MODEL_NAME }

		ElseIf nTypeTrans == TRANS_SEND

			aAux := genEAIobj()

			aRet := { aAux[ 1 ] , aAux[ 2 ], MODEL_NAME }

		EndIf
	EndIf

Return aRet

/*/{Protheus.doc} genEAIobj
Gera o objeto JSON (FWEAIobj) para envio da Receita (NE6) e Itens (NE7)
a partir dos MODELOS ao AgroReceita.
@type    function
@version 12
@author  rodrigo.nsoledade
@since   03/12/2025
@return  array, { lResult , xValue(oFWEAIobj ou cMsgErr) }
/*/
Static Function genEAIobj()
    Local aReturn     := { .F., Nil }
    Local oModelAct   := FWModelActive()
    Local oMdlNE6     := Nil
    Local oMdlNE7     := Nil
    Local oFWEAIobj   := Nil
    Local cEvent      := "upsert"
    Local cInternalId := ""
    Local cInternalOp := ""
    Local cCFOP       := ""
    Local cTesNF      := ""
    Local cTesOper    := ""
    Local cChaveSF3   := ""
    Local cCodProduto    := ""
    Local aDadosSF2   := {}
    Local aDadosItem  := {}

    Local nI          := 0

    // Valida o modelo ativo
    If oModelAct == Nil          ;
        .Or. ValType(oModelAct) != "O" ;
        .Or. !oModelAct:IsActive()     ;
        .Or. oModelAct:GetId() != MODEL_NAME
        aReturn[2] := STR0002 //"Modelo não ativo."
        Return aReturn
    EndIf

    // Obtém modelos NE6 (pai) e NE7 (filho)
    oMdlNE6 := oModelAct:GetModel("AGDA120_NE6")
    oMdlNE7 := oModelAct:GetModel("AGDA120_NE7")

    aDadosSF2 := getDadosSF2(oMdlNE6) //Busca dados da NF de saída na SF2 a partir dos dados da receita NE6

    //  INTERNAL ID (via CFGA070Ext)    
    cInternalId := cEmpAnt + "|" + cFilAnt + "|" + oMdlNE6:GetValue("NE6_CODREC")
    cChaveSF3   := xFilial("SF3")+oMdlNE6:GetValue("NE6_CLIENT")+oMdlNE6:GetValue("NE6_LOJA")+oMdlNE6:GetValue("NE6_DOC")+oMdlNE6:GetValue("NE6_SERIE")
    cCFOP       := Iif(!Empty(oMdlNE6:GetValue("NE6_DOC")),Posicione("SF3",4,cChaveSF3,"F3_CFO"),"")

    //  OBJETO JSON
    oFWEAIobj := FWEAIobj():New()
    oFWEAIobj:Activate()
    oFWEAIobj:setEvent(cEvent)

    oFWEAIobj:setProp("Entity"              , MODEL_NAME)
    oFWEAIobj:setProp("Event"               , cEvent)
    oFWEAIobj:setProp("InternalId"          , cInternalId)
    oFWEAIobj:setProp("ExternalId"          , AllTrim(oMdlNE6:GetValue("NE6_CODEXT")))
    oFWEAIobj:setProp("CompanyId"           , cEmpAnt)
    oFWEAIobj:setProp("BranchId"            , cFilAnt)
    oFWEAIobj:setProp("ReceiptId"           , oMdlNE6:GetValue("NE6_CODREC"))
    oFWEAIobj:setProp("ExternalReceiptId"   , AllTrim(oMdlNE6:GetValue("NE6_CODEXT")))
    oFWEAIobj:setProp("CustomerCode"        , oMdlNE6:GetValue("NE6_CLIENT"))
    oFWEAIobj:setProp("CustomerStore"       , oMdlNE6:GetValue("NE6_LOJA"))
    oFWEAIobj:setProp("ReceiptNumber"       , AllTrim(oMdlNE6:GetValue("NE6_NUMREC")))
    oFWEAIobj:setProp("IssueDate"           , oMdlNE6:GetValue("NE6_DTEMIS"))
    oFWEAIobj:setProp("IssueTime"           , oMdlNE6:GetValue("NE6_HREMIS"))
    oFWEAIobj:setProp("InvoiceNumber"       , oMdlNE6:GetValue("NE6_DOC"))
    oFWEAIobj:setProp("InvoiceSeries"       , oMdlNE6:GetValue("NE6_SERIE"))
    oFWEAIobj:setProp("Status"              , oMdlNE6:GetValue("NE6_STATUS"))
    oFWEAIobj:setProp("SourceOrder"         , oMdlNE6:GetValue("NE6_PEDORI"))
    oFWEAIobj:setProp("ReceiptUrl"          , Alltrim(oMdlNE6:GetValue("NE6_URLREC")))
    oFWEAIobj:setProp("Culture"             , oMdlNE6:GetValue("NE6_CULTUR"))
    oFWEAIobj:setProp("Notes"               , oMdlNE6:GetValue("NE6_OBS"))
    oFWEAIobj:setProp("StatusNF"            , oMdlNE6:GetValue("NE6_STSNF"))

    oFWEAIobj:setProp("tipo_nf"             , "saida")
    oFWEAIobj:setProp("tipo_movimentacao"   , "saida")
    oFWEAIobj:setProp("subtipo_movimentacao", "venda")
    oFWEAIobj:setProp("nf"                  , oMdlNE6:GetValue("NE6_DOC"))
    oFWEAIobj:setProp("serie"               , oMdlNE6:GetValue("NE6_SERIE"))
    oFWEAIobj:setProp("estado"              , aDadosSF2[1])
    oFWEAIobj:setProp("chave_acesso"        , aDadosSF2[2])
    oFWEAIobj:setProp("data_emissao"        , aDadosSF2[3])
    oFWEAIobj:setProp("valor_total"         , aDadosSF2[4])
    oFWEAIobj:setProp("cfop"                , cCFOP)
    oFWEAIobj:setProp("natureza_operacao"   , "Venda de agrotoxico")
    oFWEAIobj:setProp("cpf_cnpj_emissor"    , SM0->M0_CGC)
    oFWEAIobj:setProp("razao_social_emissor", AllTrim(Iif(!Empty(SM0->M0_FULNAME),SM0->M0_FULNAME,SM0->M0_NOMECOM)))
    oFWEAIobj:setProp("endereco_emissor"    , AllTrim(SM0->M0_ENDENT))
    oFWEAIobj:setProp("bairro_emissor"      , AllTrim(SM0->M0_BAIRENT))
    oFWEAIobj:setProp("municipio_emissor"   , AllTrim(SM0->M0_CIDENT))
    oFWEAIobj:setProp("uf_emissor"          , AllTrim(SM0->M0_ESTENT))

    //  ITENS (NE7) – várias linhas
    For nI := 1 To oMdlNE7:Length()

        oMdlNE7:GoLine(nI)

        aDadosItem := getDadosItem(oMdlNE6, oMdlNE7)

        If Empty(aDadosItem[1]) .And. !Empty(oMdlNE7:GetValue("NE7_MAPA"))
            //Caso não encontre o produto pela NF, tenta buscar pelo item solicitação de receita
            cCodProduto   := Posicione("NEU",5,xFilial("NEU")+oMdlNE7:GetValue("NE7_CODREC")+oMdlNE7:GetValue("NE7_SEQREC"),"NEU_PRODUT")
            aDadosItem[1] := Alltrim(Posicione("SB1",1,xFilial("SB1")+cCodProduto,"B1_DESC"))
        EndIf
        
        oFWEAIobj:setprop("Items",{},'Item',,.T.)
		oFWEAIobj:getPropValue("Items")[nI]:setProp("ItemSequence"     , oMdlNE7:GetValue("NE7_SEQREC"))
		oFWEAIobj:getPropValue("Items")[nI]:setProp("Quantity"         , oMdlNE7:GetValue("NE7_QTDE"))
		oFWEAIobj:getPropValue("Items")[nI]:setProp("AvailableQuantity", oMdlNE7:GetValue("NE7_QTDISP"))
    
        oFWEAIobj:getPropValue("Items")[nI]:setProp("cod_prod_mapa"    , AllTrim(oMdlNE7:GetValue("NE7_MAPA")))
        oFWEAIobj:getPropValue("Items")[nI]:setProp("nome_produto"     , aDadosItem[1])
        oFWEAIobj:getPropValue("Items")[nI]:setProp("ncm_produto"      , aDadosItem[2])
        oFWEAIobj:getPropValue("Items")[nI]:setProp("unidade_medida"   , aDadosItem[3])
        oFWEAIobj:getPropValue("Items")[nI]:setProp("qtd_produto"      , aDadosItem[4])
        oFWEAIobj:getPropValue("Items")[nI]:setProp("valor_unitario"   , aDadosItem[5])
        oFWEAIobj:getPropValue("Items")[nI]:setProp("valor_total"      , aDadosItem[6])
        oFWEAIobj:getPropValue("Items")[nI]:setProp("lote"             , aDadosItem[7])
        oFWEAIobj:getPropValue("Items")[nI]:setProp("embalagem_id"     , "")
        cTesNF := Iif(Empty(cTesNF), aDadosItem[8], cTesNF)

    Next nI
    oMdlNE7:GoLine(1)

    cInternalOp := cEmpAnt + "|" + cFilAnt + "|" + cTesNF
    cTesOper := Iif(!Empty(cTesNF),Rtrim(CFGA070Ext("AGD-RECEITA", "SF4", "F4_CODIGO", cInternalOp)), "") //Busca tipo operação no De-Para da
    oFWEAIobj:setProp("operacao"            , cTesOper)

    aReturn[1] := .T.
    aReturn[2] := oFWEAIobj
Return aReturn

/*/{Protheus.doc} getDadosSF2
Busca dados da NF de saída na SF2 a partir dos dados da receita NE6.
@type static function
@param oMdlNE6, object, modelo AGDA120_NE6
@author  rodrigo.nsoledade
@since   30/04/2026
@return array, { lFound, cEstado, cChvNFe, dEmissao, nValFat }
/*/
Static Function getDadosSF2(oMdlNE6)
    Local aAreaSF2 := SF2->(FWGetArea())
    Local aRet     := { "", "", "", 0 }
    Local cDtEmiss := ""

    DbSelectArea("SF2")
    SF2->(DbSetOrder(1))

    If SF2->(DbSeek(FWxFilial("SF2")+oMdlNE6:GetValue("NE6_DOC")+oMdlNE6:GetValue("NE6_SERIE")+oMdlNE6:GetValue("NE6_CLIENT")+oMdlNE6:GetValue("NE6_LOJA")))
        cDtEmiss := DToS(SF2->F2_EMISSAO)
        aRet[1] := SF2->F2_EST
        aRet[2] := SF2->F2_CHVNFE
        aRet[3] := SubStr(cDtEmiss,1,4) + "-" + SubStr(cDtEmiss,5,2) + "-" + SubStr(cDtEmiss,7,2)
        aRet[4] := SF2->F2_VALFAT
    EndIf

    SF2->(FWRestArea(aAreaSF2))

Return aRet

/*/{Protheus.doc} getDadosItem
Busca dados complementares do item da nota fiscal a partir da Receita/Item,
relacionando NE6, NE7, NCR, SB1, SD2 e SFT.
@type    static function
@version 12
@author  rodrigo.nsoledade
@since   04/05/2026
@param   oMdlNE6, object, modelo AGDA120_NE6
@param   oMdlNE7, object, modelo AGDA120_NE7
@return  array, { B1_DESC, FT_POSIPI, D2_UM, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_LOTECTL, D2_TES }
/*/
Static Function getDadosItem(oMdlNE6, oMdlNE7)
    Local aRet       := { "", "", "", 0, 0, 0, "", "" }
    Local cAliasQry  := GetNextAlias()
    Local cQuery     := ""
    Local oStatement := FWPreparedStatement():New()

    Local cCodRec    := AllTrim(oMdlNE6:GetValue("NE6_CODREC"))
    Local cDoc       := AllTrim(oMdlNE6:GetValue("NE6_DOC"))
    Local cSerie     := AllTrim(oMdlNE6:GetValue("NE6_SERIE"))
    Local cMapa      := AllTrim(oMdlNE7:GetValue("NE7_MAPA"))

    If Empty(cMapa) .Or. Empty(cDoc) .Or. Empty(cSerie)
        Return aRet
    EndIf

    cQuery := " SELECT " + CRLF
    cQuery += "     NCR_MAPA, " + CRLF
    cQuery += "     B1_DESC, " + CRLF
    cQuery += "     D2_UM, " + CRLF
    cQuery += "     D2_QUANT, " + CRLF
    cQuery += "     D2_PRCVEN, " + CRLF
    cQuery += "     D2_TOTAL, " + CRLF
    cQuery += "     D2_LOTECTL, " + CRLF
    cQuery += "     D2_TES, " + CRLF
    cQuery += "     ISNULL(SFT.FT_POSIPI, '') FT_POSIPI " + CRLF
    cQuery += " FROM " + RetSqlName("NE6") + " NE6 " + CRLF
    cQuery += " INNER JOIN " + RetSqlName("NE7") + " NE7 " + CRLF
    cQuery += "    ON NE7.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "   AND NE7.NE7_FILIAL = NE6.NE6_FILIAL " + CRLF
    cQuery += "   AND NE7.NE7_CODREC = NE6.NE6_CODREC " + CRLF
    cQuery += "   AND NE7.NE7_MAPA   = ? " + CRLF
    cQuery += " INNER JOIN " + RetSqlName("NCR") + " NCR " + CRLF
    cQuery += "    ON NCR.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "   AND NCR.NCR_MAPA = NE7.NE7_MAPA " + CRLF
    cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 " + CRLF
    cQuery += "    ON SB1.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "   AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
    cQuery += "   AND SB1.B1_COD    = NCR.NCR_PROD " + CRLF
    cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 " + CRLF
    cQuery += "    ON SD2.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "   AND SD2.D2_FILIAL  = NE6.NE6_FILIAL " + CRLF
    cQuery += "   AND SD2.D2_DOC     = NE6.NE6_DOC " + CRLF
    cQuery += "   AND SD2.D2_SERIE   = NE6.NE6_SERIE " + CRLF
    cQuery += "   AND SD2.D2_CLIENTE = NE6.NE6_CLIENT " + CRLF
    cQuery += "   AND SD2.D2_LOJA    = NE6.NE6_LOJA " + CRLF
    cQuery += "   AND SD2.D2_COD     = NCR.NCR_PROD " + CRLF
    cQuery += " LEFT JOIN " + RetSqlName("SFT") + " SFT " + CRLF
    cQuery += "    ON SFT.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "   AND SFT.FT_FILIAL  = SD2.D2_FILIAL " + CRLF
    cQuery += "   AND SFT.FT_NFISCAL = SD2.D2_DOC " + CRLF
    cQuery += "   AND SFT.FT_SERIE   = SD2.D2_SERIE " + CRLF
    cQuery += "   AND SFT.FT_CLIEFOR = SD2.D2_CLIENTE " + CRLF
    cQuery += "   AND SFT.FT_LOJA    = SD2.D2_LOJA " + CRLF
    cQuery += "   AND SFT.FT_PRODUTO = SD2.D2_COD " + CRLF
    cQuery += "   AND SFT.FT_ITEM    = SD2.D2_ITEM " + CRLF
    cQuery += " WHERE NE6.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "   AND NE6.NE6_FILIAL = ? " + CRLF
    cQuery += "   AND NE6.NE6_CODREC = ? " + CRLF
    cQuery += "   AND NE6.NE6_DOC    = ? " + CRLF
    cQuery += "   AND NE6.NE6_SERIE  = ? " + CRLF

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, cMapa)
    oStatement:SetString(2, FWxFilial("NE6"))
    oStatement:SetString(3, cCodRec)
    oStatement:SetString(4, cDoc)
    oStatement:SetString(5, cSerie)

    cQuery := oStatement:GetFixQuery()

    MPSysOpenQuery(cQuery, cAliasQry)

    If (cAliasQry)->(!Eof())
        aRet[1] := AllTrim((cAliasQry)->B1_DESC)
        aRet[2] := AllTrim((cAliasQry)->FT_POSIPI)
        aRet[3] := AllTrim((cAliasQry)->D2_UM)
        aRet[4] := (cAliasQry)->D2_QUANT
        aRet[5] := (cAliasQry)->D2_PRCVEN
        aRet[6] := (cAliasQry)->D2_TOTAL
        aRet[7] := AllTrim((cAliasQry)->D2_LOTECTL)
        aRet[8] := AllTrim((cAliasQry)->D2_TES)
    EndIf

    (cAliasQry)->(DbCloseArea())

Return aRet
