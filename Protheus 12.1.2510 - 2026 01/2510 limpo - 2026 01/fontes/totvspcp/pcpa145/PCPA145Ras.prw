#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145.CH"
#INCLUDE "PCPA145DEF.ch"

Static _oQrySD4 := Nil
Static _oQtdSD4 := Nil
Static _oQrySVR := Nil
Static _oDocDem := Nil

/*/{Protheus.doc} P145GrvRas
Grava a tabela SMH com o rastreio das demandas
@type Function
@author marcelo.neumann
@since 02/12/2020
@version P12.1.31
@param cTicket  , Character, Ticket de processamento do MRP para geração dos documentos
@param cCodUsr  , Character, Código do usuário logado no sistema.
@return lOk, Lógico, Indica se gravou com sucesso o rastreio
/*/
Function P145GrvRas(cTicket, cCodUsr)
	Local aDocGerado := {}
	Local aIncluir   := {}
	Local aRegs      := {}
	Local cChave     := ""
	Local cDemanda   := ""
	Local cDocDeman  := ""
	Local cDocGerado := ""
	Local cDocPai    := ""
	Local cFilDeman  := ""
	Local cIdDemAnt  := ""
	Local cIdReg     := ""
	Local cIdPaiPad  := ""
	Local cProduto   := ""
	Local cTipDocGer := ""
	Local cTipDocPai := ""
	Local cTxtES     := ""
	Local cTxtPPed   := ""
	Local cTRT       := ""
	Local lOk        := .T.
	Local lEmpenho   := .F.
	Local lEstSeg    := .F.
	Local lPontPed   := .F.
	Local lEstNeg    := .F.
	Local lFieldsLt  := .F.
	Local lPreDoc    := .F.
	Local lPaiPre    := .F.
	Local lRastPai   := .F.
	Local lTemIDPai  := .F.
	Local lFilDest   := .F.
	Local nDecSMH    := 0
	Local nInd       := 0
	Local nSeqDeman  := 0
	Local nQtdRegs   := 0
	Local nQtdOPPai  := 0
	Local nQtdEmp    := 0
	Local nQuant     := 0
	Local nQtdNec    := 0
	Local nUsoPai    := 0
	Local nTamDemDoc := 0
	Local nTamNmEnt  := 0
	Local nTamNmSai  := 0
	Local nTamProd   := 0
	Local nTamTpEnt  := 0
	Local nTamTpSai  := 0
	Local nTamTRT    := 0
	Local nTamIDReg  := 0
	Local oExcluir   := Nil
	Local oIncluidos := Nil
	Local oJson      := Nil
	Local oJsEstSeg  := Nil
	Local oJsPPed    := Nil
	Local oRastPai   := Nil
	Local oProcesso  := Nil
	Local oIdsPai    := Nil

	oProcesso := ProcessaDocumentos():New(cTicket, .T., /*03*/, cCodUsr)
	cTxtES    := MrpDGetSTR("ES")
	cTxtPPed  := MrpDGetSTR("PP")

	oProcesso:msgLog("Iniciando processo de geracao da Rastreabilidade. [" + Time() + "]", "6")
	aRegs := MrpGetRasD(oProcesso:cTicket)
	If aRegs[1]
		nTamNmEnt  := GetSX3Cache("MH_NMDCENT", "X3_TAMANHO")
		nTamNmSai  := GetSX3Cache("MH_NMDCSAI", "X3_TAMANHO")
		nTamProd   := GetSX3Cache("MH_PRODUTO", "X3_TAMANHO")
		nTamTpEnt  := GetSX3Cache("MH_TPDCENT", "X3_TAMANHO")
		nTamTpSai  := GetSX3Cache("MH_TPDCSAI", "X3_TAMANHO")
		nTamTRT    := GetSX3Cache("MH_TRT"    , "X3_TAMANHO")
		nTamIDReg  := GetSX3Cache("MH_IDREG"  , "X3_TAMANHO")
		nDecSMH    := GetSX3Cache("MH_QUANT"  , "X3_DECIMAL")
		nTamDemDoc := GetSX3Cache("MH_DEMDOC" , "X3_TAMANHO")

		_oDocDem   := JsonObject():New()
		_oQtdSD4   := JsonObject():New()
		oExcluir   := JsonObject():New()
		oIncluidos := JsonObject():New()
		oRastPai   := JsonObject():New()
		oJsEstSeg  := JsonObject():New()
		oJsPPed    := JsonObject():New()
		oJson      := aRegs[2]
		nQtdRegs   := Len(oJson["items"])

		oProcesso:msgLog("Dados da rastreabilidade obtidos. Total de registros a processar: " + cValToChar(nQtdRegs) + ". [" + Time() + "]", "6")

		//Seta o total de registros que serão processados
		//Total é +2 para contar no progresso a exclusão e inclusão de registros, que é feita no final do processo

		/*
			Total é multiplicado por 2 e somado 1 pq:
				1x irá percorrer o array para montar os dados para inclusão na SMH (percorre nQtdRegs)
				mais uma vez irá percorrer o array aIncluir para incluir os dados com o FWBULK.
				soma 1 devido ao processo de exclusão da SMH, efetuado antes de incluir os dados com o FWBULK.
		*/
		oProcesso:initCount("RASTREABILIDADE_TOTAL", (nQtdRegs * 2) + 1)

		DbSelectArea("SMH")
		If SMH->(FieldPos("MH_IDPAI")) > 0
			cIdPaiPad := Space(GetSX3Cache("MH_IDPAI", "X3_TAMANHO"))
			lTemIDPai := .T.
			oIdsPai   := JsonObject():New()
		EndIf

		lFieldsLt := FieldPos("MH_LOTE") > 0 .And. FieldPos("MH_SLOTE") > 0
		lFilDest  := FieldPos("MH_FILDES") > 0

		For nInd := 1 To nQtdRegs
			lRastPai   := .F.
			cTipDocPai := RTrim(oJson["items"][nInd]["parentDocumentType"])
			lEstSeg    := SubStr(oJson["items"][nInd]["demandId"], 1, Len(cTxtES)  ) == cTxtES
			lPontPed   := SubStr(oJson["items"][nInd]["demandId"], 1, Len(cTxtPPed)) == cTxtPPed

			cChave := RTrim(oJson["items"][nInd]["document"])
			If lEstSeg .And. cChave <> "SaldoInicial"
				oJsEstSeg[cChave] := JsonObject():New()
				oJsEstSeg[cChave]["parentDocument"] := RTrim(oJson["items"][nInd]["parentDocument"])
				oJsEstSeg[cChave]["product"       ] := RTrim(oJson["items"][nInd]["product"])
			EndIf

			If lPontPed .And. cChave <> "SaldoInicial"
				oJsPPed[cChave] := JsonObject():New()
				oJsPPed[cChave]["parentDocument"] := RTrim(oJson["items"][nInd]["parentDocument"])
				oJsPPed[cChave]["product"       ] := RTrim(oJson["items"][nInd]["product"])
			EndIf

			If nInd == 1 .Or. cIdDemAnt <> oJson["items"][nInd]["demandId"]

				lEstNeg  := SubStr(oJson["items"][nInd]["demandId"], 1, 6) == "ESTNEG"
				lEmpenho := cTipDocPai == "Pré-OP"                             .And.;
				            !preExist(RTrim(oJson["items"][nInd]["document"])) .And.;
				             preExist(RTrim(oJson["items"][nInd]["demandId"])) .And.;
				            RTrim(oJson["items"][nInd]["document"]) != "SaldoInicial"

				If lEstSeg .Or. lEstNeg .Or. lPontPed .Or. lEmpenho
					cDemanda  := ""
					nSeqDeman := 0
					cIdDemAnt := ""
					If lEstSeg
						cDocDeman := cTxtES + " " + getPrdOrg(oJsEstSeg, RTrim(oJson["items"][nInd]["parentDocument"]))
					ElseIf lEstNeg
						cDocDeman := "ESTNEG"
					ElseIf lPontPed
						cDocDeman := cTxtPPed + " " + getPrdOrg(oJsPPed, RTrim(oJson["items"][nInd]["parentDocument"]))
					ElseIf lEmpenho
						cDocDeman := ""
					EndIf
				Else
					cFilDeman := P136GetInf(oJson["items"][nInd]["demandId"], "VR_FILIAL")
					cDemanda  := P136GetInf(oJson["items"][nInd]["demandId"], "VR_CODIGO")
					nSeqDeman := P136GetInf(oJson["items"][nInd]["demandId"], "VR_SEQUEN")

					cDocDeman := getDocDem(cFilDeman, cDemanda, nSeqDeman, oJson["items"][nInd]["demandId"])
					cIdDemAnt := oJson["items"][nInd]["demandId"]
				EndIf
				cDocDeman := PadR(cDocDeman, nTamDemDoc)
			EndIf

			//Busca o De-Para dos documentos (MRP -> ERP)
			//Documento Pai:
			cDocPai    := RTrim(oJson["items"][nInd]["parentDocument"])
			If preExist(@cDocPai)
				lPaiPre := .T.
				addExcluir(@oExcluir, "S", cTipDocPai, cDocPai, oJson["items"][nInd]["branchId"])
			Else
				lPaiPre := .F.
				cProduto := RTrim(oJson["items"][nInd]["parentProduct"])
				cTRT     := RTrim(oJson["items"][nInd]["parentSequence"])
				cChave   := cDocPai + "_" + cProduto + "_" + cTRT
				VarGetAD(oProcesso:cUIDRasEntr, cChave, @aDocGerado)

				If Empty(aDocGerado) .And. oProcesso:getGeraDocAglutinado(oJson["items"][nInd]["productLevel"], .T.)
					cChave   := cDocPai + "_" + cProduto + "_"
					VarGetAD(oProcesso:cUIDRasEntr, cChave, @aDocGerado)
				EndIf

				If !Empty(aDocGerado)
					cDocPai := aDocGerado[2]
					aSize(aDocGerado, 0)
				EndIf
			EndIf

			//Documento Gerado:
			cDocGerado := RTrim(oJson["items"][nInd]["document"])
			cTipDocGer := RTrim(oJson["items"][nInd]["documentType"])
			cProduto   := RTrim(oJson["items"][nInd]["product"])
			cTRT       := RTrim(oJson["items"][nInd]["sequenceInStructure"])

			lRastPai := oRastPai:HasProperty(RTrim(oJson["items"][nInd]["parentDocument"])+";"+oJson["items"][nInd]["demandId"])

			If preExist(@cDocGerado)
				lPreDoc  := .T.
				addExcluir(@oExcluir, "E", cTipDocGer, cDocGerado, oJson["items"][nInd]["branchId"])
			Else
				lPreDoc := .F.
				cChave := cDocGerado + "_" + cProduto + "_"

				If !oProcesso:getGeraDocAglutinado(oJson["items"][nInd]["productLevel"])
					cChave += cTRT
				EndIf

				VarGetAD(oProcesso:cUIDRasEntr, cChave, @aDocGerado)

				If Empty(aDocGerado)
					cChave := cDocGerado + "_" + cProduto + "_"
					//Tenta buscar o doc gerado sem o TRT.
					VarGetAD(oProcesso:cUIDRasEntr, cChave, @aDocGerado)
				EndIf

				If Empty(aDocGerado)
					//Verifica se a entrada desse produto foi gerada por um subproduto.
					cChave := "SUBPRD|" + RTrim(oJson["items"][nInd]["product"]) + "|" + oJson["items"][nInd]["date"]
					VarGetAD(oProcesso:cUIDRasEntr, cChave, @aDocGerado)
				EndIf

				If !Empty(aDocGerado)
					cTipDocGer := aDocGerado[1]
					cDocGerado := aDocGerado[2]
					aSize(aDocGerado, 0)
				EndIf
			EndIf

			If !lRastPai .And. (lPreDoc .Or. lPaiPre)
				addRastPai(@oRastPai, oJson["items"][nInd]["quantity"], oJson["items"][nInd]["document"], oJson["items"][nInd]["demandId"])
			EndIf

			cIdReg := IIF(RTrim(oJson["items"][nInd]["productLevel"])=='99','MP','PA') + oProcesso:cTicket + "_" + RTrim(oJson["items"][nInd]["id"])
			cChave := oJson["items"][nInd]["branchId"] + "_" + cDemanda + "_" + cValToChar(nSeqDeman) + "_" + cIdReg

			trataChave(@oIncluidos, cChave, @cIdReg)

			cTipDocGer := PadR(cTipDocGer, nTamTpEnt)
			cDocGerado := PadR(cDocGerado, nTamNmEnt)
			cTipDocPai := PadR(cTipDocPai, nTamTpSai)
			cDocPai    := PadR(cDocPai   , nTamNmSai)
			cProduto   := PadR(cProduto  , nTamProd )
			cTRT       := PadR(cTRT      , nTamTRT  )
			cIdReg     := PadR(cIdReg    , nTamIDReg)

			If (lPreDoc .Or. lPaiPre) .And. lRastPai
				//Calcula a qtd deste componente relacionada ao uso do produto pai para o documento pré-existente.

				//nUsoPai = Quantidade que o produto PAI utilizou da ordem de produção.
				nUsoPai   := oRastPai[RTrim(oJson["items"][nInd]["parentDocument"])+";"+oJson["items"][nInd]["demandId"]]
				//nQtdOPPai = Quantidade total da ordem de produção PAI (sem descontar _QUJE)
				nQtdOPPai := oJson["items"][nInd]["quantityDocumentFather"]
				//nQtdEmp = Quantidade original do empenho
				nQtdEmp   := getQtdSD4(cDocPai, cProduto, cTRT, Iif(Empty(oJson["items"][nInd]["destinyBranch"]), oJson["items"][nInd]["branchId"], oJson["items"][nInd]["destinyBranch"]))
				//nQtdNec = Quantidade necessária do componente, considerando a QTD DA OP PAI e a QTD TOTAL DO EMPENHO.
				nQtdNec   := (nQtdEmp / nQtdOPPai)

				nQuant := (oJson["items"][nInd]["quantity"]/nQtdEmp) //Verifica a proporção desse empenho X empenho total
				nQuant := nQuant * nQtdNec * nUsoPai //Quantidade atendida do empenho por esta OP, proporcionada ao empenho.

				nQuant := Round(nQuant, nDecSMH)

				//Registrar em oRastPai a quantidade atualizada deste produto, para utilizar nos produtos filhos.
				addRastPai(@oRastPai, nQuant, oJson["items"][nInd]["document"], oJson["items"][nInd]["demandId"])
			Else
				nQuant := oJson["items"][nInd]["quantity"]
			EndIf

			aAdd(aIncluir, {oJson["items"][nInd]["branchId"]  , ; // MH_FILIAL
							cDemanda                          , ; // MH_DEMANDA
							nSeqDeman                         , ; // MH_DEMSEQ
							cDocDeman                         , ; // MH_DEMDOC
							cTipDocGer                        , ; // MH_TPDCENT
							cDocGerado                        , ; // MH_NMDCENT
							cProduto                          , ; // MH_PRODUTO
							SToD(oJson["items"][nInd]["date"]), ; // MH_DATA
							nQuant                            , ; // MH_QUANT
							cTipDocPai                        , ; // MH_TPDCSAI
							cDocPai                           , ; // MH_NMDCSAI
							cIdReg                            , ; // MH_IDREG
							cTRT} )                               // MH_TRT

			If lTemIDPai
				//Grava o identificador do registro pai
				cChave := RTrim(oJson["items"][nInd]["demandId"]) + "|" + RTrim(oJson["items"][nInd]["document"])
				If ! oIdsPai:HasProperty(cChave)
					oIdsPai[cChave] := cIdReg
				EndIf

				//Verifica se o documento possui registro pai, e adiciona informação na coluna MH_IDPAI
				cChave := RTrim(oJson["items"][nInd]["demandId"]) + "|" + RTrim(oJson["items"][nInd]["parentDocument"])
				If oIdsPai:HasProperty(cChave)
					aAdd(aIncluir[nInd], oIdsPai[cChave])
				Else
					aAdd(aIncluir[nInd], cIdPaiPad)
				EndIf
			EndIf

			If lFieldsLt
				aAdd(aIncluir[nInd], oJson["items"][nInd]["lote"   ])
				aAdd(aIncluir[nInd], oJson["items"][nInd]["subLote"])
			EndIf

			If lFilDest
				aAdd(aIncluir[nInd], oJson["items"][nInd]["destinyBranch"])
				aAdd(aIncluir[nInd], cFilDeman)
			EndIf

			FreeObj(oJson["items"][nInd])

			//Incremento do percentual de progresso
			oProcesso:incCount("RASTREABILIDADE_PROCESSADO")
		Next nInd
		aSize(oJson["items"], 0)

		P145DelRas(oExcluir)
		//Incremento do percentual de progresso após a exclusão
		oProcesso:incCount("RASTREABILIDADE_PROCESSADO")

		lOk := inserir(aIncluir, lTemIDPai, lFieldsLt, lFilDest, oProcesso)

		FreeObj(_oDocDem)
		FreeObj(_oQtdSD4)
		FreeObj(oRastPai)
		FreeObj(oExcluir)
		FreeObj(oIncluidos)
		FreeObj(oJson)
		FwFreeObj(oJsEstSeg)
		FwFreeObj(oJsPPed)
		If lTemIDPai
			FreeObj(oIdsPai)
		EndIf
		If _oQrySD4 != Nil
			_oQrySD4:Destroy()
			_oQrySD4 := Nil
		EndIf
		If _oQrySVR != Nil
			_oQrySVR:Destroy()
			_oQrySVR := Nil
		EndIf

	EndIf
	FreeObj(aRegs[2])
	aSize(aRegs, 0)

	//Incrementa contador para identificar que a thread foi finalizada.
	oProcesso:incCount("RASTREABILIDADE_FIM")
	oProcesso:msgLog("Termino do processo de geracao da Rastreabilidade. [" + Time() + "]", "6")

