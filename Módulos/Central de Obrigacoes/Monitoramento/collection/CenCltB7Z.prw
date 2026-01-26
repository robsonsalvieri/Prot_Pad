#include "TOTVS.CH"

Class CenCltB7Z from CenCollection
	   
    Method New() Constructor
    Method initEntity()

EndClass

Method New() Class CenCltB7Z
    _Super:new()
    self:oMapper := CenMprB7Z():New()
    self:oDao := CenDaoB7Z():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB7Z
return CenB7Z():New()
