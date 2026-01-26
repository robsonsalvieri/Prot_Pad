#include "TOTVS.CH"

Class CenMprBvt from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBvt
    _Super:new()

    aAdd(self:aFields,{"BVT_ANO" ,"referenceYear"})
    aAdd(self:aFields,{"BVT_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BVT_CDOBRI" ,"requirementCode"})
    aAdd(self:aFields,{"BVT_CODGRU" ,"procedureGroup"})
    aAdd(self:aFields,{"BVT_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BVT_CODPRO" ,"procedureCode"})
    aAdd(self:aFields,{"BVT_CODTAB" ,"tableCode"})
    aAdd(self:aFields,{"BVT_DTPRGU" ,"formProcDt"})
    aAdd(self:aFields,{"BVT_LOTE" ,"batchCode"})
    aAdd(self:aFields,{"BVT_NMGPRE" ,"providerFormNumber"})
    aAdd(self:aFields,{"BVT_QTDINF" ,"enteredQuantity"})
    aAdd(self:aFields,{"BVT_VLPGPR" ,"procedureValuePaid"})
    aAdd(self:aFields,{"BVT_VLRCOP" ,"coPaymentValue"})
    aAdd(self:aFields,{"BVT_STATUS" ,"status"})

Return self
