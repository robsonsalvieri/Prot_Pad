#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBkt - Movement Package Api Monit
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBkt from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()
    Method getIdeOri()
    Method getDesOri()

EndClass

Method New() Class CenBkt
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBkt

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear")) /* Column BKT_ANO */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BKT_CDCOMP */ 
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column BKT_CDOBRI */ 
    oJsonControl:setProp(oJson,"itemProCode",self:getValue("itemProCode")) /* Column BKT_CDPRIT */ 
    oJsonControl:setProp(oJson,"itemTableCode",self:getValue("itemTableCode")) /* Column BKT_CDTBIT */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BKT_CODOPE */ 
    oJsonControl:setProp(oJson,"procedureCode",self:getValue("procedureCode")) /* Column BKT_CODPRO */ 
    oJsonControl:setProp(oJson,"tableCode",self:getValue("tableCode")) /* Column BKT_CODTAB */ 
    oJsonControl:setProp(oJson,"formProcDt",self:getValue("formProcDt")) /* Column BKT_DTPRGU */ 
    oJsonControl:setProp(oJson,"batchCode",self:getValue("batchCode")) /* Column BKT_LOTE */ 
    oJsonControl:setProp(oJson,"operatorFormNumber",self:getValue("operatorFormNumber")) /* Column BKT_NMGOPE */ 
    oJsonControl:setProp(oJson,"packageQuantity",self:getValue("packageQuantity")) /* Column BKT_QTPRPC */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BKT_STATUS */ 

Return oJson

Method destroy() Class CenBkt
	_Super:destroy()
	DelClassIntF()
return

Method getIdeOri() Class CenBkt
Return BKT->(BKT_CODOPE+BKT_NMGOPE+BKT_CDOBRI+BKT_ANO+BKT_CDCOMP+BKT_LOTE)+DTOS(BKT->BKT_DTPRGU)+BKT->(BKT_CODTAB+BKT_CODPRO+BKT_CDTBIT+BKT_CDPRIT)

Method getDesOri() Class CenBkt
Return BKT->BKT_LOTE