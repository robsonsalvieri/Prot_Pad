#include 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "InsightDefs.ch"

Static __nBranchSize := FWSizeFilial()
Static __aBranchs := FWAllFilial(,,,.F.)
Static __cBranchs := ArrTokStr( __aBranchs, "," ) + ","


/*/{Protheus.doc} PINSMakeTemp
    @type  Function 
    Função responsavel por criar uma tabela temporária para guardar os alerts separados fora do JSON
    @author Raphael Santana Ferreira
    @since 25/07/2024
    @version version
    @param 
    @return array
/*/
Function PINSMakeTemp(cAliasTabTmp, cPropJs, cReqTab, cInsTyp, cModulo, aCampos, cQryBranch, nNewService)

	Local aStruBulk		as Array
	Local aGraphic		as Array
	Local aLinTab		as Array
	Local aCpoTab		as Array
	Local aStruCPO      as Array
	Local aSvAlias 		as Array
	Local aAreaSB1 		as Array	
	Local cTableMsg     as Character
	Local cNextAlias    as Character
	Local cPayload      as Character
	Local cDemandAcc    as Character
	Local cMessID       as Character
	Local cGraphPoints	as Character
	Local oTempTable    as Object
	Local oJson         as Object
	Local oBulk			as Object
	Local nX            as Numeric
	Local nSaldo        as Numeric

	Default nNewService := 1 // 1 - Estrutra I14; 2 - REstrutura I21  

	cNextAlias    := ""
	nX            := 0
	nSaldo        := 0
	aStruBulk	  := {}
	aGraphic	  := {}
	aLinTab		  := {}
	aStruCPO      := {}
	aSvAlias 	  := GetArea()
	aAreaSB1 	  := SB1->( GetArea() )	
	cMessID       := ""
	cTableMsg	  := "I14"	
	cDemandAcc    := ""
	cGraphPoints  := ""
	aCpoTab		  := aCampos
	oTempTable    := totvs.framework.database.temporary.SharedTable():New(cAliasTabTmp)

	If(nNewService) == 2
		cTableMsg 	:= "I21"
	EndIf

	SB1->( DBSetOrder(1) )	//B1_FILIAL+B1_COD

	//Alimenta o array da estrutura da tabela temporária
	For nX:=1 To Len(aCpoTab)
		Aadd(aStruCPO, {aCpoTab[nX][2][1], aCpoTab[nX][2][2], aCpoTab[nX][2][3], aCpoTab[nX][2][4]})
	Next nX

	//Configuração da tabela temporária
	oTempTable:SetFields(aStruCPO)

	//Efetiva a criação da tabela temporária
	oTempTable:Create()

	//Recupera o nome da tabela temporária para ser usada no Bulk
	cTableName := oTempTable:GetTableNameForTCFunctions()

	//Copia a estrutura de campos da tabela temporária
	aStruBulk := (cAliasTabTmp)->( DBStruct() )

	//Instancia o objeto FwBulk e seta as propriedades do objeto
	oBulk := FwBulk():New(cTableName)
	oBulk:SetFields(aStruBulk)

	//Função que faz a query de busca de registros na tabela I14 ou I19
	//Parametro nNewService controla se vai buscar na I14 ou I19
	//gera os dados no alias passado por parâmetro
	cNextAlias := PINSGetAlerts( cReqTab, cInsTyp, cModulo, nNewService, cQryBranch )

	// Itera sobre todos os registros com o mesmo ID de mensagem
	While (cNextAlias)->(!Eof())

		oJson := JsonObject():New()
		nSaldo := 0

		DbSelectArea(cTableMsg)
		If nNewService == 2
			
			DbGoTo((cNextAlias)->RECI21)	
			cPayload := Trim(I21->I21_PAYLOD)

			oJson:FromJson(cPayload)
			aLinTab := {}
			aLinTab := PINSAlertLine(oJson, aCpoTab,,,nNewService)

			If Len(aLinTab) > 0
				//Alimentando campos fora do JSON, dentro da I21
				Aadd(aLinTab,I21->I21_BRANCH)
				
				oBulk:AddData(aLinTab)
			EndIf
		Else
			
			DbGoTo((cNextAlias)->RECI14)	
			cPayload := Trim(I14->I14_MSGRAW)
		
			oJson:FromJson(cPayload)

			For nX:=1 To len(oJson[cPropJs])
				aLinTab := {}
				aLinTab := PINSAlertLine(oJson[cPropJs][nX], aCpoTab, cQryBranch,,nNewService)
				If Len(aLinTab) > 0
					oBulk:AddData(aLinTab)
				EndIf
			Next nX
		EndIf
		
		FreeObj(oJson)

		(cNextAlias)->(DbSkip())
	EndDo

	oBulk:Close()
	oBulk:Destroy()
	oBulk := nil

	RestArea( aSvAlias )
	RestArea( aAreaSB1 )

	Asize( aSvAlias, 0 )
	Asize( aAreaSB1, 0 )
	aSvAlias := nil
	aAreaSB1 := nil

	FWFreeArray( aStruBulk )
	FWFreeArray( aGraphic )
	FWFreeArray( aLinTab )
	FWFreeArray( aCpoTab )
	FWFreeArray( aStruCPO )
