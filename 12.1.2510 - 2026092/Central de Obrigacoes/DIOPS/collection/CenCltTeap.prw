#include "TOTVS.CH"

Class CenCltTeap from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltTeap
    _Super:new()
    self:oMapper := CenMprTeap():New()
    self:oDao := CenDaoTeap():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltTeap
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltTeap
return CenTeap():New()
