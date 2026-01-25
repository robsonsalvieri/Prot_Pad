#include "TOTVS.CH"

Class CenCltBrg from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method bscEveHist()

EndClass

Method New() Class CenCltBrg
    _Super:new()
    self:oMapper := CenMprBrg():New()
    self:oDao := CenDaoBrg():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBrg
return CenBrg():New()

Method bscEveHist() Class CenCltBrg
    self:lFound := self:getDao():bscEveHist()
    self:goTop()
Return self:found()
