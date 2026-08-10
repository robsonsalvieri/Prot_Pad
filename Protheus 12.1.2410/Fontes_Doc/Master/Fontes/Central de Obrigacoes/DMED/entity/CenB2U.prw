#include "TOTVS.CH"

/*/{Protheus.doc}
    Classe concreta da Entidade CenB2U - Dmed File History
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB2U from CenEntity

    Method New()

    //   Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB2U
    _Super:New()
Return self
/*
Method serialize(oJsonControl) Class CenB2U

    Local oJson := JsonObject():New()
    Default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"healthInsurerCode",self:getValue("healthInsurerCode")) //Column B2U_CODOPE
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("dutyCode")) //Column B2U_CODOBR
    oJsonControl:setProp(oJson,"commitmentYear",self:getValue("commitmentYear")) //Column B2U_ANOCMP
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) //Column B2U_CDCOMP
    oJsonControl:setProp(oJson,"reference",self:getValue("reference")) //Column B2U_REFERE
    oJsonControl:setProp(oJson,"calendarYear",self:getValue("calendarYear")) //Column B2U_ANOCAL
    oJsonControl:setProp(oJson,"correctedReceiptNumber",self:getValue("correctedReceiptNumber")) //Column B2U_RECRET
    oJsonControl:setProp(oJson,"ReceiptNumber",self:getValue("ReceiptNumber")) //Column B2U_NUMREC
    oJsonControl:setProp(oJson,"fileDate",self:getValue("fileDate")) //Column B2U_DATARQ
    oJsonControl:setProp(oJson,"fileTime",self:getValue("fileTime")) //Column B2U_HORARQ
    oJsonControl:setProp(oJson,"fileName",self:getValue("fileName")) //Column B2U_NOMARQ
    oJsonControl:setProp(oJson,"status",self:getValue("status")) //Column B2U_STATUS

Return oJson
*/
Method destroy() Class CenB2U
    _Super:destroy()
    DelClassIntF()
return