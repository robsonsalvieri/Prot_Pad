#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBA940J.CH"

Function CTBA940J()
    If QLB->(FieldPos("QLB_VERSAO")) > 0
        UpdateQLB()
    Else
        FWAlertHelp( STR0071 ;//"Não foi encontrado o campo QLB_VERSAO em seu dicionário de dados";
            , STR0072 ) //"Atualize seu dicionário de dados com a expedição continua para incluir o campo, assim poderemos atualizar e implementar novas configurações de forma automática em seu Conciliador."
    EndIf
Return

Static Function UpdateQLB()

    Local jsonLoop  := JsonObject():New() as Json
    Local jsonSave  := JsonObject():New() as Json
    Local lContinue := .T. as Logical
    Local lFound := .T. as Logical
    Local cCodCfg   := "" as Character
    Local cVersion  := "" as Character
    Local nI        := 0 as Numeric

    DeleteEmptyQLB() //Limpreza de configurações de conciliação em branco

    jsonLoop:FromJson(GetJsonCfgInfo())

    for nI := 1 to Len(jsonLoop["items"])

        cCodCfg := jsonLoop["items"][nI]["codcfg"]
        cVersion := GetJsonVersion(cCodCfg)

        //Se a função CheckUpdate retornar falso, não há necessidade de atualização
        If (CheckUpdate(cCodCfg, cVersion, @lFound) )
            lContinue := .T.

            jsonSave["codcfg"]  := cCodCfg
            jsonSave["descfg"]  := jsonLoop["items"][nI]["descfg"]
            jsonSave["tabori"]  := jsonLoop["items"][nI]["tabori"]
            jsonSave["descor"]  := jsonLoop["items"][nI]["descor"]
            jsonSave["tabdes"]  := jsonLoop["items"][nI]["tabdes"]
            jsonSave["descde"]  := jsonLoop["items"][nI]["descde"]
            jsonSave["fields"]  := GetJsonFields(cCodCfg)
            jsonSave["filter"]  := GetJsonFilters(cCodCfg)
            jsonSave["cidori"]  := GetCIDFields(cCodCfg, /*lIDOrigem*/ .T.)
            jsonSave["ciddes"]  := GetCIDFields(cCodCfg, /*lIDOrigem*/ .F.)
            jsonSave["regmat"]  := GetJsonRegMatch(cCodCfg)
            jsonSave["total"]   := GetJsonTotal(cCodCfg)
            jsonSave["version"] := cVersion
            //Apenas as configurações 0020 e 0021 possuem o atributo "union"
            If cCodCfg == "0020" .Or. cCodCfg == "0021"
                jsonSave["union"] := GetJsonUnion(cCodCfg)

                If QLB->(FieldPos("QLB_TABGRP")) == 0
                    FWAlertHelp(STR0073 + cCodCfg + STR0074 , STR0068) //"A configuração " // " não pode ser incluída, porque o dicionário de dados ainda não foi atualizado com o campo QLB_TABGRP"// ""Por favor, atualize sua tabela utilizar as configurações de conciliação mais atualizadas""
                    lContinue := .F.
                EndIf
            EndIf

            If lContinue
                //Gravar os dados na QLB
                SaveJsonOnQLB(jsonSave, lFound)
            EndIf

        EndIf

        //Limpar o Json ao final do loop para receber os dados do próximo item
        jsonSave := JsonObject():New()

    next nI
Return

//Retorna as informações basicas da configuração
Static Function GetJsonCfgInfo()
    Local cCfgInfo      := "" as Character
    Local cCT2CfgInfo   := "" as Character

    cCT2CfgInfo :=  '"tabdes": "CT2",'+;
                    '"descde": "'+ STR0008 +'"' //"Lançamentos Contábeis"

    cCfgInfo := '{"items":['+;
                    '{'+;
                        '"codcfg": "0001",'+;
                        '"descfg": "'+ STR0009 + '",'+; //"Contas a Receber x Contabilidade"
                        '"tabori": "SE1",'+;
                        '"descor": "'+ STR0010 + '",'+; //"Contas a Receber"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0002",'+;
                        '"descfg": "'+ STR0011 +'",'+; //"Contas a Pagar x Contabilidade"
                        '"tabori": "SE2",'+;
                        '"descor": "'+ STR0012 +'",'+; //"Contas a Pagar"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0003",'+;
                        '"descfg": "'+ STR0013 +'" ,'+; //"Movimentação Bancária x Contabilidade"
                        '"tabori": "SE5",'+;
                        '"descor": "'+ STR0014 +'",'+; //"Movimentação Bancária"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0004",'+;
                        '"descfg": "'+ STR0015 +'",'+; //"Cabeçalho das NF de Entrada x Contabilidade"
                        '"tabori": "SF1",'+;
                        '"descor": "'+ STR0016 +'",'+; //"Cabeçalho das NF de Entrada"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0005",'+;
                        '"descfg": "'+ STR0017 +'",'+; //"Itens das NF de Entrada x Contabilidade"
                        '"tabori": "SD1",'+;
                        '"descor": "'+ STR0018 +'",'+; //"Itens das NF de Entrada"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0006",'+;
                        '"descfg": "'+STR0019+'",'+; //"Movimentações Internas x Contabilidade"
                        '"tabori": "SD3",'+;
                        '"descor": "'+STR0020+'",'+; //"Movimentações Internas"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0007",'+;
                        '"descfg": "'+ STR0021 +'",'+; //"Pedidos de Compras x Contabilidade"
                        '"tabori": "SC7",'+;
                        '"descor": "'+ STR0022 +'",'+; //"Pedidos de Compras"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0008",'+;
                        '"descfg": "' +STR0023+ '",'+; //"Cotações x Contabilidade"
                        '"tabori": "SC8",'+;
                        '"descor": "' +STR0024+ '",'+; //"Cotações"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0009",'+;
                        '"descfg": "'+ STR0025 +'",'+; //"Pedidos de Venda x Contabilidade"
                        '"tabori": "SC5",'+;
                        '"descor": "'+ STR0026 +'",'+; //"Pedidos de Venda"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0010",'+;
                        '"descfg": "'+ STR0027 +'",'+; //"Itens de Pedidos x Contabilidade"
                        '"tabori": "SC6",'+;
                        '"descor": "'+ STR0028 +'",'+; //"Itens de Pedidos"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0011",'+;
                        '"descfg": "'+ STR0029 +'",'+; //"Cabeçalho NF Saída x Contabilidade"
                        '"tabori": "SF2",'+;
                        '"descor": "'+ STR0030+ '",'+; //"Cabeçalho NF Saída"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0012",'+;
                        '"descfg": "'+ STR0031 +'",'+; //"Itens NF Saída x Contabilidade"
                        '"tabori": "SD2",'+;
                        '"descor": "'+ STR0032+ '",'+; //"Itens NF Saída"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0013",'+;
                        '"descfg": "'+ STR0033 +'",'+; //"Cheques x Contabilidade"
                        '"tabori": "SEF",'+;
                        '"descor": "'+ STR0034 +'",'+; //"Cheques"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0014",'+;
                        '"descfg": "'+ STR0035 +'",'+; //"Rateio NF Saida x Contabilidade"
                        '"tabori": "AGH",'+;
                        '"descor": "'+ STR0036 +'",'+; //"Rateio NF Saida"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0015",'+;
                        '"descfg": "'+ STR0037 +'",'+; //"Rateio Pedido de Venda x Contabilidade"
                        '"tabori": "AGG",'+;
                        '"descor": "'+ STR0038 +'",'+; //"Rateio Pedido de Venda"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0016",'+;
                        '"descfg": "'+ STR0039 +'",'+; //"Mov AVP CR x Contabilidade"
                        '"tabori": "FIP",'+;
                        '"descor": "'+ STR0040 +'",'+; //"Mov AVP CR"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0017",'+;
                        '"descfg": "'+ STR0041 +'",'+; //"Distrib de Naturezas em CC x Contabilidade"
                        '"tabori": "SEZ",'+;
                        '"descor": "'+ STR0042 +'",'+; //"Distrib de Naturezas em CC"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0018",'+;
                        '"descfg": "'+ STR0043 +'",'+; //"Mov AVP CP x Contabilidade"
                        '"tabori": "FIS",'+;
                        '"descor": "'+ STR0044 +'",'+; //"Mov AVP CP"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0019",'+;
                        '"descfg": "'+ STR0045 +'",'+; //"Movimentos do Caixinha x Contabilidade"
                        '"tabori": "SEU",'+;
                        '"descor": "'+ STR0046 +'",'+; //"Movimentos do Caixinha"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0020",'+;
                        '"descfg": "'+ STR0047 +'",'+; //"NF de Entrada x Contabilidade"
                        '"tabori": "SF1",'+;
                        '"descor": "'+ STR0048 +'",'+; //"NF de Entrada"
                        ''+cCT2CfgInfo+;
                    '},'+;
                    '{'+;
                        '"codcfg": "0021",'+;
                        '"descfg": "' +STR0049+ '",'+; //"NF de Saída x Contabilidade"
                        '"tabori": "SF2",'+;
                        '"descor": "'+ STR0050 +'",'+; //"NF de Saída"
                        ''+cCT2CfgInfo+;
                    '}'+;
                ']}'


