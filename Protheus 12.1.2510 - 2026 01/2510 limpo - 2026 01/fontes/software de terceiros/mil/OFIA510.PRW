#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'OFIA510.CH'

/*/{Protheus.doc} OFIA510 
	Login OAUTH 2.0 OKTA JD

	@author Vinicius Gati
	@since  16/10/2015
/*/
Function OFIA510(oOkta)
	Local oButton, oDlg
	Local lNovoLogin := .t.
	Private oProcess

	if ValType(oOkta) == "U"
		UserException("Uso inválido da função OFIA510()")
	endif

	if empty(oOkta:_service)
		UserException("Objeto okta deve ter serviço selecionado antes de chamar OFIA510()")
	endif

	if oOkta:AnyValidToken()
		if oOkta:UseLastToken()
			lNovoLogin := .F.
		else
			lNovoLogin := .T.
		endif
	endif

	if lNovoLogin
		DEFINE MSDIALOG oDlg FROM 0,0 TO 650,1000 PIXEL TITLE STR0001 //'Autenticação John Deere'
		oTIBrowser := TWebEngine():New(oDlg, 0, 0, 500, 300, oOkta:GetAuthUrl())
		oButton := TButton():New(310, 0070, 'OK', oDlg, { || oDlg:End() }, 40, 10,,,,.T.)
		ACTIVATE MSDIALOG oDlg CENTERED

		oProcess := MsNewProcess():New({|lEnd| OA5100014_BUSCAAUTH(@oOkta) },STR0002,STR0003,.T.) //"Aguarde a conclusão da autenticação" //"Buscando tokens"
		oProcess:Activate()

		oOkta:getToken()
	endif
Return oOkta

/*/{Protheus.doc} OA5100014_BUSCAAUTH
	
	@type  Function
	@author VINICIUS GATI
	@since 27/01/2025
/*/
Function OA5100014_BUSCAAUTH(oOkta)
	local nTime := 0
	local oAuth2 := OFOAUTH2():New()
	
	While nTime < 10000
        sleep(500)
		nTime += 500
        oProcess:SetRegua1(nTime)

		cToken := oAuth2:GetToken(oOkta:GetLastStatus(), oOkta:_client_ID)
		if ! Empty(cToken)
			oOkta:SetToken(cToken)
			exit
		endif
    End
Return .t.
