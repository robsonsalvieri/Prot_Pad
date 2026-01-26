#include "TOTVS.CH"

Class CenCltRepr from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltRepr
    _Super:new()
    self:oMapper := CenMprRepr():New()
    self:oDao := CenDaoRepr():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltRepr
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltRepr
return CenRepr():New()
