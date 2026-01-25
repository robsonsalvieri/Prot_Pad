#INCLUDE "QualityAPIManager.ch"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOTVS.CH"

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

#DEFINE X5_FILIAL     1
#DEFINE X5_TABELA     2
#DEFINE X5_CHAVE      3
#DEFINE X5_DESCRICAO  4

Static lQAStrToASC := Nil
Static lQIEIntAPI  := Nil
Static lQIPIntAPI  := Nil

/*/{Protheus.doc} qualityapimanager
API Genérica da Inspeção da Qualidade
@author brunno.costa
@since  05/09/2025
/*/
WSRESTFUL qualityapimanager DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ensaios Calculados Inspeção da Qualidade"
	
	WSDATA Table  as STRING

	WSMETHOD GET sx5list;
    DESCRIPTION STR0004; //"Retorna Lista da SX5"
    WSSYNTAX "api/qip/v1/sx5list/{Table}" ;
    PATH "api/qip/v1/sx5list" ;
    TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET sx5list PATHPARAM Table WSSERVICE qualityapimanager

	Local aDados      := {}
	Local aQ2SX5      := {}
	Local nIndSX5     := Nil
	Local nTamanho    := GetSx3Cache("QP7_LABOR", "X3_TAMANHO")
	Local nTotal      := 1
	Local oAPIManager := QualityAPIManager():New(, Self,)
	Local oItemAPI    := Nil

	Default Self:Table := "Q2"
	
	If oAPIManager:ValidaPrepareInDoAmbiente()		
		aQ2SX5 := FWGetSX5( Self:Table )
		nTotal := Len(aQ2SX5)

		For nIndSX5 := 1 to nTotal
			If aQ2SX5[nIndSX5][X5_FILIAL] == xFilial("SX5")
				oItemAPI          := JsonObject():New()
				oItemAPI["value"] := PadR(Rtrim(aQ2SX5[nIndSX5][X5_CHAVE]), nTamanho)
				oItemAPI["label"] := Capital(AllTrim(aQ2SX5[nIndSX5][X5_DESCRICAO])) + " ("+AllTrim(aQ2SX5[nIndSX5][X5_CHAVE])+")"
				aAdd(aDados, oItemAPI)
			EndIf
		Next
	EndIf

	oAPIManager:RespondeArray(aDados, .F.)
	
Return 