Return cCfgInfo

//Retorna o objeto pronto para gravar na QLB
Static Function GetJsonFields(cCodCfg as Character)

    Local cFields    := "" as Character
    Local cCT2Fields := "" as Character
    Local jFields := JsonObject():New() as Json

    cCT2Fields := '"data_des": ['+;
                        '"CT2_FILIAL",'+;
                        '"CT2_DATA",'+;
                        '"CT2_VALOR",'+;
                        '"CT2_LOTE",'+;
                        '"CT2_DOC",'+;
                        '"CT2_MOEDLC",'+;
                        '"CT2_TPSALD",'+;
                        '"CT2_DC",'+;
                        '"CT2_DEBITO",'+;
                        '"CT2_CREDIT",'+;
                        '"CT2_HIST",'+;
                        '"CT2_CCD",'+;
                        '"CT2_CCC",'+;
                        '"CT2_ITEMD",'+;
                        '"CT2_ITEMC",'+;
                        '"CT2_CLVLDB",'+;
                        '"CT2_CLVLCR"'+;
                    ']'+;
                    '}'

    If  cCodCfg == "0001"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"E1_FILIAL",'+;
                        '"E1_PREFIXO",'+;
                        '"E1_NUM",'+;
                        '"E1_PARCELA",'+;
                        '"E1_TIPO",'+;
                        '"E1_VALOR",'+;
                        '"E1_NATUREZ",'+;
                        '"E1_CLIENTE",'+;
                        '"E1_LOJA",'+;
                        '"E1_EMISSAO",'+;
                        '"E1_VENCTO",'+;
                        '"E1_VENCREA",'+;
                        '"E1_ISS",'+;
                        '"E1_IRRF",'+;
                        '"E1_HIST",'+;
                        '"E1_MOEDA",'+;
                        '"E1_NODIA"'+;
                    '],' ;
                    + cCT2Fields
    ElseIf  cCodCfg == "0002"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"E2_FILIAL",'+;
                        '"E2_PREFIXO",'+;
                        '"E2_NUM",'+;
                        '"E2_PARCELA",'+;
                        '"E2_TIPO",'+;
                        '"E2_VALOR",'+;
                        '"E2_NATUREZ",'+;
                        '"E2_PORTADO",'+;
                        '"E2_FORNECE",'+;
                        '"E2_LOJA",'+;
                        '"E2_EMISSAO",'+;
                        '"E2_VENCTO",'+;
                        '"E2_VENCREA",'+;
                        '"E2_IRRF",'+;
                        '"E2_INSS",'+;
                        '"E2_HIST",'+;
                        '"E2_MOEDA"'+;
                    '],' ;
                    + cCT2Fields
    ElseIf  cCodCfg == "0003"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"E5_FILIAL",'+;
                        '"E5_DATA",'+;
                        '"E5_MOEDA",'+;
                        '"E5_VALOR",'+;
                        '"E5_PARCELA",'+;
                        '"E5_PREFIXO",'+;
                        '"E5_NATUREZ",'+;
                        '"E5_BANCO",'+;
                        '"E5_AGENCIA",'+;
                        '"E5_CONTA",'+;
                        '"E5_NUMERO",'+;
                        '"E5_NUMCHEQ",'+;
                        '"E5_BENEF",'+;
                        '"E5_HISTOR",'+;
                        '"E5_CREDITO",'+;
                        '"E5_MODSPB",'+;
                        '"E5_TXMOEDA",'+;
                        '"E5_NODIA"'+;
                    '],' ;
                    + cCT2Fields

    ElseIf  cCodCfg == "0004"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"F1_FILIAL",'+;
                        '"F1_DOC",'+;
                        '"F1_DTDIGIT",'+;
                        '"F1_SERIE",'+;
                        '"F1_FORNECE",'+;
                        '"F1_LOJA",'+;
                        '"F1_COND",'+;
                        '"F1_VALBRUT",'+;
                        '"F1_HAWB",'+;
                        '"F1_NFELETR",'+;
                        '"F1_TPFRETE",'+;
                        '"F1_TPCTE",'+;
                        '"F1_ANOAIDF",'+;
                        '"F1_NUMAIDF",'+;
                        '"F1_MODAL",'+;
                        '"F1_ESTPRES"'+;
                    '],' ;
                    + cCT2Fields

    ElseIf  cCodCfg == "0005"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"D1_FILIAL",'+;
                        '"D1_COD",'+;
                        '"D1_UM",'+;
                        '"D1_SEGUM",'+;
                        '"D1_QUANT",'+;
                        '"D1_VUNIT",'+;
                        '"D1_TOTAL",'+;
                        '"D1_DTDIGIT",'+;
                        '"D1_LOCPAD",'+;
                        '"D1_ORDEM",'+;
                        '"D1_SERVIC",'+;
                        '"D1_ENDER",'+;
                        '"D1_TPESTR",'+;
                        '"D1_DESCICM",'+;
                        '"D1_DFABRIC",'+;
                        '"D1_CODLAN",'+;
                        '"D1_VALCMAJ"'+;
                        '],' ;
                        + cCT2Fields

    ElseIf  cCodCfg == "0006"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"D3_FILIAL",'+;
                        '"D3_TM",'+;
                        '"D3_COD",'+;
                        '"D3_UM",'+;
                        '"D3_QUANT",'+;
                        '"D3_OP",'+;
                        '"D3_CUSTO1",'+;
                        '"D3_LOCAL",'+;
                        '"D3_LOTECTL",'+;
                        '"D3_LOCALIZ",'+;
                        '"D3_DOC",'+;
                        '"D3_TIPO",'+;
                        '"D3_GRUPO",'+;
                        '"D3_EMISSAO",'+;
                        '"D3_REGWMS",'+;
                        '"D3_PERDA",'+;
                        '"D3_ORDEM"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0007"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"C7_FILIAL",'+;
                        '"C7_NUM",'+;
                        '"C7_EMISSAO",'+;
                        '"C7_FORNECE",'+;
                        '"C7_LOJA",'+;
                        '"C7_TIPO",'+;
                        '"C7_ITEM",'+;
                        '"C7_PRODUTO",'+;
                        '"C7_UM",'+;
                        '"C7_SEGUM",'+;
                        '"C7_QUANT",'+;
                        '"C7_PRECO",'+;
                        '"C7_TOTAL",'+;
                        '"C7_LOCAL"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0008"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"C8_FILIAL",'+;
                        '"C8_NUM",'+;
                        '"C8_ITEM",'+;
                        '"C8_EMISSAO",'+;
                        '"C8_PRODUTO",'+;
                        '"C8_UM",'+;
                        '"C8_QUANT",'+;
                        '"C8_PRECO",'+;
                        '"C8_TOTAL",'+;
                        '"C8_SEGUM",'+;
                        '"C8_QTSEGUM",'+;
                        '"C8_FORNECE",'+;
                        '"C8_LOJA",'+;
                        '"C8_FORNOME",'+;
                        '"C8_FORMAIL",'+;
                        '"C8_PRECOOR",'+;
                        '"C8_NUMPRO"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0009"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"C5_FILIAL",'+;
                        '"C5_EMISSAO",'+;
                        '"C5_NUM",'+;
                        '"C5_CLIENTE",'+;
                        '"C5_LOJACLI",'+;
                        '"C5_FRETE",'+;
                        '"C5_VEND1",'+;
                        '"C5_PEDEXP",'+;
                        '"C5_CODED",'+;
                        '"C5_NUMPR",'+;
                        '"C5_MUNPRES",'+;
                        '"C5_DESCMUN",'+;
                        '"C5_SERSUBS",'+;
                        '"C5_NFSUBST",'+;
                        '"C5_OBRA",'+;
                        '"C5_MOEDTIT",'+;
                        '"C5_TXREF"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0010"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"C6_FILIAL",'+;
                        '"C6_ITEM",'+;
                        '"C6_PRODUTO",'+;
                        '"C6_UM",'+;
                        '"C6_QTDVEN",'+;
                        '"C6_PRCVEN",'+;
                        '"C6_VALOR",'+;
                        '"C6_DATFAT",'+;
                        '"C6_QTDLIB",'+;
                        '"C6_SEGUM",'+;
                        '"C6_OPER",'+;
                        '"C6_TES",'+;
                        '"C6_LOCAL",'+;
                        '"C6_CF",'+;
                        '"C6_QTDENT",'+;
                        '"C6_CLI",'+;
                        '"C6_LOJA"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0011"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"F2_FILIAL",'+;
                        '"F2_DOC",'+;
                        '"F2_SERIE",'+;
                        '"F2_EMISSAO",'+;
                        '"F2_CLIENTE",'+;
                        '"F2_LOJA",'+;
                        '"F2_COND",'+;
                        '"F2_VALBRUT",'+;
                        '"F2_VALMERC",'+;
                        '"F2_TPFRETE",'+;
                        '"F2_NFELETR",'+;
                        '"F2_BASEIRR",'+;
                        '"F2_NFICMST",'+;
                        '"F2_DESCZFR",'+;
                        '"F2_DTTXREF",'+;
                        '"F2_SERMDF"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0012"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"D2_FILIAL",'+;
                        '"D2_DOC",'+;
                        '"D2_SERIE",'+;
                        '"D2_COD",'+;
                        '"D2_CLIENTE",'+;
                        '"D2_LOJA",'+;
                        '"D2_LOCAL",'+;
                        '"D2_UM",'+;
                        '"D2_QUANT",'+;
                        '"D2_TOTAL",'+;
                        '"D2_PRCVEN",'+;
                        '"D2_TPESTR",'+;
                        '"D2_ITLPRE",'+;
                        '"D2_VLIMPOR",'+;
                        '"D2_DIFAL",'+;
                        '"D2_PDORI",'+;
                        '"D2_INDICE"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0013"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"EF_FILIAL",'+;
                        '"EF_BANCO",'+;
                        '"EF_AGENCIA",'+;
                        '"EF_CONTA",'+;
                        '"EF_NUM",'+;
                        '"EF_VALOR",'+;
                        '"EF_DATA",'+;
                        '"EF_VENCTO",'+;
                        '"EF_PREFIXO",'+;
                        '"EF_TITULO",'+;
                        '"EF_PARCELA",'+;
                        '"EF_TIPO",'+;
                        '"EF_BENEF",'+;
                        '"EF_FORNECE",'+;
                        '"EF_LOJA",'+;
                        '"EF_CLIENTE",'+;
                        '"EF_LOJACLI"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0014"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"AGH_FILIAL",'+;
                        '"AGH_NUM",'+;
                        '"AGH_SERIE",'+;
                        '"AGH_FORNEC",'+;
                        '"AGH_LOJA",'+;
                        '"AGH_ITEM",'+;
                        '"AGH_ITEMPD",'+;
                        '"AGH_PERC",'+;
                        '"AGH_CC",'+;
                        '"AGH_CONTA",'+;
                        '"AGH_ITEMCT",'+;
                        '"AGH_CLVL",'+;
                        '"AGH_CUSTO1"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0015"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"AGG_FILIAL",'+;
                        '"AGG_PEDIDO",'+;
                        '"AGG_FORNEC",'+;
                        '"AGG_LOJA",'+;
                        '"AGG_ITEM",'+;
                        '"AGG_ITEMPD",'+;
                        '"AGG_PERC",'+;
                        '"AGG_CC",'+;
                        '"AGG_CONTA",'+;
                        '"AGG_ITEMCT",'+;
                        '"AGG_CLVL",'+;
                        '"AGG_CUSTO1"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0016"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"FIP_FILIAL",'+;
                        '"FIP_PREFIX",'+;
                        '"FIP_NUM",'+;
                        '"FIP_PARCEL",'+;
                        '"FIP_TIPO",'+;
                        '"FIP_CLIENT",'+;
                        '"FIP_LOJA",'+;
                        '"FIP_SEQ",'+;
                        '"FIP_DTAVP",'+;
                        '"FIP_TAXAVP",'+;
                        '"FIP_VLRAVP",'+;
                        '"FIP_FORMUL",'+;
                        '"FIP_CODIND",'+;
                        '"FIP_PERIOD",'+;
                        '"FIP_STATUS"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0017"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"EZ_FILIAL",'+;
                        '"EZ_PREFIXO",'+;
                        '"EZ_NUM",'+;
                        '"EZ_PARCELA",'+;
                        '"EZ_CLIFOR",'+;
                        '"EZ_LOJA",'+;
                        '"EZ_TIPO",'+;
                        '"EZ_VALOR",'+;
                        '"EZ_NATUREZ",'+;
                        '"EZ_CCUSTO",'+;
                        '"EZ_RECPAG",'+;
                        '"EZ_PERC",'+;
                        '"EZ_ITEMCTA",'+;
                        '"EZ_IDENT",'+;
                        '"EZ_SEQ",'+;
                        '"EZ_SITUACA",'+;
                        '"EZ_CONTA"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0018"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"FIS_FILIAL",'+;
                        '"FIS_PREFIX",'+;
                        '"FIS_NUM",'+;
                        '"FIS_PARCEL",'+;
                        '"FIS_TIPO",'+;
                        '"FIS_FORNEC",'+;
                        '"FIS_LOJA",'+;
                        '"FIS_SEQ",'+;
                        '"FIS_DTAVP",'+;
                        '"FIS_VLRAVP",'+;
                        '"FIS_TAXAVP",'+;
                        '"FIS_FORMUL",'+;
                        '"FIS_CODIND",'+;
                        '"FIS_VLRIND",'+;
                        '"FIS_PERIOD",'+;
                        '"FIS_STATUS"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0019"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"EU_NUM",'+;
                        '"EU_CAIXA",'+;
                        '"EU_TIPO",'+;
                        '"EU_HISTOR",'+;
                        '"EU_NRCOMP",'+;
                        '"EU_VALOR",'+;
                        '"EU_BENEF",'+;
                        '"EU_DTDIGIT",'+;
                        '"EU_NOME",'+;
                        '"EU_CONTAD",'+;
                        '"EU_CONTAC",'+;
                        '"EU_CCD",'+;
                        '"EU_CCC",'+;
                        '"EU_ITEMD",'+;
                        '"EU_ITEMC",'+;
                        '"EU_CLVLDB",'+;
                        '"EU_DIACTB"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0020"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"F1_FILIAL",'+;
                        '"F1_DOC",'+;
                        '"F1_DTDIGIT",'+;
                        '"F1_SERIE",'+;
                        '"F1_FORNECE",'+;
                        '"F1_LOJA",'+;
                        '"F1_COND",'+;
                        '"F1_VALBRUT",'+;
                        '"F1_HAWB",'+;
                        '"F1_NFELETR",'+;
                        '"F1_TPFRETE",'+;
                        '"F1_TPNFEXP",'+;
                        '"F1_TPCTE",'+;
                        '"F1_ANOAIDF",'+;
                        '"F1_NUMAIDF",'+;
                        '"F1_MODAL",'+;
                        '"F1_ESTPRES"'+;
                        '],' ;
                        + cCT2Fields
    ElseIf  cCodCfg == "0021"
        cFields :=  '{'+;
                        '"data_ori": ['+;
                        '"F2_FILIAL",'+;
                        '"F2_DOC",'+;
                        '"F2_SERIE",'+;
                        '"F2_EMISSAO",'+;
                        '"F2_CLIENTE",'+;
                        '"F2_LOJA",'+;
                        '"F2_COND",'+;
                        '"F2_VALBRUT",'+;
                        '"F2_VALMERC",'+;
                        '"F2_TPFRETE",'+;
                        '"F2_NFELETR",'+;
                        '"F2_BASEIRR",'+;
                        '"F2_NFICMST",'+;
                        '"F2_TPNFEXP",'+;
                        '"F2_DESCZFR",'+;
                        '"F2_DTTXREF",'+;
                        '"F2_SERMDF"'+;
                        '],' ;
                        + cCT2Fields
    EndIf

    jFields:FromJson(cFields)

