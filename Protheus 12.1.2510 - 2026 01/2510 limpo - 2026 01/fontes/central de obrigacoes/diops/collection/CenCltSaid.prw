#include "TOTVS.CH"

Class CenCltSaid from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltSaid
    _Super:new()
    self:oMapper := CenMprSaid():New()
    self:oDao := CenDaoSaid():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltSaid
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltSaid
return CenSaid():New()
