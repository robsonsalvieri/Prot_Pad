#INCLUDE "TOTVS.CH"
#INCLUDE "FWLIBVERSION.CH"
#include 'Fileio.CH'

/*/{Protheus.doc} QLTMetrics
Envia Métrica em Thread
@author brunno.costa
@since 13/02/2023
@version P12.1.2310
@param 01 - cEmpAux   , caracter, grupo de empresa para preparação do ambiente
@param 02 - cFilAux   , caracter, filial para preparação do ambiente
@param 03 - cSiglaModu, caracter, sigla do módulo para preparação do ambiente
@param 04 - nOpc      , caracter, id interno da métrica para disparo:
                    nOpc == 1 Self:enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco()
/*/

Main Function QLTMetrics(cEmpAux, cFilAux, cSiglaModu, nOpc)

    Local lAmbiente     := .F.
    Local lSemInterface := .T.
    Local oSelf         := Nil

    Default nOpc        := 0

    RPCSetType(3)
    lAmbiente := RpcSetEnv(cEmpAux, cFilAux,,,cSiglaModu)

    If lAmbiente
        oSelf := QLTMetrics():New(lSemInterface)

        If nOpc == 1
            oSelf:enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco()
        ElseIf nOpc == 2
            oSelf:enviaMetricaPercentualUsoOtimizacaoTelasQIPComDadosDoBanco()
        EndIf
        RpcClearEnv()
    EndIf

Return 

/*/{Protheus.doc} QLTMetrics
Classe de Controle do Envio de Métricas dos Módulos de Qualidade
@type  Classe
@author brunno.costa
@since 13/02/2023
@version P12.1.2310
/*/
CLASS QLTMetrics FROM LongNameClass
    
    DATA cBanco        as String
    DATA lSemInterface as Logical
    DATA lSincrono     as Logical

    //Métodos públicos
    METHOD new(lSemInterface) Constructor
    METHOD abreThreadExtracaoBancoEEnvioMetricaPercentualUsoOtimizacaoTelasQIPComDadosDoBanco()
    METHOD abreThreadExtracaoBancoEEnvioMetricaQuantidadeResultadosEnsaiosDigitadosQIP()
    METHOD enviaMetricaNaoConformidadeAberta(cModulo)
    METHOD enviaMetricaPlanoDeAcaoAberto(cModulo)
    METHOD enviaMetricaQuantidadeDocumentosLidosQDO(cRotina, cQAA_TPWORD, cTipoDoc)
    METHOD enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIP(cRotina, nResultados)

    //Métodos Internos
	METHOD checaPrimeiroEnvioSincrono(cChave)
    METHOD confirmaEnvioSemInterfaceSincrono(cUsuario, cIDModulo, cSubRotina)
    METHOD enviaMetrica(cIDModulo, cRotina, cSubRotina, cIDMetric, nResultados)
    METHOD enviaMetricaAssincrona(cRotina, cSubRotina, cIDMetric, nResultados)
    METHOD enviaMetricaPercentualUsoOtimizacaoTelasQIPComDadosDoBanco()
    METHOD enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco()
    METHOD enviaMetricaSincrona(cRotina, cSubRotina, cIDMetric, nResultados)
    METHOD retornaPercentualUsoRoteiroEOperacaoUnicosGenericos()
    METHOD retornaPercentualUsoRoteiroEOperacaoUnicosNaoGenericos()
    METHOD retornaPercentualUsoRoteiroUnicoGenerico()
    METHOD retornaPercentualUsoRoteiroUnicoNaoGenerico()
    METHOD retornaQuantidadeResultadosEnsaiosDigitadosQIPNoBanco()
    METHOD retornaTipoExibicaoDocumentoDoUsuario()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@since 13/02/2023
