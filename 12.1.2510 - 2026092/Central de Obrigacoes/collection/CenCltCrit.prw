#include "TOTVS.CH"

Class CenCltCrit from CenCollection

    Method New() Constructor
    Method initEntity()
    Method lmpCriticas()
    Method insCritGrp(cSelectGrp)
    //Não encontrado chamada do metodo no sistema
    //Method bscCritBKT(oCltBKR)
    Method bscQtdCrit()
    Method ajuCriStatus(cCamposChave)
    Method initRelation()

EndClass

Method New() Class CenCltCrit
    _Super:new()
    self:oMapper := CenMprCrit():New()
    self:oDao := CenDaoCrit():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltCrit
return CenCrit():New()

Method lmpCriticas() Class CenCltCrit
    self:lFound := self:getDao():lmpCriticas()
return self:lFound

Method insCritGrp(cSelectGrp) Class CenCltCrit
    self:lFound := self:getDao():insCritGrp(cSelectGrp)
return self:lFound

//Não encontrado chamada do metodo no sistema
//Method bscCritBKT(oCltBKR) Class CenCltCrit
//    self:lFound := self:getDao():bscCritBKT(oCltBKR)
//    self:goTop()
//return self:lFound

Method bscQtdCrit() Class CenCltCrit
    self:lFound := self:getDao():bscQtdCrit()
return self:lFound

Method ajuCriStatus(cCamposChave) Class CenCltCrit
    self:lFound := self:getDao():ajuCriStatus(cCamposChave)
return self:lFound

Method initRelation() Class CenCltCrit
return self:listRelations()