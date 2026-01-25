#include "TOTVS.CH"

Class CenCltSmcr from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltSmcr
    _Super:new()
    self:oMapper := CenMprSmcr():New()
    self:oDao := CenDaoSmcr():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltSmcr
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltSmcr
return CenSmcr():New()
