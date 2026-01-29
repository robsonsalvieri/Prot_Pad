#INCLUDE "TOTVS.CH"
#INCLUDE "QIPLaudosEnsaios.CH"

Static lIntQMT := Nil
Static lIntQNC := Nil

CLASS QIPLaudosEnsaios FROM LongNameClass
	
	DATA cNivelLaudo         as STRING
	DATA cParecerAprovado    as STRING
	DATA cParecerCondicional as STRING
	DATA cParecerReprovado   as STRING
	DATA cParecerUrgente     as STRING
	DATA cPrimeiroAprovado   as STRING
	DATA cPrimeiroReprovado  as STRING
	DATA oAPIManager         as OBJECT
	DATA oWSRestFul          as OBJECT

	Method New(oWSRestFul)

	//Métodos Públicos
	Method AvaliaAcessoATodaOperacao(nRecnoInspecao, cUsuario, cOperacao)
	Method BuscaDataDeValidadeDoLaudo(nRecnoInspecao, cUsuario, cError)
	Method ChecaTodasAsOperacoesComLaudos(cUsuario, nRecnoQPK)
	Method ChecaTodosOsLaboratoriosComLaudos(cUsuario, nRecnoQPK)
	Method DirecionaParaTelaDeLaudoPorInspecaoEUsuario(nRecnoInspecao, cUsuario, cError, cRoteiro, cOperacao)
	Method ExcluiLaudoGeral(cUsuario, nRecnoQPK, cRoteiro, cOperacao)
	Method ExcluiLaudoGeralEEstornaMovimentosCQ(cLogin, nRecnoQPK, cRoteiro, lMedicao)
	Method ExcluiLaudoLaboratorio(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, lMedicao)
	Method ExcluiLaudoOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, lMedicao)
	Method GravaLaudoGeral(cUsuario, nRecnoQPK, cRoteiro, cParecer, cJustifica, nRejeicao, cValidade, lBaixaCQ)
	Method GravaLaudoLaboratorio(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, cParecer, cJustifica, nRejeicao, cValidade)
	Method GravaLaudoOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cParecer, cJustifica, nRejeicao, cValidade)
	Method LaudoPodeSerEditado(nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, cNivelLaudo)
	Method ReabreInspecao(cUsuario, nRecnoQPK, cRoteiro, lMedicao)
	Method ReabreOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, lMedicao)
	Method RetornaLaudoGeral(nRecnoQPK, cRoteiro)
	Method RetornaLaudoLaboratorio(nRecnoQPK, cRoteiro, cOperacao, cLaboratorio)
	Method RetornaLaudoOperacao(nRecnoQPK, cRoteiro, cOperacao)
	Method RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos()
	Method SugereParecerLaudo(cNivelLaudo, nRecnoInspecao, aOperacoes, aLaboratorios, cUsuario, cError)
	Method UsuarioPodeConsultarLaudo(cUsuario, cNivelLaudo, cError)
	Method UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, cError)
	Method ValidaDataDeValidadeDoLaudo(dShelfLife, cReportSelected, cError)

	//Métodos Internos
	Method ApagaAssinatura( cNumOP, cOperacao, cLabor)
	Method AtualizaCertificadoDaQualidade(lDesvincular)
	Method AtualizaFlagLegendaInspecao(cParecer)
	Method AvaliaLaudosOperacoes(cAlias, cParecer)
	Method AvaliaNecessidadeDeDirecionarParaGeralERedireciona(nRecnoInspecao, cPagina)
	Method AvaliaObrigatoriedadeEnsaiosDaOperacao(cAlias, lEnsObr, lEnsOK, cEnsPend)
	Method AvaliaParecerLaboratorio(cAlias, cParecer)
	Method DefineParecerLaudos()
	Method DirecionaParaTelaDeLaudo(nLabsInspecao, nOperInspecao, nLabsUInsp, cUsuario, lLaudGeral)
	Method FluxoAnaliseTodosOsLaboratoriosOperacao(nRecnoInspecao, cOpeAnterior, cUsuario, oEnsaiosAPI, cError, lSequencia, cDescOper)
	Method FluxoValidacaoLaudoOperacao(nRecnoInspecao, cOperacao, cUsuario, cError)
	Method FluxoValidacaoSequenciaLaudoOperacao(nRecnoInspecao, cOperacao, cUsuario, cError)
	Method GravaAssinaturaGeral(cUsuario, cLaudoGer, cNumOp)
	Method GravaAssinaturaLaboratorio(cUsuario, cLaudoLab, cNumOP, cLabor, cOperacao)
	Method GravaAssinaturaOperacao(cUsuario, cLaudoOpe, cNumOP, cOperacao)
	Method ModoAcessoLaudo(cLogin, cCampo)
	Method MovimentaEstoqueCQ(nRecnoQPK)
	Method QuantidadeLaboratoriosInspecao(nRecnoInspecao)
	Method QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario)
	Method QuantidadeOperacoesInspecao(nRecnoInspecao)
	Method ReabreInspecaoEEstornaMovimentosCQ(cLogin, nRecnoQPK, cRoteiro, lMedicao, nOpc)
	Method RetornaListaOperacoes(nRecnoInspecao)
	Method RetornaObrigatoriedadesOperacao(cProduto, cRevisao, cRoteiro, cOperacao, lSequencia, lLaudo, lOperacao)
	Method SugereParecerLaudoGeral(nRecnoInspecao, cUsuario, cError)
	Method SugereParecerLaudosLaboratorios(nRecnoInspecao, cOperacao, cParecer, aLaboratorios, cUsuario, lAnlSeqObr, cError)
	Method SugereParecerLaudosOperacoes(nRecnoInspecao, aOperacoes, aLaboratorios, cUsuario, cError, lSequencia)
	Method SugereParecerSuperior(cParecer, cPriAprovado, cPriReprovado, cPriUrgente, cPriCondicional, cPriPendente, cParecerMed)
	Method TodosOsLaboratoriosOperacaoComLaudo(cAliasEnsaios)
	Method ValidaRecnoValidoQPK(nRecnoQPK)

EndClass

METHOD New(oWSRestFul) CLASS QIPLaudosEnsaios

     Self:oWSRestFul  := oWSRestFul
	 Self:oAPIManager := QualityAPIManager():New(Nil, oWSRestFul)

	self:cParecerAprovado     := ""
	self:cParecerCondicional  := ""
	self:cParecerReprovado    := ""
	self:cParecerUrgente      := ""

Return Self

/*/{Protheus.doc} DirecionaParaTelaDeLaudo
Método Responsável por Realização do Direcionamento para a Página de Laudo
@author brunno.costa
@since  17/10/2022
@param 01 - nLabsInspecao, número, quantidade de laboratórios relacionados a inspeção atual
@param 02 - nOperInspecao, número, quantidade de operações relacionadas a inspeção atual
@param 03 - nLabsUInsp   , número, quantidade de laboratórios da inspeção que o usuário tem acesso
@param 04 - cUsuario     , caracter, login do usuário para checagem
@param 05 - cError       , caracter, retorna por referência erro na comparação
@return cPagina, caracter, caracter que indica o modelo de página de Laudo que o usuário será direcionado, sendo:
                          L  - Laudo via Laboratório
						  O  - Laudo via Operação
						  G  - Laudo Geral
						  OA - Laudo de Operação Agrupado (Similar ao Geral, visualiza várias operações, mas não grava Laudo Geral)
						  LA - Laudo de Laboratório Agrupado (Similar ao via Operação, visualiza vários laboratórios, mas não grava Laudo Geral nem de Operação)
/*/
Method DirecionaParaTelaDeLaudo(nLabsInspecao, nOperInspecao, nLabsUInsp, cUsuario, cError) CLASS QIPLaudosEnsaios
	Local cPagina      := ""
	Local cNivelLaudo  := ""
	Local cError       := ""

	Default nLabsInspecao := 1
	Default nOperInspecao := 1
	Default nLabsUInsp    := 1

	If nLabsInspecao == nLabsUInsp //Cenários SEM Restrições de Acesso a Laboratórios
		If     nLabsInspecao == 1 .AND. nOperInspecao == 1
			cPagina     := "L"
			cNivelLaudo := "L"
		ElseIf nLabsInspecao == 1 .AND. nOperInspecao >  1
			cPagina     := "G"
			cNivelLaudo := "G"
		ElseIf nLabsInspecao >  1 .AND. nOperInspecao == 1
			cPagina     := "O"
			cNivelLaudo := "O"
		ElseIf nLabsInspecao >  1 .AND. nOperInspecao >  1
			cPagina     := "G"
			cNivelLaudo := "G"
		EndIf
	Else                           //Cenários COM Restrições de Acesso a Laboratórios
		If nLabsInspecao >  1 .AND. nOperInspecao == 1
			cPagina     := "LA"
			cNivelLaudo := "L"
		ElseIf nLabsInspecao >  1 .AND. nOperInspecao >  1
			cPagina     := "OA"
			cNivelLaudo := "O"
		EndIf
	EndIf

	If !Self:UsuarioPodeGerarLaudo(cUsuario, "T")
		If cNivelLaudo == "G" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, @cError)
			cPagina         := "OA"
			cNivelLaudo     := "O"
		EndIf

		If cNivelLaudo == "O" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, @cError)
			cPagina         := "LA"
			cNivelLaudo     := "L"
		EndIf

		If cNivelLaudo == "L" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, @cError)
			cPagina         := ""
		EndIf

		If cNivelLaudo == "O" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, "G", @cError)
			cPagina         := "OA"
		EndIf

		If cNivelLaudo == "L" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, "G", @cError)
			cPagina         := "LA"
		EndIf
	EndIf


Return cPagina

/*/{Protheus.doc} DirecionaParaTelaDeLaudoPorInspecaoEUsuario
Método Responsável por Realização do Direcionamento para a Página de Laudo - Por Inspeção e Usuário
@author brunno.costa
@since  17/10/2022
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@param 02 - cUsuario      , caracter, login do usuário para checagem
@param 03 - cError        , caracter, retorna por referência erro na comparação
@param 04 - cRoteiro      , caracter, indica o código do roteiro de operações
@param 05 - cOperacao     , caracter, indica o código da operação
@return cPagina, caracter, caracter que indica o modelo de página de Laudo que o usuário será direcionado, sendo:
                          L  - Laudo via Laboratório
						  O  - Laudo via Operação
						  G  - Laudo Geral
						  OA - Laudo de Operação Agrupado (Similar ao Geral, visualiza várias operações, mas não grava Laudo Geral)
						  LA - Laudo de Laboratório Agrupado (Similar ao via Operação, visualiza vários laboratórios, mas não grava Laudo Geral nem de Operação)
						  X  - Usuário sem acesso a geração de Laudos
/*/
Method DirecionaParaTelaDeLaudoPorInspecaoEUsuario(nRecnoInspecao, cUsuario, cError, cRoteiro, cOperacao) CLASS QIPLaudosEnsaios
	
	Local cPagina       := "X"
	Local nLabsInspecao := Nil
	Local nLabsUInsp    := Nil
	Local nOperInspecao := Nil

	If Self:UsuarioPodeGerarLaudo(cUsuario, "X", @cError)
		nLabsInspecao := Self:QuantidadeLaboratoriosInspecao(nRecnoInspecao)
		nLabsUInsp    := Self:QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario)
		nOperInspecao := Self:QuantidadeOperacoesInspecao(nRecnoInspecao)
		cPagina       := Self:DirecionaParaTelaDeLaudo(nLabsInspecao, nOperInspecao, nLabsUInsp, cUsuario, @cError)
		cPagina       := Self:AvaliaNecessidadeDeDirecionarParaGeralERedireciona(nRecnoInspecao, cPagina)

	EndIf

	If     cPagina != "G" .And.                       Self:RetornaLaudoGeral(nRecnoInspecao, cRoteiro)['hasReport']               .And. Self:UsuarioPodeConsultarLaudo(cUsuario, "G", @cError)
		cPagina   := "G"

	ElseIf cPagina != "G" .And. cPagina != "O" .And. cPagina != "OA" .And. Self:RetornaLaudoOperacao(nRecnoInspecao, cRoteiro, cOperacao)['hasReport'] .And. Self:UsuarioPodeConsultarLaudo(cUsuario, "O", @cError)
		cPagina   := "OA"

	EndIf

	If (cPagina == "L" .OR. cPagina == "O") .And. !Self:fluxoValidacaoLaudoOperacao(nRecnoInspecao, cOperacao, cUsuario, /*@cError*/) //Este erro não deve notificar front-end - apenas redirecionará para próxima página que notificará
		cPagina := "G"
	EndIf

	Self:oApiManager:cErrorMessage := Iif(!Empty(cError) .AND. Empty(cPagina), cError, Self:oApiManager:cErrorMessage)

Return cPagina

/*/{Protheus.doc} AvaliaNecessidadeDeDirecionarParaGeralERedireciona
Avalia Necessidade de Direcionar Para Tela Laudo de Inspeção Geral, devido existência de laudo de Operação ou Laboratório
@author brunno.costa
@since  16/11/2022
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@param 02 - cPagina       , caracter, página de direcionamento atual
@return cPagina, caracter, página correta para direcionamento
/*/
Method AvaliaNecessidadeDeDirecionarParaGeralERedireciona(nRecnoInspecao, cPagina) CLASS QIPLaudosEnsaios
	
	Local cFilQPM := xFilial("QPM")
	Local cFilQPL := xFilial("QPL")

	If cPagina == "L"
		QPK->(DbGoTo(nRecnoInspecao))
		QPM->(dbSetOrder(3))
		If QPM->(dbSeek(cFilQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)))
			While cFilQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER) == QPM->(QPM_FILIAL+QPM_OP+QPM_LOTE+QPM_NUMSER)
				If !Empty(QPM->QPM_LAUDO)
					cPagina := "G"
					Exit
				EndIf
				QPM->(DbSkip())
			EndDo
		EndIf

		If cPagina != "G"
			QPL->(dbSetOrder(3))
			If QPL->(dbSeek(cFilQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)))
				While cFilQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER) == QPL->(QPL_FILIAL+QPL_OP+QPL_LOTE+QPL_NUMSER)
					If !Empty(QPL->QPL_LAUDO) .AND. !Empty(QPL->QPL_LABOR)
						cPagina := "G"
						Exit
					EndIf
					QPL->(DbSkip())
				EndDo
			EndIf
		EndIf
	ElseIf cPagina == "O"
		QPK->(DbGoTo(nRecnoInspecao))
		QPM->(dbSetOrder(3))
		If QPM->(dbSeek(cFilQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)))
			While cFilQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER) == QPM->(QPM_FILIAL+QPM_OP+QPM_LOTE+QPM_NUMSER)
				If !Empty(QPM->QPM_LAUDO)
					cPagina := "G"
					Exit
				EndIf
				QPM->(DbSkip())
			EndDo
		EndIf
	EndIf
	
Return cPagina

/*/{Protheus.doc} AvaliaAcessoATodaOperacao
Avalia acesso a inclusão de Laudo para toda a Operação
@author brunno.costa
@since  17/10/2022
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@param 02 - cUsuario      , caracter, login do usuário para checagem
@param 03 - cOperacao     , caracter, operação relacionada
@return lPermite, lógico, indica se permite acesso a inclusão de laudo em toda a operação
/*/
Method AvaliaAcessoATodaOperacao(nRecnoInspecao, cUsuario, cOperacao) CLASS QIPLaudosEnsaios
	
	Local lPermite      := Nil
	Local nLabsInspecao := Nil
	Local nLabsUInsp    := Nil

	nLabsInspecao := Self:QuantidadeLaboratoriosInspecao(nRecnoInspecao, cOperacao) 
	nLabsUInsp    := Self:QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario, cOperacao) 

	lPermite := nLabsUInsp >= nLabsInspecao
	
Return lPermite

