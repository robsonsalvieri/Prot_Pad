#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldCoes from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldCoes
    _Super:New()
Return self

Method validate(oEntity) Class CenVldCoes
Return _Super:validate(oEntity)
