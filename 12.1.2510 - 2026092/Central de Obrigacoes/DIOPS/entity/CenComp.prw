#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenComp - Commitment
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenComp from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenComp
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenComp

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column B3D_CDOBRI */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B3D_CODIGO */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column B3D_CODOPE */ 
    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear")) /* Column B3D_ANO */ 
    oJsonControl:setProp(oJson,"obligationType",self:getValue("obligationType")) /* Column B3D_TIPOBR */ 
    oJsonControl:setProp(oJson,"commitmentDueDate",self:getValue("commitmentDueDate")) /* Column B3D_VCTO */ 
    oJsonControl:setProp(oJson,"dueDateNotification",self:getValue("dueDateNotification")) /* Column B3D_AVVCTO */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B3D_REFERE */ 
    oJsonControl:setProp(oJson,"synthetizesBenefit",self:getValue("synthetizesBenefit")) /* Column B3D_SNTBEN */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B3D_STATUS */ 

Return oJson

Method destroy() Class CenComp
	_Super:destroy()
	DelClassIntF()
return