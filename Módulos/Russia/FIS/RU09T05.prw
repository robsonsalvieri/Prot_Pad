#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'topconn.ch'
#include 'ru09t03.ch'
#include 'RU09XXX.ch'

#define EXTRA_DAYS_AFTER_TAX_PERIOD 25
STATIC __isVatInvoice := FWIsInCallStack("RU09T10018_SaveInPurchaseBook")

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T05
Creates the main screen of Purchases VAT Books.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Function RU09T05()
	Local oBrowse as Object
	Private aRotina as Array
	SetKey(VK_F12, {||AcessaPerg("RU09T05ACC",.T.)})

// Initalization of the tables, if they do not exist.
	DbSelectArea("F3B")
	DbSelectArea("F3C")
	DbSelectArea("F64")

	F3C->(DbSetOrder(4))

	oBrowse := FWLoadBrw("RU09T05")
	aRotina := MenuDef()

	oBrowse:Activate()

Return(.T.)
// The end of the Function RU09T05()



//-----------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Defines the browser of the Purchases VAT Books.
@author Artem Kostin
@since 26/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function BrowseDef()
	Local oBrowse 		as Object
	Local cBrowseFilter as Character
	Local cVATKey 		as Character
	Local cDocType		as Character
	Local cTab 			as Character
	Local cQuery 		as Character

	cTab := ""
	cBrowseFilter := ""

	oBrowse := FwMBrowse():New()

	oBrowse:setAlias("F3B")
	oBrowse:AddLegend("F3B_STATUS =='1'", "GREEN", "Open")
	oBrowse:AddLegend("F3B_STATUS =='2'", "BLACK", "Blocked")
	oBrowse:AddLegend("F3B_STATUS =='3'", "RED", "Closed")
	oBrowse:setDescription(STR0901)
	oBrowse:DisableDetails()

	If IsInCallStack("RU09T03RUS")
		cVATKey := F37->F37_KEY
		cDocType := F37->F37_TYPE

		
		cQuery := " SELECT DISTINCT T0.F3B_BOOKEY AS BOOK_KEY FROM " + RetSQLName("F3B") + " AS T0 "
		If cDocType == "1"
			// Commercial Invoices:
			cQuery += " JOIN " + RetSQLName("F3C") + " AS T1 ON ("
			cQuery += " T1.F3C_FILIAL = '" + xFilial("F3C") +"'"
			cQuery += " AND T1.F3C_KEY = '" + cVATKey + "'"
			cQuery += " AND T1.F3C_BOOKEY = T0.F3B_BOOKEY"
			cQuery += " ) "
		else
			// Advances/Prepayments:
			cQuery += " JOIN " + RetSQLName("F64") + " AS T1 ON ("
			cQuery += " T1.F64_FILIAL = '" + xFilial("F64") +"'"
			cQuery += " AND T1.F64_KEY = '" + cVATKey + "'"
			cQuery += " AND T1.F64_BOOKEY = T0.F3B_BOOKEY"
			cQuery += " ) "
		EndIf		
		cQuery += " WHERE T0.F3B_FILIAL = '" + xFilial("F3B") +"'"
		cQuery += " AND T0.D_E_L_E_T_ = ' '"
		cQuery += " AND T1.D_E_L_E_T_ = ' '"
			
		cTab := MPSysOpenQuery(ChangeQuery(cQuery))

		While !(cTab)->(Eof())
			cBrowseFilter += "(F3B_BOOKEY=='" + (cTab)->BOOK_KEY + "') .or. "
			(cTab)->(DbSkip())
		EndDo
		CloseTempTable(cTab)
		// Cuts " .and. " from the end of the line of the Purchases Book Keys.
		If !Empty(cBrowseFilter)
			cBrowseFilter := SubStr(cBrowseFilter, 1, Len(cBrowseFilter)-6)
		Else
			cBrowseFilter := "F3B_BOOKEY=='" + Space(TamSX3("F3B_BOOKEY")[1]) + "'"
		EndIf

		oBrowse:setFilterDefault(cBrowseFilter)
	EndIf

Return(oBrowse)

//-----------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defines the menu to Purchases VAT Books.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function MenuDef()
	Local aButtons as Array

	aButtons := {{STR0902, "FwExecView('" + STR0902 + "', 'RU09T05', " + STR(MODEL_OPERATION_VIEW) + ")", 0, 2, 0, Nil},;
		{STR0903, "FwExecView('" + STR0903 + "', 'RU09T05', " + STR(MODEL_OPERATION_INSERT) + ")", 0, 3, 0, Nil},;
		{STR0904, "FwExecView('" + STR0904 + "', 'RU09T05', " + STR(MODEL_OPERATION_UPDATE) + ")", 0, 4, 0, Nil},;
		{STR0905, "FwExecView('" + STR0905 + "', 'RU09T05', " + STR(MODEL_OPERATION_DELETE) + ")", 0, 5, 0, Nil},;
		{STR0054, "CTBC662", 0, 2, 0, Nil},; //"Track Posting"
	{STR0055,"RU09T05001_RETBOOK",0,7,0,Nil}}
	aAdd(aButtons,{STR0057, "RU09R01()", 0, 6, 0, NIL}) //Print Purchases book

Return(aButtons)
// The end of the Static Function MenuDef()

//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Creates the model of Purchases VAT Books.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function ModelDef()
	Local oModel as Object
	Local oStructF3B as Object
	Local oStructF3C as Object
	Local oStruF64P as Object
	Local oStruF64R as Object
	Local oModelEvent as Object

	oStructF3B := FWFormStruct(1, "F3B")
	oStructF3C := FWFormStruct(1, "F3C")
	oStruF64P := FwFormStruct(1, "F64")
	oStruF64R := FwFormStruct(1, "F64")

	oModel := MPFormModel():New("RU09T05", Nil, {|oModel| RU09T05MPost(oModel)}, {|oModel| ModelRec(oModel)}, /*bLoadModel*/)
	oModel:setDescription(STR0901)