//Return cFields
Return jFields

Static Function GetJsonFilters(cCodCfg as Character)

    Local cFilters := '' as Character
    Local cFiltersCT2 := '' as Character
    Local jFilters := JsonObject():New()

    cFiltersCT2 := '"tabdes": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "CT2_DATA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "CT2_DATA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "CT2_DOC",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "CT2_DOC",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "CT2_DEBITO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "CT2_DEBITO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "CT2_CREDIT",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "CT2_CREDIT",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "CT2_CCD",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "CT2_CCD",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "CT2_CCC",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "CT2_CCC",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "13",'+;
                            '"field": "CT2_ITEMD",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "14",'+;
                            '"field": "CT2_ITEMD",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "15",'+;
                            '"field": "CT2_ITEMC",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "16",'+;
                            '"field": "CT2_ITEMC",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "17",'+;
                            '"field": "CT2_CLVLDB",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "18",'+;
                            '"field": "CT2_CLVLDB",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "19",'+;
                            '"field": "CT2_CLVLCR",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "20",'+;
                            '"field": "CT2_CLVLCR",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "21",'+;
                            '"field": "CT2_LOTE",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "22",'+;
                            '"field": "CT2_LP",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "23",'+;
                            '"field": "CT2_TPSALD",'+;
                            '"operation": "IN"'+;
                        '}'+;
                    ']'+;
                    '}'

    If cCodCfg == "0001"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "E1_EMISSAO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "E1_EMISSAO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "E1_VENCREA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "E1_VENCREA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "E1_PREFIXO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "E1_PREFIXO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "E1_NUM",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "E1_NUM",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "E1_NATUREZ",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "E1_NATUREZ",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "E1_CLIENTE",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "E1_CLIENTE",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "13",'+;
                            '"field": "E1_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "14",'+;
                            '"field": "E1_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "15",'+;
                            '"field": "E1_TIPO",'+;
                            '"operation": "IN"'+;
                        '}'+;
                    '],';
                    + cFiltersCT2

    ElseIf cCodCfg == "0002"
        cFilters := '{'+;
                        '"tabori": ['+;
                            '{'+;
                                '"order": "01",'+;
                                '"field": "E2_EMISSAO",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "02",'+;
                                '"field": "E2_EMISSAO",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "03",'+;
                                '"field": "E2_VENCREA",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "04",'+;
                                '"field": "E2_VENCREA",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "05",'+;
                                '"field": "E2_PREFIXO",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "06",'+;
                                '"field": "E2_PREFIXO",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "07",'+;
                                '"field": "E2_NUM",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "08",'+;
                                '"field": "E2_NUM",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "09",'+;
                                '"field": "E2_NATUREZ",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "10",'+;
                                '"field": "E2_NATUREZ",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "11",'+;
                                '"field": "E2_FORNECE",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "12",'+;
                                '"field": "E2_FORNECE",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "13",'+;
                                '"field": "E2_LOJA",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "14",'+;
                                '"field": "E2_LOJA",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "15",'+;
                                '"field": "E2_TIPO",'+;
                                '"operation": "IN"'+;
                            '}'+;
                        '],';
                        + cFiltersCT2

    ElseIf cCodCfg == "0003"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "E5_DATA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "E5_DATA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "E5_PREFIXO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "E5_PREFIXO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "E5_NUMERO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "E5_NUMERO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "E5_PARCELA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "E5_PARCELA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "E5_BANCO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "E5_BANCO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "E5_AGENCIA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "E5_AGENCIA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "13",'+;
                            '"field": "E5_CONTA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "14",'+;
                            '"field": "E5_CONTA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "15",'+;
                            '"field": "E5_TIPO",'+;
                            '"operation": "IN"'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0004"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "F1_DTDIGIT",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "F1_DTDIGIT",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "F1_DOC",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "F1_DOC",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "F1_FORNECE",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "F1_FORNECE",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "F1_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "F1_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "F1_TIPO",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "F1_ESPECIE",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "F1_VALBRUT",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "F1_VALBRUT",'+;
                            '"operation": "<="'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0005"
        cFilters := '{'+;
                    '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "D1_DTDIGIT",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "D1_DTDIGIT",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "D1_COD",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "D1_COD",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "D1_FORNECE",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "D1_FORNECE",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "D1_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "D1_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "D1_TOTAL",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "D1_TOTAL",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "D1_TIPO",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "D1_TES",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "13",'+;
                            '"field": "D1_CF",'+;
                            '"operation": "IN"'+;
                        '}'+;
                    '],';
                    + cFiltersCT2

    ElseIf cCodCfg == "0006"
        cFilters := '{'+;
            '"tabori": ['+;
                '{'+;
                    '"order": "01",'+;
                    '"field": "D3_EMISSAO",'+;
                    '"operation": ">="'+;
                '},'+;
                '{'+;
                    '"order": "02",'+;
                    '"field": "D3_EMISSAO",'+;
                    '"operation": "<="'+;
                '},'+;
                '{'+;
                    '"order": "03",'+;
                    '"field": "D3_COD",'+;
                    '"operation": ">="'+;
                '},'+;
                '{'+;
                    '"order": "04",'+;
                    '"field": "D3_COD",'+;
                    '"operation": "<="'+;
                '},'+;
                '{'+;
                    '"order": "05",'+;
                    '"field": "D3_OP",'+;
                    '"operation": ">="'+;
                '},'+;
                '{'+;
                    '"order": "06",'+;
                    '"field": "D3_OP",'+;
                    '"operation": "<="'+;
                '},'+;
                '{'+;
                    '"order": "07",'+;
                    '"field": "D3_GRUPO",'+;
                    '"operation": ">="'+;
                '},'+;
                '{'+;
                    '"order": "08",'+;
                    '"field": "D3_GRUPO",'+;
                    '"operation": "<="'+;
                '},'+;
                '{'+;
                    '"order": "09",'+;
                    '"field": "D3_LOCAL",'+;
                    '"operation": "IN"'+;
                '},'+;
                '{'+;
                    '"order": "10",'+;
                    '"field": "D3_TIPO",'+;
                    '"operation": "IN"'+;
                '},'+;
                '{'+;
                    '"order": "11",'+;
                    '"field": "D3_LOTECTL",'+;
                    '"operation": "IN"'+;
                '},'+;
                '{'+;
                    '"order": "12",'+;
                    '"field": "D3_LOCALIZ",'+;
                    '"operation": "IN"'+;
                '}'+;
            '],';
            + cFiltersCT2
    ElseIf cCodCfg == "0007"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "C7_EMISSAO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "C7_EMISSAO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "C7_NUM",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "C7_NUM",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "C7_FORNECE",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "C7_FORNECE",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "C7_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "C7_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "C7_PRODUTO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "C7_PRODUTO",'+;
                            '"operation": "<="'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0008"
        cFilters := '{'+;
                        '"tabori": ['+;
                            '{'+;
                                '"order": "01",'+;
                                '"field": "C8_EMISSAO",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "02",'+;
                                '"field": "C8_EMISSAO",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "03",'+;
                                '"field": "C8_NUM",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "04",'+;
                                '"field": "C8_NUM",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "05",'+;
                                '"field": "C8_ITEM",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "06",'+;
                                '"field": "C8_ITEM",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "07",'+;
                                '"field": "C8_PRODUTO",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "08",'+;
                                '"field": "C8_PRODUTO",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "09",'+;
                                '"field": "C8_FORNECE",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "10",'+;
                                '"field": "C8_FORNECE",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "11",'+;
                                '"field": "C8_LOJA",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "12",'+;
                                '"field": "C8_LOJA",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "13",'+;
                                '"field": "C8_PRECO",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "14",'+;
                                '"field": "C8_PRECO",'+;
                                '"operation": "<="'+;
                            '}'+;
                        '],';
                        + cFiltersCT2
    ElseIf cCodCfg == "0009"
        cFilters := '{'+;
                        '"tabori": ['+;
                            '{'+;
                                '"order": "01",'+;
                                '"field": "C5_EMISSAO",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "02",'+;
                                '"field": "C5_EMISSAO",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "03",'+;
                                '"field": "C5_CLIENTE",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "04",'+;
                                '"field": "C5_CLIENTE",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "05",'+;
                                '"field": "C5_LOJACLI",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "06",'+;
                                '"field": "C5_LOJACLI",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "07",'+;
                                '"field": "C5_VEND1",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "08",'+;
                                '"field": "C5_VEND1",'+;
                                '"operation": "<="'+;
                            '}'+;
                        '],';
                        + cFiltersCT2
    ElseIf cCodCfg == "0010"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "C6_DATFAT",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "C6_DATFAT",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "C6_NUM",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "C6_NUM",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "C6_PRODUTO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "C6_PRODUTO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "C6_CLI",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "C6_CLI",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "C6_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "C6_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "C6_TES",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "C6_CF",'+;
                            '"operation": "IN"'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0011"
        cFilters := '{'+;
                        '"tabori": ['+;
                            '{'+;
                                '"order": "01",'+;
                                '"field": "F2_EMISSAO",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "02",'+;
                                '"field": "F2_EMISSAO",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "03",'+;
                                '"field": "F2_DOC",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "04",'+;
                                '"field": "F2_DOC",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "05",'+;
                                '"field": "F2_SERIE",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "06",'+;
                                '"field": "F2_SERIE",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "07",'+;
                                '"field": "F2_CLIENTE",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "08",'+;
                                '"field": "F2_CLIENTE",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "09",'+;
                                '"field": "F2_LOJA",'+;
                                '"operation": ">="'+;
                            '},'+;
                            '{'+;
                                '"order": "10",'+;
                                '"field": "F2_LOJA",'+;
                                '"operation": "<="'+;
                            '},'+;
                            '{'+;
                                '"order": "11",'+;
                                '"field": "F2_COND",'+;
                                '"operation": "IN"'+;
                            '},'+;
                            '{'+;
                                '"order": "12",'+;
                                '"field": "F2_ESPECIE",'+;
                                '"operation": "IN"'+;
                            '},'+;
                            '{'+;
                                '"order": "13",'+;
                                '"field": "F2_TIPO",'+;
                                '"operation": "IN"'+;
                            '}'+;
                        '],';
                        + cFiltersCT2
    ElseIf cCodCfg == "0012"
        cFilters := '{'+;
                        '"tabori": ['+;
                    '{'+;
                        '"order": "01",'+;
                        '"field": "D2_EMISSAO",'+;
                        '"operation": ">="'+;
                    '},'+;
                    '{'+;
                        '"order": "02",'+;
                        '"field": "D2_EMISSAO",'+;
                        '"operation": "<="'+;
                    '},'+;
                    '{'+;
                        '"order": "03",'+;
                        '"field": "D2_DOC",'+;
                        '"operation": ">="'+;
                    '},'+;
                    '{'+;
                        '"order": "04",'+;
                        '"field": "D2_DOC",'+;
                        '"operation": "<="'+;
                    '},'+;
                    '{'+;
                        '"order": "05",'+;
                        '"field": "D2_SERIE",'+;
                        '"operation": ">="'+;
                    '},'+;
                    '{'+;
                        '"order": "06",'+;
                        '"field": "D2_SERIE",'+;
                        '"operation": "<="'+;
                    '},'+;
                    '{'+;
                        '"order": "07",'+;
                        '"field": "D2_CLIENTE",'+;
                        '"operation": ">="'+;
                    '},'+;
                    '{'+;
                        '"order": "08",'+;
                        '"field": "D2_CLIENTE",'+;
                        '"operation": "<="'+;
                    '},'+;
                    '{'+;
                        '"order": "09",'+;
                        '"field": "D2_LOJA",'+;
                        '"operation": ">="'+;
                    '},'+;
                    '{'+;
                        '"order": "10",'+;
                        '"field": "D2_LOJA",'+;
                        '"operation": "<="'+;
                    '},'+;
                    '{'+;
                        '"order": "11",'+;
                        '"field": "D2_PEDIDO",'+;
                        '"operation": ">="'+;
                    '},'+;
                    '{'+;
                        '"order": "12",'+;
                        '"field": "D2_PEDIDO",'+;
                        '"operation": "<="'+;
                    '},'+;
                    '{'+;
                        '"order": "13",'+;
                        '"field": "D2_COD",'+;
                        '"operation": ">="'+;
                    '},'+;
                    '{'+;
                        '"order": "14",'+;
                        '"field": "D2_COD",'+;
                        '"operation": "<="'+;
                    '},'+;
                    '{'+;
                        '"order": "15",'+;
                        '"field": "D2_LOCAL",'+;
                        '"operation": "IN"'+;
                    '},'+;
                    '{'+;
                        '"order": "16",'+;
                        '"field": "D2_TES",'+;
                        '"operation": "IN"'+;
                    '},'+;
                    '{'+;
                        '"order": "17",'+;
                        '"field": "D2_CF",'+;
                        '"operation": "IN"'+;
                    '},'+;
                    '{'+;
                        '"order": "18",'+;
                        '"field": "D2_SERIE",'+;
                        '"operation": "IN"'+;
                    '}'+;
                '],';
                + cFiltersCT2
    ElseIf cCodCfg == "0013"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "EF_DATA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "EF_DATA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "EF_BANCO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "EF_BANCO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "EF_AGENCIA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "EF_AGENCIA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "EF_CONTA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "EF_CONTA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "EF_NUM",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "EF_NUM",'+;
                            '"operation": "<="'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0014"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "AGH_NUM",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "AGH_NUM",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "AGH_SERIE",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "AGH_SERIE",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "AGH_FORNEC",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "AGH_FORNEC",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "AGH_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "AGH_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "AGH_CONTA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "AGH_CONTA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "AGH_ITEMCT",'+;
                            '"operation": "="'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "AGH_CLVL",'+;
                            '"operation": "="'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0015"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "AGG_PEDIDO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "AGG_PEDIDO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "AGG_FORNEC",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "AGG_FORNEC",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "AGG_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "AGG_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "AGG_CONTA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "AGG_CONTA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "AGG_ITEMCT",'+;
                            '"operation": "="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "AGG_CLVL",'+;
                            '"operation": "="'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0016"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "FIP_DTAVP",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "FIP_DTAVP",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "FIP_NUM",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "FIP_NUM",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "FIP_PREFIX",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "FIP_PREFIX",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "FIP_PARCEL",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "FIP_PARCEL",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "FIP_CLIENT",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "FIP_CLIENT",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "FIP_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "FIP_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "13",'+;
                            '"field": "FIP_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "14",'+;
                            '"field": "FIP_TIPO",'+;
                            '"operation": "IN"'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0017"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "EZ_PREFIXO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "EZ_PREFIXO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "EZ_NUM",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "EZ_NUM",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "EZ_NATUREZ",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "EZ_NATUREZ",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "EZ_CLIFOR",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "EZ_CLIFOR",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "EZ_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "EZ_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "EZ_CCUSTO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "EZ_CCUSTO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "13",'+;
                            '"field": "EZ_CONTA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "14",'+;
                            '"field": "EZ_CONTA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "15",'+;
                            '"field": "EZ_RECPAG",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "16",'+;
                            '"field": "EZ_TIPO",'+;
                            '"operation": "IN"'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0018"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "FIS_DTAVP",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "FIS_DTAVP",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "FIS_NUM",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "FIS_NUM",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "FIS_PREFIX",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "FIS_PREFIX",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "FIS_PARCEL",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "FIS_PARCEL",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "FIS_FORNEC",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "FIS_FORNEC",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "FIS_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "FIS_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "13",'+;
                            '"field": "FIS_TIPO",'+;
                            '"operation": "IN"'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0019"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "EU_CAIXA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "EU_CAIXA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "EU_DTDIGIT",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "EU_DTDIGIT",'+;
                            '"operation": "<="'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    ElseIf cCodCfg == "0020"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "F1_DTDIGIT",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "F1_DTDIGIT",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "F1_DOC",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "F1_DOC",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "F1_FORNECE",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "F1_FORNECE",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "F1_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "F1_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "F1_TIPO",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "F1_ESPECIE",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "F1_VALBRUT",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "F1_VALBRUT",'+;
                            '"operation": "<="'+;
                        '}'+;
                    '],';
                    +  cFiltersCT2
    ElseIf cCodCfg == "0021"
        cFilters := '{'+;
                        '"tabori": ['+;
                        '{'+;
                            '"order": "01",'+;
                            '"field": "F2_EMISSAO",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "02",'+;
                            '"field": "F2_EMISSAO",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "03",'+;
                            '"field": "F2_DOC",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "04",'+;
                            '"field": "F2_DOC",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "05",'+;
                            '"field": "F2_SERIE",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "06",'+;
                            '"field": "F2_SERIE",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "07",'+;
                            '"field": "F2_CLIENTE",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "08",'+;
                            '"field": "F2_CLIENTE",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "09",'+;
                            '"field": "F2_LOJA",'+;
                            '"operation": ">="'+;
                        '},'+;
                        '{'+;
                            '"order": "10",'+;
                            '"field": "F2_LOJA",'+;
                            '"operation": "<="'+;
                        '},'+;
                        '{'+;
                            '"order": "11",'+;
                            '"field": "F2_COND",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "12",'+;
                            '"field": "F2_ESPECIE",'+;
                            '"operation": "IN"'+;
                        '},'+;
                        '{'+;
                            '"order": "13",'+;
                            '"field": "F2_TIPO",'+;
                            '"operation": "IN"'+;
                        '}'+;
                    '],';
                    + cFiltersCT2
    EndIf
   jFilters:FromJson(cFilters)
