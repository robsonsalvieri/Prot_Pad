#include "TOTVS.CH"

Class CenMprMdpc from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprMdpc
    _Super:new()

    aAdd(self:aFields,{"B82_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B82_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B82_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B82_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B82_NMRMTP" ,"tempRemidNumber"})
    aAdd(self:aFields,{"B82_NMRMVI" ,"vitRemidNumber"})
    aAdd(self:aFields,{"B82_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B82_SMDETP" ,"tempExpSom"})
    aAdd(self:aFields,{"B82_SMDEVI" ,"vitExpSom"})
    aAdd(self:aFields,{"B82_SMRMTP" ,"tempRemisSom"})
    aAdd(self:aFields,{"B82_SMRMVI" ,"vitRemisSom"})
    aAdd(self:aFields,{"B82_STATUS" ,"status"})

Return self
