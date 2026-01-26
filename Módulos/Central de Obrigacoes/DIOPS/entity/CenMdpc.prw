#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenMdpc - Capital Standard Model
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenMdpc from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenMdpc
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenMdpc

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B82_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B82_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B82_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B82_CODOPE */ 
    oJsonControl:setProp(oJson,"tempRemidNumber",self:getValue("tempRemidNumber")) /* Column B82_NMRMTP */ 
    oJsonControl:setProp(oJson,"vitRemidNumber",self:getValue("vitRemidNumber")) /* Column B82_NMRMVI */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B82_REFERE */ 
    oJsonControl:setProp(oJson,"tempExpSom",self:getValue("tempExpSom")) /* Column B82_SMDETP */ 
    oJsonControl:setProp(oJson,"vitExpSom",self:getValue("vitExpSom")) /* Column B82_SMDEVI */ 
    oJsonControl:setProp(oJson,"tempRemisSom",self:getValue("tempRemisSom")) /* Column B82_SMRMTP */ 
    oJsonControl:setProp(oJson,"vitRemisSom",self:getValue("vitRemisSom")) /* Column B82_SMRMVI */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B82_STATUS */ 

Return oJson

Method destroy() Class CenMdpc
	_Super:destroy()
	DelClassIntF()
return