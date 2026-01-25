#include 'totvs.ch'
#include 'protheus.ch'

#DEFINE ARQ_LOG_CARGA "carga_diops_central.log"
#DEFINE CHECKED    1
#DEFINE COD_QUADRO 2
#DEFINE DESCQUADRO 3
#DEFINE FUNCIMPQDR 4

#DEFINE AGUARDANDO '0'
#DEFINE SUCESSO	   '1'
#DEFINE FALHA      '2'

#DEFINE QDR_BALANC	"1"	 // Balancete Trimestral
#DEFINE QDR_CADAST	"2"	 // Dados Cadatrai
#DEFINE QDR_AGIMOB	"3"	 // Ativos Garantidores - Imobiliario
#DEFINE QDR_FLUXCA	"4"	 // Fluxo de Caixa Trimestral
#DEFINE QDR_IDASPA	"5"	 // Idade de Saldos - Contas a Pagar - Passivo
#DEFINE QDR_LUCPRE	"6"	 // Lucros e Prejuízos
#DEFINE QDR_CONEST	"7"	 // Contratos Estipulados"
#DEFINE QDR_CONREP	"8"	 // Segregação do Montante de Contraprestações a Repassar
#DEFINE QDR_COBASS	"9"	 // Cobertura Assistencial
#DEFINE QDR_EVEIND	"11" // Movimentação de Eventos Indenizáveis
#DEFINE QDR_AGRCON	"12" // Agrupamento de Contratos
#DEFINE QDR_PESL	"13" // Saldo da Provisão de Eventos Sinistros a Liquidar
#DEFINE QDR_CCCOOP	"14" // Conta-Corrente Cooperado
#DEFINE QDR_CTRPAS	"15" // Conta Tributo Passivo
#DEFINE QDR_IDASRE	"16" // Idade de Saldos - Contas a Receber - Ativo
#DEFINE QDR_EVECOR	"18" // Eventos em Corresponsabilidade (2018)
#DEFINE QDR_FUNCOM	"19" // Programas-Fundos Comuns de Despesas Assistenciais (2018)
#DEFINE QDR_EVCCC	"20" // Eventos de Contraprestação de Corresponsabilidade Cedid
#DEFINE QDR_MPC		"21" // Modelo Padrão de Capital
#DEFINE QDR_TAP		"22" // Teste de Adequação do Passivo - TAP
#DEFINE QDR_CONPEC	"23" // Contraprestações Pecuniárias.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSDIOPSPL

Rotina criada para disparar as integrações do SIGAPLS com os Quadros da DIOPS da Central de Obrigações

