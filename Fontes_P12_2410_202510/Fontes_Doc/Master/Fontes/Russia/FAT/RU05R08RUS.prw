#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RU05R08.CH"

#DEFINE M15_OKUD 0315007

/*/{Protheus.doc} RU05R08
    @description prints M4 PDF form
    @type Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 12.1.2310
/*/  

Function RU05R08()

    Local oData      As Object
    Local cJson      As Char
    Local aData      As Array
    Local oOptions   As Object
    Local nDataLen   As Numeric

    aData := {}

    aData := RU05R0803_GeTData()
    nDataLen := Len(aData)
    
    oData := RU05R08Frm(nDataLen, aData)

    RU05R0802_SetStrings(@oData, nDataLen)
    oData := RU05R0801_SetData(aData, @oData, nDataLen)

    cJson := oData:ToJson()

    //Gets Options for PDF template
    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.

    cOptions := oOptions:ToJson()

    //Calls library with FWCALLAPP
    ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions,'ru6245_f')

Return Nil

/*/{Protheus.doc} RU05R0801_SetData
    @type  Static Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 12.1.2310
     
    @param oData, object, Json object
    @param nDataLen, Numeric, lenght ofarray
    @return oData, object, Json object
/*/
Static Function RU05R0801_SetData(aData, oData, nDataLen)
    local nX as Numeric
    local nSum1 as Numeric
    local nSum2 as Numeric
    local nSum3 as Numeric
    Local aCompanyInfo as ARRAY
    Local aBranchInfo as ARRAY
    Local cComName As Character
    Local cINNKPP As Character   
    Local cOKPO As Character
    Local cComPar As Character
    Local cBottomLine As Character
    Local lParam    As Logical

    lParam := .T.

    cBottomLine := ''

    cComPar := Alltrim(SuperGetMv("MV_CMPLVL",.F.,""))

    DO CASE 

        CASE cValToChar(VAL(cComPar)-1) == '3' // filial
            aCompanyInfo := RU05R0805_GetCompanyInfo('2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R0806_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aBranchInfo[3]//branch
                cINNKPP   := aCompanyInfo[2] + "/" + aBranchInfo[2]//branch
                cOKPO     := aBranchInfo[4]//branch
            endif
        CASE cValToChar(VAL(cComPar)-1) == '2' // Buisness unit.
            aCompanyInfo := RU05R0805_GetCompanyInfo('2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R0806_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
        CASE cValToChar(VAL(cComPar)-1) == '1' // Company.
            aCompanyInfo := RU05R0805_GetCompanyInfo('1', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R0806_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
        CASE cValToChar(VAL(cComPar)-1) == '0' // Group company.
            aCompanyInfo := RU05R0805_GetCompanyInfo('0', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R0806_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
    ENDCASE

    if Empty(aCompanyInfo) .or. Empty(aBranchInfo)
        lParam := .F.
        Help("",1,STR0054,,STR0055,1,0,,,,,,{""})
    endif

    if lParam == .T.

        if !Empty(cINNKPP) 
            cComName := cComName + ', ' + cINNKPP
        endif

        //header
        oData['content'][3]["table"]["body"][1][4]["text"] := aData[1][1]
        oData['content'][3]["table"]["body"][2][7]["text"] := M15_OKUD
        oData['content'][3]["table"]["body"][3][2]["text"] := cComName
        oData['content'][3]["table"]["body"][3][7]["text"] := cOKPO

        //table 1
        oData['content'][4]["table"]["body"][3][2]["text"] := aData[1][2]
        oData['content'][4]["table"]["body"][3][3]["text"] := '-'
        oData['content'][4]["table"]["body"][3][4]["text"] := aData[1][3]
        oData['content'][4]["table"]["body"][3][5]["text"] := ''
        oData['content'][4]["table"]["body"][3][6]["text"] := aData[1][4]
        oData['content'][4]["table"]["body"][3][7]["text"] := '-'
        oData['content'][4]["table"]["body"][3][8]["text"] := '-'
        oData['content'][4]["table"]["body"][3][9]["text"] := '-'
        oData['content'][4]["table"]["body"][3][10]["text"] := '-'

        //under first table
        oData['content'][5]["table"]["body"][1][2]["text"] := ''
        oData['content'][5]["table"]["body"][2][2]["text"] := aData[1][5]
        oData['content'][5]["table"]["body"][2][4]["text"] := ''

        //table 2
        nSum1 := 0
        nSum2 := 0
        nSum3 := 0
        For nX := 1 To nDataLen
            oData['content'][6]["table"]["body"][3+nX][1]["text"] := aData[nX][6]
            oData['content'][6]["table"]["body"][3+nX][2]["text"] := '-'
            oData['content'][6]["table"]["body"][3+nX][3]["text"] := aData[nX][7]
            oData['content'][6]["table"]["body"][3+nX][4]["text"] := aData[nX][8]
            oData['content'][6]["table"]["body"][3+nX][5]["text"] := aData[nX][9]
            oData['content'][6]["table"]["body"][3+nX][6]["text"] := aData[nX][10]
            oData['content'][6]["table"]["body"][3+nX][7]["text"] := aData[nX][11]
            oData['content'][6]["table"]["body"][3+nX][8]["text"] := aData[nX][12]
            oData['content'][6]["table"]["body"][3+nX][9]["text"] := aData[nX][13]
            oData['content'][6]["table"]["body"][3+nX][10]["text"] := aData[nX][14]
            oData['content'][6]["table"]["body"][3+nX][11]["text"] := aData[nX][15]
            oData['content'][6]["table"]["body"][3+nX][12]["text"] := aData[nX][16]
            oData['content'][6]["table"]["body"][3+nX][13]["text"] := '-'
            oData['content'][6]["table"]["body"][3+nX][14]["text"] := '-'
            oData['content'][6]["table"]["body"][3+nX][15]["text"] := '-'
            nSum1 += aData[nX][12]
            nSum2 += aData[nX][17]
            nSum3 += aData[nX][18]
        Next

        //bottom
        oData['content'][7]["table"]["body"][1][2]["text"] := ALLTRIM(RU99X01(nSum1,.T.,'1'))

        cBottomLine += STR0045
        cBottomLine := cBottomLine + ' ' + ALLTRIM(RU99X01(nSum2,.T.,'1')) + ' '
        cBottomLine += STR0046
        if Decimal(nSum2) == 0
            cBottomLine := cBottomLine + ' ' + STR0053 + ' '//nil
        else
            cBottomLine := cBottomLine + ' ' + ALLTRIM(RU99X01(Decimal(nSum2),.T.,'1')) + ' '
        endif
        cBottomLine += STR0047
        cBottomLine += ' '
        cBottomLine += STR0048
        cBottomLine := cBottomLine + ' ' + ALLTRIM(RU99X01(nSum3,.T.,'1')) + ' '
        cBottomLine += STR0046
        if Decimal(nSum2) == 0
            cBottomLine := cBottomLine + ' ' + STR0053 + ' '//nil
        else
            cBottomLine := cBottomLine + ' ' + ALLTRIM(RU99X01(Decimal(nSum3),.T.,'1')) + ' '
        endif
        cBottomLine += STR0047

        oData['content'][8]["text"] := cBottomLine

    endif

Return oData


/*/{Protheus.doc} RU05R0802_SetStrings
    @type  Static Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 12.1.2310
    @param oData, Object, contains a template construct
    @param nLen, number, Array length
/*/
Static Function RU05R0802_SetStrings(oData, nLen)

    oData['content'][1]["text"] := STR0001//Standard intersectoral form No. M-15
    oData['content'][2]["text"] := STR0002//Approved by Resolution of the State Statistics Committee of Russia dated October 30, 1997 No. 71a
    // header
    oData['content'][3]["table"]["body"][1][3]["text"] := STR0003//INVOICE NO.
    oData['content'][3]["table"]["body"][1][7]["text"] := STR0004//codes
    oData['content'][3]["table"]["body"][2][3]["text"] := STR0005//for outsourcing of materials
    oData['content'][3]["table"]["body"][2][6]["text"] := STR0006//OKUD form
    oData['content'][3]["table"]["body"][3][1]["text"] := STR0007//Organization
    oData['content'][3]["table"]["body"][3][6]["text"] := STR0008//according to OKPO

    //table 1
    oData['content'][4]["table"]["body"][1][2]["text"] := STR0009//Date of preparation
    oData['content'][4]["table"]["body"][1][3]["text"] := STR0010//Operation type code
    oData['content'][4]["table"]["body"][1][4]["text"] := STR0011//Sender
    oData['content'][4]["table"]["body"][1][6]["text"] := STR0012//Recipient
    oData['content'][4]["table"]["body"][1][8]["text"] := STR0006//OKUD form

    oData['content'][4]["table"]["body"][2][4]["text"] := STR0013//structural subdivision
    oData['content'][4]["table"]["body"][2][5]["text"] := STR0014//Kind of activity
    oData['content'][4]["table"]["body"][2][6]["text"] := STR0013//structural subdivision
    oData['content'][4]["table"]["body"][2][7]["text"] := STR0014//Kind of activity
    oData['content'][4]["table"]["body"][2][8]["text"] := STR0013//structural subdivision
    oData['content'][4]["table"]["body"][2][9]["text"] := STR0014//Kind of activity
    oData['content'][4]["table"]["body"][2][10]["text"] := STR0015//artist code

    //header 2
    oData['content'][5]["table"]["body"][1][1]["text"] := STR0016//Base
    oData['content'][5]["table"]["body"][2][1]["text"] := STR0017//To whom
    oData['content'][5]["table"]["body"][2][3]["text"] := STR0018//Through whom

    //table
    oData['content'][6]["table"]["body"][1][1]["text"] := STR0019//Corresponding account
    oData['content'][6]["table"]["body"][1][3]["text"] := STR0020//Material values
    oData['content'][6]["table"]["body"][1][5]["text"] := STR0021//Unit
    oData['content'][6]["table"]["body"][1][7]["text"] := STR0022//Quantity
    oData['content'][6]["table"]["body"][1][9]["text"] := STR0023//price, rub. cop.
    oData['content'][6]["table"]["body"][1][10]["text"] := STR0024//Amount excluding VAT, rub. cop.
    oData['content'][6]["table"]["body"][1][11]["text"] := STR0025//VAT amount, rub. cop.
    oData['content'][6]["table"]["body"][1][12]["text"] := STR0026//Total including VAT, rub. cop.
    oData['content'][6]["table"]["body"][1][13]["text"] := STR0027//Number
    oData['content'][6]["table"]["body"][1][15]["text"] := STR0028//Serial number of the record on the warehouse card file

    oData['content'][6]["table"]["body"][2][1]["text"] := STR0029//account, sub-account
    oData['content'][6]["table"]["body"][2][2]["text"] := STR0030//analytical accounting code
    oData['content'][6]["table"]["body"][2][3]["text"] := STR0031//name, grade, size, brand
    oData['content'][6]["table"]["body"][2][4]["text"] := STR0032//item number
    oData['content'][6]["table"]["body"][2][5]["text"] := STR0033//code
    oData['content'][6]["table"]["body"][2][6]["text"] := STR0034//Name
    oData['content'][6]["table"]["body"][2][7]["text"] := STR0035//must be released
    oData['content'][6]["table"]["body"][2][8]["text"] := STR0036//released
    oData['content'][6]["table"]["body"][2][13]["text"] := STR0037//inventory
    oData['content'][6]["table"]["body"][2][14]["text"] := STR0038//passports

    //bottom
    oData['content'][7]["table"]["body"][1][1]["text"] := STR0039//Total released
    oData['content'][7]["table"]["body"][1][3]["text"] := STR0040//items
    oData['content'][7]["table"]["body"][2][2]["text"] := STR0041//(in words)

    oData['content'][9]["table"]["body"][1][1]["text"] := STR0049//Vacation allowed
    oData['content'][9]["table"]["body"][1][7]["text"] := STR0050//Chief Accountant

    oData['content'][9]["table"]["body"][2][2]["text"] := STR0042//(job title)
    oData['content'][9]["table"]["body"][2][4]["text"] := STR0043//(signature)
    oData['content'][9]["table"]["body"][2][6]["text"] := STR0044//(full name)
    oData['content'][9]["table"]["body"][2][10]["text"] := STR0043//(signature)
    oData['content'][9]["table"]["body"][2][12]["text"] := STR0044//(full name)

    oData['content'][9]["table"]["body"][3][1]["text"] := STR0051//Let go
    oData['content'][9]["table"]["body"][3][7]["text"] := STR0052//Received

    oData['content'][9]["table"]["body"][4][2]["text"] := STR0042//(job title)
    oData['content'][9]["table"]["body"][4][4]["text"] := STR0043//(signature)
    oData['content'][9]["table"]["body"][4][6]["text"] := STR0044//(full name)
    oData['content'][9]["table"]["body"][4][8]["text"] := STR0042//(job title)
    oData['content'][9]["table"]["body"][4][10]["text"] := STR0043//(signature)
    oData['content'][9]["table"]["body"][4][12]["text"] := STR0044//(full name)
    
Return Nil


/*/{Protheus.doc} RU05R0803_GeTData
    (long_description)
    @type  Static Function
    @author Dsidorenko
    @since 20/03/2024
    @version 12.1.2310
    @return aBlock_2, array, Array for document table
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RU05R0803_GeTData()
    Local aArea         As Array
    Local cAliasTMP     As Char
    Local aBlock_2      As Array
    Local aBlock_tmp    As Array
    Local cQuery := ""  As Character
    Local lEBlockSQL as logical
    Local cSelFil  	 as char 
    Local cEmissao 	 as char
    Local cSelDoc  	 as char
    local cClient  	 as char
    local cSerie   	 as char

    lEBlockSQL := .F.

    cSelDoc  := SF2->F2_DOC
    cSelFil  := SF2->F2_FILIAL
    cEmissao := DTOC(SF2->F2_EMISSAO)
    cClient  := SF2->F2_CLIENTE
    cSerie 	 := SF2->F2_SERIE

    cSelFil  :=strtran(cSelFil,'"',"")
    cSelDoc  :=strtran(cSelDoc,'"',"")
    cEmissao :=strtran(cEmissao,'"',"")
    cClient  :=strtran(cClient,'"',"")
    cSerie   :=strtran(cSerie,'"',"")
 
    aArea 	:= getArea()
    cAliasTMP	:= GetNextAlias()

	cQuery := "SELECT SF2.F2_DOC, SF2.F2_EMISSAO, SF2.F2_CLIENTE, SD2.D2_CONTA, SB1.B1_DESC, SD2.D2_COD, NNR.NNR_DESCRI, "
	cQuery += "SAH.AH_CODOKEI, SAH.AH_UMRES, SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_TOTAL, SD2.D2_VALIMP1, "
	cQuery += "COALESCE(SA1.A1_NOME,'') A1_NOME, COALESCE(SA2.A2_NOME,'') A2_NOME, F5Q_DESCR "
	If ExistBlock("RU05R02S")
		cQuery += ExecBlock('RU05R02S',.T.,.T.,'1')
		lEBlockSQL:=.T.
	Endif
	cQuery += "FROM " + RetSqlName("SF2") + " SF2 "

	cQuery += "INNER JOIN " + RetSqlName("SD2") + " SD2 "
	cQuery += "ON  SD2.D2_FILIAL  = SF2.F2_FILIAL "
	cQuery += "AND SD2.D2_DOC 	  = SF2.F2_DOC "
	cQuery += "AND SD2.D2_SERIE	  = SF2.F2_SERIE  "
	cQuery += "AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
	cQuery += "AND SD2.D2_LOJA	  = SF2.F2_LOJA "
	cQuery += "AND SD2.D2_TIPODOC = SF2.F2_TIPODOC "
	cQuery += "AND SD2.D2_ESPECIE = SF2.F2_ESPECIE "
	cQuery += "AND SD2.D2_TIPODOC = SF2.F2_TIPODOC "
	cQuery += "AND SD2.D2_FILIAL  = '" + cSelFil + "' "
	cQuery += "AND SD2.D_E_L_E_T_ = '' "

	cQuery += "INNER JOIN " + RetSqlName("SAH") + " SAH "
	cQuery += "ON SAH.AH_UNIMED = SD2.D2_UM "
	cQuery += "AND SAH.D_E_L_E_T_ = '' "
	cQuery += "AND SAH.AH_FILIAL = '"+xFilial('SAH')+"' "

	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "ON SB1.D_E_L_E_T_ = '' "
	cQuery += "AND B1_COD = D2_COD "
	cQuery += "AND SB1.B1_FILIAL = '"+xFilial('SB1')+"' "

	cQuery += "INNER JOIN " + RetSqlName("NNR") + " NNR "
	cQuery += "ON NNR.D_E_L_E_T_ = '' "
	cQuery += "AND D2_FILIAL = NNR_FILIAL "
	cQuery += "AND D2_LOCAL = NNR_CODIGO "

	cQuery += "LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += "ON SA1.D_E_L_E_T_ = '' "
	cQuery += "AND SF2.F2_CLIENTE = A1_COD "
	cQuery += "AND SA1.A1_FILIAL = '"+xFilial('SA1')+"' "

	cQuery += "LEFT JOIN " + RetSqlName("SA2") + " SA2 "
	cQuery += "ON SA2.D_E_L_E_T_ = '' "
	cQuery += "AND SF2.F2_CLIENTE = A2_COD "
	cQuery += "AND SA2.A2_FILIAL = '"+xFilial('SA2')+"' "

	cQuery += "LEFT JOIN " + RetSqlName("F5Q") + " F5Q "
	cQuery += "ON F5Q.D_E_L_E_T_ = '' "
	cQuery += "AND F5Q.F5Q_A1COD = A1_COD "
	cQuery += "AND F5Q.F5Q_FILIAL = '"+xFilial('SA2')+"' "

	cQuery += "WHERE SF2.F2_FILIAL = '" + cSelFil + "' "
	cQuery += "AND SF2.D_E_L_E_T_ = '' "
	cQuery += "AND SF2.F2_DOC = '" + cSelDoc + "' "
	cQuery += "AND SF2.F2_CLIENTE = '" + cClient + "' "
	cQuery += "AND SF2.F2_SERIE = '" + cSerie + "' "

    cQuery := ChangeQuery(cQuery)

    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T.)
	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(dbGotop())

    nCountStr := 0
    aBlock_2 := {}

    While (cAliasTMP)->(!EOF())
        aBlock_tmp := {}

        //header
        aAdd(aBlock_tmp, (cAliasTMP)->F2_DOC)

        //table 1
        aAdd(aBlock_tmp, StrTran(DTOC(STOD ((cAliasTMP)->F2_EMISSAO)), "/", "."))
        aAdd(aBlock_tmp, (cAliasTMP)->NNR_DESCRI)
        aAdd(aBlock_tmp, (cAliasTMP)->D2_CONTA)
        
        //header 2
        aAdd(aBlock_tmp, (cAliasTMP)->A1_NOME)

        //table 2
        aAdd(aBlock_tmp, (cAliasTMP)->D2_CONTA)
        aAdd(aBlock_tmp, (cAliasTMP)->B1_DESC)
        aAdd(aBlock_tmp, (cAliasTMP)->D2_COD)
        aAdd(aBlock_tmp, (cAliasTMP)->AH_CODOKEI)
        aAdd(aBlock_tmp, (cAliasTMP)->AH_UMRES)
        aAdd(aBlock_tmp, (cAliasTMP)->D2_QUANT)
        aAdd(aBlock_tmp, (cAliasTMP)->D2_QUANT)
        aAdd(aBlock_tmp, Transform((cAliasTMP)->D2_PRCVEN, GetSx3Cache( "D2_PRCVEN", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform((cAliasTMP)->D2_TOTAL, GetSx3Cache( "D2_TOTAL", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform((cAliasTMP)->D2_VALIMP1, GetSx3Cache( "D2_VALIMP1", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform(Round(((cAliasTMP)->D2_TOTAL + (cAliasTMP)->D2_VALIMP1), 2), GetSx3Cache( "D2_VALIMP1", "X3_PICTURE" )))
        
        //bottom
        aAdd(aBlock_tmp, (cAliasTMP)->D2_TOTAL)
        aAdd(aBlock_tmp, (cAliasTMP)->D2_VALIMP1)

        aAdd(aBlock_2, aClone(aBlock_tmp))

        (cAliasTMP)->(dbSkip())
    EndDo

    (cAliasTMP)->(dbCloseArea())
	RestArea(aArea)

Return aBlock_2

/*/
{Protheus.doc} RU05R0805_GetCompanyInfo()
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
    @example RU05R0805_GetCompanyInfo(nType, cGroupCode, cCompanyCode, cBusUnitCode)
/*/
Static Function RU05R0805_GetCompanyInfo(cType, cGroupCode, cCompanyCode, cBusUnitCode)
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
{Protheus.doc} RU05R0806_GetBranchInfo()
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
    @example RU05R0806_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
/*/
Static Function RU05R0806_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
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
                   
                   
