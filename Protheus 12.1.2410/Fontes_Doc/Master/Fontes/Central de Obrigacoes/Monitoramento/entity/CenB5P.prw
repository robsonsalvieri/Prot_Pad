#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB5P - Quality File Details
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB5P from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB5P
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB5P

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()


    oJsonControl:setProp(oJson,"formFieldIdentifier",self:getValue("formFieldIdentifier")) /* Column B5P_CDCMGU */ 
    oJsonControl:setProp(oJson,"errorCode",self:getValue("errorCode")) /* Column B5P_CDCMER */ 
    oJsonControl:setProp(oJson,"errorDescription",self:getValue("errorDescription")) /* Column B5P_DESERR */ 
    oJsonControl:setProp(oJson,"errorLevel",self:getValue("errorLevel")) /* Column B5P_NIVERR */ 
    oJsonControl:setProp(oJson,"ansRegister",self:getValue("ansRegister")) /* Column B5P_CODOPE */ 
    oJsonControl:setProp(oJson,"batchNumber",self:getValue("batchNumber")) /* Column B5P_NUMLOT */ 
    oJsonControl:setProp(oJson,"operatorFormNumber",self:getValue("operatorFormNumber")) /* Column B5P_NMGOPE */ 
    oJsonControl:setProp(oJson,"providerFormNumber",self:getValue("providerFormNumber")) /* Column B5P_NMGPRE */ 
    oJsonControl:setProp(oJson,"refundIdentifier",self:getValue("refundIdentifier")) /* Column B5P_IDREEM */ 
    oJsonControl:setProp(oJson,"processingDate",self:getValue("processingDate")) /* Column B5P_DATPRO */ 
    oJsonControl:setProp(oJson,"tableCode",self:getValue("tableCode")) /* Column B5P_CODPAD */ 
    oJsonControl:setProp(oJson,"procedureCode",self:getValue("procedureCode")) /* Column B5P_CODPRO */ 
    oJsonControl:setProp(oJson,"toothCode",self:getValue("toothCode")) /* Column B5P_CDDENT */ 
    oJsonControl:setProp(oJson,"toothFaceCode",self:getValue("toothFaceCode")) /* Column B5P_CDFACE */ 
    oJsonControl:setProp(oJson,"regionCode",self:getValue("regionCode")) /* Column B5P_CDREGI */ 
    oJsonControl:setProp(oJson,"procedureGroup",self:getValue("procedureGroup")) /* Column B5P_CODGRU */ 

Return oJson

Method destroy() Class CenB5P
	_Super:destroy()
	DelClassIntF()
return