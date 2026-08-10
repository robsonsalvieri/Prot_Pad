#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSJURPEDIDOS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurPedidos
Métodos WS do Jurídico para pedidos

@author SIGAJURI
@since 11/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL JURPEDIDOS DESCRIPTION STR0001 // "WS para Pedidos"

	WSMETHOD GET hasAPI       DESCRIPTION STR0002 PATH "hasApiJurPedidos"     PRODUCES APPLICATION_JSON // "Retorna que a API existe no rpo"

	WSMETHOD PUT correcao     DESCRIPTION STR0003 PATH "correcao"             PRODUCES APPLICATION_JSON // "Realiza a correção de valores monetários de todos os pedidos de um processo"
	WSMETHOD PUT altLotePed   DESCRIPTION STR0004 PATH "altLotePed"           PRODUCES APPLICATION_JSON // "Realiza alteração em lote de pedidos de um processo"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} hasAPI
Retorna que a API existe no rpo

@since 26/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET hasAPI WSREST JURPEDIDOS

	Self:SetContentType("application/json")
	Self:SetResponse('{"ok":"true"}')

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT correcao
Método responsável pela alteração de um modelo de exportação personalizada

@param body - Json com os dados do processo, filial, cajuri e códigos dos pedidos
@return lRet - Indica se a correção moentária foi aplicada com sucesso

@since 11/07/2024
@example [Sem Opcional] PUT -> http://localhost:12173/rest/JURPEDIDOS/correcao
	body - {
			"processo: "MDEwMDAwMDAwOTc3",
			"pedidos": [
				"0000000001",
				"0000000002"
			]
		}
/*/
//-------------------------------------------------------------------
WSMETHOD PUT correcao WSREST JURPEDIDOS
Local aArea      := GetArea()
Local oRequest   := JsonObject():New()
Local oResponse  := JsonObject():New()
Local cBody      := Self:GetContent()
Local lRet       := .T.
Local cChaveProc := ""
Local cFilialPro := ""
Local cCajuri    := ""
Local nTamFilial := TamSX3("O0W_FILIAL")[1]
Local nTamCajuri := TamSX3("O0W_CAJURI")[1]
Local cMsgErro   := ""
Local nX         := 0

	oRequest:FromJson(cBody)

	If !Empty(oRequest["processo"])
		cChaveProc := Decode64(oRequest["processo"])
		cFilialPro := Substr(cChaveProc, 1, nTamFilial)
		cCajuri    := Substr(cChaveProc, nTamFilial + 1, nTamCajuri)

		DbSelectArea("NSY")
		NSY->(DbSetOrder(1))  // NSY_FILIAL + NSY_CAJURI
		DbSelectArea("O0W")
		O0W->(DbSetOrder(1))  // O0W_FILIAL + O0W_COD

		DbSelectArea("NSZ")
		NSZ->(DbSetOrder(1))  // NSZ_FILIAL + NSZ_COD
		NSZ->(DbSeek(cFilialPro + cCajuri))

		For nX := 1 To Len(oRequest["pedidos"])
			If lRet
				If JURCORVLRS('NSY', cCajuri, , , , .T., oRequest["pedidos"][nX])
					JAtuValO0W(cCajuri)
				Else
					Loop
				EndIf
			EndIf
		Next nX

	Else
		lRet := .F.
		cMsgErro := JurEncUTF8(STR0005) // "É necessário informar o processo para relizar a atualização de valores. Verifique!"
	EndIf

	If lRet
		Self:SetContentType("application/json")
		oResponse['ok'] := .T.
		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	Else
		JRestError(404, cMsgErro)
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT altLotePed
Método responsável pela alteração em lote de pedidos

@param body  - Dados dos pedidos que serão alterados em lote
@return lRet - Indica se a alteração em lote foi executada com sucesso

@since 11/07/2024
@example [Sem Opcional] PUT -> http://localhost:12173/rest/JURPEDIDOS/altLotePed
	body = {
    "processo": "RCBNRyAwMSA=MDAwMDAwMDk4MA==",
    "codigoWF": "",
    "pedidos": [
        {
            "pedido": "RCBNRyAwMSA=MDAwMDAwMTY1OA==",
            "codWF": "",
            "O0W_PROGNO": {
                "oldValue": "Provável",
                "newValue": ""
            },
            "O0W_DATPED": {
                "oldValue": "",
                "newValue": "20150101"
            },
            "O0W_CFRCOR": {
                "oldValue": "09",
                "newValue": "09"
            },
            "O0W_VPEDID": {
                "oldValue": 500000,
                "newValue": 600000
            },
            "O0W_VPROVA": {
                "oldValue": 300000,
                "newValue": 200000
            },
            "O0W_VPOSSI": {
                "oldValue": 150000,
                "newValue": 150000
            },
            "O0W_VREMOT": {
                "oldValue": 17000,
                "newValue": 5000
            },
            "O0W_VINCON": {
                "oldValue": 33000,
                "newValue": 0
            },
            "O0W_DTJURO": {
                "oldValue": "",
                "newValue": "20150101"
            },
            "O0W_REDUT": {
                "oldValue": "2",
                "newValue": "2"
            }
        }
    ]
}
/*/
//-------------------------------------------------------------------
WSMETHOD PUT altLotePed WSREST JURPEDIDOS
Local aArea       := GetArea()
Local aAreaO0W    := O0W->( GetArea() )
Local oRequest    := JsonObject():New()
Local oResponse   := JsonObject():New()
Local oMdl310     := Nil
Local oModelO0W   := Nil
Local cBody       := Self:GetContent()
Local cChaveProc  := ""
Local cFilialPro  := ""
Local cCajuri     := ""
Local cCodPedido  := ""
Local cTexto      := ""
Local cDesc       := ""
Local cCodWF      := ""
Local cSeparador  := CRLF + "//-------------------------------------------------------------------//" + CRLF
Local nTamFilial  := TamSX3("O0W_FILIAL")[1]
Local nTamCajuri  := TamSX3("O0W_CAJURI")[1]
Local nTamPedido  := TamSX3("O0W_COD")[1]
Local lRet        := .F.
Local nX          := 0
Local nVlrAprov   := 0
Local nPosValO0W  := 0
Local nPosDtPed   := 0
Local nPosDtJuros := 0
Local nPosBKP     := 0
Local nvlrBKPvlr  := 0
Local nDataPed    := 0
Local nDataJuros  := 0
Local nVlrPos     := 0
Local nVlrPossi   := 0
Local nOpc        := 3  // Inclusão
Local aPedidos    := {}
Local aDadFwApv   := {}
Local aPedNZK     := {}
Local aErros      := {}
Local aSuccessNTA := {}
Local aBkpO0W     := {}
Local dDataPed    := CTOD("  /  /    ")
Local dDataJuros  := CTOD("  /  /    ")

