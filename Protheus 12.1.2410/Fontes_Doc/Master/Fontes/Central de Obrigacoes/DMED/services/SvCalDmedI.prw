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
Function SvVldDmedIn(cEmp, cFil, lJob, oSvc)
    Default lJob := .T.
    If lJob
        rpcSetType(3)
        rpcSetEnv( cEmp, cFil,,,GetEnvServer())
    EndIf
    If oSvc:beforeProc("4")
        oSvc:setProcId(ThreadId())
        While oSvc:keepProc()
            oSvc:logMsg("W","vai processar: procNextMsg",JOB_PROCES,.t.)
            oSvc:procNextMsg()
        EndDo
    EndIf
    oSvc:logMsg("W","Finalizou o serviço",JOB_CONCLU,.t.)
    //    oSvc:destroy()
    //    FreeObj(oSvc)
    //    oSvc := nil
    DelClassIntf()
Return

Function JbCalDmedI(cEmp, cFil, lJob, cCodOpe)
    Local oSvc := SvCalDmedI():New()
    Default cEmp := cEmpAnt
    Default cFil := cFilAnt
    Default lJob := .T.
    oSvc:setCodOpe(cCodOpe)
    SvVldDmedIn(cEmp, cFil, lJob, oSvc)
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc}
    Serviço de validação individual das criticas DMED
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvCalDmedI From Service

    Method New()
    Method runProc(oObj)

EndClass

Method New() Class SvCalDmedI
    _Super:New()
    self:cFila := "FILA_VLD_DEMED_IND"
    self:cJob := "JbCalDmedI"
    self:cObs := "Valida individualmente a tabela B2W DMED"
    self:oFila := CenFilaBd():New(CenCltB2W():New())
    self:oProc := CenVldDB2W():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvCalDmedI
    self:oProc:setEntity(oObj)
    self:oProc:vldIndiv(self:oFila:oCollection)
Return