#include "TOTVS.CH"

Class CenMprB5I from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB5I
    _Super:new()

    aAdd(self:aFields,{"B5I_CODOPE" ,"ansRegister"})
    aAdd(self:aFields,{"B5I_CMPLOT" ,"batchPeriod"})
    aAdd(self:aFields,{"B5I_NUMLOT" ,"batchNumber"})
    aAdd(self:aFields,{"B5I_TPTRAN" ,"transactionType"})
    aAdd(self:aFields,{"B5I_DATPRO" ,"processingDate"})
    aAdd(self:aFields,{"B5I_HORPRO" ,"processingTime"})
    aAdd(self:aFields,{"B5I_VERPAD" ,"defaultVersion"})
    aAdd(self:aFields,{"B5I_ARQUIV" ,"qualityFile"})
    aAdd(self:aFields,{"B5I_STATUS" ,"status"})


Return self
