#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltB2W from CenCollection

    Method New() Constructor
    Method initEntity()
    Method initRelation()
    Method setExpired()
    Method setProcessing()
    Method getMessage()
    Method getAnoOpe()
    Method getTop()
    Method getRTop(cCpfTit)
    Method getDTop(cCpfTit)
    Method getRDTop(cCpfBenef, cBenefName)
    Method atuStatusByRecno(cStatus, nRecno)
    Method setEndProc(nRecno)
    Method VerAtuB2W()
    Method updateStatus(cStatus)
    Method buscacpf()
    Method setCriPro()
    Method bscCpfBen()
    Method setlAuto(lAuto)

EndClass

Method New() Class CenCltB2W
    _Super:new()
    self:oMapper := CenMprB2W():New()
    self:oDao := CenDaoB2W():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB2W
return CenB2W():New()

Method initRelation() Class CenCltB2W

    Local oRelation := CenRelation():New()
    oRelation:destroy()

return self:listRelations()

Method setExpired() Class CenCltB2W
    Local lFound := self:getDao():setExpired()
Return lFound

Method setProcessing() Class CenCltB2W
Return self:getDao():setProcessing()

Method atuStatusByRecno(cStatus, nRecno) Class CenCltB2W
Return self:getDao():atuStatusByRecno(cStatus, nRecno)

Method getMessage() Class CenCltB2W
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method getAnoOpe() Class CenCltB2W
    Local lFound := self:getDao():getAnoOpe()
    self:goTop()
Return lFound

Method getTop() Class CenCltB2W
    Local lFound := self:getDao():getTop()
    self:goTop()
Return lFound

Method getRTop(cCpfTit) Class CenCltB2W
    Local lFound := self:getDao():getRTop(cCpfTit)
    self:goTop()
Return lFound

Method getDTop(cCpfTit) Class CenCltB2W
    Local lFound := self:getDao():getDTop(cCpfTit)
    self:goTop()
Return lFound

Method getRDTop(cCpfBenef, cBenefName) Class CenCltB2W
    Local lFound := self:getDao():getRDTop(cCpfBenef, cBenefName)
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltB2W
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method VerAtuB2W() Class CenCltB2W
    self:lFound := self:getDao():VerAtuB2W()
    self:goTop()
Return self:found()

Method updateStatus(cStatus) Class CenCltB2W
    self:lFound := self:getDao():updateStatus(cStatus)
    self:goTop()
Return self:found()

Method buscacpf() Class CenCltB2W
    self:lFound := self:getDao():buscacpf()
    self:goTop()
Return self:found()

Method setCriPro() Class CenCltB2W
    self:lFound := self:getDao():setCriPro()
    self:goTop()
Return self:found()

Method bscCpfBen() Class CenCltB2W
    self:lFound := self:getDao():bscCpfBen()
    self:goTop()
Return self:found()

Method setlAuto(lAuto) Class CenCltB2W
    Default lAuto   := .F.
    self:getDao():setlAuto(lAuto)
Return