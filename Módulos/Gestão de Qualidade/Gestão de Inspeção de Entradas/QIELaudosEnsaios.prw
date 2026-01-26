#INCLUDE "TOTVS.CH"
#INCLUDE "QIELaudosEnsaios.CH"

Static lIntQMT := Nil
Static lIntQNC := Nil

CLASS QIELaudosEnsaios FROM LongNameClass
	
	DATA cBlocoForcaErro     as STRING
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
	Method AvaliaAcessoATodaInspecao(nRecnoInspecao, cUsuario)
	Method BuscaDataDeValidadeDoLaudo(nRecnoInspecao, cUsuario, cError)
	Method ChecaTodosOsLaboratoriosComLaudos(cUsuario, nRecnoQEK)
	Method DirecionaParaTelaDeLaudoPorInspecaoEUsuario(nRecnoInspecao, cUsuario, cError)
	Method ExcluiLaudoGeral(cUsuario, nRecnoQEK)
	Method ExcluiLaudoGeralEEstornaMovimentosCQ(cLogin, nRecnoQEK, lMedicao)
	Method ExcluiLaudoLaboratorio(cUsuario, nRecnoQEK, cLaboratorio, lMedicao)
	Method GravaLaudoGeral(cUsuario, nRecnoQEK, cParecer, cJustifica, nRejeicao, cValidade, lBaixaCQ)
	Method GravaLaudoLaboratorio(cUsuario, nRecnoQEK, cLaboratorio, cParecer, cJustifica, nRejeicao, cValidade)
	Method LaudoPodeSerEditado(nRecnoQEK, cLaboratorio, cNivelLaudo)
	Method ReabreInspecao(cUsuario, nRecnoQEK, lMedicao)
	Method RetornaLaudoGeral(nRecnoQEK)
	Method RetornaLaudoLaboratorio(nRecnoQEK, cLaboratorio)
	Method RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos()
	Method SugereParecerLaudo(cNivelLaudo, nRecnoInspecao, aLaboratorios, cUsuario, cError)
	Method UsuarioPodeConsultarLaudo(cUsuario, cNivelLaudo, cError)
	Method UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, cError)
	Method ValidaDataDeValidadeDoLaudo(dShelfLife, cReportSelected, cError)

	//Métodos Internos
	Method AtualizaCertificadoDaQualidade(lDesvincular)
	Method AtualizaFlagLegendaInspecao(cParecer, lMedicao, lMovimentouEstoque)
	Method AvaliaNecessidadeDeDirecionarParaGeralERedireciona(nRecnoInspecao, cPagina)
	Method AvaliaParecerLaboratorio(cAlias, cParecer)
	Method DefineParecerLaudos()
	Method DirecionaParaTelaDeLaudo(nLabsInspecao, nLabsUInsp, cUsuario, lLaudGeral)
	Method ModoAcessoLaudo(cLogin, cCampo)
	Method MovimentaEstoqueCQ(nRecnoQEK)
	Method QuantidadeLaboratoriosInspecao(nRecnoInspecao)
	Method QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario)
	Method ReabreInspecaoEEstornaMovimentosCQ(cLogin, nRecnoQEK, lMedicao, nOpc)
	Method SugereParecerLaudoGeral(nRecnoInspecao, aLaboratorios, cUsuario)
	Method SugereParecerLaudosLaboratorios(nRecnoInspecao, cParecer, aLaboratorios, cUsuario)
	Method SugereParecerSuperior(cParecer, cPriAprovado, cPriReprovado, cPriUrgente, cPriCondicional, cPriPendente, cParecerMed)
	Method ValidaRecnoValidoQEK(nRecnoQEK)

EndClass

METHOD New(oWSRestFul, cBlocoForcaErro) CLASS QIELaudosEnsaios
    Self:oWSRestFul      := oWSRestFul
	Self:oAPIManager     := QualityAPIManager():New(Nil, oWSRestFul)
	Default Self:cBlocoForcaErro := ".T."

	self:cParecerAprovado     := ""
	self:cParecerCondicional  := ""
	self:cParecerReprovado    := ""
	self:cParecerUrgente      := ""

Return Self

/*/{Protheus.doc} DirecionaParaTelaDeLaudo
Método Responsável por Realização do Direcionamento para a Página de Laudo
@author brunno.costa
@since  28/10/2024
@param 01 - nLabsInspecao, número, quantidade de laboratórios relacionados a inspeção atual
@param 02 - nLabsUInsp   , número, quantidade de laboratórios da inspeção que o usuário tem acesso
@param 03 - cUsuario     , caracter, login do usuário para checagem
@param 04 - cError       , caracter, retorna por referência erro na comparação
@return cPagina, caracter, caracter que indica o modelo de página de Laudo que o usuário será direcionado, sendo:
                          L  - Laudo via Laboratório
						  G  - Laudo Geral
						  LA - Laudo de Laboratório Agrupado (Similar ao via Operação, visualiza vários laboratórios, mas não grava Laudo Geral nem de Operação)
/*/
Method DirecionaParaTelaDeLaudo(nLabsInspecao, nLabsUInsp, cUsuario, cError) CLASS QIELaudosEnsaios
	
	//Local cError       := ""
	Local cNivelLaudo := ""
	Local cPagina     := ""

	Default nLabsInspecao := 1
	Default nLabsUInsp    := 1

	If nLabsInspecao == nLabsUInsp //Cenários SEM Restrições de Acesso a Laboratórios
		If     nLabsInspecao == 1
			cPagina     := "L"
			cNivelLaudo := "L"
		ElseIf nLabsInspecao >  1
			cPagina     := "G"
			cNivelLaudo := "G"
		EndIf
	Else                           //Cenários COM Restrições de Acesso a Laboratórios
		If nLabsInspecao >  1
			cPagina     := "LA"
			cNivelLaudo := "L"
		EndIf
	EndIf

	If !Self:UsuarioPodeGerarLaudo(cUsuario, "T")
		If cNivelLaudo == "G" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, "G", @cError)
			cPagina         := "LA"
			cNivelLaudo     := "L"
		EndIf
		If cNivelLaudo == "L" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, "L", @cError)
			cPagina         := ""
		EndIf
		If cNivelLaudo == "L" .AND. !Self:UsuarioPodeGerarLaudo(cUsuario, "G", @cError)
			cPagina         := "LA"
		EndIf
	EndIf

Return cPagina

/*/{Protheus.doc} DirecionaParaTelaDeLaudoPorInspecaoEUsuario
Método Responsável por Realização do Direcionamento para a Página de Laudo - Por Inspeção e Usuário
@author brunno.costa
@since  28/10/2024
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@param 02 - cUsuario      , caracter, login do usuário para checagem
@param 03 - cError        , caracter, retorna por referência erro na comparação
@return cPagina, caracter, caracter que indica o modelo de página de Laudo que o usuário será direcionado, sendo:
                          L  - Laudo via Laboratório
						  O  - Laudo via Operação
						  G  - Laudo Geral
						  OA - Laudo de Operação Agrupado (Similar ao Geral, visualiza várias operações, mas não grava Laudo Geral)
						  LA - Laudo de Laboratório Agrupado (Similar ao via Operação, visualiza vários laboratórios, mas não grava Laudo Geral nem de Operação)
						  X  - Usuário sem acesso a geração de Laudos
/*/
Method DirecionaParaTelaDeLaudoPorInspecaoEUsuario(nRecnoInspecao, cUsuario, cError) CLASS QIELaudosEnsaios
	
	Local cPagina       := "X"
	Local nLabsInspecao := Nil
	Local nLabsUInsp    := Nil

	If Self:UsuarioPodeGerarLaudo(cUsuario, "X", @cError)
		nLabsInspecao := Self:QuantidadeLaboratoriosInspecao(nRecnoInspecao) 
		nLabsUInsp    := Self:QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario) 
		cPagina       := Self:DirecionaParaTelaDeLaudo(nLabsInspecao, nLabsUInsp, cUsuario, @cError)
		cPagina       := Self:AvaliaNecessidadeDeDirecionarParaGeralERedireciona(nRecnoInspecao, cPagina)
	EndIf

	If cPagina != "G" .And. Self:RetornaLaudoGeral(nRecnoInspecao)['hasReport'] .And. Self:UsuarioPodeConsultarLaudo(cUsuario, "G", @cError)
		cPagina   := "G"
	EndIf

	Self:oApiManager:cErrorMessage := Iif(!Empty(cError) .AND. Empty(cPagina), cError, Self:oApiManager:cErrorMessage)

Return cPagina

