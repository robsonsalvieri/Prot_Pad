#include "TOTVS.CH"

Class CenMprB2U from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB2U
    _Super:new()

    aAdd(self:aFields,{"B2U_CODOPE" ,"healthInsurerCode"})
    aAdd(self:aFields,{"B2U_CODOBR" ,"requirementCode"})
    aAdd(self:aFields,{"B2U_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B2U_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B2U_ANOCAL" ,"calendarYear"})
    aAdd(self:aFields,{"B2U_DATARQ" ,"fileDate"})
    aAdd(self:aFields,{"B2U_HORARQ" ,"fileTime"})
    aAdd(self:aFields,{"B2U_NOMARQ" ,"fileName"})
    aAdd(self:aFields,{"B2U_REFERE" ,"reference"})
    aAdd(self:aFields,{"B2U_RECRET" ,"correctedReceiptNumber"})
    aAdd(self:aFields,{"B2U_STATUS" ,"status"})
    aAdd(self:aFields,{"B2U_NUMREC" ,"receiptNumber"})
    aAdd(self:aFields,{"B2U_USRDEL" ,"userDeleted"})
    aAdd(self:aFields,{"B2U_DTHDEL" ,"timeDeleted"})

Return self
