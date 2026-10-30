#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#include "FWEVENTVIEWCONSTS.CH"
#include "FWMVCDef.ch"

/*/{PROTHEUS.DOC} LOCW064.PRW
ITUP BUSINESS - TOTVS RENTAL
API de solicitacao de retirada/devolucao de equipamentos. Atualiza os
registros da locacao (FPA) referentes a retirada e, opcionalmente, gera
o Romaneio de Devolucao (FQW/FQX), reaproveitando as regras do processo
padrao de devolucao do SIGALOC (LOCA104/LOCA104B).
@TYPE function
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
WSRESTFUL LOCW064 DESCRIPTION "API de Retirada/Devolucao de Equipamentos e geracao do Romaneio de Devolucao - RENTAL"

	WSMETHOD POST DESCRIPTION "<h2>Registra a solicitacao de retirada/devolucao de equipamentos e, opcionalmente, gera o Romaneio de Devolucao</h2>" WSSYNTAX "/LOCW064"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW064
ITUP BUSINESS - TOTVS RENTAL
Metodo que recebe o cabecalho (datas de retirada, flag de geracao de
romaneio e observacao) e os itens (AS, bem e quantidade devolvida),
valida as regras de negocio, atualiza a FPA e, quando solicitado,
gera o Romaneio de Devolucao.
@TYPE WSMETHOD
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
WSMETHOD POST WSSERVICE LOCW064

	Local cBody      := DecodeUtf8(::GetContent())
	Local oJson      := Nil
	Local bError     := {||}
	Local cEnvLog    := ""
	Local cEventID   := "103" // ID do EventViewer (Tabela E3/SX5) - deve ser cadastrado pelo administrador
	Local aSx5       := {}
	Local lSucesso   := .T.
	Local cMensagem  := ""
	Local lGerado    := .F.
	Local cNumRom    := ""
	Local cErro      := ""
	Local aItensVal  := {}

	::SetContentType("application/json; charset=iso-8859-1")

	aSx5 := FWGetSX5("E3", cEventID)

	bError := ErrorBlock({|oError| xTrataError(oError, @cEnvLog)})

	Begin Sequence

		If !FWJsonDeserialize(cBody, @oJson)
			lSucesso  := .F.
			cMensagem := "JSON informado e invalido."
		Else

			cErro := LOCW064VH(oJson)

			If !Empty(cErro)
				lSucesso  := .F.
				cMensagem := cErro
			Else

				aItensVal := LOCW064VI(oJson, @cErro)

				If !Empty(cErro)
					lSucesso  := .F.
					cMensagem := cErro
				Else

					cErro := LOCW064PR(oJson, aItensVal, cEventID, aSx5, @cNumRom, @lGerado)

					If !Empty(cErro)
						lSucesso  := .F.
						cMensagem := cErro
					Else
						cMensagem := "Processamento realizado com sucesso."
					EndIf

				EndIf

			EndIf

		EndIf

	End Sequence

	ErrorBlock(bError)

	//If !Empty(cEnvLog)
	//	lSucesso  := .F.
	//	cMensagem := "Erro inesperado ao processar a requisicao: "+cEnvLog
	//EndIf

	//If !lSucesso .and. Empty(cMensagem)
	//	cMensagem := "Erro inesperado ao processar a requisicao."
	//EndIf

	//LOCW064Log(cEventID, aSx5, If(lSucesso, "INFO", "ERRO"), "LOCW064 - Fim do processamento",;
	//	If(lSucesso, "Sucesso. Romaneio gerado: "+If(lGerado, cNumRom, "Nao"), "Falha: "+cMensagem))

	::SetResponse(Alltrim(FWhttpEncode('{"sucesso":'+If(lSucesso,"true","false")+;
		',"mensagem":"'+LOCW064Esc(cMensagem)+'"'+;
		',"romaneio":{"gerado":'+If(lGerado,"true","false")+',"numero":"'+LOCW064Esc(cNumRom)+'"}}')))

Return .T.

/*/{PROTHEUS.DOC} LOCW064VH
ITUP BUSINESS - TOTVS RENTAL
Valida o cabecalho da requisicao (Gera Romaneio obrigatorio e pelo menos
uma das datas de retirada/previsao informada)
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064VH(oJson)
Local cErro := ""
Local cGrRom := Upper(AllTrim(If(ValType(oJson:geraRomaneio) == "C", oJson:geraRomaneio, "")))

	If Empty(cGrRom)
		cErro := "O campo 'geraRomaneio' e obrigatorio e deve ser informado como 'S' ou 'N'."
	ElseIf !(cGrRom $ "S#N")
		cErro := "O campo 'geraRomaneio' deve ser informado como 'S' ou 'N'."
	ElseIf Empty(LOCW064Str(oJson:dataPrevisaoRetirada)) .Or. Empty(LOCW064Str(oJson:dataSolicitacaoRetirada))
		cErro := "E obrigatorio informar a Data de Previsao de Retirada ou a Data de Solicitacao de Retirada."
	ElseIf ValType(oJson:itens) <> "A" .or. Len(oJson:itens) == 0
		cErro := "A lista de itens e obrigatoria e deve conter ao menos um item."
	EndIf

