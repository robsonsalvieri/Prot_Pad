#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenCrit - Obligation Central Critics
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenCrit from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenCrit
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenCrit

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B3F_CDCOMP */ 
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column B3F_CDOBRI */ 
    oJsonControl:setProp(oJson,"originRegAcknowlegm",self:getValue("originRegAcknowlegm")) /* Column B3F_CHVORI */ 
    oJsonControl:setProp(oJson,"reviewCode",self:getValue("reviewCode")) /* Column B3F_CODCRI */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column B3F_CODOPE */ 
    oJsonControl:setProp(oJson,"originDescription",self:getValue("originDescription")) /* Column B3F_DESORI */ 
    oJsonControl:setProp(oJson,"originIdentKey",self:getValue("originIdentKey")) /* Column B3F_IDEORI */ 
    oJsonControl:setProp(oJson,"reviewOrigin",self:getValue("reviewOrigin")) /* Column B3F_ORICRI */ 
    oJsonControl:setProp(oJson,"commitReferenceYear",self:getValue("commitReferenceYear")) /* Column B3F_ANO */ 
    oJsonControl:setProp(oJson,"type",self:getValue("type")) /* Column B3F_TIPO */ 
    oJsonControl:setProp(oJson,"affectedFields",self:getValue("affectedFields")) /* Column B3F_CAMPOS */ 
    oJsonControl:setProp(oJson,"suggestOfRevSolution",self:getValue("suggestOfRevSolution")) /* Column B3F_SOLUCA */ 
    oJsonControl:setProp(oJson,"reviewStatus",self:getValue("reviewStatus")) /* Column B3F_STATUS */ 
    oJsonControl:setProp(oJson,"ansCritCode",self:getValue("ansCritCode")) /* Column B3F_CRIANS */ 
    oJsonControl:setProp(oJson,"reviewDescription",self:getValue("reviewDescription")) /* Column B3F_DESCRI */ 

Return oJson

Method destroy() Class CenCrit
	_Super:destroy()
	DelClassIntF()
return