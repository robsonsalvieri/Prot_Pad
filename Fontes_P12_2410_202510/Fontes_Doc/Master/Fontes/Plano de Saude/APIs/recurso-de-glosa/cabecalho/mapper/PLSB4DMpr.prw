#include "TOTVS.CH"

Class PLSB4DMpr from CenMapper

    Method New() Constructor

EndClass

Method New() Class PLSB4DMpr
    _Super:new()

    //Campo Protheus - atributo
    aAdd(self:aFields,{"B4D_PROTOC","appealProtocol"})
    aAdd(self:aFields,{"B4D_DCDPEG","newProtocol"})
    aAdd(self:aFields,{"B4D_CODPEG","protocol"})
    aAdd(self:aFields,{"B4D_NUMAUT","autorizationNumber"})
    aAdd(self:aFields,{"B4D_DATSOL","requestDate"})
    aAdd(self:aFields,{"B4D_SEQB4D","sequential"})
    aAdd(self:aFields,{"STATUS","status"})
    aAdd(self:aFields,{"ORIGEM","origem"})
    aAdd(self:aFields,{"OBJREC","appealObject"})
    aAdd(self:aFields,{"CHAVE","attachmentsKey"})
    aAdd(self:aFields,{"RecnoB4D","recno"})
    
Return self