Return cErro

/*/{PROTHEUS.DOC} LOCW064VI
ITUP BUSINESS - TOTVS RENTAL
Valida estruturalmente e no banco de dados cada item informado (AS, bem
e quantidade devolvida), incluindo a regra de acessorio (BM_XACESS = 3
exige Gera Romaneio = S). Retorna o array de itens resolvidos ou, via
parametro de saida cErro, a primeira inconsistencia encontrada.
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064VI(oJson, cErro)
Local aRet     := {}
Local aItem    := {}
Local nX       := 0
Local cGrRom   := Upper(AllTrim(oJson:geraRomaneio))
Local cAs      := ""
Local cAs_Fre  := ""
Local cBem     := ""
Local nQtd     := 0
Local oItem    := Nil

	cErro := ""

	For nX := 1 To Len(oJson:itens) 

		oItem := oJson:itens[nX]
		//cAs   := Upper(AllTrim(LOCW064Str(oItem:as)))
		cAs     := oItem:as_projeto
		cAs_Fre := LOCW064Str(oItem:as_frete)
		cBem    := Upper(AllTrim(LOCW064Str(oItem:bem)))
		nQtd    := LOCW064Num(oItem:quantidadeDevolvida)

		If cGrRom == "S"
			If Empty(cAs_Fre)
				cErro := "Item "+AllTrim(Str(nX))+": o campo 'as_frete' e obrigatorio quando o campo 'geraRomaneio' for igual a 'S'."
				Exit
			EndIf
		Else
			cAs_Fre := "" // geraRomaneio = 'N': 'as_frete' nunca deve ser considerado/gravado
		EndIf

		If Empty(cAs) .or. Empty(cBem) .or. nQtd <= 0
			cErro := "Item "+AllTrim(Str(nX))+": os campos 'as', 'bem' e 'quantidadeDevolvida' (maior que zero) sao obrigatorios."
			Exit
		EndIf

		If !LOCW064ExisteAS(cAs)
			cErro := "Item "+AllTrim(Str(nX))+": AS '"+cAs+"' nao encontrada."
			Exit
		EndIf

		aItem := LOCW064BuscaBem(cAs, cBem)

		If Len(aItem) == 0
			cErro := "Item "+AllTrim(Str(nX))+": bem '"+cBem+"' nao encontrado para a AS '"+cAs+"' (verifique se ha remessa emitida e retorno pendente)."
			Exit
		EndIf

		If nQtd > aItem[5] // FPA_QUANT
			cErro := "Item "+AllTrim(Str(nX))+": quantidade devolvida ("+AllTrim(Str(nQtd))+") maior que a quantidade disponivel ("+AllTrim(Str(aItem[5]))+") para o bem '"+cBem+"' da AS '"+cAs+"'."
			Exit
		EndIf

		If aItem[9] .and. cGrRom <> "S" // Grupo do produto com BM_XACESS = 3 (acessorio)
			cErro := "Item "+AllTrim(Str(nX))+": o bem '"+cBem+"' pertence a um grupo de acessorio (BM_XACESS = 3) e exige 'geraRomaneio' = 'S'."
			Exit
		EndIf

		Aadd(aRet, {aItem[1], aItem[2], cAs_Fre, cBem, aItem[3], aItem[4], nQtd, aItem[6], aItem[7], aItem[8]})
		// aRet[n] := { nRecnoFPA, cFilialFPA, cAS, cBem(FPA_GRUA), cProjeto, cObra, nQtdDevolvida, cFilRem, cProduto, cUnidMedida }

	Next nX

Return aRet

/*/{PROTHEUS.DOC} LOCW064ExisteAS
ITUP BUSINESS - TOTVS RENTAL
Verifica a existencia da A.S. informada na tabela FQ5 (cabecalho da A.S.)
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064ExisteAS(cAs)
Local lRet       := .F.
Local cQuery     := ""
Local aBind      := {}
Local cAliasT    := GetNextAlias()

	cQuery := "SELECT FQ5_AS FROM "+RetSqlName("FQ5")+" FQ5 "
	cQuery += " WHERE FQ5_FILIAL = ? AND FQ5_AS = ? AND FQ5.D_E_L_E_T_ = ' ' "
	Aadd(aBind, xFilial("FQ5"))
	Aadd(aBind, cAs)

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAliasT, , , aBind)

	lRet := !(cAliasT)->(Eof())

	(cAliasT)->(dbCloseArea())