Return lOk

/*/{Protheus.doc} inserir
Insere os dados na tabela SMH

@type  Static Function
@author lucas.franca
@since 06/03/2024
@version P12
@param 01 aIncluir , Array , Array com os dados para inclusão
@param 02 lTemIDPai, Logic , Indica se pode gravar a coluna MH_IDPAI
@param 03 lFieldsLt, Logic , Indica se pode gravar as colunas MH_LOTE e MH_SLOTE
@param 04 lFilDest , Logic , Indica se pode gravar as colunas MH_FILDES e MH_DEMFIL
@param 05 oProcesso, Object, Instância da classe de processamento do PCPA145
@return lOk, Logic, Retorna se incluiu os dados com sucesso
/*/
Static Function inserir(aIncluir, lTemIDPai, lFieldsLt, lFilDest, oProcesso)
	Local aFields := {}
	Local lOk     := .T.
	Local nIndex  := 1
	Local nTotal  := Len(aIncluir)
	Local oBulk   := FwBulk():New(RetSqlName("SMH"))

	aAdd(aFields, {"MH_FILIAL" })
	aAdd(aFields, {"MH_DEMANDA"})
	aAdd(aFields, {"MH_DEMSEQ" })
	aAdd(aFields, {"MH_DEMDOC" })
	aAdd(aFields, {"MH_TPDCENT"})
	aAdd(aFields, {"MH_NMDCENT"})
	aAdd(aFields, {"MH_PRODUTO"})
	aAdd(aFields, {"MH_DATA"   })
	aAdd(aFields, {"MH_QUANT"  })
	aAdd(aFields, {"MH_TPDCSAI"})
	aAdd(aFields, {"MH_NMDCSAI"})
	aAdd(aFields, {"MH_IDREG"  })
	aAdd(aFields, {"MH_TRT"    })

	If lTemIDPai
		aAdd(aFields, {"MH_IDPAI"})
	EndIf

	If lFieldsLt
		aAdd(aFields, {"MH_LOTE" })
		aAdd(aFields, {"MH_SLOTE"})
	EndIf

	If lFilDest
		aAdd(aFields, {"MH_FILDES"})
		aAdd(aFields, {"MH_DEMFIL"})
	EndIf

	oBulk:SetFields( aFields )
	aSize(aFields, 0)

	While nIndex <= nTotal .And. lOk
		lOk := oBulk:addData(aIncluir[nIndex])

		aSize(aIncluir[nIndex], 0)
		nIndex++

		//Incremento do percentual de progresso
		oProcesso:incCount("RASTREABILIDADE_PROCESSADO")
	End

	If lOk
		lOk := oBulk:close()
	EndIf

	If !lOk
		Final(STR0053, oBulk:getError()) //"Erro ao gravar a rastreabilidade das demandas."
	EndIf

	oBulk:Destroy()
	FreeObj(oBulk)
	aSize(aIncluir, 0)

