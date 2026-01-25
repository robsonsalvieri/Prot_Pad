#INCLUDE 'protheus.ch'
#INCLUDE 'MrpDados.ch'

Static sCRLF       := chr(13)+chr(10) //Quebra de linha

Static sPRD_NIVEST := 7
Static sPRD_CHAVE2 := 8

Static sEST_FILIAL := 1
Static sEST_CODPAI := 2
Static sEST_CODFIL := 3

Static sOPC_KEY      := 1
Static sOPC_KEY2     := 2

/*/{Protheus.doc} MrpData_Global
Manipulacao simplificada de registros globais
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
CLASS MrpData_Global FROM LongClassName

	//PROPRIEDADES locais
	DATA aCurrentRow AS ARRAY
	DATA cUIDSession AS STRING
	DATA cTabela     AS STRING
	DATA cGlobalKey  AS STRING
	DATA cCurrentKey AS STRING
	DATA cFilReg     AS STRING
	DATA nCurrentKey AS INTEGER
	DATA nIndice     AS INTEGER

	//Construtor da classe
	METHOD new(cGlobalKey, cTabela, lCreate)

	//Destrutor da classe
	METHOD destroy()

	//Controle de identificacao da chave atual - Propriedade local
	METHOD getnKeyCurrent()
	METHOD setnKeyCurrent(nKey)
	METHOD getcKeyCurrent()

	//Controle do array atual - Propriedade local
	METHOD getRowCurrent()
	METHOD setRowCurrent(aRow)

	//Controle de indexacao - Propriedade local
	METHOD getIndice()
	METHOD setIndice(nIndice)

	//Controle flag de carga - Propriedade local
	METHOD getFlag(cChave, lError, lLock)
	METHOD setFlag(cChave, oFlag, lError, lLock)
	METHOD delFlag(cChave, lError)
	METHOD cleanFlags()

	//Controle flag de resultados - Propriedade local
	METHOD getResult(cChave, lError, lLock)
	METHOD setResult(cChave, oFlag, lError, lLock)
	METHOD cleanResults()
	METHOD getAllRes()

	//Controle de listas - Propriedade local
	METHOD createList(cList, lCreate)
	METHOD existList(cList)
	METHOD getItemList(cList, cChave, lError, lLock)
	METHOD setItemList(cList, cChave, oFlag, lError, lLock)
	METHOD cleanList(cList)
	METHOD getAllList(cList, aTabela, lError)

	//Controle de matrizes - Propriedade local
	METHOD createAList(cList, lCreate)
	METHOD existAList(cList)
	METHOD getItemAList(cList, cChave, lError, lLock)
	METHOD setItemAList(cList, cChave, oFlag, lError, lLock, lSoma, nTipoSoma)
	METHOD cleanAList(cList)
	METHOD getAllAList(cList, aTabela, lError)
	METHOD delItemAList(cList, cChave, lError)

	//Controle de manipulacao do array - GLOBAL
	METHOD getAllRow(aTabela, lError)
	METHOD position(nPos, lError)
	METHOD getRow(nIndice, cKey, nPos, aReturn, lError, lLock)
	METHOD delRow(nIndice, cKey, lError)
	METHOD updRow(nIndice, cKey, nPos, aRow, lError, lLock)
	METHOD addRow(cKey, aRow, lError, lLock)
	METHOD cleanRows()

	//Controle de manipulacao dos totalizadores do array - GLOBAL
	METHOD getRowsNum(lError, lIdenta)
	METHOD incRowsNum(lError)
	METHOD setRowsNum(nRows, lError, lLock)

	//Controle de chaves das linhas do Array - GLOBAL
	METHOD getcKey(nIndice, nKey, lError, lLock)
	METHOD getnKey(nIndice, cKey, lError, lLock)
	METHOD getcKeys(nIndice, aKeys, lError, lLock)
	METHOD setKeys(nIndice, aKeys)
	METHOD updKey(nIndice, nKey, cKey, lError, lLock)
	METHOD addKey(nIndice, cKey, lError, lLock, cKeyNo1)
	METHOD cleanKeys()

	//Controle de reordenacao do Array - GLOBAL
	METHOD getlOrder(lError, lLock)
	METHOD setlOrder(lOrder, lError, lLock)
	METHOD order(nIndice, lError)
	METHOD updKeys(nIndice, oDados, lError)

	//Controle de lock de registros
	METHOD lock()
	METHOD unLock()
	METHOD trava()
	METHOD destrava()

	//Analise de Memoria
	METHOD analiseMemoria(lSplit)

ENDCLASS

/*/{Protheus.doc} new
Método construtor da classe MrpData_Global
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cGlobalKey, caracter, indica a chave de sessao global a ser utilizada
@param 02 - cTabela   , caracter, string que indica qual a tabela
@param 03 - lCreate   , logico  , indica se deve instanciar novos objetos globais
/*/
METHOD new(cGlobalKey, cTabela, lCreate) CLASS MrpData_Global

	Default cGlobalKey := "PCPXXX"
	Default lCreate    := .T.

	::cUIDSession := cGlobalKey + "UIDs_PCPMRP"

	cGlobalKey    := cGlobalKey + "_" + cTabela
	::cGlobalKey  := cGlobalKey
	::cTabela     := cTabela
	::cFilReg     := ""

	If lCreate

		//Limpa sessoes de variaveis globais
		Self:destroy()

		VarSetUID( cGlobalKey            , .T.)
		VarSetUID( cGlobalKey + "aRows"  , .T.)
		VarSetUID( cGlobalKey + "aKeys01", .T.)
		VarSetUID( cGlobalKey + "aKeys_rev01", .T.)
		VarSetUID( cGlobalKey + "aFlag"  , .T.)
		VarSetUID( cGlobalKey + "aResultados"  , .T.)

		//Protege limpeza de memória
		VarBeginT( ::cUIDSession, "UIDs_PCPMRP" )

		//Adiciona sessoes no controle de sessoes globais
		VarSetXD( ::cUIDSession, cGlobalKey, .T. )
		VarSetXD( ::cUIDSession, cGlobalKey + "aRows", .T. )
		VarSetXD( ::cUIDSession, cGlobalKey + "aKeys01", .T. )
		VarSetXD( ::cUIDSession, cGlobalKey + "aKeys_rev01", .T. )
		VarSetXD( ::cUIDSession, cGlobalKey + "aFlag", .T. )
		VarSetXD( ::cUIDSession, cGlobalKey + "aResultados", .T. )

		//Libera trecho de limpeza de memória
		VarEndT( ::cUIDSession, "UIDs_PCPMRP" )

		VarSetX( cGlobalKey, "nRows"      , 0  )
		VarSetX( cGlobalKey, "lOrder"     , .F.)
		::setFlag("flag", "N", Nil, .F.)
	EndIf
	::nCurrentKey := 0
	::cCurrentKey := ""
	::aCurrentRow := {}
	::nIndice     := 1

Return Self

/*/{Protheus.doc} destroy
Destrutor da classe
@author    brunno.costa
@since     25/04/2019
@version   1
/*/
METHOD destroy() CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey

	If VarIsUID( cGlobalKey )
		VarClean( cGlobalKey )
	EndIf

	If VarIsUID( cGlobalKey + "aRows" )
		VarClean( cGlobalKey + "aRows" )
	EndIf

	If VarIsUID( cGlobalKey + "aKeys01" )
		VarClean( cGlobalKey + "aKeys01" )
	EndIf

	If VarIsUID( cGlobalKey + "aKeys_rev01" )
		VarClean( cGlobalKey + "aKeys_rev01" )
	EndIf

	If VarIsUID( cGlobalKey + "aKeys_conv01" )
		VarClean( cGlobalKey + "aKeys_conv01" )
	EndIf

	If VarIsUID( cGlobalKey+ "aFlag" )
		VarClean( cGlobalKey + "aFlag")
	EndIf

	If VarIsUID( cGlobalKey + "aResultados" )
		VarClean( cGlobalKey + "aResultados")
	EndIf

Return

//************************************************//
//*** Controle de identificacao da chave atual ***//
//************************************************//

