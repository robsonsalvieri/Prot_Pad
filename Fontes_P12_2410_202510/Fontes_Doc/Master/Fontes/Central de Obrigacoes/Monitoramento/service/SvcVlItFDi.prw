#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcVlItFDi()
    
    Local oSvcVlItFDi := SvcVlItFDi():New()
    oSvcVlItFDi:run()
    FreeObj(oSvcVlItFDi)
    oSvcVlItFDi := nil

return

/*/{Protheus.doc} 
    Chama a validação individual
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobVlItFDi(cEmp, cFil, lJob, cCodOpe)
    Local oSvc := SvcVlItFDi():New()
    Default cEmp := cEmpAnt
    Default cFil := cFilAnt
    Default lJob := .T.
    oSvc:setCodOpe(cCodOpe)
    JobVldInMon(cEmp, cFil, lJob, oSvc)
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico que valida individualmente os itens das guias de fornecimento direto
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlItFDi From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcVlItFDi
    _Super:New()
    self:cFila := "FILA_VLD_ITEM_FOR_DIR_IND"
    self:cJob := "JobVlItFDi"
    self:cObs := "Valida indiv os itens guias fornecimento direto"
    self:oFila := CenFilaBd():New(CenCltBVT():New())
    self:oProc := CenVldItFDir():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcVlItFDi
	self:oProc:setEntity(oObj)
    self:oProc:vldIndiv(self:oFila:oCollection)
Return