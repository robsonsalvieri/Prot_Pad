#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSQry4080()
Query dos pendentes de apuração do eventos R-4080

@author Rafael de Paula Leme
@since 17/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function WSQry4080(cPerApu, aFil, aInfEUF, nPage, nSize, lAll)

Local cQuery     as Character
Local cQryTot    as Character
Local cAlias     as Character
Local cAliasTot  as Character
Local cBd        as Character
Local cFilsV4K   as Character
Local cDataIni   as Character
Local cDataFim   as Character
Local cCompC1H   as Character
Local nTotReg	 as Numeric
Local nV4KPRID40 as Numeric
Local nC1HCNPJ   as Numeric
Local lHasNext   as Logical

Default cPerApu := ""
Default aFil    := {}
Default aInfEUF := {}
Default nPage 	:= 1
Default nSize 	:= 20
Default lAll    := .F.

cQuery     := ""
cQryTot    := ""
cAlias	   := ""
cAliasTot  := ""
cBd        := Upper(AllTrim(TcGetDb()))
cFilsV4K   := TafRetFilC("V4K", aFil)
cDataIni   := cPerApu + "01"
cDataFim   := DtoS(LastDay(StoD(cDataIni)))
cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
nTotReg    := 0
nV4KPRID40 := TamSX3("V4K_PRID40")[1]
nC1HCNPJ   := TamSX3("C1H_CNPJ")[1]
lHasNext   := .F.

//Tratamento para paginação nos bancos não homologados
if TafBdVers() .and. nPage > 0 .and. nSize > 0
	
	cQuery += " SELECT LINE_NUMBER, FILIAL, CNPJ, NOME, VLD, VALLIQ, BASEIR, VALIR FROM ( "
	cQuery += " SELECT ROW_NUMBER() OVER ( "
	cQuery += " ORDER BY VLD, CNPJ "
	cQuery +="		) LINE_NUMBER  "
	cQuery += " ,FILIAL "
	cQuery += " ,CNPJ "
	cQuery += " ,NOME "
	cQuery += " ,VLD "
	cQuery += " ,VALLIQ "
	cQuery += " ,BASEIR "
	cQuery += " ,VALIR "
	cQuery += " FROM ( "
	
EndIf

cQuery += " SELECT TBGER.FILIAL FILIAL, TBGER.CNPJ CNPJ, TBGER.NOME NOME, "
cQuery += "	CASE WHEN (SELECT COUNT(V4K_PRID40) FROM " + RetSqlName("V4K") + " WHERE V4K_FILIAL = TBGER.FILIAL AND V4K_CGCFON = TBGER.CNPJ AND V4K_INDNAT = '1' AND "
cQuery += " V4K_DTPAG BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND "
cQuery += " V4K_PRID40 = '" + Space(nV4KPRID40) + "' AND "
cQuery += " D_E_L_E_T_ = ' ') > 0 THEN 'notValidated' ELSE 'validated' END VLD, "
cQuery += "	SUM(TBGER.VALLIQ) VALLIQ, "
cQuery += " SUM(TBGER.BASEIR) BASEIR, "
cQuery += " SUM(TBGER.VALIR)  VALIR "
cQuery += " FROM "
cQuery += " (SELECT V4K.V4K_FILIAL FILIAL, C1H.C1H_CNPJ CNPJ, C1H.C1H_NOME NOME, V4K.V4K_PRID40 PROCID, V4K.V4K_VLREAJ VALLIQ, V4K.V4K_BASEIR BASEIR, V4K.V4K_VLRIR VALIR "
cQuery += " FROM " + RetSqlName("V4K") + " V4K "

//-----JOIN C1H X V4K
cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
If cCompC1H == "EEE"
	cQuery += " C1H.C1H_FILIAL = V4K.V4K_FILIAL "
Else
	If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V4K.V4K_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
	ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQuery += " SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V4K.V4K_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
	Else
		cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf
cQuery += " AND C1H.C1H_ID     = V4K.V4K_IDPART "
cQuery += " AND C1H.C1H_CNPJ   <> '" + Space(nC1HCNPJ) + "' "
cQuery += " AND C1H.C1H_PPES   = '2' "
cQuery += " AND C1H.D_E_L_E_T_ = ' ' "

cQuery += "	WHERE "
cQuery += "	V4K.V4K_FILIAL IN " + cFilsV4K + " AND "
cQuery += "	V4K.V4K_INDNAT = '1' AND "
cQuery += "	V4K.V4K_DTPAG BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND "
cQuery += "	V4K.D_E_L_E_T_ = ' ' "
cQuery += "	) TBGER "
cQuery += " GROUP BY TBGER.FILIAL, TBGER.CNPJ, TBGER.NOME "