Return jFilters

Static Function GetCIDFields(cCodCfg as Character, lIDOrigem as Logical)

    Local cIdField := "" as Character

    If cCodCfg == "0001"
        If lIDOrigem
            cIdField := "E1_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0002"
        If lIDOrigem
            cIdField := "E2_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0003"
        If lIDOrigem
            cIdField := "E5_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0004"
        If lIDOrigem
            cIdField := "F1_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0005"
        If lIDOrigem
            cIdField := "D1_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0006"
        If lIDOrigem
            cIdField := "D3_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0007"
        If lIDOrigem
            cIdField := "C7_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0008"
        If lIDOrigem
            cIdField := "C8_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0009"
        If lIDOrigem
            cIdField := "C5_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0010"
        If lIDOrigem
            cIdField := "C6_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0011"
        If lIDOrigem
            cIdField := "F2_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0012"
        If lIDOrigem
            cIdField := "D2_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0013"
        If lIDOrigem
            cIdField := "EF_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0014"
        If lIDOrigem
            cIdField := "AGH_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0015"
        If lIDOrigem
            cIdField := "AGG_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0016"
        If lIDOrigem
            cIdField := "FIP_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0017"
        If lIDOrigem
            cIdField := "EZ_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0018"
        If lIDOrigem
            cIdField := "FIS_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0019"
        If lIDOrigem
            cIdField := "EU_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0020"
        If lIDOrigem
            cIdField := "F1_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    ElseIf cCodCfg == "0021"
        If lIDOrigem
            cIdField := "F2_MSUIDT"
        Else
            cIdField := "CT2_MSUIDT"
        EndIf
    EndIf