Private cTipoASJ := ""

	oRequest:FromJson(cBody)

	// Verifica se o fup é pendente para definir se irá incluir ou alterar NTA (necessário para situação em que a aprovação foi recusada)
	cCodWF := oRequest["codigoWF"]

	If !Empty(cCodWf) .And. J94FTarFw(xFilial("O0W"), cCodWf, "6", "1") // Posiciona no Fup // Tipo(6=Aprovação de Objeto) / Resultado(1=Pendente)
		nOpc := 4 // Alteração
	EndIf

	// Considera somente os pedidos que são do mesmo fup de aprovação
	For nX := 1 To Len(oRequest["pedidos"])
		If Empty(oRequest["pedidos"][nX]["codWF"]) .OR. oRequest["pedidos"][nX]["codWF"] == cCodWF
			aAdd(aPedidos, oRequest["pedidos"][nX])
		EndIf
	Next nX

	If !Empty(oRequest["processo"]) .AND. Len(aPedidos) > 0
		cChaveProc := Decode64(oRequest["processo"])
		cFilialPro := Substr(cChaveProc, 1, nTamFilial)
		cCajuri    := Substr(cChaveProc, nTamFilial + 1, nTamCajuri)
		cTipoASJ   := JurGetDados("NSZ", 1, cFilialPro + cCajuri, "NSZ_TIPOAS")

		oMdl310 := FWLoadModel("JURA310")
		oMdl310:SetOperation(4)  // Alteração

		For nX := 1 To Len(aPedidos)
			cCodPedido := Substr(Decode64(aPedidos[nX]["pedido"]), nTamFilial + 1, nTamPedido)

			DbSelectArea("O0W")
			O0W->(DbSetOrder(1))  // O0W_FILIAL + O0W_COD
			
			If O0W->(DbSeek(cFilialPro + cCodPedido))
				oMdl310:Activate()
				oModelO0W := oMdl310:GetModel("O0WMASTER")

				JSetDataPe(oModelO0W, aPedidos[nX], cCodWF) // Seta os dados no modelo da O0W
				aBkpO0W := aClone(oModelO0W:adatamodel[1])
				nVlrPossi := aPedidos[nX]:O0W_VPOSSI["newValue"]

				nPosDtPed := aScan(oModelO0W:adatamodel[1], {|x| x[1] == "O0W_DATPED" })
				dDataPed  := oModelO0W:adatamodel[1][nPosDtPed][2]

				nPosDtJuros := aScan(oModelO0W:adatamodel[1], {|x| x[1] == "O0W_DTJURO" })
				dDataJuros  := oModelO0W:adatamodel[1][nPosDtJuros][2]
				
				If (lRet := oMdl310:VldData())
					nPosBKP    := aScan(oModelO0W:adatamodel[1], {|x| x[1] == "O0W__ALVLR" })
					nvlrBKPvlr := oModelO0W:adatamodel[1][nPosBKP][2]
					lRet := lRet .AND. oMdl310:CommitData()
				EndIf

				If !lRet
					aAdd(aErros, {cCodPedido, oModelO0W:GetModel("O0WMASTER"):GetErrorMessage()})
					Exit
				EndIf

				If lRet
					JSetCpos(aBkpO0W, aDadFwApv)
					If Len(aDadFwApv) > 0
						aAdd(aDadFwApv, aClone({"O0W_COD", cCodPedido}) )
						aAdd(aDadFwApv, aClone({"O0W_CODWF", cCodWF})   )
						aAdd(aPedNZK,   aClone(aDadFwApv)               )
						
						// Acumula valor para aprovação
						nPosValO0W := aScan(aDadFwApv,{|x| x[1] == "O0W__ALVLR"})
						aDadFwApv[nPosValO0W][2] := nvlrBKPvlr
						nVlrAprov += nvlrBKPvlr

						nDataPed := aScan(aDadFwApv,{|x| x[1] == "O0W_DATPED"})
						aDadFwApv[nDataPed][2] := dDataPed

						nDataJuros := aScan(aDadFwApv,{|x| x[1] == "O0W_DTJURO"})
						aDadFwApv[nDataJuros][2] := dDataJuros

						nVlrPos := aScan(aDadFwApv,{|x| x[1] == "O0W_VPOSSI"})
						aDadFwApv[nVlrPos][2] := nVlrPossi

						// Texto da aprovação
						If nX > 1
							cTexto += cSeparador
						EndIf
						cTexto += JO0WSetText(oModelO0W, aDadFwApv, 4)
					EndIf

					aSize(aDadFwApv, 0)
					oMdl310:DeActivate()
				EndIf
			EndIf
		Next nX

		If lRet .AND. !Empty(cTexto)
			cDesc += STR0006 + AllTrim( Transform(nVlrAprov , "@E 99,999,999,999.99") ) + CRLF  // "Valor para aprovação: "
			cDesc += cSeparador
			cDesc += cTexto
		EndIf

		// cria/atualiza o fup de aprovação
		If lRet
			lRet := JPedAtuFup(nOpc, cFilialPro, cCajuri, aPedNZK, nVlrAprov, cDesc, @aErros, @aSuccessNTA)
		EndIf
	EndIf

	If lRet
		oResponse['pedidos']  := aSuccessNTA
		oResponse["errosMVC"] := {}
		oResponse["msg"]      := STR0007 // Processamento realizado com sucesso!
		Self:SetResponse(oResponse:toJson())
	Else
		oResponse['pedidos']  := {}
		oResponse["errosMVC"] := aErros
		oResponse["msg"]      := JurEncUTF8(STR0008) // "Não foi possível incluir o follow-up de aprovação. Verifique!"
		SetRestFault(400, oResponse:toJson())
	EndIf
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aAreaO0W)
	RestArea(aArea)

	aSize(aPedidos,    0)
	aSize(aDadFwApv,   0)
	aSize(aPedNZK,     0)
	aSize(aErros,      0)
	aSize(aSuccessNTA, 0)
	aSize(aBkpO0W,     0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JSetDataPe
Responsável por setar os dados do pedido no modelo instanciado

@param oMdl310 - Modelo MVC de pedidos
@param oPedido - Objeto com dados do pedido
@param cCodWF  - Código do Workflow no Fluig
@return .T.
@since 16/07/2024
/*/
//-------------------------------------------------------------------
Static Function JSetDataPe(oMdl310, oPedido, cCodWF)
Local nI          := 0
Local cCampo      := ""
Local aListCampos := ClassDataArr(oPedido)

	For nI := 1 To Len(aListCampos)
		cCampo := aListCampos[nI][1]
		If (cCampo $ "O0W_DTJURO|O0W_DATPED")
			oMdl310:SetValue(cCampo, STOD(oPedido[cCampo]["newValue"]))
		ElseIf !(cCampo $ "pedido|codWF|O0W_VPOSSI")
			oMdl310:SetValue(cCampo, oPedido[cCampo]["newValue"])
		EndIf
	Next nI

	If !Empty(cCodWF)
		oMdl310:SetValue("O0W_CODWF", cCodWF)
	EndIf

	oMdl310:LoadValue("O0W__ALTPD", .T.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JO0WSetText
Responsável por setar os dados do pedido no modelo instanciado

@param oMdl310 - Modelo MVC de pedidos
@param aCampos - Lista de campo / valor
@param nOpc    - Operação (3=Inclusão / 4=Alteração)
@return cDesc  - Texto de aprovação
@since 16/07/2024
/*/
//-------------------------------------------------------------------
Static Function JO0WSetText(oModelO0W, aCampos, nOpc)
Local cDesc      := ""
Local cProgAtual := ""
Local nPosValO0W := Ascan(aCampos,{|x| x[1] == "O0W__ALVLR"})
Local nValorO0W  := aCampos[nPosValO0W][2] //Valor que será enviado para aprovação
Local nPosProgAp := Ascan(aCampos, {|x| x[1] == "O0W_PROGNO"})
Local cProgAprov := AllTrim(aCampos[nPosProgAp][2]) //Descrição do grupo de aprovação
Local nVlrPedAtu := 0 //Valor atual do pedido
Local nPosPedApr := Ascan(aCampos, {|x| x[1] == "O0W_VPEDID"})
Local nVlrPedApr := aCampos[nPosPedApr][2]//Valor a aprovar do pedido
Local nVlrPrvAtu := 0 //Valor atual provável
Local nPosPrvApr := Ascan(aCampos, {|x| x[1] == "O0W_VPROVA"})
Local nVlrPrvApr := aCampos[nPosPrvApr][2]//Valor a aprovar provável
Local nVlrPssAtu := 0 //Valor atual possível
Local nPosPssApr := Ascan(aCampos, {|x| x[1] == "O0W_VPOSSI"})
Local nVlrPssApr := aCampos[nPosPssApr][2]//Valor a aprovar possível
Local nVlrRemAtu := 0 //Valor atual remoto
Local nPosRemApr := Ascan(aCampos, {|x| x[1] == "O0W_VREMOT"})
Local nVlrRemApr := aCampos[nPosRemApr][2]//Valor a aprovar remoto
Local nVlrIncAtu := 0 //Valor atual incontroverso
Local nPosIncApr := Ascan(aCampos, {|x| x[1] == "O0W_VINCON"})
Local nVlrIncApr := aCampos[nPosIncApr][2]//Valor a aprovar incontroverso
Local dDtPedAtu  := "" //Data atual do pedido
Local nDtPedApr  := Ascan(aCampos, {|x| x[1] == "O0W_DATPED"})
Local dDtPedApr  := aCampos[nDtPedApr][2]//Data a aprovar do pedido
Local dDtJuroAtu := "" //Data atual de juros
Local nDtJuroApr := Ascan(aCampos, {|x| x[1] == "O0W_DTJURO"})
Local dDtJuroApr := aCampos[nDtJuroApr][2]//Data a aprovar  de juros
Local cForCorAtu := "" //Forma de correção atual
Local nDtMultaApr := Ascan(aCampos, {|x| x[1] == "O0W_DTMULT"})
Local dDtMultaApr := aCampos[nDtMultaApr][2]//Data a aprovar  de multa
Local dDtMultaAtu := "" //Data atual de multa
Local nPercMulApr := Ascan(aCampos, {|x| x[1] == "O0W_PERMUL"})
Local cPercMulApr := aCampos[nPercMulApr][2]//Porcentagem a aprovar de multa
Local cPercMulAtu := "" //Porcentagem de multa atual
Local nForCorApr := Ascan(aCampos, {|x| x[1] == "O0W_CFRCOR"})
Local cForCorApr := cValToChar(aCampos[nForCorApr][2])//Forma de correção a aprovar

	If nOpc == MODEL_OPERATION_UPDATE
		cProgAtual  := O0W->O0W_PROGNO
		nVlrPedAtu  := O0W->O0W_VPEDID
		nVlrPrvAtu  := O0W->O0W_VPROVA
		nVlrPssAtu  := O0W->O0W_VPOSSI
		nVlrRemAtu  := O0W->O0W_VREMOT
		nVlrIncAtu  := O0W->O0W_VINCON
		dDtPedAtu   := O0W->O0W_DATPED
		dDtJuroAtu  := O0W->O0W_DTJURO
		cForCorAtu  := O0W->O0W_CFRCOR
		dDtMultaAtu := O0W->O0W_DTMULT
		cPercMulAtu := O0W->O0W_PERMUL
	EndIf

	cDesc := STR0009 + JurGetDados("NSP", 1, xFilial("NSP") + oModelO0W:GetValue("O0W_CTPPED"), "NSP_DESC") // "Aprovação de Alteração no Pedido: "
	cDesc += CRLF + STR0010 + AllTrim( Transform(nValorO0W , "@E 99,999,999,999.99") )                      // "Valor para aprovação: "
	cDesc += CRLF + STR0011 + cProgAtual                                                                    // "Prognóstico atual: "
	cDesc += CRLF + STR0012 + cProgAprov                                                                    // "Prognóstico após aprovação: "

	cDesc += CRLF + STR0013  // "Data atual do pedido: "
	If !Empty(dDtPedAtu)
		cDesc += DToC(dDtPedAtu) 
	EndIf

	cDesc += CRLF + STR0014 + DToC(dDtPedApr)                                                // "Data do pedido após aprovação: "
	cDesc += CRLF + STR0015 + JurGetDados("NW7", 1, xFilial("NW7") + cForCorAtu, "NW7_DESC") // "Forma de correção atual: "
	cDesc += CRLF + STR0016 + JurGetDados("NW7", 1, xFilial("NW7") + cForCorApr, "NW7_DESC") // "Forma de correção após aprovação: "
	cDesc += CRLF + STR0017 + AllTrim( Transform(nVlrPedAtu, "@E 99,999,999,999.99") )       // "Valor do pedido atual: "
	cDesc += CRLF + STR0018 + AllTrim( Transform(nVlrPedApr, "@E 99,999,999,999.99") )       // "Valor do pedido após aprovação: "
	cDesc += CRLF + STR0019 + AllTrim( Transform(nVlrPrvAtu, "@E 99,999,999,999.99") )       // "Valor provável atual: "
	cDesc += CRLF + STR0020 + AllTrim( Transform(nVlrPrvApr, "@E 99,999,999,999.99") )       // "Valor provável após aprovação: "
	cDesc += CRLF + STR0021 + AllTrim( Transform(nVlrPssAtu, "@E 99,999,999,999.99") )       // "Valor possível atual: "
	cDesc += CRLF + STR0022 + AllTrim( Transform(nVlrPssApr, "@E 99,999,999,999.99") )       // "Valor possível após aprovação: "
	cDesc += CRLF + STR0023 + AllTrim( Transform(nVlrRemAtu, "@E 99,999,999,999.99") )       // "Valor remoto atual: "
	cDesc += CRLF + STR0024 + AllTrim( Transform(nVlrRemApr, "@E 99,999,999,999.99") )       // "Valor remoto após aprovação: "
	cDesc += CRLF + STR0025 + AllTrim( Transform(nVlrIncAtu, "@E 99,999,999,999.99") )       // "Valor incontroverso atual: "
	cDesc += CRLF + STR0026 + AllTrim( Transform(nVlrIncApr, "@E 99,999,999,999.99") )       // "Valor incontroverso após aprovação: "

	cDesc += CRLF + STR0027  // "Data de juros atual: "
	If !Empty(dDtJuroAtu)
		cDesc += DToC(dDtJuroAtu)
	EndIf

	cDesc += CRLF + STR0028  // "Data de juros após aprovação: "
	If !Empty(dDtJuroApr)
		cDesc += DToC(dDtJuroApr)
	EndIf	
	cDesc += CRLF + STR0029  // "Data de multa atual: "
	If !Empty(dDtMultaAtu)
		cDesc += DToC(dDtMultaAtu)
	EndIf	
	cDesc += CRLF + STR0030  // "Data de multa após aprovação: "
	If !Empty(dDtMultaApr)
		cDesc += DToC(dDtMultaApr)
	EndIf
	cDesc += CRLF + STR0031 + AllTrim(cPercMulAtu) + Iif(!Empty(cPercMulAtu), "%", "")  // "Porcentagem de multa atual: "
	cDesc += CRLF + STR0032 + AllTrim(cPercMulApr) + Iif(!Empty(cPercMulApr), "%", "")  // "Porcentagem de multa após aprovação: "

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} JPedAtuFup
Responsável por criar/atualizar follow de aprovação

