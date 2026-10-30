#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenFuco - Common Funds
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenFuco from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenFuco
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenFuco

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B6R_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B6R_CDCOMP */ 
    oJsonControl:setProp(oJson,"cnpjOrFundAnsRec",self:getValue("cnpjOrFundAnsRec")) /* Column B6R_CNPJ */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B6R_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B6R_CODOPE */ 
    oJsonControl:setProp(oJson,"fundType",self:getValue("fundType")) /* Column B6R_TIPO */ 
    oJsonControl:setProp(oJson,"fundName",self:getValue("fundName")) /* Column B6R_NOME */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B6R_REFERE */ 
    oJsonControl:setProp(oJson,"creditBalanceOfFund",self:getValue("creditBalanceOfFund")) /* Column B6R_SLDCRD */ 
    oJsonControl:setProp(oJson,"debitorBalanceOfFund",self:getValue("debitorBalanceOfFund")) /* Column B6R_SLDDEB */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B6R_STATUS */ 

Return oJson

Method destroy() Class CenFuco
	_Super:destroy()
	DelClassIntF()
return