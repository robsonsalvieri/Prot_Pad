#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenSmcr - Trans Contr Amt Segr
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenSmcr from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenSmcr
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenSmcr

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column BVS_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BVS_CDCOMP */ 
    oJsonControl:setProp(oJson,"benefitAdmOperCode",self:getValue("benefitAdmOperCode")) /* Column BVS_CODIGO */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column BVS_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column BVS_CODOPE */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column BVS_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BVS_STATUS */ 
    oJsonControl:setProp(oJson,"amt1StMthTrimester",self:getValue("amt1StMthTrimester")) /* Column BVS_VLMES1 */ 
    oJsonControl:setProp(oJson,"amt2NdMthTrimester",self:getValue("amt2NdMthTrimester")) /* Column BVS_VLMES2 */ 
    oJsonControl:setProp(oJson,"amt3RdMthTrimester",self:getValue("amt3RdMthTrimester")) /* Column BVS_VLMES3 */ 

Return oJson

Method destroy() Class CenSmcr
	_Super:destroy()
	DelClassIntF()
return