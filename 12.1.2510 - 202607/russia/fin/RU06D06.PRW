#Include "PROTHEUS.CH"
#Include "PARMTYPE.CH"
#Include "FWMVCDEF.CH"
#Include "TOPCONN.CH"
#Include "TOTVS.CH"

Static __cTabHdr  := "F49"
Static __cTabItm  := "F4B"
Static __cVrtItm  := "B"
Static __cProgram := "RU06D06"
Static __cHeadPrg := "RU06D05"
Static __cHeadMdl := __cHeadPrg+"_MF49"
Static __cGridMdl := __cHeadPrg+"_MF4B"
Static __cVirtMdl := __cHeadPrg+"_MVIRT"
Static __cExRatDt := __cTabHdr+"_DTPAYM"
Static __cActPayD := __cTabHdr+"_DTACTP"
Static __cVATRate := __cTabHdr+"_VATRAT"
Static __cNatures := __cTabHdr+"_CLASS"
Static __cValue   := __cTabHdr+"_VALUE"
Static __cVATAMT  := __cTabHdr+"_VATAMT"
Static __cReason  := __cTabHdr+"_REASON"
Static __cCurren  := "_CURREN"
Static __cVrtFil  := "_BRANCH"
Static __aCanChVr := {"B_CHECK", "B_VALPAY", "B_EXGRAT", "B_BSVATC", "B_VLVATC"}
Static __aRmvView := {__cTabHdr+"_FILREQ"}

//https://jiraproducao.totvs.com.br/browse/RULOC-44
//FI-CF-25-17 [Payment order without a payment requests]

Static Function ViewDef()

    Local oModel    as Object
    Local oView 	as Object
    
    oModel := FwLoadModel(__cProgram)
    oView  := RU06D05492_RetView(oModel)
    RU06D06009_ConfigView(oView)

Return oView

Static Function ModelDef()

    Local oModel     As Object
    Local oGridMdl   As Object
    Local oVirtMdl   As Object
    Local aStruct    As Array

    aStruct := {}

    oModel   := MPFormModel():New(__cProgram)
    aStruct  := RU06D05490_RetStructs()
    RU06D06004_ChangeStructs(aStruct)
    oModel   := RU06D05491_(__cProgram, oModel, aStruct)
    oGridMdl := oModel:GetModel(__cGridMdl)
    oGridMdl:SetNoInsertLine(.F.)
    oGridMdl:SetNoUpdateLine(.F.)
    oGridMdl:SetNoDeleteLine(.F.)
    oVirtMdl := oModel:GetModel(__cVirtMdl)
    //Block for updating first empty line
    oVirtMdl:SetNoUpdateLine(.T.)
    oVirtMdl:SetNoDeleteLine(.T.)
    oVirtMdl:SetNoInsertLine(.T.)

Return oModel