Return oTempTable

/*/{Protheus.doc} PINSGetAlerts
    @type  Function 
    Função que faz o select na tabela I14 retornando todos registros referente ao último
	alert enviado pelo smartlink
    @author Raphael Santana Ferreira
    @since 25/07/2024
    @version version
    @param cReqTab, Charactere, contém a string referente ao tipo de requisição será filtrado na query
	@param cInsTyp, Charactere, contém a string referente ao tipo de insight será filtrado na query
	@param cModulo, Charactere, contém a string referente ao módulo que será filtrado na query
	@param nNewService, Numeric,   Define a origem da tabela de mensagens, onde 1 - Estrutura I14 e 2 - Estrutura I21
	@param cQryBranch, caracter, filiais em que usuário tem acesso
    @return Charactere
/*/
Function PINSGetAlerts(cReqTab, cInsTyp, cModulo, nNewService, cQryBranch )

	Local cQuery     as Character
	Local cNextAlias as Character
	Local oPrepare   as Object
	Local aAux 		 as Array
	Local lUseBranch as Logical
	Local nBind	     as Numeric

	Default nNewService := 1 // 1 - Estrutra I14; 2 - REstrutura I21
	Default cQryBranch := ''  

	cNextAlias := ""

	If(nNewService == 1)
		cQuery := " SELECT R_E_C_N_O_ RECI14 "
		cQuery += " FROM " + RetSqlName("I14") + " I14 "
		cQuery += " WHERE I14.I14_MESSID = ( "
		cQuery += "     SELECT I14_MESSID "
		cQuery += "     FROM ( "
		cQuery += "         SELECT ROW_NUMBER() OVER( "
		cQuery += " 			ORDER BY I141.R_E_C_N_O_ DESC "
		cQuery += "           ) LINHA, I14_MESSID, R_E_C_N_O_ "
		cQuery += "         FROM " + RetSqlName("I14") + " I141 "
		cQuery += "         WHERE "
		cQuery += "           I141.I14_REQTYP = ? "
		cQuery += "           AND I141.I14_INSTYP = ? "
		cQuery += "           AND I141.I14_MODULO = ? "
		cQuery += "           AND I141.I14_MESSID <> '' "
		cQuery += "           AND I141.D_E_L_E_T_ = ? "
		cQuery += "       ) AUX "
		cQuery += " WHERE LINHA = 1 "
		cQuery += " AND I14.D_E_L_E_T_ = '' ) "

		cQuery := ChangeQuery(cQuery)

		oPrepare := FwExecStatement():New(cQuery)

		oPrepare:setString( 1, cReqTab )
		oPrepare:setString( 2, cInsTyp )
		oPrepare:setString( 3, cModulo )
		oPrepare:setString( 4, '' )

		cNextAlias := oPrepare:OpenAlias()

	Else

		nBind := 0

		If ( lUseBranch := !Empty( cQryBranch ) )
			// Trata as branchs para passar o conteúdo correto no método SetIn da FWExecStatement
			cQryBranch := StrTran( cQryBranch, ", ", "," )
			cQryBranch := StrTran( cQryBranch, "'", "" )
			aAux := StrTokArr( cQryBranch, ',' )
		EndIf
		
		If cInsTyp == 'stock_out'

			cQuery := " SELECT RECI21 FROM "
			cQuery += " (	SELECT I21.R_E_C_N_O_ RECI21, "
			cQuery += " 		ROW_NUMBER() OVER( PARTITION BY I21_KEY ORDER BY I21.R_E_C_N_O_ DESC ) LINHA "
			cQuery += " 	FROM " + RetSqlName("I21") + " I21 "
			cQuery += " 	INNER JOIN " + RetSqlName("I19") + " I19 "
			cQuery += " 		ON	I19.D_E_L_E_T_ = ? "
			cQuery += " 		AND I19.I19_INSIGT = ? "
			cQuery += " 		AND I19.I19_MESSID <> ? "
			cQuery += " 		AND I19.I19_UIDMSG = I21.I21_UIDMSG "
			cQuery += " 	WHERE I21.I21_MODULO = ? "
			cQuery += " 	AND I21.I21_INSIGT = ? "
			If lUseBranch
				cQuery += "     AND I21.I21_BRANCH IN ( ? ) "
			EndIf
			cQuery += "     AND I21.D_E_L_E_T_ = ? "
			cQuery += " 	AND I19.I19_DTRECV >= ? "
			cQuery += " ) AUX WHERE LINHA = 1 "

		Else
	
			cQuery := " SELECT I21.R_E_C_N_O_ RECI21 "
			cQuery += " FROM " + RetSqlName("I21") + " I21 "
			cQuery += " WHERE I21_UIDMSG IN ( "
			cQuery += " 	    SELECT I19_UIDMSG "
			cQuery += " 	    FROM " + RetSqlName("I19") + " I19 "
			cQuery += "     	WHERE I19.I19_MESSID = ( "
			cQuery += " 		    SELECT I19_MESSID "
			cQuery += " 		    FROM ( "
			cQuery += " 			    SELECT ROW_NUMBER() OVER( "
			cQuery += " 				    ORDER BY I191.R_E_C_N_O_ DESC "
			cQuery += " 			     ) LINHA, I19_MESSID, R_E_C_N_O_ "
			cQuery += " 			    FROM " + RetSqlName("I19") + " I191 "
			cQuery += " 		    	WHERE I191.D_E_L_E_T_ = ? "
			cQuery += " 			      AND I191.I19_INSIGT = ? "
			cQuery += " 			    AND I191.I19_MESSID <> ? "
			cQuery += " 		    ) AUX "
			cQuery += " 	    WHERE LINHA = 1 "
			cQuery += " 	    AND I19.D_E_L_E_T_ = '' ) "
			cQuery += "     ) "
			cQuery += "     AND I21.I21_MODULO = ? "
			cQuery += "     AND I21.I21_INSIGT = ? "
			If lUseBranch
				cQuery += "     AND I21.I21_BRANCH IN ( ? ) "
			EndIf
			cQuery += "     AND I21.D_E_L_E_T_ = ? "
		
		EndIf

		cQuery := ChangeQuery(cQuery)
		
		oPrepare := FwExecStatement():New(cQuery)

		oPrepare:setString( ++nBind, ' ' )
		oPrepare:setString( ++nBind, cInsTyp )
		oPrepare:setString( ++nBind, ' ' )
		oPrepare:setString( ++nBind, cModulo )
		oPrepare:setString( ++nBind, cInsTyp )
		If lUseBranch
			oPrepare:setIn( ++nBind, aAux )
		EndIf
		oPrepare:setString( ++nBind, ' ' )
		If cInsTyp == 'stock_out'
			oPrepare:setString( ++nBind, Transform( DTOS( Date() - Dow( Date() - 1 ) - 14 ), "@R ####-##-##" ) )
		EndIf
		cNextAlias := oPrepare:OpenAlias()
	
	EndIf

	FWFreeArray( aAux )
	FreeObj(oPrepare)

