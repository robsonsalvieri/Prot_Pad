#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldB8M from CenValidator

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldB8M
    _Super:New()
Return self

Method validate(oEntity) Class CenVldB8M
Return _Super:validate(oEntity)
