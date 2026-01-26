#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade PlsBNV
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class PlsBNV from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class PlsBNV
	_Super:New()
Return self

Method serialize(oJsonControl) Class PlsBNV

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"code" ,self:getValue("code")) /* Column BNV_CODIGO */
    oJsonControl:setProp(oJson,"transactionCode" ,self:getValue("transactionCode")) /* Column BNV_CODTRA */
    oJsonControl:setProp(oJson,"key",self:getValue("key")) /* Column BNV_CHAVE" */
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BNV_STATUS */
    oJsonControl:setProp(oJson,"alias",self:getValue("alias")) /* Column BNV_ALIAS" */
    oJsonControl:setProp(oJson,"fields",self:getValue("fields")) /* Column BNV_CAMPOS */
    oJsonControl:setProp(oJson,"creationDate",self:getValue("creationDate")) /* Column BNV_DATCRI */
    oJsonControl:setProp(oJson,"creationTime",self:getValue("creationTime")) /* Column BNV_HORCRI */
    oJsonControl:setProp(oJson,"substOrder",self:getValue("substOrder")) /* Column BNV_PEDSUB */
    //oJsonControl:setProp(oJson,"json",self:getValue("json")) /* Column BNV_JSON  */
    oJsonControl:setProp(oJson,"token",self:getValue("token")) /* Column BNV_TOKEN" */
    oJsonControl:setProp(oJson,"integrationID",self:getValue("integrationID")) /* Column BNV_IDINT" */
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BNV_CODOPE */
    oJsonControl:setProp(oJson,"roboId",self:getValue("roboId")) /* Column BNV_ROBOID */
    oJsonControl:setProp(oJson,"numberAttempts",self:getValue("numberAttempts")) /* Column BNV_QTDTRY */
    
Return oJson

Method destroy() Class PlsBNV
	_Super:destroy()
	DelClassIntF()
return