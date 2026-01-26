#include "TOTVS.CH"

Class CenMprTeap from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprTeap
    _Super:new()

    aAdd(self:aFields,{"B89_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B89_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B89_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B89_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B89_TIPPLA" ,"planType"})
    aAdd(self:aFields,{"B89_TXCANC" ,"contractCancelRate"})
    aAdd(self:aFields,{"B89_AJUTAB" ,"biomTabAdjustment"})
    aAdd(self:aFields,{"B89_ESTFLX" ,"cashFlowAdjEstimation"})
    aAdd(self:aFields,{"B89_FAIETA" ,"utiOfRangesRn632003"})
    aAdd(self:aFields,{"B89_INFMED" ,"estimatedMedicalInflati"})
    aAdd(self:aFields,{"B89_METINT" ,"ettjInterMethod"})
    aAdd(self:aFields,{"B89_REACUS" ,"averageAdjustmentPerVa"})
    aAdd(self:aFields,{"B89_REAMAX" ,"estimatedMaximumAdjustm"})
    aAdd(self:aFields,{"B89_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B89_STATUS" ,"status"})

Return self