@param  nOpc        - Operação (3=Inclusão / 4=Alteração)
@param  cFilialPro  - Filial do processo
@param  cProcesso   - Código do processo
@param  aPedNZK     - Lista de valores dos pedidos alterados
@param  nValorO0W   - Valor dos pedidos acumulado para aprovação
@param  cDesc       - Texto de descrição para tarefa de aprovação
@param  aErros      - Lista de erros
@param  aSuccessNTA - Lista de pedidos alterados com sucesso
@return lRet        - Indica se o fup foi gravado com sucesso
@since 16/07/2024
/*/
//-------------------------------------------------------------------
Static function JPedAtuFup(nOpc, cFilialPro, cProcesso, aPedNZK, nValorO0W, cDesc, aErros, aSuccessNTA)
Local oModel106   := Nil
Local oModelNTA   := Nil
Local dDataFup    := DataValida(Date(),.T.)
Local cCodFlwp    := ""
local cCodWF      := ""
Local cCodPedido  := ""
Local cPart       := JurUsuario(__cUserId)
Local cSigla      := JurGetDados("RD0", 1, xFilial("RD0") + cPart, "RD0_SIGLA") // RD0_FILIAL + RD0_CODIGO
Local cTipoFw     := JurGetDados("NQS", 3, xFilial("NQS") + "6", "NQS_COD") // NQS_FILIAL + NQS_TAPROV / 6=Objeto
Local cResultFw   := JurGetDados("NQN", 3, xFilial("NQN") + "4", "NQN_COD") // NQN_FILIAL + NQN_TIPO / 4=Em Aprovação
Local nX          := 0
Local nPosCodO0W  := 0
local aNTA        := {}
Local aNTE        := {}
Local aNZK        := {}
Local aNZM        := {}
Local lRet        := .F.

	// Se existe follow-up pendente
	If nOpc == 4
		cResultFw := JurGetDados("NQN", 3, xFilial("NQN") + "2", "NQN_COD") // NQN_FILIAL + NQN_TIPO / 2=Concluido
		cDesc     := AllTrim(cDesc) + CRLF + Replicate("-", 5) + CRLF + AllTrim(NTA->NTA_DESC)

		aAdd(aNZM, {"NZM_CODWF"	, AllTrim(NTA->NTA_CODWF)} )
		aAdd(aNZM, {"NZM_CAMPO"	, "sObsExecutor"         } )
		aAdd(aNZM, {"NZM_CSTEP"	, "16"                   } )
		aAdd(aNZM, {"NZM_STATUS", "2"                    } )
	EndIf

	oModel106 := FWLoadModel("JURA106")
	oModel106:SetOperation(nOpc)  // 3=Inclusão / 4=Alteração
	oModel106:Activate()

	oModelNTA := oModel106:GetModel("NTAMASTER")
	cCodFlwp  := oModelNTA:GetValue("NTA_COD")

	// Dados principais
	Aadd(aNTA, {"NTA_CAJURI", cProcesso        } )
	Aadd(aNTA, {"NTA_CTIPO" , cTipoFw          } )
	Aadd(aNTA, {"NTA_DTFLWP", dDataFup         } )
	Aadd(aNTA, {"NTA_CRESUL", cResultFw        } )
	Aadd(aNTA, {"NTA__VALOR", Abs( nValorO0W ) } )
	Aadd(aNTA, {"NTA_DESC"  , cDesc            } )

	// Responsável
	Aadd(aNTE, {"NTE_SIGLA", cSigla} )
	Aadd(aNTE, {"NTE_CPART", cPart } )
	lRet := JSetNTANTE(oModel106, nOpc, aNTA, aNTE)

	If lRet
		oModel106:GetModel("NZKDETAIL"):GoLine(1)
		oModel106:GetModel("NZKDETAIL"):DeleteLine()

		// Campos do pedido para aprovação
		For nX := 1 To Len(aPedNZK)
			nPosCodO0W := aScan(aPedNZK[nX],{|x| x[1] == "O0W_COD"})
			cCodPedido := aPedNZK[nX][nPosCodO0W][2]

			JSetCpoNZK(aPedNZK[nX], .T., @aNZK, cCodPedido)
			lRet := JPedSetNZK(aNZK, oModel106, cCodPedido)

			If lRet
				aAdd(aSuccessNTA, cCodPedido)
			Else
				aAdd(aErros, {cCodPedido, oModel106:GetErrorMessage()})
				Loop
			EndIf
		Next nX

		If lRet
			If nOpc == 4 // Alteração
				For nX := 1 To Len( aNZM )
					If !( oModel106:SetValue("NZMDETAIL", aNZM[nX][1], aNZM[nX][2]) )
						lRet := .F.
						Exit
					EndIf
				Next nX
			EndIf
		EndIf
	EndIf

	If lRet
		// Grava Fup
		If ( lRet := oModel106:VldData() .AND. oModel106:CommitData())
			cCodWF := oModel106:GetValue("NTAMASTER", "NTA_CODWF")

			// Valida se o FUP esta concluído e seta os valores necessários
			lRet := JVldConc(oModel106:GetValue("NTAMASTER","NTA_CRESUL"), aPedNZK, aSuccessNTA, cFilialPro, aErros, cCodWF)

			// Verifica se há pedidos com cod WF que não foram alterados
			If lRet .AND. nOpc == 4 // Alteração
				JVldPedNTA(cFilialPro, cProcesso, cCodWF, aSuccessNTA)
			EndIf

		Else
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		aAdd(aErros, {cCodPedido, oModel106:GetErrorMessage()})
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} setDataTipo
Converte o conteúdo de acordo com o tipo de dado

@param  cConteudo - Conteúdo a ser convertido
@return cConteudo - Dado convertido
@since 18/07/2024
/*/
//-------------------------------------------------------------------
Static Function setDataTipo(cConteudo)

	Do Case
		Case ValType( cConteudo ) == "D"
			cConteudo := DtoS( cConteudo )
		Case ValType( cConteudo ) == "N"
			cConteudo := cValToChar( cConteudo )
	End Case

