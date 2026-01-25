#INCLUDE "TOTVS.CH"
#INCLUDE "MRPTRIGGER.CH"

#DEFINE FIELDS_PROPERTY_POS_TYPE    1
#DEFINE FIELDS_PROPERTY_POS_SIZE    2
#DEFINE FIELDS_PROPERTY_POS_DECIMAL 3
#DEFINE FIELDS_PROPERTY_ARRAY_SIZE  3

#DEFINE ASPAS '"'

/*/{Protheus.doc} MRPTrigger
Classe para controlar as TRIGGERS que serão necessárias para o envio de dados ao MRP.

@type  CLASS
@author lucas.franca
@since 30/07/2019
@version P12.1.28
@example
	oTrigger := MRPTrigger():New()
	oTrigger:configureTable("SVR", "MRPDEMANDS", {"VR_FILIAL","VR_PROD"}, {"VR_FILIAL","VR_CODIGO","VR_SEQUEN"}, .T.)

	//Verificar se a trigger está instalada.
	If oTrigger:isTriggerInstalled()
		//Trigger está instalada.
	EndIf

	//Verificar se a trigger está atualizada
	If oTrigger:isTriggerUpdated()
		//Trigger está atualizada.
	EndIf

	//Desinstalar a trigger.
	If oTrigger:uninstallTrigger()
		//Trigger desinstalada.
	Else
		//Erro.
		Conout(oTrigger:getError())
	EndIf

	//Instalar a trigger.
	If oTrigger:installTrigger()
		//Trigger instalada.
	Else
		//Erro.
		Conout(oTrigger:getError())
	EndIf

	//Limpar os dados para verificar a trigger de outra tabela.
	oTrigger:clear()

	//Seta os novos parâmetros;
	oTrigger:configureTable(cAlias, cApiCode, aFields, aFieldsID, lCriaDados)

	//todos os métodos anteriores disponíveis para a nova configuração.

	//Destruir o objeto.
	oTrigger:Destroy()
	FreeObj(oTrigger)
/*/
CLASS MRPTrigger FROM LongClassName
	DATA aFields      AS Array
	DATA aFieldsID    AS Array
	DATA aFieldsNC    AS Array
	DATA aFieldsPai   AS Array
	DATA aFieldsUpd   AS Array
	Data aRelpai      AS Array
	DATA cAlias       AS Character
	DATA cApiCode     AS Character
	DATA cBanco       AS Character
	DATA cError       AS Character
	DATA cFilGrv      AS Character
	DATA cSqlTrigger  AS Character
	DATA cTabela      AS Character
	DATA cTabelaPai   AS Character
	DATA cTriggerName AS Character
	Data lCanDelete   As Logic
	DATA lCriaDados   AS Logic
	DATA lExistHWJ    AS Logic
	DATA lExistT4R    AS Logic
	DATA lNetChange   AS Logic
	DATA lOnlyIns     AS Logic
	DATA lReady       AS Logic
	DATA lVldData     AS Logic
	DATA oFieldsProp  AS Object
	DATA oFldPropPai  AS Object

	//Método construtor
	Method New() CONSTRUCTOR

	//Métodos internos de processamento.
	Method createSqlTrigger()
	Method initFields()
	Method MSSQLTrigger()
	Method ORACLETrigger()
	Method POSTGRESTrigger()
	Method concatKey(cPrefix)
	Method montaDelete(cOperacao)
	Method montaUpdate(cOperacao)
	Method montaInsert(cOperacao)
	Method montaDELInsert(cOperacao)
	Method SQLconcatDados(cPrefix)
	Method iniFldPai()
	Method insertHWJ(cOperacao)

	//Métodos externos
	Method installTrigger()
	Method uninstallTrigger()
	Method isTriggerUpdated()
	Method isTriggerInstalled()
	Method clear()
	Method configureTable(cAlias, cApiCode, aFields, aFieldsID, lCriaDados, cTabelaPai, aFieldsPai, aRelPai, lCanDelete, aFieldsNC, aFieldsUpd, lVldData)

	//Métodos de retorno de informações
	Method getSqlTrigger()
	Method getError()

	//Métod destrutor
	Method Destroy()
ENDCLASS

/*/{Protheus.doc} New
Método construtor da classe MRPTrigger

@author lucas.franca
@since 30/07/2019
@version P12.1.28
@return Self     , Object   , Referência da classe MRPTrigger
/*/
METHOD New() Class MRPTrigger
	Self:cBanco    := TCGetDB()
	If Self:cBanco == "MSSQL7"
		Self:cBanco := "MSSQL"
	EndIf
	Self:lReady     := .F.
	Self:lExistT4R  := FWAliasInDic("T4R",.F.)
	Self:lExistHWJ  := FWAliasInDic("HWJ",.F.)
	Self:lNetChange := .F.

	If FWAliasInDic("HWL",.F.)
		dbSelectArea('HWL')
		HWL->(dbSetOrder(1))
		IF HWL->( dbSeek( xFilial("HWL") + "1" ) )
			If HWL->HWL_NETCH == "1"
				Self:lNetChange := .T.
			EndIf
		EndIf
	EndIf

Return Self

/*/{Protheus.doc} Destroy
Método destrutor da classe MRPTrigger

@author lucas.franca
@since 30/07/2019
@version P12.1.28
@return Nil
/*/
METHOD Destroy() Class MRPTrigger
	Self:cBanco := ""

	Self:clear()
Return Nil

/*/{Protheus.doc} clear
Limpa as variáveis para reutilização do objeto.

@author lucas.franca
@since 02/08/2019
@version P12.1.28
@return Nil
/*/
Method clear() Class MRPTrigger
	Self:aFields      := {}
	Self:aFieldsID    := {}
	Self:cAlias       := ""
	Self:cApiCode     := ""
	Self:cError       := ""
	Self:cFilGrv      := ""
	Self:cTabela      := ""
	Self:cTriggerName := ""
	Self:cSqlTrigger  := ""
	Self:lCriaDados   := .T.
	Self:lReady       := .F.
	Self:lVldData     := .F.
	Self:lOnlyIns     := .F.
	Self:cTabelaPai   := ""
	Self:aFieldsPai   := {}
	Self:aRelpai      := {}

	If Self:oFieldsProp != Nil
		FreeObj(Self:oFieldsProp)
		Self:oFieldsProp := Nil
	EndIf

	If Self:oFldPropPai != Nil
		FreeObj(Self:oFldPropPai)
		Self:oFldPropPai := Nil
	EndIf
Return Nil

/*/{Protheus.doc} configureTable
Definição dos parâmetros de configuração para criação da trigger.

@author lucas.franca
@since 30/07/2019
@version P12.1.28
@param 01 cAlias    , Character, Alias da tabela onde será instalada a trigger
@param 02 cApiCode  , Character, Código da API correspondente do MRP
@param 03 aFields   , Array    , Array com os campos da tabela onde será instalada a trigger que devem ser salvos na tabela T4R.
@param 04 aFieldsID , Array    , Array com os campos que compõem a formação do T4R_IDREG.
@param 05 lCriaDados, Logic    , Indica se deverá ser criada a informação no campo T4R_DADOS.
@param 06 cTabelaPai, Character, Alias da tabela pai (com a qual será feita a chave).
@param 07 aFieldsPai, Array    , Array com os campos da tabela usados para montar a chave
@param 08 aRelPai   , Array    , Array de relações que deverão ser consideradas no Join entre a tabela da trigger e a tabela pai
@param 09 lCanDelete, Logic    , Define se a trigger criada pode inserir registros do tipo 2 (exclusão), *triggers do tipo #child não podem inserir tipo 2 na T4R
@param 10 aFieldsNC , Array    , Array com os campos que de filial e produto que atualizarão a HWJ.
@param 11 aFieldsUpd, Array    , Array com os campos que serão gatilho para atualização da tabela HWJ.
@param 12 lVldData  , Logic    , Indica que a trigger deve validar os dados alterados antes de gerar a pendência. Somente gera pendência se for alterado algum dos campos de aFields.
@param 13 lOnlyIns  , Logic    , Indica que a trigger irá ser criada sempre fazendo apenas a inclusão do registro na tabela T4R, caso não exista.
@return lReady      , Logic    , Indica se a tabela foi configurada com sucesso.
/*/
Method configureTable(cAlias, cApiCode, aFields, aFieldsID, lCriaDados, cTabelaPai, aFieldsPai, aRelPai, lCanDelete, aFieldsNC, aFieldsUpd, lVldData, lOnlyIns) Class MRPTrigger

	Default lCanDelete := .T.
	Default aFieldsNC  := {}
	Default aFieldsUpd := {}
	Default lVldData   := .F.
	Default lOnlyIns   := .F.

	Self:aFields    := aFields
	Self:aFieldsID  := aFieldsID
	Self:aFieldsNC  := aFieldsNC
	Self:aFieldsUpd := aFieldsUpd
	Self:cAlias     := cAlias
	Self:cApiCode   := cApiCode
	Self:lCriaDados := lCriaDados
	Self:lReady     := .F.
	Self:cTabelaPai := cTabelaPai
	Self:aFieldsPai := aFieldsPai
	Self:aRelPai	:= aRelPai
	Self:lCanDelete := lCanDelete
	Self:lVldData   := lVldData
	Self:lOnlyIns   := lOnlyIns

	If !Self:lExistT4R
		Self:cError := STR0003 + " 'T4R' " + STR0004 //"Tabela 'T4R' não existe no dicionário de dados.
	ElseIf !FWAliasInDic(cAlias,.F.)
		Self:cError := STR0003 + " '" + cAlias + "' " + STR0004 //"Tabela 'XXX' não existe no dicionário de dados.
	ElseIf Self:lVldData .And. Empty(Self:aFields)
		Self:cError := STR0006 + " '" + cAlias + "'. " + STR0007 //"Configuração inválida para " 'tabela'. "Não possui campos definidos."
	Else
		//Carrega informações úteis para o processamento.
		Self:cFilGrv := xFilial(cAlias)
		Self:cTabela := RetSqlName(cAlias)
		Self:cError  := ""

		//Monta o nome que será utilizado para a Trigger
		Self:cTriggerName := Self:cTabela + "_SCHEDULE_MRP"

		//Alimenta objeto auxiliar com as propriedades dos campos.
		If Self:initFields()
			//Monta o comando SQL de criação da Trigger.
			Self:cSqlTrigger := Self:createSqlTrigger()

			//Variável para identificar que o método de Configuração foi executado.
			Self:lReady := .T.
		EndIf
	EndIf
Return Self:lReady