Return lOk

/*/{Protheus.doc} getDocDem
Busca o número do documento (VR_DOC) da demanda
@type Static Function
@author marcelo.neumann
@since 02/12/2020
@version P12.1.31
@param 01 cFilDeman, Caracter, Filial da demanda
@param 02 cDemanda , Caracter, Código da demanda
@param 03 nSeqDeman, Numeric , Sequência da demanda
@param 04 cDemandID, Caracter, ID da demanda obtida da SME
@return   cDocDeman, Caracter, Documento da demanda (VR_DOC)
/*/
Static Function getDocDem(cFilDeman, cDemanda, nSeqDeman, cDemandID)
	Local cAlias    := ""
	Local cDocDeman := ""

	If _oDocDem:HasProperty(cDemandID)
		cDocDeman := _oDocDem[cDemandID]
	Else
		If _oQrySVR == Nil
			_oQrySVR := FwExecStatement():New("SELECT SVR.VR_DOC"+;
			                                   " FROM " + RetSqlName("SVR") + " SVR" +;
			                                  " WHERE SVR.VR_FILIAL = ?"             +;
			                                    " AND SVR.VR_CODIGO = ?"             +;
			                                    " AND SVR.VR_SEQUEN = ?"             +;
			                                    " AND SVR.D_E_L_E_T_ = ' '"           )
		EndIf

		_oQrySVR:setString( 1, cFilDeman) //VR_FILIAL
		_oQrySVR:setString( 2, cDemanda ) //VR_CODIGO
		_oQrySVR:setNumeric(3, nSeqDeman) //VR_SEQUEN

		cAlias := PCPAliasQr()
		_oQrySVR:OpenAlias(cAlias)

		If (cAlias)->(!Eof())
			cDocDeman := (cAlias)->VR_DOC
		EndIf
		(cAlias)->(dbCloseArea())

		_oDocDem[cDemandID] := cDocDeman
	EndIf

