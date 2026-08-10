#include "TOTVS.CH"

Class CenCltCoes from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()

EndClass

Method New() Class CenCltCoes
    _Super:new()
    self:oMapper := CenMprCoes():New()
    self:oDao := CenDaoCoes():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltCoes
return CenCoes():New()

Method initRelation() Class CenCltCoes

    Local oRelation := CenRelation():New()
    oRelation:destroy()

return self:listRelations()