#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

// Parâmetro exclusivo do envio, o mesmo lido pelo WSTAF022.
// O parâmetro do retorno (MV_TAFQTMT) não participa deste fluxo.
#DEFINE PAR_MT_THREADS "MV_TAFMTQE"
#DEFINE PAR_MT_BATCH   "MV_TAFMTBF"
#DEFINE PAR_MT_RECBAT  "MV_TAFMTRB"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTSTRT
@type Function
Reserva o job e despacha o planejamento multithread sem bloquear a resposta REST.
Falhas posteriores ao aceite ficam registradas no próprio job para consulta pelo GET STATUS.

@param cJobId, Character, identificador da transmissão.
@param cCompany, Character, empresa do ambiente.
@param cBranch, Character, filial do ambiente.
@param aEvents, Array, evento selecionado.
@param cStatus, Character, situações aceitas.
@param aRecnos, Array, registros selecionados.
@param aBranches, Array, dados das filiais.
@param dDateFrom, Date, data inicial.
@param dDateTo, Date, data final.
@param cPeriod, Character, período da transmissão.
@param cUser, Character, usuário da solicitação.
@param aMotiveCode, Array, motivos informados.
@param nThreads, Numeric, quantidade solicitada de workers.
@param cMessage, Character, mensagem devolvida ao chamador.
@param aProgressTotals, Array, totais selecionados por evento para o progresso visual.
@param lReserveFail, Logical, indica falha ao reservar a empresa para o job.
@return Logical, indica se o job foi reservado e o planejamento assíncrono foi despachado.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTSTRT(cJobId As Character, cCompany As Character, cBranch As Character, aEvents As Array, cStatus As Character, aRecnos As Array, aBranches As Array,;
                   dDateFrom As Date, dDateTo As Date, cPeriod As Character, cUser As Character, aMotiveCode As Array, nThreads As Numeric, cMessage As Character,;
                   aProgressTotals As Array, lReserveFail As Logical) As Logical

    Local bOldError As Block
    Local lStarted  As Logical
    Local oError    As Object

    Default cJobId      := ""
    Default cCompany    := ""
    Default cBranch     := ""
    Default aEvents     := {}
    Default cStatus     := ""
    Default aRecnos     := {}
    Default aBranches   := {}
    Default dDateFrom   := StoD("")
    Default dDateTo     := StoD("")
    Default cPeriod     := ""
    Default cUser       := ""
    Default aMotiveCode := {}
    Default nThreads    := 0
    Default cMessage        := ""
    Default aProgressTotals := {}
    Default lReserveFail     := .F.

    bOldError    := Nil
    lReserveFail := .F.
    lStarted  := .F.
    oError    := Nil

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        lStarted := MTSTART0(cJobId, cCompany, cBranch, aEvents, cStatus, aRecnos, aBranches,;
                             dDateFrom, dDateTo, cPeriod, cUser, aMotiveCode, nThreads, @cMessage, aProgressTotals, @lReserveFail)
    Recover Using oError; cMessage := "Falha ao iniciar a transmissão multithread: " + TAFMTERR(oError); End Sequence

    ErrorBlock(bOldError)

    If !lStarted; TAFMTFAIL(cJobId, cMessage, cCompany, cBranch); EndIf

Return lStarted

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTSTART0
@type Static Function
Reserva o job e devolve o controle ao REST sem executar a seleção pesada no POST.
O planejamento funcional é despachado para TAFMTPLAN e mantém o mesmo JobId.

@param cJobId, Character, identificador da transmissão.
@param cCompany, Character, empresa do ambiente.
@param cBranch, Character, filial do ambiente.
@param aEvents, Array, evento selecionado.
@param cStatus, Character, situações aceitas.
@param aRecnos, Array, registros selecionados.
@param aBranches, Array, dados das filiais.
@param dDateFrom, Date, data inicial.
@param dDateTo, Date, data final.
@param cPeriod, Character, período da transmissão.
@param cUser, Character, usuário da solicitação.
@param aMotiveCode, Array, motivos informados.
@param nThreads, Numeric, quantidade solicitada de workers.
@param cMessage, Character, mensagem devolvida ao chamador.
@param aProgressTotals, Array, totais selecionados por evento para o progresso visual.
@param lReserveFail, Logical, indica falha ao reservar a empresa para o job.
@return Logical, indica se o planejamento assíncrono foi despachado.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTSTART0(cJobId As Character, cCompany As Character, cBranch As Character, aEvents As Array, cStatus As Character, aRecnos As Array, aBranches As Array,;
                         dDateFrom As Date, dDateTo As Date, cPeriod As Character, cUser As Character, aMotiveCode As Array, nThreads As Numeric, cMessage As Character,;
                         aProgressTotals As Array, lReserveFail As Logical) As Logical

    Local bOldError   As Block
    Local cStartError As Character
    Local lDispatched As Logical
    Local nPoolMax    As Numeric
    Local nQprc       As Numeric
    Local nRunWait    As Numeric
    Local nStartWait  As Numeric
    Local oError      As Object

    Default cJobId      := ""
    Default cCompany    := ""
    Default cBranch     := ""
    Default aEvents     := {}
    Default cStatus     := ""
    Default aRecnos     := {}
    Default aBranches   := {}
    Default dDateFrom   := StoD("")
    Default dDateTo     := StoD("")
    Default cPeriod     := ""
    Default cUser       := ""
    Default aMotiveCode := {}
    Default nThreads    := 0
    Default cMessage        := ""
    Default aProgressTotals := {}
    Default lReserveFail     := .F.

    bOldError   := Nil
    cStartError := ""
    lDispatched := .F.
    nPoolMax    := 8
    nQprc       := 0
    nRunWait    := 10800
    nStartWait  := 300
    oError      := Nil
    cMessage    := ""
    lReserveFail := .F.

    If Empty(aBranches); cMessage := "Nenhuma filial válida foi encontrada para a transmissão multithread."; Return .F.; EndIf

    // Resolve os parâmetros uma única vez para que o planejamento assíncrono use
    // exatamente a configuração aceita pelo POST.
    nPoolMax   := MTPARNUM(GetNewPar("MV_TAFMTGP", 8), 8)
    nRunWait   := MTPARNUM(GetNewPar("MV_TAFMTRT", 10800), 10800)
    nStartWait := MTPARNUM(GetNewPar("MV_TAFMTST", 300), 300)
    nQprc      := Max(0, Int(MTPARNUM(GetNewPar("MV_TAFQPRC", 0), 0)))
    nThreads   := Max(0, Min(8, Int(nThreads)))
    nPoolMax   := Max(1, Min(8, Int(nPoolMax)))
    nRunWait   := Max(300, Min(10800, Int(nRunWait)))
    nStartWait := Max(30, Min(3600, Int(nStartWait)))

    // O estado inicial existe antes do 202 para que GET STATUS e recuperação
    // encontrem o JobId imediatamente. Um slot lógico temporário representa o planner.
    If !TAFMTINIT(cJobId, cCompany, cBranch, 0, 1, nStartWait, nRunWait, {}, @cMessage); Return .F.; EndIf
    If !TAFMTACQ(cCompany, cBranch, cJobId, @cMessage, @lReserveFail); Return .F.; EndIf

    lDispatched := .T.
    bOldError   := ErrorBlock({|e| Break(e)})
    Begin Sequence
        StartJob("TAFMTPLAN", GetEnvServer(), .F.,;
                 cJobId, cCompany, cBranch, aEvents, cStatus, aRecnos, aBranches,;
                 dDateFrom, dDateTo, cPeriod, cUser, aMotiveCode, nThreads, aProgressTotals,;
                 nPoolMax, nRunWait, nStartWait, nQprc)
    Recover Using oError; lDispatched := .F.; cStartError := TAFMTERR(oError); End Sequence
    ErrorBlock(bOldError)


    If !lDispatched; cMessage := "Não foi possível iniciar o planejamento da transmissão multithread: " + cStartError; Return .F.; EndIf

    cMessage := "Transmissão multithread aceita e em preparação."

Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTPLAN
@type Function
Executa em thread própria a seleção funcional e a montagem das tarefas do job já aceito.
A seleção, o QPRC, a ordenação e a divisão de tarefas permanecem idênticos ao fluxo anterior;
somente deixam de bloquear a resposta HTTP que entrega o JobId.

