#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltBrb from CenCollection

    Method New() Constructor
    Method initEntity()
    Method initRelation()
    Method aglutEvent()

EndClass

Method New() Class CenCltBrb
    _Super:new()
    self:oMapper := CenMprBrb():New()
    self:oDao := CenDaoBrb():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBrb
return CenBrb():New()

Method initRelation() Class CenCltBrb

    Local oRelation := CenRelation():New()

    oRelation:setCollection(CenCltBrc():New())
    oRelation:setName("monitFormPackages")
    oRelation:setRelationType(ONE_TO_N)
    oRelation:setBehavior(CASCADE)
    oRelation:setKey({;
        {"formSequential","formSequential"},;
        {"operatorRecord","operatorRecord"},;
        {"sequence","sequentialItem"};
        })
    self:setRelation(oRelation)

return self:listRelations()

Method aglutEvent() Class CenCltBrb
    self:lFound := self:getDao():aglutEvent()
    self:goTop()
Return self:found()