if TafBdVers() .and. nPage > 0 .and. nSize > 0
	cQuery += " ) TAB ) TMP "
endIf

If lAll .Or. (nPage > 0 .And. nSize > 0) //paginacao e contagem considerando os dados ja agrupados
	cAliasTot := GetNextAlias()
	cQryTot := " SELECT COUNT(TBTOT.FILIAL) QTDREG FROM  ( " + cQuery + " ) TBTOT "
	cQryTot := ChangeQuery(cQryTot)
	TCQuery cQryTot New Alias (cAliasTot)
	nTotReg := (cAliasTot)->QTDREG
	(cAliasTot)->(DBCloseArea())
	If lAll
		lHasNext := .F.
	Else
		lHasNext := Iif((nPage * nSize) >= nTotReg, .F., .T.)
	Endif

EndIf

if TafBdVers() .and. nPage > 0 .and. nSize > 0
	cQuery += " WHERE LINE_NUMBER BETWEEN " + cValToChar(((nPage-1)*nSize) +1) + " AND " + cValToChar(nSize*nPage)
Else
	cQuery += " ORDER BY 4,1,2 "
	If !lAll .And. nPage > 0 .And. nSize > 0
		cQuery += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nSize) + " ) ROWS "
		cQuery += " FETCH NEXT " + cValToChar(nSize) + " ROWS ONLY "
	EndIf
EndIf


cQuery := ChangeQuery(cQuery)
cAlias := GetNextAlias()
TCQuery cQuery New Alias (cAlias)

Return {cAlias, nTotReg, lHasNext}

//-------------------------------------------------------------------
/*/{Protheus.doc} WS0024080()
Monta Json de acordo com a query

@author Rafael de Paula Leme
@since 04/11/2022
@version 1.0
@return
/*/ 
//-------------------------------------------------------------------
Function WS0024080(aApurac, oEstruct, cPeriodo, cEvent, aFiliais, oValidationError)

Local cAlias     as Character
Local cStatus	 as Character
Local nTSintetic as Numeric
Local lhasNext   as Logical

Default aApurac          := {'',0,.F.}
Default oEstruct         := Nil
Default cPeriodo         := '' 
Default cEvent 	         := ''
Default aFiliais         := {}
Default oValidationError := Nil

cAlias     := aApurac[1]
lhasNext   := aApurac[3]
nTSintetic := 0
cStatus    := ""
cCNPJ      := ""
cNome      := ""

If oValidationError == Nil .Or. oValidationError["registryKey"] == Nil
	oValidationError := JsonObject():New()
	oValidationError["registryKey"] := {}
Endif

If !(cAlias)->(EOF())
	(cAlias)->(DbGoTop())
	While !(cAlias)->(EOF())

		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])
			
		cStatus := Iif(Lower(Alltrim((cAlias)->VLD))=="notvalidated","notValidated","validated")
		
		oEstruct["eventDetail"][nTSintetic]["status"]      := cStatus
		oEstruct["eventDetail"][nTSintetic]["branchId"]    := (cAlias)->FILIAL
		oEstruct["eventDetail"][nTSintetic]["numInsc"]     := (cAlias)->CNPJ
		oEstruct["eventDetail"][nTSintetic]["key"]		   := (cAlias)->CNPJ
		oEstruct["eventDetail"][nTSintetic]["fontName"]	   := AllTrim(EncodeUTF8((cAlias)->NOME))
		oEstruct["eventDetail"][nTSintetic]["liquidValue"] := (cAlias)->VALLIQ
		oEstruct["eventDetail"][nTSintetic]["irBaseValue"] := (cAlias)->BASEIR
		oEstruct["eventDetail"][nTSintetic]["irValue"]     := (cAlias)->VALIR
		oEstruct["eventDetail"][nTSintetic]["errors"]      := 'errors'
		
		If Len(oValidationError["registryKey"]) > 0 		
			oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"] := KeyError(oEstruct["eventDetail"][nTSintetic], oValidationError)
		EndIf		

		(cAlias)->(dbSkip())
	EndDo
Else
	aadd(oEstruct["eventDetail"],JsonObject():New())
	oEstruct["eventDetail"] := {}
Endif

oEstruct['hasNext'] := lhasNext

(cAlias)->(DBCloseArea())

Return oEstruct

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Query Invoice Detail (Segundo nível pendente apuração e relatório)

@author Wesley Matos
@since 18/08/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Function QryInv4080(cPerApu, aFil, aInfEUF, cInsc, cFilDoc)

