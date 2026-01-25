#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.ch"

#DEFINE IND_CAPACIDADE       1
#DEFINE IND_DISPONIBILIDADE  2
#DEFINE IND_EFETIVADAS       3
#DEFINE IND_PROGRAMADAS      4
#DEFINE IND_APONTADAS        5
#DEFINE IND_SETUP            6
#DEFINE IND_SALDO            7
#DEFINE IND_SETUP_PROG       8
#DEFINE IND_SETUP_EFET       9
#DEFINE QTD_LINHAS_TIPO      9

Static _oUtiRec   := Nil
Static _oUtiCt    := Nil
Static _oUtiRecCT := Nil
Static _oDetRec   := Nil

/*/{Protheus.doc} PCPA152UTI
API para exibição da Utilização dos recursos

@type WSCLASS
@author marcelo.neumann
@since 10/05/2023
@version P12
/*/
WSRESTFUL PCPA152UTI DESCRIPTION "PCPA152UTI" FORMAT APPLICATION_JSON
	WSDATA Page             AS INTEGER OPTIONAL
	WSDATA PageSize         AS INTEGER OPTIONAL
	WSDATA centroDeTrabalho AS STRING  OPTIONAL
	WSDATA dataInicial      AS STRING  OPTIONAL
	WSDATA dataFinal        AS STRING  OPTIONAL
	WSDATA programacao      AS STRING  OPTIONAL
	WSDATA recurso          AS STRING  OPTIONAL

	WSMETHOD GET LISTRECURS;
		DESCRIPTION STR0596; //"Retorna a lista de recursos para a utilização"
		WSSYNTAX "/api/pcp/v1/pcpa152uti/{programacao}/listaRecurso";
		PATH "/api/pcp/v1/pcpa152uti/{programacao}/listaRecurso";
		TTALK "v1"

	WSMETHOD GET DETRECURSO;
		DESCRIPTION STR0191; //"Retorna a utilização dos recursos"
		WSSYNTAX "/api/pcp/v1/pcpa152uti/{programacao}/recurso" ;
		PATH "/api/pcp/v1/pcpa152uti/{programacao}/recurso" ;
		TTALK "v1"

	WSMETHOD GET GETDETAILCT;
		DESCRIPTION STR0238; //"Retorna a utilização dos recursos por centro de trabalho"
		WSSYNTAX "/api/pcp/v1/pcpa152uti/{programacao}/{centroDeTrabalho}" ;
		PATH "/api/pcp/v1/pcpa152uti/{programacao}/{centroDeTrabalho}" ;
		TTALK "v1"

	WSMETHOD GET GETRECSCT;
		DESCRIPTION STR0340; //"Retorna a utilização dos recursos de um centro de trabalho"
		WSSYNTAX "/api/pcp/v1/pcpa152uti/{programacao}/{centroDeTrabalho}/recursos" ;
		PATH "/api/pcp/v1/pcpa152uti/{programacao}/{centroDeTrabalho}/recursos" ;
		TTALK "v1"

	WSMETHOD GET DETAILREC;
		DESCRIPTION STR0248; // "Retorna a utilização de um recurso em um centro de trabalho"
		WSSYNTAX "/api/pcp/v1/pcpa152uti/{programacao}/{centroDeTrabalho}/{recurso}" ;
		PATH "/api/pcp/v1/pcpa152uti/{programacao}/{centroDeTrabalho}/{recurso}" ;
		TTALK "v1"

	WSMETHOD GET CTS;
		DESCRIPTION STR0341; // "Retornar os centro de trabalho de uma programação"
		WSSYNTAX "/api/pcp/v1/pcpa152uti/{programacao}/centrosDeTrabalho";
		PATH "/api/pcp/v1/pcpa152uti/{programacao}/centrosDeTrabalho";
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET LISTRECURS /api/pcp/v1/pcpa152uti/{programacao}/listaRecurso
Retorna a lista de recursos para a utilização

@type WSMETHOD
@author lucas.franca
@since 29/10/2024
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD GET LISTRECURS PATHPARAM programacao QUERYPARAM Page, PageSize, recurso WSSERVICE PCPA152UTI
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152UTI"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getRecurso(Self:programacao, Self:Page, Self:PageSize, Self:recurso)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getRecurso
Faz a busca dos recursos para a utilização

@type  Static Function
@author lucas.franca
@since 29/10/2024
@version P12
@param 01 cProg     , Caracter, Código da programação
@param 02 nPage     , Numeric , Página para consulta
@param 03 nPageSize , Numeric , Tamanho da página
@param 04 cInRecurso, Caracter, Recursos para filtro dos dados
@return aReturn   , Array   , Array com os dados de retorno da API
/*/
Static Function getRecurso(cProg, nPage, nPageSize, cInRecurso)
	Local aReturn    := {.T., 206, ""}
	Local cAlias     := ""
	Local cQuery     := ""
	Local nCount     := 0
	Local nStart     := 0
	Local oJsRet     := JsonObject():New()
	Local oQuery     := Nil

	Default nPage      := 1
	Default nPageSize  := 20
	Default cInRecurso := ""

	cQuery := " SELECT DISTINCT SMT.MT_RECURSO,"
	cQuery +=                 " SH1.H1_DESCRI,"
	cQuery +=                 " SH1.H1_ILIMITA"
	cQuery +=   " FROM " + RetSqlName("SMT") + " SMT"
	cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1"
	cQuery +=     " ON SH1.H1_FILIAL  = ?"
	cQuery +=    " AND SH1.H1_CODIGO  = SMT.MT_RECURSO"
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE SMT.MT_FILIAL  = ?"
	cQuery +=    " AND SMT.MT_PROG    = ?"
	cQuery +=    " AND SMT.D_E_L_E_T_ = ' '"

	If !Empty(cInRecurso)
		cQuery +=" AND SMT.MT_RECURSO IN (?)"
	EndIf

	cOrder  := " ORDER BY SMT.MT_RECURSO"

	oQuery := FwExecStatement():New(cQuery)
	oQuery:setString(1, xFilial("SH1")) //H1_FILIAL
	oQuery:setString(2, xFilial("SMT")) //MT_FILIAL
	oQuery:setString(3, cProg         ) //MT_PROG

	If !Empty(cInRecurso)
		oQuery:setIn(4, StrTokArr(cInRecurso, ", "))
	EndIf

	cAlias := oQuery:openAlias()

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oJsRet["items"  ] := {}
	oJsRet["hasNext"] := .F.

	While (cAlias)->(!EoF())
		nCount++
		aAdd(oJsRet["items"], JsonObject():New())

		oJsRet["items"][nCount]["recurso"  ] := (cAlias)->MT_RECURSO
		oJsRet["items"][nCount]["descricao"] := (cAlias)->H1_DESCRI
		oJsRet["items"][nCount]["ilimitado"] := (cAlias)->H1_ILIMITA == "S"

		(cAlias)->(dbSkip())
		If nCount >= nPageSize
			Exit
		EndIf
	End

	oJsRet["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If nCount > 0
		aReturn[2] := 200
	EndIf
	aReturn[3] := oJsRet:toJson()

	oQuery:destroy()
	FreeObj(oQuery)
	FreeObj(oJsRet)

Return aReturn

/*/{Protheus.doc} GET DETRECURSO /api/pcp/v1/pcpa152uti/{programacao}/recurso
Retorna a utilizacao dos recursos

