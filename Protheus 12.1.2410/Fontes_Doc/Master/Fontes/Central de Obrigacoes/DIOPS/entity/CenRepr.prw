#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenRepr - Representatives
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenRepr from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenRepr
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenRepr

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"registrationOfIndividua",self:getValue("registrationOfIndividua")) /* Column B8N_CPFREP */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8N_CODOPE */ 
    oJsonControl:setProp(oJson,"addressComplement",self:getValue("addressComplement")) /* Column B8N_COMPEN */ 
    oJsonControl:setProp(oJson,"district",self:getValue("district")) /* Column B8N_BAIRRO */ 
    oJsonControl:setProp(oJson,"representativeSPosition",self:getValue("representativeSPosition")) /* Column B8N_CARGO */ 
    oJsonControl:setProp(oJson,"ibgeCityCode",self:getValue("ibgeCityCode")) /* Column B8N_CDIBGE */ 
    oJsonControl:setProp(oJson,"postAddrCode",self:getValue("postAddrCode")) /* Column B8N_CODCEP */ 
    oJsonControl:setProp(oJson,"nationalCallingCd",self:getValue("nationalCallingCd")) /* Column B8N_CODDDD */ 
    oJsonControl:setProp(oJson,"internationalCallinfCd",self:getValue("internationalCallinfCd")) /* Column B8N_CODDDI */ 
    oJsonControl:setProp(oJson,"idIssueDate",self:getValue("idIssueDate")) /* Column B8N_DTEXRG */ 
    oJsonControl:setProp(oJson,"addressName",self:getValue("addressName")) /* Column B8N_NMLOGR */ 
    oJsonControl:setProp(oJson,"representativeSName",self:getValue("representativeSName")) /* Column B8N_NOMEDE */ 
    oJsonControl:setProp(oJson,"idNumber",self:getValue("idNumber")) /* Column B8N_NUMERG */ 
    oJsonControl:setProp(oJson,"addressNumber",self:getValue("addressNumber")) /* Column B8N_NUMLOG */ 
    oJsonControl:setProp(oJson,"idIssuingBody",self:getValue("idIssuingBody")) /* Column B8N_ORGEXP */ 
    oJsonControl:setProp(oJson,"country",self:getValue("country")) /* Column B8N_PAIS */ 
    oJsonControl:setProp(oJson,"extension",self:getValue("extension")) /* Column B8N_RAMAL */ 
    oJsonControl:setProp(oJson,"stateAcronym",self:getValue("stateAcronym")) /* Column B8N_SIGLUF */ 
    oJsonControl:setProp(oJson,"telephoneNumber",self:getValue("telephoneNumber")) /* Column B8N_TELEFO */ 

Return oJson

Method destroy() Class CenRepr
	_Super:destroy()
	DelClassIntF()
return