@return Logical, indica se o plano foi montado e os workers foram despachados.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTPLAN(cJobId As Character, cCompany As Character, cBranch As Character, aEvents As Array, cStatus As Character, aRecnos As Array, aBranches As Array,;
                   dDateFrom As Date, dDateTo As Date, cPeriod As Character, cUser As Character, aMotiveCode As Array, nThreads As Numeric, aProgressTotals As Array,;
                   nPoolMax As Numeric, nRunWait As Numeric, nStartWait As Numeric, nQprc As Numeric) As Logical

    Local bOldError As Block
    Local cMessage  As Character
    Local cTrackMsg As Character
    Local lEnvOpen  As Logical
    Local lStarted  As Logical
    Local lTracked  As Logical
    Local oError    As Object

    Default cJobId      := ""
    Default cCompany    := ""
    Default cBranch     := ""
    Default aEvents     := {}
    Default cStatus     := ""
    Default aRecnos     := {}
    Default aBranches   := {}
    Default dDateFrom   := StoD("")
    Default dDateTo     := StoD("")
    Default cPeriod     := ""
    Default cUser       := ""
    Default aMotiveCode := {}
    Default nThreads    := 0
    Default aProgressTotals := {}
    Default nPoolMax    := 8
    Default nRunWait    := 10800
    Default nStartWait  := 300
    Default nQprc       := 0

    bOldError := Nil
    cMessage  := ""
    cTrackMsg := ""
    lEnvOpen  := .F.
    lStarted  := .F.
    lTracked  := .F.
    oError    := Nil

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        RpcSetType(3)
        lEnvOpen := RpcSetEnv(cCompany, cBranch, , , "TAF", "TAFMTPLAN")
        If !lEnvOpen; cMessage := "Não foi possível preparar o ambiente para planejar a transmissão multithread."
        Else
            // O planner é rastreado durante a seleção pesada para que a reconciliação
            // local reconheça uma thread viva e não expire a inicialização por engano.
            lTracked := TAFMTWSTA(cJobId, 0, @cTrackMsg)
            If !lTracked; cMessage := IIf(Empty(cTrackMsg), "Não foi possível registrar o planejamento da transmissão multithread.", cTrackMsg)
            Else
                lStarted := MTPLAN0(cJobId, cCompany, cBranch, aEvents, cStatus, aRecnos, aBranches,;
                                    dDateFrom, dDateTo, cPeriod, cUser, aMotiveCode, nThreads, @cMessage,;
                                    aProgressTotals, nPoolMax, nRunWait, nStartWait, nQprc)
            EndIf
        EndIf
    Recover Using oError; lStarted := .F.; cMessage := "Falha ao planejar a transmissão multithread: " + TAFMTERR(oError); End Sequence
    ErrorBlock(bOldError)

    If !lStarted
        TAFMTFAIL(cJobId, cMessage, cCompany, cBranch)
    EndIf

    If lEnvOpen
        bOldError := ErrorBlock({|e| Break(e)})
        Begin Sequence
            RpcClearEnv()
        Recover Using oError; TafConOut("[TAFMTPLAN][" + cJobId + "] Falha ao liberar o ambiente do planner: " + TAFMTERR(oError)); End Sequence
        ErrorBlock(bOldError)
    EndIf

Return lStarted

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTPLAN0
@type Static Function
Materializa o conjunto funcional, configura o estado definitivo e inicia os workers.

