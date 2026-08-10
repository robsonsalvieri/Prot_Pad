#include "TOTVS.CH"

Class CenCltBrh from CenCollection
	   
    Method New() Constructor
    Method initEntity()

EndClass

Method New() Class CenCltBrh
    _Super:new()
    self:oMapper := CenMprBrh():New()
    self:oDao := CenDaoBrh():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBrh
return CenBrh():New()
