#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

Static snTamCod    := 90

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
Static sTAM_OPC      := 10

Static sPRD_ESTSEG := 3
Static sPRD_SLDDIS := 6
Static sPRD_NIVEST := 7
Static sPRD_CHAVE2 := 8
Static sPRD_IDOPC  := 14
Static sPRD_PPED   := 19

/*/{Protheus.doc} MrpDominio_Opcional
Regras de negocio MRP - Produtos Opcionais
@author    brunno.costa
@since     14/05/2019
@version   1
/*/
CLASS MrpDominio_Opcional FROM LongClassName

	DATA cChaveJs    AS CHARACTER
	DATA oDados      AS OBJECT
	DATA oParametros AS OBJECT   //Objeto JSON com todos os parametros do MRP - Consulte MRPAplicacao():parametrosDefault()

	METHOD new(oDados) CONSTRUCTOR
	METHOD adicionaLista(cFilAux, cProduto, cIDOpc)
	METHOD converteJsonEmID(cFilAux, cJsonOrig, cTabRecno, nRecno, cPathOrig, cIDInterme, lLastPath)
	METHOD copiaProduto(cProduto, cIDOpc, lDefault, aDefault)
	METHOD criaIDsIntermediarios(cFilAux, oJson, cIDMaster, cTabRecno, nRecno, cPathOrig, cIDInterme, lLastPath)
	METHOD insereProdutosOpcionais()
	METHOD removeKeyOpcional(cJson)
	METHOD retornaChave(cChave2)
	METHOD retorna2Chave(cChave)
	METHOD retornaIDComponente(cComponente, cIDOpcPai)
	METHOD retornaIDMaster(cJson)
	METHOD selecionado(cIDOpcSel, cGrupo, cItem)
	METHOD montaT4SPath(cFilAux, cIDRegistro, cComponente, aPathOrig)
	METHOD montaT4QPath(cFilAux, cIDRegistro, cOP, aPathOrig)
	METHOD registraDadosOpcDefault(cChaveProd, cIdOpc, nQtdDisp, nQtdES, nQtdPP)
	METHOD separaIdChaveProduto(cChaveProd, cIdOpc)
	METHOD salvaIntermediarios(cJson)
	METHOD buscaPorItermediario(cJson, lError)
	METHOD setChaveId(cChave, aDados)
	METHOD getChaveId(cChave)
	METHOD validaOpcionalDefault(cChaveDef,cChaveComp)

ENDCLASS

/*/{Protheus.doc} new
Metodo construtor
@author    brunno.costa
@since     14/05/2019
@version   1
@param 01 - oDados, objeto, instancia da classe de dados
@return Self, objeto, instancia da classe
/*/
METHOD new(oDados) CLASS MrpDominio_Opcional
    ::oDados := oDados
	::oParametros := oDados:oParametros
Return Self

/*/{Protheus.doc} converteJsonEmID
Converte Json despadronizado em ID Master - ID da demanda na Matriz
@author    brunno.costa
@since     14/05/2019
@version   1
@param 01 - cFilAux   , caracter, código da filial para processamento
@param 02 - cJsonOrig , caracter, string Json de opcionais - despadronizado
@param 03 - cTabRecno , caracter, Tabela utilizada para obter a origem do registro de opcional
@param 04 - nRecno    , número  , código do RECNO referente registro na 'cTabRecno' quando existir MEMO Opcional
@param 05 - cPathOrig , caracter, string com o path do opcional atual para pesquisa do cIDInterme (ID intermediário)
@param 06 - cIDInterme, caracter, utilizado em conjunto com os parâmetros 05 e 06 para retornar por referencia o ID do intermediario
@param 07 - lLastPath , logic   , utilizado em conjunto com os parâmetros 05 e 06. Indica que buscará pela última parte do path apenas.
@return cReturn, caracter, ID Master referente a string JSON
/*/
METHOD converteJsonEmID(cFilAux, cJsonOrig, cTabRecno, nRecno, cPathOrig, cIDInterme, lLastPath) CLASS MrpDominio_Opcional
	Local cReturn   := ""
	Local cValOpc   := ""
	Local lCheckVal := .F.
	Local oJson     := Nil

	Default cTabRecno  := ""
	Default nRecno     := 0
	Default lLastPath  := .F.

	// Se cJsonOrig estiver igual a "[]" significa que sincronizou um opcional diferente do que está na estrutura do produto.
	// (Ocorre quando a estrutura tem os opcionais alterados, e não foi atualizado o default / opcional do documento).
	// Neste caso não realiza vinculo opcional.
	If cJsonOrig == "[]"
		Return ""
	EndIf


	If !Empty(cJsonOrig)
		oJson := JsonObject():new()

		//Padroniza string recebida.
		cJsonOrig := '{"OPTIONAL": ' + cJsonOrig + '}'
		//Busca ID relacionado a este opcional
		cReturn   := ::retornaIDMaster(@cJsonOrig, @lCheckVal, @cValOpc, cPathOrig)
		//Cria objeto JSON após padronização realizada no método retornaIDMaster
		oJson:fromJson(cJsonOrig)

		::criaIDsIntermediarios(cFilAux, oJson, cReturn, cTabRecno, nRecno, cPathOrig, @cIDInterme, lLastPath, lCheckVal, cValOpc)

	EndIf

Return cReturn

/*/{Protheus.doc} retornaIDMaster
Retorna ID Master com base em cJson padronizado - ID da demanda na Matriz
@author    brunno.costa
@since     14/05/2019
@version   1
@param 01 - cJson    , Character, String JSON de opcionais para validação (retorna conteúdo atualizado por referência)
@param 02 - lCheckVal, Logico   , Retorna por referência se deve comparar o valor do opcional na hora de retornar o id itermediario.
@param 03 - cValOpc  , Character, Retorna por referência o valor do opcional para comparação. (Usado em conjunto com o parâmetro 02)
@param 04 - cPathOrig, Character, String com o path do opcional para pegar o valor que será usado para comparar o retorno do intermediario.
@return cReturn, caracter, ID Master referente a string JSON
/*/
METHOD retornaIDMaster(cJson, lCheckVal, cValOpc, cPathOrig) CLASS MrpDominio_Opcional
	Local lError  := .F.
	Local cReturn := ""

	If !Self:oDados:oOpcionais:existList("JSONORIG")
		Self:oDados:oOpcionais:createList("JSONORIG", .T.)
	EndIf

	//Remove produtos sem opcionais diretos das chaves do JSON.
	cJson := Self:removeKeyOpcional(cJson, @lCheckVal, @cValOpc, cPathOrig)

	cReturn := ::oDados:oJsonOpcionais:getnKey(1, cJson, @lError, .F.)

	If cReturn == Nil
		If ::oDados:oJsonOpcionais:addKey(1, cJson, @lError, .F., Nil, @cReturn)
			cReturn := "M" + cValToChar(cReturn)
		Else
			cReturn := ""
		EndIf
	Else
		cReturn := "M" + cValToChar(cReturn)
	EndIf

Return cReturn

