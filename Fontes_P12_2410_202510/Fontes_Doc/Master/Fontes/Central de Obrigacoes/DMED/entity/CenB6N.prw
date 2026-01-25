#include "TOTVS.CH"

/*/{Protheus.doc}
    Classe concreta da Entidade CenB6N - Persons In Charge
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB6N from CenEntity

    Method New()

    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB6N
    _Super:New()
Return self

Method serialize(oJsonControl) Class CenB6N

    Local oJson := JsonObject():New()
    Default oJsonControl := CenJsonControl():New()


    oJsonControl:setProp(oJson,"healthInsurerCode",self:getValue("healthInsurerCode"))  //Column B6N_CODOPE
    oJsonControl:setProp(oJson,"ssn",self:getValue("ssn"))  //Column B6N_CPFRES
    oJsonControl:setProp(oJson,"name",self:getValue("name"))  //Column B6N_NOMRES
    oJsonControl:setProp(oJson,"areaCode",self:getValue("areaCode"))  //Column B6N_DDDRES
    oJsonControl:setProp(oJson,"phoneNumber",self:getValue("phoneNumber"))  //Column B6N_TELRES
    oJsonControl:setProp(oJson,"extensionLine",self:getValue("extensionLine"))  //Column B6N_RAMALR
    oJsonControl:setProp(oJson,"fax",self:getValue("fax"))  //Column B6N_FAXRES
    oJsonControl:setProp(oJson,"eMail",self:getValue("eMail"))  //Column B6N_EMAILR
    oJsonControl:setProp(oJson,"active",self:getValue("active"))  //Column B6N_ATIVO

Return oJson

Method destroy() Class CenB6N
    _Super:destroy()
    DelClassIntF()
return