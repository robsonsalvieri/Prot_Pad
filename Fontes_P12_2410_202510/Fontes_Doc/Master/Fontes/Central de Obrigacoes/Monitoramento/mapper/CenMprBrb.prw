#include "TOTVS.CH"

Class CenMprBrb from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprBrb
    _Super:new()

    aAdd(self:aFields,{"BRB_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BRB_SEQGUI" ,"formSequential"})
    aAdd(self:aFields,{"BRB_SEQITE" ,"sequence"})
    aAdd(self:aFields,{"BRB_VLPGPR" ,"procedureValuePaid"})
    aAdd(self:aFields,{"BRB_VLRCOP" ,"coPaymentValue"})
    aAdd(self:aFields,{"BRB_VLRGLO" ,"disallVl"})
    aAdd(self:aFields,{"BRB_VLRINF" ,"valueEntered"})
    aAdd(self:aFields,{"BRB_VLRPGF" ,"valuePaidSupplier"})
    aAdd(self:aFields,{"BRB_CODPRO" ,"procedureCode"})
    aAdd(self:aFields,{"BRB_CODTAB" ,"tableCode"})
    aAdd(self:aFields,{"BRB_PACOTE" ,"package"})
    aAdd(self:aFields,{"BRB_QTDINF" ,"enteredQuantity"})
    aAdd(self:aFields,{"BRB_QTDPAG" ,"quantityPaid"})
    aAdd(self:aFields,{"BRB_CDDENT" ,"toothCode"})
    aAdd(self:aFields,{"BRB_CDFACE" ,"toothFaceCode"})
    aAdd(self:aFields,{"BRB_CDREGI" ,"regionCode"})
    aAdd(self:aFields,{"BRB_CNPJFR" ,"supplierCnpj"})
    aAdd(self:aFields,{"BRB_CODGRU" ,"procedureGroup"})
    
    aAdd(self:aExpand,{"monitFormPackages"})

Return self
