#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

// Estado do job. Os índices são privados deste fonte; os consumidores recebem
// o array completo somente para leitura (TAFMTGET).
#DEFINE MT_ID       1
#DEFINE MT_STATUS   2
#DEFINE MT_TOTAL    3
#DEFINE MT_DONE     4
#DEFINE MT_WORKERS  5
#DEFINE MT_WDONE    6
#DEFINE MT_SENT     7
#DEFINE MT_ERRORS   8
#DEFINE MT_FAILED   9
#DEFINE MT_MESSAGE 10
#DEFINE MT_CDATE   11
#DEFINE MT_CTIME   12
#DEFINE MT_UDATE   13
#DEFINE MT_UTIME   14
#DEFINE MT_COMPANY 15
#DEFINE MT_BRANCH  16
#DEFINE MT_NEXT    17
#DEFINE MT_WFAILED 18
#DEFINE MT_WSTART  19
#DEFINE MT_STWAIT  20
#DEFINE MT_RTWAIT  21
#DEFINE MT_TKGROUP 11
#DEFINE MT_TYPES   22
#DEFINE MT_EVENTS  23
#DEFINE MT_PHASE   24
#DEFINE MT_ACTIVE  25
#DEFINE MT_PDATE   26
#DEFINE MT_PTIME   27
#DEFINE MT_OWNER   28
#DEFINE MT_THREADS 29
#DEFINE MT_PROGRESS 30
#DEFINE MT_HEARTBEAT_WAIT 900

#DEFINE EV_CODE     1
#DEFINE EV_TOTAL    2
#DEFINE EV_DONE     3
#DEFINE EV_SENT     4
#DEFINE EV_ERRORS   5
#DEFINE EV_FAILED   6
#DEFINE EV_STATUS   7
#DEFINE EV_RTOTAL   8
#DEFINE EV_RDONE    9
#DEFINE EV_AGGREG   10

#DEFINE MT_QUEUED  "queued"
#DEFINE MT_RUNNING "running"
#DEFINE MT_OK      "completed"
#DEFINE MT_PARTIAL "completed_with_errors"
#DEFINE MT_ERROR   "failed"
#DEFINE MT_UNCERT  "requires_reconciliation"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTPAC
@type Function
Reserva no AppServer os workers do job antes de iniciar as tarefas.
Limita a soma local para não sobrecarregar o processo que recebeu o POST.

@param cJobId, Character, identificador da transmissão.
@param nWorkers, Numeric, quantidade de workers do job.
@param nLimit, Numeric, limite compartilhado do AppServer.
@param cMessage, Character, mensagem devolvida ao chamador.
@return Logical, indica se a capacidade foi reservada.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTPAC(cJobId As Character, nWorkers As Numeric, nLimit As Numeric, cMessage As Character) As Logical

    Local aCurrent  As Array
    Local aLive     As Array
    Local aPool     As Array
    Local bOldError As Block
    Local cUID      As Character
    Local lChanged  As Logical
    Local lKnown    As Logical
    Local lReserved As Logical
    Local lSaved    As Logical
    Local lStarted  As Logical
    Local nItem     As Numeric
    Local nJobPos   As Numeric
    Local nLive     As Numeric
    Local nLivePos  As Numeric
    Local nUsed     As Numeric
    Local oError    As Object

    Default cJobId   := ""
    Default nWorkers := 0
    Default nLimit   := 0
    Default cMessage := ""

    aCurrent  := {}
    aLive     := {}
    aPool     := {}
    bOldError := Nil
    cUID      := "TAFMT_POOL"
    lChanged  := .F.
    lKnown    := .F.
    lReserved := .F.
    lSaved    := .F.
    lStarted  := .F.
    nItem     := 0
    nJobPos   := 0
    nLive     := 0
    nLivePos  := 0
    nUsed     := 0
    oError    := Nil
    cMessage  := ""

    // Sem o pool local, o job continua para não transformar a proteção adicional em bloqueio.
    If !VarSetUID(cUID, .T.); Return .T.; EndIf

    lStarted := MTBTX(cUID, "POOL", 400)
    If !lStarted; Return .T.; EndIf

    // A cópia do pool é obtida sem manter o mutex enquanto cada job é verificado.
    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        If !VarGetAD(cUID, "POOL", @aPool)
            aPool := {}
        EndIf
        lSaved := .T.
    Recover Using oError; lSaved := .F.; End Sequence

    lSaved := MTENDT(cUID, "POOL", lSaved)
    ErrorBlock(bOldError)

    If !lSaved; Return .T.; EndIf

    // O snapshot é validado fora do mutex; entradas inconclusivas permanecem reservadas.
    For nItem := 1 To Len(aPool)
        If ValType(aPool[nItem]) == "A" .And. Len(aPool[nItem]) >= 2 .And.;
           ValType(aPool[nItem][1]) == "C" .And. ValType(aPool[nItem][2]) == "N"
            nLive := -1
            If !MTPPOOLLIVE(aPool[nItem][1], @nLive); nLive := -1; EndIf
            AAdd(aLive, {aPool[nItem][1], nLive, aPool[nItem][2]})
        EndIf
    Next nItem

    lStarted := MTBTX(cUID, "POOL", 400)
    If !lStarted; Return .T.; EndIf

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        If !VarGetAD(cUID, "POOL", @aCurrent)
            aCurrent := {}
        EndIf
        lKnown := .T.
            For nItem := Len(aCurrent) To 1 Step -1
                nLivePos := 0
                If ValType(aCurrent[nItem]) == "A" .And. Len(aCurrent[nItem]) >= 2 .And.;
                   ValType(aCurrent[nItem][1]) == "C" .And. ValType(aCurrent[nItem][2]) == "N"
                    nLivePos := AScan(aLive, {|x| x[1] == aCurrent[nItem][1]})

                    If nLivePos > 0 .And. aLive[nLivePos][2] >= 0 .And.;
                       aCurrent[nItem][2] == aLive[nLivePos][3]
                        If aLive[nLivePos][2] > 0; If aCurrent[nItem][2] <> aLive[nLivePos][2]; aCurrent[nItem][2] := aLive[nLivePos][2]; lChanged := .T.; EndIf; nUsed += Max(0, aCurrent[nItem][2]); Else; ADel(aCurrent, nItem); ASize(aCurrent, Len(aCurrent) - 1); lChanged := .T.; EndIf
                    Else
                        // Entrada nova, alterada ou inconclusiva não é saneada nesta passagem.
                        nUsed += Max(0, aCurrent[nItem][2])
                    EndIf
                Else; ADel(aCurrent, nItem); ASize(aCurrent, Len(aCurrent) - 1); lChanged := .T.; EndIf
            Next nItem

            nJobPos := AScan(aCurrent, {|x| x[1] == cJobId})
            If nJobPos > 0
                lReserved := .T.
            ElseIf nUsed + nWorkers <= nLimit
                AAdd(aCurrent, {cJobId, nWorkers})
                lChanged  := .T.
                lReserved := .T.
            Else
                cMessage := "O limite de workers desta instância já está sendo utilizado por uma transmissão em execução." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                            "Tente novamente em alguns minutos."
            EndIf

            lSaved := IIf(lChanged, VarSetAD(cUID, "POOL", aCurrent), .T.)
    Recover Using oError; lKnown := .F.; lSaved := .F.; cMessage := ""; End Sequence

    lSaved := MTENDT(cUID, "POOL", lSaved)
    ErrorBlock(bOldError)

    If !lReserved .And. lKnown .And. lSaved .And. !Empty(cMessage); Return .F.; EndIf

    If !lReserved .Or. !lSaved; cMessage := ""; EndIf


Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTACQ
@type Function
Reserva a empresa na V3J para impedir dois envios paralelos em uma farm.

@param cCompany, Character, empresa do ambiente.
@param cBranch, Character, filial do ambiente.
@param cJobId, Character, identificador da transmissão.
@param cMessage, Character, mensagem devolvida ao chamador.
@return Logical, indica se a empresa foi reservada.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTACQ(cCompany As Character, cBranch As Character, cJobId As Character, cMessage As Character, lConflict As Logical) As Logical

    Local aArea       As Array
    Local bOldError   As Block
    Local cOldJob     As Character
    Local cReconJob   As Character
    Local cReconState As Character
    Local cScopeId    As Character
    Local lAcquired   As Logical
    Local lLocked     As Logical
    Local oError      As Object

    Default cCompany  := ""
    Default cBranch   := ""
    Default cJobId    := ""
    Default cMessage  := ""

    aArea       := GetArea()
    bOldError   := Nil
    cOldJob     := ""
    cReconJob   := ""
    cReconState := ""
    cScopeId    := MTSCOPEID(cCompany)
    lAcquired   := .F.
    lConflict   := .F.
    lLocked     := .F.
    oError      := Nil
    cMessage    := ""

    If Empty(cCompany) .Or. Empty(cScopeId) .Or. Empty(cJobId); cMessage := "Empresa ou identificador inválido para reservar a transmissão."; Return .F.; EndIf

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        DbSelectArea("V3J")
        V3J->(DbSetOrder(1))

        // MTSCOPEN já posiciona a V3J no registro de controle da empresa.
        If MTSCOPEN(cScopeId)
            cOldJob := AllTrim(V3J->V3J_PARAMS)

            If V3J->V3J_STATUS == "1" .And. !Empty(cOldJob)
                cReconJob := cOldJob
                cReconState := TAFMNRCN(cOldJob, @cMessage)
                If cReconState <> "active"; cReconState := TAFMTRCN(cOldJob, @cMessage); EndIf
                If cReconState == "terminal" .Or. cReconState == "absent"
                    TAFMTREL(cCompany, cBranch, cOldJob)
                    cMessage := ""
                EndIf
                V3J->(DbSetOrder(1))
                V3J->(DbSeek(MTDBKEY(cScopeId)))
                cOldJob := AllTrim(V3J->V3J_PARAMS)
            EndIf

            // Uma troca concorrente de registro recebe a mesma validação antes de bloquear.
            If V3J->V3J_STATUS == "1" .And. !Empty(cOldJob) .And. cOldJob <> cReconJob; cReconJob := cOldJob; cReconState := TAFMNRCN(cOldJob, @cMessage); If cReconState <> "active"; cReconState := TAFMTRCN(cOldJob, @cMessage); EndIf; If cReconState == "terminal" .Or. cReconState == "absent"; TAFMTREL(cCompany, cBranch, cOldJob); cMessage := ""; EndIf; V3J->(DbSetOrder(1)); V3J->(DbSeek(MTDBKEY(cScopeId))); cOldJob := AllTrim(V3J->V3J_PARAMS); EndIf

            // Estado técnico inconclusivo não mantém exclusividade sem prova positiva de execução.
            // O snapshot do job permanece na V3J; somente o controle da empresa é liberado.
            If cReconState == "unknown" .And. cOldJob == cReconJob .And. TAFMTREL(cCompany, cBranch, cOldJob)
                cReconState := "absent"
                cMessage := ""
            EndIf

            If V3J->V3J_STATUS == "1" .And. !Empty(cOldJob)
                If cOldJob == cReconJob .And. (cReconState == "terminal" .Or. cReconState == "absent")
                    lLocked := RecLock("V3J", .F.)
                    If lLocked
                        If AllTrim(V3J->V3J_PARAMS) == cOldJob; V3J->V3J_STATUS := "1"; V3J->V3J_PARAMS := cJobId; V3J->V3J_DTREQ := Date(); V3J->V3J_HRREQ := StrTran(Time(), ":", ""); V3J->V3J_PERC := 0; lAcquired := .T.; EndIf
                        V3J->(MsUnlock()); lLocked := .F.
                    EndIf
                Else
                    // O estado reconciliado define o conflito; a mensagem apenas informa o usuário.
                    lConflict := cReconState == "active" .Or. cReconState == "requires_reconciliation"
                EndIf
                If !lAcquired .And. Empty(cMessage); cMessage := "Já existe uma transmissão do eSocial em processamento para esta empresa." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Para evitar duas transmissões simultâneas, este novo processamento não foi iniciado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Tente novamente em alguns minutos."; EndIf
            Else
                lLocked := RecLock("V3J", .F.)
                If lLocked
                    cOldJob := AllTrim(V3J->V3J_PARAMS)
                    If V3J->V3J_STATUS == "1" .And. !Empty(cOldJob); lConflict := .T.; cMessage := "Já existe uma transmissão do eSocial em processamento para esta empresa." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Para evitar duas transmissões simultâneas, este novo processamento não foi iniciado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Tente novamente em alguns minutos."; Else
                        V3J->V3J_STATUS := "1"
                        V3J->V3J_PARAMS := cJobId
                        V3J->V3J_DTREQ  := Date()
                        V3J->V3J_HRREQ  := StrTran(Time(), ":", "")
                        V3J->V3J_PERC   := 0
                        lAcquired       := .T.
                    EndIf
                    V3J->(MsUnlock())
                    lLocked := .F.
                EndIf
            EndIf
        EndIf
    Recover Using oError; lAcquired := .F.; cMessage := "Falha no controle de exclusividade: " + TAFMTERR(oError); End Sequence

    If lLocked; V3J->(MsUnlock()); EndIf
    ErrorBlock(bOldError)
    RestArea(aArea)


    If !lAcquired .And. Empty(cMessage); cMessage := "Não foi possível reservar a empresa para a transmissão."; EndIf

Return lAcquired

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTREL
@type Function
Libera na V3J somente a reserva pertencente ao job informado.
O resumo do processamento permanece disponível para consulta.

@param cCompany, Character, empresa do ambiente.
@param cBranch, Character, filial do ambiente.
@param cJobId, Character, identificador da transmissão.
@return Logical, indica se a reserva foi liberada ou já não pertencia ao job.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTREL(cCompany As Character, cBranch As Character, cJobId As Character) As Logical

    Local aArea     As Array
    Local bOldError As Block
    Local cScopeId  As Character
    Local lLocked   As Logical
    Local lReleased As Logical
    Local oError    As Object

    Default cCompany := ""
    Default cBranch  := ""
    Default cJobId   := ""

    aArea     := GetArea()
    bOldError := Nil
    cScopeId  := MTSCOPEID(cCompany)
    lLocked   := .F.
    lReleased := .F.
    oError    := Nil

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        DbSelectArea("V3J")
        V3J->(DbSetOrder(1))

        If !V3J->(DbSeek(MTDBKEY(cScopeId)))
            lReleased := .T.
        ElseIf AllTrim(V3J->V3J_PARAMS) <> cJobId
            lReleased := .T.
        Else
            lLocked := RecLock("V3J", .F.)
            If lLocked
                If AllTrim(V3J->V3J_PARAMS) == cJobId
                    V3J->V3J_STATUS := "2"
                    V3J->V3J_DTRESP := Date()
                    V3J->V3J_HRRESP := StrTran(Time(), ":", "")
                EndIf
                V3J->(MsUnlock())
                lLocked   := .F.
                lReleased := .T.
            EndIf
        EndIf
    Recover Using oError; lReleased := .F.; TafConOut("[TAFMTREL] " + TAFMTERR(oError)); End Sequence

    If lLocked; V3J->(MsUnlock()); EndIf
    ErrorBlock(bOldError)
    RestArea(aArea)

Return lReleased

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMNACQ
@type Function
Registra uma observação Mono no escopo compartilhado sem impedir o processamento síncrono.

@param cCompany, Character, empresa do ambiente.
@param cBranch, Character, filial do ambiente.
@param cJobId, Character, identificador da transmissão Mono.
@return Logical, indica se a observação foi registrada.

