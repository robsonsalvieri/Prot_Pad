
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU09R01.CH"

#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"
#DEFINE SEPARATOR_ARRAY_INTERVAL_SYMBOL "-"


/*/{Protheus.doc} RU09R01 - Purchases_book
	Entry point to run the routine.

@type function
@author eprokhorenko
@version 
@since 28/11/2023
@param  
@return NIL
/*/
Function RU09R01()  

//https://jiraproducao.totvs.com.br/browse/RULOC-5194
//FI-VAT-31-18 Purchases book

//https://jiraproducao.totvs.com.br/browse/RULOC-5544
//Develop a printable form of a purchase ledger in Excel with traceability

Local lResult 	As Logical
Local lRes		As Logical
Local aFilters 	As Array

aFilters := {}
lResult :=	Pergunte("RU09R0201", .T.)

If lResult
	//1 - Report format 
	Aadd(aFilters, MV_PAR01) 
	If aFilters[1] == 1
		lRes := Pergunte("RU09R0102", .T.)
		If lRes
	//2 - Date from
			Aadd(aFilters, MV_PAR01) 
	//3 - Date to 
			Aadd(aFilters, MV_PAR02) 
	//4 - Head of the company
			Aadd(aFilters, MV_PAR03) 
	//5 - Branches
			Aadd(aFilters, "")
	//6 - Supplier's code 
			Aadd(aFilters, "")
	//7 - Supplier's unit
			Aadd(aFilters, "") 
			
			GetDataPrBook(aFilters)
		EndIf
	Else
		lRes := Pergunte("RU09R01PER", .T.)
		If lRes
	//2 - Date from
			Aadd(aFilters, MV_PAR01) 
	//3 - Date to 
			Aadd(aFilters, MV_PAR02) 
	//4 - Head of the company
			Aadd(aFilters, MV_PAR03) 
	//5 - Branches
			Aadd(aFilters, MV_PAR04) 
	//6 - Supplier's code 
			Aadd(aFilters, AllTrim(MV_PAR05)) 
	//7 - Supplier's unit
			Aadd(aFilters, AllTrim(MV_PAR06)) 

			GetDataPrBook(aFilters)
		EndIf
	EndIf
EndIf

Return .T.

/*/
{Protheus.doc} GetDataPrBook()
    Create arrays aHeaders, aTables, aFooter for purchases book
    @type Function
    @params aFilter, Array - filters
    @author eprokhorenko
    @since 28/11/2023
    @version 
    @return 
    @example GetDataPrBook(aFilters)
/*/

Static Function GetDataPrBook(aFilters)