@type WSMETHOD
@author marcelo.neumann
@since 10/05/2023
@version P12
@return lReturn, Logic, Identifica se processou corretamente os dados
/*/
WSMETHOD GET DETRECURSO PATHPARAM programacao QUERYPARAM Page, PageSize, dataInicial, dataFinal, recurso WSSERVICE PCPA152UTI
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152UTI"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := P152UTIREC(Self:programacao, Self:Page, Self:PageSize, PCPConvDat(Self:dataInicial, 1), PCPConvDat(Self:dataFinal, 1), Self:recurso, Nil, Nil, .F., .T.)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} P152UTIREC
Busca os dados de utilização dos recursos

@type Static Function
@author marcelo.neumann
@since 10/05/2023
@version P12
@param 01 cProg     , Caracter, Código da programação
@param 02 nPage     , Numeric , Página para consulta
@param 03 nPageSize , Numeric , Tamanho da página
@param 04 cDataIni  , Caracter, Data inicial para filtro dos dados
@param 05 cDataFim  , Caracter, Data final para filtro dos dados
@param 06 cInRecurso, Caracter, Recursos para filtro dos dados
@param 07 cCtrabDe  , Caracter, Centro de trabalho para filtra dados
@param 08 cCtrabAte , Caracter, Centro de trabalho para filtra dados
@param 09 lCtrab    , Logical , Se irá utilizar centro de trabalho para filtrar os dados
@param 10 lJson     , Logical , Valida se o retorno da api é objeto ou json.
@return   aReturn   , Array   , Array com os dados de retorno da API
/*/
Function P152UTIREC(cProg, nPage, nPageSize, dDataIni, dDataFim, cInRecurso, cCtrabDe, cCtrabAte, lCtrab, lJson)
	Local aFiltCT    := {}
	Local aReturn    := Array(3)
	Local cAlias     := GetNextAlias()
	Local cCodRec    := ""
	Local cFields    := ""
	Local cFrom      := ""
	Local cOrder     := ""
	Local cWhere     := ""
	Local cGroup     := ""
	Local nProgramad := 0
	Local nEfetProg  := 0
	Local nApontada  := 0
	Local nCount     := 0
	Local nStart     := 0
	Local oJsRet     := JsonObject():New()

	Default nPage      := 1
	Default nPageSize  := 20
	Default cInRecurso := ""
	Default cCtrabAte  := ""
	Default cCtrabDe   := ""
	Default lCtrab     := .F.

	If lCtrab
		aFiltCT := {cCtrabDe, cCtrabAte}
	EndIf

	cFields := /*SELECT*/" DISTINCT SMR.MR_RECURSO, "
	cFields +=           " SH1.H1_DESCRI, "
	cFields +=           " SUM(SMR.MR_TEMPOTO) disponibilidade, "
	cFields +=           " SUM(SMR.MR_TEMPOEF) efetivadas, "
	cFields +=           " T4X.T4X_STATUS"

	cFrom   :=    /*FROM*/ RetSqlName("SMR") + " SMR "
	cFrom   +=     " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cFrom   +=        " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cFrom   +=       " AND SH1.H1_CODIGO  = SMR.MR_RECURSO "
	cFrom   +=       " AND SH1.D_E_L_E_T_ = ' ' "
	cFrom   +=     " INNER JOIN " + RetSqlName("T4X") + " T4X "
	cFrom   +=        " ON T4X.T4X_FILIAL = '" + xFilial("T4X") + "' "
	cFrom   +=       " AND T4X.T4X_PROG   = SMR.MR_PROG"
	cFrom   +=       " AND T4X.D_E_L_E_T_ = ' '"

	cWhere  :=  /*WHERE*/" SMR.MR_FILIAL  = '" + xFilial("SMR")  + "' "
	cWhere  +=       " AND SMR.MR_PROG    = '" + cProg           + "' "
	cWhere  +=       " AND SMR.MR_TIPO    = '" + MR_TIPO_RECURSO + "' "
	cWhere  +=       " AND SMR.D_E_L_E_T_ = ' ' "
	cWhere  +=       " AND SMR.MR_DATDISP >= '" + DtoS(dDataIni) + "' "
	cWhere  +=       " AND SMR.MR_DATDISP <= '" + DtoS(dDataFim) + "' "

	If !Empty(cInRecurso)
		cWhere +=    " AND SMR.MR_RECURSO IN ('" + StrTran(cInRecurso, ", ", "','") + "') "
	EndIf

	cGroup :=   /*GROUP BY*/" SMR.MR_RECURSO, SH1.H1_DESCRI, T4X.T4X_STATUS, SMR.MR_PROG "

	cOrder  :=  /*ORDER BY*/" SMR.MR_RECURSO, SH1.H1_DESCRI "

	cFields := "%" + cFields + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + "%"
	cGroup  := "%" + cGroup  + "%"
	cOrder  := "%" + cOrder  + "%"

	BeginSql Alias cAlias
		SELECT %Exp:cFields%
		  FROM %Exp:cFrom%
		 WHERE %Exp:cWhere%
		 GROUP BY %Exp:cGroup%
		 ORDER BY %Exp:cOrder%
	EndSql

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oJsRet["items"  ] := {}
	oJsRet["hasNext"] := .F.

	While (cAlias)->(!EoF())
		cCodRec := (cAlias)->MR_RECURSO

		nCount++
		aAdd(oJsRet["items"], JsonObject():New())

		oJsRet["items"][nCount]["recurso"   ] := cCodRec
		oJsRet["items"][nCount]["descricao" ] := (cAlias)->H1_DESCRI

		If (cAlias)->T4X_STATUS == STATUS_EFETIVADO
			nProgramad := 0
			nEfetProg  := getEfetRec(Nil, cProg, .F., .T., cCodRec, "", dDataIni, dDataFim, .F., aFiltCT)
		Else
			nProgramad := getProgRec(Nil, cProg, .F., .T., cCodRec, "", dDataIni, dDataFim, .F., aFiltCT)
			nEfetProg  := 0
		EndIf

		nApontada := getAponRec(Nil, .F., .T., cCodRec, "", dDataIni, dDataFim, .F., aFiltCT)

		oJsRet["items"][nCount]["utilizacao"] := getUtiliza(cProg, dDataIni, dDataFim, cCodRec, Nil, (cAlias)->T4X_STATUS)
		montaHoras(@oJsRet["items"][nCount]["utilizacao"],;
		           (cAlias)->disponibilidade             ,;
		           (cAlias)->efetivadas                  ,;
		           nEfetProg                             ,;
		           nProgramad                            ,;
		           nApontada                              )

		(cAlias)->(dbSkip())
		If nCount >= nPageSize
			Exit
		EndIf
	End

	oJsRet["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If lJson
		aReturn[1] := .T.
		aReturn[2] := 200
		If Empty(oJsRet["items"])
			aReturn[2] := 206
		EndIf
		aReturn[3] := oJsRet:toJson()

		FwFreeObj(oJsRet)
	EndIf

	aSize(aFiltCT, 0)

Return Iif(lJson, aReturn, oJsRet)

/*/{Protheus.doc} montaHoras
Monta o objeto com as horas de capacidade, disponibilidade, efetivadas, programadas e saldo.

@type  Static Function
@author lucas.franca
@since 20/02/2024
@version P12
@param 01 oJS       , JsonObject, Objeto JSON para adicionar as informações das horas
@param 02 nDispSMR  , Numeric   , Horas de disponibilidade (MR_TEMPOTO)
@param 03 nEfetDisp , Numeric   , Horas de disponibilidade efetivadas (MRP_TEMPOEF)
@param 04 nEfetProg , Numeric   , Horas efetivadas da programação (HWF)
@param 05 nProgramad, Numeric   , Horas programadas (SVM)
@param 06 nApontadas, Numeric   , Horas apontadas (HWK)
@param 07 nSetupProg, Numeric   , Setup programado (SVM)
@param 08 nSetupEfet, Numeric   , Setup efetivado (HWF)
@param 09 oDetUti   , Object    , Json para montagem dos detalhes do CT.
@return Nil
/*/
Static Function montaHoras(oJS, nDispSMR, nEfetDisp, nEfetProg, nProgramad, nApontadas, nSetupProg, nSetupEfet, oDetUti)
	Local aNames  := {}
	Local cCodCT  := ""
	Local nCapac  := 0
	Local nDisp   := 0
	Local nEfetiv := 0
	Local nIndex  := 0
	Local nTotal  := 0
	Default nSetupProg := 0
	Default nSetupEfet := 0

	//Capacidade = disponibilidade da SMR + efetivadas da SMR
	nCapac  := nDispSMR + nEfetDisp
	//Efetivadas = efetivadas da SMR + efetivadas da própria programação
	nEfetiv := nEfetDisp + nEfetProg
	//Disponibilidade = disponibilidade da SMR - efetivadas da programação. Não permite negativo.
	nDisp   := Max(0, nDispSMR - nEfetProg)

	oJs["horasCapacidade"     ] := __Min2Hrs(nCapac    , .T.)
	oJs["horasDisponibilidade"] := __Min2Hrs(nDisp     , .T.)
	oJs["horasEfetivadas"     ] := __Min2Hrs(nEfetiv   , .T.)
	oJs["horasProgramadas"    ] := __Min2Hrs(nProgramad, .T.)
	oJs["horasSaldo"          ] := tempoDisp(nCapac, nProgramad, nEfetiv)
	oJs["horasApontadas"      ] := __Min2Hrs(nApontadas, .T.)
	oJs["horasSetup"          ] := __Min2Hrs(nSetupProg + nSetupEfet, .T.)
	oJs["setupProgramado"     ] := __Min2Hrs(nSetupProg, .T.)
	oJs["setupEfetivado"      ] := __Min2Hrs(nSetupEfet, .T.)

	If oDetUti != Nil
		aNames := oDetUti["centrosDeTrabalho"]:getNames()
		nTotal := Len(aNames)

		oJs["detalhamentoCT"] := JsonObject():New()

		oJs["detalhamentoCT"]["horasEfetivadas"] := JsonObject():New()
		oJs["detalhamentoCT"]["horasEfetivadas"]["total"] := oJs["horasEfetivadas"]
		oJs["detalhamentoCT"]["horasEfetivadas"]["noCentroDeTrabalho"      ] := __Min2Hrs(oDetUti["efetivadaCT"       ], .T.)
		oJs["detalhamentoCT"]["horasEfetivadas"]["outrosCentrosDeTrabalho" ] := __Min2Hrs(oDetUti["efetivadaOutrosCTs"], .T.)
		oJs["detalhamentoCT"]["horasEfetivadas"]["horasPorCentroDeTrabalho"] := Array(nTotal)

		oJs["detalhamentoCT"]["horasProgramadas"] := JsonObject():New()
		oJs["detalhamentoCT"]["horasProgramadas"]["total"] := oJs["horasProgramadas"]
		oJs["detalhamentoCT"]["horasProgramadas"]["noCentroDeTrabalho"      ] := __Min2Hrs(oDetUti["programadasCT"       ], .T.)
		oJs["detalhamentoCT"]["horasProgramadas"]["outrosCentrosDeTrabalho" ] := __Min2Hrs(oDetUti["programadasOutrosCTs"], .T.)
		oJs["detalhamentoCT"]["horasProgramadas"]["horasPorCentroDeTrabalho"] := Array(nTotal)

		For nIndex := 1 To nTotal
			cCodCT := aNames[nIndex]

			oJs["detalhamentoCT"]["horasEfetivadas"]["horasPorCentroDeTrabalho"][nIndex] := JsonObject():New()
			oJs["detalhamentoCT"]["horasEfetivadas"]["horasPorCentroDeTrabalho"][nIndex]["centroTrabalho"] := cCodCT
			oJs["detalhamentoCT"]["horasEfetivadas"]["horasPorCentroDeTrabalho"][nIndex]["descricao"     ] := oDetUti["centrosDeTrabalho"][cCodCT]["descricao"]
			oJs["detalhamentoCT"]["horasEfetivadas"]["horasPorCentroDeTrabalho"][nIndex]["horas"         ] := __Min2Hrs(oDetUti["centrosDeTrabalho"][cCodCT]["horasEfetivadas"], .T.)

			oJs["detalhamentoCT"]["horasProgramadas"]["horasPorCentroDeTrabalho"][nIndex] := JsonObject():New()
			oJs["detalhamentoCT"]["horasProgramadas"]["horasPorCentroDeTrabalho"][nIndex]["centroTrabalho"] := cCodCT
			oJs["detalhamentoCT"]["horasProgramadas"]["horasPorCentroDeTrabalho"][nIndex]["descricao"     ] := oDetUti["centrosDeTrabalho"][cCodCT]["descricao"]
			oJs["detalhamentoCT"]["horasProgramadas"]["horasPorCentroDeTrabalho"][nIndex]["horas"         ] := __Min2Hrs(oDetUti["centrosDeTrabalho"][cCodCT]["horasProgramadas"], .T.)
		Next

		aSize(aNames, 0)
	EndIf

Return Nil

/*/{Protheus.doc} getDatas
Busca a utilização de um recurso/ct em cada data.

@type Static Function
@author marcelo.neumann
@since 10/05/2023
@version P12
@param oBusca, Object, Instancia da classe FwExecStatement com a query para buscar a utilização.
@param cProg , Caracter, Código da programação.
@return oReturn, Object, Json com a utilização.
/*/
Static Function getDatas(oBusca, cProg, oHrsEfet, oHrsProg, oApont, oStpProg, oStpEfet, cStatus)
	Local cAlias     := getNextAlias()
	Local cData      := ""
	Local nApontada  := 0
	Local nSetupEfet := 0
	Local nSetupProg := 0
	Local nProgEfetv := 0
	Local nProgramad := 0
	Local oJsHoras   := JsonObject():New()
	Local oReturn    := JsonObject():New()

	cAlias := oBusca:OpenAlias()

	oReturn["datas"      ] := Array(QTD_LINHAS_TIPO)
	oReturn["datasVazias"] := {}

	oReturn["datas"][IND_CAPACIDADE     ] := JsonObject():New()
	oReturn["datas"][IND_DISPONIBILIDADE] := JsonObject():New()
	oReturn["datas"][IND_PROGRAMADAS    ] := JsonObject():New()
	oReturn["datas"][IND_EFETIVADAS     ] := JsonObject():New()
	oReturn["datas"][IND_APONTADAS      ] := JsonObject():New()
	oReturn["datas"][IND_SALDO          ] := JsonObject():New()
	oReturn["datas"][IND_SETUP          ] := JsonObject():New()
	oReturn["datas"][IND_SETUP_PROG     ] := JsonObject():New()
	oReturn["datas"][IND_SETUP_EFET     ] := JsonObject():New()

	While (cAlias)->(!Eof())

		nProgramad := 0
		nSetupProg := 0
		nSetupEfet := 0
		nProgEfetv := 0
		nApontada  := 0

		If oHrsProg:HasProperty((cAlias)->dataDisponibilidade)
			nProgramad := oHrsProg[(cAlias)->dataDisponibilidade]
		EndIf
		If oStpProg:HasProperty((cAlias)->dataDisponibilidade)
			nSetupProg := oStpProg[(cAlias)->dataDisponibilidade]
		EndIf
		If oStpEfet:HasProperty((cAlias)->dataDisponibilidade)
			nSetupEfet := oStpEfet[(cAlias)->dataDisponibilidade]
		EndIf
		If oHrsEfet:HasProperty((cAlias)->dataDisponibilidade)
			nProgEfetv := oHrsEfet[(cAlias)->dataDisponibilidade]
		EndIf
		If oApont:HasProperty((cAlias)->dataDisponibilidade)
			nApontada := oApont[(cAlias)->dataDisponibilidade]
		EndIf

		cData := PCPConvDat((cAlias)->dataDisponibilidade, 4)

		If cStatus == STATUS_EFETIVADO
			nSetupEfet += nSetupProg
			nSetupProg := 0
		EndIf

		montaHoras(@oJsHoras                ,;
		           (cAlias)->disponibilidade,;
		           (cAlias)->efetivadas     ,;
		           nProgEfetv               ,;
		           nProgramad               ,;
		           nApontada                ,;
		           nSetupProg               ,;
		           nSetupEfet               ,;
		           Nil)

		oReturn["datas"][IND_CAPACIDADE     ][cData] := oJsHoras["horasCapacidade"     ]
		oReturn["datas"][IND_DISPONIBILIDADE][cData] := oJsHoras["horasDisponibilidade"]
		oReturn["datas"][IND_EFETIVADAS     ][cData] := oJsHoras["horasEfetivadas"     ]
		oReturn["datas"][IND_PROGRAMADAS    ][cData] := oJsHoras["horasProgramadas"    ]
		oReturn["datas"][IND_SALDO          ][cData] := oJsHoras["horasSaldo"          ]
		oReturn["datas"][IND_SETUP          ][cData] := oJsHoras["horasSetup"          ]
		oReturn["datas"][IND_APONTADAS      ][cData] := __Min2Hrs(nApontada, .T.)
		oReturn["datas"][IND_SETUP_PROG     ][cData] := oJsHoras["setupProgramado"]
		oReturn["datas"][IND_SETUP_EFET     ][cData] := oJsHoras["setupEfetivado" ]

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	FreeObj(oJsHoras)

Return oReturn

/*/{Protheus.doc} completaDt
Percorre os recursos e datas completando as datas sem registro de utilização

@type Static Function
@author marcelo.neumann
@since 10/05/2023
@version P12
@param 01 oJsRet  , Object  , Dados a serem retornados da API (retorno por refereência)
@param 02 cProg   , Caracter, Código da programação para filtro
@param 03 dDataIni, Date    , Data inicial da pesquisa
@param 04 dDataFim, Date    , Data final da pesquisa
@return Nil
/*/
Static Function completaDt(oJsRet, cProg, dDataIni, dDataFim)
	Local cData     := ""
	Local dDataAux  := Nil
	Local nIndData  := 0
	Local nTotDatas := 0

	dDataAux := dDataIni
	nTotDatas := dDataFim - dDataIni + 1

	//Percorre as datas do filtro, preenchendo com zero a data inexistente
	For nIndData := 1 To nTotDatas
		cData := PCPConvDat(PCPConvDat(dDataAux, 2), 3)

		If !oJsRet["datas"][IND_DISPONIBILIDADE]:HasProperty(cData)
			oJsRet["datas"][IND_CAPACIDADE     ][cData] := "00:00"
			oJsRet["datas"][IND_DISPONIBILIDADE][cData] := "00:00"
			oJsRet["datas"][IND_PROGRAMADAS    ][cData] := "00:00"
			oJsRet["datas"][IND_EFETIVADAS     ][cData] := "00:00"
			oJsRet["datas"][IND_APONTADAS      ][cData] := "00:00"
			oJsRet["datas"][IND_SALDO          ][cData] := "00:00"
			oJsRet["datas"][IND_SETUP          ][cData] := "00:00"
			oJsRet["datas"][IND_SETUP_PROG     ][cData] := "00:00"
			oJsRet["datas"][IND_SETUP_EFET     ][cData] := "00:00"

			aAdd(oJsRet["datasVazias"], cData)
		EndIf

		dDataAux++
	Next nIndData

Return

/*/{Protheus.doc} GET GETDETAILCT /api/pcp/v1/pcpa152uti/{programacao}/{centroDeTrabalho}
Retorna a utilização de um centro de trabalho

@type WSMETHOD
@author Lucas Fagundes
@since 19/06/2023
@version P12
@param 01 programacao     , Caracter, Código da programação.
@param 02 centroDeTrabalho, Caracter, Filtro de centro de trabalho.
@param 03 dataInicial     , Date    , Data inicial da programação.
@param 04 dataFinal       , Date    , Data final da programação.
@param 05 recurso         , Caracter, Filtro de recurso.
@return lReturn, Logico, Identifica se processou corretamente os dados
/*/
WSMETHOD GET GETDETAILCT PATHPARAM programacao, centroDeTrabalho QUERYPARAM dataInicial, dataFinal, recurso WSSERVICE PCPA152UTI
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152UTI"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := P152UTICT(Self:programacao, Self:centroDeTrabalho, PCPConvDat(Self:dataInicial, 1), PCPConvDat(Self:dataFinal, 1), Self:recurso, .T.)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} P152UTICT
Retorna a utilização de um centro de trabalho.

@type Function
@author Lucas Fagundes
@since 24/10/2023
@version P12
@param 01 cProg   , Caracter, Código da programação.
@param 02 cCodCT  , Caracter, Código do centro de trabalho.
@param 03 dDataIni, Date    , Data inicial da utilização.
@param 04 dDataFim, Date    , Data final da utilização.
@param 05 cRecurso, Caracter, Filtro de recursos.
@param 06 lJson   , Logical , Valida se o retorno da api é objeto ou json.
@return aReturn, Array, Array com as informações para retorno da API.
/*/
Function P152UTICT(cProg, cCodCT, dDataIni, dDataFim, cRecurso, lJson)
	Local aReturn   := Array(3)
	Local cAliasQtd := getNextAlias()
	Local cAliasSum := getNextAlias()
	Local cAtivo    := STATUS_ATIVO
	Local cCT       := ""
	Local cFiltHWF  := "% 1=1 %"
	Local cFiltHWK  := "% 1=1 %"
	Local cFiltSMF  := "% 1=1 %"
	Local cFiltSMR  := "% 1=1 %"
	Local cFiltSMT  := "% 1=1 %"
	Local oDet      := JsonObject():New()
	Local oHoras    := JsonObject():New()
	Local oReturn   := JsonObject():New()

	oHoras["disponibilidade"     ] := 0
	oHoras["efetivadaSMR"        ] := 0
	oHoras["efetivadaProgramacao"] := 0
	oHoras["programadas"         ] := 0
	oHoras["apontadas"           ] := 0

	oDet["efetivadaCT"         ] := 0
	oDet["efetivadaOutrosCTs"  ] := 0
	oDet["programadasCT"       ] := 0
	oDet["programadasOutrosCTs"] := 0
	oDet["centrosDeTrabalho"   ] := JsonObject():New()

	T4X->(dbSetOrder(1))
	T4X->(dbSeek(xFilial("T4X") + cProg ))

	If !Empty(cRecurso)
		cFiltSMT := "% SMT.MT_RECURSO IN ('" + StrTran(cRecurso, ", ", "','") + "') %"
	EndIf

	BeginSql Alias cAliasQtd
	  SELECT Count(SMT.MT_RECURSO) qtdRecursos
	    FROM %Table:SMT% SMT
	   WHERE SMT.MT_FILIAL = %xFilial:SMT%
	     AND SMT.MT_PROG   = %Exp:cProg%
	     AND SMT.MT_CTRAB  = %Exp:cCodCT%
	     AND SMT.%NotDel%
	     AND %Exp:cFiltSMT%
	EndSql

	If Empty(cRecurso)
		oReturn := getUtiliza(cProg, dDataIni, dDataFim, Nil, cCodCt, T4X->T4X_STATUS)
	Else
		oReturn := getUtiliza(cProg, dDataIni, dDataFim, StrTokArr(cRecurso, ", "), cCodCt, T4X->T4X_STATUS)

		cFiltSMR := "% SMR.MR_RECURSO IN ('" + StrTran(cRecurso, ", ", "','") + "') %"
		cFiltSMF := "% SMF.MF_RECURSO IN ('" + StrTran(cRecurso, ", ", "','") + "') %"
		cFiltHWF := "% HWF.HWF_RECURS IN ('" + StrTran(cRecurso, ", ", "','") + "') %"
		cFiltHWK := "% HWK.HWK_RECURS IN ('" + StrTran(cRecurso, ", ", "','") + "') %"
	EndIf

	BeginSql Alias cAliasSum
	  SELECT SUM(SMR.MR_TEMPOTO) disponibilidade
	    FROM %Table:SMR% SMR
	   INNER JOIN %Table:SMT% SMT
	      ON SMT.MT_FILIAL  = %xFilial:SMT%
	     AND SMT.MT_PROG    = %Exp:cProg%
	     AND SMT.MT_RECURSO = SMR.MR_RECURSO
	     AND SMT.MT_CTRAB   = %Exp:cCodCT%
	     AND SMT.%NotDel%
	   WHERE SMR.MR_FILIAL   = %xFilial:SMR%
	     AND SMR.MR_PROG     = %Exp:cProg%
	     AND SMR.MR_DATDISP >= %Exp:dDataIni%
	     AND SMR.MR_DATDISP <= %Exp:dDataFim%
	     AND SMR.%NotDel%
	     AND %Exp:cFiltSMR%
	EndSql

	oHoras["disponibilidade"] := (cAliasSum)->disponibilidade
	(cAliasSum)->(dbCloseArea())

	BeginSql Alias cAliasSum
		SELECT SUM(HWF.HWF_TEMPOT) efetivadas,
		       	HWF.HWF_CTRAB,
		       	SHB.HB_NOME
		  FROM %Table:HWF% HWF
		  LEFT JOIN %Table:SHB% SHB
		    ON SHB.HB_FILIAL  = %xFilial:SHB%
		   AND SHB.HB_COD     = HWF.HWF_CTRAB
		   AND SHB.%NotDel%
		 WHERE HWF.HWF_FILIAL = %xFilial:HWF%
		   AND HWF.HWF_DATA   >= %Exp:dDataIni%
		   AND HWF.HWF_DATA   <= %Exp:dDataFim%
		   AND HWF.HWF_STATUS = %Exp:cAtivo%
		   AND NOT EXISTS (SELECT 1
		                     FROM %Table:SMF% SMF
		                    WHERE SMF.MF_FILIAL = %xFilial:SMF%
		                      AND SMF.MF_PROG   = %Exp:cProg%
		                      AND SMF.MF_OP     = HWF.HWF_OP
		                      AND SMF.MF_OPER   = HWF.HWF_OPER
		                      AND SMF.%NotDel%)
		   AND HWF.HWF_RECURS IN (SELECT DISTINCT SMT.MT_RECURSO
			                        FROM %Table:SMT% SMT
			                       WHERE SMT.MT_FILIAL = %xFilial:SMT%
			                         AND SMT.MT_PROG   = %Exp:cProg%
			                         AND SMT.MT_CTRAB  = %Exp:cCodCT%)
		   AND %Exp:cFiltHWF%
		   AND HWF.%NotDel%
		 GROUP BY HWF.HWF_CTRAB, SHB.HB_NOME
	EndSql

	While (cAliasSum)->(!EoF())
		cCT := (cAliasSum)->HWF_CTRAB
		oHoras["efetivadaSMR"] += (cAliasSum)->efetivadas

		If cCT == cCodCT
			oDet["efetivadaCT"] += (cAliasSum)->efetivadas
		Else
			oDet["efetivadaOutrosCTs"] += (cAliasSum)->efetivadas

			sumDetCT(@oDet, cCT, (cAliasSum)->HB_NOME, (cAliasSum)->efetivadas, 2)
		EndIf

		(cAliasSum)->(dbSkip())
	End
	(cAliasSum)->(dbCloseArea())

	If T4X->T4X_STATUS == STATUS_EFETIVADO
		BeginSql Alias cAliasSum
			SELECT SUM(HWF.HWF_TEMPOT) efetivadas,
			       HWF.HWF_CTRAB,
			       SHB.HB_NOME
			  FROM %Table:HWF% HWF
			  LEFT JOIN %Table:SHB% SHB
			    ON SHB.HB_FILIAL  = %xFilial:SHB%
			   AND SHB.HB_COD     = HWF.HWF_CTRAB
			   AND SHB.%NotDel%
			 WHERE HWF.HWF_FILIAL = %xFilial:HWF%
			   AND HWF.HWF_PROG   = %Exp:cProg%
			   AND HWF.HWF_DATA   >= %Exp:dDataIni%
			   AND HWF.HWF_DATA   <= %Exp:dDataFim%
			   AND HWF.HWF_RECURS IN (SELECT DISTINCT SMT.MT_RECURSO
			                            FROM %Table:SMT% SMT
			                           WHERE SMT.MT_FILIAL = %xFilial:SMT%
			                             AND SMT.MT_PROG   = %Exp:cProg%
			                             AND SMT.MT_CTRAB  = %Exp:cCodCT%)
			   AND %Exp:cFiltHWF%
			   AND HWF.%NotDel%
			 GROUP BY HWF.HWF_CTRAB, SHB.HB_NOME
		EndSql

		While (cAliasSum)->(!EoF())
			cCT := (cAliasSum)->HWF_CTRAB
			oHoras["efetivadaProgramacao"] += (cAliasSum)->efetivadas

			If cCT == cCodCT
				oDet["efetivadaCT"] += (cAliasSum)->efetivadas
			Else
				oDet["efetivadaOutrosCTs"] += (cAliasSum)->efetivadas

				sumDetCT(@oDet, cCT, (cAliasSum)->HB_NOME, (cAliasSum)->efetivadas, 2)
			EndIf


			(cAliasSum)->(dbSkip())
		End

		(cAliasSum)->(dbCloseArea())
	Else
		BeginSql Alias cAliasSum
			SELECT SUM(SVM.VM_TEMPO) programadas,
			       SMF.MF_CTRAB,
			       SHB.HB_NOME
			  FROM %Table:SVM% SVM
			 INNER JOIN %Table:SMF% SMF
			    ON SMF.MF_FILIAL  = %xFilial:SMF%
			   AND SMF.MF_PROG    = SVM.VM_PROG
			   AND SMF.MF_ID      = SVM.VM_ID
			   AND SMF.MF_RECURSO IN (SELECT DISTINCT SMT.MT_RECURSO
			                            FROM %Table:SMT% SMT
			                           WHERE SMT.MT_FILIAL = %xFilial:SMT%
			                             AND SMT.MT_PROG   = SMF.MF_PROG
			                          	 AND SMT.MT_CTRAB  = %Exp:cCodCT%)
			   AND %Exp:cFiltSMF%
			   AND SMF.%NotDel%
			  LEFT JOIN %Table:SHB% SHB
			    ON SHB.HB_FILIAL  = %xFilial:SHB%
			   AND SHB.HB_COD     = SMF.MF_CTRAB
			   AND SHB.%NotDel%
			 WHERE SVM.VM_FILIAL  = %xFilial:SVM%
			   AND SVM.VM_PROG    = %Exp:cProg%
			   AND SVM.VM_DATA   >= %Exp:dDataIni%
			   AND SVM.VM_DATA   <= %Exp:dDataFim%
			   AND SVM.%NotDel%
			 GROUP BY SMF.MF_CTRAB, SHB.HB_NOME
		EndSql

		While (cAliasSum)->(!EoF())
			cCT := (cAliasSum)->MF_CTRAB
			oHoras["programadas"] += (cAliasSum)->programadas

			If cCT == cCodCT
				oDet["programadasCT"] += (cAliasSum)->programadas
			Else
				oDet["programadasOutrosCTs"] += (cAliasSum)->programadas

				sumDetCT(@oDet, cCT, (cAliasSum)->HB_NOME, (cAliasSum)->programadas, 1)
			EndIf

			(cAliasSum)->(dbSkip())
		End
		(cAliasSum)->(dbCloseArea())
	EndIf

	BeginSql Alias cAliasSum
		SELECT COALESCE(SUM(HWK.HWK_TEMPOT), 0) apontadas
		  FROM %Table:HWK% HWK
		 WHERE HWK.HWK_FILIAL = %xFilial:HWK%
		   AND HWK.HWK_CTRAB  = %Exp:cCodCT%
		   AND HWK.HWK_DATA  >= %Exp:dDataIni%
		   AND HWK.HWK_DATA  <= %Exp:dDataFim%
		   AND %Exp:cFiltHWK%
		   AND HWK.%NotDel%
	EndSql

	oHoras["apontadas"] := (cAliasSum)->apontadas
	(cAliasSum)->(dbCloseArea())

	oReturn["quantidadeRecursos"] := (cAliasQtd)->qtdRecursos
	montaHoras(@oReturn, oHoras["disponibilidade"     ],;
	                     oHoras["efetivadaSMR"        ],;
	                     oHoras["efetivadaProgramacao"],;
	                     oHoras["programadas"         ],;
	                     oHoras["apontadas"           ],;
	                     Nil                           ,;
	                     Nil                           ,;
	                     oDet)
	(cAliasQtd)->(dbCloseArea())

	If lJson
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()

		FwFreeObj(oReturn)
	EndIf
	FreeObj(oHoras)
	FreeObj(oDet)
Return Iif(lJson, aReturn, oReturn)

/*/{Protheus.doc} GET GETRECSCT /api/pcp/v1/pcpa152uti/{programacao}/{centroDeTrabalho}/recursos
Retorna a utilização dos recursos de um centro de trabalho.

@type WSMETHOD
@author Lucas Fagundes
@since 19/06/2023
@version P12
@param 01 programacao     , Caracter, Código da programação.
@param 02 centroDeTrabalho, Caracter, Filtro de centro de trabalho.
@param 03 page            , Numerico, Paginação da consulta.
@param 04 pageSize        , Numerico, Tamanho da página da consulta.
@param 05 dataInicial     , Date    , Data inicial da programação.
@param 06 dataFinal       , Date    , Data final da programação.
@param 07 recurso         , Caracter, Filtro de recurso.
@return lReturn, Logico, Identifica se processou corretamente os dados
/*/
WSMETHOD GET GETRECSCT PATHPARAM programacao, centroDeTrabalho QUERYPARAM page, pageSize, dataInicial, dataFinal, recurso WSSERVICE PCPA152UTI
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152UTI"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getRecsCT(Self:programacao, Self:centroDeTrabalho, Self:page, Self:pageSize, PCPConvDat(Self:dataInicial, 1), PCPConvDat(Self:dataFinal, 1), Self:recurso)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getRecsCT
Retorna a utilização dos recursos de um centro de trabalho.
@type  Static Function
@author Lucas Fagundes
@since 24/10/2023
@version P12
@param 01 cProg    , Caracter, Código da programação.
@param 02 cCodCT   , Caracter, Código do centro de trabalho.
@param 03 nPage    , Numerico, Páginação dos recursos na tela.
@param 04 nPageSize, Numerico, Quantidade de registros por página.
@param 05 dDataIni , Date    , Data inicial da utilização.
@param 06 dDataFim , Date    , Data final da utilização.
@param 07 cRecurso , Caracter, Filtro de recursos.
@return aReturn, Array, Array com as informações para retorno da API.
/*/
Static Function getRecsCT(cProg, cCodCt, nPage, nPageSize, dDataIni, dDataFim, cRecurso)
	Local aReturn    := Array(3)
	Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local nApontada  := 0
	Local nEfetProg  := 0
	Local nProgramad := 0
	Local nCont      := 0
	Local nStart     := 0
	Local oReturn    := JsonObject():New()
	Local oUtiliza   := Nil

	cQuery := " SELECT SMT.MT_RECURSO, "
	cQuery +=        " SMT.MT_CTRAB,   "
	cQuery +=        " SH1.H1_DESCRI,  "
	cQuery +=        " SUM(SMR.MR_TEMPOTO) disponibilidade, "
	cQuery +=        " SUM(SMR.MR_TEMPOEF) efetivadas, "
	cQuery +=        " T4X.T4X_STATUS, "
	cQuery +=        " SH1.H1_ILIMITA "
	cQuery +=   " FROM " + RetSqlName("SMT") + " SMT "
	cQuery +=  " INNER JOIN " + RetSqlName("T4X") + " T4X "
	cQuery +=     " ON T4X.T4X_FILIAL = '" + xFilial("T4X") + "' "
	cQuery +=    " AND T4X.T4X_PROG   = SMT.MT_PROG "
	cQuery +=    " AND T4X.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cQuery +=     " ON " + FwJoinFilial("SH1", "SMT", "SH1", "SMT", .T.)
	cQuery +=    " AND SH1.H1_CODIGO  = SMT.MT_RECURSO "
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SMR") + " SMR "
	cQuery +=     " ON " + FwJoinFilial("SMR", "SMT", "SMR", "SMT", .T.)
	cQuery +=    " AND SMR.MR_PROG     = SMT.MT_PROG "
	cQuery +=    " AND SMR.MR_RECURSO  = SMT.MT_RECURSO "
	cQuery +=    " AND SMR.MR_TIPO     = '" + MR_TIPO_RECURSO + "' "
	cQuery +=    " AND SMR.MR_DATDISP >= '" + DToS(dDataIni) + "' "
	cQuery +=    " AND SMR.MR_DATDISP <= '" + DToS(dDataFim) + "' "
	cQuery +=    " AND SMR.D_E_L_E_T_  = ' ' "
	cQuery +=  " WHERE SMT.MT_FILIAL = '" + xFilial("SMT") + "' "
	cQuery +=    " AND SMT.MT_PROG    = '" + cProg  + "' "
	cQuery +=    " AND SMT.MT_CTRAB   = '" + cCodCt + "' "
	If !Empty(cRecurso)
		cQuery +=" AND SMT.MT_RECURSO IN ('" + StrTran(cRecurso, ", ", "','") + "') "
	EndIf
	cQuery +=    " AND SMT.D_E_L_E_T_ = ' ' "
	cQuery +=  " GROUP BY SMT.MT_RECURSO, SMT.MT_CTRAB, SH1.H1_DESCRI, T4X.T4X_STATUS, SH1.H1_ILIMITA "
	cQuery +=  " ORDER BY SMT.MT_RECURSO "

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias, .F., .F.)

	oReturn["items"] := {}

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	While (cAlias)->(!EoF())
		nCont++

		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCont]["recurso"         ] := (cAlias)->MT_RECURSO
		oReturn["items"][nCont]["centroDeTrabalho"] := (cAlias)->MT_CTRAB
		oReturn["items"][nCont]["descricao"       ] := (cAlias)->H1_DESCRI
		oReturn["items"][nCont]["ilimitado"       ] := (cAlias)->H1_ILIMITA == "S"
		oReturn["items"][nCont]["viewChart"       ] := {"viewChart"}

		If (cAlias)->T4X_STATUS == STATUS_EFETIVADO
			nProgramad := 0
			nEfetProg  := getEfetRec(Nil, cProg, .T., .T., {(cAlias)->MT_RECURSO}, (cAlias)->MT_CTRAB, dDataIni, dDataFim, .F.)
		Else
			nProgramad := getProgRec(Nil, cProg, .T., .T., {(cAlias)->MT_RECURSO}, (cAlias)->MT_CTRAB, dDataIni, dDataFim, .F.)
			nEfetProg  := 0
		EndIf

		nApontada := getAponRec(Nil, .T., .T., {(cAlias)->MT_RECURSO}, (cAlias)->MT_CTRAB, dDataIni, dDataFim, .F.)

		oUtiliza := JsonObject():New()
		montaHoras(@oUtiliza                ,;
		           (cAlias)->disponibilidade,;
		           (cAlias)->efetivadas     ,;
		           nEfetProg                ,;
		           nProgramad               ,;
		           nApontada                 )

		oReturn["items"][nCont]["utilizacao"] := oUtiliza
		oUtiliza := Nil

		(cAlias)->(dbSkip())
		If nCont >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getUtiliza