/*/{Protheus.doc} getnKeyCurrent
Retorna a posicao do registro na tabela: nCurrentKey
@author    brunno.costa
@since     25/04/2019
@version   1
@return nCurrentKey, numero, posicao do registro na tabela
/*/
METHOD getnKeyCurrent() CLASS MrpData_Global
Return ::nCurrentKey

/*/{Protheus.doc} setnKeyCurrent
Seta a posicao do registro na tabela
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nCurrentKey, numero, posicao do registro na tabela
/*/
METHOD setnKeyCurrent(nCurrentKey) CLASS MrpData_Global
Return ::nCurrentKey := nCurrentKey

/*/{Protheus.doc} getcKeyCurrent
Retorna a chave do registro na tabela
@author    brunno.costa
@since     25/04/2019
@version   1
@return cCurrentKey, caracter, chave do registro na tabela
/*/
METHOD getcKeyCurrent() CLASS MrpData_Global

	If ::cCurrentKey == Nil
		::cCurrentKey := ::getcKey(::nIndice, ::nCurrentKey)
	EndIf

Return ::cCurrentKey

//************************************************//
//*** Controle da linha atual da tabela **********//
//************************************************//

/*/{Protheus.doc} getRowCurrent
Retorna a linha atual do array
@author    brunno.costa
@since     25/04/2019
@version   1
@return aCurrentRow, array, array contendo os campos da linha atual da tabela
/*/
METHOD getRowCurrent() CLASS MrpData_Global
Return ::aCurrentRow

/*/{Protheus.doc} setRowCurrent
Seta a linha atual do array
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - aCurrentRow, array, array contendo os campos da linha atual da tabela
/*/
METHOD setRowCurrent(aCurrentRow) CLASS MrpData_Global
Return ::aCurrentRow := aCurrentRow

//************************************************//
//*** Controle de indexacao da tabela ************//
//************************************************//

/*/{Protheus.doc} getIndice
Retorna o indice atual da tabela
@author    brunno.costa
@since     25/04/2019
@version   1
@return nIndice, numero, indicador do indice atual da tabela
/*/
METHOD getIndice() CLASS MrpData_Global
Return ::nIndice

/*/{Protheus.doc} setIndice
Seta o indice atual da tabela
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nIndice, numero, indicador do indice atual da tabela
@return lSucesso, logico, indica se conseguiu realizar a operacao
/*/
METHOD setIndice(nIndice) CLASS MrpData_Global
Return ::nIndice := nIndice

//************************************************//
//*** Controle de Flags - Variaveis Isoladas *****//
//************************************************//

/*/{Protheus.doc} getFlag
Retorna o conteudo da variavel global
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cChave, caracter, chave da variavel/flag
@param 02 - lError, logico  , retorna por referencia ocorrencia de erro
@param 03 - lLock , logico  , indica se utiliza transacao com lock ou sem VarGetX ou VarGetXD
@return oFlag, (numero / caracter / logico / data), conteudo da flag
/*/
METHOD getFlag(cChave, lError, lLock) CLASS MrpData_Global
	Local oFlag
	Local cGlobalKey := ::cGlobalKey
	Default lLock := .F.
	Default cChave := "flag"
	Default lError  := .F.
	If lLock
		lError := !VarGetX ( cGlobalKey + "aFlag", cChave, @oFlag )
	Else
		lError := !VarGetXD( cGlobalKey + "aFlag", cChave, @oFlag )
	EndIf
Return oFlag

/*/{Protheus.doc} setFlag
Seta o conteudo da variavel global
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cChave, caracter, chave da variavel/flag
@param 02 - oFlag , (numero / caracter / logico / data), conteudo da flag
@param 03 - lError, logico  , retorna por referencia ocorrencia de erro
@param 04 - lLock , logico  , indica se utiliza transacao com lock ou sem VarSetX ou VarSetXD
@param 05 - lSoma , logico  , indica se incrementa o valor do registro (ou concatena em caso de string)
@param 06 - lInc  , lógico  , indica se realiza o incremento atômico +1
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD setFlag(cChave, oFlag, lError, lLock, lSoma, lInc) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local oOld
	Default lError := .F.
	Default cChave := "flag"
	Default lLock  := .F.
	Default lSoma  := .F.
	Default lInc   := .F.

	If lInc
		lError := !VarSetX(cGlobalKey + "aFlag", cChave, @oFlag, 1, 1)
	Else
		If lSoma
			::lock("flag" + cChave)
			oOld   := ::getFlag(cChave, @lError, lLock)
			If !lError .AND. oOld != Nil
				oFlag  := oOld + oFlag
			Else
				lError := .F.
			EndIf
			lError := !VarSetX ( cGlobalKey + "aFlag", cChave , oFlag )
			::unLock("flag" + cChave)
		Else
			If lLock
				lError := !VarSetX ( cGlobalKey + "aFlag", cChave , oFlag )
			Else
				lError := !VarSetXD( cGlobalKey + "aFlag", cChave , oFlag )
			EndIf
		EndIf
	EndIf
Return (!lError)

/*/{Protheus.doc} delFlag
Seta o conteudo da variavel global
@author    brunno.costa
@since     17/12/2019
@version   1
@param 01 - cChave, caracter, chave da variavel/flag
@param 02 - lError, logico  , retorna por referencia ocorrencia de erro
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD delFlag(cChave, lError) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Default lError := .F.
	Default cChave := "flag"

	lError := !VarDelX(cGlobalKey + "aFlag", cChave)

Return (!lError)

/*/{Protheus.doc} cleanFlags
Limpa todas as flags da sessao
@author    brunno.costa
@since     25/04/2019
@version   1
@return lSucesso, logico, Indica se conseguiu remover todos os valores das chaves da sessao
/*/
METHOD cleanFlags() CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local lRet       := .T.

	If VarIsUID( cGlobalKey + "aFlag" )
		lRet := VarCleanX( cGlobalKey + "aFlag" )
	EndIf

Return lRet

//************************************************//
//*** Controla lista de resultados           *****//
//************************************************//