/*/{Protheus.doc} initFields
Cria o objeto com as propriedades dos campos utilizados no processo.

@author lucas.franca
@since 30/07/2019
@version P12.1.28
@return lStatus, Logic, Identifica se todos os campos são válidos.
/*/
METHOD initFields() Class MRPTrigger
	Local lStatus := .T.
	Local nIndex  := 0
	Local nTotal  := Len(Self:aFields)

	Self:oFieldsProp := JsonObject():New()

	For nIndex := 1 To nTotal
		Self:oFieldsProp[Self:aFields[nIndex]] := Array(FIELDS_PROPERTY_ARRAY_SIZE)
		If Self:aFields[nIndex] == "R_E_C_N_O_"
			Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_TYPE]    := "N"
			Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_SIZE]    := 10
			Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_DECIMAL] := 0
		Else
			Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_TYPE]    := GetSx3Cache(Self:aFields[nIndex], "X3_TIPO")
			Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_SIZE]    := GetSx3Cache(Self:aFields[nIndex], "X3_TAMANHO")
			Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_DECIMAL] := GetSx3Cache(Self:aFields[nIndex], "X3_DECIMAL")
			If Empty(Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_TYPE])
				lStatus := .F.
				Self:cError := STR0005 + " '" + Self:aFields[nIndex] + "' " + STR0004 //"Coluna 'XXXX' não existe no dicionário de dados.
				Exit
			EndIf
		EndIf
	Next nIndex

	If lStatus
		nTotal := Len(Self:aFieldsID)
		For nIndex := 1 To nTotal
			If Self:oFieldsProp[Self:aFieldsID[nIndex]] == Nil
				Self:oFieldsProp[Self:aFieldsID[nIndex]] := Array(FIELDS_PROPERTY_ARRAY_SIZE)
				If Self:aFieldsID[nIndex] == "R_E_C_N_O_"
					Self:oFieldsProp[Self:aFieldsID[nIndex]][FIELDS_PROPERTY_POS_TYPE] := "N"
					Self:oFieldsProp[Self:aFieldsID[nIndex]][FIELDS_PROPERTY_POS_SIZE] := 10
					Self:oFieldsProp[Self:aFieldsID[nIndex]][FIELDS_PROPERTY_POS_DECIMAL] := 0
				Else
					Self:oFieldsProp[Self:aFieldsID[nIndex]][FIELDS_PROPERTY_POS_TYPE] := GetSx3Cache(Self:aFieldsID[nIndex], "X3_TIPO")
					Self:oFieldsProp[Self:aFieldsID[nIndex]][FIELDS_PROPERTY_POS_SIZE] := GetSx3Cache(Self:aFieldsID[nIndex], "X3_TAMANHO")
					Self:oFieldsProp[Self:aFieldsID[nIndex]][FIELDS_PROPERTY_POS_DECIMAL] := GetSx3Cache(Self:aFieldsID[nIndex], "X3_DECIMAL")
					If Empty(Self:oFieldsProp[Self:aFieldsID[nIndex]][FIELDS_PROPERTY_POS_TYPE])
						lStatus := .F.
						Self:cError := STR0005 + " '" + Self:aFieldsID[nIndex] + "' " + STR0004 //"Coluna 'XXXX' não existe no dicionário de dados.
						Exit
					EndIf
				EndIf
			EndIf
		Next nIndex
	EndIf

	If !Empty(Self:cTabelaPai) .And. Len(Self:aRelPai) > 0 .And. Len(Self:aFieldsPai) > 0

		Self:oFldPropPai := JsonObject():New()
		nTotal := Len(Self:aFieldsPai)
		For nIndex := 1 To nTotal
			If Self:oFldPropPai[Self:aFieldsPai[nIndex]] == Nil
				Self:oFldPropPai[Self:aFieldsPai[nIndex]] := Array(FIELDS_PROPERTY_ARRAY_SIZE)
				If Self:aFieldsPai[nIndex] == "R_E_C_N_O_"
					Self:oFldPropPai[Self:aFieldsPai[nIndex]][FIELDS_PROPERTY_POS_TYPE] := "N"
					Self:oFldPropPai[Self:aFieldsPai[nIndex]][FIELDS_PROPERTY_POS_SIZE] := 10
					Self:oFldPropPai[Self:aFieldsPai[nIndex]][FIELDS_PROPERTY_POS_DECIMAL] := 0
				Else
					Self:oFldPropPai[Self:aFieldsPai[nIndex]][FIELDS_PROPERTY_POS_TYPE] := GetSx3Cache(Self:aFieldsPai[nIndex], "X3_TIPO")
					Self:oFldPropPai[Self:aFieldsPai[nIndex]][FIELDS_PROPERTY_POS_SIZE] := GetSx3Cache(Self:aFieldsPai[nIndex], "X3_TAMANHO")
					Self:oFldPropPai[Self:aFieldsPai[nIndex]][FIELDS_PROPERTY_POS_DECIMAL] := GetSx3Cache(Self:aFieldsPai[nIndex], "X3_DECIMAL")
					If Empty(Self:oFldPropPai[Self:aFieldsPai[nIndex]][FIELDS_PROPERTY_POS_TYPE])
						lStatus := .F.
						Self:cError := STR0005 + " '" + Self:aFieldsPai[nIndex] + "' " + STR0004 //"Coluna 'XXXX' não existe no dicionário de dados.
						Exit
					EndIf
				EndIf
			EndIf
		Next nIndex
	EndIf

Return lStatus

/*/{Protheus.doc} installTrigger
Método responsável por instalar a Trigger no banco de dados.

@author lucas.franca
@since 30/07/2019
@version P12.1.28
@return lSuccess, Logic, Identifica se a trigger foi instalada com sucesso no banco de dados.
/*/
METHOD installTrigger() Class MRPTrigger
	Local lSuccess := .T.

	If !Self:lReady
		lSuccess := .F.
		Self:cError := STR0001 //"Configurações da TRIGGER não foram definidas."
	EndIf

	If lSuccess .And. !Self:cBanco $ "|MSSQL|POSTGRES|ORACLE|"
		lSuccess := .F.
		Self:cError := STR0002 + Self:cBanco // "Trigger não disponível para o banco de dados atual. "
	EndIf

	//Se a trigger já existir, primeiro irá deletar e criar novamente.
	If lSuccess .And. Self:isTriggerInstalled()
		lSuccess := Self:uninstallTrigger()
	EndIf

	If lSuccess
		//Antes de instalar a trigger, faz um dbSelectArea nas tabelas
		//para o caso de a tabela não existir ser criada.
		dbSelectArea("T4R")
		dbSelectArea(Self:cAlias)
		If Self:lExistHWJ .And. Self:lNetChange
			dbSelectArea("HWJ")
		EndIf

		//Executa o script para criar a trigger.
		If TcSqlExec(Self:cSqlTrigger) < 0
			lSuccess := .F.
			Self:cError := TcSqlError()
		EndIf
	EndIf
Return lSuccess

/*/{Protheus.doc} uninstallTrigger
Método responsável por desinstalar a Trigger no banco de dados.

@author lucas.franca
@since 30/07/2019
@version P12.1.28
@return lSuccess, Logic, Identifica se a trigger foi desinstalada com sucesso do banco de dados.
/*/
METHOD uninstallTrigger() Class MRPTrigger
	Local lSuccess := .T.
	Local cSqlDrop := ""

	If !Self:lReady
		lSuccess := .F.
		Self:cError := STR0001 //"Configurações da TRIGGER não foram definidas."
	EndIf

	If lSuccess
		cSqlDrop := " DROP TRIGGER " + Self:cTriggerName

		If Self:cBanco == "POSTGRES"
			cSqlDrop += " ON " + Self:cTabela + "; "
			cSqlDrop += " DROP FUNCTION " + Self:cTriggerName + "_FUN();"
		EndIf

		If TcSqlExec(cSqlDrop) < 0
			lSuccess := .F.
			Self:cError := TcSqlError()
		EndIf
	EndIf

Return lSuccess

/*/{Protheus.doc} isTriggerUpdated
Verifica se a trigger está instalada no banco de dados e se a trigger está atualizada.

@author lucas.franca
@since 30/07/2019
@version P12.1.28
@return lStatus, Logic, Identifica se a trigger está atualizada ou não.
/*/
METHOD isTriggerUpdated() Class MRPTrigger
	Local cAlias     := PCPAliasQr()
	Local cCommand   := ""
	Local cTrigBanco := ""
	Local cTrigBase  := AllTrim(Self:cSqlTrigger)
	Local nPos       := 0
	Local lStatus    := .F.

	If !Self:lReady
		Self:cError := STR0001 //"Configurações da TRIGGER não foram definidas."
		Return .F.
	EndIf

	If Self:cBanco == "MSSQL"
		BeginSql Alias cAlias
			%noparser%
			SELECT CAST(definition AS VARCHAR(MAX)) DEFTRIGGER
			  FROM sys.sql_modules
			 WHERE object_id  = OBJECT_ID(%Exp:Self:cTriggerName%)
		EndSql
	ElseIf Self:cBanco == "ORACLE"
		cCommand := "%TYPE = 'TRIGGER' "
		cCommand += " AND OWNER = (select user from dual) " // Para buscar a trigger do usuário corrente do banco, quando há mais de um banco no oracle.
		cCommand += " AND NAME = '" + Self:cTriggerName + "' ORDER BY LINE%"
		BeginSql Alias cAlias
			%noparser%
			SELECT TEXT DEFTRIGGER
			  FROM ALL_SOURCE
			 WHERE %Exp:cCommand%
		EndSql
	ElseIf Self:cBanco == "POSTGRES"
		cCommand := Self:cTriggerName + "_FUN"
		BeginSql Alias cAlias
			SELECT S.LINE DEFTRIGGER
			  FROM PG_PROC, UNNEST(STRING_TO_ARRAY(PROSRC, ';')) S(LINE)
			 WHERE UPPER(PRONAME) = %Exp:cCommand%
		EndSql
	Else
		Return .F.
	EndIf

	While (cAlias)->(!Eof())
		If Self:cBanco == "POSTGRES"
			If !Empty((cAlias)->DEFTRIGGER)
				cTrigBanco += AllTrim((cAlias)->DEFTRIGGER) + "; "
			EndIf
		Else
			cTrigBanco += (cAlias)->DEFTRIGGER
		EndIf
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If Self:cBanco == "ORACLE"
		//Adiciona o CREATE que é omitido pelo ORACLE.
		cTrigBanco := "CREATE " + cTrigBanco
	EndIf

	If Self:cBanco == "POSTGRES"
		//No POSTGRES avalia somente o conteúdo da TRIGGER FUNCTION.
		nPos := AT("DECLARE", cTrigBase)
		If nPos > 0
			cTrigBase := SubStr(cTrigBase, nPos, Len(cTrigBase)-nPos)
		EndIf
		nPos := AT("END;", cTrigBase)
		If nPos > 0
			cTrigBase := SubStr(cTrigBase, 1, nPos+3)
		EndIf
	EndIf

	lStatus := AllTrim(cTrigBanco) == cTrigBase
Return lStatus

/*/{Protheus.doc} isTriggerInstalled
Verifica se a trigger está instalada no banco de dados.

@author lucas.franca
@since 30/07/2019
@version P12.1.28
@return lStatus, Logic, Identifica se a trigger está instalada ou não.
/*/
METHOD isTriggerInstalled() Class MRPTrigger
	Local cAlias  := PCPAliasQr()
	Local cQuery  := ""
	Local lStatus := .F.

	If !Self:lReady
		Self:cError := STR0001 //"Configurações da TRIGGER não foram definidas."
		Return .F.
	EndIf

	If Self:cBanco == "POSTGRES"

		//Verifica se a FUNCTION da trigger existe.
		cQuery := " SELECT COUNT(*) TOTAL "
		cQuery +=   " FROM pg_proc "
		cQuery +=  " WHERE UPPER(proname) = '" + Self:cTriggerName + "_FUN' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
		If (cAlias)->(TOTAL) >= 1
			//Function existe, verifica se a trigger existe.
			(cAlias)->(dbCloseArea())

			cAlias := PCPAliasQr()

			cQuery := " SELECT COUNT(*) TOTAL "
			cQuery +=   " FROM pg_trigger "
			cQuery +=  " WHERE NOT tgisinternal "
			cQuery +=    " AND UPPER(tgname) = '" + Self:cTriggerName + "'"

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
			If (cAlias)->(TOTAL) >= 1
				lStatus := .T.
			EndIf
		EndIf

		(cAlias)->(dbCloseArea())
	Else
		cQuery := " SELECT COUNT(*) TOTAL "
		If Self:cBanco == "MSSQL"
			cQuery +=  " FROM sys.sysobjects "
			cQuery += " WHERE xtype ='TR' "
			cQuery +=   " AND name  = '" + Self:cTriggerName + "' "
		ElseIf Self:cBanco == "ORACLE"
			cQuery +=  " FROM ALL_TRIGGERS "
			cQuery += " WHERE TABLE_NAME   = '" + Self:cTabela + "' "
			cQuery +=   " AND OWNER = (select user from dual) " // Para buscar a trigger do usuário corrente do banco, quando há mais de um banco no oracle.
			cQuery +=   " AND TRIGGER_NAME = '" + Self:cTriggerName + "' "
		Else
			Return .F.
		EndIf

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
		If (cAlias)->(TOTAL) >= 1
			lStatus := .T.
		EndIf
		(cAlias)->(dbCloseArea())
	EndIf

