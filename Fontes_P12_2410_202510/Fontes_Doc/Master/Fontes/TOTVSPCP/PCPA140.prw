#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA140.CH"

#DEFINE IND_TELA_PRODUTOS     1
#DEFINE IND_TELA_INDICA_PROD  2
#DEFINE IND_TELA_ESTRUTURA    3
#DEFINE IND_TELA_VERSAO_PROD  4
#DEFINE IND_TELA_OPER_COMPON  5
#DEFINE IND_TELA_CALENDARIOS  6
#DEFINE IND_TELA_DEMANDAS     7
#DEFINE IND_TELA_ORDEM_PROD   8
#DEFINE IND_TELA_EMPENHOS     9
#DEFINE IND_TELA_SOL_COMPRAS  10
#DEFINE IND_TELA_PED_COMPRAS  11
#DEFINE IND_TELA_ESTOQUES     12
#DEFINE IND_TELA_CQ           13
#DEFINE IND_TELA_ARMAZEM      14

#DEFINE IND_PAR_CHECKED       1
#DEFINE IND_PAR_ALIAS         2
#DEFINE IND_PAR_QUERY         3
#DEFINE IND_PAR_QTD_TOTAL     4
#DEFINE IND_PAR_QTD_SUCESSO   5
#DEFINE IND_PAR_QTD_ERRO      6
#DEFINE IND_PAR_DESCRICAO     7
#DEFINE IND_PAR_API           8
#DEFINE IND_PAR_PROCESSADO    9
#DEFINE IND_PAR_VISIVEL      10
#DEFINE IND_PAR_MSG_ERRO     11
#DEFINE IND_PAR_STATUS       12
#DEFINE IND_PAR_CORE_QUERY   13
#DEFINE QTD_IND_PAR          13
#DEFINE VOL_BUFFER           200

Static _aFilsSMQ := {}
Static _cCompTab := ""
Static _lTemSMQ  := Nil
Static _nTamFil  := 0

/*/{Protheus.doc} PCPA140
Programa de Sincronização de dados com o MRP
@author  Marcelo Neumann
@version P12
@since   17/07/2019
/*/
Function PCPA140(lLogSync, aApiAlter, lTela, cTicket)

	Local lChecked  := .F.
	Local oCheckAll
	Local oChkPrd
	Local oBtnProc
	Local oBtnSair
	Local oDlgSinc
	Local oPnlBottom
	Local oPnlTop
	Local oTFont   := TFont():New('Arial',,-13,,.T.)
	Local oPCPLock := PCPLockControl():New()

	/*nEspera, nNumerico, indica o comportamento relacionado a espera e falha na tentativa de reserva: PCPLockControl
	0 - Não aguarda lock e não exibe help
	1 - Não aguarda lock e exibe Help de Falha
	2 - Aguarda para fazer lock e não exibe tela de aguarde;
	3 - Aguarda para fazer lock e exibe tela de aguarde;*/
	Local nEspera      := 3
	Local lLock        := .F.

	Default lLogSync   := .T.
	Default lTela      := .T.
	Default aApiAlter  := {}
	Default cTicket    := ""

	Private aParTela   := {}
	Private nLinha     := 25
	Private nLinhaC2   := 25
	Private lVisual    := lTela
	Private nCountItem := 0
	Private aEmprCent  := {}

	If GetRpoRelease() < "12.1.025"
        HELP(' ',1,"Release" ,,STR0062,2,0,,,,,,) //"Rotina disponível a partir do release 12.1.25."
        Return
    EndIf

	//Se a tabela T4R não estiver em modo compartilhado, não permite abertura da tela
	If !FWModeAccess("T4R",1) == "C" .Or. !FWModeAccess("T4R",2) == "C" .Or. !FWModeAccess("T4R",3) == "C"
		HELP(' ', 1, "Help",,STR0053 ,; //"A rotina não pode ser inciada pois tabela T4R (pendências do MRP) está com modo de compartilhamento incorreto)."
		     2, 0, , , , , , {STR0054}) //"Altere o modo de compartilhamento da tabela T4R para 'Compartilhado'."
		Return
	Else
		//Se a integração não estiver habilitada, não permite utilizar a tela de sincronização.
		If !IntNewMRP("MRPDEMANDS")
			HELP(' ', 1, "Help",, STR0030,; //"Integração com o MRP não está habilitada."
				2, 0, , , , , , {STR0031}) //"Ative a integração com o MRP para utilizar o programa de Sincronização."
			Return
		EndIf
	EndIf

	If EhFilCentr()
        HELP(' ',1,"Help",,STR0064,2,0,,,,,,) //"Não é possível executar a rotina para uma empresa centralizada. Execute na respectiva empresa centralizadora."
        Return
    EndIf

	If FWAliasInDic("SMQ",.F.) .And. !mrpInSMQ(cFilAnt)
		Help('', 1, "Help", , STR0069,; // "Não é permitada a sincronização na filial atual."
			2, 0, , , , , , {STR0070}) // "Para sincronizar esta filial, realize o cadastro nas configurações do MRP (PCPA139)."
		Return
	EndIf

	If lTela //Aguarda reserva de lock do MRP Memoria
		lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA140", "", .F., {"PCPA712","PCPA140","PCPA145","PCPA151"}, nEspera)
	EndIf

	//Execução sem tela a partir do PCPA712 ou com lock realizado pelo PCPA140
	If !lTela .OR. lLock

		If Len(aApiAlter) == 0
			//Define a tela e seus painéis
			DEFINE DIALOG oDlgSinc TITLE STR0001 FROM 0,0 TO 430, 460 PIXEL //"Sincronizador MRP"

			oPnlTop := TPanel():New(01, 01, , oDlgSinc, , , , , , 415, 300, .T.,.T.)
			oPnlTop:Align := CONTROL_ALIGN_TOP

			oPnlBottom := TPanel():New(300, 01, ,oDlgSinc, , , , , , 415, 20, .T.,.T.)
			oPnlBottom:Align := CONTROL_ALIGN_BOTTOM

			//Cria o checkbox para marcar/desmarcar todos
			@ 15, 70 CHECKBOX oCheckAll VAR lChecked PROMPT STR0002 ON CHANGE MarcaTodos(lChecked, oCheckAll, oChkPrd) PIXEL OF oPnlTop SIZE 100,015 MESSAGE "" font oTFont //"Marca/Desmarca todos"
		EndIf

		//Adiciona os parâmetros da tela
		oChkPrd := AddParam(oPnlTop, IND_TELA_PRODUTOS, "SB1", P139GetAPI("MRPPRODUCT"  ), "MRPPRODUCT"          , lTela)     //"Produtos"
		AddParam(oPnlTop, IND_TELA_INDICA_PROD, "SBZ", P139GetAPI("MRPPRODUCTINDICATOR" ), "MRPPRODUCTINDICATOR" , lTela)     //"Indicadores Produtos"
		AddParam(oPnlTop, IND_TELA_ESTRUTURA  , "SG1", P139GetAPI("MRPBILLOFMATERIAL"   ), "MRPBILLOFMATERIAL"   , lTela)     //"Estrutura"
		AddParam(oPnlTop, IND_TELA_VERSAO_PROD, "SVC", P139GetAPI("MRPPRODUCTIONVERSION"), "MRPPRODUCTIONVERSION", lTela)     //"Versão da Produção"
		AddParam(oPnlTop, IND_TELA_OPER_COMPON, "SGF", P139GetAPI("MRPBOMROUTING"       ), "MRPBOMROUTING"       , lTela .AND. FWAliasInDic( "HW9", .F. ))  //"Operações por Componente"
		AddParam(oPnlTop, IND_TELA_CALENDARIOS, "SVZ", P139GetAPI("MRPCALENDAR"         ), "MRPCALENDAR"         , lTela)     //"Calendários"
		AddParam(oPnlTop, IND_TELA_DEMANDAS   , "SVR", P139GetAPI("MRPDEMANDS"          ), "MRPDEMANDS"          , lTela)     //"Demandas"
		AddParam(oPnlTop, IND_TELA_ORDEM_PROD , "SC2", P139GetAPI("MRPPRODUCTIONORDERS" ), "MRPPRODUCTIONORDERS" , lTela)     //"Ordem de Produção"
		AddParam(oPnlTop, IND_TELA_EMPENHOS   , "SD4", P139GetAPI("MRPALLOCATIONS"      ), "MRPALLOCATIONS"      , lTela)     //"Empenhos"
		AddParam(oPnlTop, IND_TELA_SOL_COMPRAS, "SC1", P139GetAPI("MRPPURCHASEORDER"    ), "MRPPURCHASEORDER"    , lTela)     //"Solicitações de Compras"
		AddParam(oPnlTop, IND_TELA_PED_COMPRAS, "SC7", P139GetAPI("MRPPURCHASEREQUEST"  ), "MRPPURCHASEREQUEST"  , lTela)     //"Pedidos de Compras"
		AddParam(oPnlTop, IND_TELA_ESTOQUES   , "SB2", P139GetAPI("MRPSTOCKBALANCE"     ), "MRPSTOCKBALANCE"     , lTela)     //"Estoques"
		AddParam(oPnlTop, IND_TELA_CQ         , "SD7", P139GetAPI("MRPREJECTEDINVENTORY"), "MRPREJECTEDINVENTORY", lTela .AND. FWAliasInDic( "HWX", .F. ))  //"CQ"
		AddParam(oPnlTop, IND_TELA_ARMAZEM    , "NNR", P139GetAPI("MRPWAREHOUSE"        ), "MRPWAREHOUSE"        , lTela .AND. FWAliasInDic( "HWY", .F. ))  //"Armazens"

		If Len(aApiAlter) > 0
			procExt(aApiAlter, cTicket)
		Else
			//Botões
			@ 03, 015 BUTTON oBtnSair PROMPT STR0004 SIZE 70,12 WHEN (.T.) ACTION (oDlgSinc:End()) OF oPnlBottom PIXEL //"Sair"
			@ 03, 150 BUTTON oBtnProc PROMPT STR0005 SIZE 70,12 WHEN (.T.) ACTION (Processar(cTicket))    OF oPnlBottom PIXEL //"Processar"
			//Abre a tela
			ACTIVATE MSDIALOG oDlgSinc CENTERED ON INIT Iif(lLogSync, logSync(), .T.)
		EndIf

		If lLock
			oPCPLock:unlock("MRP_MEMORIA", "PCPA140")
		EndIf

	EndIf

Return

/*/{Protheus.doc} AddParam
Adiciona um parâmetro na tela (Checkbox, Descrição e Botão de filtro)
@author  Marcelo Neumann
@version P12
@since   17/07/2019
@param   01 oDialog   , objeto  , tela onde serão criados os componentes
@param   02 nIndTela  , numérico, indicador da posição do item na tela
@param   03 cAlias    , caracter, tabela a ser utilizada no filtro
@param   04 cDescricao, caracter, descrição/label do checkbox
@param   05 cApi      , caracter, nome da API que esse parâmetro utilizará
@param   06 lVisivel  , lógico  , indica se o checkbox deverá ser exibido
@return  oCheck       , objeto  , objeto com o checkbox criado
/*/
Static Function AddParam(oDialog, nIndTela, cAlias, cDescricao, cApi, lVisivel)

	Local oCheck
	Local oTFont := TFont():New('Arial',,-12)

	//Adiciona uma posição no array de controle (aParTela)
	aAdd(aParTela, Array(QTD_IND_PAR))

	//Atribui default para os campos
	aParTela[nIndTela][IND_PAR_CHECKED]      := .F.
	aParTela[nIndTela][IND_PAR_API]          := cApi
	aParTela[nIndTela][IND_PAR_PROCESSADO]   := .F.
	aParTela[nIndTela][IND_PAR_VISIVEL]      := lVisivel
	aParTela[nIndTela][IND_PAR_MSG_ERRO]	 := ""
	IniParTela()

	//Cria na tela o checkbox
	If lVisivel
		If @nCountItem > 9
			nLinhaC2 += 15
			@ nLinhaC2, 130 CHECKBOX oCheck VAR aParTela[nIndTela][IND_PAR_CHECKED] PROMPT cDescricao PIXEL OF oDialog SIZE 150,015 MESSAGE "" FONT oTFont
		Else
			nLinha += 15
			@ nLinha, 15 CHECKBOX oCheck VAR aParTela[nIndTela][IND_PAR_CHECKED] PROMPT cDescricao PIXEL OF oDialog SIZE 150,015 MESSAGE "" FONT oTFont
		EndIf
		@nCountItem++
	EndIf

	aParTela[nIndTela][IND_PAR_ALIAS]     := cAlias
	aParTela[nIndTela][IND_PAR_DESCRICAO] := cDescricao

Return oCheck

/*/{Protheus.doc} MarcaTodos
Marca/Desmarca todos os checkboxs
@author  Marcelo Neumann
@version P12
@since   17/07/2019
@param   01 lChecked , lógico, indica se foi marcado ou desmarcado o checkbox de marcar todos
@param   02 oCheckAll, objeto, objeto do checkbox Marca/Desmarca todos
@param   03 oChecks  , objeto, objeto dos demais checkboxs para atualizar o conteúdo em tela
@return  .T.
/*/
Static Function MarcaTodos(lChecked, oCheckAll, oChecks)

	Local nInd   := 1
	Local nTotal := Len(aParTela)

	//Marca todos os parâmetros que podem ser marcados
	For nInd := 1 To nTotal
		If aParTela[nInd][IND_PAR_VISIVEL]
			aParTela[nInd][IND_PAR_CHECKED] := lChecked
		EndIf
	Next nInd

	//Dá foco para atualizar a tela com as marcações
	SetFocus(oChecks:HWND)

Return .T.

/*/{Protheus.doc} Processar
Função principal de processamento dos dados
@author  Marcelo Neumann
@version P12
@since   17/07/2019
@param cTicket, caracter, Número do ticket de processamento do MRP
@return  NIL
/*/
Static Function Processar(cTicket)
	Local nIndFilEmp := 0
	Local nTotFilEmp := 0
	Local nTotal     := 0

	//Verifica se foi selecionado algum registro para processar
	If aScan(aParTela, {|x| x[IND_PAR_CHECKED]}) < 1
		Help('', 1, "Help", , STR0008,; //"Nenhum registro selecionado."
		     2, 0, , , , , , {STR0009}) //"Marque algum registro para prosseguir com a sincronização."
		Return .F.
	EndIf

	If FWAliasInDic("SMQ",.F.)
		aEmprCent := getFilsSMQ()
	Else
		aEmprCent := CargEmprC(cEmpAnt, cFilAnt)
	EndIf

	nTotFilEmp := Len(aEmprCent)

	For nIndFilEmp := 1 To nTotFilEmp

		//Filtra os registros retornando a quantidade
		nTotal += IIF(aParTela[IND_TELA_CALENDARIOS][IND_PAR_CHECKED], padContReg(IND_TELA_CALENDARIOS, aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_DEMANDAS][IND_PAR_CHECKED]   , padContReg(IND_TELA_DEMANDAS   , aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_VERSAO_PROD][IND_PAR_CHECKED], padContReg(IND_TELA_VERSAO_PROD, aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_INDICA_PROD][IND_PAR_CHECKED], padContReg(IND_TELA_INDICA_PROD, aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_ARMAZEM][IND_PAR_CHECKED]    , padContReg(IND_TELA_ARMAZEM    , aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_OPER_COMPON][IND_PAR_CHECKED], padContReg(IND_TELA_OPER_COMPON, aEmprCent[nIndFilEmp][2]), 0)

		nTotal += IIF(aParTela[IND_TELA_PRODUTOS][IND_PAR_CHECKED]   , PrdContReg()                        , 0)
		nTotal += IIF(aParTela[IND_TELA_ESTRUTURA][IND_PAR_CHECKED]  , EtrContReg(aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_ORDEM_PROD][IND_PAR_CHECKED] , OrdContReg(aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_EMPENHOS][IND_PAR_CHECKED]   , EmpContReg(aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_ESTOQUES][IND_PAR_CHECKED]   , EstContReg(aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_SOL_COMPRAS][IND_PAR_CHECKED], SolContReg(aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_PED_COMPRAS][IND_PAR_CHECKED], PecContReg(aEmprCent[nIndFilEmp][2]), 0)
		nTotal += IIF(aParTela[IND_TELA_CQ][IND_PAR_CHECKED]         , CqlContReg(aEmprCent[nIndFilEmp][2]), 0)

	Next nIndFilEmp

	If !lVisual
		Processa( {|| GerenProc(nTotal, cTicket) }, STR0016, STR0015,.F.) //"Aguarde..." "Sincronizando..."
	Else
		If nTotal == 0
			If MsgYesNo(STR0060, STR0014) //"Deseja continuar com a sincronização dos registros?" "Atenção"
				//Monta a barra de progresso e os parâmetros
				Processa( {|| GerenProc(nTotal, cTicket) }, STR0016, STR0015,.F.) //"Aguarde..." "Sincronizando..."
			EndIf
		ElseIf MsgYesNo(STR0012 + cValToChar(nTotal) + STR0013, STR0014) //"Serão processados" X "registros, deseja continuar?" "Atenção"
			//Monta a barra de progresso e os parâmetros
			Processa( {|| GerenProc(nTotal, cTicket) }, STR0016, STR0015,.F.) //"Aguarde..." "Sincronizando..."
		EndIf
	EndIf

	aSize(aEmprCent, 0)

	IniParTela()

Return

/*/{Protheus.doc} IniParTela
Inicializa o array com os parâmetros da tela
@author  Marcelo Neumann
@version P12
@since   17/07/2019
@return  NIL
/*/
Static Function IniParTela()

	Local nInd := 1

	For nInd := 1 To Len(aParTela)
		If aParTela[nInd][IND_PAR_QTD_TOTAL] > 0
			aParTela[nInd][IND_PAR_QTD_TOTAL]    := 0
			aParTela[nInd][IND_PAR_QTD_SUCESSO]  := 0
			aParTela[nInd][IND_PAR_QTD_ERRO]     := 0
		EndIf
		aParTela[nInd][IND_PAR_PROCESSADO] := .F.
		aParTela[nInd][IND_PAR_MSG_ERRO]   := ""

		// Limpa as querys do ultimo processamento
		If aParTela[nInd][IND_PAR_QUERY] != Nil
			aSize(aParTela[nInd][IND_PAR_QUERY], 0)
		EndIf

		// Limpa as querys do ultimo processamento
		If aParTela[nInd][IND_PAR_CORE_QUERY] != Nil
			aSize(aParTela[nInd][IND_PAR_CORE_QUERY], 0)
		EndIf

	Next nInd

Return