Local aArea             As Array
Local cQuery            As Character
Local cAliasTMP         As Character
Local cComPar           As Character
Local nCountStr         As Numeric
Local aHeaders := {}    As Array
Local aFooter  := {}    As Array
Local aTables  := {}    As Array 
Local cINN_KPP := ""	As Character
Local cCompanyName:= ""	As Character
Local nTotal 			As Numeric
Local nFormReport		As Numeric
Local cDateFrom			As Character
Local cDateTo			As Character
Local cSuppliersCode:= "" As Character
Local nX				As Numeric
Local cFilterSup		As Character
Local cFilterUnit		As Character
Local cFiltrFil			As Character
Local aTransfArr  := {}	As Array 
Local cBranches	  := ""	As Character
Local cFilialName := ""	As Character
Local cFilINN_KPP		As Character
Local nCountFil			As Numeric
Local aAreaSB			As Array
Local cNotFil			As Character
Local aListFl := {}     As Character
Local cKeyF3C := ""     As Character
Local aBlock_tmp        As Character
Local aCompanyInfo:= {} As Array
Local aBranchInfo := {} As Array
Local aAreaCTO			As Array
Local aAreaSa2			As Array
Local cFilCodeOfList:="" As Character

	cNotFil := STUFF(cNumemp, 1, Len(cEmpant)+Len(FWCompany())+Len(FWUnitBusiness()), "")

    cComPar     := Alltrim(SuperGetMv("MV_CMPLVL",.F.,""))

  	nFormReport	 := aFilters[1] 
	cDateFrom    := RU09R01005_FormatDate(aFilters[2])
    cDateTo      := RU09R01005_FormatDate(aFilters[3])

	//Formatting Branches
	If !Empty(aFilters[5]) .AND. nFormReport == 2
		aTransfArr := StrTokArr(aFilters[5], SEPARATOR_ARRAY_VALUES_SYMBOL)
		For nX := 1 To Len(aTransfArr)
			If !Empty(aTransfArr[nX])
				cBranches += aTransfArr[nX]
					If(nX!=Len(aTransfArr))
						cBranches += ", "
					EndIf
				Aadd(aListFl, aTransfArr[nX])
			EndIf
		Next
		If Len(aListFl) == 1
			aListFl := StrTokArr(aListFl[1], SEPARATOR_ARRAY_INTERVAL_SYMBOL)
			nCountFil := Iif(Len(aListFl) == 1, 1, 0)
		Else
			nCountFil := 0
		EndIf
		cFiltrFil := RU09R01006_TransformArray(aTransfArr, 3)// Create the filter for an SQL query (Branches)
	Else
		cFiltrFil := ""
	EndIf

	//Formatting Suppliers Codes
	If !Empty(aFilters[6]) .AND. nFormReport == 2
		aTransfArr := StrTokArr(aFilters[6], SEPARATOR_ARRAY_VALUES_SYMBOL)
		For nX := 1 To Len(aTransfArr)
			cSuppliersCode += aTransfArr[nX]
			If(nX!=Len(aTransfArr))
				cSuppliersCode += ", "
			EndIf
		Next
		cFilterSup := RU09R01006_TransformArray(aTransfArr, 1)// Create the filter for an SQL query (Suppliers Codes)
	Else
		cFilterSup := ""
	EndIF

		//Formatting Supplier's unit
	If !Empty(aFilters[7]) .AND. nFormReport == 2
		aTransfArr := StrTokArr(aFilters[7], SEPARATOR_ARRAY_VALUES_SYMBOL)
		cFilterUnit := RU09R01006_TransformArray(aTransfArr, 2)// Create the filter for an SQL query (Supplier's unit)
	Else
		cFilterUnit := ""
	EndIF
	
    // Create data aHeaders
    DO CASE 
    
        CASE cValToChar(VAL(cComPar)-1) == '2' // Buisness unit.
            aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            cCompanyName := aCompanyInfo[1]
            cINN_KPP     := aCompanyInfo[2] + IIF(aCompanyInfo[4] == "2","/" + aCompanyInfo[3],"")
        CASE cValToChar(VAL(cComPar)-1) == '1' // Company.
            aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'1', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            cCompanyName := aCompanyInfo[1]
            cINN_KPP     := aCompanyInfo[2] + IIF(aCompanyInfo[4] == "2","/" + aCompanyInfo[3],"")
        CASE cValToChar(VAL(cComPar)-1) == '0' // Group company.
            aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'0', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            cCompanyName := aCompanyInfo[1]
            cINN_KPP     := aCompanyInfo[2] + IIF(aCompanyInfo[4] == "2","/" + aCompanyInfo[3],"")
    ENDCASE

    If nFormReport == 1
        aAdd(aHeaders, cCompanyName	 )
        aAdd(aHeaders, cINN_KPP		 )
    EndIf
	
    If nFormReport == 2 .AND. !Empty(aFilters[5])
        If nCountFil == 1
			cFilCodeOfList := STUFF(aListFl[1], 1, Len(FWCompany())+ Len(FWUnitBusiness()), "") 
            aBranchInfo  := StaticCall(RU05R06,RU05R06002_GetBranchInfo,FWGrpCompany(),FWCompany(), FWUnitBusiness(), cFilCodeOfList)
            cFilialName    := aBranchInfo[3]
            cFilINN_KPP    := aCompanyInfo[2] + "/"+  aBranchInfo[2]
            aAdd(aHeaders, cFilialName	 )
			aAdd(aHeaders, cFilINN_KPP	 )
        Else
            aAdd(aHeaders, cBranches	 )
			aAdd(aHeaders, " "	 		 )
        EndIf
    ElseIf nFormReport == 2 .AND. Empty(aFilters[5])
        aAdd(aHeaders, cCompanyName	 )
        aAdd(aHeaders, cINN_KPP		 )
    EndIf
    
    aAdd(aHeaders, cDateFrom	 )
    aAdd(aHeaders, cDateTo		 )
	If nFormReport == 2 .AND. !Empty(aFilters[6])
		aAdd(aHeaders, cSuppliersCode)
	EndIf

	aArea := getArea()
    
	cQuery := " SELECT F.F37_FILIAL, FC.F3C_CODE, FC.F3C_BOOKEY, FC.F3C_KEY, FC.F3C_DOC, FC.F3C_PDATE, SUM(FC.F3C_VALUE) AS SUM_F3C_VALUE, F.F37_INVDT, F.F37_BRANCH,"
	cQuery += " F.F37_FORNEC, F.F37_KPP_SP, F.F37_VALGR, F.F37_INVCUR, F.F37_VATCD2  "
    //, F38.F38_ENRNT, F38.F38_ITMCOD, F38.F38_QUANT, F38.F38_RNPTCO, F38.F38_ITEM
	cQuery += " FROM " + RetSqlName("F3C") + " AS FC"

	cQuery += " INNER JOIN " + RetSqlName("F37") + " AS F"
	cQuery += " ON FC.F3C_DOC = F.F37_DOC"
    cQuery += " AND FC.F3C_PDATE = F.F37_PDATE"
	cQuery += " AND FC.F3C_KEY = F.F37_KEY"
	cQuery += " AND FC.F3C_FILIAL = F.F37_FILIAL"
	cQuery += " AND FC.D_E_L_E_T_ = F.D_E_L_E_T_"

	cQuery += " INNER JOIN " + RetSqlName("F3B") + " AS FB"
	cQuery += " ON FC.F3C_BOOKEY = FB.F3B_BOOKEY"
	cQuery += " AND FC.D_E_L_E_T_ = FB.D_E_L_E_T_"

	// cQuery += " INNER JOIN " + RetSqlName("F38") + " AS F38"
	// cQuery += " ON F.F37_FILIAL = F38.F38_FILIAL"
    // cQuery += " AND F.F37_KEY = F38.F38_KEY"
	// cQuery += " AND F.D_E_L_E_T_ = F38.D_E_L_E_T_"

	cQuery += " WHERE FC.F3C_ADSHNR = '0' "
	If nFormReport == 2
		cQuery += cFiltrFil
		cQuery += cFilterSup
		cQuery += cFilterUnit
	EndIf
	cQuery += " AND FB.F3B_FINAL >= " + "'" + DToS(aFilters[2]) + "' AND FB.F3B_FINAL <='" + DToS(aFilters[3]) + "'"
	cQuery += " AND FC.D_E_L_E_T_ = ' '"
    cQuery += " GROUP BY F.F37_FILIAL, FC.F3C_CODE, FC.F3C_BOOKEY, FC.F3C_KEY, FC.F3C_DOC, FC.F3C_PDATE, F.F37_INVDT, F.F37_BRANCH,"
    cQuery += " F.F37_FORNEC, F.F37_KPP_SP, F.F37_VALGR, F.F37_INVCUR, F.F37_VATCD2 "
    //, F38.F38_ENRNT, F38.F38_ITMCOD, F38.F38_QUANT, F38.F38_RNPTCO, F38.F38_ITEM
	cQuery += " ORDER BY FC.F3C_PDATE ASC, FC.F3C_KEY ASC, FC.F3C_DOC ASC "
    //, F38.F38_ENRNT DESC
	cQuery      := ChangeQuery(cQuery)
	cAliasTMP   := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
	DbSelectArea(cAliasTMP)

    nCountStr := 0
	nTotal	  := 0

    (cAliasTMP)->(dbGotop())
    While (cAliasTMP)->(!EOF())
        
        //Create data block_tmp
        aBlock_tmp := {}

		If(cKeyF3C !=  (cAliasTMP)->F37_FILIAL + (cAliasTMP)->F3C_DOC + (cAliasTMP)->F3C_PDATE + (cAliasTMP)->F3C_KEY)
		  //.OR. !EMPTY((cAliasTMP)->F38_ENRNT))
		
			If(cKeyF3C !=  (cAliasTMP)->F37_FILIAL + (cAliasTMP)->F3C_DOC + (cAliasTMP)->F3C_PDATE + (cAliasTMP)->F3C_KEY)
		//1 - Item number, auto incrementation 
				aAdd(aBlock_tmp, nCountStr += 1)
				nTotal += (cAliasTMP)->SUM_F3C_VALUE
			Else
				aAdd(aBlock_tmp, nCountStr)
			EndIf
		
		//2 - Code of the type of operation 
			aAdd(aBlock_tmp, AllTrim((cAliasTMP)->F37_VATCD2  ))
		//3 - VAT invoice number and date F3C_DOC and F3C_PDATE, separated by a semicolon ";"
			aAdd(aBlock_tmp, AllTrim((cAliasTMP)->F3C_DOC) + "; " + RU09R01005_FormatDate(STOD(AllTrim((cAliasTMP)->F3C_PDATE)))) 
		//4 - Acquisition date F37_ INVDT
			aAdd(aBlock_tmp, STOD(AllTrim((cAliasTMP)->F37_INVDT))) 
		//5 - Supplier's short name A2_NREDUZ
		aAreaSa2 := SA2->(GetArea())
			DbSelectArea("SA2")
			dbSetOrder(1)
			If (dbseek(XFilial("SA2")+(cAliasTMP)->F37_FORNEC +(cAliasTMP)->F37_BRANCH))
				aAdd(aBlock_tmp, AllTrim(SA2->A2_NREDUZ))
			Else
				aAdd(aBlock_tmp, "No Supplier")
			EndIf 
			cSupplier  := XFilial("SA2")+(cAliasTMP)->F37_FORNEC + (cAliasTMP)->F37_BRANCH
		//6 - INN code from supplier's card A2_CODZON; KPP code from A2_KPP separated by slash "/".
			aAdd(aBlock_tmp, AllTrim(Posicione("SA2", 1, cSupplier, "A2_CODZON")) + "/"+ AllTrim(Posicione("SA2", 1, cSupplier, "A2_KPP")))
		RestArea(aAreaSa2)
		//7 - Currency F37_INVCUR
		//Should be filled only if currency is different from 01 (not ruble)
			If((cAliasTMP)->F37_INVCUR != "01")
				aAreaCTO := CTO->(GetArea())
					aAdd(aBlock_tmp, AllTrim(Posicione("CTO",1,xFilial("CTO")+AllTrim((cAliasTMP)->F37_INVCUR),"CTO_RDESC")) + ", ";
								+ AllTrim(Posicione("CTO",1,xFilial("CTO")+AllTrim((cAliasTMP)->F37_INVCUR),"CTO_CODISO"))) 
				RestArea(aAreaCTO)
			Else
				aAdd(aBlock_tmp, "")
			EndIf
		//8 - Gross value for VAT invoice in VAT invoice 
			aAdd(aBlock_tmp, (cAliasTMP)->F37_VALGR) 
		//9 - VAT amount for VAT invoice. Total sum of F3C_ VALUE for all the lines referring to the same VAT invoice
			aAdd(aBlock_tmp, (cAliasTMP)->SUM_F3C_VALUE)   

		// 	If(!Empty((cAliasTMP)->F38_ENRNT))
		// //10 - External Number     
		// 		aAdd(aBlock_tmp, (cAliasTMP)->F38_ENRNT	)
		// //11 - Unit of measure 
		// 		aAreaSB := getArea()
		// 		aAdd(aBlock_tmp, Posicione("SAH",1,xFilial("SAH")+(Posicione("SB1",1,xFilial("SB1")+(cAliasTMP)->F38_ITMCOD,"B1_UM")),"AH_CODOKEI")) 
		// 		RestArea(aAreaSB)
		// //12 - Quantity
		// 		aAdd(aBlock_tmp, (cAliasTMP)->F38_QUANT)
		// //13 - Cost of RNPT          
		// 		aAdd(aBlock_tmp, (cAliasTMP)->F38_RNPTCO)
		// 	Else
		//10 - External Number     
				aAdd(aBlock_tmp, ""	)
		//11 - Unit of measure 
				aAdd(aBlock_tmp, ""	)
		//12 - Quantity
				aAdd(aBlock_tmp, ""	)
		//13 - Cost of RNPT          
				aAdd(aBlock_tmp, ""	)
			// EndIF
		
			cKeyF3C := (cAliasTMP)->F37_FILIAL + (cAliasTMP)->F3C_DOC + (cAliasTMP)->F3C_PDATE + (cAliasTMP)->F3C_KEY
			aAdd(aTables, aClone(aBlock_tmp))
		EndIf
		
		(cAliasTMP)->(dbSkip())		
    EndDo
    (cAliasTMP)->(dbCloseArea())
    RestArea(aArea)
	
	//1 - Total all book (sum F3C_VALUE)
	aAdd(aFooter, nTotal) 
	//2 - - Head of the company
	If !Empty(aFilters[4])
		aArea := getArea()
			aAdd(aFooter, Posicione("F42",1,xFilial("F42")+ aFilters[4],"F42_NAME"))
		RestArea(aArea)
	EndIf

	//3 - if the company is an individual entrepreneur 
	If (Len(aCompanyInfo) > 3 .AND. aCompanyInfo[4] == "1")//CO_TYPE
		aAdd(aFooter, IIF(Len(aCompanyInfo) > 4, aCompanyInfo[5], ""))
	Else
		aAdd(aFooter, "")
	EndIf
    RU09R01001(aHeaders, aTables, aFooter)

