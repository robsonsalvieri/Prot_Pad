#include "TOTVS.CH"

Class CenCltBVZ from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method bscMovPend()
    Method bscMovProc()
    Method bscUltChv()
    Method bscMovExcl()
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

Method New() Class CenCltBVZ
    _Super:new()
    self:oMapper := CenMprBVZ():New()
    self:oDao := CenDaoBVZ():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBVZ
return CenBVZ():New()

Method bscMovPend() Class CenCltBVZ
    self:lFound := self:getDao():bscMovPend()
    self:goTop()
Return self:found()

Method bscMovProc() Class CenCltBVZ
    self:lFound := self:getDao():bscMovProc()
    self:goTop()
Return self:found()

Method bscUltChv() Class CenCltBVZ
    self:lFound := self:getDao():bscUltChv()
    self:goTop()
Return self:found()

Method bscMovExcl() Class CenCltBVZ
    self:lFound := self:getDao():bscMovExcl()
    self:goTop()
Return self:found()

Method setProcessing() Class CenCltBVZ
Return self:getDao():setProcessing()

Method getMessage() Class CenCltBVZ
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltBVZ
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class CenCltBVZ
    Local lFound := self:getDao():setExpired()
Return lFound

Method bscAddLote() Class CenCltBvz
    self:lFound := self:getDao():bscAddLote()
    self:goTop()
Return self:found()

Method qtdGuiComp() Class CenCltBvz
Return self:getDao():qtdGuiComp()

Method atuCodLote(nQtdReg) Class CenCltBvz
Return self:getDao():atuCodLote(nQtdReg)

Method atuStaANS(cStatAtu,cStatCond) Class CenCltBvz
Return self:getDao():atuStaANS(cStatAtu,cStatCond)


Method atuStaLot(nQtdReg) Class CenCltBvz
Return self:getDao():atuStaLot(nQtdReg)

Method staPosLot() Class CenCltBvz
Return self:getDao():staPosLot()

Method delLote() Class CenCltBvz
Return self:getDao():delLote()