/*/{Protheus.doc} AvaliaNecessidadeDeDirecionarParaGeralERedireciona
Avalia Necessidade de Direcionar Para Tela Laudo de Inspeção Geral, devido existência de laudo de Operação ou Laboratório
@author brunno.costa
@since  28/10/2024
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@param 02 - cPagina       , caracter, página de direcionamento atual
@return cPagina, caracter, página correta para direcionamento
/*/
Method AvaliaNecessidadeDeDirecionarParaGeralERedireciona(nRecnoInspecao, cPagina) CLASS QIELaudosEnsaios
	
	Local cFilQEL := xFilial("QEL")

	If cPagina == "L"
		QEK->(DbGoTo(nRecnoInspecao))
		QEL->(dbSetOrder(3))
		If QEL->(dbSeek(cFilQEL+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)))
			While cFilQEL+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE) == QEL->(QEL_FILIAL+QEL_FORNEC+QEL_LOJFOR+QEL_PRODUT+QEL_NISERI+QEL_TIPONF+DTOS(QEL_DTENTR)+QEL_LOTE)
				If !Empty(QEL->QEL_LAUDO) .AND. !Empty(QEL->QEL_LABOR)
					cPagina := "G"
					Exit
				EndIf
				QEL->(DbSkip())
			EndDo
		EndIf
	EndIf
	
Return cPagina

/*/{Protheus.doc} AvaliaAcessoATodaInspecao
Avalia acesso a inclusão de Laudo para toda a Operação
@author brunno.costa
@since  28/10/2024
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@param 02 - cUsuario      , caracter, login do usuário para checagem
@return lPermite, lógico, indica se permite acesso a inclusão de laudo em toda a operação
/*/
Method AvaliaAcessoATodaInspecao(nRecnoInspecao, cUsuario) CLASS QIELaudosEnsaios
	
	Local lPermite      := Nil
	Local nLabsInspecao := Nil
	Local nLabsUInsp    := Nil

	nLabsInspecao := Self:QuantidadeLaboratoriosInspecao(nRecnoInspecao) 
	nLabsUInsp    := Self:QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario) 

	lPermite := nLabsUInsp >= nLabsInspecao
	
Return lPermite


/*/{Protheus.doc} QuantidadeLaboratoriosInspecao
Retorna a quantidade de laboratórios relacionados a inspeção
@author brunno.costa
@since  28/10/2024
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@return nLabsInspecao, número, indica o número de laboratórios vinculados a inspeção
/*/
Method QuantidadeLaboratoriosInspecao(nRecnoInspecao) CLASS QIELaudosEnsaios
	
	Local cAlias        := ""
	Local cQuery        := ""
	Local nLabsInspecao := 0

	Default nRecnoInspecao := -1

	If nRecnoInspecao > 0
		cQuery += " SELECT COUNT(QE7_LABOR) COUNTLAB
		cQuery += "  FROM  "
		cQuery +=  " (SELECT QEK_PRODUT, QEK_REVI  "
		cQuery += "  FROM " + RetSQLName("QEK")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QEK_FILIAL = '" + xFilial("QEK") + "') "
		cQuery +=    " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
		cQuery +=  " ) QEK INNER JOIN  "
		cQuery +=  " (SELECT QE7_PRODUT, QE7_REVI, QE7_LABOR  "
		cQuery += "  FROM " + RetSQLName("QE7")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QE7_FILIAL = '"+xFilial("QE7")+"')  "
		cQuery += "  UNION  "
		cQuery += "  SELECT QE8_PRODUT, QE8_REVI, QE8_LABOR  "
		cQuery += "  FROM " + RetSQLName("QE8")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QE8_FILIAL = '"+xFilial("QE8")+"')  
		cQuery += " ) ENSAIOS "
		cQuery += " ON   QEK_PRODUT = QE7_PRODUT "
		cQuery +=  " AND QEK_REVI   = QE7_REVI "


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
@since  28/10/2024
@param 01 - nRecnoInspecao, número  , indica o Recno da Inspeção
@param 02 - cUsuario      , caracter, login do usuário para checagem
@return nLabsUInsp, número, indica o número de laboratórios vinculados a inspeção que o usuário possui acesso
/*/
Method QuantidadeLaboratoriosUsuarioInspecao(nRecnoInspecao, cUsuario) CLASS QIELaudosEnsaios
	
	Local cAlias     := ""
	Local cQuery     := ""
	Local nLabsUInsp := 0

	Default nRecnoInspecao := -1

	If nRecnoInspecao > 0
		
		Self:oAPIManager:AvaliaPELaboratoriosRelacionadosAoUsuario("QIE")

		cQuery += " SELECT COUNT(QE7_LABOR) COUNTLAB
		cQuery += "  FROM  "
		cQuery +=  " (SELECT QEK_PRODUT, QEK_REVI  "
		cQuery += "  FROM " + RetSQLName("QEK")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		cQuery +=    " AND (QEK_FILIAL = '" + xFilial("QEK") + "') "
		cQuery +=    " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ") "
		cQuery +=  " ) QEK INNER JOIN  "
		cQuery +=  " (SELECT QE7_PRODUT, QE7_REVI, QE7_LABOR  "
		cQuery += "  FROM " + RetSQLName("QE7")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ') "

		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QE7_LABOR", cUsuario, "incominginspectiontestreports/api/qie/v1/standardreportpage")
		EndIf

		cQuery +=    " AND (QE7_FILIAL = '"+xFilial("QE7")+"')  "
		cQuery += "  UNION  "
		cQuery += "  SELECT QE8_PRODUT, QE8_REVI, QE8_LABOR  "
		cQuery += "  FROM " + RetSQLName("QE8")
		cQuery += "  WHERE (D_E_L_E_T_ = ' ')  "
		
		If Self:oAPIManager:lPELaboratoriosRelacionadosAoUsuario
			cQuery +=   Self:oAPIManager:RetornaFiltroPELaboratoriosRelacionadosAoUsuario("QE8_LABOR", cUsuario, "incominginspectiontestreports/api/qie/v1/standardreportpage")
		EndIf

		cQuery +=    " AND (QE8_FILIAL = '"+xFilial("QE8")+"')  ) ENSAIOS "
		cQuery += " ON   QEK_PRODUT = QE7_PRODUT "
		cQuery +=  " AND QEK_REVI   = QE7_REVI "

		oExec := FwExecStatement():New(cQuery)
		cAlias := oExec:OpenAlias()

		If (cAlias)->(!Eof())
			nLabsUInsp := (cAlias)->COUNTLAB
		EndIf
		(cAlias)->(DbCloseArea())
	EndIf

Return nLabsUInsp

/*/{Protheus.doc} UsuarioPodeGerarLaudo
Indica se o usuário pode gerar laudo
@author brunno.costa
@since  28/10/2024
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
Method UsuarioPodeGerarLaudo(cUsuario, cNivelLaudo, cError) CLASS QIELaudosEnsaios
	
	Local lReturn    := .T.
	Local lLaudGeral := .F.
	Local lLaudLabor := .F.
	Local oLastError := ErrorBlock({|e| cError := (e:Description) +  Self:oApiManager:CallStack(), Break(e)} )

	Default cNivelLaudo := 'X'

	lLaudLabor := Self:ModoAcessoLaudo(cUsuario, "QAA_LDOLAB") == "1" //Inclusão / Edição
	lLaudGeral := Self:ModoAcessoLaudo(cUsuario, "QAA_LDOGER") == "1" //Inclusão / Edição

	lReturn := Iif(cNivelLaudo == 'L', lLaudLabor                  , lReturn)

	If !lReturn
		//STR0032 - 'Acesso negado. Solicite liberação no campo '
		//STR0033 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
		cError := STR0032 + ' "' + AllTrim(GetSx3Cache("QAA_LDOLAB","X3_TITULO")) + '" (QAA_LDOLAB)' + STR0033
	EndIf

	lReturn := Iif(cNivelLaudo == 'G', lLaudGeral                  , lReturn)
	lReturn := Iif(cNivelLaudo == 'X', lLaudLabor .OR. lLaudGeral  , lReturn)
	lReturn := Iif(cNivelLaudo == 'T', lLaudLabor .AND. lLaudGeral , lReturn)

	If !lReturn .AND. Empty(cError)
		//STR0032 - 'Acesso negado. Solicite liberação no campo '
		//STR0033 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
		cError := STR0032 + ' "' + AllTrim(GetSx3Cache("QAA_LDOGER","X3_TITULO")) + '" (QAA_LDOGER)' + STR0033
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
@return lLaudGeral, lógico, indica se o usuário pode consultar laudo geral
/*/
Method UsuarioPodeConsultarLaudo(cUsuario, cNivelLaudo, cError) CLASS QIELaudosEnsaios
	
	Local lReturn    := .T.
	Local lLaudGeral := .F.
	Local lLaudLabor := .F.
	Local oLastError := ErrorBlock({|e| cError := (e:Description) +  Self:oApiManager:CallStack(), Break(e)} )

	Default cNivelLaudo := 'X'

	lLaudLabor := Self:ModoAcessoLaudo(cUsuario, "QAA_LDOLAB") $ "|1|3|" //Inclusão / Edição ou Consulta
	lLaudGeral := Self:ModoAcessoLaudo(cUsuario, "QAA_LDOGER") $ "|1|3|" //Inclusão / Edição ou Consulta

	lReturn := Iif(cNivelLaudo == 'L', lLaudLabor                  , lReturn)

	If !lReturn
		//STR0032 - 'Acesso negado. Solicite liberação no campo '
		//STR0033 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
		cError := STR0032 + ' "' + AllTrim(GetSx3Cache("QAA_LDOLAB","X3_TITULO")) + '" (QAA_LDOLAB)' + STR0033
	EndIf

	lReturn := Iif(cNivelLaudo == 'G', lLaudGeral                  , lReturn)
	lReturn := Iif(cNivelLaudo == 'X', lLaudLabor .OR. lLaudGeral  , lReturn)
	lReturn := Iif(cNivelLaudo == 'T', lLaudLabor .AND. lLaudGeral , lReturn)

	If !lReturn .AND. Empty(cError)
		//STR0032 - 'Acesso negado. Solicite liberação no campo '
		//STR0033 - ' do seu cadastro de usuário (QIEA050) do Protheus.'
		cError := STR0032 + ' "' + AllTrim(GetSx3Cache("QAA_LDOGER","X3_TITULO")) + '" (QAA_LDOGER)' + STR0033
	EndIf

	ErrorBlock(oLastError)

Return lReturn

/*/{Protheus.doc} ModoAcessoLaudo
Indica o modo de acesso do usuário a gestão de laudos
@author brunno.costa
@since  23/05/2022
@param 01 - cLogin , caracter, login do usuário para validação das permissões de acesso
@param 02 - cCampo , caracter, campo para checagem do modo de acesso
@return cRetorno, caracter, indica o modo de acesso do usuário aos resultados das amostras do QIP:
							1 = Com Acesso;
							2 = Sem Acesso;
							3 = Apenas Consulta
