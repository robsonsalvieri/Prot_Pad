#INCLUDE "Totvs.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "InsightDefs.ch"

Static __nBranchSize := FWSizeFilial()

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PINSMakeTemp
Função responsavel por criar uma tabela temporária para guardar os alerts separados fora do JSON

@param cAliasTabTmp, character, alias tabela temporaria.
@param cInsightName, character, insight selecionado no front. 
@param cModule, character, modulo do protheus.
@param aFields, character, campos da tabela temporaria.
@param cQryBranch, character, filiais em que usuário tem acesso.

@return oTempTable, object, objeto da tabela temporaria

@author Raphael Santana Ferreira
@since 25/07/2024
/*/
//---------------------------------------------------------------------------------------------
Function PINSMakeTemp(cAliasTabTmp, cInsightName, cModule, aFields, cQryBranch)
	Local oTempTable    as Object
	Local oBulk			as Object
	Local oInsight		as Object
	Local aStruBulk		:= {} as Array
	Local aLinTab		:= {} as Array
	Local aStruCPO      := {} as Array
	Local aArea 		:= {} as Array
	Local aAreaSB1 		:= {} as Array
	Local aAreaSB2 		:= {} as Array
	Local cNextAlias	:= "" as Character
	Local cTableName	:= "" as Character
	Local nX			:= 0 as Numeric

	Default cQryBranch	:= ""

	aArea	 := GetArea()
	aAreaSB1 := SB1->( GetArea() )
	aAreaSB2 := SB2->( GetArea() )

	// Instancia o objeto do insight - usado para consultar os pontos de extensao
	// (BuildContractLine) declarados em PinsConfig
	oInsight := pinsObject( cInsightName )

	//Alimenta o array da estrutura da tabela temporária
	For nX := 1 To Len( aFields )
		Aadd( aStruCPO, { aFields[nX][2][1], aFields[nX][2][2], aFields[nX][2][3], aFields[nX][2][4] } )
	Next nX

	// tabela temporária
	oTempTable	:= totvs.framework.database.temporary.SharedTable():New( cAliasTabTmp )
	oTempTable:SetFields( aStruCPO )
	oTempTable:Create()
	cTableName := oTempTable:GetTableNameForTCFunctions()

	//Copia a estrutura de campos da tabela temporária
	aStruBulk := ( cAliasTabTmp )->( DBStruct() )

	//Instancia o objeto FwBulk e seta as propriedades do objeto
	oBulk := FwBulk():New( cTableName )
	oBulk:SetFields( aStruBulk )

	DbSelectArea( "SB1" )
	SB1->( DbSetOrder( 1 ) )	// FILIAL + CODIGO PRODUTO
	DbSelectArea( "SB2" )
	SB2->( DbSetOrder( 1 ) )	// FILIAL + CODIGO PRODUTO

	//Função que faz a query de busca de registros na tabela I19
	//gera os dados no alias passado por parâmetro
	cNextAlias := PINSGetAlerts( cInsightName, cModule, cQryBranch, aFields )

	While ( cNextAlias )->( !Eof() )

		// BuildContractLine delega para PINSAlertLine quando o insight nao tem
		// override (stock_out, demand_forecast) - comportamento inalterado.
		// sales_recommendation sobrescreve com a montagem completa das 33 colunas.
		aLinTab := oInsight:BuildContractLine( /*oJson*/, aFields, .F., cNextAlias )

		If Len( aLinTab ) == Len( aFields )
			oBulk:AddData( aLinTab )
		EndIf

		( cNextAlias )->( DbSkip() )
	EndDo
	( cNextAlias )->( DbCloseArea() )

	oBulk:Close()
	oBulk:Destroy()
	oBulk := nil

	RestArea( aArea )
	RestArea( aAreaSB1 )
	RestArea( aAreaSB2 )
	Asize( aArea, 0 )
	Asize( aAreaSB1, 0 )
	Asize( aAreaSB2, 0 )
	aArea := nil
	aAreaSB1 := nil
	aAreaSB2 := nil

	FreeObj( oInsight )
	FWFreeArray( aStruBulk )
	FWFreeArray( aLinTab )
	FWFreeArray( aStruCPO )
Return oTempTable

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PINSGetAlerts
Função que faz o select na tabela I21 retornando registros do insight recebido
como parâmetro.