@version P12.1.2310
@param 01 - lSemInterface, lógico, indica execução sem interface
@return Self, objeto, instância da classe
/*/
METHOD new(lSemInterface) CLASS QLTMetrics
    Default lSemInterface  := IsBlind()
    Self:lSincrono     := .F.
    Self:lSemInterface := lSemInterface
    Self:cBanco        := Upper(TcgetDB())
Return Self

/*/{Protheus.doc} enviaMetrica
Envia Métrica pela Regra Padrão de Qualidade: primeiro envio síncrono, demais assíncronos semanais.
@since 13/02/2023
@version P12.1.2310
@param 01 - cIDModulo  , caracter, código do módulo
@param 02 - cRotina    , caracter, indica a rotina em execução
@param 03 - cSubRotina , caracter, indica a subrotina para detalhamento da métrica
@param 04 - cIDMetric  , caracter, indica o ID da Métrica
@param 05 - nResultados, numérico, indica a quantidade de resultados para registro da métrica
/*/
METHOD enviaMetrica(cIDModulo, cRotina, cSubRotina, cIDMetric, nResultados) CLASS QLTMetrics
    //If Self:checaPrimeiroEnvioSincrono(cIDMetric + "_" + cSubRotina)
    //    Self:enviaMetricaSincrona(cRotina, cSubRotina, cIDMetric, nResultados)
    //Else
        Self:enviaMetricaAssincrona(cRotina, cSubRotina, cIDMetric, nResultados)
    //EndIf
    //Self:confirmaEnvioSemInterfaceSincrono(Nil, cIDModulo, cSubRotina)
Return

/*/{Protheus.doc} enviaMetricaSincrona
Envia Métrica de forma Síncrona
@since 13/02/2023
@version P12.1.2310
@param 01 - cRotina    , caracter, indica a rotina em execução
@param 02 - cSubRotina , caracter, indica a subrotina para detalhamento da métrica
@param 03 - cIDMetric  , caracter, indica o ID da Métrica
@param 04 - nResultados, numérico, indica a quantidade de resultados para registro da métrica
/*/
METHOD enviaMetricaSincrona(cRotina, cSubRotina, cIDMetric, nResultados) CLASS QLTMetrics

    Local cBkpRotina := Nil

     If FwLibVersion() >= "20200727"
        cSubRotina := Lower(cSubRotina)
        cBkpRotina := FunName()
        SetFunName(cRotina)
        FWMetrics():addMetrics(cSubRotina, {{cIDMetric, nResultados }} )
        SetFunName(cBkpRotina)
    EndIf

Return

/*/{Protheus.doc} enviaMetricaAssincrona
Envia Métrica de Forma Assíncrona - Semanal
@since 13/02/2023
@version P12.1.2310
@param 01 - cRotina    , caracter, indica a rotina em execução
@param 02 - cSubRotina , caracter, indica a subrotina para detalhamento da métrica
@param 03 - cIDMetric  , caracter, indica o ID da Métrica
@param 04 - nResultados, numérico, indica a quantidade de resultados para registro da métrica
/*/
METHOD enviaMetricaAssincrona(cRotina, cSubRotina, cIDMetric, nResultados) CLASS QLTMetrics

    Local dDataEnvio := Nil

    If FwLibVersion() >= "20210517" .and. !("|"+Self:cBanco+"|" $ "|OPENEDGE|INFORMIX|DB2|")
        cSubRotina := Lower(cSubRotina)
        dDataEnvio := LastDayWeek(Date())
        FwCustomMetrics():setSumMetric(cSubRotina, cIDMetric, nResultados, dDataEnvio, /*nLapTime*/, cRotina)
    EndIf

Return


