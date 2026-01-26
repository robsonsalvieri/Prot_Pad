#include "TOTVS.CH"

/*/{Protheus.doc}
    Classe concreta da Entidade CenB2Y - Analytic Dmed Expenses
    @type  Class
    @author FrameworkApi 1.0
    @since 20200914
/*/
Class CenB2Y from CenEntity
    Method New()
    Method serialize(oJsonControl)
    Method destroy()
EndClass

Method New() Class CenB2Y
    _Super:New()
Return self

Method serialize(oJsonControl) Class CenB2Y

    Local oJson := JsonObject():New()
    Default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"healthInsurerCode",self:getValue("healthInsurerCode")) /* Column B2Y_CODOPE */
    oJsonControl:setProp(oJson,"ssnHolder",self:getValue("ssnHolder")) /* Column B2Y_CPFTIT */
    oJsonControl:setProp(oJson,"titleHolderEnrollment",self:getValue("titleHolderEnrollment")) /* Column B2Y_MATTIT */
    oJsonControl:setProp(oJson,"holderName",self:getValue("holderName")) /* Column B2Y_NOMTIT */
    oJsonControl:setProp(oJson,"dependentSsn",self:getValue("dependentSsn")) /* Column B2Y_CPFDEP */
    oJsonControl:setProp(oJson,"dependentEnrollment",self:getValue("dependentEnrollment")) /* Column B2Y_MATDEP */
    oJsonControl:setProp(oJson,"dependentName",self:getValue("dependentName")) /* Column B2Y_NOMDEP */
    oJsonControl:setProp(oJson,"dependentBirthDate",self:getValue("dependentBirthDate")) /* Column B2Y_DTNASD */
    oJsonControl:setProp(oJson,"dependenceRelationships",self:getValue("dependenceRelationships")) /* Column B2Y_RELDEP */
    oJsonControl:setProp(oJson,"expenseKey",self:getValue("expenseKey")) /* Column B2Y_CHVDES */
    oJsonControl:setProp(oJson,"expenseAmount",self:getValue("expenseAmount")) /* Column B2Y_VLRDES */
    oJsonControl:setProp(oJson,"refundAmount",self:getValue("refundAmount")) /* Column B2Y_VLRREE */
    oJsonControl:setProp(oJson,"previousYearRefundAmt",self:getValue("previousYearRefundAmt")) /* Column B2Y_VLRRAA */
    oJsonControl:setProp(oJson,"period",self:getValue("period")) /* Column B2Y_COMPET */
    oJsonControl:setProp(oJson,"providerSsnEin",self:getValue("providerSsnEin")) /* Column B2Y_CPFCGC */
    oJsonControl:setProp(oJson,"providerName",self:getValue("providerName")) /* Column B2Y_NOMPRE */
    oJsonControl:setProp(oJson,"processed",self:getValue("processed")) /* Column B2Y_PROCES */
    oJsonControl:setProp(oJson,"roboId",self:getValue("roboId"))
    oJsonControl:setProp(oJson,"inclusionTime",self:getValue("inclusionTime"))
    oJsonControl:setProp(oJson,"exclusionId",self:getValue("exclusionId"))
    oJsonControl:setProp(oJson,"inclusionDate",self:getValue("inclusionDate"))
    oJsonControl:setProp(oJson,"inclusionType",self:getValue("inclusionType"))

Return oJson

Method destroy() Class CenB2Y
    _Super:destroy()
    DelClassIntF()
return
