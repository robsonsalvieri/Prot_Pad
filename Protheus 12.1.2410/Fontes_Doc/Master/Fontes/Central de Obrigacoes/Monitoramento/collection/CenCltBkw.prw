#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltBkw from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()
    Method bscUltLote()
    Method bscLastArq()
    Method bscGerXTE()
    Method staPosLot()
    
EndClass

Method New() Class CenCltBkw
    _Super:new()
    self:oMapper := CenMprBkw():New()
    self:oDao := CenDaoBkw():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBkw
return CenBkw():New()

Method initRelation() Class CenCltBkw
return self:listRelations()

Method bscUltLote() Class CenCltBkw
Return self:getDao():bscUltLote()

Method bscLastArq() Class CenCltBkw
Return self:getDao():bscLastArq()

Method bscGerXTE() Class CenCltBkw
    self:lFound := self:getDao():bscGerXTE()
    self:goTop()
Return self:found()

Method staPosLot() Class CenCltBkw
Return self:getDao():staPosLot()