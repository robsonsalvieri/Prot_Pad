#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "ru09t10.ch"
#INCLUDE "ru09xxx.ch"

/*/{Protheus.doc} RU09T10EventRUS
Class to manage the RU09T10 routine events
@type Class
@author Leandro Nunes
@project MA3 - Russia
@since 20/11/2023
/*/
Class RU09T10EventRUS From FwModelEvent

	Method New() Constructor
    Method Activate()
    Method FieldPreVld()
    Method ModelPosVld()
    Method GridLinePreVld()
    Method GridLinePosVld()

EndClass

/*/{Protheus.doc} RU09T10EventRUS:New()
Constructor of the class RU09T10EventRUS
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 20/11/2023
/*/
Method New() Class RU09T10EventRUS
Return()

/*/{Protheus.doc} RU09T10EventRUS:Activate()
Method does additional neccesary things after model's activation
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 20/11/2023
@param oModel, Object,  Model to be saved
@param lCopy,  Logical
@return lRet,  Logical, If saving process is ok
/*/
Method Activate(oModel As Object, lCopy As Logical) Class RU09T10EventRUS

    Local lRet       As Logical
    Local nOperation As Numeric
    Local cF37_Type  As Character
 
    Local cDescLC    As Character
    Local oStr       As Object
    Local oView      As Object
    Local oModelF37  As Object
	
    Default lCopy := .F.

    lRet := .T.
    cDescLC:= ""
    cF37_Type := AllTrim(FwFldGet("F37_TYPE"))
    nOperation := oModel:GetOperation()

    If (cF37_Type == "1" .And. nOperation == MODEL_OPERATION_UPDATE)
        oModel:GetModel("F38detail"):SetNoInsertLine(.T.)
        oModel:GetModel("SE2detail"):SetNoInsertLine(.T.)
    EndIf

    oView := FwViewActive()
    If (ValType(oView) == "O" .And. oView:GetModel():GetId() == "RU09T10")
        If ((cF37_Type != "2") .And. nOperation == MODEL_OPERATION_UPDATE)
            oStr := oView:GetViewStruct("VIEW_F37M")
            oStr:SetProperty("F37_FORNEC", MVC_VIEW_CANCHANGE, .F.)
            oStr:SetProperty("F37_INVCUR", MVC_VIEW_CANCHANGE, .F.)
            oStr:SetProperty("F37_BRANCH", MVC_VIEW_CANCHANGE, .F.)
        EndIf
        //Virtual fields filling there:
        If (cF37_Type == "3" .and. nOperation == MODEL_OPERATION_VIEW)
            RU09T10020(FwFldGet("F37_CONTRA"), @cDescLC)
            If AllTrim(cDescLC) != ""
                oModelF37 := oModel:GetModel("F37master")
                oModelF37:LoadValue("F37_F5QDES", cDescLC) //Legal Contracts Description
            EndIf
        EndIf
    EndIf

Return(lRet)

