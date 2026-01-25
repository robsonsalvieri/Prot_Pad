#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBny - BirthDeath Certificates Api
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBny from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBny
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBny

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BNY_CODOPE */ 
    oJsonControl:setProp(oJson,"certificateNumber",self:getValue("certificateNumber")) /* Column BNY_DECNUM */ 
    oJsonControl:setProp(oJson,"operatorFormNumber",self:getValue("operatorFormNumber")) /* Column BNY_NMGOPE */ 
    oJsonControl:setProp(oJson,"certificateType",self:getValue("certificateType")) /* Column BNY_TIPO */ 

Return oJson

Method destroy() Class CenBny
	_Super:destroy()
	DelClassIntF()
return