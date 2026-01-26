#include "TOTVS.CH"

Class CenMprBny from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBny
    _Super:new()

    aAdd(self:aFields,{"BNY_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BNY_DECNUM" ,"certificateNumber"})
    aAdd(self:aFields,{"BNY_NMGOPE" ,"operatorFormNumber"})
    aAdd(self:aFields,{"BNY_TIPO" ,"certificateType"})

Return self
