#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relaï¿½ï¿½o N para N
#DEFINE ONE_TO_N 2 // Relaï¿½ï¿½o 1 para N
#DEFINE N_TO_ONE 3 // Relaï¿½ï¿½o N para 1
#DEFINE ZERO_TO  4 // Relaï¿½ï¿½o 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relaï¿½ï¿½o N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltB8M from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()

EndClass

Method New() Class CenCltB8M
    _Super:new()
    self:oMapper := CenMprB8M():New()
    self:oDao := CenDaoB8M():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB8M
return CenB8M():New()

Method initRelation() Class CenCltB8M

    Local oRelation := CenRelation():New()


    oRelation:destroy()

return self:listRelations()
