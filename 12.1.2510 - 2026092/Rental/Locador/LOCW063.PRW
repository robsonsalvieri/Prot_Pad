#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#Include 'FWMVCDef.ch'

/*/{PROTHEUS.DOC} LOCW063.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Consulta de titulos financeiros de um cliente (projeto/obra/periodo)
e geracao do boleto em PDF base64 para cada titulo encontrado
@TYPE function
@AUTHOR Dennis Calabrez
@SINCE 08/06/2026
/*/
WSRESTFUL LOCW063 DESCRIPTION "Consulta de titulos financeiros para geracao de boleto - RENTAL"

	WSMETHOD GET DESCRIPTION "<h2>Consulta titulos financeiros de um cliente e retorna os dados/boleto em PDF base64 - Rental</h2>" WSSYNTAX "/LOCW063/{param1}/{param2}/{param3}/{param4}/{param5}/{param6}/{param7}"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW063
ITUP BUSINESS - TOTVS RENTAL
Metodo para consulta dos titulos financeiros vinculados a um cliente,
filtrando por projeto, obra e periodo de emissao, retornando os dados
necessarios para a geracao do boleto (linha digitavel, codigo de barras,
dados do beneficiario/pagador) e o PDF do boleto em base64.
@TYPE WSMETHOD
@AUTHOR Dennis Calabrez
@SINCE 08/06/2026
/*/
WSMETHOD GET WSSERVICE LOCW063
Local cEnvLog    := ""
Local bError     := {||}
Local cDados     := ""
Local cRet       := ""
Local cMsg       := ""
Local aPar       := {}
Local aEmp       := {}
Local aTitulos   := {}
Local cParam1    := ""
Local cParam2    := ""
Local cParam3    := ""
Local cParam4    := ""
Local cParam5    := ""
Local cParam6    := ""
Local cParam7    := ""
Local cDtIni     := ""
Local cDtFim     := ""
Local cProjeto   := ""
Local cObra      := ""
Local cAut       := ""
Local cCliente   := ""
Local cLoja      := ""
Local lLog       := .F.
Local nX         := 0
Local cFonte     := "LOCW063.PRW"
Local aInfo      := GetAPOInfo(cFonte)

	aPar :=  LOCW063A(AllTrim(Upper(::GetPath(1)))) //Busco os parametros informados na URL/API

	cParam1 := aPar[1]
	cParam2 := aPar[2]
	cParam3 := aPar[3]
	cParam4 := aPar[4]
	cParam5 := aPar[5]
	cParam6 := aPar[6]
	cParam7 := aPar[7]

	cDtIni   := AllTrim(SubStr(cParam1, At("=", cParam1) + 1)) //Data de emissao de (YYYY-MM-DD)
	cDtFim   := AllTrim(SubStr(cParam2, At("=", cParam2) + 1)) //Data de emissao ate (YYYY-MM-DD)
	cProjeto := AllTrim(SubStr(cParam3, At("=", cParam3) + 1)) //Projeto (se informado)
	cObra    := AllTrim(SubStr(cParam4, At("=", cParam4) + 1)) //Obra (se informada)
	cAut     := AllTrim(SubStr(cParam5, At("=", cParam5) + 1)) //CNPJ da empresa para logar no Protheus na empresa correta
	cCliente := AllTrim(SubStr(cParam6, At("=", cParam6) + 1)) //Cliente (obrigatorio)
	cLoja    := AllTrim(SubStr(cParam7, At("=", cParam7) + 1)) //Loja (se informada)

	::SetContentType("application/json; charset=iso-8859-1")

	Begin Sequence

		aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
		lLog := if(len(aEmp)==4, aEmp[4], aEmp[3]=="Empresa ja existente.")

		If lLog

			cRet := xAbreEnv1(aEmp[1],aEmp[2])

			If Empty(cCliente)
				cRet := "400 - "
				cMsg := "Cliente deve ser obrigatoriamente informado"
			EndIf

			If Empty(cRet)

				aTitulos := LOCW063B(cCliente, cLoja, cProjeto, cObra, cDtIni, cDtFim)

				cDados += ', "Titulos": ['

				If Len(aTitulos) > 0
					For nX := 1 To Len(aTitulos)
						cDados += LOCW063C(aTitulos[nX])
						If nX < Len(aTitulos)
							cDados += ","
						EndIf
					Next
				Else
					cRet := "204 - "
					cMsg := "A requisicao foi bem-sucedida, mas nao ha titulos para retornar, verifique os parametros"
				EndIf

				cDados += "]"

			EndIf
		EndIf

	End Sequence

	If Empty(cRet)
		cRet := "200 - "
		cMsg := "Recurso encontrado"
	EndIf

	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'" '+cDados+',"compilado":"'+aInfo[1]+' '+DtoS(aInfo[4])+'"}')) )

Return .T.

/*/{PROTHEUS.DOC} LOCW063A
ITUP BUSINESS - TOTVS RENTAL
Alimenta os parametros da URL em um Array
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 08/06/2026
/*/
Static Function LOCW063A(cUrl)
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

/*/{PROTHEUS.DOC} LOCW063B
ITUP BUSINESS - TOTVS RENTAL
Consulta os titulos financeiros (SE1) vinculados ao cliente informado,
filtrando por projeto/obra/periodo de emissao. O vinculo entre o titulo
e o projeto/obra e feito via pedido de venda (SD2/FPZ) para titulos
definitivos, ou via FQB para titulos provisorios (mesmo modelo usado
no relatorio sigaloc.sv.loc.titulosrental).
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 08/06/2026
/*/
Static Function LOCW063B(cCliente, cLoja, cProjeto, cObra, cDtIni, cDtFim)
Local cQuery     := ""
Local aBindParam := {}
Local aRet       := {}
Local aVisto     := {}
Local lAchou     := .F.
Local nX         := 0
Local cCliPad    := PadR(Alltrim(cCliente), TamSx3("E1_CLIENTE")[1])
Local cLojaDe    := If(Empty(cLoja), Space(TamSx3("E1_LOJA")[1])          , PadR(Alltrim(cLoja)   , TamSx3("E1_LOJA")[1]))
Local cLojaAte   := If(Empty(cLoja), Replicate("Z",TamSx3("E1_LOJA")[1]) , PadR(Alltrim(cLoja)   , TamSx3("E1_LOJA")[1]))
Local cProjDe    := If(Empty(cProjeto), Space(TamSx3("FPZ_PROJET")[1])          , PadR(Alltrim(cProjeto), TamSx3("FPZ_PROJET")[1]))
Local cProjAte   := If(Empty(cProjeto), Replicate("Z",TamSx3("FPZ_PROJET")[1]) , PadR(Alltrim(cProjeto), TamSx3("FPZ_PROJET")[1]))
Local cObraDe    := If(Empty(cObra), Space(TamSx3("FPZ_OBRA")[1])          , PadR(Alltrim(cObra), TamSx3("FPZ_OBRA")[1]))
Local cObraAte   := If(Empty(cObra), Replicate("Z",TamSx3("FPZ_OBRA")[1]) , PadR(Alltrim(cObra), TamSx3("FPZ_OBRA")[1]))
Local cEmisDe    := If(Empty(cDtIni), "19000101", StrTran(cDtIni,"-",""))
Local cEmisAte   := If(Empty(cDtFim), "20991231", StrTran(cDtFim,"-",""))

	LOCACLOSE("TRBW63")

	// Titulos definitivos: SE1 -> SD2 (nota de saida) -> FPZ (projeto/obra)
	cQuery := " SELECT SE1.R_E_C_N_O_ AS RECSE1, SE1.E1_NUM, SE1.E1_PREFIXO, SE1.E1_PARCELA, SE1.E1_NATUREZ, "
	cQuery += " SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI, SE1.E1_EMISSAO, SE1.E1_VENCTO, SE1.E1_VALOR, SE1.E1_SALDO, "
	cQuery += " FPZ.FPZ_PROJET AS PROJETO, FPZ.FPZ_OBRA AS OBRA "
	cQuery += " FROM "+RetSqlName("SE1")+" SE1 "
	cQuery += " INNER JOIN ( "
	cQuery += "   SELECT SD2.D2_DOC, SD2.D2_SERIE, MIN(FPZ.FPZ_PROJET) AS FPZ_PROJET, MIN(FPZ.FPZ_OBRA) AS FPZ_OBRA "
	cQuery += "   FROM "+RetSqlName("SD2")+" SD2 "
	cQuery += "   INNER JOIN "+RetSqlName("FPZ")+" FPZ ON FPZ.FPZ_FILIAL = '"+xFilial("FPZ")+"' "
	cQuery += "     AND FPZ.FPZ_PEDVEN = SD2.D2_PEDIDO AND FPZ.FPZ_PROJET <> ' ' "
	cQuery += "     AND FPZ.FPZ_PROJET >= ? AND FPZ.FPZ_PROJET <= ? "
	AAdd(aBindParam, cProjDe)
	AAdd(aBindParam, cProjAte)
	cQuery += "     AND FPZ.FPZ_OBRA >= ? AND FPZ.FPZ_OBRA <= ? "
	AAdd(aBindParam, cObraDe)
	AAdd(aBindParam, cObraAte)
	cQuery += "     AND FPZ.D_E_L_E_T_ = ' ' "
	cQuery += "   WHERE SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = '"+xFilial("SD2")+"' "
	cQuery += "   GROUP BY SD2.D2_DOC, SD2.D2_SERIE "
	cQuery += " ) FPZ ON FPZ.D2_DOC = SE1.E1_NUM AND FPZ.D2_SERIE = SE1.E1_PREFIXO "
	cQuery += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
	cQuery += " AND SE1.E1_CLIENTE = ? AND SE1.E1_LOJA >= ? AND SE1.E1_LOJA <= ? "
	AAdd(aBindParam, cCliPad)
	AAdd(aBindParam, cLojaDe)
	AAdd(aBindParam, cLojaAte)
	cQuery += " AND SE1.E1_EMISSAO >= ? AND SE1.E1_EMISSAO <= ? "
	AAdd(aBindParam, cEmisDe)
	AAdd(aBindParam, cEmisAte)
	cQuery += " AND SE1.D_E_L_E_T_ = ' ' "

	cQuery += " UNION ALL "

	// Titulos provisorios: SE1 -> FQB (projeto/obra)
	cQuery += " SELECT SE1.R_E_C_N_O_ AS RECSE1, SE1.E1_NUM, SE1.E1_PREFIXO, SE1.E1_PARCELA, SE1.E1_NATUREZ, "
	cQuery += " SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI, SE1.E1_EMISSAO, SE1.E1_VENCTO, SE1.E1_VALOR, SE1.E1_SALDO, "
	cQuery += " FQB.FQB_PROJET AS PROJETO, FQB.FQB_OBRA AS OBRA "
	cQuery += " FROM "+RetSqlName("SE1")+" SE1 "
	cQuery += " INNER JOIN ( "
	cQuery += "   SELECT FQB.FQB_PR, FQB.FQB_PREF, FQB.FQB_PARC, MIN(FQB.FQB_PROJET) AS FQB_PROJET, MIN(FQB.FQB_OBRA) AS FQB_OBRA "
	cQuery += "   FROM "+RetSqlName("FQB")+" FQB "
	cQuery += "   WHERE FQB.FQB_FILIAL = '"+xFilial("FQB")+"' "
	cQuery += "     AND FQB.FQB_PROJET >= ? AND FQB.FQB_PROJET <= ? "
	AAdd(aBindParam, cProjDe)
	AAdd(aBindParam, cProjAte)
	cQuery += "     AND FQB.FQB_OBRA >= ? AND FQB.FQB_OBRA <= ? "
	AAdd(aBindParam, cObraDe)
	AAdd(aBindParam, cObraAte)
	cQuery += "     AND FQB.D_E_L_E_T_ = ' ' "
	cQuery += "   GROUP BY FQB.FQB_PR, FQB.FQB_PREF, FQB.FQB_PARC "
	cQuery += " ) FQB ON FQB.FQB_PR = SE1.E1_NUM AND FQB.FQB_PREF = SE1.E1_PREFIXO AND FQB.FQB_PARC = SE1.E1_PARCELA "
	cQuery += " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
	cQuery += " AND SE1.E1_CLIENTE = ? AND SE1.E1_LOJA >= ? AND SE1.E1_LOJA <= ? "
	AAdd(aBindParam, cCliPad)
	AAdd(aBindParam, cLojaDe)
	AAdd(aBindParam, cLojaAte)
	cQuery += " AND SE1.E1_EMISSAO >= ? AND SE1.E1_EMISSAO <= ? "
	AAdd(aBindParam, cEmisDe)
	AAdd(aBindParam, cEmisAte)
	cQuery += " AND SE1.D_E_L_E_T_ = ' ' "

	cQuery := CHANGEQUERY(cQuery)
	MPSysOpenQuery(cQuery,"TRBW63",,,aBindParam)

	While TRBW63->(!Eof())

		lAchou := .F.
		For nX := 1 To Len(aVisto)
			If aVisto[nX] == TRBW63->RECSE1
				lAchou := .T.
				Exit
			EndIf
		Next

		If !lAchou
			AAdd(aVisto, TRBW63->RECSE1)
			AAdd(aRet, { TRBW63->RECSE1, TRBW63->E1_NUM, TRBW63->E1_PREFIXO, TRBW63->E1_PARCELA,;
			             TRBW63->E1_NATUREZ, TRBW63->E1_CLIENTE, TRBW63->E1_LOJA, TRBW63->E1_NOMCLI,;
			             STOD(TRBW63->E1_EMISSAO), STOD(TRBW63->E1_VENCTO), TRBW63->E1_VALOR, TRBW63->E1_SALDO,;
			             TRBW63->PROJETO, TRBW63->OBRA } )
		EndIf

		TRBW63->(dbSkip())
	EndDo

	TRBW63->(dbCloseArea())

Return aRet

/*/{PROTHEUS.DOC} LOCW063C
ITUP BUSINESS - TOTVS RENTAL
Monta o JSON de um titulo (dados do titulo + dados do boleto + PDF base64)
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 08/06/2026
/*/
Static Function LOCW063C(aRow)
Local cItem       := ""
Local aBoleto     := {}
Local cPayloadBol := ""
Local cErroBol    := ""
Local cErroRender := ""

	SE1->(dbGoto(aRow[1]))

	aBoleto     := LOCW063D()
	cPayloadBol := aBoleto[1]
	cErroBol    := aBoleto[2]


	cItem += '{'
	cItem += '"numero_titulo": "'+Alltrim(aRow[2])+'",'
	cItem += '"prefixo": "'+Alltrim(aRow[3])+'",'
	cItem += '"parcela": "'+Alltrim(aRow[4])+'",'
	cItem += '"natureza": "'+Alltrim(aRow[5])+'",'
	cItem += '"cliente": "'+Alltrim(aRow[6])+'",'
	cItem += '"loja": "'+Alltrim(aRow[7])+'",'
	cItem += '"nome_cliente": "'+LOCW063F(aRow[8])+'",'
	cItem += '"projeto": "'+Alltrim(aRow[13])+'",'
	cItem += '"obra": "'+Alltrim(aRow[14])+'",'
	cItem += '"data_emissao": "'+LOCW063G(aRow[9])+'",'
	cItem += '"data_vencimento": "'+LOCW063G(aRow[10])+'",'
	cItem += '"valor": '+StrTran(Alltrim(Str(aRow[11],17,2)),",",".")+','
	cItem += '"saldo": '+StrTran(Alltrim(Str(aRow[12],17,2)),",",".")+','

	If !Empty(cErroBol)
		cItem += '"boleto": null,'
		//cItem += '"pdf_base64": "",'
		//cItem += '"pdf_url": null,'
		cItem += '"erro": "'+LOCW063F(cErroBol)+'"'
	//ElseIf !Empty(cErroRender)
		//cItem += '"boleto": '+cPayloadBol+','
		//cItem += '"pdf_base64": "",'
		//cItem += '"pdf_url": null,'
		//cItem += '"erro": "'+LOCW063F(cErroRender)+'"'
	Else
		cItem += '"boleto": '+cPayloadBol+','
		//cItem += '"pdf_base64": "'+cPdfBase64+'",'
		//cItem += If(Empty(cPdfUrl), '"pdf_url": null,', '"pdf_url": "'+cPdfUrl+'",')
		cItem += '"erro": ""'
	EndIf

	cItem += '}'

Return cItem

/*/{PROTHEUS.DOC} LOCW063D
ITUP BUSINESS - TOTVS RENTAL
Monta o objeto "boleto" (banco/titulo/beneficiario/pagador) a partir do
titulo (SE1) atualmente posicionado, seguindo o mesmo modelo de
LOCA0737 (loca073.prw), usado como base para essa geracao.
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 08/06/2026
/*/
Static Function LOCW063D()
Local lImprime    := .T.
Local cErro       := ""
Local cPayload    := ""
Local cPortado    := ""
Local cBanco      := ""
Local cAgencia    := ""
Local cConta      := ""
Local cLinha      := ""
Local cBarra      := ""
Local cNosso      := ""
Local cCarteira   := ""
Local cEspecie    := ""
Local cEmissao    := ""
Local cVencimento := ""
Local cValor      := ""
Local cMoeda      := ""
Local cBenNome    := ""
Local cBenCNPJ    := ""
Local cBenRua     := ""
Local cBenNum     := ""
Local cBenBairro  := ""
Local cBenCidade  := ""
Local cBenUF      := ""
Local cBenCep     := ""
Local cNome       := ""
Local cDocumento  := ""
Local cRua        := ""
Local cNumero     := ""
Local cBairro     := ""
Local cCidade     := ""
Local cUF         := ""
Local cCEP        := ""

	SA6->(dbSetOrder(1))
	If !SA6->(dbSeek(xFilial("SA6")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)))
		lImprime := .F.
		cErro += "Banco/agencia/conta nao localizado: "+alltrim(SE1->E1_PORTADO)+" - "+alltrim(SE1->E1_AGEDEP)+" - "+alltrim(SE1->E1_CONTA)+". "
	EndIf

	SEE->(dbSetOrder(1))
	If !SEE->(dbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)))
		lImprime := .F.
		cErro += "Comunicacao remota (SEE) nao localizada para o banco/agencia/conta do titulo. "
	EndIf

	SEA->(dbSetOrder(1))
	If !SEA->(dbSeek(xFilial("SEA")+SE1->(E1_NUMBOR+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
		lImprime := .F.
		cErro += "Vinculo com o titulo enviado ao banco (SEA) nao localizado - titulo ainda nao remetido ao banco. "
	EndIf

	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))

	If lImprime
		cPortado    := alltrim(SE1->E1_PORTADO)
		cBanco      := alltrim(SA6->A6_NOME)
		cAgencia    := alltrim(SE1->E1_AGEDEP)
		cConta      := alltrim(SE1->E1_CONTA)
		cLinha      := alltrim(SE1->E1_CODDIG)
		cBarra      := alltrim(SE1->E1_CODBAR)
		cNosso      := alltrim(SE1->E1_NUMBCO)
		cCarteira   := alltrim(SEE->EE_CODCART)
		cEspecie    := alltrim(SEA->EA_ESPECIE)
		cEmissao    := LOCW063G(SE1->E1_EMISSAO)
		cVencimento := LOCW063G(SE1->E1_VENCTO)
		cValor      := StrTran(alltrim(Str(SE1->E1_VALOR, 17, 2)), ",", ".")
		cMoeda      := "BRL"
		cBenNome    := alltrim(SM0->M0_NOME)
		cBenCNPJ    := alltrim(SM0->M0_CGC)
		cBenRua     := alltrim(SM0->M0_ENDENT)
		cBenBairro  := alltrim(SM0->M0_BAIRENT)
		cBenCidade  := alltrim(SM0->M0_CIDENT)
		cBenUF      := alltrim(SM0->M0_ESTENT)
		cBenCep     := alltrim(SM0->M0_CEPENT)
		cNome       := alltrim(SA1->A1_NOME)
		cDocumento  := alltrim(SA1->A1_CGC)
		cRua        := alltrim(SA1->A1_END)
		cBairro     := alltrim(SA1->A1_BAIRRO)
		cCidade     := alltrim(SA1->A1_MUN)
		cUF         := alltrim(SA1->A1_EST)
		cCEP        := alltrim(SA1->A1_CEP)
	EndIf

	If lImprime
		cPayload := '{'
		cPayload += '"banco": {'
		cPayload += '"codigo": "'+cPortado+'",'
		cPayload += '"nome": "'+LOCW063F(cBanco)+'"'
		cPayload += '},'
		cPayload += '"titulo": {'
		cPayload += '"linha_digitavel": "'+cLinha+'",'
		cPayload += '"codigo_barras": "'+cBarra+'",'
		cPayload += '"nosso_numero": "'+cNosso+'",'
		cPayload += '"carteira": "'+cCarteira+'",'
		cPayload += '"especie_documento": "'+cEspecie+'",'
		cPayload += '"aceite": "N",'
		cPayload += '"data_emissao": "'+cEmissao+'",'
		cPayload += '"data_vencimento": "'+cVencimento+'",'
		cPayload += '"valor": '+cValor+','
		cPayload += '"moeda": "'+cMoeda+'",'
		cPayload += '"valor_documento": '+cValor
		cPayload += '},'
		cPayload += '"beneficiario": {'
		cPayload += '"nome": "'+LOCW063F(cBenNome)+'",'
		cPayload += '"cnpj": "'+cBenCNPJ+'",'
		cPayload += '"endereco": {'
		cPayload += '"logradouro": "'+LOCW063F(cBenRua)+'",'
		cPayload += '"numero": "'+cBenNum+'",'
		cPayload += '"bairro": "'+LOCW063F(cBenBairro)+'",'
		cPayload += '"cidade": "'+LOCW063F(cBenCidade)+'",'
		cPayload += '"uf": "'+cBenUF+'",'
		cPayload += '"cep": "'+cBenCep+'"'
		cPayload += '},'
		cPayload += '"agencia": "'+cAgencia+'",'
		cPayload += '"conta": "'+cConta+'"'
		cPayload += '},'
		cPayload += '"pagador": {'
		cPayload += '"nome": "'+LOCW063F(cNome)+'",'
		cPayload += '"documento": "'+cDocumento+'",'
		cPayload += '"endereco": {'
		cPayload += '"logradouro": "'+LOCW063F(cRua)+'",'
		cPayload += '"numero": "'+cNumero+'",'
		cPayload += '"bairro": "'+LOCW063F(cBairro)+'",'
		cPayload += '"cidade": "'+LOCW063F(cCidade)+'",'
		cPayload += '"uf": "'+cUF+'",'
		cPayload += '"cep": "'+cCEP+'"'
		cPayload += '}'
		cPayload += '}'
		cPayload += '}'
	EndIf

Return { cPayload, AllTrim(cErro) }


/*/{PROTHEUS.DOC} LOCW063H
ITUP BUSINESS - TOTVS RENTAL
Converte uma lista de bytes decimais separados por virgula (formato
retornado pela API de boleto no campo pdf_base64) para uma string
base64 valida.
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 08/06/2026
/*/
Static Function LOCW063H(cCsvBytes)
Local aBytes   := StrTokArr(cCsvBytes, ",")
Local cBinario := ""
Local nY       := 0

	For nY := 1 To Len(aBytes)
		cBinario += Chr(Val(AllTrim(aBytes[nY])))
	Next

	// Encode64 quebra a saida em linhas (estilo MIME); removemos as quebras
	// pois o valor sera embutido como uma unica string no JSON de retorno.
Return StrTran(StrTran(Encode64(cBinario), Chr(13), ""), Chr(10), "")

/*/{PROTHEUS.DOC} LOCW063F
ITUP BUSINESS - TOTVS RENTAL
Escapa uma string para uso seguro dentro de um valor JSON
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 08/06/2026
/*/
Static Function LOCW063F(cTxt)
Local cRet := Alltrim(cTxt)

	cRet := StrTran(cRet, '\', '\\')
	cRet := StrTran(cRet, '"', '\"')
	cRet := StrTran(cRet, Chr(13)+Chr(10), " ")
	cRet := StrTran(cRet, Chr(10), " ")
	cRet := StrTran(cRet, Chr(13), " ")

Return cRet

/*/{PROTHEUS.DOC} LOCW063G
ITUP BUSINESS - TOTVS RENTAL
Converte uma data para o formato YYYY-MM-DD exigido pela API de boleto
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 08/06/2026
/*/
Static Function LOCW063G(dData)
Local cRet := ""

	If ValType(dData) == "D" .and. !Empty(dData)
		cRet := SubStr(DToS(dData),1,4)+"-"+SubStr(DToS(dData),5,2)+"-"+SubStr(DToS(dData),7,2)
	EndIf

Return cRet
