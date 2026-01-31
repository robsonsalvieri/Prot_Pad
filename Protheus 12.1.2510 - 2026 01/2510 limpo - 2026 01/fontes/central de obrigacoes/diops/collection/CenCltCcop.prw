#include "TOTVS.CH"

Class CenCltCcop from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltCcop
    _Super:new()
    self:oMapper := CenMprCcop():New()
    self:oDao := CenDaoCcop():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltCcop
return CenCcop():New()

Method initRelation() Class CenCltCcop

    Local oRelation := CenRelation():New()
    oRelation:destroy()

return self:listRelations()