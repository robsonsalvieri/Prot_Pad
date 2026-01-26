#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class PLSCltBj3 from CENCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()

EndClass

Method New() Class PLSCltBj3
    _Super:new()
    self:oMapper := PLSMprBj3():New()
    self:oDao := PLSDaoBj3():New(self:oMapper:getFields())
return self

Method initEntity() Class PLSCltBj3
return PLSBj3():New()

Method initRelation() Class PLSCltBj3

    Local oRelation := CenRelation():New()


    oRelation:destroy()

return self:listRelations()
