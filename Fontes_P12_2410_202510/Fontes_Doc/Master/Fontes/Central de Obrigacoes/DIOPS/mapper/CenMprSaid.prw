#include "TOTVS.CH"

Class CenMprSaid from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprSaid
    _Super:new()

    aAdd(self:aFields,{"B8F_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8F_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8F_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8F_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8F_VENCTO" ,"financialDueDate"})
    aAdd(self:aFields,{"B8F_AQUCAR" ,"debWPortfAcquis"})
    aAdd(self:aFields,{"B8F_COMERC" ,"mktOnOperations"})
    aAdd(self:aFields,{"B8F_DEBOPE" ,"debitsWithOperators"})
    aAdd(self:aFields,{"B8F_DEPBEN" ,"benefDepContrapIns"})
    aAdd(self:aFields,{"B8F_EVENTO" ,"eventClaimNetPres"})
    aAdd(self:aFields,{"B8F_EVESUS" ,"eventClaimNetSus"})
    aAdd(self:aFields,{"B8F_OUDBOP" ,"otherDebOprWPlan"})
    aAdd(self:aFields,{"B8F_OUDBPG" ,"otherDebitsToPay"})
    aAdd(self:aFields,{"B8F_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B8F_SERASS" ,"hthCareServProv"})
    aAdd(self:aFields,{"B8F_STATUS" ,"status"})
    aAdd(self:aFields,{"B8F_TITSEN" ,"billsChargesCollect"})

Return self