Return .T. 

/*/{Protheus.doc} RU09R01001
  Draw report Purchase book with needed parameters

@type function
@author eprokhorenko
@version 2210
@param  aHeaders as Array for filling header of report
		aTables as Array of Arrays, every line of aTables is line of report's table part
		aFooter as Array for table bottom and footer of report
@return NIL
/*/

Static Function RU09R01001(aHeaders, aTables, aFooter)

Local oPrtXlsx  	:= FwPrinterXlsx():New(.T.)
Local cPath := ""	As Character
Local cFile := ""	As Character
Local nPp			As Numeric
Local nX 			As Numeric
Local nCntR := 10	As Numeric
Local nCntC			As Numeric
Local nSavePos		As Numeric
Local lHtml         := (GetRemoteType() == 5) //Checks if the environment is SmartClientHtml

DEFAULT aHeaders := {"", "", "", "", ""}
DEFAULT aTables := {{"", "", "", "", "", "", "", "", "", "", "", "", ""}}
DEFAULT aFooter := {"", "", "", ""}

cPATH_TITLE := STR0040 //Select folder for save
cPath := cGetFile(, cPATH_TITLE, 0, "", .F., nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE, 128, 256),.T., .T. ) 
If (Empty(cPath))
	If !isblind() 
		MSGINFO(STR0040 ) //Select folder
	EndIf