@param cJobId, Character, Identificador único do Job de transmissão.
@param cCompany, Character, Código da empresa.
@param cBranch, Character, Código da filial principal.
@param aEvents, Array, Lista de eventos selecionados para processamento.
@param cStatus, Character, Status dos registros filtrados.
@param aRecnos, Array, Lista de R_E_C_N_O_s selecionados.
@param aBranches, Array, Lista de filiais abrangidas pela transmissão.
@param dDateFrom, Date, Data inicial do período de transmissão.
@param dDateTo, Date, Data final do período de transmissão.
@param cPeriod, Character, Competência do período transmitido.
@param cUser, Character, Usuário responsável pela execução.
@param aMotiveCode, Array, Lista de códigos de motivos de afastamento.
@param nThreads, Numeric, Quantidade de threads configuradas.
@param cMessage, Character, Mensagem descritiva de erro ou retorno.
@param aProgressTotals, Array, Lista com os totais de progresso por evento.
@param nPoolMax, Numeric, Limite máximo de workers no pool de conexões.
@param nRunWait, Numeric, Tempo de espera durante a execução (em segundos).
@param nStartWait, Numeric, Tempo de espera na inicialização (em segundos).
@param nQprc, Numeric, Quantidade de registros por lote de processamento.

@return Logical, Retorna .T. se a inicialização e disparo ocorreram com sucesso, senão .F.

@author Denis R. de Oliveira
@since 25/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTPLAN0(cJobId As Character, cCompany As Character, cBranch As Character, aEvents As Array, cStatus As Character, aRecnos As Array, aBranches As Array,;
                        dDateFrom As Date, dDateTo As Date, cPeriod As Character, cUser As Character, aMotiveCode As Array, nThreads As Numeric, cMessage As Character,;
                        aProgressTotals As Array, nPoolMax As Numeric, nRunWait As Numeric, nStartWait As Numeric, nQprc As Numeric) As Logical

    Local aEventStats As Array
    Local aSelection  As Array
    Local aTasks      As Array
    Local bOldError   As Block
    Local cRecFilter  As Character
    Local cStartError As Character
    Local lDispatched As Logical
    Local nAccepted   As Numeric
    Local nTask       As Numeric
    Local nTaskCount  As Numeric
    Local nWorker     As Numeric
    Local nWorkers    As Numeric
    Local oError      As Object

    Default cJobId      := ""
    Default cCompany    := ""
    Default cBranch     := ""
    Default aEvents     := {}
    Default cStatus     := ""
    Default aRecnos     := {}
    Default aBranches   := {}
    Default dDateFrom   := StoD("")
    Default dDateTo     := StoD("")
    Default cPeriod     := ""
    Default cUser       := ""
    Default aMotiveCode := {}
    Default nThreads    := 0
    Default cMessage        := ""
    Default aProgressTotals := {}
    Default nPoolMax    := 8
    Default nRunWait    := 10800
    Default nStartWait  := 300
    Default nQprc       := 0

    aEventStats := {}
    aSelection  := {}
    aTasks      := {}
    bOldError   := Nil
    cRecFilter  := ""
    cStartError := ""
    lDispatched := .F.
    nAccepted   := 0
    nTask       := 0
    nTaskCount  := 0
    nWorker     := 0
    nWorkers    := 0
    oError      := Nil

    nThreads   := Max(0, Min(8, Int(nThreads)))
    nPoolMax   := Max(1, Min(8, Int(nPoolMax)))
    nRunWait   := Max(300, Min(10800, Int(nRunWait)))
    nStartWait := Max(30, Min(3600, Int(nStartWait)))
    nQprc      := Max(0, Int(nQprc))

    If Empty(aBranches); cMessage := "Nenhuma filial válida foi encontrada para a transmissão multithread."; Return .F.; EndIf
    If !MTSCOPEOWN(cCompany, cJobId); cMessage := "A transmissão não possui mais a reserva da empresa para concluir o planejamento."; Return .F.; EndIf

    If Empty(aRecnos) .Or. nQprc > 0
        cRecFilter := MTRINSQL(MTRECS(aRecnos))
        TAFMTSLC(aEvents, cStatus, cRecFilter, aBranches, dDateFrom, dDateTo,;
                 cPeriod, cUser, aMotiveCode, @aSelection, @cMessage)
        aTasks := MTMAKESEL(aEvents, cStatus, aSelection, aBranches, dDateFrom, dDateTo,;
                            cPeriod, cUser, aMotiveCode, Min(nThreads, nPoolMax))
        aSelection := {}
    Else
        aTasks := MTMAKETS(aEvents, cStatus, aRecnos, aBranches, dDateFrom, dDateTo,;
                           cPeriod, cUser, aMotiveCode, Min(nThreads, nPoolMax))
    EndIf


    If Empty(aTasks); cMessage := "Não foi possível montar unidades de trabalho para a transmissão. Verifique os eventos, registros e filiais selecionados."; Return .F.; EndIf

    nTaskCount  := Len(aTasks)
    aEventStats := MTEVINIT(aEvents, aTasks, aProgressTotals)
    nWorkers    := Min(Min(nThreads, MTEVMAX(aEventStats)), nPoolMax)

    TafConOut("[TAFMTSTRT][" + cJobId + "] Solicitados=" +;
              cValToChar(nThreads) + " Tarefas=" + cValToChar(nTaskCount) +;
              " Pool=" + cValToChar(nPoolMax) + " Workers=" +;
              cValToChar(nWorkers))

    // Troca o estado temporário pelo plano real sem recriar o JobId nem a reserva.
    If !TAFMTCFG(cJobId, nTaskCount, nWorkers, nStartWait, nRunWait, aEventStats, @cMessage); Return .F.; EndIf

    For nTask := 1 To nTaskCount
        If !TAFMTADDT(cJobId, nTask, aTasks[nTask]); cMessage := "Falha ao registrar a unidade de trabalho " + cValToChar(nTask) + "."; Return .F.; EndIf
        aTasks[nTask] := Nil
    Next nTask
    aTasks := {}

    If !TAFMTPAC(cJobId, nWorkers, nPoolMax, @cMessage); Return .F.; EndIf

    // Cada StartJob recebe o mesmo identificador, prazo e posição exclusiva.
    For nWorker := 1 To nWorkers
        lDispatched := .T.
        cStartError := ""
        oError      := Nil
        bOldError   := ErrorBlock({|e| Break(e)})

        Begin Sequence
            StartJob("TAFMTWORK", GetEnvServer(), .F.,;
                     cJobId, cCompany, cBranch, nWorker, nRunWait)
        Recover Using oError; lDispatched := .F.; cStartError := TAFMTERR(oError); End Sequence

        ErrorBlock(bOldError)

        If lDispatched; nAccepted++; Else; TAFMTWDON(cJobId, .T., "Worker " + cValToChar(nWorker) + " não iniciado: " + cStartError); EndIf
    Next nWorker

    If nAccepted == 0; cMessage := "Nenhum worker da transmissão multithread foi iniciado."; Return .F.; EndIf

    cMessage := "Transmissão multithread iniciada com " + cValToChar(nAccepted) +;
                " worker(s) e " + cValToChar(nTaskCount) + " unidade(s) de trabalho."

    TafConOut("[TAFMTSTRT][" + cJobId + "] " + cMessage)

Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTMAKETS
@type Function
Divide cada evento em tarefas exclusivas e mantém uma fila dinâmica.
Filiais físicas e blocos de RECNO nunca são processados em duplicidade.

