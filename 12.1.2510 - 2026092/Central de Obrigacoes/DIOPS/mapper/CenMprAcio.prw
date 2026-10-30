#include "TOTVS.CH"

Class CenMprAcio from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprAcio
    _Super:new()

    aAdd(self:aFields,{"B8S_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8S_CPFCNP" ,"shareholderSCpfCnpj"})
    aAdd(self:aFields,{"B8S_NOMRAZ" ,"corporateName"})
    aAdd(self:aFields,{"B8S_QTDQUO" ,"numberOfShares"})
    aAdd(self:aFields,{"B8S_TPACIO" ,"shareholderType"})

Return self
