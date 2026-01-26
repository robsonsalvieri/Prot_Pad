#INCLUDE "TOTVS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PJobPlsHat

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
main Function PJobPlsHat()

    Local oPEHatServ := nil
    Local cEnv  := GetEnvServer() 
    Local cEmp  := AllTrim(GETPVPROFSTRING(cEnv,"EMPROBOXML","",GetADV97()))
    Local cFil  := AllTrim(GETPVPROFSTRING(cEnv,"FILROBOXML","",GetADV97()))

    rpcSetType(3)
    rpcSetEnv(cEmp,cFil,,,cEnv,,)

    oPEHatServ := PEHatServ():New()
    If oPEHatServ:beforeProc()
        oPEHatServ:setProcId(ThreadId())
        While !KillApp()
            oPEHatServ:procNextMsg()
            sleep(500)
        EndDo        
    EndIf

    FreeObj(oPEHatServ)
    oPEHatServ := nil
    DelClassIntf()

Return