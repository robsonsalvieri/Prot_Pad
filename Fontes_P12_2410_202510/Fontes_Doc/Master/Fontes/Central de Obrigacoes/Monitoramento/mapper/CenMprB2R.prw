#include "TOTVS.CH"

Class CenMprB2R from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB2R
    _Super:new()

    aAdd(self:aFields,{"B2R_CODTAB" ,"tableCode"})
    aAdd(self:aFields,{"B2R_CDTERM" ,"termCode"})
    aAdd(self:aFields,{"B2R_DESTER" ,"termDescription"})
    aAdd(self:aFields,{"B2R_VIGDE " ,"validityFrom"})
    aAdd(self:aFields,{"B2R_VIGATE" ,"validityTo"})
    aAdd(self:aFields,{"B2R_DATFIM" ,"deploymentEndDate"})
    aAdd(self:aFields,{"B2R_DSCDET" ,"detailedDescription"})
    aAdd(self:aFields,{"B2R_TABTUS" ,"tussTerminology"})
    aAdd(self:aFields,{"B2R_CODGRU" ,"groupCode"})
    aAdd(self:aFields,{"B2R_DESGRU" ,"groupDescription"})
    aAdd(self:aFields,{"B2R_HASVIN" ,"hasLinkFromTo"})


Return self

