#include "TOTVS.CH"

Class CenMprFlcx from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprFlcx
    _Super:new()

    aAdd(self:aFields,{"B8H_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8H_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8H_CODIGO" ,"cashFlowCode"})
    aAdd(self:aFields,{"B8H_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8H_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8H_STATUS" ,"status"})
    aAdd(self:aFields,{"B8H_VLRCON" ,"value"})
    aAdd(self:aFields,{"B8H_REFERE" ,"trimester"})

Return self