/*/{Protheus.doc} enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIP
Envia Métrica Quantidade de Resultados Ensaios Digitados do QIP por Rotina e Quantidade
@since 13/02/2023
@version P12.1.2310
@param 01 - cRotina    , caracter, indica a rotina em execução
@param 02 - nResultados, numérico, indica a quantidade de resultados para registro da métrica
/*/
METHOD enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIP(cRotina, nResultados) CLASS QLTMetrics

    Local cIDMetric   := "gestao-da-qualidade-protheus_quantidade-de-resultados-de-ensaios-digitados-no-modulo-de-inspecao-de-processos_total"
    Local cIDModulo   := "25"
    Local cSubRotina  := "protheus_sigaqip_"
    Local cSufPRAPONT := ""
    Local cSufQINSPEC := ""
    Local cSufQIPMAT  := ""

    Default cRotina  := ""

    Self:new(.F.)
    cSufQIPMAT  := "MV_QIPMAT_"  + AllTrim(    SuperGetMV("MV_QIPMAT" , .F., "N"))
    cSufQINSPEC := "MV_QINSPEC_" + AllTrim(    SuperGetMV("MV_QINSPEC", .F., "2"))
    cSufPRAPONT := "MV_PRAPONT_" + AllTrim(Str(SuperGetMV("MV_PRAPONT", .F., 2 )))

    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "total_default"    , cIDMetric, nResultados)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "rotina_" + cRotina, cIDMetric, nResultados)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufQIPMAT         , cIDMetric, nResultados)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufQINSPEC        , cIDMetric, nResultados)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufPRAPONT        , cIDMetric, nResultados)

Return

/*/{Protheus.doc} abreThreadExtracaoBancoEEnvioMetricaQuantidadeResultadosEnsaiosDigitadosQIP
Abre Thread para Envio da Métrica Quantidade de Resultados Ensaios Digitados no QIP baseados no Volume de Dados do Banco de Dados
@since 13/02/2023
@version P12.1.2310
/*/
METHOD abreThreadExtracaoBancoEEnvioMetricaQuantidadeResultadosEnsaiosDigitadosQIP() CLASS QLTMetrics
    StartJob("QLTMetrics" , GetEnvServer() , .F. , cEmpAnt, cFilAnt, "QIP", 1) //nOpc==1 -> enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco
Return

/*/{Protheus.doc} abreThreadExtracaoBancoEEnvioMetricaPercentualUsoOtimizacaoTelasQIPComDadosDoBanco
Abre Thread para Envio da Métrica Percentual de Uso das Otimizações de Tela do QIP
@since 15/08/2023
@version P12.1.2310
/*/
METHOD abreThreadExtracaoBancoEEnvioMetricaPercentualUsoOtimizacaoTelasQIPComDadosDoBanco() CLASS QLTMetrics
    StartJob("QLTMetrics" , GetEnvServer() , .F. , cEmpAnt, cFilAnt, "QIP", 2) //nOpc==2 -> enviaMetricaPercentualUsoOtimizacaoTelasQIPComDadosDoBanco
Return

/*/{Protheus.doc} enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco
Envia da Métrica Quantidade de Resultados Ensaios Digitados no QIP baseados no Volume de Dados do Banco de Dados
@since 13/02/2023
@version P12.1.2310
/*/
METHOD enviaMetricaQuantidadeResultadosEnsaiosDigitadosQIPComDadosDoBanco() CLASS QLTMetrics

    Local cIDMetric   := "gestao-da-qualidade-protheus_quantidade-de-resultados-de-ensaios-digitados-no-modulo-de-inspecao-de-processos_total"
    Local cIDModulo   := "25"
    Local cRotina     := "QIPLOAD"
    Local cSubRotina  := "protheus_sigaqip_"
    Local cSufPRAPONT := ""
    Local cSufQINSPEC := ""
    Local cSufQIPMAT  := ""
    Local nResultados := 0
    Local oQLTManager := Nil

    If FindClass("QLTQueryManager")
	    oQLTManager := QLTQueryManager():New()
        If oQLTManager:confirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "QLTMetrics_QIPLOAD_M", Nil, 1, .T.)
            Self:new(.F.)
            cSufQIPMAT  := "MV_QIPMAT_"  + AllTrim(    SuperGetMV("MV_QIPMAT" , .F., "N"))
            cSufQINSPEC := "MV_QINSPEC_" + AllTrim(    SuperGetMV("MV_QINSPEC", .F., "2"))
            cSufPRAPONT := "MV_PRAPONT_" + AllTrim(Str(SuperGetMV("MV_PRAPONT", .F., 2 )))

            nResultados := Self:retornaQuantidadeResultadosEnsaiosDigitadosQIPNoBanco()
            Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "rotina_" + cRotina, cIDMetric, nResultados)
            Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufQIPMAT         , cIDMetric, nResultados)
            Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufQINSPEC        , cIDMetric, nResultados)
            Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + cSufPRAPONT        , cIDMetric, nResultados)
        EndIf
    EndIf
