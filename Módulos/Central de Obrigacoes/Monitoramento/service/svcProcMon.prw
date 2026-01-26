#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcProcMon()
    
    Local oSvcProcMon := SvcProcMon():New()
    oSvcProcMon:run()
    FreeObj(oSvcProcMon)
    oSvcProcMon := nil

return

/*/{Protheus.doc} 
    Job que processa as guias que chegaram via API
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobProcMon(cEmp, cFil)
    Local oSvcProcMon := nil
	rpcSetType(3)    
	rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    oSvcProcMon := SvcProcMon():New()
    If oSvcProcMon:beforeProc()
        oSvcProcMon:setProcId(ThreadId())
        While !KillApp() .and. oSvcProcMon:keepProc()
            oSvcProcMon:logMsg("W","vai processar: procNextMsg")
            oSvcProcMon:procNextMsg()
        EndDo
    EndIf

    oSvcProcMon:destroy()
    FreeObj(oSvcProcMon)
    oSvcProcMon := nil
    DelClassIntf()
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico que processa as guias que chegaram via API
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcProcMon From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcProcMon
    _Super:New()
    self:cFila := "FILA_PROC_MON"
    self:cJob := "JobProcMon"
    self:cObs := "Servico que processa as guias que chegaram via API"
    self:oFila := CenFilaBd():New(CenCltBRA():New())
    self:oProc := CenPrMoGui():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcProcMon
    self:oProc:cCodOpe := oObj:getValue("operatorRecord")
    self:oProc:cSeqGui := oObj:getValue("formSequential")
    self:oProc:cTipRegist := '1'
    self:oProc:proGuiaAPI(oObj)
Return
