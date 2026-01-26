#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldResp from CenVldDIOPS

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldResp
    _Super:New()
Return self

Method validate(oEntity) Class CenVldResp
    Local lOk := .T.
    If Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "Código da operadora não informado (providerRegister)"
    EndIf
    If Empty( oEntity:getValue( "cpfCnpj" ) ) 
        lOk := .F.
        self:cMsg := "CPF/CNPJ não informado (cpfCnpj)"
    EndIf
Return lOk