Return cNextAlias

/*/{Protheus.doc} PINSAlertLine
    @type  Function 
    Retorna um array com os dados da linha do Json de alert enviada por parâmetro
	alert enviado pelo smartlink
    @author Raphael Santana Ferreira
    @since 25/07/2024
    @version version
	@param oJson, objeto, contém a linha posicionada no array de Json de alerts
	@param aCpoTab, array, contém um array com os dados de campos referente a tabela temporária e propriedades do json de alert
	@param cQryBranch, caracter, filiais em que usuário tem acesso
	@param lMock, boolean, Indica se está sendo chamada por mock.
    @param nService , Numeric, Identifica o serviço da estrutura 1-Arquitetura antiga , 2 Arquitetura nova
	@return array
/*/
Function PINSAlertLine(oJson, aCpoTab, cQryBranch, lMock, nService )

	Local nI            as Numeric
	Local aRet          as Array
	Local aAux			as Array
	Local cGraphPoints  as Character
	Local cField 		as Character
	Local cCodeProp 	as Character
	Local cBranch 		as Character
	Local cProductCode	as Character
	Local lContinue     as Logical
	Local lAdd 			as Logical
	Local lAddEmpty		as Logical

	Default cQryBranch := ""
	Default lMock := .F.
	Default nService := 1 //Identifica o serviço da estrutura 1-Arquitetura antiga , 2 Arquitetura nova 

	nI           := 0
	aRet         := {}
	aAux		 := {}
	cGraphPoints := ""
	cField 		 := ""
	cCodeProp 	 := "code"
	cBranch		 := ""
	cProductCode := ""
	lContinue := .T.
 
	If nService == 1
		// Avalia se o alerta é de uma filial deste grupo de empresas ou compartilhado para ser apresentado
		IF !lMock .And. !Empty( oJson["branch" ] ) .And. !( Padr( oJson["branch" ], __nBranchSize ) +',' $ __cBranchs )
			lContinue := .F.
		EndIf

		// Valida se o registro da filial deve ser apresentado para o usuário
		If lContinue .And. !lMock .And. !Empty( oJson["branch" ] ) .And. !Empty( cQryBranch )
			If !( Padr( oJson[ "branch" ], __nBranchSize ) $ cQryBranch )
				lContinue := .F.
			EndIf
		EndIf
	Else	
		cCodeProp := "product_code"
	EndIf

	// Antes de alimentar a tabela temporária, verifica se o produto existe na tabela SB1
	If lContinue .And. !lMock .And. !Empty( oJson[ cCodeProp ] )
		If nService == 1
			cBranch := Padr( oJson[ "branch" ], __nBranchSize )
			cProductCode := oJson[ "code" ]
		Else
			aAux := StrTokArr2( oJson[ cCodeProp ], '|', .T. )
			cBranch:= Padr( aAux[ 1 ], __nBranchSize )
			cProductCode := aAux[ 2 ]
		EndIf
		If SB1->( !MSSeek( xFilial( "SB1", cBranch ) + cProductCode ) )
			lContinue := .F.
		EndIf
	EndIf

	If lContinue
		For nI:=1 To Len(aCpoTab)
			cField := aCpoTab[nI][1]
			lAdd := Iif( ( nService == 1 .And. oJson:hasProperty( cField ) ) .Or. ( nService == 2 .And. !( aCpoTab[nI][2][1] $ 'branch/company_group') ), .T., .F. )

			If lAdd
				If ValType(oJson[ cField ]) == "A"
					
					cGraphPoints := ""

					aeval(oJson[ cField ], {|i| cGraphPoints += i:ToJson() + "," })
					cGraphPoints := Left(cGraphPoints, Len(cGraphPoints) - 1)

					Aadd( aRet, cGraphPoints )
				ElseIf ValType(oJson[ cField ]) == "C"
					If '|' $ oJson[ cField ] .And. Len( aCpoTab[ nI ] ) >= STRUCT_COMPOSITE .And. aCpoTab[ nI ][ STRUCT_COMPOSITE ] //( "code" $ cField .Or. "type" $ cField )
						aAux := StrTokArr2( oJson[ cField ], '|', .T. )
						If Len( aCpoTab[ nI ][ 2 ] ) >= 6
							Aadd( aRet, RTrim( DecodeUTF8( aAux[ aCpoTab[ nI ][ 2 ][ 6 ] ] ) ) )
						Else
							Aadd( aRet, RTrim( DecodeUTF8( aAux[ Len( aAux ) ] ) ) )
						EndIf
					Else
						Aadd( aRet, AllTrim( DecodeUTF8( oJson[ cField ] ) ) )
					EndIf
				ElseIf ValType(oJson[ cField ]) == "N"
					Aadd( aRet, Round( oJson[ cField ], aCpoTab[ nI ][ 2 ][ 4 ] ) )
				Else
					If nService == 1
						Aadd( aRet, oJson[ cField ] )
					Else
						If !Empty( cField )
							Aadd( aRet, oJson[ cField ] )
						Else
							lAddEmpty := .T.

							If aCpoTab[ nI ][ 5 ] == STRUCT_INVISIBLE
								// campos de chave composta, ocultos no front
								If Len( aCpoTab[ nI ][ 2 ] ) >= 5
									Aadd( aRet, oJson[ aCpoTab[ nI ][ 2 ][ 5 ] ] )
									lAddEmpty := .F.
								EndIf
							Else
								If Len( aCpoTab[ nI ][ 2 ] ) >= 6
									If !Empty( aCpoTab[ nI ][ 2 ][ 5 ] ) 
										If ValType(oJson[ aCpoTab[ nI ][ 2 ][ 5 ] ]) == "C"
											If '|' $ oJson[ aCpoTab[ nI ][ 2 ][ 5 ] ]
												aAux := StrTokArr2( oJson[ aCpoTab[ nI ][ 2 ][ 5 ] ], '|', .T. )
												Aadd( aRet, RTrim( DecodeUTF8( aAux[ aCpoTab[ nI ][ 2 ][ 6 ] ] ) ) )
												lAddEmpty := .F.
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf

							If lAddEmpty
								Aadd( aRet, "" )
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				IF nService  == 1
					// se não tiver a propriedade no json, atribui um conteúdo vazio
					if aCpoTab[ nI ][ 2 ][ 2 ] == "C"
						Aadd( aRet, "" )
					EndIf
				EndIf
			Endif
		Next nI
    EndIf

	FWFreeArray( aAux )
