#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//TODO: Translation

Function RU44X10001_SeekMethod (oFMModel, cPK)

	Local lRet := .F.
	Local cQry := ""
	Local cPkFilter := ""
	Local nX 
	Local nStart
	Local nFieldSize
    Local nOperOld := 0
	Local cEmpty := ""
	Local oEmptyModel as Json
	Local aKeys := {}
	Local oBlockedObject
	Private aFilterVars := {}

	If (oFMModel:cSkip == NIL) .Or. oFMModel:cSkip == ""
		oFMModel:cSkip := '0'
	EndIf
	If (oFMModel:cPageSize == NIL) .Or. oFMModel:cPageSize == ""
		oFMModel:cPageSize := '10'
	EndIf
	If (oFMModel:cFirstLevel == NIL) .Or. oFMModel:cFirstLevel == "true" .Or. oFMModel:cFirstLevel == "1"
		oFMModel:cFirstLevel := '1'
	EndIf
	If Valtype(oFMModel:lReqTotalCount) <> "L" 
		If (oFMModel:lReqTotalCount == NIL) .Or. (oFMModel:lReqTotalCount == "" .And. (oFMModel:nTotal == NIL)) .Or. lower(oFMModel:lReqTotalCount) == "true"
			oFMModel:lReqTotalCount := .T.
		Else
			oFMModel:lReqTotalCount := .F.
		EndIf
	Endif
	If (oFMModel:nTotal == NIL)
		oFMModel:nTotal := 0
	EndIf

	If oFMModel:cFieldDetail == "true" .Or. oFMModel:cFieldDetail == "1"
		oFMModel:cFieldDetail := '1'
	EndIf

	If oFMModel:cFieldVirtual == "true" .Or. oFMModel:cFieldVirtual == "1"
		oFMModel:cFieldVirtual := '1'
	EndIf

	If oFMModel:cFieldEmpty == "true" .Or. oFMModel:cFieldEmpty == "1"
		oFMModel:cFieldEmpty := '1'
	EndIf


	If oFMModel:cDebug == "true" .Or. oFMModel:cDebug == "1"
		oFMModel:cDebug := '1'
	EndIf

	If oFMModel:cInternalId == "true" .Or. oFMModel:cInternalId == "1"
		oFMModel:cInternalId := '1'
	EndIf
	If (oFMModel:cGroup != NIL  .And. !Empty(oFMModel:cGroup ))
		oFMModel:cFields := oFMModel:cGroup
		oFMModel:cInternalId := '0'
		oFMModel:cFieldDetail := '1'
		oFMModel:cFirstLevel := '1'
	Endif
	If (oFMModel:cFields != NIL) .And. !Empty(oFMModel:cFields)
		oFMModel:aFields := StrTokArr((oFMModel:cFields), ",")
	EndIf
	oFMModel:cFilterVars := StrTran(oFMModel:cFilterVars, "''", "__DONTREMOVEEMPTYSPACE__")
	oFMModel:cFilterVars := StrTran(oFMModel:cFilterVars, ";", "")
	oFMModel:cFilterVars := StrTran(oFMModel:cFilterVars, "'", "")
	oFMModel:cFilterVars := StrTran(oFMModel:cFilterVars, "__DONTREMOVEEMPTYSPACE__", "''")

	If  charCount(oFMModel:cFilterExp, "?")>0 .And. (!Empty(oFMModel:cFilterExp) .Or. !Empty(oFMModel:cFilterVars)) .And. charCount(oFMModel:cFilterExp, "?") <> charCount(oFMModel:cFilterVars, ",") + 1

		If oFMModel:cDebug  == "1"
			i18nConOut("[FWRESTMODELOBJECT] Filter expression ERROR: cFilterExp: #1 cFilterVars#2", {oFMModel:cFilterExp, oFMModel:cFilterVars})
		EndIf
		cRet := '{"error": "Invalid Filter"}'

		oFMModel:cResponse := cRet

	ElseIf oFMModel:HasAlias()

		If !Empty(cPK)

			//cPkFilter := FWAToS(oFMModel:oModel:GetPrimaryKey(),"||") + " = '" + cPk + "'"
			nStart := 1
			If (oFMModel:cAlias)->(FieldPos(PrefixoCpo(oFMModel:cAlias)+"_FILIAL")) > 0
				//cPkFilter := PrefixoCpo(oFMModel:cAlias)+"_FILIAL||" + cPkFilter
				nFieldSize 	:= TamSX3(PrefixoCpo(oFMModel:cAlias)+"_FILIAL")[1]
				cPkFilter 	:= PrefixoCpo(oFMModel:cAlias)+"_FILIAL = '"+SubStr(cPk,nStart,nFieldSize)+"' AND "
				nStart 		+= nFieldSize
			EndIf
			aPKey := oFMModel:oModel:GetPrimaryKey()
			For nX:=1 to Len(aPKey)
				nFieldSize 	:= 	TamSX3(aPKey[nX])[1]
				cPkFilter 	+= 	aPKey[nX]+"='"+SubStr(cPk,nStart,nFieldSize)+IIf(nX< Len(aPKey),"' AND ","'")
				nStart 		+=	nFieldSize
			Next
			///REIMPLEMENT using oFwModel:cFilterVars and oFwModel:cFilterExp when cFilterExp is implemented.
            If !Empty(oFMModel:cFilterVars) .And. !Empty(oFMModel:cFilterExp)
                cPkFilter := cPkFilter  + " AND " + oFMModel:cFilterExp
            EndIf
			oFMModel:SetFilter(cPkFilter)

		EndIf

		If !Empty(oFMModel:cFilterVars) .And. !Empty(oFMModel:cFilterExp)

			aFilterVars := StrTokArr((oFMModel:cFilterVars), ",")

		EndIf

		cQry := createQueryAlias(@oFMModel:cQryAlias, oFMModel:cAlias, oFMModel:cFilter, oFMModel:cOrder, oFMModel:cSkip, oFMModel:cPageSize, oFMModel:lReqTotalCount, @oFMModel:nTotal,oFMModel:cGroup)

		If oFMModel:cDebug  == "1" //.And. oFMModel:GetQSValue("showQuery") == "true"
			i18nConOut("[FWRESTMODELOBJECT] Query: #1#2", {CRLF, cQry})
		EndIf

		If !(oFMModel:cQryAlias)->(Eof())
            If Type("nRecAlt") != "U" .And. nRecAlt > 0
                (oFMModel:cAlias)->(dbGoTo(nRecAlt))
            Else
			    (oFMModel:cAlias)->(dbGoTo((oFMModel:cQryAlias)->R_E_C_N_O_))
            EndIf
			lRet := !(oFMModel:cAlias)->(Eof())
		EndIf

		// aStru := (oFMModel:cAlias)->(DbStruct())
		// DbSelectArea((oFMModel:cAlias))
		// While (oFMModel:cQryAlias)->(!Eof())
		// 	(oFMModel:cAlias)->(DbGoto((oFMModel:cQryAlias)->R_E_C_N_O_))
		// 	oJsonResp   := JsonObject():New()
		// 	cRet += ","+rec2Json(aStru,oJsonResp)
		// 	FreeObj(oJsonResp)
		// 	(oFMModel:cQryAlias)->(DbSkip())
		// End

		nPageSize := Min(oFMModel:nTotal - Val(oFMModel:cSkip), Val(oFMModel:cPageSize))

		If Empty(cPK)
			cRet := i18n('{"total":#1,"count":#2,"startindex":#3,"resources":[', {oFMModel:nTotal, cValToChar(nPageSize), cValToChar(Val(oFMModel:cSkip) + 1)})
		Else
			cRet := i18n('{"total":#1,"count":#2,"startindex":#3,"resources":[', {oFMModel:nTotal, cValToChar(nPageSize), cValToChar(1)})
		EndIf

		DbSelectArea(oFMModel:cAlias)
        While (oFMModel:cQryAlias)->(!Eof())
            If Type("nRecAlt") != "U" .And. nRecAlt > 0
                (oFMModel:cAlias)->(DbGoto(nRecAlt))
            Else
			    (oFMModel:cAlias)->(DbGoto((oFMModel:cQryAlias)->R_E_C_N_O_))
            EndIf
            nOperOld := oFMModel:oModel:GetOperation()
			oFMModel:oModel:SetOperation(MODEL_OPERATION_VIEW)
    		If oFMModel:oModel:Activate()
				cRet += oFMModel:oModel:GetJsonData(oFMModel:cFieldDetail == "1"/* lFieldDetail*/,, oFMModel:cFieldVirtual == "1"/* lFieldVirtual */,, oFMModel:cFieldEmpty == "1" /* lFieldEmpty */, .T./*lPK*/, .T./*lPKEncoded*/, oFMModel:aFields, oFMModel:cFirstLevel == "1" /* lFirstLevel */, oFMModel:cInternalId == "1"/* lInternalID */)
				oFMModel:oModel:DeActivate()
			Else
				cEmpty := oFMModel:oModel:GetJsonData(.T./* lFieldDetail*/,, .T./* lFieldVirtual */,, .F. /* lFieldEmpty */, .T./*lPK*/, .T./*lPKEncoded*/, oFMModel:aFields, .T. /* lFirstLevel */, oFMModel:cInternalId == "1"/* lInternalID */)
				oEmptyModel := JsonObject():New()
				oEmptyModel:FromJson(cEmpty)
				aKeys := oFMModel:oModel:GetPrimaryKey()
				For nX:= 1 To Len(oEmptyModel['models'][1]['fields'])
					If Ascan(aKeys,oEmptyModel['models'][1]['fields'][nX]['id']) > 0
						If oEmptyModel['models'][1]['fields'][nX]['datatype'] == "D"
							oEmptyModel['models'][1]['fields'][nX]['value'] := Dtos((oFMModel:cAlias)->(FieldGet(FieldPos(oEmptyModel['models'][1]['fields'][nX]['id']))))
						Else
							oEmptyModel['models'][1]['fields'][nX]['value'] := (oFMModel:cAlias)->(FieldGet(FieldPos(oEmptyModel['models'][1]['fields'][nX]['id'])))
							oEmptyModel['models'][1]['fields'][nX]['value'] := EncodeUTF8(oEmptyModel['models'][1]['fields'][nX]['value'])
						Endif
					ElseIf oEmptyModel['models'][1]['fields'][nX]['datatype'] $ "CM"
						oEmptyModel['models'][1]['fields'][nX]['value'] := Replicate("*", Min(10,Val(oEmptyModel['models'][1]['fields'][nX]['len'])))
					ElseIf oEmptyModel['models'][1]['fields'][nX]['datatype'] == "N"
						oEmptyModel['models'][1]['fields'][nX]['value'] := 0
					Endif
				Next
				If  oBlockedObject == Nil
					oBlockedObject:= JsonObject():New()
					oBlockedObject['id']:='BLOCKED'
					oBlockedObject['datatype']:='N'
					oBlockedObject['value']:= 1
				Endif
				aadd(oEmptyModel['models'][1]['fields'],oBlockedObject)
				cRet += oEmptyModel:ToJson()
				FreeObj(oEmptyModel)
			Endif

            If nOperOld > 0
                oFMModel:oModel:SetOperation(nOperOld)
            EndIf
            If Type("nRecAlt") != "U" .And. nRecAlt > 0
                Exit
            EndIf
			(oFMModel:cQryAlias)->(DbSkip())

			If (oFMModel:cQryAlias)->(!Eof())
				cRet += ","
			EndIf

		End

		cRet += "]}"
        
        oFMModel:cResponse := cRet
	EndIf

