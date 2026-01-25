#include "TOTVS.CH"

Class CenCltPesl from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltPesl
    _Super:new()
    self:oMapper := CenMprPesl():New()
    self:oDao := CenDaoPesl():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltPesl
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltPesl
return CenPesl():New()
