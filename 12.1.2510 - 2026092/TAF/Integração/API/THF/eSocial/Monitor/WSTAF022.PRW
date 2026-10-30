#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "WSTAF022.CH"

#DEFINE API_CODE "WSTAF022"
#DEFINE PAR_MT_THREADS "MV_TAFMTQE"

Static __aRetComp := {}

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSRESTFUL

/*/
//-------------------------------------------------------------------------------------------------------------
WSRESTFUL TAFEsocialMonitorTransmission DESCRIPTION "Transmissão de eventos do eSocial" //FORMAT APPLICATION_JSON

    WSDATA id        AS STRING OPTIONAL
    WSDATA companyId AS STRING OPTIONAL
    WSDATA mode      AS STRING OPTIONAL

    WSMETHOD POST TRANSMISSION  DESCRIPTION "Realiza a transmissão dos eventos do eSocial" WSSYNTAX "api/rh/esocial/v1/TAFEsocialMonitorTransmission" PATH "api/rh/esocial/v1/TAFEsocialMonitorTransmission"
    WSMETHOD GET STATUS DESCRIPTION "Consulta o estado da transmissão multithread" WSSYNTAX "api/rh/esocial/v1/TAFEsocialMonitorTransmission" PATH "api/rh/esocial/v1/TAFEsocialMonitorTransmission"

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo POST
Realiza a transmissão dos eventos do eSocial
S-1202 – Remuneração de servidor vinculado a Regime Próprio de Previd. Social

@params

@author José Mauro Dourado Lopes
@since 06/05/2020
@version 1.0
/*/
//-------------------------------------------------------------------------------------------------------------

