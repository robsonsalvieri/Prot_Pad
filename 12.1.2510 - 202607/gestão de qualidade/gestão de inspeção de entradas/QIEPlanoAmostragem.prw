#include "TOTVS.CH"
#include "QIEPlanoAmostragem.CH"

// Constantes simbólicas para índices do array de contadores de NC
#DEFINE NC_CRITICAS   1
#DEFINE NC_GRAVES     2
#DEFINE NC_TOLERAVEIS 3

/*/{Protheus.doc} QIEPlanoAmostragem
Classe especializada para cálculo de parecer baseado em plano de amostragem.
Implementa todas as regras do QIEA215 de forma independente e reutilizável,
incluindo NBR5426, NBR5429, QS9000, Texto e Amostragem Dupla.
@type class
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
/*/
CLASS QIEPlanoAmostragem FROM LongNameClass

    // ========================================================================
    // PROPRIEDADES DA CLASSE (DATA)
    // ========================================================================

    // Dados de entrada
    DATA nRecnoQEK                  AS NUMERIC   // Recno da inspeção na QEK
    DATA cLaborat                   AS CHARACTER // Laboratório para análise
    DATA cUsuario                   AS CHARACTER // Usuário processando

    // Dados carregados
    DATA aEnsaios                   AS ARRAY    // Ensaios com dados de PA
    DATA aResultado                 AS ARRAY    // Resultados processados
    DATA aAcumAglut                 AS ARRAY    // Acumulador para MV_QACUPAM

    // Resultados do cálculo
    DATA cParecer                   AS CHARACTER // Parecer calculado
    DATA cMensagem                  AS CHARACTER // Mensagem explicativa
    DATA lSucesso                   AS LOGICAL   // Se cálculo foi bem-sucedido
    DATA cErro                      AS CHARACTER // Mensagem de erro

    // Configurações de parâmetros
    DATA lAglutPlan                 AS LOGICAL   // MV_QACUPAM
    DATA lBlqPlano                  AS LOGICAL   // MV_QBLQPLA
    DATA lConsTol                   AS LOGICAL   // MV_QAPTOL
    DATA lAprConTol                 AS LOGICAL   // Aprovação Condicional com Tolerância
    DATA lMedForEsp                 AS LOGICAL   // Medições Fora de Especificação como NC
    DATA lQ215PL1                   AS LOGICAL   // Verifica se existe PE Q215PL1 para Plano Interno
    DATA lQ215PL2                   AS LOGICAL   // Verifica se existe PE Q215PL2 para Plano Interno Especializado
    DATA lQ215PINT                  AS LOGICAL   // Verifica se existe PE Q215PINT para alteração de contagem PI

    // ========================================================================
    // MÉTODOS PÚBLICOS
    // ========================================================================

    METHOD New(nRecnoQEK, cLaborat) CONSTRUCTOR

    METHOD CalculaParecer()
    METHOD RetornaDetalhes()
    METHOD RetornaErro()
    METHOD RetornaMensagem()
    METHOD RetornaParecer()
    METHOD RetornaSucesso()

    // ========================================================================
    // MÉTODOS PRIVADOS - CARREGAMENTO DE DADOS
    // ========================================================================

    METHOD BuscaDadosPlanoAmostragem(cCodEnsaio)
    METHOD CarregaEnsaiosComPlanoAmostragem()
    METHOD CarregaMedicoesDoEnsaio(nRecnoQER)

    // ========================================================================
    // MÉTODOS PRIVADOS - PROCESSAMENTO
    // ========================================================================

    METHOD BuscaDadosPlanoAmostragemComHistorico(cCodEnsaio)
    METHOD CalculaIndiceDefeitosNBR5429(aMedicoes, oEnsaio, nLIE, nLSE)
    METHOD ContaNaoConformidadesNBR5426(oEnsaio)
    METHOD ContaNaoConformidadesNBR5429(oEnsaio)
    METHOD ContaNaoConformidadesPadrao(oEnsaio)
    METHOD ContaNaoConformidadesPlanoInterno(oEnsaio)
    METHOD ContaNaoConformidadesPorTipoPlano(oEnsaio)
    METHOD ContaNaoConformidadesQS9000(oEnsaio)
    METHOD ContaNaoConformidadesTexto(oEnsaio)
    METHOD ProcessaEnsaios()
    METHOD ValidaPreCondicoesTamanhoAmostra(oEnsaio)
    METHOD VerificaExistenciaSegundaAmostra(oResultado)

    // ========================================================================
    // MÉTODOS PRIVADOS - APLICAÇÃO DE REGRAS
    // ========================================================================

    METHOD AplicaRegrasPlanoAmostragem()
    METHOD AvaliaAmostragemDupla(oResultado)
    METHOD AvaliaAmostragemSimples(oResultado)

    // ========================================================================
    // MÉTODOS PRIVADOS - VALIDAÇÕES E AUXILIARES
    // ========================================================================

    METHOD AplicaPEPlanoInterno(aPlaInt1, aPlaInt2)
    METHOD FormataMessagemPlanoAmostragem(nTipo, aParams)
    METHOD LimpaResultados()
    METHOD SeparaNaoConformidadesPorAmostra(oResultado)
    METHOD VerificaMedicaoAprovada(oResultado)
    METHOD VerificaMedicaoReprovada(oResultado)

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe - Inicializa propriedades e configurações

@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0

@param01 nRecnoQEK, numeric, Recno da inspeção na tabela QEK
@param02 cLaborat, character, Código do laboratório (vazio para todos)

