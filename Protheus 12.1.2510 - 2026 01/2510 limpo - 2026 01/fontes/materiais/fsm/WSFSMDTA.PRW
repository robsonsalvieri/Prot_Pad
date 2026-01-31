#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFSMDTA
Métodos Rest do FSM serviços DTA
@author flavio.martins
@since 22/09/2025
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL FSMDTA DESCRIPTION "WS de Integração Field Services Manager - DTA" 

	WSDATA productCode AS STRING
	WSDATA userRequest AS STRING

	WSMETHOD GET dtaVision DESCRIPTION 'Retorna o token do DTA' PATH "dtaVision" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET dtaVision WSREST FSMDTA
Local lRet      := .F.
Local oResponse := JSonObject():New()

Default Self:productCode := ''
Default Self:userRequest := ''

If Empty(Self:productCode)
	SetRestFault(400, EncodeUTF8("Parâmetro 'productCode' não informado"))
	Return .F.
Endif

If Empty(Self:userRequest)
	SetRestFault(400, EncodeUTF8("Parâmetro 'userRequest' não informado"))
	Return .F.
Endif

lRet := FsmVisExtrct(Self:productCode, Self:userRequest, @oResponse)

If lRet
	Self:SetResponse(FwJsonSerialize(oResponse, .F., .F., .T.))
Else
	SetRestFault(400, EncodeUTF8(oResponse['message']))
Endif

oResponse := Nil

Return lRet