/*/{Protheus.doc} GerenProc
Gerencia o processamento dos parâmetros
@author  Marcelo Neumann
@version P12
@since   17/07/2019
@param   01 nTotal  , numérico, total de registros que serão processados
@param   02 cTicket , caracter, Número do ticket de processamento do MRP
@return  NIL
/*/
Static Function GerenProc(nTotal, cTicket)
	Local aJobs      := {}
	Local aRetVal    := {}
	Local aProc      := {}
	Local cValue     := ""
	Local cCarga     := ""
	Local cErros     := ""
	Local lCargaAll  := .F.
	Local nCountTot  := 0
	Local nCountAux  := 0
	Local nIndex     := 0
	Local nFinished  := 0
	Local nQtdErrors := 0
	Local oPCPError  := Nil

	//Adequa o total de passos da barra de progresso superior
	nTotal := nTotal + 4

	ProcRegua(nTotal)

	IncProc(STR0049) //"Iniciando processamentos"

	aRetVal := VldCampTam()

	If aRetVal[3] == 0
		oPCPError := PCPMultiThreadError():New("PCPA140SINC", .T.)
		//Se está processando a sincronização através do PCPA712, faz o controle de lock
		If cTicket <> "000000"
			PCPLock("PCPA712_PCPA140_PROC")
		EndIf

		For nIndex := 1 To Len(aParTela)
			If aParTela[nIndex][IND_PAR_CHECKED]
				aParTela[nIndex][IND_PAR_PROCESSADO] := .F.
				cValue := cValToChar(ThreadId()) + "PCPA140JOB" + cValToChar(nIndex)

				aAdd(aJobs, {cValue, nIndex})
				PutGlbValue(cValue, "0")
				PutGlbValue(cValue+"TOTAL"    , "0")
				PutGlbValue(cValue+"CARGA"    , "0")
				PutGlbValue(cValue+"SUCESSO"  , "0")
				PutGlbValue(cValue+"ERRO"     , "0")
				PutGlbValue(cValue+"LOG_ERROR", "0")
				GlbUnLock()

				oPCPError:startJob("PCPA140JOB", GetEnvServer(), .F., cEmpAnt, cFilAnt, cValue, nIndex, aParTela, aEmprCent)
			EndIf
		Next nIndex
	Else
		For nIndex := 1 To Len(aParTela)
			aParTela[nIndex][IND_PAR_PROCESSADO]  := .F.
			aParTela[nIndex][IND_PAR_MSG_ERRO]    := STR0063 //"Não processado devido inconsistências encontradas na validação da integridade da base de dados."
			aParTela[nIndex][IND_PAR_QTD_SUCESSO] := 0
			aParTela[nIndex][IND_PAR_QTD_ERRO]    := 0
		Next nIndex
		aAdd(aProc, {.T.,"VAL","",aRetVal[2]+aRetVal[3],aRetVal[2],aRetVal[3],STR0061,"VALIDADOR",.T.,.T.,aRetVal[1], Nil})
		nQtdErrors++
		PutGlbValue(cTicket+"ERROSINCVALID", aRetVal[1])
	EndIf

	IncProc(STR0050) //"Aguardando processamentos"

	//Aguarda os jobs finalizarem
	While .T.
		nCountAux := 0
		nFinished := 0
		lCargaAll := .T.

		For nIndex := 1 To Len(aJobs)
			nCountAux += Val(GetGlbValue(aJobs[nIndex][1]+"TOTAL"))

			If aParTela[aJobs[nIndex][2]][IND_PAR_PROCESSADO]
				nFinished++
				Loop
			EndIf

			cValue    := GetGlbValue(aJobs[nIndex][1])
			cCarga    := GetGlbValue(aJobs[nIndex][1]+"CARGA")

			If cCarga == "0" .Or. Empty(cCarga)
				lCargaAll := .F.
			EndIf

			If cValue == "1"
				//Processou com sucesso
				aParTela[aJobs[nIndex][2]][IND_PAR_QTD_SUCESSO]  := Val(GetGlbValue(aJobs[nIndex][1]+"SUCESSO"))
				aParTela[aJobs[nIndex][2]][IND_PAR_QTD_ERRO]     := Val(GetGlbValue(aJobs[nIndex][1]+"ERRO"))
				aParTela[aJobs[nIndex][2]][IND_PAR_PROCESSADO]   := .T.
				If aParTela[aJobs[nIndex][2]][IND_PAR_QTD_ERRO] > 0
					nQtdErrors += aParTela[aJobs[nIndex][2]][IND_PAR_QTD_ERRO]
				EndIf
				nFinished++
			ElseIf cValue == "2"
				aParTela[aJobs[nIndex][2]][IND_PAR_MSG_ERRO] := GetGlbValue(aJobs[nIndex][1]+"LOG_ERROR")
				nQtdErrors++
				nFinished++
			EndIf
		Next nIndex

		If nFinished == Len(aJobs)
			Exit
		EndIf

		//Atualiza a barra de progresso
		If lCargaAll
			IncProc(STR0052) //"Enviando dados..."
			ProcRegua(0)
			SysRefresh()
		Else
			For nIndex := 1 To (nCountAux-nCountTot)
				IncProc(STR0015 + cValToChar(nCountAux) + STR0019 + cValToChar(nTotal-4)) //"Sincronizando dados... " x " de " y
				PutGlbValue(cTicket+"PERCENTUALSINC", CVALTOCHAR(Round((nCountTot*100)/(nTotal-4), 2)))
			Next nIndex
			nCountTot := nCountAux
		EndIf

		Sleep(50)
	End

	IncProc(STR0027) //"Atualizando parametros"
	UpdateT4P()

	//Limpa os valores das variáveis globais criadas.
	For nIndex := 1 To Len(aJobs)
		If GetGlbValue(aJobs[nIndex][1]) == "2"
			If Empty(cErros)
				cErros += aJobs[nIndex][1] + ": " + aParTela[aJobs[nIndex][2]][IND_PAR_MSG_ERRO]
			Else
				cErros += "; " + aJobs[nIndex][1] + ": " + aParTela[aJobs[nIndex][2]][IND_PAR_MSG_ERRO]
			EndIf
		EndIf
		ClearGlbValue(aJobs[nIndex][1])
		ClearGlbValue(aJobs[nIndex][1]+"TOTAL"  )
		ClearGlbValue(aJobs[nIndex][1]+"CARGA"  )
		ClearGlbValue(aJobs[nIndex][1]+"SUCESSO")
		ClearGlbValue(aJobs[nIndex][1]+"ERRO"   )
		ClearGlbValue(aJobs[nIndex][1]+"LOG_ERROR")
		GlbUnLock()
	Next nIndex

	PCPUnLock("PCPA712_PCPA140_PROC")

	If nQtdErrors > 0
		PutGlbValue(cTicket+"QTDERROSSINC", cValToChar(nQtdErrors))
		PutGlbValue(cTicket+"CERROSSINC"  , cErros)
	EndIf

	For nIndex := 1 To Len(aParTela)
		If aParTela[nIndex][IND_PAR_CHECKED]
			If aParTela[nIndex][IND_PAR_QTD_SUCESSO] == Nil
				aParTela[nIndex][IND_PAR_QTD_SUCESSO] := 0
			EndIf
			If aParTela[nIndex][IND_PAR_QTD_ERRO] == Nil
				aParTela[nIndex][IND_PAR_QTD_ERRO] := 0
			EndIf
			aAdd(aProc, aParTela[nIndex])
		EndIf
	Next nIndex

	//Mostra a tela com o resultado do processamento
	IncProc(STR0022) //"Sumarizando os resultados..."
	If lVisual
		ResultProc(aProc)
	EndIf
	aSize(aProc, 0)

    If oPCPError <> Nil
	  oPCPError:destroy()
	EndIf
Return

/*/{Protheus.doc} PCPA140JOB
Função para executar a sincronização em multi-thread.

@type  Function
@author lucas.franca
@since 06/08/2019
@version P12.1.28
@param 01 cJobName  , Character, Nome identificador do JOB
@param 02 nSync     , Numeric  , Identificador da entidade a sincronizar.
@param 03 aParamTela, Array    , Array com os parâmetros da tela.
@param 04 aFiliais  , Array    , Filiais a serem excluídas pela sincronização.
@return Nil
/*/
Function PCPA140JOB(cJobName, nSync, aParamTela, aFiliais)

	Private aParTela  := aParamTela
	Private aEmprCent := aFiliais

	ErrorBlock({|e| A140Error(e, cJobName) })

	Begin Sequence

		SetFunName("PCPA140") //Seta a função inicial para PCPA140

		Do Case
			Case nSync == IND_TELA_CALENDARIOS
				SincCalend(cJobName)
			Case nSync == IND_TELA_DEMANDAS
				SincDemand(cJobName)
			Case nSync == IND_TELA_EMPENHOS
				SincEmpe(cJobName)
			Case nSync == IND_TELA_ESTRUTURA
				SincEstrut(cJobName)
			Case nSync == IND_TELA_OPER_COMPON
				SincOpComp(cJobName)
			Case nSync == IND_TELA_ORDEM_PROD
				SincOrdPrd(cJobName)
			Case nSync == IND_TELA_PED_COMPRAS
				SincPedCom(cJobName)
			Case nSync == IND_TELA_SOL_COMPRAS
				SincSolCom(cJobName)
			Case nSync == IND_TELA_VERSAO_PROD
				SincPrdVer(cJobName)
			Case nSync == IND_TELA_ESTOQUES
				SincStock(cJobName)
			Case nSync == IND_TELA_CQ
				SincCQ(cJobName)
			Case nSync == IND_TELA_PRODUTOS
				SincProd(cJobName)
			Case nSync == IND_TELA_INDICA_PROD
				SincIndPrd(cJobName)
			Case nSync == IND_TELA_ARMAZEM
				SincArmaz(cJobName)
		EndCase
		PutGlbValue(cJobName, "1")
		GlbUnLock()

		//Caso ocorra algum erro, seta a flag com o valor 2.
		RECOVER
			PutGlbValue(cJobName, "2")
			GlbUnLock()

	End Sequence

	FwFreeArray(aParTela)
	FwFreeArray(aEmprCent)

Return Nil

/*/{Protheus.doc} A140Error
Função para tratativa de erros de execução

@type  Function
@author lucas.franca
@since 06/08/2019
@version P12.1.28
@param e, Object, Objeto com os detalhes do erro ocorrido
/*/
Function A140Error(e, cJobName)
	Local cMessage := AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack)
	LogMsg('PCPA140JOB', 0, 0, 1, '', '', ;
	       Replicate("-",70) + CHR(10) + cMessage + CHR(10) + Replicate("-",70))
	PutGlbValue(cJobName+"LOG_ERROR", cMessage)
	BREAK
Return

/*/{Protheus.doc} SincCalend
Sincroniza os Calendários
@author  brunno.costa
@version P12
@since   05/08/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincCalend(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cQryCondic := ""
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nSuccess 	 := 0
	Local nTotal     := 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_CALENDARIOS][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(A131APICnt("ARRAY_CALENDAR_SIZE")))
		aDadosInc[nPos][A131APICnt("ARRAY_CALENDAR_POS_FILIAL")] := xFilial("SVZ", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do PCPA131API para integrar os registros
	PCPA131INT("SYNC", aDadosInc, @aSuccess, @aError, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_CALENDARIOS][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_CALENDARIOS][IND_PAR_QUERY][nIndex]

		BeginSql Alias cAliasQry
			COLUMN VZ_DATA AS DATE
			SELECT VZ_FILIAL,
				VZ_CALEND,
				VZ_DATA,
				VZ_HORAINI,
				VZ_HORAFIM,
				VZ_INTERVA,
				R_E_C_N_O_
			FROM %Exp:cQryCondic%
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(A131APICnt("ARRAY_CALENDAR_SIZE")))
			nPos++

			//Adiciona as informações no array de inclusão/atualização
			aDadosInc[nPos][A131APICnt("ARRAY_CALENDAR_POS_FILIAL")] := (cAliasQry)->VZ_FILIAL
			aDadosInc[nPos][A131APICnt("ARRAY_CALENDAR_POS_CALEND")] := (cAliasQry)->VZ_CALEND
			aDadosInc[nPos][A131APICnt("ARRAY_CALENDAR_POS_DATA"  )] := (cAliasQry)->VZ_DATA
			aDadosInc[nPos][A131APICnt("ARRAY_CALENDAR_POS_HRAINI")] := (cAliasQry)->VZ_HORAINI
			aDadosInc[nPos][A131APICnt("ARRAY_CALENDAR_POS_HRAFIM")] := (cAliasQry)->VZ_HORAFIM
			aDadosInc[nPos][A131APICnt("ARRAY_CALENDAR_POS_INTER" )] := (cAliasQry)->VZ_INTERVA

			(cAliasQry)->(dbSkip())
			If nPos > VOL_BUFFER .Or. (cAliasQry)->(Eof())
				//Chama a função do PCPA131API para integrar os registros
				PCPA131INT("SYNC", aDadosInc, @aSuccess, @aError, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincEmpe
Sincroniza os Empenhos
@author  brunno.costa
@version P12
@since   05/08/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincEmpe(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cQryCondic := ""
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nSuccess 	 := 0
	Local nTamQtd    := GetSx3Cache("D4_QUANT", "X3_TAMANHO")
	Local nTamDec    := GetSx3Cache("D4_QUANT", "X3_DECIMAL")
	Local nTotal     := 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_EMPENHOS][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(A381APICnt("ARRAY_SIZE")))
		aDadosInc[nPos][A381APICnt("ARRAY_POS_FILIAL")] := xFilial("SD4", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do PCPA381API para integrar os registros
	PCPA381INT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_EMPENHOS][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_EMPENHOS][IND_PAR_QUERY][nIndex]

		BeginSql Alias cAliasQry
			COLUMN D4_DATA  AS DATE
			COLUMN D4_QUANT AS NUMERIC(nTamQtd, nTamDec)
			COLUMN D4_QSUSP AS NUMERIC(nTamQtd, nTamDec)
			SELECT D4_FILIAL,
				D4_COD,
				D4_OP,
				D4_OPORIG,
				D4_DATA,
				D4_TRT,
				D4_QUANT,
				D4_QSUSP,
				D4_LOCAL,
				R_E_C_N_O_
			FROM %Exp:cQryCondic%
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(A381APICnt("ARRAY_SIZE")))
			nPos++

			//Adiciona as informações no array de inclusão/atualização
			aDadosInc[nPos][A381APICnt("ARRAY_POS_FILIAL" )] := (cAliasQry)->D4_FILIAL
			aDadosInc[nPos][A381APICnt("ARRAY_POS_PROD"   )] := (cAliasQry)->D4_COD
			aDadosInc[nPos][A381APICnt("ARRAY_POS_OP"     )] := (cAliasQry)->D4_OP
			aDadosInc[nPos][A381APICnt("ARRAY_POS_OP_ORIG")] := (cAliasQry)->D4_OPORIG
			aDadosInc[nPos][A381APICnt("ARRAY_POS_DATA"   )] := (cAliasQry)->D4_DATA
			aDadosInc[nPos][A381APICnt("ARRAY_POS_SEQ"    )] := (cAliasQry)->D4_TRT
			aDadosInc[nPos][A381APICnt("ARRAY_POS_QTD"    )] := (cAliasQry)->D4_QUANT
			aDadosInc[nPos][A381APICnt("ARRAY_POS_QSUSP"  )] := (cAliasQry)->D4_QSUSP
			aDadosInc[nPos][A381APICnt("ARRAY_POS_LOCAL"  )] := (cAliasQry)->D4_LOCAL
			aDadosInc[nPos][A381APICnt("ARRAY_POS_RECNO"  )] := cValToChar((cAliasQry)->R_E_C_N_O_)

			(cAliasQry)->(dbSkip())
			If nPos > VOL_BUFFER .Or. (cAliasQry)->(Eof())
				//Chama a função do PCPA381API para integrar os registros
				PCPA381INT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincDemand
Sincroniza as Demandas
@author  Marcelo Neumann
@version P12
@since   17/07/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincDemand(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cFilBkp    := cFilAnt
	Local cQryCondic := ""
	Local cQryFields := ""
	Local cRevisao   := ""
	Local lTrocouFil := .F.
	Local lVRRev     := GetSx3Cache("VR_REV", "X3_TAMANHO") > 0
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nSuccess 	 := 0
	Local nTamDec    := GetSx3Cache("VR_QUANT", "X3_DECIMAL")
	Local nTamQtd    := GetSx3Cache("VR_QUANT", "X3_TAMANHO")
	Local nTotal     := 0
	Local oTTInteg   := P136APITMP() //Cria temporárias para a PCPA136INT

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_DEMANDAS][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(A136APICnt("ARRAY_DEMAND_SIZE")))
		aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_FILIAL")] := xFilial("SVR", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do PCPA136API para integrar os registros
	PCPA136INT("SYNC", aDadosInc, oTTInteg, @aSuccess, @aError, /*cUUID*/, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_DEMANDAS][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_DEMANDAS][IND_PAR_QUERY][nIndex]
		cQryFields := " VR_FILIAL, VR_CODIGO, VR_SEQUEN, VR_PROD, VR_DATA, VR_TIPO, VR_DOC,	VR_QUANT, VR_LOCAL,	VR_NRMRP, VR_OPC"
		If lVRRev
			cQryFields += ", VR_REV"
		EndIf
		cQryFields += ", VR_MOPC"

		cQryFields := "%"+cQryFields+"%"

		BeginSql Alias cAliasQry
			COLUMN VR_DATA  AS DATE
			COLUMN VR_QUANT AS NUMERIC(nTamQtd, nTamDec)
			SELECT %Exp:cQryFields%
			  FROM %Exp:cQryCondic%
			 ORDER BY VR_FILIAL
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			cRevisao := ""

			If lVRRev
				cRevisao := (cAliasQry)->VR_REV
			EndIf

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(A136APICnt("ARRAY_DEMAND_SIZE")))
			nPos++

			//Adiciona as informações no array de inclusão/atualização
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_FILIAL" )] := (cAliasQry)->VR_FILIAL
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_CODE"   )] := (cAliasQry)->VR_CODIGO
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_SEQUEN" )] := (cAliasQry)->VR_SEQUEN
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_PROD"   )] := (cAliasQry)->VR_PROD
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_REV"    )] := ""
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_DATA"   )] := (cAliasQry)->VR_DATA
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_TIPO"   )] := (cAliasQry)->VR_TIPO
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_DOC"    )] := (cAliasQry)->VR_DOC
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_QUANT"  )] := (cAliasQry)->VR_QUANT
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_LOCAL"  )] := (cAliasQry)->VR_LOCAL
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_OPC"    )] := (cAliasQry)->VR_MOPC
			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_STR_OPC")] := (cAliasQry)->VR_OPC

			If Empty((cAliasQry)->VR_NRMRP)
				aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_TICKET")] := ""
				aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_PROC"  )] := "2"
			Else
				aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_TICKET")] := (cAliasQry)->VR_NRMRP
				aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_PROC"  )] := "1"
			EndIf

			aDadosInc[nPos][A136APICnt("ARRAY_DEMAND_POS_REV")] := cRevisao

			(cAliasQry)->(dbSkip())

			If cFilBkp != (cAliasQry)->(VR_FILIAL)
				// Verifica se precisa trocar o cFilAnt para sincronizar os opcionais corretamente.
				// (seta cFilAnt de acordo com o compartilhamento da tabela, para buscar na filial correta, a estrutura com os opcionais)
				// Se necessario trocar cFilant, sincroniza os produtos que já foram processados.
				lTrocouFil := setFilAnt((cAliasQry)->(VR_FILIAL), "SVR")

				If lTrocouFil
					cFilBkp := (cAliasQry)->(VR_FILIAL)
				EndIf
			EndIf

			If nPos > VOL_BUFFER .Or. (cAliasQry)->(Eof()) .Or. lTrocouFil
				//Chama a função do PCPA136API para integrar os registros
				PCPA136INT("SYNC", aDadosInc, oTTInteg, @aSuccess, @aError, /*cUUID*/, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
				lTrocouFil := .F.
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))

	//Elimina as temporárias
	oTTInteg:Delete()
	FreeObj(oTTInteg)
Return

