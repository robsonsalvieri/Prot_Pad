#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBnw - BirthDeath Certificates Temp
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBnw from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBnw
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBnw

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BNW_CODOPE */ 
    oJsonControl:setProp(oJson,"certificateNumber",self:getValue("certificateNumber")) /* Column BNW_DECNUM */ 
    oJsonControl:setProp(oJson,"formSequential",self:getValue("formSequential")) /* Column BNW_SEQGUI */ 
    oJsonControl:setProp(oJson,"certificateType",self:getValue("certificateType")) /* Column BNW_TIPO */ 

Return oJson

Method destroy() Class CenBnw
	_Super:destroy()
	DelClassIntF()
return