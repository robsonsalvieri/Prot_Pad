#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTWORK
@type Function
Prepara o ambiente do worker e processa as tarefas disponíveis.
Retira unidades da fila até o fim e registra qualquer falha operacional.

@param cJobId, Character, identificador da transmissão.
@param cCompany, Character, empresa do ambiente.
@param cBranch, Character, filial do ambiente.
@param nWorker, Numeric, número do worker.
@param nRunWait, Numeric, prazo máximo de espera entre fases.
@return Variant, encerra o job sem conteúdo de retorno.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTWORK(cJobId As Character, cCompany As Character, cBranch As Character, nWorker As Numeric, nRunWait As Numeric) As Variant

    Local aCatalog    As Array
    Local aTask       As Array
    Local bOldError   As Block
    Local bTaskError  As Block
    Local cFatalMsg   As Character
    Local cStartMsg   As Character
    Local cTaskMsg    As Character
    Local cTaskStart  As Character
    Local lEnvOpen    As Logical
    Local lFatal      As Logical
    Local lWait       As Logical
    Local lSaved      As Logical
    Local lTaskActive As Logical
    Local lTaskCrash     As Logical
    Local lTaskOK        As Logical
    Local lTaskUncertain As Logical
    Local lUncertain     As Logical
    Local nErrors     As Numeric
    Local nErrorType  As Numeric
    Local nRecords    As Numeric
    Local nSent       As Numeric
    Local nTask       As Numeric
    Local nTaskBranch As Numeric
    Local nWaitLimit  As Numeric
    Local nWaitTry    As Numeric
    Local nSeqIni     As Numeric
    Local nSeqMax     As Numeric
    Local nSeqXML     As Numeric
    Local oError      As Object
    Local oTaskError  As Object

    Default cJobId   := ""
    Default cCompany := ""
    Default cBranch  := ""
    Default nWorker  := 0
    Default nRunWait := 10800

    aCatalog    := {}
    aTask       := {}
    bOldError   := Nil
    bTaskError  := Nil
    cFatalMsg   := ""
    cStartMsg   := ""
    cTaskMsg    := ""
    cTaskStart  := ""
    lEnvOpen    := .F.
    lFatal      := .F.
    lWait       := .F.
    lSaved      := .F.
    lTaskActive := .F.
    lTaskCrash     := .F.
    lTaskOK        := .F.
    lTaskUncertain := .F.
    lUncertain     := .F.
    nErrors     := 0
    nErrorType  := -1
    nRecords    := 0
    nSent       := 0
    nTask       := 0
    nTaskBranch := 0
    nWaitLimit  := Max(1500, Min(54000, Int(nRunWait) * 5))
    nWaitTry    := 0
    nSeqIni     := ((Max(1, Min(8, Int(nWorker))) - 1) * 12000) + 1
    nSeqMax     := nSeqIni + 11999
    nSeqXML     := nSeqIni - 1
    oError      := Nil
    oTaskError  := Nil

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence

        // Abre a empresa antes de acessar a V3J usada pelo acompanhamento.
        RpcSetType(3)
        lEnvOpen := RpcSetEnv(cCompany, cBranch, , , "TAF", "TAFMTWORK")
        If lEnvOpen; TAFMTEXP(cJobId); EndIf

        If !lEnvOpen; lFatal := .T.; cFatalMsg := "Worker " + cValToChar(nWorker) + ": falha ao preparar o ambiente Protheus."; ElseIf !TAFMTWSTA(cJobId, nWorker, @cStartMsg); lFatal := .T.; cFatalMsg := "Worker " + cValToChar(nWorker) + ": " + cStartMsg; EndIf

        If !lFatal
            // O catálogo é invariável dentro do ambiente deste worker.
            aCatalog := aClone(TafRotinas(,,.T.,2))
        EndIf

        If !lFatal

            // Cada worker retira a próxima unidade disponível até esvaziar a fila.
            While !lFatal

                aTask := {}
                nTask := 0
                lWait := .F.

                If !TAFMTCLM(cJobId, nWorker, @nTask, @aTask, @lWait)
                    // Outra unidade da fase atual ainda está em execução.
                    If lWait; nWaitTry++; If nWaitTry >= nWaitLimit; lFatal := .T.; lUncertain := .T.; cFatalMsg := "Worker " + cValToChar(nWorker) + ": prazo de espera entre fases excedido."; Exit; EndIf; Sleep(200); Loop; EndIf
                    Exit
                EndIf

                lTaskActive := .T.
                nWaitTry    := 0
                nSent       := 0
                nErrors    := 0
                nErrorType := -1
                nRecords   := 0
                nTaskBranch := 0
                cTaskMsg  := ""
                cTaskStart := Time()
                lTaskOK        := .F.
                lTaskCrash     := .F.
                lTaskUncertain := .F.
                oTaskError     := Nil
                bTaskError := ErrorBlock({|e| Break(e)})

                Begin Sequence
                    lTaskOK := MTDOTASK(aTask, aCatalog, @nSent, @nErrors, @nErrorType, @nRecords, @cTaskMsg,;
                                           @lTaskUncertain, nSeqIni, nSeqMax, @nSeqXML, cJobId, nTask)
                Recover Using oTaskError; lTaskOK    := .F.; lTaskCrash := .T.; cTaskMsg   := TAFMTERR(oTaskError); End Sequence

                ErrorBlock(bTaskError)

                nTaskBranch := Len(aTask[3])

                TafConOut("[TAFMTWORK][" + cJobId + "][W" + cValToChar(nWorker) +;
                          "][T" + cValToChar(nTask) + "] Tempo=" + ElapTime(cTaskStart, Time()) +;
                          " Filiais=" + cValToChar(nTaskBranch) +;
                          " Processados=" + cValToChar(nRecords) +;
                          " Enviados=" + cValToChar(nSent) + " Erros=" + cValToChar(nErrors))

                // Se a tarefa parar após iniciar o processamento, não repete o envio.
                If lTaskCrash .Or. lTaskUncertain; lFatal := .T.; lUncertain := .T.; cFatalMsg := "Worker " + cValToChar(nWorker) + ": unidade " + cValToChar(nTask) + " com resultado não confirmado: " + cTaskMsg
                Else
                    lSaved := TAFMTDONE(cJobId, nTask, nSent, nErrors, lTaskOK,;
                                        cTaskMsg, nErrorType, nRecords)

                    If !lSaved; lFatal := .T.; lUncertain := .T.; cFatalMsg := "Worker " + cValToChar(nWorker) + ": falha ao consolidar a unidade " + cValToChar(nTask) + "."; Else; lTaskActive := .F.; EndIf
                EndIf

            EndDo

        EndIf

    Recover Using oError; lFatal := .T.; If lTaskActive; lUncertain := .T.; EndIf; cFatalMsg := "Worker " + cValToChar(nWorker) + ": " + TAFMTERR(oError); End Sequence

    If lFatal; TafConOut("[TAFMTWORK][" + cJobId + "] " + cFatalMsg); EndIf

    ASize(aCatalog, 0)
    aCatalog := {}

    If !TAFMTWDON(cJobId, lFatal, cFatalMsg, lEnvOpen, lUncertain, IIf(lTaskActive, nTask, 0)); TafConOut("[TAFMTWORK][" + cJobId + "] Não foi possível registrar o término do worker " + cValToChar(nWorker) + "."); EndIf

    If lEnvOpen
        oError := Nil
        Begin Sequence
            RpcClearEnv()
            lEnvOpen := .F.
        Recover Using oError; TafConOut("[TAFMTWORK][" + cJobId + "] Worker " + cValToChar(nWorker) + ": falha ao liberar o ambiente (não afeta o resultado da transmissão): " + TAFMTERR(oError)); End Sequence
    EndIf

    ErrorBlock(bOldError)

