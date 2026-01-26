#include "TOTVS.CH"

Class CenMprBkt from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBkt
    _Super:new()

    aAdd(self:aFields,{"BKT_ANO" ,"referenceYear"})
    aAdd(self:aFields,{"BKT_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BKT_CDOBRI" ,"requirementCode"})
    aAdd(self:aFields,{"BKT_CDPRIT" ,"itemProCode"})
    aAdd(self:aFields,{"BKT_CDTBIT" ,"itemTableCode"})
    aAdd(self:aFields,{"BKT_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BKT_CODPRO" ,"procedureCode"})
    aAdd(self:aFields,{"BKT_CODTAB" ,"tableCode"})
    aAdd(self:aFields,{"BKT_DTPRGU" ,"formProcDt"})
    aAdd(self:aFields,{"BKT_LOTE" ,"batchCode"})
    aAdd(self:aFields,{"BKT_NMGOPE" ,"operatorFormNumber"})
    aAdd(self:aFields,{"BKT_QTPRPC" ,"packageQuantity"})
    aAdd(self:aFields,{"BKT_STATUS" ,"status"})

Return self