Return cDocDeman

/*/{Protheus.doc} P145SetDoc
Seta a variável global com o De-Para do documento
@type Function
@author marcelo.neumann
@since 03/12/2020
@version P12.1.31
@param 01 oProcesso , Objeto  , Classe da geração de documentos
@param 02 aDados    , Array   , Array com as informações do rastreio que serão processados.
                                As posições deste array são acessadas através das constantes iniciadas com o nome RASTREIO_POS.
								Estas constantes estão definidas no arquivo PCPA145DEF.ch
@param 03 cTipDocERP, Caracter, Tipo do documento gerado no ERP
@param 04 cDocGerado, Caracter, Número do documento gerado no ERP
/*/
Function P145SetDoc(oProcesso, aDados, cTipDocERP, cDocGerado)

	Local cDocFilho := ""
	Local cChave    := ""
	Local cProduto  := ""
	Local cTRT      := ""

	If !Empty(cDocGerado)
		If Empty(aDados[RASTREIO_POS_DOCFILHO])
			If aDados[RASTREIO_POS_TIPODOC] == "Ponto Ped."
				cDocFilho := "Ponto Ped." + DToS(aDados[RASTREIO_POS_DATA_ENTREGA]) + "_" + cValToChar(aDados[RASTREIO_POS_SEQUEN]) + "_Filha"
			Else
				cDocFilho := Trim(aDados[RASTREIO_POS_DOCPAI]) + "_" + cValToChar(aDados[RASTREIO_POS_SEQUEN]) + "_Filha"
			EndIf
		Else
			cDocFilho := Trim(aDados[RASTREIO_POS_DOCFILHO])
		EndIf

		cProduto := Trim(aDados[RASTREIO_POS_PRODUTO])
		If oProcesso:getGeraDocAglutinado(aDados[RASTREIO_POS_NIVEL])
			cTRT := ""
		Else
			cTRT := Trim(aDados[RASTREIO_POS_TRT])
		EndIf

		cChave   := cDocFilho + "_" + cProduto + "_" + cTRT

		VarSetAD(oProcesso:cUIDRasEntr, cChave, {cTipDocERP, cDocGerado})

		If AllTrim(aDados[RASTREIO_POS_TIPODOC]) == "SUBPRD"
			cChave := "SUBPRD|" + RTrim(aDados[RASTREIO_POS_DOCPAI]) + "|" + DtoS(aDados[RASTREIO_POS_DATA_ENTREGA])
			VarSetAD(oProcesso:cUIDRasEntr, cChave, {cTipDocERP, cDocGerado})
		EndIf

	EndIf