@param cInsightName, Charactere, contém a string referente ao tipo de insight será filtrado na query
@param cModule, Charactere, contém a string referente ao módulo que será filtrado na query
@param cQryBranch, Character, filiais em que usuário tem acesso
@param aFields, Array, campos da struct da classe do insight

@return cNextAlias, Charactere, alias da tabela criada.

@author Raphael Santana Ferreira
@since 25/07/2024
/*/
//---------------------------------------------------------------------------------------------
Function PINSGetAlerts( cInsightName, cModule, cQryBranch, aFields )
	Local oPrepare			as Object
	Local oInsight			as Object
	Local cQuery			:= "" as Character
	Local cNextAlias		:= "" as Character
	Local cFieldsSelect		:= "" as Character
	Local cPayloadExpr		:= "" as Character
	Local cDatabase   		:= "" as Character
	Local cPhysicalFields	:= "" as Character
	Local cExtraFilter		:= "" as Character
	Local aAux				:= {} as Array
	Local aPhysical			:= {} as Array
	Local aExtraFilters		:= {} as Array
	Local nBind				:= 0 as Numeric
	Local nI				:= 0 as Numeric
	Local lUseBranch		:= .F. as Logical
	Local lStockOut			:= .F. as Logical

	Default cQryBranch := ''  

	// tipo de banco de dados para montar expressões SQL
	cDatabase	:= Upper(TcGetDb())

	If ( lUseBranch := !Empty( cQryBranch ) )
		// Trata as branchs para passar o conteúdo correto no método SetIn da FWExecStatement
		cQryBranch := StrTran( cQryBranch, ", ", "," )
		cQryBranch := StrTran( cQryBranch, "'", "" )
		aAux := StrTokArr( cQryBranch, ',' )
	EndIf

	// Consulta os pontos de extensao do insight (PinsConfig):
	// colunas fisicas adicionais e filtros extras na query de leitura.
	oInsight 	  := pinsObject( cInsightName )
	aPhysical	  := oInsight:GetPhysicalFields()
	aExtraFilters := oInsight:GetExtraFilters()
	FreeObj( oInsight )

	// Monta a expressao SELECT para extrair valores do JSON conforme tipo de banco de dados
	cFieldsSelect := GetSelectJSON( aFields, cDatabase, aPhysical )

	// Concatena as colunas fisicas na subquery interna
	// (expressao SQL, ex.: I21_STATUS, com alias em upper, ex.: MSG_STATUS)
	For nI := 1 To Len( aPhysical )
		cPhysicalFields += "," + aPhysical[ nI ][ 1 ] + " " + Upper( aPhysical[ nI ][ 2 ] )
	Next nI

	// Monta os predicados extras de filtro (fora do WHERE padrao)
	For nI := 1 To Len( aExtraFilters )
		cExtraFilter += " AND " + aExtraFilters[ nI ][ 1 ]
	Next nI

	// Monta expressao de conversao do campo memo I21_PAYLOD para JSON conforme banco
	cPayloadExpr := GetPayloadExpr( cDatabase )
		
	If ( lStockOut := cInsightName == 'stock_out' )

		cQuery := " SELECT "+ cFieldsSelect +" FROM"
		cQuery += " (SELECT"
		cQuery += " ROW_NUMBER() OVER( PARTITION BY I21_KEY ORDER BY I21.R_E_C_N_O_ DESC ) LINHA,"
    	cQuery += " "+ cPayloadExpr
		cQuery += " "+ cPhysicalFields
		cQuery += " FROM "+ RetSqlName("I21") +" I21"
		cQuery += " INNER JOIN "+ RetSqlName("I19") +" I19"
		cQuery += " ON I19.I19_UIDMSG = I21.I21_UIDMSG"
		cQuery += " AND I19.I19_INSIGT = ?"
		cQuery += " AND I19.I19_MESSID <> ?"
		cQuery += " AND I19.I19_DTRECV >= ?"
		cQuery += " AND I19.D_E_L_E_T_ = ?"
		cQuery += " WHERE I21.I21_MODULO = ?"
		cQuery += " AND I21.I21_INSIGT = ?"
		If lUseBranch
			cQuery += " AND I21.I21_BRANCH IN ( ? )"
		EndIf
		cQuery += " AND I21.D_E_L_E_T_ = ?"
		cQuery += cExtraFilter
		cQuery += " ) AUX WHERE LINHA = 1"

	Else
	
		cQuery := " SELECT "+ cFieldsSelect +" FROM"
		cQuery += " (SELECT"
		cQuery += " "+ cPayloadExpr
		cQuery += " "+ cPhysicalFields
		cQuery += " FROM " + RetSqlName("I21") + " I21"
		cQuery += " WHERE I21_UIDMSG IN"
		cQuery += " (SELECT I19_UIDMSG FROM " + RetSqlName("I19") + " I19"
		cQuery += " WHERE I19.I19_MESSID ="
		cQuery += "	(SELECT I19_MESSID FROM"
		cQuery += "	(SELECT ROW_NUMBER() OVER( ORDER BY I191.R_E_C_N_O_ DESC ) LINHA, I19_MESSID, R_E_C_N_O_"
		cQuery += "	FROM " + RetSqlName("I19") + " I191"
		cQuery += "	WHERE I191.I19_INSIGT = ?"
		cQuery += "	AND I191.I19_MESSID <> ?"
		cQuery += "	AND I191.D_E_L_E_T_ = ? ) TMP1"
		cQuery += "	WHERE LINHA = 1)"
		cQuery += " AND I19.D_E_L_E_T_ = ? )"
		cQuery += " AND I21.I21_MODULO = ?"
		cQuery += " AND I21.I21_INSIGT = ?"
		If lUseBranch
			cQuery += " AND I21.I21_BRANCH IN ( ? )"
		EndIf
		cQuery += " AND I21.D_E_L_E_T_ = ?"
		cQuery += cExtraFilter
		cQuery += ") TMP2"

	EndIf

	oPrepare := FwExecStatement():New( ChangeQuery(cQuery) )
	oPrepare:setString( ++nBind, cInsightName )
	oPrepare:setString( ++nBind, ' ' )
	If lStockOut
		oPrepare:setString( ++nBind, Transform( DTOS( Date() - Dow( Date() - 1 ) - 14 ), "@R ####-##-##" ) )
	Else
		oPrepare:setString( ++nBind, ' ' )
	EndIf
	oPrepare:setString( ++nBind, ' ' )
	oPrepare:setString( ++nBind, cModule )
	oPrepare:setString( ++nBind, cInsightName )
	If lUseBranch
		oPrepare:setIn( ++nBind, aAux )
	EndIf
	oPrepare:setString( ++nBind, ' ' )
	// Binds dos predicados extras (GetExtraFilters)
	For nI := 1 To Len( aExtraFilters )
		oPrepare:setString( ++nBind, aExtraFilters[ nI ][ 2 ] )
	Next nI

	cNextAlias := oPrepare:OpenAlias()

	oPrepare:Destroy()
	oPrepare := nil

	FWFreeArray( aAux )
	FWFreeArray( aPhysical )
	FWFreeArray( aExtraFilters )

Return cNextAlias

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PINSAlertLine
Retorna um array com os dados da linha do Json de alert enviada por parâmetro alert enviado 
pelo smartlink

@param oJson, objeto, contém a linha posicionada no array de Json de alerts
@param aFields, array, contém um array com os dados de campos referente a tabela temporária e 
					   propriedades do json 
@param lMock, boolean, Indica se está sendo chamada por mock.
@param cNextAlias, character, query em memória com os valores do I21_PAYLOD.

@return aRet, array, dados da mensagem adicionados em array.

@author Raphael Santana Ferreira
@since 25/07/2024
/*/
//---------------------------------------------------------------------------------------------
Function PINSAlertLine( oJson, aFields, lMock, cNextAlias )
	Local aRet          := {} as Array
	Local aAux			:= {} as Array
	Local cGraphPoints  := "" as Character
	Local cField 		:= "" as Character
	Local cValType 		:= "" as Character
	Local cFieldType	:= "" as Character
	Local cBranch		:= "" as Character
	Local cProduct		:= "" as Character
	Local cFieldAux		:= "" as Character
	Local cAuxVal		:= "" as Character
	Local nI            := 0 as Numeric
	Local lAdd 			:= .T. as Logical
	Local lAddEmpty		:= .T. as Logical
	Local xAuxValue		as Any

	Default lMock := .F.
	Default cNextAlias := ""

	If lMock

		For nI := 1 To Len(aFields)
			xAuxValue	:= NIL
			cField		:= aFields[nI][1]
			cValType	:= ValType( oJson[ cField ] )
			cFieldType	:= aFields[ nI ][ 2 ][ 2 ]
			lAdd		:= aFields[ nI ][ 2 ][ 1 ] != 'company_group'

			If lAdd
				If cValType == "A"
						
					cGraphPoints := ""

					aeval(oJson[ cField ], {|i| cGraphPoints += i:ToJson() + "," })
					cGraphPoints := Left(cGraphPoints, Len(cGraphPoints) - 1)

					Aadd( aRet, cGraphPoints )
				ElseIf cValType == "C"
					If '|' $ oJson[ cField ] .And. Len( aFields[ nI ] ) >= STRUCT_COMPOSITE .And. aFields[ nI ][ STRUCT_COMPOSITE ] //( "code" $ cField .Or. "type" $ cField )
						aAux := StrTokArr2( oJson[ cField ], '|', .T. )
						If Len( aFields[ nI ][ 2 ] ) >= 6
							Aadd( aRet, RTrim( DecodeUTF8( aAux[ aFields[ nI ][ 2 ][ 6 ] ] ) ) )
						Else
							Aadd( aRet, RTrim( DecodeUTF8( aAux[ Len( aAux ) ] ) ) )
						EndIf
					Else
						Aadd( aRet, AllTrim( DecodeUTF8( oJson[ cField ] ) ) )
					EndIf
				ElseIf cValType == "N"
					Aadd( aRet, Round( oJson[ cField ], aFields[ nI ][ 2 ][ 4 ] ) )
				Else
					If !Empty( cField )
						If cFieldType == "C"
							xAuxValue := ""
						ElseIf cFieldType == "N"
							xAuxValue := 0
						EndIf

						Aadd( aRet, xAuxValue )							
					Else
						lAddEmpty := .T.

						If aFields[ nI ][ 5 ] == STRUCT_INVISIBLE
							// campos de chave composta, ocultos no front
							If Len( aFields[ nI ][ 2 ] ) >= 5
								Aadd( aRet, oJson[ aFields[ nI ][ 2 ][ 5 ] ] )
								lAddEmpty := .F.
							EndIf
						EndIf

						If lAddEmpty
							Aadd( aRet, "" )
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI
	
	Else

		If ( ( cNextAlias )->( FieldPos( "PRODCODE" ) ) > 0 ) .And. ( '|' $ ( cNextAlias )->( FieldGet( FieldPos( "PRODCODE" ) ) ) )

			aAux		:= StrTokArr2( ( cNextAlias )->( FieldGet( FieldPos( "PRODCODE" ) ) ), '|', .T. )
			cBranch		:= PadR( aAux[ 1 ], __nBranchSize )
			cProduct	:= AllTrim( aAux[ 2 ] )

			If SB1->( MsSeek( FWxFilial( "SB1", cBranch ) + cProduct ) )

				aRet := {}

				//Monta o array de dados na mesma ordem dos campos definidos em aFields/aStruBulk (SetFields)
				For nI := 1 To Len( aFields )

					cFieldAux := ""
					xAuxValue := Nil
					// Identifica o nome do campo na tabela temporaria
					cField := aFields[ nI ][ 2 ][ 1 ]

					// Obtem o valor bruto do alias
					xAuxValue := AllTrim( ( cNextAlias )->( FieldGet( FieldPos( Upper( cField ) ) ) ) )

					// Tratamento de campos compostos (chave com separador '|')
					If Len( aFields[ nI ] ) >= STRUCT_COMPOSITE .And. aFields[ nI ][ STRUCT_COMPOSITE ]

						If Len( aFields[ nI ][ 2 ] ) >= 6
							// [2][5] contem o nome do campo formador da chave composta
							cFieldAux := aFields[ nI ][ 2 ][ 5 ]

							If aFields[ nI ][ 5 ] == STRUCT_INVISIBLE
								// Chave composta oculta no front - utiliza o valor inteiro do campo referencia
								xAuxValue := AllTrim( DecodeUTF8( ( cNextAlias )->( FieldGet( FieldPos( Upper( cFieldAux ) ) ) ) ) )
							Else
								// Obtem o valor do campo referencia para extrair a posicao da chave composta
								cAuxVal := AllTrim( ( cNextAlias )->( FieldGet( FieldPos( Upper( cFieldAux ) ) ) ) )
								If '|' $ cAuxVal
									aAux := StrTokArr2( cAuxVal, '|', .T. )
									xAuxValue := RTrim( DecodeUTF8( aAux[ aFields[ nI ][ 2 ][ 6 ] ] ) )
									FWFreeArray( aAux )
								EndIf
							EndIf
						Else
							// Nao tem posicao definida em [2][6] - usa a ultima posicao do array
							If '|' $ xAuxValue
								aAux := StrTokArr2( xAuxValue, '|', .T. )
								xAuxValue := RTrim( DecodeUTF8( aAux[ Len( aAux ) ] ) )
								FWFreeArray( aAux )
							EndIf
						EndIf

					ElseIf cField == "grphPt"
						// Campo Memo (grphPt) - remove colchetes de array JSON
						xAuxValue := StrTran( xAuxValue, "[", "" )
						xAuxValue := StrTran( xAuxValue, "]", "" )

					ElseIf aFields[ nI ][ 2 ][ 2 ] == "N"
						// ajusta arredondamentos em numericos
						xAuxValue := Round( Val( xAuxValue ), aFields[ nI ][ 2 ][ 4 ] )

					Else

						xAuxValue := RTrim( DecodeUTF8( xAuxValue ) )

					EndIf

					Aadd( aRet, xAuxValue )
				Next nI
			EndIf
		EndIf
	EndIf

	FWFreeArray( aAux )