Return cIdField

Static Function GetJsonRegMatch(cCodCfg as Character)

    Local jRegMatch := JsonObject():New()
    Local cRegMatch := "" as Character

    If cCodCfg == "0001"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "E1_MSUIDT",'+;
                                        '"ori_link": "E1_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND E1_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'

    ElseIf cCodCfg == "0002"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "E2_MSUIDT",'+;
                                        '"ori_link": "E2_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND E2_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'

    ElseIf cCodCfg == "0003"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "E5_MSUIDT",'+;
                                        '"ori_link": "E5_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND E5_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'

    ElseIf cCodCfg == "0004"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "F1_MSUIDT",'+;
                                        '"ori_link": "F1_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND F1_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0005"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "D1_MSUIDT",'+;
                                        '"ori_link": "D1_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND D1_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'

    ElseIf cCodCfg == "0006"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "D3_MSUIDT",'+;
                                        '"ori_link": "D3_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND D3_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0007"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "C7_MSUIDT",'+;
                                        '"ori_link": "C7_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND C7_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0008"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "C8_MSUIDT",'+;
                                        '"ori_link": "C8_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND C8_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0009"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "C5_MSUIDT",'+;
                                        '"ori_link": "C5_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND C5_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0010"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "C6_MSUIDT",'+;
                                        '"ori_link": "C6_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND C6_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0011"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "F2_MSUIDT",'+;
                                        '"ori_link": "F2_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND F2_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0012"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "D2_MSUIDT",'+;
                                        '"ori_link": "D2_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND D2_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'

    ElseIf cCodCfg == "0013"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "EF_MSUIDT",'+;
                                        '"ori_link": "EF_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND EF_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0014"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "AGH_MSUIDT",'+;
                                        '"ori_link": "AGH_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND AGH_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0015"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "AGG_MSUIDT",'+;
                                        '"ori_link": "AGG_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND AGG_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0016"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "FIP_MSUIDT",'+;
                                        '"ori_link": "FIP_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND FIP_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0017"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "EZ_MSUIDT",'+;
                                        '"ori_link": "EZ_MSUIDT = CV3_RECORI",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_RECDES",'+;
                                        '"condition": "CV3_RECORI <> ' + "' '" + ' AND CV3_RECDES <> ' + "' '" + ' AND EZ_MSUIDT = CV3_RECORI AND CT2_MSUIDT = CV3_RECDES"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0018"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "FIS_MSUIDT",'+;
                                        '"ori_link": "FIS_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND FIS_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0019"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "EU_MSUIDT",'+;
                                        '"ori_link": "EU_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND EU_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0020"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "F1_MSUIDT",'+;
                                        '"ori_link": "F1_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND F1_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    ElseIf cCodCfg == "0021"
        cRegMatch :=    '{'+;
                            '"rules": ['+;
                                '{'+;
                                    '"idrule": "001",'+;
                                    '"name": "Ordem Padrão Sistema",'+;
                                    '"linktable": "CV3",'+;
                                    '"rule": {'+;
                                        '"ori_fields": "F2_MSUIDT",'+;
                                        '"ori_link": "F2_MSUIDT = CV3_IDORIG",'+;
                                        '"des_fields": "CT2_MSUIDT",'+;
                                        '"des_link": "CT2_MSUIDT = CV3_IDDEST",'+;
                                        '"condition": "CV3_IDORIG <> ' + "' '" + ' AND CV3_IDDEST <> ' + "' '" + ' AND F2_MSUIDT = CV3_IDORIG AND CT2_MSUIDT = CV3_IDDEST"'+;
                                    '}'+;
                                '}'+;
                            ']'+;
                        '}'
    EndIf

    jRegMatch:FromJson(cRegMatch)

