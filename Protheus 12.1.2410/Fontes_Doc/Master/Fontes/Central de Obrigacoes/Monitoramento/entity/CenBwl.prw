#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBwl - monitDirectSupplyEvents
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBwl from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBwl
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBwl

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BWL_CODOPE */ 
    oJsonControl:setProp(oJson,"formSequential",self:getValue("formSequential")) /* Column BWL_SEQGUI */ 
    oJsonControl:setProp(oJson,"sequence",self:getValue("sequence")) /* Column BWL_SEQITE */ 
    oJsonControl:setProp(oJson,"procedureValuePaid",self:getValue("procedureValuePaid")) /* Column BWL_VLPGPR */ 
    oJsonControl:setProp(oJson,"coPaymentValue",self:getValue("coPaymentValue")) /* Column BWL_VLRCOP */ 
    oJsonControl:setProp(oJson,"procedureCode",self:getValue("procedureCode")) /* Column BWL_CODPRO */ 
    oJsonControl:setProp(oJson,"tableCode",self:getValue("tableCode")) /* Column BWL_CODTAB */ 
    oJsonControl:setProp(oJson,"enteredQuantity",self:getValue("enteredQuantity")) /* Column BWL_QTDINF */ 
    oJsonControl:setProp(oJson,"procedureGroup",self:getValue("procedureGroup")) /* Column BWL_CODGRU */ 

Return oJson

Method destroy() Class CenBwl
	_Super:destroy()
	DelClassIntF()
return