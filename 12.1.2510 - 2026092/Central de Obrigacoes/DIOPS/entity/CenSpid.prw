#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenSpid - Liability Balance Age
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenSpid from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenSpid
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenSpid

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8G_ANOCMP */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8G_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8G_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8G_CODOPE */ 
    oJsonControl:setProp(oJson,"financialDueDate",self:getValue("financialDueDate")) /* Column B8G_VENCTO */ 
    oJsonControl:setProp(oJson,"collectiveFloating",self:getValue("collectiveFloating")) /* Column B8G_COLPOS */ 
    oJsonControl:setProp(oJson,"collectiveFixed",self:getValue("collectiveFixed")) /* Column B8G_COLPRE */ 
    oJsonControl:setProp(oJson,"beneficiariesOperationC",self:getValue("beneficiariesOperationC")) /* Column B8G_CREADM */ 
    oJsonControl:setProp(oJson,"postPaymentOperCredit",self:getValue("postPaymentOperCredit")) /* Column B8G_CROPPO */ 
    oJsonControl:setProp(oJson,"individualFloating",self:getValue("individualFloating")) /* Column B8G_INDPOS */ 
    oJsonControl:setProp(oJson,"individualFixed",self:getValue("individualFixed")) /* Column B8G_INDPRE */ 
    oJsonControl:setProp(oJson,"prePaymentOperatorsCre",self:getValue("prePaymentOperatorsCre")) /* Column B8G_OUCROP */ 
    oJsonControl:setProp(oJson,"otherCreditsWithPlan",self:getValue("otherCreditsWithPlan")) /* Column B8G_OUCRPL */ 
    oJsonControl:setProp(oJson,"otherCredNotRelatPlan",self:getValue("otherCredNotRelatPlan")) /* Column B8G_OUTCRE */ 
    oJsonControl:setProp(oJson,"partBenefInEveClaim",self:getValue("partBenefInEveClaim")) /* Column B8G_PARBEN */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B8G_REFERE */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B8G_STATUS */ 

Return oJson

Method destroy() Class CenSpid
	_Super:destroy()
	DelClassIntF()
return