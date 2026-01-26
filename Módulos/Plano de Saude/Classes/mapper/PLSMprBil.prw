#include "TOTVS.CH"

Class PLSMprBil from CENMapper

    Method New() Constructor

EndClass

Method New() Class PLSMprBil
    _Super:new()

    aAdd(self:aFields,{"BIL_CODIGO" ,"companyType"})
    aAdd(self:aFields,{"BIL_VERSAO" ,"version"})
    aAdd(self:aFields,{"BIL_DATINI" ,"versionInitialDate"})
    aAdd(self:aFields,{"BIL_DATFIN" ,"versionFinalDate"})
    aAdd(self:aFields,{"BIL_CODANT" ,"versionIdentification"})
    aAdd(self:aFields,{"BIL_DESANT" ,"versionDescript"})


Return self