Realiza a busca da utilização de acordo com os parâmetros recebidos.
1 - Realiza a busca da utilização geral de um recurso.
2 - Realiza a busca da utilização de um recurso em um CT.
3 - Realiza a busca de utilização geral de um CT.

@type  Static Function
@author Lucas Fagundes
@since 20/06/2023
@version P12
@param 01 cProg   , Caracter      , Código da programação.
@param 02 dDataIni, Date          , Data inicial da utilização.
@param 03 dDataFim, Date          , Data final da utilização.
@param 04 xRecurso, Caracter/Array, Código do recurso quando for buscar a utilização de um recurso ou array com os recursos quando for buscar a utilização de um ct.
@param 05 cCodCt  , Caracter      , Código do centro de trabalho.
@param 06 cStatus , Caracter      , Status da programação (T4X_STATUS)
@return oReturn, Object, Json com a utilização do recurso/centro de trabalho.
/*/
Static Function getUtiliza(cProg, dDataIni, dDataFim, xRecurso, cCodCt, cStatus)
	Local cQuery     := ""
	Local lFiltraRec := .F.
	Local lGroupCT   := .F.
	Local nPosPar    := 1
	Local oBusca     := Nil
	Local oReturn    := Nil
	Local oHrsProg   := JsonObject():New()
	Local oHrsEfet   := JsonObject():New()
	Local oApont     := JsonObject():New()
	Local oStpProg   := JsonObject():New()
	Local oStpEfet   := JsonObject():New()

	If cCodCt != Nil
		lGroupCT := .T.

		If xRecurso != Nil
			// 2 - Realiza a busca da utilização de um recurso em um CT.
			If _oUtiRecCT == Nil
				cQuery := getQryUtiCt(.T.)

				_oUtiRecCT := FwExecStatement():New(cQuery)
			EndIf
			lFiltraRec := .T.
			oBusca     := _oUtiRecCT
		Else
			// 3 - Realiza a busca de utilização geral de um CT.
			If _oUtiCt == Nil
				cQuery := getQryUtiCt(.F.)

				_oUtiCt := FwExecStatement():New(cQuery)
			EndIf
			lFiltraRec := .F.
			oBusca     := _oUtiCt
		EndIf

		oBusca:setString(nPosPar++, xFilial("SMR") ) // SMR.MR_FILIAL
		oBusca:setString(nPosPar++, cProg          ) // SMR.MR_PROG
		oBusca:setString(nPosPar++, MR_TIPO_RECURSO) // SMR.MR_TIPO

		oBusca:setDate(nPosPar++, dDataIni) // SMR.MR_DATDISP
		oBusca:setDate(nPosPar++, dDataFim) // SMR.MR_DATDISP

		oBusca:setString(nPosPar++, xFilial("SMT")) // SMT.MT_FILIAL
		oBusca:setString(nPosPar++, cProg  ) // SMT.MT_PROG
		oBusca:setString(nPosPar++, cCodCt ) // SMT.MT_CTRAB

		If lFiltraRec
			oBusca:setIn(nPosPar++, xRecurso) // SMT.MT_RECURSO
		EndIf

	Else // 1 - Realiza a busca da utilização geral de um recurso.
		If _oUtiRec == Nil
			cQuery := " SELECT SMR.MR_RECURSO recurso, "
			cQuery +=        " SMR.MR_DATDISP dataDisponibilidade, "
			cQuery +=        " SMR.MR_TEMPOTO disponibilidade, "
			cQuery +=        " SMR.MR_TEMPOEF efetivadas"
			cQuery +=   " FROM " + RetSqlName("SMR") + " SMR"
			cQuery +=  " WHERE SMR.MR_FILIAL  =  ? "
			cQuery +=    " AND SMR.MR_PROG    =  ? "
			cQuery +=    " AND SMR.MR_TIPO    =  ? "
			cQuery +=    " AND SMR.D_E_L_E_T_ = ' ' "
			cQuery +=    " AND SMR.MR_RECURSO =  ? "
			cQuery +=    " AND SMR.MR_DATDISP >= ? "
			cQuery +=    " AND SMR.MR_DATDISP <= ? "
			cQuery +=  " ORDER BY recurso, dataDisponibilidade"

			_oUtiRec := FwExecStatement():New(cQuery)
		EndIf

		_oUtiRec:setString(nPosPar++, xFilial("SMR") ) // SMR.MR_FILIAL
		_oUtiRec:setString(nPosPar++, cProg   ) // SMR.MR_PROG
		_oUtiRec:setString(nPosPar++, MR_TIPO_RECURSO) // SMR.MR_TIPO
		_oUtiRec:setString(nPosPar++, xRecurso) // SMR.MR_RECURSO

		_oUtiRec:setDate(nPosPar++, dDataIni) // SMR.MR_DATDISP
		_oUtiRec:setDate(nPosPar++, dDataFim) // SMR.MR_DATDISP

		oBusca     := _oUtiRec
		lFiltraRec := .T.
	EndIf

	If cStatus == STATUS_EFETIVADO
		//Horas programadas que estão efetivadas
		getEfetRec(@oHrsEfet, cProg, lGroupCT, lFiltraRec, xRecurso, cCodCT, dDataIni, dDataFim, .T.)
	Else
		//Horas programadas
		getProgRec(@oHrsProg, cProg, lGroupCT, lFiltraRec, xRecurso, cCodCT, dDataIni, dDataFim, .T.)
	EndIf

	//Horas apontadas
	getAponRec(@oApont, lGroupCT, lFiltraRec, xRecurso, cCodCT, dDataIni, dDataFim, .T.)

	//Setup programado e setup efetivado
	getStpRec(@oStpProg, @oStpEfet, cProg, lGroupCT, lFiltraRec, xRecurso, cCodCT, dDataIni, dDataFim)

	oReturn := getDatas(oBusca, cProg, oHrsEfet, oHrsProg, oApont, oStpProg, oStpEfet, cStatus)

	completaDt(@oReturn, cProg, dDataIni, dDataFim)

	oBusca := Nil
	FreeObj(oHrsProg)
	FreeObj(oHrsEfet)
	FreeObj(oApont  )
	FreeObj(oStpProg)
	FreeObj(oStpEfet)
Return oReturn

/*/{Protheus.doc} execQrySum
Executa a query com o sum de dados e alimenta o JSON com as datas e totais.
A query deve estar com os alias dos campos como DIA para o campo de data e TOTAL para o campo de horas.

