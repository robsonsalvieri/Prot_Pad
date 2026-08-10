#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBrh - Process Packages Api Monitor
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBrh from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBrh
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBrh

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"itemProCode",self:getValue("itemProCode")) /* Column BRH_CDPRIT */ 
    oJsonControl:setProp(oJson,"itemTableCode",self:getValue("itemTableCode")) /* Column BRH_CDTBIT */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BRH_CODOPE */ 
    oJsonControl:setProp(oJson,"procedureCode",self:getValue("procedureCode")) /* Column BRH_CODPRO */ 
    oJsonControl:setProp(oJson,"tableCode",self:getValue("tableCode")) /* Column BRH_CODTAB */ 
    oJsonControl:setProp(oJson,"operatorFormNumber",self:getValue("operatorFormNumber")) /* Column BRH_NMGOPE */ 
    oJsonControl:setProp(oJson,"packageQuantity",self:getValue("packageQuantity")) /* Column BRH_QTPRPC */ 

Return oJson

Method destroy() Class CenBrh
	_Super:destroy()
	DelClassIntF()
return