/*/{Protheus.doc} getResult
Retorna o conteudo de uma chave da lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cChave, caracter, chave da variavel/flag
@param 02 - lError, logico  , retorna por referencia ocorrencia de erro
@param 03 - lLock , logico  , indica se utiliza transacao com lock ou sem VarGetX ou VarGetXD
@return oFlag, (numero / caracter / logico / data), conteudo da flag
/*/
METHOD getResult(cChave, lError, lLock) CLASS MrpData_Global
	Local oFlag
	Local cGlobalKey := ::cGlobalKey
	Default lLock := .F.
	Default cChave := "result"
	Default lError  := .F.
	If lLock
		lError := !VarGetX ( cGlobalKey + "aResultados", cChave, @oFlag )
	Else
		lError := !VarGetXD( cGlobalKey + "aResultados", cChave, @oFlag )
	EndIf
Return oFlag

/*/{Protheus.doc} setResult
Seta o conteudo de uma chave da lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cChave, caracter, chave da variavel/flag
@param 02 - oFlag , (numero / caracter / logico / data), conteudo da flag
@param 03 - lError, logico  , retorna por referencia ocorrencia de erro
@param 04 - lLock , logico  , indica se utiliza transacao com lock ou sem VarSetX ou VarSetXD
@param 05 - lSoma , logico  , indica se incrementa o valor do registro (ou concatena em caso de string)
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD setResult(cChave, oFlag, lError, lLock, lSoma) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local oOld       := 0
	Default lError := .F.
	Default cChave := "result"
	Default lLock  := .F.

	If lSoma
		::lock("aResultados" + cChave)
		VarGetX ( cGlobalKey + "aResultados", cChave , @oOld )
		If !lError .AND. oOld != Nil
			oFlag  := oOld + oFlag
		Else
			lError := .F.
			oFlag  := 1 //Uso concatenacao falhas
		EndIf
		lError := !VarSetX ( cGlobalKey + "aResultados", cChave , oFlag )
		::unLock("aResultados" + cChave)
	Else
		If lLock
			lError := !VarSetX ( cGlobalKey + "aResultados", cChave , oFlag )
		Else
			lError := !VarSetXD( cGlobalKey + "aResultados", cChave , oFlag )
		EndIf
	EndIf

Return (!lError)

/*/{Protheus.doc} cleanResults
Limpa a lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@return lSucesso, logico, Indica se conseguiu remover todos os valores das chaves da sessao
/*/
METHOD cleanResults() CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local lRet       := .T.

	If VarIsUID( cGlobalKey + "aResultados" )
		lRet := VarCleanX( cGlobalKey + "aResultados" )
	EndIf

Return lRet

/*/{Protheus.doc} getAllRes
Retorna todos os resultados da lista
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - aTabela, array   , retorna por referencia os resultados no array
@param 02 - lError , logico  , retorna por referencia ocorrencia de erro
@return aTabela, array, retorna todos os resultados da lista
/*/
METHOD getAllRes(aTabela, lError) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Default lError := .F.
	Default aTabela := {}
	lError := !VarGetXA( cGlobalKey + "aResultados", @aTabela)
Return aTabela

//************************************************//
//*** Controla listas especificas cList      *****//
//************************************************//

/*/{Protheus.doc} createList
Retorna o conteudo de uma chave da lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cList  , caracter, indica o nome da lista
@param 02 - lCreate, logico  , indica se deve instanciar novos objetos globais
@return lRet, logico, indica se conseguiu criar a lista
/*/
METHOD createList(cList, lCreate) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local lRet       := .T.
	Default lCreate := .T.
	If lCreate
		lRet := VarSetUID( cGlobalKey + cList  , .T.)
		If lRet
			VarSetXD( ::cUIDSession, cGlobalKey + cList, .T. )
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} existList
Verifica se existe a lista
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cList, caracter, indica o nome da lista
@return lRet, logico, indica se a lista existe
/*/
METHOD existList(cList) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
Return VarIsUID( cGlobalKey + cList )

/*/{Protheus.doc} getItemList
Retorna o conteudo de uma chave da lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cChave, caracter, chave da variavel/flag
@param 02 - lError, logico  , retorna por referencia ocorrencia de erro
@param 03 - lLock , logico  , indica se utiliza transacao com lock ou sem VarGetX ou VarGetXD
@return oFlag, (numero / caracter / logico / data), conteudo da flag
/*/
METHOD getItemList(cList, cChave, lError, lLock) CLASS MrpData_Global
	Local oFlag
	Local cGlobalKey := ::cGlobalKey
	Default lLock := .F.
	Default cChave := "result"
	Default lError  := .F.
	If lLock
		lError := !VarGetX ( cGlobalKey + cList, cChave, @oFlag )
	Else
		lError := !VarGetXD( cGlobalKey + cList, cChave, @oFlag )
	EndIf
Return oFlag

/*/{Protheus.doc} setResult
Seta o conteudo de uma chave da lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cChave, caracter, chave da variavel/flag
@param 02 - oFlag , (numero / caracter / logico / data), conteudo da flag
@param 03 - lError, logico  , retorna por referencia ocorrencia de erro
@param 04 - lLock , logico  , indica se utiliza transacao com lock ou sem VarSetX ou VarSetXD
@param 05 - lSoma , logico  , indica se incrementa o valor do registro (ou concatena em caso de string)
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD setItemList(cList, cChave, oFlag, lError, lLock, lSoma) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local oOld       := 0
	Default lError := .F.
	Default cChave := "result"
	Default lLock  := .F.
	Default lSoma  := .F.
	If lSoma
		::lock(cList + cChave)
		VarGetX ( cGlobalKey + cList, cChave , @oOld )
		If !lError .AND. oOld != Nil
			oFlag  := oOld + oFlag
		Else
			lError := .F.
			oFlag  := 1 //Uso concatenacao falhas
		EndIf
		lError := !VarSetX ( cGlobalKey + cList, cChave , oFlag )
		::unLock(cList + cChave)
	Else
		If lLock
			lError := !VarSetX ( cGlobalKey + cList, cChave , oFlag )
		Else
			lError := !VarSetXD( cGlobalKey + cList, cChave , oFlag )
		EndIf
	EndIf

Return (!lError)

/*/{Protheus.doc} cleanList
Limpa a lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@return lSucesso, logico, Indica se conseguiu remover todos os valores das chaves da sessao
/*/
METHOD cleanList(cList) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local lRet       := .T.

	If VarIsUID( cGlobalKey + cList )
		lRet := VarCleanX( cGlobalKey + cList )
	EndIf

Return lRet

/*/{Protheus.doc} getAllList
Retorna todos os resultados da lista
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - aTabela, array   , retorna por referencia os resultados no array
@param 02 - lError , logico  , retorna por referencia ocorrencia de erro
@return aTabela, array, retorna todos os resultados da lista
/*/
METHOD getAllList(cList, aTabela, lError) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Default lError := .F.
	Default aTabela := {}
	lError := !VarGetXA( cGlobalKey + cList, @aTabela)
Return aTabela


//************************************************//
//*** Controle de manipulacao do array       *****//
//************************************************//

//************************************************//
//*** Controla listas especificas cList      *****//
//************************************************//

