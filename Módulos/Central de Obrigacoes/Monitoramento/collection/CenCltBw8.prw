#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltBw8 from CenCollection

    Method New() Constructor
    Method initEntity()
    Method setProcessing()
    Method getMessage()
    Method setEndProc(nRecno)
    Method setExpired()
    Method GetProcess(cIdProc)
    Method initRelation()

EndClass

Method New() Class CenCltBw8
    _Super:new()
    self:oMapper := CenMprBw8():New()
    self:oDao := CenDaoBw8():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltBw8
return CenBw8():New()

Method setProcessing() Class CenCltBw8
Return self:getDao():setProcessing()

Method getMessage() Class CenCltBw8
    Local lFound := self:getDao():getMessage()
    self:goTop()
Return lFound

Method setEndProc(nRecno) Class CenCltBw8
    Local lFound := self:getDao():setEndProc(nRecno)
    self:goTop()
Return lFound

Method setExpired() Class CenCltBw8
    Local lFound := self:getDao():setExpired()
Return lFound

Method GetProcess(cIdProc) Class CenCltBw8
    Local lFound := self:getDao():GetProcess(cIdProc)
    self:goTop()
Return lFound

Method initRelation() Class CenCltBw8

    Local oRelation := CenRelation():New()

    oRelation:setCollection(CenCltBwl():New())
    oRelation:setName("monitDirectSupplyEvents")
    oRelation:setRelationType(ONE_TO_N)
    oRelation:setBehavior(CASCADE)
    oRelation:setKey({;
        {"operatorRecord","operatorRecord"},;
        {"formSequential","formSequential"};
        })
    self:setRelation(oRelation)

return self:listRelations()