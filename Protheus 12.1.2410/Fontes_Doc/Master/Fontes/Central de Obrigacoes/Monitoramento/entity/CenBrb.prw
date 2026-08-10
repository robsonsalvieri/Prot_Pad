#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBrb - monitFormEvents
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBrb from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBrb
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBrb

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()

    oJson["_expandables"] := {"monitFormPackages"}

    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BRB_CODOPE */ 
    oJsonControl:setProp(oJson,"formSequential",self:getValue("formSequential")) /* Column BRB_SEQGUI */ 
    oJsonControl:setProp(oJson,"sequence",self:getValue("sequence")) /* Column BRB_SEQITE */ 
    oJsonControl:setProp(oJson,"procedureValuePaid",self:getValue("procedureValuePaid")) /* Column BRB_VLPGPR */ 
    oJsonControl:setProp(oJson,"coPaymentValue",self:getValue("coPaymentValue")) /* Column BRB_VLRCOP */ 
    oJsonControl:setProp(oJson,"disallVl",self:getValue("disallVl")) /* Column BRB_VLRGLO */ 
    oJsonControl:setProp(oJson,"valueEntered",self:getValue("valueEntered")) /* Column BRB_VLRINF */ 
    oJsonControl:setProp(oJson,"valuePaidSupplier",self:getValue("valuePaidSupplier")) /* Column BRB_VLRPGF */ 
    oJsonControl:setProp(oJson,"procedureCode",self:getValue("procedureCode")) /* Column BRB_CODPRO */ 
    oJsonControl:setProp(oJson,"tableCode",self:getValue("tableCode")) /* Column BRB_CODTAB */ 
    oJsonControl:setProp(oJson,"package",self:getValue("package")) /* Column BRB_PACOTE */ 
    oJsonControl:setProp(oJson,"enteredQuantity",self:getValue("enteredQuantity")) /* Column BRB_QTDINF */ 
    oJsonControl:setProp(oJson,"quantityPaid",self:getValue("quantityPaid")) /* Column BRB_QTDPAG */ 
    oJsonControl:setProp(oJson,"toothCode",self:getValue("toothCode")) /* Column BRB_CDDENT */ 
    oJsonControl:setProp(oJson,"toothFaceCode",self:getValue("toothFaceCode")) /* Column BRB_CDFACE */ 
    oJsonControl:setProp(oJson,"regionCode",self:getValue("regionCode")) /* Column BRB_CDREGI */ 
    oJsonControl:setProp(oJson,"supplierCnpj",self:getValue("supplierCnpj")) /* Column BRB_CNPJFR */ 
    oJsonControl:setProp(oJson,"procedureGroup",self:getValue("procedureGroup")) /* Column BRB_CODGRU */ 

Return oJson

Method destroy() Class CenBrb
	_Super:destroy()
	DelClassIntF()
return