@type  Static Function
@author lucas.franca
@since 25/10/2024
@version P12
@param 01 oData     , Object, JsonObject onde será retornado por referência os dados
@param 02 oExec     , Object, Objeto preparado de execução da query, já com os parâmetros setados
@param 03 lGroupData, Logic , Identifica se agrupa por data, ou se retorna o total de todos os dias
@return nTotal, Numeric, Total quando não utilizado o lGroupData
/*/
Static Function execQrySum(oData, oExec, lGroupData)
	Local cAlias := oExec:openAlias()
	Local nTotal := 0

	Default lGroupData := .T.

	If lGroupData
		While (cAlias)->(!Eof())
			oData[(cAlias)->DIA] := (cAlias)->TEMPO
			(cAlias)->(dbSkip())
		End
	Else
		nTotal := (cAlias)->TEMPO
	EndIf
	(cAlias)->(dbCloseArea())
Return nTotal

/*/{Protheus.doc} getStpRec
Busca as horas de setup de um recurso, ct ou de recursos em um ct

@type  Static Function
@author lucas.franca
@since 24/10/2024
@version P12
@param 01 oStpProg  , Object        , Retorna os dados de setup programado por referência
@param 02 oStpEfet  , Object        , Retorna os dados de setup efetivado por referência
@param 03 cProg     , Caracter      , Número da programação
@param 04 lGroupCT  , Logic         , Query agrupando por CT e filtrando CT
@param 05 lFiltraRec, Logic         , Aplica filtro de recursos
@param 06 xRecurso  , Caracter/Array, Código do recurso. Quando por CT é um array e filtra com IN. Caso contrário filtra com =
@param 07 cCodCT    , Caracter      , Código do centro de trabalho
@param 08 dDataIni  , Date          , Data inicial para buscar as horas
@param 09 dDataFim  , Date          , Data final para buscar as horas
@return Nil
/*/
Static Function getStpRec(oStpProg, oStpEfet, cProg, lGroupCT, lFiltraRec, xRecurso, cCodCT, dDataIni, dDataFim)
	Local cQuery    := ""
	Local cFiltRec  := " = ?"
	Local nPosParam := 1
	Local oExec     := Nil

	//Busca do setup da programação
	cQuery := " SELECT SVM.VM_DATA DIA, SUM(SVM.VM_TEMPO) TEMPO "
	cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
	cQuery +=  " INNER JOIN " + RetSqlName("SVM") + " SVM "
	cQuery +=     " ON SVM.VM_FILIAL = ? "
	cQuery +=    " AND SVM.VM_PROG   = SMF.MF_PROG"
	cQuery +=    " AND SVM.VM_ID     = SMF.MF_ID"
	cQuery +=    " AND SVM.VM_DATA BETWEEN ? AND ?"
	cQuery +=    " AND SVM.VM_TIPO   IN (" + cValToChar(VM_TIPO_SETUP) + "," + cValToChar(VM_TIPO_FINALIZACAO) + ")"
	cQuery +=    " AND SVM.D_E_L_E_T_ = ' '
	cQuery +=  " WHERE SMF.MF_FILIAL  = ? "
	cQuery +=    " AND SMF.MF_PROG    = ? "

	If lGroupCT
		cQuery +=" AND SMF.MF_CTRAB   = ?"
		cFiltRec := " IN (?)"
	EndIf

	If lFiltraRec
		cQuery +=" AND SMF.MF_RECURSO" + cFiltRec
	EndIf

	cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
	cQuery +=  " GROUP BY SVM.VM_DATA"

	oExec := FwExecStatement():New(cQuery)

	oExec:setString(nPosParam++, xFilial("SVM")) //VM_FILIAL
	oExec:setDate(nPosParam++  , dDataIni      ) //VM_DATA
	oExec:setDate(nPosParam++  , dDataFim      ) //VM_DATA
	oExec:setString(nPosParam++, xFilial("SMF")) //MF_FILIAL
	oExec:setString(nPosParam++, cProg         ) //MF_PROG

	If lGroupCT
		oExec:setString(nPosParam++, cCodCT    ) //MF_CTRAB
		If lFiltraRec
			oExec:setIn(nPosParam++, xRecurso  ) //MF_RECURSO
		EndIf
	ElseIf lFiltraRec
		oExec:setString(nPosParam++, xRecurso  ) //MF_RECURSO
	EndIf

	execQrySum(@oStpProg, @oExec)

	oExec:destroy()
	FreeObj(oExec)

	//Busca do Setup das disponibilidades efetivadas, considerando as OPs que não entraram na programação.
	cQuery := " SELECT HWF.HWF_DATA DIA, SUM(HWF.HWF_TEMPOT) TEMPO"
	cQuery +=   " FROM " + RetSqlName("HWF") + " HWF"
	cQuery +=  " INNER JOIN " + RetSqlName("SMR") + " SMR"
	cQuery +=     " ON SMR.MR_FILIAL  = ?"
	cQuery +=    " AND SMR.MR_PROG    = ?"
	cQuery +=    " AND SMR.MR_TIPO    = ?"
	cQuery +=    " AND SMR.MR_RECURSO = HWF.HWF_RECURS"
	cQuery +=    " AND SMR.MR_DATDISP = HWF.HWF_DATA"
	cQuery +=    " AND SMR.MR_TEMPOEF <> 0"
	cQuery +=    " AND SMR.D_E_L_E_T_ = ' '"
	If lGroupCT
		cQuery +=  " INNER JOIN " + RetSqlName("SMT") + " SMT"
		cQuery +=     " ON SMT.MT_FILIAL  = ?"
		cQuery +=    " AND SMT.MT_PROG    = SMR.MR_PROG"
		cQuery +=    " AND SMT.MT_RECURSO = SMR.MR_RECURSO"
		cQuery +=    " AND SMT.MT_CTRAB   = ?"
		If lFiltraRec
			cQuery +=" AND SMT.MT_RECURSO IN (?)"
		EndIf
		cQuery +=    " AND SMT.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=   " LEFT JOIN " + RetSqlName("SMF") + " SMF"
	cQuery +=     " ON SMF.MF_FILIAL  = ?"
	cQuery +=    " AND SMF.MF_PROG    = SMR.MR_PROG"
	cQuery +=    " AND SMF.MF_OP      = HWF.HWF_OP"
	cQuery +=    " AND SMF.MF_OPER    = HWF.HWF_OPER"
	cQuery +=    " AND SMF.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE HWF.HWF_FILIAL = ?"
	cQuery +=    " AND HWF.HWF_TIPO IN (" + cValToChar(VM_TIPO_SETUP) + "," + cValToChar(VM_TIPO_FINALIZACAO) + ")"
	cQuery +=    " AND HWF.HWF_DATA BETWEEN ? AND ?"

	If lGroupCT
		cQuery +=" AND HWF.HWF_CTRAB = ?"
	EndIf

	If lFiltraRec
		cQuery +=" AND HWF.HWF_RECURS" + cFiltRec
	EndIf

	cQuery +=    " AND SMF.MF_OP IS NULL"
	cQuery +=    " AND HWF.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY HWF.HWF_DATA"

	oExec     := FwExecStatement():New(cQuery)
	nPosParam := 1

	oExec:setString(nPosParam++, xFilial("SMR") ) //MR_FILIAL
	oExec:setString(nPosParam++, cProg          ) //MR_PROG
	oExec:setString(nPosParam++, MR_TIPO_RECURSO) //MR_TIPO

	If lGroupCT
		oExec:setString(nPosParam++, xFilial("SMR")) //MT_FILIAL
		oExec:setString(nPosParam++, cCodCT        ) //MT_CTRAB
		If lFiltraRec
			oExec:setIn(nPosParam++, xRecurso      ) //MT_RECURSO
		EndIf
	EndIf
	oExec:setString(nPosParam++, xFilial("SMF")) //MF_FILIAL
	oExec:setString(nPosParam++, xFilial("HWF")) //HWF_FILIAL
	oExec:setDate(nPosParam++  , dDataIni      ) //HWF_DATA
	oExec:setDate(nPosParam++  , dDataFim      ) //HWF_DATA

	If lGroupCT
		oExec:setString(nPosParam++, cCodCT    ) //HWF_CTRAB
		If lFiltraRec
			oExec:setIn(nPosParam++, xRecurso  ) //HWF_RECURS
		EndIf
	ElseIf lFiltraRec
		oExec:setString(nPosParam++, xRecurso  ) //HWF_RECURS
	EndIf

	execQrySum(@oStpEfet, @oExec)

	oExec:destroy()
	FreeObj(oExec)

Return Nil

/*/{Protheus.doc} getAponRec
Busca as horas apontadas de um recurso, de um ct ou de recursos no ct

