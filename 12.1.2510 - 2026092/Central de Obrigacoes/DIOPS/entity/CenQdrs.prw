#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenQdrs - Charts
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenQdrs from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenQdrs
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenQdrs

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8X_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8X_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8X_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8X_CODOPE */ 
    oJsonControl:setProp(oJson,"diopsChart",self:getValue("diopsChart")) /* Column B8X_QUADRO */ 
    oJsonControl:setProp(oJson,"chartReceived",self:getValue("chartReceived")) /* Column B8X_RECEBI */ 
    oJsonControl:setProp(oJson,"validateChart",self:getValue("validateChart")) /* Column B8X_VALIDA */ 

Return oJson

Method destroy() Class CenQdrs
	_Super:destroy()
	DelClassIntF()
return