#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenDepn - Premises
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenDepn from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenDepn
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenDepn

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8Z_CODOPE */ 
    oJsonControl:setProp(oJson,"legalEntityNatRegister",self:getValue("legalEntityNatRegister")) /* Column B8Z_CNPJ */ 
    oJsonControl:setProp(oJson,"postAddrCode",self:getValue("postAddrCode")) /* Column B8Z_CODCEP */ 
    oJsonControl:setProp(oJson,"longDistanceCode",self:getValue("longDistanceCode")) /* Column B8Z_CODDDD */ 
    oJsonControl:setProp(oJson,"internationalCallinfCd",self:getValue("internationalCallinfCd")) /* Column B8Z_CODDDI */ 
    oJsonControl:setProp(oJson,"district",self:getValue("district")) /* Column B8Z_BAIRRO */ 
    oJsonControl:setProp(oJson,"ibgeCityCode",self:getValue("ibgeCityCode")) /* Column B8Z_CDIBGE */ 
    oJsonControl:setProp(oJson,"addressComplement",self:getValue("addressComplement")) /* Column B8Z_COMDEP */ 
    oJsonControl:setProp(oJson,"eMail",self:getValue("eMail")) /* Column B8Z_EMAIL */ 
    oJsonControl:setProp(oJson,"addressName",self:getValue("addressName")) /* Column B8Z_NMLOGR */ 
    oJsonControl:setProp(oJson,"corporateName",self:getValue("corporateName")) /* Column B8Z_NOMRAZ */ 
    oJsonControl:setProp(oJson,"addressNumber",self:getValue("addressNumber")) /* Column B8Z_NUMLOG */ 
    oJsonControl:setProp(oJson,"extensionLine",self:getValue("extensionLine")) /* Column B8Z_RAMAL */ 
    oJsonControl:setProp(oJson,"stateAcronym",self:getValue("stateAcronym")) /* Column B8Z_SIGLUF */ 
    oJsonControl:setProp(oJson,"telephoneNumber",self:getValue("telephoneNumber")) /* Column B8Z_TELEFO */ 
    oJsonControl:setProp(oJson,"dependenceType",self:getValue("dependenceType")) /* Column B8Z_TIPODE */ 

Return oJson

Method destroy() Class CenDepn
	_Super:destroy()
	DelClassIntF()
return