#include "TOTVS.CH"

Class CenCltFuco from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltFuco
    _Super:new()
    self:oMapper := CenMprFuco():New()
    self:oDao := CenDaoFuco():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltFuco
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltFuco
return CenFuco():New()
