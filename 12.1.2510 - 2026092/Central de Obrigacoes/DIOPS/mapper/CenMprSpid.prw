#include "TOTVS.CH"

Class CenMprSpid from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprSpid
    _Super:new()

    aAdd(self:aFields,{"B8G_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8G_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8G_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8G_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8G_VENCTO" ,"financialDueDate"})
    aAdd(self:aFields,{"B8G_COLPOS" ,"collectiveFloating"})
    aAdd(self:aFields,{"B8G_COLPRE" ,"collectiveFixed"})
    aAdd(self:aFields,{"B8G_CREADM" ,"beneficiariesOperationC"})
    aAdd(self:aFields,{"B8G_CROPPO" ,"postPaymentOperCredit"})
    aAdd(self:aFields,{"B8G_INDPOS" ,"individualFloating"})
    aAdd(self:aFields,{"B8G_INDPRE" ,"individualFixed"})
    aAdd(self:aFields,{"B8G_OUCROP" ,"prePaymentOperatorsCre"})
    aAdd(self:aFields,{"B8G_OUCRPL" ,"otherCreditsWithPlan"})
    aAdd(self:aFields,{"B8G_OUTCRE" ,"otherCredNotRelatPlan"})
    aAdd(self:aFields,{"B8G_PARBEN" ,"partBenefInEveClaim"})
    aAdd(self:aFields,{"B8G_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B8G_STATUS" ,"status"})

Return self
