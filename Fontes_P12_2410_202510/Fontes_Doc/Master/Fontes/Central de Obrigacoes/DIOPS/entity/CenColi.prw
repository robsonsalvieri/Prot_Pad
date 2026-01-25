#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenColi - Controlled Affiliates
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenColi from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenColi
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenColi

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"legalEntityNatRegister",self:getValue("legalEntityNatRegister")) /* Column B8T_CNPJ */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8T_CODOPE */ 
    oJsonControl:setProp(oJson,"quantityOfActions",self:getValue("quantityOfActions")) /* Column B8T_QTDACO */ 
    oJsonControl:setProp(oJson,"companyName",self:getValue("companyName")) /* Column B8T_RAZSOC */ 
    oJsonControl:setProp(oJson,"totalOfActionsOrQuota",self:getValue("totalOfActionsOrQuota")) /* Column B8T_TOTACO */ 
    oJsonControl:setProp(oJson,"typeOfShare",self:getValue("typeOfShare")) /* Column B8T_TPPART */ 
    oJsonControl:setProp(oJson,"companyClassification",self:getValue("companyClassification")) /* Column B8T_CLAEMP */ 

Return oJson

Method destroy() Class CenColi
	_Super:destroy()
	DelClassIntF()
return