/*/{Protheus.doc} QualityAPIManager
Classe Auxiliar da Construção de APIs de Qualidade Protheus
@author brunno.costa
@since  23/05/2022
/*/
CLASS QualityAPIManager FROM LongNameClass
	
	DATA aMapaCampos                             as ARRAY
	DATA aUsuarios                               as ARRAY
	DATA cBanco                                  as STRING
	DATA cConcat                                 as STRING
	DATA cDetailedMessage                        as STRING
	DATA cErrorMessage                           as STRING
	DATA cSuccessMessage                         as STRING
	DATA lPELaboratoriosRelacionadosAoUsuario    as LOGICAL
	DATA lPEQIELaboratoriosRelacionadosAoUsuario as LOGICAL
	DATA lPEQIPLaboratoriosRelacionadosAoUsuario as LOGICAL
	DATA lWarningError                           as LOGICAL
	DATA oCacheInicializadorCampos               as OBJECT
	DATA oCacheObrigatorios                      as OBJECT
	DATA oCacheGetSx3CacheTipo                   as OBJECT
	DATA oQueryManager                           as OBJECT
	DATA oWSRestFul                              as OBJECT

	METHOD AtualizaCamposAPINoRegistro(oItemAPI, oRegistro, cAlias, aMapaCampos)
	METHOD AtualizaCamposBancoNoRegistro(oRegistro, cAlias, nRecho, aMapaCampos)
	METHOD AvaliaPELaboratoriosRelacionadosAoUsuario()
	METHOD ChangeQueryAllDB(cQuery, cBanco)
	METHOD ChecaLaboratorioValidoParaUsuario(cUsuario, cEndPoint, cLaboratorio)
	METHOD ExistePEIntegracaoAppMinhaProducaoCompilado(cModulo)
	METHOD FormataDado(cTipo, cValor, cOrigem, nTamanho)
	METHOD InicializaCamposPadroes(cAlias, cExcecao, lCache)
	METHOD MarcaCamposConsiderados(cCampos, aMapaCampos, nIndCpoPsq)
	METHOD new(aMapaCampos, oWSRestFul, cBanco) CONSTRUCTOR
	METHOD ProcessaListaResultados(cAlias)
	METHOD RespondeArray(aArray, lHasNext)
	METHOD RespondeJson(oDados, cError, cDetailedMessage)
	METHOD RespondeValor(cChave, oValor, cError, cDetailedMessage)
	METHOD RetornaFiltroPELaboratoriosRelacionadosAoUsuario(cCampo, cUsuario, cEndPoint)
	METHOD RetornaOrdemDB(cOrdem,cOrdemTipo)
	METHOD SalvaRegistroDB(cAlias, oDadosJson, aMapaCampos, nRecnoErro)
	METHOD ValidaCamposObrigatorios(oRegistro, cCampos, cCpsErro)
	METHOD ValidaChaveEstrangeira(cAlias, nOrder, cChave)
	METHOD ValidaFormatosCamposItem(oItemAPI, aMapaCampos, cCpsErro)
	METHOD ValidaUsuarioProtheus(cLogin)

	//Métodos Internos
	METHOD CallStack(nTotal)
	METHOD ErrorBlock(e, cErrorMessage)
	METHOD GetSx3Cache(cCampo, cCampoSX3)
    METHOD MontaItensRetorno(cAlias, nPagina, nTamPag)
	METHOD ValidaFormatoData(cData)
	METHOD ValidaFormatoHora(cHora)
	METHOD validaMudancaRegistro(cAlias, oRegistro, aMapaCampos)
	METHOD ValidaPrepareInDoAmbiente()
ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author brunno.costa
@since  23/05/2022
@param 01 - aMapaCampos, array , lista de campos {{nPosCPS_Considera, ..., nPosCPS_Decimal}}
@param 02 - oWSRestFul , objeto, objeto WSRESTFUL da API
@param 03 - cBanco, caracter, banco consideração
@return Self, objeto, instancia da classe
/*/
METHOD new(aMapaCampos, oWSRestFul, cBanco) CLASS QualityAPIManager
	Default cBanco     := TcGetDB()
	Self:aMapaCampos   := aMapaCampos
	Self:oWSRestFul    := oWSRestFul
	Self:cBanco        := cBanco
	Self:lWarningError := .F.
	If "MSSQL" $ Self:cBanco
		Self:cConcat := "+"
	Else
		Self:cConcat := "||"
	EndIf
	Self:oQueryManager := QLTQueryManager():New()
Return Self

/*/{Protheus.doc} ProcessaListaResultados
Processa Lista de Resultados em WSRestFul
@author brunno.costa
@since  23/05/2022
@param 01 - cAlias , caracter, alias dos campos para consulta
@param 02 - nPagina, numérico, numero de pagina para retornar os dados
@param 03 - nTamPag, numérico, tamanho da pagina padrao
@param 04 - lPosicionaPrimeiro, numérico, posiciona no primeiro registro
@return lRetorno, lógico, indica se conseguiu realizar o processamento com sucesso
/*/
METHOD ProcessaListaResultados(cAlias, nPagina, nTamPag, lPosicionaPrimeiro) CLASS QualityAPIManager

	Local lRetorno  := .T.
	Local oResponse := JsonObject():New()

	oResponse['items'        ] := Self:MontaItensRetorno(cAlias, nPagina, nTamPag, lPosicionaPrimeiro)
	oResponse['hasNext'      ] := .F.
	If (cAlias)->(!Eof())
		oResponse["hasNext"]   := .T.
	EndIf

	Self:oWSRestFul:SetContentType("application/json")

	If Len(oResponse['items']) > 0
		//Processou com sucesso.
		HTTPSetStatus(200)
		oResponse['code'         ] := 200
		Self:oWSRestFul:SetResponse(EncodeUtf8(oResponse:toJson()))
	Else
		//Não processou com sucesso. Seta o código e mensagem de erro para retorno.
		oResponse['code'         ] := 404
		oResponse['errorCode'    ] := 404
		oResponse['message'      ] := STR0001 //"Nenhum registro foi encontrado."
		oResponse['errorMessage' ] := STR0001 //"Nenhum registro foi encontrado."
		//oResponse['detailedMessage' ] := "Nenhum registro foi encontrado."
		SetRestFault(404, STR0001) //"Nenhum registro foi encontrado."
		lRetorno := .F.
	EndIf

Return lRetorno

/*/{Protheus.doc} RespondeArray
Responde Array em WSRestFul
@author brunno.costa
@since  22/09/2022
@param 01 - aArray  , array , array de dados
@param 02 - lHasNext, lógico, indica se tem próxima página
/*/
METHOD RespondeArray(aArray, lHasNext) CLASS QualityAPIManager

	Local oResponse  := JsonObject():New()

	Default lHasNext := .F.

	oResponse['items'  ] := aArray
	oResponse["hasNext"] := lHasNext

	Self:oWSRestFul:SetContentType("application/json")

	//Processou com sucesso.
	HTTPSetStatus(200)
	oResponse['code'] := 200
	Self:oWSRestFul:SetResponse(EncodeUtf8(oResponse:toJson()))

Return

/*/{Protheus.doc} RespondeValor
Responde Valor
@author brunno.costa
@since  22/09/2022
@param 01 - cChave          , caracter, chave de valor
@param 02 - oValor          , variável, conteúdo para envio
@param 03 - cError          , caracter, mensagem de erro no processamento
@param 04 - cDetailedMessage, caracter, mensagem de erro detalhada
/*/
METHOD RespondeValor(cChave, oValor, cError, cDetailedMessage) CLASS QualityAPIManager

	Local cSuccessMessage := Iif(Self:cSuccessMessage != Nil, Self:cSuccessMessage, "")
	Local oResponse       := JsonObject():New()

	Default cChave           := ""
	Default cDetailedMessage := Iif(Self:cDetailedMessage != Nil, Self:cDetailedMessage, "")
	Default cError           := Iif(Self:cErrorMessage != Nil, Self:cErrorMessage , "")
	Default oValor           := ""

	oResponse[cChave] := oValor
	
	Self:oWSRestFul:SetContentType("application/json")
	oResponse['showWarningError' ]    := Self:lWarningError
	If Empty(cError)
		//Processou com sucesso.
		HTTPSetStatus(200)
		oResponse['code']             := 200
		Self:oWSRestFul:SetResponse(EncodeUtf8(oResponse:toJson()))
	Else
		oResponse['code'         ]    := 404
		oResponse['errorCode'    ]    := 404
		oResponse['message'      ]    := cError
		oResponse['errorMessage' ]    := cError
		oResponse['detailedMessage' ] := cDetailedMessage

		//Mensagem complementar de operação realizada com sucesso, mesmo quando há um erro a reportar ao cliente.
		If !Empty(cSuccessMessage)
			oResponse['successMessage' ]   := cSuccessMessage
		EndIf

		SetRestFault(404, EncodeUtf8(oResponse:toJson()))
	EndIf

Return

/*/{Protheus.doc} RespondeJson
Responde Json Object
@author brunno.costa
@since  05/11/2022
@param 01 - oDados          , json    , json de resposta
@param 02 - cError          , caracter, mensagem de erro no processamento
@param 03 - cDetailedMessage, caracter, mensagem de erro detalhada
/*/
METHOD RespondeJson(oDados, cError, cDetailedMessage) CLASS QualityAPIManager

	Default cDetailedMessage := Iif(Self:cDetailedMessage != Nil, Self:cDetailedMessage, "")
	Default cError           := Iif(Self:cErrorMessage != Nil, Self:cErrorMessage , "")
	
	Self:oWSRestFul:SetContentType("application/json")
	oDados['showWarningError']     := Self:lWarningError
	If Empty(cError)
		//Processou com sucesso.
		HTTPSetStatus(200)
		oDados['code']             := 200
		Self:oWSRestFul:SetResponse(EncodeUtf8(oDados:toJson()))
	Else
		oDados['code'         ]    := 404
		oDados['errorCode'    ]    := 404
		oDados['message'      ]    := cError
		oDados['errorMessage' ]    := cError
		oDados['detailedMessage' ] := cDetailedMessage
		SetRestFault(404, EncodeUtf8(oDados:toJson()))
	EndIf

Return

/*/{Protheus.doc} GetSx3Cache
Método para retornar o processamento da função GetSx3Cache com proteção de error.log 
Ocorre quando PrepareIN no appserver.ini é diferente da base utilizada
@author rafael.hesse
@since  24/10/2022
@param 01 - cCampo, caracter, Campo que deseja buscar
@param 02 - cCampoSX3, caracter, campo da SX3 que deseja buscar
@return xReturn, numérico, retorna o processamento da função GetSx3Cache em caso de não nulo.
/*/
METHOD GetSx3Cache(cCampo, cCampoSX3) CLASS QualityAPIManager
	Local cError  := STR0003 //Não foi possível identificar a Empresa e Filial do servidor de aplicação Protheus. Informe a Empresa e Filial no PrepareIn do AppServer.INI
	Local xReturn := GetSx3Cache(cCampo,cCampoSX3)

	If xReturn == NIL
		self:RespondeValor("result", .F.,cError)
		break
	EndIf

Return xReturn

/*/{Protheus.doc} ValidaPrepareInDoAmbiente
Método verificar se o ambiente está com PREPAREIN no AppServer configurado corretamente.
@author rafael.hesse
@since  27/10/2022
@return lReturn, Lógico, se o ambiente está válido.
/*/
METHOD ValidaPrepareInDoAmbiente() CLASS QualityAPIManager

	Local bErrorBlock := ErrorBlock({|e| Self:ErrorBlock(e, STR0003), Break(e)}) //Não foi possível identificar a Empresa e Filial do servidor de aplicação Protheus. Informe a Empresa e Filial no PrepareIn do AppServer.INI
	Local cValida     := ""
	Local lReturn     := .T.
	
	Begin Sequence
		cValida := RetSqlName("QAA")
	End Sequence

	ErrorBlock(bErrorBlock)	

	If Empty(cValida) .Or. cValida == NIL
		self:RespondeValor("result", .F.,STR0003)
		lReturn	:= .F.
	EndIf
	
Return lReturn

/*/{Protheus.doc} MontaItensRetorno
Retorna Lista em Array de Dados no Formato Padrão Json
@author brunno.costa
@since  23/05/2022
@param 01 - cAlias            , caracter, alias dos campos para consulta
@param 02 - nPagina           , numérico, numero de pagina para retornar os dados
@param 03 - nTamPag           , numérico, tamanho da pagina padrao
@param 04 - lPosicionaPrimeiro, numérico, posiciona no primeiro registro
@return aRetorno, array, lista de resultados em formato JsonObject
/*/
METHOD MontaItensRetorno(cAlias, nPagina, nTamPag, lPosicionaPrimeiro) CLASS QualityAPIManager
	
	Local aRetorno  := {}
	Local cCampo    := Nil
	Local cValor    := Nil
	Local lAchou    := Nil
	Local nCampos   := Len(Self:aMapaCampos)
	Local nIndCampo := 0
	Local nPrimeiro := 1
	Local oDados    := Nil

	Default lPosicionaPrimeiro := .T.

	//Ajusta o tipo dos campos DATA, LÓGICO e NUMÉRICO de acordo com os tamanhos definidos no MAP da API.
	For nIndCampo := 1 To nCampos
		If Self:aMapaCampos[nIndCampo][nPosCPS_Tipo] $ "|D|N|"
			TcSetField(cAlias, Self:aMapaCampos[nIndCampo][nPosCPS_Protheus],;
			                   Self:aMapaCampos[nIndCampo][nPosCPS_Tipo          ],;
			                   Self:aMapaCampos[nIndCampo][nPosCPS_Tamanho       ],;
			                   Self:aMapaCampos[nIndCampo][nPosCPS_Decimal       ])
		EndIf
	Next nIndCampo

	//Posiciona no registro correto de acordo com a paginação.
	If nPagina > 1 .And. lPosicionaPrimeiro
		nPrimeiro := ( (nPagina-1) * nTamPag )
		If nPrimeiro > 0
			(cAlias)->(DbSkip(nPrimeiro))
		EndIf
	EndIf

	While (cAlias)->(!Eof())
		lAchou := .T.
		oDados := JsonObject():New()

		//Carrega as informações que devem ser retornadas
		For nIndCampo := 1 To nCampos
			If Self:aMapaCampos[nIndCampo][nPosCPS_Considera]
				cCampo  := Self:aMapaCampos[nIndCampo][nPosCPS_Titulo_API]
				cValor  := &("(cAlias)->(" + Self:aMapaCampos[nIndCampo][nPosCPS_Protheus] + ")")
				oDados[cCampo] := Self:FormataDado(Self:aMapaCampos[nIndCampo][nPosCPS_Tipo],  ;
				                                   cValor,                                ;
												   "2",                                   ;
												   Self:aMapaCampos[nIndCampo][nPosCPS_Tamanho])
			EndIf
		Next nIndCampo
		
		aAdd(aRetorno, oDados)

		(cAlias)->(dbSkip())

		If Len(aRetorno) >= nTamPag
			Exit
		EndIf

	EndDo
	
Return aRetorno

/*/{Protheus.doc} FormataDado
Formata uma informação recebida pela API de acordo com o campo correspondente no APIMAP.
@author brunno.costa
@since  23/05/2022
@param 01 - cTipo   , caracter, Tipo do valor para conversão. (C=Caracter, D=Date, L-Logic, N=Numeric)
@param 02 - cValor  , qualquer, Valor que será tratado
@param 03 - cOrigem , caracter, Origem da conversão. 1=JSON para ADVPL. 2=ADVPL para JSON.
@param 04 - nTamanho, numérico, Tamanho do campo.
@return xNovoValor, qualquer, Campo formatado no formato correto.
/*/
Method FormataDado(cTipo, cValor, cOrigem, nTamanho) CLASS QualityAPIManager

	Local oAux       := Nil
	Local xNovoValor := Nil
	
	If cValor != Nil .AND. !Empty(cValor)
		Do Case
			Case cTipo $ "CH"
				If cOrigem == "1"
					xNovoValor := PadR(cValor, nTamanho)
				Else
					xNovoValor := RTrim(cValor)
				EndIf
			Case cTipo == "D"
				If cOrigem == "1"
					xNovoValor := StoD(StrTran(cValor,'-',''))
				Else
					If !Empty(cValor)
						xNovoValor := cValor
						xNovoValor := StrZero(Year(xNovoValor),4) + "-" + StrZero(Month(xNovoValor),2) + "-" + StrZero(Day(xNovoValor),2)
					Else
						xNovoValor := ""
					EndIf
				EndIf
			Case cTipo == "L"
				If cOrigem == "1"
					xNovoValor := Iif(cValor == "true", .T., .F.)
				Else
					xNovoValor := Iif(cValor == '.T.', .T., .F.)
				EndIf
			Case cTipo == "A"
				xNovoValor := cValor
				If cOrigem == "2"
					oAux := JsonObject():New()
					If Empty(oAux:fromJson('{ "aux": ' + cValor + "}"))
						xNovoValor := oAux['aux']
					EndIf
				EndIf
			Otherwise
				xNovoValor := cValor
		EndCase
	EndIf
Return xNovoValor

/*/{Protheus.doc} RetornaOrdemDB
Retorna Lista em Array de Dados no Formato Padrão Json
@author brunno.costa
@since  23/05/2022
@param 01 - cOrdem, caracter, ordem de campos original na API
@param 02 - cOrdemTipo, caracter, tipo de ordenação para retornar a listagem dos dados (Ascencente ou Decrescente)
@return cOrdemDB, caracter, ordem de campos DB
/*/
METHOD RetornaOrdemDB(cOrdem,cOrdemTipo) CLASS QualityAPIManager
	Local aOrdem   := StrTokArr(cOrdem,",")
	Local cOrdemDB := ""
	Local nCampos  := Len(aOrdem)
	Local nInd     := 0
	Local nPos     := Nil

	Default cOrdemTipo := ""

	For nInd := 1 to nCampos
		nPos := aScan(Self:aMapaCampos, {|aMapa| AllTrim(aMapa[nPosCPS_Titulo_API]) == AllTrim(aOrdem[nInd])})
		If nPos > 0
			If Empty(cOrdemDB)
				cOrdemDB := Self:aMapaCampos[nPos][nPosCPS_Protheus] 
			Else
				cOrdemDB += "," + Self:aMapaCampos[nPos][nPosCPS_Protheus] 
			EndIf
			If cOrdemTipo <> ""
				cOrdemDB += " " + cOrdemTipo
			EndIf
		EndIf
	Next nInd

Return cOrdemDB

/*/{Protheus.doc} InicializaCamposPadroes
Inicializa os Campos Padrões do Alias Especificado
@author brunno.costa
@since  23/05/2022
@param 01 - cAlias  , caracter, alias dos campos para inicialização
@param 02 - cExcecao, caracter, relação de campos com exceção de inicialização, separados por | (pipe)
@param 03 - lCache  , lógico  , indica se deve realizar cache
@return oDadosJson, objeto, objeto Json com os dados inicializados
/*/
METHOD InicializaCamposPadroes(cAlias, cExcecao, lCache) CLASS QualityAPIManager

	Local aCampos    := Nil
	Local cCampo     := Nil
	Local nCampos    := Nil
	Local nIndCpo    := Nil
	Local oDadosJson := JsonObject():New()

	Default cExcecao   := ""
	Default lCache     := .F.

	If lCache
		Self:oCacheInicializadorCampos := Iif(Self:oCacheInicializadorCampos == Nil, JsonObject():New(), Self:oCacheInicializadorCampos)
	EndIf

	If !lCache .OR. Self:oCacheInicializadorCampos[cAlias + "_" + cExcecao] == Nil

		aCampos := FWFormStruct(3, cAlias,{|cCampo| !("|"+AllTrim(cCampo)+"|" $ cExcecao)})[3]
		nCampos := Len(aCampos)

		For nIndCpo := 1 to nCampos
			cCampo := AllTrim(aCampos[nIndCpo][1])
			oDadosJson[cCampo] := CriaVar(cCampo, .T.)
		Next nX

		If lCache
			Self:oCacheInicializadorCampos[cAlias + "_" + cExcecao] := oDadosJson:toJson()
		EndIf

	ElseIf lCache

		oDadosJson:fromJson(Self:oCacheInicializadorCampos[cAlias + "_" + cExcecao])

	EndIf

Return oDadosJson

/*/{Protheus.doc} SalvaRegistroDB
Salva Registro Json no Banco de Dados conforme aMapaCampos
@author brunno.costa
@since  23/05/2022
@param 01 - cAlias     , caracter, alias dos campos para inicialização
@param 02 - oRegistro  , objeto  , objeto com o item para gravação no banco
@param 03 - aMapaCampos, array   , lista de campos {{nPosCPS_Considera, ..., nPosCPS_Decimal}}
@param 04 - nRecnoErro , numérico, retorna por referência recno do registro com erro
@return lSucesso, lógico, indica se conseguiu realizar a gravação com sucesso
/*/
METHOD SalvaRegistroDB(cAlias, oRegistro, aMapaCampos, nRecnoErro) CLASS QualityAPIManager

	Local cCampo      := Nil
	Local lModificado := .T.
	Local lSucesso    := .T.
	Local nCampos     := Len(aMapaCampos)
	Local nIndCampo   := Nil
	Local nRecno      := Nil

	DbSelectArea(cAlias)
	nRecno := oRegistro['R_E_C_N_O_']
	If nRecno == Nil .OR. nRecno <= 0
		RecLock(cAlias, .T.)
	Else
		(cAlias)->(DbGoTo(nRecno))
		If (cAlias)->(Eof())
			lSucesso   := .F.
			nRecnoErro := nRecno
		Else
			lModificado    := Self:validaMudancaRegistro(cAlias, oRegistro, aMapaCampos)
			If lModificado
				RecLock(cAlias, .F.)
			EndIf
		EndIf
	EndIf

	If lSucesso	
		If lModificado
			For nIndCampo := 1 to nCampos
				cCampo := aMapaCampos[nIndCampo][nPosCPS_Protheus]
				If oRegistro[cCampo] != Nil
					(cAlias)->&(cCampo) := oRegistro[cCampo]
				EndIf
			Next nIndCampo
			(cAlias)->&(cAlias+"_FILIAL") := xFilial(cAlias)
			(cAlias)->(MsUnlock())
		EndIf
		oRegistro["R_E_C_N_O_"] := (cAlias)->(Recno())
	EndIf

Return lSucesso

/*/{Protheus.doc} MarcaCamposConsiderados
Marca nPosCPS_Considera no aMapaCampos dos Registros para Consideração
@author brunno.costa
@since  02/04/2025
@param 01 - cAlias     , caracter, alias dos campos para inicialização
@param 02 - oRegistro  , objeto  , objeto com o item para gravação no banco
@param 03 - aMapaCampos, array   , lista de campos {{nPosCPS_Considera, ..., nPosCPS_Decimal}}
@return lModificado, lógico      , indica se o registro foi modificado
/*/
METHOD validaMudancaRegistro(cAlias, oRegistro, aMapaCampos) CLASS QualityAPIManager
	
	Local cCampo      := Nil
	Local lModificado := .F.
	Local nCampos     := Len(aMapaCampos)
	Local nIndCampo   := Nil

	For nIndCampo := 1 to nCampos
		cCampo := aMapaCampos[nIndCampo][nPosCPS_Protheus]
		If oRegistro[cCampo] != Nil .And. cCampo != "R_E_C_N_O_"
			If ((AllTrim((cAlias)->&(cCampo)) <> AllTrim(oRegistro[cCampo]) .And. aMapaCampos[nIndCampo][nPosCPS_Tipo] == "C");
				.Or.    ((cAlias)->&(cCampo)  <>         oRegistro[cCampo]  .And. aMapaCampos[nIndCampo][nPosCPS_Tipo] != "C") )
				lModificado    := .T.
				Exit
			EndIf
		EndIf
	Next nIndCampo

Return lModificado

/*/{Protheus.doc} MarcaCamposConsiderados
Marca nPosCPS_Considera no aMapaCampos dos Registros para Consideração
@author brunno.costa
@since  23/05/2022
@param 01 - cCampos    , caracter, string com os campos para consideração
@param 02 - aMapaCampos, array   , lista de campos {{nPosCPS_Considera, ..., nPosCPS_Decimal}}
@param 03 - nIndCpoPsq , numérico, indice do aMapaCampos com a coluna referência para comparação de campo
@return aMapaCampos, array   , lista de campos {{nPosCPS_Considera, ..., nPosCPS_Decimal}}
/*/
METHOD MarcaCamposConsiderados(cCampos, aMapaCampos, nIndCpoPsq) CLASS QualityAPIManager
	
	Local aCampos := {}
    Local nInd    := 0
    Local nTotal  := 0

    DEFAULT cCampos := "*"

    aCampos := StrTokArr(cCampos,",")
    nTotal  := Len(aCampos)
	
	If nTotal > 0 .And. aCampos[1] != "*"
         For nInd := 1 to nTotal
              nPos := aScan(aMapaCampos, {|aMapa| AllTrim(aMapa[nIndCpoPsq]) == AllTrim(aCampos[nInd])})
              If nPos > 0
                   aMapaCampos[nPos][nPosCPS_Considera] := .T.
              EndIf
         Next nInd
    Else
         nTotal := Len(aMapaCampos)
         For nInd := 1 to nTotal
              aMapaCampos[nInd][nPosCPS_Considera] := .T.
         Next nInd
    EndIf

Return aMapaCampos

/*/{Protheus.doc} AtualizaCamposAPINoRegistro
Atualiza Campos da API no oRegistro
@author brunno.costa
@since  23/05/2022
@param 01 - oItemAPI   , objeto  , objeto com o item dos registros recebidos da API
@param 02 - oRegistro  , objeto  , objeto com os dados do registro para gravação no banco de dados
@param 03 - cAlias     , caracter, alias dos campos que deverão ser considerados do aMapaCampos para gravação no oRegistro
@param 04 - aMapaCampos, array   , lista de campos {{nPosCPS_Considera, ..., nPosCPS_Decimal}}
@return oRegistro, objeto, objeto com os dados do registro para gravação no banco de dados
/*/
METHOD AtualizaCamposAPINoRegistro(oItemAPI, oRegistro, cAlias, aMapaCampos) CLASS QualityAPIManager

	Local cAPI      := Nil //Campo na API
	Local cProtheus := Nil //Campo no Protheus
	Local cTipo     := Nil
	Local nCampos   := Len(aMapaCampos)
	Local nDecimal  := Nil
	Local nIndCampo := Nil
	Local nTamanho  := Nil

	Default oRegistro := JsonObject():New()
	
	For nIndCampo := 1 to nCampos
		If aMapaCampos[nIndCampo][nPosCPS_Alias] == cAlias
			cProtheus            := aMapaCampos[nIndCampo][nPosCPS_Protheus]
			cAPI                 := aMapaCampos[nIndCampo][nPosCPS_Titulo_API]
			cTipo                := aMapaCampos[nIndCampo][nPosCPS_Tipo]
			nTamanho             := aMapaCampos[nIndCampo][nPosCPS_Tamanho]
			nDecimal             := aMapaCampos[nIndCampo][nPosCPS_Decimal]
			oRegistro[cProtheus] := Self:formataDado(cTipo, oItemAPI[cAPI], "1", nTamanho, nDecimal)
		EndIf
	Next nIndCampo

Return oRegistro

/*/{Protheus.doc} AtualizaCamposBancoNoRegistro
Atualiza Campos do Banco no oRegistro
@author brunno.costa
@since  23/05/2022
@param 01 - oRegistro  , objeto  , objeto com os dados do registro para gravação no banco de dados
@param 02 - cAlias     , caracter, alias dos campos que deverão ser considerados do aMapaCampos para gravação no oRegistro
@param 03 - nRecno     , numérico, recno do registro de referencia no cAlias para consulta
@param 04 - aMapaCampos, array   , lista de campos {{nPosCPS_Considera, ..., nPosCPS_Decimal}} utilizada para atualização
@return lSucesso, lógico, indica se executou a operação com sucesso
/*/
METHOD AtualizaCamposBancoNoRegistro(oRegistro, cAlias, nRecno, aMapaCampos) CLASS QualityAPIManager

	Local cProtheus := Nil //Campo no Protheus
	Local lSucesso  := .T.
	Local nCampos   := Len(aMapaCampos)
	Local nIndCampo := Nil

	Default oRegistro := JsonObject():New()
	
	(cAlias)->(DbGoTo(nRecno))
	If (cAlias)->(Eof())
		lSucesso := .F.
	Else
		For nIndCampo := 1 to nCampos
			If aMapaCampos[nIndCampo][nPosCPS_Alias] == cAlias
				cProtheus            := aMapaCampos[nIndCampo][nPosCPS_Protheus]
				If cProtheus == "R_E_C_N_O_"
					oRegistro[cProtheus] := (cAlias)->(Recno())
				Else
					oRegistro[cProtheus] := (cAlias)->&(cProtheus)
				EndIf
			EndIf
		Next nIndCampo
	EndIf

Return lSucesso

/*/{Protheus.doc} ChangeQueryAllDB
Ajusta a Query para Uso em ORACLE / POSTGRES / SQL
@author brunno.costa
@since  23/05/2022
@param 01 - cQuery, caracter, query original
@param 02 - cBanco, caracter, banco consideração
@return cQuery, caracter    , query ajustada
/*/
METHOD ChangeQueryAllDB(cQuery, cBanco) CLASS QualityAPIManager
	Default cBanco := Self:cBanco
	cQuery := Self:oQueryManager:changeQuery(cQuery, cBanco)
Return cQuery

/*/{Protheus.doc} ValidaCamposObrigatorios
Valida Preenchimento dos Campos Obrigatórios Contidos no Registro JSON
@author brunno.costa
@since  24/06/2022
@param 01 - oRegistro, caracter, objeto JSON com os registros dos campos preparados para gravação
@param 02 - cCampos  , caracter, campos obrigatórios para API separados por PIPE "|"
@param 03 - cCpsErro , caracter, retorna por referência campos com erro
@return lSucesso, lógico, indica sucesso na validação de preenchimento dos campos obrigatórios
/*/
METHOD ValidaCamposObrigatorios(oRegistro, cCampos, cCpsErro) CLASS QualityAPIManager
	
	Local aCampos    := oRegistro:GetNames()
	Local cCampo     := ""
	Local cTipo      := ""
	Local lItemOk    := .T.
	Local lObrigat   := .F.
	Local lSucesso   := .T.
	Local nInd       := 0
	Local nTotal     := Len(aCampos)

	Default cCampos  := ""
	Default cCpsErro := ""

	Self:oCacheInicializadorCampos := Iif(Self:oCacheInicializadorCampos == Nil, JsonObject():New(), Self:oCacheInicializadorCampos)
	Self:oCacheGetSx3CacheTipo     := Iif(Self:oCacheGetSx3CacheTipo     == Nil, JsonObject():New(), Self:oCacheGetSx3CacheTipo    )

	For nInd := 1 to nTotal
		cCampo                                 := AllTrim(aCampos[nInd])
		If !("RECNO" $ cCampo ) .AND. cCampo != "R_E_C_N_O_"
			cTipo                              := Iif(Self:oCacheGetSx3CacheTipo[cCampo] == Nil,;
													GetSx3Cache(cCampo, "X3_TIPO")           ,;
													Self:oCacheGetSx3CacheTipo[cCampo]        )
			Self:oCacheGetSx3CacheTipo[cCampo] := cTipo
			lItemOk                            := .T.
			If cTipo != Nil .AND. !Empty(cTipo)
				lObrigat                               := Iif(Self:oCacheInicializadorCampos[cCampo] == Nil,;
														X3Obrigat(cCampo)                                ,;
														Self:oCacheInicializadorCampos[cCampo]            )

				Self:oCacheInicializadorCampos[cCampo] := lObrigat
				If lObrigat .OR. ("|"+cCampo+"|" $ cCampos)
					Do Case
						Case cTipo == "N"
							lItemOk := IIf(oRegistro[cCampo] == Nil, .F., .T.)
						Case cTipo $ "CH"
							lItemOk := IIf(Empty(oRegistro[cCampo]), .F., .T.)
						Case cTipo == "D"
							lItemOk := IIf(Empty(DtoS(oRegistro[cCampo])), .F., .T.)
					EndCase
				EndIf
				If !lItemOk
					lSucesso := .F.
					cCpsErro += Iif(Empty(cCpsErro), "", ", ") + AllTrim(cCampo)
				EndIf
			EndIf
		EndIf


	Next nInd
	
Return lSucesso

/*/{Protheus.doc} ValidaChaveEstrangeira
Valida Existência do Registro em Chave Estrangeira
@author brunno.costa
@since  24/06/2022
@param 01 - cAlias , caracter, alias para pesquisa da chave estrageira
@param 02 - nOrder , número  , indice da tabela
@param 03 - cChave , caracter, chave para pesquisa
@return lSucesso, lógico, indica sucesso na validação de chave estrangeira
/*/
METHOD ValidaChaveEstrangeira(cAlias, nOrder, cChave) CLASS QualityAPIManager

	Local lSucesso   := .T.
	Local aArea      := GetArea()

	(cAlias)->(DbSetOrder(nOrder))
	lSucesso := (cAlias)->(MsSeek(cChave))

	RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} ValidaFormatosCamposItem
Valida se os Campos Estão no Formato Correto para nPosCpo (API, Protheus...)
@author brunno.costa
@since  24/06/2022
@param 01 - oItemAPI   , caracter, alias para pesquisa da chave estrageira
@param 02 - aMapaCampos, número  , indice da tabela
@param 03 - cCpsErro   , caracter, retorna por referência os campos com erros
@param 04 - nPosCpo    , número  , posicao do campoo para checagem do valor
@return lSucesso, lógico, indica sucesso na validação dos formatos dos dados recebidos
/*/
METHOD ValidaFormatosCamposItem(oItemAPI, aMapaCampos, cCpsErro, nPosCpo) CLASS QualityAPIManager

	Local aArea      := GetArea()
	Local cCpoAPI    := Nil
	Local cTipo      := Nil
	Local cValType   := Nil
	Local lItemOk    := .T.
	Local lSucesso   := .T.
	Local nCampos    := Len(aMapaCampos)
	Local nIndCampo  := Nil

	Default cCpsErro := ""
	Default nPosCpo  := nPosCPS_Titulo_API
	Default oItemAPI := JsonObject():New()
	
	For nIndCampo := 1 to nCampos
		cCpoAPI   := aMapaCampos[nIndCampo][nPosCpo]
		If oItemAPI[cCpoAPI] != Nil
			cTipo    := aMapaCampos[nIndCampo][nPosCPS_Tipo]
			cValType := ValType(oItemAPI[cCpoAPI])
			lItemOk  := .T.

			lItemOk  := Iif(cTipo $ "CH" .AND. cValType != "C"                     , .F., lItemOk)
			lItemOk  := Iif(cTipo == "D" .AND. cValType != "C"                     , .F., lItemOk) //string "ano-mes-dia"
			lItemOk  := Iif(cTipo == "L" .AND. cValType != "C"                     , .F., lItemOk) //string "true" ou "false"
			lItemOk  := Iif(cTipo == "A" .AND. cValType != "A"                     , .F., lItemOk)
			lItemOk  := Iif((cTipo == "NN" .OR. cTipo == "N") .AND. cValType != "N", .F., lItemOk)

			If lItemOk .AND. cTipo == "D"
				lItemOk := Self:ValidaFormatoData(oItemAPI[cCpoAPI])
			EndIf

			If lItemOk .AND. cTipo == "H"
				lItemOk := Self:ValidaFormatoHora(oItemAPI[cCpoAPI])
			EndIf

			lSucesso := Iif(!lItemOk, .F., lSucesso)
			cCpsErro += Iif(!lItemOk, Iif(!Empty(cCpsErro),", ","") + cCpoAPI, "")
		EndIf

	Next nIndCampo

	RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} ValidaFormatoData
