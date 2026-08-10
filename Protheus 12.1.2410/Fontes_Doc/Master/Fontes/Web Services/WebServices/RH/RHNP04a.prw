#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "RHNP04.CH"

Function RHNP04a()
Return .T.


Function getNotifications(cMatSRA,oItemData,cBranchVld,aItems,aQPs,cMatAprov,cSubDepts,nCount,nIniCount,nFimCount,cFilOrig)
Local nI			:= 0
Local cQuery		:= GetNextAlias()
Local aArea			:= GetArea()
Local cType 		:= "'B','8','Z'"

Local cDescType		:= ""
Local oFields		:= Nil
Local oEmployee		:= Nil
Local oProps		:= Nil
Local aFields		:= {}
Local aExtFields	:= {}
Local aEmployee		:= {}
Local aSeqClock		:= {}
Local cWhere		:= ""
Local cAux			:= ""
Local cAuxCode		:= ""
Local cJustify		:= ""
Local __cSRFtab		:= ""
Local cDataPesq		:= ""
Local cDataPesq2    := ""
Local cCpoQry		:= "%%"
Local __cSRFDel 	:= "% SRF.D_E_L_E_T_ = ' ' %"
Local __cRH3Del 	:= "% RH3.D_E_L_E_T_ = ' ' %"
Local __cRH4Del		:= "% RH4.D_E_L_E_T_ = ' ' %"
Local __cSRADel		:= "% SRA.D_E_L_E_T_ = ' ' %"
Local lJustify		:= .F.
Local lLastObs		:= .F.
Local lBipMap		:= RH3->(ColumnPos("RH3_BITMAP"))
Local lAttach		:= .F.
Local lNomeSoc    := SuperGetMv("MV_NOMESOC", NIL, .F.)

Default oItemData	:= JsonObject():New()
Default aItems		:= {}
Default aQPs		:= {}
Default cSubDepts	:= ""
DEFAULT nCount    	:= 0
DEFAULT nIniCount 	:= 1
DEFAULT nFimCount 	:= 6

// esse conjunto de campos podem conter:
// - matricula do usuário logado(token), ou
// - string com filial e matricula que o usuário logado está substituindo 
Default cBranchVld	:= FwCodFil()
Default cMatSRA		:= ""

// esse conjunto de campos contém:
// - matricula do usuário logado no app(token) 
Default cFilOrig	:= FwCodFil()
Default cMatAprov	:= ""


oFields   := JsonObject():New()
oEmployee := JsonObject():New()

//Retorna uma matriz com entrada/saida de cada dia para classificar as marcacoes do espelho
aSeqClock := fGetSeqClock(cBranchVld, cMatSRA, cMatAprov, cFilOrig)

If lBipMap
	cCpoQry := "%, RH3.RH3_BITMAP %"
EndIf

//************************************************************
//Preparação do cWhere
//************************************************************
cWhere := "%"

If !empty(aQPs[6]) //nome do colaborador
	cWhere += " ( ( SRA.RA_NOME LIKE '%" + UPPER( aQPs[6] ) + "%' ) OR
	cWhere += If(lNomeSoc, " ( SRA.RA_NSOCIAL LIKE '%" + UPPER( aQPs[6] ) + "%' ) OR ", "")
	cWhere += " ( SRA.RA_NOMECMP LIKE '%" + UPPER( aQPs[6] ) + "%' ) ) AND "
EndIf

If !Empty(aQPs[3])
	//Padrão das datas na RH4 (dd/mm/aaaa)
	cDataPesq := Substr(aQPs[3],9,2) + "/" + Substr(aQPs[3],6,2) + "/" + Substr(aQPs[3],1,4)
	// Trata datas gravadas na RH4 com apenas 2 dígitos para o ano; Ex 2021 (21)
	cDataPesq2 := Substr(aQPs[3],9,2) + "/" + Substr(aQPs[3],6,2) + "/" + Substr(aQPs[3],3,2)
EndIF

If !empty(aQPs[1])  //Tab. Ao acessar a tela esse QP sempre virá preenchido
	If !empty(aQPs[2]) //Type. QP utilizado para realizar o filtro avançado.
		If Lower(aQPs[2]) == "allowance"
			cType := "'8'"
			If !Empty(aQPs[3]) //data da solicitação
				cWhere += " RH4.RH4_CAMPO = 'RF0_DTPREI' AND "
				cWhere += " ( RH4.RH4_VALNOV = '" + cDataPesq + "' OR
				cWhere += " RH4.RH4_VALNOV = '" + cDataPesq2 + "' ) AND "
			EndIf
		ElseIf Lower(aQPs[2]) == "clocking"
			cType := "'Z'"
			If !Empty(aQPs[3]) //data da solicitação
				cWhere += " RH4.RH4_CAMPO = 'P8_DATA' AND "
				cWhere += " ( RH4.RH4_VALNOV = '" + cDataPesq + "' OR
				cWhere += " RH4.RH4_VALNOV = '" + cDataPesq2 + "' ) AND "
			EndIf
		Elseif Lower(aQPs[2]) == "vacation"
			cType := "'B'"
			If !Empty(aQPs[3]) //data da solicitação
				cWhere += " RH4.RH4_CAMPO = 'R8_DATAINI' AND "
				cWhere += " ( RH4.RH4_VALNOV = '" + cDataPesq + "' OR
				cWhere += " RH4.RH4_VALNOV = '" + cDataPesq2 + "' ) AND "
			EndIf
		Elseif Lower(aQPs[2]) == "demission"
			cType := "'6'"
			//As solicitações de desligamento não gravam data na RH4, então pode-se filtrar pela RH3.
			If !Empty(aQPs[3]) //data da solicitação
				//Padrão da data na RH3 - (aaaammdd)
				cDataPesq := Substr(aQPs[3],9,2) + Substr(aQPs[3],6,2) + Substr(aQPs[3],1,4)
				cDataPesq2 := Substr(aQPs[3],9,2) + Substr(aQPs[3],6,2) + Substr(aQPs[3],3,2)
				cWhere += " ( RH3.RH3_DTSOLI = '" + cDataPesq + "' OR
				cWhere += " RH3.RH3_DTSOLI = '" + cDataPesq2 + "' ) AND "
			EndIf
		EndIf
		cWhere += " RH3.RH3_TIPO IN (" + cType + ") "
	else
		cWhere += " RH3.RH3_TIPO IN ('8','Z') " //"allowance" e "clocking"
		If !Empty(aQPs[3]) //data da solicitação
			cWhere += " AND ( ( RH4.RH4_CAMPO = 'P8_DATA' AND 
			cWhere += " ( RH4.RH4_VALNOV = '" + cDataPesq + "' OR 
			cWhere += " RH4.RH4_VALNOV = '" + cDataPesq2 + "' ) ) OR "
			cWhere += " ( RH4.RH4_CAMPO = 'RF0_DTPREI' AND 
			cWhere += " ( RH4.RH4_VALNOV = '" + cDataPesq + "' OR 
			cWhere += " RH4.RH4_VALNOV = '" + cDataPesq2 + "' ) ) ) "
		EndIf
	EndIf
EndIf

If !Empty( cSubDepts )
	cWhere += " AND "
	cWhere += " ( "
	cWhere += " RH3.RH3_FILAPR IN ('" + cFilOrig + "') AND "
	cWhere += " RH3.RH3_MATAPR IN ('" + cMatAprov + "') "
	cWhere += " OR ( "
	cWhere += " RH3.RH3_FILAPR IN (" + cBranchVld + ") AND "
	cWhere += " RH3.RH3_MATAPR IN (" + cMatSRA + ") AND "
	cWhere += " SRA.RA_DEPTO IN (" + cSubDepts + ") "
	cWhere += " ) "
	cWhere += " ) "
Else
	cWhere += " AND "
	cWhere += " RH3.RH3_FILAPR IN ('" + cFilOrig + "') AND "
	cWhere += " RH3.RH3_MATAPR IN ('" + cMatAprov + "')"
EndIF

cWhere += " AND RH3.RH3_EMPAPR = '" + cEmpAnt + "' %"


//************************************************************
//Execução da Query
//************************************************************
If !Empty( cSubDepts ) .or. !empty(aQPs[6])
	BEGINSQL ALIAS cQuery
	    SELECT DISTINCT RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH3.RH3_MAT, RH3.RH3_DTSOLI, RH3.RH3_VISAO, RH3.RH3_FILINI, RH3.RH3_MATINI, RH3.RH3_FILAPR, RH3.RH3_MATAPR, RH3.RH3_STATUS, RH3.RH3_TIPO, RH3.RH3_EMP
			%Exp:cCpoQry%
			FROM %table:RH3% RH3
	    INNER JOIN %table:SRA% SRA
			ON RH3.RH3_FILIAL = SRA.RA_FILIAL AND RH3.RH3_MAT = SRA.RA_MAT
		INNER JOIN %table:RH4% RH4
			ON RH3.RH3_FILIAL = RH4.RH4_FILIAL AND RH3.RH3_CODIGO = RH4.RH4_CODIGO
	    WHERE	RH3.RH3_STATUS = '1'	AND
				%exp:__cRH3Del%			AND
				%exp:__cRH4Del%         AND
				%exp:__cSRADel%			AND
				%Exp:cWhere%
		Order by RH3.RH3_DTSOLI
	ENDSQL
Else
	BEGINSQL ALIAS cQuery
	    SELECT DISTINCT RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH3.RH3_MAT, RH3.RH3_DTSOLI, RH3.RH3_VISAO, RH3.RH3_FILINI, RH3.RH3_MATINI, RH3.RH3_FILAPR, RH3.RH3_MATAPR, RH3.RH3_STATUS, RH3.RH3_TIPO, RH3.RH3_EMP
			%Exp:cCpoQry%
			FROM %table:RH3% RH3
		INNER JOIN %table:RH4% RH4
			ON RH3.RH3_FILIAL = RH4.RH4_FILIAL AND RH3.RH3_CODIGO = RH4.RH4_CODIGO
	    WHERE 	RH3.RH3_STATUS = '1'	AND
				%Exp:cWhere%			AND
				%exp:__cRH3Del%         AND
				%exp:__cRH4Del%
		Order by RH3.RH3_DTSOLI
	ENDSQL
EndIf

While (cQuery)->(!Eof())

	lAttach := .F.
	nCount++
	If ( nCount >= nIniCount .and. nCount <= nFimCount )
		oItemData					 := JsonObject():New()

		oItemData["id"] 			 := (cQuery)->RH3_FILIAL +"|"+ (cQuery)->RH3_MAT +"|"+ (cQuery)->RH3_EMP +"|"+ (cQuery)->RH3_CODIGO 
		oItemData["type"]			 := GetENUMDecode((cQuery)->RH3_TIPO)
		oItemData["canApprove"] 	 := Iif((cQuery)->RH3_MATAPR $ cMatSRA, .T., .F.)

		//Verifica se existe imagem na requisicao abono
		If lBipMap .And. (cQuery)->RH3_TIPO == "8"
			lAttach := !Empty((cQuery)->RH3_BITMAP)
		EndIf

		oEmployee 					 := JsonObject():New()
		aEmployee 					 := getSummary((cQuery)->RH3_MAT, (cQuery)->RH3_FILIAL, (cQuery)->RH3_EMP)
		oEmployee["id"] 			 := aEmployee[4] +"|" +aEmployee[1] +"|"+ (cQuery)->RH3_EMP //Filial+Mat
		oEmployee["name"]			 := aEmployee[2]
		oEmployee["roleDescription"] := aEmployee[3]

		oItemData["employeeSummary"] := oEmployee

		If (cQuery)->RH3_TIPO == "B"
			__cSRFtab := "%" + RetFullName("SRF", (cQuery)->RH3_EMP) + "%"
			__cSRFDel := "% SRF.D_E_L_E_T_ = ' ' %"
		EndIf

		If RH4->(dbSeek(xFilial("RH4", (cQuery)->RH3_FILIAL) + (cQuery)->RH3_CODIGO ))
			lJustify := .F.

			While RH4->(!Eof())

				oFields := JsonObject():New()
				If RH4->RH4_CODIGO == (cQuery)->RH3_CODIGO
					getFields(@oFields, (cQuery)->RH3_TIPO, (cQuery)->RH3_CODIGO, aSeqClock)

					If !empty(oFields['type'])
						Aadd(aFields,oFields)

						If (cQuery)->RH3_TIPO == 'Z' .and. oFields['type'] == 'justify' //inclusão manual
							lJustify := .T.
						EndIf
					EndIf
				Else
					EXIT
				EndIf

				cAux     := (cQuery)->RH3_MAT
				cAuxCode := (cQuery)->RH3_CODIGO
				RH4->(DbSkip())
			EndDo

			// add o 'justify' vazio, mesmo quando não exista observação na solic. abono
			// com objetivo de não bloquear o processo de aprovação/reprovação nas notifiações
			If !lJustify .And. (cQuery)->RH3_TIPO == 'Z'
				cDescType := "justify"

				oFields := JsonObject():New()
				oFields["type"]  := EncodeUTF8(cDescType)
				oFields["value"] := ""

				oProps := JsonObject():New()
				oProps["field"]     := cDescType
				oProps["visible"]   := .T.
				oProps["editable"]  := .F.
				oProps["required"]  := .F.

				oFields["props"]    := oProps
				Aadd(aFields,oFields)
			EndIf
		EndIf

		//Busca justificativas (nao considera marcacoes que ja possui tratamento especifico)
		If !(cQuery)->RH3_TIPO == "Z"
			lLastObs := (cQuery)->RH3_TIPO == "B"
			cJustify := getRGKJustify((cQuery)->RH3_FILIAL,(cQuery)->RH3_CODIGO,,lLastObs)
			If !empty(cJustify)
				oFields := JsonObject():New()
				oFields["type"]  := "justify"
				oFields["value"] := cJustify

				//Libera campo de justificativa
				oProps := JsonObject():New()
				oProps["field"]     := "justify"
				oProps["visible"]   := .T.
				oProps["editable"]  := .F.
				oProps["required"]  := .F.

				oFields["props"]    := oProps
				Aadd(aFields, oFields)
			Else
				oFields := JsonObject():New()
				oFields["type"]  := "justify"
				oFields["value"] := ""

				//Libera campo de justificativa
				oProps := JsonObject():New()
				oProps["field"]     := "justify"
				oProps["visible"]   := .T.
				oProps["editable"]  := .F.
				oProps["required"]  := .F.

				oFields["props"]    := oProps
				Aadd(aFields, oFields)
			EndIf
		EndIf

		//Inicializa campos contrato
		aExtFields := getInitFields((cQuery)->RH3_TIPO, lAttach, (cQuery)->RH3_EMP, (cQuery)->RH3_FILIAL, (cQuery)->RH3_MAT, (cQuery)->RH3_CODIGO)
		For nI := 1 To Len(aExtFields)
			oFields := JsonObject():New()
			oFields["type"]  := aExtFields[nI][1]
			oFields["value"] := aExtFields[nI][2]

	        //Inclui properties de cada campo
			oProps := JsonObject():New()
			oProps["field"]     := aExtFields[nI][1]
			oProps["visible"]   := aExtFields[nI][4]
			oProps["editable"]  := aExtFields[nI][5]
			oProps["required"]  := aExtFields[nI][6]
			oFields["props"]    := oProps

			Aadd(aFields, oFields)
		Next nI

		//Carrega Fields
		oItemData["fields"] := aFields
		aFields             := {}
		Aadd(aItems,oItemData)
	EndIf

	(cQuery)->(DbSkip())
EndDo

(cQuery)->( DBCloseArea() )

RestArea(aArea)

Return(Nil)


/*/{Protheus.doc}countNotifications()
- Efetua a contagem das notificações do usuário logado.
@author:	Matheus Bizutti
/*/
Function countNotifications(cMatSRA,oItemData,cBranchVld,cSubDepts,cTypes,cAction,nTotReq,nTotPend,cFilOrig,cMatOrig,cLogin,cCodRD0)

Local nX            := 0
Local nQtdTotal     := 0
Local nQtdReq		:= 0

Local aData         := {}
Local aTypesFilter  := {}

Local oSubTotals    := Nil

Local cWhere		:= ""
Local cTypeQRY      := ""
Local cTypeReq		:= "6|7|3|4"
Local cQuery        := GetNextAlias()
Local cQryCount 	:= GetNextAlias()

Local lVacation		:= .T.
Local lTimesheet	:= .T.
Local lRequisitions := .T.
Local lDemission    := .F.
Local lStaffInc		:= .F.
Local lDataChange	:= .F.
Local lTransfer		:= .F.

