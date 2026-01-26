#include "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "hatActions.ch"

#define LOGHAT "ISLOG_SYNCHANDLER"
#define HASERROR "HASERROR_SYNCHANDLER"
#define MAINTHREAD "NAME_THREAD_GLOBAL_SYNCHANDLER"
#define PERSISTWORK "SYNCHANDLER_PERSISTE_WORK"
#define __NSLEEP 1000

/*/{Protheus.doc} SyncHelper
    Auxiliares para classe suncHandle
    @type  Class
    @author pld
    @since 12/03/2021
/*/
function exceptErro(e)
    local cError        := 'Erro no processamento:'
    local cDescription  := Iif(valType(e:Description) == 'N', cValToChar(e:Description), e:Description )
    local cErrorStack   := Iif(valType(e:ErrorStack) == 'N', cValToChar(e:ErrorStack), e:ErrorStack )

    cError += cDescription + CRLF + strTran(cErrorStack, cDescription, '')

    //aqui pode ser a main thread ou as thReads do manualjob
    PutGlbValue(HASERROR + allTrim(str(thReadID())), 'true')

    logInf(cError,'ERROR_LOG.log',,, .t.)

return

function isWorkSync()
    local cThCurrent := getGlbValue( HASERROR + allTrim(str(thReadID())) )
    local cThClasse  := getGlbValue( HASERROR + getGlbValue(MAINTHREAD) )

    cThCurrent := Iif(empty(cThCurrent), 'false', cThCurrent)
    cThClasse  := Iif(empty(cThClasse), 'false', cThClasse)

return cThCurrent == 'false' .and. cThClasse == 'false'

function logInf(cMessage, cFile, lTime, nSeconds, lcoNout)
    local cTime := time()

    default cFile       := allTrim(funName()) + ".log"
    default nSeconds    := -1
    default lTime       := .f.
    default lcoNout     := .f.

    if lTime

        if nSeconds == -1
            nSeconds := seconds()
            coNout(CRLF + '****** ' + cMessage + ' (' + dtoc(Date()) + ' - ' + cTime + ') ******')
        else
            coNout(CRLF + '****** ' + cMessage + ' (' + dtoc(Date()) + ' - ' + Time() + ' segundos [' + cValToChar(seconds()-nSeconds) + ']) ******')
        endIf

    else

        if getGlbValue(LOGHAT) == 'true'
            PLSLogHAT(cMessage,, cFile)
        endIf

        if lcoNout
            coNout(cMessage)
        else
            FWLogMsg('INFO',, 'HAT', funName(), '', '01', cMessage, 0, 0, {})
        endIf

    endIf

return nSeconds

function chkJsonTag(cTrack, oObj, aTag, nItem, cFile)
    local nI         := 1
    local nX         := 1
    local lRet       := .t.
    local cTag       := ''
    local cTagX      := ''
    local cError     := "[" + cTrack + "] "
    local aData      := {}
    local aTagSun    := {}
    local cNameR     := ''
    default nItem := -1

    for nI := 1 to len(aTag)

        cTag := aTag[nI]

        if at(",", cTag) > 1

            aTagSun := strToKArr(cTag, ',')

            for nX := 1 to len(aTagSun)

                cTagX := allTrim(aTagSun[nX])

                if oObj[cTagX] == nil
                    cError  += '(' + cTagX + ') nao existe na tag origem [' + cNameR +']'
                    lRet    := .f.
                    exit
                endIf

            next

        else

            if oObj[cTag] == nil

                cError  += '(' + cTag + ') nao existe na tag origem [' + cNameR +']'
                lRet    := .f.
                exit

            elseIf nItem <> -1 .and. valtype(oObj[cTag]) == 'A'

                aData := oObj[cTag]

                if nItem > len(aData)
                    cError  += 'Item (' + cValToChar(nItem) + ') nao existe na [' + cTag + ']'
                    lRet    := .f.
                    exit
                endIf

            endIf

            cNameR  := aTag[nI]
            oObj    := oObj[cTag]

        endIf

        if !lRet
            exit
        endIf

    next

    FreeObj(oObj)
    oObj := nil

    if !lRet
        logInf(cError, cFile,,,.t.)
    endIf

