#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcVlInORe()
    
    Local oSvcVlInORe := SvcVlInORe():New()
    oSvcVlInORe:run()
    FreeObj(oSvcVlInORe)
    oSvcVlInORe := nil

return

/*/{Protheus.doc} 
    Chama a validação individual
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobVlInORe(cEmp, cFil, lJob, cCodOpe)
    Local oSvc := SvcVlInORe():New()
    Default cEmp := cEmpAnt
    Default cFil := cFilAnt
    Default lJob := .T.
    oSvc:setCodOpe(cCodOpe)
    JobVldInMon(cEmp, cFil, lJob, oSvc)
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico que valida as guias de outras remunerações
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlInORe From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcVlInORe
    _Super:New()
    self:cFila := "FILA_VLD_GUI_OUTRAS_REM_IND"
    self:cJob := "JobVlInORe"
    self:cObs := "Valida indiv guias de outras remunerações"
    self:oFila := CenFilaBd():New(CenCltBVZ():New())
    self:oProc := CenVldORem():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcVlInORe
	self:oProc:setEntity(oObj)
    self:oProc:vldIndiv(self:oFila:oCollection)
Return