Default oItemData   := JsonObject():New()
Default cMatSRA     := ""
Default cBranchVld  := FwCodFil()
Default cFilOrig  	:= FwCodFil()
Default cMatOrig	:= ""
Default cSubDepts	:= ""
Default cTypes   	:= ""
Default cAction   	:= ""
Default cLogin		:= ""
Default cCodRD0		:= ""
Default nTotReq		:= 0
Default nTotPend	:= 0

oSubTotals := JsonObject():New()

//Busca permissões.
fPermission(cFilOrig, cLogin, cCodRD0, "notificationClocking", @lTimesheet)
fPermission(cFilOrig, cLogin, cCodRD0, "notificationVacation", @lVacation)
fPermission(cFilOrig, cLogin, cCodRD0, "requisitions", @lRequisitions)
fPermission(cFilOrig, cLogin, cCodRD0, "demission", @lDemission)
fPermission(cFilOrig, cLogin, cCodRD0, "staffIncrease", @lStaffInc)
fPermission(cFilOrig, cLogin, cCodRD0, "employeeDataChange", @lDataChange)
fPermission(cFilOrig, cLogin, cCodRD0, "transfer", @lTransfer)

If cAction == "notify"
	If lTimesheet
		cTypes += "allowance|clocking"
	EndIf

	If lVacation
		cTypes += "|vacation"
	EndIf

	If lRequisitions
		If lDemission
			cTypes += "|demission"
		EndIf
		If lStaffInc
			cTypes += "|staffIncrease"
		EndIf
		If lDataChange
			cTypes += "|employeeDataChange"
		ENDIF
		If lTransfer
			cTypes += "|transfer"
		EndIf
	EndIf
EndIf

aTypesFilter := STRTOKARR(cTypes, "|")
IF len(aTypesFilter) > 0
	For nX := 1 To Len(aTypesFilter)
		If nX > 1
			cTypeQRY += ","
		ENDIF

		If cAction == "notify"
			if aTypesFilter[nX] == "allowance"
				cTypeQRY += "'8'"
			elseif aTypesFilter[nX] == "vacation"
				cTypeQRY += "'B'"
			elseif aTypesFilter[nX] == "clocking"
				cTypeQRY += "'Z'"
			elseif Upper( aTypesFilter[nX] ) == "DEMISSION"
				cTypeQRY += "'6'"
			elseif Upper( aTypesFilter[nX] ) == "EMPLOYEEDATACHANGE"
				cTypeQRY += "'7'"
			elseif Upper( aTypesFilter[nX] ) == "STAFFINCREASE"
				cTypeQRY += "'3'"
			elseif Upper( aTypesFilter[nX] ) == "TRANSFER"
				cTypeQRY += "'4'"
			EndIf
		Else
			if aTypesFilter[nX] == "demission"
				cTypeQRY	+= "'6'"
			elseif UPPER(aTypesFilter[nX]) == "EMPLOYEEDATACHANGE"
				cTypeQRY	+= "'7'"
			elseif UPPER(aTypesFilter[nX]) == "STAFFINCREASE"
				cTypeQRY	+= "'3'"
			elseif UPPER(aTypesFilter[nX]) == "TRANSFER"
				cTypeQRY	+= "'4'"
			ENDIF	
		EndIf
	Next nX
ENDIF

cWhere := ""
If !Empty( cTypeQRY )
	If cAction == "count"
		cWhere := "%"
		cWhere += "(( RH3.RH3_FILINI = '" + cBranchVld + "' AND "
		cWhere += " RH3.RH3_MATINI = '" + cMatSRA    + "') OR "
		cWhere += "( RH3.RH3_FILAPR = '" + cBranchVld + "' AND 
		cWhere += " RH3.RH3_MATAPR = '" +  cMatSRA    + "')) AND"
		cWhere += " RH3.RH3_TIPO   IN (" + cTypeQRY  + ") "
	Elseif cAction == "notify"
		If !Empty( cSubDepts )
			cWhere := "%"
			cWhere += " RH3.RH3_TIPO IN (" + cTypeQRY  + ") AND "
			cWhere += " ( "
			cWhere += " RH3.RH3_FILAPR IN ('" + cFilOrig + "') AND "
			cWhere += " RH3.RH3_MATAPR IN ('" + cMatOrig + "') "
			cWhere += " OR ( "
			cWhere += " RH3.RH3_FILAPR IN (" + cBranchVld + ") AND "
			cWhere += " RH3.RH3_MATAPR IN (" + cMatSRA + ") AND "
			cWhere += " SRA.RA_DEPTO IN (" + cSubDepts + ") "
			cWhere += " ) "
			cWhere += " ) "
		Else
			cWhere := "%"
			cWhere += " RH3.RH3_FILAPR IN ('" + cFilOrig + "') AND "
			cWhere += " RH3.RH3_MATAPR IN ('" + cMatOrig + "') AND "
			cWhere += " RH3.RH3_TIPO   IN (" + cTypeQRY  + ") "
		EndIf    
	EndIf
EndIf

//Quando o funcionario esta substituindo seu gestor
If !Empty( cWhere )
    
	cWhere += " AND (RH3.RH3_EMPAPR = '" + cEmpAnt + "'"
	cWhere += " OR RH3.RH3_EMPINI = '" + cEmpAnt + "')"
	
	If !Empty( cSubDepts )
		cWhere += "%"

		BEGINSQL ALIAS cQuery

			SELECT RH3.RH3_TIPO, COUNT(*) QTD
					FROM %table:RH3% RH3
			INNER JOIN %table:SRA% SRA
					ON RH3_FILIAL = RA_FILIAL AND RH3_MAT = RA_MAT
			WHERE  RH3.RH3_STATUS = '1' AND
					RH3.%NotDel% AND 
					SRA.%NotDel% AND
					%Exp:cWhere%
			GROUP BY RH3.RH3_TIPO

		ENDSQL
	Else

		cWhere += "%"

		BEGINSQL ALIAS cQuery

			SELECT RH3.RH3_TIPO, COUNT(*) QTD
					FROM %table:RH3% RH3
			WHERE  RH3.RH3_STATUS IN ('1','4') AND
					%Exp:cWhere% 			   AND
					RH3.%NotDel%
			GROUP  BY RH3.RH3_TIPO

		ENDSQL

	EndIf

	While (cQuery)->(!Eof())
		oSubTotals := JsonObject():New()
		nQtdTotal += (cQuery)->QTD
		If !( (cQuery)->RH3_TIPO $ cTypeReq ) .Or. cAction == "count"
			oSubTotals["type"]  := GetENUMDecode( (cQuery)->RH3_TIPO )
			oSubTotals["total"] := (cQuery)->QTD
			Aadd(aData,oSubTotals)
		Else
			nQtdReq += (cQuery)->QTD
		EndIf
		(cQuery)->(DbSkip())
	EndDo
	(cQuery)->( DBCloseArea() )

	IF nQtdReq > 0
		oSubTotals := JsonObject():New()
		oSubTotals["type"]  := 'requisition'
		oSubTotals["total"] := nQtdReq
		Aadd(aData,oSubTotals)
	EndIf

	If cAction == "count"
		//Tratativa para acumular os totais.
		If !Empty( cSubDepts )

			BEGINSQL ALIAS cQryCount

				SELECT RH3.RH3_FILINI, RH3.RH3_MATINI, RH3.RH3_FILAPR, RH3.RH3_MATAPR
						FROM %table:RH3% RH3
				INNER JOIN %table:SRA% SRA
						ON RH3_FILIAL = RA_FILIAL AND RH3_MAT = RA_MAT
				WHERE  RH3.RH3_STATUS = '1' AND
						%Exp:cWhere% AND
						RH3.%NotDel% AND 
						SRA.%NotDel%
			ENDSQL

		Else

			BEGINSQL ALIAS cQryCount

				SELECT RH3.RH3_FILINI, RH3.RH3_MATINI, RH3.RH3_FILAPR, RH3.RH3_MATAPR
						FROM %table:RH3% RH3
				WHERE  RH3.RH3_STATUS IN ('1','4') AND
						%Exp:cWhere% 			   AND
						RH3.%NotDel%
			ENDSQL

		EndIf

		While (cQryCount)->(!Eof())

			//requisições em aberto que foram iniciadas pelo usuário logado
			If (cQryCount)->RH3_FILINI == cBranchVld .And. (cQryCount)->RH3_MATINI == cMatSRA
				nTotReq += 1
			EndIf

			//requisições em aberto que estão no passo do usuário logado para que seja tomado uma ação
			If (cQryCount)->RH3_FILAPR == cBranchVld .And. (cQryCount)->RH3_MATAPR == cMatSRA
				nTotPend += 1
			EndIf

			(cQryCount)->(DbSkip())
		EndDo
		(cQryCount)->( DBCloseArea() )
	ENDIF

EndIf

If cAction == "notify"
	If nQtdTotal > 0
		oItemData["subtotals"] 	:= aData
		oItemData["total"] 		:= nQtdTotal - nQtdReq
	EndIf
else
	oItemData := aData
EndIf

Return(Nil)


Static Function getFields(oFields,cTypeRequest,cCodRH4,aSeqClock)

//Local cJsonObj 	 	:= "JsonObject():New()"
Local oProps		:= JsonObject():New() 
Local nPos			:= 0
Local cCpoRH4		:= AllTrim(RH4->RH4_CAMPO)

Default cTypeRequest := ""
Default cCodRH4 := ""
Default aSeqClock := {}

DO CASE
	CASE cTypeRequest == "B" // VACATION
		If cCpoRH4 == "R8_DATAINI"
			oFields["type"]        := EncodeUTF8("initDate")
			oFields["value"]       := formatGMT(Alltrim(RH4->RH4_VALNOV))
		ElseIf cCpoRH4 == "R8_DATAFIM"
		  	oFields["type"]        := EncodeUTF8("endDate")
		  	oFields["value"]       := formatGMT(Alltrim(RH4->RH4_VALNOV))
		ElseIf cCpoRH4 == "R8_DURACAO"
			oFields["type"]        := EncodeUTF8("totalDays")
          oFields["value"]         := Alltrim(RH4->RH4_VALNOV)
		Elseif cCpoRH4 == "TMP_DABONO"
			oFields["type"]        := EncodeUTF8("vacationBonus")
          oFields["value"]         := Alltrim(RH4->RH4_VALNOV)
		Elseif cCpoRH4 == "RF_DATABAS"
			oFields["type"]        := EncodeUTF8("initVacationLimit")
          oFields["value"]         := formatGMT(Alltrim(RH4->RH4_VALNOV) )
		Elseif cCpoRH4 == "RF_DATAFIM"
		  oFields["type"]         := EncodeUTF8("endVacationLimit")
          oFields["value"]        := formatGMT(Alltrim(RH4->RH4_VALNOV) )
	   Else
          oFields["type"]         := ""
          oFields["value"]        := ""
       EndIf

	CASE cTypeRequest == "Z" // CLOCKING
		If cCpoRH4 == "P8_DATA"
			oFields["type"] := EncodeUTF8("initDate")
			oFields["value"] := formatGMT(Alltrim(RH4->RH4_VALNOV))
		ElseIf cCpoRH4 == "P8_HORA"
			oFields["type"] := EncodeUTF8("initHour")
			oFields["value"] := HourToMs(strZero( TimeToFloat(Alltrim(RH4->RH4_VALNOV)), 5, 2)) //TimeToFloat função do RHLIBHRS.
		//O campo TMP_TEXT só existe no MeuRH então considera a última atribuição caso exista os dois.
		//Dessa forma manterá a compatibilidade com as solicitações originadas no Portal GCH
		ElseIf cCpoRH4 $ "TMP_TEXT"
		  	oFields["type"] := EncodeUTF8("justify")
			oFields["value"] := EncodeUTF8(Alltrim(RH4->RH4_VALNOV))

			//Adiciona o properties
			oProps["field"]     := "justify"
			oProps["visible"]   := .T.
			oProps["editable"]  := .F.
			oProps["required"]  := .F.

			oFields["props"]    := oProps
		ElseIf cCpoRH4 $ "P8_MOTIVRG"
		  	oFields["type"] := EncodeUTF8("reason")
			oFields["value"] := EncodeUTF8(Alltrim(RH4->RH4_VALNOV))

			//Adiciona o properties
			oProps["field"]     := "reason"
			oProps["visible"]   := .T.
			oProps["editable"]  := .F.
			oProps["required"]  := .F.

			oFields["props"]    := oProps
		ElseIf cCpoRH4 == "TMP_NOME"
			//Define o sentido - Entrada/Saida
			nPos := aScan(aSeqClock, {|x| x[4] == cCodRH4} )
			If nPos > 0
				oFields["type"] := EncodeUTF8("direction")
				oFields["value"] := aSeqClock[nPos,3]
			EndIf
		EndIf

	CASE cTypeRequest == "8"
		If cCpoRH4 == "RF0_DTPREI"
			oFields["type"] := EncodeUTF8("initDate")
			oFields["value"] := formatGMT(Alltrim(RH4->RH4_VALNOV))

		ElseIf cCpoRH4 == "RF0_DTPREF"
		  	oFields["type"] := EncodeUTF8("endDate")
			oFields["value"] := formatGMT(Alltrim(RH4->RH4_VALNOV))
		ElseIf cCpoRH4 == "RF0_HORINI"
			oFields["type"] := EncodeUTF8("initHour")
			oFields["value"] := HourToMs(Alltrim(RH4->RH4_VALNOV))

			//Adiciona o properties
			oProps["field"]     := "initHour"
			oProps["visible"]   := .T.
			oProps["editable"]  := .F.
			oProps["required"]  := .F.

			oFields["props"]    := oProps
			
		ElseIf cCpoRH4 == "RF0_HORFIM"
			oFields["type"] := EncodeUTF8("endHour")
			oFields["value"] := HourToMs(Alltrim(RH4->RH4_VALNOV))

			//Adiciona o properties
			oProps["field"]     := "endHour"
			oProps["visible"]   := .T.
			oProps["editable"]  := .F.
			oProps["required"]  := .F.

			oFields["props"]    := oProps
		ElseIf cCpoRH4 == "TMP_ABOND"
			oFields["type"] := EncodeUTF8("reason")
			oFields["value"] := EncodeUTF8(Alltrim(RH4->RH4_VALNOV))
			
			//Adiciona o properties
			oProps["field"]     := "reason"
			oProps["visible"]   := .T.
			oProps["editable"]  := .F.
			oProps["required"]  := .F.

			oFields["props"]    := oProps
		EndIf

ENDCASE

Return(Nil)


Static Function getInitFields(cTypeRequest, lAttach, cEmpRH3, cFilRH3, cMatRH3, cCodRH3)
Local cValue := ""
Local aInitFields := {}

Default cTypeRequest := ""
Default lAttach 	 := .F.

//Inicializa o campo e tambem o properties a partir do terceiro elemento:
//Aadd( aInitFields, { /*Type*/, /*Value*/, /*lProperties*/, /*lvisible*/, /*leditable*/, /*lrequired*/ } )

If cTypeRequest == "B" // Férias
	Aadd( aInitFields, {"totalHours", "", .F., .F., .F., .F. } )
    Aadd( aInitFields, {"status"    , "", .F., .F., .F., .F. } )
    Aadd( aInitFields, {"direction" , "", .F., .F., .F., .F. } )
    Aadd( aInitFields, {"other"     , "", .F., .F., .F., .F. } )
	Aadd( aInitFields, {"reason"    , "", .F., .F., .F., .F. } )

ElseIf cTypeRequest == "8" //Abono
	Aadd( aInitFields, {"totalHours", "", .F., .F., .F., .F. } )
    Aadd( aInitFields, {"status"    , "", .F., .F., .F., .F. } )
    Aadd( aInitFields, {"direction" , "", .F., .F., .F., .F. } )
    Aadd( aInitFields, {"other"     , "", .F., .F., .F., .F. } )
	If lAttach
		cValue := RC4CRYPT(cFilRH3 + "|" + cMatRH3 + "|"  + cEmpRH3 + "|" + cCodRH3, "MeuRH#Allowance")
    	Aadd( aInitFields, {"requestId", cValue, .T., .T., .T., .T. } )
    	Aadd( aInitFields, {"hasAttachment", .T., .T., .T., .T., .T. } )
	EndIf

EndIf

Return(aInitFields)

/*/{Protheus.doc}GetNotifys()
- Efetua a contagem das notificações do usuário logado.

@author:	Matheus Bizutti
/*/
Function GetNotifys(cMatSRA,cJsonObj,oItemData,cBranchVld)

Local nI			:= 0
Local nQtd			:= 0
Local cType 		:= "'B','8'" //"'8','B'"
Local aData		:= {}
Local aEnum		:= {}
Local aRequests	:= {}
Local oSubTotals	:= Nil

