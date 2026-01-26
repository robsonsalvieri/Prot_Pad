#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB2X - Preset Value Api
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB2X from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB2X
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB2X

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"formSequential",self:getValue("formSequential")) /* Column B2X_SEQUEN */ 
    oJsonControl:setProp(oJson,"presetValue",self:getValue("presetValue")) /* Column B2X_VLRPRE */ 
    oJsonControl:setProp(oJson,"cityOfProvider",self:getValue("cityOfProvider")) /* Column B2X_CDMNPR */ 
    oJsonControl:setProp(oJson,"cnes",self:getValue("cnes")) /* Column B2X_CNES */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column B2X_CODOPE */ 
    oJsonControl:setProp(oJson,"periodCover",self:getValue("periodCover")) /* Column B2X_COMCOB */ 
    oJsonControl:setProp(oJson,"providerCpfCnpj",self:getValue("providerCpfCnpj")) /* Column B2X_CPFCNP */ 
    oJsonControl:setProp(oJson,"inclusionDate",self:getValue("inclusionDate")) /* Column B2X_DATINC */ 
    oJsonControl:setProp(oJson,"exclusionId",self:getValue("exclusionId")) /* Column B2X_EXCLU */ 
    oJsonControl:setProp(oJson,"inclusionTime",self:getValue("inclusionTime")) /* Column B2X_HORINC */ 
    oJsonControl:setProp(oJson,"providerIdentifier",self:getValue("providerIdentifier")) /* Column B2X_IDEPRE */ 
    oJsonControl:setProp(oJson,"presetValueIdent",self:getValue("presetValueIdent")) /* Column B2X_IDVLRP */ 
    oJsonControl:setProp(oJson,"processed",self:getValue("processed")) /* Column B2X_PROCES */ 
    oJsonControl:setProp(oJson,"ansRecordNumber",self:getValue("ansRecordNumber")) /* Column B2X_RGOPIN */ 
    oJsonControl:setProp(oJson,"roboId",self:getValue("roboId")) /* Column B2X_ROBOID */ 

Return oJson

Method destroy() Class CenB2X
	_Super:destroy()
	DelClassIntF()
return