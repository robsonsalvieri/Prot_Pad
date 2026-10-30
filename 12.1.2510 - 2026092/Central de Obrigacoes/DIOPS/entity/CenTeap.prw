#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenTeap - Liability Adequation Test
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenTeap from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenTeap
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenTeap

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B89_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B89_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B89_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B89_CODOPE */ 
    oJsonControl:setProp(oJson,"planType",self:getValue("planType")) /* Column B89_TIPPLA */ 
    oJsonControl:setProp(oJson,"contractCancelRate",self:getValue("contractCancelRate")) /* Column B89_TXCANC */ 
    oJsonControl:setProp(oJson,"biomTabAdjustment",self:getValue("biomTabAdjustment")) /* Column B89_AJUTAB */ 
    oJsonControl:setProp(oJson,"cashFlowAdjEstimation",self:getValue("cashFlowAdjEstimation")) /* Column B89_ESTFLX */ 
    oJsonControl:setProp(oJson,"utiOfRangesRn632003",self:getValue("utiOfRangesRn632003")) /* Column B89_FAIETA */ 
    oJsonControl:setProp(oJson,"estimatedMedicalInflati",self:getValue("estimatedMedicalInflati")) /* Column B89_INFMED */ 
    oJsonControl:setProp(oJson,"ettjInterMethod",self:getValue("ettjInterMethod")) /* Column B89_METINT */ 
    oJsonControl:setProp(oJson,"averageAdjustmentPerVa",self:getValue("averageAdjustmentPerVa")) /* Column B89_REACUS */ 
    oJsonControl:setProp(oJson,"estimatedMaximumAdjustm",self:getValue("estimatedMaximumAdjustm")) /* Column B89_REAMAX */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B89_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B89_STATUS */ 

Return oJson

Method destroy() Class CenTeap
	_Super:destroy()
	DelClassIntF()
return