#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "topconn.ch"
#INCLUDE "ru09xxx.ch"
#INCLUDE "ru09d09.ch"

#define __PurchasesVATInvoices "RU09T03|RU09T10"
#define __PurchasesBook 	   "RU09T05"
#define __WriteOffDocument 	   "RU09T06"
#define __VATRestoration	   "RU09T08"
#define __AllRoutines		   "RU09T03|RU09T10|RU09T05|RU09T06|RU09T08|RU09T10"

/* {Protheus.doc} RU09D09
Routine to deal with Outflow VAT Balances
@type Function
@author Leandro Nunes
@since 01/11/2023
@version 1.0
@project MA3 - Russia
@return lRet,  Logical, If routine runs ok
*/
Function RU09D09() As Logical

	Local oBrowse As Object
	Local lRet    As Logical
	
	lRet := .T.

	DbSelectArea("F62")
    F62->(DbSetOrder(1))

	oBrowse := FWLoadBrw("RU09D09")
	aRotina := MenuDef()
	oBrowse:Activate()

Return(lRet)

/* {Protheus.doc} BrowseDef
Browse definitions
@type Static Function
@author Leandro Nunes
@since 01/11/2023
@project MA3 - Russia
@return oBrowse, Object, Browse instance of the routine
*/
Static Function BrowseDef() As Object

	Local oBrowse As Object
	
	oBrowse	:= FWMBrowse():New()
	oBrowse:SetDescription(STR0001) // "Outfloe VAT Balances"
	oBrowse:SetAlias("F62")
    oBrowse:DisableDetails()

Return(oBrowse)

/* {Protheus.doc} MenuDef
Menu definitions
@type Static Function
@author Leandro Nunes
@since 01/11/2023
@project MA3 - Russia
*/
Static Function MenuDef()

    Local aRet As Array

    aRet := {{STR0902, "VIEWDEF.RU09D09", 0, 2, 0, Nil}} // View

Return(aRet)

/* {Protheus.doc} MenuDef
Creates the model of Outflow VAT Balances
@type Static Function
@author Leandro Nunes
@since 01/11/2023
@project MA3 - Russia
*/
Static Function ModelDef() As Object

    Local oModel     As Object
    Local oCab       As Object
    Local oStructF62 As Object

    oCab := FWFormModelStruct():New()
    oStructF62 := FWFormStruct(1, "F62")

    oModel := MPFormModel():New("RU09D09")
    oCab:AddTable('F62', ,'F62',)
    oCab:AddField("Id", "", "F62_CAMPO", "C", 1, 0,,,, .F., {||'"1"'},, .F., .T.,)

    oModel:AddFields("F62MASTER",, oCab,,, {|o|{}})
    oModel:GetModel('F62MASTER'):SetDescription(STR0001) // "Outflow VAT Balances"
    oModel:SetPrimaryKey({})

    oModel:AddGrid("F62DETAIL", "F62MASTER", oStructF62)
    oModel:SetOptional("F62DETAIL", .T.)

Return(oModel)

/* {Protheus.doc} MenuDef
Creates the view of Outflow VAT Balances
@type Static Function
@author Leandro Nunes
@since 01/11/2023
@project MA3 - Russia
*/
Static Function ViewDef() As Object

    Local oView      As Object
    Local oModel     As Object
    Local oStructF62 As Object

    oModel := FwLoadModel("RU09D09")
    oStructF62 := FWFormStruct(2, "F62")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddGrid("F62_D", oStructF62, "F62DETAIL")

    oView:CreateHorizontalBox("MAINBOX", 100)

    oView:SetOwnerView("F62_D", "MAINBOX")
    oView:SetNoInsertLine("F62_D")
    oView:SetNoUpdateLine("F62_D")
    oView:SetNoDeleteLine("F62_D")

Return(oView)

