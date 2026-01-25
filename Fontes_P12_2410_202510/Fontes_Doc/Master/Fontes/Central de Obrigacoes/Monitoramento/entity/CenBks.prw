#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBks - Monitoring Movement Events
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBks from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()
    Method getIdeOri()
    Method getDesOri()

EndClass

Method New() Class CenBks
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBks

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"procedureGroup",self:getValue("procedureGroup")) /* Column BKS_CODGRU */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BKS_CODOPE */ 
    oJsonControl:setProp(oJson,"procedureCode",self:getValue("procedureCode")) /* Column BKS_CODPRO */ 
    oJsonControl:setProp(oJson,"tableCode",self:getValue("tableCode")) /* Column BKS_CODTAB */ 
    oJsonControl:setProp(oJson,"formProcDt",self:getValue("formProcDt")) /* Column BKS_DTPRGU */ 
    oJsonControl:setProp(oJson,"batchCode",self:getValue("batchCode")) /* Column BKS_LOTE */ 
    oJsonControl:setProp(oJson,"operatorFormNumber",self:getValue("operatorFormNumber")) /* Column BKS_NMGOPE */ 
    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear")) /* Column BKS_ANO */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BKS_CDCOMP */ 
    oJsonControl:setProp(oJson,"toothCode",self:getValue("toothCode")) /* Column BKS_CDDENT */ 
    oJsonControl:setProp(oJson,"toothFaceCode",self:getValue("toothFaceCode")) /* Column BKS_CDFACE */ 
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column BKS_CDOBRI */ 
    oJsonControl:setProp(oJson,"regionCode",self:getValue("regionCode")) /* Column BKS_CDREGI */ 
    oJsonControl:setProp(oJson,"supplierCnpj",self:getValue("supplierCnpj")) /* Column BKS_CNPJFR */ 
    oJsonControl:setProp(oJson,"package",self:getValue("package")) /* Column BKS_PACOTE */ 
    oJsonControl:setProp(oJson,"enteredQuantity",self:getValue("enteredQuantity")) /* Column BKS_QTDINF */ 
    oJsonControl:setProp(oJson,"quantityPaid",self:getValue("quantityPaid")) /* Column BKS_QTDPAG */ 
    oJsonControl:setProp(oJson,"procedureValuePaid",self:getValue("procedureValuePaid")) /* Column BKS_VLPGPR */ 
    oJsonControl:setProp(oJson,"coPaymentValue",self:getValue("coPaymentValue")) /* Column BKS_VLRCOP */ 
    oJsonControl:setProp(oJson,"disallVl",self:getValue("disallVl")) /* Column BKS_VLRGLO */ 
    oJsonControl:setProp(oJson,"valueEntered",self:getValue("valueEntered")) /* Column BKS_VLRINF */ 
    oJsonControl:setProp(oJson,"valuePaidSupplier",self:getValue("valuePaidSupplier")) /* Column BKS_VLRPGF */ 
    oJsonControl:setProp(oJson,"eventType",self:getValue("eventType")) /* Column BKS_TIPEVE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BKS_STATUS */ 

Return oJson

Method destroy() Class CenBks
	_Super:destroy()
	DelClassIntF()
return

Method getIdeOri() Class CenBks
Return BKS->(BKS_CODOPE+BKS_NMGOPE+BKS_CDOBRI+BKS_ANO+BKS_CDCOMP+BKS_LOTE)+DTOS(BKS->BKS_DTPRGU)+BKS->(BKS_CODGRU+BKS_CODTAB+BKS_CODPRO+BKS_CDDENT+BKS_CDREGI+BKS_CDFACE)
                                                                    
Method getDesOri() Class CenBks
Return BKS->BKS_LOTE