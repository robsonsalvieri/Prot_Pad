#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Rela��o N para N
#DEFINE ONE_TO_N 2 // Rela��o 1 para N
#DEFINE N_TO_ONE 3 // Rela��o N para 1
#DEFINE ZERO_TO  4 // Rela��o 0 para 1 ou N
#DEFINE TO_ZERO  5 // Rela��o N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class PLSB4EClt from CenCollection
	   
    Method New() Constructor
    Method initEntity()
 	
    Method bscUtiliz()
    Method goTop()
    Method getNext()

EndClass

Method New() Class PLSB4EClt
    _Super:new()
    self:oMapper := PLSB4EMpr():New()
    self:oDao := PLSB4EDao():New(self:oMapper:getFields())
return self

Method initEntity() Class PLSB4EClt
return PLSB4EEnt():New()

Method bscUtiliz(cCodRda,cSeqB4D,cStatus) Class PLSB4EClt
    self:lFound := self:getDao():bscUtiliz(cCodRda,cSeqB4D,cStatus)
    if self:lFound 
        self:goTop()
    endIf    
Return self:found()

Method goTop() Class PLSB4EClt
    self:nRecno := 1
    (self:getDao():getAliasTemp())->(DBGoTop())
return

Method getNext() Class PLSB4EClt
    self:oMapper:setEntity(self:initEntity())
    self:oMapper:mapFromDao(self:getDao())
    self:hMap := self:oMapper:getEntity():getHMap()
    self:setKeyRelation()
    self:nRecno++
    (self:getDao():getAliasTemp())->(DbSkip())
return self:oMapper:getEntity()