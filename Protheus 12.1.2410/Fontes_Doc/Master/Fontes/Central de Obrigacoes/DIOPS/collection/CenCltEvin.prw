#include "TOTVS.CH"

Class CenCltEvin from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltEvin
    _Super:new()
    self:oMapper := CenMprEvin():New()
    self:oDao := CenDaoEvin():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltEvin
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltEvin
return CenEvin():New()
