#include "TOTVS.CH"

Class CenCltCrcd from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltCrcd
    _Super:new()
    self:oMapper := CenMprCrcd():New()
    self:oDao := CenDaoCrcd():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltCrcd
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltCrcd
return CenCrcd():New()
