#include "TOTVS.CH"

Class PlsMprBNV from CenMapper

    Method New() Constructor

EndClass

Method New() Class PlsMprBNV
    _Super:new()

    aAdd(self:aFields,{"BNV_CODIGO" ,"code"})
    aAdd(self:aFields,{"BNV_CODTRA" ,"transactionCode"})
    aAdd(self:aFields,{"BNV_CHAVE"  ,"key"})
    aAdd(self:aFields,{"BNV_STATUS" ,"status"})
    aAdd(self:aFields,{"BNV_ALIAS"  ,"alias"})
    aAdd(self:aFields,{"BNV_CAMPOS" ,"fields"})
    aAdd(self:aFields,{"BNV_DATCRI" ,"creationDate"})
    aAdd(self:aFields,{"BNV_HORCRI" ,"creationTime"})
    aAdd(self:aFields,{"BNV_PEDSUB" ,"substOrder"})
    //aAdd(self:aFields,{"BNV_JSON"   ,"json"})
    aAdd(self:aFields,{"BNV_TOKEN"  ,"token"})
    aAdd(self:aFields,{"BNV_IDINT"  ,"integrationID"})
    aAdd(self:aFields,{"BNV_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"BNV_ROBOID" ,"roboId"})
    aAdd(self:aFields,{"BNV_QTDTRY" ,"numberAttempts"})

Return self