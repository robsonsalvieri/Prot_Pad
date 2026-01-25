#include "TOTVS.CH"

Class CenMprPesl from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprPesl
    _Super:new()

    aAdd(self:aFields,{"B8J_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8J_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8J_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8J_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8J_CAMAIS" ,"evCorrAssumMajorPer"})
    aAdd(self:aFields,{"B8J_CAULTI" ,"lastDaysAssumCorrEv"})
    aAdd(self:aFields,{"B8J_EVMAIS" ,"greaterDangerLossEvent"})
    aAdd(self:aFields,{"B8J_EVULTI" ,"latestDaysEvents"})
    aAdd(self:aFields,{"B8J_QTDE" ,"noOfBeneficiaries"})
    aAdd(self:aFields,{"B8J_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B8J_STATUS" ,"status"})

Return self
