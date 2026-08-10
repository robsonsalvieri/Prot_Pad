#include "protheus.ch"
#include "ru09r02.ch"
#include 'fwmvcdef.ch'
#include 'fileio.ch'

#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"
#DEFINE SEPARATOR_ARRAY_INTERVAL_SYMBOL "-"
#DEFINE F54_TYPE_SALES_CODE "02"
#DEFINE F54_TYPE_VAT_REFUND_OR_RESTORATION "03"

/*/{Protheus.doc} RU09R02 
  Entry point to run the routine.

@type function
@author ogalyndina
@version 2210
@param  
@return NIL
/*/
Function RU09R02() 
//https://jiraproducao.totvs.com.br/browse/RULOC-5199
//FI-VAT-31-19 Sales Book

Local lResult 	As Logical
Local lRes		As Logical
Local aFilters 	As Array

aFilters := {}
lResult :=	Pergunte("RU09R0201", .T.)

If lResult
	//1 - Report format 
	Aadd(aFilters, MV_PAR01) 
	If aFilters[1] == 1
		lRes := Pergunte("RU09R0202", .T.)
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
			
			GetDataSlBook(aFilters)
		EndIf
	Else
		lRes := Pergunte("RU09R0203", .T.)
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

			GetDataSlBook(aFilters)
		EndIf
	EndIf
EndIf

Return .T.

/*/
{Protheus.doc} GetDataSLBook()
    Create arrays aHeaders, aTables, aFooter for sales book
    @type Function
    @params aParam Array - filters
    @author eprokhorenko
    @since 26/10/2023
    @version 
    @return 
    @example GetDataSLBook(aParam)
/*/
Static Function GetDataSlBook(aFilters)
Local cDateFrom			As Character
Local cDateTo			As Character
Local aHeaders := {}    As Array
Local aFooter           As Array
Local aTables           As Array 
Local aTransfArr := {}	As Array
Local aListFl := {}		As Array 
Local nFormReport		As Numeric
Local nCountStr	:= 0	As Numeric
Local cINN_KPP:= ""		As Character
Local cCompanyName:= ""	As Character
Local cFilialName := ""	As Character
Local cFilINN_KPP := ""	As Character
Local cBuyersCode := ""	As Character
Local cBranches	  := ""	As Character
Local cBuyer			As Character
Local cFilterBuyer		As Character
// Local aAreaSB			As Array
Local cF5PDoc 			As Character
Local nX				As Numeric
Local cNotFil			As Character
Local cFiltRegular		As Character
Local aAreaSa1			As Array
Local aAreaCTO			As Array
Local aAreaF35			As Array
Local aAreaF5P			As Array
Local aCompanyInfo:= {} As Array
Local aBranchInfo := {} As Array
Local cFilCodeOfList	As Character
Local nTotSum20 := 0	As Character
Local nTotSum18 := 0	As Character
Local nTotSum10 := 0	As Character
Local nTotSum0 := 0		As Character
Local nTSumNoVAT:= 0	As Numeric
Local nTotVAT20 := 0	As Character
Local nTotVAT18 := 0	As Character
Local nTotVAT10 := 0	As Character
Local cCheckF54 := ""	As Character
Local cF31OpCode		As Character

cNotFil := STUFF(cNumemp, 1, Len(cEmpant)+Len(FWCompany())+Len(FWUnitBusiness()), "")

cComPar     := Alltrim(SuperGetMv("MV_CMPLVL",.F.,""))

nFormReport := aFilters[1]
cDateFrom   := RU09R02002_FormatDate(aFilters[2])
cDateTo     := RU09R02002_FormatDate(aFilters[3])
	
//Create and transform filters

	//Formatting Branches
	If !Empty(aFilters[5]) .AND. nFormReport == 2
		aTransfArr := StrTokArr(aFilters[5], SEPARATOR_ARRAY_VALUES_SYMBOL)
		For nX := 1 To Len(aTransfArr)
			If !Empty(aTransfArr[nX])
				cBranches += aTransfArr[nX] + IIF(nX!=Len(aTransfArr), ", " , "")
				Aadd(aListFl, aTransfArr[nX])
			EndIf
		Next
		If Len(aListFl) == 1
			aListFl := StrTokArr(aListFl[1], SEPARATOR_ARRAY_INTERVAL_SYMBOL)
			nCountFil := Iif(Len(aListFl) == 1, 1, 0)
		Else
			nCountFil := 0
		EndIf
		cFiltrFil := RU09R02003_TransformArray(aTransfArr, 3)// Create the filter for an SQL query (Branches)
	Else
		cFiltrFil := ""
	EndIf

	//Formatting Buyers Codes
	If !Empty(aFilters[6]) .AND. nFormReport == 2
		aTransfArr := StrTokArr(aFilters[6], SEPARATOR_ARRAY_VALUES_SYMBOL)
		For nX := 1 To Len(aTransfArr)
			cBuyersCode += aTransfArr[nX] + IIF(nX!=Len(aTransfArr), ", " , "")
		Next
		cFilterBuyer := RU09R02003_TransformArray(aTransfArr, 1)// Create the filter for an SQL query (Buyers Codes)
	Else
		cFilterBuyer := ""
	EndIF

		//Formatting Buyer's unit
	If !Empty(aFilters[7]) .AND. nFormReport == 2
		aTransfArr := StrTokArr(aFilters[7], SEPARATOR_ARRAY_VALUES_SYMBOL)
		cFilterUnit := RU09R02003_TransformArray(aTransfArr, 2)// Create the filter for an SQL query (Buyer's unit)
	Else
		cFilterUnit := ""
	EndIF	

	//Create fielters. Report format: 1 - Regular
	If nFormReport == 1 .AND. cComPar == "4"
		cFiltRegular := cNotFil
	Else
		cFiltRegular := ""
	EndIf

	// Create data aHeaders
    DO CASE 

		CASE cValToChar(VAL(cComPar)-1) == '3' // Filial.
            aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
			If(!Empty(aCompanyInfo))
				cCompanyName := aCompanyInfo[1]
				cINN_KPP     := aCompanyInfo[2] 
			Else
				aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'1', FWGrpCompany(),FWCompany(), FWUnitBusiness())
				If(!Empty(aCompanyInfo))
					cCompanyName := aCompanyInfo[1]
					cINN_KPP     := aCompanyInfo[2]
				Else
					aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'0', FWGrpCompany(),FWCompany(), FWUnitBusiness())
					If(!Empty(aCompanyInfo))
						cCompanyName := aCompanyInfo[1]
						cINN_KPP     := aCompanyInfo[2]
					EndIf
				EndIF
			EndIF
			aBranchInfo := StaticCall(RU05R06,RU05R06002_GetBranchInfo, FWGrpCompany(),FWCompany(), FWUnitBusiness(), cNotFil)
			cINN_KPP += IIF(aBranchInfo[1] == '2', "/" + aBranchInfo[2], "")
    
        CASE cValToChar(VAL(cComPar)-1) == '2' // Buisness unit.
            aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            cCompanyName := aCompanyInfo[1]
            cINN_KPP     := aCompanyInfo[2] + IIF(aCompanyInfo[4] == "2", "/" + aCompanyInfo[3], "")
        CASE cValToChar(VAL(cComPar)-1) == '1' // Company.
            aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'1', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            cCompanyName := aCompanyInfo[1]
            cINN_KPP     := aCompanyInfo[2] + IIF(aCompanyInfo[4] == "2", "/" + aCompanyInfo[3], "")
        CASE cValToChar(VAL(cComPar)-1) == '0' // Group company.
            aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'0', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            cCompanyName := aCompanyInfo[1]
            cINN_KPP     := aCompanyInfo[2] + IIF(aCompanyInfo[4] == "2", "/" + aCompanyInfo[3], "")
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
		aAdd(aHeaders, cBuyersCode)
	EndIf

