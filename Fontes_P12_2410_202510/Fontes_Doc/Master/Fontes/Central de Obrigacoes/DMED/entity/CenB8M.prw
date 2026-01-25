#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB8M - Operators Diops
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB8M from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB8M
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB8M

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()


    oJsonControl:setProp(oJson,"registerNumber",self:getValue("registerNumber")) 
    oJsonControl:setProp(oJson,"operatorCnpj",self:getValue("operatorCnpj")) 
    oJsonControl:setProp(oJson,"corporateName",self:getValue("corporateName")) 
    oJsonControl:setProp(oJson,"tradeName",self:getValue("tradeName")) 
    oJsonControl:setProp(oJson,"legalNature",self:getValue("legalNature")) 
    oJsonControl:setProp(oJson,"operatorMode",self:getValue("operatorMode")) 
    oJsonControl:setProp(oJson,"operatorSegmentation",self:getValue("operatorSegmentation")) 

Return oJson

Method destroy() Class CenB8M
	_Super:destroy()
	DelClassIntF()
return