/*/{Protheus.doc} createAList
Retorna o conteudo de uma chave da lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cList  , caracter, indica o nome da lista
@param 02 - lCreate, logico  , indica se deve instanciar novos objetos globais
@return lRet, logico, indica se conseguiu criar a lista
/*/
METHOD createAList(cList, lCreate) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local lRet       := .T.
	Default lCreate := .T.
	If lCreate
		lRet := VarSetUID( cGlobalKey + cList  , .T.)
		If lRet
			VarSetXD( ::cUIDSession, cGlobalKey + cList, .T. )
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} existList
Verifica se existe a lista
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cList, caracter, indica o nome da lista
@return lRet, logico, indica se a lista existe
/*/
METHOD existAList(cList) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
Return VarIsUID( cGlobalKey + cList )

/*/{Protheus.doc} getItemList
Retorna o conteudo de uma chave da lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cChave, caracter, chave da variavel/flag
@param 02 - lError, logico  , retorna por referencia ocorrencia de erro
@param 03 - lLock , logico  , indica se utiliza transacao com lock ou sem VarGetX ou VarGetXD
@return oFlag, (numero / caracter / logico / data), conteudo da flag
/*/
METHOD getItemAList(cList, cChave, lError, lLock) CLASS MrpData_Global
	Local oFlag
	Local cGlobalKey := ::cGlobalKey
	Default lLock := .F.
	Default cChave := "result"
	Default lError  := .F.
	If lLock
		lError := !VarGetA ( cGlobalKey + cList, cChave, @oFlag )
	Else
		lError := !VarGetAD( cGlobalKey + cList, cChave, @oFlag )
	EndIf
Return oFlag

/*/{Protheus.doc} setItemAList
Seta o conteudo de uma chave da lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cChave   , caracter, chave da variavel/flag
@param 02 - oFlag    , (numero / caracter / logico / data), conteudo da flag
@param 03 - lError   , logico  , retorna por referencia ocorrencia de erro
@param 04 - lLock    , logico  , indica se utiliza transacao com lock ou sem VarSetX ou VarSetXD
@param 05 - lSoma    , logico  , indica se incrementa o valor do registro (ou concatena em caso de string)
@param 06 - nTipoSoma, caracter, Indica o tipo de soma usada (lSoma).
                                 1 = Apenas adiciona o valor de oFlag na global. Ex: aAdd(global, oFlag)
                                 2 = Adiciona na global os elementos de oFlag de forma separada. Ex: aAdd(global, oFlag[1]), aAdd(global, oFlag[2])
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD setItemAList(cList, cChave, oFlag, lError, lLock, lSoma, nTipoSoma) CLASS MrpData_Global

	Default cChave    := "result"
	Default lError    := .F.
	Default lLock     := .F.
	Default lSoma     := .F.
	Default nTipoSoma := 1

	If lSoma
		//Adiciona um novo elemento em uma lista sem precisar recuperar a lista completa
		lError := !VarSetA( ::cGlobalKey + cList, cChave , {}, nTipoSoma, @oFlag )
	Else
		If lLock
			lError := !VarSetA( ::cGlobalKey + cList, cChave , oFlag )
		Else
			lError := !VarSetAD( ::cGlobalKey + cList, cChave , oFlag )
		EndIf
	EndIf
Return !lError

/*/{Protheus.doc} delItemAList
Deleta o conteudo de uma chave da lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cList , caracter, identificador da sessão de variáveis globais
@param 02 - cChave, caracter, chave da variavel/flag
@param 03 - lError, logico  , retorna por referencia ocorrencia de erro
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD delItemAList(cList, cChave, lError) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Default lError := .F.
	Default cChave := "result"

	lError := !VarDelA( cGlobalKey + cList, cChave )

Return (!lError)

/*/{Protheus.doc} cleanList
Limpa a lista de resultados
@author    brunno.costa
@since     25/04/2019
@version   1
@return lSucesso, logico, Indica se conseguiu remover todos os valores das chaves da sessao
/*/
METHOD cleanAList(cList) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local lRet       := .T.

	If VarIsUID( cGlobalKey + cList )
		lRet := VarCleanA( cGlobalKey + cList )
	EndIf

Return lRet

/*/{Protheus.doc} getAllAList
Retorna todos os resultados da lista
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - aTabela, array   , retorna por referencia os resultados no array
@param 02 - lError , logico  , retorna por referencia ocorrencia de erro
@return aTabela, array, retorna todos os resultados da lista
/*/
METHOD getAllAList(cList, aTabela, lError) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Default lError := .F.
	Default aTabela := {}
	lError := !VarGetAA( cGlobalKey + cList, @aTabela)
Return aTabela


//************************************************//
//*** Controle de manipulacao do array       *****//
//************************************************//

/*/{Protheus.doc} getAllRow
Retorna todos as linhas da tabela principal do objeto (matriz linhas x colunas)
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - aTabela, array   , retorna por referencia os resultados no array
@param 02 - lError , logico  , retorna por referencia ocorrencia de erro
@return aTabela, array, retorna todos os resultados da lista
/*/
METHOD getAllRow(aTabela, lError) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Default lError := .F.
	Default aTabela := {}
	lError := !VarGetAA( cGlobalKey + "aRows", @aTabela)
	If !lError
		::setRowsNum(Len(aTabela), @lError, .F.)
	EndIf

Return aTabela

/*/{Protheus.doc} position
Posiciona a tabela no registro especifico
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nPos   , numero  , indice da tabela para posicionamento
@param 02 - lError , logico  , retorna por referencia ocorrencia de erro
@return aReturn, array, linha com os dados da posicao
/*/
METHOD position(nPos, lError) CLASS MrpData_Global
	Local aReturn := {}
	::getRow(1, Nil, nPos, @aReturn, @lError, .F.)
Return aReturn

/*/{Protheus.doc} getRow
Retorna linha da tabela referente dados para posicionamento
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nIndice, numero  , indice da tabela para posicionamento
@param 02 - cKey   , caracter, chave do registro no indice nIndice
@param 03 - nPos   , numero  , posicao da tabela para posicionamento
@param 04 - aReturn, array   , retorna por referencia a linha com os resultados
@param 05 - lError , logico  , retorna por referencia ocorrencia de erro
@param 06 - lLock  , logico  , indica se utiliza transacao com lock ou sem VarGetA ou VarGetAD
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD getRow(nIndice, cKey, nPos, aReturn, lError, lLock) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local cIndice
	Local cAux
	Local cKeyBackup := ""

	Default lError := .F.
	Default cKey    := IIf(nPos == ::nCurrentKey, ::cCurrentKey, "")
	Default nPos    := IIf(cKey == ::cCurrentKey, ::nCurrentKey, 0)
	Default lLock   := .F.
	Default aReturn := {}

	If Empty(cKey) .and. nPos == 0
		lError := .T.
	Else
		If Empty(cKey)
			cIndice  := PadL(cValToChar(nIndice), 2, '0')
			cKey     := ::getcKey(cIndice, nPos, @lError, lLock)
		EndIf
		If Empty(cKey) .OR. cKey == Nil
			lError := .T.
		EndIf
		If !lError .AND. nIndice != Nil .and. nIndice != 1 .and. nIndice != 0
			cIndice    := PadL(cValToChar(nIndice), 2, '0')
			If lLock
				lError := !VarGetX ( cGlobalKey + "aKeys_conv" + cIndice, cKey , @cAux )
			Else
				lError := !VarGetXD( cGlobalKey + "aKeys_conv" + cIndice, cKey , @cAux )
			EndIf
			cKeyBackup := cKey
			cKey       := cAux
		EndIf
		If !lError
			If lLock
				lError := !VarGetA ( cGlobalKey + "aRows", cKey , @aReturn )
			Else
				lError := !VarGetAD( cGlobalKey + "aRows", cKey , @aReturn )
			EndIf
			If !Empty(cKeyBackup)
				cKey := cKeyBackup
			EndIf
		EndIf
	EndIf

	::aCurrentRow := aReturn
	::nCurrentKey := nPos
	::cCurrentKey := cKey

Return (!lError)


/*/{Protheus.doc} delRow
Deleta linha da tabela referente dados para posicionamento
@author    brunno.costa
@since     15/08/2019
@version   1
@param 01 - nIndice, numero  , indice da tabela para posicionamento
@param 02 - cKey   , caracter, chave do registro no indice nIndice
@param 03 - lError , logico  , retorna por referencia ocorrencia de erro
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD delRow(nIndice, cKey, lError) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local cIndice
	Local cAux

	Default lError := .F.
	Default cKey    := ""
	Default lLock   := .F.

	If Empty(cKey)
		lError := .T.
	Else
		If !lError .AND. nIndice != Nil .and. nIndice != 1 .and. nIndice != 0
			cIndice    := PadL(cValToChar(nIndice), 2, '0')
			If lLock
				lError := !VarGetX ( cGlobalKey + "aKeys_conv" + cIndice, cKey , @cAux )
			Else
				lError := !VarGetXD( cGlobalKey + "aKeys_conv" + cIndice, cKey , @cAux )
			EndIf
			cKey := cAux
		EndIf
		If !lError
			lError := !VarDelA( cGlobalKey + "aRows", cKey)
		EndIf
	EndIf

