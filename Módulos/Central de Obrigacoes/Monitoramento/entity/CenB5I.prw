#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB5I - Quality Return Files
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB5I from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB5I
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB5I

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()


    oJsonControl:setProp(oJson,"ansRegister",self:getValue("ansRegister")) /* Column B5I_CODOPE */ 
    oJsonControl:setProp(oJson,"batchPeriod",self:getValue("batchPeriod")) /* Column B5I_CMPLOT */ 
    oJsonControl:setProp(oJson,"batchNumber",self:getValue("batchNumber")) /* Column B5I_NUMLOT */ 
    oJsonControl:setProp(oJson,"transactionType",self:getValue("transactionType")) /* Column B5I_TPTRAN */ 
    oJsonControl:setProp(oJson,"processingDate",self:getValue("processingDate")) /* Column B5I_DATPRO */ 
    oJsonControl:setProp(oJson,"processingTime",self:getValue("processingTime")) /* Column B5I_HORPRO */ 
    oJsonControl:setProp(oJson,"defaultVersion",self:getValue("defaultVersion")) /* Column B5I_VERPAD */ 
    oJsonControl:setProp(oJson,"qualityFile",self:getValue("qualityFile")) /* Column B5I_ARQUIV */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B5I_STATUS */ 

Return oJson

Method destroy() Class CenB5I
	_Super:destroy()
	DelClassIntF()
return