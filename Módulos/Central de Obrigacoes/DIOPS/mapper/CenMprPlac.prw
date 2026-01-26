#include "TOTVS.CH"

Class CenMprPlac from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprPlac
    _Super:new()

    aAdd(self:aFields,{"B8B_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8B_CONTA" ,"accountCode"})
    aAdd(self:aFields,{"B8B_VIGFIN" ,"validityEndDate"})
    aAdd(self:aFields,{"B8B_VIGINI" ,"validityStartDate"})
    aAdd(self:aFields,{"B8B_DESCRI" ,"accountDescription"})

Return self
