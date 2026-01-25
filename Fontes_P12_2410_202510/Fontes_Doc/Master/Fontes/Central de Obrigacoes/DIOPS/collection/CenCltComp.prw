#include "TOTVS.CH"

Class CenCltComp from CenCollection

    Method New() Constructor
    Method initEntity()
    Method podeImpDiops()
    Method initRelation()
    Method bscCmpMonAtiv()
    Method bscCmpDmAtiv()

EndClass

Method New() Class CenCltComp
    _Super:new()
    self:oMapper := CenMprComp():New()
    self:oDao := CenDaoComp():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltComp
return CenComp():New()

Method initRelation() Class CenCltComp
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method podeImpDiops() Class CenCltComp
    self:lFound := self:getDao():podeImpDiops()
    self:goTop()
Return self:found()

Method bscCmpMonAtiv() Class CenCltComp
    self:lFound := self:getDao():bscCmpMonAtiv()
    self:goTop()
Return self:found()

Method bscCmpDmAtiv() Class CenCltComp
    self:lFound := self:getDao():bscCmpDmAtiv()
    self:goTop()
Return self:found()