/*/{Protheus.doc} QuantidadeLaboratoriosInspecao
Retorna a quantidade de laboratórios relacionados a inspeção
@author brunno.costa
@since  17/10/2022
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@param 02 - cOperacao     , caracter, indica o filtro de operação para análise
@return nLabsInspecao, número, indica o número de laboratórios vinculados a inspeção
/*/
Method QuantidadeLaboratoriosInspecao(nRecnoInspecao, cOperacao) CLASS QIPLaudosEnsaios
	
	Local cAlias        := ""
	Local cQuery        := ""
	Local nLabsInspecao := 0

	Default nRecnoInspecao := -1
	Default cOperacao      := ""

	If nRecnoInspecao > 0
		cQuery += " SELECT COUNT(QP7_LABOR) COUNTLAB
		cQuery += "  FROM  "
		cQuery +=  " (SELECT QPK_PRODUT, QPK_REVI  "
		cQuery += "  FROM " + RetSQLName("QPK")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "
		cQuery +=    " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
		cQuery +=  " ) QPK INNER JOIN  "
		cQuery +=  " (SELECT QP7_PRODUT, QP7_REVI, QP7_LABOR  "
		cQuery += "  FROM " + RetSQLName("QP7")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP7_FILIAL = '"+xFilial("QP7")+"')  "

		If !Empty(cOperacao)
			cQuery +=    " AND (QP7_OPERAC = '"+cOperacao+"')  "
		EndIf

		cQuery += "  UNION  "
		cQuery += "  SELECT QP8_PRODUT, QP8_REVI, QP8_LABOR  "
		cQuery += "  FROM " + RetSQLName("QP8")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP8_FILIAL = '"+xFilial("QP8")+"')  
		
		If !Empty(cOperacao)
			cQuery +=    " AND (QP8_OPERAC = '"+cOperacao+"')  "
		EndIf

		cQuery += " ) ENSAIOS "
		cQuery += " ON   QPK_PRODUT = QP7_PRODUT "
		cQuery +=  " AND QPK_REVI   = QP7_REVI "


		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		If (cAlias)->(!Eof())
			nLabsInspecao := (cAlias)->COUNTLAB
		EndIf
		(cAlias)->(DbCloseArea())
	EndIf

Return nLabsInspecao

/*/{Protheus.doc} QuantidadeLaboratoriosUsuarioInspecao
Retorna a quantidade de laboratórios relacionados a inspeção que o usuário possui acesso
@author brunno.costa
@since  17/10/2022
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@param 02 - cUsuario      , caracter, login do usuário para checagem
@param 03 - cOperacao     , caracter, operação relacionada
@return nLabsUInsp, número, indica o número de laboratórios vinculados a inspeção que o usuário possui acesso
/*/
Method QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario, cOperacao) CLASS QIPLaudosEnsaios
	
	Local cAlias     := ""
	Local cQuery     := ""
	Local nLabsUInsp := 0

	Default nRecnoInspecao := -1
	Default cOperacao      := ""

	If nRecnoInspecao > 0
		
		Self:oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario()

		cQuery += " SELECT COUNT(QP7_LABOR) COUNTLAB
		cQuery += "  FROM  "
		cQuery +=  " (SELECT QPK_PRODUT, QPK_REVI  "
		cQuery += "  FROM " + RetSQLName("QPK")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "
		cQuery +=    " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
		cQuery +=  " ) QPK INNER JOIN  "
		cQuery +=  " (SELECT QP7_PRODUT, QP7_REVI, QP7_LABOR  "
		cQuery += "  FROM " + RetSQLName("QP7")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		If !Empty(cOperacao)
			cQuery +=    " AND (QP7_OPERAC = '"+cOperacao+"')  "
		EndIf

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP7_LABOR", cUsuario)
		EndIf

		cQuery +=    " AND (QP7_FILIAL = '"+xFilial("QP7")+"')  "
		cQuery += "  UNION  "
		cQuery += "  SELECT QP8_PRODUT, QP8_REVI, QP8_LABOR  "
		cQuery += "  FROM " + RetSQLName("QP8")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "

		If !Empty(cOperacao)
			cQuery +=    " AND (QP8_OPERAC = '"+cOperacao+"')  "
		EndIf
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QP8_LABOR", cUsuario)
		EndIf

		cQuery +=    " AND (QP8_FILIAL = '"+xFilial("QP8")+"')  ) ENSAIOS "
		cQuery += " ON   QPK_PRODUT = QP7_PRODUT "
		cQuery +=  " AND QPK_REVI   = QP7_REVI "

		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		If (cAlias)->(!Eof())
			nLabsUInsp := (cAlias)->COUNTLAB
		EndIf
		(cAlias)->(DbCloseArea())
	EndIf

Return nLabsUInsp

/*/{Protheus.doc} QuantidadeOperacoesInspecao
Retorna a quantidade de operações relacionadas a inspeção
@author brunno.costa
@since  17/10/2022
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@return nOperInspecao, número, indica o número de operações vinculados a inspeção
/*/
Method QuantidadeOperacoesInspecao(nRecnoInspecao) CLASS QIPLaudosEnsaios
	
	Local cAlias        := ""
	Local cQuery        := ""
	Local nOperInspecao := 0

	Default nRecnoInspecao := -1

	If nRecnoInspecao > 0
		cQuery += " SELECT COUNT(QP7_OPERAC) COUNTOPER
		cQuery += "  FROM  "
		cQuery +=  " (SELECT QPK_PRODUT, QPK_REVI  "
		cQuery += "  FROM " + RetSQLName("QPK")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "
		cQuery +=    " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
		cQuery +=  " ) QPK INNER JOIN  "
		cQuery +=  " (SELECT QP7_PRODUT, QP7_REVI, QP7_OPERAC  "
		cQuery += "  FROM " + RetSQLName("QP7")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP7_FILIAL = '"+xFilial("QP7")+"')  "
		cQuery += "  UNION  "
		cQuery += "  SELECT QP8_PRODUT, QP8_REVI, QP8_OPERAC  "
		cQuery += "  FROM " + RetSQLName("QP8")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP8_FILIAL = '"+xFilial("QP8")+"')  ) ENSAIOS "
		cQuery += " ON   QPK_PRODUT = QP7_PRODUT "
		cQuery +=  " AND QPK_REVI   = QP7_REVI "

		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		If (cAlias)->(!Eof())
			nOperInspecao := (cAlias)->COUNTOPER
		EndIf
		(cAlias)->(DbCloseArea())
	EndIf

Return nOperInspecao

/*/{Protheus.doc} UsuarioPodeGerarLaudo
Indica se o usuário pode gerar laudo
@author brunno.costa
@since  17/10/2022
@param 01 - cUsuario    , caracter, login do usuário para checagem
@param 02 - cNivelLaudo, caracter, indica o nível para análise:
								L - Laboratório
								O - Operação
								G - Geral
								X - Qualquer
								T - Todos
@param 03 - cError      , caracter, retorna por referência erro na comparação
@return lLaudGeral, lógico, indica se o usuário pode gerar laudo geral
/*/
Method UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, cError) CLASS QIPLaudosEnsaios
	
	Local cNivDefGer := Nil
	Local cNivDefLab := Nil
	Local cNivDefOpe := Nil
	Local cNivelDef  := SuperGetMV("MV_QPLDNIV", .F., "000")
	Local cNivelUser := Posicione("QAA", 6, Upper(cUsuario), "QAA_NIVEL")
	Local lLaudGeral := .F.
	Local lLaudLabor := .F.
	Local lLaudOpera := .F.
	Local lReturn    := .F.
	Local oLastError := ErrorBlock({|e| cError := (e:Description) +  Self:oApiManager:CallStack(), Break(e)} )

	Default cNivelLaudo := 'X'

	cNivelUser := Iif(Empty(cNivelUser), "0", cNivelUser)

	If Len(cNivelDef) < 3
		cError                            := STR0001 //"Falha na configuração do parâmetro MV_QPLDNIV."
		Self:oApiManager:cErrorMessage    := cError
	Else
		cNivDefLab := Substring(cNivelDef, 1, 1)
		cNivDefOpe := Substring(cNivelDef, 2, 1)
		cNivDefGer := Substring(cNivelDef, 3, 1)

		lLaudLabor := Val(cNivDefLab) <= Val(cNivelUser)
		lLaudOpera := Val(cNivDefOpe) <= Val(cNivelUser)
		lLaudGeral := Val(cNivDefGer) <= Val(cNivelUser)

		lReturn := Iif(cNivelLaudo == 'L', lLaudLabor                                  , lReturn)
		lReturn := Iif(cNivelLaudo == 'O', lLaudOpera                                  , lReturn)
		lReturn := Iif(cNivelLaudo == 'G', lLaudGeral                                  , lReturn)
		lReturn := Iif(cNivelLaudo == 'X', lLaudLabor .OR. lLaudOpera .OR. lLaudGeral  , lReturn)
		lReturn := Iif(cNivelLaudo == 'T', lLaudLabor .AND. lLaudOpera .AND. lLaudGeral, lReturn)
	EndIf

	
	//Avalia Campos QAXA010
	If lReturn
		lLaudLabor := Self:ModoAcessoLaudo(cUsuario, "QAA_LDOLAB") == "1" //Inclusão / Edição
		lLaudOpera := Self:ModoAcessoLaudo(cUsuario, "QAA_LDOOPE") == "1" //Inclusão / Edição
		lLaudGeral := Self:ModoAcessoLaudo(cUsuario, "QAA_LDOGER") == "1" //Inclusão / Edição


		lReturn := Iif(cNivelLaudo == 'L', lLaudLabor                  , lReturn)
		If !lReturn
			//STR0032 - 'Acesso negado. Solicite liberação no campo '
			//STR0033 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
			cError := STR0032 + ' "' + AllTrim(GetSx3Cache("QAA_LDOLAB","X3_TITULO")) + '" (QAA_LDOLAB)' + STR0033
		EndIf


		lReturn := Iif(cNivelLaudo == 'O', lLaudOpera                                  , lReturn)
		If !lReturn .AND. Empty(cError)
			//STR0032 - 'Acesso negado. Solicite liberação no campo '
			//STR0033 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
			cError := STR0032 + ' "' + AllTrim(GetSx3Cache("QAA_LDOOPE","X3_TITULO")) + '" (QAA_LDOOPE)' + STR0033
		EndIf


		lReturn := Iif(cNivelLaudo == 'G', lLaudGeral                                   , lReturn)
		lReturn := Iif(cNivelLaudo == 'X', lLaudLabor .OR. lLaudOpera .OR. lLaudGeral   , lReturn)
		lReturn := Iif(cNivelLaudo == 'T', lLaudLabor .AND. lLaudOpera .AND. lLaudGeral , lReturn)

		If !lReturn .AND. Empty(cError)
			//STR0032 - 'Acesso negado. Solicite liberação no campo '
			//STR0033 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
			cError := STR0032 + ' "' + AllTrim(GetSx3Cache("QAA_LDOGER","X3_TITULO")) + '" (QAA_LDOGER)' + STR0033
		EndIf
	EndIf

	ErrorBlock(oLastError)

Return lReturn

/*/{Protheus.doc} UsuarioPodeConsultarLaudo
Indica se o usuário pode consultar o  laudo
@author brunno.costa
@since  17/10/2022
@param 01 - cUsuario    , caracter, login do usuário para checagem
@param 02 - cNivelLaudo, caracter, indica o nível para análise:
								L - Laboratório
								O - Operação
								G - Geral
								X - Qualquer
								T - Todos
@param 03 - cError      , caracter, retorna por referência erro na comparação
@return lLaudGeral, lógico, indica se o usuário pode consultar o laudo geral
/*/
Method UsuarioPodeConsultarLaudo(cUsuario, cNivelLaudo, cError) CLASS QIPLaudosEnsaios
	
	Local lLaudGeral := .F.
	Local lLaudLabor := .F.
	Local lLaudOpera := .F.
	Local lReturn    := .T.
	Local oLastError := ErrorBlock({|e| cError := (e:Description) +  Self:oApiManager:CallStack(), Break(e)} )

	Default cNivelLaudo := 'X'

	lLaudLabor := Self:ModoAcessoLaudo(cUsuario, "QAA_LDOLAB") $ "|1|3|" //Inclusão / Edição ou Consulta
	lLaudOpera := Self:ModoAcessoLaudo(cUsuario, "QAA_LDOOPE") $ "|1|3|" //Inclusão / Edição ou Consulta
	lLaudGeral := Self:ModoAcessoLaudo(cUsuario, "QAA_LDOGER") $ "|1|3|" //Inclusão / Edição ou Consulta


	lReturn := Iif(cNivelLaudo == 'L', lLaudLabor                  , lReturn)
	If !lReturn
		//STR0032 - 'Acesso negado. Solicite liberação no campo '
		//STR0033 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
		cError := STR0032 + ' "' + AllTrim(GetSx3Cache("QAA_LDOLAB","X3_TITULO")) + '" (QAA_LDOLAB)' + STR0033
	EndIf


	lReturn := Iif(cNivelLaudo == 'O', lLaudOpera                                  , lReturn)
	If !lReturn .AND. Empty(cError)
		//STR0032 - 'Acesso negado. Solicite liberação no campo '
		//STR0033 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
		cError := STR0032 + ' "' + AllTrim(GetSx3Cache("QAA_LDOOPE","X3_TITULO")) + '" (QAA_LDOOPE)' + STR0033
	EndIf


	lReturn := Iif(cNivelLaudo == 'G', lLaudGeral                                   , lReturn)
	lReturn := Iif(cNivelLaudo == 'X', lLaudLabor .OR. lLaudOpera .OR. lLaudGeral   , lReturn)
	lReturn := Iif(cNivelLaudo == 'T', lLaudLabor .AND. lLaudOpera .AND. lLaudGeral , lReturn)

	If !lReturn .AND. Empty(cError)
		//STR0032 - 'Acesso negado. Solicite liberação no campo '
		//STR0033 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
		cError := STR0032 + ' "' + AllTrim(GetSx3Cache("QAA_LDOGER","X3_TITULO")) + '" (QAA_LDOGER)' + STR0033
	EndIf

	ErrorBlock(oLastError)

Return lReturn

/*/{Protheus.doc} ModoAcessoLaudo
Indica o modo de acesso do usuário a inclusão de laudos
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@param 02 - cCampo , caracter, campo para checagem do modo de acesso
@return cRetorno, caracter, indica o modo de acesso do usuário aos resultados das amostras do QIP:
							1 = Com Acesso;
							2 = Sem Acesso;
							3 = Apenas Consulta
/*/
METHOD ModoAcessoLaudo(cLogin, cCampo) CLASS QIPLaudosEnsaios
     
    Local cAlias   := Nil
    Local cQuery   := Nil
	Local cRetorno := "1"
	Local lExiste  := !Empty(GetSx3Cache(cCampo, "X3_TAMANHO"))
	
	If lExiste
		cQuery :=   " SELECT COALESCE( " + cCampo +", '1') CAMPO "
		cQuery +=   " FROM " + RetSQLName("QAA") + " "
		cQuery +=   " WHERE (D_E_L_E_T_ = ' ') "
		cQuery +=     " AND (QAA_FILIAL = '" + xFilial("QAA") + "') "
		cQuery +=     " AND (UPPER(RTRIM(QAA_LOGIN)) = " + FwQtToChr(AllTrim(Upper(cLogin))) +" ) "

		cAlias := Self:oAPIManager:oQueryManager:executeQuery(cQuery)

		If !Empty((cAlias)->CAMPO)
			cRetorno := Alltrim( (cAlias)->CAMPO )
		EndIf
		
		(cAlias)->(dbCloseArea())
	EndIF

Return cRetorno

/*/{Protheus.doc} SugereParecerLaudo
Sugere Parecer para Laudo
@author brunno.costa
@since 25/10/2022
@param 01 - cNivelLaudo  , caracter, indica o nível de laudo que deseja ser gerado:
									L - Laboratório
									O - Operação
									G - Geral
									LA - Laboratórios Agrupados
									OA - Operações Agrupadas
@param 02 - nRecnoInspecao, número  , recno do registro da QPK relacionado a inspeção 
@param 03 - aOperacoes    , array   , relação de operações para análise - em branco para todas
@param 04 - aLaboratorios , array   , relação de laboratórios para análise - em branco para todos
@param 05 - cUsuario      , caracter, usuário processando a sugestão de parecer
@param 06 - cError        , caracter, retorna por referência erro ocorrido
@return cParecer, lógico, indica se o usuário pode gerar laudo geral
/*/
Method SugereParecerLaudo(cNivelLaudo, nRecnoInspecao, aOperacoes, aLaboratorios, cUsuario, cError) CLASS QIPLaudosEnsaios
	
	Local cOperacao  := ""
	Local cParecer   := "" //Default Ensaio Não Obrigatório Vazio
	Local oLastError := ErrorBlock({|e| cError := (e:Description) +  Self:oApiManager:CallStack(), Break(e)} )

	Default nRecnoInspecao := -1
	Default aOperacoes     := {}
	Default aLaboratorios  := {}
	Default cError         := ""

	Begin Sequence
		
		Self:DefineParecerLaudos()

		If nRecnoInspecao > 0
			Self:cNivelLaudo := cNivelLaudo
			If cNivelLaudo == "L" .OR. cNivelLaudo == "LA"
				cOperacao := Iif(VALTYPE(aOperacoes) == "A",Iif(Len(aOperacoes) > 0, aOperacoes[1], ""),  aOperacoes) 
				cParecer  := Self:SugereParecerLaudosLaboratorios(nRecnoInspecao, cOperacao, cParecer, aLaboratorios, cUsuario, .T., @cError)
			ElseIf cNivelLaudo == "O"
				cParecer := Self:SugereParecerLaudosOperacoes(nRecnoInspecao, aOperacoes, aLaboratorios, cUsuario, @cError, .T.)
			ElseIf cNivelLaudo == "OA"
				cParecer := Self:SugereParecerLaudoGeral(nRecnoInspecao, cUsuario, @cError)
			Else
				cParecer := Self:SugereParecerLaudoGeral(nRecnoInspecao, cUsuario, @cError)
			EndIf
		EndIf
	Recover
		cParecer := self:cPrimeiroReprovado
		cError   := Iif(Empty(cError), STR0002, cError) //"Erro no processo de sugestão de laudo."
	End Sequence 

	ErrorBlock(oLastError)

