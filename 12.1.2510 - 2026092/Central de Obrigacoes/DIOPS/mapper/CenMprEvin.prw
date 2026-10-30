#include "TOTVS.CH"

Class CenMprEvin from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprEvin
    _Super:new()

    aAdd(self:aFields,{"B8L_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8L_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8L_CODIGO" ,"eventCodeAns"})
    aAdd(self:aFields,{"B8L_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8L_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8L_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B8L_STATUS" ,"status"})
    aAdd(self:aFields,{"B8L_VLMES1" ,"quarterMthFirstValue"})
    aAdd(self:aFields,{"B8L_VLMES2" ,"quarterMthSecValue"})
    aAdd(self:aFields,{"B8L_VLMES3" ,"quarterMthThirdValue"})

Return self
