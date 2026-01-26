#include "TOTVS.CH"

Class CenMprB8M from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB8M
    _Super:new()

    aAdd(self:aFields,{"B8M_CODOPE" ,"registerNumber"})
    aAdd(self:aFields,{"B8M_CNPJOP" ,"operatorCnpj"})
    aAdd(self:aFields,{"B8M_RAZSOC" ,"corporateName"})
    aAdd(self:aFields,{"B8M_NOMFAN" ,"tradeName"})
    aAdd(self:aFields,{"B8M_NATJUR" ,"legalNature"})
    aAdd(self:aFields,{"B8M_MODALI" ,"operatorMode"})
    aAdd(self:aFields,{"B8M_SEGMEN" ,"operatorSegmentation"})


Return self
