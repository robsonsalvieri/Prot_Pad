#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenAgcn - Contract Consolidation
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenAgcn from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenAgcn
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenAgcn

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8K_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8K_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8K_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8K_CODOPE */ 
    oJsonControl:setProp(oJson,"riskPool",self:getValue("riskPool")) /* Column B8K_TIPO */ 
    oJsonControl:setProp(oJson,"pceCorresponGranted",self:getValue("pceCorresponGranted")) /* Column B8K_PCECC */ 
    oJsonControl:setProp(oJson,"pceIssuedCounterprov",self:getValue("pceIssuedCounterprov")) /* Column B8K_PCECE */ 
    oJsonControl:setProp(oJson,"eveClaimsKnownPce",self:getValue("eveClaimsKnownPce")) /* Column B8K_PCEEV */ 
    oJsonControl:setProp(oJson,"plaCorresponGranted",self:getValue("plaCorresponGranted")) /* Column B8K_PLACC */ 
    oJsonControl:setProp(oJson,"issuedConsiderationsPla",self:getValue("issuedConsiderationsPla")) /* Column B8K_PLACE */ 
    oJsonControl:setProp(oJson,"plaKnowlLossEvents",self:getValue("plaKnowlLossEvents")) /* Column B8K_PLAEV */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B8K_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B8K_STATUS */ 

Return oJson

Method destroy() Class CenAgcn
	_Super:destroy()
	DelClassIntF()
return