Default cJsonObj	:= "JsonObject():New()"
Default oItemData	:= &cJsonObj
Default cMatSRA 	:= ""
Default cBranchVld	:= FwCodFil()

oSubTotals := &cJsonObj
Aadd(aEnum,"vacation")
Aadd(aEnum,"allowance")
Aadd(aEnum,"clocking")

aRequests := fGetAllReq(cBranchVld, cMatSRA, cType, 0, "", "", .F., "", .T., .F., .F., .T.)

For nI := 1 To Len(aRequests)

	If Alltrim(aRequests[nI]:Registration) == Alltrim(cMatSRA) .Or. Alltrim(cMatSRA) != Alltrim(aRequests[nI]:ApproverRegistration)
		Loop
	EndIf

	If aRequests[nI]:Status:Code == "1"
		nQtd += 1
	EndIf

Next nI

oSubTotals["type"]  := aEnum[1] // @FIXME
oSubTotals["total"] := nQtd

Aadd(aData,oSubTotals)

oItemData["subtotals"] 	:= aData
oItemData["total"] 		:= nQtd

Return(Nil)


/*/{Protheus.doc} fGetSeqclock
Retorna uma matriz com sentido (entrada/saida) das marcacoes incluidas pelo espelho de acordo com a data/hora
@author:	Marcelo Silveira
@since:		16/04/2019
@param:		cFilSRA - Filial do aprovador;
			cMatSRA - Matricula do aprovador;
@return:	aSentido - Array com as datas/horas classificadas como entrada/saida
/*/
Function fGetSeqclock(cFilSRA, cMatSRA, cMatAprov, cFilOrig)

Local cQuery	:= GetNextAlias()
Local nX  		:= 0
Local nPos  	:= 0
Local nCount	:= 0
Local cCod		:= ""
Local cLastDt	:= ""
Local cWhere	:= ""
Local cExit		:= EncodeUTF8(STR0008) //"Saída"
Local cEntry	:= EncodeUTF8(STR0009) //"Entrada"
Local aSentido 	:= {}

cWhere := "%"
cWhere += " RH3.RH3_FILAPR IN (" + cFilSRA + ", '" + cFilOrig + "' ) AND "
cWhere += " RH3.RH3_MATAPR IN (" + cMatSRA + ", '" + cMatAprov + "') "
cWhere += "%"

BEGINSQL ALIAS cQuery
	SELECT RH3_CODIGO, RH4.RH4_CAMPO, RH4_VALNOV
	FROM %table:RH3% RH3
	INNER JOIN %table:RH4% RH4 ON
		RH4_FILIAL = RH3_FILIAL AND
		RH4_CODIGO = RH3_CODIGO
	WHERE
		RH3.RH3_STATUS ='1' AND RH3.RH3_TIPO ='Z' AND
		RH4_CAMPO IN ('P8_DATA','P8_HORA','TMP_DIRECT') AND
		%Exp:cWhere% AND
        RH3.%notDel% AND RH4.%notDel%
    ORDER BY RH3_CODIGO, RH3_FILIAL, RH3_MAT
ENDSQL

//Inclui na matriz os marcacoes incluidas para aprovacao
While (cQuery)->(!Eof())

	If( AllTrim((cQuery)->RH4_CAMPO) == 'P8_DATA')
		nPos := 1
	Elseif ( AllTrim((cQuery)->RH4_CAMPO) == 'P8_HORA')
		nPos := 2
	Elseif ( AllTrim((cQuery)->RH4_CAMPO) == 'TMP_DIRECT')
		nPos := 5
	Endif						

	If !(cCod == (cQuery)->RH3_CODIGO)
		aAdd( aSentido, {Ctod("//"), "", "", (cQuery)->RH3_CODIGO, ""} )
		cCod := (cQuery)->RH3_CODIGO
	EndIf

	aSentido[Len(aSentido),nPos] := AllTrim(RH4_VALNOV)

	(cQuery)->(DbSkip())

Enddo

If Len(aSentido) > 0
	//Ordena as marcacoes incluidas por data e hora
	aSort(aSentido,,,{|x,y| DtoS(cTod(x[1]))+StrTran(StrZero( Val(x[2]),5,2),".", ":") < DtoS(cToD(y[1]))+StrTran(StrZero( Val(y[2]),5,2),".", ":") })

	//Se a direção não existir na solicitação classifica cada registro como entrada/saida de acordo com a ordem dos horarios
	For nX := 1 to Len(aSentido)
		If !Empty(aSentido[nX, 05])
			aSentido[nX,3] := EncodeUTF8(aSentido[nX, 05])
		Else
			nCount		:= If( cLastDt == aSentido[nX, 01], nCount, 0 )
			nCount++

			aSentido[nX,3] 	:= Iif(nCount % 2 == 0 , cExit, cEntry)
			cLastDt 	:= aSentido[nX, 01]
		EndIf
	Next nX
EndIf

(cQuery)->(DbCloseArea())

Return(aSentido)


/*/{Protheus.doc} fRequests
Retorna um array com as requisições realizadas
@author:	Henrique Ferreira
@since:		09/12/2019
@param:		cFilSRA  - Filial do aprovador;
			cMatSRA	 - Matricula do aprovador;
			cWhere	 - Array com as datas/horas classificadas como entrada/saida
			cTipoReq - Tipo de requisição ser filtrada na query
			cStatus  - Status a ser filtrado na query
@return: Array com as requisições filtradas de acordo com os parâmetros.
/*/
Function fRequests(cFilSRA, cMatSRA, cWhere, nCount, nIniCount, nFimCount, cFiltro, cFiltFunc, cFiltResp)
Local oFields    := JsonObject():New()
Local cQryRH3    := GetNextAlias()
Local aData      := {}
Local aReturn	 := {}
Local aEmployee  := {}
Local lFiltros   := .T.
Local nX		 := 0

DEFAULT nCount    := 0
DEFAULT nIniCount := 1
DEFAULT nFimCount := 6
DEFAULT cFiltro   := ""
DEFAULT cFiltFunc := ""
DEFAULT cFiltResp := ""

BeginSql alias cQryRH3
	SELECT
		RH3.RH3_CODIGO, 
		RH3.RH3_FILIAL, 
		RH3.RH3_MAT, 
		RH3.RH3_TIPO, 
		RH3.RH3_DTSOLI, 
		RH3.RH3_FILAPR, 
		RH3.RH3_MATAPR, 
		RH3.RH3_STATUS, 
		RH3.RH3_EMP,
		RH3_FILINI, 
		RH3_EMPINI, 
		RH3_MATINI,
		RH3.RH3_EMPAPR
	FROM  %table:RH3% RH3
	WHERE  RH3.%notDel% AND 
		   %Exp:cWhere%
	ORDER BY RH3_DTSOLI
EndSql

While (cQryRH3)->(!Eof())
	
	aEmployee := getSummary((cQryRH3)->RH3_MAT, (cQryRH3)->RH3_FILIAL, (cQryRH3)->RH3_EMP, cFiltro)

	//Não executa o filtro por nome para requisições de aumento de quadro.
	If !Empty(aEmployee[2]) .Or. ((cQryRH3)->RH3_TIPO == "3")
		aAdd(aData, { ;
						(cQryRH3)->RH3_FILIAL +"|"+ (cQryRH3)->RH3_MAT +"|"+ (cQryRH3)->RH3_EMP,						    		  					  ;	// 01 - MATRÍCULA DO FUNCIONÁRIO QUE SOFREU A AÇÃO
						aEmployee[2],																					    		  					  ; // 02 - NOME DO FUNCIONÁRIO QUE SOFREU A AÇÃO
						rc4crypt((cQryRH3)->RH3_FILIAL +"|"+ (cQryRH3)->RH3_MAT +"|"+ (cQryRH3)->RH3_EMP +"|"+ (cQryRH3)->RH3_CODIGO, "MeuRH#Requisicao"),;	// 03 - ID DA SOLICITAÇÃO (FILIAL + CODIGO DA SOLICITAÇÃO)
						(cQryRH3)->RH3_CODIGO,  												 			  											  ;	// 04 - CODIGO DA SOLICITAÇÃO.
						GetENUMDecode( (cQryRH3)->RH3_TIPO ),	 																						  ;	// 05 - TIPO DE SOLICITAÇÃO.
						(cQryRH3)->RH3_DTSOLI,   															  											  ; // 06 - DATA DA SOLICIAÇÃO.
						fGetRANome( (cQryRH3)->RH3_FILAPR, (cQryRH3)->RH3_MATAPR, (cQryRH3)->RH3_EMPAPR ),											      ;	// 07 - NOME DO RESPONSÁVEL APROVADOR NA ETAPA.
						getStatusWKF( (cQryRH3)->RH3_STATUS ),   																						  ; // 08 - STATUS DA SOLICITAÇÃO.
						fStatusLabel( (cQryRH3)->RH3_STATUS ),	 												  										  ; // 09 - DESCRIÇÃO DO STATUS DA SOLICITAÇÃO.
						(cQryRH3)->RH3_FILAPR + "|" + (cQryRH3)->RH3_MATAPR,									  										  ; // 10 - ID DO RESPONSÁVEL DO APROVADOR.
						If((cQryRH3)->RH3_TIPO == "3" , (cQryRH3)->RH3_FILIAL , NIL),                                   								  ; // 11 - FILIAL DA REQUISIÇÃO DE AUMENTO DE QUADRO
						If((cQryRH3)->RH3_TIPO == "3", fRH4Func((cQryRH3)->RH3_FILIAL, (cQryRH3)->RH3_CODIGO), NIL),    								  ; // 12 - FUNÇÃO DA REQUISIÇÃO DE AUMENTO DE QUADRO
						If((cQryRH3)->RH3_TIPO == "3", fRH4Vagas((cQryRH3)->RH3_FILIAL, (cQryRH3)->RH3_CODIGO), NIL),   								  ; // 13 - QUANTIDADE DE VAGAS DA REQUISIÇÃO DE AUMENTO DE QUADRO
						If((cQryRH3)->RH3_TIPO == "4", aEmployee[3], NIL),    																			  ; // 14 - DESCRICAO DA FUNCAO
						fGetRANome((cQryRH3)->RH3_FILINI, (cQryRH3)->RH3_MATINI, (cQryRH3)->RH3_EMPINI);
			})
	EndIf
	(cQryRH3)->(DbSkip())
EndDo
(cQryRH3)->( DBCloseArea() )

If Len(aData) > 0
	For nX := 1 to Len(aData)

		//Verificação do filtro de função.
		If!Empty(cFiltFunc)
			If !Empty(aData[nX,12])
				lFiltros := (cFiltFunc $ UPPER(DecodeUTF8(aData[nX,12])))
			EndIf
		EndIf

		//Verificação do filtro do nome do responsável.
		If !Empty(cFiltResp) .And. lFiltros
			If !Empty(aData[nX,7])
				lFiltros := (cFiltResp $ aData[nX,7])
			EndIf
		EndIf

		If lFiltros
			nCount++
			If ( nCount >= nIniCount .And. nCount <= nFimCount ) .And. lFiltros
				oFields   					:= JsonObject():New()
				oFields["employeeId"] 		:= aData[nX,1]
				oFields["employeeName"] 	:= aData[nX,2]
				oFields["id"] 				:= aData[nX,3]
				oFields["requestId"] 		:= aData[nX,4]
				oFields["requestType"] 		:= aData[nX,5]
				oFields["startDate"] 		:= SubStr(aData[nX,6],1,4) + "-" + SubStr(aData[nX,6],5,2) + "-" + SubStr(aData[nX,6],7,2) + "T" + "12:00:00" + "Z"
				oFields["responsableName"] 	:= aData[nX,7]
				oFields["status"] 			:= aData[nX,8]
				oFields["statusLabel"] 		:= aData[nX,9]
				oFields["responsableId"]  	:= aData[nX,10]
				oFields["siteCode"]         := aData[nX,11]
				oFields["roleDescription"]  := aData[nX,12]
				oFields["vacanciesNumber"]  := aData[nX,13]
				oFields["role"]  			:= aData[nX,14]
				oFields["requesterName"]  	:= aData[nX,15]					
				oFields["company"]  		:= Nil
				aAdd(aReturn, oFields)
			EndIf			
		EndIf

		lFiltros := .T.
	Next nX
EndIf

Return(aReturn)

/*/{Protheus.doc} fAvalAprRepr
Retorna um array com as requisições realizadas
@author:	Marcelo Faria
@since:		08/06/2019
@param:		cBody  - dados da requisição
			cToken - dados do usuário de login
			cKeyId - dados do usuário de login integrado Protheus/AD
			lCrypt - .T. se o Id da requisição vem criptografado.
@return:	string com ocorrências do processo de avaliação da solicitação
/*/
Function fAvalAprRepr(cToken, cBody, cKeyId, lCrypt)
Local oItemDetail   := JsonObject():New()
Local oRequest		:= WSClassNew("TRequest")
Local cOrgCFG		:= SuperGetMv("MV_ORGCFG", NIL, "0")
Local aRequests		:= {}
Local aGetStruct    := {}
Local aDataLogin	:= {}
Local aSubstitute	:= {}
Local aInfoReq	    := {}
Local aCposRH4		:= {}
Local aDadosSRH		:= {}
Local aPerFerias	:= {}
Local cSubMat		:= ""
Local cSubBranch 	:= ""
Local cFilToken		:= ""
Local cMatToken		:= ""
Local cRH3Fil       := ""
Local cRH3Tipo      := ""
Local cRH3Emp		:= ""
Local cRH3Mat       := ""
Local cRH3Cod       := ""
Local cApprover     := ""
Local cEmpApr       := cEmpAnt
Local cUsrCurrent   := ""
Local cFilApr       := ""
Local cJustify		:= ""
Local cMotive		:= ""
Local cMsg			:= ""
Local cDtIniFer		:= ""
Local cDtFimFer		:= ""
Local cDtBsIni		:= ""
Local cDtBsFim		:= ""
Local cIdCrypt      := ""
Local cFilGestor	:= ""
Local cMatGestor	:= ""
Local nX            := 0
Local nSupLevel     := 0
Local nCpos			:= 0
Local lAprove		:= .T.
Local lGestor		:= .F.
Local lSubstitute   := .F.
Local lContinua		:= .T.
Local lSolic13		:= .F.
Local nDiasFer		:= 0
Local nDiasAbono	:= 0
//Variáveis para chamada APIGetStructure para buscar o aprovador.
Local lDemitido     := .T.
Local lOnlySup      := .T.

DEFAULT cToken		:= ""
DEFAULT cBody		:= ""
DEFAULT lCrypt      := .F.

aDataLogin  := GetDataLogin(cToken,,cKeyId)
If Len(aDataLogin) > 0
	cMatToken	:= aDataLogin[1]
	cUsrCurrent	:= aDataLogin[1]
	cFilToken	:= aDataLogin[5]
EndIf

oItemDetail:FromJson(cBody)
lAprove     := If(oItemDetail:hasProperty("approved"), oItemDetail["approved"], .F.)
cJustify    := If(oItemDetail:hasProperty("justify"), AllTrim(oItemDetail["justify"]), "")
aRequests   := If(oItemDetail:hasProperty("requisitions"), oItemDetail["requisitions"], "")

