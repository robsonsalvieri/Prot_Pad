#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PLSBil - Versions Of Products
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSBil from CENEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PLSBil
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLSBil

	Local oJson := JsonObject():New()
	Default oJsonControl := PLSJsonControl():New()


    oJsonControl:setProp(oJson,"companyType",self:getValue("BIL_CODIGO")) 
    oJsonControl:setProp(oJson,"version",self:getValue("BIL_VERSAO")) 
    oJsonControl:setProp(oJson,"versionInitialDate",self:getValue("BIL_DATINI")) 
    oJsonControl:setProp(oJson,"versionFinalDate",self:getValue("BIL_DATFIN")) 
    oJsonControl:setProp(oJson,"versionIdentification",self:getValue("BIL_CODANT")) 
    oJsonControl:setProp(oJson,"versionDescript",self:getValue("BIL_DESANT")) 

Return oJson

Method destroy() Class PLSBil
	_Super:destroy()
	DelClassIntF()
return