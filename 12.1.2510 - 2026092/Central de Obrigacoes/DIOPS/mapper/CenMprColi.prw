#include "TOTVS.CH"

Class CenMprColi from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprColi
    _Super:new()

    aAdd(self:aFields,{"B8T_CNPJ" ,"legalEntityNatRegister"})
    aAdd(self:aFields,{"B8T_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8T_QTDACO" ,"quantityOfActions"})
    aAdd(self:aFields,{"B8T_RAZSOC" ,"companyName"})
    aAdd(self:aFields,{"B8T_TOTACO" ,"totalOfActionsOrQuota"})
    aAdd(self:aFields,{"B8T_TPPART" ,"typeOfShare"})
    aAdd(self:aFields,{"B8T_CLAEMP" ,"companyClassification"})

Return self