@type  Static Function
@author lucas.franca
@since 24/10/2024
@version P12
@param 01 oApont    , Object        , Retorna os dados por referência
@param 02 lGroupCT  , Logic         , Query agrupando por CT e filtrando CT
@param 03 lFiltraRec, Logic         , Aplica filtro de recursos
@param 04 xRecurso  , Caracter/Array, Código do recurso. Quando por CT é um array e filtra com IN. Caso contrário filtra com =
@param 05 cCodCT    , Caracter      , Código do centro de trabalho
@param 06 dDataIni  , Date          , Data inicial para buscar as horas
@param 07 dDataFim  , Date          , Data final para buscar as horas
@param 08 lGroupData, Logic         , Identifica se agrupa por data, ou se retorna o total de todos os dias
@param 09 aFiltCT   , Array         , Filtro DE/ATÉ para o centro de trabalho. aFiltCT[1] = CT DE. aFiltCT[2] = CT ATÉ
@return nTotal, Numeric, Total de horas, quando lGroupData é .F.
/*/
Static Function getAponRec(oApont, lGroupCT, lFiltraRec, xRecurso, cCodCT, dDataIni, dDataFim, lGroupData, aFiltCT)
	Local cQuery    := ""
	Local cFiltRec  := " = ?"
	Local lFiltCT   := !Empty(aFiltCT)
	Local nTotal    := 0
	Local nPosParam := 1
	Local oExec     := Nil

	cQuery := " SELECT SUM(HWK.HWK_TEMPOT) TEMPO"
	If lGroupData
		cQuery +=    ",HWK.HWK_DATA DIA"
	EndIf
	cQuery +=   " FROM " + RetSqlName("HWK") + " HWK"
	cQuery +=  " WHERE HWK.HWK_FILIAL = ?"

	If lFiltCT
		cQuery +=" AND HWK.HWK_CTRAB BETWEEN ? AND ?"
	EndIf

	If lGroupCT
		cQuery +=" AND HWK.HWK_CTRAB  = ?"
		cFiltRec := " IN (?)"
	EndIf

	If lFiltraRec
		cQuery +=" AND HWK.HWK_RECURS" + cFiltRec
	EndIf
	cQuery +=    " AND HWK.HWK_DATA BETWEEN ? AND ?"
	cQuery +=    " AND HWK.D_E_L_E_T_ = ' '"
	If lGroupData
		cQuery +=" GROUP BY HWK.HWK_DATA"
	EndIf

	oExec := FwExecStatement():New(cQuery)

	oExec:setString(nPosParam++, xFilial("HWK")) //HWK_FILIAL

	If lFiltCT
		oExec:setString(nPosParam++, aFiltCT[1]) //HWK_CTRAB
		oExec:setString(nPosParam++, aFiltCT[2]) //HWK_CTRAB
	EndIf

	If lGroupCT
		oExec:setString(nPosParam++, cCodCT    ) //HWK_CTRAB
		If lFiltraRec
			oExec:setIn(nPosParam++, xRecurso  ) //HWK_RECURS
		EndIf
	ElseIf lFiltraRec
		oExec:setString(nPosParam++, xRecurso  ) //HWK_RECURS
	EndIf
	oExec:setDate(nPosParam++, dDataIni)
	oExec:setDate(nPosParam++, dDataFim)

	nTotal := execQrySum(@oApont, @oExec, lGroupData)

	oExec:Destroy()
	FreeObj(oExec)
Return nTotal

/*/{Protheus.doc} getEfetRec
Busca as horas efetivadas de um recurso, de um ct, ou de recursos em um ct

