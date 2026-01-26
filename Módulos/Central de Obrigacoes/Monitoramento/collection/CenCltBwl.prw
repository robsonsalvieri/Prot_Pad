#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltBwl from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method aglutEvent()
	Method initRelation()
	
EndClass

Method New() Class CenCltBwl
    _Super:new()
    self:oMapper := CenMprBwl():New()
    self:oDao := CenDaoBwl():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBwl
return CenBwl():New()

Method aglutEvent() Class CenCltBwl
    self:lFound := self:getDao():aglutEvent()
    self:goTop()
Return self:found()

Method initRelation() Class CenCltBwl
return self:listRelations()