WSMETHOD POST TRANSMISSION WSREST TAFEsocialMonitorTransmission

    Local cBody             as character
    Local cMsgRet           as character
    Local cValid            as character
    Local cEmpRequest       as character
    Local cFilRequest       as character
    Local cRecnos           as character
    Local cId               as character
    Local cPeriod           as character
    Local cUser             as character
    Local cStatus           as character
    Local cUserId           as Character
    Local lNoErro           as logical
    local lGlbVarFunctions  as logical
    Local nX                as numeric
    Local nZ                as numeric
    Local nSize             as numeric
    Local nAchou            as numeric
    Local nIds              as numeric
    Local oJson             as object
    Local aFiliais          as array
    Local aFilTss           as array
    lOCAL aCompany          as array
    Local aEvtsESoc         as array
    Local aEventos          as array
    Local aVersoes          as array
    Local aRecnos           as array
    Local aKeys             as array
    Local aErrosJob         as array
    Local aMotiveCode       as array
    Local aRetErro          as array
    Local aFilC1E           as array
    Local dDataIni          as date
    Local dDataFim          as date

    Local aProgressItem     as array
    Local aProgressTotals   as array
    Local cInvalidBranch    as character
    Local cModeRequest      as character
    Local cMTMsg            as character
    Local lModeSent         as logical
    Local lMTReserveFail    as logical
    Local lMTStarted        as logical
    Local lMultiThread      as logical
    Local lMonoReserved     as logical
    Local nMTHttp           as numeric
    Local nProgress         as numeric
    Local nThreads          as numeric
    Local xThreadParam      as variant

    lGlbVarFunctions    := FindFunction("hasUKeyByUID")
    cBody               := ''
    cRecnos             := ''
    cValid              := ''
    cStatus             := "' ','1','0'"
    oJson               := JsonObject():New()
    cBody               := self:GetContent()
    cUserId             := IIf(lGlbVarFunctions,;
                               getIdUserFromRequest(self:GetHeader("Authorization")),;
                               "000000")
    aEvtsESoc           := {}
    aEventos            := {}
    aFiliais            := {}
    aFilC1E             := {}
    aRecnos             := {}
    aKeys               := {}
    aVersoes            := {}
    aRetErro            := {}
    lNoErro             := .T.
    nIds                := 0

    aProgressItem    := {}
    aProgressTotals  := {}
    cInvalidBranch   := ""
    cModeRequest     := ""
    cMTMsg           := ""
    lModeSent        := .F.
    lMTReserveFail   := .F.
    lMTStarted       := .F.
    lMultiThread     := .F.
    lMonoReserved    := .F.
    nMTHttp          := 200
    nProgress        := 0
    nThreads         := 0
    xThreadParam     := Nil

    oJson:fromJSON( cBody )
    oResponse := JsonObject():New()
    ::SetContentType("application/json")

    cValid    := FPREVALID(oJson)
    cId       := TAFGERAID("TAF")

    If Empty(cValid)
        aCompany  := StrTokArr( oJson["companyId"], "|" )
        cEmpRequest := aCompany[1]
        cFilRequest := aCompany[2]

        cUser       := oJson["user"]

        If PrepEnv( cEmpRequest, cFilRequest )

            If TAFALSINDIC("V5N")

                aFiliais    := IIf(lGlbVarFunctions,;
                                   getFilFromRequestOrCached(oJson["branches"], cUserId, cEmpRequest, cFilRequest, API_CODE),;
                                   oJson["branches"])
                cPeriod     := StrTran( oJson["period"] , "/" )

                If oJson["periodFrom"] <> nil
                    dDataIni    := StoD(StrTran(oJson["periodFrom"], "-"))
                EndIf

                If oJson["periodTo"] <> nil
                    dDataFim    := StoD(StrTran(oJson["periodTo"], "-"))
                EndIf

                xThreadParam := GetNewPar(PAR_MT_THREADS, 0)
                If ValType(xThreadParam) == "N"
                    nThreads := Max(0, Min(8, Int(xThreadParam)))
                EndIf

                If ValType(oJson["mode"]) == "C" .And. !Empty(oJson["mode"])
                    cModeRequest := Lower(AllTrim(oJson["mode"]))
                    lModeSent    := .T.
                EndIf

                If lModeSent .And. cModeRequest <> "mono" .And. cModeRequest <> "multi"; cValid := "Não foi possível confirmar o modo da transmissão. Atualize o monitor e tente novamente."; nMTHttp := 400
                ElseIf !lModeSent; lMultiThread := .F.
                ElseIf (cModeRequest == "multi") <> (nThreads > 1); cValid := "O modo de transmissão foi alterado. Atualize o monitor e inicie uma nova tentativa."; nMTHttp := 400
                Else
                    lMultiThread := nThreads > 1
                EndIf

                aEvtsESoc   := TafRotinas(,,.T.,2)
                nSize       := len(oJson["events"])

                If oJson["motiveCode"] <> nil
                    aMotiveCode := aClone(oJson["motiveCode"])
                EndIf

                If Empty(cValid)
                    CRIALOG( cId , oJson["keys"] )
                    oResponse['id'] := cId
                EndIf

                For nX := 1 to nSize
                    nAchou := aScan(aEvtsESoc,{|x| x[4] == oJson["events"][nX]})
                    IF nAchou > 0
                        aadd(aEventos,aEvtsESoc[nAchou])
                    EndIf
                Next nX

                If Empty(cValid) .And. lMultiThread .And. Empty(aEventos); cValid := "Nenhum evento válido foi localizado para a transmissão."; EndIf

                If lMultiThread .And. ValType(oJson["progressTotals"]) == "A"
                    For nProgress := 1 To Len(oJson["progressTotals"])
                        If ValType(oJson["progressTotals"][nProgress]) == "C"
                            aProgressItem := StrTokArr(oJson["progressTotals"][nProgress], "|")
                            If Len(aProgressItem) >= 2 .And. !Empty(aProgressItem[1])
                                AAdd(aProgressTotals, {AllTrim(aProgressItem[1]), Max(0, Int(Val(AllTrim(aProgressItem[2]))))})
                            EndIf
                        EndIf
                    Next nProgress
                EndIf

                If oJson["keys"] <> nil .And. Len(oJson["keys"]) > 0
                    cStatus :=  "' ','1','0','3','6'"
                    For nZ := 1 to Len(oJson["keys"])
                        aIds := StrTokArr( oJson["keys"][nZ], "|" )
                        nIds := Len(aIds)

                        aadd(aVersoes, Iif(nIds >= 4, aIds[4], ""))
                        aadd(aKeys, Iif(nIds >= 3, aIds[3], ""))

                        If nIds >= 2
                            If aIds[2] == "S1000" .AND. !Empty(aIds[1])
                                aadd(aFilC1E, aIds[1])
                            EndIf
                        EndIf
                    Next nZ
                    If Empty(cValid); aRecnos := RETRECNO(aEventos,aKeys,aFiliais,aVersoes,aFilC1E); If lMultiThread .And. Empty(aRecnos); cValid := "Nenhum registro foi localizado."; EndIf; cRecnos := RETINSQL(aRecnos, .T.); EndIf
                ElseIf oJson["sendRejected"] <> nil .And. oJson["sendRejected"] == .T.
                    cStatus  += ",'3'"
                EndIf

                If Empty(cValid)
                    If lMultiThread
                        aFilTss := RETINFEMP(cEmpRequest, aFiliais, @cInvalidBranch)
                        If !Empty(cInvalidBranch); cValid := "Não foi possível carregar os dados cadastrais da filial " + cInvalidBranch + "."; EndIf
                    Else
                        aFilTss := RETINFEMP(cEmpRequest, aFiliais)
                    EndIf
                EndIf

                If Empty(cValid) .And. lMultiThread
                    lMTReserveFail := .F.
                    lMTStarted := TAFMTSTRT(cId, cEmpRequest, cFilRequest, aEventos, cStatus,;
                                           aRecnos, aFilTss, dDataIni, dDataFim, cPeriod, cUser,;
                                           aMotiveCode, nThreads, @cMTMsg, aProgressTotals, @lMTReserveFail)
                    If !lMTStarted; oResponse['success'] := .F.; oResponse['message'] := EncodeUTF8(cMTMsg); If lMTReserveFail; ::SetStatus(409); Else; oResponse['accepted'] := .F.; oResponse['jobId'] := cId; ::SetStatus(503); EndIf
                    Else
                        oResponse['success']  := .T.
                        oResponse['accepted'] := .T.
                        oResponse['jobId']    := cId
                        oResponse['message']  := EncodeUTF8(cMTMsg)
                        ::SetStatus(202)
                    EndIf

                ElseIf Empty(cValid)
                    lMonoReserved := TAFMNACQ(cEmpRequest, cFilRequest, cId)
                    aErrosJob := TAFProc4Tss(.T.,aEventos,cStatus,,,cRecnos, @lNoErro, @cMsgRet,.T.,aFilTss,dDataIni,dDataFim,,,,,,.T.,cPeriod,,cUser,aMotiveCode,@aRetErro)
                    If lMonoReserved; TAFMNREL(cEmpRequest, cFilRequest, cId); EndIf
                    TAFMErrT0X(aErrosJob,.T.)

                    If lNoErro
                        oResponse['success'] := .T.
                        oResponse['message'] := ENCODEUTF8(cMsgRet)
                        ::SetStatus(200)
                    Else
                        oResponse['success'] := .F.
                        oResponse['message'] := ENCODEUTF8(RETMSG(cMsgRet))
                        oResponse['type']    := RetType(aRetErro)
                        ::SetStatus(200)
                    EndIf

                Else; oResponse['success'] := .F.; oResponse['message'] := EncodeUTF8(cValid); ::SetStatus(nMTHttp); EndIf

            Else; oResponse['success'] := .F.; oResponse['message'] := EncodeUTF8(STR0005); ::SetStatus(200); EndIf

        else
            oResponse['success'] := .F.
            oResponse['message'] := STR0004
            ::SetStatus(200)
        Endif
    else
        oResponse['success'] :=.F.
        oResponse['message'] := ENCODEUTF8(cValid)
        ::SetStatus(200)
    EndIf
    ::SetResponse(oResponse:toJSON())

Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} Método GET STATUS
@type Method
Consulta o progresso da transmissão multithread. Mantém as unidades de trabalho
para compatibilidade e acrescenta o progresso por registros selecionados, geral e
por evento, sem misturar resultado de envio com avanço da fila.