@type  Static Function
@author lucas.franca
@since 24/10/2024
@version P12
@param 01 oHrsEfet  , Object        , Retorna os dados por referência
@param 02 cProg     , Caracter      , Número da programação
@param 03 lGroupCT  , Logic         , Query agrupando por CT e filtrando CT
@param 04 lFiltraRec, Logic         , Aplica filtro de recursos
@param 05 xRecurso  , Caracter/Array, Código do recurso. Quando por CT é um array e filtra com IN. Caso contrário filtra com =
@param 06 cCodCT    , Caracter      , Código do centro de trabalho
@param 07 dDataIni  , Date          , Data inicial para buscar as horas
@param 08 dDataFim  , Date          , Data final para buscar as horas
@param 09 lGroupData, Logic         , Identifica se agrupa por data, ou se retorna o total de todos os dias
@param 10 aFiltCT   , Array         , Filtro DE/ATÉ para o centro de trabalho. aFiltCT[1] = CT DE. aFiltCT[2] = CT ATÉ
@return nTotal, Numeric, Total de horas, quando lGroupData é .F.
/*/
Static Function getEfetRec(oHrsEfet, cProg, lGroupCT, lFiltraRec, xRecurso, cCodCT, dDataIni, dDataFim, lGroupData, aFiltCT)
	Local aTipos    := {VM_TIPO_SETUP, VM_TIPO_PRODUCAO, VM_TIPO_FINALIZACAO}
	Local cQuery    := ""
	Local cFiltRec  := " = ?"
	Local lFiltCT   := !Empty(aFiltCT)
	Local nPosParam := 1
	Local nTotal    := 0
	Local oExec     := Nil

	cQuery := "SELECT SUM(HWF.HWF_TEMPOT) TEMPO"
	If lGroupData
		cQuery +=   ",HWF.HWF_DATA DIA"
	EndIf
	cQuery +=   " FROM " + RetSqlName("HWF") + " HWF"
	cQuery +=  " WHERE HWF.HWF_FILIAL = ?"
	cQuery +=    " AND HWF.HWF_PROG   = ?"
	If lFiltCT
		cQuery +=" AND HWF.HWF_CTRAB BETWEEN ? AND ?"
	EndIf
	If lGroupCT
		cQuery +=" AND HWF.HWF_CTRAB  = ?"
		cFiltRec := " IN (?)"
	EndIf
	If lFiltraRec
		cQuery +=" AND HWF.HWF_RECURS" + cFiltRec
	EndIf
	cQuery +=    " AND HWF.HWF_DATA   BETWEEN ? AND ?"
	cQuery +=    " AND HWF.HWF_TIPO   IN (?)"
	cQuery +=    " AND HWF.D_E_L_E_T_ = ' '"
	If lGroupData
		cQuery +=" GROUP BY HWF.HWF_DATA"
	EndIf

	oExec := FwExecStatement():New(cQuery)

	oExec:setString(nPosParam++, xFilial("HWF")) //HWF_FILIAL
	oExec:setString(nPosParam++, cProg         ) //HWF_PROG

	If lFiltCT
		oExec:setString(nPosParam++, aFiltCT[1]) //HWF_CTRAB
		oExec:setString(nPosParam++, aFiltCT[2]) //HWF_CTRAB
	EndIf

	If lGroupCT
		oExec:setString(nPosParam++, cCodCT) //HWF_CTRAB
		If lFiltraRec
			oExec:setIn(nPosParam++, xRecurso) //HWF_RECURS
		EndIf
	ElseIf lFiltraRec
		oExec:setString(nPosParam++, xRecurso) //HWF_RECURS
	EndIf

	oExec:setDate(nPosParam++, dDataIni) // HWF_DATA
	oExec:setDate(nPosParam++, dDataFim) // HWF_DATA
	oExec:setIn(nPosParam++, aTipos) // HWF_TIPO

	nTotal := execQrySum(@oHrsEfet, @oExec, lGroupData)

	oExec:Destroy()
	FreeObj(oExec)

	aSize(aTipos, 0)
Return nTotal

/*/{Protheus.doc} getProgRec
Busca as horas programadas de um recurso, de um ct, ou de recursos em um ct

