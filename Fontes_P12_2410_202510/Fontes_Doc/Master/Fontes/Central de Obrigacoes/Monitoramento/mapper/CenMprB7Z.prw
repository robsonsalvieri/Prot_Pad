#include "TOTVS.CH"

Class CenMprB7Z from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB7Z
    _Super:new()

    aAdd(self:aFields,{"B7Z_CODPRO" ,"procedureCode"})
    aAdd(self:aFields,{"B7Z_CODTAB" ,"tableCode"})
    aAdd(self:aFields,{"B7Z_FORENV" ,"submissionMethod"})
    aAdd(self:aFields,{"B7Z_TIPEVE" ,"eventType"})
    aAdd(self:aFields,{"B7Z_CODGRU" ,"procedureGroup"})

Return self
