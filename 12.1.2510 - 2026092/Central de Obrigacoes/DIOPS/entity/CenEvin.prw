#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenEvin - Indemnifiable Events
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenEvin from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenEvin
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenEvin

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8L_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8L_CDCOMP */ 
    oJsonControl:setProp(oJson,"eventCodeAns",self:getValue("eventCodeAns")) /* Column B8L_CODIGO */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8L_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8L_CODOPE */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B8L_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B8L_STATUS */ 
    oJsonControl:setProp(oJson,"quarterMthFirstValue",self:getValue("quarterMthFirstValue")) /* Column B8L_VLMES1 */ 
    oJsonControl:setProp(oJson,"quarterMthSecValue",self:getValue("quarterMthSecValue")) /* Column B8L_VLMES2 */ 
    oJsonControl:setProp(oJson,"quarterMthThirdValue",self:getValue("quarterMthThirdValue")) /* Column B8L_VLMES3 */ 

Return oJson

Method destroy() Class CenEvin
	_Super:destroy()
	DelClassIntF()
return