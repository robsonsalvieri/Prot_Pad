#include "TOTVS.CH"

Class CenCltColi from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltColi
    _Super:new()
    self:oMapper := CenMprColi():New()
    self:oDao := CenDaoColi():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltColi
return CenColi():New()

Method initRelation() Class CenCltColi

    Local oRelation := CenRelation():New()
    oRelation:destroy()

return self:listRelations()