Return

/*/{Protheus.doc} preExist
Retorna se é um documento pré-existente, removendo o indicador do número
@type Static Function
@author marcelo.neumann
@since 19/12/2020
@version P12.1.31
@param 01 cNumDoc, Character, Número do documento a ser verificado (retornado por referência)
@return lPreExist, Logic    , Indica se o documento é pré-existente
/*/
Static Function preExist(cNumDoc)

	Local lPreExist := .F.

	If Left(cNumDoc, 4) == "Pre_"
		lPreExist := .T.
		cNumDoc   := SubStr(cNumDoc, 5, Len(cNumDoc))
	EndIf

Return lPreExist

/*/{Protheus.doc} P145DelRas
Exclui os documentos pré-existentes que foram usados no cálculo e que já possuíam rastreabilidade
@type Static Function
@author marcelo.neumann
@since 22/12/2020
@version P12
@param 01 oExcluir, Object, Json com os registros a serem excluídos da SMH
@return Nil
/*/
Function P145DelRas(oExcluir)
	Local aExcluir := oExcluir:GetNames()
	Local cUpdDel  := ""
	Local cFilAux  := ""
	Local cUltFil  := ""
	Local nIndex   := 1
	Local nTotal   := Len(aExcluir)

	For nIndex := 1 To nTotal
		If cUltFil != oExcluir[aExcluir[nIndex]][4]
			cUltFil := oExcluir[aExcluir[nIndex]][4]
			cFilAux := xFilial("SMH", cUltFil)
		EndIf

		cUpdDel := "UPDATE " + RetSqlName("SMH")             + ;
				 	 " SET D_E_L_E_T_   = '*',"              + ;
				 	 	 " R_E_C_D_E_L_ = R_E_C_N_O_"        + ;
				   " WHERE MH_FILIAL    = '" + cFilAux + "'" + ;
					 " AND D_E_L_E_T_   = ' '"

		If oExcluir[aExcluir[nIndex]][1] == "E"
			cUpdDel += " AND MH_TPDCENT = '" + oExcluir[aExcluir[nIndex]][2] + "'" + ;
			           " AND MH_NMDCENT = '" + oExcluir[aExcluir[nIndex]][3] + "'"
		Else
			cUpdDel += " AND MH_TPDCSAI = '" + oExcluir[aExcluir[nIndex]][2] + "'" + ;
			           " AND MH_NMDCSAI = '" + oExcluir[aExcluir[nIndex]][3] + "'"
		EndIf

		If TcSqlExec(cUpdDel) < 0
			Final("Erro ao excluir os registros de rastreabilidade.", TcSqlError())
		EndIf
	Next nIndex

