#include "TOTVS.CH"

Class CenCltMdpc from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltMdpc
    _Super:new()
    self:oMapper := CenMprMdpc():New()
    self:oDao := CenDaoMdpc():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltMdpc
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltMdpc
return CenMdpc():New()
