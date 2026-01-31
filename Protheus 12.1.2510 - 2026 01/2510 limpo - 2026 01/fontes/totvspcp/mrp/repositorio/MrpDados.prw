#INCLUDE 'protheus.ch'
#INCLUDE 'MrpDados.ch'

Static saMAT
Static soDominio     := Nil             //Instancia da camada de dominio
Static slTravaOut    := .F.
Static slTravaSE     := .T.
Static slTravaOCI    := .T.

Static snTamCod      := 90
Static sPRD_FILIAL   := 1
Static sPRD_COD      := 2
Static sPRD_ESTSEG   := 3
Static sPRD_LE       := 4 //Lote econômico.
Static sPRD_PE       := 5
Static sPRD_SLDDIS   := 6
Static sPRD_NIVEST   := 7
Static sPRD_CHAVE2   := 8
Static sPRD_NPERAT   := 9
Static sPRD_NPERMA   := 10 //Ultimo periodo permitido calcular - limitacao de bloqueio
Static sPRD_THREAD   := 11
Static sPRD_NPERCA   := 12 //Ultimo periodo calculado
Static sPRD_REINIC   := 13
Static sPRD_IDOPC    := 14
Static sPRD_HORFIR   := 15
Static sPRD_TPHOFI   := 16
Static sPRD_DTHOFI   := 17
Static sPRD_TIPE     := 18
Static sPRD_PPED     := 19
Static sPRD_REVATU   := 20
Static sPRD_TIPDEC   := 21
Static sPRD_NUMDEC   := 22
Static SPRD_ROTEIR   := 23
Static sPRD_QTEMB    := 24 //Qtd. Embalagem
Static sPRD_LM       := 25 //Lote Mínimo
Static sPRD_TOLER    := 26 //Tolerância
Static sPRD_TIPO     := 27
Static sPRD_GRUPO    := 28
Static sPRD_RASTRO   := 29
Static sPRD_MRP      := 30
Static sPRD_EMAX     := 31
Static sPRD_PROSBP   := 32
Static sPRD_LOTSBP   := 33
Static sPRD_ESTORI   := 34
Static sPRD_APROPR   := 35
Static sPRD_LOTVNC   := 36
Static sPRD_CPOTEN   := 37
Static sPRD_BLOQUE   := 38
Static sPRD_LSUBPR   := 39
Static sPRD_MOD      := 40
Static sPRD_LOCPAD   := 41
Static sPRD_LTTRAN   := 42
Static sPRD_CALCES   := 43
Static sPRD_AGLUT    := 44
Static sPRD_QB       := 45
Static sPRD_TRANSF   := 46
Static sPRD_FILCOM   := 47
Static sPRD_CALENS   := 48
Static sPRD_LMTRAN   := 49

Static sEST_FILIAL   := 1
Static sEST_CODPAI   := 2
Static sEST_CODFIL   := 3
Static sEST_QTD      := 4
Static sEST_FANT     := 5
Static sEST_TRT      := 6
Static sEST_GRPOPC   := 7
Static sEST_ITEOPC   := 8
Static sEST_VLDINI   := 9
Static sEST_VLDFIM   := 10
Static sEST_REVINI   := 11
Static sEST_REVFIM   := 12
Static sEST_ALTERN   := 13
Static sEST_FIXA     := 14
Static sEST_POTEN    := 15
Static sEST_PERDA    := 16
Static sEST_QTDB     := 17
Static sEST_OPERA    := 18
Static sEST_ARMCON   := 19

Static sMAT_FILIAL   := 1
Static sMAT_DATA     := 2
Static sMAT_PRODUT   := 3
Static sMAT_SLDINI   := 4
Static sMAT_ENTPRE   := 5
Static sMAT_SAIPRE   := 6
Static sMAT_SAIEST   := 7
Static sMAT_SALDO    := 8
Static sMAT_NECESS   := 9
Static sMAT_TPREPO   := 10
Static sMAT_EXPLOD   := 11
Static sMAT_THREAD   := 12
Static sMAT_IDOPC    := 13
Static sMAT_DTINI    := 14
Static sMAT_QTRENT   := 15
Static sMAT_QTRSAI   := 16
Static sTAM_MAT      := 16

Static sALT_FILIAL   := 1
Static sALT_PRODUT   := 2
Static sALT_ALTERT   := 3
Static sALT_FATOR    := 4
Static sALT_TPFAT    := 5
Static sALT_ORDEM    := 6
Static sALT_DATA     := 7

Static sOPC_KEY      := 1
Static sOPC_KEY2     := 2
Static sOPC_OPCION   := 3
Static sOPC_ID       := 4
Static sOPC_IDPAI    := 5
Static sOPC_IDMASTER := 6
Static sOPC_TABRECNO := 7
Static sOPC_RECNO    := 8
Static sOPC_FILIAIS  := 9
Static sOPC_DEFAULT  := 10

Static sCAL_FILIAL   := 1
Static sCAL_DATA     := 2
Static sCAL_HRINI    := 3
Static sCAL_HRFIM    := 4
Static sCAL_INTER    := 5
Static sCAL_UTEIS    := 6

Static sOPE_ROTE     := 1
Static sOPE_OPERA    := 2

Static sTRN_FILDES   := 1
Static sTRN_FILORI   := 2
Static sTRN_PRODUT   := 3
Static sTRN_DATA     := 4
Static sTRN_QUANT    := 5
Static sTRN_DOCUM    := 6