If valtype(lAprove) == "L" .And. !Empty(aRequests) .and. !Empty(cToken)
	oRequest:Status	:= WSClassNew("TRequestStatus")
	oRequest:RequestType := WSClassNew("TRequestType")

	//Verifica se o funcionario esta substituindo o seu superior
	aSubstitute := fGetSupNotify( cFilToken, cMatToken)
	If Len(aSubstitute) > 0
		If lAprove
			//Chamada da apigetstructure para saber quem é o gestor do substituto cadastrado.
			cMRrhKeyTree := fMHRKeyTree(aSubstitute[1,1], aSubstitute[1,2])
			aGetStruct   := APIGetStructure("", cOrgCFG, RH3->RH3_VISAO, aSubstitute[1,1], aSubstitute[1,2], , , , RH3->RH3_TIPO, aSubstitute[1,1], aSubstitute[1,2], , , , , .T., {cEmpAnt}, {}, , lOnlySup, lDemitido)
			lGestor      := Len(aGetStruct) > 0 .and. (valtype(aGetStruct[1]:ListOfEmployee[1]:LevelSup) == "N")
			cFilGestor	 := If( lGestor, aGetStruct[1]:ListOfEmployee[1]:SupFilial, "")
			cMatGestor	 := If( lGestor, aGetStruct[1]:ListOfEmployee[1]:SupRegistration, "")
			For nX := 1 To Len(aSubstitute)
				//Se os dados do gestor for igual aos dados do substituto escolhido, então assume-se os dados do gestor para o fluxo de aprovação
				cSubMat	+= If( cFilGestor+cMatGestor == aSubstitute[nX,4]+aSubstitute[nX,5], aSubstitute[nX,5], aSubstitute[nX,2] )
				cSubBranch += If( cFilGestor+cMatGestor == aSubstitute[nX,4]+aSubstitute[nX,5], aSubstitute[nX,4], aSubstitute[nX,1])
				lSubstitute := .T.
			Next nX
		Else
			cEmpApr		:= cEmpAnt
			cSubBranch	:= cFilToken
			cSubMat		:= cMatToken
		EndIf	
	Else
		cSubMat	:= cMatToken
		cSubBranch := cFilToken
	EndIf

	//aprovação e reprovação em lote
	Begin Transaction
	
		For nX := 1 To Len( aRequests )
			If lCrypt
				cIdCrypt := rc4crypt(oItemDetail["requisitions"][nX]["id"], "MeuRH#Requisicao", .F., .T.)
				aInfoReq := STRTOKARR(cIdCrypt, "|")
			Else
				aInfoReq := STRTOKARR(oItemDetail["requisitions"][nX]["id"], "|")
			EndIf

			If Len(aInfoReq) > 3
				cRH3Fil := aInfoReq[1]
				cRH3Cod := aInfoReq[4]
			EndIf

			DbSelectArea("RH3")
			RH3->( dbSetOrder(1) )
		
			If RH3->( dbSeek(xFilial("RH3", cRH3Fil) + cRH3Cod ) )
				
				cRH3Mat  := RH3->RH3_MAT
				cRH3Tipo := RH3->RH3_TIPO
				cRH3Emp  := RH3->RH3_EMP

				//Em caso de férias, valida SRF/SRH antes de realizar a aprovação.
				If lAprove .And. (RH3->RH3_TIPO == "B")
					aCposRH4 := fGetRH4Cpos(cRH3Fil, cRH3Cod)
					If Len(aCposRH4) > 0
						For nCpos := 1 To Len(aCposRH4)
							If aCposRH4[nCpos,1] == "R8_DATAINI"
								cDtIniFer := aCposRH4[nCpos,2]
							ElseIf aCposRH4[nCpos,1] == "R8_DATAFIM"
								cDtFimFer := aCposRH4[nCpos,2]
							ElseIf aCposRH4[nCpos,1] == "R8_DURACAO"
								nDiasFer := Val(aCposRH4[nCpos,2])
							ElseIf aCposRH4[nCpos,1] == "TMP_ABONO"
								nDiasAbono := Val(aCposRH4[nCpos,2])
							ElseIf aCposRH4[nCpos,1] == "TMP_1P13SL"
								lSolic13 := &(aCposRH4[nCpos,2])
							ElseIf aCposRH4[nCpos,1] == "RF_DATABAS"
								cDtBsIni := aCposRH4[nCpos,2]
							ElseIf aCposRH4[nCpos,1] == "RF_DATAFIM"
								cDtBsFim := aCposRH4[nCpos,2]
							EndIf 
						Next nCpos

						//Ferias que foram solicitadas pelo Portal GCH não possuem os dados do período aquisitivo.
						If Empty(cDtBsIni) .And. Empty(cDtBsFim)
							GetDtBasFer(cRH3Fil, cRH3Mat, @aPerFerias, RH3->RH3_EMP)
							If Len(aPerFerias) > 0
								cDtBsIni := DTOC(aPerFerias[1,1])
								cDtBsFim := DTOC(aPerFerias[1,2])
							EndIf
						EndIf

						If !Empty( cMsg := fVldSRF(cRH3Fil, cRH3Mat, cDtIniFer, nDiasFer, nDiasAbono, lSolic13, cDtBsIni, RH3->RH3_EMP) )
							lContinua := .F.
							cMsg := EncodeUTF8(cMsg)
						EndIf
						If lContinua
							aDadosSRH := fGetSRH( cRH3Fil, cRH3Mat, CTOD(cDtBsIni), CTOD(cDtBsFim), RH3->RH3_EMP)
						   	If !Empty(cMsg := fVldSRH(cRH3Fil, cRH3Mat, cDtIniFer, cDtFimFer, nDiasFer, nDiasAbono, aDadosSRH, cDtBsIni, cDtBsFim) )
								lContinua := .F.
								cMsg := EncodeUTF8(cMsg)
							EndIf
						EndIf
					EndIf
				EndIf

				If lContinua
					if lAprove
						//Dados da estrutura hierarquica
						cMRrhKeyTree := fMHRKeyTree(cSubBranch, cSubMat)
						aGetStruct   := APIGetStructure("", cOrgCFG, RH3->RH3_VISAO, cSubBranch, cSubMat, , , , RH3->RH3_TIPO, cSubBranch, cSubMat, , , , , .T., {cEmpAnt}, {}, , lOnlySup, lDemitido)
						
						If len(aGetStruct) > 0 .and. (valtype(aGetStruct[1]:ListOfEmployee[1]:LevelSup) == "N") .and. (aGetStruct[1]:ListOfEmployee[1]:LevelSup != 99)
							cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
							cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
							nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
							cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
						Else
							nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
						EndIf
						//Verifica se o aprovador eh o usuario corrente. Se positivo o APRROVER deve ficar "''" 
						cApprover := If( cApprover == cUsrCurrent, "", cApprover )	
					Else
						cEmpApr   := cEmpAnt
						cFilApr   := cSubBranch
						cApprover := cSubMat
					EndIf
					
					//Inclui justificativa padrao caso nao tenha sido informada
					If Empty( cJustify )
						cMotive := If( lAprove, STR0016, STR0017 ) //"Aprovado via App MeuRH em:"#"Reprovado via App MeuRH em:"
						cMotive := Alltrim( EncodeUTF8( cMotive ) + Space(1) + dToC(date()) + Space(1) + Time() )
					Else
						If RH3->RH3_TIPO $ "3/6/7/4/Z"
							cMotive := DecodeUTF8(cJustify)
						Else
							cMotive := EncodeUTF8(cJustify)
						EndIf						
					EndIf

					//Justificativa especifica quando é rejeicao de ferias
					If RH3->RH3_TIPO == "B" .And. !lAprove //Ferias
						If( !Empty( oItemDetail["requisitions"][nX]["reason"]) )
							cMotive := DecodeUTF8(oItemDetail["requisitions"][nX]["reason"])
							If Len( cMotive ) > 50
								cMsg := EncodeUTF8(STR0023) //"O motivo deve ter no máximo 50 caracteres!"
								lContinua := .F.
							EndIf
						Else							
							cMsg := EncodeUTF8(STR0022) //"É obrigatório informar um motivo para a reprovação!"
							lContinua := .F.
						EndIf
					EndIf
				EndIf					

				If lContinua
					
					oRequest:Empresa				:= cRH3Emp
					oRequest:Branch 				:= cRH3Fil
					oRequest:Registration			:= cRH3Mat
					oRequest:Code 					:= cRH3Cod
					oRequest:Observation 			:= cMotive
			
					oRequest:ApproverBranch			:= cFilApr
					oRequest:ApproverRegistration 	:= cApprover
					oRequest:EmpresaAPR				:= cEmpApr
					oRequest:ApproverLevel			:= nSupLevel
					oRequest:RequestType:Code 		:= RH3->RH3_TIPO
			
					//Guarda os dados da aprovacao feita pelo substituto para geracao do historico
					If lSubstitute
						oRequest:ApproverSubBranch		:= cFilToken
						oRequest:ApproverSubRegistration:= cMatToken
					EndIf
			
					If lAprove
						ApproveRequest(oRequest, .T.)
					Else
						ReproveRequest(oRequest, .T.)
						If cRH3Tipo == "Z" //Atualiza a tabela transitoria RS3 quando a batida é reprovada
							fRS3UpdStatus(cRH3Fil, cRH3Cod)
						EndIf						
					EndIf
				EndIf
			Else
				If Empty(cMsg)
					cMsg := EncodeUTF8(STR0020) + cRH3Cod //"Não foi possível realizar operação para essas solicitações: " 
				else
					cMsg += "," +cRH3Cod 
				EndIf		
			EndIf

			aInfoReq := {}
		
		Next nX
	
	End Transaction

Else
	cMsg := EncodeUTF8(STR0018)  //"Não foi possível realizar essa operação. Verifique os dados e o status das requisições selecionadas." 
EndIF

Return cMsg


/*/{Protheus.doc} fGetEmpReq
Retorna um array com as requisições realizadas
@author:	Alberto Ortiz
@since:		08/04/2020
@param:		aDataLogin - Dados do usuário logado, no formato do retorno da GetDataLogin
            aQryParam - Filtros para utilizar na APIGetStructure no formato aQueryString
			cRequestType - 
			lMorePages - Variável para verificar se será necessário mais de uma página.
@return:	Dados dos funcionários no formato - "employeesRequisitionsResponse"
/*/
Function fGetEmpReq(aDataLogin, aQryParam, lMorePages)
	Local aVision       := {}
	Local aEmpresas     := Nil
	Local aCoordTeam    := {}
	Local aItens        := {}
	Local cOrgCFG       := GetMv("MV_ORGCFG", NIL, "0")
	Local cVision       := Nil
	Local cRoutine      := "W_PWSA120.APW"
	Local cEmpStruct    := ""
	Local cFilStruct    := ""
	Local cMatStruct    := ""
	Local cRD0Login     := ""
	Local cCodRD0       := ""
	Local cMatSRA       := ""
	Local cBranchVld    := ""
	Local lContinua     := .F.
	Local lNomeSoc      := SuperGetMv("MV_NOMESOC", NIL, .F.)
	Local lDemit        := .F.
	Local nX            := 1
	Local nPos			:= 0
	Local oEmployee     := JsonObject():New()

	DEFAULT aDataLogin   := {}
	DEFAULT aQryParam    := {}
	DEFAULT lMorePages   := .F.

	If Len(aDataLogin) > 0
		cMatSRA		:= aDataLogin[1]
		cRD0Login	:= aDataLogin[2]
		cCodRD0		:= aDataLogin[3]
		cBranchVld	:= aDataLogin[5]
		lDemit      := aDataLogin[6]
	EndIf

	If Len( aQryParam ) > 0
		If ( nPos := aScan( aQryParam, { |x| Upper(x[1]) == "REQUISITIONTYPE" } ) ) > 0
			cRoutine := iif( Upper( aQryParam[nPos,2] ) == "DATACHANGEEMPLOYEE", "W_PWSA120.APW", "W_PWSA140.APW" )
		EndIf
	EndIf

	//Quando utiliza SIGORG carrega a relacao de empresas abrangidas pelo funcionario dentro da visao
	If !(cOrgCFG == "0")
		aVision := GetVisionAI8(cRoutine, cBranchVld)
		cVision := aVision[1][1]
		aEmpresas := {}
		fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T.)
	EndIf

	aCoordTeam := APIGetStructure(cCodRD0, cOrgCFG, cVision, cBranchVld, cMatSRA, , , , Nil, cBranchVld, cMatSRA, , , , , .T., aEmpresas, aQryParam, @lMorePages)
	lContinua  := Len(aCoordTeam) > 0 .And. !ValType( aCoordTeam[1] ) == "L" //Verifica se carregou dados da hierarquia.

	If lContinua
		For nX := 1 To Len(aCoordTeam[1]:ListOfEmployee)

			cEmpStruct := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeEmp
			cFilStruct := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeFilial
			cMatStruct := aCoordTeam[1]:ListOfEmployee[nX]:Registration

			//Remove o coordinatorId caso ele esteja na estrutura.
			If !(cEmpStruct+cFilStruct+cMatStruct == cEmpAnt+cBranchVld+cMatSRA)
				oEmployee                                 := JsonObject():New()
				oEmployee["id"]                           := cFilStruct + "|" + cMatStruct + "|" + cEmpStruct
				oEmployee["name"]                         := Alltrim(EncodeUTF8(If(lNomeSoc .And. !Empty(aCoordTeam[1]:ListOfEmployee[nX]:SOCIALNAME), aCoordTeam[1]:ListOfEmployee[nX]:SOCIALNAME, aCoordTeam[1]:ListOfEmployee[nX]:NAME)))
				oEmployee["admissionDate"]                := formatGMT(aCoordTeam[1]:ListOfEmployee[nX]:ADMISSIONDATE) 
				oEmployee["salary"]                       := aCoordTeam[1]:ListOfEmployee[nX]:SALARY 
				oEmployee["registry"]                     := aCoordTeam[1]:ListOfEmployee[nX]:REGISTRATION
				oEmployee["department"]                   := Alltrim(aCoordTeam[1]:ListOfEmployee[nX]:DESCRDEPARTMENT)
				oEmployee["salaryLevel"]                  := Nil 
				oEmployee["function"]                     := Alltrim(aCoordTeam[1]:ListOfEmployee[nX]:FUNCTIONDESC)
				oEmployee["salaryRange"]                  := Nil 
				oEmployee["role"]                         := Nil 
				oEmployee["costCenter"]                   := Alltrim(aCoordTeam[1]:ListOfEmployee[nX]:COST)
				oEmployee["category"]                     := Alltrim(aCoordTeam[1]:ListOfEmployee[nX]:CATFUNCDESC)
				oEmployee["currentHierarchicalStructure"] := Nil 
				oEmployee["idFunction"]                   := aCoordTeam[1]:ListOfEmployee[nX]:FUNCTIONID
				oEmployee["idDepartment"]                 := cEmpStruct + "|" + ;
																cFilStruct + "|" + ;
																aCoordTeam[1]:ListOfEmployee[nX]:DEPARTMENT
				Aadd(aItens, oEmployee)			
			EndIf
		Next nX
	EndIf

Return aItens

