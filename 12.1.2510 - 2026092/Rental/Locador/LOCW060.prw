#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW060.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Consulta saldo (SB2)
@TYPE function
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSRESTFUL LOCW060 DESCRIPTION "Consulta simplificada de saldo de estoque por armazem - Rental"

	WSMETHOD GET DESCRIPTION "<h2>Retorna o saldo de estoque por armazem para o aplicativo de expedicao. - Rental</h2>" WSSYNTAX "/LOCW060/{param1}/{param2}/"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW060
ITUP BUSINESS - TOTVS RENTAL
Método para Consulta saldo (SB2)
@TYPE WSMETHOD
@AUTHOR DENNIS CALABREZ
@SINCE 10/02/2026
/*/
WSMETHOD GET WSSERVICE LOCW060
Local cRet        := ""
Local cDados      := ""
Local aPar        := {}
Local aEmp        := {}
Local aBindParam  := {}
Local cParam1     := ""
Local cParam2     := ""
Local cArmazem    := ""
Local cLimite     := ""
Local cAut        := ""
Local nLimite     := 0
Local nLmt        := 0
Local nCont       := 0
Local cQuery      := ""
Local cFonte      := "LOCW060.PRW"
Local aInfo       := GetAPOInfo(cFonte)
Local cMsg        := ""

	::SetContentType("application/json; charset=iso-8859-1")

	// Busca os parametros informados na URL/API
	aPar := LOCW060A(AllTrim(Upper(::GetPath(1))))

	cParam1 := IIf(Len(aPar) >= 1, aPar[1], "")
	cParam2 := IIf(Len(aPar) >= 2, aPar[2], "")

	cArmazem := AllTrim(SubStr(cParam1, At("=", cParam1) + 1)) // Armazem (B2_LOCAL)
	cLimite  := AllTrim(SubStr(cParam2, At("=", cParam2) + 1)) // Limite de registros

	nLimite := Val(cLimite)

	Begin Sequence

		// Abre o ambiente na empresa correta a partir do CNPJ informado
		aEmp := xVerEmp1(Replace(Replace(Replace(cAut, ".", ""), "/", ""), "-", ""))

		If (aEmp[3] == "Empresa já existente.")

			cRet := xAbreEnv1(aEmp[1], aEmp[2])

			If Empty(cRet)

				// Padding Protheus: campo com o tamanho exato definido no dicionario
				cArmazem := PadR(cArmazem, TamSX3("B2_LOCAL")[1])

				cQuery := "SELECT "
				cQuery += " B2_LOCAL, B2_COD, B1_DESC, B1_UM, B1_RASTRO, B1_LOCALIZ, B2_CM1, B2_QATU "
				cQuery += "FROM " + RetSqlName("SB2") + " SB2 "
				cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 "
				cQuery += "  ON B1_FILIAL  = '" + xFilial("SB1") + "' "
				cQuery += " AND B1_COD     = B2_COD "
				cQuery += " AND B1_MSBLQL <> '1' "                 // produto nao bloqueado (ativo)
				cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
				cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
				cQuery += "  AND B2_LOCAL  = ? "                    // armazem informado
				cQuery += "  AND B2_QATU  > 0 "                    // somente com saldo disponivel
				cQuery += "  AND SB2.D_E_L_E_T_ = ' ' "
				cQuery += "ORDER BY B2_COD "

				aAdd(aBindParam, cArmazem)

				cQuery := ChangeQuery(cQuery)
				MPSysOpenQuery(cQuery, "TRBB2", , , aBindParam)
				cDados += ', "Dados" : ['
				While TRBB2->(!EoF())

					If nLmt == nLimite
						Exit
					EndIf				

					If nCont > 0
						cDados += ","
					EndIf

					cDados += ' { ' 
					cDados += '"B2_LOCAL": "'   + AllTrim(TRBB2->B2_LOCAL)             + '",'
					cDados += '"B2_COD": "'     + AllTrim(TRBB2->B2_COD)               + '",'
					cDados += '"B1_DESC": "'    + LOCW060C(AllTrim(TRBB2->B1_DESC))    + '",'
					cDados += '"B1_UM": "'      + AllTrim(TRBB2->B1_UM)                + '",'
					cDados += '"B1_RASTRO": "'  + AllTrim(TRBB2->B1_RASTRO)            + '",'
					cDados += '"B1_LOCALIZ": "' + AllTrim(TRBB2->B1_LOCALIZ)           + '",'
					cDados += '"B2_CM1": '      + LOCW060B(TRBB2->B2_CM1)              + ','
					cDados += '"B2_QATU": '     + LOCW060B(TRBB2->B2_QATU)             
					cDados += ' } '

					nCont++
					nLmt++

					TRBB2->(DbSkip())
				EndDo
					cDados += ']'
				// Sempre fecha o alias aberto pelo MPSysOpenQuery
				LOCACLOSE("TRBB2")

			EndIf
		EndIf

	End Sequence

	// Em caso de falha (ambiente/empresa ou excecao), retorna erro HTTP
	If Empty(cRet)
        cRet := "200 - "
        cMsg := "Dados com sucesso! "
	EndIf

	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'" '+cDados+',"compilado":"'+aInfo[1]+' '+DtoS(aInfo[4])+'"}')) )

Return .T.


/*/{PROTHEUS.DOC}
ITUP BUSINESS - TOTVS RENTAL
Alimenta os parametros da URL em um Array
@TYPE STATIC FUNCTION
@AUTHOR IT UP Business
@SINCE 01/07/2026
/*/
Static Function LOCW060A(cUrl)
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


/*/{PROTHEUS.DOC}
Escapa caracteres especiais para montagem segura do JSON
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 01/07/2026
/*/
Static Function LOCW060C(cStr)
Local cRet := cStr

	cRet := StrTran(cRet, "\", "\\")
	cRet := StrTran(cRet, '"', '\"')
	cRet := StrTran(cRet, Chr(13), " ")
	cRet := StrTran(cRet, Chr(10), " ")
	cRet := StrTran(cRet, Chr(9), " ")

Return cRet


/*/{PROTHEUS.DOC}
Formata valor numerico para JSON (separador decimal ".", sem zeros a direita)
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 01/07/2026
/*/
Static Function LOCW060B(nVal)
Local cRet := AllTrim(Str(nVal, 18, 4))

	If At(".", cRet) > 0
		While Len(cRet) > 0 .And. Right(cRet, 1) == "0"
			cRet := Left(cRet, Len(cRet) - 1)
		EndDo
		If Right(cRet, 1) == "."
			cRet := Left(cRet, Len(cRet) - 1)
		EndIf
	EndIf

Return cRet