Return lStatus

/*/{Protheus.doc} createSqlTrigger
Método responsável por criar o comando SQL para instalar a Trigger.

@author lucas.franca
@since 30/07/2019
@version P12.1.28
@return cTrigger, Character, String com o código SQL que irá criar a Trigger.
/*/
METHOD createSqlTrigger() Class MRPTrigger
	Local cTrigger := ""

	If Self:cBanco == "MSSQL"
		cTrigger := Self:MSSQLTrigger()
	ElseIf Self:cBanco == "ORACLE"
		cTrigger := Self:ORACLETrigger()
	ElseIf Self:cBanco == "POSTGRES"
		cTrigger := Self:POSTGRESTrigger()
	EndIf
Return cTrigger

/*/{Protheus.doc} MSSQLTrigger
Método responsável por criar o comando SQL para instalar a Trigger para o banco de dados SQL Server.

@author lucas.franca
@since 01/08/2019
@version P12.1.28
@return cTrigger, Character, String com o código SQL que irá criar a Trigger.
/*/
Method MSSQLTrigger() Class MRPTrigger
	Local cTrigger  := ""
	Local lAtuHwj   := Self:lExistHWJ .And. Self:lNetChange .And. Len(Self:aFieldsNC) > 0
	Local nIndField := 0
	Local nTotal    := 0

	/* 
	AO ACRESCENTAR CÓDIGO DA TRIGGER NA STRING, NÃO DEIXAR ESPAÇO EM BRANCO NO FINAL.
	EXEMPLO: cTrigger += " codigo_da_trigger " <- ERRADO
			 cTrigger += " codigo_da_trigger"  <- CERTO 
	*/

	cTrigger := "CREATE TRIGGER " + Self:cTriggerName + " ON " + Self:cTabela
	cTrigger += " FOR INSERT, UPDATE, DELETE"
	cTrigger += " AS"
	cTrigger += " BEGIN"

	//Correção de bug conforme issue TEC MTEC-3612, MTEC-3613
	cTrigger += " SET NOCOUNT ON "

	//Definição das variáveis utilizadas na trigger.
	cTrigger += " DECLARE " + T4RVars(Self:cBanco) + If(lAtuHwj,HWJVars(Self:cBanco),"")

	//Variável para controlar a operação em execução
	If Self:lOnlyIns
		//Se somente insert, não é necessário a variável @OPERACAO. Remove a última virgula da declaração das variáveis.
		cTrigger := PadR(cTrigger, Len(cTrigger)-1)
	Else
		cTrigger += " @OPERACAO VARCHAR(12)"
	EndIf

	If Self:lVldData
		cTrigger += ", @TOTAL INTEGER"
	EndIf

	cTrigger += " SET @T4R_FILIAL = '" + Space(FwSizeFilial()) + "';"
	cTrigger += " SET @T4R_API    = '" + Self:cApiCode  + "';"
	cTrigger += " SET @T4R_DTENV  = REPLACE(CONVERT(VARCHAR(10), getdate(), 111), '/', '');"
	cTrigger += " SET @T4R_HRENV  = CONVERT(VARCHAR(8), GETDATE(), 108);"

	//Identifica a operação em execução
	If Self:lVldData .Or. !Self:lOnlyIns
		cTrigger += " IF EXISTS(SELECT 1 FROM inserted)"
		cTrigger +=     " IF EXISTS(SELECT 1 FROM deleted)"
		If Self:lVldData
			cTrigger +=    " BEGIN"
			cTrigger +=       " SET @TOTAL = (SELECT COUNT(*)"
			cTrigger +=                       " FROM inserted"
			cTrigger +=                      " INNER JOIN deleted"
			cTrigger +=                         " ON inserted.R_E_C_N_O_ = deleted.R_E_C_N_O_"
			cTrigger +=                        " AND (inserted.D_E_L_E_T_ <> deleted.D_E_L_E_T_"

			nTotal := Len(Self:aFields)
			For nIndField := 1 To nTotal
				cTrigger += " OR inserted." + Self:aFields[nIndField] + " <> deleted." + Self:aFields[nIndField]
			Next nIndField
			cTrigger += "))"

			cTrigger +=       " IF @TOTAL = 0"
			cTrigger +=          " RETURN;"
			If !Self:lOnlyIns
				cTrigger +=   " ELSE"
			EndIf
		EndIf
		If !Self:lOnlyIns
			cTrigger +=          " SELECT @OPERACAO = 'update'"
					            //ENDIF
		EndIf
		If Self:lVldData
			cTrigger +=    " END"
		EndIf

		If !Self:lOnlyIns
			cTrigger += " ELSE"
			cTrigger +=    " SELECT @OPERACAO = 'insert'"
					    //ENDIF
			cTrigger += " ELSE"
			cTrigger +=     " IF EXISTS(SELECT 1 FROM deleted)"
			cTrigger +=         " SELECT @OPERACAO = 'delete'"
			cTrigger +=     " ELSE"
			cTrigger +=         " RETURN;"
						//ENDIF
					//ENDIF
		EndIf
	EndIf

	If Self:lOnlyIns
		cTrigger += " BEGIN"
		cTrigger += " " + Self:montaInsert('insert')
		cTrigger += " END"
	Else
		//Execução quando operação de INSERT
		cTrigger += " IF @OPERACAO = 'insert'"
		cTrigger +=     " BEGIN"
		//Primeiro irá fazer o DELETE para os registros que já existem na T4R.
		cTrigger +=     Self:montaDelete('insert')
		//Depois irá fazer o INSERT para os registros que ainda não existem na T4R.
		cTrigger += " " + Self:montaInsert('insert')
		If lAtuHwj
			cTrigger += " " + Self:insertHWJ('insert')
		EndIf
		cTrigger +=     " END"
		cTrigger += " ELSE"

		//Execução quando operação de UPDATE
		cTrigger +=     " IF @OPERACAO = 'update'"
		cTrigger +=         " BEGIN"
		//Primeiro irá fazer o DELETE para os registros que já existem na T4R.
		cTrigger +=         Self:montaDelete('update')
		//Depois irá fazer o INSERT para os registros que ainda não existem na T4R.
		cTrigger +=   " " + Self:montaInsert('update')
		If lAtuHwj
			cTrigger +=   " " + Self:insertHWJ('update')
		EndIf
		cTrigger +=         " END"
		cTrigger +=     " ELSE"

		//Execução quando operação de DELETE
		cTrigger +=         " BEGIN"
		//Primeiro irá fazer o DELETE para os registros que já existem na T4R.
		cTrigger +=         Self:montaDelete('delete')
		//Depois irá fazer o INSERT para os registros que ainda não existem na T4R.
		cTrigger +=   " " + Self:montaInsert('delete')
		If lAtuHwj
			cTrigger +=   " " + Self:insertHWJ('delete')
		EndIf
		cTrigger +=         " END"
	EndIf
	cTrigger += " END;"
Return cTrigger