/*/
METHOD ModoAcessoLaudo(cLogin, cCampo) CLASS QIELaudosEnsaios
     
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
@since 28/10/2024
@param 01 - cNivelLaudo  , caracter, indica o nível de laudo que deseja ser gerado:
									L - Laboratório
									G - Geral
									LA - Laboratórios Agrupados
@param 02 - nRecnoInspecao, número  , recno do registro da QEK relacionado a inspeção 
@param 03 - aLaboratorios , array   , relação de laboratórios para análise - em branco para todos
@param 04 - cUsuario      , caracter, usuário processando a sugestão de parecer
@param 05 - cError        , caracter, retorna por referência erro ocorrido
@return cParecer, lógico, indica se o usuário pode gerar laudo geral
/*/
Method SugereParecerLaudo(cNivelLaudo, nRecnoInspecao, aLaboratorios, cUsuario, cError) CLASS QIELaudosEnsaios
	
	Local cParecer   := "" //Default Ensaio Não Obrigatório Vazio
	Local oLastError := ErrorBlock({|e| cError := (e:Description) + Self:oApiManager:CallStack(), Break(e)} )

	Default aLaboratorios  := {}
	Default cError         := ""
	Default nRecnoInspecao := -1

	Begin Sequence
		
		&(Self:cBlocoForcaErro)

		Self:DefineParecerLaudos()

		If nRecnoInspecao > 0
			Self:cNivelLaudo := cNivelLaudo
			If cNivelLaudo == "L" .OR. cNivelLaudo == "LA"
				cParecer  := Self:SugereParecerLaudosLaboratorios(nRecnoInspecao, cParecer, aLaboratorios, cUsuario)
			Else
				cParecer := Self:SugereParecerLaudoGeral(nRecnoInspecao, aLaboratorios, cUsuario)
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
@since 28/10/2024
@param 01 - nRecnoInspecao, número  , recno do registro da QEK relacionado a inspeção 
@param 02 - cParecer      , caracter, parecer precedente a análise
@param 03 - aLaboratorios , array   , relação de laboratórios para análise - em branco para todos
@param 04 - cUsuario      , caracter, usuário processando a sugestão de parecer
@return cParecer, lógico, sugestão de paracer para o(s) Laboratório(s)
/*/
Method SugereParecerLaudosLaboratorios(nRecnoInspecao, cParecer, aLaboratorios, cUsuario) CLASS QIELaudosEnsaios
	
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
	Local nIndiceLabor    := 0
	Local nLaboratorios   := 0
	Local nPagina         := 1
	Local nTamPag         := 999999
	Local oEnsaiosAPI     := EnsaiosInspecaoDeEntradasAPI():New(Nil)
	
	Default aLaboratorios := {}
	Default cParecer      := "" //Default Ensaio Não Obrigatório Vazio

	nLaboratorios := Len(aLaboratorios)
	If nLaboratorios > 0
		For nIndiceLabor := 1 to nLaboratorios
			cAlias      := oEnsaiosAPI:CriaAliasEnsaiosPesquisa(nRecnoInspecao, aLaboratorios[nIndiceLabor], cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario)
			cParecerLab := Self:AvaliaParecerLaboratorio(cAlias, cParecer)
			(cAlias)->(DbCloseArea())
			
			If cParecerLab $ self:cParecerReprovado //Se REPROVADO, encerra a Análise
				cPriReprovado := cParecerLab
				Exit
			EndIf
			
			cPriAprovado    := Iif(Empty(cPriAprovado   ) .And. cParecerLab $ self:cParecerAprovado   , cParecerLab, cPriAprovado   )
			cPriCondicional := Iif(Empty(cPriCondicional) .And. cParecerLab $ self:cParecerCondicional, cParecerLab, cPriCondicional)
			cPriUrgente     := Iif(Empty(cPriUrgente    ) .And. cParecerLab $ self:cParecerUrgente    , cParecerLab, cPriUrgente    )
			cPriPendente    := Iif(Empty(cPriPendente   ) .And. (cParecerLab == Nil   ;
															.OR. cParecerLab == "PEND"   ;
															.OR. Empty(cParecerLab)   ) , "PEND", cPriPendente )

		Next nIndiceLabor

		cParecer := Self:SugereParecerSuperior(cParecer, cPriAprovado, cPriReprovado, cPriUrgente, cPriCondicional, cPriPendente, "")	
		
	Else
		cAlias   := oEnsaiosAPI:CriaAliasEnsaiosPesquisa(nRecnoInspecao, "", cOrdem, cTipoOrdem, nPagina, nTamPag, cCampos, cIDEnsaio, cUsuario)
		cParecer := Self:AvaliaParecerLaboratorio(cAlias, cParecer)
		(cAlias)->(DbCloseArea())
	EndIf

Return cParecer

/*/{Protheus.doc} AvaliaParecerLaboratorio
Avalia Parecer do Laboratório
@author brunno.costa
@since 28/10/2024
@param 01 - cAlias  , caracter, alias com os registros dos Ensaios do laboratório
@param 02 - cParecer, caracter, parecer precedente a análise
@return cParecer, lógico, sugestão de paracer para o Laboratório
/*/
Method AvaliaParecerLaboratorio(cAlias, cParecer) CLASS QIELaudosEnsaios

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
	Local cStatusMed      := ""

	While !(cAlias)->(Eof()) .And. !(cParecer $ self:cParecerReprovado)
		cLaudo        := Iif((cAlias)->QEL_LAUDO  == Nil, Nil, AllTrim((cAlias)->QEL_LAUDO ))
		cStatus       := Iif((cAlias)->STATUS     == Nil, Nil, Alltrim((cAlias)->STATUS    ))
		cStatusMed    := Iif((cAlias)->QER_RESULT == Nil, Nil, Alltrim((cAlias)->QER_RESULT))
		
		If cLaudo $ self:cParecerReprovado //Se REPROVADO, encerra a Análise
			cPriReprovado := cLaudo
			Exit
		EndIf

		cPriAprovado    := Iif(Empty(cPriAprovado   ) .And. cLaudo $ self:cParecerAprovado   , cLaudo, cPriAprovado   )
		cPriCondicional := Iif(Empty(cPriCondicional) .And. cLaudo $ self:cParecerCondicional, cLaudo, cPriCondicional)
		cPriUrgente     := Iif(Empty(cPriUrgente    ) .And. cLaudo $ self:cParecerUrgente    , cLaudo, cPriUrgente    )

		If((Self:cNivelLaudo == "L" .AND. Empty(cLaudo)) .OR. Empty(cLaudo))       // (cAlias)->ENSOBRI == "S" .AND. 
			If !(cStatus $ "|" + self:cParecerAprovado + "|" + self:cParecerReprovado + "|")

				QEK->(DbGoTo((cAlias)->RECNOQEK))

				//STR0037 - "Certificar"
				If OemToAnsi(STR0037) != QieSkpTst(QEK->QEK_FORNEC,QEK->QEK_LOJFOR,QEK->QEK_PRODUT,QE7->QE7_ENSAIO,QEK->QEK_DTENTR,QEK->QEK_LOTE,.F.,QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF,QEK->QEK_TIPONF)
					cPriReprovado := self:cPrimeiroReprovado                           //Se o ENSAIO é OBRIGATÓRIO e está PENDENTE, considera REPROVADO e encerra a Análise
					cPriPendente  := "PEND"
					Exit

				Else //Certifica Ensaio por Skip-Teste
					cStatusMed := cMedAprovada

				EndIf

			EndIf
		EndIf

		If cStatusMed == cMedAprovada .AND. cParecerMed != self:cPrimeiroReprovado //Se houver MEDIÇÃO aprovada, considera medição APROVADO
			cParecerMed := self:cPrimeiroAprovado
		ElseIf cStatusMed == cMedReprovada
			cParecerMed := self:cPrimeiroReprovado                                 //Se houver MEDIÇÃO reprovada, considera medição REPROVADO
		EndIf
		
		(cAlias)->(DbSkip())
	EndDo 
	
	cParecer := Self:SugereParecerSuperior(cParecer, cPriAprovado, cPriReprovado, cPriUrgente, cPriCondicional, cPriPendente, cParecerMed)
	
Return cParecer


/*/{Protheus.doc} SugereParecerLaudoGeral
Sugere Parecer para Laudo Geral
@author brunno.costa
@since 28/10/2024
@param 01 - nRecnoInspecao, número  , recno do registro da QEK relacionado a inspeção 
@param 02 - aLaboratorios , array   , relação de laboratórios para análise - em branco para todos
@param 03 - cUsuario      , caracter, usuário processando a sugestão de parecer
@return cParecer, lógico, sugestão de paracer para a inspeção
/*/
Method SugereParecerLaudoGeral(nRecnoInspecao, aLaboratorios, cUsuario) CLASS QIELaudosEnsaios
	
	Local cParecer      := ""

	cParecer  := Self:SugereParecerLaudosLaboratorios(nRecnoInspecao, cParecer, aLaboratorios, cUsuario)

Return cParecer

/*/{Protheus.doc} BuscaDataDeValidadeDoLaudo
Busca uma data de validade para sugerir na tela do laudo
@author brunno.costa
@since  28/10/2024
@param 01 - cProductID, numerico, produto da inspeção
@param 02 - cSpecificationVersion, caracter, Revisão do produto
@return dDataVal, date, indica a data de validade que será sugerido
/*/
Method BuscaDataDeValidadeDoLaudo(cProductID, cSpecificationVersion) CLASS QIELaudosEnsaios
	Local dDataVal := ""
	Local nDias    := 0
	Local oQltAPIManager := QualityAPIManager():New(nil, Self:oWSRestFul)

	If !(cProductID == Nil .And. cSpecificationVersion == Nil)
		DbSelectArea("QE6")
		QE6->(DbSetOrder(3))
		If QE6->(dbSeek(xFilial("QE6")+PADR( cProductID, oQltAPIManager:GetSx3Cache('QE6_PRODUT', 'X3_TAMANHO'))+cSpecificationVersion))
			If QE6->QE6_SHLF > 0
				DO Case
					Case QE6->QE6_UNSHEL == "1"
						nDias := QE6->QE6_SHLF
					Case QE6->QE6_UNSHEL == "2"
						nDias := QE6->QE6_SHLF * 30
					Case QE6->QE6_UNSHEL == "3"
						nDias := Int(QE6->QE6_SHLF / 24)
					Case QE6->QE6_UNSHEL == "4"
						nDias := QE6->QE6_SHLF * 365
				EndCase
				dDataVal := dDataBase + nDias
			EndIf
		EndIf
	EndIf

Return dDataVal

/*/{Protheus.doc} ValidaDataDeValidadeDoLaudo
Verifica se a data de validade do Laudo é valida
@author brunno.costa
@since  28/10/2024
@param 01 - dShelfLife, date, data a ser validada.
@param 02 - cReportSelected, String, descrição do laudo.
@param 03 - cError, String, mensagem de erro que será passada por referencia.
@return lReturn, lógico, indica se a data é válida ou não.
/*/
Method ValidaDataDeValidadeDoLaudo(dShelfLife, cReportSelected, cError) CLASS QIELaudosEnsaios
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
@since  28/10/2024
@param 01 - cUsuario  , caracter, Login do usuário
@param 02 - nRecnoQEK , número  , recno da inspeção relacionada na QEK
@param 03 - cParecer  , caracter, parecer do laudo.
@param 04 - cJustifica, caracter, justificativa de alteração da sugestão de parecer do laudo
@param 05 - nRejeicao , número  , quantidade rejeitada
@param 06 - cValidade , caracter, data de validade do laudo no formato JSON
@param 07 - lBaixaCQ , Logico, indica se o usuário deseja realizar a movimentação do estoque CQ.
@return lSucesso, lógico, indica se conseguiu realizar a gravação
/*/
Method GravaLaudoGeral(cUsuario, nRecnoQEK, cParecer, cJustifica, nRejeicao, cValidade, lBaixaCQ) CLASS QIELaudosEnsaios
	
	Local cFiLQEL         := xFilial("QEL")
	Local lInclui         := Nil
	Local lSucesso        := .F.
	Local nRecnoQEL       := -1
	Local oLastError      := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0005), Break(e)}) //"Falha na gravação do Laudo Geral"
	Local oObj            := Nil
	Local oQIEA215Estoque := Nil

	Default cJustifica := ""
	Default cParecer   := self:cPrimeiroReprovado
	Default cValidade  := ""
	Default nRecnoQEK  := -1
	Default nRejeicao  := 0

	//Força passagem por MATXALC para popular variável Static cRetCodUsr - DMANQUALI-9983 - DBRUnlock cannot be called in a transaction
	PCPDocUser(RetCodUsr(cUsuario))

	Begin Transaction
		Begin Sequence
			
			&(Self:cBlocoForcaErro)

			DbSelectArea("QEK")
			lSucesso := Self:ValidaRecnoValidoQEK(nRecnoQEK)

			If lSucesso .AND. !QEK->(Eof())

				dbSelectArea("QEL")
				QEL->(dbSetOrder(3))
				lInclui := !QEL->(dbSeek(cFiLQEL+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)+Space(GetSX3Cache("QEL_LABOR", "X3_TAMANHO"))))

				RecLock("QEL", lInclui)
				QEL->QEL_FILIAL	:= cFiLQEL
				QEL->QEL_PRODUT	:= QEK->QEK_PRODUT
				QEL->QEL_DTENTR	:= QEK->QEK_DTENTR
				QEL->QEL_LOTE	:= QEK->QEK_LOTE
				
				QEL->QEL_FORNEC	:= QEK->QEK_FORNEC
				QEL->QEL_LOJFOR	:= QEK->QEK_LOJFOR
				QEL->QEL_REVI	:= QEK->QEK_REVI
				QEL->QEL_NISERI	:= QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
				QEL->QEL_NTFISC	:= QEK->QEK_NTFISC
				QEL->QEL_SERINF	:= QEK->QEK_SERINF
				QEL->QEL_ITEMNF	:= QEK->QEK_ITEMNF
				QEL->QEL_TIPONF	:= QEK->QEK_TIPONF

				If QIEReinsp()
					QEL->QEL_NUMSEQ	:= QEK->QEK_NUMSEQ
				EndIf
				
				QEL->QEL_TAMLOT := cValToChar(QEK->QEK_TAMLOT)
				QEL->QEL_QTREJ  := cValToChar(nRejeicao)

				QEL->QEL_LAUDO  := cParecer
				QEL->QEL_JUSTLA := cJustifica
				QEL->QEL_DTVAL  := Self:oAPIManager:FormataDado("D", cValidade, "1", 8)

				If Empty(QEL->QEL_DTENLA)
					QEL->QEL_DTENLA := dDataBase
					QEL->QEL_HRENLA := Time()
				EndIf

				QEL->QEL_DTLAUD := dDataBase
				QEL->QEL_HRLAUD := Time()
				MsUnLock()

				nRecnoQEL := QEL->(Recno())

				If lBaixaCQ
					If FindClass("QIEA215Estoque")
						oQIEA215Estoque := QIEA215Estoque():New(-1)
						If !oQIEA215Estoque:validaPermissaoDeAcessoLiberacaoMATA175()
							lBaixaCQ := .F.
							lSucesso := .F.
						EndIf
					EndIf
				EndIf

				If lBaixaCq
					lBaixaCq := Self:MovimentaEstoqueCQ(nRecnoQEK,cUsuario)
				EndIf

				Self:AtualizaFlagLegendaInspecao(cParecer,.F.,lBaixaCQ,cUsuario)
				Self:AtualizaCertificadoDaQualidade(.F.)

				If Self:oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIE")
					oObj             := JsonObject():New()
					oObj["login"   ] := cUsuario
					oObj["recnoQEL"] := nRecnoQEL
					oObj["insert"  ] := lInclui
					oObj["update"  ] := !lInclui
					oObj["laudo"   ] := 'geral'
					Execblock('QIEINTAPI',.F.,.F.,{oObj, "incominginspectiontestreports/api/qie/v1/savegeneralreport", "QIELaudosEnsaios", "complementoLaudo"})
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
@since  28/10/2024
@param 01 - cUsuario    , caracter, Login de usuário
@param 02 - nRecnoQEK   , número  , recno da inspeção relacionada na QEK
@param 03 - cLaboratorio, caracter, recno da inspeção relacionada na QEK
@param 04 - cParecer    , caracter, parecer do laudo.
@param 05 - cJustifica  , caracter, justificativa de alteração da sugestão de parecer do laudo
@param 06 - nRejeicao   , número  , quantidade rejeitada
@param 07 - cValidade   , caracter, data de validade do laudo no formato JSON
@return lSucesso, lógico, indica se conseguiu realizar a gravação
/*/
Method GravaLaudoLaboratorio(cUsuario, nRecnoQEK, cLaboratorio, cParecer, cJustifica, nRejeicao, cValidade) CLASS QIELaudosEnsaios
	
	Local cFiLQEL    := xFilial("QEL")
	Local lInclui    := Nil
	Local lSucesso   := .T.
	Local nRecnoQEL  := -1
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0008), Break(e)}) //"Falha na gravação do Laudo de Laboratório"
	Local oObj       := Nil

	Default cJustifica   := ""
	Default cLaboratorio := "LABFIS"
	Default cParecer     := self:cPrimeiroReprovado
	Default cValidade    := ""
	Default nRecnoQEK    := -1
	Default nRejeicao    := 0

	Begin Transaction
		Begin Sequence

			&(Self:cBlocoForcaErro)

			DbSelectArea("QEK")
			lSucesso := Self:ValidaRecnoValidoQEK(nRecnoQEK)
			If lSucesso .AND. !QEK->(Eof())
				dbSelectArea("QEL")
				QEL->(dbSetOrder(3))
				lInclui := !QEL->(dbSeek(cFiLQEL+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)+cLaboratorio))
				
				RecLock("QEL", lInclui)
				QEL->QEL_FILIAL	:= cFiLQEL
				QEL->QEL_PRODUT	:= QEK->QEK_PRODUT
				QEL->QEL_DTENTR	:= QEK->QEK_DTENTR
				QEL->QEL_LOTE	:= QEK->QEK_LOTE
				
				QEL->QEL_FORNEC	:= QEK->QEK_FORNEC
				QEL->QEL_LOJFOR	:= QEK->QEK_LOJFOR
				QEL->QEL_REVI	:= QEK->QEK_REVI
				QEL->QEL_NISERI	:= QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF
				QEL->QEL_NTFISC	:= QEK->QEK_NTFISC
				QEL->QEL_SERINF	:= QEK->QEK_SERINF
				QEL->QEL_ITEMNF	:= QEK->QEK_ITEMNF
				QEL->QEL_TIPONF	:= QEK->QEK_TIPONF
				
				If QIEReinsp()
					QEL->QEL_NUMSEQ	:= QEK->QEK_NUMSEQ
				EndIf

				QEL->QEL_LABOR	:= cLaboratorio
				
				QEL->QEL_TAMLOT := cValToChar(QEK->QEK_TAMLOT)
				QEL->QEL_QTREJ  := cValToChar(nRejeicao)

				QEL->QEL_LAUDO  := cParecer
				QEL->QEL_JUSTLA := cJustifica
				QEL->QEL_DTVAL  := Self:oAPIManager:FormataDado("D", cValidade, "1", 8)


				If Empty(QEL->QEL_DTENLA)
					QEL->QEL_DTENLA := dDataBase
					QEL->QEL_HRENLA := Time()
				EndIf

				QEL->QEL_DTLAUD := dDataBase
				QEL->QEL_HRLAUD := Time()
				MsUnLock()

				nRecnoQEL := QEL->(Recno())

				Self:AtualizaFlagLegendaInspecao(cParecer,.F.,.F.,cUsuario)

				If Self:oAPIManager:existePEIntegracaoAppMinhaProducaoCompilado("QIE")
					oObj             := JsonObject():New()
					oObj["login"   ] := cUsuario
					oObj["recnoQEL"] := nRecnoQEL
					oObj["insert"  ] := lInclui
					oObj["update"  ] := !lInclui
					oObj["laudo"   ] := 'laboratorio'
					Execblock('QIEINTAPI',.F.,.F.,{oObj, "incominginspectiontestreports/api/qie/v1/savelaboratoryreport", "QIELaudosEnsaios", "complementoLaudo"})
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
Atualiza FLAG de legenda da inspeção - QEK_SITENT
@author brunno.costa
@since  28/10/2024
@param 01 - cParecer          , caracter, parecer do laudo.
@param 02 - lMedicao          , lógico  , indica se a inspeção possui medição
@param 03 - lMovimentouEstoque, lógico  , indica se a inspeção movimentou estoque CQ
@param 04 - cLogin            , caracter, login do usuário
/*/
Method AtualizaFlagLegendaInspecao(cParecer, lMedicao, lMovimentouEstoque, cLogin) CLASS QIELaudosEnsaios

		Local cQEKSITENT       := ""
		Local lLaudoParcial   := .F.
		Local lQEKLDAUTO      := !Empty(GetSx3Cache("QEK_LDAUTO","X3_CAMPO"))
		Local oQIEA215Aux     := Nil
		Local oQIEA215Estoque := Nil

		Default lMedicao 		   := .F.
		Default lMovimentouEstoque := .T.

		If FindClass("QIEA215AuxClass")
			oQIEA215Aux := QIEA215AuxClass():New()
			lLaudoParcial := oQIEA215Aux:possuiLaudoParcialSemLaudoGeral(cLogin)
		EndIf

		If Empty(self:cParecerAprovado)
			Self:DefineParecerLaudos()
		EndIf

		cQEKSITENT := Iif(Empty(cQEKSITENT) .AND. 	 lLaudoParcial                      , "7", cQEKSITENT) //Tem laudo parcial (operação ou laboratório sem geral)
		cQEKSITENT := Iif(Empty(cQEKSITENT) .AND. 	 cParecer $ self:cParecerAprovado   , "2", cQEKSITENT) //Aprovado
		cQEKSITENT := Iif(Empty(cQEKSITENT) .AND. 	 cParecer $ self:cParecerReprovado  , "3", cQEKSITENT) //Reprovado
		cQEKSITENT := Iif(Empty(cQEKSITENT) .AND. 	 cParecer $ self:cParecerUrgente    , "4", cQEKSITENT) //Urgente
		cQEKSITENT := Iif(Empty(cQEKSITENT) .AND. 	 cParecer $ self:cParecerCondicional, "5", cQEKSITENT) //Condicional
		cQEKSITENT := Iif(Empty(cQEKSITENT) .AND. 	 lMedicao	                        , "1", cQEKSITENT) //Tem medição e não tem laudo

		If !lMovimentouEstoque .And. cQEKSITENT $ "2345"
			If FindClass("QIEA215Estoque")
				oQIEA215Estoque := QIEA215Estoque():New(-1)
				If oQIEA215Estoque:lIntegracaoEstoqueHabilitada
					cQEKSITENT := "6" //Movimentacao de estoque pendente
				EndIf
			EndIf
		EndIf

		RecLock("QEK", .F.)

			QEK->QEK_SITENT := cQEKSITENT
			If lQEKLDAUTO
				QEK->QEK_LDAUTO := "0"
			EndIf

		QEK->(MSUnLock())
