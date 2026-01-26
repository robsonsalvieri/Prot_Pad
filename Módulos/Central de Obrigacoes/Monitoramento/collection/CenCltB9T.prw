#include "TOTVS.CH"

Class CenCltB9T from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method bscMovPend()
    Method bscMovProc()
    Method bscUltChv()
    Method bscMovExcl()
    Method getQtdIdVPre()
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
    
EndClass

Method New() Class CenCltB9T
    _Super:new()
    self:oMapper := CenMprB9T():New()
    self:oDao := CenDaoB9T():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB9T
return CenB9T():New()

Method bscMovPend() Class CenCltB9T
    self:lFound := self:getDao():bscMovPend()
    self:goTop()
Return self:found()

Method bscMovProc() Class CenCltB9T
    self:lFound := self:getDao():bscMovProc()
    self:goTop()
Return self:found()

Method bscUltChv() Class CenCltB9T
    self:lFound := self:getDao():bscUltChv()
    self:goTop()
Return self:found()

Method bscMovExcl() Class CenCltB9T
    self:lFound := self:getDao():bscMovExcl()
    self:goTop()
Return self:found()

Method getQtdIdVPre() Class CenCltB9T
Return self:getDao():getQtdIdVPre()

Method setProcessing() Class CenCltB9T
Return self:getDao():setProcessing()

Method getMessage() Class CenCltB9T
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltB9T
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class CenCltB9T
    Local lFound := self:getDao():setExpired()
Return lFound

Method bscAddLote() Class CenCltB9T
    self:lFound := self:getDao():bscAddLote()
    self:goTop()
Return self:found()

Method qtdGuiComp() Class CenCltB9T
Return self:getDao():qtdGuiComp()

Method atuCodLote(nQtdReg) Class CenCltB9T
Return self:getDao():atuCodLote(nQtdReg)

Method atuStaANS(cStatAtu,cStatCond) Class CenCltB9T
Return self:getDao():atuStaANS(cStatAtu,cStatCond)

Method atuStaLot(nQtdReg) Class CenCltB9T
Return self:getDao():atuStaLot(nQtdReg)

Method staPosLot() Class CenCltB9T
Return self:getDao():staPosLot()

Method delLote() Class CenCltB9T
Return self:getDao():delLote()