@return Self, object, Instância da classe inicializada
/*/
METHOD New(nRecnoQEK, cLaborat) CLASS QIEPlanoAmostragem

    Default cLaborat  := ""
    Default nRecnoQEK := 0

    // Dados de entrada
    self:cLaborat  := AllTrim(cLaborat)
    self:cUsuario  := UsrRetName(RetCodUsr())
    self:nRecnoQEK := nRecnoQEK

    // Inicializa arrays
    self:aAcumAglut := {}
    self:aEnsaios   := {}
    self:aResultado := {}

    // Inicializa resultados
    self:cErro     := ""
    self:cMensagem := ""
    self:cParecer  := ""
    self:lSucesso  := .F.

    // Carrega configurações de parâmetros
    self:lAglutPlan := GetMV("MV_QACUPAM", .F., .F.)
    self:lAprConTol := GetMV("MV_QAPCTOL", .F., .T.) // Aprovação Condicional com Tolerância
    self:lBlqPlano  := (GetMV("MV_QBLQPLA", .F., "2") == "1")
    self:lConsTol   := GetMV("MV_QAPTOL", .F., .T.)
    self:lMedForEsp := GetMV("MV_QERESNC", .F., .F.) // Medições Fora de Especificação como NC
    
    // Valida se existe Ponto de Entrada
    self:lQ215PINT := ExistBlock("Q215PINT")
    self:lQ215PL1  := ExistBlock("Q215PL1")
    self:lQ215PL2  := ExistBlock("Q215PL2")

Return Self

/*/{Protheus.doc} CalculaParecer
Método principal - Calcula parecer baseado em plano de amostragem.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@return lSucesso, lógical, .T. se cálculou com sucesso, .F. se houve erro
/*/
METHOD CalculaParecer() CLASS QIEPlanoAmostragem

    Begin Sequence

        // Limpa resultados de execuções anteriores
        self:LimpaResultados()

        // Carrega dados da inspeção com planos de amostragem
        If !self:CarregaEnsaiosComPlanoAmostragem()
            //STR0002 - Nenhum ensaio encontrado para análise
            self:cErro := STR0002
            Break
        EndIf

        // Processa ensaios (conta não-conformidades)
        If !self:ProcessaEnsaios()
            // STR0003 - Falha ao processar ensaios 
            self:cErro := STR0003
            Break
        EndIf

        // Aplica regras de aprovação/reprovação
        If !self:AplicaRegrasPlanoAmostragem()
            // STR0004 - Falha ao aplicar regras de plano de amostragem
            self:cErro := STR0004
            Break
        EndIf

        self:lSucesso := .T.

    Recover

        self:lSucesso := .F.
        self:cParecer := "REPR"

        If Empty(self:cErro)
            // STR0005 - Erro não identificado no cálculo
            self:cErro := STR0005
        EndIf

    End Sequence

Return self:lSucesso

/*/{Protheus.doc} CarregaEnsaiosComPlanoAmostragem
Carrega ensaios da inspeção com todos os dados de plano de amostragem.
Executa query otimizada com joins para obter dados de QER, QF4/QF6 e medições.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@return lSucesso, lógical, .T. se carregou ao menos um ensaio, .F. caso contrário
/*/
METHOD CarregaEnsaiosComPlanoAmostragem() CLASS QIEPlanoAmostragem

    Local aAreaAnt   := GetArea()
    Local aBindParam := {}
    Local cAliasQry  := ""
    Local cCampoEnt  := "" // Campo entidade: FORNEC (QF4) ou CLIENT (QF6)
    Local cCampoLoj  := "" // Campo loja:     LOJFOR (QF4) ou LOJCLI (QF6)
    Local cCampoPref := ""
    Local cQuery     := ""
    Local cTabEspec  := ""
    Local oEnsaio    := Nil

    // Posiciona na inspeção
    DbSelectArea("QEK")
    QEK->(DbGoTo(self:nRecnoQEK))

    If QEK->(Eof())
        RestArea(aAreaAnt)
        Return .F.
    EndIf

    // Define tabela de específicação baseada no tipo de nota fiscal
    cTabEspec  := If(QEK->QEK_TIPONF $ "B/D", "QF6", "QF4")
    cCampoPref := If(QEK->QEK_TIPONF $ "B/D", "QF6_", "QF4_")
    cCampoEnt  := If(QEK->QEK_TIPONF $ "B/D", "CLIENT", "FORNEC")
    cCampoLoj  := If(QEK->QEK_TIPONF $ "B/D", "LOJCLI", "LOJFOR")

    // Monta query com bind variables (proteção contra SQL Injection)
    cQuery := " SELECT "
    cQuery +=   " QER.R_E_C_N_O_ AS RECNO_QER, "
    cQuery +=   " QER.QER_ENSAIO, "
    cQuery +=   " QER.QER_LABOR, "
    cQuery +=   " QER.QER_RESULT, "
    cQuery +=   " " + cTabEspec + "." + cCampoPref + "TIPAMO AS TIPO_AMOSTRAGEM, "
    cQuery +=   " " + cTabEspec + "." + cCampoPref + "PLAMO AS PLANO_AMOSTRAGEM, "
    cQuery +=   " " + cTabEspec + "." + cCampoPref + "NIVEL AS NIVEL_AMOSTRAGEM, "
    cQuery +=   " " + cTabEspec + "." + cCampoPref + "NQA AS NQA "
    cQuery += " FROM " + RetSqlName("QER") + " QER "

    // Join com específicação do produto
    cQuery += " INNER JOIN " + RetSqlName(cTabEspec) + " " + cTabEspec
    cQuery +=   " ON " + cTabEspec + "." + cCampoPref + "FILIAL = ? "
    cQuery +=  " AND " + cTabEspec + "." + cCampoPref + cCampoEnt + " = ? "
    cQuery +=  " AND " + cTabEspec + "." + cCampoPref + cCampoLoj + " = ? "
    cQuery +=  " AND " + cTabEspec + "." + cCampoPref + "PRODUT = ? "
    cQuery +=  " AND " + cTabEspec + "." + cCampoPref + "REVI = ? "
    cQuery +=  " AND " + cTabEspec + "." + cCampoPref + "ENSAIO = QER.QER_ENSAIO "
    cQuery +=  " AND " + cTabEspec + ".D_E_L_E_T_ = ' ' "

    // Filtros principais
    cQuery += " WHERE QER.QER_FILIAL = ? "
    cQuery +=   " AND QER.QER_NUMSEQ = ? "
    cQuery +=   " AND QER.D_E_L_E_T_ = ' ' "

    AAdd(aBindParam, {xFilial(cTabEspec), "S"})    // FILIAL tabela espec.
    AAdd(aBindParam, {QEK->QEK_FORNEC      , "S"}) // FORNEC
    AAdd(aBindParam, {QEK->QEK_LOJFOR      , "S"}) // LOJFOR
    AAdd(aBindParam, {QEK->QEK_PRODUT      , "S"}) // PRODUT
    AAdd(aBindParam, {QEK->QEK_REVI        , "S"}) // REVI
    AAdd(aBindParam, {xFilial("QER")       , "S"}) // FILIAL QER
    AAdd(aBindParam, {QEK->QEK_NUMSEQ      , "S"}) // NUMSEQ

    // Filtro de laboratório (se informado)
    If !Empty(self:cLaborat)
        cQuery += " AND QER.QER_LABOR = ? "
        AAdd(aBindParam, {self:cLaborat, "S"}) // LABOR
    EndIf

    cQuery    += " ORDER BY QER.QER_LABOR, QER.QER_ENSAIO "
    cAliasQry := QLTQueryManager():executeQueryWithBind(cQuery, aBindParam)

    // Processa resultado da query
    While !(cAliasQry)->(Eof())

        oEnsaio := JsonObject():New()

        // Dados básicos do ensaio
        oEnsaio["RecnoQER"       ] := (cAliasQry)->RECNO_QER
        oEnsaio["CodigoEnsaio"   ] := AllTrim((cAliasQry)->QER_ENSAIO)
        oEnsaio["Laboratorio"    ] := AllTrim((cAliasQry)->QER_LABOR)
        oEnsaio["ResultadoEnsaio"] := AllTrim((cAliasQry)->QER_RESULT)

        // Dados do plano de amostragem
        oEnsaio["TipoAmostragem" ] := AllTrim((cAliasQry)->TIPO_AMOSTRAGEM)
        oEnsaio["PlanoAmostragem"] := AllTrim((cAliasQry)->PLANO_AMOSTRAGEM)
        oEnsaio["NivelAmostragem"] := AllTrim((cAliasQry)->NIVEL_AMOSTRAGEM)
        oEnsaio["NQA"            ] := AllTrim((cAliasQry)->NQA)

        // Carrega medições do ensaio
        oEnsaio["Medicoes"       ] := self:CarregaMedicoesDoEnsaio((cAliasQry)->RECNO_QER)
        If ValType(oEnsaio["Medicoes"]) <> "A"
            oEnsaio["Medicoes"] := {}
        EndIf

        // Busca dados completos do plano (aceite, rejeite, tamanhos)
        oEnsaio["DadosPlano"     ] := self:BuscaDadosPlanoAmostragemComHistorico(oEnsaio["CodigoEnsaio"])
        If ValType(oEnsaio["DadosPlano"]) <> "A"
            oEnsaio["DadosPlano"] := {0, 0, 0, 0, 0, 0}
        EndIf

        AAdd(self:aEnsaios, oEnsaio)

        (cAliasQry)->(DbSkip())
    EndDo

    (cAliasQry)->(DbCloseArea())
    RestArea(aAreaAnt)

Return (Len(self:aEnsaios) > 0)

/*/{Protheus.doc} CarregaMedicoesDoEnsaio
Carrega todas as medições de um ensaio específico da tabela QES.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param nRecnoQER, numeric, Recno do ensaio na tabela QER
@return aMedicoes, array, Array de objetos JSON com dados das medições
/*/
METHOD CarregaMedicoesDoEnsaio(nRecnoQER) CLASS QIEPlanoAmostragem

    Local aAreaAnt  := GetArea()
    Local aMedicoes := {}
    Local cMinMax   := ""
    Local cResMed   := ""
    Local nLIE      := 0
    Local nLSE      := 0
    Local nValor    := 0
    Local oMedicao  := Nil

    DbSelectArea("QER")
    QER->(DbGoTo(nRecnoQER))

    If !QER->(Eof())

        DbSelectArea("QEK")
        QEK->(DbGoTo(self:nRecnoQEK))

        DbSelectArea("QE7")
        QE7->(DbSetOrder(1)) // QE7_FILIAL+QE7_PRODUT+QE7_REVI+QE7_ENSAIO
        If QE7->(DbSeek(xFilial("QE7") + QEK->QEK_PRODUT + QEK->QEK_REVI + QER->QER_ENSAIO))
            nLIE    := SuperVal(QE7->QE7_LIE)
            nLSE    := SuperVal(QE7->QE7_LSE)
            cMinMax := AllTrim(QE7->QE7_MINMAX)
        EndIf

        DbSelectArea("QES")
        QES->(DbSetOrder(1)) // QES_FILIAL+QES_CODMED

        If QES->(DbSeek(xFilial("QES") + QER->QER_CHAVE))

            While !QES->(Eof()) .And. ;
                  QES->QES_FILIAL == xFilial("QES") .And. ;
                  QES->QES_CODMED == QER->QER_CHAVE

                cResMed := Upper(AllTrim(QER->QER_RESULT))
                nValor  := SuperVal(QES->QES_MEDICA)

                oMedicao := JsonObject():New()
                oMedicao["ResultadoMedicao"] := cResMed
                oMedicao["ValorMedido"     ] := nValor
                oMedicao["ClasseNC"        ] := ""        // sem origem na QES
                oMedicao["NumeroAmostra"   ] := 1         // sem origem na QES (amostragem dupla indisponivel)
                oMedicao["DataEmissao"     ] := Date()    // nao persistido na QES
                oMedicao["HoraEmissao"     ] := Time()    // nao persistido na QES
                oMedicao["RegistroExcluido"] := QES->(Deleted())

                AAdd(aMedicoes, oMedicao)

                QES->(DbSkip())
            EndDo
        EndIf
    EndIf

    RestArea(aAreaAnt)

Return aMedicoes

/*/{Protheus.doc} BuscaDadosPlanoAmostragem
Busca dados completos do plano de amostragem (aceite, rejeite, tamanhos de amostra).
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param cCodEnsaio, character, Código do ensaio
@return aDadosPlno, array, Array com 6 posições:
    [1] Tamanho Amostra 1
    [2] Aceite 1
    [3] Rejeite 1
    [4] Tamanho Amostra 2 (amostragem dupla)
    [5] Aceite 2 (amostragem dupla)
    [6] Rejeite 2 (amostragem dupla)