@author Denis R. de Oliveira
@since 19/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMNACQ(cCompany As Character, cBranch As Character, cJobId As Character) As Logical

    Local aArea     As Array
    Local bOldError As Block
    Local cOldJob   As Character
    Local cScopeId  As Character
    Local lLocked   As Logical
    Local lMarked   As Logical
    Local lReserved As Logical
    Local oError    As Object

    Default cCompany := ""
    Default cBranch  := ""
    Default cJobId   := ""

    aArea     := GetArea()
    bOldError := Nil
    cOldJob   := ""
    cScopeId  := ""
    lLocked   := .F.
    lMarked   := .F.
    lReserved := .F.
    oError    := Nil

    If Empty(cCompany) .Or. Empty(cJobId); Return .F.; EndIf
    If !TAFALSINDIC("V3J"); Return .F.; EndIf

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        cScopeId := MTSCOPEID(cCompany)
        lMarked  := !Empty(cScopeId) .And. MNDBSET(cJobId, cCompany, cBranch, .T.)

        If lMarked
            DbSelectArea("V3J")
            V3J->(DbSetOrder(1))

            If MTSCOPEN(cScopeId)
                lLocked := RecLock("V3J", .F.)
                If lLocked
                    cOldJob := AllTrim(V3J->V3J_PARAMS)
                    If V3J->V3J_STATUS <> "1" .Or. Empty(cOldJob)
                        V3J->V3J_STATUS := "1"
                        V3J->V3J_PARAMS := cJobId
                        V3J->V3J_DTREQ  := Date()
                        V3J->V3J_HRREQ  := StrTran(Time(), ":", "")
                        V3J->V3J_PERC   := 0
                        lReserved       := .T.
                    EndIf
                    V3J->(MsUnlock())
                    lLocked := .F.
                EndIf
            EndIf
        EndIf
    Recover Using oError; lReserved := .F.; TafConOut("[TAFMNACQ] " + TAFMTERR(oError)); End Sequence

    If lLocked; V3J->(MsUnlock()); EndIf
    ErrorBlock(bOldError)
    RestArea(aArea)

    If lMarked .And. !lReserved; MNDBSET(cJobId, cCompany, cBranch, .F.); EndIf

Return lReserved

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMNREL
@type Function
Finaliza a observação Mono e libera somente o escopo pertencente ao identificador informado.

@param cCompany, Character, empresa do ambiente.
@param cBranch, Character, filial do ambiente.
@param cJobId, Character, identificador da transmissão Mono.
@return Logical, indica se o controle e o escopo foram finalizados.

@author Denis R. de Oliveira
@since 19/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMNREL(cCompany As Character, cBranch As Character, cJobId As Character) As Logical

    Local lReleased As Logical
    Local lSaved    As Logical

    Default cCompany := ""
    Default cBranch  := ""
    Default cJobId   := ""

    lReleased := .F.
    lSaved    := MNDBSET(cJobId, cCompany, cBranch, .F.)
    lReleased := TAFMTREL(cCompany, cBranch, cJobId)

Return lSaved .And. lReleased

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMNRCN
@type Function
Avalia a observação Mono antes de o MT reutilizar o escopo da empresa.

@param cJobId, Character, identificador da transmissão Mono.
@param cMessage, Character, mensagem devolvida ao chamador.
@return Character, active, absent ou unknown.

@author Denis R. de Oliveira
@since 19/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMNRCN(cJobId As Character, cMessage As Character) As Character

    Local aInfo        As Array
    Local bOldError    As Block
    Local cBranch      As Character
    Local cCompany     As Character
    Local cPort        As Character
    Local cServer      As Character
    Local lAccessOk    As Logical
    Local lActive      As Logical
    Local lThreadRead  As Logical
    Local nAge         As Numeric
    Local nRemaining   As Numeric
    Local nThread      As Numeric
    Local oError       As Object

    Default cJobId   := ""
    Default cMessage := ""

    aInfo       := {}
    bOldError   := Nil
    cBranch     := ""
    cCompany    := ""
    cPort       := ""
    cServer     := ""
    lAccessOk   := .F.
    lActive     := .F.
    lThreadRead := .F.
    nAge        := 0
    nRemaining  := 0
    nThread     := 0
    oError      := Nil
    cMessage    := ""

    If Empty(cJobId); cMessage := "Identificador inválido para reconciliação Mono."; Return "unknown"; EndIf

    If !MNDBGET(cJobId, @cCompany, @cBranch, @lActive, @cServer, @cPort, @nThread, @lAccessOk, @nAge); If lAccessOk; Return "absent"; EndIf; Return "absent"; EndIf

    If !lActive
        TAFMNREL(cCompany, cBranch, cJobId)
        Return "absent"
    EndIf

    If nThread <= 0; TAFMNREL(cCompany, cBranch, cJobId); Return "absent"; EndIf

    If nAge >= 10800
        TAFMNREL(cCompany, cBranch, cJobId)
        Return "absent"
    EndIf

    nRemaining := Max(1, Int((10800 - nAge + 59) / 60))

    If !Empty(cServer) .And. !Empty(cPort) .And. Upper(cServer + "|" + cPort) == MTOWNER()
        bOldError := ErrorBlock({|e| Break(e)})
        Begin Sequence
            aInfo       := GetUserInfoArray()
            lThreadRead := .T.
        Recover Using oError; lThreadRead := .F.; End Sequence
        ErrorBlock(bOldError)


        If !lThreadRead; TAFMNREL(cCompany, cBranch, cJobId); Return "absent"; EndIf
        If AScan(aInfo, {|x| x[3] == nThread}) == 0; TAFMNREL(cCompany, cBranch, cJobId); Return "absent"; EndIf
    EndIf

    cMessage := "Já existe uma transmissão do eSocial em modo Monothread para esta empresa." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                "Para evitar duas transmissões simultâneas, este novo processamento ainda não foi iniciado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                "A proteção será liberada automaticamente em até " + cValToChar(nRemaining) + IIf(nRemaining == 1, " minuto.", " minutos.") + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                "Se precisar iniciar uma nova transmissão com urgência, solicite ao suporte de TI a verificação da Thread no WebMonitor." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                "JobId: " + cJobId + Chr(13) + Chr(10) +;
                "ThreadId: " + cValToChar(nThread)

    If !Empty(cServer) .Or. !Empty(cPort)
        cMessage += Chr(13) + Chr(10) + "Owner: " + cServer + IIf(!Empty(cPort), "|" + cPort, "")
    EndIf

    If !Empty(cServer)
        cMessage += Chr(13) + Chr(10) + "Servidor: " + cServer
    EndIf
    If !Empty(cPort)
        cMessage += Chr(13) + Chr(10) + "Porta: " + cPort
    EndIf

Return "active"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTRCN
@type Function
Reconcilia o lifecycle MT antes de aquisição, expiração ou consulta de status.
Separa worker local, restart comprovado e execução pertencente a outra instância.

@param cJobId, Character, identificador da transmissão.
@param cMessage, Character, mensagem devolvida ao chamador.
@return Character, active, terminal, absent, unknown ou requires_reconciliation.

