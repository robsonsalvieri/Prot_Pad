#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBvq - Direct Supply
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBvq from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()
    Method getIdeOri()
    Method getDesOri()

EndClass

Method New() Class CenBvq
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBvq

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear")) /* Column BVQ_ANO */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BVQ_CDCOMP */ 
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column BVQ_CDOBRI */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BVQ_CODOPE */ 
    oJsonControl:setProp(oJson,"formProcDt",self:getValue("formProcDt")) /* Column BVQ_DTPRGU */ 
    oJsonControl:setProp(oJson,"batchCode",self:getValue("batchCode")) /* Column BVQ_LOTE */ 
    oJsonControl:setProp(oJson,"providerFormNumber",self:getValue("providerFormNumber")) /* Column BVQ_NMGPRE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BVQ_STATUS */ 
    oJsonControl:setProp(oJson,"monitoringRecordType",self:getValue("monitoringRecordType")) /* Column BVQ_TPRGMN */ 
    oJsonControl:setProp(oJson,"coPaymentTotalValue",self:getValue("coPaymentTotalValue")) /* Column BVQ_VLTCOP */ 
    oJsonControl:setProp(oJson,"valuePaidForm",self:getValue("valuePaidForm")) /* Column BVQ_VLTGUI */ 
    oJsonControl:setProp(oJson,"ownTableTotalValue",self:getValue("ownTableTotalValue")) /* Column BVQ_VLTTBP */ 
    oJsonControl:setProp(oJson,"registration",self:getValue("registration")) /* Column BVQ_MATRIC */ 
    oJsonControl:setProp(oJson,"processingTime",self:getValue("processingTime")) /* Column BVQ_HORPRO */ 
    oJsonControl:setProp(oJson,"processingDate",self:getValue("processingDate")) /* Column BVQ_DATPRO */ 
    oJsonControl:setProp(oJson,"inclusionDate",self:getValue("inclusionDate")) /* Column BVQ_DATINC */ 
    oJsonControl:setProp(oJson,"inclusionTime",self:getValue("inclusionTime")) /* Column BVQ_HORINC */ 

Return oJson

Method destroy() Class CenBvq
	_Super:destroy()
	DelClassIntF()
return

Method getIdeOri() Class CenBvq
Return BVQ->(BVQ_CODOPE+BVQ_NMGPRE+BVQ_CDOBRI+BVQ_ANO+BVQ_CDCOMP+BVQ_LOTE)+DTOS(BVQ->(BVQ_DTPRGU))

Method getDesOri() Class CenBvq
Return BVQ->BVQ_LOTE