/*/{Protheus.doc} SincPedCom
Sincroniza os Pedidos de Compras
@author  brunno.costa
@version P12
@since   05/08/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincPedCom(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cQryCondic := ""
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nTamQtd    := GetSx3Cache("C7_QUANT", "X3_TAMANHO")
	Local nTamDec    := GetSx3Cache("C7_QUANT", "X3_DECIMAL")
	Local nTotal     := 0
	Local nSuccess 	 := 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_PED_COMPRAS][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(PEDCAPICnt("ARRAY_PEDCOM_SIZE")))
		aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_FILIAL")] := xFilial("SC7", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do MrpPurchaseRequestAPI para integrar os registros
	PCPPEDCINT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_PED_COMPRAS][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_PED_COMPRAS][IND_PAR_QUERY][nIndex]

		BeginSql Alias cAliasQry
			COLUMN C7_DATPRF AS DATE
			COLUMN C7_QUANT  AS NUMERIC(nTamQtd, nTamDec)
			COLUMN C7_QUJE   AS NUMERIC(nTamQtd, nTamDec)
			SELECT C7_FILIAL,
				C7_NUM,
				C7_ITEM,
				C7_PRODUTO,
				C7_OP,
				C7_DATPRF,
				C7_QUANT,
				C7_QUJE,
				C7_LOCAL,
				C7_TPOP,
				C7_ITEMGRD,
				C7_TIPO,
				R_E_C_N_O_
			FROM %Exp:cQryCondic%
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(PEDCAPICnt("ARRAY_PEDCOM_SIZE")))
			nPos++

			//Adiciona as informações no array de inclusão/atualização
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_FILIAL" )] := (cAliasQry)->C7_FILIAL
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_NUM"    )] := (cAliasQry)->C7_NUM
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_ITEM"   )] := (cAliasQry)->C7_ITEM
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_PROD"   )] := (cAliasQry)->C7_PRODUTO
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_OP"     )] := (cAliasQry)->C7_OP
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_DATPRF" )] := (cAliasQry)->C7_DATPRF
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_QTD"    )] := (cAliasQry)->C7_QUANT
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_QUJE"   )] := (cAliasQry)->C7_QUJE
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_LOCAL"  )] := (cAliasQry)->C7_LOCAL
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_TIPO"   )] := (cAliasQry)->C7_TPOP
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_ITGRD"  )] := (cAliasQry)->C7_ITEMGRD
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_DOCUM"  )] := (cAliasQry)->C7_NUM+(cAliasQry)->C7_ITEM+(cAliasQry)->C7_ITEMGRD
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_TIPOPD" )] := cValToChar((cAliasQry)->C7_TIPO)
			aDadosInc[nPos][PEDCAPICnt("ARRAY_PEDCOM_POS_RECNO"  )] := cValToChar((cAliasQry)->R_E_C_N_O_)

			(cAliasQry)->(dbSkip())
			If nPos > VOL_BUFFER .Or. (cAliasQry)->(Eof())
				//Chama a função do MrpPurchaseRequestAPI para integrar os registros
				PCPPEDCINT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincStock
Sincroniza os Estoques
@author  brunno.costa
@version P12
@since   06/08/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincStock(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cQryCondic := ""
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nSuccess 	 := 0
	Local nTamFil    := FwSizeFilial()
	Local nTamPrd    := GetSx3Cache("B8_PRODUTO","X3_TAMANHO")
	Local nTamLoc    := GetSx3Cache("B8_LOCAL"  ,"X3_TAMANHO")
	Local nTamLote   := GetSx3Cache("B8_LOTECTL","X3_TAMANHO")
	Local nTamSubLt  := GetSx3Cache("B8_NUMLOTE","X3_TAMANHO")
	Local nTamQtd    := GetSx3Cache("B2_QATU"   ,"X3_TAMANHO")
	Local nTamDec    := GetSx3Cache("B2_QATU"   ,"X3_DECIMAL")
	Local nTotal     := 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_ESTOQUES][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(EstqAPICnt("ARRAY_ESTOQUE_SIZE")))
		aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_FILIAL")] := xFilial("SB2", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do MrpStockBalanceAPI para integrar os registros
	PcpEstqInt("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_ESTOQUES][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_ESTOQUES][IND_PAR_QUERY][nIndex]

		BeginSql Alias cAliasQry
			COLUMN availableQuantity    AS NUMERIC(nTamQtd, nTamDec)
			COLUMN consignedOut         AS NUMERIC(nTamQtd, nTamDec)
			COLUMN consignedIn          AS NUMERIC(nTamQtd, nTamDec)
			COLUMN unavailableQuantity  AS NUMERIC(nTamQtd, nTamDec)
			COLUMN expirationDate       AS DATE
			COLUMN blockedBalance 		AS NUMERIC(nTamQtd, nTamDec)
			SELECT branchId,
				product,
				warehouse,
				lot,
				sublot,
				expirationDate,
				availableQuantity,
				consignedOut,
				consignedIn,
				unavailableQuantity,
				blockedBalance
			FROM %Exp:cQryCondic%
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(EstqAPICnt("ARRAY_ESTOQUE_SIZE")))
			nPos++

			//Adiciona as informações no array de inclusão/atualização
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_FILIAL"   )] := PadR((cAliasQry)->branchId , nTamFil)
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_PROD"     )] := PadR((cAliasQry)->product  , nTamPrd)
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_LOCAL"    )] := PadR((cAliasQry)->warehouse, nTamLoc)
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_LOTE"     )] := PadR((cAliasQry)->lot      , nTamLote)
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_SUBLOTE"  )] := PadR((cAliasQry)->sublot   , nTamSubLt)
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_VALIDADE" )] := (cAliasQry)->expirationDate
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_QTD"      )] := (cAliasQry)->availableQuantity
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_NPT"  )] := (cAliasQry)->consignedOut
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_TNP"  )] := (cAliasQry)->consignedIn
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_IND"  )] := (cAliasQry)->unavailableQuantity
			aDadosInc[nPos][EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_BLQ"  )] := (cAliasQry)->blockedBalance

			(cAliasQry)->(dbSkip())
			If nPos > VOL_BUFFER .Or. (cAliasQry)->(Eof())
				//Chama a função do MrpStockBalanceAPI para integrar os registros
				PcpEstqInt("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincCQ
Sincroniza CQ
@author  brunno.costa
@version P12
@since   13/07/2020
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincCQ(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAlias     := PCPAliasQr()
	Local cQryCondic := ""
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nSuccess 	 := 0
	Local nTamData   := 8
	Local nTamFil    := FwSizeFilial()
	Local nTamPrd    := GetSx3Cache("D7_PRODUTO","X3_TAMANHO")
	Local nTamLoc    := GetSx3Cache("D7_LOCDEST","X3_TAMANHO")
	Local nTamQtd    := GetSx3Cache("D7_QTDE"   ,"X3_TAMANHO")
	Local nTamDec    := GetSx3Cache("D7_QTDE"   ,"X3_DECIMAL")
	Local nTotal     := 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_CQ][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(CQAPICnt("ARRAY_CQ_SIZE")))
		aDadosInc[nPos][CQAPICnt("ARRAY_CQ_POS_FILIAL")] := xFilial("SD7", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do MrpRejectedInventory para integrar os registros
	PcpCQInt("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_CQ][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_CQ][IND_PAR_QUERY][nIndex]

		BeginSql Alias cAlias
			COLUMN quantity         AS NUMERIC(nTamQtd, nTamDec)
			COLUMN returnedQuantity AS NUMERIC(nTamQtd, nTamDec)
			SELECT branchId,
				product,
				warehouse,
				invoiceDate,
				quantity,
				returnedQuantity,
				lot,
				subLot
			FROM %Exp:cQryCondic%
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAlias)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(CQAPICnt("ARRAY_CQ_SIZE")))
			nPos++

			aDadosInc[nPos][CQAPICnt("ARRAY_CQ_POS_FILIAL"   )] := PadR((cAlias)->branchId   , nTamFil)
			aDadosInc[nPos][CQAPICnt("ARRAY_CQ_POS_PROD"     )] := PadR((cAlias)->product    , nTamPrd)
			aDadosInc[nPos][CQAPICnt("ARRAY_CQ_POS_LOCAL"    )] := PadR((cAlias)->warehouse  , nTamLoc)
			aDadosInc[nPos][CQAPICnt("ARRAY_CQ_POS_DATA"     )] := PadR((cAlias)->invoiceDate, nTamData)
			aDadosInc[nPos][CQAPICnt("ARRAY_CQ_POS_QTDE"     )] := (cAlias)->quantity
			aDadosInc[nPos][CQAPICnt("ARRAY_CQ_POS_QTD_DEV"  )] := (cAlias)->returnedQuantity
			aDadosInc[nPos][CQAPICnt("ARRAY_CQ_POS_LOTE"     )] := (cAlias)->lot
			aDadosInc[nPos][CQAPICnt("ARRAY_CQ_POS_SBLOTE"   )] := (cAlias)->subLot

			(cAlias)->(dbSkip())

			If nPos > VOL_BUFFER .Or. (cAlias)->(Eof())
				//Chama a função do MrpRejectedInventory para integrar os registros
				PcpCQInt("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
			EndIf
		End
		(cAlias)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincOrdPrd
Sincroniza as Ordens de Produção
@author  brunno.costa
@version P12
@since   05/08/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincOrdPrd(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cFilAux    := ""
	Local cQryCondic := ""
	Local nAtual     := 0
	Local nError     := 0
	Local nPos       := 0
	Local nSuccess 	 := 0
	Local nIndFilEmp := 0
	Local nTotFilEmp := 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_ORDEM_PROD][IND_PAR_API])

	dbSelectArea("SC2")
	SC2->(dbSetOrder(1))

	nTotFilEmp   := Len(aParTela[IND_TELA_ORDEM_PROD][IND_PAR_QUERY])

	For nIndFilEmp := 1 To nTotFilEmp

		If existeSMQ()
			cFilAux := getFilParc(RTrim(aParTela[IND_TELA_ORDEM_PROD][IND_PAR_CORE_QUERY][nIndFilEmp]))

			If !Empty(cFilAux)
				cFilAnt := cFilAux
			EndIf
		EndIf

		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(A650APICnt("ARRAY_OP_SIZE")))
		aDadosInc[1][A650APICnt("ARRAY_OP_POS_FILIAL")] := aParTela[IND_TELA_ORDEM_PROD][IND_PAR_CORE_QUERY][nIndFilEmp]
		aDadosInc[1][A650APICnt("ARRAY_OP_POS_XOPER")]  := "SYNC"

		//Chama a função do MATA650API para integrar os registros
		MATA650INT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

		//Carregar as variaveis de registros com sucesso e erros
		nSuccess += Len(aSuccess)
		nError   += Len(aError)

		//Reseta as variaveis
		aSize(aDadosInc, 0)
		aSize(aSuccess , 0)
		aSize(aError   , 0)

		//Consulta os registros
		cQryCondic := QryCondSC2(.F., aParTela[IND_TELA_ORDEM_PROD][IND_PAR_CORE_QUERY][nIndFilEmp])
		SC2->(dbSetFilter({|| &cQryCondic}, cQryCondic))
		SC2->(dbGoTop())

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While SC2->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			A650AddInt(aDadosInc, , "SYNC")
			nPos++

			SC2->(dbSkip())

			If nPos > VOL_BUFFER .Or. SC2->(Eof())
				//Chama a função do MATA650API para integrar os registros
				MATA650INT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)
				nPos := 0
			EndIf

		End

		SC2->(dbClearFilter())
	Next nIndBuffer

	SC2->(dbGoTop())

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincSolCom
Sincroniza as Solicitações de Compras
@author  Marcelo Neumann
@version P12
@since   05/08/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincSolCom(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cQryCondic := ""
	Local lT4TAprov  := .F.
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nTamQtd    := GetSx3Cache("C1_QUANT", "X3_TAMANHO")
	Local nTamDec    := GetSx3Cache("C1_QUANT", "X3_DECIMAL")
	Local nTotal     := 0
	Local nSuccess 	 := 0

	//DMANSMARTSQUAD1-30175 - Inclusão C1_APROV na T4T
	dbSelectArea("T4T")
	lT4TAprov := FieldPos("T4T_APROV") > 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_SOL_COMPRAS][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(SOLCAPICnt("ARRAY_SOLCOM_SIZE")))
		aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_FILIAL")] := xFilial("SC1", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do MrpPurchaseOrderAPI para integrar os registros
	PCPSOLCINT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_SOL_COMPRAS][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_SOL_COMPRAS][IND_PAR_QUERY][nIndex]

		BeginSql Alias cAliasQry
			COLUMN C1_DATPRF AS DATE
			COLUMN C1_QUANT  AS NUMERIC(nTamQtd, nTamDec)
			COLUMN C1_QUJE   AS NUMERIC(nTamQtd, nTamDec)
			SELECT C1_FILIAL,
				C1_NUM,
				C1_ITEM,
				C1_PRODUTO,
				C1_OP,
				C1_DATPRF,
				C1_QUANT,
				C1_QUJE,
				C1_LOCAL,
				C1_TPOP,
				C1_ITEMGRD,
				C1_APROV,
				R_E_C_N_O_
			FROM %Exp:cQryCondic%
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(SOLCAPICnt("ARRAY_SOLCOM_SIZE")))
			nPos++

			//Adiciona as informações no array de inclusão/atualização
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_FILIAL" )] := (cAliasQry)->C1_FILIAL
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_NUM"    )] := (cAliasQry)->C1_NUM
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_ITEM"   )] := (cAliasQry)->C1_ITEM
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_PROD"   )] := (cAliasQry)->C1_PRODUTO
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_OP"     )] := (cAliasQry)->C1_OP
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_DATPRF" )] := (cAliasQry)->C1_DATPRF
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_QTD"    )] := (cAliasQry)->C1_QUANT
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_QUJE"   )] := (cAliasQry)->C1_QUJE
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_LOCAL"  )] := (cAliasQry)->C1_LOCAL
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_TIPO"   )] := IIf( Empty((cAliasQry)->C1_TPOP), "1", (cAliasQry)->C1_TPOP )
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_ITGRD"  )] := (cAliasQry)->C1_ITEMGRD
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_DOCUM"  )] := (cAliasQry)->C1_NUM+(cAliasQry)->C1_ITEM+(cAliasQry)->C1_ITEMGRD
			aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_RECNO"      )] := cValToChar((cAliasQry)->R_E_C_N_O_)

			//DMANSMARTSQUAD1-30175 - Inclusão C1_APROV na T4T
			If lT4TAprov
				aDadosInc[nPos][SOLCAPICnt("ARRAY_SOLCOM_POS_APROV"  )] := (cAliasQry)->C1_APROV
			EndIf

			(cAliasQry)->(dbSkip())
			If nPos > VOL_BUFFER .Or. (cAliasQry)->(Eof())
				//Chama a função do MrpPurchaseOrderAPI para integrar os registros
				PCPSOLCINT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincPrdVer
Sincroniza as versões de produção
@author  Ricardo Prandi
@version P12
@since   01/08/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincPrdVer(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cQryCondic := ""
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nSuccess 	 := 0
	Local nTamQtd    := GetSx3Cache("VC_QTDDE", "X3_TAMANHO")
	Local nTamDec    := GetSx3Cache("VC_QTDDE", "X3_DECIMAL")
	Local nTotal     := 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_VERSAO_PROD][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(A119APICnt("ARRAY_PRODVERS_SIZE")))
		aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_FILIAL")] := xFilial("SVC", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do PCPA119API para integrar os registros
	PCPA119INT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_VERSAO_PROD][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_VERSAO_PROD][IND_PAR_QUERY][nIndex]

		BeginSql Alias cAliasQry
			COLUMN VC_DTINI  AS DATE
			COLUMN VC_DTFIM  AS DATE
			COLUMN VC_QTDDE  AS NUMERIC(nTamQtd, nTamDec)
			COLUMN VC_QTDATE AS NUMERIC(nTamQtd, nTamDec)
			SELECT VC_FILIAL,
				VC_VERSAO,
				VC_PRODUTO,
				VC_DTINI,
				VC_DTFIM,
				VC_QTDDE,
				VC_QTDATE,
				VC_REV,
				VC_ROTEIRO,
				VC_LOCCONS
			FROM %Exp:cQryCondic%
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(A119APICnt("ARRAY_PRODVERS_SIZE")))
			nPos++

			//Adiciona as informações no array de inclusão/atualização
			aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_FILIAL" )] := (cAliasQry)->VC_FILIAL
			aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_CODE"   )] := (cAliasQry)->VC_VERSAO
			aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_PROD"   )] := (cAliasQry)->VC_PRODUTO
			aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_DTINI"  )] := (cAliasQry)->VC_DTINI
			aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_DTFIM"  )] := (cAliasQry)->VC_DTFIM
			aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_QTDINI" )] := (cAliasQry)->VC_QTDDE
			aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_QTDFIM" )] := (cAliasQry)->VC_QTDATE
			aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_REVISAO")] := (cAliasQry)->VC_REV
			aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_ROTEIRO")] := (cAliasQry)->VC_ROTEIRO
			aDadosInc[nPos][A119APICnt("ARRAY_PRODVERS_POS_LOCAL"  )] := (cAliasQry)->VC_LOCCONS

			(cAliasQry)->(dbSkip())

			If nPos > VOL_BUFFER .Or. (cAliasQry)->(Eof())
				//Chama a função do PCPA119API para integrar os registros
				PCPA119INT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincEstrut
Sincroniza as estruturas
@author  lucas.franca
@version P12
@since   05/08/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincEstrut(cJobName)
	Local aDadosCab  := {}
	Local aDadosCmp  := {}
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cFilAtu    := ""
	Local cPaiAtu    := Nil
	Local cPaiProx   := ""
	Local cPrdTable  := SuperGetMv("MV_ARQPROD",.F.,"SB1")
	Local cQuery     := ""
	Local nAtual     := 0
	Local nCont      := 0
	Local nIndFilEmp := 0
	Local nTotFilEmp := 0
	Local nTamQtd    := GetSx3Cache("G1_QUANT", "X3_TAMANHO")
	Local nDecQtd    := GetSx3Cache("G1_QUANT", "X3_DECIMAL")
	Local nTamPerda  := GetSx3Cache("G1_PERDA", "X3_TAMANHO")
	Local nDecPerda  := GetSx3Cache("G1_PERDA", "X3_DECIMAL")
	Local nError     := 0
	Local nSuccess 	 := 0

	LockByName("P140_ESTRUT",.T.,.F.)
	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_ESTRUTURA][IND_PAR_API])

	nTotFilEmp   := Len(aParTela[IND_TELA_ESTRUTURA][IND_PAR_QUERY])

	For nIndFilEmp := 1 To nTotFilEmp

		cFilAtu := aParTela[IND_TELA_ESTRUTURA][IND_PAR_QUERY][nIndFilEmp]
		cFilAnt := cFilAtu

		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosCab, Array(A200APICnt("ARRAY_ESTRU_CAB_SIZE")))
		aDadosCab[A200APICnt("ARRAY_ESTRU_CAB_POS_FILIAL")] := xFilial("SG1", cFilAtu)
		aAdd(aDadosInc, aClone(aDadosCab))
		aSize(aDadosCab, 0)

		//Chama a função do PCPA200API para integrar os registros
		PCPA200INT("SYNC", aDadosInc, Nil, @aSuccess, @aError, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

		//Carregar as variaveis de registros com sucesso e erros
		nSuccess += Len(aSuccess)
		nError   += Len(aError)

		//Reseta as variaveis
		aSize(aDadosInc, 0)
		aSize(aSuccess , 0)
		aSize(aError   , 0)

		cQuery := "SELECT SG1.G1_FILIAL, "
		cQuery +=       " SG1.G1_COD, "
		cQuery +=       " SG1.G1_COMP, "
		cQuery +=       " SG1.G1_TRT, "
		cQuery +=       " SG1.G1_QUANT, "
		cQuery +=       " SG1.G1_INI, "
		cQuery +=       " SG1.G1_FIM, "
		cQuery +=       " SG1.G1_REVINI, "
		cQuery +=       " SG1.G1_REVFIM, "
		cQuery +=       " SG1.G1_PERDA, "
		cQuery +=       " SG1.G1_FIXVAR, "
		cQuery +=       " SG1.G1_POTENCI, "
		cQuery +=       " SG1.G1_GROPC, "
		cQuery +=       " SG1.G1_OPC, "
		cQuery +=       " SG1.G1_LOCCONS, "
		cQuery +=       " SG1.R_E_C_N_O_ AS RECSG1, "
		If cPrdTable == "SBZ"
			cQuery +=   " COALESCE(SBZPAI.BZ_QB, SB1PAI.B1_QB) AS QTDBASE,"
		Else
			cQuery +=   " SB1PAI.B1_QB AS QTDBASE,"
		EndIf
		cQuery +=       " (SELECT COUNT(SGI.GI_FILIAL) "
		cQuery +=          " FROM " + RetSqlName("SGI") + " SGI "
		cQuery +=         " WHERE SGI.GI_FILIAL  = '" + xFilial("SGI",cFilAtu) + "' "
		cQuery +=           " AND SGI.GI_PRODORI = SG1.G1_COMP "
		cQuery +=           " AND SGI.GI_MRP = 'S' "
		cQuery +=           " AND SGI.D_E_L_E_T_ = ' ' ) AS ALTERNATIVOS, "

		If cPrdTable == "SBZ"
			cQuery +=   " CASE "
			cQuery +=      " WHEN SG1.G1_FANTASM = ' ' THEN "
			cQuery +=         " CASE "
			cQuery +=            " WHEN SBZ.BZ_FANTASM = 'S' THEN 'T' "
			cQuery +=            " WHEN SBZ.BZ_FANTASM = 'N' THEN 'F' "
			cQuery +=            " ELSE "
			cQuery +=               " CASE "
			cQuery +=                  " WHEN SB1.B1_FANTASM = 'S' THEN 'T' "
			cQuery +=                  " WHEN SB1.B1_FANTASM = 'N' THEN 'F' "
			cQuery +=                  " ELSE 'F' "
			cQuery +=               " END "
			cQuery +=         " END "
			cQuery +=      " WHEN SG1.G1_FANTASM = '1' THEN 'T' "
			cQuery +=      " ELSE 'F' "
			cQuery +=   " END AS FANTASMA "

			cQuery +=  " FROM "      + RetSqlName("SG1") + " SG1 "
			cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
			cQuery +=         " ON SB1.B1_FILIAL = '" + xFilial("SB1",cFilAtu) + "' "
			cQuery +=        " AND SB1.B1_COD    = SG1.G1_COMP "
			cQuery +=        " AND SB1.D_E_L_E_T_ = ' ' "

			cQuery += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ "
			cQuery +=              " ON SBZ.BZ_FILIAL  = '" + xFilial("SBZ",cFilAtu) + "' "
			cQuery +=             " AND SB1.B1_COD     = SBZ.BZ_COD "
			cQuery +=             " AND SBZ.D_E_L_E_T_ = ' ' "

		Else
			cQuery +=   " CASE "
			cQuery +=      " WHEN SG1.G1_FANTASM = ' ' THEN "
			cQuery +=         " CASE "
			cQuery +=            " WHEN (SELECT SB1.B1_FANTASM "
			cQuery +=                    " FROM " + RetSqlName("SB1") + " SB1 "
			cQuery +=                   " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1",cFilAtu) + "' "
			cQuery +=                     " AND SB1.D_E_L_E_T_ = ' ' "
			cQuery +=                     " AND SB1.B1_COD     = SG1.G1_COMP ) = 'S' THEN 'T' "
			cQuery +=            " ELSE 'F' "
			cQuery +=         " END "
			cQuery +=      " WHEN SG1.G1_FANTASM = '1' THEN 'T' "
			cQuery +=      " ELSE 'F' "
			cQuery +=   " END AS FANTASMA "

			cQuery +=   " FROM " + RetSqlName("SG1") + " SG1 "
		EndIf

		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1PAI "
		cQuery +=         " ON SB1PAI.B1_FILIAL  = '" + xFilial("SB1", cFilAtu) + "'"
		cQuery +=        " AND SB1PAI.B1_COD     = SG1.G1_COD"
		cQuery +=        " AND SB1PAI.B1_MSBLQL  <> '1'"
		cQuery +=        " AND SB1PAI.D_E_L_E_T_ = ' '"

		If cPrdTable == "SBZ"
			cQuery += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZPAI "
			cQuery +=              " ON SBZPAI.BZ_FILIAL  = '" + xFilial("SBZ", cFilAtu) + "'"
			cQuery +=             " AND SBZPAI.BZ_COD     = SB1PAI.B1_COD "
			cQuery +=             " AND SBZPAI.D_E_L_E_T_ = ' ' "
		EndIf

		cQuery += " WHERE SG1.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND SG1.G1_FILIAL  = '" + xFilial("SG1", cFilAtu) + "' "

		cQuery +=  " ORDER BY G1_FILIAL, "
		cQuery +=           " G1_COD, "
		cQuery +=           " G1_COMP, "
		cQuery +=           " G1_TRT "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
		TcSetField(cAliasQry, "G1_INI"  , "D", 8        , 0)
		TcSetField(cAliasQry, "G1_FIM"  , "D", 8        , 0)
		TcSetField(cAliasQry, "G1_QUANT", "N", nTamQtd  , nDecQtd)
		TcSetField(cAliasQry, "G1_PERDA", "N", nTamPerda, nDecPerda)

		nCont  := 0

		//Monta os dados de cabeçalho do primeiro pai (se existir)
		If (cAliasQry)->(!Eof())
			cPaiAtu := (cAliasQry)->(G1_FILIAL) + (cAliasQry)->(G1_COD)
			nAtual++

			aDadosCab := Array(A200APICnt("ARRAY_ESTRU_CAB_SIZE"))
			//Dados do cabeçalho
			aDadosCab[A200APICnt("ARRAY_ESTRU_CAB_POS_FILIAL")] := (cAliasQry)->(G1_FILIAL)
			aDadosCab[A200APICnt("ARRAY_ESTRU_CAB_POS_PAI"   )] := (cAliasQry)->(G1_COD)
			aDadosCab[A200APICnt("ARRAY_ESTRU_CAB_POS_QBASE" )] := (cAliasQry)->(QTDBASE)
			aDadosCab[A200APICnt("ARRAY_ESTRU_CAB_POS_COMPON")] := {}
		EndIf

		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			If (cPaiAtu != (cAliasQry)->(G1_FILIAL) + (cAliasQry)->(G1_COD))
				nAtual++
				cPaiAtu := (cAliasQry)->(G1_FILIAL) + (cAliasQry)->(G1_COD)
				PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
				GlbUnLock()

				aAdd(aDadosInc, aClone(aDadosCab))
				nCont++
				aDadosCab[A200APICnt("ARRAY_ESTRU_CAB_POS_FILIAL")] := (cAliasQry)->(G1_FILIAL)
				aDadosCab[A200APICnt("ARRAY_ESTRU_CAB_POS_PAI"   )] := (cAliasQry)->(G1_COD)
				aDadosCab[A200APICnt("ARRAY_ESTRU_CAB_POS_QBASE" )] := (cAliasQry)->(QTDBASE)
				aSize(aDadosCab[A200APICnt("ARRAY_ESTRU_CAB_POS_COMPON")], 0)
			EndIf

			aDadosCmp := Array(A200APICnt("ARRAY_ESTRU_CMP_SIZE"))
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_COMP"   )] := (cAliasQry)->G1_COMP
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_SEQ"    )] := (cAliasQry)->G1_TRT
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_QTDNEC" )] := (cAliasQry)->G1_QUANT
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_VLDINI" )] := (cAliasQry)->G1_INI
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_VLDFIM" )] := (cAliasQry)->G1_FIM
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_REVINI" )] := (cAliasQry)->G1_REVINI
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_REVFIM" )] := (cAliasQry)->G1_REVFIM
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_PERDA"  )] := (cAliasQry)->G1_PERDA
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_QTDFIXA")] := (cAliasQry)->G1_FIXVAR
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_POTENC" )] := (cAliasQry)->G1_POTENCI
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_GRPOPC" )] := (cAliasQry)->G1_GROPC
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_ITEMOPC")] := (cAliasQry)->G1_OPC
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_LOCAL"  )] := (cAliasQry)->G1_LOCCONS
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_FANTASM")] := Iif(AllTrim((cAliasQry)->FANTASMA) == "T", .T., .F.)
			aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_RECNO"  )] := (cAliasQry)->RECSG1
			If (cAliasQry)->ALTERNATIVOS > 0
				aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_ALTERNATIVO")] := A200APIAlt((cAliasQry)->(G1_COD), (cAliasQry)->G1_COMP)
			Else
				aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_ALTERNATIVO")] := {}
			EndIf
			aAdd(aDadosCab[A200APICnt("ARRAY_ESTRU_CAB_POS_COMPON")], aClone(aDadosCmp))

			aSize(aDadosCmp[A200APICnt("ARRAY_ESTRU_CMP_POS_ALTERNATIVO")], 0)
			aSize(aDadosCmp, 0)

			(cAliasQry)->(dbSkip())

			cPaiProx := IIf((cAliasQry)->(Eof()), '', (cAliasQry)->(G1_FILIAL) + (cAliasQry)->(G1_COD))

			If (cPaiProx != cPaiAtu .And. nCont > VOL_BUFFER) .Or. (cAliasQry)->(Eof())
				If (cAliasQry)->(Eof())
					//Adiciona o último pai no aDadosInc
					aAdd(aDadosInc, aClone(aDadosCab))
					aSize(aDadosCab, 0)
				EndIf

				//Chama a função do PCPA200API para integrar os registros
				PCPA200INT("SYNC", aDadosInc, Nil, @aSuccess, @aError, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)
				nCont := 0
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndBuffer

	UnLockByName("P140_ESTRUT", .T., .F.)

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincProd
Sincroniza os Produtos
@author  marcelo.neumann
@version P12
@since   23/10/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincProd(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cBanco     := AllTrim(Upper(TcGetDb()))
	Local cQryCondic := ""
	Local cProdu     := ""
	Local cFilBkp    := cFilAnt
	Local lTrocouFil := .F.
	Local nAtual     := 0
	Local nError     := 0
	Local nPos       := 1
	Local nSuccess 	 := 0
	Local nTamQE     := GetSx3Cache("B1_QE"    , "X3_TAMANHO")
	Local nDecQE     := GetSx3Cache("B1_QE"    , "X3_DECIMAL")
	Local nTamEMIN   := GetSx3Cache("B1_EMIN"  , "X3_TAMANHO")
	Local nDecEMIN   := GetSx3Cache("B1_EMIN"  , "X3_DECIMAL")
	Local nTamESTSEG := GetSx3Cache("B1_ESTSEG", "X3_TAMANHO")
	Local nDecESTSEG := GetSx3Cache("B1_ESTSEG", "X3_DECIMAL")
	Local nTamLE     := GetSx3Cache("B1_LE"    , "X3_TAMANHO")
	Local nDecLE     := GetSx3Cache("B1_LE"    , "X3_DECIMAL")
	Local nTamLM     := GetSx3Cache("B1_LM"    , "X3_TAMANHO")
	Local nDecLM     := GetSx3Cache("B1_LM"    , "X3_DECIMAL")
	Local nTamEMAX   := GetSx3Cache("B1_EMAX"  , "X3_TAMANHO")
	Local nDecEMAX   := GetSx3Cache("B1_EMAX"  , "X3_DECIMAL")
	Local nTamQB     := GetSx3Cache("B1_QB"    , "X3_TAMANHO")
	Local nDecQB     := GetSx3Cache("B1_QB"    , "X3_DECIMAL")
	Local nPosLT     := 0
	Local nPosEmpB1  := 0
	Local nTotal     := 0
	Local oDescTp    := Nil

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_PRODUTOS][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(A010APICnt("ARRAY_PROD_SIZE")))
		aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_FILIAL")] :=  xFilial("SB5", aEmprCent[nPos][2])
	Next nPos

    For nPosEmpB1 := 1 To nTotal
		aAdd(aDadosInc, Array(A010APICnt("ARRAY_PROD_SIZE")))
        aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_FILIAL")] :=  xFilial("SB1", aEmprCent[nPosEmpB1][2])
		nPos++
	Next nPosEmpB1

	//Chama a função do MATA010API para integrar os registros
	MATA010INT("SYNC", aDadosInc, @aSuccess, @aError, .T. /*OnlyDel*/, /*cUUID*/ , .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Monta Query que busca os registros
	cQryCondic := getQrySb1(aEmprCent, .F.)

	cQryCondic := "%" + cQryCondic + "%"
	If "MSSQL" $ cBanco
		cQryCondic := StrTran(cQryCondic, "||", "+")
	EndIf

	BeginSql Alias cAliasQry
		COLUMN B1_QE     AS NUMERIC(nTamQE    , nDecQE    )
		COLUMN B1_EMIN   AS NUMERIC(nTamEMIN  , nDecEMIN  )
		COLUMN B1_ESTSEG AS NUMERIC(nTamESTSEG, nDecESTSEG)
		COLUMN B1_LE     AS NUMERIC(nTamLE    , nDecLE    )
		COLUMN B1_LM     AS NUMERIC(nTamLM    , nDecLM    )
		COLUMN B1_EMAX   AS NUMERIC(nTamEMAX  , nDecEMAX  )
		COLUMN B1_QB     AS NUMERIC(nTamQB    , nDecQB  )
		SELECT B1_FILIAL ,
			B1_COD    ,
			B1_LOCPAD ,
			B1_TIPO   ,
			B1_GRUPO  ,
			B1_QE     ,
			B1_EMIN   ,
			B1_ESTSEG ,
			B1_PE     ,
			B1_TIPE   ,
			B1_LE     ,
			B1_LM     ,
			B1_TOLER  ,
			B1_TIPODEC,
			B1_RASTRO ,
			B1_MRP    ,
			B1_REVATU ,
			B1_EMAX   ,
			B1_PRODSBP,
			B1_LOTESBP,
			B1_ESTRORI,
			B1_APROPRI,
			B1_CPOTENC,
			B1_MSBLQL ,
			B1_CONTRAT,
			B1_OPERPAD,
			B1_CCCUSTO,
			B1_DESC   ,
			B1_GRUPCOM,
			B1_UM     ,
			B1_OPC    ,
			B1_QB     ,
			VK_HORFIX ,
			VK_TPHOFIX,
			B5_FILIAL ,
			B5_LEADTR ,
			B5_AGLUMRP,
			B5_COD    ,
			HZ8_FILIAL,
			HZ8_LEADTR,
			HZ8_TRANSF,
			HZ8_FILCOM,
			HZ8_LMTRAN,
			AJ_DESC   ,
			TEMOPC    ,
			R_E_C_N_O_
		FROM %Exp:cQryCondic%
		ORDER BY B1_FILIAL, B1_COD
	EndSql

	If !(cAliasQry)->(Eof())
		oDescTp := JsonObject():New()

		nAtual := 0
		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())

			If cProdu <> (cAliasQry)->(B1_FILIAL + B1_COD)

				//Atualiza as barras de progresso
				nAtual++
				PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
				GlbUnLock()

				cProdu := (cAliasQry)->(B1_FILIAL + B1_COD)
				//Adiciona nova linha no array de inclusão/atualização
				aAdd(aDadosInc, Array(A010APICnt("ARRAY_PROD_SIZE")))
				nPos++
				nPosLT := 0

				//Adiciona as informações no array de inclusão/atualização
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_FILIAL"   )] := (cAliasQry)->B1_FILIAL
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_PROD"     )] := (cAliasQry)->B1_COD
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LOCPAD"   )] := (cAliasQry)->B1_LOCPAD
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_TIPO"     )] := (cAliasQry)->B1_TIPO
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_GRUPO"    )] := (cAliasQry)->B1_GRUPO
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_QE"       )] := (cAliasQry)->B1_QE
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_EMIN"     )] := (cAliasQry)->B1_EMIN
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_ESTSEG"   )] := (cAliasQry)->B1_ESTSEG
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_PE"       )] := (cAliasQry)->B1_PE
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_TIPE"     )] := M010CnvFld("B1_TIPE"   , (cAliasQry)->B1_TIPE)
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LE"       )] := (cAliasQry)->B1_LE
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LM"       )] := (cAliasQry)->B1_LM
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_TOLER"    )] := (cAliasQry)->B1_TOLER
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_TIPDEC"   )] := M010CnvFld("B1_TIPODEC", (cAliasQry)->B1_TIPODEC)
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_RASTRO"   )] := M010CnvFld("B1_RASTRO" , (cAliasQry)->B1_RASTRO)
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_MRP"      )] := M010CnvFld("B1_MRP"    , (cAliasQry)->B1_MRP)
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_REVATU"   )] := (cAliasQry)->B1_REVATU
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_EMAX"     )] := (cAliasQry)->B1_EMAX
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_PROSBP"   )] := M010CnvFld("B1_PRODSBP", (cAliasQry)->B1_PRODSBP)
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LOTSBP"   )] := (cAliasQry)->B1_LOTESBP
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_ESTORI"   )] := (cAliasQry)->B1_ESTRORI
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_APROPR"   )] := M010CnvFld("B1_APROPRI", (cAliasQry)->B1_APROPRI)
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_CPOTEN"   )] := (cAliasQry)->B1_CPOTENC
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_HORFIX"   )] := (cAliasQry)->VK_HORFIX
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_TPHFIX"   )] := (cAliasQry)->VK_TPHOFIX
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_NUMDEC"   )] := "0" //Protheus não utiliza esse campo, passar 0 fixo
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_IDREG"    )] := (cAliasQry)->B1_FILIAL+(cAliasQry)->B1_COD
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_BLOQUEADO")] := (cAliasQry)->B1_MSBLQL
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_CONTRATO" )] := M010CnvFld("B1_CONTRAT", (cAliasQry)->B1_CONTRAT)
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_ROTEIRO"  )] := (cAliasQry)->B1_OPERPAD
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_CCUSTO"   )] := (cAliasQry)->B1_CCCUSTO
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_DESC"     )] := (cAliasQry)->B1_DESC
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_UM"       )] := (cAliasQry)->B1_UM
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_QTDB"     )] := (cAliasQry)->B1_QB

				If Trim((cAliasQry)->TEMOPC) == "1"
					SB1->(DbGoTo((cAliasQry)->R_E_C_N_O_))
					aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_OPC")] := SB1->B1_MOPC
				EndIf
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_STR_OPC"  )] := (cAliasQry)->B1_OPC

				If oDescTp[(cAliasQry)->B1_FILIAL+(cAliasQry)->B1_TIPO] == Nil
					oDescTp[(cAliasQry)->B1_FILIAL+(cAliasQry)->B1_TIPO] := M010CnvFld("B1_DESCTP", (cAliasQry)->B1_TIPO)
				EndIf

				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_DESCTP"   )] := oDescTp[(cAliasQry)->B1_FILIAL+(cAliasQry)->B1_TIPO]
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_GRPCOM"   )] := (cAliasQry)->B1_GRUPCOM
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_GCDESC"   )] := (cAliasQry)->AJ_DESC
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )] := {}
			EndIf

			If !Empty((cAliasQry)->B5_COD)

				nPosLT++
				aAdd(aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )], Array(A010APICnt("ARRAY_TRANSF_POS_SIZE")))
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPosLT][A010APICnt("ARRAY_TRANSF_POS_FILIAL"  )] := (cAliasQry)->B5_FILIAL
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPosLT][A010APICnt("ARRAY_TRANSF_POS_LEADTIME")] := (cAliasQry)->B5_LEADTR
				aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LDTRANSF" )][nPosLT][A010APICnt("ARRAY_TRANSF_POS_AGLUTMRP")] := (cAliasQry)->B5_AGLUMRP

				If !Empty((cAliasQry)->HZ8_FILIAL)
					If !Empty((cAliasQry)->HZ8_LEADTR)
						aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LDTRANSF")][nPosLT][A010APICnt("ARRAY_TRANSF_POS_LEADTIME")] := (cAliasQry)->HZ8_LEADTR
					EndIf

					aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LDTRANSF")][nPosLT][A010APICnt("ARRAY_TRANSF_POS_TRANSF")] := (cAliasQry)->HZ8_TRANSF
					aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LDTRANSF")][nPosLT][A010APICnt("ARRAY_TRANSF_POS_FILCOM")] := (cAliasQry)->HZ8_FILCOM
					aDadosInc[nPos][A010APICnt("ARRAY_PROD_POS_LDTRANSF")][nPosLT][A010APICnt("ARRAY_TRANSF_POS_LMTRAN")] := (cAliasQry)->HZ8_LMTRAN
				EndIf
			EndIf

			(cAliasQry)->(dbSkip())

			If cFilBkp != (cAliasQry)->(B1_FILIAL) .And. (cAliasQry)->(B1_FILIAL) != ' '
				// Verifica se precisa trocar o cFilAnt para sincronizar os opcionais corretamente.
				// (seta cFilAnt de acordo com o compartilhamento da tabela, para buscar na filial correta, a estrutura com os opcionais)
				// Se necessario trocar cFilant, sincroniza os produtos que já foram processados.
				lTrocouFil := setFilAnt((cAliasQry)->(B1_FILIAL), "SB1")

				If lTrocouFil
					cFilBkp := (cAliasQry)->(B1_FILIAL)
				EndIf
			EndIf

			If (nPos > VOL_BUFFER .And. cProdu <> (cAliasQry)->(B1_FILIAL + B1_COD)) .Or. (cAliasQry)->(Eof()) .Or. lTrocouFil
				//Chama a função do MATA010API para integrar os registros
				MATA010INT("SYNC", aDadosInc, @aSuccess, @aError, .F. /*OnlyDel*/, /*cUUID*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
				lTrocouFil := .F.
			EndIf
		EndDo

		FreeObj(oDescTp)
		oDescTp := Nil
	EndIf

	(cAliasQry)->(dbCloseArea())

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincOpComp
Sincroniza as Operações por Componente
@author  brunno.costa
@version P12
@since   13/04/2020
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincOpComp(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cQryCondic := ""
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nSuccess 	 := 0
	Local nTotal     := 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_OPER_COMPON][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(A637APICnt("ARRAY_SIZE")))
		aDadosInc[nPos][A637APICnt("ARRAY_POS_FILIAL")] := xFilial("SGF", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do MATA637API para integrar os registros
	MATA637INT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_OPER_COMPON][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_OPER_COMPON][IND_PAR_QUERY][nIndex]

		BeginSql Alias cAliasQry
			SELECT DISTINCT GF_FILIAL,
							GF_PRODUTO,
							GF_ROTEIRO,
							GF_OPERAC,
							GF_COMP,
							GF_TRT
			FROM %Exp:cQryCondic%
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(A637APICnt("ARRAY_SIZE")))
			nPos++

			//Adiciona as informações no array de inclusão/atualização
			aDadosInc[nPos][A637APICnt("ARRAY_POS_FILIAL"     )] := (cAliasQry)->GF_FILIAL
			aDadosInc[nPos][A637APICnt("ARRAY_POS_PRODUTO"    )] := (cAliasQry)->GF_PRODUTO
			aDadosInc[nPos][A637APICnt("ARRAY_POS_ROTEIRO"    )] := (cAliasQry)->GF_ROTEIRO
			aDadosInc[nPos][A637APICnt("ARRAY_POS_OPERACAO"   )] := (cAliasQry)->GF_OPERAC
			aDadosInc[nPos][A637APICnt("ARRAY_POS_COMPONENTE" )] := (cAliasQry)->GF_COMP
			aDadosInc[nPos][A637APICnt("ARRAY_POS_TRT"        )] := (cAliasQry)->GF_TRT
			aDadosInc[nPos][A637APICnt("ARRAY_POS_IDREG"      )] := (cAliasQry)->(GF_FILIAL + GF_PRODUTO + GF_ROTEIRO + GF_OPERAC + GF_COMP + GF_TRT)

			(cAliasQry)->(dbSkip())

			If nPos > VOL_BUFFER .Or. (cAliasQry)->(Eof())
				//Chama a função do MATA637API para integrar os registros
				MATA637INT("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} SincIndPrd
Sincroniza os Indicadores de Produtos
@author  renan.roeder
@version P12
@since   19/11/2019
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincIndPrd(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cFilBkp    := cFilAnt
	Local cQryCondic := ""
	Local lTrocouFil := .F.
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nSuccess 	 := 0
	Local nTamQE     := GetSx3Cache("BZ_QE"    , "X3_TAMANHO")
	Local nDecQE     := GetSx3Cache("BZ_QE"    , "X3_DECIMAL")
	Local nTamEMIN   := GetSx3Cache("BZ_EMIN"  , "X3_TAMANHO")
	Local nDecEMIN   := GetSx3Cache("BZ_EMIN"  , "X3_DECIMAL")
	Local nTamESTSEG := GetSx3Cache("BZ_ESTSEG", "X3_TAMANHO")
	Local nDecESTSEG := GetSx3Cache("BZ_ESTSEG", "X3_DECIMAL")
	Local nTamLE     := GetSx3Cache("BZ_LE"    , "X3_TAMANHO")
	Local nDecLE     := GetSx3Cache("BZ_LE"    , "X3_DECIMAL")
	Local nTamLM     := GetSx3Cache("BZ_LM"    , "X3_TAMANHO")
	Local nDecLM     := GetSx3Cache("BZ_LM"    , "X3_DECIMAL")
	Local nTamEMAX   := GetSx3Cache("BZ_EMAX"  , "X3_TAMANHO")
	Local nDecEMAX   := GetSx3Cache("BZ_EMAX"  , "X3_DECIMAL")
	Local nTamQB     := GetSx3Cache("BZ_QB"    , "X3_TAMANHO")
	Local nDecQB     := GetSx3Cache("BZ_QB"    , "X3_DECIMAL")
	Local nTotal     := 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_INDICA_PROD][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(A019APICnt("ARRAY_IND_PROD_POS_SIZE")))
		aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_FILIAL")] := xFilial("SBZ", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do MATA019API para integrar os registros
	MATA019INT("SYNC", aDadosInc, @aSuccess, @aError, .T. /*OnlyDel*/, /*cUUID*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_INDICA_PROD][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_INDICA_PROD][IND_PAR_QUERY][nIndex]

		BeginSql Alias cAliasQry
			COLUMN BZ_QE     AS NUMERIC(nTamQE    , nDecQE    )
			COLUMN BZ_EMIN   AS NUMERIC(nTamEMIN  , nDecEMIN  )
			COLUMN BZ_ESTSEG AS NUMERIC(nTamESTSEG, nDecESTSEG)
			COLUMN BZ_LE     AS NUMERIC(nTamLE    , nDecLE    )
			COLUMN BZ_LM     AS NUMERIC(nTamLM    , nDecLM    )
			COLUMN BZ_EMAX   AS NUMERIC(nTamEMAX  , nDecEMAX  )
			COLUMN BZ_QB     AS NUMERIC(nTamQB    , nDecQB    )
			SELECT BZ_FILIAL ,
				BZ_COD    ,
				BZ_LOCPAD ,
				BZ_QE     ,
				BZ_EMIN   ,
				BZ_ESTSEG ,
				BZ_PE     ,
				BZ_TIPE   ,
				BZ_LE     ,
				BZ_LM     ,
				BZ_TOLER  ,
				BZ_MRP    ,
				BZ_REVATU ,
				BZ_EMAX   ,
				BZ_HORFIX ,
				BZ_TPHOFIX,
				BZ_QB     ,
				BZ_OPC    ,
				BZ_MOPC
			FROM %Exp:cQryCondic%
			ORDER BY BZ_FILIAL
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(A019APICnt("ARRAY_IND_PROD_POS_SIZE")))
			nPos++

			//Adiciona as informações no array de inclusão/atualização
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_FILIAL"  )] := (cAliasQry)->BZ_FILIAL
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_PROD"    )] := (cAliasQry)->BZ_COD
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_LOCPAD"  )] := (cAliasQry)->BZ_LOCPAD
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_QE"      )] := (cAliasQry)->BZ_QE
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_EMIN"    )] := (cAliasQry)->BZ_EMIN
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_ESTSEG"  )] := (cAliasQry)->BZ_ESTSEG
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_PE"      )] := (cAliasQry)->BZ_PE
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_TIPE"    )] := M019CnvFld("BZ_TIPE"   , (cAliasQry)->BZ_TIPE)
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_LE"      )] := (cAliasQry)->BZ_LE
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_LM"      )] := (cAliasQry)->BZ_LM
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_TOLER"   )] := (cAliasQry)->BZ_TOLER
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_MRP"     )] := M019CnvFld("BZ_MRP"    , (cAliasQry)->BZ_MRP)
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_REVATU"  )] := (cAliasQry)->BZ_REVATU
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_EMAX"    )] := (cAliasQry)->BZ_EMAX
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_HORFIX"  )] := (cAliasQry)->BZ_HORFIX
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_TPHFIX"  )] := (cAliasQry)->BZ_TPHOFIX
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_IDREG"   )] := (cAliasQry)->BZ_FILIAL+(cAliasQry)->BZ_COD
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_OPC"     )] := (cAliasQry)->BZ_MOPC
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_STR_OPC" )] := (cAliasQry)->BZ_OPC
			aDadosInc[nPos][A019APICnt("ARRAY_IND_PROD_POS_QTDB"    )] := (cAliasQry)->BZ_QB

			(cAliasQry)->(dbSkip())

			If cFilBkp != (cAliasQry)->(BZ_FILIAL)
				// Verifica se precisa trocar o cFilAnt para sincronizar os opcionais corretamente.
				// (seta cFilAnt de acordo com o compartilhamento da tabela, para buscar na filial correta, a estrutura com os opcionais)
				// Se necessario trocar cFilant, sincroniza os produtos que já foram processados.
				lTrocouFil := setFilAnt((cAliasQry)->(BZ_FILIAL), "SBZ")

				If lTrocouFil
					cFilBkp := (cAliasQry)->(BZ_FILIAL)
				EndIf
			EndIf

			If nPos > VOL_BUFFER .Or. (cAliasQry)->(Eof()) .Or. lTrocouFil
				//Chama a função do MATA019API para integrar os registros
				MATA019INT("SYNC", aDadosInc, @aSuccess, @aError, .F. /*OnlyDel*/, /*cUUID*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
				lTrocouFil := .F.
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))
Return

/*/{Protheus.doc} PrdContReg
Conta quantos registros de produto serão considerados na sincronização
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 cFilCent, Character, Filial onde deve ser executada a query
@return nRegistros, Numeric, Quantidade de registros encontrados na execução da query
/*/
Static Function PrdContReg()
	Local cQuery     := 0
	Local nRegistros := 0

	cQuery := getQrySb1(aEmprCent, .T.)
	If valFilQry(cQuery, IND_TELA_PRODUTOS)
		nRegistros := calculaReg(cQuery, IND_TELA_PRODUTOS)
	EndIf

Return nRegistros

/*/{Protheus.doc} EtrContReg
Conta quantos registros de estrutura serão considerados na sincronização
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 cFilCent, Character, Filial onde deve ser executada a query
@return nRegistros, Numeric, Quantidade de registros encontrados na execução da query
/*/
Static Function EtrContReg(cFilCent)
	Local cQuery     := ""
	Local nRegistros := 0

	cQuery := " ("
	cQuery += " SELECT DISTINCT SG1.G1_FILIAL, SG1.G1_COD "
	cQuery +=   " FROM " + RetSqlName("SG1") + " SG1 "
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1",cFilCent) + "' "
	cQuery +=    " AND SB1.B1_COD     = SG1.G1_COD "
	cQuery +=    " AND SB1.B1_MSBLQL  <> '1' "
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SG1.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SG1.G1_FILIAL  = '" + xFilial("SG1",cFilCent) + "' "
	cQuery += " ) CNT "

	If valFilQry(cQuery, IND_TELA_ESTRUTURA)
		cQuery := "%" + cQuery + "%"
		nRegistros := calculaReg(cQuery, IND_TELA_ESTRUTURA)
		aParTela[IND_TELA_ESTRUTURA][IND_PAR_QUERY][Len(aParTela[IND_TELA_ESTRUTURA][IND_PAR_QUERY])] := cFilCent
	EndIf

Return nRegistros

/*/{Protheus.doc} OrdContReg
Conta quantos registros de ordem de produção serão considerados na sincronização
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 cFilCent, Character, Filial onde deve ser executada a query
@return nRegistros, Numeric, Quantidade de registros encontrados na execução da query
/*/
Static Function OrdContReg(cFilCent)
	Local cQuery     := "%" + RetSqlName(aParTela[IND_TELA_ORDEM_PROD][IND_PAR_ALIAS]) + " WHERE D_E_L_E_T_ = ' ' "
	Local nRegistros := 0

	If valFilQry(xFilial("SC2",cFilCent), IND_TELA_ORDEM_PROD)
		cQuery += QryCondSC2(.T., cFilCent) + "%"
		nRegistros := calculaReg(cQuery, IND_TELA_ORDEM_PROD)
	EndIf

Return nRegistros

/*/{Protheus.doc} EmpContReg
Conta quantos registros de empenho serão considerados na sincronização
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 cFilCent, Character, Filial onde deve ser executada a query
@return nRegistros, Numeric, Quantidade de registros encontrados na execução da query
/*/
Static Function EmpContReg(cFilCent)
	Local cBanco     := AllTrim(Upper(TcGetDb()))
	Local cQuery     := ""
	Local cQueryCond := ""
	Local nRegistros := 0

	cQueryCond :=  " SELECT SD4.D4_FILIAL, "
	cQueryCond +=         " SD4.D4_COD, "
	cQueryCond +=         " SD4.D4_OP, "
	cQueryCond +=         " SD4.D4_OPORIG, "
	cQueryCond +=         " SD4.D4_DATA, "
	cQueryCond +=         " SD4.D4_TRT, "
	cQueryCond +=         " SD4.D4_QUANT, "
	cQueryCond +=         " SD4.D4_QSUSP, "
	cQueryCond +=         " SD4.D4_LOCAL, "
	cQueryCond +=         " SD4.R_E_C_N_O_ "
	cQueryCond +=    " FROM " + RetSqlName("SD4") + " SD4 INNER JOIN " + RetSqlName("SC2") + " SC2 ON "

	If cBanco == "POSTGRES"
		cQueryCond += " TRIM(SD4.D4_OP) = TRIM((SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD )) "
	Else
		cQueryCond += " SD4.D4_OP = (SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD ) "
	EndIf

	cQueryCond += " AND SD4.D4_QUANT <> 0 ";
				+ " AND SD4.D_E_L_E_T_ = ' ' ";
				+ " AND SD4.D4_FILIAL = '" + xFilial("SD4",cFilCent) + "' ";
				+ " AND SC2.C2_FILIAL = '" + xFilial("SC2",cFilCent) + "' ";
				+ " AND SC2.D_E_L_E_T_ = ' ' ";
				+ " AND SC2.C2_DATRF = ' ' ";
				+ " AND (SC2.C2_QUANT-SC2.C2_QUJE - ";
				+ Iif(SuperGetMV("MV_PERDINF",.F.,.F.), "0", "C2_PERDA") + ") >= 0 "

	If valFilQry(cQueryCond, IND_TELA_EMPENHOS)
		cQuery := "% ( " + cQuerycond + " ) SD4a %"
		nRegistros := calculaReg(cQuery, IND_TELA_EMPENHOS)
	EndIf

Return nRegistros

/*/{Protheus.doc} EstContReg
Conta quantos registros de saldo de estoque serão considerados na sincronização
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 cFilCent, Character, Filial onde deve ser executada a query
@return nRegistros, Numeric, Quantidade de registros encontrados na execução da query
/*/
Static Function EstContReg(cFilCent)
	Local cLoteUni   := SuperGetMv("MV_LOTEUNI",.F.,.F.)
	Local cQuery     := ""
	Local nRegistros := 0

	cQuery := " (";
				+ "SELECT branchId,";
						+ " product,";
						+ " warehouse,";
						+ " lot,";
						+ " sublot,";
						+ " expirationDate,";
						+ " SUM(availableQuantity)   AS availableQuantity,";
						+ " SUM(consignedOut)        AS consignedOut,";
						+ " SUM(consignedIn)         AS consignedIn,";
						+ " SUM(unavailableQuantity) AS unavailableQuantity,";
						+ " SUM(blockedBalance)      AS blockedBalance";
				+ " FROM ("

	cQuery += " SELECT SB2.B2_FILIAL      AS branchId,";
						+ " SB2.B2_COD    AS product,";
						+ " SB2.B2_LOCAL  AS warehouse,";
						+ " ''            AS lot,";
						+ " ''            AS sublot,";
						+ " ''            AS expirationDate, ";
						+ " (CASE WHEN B1_RASTRO IN ('L', 'S') THEN 0 ELSE B2_QATU END) AS availableQuantity,";
						+ " 0             AS consignedOut,";   //saldo em poder de terc será obtido pela SB6 e SD5
						+ " SB2.B2_QTNP   AS consignedIn,";
						+ " 0             AS unavailableQuantity,";
						+ " 0             AS blockedBalance";
					+ " FROM " + RetSqlName("SB2");
						+ " SB2 INNER JOIN (SELECT B1_COD, B1_RASTRO";
						+                   " FROM " + RetSqlName("SB1");
						+                  " WHERE D_E_L_E_T_ = ' '";
						+                    " AND B1_FILIAL = '" + xFilial("SB1",cFilCent) + "' ) SB1";
						+ " 	ON SB2.B2_COD = SB1.B1_COD";
				+ " WHERE SB2.D_E_L_E_T_ = ' '";
				+   " AND SB2.B2_FILIAL  = '" + xFilial("SB2",cFilCent) + "'"

				//Busca saldo disponível na SB8 quando tem lote/sublote
				//Quando o parâmetro MV_LOTEUNI está F e o produto controla lote, o sublote é preenchido automaticamente pelo sistema
				//Por esse motivo foi feita uma quebra na SB8 para retornar o sublote em branco quando não controlar sublote e o mesmo for preenchido automaticamente
				//Essa regra de retornar o sublote em branco será aplicada para o Bloqueio e Em Terceiro
				IF !cLoteUni
					cQuery += " UNION ALL";
					+ " SELECT  SB8.B8_FILIAL   AS branchId,";
							+ " SB8.B8_PRODUTO  AS product,";
							+ " SB8.B8_LOCAL    AS warehouse,";
							+ " SB8.B8_LOTECTL  AS lot,";
							+ " ' '             AS sublot,";
							+ " SB8.B8_DTVALID  AS expirationDate,";
							+ " SB8.B8_SALDO    AS availableQuantity,";
							+ " 0               AS consignedOut,";
							+ " 0               AS consignedIn,";
							+ " 0               AS unavailableQuantity,";
							+ " 0               AS blockedBalance";
					+ " FROM " + RetSqlName("SB8") + " SB8";
					+ " INNER JOIN (SELECT B1_COD, B1_RASTRO";
								+   " FROM " + RetSqlName("SB1");
								+  " WHERE D_E_L_E_T_ = ' '";
								+   " AND B1_FILIAL = '" + xFilial("SB1",cFilCent) + "'";
								+   " AND B1_RASTRO IN ('L')) SB1";
							+ " ON SB8.B8_PRODUTO = SB1.B1_COD";
					+ " WHERE SB8.D_E_L_E_T_ = ' '";
					+   " AND SB8.B8_SALDO > 0";
					+   " AND SB8.B8_FILIAL = '" + xFilial("SB8",cFilCent) + "'";
					+ " UNION ALL";
					+ " SELECT  SB8.B8_FILIAL   AS branchId,";
							+ " SB8.B8_PRODUTO  AS product,";
							+ " SB8.B8_LOCAL    AS warehouse,";
							+ " SB8.B8_LOTECTL  AS lot,";
							+ " SB8.B8_NUMLOTE  AS sublot,";
							+ " SB8.B8_DTVALID  AS expirationDate,";
							+ " SB8.B8_SALDO    AS availableQuantity,";
							+ " 0               AS consignedOut,";
							+ " 0               AS consignedIn,";
							+ " 0               AS unavailableQuantity,";
							+ " 0               AS blockedBalance";
					+ " FROM " + RetSqlName("SB8") + " SB8";
					+ " INNER JOIN (SELECT B1_COD, B1_RASTRO";
								+   " FROM " + RetSqlName("SB1");
								+  " WHERE D_E_L_E_T_ = ' '";
								+   " AND B1_FILIAL = '" + xFilial("SB1",cFilCent) + "'";
								+   " AND B1_RASTRO IN ('S')) SB1";
							+ " ON SB8.B8_PRODUTO = SB1.B1_COD";
					+ " WHERE SB8.D_E_L_E_T_ = ' '";
					+   " AND SB8.B8_SALDO > 0";
					+   " AND SB8.B8_FILIAL = '" + xFilial("SB8",cFilCent) + "'"
				Else
					cQuery += " UNION ALL";
					+ " SELECT  SB8.B8_FILIAL   AS branchId,";
							+ " SB8.B8_PRODUTO  AS product,";
							+ " SB8.B8_LOCAL    AS warehouse,";
							+ " SB8.B8_LOTECTL  AS lot,";
							+ " SB8.B8_NUMLOTE  AS sublot,";
							+ " SB8.B8_DTVALID  AS expirationDate,";
							+ " SB8.B8_SALDO    AS availableQuantity,";
							+ " 0               AS consignedOut,";
							+ " 0               AS consignedIn,";
							+ " 0               AS unavailableQuantity,";
							+ " 0               AS blockedBalance";
					+ " FROM " + RetSqlName("SB8") + " SB8";
					+ " INNER JOIN (SELECT B1_COD, B1_RASTRO";
								+   " FROM " + RetSqlName("SB1");
								+  " WHERE D_E_L_E_T_ = ' '";
								+   " AND B1_FILIAL = '" + xFilial("SB1",cFilCent) + "'";
								+   " AND B1_RASTRO IN ('L','S')) SB1";
							+ " ON SB8.B8_PRODUTO = SB1.B1_COD";
					+ " WHERE SB8.D_E_L_E_T_ = ' '";
					+   " AND SB8.B8_SALDO > 0";
					+   " AND SB8.B8_FILIAL = '" + xFilial("SB8",cFilCent) + "'"
				EndIF

				//Busca saldo Em Terceiros - Sem lote e sem sublote
                cQuery += " UNION ALL";
				+ " SELECT SB6.B6_FILIAL   AS branchId,";
                       + " SB6.B6_PRODUTO  AS product,";
                       + " SB6.B6_LOCAL    AS warehouse,";
                       + " ''              AS lot,";
                       + " ''              AS sublot,";
                       + " ''              AS expirationDate,";
			 	       + " 0               AS availableQuantity,";
					   + " SB6.B6_SALDO    AS consignedOut,";
                       + " 0               AS consignedIn,";
                       + " 0               AS unavailableQuantity,";
                       + " 0               AS blockedBalance";
				 +  " FROM " + RetSqlName("SB6")+" SB6";
                 + " INNER JOIN (SELECT B1_COD, B1_RASTRO";
				              + " FROM " + RetSqlName("SB1");
                              + " WHERE D_E_L_E_T_ = ' '";
							  + " AND B1_FILIAL = '" + xFilial("SB1",cFilCent) + "'";
                              + " AND B1_RASTRO NOT IN ('L','S')) SB1";
				    + " ON SB6.B6_PRODUTO = SB1.B1_COD";
                +  " WHERE SB6.D_E_L_E_T_ = ' '";
				+    " AND SB6.B6_QUANT > 0";
				+    " AND SB6.B6_TIPO = 'E'";
				+    " AND SB6.B6_FILIAL = '" + xFilial("SB6",cFilCent) + "'";
				+    " AND SB6.B6_PODER3 = 'R'";
				+    " AND SB6.B6_ESTOQUE = 'S'"

				//Busca saldo Em Terceiros - Com lote e sublote
                //DMANSMARTSQUAD1-29833 - Vivian - 20/09/2024
	            //Existe uma questão quando numa mesma NF de remessa forem enviados mais de um lote/sublote do mesmo produto
	            //Algumas informações estão só na SB6 (como a indentificação do tipo do movimento - B6_PODER3 = R (remessa) e D (devolução)).
	            //Está sendo utilizado o campo B6_SALDO para determinar a quantidade em terceiro, porque na SD5 tem a quantidade que foi
	            //enviada para terceiro, porém as quantidades retornadas estão em outros registros da SD5, o correto seria ser efetuado
	            //cálculo (saldo = remessa - retorno), porém, o relacionamento entre as tabelas SB6 e SD5 é efetuado pelo B6_IDENT = D5_NUMSEQ
	            //Quando é efetuada remessa, é gerado um registro na SB6 com B6_IDENT igual ao D5_NUMSEQ gerado na SD5, porém ao efetuar
	            //devolução é gerado novo registro da SB6, com o B6_IDENT igual ao B6_IDENT da remessa, e na SD5 é gerado um D5_NUMSEQ novo,
	            //que não relaciona com a SB6.
	            //Para que fosse possível efetuar o cálculo, teria que ter um campo B6_NUMSEQ na SB6, para gravar o NUMSEQ que relaciona
	            //exatamente com a SD5, e o B6_IDENT ser utilizado para identificar todos os registros da SB6 referentes à remessa X, ou ter .
	            //outra tabela que faça esse relacionamento (que pode existir e não sabemos - seria necessário tratar com a equipe de estoque)
	            //Optamos por não fazer esse movimento (de envolver a equipe de estoque), nesse momento, devido a urgência da liberação da
	            //correção da issue, e só termos identificados problemas em testes internos (nos problemas das issues anteriores, identificados
	            //por clientes não havia essa situação).

				IF !cLoteUni
					//Foram montadas duas queries, uma para o Lote e outra para o Sublote.
					//Retornar o sublote me branco quando não controlar sublote e o mesmo for preenchido automaticamente

					//Query do lote - fixando o sublote em branco
					cQuery += " UNION ALL";
					+ " SELECT SD5.D5_FILIAL   AS branchId, ";
					       + " SB6a.B6_PRODUTO AS product, ";
					       + " SB6a.B6_LOCAL   AS warehouse, ";
					       + " SD5.D5_LOTECTL  AS lot, ";
					       + " ' '             AS sublot, ";
					       + " SD5.D5_DTVALID  AS expirationDate, ";
					       + " 0               AS availableQuantity, ";
					       + " SB6a.B6_SALDO   AS consignedOut, ";
					       + " 0               AS consignedIn, ";
					       + " 0               AS unavailableQuantity, ";
					       + " 0               AS blockedBalance ";
					 +  " FROM " + RetSqlName("SB6") + " SB6a ";
					 + " INNER JOIN " + RetSqlName("SB1") + " SB1 ";
					 +    " ON SB1.B1_FILIAL = '" + xFilial("SB1",cFilCent) + "' ";
					 +   " AND SB1.B1_COD = SB6a.B6_PRODUTO ";
					 +   " AND SB1.B1_RASTRO = 'L' ";
					 +   " AND SB1.D_E_L_E_T_ = ' ' ";
					 + " INNER JOIN (SELECT SD5.D5_FILIAL, ";
					                    + " SD5.D5_PRODUTO, ";
					                    + " SD5.D5_LOCAL, ";
					                    + " SD5.D5_DOC, ";
					                    + " SD5.D5_SERIE, ";
					                    + " SD5.D5_ORIGLAN, ";
					                    + " SD5.D5_NUMSEQ, ";
					                    + " SD5.D5_LOTECTL, ";
					                    + " SD5.D5_DTVALID ";
					              +  " FROM " + RetSqlName("SD5") + " SD5 ";
					              + " WHERE SD5.D5_FILIAL = '" + xFilial("SD5",cFilCent) + "' ";
					              +   " AND SD5.D5_QUANT > 0 ";
					              +   " AND SD5.D_E_L_E_T_ = ' ' ";
					              + " GROUP BY SD5.D5_FILIAL, ";
					                       + " SD5.D5_PRODUTO, ";
					                       + " SD5.D5_LOCAL, ";
					                       + " SD5.D5_DOC, ";
					                       + " SD5.D5_SERIE, ";
					                       + " SD5.D5_ORIGLAN, ";
					                       + " SD5.D5_NUMSEQ, ";
					                       + " SD5.D5_LOTECTL, ";
					                       + " SD5.D5_DTVALID) SD5 ";
					   +  " ON SD5.D5_PRODUTO = SB6a.B6_PRODUTO ";
					   + " AND SD5.D5_LOCAL = SB6a.B6_LOCAL  ";
					   + " AND SD5.D5_DOC = SB6a.B6_DOC ";
					   + " AND SD5.D5_SERIE = SB6a.B6_SERIE ";
					   + " AND SD5.D5_ORIGLAN = SB6a.B6_TES ";
					   + " AND SD5.D5_NUMSEQ = SB6a.B6_IDENT ";
					 + " WHERE SB6a.B6_FILIAL = '" + xFilial("SB6",cFilCent) + "' ";
					 +   " AND SB6a.B6_TIPO = 'E' ";
					 +   " AND SB6a.B6_PODER3 = 'R' ";
					 +   " AND SB6a.B6_ESTOQUE = 'S' ";
					 +   " AND SB6a.D_E_L_E_T_ = ' ' ";

					//Query do Sublote - gravando o valor do sublote
					cQuery += " UNION ALL";
				    + " SELECT SD5.D5_FILIAL   AS branchId, ";
					       + " SB6a.B6_PRODUTO AS product, ";
					       + " SB6a.B6_LOCAL   AS warehouse, ";
					       + " SD5.D5_LOTECTL  AS lot, ";
					       + " SD5.D5_NUMLOTE  AS sublot, ";
					       + " SD5.D5_DTVALID  AS expirationDate, ";
					       + " 0               AS availableQuantity, ";
					       + " SB6a.B6_SALDO   AS consignedOut, ";
					       + " 0               AS consignedIn, ";
					       + " 0               AS unavailableQuantity, ";
					       + " 0               AS blockedBalance  ";
					+   " FROM " + RetSqlName("SB6") + " SB6a ";
					+  " INNER JOIN " + RetSqlName("SB1") + " SB1 ";
					+     " ON SB1.B1_FILIAL = '" + xFilial("SB1",cFilCent) + "' ";
					+    " AND SB1.B1_COD = SB6a.B6_PRODUTO ";
					+    " AND SB1.B1_RASTRO = 'S' ";
					+    " AND SB1.D_E_L_E_T_ = ' ' ";
					+  " INNER JOIN (SELECT SD5.D5_FILIAL, ";
					                    + " SD5.D5_PRODUTO, ";
					                    + " SD5.D5_LOCAL, ";
					                    + " SD5.D5_DOC, ";
					                    + " SD5.D5_SERIE, ";
					                    + " SD5.D5_ORIGLAN, ";
					                    + " SD5.D5_NUMSEQ, ";
					                    + " SD5.D5_LOTECTL, ";
					                    + " SD5.D5_NUMLOTE, ";
					                    + " SD5.D5_DTVALID ";
					              +  " FROM " + RetSqlName("SD5") + " SD5 ";
					              + " WHERE SD5.D5_FILIAL = '" + xFilial("SD5",cFilCent) + "' ";
					              +   " AND SD5.D5_QUANT > 0 ";
					              +   " AND SD5.D_E_L_E_T_ = ' ' ";
					              + " GROUP BY SD5.D5_FILIAL, ";
					                       + " SD5.D5_PRODUTO, ";
					                       + " SD5.D5_LOCAL, ";
					                       + " SD5.D5_DOC, ";
					                       + " SD5.D5_SERIE, ";
					                       + " SD5.D5_ORIGLAN, ";
					                       + " SD5.D5_NUMSEQ, ";
					                       + " SD5.D5_LOTECTL, ";
					                       + " SD5.D5_NUMLOTE, ";
					                       + " SD5.D5_DTVALID) SD5 ";
					   +  " ON SD5.D5_PRODUTO = SB6a.B6_PRODUTO ";
					   + " AND SD5.D5_LOCAL = SB6a.B6_LOCAL ";
					   + " AND SD5.D5_DOC = SB6a.B6_DOC ";
					   + " AND SD5.D5_SERIE = SB6a.B6_SERIE ";
					   + " AND SD5.D5_ORIGLAN = SB6a.B6_TES ";
					   + " AND SD5.D5_NUMSEQ = SB6a.B6_IDENT ";
					 + " WHERE SB6a.B6_FILIAL = '" + xFilial("SB6",cFilCent) + "' ";
					 +   " AND SB6a.B6_TIPO = 'E' ";
					 +   " AND SB6a.B6_PODER3 = 'R' ";
					 +   " AND SB6a.B6_ESTOQUE = 'S' ";
					 +   " AND SB6a.D_E_L_E_T_ = ' ' "
				Else
					cQuery +=  " UNION ALL";
					        + " SELECT SD5.D5_FILIAL   AS branchId, ";
					               + " SB6a.B6_PRODUTO AS product, ";
					               + " SB6a.B6_LOCAL   AS warehouse, ";
					               + " SD5.D5_LOTECTL  AS lot, ";
					               + " SD5.D5_NUMLOTE  AS sublot, ";
					               + " SD5.D5_DTVALID  AS expirationDate, ";
					               + " 0               AS availableQuantity, ";
					               + " SB6a.B6_SALDO   AS consignedOut, ";
					               + " 0               AS consignedIn, ";
					               + " 0               AS unavailableQuantity, ";
					               + " 0               AS blockedBalance ";
					         +  " FROM " + RetSqlName("SB6") + " SB6a ";
					         + " INNER JOIN " + RetSqlName("SB1") + " SB1 ";
					         +    " ON SB1.B1_FILIAL = '" + xFilial("SB1",cFilCent) + "' ";
					         +   " AND SB1.B1_COD = SB6a.B6_PRODUTO  ";
					         +   " AND SB1.B1_RASTRO IN ('L', 'S') ";
					         +   " AND SB1.D_E_L_E_T_ = ' ' ";
					         + " INNER JOIN (SELECT SD5.D5_FILIAL, ";
					                           +  " SD5.D5_PRODUTO, ";
					                           +  " SD5.D5_LOCAL, ";
					                           +  " SD5.D5_DOC, ";
					                           +  " SD5.D5_SERIE, ";
					                           +  " SD5.D5_ORIGLAN, ";
					                           +  " SD5.D5_NUMSEQ, ";
					                           +  " SD5.D5_LOTECTL, ";
					                           +  " SD5.D5_NUMLOTE, ";
					                           +  " SD5.D5_DTVALID ";
					                     +   " FROM " + RetSqlName("SD5") + " SD5 ";
					                     +  " WHERE SD5.D5_FILIAL = '" + xFilial("SD5",cFilCent) + "' ";
					                     +    " AND SD5.D5_QUANT > 0 ";
					                     +    " AND SD5.D_E_L_E_T_ = ' ' ";
					                     +  " GROUP BY SD5.D5_FILIAL, ";
					                              +  " SD5.D5_PRODUTO, ";
					                              +  " SD5.D5_LOCAL, ";
					                              +  " SD5.D5_DOC, ";
					                              +  " SD5.D5_SERIE, ";
					                              +  " SD5.D5_ORIGLAN, ";
					                              +  " SD5.D5_NUMSEQ, ";
					                              +  " SD5.D5_LOTECTL, ";
					                              +  " SD5.D5_NUMLOTE, ";
					                              +  " SD5.D5_DTVALID) SD5 ";
					           +  " ON SD5.D5_PRODUTO = SB6a.B6_PRODUTO  ";
					           + " AND SD5.D5_LOCAL = SB6a.B6_LOCAL ";
					           + " AND SD5.D5_DOC = SB6a.B6_DOC ";
					           + " AND SD5.D5_SERIE = SB6a.B6_SERIE  ";
					           + " AND SD5.D5_ORIGLAN = SB6a.B6_TES ";
					           + " AND SD5.D5_NUMSEQ = SB6a.B6_IDENT ";
					         + " WHERE SB6a.B6_FILIAL = '" + xFilial("SB6",cFilCent) + "' ";
					           + " AND SB6a.B6_TIPO = 'E' ";
					           + " AND SB6a.B6_PODER3 = 'R' ";
					           + " AND SB6a.B6_ESTOQUE = 'S' ";
					           + " AND SB6a.D_E_L_E_T_ = ' ' "
				EndIf

				//Busca saldo Bloqueado	para produto com Lote
				cQuery += " UNION ALL";
				+ " SELECT	SDDa.DD_FILIAL   AS branchId,";
						+ "	SDDa.DD_PRODUTO  AS product,";
						+ "	SDDa.DD_LOCAL    AS warehouse,";
						+ "	SDDa.DD_LOTECTL  AS lot,";
						+ " SDDa.DD_NUMLOTE  AS sublot,";
						+ "	SDDa.DD_DTVALID  AS expirationDate,";
						+ "	0                AS availableQuantity,";
						+ "	0                AS consignedOut,";
						+ "	0                AS consignedIn,";
						+ "	0                AS unavailableQuantity,";
						+ "	SDDa.DD_SALDO    AS blockedBalance";
					+ " FROM " + RetSqlName("SDD")+" SDDa";
					+ " INNER JOIN (SELECT B1_COD, B1_RASTRO";
						        	+   " FROM " + RetSqlName("SB1");
						        	+  " WHERE D_E_L_E_T_ = ' '";
						        	+   " AND B1_FILIAL = '" + xFilial("SB1",cFilCent) + "'";
						        	+   " AND B1_RASTRO = 'L') SB1a";
						        + " ON SDDa.DD_PRODUTO = SB1a.B1_COD ";
								+ " WHERE SDDa.D_E_L_E_T_ = ' ' AND SDDa.DD_SALDO > 0 AND SDDa.DD_MOTIVO <> 'VV' AND SDDa.DD_FILIAL = '"+xFilial("SDD",cFilCent)+"'"

				//Busca saldo Bloqueado	para produto com Sublote
				cQuery += " UNION ALL";
				+ " SELECT	SDDb.DD_FILIAL   AS branchId,";
						+ "	SDDb.DD_PRODUTO  AS product,";
						+ "	SDDb.DD_LOCAL    AS warehouse,";
						+ "	SDDb.DD_LOTECTL  AS lot,";
						+ "	SB8c.B8_NUMLOTE  AS sublot,";
						+ "	SB8c.B8_DTVALID  AS expirationDate,";
						+ "	0                AS availableQuantity,";
						+ "	0                AS consignedOut,";
						+ "	0                AS consignedIn,";
						+ "	0                AS unavailableQuantity,";
						+ "	SDDb.DD_SALDO    AS blockedBalance";
					+ " FROM " + RetSqlName("SDD")+" SDDb";
					+ " INNER JOIN (SELECT B8_PRODUTO, B8_DTVALID, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE";
									+  " FROM " + RetSqlName("SB8")+" SB8";
                                    + " INNER JOIN (SELECT B1_COD, B1_RASTRO";
						        	+   " FROM " + RetSqlName("SB1");
						        	+  " WHERE D_E_L_E_T_ = ' '";
						        	+   " AND B1_FILIAL = '" + xFilial("SB1",cFilCent) + "'";
						        	+   " AND B1_RASTRO = 'S') SB1b";
						        + " ON SB8.B8_PRODUTO = SB1b.B1_COD";
									+ " WHERE D_E_L_E_T_ = ' ' AND B8_FILIAL = '" + xFilial("SB8",cFilCent) + "') SB8c";
							+ " ON SB8c.B8_PRODUTO = SDDb.DD_PRODUTO";
								+ " AND SB8c.B8_LOCAL = SDDb.DD_LOCAL";
								+ " AND SB8c.B8_LOTECTL = SDDb.DD_LOTECTL";
								+ " AND SB8c.B8_NUMLOTE = SDDb.DD_NUMLOTE";
				+ " WHERE SDDb.D_E_L_E_T_ = ' ' AND SDDb.DD_SALDO > 0 AND SDDb.DD_MOTIVO <> 'VV' AND SDDb.DD_FILIAL = '"+xFilial("SDD",cFilCent)+"'"

	cQuery += ") SB2a";
				+ " GROUP BY branchId,";
							+ " product,";
							+ " warehouse,";
							+ " lot,";
							+ " sublot,";
							+ " expirationDate";
				+ " HAVING SUM(availableQuantity)";
						+ "+SUM(consignedOut)";
						+ "+SUM(consignedIn)";
						+ "+SUM(unavailableQuantity)";
						+ "+SUM(blockedBalance) != 0";
				+ ") SB2b"

	If valFilQry(cQuery, IND_TELA_ESTOQUES)
		cQuery := "%" + cQuery + "%"
		nRegistros := calculaReg(cQuery, IND_TELA_ESTOQUES)
	EndIf

Return nRegistros

/*/{Protheus.doc} SolContReg
Conta quantos registros de solicitação de compra serão considerados na sincronização
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 cFilCent, Character, Filial onde deve ser executada a query
@return nRegistros, Numeric, Quantidade de registros encontrados na execução da query
/*/
Static Function SolContReg(cFilCent)
	Local cQuery     := ""
	Local nRegistros := 0
	Local cFilSol    := xFilial("SC1",cFilCent)

	cQuery := "%" + RetSqlName(aParTela[IND_TELA_SOL_COMPRAS][IND_PAR_ALIAS]) + " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND C1_FILIAL  = '" + cFilSol + "' "
	cQuery += " AND C1_QUJE    < C1_QUANT ";
				+ " AND C1_RESIDUO = '" + CriaVar("C1_RESIDUO",.F.) + "' ";
				+ IIf(SuperGetMV("MV_MRPSCRE",.F.,.T.), "", " AND C1_ORIGEM <> 'MATA106' ")
	cQuery += "%"

	If valFilQry(cFilSol, IND_TELA_SOL_COMPRAS)
		nRegistros := calculaReg(cQuery, IND_TELA_SOL_COMPRAS)
	EndIf

Return nRegistros

/*/{Protheus.doc} PecContReg
Conta quantos registros de pedido de compra serão considerados na sincronização
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 cFilCent, Character, Filial onde deve ser executada a query
@return nRegistros, Numeric, Quantidade de registros encontrados na execução da query
/*/
Static Function PecContReg(cFilCent)
	Local cQuery     := ""
	Local nRegistros := 0
	Local cFilPed    := xFilial("SC7",cFilCent)

	cQuery := "%" + RetSqlName(aParTela[IND_TELA_PED_COMPRAS][IND_PAR_ALIAS]) + " SC7 "
	cQuery += " WHERE SC7.D_E_L_E_T_ = ' ' "
	cQuery += " AND SC7.C7_FILIAL  = '" + cFilPed + "' "
	cQuery += " AND SC7.C7_QUJE    < SC7.C7_QUANT "
	cQuery += " AND SC7.C7_RESIDUO = '" + CriaVar("C7_RESIDUO",.F.) + "' "
	cQuery += " AND (SC7.C7_TES IN (SELECT SF4.F4_CODIGO "
	cQuery +=                       " FROM " + RetSqlName("SF4") + " SF4 "
	cQuery +=                      " WHERE SF4.F4_FILIAL  = '" + xFilial("SF4") + "' "
	cQuery +=                        " AND SF4.F4_CODIGO = SC7.C7_TES "
	cQuery +=                        " AND SF4.F4_ESTOQUE = 'S' "
	cQuery +=                        " AND SF4.D_E_L_E_T_ = ' ') "
	cQuery +=  " OR  SC7.C7_TES = ' ')
	cQuery += + " %"

	If valFilQry(cFilPed, IND_TELA_PED_COMPRAS)
		nRegistros := calculaReg(cQuery, IND_TELA_PED_COMPRAS)
	EndIf

Return nRegistros

/*/{Protheus.doc} padContReg
Função padrão que conta quantos registros serão considerados na sincronização
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 nIndTela, Numeric  , Indice do processo no array aParTela
@param 02 cFilCent, Character, Filial onde deve ser executada a query
@return nRegistros, Numeric, Quantidade de registros encontrados na execução da query
/*/
Static Function padContReg(nIndTela, cFilCent)
	Local cFilCom    := xFilial(aParTela[nIndTela][IND_PAR_ALIAS],cFilCent)
	Local cQuery     := "% " + RetSqlName(aParTela[nIndTela][IND_PAR_ALIAS]) + " WHERE D_E_L_E_T_ = ' ' AND "
	Local nRegistros := 0

	If Left(aParTela[nIndTela][IND_PAR_ALIAS], 1) == "S"
		cQuery += SubStr(aParTela[nIndTela][IND_PAR_ALIAS] + "_FILIAL = '" + cFilCom + "' ", 2) + "%"
	Else
		cQuery += aParTela[nIndTela][IND_PAR_ALIAS] + "_FILIAL = '" + cFilCom + "'%"
	EndIf

	If valFilQry(cFilCom, nIndTela)
		nRegistros := calculaReg(cQuery, nIndTela)
	EndIf

Return nRegistros

/*/{Protheus.doc} CqlContReg
Conta quantos registros de material rejeitado pelo CQ serão considerados na sincronização
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 cFilCent, Character, Filial onde deve ser executada a query
@return nRegistros, Numeric, Quantidade de registros encontrados na execução da query
/*/
Static Function CqlContReg(cFilCent)
	Local cQuery     := ""
	Local lConsidLt  := Iif(FindFunction("mrpLoteCQ"), mrpLoteCQ(), .F.)
	Local nRegistros := 0

	cQuery := " ( "
	cQuery +=  " SELECT branchId, "
	cQuery +=         " product, "
	cQuery +=         " SUM(quantity) as quantity, "
	cQuery +=         " warehouse, "
	cQuery +=         " invoiceDate, "
	cQuery +=         " SUM(returnedQuantity) as returnedQuantity, "
	cQuery +=         " lot, "
	cQuery +=         " subLot "
	cQuery +=    " FROM (

	cQuery +=      " SELECT SD7.D7_FILIAL         as branchId, "
	cQuery +=             " SD7.D7_PRODUTO        as product, "
	cQuery +=             " SD7.D7_QTDE           as quantity, "
	cQuery +=             " SD7.D7_LOCDEST        as warehouse, "
	cQuery +=             " SD7.D7_DATA           as invoiceDate, "
	cQuery +=             " COALESCE(D2_QUANT, 0) as returnedQuantity, "
	cQuery +=             " SD7.D7_LOTECTL        as lot, "
	cQuery +=             " SD7.D7_NUMLOTE        as subLot "
	cQuery +=        " FROM (SELECT D7_FILIAL, D7_PRODUTO, SUM(D7_QTDE) as D7_QTDE, D7_LOCDEST, D7_DATA, D7_FORNECE, D7_LOJA, D7_DOC, D7_SERIE, D7_TIPO, "

	If lConsidLt
		cQuery += "D7_LOTECTL, D7_NUMLOTE "
	Else
		cQuery += "' ' D7_LOTECTL, ' ' D7_NUMLOTE "
	EndIf

	cQuery +=                " FROM " + RetSqlName("SD7")
	cQuery +=               " WHERE D7_TIPO IN (2,6) "
	cQuery +=                 " AND D7_FILIAL = '" + xFilial("SD7",cFilCent) + "' "
	cQuery +=                 " AND D7_ESTORNO <> 'S' "
	cQuery +=               " GROUP BY D7_FILIAL, D7_PRODUTO, D7_LOCDEST, D7_DATA, D7_LOTECTL, D7_NUMLOTE, D7_FORNECE, D7_LOJA, D7_DOC, D7_SERIE, D7_TIPO) SD7 "
	cQuery +=        " LEFT JOIN ( SELECT SUM(D2_QUANT) D2_QUANT, "
	cQuery +=                           " D2_FILIAL, "
	cQuery +=                           " D2_TIPO, "
	cQuery +=                           " D2_CLIENTE, "
	cQuery +=                           " D2_LOJA, "
	cQuery +=                           " D2_NFORI, "
	cQuery +=                           " D2_SERIORI, "
	cQuery +=                           " D2_COD, "
	cQuery +=                           " D2_LOTECTL, "
	cQuery +=                           " D2_NUMLOTE "
	cQuery +=                      " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery +=                     " WHERE D_E_L_E_T_ = ' ' "
	cQuery +=                       " AND D2_TIPO = 'D' "
	cQuery +=                       " AND D2_FILIAL = '" + xFilial("SD2",cFilCent) + "' "
	cQuery +=                     " GROUP BY
	cQuery +=                              " D2_FILIAL, "
	cQuery +=                              " D2_TIPO, "
	cQuery +=                              " D2_CLIENTE, "
	cQuery +=                              " D2_LOJA, "
	cQuery +=                              " D2_NFORI, "
	cQuery +=                              " D2_SERIORI, "
	cQuery +=                              " D2_LOTECTL, "
	cQuery +=                              " D2_NUMLOTE, "
	cQuery +=                              " D2_COD ) SD2a "
	cQuery +=             " ON  SD7.D7_FORNECE = SD2a.D2_CLIENTE "
	cQuery +=             " AND SD7.D7_LOJA    = SD2a.D2_LOJA "
	cQuery +=             " AND SD7.D7_DOC     = SD2a.D2_NFORI "
	cQuery +=             " AND SD7.D7_SERIE   = SD2a.D2_SERIORI "
	cQuery +=             " AND SD7.D7_PRODUTO = SD2a.D2_COD "
	cQuery +=             " AND SD7.D7_TIPO    = 2 "

	If lConsidLt
		cQuery +=         " AND SD7.D7_LOTECTL = SD2a.D2_LOTECTL "
		cQuery +=         " AND SD7.D7_NUMLOTE = SD2a.D2_NUMLOTE "

	EndIf
	cQuery +=          " ) SD7a "
	cQuery +=   " GROUP BY branchId, "
	cQuery +=            " product, "
	cQuery +=            " warehouse, "
	cQuery +=            " invoiceDate, "
	cQuery +=            " lot, "
	cQuery +=            " subLot "
	cQuery += " ) SD7b "

	If valFilQry(cQuery, IND_TELA_CQ)
		cQuery := "%" + cQuery + "%"
		nRegistros := calculaReg(cQuery, IND_TELA_CQ)
	EndIf

Return nRegistros

/*/{Protheus.doc} valFilQry
Função responsável por validar se a query já foi processada, para não processá-la novamente
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 cFilQry , Character, String com o pedaço da query ou filial que deve ser validada
@param 02 nIndTela, Numeric  , Indice do processo no array aParTela
@return lRet, Logical, Retorna true se a query/filial pode ser processada
/*/
Static Function valFilQry(cFilQry, nIndTela)
	Local nPos := 0
	Local lRet := .F.

	nPos := aScan(aParTela[nIndTela][IND_PAR_CORE_QUERY], cFilQry)
	If nPos <= 0
		If aParTela[nIndTela][IND_PAR_CORE_QUERY] == NIl
			aParTela[nIndTela][IND_PAR_CORE_QUERY] := {}
		EndIf
		aAdd(aParTela[nIndTela][IND_PAR_CORE_QUERY], cFilQry)
		lRet := .T.
	EndIf
Return lRet

/*/{Protheus.doc} calculaReg
Executa no banco de dados a query para contar a quantidade de registros a serem sincronizados
@author  renan.roeder
@version P12
@since   04/05/2022
@param 01 cQueryCond, Character, Query para execução no banco de dados
@param 02 nIndTela  , Numeric  , Indice do processo no array aParTela
@return nRegistros, Numeric, Quantidade de registros encontrados na execução da query
/*/
Static Function calculaReg(cQueryCond, nIndTela)
	Local cAliasQry  := PCPAliasQr()
	Local cBanco     := AllTrim(Upper(TcGetDb()))
	Local cQuery     := ""
	Local nRegistros := 0

	If "MSSQL" $ cBanco
		cQueryCond := StrTran(cQueryCond, "||", "+")
	EndIf

	cQuery := " SELECT COUNT(*) QTDREG "
	cQuery +=   " FROM " + StrTran(cQueryCond, "%", " ")

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	nRegistros := (cAliasQry)->QTDREG
	aParTela[nIndTela][IND_PAR_QTD_TOTAL] := IIF(aParTela[nIndTela][IND_PAR_QTD_TOTAL] == Nil, nRegistros, aParTela[nIndTela][IND_PAR_QTD_TOTAL] + nRegistros)
	If aParTela[nIndTela][IND_PAR_QUERY] == NIl
		aParTela[nIndTela][IND_PAR_QUERY] := {}
	EndIf
	aAdd(aParTela[nIndTela][IND_PAR_QUERY], cQueryCond)

	(cAliasQry)->(dbCloseArea())

Return nRegistros

/*/{Protheus.doc} ResultProc
Exibe uma tela com o resultado da sincronização
@author  Marcelo Neumann
@version P12
@since   17/07/2019
@return  NIL
/*/
Static Function ResultProc(aDados)

	Local aLinhas := {}
	Local nInd    := 0
	Local oDlgResult
	Local oOk 	:= LoadBitmap(GetResources(),'br_verde')
	Local oWArn := LoadBitmap(GetResources(),'br_amarelo')
	Local oErr  := LoadBitmap(GetResources(),'br_vermelho')
	Local oLegenda

	Private aProc   := aDados
	Private cMsgRet := ""
	Private oBrowse
	Private oMsgRet

	For nInd := 1 To Len(aProc)
		If !Empty(aProc[nInd][IND_PAR_MSG_ERRO]) .And. ( aProc[1][IND_PAR_ALIAS] != "VAL" .Or. nInd == 1 )
			oLegenda := oErr
		ElseIf aProc[nInd][IND_PAR_QTD_ERRO] > 0 .Or. !aProc[nInd][IND_PAR_PROCESSADO]
			oLegenda := oWArn
		Else
			oLegenda := oOk
		EndIf

		aAdd(aLinhas, { oLegenda    					  , ;
						aProc[nInd][IND_PAR_DESCRICAO]    , ;
						aProc[nInd][IND_PAR_QTD_SUCESSO]  , ;
						aProc[nInd][IND_PAR_QTD_ERRO]})
	Next nInd

	If Len(aLinhas) < 1
		aAdd(aLinhas, {"", "", ""})
	EndIf

	DEFINE DIALOG oDlgResult TITLE STR0023 FROM 0,0 TO 520,460 PIXEL //"Resultado" //350 460

	oPanelSup := TPanel():New(0,0,,oDlgResult,,,,,, 400, 230, .F., .T.)
	oPanelSup:Align := CONTROL_ALIGN_TOP

	oBrowse := TWBrowse():New(01,01,230,190, ,{" ",STR0055,STR0025,STR0026},{10,140,30,30},oPanelSup,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,) //"Rotina" "Sucesso" "Erro"
	oBrowse:SetArray(aLinhas)
	oBrowse:bLine := {|| { aLinhas[oBrowse:nAt,1], aLinhas[oBrowse:nAt,2], aLinhas[oBrowse:nAt,3], aLinhas[oBrowse:nAt,4]}}
	oBrowse:bChange := { || AlteraMemo(oBrowse:nAt) }

	oPanelInf := TPanel():New(190,0,,oDlgResult,,,,,, 400, 50, .F., .F.)

	TSay():New(05, 05, {|| STR0056 }, oPanelInf, , , , , , .T., , , 100, 20) //"Mensagem:"
	oMsgRet := tMultiget():new(15, 05, {|u| If(PCount()==0,cMsgRet,cMsgRet:=u)}, oPanelInf,220,30,,,,,,.T.,,,{||.T.},,,.T.)

	DEFINE SBUTTON FROM 245, 205 TYPE 1 ACTION (oDlgResult:End()) ENABLE OF oDlgResult

	ACTIVATE MSDIALOG oDlgResult CENTERED

Return

/*/{Protheus.doc} AlteraMemo
Atualização do campo Memo da tela
@author  Douglas.heydt
@version P12
@since   05/11/2019
@return  NIL
/*/
Static Function AlteraMemo(nAt)

	cMsgRet := ""

	If !Empty(aProc[nAt][IND_PAR_MSG_ERRO])
		cMsgRet += STR0057 + aProc[nAt][IND_PAR_MSG_ERRO]//"Ocorreu uma falha de processamento: "
	Else
		cMsgRet += STR0058 + cValToChar(aProc[nAt][IND_PAR_QTD_SUCESSO])+CRLF //"Registros processados com sucesso: "
		cMsgRet += STR0059 + cValToChar(aProc[nAt][IND_PAR_QTD_ERRO])+CRLF //"Registros processados com erro (não sincronizados): "
	EndIf

	SetFocus(oMsgRet:HWND)
	SetFocus(oBrowse:HWND)

Return NIl

/*/{Protheus.doc} logSync
Verifica se existem APIs que devem ser sincronizadas e exibe alerta ao usuário.

@type  Static Function
@author lucas.franca
@since 29/07/2019
@version P12.1.28
@return .T.
/*/
Static Function logSync()

	MRPVldSync(.T.)

Return .T.

/*/{Protheus.doc} UpdateT4P
Atualiza o campo T4P_ALTER para as APIs que foram processadas.

@type  Static Function
@author lucas.franca
@since 29/07/2019
@version P12.1.28
@return .T.
/*/
Static Function UpdateT4P()
	Local cApiAtu_0 := ""
	Local cApiAtu_1 := ""
	Local nIndex    := 0

	For nIndex := 1 To Len(aParTela)
		If aParTela[nIndex][IND_PAR_CHECKED]
			If Empty(aParTela[nIndex][IND_PAR_MSG_ERRO])
				If aParTela[nIndex][IND_PAR_PROCESSADO]
					If !Empty(cApiAtu_0)
						cApiAtu_0 += ","
					EndIf
					cApiAtu_0 += "'" + aParTela[nIndex][IND_PAR_API] + "' "
				EndIf
			Else
				If !Empty(cApiAtu_1)
					cApiAtu_1 += ","
				EndIf
				cApiAtu_1 += "'" + aParTela[nIndex][IND_PAR_API] + "' "
			EndIf
		EndIf
	Next nIndex

	ExecUpdT4P(cApiAtu_0, "0")
	ExecUpdT4P(cApiAtu_1, "1")

Return .T.

/*/{Protheus.doc} ExecUpdT4P
Executa o UPDATE do campo T4P_ALTER

@type  Static Function
@author marcelo.neumann
@since 24/03/2020
@version P12.1.28
@param 01 cApis , Character, APIsa serem atualizadas (instrução IN)
@param 02 cAlter, Character, Indicador a ser gravado na coluna T4P_ALTER
@return Nil
/*/
Static Function ExecUpdT4P(cApis, cAlter)

	Local cUpdate := ""

	If !Empty(cApis)
		cUpdate := "UPDATE " + RetSqlName("T4P")                  + ;
		             " SET T4P_ALTER  = '" + cAlter         + "'" + ;
				   " WHERE T4P_FILIAL = '" + xFilial("T4P") + "'" + ;
		             " AND D_E_L_E_T_ = ' '"                      + ;
		             " AND T4P_API IN (" + cApis + ")"

		If TcSqlExec(cUpdate) < 0
			Final(STR0028, tcSQLError()) //"Erro ao atualizar as parametrizações do MRP."
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} limpaT4R
Limpa as pendências (T4R) de determinada API.

@type  Static Function
@author lucas.franca
@since 30/07/2019
@version P12.1.28
@param cApi, Character, Código da API que será utilizado para limpar a tabela T4R
@return Nil
/*/
Static Function limpaT4R(cApi)
	Local cAlias     := PCPAliasQr()
	Local cT4R       := RetSqlName("T4R")
	Local cSql       := ""
	Local nTentativa := 1

	cSql := " SELECT R_E_C_N_O_ REC "
	cSql +=   " FROM " + cT4R
	cSql +=  " WHERE T4R_FILIAL = '" + xFilial("T4R") + "' "
	cSql +=    " AND D_E_L_E_T_ = ' ' "
	cSql +=    " AND T4R_API   = '" + cApi + "' "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cSql),cAlias,.F.,.F.)

	While (cAlias)->(!Eof())
		nTentativa := 1

		cSql := " UPDATE " + cT4R
		cSql +=    " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
		cSql +=  " WHERE R_E_C_N_O_ = " + cValToChar((cAlias)->REC)

		For nTentativa := 1 To 10
			T4R->(dbGoTo((cAlias)->REC))
			If !T4R->(Deleted())
				If TcSqlExec(cSql) < 0
					If nTentativa == 10
						LogMsg('limpaT4R', 0, 0, 1, '', '', STR0065 + TcSqlError()) //"Erro ao eliminar T4R. "
						Exit
					Else
						LogMsg('limpaT4R', 0, 0, 1, '', '', STR0066 + cValToChar(nTentativa)    + ; //"Falha ao atualizar registro. Será executada nova tentativa. Tentativa atual: "
						                                    STR0067 + cValToChar((cAlias)->REC) + ; //" RECNO Registro: "
															STR0068 + TcSqlError())                 //". Erro: "
						Sleep(500)
					EndIf
				Else
					Exit
				EndIf
			Else
				Exit
			EndIf
		Next nTentativa
		(cAlias)->(dbSkip())
	End