/*/{Protheus.doc} ORACLETrigger
Método responsável por criar o comando SQL para instalar a Trigger para o banco de dados ORACLE.

@author lucas.franca
@since 01/08/2019
@version P12.1.28
@return cTrigger, Character, String com o código SQL que irá criar a Trigger.
/*/
Method ORACLETrigger() Class MRPTrigger
	Local cTrigger := ""
	Local cTabHWJ  := RetSqlName("HWJ")
	Local cTipo    := ""
	Local nIndex   := 0
	Local nTotal   := Len(Self:aFields)
	Local nTotUpd  := Len(Self:aFieldsUpd)
	Local lAtuHwj  := Self:lExistHWJ .And. Self:lNetChange .And. Len(Self:aFieldsNC) > 0

	/* 
	AO ACRESCENTAR CÓDIGO DA TRIGGER NA STRING, NÃO DEIXAR ESPAÇO EM BRANCO NO FINAL.
	EXEMPLO: cTrigger += " codigo_da_trigger " <- ERRADO
			 cTrigger += " codigo_da_trigger"  <- CERTO 
	*/

	cTrigger := "CREATE TRIGGER " + Self:cTriggerName
	cTrigger += " AFTER INSERT OR UPDATE OR DELETE ON " + Self:cTabela
	cTrigger += " FOR EACH ROW"
	cTrigger += " DECLARE " + T4RVars(Self:cBanco) + If(lAtuHwj,HWJVars(Self:cBanco),"")
	
	//Define as variáveis para os dados que serão salvos na trigger.
	If Self:lCriaDados
		For nIndex := 1 To nTotal
			cTrigger += " v" + Self:aFields[nIndex] + " " + Self:cTabela + "." + Self:aFields[nIndex] + "%TYPE;"
		Next nIndex
	EndIf

	cTrigger +=         " vDELETED " + Self:cTabela + ".D_E_L_E_T_%TYPE;"
	cTrigger +=         " vOPERACAO VARCHAR(12);"
	cTrigger +=         " vCOUNT    NUMBER;"

	cTrigger += " BEGIN"
	cTrigger +=     " IF DELETING THEN"
	cTrigger +=         " vOPERACAO := 'delete';"
	cTrigger +=     " ELSE"
	cTrigger +=         " IF INSERTING THEN"
	cTrigger +=             " vOPERACAO := 'insert';"
	cTrigger +=         " ELSE"
	cTrigger +=             " IF UPDATING THEN"
	cTrigger +=                 " vOPERACAO := 'update';"
	cTrigger +=             " ELSE"
	cTrigger +=                 " RETURN;"
	cTrigger +=             " END IF;"
	cTrigger +=         " END IF;"
	cTrigger +=     " END IF;"

	If nTotal > 0 .and. Self:lVldData
		cTrigger += " IF vOPERACAO = 'update' THEN"
		cTrigger += 	" IF NOT ("

		cTrigger += " :OLD.D_E_L_E_T_ <> :NEW.D_E_L_E_T_"
		For nIndex := 1 To nTotal
			cTipo := Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_TYPE]
			If cTipo == "M"
				cTrigger += " OR ((dbms_lob.compare(:OLD." + Self:aFields[nIndex] + ",:NEW." + Self:aFields[nIndex] + ") <> 0)"
				cTrigger += " AND ((:OLD." + Self:aFields[nIndex] + " IS NULL AND :NEW." + Self:aFields[nIndex] + " IS NOT NULL) OR"
				cTrigger += " (:OLD." + Self:aFields[nIndex] + " IS NOT NULL AND :NEW." + Self:aFields[nIndex] + " IS NULL) OR"
				cTrigger += " (:OLD." + Self:aFields[nIndex] + " IS NOT NULL AND :NEW." + Self:aFields[nIndex] + " IS NOT NULL)))"
			Else
				cTrigger += " OR :OLD." + Self:aFields[nIndex] + " <> :NEW." + Self:aFields[nIndex]
			EndIf
		Next
		
		cTrigger += 	" ) THEN"
		cTrigger += 		" RETURN;"
		cTrigger += 	" END IF;"
		cTrigger += " END IF;"
	EndIf

	//Tratativa específica para a tabela de demandas.
	//Não executa a trigger quando for atualizado somente o campo VR_INTMRP
	If Self:cAlias == "SVR"
		cTrigger += " IF vOPERACAO = 'update' THEN"
		cTrigger +=     " IF (:OLD.D_E_L_E_T_ = :NEW.D_E_L_E_T_"
		cTrigger +=       " OR (:OLD.D_E_L_E_T_ IS NULL AND :NEW.D_E_L_E_T_ IS NULL))"
		For nIndex := 1 To nTotal
			If Self:aFields[nIndex] == "VR_INTMRP"
				Loop
			EndIf
			cTipo := Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_TYPE]
			If cTipo == "M"
				cTrigger += " AND (dbms_lob.compare(:OLD." + Self:aFields[nIndex] + ", :NEW." + Self:aFields[nIndex] + ") = 0"
			Else
				cTrigger += " AND (:OLD." + Self:aFields[nIndex] + " = :NEW." + Self:aFields[nIndex]
			EndIf
			cTrigger +=  " OR (:OLD." + Self:aFields[nIndex] + " IS NULL AND :NEW." + Self:aFields[nIndex] + " IS NULL))"
		Next nIndex
		cTrigger +=                " THEN"
		cTrigger +=         " RETURN;"
		cTrigger +=     " END IF;"
		cTrigger += " END IF;"
	EndIf

    cTrigger +=     " vT4R_FILIAL := '" + Space(FwSizeFilial()) + "';"
	cTrigger +=     " vT4R_API    := '" + Self:cApiCode + "';"
    cTrigger +=     " vT4R_DTENV  := TO_CHAR(SYSDATE, 'YYYYMMDD');"
    cTrigger +=     " vT4R_HRENV  := TO_CHAR(SYSDATE,'hh24:mi:ss');"

	If lAtuHwj
		cTrigger +=     " vHWJ_ORIGEM := '" + GetHWJOri(Self:cApiCode) + "';"
	EndIf

	cTrigger +=     " IF vOPERACAO = 'delete' THEN"
	cTrigger +=       Self:concatKey(':OLD','vT4R_IDREG') + ";"

	If lAtuHwj
		cTrigger += " vHWJ_FILIAL := :OLD." + SELF:aFieldsNC[1] + ";"
		cTrigger += " vHWJ_PROD   := :OLD." + SELF:aFieldsNC[2] + ";"
	EndIf

	cTrigger +=         " vDELETED  := :OLD.D_E_L_E_T_;"
	//Se irá criar os dados, armazena os valores nas variáveis,
	If Self:lCriaDados
		For nIndex := 1 To nTotal
			cTrigger += " v" + Self:aFields[nIndex] + " := :OLD." + Self:aFields[nIndex] + ";"
		Next nIndex
	EndIf
	cTrigger +=     " ELSE"
	cTrigger +=       /*" vT4R_IDREG := "*/ + Self:concatKey(':NEW','vT4R_IDREG') + ";"

	If lAtuHwj
		cTrigger += " vHWJ_FILIAL := :NEW." + SELF:aFieldsNC[1] + ";"
		cTrigger += " vHWJ_PROD   := :NEW." + SELF:aFieldsNC[2] + ";"
	EndIf

	cTrigger +=         " vDELETED  := :NEW.D_E_L_E_T_;"
	//Se irá criar os dados, armazena os valores nas variáveis,
	If Self:lCriaDados
		For nIndex := 1 To nTotal
			cTrigger += " v" + Self:aFields[nIndex] + " := :NEW." + Self:aFields[nIndex] + ";"
		Next nIndex
	EndIf
	cTrigger +=     " END IF;"
	cTrigger +=     " IF (vDELETED = '*' AND vOPERACAO IN('delete','insert')) OR vT4R_IDREG = ' ' THEN"
	cTrigger +=         " RETURN;"
	cTrigger +=     " END IF;"

	If Self:lOnlyIns
		cTrigger +=  " vT4R_TIPO := '3';"
		If lAtuHwj
			cTrigger += " vHWJ_EVENTO := '3';"
		EndIf
	Else
		If Self:lCanDelete
			If lAtuHwj
				cTrigger +=     " IF vDELETED = '*' THEN"
				cTrigger +=         " vT4R_TIPO := '2';"
				cTrigger +=         " vHWJ_EVENTO := '2';"
				cTrigger +=     " ELSE"
				cTrigger +=         " IF vOPERACAO = 'delete' THEN"
				cTrigger +=             " vT4R_TIPO := '2';"
				cTrigger +=             " vHWJ_EVENTO := '2';"
				cTrigger +=         " ELSE"
				cTrigger +=             " vT4R_TIPO := '1';"
				cTrigger +=             " vHWJ_EVENTO := '1';"
				cTrigger +=         " END IF;"
				cTrigger +=     " END IF;"
			Else
				cTrigger +=     " IF vDELETED = '*' THEN"
				cTrigger +=         " vT4R_TIPO := '2';"
				cTrigger +=     " ELSE"
				cTrigger +=         " IF vOPERACAO = 'delete' THEN"
				cTrigger +=             " vT4R_TIPO := '2';"
				cTrigger +=         " ELSE"
				cTrigger +=             " vT4R_TIPO := '1';"
				cTrigger +=         " END IF;"
				cTrigger +=     " END IF;"
			EndIf
		Else
			cTrigger +=     " vT4R_TIPO := '1';"
			If lAtuHwj
				cTrigger +=     " vHWJ_EVENTO := '1';"
			EndIf
		EndIf
	EndIf

	//Se irá criar os dados, alimenta a variável para inserir no campo T4R_DADOS,
	If Self:lCriaDados
		cTrigger += " vT4R_DADOS := TO_BLOB(UTL_RAW.CAST_TO_RAW('{"

		For nIndex := 1 To nTotal
			If nIndex > 1
				cTrigger += ","
			EndIf
			cTipo := Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_TYPE]

			cTrigger += ASPAS + Self:aFields[nIndex] + ASPAS + ":"
			If cTipo $ "|C|D|L|"
				cTrigger += ASPAS + "'||"
				If cTipo == "C"
					cTrigger += "RTRIM(v" + Self:aFields[nIndex] + ")"
				Else
					cTrigger += "v" + Self:aFields[nIndex]
				EndIf
				cTrigger += "||'"
				cTrigger += ASPAS
			ElseIf cTipo == "M"
				cTrigger += "'|| CASE WHEN v" + Self:aFields[nIndex] + " IS NULL THEN 'false' ELSE 'true' END||'"
			Else //Numérico
				cTrigger += "'|| TO_CHAR(v" + Self:aFields[nIndex] + GetMascara(Self, nIndex) + ")||'"
			EndIf

		Next nIndex

		cTrigger += "} '));"
	Else
		cTrigger += " vT4R_DADOS := NULL;"
	EndIf

	If Self:lOnlyIns
		
		cTrigger += " SELECT COUNT(*)"
		cTrigger +=   " INTO vCOUNT"
		cTrigger +=   " FROM " + RetSqlName("T4R")
		cTrigger +=  " WHERE T4R_FILIAL = vT4R_FILIAL"
		cTrigger +=    " AND T4R_API    = vT4R_API"
		cTrigger +=    " AND T4R_IDPRC  = ' '"
		cTrigger +=    " AND T4R_IDREG  = vT4R_IDREG"
		cTrigger +=    " AND R_E_C_D_E_L_ = 0;"

		cTrigger += " IF vCOUNT = 0 THEN"
	Else
		cTrigger += Self:montaDelete()
	EndIf
	
	//Inclui os novos dados na T4R para este registro
	cTrigger += Self:montaInsert()

	If Self:lOnlyIns
		cTrigger += " END IF;"
	EndIf

    If lAtuHwj
		If nTotUpd > 0
			cTrigger += " IF vOPERACAO = 'update' THEN"
			cTrigger +=     " IF (:OLD.D_E_L_E_T_ = :NEW.D_E_L_E_T_"
			cTrigger +=       " OR (:OLD.D_E_L_E_T_ IS NULL AND :NEW.D_E_L_E_T_ IS NULL))"
			For nIndex := 1 To nTotUpd
				cTrigger += " AND (:OLD." + Self:aFieldsUpd[nIndex] + " = :NEW." + Self:aFieldsUpd[nIndex]
				cTrigger +=  " OR (:OLD." + Self:aFieldsUpd[nIndex] + " IS NULL AND :NEW." + Self:aFieldsUpd[nIndex] + " IS NULL))"
			Next nIndex
			cTrigger +=                " THEN"
			cTrigger +=         " RETURN;"
			cTrigger +=     " END IF;"
			cTrigger += " END IF;"
		EndIf
		cTrigger +=     " SELECT COUNT(*)"
		cTrigger +=       " INTO vCOUNT"
		cTrigger +=      " FROM " + cTabHWJ
		cTrigger +=     " WHERE HWJ_FILIAL   = vHWJ_FILIAL"
		cTrigger +=       " AND HWJ_PROD = vHWJ_PROD;"

		cTrigger +=     " IF vCOUNT = 0 THEN"
		cTrigger += Self:insertHWJ('insert')
		cTrigger +=     " END IF;"
	EndIf
	cTrigger += " END;"

Return cTrigger