@return Logical, indica que a resposta REST foi montada.

@author Denis R. de Oliveira
@since 04/08/2026
@version 1.0
/*/
//--------------------------------------------------------------------------------
WSMETHOD GET STATUS QUERYPARAM id, companyId, mode WSREST TAFEsocialMonitorTransmission

    Local aCompany       As Array
    Local aEventResponse As Array
    Local aMeta          As Array
    Local cEmpRequest    As Character
    Local cFilRequest    As Character
    Local cJobId         As Character
    Local cMTMsg         As Character
    Local cReconState    As Character
    Local jEvent         As Json
    Local jResponse      As Json
    Local lModeRequest   As Logical
    Local nEvent           As Numeric
    Local nEventPercent    As Numeric
    Local nEventRecDone    As Numeric
    Local nEventRecPercent As Numeric
    Local nEventRecTotal   As Numeric
    Local nPercent         As Numeric
    Local nRecordDone      As Numeric
    Local nRecordPercent   As Numeric
    Local nRecordTotal     As Numeric
    Local nThreads         As Numeric
    Local xThreadParam     As Variant

    aCompany       := {}
    aEventResponse := {}
    aMeta          := {}
    cEmpRequest    := ""
    cFilRequest    := ""
    cJobId         := ""
    cMTMsg         := ""
    cReconState    := ""
    jEvent         := Nil
    jResponse      := JsonObject():New()
    lModeRequest   := .F.
    nEvent           := 0
    nEventPercent    := 0
    nEventRecDone    := 0
    nEventRecPercent := 0
    nEventRecTotal   := 0
    nPercent         := 0
    nRecordDone      := 0
    nRecordPercent   := 0
    nRecordTotal     := 0
    nThreads         := 0
    xThreadParam     := Nil


    ::SetContentType("application/json")

    lModeRequest := ValType(::mode) == "C" .And. AllTrim(::mode) == "1"
    If lModeRequest
        If ValType(::companyId) <> "C" .Or. Empty(AllTrim(::companyId)); jResponse['success'] := .F.; jResponse['message'] := EncodeUTF8("Empresa não informada para consultar o modo de transmissão."); ::SetStatus(400)
        Else
            aCompany := StrTokArr(::companyId, "|")
            If Len(aCompany) < 2 .Or. Empty(aCompany[1]) .Or. Empty(aCompany[2]); jResponse['success'] := .F.; jResponse['message'] := EncodeUTF8("Empresa inválida para consultar o modo de transmissão."); ::SetStatus(400)
            Else
                cEmpRequest := aCompany[1]
                cFilRequest := aCompany[2]
                If !PrepEnv(cEmpRequest, cFilRequest); jResponse['success'] := .F.; jResponse['message'] := EncodeUTF8("Não foi possível preparar o ambiente para consultar o modo de transmissão."); ::SetStatus(503)
                Else
                    xThreadParam := GetNewPar(PAR_MT_THREADS, 0)
                    If ValType(xThreadParam) == "N"; nThreads := Max(0, Min(8, Int(xThreadParam))); EndIf
                    jResponse['success']     := .T.
                    jResponse['multiThread'] := nThreads >= 2
                    ::SetStatus(200)
                EndIf
            EndIf
        EndIf

        ::SetResponse(jResponse:toJSON())
        FreeObj(jResponse)
        Return .T.
    EndIf

    If ValType(::id) == "C"
        cJobId := ::id
    EndIf

    If Empty(cJobId); jResponse['success'] := .F.; jResponse['message'] := EncodeUTF8("Identificador da transmissão não informado."); ::SetStatus(400)
    Else
        cReconState := TAFMTRCN(cJobId, @cMTMsg)

        If cReconState == "absent"
            jResponse['success'] := .F.
            jResponse['jobId']   := cJobId
            jResponse['message'] := EncodeUTF8("Transmissão não localizada neste serviço.")
            ::SetStatus(404)
        ElseIf cReconState == "unknown"; jResponse['success'] := .F.; jResponse['jobId'] := cJobId; jResponse['message'] := EncodeUTF8(cMTMsg); ::SetStatus(503)
        ElseIf !TAFMTGET(cJobId, @aMeta); jResponse['success'] := .F.; jResponse['jobId'] := cJobId; jResponse['message'] := EncodeUTF8("Não foi possível consultar o estado da transmissão."); ::SetStatus(503)
        Else
            If aMeta[3] > 0
                nPercent := Round((aMeta[4] / aMeta[3]) * 100, 2)
            EndIf

            jResponse['success']                := .T.
            jResponse['accepted']               := .T.
            jResponse['active']                 := cReconState == "active"
            jResponse['completed']              := aMeta[2] == "completed" .Or.;
                                                   aMeta[2] == "completed_with_errors"
            jResponse['requiresReconciliation'] := aMeta[2] == "requires_reconciliation"
            jResponse['jobId']                  := cJobId
            jResponse['status']                 := aMeta[2]
            jResponse['total']                  := aMeta[3]
            jResponse['processed']              := aMeta[4]
            jResponse['unprocessed']            := Max(0, aMeta[3] - aMeta[4])
            jResponse['percent']                := nPercent
            jResponse['unit']                   := "workUnits"
            jResponse['workers']                := aMeta[5]
            jResponse['startedWorkers']         := aMeta[19]
            jResponse['finishedWorkers']        := aMeta[6]
            jResponse['sent']                   := aMeta[7]
            jResponse['errors']                 := aMeta[8]
            jResponse['failedWorkUnits']        := aMeta[9]
            jResponse['workerFailures']         := aMeta[18]
            jResponse['errorTypeCounts']        := aMeta[22]
            For nEvent := 1 To Len(aMeta[23])
                nEventPercent    := 0
                nEventRecDone    := 0
                nEventRecPercent := 0
                nEventRecTotal   := 0

                If aMeta[23][nEvent][2] > 0
                    nEventPercent := Round((aMeta[23][nEvent][3] / aMeta[23][nEvent][2]) * 100, 2)
                EndIf
                nEventRecTotal := Max(0, aMeta[23][nEvent][8])
                nEventRecDone  := Max(0, Min(nEventRecTotal, aMeta[23][nEvent][9]))
                If nEventRecTotal > 0
                    nEventRecPercent := Round((nEventRecDone / nEventRecTotal) * 100, 2)
                EndIf
                If !(Len(aMeta[23][nEvent]) >= 10 .And. aMeta[23][nEvent][10] == 1)
                    nRecordTotal += nEventRecTotal
                    nRecordDone  += nEventRecDone
                EndIf

                jEvent := JsonObject():New()
                jEvent['eventCode']              := aMeta[23][nEvent][1]
                jEvent['completed']              := aMeta[23][nEvent][7] == "completed" .Or.;
                                                    aMeta[23][nEvent][7] == "completed_with_errors"
                jEvent['requiresReconciliation'] := aMeta[23][nEvent][7] == "requires_reconciliation"
                jEvent['status']                 := aMeta[23][nEvent][7]
                jEvent['total']                  := aMeta[23][nEvent][2]
                jEvent['processed']              := aMeta[23][nEvent][3]
                jEvent['percent']                := nEventPercent
                jEvent['recordTotal']            := nEventRecTotal
                jEvent['recordProcessed']        := nEventRecDone
                jEvent['recordPercent']          := nEventRecPercent
                jEvent['aggregated']             := Len(aMeta[23][nEvent]) >= 10 .And. aMeta[23][nEvent][10] > 0
                jEvent['sent']                   := aMeta[23][nEvent][4]
                jEvent['errors']                 := aMeta[23][nEvent][5]
                jEvent['failedWorkUnits']        := aMeta[23][nEvent][6]
                AAdd(aEventResponse, jEvent)
            Next nEvent

            If nRecordTotal > 0
                nRecordPercent := Round((Min(nRecordDone, nRecordTotal) / nRecordTotal) * 100, 2)
            EndIf
            jResponse['recordTotal']            := nRecordTotal
            jResponse['recordProcessed']        := Min(nRecordDone, nRecordTotal)
            jResponse['recordPercent']          := nRecordPercent
            jResponse['events']                 := aEventResponse
            jResponse['message']                := EncodeUTF8(IIf(!Empty(cMTMsg), cMTMsg, aMeta[10]))
            jResponse['createdAt']              := DToS(aMeta[11]) + "T" + aMeta[12]
            jResponse['updatedAt']              := DToS(aMeta[13]) + "T" + aMeta[14]
            ::SetStatus(200)
        EndIf
    EndIf

    ::SetResponse(jResponse:toJSON())
    For nEvent := 1 To Len(aEventResponse)
        FreeObj(aEventResponse[nEvent])
    Next nEvent
    FreeObj(jResponse)

Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} function FPREVALID
Realiza validação dos dados enviados no payload.
@author  José Mauro - Cópia da do fonte WSMIDPROC.PRW
@since   06/05/2020
@version 12.1.25
/*/
//--------------------------------------------------------------------------------
Static Function FPREVALID(oJson)

    Local cMessage	:= ""

    If oJson["branches"] == Nil

        cMessage := STR0001

    ElseIf Empty(oJson["events"]) .OR. oJson["events"] == Nil

        cMessage := STR0002

    ElseIf Empty(oJson["companyId"]) .OR. oJson["companyId"] == Nil

        cMessage := STR0003

    EndIf