Return (!lError)

/*/{Protheus.doc} updRow
Atualiza linha da tabela referente dados para posicionamento
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nIndice, numero  , indice da tabela para posicionamento
@param 02 - cKey   , caracter, chave do registro no indice nIndice
@param 03 - nPos   , numero  , posicao da tabela para posicionamento
@param 04 - aRow   , array   , array com os dados da linha para gravacao
@param 05 - lError , logico  , retorna por referencia ocorrencia de erro
@param 06 - lLock  , logico  , indica se utiliza transacao com lock ou sem VarSetA ou VarSetAD
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD updRow(nIndice, cKey, nPos, aRow, lError, lLock, nTentativas) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local cAux       := ""
	Local cKeyBackup := cKey
	Local nKeyBackup := nPos

	Default lError      := .F.
	Default cKey        := IIf(nPos == ::nCurrentKey, ::cCurrentKey, "")
	Default nPos        := IIf(cKey == ::cCurrentKey, ::nCurrentKey, 0)
	Default lLock       := .F.
	Default nTentativas := 1

	If Empty(cKey) .and. nPos == 0
		lError := .T.
	Else
		If Empty(cKey)
			cKey := ::getcKey(nIndice, nPos, @lError, lLock)
		EndIf
		If !lError .AND. nIndice != Nil .and. nIndice != 1 .and. nIndice != 0
			cIndice    := PadL(cValToChar(nIndice), 2, '0')
			If lLock
				lError := !VarGetX ( cGlobalKey + "aKeys_conv" + cIndice, cKey , @cAux )
			Else
				lError := !VarGetXD( cGlobalKey + "aKeys_conv" + cIndice, cKey , @cAux )
			EndIf
			cKeyBackup := cKey
			nKeyBackup := nPos
			cKey       := cAux
			nIndice    := 1
		EndIf

		If !lError
			If lLock
				lError := !VarSetA ( cGlobalKey + "aRows", cKey , aRow )
			Else
				lError := !VarSetAD( cGlobalKey + "aRows", cKey , aRow )
			EndIf
		EndIf
	EndIf

	::aCurrentRow := aRow
	If Empty(cKeyBackup)
		::cCurrentKey := cKey
	Else
		::cCurrentKey := cKeyBackup
	EndIf
	If nKeyBackup != Nil
		::nCurrentKey := nPos
	Else
		::nCurrentKey := nKeyBackup
	EndIf

Return (!lError)

/*/{Protheus.doc} addRow
Adiciona linha da tabela referente dados para posicionamento
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cKey     , caracter, chave do registro no indice primario
@param 02 - aRow     , array   , array com os dados da linha para gravacao
@param 03 - lError   , logico  , retorna por referencia ocorrencia de erro
@param 04 - lLock    , logico  , indica se utiliza transacao com lock ou sem VarSetA ou VarSetAD
@param 05 - cKeyNo1  , caracter, chave do registro no indice atual da tabela ::nIndice - propriedade da tabela
@param 06 - cProdMRP , caracter, codigo do produto no MRP, utilizado pontualmente para chave
                                "cExistMAT_" que identifica se o produto existe na matriz do MRP
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD addRow(cKey, aRow, lError, lLock, cKeyNo1, cProdMRP) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local nIndice    := ::nIndice
	Local nPos       := 0

	Local lErrAux   := .F.

	Default cKey    := ""
	Default lError  := .F.
	Default lLock   := .F.
	Default cProdMRP    := ""

	nIndice := Iif(nIndice == 0 .or. nIndice == Nil, 1, nIndice)

	If Empty(cKey) .or. Empty(aRow)
		lError := .T.
	Else
		If !lErrAux
			If lLock
				lError := !VarSetA ( cGlobalKey + "aRows", cKey , aRow )
			Else
				lError := !VarSetAD( cGlobalKey + "aRows", cKey , aRow )
			EndIf
		Else
			lError := .T.
		EndIf
	EndIf

	If !lError
		::addKey(nIndice, cKey, @lError, lLock, cKeyNo1)
	EndIf

	If !lError .and. !Empty(cProdMRP)
		::setFlag("cExistMAT_" + cProdMRP, .T., .F., .F.) //Sem lock pois esta protegido com o AddRow
	EndIf

	::aCurrentRow := aRow
	::nCurrentKey := nPos
	::cCurrentKey := cKey

Return (!lError)

/*/{Protheus.doc} cleanRows
Limpa a tabela
@author    brunno.costa
@since     25/04/2019
@version   1
@return lSucesso, logico, Indica se conseguiu remover todos os valores das chaves da sessao
/*/
METHOD cleanRows() CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local lRet       := .T.

	::aCurrentRow := {}
	While !::setRowsNum(0, Nil, .F.)
	EndDo

	If VarIsUID( cGlobalKey + "aRows" )
		lRet := VarCleanA( cGlobalKey + "aRows" )
	EndIf

Return lRet

//*************************************************************//
//*** Controle de manipulacao dos totalizadores do array ******//
//*************************************************************//

/*/{Protheus.doc} getRowsNum
Retorna a quantidade de linhas da tabela
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - lError , logico  , retorna por referencia ocorrencia de erro
@param 02 - lIdenta, logico  , indica se identa (soma 1) ao retornar
@return nRows, numero, numero de linhas da tabela
/*/
METHOD getRowsNum(lError, lIdenta) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local nRows     := 0
	Default lError  := .F.
	Default lIdenta := .F.
	If lIdenta
		lError := !VarSetX ( cGlobalKey, "nRows", @nRows, 1, 1 )
	Else
		lError := !VarGetX ( cGlobalKey, "nRows", @nRows )
	EndIf