Return jRegMatch

Static Function GetJsonTotal(cCodCfg as Character)

    Local cTotal := "" as Character
    Local cCT2Total := "" as Character
    Local cCT2TUnion := "" as Character

    Local jTotal := JsonObject():New() as Json

    cCT2Total := '"totaldes": ['+;
                    '{'+;
                        '"label": "'+ STR0051 +'",'+; // "Total a Débito"
                        '"condition": "CT2_DC = ' + "'1'" + ' OR CT2_DC = ' + "'3'" + '",'+;
                        '"total": "CT2_VALOR",'+;
                        '"valid":true,'+;
				        '"fields":"CT2_VALOR"'+;
                    '},'+;
                    '{'+;
                        '"label": "'+ STR0052 +'",'+; //"Total a Crédito"
                        '"condition": "CT2_DC = ' + "'2'" + ' OR CT2_DC = ' + "'3'" + '",'+;
                        '"total": "CT2_VALOR",'+;
                        '"valid":true,'+;
				        '"fields":"CT2_VALOR"'+;
                    '}'+;
                ']'+;
            '}'

    cCT2TUnion := '"totaldes": ['+;
                    '{'+;
                        '"label": "'+ STR0051 +'",'+; // "Total a Débito"
                        '"condition": "CT2_DC = ' + "'1'" + ' OR CT2_DC = ' + "'3'" + '",'+;
                        '"total": "CT2_VALOR",'+;
                        '"valid":false,'+;
				        '"fields":"CT2_VALOR"'+;
                    '},'+;
                    '{'+;
                        '"label": "'+ STR0052 +'",'+; //"Total a Crédito"
                        '"condition": "CT2_DC = ' + "'2'" + ' OR CT2_DC = ' + "'3'" + '",'+;
                        '"total": "CT2_VALOR",'+;
                        '"valid":false,'+;
				        '"fields":"CT2_VALOR"'+;
                    '}'+;
                ']'+;
            '}'

    If cCodCfg == "0001"
        cTotal :=   '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "E1_VALOR",'+;
                                '"valid":true,'+;
				                '"fields":"E1_VALOR"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0002"
        cTotal :=   '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "E2_VALOR",'+;
                                '"valid":true,'+;
				                '"fields":"E2_VALOR"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0003"
        cTotal :=   '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "E5_VALOR",'+;
                                '"valid":true,'+;
				                '"fields":"E5_VALOR"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0004"
        cTotal :=   '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "F1_VALBRUT",'+;
                                '"valid":true,'+;
				                '"fields":"F1_VALBRUT"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0005"
        cTotal :=   '{'+;
                            '"totalori": ['+;
                                '{'+;
                                    '"label": "'+ STR0053 +'",'+; //"Total"
                                    '"total": "D1_TOTAL",'+;
                                    '"valid":true,'+;
				                    '"fields":"D1_TOTAL"'+;
                                '}'+;
                            '],';
                            + cCT2Total

    ElseIf cCodCfg == "0006"
        cTotal :=   '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "D3_CUSTO1",'+;
                                '"valid":true,'+;
				                '"fields":"D3_CUSTO1"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0007"
        cTotal :=   '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "C7_TOTAL",'+;
                                '"valid":true,'+;
				                '"fields":"C7_TOTAL"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0008"
        cTotal :=   '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "C8_TOTAL",'+;
                                '"valid":true,'+;
				                '"fields":"C8_TOTAL"'+;
                            '},'+;
                            '{'+;
                                '"label": "'+ STR0054 +'",'+; //"Total Preços"
                                '"total": "C8_PRECO",'+;
                                '"valid":false,'+;
				                '"fields":"C8_PRECO"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0009"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "C5_FRETE",'+;
                                '"valid":true,'+;
				                '"fields":"C5_FRETE"'+;
                            '}'+;
                        '],';
                        + cCT2Total
    ElseIf cCodCfg == "0010"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "C6_VALOR",'+;
                                '"valid":true,'+;
				                '"fields":"C6_VALOR"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0011"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "F2_VALBRUT",'+;
                                '"valid":true,'+;
				                '"fields":"F2_VALBRUT"'+;
                            '},'+;
                            '{'+;
                                '"label": "'+ STR0055 +'",'+; //"Total Mercadorias"
                                '"total": "F2_VALMERC",'+;
                                '"valid":false,'+;
				                '"fields":"F2_VALMERC"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0012"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "D2_TOTAL",'+;
                                '"valid":true,'+;
				                '"fields":"D2_TOTAL"'+;
                            '},'+;
                            '{'+;
                                '"label": "'+ STR0056 +'",'+; //"Total Vendas"
                                '"total": "D2_PRCVEN",'+;
                                '"valid":false,'+;
                                '"fields":"D2_PRCVEN"'+;
                            '},'+;
                            '{'+;
                                '"label": "'+ STR0057 +'",'+; //"Quantidade Total"
                                '"total": "D2_QUANT",'+;
                                '"valid":false,'+;
				                '"fields":"D2_QUANT"'+;
                           '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0013"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "EF_VALOR",'+;
                                '"valid":true,'+;
				                '"fields":"EF_VALOR"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0014"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "AGH_CUSTO1",'+;
                                '"valid":true,'+;
				                '"fields":"AGH_CUSTO1"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0015"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "AGG_CUSTO1",'+;
                                '"valid":true,'+;
				                '"fields":"AGG_CUSTO1"'+;
                            '}'+;
                        '],';
                        + cCT2Total
    ElseIf cCodCfg == "0016"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "FIP_VLRAVP",'+;
                                '"valid":true,'+;
				                '"fields":"FIP_VLRAVP"'+;
                            '}'+;
                        '],';
                        + cCT2Total
    ElseIf cCodCfg == "0017"
        cTotal := '{'+;
                       ' "totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "EZ_VALOR",'+;
                                '"valid":true,'+;
				                '"fields":"EZ_VALOR"'+;
                            '}'+;
                        '],';
                        + cCT2Total

    ElseIf cCodCfg == "0018"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "FIS_VLRAVP",'+;
                                '"valid":true,'+;
				                '"fields":"FIS_VLRAVP"'+;
                            '}'+;
                        '],';
                        + cCT2Total
    ElseIf cCodCfg == "0019"
        cTotal := '{'+;
                    '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0053 +'",'+; //"Total"
                                '"total": "EU_VALOR",'+;
                                '"valid":true,'+;
				                '"fields":"EU_VALOR"'+;
                            '}'+;
                        '],';
                        + cCT2Total
    ElseIf cCodCfg == "0020"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0058 +'",'+; //"Total SF1"
                                '"total": "F1_VALBRUT",'+;
                                '"valid":false,'+;
				                '"fields":"F1_VALBRUT"'+;
                            '},'+;
                            '{'+;
                                '"label": "'+ STR0059 +'",'+; //"Total SD1"
                                '"total": "D1_TOTAL",'+;
                                '"valid":false,'+;
				                '"fields":"D1_TOTAL"'+;
                            '}'+;
                        '],';
                        + cCT2TUnion

    ElseIf cCodCfg == "0021"
        cTotal := '{'+;
                        '"totalori": ['+;
                            '{'+;
                                '"label": "'+ STR0060 +'",'+; //"Total SF2"
                                '"total": "F2_VALBRUT",'+;
                                '"valid":false,'+;
				                '"fields":"F2_VALBRUT"'+;
                            '},'+;
                            '{'+;
                                '"label": "'+ STR0061 +'",'+; //"Total SD2"
                                '"total": "D2_TOTAL",'+;
                                '"valid":false,'+;
				                '"fields":"D2_TOTAL"'+;
                            '}'+;
                        '],';
                        + cCT2TUnion

    EndIf

    jTotal:FromJson(cTotal)