Return cConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} JSetCpoNZK
Seta os campos para aprovação do pedido

@param  aCampos    - Lista de campos que serão gravados na NZK
@param  lCallJ310  - Indica se a chamada esta sendo feita pelo JURA310
@param  aNZK       - Lista de campos e valores para a aprovação
@param  cCodPedido - Código do pedido
@return Nil
@since 18/07/2024
/*/
//-------------------------------------------------------------------
Function JSetCpoNZK(aCampos, lCallJ310, aNZK, cCodPedido)
Local nX         := 0
Local cCampo     := ""
Local cValor     := ""
Local aAprovPed  := {}
Local aCamposNZK := {"O0W_DATPED", "O0W_CFRCOR", "O0W_VPEDID", "O0W_VPROVA", "O0W_VPOSSI",;
						"O0W_VREMOT", "O0W_VINCON","O0W_DTJURO", "O0W_REDUT","O0W_PROGNO"}

	aNZK := {}

	For nX := 1 To Len( aCampos )
		If aScan(aCamposNZK, {|x| x == aCampos[nX][1]}) > 0 .and. !aCampos[nX][1] $ "PROV_O0W/O0W_VPOSSI/O0W_COD/O0W_CODWF"
			cCampo    := aCampos[nX][1]
			cValor    := setDataTipo(aCampos[nX][2])

			aAprovPed := {}
			Aadd(aAprovPed, {"NZK_STATUS", "1" } ) // 1=Em Aprovacao
			If lCallJ310
				Aadd(aAprovPed, { "NZK_FONTE" , "JURA310"   } )
				Aadd(aAprovPed, { "NZK_MODELO", "O0WMASTER" } )
			Else
				Aadd(aAprovPed, { "NZK_FONTE" , "JURA270"   } )
				Aadd(aAprovPed, { "NZK_MODELO", "O0WDETAIL" } )
			EndIf
			Aadd(aAprovPed, { "NZK_CAMPO" , cCampo                      } )
			Aadd(aAprovPed, { "NZK_VALOR" , cValor                      } )
			Aadd(aAprovPed, { "NZK_CHAVE" , xFilial("O0W") + cCodPedido } )
			aAdd(aNZK, aAprovPed)
		EndIf
	Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPedSetNZK
Seta os campos para aprovação de um pedido
 
@param  aNZK        - Dados para aprovação
@param  oModel106   - Objeto do MVC da tarefa / fup
@param  cCodPedido  - Código do pedido
@return lRet        - Indica se todos os campos foram setados
@since 18/07/2024
/*/
//-------------------------------------------------------------------
Function JPedSetNZK(aNZK, oModel106, cCodPedido)
Local lRet       := .T.
Local nReg       := 0
Local nCont      := 0

	For nReg := 1 To Len( aNZK ) // Cada linha de NZK
		oModel106:GetModel("NZKDETAIL"):AddLine()

		For nCont := 1 To Len(aNZK[nReg]) // Cada campo da linha
			If !( oModel106:SetValue("NZKDETAIL", aNZK[nReg][nCont][1], aNZK[nReg][nCont][2]) )
				lRet := .F.
				Exit
			EndIf
		Next nCont
	Next nReg

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JSetNTANTE

