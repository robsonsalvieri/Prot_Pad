#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenCrcd - CoResponsibility Granted
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenCrcd from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenCrcd
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenCrcd

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B36_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B36_CDCOMP */ 
    oJsonControl:setProp(oJson,"ansEventCode",self:getValue("ansEventCode")) /* Column B36_CODIGO */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B36_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B36_CODOPE */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B36_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B36_STATUS */ 
    oJsonControl:setProp(oJson,"amt1StMthTrimester",self:getValue("amt1StMthTrimester")) /* Column B36_VLMES1 */ 
    oJsonControl:setProp(oJson,"amt2NdMthTrimester",self:getValue("amt2NdMthTrimester")) /* Column B36_VLMES2 */ 
    oJsonControl:setProp(oJson,"amt3RdMthTrimester",self:getValue("amt3RdMthTrimester")) /* Column B36_VLMES3 */ 

Return oJson

Method destroy() Class CenCrcd
	_Super:destroy()
	DelClassIntF()
return