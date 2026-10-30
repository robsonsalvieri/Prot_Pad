#include "TOTVS.CH"

Class CenCltPlac from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()    

EndClass

Method New() Class CenCltPlac
    _Super:new()
    self:oMapper := CenMprPlac():New()
    self:oDao := CenDaoPlac():New(self:oMapper:getFields())
return self

Method initRelation() Class CenCltPlac
    Local oRelation := CenRelation():New()
    oRelation:destroy()
return self:listRelations()

Method initEntity() Class CenCltPlac
return CenPlac():New()
