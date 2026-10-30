#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW061.PRW
ITUP BUSINESS - TOTVS RENTAL
API - retornar algum parametro informado SX6
@TYPE function
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSRESTFUL LOCW061 DESCRIPTION " API para retornar algum parametro informado SX6 - Rental"

	WSMETHOD GET DESCRIPTION "<h2> API para retornar algum parametro informado SX6. - Rental</h2>" WSSYNTAX "/LOCW061/{param1}/{param2}/"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW061
ITUP BUSINESS - TOTVS RENTAL
Método para retornar algum parametro informado SX6
@TYPE WSMETHOD
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSMETHOD GET WSSERVICE LOCW061
Local cRet        := ""
Local aPar        := {}
Local aEmp        := {}
Local cParam1     := ""
Local cParam      := ""
Local cAut        := ""
Local cConteudo   := ""
Local cFonte      := "LOCW061.PRW"
Local aInfo       := GetAPOInfo(cFonte)
Local cMsg        := ""

	::SetContentType("application/json; charset=iso-8859-1")

	// Busca os parametros informados na URL/API
	aPar := LOCW061A(AllTrim(Upper(::GetPath(1))))

	cParam1 := IIf(Len(aPar) >= 1, aPar[1], "")

	cParam := AllTrim(SubStr(cParam1, At("=", cParam1) + 1)) // Parâmetro informado (SX6)

	Begin Sequence

		// Abre o ambiente na empresa correta a partir do CNPJ informado
		aEmp := xVerEmp1(Replace(Replace(Replace(cAut, ".", ""), "/", ""), "-", ""))

		If (aEmp[3] == "Empresa já existente.")

			cRet := xAbreEnv1(aEmp[1], aEmp[2])

			If Empty(cRet)

				//Se o parâmetro existir na base, pega o conteúdo dele
				If FWSX6Util():ExistsParam(cParam)
					cConteudo := GetMV(cParam)
			
				//Senão, atribui como não encontrado
				Else
					cRet := "400 - "
					cMsg := "Parametro nao encontrado ou inexistente"
				EndIf
			EndIf
		EndIf

	End Sequence

	If ValType(cConteudo) == "D"  
		cConteudo := DTOS(cConteudo)
	EndIf

	If ValType(cConteudo) == "N"  
		cConteudo := cValtoChar(cConteudo)
	EndIf

	If ValType(cConteudo) == "L"  
		cConteudo := iif(cConteudo, "TRUE","FALSE") 
	EndIf					

	If Empty(cRet)
        cRet := "200 - "
        cMsg := "O conteudo do parametro" + "  " + cParam + " e:  " + cConteudo
	EndIf

	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'" '+""+',"compilado":"'+aInfo[1]+' '+DtoS(aInfo[4])+'"}')) )
Return .T.


/*/{PROTHEUS.DOC}
ITUP BUSINESS - TOTVS RENTAL
Alimenta os parametros da URL em um Array
@TYPE STATIC FUNCTION
@AUTHOR IT UP Business
@SINCE 01/07/2026
/*/
Static Function LOCW061A(cUrl)
Local cQry    := ""
Local aParams := {}

	// Captura apenas a parte dos parametros apos o '?'
	If At("?", cUrl) > 0
		cQry := AllTrim(SubStr(cUrl, At("?", cUrl) + 1))
	EndIf

	// Quebra os parametros pelo '&'
	If !Empty(cQry)
		aParams := StrTokArr(cQry, "&")
	EndIf

Return aParams