@author Henrique Brugugnoli
@since 15/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSDIOPSPL(lAuto, cTrimestre, cAno, cQuadro)

	Local oBrw	   := ""
	Local aQuadros := RetornaQuadros()
	Local cTitulo  := "Parâmetros Geração DIOPS"
	Local oDlg
	Local i 	   := 0

	Default lAuto  := .F.
	Default cTrimestre := ''
	Default cAno := ''

	If !lAuto

		If ( Pergunte('PLSCEDIOPS',.T.,cTitulo) )

			oOk 	:= LoadBitmap(GetResources(), "LBOK")
			oCancel := LoadBitmap(GetResources(), "LBNO")

			DEFINE MSDIALOG oDlg FROM 0,0 TO 340,640 PIXEL TITLE "Selecionar Quadros DIOPS"

			oBrw := TCBrowse():New( 01,01,320,147 ,,{"","Descrição"},{2,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
			oBrw:SetArray(aQuadros)
			oBrw:bLine := {|| {iIf(aQuadros[oBrw:nAt,CHECKED],oOk,oCancel),aQuadros[oBrw:nAt,DESCQUADRO]}}
			oBrw:bLDblClick := {|| aQuadros[oBrw:nAt,CHECKED] := !aQuadros[oBrw:nAt,CHECKED] }

			TButton():New(151,10,  "Marcar/Desmarcar todos" ,,{|| SelecTodos(@aQuadros) } , 080, 010 ,,,,.T.)
			TButton():New(151,200, "Sair"                   ,,{|| oDlg:End()            } , 040, 010 ,,,,.T.)
			TButton():New(151,250, "Aplicar selação"        ,,{|| impDIOPS( @aQuadros ) } , 060, 010 ,,,,.T.)

			ACTIVATE MSDIALOG oDlg CENTERED

		EndIf

	Else

		For i := 1 to Len(aQuadros)
			If aQuadros[i,2] == cQuadro
				aQuadros[i,1] := .T.
				Exit
			EndIf
		Next

		impDIOPS( @aQuadros, cTrimestre, cAno, lAuto )

	EndIf

Return


Static Function SelecTodos(aQuadros)

	Local i := 0

	For i:= 1 to Len(aQuadros)
		if aQuadros[i,1] == .T.
			aQuadros[i,1] := .F.
		Else
			aQuadros[i,1] := .T.
		EndIf
	Next

Return aQuadros

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaQuadros

Rotina criada para retornar a lista de quadros para o browse

@author lima.everton
@since 15/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaQuadros()

	Local aQuadros	  := {}
	Local aAuxQua	  := getQdrsDiops()
	Local nQuadro	  := 0
	Local nCodQuadro  := 1
	Local nDesQuadro  := 2
	Local nFuncQuadro := 3

	For nQuadro := 1 TO Len(aAuxQua)
		If !Empty(aAuxQua[nQuadro,nFuncQuadro])
			aAdd(aQuadros,{.F.,aAuxQua[nQuadro,nCodQuadro],aAuxQua[nQuadro,nDesQuadro],aAuxQua[nQuadro,nFuncQuadro]})
		EndIf
	Next nQuadro

Return aQuadros

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getQdrsDiops

Função extraida da central para eliminar a dependência
Retorna array com os quadros do DIOPS

@author lima.everton
@since 13/06/2019
/*/
//--------------------------------------------------------------------------------------------------
function getQdrsDiops()

	local aQuadros := {}
	// NÃO ALTERAR A ORDEM DOS QUADROS, É MANTIDO PARA EXIBIR NA TELA DE SELEÇÃO E ORDEM DE CHAMADA DOS RELATÓRIOS

	aAdd( aQuadros, { QDR_CADAST, "Dados Cadastrais",                                  "" })
	aAdd( aQuadros, { QDR_BALANC, "Balancete Trimestral",                              "PLSMIGBAL" })
	aAdd( aQuadros, { QDR_AGIMOB, "Ativos Garantidores - Imobiliario",                 "PLSMIGAGI" })
	aAdd( aQuadros, { QDR_FLUXCA, "Fluxo de Caixa Trimestral",                         "PLSMIGFLX" })
	aAdd( aQuadros, { QDR_LUCPRE, "Lucros e Prejuízos",                                "PLSMIGLCR" })
	aAdd( aQuadros, { QDR_IDASPA, "Idade de Saldos - A Pagar",                         "PLSMIGISP" })
	aAdd( aQuadros, { QDR_IDASRE, "Idade de Saldos - A Receber",                       "PLSMIGISA" })
	aAdd( aQuadros, { QDR_COBASS, "Cobertura Assistencial",                            "PLSMIGCOA" })
	aAdd( aQuadros, { QDR_AGRCON, "Agrupamento de Contratos",                          "PLSMIGAGC" })
	aAdd( aQuadros, { QDR_EVEIND, "Movimentação de Eventos Indenizáveis",              "PLSMIGEVI" })
	aAdd( aQuadros, { QDR_PESL,   "Saldo da Provisão de Eventos Sinistros a Liquidar", "PLSMIGPES" })
	aAdd( aQuadros, { QDR_CCCOOP, "Conta-Corrente Cooperado",                          ''/*"PLSMIGCCC"*/ })
	If FindFunction('PLSMIGCTP')
		aAdd( aQuadros, { QDR_CTRPAS, "Conta Tributo Passivo",                             "PLSMIGCTP" })
	Endif
	aAdd( aQuadros, { QDR_CONEST, "Contratos Estipulados",                             ''/*"PLSMIGCOE"*/ })
	aAdd( aQuadros, { QDR_CONREP, "Segregação do Montante de Contraprestações a Repassar", ''/*"PLSMIGMCR"*/ })
	aAdd( aQuadros, { QDR_FUNCOM, "Programas-Fundos Comuns de Despesas Assistenciais (2018)", ''/*"PLSMIGFUC"*/  })
	aAdd( aQuadros, { QDR_EVCCC,  "Eventos de Contraprestação de Corresponsabilidade Cedida", ''/*"PLSMIGMCR"*/ })
	aAdd( aQuadros, { QDR_MPC,	  "Modelo Padrão de Capital", '' })
	aAdd( aQuadros, { QDR_TAP,	  "Teste de Adequação do Passivo - TAP", '' })
	If FindFunction('PLSMIGPEC')
		aAdd( aQuadros, { QDR_CONPEC, "Contraprestações Pecuniárias", 'PLSMIGPEC' })
	EndIf

Return aQuadros

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} impDIOPS

