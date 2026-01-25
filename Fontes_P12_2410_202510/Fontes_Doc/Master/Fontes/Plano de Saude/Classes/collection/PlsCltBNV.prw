#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class PlsCltBNV from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method GetProcess(cIdProc) 
	
EndClass

Method New() Class PlsCltBNV
    _Super:new()
    self:oMapper := PlsMprBNV():New()
    self:oDao := PlsDaoBNV():New(self:oMapper:getFields())
return self

Method initEntity() Class PlsCltBNV
return PlsBNV():New()

Method setProcessing() Class PlsCltBNV
Return self:getDao():setProcessing()

Method getMessage() Class PlsCltBNV
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class PlsCltBNV
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class PlsCltBNV
    Local lFound := self:getDao():setExpired()
Return lFound

Method GetProcess(cIdProc) Class PlsCltBNV
    Local lFound := self:getDao():GetProcess(cIdProc)
    self:goTop()
Return lFound