Return

/*/{Protheus.doc} retornaQuantidadeResultadosEnsaiosDigitadosQIPNoBanco
Retorna quantidade de resultados de ensaios digitados no banco de dados do grupo de empresas
@since 13/02/2023
@version P12.1.2310
@return nResultados, numérico, quantidade de resultados QPQ e QPS existentes na base do cliente (indiferente a filial)
/*/
METHOD retornaQuantidadeResultadosEnsaiosDigitadosQIPNoBanco() CLASS QLTMetrics

    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
    Local nResultados := 0

    cQuery += " SELECT QTDQPQ + QTDQPS AS TOTAL "
    cQuery += " FROM  "

    cQuery += 	" (SELECT COUNT(*) QTDQPQ "
    cQuery += 	" FROM " + RetSQLName("QPQ")
    cQuery += 	" WHERE D_E_L_E_T_= ' ' "
    cQuery += 	" AND QPQ_FILIAL = '" + xFilial("QPQ") + "') QPQ, "

    cQuery += 	" (SELECT COUNT(*) QTDQPS "
    cQuery += 	" FROM "+RetSQLName("QPS")
    cQuery += 	" WHERE D_E_L_E_T_= ' ' "
    cQuery += 	" AND QPS_FILIAL = '" + xFilial("QPS") + "') QPS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DBGotop())
	If (cAliasQry)->(!EOF())
        nResultados := (cAliasQry)->TOTAL
    EndIf
    (cAliasQry)->(DbCloseArea())
    
Return nResultados

/*/{Protheus.doc} enviaMetricaPercentualUsoOtimizacaoTelasQIPComDadosDoBanco
Envia da Métrica Percentual de Uso das Otimizações de Tela do QIP
@since 15/08/2023
@version P12.1.2310
/*/
METHOD enviaMetricaPercentualUsoOtimizacaoTelasQIPComDadosDoBanco() CLASS QLTMetrics

    Local cIDMetric   := "gestao-de-qualidade-protheus_uso-otimizacao-telas_total"
    Local cIDModulo   := "25"
    Local cRotina     := "QIPLOAD"
    Local cSufQIPOPEP := ""
    Local nResults1   := 1
    Local nResults2   := 1
    Local nResults3   := 1
    Local nResults4   := 1
    Local oQLTManager := Nil

    If FindClass("QLTQueryManager")
	    oQLTManager := QLTQueryManager():New()
        If oQLTManager:confirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "QLTMetrics_QIPLOAD_PM", Nil, 1, .T.)
            Self:new(.F.)
            cSufQIPOPEP  := "pep_"  + AllTrim(SuperGetMV("MV_QIPOPEP" , .F., "2"))

            nResults1 := Self:retornaPercentualUsoRoteiroUnicoNaoGenerico()
            nResults2 := Self:retornaPercentualUsoRoteiroEOperacaoUnicosNaoGenericos()
            nResults3 := Self:retornaPercentualUsoRoteiroUnicoGenerico()
            nResults4 := Self:retornaPercentualUsoRoteiroEOperacaoUnicosGenericos()

            Self:enviaMetrica(cIDModulo, cRotina, cSufQIPOPEP + "_perc_unico_roteiro_nao_generico"             , cIDMetric, nResults1)
            Self:enviaMetrica(cIDModulo, cRotina, cSufQIPOPEP + "_perc_unicos_roteiro_e_operacao_nao_genericos", cIDMetric, nResults2)
            Self:enviaMetrica(cIDModulo, cRotina, cSufQIPOPEP + "_perc_unico_roteiro_generico"                 , cIDMetric, nResults3)
            Self:enviaMetrica(cIDModulo, cRotina, cSufQIPOPEP + "_perc_unicos_roteiro_e_operacao_genericos"    , cIDMetric, nResults4)
        EndIf
    EndIf