Return

/*/{Protheus.doc} AtualizaCertificadoDaQualidade
Atualiza Código do Certificado da Qualidade
@author brunno.costa
@since  28/10/2024
@param 01 - lDesvincular, lógico, indica se deve vincular (.F.) ou desvincular (.T.)
/*/
Method AtualizaCertificadoDaQualidade(lDesvincular) CLASS QIELaudosEnsaios
	Default lDesvincular := .F.
	RecLock("QEK", .F.)
		If lDesvincular
			QEK->QEK_CERQUA := ""
		Else
		If Empty(QEK->QEK_CERQUA) .AND. !Empty(QEK->QEK_SITENT)
			QEK->QEK_CERQUA := QA_SEQUSX6("QIP_CEQU",TamSX3("C2_CERQUA")[1],"S", STR0007) //"Certificado Qualidade"
		EndIf
	EndIf
	QEK->(MSUnLock())
Return

/*/{Protheus.doc} RetornaLaudoGeral
Retorna Laudo Geral
@author brunno.costa
@since  28/10/2024
@param 01 - nRecnoQEK , número  , recno da inspeção relacionada na QEK
@return oLaudo, json, objeto json com:
					  hasReport       , lógico  , indica se possui laudo geral
					  reportLevel     , caracter, indica o nível do laudo geral:
												G - Geral
					  reportSelected  , caracter, parecer do laudo
					  justification   , caracter, justificativa de alteração da sugestão de parecer do laudo
					  rejectedQuantity, número  , quantidade rejeitada
					  shelfLife       , data    , data de validade do laudo no formato JSON
/*/ 
Method RetornaLaudoGeral(nRecnoQEK) CLASS QIELaudosEnsaios
	
	Local oLaudo     := JsonObject():New()
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0010)}) //"Falha na consulta do Laudo Geral"

	Default nRecnoQEK  := -1

	oLaudo['hasReport'] := .F.

	DbSelectArea("QEK")
	Self:ValidaRecnoValidoQEK(nRecnoQEK)
	If !QEK->(Eof())
		dbSelectArea("QEL")
		QEL->(dbSetOrder(3))
		If QEL->(dbSeek(xFilial("QEL")+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)+Space(GetSX3Cache("QEL_LABOR", "X3_TAMANHO"))))
			If !Empty(QEL->QEL_LAUDO)
				oLaudo['hasReport']        := .T.
				oLaudo['reportLevel']      := "G"
				oLaudo['rejectedQuantity'] := QEL->QEL_QTREJ
				oLaudo['reportSelected']   := QEL->QEL_LAUDO
				oLaudo['justification']    := QEL->QEL_JUSTLA
				oLaudo['shelfLife']        := QEL->QEL_DTVAL
			EndIf
		EndIf
	EndIf

	ErrorBlock(oLastError)
	