Return lRet

Function RU44X10002_FilterOnActivate(oFMModel,cModel)

	Local cFixedFilter   := ""
	Local cQuery         := ""
	Local lFilterClients := (SuperGetMV("MV_PMSPCLI", .F., 1) == 1 )
	If(lFilterClients)
		cQuery := 'SELECT AI4_CODCLI,AI4_LOJCLI FROM '+RetSqlName('AI4')+" AI4,"+RetSqlName('AI3')+" AI3 "
		cQuery += 'WHERE  AI3_CODUSU=AI4_CODUSU '
		cQuery += " AND  AI3_USRSIS='"+__cUserID+"' "
		cQuery += " AND  AI3_FILIAL='"+xFilial('AI3')+"' "
		cQuery += " AND  AI4_FILIAL='"+xFilial('AI4')+"' "
		cQuery += " AND  AI4.D_E_L_E_T_='' "
		cQuery += " AND  AI3.D_E_L_E_T_='' "
	EndIf

	If cModel == 'AF8FWMODEL' .or. cModel == 'RU44W200'  
		If lFilterClients
			cFixedFilter := " (AF8_CLIENT,AF8_LOJA) IN ("+cQuery+") "
		EndIf
	ElseIf cModel == 'AF9FWMODEL' .Or. cModel == 'RU44W201'
		If lFilterClients
			cFixedFilter += "  AF9_REVISA IN (SELECT AF8_REVISA FROM "+retSqlName('AF8')+" AF8 WHERE AF8_FILIAL=AF9_FILIAL AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AF9_PROJET AND (AF8_CLIENT,AF8_LOJA) IN ("+cQuery+") )"
		Else
			cFixedFilter := "  (AF9_REVISA IN (SELECT AF8_REVISA FROM "+retSqlName('AF8')+" AF8 WHERE AF8_FILIAL=AF9_FILIAL AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AF9_PROJET)) "
		EndIf
	ElseIf cModel == 'AFCFWMODEL' .or. cModel == 'RU44W202'
		If lFilterClients
			cFixedFilter += "  AFC_REVISA IN (SELECT AF8_REVISA FROM "+retSqlName('AF8')+" AF8 WHERE AF8_FILIAL=AFC_FILIAL AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AFC_PROJET AND (AF8_CLIENT,AF8_LOJA) IN ("+cQuery+") )"
		Else
			cFixedFilter := "  (AFC_REVISA IN (SELECT AF8_REVISA FROM "+retSqlName('AF8')+" AF8 WHERE AF8_FILIAL=AFC_FILIAL AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AFC_PROJET)) "
		EndIf
	ElseIf cModel == 'AFUFWMODEL' .or. cModel == 'RU44W300'
		cFixedFilter := " AFU_CTRRVS='1' "
		If lFilterClients
			cFixedFilter += " AND (AFU_PROJET IN (SELECT AF8_PROJET FROM "+retSqlName('AF8')+" AF8 WHERE AF8_FILIAL=AFU_FILIAL AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AFU_PROJET AND (AF8_CLIENT,AF8_LOJA) IN ("+cQuery+") ) )"
		EndIf
	ElseIf cModel == 'AFFFWMODEL' .or. cModel == 'RU44W310'
		If lFilterClients
			cFixedFilter += "  AFF_REVISA IN (SELECT AF8_REVISA FROM "+retSqlName('AF8')+" AF8 WHERE AF8_FILIAL=AFF_FILIAL AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AFF_PROJET AND (AF8_CLIENT,AF8_LOJA) IN ("+cQuery+") )"
		Else
			cFixedFilter := "  (AFF_REVISA IN (SELECT AF8_REVISA FROM "+retSqlName('AF8')+" AF8 WHERE AF8_FILIAL=AFF_FILIAL AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AFF_PROJET)) "
		EndIf
	ElseIf cModel == 'AJKFWMODEL' .or. cModel == 'RU44W700'
		cFixedFilter := " AJK_CTRRVS='1' "
		If lFilterClients
			cFixedFilter += " AND (AJK_PROJET IN (SELECT AF8_PROJET FROM "+retSqlName('AF8')+" AF8 WHERE AF8_FILIAL=AJK_FILIAL AND AF8.D_E_L_E_T_='' AND AF8_PROJET=AJK_PROJET AND (AF8_CLIENT,AF8_LOJA) IN ("+cQuery+") ) )"
		EndIf
	EndIf

	If cFixedFilter <> ""

		If(oFMModel:cFilter) <> ""
			oFMModel:setfilter(oFMModel:cFilter + " AND ("+cFixedFilter+")")
		Else
			oFMModel:setfilter("("+cFixedFilter+")")
		EndIf

	EndIf

