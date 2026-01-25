#INCLUDE "TOTVS.CH"

/*/{Protheus.doc}
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author david.juan
    @since 20201210
/*/
Main Function SvcRzTiss()

Local oSvcRzTiss := SvcRzTiss():New()
oSvcRzTiss:run()
FreeObj(oSvcRzTiss)
oSvcRzTiss := nil

return

/*/{Protheus.doc}
    Chama a validação individual

    @type  Function
    @author david.juan
    @since 20201210
/*/
Function JobRzTiss(cEmp, cFil, lJob, cCodOpe)
    Local oSvc := SvcRzTiss():New()
    Default cEmp := cEmpAnt
    Default cFil := cFilAnt
    Default lJob := .T.
    Default cCodOpe := ""

    If lJob
        rpcSetType(3)
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf

    oSvc:setCodOpe(cCodOpe)
    oSvc:runProc()
    oSvc:destroy()
    FreeObj(oSvc)
    oSvc := nil

    DelClassIntf()
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc}
    Servico que valida as guias de outras remunerações
    @type  Class
    @author david.juan
    @since 20201210
/*/
Class SvcRzTiss From Service

    Method New()
    Method runProc(oObj)

EndClass

Method New() Class SvcRzTiss
    _Super:New()
    self:cFila := "FILA_IND_IDSS_RAZAO_TISS"
    self:cJob := "JobRzTiss"
    self:cObs := "Monta o Indicador IDSS - Razao TISS"
    self:oFila := CenFilaBd():New(CenCltBI0():New())
    self:oProc := CenCmdRzT():New(self:oFila:oCollection)
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcRzTiss
    self:oProc:setOper(self:cCodOpe)
    self:oProc:setAno()
    self:oProc:execute()
    self:oProc:destroy()
Return