@type  Static Function
@author lucas.franca
@since 24/10/2024
@version P12
@param 01 oHrsProg  , Object        , Retorna os dados por referência
@param 02 cProg     , Caracter      , Número da programação
@param 03 lGroupCT  , Logic         , Query agrupando por CT e filtrando CT
@param 04 lFiltraRec, Logic         , Aplica filtro de recursos
@param 05 xRecurso  , Caracter/Array, Código do recurso. Quando por CT é um array e filtra com IN. Caso contrário filtra com =
@param 06 cCodCT    , Caracter      , Código do centro de trabalho
@param 07 dDataIni  , Date          , Data inicial para buscar as horas
@param 08 dDataFim  , Date          , Data final para buscar as horas
@param 09 lGroupData, Logic         , Identifica se agrupa por data, ou se retorna o total de todos os dias
@param 10 aFiltCT   , Array         , Filtro DE/ATÉ para o centro de trabalho. aFiltCT[1] = CT DE. aFiltCT[2] = CT ATÉ
@return nTotal, Numeric, Total de horas, quando lGroupData é .F.
/*/
Static Function getProgRec(oHrsProg, cProg, lGroupCT, lFiltraRec, xRecurso, cCodCT, dDataIni, dDataFim, lGroupData, aFiltCT)
	Local aTipos    := {VM_TIPO_SETUP, VM_TIPO_PRODUCAO, VM_TIPO_FINALIZACAO}
	Local cQuery    := ""
	Local cFiltRec  := " = ?"
	Local lFiltCT   := !Empty(aFiltCT)
	Local nPosParam := 1
	Local nTotal    := 0
	Local oExec     := Nil

	cQuery := " SELECT SUM(SVM.VM_TEMPO) TEMPO"
	If lGroupData
		cQuery +=    ",SVM.VM_DATA DIA"
	EndIf
	cQuery +=   " FROM " + RetSqlName("SMF") + " SMF"
	cQuery +=  " INNER JOIN " + RetSqlName("SVM") + " SVM"
	cQuery +=     " ON SVM.VM_FILIAL  = ?"
	cQuery +=    " AND SVM.VM_PROG    = SMF.MF_PROG"
	cQuery +=	 " AND SVM.VM_ID      = SMF.MF_ID"
	cQuery +=    " AND SVM.VM_DATA BETWEEN ? AND ?"
	cQuery +=    " AND SVM.VM_TIPO   IN (?)"
	cQuery +=    " AND SVM.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE SMF.MF_FILIAL  = ?"
	cQuery +=    " AND SMF.MF_PROG    = ?"

	If lFiltCT
		cQuery +=" AND SMF.MF_CTRAB BETWEEN ? AND ?"
	EndIf

	If lGroupCT
		cQuery +=" AND SMF.MF_CTRAB   = ?"
		cFiltRec := " IN (?)"
	EndIf

	If lFiltraRec
		cQuery +=" AND SMF.MF_RECURSO" + cFiltRec
	EndIf

	cQuery +=    " AND SMF.D_E_L_E_T_ = ' '"

	If lGroupData
		cQuery +=" GROUP BY SVM.VM_DATA"
	EndIf

	oExec := FwExecStatement():New(cQuery)

	oExec:setString(nPosParam++, xFilial("SVM")) //VM_FILIAL
	oExec:setDate(nPosParam++  , dDataIni      ) //VM_DATA
	oExec:setDate(nPosParam++  , dDataFim      ) //VM_DATA
	oExec:setIn(nPosParam++    , aTipos        ) //VM_TIPO
	oExec:setString(nPosParam++, xFilial("SMF")) //MF_FILIAL
	oExec:setString(nPosParam++, cProg         ) //MF_PROG

	If lFiltCT
		oExec:setString(nPosParam++, aFiltCT[1]) //MF_CTRAB
		oExec:setString(nPosParam++, aFiltCT[2]) //MF_CTRAB
	EndIf

	If lGroupCT
		oExec:setString(nPosParam++, cCodCT) //MF_CTRAB
	EndIf

	If lFiltraRec
		If lGroupCT
			oExec:setIn(nPosParam++, xRecurso) //MF_RECURSO
		Else
			oExec:setString(nPosParam++, xRecurso) //MF_RECURSO
		EndIf
	EndIf

	nTotal := execQrySum(@oHrsProg, @oExec, lGroupData)

	oExec:Destroy()
	FreeObj(oExec)

	aSize(aTipos, 0)
Return nTotal

/*/{Protheus.doc} getQryUtiCt
Monta a query para buscar a utilização filtrando centro de trabalho.
@type  Static Function
@author Lucas Fagundes
@since 20/06/2023
@version P12
@param lFiltraRec, Logico, Indica que a query será para um recurso especifico.
@return cQuery, Caracter, Query para buscar utilização filtrando centro de trabalho.
/*/
Static Function getQryUtiCt(lFiltraRec)
	Local cQuery := ""

	cQuery := " SELECT SMR.MR_DATDISP dataDisponibilidade, "
	cQuery +=        " SUM(SMR.MR_TEMPOTO) disponibilidade, "
	cQuery +=        " SUM(SMR.MR_TEMPOEF) efetivadas "
	cQuery +=   " FROM " + RetSqlName("SMR") + " SMR "
	cQuery +=  " WHERE SMR.MR_FILIAL  =  ? "
	cQuery +=    " AND SMR.MR_PROG    =  ? "
	cQuery +=    " AND SMR.MR_TIPO    =  ? "
	cQuery +=    " AND SMR.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SMR.MR_DATDISP >=  ? "
	cQuery +=    " AND SMR.MR_DATDISP <=  ? "
	cQuery +=    " AND SMR.MR_RECURSO IN (SELECT SMT.MT_RECURSO "
	cQuery +=                             " FROM " + RetSqlName("SMT") + " SMT "
	cQuery +=                            " WHERE SMT.MT_FILIAL  =  ? "
	cQuery +=                              " AND SMT.MT_PROG    =  ? "
	cQuery +=                              " AND SMT.MT_CTRAB   =  ? "

	If lFiltraRec
		cQuery +=                          " AND SMT.MT_RECURSO IN (?) "
	EndIf

	cQuery +=                              " AND SMT.D_E_L_E_T_ = ' ') "
	cQuery +=  " GROUP BY SMR.MR_DATDISP, SMR.MR_PROG "
	cQuery +=  " ORDER BY dataDisponibilidade "

Return cQuery

/*/{Protheus.doc} GET DETAILREC /api/pcp/v1/pcpa152uti/{programacao}/{centroDeTrabalho}/{recurso}
Retorna a utilização de um recurso em um centro de trabalho