ElseIf(cPath == "C:\")
	If !isblind()
		MSGINFO(STR0041 ) //Don't select the root directory, for example 'C:\'
	EndIf
EndIf

If (!Empty(cPath) .AND. !(cPath == "C:\"))
	cFile:= cPath + "purchases_book_" + FwTimeStamp(1)
	// Create excel report
	oPrtXlsx:Activate(cFile)
	oPrtXlsx:AddSheet("Sheet1")
	RU09R01002_SetColumnWidth(@oPrtXlsx)
	
	// Form name
	RU09R01004_SetFontStyle(@oPrtXlsx, "FormName")
	oPrtXlsx:MergeCells(1, 1, 1, 15)
	oPrtXlsx:setText(1, 1, STR0001+Chr(13)+Chr(10) + STR0002)
	
	//Title - Purchases book
	RU09R01004_SetFontStyle(@oPrtXlsx, "Title")
	oPrtXlsx:MergeCells(2, 1, 2, 15)
	oPrtXlsx:setText(2, 1, STR0003)
	
	//Empty string
	oPrtXlsx:setText(3, 1, "")
	
	//Header
	RU09R01004_SetFontStyle(@oPrtXlsx, "Header")
	oPrtXlsx:MergeCells(4, 1, 4, 9)
	oPrtXlsx:setText(4, 1, STR0024 + IIF( LEN(aHeaders) > 0, " " + aHeaders[1], "" ))
	
	oPrtXlsx:MergeCells(5, 1, 5, 9)
	oPrtXlsx:setText(5, 1, STR0025 + IIF( LEN(aHeaders) > 1, " " + aHeaders[2], "" ))
	oPrtXlsx:MergeCells(6, 1, 6, 9)
	oPrtXlsx:setText(6, 1, STR0026 + IIF( LEN(aHeaders) > 3, " " + aHeaders[3] + " " + STR0032 + " " + aHeaders[4], "" ))
	
	//Suppliers - If report is filled in a flexible form 
	oPrtXlsx:MergeCells(7, 1, 7, 9)
	oPrtXlsx:setText(7, 1, IIF( LEN(aHeaders) > 4, STR0034 + " " + aHeaders[5], "" ))
	
	//Header Table
	oPrtXlsx:SetRowsHeight(8, 8, 120.00)
	oPrtXlsx:SetRowsHeight(9, 9, 39.75)
	RU09R01004_SetFontStyle(@oPrtXlsx, "HeaderTable")
	oPrtXlsx:MergeCells(8, 1, 9, 1)
	oPrtXlsx:setText(8, 1, STR0004)
	oPrtXlsx:MergeCells(8, 2, 9, 2)
	oPrtXlsx:setText(8, 2, STR0005)
	oPrtXlsx:MergeCells(8, 3, 9, 3)
	oPrtXlsx:setText(8, 3, STR0006)
	oPrtXlsx:MergeCells(8, 4, 9, 4)
	oPrtXlsx:setText(8, 4, STR0007)
	oPrtXlsx:MergeCells(8, 5, 9, 5)
	oPrtXlsx:setText(8, 5, STR0008)
	oPrtXlsx:MergeCells(8, 6, 9, 6)
	oPrtXlsx:setText(8, 6, STR0009)
	oPrtXlsx:MergeCells(8, 7, 9, 7)
	oPrtXlsx:setText(8, 7, STR0010)
	oPrtXlsx:MergeCells(8, 8, 9, 8)
	oPrtXlsx:setText(8, 8, STR0011)
	oPrtXlsx:MergeCells(8, 9, 9, 9)
	oPrtXlsx:setText(8, 9, STR0012)
	oPrtXlsx:MergeCells(8, 10, 9, 10)
	oPrtXlsx:setText(8, 10, STR0013)
	oPrtXlsx:MergeCells(8, 11, 8, 12)
	oPrtXlsx:setText(8, 11, STR0014)
	oPrtXlsx:setText(9, 11, STR0015)
	oPrtXlsx:setText(9, 12, STR0016)
	oPrtXlsx:MergeCells(8, 13, 9, 13)
	oPrtXlsx:setText(8, 13, STR0017)
	oPrtXlsx:MergeCells(8, 14, 9, 14)
	oPrtXlsx:setText(8, 14, STR0018)
	oPrtXlsx:MergeCells(8, 15, 9, 15)
	oPrtXlsx:setText(8, 15, STR0019)
	oPrtXlsx:MergeCells(8, 16, 9, 16)
	oPrtXlsx:setText(8, 16, STR0020)
	oPrtXlsx:MergeCells(8, 17, 9, 17)
	oPrtXlsx:setText(8, 17, STR0021)
	oPrtXlsx:MergeCells(8, 18, 9, 18)
	oPrtXlsx:setText(8, 18, STR0022)
	oPrtXlsx:MergeCells(8, 19, 9, 19)
	oPrtXlsx:setText(8, 19, STR0023)
	oPrtXlsx:SetRowsHeight(10, 10, 11.25)

	For nPp := 1 To 19
		oPrtXlsx:setValue(10, nPp, nPp)
	Next

	RU09R01004_SetFontStyle(@oPrtXlsx, "Table")
	nSavePos := 1

	For nPp := 1 To Len(aTables)
	//Merge cells if number of identical cells > 1
		If nPp<> 1
			if aTables[nPp][1] <> aTables[nPp-1][1] 
				if nSavePos <> nPp-1
					For nX := 1 To 15
						oPrtXlsx:MergeCells( nSavePos+10,nX,nPp+10-1,nX)
					Next
				EndIf
				nSavePos := nPp
			EndIf
			If nPp == LEN(aTables)
				if nSavePos <> nPp
					For nX := 1 To 15
						oPrtXlsx:MergeCells( nSavePos+10,nX,nPp+10,nX)
					Next
				EndIf
			EndIf
		EndIf
		nCntR += 1
		nCntC := 1
		//1 - Item number, auto incrementation 
		RU09R01003_SetCellsFormat(@oPrtXlsx, "C", "Table") 
		oPrtXlsx:setNumber(nCntR, nCntC++, IIF(Len(aTables[nPp]) > 0, aTables[nPp][1], ""))
		//2 - Code of the type of operation
		oPrtXlsx:setText(nCntR, nCntC++, IIF(Len(aTables[nPp]) > 1, aTables[nPp][2], ""))
		//3 - VAT invoice number and date F3C_DOC and F3C_PDATE, separated by a semicolon ";"
		oPrtXlsx:setText(nCntR, nCntC++, IIF(Len(aTables[nPp]) > 2, aTables[nPp][3], ""))
		//4 
		oPrtXlsx:setText(nCntR, nCntC++,"")
		//5
		oPrtXlsx:setText(nCntR, nCntC++,"")
		//6
		oPrtXlsx:setText(nCntR, nCntC++,"")
		//7
		oPrtXlsx:setText(nCntR, nCntC++,"")
		If(Len(aTables[nPp]) > 3 .AND. !Empty(aTables[nPp][4]))
		//8 - Acquisition date F37_ INVDT
			RU09R01003_SetCellsFormat(@oPrtXlsx, ValType(aTables[nPp][4]), "Table")
			oPrtXlsx:setDate(nCntR, nCntC++, aTables[nPp][4])
		Else
		//8 - Acquisition date F37_ INVDT
			oPrtXlsx:setText(nCntR, nCntC++,"")
		EndIf
		//9 - Supplier's short name A2_NREDUZ
		RU09R01003_SetCellsFormat(@oPrtXlsx, ValType(aTables[nPp][5]), "TableTextWrap")
		oPrtXlsx:setText(nCntR, nCntC++, IIF(Len(aTables[nPp]) > 4, aTables[nPp][5], ""))
		//10 - INN code from supplier's card A2_CODZON; KPP code from A2_KPP separated by slash "/".
		oPrtXlsx:setText(nCntR, nCntC++, IIF(Len(aTables[nPp]) > 5,aTables[nPp][6], ""))
		//11 
		oPrtXlsx:setText(nCntR, nCntC++,"")
		//12 
		oPrtXlsx:setText(nCntR, nCntC++,"")
		//13 - Currency F37_INVCUR
		//Should be filled only if currency is different from 01 (not ruble)
		oPrtXlsx:setText(nCntR, nCntC++, IIF(Len(aTables[nPp]) > 6, aTables[nPp][7], ""))
		If(Len(aTables[nPp]) > 7 .AND. !Empty(aTables[nPp][8]))
		//14 - Gross value for VAT invoice in VAT invoice 
			RU09R01003_SetCellsFormat(@oPrtXlsx, ValType(aTables[nPp][8]), "Table")
			oPrtXlsx:setValue(nCntR, nCntC++, aTables[nPp][8])
		Else
		//14 - Gross value for VAT invoice in VAT invoice 
			oPrtXlsx:setText(nCntR, nCntC++, "")
		EndIf
		If(Len(aTables[nPp]) > 8 .AND. !Empty(aTables[nPp][9]))
		//15 - VAT amount for VAT invoice. Total sum of F3C_ VALUE for all the lines referring to the same VAT invoice
			RU09R01003_SetCellsFormat(@oPrtXlsx, ValType(aTables[nPp][9]), "Table")
			oPrtXlsx:setValue(nCntR, nCntC++, aTables[nPp][9])
		Else
		//15 - VAT amount for VAT invoice. Total sum of F3C_ VALUE for all the lines referring to the same VAT invoice
			oPrtXlsx:setText(nCntR, nCntC++, "")
		EndIf
		
		//16 - External Number
		RU09R01003_SetCellsFormat(@oPrtXlsx, ValType(aTables[nPp][9]), "Table")
		oPrtXlsx:setText(nCntR, nCntC++, IIF(Len(aTables[nPp]) > 9, aTables[nPp][10], ""))
		//17 - Unit of measure 
		RU09R01003_SetCellsFormat(@oPrtXlsx, ValType(aTables[nPp][11]), "Table")
		oPrtXlsx:setText(nCntR, nCntC++, IIF(Len(aTables[nPp]) > 10, aTables[nPp][11], ""))
		If(Len(aTables[nPp]) > 11 .AND. !Empty(aTables[nPp][12]))
		//18 - Quantity
			RU09R01003_SetCellsFormat(@oPrtXlsx, ValType(aTables[nPp][12]), "Table")
			oPrtXlsx:setValue(nCntR, nCntC++, aTables[nPp][12])
		Else
		//18 - Quantity
			oPrtXlsx:setText(nCntR, nCntC++, "")
		EndIf
		If(Len(aTables[nPp]) > 12 .AND. !Empty(aTables[nPp][13]))
		//19 - Cost of RNPT 
			RU09R01003_SetCellsFormat(@oPrtXlsx, ValType(aTables[nPp][13]), "Table")
			oPrtXlsx:setValue(nCntR, nCntC++, aTables[nPp][13])
		Else
		//19 - Cost of RNPT 
			oPrtXlsx:setText(nCntR, nCntC++, "")
		EndIf
	Next
	nCntR++ //go to new line
	RU09R01004_SetFontStyle(@oPrtXlsx, "HeaderTable")
	RU09R01003_SetCellsFormat(@oPrtXlsx, "C", "FormName")
	oPrtXlsx:MergeCells(nCntR, 1, nCntR, 14)
	oPrtXlsx:setText(nCntR, 1, STR0031)
	RU09R01004_SetFontStyle(@oPrtXlsx, "Table")
	RU09R01003_SetCellsFormat(@oPrtXlsx, ValType(aFooter[1]), "")
	oPrtXlsx:setValue(nCntR, 15, IIF(LEN(aFooter) > 0, aFooter[1], ""))
	
	RU09R01003_SetCellsFormat(@oPrtXlsx, "C", "Table")
	For nX := 16 To 19
		oPrtXlsx:setText(nCntR, nX, "")
	Next

	nCntR+= 3 //go to new line (twice)
	RU09R01004_SetFontStyle(@oPrtXlsx, "Header")
	oPrtXlsx:MergeCells(nCntR, 1, nCntR, 5)
	oPrtXlsx:setText(nCntR, 1, STR0027)
	RU09R01004_SetFontStyle(@oPrtXlsx, "Signatory")
	oPrtXlsx:MergeCells(nCntR, 6, nCntR, 7)
	oPrtXlsx:setText(nCntR, 6, "")
	RU09R01004_SetFontStyle(@oPrtXlsx, "Header")
	oPrtXlsx:setText(nCntR, 8, "")
	RU09R01004_SetFontStyle(@oPrtXlsx, "Signatory")
	oPrtXlsx:MergeCells(nCntR, 9, nCntR, 11)
	oPrtXlsx:setText(nCntR, 9, IIF(LEN(aFooter) > 1, aFooter[2], ""))

	nCntR+= 1 //go to new line 
	RU09R01004_SetFontStyle(@oPrtXlsx, "SmallSignatory")
	oPrtXlsx:setText(nCntR, 6,STR0035)
	oPrtXlsx:setText(nCntR, 10,STR0030)

	nCntR+= 1 //go to new line
	RU09R01004_SetFontStyle(@oPrtXlsx, "Header")
	oPrtXlsx:MergeCells(nCntR, 1, nCntR, 5)
	oPrtXlsx:setText(nCntR, 1, STR0028)
	RU09R01004_SetFontStyle(@oPrtXlsx, "Signatory")
	oPrtXlsx:MergeCells(nCntR, 6, nCntR, 11)
	oPrtXlsx:setText(nCntR, 6, "")

	nCntR+= 1 //go to new line 
	RU09R01004_SetFontStyle(@oPrtXlsx, "SmallSignatory")
	oPrtXlsx:setText(nCntR, 8,STR0030)

	nCntR+= 1 //go to new line
	RU09R01004_SetFontStyle(@oPrtXlsx, "Header")
	oPrtXlsx:MergeCells(nCntR, 1, nCntR, 7)
	oPrtXlsx:setText(nCntR, 1, STR0029)
	RU09R01004_SetFontStyle(@oPrtXlsx, "Signatory")
	oPrtXlsx:MergeCells(nCntR, 8, nCntR, 11)
	oPrtXlsx:setText(nCntR, 8, "")
	oPrtXlsx:toXlsx()
	oPrtXlsx:DeActivate()
	oPrtXlsx := Nil

	If(!lHtml)
		StaticCall(RU09XXXFUN, OpenFileExcel, cFile)
	EndIf
	If !isblind() 
		MSGINFO(STR0036 + " " +Chr(13)+Chr(10) + cPath+Chr(13)+Chr(10) + STR0037 + " " + STUFF(cFile,1,Len(cPath), ""),;
		STR0038 +Chr(13)+Chr(10) + " " + STR0039) //Report completed
	EndIf

EndIf

Return Nil


/*/{Protheus.doc} RU09R01002_SetColumnWidth
  Set Width Columns only for report PurchasesBook

@type function
@author eprokhorenko
@version 2210
@param oPrtXlsx, object of class FwPrinterXlsx
@return NIL
/*/
Static Function RU09R01002_SetColumnWidth(oPrtXlsx)

//Set width for column
	oPrtXlsx:SetColumnsWidth(1,1,4.29)
	oPrtXlsx:SetColumnsWidth(2,2,4.86)
	oPrtXlsx:SetColumnsWidth(3,3,23.29)
	oPrtXlsx:SetColumnsWidth(4,4,14.86)
	oPrtXlsx:SetColumnsWidth(5,5,15.14)
	oPrtXlsx:SetColumnsWidth(6,6,14.86)
	oPrtXlsx:SetColumnsWidth(7,7,13.14)
	oPrtXlsx:SetColumnsWidth(8,8,13.71)
	oPrtXlsx:SetColumnsWidth(9,9,21.00)
	oPrtXlsx:SetColumnsWidth(10,10,10.43)
	oPrtXlsx:SetColumnsWidth(11,11,19.86)
	oPrtXlsx:SetColumnsWidth(12,12,10.43)
	oPrtXlsx:SetColumnsWidth(13,13,8.14)
	oPrtXlsx:SetColumnsWidth(14,15,14.86)
	oPrtXlsx:SetColumnsWidth(16,16,24.23)
	oPrtXlsx:SetColumnsWidth(17,17,17.14)
	oPrtXlsx:SetColumnsWidth(18,18,18.29)
	oPrtXlsx:SetColumnsWidth(19,19,11.57)

Return Nil

/*/{Protheus.doc} RU09R01003_SetCellsFormat
  Determines the formatting that will be applied 
  to cells by applying alignment, colors, and formatting to values.

@type function
@author eprokhorenko
@version 2210
@param oXlsx, object of class FwPrinterXlsx
	   cTypeValue, Character, value type
	   cTypeStyle, Character, style type
@return Nil
/*/
Static Function RU09R01003_SetCellsFormat(oPrtXlsx, cTypeValue, cTypeStyle)

Local cFormat      := ""
Local oCellHorAl   := FwXlsxCellAlignment():Horizontal()
Local oCellVerAl   := FwXlsxCellAlignment():Vertical()
Local cHorAlign    := oCellHorAl:Left()
Local cVertAlign   := oCellVerAl:Center()
Local lTextWrap    := .F.
Local cTextColor   := "000000" //black
Local cBgColor     := "FFFFFF"

Default cTypeValue := ""
Default cTypeStyle := ""

	Do Case
		Case cTypeValue == "D"
			cFormat := "dd/mm/yyyy"
			cHorAlign := oCellHorAl:Center()
		Case cTypeValue == "N"
			cFormat := "#,##0.00"
			cHorAlign := oCellHorAl:Right()
		Otherwise
			cFormat := ""
	EndCase

	Do Case 
		Case cTypeStyle == "FormName"
			cHorAlign  := oCellHorAl:Right()
			lTextWrap  := .T.
		Case cTypeStyle == "Title"
			cHorAlign  := oCellHorAl:Center()
		Case cTypeStyle == "HeaderTable"
			cHorAlign  := oCellHorAl:Center()
			lTextWrap  := .T.
		Case cTypeStyle == "TableTextWrap"
			lTextWrap  := .T.
		Case cTypeStyle == "SmallSignatory"
			cHorAlign  := oCellHorAl:Center()
			cVertAlign := oCellVerAl:Top()
		Otherwise
	EndCase

	oPrtXlsx:SetCellsFormat(cHorAlign, cVertAlign, lTextWrap, 0, cTextColor, cBgColor, cFormat)
Return Nil

/*/{Protheus.doc} RU09R01004_SetFontStyle
  Determines the formatting that will be applied 
  to cells by applying alignment, colors, and formatting to values.

@type function
@author eprokhorenko
@version 2210
@param oXlsx, object of class FwPrinterXlsx
	   cType, Character, style name
	   aBorders, Array, border
	   [1] Left [2] Top [3] Right [4] Bottom
@return Nil
/*/
Static Function RU09R01004_SetFontStyle(oPrtXlsx, cType, aBorders)
Default aBorders := {} 

	Do Case

		Case cType == "FormName"
			RU09R01003_SetCellsFormat(@oPrtXlsx, "C", cType)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 6, .F., .F., .F.)

		Case cType == "Title"
			RU09R01003_SetCellsFormat(@oPrtXlsx, "C", cType)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 14, .F., .T., .F.)

		Case cType == "Header"
			RU09R01003_SetCellsFormat(@oPrtXlsx, "C", cType)
			oPrtXlsx:SetBorder(.F., .F., .F., .F., FwXlsxBorderStyle():Thin()/*cStyle*/, "000000"/*cColor*/)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 9, .F., .F., .F.)

		Case cType == "HeaderTable"
			RU09R01003_SetCellsFormat(@oPrtXlsx, "C", cType)
			oPrtXlsx:SetBorder(.T., .T., .T., .T., FwXlsxBorderStyle():Thin()/*cStyle*/, "000000"/*cColor*/)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 8, .F., .T., .F.)

		Case cType == "Table"
			oPrtXlsx:SetBorder(.T., .T., .T., .T., FwXlsxBorderStyle():Thin()/*cStyle*/, "000000"/*cColor*/)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 9, .F., .F., .F.)

		Case cType == "Signatory"
			RU09R01003_SetCellsFormat(@oPrtXlsx, "C", cType)
			oPrtXlsx:SetBorder(.F., .F., .F., .T., FwXlsxBorderStyle():Thin()/*cStyle*/, "000000"/*cColor*/)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 9, .F., .F., .F.)

		Case cType == "SmallSignatory"
			RU09R01003_SetCellsFormat(@oPrtXlsx, "C", cType)
			oPrtXlsx:SetBorder(.F., .F., .F., .F., FwXlsxBorderStyle():Thin()/*cStyle*/, "000000"/*cColor*/)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 6, .F., .F., .F.)

	EndCase