/*/{Protheus.doc} MrpDados
Classe para manipulação de dados via variaveis globais
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpDados FROM LongClassName

	DATA aFlagProd          AS ARRAY
	DATA oAglutinacao       AS OBJECT
	DATA oAlternativos      AS OBJECT
	DATA oCalendario        AS OBJECT
	DATA oCargaMemoria      AS OBJECT
	DATA oDominio           AS OBJECT
	DATA oEstruturas        AS OBJECT
	DATA oEventos           AS OBJECT
	DATA oJsonOpcionais     AS OBJECT
	DATA oLiveLock          AS OBJECT
	DATA oLogs              AS OBJECT
	DATA oMatriz            AS OBJECT
	DATA oOpcionais         AS OBJECT
	DATA oParametros        AS OBJECT
	DATA oPendencias        AS OBJECT
	DATA oPeriodos          AS OBJECT
	DATA oProdutos          AS OBJECT
	DATA oRastreio          AS OBJECT
	DATA oRastreioEntradas  AS OBJECT
	DATA oSeletivos         AS OBJECT
	DATA oSubProdutos       AS OBJECT
	DATA oTransferencia     AS OBJECT
	DATA oVersaoDaProducao  AS OBJECT
	DATA lReordena          AS LOGICAL
	DATA lCreate            AS LOGICAL

	METHOD new(oParametros, oPeriodos, lRecursiva) CONSTRUCTOR
	METHOD inicializaTabelas(lCreate)

	//Metodos pontuais de manipulação de dados em tabela
	METHOD gravaCampo()
	METHOD gravaLinha()
	METHOD retornaCampo()
	METHOD retornaLinha()
	METHOD retornaLista()
	METHOD tamanhoLista()
	METHOD posicaoCampo(cCampo)

	//Sets de atributos
	METHOD setOPeriodos(oPeriodos)
	METHOD setoDominio(oDominio)

	//Outros metodos
	METHOD atualizaMatriz(cFilAux, dData, cProduto, cIDOpc, aFields, aValores, cChave, lMantTrava, lFazLock, lAltTamPrd)
	METHOD criaMatriz(cFilAux, cProduto, cIDOpc, nPeriodo)
	METHOD decrementaTotalizador(cProduto)
	METHOD incrementaTotalizador(cProduto)
	METHOD existeMatriz(cFilAux, cProduto, nPeriodo, cChaveAux, cIDOpc)
	METHOD foiCalculado(cProduto, nPeriodo, lAvMinimo, nPerCal)
	METHOD gravaPeriodosProd(cProduto, nPerMinimo, nPerMaximo, nUltPerCal)
	METHOD gravaSaidaEstrutura(cFilAux, dData, cComponente, nQuantidade, nPerMinimo, cIDOpc, lMantTrava, lFazLock)
	METHOD possuiEstrutura(cFilAux, cProduto)
	METHOD possuiPendencia(cProduto, lNoThread, cIDOpc)
	METHOD limpaFlagProd()

	//Metodos para protecao de posicionamento.
	METHOD retornaArea()
	METHOD setaArea()
	METHOD trava()
	METHOD destrava()
	METHOD reservaProduto()
	METHOD liberaProduto()

	METHOD semaforoNiveis(cOpcao) //Controle de semáforo do calculo de niveis

	METHOD destruir(lForca)
ENDCLASS

/*/{Protheus.doc} MrpDados
Método construtor da classe MrpDados
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - oParametros, objeto  , Objeto JSON com todos os parametros do MRP - Consulte MRPAplicacao():parametrosDefault()
@param 02 - oPeriodos  , objeto  , array com as datas dos periodos de processamento
@param 04 - lRecursiva , numero  , indica se refere-se a execucao recursiva
/*/
METHOD new(oParametros, oPeriodos, lRecursiva) CLASS MrpDados

	Default lRecursiva := .F.

	::aFlagProd   := {}
	::oLogs       := MrpDados_Logs():New(oParametros["cFilAnt"])
	::oParametros := oParametros
	::oPeriodos   := oPeriodos
	::lReordena   := .F.

	If lRecursiva .or. ::oParametros["nOpcCarga"] == 2
		::inicializaTabelas(.F.)
	Else
		::inicializaTabelas(.T.)
	EndIf

	::oCargaMemoria := MrpDados_CargaMemoria():New( Self )

Return Self

/*/{Protheus.doc} inicializaTabelas
Inicializa tabela do MRP:
- MAT - Matriz de movimentos do MRP
- PRD - Parametros de produtos
- EST - Estruturas de produtos
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - lCreate   , logico, indica se deve instanciar novos objetos globais
/*/
METHOD inicializaTabelas(lCreate) CLASS MrpDados

	Local aSessoes   := {}
	Local cChaveExec := ::oParametros["cChaveExec"]
	Local nInd

	Default lCreate := .T.

	Self:lCreate := lCreate

	If lCreate .AND. (::oParametros["nOpcCarga"] != 2) //!Carga Movimento em Memória
		//Avalia controle de sessoes de variaveis globais e limpa residuos, caso necessario
		If VarIsUID( cChaveExec + "UIDs_PCPMRP")
			//Protege limpeza de memória
			VarBeginT( cChaveExec + "UIDs_PCPMRP", "UIDs_PCPMRP" )

			VarGetXA( cChaveExec + "UIDs_PCPMRP", @aSessoes)

			VarBeginT( cChaveExec + "UIDs_PCPMRP_LOCK", "UIDs_PCPMRP" )

			//Libera trecho de limpeza de memória
			VarEndT( cChaveExec + "UIDs_PCPMRP", "UIDs_PCPMRP" )

			VarClean(cChaveExec + "UIDs_PCPMRP")

			//Elimina residuos de variaveis globais
			If !Empty(aSessoes)
				VarGetXA( cChaveExec + "UIDs_PCPMRP", @aSessoes)
				VarEndT( cChaveExec + "UIDs_PCPMRP_LOCK", "UIDs_PCPMRP" )

				For nInd := 1 to Len(aSessoes)
					VarClean( aSessoes[nInd][1] )
				Next nInd
				aSessoes := FwFreeArray(aSessoes)
			Else
				VarEndT( cChaveExec + "UIDs_PCPMRP_LOCK", "UIDs_PCPMRP" )
			EndIf
		EndIf

		VarSetUID( cChaveExec + "UIDs_PCPMRP", .T.)
	EndIf

	::oMatriz := MrpData_Global():New( cChaveExec, "MAT", lCreate)
	::oMatriz:setlOrder ( .T. )

	::oProdutos := MrpData_Global():New( cChaveExec, "PRD", lCreate)
	::oProdutos:setlOrder( .T. )

	::oEstruturas := MrpData_Global():New( cChaveExec, "EST", lCreate)
	::oEstruturas:setlOrder( .T. )

	::oSubProdutos := MrpData_Global():New( cChaveExec, "SUB", lCreate)
	::oSubProdutos:setlOrder( .T. )

	::oAglutinacao := MrpData_Global():New( cChaveExec, "AGL", lCreate)
	::oAglutinacao:createAList("1", lCreate) //Carga de Demandas
	::oAglutinacao:createAList("2", lCreate) //Carga de Empenhos
	::oAglutinacao:createAList("3", lCreate) //Carga de Saídas Outras Previstas
	::oAglutinacao:createAList("4", lCreate) //Explosão de Estrutura
	::oAglutinacao:createAList("6", lCreate) //Transferências
	If lCreate
		::oAglutinacao:setFlag("1" + chr(13) + "cIDAuto" + chr(13), "DEM0000000")
		::oAglutinacao:setFlag("2" + chr(13) + "cIDAuto" + chr(13), "EMP0000000")
		::oAglutinacao:setFlag("3" + chr(13) + "cIDAuto" + chr(13), "SAI0000000")
	EndIf

	::oAlternativos := MrpData_Global():New( cChaveExec, "ALT", lCreate)
	::oAlternativos:setlOrder( .T. )
	::oAlternativos:createList("substituicoes_produtos", lCreate)
	::oAlternativos:createAList("substituicoes_dados", lCreate)
	::oAlternativos:createAList("min_max", lCreate)

	::oPendencias := MrpData_Global():New( cChaveExec, "PEN", lCreate)
	::oPendencias:setlOrder( .T. )

	::oLiveLock := MrpData_Global():New( cChaveExec, "LIVELOCK", lCreate)
	::oLiveLock:setlOrder( .T. )

	::oJsonOpcionais := MrpData_Global():New( cChaveExec, "OPC_JSON", lCreate)
	::oJsonOpcionais:setlOrder( .F. )

	::oOpcionais := MrpData_Global():New( cChaveExec, "OPC", lCreate)
	::oOpcionais:setlOrder( .F. )
	::oOpcionais:createAList("OPC_DEFAULT", lCreate)

	::oCalendario := MrpData_Global():New( cChaveExec, "CAL", lCreate)
	::oCalendario:setlOrder( .F. )

	::oVersaoDaProducao := MrpData_Global():New( cChaveExec, "_TAB*VDP_", lCreate)
	::oVersaoDaProducao:setlOrder( .F. )

	::oSeletivos := MrpData_Global():New( cChaveExec, "SELETIVOS", lCreate)
	::oSeletivos:setlOrder( .F. )

	::oEventos := MrpData_Global():New( cChaveExec, "EVENTOS", lCreate)
	::oEventos:setlOrder( .F. )

	::oEventos:createAList("001", lCreate)
	::oEventos:createAList("002", lCreate)
	::oEventos:createAList("003", lCreate)
	::oEventos:createAList("004", lCreate)
	::oEventos:createAList("005", lCreate)
	::oEventos:createAList("006", lCreate)
	::oEventos:createAList("007", lCreate)
	::oEventos:createAList("008", lCreate)
	::oEventos:createAList("009", lCreate)
	::oEventos:createAList("010", lCreate)
	::oEventos:createAList("011", lCreate)
	::oEventos:createAList("013", lCreate)
	::oEventos:createAList("Entradas", lCreate)

	::oRastreio := MrpDados_Rastreio():New(lCreate, Self)
	::oRastreio:oDados:createAList("LOTES_VENCIDOS", lCreate)

	::oRastreioEntradas := MrpData_Global():New( cChaveExec, "RASTRO_ENTR", lCreate)
	::oRastreioEntradas:setlOrder( .F. )

	::oTransferencia := MrpData_Global():New( cChaveExec, "TRN", lCreate)
	::oTransferencia:setlOrder( .T. )
	::oTransferencia:createAList("TRANSF_ESTOQUE", lCreate)

Return

/*/{Protheus.doc} atualizaMatriz
Atualiza registro da Matriz
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cFilAux    , caracter, Código da filial para processamento
@param 02 - dData      , data    , data da saida da estrutura
@param 03 - cProduto   , caracter, codigo do produto
@param 04 - cIDOpc     , caracter, ID do opcional
@param 05 - aFields    , array   , nomes dos campos para atualizar
@param 06 - aValores   , array   , valores dos campos para atualizar
@param 07 - cChave     , caracter, chave do registro na matriz
@param 08 - lMantTrava , lógico  , indica se deve manter a trava após saída da função - utilizado com rastreamento
@param 09 - lFazLock   , lógico  , Indica se deve ser feito o lock. Se este parâmetro for .F., a função chamadora deverá fazer o lock.
@param 10 - lAltTamPrd , lógico  , Indica se deve ser feito o PadR para forçar o tamanho do produto com snTamCod
@return lReturn, logico, indica se conseguiu atualizar a matriz
/*/
METHOD atualizaMatriz(cFilAux, dData, cProduto, cIDOpc, aFields, aValores, cChave, lMantTrava, lFazLock, lAltTamPrd) CLASS MrpDados

	Local aAux       := Array(sTAM_MAT)
	Local aRegistro
	Local cChaveProd := ""
	Local cFilProd   := ""
	Local lError     := .F.
	Local lReturn    := .T.
	Local nInd       := 0
	Local nTotal     := 0

	Default cIDOpc     := ""
	Default aFields    := {}
	Default aValores   := {}
	Default lMantTrava := .F.
	Default lFazLock   := .T.
	Default lAltTamPrd := .T.

	If lAltTamPrd
		cProduto := PadR(RTrim(cProduto), snTamCod)
	EndIf

	cChaveProd := cFilAux + cProduto + Iif(!Empty(cIDOpc), "|" + cIDOpc, "")
	cChave     := DtoS(dData) + cChaveProd
	cFilProd   := cFilAux + cProduto

	If lFazLock
		::oMatriz:trava(cChave)
	EndIf

	nTotal := Len(aFields)
	If ::oMatriz:getRow(1, cChave, Nil, @aRegistro, .F., slTravaSE)
		For nInd := 1 To nTotal
			aRegistro[&("s" + aFields[nInd])] += aValores[nInd]
		Next

		If !::possuiPendencia(cFilProd, .T., cIDOpc)
			::decrementaTotalizador(cChaveProd)
		EndIf

		If !::oMatriz:updRow(1, cChave, Nil, aRegistro, .F., slTravaSE)
			lReturn := .F.
		EndIf

		aRegistro := FwFreeArray(aRegistro)

	Else
		aAux[sMAT_FILIAL] := cFilAux
		aAux[sMAT_DATA]   := dData
		aAux[sMAT_PRODUT] := cProduto
		aAux[sMAT_SLDINI] := 0
		aAux[sMAT_ENTPRE] := 0
		aAux[sMAT_SAIPRE] := 0
		aAux[sMAT_SAIEST] := 0
		aAux[sMAT_SALDO]  := 0
		aAux[sMAT_NECESS] := 0
		aAux[sMAT_QTRENT] := 0
		aAux[sMAT_QTRSAI] := 0
		aAux[sMAT_TPREPO] := " "
		aAux[sMAT_EXPLOD] := .F.
		aAux[sMAT_THREAD] := -1
		aAux[sMAT_IDOPC]  := cIDOpc
		aAux[sMAT_DTINI]  := dData

		For nInd := 1 To nTotal
			aAux[&("s" + aFields[nInd])] += aValores[nInd]
		Next

		If !::existeMatriz(cFilAux, cProduto, , , cIDOpc) .OR. !::possuiPendencia(cFilProd, .T., cIDOpc)
			::decrementaTotalizador(cChaveProd)
		EndIf

		If !::oMatriz:addRow(cChave, aAux, .F., .F.,,cChaveProd)
			lReturn := .F.
		Else
			//Cria lista deste produto para registrar os periodos
			If !::oMatriz:existList("Periodos_Produto_" + cChaveProd)
				::oMatriz:createList("Periodos_Produto_" + cChaveProd)
			EndIf
			nPeriodo := ::oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, dData, .T.)
			::oMatriz:setItemList("Periodos_Produto_" + cChaveProd, cValToChar(nPeriodo), nPeriodo)
		EndIf

		::oMatriz:setFlag("cExistMAT_" + cChaveProd, .T., lError, .F.)

	EndIf

	If !lMantTrava
		::oMatriz:destrava(cChave)
	EndIf

	aAux := aSize(aAux, 0)

Return lReturn

/*/{Protheus.doc} criaMatriz
Cria registro na matriz com quantidades zeradas.

