#INCLUDE "TOTVS.CH"
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"

/*/{Protheus.doc} 
    Job que roda a validação individual para as tabelas do monitoramento
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobVldInMon(cEmp, cFil, lJob, oSvc)
    Default lJob := .T.
    If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer())
    EndIf
    If oSvc:beforeProc()
        oSvc:setProcId(ThreadId())
        While oSvc:keepProc()
            oSvc:logMsg("W","vai processar "+GetClassName(oSvc)+" : procNextMsg",JOB_PROCES)
            oSvc:procNextMsg()
        EndDo
    EndIf
    oSvc:logMsg("W","Finalizou o serviço "+GetClassName(oSvc)+" ",JOB_CONCLU)
//  oSvc:destroy()
//  FreeObj(oSvc)
//  oSvc := nil
    DelClassIntf()
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}