Local cDataIni   As Character
Local cDataFim   As Character
Local cBd		 As Character
Local cQuery     As Character
Local cAlias     As Character

Default cPerApu  := ""
Default aFil     := {}
Default aInfEUF  := {}
Default cFilDoc  := cFilAnt

cQuery     := ""
cDataIni   := cPerApu + "01" //ex: 20220201
cDataFim   := DtoS( LastDay( StoD( cDataIni ) ) )
cAlias	   := ""
cBd		   := Upper(AllTrim(TcGetDb()))
cFilsV4K   := "('" + cFilDoc + "')"

cQuery += ' SELECT TBGER.NUMDOC NUMDOC'
cQuery += ' ,TBGER.NATREN NATREN'
cQuery += ' ,TBGER.DTPAGTO DTPAGTO'
cQuery += ' ,TBGER.VLRLIQ VLRLIQ'
cQuery += ' ,TBGER.BASEIR BASEIR'
cQuery += ' ,TBGER.VLRIR VLRIR'
cQuery += ' FROM ('

cQuery += ' SELECT V4K_CODDOC NUMDOC' 
cQuery += ' ,V3O.V3O_CODIGO NATREN'
cQuery += '	,V4K_DTPAG DTPAGTO'
cQuery += '	,V4K_VLREAJ VLRLIQ'
cQuery += '	,V4K_BASEIR BASEIR'
cQuery +=  ',V4K_VLRIR VLRIR'
cQuery += " FROM " + RetSqlName("V4K") + " V4K "

cQuery += " LEFT JOIN " + RetSqlName("V3O") + " V3O ON V3O.V3O_ID = V4K.V4K_IDNATR AND V3O.V3O_FILIAL = '" + xFilial("V3O") + "' AND V3O.D_E_L_E_T_ = ' ' "

cQuery += "	WHERE "
cQuery += "	V4K.V4K_FILIAL IN " + cFilsV4K + " AND "
cQuery += "	V4K.V4K_INDNAT = '1' AND "
cQuery += "	V4K.V4K_DTPAG BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND "
cQuery += " V4K.V4K_CGCFON = " + cInsc + " AND"
cQuery += "	V4K.D_E_L_E_T_ = ' ' "
cQuery += "	) TBGER "
cQuery += " GROUP BY TBGER.NUMDOC, TBGER.DTPAGTO, TBGER.NATREN, TBGER.VLRLIQ, TBGER.BASEIR, TBGER.VLRIR "

If !("DB2" $ cBd )
	cQuery := ChangeQuery( cQuery )
EndIf

cAlias := GetNextAlias()
TCQuery cQuery New Alias (cAlias)

return {cAlias}


//-------------------------------------------------------------------
/*/{Protheus.doc} WS002D4080

@description Monta a mensagem JON de retorno referente ao invoice detail
@author Wesley Matos
@since 21/08/2023
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function WS002D4080(aApurac, oEstruct)

	Local nTotInv as Numeric

	nTotInv := 0

    while !(aApurac[1])->(eof())

        aAdd( oEstruct["invoices"],JsonObject():New())
        nTotInv   :=  len(oEstruct["invoices"])

        //Tipo
        oEstruct["invoices"][nTotInv]["document"]      := (aApurac[1])->NUMDOC

        //Documento
        oEstruct["invoices"][nTotInv]["natureIncome"]  := (aApurac[1])->NATREN

        //Série
        oEstruct["invoices"][nTotInv]["date"]   	   := StoD((aApurac[1])->DTPAGTO)

        //Valor Bruto
        oEstruct["invoices"][nTotInv]["netValue"]      := (aApurac[1])->VLRLIQ

        //Base Imposto (IR)
        oEstruct["invoices"][nTotInv]["taxBase"]       := (aApurac[1])->BASEIR

		//Valor Imposto (IR)
		oEstruct["invoices"][nTotInv]["taxAmount"]     := (aApurac[1])->VLRIR

        (aApurac[1])->(dbSkip())
    endDo

Return oEstruct


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Denis Souza /Jose Felipe
@since 04/11/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oEstruct, oValidationError)

Local cKeyError as Character
Local nX        as Numeric

cKeyError := ""
nX        := 1

For nX := 1 to Len(oValidationError["registryKey"])
	if alltrim(oValidationError["registryKey"][nX]["branchId"]) == alltrim(oEstruct["branchId"])
		if alltrim(oValidationError["registryKey"][nX]["id"]) == alltrim(oEstruct["key"])
			cKeyError := oValidationError["registryKey"][nX]["error"]
		endif
	endif
Next nX

Return (cKeyError)
