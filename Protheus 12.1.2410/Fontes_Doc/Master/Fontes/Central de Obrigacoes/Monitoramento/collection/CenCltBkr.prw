#include "TOTVS.CH"

Class CenCltBkr from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method bscMovPend()
    Method bscMovProc()
    Method bscMovExcl()
    Method bscUltMov(aTransExc)
    Method bscQtdPag(aDatProc)
    Method bscUltChv()
    Method bscTpGuia()
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
    Method VerCritBKR(cOperadora,cObri,cAno,cComp,cGuia)
EndClass

Method New() Class CenCltBkr
    _Super:new()
    self:oMapper := CenMprBkr():New()
    self:oDao := CenDaoBkr():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBkr
return CenBkr():New()

Method bscMovPend() Class CenCltBkr
    self:lFound := self:getDao():bscMovPend()
    self:goTop()
Return self:found()

Method bscMovProc() Class CenCltBkr
    self:lFound := self:getDao():bscMovProc()
    self:goTop()
Return self:found()

Method bscMovExcl() Class CenCltBkr
    self:lFound := self:getDao():bscMovExcl()
    self:goTop()
Return self:found()

Method bscUltMov(aTransExc) Class CenCltBkr
    self:lFound := self:getDao():bscUltMov(aTransExc)
    self:goTop()
Return self:found()

Method bscQtdPag(aDatProc) Class CenCltBkr
    self:lFound := self:getDao():bscQtdPag(aDatProc)
Return self:found()

Method bscUltChv() Class CenCltBkr
    self:lFound := self:getDao():bscUltChv()
    self:goTop()
Return self:found()

Method bscTpGuia(cTpGuia) Class CenCltBkr
Return self:getDao():bscTpGuia(cTpGuia)

Method setProcessing() Class CenCltBkr
Return self:getDao():setProcessing()

Method getMessage() Class CenCltBkr
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltBkr
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class CenCltBkr
    Local lFound := self:getDao():setExpired()
Return lFound

Method bscAddLote() Class CenCltBkr
    self:lFound := self:getDao():bscAddLote()
    self:goTop()
Return self:found()

Method qtdGuiComp() Class CenCltBkr
Return self:getDao():qtdGuiComp()

Method atuStaANS(cStatAtu,cStatCond) Class CenCltBkr
Return self:getDao():atuStaANS(cStatAtu,cStatCond)

Method atuCodLote(nQtdReg) Class CenCltBkr
Return self:getDao():atuCodLote(nQtdReg)

Method atuStaLot(nQtdReg) Class CenCltBkr
Return self:getDao():atuStaLot(nQtdReg)

Method staPosLot() Class CenCltBkr
Return self:getDao():staPosLot()

Method delLote() Class CenCltBkr
Return self:getDao():delLote()

Method VerCritBKR(cOperadora,cObri,cAno,cComp,cGuia) Class CenCltBkr
Return self:getDao():VerCritBKR(cOperadora,cObri,cAno,cComp,cGuia)