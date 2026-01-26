#include "TOTVS.CH"

Class CenMprBra from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBra
    _Super:new()

    aAdd(self:aFields,{"BRA_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BRA_SEQGUI" ,"formSequential"})
    aAdd(self:aFields,{"BRA_SOLINT" ,"hospitalizationRequest"})
    aAdd(self:aFields,{"BRA_TIPADM" ,"admissionType"})
    aAdd(self:aFields,{"BRA_TIPATE" ,"serviceType"})
    aAdd(self:aFields,{"BRA_TIPCON" ,"appointmentType"})
    aAdd(self:aFields,{"BRA_TIPFAT" ,"invoicingTp"})
    aAdd(self:aFields,{"BRA_TIPINT" ,"hospTp"})
    aAdd(self:aFields,{"BRA_TPEVAT" ,"aEventType"})
    aAdd(self:aFields,{"BRA_VTISPR" ,"tissProviderVersion"})
    aAdd(self:aFields,{"BRA_CBOS" ,"cboSCode"})
    aAdd(self:aFields,{"BRA_CDCID1" ,"icdDiagnosis1"})
    aAdd(self:aFields,{"BRA_CDCID2" ,"icdDiagnosis2"})
    aAdd(self:aFields,{"BRA_CDCID3" ,"icdDiagnosis3"})
    aAdd(self:aFields,{"BRA_CDCID4" ,"icdDiagnosis4"})
    aAdd(self:aFields,{"BRA_CDMNEX" ,"executingCityCode"})
    aAdd(self:aFields,{"BRA_CNES" ,"cnes"})
    aAdd(self:aFields,{"BRA_CPFCNP" ,"providerCpfCnpj"})
    aAdd(self:aFields,{"BRA_DATAUT" ,"authorizationDate"})
    aAdd(self:aFields,{"BRA_DATINC" ,"inclusionDate"})
    aAdd(self:aFields,{"BRA_DATREA" ,"executionDate"})
    aAdd(self:aFields,{"BRA_DATSOL" ,"requestDate"})
    aAdd(self:aFields,{"BRA_DIAACP" ,"escortDailyRates"})
    aAdd(self:aFields,{"BRA_DIAUTI" ,"icuDailyRates"})
    aAdd(self:aFields,{"BRA_DTFIFT" ,"invoicingEndDate"})
    aAdd(self:aFields,{"BRA_DTINFT" ,"invoicingStartDate"})
    aAdd(self:aFields,{"BRA_DTPAGT" ,"paymentDt"})
    aAdd(self:aFields,{"BRA_DTPRGU" ,"formProcDt"})
    aAdd(self:aFields,{"BRA_DTPROT" ,"collectionProtocolDate"})
    aAdd(self:aFields,{"BRA_EXCLU" ,"exclusionId"})
    aAdd(self:aFields,{"BRA_FORENV" ,"submissionMethod"})
    aAdd(self:aFields,{"BRA_HORINC" ,"inclusionTime"})
    aAdd(self:aFields,{"BRA_IDEEXC" ,"executerId"})
    aAdd(self:aFields,{"BRA_IDEREE" ,"refundId"})
    aAdd(self:aFields,{"BRA_IDVLRP" ,"presetValueIdent"})
    aAdd(self:aFields,{"BRA_INAVIV" ,"newborn"})
    aAdd(self:aFields,{"BRA_INDACI" ,"indicAccident"})
    aAdd(self:aFields,{"BRA_MATRIC" ,"registration"})
    aAdd(self:aFields,{"BRA_MOTSAI" ,"outflowType"})
    aAdd(self:aFields,{"BRA_NMGOPE" ,"operatorFormNumber"})
    aAdd(self:aFields,{"BRA_NMGPRE" ,"providerFormNumber"})
    aAdd(self:aFields,{"BRA_NMGPRI" ,"mainFormNumb"})
    aAdd(self:aFields,{"BRA_OREVAT" ,"eventOrigin"})
    aAdd(self:aFields,{"BRA_PROCES" ,"processed"})
    aAdd(self:aFields,{"BRA_REGINT" ,"hospRegime"})
    aAdd(self:aFields,{"BRA_RGOPIN" ,"ansRecordNumber"})
    aAdd(self:aFields,{"BRA_ROBOID" ,"roboId"})

    aAdd(self:aExpand,{"monitFormEvents","monitFormCertificates"})

Return self
