#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBvt - Direct Supply Events
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBvt from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()
    Method getIdeOri()
    Method getDesOri()

EndClass

Method New() Class CenBvt
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBvt

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear")) /* Column BVT_ANO */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BVT_CDCOMP */ 
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column BVT_CDOBRI */ 
    oJsonControl:setProp(oJson,"procedureGroup",self:getValue("procedureGroup")) /* Column BVT_CODGRU */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BVT_CODOPE */ 
    oJsonControl:setProp(oJson,"procedureCode",self:getValue("procedureCode")) /* Column BVT_CODPRO */ 
    oJsonControl:setProp(oJson,"tableCode",self:getValue("tableCode")) /* Column BVT_CODTAB */ 
    oJsonControl:setProp(oJson,"formProcDt",self:getValue("formProcDt")) /* Column BVT_DTPRGU */ 
    oJsonControl:setProp(oJson,"batchCode",self:getValue("batchCode")) /* Column BVT_LOTE */ 
    oJsonControl:setProp(oJson,"providerFormNumber",self:getValue("providerFormNumber")) /* Column BVT_NMGPRE */ 
    oJsonControl:setProp(oJson,"enteredQuantity",self:getValue("enteredQuantity")) /* Column BVT_QTDINF */ 
    oJsonControl:setProp(oJson,"procedureValuePaid",self:getValue("procedureValuePaid")) /* Column BVT_VLPGPR */ 
    oJsonControl:setProp(oJson,"coPaymentValue",self:getValue("coPaymentValue")) /* Column BVT_VLRCOP */ 

Return oJson

Method destroy() Class CenBvt
	_Super:destroy()
	DelClassIntF()
return

Method getIdeOri() Class CenBvt
Return BVT->(BVT_CODOPE+BVT_NMGPRE+BVT_CDOBRI+BVT_ANO+BVT_CDCOMP+BVT_LOTE)+DTOS(BVT->BVT_DTPRGU)+BVT->(BVT_CODTAB+BVT_CODGRU+BVT_CODPRO)

Method getDesOri() Class CenBvt
Return BVT->BVT_LOTE