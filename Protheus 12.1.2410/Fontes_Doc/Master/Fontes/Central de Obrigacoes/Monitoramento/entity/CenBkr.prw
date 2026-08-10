#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBkr - Cab Form Transac Api Monit
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBkr from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()
    Method getIdeOri()
    Method getDesOri()

EndClass

Method New() Class CenBkr
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBkr

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"referenceYear",self:getValue("referenceYear")) /* Column BKR_ANO */ 
    oJsonControl:setProp(oJson,"commitmentCode",self:getValue("commitmentCode")) /* Column BKR_CDCOMP */ 
    oJsonControl:setProp(oJson,"requirementCode",self:getValue("requirementCode")) /* Column BKR_CDOBRI */ 
    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BKR_CODOPE */ 
    oJsonControl:setProp(oJson,"operatorFormNumber",self:getValue("operatorFormNumber")) /* Column BKR_NMGOPE */ 
    oJsonControl:setProp(oJson,"formProcDt",self:getValue("formProcDt")) /* Column BKR_DTPRGU */ 
    oJsonControl:setProp(oJson,"batchCode",self:getValue("batchCode")) /* Column BKR_LOTE */ 
    oJsonControl:setProp(oJson,"registration",self:getValue("registration")) /* Column BKR_MATRIC */ 
    oJsonControl:setProp(oJson,"outflowType",self:getValue("outflowType")) /* Column BKR_MOTSAI */ 
    oJsonControl:setProp(oJson,"collectionProtocolDate",self:getValue("collectionProtocolDate")) /* Column BKR_DTPROT */ 
    oJsonControl:setProp(oJson,"submissionMethod",self:getValue("submissionMethod")) /* Column BKR_FORENV */ 
    oJsonControl:setProp(oJson,"inclusionTime",self:getValue("inclusionTime")) /* Column BKR_HORINC */ 
    oJsonControl:setProp(oJson,"processingTime",self:getValue("processingTime")) /* Column BKR_HORPRO */ 
    oJsonControl:setProp(oJson,"executerId",self:getValue("executerId")) /* Column BKR_IDEEXC */ 
    oJsonControl:setProp(oJson,"refundId",self:getValue("refundId")) /* Column BKR_IDEREE */ 
    oJsonControl:setProp(oJson,"presetValueIdent",self:getValue("presetValueIdent")) /* Column BKR_IDVLRP */ 
    oJsonControl:setProp(oJson,"newborn",self:getValue("newborn")) /* Column BKR_INAVIV */ 
    oJsonControl:setProp(oJson,"indicAccident",self:getValue("indicAccident")) /* Column BKR_INDACI */ 
    oJsonControl:setProp(oJson,"providerFormNumber",self:getValue("providerFormNumber")) /* Column BKR_NMGPRE */ 
    oJsonControl:setProp(oJson,"mainFormNumb",self:getValue("mainFormNumb")) /* Column BKR_NMGPRI */ 
    oJsonControl:setProp(oJson,"eventOrigin",self:getValue("eventOrigin")) /* Column BKR_OREVAT */ 
    oJsonControl:setProp(oJson,"hospRegime",self:getValue("hospRegime")) /* Column BKR_REGINT */ 
    oJsonControl:setProp(oJson,"ansRecordNumber",self:getValue("ansRecordNumber")) /* Column BKR_RGOPIN */ 
    oJsonControl:setProp(oJson,"hospitalizationRequest",self:getValue("hospitalizationRequest")) /* Column BKR_SOLINT */ 
    oJsonControl:setProp(oJson,"status",self:getValue("status")) /* Column BKR_STATUS */ 
    oJsonControl:setProp(oJson,"admissionType",self:getValue("admissionType")) /* Column BKR_TIPADM */ 
    oJsonControl:setProp(oJson,"serviceType",self:getValue("serviceType")) /* Column BKR_TIPATE */ 
    oJsonControl:setProp(oJson,"appointmentType",self:getValue("appointmentType")) /* Column BKR_TIPCON */ 
    oJsonControl:setProp(oJson,"invoicingTp",self:getValue("invoicingTp")) /* Column BKR_TIPFAT */ 
    oJsonControl:setProp(oJson,"hospTp",self:getValue("hospTp")) /* Column BKR_TIPINT */ 
    oJsonControl:setProp(oJson,"aEventType",self:getValue("aEventType")) /* Column BKR_TPEVAT */ 
    oJsonControl:setProp(oJson,"monitoringRecordType",self:getValue("monitoringRecordType")) /* Column BKR_TPRGMN */ 
    oJsonControl:setProp(oJson,"coPaymentTotalValue",self:getValue("coPaymentTotalValue")) /* Column BKR_VLTCOP */ 
    oJsonControl:setProp(oJson,"dailyRatesTotalValue",self:getValue("dailyRatesTotalValue")) /* Column BKR_VLTDIA */ 
    oJsonControl:setProp(oJson,"valuePaidSuppliers",self:getValue("valuePaidSuppliers")) /* Column BKR_VLTFOR */ 
    oJsonControl:setProp(oJson,"formDisallowanceValue",self:getValue("formDisallowanceValue")) /* Column BKR_VLTGLO */ 
    oJsonControl:setProp(oJson,"valuePaidForm",self:getValue("valuePaidForm")) /* Column BKR_VLTGUI */ 
    oJsonControl:setProp(oJson,"totalValueEntered",self:getValue("totalValueEntered")) /* Column BKR_VLTINF */ 
    oJsonControl:setProp(oJson,"materialsTotalValue",self:getValue("materialsTotalValue")) /* Column BKR_VLTMAT */ 
    oJsonControl:setProp(oJson,"medicationTotalValue",self:getValue("medicationTotalValue")) /* Column BKR_VLTMED */ 
    oJsonControl:setProp(oJson,"totalOpmeValue",self:getValue("totalOpmeValue")) /* Column BKR_VLTOPM */ 
    oJsonControl:setProp(oJson,"procedureTotalValuePai",self:getValue("procedureTotalValuePai")) /* Column BKR_VLTPGP */ 
    oJsonControl:setProp(oJson,"valueProcessed",self:getValue("valueProcessed")) /* Column BKR_VLTPRO */ 
    oJsonControl:setProp(oJson,"feesTotalValue",self:getValue("feesTotalValue")) /* Column BKR_VLTTAX */ 
    oJsonControl:setProp(oJson,"ownTableTotalValue",self:getValue("ownTableTotalValue")) /* Column BKR_VLTTBP */ 
    oJsonControl:setProp(oJson,"tissProviderVersion",self:getValue("tissProviderVersion")) /* Column BKR_VTISPR */ 
    oJsonControl:setProp(oJson,"providerCpfCnpj",self:getValue("providerCpfCnpj")) /* Column BKR_CPFCNP */ 
    oJsonControl:setProp(oJson,"authorizationDate",self:getValue("authorizationDate")) /* Column BKR_DATAUT */ 
    oJsonControl:setProp(oJson,"inclusionDate",self:getValue("inclusionDate")) /* Column BKR_DATINC */ 
    oJsonControl:setProp(oJson,"processingDate",self:getValue("processingDate")) /* Column BKR_DATPRO */ 
    oJsonControl:setProp(oJson,"executionDate",self:getValue("executionDate")) /* Column BKR_DATREA */ 
    oJsonControl:setProp(oJson,"requestDate",self:getValue("requestDate")) /* Column BKR_DATSOL */ 
    oJsonControl:setProp(oJson,"escortDailyRates",self:getValue("escortDailyRates")) /* Column BKR_DIAACP */ 
    oJsonControl:setProp(oJson,"icuDailyRates",self:getValue("icuDailyRates")) /* Column BKR_DIAUTI */ 
    oJsonControl:setProp(oJson,"invoicingEndDate",self:getValue("invoicingEndDate")) /* Column BKR_DTFIFT */ 
    oJsonControl:setProp(oJson,"invoicingStartDate",self:getValue("invoicingStartDate")) /* Column BKR_DTINFT */ 
    oJsonControl:setProp(oJson,"paymentDt",self:getValue("paymentDt")) /* Column BKR_DTPAGT */ 
    oJsonControl:setProp(oJson,"cnes",self:getValue("cnes")) /* Column BKR_CNES */ 
    oJsonControl:setProp(oJson,"executingCityCode",self:getValue("executingCityCode")) /* Column BKR_CDMNEX */ 
    oJsonControl:setProp(oJson,"cboSCode",self:getValue("cboSCode")) /* Column BKR_CBOS */ 
    oJsonControl:setProp(oJson,"icdDiagnosis1",self:getValue("icdDiagnosis1")) /* Column BKR_CDCID1 */ 
    oJsonControl:setProp(oJson,"icdDiagnosis2",self:getValue("icdDiagnosis2")) /* Column BKR_CDCID2 */ 
    oJsonControl:setProp(oJson,"icdDiagnosis3",self:getValue("icdDiagnosis3")) /* Column BKR_CDCID3 */ 
    oJsonControl:setProp(oJson,"icdDiagnosis4",self:getValue("icdDiagnosis4")) /* Column BKR_CDCID4 */ 

Return oJson

Method destroy() Class CenBkr
	_Super:destroy()
	DelClassIntF()
return

Method getIdeOri() Class CenBkr
Return BKR->(BKR_CODOPE+BKR_NMGOPE+BKR_CDOBRI+BKR_ANO+BKR_CDCOMP+BKR_LOTE+DtoS(BKR_DTPRGU))

Method getDesOri() Class CenBkr
Return BKR->BKR_LOTE