#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcVlInItG()
    
    Local oSvcVlInItG := SvcVlInItG():New()
    oSvcVlInItG:run()
    FreeObj(oSvcVlInItG)
    oSvcVlInItG := nil

return

/*/{Protheus.doc} 
    Chama a validação individual
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobVlInItG(cEmp, cFil, lJob, cCodOpe)
    Local oSvc := SvcVlInItG():New()
    Default cEmp := cEmpAnt
    Default cFil := cFilAnt
    Default lJob := .T.
    oSvc:setCodOpe(cCodOpe)
    JobVldInMon(cEmp, cFil, lJob, oSvc)
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico que valida individualmente os itens das guias do monitoramento
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlInItG From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcVlInItG
    _Super:New()
    self:cFila := "FILA_VLD_ITEM_GUI_MON_IND"
    self:cJob := "JobVlInItG"
    self:cObs := "Valida indiv itens das guias do monitoramento"
    self:oFila := CenFilaBd():New(CenCltBKS():New())
    self:oProc := CenVldItMGui():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcVlInItG
	self:oProc:setEntity(oObj)
    self:oProc:vldIndiv(self:oFila:oCollection)
Return