Return aRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PINSMakePage
Função que gera a query de select na tabela temporária
Retorna um objeto FWPreparedStatement com a query ordenada, paginada e com os filtros setada no objeto

@param cTmpAlias, character, tabela temporária
@param cWhere, character, condição de where
@param cOrder, character, ordernação da query
@param cOrderSort, character, ordernação do campo 
@param cCodUsr, character, código do usuário
@param aCpoTab, array, array com campos da tabela 

@return array

@author Raphael Santana Ferreira
@since 25/07/2024

/*/
//---------------------------------------------------------------------------------------------
Function PINSMakePage(cTmpAlias, cWhere, cOrder, cOrderSort, cCodUsr, aCpoTab)

	Local oPrepare    as Object
	Local cQuery      as Character
	Local cTreatQuery as Character
	Local cOrderTab   as Character
	Local aCpoMemo    as Array
	Local nPosOrder   as Numeric

	oPrepare    := Nil
	cQuery      := ""
	cTreatQuery := ""
	cOrderTab   := "R_E_C_N_O_"
	aCpoMemo    := {}
	nPosOrder   := 0

	//Tratativa para pegar o nome do campo na tabela para definir o Order By
	If !Empty(cOrder)
		nPosOrder := aScan(aCpoTab,{|x| AllTrim(x[1]) == Alltrim(cOrder)})
		If nPosOrder > 0
			cOrderTab := aCpoTab[nPosOrder][2][1] + " " + cOrderSort
		EndIf
	EndIf

	cQuery := "SELECT R_E_C_N_O_"
	cQuery += " FROM ("
	cQuery += " SELECT ROW_NUMBER() OVER( ORDER BY " + cOrderTab + ") LINE_NUMBER, R_E_C_N_O_"

	cQuery += " FROM " + cTmpAlias

	cQuery += cWhere

	cQuery += " ) "
	cQuery += " TABLE_AUX WHERE LINE_NUMBER BETWEEN ? AND ? "

	cTreatQuery := ChangeQuery(cQuery)

	If !Empty(cTreatQuery)
		oPrepare := FWPreparedStatement():New(cTreatQuery)
	EndIf

Return oPrepare

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PINSMakeWhere
Função que gera a query de select na tabela temporária
Retorna um objeto FWPreparedStatement com a query ordenada, paginada e com os filtros setada no objeto

@param aCpoTab, array, contém a configuração dos campos da tabela temporária
@param cCondition, Character, contém a condição que será inserida no select da tabela temporária
@param cQryBranch, Character, contám as filiais que o usuário pode acessar
@param cFilterByField, Character, contám os filtros provenientes dos combos

@return caracter, condição de where que deve ser utilizada na consulta.

@author Raphael Santana Ferreira
@since 25/07/2024
/*/
//---------------------------------------------------------------------------------------------
Function PINSMakeWhere(aCpoTab, cCondition, cQryBranch, cFilterByField )
	Local oJsonTmp as Json
	Local cWhere := "" as Character
	Local cAux := "" as Character
	Local aCpoWhere := {} as Array
	Local nI := 0 as Numeric
	Local nJ := 0 as Numeric

	Default aCpoTab := {}
	Default cCondition := "" 
	Default cQryBranch := ""
	Default cFilterByField := ""

	aEval(aCpoTab, {|i| IIf(i[3], aadd(aCpoWhere, i[2][1]), ) })

	If Len(aCpoWhere) > 0 .AND. !Empty(cCondition)
		cWhere += " ( "
		For nI:=1 To Len(aCpoWhere)
			If nI > 1
				cWhere += " OR "
			EndIf
			cWhere += " " + aCpoWhere[nI] + " LIKE '%" + cCondition + "%'"
		Next nI
		cWhere += " ) "
	EndIf

	If !Empty(cQryBranch)
		If !Empty(cWhere)
			cWhere += " AND "
		EndIf

		cWhere += " branch IN (" + cQryBranch + ")"
	EndIf

	// constroi a condição de Where provenientes dos combos.
	If !Empty( cfilterByField )
		oJsonTmp := JsonObject():new()
		oJsonTmp:FromJson( cFilterByField )

		For nI := 1 to len( oJsonTmp )
			cAux := ""
			For nJ := 1 to len( oJsonTmp[ nI ][ "items" ] )
				cAux += "'" + oJsonTmp[ nI ][ "items" ][ nJ ] + "',"
			Next nJ
			cAux := Left( cAux, Len( cAux ) - 1 )

			If !Empty( cWhere )
				cWhere += " AND "
			EndIf
			cWhere += oJsonTmp[ nI ][ "field" ] + ' IN (' + cAux + ') '
		Next nI
	EndIf

	If !Empty( cWhere )
		cWhere := " WHERE " + cWhere
	EndIf

	FreeObj( oJsonTmp )
	FWFreeArray( aCpoWhere )
