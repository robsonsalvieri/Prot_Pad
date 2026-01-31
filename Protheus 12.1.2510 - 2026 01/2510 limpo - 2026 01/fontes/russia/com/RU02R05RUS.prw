#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RU02R05.CH"

#DEFINE M4_OKUD 0315003

/*/{Protheus.doc} RU02R05
    @description prints M4 PDF form
    @type Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 13.1.2310
/*/  

Function RU02R05()

    Local oData      As Object
    Local cJson      As Char
    Local aData      As Array
    Local oOptions   As Object

    //Create dialog window
    aData := {}
    aData := RU02R0503_GeTData()
    nDataLen := Len(aData)
    
    oData := RU02R05Frm(nDataLen, aData) 

    oData := RU02R0501_SetData(aData, @oData)
    RU02R0502_SetStrings(@oData, nDataLen)

    cJson := oData:ToJson()

    //Gets Options for PDF template
    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.

    cOptions := oOptions:ToJson()

    //Calls library with FWCALLAPP
    ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions,'ru6245_f')

    ConfirmSx8()

Return Nil

/*/{Protheus.doc} RU02R0501_SetData
    @type  Static Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 13.1.2310
    @param aData, array, Data to fill section
    @param oData, object, Json object
    @return object, Object received with data inserted
/*/
Static Function RU02R0501_SetData(aData, oData)
    Local nX        As Numeric
    Local nEnd      As Numeric
    Local nSum      As Numeric
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
            aCompanyInfo := RU02R0505_GetCompanyInfo('2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU02R0506_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aBranchInfo[3]//branch
                cINNKPP   := aCompanyInfo[2] + "/" + aBranchInfo[2]//branch
                cOKPO     := aBranchInfo[4]//branch
            endif
        CASE cValToChar(VAL(cComPar)-1) == '2' // Buisness unit.
            aCompanyInfo := RU02R0505_GetCompanyInfo('2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU02R0506_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
        CASE cValToChar(VAL(cComPar)-1) == '1' // Company.
            aCompanyInfo := RU02R0505_GetCompanyInfo('1', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU02R0506_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
        CASE cValToChar(VAL(cComPar)-1) == '0' // Group company.
            aCompanyInfo := RU02R0505_GetCompanyInfo('0', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU02R0506_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
    ENDCASE

    if Empty(aCompanyInfo) .or. Empty(aBranchInfo)
        lParam := .F.
        Help("",1,STR0044,,STR0045,1,0,,,,,,{""})
    endif

    if lParam == .T.

        if !Empty(cINNKPP) 
            cComName := cComName + ', ' + cINNKPP
        endif

        oData['content'][4]["table"]["body"][2][3]["text"] := cValToChar(Val(GetSxeNum("SF1", "F1_MSIDENT")))//'order'//H_SYSCOD

        oData['content'][4]["table"]["body"][2][6]["text"] := M4_OKUD
        oData['content'][4]["table"]["body"][3][6]["text"] := cOKPO

        oData['content'][5]["table"]["body"][1][2]["text"] := cComName
        oData['content'][5]["table"]["body"][2][2]["text"] := ''
        
        oData['content'][6]["table"]["body"][3][1]["text"] := aData[1][2]//F1_DTDIGIT
        oData['content'][6]["table"]["body"][3][2]["text"] := ''
        oData['content'][6]["table"]["body"][3][3]["text"] := aData[1][3]//NNR_DESCRI
        oData['content'][6]["table"]["body"][3][4]["text"] := aData[1][4]//A2_NOME
        oData['content'][6]["table"]["body"][3][5]["text"] := aData[1][5]//F1_FORNECE
        oData['content'][6]["table"]["body"][3][6]["text"] := ''
        oData['content'][6]["table"]["body"][3][7]["text"] := aData[1][6]//A2_CONTA
        oData['content'][6]["table"]["body"][3][8]["text"] := ''
        oData['content'][6]["table"]["body"][3][9]["text"] := aData[1][7]//F1_DOC
        oData['content'][6]["table"]["body"][3][10]["text"] := ''

        nSum := 0
        For nX := 1 To nEnd
            oData['content'][7]["table"]["body"][3+nX][1]["text"] := aData[nX][8]//B1_DESC
            oData['content'][7]["table"]["body"][3+nX][2]["text"] := aData[nX][9]//D1_COD
            oData['content'][7]["table"]["body"][3+nX][3]["text"] := aData[nX][10]//AH_CODOKEI
            oData['content'][7]["table"]["body"][3+nX][4]["text"] := aData[nX][11]//D1_UM
            oData['content'][7]["table"]["body"][3+nX][5]["text"] := aData[nX][12]//D1_QUANT
            oData['content'][7]["table"]["body"][3+nX][6]["text"] := aData[nX][12]
            nSum += aData[nX][20]
            oData['content'][7]["table"]["body"][3+nX][7]["text"] := aData[nX][13]//D1_VUNIT
            oData['content'][7]["table"]["body"][3+nX][8]["text"] := aData[nX][14]//D1_TOTAL
            oData['content'][7]["table"]["body"][3+nX][9]["text"] := aData[nX][15]//D1_VALIMP1
            oData['content'][7]["table"]["body"][3+nX][10]["text"] := aData[nX][19]
            oData['content'][7]["table"]["body"][3+nX][11]["text"] := ''
            oData['content'][7]["table"]["body"][3+nX][12]["text"] := ''
        Next

        oData['content'][7]["table"]["body"][3+nX][6]["text"] := Transform(nSum, GetSx3Cache( "D1_QUANT", "X3_PICTURE" ))
        oData['content'][7]["table"]["body"][3+nX][7]["text"] := 'X'
        oData['content'][7]["table"]["body"][3+nX][8]["text"] := aData[1][16]//F1_VALMERC
        oData['content'][7]["table"]["body"][3+nX][9]["text"] := aData[1][17]//F1_VALIMP1
        oData['content'][7]["table"]["body"][3+nX][10]["text"] := aData[1][18]//F1_VALBRUT
        
        oData['content'][8]["table"]["body"][1][3]["text"] := ''
        oData['content'][8]["table"]["body"][1][5]["text"] := ''
        oData['content'][8]["table"]["body"][1][7]["text"] := ''

        oData['content'][8]["table"]["body"][3][3]["text"] := ''
        oData['content'][8]["table"]["body"][3][5]["text"] := ''
        oData['content'][8]["table"]["body"][3][7]["text"] := ''

    endif

Return oData

/*/{Protheus.doc} RU02R0502_SetStrings
    @type  Static Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 13.1.2310
    @param oData, Object, contains a template construct
/*/
Static Function RU02R0502_SetStrings(oData, nLen)

    oData['content'][1]["text"] := STR0001
    oData['content'][2]["text"] := STR0002

    oData['content'][4]["table"]["body"][1][6]["text"] := STR0004
    oData['content'][4]["table"]["body"][2][1]["text"] := STR0005
    oData['content'][4]["table"]["body"][2][5]["text"] := STR0006
    oData['content'][4]["table"]["body"][3][5]["text"] := STR0007

    oData['content'][5]["table"]["body"][1][1]["text"] := STR0042
    oData['content'][5]["table"]["body"][2][1]["text"] := STR0043

    oData['content'][6]["table"]["body"][1][1]["text"] := STR0008
    oData['content'][6]["table"]["body"][1][2]["text"] := STR0009
    oData['content'][6]["table"]["body"][1][3]["text"] := STR0010
    oData['content'][6]["table"]["body"][1][4]["text"] := STR0011
    oData['content'][6]["table"]["body"][1][6]["text"] := STR0012
    oData['content'][6]["table"]["body"][1][7]["text"] := STR0013
    oData['content'][6]["table"]["body"][1][9]["text"] := STR0014

    oData['content'][6]["table"]["body"][2][4]["text"] := STR0015
    oData['content'][6]["table"]["body"][2][5]["text"] := STR0016
    oData['content'][6]["table"]["body"][2][7]["text"] := STR0017
    oData['content'][6]["table"]["body"][2][8]["text"] := STR0018
    oData['content'][6]["table"]["body"][2][9]["text"] := STR0019
    oData['content'][6]["table"]["body"][2][10]["text"] := STR0020

    oData['content'][7]["table"]["body"][1][1]["text"] := STR0021
    oData['content'][7]["table"]["body"][1][3]["text"] := STR0022
    oData['content'][7]["table"]["body"][1][5]["text"] := STR0023
    oData['content'][7]["table"]["body"][1][7]["text"] := STR0024
    oData['content'][7]["table"]["body"][1][8]["text"] := STR0025
    oData['content'][7]["table"]["body"][1][9]["text"] := STR0026
    oData['content'][7]["table"]["body"][1][10]["text"] := STR0027
    oData['content'][7]["table"]["body"][1][11]["text"] := STR0028
    oData['content'][7]["table"]["body"][1][12]["text"] := STR0029

    oData['content'][7]["table"]["body"][2][1]["text"] := STR0030
    oData['content'][7]["table"]["body"][2][2]["text"] := STR0031
    oData['content'][7]["table"]["body"][2][3]["text"] := STR0032
    oData['content'][7]["table"]["body"][2][4]["text"] := STR0033
    oData['content'][7]["table"]["body"][2][5]["text"] := STR0034
    oData['content'][7]["table"]["body"][2][6]["text"] := STR0035

    oData['content'][7]["table"]["body"][4+nLen][5]["text"] := STR0036

    oData['content'][8]["table"]["body"][1][1]["text"] := STR0037

    oData['content'][8]["table"]["body"][2][3]["text"] := STR0038
    oData['content'][8]["table"]["body"][2][5]["text"] := STR0039
    oData['content'][8]["table"]["body"][2][7]["text"] := STR0040

    oData['content'][8]["table"]["body"][3][1]["text"] := STR0041

    oData['content'][8]["table"]["body"][4][3]["text"] := STR0038
    oData['content'][8]["table"]["body"][4][5]["text"] := STR0039
    oData['content'][8]["table"]["body"][4][7]["text"] := STR0040

Return Nil


/*/{Protheus.doc} RU02R0503_GeTData
    (long_description)
    @type  Static Function
    @author Dsidorenko
    @since 20/03/2024
    @version 13.1.2310
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RU02R0503_GeTData()
    Local aArea         As Array
    Local cAliasTMP     As Char
    Local cQuery        As Char
    Local nCountStr     As Numeric
    Local aBlock_2      As Array
    Local aBlock_tmp    As Array
 
    aArea 	:= getArea()
    cAliasTMP	:= GetNextAlias()

    cQuery := " SELECT A2_NOME, A2_END, A2_BAIRRO, A2_MUN, A2_PAIS, A2_EST, A2_CEP, A2_CONTA,"
	cQuery += " F1_DOC, F1_FORNECE, F1_LOJA, F1_DTDIGIT, F1_VALIMP1, F1_VALBRUT, F1_VALMERC, F1_MOEDA,"
	cQuery += " D1_COD, D1_QUANT, D1_UM, D1_VUNIT, D1_LOCAL, B1_DESC, D1_CC, F1_MSIDENT,"
	cQuery += " D1_VALIMP1, D1_ALQIMP1, D1_TOTAL, AH_UNIMED, D1_TIPODOC, AH_CODOKEI, AH_DESCPO,"
	cQuery += " D1_CC, NNR_DESCRI, AH_UMRES, D1_ITEM, F5Q_NUMBER "
	cQuery += " FROM " + RetSqlName("SF1") + " SF1"
	cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += " ON SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
	cQuery += " AND SA2.A2_COD = SF1.F1_FORNECE"
	cQuery += " AND SA2.A2_LOJA = SF1.F1_LOJA "
	cQuery += " AND SA2.D_E_L_E_T_=' '"
	cQuery += " INNER JOIN " + RetSqlName("SD1") + " SD1"
	cQuery += " ON SD1.D1_FILIAL = SF1.F1_FILIAL"
	cQuery += " AND SD1.D1_DOC = SF1.F1_DOC"
	cQuery += " AND SD1.D1_SERIE = SF1.F1_SERIE"
	cQuery += " AND SD1.D1_FORNECE = SF1.F1_FORNECE"
	cQuery += " AND SD1.D1_LOJA = SF1.F1_LOJA"
	cQuery += " AND SD1.D1_TIPODOC = SF1.F1_TIPODOC"
	cQuery += " AND SD1.D1_ESPECIE = SF1.F1_ESPECIE"
	cQuery += " AND SD1.D_E_L_E_T_ = ' '"
	cQuery += " AND SD1.D1_FILIAL =	'" + xFilial("SD1") + "'"
	cQuery += " INNER JOIN " + RetSqlName("SAH") + " SAH"
	cQuery += " ON SAH.AH_FILIAL = '" + xFilial("SAH") + "'"
	cQuery += " AND SAH.AH_UNIMED = SD1.D1_UM"
	cQuery += " AND SAH.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1"
	cQuery += " ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'" 
	cQuery += " AND SB1.B1_COD = SD1.D1_COD"
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("NNR") + " NNR"
	cQuery += " ON NNR.NNR_FILIAL = SD1.D1_FILIAL"
	cQuery += " AND NNR.NNR_CODIGO = SD1.D1_LOCAL"
	cQuery += " AND NNR.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN " + RetSqlName("F5Q") + " F5Q"
	cQuery += " ON F5Q.F5Q_FILIAL = SF1.F1_FILIAL"
	cQuery += " AND F5Q.F5Q_UID = SF1.F1_F5QUID"
	cQuery += " AND F5Q.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
	cQuery += " AND SF1.F1_DOC = '" + SF1->F1_DOC + "'"
	cQuery += " AND SF1.F1_SERIE = '" + SF1->F1_SERIE + "'"
	cQuery += " AND SF1.F1_FORNECE = '" + SF1->F1_FORNECE + "'"
	cQuery += " AND SF1.F1_LOJA = '" + SF1->F1_LOJA + "'"
	cQuery += " AND SF1.F1_FORMUL = '" + SF1->F1_FORMUL + "'"
	cQuery += " AND SF1.D_E_L_E_T_ = ' '"

    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T.)
	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(dbGotop())

    nCountStr := 0
    aBlock_2 := {}

    While (cAliasTMP)->(!EOF())
        aBlock_tmp := {}
        aAdd(aBlock_tmp, nCountStr += 1) 

        aAdd(aBlock_tmp, StrTran(DTOC(Stod((cAliasTMP)->F1_DTDIGIT)), "/", "."))
        aAdd(aBlock_tmp, (cAliasTMP)->NNR_DESCRI)
        aAdd(aBlock_tmp, (cAliasTMP)->A2_NOME)
        aAdd(aBlock_tmp, (cAliasTMP)->F1_FORNECE)
        aAdd(aBlock_tmp, (cAliasTMP)->A2_CONTA)
        aAdd(aBlock_tmp, (cAliasTMP)->F1_DOC)

        aAdd(aBlock_tmp, (cAliasTMP)->B1_DESC)
        aAdd(aBlock_tmp, (cAliasTMP)->D1_COD)
        aAdd(aBlock_tmp, (cAliasTMP)->AH_CODOKEI)
        aAdd(aBlock_tmp, (cAliasTMP)->D1_UM)
        aAdd(aBlock_tmp, Transform((cAliasTMP)->D1_QUANT, GetSx3Cache( "D1_QUANT", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform((cAliasTMP)->D1_VUNIT, GetSx3Cache( "D1_VUNIT", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform((cAliasTMP)->D1_TOTAL, GetSx3Cache( "D1_TOTAL", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform((cAliasTMP)->D1_VALIMP1, GetSx3Cache( "D1_VALIMP1", "X3_PICTURE" )))

        aAdd(aBlock_tmp, Transform((cAliasTMP)->F1_VALMERC, GetSx3Cache( "F1_VALMERC", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform((cAliasTMP)->F1_VALIMP1, GetSx3Cache( "F1_VALIMP1", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform((cAliasTMP)->F1_VALBRUT, GetSx3Cache( "F1_VALBRUT", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform((((cAliasTMP)->D1_TOTAL) + ((cAliasTMP)->D1_VALIMP1)), GetSx3Cache( "D1_TOTAL", "X3_PICTURE" )))

        aAdd(aBlock_tmp, (cAliasTMP)->D1_QUANT)
        aAdd(aBlock_2, aClone(aBlock_tmp))

        (cAliasTMP)->(dbSkip())
    EndDo

    (cAliasTMP)->(dbCloseArea())
	RestArea(aArea)

Return aBlock_2

/*/
{Protheus.doc} RU02R0505_GetCompanyInfo()
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
    @version 13.1.2310
    @return aCompanyInfo
            aCompanyInfo[1] - CO_FULLNAM // Full name.
            aCompanyInfo[2] - CO_INN // INN. 
            aCompanyInfo[3] - CO_KPP // KPP.
            aCompanyInfo[4] - CO_TYPE // CO_TYPE
            aCompanyInfo[5] - CO_OGRN // CO_OGRN
    @example RU02R0505_GetCompanyInfo(nType, cGroupCode, cCompanyCode, cBusUnitCode)
/*/
Static Function RU02R0505_GetCompanyInfo(cType, cGroupCode, cCompanyCode, cBusUnitCode)
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
{Protheus.doc} RU02R0506_GetBranchInfo()
    Get information about filial(branch)
    @type Function
    @params cGroupCode  , Character, BR_COMPGRP
            cCompanyCode, Character, BR_COMPEMP
            cBusUnitCode, Character, BR_COMPUNI
            cFilialCode , Character, BR_BRANCH
    @author Dsidorenko
    @since 2024/03/24
    @version 13.1.2310
    @return aBranchInfo
            aBranchInfo[1] - BR_TYPE // Type of filial
            aBranchInfo[2] - BR_KPP // KPP. 
            aBranchInfo[2] - BR_FULLNAM // Full name of the branch
    @example RU02R0506_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
/*/
Static Function RU02R0506_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
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