@param aEvents, Array, evento selecionado.
@param cStatus, Character, situações aceitas.
@param aRecnos, Array, registros selecionados.
@param aBranches, Array, dados das filiais.
@param dDateFrom, Date, data inicial.
@param dDateTo, Date, data final.
@param cPeriod, Character, período da transmissão.
@param cUser, Character, usuário da solicitação.
@param aMotiveCode, Array, motivos informados.
@param nThreads, Numeric, quantidade de workers.
@return Array, tarefas prontas para o controle compartilhado.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTMAKETS(aEvents As Array, cStatus As Character, aRecnos As Array, aBranches As Array, dDateFrom As Date, dDateTo As Date,;
                         cPeriod As Character, cUser As Character, aMotiveCode As Array, nThreads As Numeric) As Array

    Local aBranchChunks As Array
    Local aCleanBranch  As Array
    Local aEvent        As Array
    Local aRecChunk     As Array
    Local aRecGroups    As Array
    Local aRecList      As Array
    Local aTask         As Array
    Local aTasks        As Array
    Local cEventAlias   As Character
    Local aGroup        As Array
    Local cEventCode    As Character
    Local lOrdered      As Logical
    Local nMember       As Numeric
    Local nBatchSize    As Numeric
    Local nChunk        As Numeric
    Local nEnd          As Numeric
    Local nEvent        As Numeric
    Local nPosition     As Numeric
    Local nRecBatch     As Numeric
    Local nRecGroup     As Numeric
    Local nRecno        As Numeric
    Local nTaskBatch    As Numeric
    Local xBatchSize    As Variant
    Local xRecBatch     As Variant

    Default aEvents     := {}
    Default cStatus     := ""
    Default aRecnos     := {}
    Default aBranches   := {}
    Default dDateFrom   := StoD("")
    Default dDateTo     := StoD("")
    Default cPeriod     := ""
    Default cUser       := ""
    Default aMotiveCode := {}
    Default nThreads    := 1

    aBranchChunks := {}
    aCleanBranch  := {}
    aEvent        := {}
    aRecChunk     := {}
    aRecGroups    := {}
    aRecList      := {}
    aTask         := {}
    aTasks        := {}
    aGroup        := {}
    cEventAlias   := ""
    lOrdered      := .F.
    nMember       := 0
    cEventCode    := ""
    nBatchSize    := 0
    nChunk        := 0
    nEnd          := 0
    nEvent        := 0
    nPosition     := 0
    nRecBatch     := 0
    nRecGroup     := 0
    nRecno        := 0
    nTaskBatch    := 0
    xBatchSize    := GetNewPar(PAR_MT_BATCH, 1)
    xRecBatch     := GetNewPar(PAR_MT_RECBAT, 500)

    If Empty(aEvents)
        Return {}
    EndIf

    nRecBatch  := Max(1, Min(5000, Int(MTPARNUM(xRecBatch, 500))))
    nThreads   := Max(1, Int(nThreads))
    aCleanBranch := MTBRUNI(aBranches)
    If !Empty(aRecnos); aRecList := MTRECS(aRecnos); EndIf

    If Empty(aCleanBranch); Return {}; EndIf

    nBatchSize := Max(1, Min(250, Int(MTPARNUM(xBatchSize, 1))))

    aGroup := MTGROUP(aEvents, .F.)

    // Preserva a mesma ordem de eventos recebida pelo monitor e separa somente as unidades internas.
    For nEvent := 1 To Len(aEvents)
        aEvent        := aEvents[nEvent]
        aBranchChunks := {}
        aRecGroups    := {}
        cEventAlias   := AllTrim(aEvent[3])
        cEventCode    := AllTrim(aEvent[4])
        nMember       := MTGRPPOS(aGroup, cEventCode)
        lOrdered      := MTISORDER(cEventCode) .Or. nMember > 0

        // Membros seguintes do grupo já foram enviados na unidade conjunta.
        If nMember > 1
            Loop
        EndIf

        If Empty(aRecnos)
            If lOrdered
                AAdd(aBranchChunks, aClone(aCleanBranch))
            Else
                aBranchChunks := MTBRCHKS(aEvent, aCleanBranch, nBatchSize)
            EndIf
            AAdd(aRecGroups, {})
        Else

            If Empty(aRecList); Loop; EndIf

            AAdd(aBranchChunks, aClone(aCleanBranch))

            If lOrdered
                AAdd(aRecGroups, aClone(aRecList))
            Else
                nTaskBatch := Max(1, Int(Len(aRecList) / nThreads))
                nTaskBatch := Min(nRecBatch, nTaskBatch)

                For nRecno := 1 To Len(aRecList) Step nTaskBatch
                    aRecChunk := {}
                    nEnd := Min(nRecno + nTaskBatch - 1, Len(aRecList))
                    For nPosition := nRecno To nEnd
                        AAdd(aRecChunk, aRecList[nPosition])
                    Next nPosition
                    AAdd(aRecGroups, aClone(aRecChunk))
                Next nRecno
            EndIf
        EndIf

        For nChunk := 1 To Len(aBranchChunks)
            For nRecGroup := 1 To Len(aRecGroups)
                aTask := {cEventCode, cEventAlias, aClone(aBranchChunks[nChunk]), cStatus,;
                          MTRINSQL(aRecGroups[nRecGroup]), dDateFrom, dDateTo, cPeriod,;
                          cUser, aClone(aMotiveCode)}
                If nMember == 1
                    AAdd(aTask, aClone(aGroup))
                EndIf
                AAdd(aTasks, aTask)
            Next nRecGroup
        Next nChunk
    Next nEvent

