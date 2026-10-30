#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenCcop - Cooper Check Accnt
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenCcop from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenCcop
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenCcop

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BUW_CDCOMP */ 
    oJsonControl:setProp(oJson,"obligationCode",self:getValue("obligationCode")) /* Column BUW_CODOBR */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column BUW_CODOPE */ 
    oJsonControl:setProp(oJson,"taxName",self:getValue("taxName")) /* Column BUW_DENOMI */ 
    oJsonControl:setProp(oJson,"periodDate",self:getValue("periodDate")) /* Column BUW_DTCOMP */ 
    oJsonControl:setProp(oJson,"taxType",self:getValue("taxType")) /* Column BUW_TIPO */ 
    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) /* Column BUW_ANOCMP */ 
    oJsonControl:setProp(oJson,"monetaryUpdate",self:getValue("monetaryUpdate")) /* Column BUW_ATUMON */ 
    oJsonControl:setProp(oJson,"amtPaidTrimester",self:getValue("amtPaidTrimester")) /* Column BUW_VLPGTR */ 
    oJsonControl:setProp(oJson,"totalAmtFinanced",self:getValue("totalAmtFinanced")) /* Column BUW_VLRFIN */ 
    oJsonControl:setProp(oJson,"totalAmtPaid",self:getValue("totalAmtPaid")) /* Column BUW_VLRPAG */ 
    oJsonControl:setProp(oJson,"dateAdhesionToRefis",self:getValue("dateAdhesionToRefis")) /* Column BUW_DTREFI */ 
    oJsonControl:setProp(oJson,"numberOfInstallments",self:getValue("numberOfInstallments")) /* Column BUW_NUMPAR */ 
    oJsonControl:setProp(oJson,"numbDueInstallments",self:getValue("numbDueInstallments")) /* Column BUW_QTPAIN */ 
    oJsonControl:setProp(oJson,"numbOfPaidInstallm",self:getValue("numbOfPaidInstallm")) /* Column BUW_QTPAPG */ 
    oJsonControl:setProp(oJson,"trimester",self:getValue("trimester")) /* Column BUW_REFERE */ 
    oJsonControl:setProp(oJson,"trimesterFinalBalance",self:getValue("trimesterFinalBalance")) /* Column BUW_SLDFIN */ 
    oJsonControl:setProp(oJson,"trimesterInitialBalance",self:getValue("trimesterInitialBalance")) /* Column BUW_SLDINI */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BUW_STATUS */ 

Return oJson

Method destroy() Class CenCcop
	_Super:destroy()
	DelClassIntF()
return