Return Nil

/*/{Protheus.doc} QryCondSC2
Retorna a query utilizada na busca das Ordens de Produção.

@type  Static Function
@author marcelo.neumann
@since 13/08/2019
@version P12.1.28
@param 01 lSql     , Logical  , Indica se deve retornar o filtro no formato SQL ou ADVPL
@param 02 cFilCent , Logical  , Filial que deverá ser considerada na montagem da query
@return cQryCondic , Character, Query para filtro na SC2 no formato SQL ou ADVPL
/*/
Static Function QryCondSC2(lSql, cFilCent)
	Local cQryCondic := ""
	Local cPerda     := "C2_PERDA"

	If SuperGetMV("MV_PERDINF",.F.,.F.)
		cPerda := "0"
	EndIf

	If lSql
		cQryCondic := " AND C2_DATRF = ' ' AND (C2_QUANT - C2_QUJE - " + cPerda + ") > 0 "
		cQryCondic += " AND ( "
	Else
		cQryCondic := " Empty(C2_DATRF) .And. (C2_QUANT - C2_QUJE - " + cPerda + ") > 0 "
		cQryCondic += " .And. ( "
	EndIf

	cQryCondic += " C2_FILIAL = '" + xFilial("SC2",cFilCent) + "' "
	cQryCondic += " ) "

