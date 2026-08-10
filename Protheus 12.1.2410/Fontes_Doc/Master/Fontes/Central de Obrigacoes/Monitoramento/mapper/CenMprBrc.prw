#include "TOTVS.CH"

Class CenMprBrc from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBrc
    _Super:new()

    aAdd(self:aFields,{"BRC_CDPRIT" ,"itemProCode"})
    aAdd(self:aFields,{"BRC_CDTBIT" ,"itemTableCode"})
    aAdd(self:aFields,{"BRC_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BRC_SEQGUI" ,"formSequential"})
    aAdd(self:aFields,{"BRC_SEQITE" ,"sequentialItem"})
    aAdd(self:aFields,{"BRC_QTPRPC" ,"packageQuantity"})

Return self
