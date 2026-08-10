#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB7Z - Tuss Events
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB7Z from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB7Z
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB7Z

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"procedureCode",self:getValue("procedureCode")) /* Column B7Z_CODPRO */ 
    oJsonControl:setProp(oJson,"tableCode",self:getValue("tableCode")) /* Column B7Z_CODTAB */ 
    oJsonControl:setProp(oJson,"submissionMethod",self:getValue("submissionMethod")) /* Column B7Z_FORENV */ 
    oJsonControl:setProp(oJson,"eventType",self:getValue("eventType")) /* Column B7Z_TIPEVE */ 
    oJsonControl:setProp(oJson,"procedureGroup",self:getValue("procedureGroup")) /* Column B7Z_CODGRU */ 

Return oJson

Method destroy() Class CenB7Z
	_Super:destroy()
	DelClassIntF()
return