@author Denis R. de Oliveira
@since 19/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTRCN(cJobId As Character, cMessage As Character) As Character

    Local aInfo         As Array
    Local aMeta         As Array
    Local bOldError     As Block
    Local cOwner        As Character
    Local cState        As Character
    Local cThread       As Character
    Local cUID          As Character
    Local lAccessOk     As Logical
    Local lChanged      As Logical
    Local lExpired      As Logical
    Local lHasMeta      As Logical
    Local lPoolRelease  As Logical
    Local lRelease      As Logical
    Local lSaved        As Logical
    Local lStarted      As Logical
    Local lThreadUp     As Logical
    Local nAge          As Numeric
    Local nItem         As Numeric
    Local nRemaining    As Numeric
    Local nWorker       As Numeric
    Local oError        As Object

    Default cJobId   := ""
    Default cMessage := ""

    aInfo         := {}
    aMeta         := {}
    bOldError     := Nil
    cOwner        := MTOWNER()
    cState        := "unknown"
    cThread       := ""
    cUID          := MTUID(cJobId)
    lAccessOk     := .F.
    lChanged      := .F.
    lExpired      := .F.
    lHasMeta      := .F.
    lPoolRelease  := .F.
    lRelease      := .F.
    lSaved        := .F.
    lStarted      := .F.
    lThreadUp     := .F.
    nAge          := 0
    nItem         := 0
    nRemaining    := 0
    nWorker       := 0
    oError        := Nil
    cMessage      := ""


    If Empty(cJobId); cMessage := "Identificador inválido para reconciliação."; Return "unknown"; EndIf

    // META local identifica workers desta instância; a ausência dele não invalida um job de outro AppServer.
    If VarIsUID(cUID)
        lStarted := MTBTX(cUID, "META", 400)
        If !lStarted; cMessage := MTJOBMSG("Não foi possível confirmar o andamento da transmissão neste momento. O estado não foi classificado como ativo nem como encerrado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Tente novamente. Sem evidência positiva de execução, este estado técnico não deve gerar bloqueio permanente.", cJobId, "", ""); Return "unknown"; EndIf

        bOldError := ErrorBlock({|e| Break(e)})
        Begin Sequence
            If VarGetAD(cUID, "META", @aMeta) .And. Len(aMeta) >= MT_THREADS
                lHasMeta := .T.
                If aMeta[MT_STATUS] == MT_OK .Or. aMeta[MT_STATUS] == MT_PARTIAL .Or. aMeta[MT_STATUS] == MT_ERROR
                    cState := "terminal"
                Else
                    If ValType(aMeta[MT_THREADS]) == "A" .And. Len(aMeta[MT_THREADS]) > 0
                        aInfo := GetUserInfoArray()
                        For nItem := 1 To Len(aMeta[MT_THREADS])
                            If AScan(aInfo, {|x| x[3] == aMeta[MT_THREADS][nItem]}) > 0
                                lThreadUp := .T.
                                cThread   := cValToChar(aMeta[MT_THREADS][nItem])
                                Exit
                            EndIf
                        Next nItem
                    EndIf

                    If lThreadUp
                        cState   := "active"
                        If aMeta[MT_STATUS] == MT_UNCERT; cMessage := "Uma transmissão anterior iniciou uma unidade de processamento, mas seu término ainda não foi confirmado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Aguarde a conclusão do worker e tente novamente." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Um worker dessa transmissão continua em execução e, para evitar o reenvio da unidade, uma nova transmissão não foi iniciada."
                        Else
                            cMessage := "Já existe uma transmissão do eSocial em processamento para esta empresa." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                        "Aguarde a conclusão do processamento e tente novamente." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                        "Um worker desta transmissão continua em execução e, para evitar duas transmissões simultâneas, este novo processamento não foi iniciado."
                        EndIf
                    ElseIf (aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING) .And.;
                           (aMeta[MT_WSTART] + aMeta[MT_WDONE]) < aMeta[MT_WORKERS] .And.;
                           MTAGE(aMeta) < aMeta[MT_STWAIT]
                        nAge       := MTAGE(aMeta)
                        nRemaining := Max(1, Int((aMeta[MT_STWAIT] - nAge + 59) / 60))
                        cState     := "active"
                        cMessage   := "Uma transmissão do eSocial está sendo iniciada para esta empresa." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                      "Aguarde a conclusão da inicialização e tente novamente." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                      "Para evitar duas transmissões simultâneas, este novo processamento não foi iniciado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                      "A inicialização será reavaliada automaticamente em até " + cValToChar(nRemaining) + IIf(nRemaining == 1, " minuto.", " minutos.")
                    ElseIf aMeta[MT_STATUS] == MT_UNCERT; nAge := MTPROGAGE(aMeta); If aMeta[MT_ACTIVE] > 0 .And. nAge < MT_HEARTBEAT_WAIT; If aMeta[MT_WDONE] <> aMeta[MT_WORKERS]; aMeta[MT_WDONE] := aMeta[MT_WORKERS]; aMeta[MT_UDATE] := Date(); aMeta[MT_UTIME] := Time(); lChanged := .T.; EndIf; nRemaining := Max(1, Int((MT_HEARTBEAT_WAIT - nAge + 59) / 60)); cState := "requires_reconciliation"; cMessage := "Uma transmissão anterior iniciou uma unidade de processamento, mas seu término não foi confirmado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                                     "Para evitar o reenvio dessa unidade, uma nova transmissão está temporariamente protegida." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                                     "Aguarde aproximadamente " + cValToChar(nRemaining) + IIf(nRemaining == 1, " minuto e tente novamente.", " minutos e tente novamente."); lPoolRelease := .T.; Else; aMeta[MT_STATUS] := MT_ERROR; aMeta[MT_MESSAGE] := "Transmissão interrompida sem confirmação recente."; aMeta[MT_WDONE] := aMeta[MT_WORKERS]; aMeta[MT_UDATE] := Date(); aMeta[MT_UTIME] := Time(); cState := "terminal"; lChanged := .T.; lPoolRelease := .T.; EndIf
                    Else
                        lExpired := MTEXPMETA(@aMeta)
                        If lExpired; aMeta[MT_WDONE] := aMeta[MT_WORKERS]; cState := "terminal"; lChanged := .T.; lPoolRelease := .T.
                        Else
                            nAge := MTPROGAGE(aMeta)
                            If aMeta[MT_ACTIVE] > 0 .And. nAge < MT_HEARTBEAT_WAIT; aMeta[MT_STATUS] := MT_UNCERT; aMeta[MT_MESSAGE] := "Uma unidade em processamento ficou sem confirmação de término."; aMeta[MT_WDONE] := aMeta[MT_WORKERS]; aMeta[MT_UDATE] := Date(); aMeta[MT_UTIME] := Time(); nRemaining := Max(1, Int((MT_HEARTBEAT_WAIT - nAge + 59) / 60)); cState := "requires_reconciliation"; cMessage := "Uma transmissão anterior iniciou uma unidade de processamento, mas seu término não foi confirmado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                                     "Para evitar o reenvio dessa unidade, uma nova transmissão está temporariamente protegida." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                                     "Aguarde aproximadamente " + cValToChar(nRemaining) + IIf(nRemaining == 1, " minuto e tente novamente.", " minutos e tente novamente."); lChanged := .T.; lPoolRelease := .T.; Else; aMeta[MT_STATUS] := MT_ERROR; aMeta[MT_MESSAGE] := "Transmissão interrompida sem workers ativos."; aMeta[MT_WDONE] := aMeta[MT_WORKERS]; aMeta[MT_UDATE] := Date(); aMeta[MT_UTIME] := Time(); cState := "terminal"; lChanged := .T.; lPoolRelease := .T.; EndIf
                        EndIf
                    EndIf
                EndIf

                If lChanged; lSaved := VarSetAD(cUID, "META", aMeta); If lSaved; lSaved := MTDBSAVE(aMeta, .F.); EndIf
                Else; lSaved := .T.; EndIf
            Else
                cState := "unknown"
                lSaved := .T.
            EndIf
        Recover Using oError; cState := "unknown"; lSaved := .F.; cMessage := "Não foi possível confirmar o andamento da transmissão neste momento." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Tente novamente. Sem evidência positiva de execução, este estado técnico não deve gerar bloqueio permanente."; TafConOut("[TAFMTRCN] " + TAFMTERR(oError)); End Sequence

        lSaved := MTENDT(cUID, "META", lSaved)
        ErrorBlock(bOldError)

        If lSaved .And. cState == "terminal"
            lRelease := TAFMTREL(aMeta[MT_COMPANY], aMeta[MT_BRANCH], cJobId)
            If lPoolRelease; For nWorker := 1 To aMeta[MT_WORKERS]; MTPDEC(cJobId); Next nWorker; EndIf
            If lRelease .And. aMeta[MT_WDONE] >= aMeta[MT_WORKERS]; MTPURGE(cJobId, aMeta[MT_TOTAL], .T.); EndIf

        ElseIf lSaved .And. cState == "requires_reconciliation"; If lPoolRelease; For nWorker := 1 To aMeta[MT_WORKERS]; MTPDEC(cJobId); Next nWorker; EndIf

        ElseIf !lSaved .And. (cState == "terminal" .Or. cState == "requires_reconciliation"); cState := "unknown"; cMessage := "Não foi possível persistir a reconciliação da transmissão neste momento. O estado não foi classificado como ativo nem como encerrado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Tente novamente. Sem evidência positiva de execução, este estado técnico não deve gerar bloqueio permanente."; EndIf

        If lHasMeta
            If cState == "active" .Or. cState == "requires_reconciliation" .Or. cState == "unknown"
                cMessage := MTJOBMSG(cMessage, cJobId, aMeta[MT_OWNER], cThread)
            EndIf
            Return cState
        EndIf
        If !lSaved; Return "unknown"; EndIf
    EndIf

    // Sem META local, o owner separa restart comprovado de execução pertencente a outra instância.
    If !MTDBGET(cJobId, @aMeta, @lAccessOk); If !lAccessOk; cMessage := MTJOBMSG("Não foi possível confirmar o andamento da transmissão neste momento. O estado não foi classificado como ativo nem como encerrado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Tente novamente. Sem evidência positiva de execução, este estado técnico não deve gerar bloqueio permanente.", cJobId, "", ""); Return "unknown"; EndIf; Return "absent"; EndIf

    If aMeta[MT_STATUS] == MT_OK .Or. aMeta[MT_STATUS] == MT_PARTIAL .Or. aMeta[MT_STATUS] == MT_ERROR
        If TAFMTREL(aMeta[MT_COMPANY], aMeta[MT_BRANCH], cJobId); Return "terminal"; EndIf; Return "absent"
    ElseIf !Empty(cOwner) .And. !Empty(aMeta[MT_OWNER]) .And. Upper(AllTrim(aMeta[MT_OWNER])) == cOwner .And.;
           (aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING .Or. aMeta[MT_STATUS] == MT_UNCERT)
        If !TAFMTREL(aMeta[MT_COMPANY], aMeta[MT_BRANCH], cJobId); cMessage := MTJOBMSG("O AppServer proprietário foi reiniciado, mas não foi possível liberar o controle residual neste momento. O estado não foi classificado como ativo nem como encerrado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Tente novamente. Sem evidência positiva de execução, este estado técnico não deve gerar bloqueio permanente.", cJobId, aMeta[MT_OWNER], ""); Return "unknown"; EndIf
        For nWorker := 1 To aMeta[MT_WORKERS]
            MTPDEC(cJobId)
        Next nWorker

        Return "absent"
    ElseIf aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING
        nAge := MTPROGAGE(aMeta)
        If nAge < MT_HEARTBEAT_WAIT
            cMessage := MTJOBMSG("Há uma transmissão do eSocial registrada em outra instância do AppServer. O acompanhamento permanece ativo." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                    "Aguarde a conclusão do processamento e tente novamente." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                    "Para evitar duas transmissões simultâneas, uma nova transmissão não foi iniciada.", cJobId, aMeta[MT_OWNER], "")
            Return "active"
        EndIf
        lRelease := TAFMTREL(aMeta[MT_COMPANY], aMeta[MT_BRANCH], cJobId)
        cMessage := MTJOBMSG(IIf(lRelease,;
                                 "A transmissão em outra instância não publicou checkpoint real durante 15 minutos. Sem evidência positiva de execução, o controle residual foi liberado e a transmissão anterior não permanece ativa." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                 "Tente iniciar a transmissão novamente.",;
                                 "A transmissão em outra instância não publicou checkpoint real durante 15 minutos, mas o controle residual não pôde ser liberado. O estado não foi classificado como ativo nem como encerrado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                 "Tente novamente. Este estado técnico não deve gerar bloqueio permanente."),;
                               cJobId, aMeta[MT_OWNER], "")
        Return IIf(lRelease, "terminal", "unknown")
    ElseIf aMeta[MT_STATUS] == MT_UNCERT
        nAge := MTPROGAGE(aMeta)
        If nAge >= MT_HEARTBEAT_WAIT
            lRelease := TAFMTREL(aMeta[MT_COMPANY], aMeta[MT_BRANCH], cJobId)
            cMessage := MTJOBMSG(IIf(lRelease,;
                                     "A instância proprietária registrou uma unidade sem confirmação de término." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                     "Como nenhum novo checkpoint foi publicado durante 15 minutos, a proteção terminou e o controle residual foi liberado. A transmissão anterior não permanece ativa." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                     "Tente iniciar a transmissão novamente.",;
                                     "A proteção da unidade sem término confirmado chegou ao limite, mas o controle residual não pôde ser liberado. O estado não foi classificado como ativo nem como encerrado." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                                     "Tente novamente. Este estado técnico não deve gerar bloqueio permanente."),;
                                   cJobId, aMeta[MT_OWNER], "")
            Return IIf(lRelease, "terminal", "unknown")
        EndIf
        nRemaining := Max(1, Int((MT_HEARTBEAT_WAIT - nAge + 59) / 60))
        cMessage   := "Uma transmissão executada em outra instância possui unidade sem confirmação de término." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                      "Para evitar o reenvio da unidade, uma nova transmissão está temporariamente protegida." + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                      "Aguarde aproximadamente " + cValToChar(nRemaining) + IIf(nRemaining == 1, " minuto e tente novamente.", " minutos e tente novamente.")
        cMessage := MTJOBMSG(cMessage, cJobId, aMeta[MT_OWNER], "")
        Return "requires_reconciliation"
    EndIf

    TAFMTREL(aMeta[MT_COMPANY], aMeta[MT_BRANCH], cJobId); Return "absent"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTINIT
@type Function
Cria o estado da transmissão antes de iniciar os workers.
Armazena contadores, prazos e situação inicial usados pelo acompanhamento.

@param cJobId, Character, identificador da transmissão.
@param cCompany, Character, empresa do ambiente.
@param cBranch, Character, filial do ambiente.
@param nTasks, Numeric, quantidade de tarefas.
@param nWorkers, Numeric, quantidade de workers.
@param nStartWait, Numeric, prazo para o primeiro worker iniciar.
@param nRunWait, Numeric, prazo sem atualização durante a execução.
@param aEvents, Array, contadores iniciais por evento.
@param cMessage, Character, mensagem devolvida ao chamador.
@return Logical, indica se o estado foi criado.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTINIT(cJobId As Character, cCompany As Character, cBranch As Character, nTasks As Numeric, nWorkers As Numeric, nStartWait As Numeric,;
                   nRunWait As Numeric, aEvents As Array, cMessage As Character) As Logical

    Local aMeta     As Array
    Local aProgress As Array
    Local cOwner    As Character
    Local cUID      As Character

    Default cJobId     := ""
    Default cCompany   := ""
    Default cBranch    := ""
    Default nTasks     := 0
    Default nWorkers   := 0
    Default nStartWait := 300
    Default nRunWait   := 10800
    Default aEvents    := {}
    Default cMessage   := ""

    aMeta     := {}
    aProgress := Array(Max(0, Int(nTasks)))
    cOwner    := MTOWNER()
    cUID      := MTUID(cJobId)

    If Len(aProgress) > 0; AFill(aProgress, 0); EndIf

    cMessage := ""
    nRunWait := Max(300, Min(10800, Int(nRunWait)))

    If !VarSetUID(cUID, .T.); cMessage := "Não foi possível criar a seção de controle da transmissão."; Return .F.; EndIf

    // Os índices seguem o contrato MT_* usado pelo monitor e pelos workers.
    aMeta := {cJobId, MT_QUEUED, nTasks, 0, nWorkers, 0, 0, 0, 0,;
              "Aguardando workers.", Date(), Time(), Date(), Time(),;
              cCompany, cBranch, 1, 0, 0, nStartWait, nRunWait,;
              {0, 0, 0, 0, 0}, aClone(aEvents), 1, 0, Date(), Time(), cOwner, {}, aProgress}

    If !MTWRITE(cUID, "META", aMeta); cMessage := "Não foi possível gravar o estado inicial da transmissão."; Return .F.; EndIf

    If !MTDBSAVE(aMeta, .T.); cMessage := "Não foi possível compartilhar o estado inicial da transmissão na V3J."; MTPURGE(cJobId, 0, .T.); Return .F.; EndIf

Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTCFG
@type Function
Substitui o estado temporário de preparação pelo plano definitivo do mesmo JobId.
Só aceita a troca antes de qualquer unidade real iniciar e enquanto a reserva da empresa
continuar pertencendo ao job.

@param cJobId, Character, identificador da transmissão.
@param nTasks, Numeric, quantidade definitiva de tarefas.
@param nWorkers, Numeric, quantidade definitiva de workers.
@param nStartWait, Numeric, prazo para os workers iniciarem após o planejamento.
@param nRunWait, Numeric, prazo de execução configurado.
@param aEvents, Array, contadores definitivos por evento.
@param cMessage, Character, mensagem devolvida ao chamador.
@return Logical, indica se o plano foi instalado e persistido.
/*/
//--------------------------------------------------------------------------------
Function TAFMTCFG(cJobId As Character, nTasks As Numeric, nWorkers As Numeric, nStartWait As Numeric, nRunWait As Numeric,;
                  aEvents As Array, cMessage As Character) As Logical

    Local aBefore   As Array
    Local aMeta     As Array
    Local aProgress As Array
    Local bOldError As Block
    Local cUID      As Character
    Local lSaved    As Logical
    Local lStarted  As Logical
    Local oError    As Object

    Default cJobId     := ""
    Default nTasks     := 0
    Default nWorkers   := 0
    Default nStartWait := 300
    Default nRunWait   := 10800
    Default aEvents    := {}
    Default cMessage   := ""

    aBefore   := {}
    aMeta     := {}
    aProgress := {}
    bOldError := Nil
    cUID      := MTUID(cJobId)
    lSaved    := .F.
    lStarted  := .F.
    oError    := Nil
    cMessage  := ""

    nTasks     := Max(0, Int(nTasks))
    nWorkers   := Max(0, Int(nWorkers))
    nStartWait := Max(30, Min(3600, Int(nStartWait)))
    nRunWait   := Max(300, Min(10800, Int(nRunWait)))

    If Empty(cJobId) .Or. nTasks <= 0 .Or. nWorkers <= 0 .Or. Empty(aEvents)
        cMessage := "Plano multithread inválido para concluir a preparação."
        Return .F.
    EndIf

    If !VarIsUID(cUID); cMessage := "Estado temporário da transmissão não localizado."; Return .F.; EndIf

    aProgress := Array(nTasks)
    If Len(aProgress) > 0; AFill(aProgress, 0); EndIf

    lStarted := MTBTX(cUID, "META", 400)
    If !lStarted; cMessage := "Não foi possível concluir o planejamento da transmissão."; Return .F.; EndIf

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        If VarGetAD(cUID, "META", @aMeta) .And. Len(aMeta) >= MT_PROGRESS
            If aMeta[MT_STATUS] == MT_QUEUED .And. aMeta[MT_TOTAL] == 0 .And. aMeta[MT_WORKERS] == 1 .And.;
               aMeta[MT_ACTIVE] == 0 .And. aMeta[MT_DONE] == 0 .And. aMeta[MT_WDONE] == 0 .And.;
               Empty(aMeta[MT_EVENTS])
                If MTSCOPEOWN(aMeta[MT_COMPANY], cJobId)
                    aBefore := aClone(aMeta)
                    aMeta[MT_TOTAL]    := nTasks
                    aMeta[MT_DONE]     := 0
                    aMeta[MT_WORKERS]  := nWorkers
                    aMeta[MT_WDONE]    := 0
                    aMeta[MT_SENT]     := 0
                    aMeta[MT_ERRORS]   := 0
                    aMeta[MT_FAILED]   := 0
                    aMeta[MT_MESSAGE]  := "Plano multithread preparado. Aguardando workers."
                    aMeta[MT_UDATE]    := Date()
                    aMeta[MT_UTIME]    := Time()
                    aMeta[MT_NEXT]     := 1
                    aMeta[MT_WFAILED]  := 0
                    aMeta[MT_WSTART]   := 0
                    aMeta[MT_STWAIT]   := nStartWait
                    aMeta[MT_RTWAIT]   := nRunWait
                    aMeta[MT_TYPES]    := {0, 0, 0, 0, 0}
                    aMeta[MT_EVENTS]   := aClone(aEvents)
                    aMeta[MT_PHASE]    := 1
                    aMeta[MT_ACTIVE]   := 0
                    aMeta[MT_PDATE]    := Date()
                    aMeta[MT_PTIME]    := Time()
                    aMeta[MT_THREADS]  := {}
                    aMeta[MT_PROGRESS] := aProgress

                    lSaved := VarSetAD(cUID, "META", aMeta)
                    If lSaved; lSaved := MTDBSAVE(aMeta, .F.); EndIf
                    If !lSaved; VarSetAD(cUID, "META", aBefore); cMessage := "Não foi possível persistir o plano definitivo da transmissão."; EndIf
                Else
                    cMessage := "A transmissão não possui mais a reserva da empresa."
                EndIf
            Else
                cMessage := "O estado da transmissão não permite substituir o plano de preparação."
            EndIf
        Else; cMessage := "Estado temporário da transmissão não localizado."
        EndIf
    Recover Using oError; lSaved := .F.; cMessage := "Falha ao concluir o planejamento da transmissão: " + TAFMTERR(oError); End Sequence

    lSaved := MTENDT(cUID, "META", lSaved)
    ErrorBlock(bOldError)

Return lSaved

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTWSTA
@type Function
Registra a entrada do worker ou permite seu encerramento após o fim da fila.
Atualiza o contador de inicialização sem reabrir um job já finalizado.

@param cJobId, Character, identificador da transmissão.
@param nWorker, Numeric, número do worker.
@param cMessage, Character, mensagem devolvida ao chamador.
@return Logical, indica se o worker pode continuar ou encerrar normalmente.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTWSTA(cJobId As Character, nWorker As Numeric, cMessage As Character) As Logical

    Local aBefore   As Array
    Local aMeta     As Array
    Local bOldError As Block
    Local cUID      As Character
    Local lSaved    As Logical
    Local lStarted  As Logical
    Local oError    As Object

    Default cJobId   := ""
    Default nWorker  := 0
    Default cMessage := ""

    aBefore   := {}
    aMeta     := {}
    bOldError := Nil
    cUID      := MTUID(cJobId)
    lSaved    := .F.
    lStarted  := .F.
    oError    := Nil

    lStarted := MTBTX(cUID, "META", 400)
    If !lStarted; cMessage := "Não foi possível registrar a entrada do worker."; Return .F.; EndIf

    // A entrada só é confirmada enquanto o job possui a reserva da empresa.
    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        If VarGetAD(cUID, "META", @aMeta) .And. Len(aMeta) >= MT_THREADS
            If aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING
                If MTSCOPEOWN(aMeta[MT_COMPANY], cJobId)
                    // O estado persistido confirma a autorização antes de qualquer claim ou chamada ao TSS.
                    aBefore := aClone(aMeta)
                    AAdd(aMeta[MT_THREADS], ThreadID())
                    If nWorker > 0
                        aMeta[MT_WSTART] := Min(aMeta[MT_WORKERS], aMeta[MT_WSTART] + 1)
                    EndIf
                    aMeta[MT_MESSAGE] := IIf(nWorker > 0,;
                                                "Worker " + cValToChar(nWorker) + " iniciado.",;
                                                "Preparando unidades de trabalho.")
                    aMeta[MT_UDATE]   := Date()
                    aMeta[MT_UTIME]   := Time()
                    lSaved            := VarSetAD(cUID, "META", aMeta)
                    If lSaved; lSaved := MTDBSAVE(aMeta, .F.); EndIf
                    If !lSaved; VarSetAD(cUID, "META", aBefore); cMessage := "Não foi possível confirmar a entrada do worker."; EndIf
                Else
                    cMessage := "A transmissão não possui mais a reserva da empresa."
                EndIf
            ElseIf aMeta[MT_STATUS] == MT_OK .Or. aMeta[MT_STATUS] == MT_PARTIAL; lSaved := .T.; Else; cMessage := "A transmissão não aceita mais workers."; EndIf
        Else; cMessage := "Estado da transmissão não localizado."; EndIf
    Recover Using oError; lSaved := .F.; cMessage := "Falha ao registrar a entrada do worker: " + TAFMTERR(oError); End Sequence

    lSaved := MTENDT(cUID, "META", lSaved)
    ErrorBlock(bOldError)

Return lSaved

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTADDT
@type Function
Grava uma unidade de trabalho imutável antes da criação dos workers.
Clona o conteúdo para impedir alterações posteriores no array do chamador.

@param cJobId, Character, identificador da transmissão.
@param nTask, Numeric, número da tarefa.
@param aTask, Array, dados que serão processados.
@return Logical, indica se a tarefa foi gravada.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTADDT(cJobId As Character, nTask As Numeric, aTask As Array) As Logical

    Default cJobId := ""
    Default nTask  := 0
    Default aTask  := {}

Return MTWRITE(MTUID(cJobId), MTTKEY(nTask), aClone(aTask))

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTCLM
@type Function
Entrega a próxima tarefa e avança o controle somente após encontrá-la.
Serializa a retirada para que dois workers nunca recebam a mesma unidade.

@param cJobId, Character, identificador da transmissão.
@param nWorker, Numeric, número do worker.
@param nTask, Numeric, número devolvido ao worker.
@param aTask, Array, tarefa devolvida ao worker.
@param lWait, Logical, indica que a fila aguarda o término da fase atual.
@return Logical, indica se uma tarefa foi reservada.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTCLM(cJobId As Character, nWorker As Numeric, nTask As Numeric, aTask As Array, lWait As Logical) As Logical

    Local aEvents   As Array
    Local aMembers  As Array
    Local aMeta     As Array
    Local aPersist  As Array
    Local bOldError As Block
    Local cEvent    As Character
    Local cUID      As Character
    Local lClaimed  As Logical
    Local lPublish  As Logical
    Local lStarted  As Logical
    Local nMember   As Numeric
    Local nMemberPos As Numeric
    Local nPhase    As Numeric
    Local oError    As Object

    Default cJobId  := ""
    Default nWorker := 0
    Default nTask   := 0
    Default aTask   := {}
    Default lWait   := .F.

    aEvents   := {}
    aMembers  := {}
    aMeta     := {}
    aPersist  := {}
    bOldError := Nil
    cEvent    := ""
    cUID      := MTUID(cJobId)
    lClaimed  := .F.
    lPublish  := .F.
    lStarted  := .F.
    nMember   := 0
    nMemberPos := 0
    nPhase    := 0
    oError    := Nil

    nTask := 0
    aTask := {}
    lWait := .F.

    lStarted := MTBTX(cUID, "META", 400)
    If !lStarted
        Return .F.
    EndIf

    // Libera somente tarefas do evento corrente. O próximo evento aguarda
    // todas as unidades em execução para preservar a precedência do eSocial.
    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        If VarGetAD(cUID, "META", @aMeta) .And. Len(aMeta) >= MT_PTIME
            If (aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING) .And.;
               aMeta[MT_NEXT] <= aMeta[MT_TOTAL]

                nTask := aMeta[MT_NEXT]
                If VarGetAD(cUID, MTTKEY(nTask), @aTask) .And.;
                   ValType(aMeta[MT_EVENTS]) == "A" .And. !Empty(aMeta[MT_EVENTS])

                    aEvents := aClone(aMeta[MT_EVENTS])
                    nPhase  := Max(1, Min(Len(aEvents), Int(aMeta[MT_PHASE])))
                    cEvent  := aEvents[nPhase][EV_CODE]

                    If aTask[1] <> cEvent
                        If aMeta[MT_ACTIVE] <= 0
                            nPhase := MTEVINDEX(aEvents, aTask[1])
                            aMeta[MT_PHASE] := nPhase
                            cEvent := aEvents[nPhase][EV_CODE]
                        Else
                            lWait := .T.
                        EndIf
                    EndIf

                    // Eventos de tabela são sequenciais por empregador.
                    If !lWait .And. MTISSERIAL(cEvent) .And. aMeta[MT_ACTIVE] > 0
                        lWait := .T.
                    EndIf

                    If !lWait .And. aTask[1] == cEvent
                        lPublish := aEvents[nPhase][EV_STATUS] <> MT_RUNNING .Or. MTDBDUE(aMeta, 5)
                        aMeta[MT_NEXT]++
                        aMeta[MT_ACTIVE]++
                        aMeta[MT_STATUS]  := MT_RUNNING
                        aMeta[MT_MESSAGE] := "Worker " + cValToChar(nWorker) + " em processamento."
                        aMeta[MT_UDATE]   := Date()
                        aMeta[MT_UTIME]   := Time()
                        aEvents[nPhase][EV_STATUS] := MT_RUNNING

                        // O processamento devolve os totais da unidade inteira, sem divisão por evento.
                        // Os contadores ficam no evento da unidade e os demais são marcados como agregados.
                        aMembers := MTMEMBERS(aTask)
                        If Len(aMembers) > 1
                            aEvents[nPhase][EV_AGGREG] := 2
                            For nMember := 2 To Len(aMembers)
                                nMemberPos := MTEVINDEX(aEvents, aMembers[nMember][1])
                                aEvents[nPhase][EV_RTOTAL] += Max(0, aEvents[nMemberPos][EV_RTOTAL])
                                aEvents[nMemberPos][EV_AGGREG] := 1
                                aEvents[nMemberPos][EV_STATUS] := MT_RUNNING
                            Next nMember
                            MTGRPMIR(aEvents, aMembers, nPhase)
                        EndIf

                        aMeta[MT_EVENTS]  := aEvents
                        If lPublish
                            aMeta[MT_PDATE] := Date()
                            aMeta[MT_PTIME] := Time()
                        EndIf
                        lClaimed := VarSetAD(cUID, "META", aMeta)
                        If lClaimed .And. lPublish
                            aPersist := aClone(aMeta)
                        EndIf
                    Else; nTask := 0; aTask := {}
                    EndIf
                Else; nTask := 0; aTask := {}
                EndIf
            EndIf
        EndIf
    Recover Using oError; lClaimed := .F.; lWait    := .F.; TafConOut("[TAFMTCLM] " + TAFMTERR(oError)); End Sequence

    lClaimed := MTENDT(cUID, "META", lClaimed)
    ErrorBlock(bOldError)

    // Publica a abertura da fase e os checkpoints de unidades em intervalos coalescidos.
    If lClaimed .And. !Empty(aPersist)
        If !MTDBSAVE(aPersist, .F.); TafConOut("[TAFMTCLM][" + cJobId + "] Não foi possível publicar o início da fase na V3J."); EndIf
    EndIf

Return lClaimed

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTPRG
@type Function
Publica o contador absoluto de registros já percorridos por uma tarefa MT.
Soma somente o delta ainda não publicado e mantém sent/errors separados.

@param cJobId, Character, identificador da transmissão.
@param nTask, Numeric, número da tarefa.
@param nRecords, Numeric, quantidade absoluta já percorrida pela tarefa.
@return Logical, indica se o checkpoint local foi aceito.

@author Denis R. de Oliveira
@since 19/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTPRG(cJobId As Character, nTask As Numeric, nRecords As Numeric) As Logical

    Local aEvents    As Array
    Local aMeta      As Array
    Local aPersist   As Array
    Local aProgress  As Array
    Local aTask      As Array
    Local bOldError  As Block
    Local cUID       As Character
    Local lDbSaved   As Logical
    Local lFirstProgress As Logical
    Local lPersist   As Logical
    Local lSaved     As Logical
    Local lStarted   As Logical
    Local nDelta     As Numeric
    Local nEventPos  As Numeric
    Local nPublished As Numeric
    Local oError     As Object

    Default cJobId   := ""
    Default nTask    := 0
    Default nRecords := 0

    aEvents    := {}
    aMeta      := {}
    aPersist   := {}
    aProgress  := {}
    aTask      := {}
    bOldError  := Nil
    cUID       := MTUID(cJobId)
    lDbSaved   := .T.
    lFirstProgress := .F.
    lPersist   := .F.
    lSaved     := .F.
    lStarted   := .F.
    nDelta     := 0
    nEventPos  := 0
    nPublished := 0
    oError     := Nil

    If Empty(cJobId) .Or. nTask <= 0; Return .F.; EndIf

    lStarted := MTBTX(cUID, "META", 400)
    If !lStarted; Return .F.; EndIf

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        If VarGetAD(cUID, "META", @aMeta) .And. Len(aMeta) >= MT_PROGRESS .And.;
           ValType(aMeta[MT_PROGRESS]) == "A" .And. nTask <= Len(aMeta[MT_PROGRESS]) .And.;
           (aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING) .And.;
           VarGetAD(cUID, MTTKEY(nTask), @aTask)
            aProgress  := aClone(aMeta[MT_PROGRESS])
            lFirstProgress := AScan(aProgress, {|nValue| ValType(nValue) == "N" .And. nValue > 0}) == 0
            nPublished := Max(0, aProgress[nTask])
            nDelta     := Max(0, Max(0, nRecords) - nPublished)
            lSaved     := .T.

            If nDelta > 0
                aEvents   := aClone(aMeta[MT_EVENTS])
                nEventPos := MTEVINDEX(aEvents, aTask[1])
                aProgress[nTask] := Max(nPublished, Max(0, nRecords))
                aEvents[nEventPos][EV_RDONE] += nDelta
                MTGRPMIR(aEvents, MTMEMBERS(aTask), nEventPos)
                aMeta[MT_PROGRESS] := aProgress
                aMeta[MT_EVENTS]   := aEvents
                aMeta[MT_UDATE]    := Date()
                aMeta[MT_UTIME]    := Time()
                lPersist           := lFirstProgress .Or. nPublished < 100 .Or. MTDBDUE(aMeta, 5)
                If lPersist; aMeta[MT_PDATE] := Date(); aMeta[MT_PTIME] := Time(); EndIf
                lSaved := VarSetAD(cUID, "META", aMeta)
                If lSaved .And. lPersist; aPersist := aClone(aMeta); EndIf
            EndIf
        EndIf
    Recover Using oError; lSaved := .F.; TafConOut("[TAFMTPRG] " + TAFMTERR(oError)); End Sequence

    lSaved := MTENDT(cUID, "META", lSaved)
    ErrorBlock(bOldError)

    If lSaved .And. lPersist .And. !Empty(aPersist)
        lDbSaved := MTDBSAVE(aPersist, .F.)
        If !lDbSaved; TafConOut("[TAFMTPRG][" + cJobId + "] Snapshot V3J não atualizado; um checkpoint posterior manterá o maior progresso."); EndIf
    EndIf

Return lSaved

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTDONE
@type Function
Consolida somente retornos observados do TAFProc4Tss; não estima registros.
Finaliza o job apenas depois que todas as unidades confirmarem resultado.

@param cJobId, Character, identificador da transmissão.
@param nTask, Numeric, número da tarefa.
@param nSent, Numeric, quantidade transmitida.
@param nErrors, Numeric, quantidade com erro.
@param lSuccess, Logical, resultado geral da tarefa.
@param cMessage, Character, mensagem da tarefa.
@param nErrorType, Numeric, tipo principal do erro.
@param nRecords, Numeric, quantidade efetivamente percorrida pela tarefa.
@return Logical, indica se o resultado foi consolidado.
@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTDONE(cJobId As Character, nTask As Numeric, nSent As Numeric, nErrors As Numeric, lSuccess As Logical, cMessage As Character,;
                   nErrorType As Numeric, nRecords As Numeric) As Logical

    Local aEvents    As Array
    Local aMembers   As Array
    Local aMeta      As Array
    Local aPersist   As Array
    Local aProgress  As Array
    Local aTask      As Array
    Local aTypes     As Array
    Local bOldError  As Block
    Local cUID       As Character
    Local lDbSaved   As Logical
    Local lPersist   As Logical
    Local lRelease   As Logical
    Local lSaved     As Logical
    Local lStarted   As Logical
    Local nDelta     As Numeric
    Local nEventPos  As Numeric
    Local nMember    As Numeric
    Local nPublished As Numeric
    Local nTypePos   As Numeric
    Local oError     As Object

    Default cJobId     := ""
    Default nTask      := 0
    Default nSent      := 0
    Default nErrors    := 0
    Default lSuccess   := .T.
    Default cMessage   := ""
    Default nErrorType := -1
    Default nRecords   := 0

    aEvents    := {}
    aMembers   := {}
    aMeta      := {}
    aPersist   := {}
    aProgress  := {}
    aTask      := {}
    aTypes     := {}
    bOldError  := Nil
    cUID       := MTUID(cJobId)
    lDbSaved   := .T.
    lPersist   := .F.
    lRelease   := .F.
    lSaved     := .F.
    lStarted   := .F.
    nDelta     := 0
    nEventPos  := 0
    nMember    := 0
    nPublished := 0
    nTypePos   := 0
    oError     := Nil

    lStarted := MTBTX(cUID, "META", 400)
    If !lStarted
        Return .F.
    EndIf

    // Consolida os contadores no estado local; a V3J recebe snapshots
    // coalescidos para não serializar o caminho crítico a cada tarefa.
    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        If VarGetAD(cUID, "META", @aMeta) .And. Len(aMeta) >= MT_PROGRESS
            If aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING
                aMeta[MT_DONE]   := Min(aMeta[MT_TOTAL], aMeta[MT_DONE] + 1)
                aMeta[MT_ACTIVE] := Max(0, aMeta[MT_ACTIVE] - 1)
                aMeta[MT_SENT]   += Max(0, nSent)
                aMeta[MT_ERRORS] += Max(0, nErrors)

                If !lSuccess
                    aMeta[MT_FAILED]++
                    If !Empty(cMessage)
                        aMeta[MT_MESSAGE] := "Unidade " + cValToChar(nTask) + ": " + cMessage
                    EndIf
                EndIf

                If nErrorType >= 0 .And. (nErrors > 0 .Or. !lSuccess)
                    nTypePos := Min(5, Max(1, Int(nErrorType) + 1))
                    aTypes := aClone(aMeta[MT_TYPES])
                    aTypes[nTypePos]++
                    aMeta[MT_TYPES] := aTypes
                EndIf

                If VarGetAD(cUID, MTTKEY(nTask), @aTask)
                    aEvents    := aClone(aMeta[MT_EVENTS])
                    aProgress  := aClone(aMeta[MT_PROGRESS])
                    aMembers   := MTMEMBERS(aTask)
                    nPublished := Max(0, aProgress[nTask])
                    nDelta     := Max(0, Max(0, nRecords) - nPublished)
                    aProgress[nTask] := Max(nPublished, Max(0, nRecords))

                    // Registros, enviados e ocorrências são da unidade e ficam no evento dela.
                    For nMember := 1 To Len(aMembers)
                        nEventPos := MTEVINDEX(aEvents, aMembers[nMember][1])
                        aEvents[nEventPos][EV_DONE] := Min(aEvents[nEventPos][EV_TOTAL],;
                                                           aEvents[nEventPos][EV_DONE] + 1)
                        If nMember == 1
                            aEvents[nEventPos][EV_SENT]   += Max(0, nSent)
                            aEvents[nEventPos][EV_ERRORS] += Max(0, nErrors)
                            aEvents[nEventPos][EV_RDONE]  += nDelta
                        EndIf
                        If !lSuccess
                            aEvents[nEventPos][EV_FAILED]++
                        EndIf
                        If aEvents[nEventPos][EV_DONE] >= aEvents[nEventPos][EV_TOTAL]
                            aEvents[nEventPos][EV_RTOTAL] := aEvents[nEventPos][EV_RDONE]
                            aEvents[nEventPos][EV_STATUS] := IIf(aEvents[nEventPos][EV_FAILED] > 0 .Or.;
                                                                 aEvents[nEventPos][EV_ERRORS] > 0, MT_PARTIAL, MT_OK)
                        Else
                            aEvents[nEventPos][EV_STATUS] := MT_RUNNING
                        EndIf
                    Next nMember
                    MTGRPMIR(aEvents, aMembers, MTEVINDEX(aEvents, aMembers[1][1]))
                    aMeta[MT_EVENTS]   := aEvents
                    aMeta[MT_PROGRESS] := aProgress
                EndIf

                If aMeta[MT_DONE] >= aMeta[MT_TOTAL]
                    If aMeta[MT_FAILED] > 0 .Or. aMeta[MT_ERRORS] > 0 .Or.;
                       aMeta[MT_WFAILED] > 0
                        aMeta[MT_STATUS]  := MT_PARTIAL
                        aMeta[MT_MESSAGE] := "Transmissão concluída com ocorrências."
                    Else
                        aMeta[MT_STATUS]  := MT_OK
                        aMeta[MT_MESSAGE] := "Transmissão concluída."
                    EndIf
                    lRelease := .T.
                EndIf

                aMeta[MT_UDATE] := Date()
                aMeta[MT_UTIME] := Time()
                // O frontend consulta a cada 5 segundos; evita snapshots mais frequentes.
                lPersist        := lRelease .Or. MTDBDUE(aMeta, 5)
                If lPersist
                    aMeta[MT_PDATE] := Date()
                    aMeta[MT_PTIME] := Time()
                EndIf

                lSaved := VarSetAD(cUID, "META", aMeta)
                If lSaved .And. lPersist
                    aPersist := aClone(aMeta)
                EndIf
            EndIf
        EndIf
    Recover Using oError; lSaved := .F.; lRelease := .F.; TafConOut("[TAFMTDONE] " + TAFMTERR(oError)); End Sequence

    lSaved := MTENDT(cUID, "META", lSaved)
    If !lSaved; lRelease := .F.; EndIf

    ErrorBlock(bOldError)

    // A tarefa concluída não participa mais da fila e pode liberar memória imediatamente.
    If lSaved
        VarDel(cUID, MTTKEY(nTask))
    EndIf

    // O snapshot persistente fica fora do mutex local para não bloquear workers
    // durante acesso ao DBAccess. O estado quente já está confirmado em memória.
    If lSaved .And. lPersist .And. !Empty(aPersist)
        lDbSaved := MTDBSAVE(aPersist, .F.)
        If !lDbSaved
            TafConOut("[TAFMTDONE][" + cJobId + "] Snapshot V3J não atualizado; nova tentativa ocorrerá no próximo checkpoint.")
            If lRelease
                lRelease := .F.
            EndIf
        EndIf
    EndIf

    If lRelease
        lRelease := TAFMTREL(aMeta[MT_COMPANY], aMeta[MT_BRANCH], cJobId)
        If lRelease
            MTPURGE(cJobId, aMeta[MT_TOTAL])
        EndIf
    EndIf

Return lSaved

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTWDON
@type Function
Registra o término do worker e fecha o job quando todos saírem.
Mantém como incerto qualquer unidade assumida sem confirmação de resultado.

@param cJobId, Character, identificador da transmissão.
@param lFatal, Logical, indica falha operacional no worker.
@param cMessage, Character, mensagem do encerramento.
@param lPersist, Logical, indica se o ambiente permite atualizar a V3J.
@param lUncertain, Logical, indica unidade assumida sem confirmação de resultado.
@return Logical, indica se o término foi registrado.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTWDON(cJobId As Character, lFatal As Logical, cMessage As Character, lPersist As Logical, lUncertain As Logical, nTask As Numeric) As Logical

    Local aEvents   As Array
    Local aMembers  As Array
    Local aMeta     As Array
    Local aTask     As Array
    Local bOldError As Block
    Local cUID      As Character
    Local lCanPurge As Logical
    Local lHasMeta  As Logical
    Local lRelease  As Logical
    Local lSaved    As Logical
    Local lStarted  As Logical
    Local nPhase    As Numeric
    Local nMember   As Numeric
    Local oError    As Object

    Default cJobId   := ""
    Default lFatal   := .F.
    Default cMessage := ""
    Default lPersist   := .T.
    Default lUncertain := .F.
    Default nTask      := 0

    aEvents   := {}
    aMembers  := {}
    aTask     := {}
    aMeta     := {}
    bOldError := Nil
    cUID      := MTUID(cJobId)
    lCanPurge := .T.
    lHasMeta  := .F.
    lRelease  := .F.
    lSaved    := .F.
    lStarted  := .F.
    nPhase    := 0
    nMember   := 0
    oError    := Nil

    lStarted := MTBTX(cUID, "META", 400)

    If !lStarted; TafConOut("[TAFMTWDON][" + cJobId + "] Timeout ao registrar o término do worker. O encerramento dependerá do TAFMTEXP."); MTPDEC(cJobId); Return .F.; EndIf

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        If VarGetAD(cUID, "META", @aMeta) .And. Len(aMeta) >= MT_PHASE
            aMeta[MT_WDONE] := Min(aMeta[MT_WORKERS], aMeta[MT_WDONE] + 1)

            If lFatal
                aMeta[MT_WFAILED]++
                If !Empty(cMessage)
                    aMeta[MT_MESSAGE] := cMessage
                EndIf
                If lUncertain .And. aMeta[MT_ACTIVE] > 0 .And.;
                   (aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING)
                    aMeta[MT_STATUS]  := MT_UNCERT
                    aMeta[MT_MESSAGE] := "Há unidade assumida sem resultado confirmado. " +;
                                        cMessage
                    If !Empty(aMeta[MT_EVENTS])
                        aEvents  := aClone(aMeta[MT_EVENTS])
                        aMembers := {}
                        If nTask > 0 .And. VarGetAD(cUID, MTTKEY(nTask), @aTask)
                            aMembers := MTMEMBERS(aTask)
                        EndIf
                        If Empty(aMembers); nPhase := Max(1, Min(Len(aEvents), Int(aMeta[MT_PHASE]))); aEvents[nPhase][EV_STATUS] := MT_UNCERT
                        Else
                            For nMember := 1 To Len(aMembers)
                                nPhase := MTEVINDEX(aEvents, aMembers[nMember][1])
                                aEvents[nPhase][EV_STATUS] := MT_UNCERT
                            Next nMember
                        EndIf
                        aMeta[MT_EVENTS] := aEvents
                    EndIf
                EndIf
            EndIf

            If aMeta[MT_WDONE] >= aMeta[MT_WORKERS] .And.;
               (aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING)
                If aMeta[MT_DONE] < aMeta[MT_TOTAL]
                    If aMeta[MT_ACTIVE] > 0; aMeta[MT_STATUS] := MT_UNCERT; aMeta[MT_MESSAGE] := "Há unidade assumida sem resultado confirmado."
                    Else
                        aMeta[MT_STATUS]  := MT_ERROR
                        aMeta[MT_MESSAGE] := "A transmissão terminou antes de processar todas as unidades."
                        lRelease := .T.
                    EndIf
                ElseIf aMeta[MT_FAILED] > 0 .Or. aMeta[MT_ERRORS] > 0 .Or. aMeta[MT_WFAILED] > 0; aMeta[MT_STATUS] := MT_PARTIAL; If Empty(aMeta[MT_MESSAGE]) .Or. "Worker " $ aMeta[MT_MESSAGE]; aMeta[MT_MESSAGE] := "Transmissão concluída com ocorrências."; EndIf
                Else
                    aMeta[MT_STATUS]  := MT_OK
                    aMeta[MT_MESSAGE] := "Transmissão concluída."
                EndIf
                If aMeta[MT_STATUS] == MT_OK .Or. aMeta[MT_STATUS] == MT_PARTIAL
                    lRelease := .T.
                EndIf
            ElseIf lFatal .And. aMeta[MT_STATUS] == MT_OK; aMeta[MT_STATUS] := MT_PARTIAL; aMeta[MT_MESSAGE] := "Transmissão concluída, mas um worker terminou com falha operacional."; lRelease := .T.
            ElseIf aMeta[MT_WDONE] >= aMeta[MT_WORKERS] .And.;
                   (aMeta[MT_STATUS] == MT_OK .Or. aMeta[MT_STATUS] == MT_PARTIAL .Or.;
                    aMeta[MT_STATUS] == MT_ERROR)
                // Confirma a liberação antes de remover o estado do último worker.
                lRelease := .T.
            EndIf

            aMeta[MT_UDATE] := Date()
            aMeta[MT_UTIME] := Time()
            lSaved          := VarSetAD(cUID, "META", aMeta)
            If lSaved .And. lPersist
                lSaved := MTDBSAVE(aMeta, .F.)
            EndIf
            If !lSaved; lRelease := .F.; EndIf

        EndIf
    Recover Using oError; lSaved   := .F.; lRelease := .F.; TafConOut("[TAFMTWDON] " + TAFMTERR(oError)); End Sequence

    lSaved := MTENDT(cUID, "META", lSaved)
    If !lSaved; lRelease := .F.; EndIf

    ErrorBlock(bOldError)

    If !MTPDEC(cJobId); TafConOut("[TAFMTWDON][" + cJobId + "] Falha ao liberar um slot do pool de workers."); EndIf


    If lRelease .And. lPersist
        lRelease := TAFMTREL(aMeta[MT_COMPANY], aMeta[MT_BRANCH], cJobId)
        lCanPurge := lRelease
        If lRelease
            MTPURGE(cJobId, aMeta[MT_TOTAL])
        EndIf
    EndIf

    If lSaved .And. lPersist .And. lCanPurge .And.;
       aMeta[MT_WDONE] >= aMeta[MT_WORKERS] .And.;
       (aMeta[MT_STATUS] == MT_OK .Or. aMeta[MT_STATUS] == MT_PARTIAL .Or.;
        aMeta[MT_STATUS] == MT_ERROR .Or. aMeta[MT_STATUS] == MT_UNCERT)
        MTPURGE(cJobId, 0, .T.)
    EndIf

Return lSaved

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTFAIL
@type Function
Finaliza uma falha de inicialização e controla a reserva da empresa.
Diferencia falha anterior ao envio de estado com resultado não confirmado.

@param cJobId, Character, identificador da transmissão.
@param cMessage, Character, motivo da falha.
@param cCompany, Character, empresa usada pelo controle da transmissão.
@param cBranch, Character, filial usada para preparar o ambiente.
@return Variant, encerra sem conteúdo de retorno.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTFAIL(cJobId As Character, cMessage As Character, cCompany As Character, cBranch As Character) As Variant

    Local aMeta     As Array
    Local bOldError As Block
    Local cUID      As Character
    Local lHasMeta  As Logical
    Local lRelease  As Logical
    Local lSaved    As Logical
    Local lStarted  As Logical
    Local oError    As Object

    Default cJobId   := ""
    Default cMessage := "Falha não identificada na transmissão multithread."
    Default cCompany := ""
    Default cBranch  := ""

    aMeta     := {}
    bOldError := Nil
    cUID      := MTUID(cJobId)
    lHasMeta  := .F.
    lRelease  := .F.
    lSaved    := .F.
    lStarted  := .F.
    oError    := Nil

    If !VarIsUID(cUID)
        If !Empty(cCompany) .And. !Empty(cBranch); TAFMTREL(cCompany, cBranch, cJobId); EndIf
        Return Nil
    EndIf

    lStarted := MTBTX(cUID, "META", 400)
    If lStarted
        // Uma tarefa já assumida pode ter resultado não confirmado; sem tarefa iniciada,
        // a falha pode encerrar o job com segurança.
        bOldError := ErrorBlock({|e| Break(e)})
        Begin Sequence
            If VarGetAD(cUID, "META", @aMeta) .And. Len(aMeta) >= MT_EVENTS
                lHasMeta := .T.
                If aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING
                    If aMeta[MT_ACTIVE] > 0
                        aMeta[MT_STATUS]  := MT_UNCERT
                        aMeta[MT_MESSAGE] := "Falha após início de unidade; " +;
                                            "resultado não confirmado. " +;
                                            cMessage
                    Else
                        aMeta[MT_STATUS]  := MT_ERROR
                        aMeta[MT_MESSAGE] := cMessage
                        lRelease         := .T.
                    EndIf
                    aMeta[MT_UDATE] := Date()
                    aMeta[MT_UTIME] := Time()
                    lSaved          := VarSetAD(cUID, "META", aMeta)
                    If lSaved
                        lSaved := MTDBSAVE(aMeta, .F.)
                    EndIf
                Else; lSaved := .T.; EndIf
            EndIf
        Recover Using oError; lSaved := .F.; TafConOut("[TAFMTFAIL] " + TAFMTERR(oError)); End Sequence
        lSaved := MTENDT(cUID, "META", lSaved)
        ErrorBlock(bOldError)
    EndIf

    If lStarted .And. !lHasMeta .And. !Empty(cCompany) .And. !Empty(cBranch); TAFMTREL(cCompany, cBranch, cJobId)
    ElseIf lSaved .And. lRelease .And. Len(aMeta) >= MT_BRANCH
        lRelease := TAFMTREL(aMeta[MT_COMPANY], aMeta[MT_BRANCH], cJobId)
        If lRelease
            MTPURGE(cJobId, aMeta[MT_TOTAL], .T.)
        EndIf
    EndIf

Return Nil

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTEXP
@type Function
Executa a reconciliação compartilhada antes de considerar uma reserva expirada.
Não possui uma segunda regra de lifecycle independente.

@param cJobId, Character, identificador da transmissão.
@return Logical, indica se o job deixou de permanecer ativo após a reconciliação.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTEXP(cJobId As Character) As Logical

    Local cMessage As Character
    Local cState   As Character

    Default cJobId := ""

    cMessage := ""
    cState   := TAFMTRCN(cJobId, @cMessage)

Return cState == "terminal" .Or. cState == "requires_reconciliation" .Or. cState == "absent"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTGET
@type Function
Obtém o estado atual usado pela consulta da transmissão.
Devolve somente estruturas completas e compatíveis com o contrato do monitor.

@param cJobId, Character, identificador da transmissão.
@param aMeta, Array, estado devolvido ao chamador.
@return Logical, indica se o estado completo foi encontrado.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTGET(cJobId As Character, aMeta As Array) As Logical

    Local bOldError As Block
    Local lFound    As Logical
    Local oError    As Object

    Default cJobId := ""
    Default aMeta  := {}

    bOldError := Nil
    lFound    := .F.
    oError    := Nil

    aMeta := {}


    If Empty(cJobId); Return .F.; EndIf

    // Procura primeiro no AppServer dono e depois no resumo compartilhado.
    bOldError := ErrorBlock({|e| Break(e)})

    Begin Sequence
        If VarIsUID(MTUID(cJobId))
            lFound := VarGetAD(MTUID(cJobId), "META", @aMeta)
        EndIf
        If !lFound
            lFound := MTDBGET(cJobId, @aMeta)
        EndIf
    Recover Using oError; lFound := .F.; TafConOut("[TAFMTGET] " + TAFMTERR(oError)); End Sequence

    ErrorBlock(bOldError)

Return lFound .And. ValType(aMeta) == "A" .And. Len(aMeta) >= MT_EVENTS

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTLCK
@type Function
Obtém o controle exclusivo usado para uma gravação compartilhada.
Centraliza a espera limitada utilizada pelos workers na mesma chave.

@param cKey, Character, nome do controle.
@param nAttempts, Numeric, quantidade máxima de tentativas.
@return Logical, indica se o controle foi obtido.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTLCK(cKey As Character, nAttempts As Numeric) As Logical

    Local cUID As Character

    Default cKey      := ""
    Default nAttempts := 12000

    cUID := "TAFMT_MUTEX"


    If !VarSetUID(cUID, .T.); Return .F.; EndIf

Return MTBTX(cUID, Upper(AllTrim(cKey)), nAttempts)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTULK
@type Function
Libera um mutex obtido por TAFMTLCK.
Preserva o resultado da liberação para o chamador tratar qualquer falha.

@param cKey, Character, nome do controle.
@return Logical, indica se o controle foi liberado.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTULK(cKey As Character) As Logical

    Default cKey := ""

Return MTENDT("TAFMT_MUTEX", Upper(AllTrim(cKey)), .T.)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTDBSAVE
@type Static Function
Grava na V3J somente snapshots monotônicos do resumo compartilhado do job.
Recusa progresso atrasado e impede reabertura de estado terminal.

@param aMeta, Array, estado consolidado da transmissão.
@param lInsert, Logical, permite criar o ticket do job.
@return Logical, indica se o snapshot foi aceito e persistido.

@author Denis R. de Oliveira
@since 13/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTDBSAVE(aMeta As Array, lInsert As Logical) As Logical

    Local aArea           As Array
    Local aCurrent        As Array
    Local aCurrentEvents  As Array
    Local aNewEvents      As Array
    Local bOldError       As Block
    Local cJobId          As Character
    Local cJson           As Character
    Local lFinished       As Logical
    Local lFound          As Logical
    Local lLocked         As Logical
    Local lSaved          As Logical
    Local lWrite          As Logical
    Local nCurrentRecords As Numeric
    Local nEvent          As Numeric
    Local nNewRecords     As Numeric
    Local nPercent        As Numeric
    Local oError          As Object

    Default aMeta   := {}
    Default lInsert := .F.

    aArea           := GetArea()
    aCurrent        := {}
    aCurrentEvents  := {}
    aNewEvents      := {}
    bOldError       := Nil
    cJobId          := ""
    cJson           := ""
    lFinished       := .F.
    lFound          := .F.
    lLocked         := .F.
    lSaved          := .F.
    lWrite          := .T.
    nCurrentRecords := 0
    nEvent          := 0
    nNewRecords     := 0
    nPercent        := 0
    oError          := Nil

    If Len(aMeta) < MT_EVENTS; Return .F.; EndIf

    cJobId := aMeta[MT_ID]
    cJson  := MTTOJSON(aMeta)
    If Empty(cJobId) .Or. Empty(cJson); Return .F.; EndIf

    nPercent  := MTRPCT(aMeta)
    lFinished := !(aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING)
    bOldError := ErrorBlock({|e| Break(e)})

    Begin Sequence
        DbSelectArea("V3J")
        V3J->(DbSetOrder(1))
        lFound := V3J->(DbSeek(MTDBKEY(cJobId)))
        If lFound
            lLocked := RecLock("V3J", .F.)
        ElseIf lInsert
            lLocked := RecLock("V3J", .T.)
            If lLocked
                V3J->V3J_FILIAL := xFilial("V3J")
                V3J->V3J_ID     := cJobId
                V3J->V3J_SERVIC := Left("TAFEsocialMonitorTransmission", TamSX3("V3J_SERVIC")[1])
                V3J->V3J_METODO := "POST"
                V3J->V3J_DTREQ  := aMeta[MT_CDATE]
                V3J->V3J_HRREQ  := StrTran(aMeta[MT_CTIME], ":", "")
            EndIf
        EndIf

        If lLocked
            // O snapshot persistido nunca reduz contadores, registros ou lifecycle.
            If lFound .And. !Empty(V3J->V3J_PARAMS)
                aCurrent := {}
                If MTFROMJS(V3J->V3J_PARAMS, @aCurrent)
                    If aCurrent[MT_DONE] > aMeta[MT_DONE] .Or.;
                       aCurrent[MT_WDONE] > aMeta[MT_WDONE] .Or.;
                       aCurrent[MT_WFAILED] > aMeta[MT_WFAILED] .Or.;
                       aCurrent[MT_SENT] > aMeta[MT_SENT] .Or.;
                       aCurrent[MT_ERRORS] > aMeta[MT_ERRORS] .Or.;
                       aCurrent[MT_FAILED] > aMeta[MT_FAILED]
                        lWrite := .F.
                    EndIf

                    aCurrentEvents := aCurrent[MT_EVENTS]
                    aNewEvents     := aMeta[MT_EVENTS]
                    For nEvent := 1 To Len(aCurrentEvents)
                        If ValType(aCurrentEvents[nEvent]) == "A" .And. Len(aCurrentEvents[nEvent]) >= EV_RDONE
                            nCurrentRecords += Max(0, aCurrentEvents[nEvent][EV_RDONE])
                            If nEvent <= Len(aNewEvents) .And. ValType(aNewEvents[nEvent]) == "A" .And. Len(aNewEvents[nEvent]) >= EV_RDONE .And. aCurrentEvents[nEvent][EV_RDONE] > aNewEvents[nEvent][EV_RDONE]; lWrite := .F.; EndIf
                        EndIf
                    Next nEvent
                    For nEvent := 1 To Len(aNewEvents)
                        If ValType(aNewEvents[nEvent]) == "A" .And. Len(aNewEvents[nEvent]) >= EV_RDONE; nNewRecords += Max(0, aNewEvents[nEvent][EV_RDONE]); EndIf
                    Next nEvent
                    If nCurrentRecords > nNewRecords; lWrite := .F.; EndIf

                    If (aCurrent[MT_STATUS] == MT_OK .Or. aCurrent[MT_STATUS] == MT_PARTIAL .Or. aCurrent[MT_STATUS] == MT_ERROR) .And.;
                       !(aMeta[MT_STATUS] == MT_OK .Or. aMeta[MT_STATUS] == MT_PARTIAL .Or. aMeta[MT_STATUS] == MT_ERROR)
                        lWrite := .F.
                    ElseIf (aCurrent[MT_STATUS] == MT_PARTIAL .And. aMeta[MT_STATUS] == MT_OK) .Or.;
                           (aCurrent[MT_STATUS] == MT_ERROR .And. aMeta[MT_STATUS] <> MT_ERROR)
                        lWrite := .F.
                    EndIf
                EndIf
            EndIf

            If lWrite
                V3J->V3J_STATUS := IIf(lFinished, "2", "1")
                V3J->V3J_PERC   := Max(0, Min(100, nPercent))
                V3J->V3J_PARAMS := cJson
                If lFinished
                    V3J->V3J_DTRESP := Date()
                    V3J->V3J_HRRESP := StrTran(Time(), ":", "")
                EndIf
            EndIf
            V3J->(MsUnlock())
            lLocked := .F.
            lSaved  := lWrite
        EndIf
    Recover Using oError; lSaved := .F.; TafConOut("[MTDBSAVE] " + TAFMTERR(oError)); End Sequence

    If lLocked; V3J->(MsUnlock()); EndIf
    ErrorBlock(bOldError)
    RestArea(aArea)

Return lSaved

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTDBGET
@type Static Function
Lê da V3J o resumo persistido pelo AppServer proprietário do job.
Distingue ausência confirmada de falha técnica ou conteúdo inválido.

@param cJobId, Character, identificador da transmissão.
@param aMeta, Array, estado devolvido por referência.
@param lAccessOk, Logical, indica leitura concluída mesmo quando o registro não existe.
@return Logical, indica se o resumo foi recuperado.

@author Denis R. de Oliveira
@since 13/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTDBGET(cJobId As Character, aMeta As Array, lAccessOk As Logical) As Logical

    Local aArea     As Array
    Local bOldError As Block
    Local cJson     As Character
    Local lExists   As Logical
    Local lFound    As Logical
    Local oError    As Object

    Default cJobId   := ""
    Default aMeta    := {}
    Default lAccessOk := .F.

    aArea     := GetArea()
    bOldError := Nil
    cJson     := ""
    lExists   := .F.
    lFound    := .F.
    oError    := Nil
    aMeta     := {}
    lAccessOk := .F.

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        DbSelectArea("V3J")
        V3J->(DbSetOrder(1))
        lExists := V3J->(DbSeek(MTDBKEY(cJobId)))
        If lExists
            cJson     := V3J->V3J_PARAMS
            lFound    := MTFROMJS(cJson, @aMeta)
            lAccessOk := lFound
        Else
            lAccessOk := .T.
        EndIf
    Recover Using oError; lFound := .F.; lAccessOk := .F.; TafConOut("[MTDBGET] " + TAFMTERR(oError)); End Sequence

    ErrorBlock(bOldError)
    RestArea(aArea)

Return lFound

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MNDBSET
@type Static Function
Grava o controle curto usado para identificar uma transmissão Mono no escopo compartilhado.

@param cJobId, Character, identificador da transmissão Mono.
@param cCompany, Character, empresa do ambiente.
@param cBranch, Character, filial do ambiente.
@param lActive, Logical, indica se a transmissão permanece ativa.
@return Logical, indica se o controle foi gravado.

@author Denis R. de Oliveira
@since 19/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MNDBSET(cJobId As Character, cCompany As Character, cBranch As Character, lActive As Logical) As Logical

    Local aArea     As Array
    Local bOldError As Block
    Local cParams   As Character
    Local cPort     As Character
    Local cServer   As Character
    Local lFound    As Logical
    Local lLocked   As Logical
    Local lSaved    As Logical
    Local nThread   As Numeric
    Local oError    As Object

    Default cJobId   := ""
    Default cCompany := ""
    Default cBranch  := ""
    Default lActive  := .F.

    aArea     := GetArea()
    bOldError := Nil
    cParams   := ""
    cPort     := ""
    cServer   := ""
    lFound    := .F.
    lLocked   := .F.
    lSaved    := .F.
    nThread   := 0
    oError    := Nil

    If Empty(cJobId); Return .F.; EndIf

    nThread := IIf(lActive, ThreadID(), 0)
    If lActive .And. nThread <= 0; Return .F.; EndIf
    cServer := MTSERVER()
    cPort   := MTPORT()
    cParams := "M2|" + cCompany + "|" + cBranch + "|" + cValToChar(nThread) + "|" +;
               IIf(Empty(cServer), "-", cServer) + "|" + IIf(Empty(cPort), "-", cPort)

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        DbSelectArea("V3J")
        V3J->(DbSetOrder(1))
        lFound := V3J->(DbSeek(MTDBKEY(cJobId)))
        If lFound .And. AllTrim(V3J->V3J_SERVIC) == AllTrim(Left("TAFMT_MONO", TamSX3("V3J_SERVIC")[1]))
            lLocked := RecLock("V3J", .F.)
        ElseIf !lFound
            lLocked := RecLock("V3J", .T.)
            If lLocked
                V3J->V3J_FILIAL := xFilial("V3J")
                V3J->V3J_ID     := cJobId
                V3J->V3J_SERVIC := Left("TAFMT_MONO", TamSX3("V3J_SERVIC")[1])
                V3J->V3J_METODO := "POST"
                V3J->V3J_DTREQ  := Date()
                V3J->V3J_HRREQ  := StrTran(Time(), ":", "")
            EndIf
        EndIf

        If lLocked
            V3J->V3J_STATUS := IIf(lActive, "1", "2")
            V3J->V3J_PARAMS := cParams
            If !lActive
                V3J->V3J_DTRESP := Date()
                V3J->V3J_HRRESP := StrTran(Time(), ":", "")
            EndIf
            V3J->(MsUnlock())
            lLocked := .F.
            lSaved  := .T.
        EndIf
    Recover Using oError; lSaved := .F.; TafConOut("[MNDBSET] " + TAFMTERR(oError)); End Sequence

    If lLocked; V3J->(MsUnlock()); EndIf
    ErrorBlock(bOldError)
    RestArea(aArea)

Return lSaved

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MNDBGET
@type Static Function
Lê o controle Mono e distingue ausência confirmada de falha de acesso.

@param cJobId, Character, identificador da transmissão Mono.
@param cCompany, Character, empresa do controle.
@param cBranch, Character, filial do controle.
@param lActive, Logical, indica se o controle está ativo.
@param cServer, Character, IP do AppServer que iniciou o processamento Mono.
@param cPort, Character, porta do AppServer que iniciou o processamento Mono.
@param nThread, Numeric, ThreadID que executa o processamento Mono.
@param lAccessOk, Logical, indica leitura concluída mesmo sem registro Mono.
@param nAge, Numeric, idade da observação Mono em segundos.
@return Logical, indica se um controle Mono válido foi recuperado.

@author Denis R. de Oliveira
@since 19/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MNDBGET(cJobId As Character, cCompany As Character, cBranch As Character, lActive As Logical,;
                        cServer As Character, cPort As Character, nThread As Numeric, lAccessOk As Logical, nAge As Numeric) As Logical

    Local aArea     As Array
    Local aScope    As Array
    Local bOldError As Block
    Local lFound    As Logical
    Local oError    As Object

    Default cJobId    := ""
    Default cCompany  := ""
    Default cBranch   := ""
    Default lActive   := .F.
    Default cServer   := ""
    Default cPort     := ""
    Default nThread   := 0
    Default lAccessOk := .F.
    Default nAge      := 0

    aArea     := GetArea()
    aScope    := {}
    bOldError := Nil
    lFound    := .F.
    oError    := Nil
    cCompany  := ""
    cBranch   := ""
    lActive   := .F.
    cServer   := ""
    cPort     := ""
    nThread   := 0
    lAccessOk := .F.
    nAge      := 0

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        DbSelectArea("V3J")
        V3J->(DbSetOrder(1))
        If !V3J->(DbSeek(MTDBKEY(cJobId)))
            lAccessOk := .T.
        ElseIf AllTrim(V3J->V3J_SERVIC) <> AllTrim(Left("TAFMT_MONO", TamSX3("V3J_SERVIC")[1]))
            lAccessOk := .T.
        Else
            aScope := StrTokArr(AllTrim(V3J->V3J_PARAMS), "|")
            If Len(aScope) >= 4 .And. aScope[1] == "M2" .And. !Empty(aScope[2])
                cCompany  := aScope[2]
                cBranch   := aScope[3]
                lActive   := V3J->V3J_STATUS == "1"
                nThread   := Val(aScope[4])
                If Len(aScope) >= 5 .And. aScope[5] <> "-"; cServer := aScope[5]; EndIf
                If Len(aScope) >= 6 .And. aScope[6] <> "-"; cPort := aScope[6]; EndIf
                If !Empty(V3J->V3J_DTREQ) .And. Len(AllTrim(V3J->V3J_HRREQ)) >= 6; nAge := Max(0, ((Date() - V3J->V3J_DTREQ) * 86400) + Seconds() - ((Val(SubStr(V3J->V3J_HRREQ, 1, 2)) * 3600) + (Val(SubStr(V3J->V3J_HRREQ, 3, 2)) * 60) + Val(SubStr(V3J->V3J_HRREQ, 5, 2)))); EndIf
                lFound    := .T.
                lAccessOk := .T.
            ElseIf Len(aScope) >= 2 .And. !Empty(aScope[1]); cCompany := aScope[1]; cBranch := aScope[2]; lActive := V3J->V3J_STATUS == "1"; If Len(aScope) >= 7; cServer := aScope[3]; cPort := aScope[6]; nThread := Val(aScope[7]); EndIf; If !Empty(V3J->V3J_DTREQ) .And. Len(AllTrim(V3J->V3J_HRREQ)) >= 6; nAge := Max(0, ((Date() - V3J->V3J_DTREQ) * 86400) + Seconds() - ((Val(SubStr(V3J->V3J_HRREQ, 1, 2)) * 3600) + (Val(SubStr(V3J->V3J_HRREQ, 3, 2)) * 60) + Val(SubStr(V3J->V3J_HRREQ, 5, 2)))); EndIf; lFound := .T.; lAccessOk := .T.
            EndIf
        EndIf
    Recover Using oError; lFound := .F.; lAccessOk := .F.; TafConOut("[MNDBGET] " + TAFMTERR(oError)); End Sequence

    ErrorBlock(bOldError)
    RestArea(aArea)

Return lFound

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTSCOPEOWN
@type Function
Confirma se a reserva da empresa continua pertencendo ao job informado.
Mantém o bloqueio apenas durante a leitura do identificador proprietário.

@param cCompany, Character, empresa do ambiente.
@param cJobId, Character, identificador da transmissão.
@return Logical, indica se o job continua proprietário da reserva.

@author Denis R. de Oliveira
@since 18/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTSCOPEOWN(cCompany As Character, cJobId As Character) As Logical

    Local aArea     As Array
    Local bOldError As Block
    Local cScopeId  As Character
    Local lLocked   As Logical
    Local lOwned    As Logical
    Local oError    As Object

    Default cCompany := ""
    Default cJobId   := ""

    aArea     := GetArea()
    bOldError := Nil
    cScopeId  := MTSCOPEID(cCompany)
    lLocked   := .F.
    lOwned    := .F.
    oError    := Nil

    If Empty(cScopeId) .Or. Empty(cJobId); Return .F.; EndIf

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        DbSelectArea("V3J")
        V3J->(DbSetOrder(1))
        If V3J->(DbSeek(MTDBKEY(cScopeId)))
            lLocked := RecLock("V3J", .F.)
            If lLocked
                lOwned := V3J->V3J_STATUS == "1" .And. AllTrim(V3J->V3J_PARAMS) == cJobId
                V3J->(MsUnlock())
                lLocked := .F.
            EndIf
        EndIf
    Recover Using oError; lOwned := .F.; End Sequence

    If lLocked; V3J->(MsUnlock()); EndIf
    ErrorBlock(bOldError)
    RestArea(aArea)

Return lOwned

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTSCOPEN
@type Static Function
Garante a existência do registro curto usado como reserva da empresa.
Uma inclusão concorrente é confirmada por nova busca da mesma chave.

@param cScopeId, Character, identificador determinístico da empresa.
@return Logical, indica se o registro está disponível para bloqueio.

@author Denis R. de Oliveira
@since 13/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTSCOPEN(cScopeId As Character) As Logical

    Local bOldError As Block
    Local lCreated  As Logical
    Local lLocked   As Logical
    Local oError    As Object

    Default cScopeId := ""

    bOldError := Nil
    lCreated  := V3J->(DbSeek(MTDBKEY(cScopeId)))
    lLocked   := .F.
    oError    := Nil

    If lCreated; Return .T.; EndIf

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        lLocked := RecLock("V3J", .T.)
        If lLocked
            V3J->V3J_FILIAL := xFilial("V3J")
            V3J->V3J_ID     := cScopeId
            V3J->V3J_SERVIC := Left("TAFMT_SCOPE", TamSX3("V3J_SERVIC")[1])
            V3J->V3J_METODO := "LOCK"
            V3J->V3J_DTREQ  := Date()
            V3J->V3J_HRREQ  := StrTran(Time(), ":", "")
            V3J->V3J_STATUS := "2"
            V3J->V3J_PERC   := 0
            V3J->V3J_PARAMS := ""
            V3J->(MsUnlock())
            lLocked  := .F.
            lCreated := .T.
        EndIf
    Recover Using oError; lCreated := .F.; End Sequence

    If lLocked; V3J->(MsUnlock()); EndIf
    ErrorBlock(bOldError)

    If !lCreated; Sleep(25); EndIf

Return V3J->(DbSeek(MTDBKEY(cScopeId)))

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTSCOPEID
@type Static Function
Monta a chave estável usada para reservar uma empresa na V3J.
Respeita o tamanho do campo definido no dicionário do ambiente.

@param cCompany, Character, empresa preparada para a transmissão.
@return Character, identificador da reserva.

@author Denis R. de Oliveira
@since 13/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTSCOPEID(cCompany As Character) As Character

    Default cCompany := ""

Return Left("TAFMTSCOPE" + Upper(AllTrim(cCompany)), TamSX3("V3J_ID")[1])

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTDBKEY
@type Static Function
Completa o identificador conforme o índice principal da V3J.
Usa o compartilhamento configurado no dicionário da tabela.

@param cId, Character, identificador do job ou da reserva.
@return Character, chave pronta para a busca.

@author Denis R. de Oliveira
@since 13/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTDBKEY(cId As Character) As Character

    Default cId := ""

Return xFilial("V3J") + PadR(cId, TamSX3("V3J_ID")[1])

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTTOJSON
@type Static Function
Serializa o resumo do job sem transportar as tarefas para o banco.
Mantém todos os contadores necessários ao frontend novo.

@param aMeta, Array, estado interno da transmissão.
@return Character, conteúdo JSON persistido na V3J.

@author Denis R. de Oliveira
@since 13/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTTOJSON(aMeta As Array) As Character

    Local cJson As Character
    Local oJson As Object

    Default aMeta := {}

    cJson := ""
    oJson := JsonObject():New()

    If Len(aMeta) >= MT_EVENTS
        oJson["id"]             := aMeta[MT_ID]
        oJson["status"]         := aMeta[MT_STATUS]
        oJson["total"]          := aMeta[MT_TOTAL]
        oJson["done"]           := aMeta[MT_DONE]
        oJson["workers"]        := aMeta[MT_WORKERS]
        oJson["workersDone"]    := aMeta[MT_WDONE]
        oJson["sent"]           := aMeta[MT_SENT]
        oJson["errors"]         := aMeta[MT_ERRORS]
        oJson["failed"]         := aMeta[MT_FAILED]
        oJson["message"]        := aMeta[MT_MESSAGE]
        oJson["createdDate"]    := DToS(aMeta[MT_CDATE])
        oJson["createdTime"]    := aMeta[MT_CTIME]
        oJson["updatedDate"]    := DToS(aMeta[MT_UDATE])
        oJson["updatedTime"]    := aMeta[MT_UTIME]
        oJson["company"]        := aMeta[MT_COMPANY]
        oJson["branch"]         := aMeta[MT_BRANCH]
        oJson["next"]           := aMeta[MT_NEXT]
        oJson["workerFailures"] := aMeta[MT_WFAILED]
        oJson["workersStarted"] := aMeta[MT_WSTART]
        oJson["startWait"]      := aMeta[MT_STWAIT]
        oJson["runWait"]        := aMeta[MT_RTWAIT]
        oJson["types"]          := aMeta[MT_TYPES]
        oJson["events"]         := aMeta[MT_EVENTS]
        oJson["phase"]          := aMeta[MT_PHASE]
        oJson["active"]         := aMeta[MT_ACTIVE]
        oJson["persistDate"]    := DToS(aMeta[MT_PDATE])
        oJson["persistTime"]    := aMeta[MT_PTIME]
        oJson["owner"]          := aMeta[MT_OWNER]
        cJson := oJson:ToJson()
    EndIf

    FreeObj(oJson)

Return cJson

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTFROMJS
@type Function
Reconstrói o array do job a partir do resumo salvo na V3J.
Permite usar o estado persistido quando o META não está disponível neste AppServer.

@param cJson, Character, resumo persistido.
@param aMeta, Array, estado reconstruído por referência.
@return Logical, indica se o conteúdo possui o contrato atual.

@author Denis R. de Oliveira
@since 13/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTFROMJS(cJson As Character, aMeta As Array) As Logical

    Local aEvents As Array
    Local aTypes  As Array
    Local oJson   As Object
    Local xError  As Variant

    Default cJson := ""
    Default aMeta := {}

    aEvents := {}
    aTypes  := {}
    aMeta   := {}
    oJson   := JsonObject():New()
    xError  := oJson:FromJson(cJson)

    If (ValType(xError) == "C" .And. !Empty(xError)) .Or. Empty(oJson["id"])
        FreeObj(oJson)
        Return .F.
    EndIf

    If ValType(oJson["types"]) == "A"
        aTypes := aClone(oJson["types"])
    EndIf
    If ValType(oJson["events"]) == "A"
        aEvents := aClone(oJson["events"])
    EndIf

    aMeta := {oJson["id"], oJson["status"], oJson["total"], oJson["done"],;
              oJson["workers"], oJson["workersDone"], oJson["sent"], oJson["errors"],;
              oJson["failed"], oJson["message"], StoD(oJson["createdDate"]),;
              oJson["createdTime"], StoD(oJson["updatedDate"]), oJson["updatedTime"],;
              oJson["company"], oJson["branch"], oJson["next"], oJson["workerFailures"],;
              oJson["workersStarted"], oJson["startWait"], oJson["runWait"], aTypes, aEvents,;
              Max(1, Int(IIf(ValType(oJson["phase"]) == "N", oJson["phase"], 1))),;
              Max(0, Int(IIf(ValType(oJson["active"]) == "N", oJson["active"], 0))),;
              IIf(ValType(oJson["persistDate"]) == "C", StoD(oJson["persistDate"]), StoD(oJson["updatedDate"])),;
              IIf(ValType(oJson["persistTime"]) == "C", oJson["persistTime"], oJson["updatedTime"]),;
              IIf(ValType(oJson["owner"]) == "C", oJson["owner"], ""), {}}

    FreeObj(oJson)

Return Len(aMeta) >= MT_EVENTS

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTEXPMETA
@type Function
Finaliza o job que não confirmou a entrada de nenhum worker no prazo.
Jobs já iniciados não são encerrados apenas pela idade do estado.

@param aMeta, Array, estado atualizado por referência.
@return Logical, indica se o prazo foi ultrapassado.

@author Denis R. de Oliveira
@since 13/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTEXPMETA(aMeta As Array) As Logical

    Local lExpired As Logical
    Local nAge     As Numeric

    Default aMeta := {}

    lExpired := .F.
    nAge     := MTAGE(aMeta)

    If Len(aMeta) >= MT_EVENTS .And. (aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING)
        If aMeta[MT_WSTART] == 0 .And. nAge > aMeta[MT_STWAIT]
            aMeta[MT_STATUS]  := MT_ERROR
            aMeta[MT_MESSAGE] := "Nenhum worker confirmou início no prazo."
            lExpired          := .T.
        EndIf
    EndIf

    If lExpired; aMeta[MT_UDATE] := Date(); aMeta[MT_UTIME] := Time(); EndIf

Return lExpired

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTPDEC
@type Static Function
Libera do pool o espaço reservado pelo worker que terminou.
Remove a entrada do job depois que o último slot for devolvido.

@param cJobId, Character, identificador da transmissão.
@return Logical, indica se o pool foi atualizado.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTPDEC(cJobId As Character) As Logical

    Local aPool     As Array
    Local bOldError As Block
    Local cUID      As Character
    Local lSaved    As Logical
    Local lStarted  As Logical
    Local nItem     As Numeric
    Local oError    As Object

    Default cJobId := ""

    aPool     := {}
    bOldError := Nil
    cUID      := "TAFMT_POOL"
    lSaved    := .T.
    lStarted  := .F.
    nItem     := 0
    oError    := Nil

    If Empty(cJobId) .Or. !VarIsUID(cUID)
        Return .T.
    EndIf

    lStarted := MTBTX(cUID, "POOL", 400)

    If !lStarted; Return .F.; EndIf

    // Cada término devolve um slot da reserva feita antes do StartJob.
    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        If VarGetAD(cUID, "POOL", @aPool)
            For nItem := 1 To Len(aPool)
                If aPool[nItem][1] == cJobId
                    aPool[nItem][2]--
                    If aPool[nItem][2] <= 0
                        ADel(aPool, nItem)
                        ASize(aPool, Len(aPool) - 1)
                    EndIf
                    lSaved := VarSetAD(cUID, "POOL", aPool)
                    Exit
                EndIf
            Next nItem
        EndIf
    Recover Using oError; lSaved := .F.; TafConOut("[MTPDEC] " + TAFMTERR(oError)); End Sequence

    lSaved := MTENDT(cUID, "POOL", lSaved)
    ErrorBlock(bOldError)

Return lSaved

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTPPOOLLIVE
@type Static Function
Confirma os workers vivos de uma entrada do pool local.
Mantém a reserva quando a criação dos workers ainda não pode ser concluída.

@param cJobId, Character, identificador da transmissão.
@param nWorkers, Numeric, quantidade de workers vivos devolvida por referência.
@return Logical, indica se a verificação foi concluída.

@author Denis R. de Oliveira
@since 21/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTPPOOLLIVE(cJobId As Character, nWorkers As Numeric) As Logical

    Local aInfo      As Array
    Local aMeta      As Array
    Local bOldError  As Block
    Local cUID       As Character
    Local lEnded     As Logical
    Local lFound     As Logical
    Local lRead      As Logical
    Local lStarted   As Logical
    Local nItem      As Numeric
    Local oError     As Object

    Default cJobId   := ""
    Default nWorkers := 0

    aInfo      := {}
    aMeta      := {}
    bOldError  := Nil
    cUID       := MTUID(cJobId)
    lEnded     := .F.
    lFound     := .F.
    lRead      := .F.
    lStarted   := .F.
    nItem      := 0
    nWorkers   := -1
    oError     := Nil

    If Empty(cJobId) .Or. !VarIsUID(cUID); nWorkers := 0; Return .T.; EndIf

    lStarted := MTBTX(cUID, "META", 400)
    If !lStarted; Return .F.; EndIf

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        lRead := .T.
        If VarGetAD(cUID, "META", @aMeta)
            If Len(aMeta) >= MT_THREADS .And. ValType(aMeta[MT_THREADS]) == "A"; lFound := .T.; Else; lRead := .F.; EndIf
        EndIf
    Recover Using oError; lRead := .F.; End Sequence

    lEnded := MTENDT(cUID, "META", .T.)
    ErrorBlock(bOldError)

    If !lEnded .Or. !lRead; Return .F.; EndIf
    If !lFound; nWorkers := 0; Return .T.; EndIf

    // A reserva inicial não é reduzida enquanto ainda podem surgir workers deste job.
    If (aMeta[MT_STATUS] == MT_QUEUED .Or. aMeta[MT_STATUS] == MT_RUNNING) .And.;
       (aMeta[MT_WSTART] + aMeta[MT_WDONE]) < aMeta[MT_WORKERS] .And.;
       MTAGE(aMeta) < aMeta[MT_STWAIT]
        Return .F.
    EndIf

    nWorkers := 0
    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        aInfo := GetUserInfoArray()
        For nItem := 1 To Len(aMeta[MT_THREADS]); If AScan(aInfo, {|x| x[3] == aMeta[MT_THREADS][nItem]}) > 0; nWorkers++; EndIf; Next nItem
    Recover Using oError; lRead := .F.; nWorkers := -1; End Sequence
    ErrorBlock(bOldError)


If !lRead; Return .F.; EndIf

Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTDBDUE
@type Static Function
Indica quando o resumo compartilhado precisa de novo snapshot na V3J.

@param aMeta, Array, estado local do job.
@param nSeconds, Numeric, intervalo mínimo entre snapshots.
@return Logical, indica se o intervalo foi atingido.

@author Denis R. de Oliveira
@since 14/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTDBDUE(aMeta As Array, nSeconds As Numeric) As Logical

    Local nElapsed As Numeric

    Default aMeta    := {}
    Default nSeconds := 2

    nElapsed := 0

    nElapsed := ((Date() - aMeta[MT_PDATE]) * 86400) +;
                (MTTSEC(Time()) - MTTSEC(aMeta[MT_PTIME]))

Return nElapsed >= Max(1, Int(nSeconds))

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTRPCT
@type Function
Calcula o percentual persistido priorizando os registros selecionados.
Usa unidades de trabalho somente quando o monitor não informou totais.

@param aMeta, Array, estado consolidado do job.
@return Numeric, percentual inteiro entre zero e cem.

@author Denis R. de Oliveira
@since 14/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTRPCT(aMeta As Array) As Numeric

    Local aEvents As Array
    Local nDone   As Numeric
    Local nEvent  As Numeric
    Local nTotal  As Numeric

    Default aMeta := {}

    aEvents := {}
    nDone   := 0
    nEvent  := 0
    nTotal  := 0

    If Len(aMeta) >= MT_EVENTS .And. ValType(aMeta[MT_EVENTS]) == "A"
        aEvents := aMeta[MT_EVENTS]
        For nEvent := 1 To Len(aEvents)
            If ValType(aEvents[nEvent]) == "A" .And. Len(aEvents[nEvent]) >= EV_RDONE
                nTotal += Max(0, aEvents[nEvent][EV_RTOTAL])
                nDone  += Max(0, aEvents[nEvent][EV_RDONE])
            EndIf
        Next nEvent
    EndIf

    If nTotal > 0
        Return Int((Min(nDone, nTotal) / nTotal) * 100)
    EndIf

    If Len(aMeta) >= MT_DONE .And. aMeta[MT_TOTAL] > 0
        Return Int((aMeta[MT_DONE] / aMeta[MT_TOTAL]) * 100)
    EndIf

Return 0

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTISSERIAL
@type Static Function
Mantém eventos de tabela em execução sequencial por empregador.
Abrange os códigos S-10xx para preservar também layouts legados da família.

@param cEvent, Character, código do evento.
@return Logical, indica se apenas uma unidade pode ficar ativa.

@author Denis R. de Oliveira
@since 14/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTISSERIAL(cEvent As Character) As Logical

    Default cEvent := ""

    cEvent := StrTran(Upper(AllTrim(cEvent)), "-", "")

Return Left(cEvent, 3) == "S10"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTGRPMIR
@type Static Function
Replica nos membros o progresso apurado para a unidade conjunta.
O processamento devolve totais da unidade, portanto todos os eventos dela exibem o mesmo avanço.

@param aEvents, Array, contadores por evento.
@param aMembers, Array, eventos da unidade.
@param nOwner, Numeric, posição do evento que mantém os contadores.
@return Nil

@author Denis R. de Oliveira
@since 23/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTGRPMIR(aEvents As Array, aMembers As Array, nOwner As Numeric)

    Local nMember As Numeric
    Local nPos    As Numeric

    Default aEvents  := {}
    Default aMembers := {}
    Default nOwner   := 0

    nMember := 0
    nPos    := 0

    If Len(aMembers) > 1 .And. nOwner > 0
        For nMember := 2 To Len(aMembers)
            nPos := MTEVINDEX(aEvents, aMembers[nMember][1])
            aEvents[nPos][EV_RTOTAL] := aEvents[nOwner][EV_RTOTAL]
            aEvents[nPos][EV_RDONE]  := aEvents[nOwner][EV_RDONE]
        Next nMember
    EndIf

Return Nil

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTMEMBERS
@type Function
Devolve os eventos que a unidade de trabalho deve enviar em uma única consulta.
Unidades comuns possuem um evento; unidades conjuntas preservam a ordem recebida.

@param aTask, Array, unidade de trabalho.
@return Array, pares de código e alias dos eventos da unidade.

@author Denis R. de Oliveira
@since 22/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTMEMBERS(aTask As Array) As Array

    Local aMembers As Array

    Default aTask := {}

    aMembers := {}

    If Len(aTask) >= MT_TKGROUP .And. ValType(aTask[MT_TKGROUP]) == "A" .And. !Empty(aTask[MT_TKGROUP])
        aMembers := aClone(aTask[MT_TKGROUP])
    ElseIf Len(aTask) >= 2
        AAdd(aMembers, {aTask[1], aTask[2]})
    EndIf

Return aMembers

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTEVINDEX
@type Function
Localiza o contador do evento associado a uma unidade concluída.
Compara o código normalizado sem alterar a ordem dos cartões.

@param aEvents, Array, contadores por evento.
@param cEvent, Character, código procurado.
@return Numeric, posição encontrada ou zero.

@author Denis R. de Oliveira
@since 13/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function MTEVINDEX(aEvents As Array, cEvent As Character) As Numeric

    Local nEvent As Numeric

    Default aEvents := {}
    Default cEvent  := ""

    For nEvent := 1 To Len(aEvents)
        If ValType(aEvents[nEvent]) == "A" .And. Len(aEvents[nEvent]) >= EV_STATUS
            If Upper(AllTrim(aEvents[nEvent][EV_CODE])) == Upper(AllTrim(cEvent))
                Return nEvent
            EndIf
        EndIf
    Next nEvent

Return 0

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTOWNER
@type Static Function
Monta a identidade da instância que criou o job.
Combina IP e porta do AppServer para diferenciar instâncias da mesma base.

@return Character, identidade da instância ou vazio quando não for possível determiná-la.

@author Denis R. de Oliveira
@since 18/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTOWNER() As Character

    Local cOwner   As Character
    Local cPort    As Character
    Local cServer  As Character

    cOwner   := ""
    cPort    := MTPORT()
    cServer  := MTSERVER()

    If Empty(cServer) .Or. Empty(cPort); Return ""; EndIf

    cOwner := Upper(cServer + "|" + cPort)

Return cOwner

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTSERVER
@type Static Function
Obtém o IP da instância atual para identificação diagnóstica do processamento.

@return Character, IP atual ou vazio quando indisponível.

@author Denis R. de Oliveira
@since 21/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTSERVER() As Character

    Local bOldError As Block
    Local cServer   As Character
    Local oError    As Object

    bOldError := Nil
    cServer   := ""
    oError    := Nil

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        cServer := AllTrim(GetServerIP())
    Recover Using oError; cServer := ""; End Sequence
    ErrorBlock(bOldError)

Return cServer

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTPORT
@type Static Function
Obtém a porta da instância atual para identificação diagnóstica do processamento.

@return Character, porta atual ou vazio quando indisponível.

@author Denis R. de Oliveira
@since 21/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTPORT() As Character

    Local bOldError As Block
    Local cPort     As Character
    Local oError    As Object

    bOldError := Nil
    cPort     := ""
    oError    := Nil

    bOldError := ErrorBlock({|e| Break(e)})
    Begin Sequence
        cPort := AllTrim(cValToChar(GetServerPort()))
    Recover Using oError; cPort := ""; End Sequence
    ErrorBlock(bOldError)

Return cPort

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTJOBMSG
Acrescenta os identificadores operacionais disponíveis à mensagem de lifecycle.
Não inventa Thread para snapshots remotos ou execuções já interrompidas.

@return Character, porta atual ou vazio quando indisponível.

@author Denis R. de Oliveira
@since 21/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTJOBMSG(cMessage As Character, cJobId As Character, cOwner As Character, cThread As Character) As Character

    Local cDetails   As Character
    Local cPort      As Character
    Local cServer    As Character
    Local nSeparator As Numeric

    Default cMessage := ""
    Default cJobId   := ""
    Default cOwner   := ""
    Default cThread  := ""

    cDetails   := ""
    cPort      := ""
    cServer    := ""
    nSeparator := At("|", cOwner)

    If nSeparator > 0
        cServer := AllTrim(Left(cOwner, nSeparator - 1))
        cPort   := AllTrim(SubStr(cOwner, nSeparator + 1))
    EndIf

    If Empty(cMessage); cMessage := "Não foi possível confirmar o andamento da transmissão neste momento."; EndIf
    If !Empty(cJobId); cDetails += Chr(13) + Chr(10) + "JobId: " + cJobId; EndIf
    If !Empty(cOwner); cDetails += Chr(13) + Chr(10) + "Owner: " + AllTrim(cOwner); EndIf
    If !Empty(cServer); cDetails += Chr(13) + Chr(10) + "Servidor: " + cServer; EndIf
    If !Empty(cPort); cDetails += Chr(13) + Chr(10) + "Porta: " + cPort; EndIf
    If !Empty(cThread); cDetails += Chr(13) + Chr(10) + "ThreadId: " + cThread; EndIf
    If !Empty(cDetails); cMessage += Chr(13) + Chr(10) + Chr(13) + Chr(10) + "Informações da transmissão:" + cDetails; EndIf
    cMessage += Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
                "Se após aguardar e tentar novamente o estado continuar, ou houver necessidade urgente, entre em contato com o TI para verificar o Job no WebMonitor."

Return cMessage


//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTUID
@type Static Function
Monta o identificador da área compartilhada do job.
Mantém cada transmissão isolada nas variáveis globais do AppServer.

@param cJobId, Character, identificador da transmissão.
@return Character, nome usado nas variáveis globais.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTUID(cJobId As Character) As Character

    Default cJobId := ""

Return "TAFMT_" + cJobId

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTTKEY
@type Static Function
Monta a chave usada para armazenar uma tarefa.
Aplica tamanho fixo para manter a ordenação e evitar colisões de nomes.

@param nTask, Numeric, número da tarefa.
@return Character, chave formatada da tarefa.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTTKEY(nTask As Numeric) As Character

    Default nTask := 0

Return "TASK_" + StrZero(nTask, 6)

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTPURGE
@type Static Function
Remove tarefas e estado local depois que o resumo final foi gravado na V3J.
Evita acumular memória no AppServer sem perder a consulta do job.

@param cJobId, Character, identificador da transmissão.
@param nTasks, Numeric, quantidade de tarefas gravadas.
@param lRemoveMeta, Logical, remove também o resumo local já persistido.
@return Variant, encerra sem conteúdo de retorno.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTPURGE(cJobId As Character, nTasks As Numeric, lRemoveMeta As Logical) As Variant

    Local bOldError As Block
    Local cUID      As Character
    Local nTask     As Numeric
    Local oError    As Object

    Default cJobId      := ""
    Default nTasks      := 0
    Default lRemoveMeta := .F.

    bOldError := ErrorBlock({|e| Break(e)})
    cUID      := MTUID(cJobId)
    nTask     := 0
    oError    := Nil

    // As tarefas são imutáveis e podem ser removidas após a consolidação.
    Begin Sequence
        For nTask := 1 To nTasks
            VarDel(cUID, MTTKEY(nTask))
        Next nTask
        If lRemoveMeta
            VarDel(cUID, "META")
        EndIf
    Recover Using oError; TafConOut("[MTPURGE] " + TAFMTERR(oError)); End Sequence

    ErrorBlock(bOldError)

Return Nil

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTWRITE
@type Static Function
Grava um array protegido pelo controle da mesma chave.
Confirma a liberação do bloqueio antes de considerar a escrita concluída.

@param cUID, Character, área compartilhada.
@param cKey, Character, chave do valor.
@param aValue, Array, conteúdo que será gravado.
@return Logical, indica se a gravação foi concluída.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTWRITE(cUID As Character, cKey As Character, aValue As Array) As Logical

    Local bOldError As Block
    Local lSaved    As Logical
    Local lStarted  As Logical
    Local oError    As Object

    Default cUID   := ""
    Default cKey   := ""
    Default aValue := {}

    bOldError := ErrorBlock({|e| Break(e)})
    lSaved    := .F.
    lStarted  := .F.
    oError    := Nil

    // A gravação e a liberação do controle formam uma única operação lógica.
    Begin Sequence
        lStarted := MTBTX(cUID, cKey, 200)
        If lStarted
            lSaved := VarSetAD(cUID, cKey, aValue)
        EndIf
    Recover Using oError; lSaved := .F.; TafConOut("[MTWRITE] " + TAFMTERR(oError)); End Sequence

    If lStarted
        lSaved := MTENDT(cUID, cKey, lSaved)
    EndIf

    ErrorBlock(bOldError)

Return lSaved

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTBTX
@type Static Function
Tenta iniciar o controle exclusivo de uma chave compartilhada.
Repete por tempo limitado para absorver contenções curtas entre workers.

@param cUID, Character, área compartilhada.
@param cKey, Character, chave que será protegida.
@param nAttempts, Numeric, quantidade máxima de tentativas.
@return Logical, indica se o controle foi obtido.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTBTX(cUID As Character, cKey As Character, nAttempts As Numeric) As Logical

    Local bOldError As Block
    Local lStarted  As Logical
    Local nTry      As Numeric
    Local oError    As Object

    Default cUID      := ""
    Default cKey      := ""
    Default nAttempts := 200

    bOldError := ErrorBlock({|e| Break(e)})
    lStarted  := .F.
    nTry      := 0
    oError    := Nil

    // Aguarda em intervalos curtos para absorver contenção entre workers.
    Begin Sequence
        For nTry := 1 To nAttempts
            If VarBeginT(cUID, cKey)
                lStarted := .T.
                Exit
            EndIf
            Sleep(25)
        Next nTry
    Recover Using oError; lStarted := .F.; TafConOut("[MTBTX] " + TAFMTERR(oError)); End Sequence

    ErrorBlock(bOldError)

Return lStarted

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTENDT
@type Static Function
Libera o controle da chave e preserva o resultado da gravação.
Só devolve sucesso quando a operação e o encerramento forem concluídos.

@param cUID, Character, área compartilhada.
@param cKey, Character, chave protegida.
@param lSaved, Logical, resultado obtido durante o controle.
@return Logical, indica se a operação e a liberação terminaram.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTENDT(cUID As Character, cKey As Character, lSaved As Logical) As Logical

    Local bOldError As Block
    Local lEnded    As Logical
    Local oError    As Object

    Default cUID   := ""
    Default cKey   := ""
    Default lSaved := .F.

    bOldError := ErrorBlock({|e| Break(e)})
    lEnded    := .F.
    oError    := Nil

    Begin Sequence
        lEnded := VarEndT(cUID, cKey)
    Recover Using oError; lEnded := .F.; TafConOut("[MTENDT] " + TAFMTERR(oError)); End Sequence

    ErrorBlock(bOldError)

Return lSaved .And. lEnded

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTAGE
@type Static Function
Calcula o tempo desde a última atualização do job.
Considera a troca de data e nunca devolve idade negativa.

@param aMeta, Array, estado atual da transmissão.
@return Numeric, idade em segundos.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTAGE(aMeta As Array) As Numeric

    Local nAge As Numeric

    Default aMeta := {}

    nAge := 999999999

    If Len(aMeta) >= MT_UTIME
        If ValType(aMeta[MT_UDATE]) == "D" .And. ValType(aMeta[MT_UTIME]) == "C"
            nAge := Max(0, ((Date() - aMeta[MT_UDATE]) * 86400) + Seconds() - MTTSEC(aMeta[MT_UTIME]))
        EndIf
    EndIf

Return nAge

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTPROGAGE
@type Static Function
Calcula o tempo desde o último checkpoint que confirmou avanço do processamento.
Não usa a atualização administrativa de entrada ou saída de worker.

@param aMeta, Array, estado atual da transmissão.
@return Numeric, idade em segundos do último avanço confirmado.

@author Denis R. de Oliveira
@since 21/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTPROGAGE(aMeta As Array) As Numeric

    Local nAge As Numeric

    Default aMeta := {}

    nAge := 999999999

    If Len(aMeta) >= MT_PTIME
        If ValType(aMeta[MT_PDATE]) == "D" .And. ValType(aMeta[MT_PTIME]) == "C"
            nAge := Max(0, ((Date() - aMeta[MT_PDATE]) * 86400) + Seconds() - MTTSEC(aMeta[MT_PTIME]))
        EndIf
    EndIf

Return nAge

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MTTSEC
@type Static Function
Converte um horário para segundos desde o início do dia.
Aceita o formato padrão do Protheus usado nos registros de controle.

@param cTime, Character, horário no formato do Protheus.
@return Numeric, total de segundos.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function MTTSEC(cTime As Character) As Numeric

    Local aTime As Array
    Local nSec  As Numeric

    Default cTime := ""

    aTime := StrTokArr(cTime, ":")
    nSec  := 0

    nSec := (Val(aTime[1]) * 3600) + (Val(aTime[2]) * 60) + Val(aTime[3])

Return nSec

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TAFMTERR
@type Function
Monta uma mensagem curta para os erros internos do processamento multithread.
Inclui a operação do Error quando ela estiver disponível.

@param oError, Object, erro capturado pelo AdvPL.
@return Character, descrição pronta para o log.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
Function TAFMTERR(oError As Object) As Character

    Local cMessage As Character

    Default oError := Nil

    cMessage := "Erro não identificado."
    If ValType(oError) == "O"; cMessage := AllTrim(cValToChar(oError:Description)); If !Empty(oError:Operation); cMessage += " [" + AllTrim(cValToChar(oError:Operation)) + "]"; EndIf; EndIf

Return cMessage