Função extraida da central para eliminar a dependencia
Função criada para executar as funções quadro a quadro que importa a DIOPS para Central

@author Henrique Brugugnoli
@since 15/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function impDIOPS( aQuadros, cTrimestre, cAno, lAuto)

	Local oBrwProc
	Local oDlg2
	Local nQuadro  := 0
	Local nPos     := 0
	Local aQdrProc := {}

	Default lAuto := .F.

	If !lAuto
		If ( Empty( MV_PAR01 ) )
			msgInfo("Por favor, informar o trimestre de referência para processamento.")
		Else

			If ( Empty( MV_PAR02 ) )
				msgInfo("Por favor, informar o ano de referência para processamento.")
			Else

				nPos := ascan( aQuadros, {|x| x[1] } )

				If ( nPos <= 0 )
					msgInfo( "Selecione algum quadro para processar a geração do DIOPS." )
				Else

					For nQuadro := 1 to len(aQuadros)
						If ( aQuadros[nQuadro,CHECKED] .And. !Empty(aQuadros[nQuadro,FUNCIMPQDR]))
							aAdd(aQdrProc,{AGUARDANDO,aQuadros[nQuadro,DESCQUADRO],aQuadros[nQuadro,FUNCIMPQDR],"Clique em confirmar para iniciar importação.",aQuadros[nQuadro,COD_QUADRO]})
						EndIf
					Next nQuadro

					oSim  	:= LoadBitmap(GetResources(), "BR_VERDE")
					oNao  	:= LoadBitmap(GetResources(), "BR_VERMELHO")
					oTalvez	:= LoadBitmap(GetResources(), "BR_AMARELO")

					DEFINE MSDIALOG oDlg2 FROM 0,0 TO 340,640 PIXEL TITLE "Geração DIOPS"

					oBrwProc := TCBrowse():New( 01,01,320,147 ,,{"","Quadro","Observação"},{2,70,70},oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
					oBrwProc:SetArray(aQdrProc)
					oBrwProc:bLine := {|| {IIf(aQdrProc[oBrwProc:nAt,1]==AGUARDANDO,oTalvez, IIf(aQdrProc[oBrwProc:nAt,1]==SUCESSO,oSim,oNao)), aQdrProc[oBrwProc:nAt,COD_QUADRO], aQdrProc[oBrwProc:nAt,FUNCIMPQDR]}}

					TButton():New(151,220, "Sair"      ,,{|| oDlg2:End() } , 040, 010 ,,,,.T.)
					TButton():New(151,270, "Confirmar" ,,{|| plsProcDiops( @aQdrProc, MV_PAR01, MV_PAR02, oBrwProc ),	oDlg2:Refresh() } , 040, 010 ,,,,.T.)

					ACTIVATE MSDIALOG oDlg2 CENTERED

				EndIf

			EndIf

		EndIf

	Else

		For nQuadro := 1 to len(aQuadros)
			If ( aQuadros[nQuadro,CHECKED] .And. !Empty(aQuadros[nQuadro,FUNCIMPQDR]))
				aAdd(aQdrProc,{AGUARDANDO,aQuadros[nQuadro,DESCQUADRO],aQuadros[nQuadro,FUNCIMPQDR],"Aguardando processamento...",aQuadros[nQuadro,COD_QUADRO]})
				Exit
			EndIf
		Next nQuadro

		plsProcDiops( @aQdrProc, cTrimestre, cAno,, lAuto)

	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} plsProcDiops

Função extraida da central para eliminar a dependencia
Função criada para executar a importação de todos os quadros marcados no browse