/*/{Protheus.doc} removeKeyOpcional
Remove da chave de opcionais os produtos que não possuem diretamente
o vínculo com uma seleção de opcionais.

@author lucas.franca
@since 13/07/2022
@version P12
@param 01 - cJson    , Character, JSON de opcionais
@param 02 - lCheckVal, Logico   , Retorna por referência se deve comparar o valor do opcional na hora de retornar o id itermediario.
@param 03 - cValOpc  , Character, Retorna por referência o valor do opcional para comparação. (Usado em conjunto com o parâmetro 02)
@param 04 - cPathOrig, Character, String com o path do opcional para pegar o valor que será usado para comparar o retorno do intermediario.
@return cJson, Character, Novo JSON de opcionais, com a seleção padronizada
/*/
METHOD removeKeyOpcional(cJson, lCheckVal, cValOpc, cPathOrig) CLASS MrpDominio_Opcional
	Local aKey     := {}
	Local aPrdTrt  := {}
	Local cProduto := ""
	Local cRemove  := ""
	Local cJsOrig  := cJson
	Local cJsAux   := ""
	Local lError   := .F.
	Local nTamTRT  := 0
	Local nIndKey  := 0
	Local nIndOpc  := 0
	Local nTotKey  := 0
	Local nTotOpc  := 0
	Local nPosTrt  := 0
	Local oJson    := JsonObject():New()

	oJson:fromJson(cJson)
	nTotOpc := Len(oJson["OPTIONAL"])
	//Percorre todas as chaves de opcionais
	For nIndOpc := 1 To nTotOpc
		aKey := StrTokArr(oJson["OPTIONAL"][nIndOpc]["key"], "|")
		nTotKey := Len(aKey)
		//Para cada chave, percorre todos os produtos da chave
		For nIndKey := 1 To nTotKey
			aPrdTrt  := StrTokArr(aKey[nIndKey], ";")
			cProduto := RTrim(aPrdTrt[1])
			nTamTRT  := 4
			If Len(aPrdTrt) > 1
				nTamTRT := Len(aPrdTrt[2]) + 1
			EndIf
			aSize(aPrdTrt, 0)

			//Verifica em todas as chaves de opcionais se este
			//produto possui alguma seleção de opcional
			//Produto que possui seleção de opcional:
			//Ou é o único produto existente na chave "key", ou é o último produto da chave "key".
			If aScan(oJson["OPTIONAL"], {|x| x["key"] == cProduto .Or. cProduto $ Right(x["key"], Len(cProduto)+nTamTRT) }) < 1
				//Não encontrou vinculo com este produto, irá remover ele da chave.
				cRemove := aKey[nIndKey]
				If At(cProduto+"|",oJson["OPTIONAL"][nIndOpc]["key"]) > 0 .Or. ; //É o primeiro produto da chave.
				   At(cRemove+"|",oJson["OPTIONAL"][nIndOpc]["key"]) > 0 //Esta no meio da chave
					cRemove += "|"
				EndIf
				oJson["OPTIONAL"][nIndOpc]["key"] := StrTran(oJson["OPTIONAL"][nIndOpc]["key"], cRemove, "")
			EndIf
		Next nIndKey
		aSize(aKey, 0)

		// Retorna por referência o valor do opcional para comparar no momento de retornar o intermediro.
		If AllTrim(oJson["OPTIONAL"][nIndOpc]["key"]) == cPathOrig
			lCheckVal := .T.
			cValOpc := oJson["OPTIONAL"][nIndOpc]["value"]
		EndIf

		//Se ficou somente um produto na chave, verifica se precisa remover a informação do TRT da chave.
		nPosTrt := At(";", oJson["OPTIONAL"][nIndOpc]["key"])
		If Len(StrTokArr(oJson["OPTIONAL"][nIndOpc]["key"], "|")) == 1 .And. nPosTrt > 0
			cRemove := SubStr(oJson["OPTIONAL"][nIndOpc]["key"], nPosTrt, Len(oJson["OPTIONAL"][nIndOpc]["key"]))
			oJson["OPTIONAL"][nIndOpc]["key"] := RTrim(StrTran(oJson["OPTIONAL"][nIndOpc]["key"], cRemove, ""))
		EndIf
	Next nIndOpc

	//Novo JSON, sem as chaves dos produtos que não possuem o vínculo direto com opcional.
	cJson  := oJson:toJson()
	//Verifica se este JSON já foi processado para algum outro nível.
	cJsAux := Self:oDados:oOpcionais:getItemList("JSONORIG", cJson, @lError, .F.)
	If lError .Or. Len(cJsAux) < Len(cJsOrig)
		If lError
			cJsAux := Self:buscaPorItermediario(cJson, @lError)
		EndIf

		If lError .Or. Len(cJsAux) < Len(cJsOrig)
			//Armazena o JSON completo vinculado ao JSON sem as chaves.
			Self:oDados:oOpcionais:setItemList("JSONORIG", cJson, cJsOrig)
			Self:salvaIntermediarios(cJson)
			If !lError
				cJsAux := cJsOrig
			EndIf
		EndIf
	EndIf

	::cChaveJs := cJson

	//Irá retornar o JSON mais completo existente.
	cJson := Iif(lError, cJsOrig, cJsAux)


	FwFreeObj(oJson)
Return cJson

