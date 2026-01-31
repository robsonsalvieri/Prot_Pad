#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class PLSB4DClt from CenCollection
	   
    Method New() Constructor
    Method initEntity()
 	
    Method bscUtiliz()
    Method goTop()
    Method getNext()

EndClass

Method New() Class PLSB4DClt
    _Super:new()
    self:oMapper := PLSB4DMpr():New()
    self:oDao := PLSB4DDao():New(self:oMapper:getFields())
return self

Method initEntity() Class PLSB4DClt
return PLSB4DEnt():New()

Method bscUtiliz(cCodRda,cPeriodDe,cPeriodAte,cStatus,cCodPeg,cProtoc) Class PLSB4DClt
    self:lFound := self:getDao():bscUtiliz(cCodRda,cPeriodDe,cPeriodAte,cStatus,cCodPeg,cProtoc)
    if self:lFound 
        self:goTop()
    endIf    
Return self:found()

Method goTop() Class PLSB4DClt
    self:nRecno := 1
    (self:getDao():getAliasTemp())->(DBGoTop())
return

Method getNext() Class PLSB4DClt
    self:oMapper:setEntity(self:initEntity())
    self:oMapper:mapFromDao(self:getDao())
    self:hMap := self:oMapper:getEntity():getHMap()
    self:setKeyRelation()
    self:nRecno++
    (self:getDao():getAliasTemp())->(DbSkip())
return self:oMapper:getEntity()