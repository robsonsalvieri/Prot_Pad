#include "TOTVS.CH"

Class CenCltQdrs from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltQdrs
    _Super:new()
    self:oMapper := CenMprQdrs():New()
    self:oDao := CenDaoQdrs():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltQdrs
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltQdrs
return CenQdrs():New()