Return aRet

/*/{Protheus.doc} PINSMakePage
    @type  Function 
    Função que gera a query de select na tabela temporária
	Retorna um objeto FWPreparedStatement com a query ordenada, paginada e com os filtros setada no objeto
    @author Raphael Santana Ferreira
    @since 25/07/2024
    @version version
    @param 
    @return array
/*/
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

/*/{Protheus.doc} PINSMakeWhere
    @type  Function 
    Função que gera a query de select na tabela temporária
	Retorna um objeto FWPreparedStatement com a query ordenada, paginada e com os filtros setada no objeto
    @author Raphael Santana Ferreira
    @since 25/07/2024
    @version version
    @param aCpoTab, array, contém a configuração dos campos da tabela temporária
	@param cCondition, Character, contém a condição que será inserida no select da tabela temporária
	@param cQryBranch, Character, contám as filiais que o usuário pode acessar
	@param cFilterByField, Character, contám os filtros provenientes dos combos
    @return caracter, condição de where que deve ser utilizada na consulta.
/*/
Function PINSMakeWhere(aCpoTab, cCondition, cQryBranch, cFilterByField )

	Local cWhere    as Character
	Local cAux 		As Character
	Local aCpoWhere as Array
	Local aFilterByField as Array
	Local nI		as Numeric
	Local nJ		as Numeric

	Default aCpoTab := {}
	Default cCondition := "" 
	Default cQryBranch := ""
	Default cFilterByField := ""

	cWhere	  := ""
	aCpoWhere := {}
	aFilterByField := {}
	nI		  := 0

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
		FwJSONDeserialize( cFilterByField, @aFilterByField )

		For nI := 1 to len( aFilterByField )
			cAux := ""
			For nJ := 1 to len( aFilterByField[ nI ][ "items" ] )
				cAux += "'" + aFilterByField[ nI ][ "items" ][ nJ ] + "',"
			Next
			cAux := Subs( cAux, 1, len( cAux ) - 1 )

			If !Empty( cWhere )
				cWhere += " AND "
			EndIf
			cWhere += aFilterByField[ nI ][ "field" ] + ' IN (' + cAux + ') '
		Next
	EndIf

	If !Empty( cWhere )
		cWhere := " WHERE " + cWhere
	EndIf

	FWFreeArray( aFilterByField )
