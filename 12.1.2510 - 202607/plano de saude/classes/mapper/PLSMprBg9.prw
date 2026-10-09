#include "TOTVS.CH"

Class PLSMprBg9 from CenMapper

    Method New() Constructor

EndClass

Method New() Class PLSMprBg9
    _Super:new()

    aAdd(self:aFields,{"BG9_CODINT" ,"operator"})
    aAdd(self:aFields,{"BG9_CODIGO" ,"code"})
    aAdd(self:aFields,{"BG9_DESCRI" ,"descrOfGroupCompanyC"})
    aAdd(self:aFields,{"BG9_NREDUZ" ,"reducedName"})
    aAdd(self:aFields,{"BG9_PODREM" ,"allowReimb"})
    aAdd(self:aFields,{"BG9_TIPO" ,"groupType"})
    aAdd(self:aFields,{"BG9_EMPANT" ,"oldCompanyCode"})
    aAdd(self:aFields,{"BG9_CODCLI" ,"customerCode"})
    aAdd(self:aFields,{"BG9_LOJA" ,"store"})
    aAdd(self:aFields,{"BG9_NATURE" ,"financClassCode"})
    aAdd(self:aFields,{"BG9_CODFOR" ,"supplier"})
    aAdd(self:aFields,{"BG9_LOJFOR" ,"supplierStore"})
    aAdd(self:aFields,{"BG9_VENCTO" ,"dueDate"})
    aAdd(self:aFields,{"BG9_USO" ,"use"})
    aAdd(self:aFields,{"BG9_MESREA" ,"adjustmentMonth"})
    aAdd(self:aFields,{"BG9_INDREA" ,"adjustmentIndex"})
    aAdd(self:aFields,{"BG9_VALFAI" ,"userMinCollecValue"})
    aAdd(self:aFields,{"BG9_TIPPAG" ,"paymentModeCode"})
    aAdd(self:aFields,{"BG9_BCOCLI" ,"customerBank"})
    aAdd(self:aFields,{"BG9_AGECLI" ,"customerBranch"})
    aAdd(self:aFields,{"BG9_CTACLI" ,"customerAccount"})
    aAdd(self:aFields,{"BG9_PORTAD" ,"operatorBank"})
    aAdd(self:aFields,{"BG9_AGEDEP" ,"operatorBranch"})
    aAdd(self:aFields,{"BG9_CTACOR" ,"operatorAccount"})
    aAdd(self:aFields,{"BG9_COBJUR" ,"chargeInterestNextMont"})
    aAdd(self:aFields,{"BG9_FILESP" ,"specialBranch"})
    aAdd(self:aFields,{"BG9_TAXDIA" ,"dailyInterest"})
    aAdd(self:aFields,{"BG9_JURDIA" ,"dailyInterestValue"})
    aAdd(self:aFields,{"BG9_MAIORI" ,"majority"})
    aAdd(self:aFields,{"BG9_CODREG" ,"regionCode"})
    aAdd(self:aFields,{"BG9_DESREG" ,"regionDescription"})
    aAdd(self:aFields,{"BG9_EMPFAT" ,"billingCompany"})
    aAdd(self:aFields,{"BG9_FILFAT" ,"billingBranch"})
    aAdd(self:aFields,{"BG9_DESEMP" ,"descCompanyBillBranch"})
    aAdd(self:aFields,{"BG9_HSPEMP" ,"hspCompanyCode"})
    aAdd(self:aFields,{"BG9_DIASIN" ,"nrOfDefaultDays"})
    aAdd(self:aFields,{"BG9_REPASS" ,"onlendingCompany"})
    aAdd(self:aFields,{"BG9_CODSB1" ,"erpProductCode"})
    aAdd(self:aFields,{"BG9_CODTES" ,"invoiceOutflowType"})
    aAdd(self:aFields,{"BG9_COMAUT" ,"automaticCompensation"})


Return self