Return nRows

/*/{Protheus.doc} incRowsNum
Incrementa o totalizador
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - lError , logico  , retorna por referencia ocorrencia de erro
@return nRows, numero, numero de linhas da tabela
/*/
METHOD incRowsNum(lError) CLASS MrpData_Global
Return ::getRowsNum(lError, .T.)

/*/{Protheus.doc} incRowsNum
Seta o total de registros da tabela
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nRows , numero  , quantidade de registros da tabela
@param 02 - lError, logico  , retorna por referencia ocorrencia de erro
@param 03 - lLock , logico  , indica se utiliza transacao com lock ou sem VarSetX ou VarSetXD
@return nRows, numero, numero de linhas da tabela
/*/
METHOD setRowsNum(nRows, lError, lLock) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Default lLock := .F.
	Default lError := .F.
	If lLock
		lError := !VarSetX ( cGlobalKey, "nRows" , nRows )
	Else
		lError := !VarSetXD( cGlobalKey, "nRows" , nRows )
	EndIf
Return (!lError)


//************************************************//
//*** Controle de Chave das Linhas do Array ******//
//************************************************//

/*/{Protheus.doc} getcKeys
Retorna todas as chaves desta tabela
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nIndice, numero  , quantidade de registros da tabela
@param 02 - aKeys  , array   , retorna por referencia todas as chaves da tabela
@param 03 - lError , logico  , retorna por referencia ocorrencia de erro
@param 04 - lLock  , logico  , indica se utiliza transacao com lock ou sem VarGetX ou VarGetXD
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD getcKeys(nIndice, aKeys, lError, lLock) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local cIndice
	Default nIndice := 1
	Default lError := .F.
	cIndice := PadL(cValToChar(nIndice), 2, '0')
	lError  := !VarGetAA( cGlobalKey + "aKeys" + cIndice, @aKeys)
Return (!lError)

/*/{Protheus.doc} getcKey
Retorna a chave referente posicao no indice
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nIndice, numero  , indice da tabela que deseja receber a chave
@param 02 - nKey   , numero  , posicao do registro
@param 03 - lError , logico  , retorna por referencia ocorrencia de erro
@param 04 - lLock  , logico  , indica se utiliza transacao com lock ou sem VarGetX ou VarGetXD
@return cKey, caracter, chave do registro posicionado (nKey) no indice "nIndice"
/*/
METHOD getcKey(nIndice, nKey, lError, lLock) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local cKey
	Default nIndice := Iif(::nIndice == Nil, 1, ::nIndice)
	Default lError := .F.

	cIndice := PadL(cValToChar(nIndice), 2, '0')

	If nKey == 0
		lError := .T.
	Else
		If lLock
			lError := !VarGetX ( cGlobalKey + "aKeys" + cIndice, PadL(cValToChar(nKey), 10, '0') , @cKey )
		Else
			lError := !VarGetXD( cGlobalKey + "aKeys" + cIndice, PadL(cValToChar(nKey), 10, '0') , @cKey )
		EndIf
	EndIf

Return cKey

/*/{Protheus.doc} getnKey
Retorna a posicao do registro com base na chave e indice
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nIndice, numero  , indice da tabela que deseja receber a chave
@param 02 - cKey   , caracter, chave do registro
@param 03 - lError , logico  , retorna por referencia ocorrencia de erro
@param 04 - lLock  , logico  , indica se utiliza transacao com lock ou sem VarGetX ou VarGetXD
@return nKey, numero, posicao do registro
/*/
METHOD getnKey(nIndice, cKey, lError, lLock) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local nKey
	Default nIndice := Iif(::nIndice == Nil, 1, ::nIndice)
	Default lError := .F.

	cIndice := PadL(cValToChar(nIndice), 2, '0')

	If nKey == 0
		lError := .T.
	Else
		If lLock
			lError := !VarGetX ( cGlobalKey + "aKeys_rev" + cIndice, cKey , @nKey )
		Else
			lError := !VarGetXD( cGlobalKey + "aKeys_rev" + cIndice, cKey , @nKey )
		EndIf
	EndIf

Return nKey

/*/{Protheus.doc} updKey
Seta a chave e posicao do registro
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nIndice, numero  , indice da tabela que deseja receber a chave
@param 02 - nKey   , numero  , posicao do registro
@param 03 - cKey   , caracter, chave do registro
@param 04 - lError , logico  , retorna por referencia ocorrencia de erro
@param 05 - lLock  , logico  , indica se utiliza transacao com lock ou sem VarSetX ou VarSetXD
@param 06 - cKey1  , caracter, chave do registro na posicao 1, quando nIndice != 1
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD updKey(nIndice, nKey, cKey, lError, lLock, cKey1) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local cIndice

	Default nIndice := 1
	Default nKey    := 0
	Default cKey    := ""
	Default lLock   := .F.
	Default lError := .F.

	cIndice := PadL(cValToChar(nIndice), 2, '0')

	If !VarIsUID( cGlobalKey + "aKeys"     + cIndice )
		VarSetUID( cGlobalKey + "aKeys"     + cIndice, .T.)
		VarSetXD( ::cUIDSession, cGlobalKey + "aKeys"     + cIndice, .T. )
	EndIf

	If !VarIsUID( cGlobalKey + "aKeys_rev"     + cIndice )
		VarSetUID( cGlobalKey + "aKeys_rev"     + cIndice, .T.)
		VarSetXD( ::cUIDSession, cGlobalKey + "aKeys_rev"     + cIndice, .T. )
	EndIf

	If !VarIsUID( cGlobalKey + "aKeys_conv"     + cIndice )
		VarSetUID( cGlobalKey + "aKeys_conv"     + cIndice, .T.)
		VarSetXD( ::cUIDSession, cGlobalKey + "aKeys_conv"     + cIndice, .T. )
	EndIf

	If Empty(cKey)
		lError := .T.
	Else
		If lLock
			lError := !VarSetX ( cGlobalKey + "aKeys"     + cIndice, PadL(cValToChar(nKey), 10, '0') , cKey )
			lError := !VarSetX ( cGlobalKey + "aKeys_rev" + cIndice, cKey                            , nKey )
			If nIndice != 1
				lError := !VarSetX ( cGlobalKey + "aKeys_conv" + cIndice, cKey                       , cKey1 )
			EndIf
		Else
			lError := !VarSetXD( cGlobalKey + "aKeys"     + cIndice, PadL(cValToChar(nKey), 10, '0') , cKey )
			lError := !VarSetXD( cGlobalKey + "aKeys_rev" + cIndice, cKey                            , nKey )
			If nIndice != 1
				lError := !VarSetX ( cGlobalKey + "aKeys_conv" + cIndice, cKey                        , cKey1 )
			EndIf
		EndIf
	EndIf

Return (!lError)