/*/{Protheus.doc} RU09T10EventRUS:FieldPreVld()
Method does fields pre validation
@type Method
@author Leandro Nunes
@project MA3 - Russia
@since 20/11/2023
@param oSubModel, Object,    Active submodel
@param cSubModID, Character, Active Submodel's Id
@param cAction,   Character, Type of action being performed
@param cField,    Character, Name of the active field
@param xValue,    Variant,   Value of the active field
@return lRet,     Logical,   If validation process is ok														
/*/
Method FieldPreVld(oSubModel As Object, cSubModID As Character, cAction As Character, cField As Character, xValue As Variant) Class RU09T10EventRUS

    Local lRet       As Logical
    Local oModel     As Object
    Local nLine      As Numeric
    Local nI         As Numeric
    Local nVatBs1    As Numeric
    Local nVatVl1    As Numeric
    Local nVatBs1Sum As Numeric
    Local nVatVl1Sum As Numeric
    Local nCurRate   As Numeric
    Local cQuery     As Character
    Local cTab       As Character
    Local nTemRv     As Numeric

    lRet := .T.

    If lRet .And. (cSubModID == "F37master") .And. (cAction == "SETVALUE") .And. (cField == "F37_ADJDT")
        If !(Empty(FWFldGet("F37_PDATE")) .Or. (xValue >= FWFldGet("F37_PDATE")))
            lRet := .F.
            Help("", 1, "RU09T10EventRUS:FieldPreVld:01", , STR0021, 1, 0) // "Print Date can not be greater than Adjustment Date"
        EndIf
    EndIf

    If lRet .And. (cSubModID == "F37master") .And. (cAction == "SETVALUE") .And. (cField $ "F37_INVCUR|F37_PDATE") .And. (FWFldGet("F37_TYPE") == "2")
        If (lRet .And. cField == "F37_INVCUR")
            lRet := lRet .And. (ExistCpo('CTO', xValue, 1))
        EndIf

        If (lRet .And. cField == "F37_INVCUR")
            cQuery := "SELECT " + CRLF 
            cQuery += "    CTO_SIMB " + CRLF 
            cQuery += "FROM " + RetSQLName("CTO") + " " + CRLF 
            cQuery += "WHERE " + CRLF
            cQuery += "    CTO_FILIAL = '" + xFilial("CTO") + "' AND " + CRLF 
            cQuery += "    CTO_MOEDA = '" + IIf(cField == "F37_INVCUR", xValue, FWFldGet("F37_INVCUR")) + "' AND " + CRLF 
            cQuery += "    D_E_L_E_T_ = ' ';"
            cTab := MPSysOpenQuery(ChangeQuery(cQuery))
            If !oSubModel:LoadValue("F37_ICUDES", (cTab)->CTO_SIMB)
                lRet := .F.
                Help("", 1, "RU09T10EventRUS:FieldPreVld:02",, STR0017 + X3Titulo("F37_ICUDES") + STR0018, 1, 0) // "The field " " was not loaded"
            EndIf
            CloseTempTable(cTab)
        EndIf

        If (lRet)
            nCurRate := RecMoeda(IIf(cField == "F37_PDATE", DToS(xValue), DToS(FWFldGet("F37_PDATE"))), IIf(cField == "F37_INVCUR", xValue, (FWFldGet("F37_INVCUR"))))
            If !oSubModel:LoadValue("F37_C_RATE", nCurRate)
                lRet := .F.
                Help("", 1, "RU09T10EventRUS:FieldPreVld:03",, STR0017 + X3Titulo("F37_C_RATE") + STR0018, 1, 0) // // "The field " " was not loaded" 
            EndIf
        EndIf

        If lRet
            oModel := FWModelActive()
            nLine := oModel:GetModel("F38detail"):GetLine()
            nVatBs1Sum := 0
            nVatVl1Sum := 0
            For nI := 1 to oModel:GetModel("F38detail"):Length()
                oModel:GetModel("F38detail"):GoLine(nI)
                nVatBs1 := Round(FWFldGet("F38_VATBS") * nCurRate, 2)
                nVatVl1 := Round(FWFldGet("F38_VATVL") * nCurRate, 2)
                nVatBs1Sum += nVatBs1
                nVatVl1Sum += nVatVl1
                If !oModel:GetModel("F38detail"):LoadValue("F38_VATBS1", nVatBs1)
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:FieldPreVld:04",, STR0017 + X3Titulo("F38_VATBS1") + STR0018, 1, 0) // "The field " " was not loaded"
                    Exit
                ElseIf !oModel:GetModel("F38detail"):LoadValue("F38_VATVL1", nVatVl1)
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:FieldPreVld:05",, STR0017 + X3Titulo("F38_VATVL1") + STR0018, 1, 0) // "The field " " was not loaded"
                    Exit
                EndIf
            Next nI
            oModel:GetModel("F38detail"):GoLine(nLine)

            If !oSubModel:LoadValue("F37_VATBS1", nVatBs1Sum)
                lRet := .F.
                Help("", 1, "RU09T10EventRUS:FieldPreVld:06",, STR0017 + X3Titulo("F37_VATBS1") + STR0018, 1, 0) // "The field " " was not loaded"
            ElseIf !oSubModel:LoadValue("F37_VATVL1", nVatVl1Sum)
                lRet := .F.
                Help("", 1, "RU09T10EventRUS:FieldPreVld:07",, STR0017 + X3Titulo("F37_VATVL1") + STR0018, 1, 0) // "The field " " was not loaded"
            EndIf
        EndIf

        If lRet .And. cSubModID == "F38detail" .And. cAction == "SETVALUE" .And. cField $ "F38_VALUE|F38_VATCOD|F38_VALGR" .And. FWFldGet("F37_TYPE") == "3"
            nValGr := FWFldGet("F38_VALGR")
            nTxMoeda := FWFldGet("E2_TXMOEDA")
            If !oModel:GetModel("F38detail"):LoadValue("F38_ORIGGR", nValGr / nTxMoeda)
                lRet := .F.
                Help("", 1, "RU09T10EventRUS:FieldPreVld:08",, STR0017 + X3Titulo("F38_ORIGGR") + STR0018, 1, 0) // "The field " " was not loaded"
            EndIf
        EndIf

        If lRet .And. cSubModID == "F38detail" .And. cAction == "SETVALUE" .And. cField == "F38_VATCOD" .And. FWFldGet("F37_TYPE") == "3"
            nTemRv := Posicione("F31", 1, xFilial("F31") + AllTrim(FWFldGet("F38_VATCOD")), "F31_RV_COD")
            If nTemRv <= 0
                lRet := .F.
            EndIf 

            If lRet
                Help("", 1, "RU09T10EventRUS:FieldPreVld:09",, "It is mandatory to select a VAT code that has the reverse code configured!" + X3Titulo("F38_ORIGGR") + STR0018, 1, 0) // "It is mandatory to select a VAT code that has the reverse code configured!"
            EndIf
        EndIf

        If (lRet)
            oView := FwViewActive()
            If (ValType(oView) != "U")
                oView:Refresh("VIEW_F37T")
            EndIf
        EndIf
    EndIf