Valida se a variável é string de data JSON
@author brunno.costa
@since  24/06/2022
@param 01 - cData, caracter, string de data JSON AAAA-MM-DD
@return lSucesso, lógico, indica sucesso na validação dos formatos dos dados recebidos
/*/
METHOD ValidaFormatoData(cData) CLASS QualityAPIManager

	Local dData    := Nil
	Local lSucesso := .T.

	lSucesso := Len(cData) == 10
	lSucesso := Iif(lSucesso,    (Substring(cData,  1, 1)) $ "123456789"  , lSucesso)
	lSucesso := Iif(lSucesso,    (Substring(cData,  2, 1)) $ "0123456789" , lSucesso)
	lSucesso := Iif(lSucesso,    (Substring(cData,  3, 1)) $ "0123456789" , lSucesso)
	lSucesso := Iif(lSucesso,    (Substring(cData,  4, 1)) $ "0123456789" , lSucesso)
	lSucesso := Iif(lSucesso,    (Substring(cData,  5, 1)) $ "-" , lSucesso)
	lSucesso := Iif(lSucesso,    (Substring(cData,  6, 1)) $ "0123456789" , lSucesso)
	lSucesso := Iif(lSucesso,    (Substring(cData,  7, 1)) $ "0123456789" , lSucesso)
	lSucesso := Iif(lSucesso,    (Substring(cData,  8, 1)) $ "-" , lSucesso)
	lSucesso := Iif(lSucesso,    (Substring(cData,  9, 1)) $ "0123456789" , lSucesso)
	lSucesso := Iif(lSucesso,    (Substring(cData, 10, 1)) $ "0123456789" , lSucesso)

	lSucesso := Iif(lSucesso, Val(Substring(cData, 6, 2)) <= 12 , lSucesso)
	lSucesso := Iif(lSucesso, Val(Substring(cData, 9, 2)) <= 31 , lSucesso)

	If lSucesso
		dData    := StoD(StrTran(cData, "-", ""))
		lSucesso := dData != Nil .AND. !Empty(dData)
	EndIf
	
Return lSucesso

/*/{Protheus.doc} ValidaFormatoHora
Valida se a variável é string de hora
@author brunno.costa
@since  24/06/2022
@param 01 - cHora, caracter, string de hora HH:MM
@return lSucesso, lógico, indica sucesso na validação dos formatos dos dados recebidos
/*/
METHOD ValidaFormatoHora(cHora) CLASS QualityAPIManager

	Local lSucesso   := .T.
	Local cMinutos   := ""
	Local cSegundos  := ""

	lSucesso := Len(cHora) == 5
	If lSucesso
		cMinutos  := Substring(cHora, 1, 2)
		cSegundos := Substring(cHora, 4, 2)
		lSucesso  := Iif(lSucesso, Substring(cHora, 3, 1) == ":" , lSucesso)
		lSucesso  := Iif(lSucesso, Val(cMinutos)            <= 23, lSucesso)
		lSucesso  := Iif(lSucesso, Val(cSegundos)           <= 59, lSucesso)
	EndIf
	
Return lSucesso

/*/{Protheus.doc} ValidaUsuarioProtheus
Valida se o Login de usuário é Válido no Protheus
@author brunno.costa
@since  24/06/2022
@param 01 - cLogin, caracter, alias para pesquisa da chave estrageira
@return lExiste, lógico, usuário existente na base do Protheus (desconsidera empresa e filial)
/*/
METHOD ValidaUsuarioProtheus(cLogin) CLASS QualityAPIManager
	Local lExiste := .F.
	Self:aUsuarios := Iif(Self:aUsuarios == Nil, FWSFAllUsers(), Self:aUsuarios)
	If aScan(Self:aUsuarios, {|aUsuario| AllTrim(Lower(aUsuario[3])) == AllTrim(Lower(cLogin)) } ) > 0
		lExiste := .T.
	EndIf
Return lExiste

/*/{Protheus.doc} AvaliaPELaboratoriosRelacionadosAoUsuario
Avalia existência do ponto de entrada QIPINTAPI / QIEINTAPI
@author brunno.costa
@since  03/10/2022
@param 01 - cModulo, caracter, modulo de origem da consulta
/*/
METHOD AvaliaPELaboratoriosRelacionadosAoUsuario(cModulo) CLASS QualityAPIManager

	Default cModulo := "QIP"

	Self:lPELaboratoriosRelacionadosAoUsuario    := .F.

	If cModulo == "QIP"
		lQIPIntAPI                                   := Iif(lQIPIntAPI == Nil .AND. Self:lPEQIPLaboratoriosRelacionadosAoUsuario == Nil, ExistBlock('QIPINTAPI'), lQIPIntAPI)
		Self:lPEQIPLaboratoriosRelacionadosAoUsuario := Iif(Self:lPEQIPLaboratoriosRelacionadosAoUsuario == Nil, lQIPIntAPI, Self:lPEQIPLaboratoriosRelacionadosAoUsuario)
	Else
		lQIEIntAPI                                   := Iif(lQIEIntAPI == Nil .AND. Self:lPEQIELaboratoriosRelacionadosAoUsuario == Nil, ExistBlock('QIEINTAPI'), lQIEIntAPI)
		Self:lPEQIELaboratoriosRelacionadosAoUsuario := Iif(Self:lPEQIELaboratoriosRelacionadosAoUsuario == Nil, lQIPIntAPI, Self:lPEQIELaboratoriosRelacionadosAoUsuario)
	EndIf

	Self:lPELaboratoriosRelacionadosAoUsuario := Self:lPEQIELaboratoriosRelacionadosAoUsuario .OR. Self:lPEQIPLaboratoriosRelacionadosAoUsuario


Return

/*/{Protheus.doc} existePEIntegracaoAppMinhaProducaoCompilado
Indica se existe ponto de entrada QIPINTAPI / QIEINTAPI compilado no RPO
@author brunno.costa
@since  20/02/2025
@param 01 - cModulo, caracter, modulo de origem da consulta
/*/
METHOD existePEIntegracaoAppMinhaProducaoCompilado(cModulo) CLASS QualityAPIManager
	Local lExiste := .F.
	Default cModulo := "QIP"
	self:AvaliaPELaboratoriosRelacionadosAoUsuario(cModulo)
	If cModulo == "QIP"
		lExiste := Self:lPEQIPLaboratoriosRelacionadosAoUsuario
	Else
		lExiste := Self:lPEQIELaboratoriosRelacionadosAoUsuario
	EndIf
Return lExiste

/*/{Protheus.doc} RetornaFiltroPELaboratoriosRelacionadosAoUsuario
Ajusta Query de Pesquisa relacionada ao Ponto de Entrada QIPINTAPI
@author brunno.costa
@since  03/10/2022
@param 01 - cCampo   , caracter, campo para filtro
@param 02 - cUsuario , caracter, usuario consumindo a API
@param 03 - cEndPoint, caracter, endpoint que está consumindo a API
@return cWhere, caracter, condição para adicionar a clausula where da consulta no banco
/*/
METHOD RetornaFiltroPELaboratoriosRelacionadosAoUsuario(cCampo, cUsuario, cEndPoint) CLASS QualityAPIManager

	Local aRetPE        := {}
	Local bErrorBlock   := ErrorBlock({|e| Self:ErrorBlock(e, STR0002), Break(e)}) //"Erro no processamento do Ponto de Entrada QIPINTAPI."
	Local cLaboratorios := ""
	Local cWhere        := ""
	Local nLaboratorio  := 0
	Local oObj          := Nil
	
	lQAStrToASC   := Iif(lQAStrToASC == Nil, FindFunction("QAStrToASC"), lQAStrToASC)

	If Self:lPEQIPLaboratoriosRelacionadosAoUsuario .OR. Self:lPEQIELaboratoriosRelacionadosAoUsuario
		Begin Sequence
			oObj                 := JsonObject():New()
			oObj["loginUsuario"] := cUsuario

			If Self:lPEQIPLaboratoriosRelacionadosAoUsuario
				aRetPE := Execblock('QIPINTAPI',.F.,.F.,{oObj, cEndPoint, "QualityAPIManager", "laboratoriosRelacionadosAoUsuario"})
			Else
				aRetPE := Execblock('QIEINTAPI',.F.,.F.,{oObj, cEndPoint, "QualityAPIManager", "laboratoriosRelacionadosAoUsuario"})
			EndIf

			If Valtype(aRetPE) == 'A'
				If  Empty(aRetPE)
					cWhere := " AND 1 = 0 "
				Else
					For nLaboratorio := 1 To Len(aRetPE) 
						cLaboratorios += Iif(lQAStrToASC, QAStrToASC(aRetPE[nLaboratorio]), "'" + aRetPE[nLaboratorio] + "'") + ","
					Next nLaboratorio
				EndIf
			Endif

			cLaboratorios := Left(cLaboratorios, Len(cLaboratorios) - 1)
			If !Empty(cLaboratorios)
				cWhere        := " AND " + cCampo + " IN (" + cLaboratorios + ") "
			EndIf

		End Sequence
	EndIf
	ErrorBlock(bErrorBlock)
	
Return cWhere

/*/{Protheus.doc} ChecaLaboratorioValidoParaUsuario
Ajusta Query de Pesquisa relacionada ao Ponto de Entrada QIPINTAPI
@author brunno.costa
@since  03/10/2022
@param 01 - cUsuario , caracter, usuario consumindo a API
@param 02 - cEndPoint, caracter, endpoint que está consumindo a API
@param 03 - cLaboratorio, caracter, codigo do laboratorio
@return cWhere, caracter, condição para adicionar a clausula where da consulta no banco
/*/
METHOD ChecaLaboratorioValidoParaUsuario(cUsuario, cEndPoint, cLaboratorio) CLASS QualityAPIManager

	Local aRetPE        := {}
	Local bErrorBlock   := ErrorBlock({|e| Self:ErrorBlock(e, STR0002), Break(e)}) //"Erro no processamento do Ponto de Entrada QIPINTAPI."
	Local oObj          := Nil
	Local lValido       := .T.

	If Self:lPEQIPLaboratoriosRelacionadosAoUsuario .OR. Self:lPEQIELaboratoriosRelacionadosAoUsuario
		Begin Sequence
			oObj                 := JsonObject():New()
			oObj["loginUsuario"] := cUsuario

			If Self:lPEQIPLaboratoriosRelacionadosAoUsuario
				aRetPE := Execblock('QIPINTAPI',.F.,.F.,{oObj, cEndPoint, "QualityAPIManager", "laboratoriosRelacionadosAoUsuario"})
			Else
				aRetPE := Execblock('QIEINTAPI',.F.,.F.,{oObj, cEndPoint, "QualityAPIManager", "laboratoriosRelacionadosAoUsuario"})
			EndIf
	
			If Valtype(aRetPE) == 'A'
				lValido := aScan(aRetPE, {|x| AllTrim(x) == AllTriM(cLaboratorio) }) > 0
			Endif

		End Sequence
	EndIf
	ErrorBlock(bErrorBlock)
	
Return lValido

/*/{Protheus.doc} ErrorBlock
Proteção para Execução de Error.log
@author brunno.costa
@since  03/10/2022
@param 01 - e            , objeto  , objeto de errror.log
@param 02 - cErrorMessage, caracter, texto para representar o local do erro 
@param 03 - nTotal, número, indica a quantidade de chamadas para CallStack
/*/
METHOD ErrorBlock(e, cErrorMessage, nTotal) CLASS QualityAPIManager
	Default nTotal        := 15
	Self:cErrorMessage    := cErrorMessage
	Self:cDetailedMessage := e:Description +  Self:CallStack(nTotal)
Return .F.

/*/{Protheus.doc} CallStack
Proteção para Execução de Error.log
@author brunno.costa
@since  03/10/2022
@param 01 - nTotal, número, indica a quantidade de chamadas para CallStack
@return cCallStack, caracter, call stack da chamada
/*/
METHOD CallStack(nTotal) CLASS QualityAPIManager
	Local cCallStack := ""
	Local nIndice    := 2
	Local nTotAux    := 0
	Default nTotal   := 15
	nTotAux    := nTotal + nIndice
	For nIndice := 2 to nTotAux
		cCallStack += " [" + ProcName(nIndice)+":"+ cValToChar(ProcLine(nIndice)) + "] <- "
	Next nIndice
Return cCallStack




