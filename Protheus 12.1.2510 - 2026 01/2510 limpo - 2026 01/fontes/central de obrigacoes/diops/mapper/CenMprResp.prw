#include "TOTVS.CH"

Class CenMprResp from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprResp
    _Super:new()

    aAdd(self:aFields,{"B8Y_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8Y_CPFCNP" ,"cpfCnpj"})
    aAdd(self:aFields,{"B8Y_TPPESS" ,"responsibleLeOrIndivid"})
    aAdd(self:aFields,{"B8Y_TPRESP" ,"responsibilityType"})
    aAdd(self:aFields,{"B8Y_NOMRAZ" ,"nameCorporateName"})
    aAdd(self:aFields,{"B8Y_NUMREG" ,"recordNumber"})

Return self
