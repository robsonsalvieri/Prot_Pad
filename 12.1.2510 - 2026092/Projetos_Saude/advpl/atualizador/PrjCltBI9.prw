#include "TOTVS.CH"

Class PrjCltBI9 from CenCollection
	   
    Method new() Constructor
    Method initEntity()
	
EndClass

Method initEntity() Class PrjCltBI9
Return PrjArtefato():new(BI9->BI9_CODIGO,allTrim(BI9->BI9_VERDIS))

Method new() Class PrjCltBI9
    _Super:new()
    self:oMapper := PrjMprBI9():new()
    self:oDao := PrjDaoBI9():new(self:oMapper:getFields())
return self