Return(lRet)

/*/{Protheus.doc} RU09T10EventRUS:GridLinePreVld()
Method does grid pre validation
@type Method
@author Leandro Nunes
@project MA3 - Russia
@since 20/11/2023
@param oSubModel, Object,    Active submodel
@param cSubModID, Character, Active Submodel's Id
@param nLineVld,  Numerical, Active line number
@param cAction,   Character, Type of action being performed
@param cField,    Character, Name of the active field
@param xValue,    Variant,   Value of the active field
@param xOldValue, Variant,   Old Value of the active field
@return lRet,     Logical,   If validation process is ok
/*/
Method GridLinePreVld(oSubModel As Object, cSubModID As Character, nLineVld As Numerical, cAction As Character, cField As Character, xValue As Variant, xOldValue As Variant) Class RU09T10EventRUS

    Local lRet As Logical
    Local cInvDoc As Character
    Local cInvSer As Character
    Local nI As Numeric
    Local nLine As Numeric
    Local cCFExt As Character
    Local oModel As Object
    Local oModelF37 As Object
    Local oModelF38 As Object
    Local oModelSE2 As Object
    Local lCanInsLin As Logical

    lRet := .T.
    cCFExt := ""

    If Type("lRecursion") == "U"
        Private lRecursion := .F.
    EndIf

    // Prevents prevalidation from recursion.
    If (lRecursion == .T.)
        // If it is recursion, just skip everything and return true.
    Else
        lRecursion := .T.

        If lRet .And. (cSubModID $ "F38detail|SE2detail") .And. (cAction $ "DELETE|UNDELETE|SETVALUE")
            oModel := FWModelActive()
            If (ValType(oModel) != "O") .Or. (oModel:getId() != "RU09T10")
                lRet := .F.
                Help("", 1, "RU09T10EventRUS:GridLinePreVld:01",, STR0910, 1, 0)
            Else
                oModelF37 := oModel:GetModel("F37master")
                oModelF38 := oModel:GetModel("F38detail")
                oModelSE2 := oModel:GetModel("SE2detail")
            EndIf

            If lRet .And. ((cAction == "DELETE") .Or. (cAction == "UNDELETE")) .And. oModelF37:GetValue("F37_TYPE") == "1"
                dMiDa	:= oModelF37:GetValue("F37_PDATE")
                cHeadDc	:= oModelF37:GetValue("F37_INVDOC")
                If (cSubModID == "F38detail")
                    cInvDoc := oModelF38:GetValue("F38_INVDOC")
                    cInvSer	:= oModelF38:GetValue("F38_INVSER")
                ElseIf (cSubModID == "SE2detail")
                    cInvDoc := oModelSE2:GetValue("E2_NUM")
                    cInvSer	:= oModelSE2:GetValue("E2_PREFIXO")
                EndIf

                If lRet
                    nLine := oModelF38:GetLine()
                    For nI := 1 To oModelF38:Length()
                        oModelF38:GoLine(nI)
                        If (alltrim(cInvDoc) == alltrim(oModelF38:GetValue("F38_INVDOC")) .And. cInvSer == oModelF38:GetValue("F38_INVSER"))
                            If ((cAction == "DELETE") .And. (!oModelF38:IsDeleted()))
                                oModelF38:DeleteLine()
                            ElseIf ((cAction == "UNDELETE") .And. (oModelF38:IsDeleted()))
                                oModelF38:UnDeleteLine()
                            EndIf
                        EndIf
                    Next nI
                    oModelF38:GoLine(nLine)

                    // Goes thougth the Puchases Invoices grid and finds the first related line.
                    nLine := oModelSE2:GetLine()
                    For nI := 1 To oModelSE2:Length()
                        oModelSE2:GoLine(nI)
                        If Alltrim(cInvDoc) == Alltrim(oModelSE2:GetValue("E2_NUM")) .And. cInvSer == oModelSE2:GetValue("E2_PREFIXO")
                            If cAction == "DELETE" .And. !oModelSE2:IsDeleted()
                                oModelSE2:DeleteLine()
                                //if we delete invoice from f37_pdate we need find new
                                if (dMiDa == oModelSE2:GetValue("E2_EMISSAO"))
                                    dMiDa1 := SToD("19000101")
                                    oModelSE2:GoLine(1)
                                    For nI := 1 To oModelSE2:Length()
                                        oModelSE2:GoLine(nI)
                                        if !oModelSE2:IsDeleted()
                                            If dMiDa1 < oModelSE2:GetValue("E2_EMISSAO")
                                                dMiDa1	:= oModelSE2:GetValue("E2_EMISSAO")
                                                cHeadDc	:= AllTrim(oModelSE2:GetValue("E2_NUM"))
                                            EndIf
                                        EndIf
                                    Next nI
                                    oModelF37:LoadValue("F37_PDATE", dMida1)
                                    oModelF37:LoadValue("F37_INVDOC", cHeadDc)
                                EndIf
                                dMida1 := oModelF37:GetValue("F37_PDATE")
                            ElseIf ((cAction == "UNDELETE") .And. (oModelSE2:IsDeleted()))
                                oModelSE2:UnDeleteLine()
                                //if we undelete invoice with max date we need set its value un f37_pdate
                                If (dMiDa < oModelSE2:GetValue("E2_EMISSAO"))
                                    dMiDa1	:= oModelSE2:GetValue("E2_EMISSAO")
                                    cHeadDc	:= oModelSE2:GetValue("E2_NUM")
                                Else
                                    dMiDa1 := dMiDa
                                EndIf
                                dMiDa1	:= max(dMiDa, oModelSE2:GetValue("E2_EMISSAO"))
                                oModelF37:LoadValue("F37_PDATE", dMida1)
                                oModelF37:LoadValue("F37_INVDOC", cHeadDc)
                            EndIf
                        EndIf
                    Next nI
                    oModelSE2:GoLine(nLine)
                EndIf
            EndIf

            If lRet .And. cSubModID == "F38detail" .And. cAction == "SETVALUE" .And. cField $ "F38_VATBS|F38_VATVL|F38_VALGR|F38_VATBS1|F38_VATVL1|F38_VALUE" .And. FWFldGet("F37_TYPE") == "2"
                cAlias := "F37" + SubStr(cField, 4, Len(cField))
                If !oModelF37:LoadValue(cAlias, FWFldGet(cAlias) + Round(xValue, 2) - Round(xOldValue, 2))
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:GridLinePreVld:02",, STR0017 + X3Titulo(cAlias) + STR0018, 1, 0) // STR0017 STR0018 "The field " " was not loaded"
                EndIf
            EndIf

            If lRet .And. cSubModID == "F38detail" .And. cAction $ "DELETE|UNDELETE"
                If (cAction == "DELETE")
                    nSign := -1
                ElseIf (cAction == "UNDELETE")
                    nSign := 1
                EndIf

                If !oModelF37:LoadValue("F37_VATVL", FWFldGet("F37_VATVL") + nSign * FWFldGet("F38_VATVL"))
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:GridLinePreVld:03",, STR0017 + X3Titulo("F37_VATVL") + STR0018, 1, 0) // "The field " " was not loaded"
                ElseIf !oModelF37:LoadValue("F37_VALGR", FWFldGet("F37_VALGR") + nSign * FWFldGet("F38_VALGR"))
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:GridLinePreVld:04",, STR0017 + X3Titulo("F37_VALGR") + STR0018, 1, 0) // "The field " " was not loaded"
                ElseIf !oModelF37:LoadValue("F37_VATBS", FWFldGet("F37_VATBS") + nSign * FWFldGet("F38_VATBS"))
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:GridLinePreVld:05",, STR0017 + X3Titulo("F37_VATBS") + STR0018, 1, 0) // "The field " " was not loaded"
                ElseIf !oModelF37:LoadValue("F37_VATVL1", FWFldGet("F37_VATVL1") + nSign * FWFldGet("F38_VATVL1"))
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:GridLinePreVld:06",, STR0017 + X3Titulo("F37_VATVL1") + STR0018, 1, 0) // "The field " " was not loaded"
                ElseIf !oModelF37:LoadValue("F37_VATBS1", FWFldGet("F37_VATBS1") + nSign * FWFldGet("F38_VATBS1"))
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:GridLinePreVld:07",, STR0017 + X3Titulo("F37_VATBS1") + STR0018, 1, 0) // "The field " " was not loaded"
                ElseIf !oModelF37:LoadValue("F37_VALUE", FWFldGet("F37_VALUE") + nSign * FWFldGet("F37_VALUE"))
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:GridLinePreVld:08",, STR0017 + X3Titulo("F37_VALUE") + STR0018, 1, 0) // "The field " " was not loaded"
                EndIf

                For nI := 1 To oModelF38:Length(.F.)
                    oModelF38:GoLine(nI)
                    If !(oModelF38:GetValue("F38_VATCD2") $ cCFExt); // if a code is already in the string of all the codes, skip it
                        .and. !(nI != nLineVld .and. oModelF38:IsDeleted()); // skip deleted lines if action is not about them
                        .and. !(nI == nLineVld .and. cAction == "DELETE") // skip a validating line, if it is going to be deleted
                        cCFExt += AllTrim(oModelF38:GetValue("F38_VATCD2")) + ";"
                    EndIf
                Next nI
                oModelF38:GoLine(nLineVld)

                If !Empty(cCFExt)
                    cCFExt := Left(cCFExt, Len(cCFExt)-1)
                EndIf

                If !oModelF37:LoadValue("F37_VATCD2", cCFExt)
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:GridLinePreVld:09",, STR0017 + X3Titulo("F37_VATCD2") + STR0018, 1, 0) // "The field " " was not loaded"
                EndIf
            EndIf
            
            If lRet .And. cSubModID == "F38detail" .And. cAction == "SETVALUE" .And. cField == "F38_VATCD2"
                lCanInsLin := oModelF38:CanInsertLine()
                oModelF38:SetNoInsertLine(.F.)
                cCFExt := AllTrim(oModelF37:GetValue("F37_VATCD2"))
                If !oModelF38:IsDeleted() .And. !(xValue $ cCFExt)
                    If !Empty(cCFExt)
                        cCFExt += ";"
                    EndIf
                    cCFExt += AllTrim(xValue) + ";"
                EndIf
                oModelF38:SetNoInsertLine(!lCanInsLin)

                If !oModelF37:LoadValue("F37_VATCD2", cCFExt)
                    lRet := .F.
                    Help("", 1, "RU09T10EventRUS:GridLinePreVld:10",, STR0017 + X3Titulo("F37_VATCD2") + STR0018, 1, 0) // "The field " " was not loaded"
                EndIf
            EndIf
        EndIf

        If lRet .And. (cAction != "CANSETVALUE") .And. (cAction != "ISENABLE")
            oView := FwViewActive()
            If (ValType(oView) != "U")
                oView:Refresh("VIEW_F37T")
            EndIf
        EndIf
        
        lRecursion := .F.
    EndIf

