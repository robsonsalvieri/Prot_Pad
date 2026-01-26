#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenBra - monitForm
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenBra from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenBra
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenBra

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()

    oJson["_expandables"] := {"monitFormEvents","monitFormCertificates"}

    oJsonControl:setProp(oJson,"operatorRecord",self:getValue("operatorRecord")) /* Column BRA_CODOPE */ 
    oJsonControl:setProp(oJson,"formSequential",self:getValue("formSequential")) /* Column BRA_SEQGUI */ 
    oJsonControl:setProp(oJson,"hospitalizationRequest",self:getValue("hospitalizationRequest")) /* Column BRA_SOLINT */ 
    oJsonControl:setProp(oJson,"admissionType",self:getValue("admissionType")) /* Column BRA_TIPADM */ 
    oJsonControl:setProp(oJson,"serviceType",self:getValue("serviceType")) /* Column BRA_TIPATE */ 
    oJsonControl:setProp(oJson,"appointmentType",self:getValue("appointmentType")) /* Column BRA_TIPCON */ 
    oJsonControl:setProp(oJson,"invoicingTp",self:getValue("invoicingTp")) /* Column BRA_TIPFAT */ 
    oJsonControl:setProp(oJson,"hospTp",self:getValue("hospTp")) /* Column BRA_TIPINT */ 
    oJsonControl:setProp(oJson,"aEventType",self:getValue("aEventType")) /* Column BRA_TPEVAT */ 
    oJsonControl:setProp(oJson,"tissProviderVersion",self:getValue("tissProviderVersion")) /* Column BRA_VTISPR */ 
    oJsonControl:setProp(oJson,"cboSCode",self:getValue("cboSCode")) /* Column BRA_CBOS */ 
    oJsonControl:setProp(oJson,"icdDiagnosis1",self:getValue("icdDiagnosis1")) /* Column BRA_CDCID1 */ 
    oJsonControl:setProp(oJson,"icdDiagnosis2",self:getValue("icdDiagnosis2")) /* Column BRA_CDCID2 */ 
    oJsonControl:setProp(oJson,"icdDiagnosis3",self:getValue("icdDiagnosis3")) /* Column BRA_CDCID3 */ 
    oJsonControl:setProp(oJson,"icdDiagnosis4",self:getValue("icdDiagnosis4")) /* Column BRA_CDCID4 */ 
    oJsonControl:setProp(oJson,"executingCityCode",self:getValue("executingCityCode")) /* Column BRA_CDMNEX */ 
    oJsonControl:setProp(oJson,"cnes",self:getValue("cnes")) /* Column BRA_CNES */ 
    oJsonControl:setProp(oJson,"providerCpfCnpj",self:getValue("providerCpfCnpj")) /* Column BRA_CPFCNP */ 
    oJsonControl:setProp(oJson,"authorizationDate",self:getValue("authorizationDate")) /* Column BRA_DATAUT */ 
    oJsonControl:setProp(oJson,"inclusionDate",self:getValue("inclusionDate")) /* Column BRA_DATINC */ 
    oJsonControl:setProp(oJson,"executionDate",self:getValue("executionDate")) /* Column BRA_DATREA */ 
    oJsonControl:setProp(oJson,"requestDate",self:getValue("requestDate")) /* Column BRA_DATSOL */ 
    oJsonControl:setProp(oJson,"escortDailyRates",self:getValue("escortDailyRates")) /* Column BRA_DIAACP */ 
    oJsonControl:setProp(oJson,"icuDailyRates",self:getValue("icuDailyRates")) /* Column BRA_DIAUTI */ 
    oJsonControl:setProp(oJson,"invoicingEndDate",self:getValue("invoicingEndDate")) /* Column BRA_DTFIFT */ 
    oJsonControl:setProp(oJson,"invoicingStartDate",self:getValue("invoicingStartDate")) /* Column BRA_DTINFT */ 
    oJsonControl:setProp(oJson,"paymentDt",self:getValue("paymentDt")) /* Column BRA_DTPAGT */ 
    oJsonControl:setProp(oJson,"formProcDt",self:getValue("formProcDt")) /* Column BRA_DTPRGU */ 
    oJsonControl:setProp(oJson,"collectionProtocolDate",self:getValue("collectionProtocolDate")) /* Column BRA_DTPROT */ 
    oJsonControl:setProp(oJson,"exclusionId",self:getValue("exclusionId")) /* Column BRA_EXCLU */ 
    oJsonControl:setProp(oJson,"submissionMethod",self:getValue("submissionMethod")) /* Column BRA_FORENV */ 
    oJsonControl:setProp(oJson,"inclusionTime",self:getValue("inclusionTime")) /* Column BRA_HORINC */ 
    oJsonControl:setProp(oJson,"executerId",self:getValue("executerId")) /* Column BRA_IDEEXC */ 
    oJsonControl:setProp(oJson,"refundId",self:getValue("refundId")) /* Column BRA_IDEREE */ 
    oJsonControl:setProp(oJson,"presetValueIdent",self:getValue("presetValueIdent")) /* Column BRA_IDVLRP */ 
    oJsonControl:setProp(oJson,"newborn",self:getValue("newborn")) /* Column BRA_INAVIV */ 
    oJsonControl:setProp(oJson,"indicAccident",self:getValue("indicAccident")) /* Column BRA_INDACI */ 
    oJsonControl:setProp(oJson,"registration",self:getValue("registration")) /* Column BRA_MATRIC */ 
    oJsonControl:setProp(oJson,"outflowType",self:getValue("outflowType")) /* Column BRA_MOTSAI */ 
    oJsonControl:setProp(oJson,"operatorFormNumber",self:getValue("operatorFormNumber")) /* Column BRA_NMGOPE */ 
    oJsonControl:setProp(oJson,"providerFormNumber",self:getValue("providerFormNumber")) /* Column BRA_NMGPRE */ 
    oJsonControl:setProp(oJson,"mainFormNumb",self:getValue("mainFormNumb")) /* Column BRA_NMGPRI */ 
    oJsonControl:setProp(oJson,"eventOrigin",self:getValue("eventOrigin")) /* Column BRA_OREVAT */ 
    oJsonControl:setProp(oJson,"processed",self:getValue("processed")) /* Column BRA_PROCES */ 
    oJsonControl:setProp(oJson,"hospRegime",self:getValue("hospRegime")) /* Column BRA_REGINT */ 
    oJsonControl:setProp(oJson,"ansRecordNumber",self:getValue("ansRecordNumber")) /* Column BRA_RGOPIN */ 
    oJsonControl:setProp(oJson,"roboId",self:getValue("roboId")) /* Column BRA_ROBOID */ 

Return oJson

Method destroy() Class CenBra
	_Super:destroy()
	DelClassIntF()
return