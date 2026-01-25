#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB2V - Other RemunerationAPI
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB2V from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB2V
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB2V

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"formSequential",self:getValue("formSequential")) /* Column B2V_SEQUEN */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column B2V_CODOPE */ 
    oJsonControl:setProp(oJson,"providerCpfCnpj",self:getValue("providerCpfCnpj")) /* Column B2V_CPFCNP */ 
    oJsonControl:setProp(oJson,"formProcDt",self:getValue("formProcDt")) /* Column B2V_DTPROC */ 
    oJsonControl:setProp(oJson,"totalDisallowValue",self:getValue("totalDisallowValue")) /* Column B2V_VLTGLO */ 
    oJsonControl:setProp(oJson,"totalValueEntered",self:getValue("totalValueEntered")) /* Column B2V_VLTINF */ 
    oJsonControl:setProp(oJson,"totalValuePaid",self:getValue("totalValuePaid")) /* Column B2V_VLTPAG */ 
    oJsonControl:setProp(oJson,"exclusionId",self:getValue("exclusionId")) /* Column B2V_EXCLU */ 
    oJsonControl:setProp(oJson,"inclusionTime",self:getValue("inclusionTime")) /* Column B2V_HORINC */ 
    oJsonControl:setProp(oJson,"identReceipt",self:getValue("identReceipt")) /* Column B2V_IDEREC */ 
    oJsonControl:setProp(oJson,"inclusionDate",self:getValue("inclusionDate")) /* Column B2V_DATINC */ 
    oJsonControl:setProp(oJson,"processed",self:getValue("processed")) /* Column B2V_PROCES */ 
    oJsonControl:setProp(oJson,"roboId",self:getValue("roboId")) /* Column B2V_ROBOID */ 

Return oJson

Method destroy() Class CenB2V
	_Super:destroy()
	DelClassIntF()
return