Return

/*/{Protheus.doc} addRastPai
Adiciona a quantidade utilizada ao objeto de rastreio

@type  Static Function
@author lucas.franca
@since 07/10/2021
@version P12
@param 01 oRastPai  , Object   , Objeto com os rastreios das quantidades utilizadas
@param 02 nQtd      , Numeric  , Quantidade utilizada.
@param 03 cDocSaida , Character, Código do documento de saída
@param 04 cIdDemanda, Character, ID da demanda que consumiu o documento
@return Nil
/*/
Static Function addRastPai(oRastPai, nQtd, cDocSaida, cIdDemanda)
	Local cChave := RTrim(cDocSaida) + ";" + cIdDemanda

	If oRastPai:HasProperty(cChave)
		oRastPai[cChave] += nQtd
	Else
		oRastPai[cChave] := nQtd
	EndIf
Return Nil

/*/{Protheus.doc} getQtdSD4
Busca a quantidade original do empenho

@type  Static Function
@author lucas.franca
@since 20/10/2021
@version P12
@param cNumOp , Character, Número da ordem de produção
@param cComp  , Character, Código do componente
@param cTRT   , Character, Sequência do componente
@param cFilAux, Character, Código da filial em processamento
@return nQtdEmp, Numeric, Quantidade original do empenho
/*/
Static Function getQtdSD4(cNumOp, cComp, cTRT, cFilAux)
	Local cAlias  := ""
	Local cQuery  := ""
	Local nQtdEmp := 0
	Local cChave  := cFilAux + ";" + cNumOp + ";" + cComp + ";" + cTRT

	If _oQtdSD4:HasProperty(cChave)
		nQtdEmp := _oQtdSD4[cChave]
	Else
		If _oQrySD4 == Nil
			cQuery := " SELECT SUM(SD4.D4_QTDEORI) TOTAL "
			cQuery +=   " FROM " + RetSqlName("SD4") + " SD4 "
			cQuery +=  " WHERE SD4.D4_FILIAL  = ?"
			cQuery +=    " AND SD4.D4_OP      = ?"
			cQuery +=    " AND SD4.D4_COD     = ?"
			cQuery +=    " AND SD4.D4_TRT     = ?"
			cQuery +=    " AND SD4.D_E_L_E_T_ = ' ' "

			_oQrySD4 := FwExecStatement():New(cQuery)
		EndIf

		_oQrySD4:setString(1, xFilial("SD4", cFilAux))
		_oQrySD4:setString(2, cNumOp)
		_oQrySD4:setString(3, cComp)
		_oQrySD4:setString(4, cTRT)

		cAlias := PCPAliasQr()
		_oQrySD4:openAlias(cAlias)
		nQtdEmp := (cAlias)->(TOTAL)
		(cAlias)->(dbCloseArea())

		_oQtdSD4[cChave] := nQtdEmp
	EndIf

