#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenCoas - Assistance Coverage
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenCoas from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenCoas
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenCoas

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8I_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8I_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8I_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8I_CODOPE */ 
    oJsonControl:setProp(oJson,"typeOfPlan",self:getValue("typeOfPlan")) /* Column B8I_PLANO */ 
    oJsonControl:setProp(oJson,"paymentOrigin",self:getValue("paymentOrigin")) /* Column B8I_ORIGEM */ 
    oJsonControl:setProp(oJson,"otherPayments",self:getValue("otherPayments")) /* Column B8I_OUTROS */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B8I_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B8I_STATUS */ 
    oJsonControl:setProp(oJson,"therapies",self:getValue("therapies")) /* Column B8I_TERAPI */ 
    oJsonControl:setProp(oJson,"medicalAppointment",self:getValue("medicalAppointment")) /* Column B8I_CONSUL */ 
    oJsonControl:setProp(oJson,"otherExpenses",self:getValue("otherExpenses")) /* Column B8I_DEMAIS */ 
    oJsonControl:setProp(oJson,"examinations",self:getValue("examinations")) /* Column B8I_EXAMES */ 
    oJsonControl:setProp(oJson,"hospitalizations",self:getValue("hospitalizations")) /* Column B8I_INTERN */ 

Return oJson

Method destroy() Class CenCoas
	_Super:destroy()
	DelClassIntF()
return