Return

/*/{Protheus.doc} retornaPercentualUsoRoteiroUnicoNaoGenerico
Retorna percentual do uso de roteiros únicos e não genéricos na base
@since 15/08/2023
@version P12.1.2310
@return nResultados, numérico, quantidade de resultados QPQ e QPS existentes na base do cliente (indiferente a filial)
/*/
METHOD retornaPercentualUsoRoteiroUnicoNaoGenerico() CLASS QLTMetrics

    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
    Local nResultados := 0

    cQuery += " SELECT ROTEIROS, ROTEIROS_UNICOS "
    cQuery += " FROM (SELECT COUNT(QQK_CODIGO) ROTEIROS "
    cQuery +=       " FROM " + RetSQLName("QQK")
    cQuery +=       " WHERE (D_E_L_E_T_ = ' ')) CONTAGEM_TOTAL, "
    cQuery +=      " (SELECT COALESCE(SUM(ROTEIROS_UNICOS), 0) ROTEIROS_UNICOS "
    cQuery +=       " FROM (SELECT COUNT(QQK_CODIGO) ROTEIROS_UNICOS "
    cQuery +=             " FROM (SELECT DISTINCT QQK_PRODUT, QQK_REVIPR, QQK_CODIGO "
    cQuery +=                    " FROM " + RetSQLName("QQK")
    cQuery +=                    " WHERE (D_E_L_E_T_ = ' ') AND (QQK_CODIGO <> '**') ) ROTEIROS "
    cQuery +=             " GROUP BY QQK_PRODUT, QQK_REVIPR "
    cQuery +=             " HAVING   (COUNT(QQK_CODIGO) = 1)) ROTEIROS_UNICOS) SOMA_UNICOS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DBGotop())
	If (cAliasQry)->(!EOF())
        nResultados := Round((cAliasQry)->ROTEIROS_UNICOS / (cAliasQry)->ROTEIROS, 2)
    EndIf
    (cAliasQry)->(DbCloseArea())
    
Return nResultados

/*/{Protheus.doc} retornaPercentualUsoRoteiroEOperacaoUnicosNaoGenericos
Retorna percentual do uso de roteiros e operações únicos e não genéricos na base
@since 15/08/2023
@version P12.1.2310
@return nResultados, numérico, quantidade de resultados QPQ e QPS existentes na base do cliente (indiferente a filial)
/*/
METHOD retornaPercentualUsoRoteiroEOperacaoUnicosNaoGenericos() CLASS QLTMetrics

    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
    Local nResultados := 0

    cQuery += " SELECT OPERACOES, OPERACOES_UNICAS "
    cQuery +=   " FROM (SELECT COUNT(QQK_OPERAC) OPERACOES "
    cQuery +=           " FROM " + RetSQLName("QQK")
    cQuery +=          " WHERE (D_E_L_E_T_ = ' ')) CONTAGEM_TOTAL, "
    cQuery +=        " (SELECT COALESCE(SUM(OPERACOES_UNICAS), 0) OPERACOES_UNICAS "
    cQuery +=           " FROM (SELECT QQK_PRODUT, QQK_REVIPR, QQK_CODIGO, COUNT(QQK_OPERAC) OPERACOES_UNICAS "
    cQuery +=                   " FROM " + RetSQLName("QQK")
    cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') AND (QQK_CODIGO <> '**') AND (QQK_OPERAC <> '**') "
    cQuery +=               " GROUP BY QQK_PRODUT, QQK_REVIPR, QQK_CODIGO "
    cQuery +=                 " HAVING COUNT(CONCAT(QQK_CODIGO, QQK_OPERAC)) = 1) CONTAGEM_UNICAS "
    cQuery +=             " INNER JOIN "
    cQuery +=                " (SELECT QQK_PRODUT, QQK_REVIPR, COUNT(QQK_CODIGO) ROTEIROS_UNICOS "
    cQuery +=                   " FROM " + RetSQLName("QQK")
    cQuery +=                  " WHERE (D_E_L_E_T_ = ' ') "
    cQuery +=               " GROUP BY QQK_PRODUT, QQK_REVIPR "
    cQuery +=                 " HAVING (COUNT(QQK_CODIGO) = 1)) CONTAGEM_UNICOS "
    cQuery +=                     " ON CONTAGEM_UNICAS.QQK_PRODUT = CONTAGEM_UNICOS.QQK_PRODUT "
    cQuery +=                    " AND CONTAGEM_UNICAS.QQK_REVIPR = CONTAGEM_UNICOS.QQK_REVIPR "
    cQuery +=          ") SOMA_UNICAS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DBGotop())
	If (cAliasQry)->(!EOF())
        nResultados := Round((cAliasQry)->OPERACOES_UNICAS / (cAliasQry)->OPERACOES, 2)
    EndIf
    (cAliasQry)->(DbCloseArea())
    
