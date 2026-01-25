#include "TOTVS.CH"

Class CenCltAcio from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation() 

EndClass

Method New() Class CenCltAcio
    _Super:new()
    self:oMapper := CenMprAcio():New()
    self:oDao := CenDaoAcio():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltAcio
return CenAcio():New()

Method initRelation() Class CenCltAcio

    Local oRelation := CenRelation():New()
    oRelation:destroy()

return self:listRelations()