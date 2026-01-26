#include "TOTVS.CH"

Class CenMprB2V from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB2V
    _Super:new()

    aAdd(self:aFields,{"B2V_SEQUEN" ,"formSequential"})
    aAdd(self:aFields,{"B2V_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"B2V_CPFCNP" ,"providerCpfCnpj"})
    aAdd(self:aFields,{"B2V_DTPROC" ,"formProcDt"})
    aAdd(self:aFields,{"B2V_VLTGLO" ,"totalDisallowValue"})
    aAdd(self:aFields,{"B2V_VLTINF" ,"totalValueEntered"})
    aAdd(self:aFields,{"B2V_VLTPAG" ,"totalValuePaid"})
    aAdd(self:aFields,{"B2V_EXCLU" ,"exclusionId"})
    aAdd(self:aFields,{"B2V_HORINC" ,"inclusionTime"})
    aAdd(self:aFields,{"B2V_IDEREC" ,"identReceipt"})
    aAdd(self:aFields,{"B2V_DATINC" ,"inclusionDate"})
    aAdd(self:aFields,{"B2V_PROCES" ,"processed"})
    aAdd(self:aFields,{"B2V_ROBOID" ,"roboId"})

Return self