Return cWhere

/*/{Protheus.doc} PINSAlertJson
    @type  Function 
    Retorna um objeto Json com os dados da linha da tabela temporária de DemandAlerts passada via parâmetro
    @author Raphael Santana Ferreira
    @since 25/07/2024
    @version version
    @param 
    @return array
/*/
Function PINSAlertJson(cNextAlias, aCpoTab)

	Local nI      as Numeric
	Local oJson   as Object
	Local oJsMemo as Object

	nI      := 0
	oJson   := JsonObject():New()
	oJsMemo := JsonObject():New()

	For nI:=1 To Len(aCpoTab)

		If aCpoTab[nI][2][2] == "C"
			oJson[aCpoTab[nI][1]] := AllTrim(StrTran((cNextAlias)->&(aCpoTab[nI][2][1]),'"',''))
		ElseIf aCpoTab[nI][2][2] == "N"
			oJson[aCpoTab[nI][1]] := (cNextAlias)->&(aCpoTab[nI][2][1])
		ElseIf aCpoTab[nI][2][2] == "M"
			cJsMemo := '{"' + aCpoTab[nI][1] + '" :  [' + (cNextAlias)->&(aCpoTab[nI][2][1]) + ']}'
			oJsMemo:FromJson(cJsMemo)
			oJson[aCpoTab[nI][1]] := oJsMemo[aCpoTab[nI][1]]
		ElseIf aCpoTab[nI][2][2] == "L"
			oJson[aCpoTab[nI][1]] := (cNextAlias)->&(aCpoTab[nI][2][1])
		EndIf

	Next nI

