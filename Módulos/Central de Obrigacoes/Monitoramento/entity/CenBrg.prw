#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBrg - Process Events Api Monitor
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBrg from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBrg
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBrg

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"procedureGroup",self:getValue("procedureGroup")) /* Column BRG_CODGRU */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BRG_CODOPE */ 
    oJsonControl:setProp(oJson,"procedureCode",self:getValue("procedureCode")) /* Column BRG_CODPRO */ 
    oJsonControl:setProp(oJson,"tableCode",self:getValue("tableCode")) /* Column BRG_CODTAB */ 
    oJsonControl:setProp(oJson,"operatorFormNumber",self:getValue("operatorFormNumber")) /* Column BRG_NMGOPE */ 
    oJsonControl:setProp(oJson,"toothCode",self:getValue("toothCode")) /* Column BRG_CDDENT */ 
    oJsonControl:setProp(oJson,"toothFaceCode",self:getValue("toothFaceCode")) /* Column BRG_CDFACE */ 
    oJsonControl:setProp(oJson,"regionCode",self:getValue("regionCode")) /* Column BRG_CDREGI */ 
    oJsonControl:setProp(oJson,"supplierCnpj",self:getValue("supplierCnpj")) /* Column BRG_CNPJFR */ 
    oJsonControl:setProp(oJson,"package",self:getValue("package")) /* Column BRG_PACOTE */ 
    oJsonControl:setProp(oJson,"enteredQuantity",self:getValue("enteredQuantity")) /* Column BRG_QTDINF */ 
    oJsonControl:setProp(oJson,"quantityPaid",self:getValue("quantityPaid")) /* Column BRG_QTDPAG */ 
    oJsonControl:setProp(oJson,"procedureValuePaid",self:getValue("procedureValuePaid")) /* Column BRG_VLPGPR */ 
    oJsonControl:setProp(oJson,"coPaymentValue",self:getValue("coPaymentValue")) /* Column BRG_VLRCOP */ 
    oJsonControl:setProp(oJson,"disallVl",self:getValue("disallVl")) /* Column BRG_VLRGLO */ 
    oJsonControl:setProp(oJson,"valueEntered",self:getValue("valueEntered")) /* Column BRG_VLRINF */ 
    oJsonControl:setProp(oJson,"valuePaidSupplier",self:getValue("valuePaidSupplier")) /* Column BRG_VLRPGF */ 
    oJsonControl:setProp(oJson,"eventType",self:getValue("eventType")) /* Column BRG_TIPEVE */ 

Return oJson

Method destroy() Class CenBrg
	_Super:destroy()
	DelClassIntF()
return