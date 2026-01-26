#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PLSBj3 - Products And Collections
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSBj3 from CENEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PLSBj3
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLSBj3

	Local oJson := JsonObject():New()
	Default oJsonControl := PLSJsonControl():New()


    oJsonControl:setProp(oJson,"companyType",self:getValue("BJ3_CODIGO")) 
    oJsonControl:setProp(oJson,"version",self:getValue("BJ3_VERSAO")) 
    oJsonControl:setProp(oJson,"collectionMode",self:getValue("BJ3_CODFOR")) 

Return oJson

Method destroy() Class PLSBj3
	_Super:destroy()
	DelClassIntF()
return