/*/{Protheus.doc} POSTGRESTrigger
Método responsável por criar o comando SQL para instalar a Trigger para o banco de dados POSTGRES.

@author lucas.franca
@since 01/08/2019
@version P12.1.28
@return cTrigger, Character, String com o código SQL que irá criar a Trigger.
/*/
Method POSTGRESTrigger() Class MRPTrigger
	Local cTrigger := ""
	Local cTabT4R  := RetSqlName("T4R")
	Local cTabHWJ  := RetSqlName("HWJ")
	Local cTipo    := ""
	Local nIndex   := 0
	Local nTotal   := Len(Self:aFields)
	Local nTotUpd  := Len(Self:aFieldsUpd)
	Local lAtuHwj  := Self:lExistHWJ .And. Self:lNetChange .And. Len(Self:aFieldsNC) > 0

	/* 
	AO ACRESCENTAR CÓDIGO DA TRIGGER NA STRING, NÃO DEIXAR ESPAÇO EM BRANCO NO FINAL.
	EXEMPLO: cTrigger += " codigo_da_trigger " <- ERRADO
			 cTrigger += " codigo_da_trigger"  <- CERTO 
	*/

	cTrigger := "CREATE OR REPLACE FUNCTION " + Self:cTriggerName + "_FUN()"
	cTrigger += " RETURNS trigger AS $" + Self:cTriggerName + "_TRIGGER$"

	cTrigger += " DECLARE " + T4RVars(Self:cBanco) + If(lAtuHwj,HWJVars(Self:cBanco),"")

	//Define as variáveis para os dados que serão salvos na trigger.
	If Self:lCriaDados
		For nIndex := 1 To nTotal
			cTrigger += " v" + Self:aFields[nIndex] + " " + Self:cTabela + "." + Self:aFields[nIndex] + "%TYPE;"
		Next nIndex
	EndIf

	cTrigger +=     " vDELETED " + cTabT4R + ".D_E_L_E_T_%TYPE;"

	If lAtuHwj
		cTrigger +=     " vCOUNT    BIGINT;"
	EndIf

	cTrigger += " BEGIN"

	If nTotal > 0 .and. Self:lVldData
		cTrigger += " IF NOT ("

		cTrigger += " OLD.D_E_L_E_T_ IS DISTINCT FROM NEW.D_E_L_E_T_"
		For nIndex := 1 To nTotal
			cTrigger += " OR OLD." + Self:aFields[nIndex] + " IS DISTINCT FROM NEW." + Self:aFields[nIndex]
		Next

		cTrigger += " ) THEN"
		cTrigger += 	" RETURN NEW;"
		cTrigger += " END IF;"
	EndIf

	cTrigger +=     " vT4R_FILIAL := '" + Space(FwSizeFilial()) + "';"
	cTrigger +=     " vT4R_API    := '" + Self:cApiCode + "';"
	cTrigger +=     " vT4R_DTENV  := TO_CHAR(current_date, 'YYYYMMDD');"
	cTrigger +=     " vT4R_HRENV  := TO_CHAR(current_timestamp, 'HH24:MI:SS');"
	If lAtuHwj
		cTrigger +=     " vHWJ_ORIGEM := '" + GetHWJOri(Self:cApiCode) + "';"
	EndIf

	cTrigger += " IF TG_OP = 'DELETE' THEN"
	cTrigger +=     " vDELETED   := OLD.D_E_L_E_T_;"
	cTrigger +=     " vT4R_IDREG := " + Self:concatKey('OLD') + ";"

	If lAtuHwj
		cTrigger +=     " vHWJ_FILIAL := OLD." + SELF:aFieldsNC[1] + ";"
		cTrigger +=     " vHWJ_PROD   := OLD." + SELF:aFieldsNC[2] + ";"
	EndIf

	//Se irá criar os dados, armazena os valores nas variáveis,
	If Self:lCriaDados
		For nIndex := 1 To nTotal
			cTrigger += " v" + Self:aFields[nIndex] + " := OLD." + Self:aFields[nIndex] + ";"
		Next nIndex
	EndIf
	cTrigger += " ELSE"
	cTrigger +=     " vDELETED   := NEW.D_E_L_E_T_;"
	cTrigger +=     " vT4R_IDREG := " + Self:concatKey('NEW') + ";"

	If lAtuHwj
		cTrigger +=     " vHWJ_FILIAL := NEW." + SELF:aFieldsNC[1] + ";"
		cTrigger +=     " vHWJ_PROD   := NEW." + SELF:aFieldsNC[2] + ";"
	EndIf

	If Self:lCriaDados
		For nIndex := 1 To nTotal
			cTrigger += " v" + Self:aFields[nIndex] + " := NEW." + Self:aFields[nIndex] + ";"
		Next nIndex
	EndIf
	cTrigger += " END IF;"

	cTrigger +=     " IF (vDELETED = '*' AND TG_OP IN('DELETE','INSERT')) OR vT4R_IDREG = ' ' THEN"
	cTrigger +=         " RETURN NEW;"
	cTrigger +=     " END IF;"

	//Tratativa específica para a tabela de demandas.
	//Não executa a trigger quando for atualizado somente o campo VR_INTMRP
	If Self:cAlias == "SVR"
		cTrigger += " IF TG_OP = 'UPDATE' THEN"
		cTrigger +=     " IF (OLD.D_E_L_E_T_ = NEW.D_E_L_E_T_"
		cTrigger +=       " OR (OLD.D_E_L_E_T_ IS NULL AND NEW.D_E_L_E_T_ IS NULL))"

		For nIndex := 1 To nTotal
			If Self:aFields[nIndex] == "VR_INTMRP"
				Loop
			EndIf
			cTrigger += " AND (OLD." + Self:aFields[nIndex] + " = NEW." + Self:aFields[nIndex]
			cTrigger +=  " OR (OLD." + Self:aFields[nIndex] + " IS NULL AND NEW." + Self:aFields[nIndex] + " IS NULL))"
		Next nIndex
		cTrigger +=                " THEN"
		cTrigger +=         " RETURN NEW;"
		cTrigger +=     " END IF;"
		cTrigger += " END IF;"
	EndIf

	If Self:lOnlyIns
		cTrigger +=     " vT4R_TIPO := '3';"
		If lAtuHwj
			cTrigger += " vHWJ_EVENTO := '3';"
		EndIf
	Else
		If Self:lCanDelete
			If lAtuHwj
				cTrigger +=     " IF vDELETED = '*' THEN"
				cTrigger +=         " vT4R_TIPO := '2';"
				cTrigger +=         " vHWJ_EVENTO := '2';"
				cTrigger +=     " ELSE"
				cTrigger +=         " IF TG_OP = 'DELETE' THEN"
				cTrigger +=             " vT4R_TIPO := '2';"
				cTrigger +=             " vHWJ_EVENTO := '2';"
				cTrigger +=         " ELSE"
				cTrigger +=             " vT4R_TIPO := '1';"
				cTrigger +=             " vHWJ_EVENTO := '1';"
				cTrigger +=         " END IF;"
				cTrigger +=     " END IF;"
			Else
				cTrigger +=     " IF vDELETED = '*' THEN"
				cTrigger +=         " vT4R_TIPO := '2';"
				cTrigger +=     " ELSE"
				cTrigger +=         " IF TG_OP = 'DELETE' THEN"
				cTrigger +=             " vT4R_TIPO := '2';"
				cTrigger +=         " ELSE"
				cTrigger +=             " vT4R_TIPO := '1';"
				cTrigger +=         " END IF;"
				cTrigger +=     " END IF;"
			EndIf
		Else
			cTrigger +=     " vT4R_TIPO := '1';"
			If lAtuHwj
				cTrigger +=     " vHWJ_EVENTO := '1';"
			EndIf
		EndIf
	EndIf

	If Self:lCriaDados
		cTrigger += " vT4R_DADOS := DECODE('{"
		For nIndex := 1 To nTotal
			If nIndex > 1
				cTrigger += ","
			EndIf
			cTipo := Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_TYPE]

			cTrigger += ASPAS + Self:aFields[nIndex] + ASPAS + ":"
			If cTipo $ "|C|D|L|"
				cTrigger += ASPAS + "'||"
				If cTipo == "C"
					cTrigger += "RTRIM(Replace(v" + Self:aFields[nIndex] + ",'\','\\'))"
				Else
					cTrigger += "v" + Self:aFields[nIndex]
				EndIf
				cTrigger += "||'"
				cTrigger += ASPAS
			ElseIf cTipo == "M"
				cTrigger += "'|| CASE WHEN COALESCE(v" + Self:aFields[nIndex] + ",'') = '' THEN 'false' ELSE 'true' END||'"
			Else
				//Numérico deve ser tratado diferentemente quando possui decimal
				If Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_DECIMAL] > 0
					cTrigger += "'|| TO_CHAR(v" + Self:aFields[nIndex] + GetMascara(Self, nIndex) + ")||'"
				Else
					cTrigger += "'|| CAST(v" + Self:aFields[nIndex] + " AS VARCHAR)||'"
				EndIf
			EndIf
		Next nIndex
		cTrigger += "} ', 'escape');"
	Else
		cTrigger += " vT4R_DADOS := NULL;"
	EndIf

	If Self:lOnlyIns
		cTrigger += " IF NOT EXISTS(SELECT 1"
		cTrigger +=                 " FROM " + cTabT4R
		cTrigger +=                " WHERE T4R_FILIAL = vT4R_FILIAL"
		cTrigger +=                  " AND T4R_API    = vT4R_API"
		cTrigger +=                  " AND T4R_IDPRC  = ' '"
		cTrigger +=                  " AND T4R_IDREG  = vT4R_IDREG"
		cTrigger +=                  " AND R_E_C_D_E_L_ = 0) THEN"
	Else
		cTrigger += Self:montaDelete()
	EndIf
	
	//Inclui os novos dados na T4R para este registro
	cTrigger += Self:montaInsert()

	If Self:lOnlyIns
		cTrigger += " END IF;"
	EndIf

    If lAtuHwj

		If nTotUpd > 0
			cTrigger += " IF TG_OP = 'UPDATE' THEN"
			cTrigger +=     " IF (OLD.D_E_L_E_T_ = NEW.D_E_L_E_T_"
			cTrigger +=       " OR (OLD.D_E_L_E_T_ IS NULL AND NEW.D_E_L_E_T_ IS NULL))"
			For nIndex := 1 To nTotUpd
				cTrigger += " AND (OLD." + Self:aFieldsUpd[nIndex] + " = NEW." + Self:aFieldsUpd[nIndex]
				cTrigger +=  " OR (OLD." + Self:aFieldsUpd[nIndex] + " IS NULL AND NEW." + Self:aFieldsUpd[nIndex] + " IS NULL))"
			Next nIndex
			cTrigger +=                " THEN"
			cTrigger +=         " RETURN NEW;"
			cTrigger +=     " END IF;"
			cTrigger += " END IF;"
		EndIf

		cTrigger +=     " SELECT COUNT(*)"
		cTrigger +=       " INTO vCOUNT"
		cTrigger +=      " FROM " + cTabHWJ
		cTrigger +=     " WHERE HWJ_FILIAL   = vHWJ_FILIAL"
		cTrigger +=       " AND HWJ_PROD = vHWJ_PROD;"

		cTrigger +=     " IF vCOUNT = 0 THEN"
		cTrigger += Self:insertHWJ('insert')
		cTrigger +=     " END IF;"
	EndIf

	cTrigger += " RETURN NEW;"
	cTrigger += " END;"
	cTrigger += " $" + Self:cTriggerName + "_TRIGGER$ LANGUAGE plpgsql;"

	cTrigger += " CREATE TRIGGER " + Self:cTriggerName
	cTrigger += " AFTER INSERT OR UPDATE OR DELETE ON " + Self:cTabela
	cTrigger += " FOR EACH ROW"
	cTrigger += " EXECUTE PROCEDURE " + Self:cTriggerName + "_FUN();"

Return cTrigger

