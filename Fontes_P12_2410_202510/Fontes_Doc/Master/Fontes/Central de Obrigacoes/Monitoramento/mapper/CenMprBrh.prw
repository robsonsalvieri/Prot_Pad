#include "TOTVS.CH"

Class CenMprBrh from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBrh
    _Super:new()

    aAdd(self:aFields,{"BRH_CDPRIT" ,"itemProCode"})
    aAdd(self:aFields,{"BRH_CDTBIT" ,"itemTableCode"})
    aAdd(self:aFields,{"BRH_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BRH_CODPRO" ,"procedureCode"})
    aAdd(self:aFields,{"BRH_CODTAB" ,"tableCode"})
    aAdd(self:aFields,{"BRH_NMGOPE" ,"operatorFormNumber"})
    aAdd(self:aFields,{"BRH_QTPRPC" ,"packageQuantity"})

Return self