Return cParecer

/*/{Protheus.doc} SugereParecerLaudosLaboratorios
Sugere Parecer para Laudo(s) Laboratório(s)
@author brunno.costa
@since 25/10/2022
@param 01 - nRecnoInspecao, número  , recno do registro da QPK relacionado a inspeção 
@param 02 - cOperacao     , caracter, operação da inspeção para checagem
@param 03 - cParecer      , caracter, parecer precedente a análise
@param 04 - aLaboratorios , array   , relação de laboratórios para análise - em branco para todos
@param 05 - cUsuario      , caracter, usuário processando a sugestão de parecer
@param 06 - lAnlSeqObr    , lógico  , indica se a análise deve considerar sequência de operação obrigatória
@param 07 - cError        , caracter, retorna por referência erro ocorrido
@return cParecer, lógico, sugestão de paracer para o(s) Laboratório(s)
/*/
Method SugereParecerLaudosLaboratorios(nRecnoInspecao, cOperacao, cParecer, aLaboratorios, cUsuario, lAnlSeqObr, cError) CLASS QIPLaudosEnsaios
	
	Local cAlias          := ""
	Local cCampos         := "*"
	Local cIDEnsaio       := ""
	Local cOrdem          := ""
	Local cParecerLab     := ""
	Local cPriAprovado    := ""
	Local cPriCondicional := ""
	Local cPriPendente    := ""
	Local cPriReprovado   := ""
	Local cPriUrgente     := ""
	Local cTipoOrdem      := "ASC"
	Local lCacheVld       := Nil
	Local nIndiceLabor    := 0
	Local nLaboratorios   := 0
	Local nPagina         := 1
	Local nTamPag         := 999999
	Local oEnsaiosAPI     := EnsaiosInspecaoDeProcessosAPI():New(Nil)
	
	Default cParecer      := ""                  //Default Ensaio Não Obrigatório Vazio
	Default aLaboratorios := {}
	Default lAnlSeqObr    := .T.

	//Faz Cache de Análise de Validação do Fluxo de Permissão para Sugestão de Laudo da Operação
	If (lCacheVld != Nil .And. lCacheVld) .OR. (lCacheVld == Nil .And. (lCacheVld := Self:fluxoValidacaoSequenciaLaudoOperacao(nRecnoInspecao, cOperacao, cUsuario, @cError)))

		nLaboratorios := Len(aLaboratorios)
		If nLaboratorios > 0
			For nIndiceLabor := 1 to nLaboratorios
				
				cAlias      := oEnsaiosAPI:CriaAliasEnsaiosPesquisa(nRecnoInspecao, cOperacao, aLaboratorios[nIndiceLabor], cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario)
				cParecerLab := Self:AvaliaParecerLaboratorio(cAlias, cParecer)
				
				If cParecerLab $ self:cParecerReprovado //Se REPROVADO, encerra a Análise
					cPriReprovado := cParecerLab
					Exit
				EndIf

				cPriAprovado    := Iif(Empty(cPriAprovado   ) .And. cParecerLab $ self:cParecerAprovado   , cParecerLab, cPriAprovado   )
				cPriCondicional := Iif(Empty(cPriCondicional) .And. cParecerLab $ self:cParecerCondicional, cParecerLab, cPriCondicional)
				cPriUrgente     := Iif(Empty(cPriUrgente    ) .And. cParecerLab $ self:cParecerUrgente    , cParecerLab, cPriUrgente    )
				cPriPendente    := Iif(Empty(cPriPendente   ) .And. (cParecerLab == Nil     ;
																.OR. cParecerLab == "PEND"  ;
																.OR. Empty(cParecerLab)   ) , "PEND", cPriPendente )

				(cAlias)->(DbCloseArea())
			Next nIndiceLab
			
			cParecer := Self:SugereParecerSuperior(cParecer, cPriAprovado, cPriReprovado, cPriUrgente, cPriCondicional, cPriPendente, "")	

		Else
			cAlias   := oEnsaiosAPI:CriaAliasEnsaiosPesquisa(nRecnoInspecao, cOperacao, "", cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario)
			cParecer := Self:AvaliaParecerLaboratorio(cAlias, cParecer)
			(cAlias)->(DbCloseArea())
		EndIf

	EndIf

	Self:oApiManager:cErrorMessage := Iif(!Empty(cError) .AND. Empty(cParecer), cError, Self:oApiManager:cErrorMessage)
	Self:oApiManager:lWarningError := Iif(!Empty(cError) .AND. Empty(cParecer), .T.   , Self:oApiManager:lWarningError)

Return cParecer

/*/{Protheus.doc} AvaliaParecerLaboratorio
Avalia Parecer do Laboratório
@author brunno.costa
@since 25/10/2022
@param 01 - cAlias  , caracter, alias com os registros dos Ensaios do laboratório
@param 02 - cParecer, caracter, parecer precedente a análise
@return cParecer, lógico, sugestão de paracer para o Laboratório
/*/
Method AvaliaParecerLaboratorio(cAlias, cParecer) CLASS QIPLaudosEnsaios

	Local cLaudo          := ""
	Local cMedAprovada    := "A"
	Local cMedReprovada   := "R"
	Local cParecerMed     := ""
	Local cPriAprovado    := ""
	Local cPriCondicional := ""
	Local cPriPendente    := ""
	Local cPriReprovado   := ""
	Local cPriUrgente     := ""
	Local cStatus         := ""

	While !(cAlias)->(Eof()) .And. !(cParecer $ self:cParecerReprovado)
		cLaudo        := Iif((cAlias)->QPL_LAUDO == Nil, Nil, AllTrim((cAlias)->QPL_LAUDO))
		cStatus       := Iif((cAlias)->STATUS    == Nil, Nil, Alltrim((cAlias)->STATUS   ))
		
		If cLaudo $ self:cParecerReprovado //Se REPROVADO, encerra a Análise
			cPriReprovado := cLaudo
			Exit
		EndIf

		cPriAprovado    := Iif(Empty(cPriAprovado   ) .And. cLaudo $ self:cParecerAprovado   , cLaudo, cPriAprovado   )
		cPriCondicional := Iif(Empty(cPriCondicional) .And. cLaudo $ self:cParecerCondicional, cLaudo, cPriCondicional)
		cPriUrgente     := Iif(Empty(cPriUrgente    ) .And. cLaudo $ self:cParecerUrgente    , cLaudo, cPriUrgente    )

		If (cAlias)->ENSOBRI == "S" .AND. ((Self:cNivelLaudo == "L" .AND. Empty(cLaudo)) .OR. Empty(cLaudo))
			If !(cStatus $ "|" + self:cParecerAprovado + "|" + self:cParecerReprovado + "|")

				Private cRoteiro := (cAlias)->QP7_CODREC
				QPK->(DbGoTo((cAlias)->RECNOQPK))

				//STR0037 - "Certificar"
				If QP215SkpT((cAlias)->QP7_ENSAIO, (cAlias)->QP7_OPERAC) != OemToAnsi(STR0037)
					cPriReprovado := self:cPrimeiroReprovado                     //Se o ENSAIO é OBRIGATÓRIO e está PENDENTE, considera REPROVADO e encerra a Análise
					cPriPendente  := "PEND"
					Exit

				Else //Certifica Ensaio por Skip-Teste
					cStatus := cMedAprovada

				EndIf
			EndIf
		EndIf

		If cStatus == cMedAprovada .AND. cParecerMed != self:cPrimeiroReprovado  //Se houver MEDIÇÃO aprovada, considera medição APROVADO
			cParecerMed := self:cPrimeiroAprovado
		ElseIf cStatus == cMedReprovada
			cParecerMed := self:cPrimeiroReprovado                               //Se houver MEDIÇÃO reprovada, considera medição REPROVADO
		EndIf
		
		(cAlias)->(DbSkip())
	EndDo 

	cParecer := Self:SugereParecerSuperior(cParecer, cPriAprovado, cPriReprovado, cPriUrgente, cPriCondicional, cPriPendente, cParecerMed)

Return cParecer

/*/{Protheus.doc} SugereParecerLaudosOperacoes
Sugere Parecer para Laudo(s) Operação(ões)
@author brunno.costa
@since 25/10/2022
@param 01 - nRecnoInspecao, número  , recno do registro da QPK relacionado a inspeção 
@param 02 - aOperacoes    , array   , operações relacionadas a inspeção
@param 03 - aLaboratorios , array   , relação de laboratórios para análise - em branco para todos
@param 04 - cUsuario      , caracter, usuário processando a sugestão de parecer
@param 05 - cError        , caracter, retorna por referência erro ocorrido
@param 06 - lSequencia    , lógico  , indica se a análise deve considerar sequência de operação obrigatória
@return cParecer, lógico, sugestão de paracer para a(s) operação(ões)
/*/
Method SugereParecerLaudosOperacoes(nRecnoInspecao, aOperacoes, aLaboratorios, cUsuario, cError, lSequencia) CLASS QIPLaudosEnsaios
	
	Local cOperacao       := ""
	Local cParecer        := "" //Default Ensaio Não Obrigatório Vazio
	Local cParecerLab     := ""
	Local cPriAprovado    := ""
	Local cPriCondicional := ""
	Local cPriPendente    := ""
	Local cPriReprovado   := ""
	Local cPriUrgente     := ""
	Local lCacheVld       := Nil
	Local nIndiceOpe      := 0
	Local nOperacoes      := Len(aOperacoes)

	Default lSequencia    := .F.

	//Ordena Operações em Ordem Decrescente para otimização de lCacheVld := Self:fluxoValidacaoSequenciaLaudoOperacao()
	If lSequencia .And. Len(aOperacoes) > 1
		aOperacoes := aSort(aOperacoes,,, { |x, y| x > y } )
	EndIf

	For nIndiceOpe := 1 to nOperacoes
		
		cOperacao   := aOperacoes[nIndiceOpe]

		//Faz Cache de Análise de Validação do Fluxo de Permissão para Sugestão de Laudo da Operação
		If ( lCacheVld != Nil .And. lCacheVld) .OR.;
		   ( lSequencia .And. lCacheVld == Nil .And. (lCacheVld := Self:fluxoValidacaoSequenciaLaudoOperacao(nRecnoInspecao, cOperacao, cUsuario, @cError)) .OR.;
		   (!lSequencia .And. Self:fluxoValidacaoLaudoOperacao(nRecnoInspecao, cOperacao, cUsuario, @cError) ) )

			cParecerLab := Self:SugereParecerLaudosLaboratorios(nRecnoInspecao, cOperacao, cParecer, aLaboratorios, cUsuario, .F., @cError)

			 //Se REPROVADO, continua análise para avaliar todas as operações em fluxoValidacaoLaudoOperacao
			If cParecerLab $ self:cParecerReprovado
				cPriReprovado := cParecerLab
			EndIf

			cPriAprovado    := Iif(Empty(cPriAprovado   ) .And. cParecerLab $ self:cParecerAprovado   , cParecerLab, cPriAprovado   )
			cPriCondicional := Iif(Empty(cPriCondicional) .And. cParecerLab $ self:cParecerCondicional, cParecerLab, cPriCondicional)
			cPriUrgente     := Iif(Empty(cPriUrgente    ) .And. cParecerLab $ self:cParecerUrgente    , cParecerLab, cPriUrgente    )
			cPriPendente    := Iif(Empty(cPriPendente   ) .And. (    cParecerLab == Nil   ;
															.OR. cParecerLab == "PEND"   ;
															.OR. Empty(cParecerLab)   ) , "PEND", cPriPendente           )
		Else
			Exit
		EndIf
		
	Next nIndiceOpe


	Self:oApiManager:cErrorMessage := Iif(!Empty(cError) .AND. Empty(cParecer), cError, Self:oApiManager:cErrorMessage)
	Self:oApiManager:lWarningError := Iif(!Empty(cError) .AND. Empty(cParecer), .T.   , Self:oApiManager:lWarningError)

	If Empty(Self:oApiManager:cErrorMessage)
		cParecer := Self:SugereParecerSuperior(cParecer, cPriAprovado, cPriReprovado, cPriUrgente, cPriCondicional, cPriPendente, "")
	EndIf

Return cParecer

/*/{Protheus.doc} SugereParecerLaudoGeral
Sugere Parecer para Laudo Geral
@author brunno.costa
@since 25/10/2022
@param 01 - nRecnoInspecao, número  , recno do registro da QPK relacionado a inspeção 
@param 02 - cUsuario      , caracter, usuário processando a sugestão de parecer
@param 03 - cError        , caracter, retorna por referência erro ocorrido
@return cParecer, lógico, sugestão de paracer para a inspeção
/*/
Method SugereParecerLaudoGeral(nRecnoInspecao, cUsuario, cError) CLASS QIPLaudosEnsaios
	
	Local aOperacoes    := {}
	Local cAlias        := ""
	Local cParecer      := ""
	Local oInspecoesAPI := InspecoesDeProcessosAPI():New(Nil)

	cAlias   := oInspecoesAPI:CriaAliasPesquisa(cUsuario, "", "", "", "ASC", 1, 9999, "*", cValToChar(nRecnoInspecao), "") 
	cParecer := Self:AvaliaLaudosOperacoes(cAlias, cParecer)
	(cAlias)->(DbCloseArea())

	If cParecer <> self:cParecerReprovado .AND. cParecer <> self:cParecerAprovado
		aOperacoes := Self:RetornaListaOperacoes(nRecnoInspecao)
		cParecer   := Self:SugereParecerLaudosOperacoes(nRecnoInspecao, aOperacoes, Nil, cUsuario, @cError)
	EndIf

Return cParecer

/*/{Protheus.doc} AvaliaLaudosOperacoes
Avalia Parecer das Operações
@author brunno.costa
@since 25/10/2022
@param 01 - cAlias  , caracter, alias com os registros dos Ensaios do laboratório
@param 02 - cParecer, caracter, parecer precedente a análise
@return cParecer, lógico, sugestão de paracer para o Laboratório
/*/
Method AvaliaLaudosOperacoes(cAlias, cParecer) CLASS QIPLaudosEnsaios

	Local cLaudo          := ""
	Local cPriAprovado    := ""
	Local cPriCondicional := ""
	Local cPriPendente    := ""
	Local cPriReprovado   := ""
	Local cPriUrgente     := ""

	While !(cAlias)->(Eof()) .And. !(cParecer $ self:cParecerReprovado)
		cLaudo          := Iif((cAlias)->QPM_LAUDO == Nil, Nil, AllTriM((cAlias)->QPM_LAUDO))
		
		If cLaudo $ self:cParecerReprovado //Se REPROVADO, encerra a Análise
			cPriReprovado := cLaudo
			Exit
		EndIf

		cPriAprovado    := Iif(Empty(cPriAprovado   ) .And. cLaudo $ self:cParecerAprovado                       , cLaudo, cPriAprovado   )
		cPriCondicional := Iif(Empty(cPriCondicional) .And. cLaudo $ self:cParecerCondicional                    , cLaudo, cPriCondicional)
		cPriUrgente     := Iif(Empty(cPriUrgente    ) .And. cLaudo $ self:cParecerUrgente                        , cLaudo, cPriUrgente    )
		cPriPendente    := Iif(Empty(cPriPendente   ) .And. (    cLaudo == Nil     ;
															.OR. cLaudo == "PEND"  ;
															.OR. Empty(cLaudo)   ) , "PEND"  , cPriPendente )

		(cAlias)->(DbSkip())
	EndDo 

	cParecer := Self:SugereParecerSuperior(cParecer, cPriAprovado, cPriReprovado, cPriUrgente, cPriCondicional, cPriPendente, "")