/*/{Protheus.doc} addKey
Adiciona nova chave de registro
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nIndice, numero  , indice da tabela que deseja receber a chave
@param 03 - cKey   , caracter, chave do registro primaria
@param 04 - lError , logico  , retorna por referencia ocorrencia de erro
@param 05 - lLock  , logico  , indica se utiliza transacao com lock ou sem VarSetX ou VarSetXD
@param 06 - cKeyNo1, caracter, chave do registro referente nIndice
@param 07 - nKey   , numero  , retorno por referencia da posicao adicionada
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD addKey(nIndice, cKey, lError, lLock, cKeyNo1, nKey) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local cIndice

	Default nIndice := 1
	Default cKey    := ""
	Default lLock   := .F.
	Default lError  := .F.
	Default cKeyNo1 := ""

	nKey    := ::incRowsNum(@lError, lLock)
	cIndice := PadL(cValToChar(nIndice), 2, '0')

	If Empty(cKey)
		lError := .T.
	Else
		If lLock
			lError := !VarSetX ( cGlobalKey + "aKeys"     + cIndice, PadL(cValToChar(nKey), 10, '0') , cKey )
			lError := !VarSetX ( cGlobalKey + "aKeys_rev" + cIndice, cKey                            , nKey )
			If nIndice != 1 .and. !Empty(cKeyNo1)
				lError := !VarSetX ( cGlobalKey + "aKeys_conv" + cIndice, cKey                       , cKeyNo1 )
			EndIf
		Else
			lError := !VarSetXD( cGlobalKey + "aKeys"     + cIndice, PadL(cValToChar(nKey), 10, '0') , cKey )
			lError := !VarSetXD( cGlobalKey + "aKeys_rev" + cIndice, cKey                            , nKey )
			If nIndice != 1 .and. !Empty(cKeyNo1)
				lError := !VarSetX ( cGlobalKey + "aKeys_conv" + cIndice, cKey                       , cKeyNo1 )
			EndIf
		EndIf
		::setlOrder(.T., Nil, lLock)
	EndIf

Return (!lError)

/*/{Protheus.doc} cleanKeys
Limpa as chaves da tabela
@author    brunno.costa
@since     25/04/2019
@version   1
@return lSucesso, logico, Indica se conseguiu remover todos os valores das chaves da sessao
/*/
METHOD cleanKeys(nIndice, lError) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local cIndice := PadL(cValToChar(nIndice), 2, '0')

	Default lError := .F.

	If !lError
		lError := !VarCleanX( cGlobalKey + "aKeys"     + cIndice )
	EndIf

	If !lError
		lError := !VarCleanX( cGlobalKey + "aKeys_rev" + cIndice )
	EndIf

Return lError

//************************************************//
//*** Controle de reordenacao do Array      ******//
//************************************************//

/*/{Protheus.doc} getlOrder
Indica se a tabela esta ordenada
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - lError , logico  , retorna por referencia ocorrencia de erro
@param 02 - lLock  , logico  , indica se utiliza transacao com lock ou sem VarGetX ou VarGetXD
@return lOrder, logico, indica se a tabela esta ordenada
/*/
METHOD getlOrder(lError, lLock) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Local lOrder
	Default lLock  := .F.
	Default lError := .F.
	If lLock
		lError := !VarGetX ( cGlobalKey, "lOrder", @lOrder )
	Else
		lError := !VarGetXD( cGlobalKey, "lOrder", @lOrder )
	EndIf
Return lOrder

/*/{Protheus.doc} getlOrder
Registra se a tabela esta ordenada
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - lOrder , logico  , indicador se a tabela esta ordenada
@param 02 - lError , logico  , retorna por referencia ocorrencia de erro
@param 03 - lLock  , logico  , indica se utiliza transacao com lock ou sem VarSetX ou VarSetXD
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD setlOrder(lOrder, lError, lLock) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey
	Default lLock := .F.
	Default lError := .F.
	If VarIsUID(cGlobalKey)
		If lLock
			lError := !VarSetX ( cGlobalKey, "lOrder" , lOrder )
		Else
			lError := !VarSetXD( cGlobalKey, "lOrder" , lOrder )
		EndIf
	EndIf
Return (!lError)

/*/{Protheus.doc} order
Ordena a tabela
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nIndice, numero, indica o indice em que a tabela deve ser ordenada
@param 02 - lError , logico, retorna por referencia ocorrencia de erro
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD order(nIndice, lError) CLASS MrpData_Global

	Local aTabela   := {}
	Local lTrava    := .F.

	::setlOrder(.F., .F., lTrava)
	::setIndice(nIndice)
	::getAllRow(@aTabela, @lError)

	If nIndice == 1
		aTabela := aSort(aTabela, , , {|x,y| "|"+x[1]+"|" < "|"+y[1]+"|" })

	ElseIf nIndice == 2 .and. ::cTabela == "PRD"
		aTabela := aSort(aTabela, , , {|x,y| "|"+x[2][sPRD_CHAVE2]+"|" < "|"+y[2][sPRD_CHAVE2]+"|" })

		//Atualiza também as chaves do índice 1 de produtos.
		::updKeys(1, aTabela, .F.)
	EndIf

	::updKeys(nIndice, aTabela, .T.)

Return lError

/*/{Protheus.doc} updKeys
Atualiza posicoes das chaves no indice
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - nIndice, numero, indica o indice para atualizacao das chaves
@param 02 - aTabela, array , array com os dados da tabela
@return lSucesso, logico, indica se obteve sucesso na operacao
/*/
METHOD updKeys(nIndice, aTabela, lLimpaTab) CLASS MrpData_Global

	Local lTrava      := .F.
	Local nIndAux
	Local cNivelAnt   := ""
	Local nItensTab   := Len(aTabela)

	Default lLimpaTab := .T.

	If nItensTab > 0
		If nIndice == 1
			::cleanKeys(nIndice, Nil)
			For nIndAux := 1  to nItensTab
				::updKey(1, nIndAux, aTabela[nIndAux][1], .F., lTrava)
			Next nIndAux

		ElseIf nIndice == 2
			If ::cTabela == "PRD"
				For nIndAux := 1  to nItensTab
					If aTabela[nIndAux][2][sPRD_NIVEST] != cNivelAnt //Tabela de Produtos
						cNivelAnt := aTabela[nIndAux][2][sPRD_NIVEST]
						::setflag("cPriNivel" + cNivelAnt, Right(aTabela[nIndAux][2][sPRD_CHAVE2], Len(aTabela[nIndAux][2][sPRD_CHAVE2]) - 2), .F., .F.)
					EndIf
					::updKey(2, nIndAux, aTabela[nIndAux][2][sPRD_CHAVE2], .F., lTrava, aTabela[nIndAux][1])

				Next nIndAux

			ElseIf ::cTabela == "OPC"
				For nIndAux := 1  to nItensTab
					::updKey(2, nIndAux, aTabela[nIndAux][2][sOPC_KEY2], .F., lTrava, aTabela[nIndAux][1])

				Next nIndAux
			EndIf

		EndIf

		If lLimpaTab
			aTabela := Nil
		EndIf
	EndIf

Return

//************************************************//
//*** Controle de lock de registros         ******//
//************************************************//

/*/{Protheus.doc} lock
Trava a chave global nesta sessao
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cChave, caracter, chave a ser travada
@return lSucesso, logico, Indica se conseguiu iniciar a transação na chave <cChave> da sessão
/*/
METHOD lock(cChave) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey

Return VarBeginT( cGlobalKey, cChave )

