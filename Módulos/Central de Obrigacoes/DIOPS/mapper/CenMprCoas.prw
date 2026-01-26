#include "TOTVS.CH"

Class CenMprCoas from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprCoas
    _Super:new()

    aAdd(self:aFields,{"B8I_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B8I_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B8I_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B8I_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B8I_PLANO" ,"typeOfPlan"})
    aAdd(self:aFields,{"B8I_ORIGEM" ,"paymentOrigin"})
    aAdd(self:aFields,{"B8I_OUTROS" ,"otherPayments"})
    aAdd(self:aFields,{"B8I_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B8I_STATUS" ,"status"})
    aAdd(self:aFields,{"B8I_TERAPI" ,"therapies"})
    aAdd(self:aFields,{"B8I_CONSUL" ,"medicalAppointment"})
    aAdd(self:aFields,{"B8I_DEMAIS" ,"otherExpenses"})
    aAdd(self:aFields,{"B8I_EXAMES" ,"examinations"})
    aAdd(self:aFields,{"B8I_INTERN" ,"hospitalizations"})

Return self
