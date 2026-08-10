#include "TOTVS.CH"

Class CenMprB6N from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB6N
    _Super:new()

    aAdd(self:aFields,{"B6N_CODOPE" ,"healthInsurerCode"})
    aAdd(self:aFields,{"B6N_CPFRES" ,"ssn"})
    aAdd(self:aFields,{"B6N_NOMRES" ,"name"})
    aAdd(self:aFields,{"B6N_DDDRES" ,"areaCode"})
    aAdd(self:aFields,{"B6N_TELRES" ,"phoneNumber"})
    aAdd(self:aFields,{"B6N_RAMALR" ,"extensionLine"})
    aAdd(self:aFields,{"B6N_FAXRES" ,"fax"})
    aAdd(self:aFields,{"B6N_EMAILR" ,"eMail"})
    aAdd(self:aFields,{"B6N_ATIVO " ,"active"})


Return self