Return cParecer

/*/{Protheus.doc} fluxoValidacaoSequenciaLaudoOperacao
Fluxo de Validação de Sequência do Laudo por Operação para uso em permissão de geração de laudo ou inclusão de resultados
@author brunno.costa
@since  01/09/2025
@param 01 - nRecnoInspecao, número  , recno do registro da QPK relacionado a inspeção 
@param 02 - cOperacao     , caracter, operação da inspeção para checagem
@param 03 - cUsuario      , caracter, usuário processando a sugestão de parecer
@param 04 - cError        , caracter, retorna por referência erro ocorrido
@return lPermite, lógico, indica se permite prosseguir com a geração do laudo / inclusão de resultados
/*/
Method fluxoValidacaoSequenciaLaudoOperacao(nRecnoInspecao, cOperacao, cUsuario, cError) CLASS QIPLaudosEnsaios

	Local cAliasOperacoes := ""
	Local cOpeAnterior    := Nil
	Local cRoteiro        := ""
	Local lLaudo          := Nil
	Local lOperacao       := Nil
	Local lPermite        := .T.
	Local lSequencia      := Nil
	Local oEnsaiosAPI     := Nil
	Local oInspecoesAPI   := InspecoesDeProcessosAPI()      :New(Self:oWSRestFul)

	cAliasOperacoes := oInspecoesAPI:CriaAliasPesquisa(cUsuario, "", "", "", "", 1, 999999, "*", cValToChar(nRecnoInspecao))

	//Percorre Operacoes da Inspeção
	While lPermite .And. (cAliasOperacoes)->(!Eof())

		cRoteiro     := (cAliasOperacoes)->QQK_CODIGO
		cOpeAnterior := (cAliasOperacoes)->QQK_OPERAC

		//Se operação atual é maior ou igual a operação da inspeção, encerra análise
		If cOpeAnterior >= cOperacao
			Exit
		EndIf

		//Retorna Obrigatoriedades da Operação
		If lLaudo == Nil
			Self:retornaObrigatoriedadesOperacao((cAliasOperacoes)->QPK_PRODUT, (cAliasOperacoes)->QPK_REVI, (cAliasOperacoes)->QQK_CODIGO,  cOpeAnterior, @lSequencia, @lLaudo, @lOperacao)
		EndIf

		//Sequencia de Operação Obrigatória (QQK_SEQ_OB == "S")
		If lSequencia 

			//Se operação não tem laudo
			If Empty((cAliasOperacoes)->QPM_LAUDO)
				
				//Operação com Laudo Obrigatório (QQK_LAU_OB == "S")
				If lLaudo

					lPermite := .F.
					//STR0038 - "Operação"
					//STR0039 - "está parametrizada com Laudo Obrigatório na Especificação do Produto. Para seguir, é necessário incluir um Laudo de Operação."
					cError   := STR0038 + " '" + AllTrim(cOpeAnterior) + " - " + Capital(AllTrim((cAliasOperacoes)->QQK_DESCRI)) +  "' " + STR0039
					Exit

				Else
					
					lPermite := Self:fluxoAnaliseTodosOsLaboratoriosOperacao(nRecnoInspecao, cOpeAnterior, cUsuario, oEnsaiosAPI, @cError, lSequencia, Capital(AllTrim((cAliasOperacoes)->QQK_DESCRI)))

				EndIf

			EndIf

		EndIf
		
		(cAliasOperacoes)->(DbSkip())
	EndDo

	(cAliasOperacoes)->(DbCloseArea())

Return lPermite

/*/{Protheus.doc} fluxoValidacaoLaudoOperacao
Fluxo de Validação do Laudo por Operação para uso em permissão de geração de laudo ou inclusão de resultados
@author brunno.costa
@since  01/09/2025
@param 01 - nRecnoInspecao, número  , recno do registro da QPK relacionado a inspeção 
@param 02 - cOperacao     , caracter, operação da inspeção para checagem
@param 03 - cUsuario      , caracter, usuário processando a sugestão de parecer
@param 04 - cError        , caracter, retorna por referência erro ocorrido
@return lPermite, lógico, indica se permite prosseguir com a geração do laudo / inclusão de resultados
/*/
Method fluxoValidacaoLaudoOperacao(nRecnoInspecao, cOperacao, cUsuario, cError) CLASS QIPLaudosEnsaios

	Local cAliasOperacoes := ""
	Local cRoteiro        := ""
	Local lLaudo          := Nil
	Local lOperacao       := Nil
	Local lPermite        := .T.
	Local lSequencia      := Nil
	Local oEnsaiosAPI     := Nil
	Local oInspecoesAPI   := InspecoesDeProcessosAPI()      :New(Self:oWSRestFul)

	//Retorna Dados da Inspeção
	cAliasOperacoes := oInspecoesAPI:CriaAliasPesquisa(cUsuario, "", "", "", "", 1, 999999, "*", cValToChar(nRecnoInspecao), cOperacao)
	If (cAliasOperacoes)->(!Eof())

		cRoteiro     := (cAliasOperacoes)->QQK_CODIGO

		//Retorna Obrigatoriedades da Operação
		If lLaudo == Nil
			Self:retornaObrigatoriedadesOperacao((cAliasOperacoes)->QPK_PRODUT, (cAliasOperacoes)->QPK_REVI, (cAliasOperacoes)->QQK_CODIGO,  cOperacao, @lSequencia, @lLaudo, @lOperacao)
		EndIf

		//Se operação não tem laudo
		If Empty((cAliasOperacoes)->QPM_LAUDO)
			
			//Operação com Laudo Obrigatório (QQK_LAU_OB == "S")
			If lLaudo

				lPermite := .F.
				//STR0038 - "Operação"
				//STR0039 - "está parametrizada com Laudo Obrigatório na Especificação do Produto. Para seguir, é necessário incluir um Laudo de Operação."
				cError   := STR0038 + " '" + AllTrim(cOperacao) + " - " + Capital(AllTrim((cAliasOperacoes)->QQK_DESCRI)) + "' " + STR0039

			Else
				
				//Operação Obrigatória (QQK_OPE_OB == "S")
				If lOperacao

					lPermite := Self:fluxoAnaliseTodosOsLaboratoriosOperacao(nRecnoInspecao, cOperacao, cUsuario, oEnsaiosAPI, @cError, .F., Capital(AllTrim((cAliasOperacoes)->QQK_DESCRI)))

				EndIf

			EndIf

		EndIf
		
	EndIf

	(cAliasOperacoes)->(DbCloseArea())

Return lPermite

/*/{Protheus.doc} retornaObrigatoriedadesOperacao
Retorna Obrigatoriedades da Operação por referência
@author brunno.costa
@since  01/09/2025
@param 01 - cProduto   , caracter, código do produto
@param 02 - cRevisao   , caracter, revisão do produto
@param 03 - cRoteiro   , caracter, código do roteiro
@param 04 - cOperacao  , caracter, código da operação
@param 05 - lSequencia , lógico  , retorna por referência se a operação possui sequência obrigatória - QQK_SEQ_OB == "S"
@param 06 - lLaudo     , lógico  , retorna por referência se a operação possui laudo obrigatório - QQK_LAU_OB == "S"
@param 07 - lOperacao  , lógico  , retorna por referência se a operação é obrigatória - QQK_OPE_OB == "S"
/*/
Method retornaObrigatoriedadesOperacao(cProduto, cRevisao, cRoteiro, cOperacao, lSequencia, lLaudo, lOperacao) CLASS QIPLaudosEnsaios

	QQK->(dbSetOrder(1))
	QQK->(dbSeek(xFilial("QQK")+cProduto+cRevisao+cRoteiro+cOperacao))

	lSequencia := QQK->QQK_SEQ_OB == "S"
	lLaudo     := QQK->QQK_LAU_OB == "S"
	lOperacao  := QQK->QQK_OPE_OB == "S"

Return 

/*/{Protheus.doc} todosOsLaboratoriosOperacaoComLaudo
Indica se a operação possui laudo
@author brunno.costa
@since  01/09/2025
@param 01 - cAlias, caracter, alias com os registros dos Ensaios do laboratório
@return lLaudos, lógico, indica se todos os laboratórios da operação possuem laudo
/*/
Method todosOsLaboratoriosOperacaoComLaudo(cAlias) CLASS QIPLaudosEnsaios

	Local lLaudos := .T.

	(cAlias)->(DbGoTop())
	While (cAlias)->(!Eof())
		If Empty((cAlias)->QPL_LAUDO)
			lLaudos := .F.
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo

Return lLaudos

/*/{Protheus.doc} fluxoAnaliseTodosOsLaboratoriosOperacao
Fluxo de Análise de Obrigatoriedades de Todos os Laboratórios da Operação para uso em permissão de geração de laudo ou inclusão de resultados
@author brunno.costa
@since  01/09/2025
@param 01 - nRecnoInspecao, número  , recno do registro da QPK relacionado a inspeção
@param 02 - cOpeAnterior , caracter, operação da inspeção para checagem
@param 03 - cUsuario     , caracter, usuário processando a sugestão de parecer
@param 04 - oEnsaiosAPI  , objeto  , instância da API de Ensaios - em branco para nova instância
@param 05 - cError       , caracter, retorna por referência erro ocorrido
@param 06 - lSequencia   , lógico  , indica se a análise deve considerar sequência de operação obrigatória
@param 07 - cDescOper    , caracter, descrição da operação
@return lPermite, lógico, indica se permite prosseguir com a geração do laudo / inclusão de resultados
/*/
Method fluxoAnaliseTodosOsLaboratoriosOperacao(nRecnoInspecao, cOpeAnterior, cUsuario, oEnsaiosAPI, cError, lSequencia, cDescOper) CLASS QIPLaudosEnsaios

	Local cAliasEnsaios := ""
	Local cEnsPend      := ""
	Local lEnsObr       := Nil
	Local lEnsOK        := Nil
	Local lPermite      := .T.

	oEnsaiosAPI   := Iif(oEnsaiosAPI == Nil, EnsaiosInspecaoDeProcessosAPI():New(Self:Self:oWSRestFul), oEnsaiosAPI)
	cAliasEnsaios := oEnsaiosAPI:CriaAliasEnsaiosPesquisa(nRecnoInspecao, cOpeAnterior, "", "", "", 1, 999999, "*", "", cUsuario)
	
	//Se algum laboratório da operação não tem Laudo
	If !Self:todosOsLaboratoriosOperacaoComLaudo(cAliasEnsaios)

		Self:avaliaObrigatoriedadeEnsaiosDaOperacao(cAliasEnsaios, @lEnsObr, @lEnsOK, @cEnsPend)

		//Se tem algum ensaio obrigatório 
		If lEnsObr
		
			//Se algum ensaio obrigatório está pendente
			If !lEnsOK

				lPermite := .F.
				//STR0038 - "Operação"
				//STR0040 - "está parametrizada com Ensaios Obrigatórios na Especificação do Produto. Para seguir, é necessário preencher os ensaios:"
				cError   := STR0038 + " '" + AllTrim(cOpeAnterior) + " - " + cDescOper + "' " + STR0040 + " " + AllTrim(cEnsPend) + "."

			EndIf

		Else

			lPermite := .F.
			//STR0038 - "Operação"
			//STR0041 - "está parametrizada com Sequência Obrigatória na Especificação do Produto. Para seguir, é necessário incluir um Laudo de Operação ou de Laboratório."
			//STR0042 - "está parametrizada com Operação Obrigatória na Especificação do Produto. Para seguir, é necessário incluir um Laudo de Operação ou de Laboratório."
			cError   := STR0038 + " '" + AllTrim(cOpeAnterior) + " - " + cDescOper + "' " + Iif(lSequencia, STR0041, STR0042) 

		EndIf

	EndIf

	(cAliasEnsaios)->(DbCloseArea())
	
Return lPermite

/*/{Protheus.doc} avaliaObrigatoriedadeEnsaiosDaOperacao
Avalia a obrigatoriedade dos ensaios da operação
@author brunno.costa
@since  01/09/2025
@param 01 - cAlias  , caracter, alias com os registros dos Ensaios do laboratório 	
@param 02 - lEnsObr , lógico  , retorna por referência se tem ensaio obrigatório
@param 03 - lEnsOK  , lógico  , retorna por referência se todos os ensaios obrigatórios possuem resultados
@param 04 - cEnsPend, caracter, retorna por referência a lista de ensaios pendentes
/*/
Method avaliaObrigatoriedadeEnsaiosDaOperacao(cAlias, lEnsObr, lEnsOK, cEnsPend) CLASS QIPLaudosEnsaios

	cEnsPend := ""

	(cAlias)->(DbGoTop())
	While (cAlias)->(!Eof())
		
		//Se ensaio obrigatório
		If (cAlias)->ENSOBRI == "S"
			lEnsObr   := .T.
		EndIf

		//Se ensaio obrigatório e está pendente
		If (cAlias)->STATUS == "P"
			lEnsOK := .F.
			cEnsPend += Iif(Empty(cEnsPend), "", ", ") + AllTrim((cAlias)->QP7_ENSAIO)
			If lEnsObr
				Exit
			EndIf
		EndIf

		(cAlias)->(DbSkip())
	EndDo

	lEnsObr := Iif(lEnsObr == Nil, .F., lEnsObr) //Se não encontrou nenhum ensaio obrigatório, considera que não tem
	lEnsOK  := Iif(lEnsOK  == Nil, .T., lEnsOK ) //Se não encontrou nenhum ensaio obrigatório pendente, considera que todos estão OK

Return 


/*/{Protheus.doc} RetornaListaOperacoes
Retorna Lista de Operações Relacionadas a Inspeção
@author brunno.costa
@since  25/10/2022
@param 01 - nRecnoInspecao, número  , recno do registro da QPK relacionado a inspeção 
@return aOperacoes, array, relação de operações relacionadas a inspeção
/*/
Method RetornaListaOperacoes(nRecnoInspecao) CLASS QIPLaudosEnsaios
	
	Local aOperacoes := {}
	Local cAlias     := ""
	Local cQuery     := ""

	Default nRecnoInspecao := -1

	If nRecnoInspecao > 0
		cQuery += " SELECT DISTINCT QP7_OPERAC
		cQuery += "  FROM  "
		cQuery +=  " (SELECT QPK_PRODUT, QPK_REVI  "
		cQuery += "  FROM " + RetSQLName("QPK")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "
		cQuery +=    " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
		cQuery +=  " ) QPK INNER JOIN  "
		cQuery +=  " (SELECT QP7_PRODUT, QP7_REVI, QP7_OPERAC  "
		cQuery += "  FROM " + RetSQLName("QP7")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP7_FILIAL = '"+xFilial("QP7")+"')  "
		cQuery += "  UNION  "
		cQuery += "  SELECT QP8_PRODUT, QP8_REVI, QP8_OPERAC  "
		cQuery += "  FROM " + RetSQLName("QP8")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QP8_FILIAL = '"+xFilial("QP8")+"')  ) ENSAIOS "
		cQuery += " ON   QPK_PRODUT = QP7_PRODUT "
		cQuery +=  " AND QPK_REVI   = QP7_REVI "

		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		While (cAlias)->(!Eof())
			aAdd(aOperacoes, (cAlias)->QP7_OPERAC)
			(cAlias)->(DbSkip())
		EndDo
		(cAlias)->(DbCloseArea())
	EndIf

Return aOperacoes


/*/{Protheus.doc} BuscaDataDeValidadeDoLaudo
Busca uma data de validade para sugerir na tela do laudo
@author rafael.hesse
@since  25/10/2022
@param 01 - cProductID, numerico, produto da inspeção
@param 02 - cSpecificationVersion, caracter, Revisão do produto
@return dDataVal, date, indica a data de validade que será sugerido
/*/
Method BuscaDataDeValidadeDoLaudo(cProductID, cSpecificationVersion) CLASS QIPLaudosEnsaios
	Local dDataVal := ""
	Local nDias    := 0
	Local oQltAPIManager := QualityAPIManager():New(nil, Self:oWSRestFul)

	If !(cProductID == Nil .And. cSpecificationVersion == Nil)
		DbSelectArea("QP6")
		QP6->(DbSetOrder(2))
		If QP6->(dbSeek(xFilial("QP6")+PADR( cProductID, oQltAPIManager:GetSx3Cache('QP6_PRODUT', 'X3_TAMANHO'))+cSpecificationVersion))
			If QP6->QP6_SHLF > 0
				DO Case
					Case QP6->QP6_TPSLIF == "1"
						nDias := QP6->QP6_SHLF
					Case QP6->QP6_TPSLIF == "2"
						nDias := QP6->QP6_SHLF * 30
					Case QP6->QP6_TPSLIF == "3"
						nDias := Int(QP6->QP6_SHLF / 24)
					Case QP6->QP6_TPSLIF == "4"
						nDias := QP6->QP6_SHLF * 365
				EndCase
				dDataVal := dDataBase + nDias
			EndIf
		EndIf
	EndIf