/* {Protheus.doc} RU06D06001_AddBills
This function used for adding lines to __cGridMdl and __cVirtMdl from
oTempTable when we press button in menu Add bills
@param  Object      oTempTable   // Temporary table with data from AP's
        Object      oMoreDlg     // link to Dialog
        Character   cMark        // mark for selected lines
@return Logical     lRet
@author astepanov
@since 15 October 2020
@version 1.0
@project MA3 - Russia
*/
Function RU06D06001_AddBills(oTempTable, oMoreDlg, cMark)
    Local   lRet       As Logical
    Local   lNoAddFtLn As Logical
    Local   oModel     As Object
    Local   oHeadMdl   As Object
    Local   oGridMdl   As Object
    Local   oVirtMdl   As Object
    Local   aHeadFld   As Array
    Local   aGridFld   As Array
    Local   aVirtFld   As Array
    Local   aInput     As Array
    Local   aArea      As Array
    Local   aError     As Array
    Local   aTotal     As Array
    Local   cErrMsg    As Character
    Local   cAlias     As Character
    Local   nGridLen   As Numeric
    Local   nVirtLen   As Numeric

    lRet     := .T.
    cErrMsg  := ""
    aArea    := GetArea()
    oModel   := FWModelActive()
    lRet     := IIF(oModel == Nil, .F., lRet)
    If lRet
        oHeadMdl := oModel:GetModel(__cHeadMdl)
        oGridMdl := oModel:GetModel(__cGridMdl)
        oVirtMdl := oModel:GetModel(__cVirtMdl)
        aHeadFld := ACLONE(oHeadMdl:GetStruct():GetFields())
        aGridFld := ACLONE(oGridMdl:GetStruct():GetFields())
        aVirtFld := ACLONE(oVirtMdl:GetStruct():GetFields())
        aInput   := RU06XFUN45_RetF5MnVrtLnsFromAPs(oTempTable,cMark,FwFldGet(__cExRatDt),oHeadMdl)
        cErrMsg  := aInput[2]
        cAlias   := ""
        If !Empty(cErrMsg)
            lRet    := .F.
        Else
            cAlias := aInput[1]:GetAlias()
            DBSelectArea(cAlias)
            DbGoTop()
        EndIf
        lNoAddFtLn := oVirtMdl:IsEmpty() .AND. oGridMdl:IsEmpty()
        oVirtMdl:SetNoInsertLine(.F.)
        oVirtMdl:SetNoUpdateLine(.F.)
        oVirtMdl:SetNoDeleteLine(.F.)
        While lRet .AND. !Eof()
            nGridLen := oGridMdl:Length()
            If lNoAddFtLn .OR. nGridLen < oGridMdl:AddLine()
                //LoadValues to GridModel
                lRet := RU06D06002_LoadValuesToGridMdl(cAlias,oGridMdl,aGridFld)
            Else
                lRet := .F.
            EndIf
            lRet := IIF(oModel:HasErrorMessage(),.F.,lRet)
            nVirtLen := oVirtMdl:Length()
            If lRet .AND. (lNoAddFtLn .OR. nVirtLen < oVirtMdl:AddLine())
                //LoadValues to VirtModel
                lRet := RU06D06003_LoadValuesToVirtMdl(cAlias,oVirtMdl,aVirtFld)
            Else
                lRet := .F.
            EndIf
            lRet := IIF(oModel:HasErrorMessage(),.F.,lRet)
            DBSkip()
            lNoAddFtLn := .F.
        EndDo
        oVirtMdl:SetNoInsertLine(.T.)
        oVirtMdl:GoLine(1)
        If !Empty(cAlias)
            If lRet
                // https://jiraproducao.totvs.com.br/browse/RULOC-964
                (cAlias)->(DBGoBottom())
                lRet := lRet .AND. RU06D06005_UpdateVATRate((cAlias)->B_ALIMP1)
                lRet := lRet .AND. RU06D06006_UpdateNatures((cAlias)->B_CLASS)
            EndIf
            (cAlias)->(DBCloseArea())
            aInput[1]:Delete()
        EndIf
    EndIf
    If lRet
        aTotal := RU06D07E7_RetTotalsForHeader(oVirtMdl, "VRT", .F.)
        lRet   := lRet .AND. RU06D06007_UpdateTotals(aTotal[1],aTotal[2])
        lRet   := lRet .AND. RU06D06008_UpdateReason()
    EndIf
    If oMoreDlg != Nil .AND. ValType(oMoreDlg) == "O"
        oMoreDlg:End()
    EndIf
    RestArea(aArea)
    If !lRet
        If     !Empty(cErrMsg)
            HELP("", 1, "", ,;
                 cErrMsg,;
                 1,0,,,,,,   )
        ElseIf oModel:HasErrorMessage()
            aError := oModel:GetErrorMessage()
            HELP("",1, aError[MODEL_MSGERR_IDFORM],,;  //Form
                aError[MODEL_MSGERR_IDFIELDERR] + " "+;
                aError[MODEL_MSGERR_MESSAGE],;    //Field and error
                1,0,,,,,,;
                {aError[MODEL_MSGERR_SOLUCTION]}) //Solution   
        EndIf  
    EndIf
Return lRet  // End of RU06D06001_AddBills


/* {Protheus.doc} RU06D06002_LoadValuesToGridMdl
This function used when we load values from temporary table (cAlias)
generated by RU06XFUN45_RetF5MnVrtLnsFromAPs
to fields aGridFld located in oGridMdl
@param  Character   cAlias
        Object      oGridMdl     // grid model with id __cGridMdl
        Array       aGridFld     // fields in oGridMdl
@return Logical     lRet
@author astepanov
@since 15 October 2020
@version 1.0
@project MA3 - Russia
*/
Static Function RU06D06002_LoadValuesToGridMdl(cAlias,oGridMdl,aGridFld)
    Local   lRet        As Logical
    Local   nX          As Numeric
    lRet := .T.
    nX   := 1
    While lRet .AND. nX <= Len(aGridFld)
        lRet := oGridMdl:LoadValue(aGridFld[nX][MODEL_FIELD_IDFIELD],(cAlias)->&(aGridFld[nX][MODEL_FIELD_IDFIELD]))
        nX := nX + 1
    EndDo
    lRet := lRet .AND. FwFldPut(__cTabItm+"_FILIAL",(cAlias)->&(__cVrtItm+__cVrtFil))
    lRet := lRet .AND. FwFldPut(__cTabItm+"_IDF49" ,FwFldGet(__cTabHdr+"_IDF49")    )
    lRet := lRet .AND. FwFldPut(__cTabItm+"_UUID",  FWUUIDV4()                      )

