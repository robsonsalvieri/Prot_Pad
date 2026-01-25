#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldObri 

    Data cMsg
    Method New() Constructor
    Method validate(oEntity)
    Method getErrMsg()

EndClass

Method New() Class CenVldObri
    self:cMsg = ""
Return self

Method getErrMsg()  Class CenVldObri
return self:cMsg

Method validate(oEntity) Class CenVldObri
    Local lOk       := .T.
    If Empty( oEntity:getValue( "obligationCode" ) ) 
		lOk := .F.
		self:cMsg := "Codigo da obrigação não informado"
	ElseIf Empty( oEntity:getValue( "providerRegister" ) ) 
        lOk := .F.
        self:cMsg := "Código da operadora não informado"
    ElseIf Empty( oEntity:getValue( "obligationType" ) ) 
        lOk := .F.
        self:cMsg := "Tipo da obrigação não informado"
    EndIf
Return lOk
