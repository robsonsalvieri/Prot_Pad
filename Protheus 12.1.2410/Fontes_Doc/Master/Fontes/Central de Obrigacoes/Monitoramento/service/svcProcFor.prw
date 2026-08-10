#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcProcFor()
    
    Local oSvcProcFor := SvcProcFor():New()
    oSvcProcFor:run()
    FreeObj(oSvcProcFor)
    oSvcProcFor := nil

return

/*/{Protheus.doc} 
    Job que processa as guias de fornecimento direto que chegaram via API
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobProcFor(cEmp, cFil)
    Local oSvcProcFor := nil
	rpcSetType(3)    
	rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    oSvcProcFor := SvcProcFor():New()
    If oSvcProcFor:beforeProc()
        oSvcProcFor:setProcId(ThreadId())
        While !KillApp() .and. oSvcProcFor:keepProc()
            oSvcProcFor:logMsg("W","vai processar: procNextMsg")
            oSvcProcFor:procNextMsg()
        EndDo
    EndIf

    oSvcProcFor:destroy()
    FreeObj(oSvcProcFor)
    oSvcProcFor := nil
    DelClassIntf()
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico que processa as guias de fornecimento direto que chegaram via API
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcProcFor From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcProcFor
    _Super:New()
    self:cFila  := "FILA_PROC_FOR"
    self:cJob   := "JobProcFor"
    self:cObs   := "Processa guias fornecimento direto da API"
    self:oFila  := CenFilaBd():New(CenCltBW8():New())
    self:oProc  := CenPrMoFor():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcProcFor
    self:oProc:cCodOpe := oObj:getValue("operatorRecord")
    self:oProc:cSeqGui := oObj:getValue("formSequential")
    self:oProc:proGuiaAPI(oObj)
Return