Return oLaudo

/*/{Protheus.doc} RetornaLaudoLaboratorio
Retorna Laudo do Laboratório
@author brunno.costa
@since  28/10/2024
@param 01 - nRecnoQEK   , número  , recno da inspeção relacionada na QEK
@param 02 - cLaboratorio, caracter, recno da inspeção relacionada na QEK
@return oLaudo, json, objeto json com:
					  hasReport       , lógico  , indica se possui laudo de laboratório ou laudo geral
					  reportLevel     , caracter, indica o nível do laudo de laboratório:
												L - Laboratório
					  reportSelected  , caracter, parecer do laudo
					  justification   , caracter, justificativa de alteração da sugestão de parecer do laudo
					  rejectedQuantity, número  , quantidade rejeitada
					  shelfLife       , data    , data de validade do laudo no formato JSON
/*/
Method RetornaLaudoLaboratorio(nRecnoQEK, cLaboratorio) CLASS QIELaudosEnsaios
	
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0011)}) //"Falha na consulta do Laudo de Laboratório"
	Local oLaudo     := JsonObject():New()

	Default cLaboratorio := "LABFIS"
	Default nRecnoQEK    := -1

	oLaudo['hasReport'] := .F.

	DbSelectArea("QEK")
	Self:ValidaRecnoValidoQEK(nRecnoQEK)
	If !QEK->(Eof())
		dbSelectArea("QEL")
		QEL->(dbSetOrder(3))
		If QEL->(dbSeek(xFilial("QEL")+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)+cLaboratorio))
			If !Empty(QEL->QEL_LAUDO)
				oLaudo['hasReport']        := .T.
				oLaudo['reportLevel']      := "L"
				oLaudo['rejectedQuantity'] := QEL->QEL_QTREJ
				oLaudo['reportSelected']   := QEL->QEL_LAUDO
				oLaudo['justification']    := QEL->QEL_JUSTLA
				oLaudo['shelfLife']        := QEL->QEL_DTVAL
			EndIf
		EndIf
	EndIf

	If !oLaudo['hasReport']
		oLaudo := Self:RetornaLaudoGeral(nRecnoQEK)
	ENdIf

	ErrorBlock(oLastError)
	