/*/{Protheus.doc} fGetEmpReq
Retorna um array com as requisições realizadas
@author:	Henrique Ferreira
@since:		18/04/2022
@param:		cBranchVld - Filial do Funcionário Logado
            cMatSRA - Matrícula do Funcionário Logado
			aIdReq - Dados da requisição que está sendo consultada.
@return:	Dados dos funcionários no formato - "employeesRequisitionsResponse"
/*/
Function fDetailReq(cBranchVld, cMatSRA, cEmpSRA, cCodReq, lJob, cUID)

	Local oItens		:= JsonObject():New()
	Local oReason		:= JsonObject():New()
	Local oCateg		:= JsonObject():New()
	Local cTipoAlt		:= ""
	Local cNewCargo 	:= ""
	Local cNewFunc		:= ""
	Local cNewCateg		:= ""
	Local cJustify		:= ""
	Local nPercent		:= 0
	Local nCpos			:= 0
	Local nNewSal		:= 0
	Local aAreaSRA      := {}
	Local aAreaRH3		:= {}
	Local aCposRH4		:= {}
	Local aSX5			:= {}
	Local dDtSolic		:= ctod("//")

	DEFAULT cBranchVld := ""
	DEFAULT cMatSRA    := ""
	DEFAULT lJob	   := .F.
	DEFAULT cUID	   := ""

	If lJob
		RPCSetType( 3 )
		RPCSetEnv( cEmpSRA, cBranchVld )
   EndIf

	aAreaSRA := SRA->(GetArea())
	aAreaRH3 := RH3->(GetArea())

	If SRA->(dbSeek(cBranchVld+cMatSRA))
		//Dados do funcionário
		oItens["role"] 				:= Alltrim( EncodeUTF8( FDesc("SRJ", SRA->RA_CODFUNC, "RJ_DESC",,cBranchVld ) ) )
		oItens["departament"] 		:= Iif( !Empty(SRA->RA_DEPTO), ;
											Alltrim( EncodeUTF8( FDesc("SQB", SRA->RA_DEPTO, "QB_DESCRIC",,cBranchVld ) ) ), ;
											EncodeUTF8( STR0028 ) )
		oItens["costCenter"] 		:= Alltrim( EncodeUTF8( FDesc("CTT", SRA->RA_CC, "CTT_DESC01",,cBranchVld ) ) )
		oItens["employeeSituation"] := IIf( Empty(SRA->RA_SITFOLH), 'N', SRA->RA_SITFOLH )

		//Dados da Requisição.
		aCposRH4 := fGetRH4Cpos(cBranchVld, cCodReq)
		If Len(aCposRH4) > 0
			For nCpos := 1 To Len(aCposRH4)
				If aCposRH4[nCpos,1] == "RB7_TPALT"
					cTipoAlt := AllTrim(aCposRH4[nCpos,2])
				ElseIf aCposRH4[nCpos,1] == "RB7_FUNCAO"
					cNewFunc := AllTrim(aCposRH4[nCpos,2])
				ElseIf aCposRH4[nCpos,1] == "RB7_CARGO"
					cNewCargo := AllTrim(aCposRH4[nCpos,2])
				ElseIf aCposRH4[nCpos,1] == "RB7_SALARI"
					nNewSal := Val(aCposRH4[nCpos,2])
				ElseIf aCposRH4[nCpos,1] == "RB7_CATEG"
					cNewCateg := AllTrim(aCposRH4[nCpos,2])
				Elseif aCposRH4[nCpos,1] == "RB7_PERCEN"
					nPercent := Val(aCposRH4[nCpos,2])
				EndIf 
			Next nCpos
		EndIf


		cJustify 						:= AllTrim(GetRGKJustify(xFilial("RGK", cBranchVld), cCodReq, ,.T.))
		oItens["justification"]		 	:= cJustify
		oItens["percentageIncrease"] 	:= nPercent
		oItens["id"]					:= cCodReq
		oItens["newRole"] 				:= IIf( !Empty(cNewCargo), ;
												Alltrim( EncodeUTF8( FDesc("SQ3", cNewCargo, "Q3_DESCSUM",,cBranchVld ) ) ), ;
												EncodeUTF8( STR0028 )) // Não informado.
		oItens["newFunction"] 			:= IIf( !Empty(cNewFunc), ;
												Alltrim( EncodeUTF8( FDesc("SRJ", cNewFunc, "RJ_DESC",,cBranchVld ) ) ), ;
												EncodeUTF8( STR0028 ) ) // Não informado.
		oItens["proposedSalary"]		:= nNewSal


		dDtSolic 						:= PosAlias( "RH3", cCodReq, cBranchVld, "RH3_DTSOLI", 1 )
		oItens["requisitionDate"]		:= FormatGMT(DtoS(dDtSolic), .T.)

		aSX5 							:= FWGetSX5("41", cTipoAlt )
		If Len(aSX5) > 0
			oReason["idCompany"]		:= AllTrim(aSX5[1,1])
			oReason["id"] 				:= AllTrim(aSX5[1,3])
			oReason["name"]				:= AllTrim(EncodeUTF8( aSX5[1,4] ))

			oItens["changeSalaryReason"] := oReason
		EndIf

		aSX5 							:= FWGetSX5("28", cNewCateg )
		If Len(aSX5) > 0
			oCateg["idCompany"]			:= AllTrim(aSX5[1,1])
			oCateg["id"] 				:= AllTrim(aSX5[1,3])
			oCateg["name"]				:= AllTrim(EncodeUTF8( aSX5[1,4] ))

			oItens["categoryChangeType"] := oCateg
		EndIf

		//Dados do arquivo de imagem.
		oItens["file"] 			:= NIL
		oItens["hasAttachment"] := .F.

		//Dados não utilizados no Protheus
		oItens["newHire"] 						:= NIL
		oItens["expectedDate"]					:= NIL
		oItens["changeFunctionReason"]  		:= NIL
		oItens["expectedDate"]  				:= NIL
		oItens["currentHierarchicalStructure"] 	:= NIL
		oItens["newHierarchicalStructure"] 		:= NIL
		oItens["progressiveIncrease"]           := NIL
	EndIf

	RestArea(aAreaSRA)
	RestArea(aAreaRH3)

	If lJob
      //Atualiza a variavel de controle que indica a finalizacao do JOB
      PutGlbValue(cUID, "1")
   EndIf

   FreeObj(oReason)
   FreeObj(oCateg)

Return oItens



/*/{Protheus.doc} fDetailTrnsf
Retorna um objeto com os dados da requisição de transferência.
@author:	Alberto Ortiz
@since:		12/08/2022
@param:		cBranchVld - Filial do Funcionário Logado
            cMatSRA - Matrícula do Funcionário Logado
			aIdReq - Dados da requisição que está sendo consultada.
@return:	Dados da requisição no formato - "transfInfo"
/*/
Function fDetailTrnsf(cBranchVld, cMatSRA, cEmpSRA, cCodReq, lJob, cUID)

	Local oItem		  := JsonObject():New()
	Local cEmpPara    := ""
	Local cFilPara    := ""
	Local cCCPara     := EncodeUTF8(STR0028) // Não Informado
	Local cProcPara   := EncodeUTF8(STR0028) // Não Informado
	Local cDeptoPara  := EncodeUTF8(STR0028) // Não Informado
	Local dDtSolic		:= ctod("//")
	Local nCpos			:= 0
	Local aAreaSRA      := {}
	Local aAreaRH3		:= {}
	Local aCposRH4		:= {}
	Local aSM0Cpos		:= {"M0_NOME","M0_FILIAL"}
	Local aSM0Data		:= {}
	Local lLenSM0       := .F.

	DEFAULT cBranchVld := ""
	DEFAULT cMatSRA    := ""
	DEFAULT lJob	   := .F.
	DEFAULT cUID	   := ""

	If lJob
		RPCSetType( 3 )
		RPCSetEnv( cEmpSRA, cBranchVld )
	EndIf

	aAreaSRA := SRA->(GetArea())
	aAreaRH3 := RH3->(GetArea())

	If SRA->(dbSeek(cBranchVld+cMatSRA))
		//Dados do funcionário
		oItem["role"] 				:= Alltrim( EncodeUTF8( FDesc("SRJ", SRA->RA_CODFUNC, "RJ_DESC", ,cBranchVld ) ) )
		oItem["employeeSituation"]  := IIf( Empty(SRA->RA_SITFOLH), 'N', SRA->RA_SITFOLH )

		//Dados da Requisição.
		aCposRH4 := fGetRH4Cpos(cBranchVld, cCodReq)
		For nCpos := 1 To Len(aCposRH4)
			If aCposRH4[nCpos,1] == "RE_EMPP"
				cEmpPara   := aCposRH4[nCpos,2]
			Elseif aCposRH4[nCpos,1] == "RE_FILIALP"
				cFilPara   := aCposRH4[nCpos,2]
			Elseif aCposRH4[nCpos,1] == "TMP_DCCP"
				cCCPara    := aCposRH4[nCpos,2]
			Elseif aCposRH4[nCpos,1] == "TMP_DPROCP"
				cProcPara  := aCposRH4[nCpos,2]
			ElseIf aCposRH4[nCpos,1] == "TMP_DDEPTO"
				cDeptoPara := aCposRH4[nCpos,2]
			EndIf 
		Next nCpos

		aSM0Data := FWSM0Util():GetSM0Data( ;
						IIf( !Empty(cEmpPara), cEmpPara, cEmpSRA ), ;
						Iif( !Empty(cFilPara), cFilPara, cBranchVld ), ;
						aSM0Cpos ) // Dados do cadastro de empresas.
		lLenSM0  := Len(aSM0Data) > 0

		cJustify    := AllTrim(GetRGKJustify(xFilial("RGK", cBranchVld), cCodReq, ,.T.))
		dDtSolic 	:= PosAlias("RH3", cCodReq, cBranchVld, "RH3_DTSOLI", 1)

		oItem["id"]				 := cCodReq
		oItem["justify"]         := If(!Empty(cJustify), cJustify, EncodeUTF8(STR0028))      // Não Informado
		oItem["requisitionDate"] := FormatGMT(DtoS(dDtSolic), .T.)
		oItem["company"]         := If(lLenSM0, AllTrim(aSM0Data[1,2]), EncodeUTF8(STR0046)) // Não cadastrado
		oItem["branch"]          := If(lLenSM0, AllTrim(aSM0Data[2,2]), EncodeUTF8(STR0046)) // Não cadastrado
		oItem["costCenter"]      := cCCPara
		oItem["department"]      := cDeptoPara
		oItem["process"]         := cProcPara

		//Dados do arquivo de imagem.
		oItem["file"] 			:= NIL
		oItem["hasAttachment"]  := .F.

		//Dados não utilizados no Protheus
		oItem["expectedDate"]		   := NIL
		oItem["changeFunction"]        := NIL
		oItem["changeFunctionReason"]  := NIL
		oItem["hierarchicalStructure"] := NIL
		oItem["newFunction"]           := NIL
		oItem["generateNewHire"]       := NIL
		oItem["transferVacancy"]       := NIL
		oItem["departmentChangeTypes"] := NIL
	EndIf

	RestArea(aAreaSRA)
	RestArea(aAreaRH3)

	If lJob
      //Atualiza a variavel de controle que indica a finalizacao do JOB
      PutGlbValue(cUID, "1")
   EndIf

Return oItem


/*/{Protheus.doc} fTrnsfDetail
Retorna um objeto com os dados da requisição de transferência.
@author:	Alberto Ortiz
@since:		17/11/2022
@param:		cBranchVld - Filial do Funcionário Logado
            cMatSRA    - Matrícula do Funcionário Logado
			aIdReq     - Dados da requisição que está sendo consultada.
@return:	Dados da requisição no formato - "SaveTransfRequest"
/*/
Function fTrnsfDetail(cBranchVld, cMatSRA, aIdReq)

	Local cFilReq	       := ""
	Local cMatReq	       := ""
	Local cEmpReq	       := ""
	Local cCodReq	       := ""
	Local cEmpPara         := ""
	Local cFilPara         := ""
	Local cProcParaDesc    := ""
	Local cProcParaId      := ""
	Local cDeptoParaDesc   := ""
	Local cDeptoParaId     := ""
	Local cCCParaDesc      := ""
	Local cCCParaId        := ""
	Local cRole            := ""
	Local cRequisitionDate := ""

	Local nCpos := 0

	Local oItem		  			 := Nil
	Local oCompany    			 := Nil
	Local oDepartment 			 := Nil
	Local oBranch     			 := Nil
	Local oCostCenter 			 := Nil
	Local oProcess    			 := Nil
	Local oEmployeesRequisitions := Nil

	Local aCposRH4		:= {}
	Local aSM0Cpos		:= {"M0_NOME","M0_FILIAL","M0_CGC"}
	Local aSM0Data		:= {}

	Local lLenSM0       := .F.

	DEFAULT cBranchVld := ""
	DEFAULT cMatSRA    := ""
	DEFAULT aIdReq     := {}

	cFilReq		:= aIdReq[1]
	cMatReq		:= aIdReq[2]
	cEmpReq		:= aIdReq[3]
	cCodReq		:= aIdReq[4]

	oItem 	   := JsonObject():New()

	//Buscando dados da Requisição.
	aCposRH4 := fGetRH4Cpos(cFilReq, cCodReq)
	For nCpos := 1 To Len(aCposRH4)
		If aCposRH4[nCpos,1] == "RE_EMPP"
			cEmpPara       := aCposRH4[nCpos,2]
		Elseif aCposRH4[nCpos,1] == "RE_FILIALP"
			cFilPara       := aCposRH4[nCpos,2]
		Elseif aCposRH4[nCpos,1] == "TMP_DPROCP"
			cProcParaDesc  := aCposRH4[nCpos,2]
		Elseif aCposRH4[nCpos,1] == "RE_PROCESS"
			cProcParaId    := aCposRH4[nCpos,2]
		ElseIf aCposRH4[nCpos,1] == "TMP_DDEPTO"
			cDeptoParaDesc := aCposRH4[nCpos,2]
		ElseIf aCposRH4[nCpos,1] == "RE_DEPTOP"
			cDeptoParaId   := aCposRH4[nCpos,2]
		ElseIf aCposRH4[nCpos,1] == "TMP_DCCP"
			cCCParaDesc    := aCposRH4[nCpos,2]
		ElseIf aCposRH4[nCpos,1] == "RE_CCP"
			cCCParaId      := aCposRH4[nCpos,2]
		EndIf 
	Next nCpos

	//Busca CNPJ e Nome da filial destino.
	aSM0Data := FWSM0Util():GetSM0Data( ;
					If( !Empty(cEmpPara), cEmpPara, cEmpReq ), ;
					If( !Empty(cFilPara), cFilPara, cFilReq ), ;
					aSM0Cpos ) // Dados do cadastro de empresas.
	
	//Verifica se os dados vieram corretamente.
	lLenSM0  := Len(aSM0Data) > 0

	//Dados da requisição - Justifica e data de solicitação.
	cJustify    	 := AllTrim(GetRGKJustify(xFilial("RGK", cFilReq), cCodReq, ,.T.))
	cJustify    	 := If(!Empty(cJustify), cJustify, EncodeUTF8(STR0028)) // Não Informado
	cRequisitionDate := FormatGMT(DtoS(PosAlias("RH3", cCodReq, cFilReq, "RH3_DTSOLI", 1)), .T.)

	//Busca dados do funcionário na função getNewEmpReq e começa a configuração do oItem.
	oEmployeesRequisitions := GetDataForJob( "15", { cEmpReq, cFilReq, cMatReq}, cEmpReq )

	cRole := oEmployeesRequisitions["raCodFuncDesc"]

	//Remoção da propriedade raCodFuncDesc não utilizada no padrão SaveTransfRequest.
	oEmployeesRequisitions:DelName("raCodFuncDesc")

	//Criação do oCompany (Grupo de empresas Destino RH4).
	If !Empty(cEmpPara)
		oCompany               := JsonObject():New()
		oCompany["id"]         := cEmpPara
		oCompany["name"]       := If(lLenSM0, AllTrim(aSM0Data[1,2]), EncodeUTF8(STR0046)) // Não cadastrado
		oCompany["identifier"] := Nil
	EndIf

	//Criação do oBranch (Filial Destino RH4).
	If !Empty(cFilPara)
		oBranch         := JsonObject():New()
		oBranch["id"]   := cFilPara
		oBranch["name"] := If(lLenSM0, AllTrim(aSM0Data[2,2]), EncodeUTF8(STR0046)) // Não cadastrado
		oBranch["cnpj"] := If(lLenSM0, AllTrim(aSM0Data[3,2]), EncodeUTF8(STR0046)) // Não cadastrado
	EndIf

	//Criação do oCostCenter (Centro de custo Destino RH4).
	If !(Empty(cCCParaDesc) .Or. Empty(cCCParaId))
		oCostCenter         := JsonObject():New()
		oCostCenter["id"]   := cCCParaId
		oCostCenter["name"] := cCCParaDesc
	EndIf

	//Criação do oDepartment (Departamento Destino RH4).
	If !(Empty(cDeptoParaDesc) .Or. Empty(cDeptoParaId))
		oDepartment              := JsonObject():New()
		oDepartment["id"]        := cDeptoParaId
		oDepartment["name"]      := cDeptoParaDesc
		oDepartment["companyId"] := If(!Empty(cEmpPara), cEmpPara, cEmpReq)
	EndIf

	//Criação do oProcess (Processo Destino RH4).
	If !(Empty(cProcParaId) .Or. Empty(cProcParaDesc))
		oProcess         := JsonObject():New()
		oProcess["id"]   := cProcParaId
		oProcess["name"] := cProcParaDesc
	EndIf

	//Atribuição do objeto oItem.

	//Dados do funcionário atuais.
	oItem["role"] 			   	   := cRole
	oItem["justify"]           	   := cJustify
	oItem["requisitionDate"]   	   := cRequisitionDate
	oItem["employeesRequisitions"] := oEmployeesRequisitions

	//Dados da requisição (Destino da transferência RH4)
	oItem["company"]     := oCompany
	oItem["branch"]      := oBranch
	oItem["department"]  := oDepartment
	oItem["process"]     := oProcess
	oItem["costCenter"]  := oCostCenter
	
	//Dados do arquivo de imagem.
	oItem["file"] 			:= Nil
	oItem["hasAttachment"]  := .F.

	//Dados não utilizados no Protheus
	oItem["expectedDate"]		   := Nil
	oItem["changeFunction"]        := Nil
	oItem["changeFunctionReason"]  := Nil
	oItem["hierarchicalStructure"] := Nil
	oItem["newFunction"]           := Nil
	oItem["generateNewHire"]       := Nil
	oItem["transferVacancy"]       := Nil
	oItem["departmentChangeTypes"] := Nil

Return oItem

/*/{Protheus.doc} fJobFunc
Retorna um array com as funções que serão utilizadas na solicitação de ação salarial
@author:	Henrique Ferreira
@since:		18/04/2022
@param:		aQryParam - Array com os querysParams (Page, PageSize, Filter)
@return:	Lista com as funções.
/*/
Function fJobFunc(cCodEmp, cCodFil, nPage, nPageSize, cFilter, lJob, cUID)

Local oJobFunc	:= JsonObject():New()
Local oRet		:= JsonObject():New()
Local oJobRole	:= JsonObject():New()

Local lMorePage		:= .F.
Local lBloq			:= .F.

