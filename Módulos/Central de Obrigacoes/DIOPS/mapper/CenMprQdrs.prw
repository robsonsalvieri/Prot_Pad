#include "TOTVS.CH"

Class CenMprQdrs from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprQdrs
    _Super:new()

    aAdd(self:aFields,{"B8X_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8X_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8X_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8X_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8X_QUADRO" ,"diopsChart"})
    aAdd(self:aFields,{"B8X_RECEBI" ,"chartReceived"})
    aAdd(self:aFields,{"B8X_VALIDA" ,"validateChart"})

Return self
