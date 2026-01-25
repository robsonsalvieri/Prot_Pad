#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenLcpr - Profits And Losses
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenLcpr from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenLcpr
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenLcpr

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8E_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8E_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8E_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8E_CODOPE */ 
    oJsonControl:setProp(oJson,"accountCode",self:getValue("accountCode")) /* Column B8E_CONTA */ 
    oJsonControl:setProp(oJson,"description",self:getValue("description")) /* Column B8E_DESCRI */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B8E_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B8E_STATUS */ 
    oJsonControl:setProp(oJson,"accountingValue",self:getValue("accountingValue")) /* Column B8E_VLRCON */ 

Return oJson

Method destroy() Class CenLcpr
	_Super:destroy()
	DelClassIntF()
return