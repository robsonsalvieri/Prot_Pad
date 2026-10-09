#include "TOTVS.CH"

Class CenMprSmcr from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprSmcr
    _Super:new()

    aAdd(self:aFields,{"BVS_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"BVS_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BVS_CODIGO" ,"benefitAdmOperCode"})
    aAdd(self:aFields,{"BVS_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"BVS_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"BVS_REFERE" ,"trimester"})
    aAdd(self:aFields,{"BVS_STATUS" ,"status"})
    aAdd(self:aFields,{"BVS_VLMES1" ,"amt1StMthTrimester"})
    aAdd(self:aFields,{"BVS_VLMES2" ,"amt2NdMthTrimester"})
    aAdd(self:aFields,{"BVS_VLMES3" ,"amt3RdMthTrimester"})

Return self
