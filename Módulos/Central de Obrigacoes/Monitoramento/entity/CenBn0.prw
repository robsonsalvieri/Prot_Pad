#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBn0 - BirthDeath Certificates Trans
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBn0 from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBn0
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBn0

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear")) /* Column BN0_ANO */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BN0_CDCOMP */ 
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column BN0_CDOBRI */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BN0_CODOPE */ 
    oJsonControl:setProp(oJson,"formProcDt",self:getValue("formProcDt")) /* Column BN0_DTPRGU */ 
    oJsonControl:setProp(oJson,"batchCode",self:getValue("batchCode")) /* Column BN0_LOTE */ 
    oJsonControl:setProp(oJson,"operatorFormNumber",self:getValue("operatorFormNumber")) /* Column BN0_NMGOPE */ 
    oJsonControl:setProp(oJson,"certificateType",self:getValue("certificateType")) /* Column BN0_TIPO */ 
    oJsonControl:setProp(oJson,"certificateNumber",self:getValue("certificateNumber")) /* Column BN0_DECNUM */ 

Return oJson

Method destroy() Class CenBn0
	_Super:destroy()
	DelClassIntF()
return