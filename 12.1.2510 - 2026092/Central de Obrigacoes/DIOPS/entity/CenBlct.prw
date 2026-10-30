#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBlct - Trimester Balance Sheet
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBlct from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBlct
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBlct

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8A_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8A_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8A_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8A_CODOPE */ 
    oJsonControl:setProp(oJson,"accountCode",self:getValue("accountCode")) /* Column B8A_CONTA */ 
    oJsonControl:setProp(oJson,"credits",self:getValue("credits")) /* Column B8A_CREDIT */ 
    oJsonControl:setProp(oJson,"debits",self:getValue("debits")) /* Column B8A_DEBITO */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B8A_REFERE */ 
    oJsonControl:setProp(oJson,"previousBalance",self:getValue("previousBalance")) /* Column B8A_SALANT */ 
    oJsonControl:setProp(oJson,"finalBalance",self:getValue("finalBalance")) /* Column B8A_SALFIN */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B8A_STATUS */ 

Return oJson

Method destroy() Class CenBlct
	_Super:destroy()
	DelClassIntF()
return