Return lRet

/*/{PROTHEUS.DOC} LOCW064BuscaBem
ITUP BUSINESS - TOTVS RENTAL
Localiza o item da A.S. (FPA) pelo bem informado (FPA_GRUA), somente
entre os itens com remessa emitida e ainda nao devolvidos, trazendo
tambem se o grupo do produto e classificado como acessorio (BM_XACESS=3)
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064BuscaBem(cAs, cBem)
Local aRet       := {}
Local cQuery     := ""
Local aBind      := {}
Local cAliasT    := GetNextAlias()

	cQuery := "SELECT FPA.R_E_C_N_O_ AS FPARECNO, FPA.FPA_FILIAL, FPA.FPA_PROJET, FPA.FPA_OBRA, FPA.FPA_QUANT, "
	cQuery += " FPA.FPA_FILREM, FPA.FPA_PRODUT, SB1.B1_UM, SBM.BM_XACESS "
	cQuery += " FROM "+RetSqlName("FPA")+" FPA "
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = FPA.FPA_PRODUT AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+RetSqlName("SBM")+" SBM ON SBM.BM_FILIAL = '"+xFilial("SBM")+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE FPA.FPA_FILIAL = ? AND FPA.FPA_AS = ? AND FPA.FPA_GRUA = ? "
	cQuery += " AND FPA.FPA_NFRET = ' ' AND FPA.FPA_NFREM <> ' ' "
	cQuery += " AND FPA.D_E_L_E_T_ = ' ' "
	Aadd(aBind, xFilial("FPA"))
	Aadd(aBind, cAs)
	Aadd(aBind, cBem)

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAliasT, , , aBind)

	If !(cAliasT)->(Eof())
		aRet := { (cAliasT)->FPARECNO, (cAliasT)->FPA_FILIAL, (cAliasT)->FPA_PROJET, (cAliasT)->FPA_OBRA,;
			(cAliasT)->FPA_QUANT, (cAliasT)->FPA_FILREM, (cAliasT)->FPA_PRODUT, (cAliasT)->B1_UM,;
			AllTrim(LOCW064Str((cAliasT)->BM_XACESS)) == "3" }
	EndIf

	(cAliasT)->(dbCloseArea())

Return aRet

/*/{PROTHEUS.DOC} LOCW064PR
ITUP BUSINESS - TOTVS RENTAL
Processa a atualizacao dos registros da FPA (retirada/observacao) e,
quando Gera Romaneio = S, gera (ou reaproveita) o Romaneio de Devolucao
e inclui os itens devolvidos, reaproveitando as regras do LOCA104B.
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064PR(oJson, aItensVal, cEventID, aSx5, cNumRom, lGerado)
Local cErro       := ""
Local cGrRom      := Upper(AllTrim(oJson:geraRomaneio))
Local dDtPrevisao := LOCW064Data(LOCW064Str(oJson:dataPrevisaoRetirada))
Local dDtSolicit  := LOCW064Data(LOCW064Str(oJson:dataSolicitacaoRetirada))
Local cObservacao := oJson:observacao
Local nX          := 0
Local cProjeto    := aItensVal[1][5]
Local cObra       := aItensVal[1][6]
Local cItemFQX    := ""
Local aAreaFPA    := {}
Local lOkFQW      := .T.
Local cAs_Frete   := aItensVal[1][3]

	lGerado := .F.
	cNumRom := ""

	If cGrRom == "S"
		For nX := 2 To Len(aItensVal)
			If aItensVal[nX][5] <> cProjeto .or. aItensVal[nX][6] <> cObra
				Return "Todos os itens da requisicao devem pertencer ao mesmo Projeto/Obra para a geracao de um unico Romaneio de Devolucao."
			EndIf
		Next nX
	EndIf

	BEGIN TRANSACTION

		// --> Atualiza os registros da FPA relacionados a retirada
		aAreaFPA := FPA->(GetArea())
		For nX := 1 To Len(aItensVal)

			FPA->(dbGoTo(aItensVal[nX][1]))
			RecLock("FPA", .F.)
				If !Empty(dDtSolicit)
					FPA->FPA_DTSCRT := dDtSolicit
				EndIf
				If !Empty(cObservacao)
					FPA->FPA_OBSOBR := LOCW064ConcatObs(FPA->FPA_OBSOBR, cObservacao, TamSx3("FPA_OBSOBR")[1])
				EndIf
			FPA->(MsUnlock())

		Next nX
		RestArea(aAreaFPA)

		// --> Gera o Romaneio de Devolucao (FQW/FQX) quando solicitado
		If cGrRom == "S"

			cNumRom := LOCW064AchaFQW(cProjeto, cObra)

			If Empty(cNumRom)

				// --> Cabecalho do Romaneio (FQW) gravado via rotina automatica MVC (modelo LOCA104A), nunca por RecLock
				cNumRom := LOCW064CriaFQW(cProjeto, cObra, @cErro,cAs_Frete)

				If Empty(cNumRom)
					lOkFQW := .F.
					DisarmTransaction()
					LOCW064Log(cEventID, aSx5, "ERRO", "LOCW064 - Falha ao gerar o Romaneio de Devolucao", "Projeto/Obra: "+cProjeto+"/"+cObra+" - "+cErro)
				Else
					LOCW064Log(cEventID, aSx5, "INFO", "LOCW064 - Romaneio de Devolucao criado", "Romaneio: "+cNumRom+" Projeto/Obra: "+cProjeto+"/"+cObra)
				EndIf

			Else
				LOCW064Log(cEventID, aSx5, "INFO", "LOCW064 - Romaneio de Devolucao reaproveitado", "Romaneio: "+cNumRom+" Projeto/Obra: "+cProjeto+"/"+cObra)
			EndIf

			If lOkFQW

				cItemFQX := LOCW064ProxItemFQX(cNumRom)

				For nX := 1 To Len(aItensVal)

					cItemFQX := Soma1(cItemFQX)

					RecLock("FQX", .T.)
						FQX->FQX_FILIAL := xFilial("FQX")
						FQX->FQX_NUM    := cNumRom
						FQX->FQX_ITEM   := cItemFQX
						FQX->FQX_PROD   := aItensVal[nX][9]
						FQX->FQX_UNID   := aItensVal[nX][10]
						FQX->FQX_QTD    := aItensVal[nX][7]
						FQX->FQX_UNID2  := GetAdvFVal("SB1", "B1_SEGUM", xFilial("SB1")+aItensVal[nX][9], 1, "")
						FQX->FQX_QTD2   := ConvUm(aItensVal[nX][9], aItensVal[nX][7], 0, 2)
						FQX->FQX_CODBEM := aItensVal[nX][4]
						FQX->FQX_AS     := aItensVal[nX][3]
						FQX->FQX_CONTRA := cProjeto
						FQX->FQX_OBRA   := cObra
						FQX->FQX_STATUS := "2" // Primeira Contagem, conforme LOCA104BOk
					FQX->(MsUnlock())

				Next nX

				// --> Atualizacao do cabecalho do Romaneio (FQW) tambem via rotina automatica MVC, nunca por RecLock
				cErro := LOCW064AtuFQW(cNumRom, aItensVal[1][8])

				If !Empty(cErro)
					lOkFQW := .F.
					DisarmTransaction()
					LOCW064Log(cEventID, aSx5, "ERRO", "LOCW064 - Falha ao atualizar o Romaneio de Devolucao", "Romaneio: "+cNumRom+" - "+cErro)
				Else
					LOCW064Log(cEventID, aSx5, "INFO", "LOCW064 - Itens incluidos no Romaneio", "Romaneio: "+cNumRom+" Itens incluidos: "+AllTrim(Str(Len(aItensVal))))
					lGerado := .T.
				EndIf

			EndIf

		EndIf

	END TRANSACTION

