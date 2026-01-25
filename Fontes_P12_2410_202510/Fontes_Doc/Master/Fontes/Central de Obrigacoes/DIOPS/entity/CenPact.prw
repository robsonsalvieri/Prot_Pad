#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenPact - Liability Tax Accnt
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenPact from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenPact
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenPact

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BUY_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column BUY_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column BUY_CODOPE */ 
    oJsonControl:setProp(oJson,"accountCode",self:getValue("accountCode")) /* Column BUY_CONTA */ 
    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column BUY_ANOCMP */ 
    oJsonControl:setProp(oJson,"monetaryUpdate",self:getValue("monetaryUpdate")) /* Column BUY_ATUMON */ 
    oJsonControl:setProp(oJson,"competenceDate",self:getValue("competenceDate")) /* Column BUY_DTCOMP */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column BUY_REFERE */ 
    oJsonControl:setProp(oJson,"balanceAtTheEndOfThe",self:getValue("balanceAtTheEndOfThe")) /* Column BUY_SLDFIN */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BUY_STATUS */ 
    oJsonControl:setProp(oJson,"initialValue",self:getValue("initialValue")) /* Column BUY_VLRINI */ 
    oJsonControl:setProp(oJson,"valuePaid",self:getValue("valuePaid")) /* Column BUY_VLRPAG */ 

Return oJson

Method destroy() Class CenPact
	_Super:destroy()
	DelClassIntF()
return