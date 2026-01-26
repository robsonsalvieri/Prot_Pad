#include "TOTVS.CH"

Class CenMprBwl from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBwl
    _Super:new()

    aAdd(self:aFields,{"BWL_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BWL_SEQGUI" ,"formSequential"})
    aAdd(self:aFields,{"BWL_SEQITE" ,"sequence"})
    aAdd(self:aFields,{"BWL_VLPGPR" ,"procedureValuePaid"})
    aAdd(self:aFields,{"BWL_VLRCOP" ,"coPaymentValue"})
    aAdd(self:aFields,{"BWL_CODPRO" ,"procedureCode"})
    aAdd(self:aFields,{"BWL_CODTAB" ,"tableCode"})
    aAdd(self:aFields,{"BWL_QTDINF" ,"enteredQuantity"})
    aAdd(self:aFields,{"BWL_CODGRU" ,"procedureGroup"})

Return self
