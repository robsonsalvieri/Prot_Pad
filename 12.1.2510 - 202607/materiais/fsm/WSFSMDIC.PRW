#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFSMDIC
Métodos Rest do FSM
@author flavio.martins
@since 14/04/2025
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL FSMDIC DESCRIPTION "WS de Integração Field Services Manager"

	WSDATA aliasTable 	AS STRING
	WSDATA fieldName 	AS STRING
	WSDATA page      	AS INTEGER
	WSDATA pageSize  	AS INTEGER
	WSDATA filter    	AS STRING
	WSDATA AliasSxb 	AS STRING

	// Métodos GET
	WSMETHOD GET fieldsStruct  DESCRIPTION 'Retorna informações do dicionário de dados dos campos utilizados no FSM' PATH "fieldsStruct" PRODUCES APPLICATION_JSON
	WSMETHOD GET nextCodeByAlias  DESCRIPTION 'Retorna próximo código de uma tabela do dicionário' PATH "nextCodeByAlias" PRODUCES APPLICATION_JSON
	WSMETHOD GET lookupSxb  DESCRIPTION 'Retorna dados para lookup com base na SXB' PATH "lookupSxb" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET fieldsStruct  WSREST FSMDIC
Local lRet      := .T.
Local aTables   := {'JN0','JN1','JNZ','AA3','AA4','JNH','JN3','JN4','JN5','JN6',;
	'JO4','JNS','AA1','JNI','JNJ','JNV','JNY','JN7','JN9','JNA',;
	'JNB','JO2','JND','JNE','JNF','JNG','JNK','JNM','JNN','JNO',;
	'JNP','JNQ','JNX','JNR','JNU','JNV','JO0','JOD','JOF','JOG',;
	'JOH','JNL','JO1','JO3','JO4','JO5','JO6','JO7','JO8','JOA',;
	'JOB','JOC','JO3','JN5','JOI','JOJ','JOK','JOL', 'JOQ', 'JOR',;
	'JOS'}

Local aFields 		:= {}
Local oResponse		:= JsonObject():New()
Local nFields 		:= 0
Local nX      		:= 0
Local nTable    	:= 0
Local cType			:= ''
Local aCBox			:= {}
Local cCombo		:= ''
Local nOptions		:= 0
Local cAliasSxb 	:= ''
Local aStructSxb 	:= {}
Local nSxb			:= 0

oResponse['fields'] := {}

For nTable := 1 To Len(aTables)

	nX := 0

	aFields := FwSX3Util():GetListFieldsStruct(aTables[nTable], .T.)

	For nX := 1 To Len(aFields)

		If X3USO(FwGetSx3Cache(aFields[nX][1], "X3_USADO"))

			nFields++

			Aadd(oResponse['fields'], JsonObject():New())

			Do Case
			Case aFields[nX][2] $ 'C|M'
				cType := 'string'
			Case aFields[nX][2] == 'N' .And. aFields[nX][4] == 0
				cType := 'number'
			Case aFields[nX][2] == 'N' .And. aFields[nX][4] > 0
				cType := 'decimal'
			Case aFields[nX][2] == 'D'
				cType := 'date'
			Case aFields[nX][2] == 'L'
				cType := 'boolean'
			End Case

			oResponse['fields'][nFields]['name'] 		:= aFields[nX][1]
			oResponse['fields'][nFields]['table'] 		:= aTables[nTable]
			oResponse['fields'][nFields]['description'] := EncodeUtf8(AllTrim(FwGetSx3Cache(aFields[nX][1], "X3_TITULO")))
			oResponse['fields'][nFields]['type'] 		:= aFields[nX][2]
			oResponse['fields'][nFields]['length'] 		:= aFields[nX][3]
			oResponse['fields'][nFields]['precision']	:= aFields[nX][4]
			oResponse['fields'][nFields]['mask'] 		:= AllTrim(aFields[nX][5])
			oResponse['fields'][nFields]['required']    := X3OBRIGAT(aFields[nX][1])
			oResponse['fields'][nFields]['dynamicType'] := cType

			If FwGetSx3Cache(aFields[nX][1], "X3_PROPRI") == 'U'
				oResponse['fields'][nFields]['userField'] := .T.

				If !Empty(FwGetSx3Cache(aFields[nX][1], "X3_CBOX"))

					cCombo := AllTrim(FwGetSx3Cache(aFields[nX][1], "X3_CBOX"))

					If Substr(cCombo,1,1) == "#"
						cCombo := &(Alltrim(Substr(cCombo,2)))
					Endif

					aCBox := StrTokArr2(cCombo,';')

					oResponse['fields'][nFields]['options'] := {}

					For nOptions := 1 To Len(aCBox)
						Aadd(oResponse['fields'][nFields]['options'], JsonObject():New())

						oResponse['fields'][nFields]['options'][nOptions]['value'] := Substr(aCBox[nOptions], 1,At('=', aCBox[nOptions]) -1)
						oResponse['fields'][nFields]['options'][nOptions]['label'] := Substr(aCBox[nOptions], At('=', aCBox[nOptions]) +1,Len(aCBox[nOptions]))

					Next

				Endif

				If !Empty(cAliasSxb := FwGetSx3Cache(aFields[nX][1], "X3_F3"))

					oResponse['fields'][nFields]['lookupAlias'] := cAliasSxb

					aStructSxb := RetSxbStru(cAliasSxb)

					oResponse['fields'][nFields]['sxbStruct'] := {}

					For nSxb := 1 To Len(aStructSxb)

						If aStructSxb[nSxb][2] == '4'

							Aadd(oResponse['fields'][nFields]['sxbStruct'], JsonObject():New())
							oResponse['fields'][nFields]['sxbStruct'][Len(oResponse['fields'][nFields]['sxbStruct'])]['label'] := EncodeUtf8(AllTrim(aStructSxb[nSxb][4]))
							oResponse['fields'][nFields]['sxbStruct'][Len(oResponse['fields'][nFields]['sxbStruct'])]['property'] := AllTrim(aStructSxb[nSxb][5])

						Endif

						If aStructSxb[nSxb][2] == '5'

							oResponse['fields'][nFields]['fieldValue'] :=  Substr(AllTrim(aStructSxb[nSxb][5]),6,15)

						Endif

					Next

				Endif

			Else
				oResponse['fields'][nFields]['userField'] := .F.
			Endif
		Endif

	Next

