#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FILEIO.ch"
#INCLUDE "AP5MAIL.ch"

#INCLUDE "RHNP.CH"

STATIC   cMeurhLog := GetConfig("RESTCONFIG","meurhLog", "")
STATIC __oSt := NIL

//**************************************************
//"Autenticações"
//**************************************************
	WSRESTFUL Auth DESCRIPTION STR0041

		WSDATA userId	As String Optional
		WSDATA password	As String Optional
		WSDATA user AS String Optional
		WSDATA redirectUrl AS String Optional
		WSDATA restUrl AS String Optional

		WSMETHOD POST DESCRIPTION "POST"  WSSYNTAX  "/auth/login | /auth/logout'

		WSMETHOD GET getLogged ;
			DESCRIPTION STR0049 ; //"Valida token JWT do login"
		WSSYNTAX "/auth/isLogged" ;
			PATH     "/auth/isLogged" ;
			PRODUCES "application/json;charset=utf-8"

		WSMETHOD POST getResetLink ;
			DESCRIPTION STR0050 ; //"Envia link por email para reset senha"
		WSSYNTAX "/renewPassword" ;
			PATH     "/renewPassword" ;
			PRODUCES "application/json;charset=utf-8"

		WSMETHOD PUT editPassword ;
			DESCRIPTION STR0051 ; //"Atualiza a senha do usuario."
		WSSYNTAX "/resetPassword" ;
			PATH     "/resetPassword" ;
			PRODUCES "application/json;charset=utf-8"

		WSMETHOD GET isFirstLogin ;
			DESCRIPTION STR0079; // Trocar a senha no primeiro login
		WSSYNTAX   "auth/isFirstLogin/{employeeId} || auth/isFirstLogin" ;

		WSMETHOD POST ChangePassWithLastPass ;
			DESCRIPTION STR0092; // Realiza troca de senha do usuário.
		WSSYNTAX   "auth/ChangePassWithLastPass"   ;
			PATH       "ChangePassWithLastPass"   ;
			PRODUCES "application/json;charset=utf-8" ;
			TTALK "v2"

	END WSRESTFUL


//************************************************************
// "Serviços de Contexto"
//************************************************************
	WSRESTFUL Setting DESCRIPTION STR0080
		WSDATA employeeId As String Optional
		WSDATA WsNull     As String Optional
		WSDATA type       As String Optional

		WSMETHOD GET getAllContexts ;
			DESCRIPTION STR0081 ; //"Retorna os contextos do usuário para seleção."
		WSSYNTAX "/setting/contexts" ;
			PATH "/contexts" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET getContext ;
			DESCRIPTION STR0082 ; //"Retorna o contexto corrente do usuário."
		WSSYNTAX "/setting/context" ;
			PATH "/context" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD PUT setContext ;
			DESCRIPTION STR0083 ; //"Atualiza o contexto selecionado."
		WSSYNTAX "/setting/context" ;
			PATH "/context" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET getPermissions ;
			DESCRIPTION STR0084 ; //"Verifica liberação de acesso as funcionalidades."
		WSSYNTAX "/setting/permissions/{employeeId}" ;
			PATH "/permissions/{employeeId}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET getFieldProperties ;
			DESCRIPTION STR0085 ; //"Verifica os elementos que podem ser visualizados e/ou editados na página."
		WSSYNTAX "/setting/fieldProperties/{pageFilter}" ;
			PATH "fieldProperties/{pageFilter}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET CompanySettings ;
			DESCRIPTION STR0127 ; //"Retorna as configurações do ambiente."
		WSSYNTAX "/setting/companySettings" ;
			PATH "/companySettings" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET employeeKey ;
			DESCRIPTION STR0129 ; // "Retorna o KeyID do usuario logado."
		WSSYNTAX "/setting/employeeKey" ;
			PATH "/employeeKey" ;
			PRODUCES 'application/json;charset=utf-8'

	END WSRESTFUL


//***************************************
//Métodos REST AUTH
//***************************************

WSMETHOD POST WSSERVICE Auth

	Local oItemData      := JsonObject():New()
	Local oItem          := JsonObject():New()
	Local oMsgReturn     := JsonObject():New()
	Local oBody          := NIL
	Local aMessages      := {}
	Local aRet           := {}
	Local aDataEnv       := {}
	Local aDtHr          := {}
	Local lRet           := .T.
	Local lSetAccess     := .F.
	Local lIsWeb         := .F.
	Local lBlocked       := .F.
	Local lAdmissal      := .F.
	Local cJson          := ""
	Local cRedirect      := ""
	Local cRestURL       := ""
	Local cUser          := ""
	Local cPassword      := ""
	Local cDemit         := ""
	Local cMatValid      := ""
	Local cBranchVld     := ""
	Local cToken         := ""
	Local cKey           := ""
	Local cKeyId         := ""
	Local cMensagem      := ""
	Local cRestPort      := ""
	Local cUserID        := ""
	Local cRestFault     := ""
	Local cString        := ""
	Local cBody          := ""
	Local nPos           := 0
	Local nLenParms      := Len(::aURLParms)
	Local cPPAccess      := GetMv("MV_ACESSPP",,"")
	Local lNewLogin      := GetMv("MV_LOGINT",,.F.)
	Local lCpoRD0        := RD0->(ColumnPos("RD0_FILRH")) > 0
	Local lLastPwd       := RD0->(ColumnPos("RD0_ULI")) > 0
	Local nNumLPwd       := If(lLastPwd, GetMv("MV_MRHULI",,0), 0)
	Local lChkUser       := lLastPwd .And. nNumLPwd > 0

	DEFAULT self:userId 		   := ""
	DEFAULT self:password	   := ""
	DEFAULT self:user	         := ""
	DEFAULT self:redirectUrl   := ""
	DEFAULT self:restUrl	      := ""