@author lucas.franca
@since 13/05/2022
@version 1.0
@param 01 - cFilAux    , caracter, Código da filial para processamento
@param 02 - cProduto   , caracter, codigo do produto
@param 03 - cIDOpc     , caracter, ID do opcional
@param 04 - nPeriodo   , numérico, número do período correspondente a dData
@return Nil
/*/
METHOD criaMatriz(cFilAux, cProduto, cIDOpc, nPeriodo) CLASS MrpDados
	Local aAux       := Array(sTAM_MAT)
	Local cChaveProd := cFilAux + cProduto + Iif(!Empty(cIDOpc), "|" + cIDOpc, "")
	Local cChave     := ""
	Local dData      := Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)

	cChave := DtoS(dData) + cChaveProd
	Self:oMatriz:trava(cChave)

	If Self:existeMatriz(cFilAux, cProduto, nPeriodo, , cIDOpc) == .F.

		aAux[sMAT_FILIAL] := cFilAux
		aAux[sMAT_DATA  ] := dData
		aAux[sMAT_PRODUT] := cProduto
		aAux[sMAT_SLDINI] := 0
		aAux[sMAT_ENTPRE] := 0
		aAux[sMAT_SAIPRE] := 0
		aAux[sMAT_SAIEST] := 0
		aAux[sMAT_SALDO ] := 0
		aAux[sMAT_NECESS] := 0
		aAux[sMAT_QTRENT] := 0
		aAux[sMAT_QTRSAI] := 0
		aAux[sMAT_TPREPO] := " "
		aAux[sMAT_EXPLOD] := .F.
		aAux[sMAT_THREAD] := -1
		aAux[sMAT_IDOPC ] := cIDOpc
		aAux[sMAT_DTINI ] := dData

		If Self:oMatriz:addRow(cChave, aAux, .F., .F.)
			//Cria lista deste produto para registrar os periodos
			If !Self:oMatriz:existList("Periodos_Produto_" + cChaveProd)
				Self:oMatriz:createList("Periodos_Produto_" + cChaveProd)
			EndIf
			Self:oMatriz:setItemList("Periodos_Produto_" + cChaveProd, cValToChar(nPeriodo), nPeriodo)
		EndIf

		Self:oMatriz:setFlag("cExistMAT_" + cChaveProd, .T., .F., .F.)
	EndIf

	Self:oMatriz:destrava(cChave)

	aSize(aAux, 0)
Return Nil

/*/{Protheus.doc} gravaSaidaEstrutura
Metodo responsavel por realizar a gravacao de saidas da estrutura
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cFilAux    , caracter, Código da filial para processamento
@param 02 - dData      , data    , data da saida da estrutura
@param 03 - cComponente, caracter, codigo do componente
@param 04 - nQuantidade, numerico, quantidade do componente
@param 05 - nPerMinimo , numerico, periodo minimo
@param 06 - cIDOpc     , caracter, ID do opcional
@param 07 - lMantTrava , lógico  , indica se deve manter a trava após saída da função - utilizado com rastreamento
@param 08 - lFazLock   , lógico  , Indica se deve ser feito o lock. Se este parâmetro for .F., a função chamadora deverá fazer o lock.
/*/
METHOD gravaSaidaEstrutura(cFilAux, dData, cComponente, nQuantidade, nPerMinimo, cIDOpc, lMantTrava, lFazLock) CLASS MrpDados

	Local cChave

	Default lFazLock := .T.

	//Atualiza ou inclui matriz
	::atualizaMatriz(cFilAux, dData, cComponente, cIDOpc, {"MAT_SAIEST"}, {nQuantidade}, @cChave, lMantTrava, lFazLock, .T.)

	//Atualiza periodo minimo de processamento do componente
	If nPerMinimo != Nil
		::gravaPeriodosProd(cFilAux + cComponente + Iif(!Empty(cIDOpc), "|" + cIDOpc, ""), nPerMinimo)
	EndIf

Return

/*/{Protheus.doc} gravaPeriodosProd
Grava periodos Minimo, Maximo e Ultimo Calculado do Produto
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cProduto  , caracter, codigo do produto
@param 02 - nPerMinimo, numero  , periodo minimo (DE)
@param 03 - nPerMaximo, numero  , periodo maximo (ATE)
@param 04 - nUltPerCal, numero  , ultimo periodo calculado
/*/
METHOD gravaPeriodosProd(cProduto, nPerMinimo, nPerMaximo, nUltPerCal) CLASS MrpDados

	Local aRetAux
	Local lAtual     := .F. //lAtual inicia sempre como .F. para pegar sempre dados atualizados. Outra thread pode ter modificado.
	Local lError     := .F.
	Local lReinicia
	Local nPerMinAtu := -1
	Local nPerMaxAtu := -1
	Local nUltPerAtu := -1
	Local nThreadRes := 0	//ID da Thread que realizou a reserva do registro
	Local lAtuPerCal := .F.

	Default nPerMinimo := -1
	Default nPerMaximo := -1
	Default nUltPerCal := -1

	::trava("PRD", cProduto)

	nPerMinimo := Iif(nUltPerCal > nPerMinimo .AND. nUltPerCal > 0, nUltPerCal, nPerMinimo)

	While !(nPerMinimo == Nil .and. nPerMaximo == Nil .and. nUltPerCal == Nil)

		//Alteracao periodo minimo (DE)
		If nPerMinimo != Nil .AND. nPerMinimo != -1
			aRetAux    := ::retornaCampo("PRD", 1, cProduto, {"PRD_NPERAT", "PRD_THREAD", "PRD_REINIC"}, @lError, lAtual, .F., .F., , ,.T. /*lVarios*/)
			If lError .AND. lAtual
				lError := .F.
				lAtual := .F.
				Sleep(50)
				Loop

			ElseIf lError
				lError := .F.
				Sleep(50)
				Loop
			EndIf
			nPerMinAtu := aRetAux[1]
			nThreadRes := aRetAux[2]
			lReinicia  := aRetAux[3]
			aRetAux    := aSize(aRetAux, 0)

			lAtual     := .T.
			If nPerMinAtu > nPerMinimo;  //Atualiza para tras
			   .OR. (nPerMinAtu >= nPerMinimo .AND. nThreadRes > 0 .AND. nThreadRes != ThreadID()); //Atualiza para tras
			   .OR. (!lReinicia .AND. nPerMinAtu <  nPerMinimo .AND. nThreadRes > 0 .AND. nThreadRes == ThreadID()) //Atualiza para frente

				If nThreadRes > 0 .AND. nThreadRes != ThreadID()
					If nPerMinAtu > nPerMinimo
						::gravaCampo("PRD", 1, cProduto, {"PRD_NPERAT", "PRD_REINIC"}, {nPerMinimo, .T.}, .T.,,, .T. /*lVarios*/)
					Else
						::gravaCampo("PRD", 1, cProduto, "PRD_REINIC", .T., .T.)
					EndIf
				Else
					::gravaCampo("PRD", 1, cProduto, "PRD_NPERAT", nPerMinimo, .T.)
				EndIf
				nUltPerAtu := ::retornaCampo("PRD", 1, cProduto, "PRD_NPERCA", @lError, .T.)
				::gravaCampo("PRD", 1, cProduto, "PRD_NPERCA", (nPerMinimo - 1), .T.)
				nPerMinimo := Nil
				lAtuPerCal := .T.
			Else
				If nThreadRes > 0 .AND. nThreadRes != ThreadID()
					::gravaCampo("PRD", 1, cProduto, "PRD_REINIC", .T., .T.)

				EndIf

				nPerMinimo := Nil
			EndIf
		Else
			nPerMinimo := Nil

		EndIf

		//Alteracao periodo maximo (ATE)
		If nPerMaximo != Nil .AND. nPerMaximo != -1
			nPerMaxAtu := ::retornaCampo("PRD", 1, cProduto, "PRD_NPERMA", @lError, lAtual, .F., .F.)
			If lError .AND. lAtual
				lError := .F.
				lAtual := .F.
				Sleep(50)
				Loop

			ElseIf lError
				lError := .F.
				Sleep(50)
				Loop

			EndIf
			lAtual     := .T.
			If (nPerMaxAtu > nPerMaximo .OR. (nPerMaxAtu == -1))
				::gravaCampo("PRD", 1, cProduto, "PRD_NPERMA", nPerMaximo, .T., .F., .F.)
				nPerMaximo := Nil
			Else
				nPerMaximo := Nil
			EndIf
		Else
			nPerMaximo := Nil
		EndIf

		//Alteracao ultimo periodo calculado
		If nUltPerCal != Nil .AND. nUltPerCal != -1
			nUltPerAtu := ::retornaCampo("PRD", 1, cProduto, "PRD_NPERCA", @lError, lAtual)
			If lError .AND. lAtual
				lError := .F.
				lAtual := .F.
				Sleep(50)
				Loop

			ElseIf lError
				lError := .F.
				Sleep(50)
				Loop

			EndIf
			lAtual     := .T.
			::gravaCampo("PRD", 1, cProduto, "PRD_NPERCA", nUltPerCal, .T., .F., .F.)
			nUltPerCal := Nil
			lAtuPerCal := .T.
		Else
			nUltPerCal := Nil
		EndIf
	EndDo

	If lAtuPerCal
		//Armazena a última thread que atualizou o período calculado deste produto.
		::oProdutos:setflag("PROD_THREAD_PER_CAL" + RTrim(cProduto), ThreadID(), .F., .F., .F., .F.)
		aAdd(::aFlagProd, RTrim(cProduto))
	EndIf

	::destrava("PRD", cProduto)