Return


Function RU44X10003_Total(oFMModel)

	Local nTotal     := 0
	Local oStatement := Nil
	Local cQuery     := ""
	Local cAlias     := GetNextAlias()

	Private aFilterVars := {}

	oFMModel:cFilterVars := StrTran(oFMModel:cFilterVars, "''", "__DONTREMOVEEMPTYSPACE__")
	oFMModel:cFilterVars := StrTran(oFMModel:cFilterVars, ";", "")
	oFMModel:cFilterVars := StrTran(oFMModel:cFilterVars, "'", "")
	oFMModel:cFilterVars := StrTran(oFMModel:cFilterVars, "__DONTREMOVEEMPTYSPACE__", "''")

	If charCount(oFMModel:cFilterExp, "?")>0 .And. (!Empty(oFMModel:cFilterExp) .Or. !Empty(oFMModel:cFilterVars)) .And. charCount(oFMModel:cFilterExp, "?") <> charCount(oFMModel:cFilterVars, ",") + 1

		If oFMModel:cDebug  == "1"
			i18nConOut("[FWRESTMODELOBJECT] Filter expression ERROR: cFilterExp: #1 cFilterVars#2", {oFMModel:cFilterExp, oFMModel:cFilterVars})
		EndIf
		cRet := '{"error": "Invalid Filter"}'

		oFMModel:cResponse := cRet

	ElseIf oFMModel:HasAlias()

		If !Empty(oFMModel:cFilterVars) .And. !Empty(oFMModel:cFilterExp)

			aFilterVars := StrTokArr((oFMModel:cFilterVars), ",")

		EndIf

		cQuery := "SELECT COUNT(*) AS TOTALCOUNT"
		cQuery += GetFromQryAlias(oFMModel:cAlias)
		cQuery += GetWhereQryAlias(oFMModel:cAlias, oFMModel:cFilter)

		cQuery := ChangeQuery(cQuery)

		oStatement := FWPreparedStatement():New()
		oStatement:SetQuery(cQuery)

		If Len(aFilterVars) > 0
			oStatement:SetParams(aFilterVars)
		EndIf

		Conout(oStatement:getFixQuery())
		DbUseArea(.T., "TOPCONN", TCGenQry(,,oStatement:getFixQuery()), cAlias, .F., .T.)
		nTotal := (cAlias)->TOTALCOUNT
		oFMModel:nTotal := (cAlias)->TOTALCOUNT
		(cAlias)->(DbCloseArea())

		oStatement:Destroy()
		FwFreeObj(oStatement)

	EndIf

