#include "TOTVS.CH"

Class CenMprLcpr from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprLcpr
    _Super:new()

    aAdd(self:aFields,{"B8E_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8E_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8E_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8E_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8E_CONTA" ,"accountCode"})
    aAdd(self:aFields,{"B8E_DESCRI" ,"description"})
    aAdd(self:aFields,{"B8E_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B8E_STATUS" ,"status"})
    aAdd(self:aFields,{"B8E_VLRCON" ,"accountingValue"})

Return self