/*/{Protheus.doc} criaIDsIntermediarios
Cria os ID's intermediarios para os Json recebidos
Estes ID's diferenciam registros sem opcionais na matriz do MRP dos registros oriundos de Opcionais
@author    brunno.costa
@since     14/05/2019
@version   1
@param 01 - cFilAux   , caracter, código da filial para processamento
@param 02 - oJson     , objeto  , instancia de objeto Json de Opcionais
@param 03 - cIDMaster , caracter, ID Master para criar os IDs intermediarios
@param 04 - cTabRecno , caracter, Tabela utilizada para obter a origem do registro de opcional
@param 05 - nRecno    , número  , código do RECNO referente registro na 'cTabRecno' quando existir MEMO Opcional
@param 06 - cPathOrig , caracter, string com o path do opcional atual para pesquisa do cIDInterme (ID intermediário)
@param 07 - cIDInterme, caracter, utilizado em conjunto com o parâmetro 06 para retornar por referencia o ID do intermediario
@param 08 - lLastPath , logic   , utilizado em conjunto com os parâmetros 06 e 07. Indica que buscará pela última parte do path apenas.
@param 09 - lCheckVal, Logico   , Retorna por referência se deve comparar o valor do opcional na hora de retornar o id itermediario.
@param 10 - cValOpc  , Character, Retorna por referência o valor do opcional para comparação. (Usado em conjunto com o parâmetro 09)
/*/
METHOD criaIDsIntermediarios(cFilAux, oJson, cIDMaster, cTabRecno, nRecno, cPathOrig, cIDInterme, lLastPath, lCheckVal, cValOpc) CLASS MrpDominio_Opcional

	Local aRegistro   := {}
	Local aPathArray  := {}
	Local cChave2     := ""
	Local cChave      := ""
	Local cIDPai      := ""
	Local cNewPath    := ""
	Local cPath       := ""
	Local cOpcionais  := ""
	Local cProduto    := ""
	Local lAddRow     := .F.
	Local lError      := .F.
	Local lUsaME      := .F.
	Local lGravou     := .F.
	Local nOpcionais  := 0
	Local nIndOpc     := 0
	Local nIndPath    := 0
	Local nPathProds  := 0
	Local nPosAux     := 0
	Local nSeqID      := 0
	Local oOpcionais  := ::oDados:oOpcionais

	Default cIDInterme := ""
	Default lLastPath  := .F.

	lUsaME := ::oDados:oDominio:oMultiEmp:utilizaMultiEmpresa()

	nOpcionais := Len(oJson["OPTIONAL"])
	For nIndOpc := 1 to nOpcionais
		cPath      := oJson["OPTIONAL"][nIndOpc]["key"]
		cOpcionais := oJson["OPTIONAL"][nIndOpc]["value"]
		aPathArray := StrTokArr(cPath, "|")
		nPathProds := Len(aPathArray)
		cNewPath   := ""
		nPosAux    := 0

		//Percorre produtos do Path
		For nIndPath := 1 to nPathProds
			cIDPai   := ::oDados:retornaCampo("OPC", 1, cIDMaster + Iif(!Empty(cNewPath), "|" + cNewPath, ""), "OPC_ID")

			If Empty(cNewPath)
				cNewPath += RTrim(aPathArray[nIndPath])
			Else
				cNewPath += "|" + RTrim(aPathArray[nIndPath])
			EndIf

			cChave := cIDMaster + "|" + cNewPath                 //Chave primaria

			oOpcionais:trava(cChave)
			If !oOpcionais:getRow(1, cChave, Nil, @aRegistro, .F., .F.)
				If Empty(cIDPai)
					cIDPai    := ""
					cID       := cIDMaster
					cChave2   := cIDMaster              //Chave estrangeira tabela Matriz MRP

					//Verifica se o ID já foi registrado
					lGravou := oOpcionais:getFlag("IDGRAVADO" + cID, @lError, .F.)
					If !lError .And. lGravou
						oOpcionais:destrava(cChave)
						Loop
					Else
						oOpcionais:setFlag("IDGRAVADO" + cID, .T., @lError, .F., .F., .F.)
					EndIf
				Else
					lError := .F.
					oOpcionais:setFlag("OPC_ID_SEQUENCE", @nSeqID, @lError, .F., .F., .T.)
					If lError
						nSeqID := oOpcionais:getRowsNum(.F.) + 1
					EndIf
					cID       := "I" + cValToChar(nSeqID)
					cChave2   := cIDMaster + "|" +  cID //Chave estrangeira tabela Matriz MRP
				EndIf

				aRegistro                := Array(sTAM_OPC)
				aRegistro[sOPC_KEY     ] := cChave
				aRegistro[sOPC_KEY2    ] := cChave2
				aRegistro[sOPC_OPCION  ] := Iif(nIndPath == nPathProds,  cOpcionais, "")
				aRegistro[sOPC_ID      ] := cID
				aRegistro[sOPC_IDPAI   ] := cIDPai
				aRegistro[sOPC_IDMASTER] := cIDMaster
				aRegistro[sOPC_TABRECNO] := cTabRecno
				aRegistro[sOPC_RECNO   ] := nRecno
				aRegistro[sOPC_FILIAIS ] := {cFilAux}
				aRegistro[sOPC_DEFAULT ] := .F.

				lAddRow := .T.

			Else
				If Empty(aRegistro[sOPC_OPCION])
					aRegistro[sOPC_OPCION] := Iif(nIndPath == nPathProds,  cOpcionais, "")
					lAddRow := .T.
				ElseIf !(cOpcionais$aRegistro[sOPC_OPCION])
					aRegistro[sOPC_OPCION] += Iif(nIndPath == nPathProds,  "|" + cOpcionais, "")
					lAddRow := .T.
				EndIf

				cChave2 := aRegistro[sOPC_KEY2]

				If lUsaME .And. aScan(aRegistro[sOPC_FILIAIS], {|x| x == cFilAux}) < 1
					aAdd(aRegistro[sOPC_FILIAIS], cFilAux)
					lAddRow := .T.
				EndIf

			EndIf

			//Identifica o ID do Opcional Intermediario
			If cPathOrig != Nil .And. Empty(cIDInterme)
				If testPath(cNewPath, cPathOrig, lLastPath, lCheckVal)
					If lCheckVal .And. !Empty(cValOpc)
						If AllTrim(cValOpc) == AllTrim(aRegistro[sOPC_OPCION])
							cIDInterme := aRegistro[sOPC_KEY2]
						EndIf
					Else
			    		cIDInterme := aRegistro[sOPC_KEY2]
					EndIf
				EndIf
			EndIf

			If lAddRow
				cProduto := StrTokArr(aPathArray[nIndPath], ";")[1]
				::adicionaLista(cFilAux, PadR(cProduto, snTamCod), cChave2)
				::setChaveId(cFilAux + PadR(cProduto, snTamCod), {cChave2, ::cChaveJs})

				oOpcionais:addRow(cChave, aRegistro, .F., .F., cChave2)
			EndIf
			oOpcionais:destrava(cChave)
		Next

	Next nInd

Return

/*/{Protheus.doc} retornaChave
Retorna a chave com base na chave 2
@author    brunno.costa
@since     14/05/2019
@version   1
@param 01 - cChave2, caracter, string referente chave extrangeira tabela Matriz MRP - Calculo (ID Master + ID)
@return cChave, caracter, chave primaria da tabela de opcionais (ID Master + Path)
/*/
METHOD retornaChave(cChave2) CLASS MrpDominio_Opcional
Return ::oDados:retornaCampo("OPC", 2, cChave2, "OPC_KEY")

/*/{Protheus.doc} retornaChave2
Retorna a chave 2 (chave extrangeira tabela Matriz MRP - Calculo) com base na chave
@author    brunno.costa
@since     14/05/2019
@version   1
@param 01 - cChave, caracter, chave primaria da tabela de opcionais (ID Master + Path)
@return cChave2, caracter, string referente chave extrangeira tabela Matriz MRP - Calculo (ID Master + ID)
/*/
METHOD retorna2Chave(cChave) CLASS MrpDominio_Opcional
Return ::oDados:retornaCampo("OPC", 1, cChave, "OPC_KEY2")

/*/{Protheus.doc} retornaIDComponente
Retorna cChave2 do componente com base no ID Opcional do pai
@author    brunno.costa
@since     14/05/2019
@version   1
@param 01 - cIDOpcPai  , caracter, ID Opcional do produto pai
@param 02 - cComponente, caracter, codigo do componente
@param 03 - cTRT       , caracter, TRT do componente
@return cChave2, caracter, string referente chave extrangeira tabela Matriz MRP - Calculo (ID Master + ID)
/*/
METHOD retornaIDComponente(cIDOpcPai, cComponente, cTRT) CLASS MrpDominio_Opcional
	Local cPathPai
	Local cReturn  := ""
	Default cTRT := ""
	If !Empty(cIDOpcPai)
		cPathPai := ::retornaChave(cIDOpcPai)
		If !Empty(cPathPai)
			cReturn  := ::retorna2Chave(cPathPai + "|" + RTrim(cComponente) + ";" + AllTrim(cTRT))
		EndIf
	EndIf
Return cReturn

/*/{Protheus.doc} selecionado
Identifica se o opcional esta selecionado
@author    brunno.costa
@since     14/05/2019
@version   1
@param 01 - cIDOpcSel, caracter, ID do opcional selecionado
@param 02 - cGrupo   , caracter, grupo de opcionais da SG1
@param 03 - cItem    , caracter, item opcionais da SG1
@return lReturn, logico, indica se o opcional esta selecionado
/*/
METHOD selecionado(cIDOpcSel, cGrupo, cItem) CLASS MrpDominio_Opcional
	Local cSelecoes   := ""
	Local lReturn     := .F.

	If !Empty(cIDOpcSel)
		cSelecoes   := ::oDados:retornaCampo("OPC", 2, cIDOpcSel, "OPC_OPCION")
		lReturn     := !Empty(cSelecoes) .AND. ((cGrupo + ";" + cItem) $ cSelecoes)
	EndIf

Return lReturn

/*/{Protheus.doc} adicionaLista
Adiciona ID de opcional a lista de processamento dos produtos opcionais
@author    brunno.costa
@since     14/05/2019
@version   1
@param 01 - cFilAux  , caracter, codigo da filial para processamento
@param 02 - cProduto , caracter, codigo do produto
@param 03 - cIDOpc   , caracter, ID do opcional
/*/
METHOD adicionaLista(cFilAux, cProduto, cIDOpc) CLASS MrpDominio_Opcional
	Local oOpcionais := ::oDados:oOpcionais
	If !oOpcionais:existList("OPC_" + cFilAux + cProduto)
		oOpcionais:createList("OPC_" + cFilAux + cProduto)
	EndIf
	oOpcionais:setItemList("OPC_" + cFilAux + cProduto, cIDOpc, "")

	If !oOpcionais:existList("OPC_Produtos_")
		oOpcionais:createList("OPC_Produtos_")
	EndIf
	oOpcionais:setItemList("OPC_Produtos_", cFilAux + cProduto, "")