Return nTotal

Static Function GetQueryOrder(cOrder,cTable)
	Local cOrderRet := " ORDER BY "

	If cOrder <> Nil .And. cOrder <> ""
		If At( Alltrim(cTable) + "_FILIAL",cOrder ) == 0
			cOrderRet += Alltrim(cTable) + "_FILIAL,"
		Endif
		cOrderRet += StrTran(cOrder,';',"") + ","
	Else

		If cTable == 'AF8'
			cOrderRet += " AF8_FILIAL, AF8_PROJET,"
		ElseIf cTable == 'AF9'
			cOrderRet += " AF9_FILIAL, AF9_PROJET, AF9_TAREFA, AF9_ORDEM,"
		ElseIf cTable == 'AFU'
			cOrderRet += " AFU_FILIAL, AFU_DATA DESC, AFU_HORAI DESC, AFU_PROJET, AFU_TAREFA, AFU_RECURS,"
		ElseIf cTable == 'AFF'
			cOrderRet += " AFF_FILIAL, AFF_DATA DESC, AFF_PROJET, AFF_TAREFA,"
		ElseIf cTable == 'AJK'
			cOrderRet += " AJK_FILIAL, AJK_DATA DESC, AJK_HORAI DESC, AJK_PROJET, AJK_TAREFA, AJK_RECURS,"
		ElseIf cTable == 'AE5'
			cOrderRet += " AE5_FILIAL, AE5_GRPCOM,"
		ElseIf cTable == 'AE8'
			cOrderRet += " AE8_FILIAL, AE8_RECURS,"
		ElseIf cTable == 'AED'
			cOrderRet += " AED_FILIAL, AED_EQUIP,"
		ElseIf cTable == 'AJ8'
			cOrderRet += " AJ8_FILIAL, AJ8_CODPLA, AJ8_ORDEM,"
		ElseIf !Empty(FWX2Unico( cTable) )
			cOrderRet += SqlOrder(Alltrim(FWX2Unico( cTable))) +","
		EndIf

	EndIf
	cOrderRet += RetSqlName(cTable)+".R_E_C_N_O_"