Return jTotal

Static Function GetJsonUnion(cCodCfg as Character)
    Local cUnion := "" as Character

    Local jUnion := JsonObject():New()

    If (cCodCfg == "0020")
        cUnion := '{'+;
                        '"unionori": [{'+;
                        '"table":"SD1",'+;
                        '"cpoid":"D1_MSUIDT",'+;
                        '"matchorder":"F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, D1_COD",'+;
                        '"fields":['+;
                            '{"cpopai":"F1_FILIAL","cpofil":"D1_FILIAL"},'+;
                            '{"cpopai":"F1_DOC","cpofil":"D1_DOC"},'+;
                            '{"cpopai":"F1_SERIE","cpofil":"D1_SERIE"},'+;
                            '{"cpopai":"F1_FORNECE","cpofil":"D1_FORNECE"},'+;
                            '{"cpopai":"F1_LOJA","cpofil":"D1_LOJA"},'+;
                            '{"cpopai":"F1_DTDIGIT","cpofil":"D1_DTDIGIT"},'+;
                            '{"cpopai":"F1_VALBRUT","cpofil":""},'+;
                            '{"cpopai":"","cpofil":"D1_COD"},'+;
                            '{"cpopai":"","cpofil":"D1_TOTAL"},'+;
                            '{"cpopai":"","cpofil":"D1_ICMSRET"},'+;
                            '{"cpopai":"","cpofil":"D1_VALIPI"},'+;
                            '{"cpopai":"","cpofil":"D1_VALDESC"}'+;
                        ']'+;
                    '}]'+;
                '}'
    ElseIf (cCodCfg == "0021")
        cUnion := '{'+;
                        '"unionori": [{'+;
                        '"table":"SD2",'+;
                        '"cpoid":"D2_MSUIDT",'+;
                        '"matchorder":"F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, D2_COD",'+;
                        '"fields":['+;
                            '{"cpopai":"F2_FILIAL","cpofil":"D2_FILIAL"},'+;
                            '{"cpopai":"F2_DOC","cpofil":"D2_DOC"},'+;
                            '{"cpopai":"F2_SERIE","cpofil":"D2_SERIE"},'+;
                            '{"cpopai":"F2_CLIENTE","cpofil":"D2_CLIENTE"},'+;
                            '{"cpopai":"F2_LOJA","cpofil":"D2_LOJA"},'+;
                            '{"cpopai":"F2_EMISSAO","cpofil":"D2_EMISSAO"},'+;
                            '{"cpopai":"F2_VALBRUT","cpofil":""},'+;
                            '{"cpopai":"","cpofil":"D2_COD"},'+;
                            '{"cpopai":"","cpofil":"D2_TOTAL"},'+;
                            '{"cpopai":"","cpofil":"D2_ICMSRET"},'+;
                            '{"cpopai":"","cpofil":"D2_VALIPI"},'+;
                            '{"cpopai":"","cpofil":"D2_DESCON"}'+;
                        ']'+;
                    '}]'+;
                '}'
    EndIf

    jUnion:FromJson(cUnion)
