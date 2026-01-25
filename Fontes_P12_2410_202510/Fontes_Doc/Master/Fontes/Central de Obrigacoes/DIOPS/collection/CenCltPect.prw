#include "TOTVS.CH"

Class CenCltPect from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltPect
    _Super:new()
    self:oMapper := CenMprPect():New()
    self:oDao := CenDaoPect():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltPect
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltPect
return CenPect():New()