Return

/*/{Protheus.doc} insereProdutosOpcionais
Insere os produtos opcionais no cadastro de produtos
@author    brunno.costa
@since     14/05/2019
@version   1
/*/
METHOD insereProdutosOpcionais() CLASS MrpDominio_Opcional
	Local aChavesId  := {}
	Local aDadosSMV  := {}
	Local aProdsOPC  := {}
	Local aIDsOPC    := {}
	Local aDefault   := {}
	Local cIDOpc     := ""
	Local cJsDefault := ""
	Local cProduto   := ""
	Local cOpc       := ""
	Local lError     := .F.
	Local lUsaME     := .F.
	Local nIndProd   := 0
	Local nIndIDs    := 0
	Local nInDefault := 0
	Local nProdsOPC  := 0
	Local nPos       := 0
	Local nIDsOPC    := 0
	Local nStart     := 0
	Local nTamPrd    := snTamCod
	Local oOpcionais := ::oDados:oOpcionais
	Local oMultiEmp  := ::oDados:oDominio:oMultiEmp

	lUsaME := oMultiEmp:utilizaMultiEmpresa()
	aDadosSMV := ::oDados:oMatriz:getItemAList("DOCMRP_T4V", "T4V")

	If lUsaME
		nTamPrd += oMultiEmp:tamanhoFilial()
	EndIf

	oOpcionais:order(2, @lError) //Reordena.

	If oOpcionais:existList("OPC_Produtos_")
		oOpcionais:getAllList("OPC_Produtos_", aProdsOPC, @lError)
		nProdsOPC := Len(aProdsOPC)

		For nIndProd := 1 to nProdsOPC
			cProduto := PadR(aProdsOPC[nIndProd][1], nTamPrd)
			aIDsOPC  := {}
			oOpcionais:getAllList("OPC_" + cProduto, aIDsOPC, @lError)
			nIDsOPC  := Len(aIDsOPC)
			aChavesId := ::getChaveId(cProduto)

			//Verifica se o produto possui opcionais default
			nInDefault := 0
			lError     := .F.
			cOpc       := ""
			aDefault   := oOpcionais:getItemAList("OPC_DEFAULT", cProduto, @lError, .F.)
			If !lError
				cOpc := aDefault[1]

				If !Empty(aChavesId)
					// Recupera o json do id default.
					nPos := aScan(aChavesId, {|x| x[1] == cOpc})
					If nPos > 0
						cJsDefault := aChavesId[nPos][2]

						// Busca um id com mesmo json que o criado para o id do default.
						nPos := aScan(aChavesId, {|x| x[1] != cOpc .And. ::validaOpcionalDefault(cJsDefault,x[2])})
						If nPos > 0
							nInDefault := aScan(aIDsOPC, {|x| x[1] == aChavesId[nPos][1]})
						EndIf
					EndIf
				EndIf

				// Se não encontrou um id com json igual ao do default, procura pela posição do default no array dos ids.
				If nInDefault == 0
					nInDefault := aScan(aIDsOPC, {|x| x[1] == cOpc})
				Else
					// Se encontrou um novo default, atualiza o opcional na SMV.
					nPos := -1
					nStart := 1

					while nPos != 0
						nPos := aScan(aDadosSMV, {|x| x[2] == cProduto}, nStart)

						If nPos > 0
							aDadosSMV[nPos][3] := aIDsOPC[nInDefault][1]
							nStart := nPos + 1
						EndIf
					End
				EndIf
			EndIf

			For nIndIDs := 1 to nIDsOPC

				cIDOpc := aIDsOPC[nIndIDs][1]

				::copiaProduto(cProduto, cIDOpc, (nIndIDs == nInDefault), aDefault)

			Next nIndIDs

			If !lError
				aSize(aDefault, 0)
			EndIf

		Next nIndProd

		::oDados:oMatriz:setItemAList("DOCMRP_T4V", "T4V", aDadosSMV)
	EndIf

Return

/*/{Protheus.doc} copiaProduto
Copia o cadastro na tabela de produtos
@author    brunno.costa
@since     14/05/2019
@version   1
@param 01 - cProduto, caracter, codigo do produto
@param 02 - cIDOpc  , caracter, ID do opcional relacionado ao produto novo
@param 03 - lDefault, Logico  , Indica que este é o opcional default do produto
@param 04 - aDefault, Array   , Array com as informações de opcional padrão do produto
/*/
METHOD copiaProduto(cProduto, cIDOpc, lDefault, aDefault) CLASS MrpDominio_Opcional

	Local aOpcional := {}
	Local aProduto  := {}
	Local cChave    := ""
	Local lError    := .F.
	Local lReturn   := .T.
	Local nSaldo    := 0
	Local nPPed     := 0
	Local nEstSeg   := 0

	aProduto := ::oDados:retornaLinha("PRD", 1, cProduto, @lError, .F.)

	If !lError
		If lDefault
			nSaldo  := aDefault[2]
			nEstSeg := aDefault[3]
			nPPed   := aDefault[4]
		EndIf
		aProduto[sPRD_ESTSEG] := nEstSeg
		aProduto[sPRD_SLDDIS] := nSaldo
		aProduto[sPRD_PPED  ] := nPPed
		aProduto[sPRD_IDOPC ] := cIDOpc
		aProduto[sPRD_CHAVE2] := aProduto[sPRD_CHAVE2] + "|" + cIDOpc

		::oDados:gravaLinha("PRD", 1, cProduto + "|" + cIDOpc, aProduto, @lError, .F., .T.) //Inclui copia
		lReturn := !lError

		::oDados:oProdutos:setflag("nProdutosN" + aProduto[sPRD_NIVEST], 1, .F., .F., .T.) //incrementa
		::oDados:oProdutos:setflag("nProdCalcN" + aProduto[sPRD_NIVEST], 0, .F., .F.)
	EndIf

	If lDefault
		cChave := ::retornaChave(cIDOpc)
		::oDados:oOpcionais:getRow(1, cChave,, @aOpcional, @lError, .F.)

		If !lError
			aOpcional[sOPC_DEFAULT] := .T.

			::oDados:oOpcionais:updRow(1, cChave,, @aOpcional, @lError, .F.)
		EndIf
	EndIf

Return lReturn

