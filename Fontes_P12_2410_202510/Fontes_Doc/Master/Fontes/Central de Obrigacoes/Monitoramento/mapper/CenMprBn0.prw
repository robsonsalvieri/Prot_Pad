#include "TOTVS.CH"

Class CenMprBn0 from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBn0
    _Super:new()

    aAdd(self:aFields,{"BN0_ANO" ,"referenceYear"})
    aAdd(self:aFields,{"BN0_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BN0_CDOBRI" ,"requirementCode"})
    aAdd(self:aFields,{"BN0_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BN0_DTPRGU" ,"formProcDt"})
    aAdd(self:aFields,{"BN0_LOTE" ,"batchCode"})
    aAdd(self:aFields,{"BN0_NMGOPE" ,"operatorFormNumber"})
    aAdd(self:aFields,{"BN0_TIPO" ,"certificateType"})
    aAdd(self:aFields,{"BN0_DECNUM" ,"certificateNumber"})

Return self