/* {Protheus.doc} RU09D09001_AddNewOutflowBalance
Creates a procedure to register the new outflow balances.
@type Function
@author Leandro Nunes
@since 01/11/2023
@project MA3 - Russia
@param oModel, Object,  F62 table's model
@return lRet,  Logical, If validation is ok
*/
Function RU09D09001_AddNewOutflowBalance(oModel as Object) As Logical
 
    Local lRet     As Logical
    Local cTab     As String
    Local cModelId As Character
    Local cEmptyZD As Character

    lRet := .T.
    cTab := ""

    // Checks, if routine get an argument of object type and if routine has an object to extract data.
    If ValType(oModel) != "O"
        lRet := .F.
        Help("", 1, "RU09D09001_AddNewOutflowBalance:01",, STR0910, 1, 0) // "No model is received as an argument"
    EndIf

    If lRet
        cModelId := oModel:GetId()
        // If routine is called from Purchases VAT Invoices.
        If cModelId $ __PurchasesVATInvoices
            DbSelectArea("F62")
            F62->(DbSetOrder(1))
        Else // Caller is unknown.
            lRet := .F.
            Help("", 1, "RU09D09001_AddNewOutflowBalance:01",, STR0926, 1, 0) // The MVC model from arguments is not defined
        EndIf
    EndIf

    // Performs an SQL query and fills the cTab alias.
    lRet := lRet .And. RU09D09002(oModel, @cTab)

    If lRet
        cEmptyZD := SToD(Space(TamSX3("F62_ZERODT")[1]))

        // Setting values into the Balances table model line by line.
        Begin Transaction
        
        (cTab)->(DbGoTop())
        While !(cTab)->(Eof())
            RecLock("F62", .T.)
            F62->F62_FILIAL := xFilial("F62")
            F62->F62_ORIGIN := "F37"	// Purchase VAT Invoice Key.
            F62->F62_KEY    := (cTab)->VAT_KEY	// Purchase VAT Invoice Key.
            F62->F62_SUPPL  := (cTab)->SUPPLIER	// Supplier's Code
            F62->F62_SUPBRA := (cTab)->SUPP_BRANCH	// Supplier's Unit Code
            F62->F62_DOC    := (cTab)->DOC_NUM	// Purchase VAT Invoice Document Number.
            F62->F62_PDATE  := SToD((cTab)->PRINT_DATE) // The Balances table holds print date of the VAT Purchases Invoice
            F62->F62_RDATE  := SToD((cTab)->REAL_DATE) // The Balance Date must be equal real inclusion date of the VAT Purchases Invoice
            F62->F62_VATCOD := (cTab)->INTCODE	// Purchase VAT Invoice Internal Code.
            F62->F62_VATCD2 := (cTab)->EXTCODE	// Purchase VAT Invoice External (Operational) Code.
            F62->F62_OPBS   := (cTab)->INIT_BASE	// Purchase VAT Invoice Base ready to reclaim or write-off.
            F62->F62_VATRT  := (cTab)->VAT_RATE	// Tax Rate related to Internals and Externals Codes.
            F62->F62_OPBAL  := (cTab)->INIT_BALANCE	// VAT Value based on Open Balance.
            F62->F62_INIBS  := (cTab)->INIT_BASE	// Initial Balance Base at this date.
            F62->F62_INIBAL := (cTab)->INIT_BALANCE	// Initial Balance Value at this date.
            F62->F62_INIGRR := (cTab)->INIT_BASE	// Initial Gross Value in Rubles.
            F62->F62_BALGRR := (cTab)->INIT_BALANCE	// Open balance for Initial Gross Value in Rubles.
            F62->F62_INIGRO := (cTab)->INIT_BASE	// Initial Gross Value in Original Currency.
            F62->F62_BALGRO := (cTab)->INIT_BALANCE	// Open balance for Initial Gross Value in Original Currency.          
            F62->(MsUnlock())
            
            (cTab)->(DbSkip())
        EndDo
        End Transaction
    EndIf

    CloseTempTable(cTab)

Return(lRet)