Return Nil

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTDOTASK
@type Static Function
Executa uma tarefa e grava o retorno produzido pelo TAFProc4Tss.
Reconstrói um único evento e preserva os filtros definidos pelo dispatcher.

@param aTask, Array, dados da tarefa.
@param aCatalog, Array, catálogo carregado uma vez no ambiente do worker.
@param nSent, Numeric, quantidade transmitida.
@param nErrors, Numeric, quantidade com erro.
@param nErrorType, Numeric, tipo principal do erro.
@param nRecords, Numeric, quantidade efetivamente percorrida pela tarefa.
@param cMessage, Character, mensagem devolvida ao controle.
@param lUncertain, Logical, indica resultado operacional sem confirmação final.
@param nSeqIni, Numeric, início da faixa XML do worker.
@param nSeqMax, Numeric, fim da faixa XML do worker.
@param nSeqXML, Numeric, sequencial XML atual do worker (referência).
@param cJobId, Character, identificador do job MT para publicação de progresso.
@param nTask, Numeric, unidade MT em processamento.
@return Logical, indica se a tarefa terminou e foi persistida.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTDOTASK(aTask As Array, aCatalog As Array, nSent As Numeric, nErrors As Numeric, nErrorType As Numeric,;
                          nRecords As Numeric, cMessage As Character, lUncertain As Logical, nSeqIni As Numeric, nSeqMax As Numeric,;
                          nSeqXML As Numeric, cJobId As Character, nTask As Numeric) As Logical

    Local aErrorsJob  As Array
    Local aEvents     As Array
    Local aExact      As Array
    Local aMembers    As Array
    Local aRetError   As Array
    Local bOldError   As Block
    Local cErrMsg     As Character
    Local cMsgRet     As Character
    Local lErrLock    As Logical
    Local lErrSaved   As Logical
    Local lNoError    As Logical
    Local lUnlocked   As Logical
    Local nEvent      As Numeric
    Local nMember      As Numeric
    Local nSelected   As Numeric
    Local oError      As Object

    Default aTask      := {}
    Default aCatalog   := {}
    Default nSent      := 0
    Default nErrors    := 0
    Default nErrorType := -1
    Default nRecords   := 0
    Default cMessage   := ""
    Default lUncertain := .F.
    Default nSeqIni     := 0
    Default nSeqMax     := 0
    Default nSeqXML     := 0
    Default cJobId      := ""
    Default nTask       := 0

    aErrorsJob  := {}
    aEvents     := {}
    aExact      := {}
    aMembers    := {}
    aRetError   := {}
    bOldError   := Nil
    cErrMsg     := ""
    cMsgRet     := ""
    lErrLock    := .F.
    lErrSaved   := .T.
    lNoError    := .T.
    lUnlocked   := .F.
    nEvent      := 0
    nMember     := 0
    oError      := Nil

    nSent      := 0
    nErrors    := 0
    nErrorType := -1
    nRecords   := 0
    nSelected  := 0
    cMessage   := ""
    lUncertain := .F.

    aMembers := MTMEMBERS(aTask)

    If Len(aTask) >= 12 .And. ValType(aTask[12]) == "A"
        aExact := aClone(aTask[12])
    EndIf

    If Empty(aMembers); cMessage := "Unidade sem evento definido para transmissão."; Return .F.; EndIf

    For nMember := 1 To Len(aMembers)
        nEvent := MTEVPOS(aCatalog, aMembers[nMember][1], aMembers[nMember][2])
        If nEvent == 0; cMessage := "Evento da unidade não existe no catálogo do worker."; Return .F.; EndIf
        AAdd(aEvents, aClone(aCatalog[nEvent]))
    Next nMember

    // Executa somente os eventos e os filtros pertencentes à unidade retirada.
    aErrorsJob := TAFProc4Tss(;
        .T.,;           // 01 lJob
        aEvents,;       // 02 eventos da unidade reconstruídos no worker
        aTask[4],;      // 03 status
        ,;              // 04 caminho XML
        ,;              // 05 trabalhadores
        aTask[5],;      // 06 recnos (vazio = todos os pendentes do filtro)
        @lNoError,;     // 07 retorno lógico
        @cMsgRet,;      // 08 mensagem
        .T.,;           // 09 força seleção
        aTask[3],;      // 10 filiais desta unidade
        aTask[6],;      // 11 data inicial
        aTask[7],;      // 12 data final
        ,;              // 13 cancelamento
        ,;              // 14 origem MV
        ,;              // 15 tabela temporária externa
        ,;              // 16 validação de acesso omitida pelo serviço REST
        ,;              // 17 retentativa TSS omitida pelo serviço REST
        .T.,;           // 18 chamada API
        aTask[8],;      // 19 período
        ,;              // 20 eventos agendados
        aTask[9],;      // 21 usuário
        aTask[10],;     // 22 motivos
        @aRetError,;    // 23 tipos de erro
        @nSelected,;    // 24 quantidade selecionada pela consulta
        @nRecords,;     // 25 quantidade efetivamente percorrida
        nSeqIni,;       // 26 início da faixa XML deste worker
        nSeqMax,;       // 27 fim da faixa XML deste worker
        @nSeqXML,;      // 28 sequencial XML persistido entre tarefas
        cJobId,;        // 29 job MT para progresso
        nTask,;         // 30 tarefa MT para progresso
        aExact)         // 31 conjunto exato materializado pelo planner

    nRecords := Max(0, Min(Max(0, nSelected), nRecords))

    // Deriva os contadores apenas do retorno confirmado pelo processamento.
    MTCOUNT(aErrorsJob, @nSent, @nErrors)
    nErrorType := MTETYPE(aRetError, lNoError, nErrors)
    cMessage := cMsgRet

    // Um worker por vez grava o retorno compartilhado da transmissão.
    lErrLock := TAFMTLCK("ERRT0X", 12000)
    If !lErrLock; cMessage := MTADDMES(cMessage, "Timeout ao obter o controle de TAFMErrT0X."); If nErrorType < 0; nErrorType := 0; EndIf; lUncertain := .T.; Return .F.; EndIf

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        TAFMErrT0X(aErrorsJob, .T.)
    Recover Using oError; lErrSaved := .F.; cErrMsg   := TAFMTERR(oError); End Sequence

    lUnlocked := TAFMTULK("ERRT0X")
    ErrorBlock(bOldError)

    If !lErrSaved; cMessage := MTADDMES(cMessage, "Falha em TAFMErrT0X: " + cErrMsg); ElseIf !lUnlocked; cMessage := MTADDMES(cMessage, "Falha ao liberar o controle de TAFMErrT0X."); EndIf

    If !lErrSaved .Or. !lUnlocked; lUncertain := .T.; If nErrorType < 0; nErrorType := 0; EndIf; EndIf