Local nRegIni		:= 0
Local nRegFim	 	:= 0
Local nCount		:= 0

Local aJobFunc		:= {}

Local cWhere   		:= ""
Local cQuery   		:= ""

DEFAULT nPage 		:= 1
DEFAULT nPageSize 	:= 10
DEFAULT lJob 		:= .F.
DEFAULT cUID 		:= ""

If lJob
	//Instancia o ambiente para a empresa onde a funcao sera executada
	RPCSetType( 3 )
	RPCSetEnv( cCodEmp, cCodFil )
EndIf

cQuery := GetNextAlias()
lBloq := SRJ->(ColumnPos("RJ_MSBLQL")) > 0

cWhere := "%"
cWhere += Iif( lBloq, " AND SRJ.RJ_MSBLQL <> '1' ", "" )
If !Empty(cFilter)
	cWhere += " AND ( ( SRJ.RJ_DESC LIKE '%" + cFilter + "%' )"
	cWhere += " OR ( SRJ.RJ_CODCBO LIKE '%" + cFilter + "%' ) ) "
EndIf
cWhere += "%"

BEGINSQL ALIAS cQuery

SELECT SRJ.RJ_FILIAL, SRJ.RJ_FUNCAO, SRJ.RJ_DESC, SRJ.RJ_CODCBO, SRJ.RJ_SALARIO, SRJ.RJ_CARGO 
	FROM %table:SRJ% SRJ
WHERE SRJ.RJ_FILIAL = %exp:xFilial("SRJ", cCodFil)%
	AND SRJ.%notDel%
	%exp:cWhere%
	ORDER BY 1,2
ENDSQL
(cQuery)->(DbGoTop())

//Controle de Paginação
If nPage == 1
	nRegIni := 1
	nRegFim := nPageSize
Else
	nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
	nRegFim := ( nRegIni + nPageSize ) - 1
EndIf

While (cQuery)->(!Eof())
	nCount ++
	If ( nCount >= nRegIni .And. nCount <= nRegFim )
		oJobFunc			  := JsonObject():New()
		oJobFunc["id"] 		  := Alltrim( (cQuery)->RJ_FUNCAO )
		oJobFunc["idCompany"] := Iif( !Empty( (cQuery)->RJ_FILIAL ), (cQuery)->RJ_FILIAL, NIL )
		oJobFunc["name"]	  := Alltrim( EncodeUTF8( (cQuery)->RJ_DESC ) )
		oJobFunc["cbo"]		  := Alltrim( (cQuery)->RJ_CODCBO )
		oJobFunc["salary"]	  := (cQuery)->RJ_SALARIO
		oJobFunc["role"]	  := NIL

		//Busca Cargo, caso exista cargo vinculado à função.
		If !Empty( (cQuery)->RJ_CARGO )
			oJobRole := JsonObject():New()
			fGetCarg( cCodFil, (cQuery)->RJ_CARGO, @oJobRole )
			oJobFunc["role"] := oJobRole
		EndIf
		aAdd( aJobFunc, oJobFunc )
	Else
		If nCount >= nRegFim
			lMorePage := .T.
			Exit
		EndIf
	EndIf
	(cQuery)->( DbSkip() )
EndDo

(cQuery)->(dbCloseArea())

oRet["items"] 	:= aJobFunc
oRet["hasNext"] := lMorePage

If lJob
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

FREEOBJ( oJobRole )
FREEOBJ( oJobFunc )

Return oRet

/*/{Protheus.doc} fJobRoles
Retorna um array com os cargos que serão utilizadas na solicitação de ação salarial
@author:	Henrique Ferreira
@since:		18/04/2022
@param:		aQryParam - Array com os querysParams (Page, PageSize, Filter)
@return:	Lista com os cargos.
/*/
Function fJobRoles(cCodEmp, cCodFil, nPage, nPageSize, cFilter, lJob, cUID)

Local oRoleFunc	:= JsonObject():New()
Local oRet		:= JsonObject():New()

Local lMorePage		:= .F.
Local lBloq			:= .F.

Local nRegIni		:= 0
Local nRegFim	 	:= 0
Local nCount		:= 0

Local aRoleFunc		:= {}

Local cWhere   		:= ""
Local cQuery   		:= ""

DEFAULT lJob := .F.
DEFAULT cUID := ""

If lJob
	//Instancia o ambiente para a empresa onde a funcao sera executada
	RPCSetType( 3 )
	RPCSetEnv( cCodEmp, cCodFil )
EndIf

lBloq := SQ3->(ColumnPos("Q3_MSBLQL")) > 0
cWhere := "%"
cWhere += iif( lBloq, " AND SQ3.Q3_MSBLQL <> '1' ", "" )
If !Empty(cFilter)
	cWhere += " AND SQ3.Q3_DESCSUM LIKE '%" + cFilter + "%'"
EndIf
cWhere += "%"

cQuery := GetNextAlias()

BEGINSQL ALIAS cQuery

SELECT SQ3.Q3_FILIAL, SQ3.Q3_CARGO, SQ3.Q3_DESCSUM 
	FROM %table:SQ3% SQ3
WHERE SQ3.Q3_FILIAL = %exp:xFilial("SQ3", cCodFil)%
	AND SQ3.%NotDel% 
	%exp:cWhere%
	ORDER BY 1,2
ENDSQL
(cQuery)->(DbGoTop())

//Controle de Paginação
If nPage == 1
	nRegIni := 1
	nRegFim := nPageSize
Else
	nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
	nRegFim := ( nRegIni + nPageSize ) - 1
EndIf

While (cQuery)->(!Eof())
	nCount ++
	If ( nCount >= nRegIni .And. nCount <= nRegFim )
		oRoleFunc	:= JsonObject():New()
		oRoleFunc["id"] 		:= Alltrim( (cQuery)->Q3_CARGO )
		oRoleFunc["name"]		:= Alltrim( EncodeUTF8( (cQuery)->Q3_DESCSUM ) )
		oRoleFunc["idCompany"] 	:= Iif( !Empty( (cQuery)->Q3_FILIAL ), (cQuery)->Q3_FILIAL, NIL )
		aAdd( aRoleFunc, oRoleFunc )
	Else
		If nCount >= nRegFim
			lMorePage := .T.
			Exit
		EndIf
	EndIf
	(cQuery)->( DbSkip() )
EndDo

(cQuery)->(dbCloseArea())

oRet["items"] 	:= aRoleFunc
oRet["hasNext"] := lMorePage

If lJob
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

FreeObj( oRoleFunc )

Return oRet

/*/{Protheus.doc} fSalaryTypes
Retorna um array com os cargos que serão utilizadas na solicitação de ação salarial
@author:	Henrique Ferreira
@since:		18/04/2022
@param:		aQryParam - Array com os querysParams (Page, PageSize, Filter)
@return:	Lista com os cargos.
/*/
Function fSalaryTypes(cBranchVld, cCodEmp, nPage, nPageSize, cFilter, lJob, cUID)

	Local oItem			:= JsonObject():New()
	Local oTipos		:= JsonObject():New()
	Local lMorePage		:= .F.
	Local cTabela		:= "41"
	Local nX			:= 0
	Local nRegIni		:= 0
	Local nRegFim	 	:= 0
	Local nCount		:= 0
	Local aGetTipos		:= {}
	Local aTipos		:= {}

	Default nPage		:= 1
	Default nPageSize	:= 10
	Default lJob		:= .F.
	default cFilter		:= ""
	Default cUID		:= ""

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType( 3 )
		RPCSetEnv( cCodEmp, cBranchVld )
	EndIf

	aGetTipos := FWGetSX5( cTabela )

	//Controle de Paginação
	If nPage == 1
		nRegIni := 1
		nRegFim := nPageSize
	Else
		nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
		nRegFim := ( nRegIni + nPageSize ) - 1
	EndIf 

	If Len(aGetTipos) > 0
		For nX := 1 To Len(aGetTipos)
			If ( Empty(cFilter) .Or. cFilter $ AllTrim( aGetTipos[nX,4] ) )
				nCount ++
				If ( nCount >= nRegIni .And. nCount <= nRegFim )
					oTipos 				:= JsonObject():New()
					oTipos["id"]		:= AllTrim(aGetTipos[nX,3])
					oTipos["idCompany"] := NIL
					oTipos["name"]		:= EncodeUTF8( AllTrim( aGetTipos[nX,4] ) )
					aAdd(aTipos, oTipos)
				Else
					If nCount >= nRegFim
						lMorePage := .T.
						Exit
					EndIf
				EndIf
			EndIf		
		Next nX
	EndIf

	oItem["items"] 	  := aTipos
	oItem["hasNext"]  := lMorePage

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

	FreeObj(oTipos)

Return oItem


/*/{Protheus.doc} fCategoryTypes
Retorna um array com as categorias de trabalhadores da empresa para uso na solicitação de ação salarial
@author:	Marcelo Silveira
@since:		09/06/2022
@param:		aQryParam - Array com os querysParams (Page, PageSize, Filter)
@return:	Lista com as categorias.
/*/
Function fCategoryTypes(cBranchVld, cCodEmp, nPage, nPageSize, cFilter, lJob, cUID)

	Local oItem			:= JsonObject():New()
	Local oCateg		:= JsonObject():New()
	Local lMorePage		:= .F.
	Local cTabela		:= "28"
	Local nX			:= 0
	Local nRegIni		:= 0
	Local nRegFim	 	:= 0
	Local nCount		:= 0
	Local aCateg		:= {}
	Local aDataRet		:= {}

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType( 3 )
		RPCSetEnv( cCodEmp, cBranchVld )
	EndIf

	aCateg := FWGetSX5( cTabela )

	//Controle de Paginação
	If nPage == 1
		nRegIni := 1
		nRegFim := nPageSize
	Else
		nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
		nRegFim := ( nRegIni + nPageSize ) - 1
	EndIf 

	If Len(aCateg) > 0
		For nX := 1 To Len(aCateg)
			If ( Empty(cFilter) .Or. cFilter $ UPPER( AllTrim(aCateg[nX,4]) ) )
				nCount ++
				If ( nCount >= nRegIni .And. nCount <= nRegFim )
					oCateg 				:= JsonObject():New()
					oCateg["id"]		:= AllTrim(aCateg[nX,3])
					oCateg["name"]		:= EncodeUTF8( AllTrim( aCateg[nX,4] ) )
					oCateg["companyId"]	:= Nil
					aAdd(aDataRet, oCateg)
				Else
					If nCount >= nRegFim
						lMorePage := .T.
						Exit
					EndIf
				EndIf
			EndIf		
		Next nX
	EndIf

	oItem["items"] 	  := aDataRet
	oItem["hasNext"]  := lMorePage

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

	FreeObj(oCateg)

Return oItem

/*/{Protheus.doc} fGetStaffInc
Retorna um array com as requisições realizadas
@author:	Henrique Ferreira
@since:		18/04/2022
@param:		cBranchVld - Filial do Funcionário Logado
            cMatSRA - Matrícula do Funcionário Logado
			aIdReq - Dados da requisição que está sendo consultada.
@return:	Dados dos funcionários no formato - "employeesRequisitionsResponse"
/*/
Function fGetStaffInc(cBranchVld, cMatSRA, aIdReq)

Local oItens		:= NIL
Local oCostCenter	:= NIL
Local oCompany		:= NIL
Local oFunction		:= NIL
Local oBranch		:= NIL
Local oContract		:= NIL
Local oDepart		:= NIL
Local oPostType		:= NIL
local oRole			:= NIL

Local cFilReq		:= ""
Local cMatReq		:= ""
Local cEmpReq		:= ""
Local cCodReq		:= ""

Local cCodFil		:= ""
Local cCodDepto 	:= ""
Local cDescDpto		:= EncodeUTF8( STR0028 ) // Não Informado
Local cCodCC		:= ""
Local cDescCC		:= EncodeUTF8( STR0028 ) // Não Informado
Local cCodFunc		:= ""
Local cDescFunc		:= EncodeUTF8( STR0028 ) // Não Informado
Local cCodCargo 	:= ""
Local cDescCargo    := EncodeUTF8( STR0028 ) // Não Informado
Local cTpPosto   	:= ""
Local cTpContr		:= ""
Local cNewHire		:= ""

Local nVacancies	:= 0
Local nCpos			:= 0
Local nNewSal		:= 0

Local aAreaSRA      := SRA->(GetArea())
Local aCposRH4		:= {}
Local aSM0Cpos		:= {"M0_NOME","M0_NOMECOM","M0_CGC" }
Local aSM0Data		:= {}

Local lLenSM0      := .F.

DEFAULT cBranchVld := ""
DEFAULT cMatSRA    := ""
DEFAULT aIdReq     := {}

//Dados da matricula que será consultada pelo gestor.
cFilReq		:= aIdReq[1]
cMatReq		:= aIdReq[2]
cEmpReq		:= aIdReq[3]
cCodReq		:= aIdReq[4]

If SRA->(dbSeek(cFilReq+cMatReq))
	
	aCposRH4 := fGetRH4Cpos(cFilReq, cCodReq)
	//Dados da Requisição.
	If Len(aCposRH4) > 0
		For nCpos := 1 To Len(aCposRH4)
			If aCposRH4[nCpos,1] == "RBT_FILIAL"
				cCodFil := aCposRH4[nCpos,2]
			ElseIf aCposRH4[nCpos,1] == "RBT_DEPTO"
				cCodDepto := AllTrim( aCposRH4[nCpos,2] )
			ElseIf aCposRH4[nCpos,1] == "TMP_DDEPTO"
				cDescDpto := AllTrim( aCposRH4[nCpos,2] )
			ElseIf aCposRH4[nCpos,1] == "RBT_CC"
				cCodCC := AllTrim( aCposRH4[nCpos,2] )
			ElseIf aCposRH4[nCpos,1] == "TMP_DCC"
				cDescCC := AllTrim( aCposRH4[nCpos,2] )
			Elseif aCposRH4[nCpos,1] == "RBT_FUNCAO"
				cCodFunc := AllTrim( aCposRH4[nCpos,2] )
			Elseif aCposRH4[nCpos,1] == "TMP_DFUNCA"
				cDescFunc := AllTrim( aCposRH4[nCpos,2] )
			Elseif aCposRH4[nCpos,1] == "RBT_CARGO"
				cCodCargo := AllTrim( aCposRH4[nCpos,2] )
			Elseif aCposRH4[nCpos,1] == "TMP_DCARGO"
				cDescCargo := AllTrim( aCposRH4[nCpos,2] )
			Elseif aCposRH4[nCpos,1] == "RBT_REMUNE"
				nNewSal := Val(aCposRH4[nCpos,2])
			Elseif aCposRH4[nCpos,1] == "RBT_TPOSTO"
				cTpPosto := AllTrim( aCposRH4[nCpos,2] )
			Elseif aCposRH4[nCpos,1] == "RBT_TPCONT"
				cTpContr := AllTrim( aCposRH4[nCpos,2] )
			Elseif aCposRH4[nCpos,1] == "RBT_QTDMOV"
				nVacancies := Val(aCposRH4[nCpos,2])
			Elseif aCposRH4[nCpos,1] == "TMP_NOVACO"
				cNewHire := AllTrim(aCposRH4[nCpos,2])
			EndIf     
		Next nCpos
	EndIf

	//Istanciando objetos Json
	oItens := JsonObject():New()

	aSM0Data := FWSM0Util():GetSM0Data( cEmpReq, cCodFil, aSM0Cpos ) // Dados do cadastro de empresas.
	lLenSM0  := Len( aSM0Data ) > 0
	
	// Dados da Empresa
	oCompany := JsonObject():New()
	oCompany["id"] 		   := cEmpReq
	oCompany["identifier"] := NIL
	oCompany["name"]	   := IIf( lLenSM0 , AllTrim( aSM0Data[1,2] ) , EncodeUTF8( STR0046 ) ) // Não cadastrado
	oItens["newHire"]      := If( cNewHire == "1", .T., .F. ) //Gera nova contratacao 1= Sim, 2=Não
	oItens["company"]  	   := oCompany

	// Dados da Filial
	oBranch := JsonObject():New()
	oBranch["id"] 		   := cCodFil
	oBranch["name"] 	   := IIf( lLenSM0 , AllTrim( aSM0Data[2,2] ) , EncodeUTF8( STR0046 ) ) // Não cadastrado
	oBranch["cnpj"]	   	   := IIf( lLenSM0 , AllTrim( aSM0Data[3,2] ), EncodeUTF8( STR0046 ) ) // Não cadastrado
	oItens["branch"]       := oBranch
	
	// Departamento
	oDepart := JsonObject():New()
	oDepart["id"] 		  := cCodDepto
	oDepart["name"] 	  := cDescDpto
	oItens["department"]  := oDepart

	// Centro de Custo
	oCostCenter := JsonObject():New()
	oCostCenter["id"] 	  := cCodCC
	oCostCenter["name"]   := cDescCC
	oItens["costCenter"]  := oCostCenter

	// Função
	oFunction := JsonObject():New()
	oFunction["id"]		  := cCodFunc
	oFunction["name"]	  := cDescFunc
	oItens["function"]    := oFunction

	// Cargo
	oRole := JsonObject():New()
	oRole["id"]		  	:= cCodCargo
	oRole["name"]	  	:= cDescCargo
	oItens["role"]  	:= oRole

	// Tipo de Posto
	oPostType := JsonObject():New()
	oPostType["id"]		  	:= cTpPosto
	oPostType["name"]	  	:= IIf( cTpPosto == "1", EncodeUTF8( STR0041 ), EncodeUTF8( STR0042 ) ) // individual, Genérico.
	oItens["postType"]  	:= oPostType

	// Tipo de Contrato
	oContract := JsonObject():New()
	oContract["id"]		  	:= cTpContr
	oContract["name"]	  	:= IIf( cTpContr == "1", EncodeUTF8( STR0043 ), EncodeUTF8( STR0044 ) ) // Indeterminado / Determinado
	oItens["contractType"]  := oContract

	oItens["salary"]    	  := nNewSal
	oItens["vacanciesNumber"] := nVacancies


	cJustify 				:= AllTrim(GetRGKJustify(xFilial("RGK", cFilReq), cCodReq, ,.T.))
	oItens["justify"]		:= cJustify
	oItens["idRequisition"]	:= cCodReq
	oItens["requisitionType"] := EncodeUTF8( STR0045 ) // Aumento de Quadro

	//Dados do arquivo de imagem.
	oItens["file"] 			:= NIL
	oItens["hasAttachment"] := .F.

	//Dados não utilizados no Protheus
	oItens["destinationHierarchicalStructure"]	:= NIL
	oItens["level"]		:= NIL
	oItens["prevision"] := NIL
	oItens["range"]  	:= NIL
	oItens["complementaryField"] := NIL
