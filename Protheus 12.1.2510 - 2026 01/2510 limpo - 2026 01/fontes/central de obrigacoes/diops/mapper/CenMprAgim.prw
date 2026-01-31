#include "TOTVS.CH"

Class CenMprAgim from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprAgim
    _Super:new()

    aAdd(self:aFields,{"B8C_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8C_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8C_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8C_CODRGI" ,"realEstateGeneralRegis"})
    aAdd(self:aFields,{"B8C_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8C_ASSIST" ,"assitance"})
    aAdd(self:aFields,{"B8C_REDPRO" ,"ownNetwork"})
    aAdd(self:aFields,{"B8C_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B8C_STATUS" ,"status"})
    aAdd(self:aFields,{"B8C_VIGFIN" ,"validityEndDate"})
    aAdd(self:aFields,{"B8C_VIGINI" ,"validityStartDate"})
    aAdd(self:aFields,{"B8C_VLRCON" ,"accountingValue"})

Return self
