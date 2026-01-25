#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldB6N from CenValidator

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldB6N
    _Super:New()
Return self

Method validate(oEntity) Class CenVldB6N
Return _Super:validate(oEntity)