Return lRet //End of RU06D06002_LoadValuesToGridMdl()


/* {Protheus.doc} RU06D06003_LoadValuesToVirtMdl
This function used when we load values from temporary table (cAlias)
generated by RU06XFUN45_RetF5MnVrtLnsFromAPs
to fields aVirtFld located in oVirtMdl
@param  Character   cAlias
        Object      oVirtMdl     // grid model with id __cVirtMdl
        Array       aVirtFld     // fields in oVirtMdl
@return Logical     lRet
@author astepanov
@since 15 October 2020
@version 1.0
@project MA3 - Russia
*/
Static Function RU06D06003_LoadValuesToVirtMdl(cAlias,oVirtMdl,aVirtFld)
    Local   lRet        As Logical
    Local   nX          As Numeric
    lRet := .T.
    nX   := 1
    While lRet .AND. nX <= Len(aVirtFld)
        lRet := oVirtMdl:LoadValue(aVirtFld[nX][MODEL_FIELD_IDFIELD],(cAlias)->&(aVirtFld[nX][MODEL_FIELD_IDFIELD]))
        nX := nX + 1
    EndDo
Return lRet //End of RU06D06003_LoadValuesToVirtMdl()

/* {Protheus.doc} RU06D06004_ChangeStructs
Here we change field properties for all structers used by oModel
@param  Array       aStruct      // Array of structers used by oModel
                                 // look to ModelDef()
@return Nil
@author astepanov
@since 15 October 2020
@version 1.0
@project MA3 - Russia
*/
Static Function RU06D06004_ChangeStructs(aStruct)

    Local oStrHdr     As Object
    Local oStrGrd     As Object
    Local oStrVrt     As Object
    Local aGridFld    As Array
    Local aGridVrt    As Array
    Local nX          As Numeric
    Local nY          As Numeric

    oStrHdr      := aStruct[1]
    oStrGrd      := aStruct[3]
    oStrVrt      := aStruct[4]

    aGridFld := oStrGrd:GetFields()
    // make all fields changable in __cGridMdl, [nX][8] = bWhen
    For nX := 1 To Len(aGridFld)
        aGridFld[nX][MODEL_FIELD_WHEN] := {|| .T.}
    Next nX
    // define fields which can be changed by the user in __cVirtMdl
    aGridVrt := oStrVrt:GetFields()
    For nX := 1 To Len(__aCanChVr)
        nY := ASCAN(aGridVrt,{|x| x[MODEL_FIELD_IDFIELD] == __aCanChVr[nX] }) 
        If nY > 0
            aGridVrt[nY][MODEL_FIELD_WHEN] := {|| .T.}
        EndIf   
    Next nX

Return Nil //End of RU06D06004_ChangeStructs()


Static Function RU06D06005_UpdateVATRate(nVATRate)
    Local lRet       As Logical
    lRet := .T.
    If Empty(FwFldGet(__cVATRate))
        lRet := lRet .AND. FWFldPut(__cVATRate,nVATRate)
    EndIf
Return lRet //End of RU06D06005_UpdateVATRate

Static Function RU06D06006_UpdateNatures(cNatures)
    Local lRet       As Logical
    lRet := .T.
    If !Empty(cNatures) .AND. Empty(FwFldGet(__cNatures))
        lRet := lRet .AND. FWFldPut(__cNatures,cNatures)
    EndIf
Return lRet //End of RU06D06006_UpdateNatures

Static Function RU06D06007_UpdateTotals(nValue, nVATAmount)
    Local lRet       As Logical
    lRet := .T.
    lRet := lRet .AND. FwFldPut(__cValue,nValue)
    lRet := lRet .AND. FwFldPut(__cVATAMT,nVATAmount)
Return lRet //End of RU06D06007_UpdateTotals

Function RU06D06008_UpdateReason()
    Local lRet       As Logical
    Local oModel     As Object
    Local nX         As Numeric
    Local cVirtModel As Character
    Local cReason    As Character
    lRet   := .T.
    oModel := FWModelActive()
    nX     := 0
    If oModel != Nil .AND. oModel:GetID() == __cProgram
        cVirtModel := __cVirtMdl
        nX := oModel:GetModel(cVirtModel):GetLine()
        cReason    := __cReason
    ElseIf oModel != Nil .AND. oModel:GetID() == "RU06D07"
        cVirtModel := "RU06D07_MVIRT"
        nX := oModel:GetModel(cVirtModel):GetLine()
        cReason    := "F4C_REASON"
    EndIf
    lRet := lRet .AND. FwFldPut(cReason,RU06XFUN19_ReasonText())
    If nX > 0
        oModel:GetModel(cVirtModel):GoLine(nX)    
    EndIf
Return lRet //End of RU06D06008_UpdateReason