Return aTasks

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTMAKESEL
@type Function
Particiona o conjunto funcional materializado em unidades exclusivas.
Eventos ordenados permanecem em uma única unidade.

@return Array, tarefas prontas para o controle compartilhado.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTMAKESEL(aEvents As Array, cStatus As Character, aSelection As Array, aBranches As Array, dDateFrom As Date, dDateTo As Date,;
                   cPeriod As Character, cUser As Character, aMotiveCode As Array, nThreads As Numeric) As Array

    Local aCleanBranch As Array
    Local aExactChunk  As Array
    Local aGroup       As Array
    Local aRecChunk    As Array
    Local aRows        As Array
    Local aTask        As Array
    Local aTaskBranch  As Array
    Local aTasks       As Array
    Local cEventAlias  As Character
    Local cEventCode   As Character
    Local lOrdered     As Logical
    Local nAssigned    As Numeric
    Local nEnd         As Numeric
    Local nEvent       As Numeric
    Local nMember      As Numeric
    Local nPosition    As Numeric
    Local nRecBatch    As Numeric
    Local nRow         As Numeric
    Local nSelection   As Numeric
    Local nTaskBatch   As Numeric
    Local xRecBatch    As Variant

    Default aEvents     := {}
    Default cStatus     := ""
    Default aSelection  := {}
    Default aBranches   := {}
    Default dDateFrom   := StoD("")
    Default dDateTo     := StoD("")
    Default cPeriod     := ""
    Default cUser       := ""
    Default aMotiveCode := {}
    Default nThreads    := 1

    aCleanBranch := MTBRUNI(aBranches)
    aExactChunk  := {}
    aGroup       := MTGROUP(aEvents, .F.)
    aRecChunk    := {}
    aRows        := {}
    aTask        := {}
    aTaskBranch  := {}
    aTasks       := {}
    cEventAlias  := ""
    cEventCode   := ""
    lOrdered     := .F.
    nAssigned    := 0
    nEnd         := 0
    nEvent       := 0
    nMember      := 0
    nPosition    := 0
    nRecBatch    := 0
    nRow         := 0
    nSelection   := 0
    nTaskBatch   := 0
    nThreads     := Max(1, Int(nThreads))
    xRecBatch    := GetNewPar(PAR_MT_RECBAT, 500)
    nRecBatch    := Max(1, Min(5000, Int(MTPARNUM(xRecBatch, 500))))

    If Empty(aEvents) .Or. Empty(aSelection) .Or. Empty(aCleanBranch); Return {}; EndIf

    For nEvent := 1 To Len(aEvents)
        aRows       := {}
        cEventAlias := AllTrim(aEvents[nEvent][3])
        cEventCode  := AllTrim(aEvents[nEvent][4])
        nMember     := MTGRPPOS(aGroup, cEventCode)
        lOrdered    := MTISORDER(cEventCode) .Or. nMember > 0

        If nMember > 1; Loop; EndIf

        For nSelection := 1 To Len(aSelection)
            If ValType(aSelection[nSelection]) == "A" .And. Len(aSelection[nSelection]) >= 4
                If nMember == 1
                    If MTSELGRP(aGroup, aSelection[nSelection][1], aSelection[nSelection][2])
                        AAdd(aRows, aClone(aSelection[nSelection]))
                    EndIf
                ElseIf Upper(AllTrim(cValToChar(aSelection[nSelection][1]))) == Upper(cEventCode) .And.;
                       Upper(AllTrim(cValToChar(aSelection[nSelection][2]))) == Upper(cEventAlias)
                    AAdd(aRows, aClone(aSelection[nSelection]))
                EndIf
            EndIf
        Next nSelection

        If Empty(aRows); Loop; EndIf

        If lOrdered
            aTask := {cEventCode, cEventAlias, aClone(aCleanBranch), cStatus, "",;
                      dDateFrom, dDateTo, cPeriod, cUser, aClone(aMotiveCode)}
            AAdd(aTask, IIf(nMember == 1, aClone(aGroup), {}))
            AAdd(aTask, aClone(aRows))
            AAdd(aTasks, aTask)
            nAssigned += Len(aRows)
        Else
            nTaskBatch := Max(1, Int(Len(aRows) / nThreads))
            nTaskBatch := Min(nRecBatch, nTaskBatch)

            For nRow := 1 To Len(aRows) Step nTaskBatch
                aExactChunk := {}
                aRecChunk   := {}
                nEnd := Min(nRow + nTaskBatch - 1, Len(aRows))
                For nPosition := nRow To nEnd
                    AAdd(aExactChunk, aClone(aRows[nPosition]))
                    AAdd(aRecChunk, aRows[nPosition][4])
                Next nPosition
                // O conjunto exato já identifica as filiais físicas da unidade.
                // Reduzir o contexto evita refazer a preparação de todas as filiais
                // em cada worker sem alterar os registros materializados pelo planner.
                aTaskBranch := MTSELBRC(aCleanBranch, aExactChunk, cEventAlias, cEventCode)
                aTask := {cEventCode, cEventAlias, aClone(aTaskBranch), cStatus,;
                          MTRINSQL(aRecChunk), dDateFrom, dDateTo, cPeriod, cUser, aClone(aMotiveCode)}
                AAdd(aTask, {})
                AAdd(aTask, aClone(aExactChunk))
                AAdd(aTasks, aTask)
                nAssigned += Len(aExactChunk)
            Next nRow
        EndIf
    Next nEvent

    If nAssigned <> Len(aSelection); aTasks := {}; EndIf