//Create SQL query
	aArea := getArea()
    
	cQuery := " SELECT F54.F54_FILIAL, F54.F54_KEY, F54.F54_DIRECT, F54.F54_TYPE, F54.F54_DOC, F54.F54_PDATE, F54.F54_DATE, F54.F54_ADJNR, F54.F54_ADJDT, F54.F54_CLIENT, F54.F54_CLIBRA,"
	cQuery += " SUM(CASE WHEN F54.F54_VATRT = 20 THEN F54.F54_VATBS  ELSE 0 END) as Sum20, "
	cQuery += " SUM(CASE WHEN F54.F54_VATRT = 18 THEN F54.F54_VATBS  ELSE 0 END) as Sum18, "
	cQuery += " SUM(CASE WHEN F54.F54_VATRT = 10 THEN F54.F54_VATBS  ELSE 0 END) as Sum10, "
	cQuery += " SUM(CASE WHEN F54.F54_VATRT = 0 AND F31.F31_RATE = '0005' THEN F54.F54_VATBS  ELSE 0 END) as Sum0,"
	cQuery += " SUM(CASE WHEN F54.F54_VATRT = 0 AND F31.F31_RATE = '0006' THEN F54.F54_VATBS  ELSE 0 END) as SumNoVAT, "
	cQuery += " SUM(CASE WHEN F54.F54_VATRT = 20 THEN F54.F54_VALUE  ELSE 0 END) as SumVAT20, "
	cQuery += " SUM(CASE WHEN F54.F54_VATRT = 18 THEN F54.F54_VALUE  ELSE 0 END) as SumVAT18, "
	cQuery += " SUM(CASE WHEN F54.F54_VATRT = 10 THEN F54.F54_VALUE  ELSE 0 END) as SumVAT10, "
	cQuery += " F35.F35_VATCD2, F35.F35_KPP_CL, F35.F35_INVCUR, F35.F35_VALGR, F35.F35_VATBS1, F35.F35_VATVL1, "
	cQuery += " F37.F37_VALGR,F37.F37_VATBS1, F37.F37_VATVL1, F37.F37_INVCUR, "
	cQuery += " F36.F36_ITMCOD, F36.F36_QUANT, F36.F36_VATBS1, F36.F36_ITEM, F54.F54_KEYORI,  "
	//cQuery += " F36.F36_ITMCOD, F36.F36_ENRNT, F36.F36_QUANT, F36.F36_VATBS1, F36.F36_ITEM, F54.F54_KEYORI, "

	cQuery += " (SELECT COALESCE (COUNT(*),0) F5PDOC FROM " + RetSqlName("F5P") + " AS FP "
		cQuery += " WHERE FP.F5P_FILIAL = F54.F54_FILIAL AND FP.F5P_KEY = F54.F54_KEY) AS F5PDOC "
	
	cQuery += " FROM " + RetSqlName("F54") + " AS F54 "

	cQuery += " LEFT JOIN " + RetSqlName("F35") + " AS F35 "
	cQuery += " ON F54.F54_KEY = F35.F35_KEY "
	cQuery += " AND F54.F54_FILIAL = F35.F35_FILIAL "
	cQuery += " AND F54.D_E_L_E_T_ = F35.D_E_L_E_T_ "

	cQuery += " LEFT JOIN " + RetSqlName("F37") + " AS F37 "
	cQuery += " ON F54.F54_DOC = F37.F37_DOC "
	cQuery += " AND F54.F54_PDATE = F37.F37_PDATE "
	cQuery += " AND F54.F54_CLIENT = F37.F37_FORNEC "
	cQuery += " AND F54.D_E_L_E_T_ = F37.D_E_L_E_T_ "

	cQuery += " LEFT JOIN " + RetSqlName("F36") + " AS F36 "
	cQuery += " ON F54.F54_KEY = F36.F36_KEY "
	cQuery += " AND F54.F54_FILIAL = F36.F36_FILIAL "
	cQuery += " AND F54.D_E_L_E_T_ = F36.D_E_L_E_T_ "

	cQuery += " LEFT JOIN " + RetSqlName("F31") + " AS F31 "
	cQuery += " ON F54.F54_VATCOD = F31.F31_CODE "
	cQuery += " AND F54.D_E_L_E_T_ = F31.D_E_L_E_T_ "

	cQuery += " WHERE F54.F54_DIRECT = '-' "
	If nFormReport == 1 .AND. (!Empty(cFiltRegular))
		cQuery += " AND F54.F54_FILIAL = '" + cFiltRegular + "'" 
	EndIf
	If nFormReport == 2
		cQuery += cFiltrFil
		cQuery += cFilterBuyer
		cQuery += cFilterUnit
	EndIf
	cQuery += " AND F54.D_E_L_E_T_ = '' "
	cQuery += " AND F54.F54_DATE >= '" + DToS(aFilters[2]) + "' AND F54.F54_DATE <='" + DToS(aFilters[3]) + "'"
	cQuery += " AND F54.F54_TYPE IN ( '02','03') "

	cQuery += " GROUP BY F54.F54_FILIAL, F54.F54_KEY, F54.F54_DIRECT, F54.F54_TYPE, F54.F54_DOC, F54.F54_PDATE, F54.F54_DATE, F54.F54_ADJNR, F54.F54_ADJDT, F54.F54_CLIENT, "
	cQuery += " F54.F54_CLIBRA, F35.F35_VATCD2, F35.F35_KPP_CL, F35.F35_INVCUR, F35.F35_VALGR, F35.F35_VATBS1, F35.F35_VATVL1, "
	cQuery += " F37.F37_VALGR,F37.F37_VATBS1, F37.F37_VATVL1, F37.F37_INVCUR, F36.F36_ITMCOD, F36.F36_QUANT, F36.F36_VATBS1, F36.F36_ITEM, F54.F54_KEYORI "

	cQuery += " ORDER BY F54.F54_PDATE ASC, F54.F54_KEY ASC, F54.F54_DOC ASC "
	// cQuery += " F37.F37_VALGR,F37.F37_VATBS1, F37.F37_VATVL1, F37.F37_INVCUR, F36.F36_ITMCOD, F36.F36_ENRNT, F36.F36_QUANT, F36.F36_VATBS1, F36.F36_ITEM, F54.F54_KEYORI, "
	// cQuery += " ORDER BY F54.F54_PDATE ASC, F54.F54_KEY ASC, F54.F54_DOC ASC, F36.F36_ENRNT DESC  "

	cQuery      := ChangeQuery(cQuery)
	cAliasTMP   := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
	DbSelectArea(cAliasTMP)

    aTables := {}
	
    (cAliasTMP)->(dbGotop())
    While  (cAliasTMP)->(!EOF())
    If(!Empty((cAliasTMP)->F54_KEY ))
        //Create data block_tmp
        aBlock_tmp := {}

		If(cCheckF54 != (cAliasTMP)->F54_FILIAL + (cAliasTMP)->F54_KEY + (cAliasTMP)->F54_DOC + (cAliasTMP)->F54_PDATE + (cAliasTMP)->F54_CLIENT + (cAliasTMP)->F54_ADJNR + (cAliasTMP)->F54_ADJDT;
)//.OR. !EMPTY((cAliasTMP)->F36_ENRNT)
		
			If(cCheckF54 != (cAliasTMP)->F54_FILIAL + (cAliasTMP)->F54_KEY + (cAliasTMP)->F54_DOC + (cAliasTMP)->F54_PDATE + (cAliasTMP)->F54_CLIENT + (cAliasTMP)->F54_ADJNR + (cAliasTMP)->F54_ADJDT)
			//1 - Item number, auto incrementation 
				aAdd(aBlock_tmp, nCountStr += 1)
			Else
				aAdd(aBlock_tmp, nCountStr)
			EndIf
			//2 - Code of the type of operation 
			cF31OpCode := ""
			
			aAreaF54 := getArea()
    
			cQuery := " SELECT F54.F54_VATCOD, F31.F31_CODE, F31.F31_OPCODE
			cQuery += " FROM " + RetSqlName("F54") + " AS F54"

			cQuery += " INNER JOIN " + RetSqlName("F31") + " AS F31"
			cQuery += " ON F54.F54_VATCOD = F31.F31_CODE"
			cQuery += " AND F54.D_E_L_E_T_ = F31.D_E_L_E_T_"

			cQuery += " WHERE F54.F54_DIRECT = '-' "
			cQuery += " AND F54.D_E_L_E_T_ = '' "
			cQuery += " AND F54.F54_DATE >= '" + DToS(aFilters[2]) + "' AND F54.F54_DATE <='" + DToS(aFilters[3]) + "'"
			cQuery += " AND F54.F54_TYPE IN ( '02','03') "

			cQuery += " AND F54.F54_KEY = '" + (cAliasTMP)->F54_KEY + "'"
			cQuery += " AND F54.F54_FILIAL = '" + (cAliasTMP)->F54_FILIAL + "'"
			
			cQuery      := ChangeQuery(cQuery)
			cAliasF54   := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasF54,.T.,.T.)
			DbSelectArea(cAliasF54)

			(cAliasF54)->(dbGotop())
				While  (cAliasF54)->(!EOF())
					If !((cAliasF54)->F31_OPCODE $ cF31OpCode)
						cF31OpCode += IIF(!Empty(cF31OpCode), ";", "") + (cAliasF54)->F31_OPCODE
					EndIf
					(cAliasF54)->(dbSkip())	
				EndDo				
				(cAliasF54)->(dbCloseArea())
			RestArea(aAreaF54)
			aAdd(aBlock_tmp, cF31OpCode) 

			//3 - VAT invoice number and date F54_DOC and F54_PDATE, separated by a semicolon ";"
			aAdd(aBlock_tmp, AllTrim((cAliasTMP)->F54_DOC) + ";" + RU09R02002_FormatDate(STOD(AllTrim((cAliasTMP)->F54_PDATE))))
			//4 - Buyer's invoice number and date of correction F54_ADJNR and F54_ADJDT, separated by a semicolon ";"
			If(!Empty((cAliasTMP)->F54_ADJNR) .AND. !Empty((cAliasTMP)->F54_ADJDT))
				aAdd(aBlock_tmp, AllTrim((cAliasTMP)->F54_ADJNR) + ";" + RU09R02002_FormatDate(STOD(AllTrim((cAliasTMP)->F54_ADJDT)))) 
			Else
				aAdd(aBlock_tmp, "")
			EndIf

			// F54_TYPE = '02' - Sales book
			// F54_TYPE = '03' - VAT refund/restoration
			If(((cAliasTMP)->F54_TYPE) == F54_TYPE_SALES_CODE)

			aAreaSa1 := SA1->(GetArea())
			//5 - Buyer's short name A1_NREDUZ 
				DbSelectArea("SA1")
				dbSetOrder(1)
				If dbseek(XFilial("SA1")+(cAliasTMP)->F54_CLIENT +(cAliasTMP)->F54_CLIBRA)
					aAdd(aBlock_tmp, AllTrim(SA1->A1_NREDUZ))
				Else
					aAdd(aBlock_tmp, "No buyer")
				EndIf 

				cBuyer  := XFilial("SA1") + (cAliasTMP)->F54_CLIENT + (cAliasTMP)->F54_CLIBRA
			//6 - INN code from Buyer's card A1_CODZON; KPP code from VAT invoice  F35_KPP_CL separated by slash "/"
				aAdd(aBlock_tmp, AllTrim(Posicione("SA1", 1, cBuyer, "A1_CODZON")) + IIF(!EMPTY(AllTrim((cAliasTMP)->F35_KPP_CL)),"/"+ AllTrim((cAliasTMP)->F35_KPP_CL),""))
				RestArea(aAreaSa1)

			Else
			DO CASE 
					CASE cValToChar(VAL(cComPar)-1) == '3' // Filial.
						aBranchInfo  := StaticCall(RU05R06,RU05R06002_GetBranchInfo,FWGrpCompany(),FWCompany(), FWUnitBusiness(), STUFF((cAliasTMP)->F54_FILIAL, 1, Len(FWCompany())+Len(FWUnitBusiness()), ""))
						aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
						If(!Empty(aCompanyInfo))
							cCompanyName := aCompanyInfo[1]
							cINN_KPP     := aCompanyInfo[2] 
						Else
							aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'1', FWGrpCompany(),FWCompany(), FWUnitBusiness())
							If(!Empty(aCompanyInfo))
								cCompanyName := aCompanyInfo[1]
								cINN_KPP     := aCompanyInfo[2]
							Else
								aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'0', FWGrpCompany(),FWCompany(), FWUnitBusiness())
								If(!Empty(aCompanyInfo))
									cCompanyName := aCompanyInfo[1]
									cINN_KPP     := aCompanyInfo[2]
								EndIf
							EndIF
						EndIF
					CASE cValToChar(VAL(cComPar)-1) == '2' // Buisness unit.
						aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
						aBranchInfo  := StaticCall(RU05R06,RU05R06002_GetBranchInfo,FWGrpCompany(),FWCompany(), FWUnitBusiness(), STUFF((cAliasTMP)->F54_FILIAL, 1, Len(FWCompany())+Len(FWUnitBusiness()), ""))

					CASE cValToChar(VAL(cComPar)-1) == '1' // Company.
						aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'1', FWGrpCompany(),FWCompany(), FWUnitBusiness())
						aBranchInfo  := StaticCall(RU05R06,RU05R06002_GetBranchInfo,FWGrpCompany(),FWCompany(), FWUnitBusiness(), STUFF((cAliasTMP)->F54_FILIAL, 1, Len(FWCompany())+Len(FWUnitBusiness()), ""))

					CASE cValToChar(VAL(cComPar)-1) == '0' // Group company.
						aCompanyInfo := StaticCall(RU05R06,RU05R06001_GetCompanyInfo,'0', FWGrpCompany(),FWCompany(), FWUnitBusiness())
						aBranchInfo  := StaticCall(RU05R06,RU05R06002_GetBranchInfo,FWGrpCompany(),FWCompany(), FWUnitBusiness(), STUFF((cAliasTMP)->F54_FILIAL, 1, Len(FWCompany())+Len(FWUnitBusiness()), ""))
						
    			ENDCASE

				If(cValToChar(VAL(cComPar)-1) != '3')
				//5 - Short name of the organization
					aAdd(aBlock_tmp, aCompanyInfo[1])

				//6 - INN/KPP of the organization
					aAdd(aBlock_tmp,aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3]))
				Else
				//5 - Short name of the organization
					aAdd(aBlock_tmp, aBranchInfo[3])

				//6 - INN/KPP of the organization
					aAdd(aBlock_tmp,aCompanyInfo[2] + "/" + aBranchInfo[2])
				EndIf

			EndIf
			//7 - Number and date of the document confirming payment
			cF5PDoc = ""
			If((cAliasTMP)->F5PDOC != 0)

				aAreaF5P := getArea()
				cQuery := " SELECT F5P_FILIAL, F5P_KEY, F5P_ADVDOC, F5P_ADVDT"
				cQuery += " FROM " + RetSqlName("F5P") 
				cQuery += " WHERE F5P_FILIAL =  '" + (cAliasTMP)->F54_FILIAL + "'"
				cQuery += " AND F5P_KEY =  '" + (cAliasTMP)->F54_KEY + "'"
				cQuery += " AND D_E_L_E_T_ = '' "

				cQuery      := ChangeQuery(cQuery)
				cAliasF5P   := GetNextAlias()
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasF5P,.T.,.T.)
				DbSelectArea(cAliasF5P)

				(cAliasF5P)->(dbGotop())
				While  (cAliasF5P)->(!EOF())
					cF5PDoc += IIF(!Empty(cF5PDoc), ",", "") + AllTrim((cAliasF5P)->F5P_ADVDOC) + ";" + RU09R02002_FormatDate(STOD(AllTrim((cAliasF5P)->F5P_ADVDT)))
					
					(cAliasF5P)->(dbSkip())		
				EndDo
				aAdd(aBlock_tmp, cF5PDoc) 

				(cAliasF5P)->(dbCloseArea())
				RestArea(aAreaF5P)
			Else
				//7 - Number and date of the document confirming payment
				aAdd(aBlock_tmp, cF5PDoc)
			EndIf

			If((cAliasTMP)->F35_INVCUR != '01' .AND. (cAliasTMP)->F54_TYPE == F54_TYPE_SALES_CODE)	
			//8 - Currency F35_INVCUR. Filled in if the VAT invoice currency is not ruble
				aAreaCTO := CTO->(GetArea())
				aAdd(aBlock_tmp, AllTrim(Posicione("CTO",1,xFilial("CTO")+AllTrim((cAliasTMP)->F35_INVCUR),"CTO_RDESC")) + ", ";
						+ AllTrim(Posicione("CTO",1,xFilial("CTO")+AllTrim((cAliasTMP)->F35_INVCUR),"CTO_CODISO")))
				RestArea(aAreaCTO)

				If(!Empty((cAliasTMP)->F54_KEYORI))
					aAreaF35 := GetArea()
						dbSelectArea('F35')
						dbSetOrder(3)
						If (F35->(dbseek(xFilial("F35") + (cAliasTMP)->F54_KEYORI )))
			//9 - Gross value for VAT invoice in VAT invoice
							aAdd(aBlock_tmp, (F35->F35_VALGR) * (-1)) 
							F35->(dbSkip()) 
						Else
							aAdd(aBlock_tmp, "")
						Endif
					RestArea(aAreaF35)
					Else
					//9 - Gross value for VAT invoice in VAT invoice
					aAdd(aBlock_tmp, (cAliasTMP)->F35_VALGR) 
				EndIf
			ElseIf((cAliasTMP)->F37_INVCUR != '01' .AND. (cAliasTMP)->F54_TYPE == F54_TYPE_VAT_REFUND_OR_RESTORATION)
			//8 - Currency F37_INVCUR. Filled in if the VAT invoice currency is not ruble
				aAreaCTO := CTO->(GetArea())
				aAdd(aBlock_tmp, AllTrim(Posicione("CTO",1,xFilial("CTO")+AllTrim((cAliasTMP)->F37_INVCUR),"CTO_RDESC")) + ", ";
							+ AllTrim(Posicione("CTO",1,xFilial("CTO")+AllTrim((cAliasTMP)->F37_INVCUR),"CTO_CODISO")))
				RestArea(aAreaCTO)
			//9 - Gross value for VAT invoice in VAT invoice
				aAdd(aBlock_tmp, Transform((cAliasTMP)->F37_VALGR, GetSx3Cache( "F37_VALGR", "X3_PICTURE" ))) 
			Else
			//8 - Currency F35_INVCUR. 
				aAdd(aBlock_tmp, "")
			//9 - Gross value for VAT invoice in VAT invoice
				aAdd(aBlock_tmp, "")
			EndIf
		
			If(((cAliasTMP)->F54_TYPE) == F54_TYPE_SALES_CODE )
				If(!Empty((cAliasTMP)->F54_KEYORI))
					aAreaF35 := GetArea()
						dbSelectArea('F35')
						dbSetOrder(3)
						If (F35->(dbseek(xFilial("F35") + (cAliasTMP)->F54_KEYORI )))
			//10 - Total F35_VATBS1+F35_VATVL1 
							aAdd(aBlock_tmp, (((F35->F35_VATBS1) + (F35->F35_VATVL1)) * (-1)))  
							F35->(dbSkip()) 
						Else
							aAdd(aBlock_tmp, "")
						Endif
					RestArea(aAreaF35)					
				Else
			//10 - Total F35_VATBS1+F35_VATVL1 
				aAdd(aBlock_tmp, (cAliasTMP)->F35_VATBS1 +(cAliasTMP)->F35_VATVL1)    
				EndIf
			Else
			//10 - Total F37_VATBS1+F37_VATVL1
				aAdd(aBlock_tmp, (cAliasTMP)->F37_VATBS1 +(cAliasTMP)->F37_VATVL1)  

			EndIf
			//11 - VAT base in rubles at a rate of 20%	
				aAdd(aBlock_tmp, IIF(((cAliasTMP)->Sum20) != 0, (cAliasTMP)->Sum20,"")) 
			//12 - VAT base in rubles at a rate of 18%
				aAdd(aBlock_tmp, IIF(((cAliasTMP)->Sum18) != 0, (cAliasTMP)->Sum18, ""))
			//13 - VAT base in rubles at a rate of 10%
				aAdd(aBlock_tmp, IIF(((cAliasTMP)->Sum10) != 0, (cAliasTMP)->Sum10, ""))
			//14 - VAT base in rubles at a rate of 0%
				aAdd(aBlock_tmp, IIF(((cAliasTMP)->Sum0)  != 0, (cAliasTMP)->Sum0, ""))

			//15 -VAT amount at 20% rate
				aAdd(aBlock_tmp, IIF(((cAliasTMP)->SumVAT20)  != 0, (cAliasTMP)->SumVAT20, "")) 
			//16 -VAT amount at 18% rate
				aAdd(aBlock_tmp, IIF(((cAliasTMP)->SumVAT18)  != 0, (cAliasTMP)->SumVAT20, ""))
			//17 - VAT amount at 10% rate
				aAdd(aBlock_tmp, IIF(((cAliasTMP)->SumVAT10)  != 0, (cAliasTMP)->SumVAT10, "")) 
			//18 - Sales value exempt from tax (Column 19 in the sales book)
				aAdd(aBlock_tmp, IIF(((cAliasTMP)->SumNoVAT)  != 0, Transform((cAliasTMP)->SumNoVAT, GetSx3Cache( "F54_VALUE", "X3_PICTURE" )), "")) 
			
			//Commented until field F36_ENRNT comein DB 
			//19 - RNPT External Number  
			//aAdd(aBlock_tmp, (cAliasTMP)->F36_ENRNT) 
			//20 - Unit of measure 
			// If(!Empty((cAliasTMP)->F36_ENRNT))
			// aAreaSB := GetArea()
			// aAdd(aBlock_tmp, Posicione("SAH",1,xFilial("SAH")+(Posicione("SB1",1,xFilial("SB1")+(cAliasTMP)->F36_ITMCOD,"B1_UM")),"AH_CODOKEI")) 
			// RestArea(aAreaSB)
			// Else
			// aAdd(aBlock_tmp, "") 
			// EndIf
			// //21 - Quantity
			// If(!Empty((cAliasTMP)->F36_ENRNT))
			// aAdd(aBlock_tmp, Transform((cAliasTMP)->F36_QUANT,  GetSx3Cache( "F36_VATBS1", "X3_PICTURE" ))) // F36_QUANT
			// Else
			// aAdd(aBlock_tmp, "") 
			// EndIf
			// //22 - Cost of RNPT
			// If(!Empty((cAliasTMP)->F36_ENRNT))
			// aAdd(aBlock_tmp, Transform((cAliasTMP)->F36_VATBS1,  GetSx3Cache( "F36_VATBS1", "X3_PICTURE" )))
			// Else
			// aAdd(aBlock_tmp, "") 
			// EndIf
			aAdd(aBlock_tmp, "")
			aAdd(aBlock_tmp, "")
			aAdd(aBlock_tmp, "")
			aAdd(aBlock_tmp, "")

			If(cCheckF54 != (cAliasTMP)->F54_FILIAL + (cAliasTMP)->F54_KEY + (cAliasTMP)->F54_DOC + (cAliasTMP)->F54_PDATE + (cAliasTMP)->F54_CLIENT + (cAliasTMP)->F54_ADJNR + (cAliasTMP)->F54_ADJDT)
				//For aFooter
				nTotSum20 += (cAliasTMP)->Sum20
				nTotSum18 += (cAliasTMP)->Sum18
				nTotSum10 += (cAliasTMP)->Sum10
				nTotSum0  += (cAliasTMP)->Sum0
				nTSumNoVAT+= (cAliasTMP)->SumNoVAT

				nTotVAT20 += (cAliasTMP)->SumVAT20
				nTotVAT18 += (cAliasTMP)->SumVAT18
				nTotVAT10 += (cAliasTMP)->SumVAT10

			EndIf

			cCheckF54 := (cAliasTMP)->F54_FILIAL + (cAliasTMP)->F54_KEY + (cAliasTMP)->F54_DOC + (cAliasTMP)->F54_PDATE + (cAliasTMP)->F54_CLIENT + (cAliasTMP)->F54_ADJNR + (cAliasTMP)->F54_ADJDT

			aAdd(aTables, aClone(aBlock_tmp))
		EndIf

		EndIf
		(cAliasTMP)->(dbSkip())		
    EndDo
    (cAliasTMP)->(dbCloseArea())
    RestArea(aArea)
	
	aFooter := {}

	//1 - Total VAT base in rubles at a rate of 20%
	aAdd(aFooter, IIF(nTotSum20 != 0, nTotSum20, "")) 
	//2 - Total VAT base in rubles at a rate of 18%
	aAdd(aFooter, IIF(nTotSum18 != 0, nTotSum18, ""))
	//3 - Total VAT base in rubles at a rate of 10% 
	aAdd(aFooter, IIF(nTotSum10 != 0, nTotSum10, "")) 
	//4 - Total VAT base in rubles at a rate of 0%
	aAdd(aFooter, IIF(nTotSum0  != 0, nTotSum0, "")) 
	//5 - VAT amount at 20% rate
	aAdd(aFooter, IIF(nTotVAT20 != 0, nTotVAT20, "")) 
	//6 - VAT amount at 18% rate
	aAdd(aFooter, IIF(nTotVAT18 != 0, nTotVAT18, "")) 
	//7 - VAT amount at 10% rate
	aAdd(aFooter, IIF(nTotVAT10 != 0, nTotVAT10, "")) 
	//8 - Total sales value exempt from tax (Column 19 in the sales book)
	aAdd(aFooter, IIF(nTSumNoVAT != 0 , Transform(nTSumNoVAT,  GetSx3Cache( "F54_VATBS", "X3_PICTURE" )), "")) 

	//9 - Head of the company
	If !Empty(aFilters[4])
		aArea := getArea()
			aAdd(aFooter, Posicione("F42",1,xFilial("F42")+ aFilters[4],"F42_NAME"))
		RestArea(aArea)
	Else
		aAdd(aFooter, "")
	EndIf

	//10 - if the company is an individual entrepreneur 
	If (Len(aCompanyInfo) > 3 .AND. aCompanyInfo[4] == "1")//CO_TYPE
		aAdd(aFooter, IIF(Len(aCompanyInfo) > 4, aCompanyInfo[5], ""))
	Else
		aAdd(aFooter, "")
	EndIf
	
	RU09R02008(aHeaders, aTables, aFooter)

