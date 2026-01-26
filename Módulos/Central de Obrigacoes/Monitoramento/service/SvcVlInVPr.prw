#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcVlInVPr()
    
    Local oSvcVlInVPr := SvcVlInVPr():New()
    oSvcVlInVPr:run()
    FreeObj(oSvcVlInVPr)
    oSvcVlInVPr := nil

return

/*/{Protheus.doc} 
    Chama a validação individual
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobVlInVPr(cEmp, cFil, lJob, cCodOpe)
    Local oSvc := SvcVlInVPr():New()
    Default cEmp := cEmpAnt
    Default cFil := cFilAnt
    Default lJob := .T.
    oSvc:setCodOpe(cCodOpe)
    JobVldInMon(cEmp, cFil, lJob, oSvc)
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico que valida individualmente as guias de valor pré-estabelecido
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlInVPr From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcVlInVPr
    _Super:New()
    self:cFila := "FILA_VLD_VLR_PRE_IND"
    self:cJob := "JobVlInVPr"
    self:cObs := "Valida indiv pacotes guias valor pré-estabelecido"
    self:oFila := CenFilaBd():New(CenCltB9T():New())
    self:oProc := CenVldVPre():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcVlInVPr
	self:oProc:setEntity(oObj)
    self:oProc:vldIndiv(self:oFila:oCollection)
Return