Static Function RU06D06009_ConfigView(oView)
    Local oStrVrt     As Object
    Local oStrHdr     As Object
    Local nX          As Numeric

    oStrVrt := oView:GetViewStruct(__cVirtMdl)
    oStrHdr := oView:GetViewStruct(__cHeadMdl)
    For nX := 1 To Len(__aCanChVr)
        oStrVrt:SetProperty(__aCanChVr[nX], MVC_VIEW_CANCHANGE, .T.)
    Next nX
    //remove fields from view 
    //https://jiraproducao.totvs.com.br/browse/RULOC-1011
    For nX := 1 To Len(__aRmvView)
        oStrHdr:RemoveField(__aRmvView[nX])
    Next nX

Return Nil


/* {Protheus.doc} RU06D06010_ValidExRatDate
We use this function when validate _cTabHdr+"_CURREN" field.
also we can use it for validation __cExRatDt.

When we change validation field, we recalculate excange rates in
__cVirtMdl and update related values. Look at the method
GridLinePreVld() in RU06D05EventRUS.PRW
@param  
@return Nil
@author astepanov
@since 28 October 2020
@version 1.0
@project MA3 - Russia
*/
Function RU06D06010_ValidExRatDate()

    Local lRet     As Logical
    Local oModel   As Object
    Local oVirtMdl As Object
    Local oHdrMdl  As Object
    Local nPos     As Numeric
    Local nX       As Numeric
    Private lUpdReason As Logical

    lRet       := .T.
    oModel     := FWModelActive()
    // we set private var lUpdReason
    // for preventing reason changing
    // when we change each line in __cVirtMdl
    // so we should update reason additionally
    lUpdReason := .F.
    If oModel != Nil .AND. oModel:GetID() == __cProgram
        oVirtMdl := oModel:GetModel(__cVirtMdl)
        oHdrMdl  := oModel:GetModel(__cHeadMdl)
        If !oVirtMdl:IsEmpty()
            oVirtMdl:SetNoUpdateLine(.F.)
            nPos     := oVirtMdl:GetLine()
            nX       := 1
            While lRet .AND. nX <= oVirtMdl:Length()
                oVirtMdl:GoLine(nX)
                // so we change currency when we have no flag for manual changed
                // currency and when currency in the line not equal to currency in the header
                If !oVirtMdl:IsDeleted() .AND. oVirtMdl:GetValue("B_CHECK") == .F. .AND.;
                   RU06D06011_CanChangeExchangeRateInLine(oVirtMdl,oHdrMdl)
                    // when we use this setvalue combination, currency will be updated
                    lRet := lRet .AND. oVirtMdl:SetValue("B_CHECK",.T.)
                    lRet := lRet .AND. oVirtMdl:SetValue("B_CHECK",.F.)
                EndIf
                nX := nX + 1
            EndDo
            oVirtMdl:GoLine(nPos)
            If lRet
                // update reason
                lUpdReason := .T.
                lRet := lRet .AND. RU06D06008_UpdateReason()
            EndIf
        EndIf
    EndIf
Return  lRet // End of RU06D06010_ValidExRatDate

/* {Protheus.doc} RU06D06011_CanChangeExchangeRateInLine
This function keeps main rule when we have possibility
to change excange rate in the grid line:
Currency in the line should not be equal to currency in 
the header
Or for example: B_CURREN <> Val(F49_CURREN)
@param  Object      oGridMdl  // link to the __cVirtMdl or __cGridMdl
        Object      oHdrMdl   // link to the __cHeadMdl
@return Logiacl     lRet      // .T. - possible, .F. - impossible
@author astepanov
@since 31 October 2020
@version 1.0
@project MA3 - Russia
*/
Function RU06D06011_CanChangeExchangeRateInLine(oGridMdl,oHdrMdl)
    Local lRet       As Logical
    Local cGridPrefx As Character
    Local cTabHdr    As Character
    Local cCurren    As Character

    cTabHdr := __cTabHdr
    cCurren := __cCurren
    If oHdrMdl:GetID() == "RU06D07_MHEAD"
        cTabHdr = "F4C"
    EndIf
    If     oGridMdl:GetID() == __cVirtMdl
        cGridPrefx := __cVrtItm
    ElseIf oGridMdl:GetID() == __cGridMdl
        cGridPrefx := __cTabItm
    ElseIf oGridMdl:GetID() == "RU06D07_MVIRT"
        cGridPrefx := __cVrtItm
    EndIf
        
    If oGridMdl:GetValue(cGridPrefx+cCurren) <> Val(oHdrMdl:GetValue(cTabHdr+cCurren))
        lRet := .T.
    Else
        lRet := .F.
    EndIf

Return lRet //End of RU06D06011_CanChangeExchangeRateInLine                   
//Merge Russia R14 
                   
