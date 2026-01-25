#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBw8 - Direct Supply Api
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBw8 from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBw8
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBw8

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()

    oJson["_expandables"] := {"monitDirectSupplyEvents"}

    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BW8_CODOPE */ 
    oJsonControl:setProp(oJson,"formSequential",self:getValue("formSequential")) /* Column BW8_SEQGUI */ 
    oJsonControl:setProp(oJson,"formProcDt",self:getValue("formProcDt")) /* Column BW8_DTPRGU */ 
    oJsonControl:setProp(oJson,"registration",self:getValue("registration")) /* Column BW8_MATRIC */ 
    oJsonControl:setProp(oJson,"providerFormNumber",self:getValue("providerFormNumber")) /* Column BW8_NMGPRE */ 
    oJsonControl:setProp(oJson,"processed",self:getValue("processed")) /* Column BW8_PROCES */ 
    oJsonControl:setProp(oJson,"inclusionDate",self:getValue("inclusionDate")) /* Column BW8_DATINC */ 
    oJsonControl:setProp(oJson,"inclusionTime",self:getValue("inclusionTime")) /* Column BW8_HORINC */ 
    oJsonControl:setProp(oJson,"exclusionId",self:getValue("exclusionId")) /* Column BW8_EXCLU */ 
    oJsonControl:setProp(oJson,"roboId",self:getValue("roboId")) /* Column BW8_ROBOID */ 

Return oJson

Method destroy() Class CenBw8
	_Super:destroy()
	DelClassIntF()
return