Return dDataVal

/*/{Protheus.doc} ValidaDataDeValidadeDoLaudo
Verifica se a data de validade do Laudo é valida
@author rafael.hesse
@since  25/10/2022
@param 01 - dDateShelfLife, date, data a ser validada.
@param 02 - cReportSelected, String, descrição do laudo.
@param 03 - cError, String, mensagem de erro que será passada por referencia.
@return lReturn, lógico, indica se a data é válida ou não.
/*/
Method ValidaDataDeValidadeDoLaudo(dShelfLife, cReportSelected, cError) CLASS QIPLaudosEnsaios
	Local lReturn        := .T.

	If !Empty(Alltrim(StrTran(cReportSelected,"'","")))
		If !Empty(dShelfLife) .And. dShelfLife < dDataBase
			lReturn := .F.
			cError  := STR0003 //"A data de validade do laudo não pode ser menor que a data atual"
		EndIf
	Else
		lReturn := .F.
		cError  := STR0004 //"Informe primeiro o parecer do Laudo para depois digitar a data de validade"
	EndIf

Return lReturn

/*/{Protheus.doc} GravaLaudoGeral
Grava Laudo Geral
@author brunno.costa
@since  01/11/2022
@param 01 - cUsuario  , caracter, Login do usuário
@param 02 - nRecnoQPK , número  , recno da inspeção relacionada na QPK
@param 03 - cRoteiro  , caracter, roteiro relacionado
@param 04 - cParecer  , caracter, parecer do laudo.
@param 05 - cJustifica, caracter, justificativa de alteração da sugestão de parecer do laudo
@param 06 - nRejeicao , número  , quantidade rejeitada
@param 07 - cValidade , caracter, data de validade do laudo no formato JSON
@param 08 - lBaixaCQ , Logico, indica se o usuário deseja realizar a movimentação do estoque CQ.
@return lSucesso, lógico, indica se conseguiu realizar a gravação
/*/
Method GravaLaudoGeral(cUsuario, nRecnoQPK, cRoteiro, cParecer, cJustifica, nRejeicao, cValidade, lBaixaCQ) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL         := xFilial("QPL")
	Local lInclui         := Nil
	Local lSucesso        := .T.
	Local nRecnoQPL       := -1
	Local oLastError      := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0005), Break(e)}) //"Falha na gravação do Laudo Geral"
	Local oObj            := Nil
	Local oQIPA215Estoque := Nil

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default cParecer   := self:cPrimeiroReprovado
	Default cValidade  := ""
	Default nRejeicao  := 0
	Default cJustifica := ""

	//Força passagem por MATXALC para popular variável Static cRetCodUsr - DMANQUALI-9983 - DBRUnlock cannot be called in a transaction
	PCPDocUser(RetCodUsr(cUsuario))

	Begin Transaction
		Begin Sequence
			DbSelectArea("QPK")
			lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)

			If lSucesso .AND. !QPK->(Eof())

				dbSelectArea("QPL")
				QPL->(dbSetOrder(3))
				lInclui := !QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+Space(GetSX3Cache("QPL_OPERAC", "X3_TAMANHO"))+Space(GetSX3Cache("QPL_LABOR", "X3_TAMANHO"))))

				RecLock("QPL", lInclui)
				QPL->QPL_FILIAL	:= cFiLQPL
				QPL->QPL_PRODUT	:= QPK->QPK_PRODUT
				QPL->QPL_DTENTR	:= QPK->QPK_EMISSA
				QPL->QPL_LOTE	:= QPK->QPK_LOTE
				QPL->QPL_OP 	:= QPK->QPK_OP
				QPL->QPL_OPERAC	:= Space(02)
				QPL->QPL_ROTEIR := cRoteiro
				QPL->QPL_NUMSER := QPK->QPK_NUMSER
				
				QPL->QPL_TAMLOT := cValToChar(QPK->QPK_TAMLOT)
				QPL->QPL_QTREJ  := cValToChar(nRejeicao)

				QPL->QPL_LAUDO  := cParecer
				QPL->QPL_JUSTLA := cJustifica
				QPL->QPL_DTVAL  := Self:oAPIManager:FormataDado("D", cValidade, "1", 8)

				If Empty(QPL->QPL_DTENLA)
					QPL->QPL_DTENLA := dDataBase
					QPL->QPL_HRENLA := Time()
				EndIf

				QPL->QPL_DTLAUD := dDataBase
				QPL->QPL_HRLAUD := Time()
				MsUnLock()

				RecLock("QPK", .F.)
				QPK->QPK_LAUDO := QPL->QPL_LAUDO
				MsUnLock()

				nRecnoQPL := QPL->(Recno())

				If lBaixaCQ
					If FindClass("QIPA215Estoque")
						oQIPA215Estoque := QIPA215Estoque():New(-1)
						If !oQIPA215Estoque:validaPermissaoDeAcessoLiberacaoMATA175()
							lBaixaCQ := .F.
							lSucesso := .F.
						EndIf
					EndIf
				EndIf
				
				If lBaixaCq
					lBaixaCq := Self:MovimentaEstoqueCQ(nRecnoQPK, cUsuario)
				EndIf

				Self:AtualizaFlagLegendaInspecao(cParecer,.F.,lBaixaCQ)
				Self:AtualizaCertificadoDaQualidade(.F.)
				Self:GravaAssinaturaGeral(cUsuario, cParecer, QPK->QPK_OP)

				If Self:oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIP")
					oObj             := JsonObject():New()
					oObj["login"   ] := cUsuario
					oObj["recnoQPL"] := nRecnoQPL
					oObj["insert"  ] := lInclui
					oObj["update"  ] := !lInclui
					oObj["laudo"   ] := 'geral'
					Execblock('QIPINTAPI',.F.,.F.,{oObj, "processinspectiontestreports/api/qip/v1/savegeneralreport", "QIPLaudosEnsaios", "complementoLaudo"})
				EndIf

			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} GravaLaudoLaboratorio
Grava Laudo de Laboratório
@author brunno.costa
@since  02/11/2022
@param 01 - cUsuario    , caracter, Login de usuário
@param 02 - nRecnoQPK   , número  , recno da inspeção relacionada na QPK
@param 03 - cRoteiro    , caracter, roteiro relacionado
@param 04 - cOperacao   , caracter, operação relacionada
@param 05 - cLaboratorio, caracter, recno da inspeção relacionada na QPK
@param 06 - cParecer    , caracter, parecer do laudo.
@param 07 - cJustifica  , caracter, justificativa de alteração da sugestão de parecer do laudo
@param 08 - nRejeicao   , número  , quantidade rejeitada
@param 09 - cValidade   , caracter, data de validade do laudo no formato JSON
@return lSucesso, lógico, indica se conseguiu realizar a gravação
/*/
Method GravaLaudoLaboratorio(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, cParecer, cJustifica, nRejeicao, cValidade) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL    := xFilial("QPL")
	Local lSucesso   := .T.
	Local nRecnoQPL  := Nil
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0008), Break(e)}) //"Falha na gravação do Laudo de Laboratório"
	Local oObj       := Nil

	Default nRecnoQPK    := -1
	Default cLaboratorio := "LABFIS"
	Default cRoteiro     := "01"
	Default cParecer     := self:cPrimeiroReprovado
	Default cValidade    := ""
	Default nRejeicao    := 0
	Default cJustifica   := ""

	Begin Transaction
		Begin Sequence
			DbSelectArea("QPK")
			lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
			If lSucesso .AND. !QPK->(Eof())
				dbSelectArea("QPL")
				QPL->(dbSetOrder(3))
				lInclui := !QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+cOperacao+cLaboratorio))
				
				RecLock("QPL", lInclui)
				QPL->QPL_FILIAL	:= cFiLQPL
				QPL->QPL_PRODUT	:= QPK->QPK_PRODUT
				QPL->QPL_DTENTR	:= QPK->QPK_EMISSA
				QPL->QPL_LOTE	:= QPK->QPK_LOTE
				QPL->QPL_OP 	:= QPK->QPK_OP
				QPL->QPL_NUMSER := QPK->QPK_NUMSER

				QPL->QPL_ROTEIR := cRoteiro
				QPL->QPL_OPERAC	:= cOperacao
				QPL->QPL_LABOR	:= cLaboratorio
				
				QPL->QPL_TAMLOT := cValToChar(QPK->QPK_TAMLOT)
				QPL->QPL_QTREJ  := cValToChar(nRejeicao)

				QPL->QPL_LAUDO  := cParecer
				QPL->QPL_JUSTLA := cJustifica
				QPL->QPL_DTVAL  := Self:oAPIManager:FormataDado("D", cValidade, "1", 8)


				If Empty(QPL->QPL_DTENLA)
					QPL->QPL_DTENLA := dDataBase
					QPL->QPL_HRENLA := Time()
				EndIf

				QPL->QPL_DTLAUD := dDataBase
				QPL->QPL_HRLAUD := Time()
				MsUnLock()

				nRecnoQPL := QPL->(Recno())

				Self:GravaAssinaturaLaboratorio(cUsuario, cParecer, QPK->QPK_OP, cLaboratorio, cOperacao)

				If Self:oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIP")
					oObj             := JsonObject():New()
					oObj["login"   ] := cUsuario
					oObj["recnoQPL"] := nRecnoQPL
					oObj["insert"  ] := lInclui
					oObj["update"  ] := !lInclui
					oObj["laudo"   ] := 'laboratorio'
					Execblock('QIPINTAPI',.F.,.F.,{oObj, "processinspectiontestreports/api/qip/v1/savelaboratoryreport", "QIPLaudosEnsaios", "complementoLaudo"})
				EndIf

			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} GravaLaudoOperacao
Grava Laudo de Operação
@author brunno.costa
@since  02/11/2022
@param 01 - cUsuario    , caracter, Login de usuário
@param 02 - nRecnoQPK   , número  , recno da inspeção relacionada na QPK
@param 03 - cRoteiro    , caracter, roteiro relacionado
@param 04 - cOperacao   , caracter, operação relacionada
@param 05 - cParecer    , caracter, parecer do laudo.
@param 06 - cJustifica  , caracter, justificativa de alteração da sugestão de parecer do laudo
@param 07 - nRejeicao   , número  , quantidade rejeitada
@param 08 - cValidade   , caracter, data de validade do laudo no formato JSON
@return lSucesso, lógico, indica se conseguiu realizar a gravação
/*/
Method GravaLaudoOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cParecer, cJustifica, nRejeicao, cValidade) CLASS QIPLaudosEnsaios
	
	Local cFiLQPM    := xFilial("QPM")
	Local lInclui    := Nil
	Local lSucesso   := .T.
	Local nRecnoQPM  := Nil
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0009), Break(e)}) //"Falha na gravação do Laudo de Operação"
	Local oObj       := Nil

	Default nRecnoQPK    := -1
	Default cRoteiro     := "01"
	Default cParecer     := self:cPrimeiroReprovado
	Default cValidade    := ""
	Default nRejeicao    := 0
	Default cJustifica   := ""

	Begin Transaction
		Begin Sequence
			DbSelectArea("QPK")
			lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
			If lSucesso .AND. !QPK->(Eof())

				dbSelectArea("QPM")
				QPM->(dbSetOrder(3))
				lInclui := !QPM->(dbSeek(cFiLQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+cOperacao))
				
				RecLock("QPM", lInclui)
				QPM->QPM_FILIAL	:= cFiLQPM
				QPM->QPM_PRODUT	:= QPK->QPK_PRODUT
				QPM->QPM_DTPROD	:= QPK->QPK_EMISSA
				QPM->QPM_LOTE	:= QPK->QPK_LOTE
				QPM->QPM_OP 	:= QPK->QPK_OP
				QPM->QPM_NUMSER := QPK->QPK_NUMSER

				QPM->QPM_ROTEIR := cRoteiro
				QPM->QPM_OPERAC	:= cOperacao
				
				QPM->QPM_TAMLOT := cValToChar(QPK->QPK_TAMLOT)
				QPM->QPM_QTREJ  := cValToChar(nRejeicao)

				QPM->QPM_LAUDO  := cParecer
				QPM->QPM_JUSTLA := cJustifica
				QPM->QPM_DTVAL  := Self:oAPIManager:FormataDado("D", cValidade, "1", 8)


				If Empty(QPM->QPM_DTENLA)
					QPM->QPM_DTENLA := dDataBase
					QPM->QPM_HRENLA := Time()
				EndIf

				QPM->QPM_DTLAUD := dDataBase
				QPM->QPM_HRLAUD := Time()
				MsUnLock()

				nRecnoQPM := QPM->(Recno())

				Self:GravaAssinaturaOperacao(cUsuario, cParecer, QPK->QPK_OP, cOperacao)

				If Self:oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIP")
					oObj             := JsonObject():New()
					oObj["login"   ] := cUsuario
					oObj["recnoQPM"] := nRecnoQPM
					oObj["insert"  ] := lInclui
					oObj["update"  ] := !lInclui
					oObj["laudo"   ] := 'operacao'
					Execblock('QIPINTAPI',.F.,.F.,{oObj, "processinspectiontestreports/api/qip/v1/saveoperationreport", "QIPLaudosEnsaios", "complementoLaudo"})
				EndIf
			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} AtualizaFlagLegendaInspecao
Atualiza FLAG de legenda da inspeção - QPK_SITOP
@author brunno.costa
@since  01/11/2022
@param 01 - cParecer  , caracter, parecer do laudo.
@param 02 - lMedicao  , logico  , indica se a inspeção possui medição
@param 03 - lMovimentouEstoque, lógico  , indica se a inspeção movimentou estoque CQ
@param 04 - cLogin            , caracter, login do usuário
/*/
Method AtualizaFlagLegendaInspecao(cParecer, lMedicao, lMovimentouEstoque, cLogin) CLASS QIPLaudosEnsaios
		Local aAreaSC2        := SC2->(GetArea())
		Local cQPKSITOP       := ""
		Local lLaudoParcial   := .F.
		Local lQPKLDAUTO      := !Empty(GetSx3Cache("QPK_LDAUTO","X3_CAMPO"))
		Local oQIPA215Aux     := Nil
		Local oQIPA215Estoque := Nil

		Default lMedicao 		   := .F.
		Default lMovimentouEstoque := .T.

		If !lMovimentouEstoque
			If FindClass("QIPA215Estoque")
				oQIPA215Estoque := QIPA215Estoque():New(-1)
				If oQIPA215Estoque:lIntegracaoEstoqueHabilitada
					cQPKSITOP := "6" //Movimentacao de estoque pendente
				EndIf
			EndIf
		EndIf

		dbSelectArea("SC2")
		SC2->(dbSetOrder(1))
		SC2->(dbSeek(xFilial("SC2")+QPK->QPK_OP))
		If FindClass("QIPA215AuxClass")
			oQIPA215Aux := QIPA215AuxClass():New()
			lLaudoParcial := oQIPA215Aux:possuiLaudoParcialSemLaudoGeral(SC2->C2_ROTEIRO, cLogin)
		EndIf

		RestArea(aAreaSC2)

		If Empty(self:cParecerAprovado)
			Self:DefineParecerLaudos()
		EndIf

		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 lLaudoParcial                      , "7", cQPKSITOP) //Tem laudo parcial (operação ou laboratório sem geral)
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 lMedicao	                        , "1", cQPKSITOP) //Tem medição e não tem laudo
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 cParecer $ self:cParecerAprovado   , "2", cQPKSITOP) //Aprovado
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 cParecer $ self:cParecerReprovado  , "3", cQPKSITOP) //Reprovado
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 cParecer $ self:cParecerUrgente    , "4", cQPKSITOP) //Urgente
		cQPKSITOP := Iif(Empty(cQPKSITOP) .AND. 	 cParecer $ self:cParecerCondicional, "5", cQPKSITOP) //Condicional
		

		RecLock("QPK", .F.)

			QPK->QPK_SITOP := cQPKSITOP
			If lQPKLDAUTO
				QPK->QPK_LDAUTO := "0"
			EndIf

		QPK->(MSUnLock())
Return

/*/{Protheus.doc} AtualizaCertificadoDaQualidade
Atualiza Código do Certificado da Qualidade
@author brunno.costa
@since  01/11/2022
@param 01 - lDesvincular, lógico, indica se deve vincular (.F.) ou desvincular (.T.)
/*/
Method AtualizaCertificadoDaQualidade(lDesvincular) CLASS QIPLaudosEnsaios
	Default lDesvincular := .F.
	RecLock("QPK", .F.)
		If lDesvincular
			QPK->QPK_CERQUA := ""
		Else
		If Empty(QPK->QPK_CERQUA) .AND. !Empty(QPK->QPK_SITOP)
			QPK->QPK_CERQUA := QA_SEQUSX6("QIP_CEQU",TamSX3("C2_CERQUA")[1],"S", STR0007) //"Certificado Qualidade"
		EndIf
	EndIf
	QPK->(MSUnLock())
Return

/*/{Protheus.doc} RetornaLaudoGeral
Retorna Laudo Geral
@author brunno.costa
@since  05/11/2022
@param 01 - nRecnoQPK , número  , recno da inspeção relacionada na QPK
@param 02 - cRoteiro  , caracter, roteiro selecionado
@return oLaudo, json, objeto json com:
					  hasReport       , lógico  , indica se possui laudo geral
					  reportLevel     , caracter, indica o nível do laudo geral:
												G - Geral
					  reportSelected  , caracter, parecer do laudo
					  justification   , caracter, justificativa de alteração da sugestão de parecer do laudo
					  rejectedQuantity, número  , quantidade rejeitada
					  shelfLife       , data    , data de validade do laudo no formato JSON
