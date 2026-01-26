#include "TOTVS.CH"

Class CenMprPect from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprPect
    _Super:new()

    aAdd(self:aFields,{"B37_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B37_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B37_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B37_PERCOB" ,"counterpartCoveragePeri"})
    aAdd(self:aFields,{"B37_PLANO" ,"planType"})
    aAdd(self:aFields,{"B37_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B37_AVENCE" ,"valueToExpire"})
    aAdd(self:aFields,{"B37_RECEBI" ,"receivedValue"})
    aAdd(self:aFields,{"B37_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B37_STATUS" ,"status"})
    aAdd(self:aFields,{"B37_VENCID" ,"dueValueInArrears"})
    aAdd(self:aFields,{"B37_EMITID" ,"netIssuedValue"})

Return self
