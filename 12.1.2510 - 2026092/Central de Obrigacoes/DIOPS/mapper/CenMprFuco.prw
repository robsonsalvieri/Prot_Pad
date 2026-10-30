#include "TOTVS.CH"

Class CenMprFuco from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprFuco
    _Super:new()

    aAdd(self:aFields,{"B6R_ANOCMP" ,"commitmentYear"})
    aAdd(self:aFields,{"B6R_CDCOMP" ,"commitmentCode"})
    aAdd(self:aFields,{"B6R_CNPJ" ,"cnpjOrFundAnsRec"})
    aAdd(self:aFields,{"B6R_CODOBR" ,"obligationCode"})
    aAdd(self:aFields,{"B6R_CODOPE" ,"providerRegister"})
    aAdd(self:aFields,{"B6R_TIPO" ,"fundType"})
    aAdd(self:aFields,{"B6R_NOME" ,"fundName"})
    aAdd(self:aFields,{"B6R_REFERE" ,"trimester"})
    aAdd(self:aFields,{"B6R_SLDCRD" ,"creditBalanceOfFund"})
    aAdd(self:aFields,{"B6R_SLDDEB" ,"debitorBalanceOfFund"})
    aAdd(self:aFields,{"B6R_STATUS" ,"status"})

Return self