Return lNoError .And. lErrSaved .And. lUnlocked

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTCOUNT
@type Static Function
Conta os eventos transmitidos e os eventos devolvidos com erro.
Percorre apenas a estrutura de retorno confirmada pelo TAFProc4Tss.

@param aErrorsJob, Array, retorno do processamento.
@param nSent, Numeric, contador de transmitidos.
@param nErrors, Numeric, contador de erros.
@return Variant, atualiza os contadores por referência.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTCOUNT(aErrorsJob As Array, nSent As Numeric, nErrors As Numeric) As Variant

    Local nBatch  As Numeric
    Local nEvent  As Numeric
    Local xBatch  As Variant
    Local xEvents As Variant

    Default aErrorsJob := {}
    Default nSent      := 0
    Default nErrors    := 0

    nBatch  := 0
    nEvent  := 0
    xBatch  := Nil
    xEvents := Nil

    nSent   := 0
    nErrors := 0

    // Percorre lotes e eventos sem presumir posições que não existam.
    For nBatch := 1 To Len(aErrorsJob)
        xBatch := aErrorsJob[nBatch]
        If ValType(xBatch) == "A"
            If Len(xBatch) >= 3
                xEvents := xBatch[3]
                If ValType(xEvents) == "A"
                    For nEvent := 1 To Len(xEvents)
                        If ValType(xEvents[nEvent]) == "A"
                            If Len(xEvents[nEvent]) >= 1
                                If ValType(xEvents[nEvent][1]) == "L"
                                    If xEvents[nEvent][1]
                                        nSent++
                                    Else
                                        nErrors++
                                    EndIf
                                EndIf
                            EndIf
                        EndIf
                    Next nEvent
                EndIf
            EndIf
        EndIf
    Next nBatch



