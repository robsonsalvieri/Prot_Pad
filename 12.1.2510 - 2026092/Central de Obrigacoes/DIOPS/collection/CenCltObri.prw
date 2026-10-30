#include "TOTVS.CH"

Class CenCltObri from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltObri
    _Super:new()
    self:oMapper := CenMprObri():New()
    self:oDao := CenDaoObri():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltObri
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltObri
return CenObri():New()