@author Henrique Brugugnoli
@since 15/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function plsProcDiops( aQdrProc, cTrimestre, cAno, oBrwProc, lAuto)

	Local nQuadro      := 0
	Local nStatus      := 1
	Local nDesQuadro   := 2
	Local nFuncQuadro  := 3
	Local nDesProcto   := 4
	Local nCodQuadro   := 5
	Local cMsg         := ''
	Local aRotProc     := {}
	Local aDtImpVal    := nil

	Private aErroDIOPS := {}
	Default lAuto      := .F.

	For nQuadro := 1 to len(aQdrProc)

		If aQdrProc[nQuadro][nStatus] == SUCESSO
			aAdd( aRotProc, aQdrProc[nQuadro][nDesQuadro] )
			Loop
		EndIf

		If !lAuto
			MsgRun("Processando: "+aQdrProc[nQuadro][nDesQuadro],"DIOPS",{||controlProc(aQdrProc[nQuadro][nFuncQuadro],cTrimestre,cAno,lAuto,@aDtImpVal)})
		Else
			controlProc(aQdrProc[nQuadro][nFuncQuadro], cTrimestre, cAno, lAuto, @aDtImpVal)
		EndIf

		If (nPos := aScan(aErroDIOPS, aQdrProc[nQuadro][nFuncQuadro])) > 0
			aQdrProc[nQuadro][nStatus]    := FALHA
			aQdrProc[nQuadro][nDesProcto] := aDtImpVal[3] //'Erros encontrados na execução da rotina.'
		Else
			aQdrProc[nQuadro][nStatus]    := SUCESSO
			aQdrProc[nQuadro][nDesProcto] := 'Rotina executada com sucesso. Registros processados: ' + AllTrim(Str(aDtImpVal[2]))
		EndIf

		If !lAuto
			oBrwProc:Refresh()
		EndIf

		// Se processou o quadro Balancete ('1') e não passou
		If aQdrProc[nQuadro][nCodQuadro] == '1' .and. aQdrProc[nQuadro][nStatus] == FALHA
			If !lAuto
				MsgAlert( "Balancete não foi processado corretamente, a importação dos demais quadros será abortada.", "DIOPS" )
			EndIf
			Exit
		EndIf

	Next nQuadro

	// Se rotinas já foram processadas e continuam solicitando execução, avisa na tela.
	If Len(aRotProc) > 0
		cMsg := "Rotina(s) : "  + CHR(13)
		For nQuadro := 1 to Len(aRotProc)
			cMsg += aQdrProc[nQuadro][nDesQuadro] + CHR(13)
		Next
		cMsg += " já processada(s). "
		If !lAuto
			MsgAlert( cMsg, "DIOPS" )
		EndIf
	EndIf

	If !lAuto
		oBrwProc:Refresh()
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} controlProc

Função extraida da central para eliminar a dependência
Função faz o controle de execução por semaforo para os quadros em execução

@author Henrique Brugugnoli
@since 15/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function controlProc( cProc, cTrimestre, cAno, lAuto, aDtImpVal)

	Local lLocked := .F.
	Local cLock   := cProc + ".lck"

	Default lAuto := .F.
	Default aDtImpVal := {}

	lLocked  := CenSmfCtrl( cLock, .F. )
	cProc    := allTrim(cProc)+"('"+cTrimestre+"','"+cAno+"','"+IIf(lAuto, ".T.", ".F.")+"')"
	aDtImpVal := &(cProc)[1]

	CenSmfCtrl( cLock, .T. )

Return aDtImpVal

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenSmfCtrl

Função extraida da central para eliminar a dependencia
Faz controle de execucao do semaForo

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
Function CenSmfCtrl( cNome, lLibera)

	Local lLocked	:= .F.
	Default cNome		:= ""
	Default lLibera		:= .F.

	If lLibera
		UnlockByName(cNome, .T., .T.)
	Else
		lLocked:= LockByName(cNome, .T., .T.)
	EndIf

return lLocked

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} quadroFimEnvDiops

Função extraida da central para eliminar a dependencia
Atualiza quadro do compromisso do DIOPS para marcar que foi enviado e para processar a validação