Return cMessage

//--------------------------------------------------------------------------------
/*/{Protheus.doc} RETRECNO
    (long_description)
    @type  Function
    @author José Mauro
    @since 08/05/2020
    @version 1.0
    @param
        aEventos -> Array com os eventos enviados na requisição.
        aKeys    -> Array com os ID's enviados na requisição.
        aFiliais -> Array com as filiasi enviadas na requisição.
    @return
        aRecnos -> Array de recnos em formato de STRING.
/*/
//--------------------------------------------------------------------------------
Function RETRECNO(aEventos, aKeys, aFiliais, aVersao, aFilC1E)

    Local cTab          as character
    Local cSelect       as character
    Local cAlias        as character
    Local cIds          as character
    Local cVersao       as character
    Local cFilC1E       as character
    Local aRecnos       as array
    Local nX            as numeric
    Local cAliasRegs    := GetNextAlias()

    Default aEventos    := {}
    Default aFiliais    := {}
    Default aKeys       := {}
    Default aVersao     := {}
    Default aFilC1E     := {}

    aRecnos             := {}
    cSelect             := ''
    nX                  := 0
    cAlias              := GetNextAlias()
    cFiliais            := TAFCacheFil(Nil, aFiliais, .T.)
    cIds                := RETINSQL(aKeys)
    cVersao             := RETINSQL(aVersao)
    cFilC1E             := TAFCacheFil(Nil, aFilC1E, .T.)

    For nX := 1 to len(aEventos)
        cTab := aEventos[nX][3]

        If nX == 1
            cSelect +=  " SELECT R_E_C_N_O_ AS RECNO FROM "+ RetSqlName( cTab )+ " WHERE "

            If aEventos[nX][4] == "S-1000"
                cSelect +=  cTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilC1E + " FILIAIS ) "
                cSelect +=  " AND " + cTab + "_FILTAF IN ( SELECT FILIAIS.FILIAL FROM " + cFiliais + " FILIAIS ) "
            Else
                cFiliais    := RETCOMP(aFiliais, cTab)
                cSelect     +=  cTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFiliais + " FILIAIS ) "
            EndIf

            cSelect +=  " AND "+ cTab + "_ID IN ("+cIds+")"
            cSelect +=  " AND "+ cTab + "_VERSAO IN ("+cVersao+")"
            cSelect +=  " AND "+ cTab + "_ATIVO= '1' AND D_E_L_E_T_ = '' "
        Else
            cSelect +=  "UNION ALL "
            cSelect +=  " SELECT R_E_C_N_O_ AS RECNO FROM "+ RetSqlName( cTab )+ " WHERE "

            If aEventos[nX][4] == "S-1000"
                cSelect +=  cTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilC1E + " FILIAIS ) "
                cSelect +=  " AND "+ cTab + "_FILTAF IN ( SELECT FILIAIS.FILIAL FROM " + cFiliais + " FILIAIS ) "
            Else
                cSelect +=  cTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFiliais + " FILIAIS ) "
            EndIf

            cSelect +=  " AND "+ cTab + "_ID IN ("+cIds+")"
            cSelect +=  " AND "+ cTab + "_VERSAO IN ("+cVersao+")"
            cSelect +=  " AND "+ cTab + "_ATIVO= '1' AND D_E_L_E_T_ = '' "
        EndIf
    Next nX

    cSelect := ChangeQuery(cSelect)

    TcQuery cSelect New Alias (cAliasRegs)


    (cAliasRegs)->(dbGoTop())

    While (cAliasRegs)->(!Eof())
        AADD(aRecnos,cvaltochar((cAliasRegs )->RECNO))
        (cAliasRegs)->(dbSkip())
    EndDo

