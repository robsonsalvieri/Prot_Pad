#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBkw - Batches
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBkw from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBkw
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBkw

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()


    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BKW_CODOPE */ 
    oJsonControl:setProp(oJson,"batchCode",self:getValue("batchCode")) /* Column BKW_CODLOT */ 
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column BKW_CDOBRI */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BKW_CDCOMP */ 
    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear")) /* Column BKW_ANO    */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BKW_STATUS */ 
    oJsonControl:setProp(oJson,"remunerationType",self:getValue("remunerationType")) /* Column BKW_FORREM */ 
    oJsonControl:setProp(oJson,"file",self:getValue("file")) /* Column BKW_ARQUIV */ 
    oJsonControl:setProp(oJson,"processingDate",self:getValue("processingDate")) /* Column BKW_DATPRO */ 
    oJsonControl:setProp(oJson,"processingTime",self:getValue("processingTime")) /* Column BKW_HORPRO */ 
    oJsonControl:setProp(oJson,"version",self:getValue("version")) /* Column BKW_VERSAO */ 
	oJsonControl:setProp(oJson,"xsdError",self:getValue("xsdError")) /* Column BKW_ERRXSD */ 
	oJsonControl:setProp(oJson,"includedRecords",self:getValue("includedRecords")) /* Column BKW_REGINC */ 
    oJsonControl:setProp(oJson,"changedRecords",self:getValue("changedRecords")) /* Column BKW_REGALT */ 
    oJsonControl:setProp(oJson,"deletedRecords",self:getValue("deletedRecords")) /* Column BKW_REGEXC */ 
    oJsonControl:setProp(oJson,"incorrectRecords",self:getValue("incorrectRecords")) /* Column BKW_REGERR */

Return oJson

Method destroy() Class CenBkw
	_Super:destroy()
	DelClassIntF()
return