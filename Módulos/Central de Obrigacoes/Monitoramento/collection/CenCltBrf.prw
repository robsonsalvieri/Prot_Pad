#include "TOTVS.CH"

Class CenCltBrf from CenCollection
	   
    Method New() Constructor
    Method initEntity()

EndClass

Method New() Class CenCltBrf
    _Super:new()
    self:oMapper := CenMprBrf():New()
    self:oDao := CenDaoBrf():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBrf
return CenBrf():New()