@author lima.everton
@since 06/06/2019
/*/
//--------------------------------------------------------------------------------------------------
function qdrPlsFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )

	Local cComp		:= ""
	Local cCodObr	:= ""
	Local lReturn := .F.

	cCodObr := PLSEXISOB( cCodOpe )
	cComp := PLSEXISCO( cCodOpe, cCodObr , cRefere, cAno )

	B8X->(dbSetOrder(1))
	//"B8X_FILIAL+B8X_CODOPE+B8X_CODOBR+B8X_ANOCMP+B8X_CDCOMP+B8X_QUADRO
	If ( B8X->(MsSeek( xFilial( "B8X" )+cCodOpe+cCodObr+cAno+cComp+cQuadro )) )

		If ( cQuadro == QDR_BALANC )

			recLock( "B8X", .F. )
			B8X->B8X_RECEBI := "1"
			B8X->B8X_VALIDA := "1"
			B8X->(msUnLock())

			lReturn := .T.

			While !B8X->(EoF()) .and. ( B8X->B8X_FILIAL+B8X->B8X_CODOPE+B8X->B8X_ANOCMP+B8X->B8X_CDCOMP == xFilial( "B8X" )+cCodOpe+cAno+cComp )

				if ( B8X->B8X_RECEBI == "1" )
					recLock( "B8X", .F. )
					B8X->B8X_VALIDA := "1"
					B8X->(msUnLock())
				endif
				B8X->(dbSkip())
			End
		Else

			RecLock( "B8X", .F. )
			B8X->B8X_RECEBI := "1"
			B8X->B8X_VALIDA := "1"
			B8X->(msUnLock())
			lReturn := .T.

		EndIf

	Else
		lReturn := .T.
	EndIf

Return lReturn

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} quadroIniEnvDiops

Função extraida da central para eliminar a dependencia
Indica o inicio de envio de um quadro

@author lima.everton
@since 06/06/2019
/*/
//--------------------------------------------------------------------------------------------------
function qdrPlsIniEnvDiops( cQuadro, cCodOpe, cAno, cRefere, lDelQua, cRecno )

	Local cTable	  := getTabQdr( cQuadro )
	Local lReturn	  := .F.
	Local cWhrQuadro  := ""
	Local cWhrCritica := ""
	Default lDelQua	  := .T.
	Default cRecno    := ""

	if ( !empty(cTable) )

		cCodObr := PLSEXISOB( cCodOpe )
		cCdComp := PLSEXISCO( cCodOpe, cCodObr, cRefere, cAno )

		//Monta o where para limpeza do quadro
		cWhrQuadro := GetWhereQdr(cTable,cCodOpe,cCodObr,cAno,cCdComp,cRecno)

		//Monta o where para limpeza das criticas do quadro
		cWhrCritica := GetWhereCri(cTable,cCodOpe,cCodObr,cAno,cCdComp,cTable)

		If !cQuadro == QDR_BALANC

			lReturn := exstBalancete(cCodOpe,cCodObr,cAno,cCdComp)

			If lReturn .Or. IsBlind()
				// Realiza preenchimento de registros dos quadros que exigem
				If cQuadro == QDR_IDASPA	//Idade de Saldos A Pagar
					PLSCRIADSP(cCodOpe,cCodObr,cCdComp,cAno)
				ElseIf cQuadro == QDR_IDASRE	//Idade de Saldos A Receber
					PLSCRIADSA(cCodOpe,cCodObr,cCdComp,cAno)
				EndIf
			EndIf

		Else
			lReturn := .T.
		EndIf

	Endif

	If lReturn .Or. IsBlind()
		If lDelQua
			delRegiDIOPS( cTable, cWhrQuadro, cWhrCritica  )
		Else
			updStusQua(cTable, cWhrQuadro,"1")
		EndIf
	EndIf

Return lReturn

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabQuadr

Função extraida da central para eliminar a dependencia
Retorna array de regras a serem validadas

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
static function getTabQdr( cQuadro )

	Local cTable := ""

	Do Case
		Case cQuadro == QDR_BALANC //Balancete
			cTable := "B8A"
		Case cQuadro == QDR_CADAST //Dados cadastrais
			cTable := cTable
		Case cQuadro == QDR_AGIMOB //Ativos garantidores Imobiliario
			cTable := "B8C"
		Case cQuadro == QDR_FLUXCA //Fluxo de Caixa Trimestral
			cTable := "B8H"
		Case cQuadro == QDR_IDASPA //Idade de Saldos - A Pagar
			cTable := "B8F"
		Case cQuadro == QDR_LUCPRE //Lucros e Prejuízos
			cTable := "B8E"
		Case cQuadro == QDR_CONEST //Contratos Estipulados
			cTable := "BUP"
		Case cQuadro == QDR_CONREP //Segregação do Montante de Contraprestações a Repassar
			cTable := "BVS"
		Case cQuadro == QDR_COBASS //Cobertura Assistencial
			cTable := "B8I"
		Case cQuadro == QDR_EVEIND //Movimentação de Eventos Indenizáveis
			cTable := "B8L"
		Case cQuadro == QDR_AGRCON //Agrupamento de Contratos
			cTable := "B8K"
		Case cQuadro == QDR_PESL   //Saldo da Provisão de Eventos Sinistros a Liquidar
			cTable := "B8J"
		Case cQuadro == QDR_CCCOOP //Conta-Corrente Cooperado
			cTable := "BUW"
		Case cQuadro == QDR_CTRPAS //Conta Tributo Passivo
			cTable := "BUY"
		Case cQuadro == QDR_IDASRE //Idade de Saldos - A receber
			cTable := "B8G"
		Case cQuadro == QDR_FUNCOM //Fundos Comuns
			cTable := "B6R"
		Case cQuadro == QDR_EVCCC  //CONTRAPRESTAÇÃO DE CORRESPONSABILIDADE CEDIDA
			cTable := "B36"
		Case cQuadro == QDR_MPC    //Modelo Padrão de Capital
			cTable := "B82"
		Case cQuadro == QDR_TAP    //Teste Adequação do Passivo
			cTable := "B89"
		Case cQuadro == QDR_CONPEC //Contraprestações pecuniárias
			cTable := "B37"
	EndCase

