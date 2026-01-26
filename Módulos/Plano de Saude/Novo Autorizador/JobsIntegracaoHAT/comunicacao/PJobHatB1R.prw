#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PJobHatXML
    @type  Class
    @author victor.silva
    @since 20210805
/*/
main function PJobHatXML()
    local service := nil
    local environment := GetEnvServer() 
    local company := allTrim(GETPVPROFSTRING(environment,"EMPROBOXML","",GetADV97()))
    local branch := allTrim(GETPVPROFSTRING(environment,"FILROBOXML","",GetADV97()))

    rpcSetType(3)    
    rpcSetEnv(company, branch,,, environment,,)

    service := PHatXMLServ():New()
    if service:beforeProc()
        service:setProcId(ThreadId())
        while !KillApp()
            service:procNextMsg()
        enddo
    endif

    freeObj(service)
    service := nil
    delClassIntf()

return
