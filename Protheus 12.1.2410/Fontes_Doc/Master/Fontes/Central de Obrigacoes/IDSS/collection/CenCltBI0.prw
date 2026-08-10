#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltBI0 from CenCollection
    Data cAliasAux      As String

    Method New() Constructor
    Method initEntity()
    Method initRelation()
    Method getVlrRzTISS(cCampoRet, cTipoObrig, oContDiops)

EndClass

Method New() Class CenCltBI0
    _Super:new()
    self:oMapper := CenMprBI0():New()
    self:oDao := CenDaoBI0():New(self:oMapper:getFields())
    self:cAliasAux := ''
return self

Method initEntity() Class CenCltBI0
return CenBI0():New()

Method initRelation() Class CenCltBI0

    Local oRelation := CenRelation():New()

    oRelation:destroy()

return self:listRelations()

Method getVlrRzTISS(cCampoRet, cTipoObrig, oContDiops) Class CenCltBI0
    Default cCampoRet   := ''
    Default cTipoObrig  := ''
    Default oContDiops  := Nil
    self:oDao:cAliasAux := self:cAliasAux
return self:oDao:getVlrRzTISS(cCampoRet, cTipoObrig, oContDiops)