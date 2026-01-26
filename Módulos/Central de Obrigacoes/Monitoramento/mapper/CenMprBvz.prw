#include "TOTVS.CH"

Class CenMprBVZ from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBVZ
    _Super:new()

    aAdd(self:aFields,{"BVZ_ANO" ,"referenceYear"})
    aAdd(self:aFields,{"BVZ_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BVZ_CDOBRI" ,"requirementCode"})
    aAdd(self:aFields,{"BVZ_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BVZ_CPFCNP" ,"providerCpfCnpj"})
    aAdd(self:aFields,{"BVZ_DTPROC" ,"formProcDt"})
    aAdd(self:aFields,{"BVZ_LOTE" ,"batchCode"})
    aAdd(self:aFields,{"BVZ_STATUS" ,"status"})
    aAdd(self:aFields,{"BVZ_TPRGMN" ,"monitoringRecordType"})
    aAdd(self:aFields,{"BVZ_VLTGLO" ,"totalDisallowValue"})
    aAdd(self:aFields,{"BVZ_VLTINF" ,"totalValueEntered"})
    aAdd(self:aFields,{"BVZ_VLTPAG" ,"totalValuePaid"})
    aAdd(self:aFields,{"BVZ_HORINC" ,"inclusionTime"})
    aAdd(self:aFields,{"BVZ_HORPRO" ,"processingTime"})
    aAdd(self:aFields,{"BVZ_IDEREC" ,"identReceipt"})
    aAdd(self:aFields,{"BVZ_DATINC" ,"inclusionDate"})
    aAdd(self:aFields,{"BVZ_DATPRO" ,"processingDate"})

Return self