Return cOrderRet

Static Function createQueryAlias(cQryAlias, cTable, cFilter, cOrder, cSkip, cPageSize, lRequireTotalCount, nTotal, cGroup)

	Local oStatement
	Local cQuery    	:= ""
	Local cAliasTot 	:= GetNextAlias()
	//Local nTotalGroups	:= 0
	//Local cGroupQry
	If lRequireTotalCount

		cQuery := "SELECT COUNT(*) AS TOTALCOUNT "
		cQuery += GetFromQryAlias(cTable)
		cQuery += GetWhereQryAlias(cTable, cFilter)
		If cGroup <> Nil .And.!Empty(cGroup )
			//cGroupQry := cQuery + " GROUP BY "+cGroup
			cQuery += " GROUP BY "+cGroup
		Endif
		cQuery := ChangeQuery(cQuery)

		oStatement := FWPreparedStatement():New()
		oStatement:SetQuery(cQuery)

		If Len(aFilterVars) > 0
			oStatement:SetParams(aFilterVars)
		EndIf

		DbUseArea(.T., "TOPCONN", TCGenQry(,,oStatement:getFixQuery()), cAliasTot, .F., .T.)
		nTotal := (cAliasTot)->TOTALCOUNT
		(cAliasTot)->(DbCloseArea())
		oStatement:Destroy()
		FwFreeObj(oStatement)

		// If cGroupQry <> Nil 
		// 	cQuery := ChangeQuery(cGroupQry)
		// 	oStatement := FWPreparedStatement():New()
		// 	oStatement:SetQuery(cQuery)

		// 	If Len(aFilterVars) > 0
		// 		oStatement:SetParams(aFilterVars)
		// 	EndIf

		// 	Conout(oStatement:getFixQuery())
		// 	DbUseArea(.T., "TOPCONN", TCGenQry(,,oStatement:getFixQuery()), cAliasTot, .F., .T.)
		// 	nTotalGroups := (cAliasTot)->TOTALCOUNT
		// 	(cAliasTot)->(DbCloseArea())
		// 	oStatement:Destroy()
		// 	FwFreeObj(oStatement)
		// Endif


	EndIf

	If cGroup <> Nil .And.!Empty(cGroup)
		//If it is grpuped, pick any recno, since it its going to return only the group field
		cQuery := "SELECT Min("+RetSqlName(cTable)+".R_E_C_N_O_) as R_E_C_N_O_"
	Else
		cQuery := "SELECT "+RetSqlName(cTable)+".R_E_C_N_O_"
	Endif
	cQuery += GetFromQryAlias(cTable)
	cQuery += GetWhereQryAlias(cTable, cFilter)
	If cGroup <> Nil .And.!Empty(cGroup)
		cQuery += " GROUP BY "+cGroup
		cQuery += " ORDER BY "+cGroup
	Else
		cQuery += GetQueryOrder(cOrder, cTable)
	Endif
	If TCGETDB() == 'ORACLE'
		cQuery += ' ROWNUM BETWEEN ' + cSkip + " AND " + cValToChar(Val(cSkip) + Val(cPageSize))
		//ROWNUM <= 10
	ElseIf 'MSSQL' $ TCGETDB()
		cQuery += ' OFFSET ' + cSkip + " ROWS FETCH FIRST " + cPageSize + " ROWS ONLY "
		//OFFSET 10 ROWS FETCH FIRST 20 ROWS ONLY
	Else //POtsgreSql and others
		cQuery += " LIMIT "  + cPageSize
		cQuery += " OFFSET "  + cSkip
		//LIMIT 3 OFFSET 2
	EndIf

	cQuery := ChangeQuery(cQuery)
	

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	
	If Len(aFilterVars) > 0
		oStatement:SetParams(aFilterVars)
	EndIf
	
	cQuery     := oStatement:getFixQuery()
	//Conout(cQuery)
	MPSysOpenQuery(cQuery, @cQryAlias)
	oStatement:Destroy()
	FwFreeObj(oStatement)

