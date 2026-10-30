#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldDepn from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldDepn
    _Super:New()
Return self

Method validate(oEntity) Class CenVldDepn
    Local lOk := .T.
    If Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "Código da operadora não informado"
	ElseIf lOk 
        lOk := self:podeImpDiops(oEntity) 
    EndIf
Return lOk
