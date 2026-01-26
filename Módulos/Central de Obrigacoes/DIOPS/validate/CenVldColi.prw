#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldColi from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldColi
    _Super:New()
Return self

Method validate(oEntity) Class CenVldColi
    Local lOk := .T.
    If Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "Código da operadora não informado"
	ElseIf lOk 
        lOk := self:podeImpDiops(oEntity) 
    EndIf
Return lOk