return lRet

/*
HAT_CONSULTA "1"
HAT_EXAME "2"
HAT_EXAME_EXECUCAO "3"
HAT_INTERNACAO "4"
HAT_ODONTO "9"
*/
function tpGuiDP(cTipGui,cDescr)
    local cRet := ''

    do case
        case 'Exame - Exec' $ cDescr
            cRet := '3'
        case alltrim(cTipGui) == HAT_CONSULTA
            cRet := '1'
        case alltrim(cTipGui) == HAT_EXAME
            cRet := '2'
        case alltrim(cTipGui) == HAT_INTERNACAO
            cRet := '4'
        case alltrim(cTipGui) == HAT_ODONTO
            cRet := '9'
    endCase

return cRet

function posProf(cUF, cNumCR, cSigCR, cNome, cCodigo, cTrack, cFile)
    local cCodOpe       := PLSINTPAD()
    local lRet          := .f.

    BB0->(DbSetOrder(1))

    cUF     := PADR(AllTrim(cUF),tamSX3("BB0_ESTADO")[1])
    cNumCR  := PADR(AllTrim(cNumCR),tamSX3("BB0_NUMCR")[1])
    cSigCR  := PADR(AllTrim(cSigCR),tamSX3("BB0_CODSIG")[1])
    cCodigo := PADR(AllTrim(cCodigo),tamSX3("BB0_CODIGO")[1])

    // Busca pelo BB0_CODIGO
    lRet := !empty(cCodigo) .AND. BB0->( MsSeek( xFilial("BB0") + cCodigo ) )

    if lRet
        logInf("[" + cTrack + "] profissional encontrado por código", cFile)
    endif

    // Caso não encontre, busca pela chave BB0_ESTADO + BB0_NUMCR + BB0_CODSIG
    BB0->(DbSetOrder(4))
    If !lRet .AND. !empty(cUf) .and. BB0->( MsSeek( xFilial("BB0") + cUf + cNumCR + cSigCR ) )
        lRet := .t.
        logInf("[" + cTrack + "] profissional encontrado por UF + NUMCR + SIGLA", cFile)
    Endif

    if !lRet
        logInf("[" + cTrack + "] profissional nao encontrado [ BB0_CODIGO: " + allTrim(cCodigo) + " - BB0_CODSIG: " + allTrim(cSigCR) + " - BB0_NUMCR: " + allTrim(cNumCR) + " - BB0_CODSIG: " + allTrim(cUf) + " - BB0_CODOPE: " + cCodOpe + "]", cFile)
    EndIf

Return lRet

function dataApiReference(nApiReference)
    local aDad := {'', '', .f.}

    do case
        case nApiReference == SYNC_AUTHORIZATIONS .or. nApiReference == SYNC_AUTHORIZATIONS + SYNC_CANCELLATIONS
            aDad[1] := 'Authorizations' + iIf(nApiReference == SYNC_AUTHORIZATIONS + SYNC_CANCELLATIONS,' - CANCELAMENTO','')
            aDad[2] := 'v1/authorizations' //atendimento
            aDad[3] := nApiReference == SYNC_AUTHORIZATIONS + SYNC_CANCELLATIONS
        case nApiReference == SYNC_CLINICAL_ATTACHMENTS .or. nApiReference == SYNC_CLINICAL_ATTACHMENTS + SYNC_CANCELLATIONS
            aDad[1] := 'ClinicalAttachments' + iIf(nApiReference == SYNC_CLINICAL_ATTACHMENTS + SYNC_CANCELLATIONS,' - CANCELAMENTO','')
            aDad[2] := 'v1/clinicalAttachments' //AnexosClinicos
            aDad[3] := nApiReference == SYNC_CLINICAL_ATTACHMENTS + SYNC_CANCELLATIONS
        case nApiReference == SYNC_TREATMENT_EXTENSIONS .or. nApiReference == SYNC_TREATMENT_EXTENSIONS + SYNC_CANCELLATIONS
            aDad[1] := 'TreatmentExtensions' + iIf(nApiReference == SYNC_TREATMENT_EXTENSIONS + SYNC_CANCELLATIONS,' - CANCELAMENTO','')
            aDad[2] := 'v1/treatmentExtensions' //Prorrogacao
            aDad[3] := nApiReference == SYNC_TREATMENT_EXTENSIONS + SYNC_CANCELLATIONS
    endCase