Return aTasks

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTSELBRC
@type Static Function
Reduz o contexto de filiais de uma unidade materializada sem alterar seu conjunto exato.
A otimização só é aplicada quando cada filial física do conjunto exato pode ser
mapeada integralmente para as filiais lógicas recebidas no pedido. Em qualquer
inconsistência, mantém todas as filiais para preservar o comportamento anterior.

@param aBranches, Array, filiais válidas recebidas pelo planner.
@param aExact, Array, conjunto exato evento, alias, filial física e RECNO.
@param cAlias, Character, alias do evento da unidade.
@param cEvent, Character, código do evento da unidade.
@return Array, subconjunto seguro de filiais ou a lista original.

@author Denis R. de Oliveira
@since 25/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTSELBRC(aBranches As Array, aExact As Array, cAlias As Character, cEvent As Character) As Array

    Local aCovered  As Array
    Local aPhysical As Array
    Local aResult   As Array
    Local cEventKey As Character
    Local cExactFil As Character
    Local cPhysical As Character
    Local nBranch   As Numeric
    Local nExact    As Numeric

    Default aBranches := {}
    Default aExact    := {}
    Default cAlias    := ""
    Default cEvent    := ""

    aCovered  := {}
    aPhysical := {}
    aResult   := {}
    cEventKey := StrTran(Upper(AllTrim(cEvent)), "-", "")
    cExactFil := ""
    cPhysical := ""
    nBranch   := 0
    nExact    := 0
    cAlias    := Upper(AllTrim(cAlias))

    If Empty(aBranches) .Or. Empty(aExact) .Or. Empty(cAlias)
        Return aBranches
    EndIf

    // C1E possui semântica especial de filial (_FILTAF em caminhos da consulta).
    // S-1000 também possui regra histórica própria de contexto de filiais.
    If cAlias == "C1E" .Or. cEventKey == "S1000"
        Return aBranches
    EndIf

    // MTMAKESEL só chama esta função com linhas normalizadas de quatro colunas.
    For nExact := 1 To Len(aExact)
        cExactFil := Upper(AllTrim(cValToChar(aExact[nExact][3])))
        If Empty(cExactFil)
            Return aBranches
        EndIf

        If AScan(aPhysical, {|cItem| cItem == cExactFil}) == 0
            AAdd(aPhysical, cExactFil)
        EndIf
    Next nExact

    For nBranch := 1 To Len(aBranches)
        // MTBRUNI já recebeu a estrutura validada de RETINFEMP e preservou a linha completa.
        If aBranches[nBranch][1]
            cPhysical := Upper(AllTrim(cValToChar(xFilial(cAlias, aBranches[nBranch][2]))))
            If !Empty(cPhysical) .And. AScan(aPhysical, {|cItem| cItem == cPhysical}) > 0
                AAdd(aResult, aClone(aBranches[nBranch]))
                If AScan(aCovered, {|cItem| cItem == cPhysical}) == 0
                    AAdd(aCovered, cPhysical)
                EndIf
            EndIf
        EndIf
    Next nBranch

    // Só reduz quando todas as filiais físicas da seleção exata foram cobertas.
    If Empty(aResult) .Or. Len(aCovered) <> Len(aPhysical)
        Return aBranches
    EndIf

Return aResult

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTSELGRP
@type Function
Verifica se um determinado evento e alias estão presentes na matriz de grupos.
Retorna verdadeiro (.T.) caso a combinação seja localizada.

@param aGroup, Array, Matriz contendo os grupos de eventos e seus respectivos alias.
@param cEvent, Character, Código do evento a ser pesquisado.
@param cAlias, Character, Alias da tabela ou entidade a ser pesquisado.
@return Logical, Retorna .T. se a combinação de evento e alias existir no grupo, senão .F.

@author Denis R. de Oliveira
@since 25/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTSELGRP(aGroup As Array, cEvent As Character, cAlias As Character) As Logical

    Default aGroup := {}
    Default cEvent := ""
    Default cAlias := ""

Return AScan(aGroup, {|aItem| Upper(AllTrim(cValToChar(aItem[1]))) == Upper(AllTrim(cEvent)) .And.;
                            Upper(AllTrim(cValToChar(aItem[2]))) == Upper(AllTrim(cAlias))}) > 0

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTEVINIT
@type Function
Monta os contadores por evento usando as tarefas já divididas.
Mantém a mesma ordem recebida do monitor para facilitar o acompanhamento.

@param aEvents, Array, eventos selecionados.
@param aTasks, Array, unidades prontas para execução.
@param aProgressTotals, Array, totais selecionados por evento informados pelo monitor.
@return Array, contadores iniciais por evento.

