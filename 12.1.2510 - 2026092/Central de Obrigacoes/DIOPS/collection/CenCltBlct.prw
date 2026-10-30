#include "TOTVS.CH"

Class CenCltBlct from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltBlct
    _Super:new()
    self:oMapper := CenMprBlct():New()
    self:oDao := CenDaoBlct():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBlct
return CenBlct():New()

Method initRelation() Class CenCltBlct

    Local oRelation := CenRelation():New()
    oRelation:destroy()

return self:listRelations()