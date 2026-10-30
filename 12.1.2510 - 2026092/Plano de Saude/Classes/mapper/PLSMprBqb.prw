#include "TOTVS.CH"

Class PLSMprBqb from CenMapper

    Method New() Constructor

EndClass

Method New() Class PLSMprBqb
    _Super:new()

    aAdd(self:aFields,{"BQB_CODIGO" ,"code"})
    aAdd(self:aFields,{"BQB_NUMCON" ,"groupCompanyGroup"})
    aAdd(self:aFields,{"BQB_VERSAO" ,"version"})
    aAdd(self:aFields,{"BQB_DATINI" ,"versionInitialDate"})
    aAdd(self:aFields,{"BQB_DATFIN" ,"versionFinalDate"})
    aAdd(self:aFields,{"BQB_CODINT" ,"operatorCode"})
    aAdd(self:aFields,{"BQB_CDEMP" ,"companyCode"})


Return self