Return cWhere

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PINSRegCnt
Função que valida se a tabela temporária tem registros

@param cTabTmp, Character, contém o nome real da tabela temporária no banco de dados

@return nRet, numeric, quantidade de registros.

@author Raphael Santana Ferreira
@since 25/07/2024
/*/
//---------------------------------------------------------------------------------------------
Function PINSRegCnt( cTabTmp )

	Local nRet := 0  		as Numeric
	Local cQuery := ""  	as Character
	Local cNextAlias := ""	as Character
	Local aArea := {}		as Array

	aArea  := GetArea()
	cQuery := "SELECT COUNT(R_E_C_N_O_) QTD_REC FROM " + cTabTmp

	cNextAlias := MPSysOpenQuery( ChangeQuery(cQuery) )

	If (cNextAlias)->(!Eof())
		nRet := (cNextAlias)->QTD_REC
	EndIf

	(cNextAlias)->(DbCloseArea())

	RestArea(aArea)

Return nRet

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PinsMakeMock
Função que gera os dados de mock, com base no parâmetro cTypeMock, e popula a 
tabela temporária com dados de mock

@param cTabTmp, Character, contém o nome real da tabela temporária no banco de dados
@param cInsightName, Character, contém o nome do insight para o qual será gerado o mock
@param aFields, array, array com os propridades do json/nome dos campos tabela temporária

@author Raphael Santana Ferreira
@since 18/10/2024
/*/
//---------------------------------------------------------------------------------------------
Function PinsMakeMock( cTabTmp, cInsightName, aFields )
	Local oBulk     as Object
	Local oJson     as Object
	Local oInsight  as Object
	Local cMock		:= "" as Character
	Local cPropJs	:= "" as Character
	Local nX		:= 0  as Numeric
	Local aLinTab	:= {} as Array
	Local aStruCPO	:= {} as Array
	Local aArea 	:= {} as Array
	Local aAreaSB1 	:= {} as Array
	Local aAreaSB2 	:= {} as Array

	aArea    := GetArea()
	aAreaSB1 := SB1->( GetArea() )
	aAreaSB2 := SB2->( GetArea() )

	oInsight := pinsObject( cInsightName )
	
	//Alimenta o array da estrutura da tabela temporária
	For nX := 1 To Len( aFields )
		Aadd( aStruCPO, { aFields[nX][2][1], aFields[nX][2][2], aFields[nX][2][3], aFields[nX][2][4] } )
	Next nX

	//Instancia o objeto FwBulk e seta as propriedades do objeto
	oBulk := FwBulk():New( cTabTmp )
	oBulk:SetFields( aStruCPO )

	DbSelectArea( "SB1" )
	SB1->( DbSetOrder( 1 ) )	// FILIAL + CODIGO PRODUTO
	DbSelectArea( "SB2" )
	SB2->( DbSetOrder( 1 ) )	// FILIAL + CODIGO PRODUTO

	cMock	:= PinsTreatMock( cInsightName )
	oJson 	:= JsonObject():New()
	oJson:FromJson( cMock )

	cPropJs := "alerts"
	If cInsightName == "sales_recommendation"
		cPropJs := "salesMock"
	EndIf

	If oJson:HasProperty( cPropJs ) .And. ValType(oJson[ cPropJs ]) == "A"
		For nX := 1 To Len(oJson[ cPropJs ])
				
			// BuildContractLine delega para PINSAlertLine quando o insight nao tem
			// override (stock_out, demand_forecast) - comportamento inalterado.
			// sales_recommendation sobrescreve com a montagem completa das 33 colunas.
			aLinTab := oInsight:BuildContractLine( oJson[ cPropJs ][nX], aFields, .T., /*cNextAlias*/ )
			
			If Len( aLinTab ) == Len( aFields )
				oBulk:AddData(aLinTab)	
			EndIf
		Next nX
	EndIf

	oBulk:Close()
	oBulk:Destroy()
	oBulk := nil

	RestArea( aArea )
	RestArea( aAreaSB1 )
	RestArea( aAreaSB2 )
	Asize( aArea, 0 )
	Asize( aAreaSB1, 0 )
	Asize( aAreaSB2, 0 )
	aArea := nil
	aAreaSB1 := nil
	aAreaSB2 := nil

	FreeObj( oJson )
	FreeObj( oInsight )
	FWFreeArray( aLinTab )
	FWFreeArray( aStruCPO )
