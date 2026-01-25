#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltB2Y from CenCollection

    Method New() Constructor
    Method initEntity()
    Method initRelation()
    Method setExpired()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method GetProcess(cIdProc)
    Method posregexc()
    Method DadosB3K()
    Method getExpensesByDate(cIncDate,cFinalDate)

EndClass

Method New() Class CenCltB2Y
    _Super:new()
    self:oMapper := CenMprB2Y():New()
    self:oDao := CenDaoB2Y():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB2Y
return CenB2Y():New()

Method initRelation() Class CenCltB2Y

    Local oRelation := CenRelation():New()
    oRelation:destroy()

return self:listRelations()

Method setExpired() Class CenCltB2Y
    Local lFound := self:getDao():setExpired()
Return lFound

Method setProcessing() Class CenCltB2Y
Return self:getDao():setProcessing()

Method getMessage() Class CenCltB2Y
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltB2Y
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method GetProcess(cIdProc) Class CenCltB2Y
    Local lFound := self:getDao():GetProcess(cIdProc)
    self:goTop()
Return lFound

Method posregexc() Class CenCltB2Y
    Local lFound := self:getDao():posregexc()
    self:goTop()
Return lFound

Method DadosB3K(cCodOpe,cMatric,cCpf) Class CenCltB2W
    Local lFound := self:getDao():DadosB3K(cCodOpe,cMatric,cCpf)
    self:goTop()
Return lFound

Method getExpensesByDate(cIncDate,cFinalDate) Class CenCltB2Y
    self:lFound := self:getDao():getExpensesByDate(cIncDate,cFinalDate)
    self:goTop()
return self:found()