/*/{Protheus.doc} concatKey
Gera a concatenação do BD para a chave do registro.

@author lucas.franca
@since 31/07/2019
@version P12.1.28
@param 01 cPrefix , Character, Prefixo para utilizar como nomenclatura de RECORD SET
@param 02 cIntoVar, Character, Variavel a ser atribuída com o INTO (tratamento para ORACLE)
@return cKey, Character, Campos concatenados para gerar o valor da chave do registro.
/*/
Method concatKey(cPrefix, cIntoVar) Class MRPTrigger
	Local cConcat  := "||"
	Local cField   := ""
	Local cKey     := ""
	Local cTipo    := ""
	Local nIndex   := 0
	Local nTotal   := Len(Self:aFieldsID)
	Local nTamanho := 0
	Local nTamRel  := 0

	Default cIntoVar := ""

	/*
		Exemplo da string esperada para cada banco:
			Postgres:
				RPAD(NEW.VR_FILIAL,2)||RPAD(NEW.VR_CODIGO, 15)||RPAD(CAST(NEW.VR_SEQUEN AS VARCHAR), 10)
			Oracle:
				:NEW.VR_FILIAL||:NEW.VR_CODIGO||CAST(:NEW.VR_SEQUEN AS VARCHAR)
			SQL Server:
				VR_FILIAL+VR_CODIGO+CAST(VR_SEQUEN AS VARCHAR(10))
	*/

	/*Caso sejam enviados estes dados, o tratamento da chave é feito para buscar os dados da tabela pai*/
	If !Empty(Self:cTabelaPai) .And. Len(Self:aRelPai) > 0 .And. Len(Self:aFieldsPai) > 0

		If Self:cBanco == "MSSQL"
			cConcat := "+"
		EndIf

		nTamRel  := Len(Self:aRelPai)
		nTotal   := Len(Self:aFieldsPai)

		If Empty(cIntoVar)
			cKey := " ("
		EndIf

		cKey += " SELECT "

		For nIndex := 1 To nTotal

			cTipo    := Self:oFldPropPai[Self:aFieldsPai[nIndex]][FIELDS_PROPERTY_POS_TYPE]
			nTamanho := Self:oFldPropPai[Self:aFieldsPai[nIndex]][FIELDS_PROPERTY_POS_SIZE]
			cField   := Self:cTabelaPai+"."+Self:aFieldsPai[nIndex]

			If cTipo $ "|C|D|"
				If Self:cBanco == "POSTGRES"
					cField := "RPAD(" + cField + "," + cValToChar(nTamanho) + ")"
				EndIf
				cKey += cField

			ElseIf cTipo == "N"
				If Self:cBanco == "POSTGRES"
					cKey += "RPAD(CAST(" + cField + " AS VARCHAR)," + cValToChar(nTamanho) + ")"
				ElseIf Self:cBanco == "MSSQL"
					cKey += "CAST(" + cField + " AS VARCHAR(" + cValToChar(nTamanho) + "))"
				Else
					cKey += "TO_CHAR(" + cField + ")"
				EndIf
			EndIf

			If nIndex <> nTotal
				cKey += cConcat
			EndIf

		Next nX

		If !Empty(cIntoVar)
			cKey += " INTO " + cIntoVar
		EndIf

		cKey += " FROM "
		cKey +=	RetSqlName(Self:cTabelaPai)+" "+Self:cTabelaPai+" WHERE "

		For nIndex := 1 To nTamRel
			cKey += Self:cTabelaPai+"."+Self:aRelPai[nIndex][1]+" = "+cPrefix+"."+Self:aRelPai[nIndex][2]
			If nIndex <> nTamRel
				cKey += " AND "
			EndIf
		Next nX

		cKey +=	" AND "+Self:cTabelaPai+".D_E_L_E_T_ = ' ' "

		If Empty(cIntoVar)
			cKey += ")"
		EndIf
	Else

		If Self:cBanco == "MSSQL"
			cConcat := "+"
		EndIf

		For nIndex := 1 To nTotal
			If !Empty(cKey)
				cKey += cConcat
			EndIf

			cTipo    := Self:oFieldsProp[Self:aFieldsID[nIndex]][FIELDS_PROPERTY_POS_TYPE]
			nTamanho := Self:oFieldsProp[Self:aFieldsID[nIndex]][FIELDS_PROPERTY_POS_SIZE]

			If !Empty(cPrefix)
				cField := cPrefix + "." + Self:aFieldsID[nIndex]
			Else
				cField := Self:aFieldsID[nIndex]
			EndIf

			If cTipo $ "|C|D|"
				If Self:cBanco == "POSTGRES"
					cField := "RPAD(" + cField + "," + cValToChar(nTamanho) + ")"
				EndIf
				cKey += cField
			ElseIf cTipo == "N"
				If Self:cBanco == "POSTGRES"
					cKey += "RPAD("
				EndIf
				cKey += "CAST(" + cField + " AS VARCHAR"
				If Self:cBanco $ "|ORACLE|POSTGRES|"
					cKey += ")"
				Else
					cKey += "(" + cValToChar(nTamanho) + "))"
				EndIf
				If Self:cBanco == "POSTGRES"
					cKey += "," + cValToChar(nTamanho) + ")"
				EndIf
			EndIf
		Next nIndex

		If !Empty(cIntoVar)
			cKey := " " + cIntoVar + " := " + cKey
		EndIf
	EndIf

Return cKey

/*/{Protheus.doc} montaUpdate
Monta a query UPDATE para a tabela T4R

@type  Method
@author lucas.franca
@since 02/08/2019
@version P12.1.28
@param cOperacao, Character, Operação que deve ser considerada (insert/update/delete). Utilizado somente se SQL Server.
@return cUpdate , Character, SQL com o update para a tabela T4R
/*/
METHOD montaUpdate(cOperacao) CLASS MRPTrigger
	Local cUpdate  := ""
	Local cPrefix  := "v"
	Local nIndex   := 0
	Local nTotal   := Len(Self:aFields)

	If Self:cBanco == "MSSQL"
		cPrefix := "@"
	EndIf

	cUpdate +=" UPDATE " + RetSqlName("T4R")
	cUpdate +=   " SET T4R_STATUS   = '" + valorPadrao("T4R_STATUS") + "',"
	cUpdate +=       " T4R_DTENV    = " + cPrefix + "T4R_DTENV,"
	cUpdate +=       " T4R_HRENV    = " + cPrefix + "T4R_HRENV,"
	cUpdate +=       " T4R_PROG     = '" + valorPadrao("T4R_PROG"  ) + "',"
	cUpdate +=       " T4R_MSGRET   = '" + valorPadrao("T4R_MSGRET") + "',"
	cUpdate +=       " T4R_DTREP    = '" + valorPadrao("T4R_DTREP" ) + "',"
	cUpdate +=       " T4R_HRREP    = '" + valorPadrao("T4R_HRREP" ) + "',"
	cUpdate +=       " T4R_MSGENV   = NULL,"

	If Self:cBanco == "MSSQL"
		If cOperacao == 'insert' .Or. !Self:lCanDelete
			cUpdate +=   " T4R_TIPO  = '1',"
		ElseIf cOperacao == 'update'
			cUpdate +=   " T4R_TIPO  = CASE WHEN REG_PEND.D_E_L_E_T_ = '*' THEN '2' ELSE '1' END,"
		Else
			cUpdate +=   " T4R_TIPO  = '2',"
		EndIf

		//Se irá criar os dados, concatena os dados para atualizar o campo T4R_DADOS
		If Self:lCriaDados
			cUpdate += " T4R_DADOS   = CONVERT(VARBINARY(MAX)," + Self:SQLconcatDados("REG_PEND") + "),"
		Else
			cUpdate += " T4R_DADOS   = NULL,"
		EndIf
	Else
		cUpdate +=   " T4R_TIPO     = " + cPrefix + "T4R_TIPO,"
		cUpdate +=   " T4R_DADOS    = " + cPrefix + "T4R_DADOS,"
	EndIf

	cUpdate +=       " D_E_L_E_T_   = ' ',"
	cUpdate +=       " R_E_C_D_E_L_ = 0"

	If Self:cBanco == "MSSQL"
		cUpdate += " FROM " + RetSqlName("T4R") + " T4R"
		cUpdate += " INNER JOIN " + Iif(cOperacao $ "|insert|update|", "inserted", "deleted") + " REG_PEND"
		cUpdate +=    " ON T4R.T4R_FILIAL = " + cPrefix + "T4R_FILIAL"
		cUpdate +=   " AND T4R.T4R_API    = " + cPrefix + "T4R_API"
		cUpdate +=   " AND T4R.T4R_IDPRC  = ' '"
		cUpdate +=   " AND T4R.D_E_L_E_T_ = ' '"
		cUpdate +=   " AND " + Self:concatKey("REG_PEND") + " = T4R.T4R_IDREG"

		If cOperacao == 'update'
			//Tratativa específica para a tabela de demandas.
			//Não executa a trigger quando for atualizado somente o campo VR_INTMRP
			If Self:cAlias == "SVR"
				cUpdate += " AND NOT EXISTS(SELECT 1"
				cUpdate +=                  " FROM deleted old"
				cUpdate +=                 " WHERE old.R_E_C_N_O_ = REG_PEND.R_E_C_N_O_"
				cUpdate +=                   " AND (old.D_E_L_E_T_ = REG_PEND.D_E_L_E_T_"
				cUpdate +=                    " OR (old.D_E_L_E_T_ IS NULL AND REG_PEND.D_E_L_E_T_ IS NULL))"

				For nIndex := 1 To nTotal
					If Self:aFields[nIndex] == "VR_INTMRP"
						Loop
					EndIf
					cUpdate += " AND (old." + Self:aFields[nIndex] + " = REG_PEND." + Self:aFields[nIndex]
					cUpdate +=  " OR (old." + Self:aFields[nIndex] + " IS NULL AND REG_PEND." + Self:aFields[nIndex] + " IS NULL))"
				Next nIndex
				cUpdate +=                ");"
			EndIf
		ElseIf cOperacao == "delete"
			cUpdate +=   " AND REG_PEND.D_E_L_E_T_ = ' ';"
		Else
			cUpdate += ";"
		EndIf
	Else
		cUpdate += " WHERE T4R_FILIAL = " + cPrefix + "T4R_FILIAL"
		cUpdate +=   " AND T4R_API    = " + cPrefix + "T4R_API"
		cUpdate +=   " AND T4R_IDPRC  = ' '"
		cUpdate +=   " AND D_E_L_E_T_ = ' '"
		cUpdate +=   " AND T4R_IDREG  = " + cPrefix + "T4R_IDREG;"
	EndIf

Return cUpdate

/*/{Protheus.doc} montaDelete
Monta a query DELETE para a tabela T4R

@type  Method
@author brunno.costa
@since 22/05/2020
@version P12.1.30
@param cOperacao, Character, Operação que deve ser considerada (insert/update/delete). Utilizado somente se SQL Server.
@return cDelete , Character, SQL com o delete para a tabela T4R
/*/
METHOD montaDelete(cOperacao) CLASS MRPTrigger
	Local cDelete := ""
	Local cPrefix := "v"
	Local cTblT4R := RetSqlName("T4R")

	Default cOperacao := ""

	If Self:cBanco == "MSSQL"
		cPrefix := "@"

		cDelete := " UPDATE " + cTblT4R
		cDelete +=    " SET " + cTblT4R + ".D_E_L_E_T_ = '*',"
		cDelete +=              cTblT4R + ".R_E_C_D_E_L_ = " + cTblT4R + ".R_E_C_N_O_"
		cDelete +=   " FROM " + cTblT4R
		cDelete +=  " INNER JOIN " + IIf(cOperacao $ "|insert|update|", "inserted", "deleted") + " REG_PEND"
		cDelete +=     " ON " + cTblT4R + ".T4R_FILIAL = " + cPrefix + "T4R_FILIAL"
		cDelete +=    " AND " + cTblT4R + ".T4R_API    = " + cPrefix + "T4R_API"
		cDelete +=    " AND " + cTblT4R + ".T4R_IDPRC  = ' '"
		cDelete +=    " AND " + cTblT4R + ".D_E_L_E_T_ = ' '"
		cDelete +=    " AND " + Self:concatKey("REG_PEND") + " = " + cTblT4R + ".T4R_IDREG"

		If cOperacao $ "|delete|insert|"
			cDelete +=   " AND REG_PEND.D_E_L_E_T_ = ' ';"
		Else
			cDelete += ";"
		EndIf
	Else
		cDelete := " UPDATE " + cTblT4R
		cDelete +=    " SET D_E_L_E_T_   = '*',"
		cDelete +=        " R_E_C_D_E_L_ = R_E_C_N_O_"
		cDelete +=  " WHERE T4R_FILIAL = " + cPrefix + "T4R_FILIAL"
		cDelete +=    " AND T4R_API    = " + cPrefix + "T4R_API"
		cDelete +=    " AND T4R_IDPRC  = ' '"
		cDelete +=    " AND D_E_L_E_T_ = ' '"
		cDelete +=    " AND T4R_IDREG  = " + cPrefix + "T4R_IDREG;"
	EndIf

Return cDelete

