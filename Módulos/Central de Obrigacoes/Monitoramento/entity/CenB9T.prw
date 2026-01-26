#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB9T - Preset Value
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB9T from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()
    Method getIdeOri()
    Method getDesOri()

EndClass

Method New() Class CenB9T
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB9T

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear")) /* Column B9T_ANO */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B9T_CDCOMP */ 
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column B9T_CDOBRI */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column B9T_CODOPE */ 
    oJsonControl:setProp(oJson,"periodCover",self:getValue("periodCover")) /* Column B9T_COMCOB */ 
    oJsonControl:setProp(oJson,"providerCpfCnpj",self:getValue("providerCpfCnpj")) /* Column B9T_CPFCNP */ 
    oJsonControl:setProp(oJson,"batchCode",self:getValue("batchCode")) /* Column B9T_LOTE */ 
    oJsonControl:setProp(oJson,"ansRecordNumber",self:getValue("ansRecordNumber")) /* Column B9T_RGOPIN */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B9T_STATUS */ 
    oJsonControl:setProp(oJson,"monitoringRecordType",self:getValue("monitoringRecordType")) /* Column B9T_TPRGMN */ 
    oJsonControl:setProp(oJson,"presetValue",self:getValue("presetValue")) /* Column B9T_VLRPRE */ 
    oJsonControl:setProp(oJson,"processingDate",self:getValue("processingDate")) /* Column B9T_DATPRO */ 
    oJsonControl:setProp(oJson,"processingTime",self:getValue("processingTime")) /* Column B9T_HORPRO */ 
    oJsonControl:setProp(oJson,"providerIdentifier",self:getValue("providerIdentifier")) /* Column B9T_IDEPRE */ 
    oJsonControl:setProp(oJson,"presetValueIdent",self:getValue("presetValueIdent")) /* Column B9T_IDVLRP */ 
    oJsonControl:setProp(oJson,"cnes",self:getValue("cnes")) /* Column B9T_CNES */ 
    oJsonControl:setProp(oJson,"cityOfProvider",self:getValue("cityOfProvider")) /* Column B9T_CDMNPR */ 
    oJsonControl:setProp(oJson,"inclusionDate",self:getValue("inclusionDate")) /* Column B9T_DATINC */ 
    oJsonControl:setProp(oJson,"inclusionTime",self:getValue("inclusionTime")) /* Column B9T_HORINC */ 

Return oJson

Method destroy() Class CenB9T
	_Super:destroy()
	DelClassIntF()
return

Method getIdeOri() Class CenB9T
Return B9T->(B9T_CODOPE+B9T_CNES+B9T_CPFCNP+B9T_CDMNPR+B9T_RGOPIN+B9T_IDVLRP+B9T_COMCOB+B9T_CDOBRI+B9T_ANO+B9T_CDCOMP+B9T_LOTE)

Method getDesOri() Class CenB9T
Return B9T->B9T_LOTE