EndIf

RestArea(aAreaSRA)

Return oItens


/*/{Protheus.doc} fRH4Func
Retorna um array com as categorias de trabalhadores da empresa para uso na solicitação de ação salarial
@author:	Alberto Ortiz
@since:		22/06/2022
@param:		cFil - Filial, cCodigo - Código da requisição
@return:	Descrição da função da requisicão de aumento de quadro.
/*/
Function fRH4Func(cFil, cCod)
	Local cDescFunc  := EncodeUTF8( STR0028 )// Não informado.
	Local cCdg       := ""
	Local cRH4Campo  := "RBT_FUNCAO"
	Local aData      := {}
	Local nPos       := 0	

	DEFAULT cFil := ""
	DEFAULT cCod := ""

	//Busca código na RH4 depois busca descrição da função na SRJ.
	aData := fGetRH4Cpos(cFil, cCod)
	nPos  := aScan(aData, {|x| x[1] == cRH4Campo})
	If nPos > 0
		cCdg := aData[nPos][2]
		cDescFunc := fDesc("SRJ" , cCdg, "SRJ->RJ_DESC" , , xFilial("SRJ", cFil) , , )
	EndIf

Return cDescFunc

/*/{Protheus.doc} fRH4Vagas
Retorna um array com as categorias de trabalhadores da empresa para uso na solicitação de ação salarial
@author:	Alberto Ortiz
@since:		22/06/2022
@param:		cFil - Filial, cCodigo - Código da requisição
@return:	Número de vagas da requisicão de aumento de quadro.
/*/
Function fRH4Vagas(cFil, cCod)
	Local cNumVag    := ""
	Local cRH4Campo  := "RBT_QTDMOV"
	Local aData      := {}
	Local nPos       := 0	

	DEFAULT cFil := ""
	DEFAULT cCod := ""

	aData := fGetRH4Cpos(cFil, cCod)
	nPos  := aScan(aData, {|x| x[1] == cRH4Campo})
	
	//Busca número de vagas na RH4
	If nPos > 0
		cNumVag := aData[nPos][2]
	EndIf

Return cNumVag

/*/{Protheus.doc} fDepartment
Retorna os departamentos que o gestor é responsável (ou não), conforme QP
@author:	Henrique Ferreira
@since:		15/07/2022
@param:		aQryParam - Array com os querysParams (Page, PageSize, Filter)
@return:	Lista com os departamentos.
/*/
Function fDepartment(cCodEmp, cCodFil, cCodMat, cRoutine, aQryParam)

Local oDepart	:= JsonObject():New()
Local oRet		:= JsonObject():New()

Local lMorePage		:= .F.
Local lBoss			:= .F.
Local lBloq			:= SQB->(ColumnPos("QB_MSBLQL")) > 0
Local cTypeOrg		:= SuperGetMv("MV_ORGCFG", NIL ,"0")
Local cVision		:= ""
Local cItem			:= ""
Local cChave		:= ""
Local cLike			:= ""
Local cWhere		:= ""
Local cCompanyId	:= cEmpAnt
Local cBranchId		:= cFilAnt
Local cFilSQB		:= xFilial("SQB", cCodFil)
Local cFilRD4		:= xFilial("RD4", cCodFil)

Local aUser			:= {}
Local aDepart		:= {}

Local nPage			:= 1
Local nPageSize 	:= 10
Local nX			:= 0
Local nLenQp		:= 0
Local nRegIni		:= 0
Local nRegFim	 	:= 0
Local nCount		:= 0

Local cFilter  		:= ""
Local cQuery   		:= GetNextAlias()

DEFAULT aQryParam   := {}
DEFAULT cCodEmp		:= ""
DEFAULT cCodFil  	:= ""
DEFAULT cCodMat     := ""

nLenQp := Len(aQryParam)

If nLenQp > 0 .And. !Empty(cCodFil)
	For nX := 1 to nLenQp
		DO Case
			CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
				nPageSize := Val(aQryParam[nX,2])
			CASE UPPER(aQryParam[nX,1]) == "PAGE"
				nPage := Val(aQryParam[nX,2])
			CASE UPPER(aQryParam[nX,1]) == "ONLYISBOSS"
				lBoss := Iif( aQryParam[nX,2] == "true", .T., .F.  )
			CASE UPPER(aQryParam[nX,1]) == "FILTER"
				cFilter := Upper( AllTrim(aQryParam[nX,2]) )
			CASE UPPER(aQryParam[nX,1]) == "COMPANYID"
				cCompanyId := Upper( AllTrim(aQryParam[nX,2]) )
			CASE UPPER(aQryParam[nX,1]) == "BRANCHID"
				cBranchId := Upper( AllTrim(aQryParam[nX,2]) )
		ENDCASE
	Next nX

	//Busca somente os departamentos que o gestor é responsável. Usado no aumento de quadro.
	If cTypeOrg == "1" .And. lBoss

		//Cria array copia da da função Participant, apenas com filial e matrícula

		aAdd(aUser, cCodMat) 		//1 - MATRICULA DO FUNCIONARIO	
		aadd(aUser, "") 			//2 - NOME COMPLETO
		aAdd(aUser, cCodFil) 		//3 - FILIAL
		aAdd(aUser, "") 			//4 - RG
		aAdd(aUser, "") 			//5 - DATA DE ADMISSAO
		aAdd(aUser, "") 			//6 - CODIGO DO FUNCIONARIO PELO CAMPO ANTIGO
		aAdd(aUser, "")				//7 - CODIGO DO FUNCIONARIO PELO CAMPO NOVO
		aAdd(aUser, "")				//8 - DEPARTAMENTO
        aAdd(aUser, "") 	 		//9 - SITUACAO DO FUNCIONARIO
        aAdd(aUser, "")  			//10 - MOTIVO DA RESCISAO
        aAdd(aUser, "")  			//11 - Regime
        aAdd(aUser, "")  			//12 - DATA DE DEMISSAO


		aVision 	:= GetVisionAI8(cRoutine, cCodFil, cCodEmp)
		cVision 	:= aVision[1][1]

		If ChaveRD4(cTypeOrg, aUser, cVision, @cItem, @cChave, @cLike)

			cWhere := "%"
			cWhere += IIf( lBloq," AND SQB.QB_MSBLQL <> '1' ", "" )
			If !Empty(cFilter)
				cWhere += " AND ((SQB.QB_DEPTO   LIKE '%" + cFilter + "%')" 
				cWhere += " OR (SQB.QB_DESCRIC LIKE '%" + cFilter + "%'))"
			EndIf
			cWhere += "%"

			BeginSql alias cQuery
				SELECT RD4.RD4_EMPIDE,RD4.RD4_FILIDE,RCL.RCL_DEPTO,SQB.QB_DESCRIC
				FROM %table:RD4% RD4
					INNER JOIN  %table:RCL% RCL 
						ON RD4.RD4_FILIDE = RCL.RCL_FILIAL 
						AND RD4.RD4_CODIDE = RCL.RCL_POSTO 
						AND RCL.%notDel%

					INNER JOIN  %table:SQB% SQB 
						ON SQB.QB_DEPTO = RCL.RCL_DEPTO 
						AND SQB.%notDel%
				WHERE 
					RD4.RD4_CHAVE LIKE %exp:cLike%     AND
					RD4.RD4_CODIGO = %exp:cVision%     AND
					RD4.RD4_FILIAL = %exp:cFilRD4%     AND
					SQB.QB_FILIAL  = %exp:cFilSQB%     AND
					RD4.%notDel%                       
					%exp:cWhere%
				GROUP BY RD4.RD4_EMPIDE,RD4.RD4_FILIDE,RCL.RCL_DEPTO,SQB.QB_DESCRIC
				ORDER BY RD4.RD4_EMPIDE,RD4.RD4_FILIDE,RCL.RCL_DEPTO,SQB.QB_DESCRIC
			EndSql

			(cQuery)->(DbGoTop())

			//Controle de Paginação
			If nPage == 1
				nRegIni := 1
				nRegFim := nPageSize
			Else
				nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
				nRegFim := ( nRegIni + nPageSize ) - 1
			EndIf

			While (cQuery)->(!Eof())
				nCount ++
				If ( nCount >= nRegIni .And. nCount <= nRegFim )
					oDepart	:= JsonObject():New()
					oDepart["idDepartment"] := 	cCodEmp + "|" + ;
												cCodFil + "|" + ;
												Alltrim( (cQuery)->RCL_DEPTO )
					oDepart["id"]		 	:= Alltrim( (cQuery)->RCL_DEPTO )
					oDepart["name"]		 	:= Alltrim( EncodeUTF8( (cQuery)->QB_DESCRIC ) )
					oDepart["companyId"] 	:= NIL
					aAdd( aDepart, oDepart )
				Else
					If nCount >= nRegFim
						lMorePage := .T.
						Exit
					EndIf
				EndIf
				(cQuery)->( DbSkip() )
			EndDo
			(cQuery)->(dbCloseArea())
			oRet["items"] 	:= aDepart
			oRet["hasNext"] := lMorePage
		EndIf
	
	//Tratativa para a parte de transferência.
	else
		if !( cCompanyId == cEmpAnt )
			oRet := GetDataForJob( "12", { cCompanyId, cBranchId, nPage, nPageSize, cFilter }, cCompanyId  )
		Else
			oRet := fGetDepto( cCompanyId, cBranchId, nPage, nPageSize, cFilter, NIL, NIL )	
		EndIf
	EndIf
EndIf

Return oRet

/*/{Protheus.doc} fCostCenter
Retorna os departamentos que o gestor é responsável (ou não), conforme QP
@author:	Henrique Ferreira
@since:		15/07/2022
@param:		aQryParam - Array com os querysParams (Page, PageSize, Filter)
			cRoutine  - Código da rotina para filtro das visões.
@return:	Lista com os departamentos.
/*/
Function fCostCenter(aQryParam, lJob, cUID)

Local oCost			:= JsonObject():New()
Local oRet			:= JsonObject():New()

Local aArea			:= {}

Local lMorePage		:= .F.
Local lBloq			:= .F.
Local cWhere		:= ""
Local cCodEmp		:= ""
Local cCodFil		:= ""

Local aCost			:= {}
Local aId			:= {}

Local nPage			:= 1
Local nPageSize 	:= 10
Local nX			:= 0
Local nLenQp		:= 0
Local nRegIni		:= 0
Local nRegFim	 	:= 0
Local nCount		:= 0

Local cFilter  		:= ""
Local cQuery   		:= ""

DEFAULT aQryParam   := {}
DEFAULT lJob		:= .F.
DEFAULT cUID		:= ""

nLenQp := Len(aQryParam)

If nLenQp > 0
	For nX := 1 to nLenQp
		DO Case
			CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
				nPageSize := Val(aQryParam[nX,2])
			CASE UPPER(aQryParam[nX,1]) == "PAGE"
				nPage := Val(aQryParam[nX,2])
			CASE UPPER(aQryParam[nX,1]) == "IDDEPARTMENT"
				aId := StrTokArr(aQryParam[nX,2], "|" )
			CASE UPPER(aQryParam[nX,1]) == "FILTER"
				cFilter := Upper( AllTrim(aQryParam[nX,2]) )
		ENDCASE
	Next nX

	If !lJob
		cCodEmp := cEmpAnt
		cCodFil := cFilAnt
	EndIf

	/* A rotina de aumento de quadro envia 3 elementos no array
	   Enquanto que a rotina de transferência, apenas 2.
	   Contudo, somente os 2 primeiros elementos importam, que são Empresa e Filial
	*/
	If Len(aId) >= 2
		cCodEmp := aId[1]
		cCodFil := aId[2]
	EndIf
	
	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType( 3 )
		RPCSetEnv( cCodEmp, cCodFil )
	EndIf

	lBloq := CTT->( ColumnPos( "CTT_MSBLQL" ) ) > 0
	aArea := GetArea()
	cQuery := GetNextAlias()

	cWhere := "%"
	cWhere += IIf( lBloq, " AND CTT.CTT_MSBLQL <> '1' ", "" )
	If !Empty(cFilter)
		cWhere += " AND (( CTT.CTT_CUSTO LIKE '%" + cFilter + "%')"
		cWhere += " OR (CTT.CTT_DESC01 LIKE '%" + cFilter + "%'))"
	EndIf
	cWhere += "%"

	BeginSql alias cQuery
		SELECT CTT.CTT_FILIAL,CTT.CTT_CUSTO,CTT.CTT_DESC01
		FROM %table:CTT% CTT
		WHERE 
			CTT.CTT_FILIAL = %exp:xFilial("CTT", cCodFil)%     AND
			CTT.CTT_CLASSE = '2' AND
			CTT.CTT_BLOQ <> '1' AND
			CTT.%notDel%                       
			%exp:cWhere%
	EndSql
	(cQuery)->(DbGoTop())

	//Controle de Paginação
	If nPage == 1
		nRegIni := 1
		nRegFim := nPageSize
	Else
		nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
		nRegFim := ( nRegIni + nPageSize ) - 1
	EndIf

	While (cQuery)->(!Eof())
		nCount ++
		If ( nCount >= nRegIni .And. nCount <= nRegFim )
			oCost	:= JsonObject():New()
			oCost["id"] 		 := Alltrim( (cQuery)->CTT_CUSTO )
			oCost["name"]		 := Alltrim( EncodeUTF8( (cQuery)->CTT_DESC01 ) )
			oCost["codCusto"]	 := NIL
			aAdd( aCost, oCost )
		Else
			If nCount >= nRegFim
				lMorePage := .T.
				Exit
			EndIf
		EndIf
		(cQuery)->( DbSkip() )
	EndDo
	(cQuery)->(dbCloseArea())
	oRet["items"] 	:= aCost
	oRet["hasNext"] := lMorePage

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf
EndIf

RestArea( aArea )
FreeObj( oCost )

Return oRet

Static Function fGetCarg( cBranch, cCargo, oRole )

Local cQuery  := GetNextAlias()

BEGINSQL ALIAS cQuery

SELECT SQ3.Q3_FILIAL, SQ3.Q3_CARGO, SQ3.Q3_DESCSUM 
		FROM %table:SQ3% SQ3
WHERE SQ3.Q3_FILIAL = %exp:xFilial("SQ3", cBranch)%
		AND SQ3.Q3_CARGO = %Exp:cCargo%
		AND SQ3.%NotDel%
ENDSQL
(cQuery)->(DbGoTop())

