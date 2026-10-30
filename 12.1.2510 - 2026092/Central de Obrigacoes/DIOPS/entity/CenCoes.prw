#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenCoes - Stipulated Contracts
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenCoes from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenCoes
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenCoes

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column BUP_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BUP_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column BUP_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column BUP_CODOPE */ 
    oJsonControl:setProp(oJson,"operatorRecordInAns",self:getValue("operatorRecordInAns")) /* Column BUP_OPECOE */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column BUP_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BUP_STATUS */ 
    oJsonControl:setProp(oJson,"billingValue",self:getValue("billingValue")) /* Column BUP_VLRFAT */ 

Return oJson

Method destroy() Class CenCoes
	_Super:destroy()
	DelClassIntF()
return