Return oLaudo

/*/{Protheus.doc} ReabreInspecao
Reabertura da Inspeção - Exclui todos os Laudos de Laboratório, Operação e Geral
@author brunno.costa
@since  28/10/2024
@param 01 - cUsuario  , número  , caracter, login do usuário
@param 02 - nRecnoQEK , número  , recno da inspeção relacionada na QEK
@param 03 - lMedicao  , logico  , indica se tem medicao
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção ou se ela já aberta
/*/ 
Method ReabreInspecao(cUsuario, nRecnoQEK, lMedicao) CLASS QIELaudosEnsaios
	
	Local cFiLQEL    := xFilial("QEL")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0013), Break(e)}) //"Falha na reabertura da Inspeção"

	Default lMedicao  := .F.
	Default nRecnoQEK := -1

	Begin Transaction
		Begin Sequence

			&(Self:cBlocoForcaErro)

			If Self:UsuarioPodeGerarLaudo(cUsuario, "T")
				DbSelectArea("QEK")
				lSucesso := Self:ValidaRecnoValidoQEK(nRecnoQEK)
				If lSucesso .AND. !QEK->(Eof())

					dbSelectArea("QEL")
					QEL->(dbSetOrder(3))
					If QEL->(dbSeek(cFiLQEL+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)))
						While !QEL->(Eof())                                                    .AND.;
							QEL->QEL_FILIAL == cFiLQEL                                         .AND.;
							QEL->QEL_LOTE   == QEK->QEK_LOTE                                   .AND.;
							QEL->QEL_FORNEC	== QEK->QEK_FORNEC                                 .AND.;
							QEL->QEL_LOJFOR	== QEK->QEK_LOJFOR                                 .AND.;
							QEL->QEL_REVI	== QEK->QEK_REVI                                   .AND.;
							QEL->QEL_NISERI	== QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF .AND.;
							QEL->QEL_TIPONF	== QEK->QEK_TIPONF

							RecLock("QEL", .F.)
							QEL->(DbDelete())
							MsUnLock()

							QEL->(DbSkip())
						EndDo
					EndIf

					Self:AtualizaFlagLegendaInspecao("", lMedicao,,cUsuario)
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

/*/{Protheus.doc} LaudoPodeSerEditado
Indica se o Laudo Pode ser Editado
@author brunno.costa
@since  28/10/2024
@param 01 - nRecnoQEK   , número  , recno da inspeção relacionada na QEK
@param 02 - cLaboratorio, caracter, laboratório relacionado
@param 03 - cNivelLaudo, caracter, caracter que indica o modelo de página de Laudo:
                          L  - Laudo via Laboratório
						  O  - Laudo via Operação
						  G  - Laudo Geral
						  OA - Laudo de Operação Agrupado (Similar ao Geral, visualiza várias operações, mas não grava Laudo Geral)
						  LA - Laudo de Laboratório Agrupado (Similar ao via Operação, visualiza vários laboratórios, mas não grava Laudo Geral nem de Operação)
@return lPermite, lógico, indica se conseguiu reabrir a inspeção ou se ela já aberta
/*/ 
Method LaudoPodeSerEditado(nRecnoQEK, cLaboratorio, cNivelLaudo) CLASS QIELaudosEnsaios
	
	Local cFiLQEL    := xFilial("QEL")
	Local lLaudoGer  := .F.
	Local lLaudoLab  := .F.
	Local lPermite   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0014)}) //"Falha na consulta de permissão para edição de laudo"

	Default nRecnoQEK  := -1
	
	lPermite := Self:ValidaRecnoValidoQEK(nRecnoQEK)
	If lPermite .AND. !QEK->(Eof())
		dbSelectArea("QEL")
		QEL->(dbSetOrder(3))
		If QEL->(dbSeek(cFiLQEL+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)))
			While !QEL->(Eof())                                                        .AND.;
				   QEL->QEL_FILIAL  == cFiLQEL                                         .AND.;
				   QEL->QEL_LOTE    == QEK->QEK_LOTE                                   .AND.;
				   QEL->QEL_FORNEC	== QEK->QEK_FORNEC                                 .AND.;
				   QEL->QEL_LOJFOR	== QEK->QEK_LOJFOR                                 .AND.;
				   QEL->QEL_REVI	== QEK->QEK_REVI                                   .AND.;
				   QEL->QEL_NISERI	== QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF .AND.;
				   QEL->QEL_TIPONF	== QEK->QEK_TIPONF

				If !Empty(QEL->QEL_LAUDO)
					If Empty(QEL->QEL_LABOR)
						lLaudoGer := .T.
					ElseIf Empty(cLaboratorio) .OR. QEL->QEL_LABOR == cLaboratorio
						lLaudoLab := .T.
					EndIf
				EndIf

				QEL->(DbSkip())
			EndDo
		EndIf

	EndIf

	lPermite := Iif("L" $ cNivelLaudo, !lLaudoGer, lPermite)
	lPermite := Iif("G" $ cNivelLaudo, .T.       , lPermite)

	ErrorBlock(oLastError)
	
