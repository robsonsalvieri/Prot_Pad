#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenAcio - Shareholders
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenAcio from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenAcio
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenAcio

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8S_CODOPE */ 
    oJsonControl:setProp(oJson,"shareholderSCpfCnpj",self:getValue("shareholderSCpfCnpj")) /* Column B8S_CPFCNP */ 
    oJsonControl:setProp(oJson,"corporateName",self:getValue("corporateName")) /* Column B8S_NOMRAZ */ 
    oJsonControl:setProp(oJson,"numberOfShares",self:getValue("numberOfShares")) /* Column B8S_QTDQUO */ 
    oJsonControl:setProp(oJson,"shareholderType",self:getValue("shareholderType")) /* Column B8S_TPACIO */ 

Return oJson

Method destroy() Class CenAcio
	_Super:destroy()
	DelClassIntF()
return