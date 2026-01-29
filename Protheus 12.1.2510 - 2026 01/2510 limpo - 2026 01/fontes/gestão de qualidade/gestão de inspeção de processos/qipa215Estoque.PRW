#INCLUDE "COLORS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FOLDER.CH"
#INCLUDE "TOTVS.CH" 
#INCLUDE "QIPA215ESTOQUE.CH" 

#DEFINE CRLF chr(13) + chr(10)
#DEFINE MAXGETDAD 4096
#DEFINE NOPC_VISUALIZACAO 2

Static oSelf := NIL

CLASS QIPA215Estoque FROM LongNameClass
	
	DATA aAlterSD7                    as Array
	DATA aCols                        as Array
	DATA aColsBackup                  as Array
	DATA aHeader                      as Array
	DATA aHeaderBackup                as Array
	DATA aQuantidadesCQ               as Array
	DATA cArquivoCQ                   as String
	DATA cDiretorioCQ                 as String
	DATA cNumeroCQ                    as String
	DATA cTexto                       as String
	DATA cTitulo                      as String
	DATA lAborta                      as Logical
	DATA lIntegracaoEstoqueHabilitada as Logical
	DATA lPorApontamento              as Logical
	DATA lRastro                      as Logical
	DATA nBackup                      as Numeric
	DATA nIndRecno                    as Numeric
	DATA nOpcOriginal                 as Object
	DATA oMsGetDados                  as Object
	
	Method new(nOpc)

	//Métodos Públicos
	Method atualizaPotenciaEmTelaENaTabelaSD7()
	Method atualizaTotalizadoresPorArray()
	Method bloqueiaManutencaoViaMATA175(nRecno)
	Method estornaTodosMovimentosDeCQ(nRecnoQPK, lTemMovi)
	Method gravaResultados(nOpc, lHelp)
	Method montaTelaEstoqueCQ(oDlg, nOpc)
	Method montaTelaEstoqueCQMenu(oDlg, nOpc)
	Method movimentaPendenciasEstoqueCQAutomaticamente(nRecnoQPK)
	Method posicionaBaixaCQPorRecnoQPK(nRecnoQPK, cNumCQ, cLocCQ, lHelp) 
	Method possuiMovimentacaoEstoqueCQ()
	Method possuiMovimentacaoEstoqueCQComSeek(nRecnoQPK)
	Method possuiPendenciaMovimentacaoEstoqueCQComSeek(nRecnoQPK)
	Method validaLiberacaoDeCQ(nOpc)
	Method validaNecessidadeEMovimentaEstoqueCQAutomaticamente(nOpc, cLaudoGeral)
	Method validaSePermiteExibicaoBaixasCQ(nOpeGot, nOpeLost, nOpc, cLaudoGeral)

	//Métodos Internos
	Method adicionaItemMovimentoDefault(aColsAux, nUsado, lNovo)
	Method atribuiDadosLaudoGeral(nRejLaudo, nLiberLaudo, nTamLote, cLaudoGeral)
	Method atualizaQPKSITOPPosBaixaMenu()
	Method completaMovimentoCQAutomaticamenteEmArray()
	Method exibeMensagemDeIntegracaoNaoHabilitada()
	Method gatilhaArmazemDestino()
	Method gravaObsMovimentoCQ(nOpc)
	Method identificaCamposEditaveisCQ()
	Method inicializaPorApontamento(nOpc)
	Method inicializaPrivatesMATA175()
	Method integracaoHabilitada()
	Method marcaTodosOsEstornosNoArray()
	Method montaAHeaderSD7Generic(cAlias, nOpcx, cWhile, cSeek, aCols)
	Method montaTelaEstoqueCQPorApontamento(oDlg, nOpc)
	Method movimentaPendenciasEstoqueCQAutomaticamenteIndependente(nRecnoQPK)
	Method movimentaPendenciasEstoqueCQAutomaticamenteQIPA215()
	Method posicionaApontamentoDeProducaoMATA250()
	Method posicionaApontamentoDeProducaoPorOperacao()
	Method posicionaBaixaCQ()
	Method posicionaMovimentoInterno()
	Method possuiMovimentoBaixasOuHistoricoCQ()
	Method possuiPendenciaMovimentacaoEstoqueCQ()
	Method possuiPendenciaMovimentacaoEstoqueCQComSeekIndependente(nRecnoQPK)
	Method possuiPendenciaMovimentacaoEstoqueCQComSeekQIPA215(nRecnoQPK)
	Method preencheMovimentoCQ(nRecnoQPK, nOpc)
	Method retornaNumeroCQ()
	Method setaPrivatesBackup()
	Method setaPrivatesTelaEstoqueCQ()
	Method setaTituloPorApontamento(nOpc)
	Method validaMovimentoEstoqueCQxLaudoGeral()
	Method validaPermissaoDeAcessoEstornoMATA175()
	Method validaPermissaoDeAcessoLiberacaoMATA175()
	Method validaSeEhExecucaoComTelaResultadosQIPA215()
	Method validaSeEhExecucaoViaMenuQIPA215()
	Method validaSeORegristoDaSD7EhRelacionadoAoQIP(cNumero, cProduto, cNumLote)
	Method validaSePermiteMovimentacaoEstorno(oEstornos)
	Method validaSeUsuarioTemPermissaoParaEstornar()

EndClass

/*/{Protheus.doc} New
Construtor da Classe de Controle de Baixas do Estoque CQ
@author brunno.costa
@since  24/02/2023
@param 01 - nOpc, numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
				-1: chamada sem inicialização de dados, por exemplo: QIPLOAD, QIPA215 -> MenuDef
				 2: chamada de visualização
				 3: chamada pelo botão "Resultados"
				 4: chamada pelo botão "Excluir"
				 5: chamada pelo botão "Reabrir Inspeção"
				 7: chamada pelo botão "Baixar estoque CQ"
				 8: chamada pelo botão "Estornar estoque CQ"
@param 02 lClickMenu, Lógico, indica se a chamada veio à partir do clique do menu no QIPA215				 
/*/
Method new(nOpc,lClickMenu) CLASS QIPA215Estoque
	
	Local aArea       := Nil
	Local aAreaQPK    := Nil

	Default nOpc   := 0
	Default lClickMenu := .F.

	Self:lRastro := SuperGetMV("MV_RASTRO",.F.,'N') == "S"

	Self:nOpcOriginal := nOpc

	nOpc := Iif(nOpc == 7, 3, nOpc)
	nOpc := Iif(nOpc == 8, 3, nOpc)

	Self:lAborta  					  := .F.
	Self:lIntegracaoEstoqueHabilitada := .F.
	If Self:integracaoHabilitada(lClickMenu) 
		If nOpc > -1
			aArea         := GetArea()
			aAreaQPK      := QPK->(GetArea())
			Self:aCols    := {}
			Self:aHeader  := {}
			Self:cTexto   := ""

			If Self:lPorApontamento
				Self:inicializaPorApontamento(nOpc)
			EndIf

			RestArea(aAreaQPK)
			RestArea(aArea)
		EndIf
	ElseIf nOpc > -1
		If Self:lPorApontamento
			Self:setaTituloPorApontamento(nOpc)
		EndIf
	EndIf

Return

/*/{Protheus.doc} integracaoHabilitada
Avalia se a integração entre o SIGAQIP e SIGAEST está habilitada
@author brunno.costa
@since  24/02/2023
@param01 lClickMenu, Lógico, indica se a chamada veio à partir do clique do menu no QIPA215
@return lHabilitada, lógico, indica se a integração entre o SIGAQIP e SIGAEST está habilitada
/*/
Method integracaoHabilitada(lClickMenu) CLASS QIPA215Estoque
	Local lHabilitada    := SuperGetMV("MV_QIPEST", .F., "0") == "1"

	Self:lPorApontamento := SuperGetMV("MV_QINSPEC", .F., "2") == "2"

	If lHabilitada
		
		If !GetMV("MV_CQLIBER", .T.) .OR. !GetMV("MV_CQREJEI", .T.)
			//STR0037 - "Inconsistência na implantação da integração SIGAQIP e SIGAEST."
			//STR0038 - "Crie os parâmetros MV_CQLIBER e MV_CQREJEI no configurador conforme documentação."
			If Self:nOpcOriginal != -2 //Chamada via MenuDef
				Help(NIL, NIL, "QIPEST-INCONSISTENTE", NIL, STR0037, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0038})
			EndIf
			Self:lAborta         := .T.
			lHabilitada          := .F.
		ElseIf !Self:lPorApontamento 
			If IsInCallStack("MATA175") .Or. lClickMenu
				//STR0037 - "Inconsistência na implantação da integração SIGAQIP e SIGAEST."
				//STR0049 - "Configure os parâmetros MV_QIPEST e MV_QINSPEC no configurador conforme documentação."
				If Self:nOpcOriginal != -2 //Não é Chamada via MenuDef ou é via Clique no Menu
					Help(NIL, NIL, "QIPEST-POR-APONTAMENTO", NIL, STR0037, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0049})
				EndIf
			EndIf
			Self:lAborta         := .T.
		EndIF
	Else
		Self:lAborta             := .T.
	EndIF

	Self:lIntegracaoEstoqueHabilitada := !Self:lAborta

Return lHabilitada

/*/{Protheus.doc} exibeMensagemDeIntegracaoNaoHabilitada
Exibe mensagem informando que a integração não está habilitada e apresenta o link para documentação
@author rafael.hesse
@since  15/03/2023
/*/
Method exibeMensagemDeIntegracaoNaoHabilitada() CLASS QIPA215Estoque
Local nOpc  := Aviso( STR0041, ; 				//"Baixas do CQ"
				      STR0042; 					//"A integração entre o módulo Inspeção de Processos (SIGAQIP) e o módulo Estoque e Custos (SIGAEST) está desabilitada. "
 					  +CRLF+CRLF+;				// ENTER
					  STR0043,; 				//"Saiba mais no botão 'Documentação'."
					  { STR0044, STR0045 },2, ; // "Ok"  //"Documentação" 
					  STR0046,, '', .F., 0 ) 	// "Integração Não Habilitada (MV_QIPEST)"
  
    If nOpc == 2
        ShellExecute("Open", "https://tdn.totvs.com/pages/viewpage.action?pageId=742224954", "", "", 1)
    Endif
  
Return