Return aRecnos


//--------------------------------------------------------------------------------
/*/{Protheus.doc} RETINSQL
    (long_description)
    @type  Static Function
    @author user
    @since 11/05/2020
    @version version
    @param
        aArray -> Recebe um array para que seja transformado em string.
    @return
        Retorna o array separado por vírgula para montade de cláusula IN dentro da query.
    @example
    (examples)
    @see (links_or_references)
/*/
//--------------------------------------------------------------------------------
Static Function RETINSQL(aArray as array, lRetVazio as logical)

    Local cRetIn	as character
    Local nX		as numeric

    Default aArray := {}
    Default lRetVazio := .F.

    cRetIn	:= ""
    nX		:= 0

    If !Empty(aArray)
        For nX := 1 to Len(aArray)
            If nX > 1
                cRetIn += " , '" + aArray[nX] + "'"
            Else
                cRetIn += "'" + aArray[nX] + "'"
            EndIf
        Next nX
    Else
        cRetIn += IIf(lRetVazio,"","''")
    EndIf

Return cRetIn


//--------------------------------------------------------------------------------
/*/{Protheus.doc} RETINFEMP
    (long_description)
    @type  Static Function
    @author user
    @since 11/05/2020
    @version version
    @param
        cEmp -> Empresa para processamento.
        aFiliais -> Filiais para processamento.
    @return
        aRetFils -> Array com as informações necessárias para a função de montagem do XML.

/*/
//--------------------------------------------------------------------------------
Function RETINFEMP(cEmp, aFiliais, cInvalidBranch)

    Local nQ             as numeric
    Local aRetFils       as array
    Local aSM0           as array
    Local bOldError      as block
    Local oError         as object

    aRetFils := {}
    aSM0     := {}

    If PCount() < 3
        For nQ := 1 to len(aFiliais)
            aSM0 := FWSM0Util():GetSM0Data( cEmp , aFiliais[nQ] ,  { "M0_CODFIL", "M0_FILIAL" , "M0_CGC","M0_INSC" } )
            aadd(aRetFils,{.T.,aSM0[1][2],aSM0[2][2],aSM0[3][2],aSM0[4][2],""})
        Next nQ
        Return aRetFils
    EndIf

    Default cInvalidBranch := ""
    cInvalidBranch := ""
    bOldError := ErrorBlock({|e| Break(e)})
    oError := Nil

    Begin Sequence
        For nQ := 1 to len(aFiliais)
            aSM0 := FWSM0Util():GetSM0Data( cEmp , aFiliais[nQ] ,  { "M0_CODFIL", "M0_FILIAL" , "M0_CGC","M0_INSC" } )
            aadd(aRetFils,{.T.,aSM0[1][2],aSM0[2][2],aSM0[3][2],aSM0[4][2],""})
        Next nQ
    Recover Using oError; cInvalidBranch := "não identificada"; If nQ >= 1 .And. nQ <= Len(aFiliais); cInvalidBranch := cValToChar(aFiliais[nQ]); EndIf; TafConOut("[WSTAF022][RETINFEMP] Falha ao consultar a filial " + cInvalidBranch + "."); End Sequence

    ErrorBlock(bOldError)

