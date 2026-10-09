#include "TOTVS.CH"

Class CenMprPact from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprPact
    _Super:new()

    aAdd(self:aFields,{"BUY_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BUY_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"BUY_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"BUY_CONTA" ,"accountCode"})
    aAdd(self:aFields,{"BUY_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"BUY_ATUMON" ,"monetaryUpdate"})
    aAdd(self:aFields,{"BUY_DTCOMP" ,"competenceDate"})
    aAdd(self:aFields,{"BUY_REFERE" ,"trimester"})
    aAdd(self:aFields,{"BUY_SLDFIN" ,"balanceAtTheEndOfThe"})
    aAdd(self:aFields,{"BUY_STATUS" ,"status"})
    aAdd(self:aFields,{"BUY_VLRINI" ,"initialValue"})
    aAdd(self:aFields,{"BUY_VLRPAG" ,"valuePaid"})

Return self
