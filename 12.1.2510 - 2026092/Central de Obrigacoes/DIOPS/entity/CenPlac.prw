#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenPlac - Ans Account Plan
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenPlac from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenPlac
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenPlac

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8B_CODOPE */ 
    oJsonControl:setProp(oJson,"accountCode",self:getValue("accountCode")) /* Column B8B_CONTA */ 
    oJsonControl:setProp(oJson,"validityEndDate",self:getValue("validityEndDate")) /* Column B8B_VIGFIN */ 
    oJsonControl:setProp(oJson,"validityStartDate",self:getValue("validityStartDate")) /* Column B8B_VIGINI */ 
    oJsonControl:setProp(oJson,"accountDescription",self:getValue("accountDescription")) /* Column B8B_DESCRI */ 

Return oJson

Method destroy() Class CenPlac
	_Super:destroy()
	DelClassIntF()
return