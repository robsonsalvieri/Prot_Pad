#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class PlsCltB1R from CenCollection
	   
    Method New() Constructor
    
    Method atuStatusByRecno(cStatus)
    Method commit(lInclui, protocol)
    Method initEntity()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method GetProcess(cIdProc) 
	
EndClass

Method New() Class PlsCltB1R
    _Super:new()
    self:oMapper := PlsMprB1R():New()
    self:oDao := PlsDaoB1R():New(self:oMapper:getFields())
return self

Method atuStatusByRecno(cStatus) Class PlsCltB1R
    self:lFound := self:getDao():atuStatusByRecno(cStatus, self:getDbRecno())
    self:goTop()
Return self:found()

Method commit(lInclui, protocol) Class PlsCltB1R
    Default lInclui := .F.
    self:lFound := self:getDao():commit(lInclui, @protocol)
    If !self:found()
        self:setError("Não conseguiu incluir o registro. " + self:getDao():getError() )
    EndIf
Return self:found()

Method initEntity() Class PlsCltB1R
return PlsB1R():New()

Method setProcessing() Class PlsCltB1R
Return self:getDao():setProcessing()

Method getMessage() Class PlsCltB1R
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class PlsCltB1R
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class PlsCltB1R
    Local lFound := self:getDao():setExpired()
Return lFound

Method GetProcess(cIdProc) Class PlsCltB1R
    Local lFound := self:getDao():GetProcess(cIdProc)
    self:goTop()
Return lFound