Return

/*/{Protheus.doc} limpaFlagProd
Limpa a flag de thread que atualizou o produto

@author    lucas.franca
@since     19/10/2022
@version 1.0
@return Nil
/*/
Method limpaFlagProd() Class MrpDados
	Local nTotal := Len(::aFlagProd)
	Local nIndex := 0

	For nIndex := 1 To nTotal
		::oProdutos:setflag("PROD_THREAD_PER_CAL" + RTrim(::aFlagProd[nIndex]), -1, .F., .F., .F., .F.)
	Next nIndex
	aSize(::aFlagProd, 0)
Return

/*/{Protheus.doc} possuiPendencia
Identifica se o produto possui pendencia de calculo
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cProduto , caracter, codigo do produto
@param 02 - lNoThread, logico  , considera true somente produtos sem reserva de Thread
@param 03 - cIDOpc   , caracter, ID do opcional relacionado
@return lReturn, logico, indica se o produto possui pendencias de calculo
/*/
METHOD possuiPendencia(cProduto, lNoThread, cIDOpc) CLASS MrpDados
	Local aAreaPRD    := Nil
	Local aRetAux
	Local cChaveProd
	Local lAtual      := .F.//(cProduto + Iif(!Empty(cIDOpc), "|" + cIDOpc, "")) == ::oProdutos:cCurrentKey
	Local lError      := .F.
	Local lReturn     := .F.
	Local nThreadRes  := 0
	Local nPerInicio

	Default lNoThread := .F.
	Default cIDOpc    := ""

	cChaveProd := cProduto + Iif(!Empty(cIDOpc), "|" + cIDOpc, "")

	If !lAtual
		aAreaPRD := ::retornaArea("PRD")
	EndIf

	If lNoThread
		aRetAux    := ::retornaCampo("PRD", 1, cChaveProd, {"PRD_NPERAT", "PRD_THREAD"} , @lError, lAtual, , , , , .T. /*lVarios*/)
		nPerInicio := aRetAux[1]
		nThreadRes := aRetAux[2]
		aRetAux := aSize(aRetAux, 0)
	Else
		nPerInicio := ::retornaCampo("PRD", 1, cChaveProd, "PRD_NPERAT" , @lError, lAtual)
	EndIf

	If nPerInicio <= ::oParametros["nPeriodos"] .and. nThreadRes <= 0
		lReturn := .T.
	EndIf

	If aAreaPRD != Nil
		::setaArea(aAreaPRD)
		aAreaPRD := aSize(aAreaPRD, 0)
	EndIf
Return lReturn

/*/{Protheus.doc} foiCalculado
Verifica se o produto ja foi calculado neste periodo.
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cProduto , caracter, codigo do produto a ser avaliado
@param 02 - nPeriodo , numero  , periodo a ser avaliado
@param 03 - lAvMinimo, logico  , indica se deve avaliar o periodo atual
            (se ultimo periodo calculado >= periodo atual, considera periodo anterior ao atual como ultimo calculado)
@param 04 - nPerCal  , numero  , retorna por referência o último período calculado
@return lReturn, logico, indica se o produto foi calculado no periodo
/*/
METHOD foiCalculado(cProduto, nPeriodo, lAvMinimo, nPerCal) CLASS MrpDados
	Local aAreaPRD   := Nil
	Local aRetAux
	Local lAtual     := .T.
	Local lError     := .F.
	Local lReturn    := .T.
	Local nUltPerCal

	Default lAvMinimo := .F.

	If cProduto != Self:oProdutos:cCurrentKey
		aAreaPRD := ::retornaArea("PRD")
		lAtual   := .F.
	EndIf

	If lAvMinimo
		aRetAux   := ::retornaCampo("PRD", 1, cProduto,	{"PRD_NPERCA", "PRD_NPERAT"}, @lError, lAtual /*lAtual*/, , , , , .T. /*lVarios*/)
		nUltPerCal := aRetAux[1]
		If nUltPerCal >= aRetAux[2]
			nUltPerCal := (aRetAux[2] - 1)
		EndIf
		aRetAux := aSize(aRetAux, 0)
	Else
		nUltPerCal := ::retornaCampo("PRD", 1, cProduto, "PRD_NPERCA" , @lError, lAtual)
	EndIf

	If nPeriodo > 0	.And. nPeriodo > nUltPerCal
		lReturn := .F.
	EndIf

	nPerCal := nUltPerCal

	If aAreaPRD != Nil
		::setaArea(aAreaPRD)
		aAreaPRD := aSize(aAreaPRD, 0)
	EndIf
Return lReturn