Return oJson

/*/{Protheus.doc} PINSRegCnt
    @type  Function 
    Função que valida se a tabela temporária tem registros
    @author Raphael Santana Ferreira
    @since 25/07/2024
    @version version
    @param cTabTmp, Character, contém o nome real da tabela temporária no banco de dados
    @return numérico
/*/
Function PINSRegCnt(cTabTmp)

	Local nRet       as Numeric
	Local cQuery     as Character
	Local cNextAlias as Character
	Local aArea		 as Array

	aArea  := GetArea()
	cQuery := "SELECT COUNT(R_E_C_N_O_) QTD_REC FROM " + cTabTmp

	cNextAlias := MPSysOpenQuery( ChangeQuery(cQuery) )

	If (cNextAlias)->(!Eof())
		nRet := (cNextAlias)->QTD_REC
	EndIf

	(cNextAlias)->(DbCloseArea())

	RestArea(aArea)

Return nRet

/*/{Protheus.doc} PinsMakeMock
    @type  Function 
    Função que gera os dados de mock, com base no parâmetro cTypeMock, e popula a tabela temporária com dados de mock
    @author Raphael Santana Ferreira
    @since 18/10/2024
	@version version

    @param cTabTmp, Character, contém o nome real da tabela temporária no banco de dados
    @param cTypeMock, Character, contém o nome do insight para o qual será gerado o mock
	@param aCpoTab, array, array com os propridades do json/nome dos campos tabela temporária
	@param cPropJs, Character, nome da propriedade para iterar a mensagem
	@param cInsightName, Character, nome real do insight	
/*/
Function PinsMakeMock(cTabTmp, cTypeMock, aCpoTab, cPropJs, nNewService, cInsightName )

	Local oBulk    as Object
	Local oJson    as Object
	Local aLinTab  as Array
	Local nX       as Numeric
	Local aStruCPO as Array
	Local cMock    as Character

	Default nNewService := 1 // 1 - Estrutra I14; 2 - REstrutura I21  
	Default cInsightName := cTypeMock

	oJson    := JsonObject():New()
	aLinTab  := {}
	aStruCPO := {}
	nX       := 0

	//Alimenta o array da estrutura da tabela temporária
	For nX:=1 To Len(aCpoTab)
		Aadd(aStruCPO, {aCpoTab[nX][2][1], aCpoTab[nX][2][2], aCpoTab[nX][2][3], aCpoTab[nX][2][4]})
	Next nX

	//Instancia o objeto FwBulk e seta as propriedades do objeto
	oBulk := FwBulk():New(cTabTmp)
	oBulk:SetFields(aStruCPO)

	cMock := IIF( nNewService == 1, mockInsight(cTypeMock),  PinsTreatMock( cInsightName, cTypeMock ) )

	oJson:FromJson(cMock)	

		For nX:=1 To len(oJson[cPropJs])

			aLinTab := {}
			aLinTab := PINSAlertLine(oJson[cPropJs][nX], aCpoTab, "", .T., nNewService )

			If nNewService == 2
				//Alimentando campos fora do JSON, dentro da I21
				Aadd(aLinTab, oJson[cPropJs][nX]["branch"] )
			EndIf
			
			If Len(aLinTab) > 0
				oBulk:AddData(aLinTab)	
			EndIf
		Next nX

	oBulk:Close()
	oBulk:Destroy()

	FreeObj(oJson)
	FreeObj(oBulk)
	FWFreeArray(aLinTab)