@author Denis R. de Oliveira
@since 13/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTEVINIT(aEvents As Array, aTasks As Array, aProgressTotals As Array) As Array

    Local aMembers As Array
    Local aStats  As Array
    Local cEvent  As Character
    Local nEvent  As Numeric
    Local nFound  As Numeric
    Local nMember As Numeric
    Local nTask   As Numeric
    Local nTotal  As Numeric

    Default aEvents         := {}
    Default aTasks          := {}
    Default aProgressTotals := {}

    aMembers := {}
    aStats := {}
    cEvent := ""
    nEvent := 0
    nFound := 0
    nMember := 0
    nTask  := 0
    nTotal := 0

    For nEvent := 1 To Len(aEvents)
        cEvent := AllTrim(aEvents[nEvent][4])
        If AScan(aStats, {|aItem| aItem[1] == cEvent}) == 0
            nTotal := MTPROGCT(aProgressTotals, cEvent)
            AAdd(aStats, {cEvent, 0, 0, 0, 0, 0, "queued", nTotal, 0, 0})
        EndIf
    Next nEvent

    For nTask := 1 To Len(aTasks)
        aMembers := MTMEMBERS(aTasks[nTask])
        For nMember := 1 To Len(aMembers)
            nFound := AScan(aStats, {|aItem| aItem[1] == aMembers[nMember][1]})
            If nFound > 0
                aStats[nFound][2]++
            EndIf
        Next nMember
    Next nTask

    For nEvent := Len(aStats) To 1 Step -1
        If aStats[nEvent][2] == 0
            ADel(aStats, nEvent)
            ASize(aStats, Len(aStats) - 1)
        EndIf
    Next nEvent

Return aStats

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTEVMAX
@type Static Function
Obtém o maior número de tarefas existente em uma fase de evento.
Evita abrir workers que ficariam ociosos em todas as fases do job.

@param aStats, Array, contadores iniciais por evento.
@return Numeric, maior quantidade de tarefas de uma fase.

@author Denis R. de Oliveira
@since 14/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTEVMAX(aStats As Array) As Numeric

    Local cEvent As Character
    Local nEvent As Numeric
    Local nMax   As Numeric
    Local nPhase As Numeric

    Default aStats := {}

    cEvent := ""
    nEvent := 0
    nMax   := 1
    nPhase := 0

    For nEvent := 1 To Len(aStats)
        If ValType(aStats[nEvent]) == "A" .And. Len(aStats[nEvent]) >= 2
            cEvent := StrTran(Upper(AllTrim(aStats[nEvent][1])), "-", "")
            nPhase := IIf(Left(cEvent, 3) == "S10", 1, Max(0, Int(aStats[nEvent][2])))
            nMax   := Max(nMax, nPhase)
        EndIf
    Next nEvent

Return nMax

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTPROGCT
@type Static Function
Obtém o total selecionado pelo monitor para o evento informado.
O valor é usado somente na apresentação do progresso e não altera a seleção.

@param aProgressTotals, Array, totais recebidos do monitor.
@param cEvent, Character, código do evento.
@return Numeric, total informado para o evento.

@author Denis R. de Oliveira
@since 14/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTPROGCT(aProgressTotals As Array, cEvent As Character) As Numeric

    Local nItem  As Numeric
    Local nTotal As Numeric

    Default aProgressTotals := {}
    Default cEvent          := ""

    nItem  := 0
    nTotal := 0

    For nItem := 1 To Len(aProgressTotals)
        If ValType(aProgressTotals[nItem]) == "A" .And. Len(aProgressTotals[nItem]) >= 2
            If Upper(AllTrim(cValToChar(aProgressTotals[nItem][1]))) == Upper(AllTrim(cEvent))
                nTotal := Max(0, Int(Val(cValToChar(aProgressTotals[nItem][2]))))
                Exit
            EndIf
        EndIf
    Next nItem

Return nTotal

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTBRUNI
@type Static Function
Remove filiais repetidas antes da criação das tarefas.
Preserva todos os dados da primeira ocorrência de cada código de filial.

@param aBranches, Array, dados das filiais selecionadas.
@return Array, filiais sem repetição.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTBRUNI(aBranches As Array) As Array

    Local aCodes  As Array
    Local aUnique As Array
    Local cCode   As Character
    Local nBranch As Numeric

    Default aBranches := {}

    aCodes  := {}
    aUnique := {}
    cCode   := ""
    nBranch := 0

    // A primeira ocorrência preserva os demais dados cadastrais da filial.
    For nBranch := 1 To Len(aBranches)
        cCode := Upper(AllTrim(cValToChar(aBranches[nBranch][2])))
        If AScan(aCodes, {|cItem| cItem == cCode}) == 0
            AAdd(aCodes, cCode)
            AAdd(aUnique, aClone(aBranches[nBranch]))
        EndIf
    Next nBranch

Return aUnique

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTGROUP
@type Static Function
Monta a lista de eventos que precisam ser consultados em uma única chamada.
Reúne S-2230 com S-3000 para preservar a ordenação conjunta aplicada pela produção.

@param aEvents, Array, eventos selecionados na ordem recebida.
@param lAll, Logical, indica se todos os eventos formam uma única unidade.
@return Array, pares de código e alias que compõem a unidade conjunta.

@author Denis R. de Oliveira
@since 22/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTGROUP(aEvents As Array, lAll As Logical) As Array

    Local aGroup As Array
    Local cEvent As Character
    Local nEvent As Numeric

    Default aEvents := {}
    Default lAll    := .F.

    aGroup := {}
    cEvent := ""
    nEvent := 0

    For nEvent := 1 To Len(aEvents)
        cEvent := AllTrim(aEvents[nEvent][4])
        If lAll .Or. MTISORDER(cEvent)
            AAdd(aGroup, {cEvent, AllTrim(aEvents[nEvent][3])})
        EndIf
    Next nEvent

    // Com limite produtivo por consulta, um único evento também forma a unidade integral.
    If !lAll .And. Len(aGroup) < 2
        aGroup := {}
    EndIf

Return aGroup

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTGRPPOS
@type Static Function
Indica a posição do evento dentro da unidade conjunta.
Zero significa que o evento mantém suas próprias unidades.

@param aGroup, Array, eventos da unidade conjunta.
@param cEvent, Character, código do evento.
@return Numeric, posição do evento na unidade conjunta.

