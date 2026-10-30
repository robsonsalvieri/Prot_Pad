#include "TOTVS.CH"

Class CenCltSpid from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltSpid
    _Super:new()
    self:oMapper := CenMprSpid():New()
    self:oDao := CenDaoSpid():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltSpid
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltSpid
return CenSpid():New()