Return nResultados

/*/{Protheus.doc} retornaPercentualUsoRoteiroUnicoGenerico
Retorna percentual do uso de roteiros únicos e genéricos na base
@since 15/08/2023
@version P12.1.2310
@return nResultados, numérico, quantidade de resultados QPQ e QPS existentes na base do cliente (indiferente a filial)
/*/
METHOD retornaPercentualUsoRoteiroUnicoGenerico() CLASS QLTMetrics

    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
    Local nResultados := 0

    cQuery += " SELECT ROTEIROS, ROTEIROS_UNICOS "
    cQuery += " FROM (SELECT COUNT(QQK_CODIGO) ROTEIROS "
    cQuery +=       " FROM " + RetSQLName("QQK")
    cQuery +=       " WHERE (D_E_L_E_T_ = ' ')) CONTAGEM_TOTAL, "
    cQuery +=      " (SELECT COALESCE(SUM(ROTEIROS_UNICOS), 0) ROTEIROS_UNICOS "
    cQuery +=       " FROM (SELECT COUNT(QQK_CODIGO) ROTEIROS_UNICOS "
    cQuery +=             " FROM (SELECT DISTINCT QQK_PRODUT, QQK_REVIPR, QQK_CODIGO "
    cQuery +=                    " FROM " + RetSQLName("QQK")
    cQuery +=                    " WHERE (D_E_L_E_T_ = ' ') AND (QQK_CODIGO = '**') ) ROTEIROS "
    cQuery +=             " GROUP BY QQK_PRODUT, QQK_REVIPR "
    cQuery +=             " HAVING   (COUNT(QQK_CODIGO) = 1)) ROTEIROS_UNICOS) SOMA_UNICOS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DBGotop())
	If (cAliasQry)->(!EOF())
        nResultados := Round((cAliasQry)->ROTEIROS_UNICOS / (cAliasQry)->ROTEIROS, 2)
    EndIf
    (cAliasQry)->(DbCloseArea())
    
Return nResultados