Next

Self:SetResponse(FwJsonSerialize(oResponse, .F., .F., .T.))

Return lRet

WSMETHOD GET nextCodeByAlias WSRECEIVE aliasTable, fieldName WSREST FSMDIC
Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cNextCode := ''
Local cMsgError := ''

Default Self:aliasTable := ''
Default Self:fieldName  := ''

If Self:aliasTable == ''
	cMsgError := " Parâmetro 'aliasTable' não informado. "
	lRet := .F.
Endif

If Self:fieldName == ''
	cMsgError += " Parâmetro 'fieldName' não informado. "
	lRet := .F.
Endif

If (lRet)

	cNextCode := GetSxEnum(Self:aliasTable, Self:fieldName)

	oResponse['nextCode'] := cNextCode

	Self:SetResponse(FwJsonSerialize(oResponse, .F., .F., .T.))

	ConfirmSx8()

Else

	SetRestFault(400, I18N(cMsgError))

Endif

Return lRet

WSMETHOD GET lookupSxb WSRECEIVE WSRECEIVE AliasSxb, filter WSREST FSMDIC
Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cAliasSxb := ''
Local aFldsSxb  := {}
Local cFieldRet := ''
Local cAliasTmp := GetNextAlias()
Local cQuery	:= ''
Local nField	:= 0
Local nItems	:= 0

Default Self:AliasSxb := ''
Default Self:page     := 1
Default Self:pageSize := 10

If Self:filter == Nil
	Self:filter := ''
Endif

If Empty(AllTrim(Self:AliasSxb))
	SetRestFault(404, EncodeUtf8("O parâmetro 'AliasSxb' deve ser informado"))
Return .F.
Endif

SXB->(dbSetOrder(1))

If SXB->(dbSeek(Self:AliasSxb))

	While SXB->(!Eof()) .And. SXB->(XB_ALIAS) == Self:AliasSxb

		Do Case
		Case SXB->(XB_TIPO) == '1'
			cAliasSxb := Alltrim(SXB->(XB_CONTEM))
		Case SXB->(XB_TIPO) == '4'
			Aadd(aFldsSxb, {SXB->(XB_DESCRI), SXB->(XB_CONTEM)} )
		Case SXB->(XB_TIPO) == '5'
			cFieldRet := Substr(SXB->(XB_CONTEM),6,10)

		End Case

		SXB->(dbSkip())

	EndDo

Else
	SetRestFault(404, EncodeUtf8("Consulta padrão '" + Self:AliasSxb + "' não encontrada"))
Return .F.
Endif

cQuery += " SELECT 	"

For nField := 1 To Len(aFldsSxb)

	cQuery += " " + AllTrim(aFldsSxb[nField][2])

	If nField < Len(aFldsSxb)
		cQuery += ","
	Endif

Next

cQuery += " FROM " + RetSqlName(AllTrim(cAliasSxb)) + " "
cQuery += " WHERE " + cAliasSxb + "_FILIAL = ? "
cQuery += " AND " + cFieldRet + " LIKE ? "
cQuery += " AND D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY " + cFieldRet + " "
cQuery += " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY "

oQryTmp := FwPreparedStatement():New(cQuery)

oQryTmp:SetString(1, xFilial(cAliasSxb))
oQryTmp:SetString(2, '%'+Self:filter+'%')
oQryTmp:SetNumeric(3, (Self:page -1) * Self:pageSize)
oQryTmp:SetNumeric(4, Self:pageSize)

cQuery    := oQryTmp:GetFixQuery()
cAliasTmp := MpSysOpenQuery(cQuery)

oResponse['items'] := {}

While !(cAliasTmp)->(Eof())

	nItems++

	Aadd(oResponse['items'], JsonObject():New())

	For nField := 1 To Len(aFldsSxb)

		oResponse['items'][nItems][AllTrim(aFldsSxb[nField][2])] := (cAliasTmp)->(AllTrim(&(aFldsSxb[nField][2])))

	Next

	(cAliasTmp)->(dbSkip())

EndDo

oResponse['hasNext'] := (nItems >= Self:pageSize)


(cAliasTmp)->(dbCloseArea())

Self:SetResponse(FwJsonSerialize(oResponse, .F., .F., .T.))


Return lRet

Static Function RetSxbStru(cAliasSxb)
	Local aStructSxb := {}

	SXB->(dbSetOrder(1))

	If SXB->(dbSeek(cAliasSxb))

		While SXB->(!Eof()) .And. SXB->(XB_ALIAS) == cAliasSxb

			Aadd(aStructSxb, {SXB->XB_ALIAS, SXB->XB_TIPO, SXB->XB_SEQ, SXB->XB_DESCRI,SXB->XB_CONTEM})

			SXB->(dbSkip())

		EndDo

	Endif

Return aStructSxb
