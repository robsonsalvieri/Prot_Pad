#Include "TOTVS.ch"

/*/{Protheus.doc} PONA490
    Responsável por executar a tarefa em segundo plano que gera o relatório Espelho de Ponto do Smart View e o integra no TAE.
    @type Function
    @version 12.1.2310
    @author arthur.sales
    @since 16/05/2024
    @return Variant, Retorno nulo pré-fixado
/*/
Function PONA490() As Variant
    // Chama a função que executará a integração por meio de um Processa() para envio de notificação pelo EventViewer
    Processa({|| ExecIntegTAE()})
Return NIL

/*/{Protheus.doc} ExecIntegTAE
    Executa a integração no TAE.
    @type Function
    @version 12.1.2310
    @author arthur.sales
    @since 16/05/2024
    @return Logical, Indica o sucesso do processamento
/*/
Static Function ExecIntegTAE() As Logical
    // Declaração das variáveis locais
    Local cFile      As Character // Nome do arquivo
    Local cCodeBar   As Character // Código de barras
    Local cPathFile  As Character // Caminho completo do arquivo
    Local lMRHTae    As Logical   // Método de assinatura do TAE caso o cliente utilize o MeuRH
    Local lSuccess   As Logical   // Indica o sucesso do processamento
    Local dPerIni    As Date      // Período inicial
    Local dPerFim    As Date      // Período final
    Local oSign      As Object    // Instância da classe FwTotvsSign()
    Local oSmartView As Object    // Instância da classe CallSmartView()
    Local jPrint     As JSON      // Informações para a impressão do artefato do Smart View

    // Inicialização das variáveis
    cFile      := MV_PAR14
    cCodeBar   := MV_PAR18
    cPathFile  := "spool\" + cFile + ".pdf"
    lSuccess   := .F.
    lMRHTae    := MV_PAR15
    dPerIni    := MV_PAR16
    dPerFim    := MV_PAR17
    oSign      := NIL
    oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.pon.ponr010.default.rep", "report")
    jPrint     := JSONObject():New()

    // Define o tamanho da régua de processamento
    ProcRegua(1)

    BEGIN SEQUENCE
        // Valida a autenticação com o TAE
        If (!SetUpSign(@oSign))
            FwLogMsg("WARN", NIL, "PONA490", NIL, NIL, NIL, "Erro na autenticação com o TAE.")
            BREAK
        EndIf

        // Define os parâmetros do artefato do Smart View
        oSmartView:setParam("DateFrom",         totvs.framework.treports.date.stringToTimeStamp(DToS(MV_PAR01)))
        oSmartView:setParam("DateTo",           totvs.framework.treports.date.stringToTimeStamp(DToS(MV_PAR02)))
        oSmartView:setParam("BranchCodeFrom",   MV_PAR03)
        oSmartView:setParam("BranchCodeTo",     MV_PAR03)
        oSmartView:setParam("EmployeeCodeFrom", MV_PAR04)
        oSmartView:setParam("EmployeeCodeTo",   MV_PAR04)
        oSmartView:setParam("PrintHours",       IIf(MV_PAR05 == 0, "", Str(MV_PAR05, 1)))
        oSmartView:setParam("ShowHours",        IIf(MV_PAR06 == 0, "", Str(MV_PAR06, 1)))
        oSmartView:setParam("WithoutPunch",     IIf(MV_PAR07 == 1, .T., .F.))
        oSmartView:setParam("HoursType",        IIf(MV_PAR08 == 0, "", Str(MV_PAR08, 1)))
        oSmartView:setParam("PrintEvents",      IIf(MV_PAR09 == 1, .T., .F.))
        oSmartView:setParam("PrintException",   IIf(MV_PAR10 == 1, .T., .F.))
        oSmartView:setParam("TAEIntegration",   .F.)
        oSmartView:setParam("PrintHoursBank",   IIf(MV_PAR11 == 1, .T., .F.))
        oSmartView:setParam("PrintExtraHour",   IIf(MV_PAR12 == 1, .T., .F.))
        oSmartView:setParam("PrintDisreg",      IIf(MV_PAR13 == 1, .T., .F.))

        // Posiciona no registro do funcionário
        DBSelectArea("SRA")
        DBSetOrder(1) // RA_FILIAL + RA_MAT + RA_NOME
        MsSeek(MV_PAR03 + MV_PAR04)

        // Define como sem interface
        oSmartView:setNoInterface(.T.)

        // Força a definição dos parâmetros (sem isso alguns parâmetros não estavam sendo definidos corretamente)
        oSmartView:setForceParams(.T.)

        // Define o tipo de impressão
        oSmartView:setPrintType(1) // 1 = Arquivo | 2 = E-mail

        // Preenche e define as informações de impressão
        jPrint["name"]      := cFile
        jPrint["path"]      := "spool\"
        jPrint["extension"] := "pdf"
        oSmartView:setPrintInfo(jPrint)

        // Executa a geração do relatório
        If (oSmartView:executeSmartView())
            // Faz o upload do documento para o TAE
            totvs.protheus.rh.treportsintegratedprovider.SendTAE(cPathFile, cFile + ".pdf", lMRHTae, oSign, .T., dPerIni, dPerFim, cCodeBar)

            // Se o arquivo foi criado, o deleta
            If (File(cPathFile))
                fErase(cPathFile)
                lSuccess := .T.
            EndIf
        EndIf
    END SEQUENCE

    // Incrementa a régua de processamento
    IncProc()

    // Libera os objetos da memória
    FwFreeObj(oSign)
    FwFreeObj(oSmartView)
    FwFreeObj(jPrint)
Return lSuccess

/*/{Protheus.doc} SchedDef
    Definições de agendamento do Schedule.
    @type Function
    @version 12.1.2310
    @author arthur.sales
    @since 21/05/2024
    @return Array, Definições do agendamento
/*/
Static Function SchedDef() As Array
    // Declaração das variáveis locais
    Local aParam As Array

    // Inicialização das variáveis
    aParam := {}

    // Montagem da estrutura do vetor de retorno
    AAdd(aParam, "P")       // Tipo do agendamento: "P" = Processo | "R" = Relatório
    AAdd(aParam, "PONA490") // Pergunte (SX1) (usar "PARAMDEF" caso não tenha conjunto de perguntas)
    AAdd(aParam, "")        // Alias principal (exclusivo para relatórios)
    AAdd(aParam, {})        // Vetor de ordenação (exclusivo para relatórios)
    AAdd(aParam, "")        // Título (exclusivo para relatórios)
Return aParam
