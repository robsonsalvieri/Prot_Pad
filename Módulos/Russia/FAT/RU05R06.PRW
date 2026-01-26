#INCLUDE "PROTHEUS.CH"
#include "RU02R02.CH"

/*/
{Protheus.doc} RU05R06()
    Entry point to run the routine.
    @type Function
    @params 
    @author eprokhorenko
    @since 9/8/2023
    @version 
    @return 
    @example RU05R06()
/*/
Function RU05R06()

    Local lRet          As Logical
    Local aSigners      As Array
    Local cNotIni       As Character 
    Local cNotFil       As Character    //branch of positioned record
 
    cNotIni := F35->F35_KEY
    cNotFil := F35->F35_FILIAL

    aSigners := {}
    lRet    :=  Pergunte("RU05R03", .T.)
    If(lRet)
        aAdd(aSigners, MV_PAR01)
        aAdd(aSigners, MV_PAR02)
    
        If !isblind() .and. (Empty(aSigners[1]) .or. Empty(aSigners[2])) 
            Help("",1,STR0017,,STR0018,1,0,,,,,,{""}) //Report signers not specified
        EndIf

        GetDataInv(cNotIni,cNotFil,aSigners)
    EndIf
Return .T.


/*/
{Protheus.doc} GetDataInv()
    Here the data is selected, filled and distributed according to the template.
    @type Function
    @params cNotIni Char -key invoice,
            cNotFil Char - Filial,
            aSigners Array - signers
    @author eprokhorenko
    @since 9/8/2023
    @version 
    @return 
    @example GetDataInv(cNotIni,cNotFil,aSigners)
/*/

    Static Function GetDataInv(cNotIni,cNotFil,aSigners)

    Local oModel            As Object
    Local oModelF35         As Object  
    Local oModelF36         As Object 
    Local cDirector         As Character
    Local cCHIEFBUH         As Character
    Local aArea             As Array
    Local nX                As Numeric 
    Local cF5Pdocuments     As Character
    Local cF35DocNumb       As Character
    Local cPrintDate        As Character
    Local cCnorCodent       As Character
    Local cCneeCodent       As Character
    Local cConsignee        As Character
    Local cConsignor        As Character
    Local cByer             As Character
    Local cByerodent        As Character 
    Local cByerCod          As Character
    Local cByername         As Character
    Local cByerAdress       As Character
    Local cByerINNKPP       As Character
    Local cMoeda            As Character
    Local cMoedaCode        As Character
    Local cContract         As Character
    Local cMyComName        As Character
    Local cMyComAdrs        As Character
    Local cMyINNKPP         As Character
    Local cQuery            As Character
    Local cAliasTMP         As Character
    Local lPrint            As Logical
    Local cFdescr           As Character
    Local cB6Vunit          As Character
    Local cComPar           As Character
    Local nVatBS            As Numeric
    Local nVatVl            As Numeric
    Local nValGr            As Numeric
    Local nCountStr         As Numeric
    Local aBlock_0          As Array
    Local aBlock_1          As Array
    Local aBlock_2          As Array 
    Local lRepeatShD        As Logical
    Local aAreaSa2          As Array
    Local aAreaSa1          As Array
    Local aAreaCTO          As Array
    Local cDocF36           As Character
    Local aCompanyInfo:= {} As Array
    Local aBranchInfo := {} As Array

    lRepeatShD := .F.
    cComPar     := Alltrim(SuperGetMv("MV_CMPLVL",.F.,""))
    cByername   := ""
    oModel      := FwLoadModel("RU09T02")
    oModel:Activate()

    oModelF35 := oModel:GetModel("F35MASTER")
    oModelF36 := oModel:GetModel("F36DETAIL")
    oModelF5P := oModel:GetModel("F5PDETAIL")

    //payment document: number, from.
    cF5Pdocuments := ""
    If !EMPTY(oModelF5P:GetValue("F5P_ADVDOC"))
        For nX := 1 to oModelF5P:Length()
                oModelF5P:GoLine(nX)
                    cF5Pdocuments += ", "+ STR0019 + " " + ALLTRIM(oModelF5P:GetValue("F5P_ADVDOC")) +  " " + STR0014 + " "+  FormatDate(oModelF5P:GetValue("F5P_ADVDT"))
        Next nX
        cF5Pdocuments := SUBSTR(cF5Pdocuments,2,LEN(cF5Pdocuments)-1)
    Else 
        cF5Pdocuments := "  --  "
    EndIf

    //main information about numbers and dates
    cF35DocNumb := oModelF35:GetValue("F35_DOC")
    cF35DocDate := FormatDate(oModelF35:GetValue("F35_PDATE"))
    cF35AdjNum  := oModelF35:GetValue("F35_ADJNR")
    cF35AdjDate := FormatDate(oModelF35:GetValue("F35_ADJDT"))
    cPrintDate  := IIF(!Empty(oModelF35:GetValue("F35_ADJDT")),DTOS(oModelF35:GetValue("F35_ADJDT")),DTOS(oModelF35:GetValue("F35_PDATE"))) //the date for check adresses and signers
    cF35AdjNum  := IIF(!Empty(cF35AdjNum),cF35AdjNum,"--")
    cF35AdjDate := IIF(!Empty(cF35AdjDate),cF35AdjDate,"--")

    cDirector   := GetSigner(aSigners[1],cPrintDate)
    cCHIEFBUH   := GetSigner(aSigners[2],cPrintDate)

    //Consignor: 1-seller, 2-another
    aAreaSa2 := SA2->(GetArea())
    If oModelF35:GetValue("F35_CNRVEN") == "1"
        cConsignor  := alltrim(GetCoBrRUS()[2][6][2])  + ", " +GettFullAdress("SM0",GetMyAgacodent(3),"2",cPrintDate)
    ElseIf oModelF35:GetValue("F35_CNRVEN") == "2"
        cCnorCodent := XFilial("SA2")+oModelF35:GetValue("F35_CNOR_C")+oModelF35:GetValue("F35_CNOR_B")
        cConsignor  := alltrim(Posicione("SA2", 1, cCnorCodent, "A2_NOME")) + ", " + GettFullAdress("SA2",cCnorCodent,"2",cPrintDate)
    Endif
    RestArea(aAreaSa2)

    //Consignee: 1-byer, 2-another
     aAreaSa1 := SA1->(GetArea())
    If oModelF35:GetValue("F35_CNECLI") == "1"
        cCneeCodent := XFilial("SA1")+oModelF35:GetValue("F35_CLIENT")+oModelF35:GetValue("F35_BRANCH")
        cConsignee  := alltrim(Posicione("SA1", 1, cCneeCodent, "A1_NOME")) + ", " + GettFullAdress("SA1",cCneeCodent,"2",cPrintDate)
    ElseIf oModelF35:GetValue("F35_CNECLI") == "2"
        cCneeCodent := XFilial("SA1")+oModelF35:GetValue("F35_CNEE_C")+oModelF35:GetValue("F35_CNEE_B")
        cConsignee  := alltrim(Posicione("SA1", 1, cCneeCodent, "A1_NOME"))+ ", " + GettFullAdress("SA1",cCneeCodent,"2",cPrintDate)
    Endif

    //Byer may be headquater 
    cByername   := " "
    cByerCod    := FindHeadQuoter(oModelF35:GetValue("F35_CLIENT"),oModelF35:GetValue("F35_BRANCH"))
    cByerodent  := XFilial("SA1")+cByerCod+ oModelF35:GetValue("F35_BRANCH")
    DbSelectArea("SA1")
    dbSetOrder(1)
        If dbseek(XFilial("SA1")+cByerCod+oModelF35:GetValue("F35_BRANCH"))
            cByername := AllTrim(SA1->A1_NOME)
        EndIf 
    cByer       := cByername 
    cByerAdress := GettFullAdress("SA1",cByerodent,"0",cPrintDate)
    cByerINNKPP := AllTrim(Posicione("SA1", 1, cByerodent, "A1_CODZON")) + IIF(!EMPTY(alltrim(oModelF35:GetValue("F35_KPP_CL"))),"/"+ alltrim(oModelF35:GetValue("F35_KPP_CL")),"") //should we take KPP of headquater?
    cContract   := AllTrim(oModelF35:GetValue("F35_GOVCTR"))
    RestArea(aAreaSa1)

    cMyINNKPP   := ""
    cMyComName  := ""
    cMyComAdrs  := ""

    DO CASE 
    
        CASE cValToChar(VAL(cComPar)-1) == '2' // Buisness unit.
            aCompanyInfo := RU05R06001_GetCompanyInfo('2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R06002_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            cMyComName  := aCompanyInfo[1]
            cMyINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])

            cMyComAdrs  := GettFullAdress("SM0",GetMyAgacodent(2),"0",cPrintDate)

        CASE cValToChar(VAL(cComPar)-1) == '1' // Company.
            aCompanyInfo := RU05R06001_GetCompanyInfo('1', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R06002_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            cMyComName  := aCompanyInfo[1]
            cMyINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])

            cMyComAdrs  := GettFullAdress("SM0",GetMyAgacodent(1),"0",cPrintDate)

        CASE cValToChar(VAL(cComPar)-1) == '0' // Group company.
            aCompanyInfo := RU05R06001_GetCompanyInfo('0', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R06002_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            cMyComName  := aCompanyInfo[1]
            cMyINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
 
            cMyComAdrs  := GettFullAdress("SM0",GetMyAgacodent(0),"0",cPrintDate) 
            
    ENDCASE

    aAreaCTO := CTO->(GetArea())
    cMoedaCode  := AllTrim(Posicione("CTO",1,xFilial("CTO")+oModelF35:GetValue("F35_INVCUR"),"CTO_CODISO"))
    cMoeda      := AllTrim(Posicione("CTO",1,xFilial("CTO")+oModelF35:GetValue("F35_INVCUR"),"CTO_RDESC")) + ", " + cMoedaCode
    RestArea(aAreaCTO)

    aBlock_0 := {}
        
    // Create data block0
    aAdd(aBlock_0, cF35DocNumb  ) //F35_DOC   
    aAdd(aBlock_0, cF35DocDate  ) //F35_PDATE 
    aAdd(aBlock_0, cF35AdjNum   ) //F35_ADJNR  
    aAdd(aBlock_0, cF35AdjDate  ) //F35_ADJDT 
    aAdd(aBlock_0, cMyComName   ) //CO_FULLNAM 
    aAdd(aBlock_0, cMyComAdrs   ) //AGA_FULL   
    aAdd(aBlock_0, cMyINNKPP    ) //F35_KPP_CO
    aAdd(aBlock_0, cConsignor   ) //F35_CNOR_C
    aAdd(aBlock_0, cConsignee   ) //F35_CNEE_C
    aAdd(aBlock_0, cF5Pdocuments) //F5P_ADVDOC
    aAdd(aBlock_0, ' '          ) //F5P_ADVDT
    aAdd(aBlock_0, cByername    ) //A1_NOME
    aAdd(aBlock_0, cByerAdress  ) //AGA_FULL
    aAdd(aBlock_0, cByerINNKPP  ) //F35_KPP_CL
    aAdd(aBlock_0, cMoeda       ) //CTO_RDESC   
    aAdd(aBlock_0, cContract    ) //F35_GOVCTR

    //--------calculated values for footer 
    If cMoedaCode == "643"
        nVatBS := oModelF35:GetValue("F35_VATBS1")
        nVatVl := oModelF35:GetValue("F35_VATVL1")
        nValGr := nVatBS + nVatVl
    Else 
        nVatBS := oModelF35:GetValue("F35_VATBS")
        nVatVl := oModelF35:GetValue("F35_VATVL")
        nValGr := oModelF35:GetValue("F35_VALGR")
    Endif

    // Create data block2
    aBlock_1 := {}
    aAdd(aBlock_1, Transform(nVatBS, GetSx3Cache( "F35_VATBS", "X3_PICTURE" )))//F35_VATBS
    aAdd(aBlock_1, Transform(nVatVl, GetSx3Cache( "F35_VATVL", "X3_PICTURE" )))//F35_VATVL
    aAdd(aBlock_1, Transform(nValGr, GetSx3Cache( "F35_VALGR", "X3_PICTURE" )))//F35_VALGR
    aAdd(aBlock_1, AllTrim(cDirector)) //cDirector
    aAdd(aBlock_1, AllTrim(cCHIEFBUH)) //cCHIEFBUH

    oModel:DeActivate()

    aArea := getArea()
    //details of print form, query used because of sb1
	cQuery := " SELECT * FROM " + RetSqlName("F36") + " AS F36"
	
	cQuery += " INNER JOIN " + RetSqlName("F31") + " AS F31"
	cQuery += " ON F31.F31_CODE = F36.F36_VATCOD"
	cQuery += " AND F31.D_E_L_E_T_ = F36.D_E_L_E_T_"
    
	cQuery += " INNER JOIN " + RetSqlName("F30") + " AS F30"
	cQuery += " ON F30.F30_CODE = F31.F31_RATE"
	cQuery += " AND F30.D_E_L_E_T_  = F31.D_E_L_E_T_"

	cQuery += " LEFT JOIN " + RetSqlName("SYA") + " AS SYA"
	cQuery += " ON SYA.YA_CODGI = F36.F36_ORIGIN "
	cQuery += " AND SYA.D_E_L_E_T_  = F36.D_E_L_E_T_"
	
	cQuery += " LEFT JOIN " + RetSqlName("SB1") + " AS SB1" 
	cQuery += " ON SB1.B1_COD = F36.F36_ITMCOD " 
	cQuery += " AND SB1.D_E_L_E_T_= F36.D_E_L_E_T_"

	cQuery += " LEFT JOIN " + RetSqlName("SBM") + " AS SBM"
	cQuery += " ON SBM.BM_GRUPO = SB1.B1_GRUPO"
	cQuery += " AND SBM.D_E_L_E_T_ = SB1.D_E_L_E_T_"
	
	cQuery += " LEFT JOIN " + RetSqlName("SAH") + " AS SAH"
	cQuery += " ON SAH.AH_UNIMED = SB1.B1_UM"
    cQuery += " AND SAH.D_E_L_E_T_ = SB1.D_E_L_E_T_"

	cQuery += " WHERE F36.F36_FILIAL = '" + cNotFil + "' "    
	cQuery += " AND F36.F36_KEY = '" + cNotIni + "' "
    cQuery += " AND F36.D_E_L_E_T_ = ' '"
    cQuery += " AND F31.F31_FILIAL = '" + xFilial('F31') + "'"
    cQuery += " AND F30.F30_FILIAL = '" + xFilial('F30') + "'"
    
    cQuery += " AND COALESCE(SYA.YA_FILIAL,'" + xFilial('SYA') + "') = '"+ xFilial('SYA') + "' "
    cQuery += " AND COALESCE(SB1.B1_FILIAL,'" + xFilial('SB1') + "') = '"+ xFilial('SB1') + "' "
    cQuery += " AND COALESCE(SBM.BM_FILIAL,'" + xFilial('SBM') + "') = '"+ xFilial('SBM') + "' "
    cQuery += " AND COALESCE(SAH.AH_FILIAL,'" + xFilial('SAH') + "') = '"+ xFilial('SAH') + "' "
    
    cQuery += " ORDER BY F36.F36_ITEM"

	cQuery      := ChangeQuery(cQuery)
	cAliasTMP   := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
	DbSelectArea(cAliasTMP)

    aBlock_2 := {}
    aBlock_5a := {}
    nCountStr := 0

    (cAliasTMP)->(dbGotop())
    While  (cAliasTMP)->(!EOF())
        
        //Create data block_1
        aBlock_tmp := {}
    //1 - Item number, auto incrementation
        aAdd(aBlock_tmp, nCountStr += 1) 
        If  !EMPTY((cAliasTMP)->BM_GDSSRV) //if at least one of the list is a commodity, not a service, the shipper / consignee will be printed
            lPrint := .T.
        EndIf
        //description of each product. If it is empty in invoice it would be taken from sb1 
        cFdescr := GetDescr(cNotFil+cNotIni + (cAliasTMP)->F36_ITEM)
        If Empty(cFdescr) 
            cFdescr := (cAliasTMP)->B1_DESC
        EndIf 
    //2 - B1_DESC - (1a)
        aAdd(aBlock_tmp, cFdescr) 
        cB6Vunit :=  Transform((cAliasTMP)->F36_VUNIT, GetSx3Cache( "F36_VUNIT", "X3_PICTURE" ))
    //3 - F36_EXC_V1 - excise amount (6) 
        aAdd(aBlock_tmp, Iif((cAliasTMP)->F36_EXC_V1 > 0, (cAliasTMP)->F36_EXC_V1, STR0061)) 
        
        If (cAliasTMP)->B1_PRINT = '2'  .or. EMPTY((cAliasTMP)->B1_PRINT) //temporary solution, because now user can enter services that are not in table SB1
    //4 - F36_CUSCOD - (1b)
            aAdd(aBlock_tmp, " -- ") 
    //5 - AH_CODOKEI - (2)
            aAdd(aBlock_tmp, " -- ")
    //6 - AH_UMRES   - (2a)
            aAdd(aBlock_tmp, " -- ")
    //7 -  F36_QUANT  - (3)
            aAdd(aBlock_tmp, " -- ")
    //8 - F36_VUNIT  - (4)
            aAdd(aBlock_tmp, " -- ") 
        Else 
    //4 - F36_CUSCOD - (1b)
            aAdd(aBlock_tmp, Iif((!EMPTY((cAliasTMP)->F36_CUSCOD)), AllTrim((cAliasTMP)->F36_CUSCOD), " -- ")) 
    //5 - AH_CODOKEI - (2)
            aAdd(aBlock_tmp, AllTrim((cAliasTMP)->AH_CODOKEI))
    //6 - AH_UMRES   - (2a)
            aAdd(aBlock_tmp, AllTrim((cAliasTMP)->AH_UMRES  )) 
    //7 -  F36_QUANT  - (3)
            aAdd(aBlock_tmp, Transform((cAliasTMP)->F36_QUANT, GetSx3Cache( "F36_QUANT", "X3_PICTURE" )))
    //8 - F36_VUNIT  - (4)
            aAdd(aBlock_tmp, cB6Vunit                        ) 
        EndIf 

        If cMoedaCode = '643' // rubles
    //9 - F36_VATBS1 - (5)
            aAdd(aBlock_tmp, Transform((cAliasTMP)->F36_VATBS1, GetSx3Cache( "F36_VATBS1", "X3_PICTURE" )))
    //10 - F36_VATVL1 - (8)
            aAdd(aBlock_tmp, Transform((cAliasTMP)->F36_VATVL1, GetSx3Cache( "F36_VATVL1", "X3_PICTURE" )))
    //11 - Total - (9)
            aAdd(aBlock_tmp, Transform((cAliasTMP)->F36_VATBS1, GetSx3Cache( "F36_VATBS1", "X3_PICTURE" )))
        Else
    //9 - F36_VATBS - (5)
            aAdd(aBlock_tmp, Transform((cAliasTMP)->F36_VATBS, GetSx3Cache( "F36_VATBS", "X3_PICTURE" )))
    //10 - F36_VATVL - (8)
            aAdd(aBlock_tmp, Transform((cAliasTMP)->F36_VATVL, GetSx3Cache( "F36_VATVL", "X3_PICTURE" )))
    //11 - F36_VALGR - (9)
            aAdd(aBlock_tmp, Transform((cAliasTMP)->F36_VALGR, GetSx3Cache( "F36_VALGR", "X3_PICTURE" )))
        EndIf
    //12 - F30_DESC - (7)
        aAdd(aBlock_tmp, AllTrim((cAliasTMP)->F30_DESC)) 

        If !EMPTY((cAliasTMP)->F36_ORIGIN)
    //13 - F36_ORIGIN - (10)
            aAdd(aBlock_tmp, AllTrim((cAliasTMP)->F36_ORIGIN)) 
    //14 - YA_DESCR   - (10a)
            aAdd(aBlock_tmp, AllTrim((cAliasTMP)->YA_DESCR))
        Else
    //13 - F36_ORIGIN - (10)
            aAdd(aBlock_tmp, " -- ")
    //14 - YA_DESCR   - (10a)
            aAdd(aBlock_tmp, " -- ")
        Endif

        If !EMPTY((cAliasTMP)->F36_NUMDES) 
    //15 -  F36_NUMDES - (11)
            aAdd(aBlock_tmp, (cAliasTMP)->F36_NUMDES) 
        Else
    // 15 -  F36_NUMDES - (11)
            aAdd(aBlock_tmp, "-") 
        Endif

        aAdd(aBlock_2, aClone(aBlock_tmp))

    //Create array for shipping document: number, from.
        If (!Empty((cAliasTMP)->F36_INVSER) .AND. !Empty((cAliasTMP)->F36_INVDOC) .AND. !Empty((cAliasTMP)->F36_INVDT)) 
            aAdd(aBlock_5a, {nCountStr, (cAliasTMP)->F36_INVSER, (cAliasTMP)->F36_INVDOC, (cAliasTMP)->F36_INVDT})
        EndIf
		(cAliasTMP)->(dbSkip())		
    EndDo
    (cAliasTMP)->(dbCloseArea())
    RestArea(aArea)

    //shipping document: number, from.
    cShipdoc := ""
    cDocF36  := ""
    If !Empty(aBlock_5a)
        nCountStr := 1
        For nX := 1 To Len(aBlock_5a)
            If Len(aBlock_5a) == 1
                cShipdoc += STR0037 + " " + cValToChar(aBlock_5a[1][1]) + " ";
                            + STR0019 + " " + aBlock_5a[1][2]+ " "+ AllTrim(aBlock_5a[1][3]) + " " + STR0014 + " "+  FormatDate(SToD(aBlock_5a[1][4]))
            Else
                If(cDocF36 != aBlock_5a[nX][2] + aBlock_5a[nX][3] + aBlock_5a[nX][4] .AND. nX != 1)
                    cShipdoc += IIF(cShipdoc != "", '; ', "") + STR0037 + " " + cValToChar(aBlock_5a[nCountStr][1]) + "-" + cValToChar((aBlock_5a[nX][1]) - 1)+ " " ;
                                 + STR0019 + " " + aBlock_5a[nCountStr][2]+ " "+ AllTrim(aBlock_5a[nCountStr][3]) + " " + STR0014 + " " + FormatDate(SToD(aBlock_5a[nCountStr][4]))
                    nCountStr := nX
                EndIf
                If(nX == Len(aBlock_5a))
                    cShipdoc += IIF(cShipdoc != "", '; ', "") + STR0037 + " " + cValToChar(aBlock_5a[nCountStr][1]) ;
                                 + IIF(aBlock_5a[nCountStr][1] != aBlock_5a[Len(aBlock_5a)][1] ,"-" + cValToChar((aBlock_5a[Len(aBlock_5a)][1])) , "")+ " " ;
                                 + STR0019 + " " + aBlock_5a[nCountStr][2]+ " "+ AllTrim(aBlock_5a[nCountStr][3]) + " " + STR0014 + " " + FormatDate(SToD(aBlock_5a[nCountStr][4]))
                EndIf
            EndIf
        cDocF36 := aBlock_5a[nX][2] + aBlock_5a[nX][3] + aBlock_5a[nX][4]

        Next
    EndIf
    aAdd(aBlock_0, cShipdoc) //shipping document

    RU05R06Frm(aBlock_0, aBlock_1, aBlock_2)

Return .T. 


/*/
{Protheus.doc} GetDescr()
    Function take information from memo field
    @type Function
    @params 
    @author 
    @since 2023/07/12
    @version 
    @return 
    @example 
/*/

Static Function GetDescr(cIndex)

    Local cFdescr       AS Character 
    Default cIndex      := ""

    cFdescr = ' '
    dbSelectArea('F36')
    dbSetOrder(1)
    If (dbseek(cIndex))
        cFdescr := alltrim(F36->F36_DESC)
        F36->(dbSkip()) 
    endif
    F36->(dbCloseArea())
Return cFdescr


/*/
{Protheus.doc} GettFullAdress()
    Function return information about adress in field aga_full
    @type Function
    @params 
    @author 
    @since 2023/07/12
    @version 
    @return 
    @example 
/*/
Static Function GettFullAdress(cAliasP,cKeyP,cTipo,cDate)

Local cQuery 	As Character
Local cAgaFull 	As Character
Local cTab 		As Character

cAgaFull 		:= ""
if (!empty(cAliasP) .and. !empty(cKeyP) .and. !empty(cTipo))
    cQuery := " SELECT AGA.R_E_C_N_O_ AS AGAREC FROM " + RetSqlName("AGA") + " AGA "
    cQuery += " WHERE AGA.AGA_FILIAL = '"+xFilial("AGA")+"'"
    cQuery += " AND AGA_ENTIDA = '" + cAliasP + "'"
    cQuery += " AND AGA_CODENT = '" + cKeyP + "'"
    cQuery += " AND AGA_TIPO = '" + cTipo + "'"
    If !empty(cDate)
        cQuery += " AND  '" + cDate +  "' BETWEEN '''AGA.AGA_FROM''' AND AGA.AGA_TO  "
    endif
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
    cTab := MPSysOpenQuery(cQuery)

    If (cTab)->(!EOF())
        AGA->(dbGoTo((cTab)->AGAREC))
        cAgaFull    := ALLTRIM(AGA->AGA_FULL)
    Else
    cAgaFull        := " "
    EndIf
    (cTab)->( dbCloseArea() )
endif
Return(cAgaFull)



/*/
{Protheus.doc} FormatDate()
    Function formating date from date to russian print standart dd.mm.yyyy
    @type Function
    @params 
    @author 
    @since 2023/07/12
    @version 
    @return 
    @example 
/*/

Static Function FormatDate(dData)
    Local cData     AS Character
    cData := DTOS(dData)
    cData := Substr(alltrim(cData), 7, 2) + "." +  Substr(alltrim(cData), 5, 2) + "." + Substr(alltrim(cData), 1, 4)
Return cData

/*/
{Protheus.doc} GetMyAgacodent()
    Function returns aga_codent of our company, depends on level
    @type Function
    @params nLevel, Numeric, CO_TIPO
            nLevel = 0 - Group company
            nLevel = 1 - Company
            nLevel = 2 - Buisness unit
            nLevel = 3 - Filial 
    @author 
    @since 2023/07/12
    @version 
    @return 
    @example 
/*/
Static Function GetMyAgacodent(nLevel)
    local cAGACodent    As Character
    Local aArea         As Array
    Default nLevel := 3

    aArea	:= GetArea()
    DbSelectArea("XX8")
    XX8->(dbSetOrder(1))
    XX8->(dbGoTop())
    

    cAGACodent := xFilial("AGA")+PADR(FWGrpCompany(),LEN(XX8->XX8_GRPEMP))+IIF(nLevel == 0, "0" , "")
    //0 - XX8_TIPO

    If nLevel >= 1 
        cAGACodent += PADR(FWCompany(),LEN(XX8->XX8_EMPR) )+IIF(nLevel == 1, "1" , "")
        //1 - XX8_TIPO
        If nLevel >= 2 
            cAGACodent += PADR(FWUnitBusiness(),LEN(XX8->XX8_UNID) ) +IIF(nLevel == 2, "2" , "")
            //2 - XX8_TIPO
            If nLevel == 3
                cAGACodent += PADR(FWFilial(),LEN(XX8->XX8_CODIGO) ) 
            EndIf
        Endif
    EndIf
    RestArea(aArea)
Return cAGACodent

/*/
{Protheus.doc} FindHeadQuoter()
    Function check headquater for client coe and return code of hedquoter, If it is found
    @type Function
    @params 
    @author 
    @since 2023/07/12
    @version 
    @return 
    @example 
/*/
Static Function FindHeadQuoter(cCod, cBranch)
Local cHeadQuot        AS Character 
Local aArea            As Array 

aArea := GetArea()
    dbSelectArea('AI0')
    dbSetOrder(1)
    If (AI0->(dbseek(xFilial("AI0") + cCod + cBranch)))
        cHeadQuot := alltrim(AI0->AI0_HEAD)
        AI0->(dbSkip()) 
    Else 
        cHeadQuot  := cCod
    endif
    
RestArea(aArea)
Return cHeadQuot

/*/
{Protheus.doc} GetSigner()
    Function later must be replased for standart one (ru99signers)
    @type Function
    @params 
    @author 
    @since 2023/07/12
    @version 
    @return 
    @example 
/*/
Static Function GetSigner(cSomeOne,cDate)

Local cTab      AS Character
Local cQuery    AS Character
Default cDate   := DTOS(ddatabase)

    cQuery := " SELECT * FROM " + RetSqlName("F42")  + " F42 "
    cQuery += " WHERE " 
    cQuery += " F42.F42_EMPL = '" + cSomeOne 	+ "'"
    cQuery += " AND F42.F42_FILIAL = '" + FWxFilial('F42')	+ "' "
    cQuery += " AND F42.F42_DFROM <= '" + cDate +	"'"
    cQuery += " AND F42.D_E_L_E_T_ = ' ' "

    //cQuery := ChangeQuery(cQuery) 
    //Comment because the field F42.F42_DFROM is converted to F42.F42_D FROM in the query
    cTab	:= GetNextAlias()
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.T.)
    DbSelectArea(cTab)

    If (cTab)->(!EOF())
        If(Empty((cTab)->F42_DATETO))
            cSomeOne := (cTab)->F42_NAME
        Else
            If((cTab)->F42_DATETO >= cDate)
                cSomeOne := (cTab)->F42_NAME
            Else
                cSomeOne := " "
            EndIf
        EndIf
    Else
        cSomeOne := " "
    EndIf
    (cTab)->(dbCloseArea())

