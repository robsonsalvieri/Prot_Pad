#include "TOTVS.CH"

Class CenCltBn0 from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method atuCodLote()
    Method bscCertXML()
    Method delLote()

EndClass

Method New() Class CenCltBn0
    _Super:new()
    self:oMapper := CenMprBn0():New()
    self:oDao := CenDaoBn0():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBn0
return CenBn0():New()

Method atuCodLote() Class CenCltBn0
Return self:getDao():atuCodLote()

Method bscCertXML() Class CenCltBn0
    self:lFound := self:getDao():bscCertXML()
    self:goTop()
Return self:found()

Method delLote() Class CenCltBn0
Return self:getDao():delLote()