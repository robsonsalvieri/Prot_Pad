#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcVlInPcG()
    
    Local oSvcVlInPcG := SvcVlInPcG():New()
    oSvcVlInPcG:run()
    FreeObj(oSvcVlInPcG)
    oSvcVlInPcG := nil

return

/*/{Protheus.doc} 
    Chama a validação individual
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobVlInPcG(cEmp, cFil, lJob, cCodOpe)
    Local oSvc := SvcVlInPcG():New()
    Default cEmp := cEmpAnt
    Default cFil := cFilAnt
    Default lJob := .T.
    oSvc:setCodOpe(cCodOpe)
    JobVldInMon(cEmp, cFil, lJob, oSvc)
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico que valida individualmente os pacotes das guias do monitoramento
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlInPcG From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcVlInPcG
    _Super:New()
    self:cFila := "FILA_VLD_PCT_GUI_MON_IND"
    self:cJob := "JobVlInPcG"
    self:cObs := "Valida indiv pacotes das guias do monitoramento"
    self:oFila := CenFilaBd():New(CenCltBKT():New())
    self:oProc := CenVldPcMGui():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcVlInPcG
	self:oProc:setEntity(oObj)
    self:oProc:vldIndiv(self:oFila:oCollection)
Return