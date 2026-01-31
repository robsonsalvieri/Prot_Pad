#include "TOTVS.CH"
 
Class CenMprCrcd from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprCrcd
    _Super:new()

    aAdd(self:aFields,{"B36_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B36_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B36_CODIGO" ,"ansEventCode"})
    aAdd(self:aFields,{"B36_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B36_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B36_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B36_STATUS" ,"status"})
    aAdd(self:aFields,{"B36_VLMES1" ,"amt1StMthTrimester"})
    aAdd(self:aFields,{"B36_VLMES2" ,"amt2NdMthTrimester"})
    aAdd(self:aFields,{"B36_VLMES3" ,"amt3RdMthTrimester"})

Return self