/* {Protheus.doc} RU09D09002_GetAliasAndQuery
Function gets alias of the temporary table and fills this table with the data from the query.
@type Function
@author Leandro Nunes
@since 01/11/2023
@project MA3 - Russia
@param oModel,  Object,  F62 table's model
@param cTab,    Object,  Alias 
@param cTabDel, Object,  Delete Alias
@return lRet,  Logical, If validation is ok
*/
Function RU09D09002_GetAliasAndQuery(oModel As Object, cTab As Character, cTabDel As Character) As Logical

    Local lRet       As Logical
    Local cQuery     As Character
    Local cQueryDel  As Character
    Local cQforModel As Character
    Local cQryOrder  As Character
    Local cModelId   As Character

    lRet       := .T.
    cQuery     := ""
    cQueryDel  := ""
    cQforModel := ""
    cQryOrder  := ""
    cModelId   := ""

    Default cTab    := ""
    Default cTabDel := ""

    cQryOrder := " ORDER BY 1, 2, 3"

    If lRet
        cModelId := oModel:GetId()

        // If routine is called from Purchases VAT Invoices.
        If cModelId $ __PurchasesVATInvoices
            cQuery := " SELECT"
            // Order matters.
            cQuery += " T0.F37_FILIAL	AS FILIAL,"
            cQuery += " T0.F37_KEY		AS VAT_KEY,"
            cQuery += " T1.F38_VATCOD	AS INTCODE,"
            cQuery += " T0.F37_DOC AS DOC_NUM,"
            cQuery += " T0.F37_RDATE AS REAL_DATE,"
            cQuery += " T0.F37_PDATE AS PRINT_DATE,"
            cQuery += " T0.F37_FORNEC AS SUPPLIER,"
            cQuery += " T0.F37_BRANCH AS SUPP_BRANCH,"
            cQuery += " T1.F38_VATCD2 AS EXTCODE,"
            cQuery += " T1.F38_VATRT AS VAT_RATE,"
            cQuery += " SUM(T1.F38_VATBS1) AS INIT_BASE,"
            cQuery += " SUM(T1.F38_VATVL1) AS INIT_BALANCE"
            cQuery += " FROM " + RetSQLName("F37") + " AS T0"
            cQuery += " INNER JOIN " + RetSQLName("F38") + " AS T1"
            cQuery += " ON ("
            cQuery += " T1.F38_FILIAL = '" + xFilial("F38") + "'"
            cQuery += " AND T1.F38_KEY = T0.F37_KEY"
            cQuery += " AND T1.D_E_L_E_T_ = ' '"
            cQuery += ")"
            cQuery += " WHERE T0.F37_FILIAL = '" + xFilial("F37") + "'"
            cQuery += " AND T0.F37_KEY = '" + oModel:GetModel("F37master"):GetValue("F37_KEY") + "'"
            cQuery += " AND T0.D_E_L_E_T_ = ' '"
            cQuery += " GROUP BY T0.F37_FILIAL"
            cQuery += " ,T0.F37_FORNEC"
            cQuery += " ,T0.F37_BRANCH"
            cQuery += " ,T0.F37_DOC"
            cQuery += " ,T0.F37_RDATE"
            cQuery += " ,T0.F37_KEY"
            cQuery += " ,T0.F37_PDATE"
            cQuery += " ,T1.F38_VATCOD"
            cQuery += " ,T1.F38_VATCD2"
            cQuery += " ,T1.F38_VATRT"	
            cTab := MPSysOpenQuery(ChangeQuery(cQuery + cQryOrder))

            cQforModel += " AND T0.F32_KEY = '" + oModel:GetModel("F37master"):GetValue("F37_KEY") + "'"
            
            cQueryDel := " SELECT"
            // Order matters.
            cQueryDel += " T0.F32_FILIAL	AS FILIAL,"
            cQueryDel += " T0.F32_KEY		AS VAT_KEY,"
            cQueryDel += " T0.F32_VATCOD	AS INTCODE,"
            cQueryDel += " T0.F32_VATRT AS VAT_RATE,"
            cQueryDel += " T0.F32_BOOKBS AS RECLAIM_BASE,"
            cQueryDel += " T0.F32_BOOKVL AS RECLAIM_VALUE"
            cQueryDel += " FROM " + RetSQLName("F32") + " AS T0"
            cQueryDel += " LEFT JOIN ("
            cQueryDel += cQuery
            cQueryDel += ") AS NEW_BALANCE"
            cQueryDel += " ON ("
            cQueryDel += " NEW_BALANCE.FILIAL = '" + XFILIAL("F32") + "'"
            cQueryDel += " AND NEW_BALANCE.VAT_KEY = T0.F32_KEY"
            cQueryDel += " AND NEW_BALANCE.INTCODE = T0.F32_VATCOD"
            cQueryDel += ")"
            cQueryDel += " WHERE T0.F32_FILIAL = '" + xFilial("F32") + "'"
            cQueryDel += cQforModel // Specific coniditions for every model
            cQueryDel += " AND T0.D_E_L_E_T_ = ' '"
            cQueryDel += " AND NEW_BALANCE.FILIAL IS NULL"
            cQueryDel += " AND NEW_BALANCE.VAT_KEY IS NULL"
            cQueryDel += " AND NEW_BALANCE.INTCODE IS NULL"

            cTabDel := MPSysOpenQuery(ChangeQuery(cQueryDel + cQryOrder))
        EndIf
    EndIf

