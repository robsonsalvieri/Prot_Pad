#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenPect - Pecuniary Consideration
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenPect from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenPect
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenPect

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B37_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B37_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B37_CODOPE */ 
    oJsonControl:setProp(oJson,"counterpartCoveragePeri",self:getValue("counterpartCoveragePeri")) /* Column B37_PERCOB */ 
    oJsonControl:setProp(oJson,"planType",self:getValue("planType")) /* Column B37_PLANO */ 
    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B37_ANOCMP */ 
    oJsonControl:setProp(oJson,"valueToExpire",self:getValue("valueToExpire")) /* Column B37_AVENCE */ 
    oJsonControl:setProp(oJson,"receivedValue",self:getValue("receivedValue")) /* Column B37_RECEBI */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B37_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B37_STATUS */ 
    oJsonControl:setProp(oJson,"dueValueInArrears",self:getValue("dueValueInArrears")) /* Column B37_VENCID */ 
    oJsonControl:setProp(oJson,"netIssuedValue",self:getValue("netIssuedValue")) /* Column B37_EMITID */ 

Return oJson

Method destroy() Class CenPect
	_Super:destroy()
	DelClassIntF()
return