Return AllTrim(cSomeOne)

/*/
{Protheus.doc} RU05R06001_GetCompanyInfo()
    Get information about company
    @type Function
    @params cType, Character, CO_TIPO
           cType = 0 - Group company
           cType = 1 - Company
           cType = 2 - Buisness unit
        cGroupCode  , Character, CO_COMPGRP
        cCompanyCode, Character, CO_COMPEMP
        cBusUnitCode, Character, CO_COMPUNI
    @author eprokhorenko
    @since 2023/11/21
    @version 
    @return aCompanyInfo
            aCompanyInfo[1] - CO_FULLNAM // Full name.
            aCompanyInfo[2] - CO_INN // INN. 
            aCompanyInfo[3] - CO_KPP // KPP.
            aCompanyInfo[4] - CO_TYPE // CO_TYPE
            aCompanyInfo[5] - CO_OGRN // CO_OGRN
    @example RU05R06001_GetCompanyInfo(nType, cGroupCode, cCompanyCode, cBusUnitCode)
/*/
Static Function RU05R06001_GetCompanyInfo(cType, cGroupCode, cCompanyCode, cBusUnitCode)
    Local cQuery := ""          As Character
    Local oStatement := Nil     As Object
    Local aArea := GetArea()    As Array
    Local aCompanyInfo := {}    As Array

    // Make SQL query.
    cQuery := " SELECT CO_TIPO, CO_COMPGRP, CO_COMPEMP, CO_COMPUNI, CO_FULLNAM, CO_SHORTNM, CO_INN, CO_KPP, CO_PHONENU, CO_OKVED, CO_OKTMO, CO_LOCLTAX, CO_TYPE, CO_OGRN "
    cQuery += " FROM SYS_COMPANY_L_RUS " 
    cQuery += " WHERE "
    cQuery += "         CO_TIPO = ? "
    If(Val(cType) >= 0)
        cQuery += " AND CO_COMPGRP = ?  "
    EndIf
    If(Val(cType) >= 1)
        cQuery += " AND CO_COMPEMP = ?  "
    EndIf
    If(Val(cType) == 2)
        cQuery += " AND CO_COMPUNI = ?  "
    EndIf
    cQuery += "     AND D_E_L_E_T_ = ' '"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cType)
    If(Val(cType) >= 0)
        oStatement:SetString(2, cGroupCode)
    EndIf
    If(Val(cType) >= 1)
        oStatement:SetString(3, cCompanyCode)
    EndIf
    If(Val(cType) == 2)
        oStatement:SetString(4, cBusUnitCode)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    While !(cTab)->(Eof())
        
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_FULLNAM)) // Full name.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_INN    )) // INN.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_KPP    )) // KPP.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_TYPE   ))// CO_TYPE
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_OGRN   ))// CO_OGRN

        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())

    If Type("oStatement") <> "U"
        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)