Return cQuery

/*/{Protheus.doc} GetFromQryAlias
Adds JOINS to main query. 
This is used to be able to perform searchs when using web listings with virtual standard fields
@type function
@version  P14
@author bsobieski
@since 14/08/2024
@param cTable, character, Table name
@return cFrom, character, From expression
/*/
Static Function GetFromQryAlias(cTable) as character
Local cRet := " FROM " + RetSqlName( cTable ) as character
If cTable $ "AFF/AFU/AJK"
	cRet += " INNER JOIN "+ RetSqlName( 'AF8' ) + " AF8  ON " 
	cRet += " AF8_FILIAL = " +cTable + "_FILIAL AND " 
	cRet += " AF8_PROJET = " +cTable + "_PROJET AND " 
	cRet += " AF8.D_E_L_E_T_ = '' " 
	cRet += " INNER JOIN "+ RetSqlName( 'AF9' ) + " AF9  ON " 
	cRet += " AF9_FILIAL = " +cTable + "_FILIAL AND " 
	cRet += " AF9_PROJET = " +cTable + "_PROJET AND " 
	cRet += " AF9_REVISA = AF8_REVISA AND " 
	cRet += " AF9_TAREFA = " +cTable+ "_TAREFA AND  " 
	cRet += " AF9.D_E_L_E_T_ = '' " 
Endif

If cTable == "AFU"
	cRet += " INNER JOIN "+ RetSqlName( 'AE8' ) + " AE8  ON " 
	cRet += " AE8_FILIAL = '" +xFilial("AE8")+ "' AND " 
	cRet += " AE8_RECURS = AFU_RECURS AND " 
	cRet += " AE8.D_E_L_E_T_ = '' " 
	cRet += " LEFT JOIN "+ RetSqlName( 'AED' ) + " AED  ON " 
	cRet += " AED_FILIAL = '" +xFilial("AED")+ "' AND " 
	cRet += " AED_EQUIP = AE8_EQUIP AND " 
	cRet += " AED.D_E_L_E_T_ = '' " 
Endif
If cTable == "AJK"
	cRet += " INNER JOIN "+ RetSqlName( 'AE8' ) + " AE8  ON " 
	cRet += " AE8_FILIAL = '" +xFilial("AE8")+ "' AND " 
	cRet += " AE8_RECURS = AJK_RECURS AND " 
	cRet += " AE8.D_E_L_E_T_ = '' " 
	cRet += " LEFT JOIN "+ RetSqlName( 'AED' ) + " AED  ON " 
	cRet += " AED_FILIAL = '" +xFilial("AED")+ "' AND " 
	cRet += " AED_EQUIP = AE8_EQUIP AND " 
	cRet += " AED.D_E_L_E_T_ = '' " 