Return cErro

/*/{PROTHEUS.DOC} LOCW064AchaFQW
ITUP BUSINESS - TOTVS RENTAL
Localiza um Romaneio de Devolucao (FQW) ainda em aberto (status
diferente de Encerrado/Faturado) para o Projeto/Obra informado
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064AchaFQW(cProjeto, cObra)
Local cRet       := ""
Local cQuery     := ""
Local aBind      := {}
Local cAliasT    := GetNextAlias()

	cQuery := "SELECT FQW_NUM FROM "+RetSqlName("FQW")+" FQW "
	cQuery += " WHERE FQW_FILIAL = ? AND FQW_PROJET = ? AND FQW_OBRA = ? "
	cQuery += " AND FQW_STATUS NOT IN ('5','6') "
	cQuery += " AND FQW.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY FQW_NUM DESC "
	Aadd(aBind, xFilial("FQW"))
	Aadd(aBind, cProjeto)
	Aadd(aBind, cObra)

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAliasT, , , aBind)

	If !(cAliasT)->(Eof())
		cRet := (cAliasT)->FQW_NUM
	EndIf

	(cAliasT)->(dbCloseArea())

Return cRet

/*/{PROTHEUS.DOC} LOCW064CriaFQW
ITUP BUSINESS - TOTVS RENTAL
Cria um novo cabecalho de Romaneio de Devolucao (FQW) atraves da rotina
automatica MVC do modelo padrao LOCA104A (submodelo FQWMASTER), nunca
por RecLock direto, preenchendo os dados minimos necessarios
(cliente/endereco de devolucao) com base no contrato (FP0) e no cliente
(SA1), conforme os defaults aplicados pela tela padrao LOCA104A
(funcoes LOCA104TGA/LOCA104TGB). Em caso de falha de validacao/commit
do modelo, retorna vazio e preenche cErro (parametro de saida).
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064CriaFQW(cProjeto, cObra, cErro,cAs_Frete)
Local cNumRom   := ""
Local oModel    := Nil
Local oModelFQW := Nil
Local lRet      := .F.
Local aAreaFP0  := FP0->(GetArea())
Local aAreaSA1  := SA1->(GetArea())

	cErro := ""

	oModel    := FWLoadModel("LOCA104A")
	oModelFQW := oModel:GetModel("FQWMASTER")
	oModel:SetOperation(MODEL_OPERATION_INSERT)

	If oModel:Activate()
		If oModel:GetModel("FQWMASTER") != Nil

			oModelFQW:SetValue("FQW_PROJET", cProjeto)
			oModelFQW:SetValue("FQW_OBRA"  , cObra)
			oModelFQW:SetValue("FQW_ASF"  , cAs_Frete)
			oModelFQW:SetValue("FQW_STATUS", "1") // Agendado (Vazio)

			FP0->(dbSetOrder(1))
			If FP0->(dbSeek(xFilial("FP0")+cProjeto))
				oModelFQW:SetValue("FQW_CLIENT", FP0->FP0_CLI)
				oModelFQW:SetValue("FQW_LOJA"  , FP0->FP0_LOJA)
				oModelFQW:SetValue("FQW_NOMCLI", FP0->FP0_CLINOM)
			EndIf

			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+oModelFQW:GetValue("FQW_CLIENT")+oModelFQW:GetValue("FQW_LOJA")))
				oModelFQW:SetValue("FQW_CLIDEV", SA1->A1_COD)
				oModelFQW:SetValue("FQW_LOJDEV", SA1->A1_LOJA)
				oModelFQW:SetValue("FQW_NOMDEV", SA1->A1_NOME)
				oModelFQW:SetValue("FQW_ENDDEV", SA1->A1_END)
				oModelFQW:SetValue("FQW_BAIDEV", SA1->A1_BAIRRO)
				oModelFQW:SetValue("FQW_MUNDEV", SubStr(SA1->A1_MUN, 1, TamSx3("FQW_MUNDEV")[1]))
				oModelFQW:SetValue("FQW_ESTDEV", SA1->A1_EST)
				oModelFQW:SetValue("FQW_CEPDEV", SA1->A1_CEP)
			EndIf

			If oModel:VldData()
				lRet := oModel:CommitData()
				If lRet
					cNumRom := oModelFQW:GetValue("FQW_NUM")
				EndIf
			Else
				lRet := .F.
			EndIf

		EndIf
	EndIf

	If !lRet
		cErro := LOCW064ErroModelo(oModel, "Nao foi possivel gerar o Romaneio de Devolucao para o Projeto/Obra '"+cProjeto+"/"+cObra+"'.")
	EndIf

	oModel:DeActivate()

	RestArea(aAreaSA1)
	RestArea(aAreaFP0)

