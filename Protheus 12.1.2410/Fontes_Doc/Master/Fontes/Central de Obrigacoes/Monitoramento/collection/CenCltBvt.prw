#include "TOTVS.CH"

Class CenCltBvt from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method bscUltEve()
    Method bscTotCop()
    Method bscTotPgGui()
    Method qtdGrupo()
    Method qtdProcGui()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method atuCodLote()
    Method delLote()
    Method VerCritBVT(cOperadora,cObri,cAno,cComp,cGuia)

EndClass

Method New() Class CenCltBvt
    _Super:new()
    self:oMapper := CenMprBvt():New()
    self:oDao := CenDaoBvt():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBvt
return CenBvt():New()

Method bscUltEve() Class CenCltBvt
    self:lFound := self:getDao():bscUltEve()
    self:goTop()
Return self:found()

Method bscTotCop() Class CenCltBvt
Return self:getDao():bscTotCop()

Method bscTotPgGui() Class CenCltBvt
Return self:getDao():bscTotPgGui()

Method qtdGrupo() Class CenCltBvt
Return self:getDao():qtdGrupo()

Method qtdProcGui() Class CenCltBvt
Return self:getDao():qtdProcGui()

Method setProcessing() Class CenCltBvt
Return self:getDao():setProcessing()

Method getMessage() Class CenCltBvt
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltBvt
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class CenCltBvt
    Local lFound := self:getDao():setExpired()
Return lFound

Method atuCodLote() Class CenCltBvt
Return self:getDao():atuCodLote()

Method delLote() Class CenCltBvt
Return self:getDao():delLote()

Method VerCritBVT(cOperadora,cObri,cAno,cComp,cGuia) Class CenCltBvt
Return self:getDao():VerCritBVT(cOperadora,cObri,cAno,cComp,cGuia)