/*/{Protheus.doc} montaT4SPath
Monta Path da T4S e Identifica a string do Opcional Selecionada
@author    brunno.costa
@since     21/01/2020
@version   1
@param 01 - cFilAux    , caracter, código da filial para processamento
@param 02 - cIDRegistro, caracter, ID do registro na T4S
@param 03 - cComponente, caracter, codigo do componente
@param 04 - aPathOrig  , caracter, retorna por referencia os paths do registro
/*/
METHOD montaT4SPath(cFilAux, cIDRegistro, cComponente, aPathOrig) CLASS MrpDominio_Opcional

	Local cAliasTop    := GetNextAlias()
	Local cBanco       := TCGetDB()
	Local cConcatId    := ""
	Local cFilT4Q      := ""
	Local cFilT4S      := ""

	If Empty(cFilAux)
		cFilT4Q   := xFilial("T4Q")
		cFilT4S   := xFilial("T4S")
	Else
		cFilT4Q   := xFilial("T4Q", cFilAux)
		cFilT4S   := xFilial("T4S", cFilAux)
	EndIf

	cConcatId :=   " RTrim(T4S_FILIAL)|| ';'"
	cConcatId += "|| RTrim(T4S_PROD)  || ';'"
	cConcatId += "|| RTrim(T4S_SEQ)   || ';'"
	cConcatId += "|| RTrim(T4S_LOCAL) || ';'"
	cConcatId += "|| RTrim(T4S_OP)    || ';'"
	cConcatId += "|| RTrim(T4S_OPORIG)|| ';'"
	cConcatId += "|| T4S_DT "

	cQuery := " WITH MOUNTPATH(ULTIDREG, T4Q_PROD, T4S_PROD, T4S_OPORIG, T4S_QTD, T4S_QSUSP, "
	cQuery += "      T4S_SEQ, "
	cQuery +=      " ULTOP, T4Q_OP, ULTOPC, ULTPROD, CODE_PATH, NIVEL) "
	cQuery +=      " AS (SELECT " + cConcatId + " AS ULTIDREG, "
	cQuery +=                 " T4Q_PROD, "
	cQuery +=                 " T4S_PROD, "
	cQuery +=                 " T4S_OPORIG, "
	cQuery +=                 " T4S_QTD, "
	cQuery +=                 " T4S_QSUSP, "
	cQuery +=                 " T4S_SEQ, "
	cQuery +=                 " T4Q_OP                                 AS ULTOP, "
	cQuery +=                 " T4Q_OP, "
	cQuery +=                 " T4Q_ERPOPC                             AS ULTOPC, "
	cQuery +=                 " T4Q_PROD                               AS ULTPROD, "
	cQuery +=                 " Cast(Rtrim(T4Q_PROD) || '|' || Rtrim(T4S_PROD) || ';' "
	cQuery +=                      " || Rtrim(T4S_SEQ) AS VARCHAR(8000)) AS CODE_PATH, "
	cQuery +=                 " 1                                      AS NIVEL "
	cQuery +=          " FROM   " + RetSqlName( "T4Q" ) + " T4Q "
	cQuery +=                 " INNER JOIN " + RetSqlName( "T4S" ) + " T4S "
	cQuery +=                         " ON T4Q_OP = T4S_OP "
	cQuery +=          " WHERE  T4Q.D_E_L_E_T_ = ' ' "
	cQuery +=                 " AND T4S.D_E_L_E_T_ = ' ' "
	cQuery +=                 " AND T4Q.T4Q_OPPAI = ' ' "
	cQuery +=                 " AND T4Q.T4Q_FILIAL = '"+cFilT4Q+"' "
	cQuery +=                 " AND T4S.T4S_FILIAL = '"+cFilT4S+"' "
	cQuery +=          " UNION ALL "
	cQuery +=          " SELECT MOUNTPATH.ULTIDREG, "
	cQuery +=                 " T4QS.T4Q_PROD, "
	cQuery +=                 " T4QS.T4S_PROD, "
	cQuery +=                 " T4QS.T4S_OPORIG, "
	cQuery +=                 " T4QS.T4S_QTD, "
	cQuery +=                 " T4QS.T4S_QSUSP, "
	cQuery +=                 " T4QS.T4S_SEQ, "
	cQuery +=                 " T4QS.T4Q_OP                                       AS ULTOP, "
	cQuery +=                 " T4QS.T4Q_OP, "
	cQuery +=                 " MOUNTPATH.ULTOPC                                  AS ULTOPC, "
	cQuery +=                 " T4QS.T4Q_PROD                                     AS ULTPROD, "
	cQuery +=                 " Cast(Rtrim(CODE_PATH) || '|' || Rtrim(T4QS.T4S_PROD) "
	cQuery +=                      " || ';' || Rtrim(T4QS.T4S_SEQ) AS VARCHAR(8000)) AS CODE_PATH, "
	cQuery +=                 " MOUNTPATH.NIVEL + 1                               AS NIVEL "
	cQuery +=          " FROM   (SELECT T4Q_PROD, "
	cQuery +=                         " T4S_PROD, "
	cQuery +=                         " T4S_QTD, "
	cQuery +=                         " T4S_QSUSP, "
	cQuery +=                         " T4S_OPORIG, "
	cQuery +=                         cConcatId + " AS T4S_IDREG, "
	cQuery +=                         " T4S_SEQ, "
	cQuery +=                         " T4Q_OPPAI, "
	cQuery +=                         " T4Q_OP, "
	cQuery +=                         " T4Q_ERPOPC "
	cQuery +=                  " FROM   " + RetSqlName( "T4Q" ) + " T4Q "
	cQuery +=                         " INNER JOIN " + RetSqlName( "T4S" ) + " T4S "
	cQuery +=                                 " ON T4Q_OP = T4S_OP "
	cQuery +=                  " WHERE  T4Q.D_E_L_E_T_ = ' ' "
	cQuery +=                         " AND T4S.D_E_L_E_T_ = ' ' "
	cQuery +=                         " AND T4Q.T4Q_FILIAL = '"+cFilT4Q+"' "
	cQuery +=                         " AND T4S.T4S_FILIAL = '"+cFilT4S+"' ) [AS T4QS] "
	cQuery +=                 " INNER JOIN MOUNTPATH "
	cQuery +=                         " ON MOUNTPATH.T4S_OPORIG = T4QS.T4Q_OP) "
	cQuery += " SELECT CODE_PATH, "
	If !("|2|" $  ::oDados:oParametros["cDocumentType"])
		cQuery += " SUM(T4S_QTD - T4S_QSUSP) QTD "
	Else
		cQuery += " SUM(T4S_QTD) QTD "
	EndIf
	cQuery += " FROM   MOUNTPATH "
	cQuery +=        " INNER JOIN (SELECT ULTIDREG, "
	cQuery +=                           " Min(NIVEL) AS MINNIVEL "
	cQuery +=                    " FROM   MOUNTPATH "
	cQuery +=                    " WHERE  MOUNTPATH.ULTIDREG = '" + cIDRegistro + "'"
	cQuery +=                    " GROUP  BY MOUNTPATH.ULTIDREG) MINNIVEL "
	cQuery +=                " ON MINNIVEL.MINNIVEL = MOUNTPATH.NIVEL "
	cQuery +=                   " AND MINNIVEL.ULTIDREG = MOUNTPATH.ULTIDREG   "
	cQuery +=  " GROUP BY CODE_PATH  "

	//Realiza ajustes da Query para cada banco
	If cBanco == "POSTGRES"

		//Altera sintaxe da clausula WITH
		cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')

		//Corrige Falhas internas de Binário - POSTGRES
		cQuery := StrTran(cQuery, CHR(13), " ")
		cQuery := StrTran(cQuery, CHR(10), " ")
		cQuery := StrTran(cQuery, CHR(09), " ")

	ElseIf "MSSQL" $ cBanco
		//Substitui concatenação || por +
		cQuery := StrTran(cQuery, '||', '+')

	ElseIf cBanco != "ORACLE"
		//Substitui concatenação || por +
		cQuery := StrTran(cQuery, '||', '+')
	EndIf

	If cBanco == "ORACLE"
		cQuery := StrTran(cQuery,"VARCHAR(8000)","VARCHAR(4000)")
		cQuery := StrTran(cQuery,"[AS T4QS]","T4QS")
	Else
		cQuery := StrTran(cQuery,"[AS T4QS]","AS T4QS")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTop, .T., .T.)
	While !(cAliasTop)->(Eof())
		aAdd(aPathOrig, {AllTrim((cAliasTop)->CODE_PATH), (cAliasTop)->QTD})
		(cAliasTop)->(DbSkip())
	EndDo
	(cAliasTop)->(dbCloseArea())

Return

