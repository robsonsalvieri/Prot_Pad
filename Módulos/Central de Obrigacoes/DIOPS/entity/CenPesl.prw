#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenPesl - Prov Net Sin Ev Pesl
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenPesl from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenPesl
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenPesl

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8J_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8J_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8J_CODOPE */ 
    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8J_ANOCMP */ 
    oJsonControl:setProp(oJson,"evCorrAssumMajorPer",self:getValue("evCorrAssumMajorPer")) /* Column B8J_CAMAIS */ 
    oJsonControl:setProp(oJson,"lastDaysAssumCorrEv",self:getValue("lastDaysAssumCorrEv")) /* Column B8J_CAULTI */ 
    oJsonControl:setProp(oJson,"greaterDangerLossEvent",self:getValue("greaterDangerLossEvent")) /* Column B8J_EVMAIS */ 
    oJsonControl:setProp(oJson,"latestDaysEvents",self:getValue("latestDaysEvents")) /* Column B8J_EVULTI */ 
    oJsonControl:setProp(oJson,"noOfBeneficiaries",self:getValue("noOfBeneficiaries")) /* Column B8J_QTDE */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B8J_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B8J_STATUS */ 

Return oJson

Method destroy() Class CenPesl
	_Super:destroy()
	DelClassIntF()
return