/*/
METHOD BuscaDadosPlanoAmostragem(cCodEnsaio) CLASS QIEPlanoAmostragem

    Local aAreaAnt   := GetArea()
    Local aDadosPlno := {0, 0, 0, 0, 0, 0}
    Local aRetQep    := {}
    Local cCampoPref := ""
    Local cTabEspec  := ""

    DbSelectArea("QEK")
    QEK->(DbGoTo(self:nRecnoQEK))

    If QEK->(Eof())
        RestArea(aAreaAnt)
        Return aDadosPlno
    EndIf

    // Define tabela e prefixo
    cTabEspec  := If(QEK->QEK_TIPONF $ "B/D", "QF6", "QF4")
    cCampoPref := If(QEK->QEK_TIPONF $ "B/D", "QF6_", "QF4_")

    DbSelectArea(cTabEspec)
    // Índice 1 de ambas as tabelas tem a mesma estrutura posicional:
    //   QF4: QF4_FILIAL+QF4_FORNEC+QF4_LOJFOR+QF4_PRODUT+QF4_REVI+QF4_ENSAIO
    //   QF6: QF6_FILIAL+QF6_CLIENT+QF6_LOJCLI+QF6_PRODUT+QF6_REVI+QF6_ENSAIO
    (cTabEspec)->(DbSetOrder(1))

    If (cTabEspec)->(MsSeek(xFilial(cTabEspec) + QEK->QEK_FORNEC + QEK->QEK_LOJFOR + QEK->QEK_PRODUT + QEK->QEK_REVI + cCodEnsaio))

        aRetQep := Qep_RetAmostra(;
            (cTabEspec)->&(cCampoPref + "TIPAMO"),;
            (cTabEspec)->&(cCampoPref + "PLAMO"),;
            (cTabEspec)->&(cCampoPref + "NIVEL"),;
            (cTabEspec)->&(cCampoPref + "NQA"),;
            QEK->QEK_TAMAMO,;
            "QEK_TAMAMO",;
            .F.;
        )

        If ValType(aRetQep) == "A" .And. Len(aRetQep) >= 6

            // Verifica se é amostragem dupla (tipo "3")
            If (cTabEspec)->&(cCampoPref + "TIPAMO") == "3"

                If Len(aRetQep) > 0 .And. ValType(aRetQep[1]) == "A"
                    // Primeira amostra
                    aDadosPlno[1] := aRetQep[1][1] // Tamanho Amostra 1
                    aDadosPlno[2] := aRetQep[1][2] // Aceite 1
                    aDadosPlno[3] := aRetQep[1][3] // Rejeite 1

                    // Segunda amostra (se existir)
                    If Len(aRetQep) >= 2
                        aDadosPlno[4] := aRetQep[2][1] // Tamanho Amostra 2
                        aDadosPlno[5] := aRetQep[2][2] // Aceite 2
                        aDadosPlno[6] := aRetQep[2][3] // Rejeite 2
                    EndIf
                EndIf

            Else
                // Amostragem simples
                aDadosPlno[1] := aRetQep[1] // Tamanho
                aDadosPlno[2] := aRetQep[2] // Aceite
                aDadosPlno[3] := aRetQep[3] // Rejeite
            EndIf
        EndIf
    EndIf

    RestArea(aAreaAnt)

Return aDadosPlno

/*/{Protheus.doc} ProcessaEnsaios
Processa todos os ensaios carregados contando não-conformidades.
Popula self:aResultado com resultados de cada ensaio.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@return lSucesso, lógical, .T. se processou ao menos um ensaio
/*/
METHOD ProcessaEnsaios() CLASS QIEPlanoAmostragem

    Local nIndice    := 0
    Local oEnsaio    := Nil
    Local oResEnsaio := Nil

    For nIndice := 1 To Len(self:aEnsaios)
        oEnsaio := self:aEnsaios[nIndice]

        // Conta não-conformidades baseado no tipo de plano
        oResEnsaio := self:ContaNaoConformidadesPorTipoPlano(oEnsaio)

        AAdd(self:aResultado, oResEnsaio)
    Next nIndice

Return (Len(self:aResultado) > 0)

/*/{Protheus.doc} ContaNaoConformidadesPorTipoPlano
Contador principal - direciona para método específico baseado no tipo de plano.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param oEnsaio, object, Objeto JSON com dados do ensaio
@return oResultado, object, Objeto JSON com resultado da contagem contendo:
    - CodigoEnsaio
    - TipoPlano
    - NCCriticas, NCGraves, NCToleraveis
    - TotalNC
    - DadosPlano
    - Medicoes