Return Nil

/*/
{Protheus.doc} RU09R02002_FormatDate()
    Function formating date from date to russian print standart dd.mm.yyyy
    @type Function
    @params 
    @author 
    @since 2023/07/12
    @version 
    @return 
    @example 
/*/

Static Function RU09R02002_FormatDate(dData)
    Local cData     AS Character
    cData := DTOS(dData)
    cData := Substr(alltrim(cData), 7, 2) + "." +  Substr(alltrim(cData), 5, 2) + "." + Substr(alltrim(cData), 1, 4)
Return cData


/*/
{Protheus.doc} RU09R02003_TransformArray()
    Create sql filter	
	@type Function
    @params 
		aTransfArr, Array, array to be converted
		nCodeOp, Numeric, operation number
		[1] - Create sql filter for F54_CLIENT
		[2] - Create sql filter for F54_CLIBRA
		[3] - Create sql filter for F54_FILIAL
    @author eprokhorenko
    @since 9/10/2023
    @version 
    @return cFilter, Character, filter for sql query
    @example RU09R02003_TransformArray(aTransfArr, cCodeOp)
/*/


 Static Function RU09R02003_TransformArray(aTransfArr, nCodeOp)
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
		cFilter := " AND (F54.F54_CLIENT IN ("
	ElseIf nCodeOp == 2
		cFilter := " AND (F54.F54_CLIBRA IN ("
	ElseIf nCodeOp == 3
		cFilter := " AND (F54.F54_FILIAL IN ("	
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
				cFilter += " AND (F54.F54_CLIENT BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			ElseIf nCodeOp == 2
				cFilter := " AND (F54.F54_CLIBRA BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			ElseIf nCodeOp == 3
				cFilter := " AND (F54.F54_FILIAL BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"	
			EndIf
		Else
			If nCodeOp == 1
				cFilter += " OR F54.F54_CLIENT BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			ElseIf nCodeOp == 2
				cFilter := " OR F54.F54_CLIBRA BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			ElseIf nCodeOp == 3
				cFilter := " OR F54.F54_FILIAL BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			EndIf
		EndIf
	Next
	cFilter += ")"	
 Return cFilter

 
