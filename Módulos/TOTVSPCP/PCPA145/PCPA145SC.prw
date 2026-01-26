#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145.ch"
#INCLUDE "PCPA145DEF.ch"

Static __LenNumSC := GetSx3Cache("C1_NUM" ,"X3_TAMANHO")
Static __LenItem  := GetSx3Cache("C1_ITEM","X3_TAMANHO")
Static __IniCom   := Nil
Static __UserGrup := UsrRetGrp()
Static __oGrupCmp := JsonObject():New()
Static __oFilSC1  := JsonObject():New()
Static __oParam   := JsonObject():New()
Static __oProcess := Nil

/*/{Protheus.doc} PCPA145SC
Função para geração das solicitações de compra

@type Function
@author marcelo.neumann
@since 15/11/2019
@version P12.1.27
@param 01 oProcesso , Object   , Instância da classe ProcessaDocumentos
@param 02 aDados    , Array    , Array com as informações do rastreio que serão processados.
                                 As posições deste array são acessadas através das constantes iniciadas
                                 com o nome RASTREIO_POS. Estas constantes estão definidas no arquivo PCPA145DEF.ch
@param 03 cDocPaiERP, Character, Código do documento pai deste registro
@param 04 cObs      , Character, Obervação a ser gravada na SC1, no campo C1_OBS
@param 05 cNumScUni , Character, Número da SC quando parametrizado para ter numeração única (oProcesso:cIncSC == "1")
@param 06 cItemSC   , Character, Item da SC criada. Retorna a informação por referência.
@return   cNumSolic , Character, Número da solicitação de compra incluída
/*/
Function PCPA145SC(oProcesso, aDados, cDocPaiERP, cObs, cNumScUni, cItemSC)
	Local aSC        := {}
	Local cGrpCompra := ""
	Local cNumOP     := " "
	Local cNumSolic  := BuscaNumSC(oProcesso, cNumScUni, @cItemSC)
	Local cTicket    := oProcesso:cTicket
	Local cTipoOp    := oProcesso:getTipoDocumento(aDados[RASTREIO_POS_DATA_ENTREGA], "SC")
	Local cLocal     := aDados[RASTREIO_POS_LOCAL]
	Local lAtuEstPCP := .F.
	Default cObs     := " "

	If __oGrupCmp[aDados[RASTREIO_POS_PRODUTO]] == Nil
		__oGrupCmp[aDados[RASTREIO_POS_PRODUTO]] := MaRetComSC(aDados[RASTREIO_POS_PRODUTO], __UserGrup, oProcesso:cCodUsr)
	EndIf

	If __oFilSC1[cFilAnt] == Nil
		__oFilSC1[cFilAnt] := xFilial("SC1")
		__oParam["MV_GRVLOCP"+cFilAnt] := SuperGetMV("MV_GRVLOCP", .F., .T.)
	EndIf

	If __IniCom == Nil
		dbSelectArea("SC1")
		__IniCom := FieldPos("C1_DINICOM") > 0
	EndIf

	cGrpCompra := __oGrupCmp[aDados[RASTREIO_POS_PRODUTO]]

	//Posiciona no produto
	If SB1->B1_COD != aDados[RASTREIO_POS_PRODUTO] .Or. SB1->B1_FILIAL != xFilial("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + aDados[RASTREIO_POS_PRODUTO]))
	EndIf

	If SB1->B1_APROPRI == "I" .And. __oParam["MV_GRVLOCP"+cFilAnt]
		cLocal := oProcesso:getLocProcesso()
	EndIf

	//Se não gera os documentos aglutinados, busca o número da OP Pai para gerar o C1_OP
	If !oProcesso:getGeraDocAglutinado(aDados[RASTREIO_POS_NIVEL])
		cNumOP := cDocPaiERP
	EndIf

	//Inicializa a gravacao dos lancamentos do SIGAPCO
	PcoIniLan("000051")

	//Inclui o registro
	RecLock("SC1",.T.)
		SC1->C1_FILIAL  := __oFilSC1[cFilAnt]
		SC1->C1_NUM     := cNumSolic
		SC1->C1_ITEM    := cItemSC
		SC1->C1_TPOP    := cTipoOp
		SC1->C1_OP      := cNumOP
		SC1->C1_GRUPCOM := cGrpCompra
		SC1->C1_SEQMRP  := cTicket
		SC1->C1_USER    := oProcesso:cCodUsr
		SC1->C1_EMISSAO := dDataBase
		SC1->C1_PRODUTO := aDados[RASTREIO_POS_PRODUTO]
		SC1->C1_LOCAL   := cLocal
		SC1->C1_QUANT   := aDados[RASTREIO_POS_NECESSIDADE]
		SC1->C1_QTDORIG := aDados[RASTREIO_POS_NECESSIDADE]
		SC1->C1_QTSEGUM := oProcesso:ConvUm(aDados[RASTREIO_POS_PRODUTO], aDados[RASTREIO_POS_NECESSIDADE], 0, 2)
		SC1->C1_DATPRF  := aDados[RASTREIO_POS_DATA_ENTREGA]
		SC1->C1_CC      := SB1->B1_CC
		SC1->C1_ITEMCTA := SB1->B1_ITEMCC
		SC1->C1_CLVL    := SB1->B1_CLVL
		SC1->C1_UM      := SB1->B1_UM
		SC1->C1_DESCRI  := SB1->B1_DESC
		SC1->C1_FORNECE := SB1->B1_PROC
		SC1->C1_CONTA   := SB1->B1_CONTA
		SC1->C1_SEGUM   := SB1->B1_SEGUM
		SC1->C1_IMPORT  := SB1->B1_IMPORT
		SC1->C1_LOJA    := SB1->B1_LOJPROC
		SC1->C1_COTACAO := If(SB1->B1_IMPORT == "S", "IMPORT", "")
		SC1->C1_FILENT  := xFilEnt(If(Empty(C1_FILENT), C1_FILIAL, C1_FILENT))
		SC1->C1_TIPCOM  := MRetTipCom( , .T., "SC")
		SC1->C1_SOLICIT := oProcesso:getUserName()
		SC1->C1_OBS     := cObs
		SC1->C1_RATEIO  := "2"
		SC1->C1_TIPO    := 1
		SC1->C1_ORIGEM  := "PCPA144"
		If __IniCom
			SC1->C1_DINICOM := aDados[RASTREIO_POS_DATA_INICIO]
		EndIf
	SC1->(MsUnlock())

	//Rotina de avaliação dos eventos de uma solicitação de compra (COMXFUN)
	MaAvalSC("SC1",1,/*03*/,/*04*/,/*05*/,/*06*/,/*07*/,/*08*/,/*09*/,.T.,@lAtuEstPCP)

	//Finaliza a gravacao dos lancamentos do SIGAPCO
	PcoFinLan("000051")
	PcoFreeBlq("000051")

	//Salva na seção global de ordens a integrar
	If oProcesso:lDocAlcada
		aAdd(aSC, {cFilAnt        , ;
		           cNumSolic      , ;
		           SC1->C1_ITEM   , ;
		           SC1->C1_QUANT  , ;
		           SC1->C1_PRODUTO, ;
		           SC1->C1_CC     , ;
		           SC1->C1_CONTA  , ;
		           SC1->C1_ITEMCTA, ;
		           SC1->C1_CLVL   , ;
		           SC1->C1_TIPCOM , ;
		           SC1->C1_EMISSAO})

		If !VarSetA(oProcesso:cUIDDocAlc, cFilAnt + cNumSolic, {}, 2, aSC)
			oProcesso:msgLog("Não conseguiu salvar a SC para gerar a Alçada: " + cNumSolic)
		EndIf
	EndIf

	If lAtuEstPCP
		//Atualiza tabela temporária para atualização de estoques
		oProcesso:atualizaSaldo(aDados[RASTREIO_POS_PRODUTO]    ,;
		                        cLocal                          ,;
		                        aDados[RASTREIO_POS_NIVEL]      ,;
		                        aDados[RASTREIO_POS_NECESSIDADE],;
		                        1                               ,; //Tipo 1 = Entrada
		                        IIF(cTipoOp == "P",.T.,.F.)     ,; //Documento Previsto
		                        cFilAnt                          )
	EndIf

Return cNumSolic

/*/{Protheus.doc} BuscaNumSC
Busca o número e item da Solicitação de Compra

@type Static Function
@author marcelo.neumann
@since 15/11/2019
@version P12.1.27
@param  01 oProcesso, Object   , Instância da classe ProcessaDocumentos
@param  02 cNumScUni, Character, Número da SC quando parametrizado para ter numeração única (oProcesso:cIncSC == "1")
@param  03 cItem    , Character, sequência do item para a solcitação de compra (referência)
@return cNumSolic, Character, número da próxima solicitação de compra
/*/
Static Function BuscaNumSC(oProcesso,cNumScUni,cItem)

	Local cAlias    := ""
	Local cNumSolic := ""

	If oProcesso:cIncSC == "2"

		cNumSolic := GetNumSC1(.T.)
		If Empty(cNumSolic)
			cAlias := GetNextAlias()

			//Busca a última numeração da tabela
			BeginSql Alias cAlias
				SELECT MAX(C1_NUM) MAX_NUM
				FROM %Table:SC1%
				WHERE C1_FILIAL = %xfilial:SC1%
				AND %NotDel%
			EndSql

			//Se não existe registro na tabela, usa a numeração "000001"
			If (cAlias)->(Eof())
				cNumSolic := StrZero(1, __LenNumSC)
			Else
				cNumSolic := Soma1((cAlias)->MAX_NUM)
			EndIf
		EndIf

		cItem := StrZero(1, __LenItem)
	Else
		//Busca número único da SC, que foi reservado no NEW do PCPA145
		cNumSolic := cNumScUni
		cItem     := prxItemSc(cNumSolic,oProcesso)
	EndIf

Return cNumSolic

/*/{Protheus.doc} prxItemSc
Retorna o próximo item válido para utilização na geração da tabela SC1

@type  Static Function
@author renan.roeder
@since 28/05/2020
@version P12.1.30
@param cChaveSC , Character, Chave identificadora da SC (C1_NUM)
@param oProcesso, Object   , Referência da classe de controle do processamento
@return cItem   , Character, Próximo item para utilização na geração da tabela SC1
/*/
Static Function prxItemSc(cChaveSC, oProcesso)
	Local cItem  := ""
	Local lRet   := .T.

	cChaveSC := "ITEMSC" + cChaveSC + cFilAnt

	//Abre transação na chave da OP
	VarBeginT(oProcesso:cUIDGlobal, cChaveSC )

	//Recupera o valor atual da sequência desta OP
	lRet := VarGetXD(oProcesso:cUIDGlobal, cChaveSC, @cItem)
	If !lRet
		//Não encontrou a chave. Inicializa.
		cItem := StrZero(1, __LenItem)
	Else
		//Encontrou a chave, incrementa a sequência
		cItem := Soma1(cItem)
	EndIf

	//Atualiza a global com a última sequência
	lRet := VarSetXD(oProcesso:cUIDGlobal, cChaveSC, cItem)

	//Fecha a transação da chave da OP
	VarEndT(oProcesso:cUIDGlobal, cChaveSC)

Return cItem

/*/{Protheus.doc} P145QtdSCs
Calcula a quantidade de SCs que serão geradas

@type Function
@author marcelo.neumann
@since 11/01/2024
@version P12
@param  aDocs  , Array  , Dados que serão processados
@return nQtdSCs, Numeric, Quantidade de Solicitações de Compras
/*/
Function P145QtdSCs(aDocs)
	Local nIndex  := 0
	Local nQtdSCs := 0
	Local nTotal  := Len(aDocs)

	For nIndex := nTotal To 1 Step -1
		If aDocs[nIndex]["level"] == "99" .And. aDocs[nIndex]["quantityNecessity"] > 0
			nQtdSCs++
		EndIf
	Next nIndex

Return nQtdSCs

/*/{Protheus.doc} P145Alcada
Prepara e delega a gravação dos documentos com alçada

@type Function
@author marcelo.neumann
@since 11/01/2024
@version P12
@param 01 cTicket  , Character, Ticket de processamento do MRP para geração dos documentos
@param 02 cCodUsr  , Character, Código do usuário logado no sistema
@param 03 cErrorUID, Character, Código identificador do controle de erros multi-thread
@return Nil
/*/
Function P145Alcada(cTicket, cCodUsr, cErrorUID)
	Local aItens     := {}
	Local aSCs       := {}
	Local cChave     := ""
	Local cFilBkp    := cFilAnt
	Local dDtDoc     := Nil
	Local lOk        := .T.
	Local nIndItem   := 1
	Local nIndSC     := 1
	Local nTotItens  := 0
	Local nTotSC     := 0
	Local oVProd     := Nil
	Local oProcesso  := ProcessaDocumentos():New(cTicket, .T., /*03*/, cCodUsr, /*05*/, cErrorUID)

	oProcesso:msgLog("Iniciando processo de alcada. [" + Time() + "]", "6")

	//Recupera na seção global as SCs geradas
	lOk := VarGetAA(oProcesso:cUIDDocAlc, @aSCs)
	VarCleanA(oProcesso:cUIDDocAlc)

	If lOk .And. !Empty(aSCs)
		VarSetXD(oProcesso:cUIDGlobal, TEXTO_PROCESSAMENTO, STR0051) //"Gerando as alçadas dos documentos"

		oVProd := JsonObject():New()

		nTotSC := Len(aSCs)
		For nIndSC := 1 To nTotSC
			dDtDoc := aSCs[nIndSC][2][1][11] //C1_EMISSAO

			nTotItens := Len(aSCs[nIndSC][2])
			For nIndItem := 1 To nTotItens
				cFilAnt := aSCs[nIndSC][2][nIndItem][1]
				cChave  := cFilAnt + aSCs[nIndSC][2][nIndItem][5]
				If !oVProd:HasProperty(cChave)
					oVProd[cChave] := MTGetVProd(aSCs[nIndSC][2][nIndItem][5])
				EndIf

				aAdd(aItens, {aSCs[nIndSC][2][nIndItem][2]                 , ; //C1_NUM
				              aSCs[nIndSC][2][nIndItem][3]                 , ; //C1_ITEM
				              ""                                           , ;
				              aSCs[nIndSC][2][nIndItem][4] * oVProd[cChave], ; //C1_QUANT * C1_PRODUTO
				              { aSCs[nIndSC][2][nIndItem][6],                ; //C1_CC
				                aSCs[nIndSC][2][nIndItem][7],                ; //C1_CONTA
				                aSCs[nIndSC][2][nIndItem][8],                ; //C1_ITEMCTA
				                aSCs[nIndSC][2][nIndItem][9] },              ; //C1_CLVL
				              aSCs[nIndSC][2][nIndItem][10]} )                 //C1_TIPCOM
			Next nIndItem

			oProcesso:incCount(oProcesso:cThrJobs + "_Delegados")
			PCPIPCGO(oProcesso:cThrJobs, .F., "P145PrcAlc", cTicket, cCodUsr, aItens, dDtDoc, cFilAnt)

			aSize(aItens, 0)
			aItens := {}
		Next nIndSC

		FreeObj(oVProd)
		aSize(aSCs, 0)

		cFilAnt := cFilBkp

		oProcesso:aguardaNivel()
	EndIf

	//Incrementa contador para identificar que a thread foi finalizada.
	oProcesso:incCount("ALCADA_FIM")
	oProcesso:msgLog("Termino do processo de geracao das alcadas. [" + Time() + "]", "6")

Return

/*/{Protheus.doc} P145PrcAlc
Chama as funções do módulo de Compras para gravar as alçadas de aprovação nos documentos gerados

@type Function
@author marcelo.neumann
@since 11/01/2024
@version P12
@param 01 cTicket, Character, Ticket de processamento do MRP para geração dos documentos
@param 02 cCodUsr, Character, Código do usuário logado no sistema
@param 03 aItens , Array    , Array com as SCs para passar para a MaRetAglEC
@param 04 dDtDoc , Date     , Data da emissão da SC para passar para a MaAlcDoc
@param 05 cFilAtu, Character, Filial do registro para setar como cFilAnt
@return Nil
/*/
Function P145PrcAlc(cTicket, cCodUsr, aItens, dDtDoc, cFilAtu)
	Local aAglut    := {}
	Local aGrpAprov := {}
	Local aItensDBM := {}
	Local cFilBkp   := cFilAnt
	Local cGrpAprov := ""
	Local cItAprov  := ""
	Local cOrderScn := ""
	Local lEntCtb   := .T.
	Local lGravaB   := .T.
	Local lGravaL   := .T.
	Local nLenDBMIt := 0
	Local nIndAgl   := 1
	Local nIndAprov := 1
	Local nTotAgl   := 0
	Local nTotAprov := 0

	cFilAnt := cFilAtu

	//Verifica se é necessário instanciar a classe ProcessaDocumentos nesta thread filha para utilização dos métodos.
	If __oProcess == Nil
		__oProcess := ProcessaDocumentos():New(cTicket, .T., /*03*/, cCodUsr)
	EndIf

	//Função para aglutinar os itens por entidade ctb
	aAglut := MaRetAglEC(aItens, "SC")

	//Gera SCR para cada entidade contábil
	nTotAgl := Len(aAglut)
	For nIndAgl := 1 To nTotAgl
		//Busca grupo de aprovadores
		aGrpAprov := MaGrpApEC(aClone(aAglut[nIndAgl][4]), @lEntCtb, "SC")
		cGrpAprov := IIf(Len(aGrpAprov) >= 1, aGrpAprov[1], "")
		cItAprov  := IIf(Len(aGrpAprov) >= 2, aGrpAprov[2], "")

		If !Empty(cGrpAprov)
			//Verifica o controle de alçadas
			MaAlcDoc({aAglut[nIndAgl][1], "SC", aAglut[nIndAgl][3], , , cGrpAprov, , , , dDtDoc}, , 1, , , cItAprov, aClone(aAglut[nIndAgl][2]), , @aItensDBM)

			nLenDBMIt := Len(DBM->DBM_ITEM)
			nTotAprov := Len(aAglut[nIndAgl][2])

			For nIndAprov := 1 To nTotAprov
				If SC1->(dbSeek(xFilial("SC1") + aAglut[nIndAgl][1] + aAglut[nIndAgl][2][nIndAprov][1]))
					cOrderScn := PadR(aAglut[nIndAgl][2][nIndAprov][1], nLenDBMIt)
					lGravaB   := aScan(aItensDBM, {|x| x[1] == cOrderScn}) > 0
					lGravaL   := MtGLastDBM("SC", aAglut[nIndAgl][1], aAglut[nIndAgl][2][nIndAprov][1])

					RecLock("SC1",.F.)
						SC1->C1_APROV := IIf(lGravaB, "B", IIf(lGravaL, "L", SC1->C1_APROV))
					SC1->(MsUnlock())
				EndIf
			Next nIndAprov

			aSize(aItensDBM, 0)
			aSize(aGrpAprov, 0)
		EndIf

		//Incremento do percentual de progresso
		__oProcess:incCount("ALCADA_PROCESSADO")
	Next nIndAgl

	cFilAnt := cFilBkp

	FwFreeArray(aAglut)
	__oProcess:incCount(__oProcess:cThrJobs + "_Concluidos")

Return