/*/{Protheus.doc} montaT4QPath
Monta Path da T4D e Identifica a string do Opcional Selecionada
@author    brunno.costa
@since     21/01/2020
@version   1
@param 01 - cFilAux    , caracter, codigo da filial para processamento
@param 02 - cIDRegistro, caracter, codigo do registro na T4Q
@param 03 - cOP        , caracter, codigo da OP
@param 04 - aPathOrig  , caracter, retorna por referencia os paths do registro
/*/
METHOD montaT4QPath(cFilAux, cIDRegistro, cOP, aPathOrig) CLASS MrpDominio_Opcional

	Local cAliasTop    := GetNextAlias()
	Local cBanco       := TCGetDB()
	Local cFilT4Q      := ""
	Local cFilT4S      := ""

	If Empty(cFilAux)
		cFilT4Q := xFilial("T4Q")
		cFilT4S := xFilial("T4S")
	Else
		cFilT4Q := xFilial("T4Q", cFilAux)
		cFilT4S := xFilial("T4S", cFilAux)
	EndIf

	cQuery := " WITH MOUNTPATH(ULTIDREG, T4Q_PROD, T4S_PROD, T4S_QTD, T4Q_QUANT, T4S_SEQ, ULTOP, "
	cQuery += "      T4Q_OP, T4S_OPORIG, ULTOPC, ULTPROD, CODE_PATH, NIVEL) "
	cQuery +=      " AS (SELECT T4Q_IDREG                              AS ULTIDREG, "
	cQuery +=                 " T4Q_PROD, "
	cQuery +=                 " T4S_PROD, "
	cQuery +=                 " T4Q_QUANT, "
	cQuery +=                 " T4Q_QUANT, "
	cQuery +=                 " T4S_SEQ, "
	cQuery +=                 " T4Q_OP                                 AS ULTOP, "
	cQuery +=                 " T4Q_OP, "
	cQuery +=                 " T4S_OPORIG, "
	cQuery +=                 " T4Q_ERPOPC                             AS ULTOPC, "
	cQuery +=                 " T4Q_PROD                               AS ULTPROD, "
	cQuery +=                 " Cast(Rtrim(T4Q_PROD) AS VARCHAR(8000)) AS CODE_PATH, "
	cQuery +=                 " 1                                      AS NIVEL "
	cQuery +=          " FROM   " + RetSqlName( "T4Q" ) + " T4Q "
	cQuery +=                 " INNER JOIN " + RetSqlName( "T4S" ) + " T4S "
	cQuery +=                         " ON T4Q_OP = T4S_OP "
	cQuery +=          " WHERE  T4Q.D_E_L_E_T_ = ' ' "
	cQuery +=                 " AND T4S.D_E_L_E_T_ = ' ' "
	cQuery +=                 " AND T4Q.T4Q_OPPAI = ' ' "
	cQuery +=                 " AND T4Q.T4Q_FILIAL = '"+cFilT4Q+"' "
	cQuery +=                 " AND T4S.T4S_FILIAL = '"+cFilT4S+"' "
	cQuery +=          " UNION ALL "
	cQuery +=          " SELECT T4QS.T4Q_IDREG, "
	cQuery +=                 " T4QS.T4Q_PROD, "
	cQuery +=                 " T4QS.T4S_PROD, "
	cQuery +=                 " MOUNTPATH.T4S_QTD, "
	cQuery +=                 " T4QS.T4Q_QUANT, "
	cQuery +=                 " T4QS.T4S_SEQ, "
	cQuery +=                 " T4QS.T4Q_OP                                       AS ULTOP, "
	cQuery +=                 " T4QS.T4Q_OP, "
	cQuery +=                 " T4QS.T4S_OPORIG, "
	cQuery +=                 " MOUNTPATH.ULTOPC                                  AS ULTOPC, "
	cQuery +=                 " T4QS.T4Q_PROD                                     AS ULTPROD, "
	cQuery +=                 " Cast(Rtrim(CODE_PATH) || '|' "
	cQuery +=                      " || Rtrim(MOUNTPATH.T4S_PROD) || ';' "
	cQuery +=                      " || Rtrim(MOUNTPATH.T4S_SEQ) AS VARCHAR(8000)) AS CODE_PATH, "
	cQuery +=                 " MOUNTPATH.NIVEL + 1                               AS NIVEL "
	cQuery +=          " FROM   (SELECT T4Q_PROD, "
	cQuery +=                         " T4S_PROD, "
	cQuery +=                         " T4S_QTD, "
	cQuery +=                         " T4S_IDREG, "
	cQuery +=                         " T4S_SEQ, "
	cQuery +=                         " T4Q_OPPAI, "
	cQuery +=                         " T4Q_OP, "
	cQuery +=                         " T4Q_ERPOPC, "
	cQuery +=                         " T4Q_IDREG, "
	cQuery +=                         " T4Q_QUANT, "
	cQuery +=                         " T4S_OPORIG "
	cQuery +=                  " FROM   " + RetSqlName( "T4Q" ) + " T4Q "
	cQuery +=                         " INNER JOIN " + RetSqlName( "T4S" ) + " T4S "
	cQuery +=                                 " ON T4Q_OP = T4S_OP "
	cQuery +=                  " WHERE  T4Q.D_E_L_E_T_ = ' ' "
	cQuery +=                         " AND T4S.D_E_L_E_T_ = ' ' "
	cQuery +=                         " AND T4Q_IDREG = '" + cIDRegistro + "' "
	cQuery +=                         " AND T4Q.T4Q_FILIAL = '"+cFilT4Q+"' "
	cQuery +=                         " AND T4S.T4S_FILIAL = '"+cFilT4S+"' ) [AS T4QS] "
	cQuery +=                 " INNER JOIN MOUNTPATH "
	cQuery +=                         " ON MOUNTPATH.T4S_OPORIG = T4QS.T4Q_OP) "
	cQuery += " SELECT DISTINCT CODE_PATH, "
	cQuery +=        " T4Q_QUANT "
	cQuery += " FROM   MOUNTPATH "
	cQuery +=        " INNER JOIN (SELECT ULTIDREG, "
	cQuery +=                           " Max(NIVEL) AS MAXNIVEL "
	cQuery +=                    " FROM   MOUNTPATH "
	cQuery +=                    " WHERE  MOUNTPATH.ULTIDREG = '" + cIDRegistro + "' "
	cQuery +=                    " GROUP  BY MOUNTPATH.ULTIDREG) MAXNIVEL "
	cQuery +=                " ON MAXNIVEL.MAXNIVEL = MOUNTPATH.NIVEL "
	cQuery +=                   " AND MAXNIVEL.ULTIDREG = MOUNTPATH.ULTIDREG  "

	//Realiza ajustes da Query para cada banco
	If cBanco == "POSTGRES"

		//Altera sintaxe da clausula WITH
		cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')

		//Medida paliativa banco POSTGRES. Banco suporta VarChar(8000), entretanto DbAccess com PostGres funciona em bases desatualizadas
		//cQuery := StrTran(cQuery,"VarChar(8000)","VarChar(255)")

		//Corrige Falhas internas de Binário - POSTGRES
		cQuery := StrTran(cQuery, CHR(13), " ")
		cQuery := StrTran(cQuery, CHR(10), " ")
		cQuery := StrTran(cQuery, CHR(09), " ")

	ElseIf cBanco == "MSSQL"
		//Substitui a função Trim
		cQuery := StrTran(cQuery, "Trim(", "RTrim(")
		//Substitui concatenação || por +
		cQuery := StrTran(cQuery, '||', '+')

	ElseIf cBanco != "ORACLE"
		//Substitui concatenação || por +
		cQuery := StrTran(cQuery, '||', '+')
	EndIf

	If cBanco == "ORACLE"
		cQuery := StrTran(cQuery,"VARCHAR(8000)","VARCHAR(4000)")
		cQuery := StrTran(cQuery,"[AS T4QS]","T4QS")
	Else
		cQuery := StrTran(cQuery,"[AS T4QS]","AS T4QS")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTop, .T., .T.)
	If !(cAliasTop)->(Eof())
		aAdd(aPathOrig, {AllTrim((cAliasTop)->CODE_PATH), (cAliasTop)->T4Q_QUANT})
		//(cAliasTop)->(DbSkip())
	EndIf
	(cAliasTop)->(dbCloseArea())

