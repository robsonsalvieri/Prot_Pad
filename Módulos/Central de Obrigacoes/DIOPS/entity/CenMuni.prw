#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenMuni - List Of Cities
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenMuni from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenMuni
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenMuni

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"ibgeCityCode",self:getValue("ibgeCityCode")) /* Column B8W_CDIBGE */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8W_CODOPE */ 
    oJsonControl:setProp(oJson,"stateAcronym",self:getValue("stateAcronym")) /* Column B8W_SIGLUF */ 

Return oJson

Method destroy() Class CenMuni
	_Super:destroy()
	DelClassIntF()
return