// This flag field plays role of the nonexistent method of the grid object ::IsChanged ? "*"-Yes : Nil-No
	aAdd(oStructF3C:aFields, {"RecBsDiff", "ReclaimBaseDiff", "F3C_RBSDIF", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})
	aAdd(oStructF3C:aFields, {"RecVlDiff", "ReclaimValueDiff", "F3C_RVLDIF", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})
	aAdd(oStructF3C:aFields, {"OpVlDiff", "OpenValueDiff", "F3C_OPBSBU", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})
	aAdd(oStructF3C:aFields, {"OpVlDiff", "OpenValueDiff", "F3C_OPVLBU", "N", 16, 2, {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., ""})

	oStructF3C:SetProperty('F3C_DOC' ,MODEL_FIELD_OBRIGAT,.F.)

	oModel:AddFields("F3BMASTER", Nil, oStructF3B, {|oModel, cAction, cField, xValue| RU09T05FPre(oModel, cAction, cField, xValue)})

	oModel:AddGrid("F3CDETAIL",;
		"F3BMASTER",;
		oStructF3C,;
		{|oModel, nLinVld, cAction, cField, xValue, xOldValue| RU09T05DLPre(oModel, nLinVld, cAction, cField, xValue, xOldValue)},;
                /* bLinePost */,;
                /* bGridPre */,;
                /* bGridPost */)

	oStruF64P:SetProperty('F64_ORIGGR', MODEL_FIELD_OBRIGAT, .T.)
	oStruF64R:SetProperty('F64_ORIGGR', MODEL_FIELD_OBRIGAT, .T.)
	
	oModel:AddGrid("F64PDETAIL", "F3BMASTER", oStruF64P)
	oModel:AddGrid("F64RDETAIL", "F3BMASTER", oStruF64R)

	oModel:GetModel("F3BMASTER"):setDescription(STR0901)

	oModel:GetModel("F3CDETAIL"):setDescription(STR0906)
	oModel:GetModel("F3CDETAIL"):setOptional(.T.)

	oModel:setRelation("F3CDETAIL", {{"F3C_FILIAL", "xFilial('F3C')"}, {"F3C_BOOKEY", "F3B_BOOKEY"}, {"F3C_CODE", "F3B_CODE"}}, F3C->(IndexKey(4))) //IndexKey(1)
	oModel:setPrimaryKey({"F3B_FILIAL", "F3B_BOOKEY"})
	oModel:setActivate({|| RU09T05AAct(oModel)})

	oModel:SetRelation("F64PDETAIL", {{"F64_FILIAL", "xFilial('F64')"}, {"F64_BOOKEY", "F3B_BOOKEY"}}, F64->(IndexKey(1)))
	oModel:SetRelation("F64RDETAIL", {{"F64_FILIAL", "xFilial('F64')"}, {"F64_BOOKEY", "F3B_BOOKEY"}}, F64->(IndexKey(1)))

	oModel:GetModel("F3CDETAIL"):setUniqueLine({"F3C_FILIAL", "F3C_KEY","F3C_VATCOD","F3C_VATCD2"})
	oModel:GetModel("F64PDETAIL"):SetUniqueLine({"F64_ITEM"})
	oModel:GetModel("F64RDETAIL"):SetUniqueLine({"F64_ITEM"})

	oModel:GetModel("F64PDETAIL"):SetOptional(.T.)
	oModel:GetModel("F64RDETAIL"):SetOptional(.T.)

	oModel:GetModel("F64PDETAIL"):GetStruct():SetProperty("F64_TYPE", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'1'"))
	oModel:GetModel("F64RDETAIL"):GetStruct():SetProperty("F64_TYPE", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'2'"))

	oModel:GetModel("F64PDETAIL"):SetLoadFilter({{"F64_TYPE", "'1'"}})
	oModel:GetModel("F64RDETAIL"):SetLoadFilter({{"F64_TYPE", "'2'"}})

	oModelEvent := RU09T05EventRUS():New()
	oModel:InstallEvent("oModelEvent", /*cOwner*/, oModelEvent)

Return(oModel)
// The end of the Static Function ModelDef()



//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Creates the view of Purchases VAT Books.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
	Local oView as Object
	Local oModel as Object
	Local oStructF3B as Object
	Local oStructF3C as Object
	Local oStruF64P as Object
	Local oStruF64R as Object

	Local cCmpF3B as Character
	Local cCmpF3C as Character
	Local cCmpTotal as Character

// Defines which fields we don't need to show on the screen.
	cCmpF3B := "F3B_BOOKEY;F3B_TOTAL "
	cCmpF3C := "F3C_CODE  ;F3C_BOOKEY;F3C_KEY   ;"
	cCmpTotal := "F3B_TOTAL "

	oModel := FwLoadModel("RU09T05")

	oStructF3B := FWFormStruct(2, "F3B", {|x| !(AllTrim(x) $ cCmpF3B)})
	oStructF3C := FWFormStruct(2, "F3C", {|x| !(AllTrim(x) $ cCmpF3C)})
	oSturctTotal := FWFormStruct(2, "F3B", {|x| (AllTrim(x) $ cCmpTotal)})
	oStruF64P := FwFormStruct(2, "F64", {|x| !(AllTrim(x) $ "F64_FILIAL|F64_KEY|F64_BOOKEY")})
	oStruF64R := FwFormStruct(2, "F64", {|x| !(AllTrim(x) $ "F64_FILIAL|F64_KEY|F64_BOOKEY")})

	oStructF3C := RU09XFN013(oStructF3C, "F3C", {"_CNEE_B", "_CNEE_C", "_CNOR_B", "_CNOR_C"})

	If (INCLUI)
		// This field will be filled in while commiting and shown in other view cases.
		oStructF3B:RemoveField("F3B_CODE")
	Else
		// User shouldn't have an option to change dates in saved books.
		oStructF3B:SetProperty("F3B_INIT", MVC_VIEW_CANCHANGE, .F.)
		oStructF3B:SetProperty("F3B_FINAL", MVC_VIEW_CANCHANGE, .F.)
	EndIf

// If Book Status is Blocked or Closed. If it is an Automatic Purchases Book.
	If (ALTERA) .and. ((F3B->F3B_STATUS == "2") .Or. (F3B->F3B_STATUS == "3") .or. (F3B->F3B_AUTO == "1"))
		oStructF3B:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
		oStructF3B:SetProperty('F3B_STATUS', MVC_VIEW_CANCHANGE, .T.)
		oStructF3B:SetProperty('F3B_CMNT', MVC_VIEW_CANCHANGE, .T.)
	EndIf

	oStructF3B:RemoveField("F3B_VRCMNT")

	oStructF3C:SetProperty("F3C_DOC", MVC_VIEW_CANCHANGE, F3C_DOC_When())

	oView := FWFormView():New()
	oView:setModel(oModel)
	oView:AddField("F3B_M", oStructF3B, "F3BMASTER")
	oView:AddGrid("F3C_D", oStructF3C, "F3CDETAIL")
	oView:AddGrid("VIEW_F64P", oStruF64P, "F64PDETAIL")
	oView:AddGrid("VIEW_F64R", oStruF64R, "F64RDETAIL")
	oView:AddField("F3B_T", oSturctTotal, "F3BMASTER")

	oView:CreateHorizontalBox("HEADERBOX", 25)
	oView:CreateHorizontalBox("ITEMBOX", 65)
	oView:CreateHorizontalBox("TOTALBOX", 10)

	oView:setOwnerView("F3B_M", "HEADERBOX")

	oView:CreateFolder('FOLDER1', 'ITEMBOX')
	oView:AddSheet('FOLDER1', 'Sheet1', STR0958) // "Commercial Invoices"
	oView:AddSheet('FOLDER1', 'Sheet2', STR0959) // "Advances Paid"
	oView:AddSheet('FOLDER1', 'Sheet3', STR0960) // "Advances Received"
	
	oView:CreateHorizontalBox("F3CBOX", 100/*%*/,,,'FOLDER1', 'Sheet1')
	oView:SetOwnerView("F3C_D", "F3CBOX")

	oView:CreateHorizontalBox("F64PBOX", 100/*%*/,,,'FOLDER1', 'Sheet2')
	oView:SetOwnerView("VIEW_F64P", "F64PBOX")
	oView:AddIncrementField("VIEW_F64P", "F64_ITEM")

	oView:CreateHorizontalBox("F64RBOX", 100/*%*/,,,'FOLDER1', 'Sheet3')
	oView:SetOwnerView("VIEW_F64R", "F64RBOX")
	oView:AddIncrementField("VIEW_F64R", "F64_ITEM")
	
	oView:setOwnerView("F3B_T", "TOTALBOX")

	oView:setDescription(STR0901)

// If Book is opened and non automatic and operation is Insertion or Update.
	If (INCLUI) .or. ((F3B->F3B_STATUS == "1") .and. (F3B->F3B_AUTO == "2") .and. (ALTERA))
		oView:AddUserButton(STR0961, '', {|| RU09T05AInc(oModel)}) //Aut. Commercial Inv.
		oView:AddUserButton(STR0962, '', {|| R09T05APay(oModel)}) //Aut. Payment Adv.
		oView:AddUserButton(STR0963, '', {|| R09T05ARec(oModel)}) //Aut. Receivement Adv.
	EndIf

	oView:AddUserButton(STR0907, '', {|| RU09T05VAT(oModel)})      //View corresponding Tax Invoice
	oView:AddUserButton(STR0964, '', {|| RU05VATInExp(oModel, 1)}) //Export All	
	oView:AddUserButton(STR0965, '', {|| RU05VATInExp(oModel, 2)}) //Export Commercial Invoices
	oView:AddUserButton(STR0966, '', {|| RU05VATInExp(oModel, 3)}) //Export Advances Paid
	oView:AddUserButton(STR0967, '', {|| RU05VATInExp(oModel, 4)}) //Export Advances Received

	oView:setCloseOnOk({|| .T.})

Return(oView)
// The end of the Static Function ViewDef()



//-----------------------------------------------------------------------
/*/{Protheus.doc} F3C_DOC_When
Function returns false, if key is not empty.
This function is used to prevent editing the Purchases VAT Invoice Document Number
after it has been filled once. Only line deletion is allowed for user.
@author Artem Kostin
@since 05/15/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function F3C_DOC_When()
	Local lRet := .T.
	Local oModel as Object

	oModel := FWModelActive()
	If (ValType(oModel) == "O") .and. (oModel:getId() == "RU09T05")
		lRet := Empty(oModel:GetModel("F3CDETAIL"):GetValue("F3C_KEY"))
	EndIf

Return lRet
// The end of the Static Function F3C_DOC_When()



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T05MPost
Handles fields changes.
@author Artem Kostin
@since 01/30/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T05MPost(oModel as Object)
	Local lRet := .T.

	Local cCode as Character

	Local nLine as Numeric
	Local nRecBsDiff as Numeric
	Local nRecValDiff as Numeric

	Local oModelF3C := oModel:GetModel("F3CDETAIL")
	Local nOperation := oModel:GetOperation()

	Local cNMBAlias := "PUBOOK"

	Local lCanUpdateLine as Logical

	If (nOperation == MODEL_OPERATION_INSERT)
		// Variables intialization.
		cCode := RU09D03NMB(cNMBAlias, Nil, xFilial("F3B"))
		If Empty(cCode)
			lRet := .F.
			Help("",1,"RU09T05MPost01",,STR0951 + cNMBAlias,1,0)
		EndIf

		If !oModel:GetModel("F3BMASTER"):LoadValue("F3B_CODE", cCode)
			lRet := .F.
			Help("",1,"RU09T05MPost_Code",,STR0927,1,0)
		EndIf
	EndIf

	If (nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)
		If lRet .and. !__isVatInvoice
			lCanUpdateLine := oModel:GetModel("F3CDETAIL"):CanUpdateLine()
			oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(.F.)
			For nLine := 1 to oModelF3C:Length(.F.)
				oModelF3C:GoLine(nLine)

				// If the row is inserted and deleted. Or if the row is not inserted and is not deleted.
				If oModelF3C:IsInserted() == oModelF3C:IsDeleted()
					nRecBsDiff := 0
					nRecValDiff := 0

					// With one exception.
					If !oModelF3C:IsDeleted() .and. oModelF3C:IsUpdated()
						nRecBsDiff := oModelF3C:GetValue("F3C_RECBAS") - oModelF3C:GetValue("F3C_RBSDIF")
						nRecValDiff := oModelF3C:GetValue("F3C_VALUE") - oModelF3C:GetValue("F3C_RVLDIF")
					EndIf
				EndIf

				// If row is not inserted but deleted.
				If !oModelF3C:IsInserted() .and. oModelF3C:IsDeleted()
					nRecBsDiff := - oModelF3C:GetValue("F3C_RBSDIF")
					nRecValDiff := - oModelF3C:GetValue("F3C_RVLDIF")
				EndIf

				// If row is inserted and not deleted.
				If oModelF3C:IsInserted() .and. !oModelF3C:IsDeleted()
					nRecBsDiff := oModelF3C:GetValue("F3C_RECBAS")
					nRecValDiff := oModelF3C:GetValue("F3C_VALUE")
				EndIf

				lRet := lRet .and. oModelF3C:LoadValue("F3C_RBSDIF", nRecBsDiff)
				lRet := lRet .and. oModelF3C:LoadValue("F3C_RVLDIF", nRecValDiff)

				If !lRet
					Help("",1,"RU09T05MPost_LoadValue",,STR0927,1,0)
					Exit
				EndIf
			Next nLine
			oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(!lCanUpdateLine)
		EndIf // lRet
	EndIf

Return(lRet)
// The end of the Static Function RU09T05MPost(oModelF3B)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T05FPre
Handles grid's line changes.
@author Artem Kostin
@since 01/30/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T05FPre(oModelF3B as Object, cAction as Character, cField as Character, xValue)
	Local lRet := .T.

	Local oModel as Object
	Local nLine as Numeric

	oModel := FWModelActive()
	oModelF3C := oModel:GetModel("F3CDETAIL")

	If (cAction == "SETVALUE") .and. (cField == "F3B_FINAL")
		If (oModelF3B:GetValue("F3B_INIT") > xValue)
			lRet := .F.
			Help("",1,"RU09T05FPre01",,STR0948,1,0)
		EndIf

		If lRet
			For nLine := 1 to oModelF3C:Length()
				oModelF3C:GoLine(nLine)
				If !oModelF3C:IsDeleted() .and. (oModelF3C:GetValue("F3C_PDATE") > xValue)
					lRet := .F.
					Help("",1,"RU09T05FPre02",,STR0947+" "+oModelF3C:GetValue("F3C_DOC"),1,0)
					Exit
				EndIf
			Next nLine
		EndIf
	EndIf

	If (cAction == "SETVALUE") .and. (cField == "F3B_INIT")
		If (oModelF3B:GetValue("F3B_FINAL") < xValue)
			lRet := .F.
			Help("",1,"RU09T05FPre03",,STR0949,1,0)
		EndIf
	EndIf
Return(lRet)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T05DLPre
Handles grid's line changes.
@author Artem Kostin
@since 01/30/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU09T05DLPre(oModelF3C as Object, nLinVld as Numeric, cAction as Character, cField as Character, xValue, xOldValue)
// Logical routine flow control
	Local lRet := .T.
// Stores reclaiming values
	Local nRecBs as Numeric
	Local nRecVal as Numeric
	Local nRecRate as Numeric
	Local nRecValTotal as Numeric
// Variables for SQL queries
	Local cQuery as Character
	Local cTab as Character
// Variables for certain filters
	Local cVATKey as Character
	Local cIntCodeList as Character
	Local dFinalDate as Date
	Local cFinalMonth as Character
// Variables to operate with Model
	Local oModel as Object
	Local nLine as Numeric
	Local lCanUpdateLine as Logical
// Saves the line selected by user
	Local aSaveRows as Array
	Local nFocus := GetFocus()
// Variables to operate with View
	Local oView as Object
//for right change F3C_ITEM on delete\undelete rows
	Local nCurDelta as Numeric
	Local cVatCode as Character

	If Type("lRecursion") == "U"
		Private lRecursion := .F.
	EndIf

// Prevents prevalidation from recursion.
	If (lRecursion == .T.)

	Else
		lRecursion := .T.
		aSaveRows := FWSaveRows()

		// Variables initialization.
		nLine := 0

		cQuery := ""
		cTab := ""
		cIntCodeList := ""

		oModel := FWModelActive()
		If (ValType(oModel) != "O") .or. (oModel:getId() != "RU09T05")
			lRet := .F.
			Help("",1,"RU09T05DLPre01",,STR0910,1,0)
		EndIf

		// If it is the deletion of an empty line return Nil.
		If (cAction == "DELETE") .and. Empty(AllTrim(oModelF3C:getValue("F3C_KEY")))
			lRet := Nil

		ElseIf lRet .and. (cAction == "CANSETVALUE") .and. (cField == "F3C_DOC")
			If !Empty(AllTrim(oModelF3C:GetValue("F3C_KEY")))
				lRet := .F.
			EndIf

			// If user put something into the Doc. Num. field and pressed enter.
		ElseIf lRet .and. (cAction == "SETVALUE")  .and. (cField $ "F3C_KEY   |F3C_DOC   |")
			If (Empty(AllTrim(oModelF3C:GetValue("F3C_KEY"))) .and. (cField == "F3C_DOC"));
					.or. (cField == "F3C_KEY")

				dFinalDate := oModel:GetModel("F3BMASTER"):GetValue("F3B_FINAL")
				cFinalMonth := SubStr(DtoS(dFinalDate), 5, 2)
				// Finds VAT Invoice grouped items from the Balances table.
				cQuery := RU09T05_01getSQLquery(oModelF3C)
				// VAT Values, which are three years old and older, cannot be reclaimed.
				If (cField == "F3C_DOC")
					cQuery += " AND F32_DOC = '" + xValue + "' "
				ElseIf (cField == "F3C_KEY")
					cQuery += " AND F32_KEY = '" + xValue + "' "
				EndIf
				cQuery += " AND T0.F32_RDATE >= '" + DtoS(YearSub(oModel:GetModel("F3BMASTER"):GetValue("F3B_FINAL"), 3)) +"'"
				If (cFinalMonth $ "03|06|09|12")
					cQuery += " AND T0.F32_PDATE <= '" + DtoS(dFinalDate) + "'"
					cQuery += " AND T0.F32_RDATE <= '" + DtoS(DaySum(LastDay(dFinalDate), EXTRA_DAYS_AFTER_TAX_PERIOD)) + "'"
				Else
					cQuery += " AND T0.F32_RDATE <= '" + DtoS(dFinalDate) + "'"
				EndIf
				cQuery += RU09T05_02getSQLorderby()
				cTab := MPSysOpenQuery(ChangeQuery(cQuery))

				// If no Purchases VAT Invoices with such Document Number were found.
				If (cTab)->(Eof())
					lRet := .F.
					Help("",1,"RU09T05DLPre04",,STR0913,1,0)
				EndIf

				If lRet
					lRet := lRet .and. RU09T05F3C(oModelF3C, oModel:GetModel("F3BMASTER"), cTab, 100.00)
				EndIf

				CloseTempTable(cTab) // Deletes the temporary table.
			EndIf

		ElseIf lRet .and. (cAction == "SETVALUE") .and. (cField $ "F3C_RECBAS|F3C_VATPER|F3C_VALUE |") .and. !Empty(oModelF3C:GetValue("F3C_DOC"))
			// If user changes Reclaim Base, the Reclaim Value and Reclaim Percent will be changed proportionally.
			If (cField == "F3C_RECBAS")
				nRecBs := xValue
				// If user wants to reclaim the whole open balance, it can be a round error.
				// Here it is an attempt to avoid round error after multiplication and division.
				If (nRecBs = (oModelF3C:GetValue("F3C_OPBSBU") + oModelF3C:GetValue("F3C_RBSDIF")))
					nRecVal := oModelF3C:GetValue("F3C_OPVLBU") + oModelF3C:GetValue("F3C_RVLDIF")
				Else
					// Reclaim Value = Reclaim Base * Reclaim % Rate
					nRecVal := Round(xValue * oModelF3C:GetValue("F3C_VATRT") / 100.00, 2)
				EndIf
				// Reclaim % Rate = Reclaim Base / Open Base
				nRecRate := Round(xValue / oModelF3C:getValue("F3C_VATBS") * 100.00, 2)

				// If user changes Reclaim Percent, the Reclaim Value and Reclaim Base will be changed proportionally.
			ElseIf (cField == "F3C_VATPER")
				// Reclaim Base = Reclaim % Rate * Open Base
				nRecBs := Round(xValue * oModelF3C:getValue("F3C_VATBS") / 100.00, 2)
				nRecRate := xValue
				// Reclaim Value = Reclaim % Rate * Open Balance
				nRecVal := Round(xValue * oModelF3C:getValue("F3C_VATVL") / 100.00, 2)

				// If user changes Reclaim Value, the Reclaim Percent and Reclaim Base will be changed proportionally.
			ElseIf (cField == "F3C_VALUE")
				nRecVal := xValue
				If (nRecVal = (oModelF3C:GetValue("F3C_OPVLBU")+oModelF3C:GetValue("F3C_RVLDIF")))
					nRecBs := oModelF3C:GetValue("F3C_OPBSBU") + oModelF3C:GetValue("F3C_RBSDIF")
				Else
					// Reclaim Base = Open Base * Reclaim Value / Open Balance
					nRecBs := Round(xValue / oModelF3C:GetValue("F3C_VATRT") * 100.00, 2)
				EndIf
				// Reclaim % Rate = Reclaim Value / Open Balance
				nRecRate := Round(nRecBs / oModelF3C:getValue("F3C_VATBS") * 100.00, 2)
			EndIf
			// Checks, if user puts the value, which is out of borders.
			If (nRecBs > (oModelF3C:GetValue("F3C_OPBSBU") + oModelF3C:GetValue("F3C_RBSDIF"))) .or. (nRecBs > oModelF3C:GetValue("F3C_VATBS"))
				lRet := .F.
				Help("",1,"RU09T05DLPre02",,STR0928,1,0)
			EndIf
			// If everything is ok.
			If lRet
				oModelF3C:LoadValue("F3C_RECBAS", nRecBs)
				oModelF3C:LoadValue("F3C_VATPER", nRecRate)
				oModelF3C:LoadValue("F3C_VALUE", nRecVal)

				oModelF3C:LoadValue("F3C_OPBS", oModelF3C:GetValue("F3C_OPBSBU") + oModelF3C:GetValue("F3C_RBSDIF") - nRecBs)
				oModelF3C:LoadValue("F3C_OPBAL", oModelF3C:GetValue("F3C_OPVLBU") + oModelF3C:GetValue("F3C_RVLDIF") - nRecVal)
			EndIf
		EndIf

		// If user deletes or undeletes any line from automatic book, all lines must be deleted.
		If lRet .and. ((cAction == "DELETE") .or. (cAction == "UNDELETE")) .and. (oModel:GetModel("F3BMASTER"):GetValue("F3B_AUTO") == "1");
				.and. (!Empty(oModelF3C:GetValue("F3C_DOC"))) .and. (!Empty(oModelF3C:GetValue("F3C_KEY")))
			// Saves the VAT Key of the deleted line.
			cVATKey := oModelF3C:GetValue("F3C_KEY")
			nCurDelta := 0
			// Goes over all the grid.
			For nLine := 1 to oModelF3C:Length(.F.)
				oModelF3C:GoLine(nLine)
				// Deletes all lines related to this Purchases VAT Invoices.
				If (oModelF3C:GetValue("F3C_KEY") == cVATKey)
					// If action is deletion, line is not deleted yet and line was not changed before.
					If (cAction == "DELETE") .and. (!oModelF3C:IsDeleted())
						nCurDelta--
						oModelF3C:DeleteLine()
						// If action is restoring, line is deleted and line was changed before.
					ElseIf (cAction == "UNDELETE") .and. oModelF3C:IsDeleted()
						oModelF3C:UnDeleteLine()
						nCurDelta++
					EndIf
				Else
					lCanUpdateLine := oModel:GetModel("F3CDETAIL"):CanUpdateLine()
					oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(.F.)
					oModelF3C:LoadValue("F3C_ITEM", StrZero(Val(oModelF3C:GetValue("F3C_ITEM")) + nCurDelta, TamSX3("F3C_ITEM")[1]))
					oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(!lCanUpdateLine)
				EndIf
			Next nLine
		EndIf

		If lRet .and. ((cAction == "DELETE") .or. (cAction == "UNDELETE"))
			cVATKey := AllTrim(oModelF3C:GetValue("F3C_KEY"))
			cVatCode := AllTrim(oModelF3C:GetValue("F3C_VATCOD"))
			nCurDelta := 0
			For nLine := 1 to oModelF3C:Length()
				oModelF3C:GoLine(nLine)
				If (AllTrim(oModelF3C:GetValue("F3C_KEY")) == cVATKey .and. AllTrim(oModelF3C:GetValue("F3C_VATCOD")) == cVatCode)
					If (cAction == "DELETE") .and. (!oModelF3C:IsDeleted())
						nCurDelta--
					ElseIf (cAction == "UNDELETE") .and. oModelF3C:IsDeleted()
						nCurDelta++
					EndIf
				Else
					lCanUpdateLine := oModel:GetModel("F3CDETAIL"):CanUpdateLine()
					oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(.F.)
					oModelF3C:LoadValue("F3C_ITEM", StrZero(Val(oModelF3C:GetValue("F3C_ITEM")) + nCurDelta, TamSX3("F3C_ITEM")[1]))
					oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(!lCanUpdateLine)
				EndIf
			Next nLine
		EndIf

		If lRet .and. ((cAction == "SETVALUE") .or. (cAction == "DELETE") .or. (cAction == "UNDELETE"))
			nRecValTotal := 0
			// Goes thought the grid and sums all values into the total.
			For nLine := 1 to oModelF3C:Length(.F.)
				// Calculates total. Sums not deleted lines and not empty values.
				If (cAction == "DELETE") .and. (nLine == nLinVld)
					Loop
				EndIf

				oModelF3C:GoLine(nLine)
				If ((!oModelF3C:IsDeleted()) .and. (!Empty(oModelF3C:GetValue("F3C_VALUE")) .or. (oModelF3C:GetValue("F3C_VALUE") != 0)));
						.or. ((cAction == "UNDELETE") .and. (nLine == nLinVld))
					nRecValTotal += oModelF3C:GetValue("F3C_VALUE")
				EndIf
			Next nLine
			// Puts the total sum into the field.
			oModel:GetModel("F3BMASTER"):LoadValue("F3B_TOTAL", nRecValTotal)
		EndIf

		FWRestRows(aSaveRows)

		If lRet .and. (cAction != "CANSETVALUE") .and. (cAction != "ISENABLE")
			// Refreshes the oView object
			oView := FwViewActive()
			If (oView != Nil) .and. (oView:GetModel():GetId() == "RU09T05")
				oView:Refresh()
				// Retores saved focus
				SetFocus(nFocus)
			EndIf
		EndIf

		lRecursion := .F.
	EndIf // lRecursion == .T.
Return(lRet)
// The end of the Static Function RU09T05DLPre(oModelF3C)



//-----------------------------------------------------------------------
/*/{Protheus.doc} ModelRec
Records Purchases Book model into the database.
@author Artem Kostin
@since 02/03/2018
@version P12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function ModelRec(oModel as Object)    // Full Model
	Local lRet := .T.
	Local nOperation 	as Numeric
	Local oModelF3C 	as Object
	Local nLine 		as Numeric

// Checks, if input argument is not an Object.
	If ValType(oModel) != "O"
		lRet := .F.
		Help("",1,"RU09T05ModelRec08",,STR0910,1,0)
	EndIf

// Checks, if operation code is defined.
	nOperation := oModel:getOperation()
	If ValType(nOperation) != "N"
		lRet := .F.
		Help("",1,"RU09T05ModelRec09",,STR0914,1,0)
	EndIf

	Begin Transaction
		If lRet
			dbSelectArea("F37")
			F37->(dbSetOrder(3))
			oModelF3C := oModel:GetModel("F3CDETAIL")

			oModel:GetModel("F3CDETAIL"):SetNoDeleteLine(.F.)
			For nLine := 1 to oModelF3C:Length(.F.)
				oModelF3C:GoLine(nLine)
				// Gets rid out of empty lines.
				If ((nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)) .and. Empty(oModelF3C:GetValue("F3C_KEY"))
					oModelF3C:DeleteLine()
				EndIf

				// If line is deleted from the Purchases Book, the related VAT Invoice property "In autobook?" will be set "No".
				If ((nOperation == MODEL_OPERATION_DELETE) .or. ((oModel:GetModel("F3BMASTER"):GetValue("F3B_AUTO") == "1") .and. oModelF3C:IsDeleted())) .and. !Empty(oModelF3C:GetValue("F3C_KEY"))
					If F37->(dbSeek(xFilial("F37") + oModelF3C:GetValue("F3C_KEY")))
						RecLock("F37", .F.)
						F37->F37_ATBOOK := "2"
						MsUnlock("F37")
					Else
						lRet := .F.
						Help("",1,"RU09T05ModelRec10",,STR0909 + "'" + oModelF3C:GetValue("F3C_KEY") + "'",1,0)
					EndIf
				EndIf
			Next nLine
			oModel:GetModel("F3CDETAIL"):SetNoDeleteLine(.T.)
//is delete call function
			If (nOperation == MODEL_OPERATION_DELETE) .And. lRet .and. F3B->F3B_STATUS=='3' .And. !Empty(F3B->F3B_DTLA)
				ctbVATpurb(oModel, .F. )
			Endif
			If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. lRet .and. oModel:GetModel("F3BMASTER"):GetValue("F3B_STATUS")=='3' .And. Empty(F3B->F3B_DTLA)
				oModel:GetModel("F3BMASTER"):SetValue("F3B_DTLA",dDataBase)
			EndIf
			// If everything is OK, commit the model.
			lRet := lRet .and. FWFormCommit(oModel)

//is insert call function
			If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. lRet .and. F3B->F3B_STATUS=='3'
				ctbVATpurb(oModel, .T. )
			Endif

			// Renew the Balances and Movements after commit.
			If nOperation == MODEL_OPERATION_INSERT
				lRet := lRet .and. RU09D05Edt(oModel)
				lRet := lRet .and. RU09D04Add(oModel)
			ElseIf nOperation == MODEL_OPERATION_UPDATE
				lRet := lRet .and. RU09D05Edt(oModel)
				lRet := lRet .and. RU09D04Edt(oModel)
			ElseIf nOperation == MODEL_OPERATION_DELETE
				lRet := lRet .and. RU09D05Edt(oModel)
				lRet := lRet .and. RU09D04Del(oModel)
			EndIf
		EndIf
		If !lRet
			Help("",1,"RU09T05ModelRec",,STR0915,1,0)
			DisarmTransaction()
		EndIf

	End Transaction


// TODO: here should be an accounting postings update.
Return(lRet)
// The end of the Static Function ModelRec(oModel)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09T05AInc
@author Artem Kostin
@since 02/27/2018
@version 12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Function RU09T05AInc(oModel as Object)
	Local lRet := .T.

	Local aParam as Array
	Local aPerguntas as Array

	Local oModelF3B as Object
	Local oModelF3C as Object

	Local nLine as Numeric
	Local nRecValTotal as Numeric

	Local cTab as Character
	Local cQuery as Character
	Local cFinalMonth as Character

// Initialisation of the variables.
	aParam :={}
	aPerguntas	:= {}
	nLine := 1

	cTab := ""
	cQuery := ""

	oModelF3B := oModel:GetModel("F3BMASTER")
	oModelF3C := oModel:GetModel("F3CDETAIL")

// Questions to help user filter result of the autocomplete function.
// ?	Doc. No.: Purchase VAT Invoice Number.
	aAdd(aPerguntas,{ 1, STR0916 + " " + STR0923, Space(TamSX3("F37_DOC")[1]),            "@!",'.T.',"F37DOC",".T.",60, .F.})
	aAdd(aPerguntas,{ 1, STR0916 + " " + STR0924,   Replicate("z", TamSX3("F37_DOC")[1]),"@!",'.T.',"F37DOC",".T.",60, .F.})
// ?	Print Date: Purchase VAT Invoice Print Date.
	aAdd(aPerguntas,{ 1, STR0917 + " " + STR0923, oModelF3B:GetValue("F3B_INIT"),    /*mask*/,'.T.',"",".T.",60, .F.}) // Not used in qeury.
	aAdd(aPerguntas,{ 1, STR0917 + " " + STR0924,   oModelF3B:GetValue("F3B_FINAL"),/*mask*/,'.T.',"",".T.",60, .F.})
// ?	Supplier: Purchase VAT Invoice Supplier Code.
	aAdd(aPerguntas,{ 1, STR0920 + " " + STR0923, Space(TamSX3("F37_FORNEC")[1]),          "@!",'.T.',"SA2",".T.",60, .F.})
	aAdd(aPerguntas,{ 1, STR0921 + " " + STR0923, Space(TamSX3("F37_BRANCH")[1]),          "@!",'.T.',"",".T.",60, .F.})
// ?	Branch: Purchase VAT Invoice Supplier Branch.
	aAdd(aPerguntas,{ 1, STR0920 + " " + STR0924, Replicate("z", TamSX3("F37_FORNEC")[1]),"@!",'.T.',"SA2",".T.",60, .F.})
	aAdd(aPerguntas,{ 1, STR0921 + " " + STR0924, Replicate("z", TamSX3("F37_BRANCH")[1]),"@!",'.T.',"",".T.",60, .F.})
//      Preliminary VAT code.
	aAdd(aPerguntas,{ 1, STR0952, Space(TamSX3("F38_VATCOD")[1]),          "@!",'.T.',"F31",".T.",60, .F.})
// ?	Reclaim %: Purchase VAT Invoice Reclaim %. The initial value must be 100%.
	aAdd(aPerguntas,{ 1, STR0922, 100.00,                                                 "@999.99",'.T.',"",".T.",60, .F.})
//      Preliminary VAT code.

// Shows user a window with questions.
	If !ParamBox(aPerguntas, STR0925, aParam, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		lRet := .F.
	EndIf

	If lRet
		cFinalMonth := SubStr(DtoS(aParam[4]), 5, 2)
		// Select from Invoices.
		cQuery := RU09T05_01getSQLquery(oModelF3C)
		If !Empty(aParam[9])
			cQuery += " AND T0.F32_VATCOD = '" + aParam[9] + "'"
		EndIf
		// VAT Values, which are three years old and elder, cannot be reclaimed.
		cQuery += " AND T0.F32_DOC BETWEEN '" + aParam[1] + "' AND '" + aParam[2] + "'"
		If Empty(aParam[3])
			cQuery += " AND T0.F32_RDATE >= '" + DtoS(YearSub(aParam[4], 3)) +"'"
		Else
			cQuery += " AND T0.F32_RDATE >= '" +  DtoS(aParam[3]) +"'"
		EndIf
		If (cFinalMonth $ "03|06|09|12")
			cQuery += " AND T0.F32_PDATE <= '" + DtoS(aParam[4]) + "'"
			cQuery += " AND T0.F32_RDATE <= '" + DtoS(DaySum(LastDay(aParam[4]), EXTRA_DAYS_AFTER_TAX_PERIOD)) + "'"
		Else
			cQuery += " AND T0.F32_RDATE <= '" + DtoS(aParam[4]) + "'"
		EndIf
		cQuery += " AND	T0.F32_SUPPL BETWEEN '" + aParam[5] + "' AND '" + aParam[7] + "'"
		cQuery += " AND	T0.F32_SUPUN BETWEEN '" + aParam[6] + "' AND '" + aParam[8] + "'"
		cQuery += RU09T05_02getSQLorderby()
		cTab := MPSysOpenQuery(ChangeQuery(cQuery))

		lRet := lRet .and. RU09T05F3C(oModelF3C, oModelF3B, cTab, aParam[10])
		nRecValTotal := 0
		// Goes thought the grid and sums all values into the total.
		For nLine := 1 to oModelF3C:Length(.F.)
			oModelF3C:GoLine(nLine)
			// Calculates total. Sums not deleted lines and not empty values.
			If (!oModelF3C:IsDeleted()) .and. (!Empty(oModelF3C:GetValue("F3C_VALUE")) .or. !oModelF3C:GetValue("F3C_VALUE") == 0)
				nRecValTotal += oModelF3C:GetValue("F3C_VALUE")
			EndIf
		Next nLine
		// Puts the total sum into the field.
		oModel:GetModel("F3BMASTER"):LoadValue("F3B_TOTAL", nRecValTotal)
		oModelF3C:GoLine(1)

		// Refreshes the oView object
		oView := FwViewActive()
		If (oView != Nil) .and. (oView:GetModel():GetId() == "RU09T05")
			oView:Refresh()
		EndIf
	EndIf

	CloseTempTable(cTab)
Return(lRet)
// The end of the Function RU09T05AInc(oModel)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU05VATInExp
@author Artem Kostin
@since 02/28/2018
@version 12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function RU05VATInExp(oModel, nOpc)
	Local lRet := .T.
	Local cArq as Character

	Local nHandle as Numeric

	cArq := cGetFile("File CSV | *.csv", "File .CSV", 1, "C:\", .F., GETF_LOCALHARD, .F., .T.)

	If (!Empty(cArq))
		nHandle := FCreate(cArq)

		If !(nHandle == -1)
			Processa({|| gravaReg(@nHandle, oModel, nOpc)}, STR0933, STR0934, .F.)

			FClose(nHandle)

			Help("",1,"RU05VATInExp01",,STR0930,1,0)
		Else
			lRet := .F.
			Help("",1,"RU05VATInExp02",,STR0931,1,0)
		EndIf
	EndIf

Return(lRet)
// The end of the Function RU05VATInExp



//-----------------------------------------------------------------------
/*/{Protheus.doc} gravaReg
@author Artem Kostin
@since 02/28/2018
@version 12.1.20
@type function
/*/
//-----------------------------------------------------------------------
Static Function gravaReg(nHandle, oModel, nOpc)
	Local aArea as Array
	Local aAreaF3C as Array
	Local aAreaF64 as Array

	Local aStructF3B as Array
	Local aStructF3C as Array
	Local aStructF64 as Array

	Local oModelF3B as Object

	Local cBookKey as Character
	Local cFilF3B as Character
	Local cFilF3C as Character

	aArea := GetArea()
	aAreaF3C := F3C->(GetArea())
	aAreaF3B := F3B->(GetArea())
	aAreaF64 := F64->(GetArea())

	aStructF3C := F3C->(DbStruct())
	aStructF3B := F3B->(DbStruct())
	aStructF64 := F64->(DbStruct())

	oModelF3B := oModel:GetModel("F3BMASTER")

	cFilF3B := xFilial("F3B")
	cFilF3C := xFilial("F3C")
	cBookKey := oModelF3B:GetValue("F3B_BOOKEY")

	DbSelectArea("F3B")
	F3B->(DbSetOrder(1))
	F3B->(DbGoTop())

	DbSelectArea("F3C")
	F3C->(DbSetOrder(2))
	F3C->(DbGoTop())

	If F3B->(DbSeek(cFilF3B+cBookKey))
		// Writes the titles of header data.
		RU09XFN021_WriteHead(nHandle, aStructF3B)

		// Writes the header data.
		While ((F3B->(!Eof())) .And. (F3B->(F3B_FILIAL+F3B_BOOKEY) == cFilF3B+cBookKey))
			RU09XFN022_WriteData(nHandle, aStructF3B, "F3B", STR0934)
			F3B->(DbSkip())
		EndDo

		If nOpc == 1 .Or. nOpc == 2
			If F3C->(DbSeek(cFilF3C+cBookKey))
				// Writes the titles of details data.
				FWrite(nHandle, "" + CRLF)
				RU09XFN021_WriteHead(nHandle, aStructF3C)

				// Writes details data.
				While (F3C->(!Eof())) .And. F3C->(F3C_FILIAL + F3C_BOOKEY) == cFilF3C + cBookKey
					
					RU09XFN022_WriteData(nHandle, aStructF3C, "F3C", STR0934)
					F3C->(DbSkip())

				EndDo
			EndIf
		EndIf

		If nOpc == 1 .Or. nOpc == 3

			If (F64->(DbSeek(xFilial("F64", cFilF3B) + cBookKey)))
				// Writes the titles of details data.
				FWrite(nHandle, "" + CRLF)
				RU09XFN021_WriteHead(nHandle, aStructF64)

				// Writes details data.
				While !F64->(Eof()) .And. F64->F64_FILIAL == xFilial("F64", cFilF3B) .And. F64->F64_BOOKEY == cBookKey
					If F64->F64_TYPE == "1" //Adv Payment
						RU09XFN022_WriteData(nHandle, aStructF64, "F64", STR0934)
					EndIf
					F64->(DbSkip())
				EndDo
			EndIf

		EndIf

		If nOpc == 1 .Or. nOpc == 4

			If (F64->(DbSeek(xFilial("F64", cFilF3B) + cBookKey)))
				// Writes the titles of details data.
				FWrite(nHandle, "" + CRLF)
				RU09XFN021_WriteHead(nHandle, aStructF64)

				// Writes details data.
				While !F64->(Eof()) .And. F64->F64_FILIAL == xFilial("F64", cFilF3B) .And. F64->F64_BOOKEY == cBookKey
					If F64->F64_TYPE == "2" //Adv Received
						RU09XFN022_WriteData(nHandle, aStructF64, "F64", STR0934)
					EndIf
					F64->(DbSkip())
				EndDo
			EndIf
		EndIf	
	EndIf

	RestArea(aAreaF64)
	RestArea(aAreaF3B)
	RestArea(aAreaF3C)
	RestArea(aArea)

	oModel:GetModel("F3CDETAIL"):GoLine(1)
Return(.T.)
// The end of the Function gravaReg



/*/{Protheus.doc} RU09T05VAT
@author Artem Kostin
@since 07/03/2018
@version 1.0
@type function
/*/
Static Function RU09T05VAT(oModel)
	Local aAreaF37 		as Array
	Local oModelInvc 	as Object
	Local cKey 			as Character
	Local oViewAct 		as Object
	Local aFocus		as Array
	Local lIsSel		as Logical	
	
	oViewAct := FWViewActive()
	aFocus:= oViewAct:ACURRENTSELECT
	lIsSel:= .T.

	If Len(aFocus) > 0
		If aFocus[1] == "VIEW_F64P"
			oModelInvc := oModel:GetModel('F64PDETAIL')
			cKey := AllTrim(oModelInvc:GetValue("F64_KEY"))
		ElseIf aFocus[1] == "VIEW_F64R"
			oModelInvc := oModel:GetModel('F64RDETAIL')
			cKey := AllTrim(oModelInvc:GetValue("F64_KEY"))
		ElseIf aFocus[1] == "F3C_D"
			oModelInvc := oModel:GetModel('F3CDETAIL')
			cKey := AllTrim(oModelInvc:GetValue("F3C_KEY"))
		Else
			lIsSel := .F.									//"Not suitable (unknown) Tab", get the message on screen, below
		EndIf
	Else
		lIsSel := .F.
	EndIf	

	If lIsSel		
		If !Empty(cKey)
			aAreaF37 := getArea()
			dbSelectArea('F37')
			F37->(DbSetOrder(3))
			If F37->(DbSeek(xFilial('F37') + cKey))
				FWExecView(STR0009, "RU09T03", MODEL_OPERATION_VIEW, , {|| .T.})
			Else
				Help("",1,"RU09T05VAT_01",,STR0909 + cKey,1,0)
			EndIf
			RestArea(aAreaF37)
		else
			Help("",1,"RU09T05VAT_02",,STR0062,1,0)
		EndIf
		oModelInvc:GoLine(1)
	else
		Help("",1,"RU09T05VAT_03",,STR0062,1,0)
	EndIf

Return

/*/{Protheus.doc} RU09T05AAct
Function performs actions before model is shown to user, but after its activation,
to prepare some specifics:
    1. fill auxiliary fields in the grid
@author Artem Kostin
@since 14/03/2018
@version 1.0
@type function
/*/
Static Function RU09T05AAct(oModel)
	Local lRet := .T.
	Local nLine as Numeric
	Local nOperation as Numeric

	Local oModelF3C as Object

	nOperation := oModel:GetOperation()

	If ((nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE))
		nLine := 0

		oModelF3C := oModel:GetModel("F3CDETAIL")
		If __isVatInvoice
			For nLine := 1 to oModelF3C:Length(.F.)
				If !oModelF3C:IsDeleted()
					oModelF3C:DeleteLine()
				EndIf			
			Next nLine
		Else			
			For nLine := 1 to oModelF3C:Length(.F.)
				oModelF3C:GoLine(nLine)
				lRet := lRet .and. oModelF3C:LoadValue("F3C_RBSDIF", oModelF3C:GetValue("F3C_RECBAS"))
				lRet := lRet .and. oModelF3C:LoadValue("F3C_RVLDIF", oModelF3C:GetValue("F3C_VALUE"))
				lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBSBU", oModelF3C:GetValue("F3C_OPBS"))
				lRet := lRet .and. oModelF3C:LoadValue("F3C_OPVLBU", oModelF3C:GetValue("F3C_OPBAL"))

				If !lRet
					Help("",1,"RU09T05AAct",,STR0927,1,0)
					Exit
				EndIf
			Next nLine
		EndIf
	EndIf

// If Book Status is Blocked or Closed.
	If (nOperation == MODEL_OPERATION_UPDATE) .and. ((F3B->F3B_STATUS == "2") .Or. (F3B->F3B_STATUS == "3"))
		oModel:GetModel("F3CDETAIL"):SetNoInsertLine(.T.)
		oModel:GetModel("F3CDETAIL"):SetNoDeleteLine(.T.)
		oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(.T.)
	EndIf
// If it is an Automatic Purchases Book.
	If (nOperation == MODEL_OPERATION_UPDATE) .and. (F3B->F3B_AUTO == "1")
		oModel:GetModel("F3CDETAIL"):SetNoInsertLine(.T.)
		oModel:GetModel("F3CDETAIL"):SetNoUpdateLine(.T.)
	EndIf

Return(lRet)



Function RU09T05F3C(oModelF3C as Object, oModelF3B as Object, cTab as Character, nUserRate as Numeric)
	Local lRet := .T.
	Local lAddLine := .T.
// Local variables to store the common codes.
	Local cBookCode as Character
	Local cBookKey as Character

	Local nLine as Numeric
	Local nRecRate as Numeric

	Local cTargCode As Char
	//Local cStartDate as Character
	//Local cEndDate as Character
	Local aSheetNrs as Array
	//Local nTmpMaxNr as Numeric
	//Local nCnt as Numeric

	aSheetNrs := {}

	cBookCode := oModelF3B:GetValue("F3B_CODE")
	cBookKey := oModelF3B:GetValue("F3B_BOOKEY")

// If there is no empty line, add new line and push new data to the bottom of the grid.
// If there is already an empty line, data could be inserted starting from this empty line.
	lAddLine :=  !Empty(AllTrim(oModelF3C:GetValue("F3C_KEY")))

// Loading new data selected by query at the end of the grid.
	While !(cTab)->(Eof()) .AND. lRet == .T.
		If lAddLine
			nLine := oModelF3C:AddLine()
		Else
			nLine := oModelF3C:Length(.F.)
			lAddLine := .T.
		EndIf

		nRecRate := min((cTab)->OPEN_BASE / (cTab)->INIT_BASE * 100.00, nUserRate)

		lRet := lRet .and. oModelF3C:LoadValue("F3C_FILIAL", xFilial("F3C"))
		lRet := lRet .and. oModelF3C:LoadValue("F3C_CODE", cBookCode)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_BOOKEY", cBookKey)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_ITEM", StrZero(nLine, GetSX3Cache("F3C_ITEM", "X3_TAMANHO")))  // Number of the line in the Reclaim details table.
		lRet := lRet .and. oModelF3C:LoadValue("F3C_KEY", (cTab)->VAT_KEY)	// Purchase VAT Invoice Key.
		lRet := lRet .and. oModelF3C:LoadValue("F3C_DOC", (cTab)->DOC_NUM)	// Purchase VAT Invoice Document Number.
		lRet := lRet .and. oModelF3C:LoadValue("F3C_PDATE", StoD((cTab)->PRINT_DATE)) // Purchase VAT Invoice Print Date
		lRet := lRet .and. oModelF3C:LoadValue("F3C_VATCOD", (cTab)->INTCODE) // Purchase VAT Invoice Internal Code.
		lRet := lRet .and. oModelF3C:LoadValue("F3C_VATCD2", (cTab)->EXTCODE) // Purchase VAT Invoice External (Operational) Code.
		lRet := lRet .and. oModelF3C:LoadValue("F3C_VATPER", nRecRate) // Percentage of Reclaim Base Value, which will be written off.
		// If user's rate is 100%, copy values from SQL query to avoid precision errors.
		If (nUserRate > nRecRate) .or. (nUserRate == 100.00)
			lRet := lRet .and. oModelF3C:LoadValue("F3C_RECBAS", (cTab)->OPEN_BASE) // Reclaim Base Value.
			lRet := lRet .and. oModelF3C:LoadValue("F3C_VALUE", (cTab)->OPEN_BALANCE) // Reclaim Value = Reclaim Base * Reclaim Percents
			lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBAL", 0) // Purchase VAT Invoice Tax Value ready for reclaim or Reclaim.
			lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBS", 0) // Purchase VAT Invoice Tax Value ready for reclaim or Reclaim.
		Else
			lRet := lRet .and. oModelF3C:LoadValue("F3C_RECBAS", nRecRate * (cTab)->INIT_BASE / 100) // Reclaim Base Value.
			lRet := lRet .and. oModelF3C:LoadValue("F3C_VALUE", nRecRate * (cTab)->INIT_VALUE / 100) // Reclaim Value = Reclaim Base * Reclaim Percents
			lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBAL", (cTab)->OPEN_BALANCE - nRecRate * (cTab)->INIT_VALUE / 100) // Purchase VAT Invoice Tax Value ready for reclaim or Reclaim.
			lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBS", (cTab)->OPEN_BASE - nRecRate * (cTab)->INIT_BASE / 100) // Purchase VAT Invoice Tax Value ready for reclaim or Reclaim.
		EndIf
		// Temporary fields to control restrictions.
		lRet := lRet .and. oModelF3C:LoadValue("F3C_RBSDIF", 0)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_RVLDIF", 0)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_OPBSBU", (cTab)->OPEN_BASE)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_OPVLBU", (cTab)->OPEN_BALANCE)
		// Virtual fields to inform user.
		lRet := lRet .and. oModelF3C:LoadValue("F3C_VATBS", (cTab)->INIT_BASE) // Purchase VAT Invoice Initial Base
		lRet := lRet .and. oModelF3C:LoadValue("F3C_VATRT", (cTab)->VAT_RATE)  // Purchase VAT Invoice Tax Rate
		lRet := lRet .and. oModelF3C:LoadValue("F3C_VATVL", (cTab)->INIT_VALUE) // Purchase VAT Invoice Initial Tax Value
		// Last line will always exist and be empty for new user inputs.

		lRet := lRet .and. oModelF3C:LoadValue("F3C_CNOR_C", (cTab)->F37_CNOR_C)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_CNOR_B", (cTab)->F37_CNOR_B)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_CNEE_C", (cTab)->F37_CNEE_C)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_CNEE_B", (cTab)->F37_CNEE_B)

		lRet := lRet .and. oModelF3C:LoadValue("F3C_ADJNR", (cTab)->F37_ADJNR)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_ADJDT", SToD((cTab)->F37_ADJDT))
		lRet := lRet .and. oModelF3C:LoadValue("F3C_NAME", SubStr((cTab)->SHORTNAME, 1, TamSX3("F3C_NAME")[1]))
		lRet := lRet .and. oModelF3C:LoadValue("F3C_SUPPL", (cTab)->SUPPL)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_SUPUN", (cTab)->SUPUN)
		lRet := lRet .and. oModelF3C:LoadValue("F3C_INVCUR", (cTab)->F37_INVCUR)

		lRet := lRet .and. oModelF3C:LoadValue("F3C_ADSHNR", 0)

		If Empty((cTab)->F31_TG_COD)
			If ((cTab)->F31_TYPE) == "1"
				lRet = .F.
				Help("",1,"RU09T05F3C:00",,STR0956,1,0)
			ElseIf ((cTab)->F31_TYPE) == "2"
				cTargCode := (cTab)->F31_CODE
			EndIf
		Else
			cTargCode := (cTab)->F31_TG_COD
		EndIf

		lRet := lRet .And. oModelF3C:LoadValue("F3C_TG_COD", AllTrim(cTargCode))

		// functionality will be required in the next release
    /*cStartDate := AllTrim(RU09T05GetQD(FWFldGet("F3B_INIT"))[1])
    If SToD((cTab)->PRINT_DATE) < SToD(cStartDate)
        //get search period for number
        aPeriod := RU09T05GetQD(Stod( (cTab)->PRINT_DATE))
        cStartDate := AllTrim(aPeriod[1])
        cEndDate := AllTrim(aPeriod[2])

        //get exist numbers in saved and added rows. if exist set max num, else create new num = max + 1
        cQuery := "SELECT Max(F3C.F3C_ADSHNR) as F3C_ADSHNR "
        cQuery += "FROM " + RetSQLName("F3C") + " F3C "
        cQuery += "WHERE F3C.F3C_PDATE >= '"+ cStartDate + "' AND F3C.F3C_PDATE < '" + cEndDate + "' AND "
        cQuery += "F3C.D_E_L_E_T_ = ' ' AND "
        cQuery += "F3C.F3C_FILIAL = '" + xFilial("F3C") + "' AND F3C.F3C_CODE = '" + FWFldGet("F3B_CODE") + "' "

        cQueryRes := MPSysOpenQuery(cQuery)

        nTmpMaxNr := 0
        For nCnt := 1 To Len(aSheetNrs) Step 1
            If aSheetNrs[nCnt][1] >= STOD(cStartDate) .AND. aSheetNrs[nCnt][1] < STOD(cEndDate) .AND. nTmpMaxNr < aSheetNrs[nCnt][2]
                nTmpMaxNr := aSheetNrs[nCnt][2]
            EndIf
        Next

        If (cQueryRes)->F3C_ADSHNR > 0 .Or. nTmpMaxNr > 0
            lRet := lRet .and. oModelF3C:LoadValue("F3C_ADSHNR", Max((cQueryRes)->F3C_ADSHNR, nTmpMaxNr)) 
        Else
            cQuery := "SELECT Max(F3C.F3C_ADSHNR) as F3C_ADSHNR "
            cQuery += "FROM " + RetSQLName("F3C") + " F3C "
            cQuery += "WHERE F3C.F3C_PDATE >= '"+ cStartDate + "' AND F3C.F3C_PDATE < '" + cEndDate + "' AND "
            cQuery += "F3C.D_E_L_E_T_ = ' ' AND "
            cQuery += "F3C.F3C_FILIAL = '" + xFilial("F3C") + "' "
            cQueryRes := MPSysOpenQuery(cQuery)

            lRet := lRet .and. oModelF3C:LoadValue("F3C_ADSHNR", Max((cQueryRes)->F3C_ADSHNR, nTmpMaxNr) + 1)
            AAdd(aSheetNrs, {Stod( (cTab)->PRINT_DATE), Max((cQueryRes)->F3C_ADSHNR, nTmpMaxNr) + 1})
        EndIf 
    EndIf*/
    

    (cTab)->(DbSkip())
EndDo

If !lRet
    Help("",1,"RU09T05F3C:01",,STR0927,1,0)
EndIf
Return(lRet)



Function RU09T05Name()
Local cName := ""
Local cKey := ""
Local aArea := GetArea()
Local aAreaSA2 := SA2->(GetArea())
Local aAreaF37 := F37->(GetArea())
 
DbSelectArea("F37")
F37->(DbSetOrder(3))
If (F37->(DbSeek(xFilial("F37") + F3C->F3C_KEY)))
    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    cKey := F37->(F37_FORNEC + F37_BRANCH)
    If !Empty(AllTrim(cKey)) .and. (SA2->(DbSeek(xFilial("SA2") + cKey)))
        cName := SA2->A2_NREDUZ
    EndIf
EndIf
 
RestArea(aAreaF37)
RestArea(aAreaSA2)
RestArea(aArea)
Return(cName)


/*/
@author: Ruslan Burkov
@description: return start and and dates of quarter by data
/*/
Function RU09T05GetQD(dData) 
	Local nMonth as Numeric
	Local cStartDate as Character
	Local cEndDate as Character
	Local aRet as Array

	nMonth := Month(dData) 
	If nMonth >= 1 .and. nMonth <= 9
		If nMonth <= 3
			nMonth := 1
		ElseIf nMonth <= 6
			nMonth := 4
		Else
			nMonth := 7
		EndIf
		cStartDate := AllTrim(Str(Year(dData))) + StrZero(nMonth, 2) + "01"
		cEndDate :=  AllTrim(Str(Year(dData))) + StrZero(nMonth + 3, 2) + "01"  // end not include!
		aRet := {cStartDate, cEndDate}
	ElseIf nMonth >= 10 .and. nMonth <= 12
		nMonth := 10
		cStartDate := Str(Year(dData)) + StrZero(nMonth, 2) + "01"
		cEndDate := Str(Year(dData) + 1) + "0101" // end not include!
		aRet := {cStartDate, cEndDate}
	EndIf

Return aRet



/*{Protheus.doc} RU09T05_01getSQLquery
It is an attempt to generalize common things.
@author Artem Kostin
@since 01/28/2019
@version P12.1.23
@type function
*/
Function RU09T05_01getSQLquery(oModelF3C as Object)
	Local cQuery as Character
	Local nLine as Numeric

	cQuery := " SELECT T0.F32_KEY AS VAT_KEY,"
	cQuery += " T0.F32_DOC AS DOC_NUM,"
	cQuery += " T0.F32_VATCOD AS INTCODE,"
	cQuery += " T0.F32_VATCD2 AS EXTCODE,"
	cQuery += " T0.F32_INIBS AS INIT_BASE,"
	cQuery += " T0.F32_INIBAL AS INIT_VALUE,"
	cQuery += " T0.F32_OPBS AS OPEN_BASE,"
	cQuery += " T0.F32_OPBAL AS OPEN_BALANCE,"
	cQuery += " T0.F32_PDATE AS PRINT_DATE,"
	cQuery += " T0.F32_VATRT AS VAT_RATE,"
	cQuery += " T1.F37_CNEE_B,"
	cQuery += " T1.F37_CNOR_C,"
	cQuery += " T1.F37_CNOR_B,"
	cQuery += " T1.F37_CNEE_C,"
	cQuery += " T1.F37_ADJNR,"
	cQuery += " T1.F37_ADJDT,"
	cQuery += " T0.F32_SUPPL AS SUPPL,"
	cQuery += " T0.F32_SUPUN AS SUPUN,"
	cQuery += " T2.A2_NOME AS SHORTNAME,"
	cQuery += " T1.F37_INVCUR, "
	cQuery += " T3.F31_CODE, "
	cQuery += " T3.F31_TG_COD, "
	cQuery += " T3.F31_TYPE "
	cQuery += " FROM " + RetSQLName("F32") + " AS T0 "
	cQuery += " LEFT JOIN " + RetSQLName("F37") + " T1"
	cQuery += " ON T1.F37_FILIAL  = '" + xFilial("F37") + "'"
	cQuery += " AND T1.D_E_L_E_T_ = ' '"
	cQuery += " AND T1.F37_KEY = T0.F32_KEY"
	cQuery += " LEFT JOIN " + RetSQLName("SA2") + " T2"
	cQuery += " ON T2.A2_FILIAL = '" + xFilial("SA2") + "'"
	cQuery += " AND T2.D_E_L_E_T_ = ' '"
	cQuery += " AND T2.A2_COD = T0.F32_SUPPL"
	cQuery += " AND T2.A2_LOJA = T0.F32_SUPUN"
	cQuery += " LEFT JOIN " + RetSQLName("F31") + " T3"
	cQuery += " ON T3.F31_FILIAL = '" + xFilial("F31") + "' "
	cQuery += " AND T3.D_E_L_E_T_ = ' '"
	cQuery += " AND T0.F32_VATCOD = T3.F31_CODE"
	cQuery += " WHERE T0.F32_FILIAL = '" + xFilial("F32") + "' "
	cQuery += " AND T0.D_E_L_E_T_ = ' '"
	cQuery += " AND T0.F32_OPBS > 0"
// Goes thought the grid and collects list of Doc Numbers, which are already in the Model.
// Lines marked as deleted must be counted too, because user can undelete them.
	For nLine := 1 to oModelF3C:Length(.F.)
		oModelF3C:GoLine(nLine)
		If !Empty(AllTrim(oModelF3C:GetValue("F3C_KEY")))
			// Adds conditions to exclude the records, which are already in the model, from SQL query.
			cQuery += " AND NOT ("
			cQuery += " T0.F32_KEY = '" + oModelF3C:GetValue("F3C_KEY") + "'"
			cQuery += " AND T0.F32_VATCOD = '" + oModelF3C:GetValue("F3C_VATCOD") + "'"
			cQuery += " )"
		EndIf
	Next nLine

Return(cQuery)



/*{Protheus.doc} RU09T05_02getSQLorderby
It is an attempt to generalize common things.
@author Artem Kostin
@since 01/28/2019
@version P12.1.23
@type function
*/
Function RU09T05_02getSQLorderby()
	Local cQuery as Character
	cQuery := " ORDER BY T0.F32_FILIAL"
	cQuery += " ,T0.F32_SUPPL"
	cQuery += " ,T0.F32_SUPUN"
	cQuery += " ,T0.F32_DOC"
	cQuery += " ,T0.F32_RDATE"
	cQuery += " ,T0.F32_KEY"
	cQuery += " ,T0.F32_VATCOD"
	cQuery += " ,T0.F32_VATCD2"
Return(cQuery)


Function RU09T05CTL_View()
	Local oModel as Object

	oModel:= FwLoadModel("RU09T05")
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	FwExecView(STR0902, "RU09T05", MODEL_OPERATION_VIEW,/* oDlg */, /*{|| .T.}*/,/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel)

Return
/*/{Protheus.doc} RU09T05001_RETBOOK
Function thats storno accounting entries.
@author Sergeeva Daria
@since 10/01/2020
@version P12.1.16
@param oModel, object, Needs to receive the actual model.
@param lInc, logical, Needs to inform it is an inclusion or not.
@type function
/*/
Function RU09T05001_RETBOOK()
	Local oModel as Object
	Local lEnt as Logical
	Local lRet as Logical

	lEnt:=.F.
	lRet := .T.
	DbSelectArea('F3B')
	DbSetOrder(1)
	If RecLock("F3B", .F.)
		oModel:= FwLoadModel("RU09T05")
		oModel:SetOperation(4)
		oModel:Activate()
		Begin Transaction
			If F3B->F3B_STATUS=="3" .And. !Empty(F3B->F3B_DTLA)
				lRet := ctbVATpurb(oModel,lEnt)
				FwFldPut('F3B_STATUS','1',,,,.T.)//oModelF3B:LoadValue("F3B_STATUS","1") //oModelF3B:SetValue("F3B_STATUS","1")
				oModel:GetModel("F3BMASTER"):SetValue("F3B_DTLA",stod(""))
			EndIf
			If lRet .AND. oModel:VldData()
				lRet := oModel:CommitData()
			ENDIF
			If !lRet
				DisarmTransaction()
			EndIf
		End Transaction
		F3B->(MSUnlock())
	EndIf
Return lRet

/*/{Protheus.doc} ctbVATpurb
Function thats posts accounting entries.
@author Sergeeva Daria
@since 10/01/2020
@version P12.1.16
@param oModel, object, Needs to receive the actual model.
@param lInc, logical, Needs to inform it is an inclusion or not.
@type function
/*/

Static Function ctbVATpurb(oModel as Object, lInc as Logical)
	Local lRet as Logical
	Local oModelF3B as Object
	Local oModelF3C as Object

	Local oModelF64P as Object
	Local oModelF64R as Object

	Local nHdlPrv as Numeric
	Local cLoteFis as Character
	Local cOrigem as Character
	Local cArquivo as Character
	Local nTotal as Numeric
	Local lCommit as Logical
	Local cPadrao as Character
	Local lMostra as Logical
	Local lAglutina as Logical
	Local cPerg as Character
	Local nOperation as Numeric

// Used areas
	Local aArea as Array
	Local aAreaF37 as Array
	Local aAreaF38 as Array
	Local aAreaSF1 as Array
	Local aAreaSA2 as Array
	Local aAreaF64 as Array

	lRet := .T.
	oModelF3B := oModel:GetModel("F3BMASTER")
	oModelF3C := oModel:GetModel("F3CDETAIL")

	oModelF64P := oModel:GetModel("F64PDETAIL")
	oModelF64R := oModel:GetModel("F64RDETAIL")

	nTotal := 0
	aArea := GetArea()
	aAreaF37 := F37->(GetArea())
	aAreaF38 := F38->(GetArea())
	aAreaSF1 := SF1->(GetArea())
	aAreaSA2 := SA2->(GetArea())
	aAreaF64 := F64->(GetArea())

	cPerg := "RU09T05ACC"
	nOperation:=oModel:GetOperation()
	Pergunte(cPerg, .F.)
	lMostra := (mv_par01 == 1)
	lAglutina := (mv_par02 == 1)

	nHdlPrv := 0
	cLoteFis := LoteCont("FIS")
	cOrigem := "RU09T05ACC"
	cArquivo := " "
	lCommit := .F.
// If it is an inclusion, must be used the Standard Entry 6AE to the header.
// If it is a deletion, must be used the Standard Entry 6AF to the header.
	cPadrao := Iif(lInc, "6AE", "6AF")
	If VerPadrao(cPadrao) // Accounting beginning
		nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)
	EndIf

//Seek oon F3C
	DbSelectArea("F3C")
	F3C->(DbSetOrder(2))
	If (F3C->(DbSeek(xFilial("F3C")+oModelF3B:GetValue("F3B_BOOKEY"))))
		//While KEY on F3C is equal to key
		While (xFilial("F3C")+oModelF3B:GetValue("F3B_BOOKEY")) == F3C->(F3C_FILIAL+F3C_BOOKEY) .AND. lRet
			If RecLock("F3C",.F.)
				DbSelectArea("F37")
				F37->(DbSetOrder(7))
				If(F37->(DbSeek(xFilial("F37")+oModelF3C:GetValue("F3C_DOC"))))
					DbSelectArea("SF1")
					SF1->(DbSetOrder(1))
					If (F37->F37_TYPE == "2") .and. !(SF1->(DbSeek(xFilial("SF1") + SubStr(F37->F37_INVDOC, 1, TamSX3("F1_DOC")[1]) + SubStr(F37->F37_INVSER, 1, TamSX3("F1_SERIE")[1]))))
						lRet := .F.
					EndIf

					If lRet
						DbSelectArea("SA2")
						SA2->(DbSetOrder(1))
						If !SA2->(DbSeek(xFilial("SA2") + F37->F37_FORNEC + F37->F37_BRANCH))
							lRet:= .F.
						EndIf
					EndIf
				Else
					Help("",1,"RU09T05_ctbVATpurb_F37",,STR0023,1,0) // "VAT Sales Invoice Header of this record was not found. Cannot delete this record."
					lRet:= .F.
				EndIf

				If (nHdlPrv > 0) .And. lRet
					nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis, /*nLinha*/, /*lExecuta*/,/*cCriterio*/, /*lRateio*/, xFilial("F3B") + F3B->F3B_BOOKEY /*cChaveBusca */, ;
                /*aCT5*/,/*lPosiciona*/, /*@aFlagCTB*/, {'F3B',F3B->(Recno())} /*aTabRecOri*/, /*aDadosProva*/)

					//Updates the posting date.
					If lRet .AND. RecLock("F3B", .F.)
						F3B->F3B_DTLA := dDataBase
						F3B->(MsUnlock())
					Else
						lRet := .F.
					EndIf

					// Updates the Outflow Document Status for Russia.
					//If it is an inclusion needs to set "2" and if it is a deletion needs to set "1".
					If lRet .AND. RecLock("SF1", .F.)
						SF1->F1_STATUSR := Iif(lInc, "2", "1")
						SF1->(MsUnlock())
					Else
						lRet :=.F.
					EndIf
				EndIf
			Else
				lRet := .F.
			EndIf
			F3C->(MSUnlock())
			F3C->(DbSkip())
		EndDo
	EndIf
	If lRet
		If (nTotal > 0)
			cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lMostra, lAglutina)
		EndIf
		RodaProva(nHdlPrv, nTotal)
	EndIf

    /* Purchase Book - VAT Invoice on Advances Paid*/ 
	lRet := .T.
	nHdlPrv := 0
	cLoteFis := LoteCont("FIS")
	cOrigem := "RU09T05ACC"
	cArquivo := " "
	lCommit := .F.
    // If it is an inclusion, must be used the Standard Entry 6AQ
    // If it is a deletion, must be used the Standard Entry 6AR
	cPadrao := Iif(lInc, "6AQ", "6AR")
	If VerPadrao(cPadrao) // Accounting beginning
		nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)
	EndIf

    //Seek on F64
	DbSelectArea("F64")
	F64->(DbSetOrder(1))
	If F64->(DbSeek(xFilial("F64") + oModelF3B:GetValue("F3B_BOOKEY")))
		//While KEY on F64 is equal to key
		While xFilial("F64") == F64->F64_FILIAL .And. oModelF3B:GetValue("F3B_BOOKEY") == F64->F64_BOOKEY .And. lRet
			If F64->F64_TYPE == "1"
				If RecLock("F64",.F.)
					DbSelectArea("F37")
					F37->(DbSetOrder(7))
					If(F37->(DbSeek(xFilial("F37") + oModelF64P:GetValue("F64_DOC"))))
						If F37->F37_TYPE != "3"
							lRet := .F.
						EndIf

						If lRet
							DbSelectArea("SA2")
							SA2->(DbSetOrder(1))
							If !SA2->(DbSeek(xFilial("SA2") + F37->F37_FORNEC + F37->F37_BRANCH))
								lRet:= .F.
							EndIf
						EndIf
					Else
						Help("",1,"RU09T05_ctbVATpurb_F37",,STR0023,1,0) // "VAT Sales Invoice Header of this record was not found. Cannot delete this record."
						lRet:= .F.
					EndIf

					If (nHdlPrv > 0) .And. lRet
						nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis, /*nLinha*/, /*lExecuta*/,/*cCriterio*/, /*lRateio*/, xFilial("F64") + F64->F64_BOOKEY /*cChaveBusca */, ;
											/*aCT5*/,/*lPosiciona*/, /*@aFlagCTB*/, {'F64',F64->(Recno())} /*aTabRecOri*/, /*aDadosProva*/)

						//Updates the posting date.
						If lRet
							F64->F64_DTLA := dDataBase
							F64->(MsUnlock())
						EndIf

					EndIf
				Else
					lRet := .F.
				EndIf
				F64->(MSUnlock())
			EndIf
			F64->(DbSkip())
		EndDo
	EndIf
	If lRet
		If (nTotal > 0)
			cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lMostra, lAglutina)
		EndIf
		RodaProva(nHdlPrv, nTotal)
	EndIf

	/* Purchase Book - VAT Invoice on Advances Received*/ 
	lRet := .T.
	nHdlPrv := 0
	cLoteFis := LoteCont("FIS")
	cOrigem := "RU09T05ACC"
	cArquivo := " "
	lCommit := .F.
    // If it is an inclusion, must be used the Standard Entry 6AS
    // If it is a deletion, must be used the Standard Entry 6AT
	cPadrao := Iif(lInc, "6AS", "6AT")
	If VerPadrao(cPadrao) // Accounting beginning
		nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)
	EndIf

    //Seek on F64
	DbSelectArea("F64")
	F64->(DbSetOrder(1))
	If F64->(DbSeek(xFilial("F64") + oModelF3B:GetValue("F3B_BOOKEY")))
		//While KEY on F64 is equal to key
		While xFilial("F64") == F64->F64_FILIAL .And. oModelF3B:GetValue("F3B_BOOKEY") == F64->F64_BOOKEY .And. lRet
			If F64->F64_TYPE == "2"
				If RecLock("F64",.F.)
					DbSelectArea("F37")
					F37->(DbSetOrder(7))
					If(F37->(DbSeek(xFilial("F37") + oModelF64P:GetValue("F64_DOC"))))
						If F37->F37_TYPE != "3"
							lRet := .F.
						EndIf

						If lRet
							DbSelectArea("SA2")
							SA2->(DbSetOrder(1))
							If !SA2->(DbSeek(xFilial("SA2") + F37->F37_FORNEC + F37->F37_BRANCH))
								lRet:= .F.
							EndIf
						EndIf
					Else
						Help("",1,"RU09T05_ctbVATpurb_F37",,STR0023,1,0) // "VAT Sales Invoice Header of this record was not found. Cannot delete this record."
						lRet:= .F.
					EndIf

					If (nHdlPrv > 0) .And. lRet
						nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis, /*nLinha*/, /*lExecuta*/,/*cCriterio*/, /*lRateio*/, xFilial("F64") + F64->F64_BOOKEY /*cChaveBusca */, ;
											/*aCT5*/,/*lPosiciona*/, /*@aFlagCTB*/, {'F64',F64->(Recno())} /*aTabRecOri*/, /*aDadosProva*/)

						//Updates the posting date.
						If lRet
							F64->F64_DTLA := dDataBase
							F64->(MsUnlock())
						EndIf

					EndIf
				Else
					lRet := .F.
				EndIf
				F64->(MSUnlock())
			EndIf
			F64->(DbSkip())
		EndDo
	EndIf
	If lRet
		If (nTotal > 0)
			cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lMostra, lAglutina)
		EndIf
		RodaProva(nHdlPrv, nTotal)
	EndIf

	RestArea(aAreaF64)
	RestArea(aAreaSA2)
	RestArea(aAreaSF1)
	RestArea(aAreaF38)
	RestArea(aAreaF37)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} R09T05APay