/*/{Protheus.doc} reservaProduto
Reserva PRD para esta Thread
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cProduto  , caracter, codigo do produto
@param 02 - nPerInicio, numero  , retorna por referencia o periodo minimo (DE)
@param 03 - nPerMaximo, numero  , retorna por referencia o periodo maximo (ATE)
@param 04 - lForca    , logico  , forca a liberacao quando o registro esta bloqueado para outra Thread
@param 05 - nUltPerCal, numero  , retorna por referencia o ultimo periodo calculado
@param 06 - cNivel    , caracter, retorna por referencia o nivel do produto
@param 07 - nThreadsLk, numero  , retorna por referencia a Thread que estava com o lock no registro
@return lReservou, logico, indica se conseguiu realizar a reserva do produto
/*/
METHOD reservaProduto(cProduto, nPerInicio, nPerMaximo, lForca, nUltPerCal, cNivel, nThreadsLk) CLASS MrpDados

	Local aPendencias := {}
	Local aRetAux
	Local lReservou   := .F.
	Local lTrava      := .F.
	Local lErrorPRD   := .F.
	Local lErrorPEN   := .F.
	Local nIndAux     := 0
	Local nThreadID   := ThreadID()
	Local nTotal      := 0

	Default lForca      := .F.
	Default nThreadsLk  := 0

	nThreadsLk := ::retornaCampo("PRD", 1, cProduto, "PRD_THREAD", @lErrorPRD, .F.)

	If nThreadsLk == nThreadID
		lReservou  := .T.

	ElseIf ((nThreadsLk <= 0) .OR. (lForca .and. nThreadsLk == 1))
		::oProdutos:trava(cProduto)
		lTrava     := .T.
		nThreadsLk := ::retornaCampo("PRD", 1 , cProduto, "PRD_THREAD", @lErrorPRD)
		If nThreadsLk <= 0 .or. (lForca .and. nThreadsLk == 1)
			::gravaCampo("PRD", 1, cProduto, "PRD_THREAD", nThreadID)

			lReservou  := .T.
		Else

			cNivel     := ::retornaCampo("PRD", 1 , cProduto, "PRD_NIVEST", @lErrorPRD)
			lReservou  := .F.
		EndIf
	EndIf

	If lReservou
		 aRetAux := ::retornaCampo("PRD", 1, cProduto, {"PRD_NPERAT", "PRD_NPERMA",;
		                                                "PRD_NPERCA", "PRD_NIVEST"}, @lErrorPRD, lTrava /*lAtual*/, , , , , .T. /*lVarios*/)

		nPerInicio := aRetAux[1]
		nPerMaximo := aRetAux[2]
		nUltPerCal := aRetAux[3]
		cNivel     := aRetAux[4]
		aRetAux := aSize(aRetAux, 0)

		nPerInicio := Iif(nPerInicio < 0, 1, nPerInicio)
		nPerMaximo := Iif(nPerMaximo < 0 .OR. nPerInicio > nPerMaximo, ::oParametros["nPeriodos"], nPerMaximo)

		If lTrava
			::oProdutos:destrava(cProduto)
		EndIf

		//Analisa pendencias Pais para limitar calculo ATE
		If nPerMaximo != ::oParametros["nPeriodos"]
			//Recupera array de pendencias pai deste componente
			aPendencias := ::retornaLinha("PEN", 1, cProduto, @lErrorPEN, .T.)
			lExecuta    := .T.
			If lErrorPEN
				nPerMaximo := ::oParametros["nPeriodos"]
			Else
				//Avalia array e grava menor periodo na PRD
				nTotal := Len(aPendencias)
				For nIndAux := 1 To nTotal
					If aPendencias[nIndAux][2] != -1
						If nPerMaximo == Nil .OR. aPendencias[nIndAux][2] < nPerMaximo
							nPerMaximo := aPendencias[nIndAux][2]
						EndIf
					EndIf
				Next nIndAux

				//TODO revisar/remover
				If nPerMaximo == Nil
					nPerMaximo := ::oParametros["nPeriodos"]
				EndIf
			EndIf
			aPendencias := FwFreeArray(aPendencias)
		EndIf
	ElseIf lTrava
		::oProdutos:destrava(cProduto)

	EndIf

Return lReservou

/*/{Protheus.doc} liberaProduto
Libera PRD para desta Thread
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cProduto, caracter, codigo do produto
@param 02 - lForca  , logico  , indica se forca a liberacao quando reservado para outra Thread
@return lLiberou, logico, indica se conseguiu liberar o produto
/*/
METHOD liberaProduto(cProduto, lForca) CLASS MrpDados

	Local lErrorPRD  := .F.
	Local lLiberou   := .F.

	Default lForca   := .F.

	//Nao trava registro para evitar deadlock
	If ::retornaCampo("PRD", 1, cProduto, "PRD_THREAD", @lErrorPRD, .F.) == ThreadID();
	   .OR. lForca
		::gravaCampo("PRD", 1, cProduto, "PRD_THREAD", 0, , ,.T.)
		lLiberou   := .T.
	EndIf

Return lLiberou

/*/{Protheus.doc} gravaCampo
Grava campo na tabela
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cTabela, array   , Array com os saldos em estoque
@param 02 - nIndice, numerico, indice da tabela
@param 03 - cChave , caracter, chave do registro na tabela
@param 04 - cCampo , caracter, nome do campo
@param 05 - oValor , variável, valor do campo
@param 06 - lAtual , logico  , indica se atualiza o posicionamento atual
@param 07 - lAcresc, logico  , acrescenta (soma)
@param 08 - lTrava , logico  , indica se deve travar o registro antes de gravar
@param 09 - lVarios, logico  , indica se realiza a gravacao de varios campos
@return lReturn, logico, indica se gravou o conteudo no campo
/*/
METHOD gravaCampo(cTabela, nIndice, cChave, cCampo, oValor, lAtual, lAcresc, lTrava, lVarios) CLASS MrpDados

	Local aRegistro
	Local cChaveGrv := ""
	Local lReturn   := .T.
	Local nAux      := 1
	Local nTotal    := 0
	Local oTabela   := Nil

	Default lAtual  := .F.
	Default lAcresc := .F.
	Default lTrava    := .F.
	Default lVarios   := .F.

	If oValor == Nil
		Return .F.
	EndIf

	If cTabela == "MAT"
		oTabela := ::oMatriz

	ElseIf cTabela == "PRD"
		oTabela := ::oProdutos

	ElseIf cTabela == "EST"
		oTabela := ::oEstruturas

	ElseIf cTabela == "TRN"
		oTabela := ::oTransferencia

	EndIf

	If lAtual
		aRegistro := oTabela:aCurrentRow
		cChaveGrv := oTabela:getcKeyCurrent()
		nIndice   := oTabela:getIndice()
	Else
		cChaveGrv := cChave
	EndIf

	//Trava registro da tabela
	::trava(cTabela, cChaveGrv)

	If lAtual .or. oTabela:getRow(nIndice, cChaveGrv, Nil, @aRegistro, .F., lTrava )	//(cKey, nPos, aReturn, lError, lTrava)
		If lVarios
			nTotal := Len(cCampo)
			For nAux := 1 To nTotal
				If lAcresc
					aRegistro[&("s"+cCampo[nAux])] += oValor[nAux]
				Else
					aRegistro[&("s"+cCampo[nAux])] := oValor[nAux]
				EndIf
			Next nAux
		Else
			If lAcresc
				aRegistro[&("s"+cCampo)] += oValor
			Else
				aRegistro[&("s"+cCampo)] := oValor
			EndIf
		EndIf
		oTabela:updRow(nIndice, cChaveGrv, Nil, aRegistro, .F., lTrava)
	Else
		lReturn   := .F.
	EndIf

	//Destrava registro da tabela
	::destrava(cTabela, cChaveGrv)

Return lReturn

/*/{Protheus.doc} retornaLinha
Retorna conteudo do campo na tabela
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cTabela   , array   , Array com os saldos em estoque
@param 02 - nIndice   , numerico, indice da tabela
@param 03 - cChave    , caracter, chave do registro na tabela
@param 04 - lError    , logico  , passagem por referencia para retornar erro
@param 05 - lTrava    , logico  , operacao com ou sem trava
@return oValor, variável, conteúdo do campo
/*/
METHOD retornaLinha(cTabela, nIndice, cChave, lError, lTrava) CLASS MrpDados

	Local aRegistro
	Local nPos      := 0
	Local oTabela
	Local oValor

	Default lError    := .F.

	If cTabela == "MAT"
		oTabela := ::oMatriz

	ElseIf cTabela == "PRD"
		oTabela := ::oProdutos

	ElseIf cTabela == "EST"
		oTabela := ::oEstruturas

	ElseIf cTabela == "SUB"
		oTabela := ::oSubProdutos

	ElseIf cTabela == "ALT"
		oTabela := ::oAlternativos

	ElseIf cTabela == "PEN"
		oTabela := ::oPendencias

	ElseIf cTabela == "CAL"
		oTabela := ::oCalendario

	ElseIf cTabela == "TRN"
		oTabela := ::oTransferencia

	EndIf

	nPos := oTabela:getnKey(nIndice, cChave, @lError, lTrava)
	oTabela:getRow(nIndice, Nil, nPos, @aRegistro, @lError, slTravaOut)

	If !lError
		oValor    := aRegistro
	EndIf

Return oValor

