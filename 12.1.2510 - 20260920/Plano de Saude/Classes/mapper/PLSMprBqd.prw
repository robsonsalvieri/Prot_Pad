#include "TOTVS.CH"

Class PLSMprBqd from CenMapper

    Method New() Constructor

EndClass

Method New() Class PLSMprBqd
    _Super:new()

    aAdd(self:aFields,{"BQD_CODIGO" ,"code"})
    aAdd(self:aFields,{"BQD_NUMCON" ,"groupCompanyGroup"})
    aAdd(self:aFields,{"BQD_VERCON" ,"version"})
    aAdd(self:aFields,{"BQD_SUBCON" ,"subContract"})
    aAdd(self:aFields,{"BQD_VERSUB" ,"subContractVersion"})
    aAdd(self:aFields,{"BQD_DATINI" ,"versionInitialDate"})
    aAdd(self:aFields,{"BQD_DATFIN" ,"versionFinalDate"})


Return self