/*/{Protheus.doc} retornaPercentualUsoRoteiroEOperacaoUnicosGenericos
Retorna percentual do uso de roteiros e operações únicos e genéricos na base
@since 15/08/2023
@version P12.1.2310
@return nResultados, numérico, quantidade de resultados QPQ e QPS existentes na base do cliente (indiferente a filial)
/*/
METHOD retornaPercentualUsoRoteiroEOperacaoUnicosGenericos() CLASS QLTMetrics

    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
    Local nResultados := 0

    cQuery += " SELECT OPERACOES, OPERACOES_UNICAS "
    cQuery +=   " FROM ( SELECT COUNT(QQK_OPERAC) AS OPERACOES "
    cQuery +=            " FROM " + RetSQLName("QQK")
    cQuery +=           " WHERE D_E_L_E_T_ = ' ' ) CONTAGEM_TOTAL, "
    cQuery +=        " ( SELECT COALESCE(SUM(OPERACOES_UNICAS), 0) AS OPERACOES_UNICAS "
    cQuery +=            " FROM ( SELECT QQK_PRODUT, QQK_REVIPR, QQK_CODIGO, COUNT(QQK_OPERAC) AS OPERACOES_UNICAS "
    cQuery +=                     " FROM " + RetSQLName("QQK")
    cQuery +=                    " WHERE D_E_L_E_T_ = ' ' AND QQK_CODIGO = '**' AND QQK_OPERAC = '**' "
    cQuery +=                 " GROUP BY QQK_PRODUT, QQK_REVIPR, QQK_CODIGO "
    cQuery +=                   " HAVING COUNT(CONCAT(QQK_CODIGO, QQK_OPERAC)) = 1 ) CONTAGEM_UNICAS "
    cQuery +=               " INNER JOIN "
    cQuery +=                 " ( SELECT QQK_PRODUT, QQK_REVIPR, COUNT(QQK_CODIGO) AS ROTEIROS_UNICOS "
    cQuery +=                     " FROM " + RetSQLName("QQK")
    cQuery +=                    " WHERE D_E_L_E_T_ = ' ' "
    cQuery +=                 " GROUP BY QQK_PRODUT, QQK_REVIPR "
    cQuery +=                   " HAVING COUNT(QQK_CODIGO) = 1 ) CONTAGEM_UNICOS "
    cQuery +=                       " ON CONTAGEM_UNICAS.QQK_PRODUT = CONTAGEM_UNICOS.QQK_PRODUT "
    cQuery +=                      " AND CONTAGEM_UNICAS.QQK_REVIPR = CONTAGEM_UNICOS.QQK_REVIPR "
    cQuery +=        " ) SOMA_UNICAS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

    (cAliasQry)->(DBGotop())
	If (cAliasQry)->(!EOF())
        nResultados := Round((cAliasQry)->OPERACOES_UNICAS / (cAliasQry)->OPERACOES, 2)
    EndIf
    (cAliasQry)->(DbCloseArea())
    
Return nResultados

/*/{Protheus.doc} confirmaEnvioSemInterfaceSincrono
Função de tratamento de envio sem interface síncrono
@since 13/02/2023
@version P12.1.2310
@param 01 - cUsuario  , caracter, indica o código do usuário logado no sistema
@param 02 - cIDModulo , caracter, indica o código do módulo para vínculo a métrica
@param 03 - cSubRotina, caracter, indica a subrotina para detalhamento da métrica
/*/
METHOD confirmaEnvioSemInterfaceSincrono(cUsuario, cIDModulo, cSubRotina) CLASS QLTMetrics
    If Self:lSemInterface .and. Self:lSincrono
        FWLsPutAsyncInfo("LS006", cUsuario, cIDModulo, cSubRotina)
    EndIf
Return

/*/{Protheus.doc} checaPrimeiroEnvioSincrono
Função que checa necessidade de primeiro envio síncrono baseado em semáforo criado fisicamente no diretório de semáforos
@since 13/02/2023
@version P12.1.2310
@param 01 - cChave, caracter, indica a chave para checagem de primeiro envio
@return lSincrono, lógico, indica se é o primeiro retorno síncrono (.T.) ou se não é (.F.)
/*/
METHOD checaPrimeiroEnvioSincrono(cChave) CLASS QLTMetrics
    Local lSincrono   := .F.
    Local oQLTManager := Nil
    If FindClass("QLTQueryManager")
	    oQLTManager := QLTQueryManager():New()
        If oQLTManager:confirmaNecessidadeDeExecucaoMensalViaSemaforo("001", "QLTMetrics_" + cChave, Nil, 9999, .T.) //9999 meses - 833 anos)
            lSincrono := .T.
        EndIf
    EndIf
    Self:lSincrono := lSincrono
Return lSincrono

