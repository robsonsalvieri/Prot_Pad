#include "TOTVS.CH"

Class CenMprBlct from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBlct
    _Super:new()

    aAdd(self:aFields,{"B8A_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8A_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8A_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8A_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8A_CONTA" ,"accountCode"})
    aAdd(self:aFields,{"B8A_CREDIT" ,"credits"})
    aAdd(self:aFields,{"B8A_DEBITO" ,"debits"})
    aAdd(self:aFields,{"B8A_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B8A_SALANT" ,"previousBalance"})
    aAdd(self:aFields,{"B8A_SALFIN" ,"finalBalance"})
    aAdd(self:aFields,{"B8A_STATUS" ,"status"})

Return self