Return

/*/{Protheus.doc} registraDadosOpcDefault
Registra informações relacionadas ao opcional default de um produto.

@author    lucas.franca
@since     18/04/2022
@version   P12
@param 01 - cChaveProd, character, chave do produto sem o ID Opcional.
@param 02 - cIdOpc    , character, ID do opcional default do produto.
@param 03 - nQtdDisp  , Numeric  , Quantidade do saldo inicial do produto
@param 04 - nQtdES    , Numeric  , Quantidade de estoque de segurança
@param 05 - nQtdPP    , Numeric  , Quantidade de ponto de pedido
@return Nil
/*/
METHOD registraDadosOpcDefault(cChaveProd, cIdOpc, nQtdDisp, nQtdES, nQtdPP) CLASS MrpDominio_Opcional
	::oDados:oOpcionais:setItemAList("OPC_DEFAULT", cChaveProd, {cIdOpc, nQtdDisp, nQtdES, nQtdPP})
Return

/*/{Protheus.doc} separaIdChaveProduto
Separa o ID Opcional da chave do produto, e retorna as informações por referência

@author    lucas.franca
@since     04/05/2021
@version   P12
@param 01 - cChaveProd, character, chave do produto com o ID Opcional. Retorna por referência a chave do produto sem o ID Opcional.
@param 02 - cIdOpc    , character, ID do opcional removido da chave do produto. Retorna o valor separado por referência.
@return Nil
/*/
METHOD separaIdChaveProduto(cChaveProd, cIdOpc) CLASS MrpDominio_Opcional
	Local nPosSepara := AT("|", cChaveProd)

	cIdOpc := ""

	If nPosSepara > 0
		cIdOpc     := SubStr(cChaveProd, nPosSepara+1)
		cChaveProd := SubStr(cChaveProd, 1, nPosSepara-1)
	EndIf
Return

/*/{Protheus.doc} testPath
Verifica se o novo path é compativel com o path original para retornar o id intermediario do registo.
@type  Static Function
@author Lucas Fagundes
@since 31/08/2022
@version P12
@param 01 cNewPath , Caractere, Novo path do opcional.
@param 02 cPathOrig, Caractere, Path original que irá retornar o itermediario.
@param 03 lLastPath, Logico   , Indica que deve considerar o final do novo path.
@param 04 lCheckVal, Logico   , Indica que irá verificar o valor do opcional.
@return lRet, Logico, Indica se o novo path é compativel ou não com o original.
/*/
Static Function testPath(cNewPath, cPathOrig, lLastPath, lCheckVal)
	Local aDivPath := {}
	Local aDivOrig := {}
	Local cNewRight := ""
	Local cRight    := Right(cNewPath, Len(cPathOrig))
	Local lRet      := .F.
	Local nIndex    := 0
	Local nTotal    := 0
	Local nIniTrt := 0
	Local nLenPathOr := Len(cPathOrig)
	Local nIniRight := 0

	If lLastPath
		lRet := cRight == cPathOrig

		If !lRet
			cRight := Right(cNewPath, nLenPathOr + 1)
			lRet := cRight == cPathOrig + ";"
		EndIf

		If !lRet
			aDivPath  := STRTOKARR(cNewPath, "|")
			aDivOrig  := STRTOKARR(cPathOrig, "|")
			nTotal    := Len(aDivPath)
			nIniRight := nTotal - Len(aDivOrig) + 1

			If nIniRight > 0 .And. nTotal >= nIniRight
				// Remove o ; do primeiro item.
				nIniTrt := At(";", aDivPath[nIniRight])
				aDivPath[nIniRight] := SubStr(aDivPath[nIniRight], 1, nIniTrt - 1)

				// Monta o novo path com o primeiro elemento sem ;.
				For nIndex := nIniRight To nTotal
					cNewRight += aDivPath[nIndex] + Iif(nIndex != nTotal, "|", "")
				Next

				lRet := cNewRight == cPathOrig

				// Se for checar o valor do opcional, remove o TRT do final para ver se é o mesmo produto.
				If !lRet .And. lCheckVal
					nIniTrt := At(";", aDivPath[nTotal])
					aDivPath[nTotal] := SubStr(aDivPath[nTotal], 1, nIniTrt - 1)

					cNewRight := ""
					For nIndex := nIniRight To nTotal
						cNewRight += aDivPath[nIndex] + Iif(nIndex != nTotal, "|", "")
					Next

					lRet := cNewRight == cPathOrig
				EndIf
			EndIf
		EndIf
	Else
		lRet := "|" + AllTrim(cPathOrig) + "|" == "|" + AllTrim(cNewPath) + "|"
	EndIf

	aSize(aDivPath, 0)
	aSize(aDivOrig, 0)
Return lRet

/*/{Protheus.doc} salvaIntermediarios
Salva referência do json original a partir dos jsons de opcionais que ele contem.
@author Lucas Fagundes
@since 01/09/2022
@version P12
@param cJson, Caractere, Json que irá buscar os itermediarios e salvar a referência.
@return Nil
/*/
METHOD salvaIntermediarios(cJson) CLASS MrpDominio_Opcional
	Local cJsonInt := ""
	Local nIndOpc  := 0
	Local nTotOpc  := 0
	Local oJson    := JsonObject():New()
	Local lError := .F.
	Local cJsSalvo := ""

	If !Self:oDados:oOpcionais:existList("JSONINTS")
		Self:oDados:oOpcionais:createList("JSONINTS")
	EndIf

	oJson:fromJson(cJson)
	nTotOpc := Len(oJson["OPTIONAL"])
	For nIndOpc := 1 To nTotOpc
		cJsonInt := oJson["OPTIONAL"][nIndOpc]:toJson()
		cJsSalvo := Self:oDados:oOpcionais:getItemList("JSONINTS", cJsonInt, @lError, .F.)

		If lError .Or. Len(cJson) > Len(cJsSalvo)
			Self:oDados:oOpcionais:setItemList("JSONINTS", cJsonInt, cJson, @lError)
		EndIf

		oJson["OPTIONAL"][nIndOpc]["key"] := limpaChave(oJson["OPTIONAL"][nIndOpc]["key"])
		cJsonInt := oJson["OPTIONAL"][nIndOpc]:toJson()
		cJsSalvo := Self:oDados:oOpcionais:getItemList("JSONINTS", cJsonInt, @lError, .F.)

		If lError .Or. Len(cJson) > Len(cJsSalvo)
			Self:oDados:oOpcionais:setItemList("JSONINTS", cJsonInt, cJson, @lError)
		EndIf
	Next

	FwFreeObj(oJson)
	oJson := Nil
Return Nil

