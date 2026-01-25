#include "TOTVS.CH"

Class CenCltAgcn from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()

EndClass

Method New() Class CenCltAgcn
    _Super:new()
    self:oMapper := CenMprAgcn():New()
    self:oDao := CenDaoAgcn():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltAgcn
return CenAgcn():New()

Method initRelation() Class CenCltAgcn

    Local oRelation := CenRelation():New()
    oRelation:destroy()

return self:listRelations()