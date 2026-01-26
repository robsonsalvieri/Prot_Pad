#include "TOTVS.CH"
#include "autSysLog.CH"

/*/{Protheus.doc} 
    Classe abstrata que define quais os metodos obrigatorios do log
    @type  Class
    @author victor.silva
    @since 20181114
/*/
Class Logger

    Data nLevel
    Data hLevels
    Data hFacilities
    Data cHostName
    Data cServerAddress
    Data cProcName
    Data oLogAdapter
    Data nSource
    Data cMsg
    Data cTenantId

    Method New()
    Method active()
    Method level(nLevel)
    Method facility(nFacility)
    Method initLevelString()
    Method initFacilityString()
    Method getLevel()
    Method setLevel(nLevel)
    Method setPath(cPath)
    Method setSource(nSource)
    Method setType(nFormat)
    Method setup()
    Method logMessage(nLevel, cMsg)
    Method pushToFile(cMsg)
    Method openFile()
    Method pushToEndpoint(cMsg)

EndClass

Method New(cTenantId) Class Logger
    default cTenantId := "1"
    self:cTenantId := "tenantId=" + cTenantId
Return self

Method active() Class Logger
Return .T.

Method level(nLevel) Class Logger
Return self:hLevels:get(nLevel)

Method facility(nFacility) Class Logger
Return self:hFacilities:get(nFacility)

Method initLevelString() Class Logger
    if empty(self:hLevels)
        self:hLevels := HashMap():New()

        self:hLevels:set(CRITICAL,"crit")
        self:hLevels:set(ERROR,"err")
        self:hLevels:set(WARNING,"warning")
        self:hLevels:set(INFORMATIONAL,"info")
        self:hLevels:set(DEBUG,"debug")
    endif

Return

Method initFacilityString() Class Logger
    if empty(self:hFacilities)
        self:hFacilities := HashMap():New()

        self:hFacilities:set(KERNEL, "kern")
        self:hFacilities:set(USER_LEVEL, "user")
        self:hFacilities:set(MAIL_SYSTEM, "mail")
        self:hFacilities:set(SYSTEM_DAEMON, "daemon")
        self:hFacilities:set(AUTH_SECURITY, "auth")
        self:hFacilities:set(SYSLOG, "syslog")
        self:hFacilities:set(LINE_PRINTER_SUBSYSTEM, "lpr")
        self:hFacilities:set(NETWORK_NEWS_SUBSYSTEM, "news")
        self:hFacilities:set(UUCP_SUBSYSTEM, "uucp")
        self:hFacilities:set(CLOCK_DAEMON, "cron")
        self:hFacilities:set(AUTHPRIV_SECURITY, "authpriv")
        self:hFacilities:set(FTP_DAEMON, "ftp")
        self:hFacilities:set(NTP_SUBSYSTEM, "12")
        self:hFacilities:set(LOG_AUDIT, "13")
        self:hFacilities:set(LOG_ALERT, "14")
        self:hFacilities:set(CRON, "15")
        self:hFacilities:set(RESTAPI, "restapi")
        self:hFacilities:set(POOLING, "pooling")
        self:hFacilities:set(REDISSRV, "redissrv")
        self:hFacilities:set(COVERAGE, "coverage")
        self:hFacilities:set(INTEGRATION, "integration")
        self:hFacilities:set(BILLING, "bill")
        self:hFacilities:set(LOCAL6, "local6")
        self:hFacilities:set(LOCAL7, "local7")
        self:hFacilities:set(SGBD_INTERFACE, "sgbd")
    endif

Return

Method getLevel() Class Logger
Return self:nLevel

Method setLevel(nLevel) Class Logger
    self:nLevel := nLevel
Return

Method setPath(cPath) Class Logger
    if empty(cPath)
        self:setSource(CONSOLE)
    else
        self:setSource(FILE)
        self:cPath := cPath
    endif
Return

Method setSource(nSource) Class Logger
    self:nSource := nSource
Return

Method setType(nFormat) Class Logger
    do case
        case nFormat == TYPE_SYSLOG
            self:oLogAdapter := SysLogAdapter():New()
    endcase
Return

Method setup() Class Logger
    self:cHostName := computerName()
    self:cServerAddress := getServerIP()
Return

Method logMessage(cMsg, cMsgId, nLevel, nFacility) Class Logger
    Local lSuccess := self:nLevel >= nLevel

    default nLevel := 3
    default nFacility := 5

    if lSuccess
        self:initLevelString()
        self:initFacilityString()
        self:oLogAdapter:formatMessage(self, cMsg, cMsgId, nLevel, nFacility)

        do case
            case self:nSource == CONSOLE
                ConOut(self:cMsg)
            case self:nSource == FILE
                lSuccess := self:pushToFile()
            case self:nSource == API
                lSuccess := self:pushToEndpoint()
        endcase
    endif

Return lSuccess

Method pushToFile(cMsg) Class Logger
    Local lSuccess := self:openFile()
    
    if lSuccess
        fSeek(self:nFileHandle,0,2)
        fWrite(self:nFileHandle, self:cMsg + chr(13) + chr(10))
        fClose(self:nFileHandle)
    endif

Return lSuccess

Method openFile() Class Logger
    Local cArqLog := ""
    Local lSuccess := .F.

    If !ExistDir(self:cPath)
        If MakeDir(self:cPath) <> 0
            lSuccess := .T.
            cArqLog := self:cPath + LOG_DEFAULT_HAT + ".log"

            if !File(cArqLog)     
                self:nFileHandle := fCreate(cArqlog,0)
            else
                self:nFileHandle := fOpen(cArqlog,2)
            endIf
        EndIf
    else
        lSuccess := .T.
    endIf

Return lSuccess

Method pushToEndpoint(cMsg) Class Logger
    /*
    Metodo todo comentado pois a funcao getCfgSvr foi removida (Debitos Tecnicos). 
    Este metodo nao e mais utilizado, futuramente e necessario analisar todas as chamadas e realizar a remocao das chamadas 
    (antigo Job do PLS que baixava as guias do HAT)

    Local oRestClient := nil
    Local aHeader := {}
    Local cEndPoint := ""
    Local cPath := ""
    Local lEnabled := .F.
    Local oCfgSvr := getCfgSvr()

    oCfgSvr:setIniSection("hatSysLog")
    lEnabled := oCfgSvr:getConfig("enable",'') == "1"

    if lEnabled
        cEndPoint := oCfgSvr:getConfig("logEndpoint",'')
        cPath := oCfgSvr:getConfig("logPath",'')

        oRestClient := FWRest():New(cEndPoint)
        oRestClient:setPath(cPath)
        oRestClient:setPostParams(cMsg)

        aAdd(aHeader,'Content-Type: text/plain') 
        oRestClient:Post(aHeader)
    endif
    */
Return
//