Return Nil

/*/
{Protheus.doc} RU09R01005_FormatDate()
    Function formating date from date to russian print standart dd.mm.yyyy
    @type Function
    @params 
    @author 
    @since 2023/07/12
    @version 
    @return 
    @example 
/*/

Static Function RU09R01005_FormatDate(dData)
    Local cData     AS Character
    cData := DTOS(dData)
    cData := Substr(alltrim(cData), 7, 2) + "." +  Substr(alltrim(cData), 5, 2) + "." + Substr(alltrim(cData), 1, 4)
Return cData

/*/
{Protheus.doc} RU09R01006_TransformArray()
    Create sql filter
    @type Function
    @params 
		aTransfArr, Array, array to be converted
		nCodeOp, Numeric, operation number
		[1] - Create sql filter for F37_FORNEC
		[2] - Create sql filter for F37_BRANCH
		[3] - Create sql filter for F3C_FILIAL
    @author eprokhorenko
    @since 9/10/2023
    @version 
    @return cFilter, Character, filter for sql query
    @example RU09R01006_TransformArray(aTransfArr, cCodeOp)
/*/
 Static Function RU09R01006_TransformArray(aTransfArr, nCodeOp)
 Local aTempArray 		As Array
 Local aInterList		As Array
 Local aList			As Array
 Local nI				As Numeric

 aInterList := {}
 aList		:= {}
 