Return

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PINSDebugFields
Função usada para verificar se o ambiente é de testes para criar a estrutura de campos da tabela 
temporária com tamanho default em campos que vem do Protheus


@param aStruCPO, Character, contém um array com a estrutura do json/nome dos campos tabela temporária
	
@return aStruCPO, contém um array com a estrutura do json/nome dos campos tabela temporária em 
ambientes de testes com base congelada TOTVS

@author Raphael Santana Ferreira
@since 18/10/2024
/*/
//---------------------------------------------------------------------------------------------
Function PINSDebugFields(aStruCPO)

	Local nI       as Numeric
	Local cIADebug as Character

	nI       := 0
	cIADebug := GetSrvProfString("IADebug", "0")

	If cIADebug == "1"
		For nI:=1 To Len(aStruCPO)
			If !(aStruCPO[nI][1] $ 'company_group/id/accuracy/mdmLastUpdated/tenantid/frequency/quantity/graphPoints/maecategory/stock_out_date/forecast_value/pb_calculate')
				If aStruCPO[nI][2][2] == "C"
					//Se caracter seta o tamanho máximo
					aStruCPO[nI][2][3] := 254
				ElseIf aStruCPO[nI][2][2] == "N"
					//Se numérico seta o tamanho máximo do campo e de casas decimais
					aStruCPO[nI][2][3] := 16
					aStruCPO[nI][2][4] := 9
				EndIf
			EndIf
		Next nI
	EndIf

Return aStruCPO

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} PinsTreatMock
Função que trata o Payload dinamicamente para usar a estrutura antiga ou nova
	
@param cInsightName, character, insight 

@return cPayload, Character, Payloda tratado com as propiedades corretas para a estrutura

@author Victor Vieira 
@since 17/06/2025
/*/
//---------------------------------------------------------------------------------------------
Static Function PinsTreatMock( cInsightName )
	Local aFromTo		:= {} 
	Local cPayload		:= ""
	Local nI			:= 0
    
	cPayload := mockInsight( cInsightName )
	aFromTo  := pinsFromToMock( cInsightName )

	If !Empty( aFromTo ) 
		For nI := 1 To Len( aFromTo )
			cPayload  := StrTran( cPayload, '"' + aFromTo[ nI ][ 1 ] + '"', '"' + aFromTo[ nI ][ 2 ]  + '"' )
		Next 
	EndIf