/*/{Protheus.doc} gravaLinha
Grava linha na tabela
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cTabela   , array   , Array com os saldos em estoque
@param 02 - nIndice   , numerico, indice da tabela
@param 03 - cChave    , caracter, chave do registro na tabela
@param 04 - aRegistro , array   , array com os dados da linha
@param 05 - lError    , logico  , passagem por referencia para retornar erro
@param 06 - lTrava     , logico  , operacao com ou sem trava
@return oValor, variável, conteúdo do campo
/*/
METHOD gravaLinha(cTabela, nIndice, cChave, aRegistro, lError, lTrava, lNova) CLASS MrpDados

	Local oTabela
	Local lReturn

	Default lError    := .F.
	Default lNova     := .F.

	If cTabela == "MAT"
		oTabela := ::oMatriz

	ElseIf cTabela == "PRD"
		oTabela := ::oProdutos

	ElseIf cTabela == "EST"
		oTabela := ::oEstruturas

	ElseIf cTabela == "SUB"
		oTabela := ::oSubProdutos

	ElseIf cTabela == "ALT"
		oTabela := ::oAlternativos

	ElseIf cTabela == "PEN"
		oTabela := ::oPendencias

	ElseIf cTabela == "CAL"
		oTabela := ::oCalendario

	ElseIf cTabela == "TRN"
		oTabela := ::oTransferencia

	EndIf

	IF lNova
		lReturn := oTabela:addRow(cChave, @aRegistro, @lError, slTravaOut)
	Else
		lReturn := oTabela:updRow(nIndice, cChave, Nil, @aRegistro, @lError, slTravaOut)
	EndIf

Return lReturn

/*/{Protheus.doc} retornaCampo
Retorna conteudo do campo na tabela
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cTabela    , array   , id da tabela
@param 02 - nIndice    , numerico, indice da tabela
@param 03 - cChave     , caracter, chave do registro na tabela
@param 04 - cCampo     , caracter, nome do campo
@param 05 - lError     , logico  , passagem por referencia para retornar erro
@param 06 - lAtual     , logico  , indica se deve retornar campo do registro
@param 07 - lPrimeiro  , logico  , indica se deve retornar campo do registro do primeiro registro do indice
@param 08 - lProximo   , logico  , indica se deve retornar campo do registro do proximo registro do indice
@param 09 - lSort      , logico  , indica se deve reordenar a tabela no indice referencia - em conjunto com ::lReordena
@param 10 - lExportacao, logico  , indica se os retornos sao sequenciais na operacao de exportacao
@param 11 - lVarios    , logico  , indica se retorna mais de um campo
@return oValor, variável, conteúdo do campo (ou dos campos)
/*/
METHOD retornaCampo(cTabela, nIndice, cChave, cCampo, lError, lAtual, lPrimeiro, lProximo, lSort, lExportacao, lVarios) CLASS MrpDados

	Local aRegistro
	Local cChaveAux
	Local nAux        := 0
	Local nPos        := 0
	Local oTabela     := Nil
	Local oValor      := Nil

	Default lError    := .F.
	Default lAtual    := .F.
	Default lPrimeiro := .F.
	Default lProximo  := .F.
	Default lSort     := .T.
	Default lVarios   := .F.

	If cTabela == "MAT"
		oTabela := ::oMatriz

	ElseIf cTabela == "PRD"
		oTabela := ::oProdutos

	ElseIf cTabela == "EST"
		oTabela := ::oEstruturas

	ElseIf cTabela == "SUB"
		oTabela := ::oSubProdutos

	ElseIf cTabela == "ALT"
		oTabela := ::oAlternativos

	ElseIf cTabela == "OPC"
		oTabela := ::oOpcionais

	ElseIf cTabela == "CAL"
		oTabela := ::oCalendario

	ElseIf cTabela == "TRN"
		oTabela := ::oTransferencia

	EndIf

	//Reordena apos alteracao de campo chave
	If (::lReordena .AND. oTabela:getlOrder())
		oTabela:order(cTabela, nIndice, @lError)

	EndIf

	If lAtual .and. oTabela:nCurrentKey != Nil .and. oTabela:nCurrentKey > 0
		nPos      := oTabela:nCurrentKey
		aRegistro := oTabela:aCurrentRow

	ElseIf lAtual .and. oTabela:cCurrentKey != Nil .and. !Empty(oTabela:cCurrentKey)
		aRegistro := oTabela:aCurrentRow
		cChaveAux := oTabela:cCurrentKey

	ElseIf lAtual
		lPrimeiro := .T.
		lAtual    := .F.

	EndIf

	If lPrimeiro
		nPos := 1

	ElseIf lProximo
		If oTabela:nCurrentKey != Nil .and. oTabela:nCurrentKey > 0
			nPos := oTabela:nCurrentKey
			nPos := nPos + 1

		ElseIf !Empty(oTabela:cCurrentKey)
			aRegistro := oTabela:aCurrentRow
			cChaveAux := oTabela:cCurrentKey
			nPos      := oTabela:getnKey(oTabela:nIndice, cChaveAux, lError, slTravaOut)
			nPos      := nPos + 1

		Else
			nPos := 1
		EndIf

		If lExportacao
			If Empty(saMAT)
				saMAT := ::retornaLista(cTabela, @lError)
			EndIf
			aRegistro := saMAT[nPos][2]
		Else
			oTabela:getRow(nIndice, Nil, nPos, @aRegistro, @lError, slTravaOut)
		EndIf

	ElseIf !lAtual .AND. nIndice == 1
		cChaveAux := cChave
		If (nPos == 0 .Or. nPos == Nil) .AND. Empty(cChaveAux)
			lError    := .T.
			nPos      := 0
		EndIf

	ElseIf !lAtual .AND. nIndice == 2
		//TODO - Revisar utilizacao e performance, possibilidade de remover referente redundancia com Dados_Global..
		nPos     := oTabela:getnKey(nIndice, cChave, lError, slTravaOut)
		If nPos == 0 .Or. nPos == Nil
			lError := .T.
			nPos := 0
		Else
			cChaveAux := cChave
		EndIf

	EndIf

	If nPos == 0 .AND. Empty(cChaveAux)
		lError := .T.
	EndIf

	If !lError .and. Empty(aRegistro)
		If lExportacao
			If Empty(saMAT)
				saMAT := ::retornaLista(cTabela, @lError)
			EndIf
			//aRegistro := saMAT[nPos][2][1][2]
			aRegistro := saMAT[nPos][2]

		ElseIf !oTabela:getRow(nIndice, cChaveAux, nPos, @aRegistro, @lError, slTravaOut)
			lError := .T.
		EndIf
	EndIf

	If !lError
		If lVarios
			oValor    := {}
			For nAux := 1 to Len(cCampo)
				aAdd(oValor, aRegistro[&("s"+cCampo[nAux])])
			Next nAux
		Else
			oValor    := aRegistro[&("s"+cCampo)]
		EndIf
	EndIf

	If !lAtual
		oTabela:nCurrentKey := nPos
		oTabela:nIndice     := nIndice
		oTabela:cCurrentKey := cChaveAux
	EndIf

Return oValor

/*/{Protheus.doc} tamanhoLista
Retorna o tamanho da tabela/lista
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cTabela    , array   , id da tabela/lista
@return nTamanho, numero, tamanho da lista
/*/
METHOD tamanhoLista(cTabela)  CLASS MrpDados
	Local nTamanho
	Local oTabela

	If cTabela == "MAT"
		oTabela := ::oMatriz

	ElseIf cTabela == "PRD"
		oTabela := ::oProdutos

	ElseIf cTabela == "EST"
		oTabela := ::oEstruturas

	ElseIf cTabela == "SUB"
		oTabela := ::oSubProdutos

	ElseIf cTabela == "ALT"
		oTabela := ::oAlternativos

	ElseIf cTabela == "CAL"
		oTabela := ::oCalendario

	EndIf

	nTamanho := oTabela:getRowsNum()

Return nTamanho

/*/{Protheus.doc} tamanhoLista
Retorna a lista/tabela
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cTabela, array , id da tabela/lista
@param 02 - lError , logico, retorna ocorrencia de erro por referencia
@param 03 - lSort  , logico, indica se deve reordenar a tabela
@return aTabela, array, array com os dados da tabela/lista
/*/
METHOD retornaLista(cTabela, lError, lSort)  CLASS MrpDados

	Local aTabela := {}
	Local lHash   := .F.
	Local oTabela
	Local oHash

	Default lSort := .F.

	If cTabela == "MAT"
		oTabela := ::oMatriz

	ElseIf cTabela == "PRD"
		oTabela := ::oProdutos

	ElseIf cTabela == "EST"
		oTabela := ::oEstruturas

	ElseIf cTabela == "SUB"
		oTabela := ::oSubProdutos

	EndIf

	If Empty(saMAT)
		oTabela:getAllRow(@aTabela, @lError)

		If lHash
			oHash   := AToHM( aTabela, 1, 0 )
			aSize(aTabela, 0)
			If !lError
				lError := !HMList(oHash, @aTabela )
			EndIf
			oHash := NIL
		Else
			If lSort
				aTabela := aSort(aTabela, , , {|x,y| "|"+x[1]+"|" < "|"+y[1]+"|" })
			EndIf
		EndIf
	Else
		aTabela := saMAT
	EndIf

