#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PLSBqd - Versions Of Subcontracts
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSBqd from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PLSBqd
	_Super:New()
Return self

Method serialize(oJsonControl) Class PLSBqd

	Local oJson := JsonObject():New()
	Default oJsonControl := PLSJsonControl():New()


    oJsonControl:setProp(oJson,"code",self:getValue("code")) /* Column BQD_CODIGO */ 
    oJsonControl:setProp(oJson,"groupCompanyGroup",self:getValue("groupCompanyGroup")) /* Column BQD_NUMCON */ 
    oJsonControl:setProp(oJson,"version",self:getValue("version")) /* Column BQD_VERCON */ 
    oJsonControl:setProp(oJson,"subContract",self:getValue("subContract")) /* Column BQD_SUBCON */ 
    oJsonControl:setProp(oJson,"subContractVersion",self:getValue("subContractVersion")) /* Column BQD_VERSUB */ 
    oJsonControl:setProp(oJson,"versionInitialDate",self:getValue("versionInitialDate")) /* Column BQD_DATINI */ 
    oJsonControl:setProp(oJson,"versionFinalDate",self:getValue("versionFinalDate")) /* Column BQD_DATFIN */ 

Return oJson

Method destroy() Class PLSBqd
	_Super:destroy()
	DelClassIntF()
return