Return cNumRom

/*/{PROTHEUS.DOC} LOCW064AtuFQW
ITUP BUSINESS - TOTVS RENTAL
Atualiza o cabecalho do Romaneio de Devolucao (FQW) apos a inclusao dos
itens na FQX (status para Primeira Contagem e filial de remessa),
tambem atraves da rotina automatica MVC do modelo padrao LOCA104A
(submodelo FQWMASTER), nunca por RecLock direto. Retorna vazio em caso
de sucesso ou a mensagem de erro em caso de falha.
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064AtuFQW(cNumRom, cFilRem)
Local cErro     := ""
Local oModel    := Nil
Local oModelFQW := Nil
Local lRet      := .F.

	FQW->(dbSetOrder(1))
	If FQW->(dbSeek(xFilial("FQW")+cNumRom))

		oModel    := FWLoadModel("LOCA104A")
		oModelFQW := oModel:GetModel("FQWMASTER")
		oModel:SetOperation(MODEL_OPERATION_UPDATE)

		If oModel:Activate()
			If oModel:GetModel("FQWMASTER") != Nil

				oModelFQW:SetValue("FQW_STATUS", "2") // Primeira contagem realizada
				If Empty(oModelFQW:GetValue("FQW_FILREM"))
					oModelFQW:SetValue("FQW_FILREM", cFilRem)
				EndIf

				If oModel:VldData()
					lRet := oModel:CommitData()
				Else
					lRet := .F.
				EndIf

			EndIf
		EndIf

		If !lRet
			cErro := LOCW064ErroModelo(oModel, "Nao foi possivel atualizar o Romaneio de Devolucao '"+cNumRom+"'.")
		EndIf

		oModel:DeActivate()

	Else
		cErro := "Romaneio de Devolucao '"+cNumRom+"' nao encontrado para atualizacao."
	EndIf

Return cErro

/*/{PROTHEUS.DOC} LOCW064ErroModelo
ITUP BUSINESS - TOTVS RENTAL
Extrai a mensagem de erro de um modelo MVC (rotina automatica) apos
falha de VldData/CommitData, retornando uma mensagem padrao quando o
modelo nao possuir uma mensagem de erro especifica
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064ErroModelo(oModel, cPadrao)
Local cRet  := cPadrao
Local aErro := {}

	If oModel != Nil
		aErro := oModel:GetErrorMessage()
		If Len(aErro) >= 6 .and. !Empty(AllTrim(LOCW064Str(aErro[6])))
			cRet := AllTrim(aErro[6])
		EndIf
	EndIf