Endif
If ExistBlock('RU44X100')
	cRetTMP := ExecBlock('RU44X100',.F.,.F.,{'GETFROMQRYALIAS',cRet,cTable})
	If cRetTMP <> Nil .AND. VALTYPE(cRetTMP)=='C' .And. !Empty(cRetTMP) 
		cRet := cRetTMP
	Endif
Endif

Return cRet
//-------------------------------------------------------------------

/*/{Protheus.doc} GetWhereQryAlias
Funcao responsavel por retornar a clausula where da query de dados
@param cTable   Tablea principal
@param cFilter  Filtro da query
@return cWhere Clausula where da query
@author Felipe Bonvicini Conti
@since 05/04/2016
@version P11, P12
/*/
//-------------------------------------------------------------------
Static Function GetWhereQryAlias(cTable, cFilter)
	
	Local cWhere
	Local cUsrFilFilter
    
	cWhere := " WHERE "+RetSqlName(cTable)+".D_E_L_E_T_ = ' '"
    //Introduz a seguran?a padr?o de acesso as filiais do sistema
    If (cTable)->(FieldPos(PrefixoCpo(cTable)+"_FILIAL")) > 0
        cUsrFilFilter := FWSQLUsrFilial(cTable)
        If !Empty(cUsrFilFilter)
            cWhere += " AND (" + cUsrFilFilter + ") "
        EndIf
		cWhere += " AND ("+PrefixoCpo(cTable)+"_FILIAL = '"+xFilial(cTable)+"') "
    EndIf
    If !Empty(cFilter)
        cWhere += " AND (" + cFilter + " ) "
    EndIf

Return cWhere

/*/{Protheus.doc} charCount
Funcao responsavel por contar os caracteres dentro de uma string
@type function
@author Fernando Nicolau
@since 13/09/2023
@param cString, character, String principal
@param cCaracter, character, Caractere buscado
@return numeric, Quantidade de Caracteres encontrada
/*/
Static Function charCount(cString, cCaracter)

	Local nTotal      := 0
	Local nPos        := 0
	Default cString   := ""
	Default cCaracter := ""
	
	//Percorre todas as letras da palavra
	For nPos := 1 To Len(cString)
		//Se a posição atual for igual ao caracter procurado, incrementa o valor
		If SubStr(cString, nPos, 1) == cCaracter
			nTotal++
		EndIf
	Next
		
Return nTotal

Function RU44X10004_SaveData(oObj, cPK, cData, cError)
local lRet := .T.
Default cData   := ""
    If Empty(cPk)
        oObj:oModel:SetOperation(MODEL_OPERATION_INSERT)
    Else
        oObj:oModel:SetOperation(MODEL_OPERATION_UPDATE)
        lRet := oObj:Seek(cPK)
    EndIf
    If lRet
        If oObj:oModel:Activate()
			If oObj:lXml
				lRet := oObj:oModel:LoadXMLData(cData,.F.)
			Else
				lRet := oObj:oModel:LoadJsonData(cData,.F.)
			EndIf
			If lRet
				If oObj:oModel:VldData() 
					// Verifico se o modelo sofreu alguma alteração
					if oObj:oModel:lModify 
						If !(oObj:oModel:CommitData())
							lRet := .F.
							cError := ErrorMessage(oObj:oModel:GetErrorMessage())
						EndIf
					Else
						lRet := .F.
						oObj:SetStatusResponse(304, 'Not modified')
					EndIf
				Else
					lRet := .F.
					cError := ErrorMessage(oObj:oModel:GetErrorMessage())
				Endif
			Else
				lRet := .F.
				cError := ErrorMessage(oObj:oModel:GetErrorMessage())
			Endif
	        oObj:oModel:DeActivate()
			If lRet 
				//Loads the saved data as response
				RU44X10001_SeekMethod(oObj, cPK)
			Endif
        Else
			lRet := .F.
            cError := ErrorMessage(oObj:oModel:GetErrorMessage())
        EndIf
    Else
        cError := i18n("Invalid record '#1' on table #2", {cPK, oObj:cAlias})
    EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DelData
