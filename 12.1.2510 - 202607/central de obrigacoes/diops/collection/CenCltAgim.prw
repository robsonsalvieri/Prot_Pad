#include "TOTVS.CH"

Class CenCltAgim from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltAgim
    _Super:new()
    self:oMapper := CenMprAgim():New()
    self:oDao := CenDaoAgim():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltAgim
return CenAgim():New()

Method initRelation() Class CenCltAgim

    Local oRelation := CenRelation():New()
    oRelation:destroy()

return self:listRelations()