Return cRet

/*/{PROTHEUS.DOC} LOCW064ProxItemFQX
ITUP BUSINESS - TOTVS RENTAL
Retorna o proximo codigo de item a ser utilizado na FQX para o romaneio
informado (mesma logica de LOCA104BMX)
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064ProxItemFQX(cNumRom)
Local cMax       := ""
Local cQuery     := ""
Local aBind      := {}
Local cAliasT    := GetNextAlias()

	cQuery := "SELECT Max(FQX_ITEM) ITEM FROM "+RetSqlName("FQX")+" FQX "
	cQuery += " WHERE FQX_FILIAL = ? AND FQX_NUM = ? AND FQX.D_E_L_E_T_ = ' ' "
	Aadd(aBind, xFilial("FQX"))
	Aadd(aBind, cNumRom)

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAliasT, , , aBind)

	cMax := (cAliasT)->ITEM

	(cAliasT)->(dbCloseArea())

	If Empty(cMax)
		cMax := Space(TamSx3("FQX_ITEM")[1])
	EndIf

Return cMax

/*/{PROTHEUS.DOC} LOCW064Log
ITUP BUSINESS - TOTVS RENTAL
Registra uma etapa do processamento da API no EventViewer, seguindo o
mesmo padrao ja adotado nas demais APIs do modulo Rental (EventInsert
condicionado ao evento estar cadastrado na SX5/tabela E3)
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064Log(cEventID, aSx5, cNivel, cTitulo, cDetalhe)

	// Mantido sempre como FW_EV_LEVEL_INFO, mesmo padrao ja usado nas demais
	// APIs deste modulo (LOCW014/LOCW017/LOCW041/...); o nivel textual (INFO/ERRO)
	// e identificado pelo proprio titulo/detalhe da mensagem gravada.
	If Len(aSx5) > 0
		EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID, FW_EV_LEVEL_INFO, "", cNivel+" - "+cTitulo, cDetalhe, .T.)
	EndIf