/*/{Protheus.doc} montaInsert
Monta o SQL para realizar o insert na tabela T4R

@type  Method
@author lucas.franca
@since 02/08/2019
@version P12.1.28
@param cOperacao, Character, Operação que deve ser considerada (insert/update/delete). Utilizado somente se SQL Server.
@return cInsert, Character, SQL com o insert para a tabela T4R
/*/
METHOD montaInsert(cOperacao) CLASS MRPTrigger
	Local cInsert := ""
	Local cTabT4R := RetSqlName("T4R")
	Local nIndex  := 0
	Local nTotal  := Len(Self:aFields)

	Default cOperacao := ""

	cInsert += " INSERT INTO " + cTabT4R
	cInsert +=            " (T4R_FILIAL,"
	cInsert +=             " T4R_API,"
	cInsert +=             " T4R_STATUS,"
	cInsert +=             " T4R_IDREG,"
	cInsert +=             " T4R_DTENV,"
	cInsert +=             " T4R_HRENV,"
	cInsert +=             " T4R_PROG,"
	cInsert +=             " T4R_MSGRET,"
	cInsert +=             " T4R_DTREP,"
	cInsert +=             " T4R_HRREP,"
	cInsert +=             " T4R_MSGENV,"
	cInsert +=             " T4R_TIPO,"
	cInsert +=             " T4R_DADOS,"
	cInsert +=             " D_E_L_E_T_,"
	cInsert +=             " R_E_C_D_E_L_)"
	If Self:cBanco == "MSSQL"
		cInsert += " SELECT DISTINCT @T4R_FILIAL,"
		cInsert +=        " @T4R_API,"
		cInsert +=        " '" + valorPadrao("T4R_STATUS") + "',"
		If Self:lOnlyIns
			cInsert +=    " REG_PEND.REG_KEY,"
		Else
			cInsert +=    " " + Self:concatKey("REG_PEND") + ","
		EndIf
		cInsert +=        " @T4R_DTENV,"
		cInsert +=        " @T4R_HRENV,"
		cInsert +=        " '" + valorPadrao("T4R_PROG"  ) + "',"
		cInsert +=        " '" + valorPadrao("T4R_MSGRET") + "',"
		cInsert +=        " '" + valorPadrao("T4R_DTREP" ) + "',"
		cInsert +=        " '" + valorPadrao("T4R_HRREP" ) + "',"
		cInsert +=        " NULL,"
		If Self:lOnlyIns
			cInsert += " '3',"
		ElseIf cOperacao == 'insert' .Or. !Self:lCanDelete
			cInsert +=   " '1',"
		ElseIf cOperacao == 'update'
			cInsert +=   " CASE WHEN REG_PEND.D_E_L_E_T_ = '*' THEN '2' ELSE '1' END,"
		Else
			cInsert +=   " '2',"
		EndIf
		If Self:lCriaDados
			cInsert +=   " CONVERT(VARBINARY(MAX)," + Self:SQLconcatDados("REG_PEND") + "),"
		Else
			cInsert +=   " NULL,"
		EndIf
		cInsert +=        " ' ',"
		cInsert +=        " 0"
		
		If Self:lOnlyIns
			cInsert += " FROM (SELECT " + Self:concatKey("INS") + " REG_KEY FROM inserted INS"
			cInsert += " UNION SELECT " + Self:concatKey("DEL") + " REG_KEY FROM deleted DEL) REG_PEND"
			cInsert += " WHERE NOT EXISTS(SELECT 1"
			cInsert +=                    " FROM " + cTabT4R + " T4R"
			cInsert +=                   " WHERE T4R.T4R_FILIAL   = @T4R_FILIAL"
			cInsert +=                     " AND T4R.T4R_API      = @T4R_API"
			cInsert +=                     " AND T4R.T4R_IDREG    = REG_PEND.REG_KEY"
			cInsert +=                     " AND T4R.T4R_IDPRC    = ' '"
			cInsert +=                     " AND T4R.R_E_C_D_E_L_ = 0)"
		Else
			cInsert +=  " FROM " + Iif(cOperacao $ "|insert|update|", "inserted", "deleted") + " REG_PEND"
			cInsert += " WHERE " + Self:concatKey("REG_PEND") + " <> ' '"
			If cOperacao == 'update'
				//Tratativa específica para a tabela de demandas.
				//Não executa a trigger quando for atualizado somente o campo VR_INTMRP
			//	If Self:cAlias == "SVR"
			//		cInsert += " AND NOT EXISTS(SELECT 1"
			//		cInsert +=                  " FROM deleted old"
			//		cInsert +=                 " WHERE old.R_E_C_N_O_ = REG_PEND.R_E_C_N_O_"
			//		cInsert +=                   " AND (old.D_E_L_E_T_ = REG_PEND.D_E_L_E_T_"
			//		cInsert +=                    " OR (old.D_E_L_E_T_ IS NULL AND REG_PEND.D_E_L_E_T_ IS NULL))"

			//		For nIndex := 1 To nTotal
			//			If Self:aFields[nIndex] == "VR_INTMRP"
			//				Loop
			//			EndIf
			//			cInsert += " AND (old." + Self:aFields[nIndex] + " = REG_PEND." + Self:aFields[nIndex]
			//			cInsert +=  " OR (old." + Self:aFields[nIndex] + " IS NULL AND REG_PEND." + Self:aFields[nIndex] + " IS NULL))"
			//		Next nIndex
			//		cInsert +=                ")"
			//	EndIf
			Else
				cInsert += " AND REG_PEND.D_E_L_E_T_ = ' '"
			EndIf
		EndIf
		
	Else
		cInsert +=      " VALUES(vT4R_FILIAL,"
		cInsert +=             " vT4R_API,"
		cInsert +=             " '" + valorPadrao("T4R_STATUS") + "',"
		cInsert +=             " vT4R_IDREG,"
		cInsert +=             " vT4R_DTENV,"
		cInsert +=             " vT4R_HRENV,"
		cInsert +=             " '" + valorPadrao("T4R_PROG"  ) + "',"
		cInsert +=             " '" + valorPadrao("T4R_MSGRET") + "',"
		cInsert +=             " '" + valorPadrao("T4R_DTREP" ) + "',"
		cInsert +=             " '" + valorPadrao("T4R_HRREP" ) + "',"
		cInsert +=             " NULL,"
		cInsert +=             " vT4R_TIPO,"
		cInsert +=             " vT4R_DADOS,"
		cInsert +=             " ' ',"
		cInsert +=             " 0);"
	EndIf

Return cInsert


/*/{Protheus.doc} montaDELInsert
Monta o SQL para realizar INSERT na tabela T4R referente dados com chave ALTERADA que devem ser excluidos no MRP

@type  Method
@author brunno.costa
@since 05/08/2020
@version P12.1.27
@param cOperacao, Character, Operação que deve ser considerada (insert/update/delete). Utilizado somente se SQL Server.
@return cInsert, Character, SQL com o insert para a tabela T4R
/*/
METHOD montaDELInsert(cOperacao) CLASS MRPTrigger
	Local cInsert  := ""
	Local cTabT4R  := RetSqlName("T4R")
	Local cPrefixo := Iif("ORACLE"$Self:cBanco, ":", "")

	If Self:cBanco != "MSSQL"
		cInsert += " IF " + Self:concatKey(cPrefixo + "NEW") + " <> " + Self:concatKey(cPrefixo + "OLD") + " THEN"
	EndIf

	cInsert += " INSERT INTO " + cTabT4R
	cInsert +=            " (T4R_FILIAL,"
	cInsert +=             " T4R_API,"
	cInsert +=             " T4R_STATUS,"
	cInsert +=             " T4R_IDREG,"
	cInsert +=             " T4R_DTENV,"
	cInsert +=             " T4R_HRENV,"
	cInsert +=             " T4R_PROG,"
	cInsert +=             " T4R_MSGRET,"
	cInsert +=             " T4R_DTREP,"
	cInsert +=             " T4R_HRREP,"
	cInsert +=             " T4R_MSGENV,"
	cInsert +=             " T4R_TIPO,"
	cInsert +=             " T4R_DADOS,"
	cInsert +=             " D_E_L_E_T_,"
	cInsert +=             " R_E_C_D_E_L_)"

	If Self:cBanco == "MSSQL"
		cInsert += " SELECT DISTINCT @T4R_FILIAL,"
		cInsert +=        " @T4R_API,"
		cInsert +=        " '" + valorPadrao("T4R_STATUS") + "',"
		cInsert +=        " " + Self:concatKey("deleted")  + ","
		cInsert +=        " @T4R_DTENV,"
		cInsert +=        " @T4R_HRENV,"
		cInsert +=        " '" + valorPadrao("T4R_PROG"  ) + "',"
		cInsert +=        " '" + valorPadrao("T4R_MSGRET") + "',"
		cInsert +=        " '" + valorPadrao("T4R_DTREP" ) + "',"
		cInsert +=        " '" + valorPadrao("T4R_HRREP" ) + "',"
		cInsert +=        " NULL,
		cInsert +=        " '2',"
		cInsert +=        " NULL,"
		cInsert +=        " ' ',"
		cInsert +=        " 0"
		cInsert +=  " FROM " + Iif(cOperacao $ "|insert|update|", "inserted", "deleted") + " REG_PEND"
		cInsert +=      " INNER JOIN deleted"
		cInsert +=        " ON " + Self:concatKey("REG_PEND") + " <> " + Self:concatKey("deleted")
		cInsert +=        " AND REG_PEND.R_E_C_N_O_ = deleted.R_E_C_N_O_ ;"
	Else
		cInsert +=	      " VALUES(vT4R_FILIAL,"
		cInsert +=	             " vT4R_API,"
		cInsert +=	             " '" + valorPadrao("T4R_STATUS") + "',"
		cInsert +=	             " " + Self:concatKey(cPrefixo + "OLD")  + ","
		cInsert +=	             " vT4R_DTENV,"
		cInsert +=	             " vT4R_HRENV,"
		cInsert +=	             " '" + valorPadrao("T4R_PROG"  ) + "',"
		cInsert +=	             " '" + valorPadrao("T4R_MSGRET") + "',"
		cInsert +=	             " '" + valorPadrao("T4R_DTREP" ) + "',"
		cInsert +=	             " '" + valorPadrao("T4R_HRREP" ) + "',"
		cInsert +=	             " NULL,"
		cInsert +=	             " '2',"
		cInsert +=	             " vT4R_DADOS,"
		cInsert +=	             " ' ',"
		cInsert +=	             " 0);"
		cInsert +=     " END IF;"

	EndIf

Return cInsert

