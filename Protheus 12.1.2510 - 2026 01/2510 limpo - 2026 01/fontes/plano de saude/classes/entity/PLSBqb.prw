#include "TOTVS.CH"

/*/{Protheus.doc}
    Classe concreta da Entidade PLSBqb - Versions Of Contracts
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PLSBqb from CenEntity

    Method New()

    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PLSBqb
    _Super:New()
Return self

Method serialize(oJsonControl) Class PLSBqb

    Local oJson := JsonObject():New()
    Default oJsonControl := PLSJsonControl():New()


    oJsonControl:setProp(oJson,"code",self:getValue("code")) /* Column BQB_CODIGO */
    oJsonControl:setProp(oJson,"groupCompanyGroup",self:getValue("groupCompanyGroup")) /* Column BQB_NUMCON */
    oJsonControl:setProp(oJson,"version",self:getValue("version")) /* Column BQB_VERSAO */
    oJsonControl:setProp(oJson,"versionInitialDate",self:getValue("versionInitialDate")) /* Column BQB_DATINI */
    oJsonControl:setProp(oJson,"versionFinalDate",self:getValue("versionFinalDate")) /* Column BQB_DATFIN */
    oJsonControl:setProp(oJson,"operatorCode",self:getValue("operatorCode")) /* Column BQB_CODINT */
    oJsonControl:setProp(oJson,"companyCode",self:getValue("companyCode")) /* Column BQB_CDEMP */

Return oJson

Method destroy() Class PLSBqb
    _Super:destroy()
    DelClassIntF()
return