#include "TOTVS.CH"

Class CenCltCoas from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltCoas
    _Super:new()
    self:oMapper := CenMprCoas():New()
    self:oDao := CenDaoCoas():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltCoas
return CenCoas():New()

Method initRelation() Class CenCltCoas

    Local oRelation := CenRelation():New()
    oRelation:destroy()

return self:listRelations()