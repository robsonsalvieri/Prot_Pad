#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB2R - Tiss Terminology Detail
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB2R from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB2R
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB2R

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()


    oJsonControl:setProp(oJson,"tableCode",self:getValue("tableCode")) /* Column B2R_CODTAB */ 
    oJsonControl:setProp(oJson,"termCode",self:getValue("termCode")) /* Column B2R_CDTERM */ 
    oJsonControl:setProp(oJson,"termDescription",self:getValue("termDescription")) /* Column B2R_DESTER */ 
    oJsonControl:setProp(oJson,"validityFrom",self:getValue("validityFrom")) /* Column B2R_VIGDE  */ 
    oJsonControl:setProp(oJson,"validityTo",self:getValue("validityTo")) /* Column B2R_VIGATE */ 
    oJsonControl:setProp(oJson,"deploymentEndDate",self:getValue("deploymentEndDate")) /* Column B2R_DATFIM */ 
    oJsonControl:setProp(oJson,"detailedDescription",self:getValue("detailedDescription")) /* Column B2R_DSCDET */ 
    oJsonControl:setProp(oJson,"tussTerminology",self:getValue("tussTerminology")) /* Column B2R_TABTUS */ 
    oJsonControl:setProp(oJson,"groupCode",self:getValue("groupCode")) /* Column B2R_CODGRU */ 
    oJsonControl:setProp(oJson,"groupDescription",self:getValue("groupDescription")) /* Column B2R_DESGRU */ 
    oJsonControl:setProp(oJson,"hasLinkFromTo",self:getValue("hasLinkFromTo")) /* Column B2R_HASVIN */ 

Return oJson

Method destroy() Class CenB2R
	_Super:destroy()
	DelClassIntF()
return