Return aTabela

/*/ {Protheus.doc} possuiEstrutura
Verifica se o produto possui estrutura
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cFilAux , caracter, codigo da filial para processamento
@param 02 - cProduto, caracter, codigo do produto
@return     lReturn, logico, indica se possui estrutura
/*/
METHOD possuiEstrutura(cFilAux, cProduto) CLASS MrpDados
	Local cChaveEst := cProduto
	Local lReturn   := .F.
	Local lError    := .F.

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
		cChaveEst := Self:oDominio:oMultiEmp:getFilialTabela("T4N", cFilAux) + cProduto
	EndIf

	If ::oEstruturas:getnKey(1, cChaveEst, @lError) > 0 .AND. !lError
		lReturn := .T.
	EndIf
Return lReturn

/*/{Protheus.doc} retornaArea
Retorna a area atual do alias especifico
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cTabela, array   , Array com os saldos em estoque
@return aResultados, array, Array com os resultados do MAT {Data, Produto, Necessidade, Saida Estrutura}
/*/
METHOD retornaArea(cTabela) CLASS MrpDados

	Local aReturn   := Array(5)
	Local oTabela

	If cTabela == "MAT"
		oTabela := ::oMatriz

	ElseIf cTabela == "PRD"
		oTabela := ::oProdutos

	ElseIf cTabela == "EST"
		oTabela := ::oEstruturas

	ElseIf cTabela == "SUB"
		oTabela := ::oSubProdutos

	EndIf

	aReturn[1] := cTabela
	aReturn[2] := oTabela:nIndice
	aReturn[3] := oTabela:nCurrentKey
	aReturn[4] := oTabela:aCurrentRow
	aReturn[5] := oTabela:cCurrentKey

Return aClone(aReturn)

/*/{Protheus.doc} setaArea
Restaura uma area atual
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - aArea, array   , Array com area a ser restaurada
/*/
METHOD setaArea(aArea) CLASS MrpDados

	Local cTabela    := aArea[1]
	Local oTabela

	If cTabela == "MAT"
		oTabela := ::oMatriz

	ElseIf cTabela == "PRD"
		oTabela := ::oProdutos

	ElseIf cTabela == "EST"
		oTabela := ::oEstruturas

	ElseIf cTabela == "SUB"
		oTabela := ::oSubProdutos

	EndIf

	oTabela:nIndice     := aArea[2]
	oTabela:nCurrentKey := aArea[3]
	oTabela:aCurrentRow := aArea[4]
	oTabela:cCurrentKey := aArea[5]

Return

/*/{Protheus.doc} destruir
Destroi os objetos e variaveis da camada de dados
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - lForca, lógico, força VarClean
/*/
METHOD destruir(lForca) CLASS MrpDados
	Local aSessoes
	Local cChaveExec := ::oParametros["cChaveExec"]
	Local oPCPError  := Nil
	Local oStatus    := MrpDados_Status():New(::oParametros["ticket"])

	Default lForca := .F.

	::oAlternativos:destroy()
	::oEstruturas:destroy()
	::oSubProdutos:destroy()
	::oMatriz:destroy()
	::oLiveLock:destroy()
	::oJsonOpcionais:destroy()
	::oOpcionais:destroy()
	::oPendencias:destroy()
	::oProdutos:destroy()
	::oCalendario:destroy()
	::oTransferencia:destroy()
	::oRastreioEntradas:destroy()
	::oRastreio:destruir()
	::oAglutinacao:cleanAList("1")
	::oAglutinacao:cleanAList("2")
	::oAglutinacao:cleanAList("3")
	::oAglutinacao:cleanAList("4")
	::oAglutinacao:destroy()
	::oEventos:cleanAList("001")
	::oEventos:cleanAList("002")
	::oEventos:cleanAList("003")
	::oEventos:cleanAList("004")
	::oEventos:cleanAList("005")
	::oEventos:cleanAList("006")
	::oEventos:cleanAList("007")
	::oEventos:cleanAList("008")
	::oEventos:cleanAList("009")
	::oEventos:cleanAList("010")
	::oEventos:cleanAList("Entradas")
	::oEventos:destroy()
	::oVersaoDaProducao:destroy()
	::oSeletivos:destroy()

	saMAT := FwFreeArray(saMAT)

	//Delega Limpeza de Memória
	oPCPError := PCPMultiThreadError():New("DESTROI_DADOS_" + ::oParametros["ticket"] + UUIDRandom(), .T.)

	oStatus:setStatus("limpaStatus", .F.)
	oPCPError:startJob("PCPCleanVr", GetEnvServer(), .F., Nil, Nil, ::oParametros["cChaveExec"], ::oParametros["ticket"], ::oParametros["lAguardaDescarga"], (Self:lCreate .OR. lForca), /*oVar05*/, /*oVar06*/, /*oVar07*/, /*oVar08*/, /*oVar09*/, /*oVar10*/, /*bRecover*/, /*cRecover*/, .F.)

	If !oPCPError:abriuUltimaThread()
		oStatus:setStatus("limpaStatus", .T.)
		LogMsg('MrpDados', 0, 0, 1, '', '', i18n("[#1[data]# - #2[hora]#] - Nao foi possivel abrir thread para executar a funcao PCPCleanVr. Executando em thread unica.", {DToC(Date()), Time()}))
		PCPCleanVr(::oParametros["cChaveExec"], ::oParametros["ticket"], ::oParametros["lAguardaDescarga"], (Self:lCreate .OR. lForca), .F.)
	EndIf

	oPCPError:destroy()
	oPCPError := Nil

	//Aguarda sempre eliminação ao menos desta trabalha para evitar intertravamento.
	While VarIsUID( cChaveExec + "UIDs_PCPMRP")
		Sleep(200)
		VarGetXA( cChaveExec + "UIDs_PCPMRP", @aSessoes)
		If Empty(aSessoes)
			Exit
		Else
			aSessoes := aSize(aSessoes, 0)
		EndIf
	EndDo

Return

/*/{Protheus.doc} trava
Trava o registro da tabela
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cTabela, caracter, id da tabela
@param 02 - cChave , caracter, chave da tabela no indice primario
@return lRet, logico, indica se conseguiu travar o registro
/*/
METHOD trava(cTabela, cChave) CLASS  MrpDados
	Local oTabela
	Local lRet      := .F.

	If cTabela == "MAT"
		oTabela := ::oMatriz

	ElseIf cTabela == "PRD"
		oTabela := ::oProdutos

	ElseIf cTabela == "EST"
		oTabela := ::oEstruturas

	ElseIf cTabela == "SUB"
		oTabela := ::oSubProdutos

	EndIf

	lRet    := oTabela:trava( cChave )

Return lRet

/*/{Protheus.doc} destrava
Destrava o registro da tabela
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cTabela, caracter, id da tabela
@param 02 - cChave , caracter, chave da tabela no indice primario
@return lRet, logico, indica se conseguiu destravar o registro
/*/
METHOD destrava(cTabela, cChave) CLASS  MrpDados
	Local oTabela
	Local lRet      := .F.

	If cTabela == "MAT"
		oTabela := ::oMatriz

	ElseIf cTabela == "PRD"
		oTabela := ::oProdutos

	ElseIf cTabela == "EST"
		oTabela := ::oEstruturas

	ElseIf cTabela == "SUB"
		oTabela := ::oSubProdutos

	EndIf

	lRet    := oTabela:destrava( cChave )

Return lRet

