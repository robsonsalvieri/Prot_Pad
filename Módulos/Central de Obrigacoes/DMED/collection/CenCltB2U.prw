#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltB2U from CenCollection

    Method New() Constructor
    Method initEntity()
    Method initRelation()
    Method setNumRecibo()
    Method bscReqRet()
    Method atuStaArq(oCenCltB2U)
    Method verNumDup(oCenCltB2U)
      
EndClass

Method New() Class CenCltB2U
    _Super:new()
    self:oMapper := CenMprB2U():New()
    self:oDao := CenDaoB2U():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB2U
return CenB2U():New()

Method initRelation() Class CenCltB2U

    Local oRelation := CenRelation():New()


    oRelation:destroy()

return self:listRelations()

Method setNumRecibo() Class CenCltB2U
    self:lFound := self:getDao():setNumRecibo()
    self:goTop()
Return self:found()

Method bscReqRet() Class CenCltB2U
    self:lFound := self:getDao():bscReqRet()
    self:goTop()
Return self:found()

Method atuStaArq(oCenCltB2U) Class CenCltB2U
    self:lFound := self:getDao():atuStaArq(oCenCltB2U)
    self:goTop()
Return self:found()


Method verNumDup(oCenCltB2U) Class CenCltB2U
    self:lFound := self:getDao():verNumDup()
    self:goTop()
Return self:found()

