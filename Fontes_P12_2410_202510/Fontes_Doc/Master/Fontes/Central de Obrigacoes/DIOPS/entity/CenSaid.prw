#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenSaid - Active Balance Age
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenSaid from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenSaid
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenSaid

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column B8F_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column B8F_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8F_CODOPE */ 
    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column B8F_ANOCMP */ 
    oJsonControl:setProp(oJson,"financialDueDate",self:getValue("financialDueDate")) /* Column B8F_VENCTO */ 
    oJsonControl:setProp(oJson,"debWPortfAcquis",self:getValue("debWPortfAcquis")) /* Column B8F_AQUCAR */ 
    oJsonControl:setProp(oJson,"mktOnOperations",self:getValue("mktOnOperations")) /* Column B8F_COMERC */ 
    oJsonControl:setProp(oJson,"debitsWithOperators",self:getValue("debitsWithOperators")) /* Column B8F_DEBOPE */ 
    oJsonControl:setProp(oJson,"benefDepContrapIns",self:getValue("benefDepContrapIns")) /* Column B8F_DEPBEN */ 
    oJsonControl:setProp(oJson,"eventClaimNetPres",self:getValue("eventClaimNetPres")) /* Column B8F_EVENTO */ 
    oJsonControl:setProp(oJson,"eventClaimNetSus",self:getValue("eventClaimNetSus")) /* Column B8F_EVESUS */ 
    oJsonControl:setProp(oJson,"otherDebOprWPlan",self:getValue("otherDebOprWPlan")) /* Column B8F_OUDBOP */ 
    oJsonControl:setProp(oJson,"otherDebitsToPay",self:getValue("otherDebitsToPay")) /* Column B8F_OUDBPG */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column B8F_REFERE */ 
    oJsonControl:setProp(oJson,"hthCareServProv",self:getValue("hthCareServProv")) /* Column B8F_SERASS */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column B8F_STATUS */ 
    oJsonControl:setProp(oJson,"billsChargesCollect",self:getValue("billsChargesCollect")) /* Column B8F_TITSEN */ 

Return oJson

Method destroy() Class CenSaid
	_Super:destroy()
	DelClassIntF()
return