#include "TOTVS.CH"

Class CenCltBvq from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method bscMovPend()
    Method bscMovExcl()
    Method bscMovProc()
    Method bscUltChv()
    Method getQtdNmPre()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method bscAddLote()
    Method qtdGuiComp()
    Method atuCodLote(nQtdReg)
    Method atuStaANS(cStatAtu,cStatCond)
    Method AtuStaLot(nQtdReg)
    Method staPosLot()
    Method delLote()
    Method VerCritBVT(cOperadora,cObri,cAno,cComp,cGuia)

EndClass

Method New() Class CenCltBvq
    _Super:new()
    self:oMapper := CenMprBvq():New()
    self:oDao := CenDaoBvq():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBvq
return CenBvq():New()

Method bscMovPend() Class CenCltBvq
    self:lFound := self:getDao():bscMovPend()
    self:goTop()
Return self:found()

Method bscMovExcl() Class CenCltBvq
    self:lFound := self:getDao():bscMovExcl()
    self:goTop()
Return self:found()

Method bscMovProc() Class CenCltBvq
    self:lFound := self:getDao():bscMovProc()
    self:goTop()
Return self:found()

Method bscUltChv() Class CenCltBvq
    self:lFound := self:getDao():bscUltChv()
    self:goTop()
Return self:found()

Method getQtdNmPre() Class CenCltBvq
Return self:getDao():getQtdNmPre()

Method setProcessing() Class CenCltBvq
Return self:getDao():setProcessing()

Method getMessage() Class CenCltBvq
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltBvq
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class CenCltBvq
    Local lFound := self:getDao():setExpired()
Return lFound

Method bscAddLote() Class CenCltBvq
    self:lFound := self:getDao():bscAddLote()
    self:goTop()
Return self:found()

Method qtdGuiComp() Class CenCltBvq
Return self:getDao():qtdGuiComp()

Method atuCodLote(nQtdReg) Class CenCltBvq
Return self:getDao():atuCodLote(nQtdReg)

Method atuStaANS(cStatAtu,cStatCond) Class CenCltBvq
Return self:getDao():atuStaANS(cStatAtu,cStatCond)


Method atuStaLot(nQtdReg) Class CenCltBvq
Return self:getDao():atuStaLot(nQtdReg)

Method staPosLot() Class CenCltBvq
Return self:getDao():staPosLot()
 
Method delLote() Class CenCltBvq
Return self:getDao():delLote()

Method VerCritBVT(cOperadora,cObri,cAno,cComp,cGuia) Class CenCltBvq
Return self:getDao():VerCritBVT(cOperadora,cObri,cAno,cComp,cGuia)
