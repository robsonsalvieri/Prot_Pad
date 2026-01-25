#include "TOTVS.CH"

Class CenCltPact from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltPact
    _Super:new()
    self:oMapper := CenMprPact():New()
    self:oDao := CenDaoPact():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltPact
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltPact
return CenPact():New()
