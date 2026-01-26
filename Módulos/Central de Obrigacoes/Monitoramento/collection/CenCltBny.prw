#include "TOTVS.CH"

Class CenCltBny from CenCollection
	   
    Method New() Constructor
    Method initEntity()

EndClass

Method New() Class CenCltBny
    _Super:new()
    self:oMapper := CenMprBny():New()
    self:oDao := CenDaoBny():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBny
return CenBny():New()