Return IIf(Empty(cInvalidBranch), aRetFils, {})

//--------------------------------------------------------------------------------
/*/{Protheus.doc} function CRIALOG
Realiza a gravação do ID macro na tabela de controle de Transações
@author  José Mauro  - Cópia da do fonte WSMIDPROC.PRW
@since   13/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------------------
Static Function CRIALOG( cId, aKeys )
    Local cHEnv      as character
    Local dDtEnv
    Local nX		:= 1
    Local cKeys	:= ""
    Local lRet		:= .F.

    Default aKeys := {}

    // Preenchimento de String de Inputs a serem gravadas na V5N
    For nX := 1 To LEN( aKeys )
        cKeys += "|" + aKeys[nX]
    Next nX

    dDtEnv 	:= DATE()
    cHEnv 	:= Substr(TIME(), 1, 5)

    // Gravação na tabela
    DbSelectArea("V5N")
    V5N->(DbSetOrder(1)) // V5N_FILIAL, V5N_ID
    V5N->(DbGoTop())

    Begin Transaction
        Reclock( "V5N", .T.)
        V5N_FILIAL      := xFilial("V5N")
        V5N->V5N_ID 	:= cId
        V5N->V5N_DTREQ	:= dDtEnv
        V5N->V5N_HRREQ	:= cHEnv
        V5N->V5N_METODO	:= "POST"
        V5N->V5N_PARAMS	:= cKeys
        lRet := .T.
        V5N->(MsUnLock())
    End Transaction
Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} RETMSG
    (long_description)
    @type  Static Function
    @author José Mauro
    @since 24/06/2020
    @version 1.0
    @param cMsg -> Mensagem recebida do TSS para ser tratada.
    @return cMsg -> Mensagem tratada para ser exibida no frontend.
    @example
    (examples)
    @see (links_or_references)
/*/
//--------------------------------------------------------------------------------
Static Function RETMSG(cMsg)

    Default cMsg := 'Não foi possível concluir o processamento'

    if "WSCERR044" $ cMsg
        cMsg := 'O serviço do TSS não está disponível ou não foi localizado.'
    EndIf