If (cQuery)->(!Eof())
	oRole := JsonObject():New()
	oRole["id"]   		  := (cQuery)->Q3_CARGO
	oRole["idCompany"]   := IIf( !Empty( (cQuery)->Q3_FILIAL ), (cQuery)->Q3_FILIAL, NIL )
	oRole["name"] 		  := AllTrim( (cQuery)->Q3_DESCSUM )
EndIf
(cQuery)->(dbCloseArea())

Return .T.


/*/{Protheus.doc} fVerPendRH3
Verifica se existe na RH3 alguma requisição com algum dos status solicitados.
@author:	Alberto Ortiz
@since:		28/07/2022
@param:		cEmp    - Empresa.
			cFil    - Filial.
			cMat    - Matrícula.
			cTipo   - Tipo da requisição.
			aStatus - Array de Status da requisição
@return:	.T. se existe requisição com algum dos status solicitado
/*/
Function fVerPendRH3(cEmp, cFil, cMat, cTipo, aStatus)

	Local lExistPend := .F.
	Local cQuery     := GetNextAlias()
	Local cStatus    := ""
	Local nX         := 1
	
	DEFAULT cEmp    := ""
	DEFAULT cFil    := ""
	DEFAULT cMat    := ""
	DEFAULT cTipo   := ""
	DEFAULT aStatus := {}

	For nX := 1 To Len(aStatus)
		cStatus += "'" + aStatus[nX] + "'"
		If(nX < Len(aStatus))
			cStatus += ','
		EndIf
	Next nX
	cStatus := "%" + cStatus + "%"

	BeginSql alias cQuery
		SELECT COUNT(*) as QTD
		FROM %table:RH3% RH3
		WHERE
			RH3.RH3_EMP = %Exp:cEmp% AND
			RH3.RH3_FILIAL = %Exp:cFil% AND
			RH3.RH3_MAT = %Exp:cMat% AND
			RH3.RH3_TIPO = %Exp:cTipo% AND
			RH3.%NotDel% AND
			RH3.RH3_STATUS IN (%exp:cStatus%)
	EndSql

	lExistPend := ((cQuery)->QTD > 0)

	(cQuery)->(DBCloseArea())

Return lExistPend

/*/{Protheus.doc} fGetDepto
Busca os departamentos executados via JOB para outros grupos de empresa.
@author:	Alberto Ortiz
@since:		28/07/2022
@param:		cCodEmp    - Empresa.
			cBranch    - Filial.
			nPage    - Numero da pagina.
			nPageSize   - Tamanho da página
			cFilter - Filtro para a query
@return:	.T. se existe requisição com algum dos status solicitado
/*/

Function fGetDepto( cCodEmp, cBranch, nPage, nPageSize, cFilter, lJob, cUID )

Local oRet	  := NIL
Local oDepart := NIL
Local aDepart := {}
Local aArea   := {}

Local cQuery  := ""
Local cWhere  := ""

Local lMorePage	:= .F.
Local lBloq		:= .F.

Local nRegIni := 0
Local nRegFim := 0
Local nCount  := 0

Default lJob := .F.
Default cUID := ""

If lJob
	//Instancia o ambiente para a empresa onde a funcao sera executada
	RPCSetType( 3 )
	RPCSetEnv( cCodEmp, cBranch )
EndIf

lBloq := SQB->(ColumnPos("QB_MSBLQL")) > 0
aArea := GetArea()
cQuery := GetNextAlias()

cWhere := "%"
cWhere += IIf( lBloq," AND SQB.QB_MSBLQL <> '1' ", "" )
If !Empty(cFilter)
	cWhere += " AND ((SQB.QB_DEPTO   LIKE '%" + cFilter + "%' )"
	cWhere += " OR  (SQB.QB_DESCRIC LIKE '%" + cFilter + "%'))"
EndIf
cWhere += "%"

BEGINSQL ALIAS cQuery
	SELECT SQB.QB_FILIAL, SQB.QB_DEPTO, SQB.QB_DESCRIC 
		FROM %table:SQB% SQB
	WHERE SQB.QB_FILIAL = %exp:xFilial("SQB", cBranch)%
		AND SQB.%notDel%
		%exp:cWhere%
		ORDER BY 1,2
ENDSQL
(cQuery)->(DbGoTop())

//Controle de Paginação
If nPage == 1
	nRegIni := 1
	nRegFim := nPageSize
Else
	nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
	nRegFim := ( nRegIni + nPageSize ) - 1
EndIf

While (cQuery)->(!Eof())
	nCount ++
	If ( nCount >= nRegIni .And. nCount <= nRegFim )
		oDepart	:= JsonObject():New()
		oDepart["idDepartment"] := 	cCodEmp	+ "|" + ;
									cBranch   + "|" + ;
									Alltrim( (cQuery)->QB_DEPTO )
		oDepart["id"]		 	:= Alltrim( (cQuery)->QB_DEPTO )
		oDepart["name"]		 	:= Alltrim( EncodeUTF8( (cQuery)->QB_DESCRIC ) )
		oDepart["companyId"] 	:= NIL
		aAdd( aDepart, oDepart )
	Else
		If nCount >= nRegFim
			lMorePage := .T.
			Exit
		EndIf
	EndIf
	(cQuery)->( DbSkip() )
EndDo
(cQuery)->(dbCloseArea())

RestArea( aArea )
FreeObj( oDepart )

oRet := JsonObject():New()
oRet["items"] 	:= aDepart
oRet["hasNext"] := lMorePage

If lJob
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

Return oRet

/*/{Protheus.doc} fRS3UpdStatus
Atualiza o status de uma solicitação de ponto que foi reprovada 
@author:	Marcelo Silveira
@since:		02/09/2022
@param:		cRH3Fil - Filial da solicitacao
			cRH3Cod - Código da solicitacao
@return:	Nil
/*/
Static Function fRS3UpdStatus(cRH3Fil, cRH3Cod)

	Local aArea 	:= {}
	
	DEFAULT cRH3Fil := ""
	DEFAULT cRH3Cod := ""

	If !Empty(cRH3Fil+cRH3Cod)
		aArea := GetArea()

		DbSelectArea("RS3")
		DbSetOrder(1)
		If RS3->( DbSeek(cRH3Fil + cRH3Cod) )
			RecLock("RS3",.F.)
			RS3->RS3_STATUS := "2" //Reprovado
			MsUnLock()
		EndIf
		
		RestArea(aArea)
	EndIf

Return()

/*/{Protheus.doc} getPendReqCount
Retorna o número de requisiições pendentes de autorização
separadas por tipo de requisição.
@author:	Alberto Ortiz
@since:		31/10/2022
@param:		cBranch     - Filial do funcionário
			cMat        - Matrícula do funcionário
			lTransfer   - Inclui requisições de transferência.
			lDataChange - Inclui requisições de alteração salarial.
			lStffInc    - Inclui requisições de aumento de quadro.
			lDemission  - Inclui requisições de demissão.
@return:	aReturn     - Array de objetos no padrão "requisitionsPendingCount"
/*/

Function getPendReqCount(cBranch, cMat, lTransfer, lDataChange, lStffInc, lDemission)

	Local aReturn  := {}

	Local cQryRH3  := GetNextAlias()
	Local cTabRH3  := ""
	Local cTipos   := ""

	DEFAULT cEmp        := cEmpAnt
	DEFAULT cBranch     := ""
	DEFAULT cMat        := ""
	DEFAULT lTransfer   := .F.
	DEFAULT lDataChange := .F.
	DEFAULT lStffInc    := .F.
	DEFAULT lDemission  := .F.

	//Verifica quais tipos de requisições serão inseridas na query.
	cTipos += If(lTransfer, "'4'," ,"")
	cTipos += If(lDataChange, "'7'," ,"")
	cTipos += If(lStffInc, "'3'," ,"")
	cTipos += If(lDemission, "'6'," ,"")
	cTipos := LEFT(cTipos, LEN(cTipos) - 1)

	//Construção da query.
	cWhere := "%"
	cWhere += " RH3.RH3_EMPAPR = '" + cEmpAnt + "' AND "
	cWhere += " RH3.RH3_FILAPR = '" + cBranch + "' AND "
	cWhere += " RH3.RH3_MATAPR = '" + cMat    + "' AND "
	cWhere += " RH3.RH3_TIPO  IN (" + cTipos  + ") "
	cWhere += "%"	

	cTabRH3  := "%" + RetFullName("RH3", cEmpAnt) + "%"

	BEGINSQL ALIAS cQryRH3

		SELECT RH3.RH3_TIPO, COUNT(*) QTD
		FROM %exp:cTabRH3% RH3
		WHERE  RH3.RH3_STATUS IN ('1') AND
				%Exp:cWhere% 		   AND
				RH3.%NotDel%
		GROUP  BY RH3.RH3_TIPO

	ENDSQL

	//Construção do array de itens de 'requisitionsPendingCount'
	While (cQryRH3)->(!Eof())
		oRequisition          := JsonObject():New()
		oRequisition["type"]  := GetENUMDecode( (cQryRH3)->RH3_TIPO )
		oRequisition["total"] := (cQryRH3)->QTD
		Aadd(aReturn, oRequisition)
		(cQryRH3)->(DbSkip())
	EndDo

	(cQryRH3)->( DBCloseArea())

Return(aReturn)

/*/{Protheus.doc} fGetReqEmp
Retorna objeto com dados do funcionário no formato "employeesRequisitions".
@author:	Alberto Ortiz
@since:		31/10/2022
@param:		cEmp - Empresa do funcionário.
			cFil - Filial do funcionário.
			cMat - Matrícula do funcionário.
@return:	oReturn - Objeto no padrão "employeesRequisitions"
/*/
Function fGetReqEmp(cEmp, cFil, cMat, lJob, cUID)

	Local oReturn := JsonObject():New()

	Local cQuerySRA   := ""
	Local cRaDepto    := ""
	Local cRaCatfunc  := ""
	Local cRACodfunc  := ""
	Local cRaCC       := ""
	Local cId         := ""
	Local cNome       := ""
	Local cDatAdmi    := ""
	Local cIdDepto    := ""
	Local cDepto      := ""
	Local cCategory   := ""
	Local cFunction   := ""
	Local cCostCenter := ""
	Local cFuncDesc   := ""
	Local cSra	      := ""
	Local cRaAdmissa  := ""

	Local lNomeSoc    := .F.
	
	Local nRaSalario  := ""

	DEFAULT cEmp := ""
	DEFAULT cFil := ""
	DEFAULT cMat := ""
	DEFAULT lJob := .F.
	DEFAULT cUID := ""

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType(3)
		RPCSetEnv(cEmp, cFil)
	EndIf

	lNomeSoc  := SuperGetMv("MV_NOMESOC", NIL, .F.)
	cSra	  := "%" + RetFullName("SRA", cEmp) + "%"
	cQuerySRA := GetNextAlias()

	BEGINSQL ALIAS cQuerySRA
	SELECT SRA.RA_DEPTO,
		   SRA.RA_CATFUNC,
		   SRA.RA_CODFUNC,
		   SRA.RA_CC,
		   SRA.RA_ADMISSA,
		   SRA.RA_SALARIO,
		   SRA.RA_NSOCIAL,
		   SRA.RA_NOME
	FROM %exp:cSra% SRA
		WHERE SRA.RA_FILIAL = %exp:cFil% AND
			  SRA.RA_MAT    = %exp:cMat% AND
              SRA.%notDel%
	ENDSQL

	//Busca os dados na SRA.
	While !(cQuerySRA)->(Eof())
		cRaDepto    := AllTrim((cQuerySRA)->RA_DEPTO)
		cRaCatfunc  := AllTrim((cQuerySRA)->RA_CATFUNC)
		cRACodfunc  := AllTrim((cQuerySRA)->RA_CODFUNC)
		cRaCC       := AllTrim((cQuerySRA)->RA_CC)
		cFuncDesc   := Alltrim(EncodeUTF8(FDesc("SRJ", AllTrim((cQuerySRA)->RA_CODFUNC), "RJ_DESC", ,cFil )))
		cRaAdmissa  := (cQuerySRA)->RA_ADMISSA
		nRaSalario  := (cQuerySRA)->RA_SALARIO
		cNome       := AllTrim(If(lNomeSoc .And. !Empty((cQuerySRA)->RA_NSOCIAL), (cQuerySRA)->RA_NSOCIAL, (cQuerySRA)->RA_NOME))
		(cQuerySRA)->(DbSkip())
	End

	//Validações de valores que irão no objeto employeesRequisitions.
	cId := cFil + "|" + cMat + "|" + cEmp

	If(Len(cRaAdmissa) > 7)
	   cDatAdmi := formatGMT(SUBSTR(cRaAdmissa, 7, 2) + "/"+ SUBSTR(cRaAdmissa, 5, 2) + "/" + SUBSTR(cRaAdmissa, 1, 4))
	EndIf
	
	cIdDepto    := If(!Empty(cRaDepto),   cEmp + "|" + cFil + "|" + cRaDepto,                                                 cRaDepto)
	cDepto      := If(!Empty(cRaDepto),   Alltrim(fDesc('SQB', cRaDepto, 'SQB->QB_DESCRIC', ,xFilial("SQB", cFil), 1)),       cRaDepto)
	cCategory   := If(!Empty(cRaCatfunc), Alltrim(fDesc("SX5", "28"+cRaCatfunc, "X5DESCRI()")),                               cRaCatfunc)
	cFunction   := If(!Empty(cRACodfunc), Alltrim(Posicione('SRJ', 1, xFilial("SRJ", cFil) + cRACodfunc, 'SRJ->RJ_DESC')),    cRACodfunc)
	cCostCenter := If(!Empty(cRaCC),      Alltrim(Posicione('CTT', 1, xFilial("CTT", cFil) + cRaCC     , 'CTT->CTT_DESC01')), cRaCC)

	//Atribuindo valores para o objeto employeesRequisitions.
    oReturn["id"]            := cId
    oReturn["name"]          := cNome
    oReturn["admissionDate"] := cDatAdmi
    oReturn["salary"]        := nRaSalario
    oReturn["registry"]      := cMat
    oReturn["department"]    := cDepto
	oReturn["costCenter"]    := cCostCenter
    oReturn["category"]      := cCategory
    oReturn["function"]      := cFunction
    oReturn["idFunction"]    := cRACodfunc
    oReturn["idDepartment"]  := cIdDepto
	oReturn["raCodFuncDesc"] := cFuncDesc

	//Valores não utilizados pelo Protheus.
	oReturn["salaryLevel"]   := Nil
    oReturn["salaryRange"]   := Nil
    oReturn["role"]          := Nil

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

Return oReturn


/*/{Protheus.doc} fGetDadosRh3
	@type  Function
	@author alberto.ortiz
	@since 02/03/2023
	@version version
	@param:	 cFilRH3   - Filial da requisição.
			 cMatRH3   - Matrícula da requisição.
			 cCodRH3   - Código da requisição.
			 cTipoPerm - Nome da permissão de acordo com o tipo de requisição.
			 cMsgPerm  - Nome do serviço de acordo com o tipo de requisição.
			 lRet      - Verifica se a requisição foi encontrada ou não
/*/
Function fGetDadosRh3(cFilRH3, cMatRH3, cCodRH3, cTipoPerm, cMsgPerm, lRet)

	Local aArea		  := GetArea()
	Local cTipoReq    := ""

	DEFAULT cFilRH3   := ""
	DEFAULT cCodRH3   := ""
	DEFAULT cMatRH3   := ""
	DEFAULT cTipoPerm := ""
	DEFAULT cMsgPerm  := ""
	DEFAULT lRet      := .T.

	If(!Empty(cFilRH3) .And. !Empty(cCodRH3) .And. !Empty(cMatRH3))
		//Busca o tipo da requisição
		DbSelectArea("RH3")
		RH3->(dbSetOrder(1))

		If RH3->(DbSeek(cFilRH3+cCodRH3+cMatRH3))
			cTipoReq := AllTrim(RH3->RH3_TIPO)
		Else
			lRet := .F.
		EndIf
		RH3->(DbCloseArea())
		RestArea(aArea)

		If lRet
			//Variáveis para verificação de permissões e rotinas.
			If cTipoReq == '3' //Aumento de quadro
				cTipoPerm := "staffIncrease"
				cMsgPerm  := " Aumento de quadro." 
			ElseIf cTipoReq == '4' // Transferência.
				cTipoPerm := "transfer"
				cMsgPerm  := " Transferência."
			ElseIf cTipoReq == '6' //Desligamentos.
				cTipoPerm := "demission"
				cMsgPerm  := " Desligamento."
			ElseIf cTipoReq == '7' //Ação Salarial.
				cTipoPerm := "employeeDataChangeRequest"
				cMsgPerm  := " Ação Salarial."
			EndIf
		EndIf
	EndIf

Return .T.