/*/ 
Method RetornaLaudoGeral(nRecnoQPK, cRoteiro) CLASS QIPLaudosEnsaios
	
	Local oLaudo     := JsonObject():New()
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0010)}) //"Falha na consulta do Laudo Geral"

	Default nRecnoQPK  := -1
	Default cRoteiro   := Space(GetSX3Cache("QPL_ROTEIR", "X3_TAMANHO"))

	oLaudo['hasReport'] := .F.

	DbSelectArea("QPK")
	Self:ValidaRecnoValidoQPK(nRecnoQPK)
	If !QPK->(Eof())
		dbSelectArea("QPL")
		QPL->(dbSetOrder(3))
		If Empty(cRoteiro)
			If QPL->(dbSeek(xFilial("QPL")+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)))
				cRoteiro := QPL->QPL_ROTEIR
			EndIf
		EndIf
		If QPL->(dbSeek(xFilial("QPL")+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+Space(GetSX3Cache("QPL_OPERAC", "X3_TAMANHO"))+Space(GetSX3Cache("QPL_LABOR", "X3_TAMANHO"))))
			If !Empty(QPL->QPL_LAUDO)
				oLaudo['hasReport']        := .T.
				oLaudo['reportLevel']      := "G"
				oLaudo['rejectedQuantity'] := QPL->QPL_QTREJ
				oLaudo['reportSelected']   := QPL->QPL_LAUDO
				oLaudo['justification']    := QPL->QPL_JUSTLA
				oLaudo['shelfLife']        := QPL->QPL_DTVAL
			EndIf
		EndIf
	EndIf

	ErrorBlock(oLastError)
	
Return oLaudo

/*/{Protheus.doc} RetornaLaudoLaboratorio
Retorna Laudo do Laboratório
@author brunno.costa
@since  05/11/2022
@param 01 - nRecnoQPK   , número  , recno da inspeção relacionada na QPK
@param 02 - cRoteiro    , caracter, roteiro relacionado
@param 03 - cOperacao   , caracter, operação relacionada
@param 04 - cLaboratorio, caracter, recno da inspeção relacionada na QPK
@return oLaudo, json, objeto json com:
					  hasReport       , lógico  , indica se possui laudo de laboratório ou laudo geral
					  reportLevel     , caracter, indica o nível do laudo de laboratório:
												L - Laboratório
					  reportSelected  , caracter, parecer do laudo
					  justification   , caracter, justificativa de alteração da sugestão de parecer do laudo
					  rejectedQuantity, número  , quantidade rejeitada
					  shelfLife       , data    , data de validade do laudo no formato JSON
/*/
Method RetornaLaudoLaboratorio(nRecnoQPK, cRoteiro, cOperacao, cLaboratorio) CLASS QIPLaudosEnsaios
	
	Local oLaudo     := JsonObject():New()
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0011)}) //"Falha na consulta do Laudo de Laboratório"

	Default nRecnoQPK    := -1
	Default cRoteiro     := "01"
	Default cOperacao    := "01"
	Default cLaboratorio := "LABFIS"

	oLaudo['hasReport'] := .F.

	DbSelectArea("QPK")
	Self:ValidaRecnoValidoQPK(nRecnoQPK)
	If !QPK->(Eof())
		dbSelectArea("QPL")
		QPL->(dbSetOrder(3))
		If QPL->(dbSeek(xFilial("QPL")+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+cOperacao+cLaboratorio))
			If !Empty(QPL->QPL_LAUDO)
				oLaudo['hasReport']        := .T.
				oLaudo['reportLevel']      := "L"
				oLaudo['rejectedQuantity'] := QPL->QPL_QTREJ
				oLaudo['reportSelected']   := QPL->QPL_LAUDO
				oLaudo['justification']    := QPL->QPL_JUSTLA
				oLaudo['shelfLife']        := QPL->QPL_DTVAL
			EndIf
		EndIf
	EndIf

	If !oLaudo['hasReport']
		oLaudo := Self:RetornaLaudoOperacao(nRecnoQPK, cRoteiro, cOperacao)
	ENdIf

	ErrorBlock(oLastError)
	
Return oLaudo

/*/{Protheus.doc} RetornaLaudoOperacao
Retorna Laudo da Operação
@author brunno.costa
@since  05/11/2022
@param 01 - nRecnoQPK   , número  , recno da inspeção relacionada na QPK
@param 02 - cRoteiro    , caracter, roteiro relacionado
@param 03 - cOperacao   , caracter, operação relacionada
@return oLaudo, json, objeto json com:
					  hasReport       , lógico  , indica se possui laudo de operação ou laudo geral
					  reportLevel     , caracter, indica o nível do laudo de operação:
												O - Operação
					  reportSelected  , caracter, parecer do laudo
					  justification   , caracter, justificativa de alteração da sugestão de parecer do laudo
					  rejectedQuantity, número  , quantidade rejeitada
					  shelfLife       , data    , data de validade do laudo no formato JSON