Return(lRet)

/* {Protheus.doc} RU09D09003_EditOutflowBalance
Creates a procedure to edit outflow balances.
@type Function
@author Leandro Nunes
@since 01/11/2023
@project MA3 - Russia
@param oModel,  Object,  F62 table's model
@return lRet,  Logical, If validation is ok
*/
Function RU09D09003_EditOutflowBalance(oModel as Object) As Logical

    Local lRet      As Logical
    Local cTab      As Character
    Local cTabDel   As Character
    Local cSeek     As Character
    Local cModelId  As Character
    Local oModelDet As Object
    Local cEmptyZD  As Character
    Local nLine     As Numeric
    Local nOpenBase As Numeric

    lRet    := .T.
    cTab    := ""
    cTabDel := ""

    // Checks, if routine get an argument of object type and if routine has an object to extract data.
    If ValType(oModel) != "O"
        lRet := .F.
        Help("", 1, "RU09D09003_EditOutflowBalance:01",, STR0910, 1, 0) // "No model is received as an argument"
    EndIf

    If lRet
        cModelId := oModel:GetId()
        If !(cModelId $ __AllRoutines) // Caller is unknown.
            lRet := .F.
            Help("", 1, "RU09D09003_EditOutflowBalance:02",, STR0926, 1, 0) // "The MVC model from arguments is not defined"
        EndIf
    EndIf

    // Performs an SQL query and fills the cTab, cTabDel aliases.
    lRet := lRet .And. RU09D09002(oModel, @cTab, @cTabDel)

    If lRet
        cEmptyZD := StoD(Space(TamSX3("F62_ZERODT")[1]))

        // Changing the working area to F62 Purchases VAT Invoices Balances table.
        DbSelectArea("F32")
        F62->(dbSetOrder(1))

        Begin Transaction
        // If routine is called from Purchases VAT Invoices.
        If cModelId $ __PurchasesVATInvoices
            // Setting values into the Balances table model line by line.
            nLine := 1
            F62->(DBGoTop())
            (cTab)->(DBGoTop())
            While !(cTab)->(Eof())
                cSeek := PadR((cTab)->VAT_KEY, TamSX3("F62_KEY")[1], " ") + ;
                    PadR((cTab)->INTCODE, TamSX3("F62_VATCOD")[1], " ") + ;
                    PadR((cTab)->EXTCODE, TamSX3("F62_VATCD2")[1], " ")
                
                // If record is found in the  Balances Table, update it.
                If !Empty(cSeek) .And. F62->(DbSeek(xFilial("F62") + cSeek))
                    RecLock("F62", .F.)
                Else // If record is not found, add it.
                    RecLock("F62", .T.)
                EndIf

                nOpenBase := (cTab)->INIT_BASE

                F62->F62_FILIAL := xFilial("F62")
                F62->F62_KEY    := (cTab)->VAT_KEY	// Purchase VAT Invoice Key.
                F62->F62_SUPPL  := (cTab)->SUPPLIER	// Supplier's Code
                F62->F62_SUPUN  := (cTab)->SUPP_BRANCH	// Supplier's Unit Code
                F62->F62_DOC    := (cTab)->DOC_NUM	// Purchase VAT Invoice Document Number.
                F62->F62_RDATE  := SToD((cTab)->REAL_DATE)	// The Balance Date must be equal real inclusion date of th VAT Purchases Invoice
                F62->F62_PDATE  := SToD((cTab)->PRINT_DATE) // The Balances table holds print date of the VAT Purchases Invoice
                F62->F62_VATCOD := (cTab)->INTCODE	// Purchase VAT Invoice Internal Code.
                F62->F62_VATCD2 := (cTab)->EXTCODE	// Purchase VAT Invoice External (Operational) Code.
                F62->F62_VATRT  := (cTab)->VAT_RATE	// VAT Rate
                F62->F62_OPBAL  := (cTab)->INIT_BALANCE	// VAT Value based on Open Balance.
                F62->F62_OPBS   := nOpenBase	// Purchase VAT Invoice Base ready to reclaim or write-off.
                F62->F62_BOOKVL := 0	// Current Purchase Book (Reclaimed) VAT Value.
                F62->F62_BOOKBS := 0	// Current Purchase Book (Reclaimed) VAT Base.
                F62->F62_WOFFVL := 0	// Current Write-Off VAT Value.
                F62->F62_WOFFBS := 0	// Current Write-Off VAT Base.
                F62->F62_INIBAL := (cTab)->INIT_BALANCE	// Initial Balance Value at this date.
                F62->F62_INIBS  := (cTab)->INIT_BASE	// Initial Balance Base at this date.
                F62->F62_ZERODT := dDataBase
                F62->(MsUnlock())

                (cTab)->(DbSkip())
            EndDo

            F62->(DBGoTop())
            While !(cTabDel)->(Eof())
                cSeek := PadR((cTabDel)->VAT_KEY, TamSX3("F62_KEY")[1], " ") + PadR((cTabDel)->INTCODE, TamSX3("F62_VATCOD")[1], " ")
                // If record is found in the  Balances Table, delete it.
                If !Empty(cSeek) .And. F62->(DbSeek(xFilial("F62") + cSeek))
                    RecLock("F62", .F.)
                    F62->(DbDelete())
                    F62->(MsUnlock())
                EndIf
                
                (cTabDel)->(DbSkip())
            EndDo
        // If routine is called from the Purchases Book
        ElseIf cModelId == __PurchasesBook
            oModelDet := oModel:GetModel("F3CDETAIL")
            // Setting values into the Balances table model line by line.
            For nLine := 1 To oModelDet:Length()
                oModelDet:GoLine(nLine)

                If !Empty(oModelDet:GetValue("F3C_KEY"))
                    cSeek := oModelDet:GetValue("F3C_KEY") + ;
                        oModelDet:GetValue("F3C_VATCOD") + ;
                        oModelDet:GetValue("F3C_VATCD2")
                            
                    If !Empty(cSeek) .And. F62->(DbSeek(xFilial("F62") + cSeek))
                        RecLock("F62", .F.)
                        If (oModel:GetOperation() == MODEL_OPERATION_DELETE)
                            F62->F62_OPBS   := F62->F62_OPBS + oModelDet:GetValue("F3C_RECBAS") // Purchase VAT Invoice Base ready to reclaim or write-off.
                            F62->F62_OPBAL  := F62->F62_OPBAL + oModelDet:GetValue("F3C_VALUE")	// VAT Value based on Open Balance.
                            F62->F62_BOOKBS := F62->F62_BOOKBS - oModelDet:GetValue("F3C_RECBAS")	// Current Purchase Book (Reclaimed) VAT Base.
                            F62->F62_BOOKVL := F62->F62_BOOKVL - oModelDet:GetValue("F3C_VALUE")	// Current Purchase Book (Reclaimed) VAT Value.				
                            F62->F62_ZERODT := cEmptyZD
                        Else
                            nOpenBase := F62->F62_OPBS - oModelDet:GetValue("F3C_RBSDIF")
                        
                            F62->F62_OPBS   := nOpenBase	// Purchase VAT Invoice Base ready to reclaim or write-off.
                            F62->F62_OPBAL  := F62->F62_OPBAL - oModelDet:GetValue("F3C_RVLDIF")	// VAT Value based on Open Balance.
                            F62->F62_BOOKBS := F62->F62_BOOKBS + oModelDet:GetValue("F3C_RBSDIF")	// Current Purchase Book (Reclaimed) VAT Base.
                            F62->F62_BOOKVL := F62->F62_BOOKVL + oModelDet:GetValue("F3C_RVLDIF")	// Current Purchase Book (Reclaimed) VAT Value.				
                            If nOpenBase > 0
                                F62->F62_ZERODT := cEmptyZD
                            Else
                                F62->F62_ZERODT := oModel:GetModel("F3BMASTER"):GetValue("F3B_FINAL")	// Date of final the balance.
                            EndIf
                        EndIf
                        F62->(MsUnlock())
                    Else
                        lRet := .F.
                        Help("", 1, "RU09D09003_EditOutflowBalance:03",, STR0940 + STR0938, 1, 0,,,,,, {oModelDet:GetValue("F3C_ITEM")}) // "The related row is not found in the" + "Incoming VAT balance"
                        DisarmTransaction()
                        Exit
                    EndIf
                EndIf
            Next nLine
        // If routine is called from Write-Off Document.
        ElseIf cModelId == __WriteOffDocument
            oModelDet := oModel:GetModel("F3EDETAIL")
            // Setting values into the Balances table model line by line.
            For nLine := 1 To oModelDet:Length()
                oModelDet:GoLine(nLine)

                If !Empty(oModelDet:GetValue("F3E_KEY"))
                    cSeek := oModelDet:GetValue("F3E_KEY") + ;
                        oModelDet:GetValue("F3E_VATCOD") + ;
                        oModelDet:GetValue("F3E_VATCD2")

                    If !Empty(cSeek) .And. F62->(DbSeek(xFilial("F62") + cSeek))

                        RecLock("F62", .F.)
                        If (oModel:GetOperation() == MODEL_OPERATION_DELETE)
                            F62->F62_OPBS   := F62->F62_OPBS + oModelDet:GetValue("F3E_WOFBAS")	// Purchase VAT Invoice Base ready to reclaim or write-off.
                            F62->F62_OPBAL  := F62->F62_OPBAL + oModelDet:GetValue("F3E_VALUE")	// VAT Value based on Open Balance.
                            F62->F62_WOFFBS := F62->F62_WOFFBS - oModelDet:GetValue("F3E_WOFBAS")	// Current Purchase Book (Reclaimed) VAT Base.
                            F62->F62_WOFFVL := F62->F62_WOFFVL - oModelDet:GetValue("F3E_VALUE")	// Current Purchase Book (Reclaimed) VAT Value.				
                            F62->F62_ZERODT := cEmptyZD
                        Else
                            nOpenBase := F32->F32_OPBS - oModelDet:GetValue("F3E_WBSDIF")
                        
                            F62->F62_OPBS   := nOpenBase	// Purchase VAT Invoice Base ready to reclaim or write-off.
                            F62->F62_OPBAL  := F62->F62_OPBAL - oModelDet:GetValue("F3E_WVLDIF")	// VAT Value based on Open Balance.
                            F62->F62_WOFFBS := F62->F62_WOFFBS + oModelDet:GetValue("F3E_WBSDIF")	// Current Purchase Book (Reclaimed) VAT Base.
                            F62->F62_WOFFVL := F62->F62_WOFFVL + oModelDet:GetValue("F3E_WVLDIF")	// Current Purchase Book (Reclaimed) VAT Value.				
                            If nOpenBase > 0
                                F62->F62_ZERODT := cEmptyZD
                            Else
                                F62->F62_ZERODT :=  oModel:GetModel("F3DMASTER"):GetValue("F3D_FINAL")	// Date of final the balance.
                            EndIf
                        EndIf
                        F62->(MsUnlock())
                    Else
                        lRet := .F.
                        Help("", 1, "RU09D09003_EditOutflowBalance:04",, STR0940 + STR0938, 1, 0,,,,,, {oModelDet:GetValue("F3E_ITEM")}) // "The related row is not found in the" + "Incoming VAT balance"
                        DisarmTransaction()
                        Exit
                    EndIf
                EndIf
            Next nLine
        // If routine is called from VAT Restoration.
        ElseIf cModelId == __VATRestoration
            oModelDet := oModel:GetModel("F53DETAIL")
            // Setting values into the Balances table model line by line.
            
            For nLine := 1 To oModelDet:Length()
                oModelDet:GoLine(nLine)

                If !Empty(FWFldGet("F53_KEY"))
                    // Updates existing Balances with Old VAT Code from the line of Restoration
                    cSeek := FWFldGet("F53_KEY") + FWFldGet("F53_OVTCOD")
                    If !Empty(cSeek) .And. F62->(DbSeek(xFilial("F62") + cSeek))
                        RecLock("F62", .F.)
                        If (oModel:GetOperation() == MODEL_OPERATION_DELETE)
                            F62->F62_RESTBS := F62->F62_RESTBS - FWFldGet("F53_RESTBS")
                            F62->F62_RESTVL := F62->F62_RESTVL - FWFldGet("F53_RESTVL")
                        ElseIf oModelDet:IsDeleted()
                            F62->F62_RESTBS := F62->F62_RESTBS - FWFldGet("F53_RBSBKP")
                            F62->F62_RESTVL := F62->F62_RESTVL - FWFldGet("F53_RVLBKP")
                        Else
                            F62->F62_RESTBS := F62->F62_RESTBS - FWFldGet("F53_RBSBKP") + FWFldGet("F53_RESTBS")
                            F62->F62_RESTVL := F62->F62_RESTVL - FWFldGet("F53_RVLBKP") + FWFldGet("F53_RESTVL")
                        EndIf
                        F62->(MsUnlock())
                    Else
                        lRet := .F.
                        Help("", 1, "RU09D09003_EditOutflowBalance:05",, STR0940 + STR0938, 1, 0,,,,,, {oModelDet:GetValue("F53_ITEM")}) // "The related row is not found in the" + "Incoming VAT balance"
                        DisarmTransaction()
                        Exit
                    EndIf

                    // Updates existing or created new Balances with New VAT Code from the line of Restoration
                    If (FWFldGet("F52_WRIOFF") == "2")
                        cSeek := FWFldGet("F53_KEY") + FWFldGet("F53_NVTCDB")
                        If !Empty(cSeek) .And. F62->(DbSeek(xFilial("F62") + cSeek))
                            RecLock("F62", .F.)
                            F62->F62_OPBS  := F62->F62_OPBS -  FWFldGet("F53_RBSBKP")
                            F62->F62_OPBAL := F62->F62_OPBAL - FWFldGet("F53_RVLBKP")
                            If (FWFldGet("F53_OVTCOD") != FWFldGet("F53_NVTCDB"))
                                F62->F62_RESTBS := F62->F62_RESTBS - FWFldGet("F53_RBSBKP")
                                F62->F62_RESTVL := F62->F62_RESTVL - FWFldGet("F53_RVLBKP")
                                F62->F62_INIBS  := F62->F62_INIBS -  FWFldGet("F53_RBSBKP")
                                F62->F62_INIBAL := F62->F62_INIBAL - FWFldGet("F53_RVLBKP")
                            EndIf
                            F62->(MsUnlock())
                        EndIf

                        cSeek := FWFldGet("F53_KEY") + FWFldGet("F53_NVTCOD")
                        If !Empty(cSeek) .And. F62->(DbSeek(xFilial("F62") + cSeek))
                            RecLock("F62", .F.)
                            If ((oModel:GetOperation() == MODEL_OPERATION_INSERT) .Or. (oModel:GetOperation() == MODEL_OPERATION_UPDATE)) .And. !oModelDet:IsDeleted()
                                F62->F62_OPBS  := F62->F62_OPBS  + FWFldGet("F53_RESTBS")
                                F62->F62_OPBAL := F62->F62_OPBAL + FWFldGet("F53_RESTVL")
                                If (FWFldGet("F53_OVTCOD") != FWFldGet("F53_NVTCOD"))
                                    F62->F62_RESTBS := F62->F62_RESTBS + FWFldGet("F53_RESTBS")
                                    F62->F62_RESTVL := F62->F62_RESTVL + FWFldGet("F53_RESTVL")
                                    F62->F62_INIBS  := F62->F62_INIBS  + FWFldGet("F53_RESTBS")
                                    F62->F62_INIBAL := F62->F62_INIBAL + FWFldGet("F53_RESTVL")
                                EndIf
                            ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
                                F62->F62_OPBS  := F62->F62_OPBS - FWFldGet("F53_RESTBS")
                                F62->F62_OPBAL := F62->F62_OPBAL - FWFldGet("F53_RESTVL")
                                If (FWFldGet("F53_OVTCOD") != FWFldGet("F53_NVTCOD"))
                                    F62->F62_RESTBS := F62->F62_RESTBS - FWFldGet("F53_RESTBS")
                                    F62->F62_RESTVL := F62->F62_RESTVL - FWFldGet("F53_RESTVL")
                                    F62->F62_INIBS  := F62->F62_INIBS  - FWFldGet("F53_RESTBS")
                                    F62->F62_INIBAL := F62->F62_INIBAL - FWFldGet("F53_RESTVL")
                                EndIf
                            EndIf
                        ElseIf (!oModelDet:IsDeleted())
                            RecLock("F62", .T.)
                            F62->F62_FILIAL := xFilial("F62")
                            F62->F62_KEY    := FWFldGet("F53_KEY")	// Purchase VAT Invoice Key.
                            F62->F62_SUPPL  := FWFldGet("F53_SUPPL")	// Supplier's Code
                            F62->F62_SUPUN  := FWFldGet("F53_SUPUN")	// Supplier's Unit Code
                            F62->F62_DOC    := FWFldGet("F53_DOC")	// Purchase VAT Invoice Document Number.
                            F62->F62_RDATE  := FWFldGet("F52_DATE")	// The Balance Date must be equal real inclusion date of th VAT Purchases Invoice
                            F62->F62_PDATE  := FWFldGet("F53_PDATE") // The Balances table holds print date of the VAT Purchases Invoice
                            F62->F62_VATCOD := FWFldGet("F53_NVTCOD")	// Purchase VAT Invoice Internal Code.
                            F62->F62_VATCD2 := FWFldGet("F53_NVTCD2")	// Purchase VAT Invoice External (Operational) Code.
                            F62->F62_OPBAL  := FWFldGet("F53_RESTVL")	// VAT Value based on Open Balance.
                            F62->F62_OPBS   := FWFldGet("F53_RESTBS")	// Purchase VAT Invoice Base ready to reclaim or write-off.
                            F62->F62_VATRT  := FWFldGet("F53_VATRT")	// VAT percent Rate
                            F62->F62_BOOKVL := 0	// Current Purchase Book (Reclaimed) VAT Value.
                            F62->F62_BOOKBS := 0	// Current Purchase Book (Reclaimed) VAT Base.
                            F62->F62_WOFFVL := 0	// Current Write-Off VAT Value.
                            F62->F62_WOFFBS := 0	// Current Write-Off VAT Base.
                            F62->F62_RESTBS := FWFldGet("F53_RESTBS")
                            F62->F62_RESTVL := FWFldGet("F53_RESTVL")
                            F62->F62_INIBS  := FWFldGet("F53_RESTBS")	// Initial Balance Base at this date.
                            F62->F62_INIBAL := FWFldGet("F53_RESTVL")	// Initial Balance Value at this date.
                        EndIf
                        F62->(MsUnlock())
                    EndIf
                EndIf
            Next nLine
        EndIf
        End Transaction
    EndIf

    CloseTempTable(cTab)
    CloseTempTable(cTabDel)

