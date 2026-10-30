#include "TOTVS.CH"

Class CenMprAgcn from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprAgcn
    _Super:new()

    aAdd(self:aFields,{"B8K_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8K_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8K_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8K_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8K_TIPO" ,"riskPool"})
    aAdd(self:aFields,{"B8K_PCECC" ,"pceCorresponGranted"})
    aAdd(self:aFields,{"B8K_PCECE" ,"pceIssuedCounterprov"})
    aAdd(self:aFields,{"B8K_PCEEV" ,"eveClaimsKnownPce"})
    aAdd(self:aFields,{"B8K_PLACC" ,"plaCorresponGranted"})
    aAdd(self:aFields,{"B8K_PLACE" ,"issuedConsiderationsPla"})
    aAdd(self:aFields,{"B8K_PLAEV" ,"plaKnowlLossEvents"})
    aAdd(self:aFields,{"B8K_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B8K_STATUS" ,"status"})

Return self
