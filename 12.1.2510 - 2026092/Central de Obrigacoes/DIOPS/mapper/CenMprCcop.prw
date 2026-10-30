#include "TOTVS.CH"

Class CenMprCcop from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprCcop
    _Super:new()

    aAdd(self:aFields,{"BUW_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"BUW_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"BUW_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"BUW_DENOMI" ,"taxName"})
    aAdd(self:aFields,{"BUW_DTCOMP" ,"periodDate"})
    aAdd(self:aFields,{"BUW_TIPO" ,"taxType"})
    aAdd(self:aFields,{"BUW_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"BUW_ATUMON" ,"monetaryUpdate"})
    aAdd(self:aFields,{"BUW_VLPGTR" ,"amtPaidTrimester"})
    aAdd(self:aFields,{"BUW_VLRFIN" ,"totalAmtFinanced"})
    aAdd(self:aFields,{"BUW_VLRPAG" ,"totalAmtPaid"})
    aAdd(self:aFields,{"BUW_DTREFI" ,"dateAdhesionToRefis"})
    aAdd(self:aFields,{"BUW_NUMPAR" ,"numberOfInstallments"})
    aAdd(self:aFields,{"BUW_QTPAIN" ,"numbDueInstallments"})
    aAdd(self:aFields,{"BUW_QTPAPG" ,"numbOfPaidInstallm"})
    aAdd(self:aFields,{"BUW_REFERE" ,"trimester"})
    aAdd(self:aFields,{"BUW_SLDFIN" ,"trimesterFinalBalance"})
    aAdd(self:aFields,{"BUW_SLDINI" ,"trimesterInitialBalance"})
    aAdd(self:aFields,{"BUW_STATUS" ,"status"})

Return self