@param  oModel106 - Objeto do MVC da tarefa / fup
@param  nOpcFw    - Operação (3=Inclusão / 4=Alteração)
@param  aNTA      - Campos e valores de detalhes da tarefa
@param  aNTE      - Campos e valores do responsável da tarefa
@return lret      - Indica se os campos foram setados
@since 23/07/2024
/*/
//-------------------------------------------------------------------
Function JSetNTANTE(oModel106, nOpcFw, aNTA, aNTE)
Local nCont    := 0
Local lRet     := .T.

	For nCont := 1 To Len( aNTA )
		If aNTA[nCont][1] == "NTA_CAJURI"
			If nOpcFw == 3  // Inclusão
				oModel106:LoadValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2])
			EndIf
			Loop
		EndIf

		If aNTA[nCont][1] == "NTA_CRESUL"
			If nOpcFw == 4  // Alteração
				oModel106:LoadValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2])
			Else
				If !( oModel106:SetValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2]) )
					lRet := .F.
					Exit
				EndIf
			EndIf
		Else
			If !( oModel106:SetValue("NTAMASTER", aNTA[nCont][1], aNTA[nCont][2]) )
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nCont

	// Responsável
	If lRet
		If nOpcFw == 3 // Inclusão
			For nCont := 1 To Len( aNTE )
				If !( oModel106:SetValue("NTEDETAIL", aNTE[nCont][1], aNTE[nCont][2]) )
					lRet := .F.
					Exit
				EndIf
			Next nCont
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JSetCpos
Seta os campos necessários para enviar os valores para aprovação

@param  aCampoValor - Campos e valores dos pedidos
@param  aDadFwApv   - Valores para aprovação
@return Nil
@since 23/07/2024
/*/
//-------------------------------------------------------------------
Static Function JSetCpos(aCampoValor, aDadFwApv)
Local nX  := 0

	For nX := 1 To Len(aCampoValor)
		aAdd(aDadFwApv, { aCampoValor[nX][1], aCampoValor[nX][2]})
	Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldPedNTA
Limpa o campos de codWF dos pedidos que foram recusados, porém não 
serão alterados novamente

@param  cFilPro     - Filial do processo
@param  cCajuri     - Código do processo
@param  cCodWF      - Código do workflow do Fluig
@param  aSuccessNTA - Lista de pedidos alterados com sucesso
@return Nil
@since 23/07/2024
/*/
//-------------------------------------------------------------------
Static Function JVldPedNTA(cFilPro, cCajuri, cCodWF, aSuccessNTA)
Local cAlias  := GetNextAlias()
Local oQuery  := Nil
Local cQuery  := ""
Local aParams := {}

	cQuery += "SELECT O0W_COD,"
	cQuery +=       " O0W_CODWF"
	cQuery +=  " FROM " + RetSqlName("O0W") + " O0W"
	cQuery +=       " INNER JOIN " + RetSqlName("NSZ") + " NSZ"
	cQuery +=       " ON NSZ.NSZ_FILIAL = O0W.O0W_FILIAL"
	cQuery +=       " AND NSZ.NSZ_COD = O0W.O0W_CAJURI"
	cQuery +=       " AND NSZ.D_E_L_E_T_ = ' '"
	cQuery +=  "WHERE O0W.D_E_L_E_T_ = ' ' "
	cQuery +=    "AND O0W.O0W_FILIAL = ? "
	cQuery +=    "AND O0W.O0W_CAJURI = ? "
	cQuery +=    "AND O0W.O0W_CODWF = ? "

	Aadd(aParams,{ "C", cFilPro })
	Aadd(aParams,{ "C", cCajuri })
	Aadd(aParams,{ "C", cCodWF  })

	oQuery := FWPreparedStatement():New(cQuery)
	oQuery := JQueryPSPr(oQuery, aParams)
	cQuery := oQuery:GetFixQuery()
	MpSysOpenQuery(cQuery,cAlias)

	While (cAlias)->(!EoF())
		If !Empty((cAlias)->O0W_CODWF) .AND. aScan(aSuccessNTA,{|x| x == (cAlias)->O0W_COD}) == 0
			O0W->(DbSetOrder(1))  // O0W_FILIAL + O0W_COD
			If O0W->(DbSeek(cFilPro + (cAlias)->O0W_COD))
				O0W->(RecLock("O0W", .F.))  // Alteração
				O0W->O0W_CODWF := ""
				O0W->( MsUnLock() )
			EndIf
		EndIf
		(cAlias)->( dbSkip() )
	EndDo

	(cAlias)->( DbCloseArea() )
	aSize(aParams, 0)
	aParams   := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldConc
Aplica os valores aos pedidos, quando as alterações não passam pelo 
fluxo de aprovação do Fluig

@param  cResult     - Resultado do fup
@param  aCampos     - Lista de campos e valores submetidos a validações
@param  aSuccessNTA - Lista de pedidos submetidos a aprovação
@param  cFilialPro  - Filial do processo
@param  aErros      - Lista de erros
@param  cCodWF      - Código do Workflow
@return lRet        - Indica se gravou os pedidos corretamente
@since 05/08/2024
/*/
//-------------------------------------------------------------------
Function JVldConc( cResult, aCampos, aSuccessNTA, cFilialPro, aErros, cCodWF )
Local lRet        := .T.
Local nX          := 0
Local nPedido     := 0
Local nDataValor  := 0
Local nFCorre     := 0
Local nVpedido    := 0
Local nVProvavel  := 0
Local nVPossivel  := 0
Local nVRemoto    := 0
Local nVIncontro  := 0
Local nDtJuros    := 0
Local nRedutor    := 0
Local nProgno     := 0
Local cCodPedido  := ""
Local cNQNTipoF   := JurGetDados('NQN', 1, xFilial('NQN') + cResult,"NQN_TIPO")
Local aPedido     := {}
Local oMdl310     := Nil
Local oModelO0W   := Nil

	If (cNQNTipoF == "2")  // 2=Concluído
		oMdl310 := FWLoadModel("JURA310")
		oMdl310:SetOperation(4)  // Alteração

		For nX := 1 To len(aSuccessNTA)
			O0W->(DbSetOrder(1))  // O0W_FILIAL + O0W_COD
			If O0W->(DbSeek(cFilialPro + aSuccessNTA[nX]))
				oMdl310:Activate()
				oModelO0W := oMdl310:GetModel("O0WMASTER")
					nPedido := aScan(aCampos, {|x| x[2][2] == aSuccessNTA[nX]})
					If nPedido > 0
						aPedido := aClone(aCampos[nPedido])
						cCodPedido := aCampos[nPedido][2][2]
						nDataValor  := aScan( aPedido, {|x| x[1] == "O0W_DATPED"} )
						nFCorre     := aScan( aPedido, {|x| x[1] == "O0W_CFRCOR"} )
						nVpedido    := aScan( aPedido, {|x| x[1] == "O0W_VPEDID"} )
						nVProvavel  := aScan( aPedido, {|x| x[1] == "O0W_VPROVA"} )
						nVPossivel  := aScan( aPedido, {|x| x[1] == "O0W_VPOSSI"} )
						nVRemoto    := aScan( aPedido, {|x| x[1] == "O0W_VREMOT"} )
						nVIncontro  := aScan( aPedido, {|x| x[1] == "O0W_VINCON"} )
						nDtJuros    := aScan( aPedido, {|x| x[1] == "O0W_DTJURO"} )
						nRedutor    := aScan( aPedido, {|x| x[1] == "O0W_REDUT" } )
						nProgno     := aScan( aPedido, {|x| x[1] == "O0W_PROGNO"} )

						oModelO0W:SetValue(  "O0W__ALTPD", .T.                    )
						oModelO0W:SetValue(  "O0W_CODWF",  cCodWF                 )
						oModelO0W:SetValue(  "O0W_DATPED", aPedido[nDataValor][2] )
						oModelO0W:SetValue(  "O0W_CFRCOR", aPedido[nFCorre][2]    )
						oModelO0W:SetValue(  "O0W_VPEDID", aPedido[nVpedido][2]   )
						oModelO0W:SetValue(  "O0W_VPROVA", aPedido[nVProvavel][2] )
						oModelO0W:LoadValue( "O0W_VPOSSI", aPedido[nVPossivel][2] )
						oModelO0W:SetValue(  "O0W_VREMOT", aPedido[nVRemoto][2]   )
						oModelO0W:SetValue(  "O0W_VINCON", aPedido[nVIncontro][2] )
						oModelO0W:SetValue(  "O0W_DTJURO", aPedido[nDtJuros][2]   )
						oModelO0W:SetValue(  "O0W_REDUT ", aPedido[nRedutor][2]   )
						oModelO0W:SetValue(  "O0W_PROGNO", GetAvlCaso(oModelO0W:GetValue("O0W_VPROVA"),;
																		oModelO0W:GetValue("O0W_VPOSSI"),;
																		oModelO0W:GetValue("O0W_VREMOT"),;
																		oModelO0W:GetValue("O0W_VINCON")))

						If !(lRet := oMdl310:VldData() .AND. oMdl310:CommitData())
							aAdd(aErros, {cCodPedido, oModelO0W:GetModel("O0WMASTER"):GetErrorMessage()})
						EndIf
					EndIf
				oMdl310:DeActivate()
			EndIf
		Next nX

	Else
		// Preenche o código do workflow nos pedidos
		For nX := 1 To len(aSuccessNTA)
			O0W->(DbSetOrder(1))  // O0W_FILIAL + O0W_COD
			If O0W->(DbSeek(cFilialPro + aSuccessNTA[nX]))
				O0W->(RecLock("O0W", .F.))  // Alteração
				O0W->O0W_CODWF := cCodWF
				O0W->( MsUnLock() )
			EndIf
		Next nX
	EndIf

Return lRet