return aDad

function chkThRead(cTp, nApiReference, cTrack)
    local xZ      := 0
    local nH      := -1
    local aGlbPut := {}
    local cIdGLB  := PERSISTWORK + cValToChar(nApiReference)
    default cTp := 'REGISTER'

    if cTp != 'MONITOR'
        nH := plsAbreSem("__CHKRHREAD.SMF")
    endIf

    GetGlbVars(cIdGLB, aGlbPut)

    do case
        case cTp == 'REGISTER'

            aadd(aGlbPut, { nApiReference, cTrack })
            PutGlbVars(cIdGLB, aGlbPut)

        case cTp == 'CHECK'

            if ( xZ := aScan(aGlbPut, {|x| x[1] == nApiReference .and. x[2] == cTrack}) ) > 0

                aDel( aGlbPut, xZ )
                aSize( aGlbPut, len(aGlbPut) - 1 )

                PutGlbVars(cIdGLB, aGlbPut)

            endIf

        case cTp == 'MONITOR'

            nX := 1

            while len(aGlbPut) > 0

                coNout('[' + dataApiReference(aGlbPut[nX,1])[1] + '] - Aguardando termino da jobExec - [' + aGlbPut[nX,2] + ']' )

                sleep(__NSLEEP)

                getGlbVars(cIdGLB, aGlbPut)

                nX++
                if nX > len(aGlbPut)
                    nX := iIf(len(aGlbPut) > 0, 1, 0)
                endIf

            endDo

    endCase

    if cTp != 'MONITOR'
        PLSFechaSem(nH, "__CHKRHREAD.SMF")
    endIf

return

function grvB2Z(cTrack, cFile, cCodOpe, cCodRDA, cNumAut, cMatric, dDataPro, cSenha, cSequen,;
        cCodTab, cCodPro, cId, cTipGui, nQtdAut, nSaldo, cDenReg, cFaDent )
    default cDenReg := ''
    default cFaDent := ''

    B2Z->(dbSetOrder(4))
    if ! B2Z->(msSeek(xFilial("B2Z") + cCodOpe + cCodRda + cNumAut + cSequen))

        B2Z->(RecLock("B2Z",.T.))
        B2Z->B2Z_FILIAL := xFilial("B2Z")
        B2Z->B2Z_IDORIG := cId
        B2Z->B2Z_OPEMOV := cCodOpe
        B2Z->B2Z_NUMAUT := cNumAut
        B2Z->B2Z_TIPGUI := cTipGui
        B2Z->B2Z_CODRDA := cCodRda
        B2Z->B2Z_SENHA  := cSenha
        B2Z->B2Z_MATRIC := cMatric
        B2Z->B2Z_DATPRO := dDataPro
        B2Z->B2Z_SEQUEN := cSequen
        B2Z->B2Z_CODPAD := cCodTab
        B2Z->B2Z_CODPRO := cCodPro
        B2Z->B2Z_QTDAUT := nQtdAut
        B2Z->B2Z_SALDO  := nSaldo

        if !empty(cDenReg)
            B2Z->B2Z_DENREG := cDenReg
            B2Z->B2Z_FADENT := cFaDent
        endIf

        B2Z->(MsUnlock())

    else
        logInf("[" + cTrack + "] B2Z - Hist Atend Int HAT/PLS ja existe", cFile)
    endIf

Return