Método responsável por remover um registro.
@param  cPK         PK do registro.
@param  @cError Retorna o alguma mensagem de erro
@return lRet        Indica se o registro foi removido
@author Bruno Sobieski
@since 8/08/2024
@version P12
/*/
//-------------------------------------------------------------------
Function RU44X10005_DelData(oObj, cPK, cError)
local lRet := .F.
    If !Empty(cPK)
        If oObj:Seek(cPK)
            oObj:oModel:SetOperation(MODEL_OPERATION_DELETE)
            If !oObj:oModel:Activate()
				lRet := .F.
				cError := ErrorMessage(oObj:oModel:GetErrorMessage())
			Else
				lRet := oObj:oModel:VldData() .And. oObj:oModel:CommitData()
				If !lRet
					cError := ErrorMessage(oObj:oModel:GetErrorMessage())
				EndIf
				oObj:oModel:DeActivate()
			Endif
        Else
            cError := i18n("Invalid record '#1' on table #2", {cPK, oObj:cAlias})
        EndIf
    EndIf
Return lRet
/*/{Protheus.doc} ErrorMessage
Funcao responsavel por retonar o erro do modelo.
@type function
@author Bruno Sobieski
@since 14/08/2024
@version P11, P12
@param aErroMsg, Array, array de erro do modelo de dados
@return cRet, character, Formato texto JSON do array de erro do modelo de dados
/*/
Static Function ErrorMessage(aErroMsg) as character
Local oRet := JsonObject():New()
if !Empty(aErroMsg[1])
	oRet['idSubmodelOrigin']:= aErroMsg[1]
Endif
if !Empty(aErroMsg[2])
	oRet['idFieldOrigin'] 	:= aErroMsg[2]
Endif
if !Empty(aErroMsg[3])
	oRet['idSubmodelError'] := aErroMsg[3]
Endif
if !Empty(aErroMsg[4])
	oRet['idFieldError'] 	:= aErroMsg[4]
Endif
if !Empty(aErroMsg[5])
	oRet['idError'] 		:= aErroMsg[5]
Endif
if !Empty(StrTran(aErroMsg[6],chr(13)+chr(10),""))
	oRet['errorMessage'] 	:= aErroMsg[6]
Endif
if !Empty(StrTran(aErroMsg[7],chr(13)+chr(10),""))
	oRet['solutionMessage'] := aErroMsg[7]
Endif
oRet['assignedValue'] := aErroMsg[8]
oRet['previousValue'] := aErroMsg[9]
Return oRet:ToJson()

/*/{Protheus.doc} RU44X10006_GetTeamName
Used on models INIT to get team name to be returned to MODELS virtual field
@type function
@version  1.0
@author bsobieski
@since 14/08/2024
@param cFrom, character, Table origin (record must be already positioned)
@return character, team code
/*/
Function RU44X10006_GetTeamName(cFrom as character) as character
Local cRet := "" as character
Local cTeam as character
If cFrom  == "AJK"
	cTeam := Posicione('AE8',1,xFilial('AE8')+ AJK->AJK_RECURS, 'AE8_EQUIP')
ElseIf cFrom  == "AFU"
	cTeam := Posicione('AE8',1,xFilial('AE8')+ AFU->AFU_RECURS, 'AE8_EQUIP')
Endif

If !Empty(cTeam)	
	cRet := Posicione('AED',1,xFilial('AED')+ cTeam, 'AED_DESCRI')
Endif

Return cRet

// /*/{Protheus.doc} RU44X10007_GetResEquip
// Used on models INIT to get team name to be returned to MODELS virtual field
// @type function
// @version  1.0
// @author bsobieski
// @since 14/08/2024
// @param cFrom, character, Table origin (record must be already positioned)
// @return character, team code
// /*/
// Function RU44X10007_GetResEquip(cFrom)
// Local cRet := ""

// If cFrom  == "AJK"
// 	cRet := Posicione('AE8',1,xFilial('AE8')+ AJK->AJK_RECURS, 'AE8_EQUIP')
// ElseIf cFrom  == "AFU"
// 	cRet := Posicione('AE8',1,xFilial('AE8')+ AFU->AFU_RECURS, 'AE8_EQUIP')
// Endif

// Return cRet

// Function U_testJson()
// 	cInsert := "'Protheus Line'"
// 	cText := '['+;
// 	'    {'+;
// 	'        "values": {'+;
// 	'            "TEXT": "%%INSERT%%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     "'+;
// 	'        },'+;
// 	'        "recno": 1100529,'+;
// 	'        "package": "      ",'+;
// 	'        "project": "000001",'+;
// 	'        "key": ['+;
// 	'            32838,'+;
// 	'            "STR0001",'+;
// 	'            "ALL"'+;
// 	'        ],'+;
// 	'        "idiom": "POR",'+;
// 	'        "version": "000001"'+;
// 	'    }'+;
// 	']'

// 	cText := StrTran(cText,'%%INSERT%%',cInsert)
// 	oReturn := JsonObject():New()
// 	cRet := oReturn:FromJson('{"data":'+(cText)+'}')

// Return

                     