// - Por por padrão todo objeto tem
// - data: contendo a estrutura do JSON
// - messages: para determinados avisos
// - length: informativo sobre o tamanho.

	::SetHeader('Access-Control-Allow-Credentials' , "true")


	If nLenParms >= 1 .And. Lower(::aURLParms[1]) == "login"

		If cMeurhLog != "0"
			aDtHr := FwTimeUF("SP",,.T.)

			conout("")
			conout(EncodeUTF8(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"    ))
			conout(EncodeUTF8(">>> " +GetVersao()                                    ))
			conout(EncodeUTF8(">>> " +GetBuild()                                     ))
			conout(EncodeUTF8(">>> build dba: " +TCGetBuild() +" - " +TCSrvType()    ))

			aDataEnv := GetAPOInfo("aplib050.prw")
			conout(EncodeUTF8(">>> build lib: " +DTos(aDataEnv[4])                   ))

			aDataEnv := GetAPOInfo("rhnp05.prw")
			conout(EncodeUTF8(">>> build mrh: " +DTos(aDataEnv[4])                   ))

			conout(EncodeUTF8(">>> ENV/RPO: " +GetEnvServer() +"/" +GetRPORelease()  ))

		EndIf

		If !Empty(cBody := ::GetContent())

			oBody := JsonObject():New()
			oBody:FromJson(cBody)
			cUser := Iif( !( oBody["user"] == NIL ), AllTrim( oBody["user"] ), "")
			cPassword := iif( !( oBody["password"] == NIL ), AllTrim( oBody["password"]),"" )
			cRedirect := iif( !( oBody["redirectUrl"] == NIL ), AllTrim( oBody["redirectUrl"]), "" )
			cRestURL := iif( !( oBody["restUrl"] == NIL ), AllTrim( oBody["restUrl"]),"" )

			//Tratativa para login com AD
			nPos := At( "?bust" , cRestURL )
			cRestUrl := If( nPos > 0, SubStr(cRestURL, 1, nPos-1), cRestURL)

			If lNewLogin
				lRet := MrhLogin(cRestURL, cUser, cPassword, @cToken, @cKeyId, @cBranchVld, @cMatValid, @cRestFault)
			Else
				// -----------------------------------------------------
				// - Persiste o acesso do usuário - PRTLOGIN WSPORTAL01|
				// -----------------------------------------------------
				UnifiedLoginRH(@lRet,cUser,cPassword,"2",cPPAccess,.T.,,,@cRestFault,nNumLPwd,@lBlocked)
			EndIf

			cRestPort := GetConfig("RESTCONFIG","restPort", "")

			//nova pesquisa em virtude da atualização do appWebWizard
			cRestPort := If( Empty(cRestPort), GetConfig("HTTPREST","Port", ""), cRestPort )

			If 'restPort' $ cRedirect
				cRedirect := StrTran( cRedirect, "?restPort="+cRestPort, "" )
			Else
				lIsWeb	:= .T.
			EndIf

			If lRet

				If !lNewLogin
					// ---------------------------------------
					// - Após validar o usuário e senha;
						// - Posiciona na RD0, captura as
					// - Matrículas que o usuário tem acesso;
						// - E provisóriamente loga com a Primeira
					// ---------------------------------------
					lSetAccess := GetAccessEmployee(cUser, @aRet, lRet, .T., @cMensagem)

					If lSetAccess
						If Len(aRet) >= 1
							nPos := Ascan(aRet,{|x| !(x[9] $ "D")})
							If nPos > 0
								cMatValid  := aRet[nPos][1]
								cBranchVld := aRet[nPos][3]
							Else
								cMatValid  := aRet[1][1]
								cBranchVld := aRet[1][3]
							EndIf
						EndIf

						cDemit := If( aRet[If(nPos > 0, nPos, 1)][9] $ "D|T", ".T.", ".F." )
						cKey   := cMatValid+"|"+cUser+"|"+RD0->RD0_CODIGO+"|"+DtoS(dDataBase)+"|"+cBranchVld+"|"+cDemit
						cUserID := GetConfig("RESTCONFIG","userId", "")

						If Empty(cUserID) //nova pesquisa em virtude da atualização do appWebWizard
							cUserID := GetConfig("HTTPREST","userId", "")
						EndIf

						//Busca usuario do portal
						If Empty(cUserID)
							dbSelectArea("AI3")
							AI3->(dbSetOrder(1))
							If !lCpoRD0
								If AI3->(dbSeek(xFilial("AI3")+RD0->RD0_PORTAL))
									cUserID := UsrRetName(AI3->AI3_USRSIS)
								EndIf
							Else
								If AI3->(dbSeek(xFilial("AI3",RD0->RD0_FILRH)+RD0->RD0_PORTAL))
									cUserID := UsrRetName(AI3->AI3_USRSIS)
								EndIf
							EndIf
						EndIf

						//Gera token
						If !Empty(cUserID)
							//cToken := FwJWT2Bear(cUserID,{"payments/","payment/","data/","team/", "request/", "timesheet/", "/team/", "setting/"},Date(),Seconds() + Val(GetConfig("RESTCONFIG","RefreshTokenTimeout", 600)),Nil,Nil,{ {"key",cKey} })

							//Retirada a passagem de data e segundos para a funcao FwJWT2Bear por orientacao do Framework - 01/2019
							cToken := FwJWT2Bear(cUserID,{"payments/","payment/","data/","team/", "request/", "timesheet/", "/team/", "setting/"},Nil,Nil,Nil,Nil,{ {"key",cKey} })
						Else
							If cMeurhLog != "0"
								conout(EncodeUTF8(STR0046 + cUser +' - ' + STR0068 )) //">>> usuario nao autenticado: "##"Este usuario nao esta vinculado a um usuario interno do Protheus."
							EndIF

							cRedirect += "auth-error.html"
							oMsgReturn["type"]   := "error"
							oMsgReturn["code"]   := "400"
							oMsgReturn["detail"] := EncodeUTF8(STR0046 + cUser + ' - ' + STR0068) //"Nenhuma matricula localizada para o usuario: "##"Este usuario nao esta vinculado a um usuario interno do Protheus."
						EndIf
					Else
						cRestFault := If( Empty(cMensagem), EncodeUTF8(STR0044), cMensagem) //"Acesso não permitido antes da data de admissão!" ou "login realizado, mas matricula não localizada!"
						lAdmissal  := !Empty(cMensagem)

						If cMeurhLog != "0"
							conout(">>> " + cRestFault + cUser)
						EndIF

						cRedirect += If( lAdmissal, "auth-admissal.html", "auth-error.html" )
						oMsgReturn["type"]   := "error"
						oMsgReturn["code"]   := "400"
						oMsgReturn["detail"] := EncodeUTF8(STR0045 +cUser) //"Nenhuma matricula localizada para o usuario: "
					EndIf
				EndIf

				::SetHeader('Set-Authorization', 'Bearer ' + cToken)
				::SetHeader('Access-Control-Expose-Headers', 'Set-Authorization')

				If !Empty(cToken)

					oMsgReturn["type"]   := "success"
					oMsgReturn["code"]   := "200"
					oMsgReturn["detail"] := EncodeUTF8(STR0001) //"Usuário autenticado"

					If cMeurhLog != "0"
						conout(EncodeUTF8(">>> "                                                 ))
						conout(EncodeUTF8(">>> MeuRH Autentication"                              ))
						conout(EncodeUTF8(STR0043 +cUser +' - ' +cBranchVld +cMatValid)) //">>> usuario autenticado: "
					EndIf

					//Zera o contador de senhas incorretas caso exista na base
					If !lNewLogin .And. lChkUser .And. !Empty(RD0->RD0_ULI)
						If RecLock("RD0", .F.)
							RD0->RD0_ULI := 0
							RD0->( MsUnlock() )
						EndIf
					EndIf
				ElseIf !lAdmissal
					cRedirect += "auth-error.html"
					oMsgReturn["detail"] := EncodeUTF8(STR0047) //"Usuário autenticado, mas token não gerado"

					If cMeurhLog != "0"
						conout(EncodeUTF8(STR0048 +cUser +' - ' +cBranchVld +cMatValid)) //">>> token nao gerado: "
					EndIF
				EndIf
			Else
				If cMeurhLog != "0"
					conout(EncodeUTF8(STR0046 +cUser +' - ' +cRestFault)) //">>> usuario nao autenticado: "
				EndIF

				cRedirect += If(lBlocked, "auth-blocked.html", "auth-error.html")
				oMsgReturn["type"]   := "error"
				oMsgReturn["code"]   := "400"
				oMsgReturn["detail"] := EncodeUTF8(cRestFault)
			EndIf

			Aadd(aMessages, oMsgReturn)

			oItem["data"]           := oItemData
			oItem["messages"]       := aMessages
			oItem["length"]         := 1

			If !lIsWeb
				cString   := Right(cRedirect, 1)
				cRedirect := Iif(cString != "/", cRedirect + "/",cRedirect)
			EndIf

			If lIsWeb
				If "auth-error.html" $ cRedirect .Or. "auth-blocked.html" $ cRedirect .Or. "auth-admissal.html" $ cRedirect
					cJson := '<html><head><title>Moved</title></head><body><script type="text/javascript">window.location="' +cRedirect +'";</script></body></html>'
				Else
					cJson := '<html><head><title>Moved</title></head><body><script type="text/javascript">window.location="'+cRedirect+'?token=' + cToken +  '&restPort=' + Alltrim(cRestPort) + '&keyId=' + Encode64(cKeyId) + '";</script></body></html>'
				EndIf
			Else
				If "auth-error.html" $ cRedirect .Or. "auth-blocked.html" $ cRedirect .Or. "auth-admissal.html" $ cRedirect
					cJson := cRedirect
				Else
					cJson := cRedirect+'?token=' + cToken + '&restPort=' + Alltrim(cRestPort) + '&keyId=' + Encode64(cKeyId)
				EndIf
			EndIf

			::SetResponse(cJson)

			If cMeurhLog != "0"
				conout(EncodeUTF8(">>> Data/Hora: " +dToC(date()) +Space(1) +Time() ))
				conout(EncodeUTF8(">>> Dt/Hr tmz: " +aDtHr[1] +"/" +aDtHr[2] ))
				conout(EncodeUTF8(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"  ))
				conout("")
			EndIF

			//Limpa Objetos
			FreeObj( oItem )
			FreeObj( oItemData )
			FreeObj( oMsgReturn )
			FreeObj( oBody )
		Else
			lRet       := .F.
			cRestFault := EncodeUTF8(STR0042) //"user/password/redirect não localizados na requisição"
		EndIf
	ElseIf nLenParms >= 1 .And. ::aURLParms[1] == "logout"

		//Invalida Bearer Token na camada de framework.
		fLogoutRest(self)

		// ---------------------------------
		// - Elimina o Bearer authorization
		// ---------------------------------

		oItemData["redirect"] := "logout.html"
		::SetHeader('Set-Authorization', '=')

		oMsgReturn["type"]   := "success"
		oMsgReturn["code"]   := "200"
		oMsgReturn["detail"] := EncodeUTF8(STR0002) //"Usuário deslogado"
		oItem["data"] 		:= oItemData
		Aadd(aMessages, oMsgReturn)

		oItem["messages"] 	:= aMessages
		oItem["length"]   	:= 1

		cJson :=  oItem:ToJson()
		::SetResponse(cJson)

		FreeObj( oItemData )
		FreeObj( oMsgReturn )
		FreeObj( oItem )
	EndIf

Return(.T.)


// -------------------------------------------------------------------
// - GET RESPONSÁVEL POR VERIFICAR SE O TOKEN ESTÁ VALIDO.
// -------------------------------------------------------------------
	WSMETHOD GET getLogged WSREST Auth

	Local cJson      := ""
	Local oJson      := JsonObject():New()
	Local cToken     := ""
	Local cMatSRA    := ""
	Local cBranchVld := ""
	Local cLogin     := ""
	Local cKeyId     := ""
	Local aDataLogin := {}

	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
	EndIf

	If Empty(cBranchVld) .Or. Empty(cMatSRA) .Or. Empty(cLogin)
		oJson["isLogged"] := .F.
	Else
		oJson["isLogged"] := .T.
	EndIf

	cJson := oJson:ToJson()
	::SetResponse(cJson)

Return(.T.)


// -------------------------------------------------------------------
// - POST RESPONSÁVEL POR ENVIAR EMAIL PARA O RESET DA SENHA.
// -------------------------------------------------------------------
	WSMETHOD POST getResetLink WSREST Auth

	Local oItemData     := NIL
	Local oItem         := NIL
	Local oMsgReturn    := NIL

	Local cQryRD0       := GetNextAlias()
	Local cQuery        := ""
	Local cBody         := Self:GetContent()
	Local cRestFault    := ""
	Local cJson         := ""
	Local cUrl          := ""
	Local cUrlRedirect  := ""
	Local cTitEmail     := ""
	Local cStrFinal     := ""
	local cRetCrypto    := ""
	Local cUser         := ""
	Local cEmail        := ""
	Local cIdiom        := FWRetIdiom() //Retorna Idioma Atual
	Local cImgMrh       := 'https://tdn.totvs.com/download/thumbnails/728659820/meurh.png'
	Local cImgSen       := 'https://tdn.totvs.com/download/attachments/728659820/esquecisenha.png'
	Local cImgRod       := 'https://tdn.totvs.com/download/thumbnails/728659820/totvs.png'

	Local nPos          := 0
	Local nRstPort      := 0

	Local aValueCookie  := {}
	Local aMessages     := {}
	Local aHtmlMsg      := {}

	Local lRet          := .T.
	Local lRobot        := .F.
	Local lIsWeb        := .F.

	Self:SetContentType("application/json")
	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	If Empty(cBody)
		lRet       := .F.
		cRestFault := EncodeUTF8(STR0054) //"body não localizado na requisição"
	EndIf

	aValueCookie := DecodeURL(cBody)

	nPos           := Ascan(aValueCookie, {|x| x[1] == "user" })
	cUser          := If( nPos > 0, aValueCookie[nPos, 2], "" )
	nPos           := Ascan(aValueCookie, {|x| x[1] == "email" })
	cEmail         := If( nPos > 0, aValueCookie[nPos, 2], "" )
	nPos           := Ascan(aValueCookie, {|x| x[1] == "redirectUrl" })
	cUrlRedirect   := If( nPos > 0, aValueCookie[nPos, 2], "" )
	lRobot         := Ascan(aValueCookie, {|x| x[1] == "execRobo" }) > 0
	lIsWeb         := !('restPort' $ cUrlRedirect)

	If lRet .and. ( Empty(cUser) .Or. Empty(cEmail) )
		lRet       := .F.
		cRestFault := EncodeUTF8(STR0053) //"user/email não localizados na requisição"
	EndIf

	If lRet .and. !RD0->(ColumnPos("RD0_RSTPWD")) > 0
		lRet       := .F.
		cRestFault := EncodeUTF8(STR0063) //"Campo RSTPWD não localizado na tabela RD0"

		If cMeurhLog != "0"
			conout(EncodeUTF8(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"     ))
			conout(EncodeUTF8(">>> MeuRH Reset Password"                                 ))
			conout(EncodeUTF8(">>> " +FwCutOff(STR0065,.T.) +": " +FwCutOff(STR0063,.T.) )) //"aviso"
			conout(EncodeUTF8(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"     ))
		EndIf
	EndIf

	//Obtem o template para envio do email
	If lRet
		cStrFinal := fMRHEmail()
		If !Empty(cStrFinal)
			aadd(aHtmlMsg, cStrFinal)
		EndIf
	EndIf

	If lRet
		If __oSt == NIL
			__oSt := FWPreparedStatement():New()

			cQuery := "SELECT RD0_FILIAL, RD0_CODIGO, RD0_CIC, RD0_LOGIN, RD0_EMAIL, RD0_NOME "
			cQuery += "FROM " + RetSqlName('RD0') + " RD0 "
			cQuery += "WHERE ( RD0.RD0_LOGIN  = ? OR "
			cQuery += "RD0.RD0_LOGIN  = ? OR "
			cQuery += "RD0.RD0_CIC = ? OR "
			cQuery += "RD0.RD0_EMAIL = ? OR "
			cQuery += "RD0.RD0_EMAIL = ? ) AND "
			cQuery += "( RD0.RD0_EMAIL = ? OR "
			cQuery += "RD0.RD0_EMAIL = ? ) AND "
			cQuery += "RD0.D_E_L_E_T_ = ' '"

			__oSt:SetQuery(cQuery)
		EndIf

		//DEFINIÇÃO DOS PARÂMETROS.
		__oSt:SetString(1,cUser)
		__oSt:SetString(2,Upper(cUser))
		__oSt:SetString(3,cUser)
		__oSt:SetString(4,cUser)
		__oSt:SetString(5,Upper(cUser))
		__oSt:SetString(6,cEmail)
		__oSt:SetString(7,Upper(cEmail))

		//RESTAURA A QUERY COM OS PARÂMETROS INFORMADOS.
		cQuery := __oSt:GetFixQuery()

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQryRD0,.T.,.T.)

		If !(cQryRD0)->(Eof())

			dbSelectArea("RD0")
			dbSetOrder(1)
			If dbSeek(xFilial("RD0")+(cQryRD0)->RD0_CODIGO)

				cRetCrypto = rc4crypt( (cQryRD0)->RD0_CODIGO +";"+ cUser +";"+ cEmail +";"+ dToC(date()) +";"+ Time() +";"+ alltrim(str(Randomize(100000,999000))) +";", "MeuRH#P12%Dutchman", .T.)
				//processo crypto - retorno será em código ASCII hexadecimal

				//atualiza hash RD0
				Reclock("RD0",.F.)
				RD0->RD0_RSTPWD := cRetCrypto
				RD0->( MsUnlock() )

				cUrl := cUrlRedirect +"#/resetPassword?hash=" + cRetCrypto //"http://spon4718.sp01.local:8081/T1/#/resetPassword?hash="

				//Quando a chamada ocorre via Mobile remove a RestPort da URL a partir da última "/"
				If !lIsWeb
					nRstPort := RAT( "/", cUrlRedirect )
					cUrl := SubStr( cUrlRedirect, 1, nRstPort )
					cUrl += "#/resetPassword?hash=" + cRetCrypto //"http://spon4718.sp01.local:8081/T1/#/resetPassword?hash="
				EndIf

				cUrl := If( lIsWeb, cUrlRedirect +"#/resetPassword?hash=" + cRetCrypto, cUrl ) //"http://spon4718.sp01.local:8081/T1/#/resetPassword?hash="

				aNome := strtokarr((cQryRD0)->RD0_NOME, " ")
				If Len(aNome) > 0
					aHtmlMsg[1] := StrTran( aHtmlMsg[1], "%first_name%", aNome[1] )
				Else
					aHtmlMsg[1] := StrTran( aHtmlMsg[1], "%first_name%", " " )
				EndIf
				aHtmlMsg[1]    := StrTran( aHtmlMsg[1], "%link_pwd%", cUrl )

				If cIdiom == 'en'
					aHtmlMsg[1]    := StrTran( aHtmlMsg[1], "%date_time%", fDateIng() +" "+ SUBSTR(TIME(), 1, 5) )
				Else
					aHtmlMsg[1]    := StrTran( aHtmlMsg[1], "%date_time%", cValToChar(day( Date() )) +" de " +mesextenso( Date() ) +" de " +cValToChar(year( Date() )) +" "+ SUBSTR(TIME(), 1, 5) )
				EndIf

				aHtmlMsg[1] := StrTran( aHtmlMsg[1], "%img_Meurh%", cImgMrh )
				aHtmlMsg[1] := StrTran( aHtmlMsg[1], "%img_header%", cImgSen )
				aHtmlMsg[1] := StrTran( aHtmlMsg[1], "%img_bottom%", cImgRod )

				cTitEmail      := EncodeUTF8(STR0078)  //"MeuRH Esqueci minha senha"

				//Dispara e-mail
				If !lRobot
					lRet := MrhMail(cTitEmail, aHtmlMsg[1], Lower(Alltrim((cQryRD0)->RD0_EMAIL)), @cRestFault )
				EndIf
			Else
				lRet       := .F.
				cRestFault := EncodeUTF8(STR0062) //"Participante não localizado na RD0"
			EndIf

		else
			lRet       := .F.
			cRestFault := EncodeUTF8(STR0052) //"usario/email não localizado na base de dados"
		EndIf

		(cQryRD0)->( DbCloseArea() )
	EndIf

	oItem       := JsonObject():New()
	oItemData   := JsonObject():New()
	oMsgReturn  := JsonObject():New()

	If lRet
		oItemData["user"]        := cUser
		oItemData["redirectUrl"] := cUrlRedirect
		oItemData["email"]       := cEmail

		oMsgReturn["type"]       := "success"
		oMsgReturn["code"]       := "200"
		//STR0055 - "link para reset da senha enviado por e-mail"
		//STR0128 - "Caso o usuário e o email estejam corretos, em alguns instantes você receberá um email com instruções para redefinir sua senha"
		oMsgReturn["detail"]     := If(lRobot, EncodeUTF8(STR0055), EncodeUTF8(STR0128))
		Conout(">>>>> " + EncodeUTF8(STR0055) + " <<<<<")
		Aadd(aMessages, oMsgReturn)
	Else
		oMsgReturn["type"]       := "error"
		oMsgReturn["code"]       := "400"
		oMsgReturn["detail"]     := If(lRobot, cRestFault, EncodeUTF8(STR0128)) //"Caso o usuário e o email estejam corretos, em alguns instantes você receberá um email com instruções para redefinir sua senha"
		Conout(">>>>> " + cRestFault + " <<<<<")
		Aadd(aMessages, oMsgReturn)
	EndIf

	oItem["data"]     := oItemData
	oItem["messages"] := aMessages
	oItem["length"]   := 1

	cJson :=  oItem:ToJson()
	Self:SetResponse(cJson)

Return(.T.)



// -------------------------------------------------------------------
// - PUT RESPONSÁVEL POR ATUALIZAR A SENHA DO USUÀRIO.
// -------------------------------------------------------------------
	WSMETHOD PUT editPassword WSREST Auth

	Local oItemDetail   := JsonObject():New()
	Local oItemData     := JsonObject():New()
	Local oItem         := JsonObject():New()
	Local oMsgReturn    := JsonObject():New()
	Local cBody         := ::GetContent()
	Local nLenParms     := Len(::aURLParms)
	Local nPolSeg       := GetMv("MV_POLSEG", .F. , 0)
	Local nHashVld      := (GetMv("MV_HASHVLD",,60) == 0, 60)
	Local lChkRules     := nPolSeg > 0 .And. FindFunction("MPPSWVAULT") //A partir da LIB de 13/04/2021
	Local lRet          := .T.
	Local lRC4          := .T.
	Local aMessages     := {}
	local aKey          := {}
	Local cRestFault    := ""
	Local cJson         := ""
	local cKey          := ""
	local cValidTime    := ""
	Local nCheck        := 0
	Local nTamPass      := 0

	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	If !Empty(cBody)
		oItemDetail:FromJson(cBody)
	EndIf

	If nLenParms >= 1 .And. ::aURLParms[1] == "resetPassword"
		//a hash foi retirada da URL e passada para o body
		//varinfo("hash recebida     : ", ::aURLParms[2] )

		If !Empty(cBody) .and. lRet

			If Empty(oItemDetail["hash"]) .Or. Empty(oItemDetail["password"])
				lRet       := .F.
				cRestFault := EncodeUTF8(STR0108) //"Requisição inválida para mudança de senha."
			EndIf

			nTamPass := If( !Empty(oItemDetail["password"]), Len(Alltrim(oItemDetail["password"])), 0 )

			If nPolSeg == 0 .And. ( nTamPass > 6 .Or. nTamPass < 3 )
				lRet       := .F.
				cRestFault := EncodeUTF8(STR0110) //"A senha deve ter no mínimo 3 e no máximo 6 caracteres."
			ElseIf nTamPass < 3
				cRestFault := EncodeUTF8(STR0109) //"A senha deve ter no mínimo 3 caracteres."
				lRet       := .F.
			EndIf

			If lRet
				// processo descriptografia
				BEGIN SEQUENCE
					cKey := rc4crypt( oItemDetail["hash"], "MeuRH#P12%Dutchman", .F., .T. )

					// verifica validade do hash
					aKey := STRTOKARR(cKey, ";")
					//varinfo("aKey: ", aKey)

					//Valida data e hora recebida no hash
					aDiffDatas := DateDiffYMD( aKey[4] , date() )
					//varinfo("Data Max: ", aKey[4] )
					//varinfo("Data Atu: ", Date() )
					RECOVER
					lRC4 := .F.
				END SEQUENCE

				//Checa a politica de senhas
				If nPolSeg > 0

					//Checa se a nova senha atende as regras de preenchimento de senhas do Protheus
					If lChkRules
						lRet := fPwdRules( aKey[1], Alltrim(oItemDetail["password"]), @cRestFault )
					EndIf

					If lRet
						nCheck     := If( lChkRules, 2, 1 )
						cRestFault := EncodeUTF8( fPwdValid( alltrim(oItemDetail["password"]), nCheck, , lChkRules ) )
						lRet       := Empty(cRestFault)
					EndIf

				EndIf

			EndIf

			If lRet

				If aDiffDatas[3] > 0 .or. !lRC4
					//hash: data fora da validade! solicite novamente.
					lRet       := .F.
					cRestFault := EncodeUTF8(STR0067) //"Link incorreto ou expirado. Solicite novamente outro link!"

					//limpa hash na RD0
					dbSelectArea("RD0")
					dbSetOrder(1)
					If dbSeek(xFilial("RD0") + alltrim(aKey[1]))
						If alltrim(RD0->RD0_RSTPWD) == alltrim(oItemDetail["hash"])
							Reclock("RD0",.F.)
							RD0->RD0_RSTPWD := ""
							RD0->( MsUnlock() )
						EndIF
					EndIf

				Else
					//nSegundos := ELAPTIME( "10:00:00", TIME() )
					//varinfo("Dif segundos : ", nSegundos )
					//IncTime([<cTime>],<nIncHours>,<nIncMinuts>,<nIncSeconds> ) -> Somar
					//DecTime([<cTime>],<nDecHours>,<nDecMinuts>,<nDecSeconds> ) -> Subtrair

					cValidTime := IncTime( aKey[5] , 0 , nHashVld , 0 )
					//varinfo("Hora Max: ", cValidTime )
					//varinfo("Hora Atu: ", Time() )

					If Time() > cValidTime
						//"hash: hora fora da validade! solicite novamente."
						lRet       := .F.
						cRestFault := EncodeUTF8(STR0067) //"Link incorreto ou expirado. Solicite novamente outro link!"

						//limpa hash na RD0
						dbSelectArea("RD0")
						dbSetOrder(1)
						If dbSeek(xFilial("RD0") + alltrim(aKey[1]))
							If alltrim(RD0->RD0_RSTPWD) == alltrim(oItemDetail["hash"])
								Reclock("RD0",.F.)
								RD0->RD0_RSTPWD := ""
								RD0->( MsUnlock() )
							EndIF
						EndIf
					Else

						//pesquisa hash na tabela RD0 e atualiza nova senha
						If RD0->(ColumnPos("RD0_RSTPWD")) > 0
							dbSelectArea("RD0")
							dbSetOrder(1)
							If dbSeek(xFilial("RD0")+ aKey[1])

								If RD0->RD0_RSTPWD != oItemDetail["hash"]
									//HASH recebida invalida/não confere
									lRet       := .F.
									cRestFault := EncodeUTF8(STR0067) //"Link incorreto ou expirado. Solicite novamente outro link!"
								EndIf

								If lRet .And. nPolSeg > 0
									cRestFault := EncodeUTF8( fPwdValid( alltrim(oItemDetail["password"]), 2, , lChkRules ) )

									If !Empty(cRestFault)
										lRet := .F.
									EndIf
								EndIf

								If lRet .And. !fPwdChange( AllTrim(oItemDetail["password"]) )
									lRet       := .F.
									cRestFault := EncodeUTF8(STR0102) //"Não foi possível a atualização da senha no momento!"
								EndIf

							Else
								lRet       := .F.
								cRestFault := EncodeUTF8(STR0062) //"Participante não localizado na RD0"
							EndIf
						Else
							lRet       := .F.
							cRestFault := EncodeUTF8(STR0063) //"Campo RSTPWD não localizado na tabela RD0"

							If cMeurhLog != "0"
								conout(EncodeUTF8(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"     ))
								conout(EncodeUTF8(">>> MeuRH Reset Password"                                 ))
								conout(EncodeUTF8(">>> " +FwCutOff(STR0065,.T.) +": " +FwCutOff(STR0063,.T.) )) //"aviso"
								conout(EncodeUTF8(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"     ))
							EndIf

						EndIf

					EndIf
				EndIf

			EndIf
		Else
			lRet       := .F.
			cRestFault := EncodeUTF8(STR0059) //"body não localizado na requisição"
		EndIf

	Else
		lRet       := .F.
		cRestFault := EncodeUTF8(STR0060) //"servico pwd invalido"
	EndIf


	If lRet
		oItemData["password"] := oItemDetail["password"]
		oItemData["hash"]     := oItemDetail["hash"]

		oMsgReturn["type"]    := "success"
		oMsgReturn["code"]    := "200"
		oMsgReturn["detail"]  := EncodeUTF8(STR0061) //"senha atualizada com sucesso"
		Aadd(aMessages, oMsgReturn)

		oItem["data"]          := oItemData
		oItem["messages"]      := aMessages
		oItem["length"]        := 1
		cJson                  := oItem:ToJson()
		::SetResponse(cJson)
	Else
		SetRestFault(400, cRestFault, , , cRestFault)
	EndIf

Return(lRet)


// -------------------------------------------------------------------
// - GET RESPONSÁVEL POR VERIFICAR SE É O PRIMEIRO LOGIN DO USUÁRIO.
// -------------------------------------------------------------------
	WSMETHOD GET isFirstLogin WSREST Auth

	Local oItem          := JsonObject():New()
	Local nPolSeg        := GetMv("MV_POLSEG", .F. , 0)
	Local lSenhaC        := RD0->(ColumnPos("RD0_SENHAC")) > 0
	Local lExitCpo       := RD0->(ColumnPos("RD0_RSTPWD")) > 0
	Local cToken         := ""
	Local cLogin         := ""
	Local cSenha         := ""
	Local cValid         := ""
	Local cBranchVld     := ""
	Local cCodVld        := ""
	Local cHash          := ""
	Local lSHA512        := .F.
	Local lFirst         := .F.
	Local aDataLogin     := {}

	If lSenhaC
		lSHA512	:= IIf(TamSX3("RD0_SENHAC")[1]==128, .T. , .F.)
	EndIf

	cToken     := Self:GetHeader('Authorization')

	aDataLogin := GetDataLogin(cToken)
	If Len(aDataLogin) > 0
		cLogin       := aDataLogin[2]
		cBranchVld   := aDataLogin[5]
		cCodVld      := aDataLogin[3]
	EndIf

	If !Empty(cLogin) .And. lExitCpo .And. GetRpoRelease() >= "12.1.025

		dbSelectArea("RD0")
		dbSetOrder(1)
		If dbSeek(xFilial("RD0", cBranchVld) + cCodVld)

			//Senha padrão do ERP.
			// Dois últimos digitos do ano de nascimento + dois dígitos do dia da admissão + dois últimos dígitos do CPF
			cSenha := SubStr(dToS(RD0->RD0_DTNASC),3,2) + SubStr(dToC(RD0->RD0_DTADMI),1,2) + SubStr(RD0->RD0_CIC,10,2)

			//Se a senha cadastrada para o usuário for igual da senha padrão do ERP, Então solicita troca de senha.
			If nPolSeg == 0 .And. Upper(AllTrim(Embaralha(RD0->RD0_SENHA,1))) == cSenha
				lFirst := .T.
			EndIf

			If nPolSeg > 0 .And. lSenhaC
				If lSHA512
					//Cliente possui tamanho do campo RD0_SENHAC atualizado no dicionario
					cValid := SHA512(AllTrim(cSenha))
				Else
					//Cliente possui tamanho padrão(40) do campo RD0_SENHAC no dicionario
					cValid := SHA1(AllTrim(cSenha))
				EndIf

				If cValid == RD0->RD0_SENHAC
					lFirst := .T.
				EndIf
			EndIf

			If lFirst
				cHash  := rc4crypt( RD0->RD0_CODIGO +";" +cLogin +";" + RD0->RD0_EMAIL +";" +dToC(date()) +";" +Time() +";" +alltrim(str(Randomize(100000,999000))) +";" ,"MeuRH#P12%Dutchman", .T.)

				//ATUALIZA O CAMPO RD0_RSTPWD COM O NOVO HASH
				RecLock("RD0", .F.)
				RD0->RD0_RSTPWD := cHash
				MsUnLock()
			EndIf
		EndIf

	EndIf

	oItem["isFirstLogin"]  := lFirst

	cJson :=  oItem:ToJson()
	::SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// - REALIZA A TROCA DE SENHA DO USUARIO
// -------------------------------------------------------------------
	WSMETHOD POST ChangePassWithLastPass WSREST Auth

	Local cJson			:= JsonObject():New()
	Local oItemDetail	:= JsonObject():New()
	Local cBody			:= ::GetContent()
	Local lRet			:= .T.
	Local lRobot      := .F.
	Local cToken		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cCodVld		:= ""
	Local cLogin		:= ""
	Local cLastPwd		:= ""
	Local cFormLogin	:= ""
	Local cFormLastPwd:= ""
	Local cFormNewPwd	:= ""
	Local cFormPwdOk	:= ""
	Local cMsgErro		:= ""
	Local cPPAccess   := GetMv("MV_ACESSPP",,"")
	Local nPolSeg		:= GetMv("MV_POLSEG", .F. , 0)
	Local lExitCpo		:= RD0->(ColumnPos("RD0_RSTPWD")) > 0
	Local lLoginVld   := .T.
	Local lChkRules   := nPolSeg > 0 .And. FindFunction("MPPSWVAULT") //A partir da LIB de 13/04/2021
	Local nCheck      := 0
	Local aDataLogin  := {}

	cToken := Self:GetHeader('Authorization')

	aDataLogin  := GetDataLogin(cToken)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cCodVld      := aDataLogin[3]
	EndIf

	If !lExitCpo .Or. Empty(cBranchVld) .Or. Empty(cMatSRA) .Or. Empty(cCodVld) .Or. Empty(cBody)
		cMsgErro := EncodeUTF8(STR0090) //"Usuário ou senha inválidos."
		lRet     := .F.
	Else
		oItemDetail:FromJson(cBody)

		lLoginVld      := If( oItemDetail:hasProperty("user") .And. !Empty( AllTrim(oItemDetail["user"]) ), .T., .F. )
		cFormLogin     := If(lLoginVld, AllTrim(oItemDetail["user"]), aDataLogin[2]) // Se não vier login ou for vazio, utiliza o login do token
		cFormLastPwd   := If(oItemDetail:hasProperty("lastPassword"), oItemDetail["lastPassword"], "")
		cFormNewPwd    := If(oItemDetail:hasProperty("password"), oItemDetail["password"], "")
		cFormPwdOk     := If(oItemDetail:hasProperty("confirmPassword"), oItemDetail["confirmPassword"], "")
		lRobot         := If(oItemDetail:hasProperty("execRobo"), oItemDetail["execRobo"], "0") == "1"

		//Remove o encode64
		If lLoginVld
			cFormLogin := DECODE64( cFormLogin )
			cFormLogin := fRemoveStr( cFormLogin )
			cFormLogin := fInvString(cFormLogin)
		EndIf
		cFormLastPwd   := DECODE64( cFormLastPwd)
		cFormNewPwd    := DECODE64( cFormNewPwd )
		cFormPwdOk     := DECODE64( cFormPwdOk )

		// Remove as strings especiais definidas
		cFormLastPwd   := fRemoveStr( cFormLastPwd )
		cFormNewPwd    := fRemoveStr( cFormNewPwd )
		cFormPwdOk     := fRemoveStr( cFormPwdOk )

		//Desembaralha as strings.
		cFormLastPwd   := AllTrim( fInvString(cFormLastPwd) )
		cFormNewPwd    := AllTrim( fInvString(cFormNewPwd) )
		cFormPwdOk     := AllTrim( fInvString(cFormPwdOk) )

		cFormLogin     := UPPER(cFormLogin)
		If nPolSeg == 0
			//Transforma em maiúsculas.
			cFormLastPwd:= UPPER(cFormLastPwd)
			cFormNewPwd := UPPER(cFormNewPwd)
			cFormPwdOk  := UPPER(cFormPwdOk)
		EndIf


		If lRet .And. ;
				( Empty(cFormLogin) .Or. Empty(cFormLastPwd) .Or. Empty(cFormNewPwd) .Or. !( cFormNewPwd == cFormPwdOk ) )
			cMsgErro := EncodeUTF8(STR0090) //"Usuário ou senha inválidos."
			lRet     := .F.
		Else
			If lRet .And. nPolSeg > 0

				//Checa se a nova senha atende as regras de preenchimento de senhas do Protheus
				If lChkRules
					lRet := fPwdRules( cCodVld, cFormNewPwd, @cMsgErro )
				EndIf

				If lRet
					nCheck   := If( lChkRules, 2, 1 )
					cMsgErro := EncodeUTF8( fPwdValid( alltrim(cFormNewPwd), nCheck, , lChkRules ) )
					lRet     := Empty(cMsgErro)
				EndIf

			EndIf

			If lRet .And. nPolSeg == 0 .And. ( Len( AllTrim( cFormNewPwd ) ) > 6 .Or. Len( AllTrim( cFormPwdOk ) ) > 6 )
				cMsgErro := EncodeUTF8(STR0091) //"A senha deve ter no máximo 6 caracteres."
				lRet     := .F.
			EndIf

			If lRet .And. nPolSeg == 0 .And. cFormLastPwd == cFormNewPwd
				cMsgErro := EncodeUTF8(STR0093) //"A nova senha não pode ser igual a última cadastrada."
				lRet     := .F.
			EndIf

			If lRet
				dbSelectArea("RD0")
				dbSetOrder(1)

				If dbSeek( xFilial("RD0", cBranchVld) + cCodVld )

					//Obtem os dados do login existente antes da atualizacao
					If !Empty( AllTrim( RD0->RD0_LOGIN ) )
						//Considera o campo login de forma prioritaria
						cLogin := UPPER( AllTrim( RD0->RD0_LOGIN ) )
					Else
						//Caso contrario considera os campos CPF ou Email conforme o parametro MV_ACESSPP
						cLogin := If( cPPAccess == "1", UPPER(AllTrim(RD0->RD0_EMAIL)), UPPER(AllTrim(RD0->RD0_CIC)) )
					EndIf

					cLastPwd	:= UPPER( AllTrim( Embaralha( RD0->RD0_SENHA,1 ) ) )

					//Verifica se os dados recebidos na requisicao estao corretos
					If !(cLogin == cFormLogin)
						lRet     := .F.
						cMsgErro := EncodeUTF8( STR0094 )
					ElseIf nPolSeg == 0 .And. !(cLastPwd == cFormLastPwd)
						lRet     := .F.
						cMsgErro := EncodeUTF8( STR0095 ) //"A senha antiga está incorreta."
					Else
						If lRet .And. nPolSeg > 0
							cMsgErro := EncodeUTF8( fPwdValid( Alltrim(cFormNewPwd), 2, AllTrim(cFormLastPwd), lChkRules) )

							If !Empty(cMsgErro)
								lRet := .F.
							EndIf
						EndIf

						If lRet .And. !fPwdChange( AllTrim(cFormNewPwd) )
							lRet     := .F.
							cMsgErro := EncodeUTF8(STR0102) //"Não foi possível a atualização da senha no momento!"
						EndIf
					EndIf
				Else
					lRet     := .F.
					cMsgErro := EncodeUTF8(STR0102) //"Não foi possível a atualização da senha no momento!"
				EndIf
			EndIf

		EndIf

	EndIf

	If lRet
		//Invalida Bearer Token na camada de framework.
		fLogoutRest(Self)

		cJson := oItemDetail:ToJson()
		::SetResponse(cJson)
	Else
		If lRobot
			lRet := .T.
			oItemDetail        			 := JsonObject():New()
			oItemDetail["errorCode"] 	 := "400"
			oItemDetail["errorMessage"] := cMsgErro
			cJson := oItemDetail:ToJson()
			::SetResponse(cJson)
		Else
			SetRestFault(400, cMsgErro)
		EndIf
	EndIf

Return( lRet )



//***************************************
// Métodos REST CONTEXT
//***************************************

// ---------------------------------------------------------------
// - GET RESPONSÁVEL POR RETORNAR OS CONTEXTOS DO USUÁRIO LOGADO.
// ---------------------------------------------------------------
	WSMETHOD GET getAllContexts  WSREST Setting

	Local oItem       := JsonObject():New()
	Local oMessages   := JsonObject():New()
	Local oValida     := JsonObject():New()
	Local cBranchVld  := ""
	Local cMatSRA     := ""
	Local cLogin      := ""
	Local cToken      := ""
	Local cKeyId      := ""
	Local aItemCtx    := {}
	Local aDadosCtx   := {}
	Local aMessages   := {}
	Local aDataLogin  := {}


	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken  := Self:GetHeader('Authorization')
	cKeyId  := Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
	EndIf

	If Empty(cBranchVld) .Or. Empty(cMatSRA) .Or. Empty(cLogin)
		oMessages["type"]   := "error"
		oMessages["code"]   := "401"
		oMessages["detail"] := EncodeUTF8(STR0086) //"Dados inválidos para validação do contexto."

		Aadd(aMessages,oMessages)
	Else
		//Busca multiplus vínculos
		getMultV(cBranchVld,cMatSRA,cLogin,@aDadosCtx,@aItemCtx,.T.)
	EndIf


// - Por por padrão todo objeto tem
// - data: contendo a estrutura do JSON
// - messages: para determinados avisos
// - length: informativo sobre o tamanho.
	oItem["data"]   := Iif(Empty(aDadosCtx),oValida,aDadosCtx)
	oItem["length"] := Iif(Empty(aDadosCtx),1,Len(aDadosCtx))
	If Len(aDadosCtx) < 1
		oMessages["type"]   := "info"
		oMessages["code"]   := ""
		oMessages["detail"] := EncodeUTF8(STR0087) //"Nenhuma matrícula localizada no serviço de contexto."

		Aadd(aMessages, oMessages)
	EndIf
	oItem["messages"] := aMessages

	cJson := oItem:ToJson()
	::SetResponse(cjson)

	FREEOBJ( oItem )
	FREEOBJ( oMessages )
	FREEOBJ( oValida )

Return(.T.)

// -------------------------------------------------------------------
// - GET RESPONSÁVEL POR RETORNAR O CONTEXTO ATUAL DO USUÁRIO LOGADO.
// -------------------------------------------------------------------
	WSMETHOD GET getContext  WSREST Setting

	Local cBranchVld    := ""
	Local cMatSRA       := ""
	Local cLogin        := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local aItemCtx      := {}
	Local aDadosCtx     := {}
	Local aDataLogin    := {}


	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken  := Self:GetHeader('Authorization')
	cKeyId  := Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
	EndIf

	If Empty(cBranchVld) .Or. Empty(cMatSRA) .Or. Empty(cLogin)
		cJson := resultSetContext(,.F.)
	Else
		//Carrega contexto atual
		getMultV(cBranchVld,cMatSRA,cLogin,@aDadosCtx,@aItemCtx,.F.)

		//prepara json retorno
		cJson := resultSetContext(aItemCtx,.F.)
	EndIf

	::SetResponse(cjson)

Return(.T.)

// --------------------------------------------------------------
// - PUT RESPONSÁVEL POR ATUALIZAR O CONTEXTO DO USUÁRIO LOGADO.
// --------------------------------------------------------------
	WSMETHOD PUT setContext WSREST Setting
	Local oItemDetail   := JsonObject():New()
	Local cBody         := ::GetContent()
	Local aArea         := GetArea()
	Local aItemCtx      := {}
	Local aEmployeeID   := {}
	Local aDadosCtx     := {}
	Local aDataLogin    := {}
	Local cToken        := ""
	Local cKey          := ""
	Local cBranchVld    := ""
	Local cMatSRA       := ""
	Local cLogin        := ""
	Local cUserId       := ""
	Local cDemit        := ".F."
	Local lCpoRD0       := RD0->(ColumnPos("RD0_FILRH")) > 0

	cToken      := Self:GetHeader('Authorization')

	aDataLogin := GetDataLogin(cToken)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
	EndIf

	If !Empty(cBody)
		//******parse employeeID, exemplo:
		// "{"current":false,"branchName":"COORDENAÇÃO RH MOBILE         ","status":"active","companyName":"Filial BELO HOR/Grupo TOTVS 1","employeeID":"D MG 01 |00502 |000207","employeeType":"internal"}"

		oItemDetail:FromJson(cBody)
	EndIf


	If Empty(cBranchVld) .Or. Empty(cMatSRA) .Or. Empty(cLogin) .Or. Empty(cBody)
		cJson := resultSetContext(,.T.)
	Else
		aEmployeeID := StrTokArr(oItemDetail["employeeID"], "|")
		//varinfo("aEmployeeID: ",aEmployeeID)

		dbSelectArea("RD0")
		RD0->(dbSetOrder(1))
		If RD0->(dbSeek( xFilial("RD0") + aEmployeeID[3] ))
			//Busca UserID do Portal para geração do token
			cUserID := GetConfig("RESTCONFIG","userId", "")

			If Empty(cUserID) //nova pesquisa em virtude da atualização do appWebWizard
				cUserID := GetConfig("HTTPREST","userId", "")
			EndIf

			//Busca usuario do portal baseado no usuário do RD0
			If Empty(cUserID)
				dbSelectArea("AI3")
				AI3->(dbSetOrder(1))
				If AI3->(dbSeek( xFilial("AI3")+RD0->RD0_PORTAL ))
					cUserID := UsrRetName(AI3->AI3_USRSIS)
				Else
					If lCpoRD0 .And. AI3->(dbSeek(xFilial("AI3", RD0->RD0_FILRH)+RD0->RD0_PORTAL))
						cUserID := UsrRetName(AI3->AI3_USRSIS)
					EndIf
				EndIf
			EndIf

			dbSelectArea("SRA")
			SRA->(dbSetOrder(1))
			If SRA->(DbSeek( aEmployeeID[1] + aEmployeeID[2] ) )
				cDemit := If( SRA->RA_SITFOLH $ "D/T", ".T.", ".F." )
			EndIf

			//carrega matricula e filial para o novo contexto solicitado
			cKey := aEmployeeID[2] +"|" +cLogin +"|" +RD0->RD0_CODIGO +"|" +DtoS(dDataBase) +"|" +aEmployeeID[1] + "|" + cDemit

			//Gera token
			If !Empty(cUserID)
				//Retirada a passagem de data e segundos para a funcao FwJWT2Bear por orientacao do Framework - 01/2019
				cToken := FwJWT2Bear(cUserID,{"payments/","payment/","data/","team/", "request/", "timesheet/", "/team/", "setting/"},Nil,Nil,Nil,Nil,{ {"key",cKey} })
			EndIf

			//configura o header
			::SetHeader('Access-Control-Allow-Credentials' , "true")
			::SetHeader('Access-Control-Expose-Headers', 'Set-Authorization')
			::SetHeader('Set-Authorization', 'Bearer ' + cToken)

			//prepara informações
			getMultV( aEmployeeID[1],aEmployeeID[2],cLogin,@aDadosCtx,@aItemCtx,.F.)
		EndIf

		//prepara json retorno
		cJson := resultSetContext(aItemCtx,.T.)
	EndIf

	RestArea(aArea)
	::SetResponse(cjson)
	FREEOBJ( oItemDetail )

Return (.T.)


// --------------------------------------------------------
// - GET RESPONSÁVEL PARA AVALIAR AS PERMISSÕES DE ACESSO.
// --------------------------------------------------------
	WSMETHOD GET getPermissions  WSREST Setting

	Local cJson          := ""
	Local cToken         := ""
	Local cMatSRA        := ""
	Local cLogin         := ""
	Local cRD0Cod        := ""
	Local cKeyId         := ""
	Local cBranchVld     := ""
	Local cServManager   := ""
	Local cServDemit     := ""
	Local cServEstag     := ""
	Local cServSubst     := ""
	Local cServPwd       := ""
	Local cSubReques     := ""
	Local lOrgCfg        := SuperGetMv("MV_ORGCFG", NIL, "0") == "0"
	Local oPermissions   := JsonObject():New()
	Local lDemit         := .F.
	Local lEmployManager := .F.
	Local lEstag         := .F.
	Local lIsSubst       := .F.
	Local cHabil         := "1"
	Local nPos           := 0
	Local aServices      := {}
	Local aDataLogin     := {}
	Local nX             := 0
	Local lSolicFeAb     := .T. // Acesso à solicitar abono durante o processo de solicitação de férias.

//Servicos gerenciais que sao disponiveis apenas para quem possui equipe
	cServManager += "clockingGeoView||clockingGeoDisconsider||substituteRequest||absenceManager||teamManagement||requisitions||demission||demissionRequest||
	cServManager += "managementOfDelaysAndAbsences||dashboardBalanceTeamSum||"

	cSubReques += "substituteRequest"
// Acesso à requisição de ação salarial e inclusão de ação salarial
	cServManager += "employeeDataChange||employeeDataChangeRequest||"

// Acesso à requisição de transferência e inclusão de transferência.
	cServManager += "transfer||transferRequest||"

//Servicos disponiveis para funcionarios demitidos
	cServDemit += "payment||annualReceipt"

// Acesso às notificações de Férias e ( Ponto + Abono )
	cServSubst   := "notificationClocking||notificationVacation||notificationAllowance||"

//Serviços de férias não disponíveis para estagiários
	cServEstag := "downloadVacationReceipt||vacation||vacationNotice||vacationReceipt||vacationRegister"

//Serviços relacionados a senha (nao permitido no login integrado Protheus/AD)
	cServPwd  := "alterPassword"

	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  := Self:GetHeader('Authorization')
	cKeyId  := Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cLogin       := aDataLogin[2]
		cRD0Cod      := aDataLogin[3]
		lDemit       := aDataLogin[6]
	EndIf

//varinfo("URLParams     : ", ::aURLParms)

	If !Empty(::aURLParms[1]) .And. ::aURLParms[1] == "permissions"

		//Carrega lista de permissionamentos do usuário de portal logado
		aServices  := fPermission(cBranchVld , cLogin, cRD0Cod)

		lSolicFeAb := GetMvMrh("MV_MRHFEAB", .F., .T., cBranchVld)
		aAdd(aServices, { "vacationBonusView"              , Iif(lSolicFeAb, "1", "2"), STR0111, STR0112, "006", .F.  }) //Férias //Ocultar abono pecuniário durante a solicitação de férias
		aAdd(aServices, { "teamManagementVacationBonusView", Iif(lSolicFeAb, "1", "2"), STR0111, STR0112, "007", .F.  }) //Férias //Ocultar abono pecuniário durante a solicitação de férias

		//Verifica dashboardBalanceSummary com o balanceSummary, default = "1"
		If ( nPos := aScan( aServices,{ |x| x[1] == "balanceSummary" } ) ) > 0
			cHabil := aServices[nPos,2]
		EndIf
		aAdd(aServices, { "dashboardBalanceSummary", cHabil, STR0116, STR0117, "009", .F.  }) //Home  //Visualizar saldo do banco de horas

		//Verifica permissão das notificações de ponto. Se estiver habilitada, habilita o abono também. Default = "1"
		If ( nPos := aScan( aServices,{ |x| x[1] == "notificationClocking" } ) ) > 0
			cHabil := aServices[nPos,2]
		EndIf
		aAdd(aServices, { "notificationAllowance", cHabil, STR0119, STR0118, "010", .F.  }) //Home  //Acesso as notificações de abono.

		If !lDemit
			//Indica se o funcionario e responsavel por algum departamento
			lEmployManager := fGetTeamManager(cBranchVld, cMatSRA)
			//Indica se o funcionario é estagiário
			lEstag := fSraVal(cBranchVld, cMatSRA, "RA_CATFUNC") $ "E|G"
			//Indica se o funcionário logado está substituindo o gestor.
			lIsSubst := Len( fGetSupNotify( cBranchVld, cMatSRA ) ) > 0 .Or. fChkRH3Apr(cBranchVld, cMatSRA)
		EndIf

		For nX := 1 To Len( aServices )
			If lDemit
				If aServices[nX,1] $ cServDemit
					oPermissions[ aServices[nX,1] ] := aServices[nX,2] == "1"
				else
					oPermissions[ aServices[nX,1] ] := .F.
				EndIf
			Else
				If aServices[nX,1] $ cServManager
					If aServices[nX,1] == cSubReques
						oPermissions[ aServices[nX,1] ] :=  lOrgCfg .And. aServices[nX,2] == "1" .And. lEmployManager
					Else
						oPermissions[ aServices[nX,1] ] := aServices[nX,2] == "1" .And. lEmployManager
					EndIf
				Else
					If aServices[nX,1] $ cServSubst
						oPermissions[ aServices[nX,1] ] := aServices[nX,2] == "1" .And. ( lEmployManager .Or. lIsSubst )
					elseIf aServices[nX,1] $ cServEstag
						oPermissions[ aServices[nX,1] ] := aServices[nX,2] == "1" .And. !lEstag
					elseIf aServices[nX,1] $ cServPwd
						oPermissions[ aServices[nX,1] ] := aServices[nX,2] == "1" .And. Empty(cKeyId)
					Else
						oPermissions[ aServices[nX,1] ] := aServices[nX,2] == "1"
					EndIf
				EndIf
			EndIf
		Next nX

		cJson := oPermissions:ToJson()
	EndIf

//varinfo("cJson: ",cJson)
	::SetResponse(cJson)

Return(.T.)

// --------------------------------------------------------------------
// - GET RESPONSÁVEL PARA AVALIAR AS PERMISSÕES ATUALIZAÇÃO DE CAMPOS.
// --------------------------------------------------------------------
	WSMETHOD GET getFieldProperties  WSREST Setting

	Local oItem      := NIL
	Local oProps     := NIL

	Local aData      := {}
	Local aDataLogin := {}

	Local cJson      := ""
	Local cToken     := ""
	Local cKeyId     := ""
	Local cMatSRA    := ""
	Local cBranchVld := ""

	Local lDemit     := .F.
	Local lSolicFe13 := .T.
	Local lIntNg	 := .F.

	Local nLenParms  := Len(::aURLParms)

	::SetContentType("application/json")
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  := Self:GetHeader('Authorization')
	cKeyId  := Self:GetHeader('keyId')

	aDataLogin   := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
		cRD0Cod      := aDataLogin[3]
		cLogin       := aDataLogin[2]
		lDemit       := aDataLogin[6]
	EndIf

//pageFilter
// payment, vacation, clocking, allowance, profile, notification, occurrence, clockingGeoUpdate, clockingRegister, clockingUpdate
// varinfo("URLParams: ", ::aURLParms)

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "dailysummary"
		fSetFieldP( "total", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "notification"
		//Motivo de rejeicao (para apresentar o motivo)
		fSetFieldP( "reprovedReason", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "reason", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "workleave"
		//Motivo de rejeicao (para apresentar o motivo)
		fSetFieldP( "initHour", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "endHour", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "hours", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "origin", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "teammanagement"
		fSetFieldP( "registry", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "teamAdvancedSearch", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "roleAdvancedSearch", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "displayPeriodFilter", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "hasadvanceddays"
		//Campo 13º salário na solicitação de férias.
		lSolicFe13 := GetMvMrh("MV_MRHFE13",.F.,.T.,cBranchVld)
		fSetFieldP( "hasAdvancedDays", lSolicFe13, lSolicFe13, lSolicFe13, @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "delayandabsence"
		//Hora inicial da falta/atraso
		fSetFieldP( "startHour", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//Hora final da falta/atraso
		fSetFieldP( "endHour", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "demission"
		//Tipo do desligamento
		fSetFieldP( "demissionType", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		//Justificativa do desligamento
		fSetFieldP( "demissionJustify", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		//Gera nova contratação
		fSetFieldP( "newHire", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		//Data do desligamento
		fSetFieldP( "demissionDate", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//Iniciativa do desligamento
		fSetFieldP( "demissionIniciative", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//Tipo de Aviso Prévio
		fSetFieldP( "demissionNoticeType", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//Motivo do desligamento
		fSetFieldP( "demissionReason", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//Considera ex-funcionários (demitidos na competência atual ou posterior)
		fSetFieldP( "employeeDemit", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//Número de dias do aviso prévio
		fSetFieldP( "noticeDays", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//Nome do solicitante da requisiçao.
		fSetFieldP( "requesterName", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//Arquivo anexo.
		fSetFieldP( "attachment", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "medicalcertificate"
		lIntNg := SUPERGETMV('MV_RHNG', .F., .F.)
		fSetFieldP( "type", !lIntNg, !lIntNg, !lIntNg, @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "reason", !lIntNg, !lIntNg, !lIntNg, @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "doctorName", !lIntNg, !lIntNg, .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "medicalRegionalCouncil", !lIntNg, !lIntNg, .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "cid", !lIntNg, !lIntNg, !lIntNg, @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "clockingupdate"
		fSetFieldP( "hour", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "justify", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "reason", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "direction", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "clocking"
		fSetFieldP( "balanceSummary", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "responsable", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "moreOptionsPointsAttencion", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "payment"
		fSetFieldP( "download", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "clockingregister"
		fSetFieldP( "hour", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "justify", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "reason", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "direction", .T., .T., .T., @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "substituterequest"
		fSetFieldP( "canViewSalary", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "canManageTeam", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "divisions", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If nLenParms > 1 .And. Lower(::aURLParms[2]) == "clockinggeoupdate"
		fSetFieldP( "justify", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "reason", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "filterButton", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If !Empty(::aURLParms[1]) .And. ::aURLParms[2] == "vacation"

		fSetFieldP( "monthInAdvance", .T., .F., .F., @oProps ) //Risco de Vencimento para férias vencidas.
		Aadd(aData,oProps)

		fSetFieldP( "dashboard", .T., .F., .F., @oProps ) //Contador da gestao de ferias
		Aadd(aData,oProps)

		fSetFieldP( "justify", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "indirectSubordinatesLevel", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "hierarchicalLevel", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "searchNameInDatabase", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "condition", .T., .T., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If !Empty(::aURLParms[1]) .And. ::aURLParms[2] == "profile"
		fSetFieldP( "positionLevel", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "registry", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "department", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "admissionDate", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		//******* Summary
		fSetFieldP( "summary. ", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//******* teams
		fSetFieldP( "teams. ", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//******* coordinator
		fSetFieldP( "coordinator. ", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//******* personalData
		fSetFieldP( "personalData. ", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//******* addresses
		fSetFieldP( "addresses. ", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//******* contacts
		fSetFieldP( "contacts. ", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//******* webReferences
		fSetFieldP( "webReferences. ", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		//******* documents
		fSetFieldP( "documents. ", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

	EndIf

	If !Empty(::aURLParms[1]) .And. ::aURLParms[2] == "requisitionsDataChange"
		fSetFieldP( "costCenter", .T., .F., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "newRole", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "currentHierarchicalStructure", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "newHierarchicalStructure", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "expectedDate", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "salaryLevel", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "salaryRange", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "salaryTable", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "levelSalaryTable", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "rangeSalaryTable", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "descriptionSalaryTable", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "editSalary", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "editPercent", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "categoryChangeType", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "reasonSalaryChange", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "jobFunctionChangeReason", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "displayAlert", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "jobRoles", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "hierarchy", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "attachment", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "dataChangeJustify", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "generateNewHire", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "complementaryField", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "requesterName", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "classValue", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "accountingItem", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

	EndIf

	If !Empty(::aURLParms[1]) .And. ::aURLParms[2] == "staffIncrease"
		fSetFieldP( "hierarchicalStructure", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "prevision", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "postType", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "contractType", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "costCenter", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "role", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "attachedFile", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "newHire", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "requesterName", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "classValue", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "accountingItem", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If !Empty(::aURLParms[1]) .And. ::aURLParms[2] == "transfer"
		fSetFieldP( "hierarchicalStructure", .F., .F., .F., @oProps ) //Descrição da hierarquia de destino
		Aadd(aData,oProps)

		fSetFieldP( "expectedDate", .F., .F., .F., @oProps ) //Data prevista da requisição
		Aadd(aData,oProps)

		fSetFieldP( "attachment", .F., .F., .F., @oProps ) //Se existe anexo
		Aadd(aData,oProps)

		fSetFieldP( "newFunction", .F., .F., .F., @oProps ) //Nova função
		Aadd(aData,oProps)

		fSetFieldP( "hierarchy", .F., .F., .F., @oProps ) // Hierarquia
		Aadd(aData,oProps)

		fSetFieldP( "file", .F., .F., .F., @oProps ) //Anexo
		Aadd(aData,oProps)

		fSetFieldP( "role", .F., .F., .F., @oProps ) //Descrição do cargo atual do funcionário
		Aadd(aData,oProps)

		fSetFieldP( "generateNewHire", .F., .F., .F., @oProps ) //Se a requisição gerou uma nova contratação
		Aadd(aData,oProps)

		fSetFieldP( "transferVacancy", .F., .F., .F., @oProps ) //Se houve transferência de vaga na requisição
		Aadd(aData,oProps)

		fSetFieldP( "changeFunctionReason", .F., .F., .F., @oProps ) //Descrição do motivo de mudança de função
		Aadd(aData,oProps)

		fSetFieldP( "changeFunction", .F., .F., .F., @oProps ) //Se foi alterada a função
		Aadd(aData,oProps)

		fSetFieldP( "sectionChangeReason", .F., .F., .F., @oProps ) //Motivo de mudança de função.
		Aadd(aData,oProps)

		fSetFieldP( "departmentChangeTypes", .F., .F., .F., @oProps ) //Motivo de mudança de departamento (seção)
		Aadd(aData,oProps)

		fSetFieldP( "costCenter", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "process", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "company", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "branch", .T., .T., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "jobFunction", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "transfJustify", .T., .T., .T., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "requesterName", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

	EndIf

	If !Empty(::aURLParms[1]) .And. ::aURLParms[2] == "dependents"
		fSetFieldP( "generalDataCard", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "recordCard", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "registerDataCard", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "dateComprFreq", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "freqFamily", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "incidence", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "invalidityType", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "sitSalFamily", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "stability", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "stabilityReason", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "stateOfHealth", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "birthCertificate", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "book", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "certificateDelivery", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "cgcRegistry", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "page", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "record", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "registry", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "birthCity", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "birthCountry", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "birthDate", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "cpf", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "degreeOfDependence", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "gender", .T., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "mothersName", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
		fSetFieldP( "uf", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	If !Empty(::aURLParms[1]) .And. ::aURLParms[2] == "beneficiaries"
		fSetFieldP( "registerDataCard", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "benefitsCard", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "paymentMethodCard", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "normalRegisterCard", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "christmasBonusSalaryCard", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "vacationRegisterCard", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "prlRegisterCard", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "cpf", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "process", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "uf", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "country", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "pensionSituation", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "occupation", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "situationData", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "pension", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "healthPlan", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "lifeInsurance", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "paymentMethod", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "bank", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "agency", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "currentAccount", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "calculationTypeBaseNormal", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "calculationTypePensionNormal", .T., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "calculationTypeBaseBonus", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "calculationTypePensionBonus", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "calculationTypeBaseVacation", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "calculationTypePensionVacation", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "calculationTypeBasePrl", .F., .F., .F., @oProps )
		Aadd(aData,oProps)

		fSetFieldP( "calculationTypePensionPrl", .F., .F., .F., @oProps )
		Aadd(aData,oProps)
	EndIf

	oItem := JsonObject():New()
	oItem["hasNext"]  := .F.
	oItem["items"]    := aData

	cJson := oItem:ToJson()
	::SetResponse(cJson)

Return(.T.)

// --------------------------------------------------------------------
// - GET RESPONSÁVEL PARA CARREGAR ALGUMAS CONFIGURAÇÕES DE AMBIENTE.
// --------------------------------------------------------------------
	WSMETHOD GET CompanySettings WSREST Setting

	Local oJson  := JsonObject():New()
	Local aOauth := {}
	Local aOIDC  := {}
	Local cJson  := ""

	oJson["forgotPasswordEnabled"] := .T.
	oJson["providersOauth"]        := aOauth
	oJson["requiredSSO"]           := .F.
	oJson["samlProviders"]         := NIL
	oJson["loginProtheus"]         := .T.
	oJson["oidcProviders"]         := aOIDC

	cJson := oJson:ToJson()
	::SetResponse(cJson)
	FreeObj(oJson)

Return .T.


	WSMETHOD GET employeeKey WSREST Setting

	Local cKeyId := ""
	Local cErr   := ""
	Local cToken := ""
	Local cAuth  := Self:GetHeader('Authorization')
	Local oID    := JsonObject():New()

	If !Empty(cAuth)
		cToken := Substr(cAuth,8,Len(cAuth))
		If MrhLogin(NIL, ;                              // cRestURL
			NIL, ;                                 // cUser
			NIL, ;                                 // cPassword
			cToken,;                               // Token
			@cKeyId,;                              // cKeyId
			NIL,;                                  // cFilUser
			NIL,;                                  // cMatUser
			@cErr)                                 // cErro
			oID["id"] := Encode64(cKeyId)
		Else
			SetRestFault(400, EncodeUTF8(cErr), .T.)
		EndIf
	EndIf
	::SetResponse(oID:toJson())

Return .T.
