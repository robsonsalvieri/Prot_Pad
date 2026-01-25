#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltB6N from CenCollection

    Method New() Constructor
    Method initEntity()
    Method initRelation()
    Method getRespByCodOpe(cCodOpe,cCpf)

EndClass

Method New() Class CenCltB6N
    _Super:new()
    self:oMapper := CenMprB6N():New()
    self:oDao := CenDaoB6N():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB6N
return CenB6N():New()

Method initRelation() Class CenCltB6N

    Local oRelation := CenRelation():New()


    oRelation:destroy()

return self:listRelations()

Method getRespByCodOpe(cCodOpe,cCpf) Class CenCltB6N
    Local lFound := self:getDao():getRespByCodOpe(cCodOpe,cCpf)
    self:goTop()
Return lFound