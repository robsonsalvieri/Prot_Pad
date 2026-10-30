#include "TOTVS.CH"

Class CenCltLcpr from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltLcpr
    _Super:new()
    self:oMapper := CenMprLcpr():New()
    self:oDao := CenDaoLcpr():New(self:oMapper:getFields())
return self


Method initRelation() Class CenCltLcpr
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltLcpr
return CenLcpr():New()
