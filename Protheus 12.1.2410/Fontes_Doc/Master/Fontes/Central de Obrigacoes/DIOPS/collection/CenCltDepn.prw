#include "TOTVS.CH"

Class CenCltDepn from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltDepn
    _Super:new()
    self:oMapper := CenMprDepn():New()
    self:oDao := CenDaoDepn():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltDepn
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltDepn
return CenDepn():New()