@return lSucesso, lógico, indica se conseguiu realizar a gravação
/*/
Method RetornaLaudoOperacao(nRecnoQPK, cRoteiro, cOperacao) CLASS QIPLaudosEnsaios
	
	Local oLaudo     := JsonObject():New()
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0012), Break(e)}) //"Falha na consulta do Laudo de Operação"

	Default nRecnoQPK := -1
	Default cRoteiro  := "01"
	Default cOperacao := "01"

	oLaudo['hasReport'] := .F.

	DbSelectArea("QPK")
	Self:ValidaRecnoValidoQPK(nRecnoQPK)
	If !QPK->(Eof())
		dbSelectArea("QPM")
		QPM->(dbSetOrder(3))
		If QPM->(dbSeek(xFilial("QPM")+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro+cOperacao))
			If !Empty(QPM->QPM_LAUDO)
				oLaudo['hasReport']        := .T.
				oLaudo['reportLevel']      := "O"
				oLaudo['rejectedQuantity'] := QPM->QPM_QTREJ
				oLaudo['reportSelected']   := QPM->QPM_LAUDO
				oLaudo['justification']    := QPM->QPM_JUSTLA
				oLaudo['shelfLife']        := QPM->QPM_DTVAL
			EndIf
		EndIf
	EndIf

	If !oLaudo['hasReport']
		oLaudo := Self:RetornaLaudoGeral(nRecnoQPK, cRoteiro)
	ENdIf

	ErrorBlock(oLastError)
	
Return oLaudo

/*/{Protheus.doc} ReabreInspecao
Reabertura da Inspeção - Exclui todos os Laudos de Laboratório, Operação e Geral
@author brunno.costa
@since  05/11/2022
@param 01 - cUsuario  , número  , caracter, login do usuário
@param 02 - nRecnoQPK , número  , recno da inspeção relacionada na QPK
@param 03 - cRoteiro  , caracter, roteiro selecionado
@param 04 - lMedicao  , logico  , indica se tem medicao
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção ou se ela já aberta
/*/ 
Method ReabreInspecao(cUsuario, nRecnoQPK, cRoteiro, lMedicao) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL    := xFilial("QPL")
	Local cFiLQPM    := xFilial("QPM")
	Local cRoterSeek := ""
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0013), Break(e)}) //"Falha na reabertura da Inspeção"

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default lMedicao   := .F.

	cRoterSeek := IIF(cRoteiro == QIPRotGene("QPL_ROTEIR"), "", cRoteiro)

	Begin Transaction
		Begin Sequence

			If Self:UsuarioPodeGerarLaudo(cUsuario, "T")
				DbSelectArea("QPK")
				lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
				If lSucesso .AND. !QPK->(Eof())

					dbSelectArea("QPL")
					QPL->(dbSetOrder(3))
					If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoterSeek))
						While !QPL->(Eof())                    .AND.;
							QPL->QPL_FILIAL == cFiLQPL         .AND.;
							QPL->QPL_OP     == QPK->QPK_OP     .AND.;
							QPL->QPL_LOTE   == QPK->QPK_LOTE   .AND.;
							QPL->QPL_NUMSER == QPK->QPK_NUMSER .AND.;
							IIF(!Empty(cRoterSeek),QPL->QPL_ROTEIR == cRoterSeek, .T.)

							Self:ApagaAssinatura(QPL->QPL_OP, QPL->QPL_OPERAC, QPL->QPL_LABOR)

							RecLock("QPL", .F.)
							QPL->(DbDelete())
							MsUnLock()

							QPL->(DbSkip())
						EndDo
					EndIf

					dbSelectArea("QPM")
					QPM->(dbSetOrder(3))
					If QPM->(dbSeek(cFiLQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoterSeek))
						While !QPM->(Eof())                    .AND.;
							QPM->QPM_FILIAL == cFiLQPM         .AND.;
							QPM->QPM_OP     == QPK->QPK_OP     .AND.;
							QPM->QPM_LOTE   == QPK->QPK_LOTE   .AND.;
							QPM->QPM_NUMSER == QPK->QPK_NUMSER .AND.;
							IIF(!Empty(cRoterSeek),QPM->QPM_ROTEIR == cRoterSeek, .T.)

							Self:ApagaAssinatura(QPM->QPM_OP, QPM->QPM_OPERAC, QPM->QPM_LABOR)

							RecLock("QPM", .F.)
							QPM->(DbDelete())
							MsUnLock()

							QPM->(DbSkip())
						EndDo
					EndIf

					RecLock("QPK", .F.)
					QPK->QPK_LAUDO := "0"
					MsUnLock()

					Self:AtualizaFlagLegendaInspecao("", lMedicao)
					Self:AtualizaCertificadoDaQualidade(.T.)

				EndIf
			Else
				lSucesso                       := .F.
				Self:oApiManager:cErrorMessage := STR0015 //"Usuário sem acesso a todos os níveis de laudos da inspeção."
				Self:oApiManager:lWarningError := .T.
			EndIf
			
		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} ReabreOperacao
Reabertura da Inspeção - Exclui todos os Laudos de Laboratório e Operação relacionados
@author brunno.costa
@since  14/11/2022
@param 01 - cUsuario  , número  , caracter, login do usuário
@param 02 - nRecnoQPK , número  , recno da inspeção relacionada na QPK
@param 03 - cRoteiro  , caracter, roteiro selecionado
@param 04 - cOperacao , caracter, operacao relacionada
@param 05 - lMedicao  , logico  , indica se tem medicao
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção ou se ela já aberta
/*/ 
Method ReabreOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, lMedicao) CLASS QIPLaudosEnsaios
	
	Local cError     := ""
	Local cFiLQPL    := xFilial("QPL")
	Local cFiLQPM    := xFilial("QPM")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0016 + cOperacao), Break(e)}) //"Falha na reabertura da Operação " + cOperacao

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default cOperacao  := "01"
	Default lMedicao   := .F.

	Begin Transaction
		Begin Sequence
			DbSelectArea("QPK")
			lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
			If lSucesso .AND. !QPK->(Eof())

				If lSucesso .And. !Self:UsuarioPodeGerarLaudo(cUsuario, "O", @cError)
					lSucesso                       := .F.
					Self:oApiManager:cErrorMessage := Iif(!Empty(cError),cError, STR0023) //"Usuário sem acesso a geração de laudo de operação."
					Self:oApiManager:lWarningError := .T.
				EndIf

				If lSucesso .And. !Self:UsuarioPodeGerarLaudo(cUsuario, "L", @cError)
					lSucesso                       := .F.
					Self:oApiManager:cErrorMessage := Iif(!Empty(cError),cError, STR0020) //"Usuário sem acesso a geração de laudo de laboratório."
					Self:oApiManager:lWarningError := .T.
				EndIf

				If lSucesso
					Self:AtualizaFlagLegendaInspecao("", lMedicao)
					Self:AtualizaCertificadoDaQualidade(.T.)

					dbSelectArea("QPL")
					QPL->(dbSetOrder(3))
					If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
						While !QPL->(Eof())                    .AND.;
							QPL->QPL_FILIAL == cFiLQPL         .AND.;
							QPL->QPL_OP     == QPK->QPK_OP     .AND.;
							QPL->QPL_LOTE   == QPK->QPK_LOTE   .AND.;
							QPL->QPL_NUMSER == QPK->QPK_NUMSER .AND.;
							QPL->QPL_ROTEIR == cRoteiro

							If QPL->QPL_OPERAC == cOperacao
								Self:ApagaAssinatura(QPL->QPL_OP, QPL->QPL_OPERAC, QPL->QPL_LABOR)

								RecLock("QPL", .F.)
								QPL->(DbDelete())
								MsUnLock()

							EndIf

							QPL->(DbSkip())
						EndDo
					EndIf

					dbSelectArea("QPM")
					QPM->(dbSetOrder(3))
					If QPM->(dbSeek(cFiLQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
						While !QPM->(Eof())                    .AND.;
							QPM->QPM_FILIAL == cFiLQPM         .AND.;
							QPM->QPM_OP     == QPK->QPK_OP     .AND.;
							QPM->QPM_LOTE   == QPK->QPK_LOTE   .AND.;
							QPM->QPM_NUMSER == QPK->QPK_NUMSER .AND.;
							QPM->QPM_ROTEIR == cRoteiro

							If QPM->QPM_OPERAC == cOperacao
								Self:ApagaAssinatura(QPM->QPM_OP, QPM->QPM_OPERAC, QPM->QPM_LABOR)

								RecLock("QPM", .F.)
								QPM->(DbDelete())
								MsUnLock()

							EndIf

							QPM->(DbSkip())
						EndDo
					EndIf					
				EndIf
					

			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} LaudoPodeSerEditado
Indica se o Laudo Pode ser Editado
@author brunno.costa
@since  05/11/2022
@param 01 - nRecnoQPK   , número  , recno da inspeção relacionada na QPK
@param 02 - cRoteiro    , caracter, roteiro relacionado
@param 03 - cOperacao   , caracter, operação relacionada
@param 04 - cLaboratorio, caracter, laboratório relacionado
@param 05 - cNivelLaudo, caracter, caracter que indica o modelo de página de Laudo:
                          L  - Laudo via Laboratório
						  O  - Laudo via Operação
						  G  - Laudo Geral
						  OA - Laudo de Operação Agrupado (Similar ao Geral, visualiza várias operações, mas não grava Laudo Geral)
						  LA - Laudo de Laboratório Agrupado (Similar ao via Operação, visualiza vários laboratórios, mas não grava Laudo Geral nem de Operação)
@return lPermite, lógico, indica se conseguiu reabrir a inspeção ou se ela já aberta
/*/ 
Method LaudoPodeSerEditado(nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, cNivelLaudo) CLASS QIPLaudosEnsaios
	
	Local cFiLQPL    := xFilial("QPL")
	Local cFiLQPM    := xFilial("QPM")
	Local lPermite   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0014)}) //"Falha na consulta de permissão para edição de laudo"
	Local lLaudoLab  := .F.
	Local lLaudoOpe  := .F.
	Local lLaudoGer  := .F.

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	
	lPermite := Self:ValidaRecnoValidoQPK(nRecnoQPK)
	If lPermite .AND. !QPK->(Eof())
		dbSelectArea("QPL")
		QPL->(dbSetOrder(3))
		If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
			While !QPL->(Eof())                    .AND.;
				QPL->QPL_FILIAL == cFiLQPL         .AND.;
				QPL->QPL_OP     == QPK->QPK_OP     .AND.;
				QPL->QPL_LOTE   == QPK->QPK_LOTE   .AND.;
				QPL->QPL_NUMSER == QPK->QPK_NUMSER .AND.;
				QPL->QPL_ROTEIR == cRoteiro

				If (Empty(cOperacao) .OR. QPL->QPL_OPERAC == cOperacao .OR. Empty(QPL->QPL_OPERAC)) .AND. !Empty(QPL->QPL_LAUDO)
					If Empty(QPL->QPL_LABOR)
						lLaudoGer := .T.
					ElseIf Empty(cLaboratorio) .OR. QPL->QPL_LABOR == cLaboratorio
						lLaudoLab := .T.
					EndIf
				EndIf

				QPL->(DbSkip())
			EndDo
		EndIf

		dbSelectArea("QPM")
		QPM->(dbSetOrder(3))
		If QPM->(dbSeek(cFiLQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
			While !QPM->(Eof())                    .AND.;
				QPM->QPM_FILIAL == cFiLQPM         .AND.;
				QPM->QPM_OP     == QPK->QPK_OP     .AND.;
				QPM->QPM_LOTE   == QPK->QPK_LOTE   .AND.;
				QPM->QPM_NUMSER == QPK->QPK_NUMSER .AND.;
				QPM->QPM_ROTEIR == cRoteiro

				If (Empty(cOperacao) .OR. QPM->QPM_OPERAC == cOperacao) .AND. !Empty(QPM->QPM_LAUDO)
					lLaudoOpe  := .T.
				EndIf

				QPM->(DbSkip())
			EndDo
		EndIf

	EndIf

	lPermite := Iif("L" $ cNivelLaudo, !lLaudoOpe .AND. !lLaudoGer, lPermite)
	lPermite := Iif("O" $ cNivelLaudo, !lLaudoGer                 , lPermite)
	lPermite := Iif("G" $ cNivelLaudo, .T.                        , lPermite)

	ErrorBlock(oLastError)
	
Return lPermite

/*/{Protheus.doc} ValidaRecnoValidoQPK
Indica se o Laudo Pode ser Editado
@author brunno.costa
@since  05/11/2022
@param 01 - nRecnoQPK   , número  , recno da inspeção relacionada na QPK
@return lValido, lógico, indica se o RECNO é válido na QPK
/*/ 
Method ValidaRecnoValidoQPK(nRecnoQPK) CLASS QIPLaudosEnsaios
	Local lValido := .T.
	QPK->(DbGoTo(nRecnoQPK))
	If QPK->(Eof())
		lValido := .F.
		Self:oAPIManager:cDetailedMessage := STR0006 + cValToChar(nRecnoQPK) + "." //"Informe um recno de inspeção válido da tabela QPK: "
		Self:oAPIManager:cErrorMessage    := STR0006 + cValToChar(nRecnoQPK) + "." //"Informe um recno de inspeção válido da tabela QPK: "
	EndIf
Return lValido

/*/{Protheus.doc} GravaAssinaturaLaboratorio
Realiza a gravação da assinatura do laboratório
@author rafael.hesse
@since  06/11/2022
@param 01 - cUsuario    , caracter, Login do usuário
@param 02 - cLaudoLab   , caracter, Laudo do Laboratório
@param 03 - cNumOP      , caracter, código da Ordem de Produção
@param 04 - cLabor      , caracter, laboratório relacionado
@param 05 - cOperacao   , caracter, operação relacionada
/*/ 
Method GravaAssinaturaLaboratorio(cUsuario, cLaudoLab, cNumOP, cLabor, cOperacao) CLASS QIPLaudosEnsaios
Local aArea     := {}
Local lLauNivel := GetNewpar("MV_QPLDNIV","000") <> "000"

	If lLauNivel 
		aArea := GetArea()
		DbSelectArea("QQL")
		QQL->(DbSetOrder(2))
		If QQL->(DbSeek(xFilial("QQL") + cNumOp + cOperacao + cLabor)) .And. !Empty(cLaudoLab)
			If cLaudoLab <> QQL->QQL_LAUDO
				RecLock("QQL",.F.)
					QQL->QQL_RESP    := cUsuario
					QQL->QQL_DATA    := dDataBase
					QQL->QQL_HORA    := Left(Time(),5)
					QQL->QQL_LAUDO   := cLaudoLab
				QQL->(MsUnLock())
			EndIf	
		Else
			RecLock("QQL",.T.)
				QQL->QQL_FILIAL  := xFilial("QQL")
				QQL->QQL_OP      := cNumOp
				QQL->QQL_OPERAC  := cOperacao
				QQL->QQL_LAB     := cLabor
				QQL->QQL_RESP    := cUsuario
				QQL->QQL_DATA    := dDataBase
				QQL->QQL_HORA    := Left(Time(),5)
				QQL->QQL_LAUDO   := cLaudoLab
			QQL->(MsUnLock())
		EndIf
		RestArea(aArea)
	EndIf

Return

/*/{Protheus.doc} GravaAssinaturaOperacao
Realiza a gravação da assinatura da Operação
@author rafael.hesse
@since  06/11/2022
@param 01 - cUsuario    , caracter, Login do usuário
@param 02 - cLaudoOpe   , caracter, Laudo da Operação
@param 03 - cNumOP      , caracter, código da Ordem de Produção
@param 04 - cOperacao   , caracter, operação relacionada
/*/ 
Method GravaAssinaturaOperacao(cUsuario, cLaudoOpe, cNumOP, cOperacao) CLASS QIPLaudosEnsaios
Local aArea     := {}
Local cLabor    := Space(TamSx3("QQL_LAB")[1])
Local lLauNivel := GetNewpar("MV_QPLDNIV","000") <> "000"

	If lLauNivel 
		aArea := GetArea()
		DbSelectArea("QQL")
		QQL->(DbSetOrder(2))
		If QQL->(DbSeek(xFilial("QQL") + cNumOp + cOperacao + cLabor)) .And. !Empty(cLaudoOpe)
			If cLaudoOpe <> QQL->QQL_LAUDO
				RecLock("QQL",.F.)
					QQL->QQL_RESP    := cUsuario
					QQL->QQL_DATA    := dDataBase
					QQL->QQL_HORA    := Left(Time(),5)
					QQL->QQL_LAUDO   := cLaudoOpe
				QQL->(MsUnLock())
			EndIf	
		Else
			RecLock("QQL",.T.)
				QQL->QQL_FILIAL  := xFilial("QQL")
				QQL->QQL_OP      := cNumOp
				QQL->QQL_OPERAC  := cOperacao
				QQL->QQL_LAB     := cLabor
				QQL->QQL_RESP    := cUsuario
				QQL->QQL_DATA    := dDataBase
				QQL->QQL_HORA    := Left(Time(),5)
				QQL->QQL_LAUDO   := cLaudoOpe
			QQL->(MsUnLock())
		EndIf
		RestArea(aArea)
	EndIf

Return

/*/{Protheus.doc} GravaAssinaturaGeral
Realiza a gravação da assinatura do laudo Geral
@author rafael.hesse
@since  06/11/2022
@param 01 - cUsuario    , caracter, Login do usuário
@param 02 - cLaudoGer   , caracter, Laudo Geral
@param 03 - cNumOP      , caracter, código da Ordem de Produção
/*/ 
Method GravaAssinaturaGeral(cUsuario, cLaudoGer, cNumOp) CLASS QIPLaudosEnsaios
Local aArea     := {}
Local cLabor    := Space(TamSx3("QQL_LAB")[1])
Local cOperacao := Space(TamSx3("QQL_OPERAC")[1])
Local lLauNivel := GetNewpar("MV_QPLDNIV","000") <> "000"

	If lLauNivel
		aArea := GetArea()
		DbSelectArea("QQL")
		QQL->(DbSetOrder(2))
		If !Empty(cLaudoGer)
			If QQL->(!DbSeek(xFilial("QQL")+cNumOp+cOperacao+cLabor))
				RecLock("QQL",.T.)
					QQL->QQL_FILIAL  := xFilial("QQL")
					QQL->QQL_OP      := cNumOp
					QQL->QQL_OPERAC  := cOperacao
					QQL->QQL_LAB     := cLabor
					QQL->QQL_RESP    := cUsuario
					QQL->QQL_DATA    := dDataBase
					QQL->QQL_HORA    := Left(Time(),5)
					QQL->QQL_LAUDO   := cLaudoGer
				QQL->(MsUnLock())
			ElseIf QQL->QQL_LAUDO <> cLaudoGer
				RecLock("QQL",.F.)
					QQL->QQL_RESP    := cUsuario
					QQL->QQL_DATA    := dDataBase
					QQL->QQL_HORA    := Left(Time(),5)
					QQL->QQL_LAUDO   := cLaudoGer
				QQL->(MsUnLock())
			EndIf
		EndIf
		RestArea(aArea)
	EndIf

Return


/*/{Protheus.doc} ExcluiLaudoLaboratorio
Exclui Laudo do Laboratório
@author brunno.costa
@since  14/11/2022
@param 01 - cUsuario     , caracter, login de usuário relacionado
@param 02 - nRecnoQPK    , número  , recno da inspeção relacionada na QPK
@param 03 - cRoteiro     , caracter, roteiro selecionado
@param 04 - cOperacao    , caracter, operacao relacionada
@param 05 - cLaboratorio , caracter, laboratório relacionado
@param 06 - lMedicao     , logico  , indica se tem medicao
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção ou se ela já aberta
/*/ 
Method ExcluiLaudoLaboratorio(cUsuario, nRecnoQPK, cRoteiro, cOperacao, cLaboratorio, lMedicao) CLASS QIPLaudosEnsaios
	
	Local cError     := ""
	Local cFiLQPL    := xFilial("QPL")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0017 + cLaboratorio + STR0018 + cOperacao), Break(e)}) //"Falha Exclusão Laudo do Laboratório " + cLaboratorio + " da Operação " + cOperacao

	Default nRecnoQPK    := -1
	Default cRoteiro     := "01"
	Default cOperacao    := "01"
	Default cLaboratorio := "LABFIS"
	Default lMedicao     := .F.

	Begin Transaction
		Begin Sequence

			If Self:UsuarioPodeGerarLaudo(cUsuario, "L", @cError)
				If Self:LaudoPodeSerEditado(nRecnoQPK, cRoteiro, cOperacao, "", "L")
					DbSelectArea("QPK")
					lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
					If lSucesso .AND. !QPK->(Eof())

						dbSelectArea("QPL")
						QPL->(dbSetOrder(3))
						If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
							While !QPL->(Eof())                    .AND.;
								QPL->QPL_FILIAL == cFiLQPL         .AND.;
								QPL->QPL_OP     == QPK->QPK_OP     .AND.;
								QPL->QPL_LOTE   == QPK->QPK_LOTE   .AND.;
								QPL->QPL_NUMSER == QPK->QPK_NUMSER .AND.;
								QPL->QPL_ROTEIR == cRoteiro

								If QPL->QPL_OPERAC == cOperacao .AND. cLaboratorio == QPL->QPL_LABOR .AND. !Empty(QPL->QPL_LABOR)
									Self:ApagaAssinatura(QPL->QPL_OP, QPL->QPL_OPERAC, QPL->QPL_LABOR)
									
									RecLock("QPL", .F.)
									QPL->(DbDelete())
									MsUnLock()

								EndIf

								QPL->(DbSkip())
							EndDo
						EndIf
						Self:AtualizaFlagLegendaInspecao("", lMedicao)
						Self:AtualizaCertificadoDaQualidade(.T.)

					EndIf
				Else
					lSucesso                       := .F.
					Self:oApiManager:cErrorMessage := STR0019 //"Este laudo não pode ser excluído, reabra a Inspeção ou exclua os laudos superiores."
					Self:oApiManager:lWarningError := .T.
				EndIf
			Else
				lSucesso                       := .F.
				Self:oApiManager:cErrorMessage := Iif(!Empty(cError),cError,STR0020) //"Usuário sem acesso a geração de laudo de laboratório."
				Self:oApiManager:lWarningError := .T.
			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso


/*/{Protheus.doc} ExcluiLaudoOperacao
Exclui Laudo de Operação
@author brunno.costa
@since  14/11/2022
@param 01 - cUsuario  , caracter, login de usuário relacionado
@param 02 - nRecnoQPK , número  , recno da inspeção relacionada na QPK
@param 03 - cRoteiro  , caracter, roteiro selecionado
@param 04 - cOperacao , caracter, operacao relacionada
@param 05 - lMedicao  , logico  , indica se tem medicao
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção ou se ela já aberta
/*/ 
Method ExcluiLaudoOperacao(cUsuario, nRecnoQPK, cRoteiro, cOperacao, lMedicao) CLASS QIPLaudosEnsaios
	
	Local cError     := ""
	Local cFiLQPM    := xFilial("QPM")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0021 + cOperacao), Break(e)}) //"Falha Exclusão Laudo da Operação "

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default cOperacao  := "01"
	Default lMedicao   := .F.

	Begin Transaction
		Begin Sequence

			If Self:UsuarioPodeGerarLaudo(cUsuario, "O", @cError)
				If Self:LaudoPodeSerEditado(nRecnoQPK, cRoteiro, cOperacao, "", "O")
					DbSelectArea("QPK")
					lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
					If lSucesso .AND. !QPK->(Eof())

						dbSelectArea("QPM")
						QPM->(dbSetOrder(3))
						If QPM->(dbSeek(cFiLQPM+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
							While !QPM->(Eof())                    .AND.;
								QPM->QPM_FILIAL == cFiLQPM         .AND.;
								QPM->QPM_OP     == QPK->QPK_OP     .AND.;
								QPM->QPM_LOTE   == QPK->QPK_LOTE   .AND.;
								QPM->QPM_NUMSER == QPK->QPK_NUMSER .AND.;
								QPM->QPM_ROTEIR == cRoteiro

								If QPM->QPM_OPERAC == cOperacao
									Self:ApagaAssinatura(QPM->QPM_OP, QPM->QPM_OPERAC, QPM->QPM_LABOR)

									RecLock("QPM", .F.)
									QPM->(DbDelete())
									MsUnLock()

								EndIf

								QPM->(DbSkip())
							EndDo
						EndIf
						Self:AtualizaFlagLegendaInspecao("", lMedicao)
						Self:AtualizaCertificadoDaQualidade(.T.)

					EndIf
				Else
					lSucesso                       := .F.
					Self:oApiManager:cErrorMessage := STR0022 //"Este laudo não pode ser excluído, reabra a Inspeção ou exclua o Laudo Geral."
					Self:oApiManager:lWarningError := .T.
				EndIf
			Else
				lSucesso                       := .F.
				Self:oApiManager:cErrorMessage := Iif(!Empty(cError),cError,STR0023) //"Usuário sem acesso a geração de laudo de operação."
				Self:oApiManager:lWarningError := .T.
			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso


/*/{Protheus.doc} ExcluiLaudoGeral
Exclui Laudo Geral
@author brunno.costa
@since  14/11/2022
@param 01 - cUsuario  , caracter, login de usuário relacionado
@param 02 - nRecnoQPK , número  , recno da inspeção relacionada na QPK
@param 03 - cRoteiro  , caracter, roteiro selecionado
@param 04 - lMedicao  , logico  , indica se tem medicao
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção ou se ela já aberta
/*/ 
Method ExcluiLaudoGeral(cUsuario, nRecnoQPK, cRoteiro, lMedicao) CLASS QIPLaudosEnsaios
	
	Local cError     := ""
	Local cFiLQPL    := xFilial("QPL")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0025), Break(e)}) //"Falha na Exclusão do Laudo Geral"

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default lMedicao   := .F.

	Begin Transaction
		Begin Sequence

			If Self:UsuarioPodeGerarLaudo(cUsuario, "G", @cError)
				DbSelectArea("QPK")
				lSucesso := Self:ValidaRecnoValidoQPK(nRecnoQPK)
				If lSucesso .AND. !QPK->(Eof())

					dbSelectArea("QPL")
					QPL->(dbSetOrder(3))
					If QPL->(dbSeek(cFiLQPL+QPK->(QPK_OP+QPK_LOTE+QPK_NUMSER)+cRoteiro))
						While !QPL->(Eof())                    .AND.;
							QPL->QPL_FILIAL == cFiLQPL         .AND.;
							QPL->QPL_OP     == QPK->QPK_OP     .AND.;
							QPL->QPL_LOTE   == QPK->QPK_LOTE   .AND.;
							QPL->QPL_NUMSER == QPK->QPK_NUMSER .AND.;
							QPL->QPL_ROTEIR == cRoteiro

							If Empty(QPL->QPL_OPERAC) .AND. Empty(QPL->QPL_LABOR)
								Self:ApagaAssinatura(QPL->QPL_OP, QPL->QPL_OPERAC, QPL->QPL_LABOR)								
								
								RecLock("QPL", .F.)
								QPL->(DbDelete())
								MsUnLock()

							EndIf

							QPL->(DbSkip())
						EndDo
					EndIf
					RecLock("QPK", .F.)
					QPK->QPK_LAUDO := "0"
					MsUnLock()

					Self:AtualizaFlagLegendaInspecao("", lMedicao)
					Self:AtualizaCertificadoDaQualidade(.T.)

				EndIf
			Else
				lSucesso                       := .F.
				Self:oApiManager:cErrorMessage := Iif(!Empty(cError),cError,STR0024) //"Usuário sem acesso a geração de laudo geral."
				Self:oApiManager:lWarningError := .T.
			EndIf

		Recover
			lSucesso := .F.
			DisarmTransaction()
		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} ApagaAssinatura
Realiza a Exclusão da Assinatura do Laudo
@author rafael.hesse
@since  16/11/2022
@param 01 - cNumOP      , caracter, código da Ordem de Produção
@param 02 - cOperacao   , caracter, operação relacionada
@param 03 - cLabor      , caracter, laboratório relacionado
/*/ 
Method ApagaAssinatura( cNumOP, cOperacao, cLabor) CLASS QIPLaudosEnsaios
Local aArea     :=  GetArea()

	DbSelectArea("QQL")
	QQL->(DbSetOrder(2))
	If QQL->(DbSeek(xFilial("QQL") + cNumOp + cOperacao + cLabor))
		RecLock("QQL",.F.)
			QQL->(DbDelete())
		QQL->(MsUnLock())
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} ChecaTodosOsLaboratoriosComLaudos
Checa se Todos os Laboratórios Possuem Laudos
@author brunno.costa
@since  20/11/2022
@param 01 - cUsuario  , caracter, login de usuário relacionado
@param 02 - nRecnoQPK , número  , recno da inspeção relacionada na QPK
@return lTodosLaudos, lógico, indica que todos os laboratórios possuem laudos
/*/ 
Method ChecaTodosOsLaboratoriosComLaudos(cUsuario, nRecnoQPK) CLASS QIPLaudosEnsaios
	Local cAlias                         := Nil
	Local lTodosLaudos                   := .T.
	Local oEnsaiosInspecaoDeProcessosAPI := EnsaiosInspecaoDeProcessosAPI():New(Nil)

	cAlias := oEnsaiosInspecaoDeProcessosAPI:CriaAliasEnsaiosPesquisa(nRecnoQPK, "", "", "", "", 1, 999999, "*", "", cUsuario)
	While (cAlias)->(!Eof())
		If Empty((cAlias)->QPL_LAUDO)
			lTodosLaudos := .F.
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo

Return lTodosLaudos


/*/{Protheus.doc} ChecaTodasAsOperacoesComLaudos
Checa se Todas as Operações Possuem Laudos
@author brunno.costa
@since  20/11/2022
@param 01 - cUsuario  , caracter, login de usuário relacionado
@param 02 - nRecnoQPK , número  , recno da inspeção relacionada na QPK
@return lTodosLaudos, lógico, indica que todas as operações possuem laudos
/*/ 
Method ChecaTodasAsOperacoesComLaudos(cUsuario, nRecnoQPK) CLASS QIPLaudosEnsaios

    Local cAlias                   := Nil
	Local lTodosLaudos             := .T.
	Local oInspecoesDeProcessosAPI := InspecoesDeProcessosAPI():New(Nil)

	cAlias := oInspecoesDeProcessosAPI:CriaAliasPesquisa(cUsuario, "", "", "", "", 1, 999999, "*", cValToChar(nRecnoQPK))
	While (cAlias)->(!Eof())
		If Empty((cAlias)->QPM_LAUDO)
			lTodosLaudos := .F.
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo

Return lTodosLaudos

/*/{Protheus.doc} RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos
Verifica se há integração com outros módulos e retorna as mensagens de falha
@author rafael.hesse
@since  17/11/2022
@return aMensagens, Array, Informa as mensagems de integração que serão exibidas. Caso vazio não será apresentado.
/*/ 
Method RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos() CLASS QIPLaudosEnsaios
	
	Local aMensagens := {}

	lIntQMT := Iif(lIntQMT == Nil, FindFunction("EAPPQIPQMT")            , lIntQMT)
	lIntQNC := Iif(lIntQNC == Nil, FindClass("FichasNaoConformidadesAPI"), lIntQNC)

	If GetMv("MV_QIPQMT") == 'S' .AND. !lIntQMT
		 aAdd(aMensagens, STR0026) //"Integração com Metrologia ativa. Utilize o Protheus para informar os instrumentos utilizados e preencher ou editar o Laudo"
	EndIf

	If GetMv("MV_QIPQNC") == '1' .AND. !lIntQNC
		aAdd(aMensagens, STR0027) //"Integração com Controle de Não Conformidades ativa. Utilize o Protheus para informar NCs e preencher ou editar o Laudo"
	EndIf

Return aMensagens

/*/{Protheus.doc} MovimentaEstoqueCQ
Movimenta Estoque da QPK Automaticamente
@author rafael.hesse
@since  21/03/2022
@param 01 - nRecnoQPK, numérico, recno do registro na QPK
@parma 02 - cUsuario , caracter, login do usuário
@Return - lSucesso, Lógico, indica se conseguiu realizar a movimentação
/*/
METHOD MovimentaEstoqueCQ(nRecnoQPK, cUsuario) CLASS QIPLaudosEnsaios

	Local aHelpErro       := Nil
	Local bErrorBlock     := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0031 + e:Description), Break(e)}) // STR0031 - "Falha na movimentação de Estoque do CQ. "
	Local lSucesso        := .F.
	Local oQIPA215Estoque := Nil

	If FindClass("QIPA215Estoque")
		oQIPA215Estoque := QIPA215Estoque():New(-1)
		QPL->(DbGoTop())//Força desposicionamento na QPL para tratar bug de posicionamento em registro de memória desatualizado
		lSucesso := oQIPA215Estoque:movimentaPendenciasEstoqueCQAutomaticamente(nRecnoQPK)

		If lSucesso
			QPK->(DbGoto(nRecnoQPK))
			QPL->(DbSetOrder(1))
			QPL->(DbSeek(xFilial("QPL")+QPK->QPK_OP ))
			Self:AtualizaFlagLegendaInspecao(QPL->QPL_LAUDO, .F., .T., cUsuario)
		Else
			Self:oApiManager:cErrorMessage := STR0034 //"Não foi possível realizar a liberação de estoque da inspeção."
			Self:oApiManager:lWarningError := .T.
			If FindFunction("QLTGetHelp")
				aHelpErro := QLTGetHelp()
				If !Empty(aHelpErro)
					Self:oApiManager:cErrorMessage   := "[" + AllTrim(aHelpErro[1]) + "] "
					Self:oApiManager:cErrorMessage   += STR0035 + aHelpErro[2] + ". " //"Problema: "
					Self:oApiManager:cErrorMessage   += STR0036 + aHelpErro[3]        //"Solução: "
					Self:oApiManager:cErrorMessage   := StrTran(Self:oApiManager:cErrorMessage, "..", ".")
					Self:oApiManager:cErrorMessage   := StrTran(Self:oApiManager:cErrorMessage, "-", "")
				EndIf
			EndIf
		EndIf

	EndIf
	ErrorBlock(bErrorBlock)

Return lSucesso

/*/{Protheus.doc} ReabreInspecaoEEstornaMovimentosCQ
Função responsável pela reabertura da inspeção e estorno das movimentações de Estoque do CQ
@type  Function
@author brunno.costa / thiago.rover
@since 07/03/2023 / 22/03/2023
@param 01 - cLogin, caracter, indica o Login do usuário da QAA
@param 02 - nRecnoQPK, numérico, indica o RECNO do registro da QPK relacionado
@param 03 - cRoteiro, caracter, indicar o código do roteiro do registro da QPK relacionado
@param 04 - lMedicao, lógico, indicar se a inspeção contém medições
@param 05 - nOpc, numérico, indica quando a chamada foi realizada via APP
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção
/*/
METHOD ReabreInspecaoEEstornaMovimentosCQ(cLogin, nRecnoQPK, cRoteiro, lMedicao, nOpc) CLASS QIPLaudosEnsaios 
		
	Local lSucesso        := .F.
	Local lTemMovi        := .F.
	Local oQIPA215Estoque := Nil

	Default nOpc := 3

	//Força passagem por MATXALC para popular variável Static cRetCodUsr - DMANQUALI-9983 - DBRUnlock cannot be called in a transaction
	PCPDocUser(RetCodUsr(cLogin))

	BEGIN TRANSACTION

		If Self:AvaliaAcessoATodaOperacao(nRecnoQPK, cLogin)
			oQIPA215Estoque := QIPA215Estoque():New(nOpc)
			
			lSucesso := oQIPA215Estoque:estornaTodosMovimentosDeCQ(nRecnoQPK, @lTemMovi) 
				
			If lTemMovi .And. !lSucesso .And. nOpc == -1
				// STR0028 - Verifique se há saldo de estoque suficente para realização dos estornos e repita o processo.
				Self:oApiManager:cErrorMessage := STR0028
				Self:oApiManager:lWarningError := .T.
			Endif

			IF (lSucesso .OR. !lTemMovi) .And. !(lSucesso := Self:ReabreInspecao(cLogin, nRecnoQPK, cRoteiro, lMedicao)) .And. nOpc == -1 
				If Empty(Self:oApiManager:cErrorMessage)
					// STR0029 - Não foi possivel realizar a reabertura da inspeção. Verifique se a inspeção está sendo editada por outro usuário."
					Self:oApiManager:cErrorMessage := STR0029
					Self:oApiManager:lWarningError := .T.
				Endif
			Endif

			If !lSucesso
				DisarmTransaction()
			EndIf
		EndIf

	END TRANSACTION

Return lSucesso

/*/{Protheus.doc} ExcluiLaudoGeralEEstornaMovimentosCQ
Função responsável pela exclusão do laudo geral e estorno das movimentações de Estoque do CQ no APP
@type  Function
@author thiago.rover
@since 22/03/2023
@param 01 - cLogin, caracter, indica o Login do usuário da QAA
@param 02 - nRecnoQPK, numérico, indica o RECNO do registro da QPK relacionado
@param 03 - cRoteiro, caracter, indicar o código do roteiro do registro da QPK relacionado
@param 04 - lMedicao, lógico, indicar se a inspeção contém medições
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção
/*/
METHOD ExcluiLaudoGeralEEstornaMovimentosCQ(cLogin, nRecnoQPK, cRoteiro, lMedicao) CLASS QIPLaudosEnsaios 

	Local lSucesso        := .F.
	Local lTemMovi        := .F.
	Local oQIPA215Estoque := QIPA215Estoque():New(-1)

	Default nRecnoQPK  := -1
	Default cRoteiro   := "01"
	Default lMedicao   := .F.

	BEGIN TRANSACTION
		lSucesso := oQIPA215Estoque:estornaTodosMovimentosDeCQ(nRecnoQPK, @lTemMovi)
			
		If lTemMovi .And. !lSucesso
			// STR0028 - Verifique se há saldo de estoque suficente para realização dos estornos e repita o processo.
			Self:oApiManager:cErrorMessage := STR0028
			Self:oApiManager:lWarningError := .T.
		Endif

		IF (lSucesso .OR. !lTemMovi) .And. !(lSucesso := Self:ExcluiLaudoGeral(cLogin, nRecnoQPK, cRoteiro, lMedicao))
			If Empty(Self:oApiManager:cErrorMessage)
				// STR0030 - Não foi possivel realizar a exclusão do laudo geral. Verifique se a inspeção está sendo editada por outro usuário."
				Self:oApiManager:cErrorMessage := STR0030
				Self:oApiManager:lWarningError := .T.
			EndIf
		Endif

		If !lSucesso
			DisarmTransaction()
		EndIf
	END TRANSACTION

Return lSucesso

/*/{Protheus.doc} DefineParecerLaudos
Define os pareceres dos laudos de acordo com a categoria
@type  Function
@author brunno.costa
@since  10/02/2025
/*/
METHOD DefineParecerLaudos() CLASS QIPLaudosEnsaios 

	QPD->(dbSetOrder(1))
	QPD->(MsSeek(xFilial("QPD")))
	While QPD->(!Eof()) .AND. QPD->QPD_FILIAL == xFilial("QPD")
		If QPD->QPD_CATEG     == "1"
			self:cParecerAprovado    += QPD->QPD_CODFAT
			self:cPrimeiroAprovado   := Iif(Empty(self:cPrimeiroAprovado), QPD->QPD_CODFAT, self:cPrimeiroAprovado)
		ElseIf QPD->QPD_CATEG == "2"
			self:cParecerCondicional += QPD->QPD_CODFAT
		ElseIf QPD->QPD_CATEG == "3"
			self:cParecerReprovado   += QPD->QPD_CODFAT
			self:cPrimeiroReprovado  := Iif(Empty(self:cPrimeiroReprovado), QPD->QPD_CODFAT, self:cPrimeiroReprovado)
		ElseIf QPD->QPD_CATEG == "4"
			self:cParecerUrgente     += QPD->QPD_CODFAT
		EndIf
		QPD->(dbSkip())
	EndDo

Return


/*/{Protheus.doc} SugereParecerSuperior
Sugere parecer de laudo de nível superior
@author brunno.costa
@since 25/10/2022
@param 01 - cParecer       , caracter, parecer atual
@param 02 - cPriAprovado   , caracter, primeiro parecer de aprovação
@param 03 - cPriReprovado  , caracter, primeiro parecer de reprovação
@param 04 - cPriUrgente    , caracter, primeiro parecer de urgência
@param 05 - cPriCondicional, caracter, primeiro parecer de condicional
@param 06 - cPriPendente   , caracter, primeiro parecer de pendência
@param 07 - cParecerMed    , caracter, parecer de medições
@return cParecer, lógico, sugestão de paracer para a(s) operação(ões)
/*/
Method SugereParecerSuperior(cParecer, cPriAprovado, cPriReprovado, cPriUrgente, cPriCondicional, cPriPendente, cParecerMed) CLASS QIPLaudosEnsaios

	//Considera REPROVADO, quando houver ao menos uma e não houver liberação urgente
	cParecer    := Iif(!Empty(cPriReprovado), cPriReprovado, cParecer)

	//Considera URGENTE - quando não houver laudo reprovado
	cParecer := Iif( !Empty(cPriUrgente  );
	           .And.  Empty(cPriReprovado);
			   , cPriUrgente, cParecer   ) 

	//Considera CONDICIONAL - quando não houver laudo reprovado ou pendente ou urgente
	cParecer := Iif( Empty(cPriPendente   );
	          .And.  Empty(cPriReprovado  );
			  .And.  Empty(cPriUrgente    );
			  .And. !Empty(cPriCondicional);
			  , cPriCondicional, cParecer ) 

	//Considera APROVADO - quando não houver laudo reprovado, pendente, urgente ou condicional
	cParecer := Iif( Empty(cPriPendente   );
	          .And.  Empty(cPriReprovado  );
			  .And.  Empty(cPriUrgente    );
			  .And.  Empty(cPriCondicional);
			  .And. !Empty(cPriAprovado   );
			  , cPriAprovado   , cParecer ) 

	//Considera parecer MEDIÇÕES - quando não houver laudo reprovado, urgente, condicional ou aprovado
	cParecer := Iif(Empty(cParecer), cParecerMed, cParecer)

	//Se ainda não existe parecer, considera PENDENTE
	cParecer := Iif(Empty(cParecer), cPriPendente       , cParecer)

Return cParecer