/*/
METHOD ContaNaoConformidadesPorTipoPlano(oEnsaio) CLASS QIEPlanoAmostragem

    Local aContNC    := {0, 0, 0}
    Local cCodPlano  := AllTrim(oEnsaio["PlanoAmostragem"])
    Local cTipoPlano := AllTrim(oEnsaio["TipoAmostragem"])
    Local oResultado := JsonObject():New()

    Do Case
        // Plano NBR5426 (código "1" ou tipo "1")
        Case cCodPlano == "1" .Or. cCodPlano == "NBR5426" .Or. cTipoPlano == "1"
            aContNC := self:ContaNaoConformidadesNBR5426(oEnsaio)

        // Plano NBR5429 (código "5" ou tipo "5")
        Case cCodPlano == "5" .Or. cCodPlano == "NBR5429" .Or. cTipoPlano == "5"
            aContNC := self:ContaNaoConformidadesNBR5429(oEnsaio)

        // Plano QS9000 (código "QS" ou tipo "QS")
        Case cCodPlano == "QS" .Or. cCodPlano == "QS9000" .Or. cTipoPlano == "QS"
            aContNC := self:ContaNaoConformidadesQS9000(oEnsaio)

        // Plano Texto (código "TX" ou tipo "TX")
        Case cCodPlano == "TX" .Or. cCodPlano == "TEXTO" .Or. cTipoPlano == "TX"
            aContNC := self:ContaNaoConformidadesTexto(oEnsaio)

        // Plano Interno (código "PI" ou tipo "PI")
        Case cCodPlano == "PI" .Or. cCodPlano == "INTERNO" .Or. cTipoPlano == "PI"
            aContNC := self:ContaNaoConformidadesPlanoInterno(oEnsaio)

        // Amostragem Dupla (tipo "3" ou "Du" ou "D")
        Case cTipoPlano == "3" .Or. SubStr(cTipoPlano, 1, 2) $ "DU/"
            aContNC := self:ContaNaoConformidadesNBR5426(oEnsaio)

        OtherWise // Padrão
            aContNC := self:ContaNaoConformidadesPadrao(oEnsaio)
    EndCase

    // Monta objeto de resultado
    oResultado["CodigoEnsaio"] := oEnsaio["CodigoEnsaio"]
    oResultado["Laboratorio" ] := oEnsaio["Laboratorio"]
    oResultado["TipoPlano"   ] := cTipoPlano
    oResultado["CodigoPlano" ] := cCodPlano
    oResultado["NCCriticas"  ] := aContNC[NC_CRITICAS]
    oResultado["NCGraves"    ] := aContNC[NC_GRAVES]
    oResultado["NCToleraveis"] := aContNC[NC_TOLERAVEIS]
    oResultado["TotalNC"     ] := aContNC[NC_CRITICAS] + aContNC[NC_GRAVES] + aContNC[NC_TOLERAVEIS]
    oResultado["DadosPlano"  ] := oEnsaio["DadosPlano"]
    oResultado["Medicoes"    ] := oEnsaio["Medicoes"]

Return oResultado

/*/{Protheus.doc} ContaNaoConformidadesNBR5426
Conta não-conformidades para plano NBR5426 com suporte a aglutinação.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param oEnsaio, object, Objeto JSON com dados do ensaio
@return aContador, array, Array com 3 posições [NCCríticas, NCGraves, NCToleráveis]
/*/
METHOD ContaNaoConformidadesNBR5426(oEnsaio) CLASS QIEPlanoAmostragem

    Local aContador  := {0, 0, 0}
    Local aMedicoes  := oEnsaio["Medicoes"]
    Local cChavePlan := ""
    Local cClasseNC  := ""
    Local nIdxMed    := 0
    Local nPosAcum   := 0
    Local oMedicao   := Nil

    // Conta não-conformidades por classe
    For nIdxMed := 1 To Len(aMedicoes)
        oMedicao := aMedicoes[nIdxMed]

        // Considera apenas medições reprovadas não excluídas
        If oMedicao["ResultadoMedicao"] == "R" .And. !oMedicao["RegistroExcluido"]

            cClasseNC := Upper(AllTrim(oMedicao["ClasseNC"]))

            Do Case
                Case cClasseNC == "C" // Crítica
                    aContador[NC_CRITICAS]++
                Case cClasseNC == "G" // Grave
                    aContador[NC_GRAVES]++
                OtherWise             // Tolerável
                    aContador[NC_TOLERAVEIS]++
            EndCase
        EndIf
    Next nIdxMed

    // Aplica aglutinação se habilitado (MV_QACUPAM)
    If self:lAglutPlan .And. oEnsaio["TipoAmostragem"] == "1"

        // Cria chave do plano: TipoAmostragem + Nivel + PlanoAmostragem + NQA
        cChavePlan :=  oEnsaio["TipoAmostragem"]  + ;
                       oEnsaio["NivelAmostragem"] + ;
                       oEnsaio["PlanoAmostragem"] + ;
                       oEnsaio["NQA"]

        // Busca se já existe acumulador para este plano
        nPosAcum := Ascan(self:aAcumAglut, {|x| x[1] == cChavePlan})

        If nPosAcum == 0
            // Primeira ocorrência deste plano - adiciona ao acumulador
            AAdd(self:aAcumAglut, {;
                cChavePlan,;
                {aContador[NC_CRITICAS], aContador[NC_GRAVES], aContador[NC_TOLERAVEIS]},;
                oEnsaio["CodigoEnsaio"];
            })
            nPosAcum := Len(self:aAcumAglut)

        Else
            // Plano já existe - acumula contadores
            self:aAcumAglut[nPosAcum][2][NC_CRITICAS] += aContador[NC_CRITICAS]
            self:aAcumAglut[nPosAcum][2][NC_GRAVES] += aContador[NC_GRAVES]
            self:aAcumAglut[nPosAcum][2][NC_TOLERAVEIS] += aContador[NC_TOLERAVEIS]

            // Atualiza contadores locais com valores acumulados
            aContador[NC_CRITICAS]   := self:aAcumAglut[nPosAcum][2][NC_CRITICAS]
            aContador[NC_GRAVES]     := self:aAcumAglut[nPosAcum][2][NC_GRAVES]
            aContador[NC_TOLERAVEIS] := self:aAcumAglut[nPosAcum][2][NC_TOLERAVEIS]

            // Adiciona código do ensaio à lista
            self:aAcumAglut[nPosAcum][3] += ", " + oEnsaio["CodigoEnsaio"]
        EndIf
    EndIf

Return aContador

/*/{Protheus.doc} ContaNaoConformidadesNBR5429
Conta não-conformidades para plano NBR5429 (Índice de Defeitos).
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param oEnsaio, object, Objeto JSON com dados do ensaio
@return aContador, array, [ÍndiceDefeitos, 0, 0]
/*/
METHOD ContaNaoConformidadesNBR5429(oEnsaio) CLASS QIEPlanoAmostragem

    Local aAreaAnt   := GetArea()
    Local aContador  := {0, 0, 0}
    Local aMed5429   := {}
    Local aMedicoes  := oEnsaio["Medicoes"]
    Local aResCalc   := {}
    Local cCodEnsaio := AllTrim(oEnsaio["CodigoEnsaio"])
    Local nIdxMed    := 0
    Local nIndDefeit := 0
    Local nLIE       := 0
    Local nLSE       := 0
    Local oMedicao   := Nil

    // Posiciona na inspeção para obter produto/revisão
    DbSelectArea("QEK")
    QEK->(DbGoTo(self:nRecnoQEK))

    DbSelectArea("QE7")
    QE7->(DbSetOrder(1)) // QE7_FILIAL+QE7_PRODUT+QE7_REVI+QE7_ENSAIO

    If QE7->(DbSeek(xFilial("QE7") + QEK->QEK_PRODUT + QEK->QEK_REVI + cCodEnsaio))
        nLIE := SuperVal(QE7->QE7_LIE)
        nLSE := SuperVal(QE7->QE7_LSE)
    EndIf

    // Prepara vetor simples de medições para QA_Def5429/QA_CalcDV
    For nIdxMed := 1 To Len(aMedicoes)
        oMedicao := aMedicoes[nIdxMed]

        If !oMedicao["RegistroExcluido"]
            If ValType(oMedicao["ValorMedido"]) $ "CN"
                AAdd(aMed5429, oMedicao["ValorMedido"])
            EndIf
        EndIf
    Next nIdxMed

    // Calcula índice de defeitos NBR5429
    If Len(aMed5429) > 0
        aResCalc := self:CalculaIndiceDefeitosNBR5429(aMed5429, oEnsaio, nLIE, nLSE)

        If ValType(aResCalc) == "A" .And. Len(aResCalc) >= 5
            nIndDefeit := aResCalc[5] // Posição 5 contém o índice
        EndIf
    EndIf

    // Armazena índice como NC crítica para avaliação
    aContador[NC_CRITICAS] := nIndDefeit

    RestArea(aAreaAnt)

Return aContador

/*/{Protheus.doc} CalculaIndiceDefeitosNBR5429
Calcula índice de defeitos conforme norma NBR5429.
@type method
@param nLIE     , numerico, Limite Inferior de Especificação
@param nLSE     , numerico, Limite Superior de Especificação
@return aResultado, array, Resultado do cálculo (posição [5] = índice)
/*/
METHOD CalculaIndiceDefeitosNBR5429(aMedicoes, oEnsaio, nLIE, nLSE) CLASS QIEPlanoAmostragem

    Local aDadosPlno := oEnsaio["DadosPlano"]
    Local cCodPlano  := AllTrim(oEnsaio["PlanoAmostragem"])
    Local aResultado := {0, 0, 0, 0, 0}

    // Chama função padrão do Protheus para cálculo NBR5429
    aResultado := QA_Def5429(;
        aMedicoes,;           // Array de medições
        nLIE,;                // Limite Inferior
        nLSE,;                // Limite Superior
        QA_Plano(cCodPlano),; // Código da norma
        aDadosPlno[1];        // Tamanho da amostra
    )

Return aResultado

/*/{Protheus.doc} ContaNaoConformidadesQS9000
Conta não-conformidades para plano QS9000.
Utiliza contagem simples sem classificação.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param oEnsaio, object, Dados do ensaio
@return aContador, array, [TotalNCs, 0, 0]
/*/
METHOD ContaNaoConformidadesQS9000(oEnsaio) CLASS QIEPlanoAmostragem

    Local aContador := {0, 0, 0}
    Local aMedicoes := oEnsaio["Medicoes"]
    Local nIdx      := 0
    Local oMed      := Nil

    For nIdx := 1 To Len(aMedicoes)
        oMed := aMedicoes[nIdx]

        If oMed["ResultadoMedicao"] == "R" .And. !oMed["RegistroExcluido"]
            aContador[NC_CRITICAS]++ // Todas como críticas
        EndIf
    Next nIdx

Return aContador

/*/{Protheus.doc} ContaNaoConformidadesTexto
Conta não-conformidades para plano tipo Texto.
Utiliza contagem simples.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param oEnsaio, object, Dados do ensaio
@return aContador, array, [TotalNCs, 0, 0]
/*/
METHOD ContaNaoConformidadesTexto(oEnsaio) CLASS QIEPlanoAmostragem

    Local aContador := {0, 0, 0}
    Local aMedicoes := oEnsaio["Medicoes"]
    Local nIdx      := 0
    Local oMed      := Nil

    For nIdx := 1 To Len(aMedicoes)
        oMed := aMedicoes[nIdx]

        If oMed["ResultadoMedicao"] == "R" .And. !oMed["RegistroExcluido"]
            aContador[NC_CRITICAS]++
        EndIf
    Next nIdx

Return aContador

/*/{Protheus.doc} ContaNaoConformidadesPadrao
Conta não-conformidades de forma padrão (sem plano específico).
Utiliza classificação por classe de NC.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param oEnsaio, object, Dados do ensaio
@return aContador, array, [NCCríticas, NCGraves, NCToleráveis]
/*/
METHOD ContaNaoConformidadesPadrao(oEnsaio) CLASS QIEPlanoAmostragem

    Local aContador := {0, 0, 0}
    Local aMedicoes := oEnsaio["Medicoes"]
    Local cClasse   := ""
    Local nIdx      := 0
    Local oMed      := Nil

    For nIdx := 1 To Len(aMedicoes)
        oMed := aMedicoes[nIdx]

        If oMed["ResultadoMedicao"] == "R" .And. !oMed["RegistroExcluido"]
            cClasse := Upper(AllTrim(oMed["ClasseNC"]))

            Do Case
                Case cClasse == "C"
                    aContador[NC_CRITICAS]++
                Case cClasse == "G"
                    aContador[NC_GRAVES]++
                OtherWise
                    aContador[NC_TOLERAVEIS]++
            EndCase
        EndIf
    Next nIdx

Return aContador

/*/{Protheus.doc} AplicaRegrasPlanoAmostragem
Aplica regras de aceite/rejeite baseado nos planos de amostragem.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@return lSucesso, lógical, .T. se definiu parecer
/*/
METHOD AplicaRegrasPlanoAmostragem() CLASS QIEPlanoAmostragem

    Local cParcLocal := ""
    Local lAprovado  := .F.
    Local lCondicnl  := .F.
    Local lReprovado := .F.
    Local nIdx       := 0
    Local oRes       := Nil

    For nIdx := 1 To Len(self:aResultado)
        oRes := self:aResultado[nIdx]

        // Verifica se é amostragem dupla (tipo começa com "D" ou é "3")
        If SubStr(oRes["TipoPlano"], 1, 1) $ "D/3"
            cParcLocal := self:AvaliaAmostragemDupla(oRes)
        Else
            cParcLocal := self:AvaliaAmostragemSimples(oRes)
        EndIf

        // Atualiza flags de status
        If cParcLocal == "REPR"
            lReprovado := .T.
            Exit // Reprovação interrompe análise
        ElseIf cParcLocal == "ACND"
            lCondicnl := .T.
        ElseIf cParcLocal == "APRV"
            lAprovado := .T.
        EndIf
    Next nIdx

    // Define parecer final baseado nas flags
    If lReprovado
        self:cParecer := "REPR"
    ElseIf lCondicnl
        self:cParecer := "ACND"
    ElseIf lAprovado
        self:cParecer := "APRV"
    Else
        self:cParecer := "PEND"
    EndIf

Return !Empty(self:cParecer)

/*/{Protheus.doc} AvaliaAmostragemSimples
Avalia ensaio com amostragem simples aplicando regras de aceite/rejeite.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param oResultado, object, Resultado do ensaio processado
@return cParecer, character, Parecer calculado (APRV/REPR/ACND/PEND)
/*/
METHOD AvaliaAmostragemSimples(oResultado) CLASS QIEPlanoAmostragem

    Local aDadosPlno := oResultado["DadosPlano"]
    Local aMedicoes  := oResultado["Medicoes"]
    Local cParecer   := ""
    Local lTemMedApv := .F.
    Local lTemMedRep := .F.
    Local nAceite1   := aDadosPlno[2]
    Local nIdxMed    := 0
    Local nRejeite1  := aDadosPlno[3]
    Local nTotalNC   := oResultado["TotalNC"]
    Local oMedicao   := Nil

    // Verifica medições aprovadas/reprovadas
    For nIdxMed := 1 To Len(aMedicoes)
        oMedicao := aMedicoes[nIdxMed]

        If !oMedicao["RegistroExcluido"]

            If oMedicao["ResultadoMedicao"] == "A"
                lTemMedApv := .T.

            ElseIf oMedicao["ResultadoMedicao"] == "R"
                lTemMedRep := .T.
            EndIf
        EndIf
    Next nIdxMed

    // O caso NC==0 e o caso NC>=Rejeite são decididos pelo status das medições.
    If nTotalNC <= nAceite1 .And. nTotalNC <> 0

        cParecer := "APRV"
        self:cMensagem := self:FormataMessagemPlanoAmostragem(5, {;
            AllTrim(Str(nTotalNC)),;
            AllTrim(Str(nAceite1));
        })

    ElseIf nTotalNC >= nRejeite1 .Or. nTotalNC == 0

        If lTemMedRep

            cParecer := "REPR"

            If nTotalNC > 0
                self:cMensagem := self:FormataMessagemPlanoAmostragem(6, {;
                    AllTrim(Str(nTotalNC)),;
                    oResultado["CodigoEnsaio"],;
                    AllTrim(Str(nRejeite1));
                })
            Else
                self:cMensagem := self:FormataMessagemPlanoAmostragem(1, {})
            EndIf

        ElseIf lTemMedApv

            cParecer := "APRV"

            // Mantém mensagem de aprovação para garantir resposta determinística.
            self:cMensagem := self:FormataMessagemPlanoAmostragem(5, {;
                AllTrim(Str(nTotalNC)),;
                AllTrim(Str(nAceite1));
            })

        EndIf

    // Aceite < NC < Rejeite ? CONDICIONAL
    Else

        cParecer := "ACND"
        self:cMensagem := self:FormataMessagemPlanoAmostragem(7, {;
            AllTrim(Str(nTotalNC)),;
            oResultado["CodigoEnsaio"],;
            AllTrim(Str(nAceite1)),;
            AllTrim(Str(nRejeite1));
        })

    EndIf

Return cParecer

/*/{Protheus.doc} AvaliaAmostragemDupla
Avalia ensaio com amostragem dupla aplicando regras específicas.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param oResultado, object, Resultado do ensaio processado
@return cParecer, character, Parecer calculado (APRV/REPR/ACND/PEND)
/*/
METHOD AvaliaAmostragemDupla(oResultado) CLASS QIEPlanoAmostragem

    Local aDadosPlno := oResultado["DadosPlano"]
    Local aNCPorAmos := {}
    Local cParecer   := ""
    Local lExiste2Am := .F.
    Local nAceite1   := aDadosPlno[2]
    Local nAceite2   := aDadosPlno[5]
    Local nNCAmos1   := 0
    Local nNCAmos2   := 0
    Local nRejeite1  := aDadosPlno[3]
    Local nRejeite2  := aDadosPlno[6]
    Local nSomaNCs   := 0

    // Separa NCs por número de amostra
    aNCPorAmos := self:SeparaNaoConformidadesPorAmostra(oResultado)
    nNCAmos1   := aNCPorAmos[1]
    nNCAmos2   := aNCPorAmos[2]

    // Verificar existência da segunda amostra por presença de medição
    lExiste2Am := self:VerificaExistenciaSegundaAmostra(oResultado)

    // Avalia primeira amostra
    If nNCAmos1 <= nAceite1

        cParecer := "APRV"
        // STR0006 - "Primeira amostra com "
        // STR0007 - " NC(s), aprovada pelo Aceite1 ("
        self:cMensagem := STR0006 + AllTrim(Str(nNCAmos1)) + STR0007 + AllTrim(Str(nAceite1)) + ")"

    ElseIf nNCAmos1 >= nRejeite1

        cParecer := "REPR"
        // STR0006 - "Primeira amostra com "
        // STR0008 - " NC(s), reprovada pelo Rejeite1 ("
        self:cMensagem := STR0006 + AllTrim(Str(nNCAmos1)) + STR0008 + AllTrim(Str(nRejeite1)) + ")"

    Else
        // Primeira amostra entre limites - necessita segunda amostra

        If !lExiste2Am .Or. self:lBlqPlano
            // Segunda amostra ainda não realizada
            cParecer := "PEND"
             // STR0009 - "Primeira amostra entre limites (" 
             // STR0010 - " NC(s)). Segunda amostra necessária."
            self:cMensagem := STR0009 + AllTrim(Str(nNCAmos1)) + STR0010
        Else
            // Avalia soma das duas amostras
            nSomaNCs := nNCAmos1 + nNCAmos2

            If nSomaNCs <= nAceite2

                cParecer := "APRV"
                // STR0011 - "Soma das amostras: "
                // STR0012 - " NC(s), aprovada pelo Aceite2 ("
                self:cMensagem := STR0011 + AllTrim(Str(nSomaNCs)) + STR0012 + AllTrim(Str(nAceite2)) + ")"

            ElseIf nSomaNCs >= nRejeite2

                cParecer := "REPR"
                // STR0011 - "Soma das amostras: "
                // STR0013 - " NC(s), reprovada pelo Rejeite2 ("
                self:cMensagem := STR0011 + AllTrim(Str(nSomaNCs)) + STR0013 + AllTrim(Str(nRejeite2)) + ")"

            Else

                cParecer := "ACND"
                // STR0011 - "Soma das amostras: "
                // STR0014 - " NC(s), entre limites. Aprovado condicionalmente."
                self:cMensagem := STR0011 + AllTrim(Str(nSomaNCs)) + STR0014

            EndIf
        EndIf
    EndIf

Return cParecer

/*/{Protheus.doc} VerificaMedicaoReprovada
Verifica se há pelo menos uma medição reprovada no ensaio.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param oResultado, object, Resultado do ensaio
@return lTemReprv, lógical, .T. se encontrou medição reprovada
/*/
METHOD VerificaMedicaoReprovada(oResultado) CLASS QIEPlanoAmostragem

    Local aMedicoes := oResultado["Medicoes"]
    Local lTemReprv := .F.
    Local nIdx      := 0
    Local oMed      := Nil

    For nIdx := 1 To Len(aMedicoes)
        oMed := aMedicoes[nIdx]

        If oMed["ResultadoMedicao"] == "R" .And. !oMed["RegistroExcluido"]
            lTemReprv := .T.
            Exit
        EndIf
    Next nIdx

Return lTemReprv

/*/{Protheus.doc} SeparaNaoConformidadesPorAmostra
Separa contagem de NCs por número de amostra (para amostragem dupla).
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param oResultado, object, Resultado do ensaio
@return aNCPorAmos, array, [NC Amostra 1, NC Amostra 2]
/*/
METHOD SeparaNaoConformidadesPorAmostra(oResultado) CLASS QIEPlanoAmostragem

    Local aMedicoes  := oResultado["Medicoes"]
    Local aNCPorAmos := {0, 0}
    Local nIdx       := 0
    Local oMed       := Nil

    For nIdx := 1 To Len(aMedicoes)
        oMed := aMedicoes[nIdx]

        If oMed["ResultadoMedicao"] == "R" .And. !oMed["RegistroExcluido"]

            If oMed["NumeroAmostra"] == 1
                aNCPorAmos[1]++
            ElseIf oMed["NumeroAmostra"] == 2
                aNCPorAmos[2]++
            EndIf

        EndIf
    Next nIdx

Return aNCPorAmos

/*/{Protheus.doc} FormataMessagemPlanoAmostragem
Formata mensagens explicativas de plano de amostragem.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param nTipo, numeric, Tipo de mensagem (1-7)
@param aParams, array, Parâmetros para substituição na mensagem
@return cMensagem, character, Mensagem formatada
/*/
METHOD FormataMessagemPlanoAmostragem(nTipo, aParams) CLASS QIEPlanoAmostragem

    Local cMensagem := ""

    Default aParams := {}

    Do Case
        Case nTipo == 1
            // STR0015 - "Existem medições reprovadas, o Laudo deverá ser Rejeitado"
            cMensagem := STR0015

        Case nTipo == 2
            // STR0016 - "Existem medições aprovadas com tolerância, o Laudo deverá ser Aprovado Condicionalmente"
            cMensagem := STR0016

        Case nTipo == 5
            If Len(aParams) >= 2
                // STR0017 - "Foram encontradas "
                // STR0018 - " não-conformidades, inferior ou igual ao Aceite de "
                // STR0019 - " O Laudo deverá ser Aprovado."
                cMensagem := STR0017 + aParams[1] + STR0018 + aParams[2] + ". " + STR0019
            EndIf

        Case nTipo == 6
            If Len(aParams) >= 3
                // STR0017 - "Foram encontradas "
                // STR0020 - " não-conformidades no Ensaio "
                // STR0021 - ", superior ou igual ao Rejeite de "
                // STR0022 - " O Laudo deverá ser Rejeitado."
                cMensagem := STR0017 + aParams[1] + STR0020 + aParams[2] + STR0021 + aParams[3] + ". " + STR0022
            EndIf

        Case nTipo == 7
            If Len(aParams) >= 4
                // STR0017 - "Foram encontradas "
                // STR0020 - " não-conformidades no Ensaio "
                // STR0023 - ", entre o Aceite de " 
                // STR0024 - " e Rejeite de "  
                // STR0025 - "O Laudo deverá ser Aprovado Condicionalmente."
                cMensagem := STR0017 + aParams[1] + STR0020 + aParams[2] + STR0023 + aParams[3] + STR0024 + aParams[4] + ". " + STR0025
            EndIf

        OtherWise
            // STR0026 - "Análise por plano de amostragem concluída"
            cMensagem := STR0026
    EndCase

Return cMensagem

/*/{Protheus.doc} LimpaResultados
Limpa resultados de execuções anteriores.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
/*/
METHOD LimpaResultados() CLASS QIEPlanoAmostragem

    self:aAcumAglut := {}
    self:aEnsaios   := {}
    self:aResultado := {}
    self:cErro      := ""
    self:cMensagem  := ""
    self:cParecer   := ""
    self:lSucesso   := .F.

Return

/*/{Protheus.doc} VerificaExistenciaSegundaAmostra
Verifica existência de segunda amostra baseada em presença de medicão.
@type method
@author brunno.costa / willian.ramalho
@since 22/05/2026
@version 1.0
@param oResultado, object, Resultado do ensaio
@return lExiste, lógical, .T. se encontrou medição com número amostra 2
/*/
METHOD VerificaExistenciaSegundaAmostra(oResultado) CLASS QIEPlanoAmostragem

    Local aMedicoes := oResultado["Medicoes"]
    Local lExiste   := .F.
    Local nIdx      := 0
    Local oMed      := Nil

    For nIdx := 1 To Len(aMedicoes)
        oMed := aMedicoes[nIdx]

        If !oMed["RegistroExcluido"] .And. oMed["NumeroAmostra"] == 2
            lExiste := .T.
            Exit
        EndIf
    Next nIdx

Return lExiste

/*/{Protheus.doc} VerificaMedicaoAprovada
Verifica se há pelo menos uma medição aprovada no ensaio.
@type method
@author brunno.costa / willian.ramalho
@since 22/05/2026
@version 1.0
@param oResultado, object, Resultado do ensaio
@return lTemAprvd, lógical, .T. se encontrou medição aprovada
/*/
METHOD VerificaMedicaoAprovada(oResultado) CLASS QIEPlanoAmostragem

    Local aMedicoes := oResultado["Medicoes"]
    Local lTemAprvd := .F.
    Local nIdx      := 0
    Local oMed      := Nil

    For nIdx := 1 To Len(aMedicoes)
        oMed := aMedicoes[nIdx]

        If oMed["ResultadoMedicao"] == "A" .And. !oMed["RegistroExcluido"]
            lTemAprvd := .T.
            Exit
        EndIf
    Next nIdx

Return lTemAprvd

/*/{Protheus.doc} ValidaPreCondicoesTamanhoAmostra
Valida pré-condições de tamanho de amostra comparando quantidade de medições.
@type method
@author brunno.costa / willian.ramalho
@since 22/05/2026
@version 1.0
@param oEnsaio, object, Dados do ensaio
@return lValido, lógical, .F. se divergência encontrada e não deve prosseguir
/*/
METHOD ValidaPreCondicoesTamanhoAmostra(oEnsaio) CLASS QIEPlanoAmostragem

    Local aDadosPlno := {0, 0, 0, 0, 0, 0}
    Local aMedicoes  := {}
    Local cCodEnsaio := ""
    Local lValido    := .T.
    Local nIdx       := 0
    Local nTamAmos1  := 0
    Local nTamAmos2  := 0
    Local nTotMed1   := 0
    Local nTotMed2   := 0
    Local oMed       := Nil

    If ValType(oEnsaio["Medicoes"]) == "A"
        aMedicoes := oEnsaio["Medicoes"]
    EndIf

    If ValType(oEnsaio["DadosPlano"]) == "A" .And. Len(oEnsaio["DadosPlano"]) >= 6
        aDadosPlno := oEnsaio["DadosPlano"]
    Else
        cCodEnsaio := AllTrim(cValToChar(Iif(oEnsaio["CodigoEnsaio"] == Nil, "", oEnsaio["CodigoEnsaio"])))
        If !Empty(cCodEnsaio)
            aDadosPlno := self:BuscaDadosPlanoAmostragemComHistorico(cCodEnsaio)
            If ValType(aDadosPlno) <> "A" .Or. Len(aDadosPlno) < 6
                aDadosPlno := {0, 0, 0, 0, 0, 0}
            EndIf
            oEnsaio["DadosPlano"] := aDadosPlno
        EndIf
    EndIf

    nTamAmos1 := aDadosPlno[1]
    nTamAmos2 := aDadosPlno[4]

    // Separa medições por número de amostra
    For nIdx := 1 To Len(aMedicoes)
        oMed := aMedicoes[nIdx]

        If !oMed["RegistroExcluido"]
            If oMed["NumeroAmostra"] == 1
                nTotMed1++
            ElseIf oMed["NumeroAmostra"] == 2
                nTotMed2++
            EndIf
        EndIf
    Next nIdx

    // Valida tamanho amostra 1
    If nTotMed1 <> nTamAmos1 .And. nTamAmos1 > 0
        // STR0027 - "Divergência de tamanho de amostra 1: esperado "
        // STR0029 - ", encontrado "
        self:cMensagem := STR0027 + AllTrim(Str(nTamAmos1)) + STR0029 + AllTrim(Str(nTotMed1))
        lValido := .F.
    EndIf

    // Valida tamanho amostra 2 (se houver)
    If lValido .And. nTamAmos2 > 0 .And. nTotMed2 > 0
        If nTotMed2 <> nTamAmos2
            // STR0028 - "Divergência de tamanho de amostra 2: esperado "
            // STR0029 - ", encontrado "
            self:cMensagem := STR0028 + AllTrim(Str(nTamAmos2)) + STR0029 + AllTrim(Str(nTotMed2))
            lValido := .F.
        EndIf
    EndIf

Return lValido

/*/{Protheus.doc} BuscaDadosPlanoAmostragemComHistorico
Busca dados do plano de amostragem com suporte a histórico.
@type method
@author brunno.costa / willian.ramalho
@since 22/05/2026
@version 1.0
@param cCodEnsaio, character, Código do ensaio
@return aDadosPlno, array, Array com dados do plano
/*/
METHOD BuscaDadosPlanoAmostragemComHistorico(cCodEnsaio) CLASS QIEPlanoAmostragem

    Local aAreaAnt   := GetArea()
    Local aDadosPlno := {0, 0, 0, 0, 0, 0}
    Local aRetQep    := {}
    Local cCampoPref := ""
    Local cChave     := ""
    Local cTabEspec  := ""
    Local lEnconHist := .F.

    DbSelectArea("QEK")
    QEK->(DbGoTo(self:nRecnoQEK))

    If QEK->(Eof())
        RestArea(aAreaAnt)
        Return aDadosPlno
    EndIf

    // Define tabela de especificação
    cTabEspec  := If(QEK->QEK_TIPONF $ "B/D", "QF6", "QF4")
    cCampoPref := If(QEK->QEK_TIPONF $ "B/D", "QF6_", "QF4_")

    DbSelectArea("QF5")
    QF5->(DbSetOrder(3)) // Índice QF5_FILIAL+QF5_FORNEC+QF5_LOJFOR+QF5_PRODUT+QF5_REVI+QF5_ENSAIO

    cChave := xFilial("QF5") + QEK->QEK_FORNEC + QEK->QEK_LOJFOR + QEK->QEK_PRODUT + QEK->QEK_REVI + cCodEnsaio

    If QF5->(MsSeek(cChave))

        // Encontrou no histórico
        aRetQep := Qep_RetAmostra(;
            QF5->QF5_TIPAMO,;
            QF5->QF5_PLAMO,;
            QF5->QF5_NIVEL,;
            QF5->QF5_NQA,;
            QEK->QEK_TAMAMO,;
            "QEK_TAMAMO",;
            .F.;
        )

        If ValType(aRetQep) == "A" .And. Len(aRetQep) >= 6

            If QF5->QF5_TIPAMO == "3"

                If Len(aRetQep) > 0 .And. ValType(aRetQep[1]) == "A"
                    aDadosPlno[1] := aRetQep[1][1]
                    aDadosPlno[2] := aRetQep[1][2]
                    aDadosPlno[3] := aRetQep[1][3]

                    If Len(aRetQep) >= 2
                        aDadosPlno[4] := aRetQep[2][1]
                        aDadosPlno[5] := aRetQep[2][2]
                        aDadosPlno[6] := aRetQep[2][3]
                    EndIf
                EndIf

            Else
                aDadosPlno[1] := aRetQep[1]
                aDadosPlno[2] := aRetQep[2]
                aDadosPlno[3] := aRetQep[3]
            EndIf

            lEnconHist := .T.
        EndIf
    EndIf

    // Se não encontrou em histórico, busca em QF4/QF6 (padrão)
    If !lEnconHist
        DbSelectArea(cTabEspec)
        (cTabEspec)->(DbSetOrder(1))

        If (cTabEspec)->(MsSeek(xFilial(cTabEspec) + QEK->QEK_FORNEC + QEK->QEK_LOJFOR + QEK->QEK_PRODUT + QEK->QEK_REVI + cCodEnsaio))

            aRetQep := Qep_RetAmostra(;
                (cTabEspec)->&(cCampoPref + "TIPAMO"),;
                (cTabEspec)->&(cCampoPref + "PLAMO"),;
                (cTabEspec)->&(cCampoPref + "NIVEL"),;
                (cTabEspec)->&(cCampoPref + "NQA"),;
                QEK->QEK_TAMAMO,;
                "QEK_TAMAMO",;
                .F.;
            )

            If ValType(aRetQep) == "A" .And. Len(aRetQep) >= 6

                If (cTabEspec)->&(cCampoPref + "TIPAMO") == "3"

                    If Len(aRetQep) > 0 .And. ValType(aRetQep[1]) == "A"
                        aDadosPlno[1] := aRetQep[1][1]
                        aDadosPlno[2] := aRetQep[1][2]
                        aDadosPlno[3] := aRetQep[1][3]

                        If Len(aRetQep) >= 2
                            aDadosPlno[4] := aRetQep[2][1]
                            aDadosPlno[5] := aRetQep[2][2]
                            aDadosPlno[6] := aRetQep[2][3]
                        EndIf
                    EndIf

                Else
                    aDadosPlno[1] := aRetQep[1]
                    aDadosPlno[2] := aRetQep[2]
                    aDadosPlno[3] := aRetQep[3]
                EndIf
            EndIf
        EndIf
    EndIf

    RestArea(aAreaAnt)

Return aDadosPlno

/*/{Protheus.doc} ContaNaoConformidadesPlanoInterno
Conta não-conformidades para plano interno (PI) com classes A/B/C/D/G.
@type method
@author brunno.costa / willian.ramalho
@since 22/05/2026
@version 1.0
@param oEnsaio, object, Dados do ensaio
@return aContador, array, [NCCríticas, NCGraves, NCToleráveis]
/*/
METHOD ContaNaoConformidadesPlanoInterno(oEnsaio) CLASS QIEPlanoAmostragem

    Local aContador := {0, 0, 0}
    Local aMedicoes := oEnsaio["Medicoes"]
    Local aPlaInt1  := {0, 0, 0, 0, 0, ""} // [Classe, SeqAmostragem, Aceite, Rejeite, TamAmostra, ClassesNC]
    Local aPlaInt2  := {0, 0, 0, 0, 0, ""} // Segunda amostra
    Local cClasse   := ""
    Local nIdx      := 0
    Local nTamAmos1 := oEnsaio["DadosPlano"][1]
    Local nTamAmos2 := oEnsaio["DadosPlano"][4]
    Local oMed      := Nil

    // Inicializa arrays: [Classe, SeqAmostragem, Aceite, Rejeite, TamanhoAmostra, ContadoresClasses]
    aPlaInt1[1] := 1  // Classe A
    aPlaInt1[2] := 1  // Sequência Amostragem
    aPlaInt1[3] := 0  // Aceite (será preenchido)
    aPlaInt1[4] := 0  // Rejeite (será preenchido)
    aPlaInt1[5] := nTamAmos1
    aPlaInt1[6] := "ABCDG" // Caracteres numéricos de NC

    aPlaInt2[1] := 1  // Classe A
    aPlaInt2[2] := 2  // Sequência Amostragem (segunda)
    aPlaInt2[3] := 0  // Aceite
    aPlaInt2[4] := 0  // Rejeite
    aPlaInt2[5] := nTamAmos2
    aPlaInt2[6] := "ABCDG"

    // Conta não-conformidades por amostra
    For nIdx := 1 To Len(aMedicoes)
        oMed := aMedicoes[nIdx]

        If !oMed["RegistroExcluido"] .And. oMed["ResultadoMedicao"] == "R"

            cClasse := Upper(oMed["ClasseNC"])

            // Classes A/B/C (CRITICAs), D/G (GRAVES), Outras (TOLERÁVEIS)
            Do Case
                Case cClasse $ "ABC"
                    If oMed["NumeroAmostra"] == 1
                        aPlaInt1[3]++
                    ElseIf oMed["NumeroAmostra"] == 2
                        aPlaInt2[3]++
                    EndIf
                    aContador[NC_CRITICAS]++

                Case cClasse $ "DG"
                    If oMed["NumeroAmostra"] == 1
                        aPlaInt1[4]++
                    ElseIf oMed["NumeroAmostra"] == 2
                        aPlaInt2[4]++
                    EndIf
                    aContador[NC_GRAVES]++

                OtherWise
                    aContador[NC_TOLERAVEIS]++
            EndCase
        EndIf
    Next nIdx

    If self:lQ215PL1 .Or. self:lQ215PINT
        self:AplicaPEPlanoInterno(aPlaInt1, aPlaInt2)
    EndIf

Return aContador

/*/{Protheus.doc} AplicaPEPlanoInterno
Aplica pontos de entrada para customização de Plano Interno.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@param aPlaInt1, array, Dados primeira amostra
@param aPlaInt2, array, Dados segunda amostra