/*/{Protheus.doc} unLock
Destrava a chave global nesta sessao
@author    brunno.costa
@since     25/04/2019
@version   1
@param 01 - cChave, caracter, chave a ser destravada
@return lSucesso, logico, Indica se conseguiu finalizar a transação na chave <cChave> da sessão
/*/
METHOD unLock(cChave) CLASS MrpData_Global
	Local cGlobalKey := ::cGlobalKey

Return VarEndT( cGlobalKey, cChave )

//Repeticao do metodo traduzida para evitar falhas de codificacao
METHOD trava(cChave) CLASS MrpData_Global
Return ::lock(cChave)

//Repeticao do metodo traduzida para evitar falhas de codificacao
METHOD destrava(cChave) CLASS MrpData_Global
Return ::unLock(cChave)

//Método para análise do consumo de memória das classes MrpData_Global
METHOD analiseMemoria(lSplit, cTitulo) CLASS MrpData_Global
	Local aX          := {}
	Local aA          := {}
	Local nInd        := 0
	Local aSessoes    := {}
	Local oJObject    := JsonObject():New()
	Local oJTotal     := JsonObject():New()
	Local cChave      := ""
	Local nIndIT      := 0
	Local cPrefixo    := ""
	Local aNames      := {}
	Local lSepTabXA   := .F.

	Default lSplit  := .T. //Quebra os dados das tabelas pelos tipos
	Default cTitulo := ""

	LogMsg('MRPLOG-MEMORY', 0, 0, 1, '', '', cTitulo)

	//Elimina residuos de variaveis globais
	If VarIsUID(::cUIDSession)
		VarGetXA( ::cUIDSession, @aSessoes)
		aSessoes := aSort(aSessoes)
		For nInd := 1 to Len(aSessoes)

			VarPrint(aSessoes[nInd][1], @aX, @aA, lSplit)

			DO CASE
			CASE "indice1" $ aSessoes[nInd][1]
				cChave := "_indice1_"
				cPrefixo := ""

			CASE "indice2" $ aSessoes[nInd][1]
				cChave := "_indice2_"
				cPrefixo := ""

			CASE "indice3" $ aSessoes[nInd][1]
				cChave := "_indice3_"
				cPrefixo := ""

			CASE "RASTREIO" $ aSessoes[nInd][1]
				cChave := "_RASTREIO_"
				cPrefixo := ""

			CASE "RASTREIO_IDS" $ aSessoes[nInd][1]
				cChave := "_RASTREIO_IDS_"
				cPrefixo := ""

			CASE "_MAT" $ aSessoes[nInd][1]
				cChave := "_MATRIZ_"
				cPrefixo := ""

			CASE "_ALT" $ aSessoes[nInd][1]
				cChave := "_TABELAS_ALTERNATIVO_"
				cPrefixo := ""

			CASE "PRODUTO" $ aSessoes[nInd][1]
				cChave := "_TABELAS_POR_PRODUTO_"
				cPrefixo := ""

			CASE "_PRD" $ aSessoes[nInd][1]
				cChave := "_TABELAS_PRODUTOS_"
				cPrefixo := ""

			CASE "_EST" $ aSessoes[nInd][1]
				cChave := "_TABELAS_ESTRUTURAS_"
				cPrefixo := ""

			CASE "_LIVELOCK" $ aSessoes[nInd][1]
				cChave := "_LIVELOCK_"
				cPrefixo := ""

			CASE "_OPC" $ aSessoes[nInd][1]
				cChave := "_TABELAS_OPCIONAIS_"
				cPrefixo := ""

			CASE "_CAL" $ aSessoes[nInd][1]
				cChave := "_TABELAS_CALENDARIOS_"
				cPrefixo := ""

			CASE "_PEN" $ aSessoes[nInd][1]
				cChave := "_TABELAS_PENDENCIAS_"
				cPrefixo := ""

			CASE "_TAB*VDP_" $ aSessoes[nInd][1]
				cChave := "_TABELAS_VERSAO_DA_PRODUCAO_"
				cPrefixo := ""

			OTHERWISE
				cChave   := AllTrim(aSessoes[nInd][1])
				cPrefixo := "_GERAL_"

			ENDCASE

			If Empty(cChave)
				VarInfo("Tabela Global X uID '" + aSessoes[nInd][1] + "':", aX)
				VarInfo("Tabela Global A uID '" + aSessoes[nInd][1] + "':", aA)
			Else
				For nIndIT := 1 to Len(aX)
					If oJObject[cChave + cPrefixo + Iif(lSepTabXA, "_AX", "") ] == Nil
						oJObject[cChave + cPrefixo + Iif(lSepTabXA, "_AX", "")] := {aX[nIndIT][2], aX[nIndIT][3], 1}
					Else
						oJObject[cChave + cPrefixo + Iif(lSepTabXA, "_AX", "")][1] += aX[nIndIT][2]
						oJObject[cChave + cPrefixo + Iif(lSepTabXA, "_AX", "")][2] += aX[nIndIT][3]
						oJObject[cChave + cPrefixo + Iif(lSepTabXA, "_AX", "")][3] ++

					EndIf
				Next

				For nIndIT := 1 to Len(aA)
					If oJObject[cChave + cPrefixo + Iif(lSepTabXA, "_AA", "") ] == Nil
						oJObject[cChave + cPrefixo + Iif(lSepTabXA, "_AA", "")] := {aA[nIndIT][2], aA[nIndIT][3], 1}
					Else
						oJObject[cChave + cPrefixo + Iif(lSepTabXA, "_AA", "")][1] += aA[nIndIT][2]
						oJObject[cChave + cPrefixo + Iif(lSepTabXA, "_AA", "")][2] += aA[nIndIT][3]
						oJObject[cChave + cPrefixo + Iif(lSepTabXA, "_AA", "")][3] ++

					EndIf
				Next

				//TOTALIZADOR
				For nIndIT := 1 to Len(aX)
					If oJTotal["TOTAL"] == Nil
						oJTotal["TOTAL"] := {aX[nIndIT][2], aX[nIndIT][3], 1}
					Else
						oJTotal["TOTAL"][1] += aX[nIndIT][2]
						oJTotal["TOTAL"][2] += aX[nIndIT][3]
						oJTotal["TOTAL"][3] ++

					EndIf
				Next

				For nIndIT := 1 to Len(aA)
					If oJTotal["TOTAL"] == Nil
						oJTotal["TOTAL"] := {aA[nIndIT][2], aA[nIndIT][3], 1}
					Else
						oJTotal["TOTAL"][1] += aA[nIndIT][2]
						oJTotal["TOTAL"][2] += aA[nIndIT][3]
						oJTotal["TOTAL"][3] ++

					EndIf
				Next
			EndIf

			aSize(aX, 0)
			aSize(aA, 0)

		Next nInd

		aNames := oJObject:GetNames()
		For nIndIT := 1 to Len(aNames)
			VarInfo("Tabela Global AGLUTINADA em JSON '" + aNames[nIndIT] + "':", oJObject[aNames[nIndIT]])
		Next

		aNames := oJTotal:GetNames()
		For nIndIT := 1 to Len(aNames)
			VarInfo("Tabela Global TOTALIZADOR em JSON '" + aNames[nIndIT] + "':", oJTotal[aNames[nIndIT]])
		Next
	EndIf

Return
