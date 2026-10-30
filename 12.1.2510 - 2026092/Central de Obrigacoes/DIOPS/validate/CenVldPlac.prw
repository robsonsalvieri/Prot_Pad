#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldPlac from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldPlac
    _Super:New()
Return self

Method validate(oEntity) Class CenVldPlac
    Local lOk := .T.
    If Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "Código da operadora não informado (providerRegister)"
    EndIf
    If Empty( oEntity:getValue( "accountCode" ) ) 
        lOk := .F.
        self:cMsg := "Código da conta não informado (accountCode)"
    EndIf
Return lOk