For nI := 1 To Len(aTransfArr)
	aTempArray := StrTokArr(aTransfArr[nI], SEPARATOR_ARRAY_INTERVAL_SYMBOL)
	If Len(aTempArray) > 1
		Aadd(aInterList, aTempArray[1])
		Aadd(aInterList, aTempArray[2])
	Else
		If !Empty(aTempArray[1])
			Aadd(aList, aTempArray[1])
		EndIf
	EndIf
Next

If !Empty(aList)
	If nCodeOp == 1
		cFilter := " AND ( F.F37_FORNEC IN ("
	ElseIf nCodeOp == 2
		cFilter := " AND ( F.F37_BRANCH IN ("
	ElseIf nCodeOp == 3
		cFilter := " AND ( FC.F3C_FILIAL IN ("	
	EndIf

	For nI := 1 To Len(aList)
		cFilter += "'" + aList[nI] + "'"
		If nI != Len(aList)
			cFilter += ", "
		Else 
			cFilter += ")"
		EndIf
	Next
EndIf

	For nI := 1 To Len(aInterList) Step 2
		If Empty(aList) .AND. nI == 1
			If nCodeOp == 1
				cFilter += " AND (F.F37_FORNEC BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			ElseIf nCodeOp == 2
				cFilter := " AND (F.F37_BRANCH BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			ElseIf nCodeOp == 3
				cFilter := " AND (FC.F3C_FILIAL BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"	
			EndIf
		Else
			If nCodeOp == 1
				cFilter += " OR F.F37_FORNEC BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			ElseIf nCodeOp == 2
				cFilter := " OR F.F37_BRANCH BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			ElseIf nCodeOp == 3
				cFilter := " OR FC.F3C_FILIAL BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			EndIf
		EndIf
	Next
	cFilter += ")"	
 Return cFilter
                   
//Merge Russia R14 
                   