@author Denis R. de Oliveira
@since 22/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTGRPPOS(aGroup As Array, cEvent As Character) As Numeric

    Default aGroup := {}
    Default cEvent := ""

Return AScan(aGroup, {|aItem| aItem[1] == cEvent})

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTISORDER
@type Static Function
Indica se o evento depende da ordenação cronológica aplicada pela consulta de produção.
Esses eventos recebem uma única unidade para preservar a sequência completa.

@param cEvent, Character, código do evento.
@return Logical, indica se o evento não pode ser dividido.

@author Denis R. de Oliveira
@since 22/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTISORDER(cEvent As Character) As Logical

    Default cEvent := ""

    cEvent := StrTran(Upper(AllTrim(cEvent)), "-", "")

Return cEvent == "S2230" .Or. cEvent == "S3000"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTBRCHKS
@type Static Function
Agrupa filiais que apontam para a mesma filial física do evento.
Mantém cada grupo físico inteiro para impedir leituras repetidas.

@param aEvent, Array, dados do evento.
@param aBranches, Array, filiais da transmissão.
@param nBatchSize, Numeric, tamanho máximo do grupo.
@return Array, grupos de filiais prontos para as tarefas.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTBRCHKS(aEvent As Array, aBranches As Array, nBatchSize As Numeric) As Array

    Local aChunk    As Array
    Local aChunks   As Array
    Local aGroups   As Array
    Local aMembers  As Array
    Local aPhysical As Array
    Local cAlias    As Character
    Local cLayout   As Character
    Local cPhysical As Character
    Local nBranch   As Numeric
    Local nFound    As Numeric
    Local nGroup    As Numeric
    Local nMember   As Numeric

    Default aEvent     := {}
    Default aBranches  := {}
    Default nBatchSize := 1

    aChunk    := {}
    aChunks   := {}
    aGroups   := {}
    aMembers  := {}
    aPhysical := {}
    cAlias    := ""
    cLayout   := ""
    cPhysical := ""
    nBranch   := 0
    nFound    := 0
    nGroup    := 0
    nMember   := 0

    cAlias    := AllTrim(aEvent[3])
    cLayout   := AllTrim(aEvent[4])
    nBatchSize := Max(1, Int(nBatchSize))

    If cLayout == "S-1000"
        AAdd(aChunks, aClone(aBranches))

        Return aChunks
    EndIf

    // Agrupa códigos lógicos que acessam a mesma tabela física.
    For nBranch := 1 To Len(aBranches)
        cPhysical := xFilial(cAlias, aBranches[nBranch][2])
        nFound    := AScan(aPhysical, {|cItem| cItem == cPhysical})

        If nFound > 0; AAdd(aGroups[nFound][2], aClone(aBranches[nBranch])); Loop; EndIf
        AAdd(aPhysical, cPhysical)
        AAdd(aGroups, {cPhysical, {aClone(aBranches[nBranch])}})
    Next nBranch

    For nGroup := 1 To Len(aGroups)
        aMembers := aGroups[nGroup][2]


        If !Empty(aChunk) .And. Len(aChunk) + Len(aMembers) > nBatchSize; AAdd(aChunks, aClone(aChunk)); aChunk := {}; EndIf

        For nMember := 1 To Len(aMembers)
            AAdd(aChunk, aClone(aMembers[nMember]))
        Next nMember
    Next nGroup

    If !Empty(aChunk)
        AAdd(aChunks, aClone(aChunk))
    EndIf

Return aChunks

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTRECS
@type Static Function
Normaliza, ordena e remove registros repetidos.
Devolve uma lista estável para a divisão exclusiva dos blocos.

@param aRecnos, Array, registros recebidos no pedido.
@return Array, registros únicos e ordenados.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTRECS(aRecnos As Array) As Array

    Local aSorted As Array
    Local aUnique As Array
    Local cRecno  As Character
    Local nRecno  As Numeric

    Default aRecnos := {}

    aSorted := {}
    aUnique := {}
    cRecno  := ""
    nRecno  := 0

    For nRecno := 1 To Len(aRecnos)
        cRecno := AllTrim(cValToChar(aRecnos[nRecno]))
        If !Empty(cRecno)
            AAdd(aSorted, cRecno)
        EndIf
    Next nRecno

    // A ordenação permite eliminar duplicidades em uma única passagem.
    ASort(aSorted)

    For nRecno := 1 To Len(aSorted)
        If nRecno == 1
            AAdd(aUnique, aSorted[nRecno])
        ElseIf aSorted[nRecno] <> aSorted[nRecno - 1]
            AAdd(aUnique, aSorted[nRecno])
        EndIf
    Next nRecno

Return aUnique

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTRINSQL
@type Static Function
Converte os registros da tarefa para o filtro usado pelo TAFProc4Tss.
Protege aspas e mantém somente os RECNOs atribuídos ao bloco.

@param aRecnos, Array, registros da tarefa.
@return Character, lista protegida e separada por vírgulas.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTRINSQL(aRecnos As Array) As Character

    Local cResult As Character
    Local nRecno  As Numeric

    Default aRecnos := {}

    cResult := ""
    nRecno  := 0

    For nRecno := 1 To Len(aRecnos)
        If nRecno > 1
            cResult += ","
        EndIf
        cResult += "'" + StrTran(cValToChar(aRecnos[nRecno]), "'", "''") + "'"
    Next nRecno

Return cResult

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTPARNUM
@type Function
Lê um parâmetro auxiliar numérico e usa o default quando ele não estiver cadastrado como número.

@param xValue, Variant, conteúdo devolvido pela leitura do parâmetro.
@param nDefault, Numeric, valor usado quando o conteúdo for inválido.
@return Numeric, valor numérico normalizado.

@author Denis R. de Oliveira
@since 11/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTPARNUM(xValue As Variant, nDefault As Numeric) As Numeric

    Default xValue   := Nil
    Default nDefault := 0

    If ValType(xValue) == "N"; Return xValue; EndIf

Return nDefault