Return jUnion

Static Function SaveJsonOnQLB(jsonSave as Json, lJaExisteQLB as Logical)

    QLB->(dbSetOrder(1))

    RecLock("QLB", !lJaExisteQLB)
    QLB->QLB_FILIAL := xFilial("QLB")
    QLB->QLB_CODCFG := jsonSave["codcfg"]
    QLB->QLB_DESCFG := jsonSave["descfg"]
    QLB->QLB_TABORI := jsonSave["tabori"]
    QLB->QLB_TABDES := jsonSave["tabdes"]
    QLB->QLB_FIELDS := ValidFields(jsonSave["fields"]):toJson()
    QLB->QLB_FILTER := jsonSave["filter"]:toJson()
    QLB->QLB_CIDORI := jsonSave["cidori"]
    QLB->QLB_CIDDES := jsonSave["ciddes"]
    QLB->QLB_DESCOR := jsonSave["descor"]
    QLB->QLB_DESCDE := jsonSave["descde"]
    QLB->QLB_REGMAT := jsonSave["regmat"]:toJson()
    QLB->QLB_TOTAL  := jsonSave["total"]:toJson()
    QLB->QLB_VERSAO := jsonSave["version"]

    If jsonSave["union"] <> nil
        QLB->QLB_TABGRP  := jsonSave["union"]:toJson()
    EndIf

    QLB->(MsUnlock())

Return

/*{Protheus.doc} ValidFields
Validacao da existência de campos para adicionar na QLB

@author: TOTVS
@since 06/03/2023
@version 1.0
*/
Static Function ValidFields(jFields)
    Local nI := 0 as Numeric
    Local nx := 0 as Numeric
    Local jReturn := JsonObject():new() as Json
    Local aFields := {} as Array
    Local aReturn := {} as Array

    If jFields <> Nil .And. ValType(jFields) == "J"
        aFields := jFields:GetNames()
        If aFields <> Nil .And. ValType(aFields) == "A"
            For nI := 1 To Len(aFields)
                If jFields[aFields[nI]] <> Nil
                    aReturn := {}
                    For nX := 1 To Len(jFields[aFields[nI]])
                        If ValType(jFields[aFields[nI]][nX]) == "C" .And. Len(FWSX3Util():GetFieldStruct(jFields[aFields[nI]][nX])) > 0
                            aAdd(aReturn, jFields[aFields[nI]][nX])
                        EndIf
                    Next nX
                    jReturn[aFields[nI]] := aClone(aReturn)
                EndIf
            Next nI
        EndIf
    EndIf

    FwFreeArray(aFields)
    FwFreeArray(aReturn)
Return jReturn

/*{Protheus.doc} GetJsonVersion
Retorna a versão das configurações de conciliação

@author: TOTVS
@since 19/04/2023
@version 1.0
*/
Static Function GetJsonVersion(cCodCfg as Character)

    Local cVersion := "" as Character

    If cCodCfg == "0001"
        cVersion := "20230427"
    ElseIf cCodCfg == "0002"
        cVersion := "20230427"
    ElseIf cCodCfg == "0003"
        cVersion := "20250306"
    ElseIf cCodCfg == "0004"
        cVersion := "20230427"
    ElseIf cCodCfg == "0005"
        cVersion := "20230427"
    ElseIf cCodCfg == "0006"
        cVersion := "20230427"
    ElseIf cCodCfg == "0007"
        cVersion := "20230427"
    ElseIf cCodCfg == "0008"
        cVersion := "20230427"
    ElseIf cCodCfg == "0009"
        cVersion := "20230427"
    ElseIf cCodCfg == "0010"
        cVersion := "20230427"
    ElseIf cCodCfg == "0011"
        cVersion := "20230427"
    ElseIf cCodCfg == "0012"
        cVersion := "20230427"
    ElseIf cCodCfg == "0013"
        cVersion := "20230427"
    ElseIf cCodCfg == "0014"
        cVersion := "20230606"
    ElseIf cCodCfg == "0015"
        cVersion := "20230427"
    ElseIf cCodCfg == "0016"
        cVersion := "20230606"
    ElseIf cCodCfg == "0017"
        cVersion := "20230427"
    ElseIf cCodCfg == "0018"
        cVersion := "20230606"
    ElseIf cCodCfg == "0019"
        cVersion := "20230427"
    ElseIf cCodCfg == "0020"
        cVersion := "20230817"
    ElseIf cCodCfg == "0021"
        cVersion := "20230817"
    EndIf

Return cVersion

/*/{Protheus.doc} CheckUpdate
    Verifica se há necessidade de atualizar a configuração
    @type  Static
    @author caio
    @since 19/04/2023
    @version 12.1.2210
    @param
        cCodCfg, Character, Codigo de configuração
        cVersion, Character, Codigo de versão
    @return
        lRet, Logico, Se deve ou não atualizar
    /*/
Static Function CheckUpdate(cCodCfg as Character, cVersion as Character, lFound as Logical)

    Local lRet      := .T. as Logical

    QLB->(dbSetOrder(1))
    lFound := (QLB->(MsSeek(xFilial("QLB")+cCodCfg)))

    //Se encontrar, confiro se a versão em QLB é menor que a versão do Json no fonte.
    If lFound
        // Se sim, devo atualizar a QLB
        If Empty(QLB->(QLB_VERSAO)) .Or. QLB->(QLB_VERSAO) < cVersion
            lRet := .T.
        Else
        //Se não, não devo atualizar
            lRet := .F.
        EndIf
    Else
        //Se não encontrar, deve atualizar (Incluir configuração)
        lRet := .T.
    EndIf

Return lRet


/*/{Protheus.doc} DeleteEmptyQLB
    Função que deleta configurações criadas incorretamente com todos os campos em branco
    @type  Static
    @author totvs
    @since 12/07/2023
    @version 12.1.2210
    @return
        vazio
    /*/
Static Function DeleteEmptyQLB()

    QLB->(dbSetOrder(1))
    If( QLB->( DbSeek( xFilial("QLB") + Space( TamSX3( "QLB_CODCFG" )[1] ) ) ) ) // DbSeek em uma configuração com o codcfg em branco
        RecLock("QLB", .F.)
        QLB->(DbDelete())
        QLB->(MsUnlock())
    EndIf

Return

