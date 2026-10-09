#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento
#DEFINE CASCADE 1     // Relacionamento em cascata

Class PLSCltBa1 from CenCollection

    Method New() Constructor
    Method initEntity()
    Method initRelation()
    Method getNextMatric()
    Method nextTipReg()
    Method matByCco(cCodCco)

EndClass

Method New() Class PLSCltBa1
    _Super:new()
    self:oMapper := PLSMprBa1():New()
    self:oDao := PLSDaoBa1():New(self:oMapper:getFields())
return self

Method initEntity() Class PLSCltBa1
return PLSBa1():New()

Method initRelation() Class PLSCltBa1

    Local oRelation := CenRelation():New()


    oRelation:destroy()

return self:listRelations()

Method getNextMatric() Class PLSCltBa1
Return self:getDao():getNextMatric()

Method nextTipReg() Class PLSCltBa1
Return self:getDao():nextTipReg()

Method matByCco(cCodCco) Class PLSCltBa1
Return self:getDao():matByCco(cCodCco)