/*/{Protheus.doc} existeMatriz
Verifica se o produto existe na Matriz
@author brunno.costa
@since 25/04/2019
@version 1.0
@param 01 - cFilAux  , caracter, código da filial
@param 02 - cProduto , caracter, codigo do produto ou codigo do produto + cIDOpc
@param 03 - nPeriodo , numero  , periodo
@param 04 - cChaveAux, caracter, chave
@return lPossuiMAT, logico, indica se o produto existe na matriz no periodo (ou se a chave existe na matriz)
/*/
METHOD existeMatriz(cFilAux, cProduto, nPeriodo, cChaveAux, cIDOpc) CLASS MrpDados
	Local lError     := .F.
	Local lPossuiMAT
	Local lErrorMAT  := .F.

	Default cProduto   := ""
	Default cIDOpc     := ""
	Default cChaveAux  := cFilAux + Iif(cProduto == Nil, "",cProduto + Iif(Empty(cIDOpc), "","|" + cIDOpc))

	If nPeriodo == Nil
		lPossuiMAT := ::oMatriz:getFlag("cExistMAT_" + cChaveAux, @lError, slTravaOut)
		If lPossuiMAT == Nil .OR. lError
			lPossuiMAT := .F.
		EndIf
	Else
		cChaveAux := DtoS(Self:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cFilAux + cProduto + Iif(Empty(cIDOpc), "","|" + cIDOpc)
		::retornaCampo("MAT"       /*cTabela*/, 1 /*nIndice*/, cChaveAux /*cChave*/,;
		              "MAT_SALDO"  /*cCampo*/, @lErrorMAT /*lError*/)
		lPossuiMAT := !lErrorMAT
	EndIf
Return lPossuiMAT


/*/{Protheus.doc} setOPeriodos
Seta propriedade oPeriodos
@author marcelo.neumann
@since 25/06/2019
@version 1.0
@param oPeriodos, objeto, instância da classe referente aos períodos
@return Nil
/*/
METHOD setOPeriodos(oPeriodos) CLASS MrpDados

	::oPeriodos := oPeriodos

Return

/*/{Protheus.doc} setoDominio
Seta propriedade oDominio
@author brunno.costa
@since 08/07/2019
@version 1.0
@param oDominio, objeto, instância da classe referente ao domínio
@return Nil
/*/
METHOD setoDominio(oDominio) CLASS MrpDados

	::oDominio := oDominio

Return

/*/{Protheus.doc} decrementaTotalizador
Decrementa o totalizador relacionado analise de conclusao do loopNiveis
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cProduto  , caracter, codigo do produto / chave do produto
@return nSobraPos, numero, retorna o saldo apos consumir o produto
/*/
METHOD decrementaTotalizador(cProduto) CLASS MrpDados

	Local aAreaPRD
	Local cNivelPrd
	Local lErrorPRD := .F.
	Local lAtual    := cProduto == ::oProdutos:cCurrentKey

	//Atualiza controles de processamento da loopNiveis
	If !lAtual
		aAreaPRD  := ::retornaArea("PRD")
	EndIf

	cNivelPrd := ::retornaCampo("PRD", 1, cProduto, "PRD_NIVEST", @lErrorPRD, .F. /*lAtual*/)
	cNivelPrd := Iif(cNivelPrd == Nil, "99", cNivelPrd)

	::oProdutos:setflag("nProdCalcN"  + cNivelPrd, -1, .F., .T., .T.) //Decrementa
	::oProdutos:setflag("nProdCalcT"             , -1, .F., .T., .T.) //Decrementa

	If !lAtual
		::setaArea(aAreaPRD)
		aAreaPRD := aSize(aAreaPRD, 0)
	EndIf

Return

/*/{Protheus.doc} incrementaTotalizador
Incrementa o totalizador relacionado analise de conclusao do loopNiveis
@author    brunno.costa
@since     25/04/2019
@version 1.0
@param 01 - cProduto  , caracter, codigo do produto / chave do produto
@return nSobraPos, numero, retorna o saldo apos consumir o produto
/*/
METHOD incrementaTotalizador(cProduto, lProcess, lCalculado) CLASS MrpDados

	Local aAreaPRD
	Local cNivelPrd
	Local lErrorPRD := .F.
	Local lAtual    := cProduto == ::oProdutos:cCurrentKey

	Default lProcess := .F.

	//Atualiza controles de processamento da loopNiveis
	If !lAtual
		aAreaPRD  := ::retornaArea("PRD")
	EndIf

	cNivelPrd := ::retornaCampo("PRD", 1, cProduto, "PRD_NIVEST", @lErrorPRD, lAtual /*lAtual*/)
	cNivelPrd := Iif(cNivelPrd == Nil, "99", cNivelPrd)

	If lProcess
		::oProdutos:setflag("nProcessNv" + cNivelPrd, +1, .F., .T., .T.)
		::oProdutos:setflag("nProcess"              , +1, .F., .T., .T.)
	EndIf

	If lCalculado
		::oProdutos:setflag("nProdCalcN"  + cNivelPrd, +1, .F., .T., .T.)
		::oProdutos:setflag("nProdCalcT"             , +1, .F., .T., .T.)
	EndIf

	If !lAtual
		::setaArea(aAreaPRD)
		aAreaPRD := aSize(aAreaPRD, 0)
	EndIf

Return

/*/{Protheus.doc} posicaoCampo
Retorna a posicao do campo na tabela
@author    brunno.costa
@since     08/07/2019
@version 1.0
@param 01 - cCampo  , caracter, identificador do campo
@return nSobraPos, numero, posicao do  campo na tabela
/*/
METHOD posicaoCampo(cCampo) CLASS MrpDados
Return &("s" + cCampo)

/*/{Protheus.doc} semaforoNiveis
Controla semáforo de execução do recálculo de níveis da estrutura.
@author    lucas.franca
@since     12/11/2020
@version 1.0
@param 01 - cOpcao, Character, Operação do semáforo (LOCK ou UNLOCK)
@return lRet, Logic, Indica o sucesso na obtenção do semáforo.
/*/
METHOD semaforoNiveis(cOpcao) CLASS MrpDados
	Local cChaveLock := "MRPLCKNV" + cEmpAnt
	Local lRet       := .T.
	Local nTry       := 0

	Do Case
		Case cOpcao == 'LOCK'
			While !LockByName(cChaveLock,.T.,.F.)
				nTry++
				If nTry > 1000
					//Não conseguiu o lock, retorna false.
					lRet := .F.
					Exit
				EndIf
				Sleep(200)
			End
		Case cOpcao == 'UNLOCK'
			UnLockByName(cChaveLock,.T.,.F.)
		Otherwise
			lRet := .F.
	EndCase

Return lRet

/*/{Protheus.doc} PCPCleanVr
Chama VarClean
@author    brunno.costa
@since     25/04/2019
@version 1.0
/*/
Function PCPCleanVr(cChaveExec, cTicket, lAguardaDescarga, lLimpaTudo, lWaitFina)
	Local aSessoes   := {}
	Local cGlobalKey := ""
	Local lOk        := .T.
	Local lPassou    := .F.
	Local nInd       := 0
	Local nTotal     := 0
	Local oPCPError  := Nil
	Local oStatus    := MrpDados_Status():New(cTicket)

	Default lLimpaTudo := .F.
	Default lWaitFina  := .T.

	If lLimpaTudo
		saMAT := FwFreeArray(saMAT)

		If soDominio == Nil
			soDominio := MRPPrepDom(cTicket)
		EndIf

		//Protege limpeza de memória
		VarBeginT( cChaveExec + "UIDs_PCPMRP", "UIDs_PCPMRP" )

		//Elimina residuos de variaveis globais
		If VarIsUID( cChaveExec + "UIDs_PCPMRP" )
			VarGetXA( cChaveExec + "UIDs_PCPMRP", @aSessoes )

			soDominio:oDados:trava("MAT", "UIDs_PCPMRP")
			VarEndT( cChaveExec + "UIDs_PCPMRP", "UIDs_PCPMRP" )

			If VarIsUID(cChaveExec + "UIDs_PCPMRP")
				VarClean(cChaveExec + "UIDs_PCPMRP")
			EndIf

			lPassou    := .T.

			//Libera trecho de limpeza de memória
			soDominio:oDados:destrava("MAT", "UIDs_PCPMRP")

			nTotal := Len(aSessoes)

			For nInd := 1 To nTotal
				cGlobalKey := aSessoes[nInd][1]
				If (cChaveExec $ cGlobalKey .OR. oStatus:getStatus("status") != "4") .AND. VarIsUID( cGlobalKey )
					VarClean( cGlobalKey )
				EndIf
			Next nInd
			aSessoes := FwFreeArray(aSessoes)
		EndIf

		//Libera trecho de limpeza de memória
		If !lPassou
			VarEndT( cChaveExec + "UIDs_PCPMRP", "UIDs_PCPMRP" )
		EndIf

		If VarIsUID(cChaveExec)
			VarClean(cChaveExec)
		EndIf

		If !lAguardaDescarga .AND. soDominio != Nil
			If oStatus:getStatus("memoria") <> "9"
				oStatus:setStatus("memoria", "4") //Descarregado
			EndIf
			oStatus:persistir(soDominio:oDados)
			//Aguarda finalização ou cancelamento

			If lWaitFina
				While oStatus:getStatus("finalizado") != "true" .And. oStatus:getStatus("status", @lOk) != "4"
					If !lOk
						Exit
					EndIf
					Sleep(50)
				End

				oStatus:Destruir()
			EndIf
		EndIf
	Else
		If VarIsUID(cChaveExec)
			VarClean(cChaveExec)
		EndIf
		oStatus:Destruir()
	EndIf

	FreeObj(oStatus)
	FreeObj(oPCPError)
Return

