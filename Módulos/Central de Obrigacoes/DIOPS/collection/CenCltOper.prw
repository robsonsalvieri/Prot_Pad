#include "TOTVS.CH"

Class CenCltOper from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltOper
    _Super:new()
    self:oMapper := CenMprOper():New()
    self:oDao := CenDaoOper():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltOper
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltOper
return CenOper():New()
