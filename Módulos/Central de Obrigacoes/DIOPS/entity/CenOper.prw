#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenOper - Operators
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenOper from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenOper
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenOper

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"operatorCnpj",self:getValue("operatorCnpj")) /* Column B8M_CNPJOP */ 
    oJsonControl:setProp(oJson,"providerRegister",self:getValue("providerRegister")) /* Column B8M_CODOPE */ 
    oJsonControl:setProp(oJson,"operatorMode",self:getValue("operatorMode")) /* Column B8M_MODALI */ 
    oJsonControl:setProp(oJson,"legalNature",self:getValue("legalNature")) /* Column B8M_NATJUR */ 
    oJsonControl:setProp(oJson,"tradeName",self:getValue("tradeName")) /* Column B8M_NOMFAN */ 
    oJsonControl:setProp(oJson,"corporateName",self:getValue("corporateName")) /* Column B8M_RAZSOC */ 
    oJsonControl:setProp(oJson,"operatorSegmentation",self:getValue("operatorSegmentation")) /* Column B8M_SEGMEN */ 

Return oJson

Method destroy() Class CenOper
	_Super:destroy()
	DelClassIntF()
return