Return lPermite

/*/{Protheus.doc} ValidaRecnoValidoQEK
Indica se o Laudo Pode ser Editado
@author brunno.costa
@since  28/10/2024
@param 01 - nRecnoQEK   , número  , recno da inspeção relacionada na QEK
@return lValido, lógico, indica se o RECNO é válido na QEK
/*/ 
Method ValidaRecnoValidoQEK(nRecnoQEK) CLASS QIELaudosEnsaios
	Local lValido := .T.
	QEK->(DbGoTo(nRecnoQEK))
	If QEK->(Eof())
		lValido := .F.
		Self:oAPIManager:cDetailedMessage := STR0006 + cValToChar(nRecnoQEK) + "." //"Informe um recno de inspeção válido da tabela QEK: "
		Self:oAPIManager:cErrorMessage    := STR0006 + cValToChar(nRecnoQEK) + "." //"Informe um recno de inspeção válido da tabela QEK: "
	EndIf
Return lValido

/*/{Protheus.doc} ExcluiLaudoLaboratorio
Exclui Laudo do Laboratório
@author brunno.costa
@since  28/10/2024
@param 01 - cUsuario     , caracter, login de usuário relacionado
@param 02 - nRecnoQEK    , número  , recno da inspeção relacionada na QEK
@param 03 - cLaboratorio , caracter, laboratório relacionado
@param 04 - lMedicao     , logico  , indica se tem medicao
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção ou se ela já aberta
/*/ 
Method ExcluiLaudoLaboratorio(cUsuario, nRecnoQEK, cLaboratorio, lMedicao) CLASS QIELaudosEnsaios
	
	Local cError     := ""
	Local cFiLQEL    := xFilial("QEL")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0017 + cLaboratorio ), Break(e)}) //"Falha Exclusão Laudo do Laboratório " + cLaboratorio 

	Default cLaboratorio := "LABFIS"
	Default lMedicao     := .F.
	Default nRecnoQEK    := -1

	Begin Transaction
		Begin Sequence

			&(Self:cBlocoForcaErro)

			If Self:UsuarioPodeGerarLaudo(cUsuario, "L", @cError)
				If Self:LaudoPodeSerEditado(nRecnoQEK, "", "L")
					DbSelectArea("QEK")
					lSucesso := Self:ValidaRecnoValidoQEK(nRecnoQEK)
					If lSucesso .AND. !QEK->(Eof())

						dbSelectArea("QEL")
						QEL->(dbSetOrder(3))
						If QEL->(dbSeek(cFiLQEL+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)))
							While !QEL->(Eof())                                                        .AND.;
								   QEL->QEL_FILIAL  == cFiLQEL                                         .AND.;
								   QEL->QEL_LOTE    == QEK->QEK_LOTE                                   .AND.;
								   QEL->QEL_FORNEC	== QEK->QEK_FORNEC                                 .AND.;
								   QEL->QEL_LOJFOR	== QEK->QEK_LOJFOR                                 .AND.;
								   QEL->QEL_REVI	== QEK->QEK_REVI                                   .AND.;
								   QEL->QEL_NISERI	== QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF .AND.;
								   QEL->QEL_TIPONF	== QEK->QEK_TIPONF

								If cLaboratorio == QEL->QEL_LABOR .AND. !Empty(QEL->QEL_LABOR)
									
									RecLock("QEL", .F.)
									QEL->(DbDelete())
									MsUnLock()

								EndIf

								QEL->(DbSkip())
							EndDo
						EndIf
						Self:AtualizaFlagLegendaInspecao("", lMedicao,,cUsuario)
						Self:AtualizaCertificadoDaQualidade(.T.)

					EndIf
				Else
					lSucesso                       := .F.
					Self:oApiManager:cErrorMessage := STR0019 //"Este laudo não pode ser excluído, reabra a Inspeção ou exclua os laudos superiores."
					Self:oApiManager:lWarningError := .T.
				EndIf
			
			Else
				lSucesso                       := .F.
				Self:oApiManager:cErrorMessage := Iif(!Empty(cError), cError, STR0020) //"Usuário sem acesso a geração de laudo de laboratório."
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
@since  28/10/2024
@param 01 - cUsuario  , caracter, login de usuário relacionado
@param 02 - nRecnoQEK , número  , recno da inspeção relacionada na QEK
@param 04 - lMedicao  , logico  , indica se tem medicao
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção ou se ela já aberta
/*/ 
Method ExcluiLaudoGeral(cUsuario, nRecnoQEK, lMedicao) CLASS QIELaudosEnsaios
	
	Local cError     := ""
	Local cFiLQEL    := xFilial("QEL")
	Local lSucesso   := .T.
	Local oLastError := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0025), Break(e)}) //"Falha na Exclusão do Laudo Geral"

	Default lMedicao  := .F.
	Default nRecnoQEK := -1

	Begin Transaction
		Begin Sequence

			&(Self:cBlocoForcaErro)

			If Self:UsuarioPodeGerarLaudo(cUsuario, "G", @cError)
				DbSelectArea("QEK")
				lSucesso := Self:ValidaRecnoValidoQEK(nRecnoQEK)
				If lSucesso .AND. !QEK->(Eof())

					dbSelectArea("QEL")
					QEL->(dbSetOrder(3))
					If QEL->(dbSeek(cFiLQEL+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE)))
						While   !QEL->(Eof())                                                      .AND.;
								QEL->QEL_FILIAL == cFiLQEL                                         .AND.;
								QEL->QEL_LOTE   == QEK->QEK_LOTE                                   .AND.;
								QEL->QEL_FORNEC	== QEK->QEK_FORNEC                                 .AND.;
								QEL->QEL_LOJFOR	== QEK->QEK_LOJFOR                                 .AND.;
								QEL->QEL_REVI	== QEK->QEK_REVI                                   .AND.;
								QEL->QEL_NISERI	== QEK->QEK_NTFISC+QEK->QEK_SERINF+QEK->QEK_ITEMNF .AND.;
								QEL->QEL_TIPONF	== QEK->QEK_TIPONF

							If Empty(QEL->QEL_LABOR)
								
								RecLock("QEL", .F.)
								QEL->(DbDelete())
								MsUnLock()

							EndIf

							QEL->(DbSkip())
						EndDo
					EndIf

					Self:AtualizaFlagLegendaInspecao("", lMedicao,,cUsuario)
					Self:AtualizaCertificadoDaQualidade(.T.)

				EndIf
			
			Else
				lSucesso                       := .F.
				Self:oApiManager:cErrorMessage := Iif(!Empty(cError), cError, STR0024) //"Usuário sem acesso a geração de laudo geral."
				Self:oApiManager:lWarningError := .T.
			EndIf

		Recover

			lSucesso := .F.
			DisarmTransaction()

		End Sequence
	End Transaction

	ErrorBlock(oLastError)
	
Return lSucesso

/*/{Protheus.doc} ChecaTodosOsLaboratoriosComLaudos
Checa se Todos os Laboratórios Possuem Laudos
@author brunno.costa
@since  28/10/2024
@param 01 - cUsuario  , caracter, login de usuário relacionado
@param 02 - nRecnoQEK , número  , recno da inspeção relacionada na QEK
@return lTodosLaudos, lógico, indica que todos os laboratórios possuem laudos
/*/ 
Method ChecaTodosOsLaboratoriosComLaudos(cUsuario, nRecnoQEK) CLASS QIELaudosEnsaios
	Local cAlias                         := Nil
	Local lTodosLaudos                   := .T.
	Local oEnsaiosInspecaoDeEntradasAPI := EnsaiosInspecaoDeEntradasAPI():New(Nil)

	cAlias := oEnsaiosInspecaoDeEntradasAPI:CriaAliasEnsaiosPesquisa(nRecnoQEK, "", "", "", 1, 999999, "*", "", cUsuario)
	While (cAlias)->(!Eof())
		If Empty((cAlias)->QEL_LAUDO)
			lTodosLaudos := .F.
			Exit
		EndIf
		(cAlias)->(DbSkip())
	EndDo

Return lTodosLaudos

/*/{Protheus.doc} RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos
Verifica se há integração com outros módulos e retorna as mensagens de falha
@author brunno.costa
@since  30/10/2024
@return aMensagens, Array, Informa as mensagems de integração que serão exibidas. Caso vazio não será apresentado.
/*/ 
Method RetornaMensagensFalhaDevidoIntegracaoComOutrosModulos() CLASS QIELaudosEnsaios
	
	Local aMensagens := {}

	lIntQMT := Iif(lIntQMT == Nil, FindFunction("EAPPQIEQMT")            , lIntQMT)
	lIntQNC := Iif(lIntQNC == Nil, FindClass("FichasNaoConformidadesAPI"), lIntQNC)

	If GetMv("MV_QINTQMT") == 'S' .AND. !lIntQMT
		 aAdd(aMensagens, STR0026) //"Integração com Metrologia ativa. Utilize o Protheus para informar os instrumentos utilizados e preencher ou editar o Laudo"
	EndIf

	If GetMv("MV_QINTQNC") == 'S' .AND. !lIntQNC
		aAdd(aMensagens, STR0027) //"Integração com Controle de Não Conformidades ativa. Utilize o Protheus para informar NCs e preencher ou editar o Laudo"
	EndIf

Return aMensagens

/*/{Protheus.doc} MovimentaEstoqueCQ
Movimenta Estoque da QEK Automaticamente
@author brunno.costa
@since  21/03/2022
@param 01 - nRecnoQEK, numérico, recno do registro na QEK
@parma 02 - cUsuario , caracter, login do usuário
@Return - lSucesso, Lógico, indica se conseguiu realizar a movimentação
/*/
METHOD MovimentaEstoqueCQ(nRecnoQEK, cUsuario) CLASS QIELaudosEnsaios

	Local aHelpErro       := Nil
	Local bErrorBlock     := ErrorBlock({|e| Self:oAPIManager:ErrorBlock(e, STR0031 + e:Description), Break(e)}) // STR0031 - "Falha na movimentação de Estoque do CQ. "
	Local lQReinsp        := QieReinsp()
	Local lSucesso        := .F.
	Local oQIEA215Estoque := Nil

	If FindClass("QIEA215Estoque")
		oQIEA215Estoque := QIEA215Estoque():New(-1)
		QEL->(DbGoTop())//Força desposicionamento na QEL para tratar bug de posicionamento em registro de memória desatualizado
		lSucesso := oQIEA215Estoque:movimentaPendenciasEstoqueCQAutomaticamente(nRecnoQEK)

		If lSucesso
			QEK->(DbGoto(nRecnoQEK))
			QEL->(DbSetOrder(3)) //QEL_FILIAL+QEL_FORNEC+QEL_LOJFOR+QEL_PRODUT+QEL_NISERI+QEL_TIPONF+DTOS(QEL_DTENTR)+QEL_LOTE+QEL_LABOR+QEL_NUMSEQ
			QEL->(DbSeek(xFilial("QEL")+QEK->(QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+QEK_TIPONF+DTOS(QEK_DTENTR)+QEK_LOTE+Space(GetSX3Cache("QEL_LABOR", "X3_TAMANHO"))+Iif(lQReinsp, QEK_NUMSEQ, "")) ))
			Self:AtualizaFlagLegendaInspecao(QEL->QEL_LAUDO, .F., .T., cUsuario)
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
@author brunno.costa
@since  28/10/2024
@param 01 - cLogin, caracter, indica o Login do usuário da QAA
@param 02 - nRecnoQEK, numérico, indica o RECNO do registro da QEK relacionado
@param 03 - lMedicao, lógico, indicar se a inspeção contém medições
@param 04 - nOpc, numérico, indica quando a chamada foi realizada via APP
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção
/*/