Return

/*/{Protheus.doc} PINSTabMock
    @type  Function 
    Função que cria a estrutura e tabela temporária compartilhada quando é executado no modo de DEMONSTRAÇÂO


    @param cAliasTabTmp, Character, contém o alias que será usado para geração da tabela temporária
	@param aCpoTab, Character, contém um array com a estrutura do json/nome dos campos tabela temporária
	
	@return Object, contém o objeto da tabela temporária SharedTable criada
	@author Raphael Santana Ferreira
    @since 18/10/2024
/*/
Function PINSTabMock(cAliasTabTmp, aCampos)

	Local aCpoTab		as Array
	Local aStruCPO      as Array
	Local oTempTable    as Object
	Local nX			as Numeric

	aStruCPO      := {}
	aCpoTab		  := aCampos
	oTempTable    := totvs.framework.database.temporary.SharedTable():New(cAliasTabTmp)
	nX			  := 0

	//Alimenta o array da estrutura da tabela temporária
	For nX:=1 To Len(aCpoTab)
		Aadd(aStruCPO, {aCpoTab[nX][2][1], aCpoTab[nX][2][2], aCpoTab[nX][2][3], aCpoTab[nX][2][4]})
	Next nX

	//Configuração da tabela temporária
	oTempTable:SetFields(aStruCPO)

	//Efetiva a criação da tabela temporária
	oTempTable:Create()

Return oTempTable

/*/{Protheus.doc} PINSDebugFields
    @type  Function 
    Função usada para verificar se o ambiente é de testes para criar a estrutura de campos da tabela temporária com tamanho default em campos que vem do Protheus


	@param aStruCPO, Character, contém um array com a estrutura do json/nome dos campos tabela temporária
	
	@return aStruCPO, contém um array com a estrutura do json/nome dos campos tabela temporária em ambientes de testes com base congelada TOTVS
	@author Raphael Santana Ferreira
    @since 18/10/2024
/*/
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
	
@param aInsight, array, vetor com as informações do insight
    [1] - nome do insight
    [2] - identificação no mock

@return cPayload, Character, Payloda tratado com as propiedades corretas para a estrutura
@author Victor Vieira 
@since 17/06/2025
/*/
//---------------------------------------------------------------------------------------------
Static Function PinsTreatMock( cInsight, cMock )

	Local aFromTo		:= {} 
	Local cPayload		:= ""
	Local nI			:= 0
    
	cPayload := mockInsight( cMock )
	aFromTo := pinsFromToMock( cInsight )

	If !Empty( aFromTo ) 
		For nI := 1 To Len( aFromTo )
			cPayload  := StrTran( cPayload, '"' + aFromTo[ nI ][ 1 ] + '"', '"' + aFromTo[ nI ][ 2 ]  + '"' )
		Next 
	EndIf
Return cPayload