Return(lRet)

/* {Protheus.doc} RU09D09004_DeleteOutflowBalance
Creates a procedure to delete Balances of Purchases VAT Invoices values.
Function should be used in the moment, when object Model is commited, but still exists.
@type Function
@author Leandro Nunes
@since 01/11/2023
@project MA3 - Russia
@param oModel,  Object,  F62 table's model
@return lRet,  Logical, If validation is ok
*/
Function RU09D09004_DeleteOutflowBalance(oModel as Object) As Logical

    Local lRet     As Logical
    Local cModelId As Character
    Local cSeek    As Character

    lRet := .T.

    // Checks, if routine get an argument of object type and if routine has an object to extract data.
    If ValType(oModel) != "O"
        lRet := .F.
        Help("", 1, "RU09D09004_DeleteOutflowBalance:01",, STR0910, 1, 0) // "No model is received as an argument"
    EndIf

    If lRet
        cModelId := oModel:GetId()	
        If (cModelId != "RU09T03|RU09T10") // Caller is unknown.
            lRet := .F.
            Help("", 1, "RU09D09004_DeleteOutflowBalance:02",, STR0926, 1, 0) // The MVC model from arguments is not defined
        EndIf
    EndIf

    If lRet
        // Changing the working area to F32 VAT Purchases Balances table.
        DbSelectArea("F62")
        F62->(dbSetOrder(1))

        cSeek := oModel:getModel("F37master"):getValue("F37_KEY")
        F62->(DBGoTop())
        Begin Transaction
        While !Empty(cSeek) .And. F62->(dbSeek(xFilial("F62") + cSeek))
            RecLock("F62", .F.)
            F62->(DbDelete())
            F62->(MsUnlock("F62"))
        EndDo
        End Transaction
    EndIf

Return(lRet)
                   
//Merge Russia R14 
                   
