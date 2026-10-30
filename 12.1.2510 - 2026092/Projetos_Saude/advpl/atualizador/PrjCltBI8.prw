#include "TOTVS.CH"

Class PrjCltBI8 from CenCollection

    Method new() Constructor
    Method initEntity()
    Method getAtuAuto()
	
EndClass

Method new() Class PrjCltBI8
    _Super:new()
    self:oMapper := PrjMprBI8():new()
    self:oDao := PrjDaoBI8():new(self:oMapper:getFields())
return self

Method initEntity() Class PrjCltBI8
Return PrjArtefato():new(BI8->BI8_CODIGO,allTrim(BI8->BI8_ULTVER))

Method getAtuAuto() Class PrjCltBI8
    self:lFound := self:getDao():getAtuAuto()
    self:goTop()
Return self:found()