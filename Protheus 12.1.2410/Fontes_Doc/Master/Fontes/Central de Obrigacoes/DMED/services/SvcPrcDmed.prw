#INCLUDE "TOTVS.CH"

#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"

/*/{Protheus.doc}
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author jose.paulo
    @since 06/10/2020
/*/
Main Function SvcPrcDmed()

Local oSvcPrcDmed := SvcPrcDmed():New()
oSvcPrcDmed:run()
FreeObj(oSvcPrcDmed)
oSvcPrcDmed := nil

return

/*/{Protheus.doc}
    Job que processa as despesas que chegaram via API

    @type  Function
    @author jose.paulo
    @since 06/10/2020
/*/
Function JobPrcDmed(cEmp, cFil)
    Local oSvcPrcDmed := nil
    rpcSetType(3)
    rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    oSvcPrcDmed := SvcPrcDmed():New()
    If oSvcPrcDmed:beforeProc("4")
        oSvcPrcDmed:setProcId(ThreadId())
        While !KillApp() .and. oSvcPrcDmed:keepProc()
            oSvcPrcDmed:logMsg("W","vai processar " + GetClassName(oSvcPrcDmed),JOB_PROCES,.t.)
            oSvcPrcDmed:procNextMsg()
        EndDo
    EndIf
    oSvcPrcDmed:logMsg("W","processou " + GetClassName(oSvcPrcDmed),JOB_CONCLU,.t.)
    oSvcPrcDmed:destroy()
    FreeObj(oSvcPrcDmed)
    oSvcPrcDmed := nil
    DelClassIntf()
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc}
    Servico que processa despesas que chegaram via API
    @type  Class
    @author jose.paulo
    @since 06/10/2020
/*/
Class SvcPrcDmed From Service

    Method New()
    Method runProc(oObj)

EndClass

Method New() Class SvcPrcDmed
    _Super:New()
    self:cFila := "FILA_PROC_MON"
    self:cJob := "JobPrcDmed"
    self:cObs := "Servico que processa despesas que chegaram via API"
    self:oFila := CenFilaBd():New(CenCltB2Y():New())
    self:oProc := CenPrDmed():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcPrcDmed
    self:oProc:cCodOpe := oObj:getValue("healthInsurerCode")
    self:oProc:cTipRegist := '1'
    self:oProc:proGuiaAPI(oObj)
Return
