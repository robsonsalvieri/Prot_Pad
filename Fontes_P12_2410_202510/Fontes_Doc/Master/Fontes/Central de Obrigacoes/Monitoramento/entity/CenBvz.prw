#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBVZ - Other Remuneration
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBVZ from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()
    Method getIdeOri()
    Method getDesOri()

EndClass

Method New() Class CenBVZ
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBVZ

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear")) /* Column BVZ_ANO */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BVZ_CDCOMP */ 
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column BVZ_CDOBRI */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BVZ_CODOPE */ 
    oJsonControl:setProp(oJson,"providerCpfCnpj",self:getValue("providerCpfCnpj")) /* Column BVZ_CPFCNP */ 
    oJsonControl:setProp(oJson,"formProcDt",self:getValue("formProcDt")) /* Column BVZ_DTPROC */ 
    oJsonControl:setProp(oJson,"batchCode",self:getValue("batchCode")) /* Column BVZ_LOTE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BVZ_STATUS */ 
    oJsonControl:setProp(oJson,"monitoringRecordType",self:getValue("monitoringRecordType")) /* Column BVZ_TPRGMN */ 
    oJsonControl:setProp(oJson,"totalDisallowValue",self:getValue("totalDisallowValue")) /* Column BVZ_VLTGLO */ 
    oJsonControl:setProp(oJson,"totalValueEntered",self:getValue("totalValueEntered")) /* Column BVZ_VLTINF */ 
    oJsonControl:setProp(oJson,"totalValuePaid",self:getValue("totalValuePaid")) /* Column BVZ_VLTPAG */ 
    oJsonControl:setProp(oJson,"inclusionTime",self:getValue("inclusionTime")) /* Column BVZ_HORINC */ 
    oJsonControl:setProp(oJson,"processingTime",self:getValue("processingTime")) /* Column BVZ_HORPRO */ 
    oJsonControl:setProp(oJson,"identReceipt",self:getValue("identReceipt")) /* Column BVZ_IDEREC */ 
    oJsonControl:setProp(oJson,"inclusionDate",self:getValue("inclusionDate")) /* Column BVZ_DATINC */ 
    oJsonControl:setProp(oJson,"processingDate",self:getValue("processingDate")) /* Column BVZ_DATPRO */ 

Return oJson

Method destroy() Class CenBVZ
	_Super:destroy()
	DelClassIntF()
return

Method getIdeOri() Class CenBVZ
Return BVZ->(BVZ_CODOPE+BVZ_CPFCNP+BVZ_CDOBRI+BVZ_ANO+BVZ_CDCOMP+BVZ_LOTE)+DTOS(BVZ->BVZ_DTPROC)

Method getDesOri() Class CenBVZ
Return BVZ->BVZ_LOTE