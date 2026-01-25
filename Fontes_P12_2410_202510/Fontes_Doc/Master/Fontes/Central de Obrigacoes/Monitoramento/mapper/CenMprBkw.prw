#include "TOTVS.CH"

Class CenMprBkw from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBkw
    _Super:new()

    aAdd(self:aFields,{"BKW_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BKW_CODLOT" ,"batchCode"})
    aAdd(self:aFields,{"BKW_CDOBRI" ,"requirementCode"})
    aAdd(self:aFields,{"BKW_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BKW_ANO   " ,"referenceYear"})
    aAdd(self:aFields,{"BKW_STATUS" ,"status"})
    aAdd(self:aFields,{"BKW_FORREM" ,"remunerationType"})
    aAdd(self:aFields,{"BKW_ARQUIV" ,"file"})
    aAdd(self:aFields,{"BKW_DATPRO" ,"processingDate"})
    aAdd(self:aFields,{"BKW_HORPRO" ,"processingTime"})
    aAdd(self:aFields,{"BKW_VERSAO" ,"version"})
    aAdd(self:aFields,{"BKW_ERRXSD" ,"xsdError"})
    aAdd(self:aFields,{"BKW_REGINC" ,"includedRecords"})
    aAdd(self:aFields,{"BKW_REGALT" ,"changedRecords"})
    aAdd(self:aFields,{"BKW_REGEXC" ,"deletedRecords"})
    aAdd(self:aFields,{"BKW_REGERR" ,"incorrectRecords"})


Return self
