#include "TOTVS.CH"

Class CenMprB2W from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB2W
    _Super:new()

    aAdd(self:aFields,{"B2W_CODOPE" ,"healthInsurerCode" })
    aAdd(self:aFields,{"B2W_CODOBR" ,"requirementCode"})
    aAdd(self:aFields,{"B2W_ANOCMP" ,"referenceYear"  })
    aAdd(self:aFields,{"B2W_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B2W_IDEREG" ,"recordId"})
    aAdd(self:aFields,{"B2W_CPFBEN" ,"ssnBeneficiary"})
    aAdd(self:aFields,{"B2W_DTNASD" ,"dependentBirthDate"})
    aAdd(self:aFields,{"B2W_NOMBEN" ,"beneficiaryName"})
    aAdd(self:aFields,{"B2W_CPFTIT" ,"ssnHolder"})
    aAdd(self:aFields,{"B2W_CPFPRE" ,"providerEinSsn"})
    aAdd(self:aFields,{"B2W_NOMPRE" ,"providerName"})
    aAdd(self:aFields,{"B2W_VLRDES" ,"expenseAmount"})
    aAdd(self:aFields,{"B2W_VLRREE" ,"reimburseTotalValue"})
    aAdd(self:aFields,{"B2W_VLRANE" ,"previousYearReimburseT"})
    aAdd(self:aFields,{"B2W_RELDEP" ,"dependenceRelationship"})
    aAdd(self:aFields,{"B2W_STATUS" ,"status"})

Return self
