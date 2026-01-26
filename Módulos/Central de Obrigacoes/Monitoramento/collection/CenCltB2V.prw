#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltB2V from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method GetProcess(cIdProc)
	Method initRelation()
	
EndClass

Method New() Class CenCltB2V
    _Super:new()
    self:oMapper := CenMprB2V():New()
    self:oDao := CenDaoB2V():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB2V
return CenB2V():New()

Method setProcessing() Class CenCltB2V
Return self:getDao():setProcessing()

Method getMessage() Class CenCltB2V
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltB2V
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class CenCltB2V
    Local lFound := self:getDao():setExpired()
Return lFound

Method GetProcess(cIdProc) Class CenCltB2V
    Local lFound := self:getDao():GetProcess(cIdProc)
    self:goTop()
Return lFound

Method initRelation() Class CenCltB2V
return self:listRelations()