/*/{Protheus.doc} RU09R02004_ValidationFilial
    Function for validation of field "Code".
	
	in pergunte question "Branches"
    @type Function
    @param cFilialCode, Character, Code like "01;02-04;".
		   cTableName, Character, Table name like "F42"
    @author eprokhorenko
    @since 15.11.2023
    @version 
    @return Logical, Result of validation.
    @example "RU09R02004("SM0", MV_PAR04)"
/*/
Function RU09R02004_ValidationFilial(cTableName,cFilialCode)
    Local lValid := .T. 	  As Logical
    Local aFilialCodes := {}  As Array
    Local nI := 0 			  As Numeric

    aFilialCodes := StrToKArr(cFilialCode, ";*-")

    If Empty(cFilialCode)
        lValid := .T.
    Else
        For nI := 1 To Len(aFilialCodes)
            If !Empty(aFilialCodes[nI])
                lValid := lValid .AND. ExistCpo(cTableName, cEmpAnt+aFilialCodes[nI], 1)
            EndIf
			If(!lValid)
				If !isblind() .and. (!lValid) 
					Help("",1,STR0043,,STR0042,1,0,,,,,,{""}) //Incorrect filial specified
				EndIf
				Exit
			EndIf
        Next nI
    EndIf

Return lValid

/*/{Protheus.doc} RU09R02005_ValidationPartner
    Function for validation of field "Code".
	
	in pergunte question "Supplier's code", "Client code"
    @type Function
    @param cPatnerCode, Character, Code like "01;02-04;".
		   cTableName, Character, Table name like "F42"
    @author eprokhorenko
    @since 15.11.2023
    @version 
    @return Logical, Result of validation.
    @example "RU09R02005("SA1", MV_PAR05)"
/*/
Function RU09R02005_ValidationPartner(cTableName,cPatnerCode)
    Local lValid := .T. 	  As Logical
    Local aPatnerCodes := {}  As Array
    Local nI := 0 			  As Numeric

	cPatnerCode := AllTrim(cPatnerCode)
    aPatnerCodes := StrToKArr(cPatnerCode, ";*-")

    If Empty(cPatnerCode)
        lValid := .T.
    Else

		//Create SQL query
		aArea := getArea()
		
		cQuery := " SELECT "
		If (cTableName == "SA1")
			cQuery += "A1_COD "
			cQuery += " FROM " + RetSqlName("SA1")
		ElseIf (cTableName == "SA2")
			cQuery += "A2_COD "
			cQuery += " FROM " + RetSqlName("SA2")
		EndIf
			cQuery += " WHERE D_E_L_E_T_ = '' "
		
		If (cTableName == "SA1")
			cQuery += " AND A1_COD IN( " 		
		ElseIf (cTableName == "SA2") 
			 cQuery += " AND A2_COD IN( "
		EndIf

		For nI := 1 To Len(aPatnerCodes)
			If !Empty(aPatnerCodes[nI])
				cQuery +=  "'" + AllTrim(aPatnerCodes[nI]) + "'" + IIF(nI != Len(aPatnerCodes), ", ", "")
			EndIf
		Next
		cQuery += " )"

		cQuery      := ChangeQuery(cQuery)
		cAliasTMP   := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
		DbSelectArea(cAliasTMP)

		aTempTabl := {}
		(cAliasTMP)->(dbGotop())

		While  (cAliasTMP)->(!EOF())
			If (cTableName == "SA1")
				aAdd(aTempTabl, (cAliasTMP)->A1_COD)
			ElseIf (cTableName == "SA2")
				aAdd(aTempTabl, (cAliasTMP)->A2_COD)
			EndIf

			(cAliasTMP)->(dbSkip())		
		EndDo

		(cAliasTMP)->(dbCloseArea())
		RestArea(aArea)

		For nI := 1 To Len(aPatnerCodes)
			If !Empty(aPatnerCodes[nI]) .AND. lValid
				nElem := AScan(aTempTabl, AllTrim(aPatnerCodes[nI]))
			
				if (nElem != 0)
					lValid := .T.
				Else
					lValid := .F.
					If !isblind() .and. (!lValid) 
						Help("",1,STR0045,,STR0044,1,0,,,,,,{""}) //Incorrect client code
					EndIf
				EndIf
			EndIf		
		Next
    EndIf

