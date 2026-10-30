#include "TOTVS.CH"

Class CenMprMuni from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprMuni
    _Super:new()

    aAdd(self:aFields,{"B8W_CDIBGE" ,"ibgeCityCode"})
    aAdd(self:aFields,{"B8W_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8W_SIGLUF" ,"stateAcronym"})

Return self
