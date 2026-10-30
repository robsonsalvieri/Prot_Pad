#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenResp - Persons Responsible
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenResp from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenResp
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenResp

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8Y_CODOPE */ 
    oJsonControl:setProp(oJson,"cpfCnpj",self:getValue("cpfCnpj")) /* Column B8Y_CPFCNP */ 
    oJsonControl:setProp(oJson,"responsibleLeOrIndivid",self:getValue("responsibleLeOrIndivid")) /* Column B8Y_TPPESS */ 
    oJsonControl:setProp(oJson,"responsibilityType",self:getValue("responsibilityType")) /* Column B8Y_TPRESP */ 
    oJsonControl:setProp(oJson,"nameCorporateName",self:getValue("nameCorporateName")) /* Column B8Y_NOMRAZ */ 
    oJsonControl:setProp(oJson,"recordNumber",self:getValue("recordNumber")) /* Column B8Y_NUMREG */ 

Return oJson

Method destroy() Class CenResp
	_Super:destroy()
	DelClassIntF()
return