Return lValid

/*/{Protheus.doc} RU09R02006_ValidationUnitCode
    Function for validation of field "Code".
	
	in pergunte questions "Supplier's unit", "Client unit"
    @type Function
    @param cUnitCode, Character, Code like "00001;00002-00004;".
		   cTableName, Character, Table name like "F42"
    @author eprokhorenko
    @since 15.11.2023
    @version 
    @return Logical, Result of validation.
    @example "RU09R02006("SA2",MV_PAR05+MV_PAR06)"
/*/
Function RU09R02006_ValidationUnitCode(cTableName, cUnitCode)
    Local lValid := .T. 	  As Logical
    Local aUnitCodes := {}    As Array
    Local nI := 0 			  As Numeric
	Local aArea				  As Array
	Local nElem				  As Numeric

	cUnitCode := AllTrim(cUnitCode)
    aUnitCodes := StrToKArr(cUnitCode, ";*-")

    If Empty(cUnitCode)
        lValid := .T.
    Else
		//Create SQL query
		aArea := getArea()
		
		cQuery := " SELECT DISTINCT "
		If (cTableName == "SA1")
			cQuery += "A1_LOJA "
			cQuery += " FROM " + RetSqlName("SA1")
		ElseIf (cTableName == "SA2")
			cQuery += "A2_LOJA "
			cQuery += " FROM " + RetSqlName("SA2") 
		EndIf

		cQuery += " WHERE D_E_L_E_T_ = '' "
		If (cTableName == "SA1")
			cQuery += " AND A1_LOJA IN( " 		
		ElseIf (cTableName == "SA2") 
			 cQuery += " AND A2_LOJA IN( "
		EndIf

		For nI := 1 To Len(aUnitCodes)
			If !Empty(aUnitCodes[nI])
				cQuery +=  "'" + AllTrim(aUnitCodes[nI]) + "'" + IIF(nI != Len(aUnitCodes), ", ", "")
			EndIf
		Next
		cQuery += " )"

		cQuery      := ChangeQuery(cQuery)
		cAliasTMP   := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
		DbSelectArea(cAliasTMP)

		aTempTabl := {}
		(cAliasTMP)->(dbGotop())

		While  (cAliasTMP)->(!EOF())
			If (cTableName == "SA1")
				aAdd(aTempTabl, (cAliasTMP)->A1_LOJA)
			ElseIf (cTableName == "SA2")
				aAdd(aTempTabl, (cAliasTMP)->A2_LOJA)
			EndIf

			(cAliasTMP)->(dbSkip())		
		EndDo

		(cAliasTMP)->(dbCloseArea())
		RestArea(aArea)

		For nI := 1 To Len(aUnitCodes)
			If !Empty(aUnitCodes[nI]) .AND. lValid
				nElem := AScan(aTempTabl, aUnitCodes[nI])
			
				if (nElem != 0)
					lValid := .T.
				Else
					lValid := .F.
					If !isblind() .and. (!lValid) 
						Help("",1,STR0047,,STR0046,1,0,,,,,,{""}) //Invalid subdivision of client specified
					EndIf
				EndIf
			EndIf		
		Next
    EndIf

Return lValid

