#include "TOTVS.CH"

Class CenCltBkt from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method bscCodPac()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method atuCodLote()
    Method delLote()
    
EndClass

Method New() Class CenCltBkt
    _Super:new()
    self:oMapper := CenMprBkt():New()
    self:oDao := CenDaoBkt():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBkt
return CenBkt():New()

Method bscCodPac() Class CenCltBkt
Return self:getDao():bscCodPac()

Method setProcessing() Class CenCltBkt
Return self:getDao():setProcessing()

Method getMessage() Class CenCltBkt
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltBkt
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class CenCltBkt
    Local lFound := self:getDao():setExpired()
Return lFound

Method atuCodLote() Class CenCltBkt
Return self:getDao():atuCodLote()

Method delLote() Class CenCltBkt
Return self:getDao():delLote()