Return cMsg

//--------------------------------------------------------------------------------
/*/{Protheus.doc} RetType
    Retorna o tipo de erro que foi apresentado no TAFProc9.
    @type  Function
    @author José Mauro
    @since 14/07/2020
    @version version
    @param Recebe o array que vem do TAFProc9.
    @return Retorna o tipo de erro.
        0 - Erro genérico
        1 - Erro de schema
        2 - Erro para se conectar no TSS
        3 - Erro de predecessão
        4 - Erro de TOKEN/Autenticação TAF X TSS.
/*/
//--------------------------------------------------------------------------------
Static Function RetType(aRetorno)

    Local nType         := 0
    Local nX            := 0

    Default aRetorno    := {}

    If !Empty(aRetorno)
        For nX := 1 to Len(aRetorno)
            If aRetorno[nX]
                nType :=  nX
            EndIf
        Next nX
    EndIf

Return nType

//--------------------------------------------------------------------------------
/*/{Protheus.doc} RETCOMP
    (long_description)
    @type  Static Function
    @author Alexandre .L
    @since 04/10/2021
    @version version
    @param
        aArray -> Recebe um array para que seja transformado em string.
    @return
        Retorna o array separado por vírgula para montade de cláusula IN dentro da query.
    @example
    Criação da função para que seja retornado a filial de acordo com o compartilhamento na SX2.
    (examples)
    @see (links_or_references)
/*/
//--------------------------------------------------------------------------------
Static Function RETCOMP(aArray as array, cTable as character)

    Local aKeyFil   as array
    Local aRetIn    as array
    Local cRetIn    as character
    Local cIDChFil  as character
    Local cKeyCache as character
    Local cVldTab   as character
    Local lForce    as logical
    Local nX        as numeric
    Local nFilCache as numeric

    Default aArray  := {}

    aKeyFil    := {}
    aRetIn     := {}
    cRetIn     := ""
    cIDChFil   := ""
    cKeyCache  := ""
    cVldTab    := VldTabTAF(cTable)
    lForce     := .F.
    nX         := 0
    nFilCache  := 0

    For nX := 1 To Len(aArray)
        AAdd(aRetIn, xFilial(cTable, aArray[nX]))
    Next

    aKeyFil := aClone(aRetIn)
    ASort(aKeyFil)

    cKeyCache := cVldTab + "|" + cEmpAnt + cFilAnt + "|"
    For nX := 1 To Len(aKeyFil)
        cKeyCache += AllTrim(aKeyFil[nX]) + ";"
    Next

    nFilCache := AScan(__aRetComp, {|x| x[1] == cVldTab})

    If nFilCache > 0
        cIDChFil := __aRetComp[nFilCache][3]
        If __aRetComp[nFilCache][2] <> cKeyCache; cIDChFil := UUIDRandom(); __aRetComp[nFilCache][2] := cKeyCache; __aRetComp[nFilCache][3] := cIDChFil; lForce := .T.; EndIf
    ElseIf !Empty(aArray)
        cIDChFil := UUIDRandom()
        AAdd(__aRetComp, {cVldTab, cKeyCache, cIDChFil})
        lForce := .T.
    EndIf

    cRetIn := TAFCacheFil(cTable, aRetIn, lForce,, cIDChFil)

Return cRetIn