/*/{Protheus.doc} insertHWJ
Monta o SQL para realizar o insert na tabela HWJ

@type  Method
@author renan.roeder
@since 20/03/2020
@version P12.1.30
@param cOperacao, Character, Operação que deve ser considerada (insert/update/delete). Utilizado somente se SQL Server.
@return cInsert, Character, SQL com o insert para a tabela T4R
/*/
METHOD insertHWJ(cOperacao) CLASS MRPTrigger
	Local cInsert := ""
	Local cTabHWJ := RetSqlName("HWJ")
	Local nIndex  := 0
	Local nTotal  := Len(Self:aFieldsUpd)

	cInsert +=       " INSERT INTO " + cTabHWJ + "("
	cInsert +=            " HWJ_FILIAL,"
	cInsert +=            " HWJ_PROD,"
	cInsert +=            " HWJ_EVENTO,"
	cInsert +=            " HWJ_ORIGEM,"
	cInsert +=            " D_E_L_E_T_,"
	cInsert +=            " R_E_C_D_E_L_)"

	If Self:cBanco == "MSSQL"
		cInsert += " SELECT"
		cInsert +=   " DISTINCT REG_PEND."+Self:aFieldsNC[1]+","
		cInsert +=            " REG_PEND."+Self:aFieldsNC[2]+","
		If cOperacao == 'insert' .Or. !Self:lCanDelete
			cInsert +=   " '1',"
		ElseIf cOperacao == 'update'
			cInsert +=   " CASE WHEN REG_PEND.D_E_L_E_T_ = '*' THEN '2' ELSE '1' END,"
		Else
			cInsert +=   " '2',"
		EndIf
		cInsert +=            " '"+GetHWJOri(Self:cApiCode)+"',"
		cInsert +=            " ' ',"
		cInsert +=            " 0"
		cInsert += " FROM " + Iif(cOperacao $ "|insert|update|", "inserted", "deleted") + " REG_PEND"
		cInsert += " WHERE REG_PEND."+Self:aFieldsNC[1]+" + REG_PEND."+Self:aFieldsNC[2]+" <> ' '"
		If cOperacao == 'update'
			If nTotal > 0
				cInsert += " AND NOT EXISTS(SELECT 1"
				cInsert +=                  " FROM deleted old"
				cInsert +=                 " WHERE old.R_E_C_N_O_ = REG_PEND.R_E_C_N_O_"
				cInsert +=                   " AND (old.D_E_L_E_T_ = REG_PEND.D_E_L_E_T_"
				cInsert +=                    " OR (old.D_E_L_E_T_ IS NULL AND REG_PEND.D_E_L_E_T_ IS NULL))"

				For nIndex := 1 To nTotal
					cInsert += " AND (old." + Self:aFieldsUpd[nIndex] + " = REG_PEND." + Self:aFieldsUpd[nIndex]
					cInsert +=  " OR (old." + Self:aFieldsUpd[nIndex] + " IS NULL AND REG_PEND." + Self:aFieldsUpd[nIndex] + " IS NULL))"
				Next nIndex
				cInsert +=                ")"
			EndIf
		Else
			cInsert +=   " AND REG_PEND.D_E_L_E_T_ = ' '"
		EndIf
		cInsert +=   " AND NOT EXISTS("
		cInsert +=     " SELECT"
		cInsert +=       " 1"
		cInsert +=     " FROM"
		cInsert +=     " "+cTabHWJ+" HWJ"
		cInsert +=     " WHERE HWJ.HWJ_FILIAL = REG_PEND."+Self:aFieldsNC[1]+""
		cInsert +=       " AND HWJ.HWJ_PROD = REG_PEND."+Self:aFieldsNC[2]+");"

	Else
		cInsert +=         " VALUES ("
		cInsert +=           " vHWJ_FILIAL,"
		cInsert +=           " vHWJ_PROD,"
		cInsert +=           " vHWJ_EVENTO,"
		cInsert +=           " vHWJ_ORIGEM,"
		cInsert +=           " ' ',"
		cInsert +=           " 0"
		cInsert +=           " );"
	EndIf

Return cInsert

/*/{Protheus.doc} SQLconcatDados
Monta a concatenação dos campos para formar o conteúdo JSON do campo T4R_DADOS

@type  Method
@author lucas.franca
@since 04/09/2019
@version P12.1.28
@param cPrefix, Character, Prefixo que será utilizado nos campos.
@return cConcat, Character, SQL com os campos concatenados.
/*/
Method SQLconcatDados(cPrefix) CLASS MRPTrigger
	Local cConcat  := "'{"
	Local cTipo    := ""
	Local cCampo   := ""
	Local nTamanho := 0
	Local nIndex   := 0
	Local nTotal   := Len(Self:aFields)

	For nIndex := 1 To nTotal
		If nIndex > 1
			cConcat += ","
		EndIf
		cTipo    := Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_TYPE]
		nTamanho := Self:oFieldsProp[Self:aFields[nIndex]][FIELDS_PROPERTY_POS_SIZE]

		If Empty(cPrefix)
			cCampo := Self:aFields[nIndex]
		Else
			cCampo := cPrefix + "." + Self:aFields[nIndex]
		EndIf

		cConcat += ASPAS + Self:aFields[nIndex] + ASPAS + ":"
		If cTipo $ "|C|D|L|"
			cConcat += ASPAS + "'+"
			If cTipo == "C"
				cConcat += "RTRIM(" + cCampo + ")"
			Else
				cConcat += cCampo
			EndIf
			cConcat += "+'"
			cConcat += ASPAS
		ElseIf cTipo == "M"
			cConcat += "'+ CASE WHEN COALESCE(" + cCampo + ",'') = '' THEN 'false' ELSE 'true' END+'"
		Else //Numérico
			cConcat += "'+ CAST(" + cCampo + " AS VARCHAR(" + cValToChar(nTamanho) + "))+'"
		EndIf

	Next nIndex

	cConcat += "}'"
Return cConcat

/*/{Protheus.doc} getSqlTrigger
Retorna o SQL que deve ser executado para instalar a Trigger.

@author lucas.franca
@since 30/07/2019
@version P12.1.28
@return Self:cSqlTrigger, Character, comando SQL que irá criar a trigger no banco de dados.
/*/
METHOD getSqlTrigger() Class MRPTrigger
Return Self:cSqlTrigger

/*/{Protheus.doc} getError
Retorna a mensagem de erro caso exista.

@author lucas.franca
@since 31/07/2019
@version P12.1.28
@return Self:cError, Character, Mensagem de erro ocorrida.
/*/
METHOD getError() Class MRPTrigger
Return Self:cError

/*/{Protheus.doc} valorPadrao
Retorna o valor padrão para um campo da tabela T4R

@type  Static Function
@author lucas.franca
@since 31/07/2019
@version P12.1.28
@param cFieldT4R, Character, Campo da tabela T4R para recuperar valor default.
@return cValue, Character, Valor default para o campo recebido
/*/
Static Function valorPadrao(cFieldT4R)
	Local cValue   := ""
	Local nTamanho := GetSx3Cache(cFieldT4R, "X3_TAMANHO")

	Do Case
		Case cFieldT4R == "T4R_STATUS"
			cValue := PadR("3", nTamanho)
		Case cFieldT4R $ "|T4R_DTREP|T4R_MSGRET|T4R_HRREP"
			cValue := Space(nTamanho)
		Case cFieldT4R == "T4R_PROG"
			cValue := PadR("TRIGGER", nTamanho)
	EndCase
Return cValue

/*/{Protheus.doc} T4RVars
Define variáveis padrão da tabela T4R

@type  Static Function
@author lucas.franca
@since 02/08/2019
@version P12.1.28
@param cBanco, Character, Banco de dados utilizado.
@return cDefT4R, Character, Definição das variáveis padrão da tabela T4R
/*/
Static Function T4RVars(cBanco)
	Local cDefT4R := ""
	Local cTabT4R := RetSqlName("T4R")

	If cBanco == "MSSQL"
		cDefT4R :=  "@T4R_FILIAL VARCHAR(" + cValToChar(FwSizeFilial()) + "),"
		cDefT4R += " @T4R_API    VARCHAR(" + cValToChar(GetSx3Cache("T4R_API"  , "X3_TAMANHO")) + "),"
		cDefT4R += " @T4R_DTENV  VARCHAR(08),"
		cDefT4R += " @T4R_HRENV  VARCHAR(08),"
	Else
		//Bancos POSTGRES e ORACLE
		cDefT4R :=  "vT4R_FILIAL " + cTabT4R + ".T4R_FILIAL%TYPE;"
		cDefT4R += " vT4R_API    " + cTabT4R + ".T4R_API%TYPE;"
		cDefT4R += " vT4R_IDREG  " + cTabT4R + ".T4R_IDREG%TYPE;"
		cDefT4R += " vT4R_TIPO   " + cTabT4R + ".T4R_TIPO%TYPE;"
		cDefT4R += " vT4R_DADOS  " + cTabT4R + ".T4R_DADOS%TYPE;"
		cDefT4R += " vT4R_DTENV  " + cTabT4R + ".T4R_DTENV%TYPE;"
		cDefT4R += " vT4R_HRENV  " + cTabT4R + ".T4R_HRENV%TYPE;"
	EndIf
Return cDefT4R

/*/{Protheus.doc} HWJVars
Define variáveis padrão da tabela HWJ

@type  Static Function
@author renan.roeder
@since 17/03/2020
@version P12.1.30
@param cBanco, Character, Banco de dados utilizado.
@return cDefT4R, Character, Definição das variáveis padrão da tabela T4R
/*/
Static Function HWJVars(cBanco)
	Local cDefHWJ := ""
	Local cTabHWJ := RetSqlName("HWJ")

	If cBanco != "MSSQL"/*
		cDefHWJ += " @HWJ_FILIAL VARCHAR(" + cValToChar(GetSx3Cache("HWJ_FILIAL", "X3_TAMANHO")) + "),"
		cDefHWJ += " @HWJ_PROD   VARCHAR(" + cValToChar(GetSx3Cache("HWJ_PROD"  , "X3_TAMANHO")) + "),"
		cDefHWJ += " @HWJ_EVENTO VARCHAR(01),"
		cDefHWJ += " @HWJ_ORIGEM VARCHAR(01),"
	Else*/
		//Bancos POSTGRES e ORACLE
		cDefHWJ := " vHWJ_FILIAL " + cTabHWJ + ".HWJ_FILIAL%TYPE;"
		cDefHWJ += " vHWJ_PROD   " + cTabHWJ + ".HWJ_PROD%TYPE;"
		cDefHWJ += " vHWJ_EVENTO " + cTabHWJ + ".HWJ_EVENTO%TYPE;"
		cDefHWJ += " vHWJ_ORIGEM " + cTabHWJ + ".HWJ_ORIGEM%TYPE;"
	EndIf
Return cDefHWJ

/*/{Protheus.doc} GetMascara
Retorna a máscara para a coluna

@type  Static Function
@author marcelo.neumann
@since 27/09/2019
@version P12.1.28
@param oSelf , Object , Referência da classe MRPTrigger
@param nIndex, Numeric, Posição atual do oSelf:aFields
@return cMascara, Character, Máscara para o campo
/*/
Static Function GetMascara(oSelf, nIndex)

	Local cDecimal := ""
	Local cInteiro := ""
	Local cMascara := ""
	Local nInteiro := 0

	If oSelf:oFieldsProp[oSelf:aFields[nIndex]][FIELDS_PROPERTY_POS_DECIMAL] > 0
		nInteiro := oSelf:oFieldsProp[oSelf:aFields[nIndex]][FIELDS_PROPERTY_POS_SIZE] - ;
		            oSelf:oFieldsProp[oSelf:aFields[nIndex]][FIELDS_PROPERTY_POS_DECIMAL] - 1
		cInteiro := PadL("0", nInteiro, "9")
		cDecimal := PadR("0", oSelf:oFieldsProp[oSelf:aFields[nIndex]][FIELDS_PROPERTY_POS_DECIMAL], "0")

		cMascara := ", '" + cInteiro + "." + cDecimal + "'"
	EndIf

Return cMascara

/*/{Protheus.doc} GetHWJOri
Retorna a máscara para a coluna

@type  Static Function
@author marcelo.neumann
@since 27/09/2019
@version P12.1.28
@param cApi , Character , Nome da API
@return cHWJOri, Character, Código da API conforme o campo HWJ_ORIGEM
/*/
Static Function GetHWJOri(cApi)
	Local cHWJOri := ""

	//Origem da alteração (1-Produtos; 2-Demandas ; 3-Saldos ; 4-OP; 5-SC; 6-Estrutura; 7-Versão da Produção; 8-SBZ; 9-Empenhos; A-Operações x Componente)

	Do Case
		Case cApi == "MRPPRODUCT"
			cHWJOri := "1"
		Case cApi == "MRPDEMANDS"
			cHWJOri := "2"
		Case cApi == "MRPSTOCKBALANCE"
			cHWJOri := "3"
		Case cApi == "MRPPRODUCTIONORDERS"
			cHWJOri := "4"
		Case cApi == "MRPPURCHASEREQUEST" //MRPPURCHASEORDER ??
			cHWJOri := "5"
		Case cApi == "MRPBILLOFMATERIAL"
			cHWJOri := "6"
		Case cApi == "MRPPRODUCTIONVERSION"
			cHWJOri := "7"
		Case cApi == "MRPPRODUCTINDICATOR"
			cHWJOri := "8"
		Case cApi == "MRPALLOCATIONS"
			cHWJOri := "9"
		Case cApi == "MRPBOMROUTING"
			cHWJOri := "A"
	EndCase

Return cHWJOri
