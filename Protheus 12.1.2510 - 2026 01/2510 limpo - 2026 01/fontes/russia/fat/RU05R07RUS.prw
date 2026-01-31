#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RU05R07.CH"

#DEFINE TORG12_OKUD 0330212 

/*/{Protheus.doc} RU05R07
    @description prints M4 PDF form
    @type Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 12.1.2310
/*/  

Function RU05R07()

    Local oData      As Object
    Local cJson      As Char
    Local aData      As Array
    Local oOptions   As Object
    Local nDataLen   As Numeric
    Local nPagAmm   As Numeric

    aData := {}

    aData := RU05R0703_GeTData()
    nDataLen := Len(aData)
    
    oData := RU05R07Frm(nDataLen, aData) 
    nPagAmm := oData['content'][7]["text"]

    RU05R0702_SetStrings(@oData, nDataLen, nPagAmm)
    oData := RU05R0701_SetData(aData, @oData, nDataLen)

    cJson := oData:ToJson()

    //Gets Options for PDF template
    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.

    cOptions := oOptions:ToJson()

    //Calls library with FWCALLAPP
    ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions,'ru6245_f')

Return Nil

/*/{Protheus.doc} RU05R0701_SetData
    @type  Static Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 12.1.2310
     
    @param oData, object, Json object
    @param nDataLen, Numeric, lenght ofarray
    @return oData, object, Json object
/*/
Static Function RU05R0701_SetData(aData, oData, nDataLen)
    Local nX, nTabNum, nPos, nRemains, nPageNum As Numeric
    local nSum1, nSum2, nSum3, nSum4 As Numeric 
    Local aComData as ARRAY
    Local aCompanyInfo as ARRAY
    Local aBranchInfo as ARRAY
    Local cComName As Character
    Local cINNKPP As Character   
    Local cOKPO As Character
    Local cComPar As Character
    Local lParam    As Logical

    lParam := .T.

    cComPar := Alltrim(SuperGetMv("MV_CMPLVL",.F.,""))

    DO CASE 

        CASE cValToChar(VAL(cComPar)-1) == '3' // filial
            aCompanyInfo := RU05R0705_GetCompanyInfo('2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R0706_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aBranchInfo[3]//branch
                cINNKPP   := aCompanyInfo[2] + "/" + aBranchInfo[2]//branch
                cOKPO     := aBranchInfo[4]//branch
            endif
        CASE cValToChar(VAL(cComPar)-1) == '2' // Buisness unit.
            aCompanyInfo := RU05R0705_GetCompanyInfo('2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R0706_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
        CASE cValToChar(VAL(cComPar)-1) == '1' // Company.
            aCompanyInfo := RU05R0705_GetCompanyInfo('1', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R0706_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
        CASE cValToChar(VAL(cComPar)-1) == '0' // Group company.
            aCompanyInfo := RU05R0705_GetCompanyInfo('0', FWGrpCompany(),FWCompany(), FWUnitBusiness())
            aBranchInfo := RU05R0706_GetBranchInfo(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
            if !Empty(aCompanyInfo) .and. !Empty(aBranchInfo)
                cComName  := aCompanyInfo[1]
                cINNKPP   := aCompanyInfo[2] + "/" + IIF(aBranchInfo[1] == '2',aBranchInfo[2],aCompanyInfo[3])
                cOKPO     := aCompanyInfo[6]
            endif
    ENDCASE

    if Empty(aCompanyInfo) .or. Empty(aBranchInfo)
        lParam := .F.
        Help("",1,STR0069,,STR0070,1,0,,,,,,{""})
    endif

    if lParam == .T.

        if !Empty(cINNKPP) 
            cComName := cComName + ', ' + cINNKPP
        endif

        aComData := GetCoBrRUS()

        //right header
        oData['content'][4]["table"]["body"][2][3]["text"] := TORG12_OKUD
        oData['content'][4]["table"]["body"][3][3]["text"] := cOKPO
        oData['content'][5]["table"]["body"][6][4]["text"] := AllTrim(aComData[2][12][2])
        

        //left header
        oData['content'][4]["table"]["body"][3][1]["text"] := cComName + '.'
        oData['content'][5]["table"]["body"][1][1]["text"] := AllTrim(aComData[2][6][2]) + ', ' + AllTrim(aComData[2][5][2]) + ', ' + AllTrim(aComData[2][12][2]) + '.'
        oData['content'][5]["table"]["body"][4][2]["text"] := aData[1][1] + ', ' + aData[1][2]
        oData['content'][5]["table"]["body"][6][2]["text"] := cComName + '.'
        oData['content'][5]["table"]["body"][8][2]["text"] := aData[1][1] + ', ' + aData[1][2]

        oData['content'][6]["table"]["body"][2][2]["text"] := aData[1][17]
        oData['content'][6]["table"]["body"][2][3]["text"] := aData[1][19]

        // table
        nSum1 := 0
        nSum2 := 0
        nSum3 := 0
        nSum4 := 0

        nTabNum := 8

        nPageNum := 2

        For nX := 1 To nDataLen

            //for first page
            if nX < 16
                nPos := nX
                if nDataLen == nx 
                    if nDataLen == 1
                        oData := RU05R0707_SetTable(aData, @oData, nTabNum, nPos, nX)
                        nPos++
                    else
                        nPos := 1
                        nTabNum++
                        oData['content'][nTabNum]["text"] := STR0068 + " " + cValToChar(nPageNum)//page number
                        nTabNum++
                        oData := RU05R0707_SetTable(aData, @oData, nTabNum, nPos, nX)
                        nPos++
                    endif
                else
                    oData := RU05R0707_SetTable(aData, @oData, nTabNum, nPos, nX)
                endif
            else

                if nX == 16
                    nPos := 1
                    nTabNum++
                    nRemains := nDataLen - 15
                    oData['content'][nTabNum]["text"] := STR0068 + " " + cValToChar(nPageNum)//page number
                    nTabNum++
                    nPageNum++
                endif

                //other tables
                if (nRemains - 28 > 0) 
                    oData := RU05R0707_SetTable(aData, @oData, nTabNum, nPos, nX)
                    if nPos == 28
                        nRemains -= 28
                        nPos := 0
                        nTabNum++
                        oData['content'][nTabNum]["text"] := STR0068 + " " + cValToChar(nPageNum)//page number
                        nTabNum++
                        nPageNum++
                    endif
                    nPos++
                else
                    if (nRemains - 15 < 0) 
                        oData := RU05R0707_SetTable(aData, @oData, nTabNum, nPos, nX)
                        nPos++
                    else
                        if nDataLen == nx 
                            nPos := 1
                            nTabNum++
                            oData['content'][nTabNum]["text"] := STR0068 + " " + cValToChar(nPageNum)//page number
                            nTabNum++
                            nPageNum++
                            oData := RU05R0707_SetTable(aData, @oData, nTabNum, nPos, nX)
                            nPos++
                        else
                            oData := RU05R0707_SetTable(aData, @oData, nTabNum, nPos, nX)
                            nPos++
                        endif
                    endif
                endif
            endif
            
            nSum1 += aData[nX][14]
            nSum2 += aData[nX][15]
            nSum3 += aData[nX][16]
            nSum4 += aData[nX][20]

            if nx == nDataLen
            
                oData['content'][nTabNum]["table"]["body"][3+nPos][1]["text"] := STR0041//Total
                oData['content'][nTabNum]["table"]["body"][4+nPos][1]["text"] := STR0042//Total per invoice

                oData['content'][nTabNum]["table"]["body"][3+nPos][10]["text"] := Transform(nSum1, GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" ))
                oData['content'][nTabNum]["table"]["body"][3+nPos][11]["text"] := 'X'
                oData['content'][nTabNum]["table"]["body"][3+nPos][12]["text"] := Transform(nSum2, GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" ))
                oData['content'][nTabNum]["table"]["body"][3+nPos][13]["text"] := 'X'
                oData['content'][nTabNum]["table"]["body"][3+nPos][14]["text"] := Transform(nSum3, GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" ))
                oData['content'][nTabNum]["table"]["body"][3+nPos][15]["text"] := Transform(nSum4, GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" ))

                oData['content'][nTabNum]["table"]["body"][4+nPos][10]["text"] := Transform(nSum1, GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" ))
                oData['content'][nTabNum]["table"]["body"][4+nPos][11]["text"] := 'X'
                oData['content'][nTabNum]["table"]["body"][4+nPos][12]["text"] := Transform(nSum2, GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" ))
                oData['content'][nTabNum]["table"]["body"][4+nPos][13]["text"] := 'X'
                oData['content'][nTabNum]["table"]["body"][4+nPos][14]["text"] := Transform(nSum3, GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" ))
                oData['content'][nTabNum]["table"]["body"][4+nPos][15]["text"] := Transform(nSum4, GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" ))
            else
                
            endif
        Next

    endif

Return oData

/*/{Protheus.doc} RU05R0707_SetTable
    @type  Static Function
    @author DSidorenko
    @since 03/05/2024
    @version version 12.1.2310
    @param aData, array, Data to fill section
    @param oData, object, Json object
    @param nTabNum, numeric, Table number
    @param nStrPos, numeric, String number
    @param nX, numeric, Number to find data in aData
    @return oData, object, Json object
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RU05R0707_SetTable(aData, oData, nTabNum, nStrPos, nX)

    oData['content'][nTabNum]["table"]["body"][3+nStrPos][1]["text"] := nX
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][2]["text"] := aData[nStrPos][4]//B1_DESC
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][3]["text"] := aData[nStrPos][5]//D2_COD
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][4]["text"] := aData[nStrPos][6]//D2_UM
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][5]["text"] := aData[nStrPos][7]//AH_CODOKEI
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][6]["text"] := ''
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][7]["text"] := '' 
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][8]["text"] := ''
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][9]["text"] := ''
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][10]["text"] := aData[nStrPos][8]//D2_QUANT
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][11]["text"] := aData[nStrPos][9]//D2_PRCVEN
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][12]["text"] := aData[nStrPos][10]//D2_TOTAL
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][13]["text"] := cValToChar(aData[nStrPos][11]) + '%'//D2_ALQIMP1
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][14]["text"] := aData[nStrPos][12]//D2_VALIMP1
    oData['content'][nTabNum]["table"]["body"][3+nStrPos][15]["text"] := Transform(aData[nStrPos][20], GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" ))

Return oData

/*/{Protheus.doc} RU05R0702_SetStrings
    @type  Static Function
    @author Dsidorenko
    @since 08/02/2024
    @version version 12.1.2310
    @param oData, Object, contains a template construct
    @param nLen, number, Array length
    @param nPagAmm, number, Ammount of pages
/*/
Static Function RU05R0702_SetStrings(oData, nLen, nPagAmm)
    Local nX, nPos As Numeric

    oData['content'][1]["text"] := STR0001//Unified form No. TORG-12
    oData['content'][2]["text"] := STR0002//Approved by Resolution of the State Statistics Committee of Russia dated December 25, 1998 No. 132

    //header
    oData['content'][4]["table"]["body"][1][3]["text"] := STR0003//Codes
    oData['content'][4]["table"]["body"][2][2]["text"] := STR0004//OKUD form
    oData['content'][4]["table"]["body"][3][2]["text"] := STR0005//According to OKPO
    oData['content'][4]["table"]["body"][4][1]["text"] := STR0006//shipping organization, address, telephone, fax, bank details

    oData['content'][5]["table"]["body"][2][2]["text"] := STR0007//structural subdivision
    oData['content'][5]["table"]["body"][3][2]["text"] := STR0008//Type of activity according to OKDP
    oData['content'][5]["table"]["body"][4][1]["text"] := STR0009//Consignee
    oData['content'][5]["table"]["body"][4][3]["text"] := STR0005//According to OKPO
    oData['content'][5]["table"]["body"][5][2]["text"] := STR0010//organization, address, telephone, fax, bank details
    oData['content'][5]["table"]["body"][6][1]["text"] := STR0011//Provider
    oData['content'][5]["table"]["body"][6][3]["text"] := STR0005//According to OKPO
    oData['content'][5]["table"]["body"][7][2]["text"] := STR0010//organization, address, telephone, fax, bank details
    oData['content'][5]["table"]["body"][8][1]["text"] := STR0012//Payer
    oData['content'][5]["table"]["body"][8][3]["text"] := STR0005//According to OKPO
    oData['content'][5]["table"]["body"][9][2]["text"] := STR0010//organization, address, telephone, fax, bank details
    oData['content'][5]["table"]["body"][10][1]["text"] := STR0013//Base
    oData['content'][5]["table"]["body"][10][3]["text"] := STR0014//number
    oData['content'][5]["table"]["body"][11][2]["text"] := STR0015//contract, work order
    oData['content'][5]["table"]["body"][11][3]["text"] := STR0016//date
    oData['content'][5]["table"]["body"][12][2]["text"] := STR0017//Waybill
    oData['content'][5]["table"]["body"][12][3]["text"] := STR0014//number

    oData['content'][6]["table"]["body"][1][2]["text"] := STR0019//Document Number
    oData['content'][6]["table"]["body"][1][3]["text"] := STR0020//Date of preparation
    oData['content'][6]["table"]["body"][2][1]["text"] := STR0021//PACKING LIST
    oData['content'][6]["table"]["body"][1][5]["text"] := STR0016//date
    oData['content'][6]["table"]["body"][2][5]["text"] := STR0018//Type of operation

    //first table
    nPos := 7
    For nX := 1 To nPagAmm
        oData['content'][nPos]["text"] := STR0068 + " " + cValToChar(nx)//Page number
        nPos++

        oData['content'][nPos]["table"]["body"][1][1]["text"] := STR0022//Number in order
        oData['content'][nPos]["table"]["body"][1][2]["text"] := STR0023//Product
        oData['content'][nPos]["table"]["body"][1][4]["text"] := STR0024//Unit
        oData['content'][nPos]["table"]["body"][1][6]["text"] := STR0025//Type of packaging
        oData['content'][nPos]["table"]["body"][1][7]["text"] := STR0026//Quantity
        oData['content'][nPos]["table"]["body"][1][9]["text"] := STR0027//Gross weight
        oData['content'][nPos]["table"]["body"][1][10]["text"] := STR0028//Quantity (net weight)
        oData['content'][nPos]["table"]["body"][1][11]["text"] := STR0029//price, rub. cop.
        oData['content'][nPos]["table"]["body"][1][12]["text"] := STR0030//Amount excluding VAT, rub. cop.
        oData['content'][nPos]["table"]["body"][1][13]["text"] := STR0031//VAT
        oData['content'][nPos]["table"]["body"][1][15]["text"] := STR0032//Amount including VAT, rub. cop.

        oData['content'][nPos]["table"]["body"][2][2]["text"] := STR0033//name, characteristics, grade, article number of goods
        oData['content'][nPos]["table"]["body"][2][3]["text"] := STR0034//code
        oData['content'][nPos]["table"]["body"][2][4]["text"] := STR0035//Name
        oData['content'][nPos]["table"]["body"][2][5]["text"] := STR0036//OKI code
        oData['content'][nPos]["table"]["body"][2][7]["text"] := STR0037//In one place
        oData['content'][nPos]["table"]["body"][2][8]["text"] := STR0038//places, pieces
        oData['content'][nPos]["table"]["body"][2][13]["text"] := STR0039//bid, %
        oData['content'][nPos]["table"]["body"][2][14]["text"] := STR0040//amount, rub. cop.
        nPos++
    Next

    //next
    oData['content'][nPos]["table"]["body"][1][1]["text"] := STR0043//in words the invoice has an attachment on

    nPos++
    oData['content'][nPos]["table"]["body"][1][1]["text"] := STR0044//and contains
    oData['content'][nPos]["table"]["body"][1][3]["text"] := STR0045//serial numbers of records
    oData['content'][nPos]["table"]["body"][2][2]["text"] := STR0046//in words

    nPos++
    oData['content'][nPos]["table"]["body"][1][2]["text"] := STR0047//Cargo weight (net)
    oData['content'][nPos]["table"]["body"][2][3]["text"] := STR0046//in words

    nPos++
    oData['content'][nPos]["table"]["body"][1][1]["text"] := STR0048//Total seats
    oData['content'][nPos]["table"]["body"][1][4]["text"] := STR0049//Cargo weight (gross)
    oData['content'][nPos]["table"]["body"][2][2]["text"] := STR0046//in words
    oData['content'][nPos]["table"]["body"][2][5]["text"] := STR0046//in words

    // //bottom table
    nPos++
    oData['content'][nPos]["table"]["body"][1][1]["text"] := STR0050//Application (passports, certificates, etc.) on
    oData['content'][nPos]["table"]["body"][1][3]["text"] := STR0051//sheets
    oData['content'][nPos]["table"]["body"][1][5]["text"] := STR0052//By power of attorney No.
    oData['content'][nPos]["table"]["body"][1][7]["text"] := STR0053//from
    oData['content'][nPos]["table"]["body"][2][2]["text"] := STR0046//in words

    nPos++
    oData['content'][nPos]["table"]["body"][1][1]["text"] := STR0054//Total amount released
    oData['content'][nPos]["table"]["body"][1][5]["text"] := STR0055//issued
    oData['content'][nPos]["table"]["body"][2][3]["text"] := STR0046//in words
    oData['content'][nPos]["table"]["body"][2][7]["text"] := STR0056//by whom, to whom

    nPos++
    oData['content'][nPos]["table"]["body"][1][1]["text"] := STR0057//Cargo release allowed
    oData['content'][nPos]["table"]["body"][2][2]["text"] := STR0058//job title
    oData['content'][nPos]["table"]["body"][2][4]["text"] := STR0059//signature
    oData['content'][nPos]["table"]["body"][2][6]["text"] := STR0060//full name

    nPos++
    oData['content'][nPos]["table"]["body"][1][1]["text"] := STR0061//Chief (senior) accountant
    oData['content'][nPos]["table"]["body"][1][8]["text"] := STR0062//Accepted the cargo
    oData['content'][nPos]["table"]["body"][2][4]["text"] := STR0059//job title
    oData['content'][nPos]["table"]["body"][2][6]["text"] := STR0060//full name
    oData['content'][nPos]["table"]["body"][2][9]["text"] := STR0058//job title
    oData['content'][nPos]["table"]["body"][2][11]["text"] := STR0059//signature
    oData['content'][nPos]["table"]["body"][2][13]["text"] := STR0060//full name

    oData['content'][nPos]["table"]["body"][3][1]["text"] := STR0063//The cargo was released
    oData['content'][nPos]["table"]["body"][3][8]["text"] := STR0064//The consignee received the cargo
    oData['content'][nPos]["table"]["body"][4][2]["text"] := STR0058//job title
    oData['content'][nPos]["table"]["body"][4][4]["text"] := STR0059//signature
    oData['content'][nPos]["table"]["body"][4][6]["text"] := STR0060//full name
    oData['content'][nPos]["table"]["body"][4][11]["text"] := STR0059//signature
    oData['content'][nPos]["table"]["body"][4][13]["text"] := STR0060//full name

    nPos++
    oData['content'][nPos]["table"]["body"][1][2]["text"] := STR0065//M.P.
    oData['content'][nPos]["table"]["body"][1][4]["text"] := STR0066//' 
    oData['content'][nPos]["table"]["body"][1][6]["text"] := STR0067//20     years
    oData['content'][nPos]["table"]["body"][1][9]["text"] := STR0065//M.P.
    oData['content'][nPos]["table"]["body"][1][11]["text"] := STR0066//' 
    oData['content'][nPos]["table"]["body"][1][13]["text"] := STR0067//20     years
    
Return Nil


/*/{Protheus.doc} RU05R0703_GeTData
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
Static Function RU05R0703_GeTData()
    Local aArea         As Array
    Local cAliasTMP     As Character
    Local aBlock_2      As Array
    Local aBlock_tmp    As Array
    Local cNotIni	:= SF2->F2_DOC
	Local cNotFin	:= SF2->F2_DOC
    Local oStatement := FWPreparedStatement():New()
    Local cQuery := ""  As Character
 
    aArea 	:= getArea()
    cAliasTMP	:= GetNextAlias()

    cNotIni :=StrTran(cNotIni,'"',"")
    cNotFin :=StrTran(cNotFin,'"',"")

    cQuery += "SELECT D2_ITEM, F2_DOC, F2_SERIE, F2_EMISSAO, B1_DESC, A1_FILIAL, "
    cQuery += "A1_CODZON, A1_NOME, A1_INSCGAN, A1_END, A1_BAIRRO, A1_MUN, A1_PAIS, A1_EST, "
    cQuery += "A1_CEP, A1_CGC, F2_DOC, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALIMP1, F2_VALIMP2, "
    cQuery += "F2_VALBRUT, F2_VALMERC, D2_COD, D2_QUANT, D2_UM, D2_NUMLOTE, D2_LOTECTL, "
    cQuery += "D2_DTVALID, D2_PRCVEN, D2_LOCAL, D2_VALIMP1, D2_ALQIMP1, D2_DESC, D2_TOTAL, "
    cQuery += "D2_VALIMP2, F2_CONTRAT, F2_PBRUTO, AH_CODERP, AH_UMRES, AH_CODOKEI, D2_PESO, "
    cQuery += "D2_REMITO, D2_PEDIDO, AGA.*, AI0.* FROM "+RetSqlName("SF2")+" SF2 "
    cQuery += "INNER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL "
    cQuery += "AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE "
    cQuery += "AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA "
    cQuery += "AND SD2.D2_TIPODOC = SF2.F2_TIPODOC AND SD2.D2_ESPECIE = SF2.F2_ESPECIE "
    cQuery += "AND SD2.D2_FILIAL = ? AND SD2.D_E_L_E_T_ = '' "
    cQuery += "INNER JOIN "+RetSqlName("SAH")+" SAH ON SAH.AH_UNIMED = SD2.D2_UM "
    cQuery += "AND SAH.D_E_L_E_T_ = '' AND SAH.AH_FILIAL = ? "
    cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = '' AND SB1.B1_FILIAL = ? "
    cQuery += "AND B1_COD = D2_COD	"
    cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_COD = SF2.F2_CLIENTE "
    cQuery += "AND SA1.A1_LOJA = SF2.F2_LOJA AND SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = ? "
    cQuery += "LEFT JOIN "+RetSqlName("AGA")+"  AGA ON AGA.AGA_ENTIDA = 'SA1' "
    cQuery += "AND AGA.AGA_FILIAL = ? AND AGA.D_E_L_E_T_=' ' AND "
    cQuery += "AGA.AGA_CODENT LIKE '%SA1.A1_FILIAL||SA1.A1_COD||SA1.A1_LOJA%' "
    cQuery += "AND AGA.AGA_TIPO = '0' AND ? BETWEEN  AGA.AGA_FROM  AND AGA_TO "
    cQuery += "AND AGA.D_E_L_E_T_ = '' "
    cQuery += "LEFT JOIN  "+RetSqlName("AI0")+" AI0 ON AI0.AI0_CODCLI = SA1.A1_COD "
    cQuery += "AND AI0.AI0_LOJA = SA1.A1_LOJA AND AI0.D_E_L_E_T_ = ''  AND AI0.AI0_FILIAL = ? "
    cQuery += "WHERE SF2.F2_FILIAL = ? AND SF2.D_E_L_E_T_ = '' AND SF2.F2_DOC = ? "
    cQuery += "AND SF2.F2_SERIE = ? AND SF2.F2_CLIENTE = ? AND SF2.F2_LOJA = ?"

    oStatement:SetQuery(cQuery)
   
    oStatement:SetString(1,FWxFilial("SD2"))
    oStatement:SetString(2,FWxFilial("SAH"))
    oStatement:SetString(3,FWxfilial("SB1"))
    oStatement:SetString(4,FWxFilial("SA1"))
    oStatement:SetString(5,FWxFilial('AGA'))
    oStatement:SetDate(6,dDataBase)
    oStatement:SetString(7,FWxfilial("AI0"))
    oStatement:SetString(8,FWxfilial("SF2"))
    oStatement:SetString(9,SF2->F2_DOC)
    oStatement:SetString(10,SF2->F2_SERIE)
    oStatement:SetString(11,SF2->F2_CLIENTE)
    oStatement:SetString(12,SF2->F2_LOJA)

    cAliasTMP := MPSysOpenQuery(oStatement:GetFixQuery() ,"cAliasTMP")

    aBlock_2 := {}

    (cAliasTMP)->(dbGotop())

    While (cAliasTMP)->(!EOF())
        aBlock_tmp := {}

        //header
        aAdd(aBlock_tmp, AllTrim((cAliasTMP)->A1_NOME))
        aAdd(aBlock_tmp, AllTrim((cAliasTMP)->A1_CODZON))

        //table
        aAdd(aBlock_tmp, AllTrim((cAliasTMP)->D2_ITEM)) 
        aAdd(aBlock_tmp, AllTrim((cAliasTMP)->B1_DESC)) 
        aAdd(aBlock_tmp, AllTrim((cAliasTMP)->D2_COD)) 
        aAdd(aBlock_tmp, AllTrim((cAliasTMP)->D2_UM)) 
        aAdd(aBlock_tmp, AllTrim((cAliasTMP)->AH_CODOKEI)) 
        aAdd(aBlock_tmp, Transform(Round(((cAliasTMP)->D2_QUANT), 2), GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform(Round(((cAliasTMP)->D2_PRCVEN), 2), GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform(Round(((cAliasTMP)->D2_TOTAL), 2), GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" )))
        aAdd(aBlock_tmp, (cAliasTMP)->D2_ALQIMP1)
        aAdd(aBlock_tmp, Transform(Round(((cAliasTMP)->D2_VALIMP1), 2), GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" )))
        aAdd(aBlock_tmp, Transform(Round(((cAliasTMP)->D2_TOTAL), 2), GetSx3Cache( "D3_CUSTO1", "X3_PICTURE" )))

        aAdd(aBlock_tmp, (cAliasTMP)->D2_QUANT)
        aAdd(aBlock_tmp, (cAliasTMP)->D2_TOTAL)
        aAdd(aBlock_tmp, (cAliasTMP)->D2_VALIMP1)

        aAdd(aBlock_tmp, (cAliasTMP)->F2_DOC)
        aAdd(aBlock_tmp, (cAliasTMP)->F2_SERIE)
        aAdd(aBlock_tmp, StrTran(DTOC(STOD ((cAliasTMP)->F2_EMISSAO)), "/", "."))

        aAdd(aBlock_tmp, (cAliasTMP)->D2_TOTAL/100*(100+(cAliasTMP)->D2_ALQIMP1))

        aAdd(aBlock_2, aClone(aBlock_tmp))

        (cAliasTMP)->(dbSkip())
    EndDo

    (cAliasTMP)->(dbCloseArea())
	RestArea(aArea)

Return aBlock_2

/*/
{Protheus.doc} RU05R0705_GetCompanyInfo()
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
    @example RU05R0705_GetCompanyInfo(nType, cGroupCode, cCompanyCode, cBusUnitCode)
/*/
Static Function RU05R0705_GetCompanyInfo(cType, cGroupCode, cCompanyCode, cBusUnitCode)
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
{Protheus.doc} RU05R0706_GetBranchInfo()
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
    @example RU05R0706_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
/*/
Static Function RU05R0706_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
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
                   
                   
