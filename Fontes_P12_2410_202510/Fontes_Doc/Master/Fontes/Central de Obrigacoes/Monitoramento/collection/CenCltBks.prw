#include "TOTVS.CH"

Class CenCltBks from CenCollection
    Method New() Constructor
    Method initEntity()
    Method bscVlrPag(aDatProc)
    Method bscLastEve(aDatProc)
    Method bscTotCop()
    Method bscTotInf()
    Method bscTotFor()
    Method qtdGrupo()
    Method qtdProcGui()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method atuCodLote()
    Method qtdProcFa()  
    Method contGuia()  
    Method delLote() 
    Method VerCritBKR(cOperadora,cObri,cAno,cComp,cGuia)

EndClass

Method New() Class CenCltBks
    _Super:new()
    self:oMapper := CenMprBks():New()
    self:oDao := CenDaoBks():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBks
return CenBks():New()

Method bscVlrPag(aDatProc) Class CenCltBks
    self:lFound := self:getDao():bscVlrPag(aDatProc)
    self:goTop()
Return self:found()

Method bscLastEve(aDatProc) Class CenCltBks
    self:lFound := self:getDao():bscLastEve(aDatProc)
    self:goTop()
Return self:found()

Method bscTotCop() Class CenCltBks
Return self:getDao():bscTotCop()

Method bscTotInf() Class CenCltBks
Return self:getDao():bscTotInf()

Method bscTotFor() Class CenCltBks
Return self:getDao():bscTotFor()

Method qtdGrupo() Class CenCltBks
Return self:getDao():qtdGrupo()

Method qtdProcGui() Class CenCltBks
Return self:getDao():qtdProcGui()

Method setProcessing() Class CenCltBks
Return self:getDao():setProcessing()

Method getMessage() Class CenCltBks
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltBks
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class CenCltBks
    Local lFound := self:getDao():setExpired()
Return lFound

Method atuCodLote() Class CenCltBks
Return self:getDao():atuCodLote()

Method qtdProcFa() Class CenCltBks
Return self:getDao():qtdProcFa()

Method contGuia() Class CenCltBks
Return self:getDao():contGuia()

Method delLote() Class CenCltBks
Return self:getDao():delLote()

Method VerCritBKR(cOperadora,cObri,cAno,cComp,cGuia) Class CenCltBks
Return self:getDao():VerCritBKR(cOperadora,cObri,cAno,cComp,cGuia)