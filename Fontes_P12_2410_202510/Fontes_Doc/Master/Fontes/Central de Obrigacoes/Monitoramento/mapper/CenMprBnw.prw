#include "TOTVS.CH"

Class CenMprBnw from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBnw
    _Super:new()

    aAdd(self:aFields,{"BNW_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BNW_DECNUM" ,"certificateNumber"})
    aAdd(self:aFields,{"BNW_SEQGUI" ,"formSequential"})
    aAdd(self:aFields,{"BNW_TIPO" ,"certificateType"})

Return self
