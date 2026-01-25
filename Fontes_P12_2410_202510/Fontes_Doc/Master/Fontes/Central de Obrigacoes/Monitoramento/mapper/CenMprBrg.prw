#include "TOTVS.CH"

Class CenMprBrg from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBrg
    _Super:new()

    aAdd(self:aFields,{"BRG_CODGRU" ,"procedureGroup"})
    aAdd(self:aFields,{"BRG_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BRG_CODPRO" ,"procedureCode"})
    aAdd(self:aFields,{"BRG_CODTAB" ,"tableCode"})
    aAdd(self:aFields,{"BRG_NMGOPE" ,"operatorFormNumber"})
    aAdd(self:aFields,{"BRG_CDDENT" ,"toothCode"})
    aAdd(self:aFields,{"BRG_CDFACE" ,"toothFaceCode"})
    aAdd(self:aFields,{"BRG_CDREGI" ,"regionCode"})
    aAdd(self:aFields,{"BRG_CNPJFR" ,"supplierCnpj"})
    aAdd(self:aFields,{"BRG_PACOTE" ,"package"})
    aAdd(self:aFields,{"BRG_QTDINF" ,"enteredQuantity"})
    aAdd(self:aFields,{"BRG_QTDPAG" ,"quantityPaid"})
    aAdd(self:aFields,{"BRG_VLPGPR" ,"procedureValuePaid"})
    aAdd(self:aFields,{"BRG_VLRCOP" ,"coPaymentValue"})
    aAdd(self:aFields,{"BRG_VLRGLO" ,"disallVl"})
    aAdd(self:aFields,{"BRG_VLRINF" ,"valueEntered"})
    aAdd(self:aFields,{"BRG_VLRPGF" ,"valuePaidSupplier"})
    aAdd(self:aFields,{"BRG_TIPEVE" ,"eventType"})

Return self
