#include "TOTVS.CH"

Class CenCltResp from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltResp
    _Super:new()
    self:oMapper := CenMprResp():New()
    self:oDao := CenDaoResp():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltResp
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltResp
return CenResp():New()