Autofill F64 table on Purchases Book (Payment)
@type function
@author Fernando Nicolau
@since 08/01/2024
@param oModel, object, param_description
@return variant, return_description
/*/
Function R09T05APay(oModel)
	Local lRet := .T.

	Local aParam as Array
	Local aPerguntas as Array
	Local oModelF3B as Object
	Local oModelF64 as Object
	Local cTab as Character
	Local cQuery as Character
	Local cSepNeg as Character
	Local cSepPag as Character

    Local cTitMov As Character
    Local cTitSup As Character
    Local cTitBra As Character
	Local nValTot as Numeric

	aParam :={}
	aPerguntas	:= {}
	cTab :=''
	cQuery := ""
	nValTot :=0

	cSepNeg := Iif("|" $ MV_CPNEG, "|", ",")
	cSepPag := Iif("|" $ MVPAGANT, "|", ",")

	oModelF3B := oModel:GetModel("F3BMASTER")
	oModelF64 := oModel:GetModel("F64PDETAIL")
	oModelF64:GoLine(1)

    cTitMov := Posicione("SX3", 2, "FK2_DATA", "X3Titulo()")
    cTitSup := Posicione("SX3", 2, "F37_FORNEC", "X3Titulo()")
    cTitBra := Posicione("SX3", 2, "F37_BRANCH", "X3Titulo()")

	AAdd(aPerguntas, {1, cTitMov/* STR0016 */ + ' ' + STR0923, oModelF3B:GetValue("F3B_INIT") , "", '.T.' , "", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitMov/* STR0016 */ + ' ' + STR0924, oModelF3B:GetValue("F3B_FINAL"), "", "RU09T05002_VldDtFin('"+cTitMov+"')" , "", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, STR0916 + ' ' + STR0923, Space(TamSX3("F37_DOC")[1])            , "@!", '.T.', "F37", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, STR0916 + ' ' + STR0924, Replicate("Z", TamSX3("F37_DOC")[1])   , "@!", '.T.', "F37", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitSup + ' ' + STR0923, Space(TamSX3("F37_FORNEC")[1])         , "@!", '.T.', "SA2", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitBra + ' ' + STR0923, Space(TamSX3("F37_BRANCH")[1])         , "@!", '.T.', ""   , ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitSup + ' ' + STR0924, Replicate("Z", TamSX3("F37_FORNEC")[1]), "@!", '.T.', "SA2", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitBra + ' ' + STR0924, Replicate("Z", TamSX3("F37_BRANCH")[1]), "@!", '.T.', ""   , ".T.", 60, .F.})

	If ParamBox(aPerguntas, STR0925, aParam, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		cQuery := RU09T05006_MakeQueryPay(aParam)
		cTab := MPSysOpenQuery(ChangeQuery(cQuery))
		lRet := lRet .And. FillF64Table(oModelF64, cTab)
	EndIf
	nValTot := RU09T05005_RecalTot(oModelF64)
	oModel:GetModel("F3BMASTER"):LoadValue("F3B_TOTAL", nValTot)
	CloseTempTable(cTab)
	oModelF64:GoLine(1)
Return


/*/{Protheus.doc} R09T05ARec
Autofill F64 table on Purchases Book (Receivement)
@type function
@author Fernando Nicolau
@since 08/01/2024
@param oModel, object, param_description		
@return variant, return_description	
/*/
Function R09T05ARec(oModel)
	Local lRet := .T.

	Local aParam as Array
	Local aPerguntas as Array
	Local oModelF3B as Object
	Local oModelF64 as Object
	Local cTab as Character
	Local cQuery as Character
	Local cSepNeg as Character
	Local cSepRec as Character
    Local cTitMov As Character
    Local cTitCus As Character
    Local cTitBra As Character
	Local nValTot as Numeric

	aParam :={}
	aPerguntas	:= {}
	cTab :=''
	cQuery := ""
	nValTot :=0

	cSepNeg := Iif("|" $ MV_CRNEG, "|", ",")
	cSepRec := Iif("|" $ MVRECANT, "|", ",")

	oModelF3B := oModel:GetModel("F3BMASTER")
	oModelF64 := oModel:GetModel("F64RDETAIL")
	oModelF64:GoLine(1)

    cTitMov := Posicione("SX3", 2, "FK1_DATA", "X3Titulo()")
	cTitCus := Posicione("SX3", 2, "F35_CLIENT", "X3Titulo()")
    cTitBra := Posicione("SX3", 2, "F35_BRANCH", "X3Titulo()")

	AAdd(aPerguntas, {1, cTitMov/* STR0016 */ + ' ' + STR0923, oModelF3B:GetValue("F3B_INIT") , "", '.T.' , "", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitMov/* STR0016 */ + ' ' + STR0924, oModelF3B:GetValue("F3B_FINAL"), "", "RU09T05002_VldDtFin('"+cTitMov+"')" , "", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, STR0916 + ' ' + STR0923, Space(TamSX3("F35_DOC")[1])            , "@!", '.T.', "F35", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, STR0916 + ' ' + STR0924, Replicate("Z", TamSX3("F35_DOC")[1])   , "@!", '.T.', "F35", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitCus + ' ' + STR0923, Space(TamSX3("F35_CLIENT")[1])         , "@!", '.T.', "SA1", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitBra + ' ' + STR0923, Space(TamSX3("F35_BRANCH")[1])         , "@!", '.T.', ""   , ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitCus + ' ' + STR0924, Replicate("Z", TamSX3("F35_CLIENT")[1]), "@!", '.T.', "SA1", ".T.", 60, .F.})
	AAdd(aPerguntas, {1, cTitBra + ' ' + STR0924, Replicate("Z", TamSX3("F35_BRANCH")[1]), "@!", '.T.', ""   , ".T.", 60, .F.})

	If ParamBox(aPerguntas,STR0925,aParam, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosY*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		cQuery := RU09XFN023_AdvancesVATSqlQuery(oModelF64)
		cQuery += " AND FK1.FK1_DATA BETWEEN '" + DtoS(aParam[1]) + "' AND '" + DtoS(aParam[2]) + "'"
		cQuery += " AND F35.F35_DOC BETWEEN '" + aParam[3] + "' AND '" + aParam[4] + "'"
		cQuery += " AND F35.F35_CLIENT BETWEEN '" + aParam[5] + "' AND '" + aParam[7] + "'"
		cQuery += " AND F35.F35_BRANCH BETWEEN '" + aParam[6] + "' AND '" + aParam[8] + "'"
		cQuery += " AND (F35.F35_TIPO IN " + FormatIn(MVRECANT, cSepRec) + " OR "
		cQuery += "      F35.F35_TIPO IN " + FormatIn(MV_CRNEG, cSepNeg) + " ) "

		cQuery += RU09XFN024_AdvancesVATGroupBy(oModelF64)
		cTab := MPSysOpenQuery(ChangeQuery(cQuery))
		lRet := lRet .and. FillF64Table(oModelF64, cTab)
	EndIf

	nValTot := RU09T05005_RecalTot(oModelF64)
	oModel:GetModel("F3BMASTER"):LoadValue("F3B_TOTAL", nValTot)
	CloseTempTable(cTab)
	oModelF64:GoLine(1)
Return

/*/{Protheus.doc} FillF64Table
Fill Purchases Book (F64 table)
@type function
@author Fernando Nicolau
@since 08/01/2024
@param oSubModel, object, param_description
@param cTab, character, param_description
@return variant, return_description
/*/
Function FillF64Table(oSubModel, cTab)
	Local aSheetNums as Array
	Local lAddLine   as Logical
	Local lTooLate   as Logical
	Local lZeroVatVl as Logical
	Local lOk        as Logical
	Local nLine      as Numeric
	Local oModel     as Object // Purchases book root model

	lAddLine := !Empty(AllTrim(oSubModel:GetValue("F64_KEY")))
	lOk := .T.
	oModel := oSubModel:oFormModel

	aSheetNums := {}

	While lOk .And. !(cTab)->(Eof())
		
		// If there is no empty line, add new line and push new data to the bottom of the grid.
		// If there is already an empty line, data could be inserted starting from this empty line.
		If lAddLine
			nLine := oSubModel:AddLine()
		Else
			nLine := oSubModel:Length(.F.)
			lAddLine := .T.
		EndIf

		If oSubModel:GetId() == "F64PDETAIL"
			lTooLate := SToD((cTab)->F37_PDATE) > FWFldGet("F3B_FINAL")
			lZeroVatVl := (cTab)->F38_VATVL == 0
		ElseIf oSubModel:GetId() == "F64RDETAIL"
			lTooLate := SToD((cTab)->F35_PDATE) > FWFldGet("F3B_FINAL")
			lZeroVatVl := (cTab)->F36_VATVL == 0
		EndIf

		If lTooLate .Or. lZeroVatVl
			(cTab)->(DbSkip())
			lAddLine := .F.
			Loop
		EndIf

		lOk := lOk .And. FillVATPurchaseBook(oSubModel, cTab, nLine)

		If !lOk
			RU99XFUN05_Help(STR0927)
			Exit
		EndIf
		
		(cTab)->(DbSkip())
	EndDo

	RU05XFN008_Help(oModel)
Return lOk

/*/{Protheus.doc} FillVATPurchaseBook
Fill Purchases Book Grid (F64 table)
@type function
@author Fernando Nicolau
@since 08/01/2024
@param oSubModel, object, param_description
@param cTab, character, param_description
@param nLine, numeric, param_description
@return variant, return_description
/*/
Function FillVATPurchaseBook(oSubModel as Object, cTab as Character, nLine as Numeric)
	Local aArea As Array
	Local lOk as Logical
	Local cTabFK As Character
    Local cTabVAT As Character
    Local cTabVATDet As Character
    Local cTabSupCli As Character
    Local cFldSupCli As Character
	Local cTabBS as Character
	Local cQuery as Character

	aArea := GetArea()
	cTabBS := ""
	cQuery := ""

    If oSubModel:GetId() == "F64PDETAIL"
        cTabFK := "FK2"
        cTabVAT := "F37"
        cTabVATDet := "F38"
        cTabSupCli := "A2"
        cFldSupCli := "_FORNEC"
    ElseIf oSubModel:GetId() == "F64RDETAIL"
        cTabFK := "FK1"
        cTabVAT := "F35"
        cTabVATDet := "F36"
        cTabSupCli := "A1"
        cFldSupCli := "_CLIENT"
    EndIf

	lOk := oSubModel:LoadValue("F64_ITEM", PadL(nLine,TamSX3('F64_ITEM')[1],"0")) //AutoFill does not work when filling by code
	lOk := oSubModel:LoadValue("F64_KEY", &("(cTab)->" + cTabVAT + "_KEY"))
	lOk := lOk .And. oSubModel:LoadValue("F64_DOC",  rtrim(&("(cTab)->" + cTabVAT + "_DOC")))
	lOk := lOk .And. oSubModel:LoadValue("F64_PDATE", SToD(&("(cTab)->" + cTabVAT + "_PDATE")))
	lOk := lOk .And. oSubModel:LoadValue("F64_ADJNR", &("(cTab)->" + cTabVAT + "_ADJNR"))
	lOk := lOk .And. oSubModel:LoadValue("F64_ADJDT", SToD(&("(cTab)->" + cTabVAT + "_ADJDT")))
	lOk := lOk .And. oSubModel:LoadValue("F64_VATCOD", &("(cTab)->" + cTabVATDet + "_VATCOD"))
	lOk := lOk .And. oSubModel:LoadValue("F64_VATCD2", &("(cTab)->" + cTabVATDet + "_VATCD2"))

	lOk := lOk .And. oSubModel:LoadValue("F64_SUCL", &("(cTab)->" + cTabVAT + cFldSupCli))
	lOk := lOk .And. oSubModel:LoadValue("F64_SUCLBR", &("(cTab)->" + cTabVAT + "_BRANCH"))
	lOk := lOk .And. oSubModel:LoadValue("F64_SUCLNM", SubStr(&("(cTab)->" + cTabSupCli + "_NOME"), 1, TamSX3("F64_SUCLNM")[1]))
	lOk := lOk .And. oSubModel:LoadValue("F64_INVCUR", &("(cTab)->" + cTabVAT + "_INVCUR"))

	lOk := lOk .And. oSubModel:LoadValue("F64_VALGR", &("(cTab)->" + cTabVATDet + "_VALGR"))
	lOk := lOk .And. oSubModel:LoadValue("F64_VATBS", &("(cTab)->" + cTabVATDet + "_VATBS"))
	lOk := lOk .And. oSubModel:LoadValue("F64_VATRT", &("(cTab)->" + cTabVATDet + "_VATRT"))
	lOk := lOk .And. oSubModel:LoadValue("F64_VATVL", &("(cTab)->" + cTabVATDet + "_VATVL"))
	lOk := lOk .And. oSubModel:LoadValue("F64_ORIGGR", &("(cTab)->" + cTabVATDet + "_VALGR"))
	If !empty(&("(cTab)->" + cTabFK + "_DATA"))
		lOk := lOk .And. oSubModel:LoadValue("F64_MDATE"	, stod(&("(cTab)->" + cTabFK + "_DATA")))
		lOk := lOk .And. oSubModel:LoadValue("F64_MSEQ"		,  Padr(&("(cTab)->" + cTabFK + "_SEQ"),TamSX3( cTabFK + "_SEQ")[1]))
		lOk := lOk .And. oSubModel:LoadValue("F64_HISTOR"	,Padr(&("(cTab)->" + cTabFK + "_HISTOR"),TamSX3( cTabFK + "_HISTOR")[1]))
		lOk := lOk .And. oSubModel:LoadValue("F64_IDFK"		, Padr(&("(cTab)->" + cTabFK + "_ID" + cTabFK),TamSX3( cTabFK + "_ID" + cTabFK)[1]))
	Endif 

	DbSelectArea(cTabVAT)
	(cTabVAT)->(DbSetOrder(3))
	If (cTabVAT)->(MsSeek(xFilial(cTabVAT) + &("(cTab)->" + cTabVAT + "_KEY")))

		If oSubModel:GetId() == "F64PDETAIL"
			cF5MKey := xFilial("F5M") + "|" + (cTabVAT)->F37_PREFIX + "|"+ (cTabVAT)->F37_NUM + "|" + (cTabVAT)->F37_PARCEL + "|"+ (cTabVAT)->F37_TIPO +"|" + (cTabVAT)->F37_FORNEC + "|" + (cTabVAT)->F37_BRANCH
		ElseIf oSubModel:GetId() == "F64RDETAIL"
			cF5MKey := xFilial("F5M") + "|" + (cTabVAT)->F35_PREFIX + "|"+ (cTabVAT)->F35_NUM + "|" + (cTabVAT)->F35_PARCEL + "|"+ (cTabVAT)->F35_TIPO +"|" + (cTabVAT)->F35_CLIENT + "|" + (cTabVAT)->F35_BRANCH
		EndIf

		cQuery := " SELECT F4C_BNKORD, F4C_DTPAYM "
		cQuery += " FROM " + RetSQLName("F4C") + " F4C "
		cQuery += " INNER JOIN " + RetSQLName("F5M") + " F5M ON (F5M_IDDOC = F4C_CUUID and F5M_FILIAL = '" + xFilial("F5M") + "') "
		cQuery += " WHERE F4C.D_E_L_E_T_ = ' ' AND F5M.D_E_L_E_T_= ' ' "
		cQuery += " AND F5M_KEY like '" + cF5MKey + "%' and F5M_ALIAS = 'F4C' "
		cTabBS := MPSysOpenQuery(ChangeQuery(cQuery))

		If !(cTabBS)->(Eof())
			lOk := lOk .And. oSubModel:LoadValue("F64_BNKORD", (cTabBS)->F4C_BNKORD)
			lOk := lOk .And. oSubModel:LoadValue("F64_DTPAYM", StoD((cTabBS)->F4C_DTPAYM))
		EndIf

	EndIf
	
	CloseTempTable(cTabBS)
	RestArea(aArea)
Return lOk


/*/{Protheus.doc} RU09T05002_VldDtFin
	Function responsible to validate the ?	Movement Date this value must be less or equal the value at XXX_FINAL
	@type  Function
	@author eduardo.Flima
	@since 23/02/2024
	@version 23/02/2024
	@param cTitMov	, Character	, Title of the final date typed 
	@return lRet	,Logical	, If it is valid
/*/
Function RU09T05002_VldDtFin(cTitMov as Character) as Logical
	Local lRet 			As Logical
	Local oModel 		As Object
	Local oModMas 		As Object
	Local cTable 		As Character
	Local dDtFinPerg	As Date
	Local dDtFinBook	As Date
	Default cTitMov :=""
	lRet := .T.
	oModel := FWModelActive()
	oModMas := RU09T05003_ModMaster(oModel)
	cTable :=  RU09T05004_ModTable(oModMas)
	dDtFinPerg := MV_PAR02
	dDtFinBook := oModMas:getvalue(cTable+"_FINAL")
	If dDtFinPerg > dDtFinBook
		cHelp := +  cTitMov + ' ' + STR0924 + ' ' +">"  +  Posicione("SX3", 2, cTable+"_FINAL", "X3Titulo()")
		Help("",1,"RU09T05VldDtFin",,cHelp ,1,0)
		lRet :=.F.
	Endif
Return lRet


/*/{Protheus.doc} Static Function RU09T05003_ModMaster
	Returns the submodel master from the main model.
    @type  Function
    @author eduardo.Flima
    @since 02/10/2022
    @version 23/02/2024
    @param oModel , Object      , Model thhat will be extracted the  master Sub Model
    @param cModNam, Character   ,String with the name of the submodel(opitional)
    @return oModMas, Object		,Submodel master from the main model. 
/*/
Static Function RU09T05003_ModMaster(oModel,cModNam)
    Local oModMas := NIL
    Default cModNam := NIL

    If cModNam == Nil
        cModNam:= oModel:GetDependency()[1][2]
    Endif 
    oModMas   :=  oModel:GetModel(cModNam)
    
Return oModMas


/*/{Protheus.doc} Static Function ModTable
    Returns the Table assigned to a given submodel
    @type  Function
    @author eduardo.Flima
    @since 06/09/2023
    @version 23/02/2024
    @param oSubModel, Object , SubModel
    @return cTable  , Character, Submodel table name
/*/
Static Function RU09T05004_ModTable(oSubModel)
    Local cTable :=""
    If oSubModel:oformmodelstruct:atable[1] != Nil
        cTable := oSubModel:oformmodelstruct:atable[1]
    Endif 
Return cTable

/*/{Protheus.doc} Static Function ModTable
    Returns the Table assigned to a given submodel
    @type  Function
    @author eduardo.Flima
    @since 06/09/2023
    @version 23/02/2024
    @param oSubModel, Object , SubModel
    @return cTable  , Character, Submodel table name
/*/
Static Function RU09T05005_RecalTot(oModelF64 as Object) As Numeric
	Local nLinha	As Numeric
	Local nX 		As Numeric
	Local nTotal 	As Numeric

	nLinha	:= 	oModelF64:GetLine()
	nX 		:= 	0
	nTotal 	:=	0

	For nX := 1 To oModelF64:Length()
		If !oModelF64:IsDeleted()
			oModelF64:GoLine(nX)
			nTotal += oModelF64:GetValue('F64_VALGR')
		Endif
	Next nX
	
	oModelF64:GoLine( nLinha )
Return nTotal

/*/{Protheus.doc} RU09T05006_MakeQueryPay
	Assemble query for  VAT Advances payment in the Purch.Book
	@type  Static Function
	@author eduardo.Flima
	@since 02/03/2024
	@version version
	@param aParam	, Array 	, Array with the parameters from the pergunte to be used as filter for query
	@return cQuery	, Character	, Result of the querry toretrieve data from VAT Advances payment in the Purch.Book
/*/
Static Function RU09T05006_MakeQueryPay(aParam as Array) as Character
	Local cQuery	as Character
	Local cTabFK	as Character 
	Local cDocIni	as Character
	Local cDocFin	as Character
	Local cDtIni	as Character
	Local cDtFin	as Character
	Local cForIni	as Character
	Local cForFin	as Character
	Local cFilIni	as Character
	Local cFilFin	as Character
	Local cSepNeg	as Character
	Local cSepPag	as Character

	cDtIni 	:= DtoS(aParam[1])
	cDtFin	:= DtoS(aParam[2])
	cDocIni	:= aParam[3]
	cDocFin	:= aParam[4] 
	cForIni	:= aParam[5]
	cForFin	:= aParam[7] 
	cFilIni	:= aParam[6]
	cFilFin	:= aParam[8]

	cSepNeg := Iif("|" $ MV_CPNEG, "|", ",")
	cSepPag := Iif("|" $ MVPAGANT, "|", ",")



	cTabFK :='FK2'

	cQuery := " SELECT "
	cQuery +=	" COALESCE(FK2.FK2_DATA, '')           FK2_DATA,"
	cQuery +=	" COALESCE(FK2.FK2_SEQ, '')            FK2_SEQ,"
	cQuery +=	" COALESCE(FK2.FK2_HISTOR, '')         FK2_HISTOR,"
	cQuery +=	" COALESCE(FK2.FK2_IDFK2, '')          FK2_IDFK2,"
	cQuery +=	" F37.F37_DOC,"
    cQuery +=	" F37.F37_PDATE,"
    cQuery +=	" F37.F37_KEY,"
    cQuery +=	" F37.F37_INVSER,"
    cQuery +=	" F37.F37_INVDOC,"
    cQuery +=	" F37.F37_FORNEC,"
    cQuery +=	" F37.F37_BRANCH,"
    cQuery +=	" F37.F37_INVCUR,"
    cQuery +=	" F37.F37_ADJNR,"
    cQuery +=	" F37.F37_ADJDT,"
    cQuery +=	" F38.F38_VATCOD,"
    cQuery +=	" F38.F38_VATCD2,"
    cQuery +=	" SUM(F38.F38_VATVL1)                  F38_VATVL,"
    cQuery +=	" SUM(F38.F38_VATVL1 + F38.F38_VATBS1) F38_VALGR,"
    cQuery +=	" SUM(F38.F38_VATBS1)                  F38_VATBS,"
    cQuery +=	" F38.F38_VATRT,"
    cQuery +=	" SA2.A2_NREDUZ                        A2_NOME,"
    cQuery +=	" F37_INVDT,"
    cQuery +=	" F37_CNEE_B,"
    cQuery +=	" F37_CNOR_C,"
    cQuery +=	" F37_CNOR_B,"
    cQuery +=	" F37_CNEE_C"
	cQuery += 	" FROM     " + RetSqlName("F37") + " F37                   "
		cQuery +=	" INNER JOIN ("
			cQuery +=	" SELECT GRP.F34_KEY"
			cQuery +=	" FROM   ("
				cQuery +=	" SELECT F34.F34_KEY,"
				cQuery +=	" MAX(F34.F34_TYPE) AS TYPE"
				cQuery += 	" FROM     " + RetSqlName("F34") + " F34                   "
				cQuery += 	" WHERE "
					cQuery += 	" F34.F34_DATE >= '" +cDtIni+"'"
					cQuery += 	"  AND "
					cQuery += 	" F34.F34_DATE <= '" +cDtFin+"'"
				cQuery +=   " GROUP  BY F34.F34_KEY"
			cQuery += " ) GRP"
			cQuery += " WHERE  GRP.TYPE = '01'"
		cQuery += " ) KEY34"
		cQuery += " ON KEY34.F34_KEY = F37_KEY"
		cQuery += 	" LEFT JOIN " + RetSqlName("F38") + " F38 "
			cQuery += 	" ON F38.F38_FILIAL = F37.F37_FILIAL "
			cQuery += 	" AND F38.D_E_L_E_T_ = ' ' "
			cQuery += 	" AND F38.F38_KEY = F37.F37_KEY "
		cQuery += 	" LEFT JOIN " + RetSqlName("SA2") + " SA2 "
			cQuery += 	" ON SA2.A2_FILIAL = '" + xFilial("SA2") +"'"
			cQuery += 	" AND SA2.A2_COD = F37.F37_FORNEC "
			cQuery += 	" AND SA2.A2_LOJA = F37.F37_BRANCH "
			cQuery += 	" AND SA2.D_E_L_E_T_ = ' ' "
		cQuery += 	" LEFT JOIN " + RetSqlName("SE2") + " SE2 "
			cQuery += 	" ON SE2.E2_FILIAL = '" + xFilial("SE2") +"'"
			cQuery += 	" AND SE2.E2_PREFIXO = F37.F37_PREFIX "
			cQuery += 	" AND SE2.E2_NUM = F37.F37_NUM "
			cQuery += 	" AND SE2.E2_PARCELA = F37.F37_PARCEL "
			cQuery += 	" AND SE2.E2_TIPO = F37.F37_TIPO "
			cQuery += 	" AND SE2.E2_FORNECE = F37.F37_FORNEC "
			cQuery += 	" AND SE2.E2_LOJA = F37.F37_BRANCH "
			cQuery += 	" AND SE2.D_E_L_E_T_ = ' ' "
		cQuery += 	" LEFT JOIN " + RetSqlName("FK7") + " FK7 "
			cQuery += 	" ON FK7.FK7_FILIAL = '" + xFilial("FK7") +"'"
			cQuery += 	" AND FK7.FK7_PREFIX = F37.F37_PREFIX "
			cQuery += 	" AND FK7.FK7_NUM = F37.F37_NUM "
			cQuery += 	" AND FK7.FK7_PARCEL = F37.F37_PARCEL "
			cQuery += 	" AND FK7.FK7_TIPO = F37.F37_TIPO "
			cQuery += 	" AND FK7.FK7_CLIFOR = F37.F37_FORNEC "
			cQuery += 	" AND FK7.FK7_LOJA = F37.F37_BRANCH "
			cQuery += 	" AND FK7.FK7_ALIAS = 'SE2' "
			cQuery += 	" AND FK7.D_E_L_E_T_ = ' ' "
		cQuery += 	" LEFT JOIN " + RetSqlName("FK2") + " FK2 " 
			cQuery += 	" ON FK2.FK2_FILIAL = '" + xFilial("FK2") +"'"
			cQuery += 	" AND FK2.FK2_IDDOC = FK7.FK7_IDDOC "
			cQuery += 	" AND FK2.D_E_L_E_T_ = ' ' "
		cQuery += 	" LEFT JOIN " + RetSqlName("FKA") + " FKA "
			cQuery += 	" ON FKA.FKA_FILIAL = '" + xFilial("FKA") +"'"
			cQuery += 	" AND FKA.FKA_IDORIG = FK2.FK2_IDFK2 "
			cQuery += 	" AND FKA.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE "
		cQuery += 	" F37.F37_FILIAL = '" + xFilial("F37") +"'"
		cQuery += 	" AND F37.D_E_L_E_T_ = ' ' " 
		cQuery += 	" AND F37.F37_BOOK = ' ' " 
		cQuery += 	" AND F37.F37_TYPE = '3' " 
		cQuery += 	" AND "
		cQuery +=   " ( "
			cQuery += " FK2.FK2_TPDOC IN ( 'BA', 'VL' ) " 
			cQuery += " OR COALESCE(FK2.FK2_TPDOC, '') = '' " 			
		cQuery +=   " ) "
		cQuery += "	AND NOT EXISTS "
		cQuery +=" ( "
			cQuery += "	SELECT "
			cQuery += "		1 "
			cQuery += "	FROM "
			cQuery += "		" + RetSQLName("FK2") + " " + cTabFK + "_AUX "
			cQuery += "	INNER JOIN " + RetSQLName("FKA") + " FKA_AUX "
			cQuery += "  ON "
			cQuery += "		FKA_AUX.FKA_FILIAL = FKA.FKA_FILIAL "
			cQuery += "		AND FKA_AUX.FKA_IDORIG = " + cTabFK + "_AUX." + cTabFK + "_ID" + cTabFK + " "
			cQuery += "		AND FKA_AUX.FKA_TABORI = '" + cTabFK + "' "
			cQuery += "		AND FKA_AUX.D_E_L_E_T_ = ' ' "
			cQuery += "	WHERE "
			cQuery += "		" + cTabFK + "_AUX." + cTabFK + "_FILIAL = " + cTabFK + "." + cTabFK + "_FILIAL "
			cQuery += "		AND FKA_AUX.FKA_IDPROC = FKA.FKA_IDPROC "
			cQuery += "		AND " + cTabFK + "_AUX." + cTabFK + "_TPDOC IN ('ES') "
			cQuery += "			AND " + cTabFK + "_AUX.D_E_L_E_T_ = ' ' "
		cQuery += " ) "
		cQuery += " AND "		
		cQuery += 	" F37.F37_DOC BETWEEN '" + cDocIni +"' AND '" + cDocFin +"' "
		cQuery += " AND "		
		cQuery += 	" F37.F37_FORNEC BETWEEN '" + cForIni +"' AND '" + cForFin +"' "
		cQuery += " AND "		
		cQuery += 	" F37.F37_BRANCH BETWEEN '" + cFilIni +"' AND '" + cFilFin +"' "
		cQuery += " AND (F37.F37_TIPO IN " + FormatIn(MVPAGANT, cSepPag) + " OR "
		cQuery += "      F37.F37_TIPO IN " + FormatIn(MV_CPNEG, cSepNeg) + " ) "
	cQuery += " GROUP  BY "
		cQuery += " FK2.FK2_DATA, "
		cQuery += " FK2.FK2_SEQ, "
		cQuery += " FK2.FK2_HISTOR, "
		cQuery += " FK2.FK2_IDFK2, "
		cQuery += " F37.F37_DOC, "
		cQuery += " F37.F37_PDATE, "
		cQuery += " F37.F37_KEY, "
		cQuery += " F38.F38_VATCOD, "
		cQuery += " F38.F38_VATCD2, "
		cQuery += " F37.F37_INVDT, "
		cQuery += " F37.F37_INVSER, "
		cQuery += " F37.F37_INVDOC, "
		cQuery += " F37.F37_FORNEC, "
		cQuery += " F37.F37_BRANCH, "
		cQuery += " F37.F37_INVCUR, "
		cQuery += " F37.F37_CNEE_B, "
		cQuery += " F37.F37_CNOR_C, "
		cQuery += " F37.F37_CNOR_B, "
		cQuery += " F37.F37_CNEE_C, "
		cQuery += " F37.F37_ADJNR, "
		cQuery += " F37.F37_ADJDT, "
		cQuery += " F38.F38_VATRT, "
		cQuery += " SA2.A2_NOME, "
		cQuery += " SA2.A2_NREDUZ "
	cQuery += " ORDER  BY "
		cQuery += " F37.F37_PDATE, "
		cQuery += " F37.F37_DOC, "
		cQuery += " F38.F38_VATCOD, "
		cQuery += " F38.F38_VATCD2 "
Return cQuery
                   
//Merge Russia R14 
                   