return cTable

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSEXISOB

Extraida da central para eliminar a dependencia
Funcao criada para verificar se existe uma obrigacao cadastrada

@author lima.everton
@since 06/062019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSEXISOB( cCodOpe )

	Local cRetorno		:= ""
	Local cSql			:= ""
	local cAliasN		:= getNextAlias()
	Default cCodOpe	:= ""

	cSql := "SELECT B3A_CODIGO FROM " + RetSqlName("B3A") + " WHERE B3A_FILIAL = '" + xFilial("B3A") + "' AND B3A_CODOPE = '" + cCodOpe
	cSQL += "' AND B3A_TIPO = '3'  AND B3A_ATIVO = '1' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasN,.F.,.T.)

	If !(cAliasN)->(Eof())
		cRetorno := (cAliasN)->B3A_CODIGO
	EndIf

	(cAliasN)->(dbCloseArea())

Return cRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSEXISCO

Função extraida da central para eliminar a dependencia
Funcao criada para verificar e retornar se existe um compromisso cadastrado

@author lima.everton
@since 06/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSEXISCO( cCodOpe, cCodObr, cRefere, cAno )

	Local cRetorno	:= ""
	Local cAliasN	:= getNextAlias()
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cRefere	:= ""
	Default cAno	:= ""

	//Na B3D-Compromisso o campo B3D_REFERE e gravado no formato 3º Tri/17, por isso o ajuste abaixo
	If !Empty(cRefere)
		cRefere := AllTrim(Str(Val(cRefere)))
	EndIf

	cSql := "SELECT B3D_CODIGO FROM " + RetSqlName("B3D") + " WHERE B3D_FILIAL = '" + xFilial("B3D") + "' AND B3D_CODOPE = '"
	cSql += cCodOpe + "' AND B3D_CDOBRI = '" + cCodObr + "' AND B3D_REFERE LIKE '"+cRefere+"%' AND B3D_ANO = '" + cAno
	cSql += "' AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasN,.F.,.T.)

	If !(cAliasN)->(Eof())
		cRetorno := (cAliasN)->B3D_CODIGO
	EndIf

	(cAliasN)->(dbCloseArea())

Return cRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetWhereQdr

Extraida da central para eliminar a dependencia
Funcao criada para montar o where para limpeza da tabela do quadro

@author lima.everton
@since 06/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Function GetWhereQdr(cTable,cCodOpe,cCodObr,cAnoCmp,cCdComp,cRecno)

	Local cWhrQuadro	:= ""
	default cTable := ""
	default cRecno := ""

	If !Empty(cTable)

		cWhrQuadro	:= cTable +"_FILIAL='" + xFilial(cTable) + "' AND "+ cTable +"_CODOPE='"+cCodOpe+"' AND "+ cTable +"_CODOBR='"+cCodObr+"' AND "+ cTable +"_ANOCMP='"+cAnoCmp+"' AND "+ cTable +"_CDCOMP='"+cCdComp+"' "

		if ( !empty(cRecno) )
			cWhrQuadro := cWhrQuadro + "AND R_E_C_N_O_<>" + cRecno+" "
		endif

	EndIf

Return cWhrQuadro

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetWhereCri

Extraida da central para eliminar a dependencia
Funcao criada para montar o where para limpeza da tabela de criticas

@author lima.everton
@since 06/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Function GetWhereCri(cFStruct,cCodOpe,cCodObr,cAnoCmp,cCdComp,cTable)

	Local cWhrCritica		:= ""
	default cTable		:= ""

	If !Empty(cTable)

		//X2_UNICO B3F B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_ORICRI+STR(B3F_CHVORI)+B3F_CODCRI+B3F_TIPO+B3F_IDEORI+B3F_DESORI
		cWhrCritica := " B3F_FILIAL='"+xFilial("B3F")+"' AND B3F_CODOPE='"+cCodOpe+"' AND B3F_CDOBRI='"+cCodObr+"' AND B3F_ANO='"+cAnoCmp+"' AND B3F_CDCOMP='"+cCdComp+"' AND B3F_ORICRI='"+cTable+"' "

	EndIf

Return cWhrCritica


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} exstBalancete

Função extraida da central para eliminar a dependencia
Verifica se balancete existe para aquela operadora e compromisso