Return cPayload

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPayloadExpr
Retorna a expressao SQL para converter o campo memo I21_PAYLOD em JSON
conforme o banco de dados em uso.
- PostgreSQL: bytea -> text (via encode/escape) -> remove null bytes -> jsonb
- SQL Server: converte para VARCHAR(MAX) e parseia com JSON_VALUE/JSON_QUERY
- Oracle: campo memo ja retorna como texto, sem conversao adicional necessaria

@param cDatabase, character, Identificador do banco (retorno de TcGetDb)

@return cExpr, character, Expressao SQL para o campo PAYLOAD na subquery

@author Lucas Lima
@since 28/07/2026
/*/
//---------------------------------------------------------------------------------------------
Static Function GetPayloadExpr( cDatabase )
	Local cExpr := "" as Character

	If cDatabase == "POSTGRES"
		// encode(bytea, 'escape') converte para texto legivel
		// regexp_replace remove sequencias de escape octal (\000, \003, etc.)
		// chr(103) = 'g' (flag global) - evita que TOPConnect converta para maiuscula
		// ::jsonb converte texto limpo em tipo JSON nativo
		cExpr := "regexp_replace(encode(I21_PAYLOD, 'escape'), '\\[0-9]{3}', '', chr(103))::jsonb AS PAYLOAD"

	ElseIf cDatabase == "MSSQL"
		// SQL Server: CAST para VARCHAR(MAX) ja retorna texto legivel de campos memo
		cExpr := "CAST(I21_PAYLOD AS VARCHAR(MAX)) AS PAYLOAD"

	Else
		// Oracle e demais: campo memo retorna como texto, sem conversao adicional necessaria
		cExpr := "I21_PAYLOD PAYLOAD"

	EndIf

Return cExpr

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSelectJSON
Monta a expressão SQL de SELECT das propriedades do JSON.
- PostgreSQL: "PAYLOAD->>"  e "PAYLOAD->"
- SQL Server e Oracle: "JSON_VALUE" e "JSON_QUERY"

@param aFields, array, campos do struct da classe insight.
@param cDatabase, character, Identificador do banco (retorno de TcGetDb)
@param aPhysical, array, campos fisicos da tabela I21.

@return cFieldsSelect, character, string com o select formatado para extrair valores do JSON.

@author Lucas Lima
@since 28/07/2026
/*/
//---------------------------------------------------------------------------------------------
Static Function GetSelectJSON( aFields, cDatabase, aPhysical )
	Local cFieldsSelect := "" as Character
    Local cOper := "" as Character
    Local nI := 0 as Numeric
	Local lFieldMemo := .F. as Logical

	Default aPhysical := {}

    For nI := 1 To Len( aFields )

        If !Empty( aFields[ nI ][ 1 ] )
            If aScan( aPhysical, {|x| Upper( x[ 2 ] ) == Upper( aFields[ nI ][ 2 ][ 1 ] ) } ) > 0

                cFieldsSelect += Upper( aFields[ nI ][ 2 ][ 1 ] ) + ","

            Else

				lFieldMemo := Upper( aFields[ nI ][ 2 ][ 2 ] ) == "M"

				If cDatabase == "POSTGRES"
					
					// Memo (array/objeto JSON) usa -> ; demais usam ->>
					If lFieldMemo
						cOper := "->"
					Else
						cOper := "->>"
					EndIf
					cFieldsSelect += " PAYLOAD"+ cOper +"LOWER('"+ aFields[ nI ][ 1 ] +"') AS "

				Else 
					// SQL Server e Oracle: 
					// Memo (array/objeto JSON) usa JSON_QUERY; demais usam JSON_VALUE
					If lFieldMemo
						cOper := " JSON_QUERY"
					Else
						cOper := " JSON_VALUE"
					EndIf
					cFieldsSelect += cOper +"(PAYLOAD, '$."+ aFields[ nI ][ 1 ] +"') "

				EndIf

				cFieldsSelect += Upper( aFields[ nI ][ 2 ][ 1 ] ) +","

            EndIf
        Else 
            cFieldsSelect += "'' "+ Upper( aFields[ nI ][ 2 ][ 1 ] ) + ","
        EndIf
    Next nI

    // Remove a ultima virgula apenas se houver conteudo
    If !Empty( cFieldsSelect )
        cFieldsSelect := Left( cFieldsSelect, Len( cFieldsSelect ) - 1 )
    EndIf

Return cFieldsSelect