Return(lRet)

/*/{Protheus.doc} RU09T10EventRUS:GridLinePosVld()
Method does grid pos validation
@type Method
@author Leandro Nunes
@project MA3 - Russia
@since 20/11/2023
@param oSubModel, Object,    Active submodel
@param cSubModID, Character, Active Submodel's Id
@return lRet,     Logical,   If validation process is ok
/*/
Method GridLinePosVld(oSubModel As Object, cSubModID As Character) Class RU09T10EventRUS

    Local lRet := .T.

    If lRet .And. (cSubModID == "F38detail")
        If Empty(oSubModel:GetValue("F38_DESC"))
            lRet := .F.
            Help("", 1, "RU09T10EventRUS:GridLinePosVld:01",, STR0019, 1, 0,,,,,,{oSubModel:GetValue("F38_ITEM")}) // "The field Full Description must be filled in"
        EndIf
    EndIf

Return(lRet)

/*/{Protheus.doc} RU09T10EventRUS:ModelPosVld()
Method does model pos validation
@type Method
@author Leandro Nunes
@project MA3 - Russia
@since 20/11/2023
@param oSubModel, Object,    Active submodel
@param cSubModID, Character, Active Submodel's Id
@return lRet,     Logical,   If validation process is ok
/*/
Method ModelPosVld(oSubModel As Object, cSubModID As Character) Class RU09T10EventRUS

    Local lRet As Logical 
    Local nF38Origr As Numeric
    Local nSe2Valor As Numeric
    Local nF38OValu As Numeric
    Local nSe2VlCru As Numeric

    nF38Origr := 0 
    nSe2Valor := 0   
    nF38OValu := 0
    nSe2VlCru := 0
    lRet := .T.

    If Empty(oSubModel:GetModel("F37master"):GetValue("F37_RDATE"))
        lRet := .F.
        Help("", 1, "RU09T10EventRUS:ModelPosVld:01",, STR0020, 1, 0) // "Inclusion Date must be fulfilled in case VAT Invoice goes into Auto Purchases Book"
    EndIf

    nF38OValu := oSubModel:GetModel("F38detail"):GetValue("F38_VALUE")
    nSe2VlCru := oSubModel:GetModel("SE2detail"):GetValue("E2_VLCRUZ")
    nF38Origr := oSubModel:GetModel("F38detail"):GetValue("F38_ORIGGR")
    nSe2Valor := oSubModel:GetModel("SE2detail"):GetValue("E2_VALOR")
    
    If nF38Origr <> nSe2Valor
        If !IsBlind()
            lRet  := MsgYesNo("RU09T10EventRUS:ModelPosVld:02", STR0023) // "Total amount at field Gross Value in Original currency are different to value at the Payment Advance, are you sure?
        EndIf
    EndIf

    If lRet .And. oSubModel:GetModel("SE2detail"):GetValue("E2_CONUNI") == "1"
        If nF38OValu <> nSe2VlCru
            If !IsBlind()
                lRet  := MsgYesNo("RU09T10EventRUS:ModelPosVld:03", STR0023) // "Total amount at field Gross Value in Original currency are different to value at the Payment Advance, are you sure?
            EndIf
        ElseIf nF38OValu <> nSe2Valor
            If !IsBlind()
                lRet  := MsgYesNo("RU09T10EventRUS:ModelPosVld:04", STR0023) // "Total amount at field Gross Value in Original currency are different to value at the Payment Advance, are you sure?
            EndIf
        EndIf
    EndIf

Return(lRet)
                   
//Merge Russia R14 
                   