Return aCompanyInfo


/*/
{Protheus.doc} RU05R06002_GetBranchInfo()
    Get information about filial(branch)
    @type Function
    @params cGroupCode  , Character, BR_COMPGRP
            cCompanyCode, Character, BR_COMPEMP
            cBusUnitCode, Character, BR_COMPUNI
            cFilialCode , Character, BR_BRANCH
    @author eprokhorenko
    @since 2023/11/27
    @version 
    @return aBranchInfo
            aBranchInfo[1] - BR_TYPE // Type of filial
            aBranchInfo[2] - BR_KPP // KPP. 
            aBranchInfo[2] - BR_FULLNAM // Full name of the branch
    @example RU05R06002_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
/*/
Static Function RU05R06002_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
    Local cQuery := ""          As Character
    Local oStatement := Nil     As Object
    Local aArea := GetArea()    As Array
    Local aBranchInfo := {}     As Array

    // Make SQL query.
    cQuery := " SELECT BR_BRANCH, BR_TYPE, BR_FULLNAM, BR_KPP "
    cQuery += " FROM SYS_BRANCH_L_RUS " 
    cQuery += " WHERE "
    cQuery += "         BR_COMPGRP = ? "
    cQuery += "     AND BR_COMPEMP = ? "
    cQuery += "     AND BR_COMPUNI = ? "
    cQuery += "     AND BR_BRANCH  = ? "
    cQuery += "     AND D_E_L_E_T_ = ' '"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cGroupCode  )
    oStatement:SetString(2, cCompanyCode)
    oStatement:SetString(3, cBusUnitCode)
    oStatement:SetString(4, cFilialCode )

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    While !(cTab)->(Eof())
        
        aAdd(aBranchInfo, Alltrim((cTab)->BR_TYPE)) // Type of filial.
        aAdd(aBranchInfo, Alltrim((cTab)->BR_KPP )) // KPP.
        aAdd(aBranchInfo, Alltrim((cTab)->BR_FULLNAM))// Full name of the branch

        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())

    If Type("oStatement") <> "U"
        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)

Return aBranchInfo
                   
//Merge Russia R14 
                   
                   