/*/
METHOD AplicaPEPlanoInterno(aPlaInt1, aPlaInt2) CLASS QIEPlanoAmostragem

    If self:lQ215PL1
        ExecBlock('Q215PL1',.F.,.F.)
    EndIf

    If self:lQ215PINT
        ExecBlock('Q215PINT',.F.,.F., {aPlaInt1, aPlaInt2})
    EndIf

    If self:lQ215PL2
        ExecBlock('Q215PL2',.F.,.F.)
    EndIf

Return

//==============================================================================
// MÉTODOS PÚBLICOS DE ACESSO (GETTERS)
//==============================================================================

/*/{Protheus.doc} RetornaParecer
Retorna parecer calculado.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@return cParecer, character, Parecer (APRV/REPR/ACND/PEND)
/*/
METHOD RetornaParecer() CLASS QIEPlanoAmostragem
Return self:cParecer

/*/{Protheus.doc} RetornaMensagem
Retorna mensagem explicativa.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@return cMensagem, character, Mensagem explicativa
/*/
METHOD RetornaMensagem() CLASS QIEPlanoAmostragem
Return self:cMensagem

/*/{Protheus.doc} RetornaSucesso
Retorna se cálculo foi bem sucedido.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@return lSucesso, lógical, .T. se sucesso, .F. se erro
/*/
METHOD RetornaSucesso() CLASS QIEPlanoAmostragem
Return self:lSucesso

/*/{Protheus.doc} RetornaErro
Retorna mensagem de erro.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@return cErro, character, Mensagem de erro (vazio se sem erro)
/*/
METHOD RetornaErro() CLASS QIEPlanoAmostragem
Return self:cErro

/*/{Protheus.doc} RetornaDetalhes
Retorna detalhes completos do processamento em formato JSON.
@type method
@author brunno.costa / willian.ramalho
@since 29/04/2026
@version 1.0
@return oDetalhes, object, JSON com todos os detalhes
/*/
METHOD RetornaDetalhes() CLASS QIEPlanoAmostragem

    Local oDetalhes := JsonObject():New()

    oDetalhes["Parecer"           ] := self:cParecer
    oDetalhes["Mensagem"          ] := self:cMensagem
    oDetalhes["Sucesso"           ] := self:lSucesso
    oDetalhes["Erro"              ] := self:cErro
    oDetalhes["QuantidadeEnsaios" ] := Len(self:aEnsaios)
    oDetalhes["Resultados"        ] := self:aResultado
    oDetalhes["Aglutinacao"       ] := self:lAglutPlan
    oDetalhes["PlanosAglutinados" ] := self:aAcumAglut

Return oDetalhes
