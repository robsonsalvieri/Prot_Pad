#include "TOTVS.CH"

Class PlsMprB1R from CenMapper

    Method New() Constructor

EndClass

Method New() Class PlsMprB1R
    _Super:new()

    aAdd(self:aFields,{"B1R_HATARQ", "fileUrl"})
    aAdd(self:aFields,{"B1R_HATTOK", "accessToken"})
    aAdd(self:aFields,{"B1R_HATTIP", "transactionType"})
    aAdd(self:aFields,{"B1R_ORIGEM", "healthProviderId"})
    aAdd(self:aFields,{"B1R_PROTOC", "protocol"})
    aAdd(self:aFields,{"B1R_PROTOG", "sourceProtocol"})
    aAdd(self:aFields,{"B1R_PROTOI", "generatedProtocol"})
    aAdd(self:aFields,{"B1R_STATUS", "status"})
    aAdd(self:aFields,{"B1R_DATSUB" ,"uploadDate"})
    aAdd(self:aFields,{"B1R_ROBOID" ,"roboId"})
    aAdd(self:aFields,{"B1R_QTDTRY" ,"numberAttempts"})

Return self