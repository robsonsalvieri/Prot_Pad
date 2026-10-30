#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenFlcx - Cash Flow
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenFlcx from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenFlcx
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenFlcx

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8H_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8H_CDCOMP */ 
    oJsonControl:setProp(oJson,"cashFlowCode",self:getValue("cashFlowCode")) /* Column B8H_CODIGO */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8H_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8H_CODOPE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B8H_STATUS */ 
    oJsonControl:setProp(oJson,"value",self:getValue("value")) /* Column B8H_VLRCON */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B8H_REFERE */ 

Return oJson

Method destroy() Class CenFlcx
	_Super:destroy()
	DelClassIntF()
return