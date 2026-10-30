#include "TOTVS.CH"

Class CenMprCoes from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprCoes
    _Super:new()

    aAdd(self:aFields,{"BUP_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"BUP_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BUP_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"BUP_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"BUP_OPECOE" ,"operatorRecordInAns"})
    aAdd(self:aFields,{"BUP_REFERE" ,"trimester"})
    aAdd(self:aFields,{"BUP_STATUS" ,"status"})
    aAdd(self:aFields,{"BUP_VLRFAT" ,"billingValue"})

Return self
