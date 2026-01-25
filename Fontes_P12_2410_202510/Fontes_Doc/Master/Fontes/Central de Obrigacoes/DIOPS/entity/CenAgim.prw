#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenAgim - Real Est Gar Asset
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenAgim from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenAgim
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenAgim

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8C_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8C_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8C_CODOPE */ 
    oJsonControl:setProp(oJson,"realEstateGeneralRegis",self:getValue("realEstateGeneralRegis")) /* Column B8C_CODRGI */ 
    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8C_ANOCMP */ 
    oJsonControl:setProp(oJson,"assitance",self:getValue("assitance")) /* Column B8C_ASSIST */ 
    oJsonControl:setProp(oJson,"ownNetwork",self:getValue("ownNetwork")) /* Column B8C_REDPRO */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B8C_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B8C_STATUS */ 
    oJsonControl:setProp(oJson,"validityEndDate",self:getValue("validityEndDate")) /* Column B8C_VIGFIN */ 
    oJsonControl:setProp(oJson,"validityStartDate",self:getValue("validityStartDate")) /* Column B8C_VIGINI */ 
    oJsonControl:setProp(oJson,"accountingValue",self:getValue("accountingValue")) /* Column B8C_VLRCON */ 

Return oJson

Method destroy() Class CenAgim
	_Super:destroy()
	DelClassIntF()
return