Return nQtdEmp

/*/{Protheus.doc} trataChave
Verifica a necessidade de tratar a chave do registro que será incluído na tabela SME,
e manipula o identificador de registro se necessário.

@type  Static Function
@author lucas.franca
@since 17/01/2022
@version P12
@param oIncluidos, JsonObject, JSON com as chaves já incluídas
@param cChave    , Character , Chave original do registro
@param cIdReg    , Character , Identificador do registro que será gravado
@return Nil
/*/
Static Function trataChave(oIncluidos, cChave, cIdReg)

	If oIncluidos:HasProperty(cChave)
		oIncluidos[cChave] := oIncluidos[cChave] + 1
		cIdReg := RTrim(cIdReg) + "_" + cValToChar(oIncluidos[cChave])
	Else
		oIncluidos[cChave] := 0
	EndIf

Return Nil

/*/{Protheus.doc} getPrdOrg
Percorre o json com os documentos de estoque de segurança e retorna o produto pai que deu origem aos documentos.
@type  Static Function
@author Lucas Fagundes
@since 17/11/2022
@version P12
@param 01 oJson , Object  , Json com os documentos relacionados a estoque de segurança.
@param 02 cChave, Caracter, Chave inicial da busca no json.
@return cProduto, Caracter, Produto que deu origem ao estoque de segurança.
/*/
Static Function getPrdOrg(oJson, cChave)
	Local cProduto   := ""
	Local lContinua  := .T.
	Local oChvCheck  := JsonObject():New()

	If oJson:HasProperty(cChave)
		While lContinua
			lContinua := oJson:HasProperty(oJson[cChave]["parentDocument"])

			If lContinua
				cChave := oJson[cChave]["parentDocument"]
				If oChvCheck:HasProperty(cChave)
					lContinua := .F.
				EndIf
				oChvCheck[cChave] := .T.
			EndIf
		End

		cProduto := oJson[cChave]["product"]
	EndIf
	FreeObj(oChvCheck)
Return cProduto

/*/{Protheus.doc} addExcluir
Adiciona um novo registro para exclusão no json "oExcluir".

@type  Static Function
@author lucas.franca
@since 14/09/2023
@version P12
@param 01 oExcluir  , JsonObject, Json para armazenar os dados de exclusão
@param 02 cEntSai   , Caracter  , Identifica se é um documento de 'E'ntrada ou 'S'aída
@param 03 cTipDocPai, Caracter  , Identifica qual é o tipo de documento pai
@param 04 cDocPai   , Caracter  , Número do documento pai
@param 05 cFilAux   , Caracter  , Código da filial
@return Nil
/*/
Static Function addExcluir(oExcluir, cEntSai, cTipDocPai, cDocPai, cFilAux)
	Local cChave := cEntSai + cTipDocPai + "_" + cDocPai + "_" + cFilAux

	If oExcluir:HasProperty(cChave) == .F.
		oExcluir[cChave] := {cEntSai, cTipDocPai, cDocPai, cFilAux}
	EndIf
Return Nil