/*/{Protheus.doc} buscaPorItermediario
Busca pela referência do json mais completo com base nos intermediarios salvos.
@author Lucas Fagundes
@since 01/09/2022
@version P12
@param 01 cJson , Caractere, Json com os itermediarios que irá na busca.
@param 02 lError, Logico   , Retorna por referência a ocorência de erros.
@return cJsRet, Caractere, Json encontrado na busca pelos intermediarios.
/*/
METHOD buscaPorItermediario(cJson, lError) CLASS MrpDominio_Opcional
	Local cJsAux     := ""
	Local cJsAuxOrg  := ""
	Local cJsAuxInt  := ""
	Local cJsonInt   := ""
	Local cJsRet     := ""
	Local lEncontrou := .F.
	Local nIndOpc    := 0
	Local nIndOpcAux := 0
	Local nIndOpcOrg := 0
	Local nTotOpc    := 0
	Local nTotOpcAux := 0
	Local oJsAux     := JsonObject():New()
	Local oJson      := JsonObject():New()

	oJson:fromJson(cJson)
	nTotOpc := Len(oJson["OPTIONAL"])
	For nIndOpc := 1 To nTotOpc
		cJsonInt := oJson["OPTIONAL"][nIndOpc]:toJson()
		cJsAux := Self:oDados:oOpcionais:getItemList("JSONINTS", cJsonInt, @lError, .F.)

		// Se encontrou um json com esse opcional, pecorre o json encontrado para ver se todos os opcionais estão nele.
		If !lError .And. !Empty(cJsAux)
			oJsAux:fromJson(cJsAux)
			nTotOpcAux := Len(oJsAux["OPTIONAL"])

			For nIndOpcOrg := 1 To nTotOpc
				cJsAuxOrg := oJson["OPTIONAL"][nIndOpcOrg]:toJson()
				lEncontrou := .F.

				For nIndOpcAux := 1 To nTotOpcAux
					cJsAuxInt := oJsAux["OPTIONAL"][nIndOpcAux]:toJson()

					lEncontrou := cJsAuxInt == cJsAuxOrg

					If !lEncontrou
						oJsAux["OPTIONAL"][nIndOpcAux]["key"] := limpaChave(oJsAux["OPTIONAL"][nIndOpcAux]["key"])
						cJsAuxInt := oJsAux["OPTIONAL"][nIndOpcAux]:toJson()

						oJson["OPTIONAL"][nIndOpcOrg]["key"] := limpaChave(oJson["OPTIONAL"][nIndOpcOrg]["key"])
						cJsAuxOrg := oJson["OPTIONAL"][nIndOpcOrg]:toJson()

						lEncontrou := cJsAuxInt == cJsAuxOrg
					EndIf

					If lEncontrou
						Exit
					EndIf
				Next

				// Se um opcional não estiver dentro do json encontrado não verifica os outros.
				If !lEncontrou
					Exit
				EndIf
			Next

			// Se todos os opcionais estiverem dentro do json encontrado retorna o json encontrado.
			If lEncontrou
				cJsRet := Self:oDados:oOpcionais:getItemList("JSONORIG", cJsAux, @lError, .F.)
				Exit
			EndIf
		EndIf
	Next

	FwFreeObj(oJson)
	oJson := Nil
	FwFreeObj(oJsAux)
	oJsAux := Nil
Return cJsRet

/*/{Protheus.doc} limpaChave
Limpa a chave de um opcional removendo os pais e o trt.
@type  Static Function
@author Lucas Fagundes
@since 02/09/2022
@version P12
@param cChave, Caractere, Chave que será limpa.
@return cNewChv, Caractere, Chave do opcional sem os produtos pais e o trt.
/*/
Static Function limpaChave(cChave)
	Local aDivChv := STRTOKARR(cChave, "|")
	Local cNewChv := ""
	Local nIniTrt := 0
	Local nUltimo := Len(aDivChv)

	cNewChv := aDivChv[nUltimo]
	nIniTrt := At(";", cNewChv)
	If nIniTrt > 0
		cNewChv := SubStr(cNewChv, 1, nIniTrt - 1)
	EndIf

	aSize(aDivChv, 0)
Return cNewChv

/*/{Protheus.doc} setChaveId
Guarda o id e a chave json na global.
@author Lucas Fagundes
@since 21/10/2022
@version P12
@param 01 cChave, Caracter, Chave que será salvo os dados na global
@param 02 aDados, Array   , Array com os dados que irá salvar.
@return Nil
/*/
METHOD setChaveId(cChave, aDados) CLASS MrpDominio_Opcional
	Local oDados := ::oDados:oOpcionais
	Local nPos := 0
	Local aAux := {}

	If !oDados:existAList("CHAVES_ID_PROD")
		oDados:createAList("CHAVES_ID_PROD")
		oDados:setItemAList("CHAVES_ID_PROD", cChave, {aDados})
	Else
		aAux := oDados:getItemAList("CHAVES_ID_PROD", cChave)

		nPos := aScan(aAux, {|x| x[1] == aDados[1]})
		If nPos == 0
			aAdd(aAux, aClone(aDados))
		EndIf

		oDados:setItemAList("CHAVES_ID_PROD", cChave, aAux)
	EndIf

	aSize(aAux, 0)
Return Nil

/*/{Protheus.doc} getChaveId
Recupera os dados referente a id e chave json da global.
@author Lucas Fagundes
@since 21/10/2022
@version P12
@param cChave, Caracter, Chave da global que irá buscar os dados.
@return aDados, Array, Array com os dados salvos na chave da global.
/*/
METHOD getChaveId(cChave) CLASS MrpDominio_Opcional
	Local oDados := ::oDados:oOpcionais

Return oDados:getItemAList("CHAVES_ID_PROD", cChave)

/*/{Protheus.doc} validaOpcionalDefault
	(long_description)
	@author vivian.beatriz
	@since 01/11/2023
	@version P12
    @param cChaveCOmp, Caractere, Chave do opcional
    @return lIgual, lógico, Se as chaves são iguais
	/*/
Method validaOpcionalDefault(cChaveDef,cChaveComp) CLASS MrpDominio_Opcional

    Local aChaves    := {}
	Local aChavesDef := {}
    Local aProds     := {}
	Local cKey       := ""
    Local cNovaChave := ""
	Local cRepgopc   := ::oParametros["optionalAllLevels"]
    Local cValue     := ""
	Local cValueDef  := ""
    Local lIgual     := .F.
    Local nIndex     := 0
	Local nIndexDef  := 0
    Local nIndProd   := 0
    Local nIniTrt    := 0
    Local nTotal     := 0
	Local nTotalDef  := 0
	Local nTotProd   := 0
    Local oChave     := NIL
    Local oJsonComp  := NIL
	Local oJsonDef   := NIL

    lIgual := cChaveDef == cChaveComp

	IF !lIgual
		oJsonComp := JsonObject():New()
	   	oJsonComp:FromJson(cChaveComp)
	   	aChaves := oJsonComp["OPTIONAL"]
   		nTotal  := Len(aChaves)

   	    IF cRepgopc == 'N'
		    oJsonDef := JsonObject():New()
	   	    oJsonDef:FromJson(cChaveDef)
	   	    aChavesDef := oJsonDef["OPTIONAL"]
			nTotalDef  := Len(aChavesDef)

			For nIndexDef := 1 To nTotalDef
				oChaveDef := aChavesdef[nIndexDef]
				cValueDef := oChaveDef["value"]
				lIgual     := .F.

				For nIndex := 1 To nTotal
					oChave     := aChaves[nIndex]
					cValue     := oChave["value"]
					lIgual := cValueDef == cValue
                    If lIgual
						Exit
					EndIf
				Next

				If !lIgual
					Exit
				EndIf
            Next
			FwFreeObj(oJsonDef)
			aSize(aChavesDef,0)
 	   	Else

            For nIndex := 1 To nTotal
                cNovaChave := ""
                oChave     := aChaves[nIndex]
                cKey       := oChave["key"]
                aProds     := STRTOKARR(cKey, "|")

                nIniTrt := At(";", aProds[1])
                If nIniTrt > 0
                    aProds[1] := SubStr(aProds[1], 1, nIniTrt - 1)
                EndIf

                nTotProd := Len(aProds)
                For nIndProd := 1 To nTotProd
                    cNovaChave += aProds[nIndProd]

                    If nIndProd < nTotProd
                       cNovaChave += "|"
                    Endif
                Next

                oChave["key"] := cNovaChave
            Next

            oJsonComp["OPTIONAL"] := aChaves

            lIgual := cChaveDef == oJsonComp:ToJson()

		EndIf
		FwFreeObj(oJsonComp)
		aSize(aChaves,0)
	EndIf

return lIgual

