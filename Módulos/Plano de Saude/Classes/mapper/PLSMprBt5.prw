#include "TOTVS.CH"

Class PLSMprBt5 from CenMapper

    Method New() Constructor

EndClass

Method New() Class PLSMprBt5
    _Super:new()

    aAdd(self:aFields,{"BT5_CODINT" ,"operator"})
    aAdd(self:aFields,{"BT5_CODIGO" ,"code"})
    aAdd(self:aFields,{"BT5_NUMCON" ,"contractNumber"})
    aAdd(self:aFields,{"BT5_VERSAO" ,"version"})
    aAdd(self:aFields,{"BT5_DATCON" ,"contractDate"})
    aAdd(self:aFields,{"BT5_TIPCON" ,"contractType"})
    aAdd(self:aFields,{"BT5_ANTCON" ,"formerContractNumber"})
    aAdd(self:aFields,{"BT5_COBNIV" ,"chargeThisLevel"})
    aAdd(self:aFields,{"BT5_CODCLI" ,"customerCode"})
    aAdd(self:aFields,{"BT5_LOJA" ,"store"})
    aAdd(self:aFields,{"BT5_NOME" ,"customerName"})
    aAdd(self:aFields,{"BT5_NATURE" ,"financialClassCode"})
    aAdd(self:aFields,{"BT5_CODFOR" ,"supplier"})
    aAdd(self:aFields,{"BT5_LOJFOR" ,"storeSupplier"})
    aAdd(self:aFields,{"BT5_VENCTO" ,"dueDate"})
    aAdd(self:aFields,{"BT5_INTERC" ,"interchangeSubContract"})
    aAdd(self:aFields,{"BT5_MODPAG" ,"paymentMode"})
    aAdd(self:aFields,{"BT5_TIPOIN" ,"interchangeType"})
    aAdd(self:aFields,{"BT5_ALLOPE" ,"allOperators"})
    aAdd(self:aFields,{"BT5_OPEINT" ,"interchangeOperator"})
    aAdd(self:aFields,{"BT5_IMPORT" ,"importedFile"})
    aAdd(self:aFields,{"BT5_INFANS" ,"notifyAns"})
    aAdd(self:aFields,{"BT5_TIPPAG" ,"paymentModeCode"})
    aAdd(self:aFields,{"BT5_BCOCLI" ,"customerBank"})
    aAdd(self:aFields,{"BT5_AGECLI" ,"customerBranch"})
    aAdd(self:aFields,{"BT5_CTACLI" ,"customerAccount"})
    aAdd(self:aFields,{"BT5_PORTAD" ,"operatorBank"})
    aAdd(self:aFields,{"BT5_AGEDEP" ,"operatorBranch"})
    aAdd(self:aFields,{"BT5_CTACOR" ,"operatorAccount"})
    aAdd(self:aFields,{"BT5_COBJUR" ,"chargeInterNextMonth"})
    aAdd(self:aFields,{"BT5_TAXDIA" ,"dailyInterestPercentage"})
    aAdd(self:aFields,{"BT5_JURDIA" ,"dailyInterestAmount"})
    aAdd(self:aFields,{"BT5_MAIORI" ,"majority"})
    aAdd(self:aFields,{"BT5_PODREM" ,"allowReimburs"})
    aAdd(self:aFields,{"BT5_DIASIN" ,"nrOfDefaultDays"})
    aAdd(self:aFields,{"BT5_CODTES" ,"surplusType"})
    aAdd(self:aFields,{"BT5_CODSB1" ,"erpProductCode"})
    aAdd(self:aFields,{"BT5_CODANS" ,"disused"})
    aAdd(self:aFields,{"BT5_CODOPE" ,"ansCodeReciprocity"})
    aAdd(self:aFields,{"BT5_COMAUT" ,"automaticCompensation"})
    aAdd(self:aFields,{"BT5_AGR309" ,"addedToRiskPool"})


Return self