Return cQryCondic

/*/{Protheus.doc} procExt
Realiza o processamento da sincronização sem tela

@type  Static Function
@author douglas.heydt
@since 16/03/2020
@version P12.1.28
@param aApiAlter, Array   , Array com as APIs que devem ser processadas
@param cTicket  , caracter, Número do ticket de processamento do MRP
/*/
Static Function procExt(aApiAlter, cTicket)

	Local nIndex := 0
	Local nPos   := 0

	//Lock pela tabela HW3
	PCPLockSinc("LOCK", cTicket)
	PutGlbValue("PCPA140_TICKET", cTicket)

	For nIndex := 1 To Len(aApiAlter)
		nPos := aScan(aParTela, {|x| Alltrim(x[IND_PAR_API]) == Alltrim(aApiAlter[nIndex]) })

		If nPos > 0
			aParTela[nPos][IND_PAR_CHECKED] := .T.
		EndIf
	Next nX

	processar(cTicket)

	PCPLockSinc("UNLOCK", cTicket)
	ClearGlbValue("PCPA140_TICKET")

Return

/*/{Protheus.doc} SincArmaz
Sincroniza os armazens
@author  douglas.heydt
@version P12
@since   07/08/2020
@param   cJobName, Character, Nome do JOB de processamento
@return  NIL
/*/
Static Function SincArmaz(cJobName)
	Local aDadosInc  := {}
	Local aError     := {}
	Local aSuccess   := {}
	Local cAliasQry  := PCPAliasQr()
	Local cQryCondic := ""
	Local nAtual     := 0
	Local nError     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nSuccess 	 := 0
	Local nTotal     := 0

	//Limpa a tabela de pendências
	limpaT4R(aParTela[IND_TELA_ARMAZEM][IND_PAR_API])

	//Chama a API para apagar os dados das filiais que estão sendo sincronizadas
	nTotal := Len(aEmprCent)
	For nPos := 1 To nTotal
		//Alimenta o array aDadosInc com uma posição contendo somente a filial para que os registros existentes no MRP sejam excluídos.
		aAdd(aDadosInc, Array(WHAPICnt("ARRAY_WH_SIZE")))
		aDadosInc[nPos][WHAPICnt("ARRAY_WH_POS_FILIAL")] := xFilial("NNR", aEmprCent[nPos][2])
	Next nPos

	//Chama a função do MRPWarehouseAPI para integrar os registros
	PcpWHInt("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .T. /*OnlyDel*/, .F. /*Mantêm Registros*/)

	//Carregar as variaveis de registros com sucesso e erros
	nSuccess += Len(aSuccess)
	nError   += Len(aError)

	//Reseta as variaveis
	aSize(aDadosInc, 0)
	aSize(aSuccess , 0)
	aSize(aError   , 0)

	//Consulta os registros
	nTotal := Len(aParTela[IND_TELA_ARMAZEM][IND_PAR_QUERY])
	For nIndex := 1 To nTotal
		cQryCondic := aParTela[IND_TELA_ARMAZEM][IND_PAR_QUERY][nIndex]
		BeginSql Alias cAliasQry
			SELECT NNR_FILIAL,
				NNR_CODIGO,
				NNR_TIPO,
				NNR_MRP,
				R_E_C_N_O_
			FROM %Exp:cQryCondic%
		EndSql

		nPos   := 0
		//Carrega o array aDadosInc com os registros a serem integrados
		While (cAliasQry)->(!Eof())
			//Atualiza as barras de progresso
			nAtual++
			PutGlbValue(cJobName+"TOTAL", cValToChar(nAtual))
			GlbUnLock()

			//Adiciona nova linha no array de inclusão/atualização
			aAdd(aDadosInc, Array(WHAPICnt("ARRAY_WH_SIZE")))
			nPos++

			//Adiciona as informações no array de inclusão/atualização
			aDadosInc[nPos][WHAPICnt("ARRAY_WH_POS_FILIAL")] := (cAliasQry)->NNR_FILIAL
			aDadosInc[nPos][WHAPICnt("ARRAY_WH_POS_COD"   )] := (cAliasQry)->NNR_CODIGO
			aDadosInc[nPos][WHAPICnt("ARRAY_WH_POS_TIPO"  )] := (cAliasQry)->NNR_TIPO
			aDadosInc[nPos][WHAPICnt("ARRAY_WH_POS_MRP"   )] := (cAliasQry)->NNR_MRP

			(cAliasQry)->(dbSkip())
			If nPos > VOL_BUFFER .Or. (cAliasQry)->(Eof())
				//Chama a função do MRPWarehouseAPI para integrar os registros
				PcpWHInt("SYNC", aDadosInc, @aSuccess, @aError, /*cUUID*/, .F. /*OnlyDel*/, .T. /*Mantêm Registros*/)

				//Carregar as variaveis de registros com sucesso e erros
				nSuccess += Len(aSuccess)
				nError   += Len(aError)

				//Reseta as variaveis
				aSize(aDadosInc, 0)
				aSize(aSuccess , 0)
				aSize(aError   , 0)

				nPos := 0
			EndIf
		End
		(cAliasQry)->(dbCloseArea())
	Next nIndex

	//Variável para identificar que terminou a carga e irá começar o processo de integração.
	PutGlbValue(cJobName+"CARGA", "1")
	GlbUnLock()

	//Guarda os registros integrados com sucesso e não integrados
	PutGlbValue(cJobName+"SUCESSO", cValToChar(nSuccess))
	PutGlbValue(cJobName+"ERRO"   , cValToChar(nError))

Return

/*/{Protheus.doc} EhFilCentr
Identifica se a filial foi cadastrada como centralizada no PCPA106
@type  Static Function
@author Parffit Jim Balsanelli
@since 03/09/2020
@version 1.0
@param 01 cEmp, char, Empresa (opcional, cEmpAnt qdo não informado)
@param 02 cFil, char, Filial (opcional, cFilAnt qdo não informado)
@return lRet, logical, Indica se filial é centralizada
/*/
Static Function EhFilCentr(cEmp,cFil)
	Local lRet      := .F.
	Local cQuery    := ""
	Local cAliasQry := "FILCENTR"
	Local aInfoFil  := {}
	Local cGrpEmp   := ""
	Local cCodEmp   := ""
	Local cCodUNeg  := ""
	Local cCodFil   := ""

	Default cEmp := cEmpAnt
	Default cFil := cFilAnt

	aInfoFil := FWArrFilAtu(cEmp, cFil)

	If Len(aInfoFil) > 0
		cGrpEmp  := aInfoFil[SM0_GRPEMP]
		cCodEmp  := aInfoFil[SM0_EMPRESA]
		cCodUNeg := aInfoFil[SM0_UNIDNEG]
		cCodFil  := aInfoFil[SM0_FILIAL]

		cQuery := " SELECT SOP.OP_CDEPCZ "
		cQuery +=   " FROM " + RetSqlName("SOP") + " SOP"
		cQuery +=  " WHERE SOP.OP_FILIAL = '" + xFilial("SOP") + "' "
		cQuery +=    " AND SOP.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SOP.OP_CDEPGR = '" + cGrpEmp + "' "
		cQuery +=    " AND SOP.OP_EMPRGR = '" + cCodEmp + "' "
		cQuery +=    " AND SOP.OP_UNIDGR = '" + cCodUNeg + "' "
		cQuery +=    " AND SOP.OP_CDESGR = '" + cCodFil + "'"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

		If (cAliasQry)->(!Eof())
			lRet := .T.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet

/*/{Protheus.doc} CargEmprC
Carrega empresas centralizadas cadastradas no PCPA106
@type  Static Function
@author Parffit Jim Balsanelli
@since 03/09/2020
@version 1.0
@param 01 cEmp, char, Empresa centralizadora (opcional, cEmpAnt qdo não informado)
@param 02 cFil, char, Filial centralizadora (opcional, cFilAnt qdo não informado)
@return aEmpresasC, array, Empresas centralizadas
						aEmpresasC[1][1] = Código da empresa centralizada
						aEmpresasC[1][2] = Filial da empresa centralizada
/*/
Static Function CargEmprC(cEmp,cFil)
	Local cQuery     := ""
	Local cAliasQry  := "CARGEMPRC"
	Local aInfoFil   := {}
	Local cGrpEmp    := ""
	Local cCodEmp    := ""
	Local cCodUNeg   := ""
	Local cCodFil    := ""
	Local aEmpresasC := {}
	Local nTamOOGE   := GetSx3Cache("OP_CDEPCZ", "X3_TAMANHO")
	Local nTamOOEmp  := GetSx3Cache("OP_EMPRCZ", "X3_TAMANHO")
	Local nTamOOUnid := GetSx3Cache("OP_UNIDCZ", "X3_TAMANHO")
	Local nTamOOFil  := GetSx3Cache("OP_CDESCZ", "X3_TAMANHO")
	Local nTamEmp    := Len(FWSM0Layout(cEmpAnt,1))
	Local nTamUNeg   := Len(FWSM0Layout(cEmpAnt,2))
	Local nTamFil    := Len(FWSM0Layout(cEmpAnt,3))
	Local nTamSM0    := FWSizeFilial(cEmpAnt)
	Default cEmp := cEmpAnt
	Default cFil := cFilAnt

	aInfoFil := FWArrFilAtu(cEmp, cFil)

	If Len(aInfoFil) > 0
		aAdd(aEmpresasC, {cEmp,cFil})

		cGrpEmp  := PadR(aInfoFil[SM0_GRPEMP] , nTamOOGE)
		cCodEmp  := PadR(aInfoFil[SM0_EMPRESA], nTamOOEmp)
		cCodUNeg := PadR(aInfoFil[SM0_UNIDNEG], nTamOOUnid)
		cCodFil  := PadR(aInfoFil[SM0_FILIAL] , nTamOOFil)

		cQuery := " SELECT SOP.OP_CDEPGR, SOP.OP_EMPRGR, SOP.OP_UNIDGR, SOP.OP_CDESGR "
		cQuery +=   " FROM " + RetSqlName("SOP") + " SOP"
		cQuery +=  " WHERE SOP.OP_FILIAL = '" + xFilial("SOP") + "' "
		cQuery +=    " AND SOP.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SOP.OP_CDEPCZ = '" + cGrpEmp + "' "
		cQuery +=    " AND SOP.OP_EMPRCZ = '" + cCodEmp + "' "
		cQuery +=    " AND SOP.OP_UNIDCZ = '" + cCodUNeg + "' "
		cQuery +=    " AND SOP.OP_CDESCZ = '" + cCodFil + "'"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

		While (cAliasQry)->(!Eof())
			cFil := PadR(PadR((cAliasQry)->(OP_EMPRGR),nTamEmp) + PadR((cAliasQry)->(OP_UNIDGR),nTamUNeg) + PadR((cAliasQry)->(OP_CDESGR),nTamFil),nTamSM0)
			aAdd(aEmpresasC,{AllTrim((cAliasQry)->(OP_CDEPGR)),cFil})
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf
Return aEmpresasC

/*/{Protheus.doc} getQrySb1
Monta query de produtos ( SB1 ), chamada nos métodos calculaReg e SincProd
@author  Douglas Heydt
@version P12
@since   16/03/2021
@param   01 aEmprCent, array   , contém as empresas centralizadas
@param   02 lContReg , lógico  , indica se a função está sendo chamada da contagem de registros (.T.) ou da sincronização (.F.)
@return  cQuery      , caracter, query de seleção de registros para contagem e/ou integração
/*/
Static Function getQrySb1(aEmprCent, lContReg)

	Local cQuery     := ""
	Local cQueryCond := ""
	Local nCont      := 0
	Local oJEmpFils  := JsonObject():New()
	Local lPossuiHZ8 := AliasInDic("HZ8")
	Local lLMTran    := GetSx3Cache("HZ8_LMTRAN", "X3_TAMANHO") > 0


	oJEmpFils["SB1"] := "'"+xFilial("SB1", aEmprCent[1][2])+"'"
	oJEmpFils["SB5"] := "'"+xFilial("SB5", aEmprCent[1][2])+"'"
	oJEmpFils["SVK"] := "'"+xFilial("SVK", aEmprCent[1][2])+"'"
	oJEmpFils["SAJ"] := "'"+xFilial("SAJ", aEmprCent[1][2])+"'"
	For nCont := 2 To Len(aEmprCent)
			oJEmpFils["SB1"] += ",'"+xFilial("SB1", aEmprCent[nCont][2])+"'"
			oJEmpFils["SB5"] += ",'"+xFilial("SB5", aEmprCent[nCont][2])+"'"
			oJEmpFils["SVK"] += ",'"+xFilial("SVK", aEmprCent[nCont][2])+"'"
			oJEmpFils["SAJ"] += ",'"+xFilial("SAJ", aEmprCent[nCont][2])+"'"
	Next nCont

	IF lContReg
		cQueryCond := " SELECT SB1.B1_COD FROM " + RetSqlName("SB1") + " SB1 "
	Else
		cQueryCond :=  " SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_LOCPAD, SB1.B1_TIPO, SB1.B1_GRUPO, ";
						+ " SB1.B1_QE, SB1.B1_EMIN, SB1.B1_ESTSEG, SB1.B1_PE, SB1.B1_TIPE, SB1.B1_LE, ";
						+ " SB1.B1_LM, SB1.B1_TOLER, SB1.B1_TIPODEC, SB1.B1_RASTRO, SB1.B1_MRP, ";
						+ " SB1.B1_REVATU, SB1.B1_EMAX, SB1.B1_PRODSBP, SB1.B1_LOTESBP, SB1.B1_ESTRORI, ";
						+ " SB1.B1_APROPRI, SB1.B1_CPOTENC, SB1.B1_MSBLQL, SB1.B1_CONTRAT, SB1.B1_OPERPAD, ";
						+ " SB1.B1_CCCUSTO, SB1.B1_DESC, SB1.B1_GRUPCOM, SB1.B1_UM, SVK.VK_HORFIX, SVK.VK_TPHOFIX, ";
						+ " SB1.B1_OPC, SB1.B1_QB, SB1.R_E_C_N_O_, "

		cQueryCond += " CASE WHEN SB1.B1_MOPC IS NULL THEN ' ' ELSE '1' END TEMOPC, "
		cQueryCond += " CASE WHEN SB5.B5_AGLUMRP IN ('1', '6') THEN NULL ELSE SB5.B5_AGLUMRP END B5_AGLUMRP "
		cQueryCond += ", B5_FILIAL, B5_LEADTR, B5_COD "
		cQueryCond += ", AJ_DESC "
		If lPossuiHZ8
			cQueryCond += ", HZ8.HZ8_FILIAL, HZ8.HZ8_LEADTR, HZ8.HZ8_TRANSF, HZ8.HZ8_FILCOM "

			If lLMTran
				cQueryCond += ", HZ8.HZ8_LMTRAN "
			Else
				cQueryCond += ", NULL HZ8_LMTRAN "
			EndIf
		Else
			cQueryCond += ", NULL HZ8_FILIAL, NULL HZ8_LEADTR, NULL HZ8_TRANSF, NULL HZ8_FILCOM, NULL HZ8_LMTRAN "
		EndIf
		cQueryCond += " FROM " + RetSqlName("SB1") + " SB1 "
		cQueryCond += " LEFT OUTER JOIN " + RetSqlName("SVK") + " SVK"     +;
		                " ON  SB1.B1_FILIAL IN (" + oJEmpFils["SB1"] + ")" +;
		               " AND SVK.VK_FILIAL IN (" + oJEmpFils["SVK"] + ")"  +;
		               " AND (SB1.B1_FILIAL = ' ' OR " + FwJoinFilial('SB1', 'SVK', 'SB1', 'SVK', .T.) + ")" +;
		               " AND SVK.VK_COD     = SB1.B1_COD" +;
		               " AND SVK.D_E_L_E_T_ = ' '"
		cQueryCond += " LEFT OUTER JOIN " + RetSqlName("SB5") + " SB5"     +;
		                " ON  SB5.B5_FILIAL IN (" + oJEmpFils["SB5"] + ")" +;
		               " AND (SB1.B1_FILIAL = ' ' OR " + FwJoinFilial('SB1', 'SB5', 'SB1', 'SB5', .T.) + ")" +;
		               " AND SB5.B5_COD     = SB1.B1_COD" +;
		               " AND SB5.D_E_L_E_T_ = ' '"
		If lPossuiHZ8
			cQueryCond += " LEFT JOIN " + RetSqlName("HZ8") + " HZ8 " +;
			                " ON HZ8.HZ8_FILIAL = SB5.B5_FILIAL "     +;
			               " AND HZ8.HZ8_PROD   = SB5.B5_COD "        +;
			               " AND HZ8.D_E_L_E_T_ = ' ' "
		EndIf
		cQueryCond += " LEFT OUTER JOIN " + RetSqlName("SAJ") + " SAJ" +;
		                " ON SAJ.R_E_C_N_O_ = (SELECT MAX(SAJLST.R_E_C_N_O_)" +;
		                                       " FROM " + RetSqlName("SAJ") + " SAJLST" +;
		                                      " WHERE SAJLST.AJ_FILIAL IN (" + oJEmpFils["SAJ"] + ")" +;
		                                        " AND (SB1.B1_FILIAL = ' ' OR " + FwJoinFilial('SB1', 'SAJ', 'SB1', 'SAJLST', .T.) + ")" +;
		                                        " AND SAJLST.AJ_GRCOM   = SB1.B1_GRUPCOM" +;
		                                        " AND SAJLST.D_E_L_E_T_ = ' ')"
	EndIf

	cQueryCond += " WHERE SB1.D_E_L_E_T_ = ' ' ";
				 + " AND SB1.B1_FILIAL IN (" + oJEmpFils["SB1"] + ") ";
				 + " AND SB1.B1_MSBLQL  <> '1'"

	cQuery := " ( " + cQueryCond + " ) SB1a "

Return cQuery

/*/{Protheus.doc} getFilsSMQ
Retorna as filiais cadastradas na tabela SMQ para o processamento.
@type  Static Function
@author Lucas Fagundes
@since 07/12/2022
@version P12
@return aFiliais, Array, Arra com as filiais que estão cadastradas na tabela SMQ.
/*/
Static Function getFilsSMQ()
	Local aFiliais := {}

	SMQ->(dbGoTop())
	While SMQ->(!Eof())
		aAdd(aFiliais, {cEmpAnt, SMQ->MQ_CODFIL})
		SMQ->(dbSKip())
	End

Return aFiliais

/*/{Protheus.doc} setFilAnt
Seta a variavel cFilAnt com a filial da SMQ que se encaixar nas regras de compartilhamento da tabela.
Regras para setar o cFilAnt de acordo com o compartilhamento:
Se for EEE, muda o cFilAnt para ser igual a filial do registro que está sincronizando.
Se for EEC, muda o cFilAnt para a primeira filial da SMQ que pertença a empresa+unidade de negócio do registro que está sendo sincronizado.
Se for ECC, muda o cFilAnt para a primeira filial da SMQ que pertença a empresa do registro que está sendo sincronizado.
Se for CCC, deixa o cFilAnt sempre com a primeira filial da SMQ.

@type  Static Function
@author Lucas Fagundes
@since 12/05/2023
@version P12
@param 01 cFilAux, Caracter, Filial do registro que está sendo sincronizado no momento.
@param 02 cTabela, Caracter, Tabela que irá verificar o compartilhamento.
@return lTrocou, Logico, Indica que trocou a filial de cFilAnt.
/*/
Static Function setFilAnt(cFilAux, cTabela)
	Local cBuscaAux := ""
	Local cFilSet   := ""
	Local lTrocou   := .F.

	If existeSMQ()
		If Empty(_cCompTab)
			_cCompTab := FWModeAccess(cTabela, 1)	+ FWModeAccess(cTabela, 2) + FWModeAccess(cTabela, 3)
		EndIf

		If _cCompTab == "EEE"
			cFilSet := cFilAux

		ElseIf _cCompTab == "EEC"
			If Empty(_nTamFil)
				_nTamFil := Len(FWSM0Layout(cEmpAnt, 1)) + Len(FWSM0Layout(cEmpAnt, 2))
			EndIf
			cBuscaAux := SubStr(cFilAux, 0, _nTamFil)

		ElseIf _cCompTab == "ECC"
			If Empty(_nTamFil)
				_nTamFil := Len(FWSM0Layout(cEmpAnt, 1))
			EndIf
			cBuscaAux := SubStr(cFilAux, 0, _nTamFil)

		ElseIf _cCompTab == "CCC"
			cBuscaAux := ""

		EndIf

		If _cCompTab != "EEE"
			cFilSet := getFilParc(cBuscaAux)
		EndIf

		If !Empty(cFilSet) .And. cFilSet != cFilAnt
			cFilAnt := cFilSet
			lTrocou := .T.
		EndIf
	EndIf

Return lTrocou

/*/{Protheus.doc} getFilParc
Busca entre as filiais cadastradas na SMQ uma filial com a empresa ou empresa+unidade de negocio recebido.
@type  Static Function
@author Lucas Fagundes
@since 12/05/2023
@version P12
@param cBusca, Caracter, Empresa que irá buscar na filial.
@return cFilSMQ, Caracter, Filial cadastrada na tabela SMQ correpondente a busca.
/*/
Static Function getFilParc(cBusca)
	Local cFilSMQ := ""
	Local nIndex  := 0
	Local nTotal  := 0

	If Empty(_aFilsSMQ)
		_aFilsSMQ := getFilsSMQ()
	EndIf

	nTotal := Len(_aFilsSMQ)
	For nIndex := 1 To nTotal
		If "|" + cBusca $ "|" + _aFilsSMQ[nIndex][2]
			cFilSMQ := _aFilsSMQ[nIndex][2]
			Exit
		EndIf
	Next

Return cFilSMQ

/*/{Protheus.doc} existeSMQ
Verifica se a tabela SMQ está presente no dicionario de dados.
@type  Static Function
@author Lucas Fagundes
@since 22/05/2023
@version P12
@return _lTemSMQ, Logico, Indica se a tabela SMQ está presente no dicionario de dados.
/*/
Static Function existeSMQ()

	If _lTemSMQ == Nil
		_lTemSMQ := FWAliasInDic("SMQ",.F.)
	EndIf

Return _lTemSMQ