METHOD ReabreInspecaoEEstornaMovimentosCQ(cLogin, nRecnoQEK, lMedicao, nOpc) CLASS QIELaudosEnsaios 
		
	Local lSucesso        := .F.
	Local lTemMovi        := .F.
	Local oQIEA215Estoque := Nil

	Default nOpc := 3

	//Força passagem por MATXALC para popular variável Static cRetCodUsr - DMANQUALI-9983 - DBRUnlock cannot be called in a transaction
	PCPDocUser(RetCodUsr(cLogin))

	BEGIN TRANSACTION

		If Self:AvaliaAcessoATodaInspecao(nRecnoQEK, cLogin)
			oQIEA215Estoque := QIEA215Estoque():New(nOpc)
			lSucesso := oQIEA215Estoque:estornaTodosMovimentosDeCQ(nRecnoQEK, @lTemMovi) 
				
			If lTemMovi .And. !lSucesso .And. nOpc == -1
				// STR0028 - Verifique se há saldo de estoque suficente para realização dos estornos e repita o processo.
				Self:oApiManager:cErrorMessage := STR0028
				Self:oApiManager:lWarningError := .T.
			Endif

			IF (lSucesso .OR. !lTemMovi) .And. !(lSucesso := Self:ReabreInspecao(cLogin, nRecnoQEK, lMedicao)) .And. nOpc == -1 
				If Empty(Self:oApiManager:cErrorMessage)
					// STR0029 - Não foi possivel realizar a reabertura da inspeção. Verifique se a inspeção está sendo editada por outro usuário."
					Self:oApiManager:cErrorMessage := STR0029
					Self:oApiManager:lWarningError := .T.
				EndIf
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
@author brunno.costa
@since  28/10/2024
@param 01 - cLogin, caracter, indica o Login do usuário da QAA
@param 02 - nRecnoQEK, numérico, indica o RECNO do registro da QEK relacionado
@param 03 - lMedicao, lógico, indicar se a inspeção contém medições
@return lSucesso, lógico, indica se conseguiu reabrir a inspeção
/*/
METHOD ExcluiLaudoGeralEEstornaMovimentosCQ(cLogin, nRecnoQEK, lMedicao) CLASS QIELaudosEnsaios 

	Local lSucesso        := .F.
	Local lTemMovi        := .F.
	Local oQIEA215Estoque := QIEA215Estoque():New(-1)

	Default nRecnoQEK  := -1
	Default lMedicao   := .F.

	BEGIN TRANSACTION
		
		lSucesso := oQIEA215Estoque:estornaTodosMovimentosDeCQ(nRecnoQEK, @lTemMovi)
			
		If lTemMovi .And. !lSucesso
			// STR0028 - Verifique se há saldo de estoque suficente para realização dos estornos e repita o processo.
			Self:oApiManager:cErrorMessage := STR0028
			Self:oApiManager:lWarningError := .T.
		Endif

		//IF (lSucesso .OR. !lTemMovi) .And. !(lSucesso := Self:ExcluiLaudoGeral(cLogin, nRecnoQEK, lMedicao))
		IF !(lSucesso := Self:ExcluiLaudoGeral(cLogin, nRecnoQEK, lMedicao))
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
METHOD DefineParecerLaudos() CLASS QIELaudosEnsaios 

	QED->(dbSetOrder(1))
	QED->(MsSeek(xFilial("QED")))
	While QED->(!Eof()) .AND. QED->QED_FILIAL == xFilial("QED")
		If QED->QED_CATEG     == "1"
			self:cParecerAprovado    += QED->QED_CODFAT
			self:cPrimeiroAprovado   := Iif(Empty(self:cPrimeiroAprovado), QED->QED_CODFAT, self:cPrimeiroAprovado)
		ElseIf QED->QED_CATEG == "2"
			self:cParecerCondicional += QED->QED_CODFAT
		ElseIf QED->QED_CATEG == "3"
			self:cParecerReprovado   += QED->QED_CODFAT
			self:cPrimeiroReprovado  := Iif(Empty(self:cPrimeiroReprovado), QED->QED_CODFAT, self:cPrimeiroReprovado)
		ElseIf QED->QED_CATEG == "4"
			self:cParecerUrgente     += QED->QED_CODFAT
		EndIf
		QED->(dbSkip())
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
Method SugereParecerSuperior(cParecer, cPriAprovado, cPriReprovado, cPriUrgente, cPriCondicional, cPriPendente, cParecerMed) CLASS QIELaudosEnsaios

	//Considera URGENTE - quando não houver laudo reprovado
	cParecer := Iif( !Empty(cPriUrgente  ), cPriUrgente, cParecer   ) 

	//Considera REPROVADO, quando houver ao menos uma e não houver liberação urgente
	cParecer    := Iif(!Empty(cPriReprovado);
	              .And. Empty(cPriUrgente  );
				  , cPriReprovado, cParecer)

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