/*/{Protheus.doc} enviaMetricaQuantidadeDocumentosLidosQDO
Envia Métrica Quantidade de Documentos Lidos no QDO
@since 13/02/2023
@version P12.1.2310
@param 01 - cRotina    , caracter, indica a rotina em execução
@param 02 - cTipoDoc   , caracter, tipo do documento (I - Interno) ou (E - Externo)
@param 03 - cQAA_TPWORD, caracter, indica a quantidade de resultados para registro da métrica
/*/
METHOD enviaMetricaQuantidadeDocumentosLidosQDO(cRotina, cTipoDoc, cQAA_TPWORD) CLASS QLTMetrics

    Local cIDMetric   := "gestao-da-qualidade-protheus_quantidade-de-documentos-lidos-no-modulo-sigaqdo-no-cliente_total"
    Local cIDModulo   := "24"
    Local cSubRotina  := "protheus_sigaqdo_"

    Default cRotina     := ""
    Default cQAA_TPWORD := Self:retornaTipoExibicaoDocumentoDoUsuario()
    Default cTipoDoc    := Iif(M->QDH_DTOIE == Nil .OR. Empty(M->QDH_DTOIE), QDH->QDH_DTOIE, M->QDH_DTOIE)

    Self:new(.F.)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "total_default"             , cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "rotina_" + cRotina         , cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "QAA_TPWORD_" + cQAA_TPWORD , cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "tipo_documento_" + cTipoDoc, cIDMetric, 1)
Return

/*/{Protheus.doc} retornaTipoExibicaoDocumentoDoUsuario
Retorna Tipo de Exibição Documento do Usuario
@since 13/02/2023
@version P12.1.2310
@return cQAA_TPWORD, caracter, modo de leitura do documento vinculada ao usuário
/*/
METHOD retornaTipoExibicaoDocumentoDoUsuario() CLASS QLTMetrics

    Local aArea       := GetArea()
    Local cAlias      := GetNextAlias()
    Local cLogin      := ""
    Local cQAA_TPWORD := ""
    Local cUsuario    := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    BeginSql Alias cAlias
        SELECT QAA_TPWORD
		FROM %Table:QAA% 
		WHERE %NotDel%
            AND LTRIM(RTRIM(UPPER(QAA_LOGIN))) =  %Exp:cLogin%
            AND QAA_LOGIN                      <> ' '
    EndSql

    If !(cAlias)->(Eof()) 
        cQAA_TPWORD := (cAlias)->QAA_TPWORD
    EndIf 

    (cAlias)->(DbCloseArea())

    RestArea(aArea)
Return cQAA_TPWORD

/*/{Protheus.doc} enviaMetricaNaoConformidadeAberta
Envia Métrica Quantidade Não Conformidade Aberta
@since 13/02/2023
@version P12.1.2310
@param 01 - cModulo, caracter, sigla do módulo origem
/*/
METHOD enviaMetricaNaoConformidadeAberta(cModulo) CLASS QLTMetrics

    Local cIDMetric  := "gestao-da-qualidade-protheus_quantidade-de-nao-conformidades-geradas-no-cliente_total"
    Local cIDModulo  := "36"
    Local cRotina    := FunName()
    Local cSubRotina := "protheus_sigaqnc_"

    Default cModulo   := "QNC"

    Self:new(.F.)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "total_default"    , cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "rotina_" + cRotina, cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "modulo_" + cModulo, cIDMetric, 1)

Return

/*/{Protheus.doc} enviaMetricaPlanoDeAcaoAberto
Envia Métrica Quantidade Plano de Ação Aberto
@since 13/02/2023
@version P12.1.2310
@param 01 - cModulo, caracter, sigla do módulo origem
/*/
METHOD enviaMetricaPlanoDeAcaoAberto(cModulo) CLASS QLTMetrics

    Local cIDMetric  := "gestao-da-qualidade-protheus_quantidade-de-nao-conformidades-geradas-no-cliente_total"
    Local cIDModulo  := "36"
    Local cRotina    := FunName()
    Local cSubRotina := "protheus_sigaqnc_plano_de_acao_"

    Default cModulo   := "QNC"

    Self:new(.F.)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "total_default"    , cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "rotina_" + cRotina, cIDMetric, 1)
    Self:enviaMetrica(cIDModulo, cRotina, cSubRotina + "modulo_" + cModulo, cIDMetric, 1)

Return
