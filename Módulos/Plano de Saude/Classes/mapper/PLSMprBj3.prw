#include "TOTVS.CH"

Class PLSMprBj3 from CENMapper

    Method New() Constructor

EndClass

Method New() Class PLSMprBj3
    _Super:new()

    aAdd(self:aFields,{"BJ3_CODIGO" ,"companyType"})
    aAdd(self:aFields,{"BJ3_VERSAO" ,"version"})
    aAdd(self:aFields,{"BJ3_CODFOR" ,"collectionMode"})


Return self
