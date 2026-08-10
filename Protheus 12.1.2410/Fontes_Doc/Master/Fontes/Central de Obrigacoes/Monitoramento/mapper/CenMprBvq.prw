#include "TOTVS.CH"

Class CenMprBvq from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBvq
    _Super:new()

    aAdd(self:aFields,{"BVQ_ANO" ,"referenceYear"})
    aAdd(self:aFields,{"BVQ_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BVQ_CDOBRI" ,"requirementCode"})
    aAdd(self:aFields,{"BVQ_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BVQ_DTPRGU" ,"formProcDt"})
    aAdd(self:aFields,{"BVQ_LOTE" ,"batchCode"})
    aAdd(self:aFields,{"BVQ_NMGPRE" ,"providerFormNumber"})
    aAdd(self:aFields,{"BVQ_STATUS" ,"status"})
    aAdd(self:aFields,{"BVQ_TPRGMN" ,"monitoringRecordType"})
    aAdd(self:aFields,{"BVQ_VLTCOP" ,"coPaymentTotalValue"})
    aAdd(self:aFields,{"BVQ_VLTGUI" ,"valuePaidForm"})
    aAdd(self:aFields,{"BVQ_VLTTBP" ,"ownTableTotalValue"})
    aAdd(self:aFields,{"BVQ_MATRIC" ,"registration"})
    aAdd(self:aFields,{"BVQ_HORPRO" ,"processingTime"})
    aAdd(self:aFields,{"BVQ_DATPRO" ,"processingDate"})
    aAdd(self:aFields,{"BVQ_DATINC" ,"inclusionDate"})
    aAdd(self:aFields,{"BVQ_HORINC" ,"inclusionTime"})

Return self