@type WSMETHOD
@author Lucas Fagundes
@since 19/06/2023
@version P12
@param 01 programacao     , Caracter, Código da programação.
@param 02 centroDeTrabalho, Caracter, Filtro de centro de trabalho.
@param 03 recurso         , Caracter, Filtro de recurso.
@param 04 dataInicial     , Date    , Data inicial da programação.
@param 05 dataFinal       , Date    , Data final da programação.
@return lReturn, Logico, Identifica se processou corretamente os dados
/*/
WSMETHOD GET DETAILREC PATHPARAM programacao, centroDeTrabalho, recurso QUERYPARAM dataInicial, dataFinal WSSERVICE PCPA152UTI
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152UTI"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getDetRec(Self:programacao, Self:centroDeTrabalho, Self:recurso, PCPConvDat(Self:dataInicial, 1), PCPConvDat(Self:dataFinal, 1))
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getDetRec
Retorna a utilização de um recurso em um centro de trabalho.
@type  Static Function
@author Lucas Fagundes
@since 04/07/2023
@version P12
@param 01 cProg   , Caracter, Código da programação.
@param 02 cCodCT  , Caracter, Filtro de centro de trabalho.
@param 03 cRecurso, Caracter, Filtro de recurso.
@param 04 dDataIni, Date    , Data inicial da programação.
@param 05 dDataFim, Date    , Data final da programação.
@return aReturn, Array, Array com o retorno da API.
/*/
Static Function getDetRec(cProg, cCodCT, cRecurso, dDataIni, dDataFim)
	Local aReturn    := Array(3)
	Local cAlias     := ""
	Local cQuery     := ""
	Local nPosPar    := 1
	Local oRecurso   := Nil
	Local oReturn    := JsonObject():New()

	If _oDetRec == Nil
		cQuery := " SELECT DISTINCT SMT.MT_RECURSO, "
		cQuery +=                 " SH1.H1_DESCRI, "
		cQuery +=                 " SMT.MT_CTRAB, "
		cQuery +=                 " SHB.HB_NOME, "
		cQuery +=                 " SUM(SMR.MR_TEMPOTO) disponibilidade, "
		cQuery +=                 " SUM(SMR.MR_TEMPOEF) efetivadas,"
		cQuery +=                 " CASE T4X.T4X_STATUS "
		cQuery +=                     " WHEN '"+STATUS_EFETIVADO+"' THEN 0 "
		cQuery +=                     " ELSE (SELECT SUM(SVM.VM_TEMPO) "
		cQuery +=                             " FROM " + RetSqlName("SVM") + " SVM "
		cQuery +=                            " INNER JOIN " + RetSqlName("SMF") + " SMF "
		cQuery +=                               " ON SMF.MF_FILIAL = ?"
		cQuery +=                              " AND SMF.MF_PROG    = SVM.VM_PROG "
		cQuery +=                              " AND SMF.MF_RECURSO = SMT.MT_RECURSO "
		cQuery +=                              " AND SMF.MF_CTRAB   = SMT.MT_CTRAB "
		cQuery +=                              " AND SMF.MF_ID      = SVM.VM_ID "
		cQuery +=                              " AND SMF.D_E_L_E_T_ = ' ' "
		cQuery +=                            " WHERE SVM.VM_FILIAL  = ?"
		cQuery +=                              " AND SVM.D_E_L_E_T_ = ' ' "
		cQuery +=                              " AND SVM.VM_PROG    = SMT.MT_PROG "
		cQuery +=                              " AND SVM.VM_DATA >= ? "
		cQuery +=                              " AND SVM.VM_DATA <= ?)"
		cQuery +=                 " END programada,"
		cQuery +=                 " CASE T4X.T4X_STATUS "
		cQuery +=                    " WHEN '"+STATUS_EFETIVADO+"' THEN (SELECT COALESCE(SUM(HWF.HWF_TEMPOT), 0)"
		cQuery +=                                     " FROM " + RetSqlName("HWF") + " HWF"
		cQuery +=                                    " WHERE HWF.HWF_FILIAL = ?"
		cQuery +=                                      " AND HWF.HWF_PROG   = SMT.MT_PROG"
		cQuery +=                                      " AND HWF.HWF_RECURS = SMT.MT_RECURSO"
		cQuery +=                                      " AND HWF.HWF_CTRAB  = SMT.MT_CTRAB"
		cQuery +=                                      " AND HWF.HWF_DATA   >= ?"
		cQuery +=                                      " AND HWF.HWF_DATA   <= ?"
		cQuery +=                                      " AND HWF.D_E_L_E_T_ = ' ')"
		cQuery +=                    " ELSE 0 "
		cQuery +=                 " END efetProg, "
		cQuery +=                 " (SELECT COALESCE(Sum(HWK.HWK_TEMPOT), 0) "
		cQuery +=                    " FROM " + RetSqlName("HWK") + " HWK "
		cQuery +=                   " WHERE HWK.HWK_FILIAL = ? "
		cQuery +=                     " AND HWK.HWK_RECURS = SMT.MT_RECURSO "
		cQuery +=                     " AND HWK.HWK_CTRAB  = SMT.MT_CTRAB "
		cQuery +=                     " AND HWK.HWK_DATA  >= ? "
		cQuery +=                     " AND HWK.HWK_DATA  <= ? "
		cQuery +=                     " AND HWK.D_E_L_E_T_ = ' ') apontadas,"
		cQuery +=        " T4X.T4X_STATUS"
		cQuery +=   " FROM " + RetSqlName("SMT") + " SMT "
		cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
		cQuery +=     " ON SH1.H1_FILIAL  = ? "
		cQuery +=    " AND SH1.H1_CODIGO  = SMT.MT_RECURSO "
		cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT OUTER JOIN " + RetSqlName("SHB") + " SHB "
		cQuery +=    "  ON SHB.HB_FILIAL  = ? "
		cQuery +=    " AND SHB.HB_COD     = SMT.MT_CTRAB "
		cQuery +=    " AND SHB.D_E_L_E_T_ = ' ' "
		cQuery +=  " INNER JOIN " + RetSqlName("SMR") + " SMR "
		cQuery +=     " ON SMR.MR_FILIAL  = ?"
		cQuery +=    " AND SMR.MR_PROG    = SMT.MT_PROG "
		cQuery +=    " AND SMR.MR_TIPO    = ? "
		cQuery +=    " AND SMR.MR_RECURSO = SMT.MT_RECURSO "
		cQuery +=    " AND SMR.MR_DATDISP >= ? "
		cQuery +=    " AND SMR.MR_DATDISP <= ? "
		cQuery +=    " AND SMR.D_E_L_E_T_ = ' '"
		cQuery +=  " INNER JOIN " + RetSqlName("T4X") + " T4X"
		cQuery +=     " ON T4X.T4X_FILIAL = ?"
		cQuery +=    " AND T4X.T4X_PROG   = SMT.MT_PROG"
		cQuery +=    " AND T4X.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE SMT.MT_FILIAL  =  ? "
		cQuery +=    " AND SMT.MT_PROG    =  ? "
		cQuery +=    " AND SMT.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SMT.MT_CTRAB   =  ? "
		cQuery +=    " AND SMT.MT_RECURSO =  ? "
		cQuery +=  " GROUP BY SMT.MT_RECURSO, SH1.H1_DESCRI, SMT.MT_CTRAB, SHB.HB_NOME, T4X.T4X_STATUS, SMT.MT_PROG "
		cQuery +=  " ORDER BY SMT.MT_CTRAB, SMT.MT_RECURSO "

		_oDetRec := FwExecStatement():New(cQuery)
	EndIf

	oReturn["items"  ] := {}
	oReturn["hasNext"] := .F.

	_oDetRec:setString(nPosPar++, xFilial("SMF")) //MF_FILIAL
	_oDetRec:setString(nPosPar++, xFilial("SVM")) //VM_FILIAL

	_oDetRec:setDate(nPosPar++, dDataIni        ) //VM_DATA >=
	_oDetRec:setDate(nPosPar++, dDataFim        ) //VM_DATA <=

	_oDetRec:setString(nPosPar++, xFilial("HWF")) //HWF_FILIAL

	_oDetRec:setDate(nPosPar++, dDataIni        ) //HWF_DATA >=
	_oDetRec:setDate(nPosPar++, dDataFim        ) //HWF_DATA <=


	_oDetRec:setString(nPosPar++, xFilial("HWK")) //HWK_FILIAL

	_oDetRec:setDate(nPosPar++, dDataIni        ) //HWK_DATA >=
	_oDetRec:setDate(nPosPar++, dDataFim        ) //HWK_DATA <=

	_oDetRec:setString(nPosPar++, xFilial("SH1") ) //H1_FILIAL
	_oDetRec:setString(nPosPar++, xFilial("SHB") ) //HB_FILIAL
	_oDetRec:setString(nPosPar++, xFilial("SMR") ) //MR_FILIAL
	_oDetRec:setString(nPosPar++, MR_TIPO_RECURSO) //MR_TIPO

	_oDetRec:setDate(nPosPar++, dDataIni        ) //MR_DATDISP >=
	_oDetRec:setDate(nPosPar++, dDataFim        ) //MR_DATDISP <=

	_oDetRec:setString(nPosPar++, xFilial("T4X")) //T4X_FILIAL
	_oDetRec:setString(nPosPar++, xFilial("SMT")) //MT_FILIAL
	_oDetRec:setString(nPosPar++, cProg         ) //MT_PROG
	_oDetRec:setString(nPosPar++, cCodCT        ) //MT_CTRAB
	_oDetRec:setString(nPosPar++, cRecurso      ) //MT_RECURSO

	cAlias := _oDetRec:openAlias()

	If (cAlias)->(!EoF())
		oRecurso := JsonObject():New()

		oRecurso["recurso"         ] := (cAlias)->MT_RECURSO
		oRecurso["descricao"       ] := (cAlias)->H1_DESCRI
		oRecurso["centroDeTrabalho"] := cCodCt

		oRecurso["utilizacao"] := getUtiliza(cProg, dDataIni, dDataFim, {oRecurso["recurso"]}, cCodCT, (cAlias)->T4X_STATUS)
		montaHoras(@oRecurso["utilizacao"]  ,;
		           (cAlias)->disponibilidade,;
		           (cAlias)->efetivadas     ,;
		           (cAlias)->efetProg       ,;
		           (cAlias)->programada     ,;
		           (cAlias)->apontadas       )

		aAdd(oReturn["items"], oRecurso)
	EndIf
	(cAlias)->(dbCloseArea())

	If !Empty(oReturn["items"])
		aReturn[1] := .T.
		aReturn[2] := 200
	Else
		oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
	EndIf
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} tempoDisp
Realiza o calculo do tempo disponivel.
@type  Static Function
@author Lucas Fagundes
@since 05/07/2023
@version P12
@param 01 nCapacidad, Numérico, Horas Previstas (MR_TEMPOTO+MR_TEMPOEF).
@param 02 nUtilizada, Numérico, Horas Utilizada (SMR).
@param 03 nEfetiv   , Numérico, Horas Efetivadas (SMR + HWF da própria programação)
@return cDisp, Caracter, Horas Disponiveis
/*/
Static Function tempoDisp(nCapacidad, nUtilizada, nEfetiv)
	Local cDisp   := ""
	Local nDispon := 0

	Default nCapacidad := 0
	Default nUtilizada := 0
	Default nEfetiv    := 0

	nDispon := nCapacidad - nUtilizada - nEfetiv

	If nDispon >= 0
		cDisp := __Min2Hrs(nDispon, .T.)
	Else
		cDisp := "-" +  __Min2Hrs(-nDispon, .T.)
	EndIf

Return cDisp

/*/{Protheus.doc} GET CTS /api/pcp/v1/pcpa152uti/{programacao}/centrosDeTrabalho
Retorna os centro de trabalho de uma programação.
@type  WSMETHOD
@author Lucas Fagundes
@since 23/10/2023
@version P12
@param 01 programacao     , Caracter, Código da programação.
@param 02 Page            , Numerico, Página que será carregada.
@param 03 PageSize        , Numerico, Quantidade de registros por página.
@param 03 centroDeTrabalho, Caracter, Filtro de centros de trabalho.
@param 03 recurso         , Caracter, Filtro de recursos.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET CTS PATHPARAM Programacao QUERYPARAM Page, PageSize, centroDeTrabalho, recurso WSSERVICE PCPA152UTI
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152UTI"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getCTs(Self:programacao, Self:Page, Self:PageSize, Self:centroDeTrabalho, Self:recurso)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getCTs
Retorna os centro de trabalho de uma programação.

@type  Static Function
@author Lucas Fagundes
@since 23/10/2023
@version P12
@param 01 cProg    , Caracter, Código da programação.
@param 02 nPage    , Numerico, Página que será carregada.
@param 03 nPageSize, Numerico, Quantidade de registros por página.
@param 04 cCodCT   , Caracter, Filtro de centro de trabalho.
@param 05 cRecurso , Caracter, Filtro de recursos.
@return aReturn, Array, Array com a informações para retorno da API.
/*/
Static Function getCTs(cProg, nPage, nPageSize, cCodCT, cRecurso)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local nCont   := 0
	Local nStart  := 0
	Local oReturn := JsonObject():New()

	cQuery += " SELECT DISTINCT SMT.MT_CTRAB, SHB.HB_NOME "
	cQuery += "   FROM " + RetSqlName("SMT") + " SMT "
	cQuery += "   LEFT JOIN " + RetSqlName("SHB") + " SHB "
	cQuery += "     ON SHB.HB_COD = SMT.MT_CTRAB "
	cQuery += "    AND " + FwJoinFilial("SHB", "SMT", "SHB", "SMT", .T.)
	cQuery += "    AND SHB.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE SMT.MT_PROG = '" + cProg + "' "
	cQuery += "    AND SMT.D_E_L_E_T_ = ' ' "

	If !Empty(cCodCT)
		cQuery += " AND SMT.MT_CTRAB IN ('" + StrTran(cCodCT, ", ", "','") + "') "
	EndIf
	If !Empty(cRecurso)
		cQuery += " AND SMT.MT_RECURSO IN ('" + StrTran(cRecurso, ", ", "','") + "') "
	EndIf
	cQuery += " ORDER BY SMT.MT_CTRAB "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		nCont++

		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCont]["centroDeTrabalho"] := (cAlias)->MT_CTRAB
		oReturn["items"][nCont]["descricao"       ] := Iif(Empty((cAlias)->HB_NOME), STR0140, (cAlias)->HB_NOME) // "Centro de trabalho em branco"

		(cAlias)->(dbSkip())
		If nCont >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} sumDetCT
Soma os detalhes de horas programadas/efetivadas de cada CT.
@type  Static Function
@author Lucas Fagundes
@since 21/06/2024
@version P12
@param 01 oDet   , Object  , Json que irá somar os detalhes de cada CT
@param 02 cCT    , Caracter, Código do centro de trabalho.
@param 03 cDescCT, Caracter, Descrição do centro de trabalho.
@param 04 nHoras , Numerico, Horas que irá somar no centro de trabalho.
@param 05 nOpc   , Numerico, Opção que irá somar as horas (1- Horas programadas, 2- Horas efetivadas).
@return Nil
/*/
Static Function sumDetCT(oDet, cCT, cDescCT, nHoras, nOpc)

	If !oDet["centrosDeTrabalho"]:HasProperty(cCT)
		oDet["centrosDeTrabalho"][cCT] := JsonObject():New()
		oDet["centrosDeTrabalho"][cCT]["horasEfetivadas" ] := 0
		oDet["centrosDeTrabalho"][cCT]["horasProgramadas"] := 0
		oDet["centrosDeTrabalho"][cCT]["descricao"       ] := Iif(Empty(cDescCT), STR0140, cDescCT) // "Centro de trabalho em branco"
	EndIf

	If nOpc == 1
		oDet["centrosDeTrabalho"][cCT]["horasProgramadas"] += nHoras
	ElseIf nOpc == 2
		oDet["centrosDeTrabalho"][cCT]["horasEfetivadas"] += nHoras
	EndIf

Return Nil

/*/{Protheus.doc} P152UtiDef
Retorna o valor dos defines de indice da utilização.

@type  Function
@author Lucas Fagundes
@since 21/06/2024
@version P12
@param cDef, Caracter, Nome do define que irá retornar o valor.
@return nValue, Numerico, Valor do define.
/*/
Function P152UtiDef(cDef)
	Local nValue := 0

	Do Case
		Case cDef == "IND_CAPACIDADE"
			nValue := IND_CAPACIDADE
		Case cDef == "IND_DISPONIBILIDADE"
			nValue := IND_DISPONIBILIDADE
		Case cDef == "IND_EFETIVADAS"
			nValue := IND_EFETIVADAS
		Case cDef == "IND_PROGRAMADAS"
			nValue := IND_PROGRAMADAS
		Case cDef == "IND_APONTADAS"
			nValue := IND_APONTADAS
		Case cDef == "IND_SETUP"
			nValue := IND_SETUP
		Case cDef == "IND_SALDO"
			nValue := IND_SALDO
		Case cDef == "QTD_LINHAS_TIPO"
			nValue := QTD_LINHAS_TIPO
	EndCase

Return nValue


