#include "TOTVS.CH"

Class CenCltFlcx from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltFlcx
    _Super:new()
    self:oMapper := CenMprFlcx():New()
    self:oDao := CenDaoFlcx():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltFlcx
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltFlcx
return CenFlcx():New()