Return

/*/{PROTHEUS.DOC} LOCW064Data
ITUP BUSINESS - TOTVS RENTAL
Converte uma data no formato ISO (YYYY-MM-DD) para o tipo Data
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064Data(cIso)
Local dRet := CTOD("")

	If !Empty(cIso) .and. Len(StrTran(cIso, "-", "")) == 8
		dRet := STOD(StrTran(cIso, "-", ""))
	EndIf

Return dRet

/*/{PROTHEUS.DOC} LOCW064Str
ITUP BUSINESS - TOTVS RENTAL
Retorna o conteudo como character, tratando valores nao informados
(Nil) vindos do JSON
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064Str(uValor)
Local cRet := ""

	If ValType(uValor) == "C"
		cRet := uValor
	EndIf

Return cRet

/*/{PROTHEUS.DOC} LOCW064Num
ITUP BUSINESS - TOTVS RENTAL
Retorna o conteudo como numerico, tratando valores nao informados
(Nil) ou enviados como texto vindos do JSON
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064Num(uValor)
Local nRet := 0

	If ValType(uValor) == "N"
		nRet := uValor
	ElseIf ValType(uValor) == "C"
		nRet := Val(uValor)
	EndIf

Return nRet

/*/{PROTHEUS.DOC} LOCW064ConcatObs
ITUP BUSINESS - TOTVS RENTAL
Concatena o valor atual de um campo de observacao com o novo texto
recebido pela API, sem sobrepor o conteudo ja existente, truncando o
resultado no tamanho do campo quando necessario
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064ConcatObs(cAtual, cNovo, nTam)
Local cRet := AllTrim(LOCW064Str(cAtual))

	If Empty(cRet)
		cRet := AllTrim(cNovo)
	Else
		cRet := cRet + " | " + AllTrim(cNovo)
	EndIf

	If nTam > 0 .and. Len(cRet) > nTam
		cRet := Left(cRet, nTam)
	EndIf

Return cRet

/*/{PROTHEUS.DOC} LOCW064Esc
ITUP BUSINESS - TOTVS RENTAL
Escapa uma string para uso seguro dentro de um valor JSON
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/07/2026
/*/
Static Function LOCW064Esc(cTxt)
Local cRet := AllTrim(LOCW064Str(cTxt))

	cRet := StrTran(cRet, '\', '\\')
	cRet := StrTran(cRet, '"', '\"')
	cRet := StrTran(cRet, Chr(13)+Chr(10), " ")
	cRet := StrTran(cRet, Chr(10), " ")
	cRet := StrTran(cRet, Chr(13), " ")

Return cRet
