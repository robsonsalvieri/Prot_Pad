#include "TOTVS.CH"

Class CenMprComp from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprComp
    _Super:new()

    aAdd(self:aFields,{"B3D_CDOBRI" ,"requirementCode"})
    aAdd(self:aFields,{"B3D_CODIGO" ,"commitmentCode"})
    aAdd(self:aFields,{"B3D_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"B3D_ANO" ,"referenceYear"})
    aAdd(self:aFields,{"B3D_TIPOBR" ,"obligationType"})
    aAdd(self:aFields,{"B3D_VCTO" ,"commitmentDueDate"})
    aAdd(self:aFields,{"B3D_AVVCTO" ,"dueDateNotification"})
    aAdd(self:aFields,{"B3D_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B3D_SNTBEN" ,"synthetizesBenefit"})
    aAdd(self:aFields,{"B3D_STATUS" ,"status"})

Return self
