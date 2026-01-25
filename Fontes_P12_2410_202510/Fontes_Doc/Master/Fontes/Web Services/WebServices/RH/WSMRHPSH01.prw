#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSMRHPSH01.CH"


WSRESTFUL Push DESCRIPTION STR0003 //"Meu RH - Push Notifications"

	WSDATA employeeId As String Optional

	WSMETHOD GET PushSetPar ;
	DESCRIPTION STR0001 ; //"Retorna se o serviço do Push Notification do Meu RH está habilitado."
	WSSYNTAX "/settingParameter/{employeeId}" ;
	PATH "/settingParameter/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

	WSMETHOD POST PushRgstUsr ;
	DESCRIPTION STR0002 ; //"Grava o token do dispositivo do funcionário, gerado pelo firebase."
	WSSYNTAX "/registerUserForPush/{employeeId}" ;
	PATH "/registerUserForPush/{employeeId}" ;
	PRODUCES 'application/json;charset=utf-8'

END WSRESTFUL

//******************** Métodos GETs ********************

WSMETHOD GET PushSetPar PATHPARAM employeeId WSREST Push

    Local oItem   := JsonObject():New()
	Local cJson   := ""
	Local lPush   := SuperGetMv("MV_MRHPUSH", .F., .F.)
	Local lTables := ChkFile("RUY") .And. ChkFile("RUX") .And. ChkFile("RUZ")

	//Garante que o push somente será liberado caso as 3 tabelas existam no dicionário.
    oItem["allowPushNotifications"] := lPush .And. lTables

    cJson := oItem:toJson()

	FreeObj(oItem)

	Self:SetResponse(cJson)
	
Return(.T.)

//******************** Métodos POSTs ********************

WSMETHOD POST PushRgstUsr PATHPARAM employeeId WSREST Push

	Local cMatSRA		:= ""
	Local cBranchVld	:= ""
	Local cBody 		:= Self:GetContent()
	Local cDeviceTok    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local aDataLogin    := {}
    Local oBody		 	:= JsonObject():New()
	Local oItem         := JsonObject():New()
    Local cJson         := ""
	Local lExistRuy     := ChkFile("RUY")
	
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	If !Empty(cBody) .And. lExistRuy

		cToken      := Self:GetHeader('Authorization')
		cKeyId  	:= Self:GetHeader('keyId')
		aDataLogin 	:= GetDataLogin(cToken, .T., cKeyId)

		If Len(aDataLogin) >= 5
			cMatSRA    := aDataLogin[1]
			cBranchVld := aDataLogin[5]
		EndIf

		If (!Empty(cMatSRA) .And. !Empty(cBranchVld))
			oBody:FromJson(cBody)
			cDeviceTok := If(oBody:hasProperty("deviceToken") .And. !oBody["deviceToken"] == Nil, oBody["deviceToken"], "")

			If !Empty(cDeviceTok)
				fGravTokPush(cBranchVld, cMatSRA, cDeviceTok)
			EndIf
		EndIf
	EndIf

    oItem["deviceToken"] := cDeviceTok

    cJson := oItem:toJson()

	FreeObj(oItem)
	FreeObj(oBody)
	Self:SetResponse(cJson)

Return(.T.)