/*/{Protheus.doc} RU09R02008_DrawReportSalesBook
  Draw report Sales book using FwPrinterXlsx()
@type function
@author ekorneev
@since 22.11.23
@param  aHeaders as Array size 4 for filling header of report
		aTables as Array of Arrays, every line of aTables is line of report's table part
							for v1 need size 10 
		aFooter as Array for table bottom and footer of report
@return NIL
/*/
Function RU09R02008_DrawReportSalesBook(aHeaders, aTables, aFooter)

	Local cA1 			As Character
	Local cA2 			As Character
	Local cA3 			As Character
	Local nPp			As Numeric 
	Local nCntR := 10	As Numeric
	Local nCol			As Numeric
	Local oFArl6		As Object 
	Local oFArl8 		As Object
	Local oFArl14B 		As Object
	Local oFArl9 		As Object
	Local oFArl8B 		As Object
	Local oFArl9B		As Object
	Local oLocRTDT 		As Object
	Local oLocCTDT 		As Object
	Local oLocLCDT 		As Object
	Local oLocCCDT 		As Object
	Local oLocRCDT 		As Object
	Local oLocLBDT 		As Object
	Local oLocRBDT 		As Object
	Local nPosBorda		As Numeric
	Local nPosBordB     As Numeric
	Local nPosBordN		As Numeric
    Local cHeadAdd 		As Character
	Local nX			As Numeric
	Local aTableNum		As Array
	Local oFwXlsx 		As Object
	Local oCellHorAlign := FwXlsxCellAlignment():Horizontal()
	Local oCellVertAlign := FwXlsxCellAlignment():Vertical()
	Local cPath	:= ""	As Character
	Local cFile := ""	As Character
	Local lHtml         := (GetRemoteType() == 5) //Checks if the environment is SmartClientHtml

	DEFAULT aHeaders := {"", "", "", "", ""}
	DEFAULT aTables := {{"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""}}
	DEFAULT aFooter := {"", "", "", ""}

	cPATH_TITLE := STR0053 //Select folder for save
	cPath := cGetFile(, cPATH_TITLE, 0, "", .F., nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE, 128, 256),.T., .T. ) 
	If (Empty(cPath))
		If !isblind() 
			MSGINFO(STR0053)//Select folder
		EndIf
	ElseIf(cPath == "C:\")
		If !isblind()
			MSGINFO(STR0054 ) //Don't select the root directory, for example 'C:\'
		EndIf
	EndIf

If (!Empty(cPath) .AND. !(cPath == "C:\"))
	cFile:= cPath + "sales_book_" + FwTimeStamp(1)

	cHeadAdd := STR0001+Chr(13)+Chr(10) + STR0002

	aTableNum := {"1", "2", "3", "3à", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13à", "13á", "14","14à", "15", "16", "17", "17à", "18", "19", "20", "21", "22", "23"}
    
	cA1 := STR0004 + IIF( LEN(aHeaders) > 0, " " + aHeaders[1], "" )
	cA2 := STR0005 + IIF( LEN(aHeaders) > 1, " " + aHeaders[2], "" )
	cA3 := STR0006 + IIF( LEN(aHeaders) > 2, " " + aHeaders[3], "" ) +;
            IIF( LEN(aHeaders) > 3, " " + STR0007 + " " + aHeaders[4], "" )
	cA4 := IIF( LEN(aHeaders) > 4, STR0041 + " " + aHeaders[5], "" )
	
	// Create excel report
	oFwXlsx := FwPrinterXlsx():New(.T.)
	oFwXlsx:Activate(cFile)
	
	//Add new sheet
	oFwXlsx:AddSheet("TDSheet")
	//Set Width Columns 
	oFwXlsx:SetColumnsWidth(1,1,4.29)
	oFwXlsx:SetColumnsWidth(2,2,4.86)
	oFwXlsx:SetColumnsWidth(3,3,17.71)
	oFwXlsx:SetColumnsWidth(4,4,7.00)
	oFwXlsx:SetColumnsWidth(5,5,12.29)
	oFwXlsx:SetColumnsWidth(6,6,12.57)
	oFwXlsx:SetColumnsWidth(7,7,14.86)
	oFwXlsx:SetColumnsWidth(8,8,19.00)
	oFwXlsx:SetColumnsWidth(9,9,10.29)
	oFwXlsx:SetColumnsWidth(10,10,17.14)
	oFwXlsx:SetColumnsWidth(11,11,10.29)
	oFwXlsx:SetColumnsWidth(12,12,11.29)
	oFwXlsx:SetColumnsWidth(13,13,8.14)
	oFwXlsx:SetColumnsWidth(14,14,14.14)
	oFwXlsx:SetColumnsWidth(15,15,14.14)
	oFwXlsx:SetColumnsWidth(16,16,14.14)
	oFwXlsx:SetColumnsWidth(17,17,14.14)
	oFwXlsx:SetColumnsWidth(18,18,14.14)
	oFwXlsx:SetColumnsWidth(19,19,14.14)
	oFwXlsx:SetColumnsWidth(20,20,14.14)
	oFwXlsx:SetColumnsWidth(21,21,14.14)
	oFwXlsx:SetColumnsWidth(22,22,14.14)
	oFwXlsx:SetColumnsWidth(23,23,15.43)
	oFwXlsx:SetColumnsWidth(24,24,23.14)
	oFwXlsx:SetColumnsWidth(25,25,15.71)
	oFwXlsx:SetColumnsWidth(26,26,16.14)
	oFwXlsx:SetColumnsWidth(27,27,16.14)
	// Fill fonts
	oFArl8 := FwXlsxPrinterConfig():MakeFont()
	oFArl8['font'] := FwPrinterFont():Arial()
	oFArl8['size'] := 8
	oFArl8['bold'] := .F.
	oFArl8['underline'] := .F.
	oFArl14B := FwXlsxPrinterConfig():MakeFont()
	oFArl14B['font'] := FwPrinterFont():Arial()
	oFArl14B['size'] := 14
	oFArl14B['bold'] := .T.
	oFArl14B['underline'] := .F.
	oFArl9 := FwXlsxPrinterConfig():MakeFont()
	oFArl9['font'] := FwPrinterFont():Arial()
	oFArl9['size'] := 9
	oFArl9['bold'] := .F.
	oFArl9['underline'] := .F.
	oFArl6 := FwXlsxPrinterConfig():MakeFont()
	oFArl6['font'] := FwPrinterFont():Arial()
	oFArl6['size'] := 6
	oFArl6['bold'] := .F.
	oFArl6['underline'] := .F.
	oFArl8B := FwXlsxPrinterConfig():MakeFont()
	oFArl8B['font'] := FwPrinterFont():Arial()
	oFArl8B['size'] := 8
	oFArl8B['bold'] := .T.
	oFArl8B['underline'] := .F.
	oFArl9B := FwXlsxPrinterConfig():MakeFont()
	oFArl9B['font'] := FwPrinterFont():Arial()
	oFArl9B['size'] := 9
	oFArl9B['bold'] := .T.
	oFArl9B['underline'] := .F.
	
	// Fill borders
	nPosBorda := FwXlsxPrinterConfig():MakeBorder()
	nPosBorda['top'] := .T.
	nPosBorda['bottom'] := .T.
	nPosBorda['right'] := .T.
	nPosBorda['left'] := .T.
	nPosBorda['border_color'] := "000000"
	nPosBorda['style'] := FwXlsxBorderStyle():Thin()
	nPosBordB := FwXlsxPrinterConfig():MakeBorder()
	nPosBordB['bottom'] := .T.
	nPosBordB['border_color'] := "000000"
	nPosBordB['style'] := FwXlsxBorderStyle():Thin()
	nPosBordN := FwXlsxPrinterConfig():MakeBorder()
	nPosBordN['top'] := .F.
	nPosBordN['bottom'] := .F.
	nPosBordN['right'] := .F.
	nPosBordN['left'] := .F.
	nPosBordN['style'] := FwXlsxBorderStyle():None()
	// Fill alignments
	oLocRTDT := FwXlsxPrinterConfig():MakeFormat()
	oLocRTDT['hor_align'] := oCellHorAlign:Right()
	oLocRTDT['vert_align'] := oCellVertAlign:Top()
	oLocRTDT['text_wrap'] := .T.
	oLocRTDT['custom_format'] := "#,##0.00"
	oLocCTDT := FwXlsxPrinterConfig():MakeFormat()
	oLocCTDT['hor_align'] := oCellHorAlign:Center()
	oLocCTDT['vert_align'] := oCellVertAlign:Top()
	oLocCTDT['text_wrap'] := .T.
	
	oLocLCDT := FwXlsxPrinterConfig():MakeFormat()
	oLocLCDT['hor_align'] := oCellHorAlign:Left()
	oLocLCDT['vert_align'] := oCellVertAlign:Center()
	oLocLCDT['text_wrap'] := .T.
	oLocCCDT := FwXlsxPrinterConfig():MakeFormat()
	oLocCCDT['hor_align'] := oCellHorAlign:Center()
	oLocCCDT['vert_align'] := oCellVertAlign:Center()
	oLocCCDT['text_wrap'] := .T.
	oLocRCDT := FwXlsxPrinterConfig():MakeFormat()
	oLocRCDT['hor_align'] := oCellHorAlign:Right()
	oLocRCDT['vert_align'] := oCellVertAlign:Center()
	oLocRCDT['text_wrap'] := .T.
	oLocRCDT['custom_format'] := "#,##0.00"
	oLocLBDT := FwXlsxPrinterConfig():MakeFormat()
	oLocLBDT['hor_align'] := oCellHorAlign:Left()
	oLocLBDT['vert_align'] := oCellVertAlign:Bottom()
	oLocLBDT['text_wrap'] := .T.
	oLocRBDT := FwXlsxPrinterConfig():MakeFormat()
	oLocRBDT['hor_align'] := oCellHorAlign:Right()
	oLocRBDT['vert_align'] := oCellVertAlign:Bottom()
	oLocRBDT['text_wrap'] := .T.
	
	// Fill header
	oFwXlsx:SetCellsFormatConfig(oLocRTDT)
	oFwXlsx:SetFontConfig(oFArl8)
	oFwXlsx:SetRowsHeight(1, 1, 32.25)
	oFwXlsx:MergeCells(1, 1, 1, 23)
	oFwXlsx:SetText(1, 1, cHeadAdd)
	
	oFwXlsx:SetCellsFormatConfig(oLocCTDT)
	oFwXlsx:SetFontConfig(oFArl14B)
	oFwXlsx:SetRowsHeight(2, 2, 18)
	oFwXlsx:MergeCells(2, 1, 2, 23)
	oFwXlsx:SetText(2, 1, STR0003)
	
	oFwXlsx:SetCellsFormatConfig(oLocLBDT)
	oFwXlsx:SetFontConfig(oFArl9)
	oFwXlsx:SetRowsHeight(3, 7, 15)
	oFwXlsx:MergeCells(4, 1, 4, 23)
	oFwXlsx:SetText(4, 1, cA1)
	
	oFwXlsx:SetCellsFormatConfig(oLocLBDT)
	oFwXlsx:SetFontConfig(oFArl9)
	oFwXlsx:MergeCells(5, 1, 5, 23)
	oFwXlsx:SetText(5, 1, cA2)
	
	oFwXlsx:SetCellsFormatConfig(oLocLBDT)
	oFwXlsx:SetFontConfig(oFArl9)
	oFwXlsx:MergeCells(6, 1, 6, 23)
	oFwXlsx:SetText(6, 1, cA3)
	
	oFwXlsx:SetCellsFormatConfig(oLocLBDT)
	oFwXlsx:SetFontConfig(oFArl9)
	oFwXlsx:SetRowsHeight(7, 7, 27.75)
	oFwXlsx:MergeCells(7, 1, 7, 9)
	oFwXlsx:SetText(7, 1, cA4)
	
	// Fill table's header
	oFwXlsx:SetRowsHeight(8, 8, 34.50)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 1, 9, 1)
	oFwXlsx:SetValue(8, 1, STR0008)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 2, 9, 2)
	oFwXlsx:SetValue(8, 2, STR0009)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 3, 9, 3)
	oFwXlsx:SetValue(8, 3, STR0010)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 4, 9, 4)
	oFwXlsx:SetValue(8, 4, STR0011)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 5, 9, 5)
	oFwXlsx:SetValue(8,5,STR0012)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 6, 9, 6)
	oFwXlsx:SetValue(8, 6, STR0013)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 7, 9, 7)
	oFwXlsx:SetValue(8, 7, STR0014)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 8, 9, 8)
	oFwXlsx:SetValue(8, 8, STR0015)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 9, 9, 9)
	oFwXlsx:SetValue(8, 9, STR0016)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 10, 8, 11)
	oFwXlsx:SetValue(8, 10, STR0017)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:ApplyFormat(8, 11)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 12, 9, 12)
	oFwXlsx:SetValue(8, 12, STR0020)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 13, 9, 13)
	oFwXlsx:SetValue(8, 13, STR0021)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 14, 8, 15)
	oFwXlsx:SetValue(8, 14, STR0022)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:ApplyFormat(8, 15)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 16, 8, 19)
	oFwXlsx:SetValue(8, 16, STR0025)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:ApplyFormat(8, 17)
	oFwXlsx:ApplyFormat(8, 18)
	oFwXlsx:ApplyFormat(8, 19)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 20, 8, 22)
	oFwXlsx:SetValue(8, 20, STR0030)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:ApplyFormat(8, 21)
	oFwXlsx:ApplyFormat(8, 22)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 23, 9, 23)
	oFwXlsx:SetValue(8, 23, STR0031)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 24, 9, 24)
	oFwXlsx:SetValue(8, 24, STR0032)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 25, 9, 25)
	oFwXlsx:SetValue(8, 25, STR0033)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 26, 9, 26)
	oFwXlsx:SetValue(8, 26, STR0034)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(8, 27, 9, 27)
	oFwXlsx:SetValue(8, 27, STR0035)
	
	oFwXlsx:SetRowsHeight(9, 9, 74.25)
	FOR nPp := 1 TO 9
		oFwXlsx:SetCellsFormatConfig(oLocCCDT)
		oFwXlsx:SetFontConfig(oFArl8B)
		oFwXlsx:SetBorderConfig(nPosBorda)
		oFwXlsx:ApplyFormat(9, nPp)
	NEXT
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 10, STR0018)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 11, STR0019)
	
	FOR nPp := 12 TO 13
		oFwXlsx:SetCellsFormatConfig(oLocCCDT)
		oFwXlsx:SetFontConfig(oFArl8B)
		oFwXlsx:SetBorderConfig(nPosBorda)
		oFwXlsx:ApplyFormat(9, nPp)
	NEXT
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 14, STR0023)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 15, STR0024)
	
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 16, STR0026)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 17, STR0027)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 18, STR0028)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 19, STR0029)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 20, STR0026)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 21, STR0027)
	oFwXlsx:SetCellsFormatConfig(oLocCCDT)
	oFwXlsx:SetFontConfig(oFArl8B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(9, 22, STR0028)
	
	FOR nPp := 23 TO 27
		oFwXlsx:SetCellsFormatConfig(oLocCCDT)
		oFwXlsx:SetFontConfig(oFArl8B)
		oFwXlsx:SetBorderConfig(nPosBorda)
		oFwXlsx:ApplyFormat(9, nPp)
	NEXT
	
	oFwXlsx:SetRowsHeight(10,10,15.00)
	FOR nPp := 1 TO 27
		
		oFwXlsx:SetCellsFormatConfig(oLocCCDT)
		oFwXlsx:SetFontConfig(oFArl8B)
		oFwXlsx:SetBorderConfig(nPosBorda)
		oFwXlsx:SetValue(10, nPp, aTableNum[nPp])
	NEXT
	oFwXlsx:SetRowsHeight(nCntR+1, nCntR+LEN(aTables), 23.50)
	
	nSavePos := 1
	FOR nPp := 1 TO LEN(aTables)
	
	//Merge cells if number of identical cells > 1
		If nPp<> 1
			if aTables[nPp][1] <> aTables[nPp-1][1] 
				if nSavePos <> nPp-1
					For nX := 1 To 23
						oFwXlsx:MergeCells(nSavePos+10, nX, nPp+10-1, nX)
					Next
				EndIf
				nSavePos := nPp
			EndIf
			If nPp == LEN(aTables)
				if nSavePos <> nPp
					For nX := 1 To 23
						oFwXlsx:MergeCells(nSavePos+10, nX, nPp+10, nX)
					Next
				EndIf
			EndIf
		EndIf
		nCntR += 1
		nCol := 0
		
		// filling table according to requirements of specification
		//1 - Column 1 - Item number, auto incrementation 
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][1]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 0, aTables[nPp][1], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//2 - Column 2 - Code of the type of operation 
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][2]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 1, aTables[nPp][2], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//3 - Column 3 - VAT invoice number and date F54_DOC and F54_PDATE, separated by a semicolon ";"
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][3]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 2, aTables[nPp][3], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//4 - Column 3a - EAEC product type code. Not filled in in this version
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		oFwXlsx:ApplyFormat(nCntR,(nCol+=1))
		
		//5 - Column 4 - Buyer's invoice number and date of correction F54_ADJNR and F54_ADJDT, separated by a semicolon ";"
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][4]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 3, aTables[nPp][4], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//6 - Column 5 - Seller's adjustment invoice number and date
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		oFwXlsx:ApplyFormat(nCntR,(nCol+=1))
		
		//7 - Column 6 - Seller's adjustment invoice number and date of correction
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		oFwXlsx:ApplyFormat(nCntR,(nCol+=1))
		
		//8 - Column 7 - Buyer's short name A1_NREDUZ 
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][5]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 4, aTables[nPp][5], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//9 - Column 8 - INN code from Buyer's card A1_CODZON; KPP code from VAT invoice  F35_KPP_CL separated by slash "/"
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][6]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 5, aTables[nPp][6], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//10 - Column 9 - Name of the intermediary
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		oFwXlsx:ApplyFormat(nCntR,(nCol+=1))
		
		//11 - Column 10 - INN/KPP of the intermediary
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		oFwXlsx:ApplyFormat(nCntR,(nCol+=1))
		
		//12 - Column 11 - Number and date of the document confirming payment
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][7]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 6,  aTables[nPp][7] , ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//13 - Column 12 - Currency F35_INVCUR
		oFwXlsx:SetCellsFormatConfig(oLocCTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][8]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 7,  aTables[nPp][8] , ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//14 - Column 13a - Gross value for VAT invoice in VAT invoice102030
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][9]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 8,  aTables[nPp][9] , ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//15 - Column 13b - Total F35_VATBS1+F35_VATVL1
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][10]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 9,  aTables[nPp][10], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//16 - Column 14 - VAT base in rubles at a rate of 20%
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][11]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 10, aTables[nPp][11], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		//17 - Column 14a - VAT base in rubles at a rate of 18%
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][12]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 11, aTables[nPp][12], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//18 - Column 15 - VAT base in rubles at a rate of 10%
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][13]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 12, aTables[nPp][13], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//19 - Column 16 - VAT base in rubles at a rate of 0%
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][14]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 13, aTables[nPp][14], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//20 - Column 17 -VAT amount at 20% rate
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][15]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 14, aTables[nPp][15], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//21 - Column 17a -VAT amount at 18% rate
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][16]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 15, aTables[nPp][16], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//22 - Column 18 - VAT amount at 10% rate
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][17]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 16, aTables[nPp][17], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//23 - Column 19 - VAT base in rubles for VAT  0% (Column 19 in the sales book)
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][18]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 17, aTables[nPp][18], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//24 - Column 20 - RNPT External Number 
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][19]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 18, aTables[nPp][19], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		//25 - Column 21 - Unit of measure
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][20]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 19, aTables[nPp][20], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//26 - Column 22 - Quantity
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][21]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 20, aTables[nPp][21], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
		
		//27 - Column 23 - Cost of RNPT
		oFwXlsx:SetCellsFormatConfig(oLocRTDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBorda)
		If (!Empty(aTables[nPp][22]))
			oFwXlsx:SetValue(nCntR, (nCol+=1), IIF(ValType(aTables[nPp])=="A" .and. LEN(aTables[nPp]) > 21, aTables[nPp][22], ""))
		Else
			oFwXlsx:SetText(nCntR, (nCol+=1), "")
		EndIf
	NEXT 
	
	nCntR += 1
	oFwXlsx:SetRowsHeight(nCntR, nCntR, 15.00)
	
	oFwXlsx:SetCellsFormatConfig(oLocRCDT)
	oFwXlsx:SetFontConfig(oFArl9B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:MergeCells(nCntR,1,nCntR,15)
	oFwXlsx:SetText(nCntR, 1, STR0036)
	
	FOR nPp := 2 TO 15
		oFwXlsx:SetCellsFormatConfig(oLocRCDT)
		oFwXlsx:SetFontConfig(oFArl9B)
		oFwXlsx:SetBorderConfig(nPosBorda)
		oFwXlsx:ApplyFormat(nCntR,nPp)
	NEXT
	
	// filling total of table according to specification
	//1 - Total VAT base in rubles at a rate of 20%
	oFwXlsx:SetCellsFormatConfig(oLocRCDT)
	oFwXlsx:SetFontConfig(oFArl9B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(nCntR, 16, IIF(ValType(aFooter)=="A" .and. LEN(aFooter) > 0, aFooter[1], ""))
	//2 - Total VAT base in rubles at a rate of 18%
	oFwXlsx:SetCellsFormatConfig(oLocRCDT)
	oFwXlsx:SetFontConfig(oFArl9B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(nCntR, 17, IIF(ValType(aFooter)=="A" .and. LEN(aFooter) > 1, aFooter[2], ""))
	//3 - Total VAT base in rubles at a rate of 10%
	oFwXlsx:SetCellsFormatConfig(oLocRCDT)
	oFwXlsx:SetFontConfig(oFArl9B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(nCntR, 18, IIF(ValType(aFooter)=="A" .and. LEN(aFooter) > 2, aFooter[3], ""))
	//4 - Total VAT base in rubles at a rate of 0%
	oFwXlsx:SetCellsFormatConfig(oLocRCDT)
	oFwXlsx:SetFontConfig(oFArl9B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(nCntR, 19, IIF(ValType(aFooter)=="A" .and. LEN(aFooter) > 3, aFooter[4], ""))
	//5 - VAT amount at 20% rate
	oFwXlsx:SetCellsFormatConfig(oLocRCDT)
	oFwXlsx:SetFontConfig(oFArl9B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(nCntR, 20, IIF(ValType(aFooter)=="A" .and. LEN(aFooter) > 4, aFooter[5], ""))
	//6 - VAT amount at 18% rate
	oFwXlsx:SetCellsFormatConfig(oLocRCDT)
	oFwXlsx:SetFontConfig(oFArl9B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(nCntR, 21, IIF(ValType(aFooter)=="A" .and. LEN(aFooter) > 5, aFooter[6], ""))
	//7 - VAT amount at 10% rate
	oFwXlsx:SetCellsFormatConfig(oLocRCDT)
	oFwXlsx:SetFontConfig(oFArl9B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(nCntR, 22, IIF(ValType(aFooter)=="A" .and. LEN(aFooter) > 6, aFooter[7], ""))
	//8 - Total VAT base in rubles at a rate of 0% (Column 19
	oFwXlsx:SetCellsFormatConfig(oLocRCDT)
	oFwXlsx:SetFontConfig(oFArl9B)
	oFwXlsx:SetBorderConfig(nPosBorda)
	oFwXlsx:SetValue(nCntR, 23, IIF(ValType(aFooter)=="A" .and. LEN(aFooter) > 7, aFooter[8], ""))
	oFwXlsx:SetRowsHeight(nCntR+1, nCntR+7, 15.00)
	
	nCntR += 3
	oFwXlsx:SetCellsFormatConfig(oLocLBDT)
	oFwXlsx:SetFontConfig(oFArl9)
	oFwXlsx:SetBorderConfig(nPosBordN)
	oFwXlsx:MergeCells(nCntR, 1, nCntR, 5)
	oFwXlsx:MergeCells(nCntR, 7, nCntR, 8)
	oFwXlsx:SetValue(nCntR, 1, STR0037)
	oFwXlsx:SetCellsFormatConfig(oLocCTDT)
	oFwXlsx:SetFontConfig(oFArl6)
	oFwXlsx:SetValue(nCntR+1, 7, STR0048)
	oFwXlsx:SetValue(nCntR+1, 12, STR0040)
	
	oFwXlsx:SetCellsFormatConfig(oLocLBDT)
	oFwXlsx:SetFontConfig(oFArl9)
	oFwXlsx:SetBorderConfig(nPosBordB)
	oFwXlsx:ApplyFormat(nCntR,7)
	oFwXlsx:ApplyFormat(nCntR,8)
	//9 - Head of the company
	oFwXlsx:SetCellsFormatConfig(oLocLBDT)
	oFwXlsx:SetFontConfig(oFArl9)
	oFwXlsx:SetBorderConfig(nPosBordB)
	oFwXlsx:SetValue(nCntR, 10, IIF(ValType(aFooter)=="A" .and. LEN(aFooter) > 8, aFooter[9], ""))
	FOR nPp := 11 TO 14
		oFwXlsx:SetCellsFormatConfig(oLocLBDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBordB)
		oFwXlsx:ApplyFormat(nCntR,nPp)
	NEXT
	
	nCntR += 2
	oFwXlsx:SetCellsFormatConfig(oLocLBDT)
	oFwXlsx:SetFontConfig(oFArl9)
	oFwXlsx:SetBorderConfig(nPosBordN)
	oFwXlsx:MergeCells(nCntR,1,nCntR,6)
	oFwXlsx:MergeCells(nCntR,8,nCntR,14)
	oFwXlsx:SetValue(nCntR, 1, STR0038)
	oFwXlsx:SetCellsFormatConfig(oLocCTDT)
	oFwXlsx:SetFontConfig(oFArl6)
	oFwXlsx:SetValue(nCntR+1, 11, STR0040)
	FOR nPp := 8 TO 14
		oFwXlsx:SetCellsFormatConfig(oLocLBDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBordB)
		oFwXlsx:ApplyFormat(nCntR,nPp)
	NEXT
	nCntR += 2
	
	oFwXlsx:SetCellsFormatConfig(oLocLBDT)
	oFwXlsx:SetFontConfig(oFArl9)
	oFwXlsx:SetBorderConfig(nPosBordN)
	oFwXlsx:MergeCells(nCntR, 1, nCntR, 7)
	oFwXlsx:MergeCells(nCntR, 9, nCntR, 14)
	oFwXlsx:SetValue(nCntR, 1, STR0039)
	
	//10 - if the company is an individual entrepreneur 
	oFwXlsx:SetCellsFormatConfig(oLocLBDT)
	oFwXlsx:SetFontConfig(oFArl9)
	oFwXlsx:SetBorderConfig(nPosBordB)
	oFwXlsx:SetValue(nCntR, 9, IIF(ValType(aFooter)=="A" .and. LEN(aFooter) > 9, aFooter[10], ""))
	
	FOR nPp := 10 TO 14
		oFwXlsx:SetCellsFormatConfig(oLocLBDT)
		oFwXlsx:SetFontConfig(oFArl9)
		oFwXlsx:SetBorderConfig(nPosBordB)
		oFwXlsx:ApplyFormat(nCntR,nPp)
	NEXT
	oFwXlsx:toXlsx()
	oFwXlsx:Deactivate()
	If(!lHtml)
		StaticCall(RU09XXXFUN, OpenFileExcel, cFile)
	EndIf
	If !isblind() 
			MSGINFO(STR0049 + Chr(13) + Chr(10) + cPath + Chr(13) + Chr(10) + STR0050 + " " + STUFF(cFile,1,Len(cPath), ""),;
			STR0051 + " " + Chr(13) + Chr(10) + STR0052 ) //Report completed
	EndIf
EndIf

RETURN NIL
                   
//Merge Russia R14 
                   
