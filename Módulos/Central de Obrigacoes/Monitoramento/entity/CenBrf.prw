#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBrf - Tables Forms Processed
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBrf from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBrf
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBrf

	local oJson := JsonObject():New()
	default oJsonControl := CenJsonControl():New()

    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BRF_CODOPE */ 
    oJsonControl:setProp(oJson,"operatorFormNumber",self:getValue("operatorFormNumber")) /* Column BRF_NMGOPE */ 
    oJsonControl:setProp(oJson,"providerFormNumber",self:getValue("providerFormNumber")) /* Column BRF_NMGPRE */ 
    oJsonControl:setProp(oJson,"mainFormNumb",self:getValue("mainFormNumb")) /* Column BRF_NMGPRI */ 
    oJsonControl:setProp(oJson,"eventOrigin",self:getValue("eventOrigin")) /* Column BRF_OREVAT */ 
    oJsonControl:setProp(oJson,"hospRegime",self:getValue("hospRegime")) /* Column BRF_REGINT */ 
    oJsonControl:setProp(oJson,"ansRecordNumber",self:getValue("ansRecordNumber")) /* Column BRF_RGOPIN */ 
    oJsonControl:setProp(oJson,"hospitalizationRequest",self:getValue("hospitalizationRequest")) /* Column BRF_SOLINT */ 
    oJsonControl:setProp(oJson,"admissionType",self:getValue("admissionType")) /* Column BRF_TIPADM */ 
    oJsonControl:setProp(oJson,"serviceType",self:getValue("serviceType")) /* Column BRF_TIPATE */ 
    oJsonControl:setProp(oJson,"appointmentType",self:getValue("appointmentType")) /* Column BRF_TIPCON */ 
    oJsonControl:setProp(oJson,"invoicingTp",self:getValue("invoicingTp")) /* Column BRF_TIPFAT */ 
    oJsonControl:setProp(oJson,"hospTp",self:getValue("hospTp")) /* Column BRF_TIPINT */ 
    oJsonControl:setProp(oJson,"aEventType",self:getValue("aEventType")) /* Column BRF_TPEVAT */ 
    oJsonControl:setProp(oJson,"coPaymentTotalValue",self:getValue("coPaymentTotalValue")) /* Column BRF_VLTCOP */ 
    oJsonControl:setProp(oJson,"dailyRatesTotalValue",self:getValue("dailyRatesTotalValue")) /* Column BRF_VLTDIA */ 
    oJsonControl:setProp(oJson,"valuePaidSuppliers",self:getValue("valuePaidSuppliers")) /* Column BRF_VLTFOR */ 
    oJsonControl:setProp(oJson,"formDisallowanceValue",self:getValue("formDisallowanceValue")) /* Column BRF_VLTGLO */ 
    oJsonControl:setProp(oJson,"valuePaidForm",self:getValue("valuePaidForm")) /* Column BRF_VLTGUI */ 
    oJsonControl:setProp(oJson,"totalValueEntered",self:getValue("totalValueEntered")) /* Column BRF_VLTINF */ 
    oJsonControl:setProp(oJson,"materialsTotalValue",self:getValue("materialsTotalValue")) /* Column BRF_VLTMAT */ 
    oJsonControl:setProp(oJson,"medicationTotalValue",self:getValue("medicationTotalValue")) /* Column BRF_VLTMED */ 
    oJsonControl:setProp(oJson,"totalOpmeValue",self:getValue("totalOpmeValue")) /* Column BRF_VLTOPM */ 
    oJsonControl:setProp(oJson,"procedureTotalValuePai",self:getValue("procedureTotalValuePai")) /* Column BRF_VLTPGP */ 
    oJsonControl:setProp(oJson,"valueProcessed",self:getValue("valueProcessed")) /* Column BRF_VLTPRO */ 
    oJsonControl:setProp(oJson,"feesTotalValue",self:getValue("feesTotalValue")) /* Column BRF_VLTTAX */ 
    oJsonControl:setProp(oJson,"ownTableTotalValue",self:getValue("ownTableTotalValue")) /* Column BRF_VLTTBP */ 
    oJsonControl:setProp(oJson,"tissProviderVersion",self:getValue("tissProviderVersion")) /* Column BRF_VTISPR */ 
    oJsonControl:setProp(oJson,"providerCpfCnpj",self:getValue("providerCpfCnpj")) /* Column BRF_CPFCNP */ 
    oJsonControl:setProp(oJson,"authorizationDate",self:getValue("authorizationDate")) /* Column BRF_DATAUT */ 
    oJsonControl:setProp(oJson,"executionDate",self:getValue("executionDate")) /* Column BRF_DATREA */ 
    oJsonControl:setProp(oJson,"requestDate",self:getValue("requestDate")) /* Column BRF_DATSOL */ 
    oJsonControl:setProp(oJson,"escortDailyRates",self:getValue("escortDailyRates")) /* Column BRF_DIAACP */ 
    oJsonControl:setProp(oJson,"icuDailyRates",self:getValue("icuDailyRates")) /* Column BRF_DIAUTI */ 
    oJsonControl:setProp(oJson,"invoicingEndDate",self:getValue("invoicingEndDate")) /* Column BRF_DTFIFT */ 
    oJsonControl:setProp(oJson,"invoicingStartDate",self:getValue("invoicingStartDate")) /* Column BRF_DTINFT */ 
    oJsonControl:setProp(oJson,"paymentDt",self:getValue("paymentDt")) /* Column BRF_DTPAGT */ 
    oJsonControl:setProp(oJson,"collectionProtocolDate",self:getValue("collectionProtocolDate")) /* Column BRF_DTPROT */ 
    oJsonControl:setProp(oJson,"submissionMethod",self:getValue("submissionMethod")) /* Column BRF_FORENV */ 
    oJsonControl:setProp(oJson,"executerId",self:getValue("executerId")) /* Column BRF_IDEEXC */ 
    oJsonControl:setProp(oJson,"refundId",self:getValue("refundId")) /* Column BRF_IDEREE */ 
    oJsonControl:setProp(oJson,"presetValueIdent",self:getValue("presetValueIdent")) /* Column BRF_IDVLRP */ 
    oJsonControl:setProp(oJson,"newborn",self:getValue("newborn")) /* Column BRF_INAVIV */ 
    oJsonControl:setProp(oJson,"indicAccident",self:getValue("indicAccident")) /* Column BRF_INDACI */ 
    oJsonControl:setProp(oJson,"registration",self:getValue("registration")) /* Column BRF_MATRIC */ 
    oJsonControl:setProp(oJson,"outflowType",self:getValue("outflowType")) /* Column BRF_MOTSAI */ 
    oJsonControl:setProp(oJson,"cboSCode",self:getValue("cboSCode")) /* Column BRF_CBOS */ 
    oJsonControl:setProp(oJson,"icdDiagnosis1",self:getValue("icdDiagnosis1")) /* Column BRF_CDCID1 */ 
    oJsonControl:setProp(oJson,"icdDiagnosis2",self:getValue("icdDiagnosis2")) /* Column BRF_CDCID2 */ 
    oJsonControl:setProp(oJson,"icdDiagnosis3",self:getValue("icdDiagnosis3")) /* Column BRF_CDCID3 */ 
    oJsonControl:setProp(oJson,"icdDiagnosis4",self:getValue("icdDiagnosis4")) /* Column BRF_CDCID4 */ 
    oJsonControl:setProp(oJson,"executingCityCode",self:getValue("executingCityCode")) /* Column BRF_CDMNEX */ 
    oJsonControl:setProp(oJson,"cnes",self:getValue("cnes")) /* Column BRF_CNES */ 

Return oJson

Method destroy() Class CenBrf
	_Super:destroy()
	DelClassIntF()
return