Return Nil

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTEVPOS
@type Function
Localiza o evento no catálogo carregado pelo worker.
Compara código e alias para reconstruir exatamente o item da tarefa.

@param aCatalog, Array, catálogo disponível no ambiente.
@param cEvent, Character, código do evento.
@param cAlias, Character, alias do evento.
@return Numeric, posição encontrada ou zero.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTEVPOS(aCatalog As Array, cEvent As Character, cAlias As Character) As Numeric

    Local nItem As Numeric

    Default aCatalog := {}
    Default cEvent   := ""
    Default cAlias   := ""

    For nItem := 1 To Len(aCatalog)
        If AllTrim(aCatalog[nItem][3]) == AllTrim(cAlias) .And.;
           AllTrim(aCatalog[nItem][4]) == AllTrim(cEvent)
            Return nItem
        EndIf
    Next nItem


Return 0

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTETYPE
@type Static Function
Identifica o tipo de erro devolvido pelo processamento.
Prioriza os indicadores recebidos e mantém zero para falha genérica.

@param aRetError, Array, indicadores de erro.
@param lNoError, Logical, resultado geral da tarefa.
@param nErrors, Numeric, quantidade de eventos com erro.
@return Numeric, tipo encontrado ou menos um quando não houve erro.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTETYPE(aRetError As Array, lNoError As Logical, nErrors As Numeric) As Numeric

    Local nItem As Numeric
    Local nType As Numeric

    Default aRetError := {}
    Default lNoError  := .T.
    Default nErrors   := 0

    nItem := 0
    nType := -1

    // Usa zero como tipo genérico e substitui pelo indicador específico.
    If !lNoError .Or. nErrors > 0
        nType := 0
        For nItem := 1 To Len(aRetError)
            If aRetError[nItem]
                nType := nItem
            EndIf
        Next nItem
    EndIf

Return nType

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTADDMES
@type Function
Acrescenta uma informação sem apagar a mensagem existente.
Evita separador inicial quando ainda não houver texto no retorno.

@param cMessage, Character, mensagem atual.
@param cExtra, Character, texto que será acrescentado.
@return Character, mensagem combinada.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTADDMES(cMessage As Character, cExtra As Character) As Character

    Default cMessage := ""
    Default cExtra   := ""

    If Empty(cMessage)
        Return cExtra
    EndIf

Return cMessage + " " + cExtra

