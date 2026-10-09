#include "TOTVS.CH"

Class CenMprBI0 from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBI0
    _Super:new()

    aAdd(self:aFields,{"BI0_CODOPE" ,"healthInsurerCode"})
    aAdd(self:aFields,{"BI0_ANO"    ,"referenceYear"})
    aAdd(self:aFields,{"BI0_NUMRZT" ,"numeratorTissRatio"})
    aAdd(self:aFields,{"BI0_DENRZT" ,"denominatorTissRatio"})
    aAdd(self:aFields,{"BI0_PRCRZT" ,"partialTissRatio"})
    aAdd(self:aFields,{"BI0_TOTRZT" ,"totalTissRatio"})

Return self