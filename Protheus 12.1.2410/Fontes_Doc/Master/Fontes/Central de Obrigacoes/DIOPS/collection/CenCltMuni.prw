#include "TOTVS.CH"

Class CenCltMuni from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltMuni
    _Super:new()
    self:oMapper := CenMprMuni():New()
    self:oDao := CenDaoMuni():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltMuni
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltMuni
return CenMuni():New()