/*/{Protheus.doc} validaSePermiteExibicaoBaixasCQ
Avalia se permite exibir a aba Baixas no CQ
@author brunno.costa
@since  24/02/2023
@param 01 - nOpeGot    , numérico, indica a posição do folder destino do clique
@param 02 - nOpeLost   , numérico, indica a posição do folder anterior ao clique
@param 03 - nOpc       , numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
@param 04 - cLaudoGeral, caracter, indica o código do parecer de Laudo Geral da inspeção
@return lPermite, lógico, indica se permite exibir a aba Baixas do CQ
/*/
Method validaSePermiteExibicaoBaixasCQ(nOpeGot, nOpeLost, nOpc, cLaudoGeral) CLASS QIPA215Estoque

	Local lPermite := nOpc == NOPC_VISUALIZACAO .OR. !Empty(cLaudoGeral) //Visualização ou Possui Laudo Geral
	Local dDataFec := Nil
	
	If lPermite
		Self:retornaNumeroCQ() //Chama retornaNumeroCQ para posicionar nos registros relacionados

		If nOpc != NOPC_VISUALIZACAO
			dDataFec := MVUlmes()

			//Verifica se o usuario tem permissao de inclusao no MATA175
			lPermite := self:validaPermissaoDeAcessoLiberacaoMATA175()

			//Verificar data do ultimo fechamento em SX6
			Iif(lPermite .And. !(lPermite := dDatabase > dDataFec), Help( ' ', 1, 'FECHTO'), Nil)

			//Verifica se o saldo do armazem esta bloqueado
			lPermite := (lPermite .And. SldBlqSB2(SD7->D7_PRODUTO,SD7->D7_LOCAL))
		EndIf

		If lPermite
			Self:setaPrivatesTelaEstoqueCQ()
		EndIf
	Else
		//STR0001 - "Não é permitida a realização da movimentação de estoque antes de informar o Laudo Geral."
		//STR0002 - "Informe o Laudo Geral antes de prosseguir."
		Help(NIL, NIL, "SEM-LAUDO-GERAL", NIL, STR0001, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
	EndIf

Return lPermite

/*/{Protheus.doc} validaSePermiteMovimentacaoEstorno
Valida se permite movimentação de Estorno CQ
@author brunno.costa
@since  24/02/2023
@param 01 - nEstorno, numérico, retorna por referência quantidade a estornar
@return lPermite, lógico, indica se permite movimentação de Estorno CQ
/*/
Method validaSePermiteMovimentacaoEstorno(oEstornos) CLASS QIPA215Estoque

	Local aAreaSB8  := {}
	Local aQtd      := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	Local lEstNeg   := (GetMV( 'MV_ESTNEG' ) == 'S' )
	Local lNecessid := .F.
	Local lPermite  := .T.
	Local nSaldoB2  := 0
	Local nSaldoB8  := 0

	dbSelectArea("SB2")
	DbSetOrder(1)
	If dbSeek(xfilial("SB2") + SD7->D7_PRODUTO + SD7->D7_LOCDEST, .T.)
		lNecessid := Localiza(SD7->D7_PRODUTO)
		nSaldoB2  := SaldoMov(lNecessid)
	EndIf

	aQtd     := A175CalcQt(SD7->D7_NUMERO, SD7->D7_PRODUTO, SD7->D7_LOCAL)

	oEstornos[SD7->D7_LOCDEST] := Iif(oEstornos[SD7->D7_LOCDEST] == Nil, 0, oEstornos[SD7->D7_LOCDEST])
	oEstornos[SD7->D7_LOCDEST] += QtdComp(SD7->D7_QTDE)

	//Consiste se existe Quantidade a ser Movimentada
	If Rastro(SD7->D7_PRODUTO)
		aAreaSB8 := SB8->(GetArea())
		dbSelectArea("SB8")
		SB8->(DbSetOrder(3))
		If SB8->(dbSeek(xfilial("SB8")+SD7->D7_PRODUTO+SD7->D7_LOCDEST+SD7->D7_LOTECTL+SD7->D7_NUMLOTE, .T.))
			nSaldoB8 := SB8->B8_SALDO
			If QtdComp(nSaldoB8) < QtdComp(oEstornos[SD7->D7_LOCDEST])
				dbSelectArea('SD3')
				SD3->(DbSetOrder(3))
				nSaldoB8 += Iif(dbseek(xFilial('SD3')+SD7->D7_PRODUTO+SB2->B2_LOCAL+SD7->D7_NUMSEQ+'RE5'), SD3->D3_QUANT, 0)
				lPermite := QtdComp(nSaldoB8) >= QtdComp(oEstornos[SD7->D7_LOCDEST])
				Iif(!lPermite .AND. !lEstNeg, Help(' ',1,'SEMSALDO'), Nil)
			EndIf
		EndIf
		RestArea(aAreaSB8)
	EndIf
	
	//Impede Estorno caso nao exista quantidade Liberada, Rejeitada ou Transferida
	If lPermite 
		lPermite := !(QtdComp( (aQtd[2]-aQtd[4])+(aQtd[3]-aQtd[5])+(aQtd[10]-aQtd[11]) ) == QtdComp(0))
		Iif(!lPermite, Help(' ',1,'A175EST'), lPermite)
	EndIf

	If lPermite .And. QtdComp(nSaldoB2) < QtdComp(oEstornos[SD7->D7_LOCDEST]) .And. !lEstNeg .And. SD7->D7_TIPO == 1
		//Verifica se tem RE5 vinculada a OP e soma no saldo, pois se não foi produzida a OP poderá estornar a RE5
		SD3->(DbSetOrder(3))
		nSaldoB2 += Iif(dbseek(xFilial('SD3')+SD7->D7_PRODUTO+SB2->B2_LOCAL+SD7->D7_NUMSEQ+'RE5'), SD3->D3_QUANT, 0)
		lPermite := !(QtdComp(nSaldoB2) < QtdComp(oEstornos[SD7->D7_LOCDEST]))
		Iif(!lPermite, Help(' ',1,'SEMSALDO'), lPermite)
	EndIf

	//Valida se permite movimentação de Estorno no MATA175
	lPermite := Iif(lPermite, self:validaPermissaoDeAcessoEstornoMATA175(), Nil)

Return lPermite

/*/{Protheus.doc} inicializaPorApontamento
Inicializa classe QIPA215Estoque por Apontamento de Producao
@author brunno.costa
@since  24/02/2023
@param 01 - nOpc, numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
/*/
Method inicializaPorApontamento(nOpc) CLASS QIPA215Estoque
	
	Local aColsAux  := {}

	Self:aHeader        := aClone(Self:montaAHeaderSD7Generic())
	Self:aQuantidadesCQ := { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	Self:cArquivoCQ     := ""
	Self:cDiretorioCQ   := AllTrim(GetMV( 'MV_DIRCQ' ))
	aColsAux            := Self:preencheMovimentoCQ(QPK->(Recno()), nOpc)
	Self:aCols          := If(Empty(aColsAux), {}, aColsAux)
	Self:setaPrivatesTelaEstoqueCQ()
	If Self:validaSeEhExecucaoViaMenuQIPA215() .OR. Self:validaSeEhExecucaoComTelaResultadosQIPA215()
		Self:setaTituloPorApontamento(nOpc)
	EndIf

Return

/*/{Protheus.doc} montaAHeaderSD7Generic
Monta e retornar aHeader
@author brunno.costa
@since  24/02/2023
@return aHeader, array, array genérico para utilização da SD7 em grid
/*/
Method montaAHeaderSD7Generic() CLASS QIPA215Estoque
	
	Local cAlias := "SD7"
	Local cSeek  := ''
	Local cWhile := ''
	Local nOpcx  := 3

	Private aHeader := {}

	FillGetDados(	nOpcx,; 								// numero correspondente à operação a ser executada, exemplo: 3 - inclusão, 4 alteração e etc;
					cAlias,;       							// area a ser utilizada;
					1,;      								// nOrdem - ordem correspondente a chave de índice para preencher o  acols;
					Iif((nOpcx == 3),'',&cSeek),;  			// chave utilizada no posicionamento da área para preencher o acols; 
					{|| &cWhile},; 							// bloco contendo a expressão a ser comparada com cSeekKey na condição  do While. 
					{|| .T.},;  							// uSeekFor
					,;  						 			// aNoFields - array contendo os campos que não estarao no aHeader;
					,;  									// aYesFields - array contendo somente os campos que estarao no aHeader;
					.F.,;      								// se verdadeiro, exibe apenas os campos de usuário;
					'',;      								// cQuery - query a ser executada para preencher o acols;
					,;    				   					// bloco contendo funcao especifica para preencher o aCols; 
					Iif((nOpcx == 3),.T.,.F.),;  			// lEmpty 
					,; 										// aHeaderAux
					,; 		   								// aColsAux
					,; 										// bAfterCols
					,; 										// bBeforeCols
					,; 										// bAfterHeader
					'') 									// cAliasQry
Return aHeader

/*/{Protheus.doc} validaLiberacaoDeCQ
Valida Liberação da Movimentação de CQ
@author brunno.costa
@since  24/02/2023
@param 01 - nOpc, numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
@return lValido, lógico, indica se os dados da grid de Baixas do CQ estão válidos para salvar
/*/
Method validaLiberacaoDeCQ(nOpc) CLASS QIPA215Estoque
	Local lValido := .T.
	If Self:lPorApontamento .AND. !Self:lAborta
		Self:setaPrivatesTelaEstoqueCQ()
		lValido := Self:oMsGetDados:TudoOk()
	EndIf
Return lValido

/*/{Protheus.doc} validaNecessidadeEMovimentaEstoqueCQAutomaticamente
Valida necessidade e movimenta Estoque CQ Automaticamente
@author brunno.costa
@since  24/02/2023
@param 01 - nOpc       , numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
@param 02 - cLaudoGeral, caracter, parecer do laudo geral
@return lVoltar, lógico, indica se deseja voltar para tela de edição de resultados
/*/
Method validaNecessidadeEMovimentaEstoqueCQAutomaticamente(nOpc, cLaudoGeral) CLASS QIPA215Estoque

	Local cMensagem := ""
	Local lPermite  := .T.
	Local lVoltar   := .F.
	Local nAviso    := 1
	Local nTimer    := 0 //120000

	If cLaudoGeral == NIL
		Self:atribuiDadosLaudoGeral(, , , @cLaudoGeral)
	EndIf

	If !lEstorno
		If self:validaSeEhExecucaoComTelaResultadosQIPA215()
			lPermite := self:validaPermissaoDeAcessoLiberacaoMATA175(.F.)
		Else
			lPermite := self:validaPermissaoDeAcessoLiberacaoMATA175()
			lVoltar  := Iif(!lPermite, .T., lVoltar)
		EndIf

		If  lPermite .And. Self:lPorApontamento .And. !Self:lAborta .And. !Empty(cLaudoGeral) .And. nOpc == 3 .And. Self:possuiPendenciaMovimentacaoEstoqueCQ()
			
			//STR0028 - "- Retornar: volta para a tela de resultados e continua editando."
			//STR0029 - "- Não: a inspeção será gravada sem movimentação do estoque em CQ."
			//STR0030 - "- Sim: a inspeção será concluída com movimentação do estoque CQ criada automaticamente."
			cMensagem += STR0028 + CRLF + CRLF
			cMensagem += STR0029 + CRLF + CRLF
			cMensagem += STR0030

			//STR0031 - "Integração Inspeção de Processos x Estoque e Custos"
			//STR0032 - "Não"
			//STR0033 - "Retornar"
			//STR0034 - "Sim"
			//STR0035 - "Deseja movimentar as Pendências do Estoque em CQ Automaticamente?"
			nAviso := Aviso( STR0031, cMensagem, { STR0032, STR0033, STR0034 }, 2,  STR0035,,'', .F., nTimer )
			
			If nAviso == 2
				lVoltar := .T.
			
			ElseIf nAviso == 3
				Self:movimentaPendenciasEstoqueCQAutomaticamente(QPL->(Recno()), .T.)
				Self:atualizaTotalizadoresPorArray()
			
			Endif
		ElseIf lPermite .And. Self:lPorApontamento .And. !Self:lAborta .And. !Empty(cLaudoGeral) .And. nOpc == 3
			oSelf:atualizaTotalizadoresPorArray()
		EndIf
	EndIf

Return lVoltar

/*/{Protheus.doc} movimentaPendenciasEstoqueCQAutomaticamente
Movimenta Pendências de Estoque CQ Automaticamente
@author brunno.costa
@since  01/03/2023
@param 01 - nRecnoQPK, numérico, obrigatório - recno de referência da QPK para movimentação
/*/
Method movimentaPendenciasEstoqueCQAutomaticamente(nRecnoQPK) CLASS QIPA215Estoque
	
	Local aArea      := GetArea()
	Local aAreaQPK   := QPK->(GetArea())
	Local lSucesso   := .F.
	Local oLaudo         := Nil
	Local oLaudosEnsaios := QIPLaudosEnsaios():New()

	If Self:validaSeEhExecucaoViaMenuQIPA215() .OR. Self:validaSeEhExecucaoComTelaResultadosQIPA215()
		Self:aCols := aCols
		lSucesso := Self:movimentaPendenciasEstoqueCQAutomaticamenteQIPA215()
	Else
		oLaudo       := oLaudosEnsaios:RetornaLaudoGeral(nRecnoQPK)
		If oLaudo['hasReport']
			lSucesso := Self:movimentaPendenciasEstoqueCQAutomaticamenteIndependente(nRecnoQPK)
		Else
			//STR0001 - "Não é permitida a realização da movimentação de estoque antes de informar o Laudo Geral."
			//STR0002 - "Informe o Laudo Geral antes de prosseguir."
			Help(NIL, NIL, "SEM-LAUDO-GERAL", NIL, STR0001, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
		EndIf	
	EndIf

	RestArea(aAreaQPK)
	RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} movimentaPendenciasEstoqueCQAutomaticamenteQIPA215
Movimenta Pendências de Estoque CQ Automaticamente via QIPA215
@author brunno.costa
@since  01/03/2023 
/*/
Method movimentaPendenciasEstoqueCQAutomaticamenteQIPA215() CLASS QIPA215Estoque
	Self:atualizaTotalizadoresPorArray()
	Self:completaMovimentoCQAutomaticamenteEmArray()
Return .T.

/*/{Protheus.doc} movimentaPendenciasEstoqueCQAutomaticamenteIndependente
Movimenta Pendências de Estoque CQ Automaticamente Independente de Tela
@author brunno.costa
@since  01/03/2023
@param 01 - nRecnoQPK, numérico, obrigatório - recno de referência da QPK para movimentação
/*/
Method movimentaPendenciasEstoqueCQAutomaticamenteIndependente(nRecnoQPK) CLASS QIPA215Estoque
	
	Local nOpc       := 3
	Local lSucesso   := .T.

	Self:lAborta  := .F.
	If Self:integracaoHabilitada() .AND. Self:lPorApontamento
		//Declaração de variáveis utilizadas pela integração com MATA175 - Inicio
		Private aCols           := {}
		Private aHeader         := {}
		Private aHeaderPro      := {}
		Private cA175Chave      := Nil
		Private cA175Loc        := Nil
		Private cA175LotCt      := Nil
		Private cA175LoteC      := Nil
		Private cA175Num        := Nil
		Private cA175OrigL      := Nil
		Private cA175Prod       := Nil
		Private cA175UM         := Nil
		Private cDirCQ          := AllTrim(GetMV( 'MV_DIRCQ' ))
		Private lEstNeg         := (GetMV( 'MV_ESTNEG' )== 'S' )
		Private lEstorno        := .F.
		Private n               := 1
		Private nAColsIni       := 0
		Private nCQPosData      := 0
		Private nCQPosEsto      := 0
		Private nCQPosLDes      := 0
		Private nCQPosMRej      := 0
		Private nCQPosNSeq      := 0
		Private nCQPosObs       := 0
		Private nCQPosQtd2      := 0
		Private nCQPosQtde      := 0
		Private nPosDesc        := 0
		Private nPosDtVld       := 0
		Private nPosEstrut      := 0
		Private nPosLocDest     := 0
		Private nPosLocLz       := 0
		Private nPosNuMSer      := 0
		Private nPosSeq         := 0
		Private nPosService     := 0
		Private nPosTipo        := 0
		Private nPotenc175      := Nil
		Private nPotencOri      := Nil
		Private oQIPA215Estoque := Nil
		Private oQtdLiber       := Nil
		Private oQtdOrig        := Nil
		Private oQtdRejei       := Nil
		Private oQtdSaldo       := Nil
		//Declaração de variáveis utilizadas pela integração com MATA175 - Fim

		QPK->(DbGoTo(nRecnoQPK))
		
		Self:aCols    := {}
		Self:aHeader  := {}
		Self:cTexto   := ""

		Self:inicializaPorApontamento(nOpc)
		Self:atualizaTotalizadoresPorArray()
		nAColsIni := Len(aCols)
		If Self:possuiPendenciaMovimentacaoEstoqueCQ()
			If self:validaPermissaoDeAcessoLiberacaoMATA175()
				Self:completaMovimentoCQAutomaticamenteEmArray()
				Self:setaPrivatesTelaEstoqueCQ()
				lSucesso := Self:gravaResultados(nOpc,.F.)
			Else
				lSucesso := .F.
				Break
			EndIf
		EndIf

	EndIf
Return lSucesso

/*/{Protheus.doc} estornaTodosMovimentosDeCQ
Função responsável por estornar todos os movimentos de CQ
@author brunno.costa
@since  07/03/2023
@param 01 - nRecnoQPK, numérico, indica o RECNO do registro da QPK relacionado
@param 02 - lTemMovi, lógico, indica se a inspeção tem movimentação CQ ou não
@return lSucesso, lógico, indica se consegui estornar todos os movimentos do Estoque de CQ
/*/
Method estornaTodosMovimentosDeCQ(nRecnoQPK, lTemMovi) CLASS QIPA215Estoque
	Local nOpc     := 3
	Local lSucesso := .F.

	Default lTemMovi := .F.

	Self:lAborta   := .F.
	If Self:integracaoHabilitada() .AND. Self:lPorApontamento
		//Declaração de variáveis utilizadas pela integração com MATA175 - Inicio
		Private aCols           := {}
		Private aHeader         := {}
		Private aHeaderPro      := {}
		Private cA175Chave      := Nil
		Private cA175Loc        := Nil
		Private cA175LotCt      := Nil
		Private cA175LoteC      := Nil
		Private cA175Num        := Nil
		Private cA175OrigL      := Nil
		Private cA175Prod       := Nil
		Private cA175UM         := Nil
		Private cDirCQ          := AllTrim(GetMV( 'MV_DIRCQ' ))
		Private lEstNeg         := (GetMV( 'MV_ESTNEG' )== 'S' )
		Private lEstorno        := .T.
		Private n               := 1
		Private nAColsIni       := 0
		Private nCQPosData      := 0
		Private nCQPosEsto      := 0
		Private nCQPosLDes      := 0
		Private nCQPosMRej      := 0
		Private nCQPosNSeq      := 0
		Private nCQPosObs       := 0
		Private nCQPosQtd2      := 0
		Private nCQPosQtde      := 0
		Private nPosDesc        := 0
		Private nPosDtVld       := 0
		Private nPosEstrut      := 0
		Private nPosLocDest     := 0
		Private nPosLocLz       := 0
		Private nPosNuMSer      := 0
		Private nPosSeq         := 0
		Private nPosService     := 0
		Private nPosTipo        := 0
		Private nPotenc175      := Nil
		Private nPotencOri      := Nil
		Private oQIPA215Estoque := Nil
		Private oQtdLiber       := Nil
		Private oQtdOrig        := Nil
		Private oQtdRejei       := Nil
		Private oQtdSaldo       := Nil
		//Declaração de variáveis utilizadas pela integração com MATA175 - Fim

		QPK->(DbGoTo(nRecnoQPK))
		
		Self:aCols    := {}
		Self:aHeader  := {}
		Self:cTexto   := ""

		Self:inicializaPorApontamento(nOpc)
		Self:atualizaTotalizadoresPorArray()
		nAColsIni := Len(aCols)
		If nAColsIni > 0 .AND. Self:possuiMovimentacaoEstoqueCQ()
			lTemMovi := .T.
			lSucesso := Self:marcaTodosOsEstornosNoArray()
			If lSucesso
				Self:setaPrivatesTelaEstoqueCQ()
				lSucesso := Self:gravaResultados(nOpc,.F.)
			EndIf
		EndIf

	EndIf
Return lSucesso

/*/{Protheus.doc} marcaTodosOsEstornosNoArray
Marca todos os Estornos no Array
@author brunno.costa
@since  24/02/2023
/*/
Method marcaTodosOsEstornosNoArray() CLASS QIPA215Estoque

	Local aArea     := GetArea()
	Local aAreaD7   := SD7->(GetArea())
	Local lSucesso  := .T.
	Local nIndItem  := 0
	Local nPosEST   := aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_ESTORNO"})
	Local nPosRec   := aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_REC_WT"})
	Local nTotal    := Len(Self:aCols)
	Local oEstornos := JsonObject():New()
	
	nPosTipo   := Iif(nPosTipo == 0  , aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_TIPO"}), nPosTipo  )

	For nIndItem := 1 to nTotal
		If Empty(Self:aCols[nIndItem, nPosEST]) .AND. Self:aCols[nIndItem, nPosTipo] != 0
			Self:aCols[nIndItem, nPosEST] := "X"
			aCols                         := Self:aCols
			n                             := nIndItem
			SD7->(DbGoTo(Self:aCols[nIndItem, nPosRec]))
			Self:aCols[nIndItem, nPosEST] := IIf(A175LinOk() .AND. Self:validaSePermiteMovimentacaoEstorno(@oEstornos), "X", " ")
			lSucesso                      := !Empty(Self:aCols[nIndItem, nPosEST])
			If !lSucesso
				Exit
			EndIf
		EndIf
	Next

	RestArea(aAreaD7)
	RestArea(aArea)
	
Return lSucesso

/*/{Protheus.doc} possuiPendenciaMovimentacaoEstoqueCQComSeek
Avalia se possui pendencia de movimentação de estoque CQ com Seek no banco
@author brunno.costa
@since  01/03/2023
@param 01 - nRecnoQPK, numérico, obrigatório - recno de referência da QPK para movimentação
@return lPossui, lógico, indica se possui pendencia de movimentação de estoque CQ com Seek no banco
/*/
Method possuiPendenciaMovimentacaoEstoqueCQComSeek(nRecnoQPK) CLASS QIPA215Estoque
	Local lPossui := .F.
	Self:lAborta  := .F.
	If Self:integracaoHabilitada() .AND. Self:lPorApontamento
		QPK->(DbGoTo(nRecnoQPK))
		If Self:validaSeEhExecucaoViaMenuQIPA215() .OR. Self:validaSeEhExecucaoComTelaResultadosQIPA215()
			lPossui := Self:possuiPendenciaMovimentacaoEstoqueCQComSeekQIPA215(nRecnoQPK)
		Else
			lPossui := Self:possuiPendenciaMovimentacaoEstoqueCQComSeekIndependente(nRecnoQPK)
		EndIf
	EndIf
Return lPossui

/*/{Protheus.doc} possuiPendenciaMovimentacaoEstoqueCQComSeekIndependente
Avalia se possui pendencia de movimentação de estoque CQ com Seek no banco
@author brunno.costa, rafael.hesse
@since  29/03/2023
@param 01 - nRecnoQPK, numérico, obrigatório - recno de referência da QPK para movimentação
@return lPossui, lógico, indica se possui pendencia de movimentação de estoque CQ com Seek no banco
/*/
Method possuiPendenciaMovimentacaoEstoqueCQComSeekIndependente(nRecnoQPK) CLASS QIPA215Estoque
	Local lPossui := .F.
	//Declaração de variáveis utilizadas pela integração com MATA175 - Inicio
	Private aCols           := {}
	Private aHeader         := {}
	Private aHeaderPro      := {}
	Private cA175Chave      := Nil
	Private cA175Loc        := Nil
	Private cA175LotCt      := Nil
	Private cA175LoteC      := Nil
	Private cA175Num        := Nil
	Private cA175OrigL      := Nil
	Private cA175Prod       := Nil
	Private cA175UM         := Nil
	Private cDirCQ          := AllTrim(GetMV( 'MV_DIRCQ' ))
	Private lEstNeg         := (GetMV( 'MV_ESTNEG' )== 'S' )
	Private lEstorno        := .F.
	Private n               := 1
	Private nAColsIni       := 0
	Private nCQPosData      := 0
	Private nCQPosEsto      := 0
	Private nCQPosLDes      := 0
	Private nCQPosMRej      := 0
	Private nCQPosNSeq      := 0
	Private nCQPosObs       := 0
	Private nCQPosQtd2      := 0
	Private nCQPosQtde      := 0
	Private nPosDesc        := 0
	Private nPosDtVld       := 0
	Private nPosEstrut      := 0
	Private nPosLocDest     := 0
	Private nPosLocLz       := 0
	Private nPosNuMSer      := 0
	Private nPosSeq         := 0
	Private nPosService     := 0
	Private nPosTipo        := 0
	Private nPotenc175      := Nil
	Private nPotencOri      := Nil
	Private oQIPA215Estoque := Nil
	Private oQtdLiber       := Nil
	Private oQtdOrig        := Nil
	Private oQtdRejei       := Nil
	Private oQtdSaldo       := Nil
	//Declaração de variáveis utilizadas pela integração com MATA175 - Fim

	Self:aCols    := {}
	Self:aHeader  := {}
	Self:cTexto   := ""

	Self:atualizaTotalizadoresPorArray()
	nAColsIni := Len(aCols)
	lPossui := Self:possuiPendenciaMovimentacaoEstoqueCQ()

Return lPossui

/*/{Protheus.doc} possuiPendenciaMovimentacaoEstoqueCQComSeekQIPA215
Avalia se possui pendencia de movimentação de estoque CQ com Seek no banco
@author brunno.costa, rafael.hesse
@since  29/03/2023
@param 01 - nRecnoQPK, numérico, obrigatório - recno de referência da QPK para movimentação
@return lPossui, lógico, indica se possui pendencia de movimentação de estoque CQ com Seek no banco
/*/
Method possuiPendenciaMovimentacaoEstoqueCQComSeekQIPA215(nRecnoQPK) CLASS QIPA215Estoque
	Local lPossui := .F.
	Self:atualizaTotalizadoresPorArray()
	lPossui := Self:possuiPendenciaMovimentacaoEstoqueCQ()
Return lPossui

/*/{Protheus.doc} completaMovimentoCQAutomaticamenteEmArray
Completa Movimento CQ Automaticamente em Array de Movimento
@author brunno.costa
@since  01/03/2023
/*/
Method completaMovimentoCQAutomaticamenteEmArray() CLASS QIPA215Estoque

	Local cLocAprov   := SuperGetMV("MV_CQLIBER", .F., "")
	Local cLocPe      := ""
	Local cLocRejei   := SuperGetMV("MV_CQREJEI", .F., "97")
	Local nCQPosQtd2  := aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_QTSEGUM"})
	Local nCQPosQtde  := aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_QTDE" })
	Local nLiberar    := 0
	Local nLiberEst   := 0
	Local nLiberLaudo := 0
	Local nPosMemo    := aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_OBS" })
	Local nPosSaldo   := aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_SALDO" })
	Local nRejeitar   := 0
	Local nRejEst     := 0
	Local nRejLaudo   := 0
	Local nSaldo      := 0

	Self:atribuiDadosLaudoGeral(@nRejLaudo, @nLiberLaudo)

	nRejEst     := Self:aQuantidadesCQ[3] - Self:aQuantidadesCQ[5]
	nLiberEst   := Self:aQuantidadesCQ[2] - Self:aQuantidadesCQ[4]
	nSaldo      := Self:aQuantidadesCQ[6]

	nLiberar    := nLiberLaudo - nLiberEst
	nRejeitar   := nRejLaudo   - nRejEst

	If nLiberar > 0
		cLocAprov  := Iif(Empty(cLocAprov), RetFldProd(QPK->QPK_PRODUT,"B1_LOCPAD"), cLocAprov)
		cLocAprov  := Iif(Empty(cLocAprov), "01"                                   , cLocAprov)
		Self:aCols := Self:adicionaItemMovimentoDefault(Self:aCols, Len(Self:aHeader), .T.)
		nIndItem                         := Len(Self:aCols)
		n                                := nIndItem
		nSaldo                           -= nLiberar
		Self:aCols[nIndItem, nPosTipo]   := 1
		Self:aCols[nIndItem, nPosSaldo]  := nSaldo
		Self:aCols[nIndItem, nCQPosQtde] := nLiberar
		Self:aCols[nIndItem, nCQPosQtd2] := ConvUm(QPK->QPK_PRODUT,nLiberar,,2)
		Self:aCols[nIndItem, nPosMemo]   := STR0039 //"Liberação de estoque automática durante liberação do Laudo Geral"

		If ExistBlock("A175ALMO")
            cLocPe := ExecBlock("A175ALMO",.F.,.F.,{cLocAprov})
            If ValType(cLocPe) == 'C'
                cLocAprov := cLocPe
            EndIf
        EndIf

		Self:aCols[nIndItem, nCQPosLDes] := cLocAprov
	EndIf

	If nRejeitar > 0
		cLocRejei  := Iif(Empty(cLocRejei), "97", cLocRejei)
		Self:aCols := Self:adicionaItemMovimentoDefault(Self:aCols, Len(Self:aHeader), .T.)
		nIndItem                         := Len(Self:aCols)
		n                                := nIndItem
		nSaldo                           -= nRejeitar
		Self:aCols[nIndItem, nPosTipo]   := 2
		Self:aCols[nIndItem, nPosSaldo]  := nSaldo
		Self:aCols[nIndItem, nCQPosQtde] := nRejeitar
		Self:aCols[nIndItem, nCQPosQtd2] := ConvUm(QPK->QPK_PRODUT,nRejeitar,,2)
		Self:aCols[nIndItem, nPosMemo]   := STR0040 //"Rejeição de estoque automática durante liberação do Laudo Geral"

		If ExistBlock("A175ALMO")
            cLocPe := ExecBlock("A175ALMO",.F.,.F.,{cLocRejei})
            If ValType(cLocPe) == 'C'
                cLocRejei := cLocPe
            EndIf
        EndIf

		Self:aCols[nIndItem, nCQPosLDes] := cLocRejei
	EndIf
	
	Self:setaPrivatesTelaEstoqueCQ()

Return

/*/{Protheus.doc} atribuiDadosLaudoGeral
Atribui Quantidades e laudo Relacionadas ao Laudo Geral
@author rafael.hesse
@since  28/03/2023
@param 01 - nRejLaudo  , numérico, retorna por referência a quantidade rejeitada no Laudo Geral (Rejeição)
@param 02 - nLiberLaudo, numérico, retorna por referência a quantidade Tamanho do Lote - Rejeição
@param 03 - nTamLote   , numérico, retorna por referência a quantidade do tamanho do lote
@param 04 - cLaudoGeral, Caracter, retorna por referência o laudo geral.
/*/
Method atribuiDadosLaudoGeral(nRejLaudo, nLiberLaudo, nTamLote, cLaudoGeral) CLASS QIPA215Estoque

	Local aAreaQPL   := Nil
	Local cFiLQPL    := Nil
	Local nPosRej    := Nil
	Local nPosTamLot := Nil

	Default nLiberLaudo := 0
	Default nRejLaudo   := 0
	Default nTamLote    := 0

	If Self:validaSeEhExecucaoComTelaResultadosQIPA215()
		nPosRej     := Iif(lLayout, QP215GetLau(aSavGets[nFldLauGer],"QPL_QTREJ") , QP215GetLau(aSavGets[1,2],"QPL_QTREJ"))
		nPosTamLot  := Iif(lLayout, QP215GetLau(aSavGets[nFldLauGer],"QPL_TAMLOT"), QP215GetLau(aSavGets[1,2],"QPL_TAMLOT"))
		nRejLaudo   := Val(aResultados[nFldLauGer, 1, nPosRej])                //Val(M->QPL_QTREJ)
		nTamLote    := Val(aResultados[nFldLauGer, 1, nPosTamLot])             //Val(M->QPL_TAMLOT)
		nLiberLaudo := nTamLote - nRejLaudo                                    //Val(M->QPL_TAMLOT) - Val(M->QPL_QTREJ)
	Else
		aAreaQPL := QPL->(GetArea())
		cFiLQPL  := xFilial("QPL")
		dbSelectArea("QPL")
		QPL->(dbSetOrder(3))
		If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)))
			While cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER) == QPL->(QPL_FILIAL+QPL_OP+QPL_LOTE+QPL_NUMSER)
				If Empty(QPL->QPL_OPERAC) .And. Empty(QPL->QPL_LABOR)
					nRejLaudo   := Val(QPL->QPL_QTREJ)
					nTamLote    := Val(QPL->QPL_TAMLOT)
					nLiberLaudo := nTamLote - nRejLaudo
					cLaudoGeral := QPL->QPL_LAUDO
					Exit
				EndIf
			EndDo
		EndIf
		RestArea(aAreaQPL)
	EndIf

Return

/*/{Protheus.doc} adicionaItemMovimentoDefault
Adiciona no Array recebido e retorna array com linha de movimento de estoque CQ Default
@author brunno.costa
@since  01/03/2023
@param 01 - aColsAux , array   , aCols com os dados de referência para adição do novo item
@param 02 - nUsado   , numérico, quantidade de colunas usadas por padrão e exibidas em tela (tamanho do aHeader)
@param 03 - lNovo    , lógico  , indica se deve inicializar o campo para novo registro (.T.) ou com base em registro posicionado da SD7 (.F.)
@return aColsAux, array, array com a nova linha adicionada
/*/
Method adicionaItemMovimentoDefault(aColsAux, nUsado, lNovo) CLASS QIPA215Estoque
	
	Local cAcha      := ''
	Local cCampo     := ""
	Local cDescricao := ""
	Local cTipoExib  := ""
	Local nIndCpo    := 0
	Local nPosA      := 0
	Local nPosZ      := 0

	Default lNovo  := .F.

	Aadd(aColsAux, Array(nUsado+1))          
	For nIndCpo := 1 To Len(Self:aHeader) 

		cTipoExib := Self:aHeader[nIndCpo, 10]
		cCampo    := AllTrim(Self:aHeader[nIndCpo, 02])

		If cTipoExib <> 'V'

			If lNovo
				aColsAux[Len(aColsAux),nIndCpo] := CriaVar(cCampo)
			Else	
				aColsAux[Len(aColsAux),nIndCpo] := &('SD7->'+cCampo)
			EndIf
			

		ElseIf cTipoExib == 'V'

			If IsHeadRec(cCampo)
				aColsAux[Len(aColsAux),nIndCpo] := SD7->(RecNo())
			ElseIf cCampo == "D7_ALI_WT"
				aColsAux[Len(aColsAux),nIndCpo] := 'SD7'	
			Else    	
				aColsAux[Len(aColsAux),nIndCpo] := CriaVar(cCampo)
			EndIf

			//Adiciona a Descricao do Tipo de Movimentacao no CQ
			If cCampo == 'D7_DESCRT'

				cDescricao := ""
				cDescricao := Iif(                         SD7->D7_TIPO  == 0, OemToAnsi(STR0017), cDescricao) //'Qtd Original'
				cDescricao := Iif( Empty(cDescricao) .AND. SD7->D7_TIPO  == 1, OemToAnsi(STR0018), cDescricao) //'Liberado'
				cDescricao := Iif( Empty(cDescricao) .AND. SD7->D7_TIPO  == 2, OemToAnsi(STR0019), cDescricao) //'Rejeitado'
				cDescricao := Iif( Empty(cDescricao) .AND. SD7->D7_TIPO  == 3, OemToAnsi(STR0020), cDescricao) //'Devolucao Liberacao'
				cDescricao := Iif( Empty(cDescricao) .AND. SD7->D7_TIPO  == 4, OemToAnsi(STR0021), cDescricao) //'Devolucao Rejeicao'
				cDescricao := Iif( Empty(cDescricao) .AND. SD7->D7_TIPO  == 6, OemToAnsi(STR0022), cDescricao) //'Estorno Liberacao'
				cDescricao := Iif( Empty(cDescricao) .AND. SD7->D7_TIPO  == 7, OemToAnsi(STR0023), cDescricao) //'Estorno Rejeicao'
				cDescricao := Iif( Empty(cDescricao) .AND. SD7->D7_TIPO  == 8, OemToAnsi(STR0024), cDescricao) //'Despesas Agregadas'
				cDescricao := Iif( Empty(cDescricao) .AND. SD7->D7_TIPO  == 9, OemToAnsi(STR0025), cDescricao) //'Estorno Despesas'
				aColsAux[Len(aColsAux), nIndCpo] := cDescricao

			//Adiciona a Descricao do Motivo da Rejeicao ao aColsAux
			ElseIf Upper(cCampo) == 'D7_DESCREJ'

				aColsAux[Len(aColsAux),nIndCpo] := Iif(SX5->(dbSeek(xFilial('SX5')+'43'+SD7->D7_MOTREJE,.F.)),;
													Left(X5Descri(), 35),;
													aColsAux[Len(aColsAux),nIndCpo])

				aColsAux[Len(aColsAux),nIndCpo] := Iif(CYO->(dbSeek(xFilial("CYO")+SD7->D7_MOTREJE,.F.)),;
													AllTRim(CYO->CYO_DSRF),;
													aColsAux[Len(aColsAux),nIndCpo])

			//Adiciona a Observacao ao aColsAux
			ElseIf cCampo == 'D7_OBS'

				cAcha := OemToAnsi('[' + STR0026 +':')+Str(SD7->D7_TIPO,1)+OemToAnsi('/' + STR0027 +':')+SD7->D7_SEQ+OemToAnsi('/A]')  //'[TIPO:' ### '/SEQ:' ### '/A]'
				nPosA := At(cAcha, Self:cTexto)
				cAcha := OemToAnsi('[' + STR0026 +':')+Str(SD7->D7_TIPO,1)+OemToAnsi('/' + STR0027 +':')+SD7->D7_SEQ+OemtoAnsi('/Z]') //'[TIPO:' ### '/SEQ:' ### '/Z]'
				nPosZ := At(cAcha, Self:cTexto)
				aColsAux[Len(aColsAux),nIndCpo] := If(nPosA>0.And.nPosZ>0, SubStr(Self:cTexto,nPosA+20,nPosZ-nPosA-21),' ')

			EndIf

		EndIf
	
		If !Empty(GetSx3Cache(cCampo,"X3_CAMPO"))
			Aadd(aHeaderPro,{ GetSx3Cache(cCampo,"X3_CAMPO") ,;
							  GetSx3Cache(cCampo,"X3_PROPRI")})
		EndIf	

	Next
	aColsAux[Len(aColsAux), nUsado+1] := .F.

Return aColsAux

/*/{Protheus.doc} setaPrivatesTelaEstoqueCQ
Seta variáveis privates genéricas da tela de Baixas do CQ
@author brunno.costa
@since  24/02/2023
/*/
Method setaPrivatesTelaEstoqueCQ() CLASS QIPA215Estoque //Q215SetLab
	Self:nBackup       := Iif(Self:nBackup       == Nil .And. Type("n")       != "U", n      , Self:nBackup      )
	Self:aHeaderBackup := Iif(Self:aHeaderBackup == Nil .And. Type("aHeader") != "U", aHeader, Self:aHeaderBackup)
	Self:aColsBackup   := Iif(Self:aColsBackup   == Nil .And. Type("aCols")   != "U", aCols  , Self:aColsBackup  )
	n                  := Iif(Self:oMsGetDados   == Nil, 1                                   , Self:oMsGetDados:oBrowse:nAt)
	aHeader            := Self:aHeader
	aCols              := Self:aCols
Return

/*/{Protheus.doc} setaPrivatesBackup
Restaura variáveis privates genéricas anteriores a chamada de setaPrivatesTelaEstoqueCQ()
@author brunno.costa
@since  24/02/2023
/*/
Method setaPrivatesBackup() CLASS QIPA215Estoque //Q215SetLab
	Self:oMsGetDados:oBrowse:nAt := n
	Self:aHeader                 := aHeader
	Self:aCols                   := aCols
	n                            := Self:nBackup
	aHeader                      := Self:aHeaderBackup
	aCols                        := Self:aColsBackup
Return

/*/{Protheus.doc} montaTelaEstoqueCQ
Monta Tela para Exibição Baixas do CQ
@author brunno.costa
@since  24/02/2023
@param 01 - oDlg, objeto  , local para exibição da tela Baixas do CQ
@param 02 - nOpc, numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
/*/
Method montaTelaEstoqueCQ(oDlg, nOpc)  CLASS QIPA215Estoque
	If Self:lPorApontamento .AND. !Self:lAborta
		Self:montaTelaEstoqueCQPorApontamento(oDlg, nOpc)
	EndIf
Return

/*/{Protheus.doc} montaTelaEstoqueCQMenu
Monta Tela para Exibição Baixas do CQ via Menu
@author brunno.costa, rafael.hesse
@since  29/03/2023
@param 01 - nOpc, numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
/*/
Method montaTelaEstoqueCQMenu(nOpc)  CLASS QIPA215Estoque

    Local aBotoes	    := {}         //Variável onde será incluido o botão para a legenda
	Local aSize         := MsAdvSize()

	Private oDlg        := Nil 
	Private cTitulo     := Self:cTitulo
	Private oPanel1     := Nil

	If Self:lPorApontamento .AND. !Self:lAborta
		oDlg := TDialog():New(0,0,aSize[6],aSize[5],Self:cTitulo,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

		Self:montaTelaEstoqueCQPorApontamento(oDlg, nOpc)
		Self:setaPrivatesTelaEstoqueCQ()

		//Alinho o grid para ocupar todo o meu formulário
		Self:oMsGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


		EnchoiceBar(oDlg, {|| Iif(Self:validaLiberacaoDeCQ(nOpc);
		                      .And. !Self:validaNecessidadeEMovimentaEstoqueCQAutomaticamente(nOpc);
							  .And. Self:gravaResultados(nOpc,.T.);
							  .And. Self:atualizaQPKSITOPPosBaixaMenu(), oDlg:End(), .F.) }, {|| oDlg:End() }, .F., aBotoes)

		oDlg:Activate()
	EndIf

Return(NIL)

/*/{Protheus.doc} montaTelaEstoqueCQPorApontamento
Monta Tela para Exibição Baixas do CQ por Apontamento de Produção
@author brunno.costa
@since  24/02/2023
@param 01 - oDlg, objeto  , local para exibição da tela da tela Baixas do CQ
@param 02 - nOpc, numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
/*/
Method montaTelaEstoqueCQPorApontamento(oDlg, nOpc) CLASS QIPA215Estoque

	Local nLib     := 0
	Local nRej     := 0
	Local oBodyLyt := Nil
	Local oPanel2  := Nil
	Local oPanel3  := Nil

	Self:inicializaPrivatesMATA175()

	//Inicializa variaveis
	aHeader   := Self:aHeader
	nUsado    := Len(aHeader)    
	aCols     := Self:aCols
	N 	   	  := 1
	nAColsIni := Len(aCols)

	nLib := (Self:aQuantidadesCQ[2]-Self:aQuantidadesCQ[4])
	nRej := (Self:aQuantidadesCQ[3]-Self:aQuantidadesCQ[5])

	//Posiciona o codigo do Produto para exibir a Descricao
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial('SB1')+QPK->QPK_PRODUT,.F.))

	oBodyLyt := tLinearLayout():New(oDlg, 2, CONTROL_ALIGN_ALLCLIENT, oDlg:nClientWidth, oDlg:nClientHeight)

	oPanel1 := tPanel():New(0,0,,oBodyLyt,,.T.,,,,0,0)
	oPanel2 := tPanel():New(0,0,,oBodyLyt,,.T.,,,,0,0)

	If Self:validaSeEhExecucaoViaMenuQIPA215()
		oPanel3 := tPanel():New(0,0,,oBodyLyt,,.T.,,,,0,0)
		oBodyLyt:addInLayout(oPanel3,,15)
		oBodyLyt:addInLayout(oPanel2,,70)
		oBodyLyt:addInLayout(oPanel1,,15)

		TSay():New(05, 18,{|| OemToAnsi(STR0053) }, oPanel3,,Nil,,,,.T.,CLR_BLACK,CLR_WHITE,100,20) //STR0053 - 'Produto: '
		@ 02.6, 05   MSGET QPK->QPK_PRODUT 	WHEN .F.
		@ 02.6, 29   MSGET SB1->B1_DESC 	WHEN .F.
		TSay():New(21, 05,{|| OemToAnsi(STR0054) }, oPanel3,,Nil,,,,.T.,CLR_BLACK,CLR_WHITE,100,20) //STR0054 - 'Unid.Medida:'
		@ 03.8, 05   MSGET QPK->QPK_UM		WHEN .F.
		TSay():New(21, 87,{|| OemToAnsi(STR0055) }, oPanel3,,Nil,,,,.T.,CLR_BLACK,CLR_WHITE,100,20) //STR0055 - 'Ordem de Produção:'
		@ 03.8, 17.4 MSGET QPK->QPK_OP		WHEN .F.
		
	Else
		oBodyLyt:addInLayout(oPanel2,,85)
		oBodyLyt:addInLayout(oPanel1,,15)
	EndIf

	@ 001.5,002 To 035,386.2 Of oPanel1 Pixel

	@ 20,05 Say OemToAnsi(STR0050) Of oPanel1 Pixel //'Lote:'
    oQtdOrig := TSay():New(20,27,{|| Transform( cA175LotCt, PesqPict("SD7", "D7_LOTECTL",14)) },oPanel1,,Nil,,,,.T.,CLR_BLUE,CLR_WHITE,100,20)
    
    @ 20,100 Say OemToAnsi(STR0051) Of oPanel1 Pixel //'Sub-Lote:'
    oQtdOrig := TSay():New(20,127,{|| Transform( cA175LoteC, PesqPict("SD7", "D7_NUMLOTE",14)) },oPanel1,,Nil,,,,.T.,CLR_BLUE,CLR_WHITE,100,20)

	
	@ 20,200 Say OemToAnsi(STR0052) Of oPanel1 Pixel //'Potencia:'
	oQtdOrig := TSay():New(20,227,{|| Transform( nPotenc175, PesqPictQt("D7_POTENCI",14)) },oPanel1,,Nil,,,,.T.,CLR_BLUE,CLR_WHITE,100,20)
		

	@ 08,05 Say OemToAnsi(STR0003) Of oPanel1 Pixel //'Qtd.Original:'
	oQtdOrig := TSay():New(08,27,{|| Transform(Self:aQuantidadesCQ[1], PesqPictQt("B2_QATU",14)) },oPanel1,,Nil,,,,.T.,CLR_BLUE,CLR_WHITE,100,20)

	@ 08,100 Say OemToAnsi(STR0004) Of oPanel1 Pixel //'Qtd.Liberada:'
	oQtdLiber := TSay():New(08,127,{|| Transform(nLib, PesqPictQt("B2_QATU",14)) },oPanel1,,Nil,,,,.T.,CLR_BLUE,CLR_WHITE,100,20)

	@ 08,200 Say OemToAnsi(STR0005) Of oPanel1 Pixel //'Qtd.Rejeitada:'
	oQtdRejei := TSay():New(08,227,{|| Transform(nRej, PesqPictQt("B2_QATU",14)) },oPanel1,,Nil,,,,.T.,CLR_BLUE,CLR_WHITE,100,20)

	@ 08,300 Say OemToAnsi(STR0006) Of oPanel1 Pixel //'Saldo:'
	oQtdSaldo := TSay():New(08,327,{|| Transform(Self:aQuantidadesCQ[6], PesqPictQt("B2_QATU",14)) },oPanel1,,Nil,,,,.T.,CLR_BLUE,CLR_WHITE,100,20)

	Self:identificaCamposEditaveisCQ()

	oSelf := Self
	Self:oMsGetDados := MSGetDados():New(048,002,203.5,499.5,nOpc,'QIPA215ELO','A175TudOk','+D7_SEQ',.T.,Self:aAlterSD7,1,.F.,MAXGETDAD,'A175GetDad() .AND. QPA215ETVL()',,,'A175GetDad(.T.)',oPanel2)

	Self:oMsGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return(NIL)

/*/{Protheus.doc} inicializaPrivatesMATA175
Inicializa Conteúdo das Variáveis Private do MATA175 relacionadas a SD7
@author brunno.costa
@since  24/02/2023
/*/
Method inicializaPrivatesMATA175() CLASS QIPA215Estoque
	cA175Chave := SD7->D7_PRODUTO+SD7->D7_DOC+SD7->D7_SERIE+SD7->D7_FORNECE+SD7->D7_LOJA 
	cA175Loc   := SD7->D7_LOCAL
	cA175LotCt := SD7->D7_LOTECTL
	cA175LoteC := SD7->D7_NUMLOTE
	cA175Num   := SD7->D7_NUMERO
	cA175OrigL := SD7->D7_ORIGLAN
	cA175Prod  := SD7->D7_PRODUTO
	cA175UM    := SB1->B1_UM
	nPotenc175 := SD7->D7_POTENCI
	nPotencOri := SD7->D7_POTENCI
	nUsado     := 0 
Return

/*/{Protheus.doc} setaTituloPorApontamento
Seta Título da Classe para consideração na Aba ou Tela de Baixas do CQ
@author brunno.costa
@since  24/02/2023
@param 01 - nOpc, numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
/*/
Method setaTituloPorApontamento(nOpc) CLASS QIPA215Estoque
	If nOpc == 2 //Visualizar
		Self:cTitulo     := OemToAnsi(STR0007) //"Baixas do CQ - Visualizar"	
	ElseIf nOpc == 4 //Excluir
			Self:cTitulo     := OemToAnsi(STR0058) //"Baixas do CQ - Excluir"	
	Else
		If lEstorno 
			Self:cTitulo := OemToAnsi(STR0008) //"Baixas do CQ - Estornar"
		Else                                
			Self:cTitulo := OemToAnsi(STR0009) //"Baixas do CQ - Liberar/Rejeitar"
		EndIf       
	EndIf
Return Self:cTitulo

/*/{Protheus.doc} identificaCamposEditaveisCQ
Identifica em Self:aAlterSD7 os campos editáveis da tela Baixas do CQ
@author brunno.costa
@since  24/02/2023
/*/
Method identificaCamposEditaveisCQ() CLASS QIPA215Estoque
	
	Local aStructSD7 := SD7->(dbStruct())
	Local cCampo     := ""
	Local lA175Vld   := SuperGetMv("MV_A175VLD",.F.,.F.) .And. ;
				        Rastro(SD7->D7_PRODUTO)
	Local lLocaliza  := .F.
	Local nIndCpo    := 0
					  
	Self:aAlterSD7 := {}

	If !lEstorno
		Aadd(Self:aAlterSD7, 'D7_DATA')
		Aadd(Self:aAlterSD7, 'D7_TIPO')
		Aadd(Self:aAlterSD7, 'D7_QTDE')
		Aadd(Self:aAlterSD7, 'D7_OBS')
		Aadd(Self:aAlterSD7, 'D7_QTSEGUM')
		Aadd(Self:aAlterSD7, 'D7_MOTREJE')
		Aadd(Self:aAlterSD7, 'D7_LOCDEST')

		lLocaliza := Localiza(QPK->QPK_PRODUT,.T.)
		Iif(lLocaliza                              , Aadd(Self:aAlterSD7, 'D7_LOCALIZ'), Nil)
		Iif(lLocaliza                              , Aadd(Self:aAlterSD7, 'D7_NUMSERI'), Nil)
		Iif(lLocaliza .AND. IntWms(QPK->QPK_PRODUT), Aadd(Self:aAlterSD7, 'D7_SERVIC' ), Nil)

		Iif(lA175Vld, aAdd(Self:aAlterSD7, 'D7_DTVALID'), Nil)	

	Else
		Aadd(Self:aAlterSD7, 'D7_DATA')
		Aadd(Self:aAlterSD7, 'D7_ESTORNO')
		Aadd(Self:aAlterSD7, 'D7_OBS')
	EndIf
	
	//Adiciona os campos customizados na Grid de Baixa de CQ.
	If !lEstorno
		For nIndCpo := 1 To Len(Self:aHeader)

			cCampo := Self:aHeader[nIndCpo, 2]

			IIf(      aScan(aStructSD7    , {|x| AllTrim(x[1]) == AllTrim(cCampo)}) > 0;
				.And. aScan(Self:aAlterSD7, cCampo) == 0;
				.And. GetSx3Cache(cCampo, 'X3_PROPRI') == "U"; 
				.And. X3Uso(GetSx3Cache(cCampo, 'X3_USADO'));
				.And. cNivel >= GetSx3Cache(cCampo, 'X3_NIVEL'),;
				Aadd(Self:aAlterSD7, cCampo),;
				Nil)

		Next nIndCpo
	EndIf
Return

/*/{Protheus.doc} atualizaTotalizadoresPorArray
Atualiza em tela os totalizadores do resumo com base no Array aCols
@author brunno.costa
@since  24/02/2023
/*/
Method atualizaTotalizadoresPorArray() CLASS QIPA215Estoque //A175CalcQt

	Local aQtd      := { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	Local cD7Seq    := ""
	Local cPicture  := PesqPictQt("B2_QATU",14)
	Local cSeqZero  := Replicate( '0' , Len(SD7->D7_SEQ)-1) + '1'
	Local nIndItem  := 0
	Local nItems    := 0
	Local nPosSaldo := 0
	Local nQtdOrig  := 0
	Local nQuant    := 0
	Local nTipo     := 0

	If self:lAborta
		Return
	EndIf

	nPosSeq    := Iif(nPosSeq == 0   , aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_SEQ" }), nPosSeq   )
	nPosTipo   := Iif(nPosTipo == 0  , aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_TIPO"}), nPosTipo  )
	nCQPosQtde := Iif(nCQPosQtde == 0, aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_QTDE"}), nCQPosQtde)
	nPosSaldo  := aScan(Self:aHeader,{|x| Alltrim(x[2])=="D7_SALDO"})

	//  Posicao do Array - aQtd - Self:aQuantidadesCQ
	//  1 - Quantidade Original
	//  2 - Quantidade Liberada
	//  3 - Quantidade Rejeitada
	//  4 - Quantidade Liberada Estornada
	//  5 - Alterar data de validade do lote
	//  6 - Saldo
	//  7 - Numero de movimentacoes
	//  8 - Quantidade Liberada marcada para estorno
	//  9 - Quantidade Rejeitada marcada para estorno
	// 10 - Quantidade Liberada Devolvida
	// 11 - Quantidade Rejeitada Devolvida
	// 12 - Soma dos saldos de todos movimentos 

	Self:aCols   := aCols
	nItems       := Len(Self:aCols)
	For nIndItem := 1 to nItems
		If !aTail(Self:aCols[nIndItem])
			nTipo    := Self:aCols[nIndItem, nPosTipo]
			cD7Seq   := Self:aCols[nIndItem, nPosSeq]
			nQuant   := Self:aCols[nIndItem, nCQPosQtde]
			nQtdOrig := Iif(nTipo == 0 .And. cD7Seq == cSeqZero,;
			                Self:aCols[nIndItem, nPosSaldo]    ,;
						    nQtdOrig                            ) //Quantidade Original
			aQtd[01] := nQtdOrig                                  //Quantidade Original
			aQtd[02] += Iif(nTipo == 1, nQuant , 0)               //Liberada
			aQtd[03] += Iif(nTipo == 2, nQuant , 0)               //Rejeitada
			aQtd[10] += Iif(nTipo == 3, nQuant , 0)               //Transferido
			aQtd[11] += Iif(nTipo == 4, nQuant , 0)               //Estorno Transferencia
			aQtd[04] += Iif(nTipo == 6, nQuant , 0)               //Estorno Liberacao
			aQtd[05] += Iif(nTipo == 7, nQuant , 0)               //Estorno Rejeicao
			aQtd[07]++                                            //Numero de Movimentos

			If lEstorno .And. Self:aCols[nIndItem, nCQPosEsto]=="X"
				aQtd[04] += Iif(nTipo == 1, nQuant , 0)           //Liberação que será estornada
				aQtd[05] += Iif(nTipo == 2, nQuant , 0)           //Rejeição que será estornada
			EndIf
		EndIf
	Next

	//Cálculo do Saldo - INICIO
	aQtd[6] :=  aQtd[01] 			   		                      //Saldo Original
	aQtd[6] -= (aQtd[02] - aQtd[04] )	                          //Subtrai as Liberacoes
	aQtd[6] -= (aQtd[03] - aQtd[05] )	                          //Subtrai as Rejeicoes
	aQtd[6] -= (aQtd[10] - aQtd[11] )	                          //Subtrai as Transferencias
	//Cálculo do Saldo - FIM

	FwFreeArray(Self:aQuantidadesCQ)
	Self:aQuantidadesCQ := aQtd

	If Self:validaSeEhExecucaoComTelaResultadosQIPA215() .And. Self:nOpcOriginal > -1  //Atualiza Componentes de Tela
		If Type('oQtdOrig') <> 'U'
			oQtdOrig:SetText(  Transform( Self:aQuantidadesCQ[1] , cPicture ) )
		EndIf
		If Type('oQtdLiber') <> 'U'
			oQtdLiber:SetText( Transform( (aQtd[2] - aQtd[4] )	 , cPicture ) )  //Liberacoes
		EndIf
		If Type('oQtdRejei') <> 'U'
			oQtdRejei:SetText( Transform( (aQtd[3] - aQtd[5] )	 , cPicture ) )  //Rejeicoes
		EndIf
		If Type('oQtdSaldo') <> 'U'
			oQtdSaldo:SetText( Transform( Self:aQuantidadesCQ[6] , cPicture ) )
		EndIf
		If Type('oPanel') <> 'U'
			oPanel1:Refresh()
		Endif
	EndIF

Return

/*/{Protheus.doc} possuiMovimentacaoEstoqueCQ
Indica se a inspeção possui movimentação (liberação ou rejeição) no estoque CQ durante exibição da tela
MOVIMENTAÇÕES NÃO ESTORNADAS
@author brunno.costa
@since  24/02/2023
@return lPossui, lógico, indica se possui movimentações não estornadas, ou seja: quantidade original != saldo
/*/
Method possuiMovimentacaoEstoqueCQ() CLASS QIPA215Estoque
	Local lPossui := Self:aQuantidadesCQ[1] != Self:aQuantidadesCQ[6]
Return lPossui

/*/
{Protheus.doc} possuiMovimentacaoEstoqueCQComSeek
Indica se a inspeção possui movimentação (liberação ou rejeição) no estoque CQ durante exibição da tela
MOVIMENTAÇÕES NÃO ESTORNADAS
@author brunno.costa
@since  24/02/2023
@return lPossui, lógico, indica se possui movimentações não estornadas, ou seja: quantidade original != saldo
/*/
Method possuiMovimentacaoEstoqueCQComSeek(nRecnoQPK) CLASS QIPA215Estoque
	Local lPossui    := .F.

	Self:lAborta  := .F. 
	If Self:integracaoHabilitada() .AND. Self:lPorApontamento
		QPK->(DbGoTo(nRecnoQPK))
		Self:lAborta := Iif(!Self:lAborta, Empty(Self:aCols), Self:lAborta)
		If !Self:lAborta
			Self:atualizaTotalizadoresPorArray()
			lPossui := Self:possuiMovimentacaoEstoqueCQ()
		EndIf
	EndIf

Return lPossui

/*/{Protheus.doc} validaSeEhExecucaoComTelaResultadosQIPA215
Valida Se Está Executando Com Tela do QIPA215
@author brunno.costa
@since  01/03/2023
@return lQIPA215, lógico, indica se está executando com tela do QIPA215
/*/
Method validaSeEhExecucaoComTelaResultadosQIPA215() CLASS QIPA215Estoque
	Local lQIPA215 := (Self:nOpcOriginal == 2 .Or. Self:nOpcOriginal == 3 .Or. Self:nOpcOriginal == 4) .AND. IsInCallStack("QP215ATURES")
Return lQIPA215

/*/{Protheus.doc} validaSeEhExecucaoViaMenuQIPA215
Valida Se Está Executando via Menu do QIPA215
@author brunno.costa, rafael.hesse
@since  29/03/2023
@return lQIPA215, lógico, indica se está executando VIA MENU do QIPA215
/*/
Method validaSeEhExecucaoViaMenuQIPA215() CLASS QIPA215Estoque
	Local lQIPA215 := Self:nOpcOriginal > 6
Return lQIPA215

/*/{Protheus.doc} possuiPendenciaMovimentacaoEstoqueCQ
Identifica se possui pendência de movimentação de Estoque CQ
@author brunno.costa
@since  27/02/2023
@return lPossui, lógico, indica se possui pendência de movimentação de estoque CQ
/*/
Method possuiPendenciaMovimentacaoEstoqueCQ() CLASS QIPA215Estoque
	Local lPossui   := .F.
	Local cNumeroCQ := Self:retornaNumeroCQ()
	lPossui         := !Empty(cNumeroCQ) .AND. Self:aQuantidadesCQ[6] > 0
Return lPossui

/*/{Protheus.doc} possuiMovimentoBaixasOuHistoricoCQ
Indica se a inspeção possui movimentação (liberação ou rejeição) no estoque CQ durante exibição da tela
MOVIMENTAÇÕES ESTORNADAS OU NÃO
@author brunno.costa
@since  24/02/2023
@return lPossui, lógico, indica se a inspeção possui movimentações estornadas ou não
/*/
Method possuiMovimentoBaixasOuHistoricoCQ() CLASS QIPA215Estoque
	Local lPossui := Len(Self:aCols) > 1
Return lPossui

/*/{Protheus.doc} validaMovimentoEstoqueCQxLaudoGeral
Valida se o movimento do Estoque CQ está condizente com Liberações e Rejeições do Laudo Geral
@author brunno.costa
@since  24/02/2023
@return lValida, lógico, indica que as movimentações estão válidas conforme Liberações e Rejeições do Laudo Geral
/*/
Method validaMovimentoEstoqueCQxLaudoGeral() CLASS QIPA215Estoque
	Local cCodHelp    := ""
	Local cProblema   := ""
	Local cSolucao    := ""
	Local cUM         := Iif(Self:validaSeEhExecucaoComTelaResultadosQIPA215(),M->QPK_UM,QPK->QPK_UM)
	Local lValida     := .T.
	Local nLiberEst   := Self:aQuantidadesCQ[2] - Self:aQuantidadesCQ[4]
	Local nLiberLaudo := 0
	Local nRejEst     := Self:aQuantidadesCQ[3] - Self:aQuantidadesCQ[5]
	Local nRejLaudo   := 0
	Local nTamLote    := 0

	Self:atribuiDadosLaudoGeral(@nRejLaudo, @nLiberLaudo, @nTamLote)
	
	lValida := nLiberEst <= nLiberLaudo
	If lValida
		lValida := nRejEst <= nRejLaudo
		If !lValida
			//STR0010 - "Rejeição [{1}] acima da permitida."
			//STR0011 - "Rejeite até {1} (Rejeição Laudo Geral) na aba 'Baixas do CQ'."
			cProblema   := StrTran(STR0010, "{1}", AllTrim(Str(nRejEst))+ " " + cUM )
			cSolucao    := StrTran(STR0011, "{1}", AllTrim(Str(nRejLaudo))+" " + cUM )
			cCodHelp    := "QTD-REJ-INV"
		EndIf
	Else
		//STR0012 - "Liberação [{1}] acima da permitida."
		//STR0013 - "Libere até {1} na aba 'Baixas do CQ'."
		//STR0014 - "Tamanho do Lote[{2}] - Rejeição Laudo Geral[{3}] = {4}."
		cProblema   := StrTran(STR0012, "{1}" , AllTrim(Str(nLiberEst))+ " " + cUM )
		cSolucao    := AllTrim(STR0013) + CRLF + CRLF + AllTrim(STR0014)
		cSolucao    := StrTran(cSolucao, "{1}", AllTrim(Str(nLiberLaudo))+" " + cUM )
		cSolucao    := StrTran(cSolucao, "{2}", AllTriM(Str(nTamLote)) )
		cSolucao    := StrTran(cSolucao, "{3}", AllTriM(Str(nRejLaudo)) )
		cSolucao    := StrTran(cSolucao, "{4}", AllTrim(Str(nLiberLaudo)) )
		cCodHelp    := "QTD-LIB-INV"
	EndIf

	If !lValida
		If lEstorno
			//STR0036 - "Estorne os movimentos na aba 'Baixas do CQ', salve a alteração, retorne a edição de resultados e:"
			cCodHelp  := "EST-" + cCodHelp
			cSolucao := STR0036 + CRLF + CRLF +  cSolucao
			lValida  := .T.
		EndIf
		Help(NIL, NIL, cCodHelp, NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
	EndIf

Return lValida

/*/{Protheus.doc} preencheMovimentoCQ
Preenche e retorna movimento de estoque do CQ
@author brunno.costa
@since  24/02/2023
@param 01 - nRecnoQPK, numérico, RECNO do registro da inspeção (QPK) relacionado
@param 02 - nOpc     , numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
@return aColsAux, array, linha de itens da movimentação para exibição na GRID conforme aHeader
/*/
Method preencheMovimentoCQ(nRecnoQPK, nOpc) CLASS QIPA215Estoque //Q215FilCQ0

	Local aAreaAnt  := GetArea()
	Local aAreaSD7  := Nil
	Local aColsAux  := {}
	Local cCampo    := ""
	Local cLocCQ    := GetMV( 'MV_CQ' )
	Local cNumCQ    := ''
	Local cProduto  := QPK->QPK_PRODUT
	Local cSeek     := ''
	Local dDataFec  := MVUlmes()
	Local nHandler  := 0
	Local nIndCpo   := 0

	//Salva o aColsAux do SD7
	aHeader := Self:aHeader
	nUsado  := Len(aHeader)

	//Verificar data do ultimo fechamento em SX6.
	If dDatabase <= dDataFec .and. nOpc <> 2
		Help( ' ', 1, 'FECHTO')
		Self:lAborta := .T.
		Return Nil
	EndIf

	If !Self:posicionaBaixaCQPorRecnoQPK(nRecnoQPK, @cNumCQ, @cLocCQ, .F.)
		Self:lAborta := .T.
		RestArea(aAreaAnt)
		Return Nil
	EndIf

	aAreaSD7 := SD7->(GetArea())

	//Verifica o Saldo Atual a ser liberado/estornado
	Self:aQuantidadesCQ := A175CalcQt(SD7->D7_NUMERO, SD7->D7_PRODUTO, SD7->D7_LOCAL)

	If Self:aQuantidadesCQ[7] != 0

		//Consiste se existe Quantidade a ser Movimentada
		If nOpc == 2                  //Visualizar
			lEstorno := .F.
		ElseIf nOpc == 4  .Or.;
			   nOpc == 5              //Exclusao ou Estorno do CQ
			lEstorno := .T.
		ElseIf Self:nOpcOriginal == 8 //Estorno via Menu
			lEstorno := .T.
		Else
			//Impede Estorno caso nao exista quantidade Liberada ou Rejeitada
			If QtdComp((Self:aQuantidadesCQ[2]-Self:aQuantidadesCQ[4])+(Self:aQuantidadesCQ[3]-Self:aQuantidadesCQ[5])) == QtdComp(0)
			
				//Verifica se o saldo do armazem esta bloqueado
				Iif(!SldBlqSB2(SD7->D7_PRODUTO,SD7->D7_LOCAL), Self:lAborta := .T., lEstorno := .F.)

			//Impede Liberacao/Rejeicao caso nao exista Saldo a Movimentar	
			ElseIf QtdComp(Self:aQuantidadesCQ[6]) == QtdComp(0) .Or. !Empty(SD7->D7_LIBERA)
				lEstorno := .T.
			EndIf
		EndIf

		If !Self:lAborta
			//Carrega o conteudo do arquivo MV_DIRCQ+CQ99999.TXT
			Self:cTexto := Iif( File(Self:cDiretorioCQ+(Self:cArquivoCQ:='CQ'+SD7->D7_NUMERO+'.TXT')) .And.;
						        (nHandler:=fOpen(Self:cDiretorioCQ+Self:cArquivoCQ,0+64))>0 .And.;
						        fClose(nHandler);
						       , MemoRead(Self:cDiretorioCQ+Self:cArquivoCQ);
						       , Self:cTexto)

			//Posiciona ponteiro do arquivo cabeca e inicializa variaveis
			dbSelectArea('SD7')
			SD7->(dbSetOrder(1))
			SD7->(MsSeek(cSeek:=xFilial('SD7')+cNumCQ+cProduto+cLocCQ,.F.))
			While SD7->(!Eof()) .And. SD7->(D7_FILIAL+D7_NUMERO+D7_PRODUTO+D7_LOCAL)==cSeek
				
				aColsAux := Self:adicionaItemMovimentoDefault(@aColsAux, @nUsado, .F.)
				
				SD7->(dbSkip())
			EndDo

			//Forca o campo D7_ESTORNO na 2a. posicao do aColsAux
			A175Acerta(@aHeader,@aColsAux)

			Self:aHeader := aClone(aHeader)

			For nIndCpo := 1 to Len(aHeader)
				cCampo      := Upper(AllTrim(aHeader[nIndCpo, 2]))
				nPosTipo    := Iif( cCampo  == 'D7_TIPO'   , nIndCpo, nPosTipo    )
				nPosDesc    := Iif( cCampo  == 'D7_DESCREJ', nIndCpo, nPosDesc    )
				nCQPosQtde  := Iif( cCampo  == 'D7_QTDE'   , nIndCpo, nCQPosQtde  )
				nCQPosLDes  := Iif( cCampo  == 'D7_LOCDEST', nIndCpo, nCQPosLDes  )
				nCQPosData  := Iif( cCampo  == 'D7_DATA'   , nIndCpo, nCQPosData  )
				nCQPosEsto  := Iif( cCampo  == 'D7_ESTORNO', nIndCpo, nCQPosEsto  )
				nCQPosMRej  := Iif( cCampo  == 'D7_MOTREJE', nIndCpo, nCQPosMRej  )
				nCQPosObs   := Iif( cCampo  == 'D7_OBS'    , nIndCpo, nCQPosObs   )
				nCQPosQtd2  := Iif( cCampo  == 'D7_QTSEGUM', nIndCpo, nCQPosQtd2  )
				nCQPosNSeq  := Iif( cCampo  == 'D7_NUMSEQ' , nIndCpo, nCQPosNSeq  )
				nPosLocLz   := Iif( cCampo  == 'D7_LOCALIZ', nIndCpo, nPosLocLz   )
				nPosNumSer  := Iif( cCampo  == 'D7_NUMSERI', nIndCpo, nPosNumSer  )
				nPosService := Iif( cCampo  == 'D7_SERVIC' , nIndCpo, nPosService )
				nPosEstrut  := Iif( cCampo  == 'D7_TPESTR' , nIndCpo, nPosEstrut  )
				nPosDtVld   := Iif( cCampo  == 'D7_DTVALID', nIndCpo, nPosDtVld   )
				nPosLocDest := Iif( cCampo  == 'D7_LOCDEST', nIndCpo, nPosLocDest )
			Next nIndCpo	
		EndIf

	Endif

	RestArea(aAreaSD7)
	RestArea(aAreaAnt)

Return (aColsAux)


/*/{Protheus.doc} gravaObsMovimentoCQ
Gravar Arquivo Físico de OBS de Movimentação do CQ 
 -> MV_DIRCQ+CQ99999.TXT
 -> Self:cDiretorioCQ+'CQ'+SD7->D7_NUMERO+'.TXT'
@author brunno.costa
@since  24/02/2023
@param 01 - nOpc, numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
/*/
Method gravaObsMovimentoCQ(nOpc) CLASS QIPA215Estoque //Q215GrvAll

	Local cTexto    := ""
	Local nIndLinha := 0
	Local nPosMemo  := 0
	//Local nPosEST  := 0 //TODO - Será revisado na issue DMANQUALI-6024

	//Grava o campo memo da SD7 - D7_OBS
	If Self:lPorApontamento .AND. !Self:lAborta //Somente se houver integracao com Materiais - Ajuste da DMANQUALI-930
		nPosSeq   := Iif(nPosSeq == 0 , aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_SEQ" }), nPosSeq   )
		nPosTipo  := Iif(nPosTipo == 0, aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_TIPO"}), nPosTipo  )
		nPosMemo  := aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_OBS" })
		nPosEST   := aScan(Self:aHeader, {|x| Alltrim(x[2])=="D7_ESTORNO"})  

		If nOpc == 3 //Botão - "Resultados"
			For nIndLinha := 2 to Len(Self:aCols)
				cSeq   := Self:aCols[nIndLinha][nPosSeq]
				cTexto += '[' + STR0026 +':' + AllTrim(Str(Self:aCols[nIndLinha][nPosTipo])) + '/' + STR0027 +':' + cSeq + '/A]' + CHR(13) + CHR(10)
				cTexto += Self:aCols[nIndLinha][nPosMemo] + CHR(13) + CHR(10)
				cTexto += '[' + STR0026 +':' + AllTrim(Str(Self:aCols[nIndLinha][nPosTipo])) + '/' + STR0027 +':' + cSeq + '/Z]' + CHR(13) + CHR(10)
			Next nIndLinha

		EndIf

		Self:cArquivoCQ := 'CQ'+SD7->D7_NUMERO+'.TXT'
		If Len(cTexto)>0
			Iif(MemoWrit(Self:cDiretorioCQ+Self:cArquivoCQ, cTexto), Nil, Help(' ',1,'MEMOERRO'))
		
		ElseIf File(Self:cDiretorioCQ+Self:cArquivoCQ) //Determina se existe arquivo no diretório ou path AdvPL padrão.
			//Exclui um arquivo do disco.
			Iif(fErase(Self:cDiretorioCQ+Self:cArquivoCQ) == -1, Help(' ',1,'MEMOERRO'), Nil)
		EndIf
	EndIf

Return

/*/{Protheus.doc} retornaNumeroCQ
Retorna D7_NUMERO com base em posicionamento da QPK
Mantém posicionamentos intermediários abertos nas tabelas SH6, SD3 e SD7
@author brunno.costa
@since  24/02/2023
@return cNumeroCQ, caracter, D7_NUMERO relacionado ao registro posicionado da QPK
/*/
Method retornaNumeroCQ() CLASS QIPA215Estoque

	Local lMATA250 := !Empty(GetSx3Cache("QPK_ORIGEM","X3_CAMPO")) .AND. AllTriM(QPK->QPK_ORIGEM) == "MATA250"

	If !lMATA250 .AND.;                                                     //Sem novo campo ou não é MATA250
		Self:posicionaApontamentoDeProducaoPorOperacao() .AND.;             //Posiciona na SH6 pela QPK
	    Self:posicionaMovimentoInterno() .AND.;              				//Posiciona na SD3 pela SH6
	    Self:posicionaBaixaCQ()                              				//Posiciona na SD7 pela SD3

		Self:cNumeroCQ := SD7->D7_NUMERO
	ElseIf Self:posicionaApontamentoDeProducaoMATA250() .AND.;              //Posiciona na SD3 pela QPK
		   Self:posicionaBaixaCQ()                                          //Posiciona na SD7 pela SD3

		Self:cNumeroCQ := SD7->D7_NUMERO
	EndIf

Return Self:cNumeroCQ

/*/{Protheus.doc} posicionaApontamentoDeProducaoPorOperacao
Posiciona no registro da SH6 relacionado ao registro pré-posicionado da QPK
@author brunno.costa
@since  24/02/2023
@return lPosicionou, lógico, indica se conseguiu realizar o posicionamento na SH6
/*/
Method posicionaApontamentoDeProducaoPorOperacao() CLASS QIPA215Estoque
	Local cAliasTRB   := Nil
	Local cQuery      := ""
	Local cRastro     := Iif(Self:lRastro, Posicione("SB1", 1, xFilial("SB1") + QPK->QPK_PRODUT, "B1_RASTRO"), "")
	Local lPosicionou := .F.
	Local oManager    := QLTQueryManager():New()

	cQuery := " SELECT SH6.R_E_C_N_O_ "
	cQuery += " FROM " + RetSQLName("SH6") + " SH6, " + RetSQLName("SD3") + " SD3"
	cQuery += " WHERE SH6.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND SD3.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND SD3.D3_FILIAL  = '" + xFilial("SD3") + "' "
	cQuery +=   " AND SD3.D3_ESTORNO <> 'S' "
	cQuery +=   " AND SD3.D3_IDENT   = SH6.H6_IDENT "
	cQuery +=   " AND SD3.D3_COD     = SH6.H6_PRODUTO "
	cQuery +=   " AND SH6.H6_FILIAL  = '" + xFilial("SH6") + "' "
	cQuery +=   " AND SH6.H6_OP      = '" + QPK->QPK_OP + "' "
	cQuery +=   " AND SH6.H6_PRODUTO = '" + QPK->QPK_PRODUT + "' "

	cQuery += oManager:montaFiltroRastroValor(cRastro, QPK->QPK_LOTE, "H6_IDENTE", "H6_IDEINV", "H6_LOTECTL", "H6_NUMLOTE", .T.)

	cQuery += " ORDER BY SH6.R_E_C_N_O_ DESC "

	cQuery    := oManager:changeQuery(cQuery)
	cAliasTRB := oManager:executeQuery(cQuery)

	If !(cAliasTRB)->(EOF())
		SH6->(DbGoTo((cAliasTRB)->R_E_C_N_O_))
		lPosicionou := .T.
	Endif

	(cAliasTRB)->(dbCloseArea())

Return lPosicionou

/*/{Protheus.doc} posicionaApontamentoDeProducaoMATA250
Posiciona no registro da SD3 relacionado ao registro pré-posicionado da QPK
@author brunno.costa
@since  24/02/2023
@return lPosicionou, lógico, indica se conseguiu realizar o posicionamento na SH6
/*/
Method posicionaApontamentoDeProducaoMATA250() CLASS QIPA215Estoque
	Local cAliasTRB   := Nil
	Local cQuery      := ""
	Local cRastro     := Iif(Self:lRastro, Posicione("SB1", 1, xFilial("SB1") + QPK->QPK_PRODUT, "B1_RASTRO"), "")
	Local lPosicionou := .F.
	Local oManager    := QLTQueryManager():New()

	cQuery := " SELECT SD3.R_E_C_N_O_ "
	cQuery += " FROM " + RetSQLName("SD3") + " SD3"
	cQuery += " WHERE SD3.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND SD3.D3_FILIAL  = '" + xFilial("SD3") + "' "
	cQuery +=   " AND SD3.D3_OP      = '" + QPK->QPK_OP + "' "
	cQuery +=   " AND SD3.D3_COD     = '" + QPK->QPK_PRODUT + "' "
	cQuery +=   " AND SD3.D3_ESTORNO <> 'S' "

	cQuery += oManager:montaFiltroRastroValor(cRastro, QPK->QPK_LOTE, "D3_IDENT", "", "D3_LOTECTL", "D3_NUMLOTE", .T.)

	cQuery    := oManager:changeQuery(cQuery)
	cAliasTRB := oManager:executeQuery(cQuery)

	If !(cAliasTRB)->(EOF())
		SD3->(DbGoTo((cAliasTRB)->R_E_C_N_O_))
		lPosicionou := .T.
	Endif

	(cAliasTRB)->(dbCloseArea())

Return lPosicionou

/*/{Protheus.doc} posicionaMovimentoInterno
Posiciona no registro da SD3 relacionado ao registro pré-posicionado da QPK
@author brunno.costa
@since  24/02/2023
@return lPosicionou, lógico, indica se conseguiu realizar o posicionamento na SD3
/*/
Method posicionaMovimentoInterno() CLASS QIPA215Estoque
	SD3->(DbSetOrder(14))//E
Return SD3->(DbSeek(xFilial("SD3")+QPK->QPK_PRODUT+SH6->H6_IDENT)) //D3_FILIAL+D3_COD+D3_IDENT

/*/{Protheus.doc} posicionaBaixaCQ
Posiciona no registro da SD7 relacionado ao registro pré-posicionado da SD3
@author brunno.costa
@since  24/02/2023
@return lPosicionou, lógico, indica se conseguiu realizar o posicionamento na SD7
/*/
Method posicionaBaixaCQ() CLASS QIPA215Estoque
	SD7->(DbSetOrder(3))
Return SD7->(DbSeek(xFilial("SD7")+SD3->(D3_COD+D3_NUMSEQ))) //D7_FILIAL+D7_PRODUTO+D7_NUMSEQ+D7_NUMERO

/*/{Protheus.doc} posicionaBaixaCQPorRecnoQPK
Posiciona no registro da SD7 relacionado por RECNO da QPK
@author brunno.costa
@since  20/07/2023
@param 01 - nRecnoQPK, numérico, obrigatório - recno de referência da QPK para movimentação
@param 02 - cNumCQ   , caracter, retorna por referência o D7_NUMERO relacionado
@param 03 - cLocCQ   , caracter, retorna por referência o armazém de CQ relacionado
@param 04 - lHelp    , lógico  , indica se exibirá Help
@return lPosicionou, lógico, indica se conseguiu realizar o posicionamento na SD7
/*/
Method posicionaBaixaCQPorRecnoQPK(nRecnoQPK, cNumCQ, cLocCQ, lHelp) CLASS QIPA215Estoque

	Local cProblema   := ""
	Local cSolucao    := ""
	Local lPosicionou := .F.

	Default cLocCQ    := GetMV( 'MV_CQ' )
	Default cNumCQ    := ''
	Default lHelp     := .F.

	//Define o Numero da Movimentacao no CQ, a partir do QEK_CERFOR
	cNumCQ := Left(AllTrim(Self:retornaNumeroCQ(nRecnoQPK)),TamSX3('D7_NUMERO')[1])
	cLocCQ := PadR(cLocCQ,TAMSX3("D7_LOCAL")[1])

	//Posiciona-se no Registro de Sequencia 001
	SD7->(DbSetOrder(1))
	If !(lPosicionou := SD7->(DbSeek(xFilial('SD7')+cNumCQ+QPK->QPK_PRODUT+cLocCQ+'001',.F.)))
		Self:lAborta := .T.
		//STR0015 - "Não foi identificada movimentação para o armazém de CQ '{1}' relacionada a esta inspeção."
		//STR0016 - "Realize apontamento de produção no armazém de CQ '{1}' para controlar a movimentação de estoque via inspeção."
		cProblema := StrTran(STR0015, "{1}", cLocCQ )
		cSolucao  := StrTran(STR0016, "{1}", cLocCQ )
		If lHelp
			Help(NIL, NIL, "SEM-ESTOQUE-CQ", NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
		EndIf
	EndIf
Return lPosicionou

/*/{Protheus.doc} gravaResultados
Realiza Gravação do Movimento Baixas de CQ via A175Grava e Grava OBS do Movimento
@author brunno.costa
@since  24/02/2023
@param 01 - nOpc , numérico, nOpc utilizado pela MENUDEF da rotina QIPA215
@param 02 - lHelp , lógico, indica se apresetará mensagem de help
@return lRetLib, lógico, indica se conseguiu gravar os resultados via MATA175
/*/
Method gravaResultados(nOpc,lHelp) CLASS QIPA215Estoque
	Local lRetLib := .F.
	Default lHelp := .F.
	If Self:lPorApontamento .AND. !Self:lAborta .AND. Self:possuiMovimentoBaixasOuHistoricoCQ()
		Private aQtd     := Self:aQuantidadesCQ
		Private l175Auto := .T.
		If A175TudOk()
			lRetLib := A175Grava()
		EndIf
		If lRetLib
			Self:gravaObsMovimentoCQ(nOpc)
		ElseIf lHelp
			// STR0047 - "Não foram incluídas movimentações de Estoque do CQ válidas para movimentação."
			// STR0048 - "Inclua movimentações manualmente ou utilize a opção 'Sim' para realização de movimentação automática."
			Help(NIL, NIL, "MOV-INVALIDA", NIL, STR0047, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0048})
		EndIf
	EndIf
Return lRetLib

/*/{Protheus.doc} atualizaQPKSITOPPosBaixaMenu
Metodo que atualiza QPK_SITOP após a baixa realizada via "Outras Ações"
@type method
@author brunno.costa, rafael.hesse
@since  29/03/2023
/*/
Method atualizaQPKSITOPPosBaixaMenu() CLASS QIPA215Estoque
	Local cLaudo   := Nil
	Local lMedicao := .T.
		Self:atribuiDadosLaudoGeral(, , , @cLaudo)
		QP215AtuSit(cLaudo, lMedicao)
Return .T.

/*/{Protheus.doc} QIPA215Estoque::validaSeORegristoDaSD7EhRelacionadoAoQIP
Verifica se o registro da SD7 tem relacionamento com o QIP
@type method
@author rafael.hesse
@since 16/03/2023
@param 01 cNumero, Caracter, indica o numero do registro da SD7
@param 02 cProduto, Caracter, Indica o produto que está sendo verificado
@param 03 cNumLote, Caracter, indica o numero do lote
@return lPermite, Lógico, Informa se encontrou registro na QPK
/*/
Method validaSeORegristoDaSD7EhRelacionadoAoQIP(cNumero, cProduto, cNumLote) CLASS QIPA215Estoque
Local cAlias      := Nil
Local cQuery      := ""
Local cRastro     := Iif(Self:lRastro, Posicione("SB1", 1, xFilial("SB1") + QPK->QPK_PRODUT, "B1_RASTRO"), "")
Local lPermite    := .T.
Local oErrorBlock := ErrorBlock({|e| Break(e)})
Local oManager	  := Nil

	Begin Sequence
		oManager := QLTQueryManager():New()

		cQuery := " SELECT QPK.QPK_PRODUT "
		cQuery += " FROM "
		cQuery += 	" (SELECT D7_NUMSEQ, "
		cQuery += 	        " D7_PRODUTO "
		cQuery += 	" FROM " + RetSqlName("SD7")
		cQuery += 	" WHERE D7_NUMERO  = '" + cNumero + "' "
		cQuery += 	  " AND D7_PRODUTO = '" + cProduto + "' "
		cQuery += 	  " AND D7_FILIAL  = '" + xFilial("SD7") + "' "
		cQuery += 	  " AND D_E_L_E_T_ = ' ' "
		cQuery += 	  " AND D7_TIPO    = 0) SD7 "
		cQuery += 	" INNER JOIN "
		cQuery +=   " (SELECT D3_COD, "
		cQuery += 			" D3_IDENT, "
		cQuery += 			" D3_NUMSEQ, "
		cQuery += 			" D3_OP, "
		cQuery += 			" D3_LOTECTL, "
		cQuery += 			" D3_NUMLOTE "
		cQuery +=    " FROM " + RetSqlName("SD3")
		cQuery +=    " WHERE D_E_L_E_T_ = ' ' "
		cQuery +=      " AND D3_FILIAL='" + xFilial("SD3") + "' "
		cQuery +=      " AND D3_ESTORNO <> 'S' ) SD3 ON   SD3.D3_NUMSEQ = SD7.D7_NUMSEQ "
		cQuery += 									" AND SD3.D3_COD    = SD7.D7_PRODUTO "
		cQuery += " INNER JOIN "
		cQuery +=   " (SELECT H6_PRODUTO, "
		cQuery += 			" H6_OP, "
		cQuery += 			" H6_IDENT, "
		cQuery += 			" H6_LOTECTL, "
		cQuery += 			" H6_NUMLOTE, "
		cQuery += 			" H6_IDENTE, "
		cQuery += 			" H6_IDEINV "
		cQuery +=    " FROM " + RetSqlName("SH6")
		cQuery +=    " WHERE D_E_L_E_T_ = ' ' "
		cQuery +=      " AND H6_PRODUTO='" + cProduto + "' "
		cQuery +=      " AND H6_FILIAL= '" + xFilial("SH6") + "') SH6 ON SD3.D3_COD = SH6.H6_PRODUTO "
		cQuery += 												   " AND SD3.D3_IDENT = SH6.H6_IDENT "
		cQuery += " INNER JOIN "
		cQuery +=  "  (SELECT QPK_PRODUT, "
		cQuery +=           " QPK_OP, "
		cQuery += 			" QPK_LOTE "
		cQuery +=    " FROM " + RetSqlName("QPK")
		cQuery +=    " WHERE D_E_L_E_T_ = ' ' "
		cQuery +=      " AND QPK_FILIAL='" + xFilial("QPK") + "' ) QPK ON SH6.H6_OP = QPK.QPK_OP "
		cQuery += 													" AND SH6.H6_PRODUTO = QPK.QPK_PRODUT "

		cQuery +=    oManager:montaFiltroRastroCampo(cRastro, "QPK_LOTE", "H6_IDENTE", "H6_IDEINV", "H6_LOTECTL", "H6_NUMLOTE", .T.)

		cQuery := oManager:changeQuery(cQuery)
		cAlias := oManager:executeQuery(cQuery)

		If !(cAlias)->(EOF())
			lPermite := .F.
		Else
			(cAlias)->(dbCloseArea())

			//Checa possível apontamento pelo MATA250
			cQuery := " SELECT QPK.QPK_PRODUT "
			cQuery += " FROM "
			cQuery +=    "(SELECT QPK_PRODUT, "
			cQuery +=           " QPK_OP, "
			cQuery +=           " QPK_LOTE "
			cQuery +=    " FROM " + RetSqlName("QPK")
			cQuery +=    " WHERE (D_E_L_E_T_ = ' ') "
			cQuery +=      " AND (QPK_FILIAL = '" + xFilial("QPK") + "')) QPK "
			cQuery += " INNER JOIN "
			cQuery +=    "(SELECT D7_NUMSEQ, "
			cQuery +=           " D7_PRODUTO "
			cQuery +=    " FROM " + RetSqlName("SD7")
			cQuery +=    " WHERE (D7_NUMERO  = '" + cNumero + "') "
			cQuery +=      " AND (D7_PRODUTO = '" + cProduto + "') "
			cQuery +=      " AND (D7_FILIAL = '" + xFilial("SD7") + "') "
			cQuery +=      " AND (D_E_L_E_T_ = ' ') "
			cQuery +=      " AND (D7_TIPO = 0)) SD7 "
			cQuery += " INNER JOIN "
			cQuery +=    "(SELECT D3_COD, "
			cQuery +=           " D3_IDENT, "
			cQuery +=           " D3_NUMSEQ, "
			cQuery +=           " D3_OP, "
			cQuery +=           " D3_LOTECTL, "
			cQuery +=           " D3_NUMLOTE "
			cQuery +=    " FROM " + RetSqlName("SD3")
			cQuery +=    " WHERE (D_E_L_E_T_ = ' ') "
			cQuery +=      " AND (D3_FILIAL = '" + xFilial("SD3") + "') "
			cQuery +=      " AND (D3_ESTORNO <> 'S') ) SD3 "
			
			cQuery += " ON  SD3.D3_NUMSEQ  = SD7.D7_NUMSEQ "
			cQuery += " AND SD3.D3_COD     = SD7.D7_PRODUTO " 
			
			cQuery += " ON  QPK.QPK_PRODUT = SD3.D3_COD "
			cQuery += " AND QPK.QPK_OP     = SD3.D3_OP "

			cQuery += oManager:montaFiltroRastroCampo(cRastro, "QPK_LOTE", "D3_IDENT", "", "D3_LOTECTL", "D3_NUMLOTE", .T.)

			cQuery += " LEFT OUTER JOIN "
			cQuery +=    "(SELECT H6_PRODUTO, "
			cQuery +=           " H6_OP, "
			cQuery +=           " H6_IDENT, "
			cQuery +=           " H6_LOTECTL, "
			cQuery +=           " H6_NUMLOTE, "
			cQuery +=           " H6_IDENTE, "
			cQuery +=           " H6_IDEINV "
			cQuery +=    " FROM " + RetSqlName("SH6")
			cQuery +=    " WHERE (D_E_L_E_T_ = ' ') "
			cQuery +=      " AND (H6_PRODUTO = '" + cProduto + "') "
			cQuery +=      " AND (H6_FILIAL  = '" + xFilial("SH6") + "')) SH6 "
			
			cQuery +=  " ON SD3.D3_COD     = SH6.H6_PRODUTO "
			cQuery += " AND SD3.D3_IDENT   = SH6.H6_IDENT "
			cQuery += " AND SH6.H6_OP      = QPK.QPK_OP "
			cQuery += " AND SH6.H6_PRODUTO = QPK.QPK_PRODUT "
			
			cQuery += oManager:montaFiltroRastroCampo(cRastro, "QPK_LOTE", "H6_IDENTE", "H6_IDEINV", "H6_LOTECTL", "H6_NUMLOTE", .T.)

			cQuery := oManager:changeQuery(cQuery)
			cAlias := oManager:executeQuery(cQuery)

			If !(cAlias)->(EOF())
				lPermite := .F.
			EndIf
		Endif

		(cAlias)->(dbCloseArea())
	End Sequence

	ErrorBlock(oErrorBlock)

Return lPermite

/*/{Protheus.doc} QIPA215Estoque::bloqueiaManutencaoViaMATA175
Verifica se o registro da SD7 tem relacionamento com o QIP e bloqueia o uso no MATA175
@type method
@author rafael.hesse
@since 30/03/2023
@param 01 nRecno, Caracter, Indica o número da sequencia na SD3
@return lBoqueia, Lógico, Informa se bloqueia a manutenção via MATA175
/*/
Method bloqueiaManutencaoViaMATA175(nRecno) CLASS QIPA215Estoque
Local aAreaSD7 := SD7->(GetArea())
Local lBoqueia := .F.
	
	SD7->(DbGoTo(nRecno))
	lBoqueia := !Self:validaSeORegristoDaSD7EhRelacionadoAoQIP(SD7->D7_NUMERO,;
															   SD7->D7_PRODUTO,;
															   SD7->D7_NUMLOTE)
	RestArea(aAreaSD7)

Return lBoqueia

/*/{Protheus.doc} QIPA215Estoque::atualizaPotenciaEmTelaENaTabelaSD7
Metodo para atualizar o campo D7_POTENCI e a variável local
@type method
@author rafael.hesse
@since 11/04/2023
@param nPotencia, numeric, potencia informada na tela de alteração
/*/
Method atualizaPotenciaEmTelaENaTabelaSD7(nPotencia) CLASS QIPA215Estoque

	If nPotencia <> 0
		Self:retornaNumeroCQ() 
		RecLock("SD7",.F.)
			SD7->D7_POTENCI := nPotencia
		SD7->(MsUnLock())
	EndIf
	nPotenc175 := nPotencia

Return

/*/{Protheus.doc} QIPA215Est
Proteção nomenclatura do arquivo
@author brunno.costa
@since  14/09/2022
/*/
Function QIPA215Est()
Return

/*/{Protheus.doc} QIPA215ELO
Validação de Linha da Grid na aba Baixas do CQ - QIPA215
@author brunno.costa
@since  24/02/2023
@return lValida, lógico, indica se permite sair da linha
/*/
Function QIPA215ELO()
	Local lValida := A175LinOk()	
	oSelf:atualizaTotalizadoresPorArray()
	If lValida
		lValida := oSelf:validaMovimentoEstoqueCQxLaudoGeral()
	EndIf

Return lValida


/*/{Protheus.doc} QPA215ETVL
Gatilho para armazém de rejeite quando movimento tipo 2-Rejeite
Valida se o usuario tem permissão de estornar movimentações conforme MATA014
@type  Function
@author rafael.kleestadt
@since 25/01/2024
@version 1.0
@param param_name, param_type, param_descr
@return lRetorno, lógico, Sempre true para D7_TIPO pois é chamado junto com a validação de campos
                          Verdadeiro se usuario tem permissão de estornar movimentação caso D7_ESTORNO
@example
(examples)
@see (links_or_references)
/*/
Function QPA215ETVL()
	Local cCampoAtu := ReadVar()
	Local lRetorno  := .T.

	If cCampoAtu == 'M->D7_TIPO'
		oSelf:gatilhaArmazemDestino()
	ElseIf cCampoAtu == 'M->D7_ESTORNO'
		lRetorno := oSelf:validaSeUsuarioTemPermissaoParaEstornar()
	EndIf

Return lRetorno


/*/{Protheus.doc} gatilhaArmazemDestino
Preenche o campo com D7_LOCAL com armazém de rejeite
@author rafael.kleestadt
@since 24/01/2024
@version 1.0
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
/*/
Method gatilhaArmazemDestino() Class QIPA215Estoque
    Local cLocAprov := SuperGetMV("MV_CQLIBER", .F., "")
	Local cLocPe    := ""
    Local cLocRejei := SuperGetMV("MV_CQREJEI", .F., "97")
    Local nIndItem  := Len(Self:aCols)

    If M->D7_TIPO == 2
        Self:aCols[nIndItem, nCQPosLDes] := Iif(Empty(cLocRejei), "97", cLocRejei)
		
		If ExistBlock("A175ALMO")
            cLocPe := ExecBlock("A175ALMO",.F.,.F.,{Self:aCols[nIndItem, nCQPosLDes]})
            If ValType(cLocPe) == 'C'
                Self:aCols[nIndItem, nCQPosLDes] := cLocPe
            EndIf
        EndIf

        M->D7_LOCAL := Self:aCols[nIndItem, nCQPosLDes]

    ElseIf M->D7_TIPO == 1
        cLocAprov  := Iif(Empty(cLocAprov), RetFldProd(SD7->D7_PRODUTO,"B1_LOCPAD"), cLocAprov)
        cLocAprov  := Iif(Empty(cLocAprov), "01"                                   , cLocAprov)

		If ExistBlock("A175ALMO")
            cLocPe := ExecBlock("A175ALMO",.F.,.F.,{cLocAprov})
            If ValType(cLocPe) == 'C'
                cLocAprov := cLocPe
            EndIf
        EndIf

        Self:aCols[nIndItem, nCQPosLDes] := cLocAprov
        M->D7_LOCAL := Self:aCols[nIndItem, nCQPosLDes]
    EndIf
    
Return Nil

/*/{Protheus.doc} validaSeUsuarioTemPermissaoParaEstornar
Valida se o usuário tem permissão de estornar movimentações conforme MATA014
@author rafael.kleestadt
@since 25/01/2024
@version 1.0
@param param_name, param_type, param_descr
@return lRetorno, lógico, verdadeiro se usuário tem permissão de estornar movimentação caso D7_ESTORNO
/*/
Method validaSeUsuarioTemPermissaoParaEstornar() Class QIPA215Estoque
	Local lRetorno := .T.

	If M->D7_ESTORNO == "X"
		lRetorno := self:validaPermissaoDeAcessoEstornoMATA175()
	EndIf
	
Return lRetorno

/*/{Protheus.doc} validaPermissaoDeAcessoLiberacaoMATA175
Valida se o usuário tem acesso a opção Liberar/Rejeitar do MENU no MATA175
@author rafael.kleestadt
@since 25/01/2024
@version 1.0
@param param_name, param_type, param_descr
@param 01 - lExibeHelp, lógico, indica se deve exibir o help
@return lRetorno, lógico, verdadeiro se usuário tem permissão ao Liberar/Rejeitar no MATA175
/*/
Method validaPermissaoDeAcessoLiberacaoMATA175(lExibeHelp) Class QIPA215Estoque

	Local lRetorno     := .T.

	Default lExibeHelp := .T.

	If !MaAvalPerm(1,{SD7->D7_PRODUTO,"MTA175",3}) .OR. !MPUserHasAccess("MATA175",3,,.F.)
		lRetorno := .F.
		If lExibeHelp
			Help(,,1,'SEMPERM')
		EndIf
	EndIf
	
Return lRetorno

/*/{Protheus.doc} validaPermissaoDeAcessoEstornoMATA175
Valida se o usuário tem acesso a opção Estorno do MENU no MATA175
@author rafael.kleestadt
@since 25/01/2024
@version 1.0
@param param_name, param_type, param_descr
@return lRetorno, lógico, verdadeiro se usuário tem permissão ao Estorno no MATA175
/*/
Method validaPermissaoDeAcessoEstornoMATA175() Class QIPA215Estoque
	Local lRetorno := .T.

	If !MaAvalPerm(1,{SD7->D7_PRODUTO,"MTA175",5}) .OR. !MPUserHasAccess("MATA175",4,,.F.)
		Help(,,1,'SEMPERM')
		lRetorno := .F.
	EndIf
	
Return lRetorno





