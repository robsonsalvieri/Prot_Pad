#include "TOTVS.CH"

Class CenMprBks from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBks
    _Super:new()

    aAdd(self:aFields,{"BKS_CODGRU" ,"procedureGroup"})
    aAdd(self:aFields,{"BKS_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BKS_CODPRO" ,"procedureCode"})
    aAdd(self:aFields,{"BKS_CODTAB" ,"tableCode"})
    aAdd(self:aFields,{"BKS_DTPRGU" ,"formProcDt"})
    aAdd(self:aFields,{"BKS_LOTE" ,"batchCode"})
    aAdd(self:aFields,{"BKS_NMGOPE" ,"operatorFormNumber"})
    aAdd(self:aFields,{"BKS_ANO" ,"referenceYear"})
    aAdd(self:aFields,{"BKS_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BKS_CDDENT" ,"toothCode"})
    aAdd(self:aFields,{"BKS_CDFACE" ,"toothFaceCode"})
    aAdd(self:aFields,{"BKS_CDOBRI" ,"requirementCode"})
    aAdd(self:aFields,{"BKS_CDREGI" ,"regionCode"})
    aAdd(self:aFields,{"BKS_CNPJFR" ,"supplierCnpj"})
    aAdd(self:aFields,{"BKS_PACOTE" ,"package"})
    aAdd(self:aFields,{"BKS_QTDINF" ,"enteredQuantity"})
    aAdd(self:aFields,{"BKS_QTDPAG" ,"quantityPaid"})
    aAdd(self:aFields,{"BKS_VLPGPR" ,"procedureValuePaid"})
    aAdd(self:aFields,{"BKS_VLRCOP" ,"coPaymentValue"})
    aAdd(self:aFields,{"BKS_VLRGLO" ,"disallVl"})
    aAdd(self:aFields,{"BKS_VLRINF" ,"valueEntered"})
    aAdd(self:aFields,{"BKS_VLRPGF" ,"valuePaidSupplier"})
    aAdd(self:aFields,{"BKS_TIPEVE" ,"eventType"})
    aAdd(self:aFields,{"BKS_STATUS" ,"status"})

Return self
