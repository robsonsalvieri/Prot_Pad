#include "TOTVS.CH"

Class CenMprB2Y from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB2Y
    _Super:new()

    aAdd(self:aFields,{"B2Y_CODOPE" ,"healthInsurerCode"})
    aAdd(self:aFields,{"B2Y_CPFTIT" ,"ssnHolder"})
    aAdd(self:aFields,{"B2Y_MATTIT" ,"titleHolderEnrollment"})
    aAdd(self:aFields,{"B2Y_NOMTIT" ,"holderName"})
    aAdd(self:aFields,{"B2Y_CPFDEP" ,"dependentSsn"})
    aAdd(self:aFields,{"B2Y_MATDEP" ,"dependentEnrollment"})
    aAdd(self:aFields,{"B2Y_NOMDEP" ,"dependentName"})
    aAdd(self:aFields,{"B2Y_DTNASD" ,"dependentBirthDate"})
    aAdd(self:aFields,{"B2Y_RELDEP" ,"dependenceRelationships"})
    aAdd(self:aFields,{"B2Y_CHVDES" ,"expenseKey"})
    aAdd(self:aFields,{"B2Y_VLRDES" ,"expenseAmount"})
    aAdd(self:aFields,{"B2Y_VLRREE" ,"refundAmount"})
    aAdd(self:aFields,{"B2Y_VLRRAA" ,"previousYearRefundAmt"})
    aAdd(self:aFields,{"B2Y_COMPET" ,"period"})
    aAdd(self:aFields,{"B2Y_CPFCGC" ,"providerSsnEin"})
    aAdd(self:aFields,{"B2Y_NOMPRE" ,"providerName"})
    aAdd(self:aFields,{"B2Y_PROCES" ,"processed"})
    aAdd(self:aFields,{"B2Y_ROBOID" ,"roboId"})
    aAdd(self:aFields,{"B2Y_HORINC" ,"inclusionTime"})
    aAdd(self:aFields,{"B2Y_EXCLU" ,"exclusionId"})
    aAdd(self:aFields,{"B2Y_TIPGRV" ,"inclusionType"})
    aAdd(self:aFields,{"B2Y_DATINC" ,"inclusionDate"})

Return self
