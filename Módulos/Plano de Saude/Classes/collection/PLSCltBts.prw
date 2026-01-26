#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class PLSCltBts from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()
    Method getNextMatVid()

EndClass

Method New() Class PLSCltBts
    _Super:new()
    self:oMapper := PLSMprBts():New()
    self:oDao := PLSDaoBts():New(self:oMapper:getFields())
return self

Method initEntity() Class PLSCltBts
return PLSBts():New()

Method initRelation() Class PLSCltBts

    Local oRelation := CenRelation():New()


    oRelation:destroy()

return self:listRelations()

Method getNextMatVid() Class PLSCltBts
Return self:getDao():getNextMatVid()
