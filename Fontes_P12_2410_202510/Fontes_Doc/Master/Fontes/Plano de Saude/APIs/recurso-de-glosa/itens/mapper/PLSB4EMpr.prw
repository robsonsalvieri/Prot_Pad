#include "TOTVS.CH"

Class PLSB4EMpr from CenMapper

    Method New() Constructor

EndClass

Method New() Class PLSB4EMpr
    _Super:new()

    //Campo Protheus - atributo
    aAdd(self:aFields,{"B4E_CODPAD","tableCode"})
    aAdd(self:aFields,{"B4E_CODPRO","eventCode"})
    aAdd(self:aFields,{"B4E_DESPRO","eventDescription"})
    aAdd(self:aFields,{"B4E_VLRREC","reconsideredValue"})
    aAdd(self:aFields,{"B4E_VLRACA","acceptedValue"})
    aAdd(self:aFields,{"B4E_SEQUEN","sequential"})
    aAdd(self:aFields,{"B4E_OPEMOV","healthInsurerId"})
    aAdd(self:aFields,{"B4E_CODLDP","typingLocation"})
    aAdd(self:aFields,{"B4E_CODPEG","protocol" })
    aAdd(self:aFields,{"B4E_NUMAUT","healthInsurerFormNumber"})
    aAdd(self:aFields,{"B4E_ORIMOV","movementOrigin"})
    aAdd(self:aFields,{"B4E_DATPRO","date"})
    aAdd(self:aFields,{"STATUS","status"})
    aAdd(self:aFields,{"RecnoB4E","recno"})

Return self

