#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RU04R05.CH"

#DEFINE M11_OKUD 0315006

/*/{Protheus.doc} RU04R05
    @description prints M4 PDF form
    @type Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 12.1.2310
/*/  

Function RU04R05()

    Local oData      As Object
    Local cJson      As Char
    Local aData      As Array
    Local oOptions   As Object
    Local cSelDoc		as Char
    Local cEmissao		as Char

    aData := {}

    If FwIsInCallStack('MATA311')
		cSelDoc := NNS->NNS_COD
		cEmissao := DTOS(NNS->NNS_DATA)

	Else
		cSelDoc := SD3->D3_DOC
		cEmissao := DTOS(SD3->D3_Emissao)
	Endif

    aData := RU04R0503_GeTData(cSelDoc, cEmissao)
    nDataLen := Len(aData)/2
    
    oData := RU04R05Frm(nDataLen, aData) 

    oData := RU04R0501_SetData(aData, @oData, cSelDoc)
    RU04R0502_SetStrings(@oData, nDataLen)

    cJson := oData:ToJson()

    //Gets Options for PDF template
    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.

    cOptions := oOptions:ToJson()

    //Calls library with FWCALLAPP
    ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions,'ru6245_f')

Return Nil

/*/{Protheus.doc} RU04R0501_SetData
    @type  Static Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 12.1.2310
    @param aData, array, Data to fill section
    @param oData, object, Json object
    @param cSelDoc, String, Document number
    @return object, Object received with data inserted
/*/
Static Function RU04R0501_SetData(aData, oData, cSelDoc)
    Local nX        As Numeric
    Local nEnd      As Numeric
    Local lParam    As Logical
    Local aCompanyInfo as ARRAY
    Local aBranchInfo as ARRAY
    Local cComName As Character
    Local cINNKPP As Character   
    Local cOKPO As Character

    lParam := .T.

    nEnd := len(aData)

    cComPar := Alltrim(SuperGetMv("MV_CMPLVL",.F.,""))

    DO CASE 

        CASE cValToChar(VAL(cComPar)-1) == '3' // filial
            aCompanyInfo := RU04R0505_GetCompanyInfo('2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU04R0506_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aBranchInfo[3]//branch
                cINNKPP   := aCompanyInfo[2] + "/" + aBranchInfo[2]//branch
                cOKPO     := aBranchInfo[4]//branch
            endif
        CASE cValToChar(VAL(cComPar)-1) == '2' // Buisness unit.
            aCompanyInfo := RU04R0505_GetCompanyInfo('2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU04R0506_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
        CASE cValToChar(VAL(cComPar)-1) == '1' // Company.
            aCompanyInfo := RU04R0505_GetCompanyInfo('1', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU04R0506_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
        CASE cValToChar(VAL(cComPar)-1) == '0' // Group company.
            aCompanyInfo := RU04R0505_GetCompanyInfo('0', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU04R0506_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
    ENDCASE

    if Empty(aCompanyInfo) .or. Empty(aBranchInfo)
        lParam := .F.
        Help("",1,STR0046,,STR0047,1,0,,,,,,{""})
    endif

    if lParam == .T.

        if !Empty(cINNKPP) 
            cComName := cComName + ', ' + cINNKPP
        endif

        //header
        oData['content'][4]["table"]["body"][1][3]["text"] := cSelDoc
        oData['content'][4]["table"]["body"][2][7]["text"] := M11_OKUD
        oData['content'][4]["table"]["body"][3][7]["text"] := cOKPO//OKPO
        oData['content'][4]["table"]["body"][3][2]["text"] := cComName


        //first table
        oData['content'][5]["table"]["body"][3][1]["text"] := aData[1][1]
        oData['content'][5]["table"]["body"][3][2]["text"] := ''
        oData['content'][5]["table"]["body"][3][3]["text"] := aData[1][2]
        oData['content'][5]["table"]["body"][3][4]["text"] := aData[1][3]
        oData['content'][5]["table"]["body"][3][5]["text"] := aData[2][2]
        oData['content'][5]["table"]["body"][3][6]["text"] := aData[2][3]
        oData['content'][5]["table"]["body"][3][7]["text"] := ''
        oData['content'][5]["table"]["body"][3][8]["text"] := ''
        oData['content'][5]["table"]["body"][3][9]["text"] := ''

        //second table
        For nX := 2 To nEnd Step 2
            oData['content'][8]["table"]["body"][3+(nX/2)][1]["text"] := aData[nX][4]
            oData['content'][8]["table"]["body"][3+(nX/2)][2]["text"] := ''
            oData['content'][8]["table"]["body"][3+(nX/2)][3]["text"] := aData[nX][5]
            oData['content'][8]["table"]["body"][3+(nX/2)][4]["text"] := aData[nX][6]
            oData['content'][8]["table"]["body"][3+(nX/2)][5]["text"] := aData[nX][7]
            oData['content'][8]["table"]["body"][3+(nX/2)][6]["text"] := aData[nX][8]
            oData['content'][8]["table"]["body"][3+(nX/2)][7]["text"] := aData[nX][9]
            oData['content'][8]["table"]["body"][3+(nX/2)][8]["text"] := aData[nX][9]
            oData['content'][8]["table"]["body"][3+(nX/2)][9]["text"] := aData[nX][10]
            oData['content'][8]["table"]["body"][3+(nX/2)][10]["text"] := aData[nX][11]
            oData['content'][8]["table"]["body"][3+(nX/2)][11]["text"] := ''
        Next

    endif

Return oData

/*/{Protheus.doc} RU04R0502_SetStrings
    @type  Static Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 12.1.2310
    @param oData, Object, contains a template construct
    @param nLen, number, Array length
/*/
Static Function RU04R0502_SetStrings(oData, nLen)

    oData['content'][1]["text"] := STR0001
    oData['content'][2]["text"] := STR0002

    //header
    oData['content'][4]["table"]["body"][1][2]["text"] := STR0003
    oData['content'][4]["table"]["body"][1][7]["text"] := STR0004
    oData['content'][4]["table"]["body"][2][6]["text"] := STR0005
    oData['content'][4]["table"]["body"][3][1]["text"] := STR0006
    oData['content'][4]["table"]["body"][3][6]["text"] := STR0007

    //first table
    oData['content'][5]["table"]["body"][1][1]["text"] := STR0008
    oData['content'][5]["table"]["body"][1][2]["text"] := STR0009
    oData['content'][5]["table"]["body"][1][3]["text"] := STR0010
    oData['content'][5]["table"]["body"][1][5]["text"] := STR0011
    oData['content'][5]["table"]["body"][1][7]["text"] := STR0012
    oData['content'][5]["table"]["body"][1][9]["text"] := STR0013

    oData['content'][5]["table"]["body"][2][3]["text"] := STR0014
    oData['content'][5]["table"]["body"][2][4]["text"] := STR0015
    oData['content'][5]["table"]["body"][2][5]["text"] := STR0016
    oData['content'][5]["table"]["body"][2][6]["text"] := STR0017
    oData['content'][5]["table"]["body"][2][7]["text"] := STR0018
    oData['content'][5]["table"]["body"][2][8]["text"] := STR0019

    //under first table
    oData['content'][6]["table"]["body"][1][1]["text"] := STR0020
    oData['content'][7]["table"]["body"][1][1]["text"] := STR0021
    oData['content'][7]["table"]["body"][1][3]["text"] := STR0022

    //second table
    oData['content'][8]["table"]["body"][1][1]["text"] := STR0023
    oData['content'][8]["table"]["body"][1][3]["text"] := STR0024
    oData['content'][8]["table"]["body"][1][5]["text"] := STR0025
    oData['content'][8]["table"]["body"][1][7]["text"] := STR0026
    oData['content'][8]["table"]["body"][1][9]["text"] := STR0027
    oData['content'][8]["table"]["body"][1][10]["text"] := STR0028
    oData['content'][8]["table"]["body"][1][11]["text"] := STR0029

    oData['content'][8]["table"]["body"][2][1]["text"] := STR0030
    oData['content'][8]["table"]["body"][2][2]["text"] := STR0031
    oData['content'][8]["table"]["body"][2][3]["text"] := STR0032
    oData['content'][8]["table"]["body"][2][4]["text"] := STR0033
    oData['content'][8]["table"]["body"][2][5]["text"] := STR0034
    oData['content'][8]["table"]["body"][2][6]["text"] := STR0035
    oData['content'][8]["table"]["body"][2][7]["text"] := STR0036
    oData['content'][8]["table"]["body"][2][8]["text"] := STR0037

    //bottom
    oData['content'][9]["table"]["body"][1][1]["text"] := STR0038
    oData['content'][9]["table"]["body"][1][8]["text"] := STR0039

    oData['content'][10]["table"]["body"][1][3]["text"] := STR0040
    oData['content'][10]["table"]["body"][1][5]["text"] := STR0041
    oData['content'][10]["table"]["body"][1][7]["text"] := STR0042
    oData['content'][10]["table"]["body"][1][10]["text"] := STR0040
    oData['content'][10]["table"]["body"][1][12]["text"] := STR0041
    oData['content'][10]["table"]["body"][1][14]["text"] := STR0042
    
Return Nil


/*/{Protheus.doc} RU04R0503_GeTData
    (long_description)
    @type  Static Function
    @author Dsidorenko
    @since 20/03/2024
    @version 12.1.2310
    @param cSelDoc, number, Document number
    @param cEmissao, number, Emissao 
    @return aBlock_2, array, Array for document table
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RU04R0503_GeTData(cSelDoc, cEmissao)
    Local aArea         As Array
    Local cAliasTMP     As Char
    Local cQuery        As Char
    Local nCountStr     As Numeric
    Local aBlock_2      As Array
    Local aBlock_tmp    As Array
 
    aArea 	:= getArea()
    cAliasTMP	:= GetNextAlias()

    IF FWIsInCallStack("MATA311")
        cQuery := " SELECT NNT.NNT_DOC, SD3.D3_EMISSAO, NNR.NNR_DESCRI, SBE.BE_DESCRIC, SD3.D3_CF, SD3.D3_QUANT,"
		cQuery += " SB1.B1_CUSTD, SB1.B1_CONTA, SB1.B1_DESC, NNT.NNT_PROD, SAH.AH_CODOKEI, SAH.AH_DESCPO,"
		cQuery += " NNT.NNT_QUANT, SD3.D3_CUSTO1, SD3.D3_LOCAL, CASE WHEN NNR_TIPO='1' THEN '" ;
				+ STR0043 + "' WHEN NNR_TIPO='2' THEN '" + STR0044 + "' ELSE '" + STR0045 + "' END AS TIPONAME "

		cQuery += " FROM " + RetSqlName("NNT") + " NNT "
	
		cQuery += " LEFT JOIN " + RetSqlName("SD3") + " SD3 "
		cQuery += " ON SD3.D3_DOC = NNT.NNT_DOC"
		cQuery += " AND SD3.D3_COD = NNT.NNT_PROD"
		cQuery += " AND SD3.D3_LOCALIZ = NNT.NNT_LOCALI"
		cQuery += " AND SD3.D3_LOTECTL = NNT.NNT_LOTECT"
		cQuery += " AND SD3.D3_FILIAL = '" + xFilial('SD3') + "' "
		cQuery += " AND SD3.D3_CF IN ('RE4','DE4') "
		cQuery += " AND SD3.D_E_L_E_T_=' ' "
	
		cQuery += " LEFT JOIN " + RetSqlName("NNR") + " NNR "
		cQuery += " ON NNR.NNR_CODIGO = SD3.D3_LOCAL " 
		cQuery += " AND NNR.NNR_FILIAL = '" + xFilial('NNR') + "' "
		cQuery += " AND NNR.D_E_L_E_T_=' ' "
	
		cQuery += " LEFT JOIN " + RetSqlName("SBE") + " SBE " 
		cQuery += " ON SBE.BE_LOCAL = SD3.D3_LOCAL "
		cQuery += " AND SBE.BE_LOCALIZ = SD3.D3_LOCALIZ "
		cQuery += " AND SBE.BE_FILIAL = '" + xFilial('SBE') + "' "
		cQuery += " AND SBE.D_E_L_E_T_=' ' "
	
		cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 " 
		cQuery += " ON SB1.B1_COD = NNT.NNT_PROD "
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial('SB1') + "' "
		cQuery += " AND SB1.D_E_L_E_T_=' ' " 
	
		cQuery += " LEFT JOIN " + RetSqlName("SAH") + " SAH " 
		cQuery += " ON SAH.AH_UNIMED = NNT.NNT_UM "
		cQuery += " AND SAH.AH_FILIAL = '" + xFilial('SAH') + "' "
		cQuery += " AND SAH.D_E_L_E_T_=' ' "
	
		cQuery += " WHERE "
		cQuery += " NNT.NNT_COD = '" + cSelDoc + "' " 
		cQuery += " AND NNT.D_E_L_E_T_ = ''
		cQuery += " ORDER BY NNT.R_E_C_N_O_ "
    ELSE
        cQuery := "SELECT NNR.NNR_DESCRI, SD3.D3_EMISSAO, SD3.D3_TM, SD3.D3_CF, SD3.D3_LOCAL, SD3.D3_CONTA, "
        cQuery += "SB1.B1_CUSTD, SD3.D3_COD, SD3.D3_QUANT, SB1.B1_DESC, SAH.AH_CODOKEI, SAH.AH_UMRES, "
        cQuery += "SB2.B2_CM1, SD3.D3_CUSTO1, SD3.R_E_C_N_O_, SBE.BE_DESCRIC, CASE WHEN NNR_TIPO='1' THEN '" ;
                + STR0043 + "' WHEN NNR_TIPO='2' THEN '" + STR0044 + "' ELSE '" + STR0045 + "' END AS TIPONAME "
        cQuery += "FROM " + RetSqlName("SD3") + " SD3 "

        cQuery += "INNER JOIN " + RetSqlName("NNR") + " NNR "
        cQuery += "ON NNR.NNR_CODIGO = SD3.D3_LOCAL " 
        cQuery += "AND NNR.NNR_FILIAL = '" + xFilial('NNR') + "' "

        cQuery += "INNER JOIN " + RetSqlName("SBE") + " SBE " 
        cQuery += "ON SBE.BE_LOCAL = SD3.D3_LOCAL "
        // cQuery += "AND SBE.BE_LOCALIZ = SD3.D3_LOCALIZ "
        cQuery += "AND SBE.BE_FILIAL = '" + xFilial('SBE') + "' "

        cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 " 
        cQuery += "ON SB1.B1_COD = SD3.D3_COD "
        cQuery += "AND SB1.B1_FILIAL = '" + xFilial('SB1') + "' "

        cQuery += "INNER JOIN " + RetSqlName("SAH") + " SAH " 
        cQuery += "ON SAH.AH_UNIMED = SD3.D3_UM "
        cQuery += "AND SAH.AH_FILIAL = '" + xFilial('SAH') + "' "

        cQuery += "INNER JOIN " + RetSqlName("SB2") + " SB2 "
        cQuery += "ON SB2.B2_COD = SB1.B1_COD "
        cQuery += "AND SB2.B2_LOCAL = SB1.B1_LOCPAD "
        cQuery += "AND SB2.B2_FILIAL = '" + xFilial('SB2') + "' "

        cQuery += "WHERE SD3.D3_CF IN ('DE4', 'RE4') "
        cQuery += "AND SD3.D_E_L_E_T_=' ' " 
        cQuery += "AND NNR.D_E_L_E_T_=' ' "
        cQuery += "AND SB1.D_E_L_E_T_=' ' " 
        cQuery += "AND SB2.D_E_L_E_T_=' ' " 
        cQuery += "AND SAH.D_E_L_E_T_=' ' " 
        cQuery += "AND SD3.D3_DOC = '" + cSelDoc + "' " 
        cQuery += "AND SD3.D3_EMISSAO = '" + cEmissao + "' "
        cQuery += "ORDER BY R_E_C_N_O_ "
    ENDIF

    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T.)
	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(dbGotop())

    nCountStr := 0
    aBlock_2 := {}

    While (cAliasTMP)->(!EOF())
        aBlock_tmp := {}

        IF FWIsInCallStack("MATA311")
            aAdd(aBlock_tmp, StrTran(DTOC(STOD (cEmissao)), "/", "."))//1.1
            aAdd(aBlock_tmp, (cAliasTMP)->NNR_DESCRI)//1.3,1.5
            aAdd(aBlock_tmp, (cAliasTMP)->TIPONAME)//1.4,1.6
            
            aAdd(aBlock_tmp, (cAliasTMP)->B1_CONTA)//2.1
            aAdd(aBlock_tmp, (cAliasTMP)->B1_DESC)//2.3
            aAdd(aBlock_tmp, (cAliasTMP)->NNT_PROD)//2.4
            aAdd(aBlock_tmp, (cAliasTMP)->AH_CODOKEI)//2.5
            aAdd(aBlock_tmp, (cAliasTMP)->AH_DESCPO)//2.6
            aAdd(aBlock_tmp, Transform((cAliasTMP)->NNT_QUANT, GetSx3Cache( "NNT_QUANT", "X3_PICTURE" )))//2.7,2.8
            aAdd(aBlock_tmp, Transform((cAliasTMP)->B1_CUSTD, GetSx3Cache( "B1_CUSTD", "X3_PICTURE" )))//2.9
            aAdd(aBlock_tmp, Transform(Round(((cAliasTMP)->B1_CUSTD * (cAliasTMP)->NNT_QUANT), 2), GetSx3Cache( "NNT_QUANT", "X3_PICTURE" )))//2.10
        ELSE
            aAdd(aBlock_tmp, StrTran(DTOC(STOD ((cAliasTMP)->D3_EMISSAO)), "/", "."))//1.1
            aAdd(aBlock_tmp, (cAliasTMP)->NNR_DESCRI)//1.3,1.5
            aAdd(aBlock_tmp, (cAliasTMP)->TIPONAME)//1.4,1.6

            aAdd(aBlock_tmp, (cAliasTMP)->D3_CONTA)//2.1
            aAdd(aBlock_tmp, (cAliasTMP)->B1_DESC)//2.3
            aAdd(aBlock_tmp, (cAliasTMP)->D3_COD)//2.4
            aAdd(aBlock_tmp, (cAliasTMP)->AH_CODOKEI)//2.5
            aAdd(aBlock_tmp, (cAliasTMP)->AH_UMRES)//2.6
            aAdd(aBlock_tmp, Transform((cAliasTMP)->D3_QUANT, GetSx3Cache( "D3_QUANT", "X3_PICTURE" )))//2.7,2.8
            aAdd(aBlock_tmp, Transform((cAliasTMP)->B1_CUSTD, GetSx3Cache( "B1_CUSTD", "X3_PICTURE" )))//2.9
            aAdd(aBlock_tmp, Transform(Round(((cAliasTMP)->B1_CUSTD * (cAliasTMP)->D3_QUANT), 2), GetSx3Cache( "D3_QUANT", "X3_PICTURE" )))//2.10
        ENDIF

        aAdd(aBlock_2, aClone(aBlock_tmp))

        (cAliasTMP)->(dbSkip())
    EndDo

    (cAliasTMP)->(dbCloseArea())
	RestArea(aArea)

Return aBlock_2

/*/
{Protheus.doc} RU04R0505_GetCompanyInfo()
    Get information about company
    @type Function
    @params cType, Character, CO_TIPO
           cType = 0 - Group company
           cType = 1 - Company
           cType = 2 - Buisness unit
        cGroupCode  , Character, CO_COMPGRP
        cCompanyCode, Character, CO_COMPEMP
        cBusUnitCode, Character, CO_COMPUNI
    @author Dsidorenko
    @since 2024/03/24
    @version 12.1.2310
    @return aCompanyInfo
            aCompanyInfo[1] - CO_FULLNAM // Full name.
            aCompanyInfo[2] - CO_INN // INN. 
            aCompanyInfo[3] - CO_KPP // KPP.
            aCompanyInfo[4] - CO_TYPE // CO_TYPE
            aCompanyInfo[5] - CO_OGRN // CO_OGRN
    @example RU04R0505_GetCompanyInfo(nType, cGroupCode, cCompanyCode, cBusUnitCode)
/*/
Static Function RU04R0505_GetCompanyInfo(cType, cGroupCode, cCompanyCode, cBusUnitCode)
    Local cQuery := ""          As Character
    Local oStatement := Nil     As Object
    Local aArea := GetArea()    As Array
    Local aCompanyInfo := {}    As Array

    // Make SQL query.
    cQuery := " SELECT CO_TIPO, CO_COMPGRP, CO_COMPEMP, CO_COMPUNI, CO_FULLNAM, CO_SHORTNM, CO_INN, CO_KPP, CO_PHONENU, CO_OKVED, CO_OKTMO, CO_LOCLTAX, CO_TYPE, CO_OGRN, CO_OKPO "
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
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_OKPO   ))// CO_OKPO

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
{Protheus.doc} RU04R0506_GetBranchInfo()
    Get information about filial(branch)
    @type Function
    @params cGroupCode  , Character, BR_COMPGRP
            cCompanyCode, Character, BR_COMPEMP
            cBusUnitCode, Character, BR_COMPUNI
            cFilialCode , Character, BR_BRANCH
    @author Dsidorenko
    @since 2024/03/24
    @version 12.1.2310
    @return aBranchInfo
            aBranchInfo[1] - BR_TYPE // Type of filial
            aBranchInfo[2] - BR_KPP // KPP. 
            aBranchInfo[2] - BR_FULLNAM // Full name of the branch
    @example RU04R0506_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
/*/
Static Function RU04R0506_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
    Local cQuery := ""          As Character
    Local oStatement := Nil     As Object
    Local aArea := GetArea()    As Array
    Local aBranchInfo := {}     As Array

    // Make SQL query.
    cQuery := " SELECT BR_BRANCH, BR_TYPE, BR_FULLNAM, BR_KPP, BR_OKPO "
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
        aAdd(aBranchInfo, Alltrim((cTab)->BR_OKPO))// OKPO

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
                   
                   
