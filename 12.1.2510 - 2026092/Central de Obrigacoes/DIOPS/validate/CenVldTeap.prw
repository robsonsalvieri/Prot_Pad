#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldTeap from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldTeap
    _Super:New()
Return self

Method validate(oEntity) Class CenVldTeap
Return _Super:validate(oEntity)