@author lima.everton
@since 06/06/2019
/*/
//--------------------------------------------------------------------------------------------------
static function exstBalancete(cCodOpe,cCodObr,cAnoCmp,cCdComp)

	Local cSql	:= ""
	Local lRet	:= .F.
	Local cAliasN := getNextAlias()

	cSql := "SELECT B8A_CONTA FROM " + RetSqlName("B8A") + " WHERE B8A_FILIAL='" + xFilial("B8A") + "' AND B8A_CODOPE='" + cCodOpe + "' AND B8A_CODOBR='" +cCodObr+ "' AND B8A_ANOCMP='" +cAnoCmp+ "' "
	cSql += "AND B8A_CDCOMP='" +cCdComp+ "' AND D_E_L_E_T_ = ''"
	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasN,.F.,.T.)

	lRet := !(cAliasN)->(Eof())

return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCRIIDSA

Função extraida da central para eliminar a dependencia
Funcao cria os demais itens do quadro idade dos saldos

@author lima.everton
@since 07/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCRIADSA(cCodOpe,cCodObr,cCdComp,cAnoCmp)

	Local aVenctos	:= {"000","030","060","090","099"}
	Local cVencto	:= ""
	Local cRefere	:= B3DRefere()
	Local nFor		:= 0
	Local lRet		:= .T.
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cCdComp	:= ""
	Default cAnoCmp	:= ""
	//Vou inserir os demais itens no quadro
	For nFor := 1 TO Len(aVenctos)

		//Monta o where para verificar se existe o iten no quadro
		cWhrQuadro := GetWhereQdr("B8F",cCodOpe,cCodObr,cAnoCmp,cCdComp)
		cWhrQuadro += " AND B8F_VENCTO='"+aVenctos[nFor]+"' "

		//Verifica se ja foi inserido algum item no quadro
		cVencto := ExstIdaSldA(cWhrQuadro)

		If Empty(cVencto)//Se nao encontrou o vencto
			//Vou inserir o vencto nao encontrado
			IsrIdaSldAtv(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,aVenctos[nFor])
		EndIf

	Next nFor

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCRIADSP

Função extraida da central para eliminar a dependencia
Funcao cria os demais itens do quadro idade dos saldos passivo

@author lima.everton
@since 07/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCRIADSP(cCodOpe,cCodObr,cCdComp,cAnoCmp)

	Local aVenctos		:= {"000","030","060","090","120","999"}
	Local cVencto	:= ""
	Local cRefere	:= B3DRefere()
	Local nFor		:= 0
	Local lRet		:= .T.
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cCdComp	:= ""
	Default cAnoCmp	:= ""

	//Vou inserir os demais itens no quadro
	For nFor := 1 TO Len(aVenctos)

		//Monta o where para verificar se existe o iten no quadro
		cWhrQuadro := GetWhereQdr("B8G",cCodOpe,cCodObr,cAnoCmp,cCdComp)
		cWhrQuadro += " AND B8G_VENCTO='"+aVenctos[nFor]+"' "

		//Verifica se ja foi inserido algum item no quadro
		cVencto := ExtIdaSldP(cWhrQuadro)

		If Empty(cVencto)//Se nao encontrou o vencto

			//Vou inserir o vencto nao encontrado
			IsrIdaSldPas(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,aVenctos[nFor])

		EndIf

	Next nFor

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExstIdaSldA

Extraida da central para eliminar a dependencia
Funcao verifica se existe um evento no quadro idade de saldos ativo e posiciona

@author lima.everton
@since 07/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExstIdaSldA(cWhrQuadro)

	Local cSql	  := ""
	Local cAliTrb := GetNextAlias()
	Local cRet	  := ""

	Default cWhrQuadro := ""

	If !Empty(cWhrQuadro)

		cSql := "SELECT R_E_C_N_O_ REC, B8F_VENCTO FROM " + RetSqlName("B8F") + " WHERE " + cWhrQuadro
		cSql := ChangeQuery(cSql)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

		If !(cAliTrb)->(Eof())
			cRet := AllTrim((cAliTrb)->B8F_VENCTO)
			B8F->(dbGoTo((cAliTrb)->REC))
		EndIf

		(cAliTrb)->(dbCloseArea())

	EndIf

Return cRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IsrIdaSldAtv

Função extraida da central para eliminar a dependencia
Funcao grava itens na tabela de idade de saldos ativos

@author lima.everton
@since 07/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function IsrIdaSldAtv(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,cVencto)

	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cRefere	:= ""
	Default cCdComp	:= ""
	Default cVencto	:= ""

	RecLock("B8F",.T.)
	B8F->B8F_FILIAL := xFilial("B8F")
	B8F->B8F_CODOPE := cCodOpe
	B8F->B8F_CODOBR := cCodObr
	B8F->B8F_ANOCMP := cAnoCmp
	B8F->B8F_REFERE := cRefere
	B8F->B8F_CDCOMP := cCdComp
	B8F->B8F_VENCTO := cVencto
	B8F->B8F_EVENTO := 0
	B8F->B8F_COMERC := 0
	B8F->B8F_DEBOPE := 0
	B8F->B8F_OUDBOP := 0
	B8F->B8F_DEPBEN := 0
	B8F->B8F_SERASS := 0
	B8F->B8F_AQUCAR := 0
	B8F->B8F_OUDBPG := 0
	B8F->B8F_EVESUS := 0
	B8F->B8F_TITSEN := 0
	B8F->B8F_STATUS := "1"
	msUnLock()

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsereIdaSldPas

Função extraida da central para eliminar a dependencia
Funcao grava itens na tabela de idade de saldos ativos

@author lima.everton
@since 07/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function IsrIdaSldPas(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,cVencto)

	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cRefere	:= ""
	Default cCdComp	:= ""
	Default cVencto	:= ""

	RecLock("B8G",.T.)
	B8G->B8G_FILIAL := xFilial("B8G")
	B8G->B8G_CODOPE := cCodOpe
	B8G->B8G_CODOBR := cCodObr
	B8G->B8G_ANOCMP := cAnoCmp
	B8G->B8G_REFERE := cRefere
	B8G->B8G_CDCOMP := cCdComp
	B8G->B8G_VENCTO := cVencto
	B8G->B8G_INDPRE := 0
	B8G->B8G_INDPOS := 0
	B8G->B8G_COLPRE := 0
	B8G->B8G_COLPOS := 0
	B8G->B8G_CREADM := 0
	B8G->B8G_PARBEN := 0
	B8G->B8G_OUCROP := 0
	B8G->B8G_OUCRPL := 0
	B8G->B8G_OUTCRE := 0
	B8G->B8G_STATUS := "1"
	msUnLock()

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExtIdaSldP

Função extraida da central para eliminar a dependencia
Funcao verifica se existe um evento no quadro idade de saldos passivo e posiciona

@author lima.everton
@since 07/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExtIdaSldP(cWhrQuadro)

	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local cRet		:= ""
	Default cWhrQuadro	:= ""

	If !Empty(cWhrQuadro)

		cSql := "SELECT R_E_C_N_O_ REC, B8G_VENCTO FROM " + RetSqlName("B8G") + " WHERE " + cWhrQuadro
		cSql := ChangeQuery(cSql)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

		If !(cAliTrb)->(Eof())
			cRet := AllTrim((cAliTrb)->B8G_VENCTO)
			B8G->(dbGoTo((cAliTrb)->REC))
		EndIf

		(cAliTrb)->(dbCloseArea())

	EndIf

Return cRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} delRegiDIOPS

Função extraida da central para eliminar a dependencia
Funcao criada para deletar um registro do quadro no momento de um novo commit do model

@author henrique.souza
@since 19/05/2016
/*/
//--------------------------------------------------------------------------------------------------
function delRegiDIOPS( cAlias, cWhrQuadro, cWhrCritica  )

	local cQryQuadro			:= ""
	local cQryCritica			:= ""
	default cWhrQuadro		:= ""
	default cWhrCritica		:= ""

	If !Empty(cWhrQuadro)
		cQryQuadro := "DELETE FROM " + RetSqlname( allTrim(cAlias) ) + " WHERE " + allTrim( cWhrQuadro )
		TCSQLEXEC(cQryQuadro)
	EndIf

	If !Empty(cWhrCritica)
		cQryCritica := "DELETE FROM " + RetSqlname( "B3F" ) + " WHERE " + allTrim( cWhrCritica )
		TCSQLEXEC(cQryCritica)
	EndIf

return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} updStusQua

Função extraida da central para eliminar a dependencia
Atualiza registro de quadros que ainda não possuem intregracao

@author lima.everton
@since 11/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function updStusQua(cTable,cWhrQuadro,cStatus)
	Local cUpdate		:= ""
	Default cTable		:= ""
	Default cWhrQuadro	:= ""
	Default cStatus		:= "1"

	cUpdate := "UPDATE " + RetSqlName(cTable) + " SET " + AllTrim(cTable) + "_STATUS='" + cStatus + "' WHERE " + AllTrim(cWhrQuadro)
	TCSQLEXEC(cUpdate)

Return

