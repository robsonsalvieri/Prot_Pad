#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "topconn.ch"
#INCLUDE "ru09xxx.ch"
#INCLUDE "ru09t10.ch"

#DEFINE RU09T10_SE2_FIELDS_HISTORY "E2_FILIAL;E2_PREFIXO;E2_NUM;E2_PARCELA;E2_TIPO;E2_FORNECE;E2_LOJA;E2_EMISSAO;E2_VENCREA;E2_VALOR;E2_SALDO;E2_TXMOEDA;E2_CONUNI;E2_MOEDA;E2_VLCRUZ;E2_BASIMP1;E2_ALQIMP1;E2_VALIMP1"
#DEFINE EXTRA_DAYS_AFTER_TAX_PERIOD 25

/* {Protheus.doc} RU09T10
Routine to deal with VAT Advances Paid
@type Function
@author Leandro Nunes
@since 01/11/2023
@version 1.0
@project MA3 - Russia
@return lRet,  Logical, If routine runs ok
*/
Function RU09T10() As Logical

	Local oBrowse As Object
	Local lRet    As Logical
	
	lRet := .T.

	DbSelectArea("F37")
	DbSelectArea("F38")

	oBrowse := FWLoadBrw("RU09T10")
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
Static Function BrowseDef()

	Local oBrowse As Object
	
	oBrowse	:= FWMBrowse():New()
	oBrowse:SetDescription(STR0001) //"Advances Payment"
	oBrowse:SetAlias("F37")

Return(oBrowse)

/* {Protheus.doc} MenuDef
Menu definitions
@type Static Function
@author Leandro Nunes
@since 01/11/2023
@project MA3 - Russia
*/
Static Function MenuDef()

    Local aButtons As Array

    aButtons := { ;
        {STR0004, "FwExecView('" + STR0004 + "', 'RU09T10', " + Str(MODEL_OPERATION_VIEW)   + ")", 0, 2, 0, Nil}, ; // "View" 
        {STR0005, "FwExecView('" + STR0005 + "', 'RU09T10', " + Str(MODEL_OPERATION_INSERT) + ")", 0, 3, 0, Nil}, ; // "Add"
        {STR0006, "FwExecView('" + STR0006 + "', 'RU09T10', " + Str(MODEL_OPERATION_UPDATE) + ")", 0, 4, 0, Nil}, ; // "Edit"
        {STR0007, "FwExecView('" + STR0007 + "', 'RU09T10', " + Str(MODEL_OPERATION_DELETE) + ")", 0, 5, 0, Nil}, ; // "Delete"
        {STR0021, "CTBC662", 0, 2, 0, Nil}} // "Track Posting"

Return()

/*/{Protheus.doc} ModelDef
Creates the model of Advances VAT Invoice.
@type Static Function
@author Leandro Nunes
@since 07/11/2023
@project MA3 - Russia
@return oModel, Object, Menu instance of the routine
/*/ 		 
Static Function ModelDef()

	Local oStructF37 As Object
	Local oStructF38 As Object
	Local oStructSE2 As Object
	Local oModelEvnt As Object

	Private oModel As Object

	oStructF37 := FWFormStruct(1, "F37")
	oStructF38 := FWFormStruct(1, "F38")
	oStructSE2 := FWFormStruct(1, "SE2", {|x| AllTrim(x) $ RU09T10_SE2_FIELDS_HISTORY})
	oStructF37:SetProperty("F37_RDATE", MODEL_FIELD_WHEN, {|| .T.})
	oStructF37 := RU09T03005_AddTriguers(oStructF37)
	oStructF37:SetProperty("F37_RDATE",  MODEL_FIELD_VALID, {| oModel | RU09T03006_VldDates(oModel)})
	oStructF37:SetProperty("F37_PDATE",  MODEL_FIELD_VALID, {| oModel | RU09T03006_VldDates(oModel)})

	oModel := MPFormModel():New("RU09T10", , , {|oModel| RU09T10017(oModel)},)
	oModel:SetDescription(STR0009)	// "Purchases VAT Invoices"

	oModel:AddFields("F37master", Nil, oStructF37, {|oModel, cAction, cField, xValue| RU09T10005(oModel, cAction, cField, xValue)}, {|oModel| RU09T10016(oModel)})
	oModel:GetModel("F37master"):SetDescription(STR0010) // "VAT Invoices Headers on Purchases"
	oModel:AddGrid("F38detail", "F37master", oStructF38)
	oModel:AddGrid("SE2detail", "F37master", oStructSE2)
	oModel:GetModel("F38detail"):SetDescription(STR0011) // "VAT Invoices Items on Purchases"
	oModel:SetRelation("F38detail", {;
		{"F38_FILIAL", "xFilial('F38')"}, ;
		{"F38_KEY", "F37_KEY"}}, ;
		F38->(IndexKey(1)))
	oModel:SetRelation("SE2detail", {;
		{"E2_FILIAL", "xFilial('SE2')"}, ;
		{"E2_PREFIXO", "F37_PREFIX"}, ;
		{"E2_NUM", "F37_NUM"}, ;
		{"E2_PARCELA", "F37_PARCEL"}, ;
		{"E2_TIPO", "F37_TIPO"}, ;
		{"E2_FORNECE", "F37_FORNEC"}, ;
		{"E2_LOJA", "F37_BRANCH"}}, ;
		SE2->(IndexKey(1)))
	oModel:SetPrimaryKey({"F37_FILIAL", "F37_FORNEC", "F37_BRANCH", "F37_PDATE", "F37_DOC", "F37_TYPE"})
	oModel:GetModel("F38detail"):SetUniqueLine({"F38_ITEM"})

	oModel:SetOnlyQuery("SE2detail")
	oModel:GetModel("SE2detail"):SetOptional(.T.)

	oModelEvnt := RU09T10EventRUS():New()
	oModel:InstallEvent("oModelEvnt",, oModelEvnt)
	
	oStructF38:SetProperty("F38_VATBS",  MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})
	oStructF38:SetProperty("F38_VALGR",  MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})
	oStructF38:SetProperty("F38_VATVL",  MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})
	oStructF38:SetProperty("F38_VATBS1", MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})
	oStructF38:SetProperty("F38_VATVL1", MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})
	oStructF38:SetProperty("F38_VALUE",  MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})

Return(oModel)

/*/{Protheus.doc} ViewDef
Creates the view of Advances VAT Invoice.
@type Static function
@author Leandro Nunes
@since 06/11/2023
@project MA3 - Russia
@return oView, Object, View instance of the routine
/*/
Static Function ViewDef()

	Local oView As Object
	Local oModel As Object
	Local oStructF37 As Object
	Local oStrucTots As Object
	Local oStructF38 As Object
	Local oStructSE2 As Object
	Local cCmpF37 As Character
	Local cCmpF37_T As Character
	Local cCmpF38 As Character
	Local cCmpSE2 As Character
	Local lHide As Logical

	lHide := .F.

	// Defines which fields we don't need to show on the upper part of screen.
	cCmpF37 := "F37_VALUE;F37_EXC_VL;F37_VATBS;F37_VATVL;F37_VALGR ;F37_BOOK;F37_VATBS1;F37_VATVL1;F37_IDATE;F37_INVSER;F37_INVDOC;F37_CURR;F37_CONUNI;F37_MOEDA;F37_MOEDES;F37_ITDATE"
	// Defines which fields want to show on the upper part of screenfields for bottom part - Totals.
	cCmpF37_T := "F37_VALUE;F37_EXC_VL;F37_VATBS;F37_VATVL;F37_VATBS1;F37_VATVL1;F37_VALGR"
	// Defines which fields we don't need to show in greed.
	cCmpF38 := "F38_FILIAL;F38_KEY;F38_DOCKEY;F38_TYPE;F38_DOC;F38_DTLA;F38_INVSER;F38_INVDOC;F38_INVIT;F38_INVDT;F38_ITDATE"
	/*Com invoice sheet*/
	cCmpSE2 := "E2_FILIAL;E2_PREFIXO;E2_NUM;E2_PARCELA;E2_TIPO;E2_FORNECE;E2_LOJA;E2_EMISSAO;E2_VENCREA;E2_VALOR;E2_SALDO;E2_TXMOEDA;E2_CONUNI;E2_MOEDA;E2_VLCRUZ;E2_BASIMP1;E2_ALQIMP1;E2_VALIMP1"

	oModel := FwLoadModel("RU09T10")
	oStructF37 := FWFormStruct(2, "F37", {|x| !(AllTrim(x) $ cCmpF37)})
	oStructF38 := FWFormStruct(2, "F38", {|x| !(AllTrim(x) $ cCmpF38)})
	oStrucTots := FWFormStruct(2, "F37", {|x| (AllTrim(x) $ cCmpF37_T)})
	oStrucTots:SetNoFolder()
	/*Purchace invoice sheet*/

	//	LOT control.  How it works: Check if the parameter MV_RASTRO = S (Yes).
	// If yes, check that at least in one product the field B1_RASTRO = L (Lot).
	// If no "L" hide the fields F38_ORIGIN and F38_NUMDES. 
	If SuperGetMV("MV_RASTRO") == "S"
		lHide := RU09T10004_CheckLote()
	EndIf
		
	If (lHide)
		oStructF38:RemoveField("F38_ORIGIN")
		oStructF38:RemoveField("F38_NUMDES")
	EndIf

	if (F37->F37_TYPE) == "3"
		oStructF37:RemoveField("F37_INVDT")
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_F37M", oStructF37, "F37master")
	oView:AddGrid("VIEW_F38D",  oStructF38, "F38detail")
	oView:AddField("VIEW_F37T", oStrucTots, "F37master")
	oView:CreateHorizontalBox("HEADERBOX", 55)
	oView:CreateFolder('FOLDER1', 'HEADERBOX')
	oView:AddSheet('FOLDER1', 'Sheet1', STR0012) // "VAT Invoice"
	oView:CreateHorizontalBox("F37HEADERBOX", 100/*%*/,,,'FOLDER1', 'Sheet1')
	oView:SetOwnerView("VIEW_F37M", "F37HEADERBOX")
	oView:SetDescription(STR0009) // "Purchases VAT Invoices" 
	oView:CreateHorizontalBox("ITEMBOX", 35)
	oView:CreateHorizontalBox("TOTALBOX", 10)
	oView:SetOwnerView("VIEW_F38D", "ITEMBOX")
	oView:SetOwnerView("VIEW_F37T", "TOTALBOX")
	oView:SetCloseOnOk({|| .T.})

	oStructSE2 := FWFormStruct(2, "SE2", {|x| (AllTrim(x) $ cCmpSE2)})
	oView:AddGrid("VIEW_SE2D", oStructSE2, "SE2detail")
	oView:SetViewProperty("VIEW_SE2D", "GRIDDOUBLECLICK", {{|oModel| RU09T10006(oModel)}})
	oView:AddSheet('FOLDER1', 'Sheet2', STR0013) // "Payment Advances" 
	oView:CreateHorizontalBox("SE2HEADERBOX", 100,,, 'FOLDER1', 'Sheet2')
	oView:SetOwnerView("VIEW_SE2D", "SE2HEADERBOX")
	oView:SetNoInsertLine("VIEW_SE2D")
	oView:SetNoUpdateLine("VIEW_SE2D")
	oView:SetNoDeleteLine("VIEW_SE2D")
	oView:SetNoInsertLine("VIEW_F38D")
	oView:SetNoUpdateLine("VIEW_F38D")
	oView:SetNoDeleteLine("VIEW_F38D")
	oStructF37:RemoveField("F37_F5QUID")
	If !INCLUI
		oView:AddUserButton(STR0901, "" ,{|| RU09T05()}) // "Purchases Book"
		oView:AddUserButton(STR0935, "", {|| RU09T06()}) // "VAT Write-Off"
	EndIf
	oView:AddIncrementField("VIEW_F38D", "F38_ITEM")

Return(oView)

/* {Protheus.doc} RU09T10001_AdvancesScreen
Function shows all the Payment Advances.
@type Static Function
@author Leandro Nunes
@since 06/11/2023
@project MA3 - Russia
@param cParPerg, Character, Paramenters of the Pergunte in the following order: Pergunte's Name | Pergunte's Item
@return lRet, Logical, If the routine runs ok
*/
Function RU09T10001_AdvancesScreen(cParPerg as Character) As Logical
	
	Local lRet As Logical
	// Working areas
	Local aArea As Array
	Local aHeader As Array
	Local aCols As Array
	Local aRotina As Array
	Local oDlg As Object
	Local oData As Object
	Local oModel As Object
	Local nPosSup As Numeric
	Local nPosBranch As Numeric
	Local nLinha As Numeric
	Local cFilBkp As Character
	Local nSimplVers	As	Character
	Local cSupplier As Character
	Local cBranch As Character

	Default cParPerg := ""

	nSimplVers := RU09T10014_getVersion(cParPerg)
	aArea   := GetArea()
	aHeader := RU09T10003_ReturnHeader()

	lRet := .T.

	// Variables initialisation
	aCols   := {}
	aRotina := {}
	cFilBkp := cFilAnt

	If RU09T10002(aCols, nSimplVers)
		If Len(aCols) > 0
			oDlg := MsDialog():New(160, 160, 400, 1200, STR0002, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // "Payment in Advance" 
		
			oData := MsNewGetDados():New(1, 1, , 1,,,,,,, 999,,,, oDlg, aHeader, aCols,,)
			oData:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oDlg:bInit := EnchoiceBar(oDlg, {|| lRet := .T., oDlg:End()}, {|| lRet := .F., oDlg:End()})
			oDlg:Activate(, , , .T., {|| .T.}, , {|| .F.})
		Else
			// If there is no record to create a Advance VAT Invoice, must be canceled and closed this window.
			lRet := .F.
			Help("", 1, "RU09T10001_AdvancesScreen01",, STR0003, 1, 0) // "According to your filters, no records were found"
		EndIf
	Else
		// Questions window was escaped or cancelled.
		lRet := .F.
	EndIf

	If (lRet)
		nPosSup := aScan(aHeader, {|x| AllTrim(x[2]) == "E2_FORNECE"})
		nPosBranch := aScan(aHeader, {|x| AllTrim(x[2]) == "E2_LOJA"})
		nLinha := oData:nAt
		
		cSupplier := oData:aCols[nLinha][nPosSup]
		cBranch := oData:aCols[nLinha][nPosBranch]
		
		// If it is everything OK, must to show a window to the end user to continue to add a Purchases VAT Invoice.
		oModel := FwLoadModel("RU09T10")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:SetDescription(STR0002) // "Payments in Advance"
		oModel:Activate()
		oModel := RU09T10008(oModel, oData, aHeader, cSupplier, cBranch)
		oModel:GetModel("F38detail"):SetNoInsertLine(.F.)
		oModel:GetModel("SE2detail"):SetNoInsertLine(.T.)
		FwExecView(STR0005, "RU09T10", MODEL_OPERATION_INSERT,, {|| .T.},,,,,,, oModel) // "Add" 
	EndIf

	cFilAnt := cFilBkp

	RestArea(aArea)

Return(lRet)

/* {Protheus.doc} RU09T10002_ReturnData (retDados)
Function that returns all records which is allowed to create a Advance VAT Invoice.
@type Static Function
@author Leandro Nunes
@since 03/11/2023
@project MA3 - Russia
@param aRet,       Array,   aCols from the calling routine
@param nSimplVers, Numeric, Type of Pergunte, if 1 is the Simplified Version, else, Complete Version
@return lRet,      Logical, If the routine runs ok
*/
Static Function RU09T10002_ReturnData(aRet As Array, nSimplVers As Numeric) As Logical

	Local lRet As Logical
	// Variables for SQL requests.
	Local cQuery As Character
	Local cTab As Character
	Local cTab2 As Character
	// Parameters of filtering questions.
	Local cPerg As Character
	Local cType As Character
	Local cFrPre As Character
	Local cToPre As Character
	Local cFrApN As Character
	Local cToApN As Character
	Local cFrIns As Character
	Local cToIns As Character	
	Local cFrSup As Character
	Local cFrBra As Character
	Local cToSup As Character
	Local cToBra As Character
	Local dFrIDt As Date
	Local dToIDt As Date
	Local aTypes As Array
	Local cIn As Character
	Local nCont As Numeric
	Local cSe2Key As Character

	Private cRetSX505 As Character // This variable is used in the Pergunte RU09T0302

	Default aRet := {}
	
	lRet := .T.
	cIn := ""
	cRetSX505 := ""
	If nSimplVers == 1
		cPerg := "RU09T0303"
	Else
		cPerg := "RU09T0302"
	EndIf

	// Opens the window with questions "From" - "To" used as filter.
	If (Pergunte(cPerg, .T.))
		If nSimplVers == 1
			dFrIDt := MV_PAR01
			dToIDt := MV_PAR02
		Else
			cType  := AllTrim(MV_PAR01)
			cFrApN := AllTrim(MV_PAR02)
			cToApN := AllTrim(MV_PAR03)
			cFrPre := AllTrim(MV_PAR04)
			cToPre := AllTrim(MV_PAR05)
			cFrIns := AllTrim(MV_PAR06)
			cToIns := AllTrim(MV_PAR07)
			cFrSup := AllTrim(MV_PAR08)
			cFrBra := AllTrim(MV_PAR09)
			cToSup := AllTrim(MV_PAR10)
			cToBra := AllTrim(MV_PAR11)
			dFrIDt := MV_PAR12
			dToIDt := MV_PAR13
		EndIf

		cQuery := "SELECT " + CRLF 
		cQuery += "    T0.E2_FILIAL, " + CRLF
		cQuery += "    T0.E2_PREFIXO, " + CRLF
		cQuery += "    T0.E2_NUM, " + CRLF
		cQuery += "    T0.E2_PARCELA, " + CRLF
		cQuery += "    T0.E2_TIPO, " + CRLF
		cQuery += "    T0.E2_FORNECE, " + CRLF
		cQuery += "    T0.E2_LOJA, " + CRLF
		cQuery += "    T1.A2_NOME, " + CRLF
		cQuery += "    T0.E2_EMISSAO, " + CRLF
		cQuery += "    T0.E2_VENCREA, " + CRLF
		cQuery += "    T0.E2_VALOR, " + CRLF
		cQuery += "    T0.E2_SALDO, " + CRLF
		cQuery += "    T0.E2_TXMOEDA, " + CRLF
		cQuery += "    T0.E2_CONUNI, " + CRLF
		cQuery += "    T0.E2_MOEDA, " + CRLF
		cQuery += "    T0.E2_VLCRUZ, " + CRLF
		cQuery += "    T0.E2_BASIMP1, " + CRLF
		cQuery += "    T0.E2_ALQIMP1, " + CRLF
		cQuery += "    T0.E2_VALIMP1 " + CRLF
		cQuery += "FROM " + RetSQLName("SE2") + " T0 INNER JOIN " + RetSQLName("SA2") + " T1 ON " + CRLF
		cQuery += "    (T1.A2_FILIAL = '" + xFilial("SA2") + "' AND " + CRLF 
		cQuery += "    T1.A2_COD = T0.E2_FORNECE AND " + CRLF
		cQuery += "    T1.A2_LOJA = T0.E2_LOJA AND " + CRLF 
		cQuery += "    T1.D_E_L_E_T_ = ' ') " + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "    T0.E2_FILIAL = '" + xFilial("SE2") + "' AND " + CRLF
		cQuery += "    T0.E2_MOEDA = '1' AND " + CRLF
		If nSimplVers == 2
			If (!Empty(cType))
				aTypes := Separa(cType, ';', .F.)
				For nCont := 1 To Len(aTypes)
					cIn += "'" + aTypes[nCont] + "'"
					If nCont < Len(aTypes) 
						cIn += ","
					EndIf
				Next
				cQuery += "    T0.E2_TIPO IN (" + cIn + ") AND " + CRLF
			EndIf
			cQuery += "    T0.E2_PREFIXO >= '" + cFrPre + "' AND " + CRLF
			cQuery += "    T0.E2_PREFIXO <= '" + cToPre + "' AND " + CRLF
			cQuery += "    T0.E2_NUM >= '" + cFrApN + "' AND " + CRLF
			cQuery += "    T0.E2_NUM <= '" + cToApN + "' AND " + CRLF
			cQuery += "    T0.E2_PARCELA >= '" + cFrIns + "' AND " + CRLF
			cQuery += "    T0.E2_PARCELA <= '" + cToIns + "' AND " + CRLF
			cQuery += "    T0.E2_FORNECE >= '" + cFrSup + "' AND " + CRLF
			cQuery += "    T0.E2_FORNECE <= '" + cToSup + "' AND " + CRLF
			cQuery += "    T0.E2_LOJA >= '" + cFrBra + "' AND " + CRLF
			cQuery += "    T0.E2_LOJA <= '" + cToBra + "' AND " + CRLF
			cQuery += "    T0.E2_EMISSAO >= '" + DToS(dFrIDt) + "' AND " + CRLF
			cQuery += "    T0.E2_EMISSAO <= '" + DToS(dToIDt) + "' AND " + CRLF
		EndIf
		cQuery += "    T0.E2_PREFIXO || T0.E2_NUM || T0.E2_PARCELA || T0.E2_TIPO NOT IN (" + CRLF
		cQuery += "    SELECT " + CRLF
		cQuery += "        F37_PREFIX || F37_NUM || F37_PARCEL || F37_TIPO " + CRLF
		cQuery += "    FROM " + RetSqlName("F37") + " F WHERE F37_FILIAL = '" + xFilial("F37") + "' AND F.D_E_L_E_T_ = ' ') AND " + CRLF
		cQuery += "    T0.D_E_L_E_T_ = ' '"
		cTab := MPSysOpenQuery(ChangeQuery(cQuery))
		DbSelectArea((cTab))
		(cTab)->(DbGoTop())
		
		While ((cTab)->(!Eof()))
			cSe2Key := (cTab)->E2_FILIAL + "|" + ;
				(cTab)->E2_PREFIXO + "|" + ;
				(cTab)->E2_NUM + "|" + ;
				(cTab)->E2_PARCELA + "|" + ;
				(cTab)->E2_TIPO + "|" + ;
				(cTab)->E2_FORNECE + "|" + ;
				(cTab)->E2_LOJA

			cQuery := "SELECT " + CRLF 
			cQuery += "    F4C_BNKORD, " + CRLF 
			cQuery += "    F4C_DTPAYM, " + CRLF 
			cQuery += "    F4C_INTNUM, " + CRLF 
			cQuery += "    F4C_DTTRAN " + CRLF 
			cQuery += "FROM " + CRLF 
			cQuery += "    " + RetSqlName("F5M") + " F5M INNER JOIN " + RetSqlName("F4C") + " F4C ON " + CRLF
			cQuery += "    F5M_IDDOC = F4C_CUUID AND " + CRLF
			cQuery += "    F4C.F4C_FILIAL = '" + xFilial("F4C") + "' AND " + CRLF
			cQuery += "    F4C.D_E_L_E_T_ = ' ' " + CRLF
			cQuery += "WHERE " + CRLF 
			cQuery += "    F5M_FILIAL = '" + xFilial("F5M") + "' AND " + CRLF 
			cQuery += "    F5M_KEY = '" + cSe2Key + "' AND " + CRLF 
			cQuery += "    F5M_ALIAS = 'F4C' AND F5M.D_E_L_E_T_ = ' '"
			cTab2 := MPSysOpenQuery(ChangeQuery(cQuery))
			DbSelectArea((cTab2))
			(cTab2)->(DbGoTop())

			aAdd(aRet, ;
				{(cTab2)->F4C_BNKORD, ;
				DToC(SToD((cTab2)->F4C_DTPAYM)), ;
				(cTab2)->F4C_INTNUM, ;
				DToC(SToD((cTab2)->F4C_DTTRAN)), ;
				(cTab)->E2_PREFIXO, ;
				(cTab)->E2_NUM, ;
				(cTab)->E2_PARCELA, ;
				(cTab)->E2_TIPO, ;
				(cTab)->E2_FORNECE, ;
				(cTab)->E2_LOJA, ;
				(cTab)->A2_NOME, ;
				DToC(SToD((cTab)->E2_EMISSAO)), ;
				DToC(SToD((cTab)->E2_VENCREA)), ;
				(cTab)->E2_VALOR, ;
				(cTab)->E2_SALDO, ;
				(cTab)->E2_TXMOEDA, ;
				(cTab)->E2_CONUNI, ;
				(cTab)->E2_MOEDA, ;
				(cTab)->E2_VLCRUZ, ;
				(cTab)->E2_BASIMP1, ;
				(cTab)->E2_ALQIMP1, ;
				(cTab)->E2_VALIMP1, ;
				.F.})

			(cTab2)->(DbCloseArea())	
			(cTab)->(DbSkip())
		EndDo
		
		(cTab)->(DbCloseArea())
	Else
		// If user closes the questions window, nothing happens.
		lRet := .F.
	EndIf

Return(lRet)

/*/{Protheus.doc} RU09T10003_ReturnHeader
Function that returns the header to select an Outflow Invoice to create an Advances VAT Invoice.
@type Static Function
@author artem.kostin
@project MA3 - Russia
@since 07/11/2023
@return aRet, Array, Returns an array with the fields of the SE2 screen's header
/*/
Static Function RU09T10003_ReturnHeader() As Array

	Local aRet As Array
	Local aArea As Array
	Local aAreaSX3 As Array
	Local aCampos As Array
	Local nI As Numeric

	aRet := {}
	aArea := GetArea()
	aAreaSX3 := SX3->(GetArea())
	aCampos := {}

	aAdd(aCampos, "F4C_BNKORD")
	aAdd(aCampos, "F4C_DTPAYM")
	aAdd(aCampos, "F4C_INTNUM")
	aAdd(aCampos, "F4C_DTTRAN")
	aAdd(aCampos, "E2_PREFIXO")
	aAdd(aCampos, "E2_NUM")
	aAdd(aCampos, "E2_PARCELA")
	aAdd(aCampos, "E2_TIPO")
	aAdd(aCampos, "E2_FORNECE")
	aAdd(aCampos, "E2_LOJA")
	aAdd(aCampos, "A2_NOME")
	aAdd(aCampos, "E2_EMISSAO")
	aAdd(aCampos, "E2_VENCREA")
	aAdd(aCampos, "E2_VALOR")
	aAdd(aCampos, "E2_SALDO")
	aAdd(aCampos, "E2_TXMOEDA")
	aAdd(aCampos, "E2_CONUNI")
	aAdd(aCampos, "E2_MOEDA")
	aAdd(aCampos, "E2_VLCRUZ")
	aAdd(aCampos, "E2_BASIMP1")
	aAdd(aCampos, "E2_ALQIMP1")
	aAdd(aCampos, "E2_VALIMP1")

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nI := 1 To Len(aCampos)
		If (SX3->(DbSeek(aCampos[nI])))
			aAdd(aRet, {AllTrim(X3Titulo()), ;
				SX3->X3_CAMPO, ;
				SX3->X3_PICTURE, ;
				SX3->X3_TAMANHO, ;
				SX3->X3_DECIMAL, ;
				SX3->X3_VALID, ;
				, ;
				SX3->X3_TIPO, , })
		EndIf
	Next nI

	RestArea(aAreaSX3)
	RestArea(aArea)

Return(aRet)

/*/{Protheus.doc} RU09T10004_CheckLote
Checks if there is at least one line in F38, that contains a product, having 'L' in SB1.b1_rastro used for LOT control (see ViewDef)
	Has two branches: 
	(1) for operations Edit, Delete, View takes F38_ITMCOD lines from database in query 
	(2) for operation Insert takes F38_ITMCOD lines from model F38details and then makes query on SB1t10
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 10/11/2023
@return lHide, Logical, Defines if shows or hide the item
/*/
Static Function RU09T10004_CheckLote() As Logical

	Local cQuery As Character 
	Local cTab As Character
	Local lHide As Logical 
	Local oModel As Object // active model if exists - when INSERT operation
	Local oModelF38 As Object // model grid F38detail - when INSERT operation
	Local cVATKey As Character
	Local cICod As Character // string <'product1','product2',..,'productN> made from F38_ITMCOD field - when INSERT operation
	Local nX As Numeric 

	lHide  := .F.
	cQuery := ""
	cICod  := ""

	// When come to this function from INSERT operation - take data from Model
	If (ValType(oModel) == "O") .and. (oModel:getId() == "RU09T10")
		oModelF38 := oModel:GetModel("F38detail")
		For nX := 1 To oModelF38:Length()
				oModelF38:GoLine(nX)
				If !Empty(oModelF38:GetValue("F38_ITMCOD"))
					cICod += "'" + oModelF38:GetValue("F38_ITMCOD") + "',"
				EndIf
		Next nX

		If !Empty(cICod)
			cICod := Left(cICod, Len(cICod) - 1)
		EndIf

		cQuery := "SELECT " + CRLF
		cQuery += "    COUNT(*) COUNT1 " + CRLF
		cQuery += "FROM " + RetSqLName("SB1") + " SB1 " + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "    SB1.B1_FILIAL = " + "'" + xFilial("SB1") + "' AND " + CRLF
		If !Empty(cICod)
			cQuery += "    SB1.B1_COD IN (" + cICod + ") AND " + CRLF
		EndIf
		cQuery += "    SB1.D_E_L_E_T_ = ' ' AND " + CRLF
		cQuery += "    SB1.B1_RASTRO = 'L'" 
	Else // When come to this function from EDIT/VIEW/DELETE operation - take data from table F38
		cVATKey := F37->F37_KEY
		cQuery := "SELECT " + CRLF 
		cQuery += "    COUNT(*) COUNT1 " + CRLF
		cQuery += "FROM " + RetSQLName("F38") + " F38 INNER JOIN " + RetSQLName("SB1") + " SB1 ON " + CRLF
		cQuery += "    (SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND " + CRLF
		cQuery += "    F38.F38_ITMCOD = SB1.B1_COD AND " + CRLF
		cQuery += "    SB1.D_E_L_E_T_ = ' ' AND " + CRLF
		cQuery += "    SB1.B1_RASTRO = 'L') " + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "    F38.F38_FILIAL = " + "'" + xFilial("F38") + "' AND " + CRLF
		If !Empty(cVATKey)
			cQuery += "    F38.F38_KEY = " + "'" + cVATKey + "' AND " + CRLF
		EndIf
		cQuery += "    F38.D_E_L_E_T_ = ' '"
	EndIf
	cTab := MPSysOpenQuery(ChangeQuery(cQuery))

	// If the quantity of lines having 'L' in b1_rastro equals zero.
	If ((cTab)->COUNT1 == 0) 
		lHide := .T.
	EndIf
	CloseTempTable(cTab)

Return(lHide)

/*/{Protheus.doc} RU09T10005_PreValidF37
Prevalidation function for the fields of master model F37.
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 07/11/2023
@param oModelF37, Object,  Active model
@param cAction,   Character, The action that is being performed
@param cField,    Character, The field that is being validated
@param xValue,    Variant,   Value of the field that is being validated
@return lRet,     Logical,   If the routine runs ok
/*/
Static Function RU09T10005_PreValidF37(oModelF37 as Object, cAction as Character, cField as Character, xValue As Variant) As Logical

	Local lRet As Logical 
	
	lRet := .T.

	// If user changes Inclusion Date.
	If ((cAction == "SETVALUE") .And. (cField == "F37_RDATE"))
		If (xValue /*F37_RDATE*/ < oModelF37:GetValue("F37_PDATE"))
			lRet := .F.
			Help("", 1, "RU09T1000501",, STR0015, 1, 0) // "The VAT Invoice's Inclusion Date cannot be earlier than the Print Date"
		EndIf
	EndIf

Return(lRet)

/*/{Protheus.doc} RU09T10006_ViewAdvances
Open View of checked Advances Paid
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 10/11/2023
@param oModel, Object, Active model
/*/
Static Function RU09T10006_ViewAdvances(oModel As Object)

	// Working areas
	Local aArea As Array
	Local aAreaSE2 As Array
	// Model objects
	Local oModelSE2 As Object
	// Keys for dbSeek()
	Local cKeySE2 As Character

	// Overwriting existing buttons.
	Private aRotina As Array

	Default oModel := FWLoadModel("RU09T10")

	aRotina	:= {{"", "", 0, 2, 0, Nil}, ;
		{"", "", 0, 2, 0, Nil}, ;
		{"", "", 0, 2, 0, Nil}, ;
		{"", "", 0, 2, 0, Nil}}

	aArea := GetArea()
	aAreaSE2 := SE2->(GetArea())

	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))

	oModelSE2 := oModel:GetModel("SE2detail")
	cKeySE2 := xFilial("SE2") + ;
		oModelSE2:GetValue("E2_PREFIXO") + ;
		oModelSE2:GetValue("E2_NUM") + ;
		oModelSE2:GetValue("E2_PARCELA") + ;
		oModelSE2:GetValue("E2_TIPO") + ;
		oModelSE2:GetValue("E2_FORNECE") + ;
		oModelSE2:GetValue("E2_LOJA")

	If SE2->(DbSeek(cKeySE2))
		RU09T10007(cKeySE2) //open View of SE2
	EndIf

	RestArea(aAreaSE2)
	RestArea(aArea)

Return()

/*/{Protheus.doc} RU09T10007_ViewBillDetails
Option to see details of Bill
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 10/11/2023
@param cSe2Key, Character, The key of SE2 table
/*/
Function RU09T10007_ViewBillDetails(cSe2Key As Character)

	Private cCadastro As Character

	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))
	If SE2->(DbSeek(cSe2Key))
		cCadastro := STR0022 // "Accounts Payable"
		AxVisual("SE2", SE2->(RecNo()), 2,, 4, SA2->A2_NOME, "FA050MCPOS", FA050BAR('SE2->E2_PROJPMS == "1"'))
	EndIf
	SE2->(DbCloseArea())

Return()

/*/{Protheus.doc} RU09T10008_FillFieldsAtInclusion
Function that fills automatically the fields at the moment of inclusion.
@type Static Function
@author artem.kostin
@project MA3 - Russia
@since 03/05/2017
@param oModel,    Object,    Active model
@param oData,     Object,    Active GetDados
@param aHeader,   Array,     Active aHeader
@param cSupplier, Character, The Supplier of the selected bill
@param cBranch,   Character, The Supplier's branch of the selected bill
@return oModel,   Object,    Active model
/*/
Function RU09T10008_FillFieldsAtInclusion(oModel As Object, oData As Object, aHeader As Array, cSupplier As Character, cBranch As Character) As Object

	Local lRet       As Logical
	// Working areas
	Local aArea      As Array
	Local aAreaSE2   As Array
	Local aAreaSA2   As Array
	Local aAreaF31   As Array
	// Positioning of user's selection.
	Local nPosPre    As Numeric
	Local nPosNum    As Numeric
	Local nPosSup    As Numeric
	Local nPosBra    As Numeric
	Local nLinha     As Numeric
	// Submodels 
	Local oModelF37  As Object
	Local oModelF38  As Object
	Local oModelSE2  As Object
	// Holds CanInsertLine property.
	Local lCanInsLin As Logical
	// Internal VAT key
	Local cVATKey    As Character
	// Character variables for the filter.
	Local cFil       As Character
	Local cNum       As Character
	Local cSup       As Character
	Local cBra       As Character
	// Variables for SQL requests.
	Local cQuery     As Character
	Local cTabSE2    As Character
	Local lConUni    As Logical
	Local cKey       As Character
	Local cDescLC    As Character
	Local cCName     As Character
	Local cF5MKey    As Character

	lRet := .T.
	aArea := GetArea()
	aAreaSE2 := SE2->(GetArea())
	aAreaSA2 := SA2->(GetArea())
	aAreaF31 := F31->(GetArea())
	cDescLC := ""
	cCName  := ""
	cF5MKey := ""

	If IsInCallStack("RU06D07RUS") .OR. IsInCallStack("FINA050")
		cFil := xFilial("SE2")
		cNum := SE2->E2_NUM
		cPre := SE2->E2_PREFIXO
		cSup := SE2->E2_FORNECE
		cBra := SE2->E2_LOJA
	Else
		nPosNum	:= aScan(aHeader, {|x| AllTrim(x[2]) == "E2_NUM"})
		nPosPre := aScan(aHeader, {|x| AllTrim(x[2]) == "E2_PREFIXO"})
		nPosSup := aScan(aHeader, {|x| AllTrim(x[2]) == "E2_FORNECE"}) 
		nPosBra := aScan(aHeader, {|x| AllTrim(x[2]) == "E2_LOJA"})
		nLinha  := oData:nAt

		cFil := xFilial("SE2")
		cNum := oData:aCols[nLinha][nPosNum]
		cPre := oData:aCols[nLinha][nPosPre]
		cSup := oData:aCols[nLinha][nPosSup]
		cBra := oData:aCols[nLinha][nPosBra]
	EndIf

	// Selects a particular Inflow Invoice using a context chosen by user.
	cQuery := "SELECT " + CRLF
	cQuery += "    * " + CRLF
	cQuery += "FROM " + RetSQLName("SE2") + " " + CRLF
	cQuery += "WHERE " + CRLF 
	cQuery += "    E2_FILIAL = '" + cFil + "' AND " + CRLF
	cQuery += "    E2_NUM = '" + cNum + "' AND " + CRLF
	cQuery += "    E2_PREFIXO = '" + cPre + "' AND " + CRLF
	cQuery += "    E2_FORNECE = '" + cSup + "' AND " + CRLF
	cQuery += "    E2_LOJA = '" + cBra + "' AND " + CRLF
	cQuery += "    D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY " + CRLF 
	cQuery += "    E2_FILIAL, " + CRLF
	cQuery += "    E2_NUM, " + CRLF
	cQuery += "    E2_PREFIXO, " + CRLF
	cQuery += "    E2_FORNECE, " + CRLF
	cQuery += "    E2_LOJA"
	cTabSE2 := MPSysOpenQuery(ChangeQuery(cQuery))

	DbSelectArea("F31")
	F31->(DbSetOrder(1))

	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2") + cSupplier + cBranch))

	// If at least one Inflow Invoice is returned by select (and should be only one).
	If (!(cTabSE2)->(Eof()))
		oModelF37 := oModel:GetModel("F37master")
		oModelF38 := oModel:GetModel("F38detail")
		oModelSE2 := oModel:GetModel("SE2detail")
		
		cVATKey := RU09T10015()
		While !MayIUseCode("RU09T10" + cVATKey)
			cVATKey := Soma1(cVATKey)
		EndDo

		// Check if the bill is in conventional units
		lConUni := IIf((cTabSE2)->E2_CONUNI == "1", .T., .F.)

		// Stores the F37 key 
		cKey := FwFldGet("F37_KEY")

		lRet := lRet .And. oModelF37:LoadValue("F37_FILIAL", xFilial("F37")) // Filial
		lRet := lRet .And. oModelF37:LoadValue("F37_ORIGIN", "2")	// Purchases Commercial Invoice
		lRet := lRet .And. oModelF37:LoadValue("F37_TYPE",   "3")	// Purchases VAT Invoice
		lRet := lRet .And. oModelF37:LoadValue("F37_CONUNI", (cTabSE2)->E2_CONUNI) // Conventional Units
		lRet := lRet .And. oModelF37:LoadValue("F37_INVCUR", IIf(lConUni, AllTrim(Str((cTabSE2)->E2_MOEDA)), "01")) // Commercial Invoice Currency
		lRet := lRet .And. oModelF37:LoadValue("F37_C_RATE", (cTabSE2)->E2_TXMOEDA)	// Unique Internal Key
		
		lRet := lRet .And. oModelF37:LoadValue("F37_FORNEC", (cTabSE2)->E2_FORNECE)	// Supplier
		lRet := lRet .And. oModelF37:LoadValue("F37_BRANCH", (cTabSE2)->E2_LOJA) // Supplier Branch
		lRet := lRet .And. oModelF37:LoadValue("F37_KPP_SP", SA2->A2_KPP)	// Supplier KPP
		lRet := lRet .And. oModelF37:LoadValue("F37_KPP_CO", GetCoBrRUS()[2][5][2]) // Branch KPP
		lRet := lRet .And. oModelF37:LoadValue("F37_CONTRA", (cTabSE2)->E2_F5QCODE) // Legal Contract Code

		RU09T10020(FwFldGet("F37_CONTRA"), @cDescLC, @cCName)		  //Legal Contract Info

		lRet := lRet .And. oModelF37:LoadValue("F37_F5QDES", cDescLC) //Legal Contracts Description
		lRet := lRet .And. oModelF37:LoadValue("F37_KEY",    cVATKey)	// Unique Internal Key
		lRet := lRet .And. oModelF37:LoadValue("F37_VATCD2", RU09T10010(cFil, cKey))	// External VAT Codes       
		lRet := lRet .And. oModelF37:LoadValue("F37_CNRVEN", "1")	// Consignor
		lRet := lRet .And. oModelF37:LoadValue("F37_CNECLI", "1")	// Consignee
		lRet := lRet .And. oModelF37:LoadValue("F37_VATBS",  RU09T10011("F38_VATBS",  cFil, cKey)) // VAT Base    
		lRet := lRet .And. oModelF37:LoadValue("F37_VALGR",  IIf(lConUni, (cTabSE2)->E2_VLCRUZ, (cTabSE2)->E2_VALOR)) // Gross Total 
		lRet := lRet .And. oModelF37:LoadValue("F37_VATVL",  RU09T10011("F38_VATVL",  cFil, cKey)) // VAT Value   
		lRet := lRet .And. oModelF37:LoadValue("F37_VATBS1", RU09T10011("F38_VATBS1", cFil, cKey)) // VAT Bs C1   
		lRet := lRet .And. oModelF37:LoadValue("F37_VATVL1", RU09T10011("F38_VATVL1", cFil, cKey)) // VAT Vl C1   
		lRet := lRet .And. oModelF37:LoadValue("F37_VALUE",  IIf(lConUni, (cTabSE2)->E2_VLCRUZ, (cTabSE2)->E2_VALOR)) // Total Value 
		lRet := lRet .And. oModelF37:LoadValue("F37_TDATE",  SToD((cTabSE2)->E2_EMISSAO)) // Input Date
		lRet := lRet .And. oModelF37:LoadValue("F37_PDATE",  SToD((cTabSE2)->E2_EMISSAO)) // Print Date
		lRet := lRet .And. oModelF37:LoadValue("F37_ATBOOK", "1") // Aut. Book?  
		lRet := lRet .And. oModelF37:LoadValue("F37_ITDATE", SToD((cTabSE2)->E2_EMISSAO))	// Commercial Type Issue Date
		lRet := lRet .And. oModelF37:LoadValue("F37_RDATE",  SToD((cTabSE2)->E2_EMISSAO))	// Real Inclusion Date
		lRet := lRet .And. oModelF37:LoadValue("F37_PREFIX", (cTabSE2)->E2_PREFIXO) // Bill Prefix
		lRet := lRet .And. oModelF37:LoadValue("F37_NUM",    (cTabSE2)->E2_NUM)     // Bill Number
		lRet := lRet .And. oModelF37:LoadValue("F37_PARCEL", (cTabSE2)->E2_PARCELA) // Bill Amendment
		lRet := lRet .And. oModelF37:LoadValue("F37_TIPO",   (cTabSE2)->E2_TIPO)    // Bill Type
		cF5MKey := PADR(xFilial("F37"),        TamSX3("F37_FILIAL")[1]) + "|"
        cF5MKey += PADR((cTabSE2)->E2_PREFIXO, TamSX3("F37_PREFIX")[1]) + "|"
        cF5MKey += PADR((cTabSE2)->E2_NUM,     TamSX3("F37_NUM")[1])    + "|"
        cF5MKey += PADR((cTabSE2)->E2_PARCELA, TamSX3("F37_PARCEL")[1]) + "|"
        cF5MKey += PADR((cTabSE2)->E2_TIPO,    TamSX3("F37_TIPO")[1])   + "|"
        cF5MKey += PADR((cTabSE2)->E2_FORNECE, TamSX3("F37_FORNEC")[1]) + "|"
        cF5MKey += PADR((cTabSE2)->E2_LOJA,    TamSX3("F37_BRANCH")[1])

		lRet := lRet .And. oModelF37:LoadValue("F37_PAYM",  RU09T10009(cF5MKey))	// Payment Document
		If !lRet
			Help("", 1, "RU09T10008_FillFieldsAtInclusion01",, STR0014, 1, 0) // "The field is not loaded into the model"
		EndIf

		// Iterates all over the details returned by select.
		lCanInsLin := oModel:GetModel("F38detail"):CanInsertLine()
		oModel:GetModel("F38detail"):SetNoInsertLine(.F.)

		lRet := lRet .And. oModelF38:LoadValue("F38_ITDATE", SToD((cTabSE2)->E2_EMISSAO))	
		lRet := lRet .And. oModelF38:LoadValue("F38_ITEM",   "1")
		cVatCod := RU09T10012((cTabSE2)->E2_F5QUID, AllTrim(Str((cTabSE2)->E2_ALQIMP1)))
		lRet := lRet .And. oModelF38:SetValue("F38_VATCOD", cVatCod)
		If !Empty(FwFldGet("F37_CONTRA"))
			lRet := lRet .And. oModelF38:LoadValue("F38_DESC", cCName)
		EndIf
		lRet := lRet .And. oModelF38:SetValue("F38_VALUE",   IIf(lConUni, (cTabSE2)->E2_VLCRUZ, (cTabSE2)->E2_VALOR)) // Total Value
		lRet := lRet .And. oModelF38:LoadValue("F38_DOCKEY", (cTabSE2)->(E2_FILIAL + E2_NUM + E2_PREFIXO + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA))
		lRet := lRet .And. oModelF38:LoadValue("F38_VATCD2", Posicione("F31", 1, xFilial("F31") + cVatCod, "F31_OPCODE")) // Ext. VAT Cd.
		lRet := lRet .And. oModelF38:LoadValue("F38_ORIGGR", (cTabSE2)->E2_VALOR) // VAT Base
		oModel:GetModel("F38detail"):SetNoInsertLine(!lCanInsLin)
		If !lRet
			Help("", 1, "RU09T10008_FillFieldsAtInclusion02",, STR0014, 1, 0) // "The field is not loaded into the model"
		EndIf

		// Autofill Bill fields
		lRet := lRet .And. oModelSE2:LoadValue("E2_PREFIXO", (cTabSE2)->E2_PREFIXO)       // Prefix
		lRet := lRet .And. oModelSE2:LoadValue("E2_NUM",     (cTabSE2)->E2_NUM)           // Number
		lRet := lRet .And. oModelSE2:LoadValue("E2_PARCELA", (cTabSE2)->E2_PARCELA)       // Installment
		lRet := lRet .And. oModelSE2:LoadValue("E2_TIPO",    (cTabSE2)->E2_TIPO)          // Type
		lRet := lRet .And. oModelSE2:LoadValue("E2_FORNECE", (cTabSE2)->E2_FORNECE)       // Supplier
		lRet := lRet .And. oModelSE2:LoadValue("E2_LOJA",    (cTabSE2)->E2_LOJA)          // Branch
		lRet := lRet .And. oModelSE2:LoadValue("E2_EMISSAO", SToD((cTabSE2)->E2_EMISSAO)) // Issue Date
		lRet := lRet .And. oModelSE2:LoadValue("E2_VENCREA", SToD((cTabSE2)->E2_VENCREA)) // Due Date
		lRet := lRet .And. oModelSE2:LoadValue("E2_VALOR",   (cTabSE2)->E2_VALOR)         // Value
		lRet := lRet .And. oModelSE2:LoadValue("E2_SALDO",   (cTabSE2)->E2_SALDO)         // Balance
		lRet := lRet .And. oModelSE2:LoadValue("E2_TXMOEDA", (cTabSE2)->E2_TXMOEDA)       // Exch. Rate  
		lRet := lRet .And. oModelSE2:LoadValue("E2_MOEDA",   (cTabSE2)->E2_MOEDA)   	  // Currency    
		lRet := lRet .And. oModelSE2:LoadValue("E2_VLCRUZ",  (cTabSE2)->E2_VLCRUZ)        // Value in local currency
		lRet := lRet .And. oModelSE2:LoadValue("E2_BASIMP1", (cTabSE2)->E2_BASIMP1)       // Tax 1 Base    
		lRet := lRet .And. oModelSE2:LoadValue("E2_ALQIMP1", (cTabSE2)->E2_ALQIMP1)   	  // Tax 1 Rate      
		lRet := lRet .And. oModelSE2:LoadValue("E2_VALIMP1", (cTabSE2)->E2_VALIMP1)       // Tax 1 Amount

		If !lRet
			Help("", 1, "RU09T10008_FillFieldsAtInclusion03",, STR0014, 1, 0) // "The field is not loaded into the model"
		EndIf
	Else
		Help("", 1, "RU09T10008_FillFieldsAtInclusion03",, STR0008, 1, 0) // "No bills found"
	EndIf

	CloseTempTable(cTabSE2)

	RestArea(aAreaF31)
	RestArea(aAreaSA2)
	RestArea(aAreaSE2)
	RestArea(aArea)

Return(oModel)

/*/{Protheus.doc} RU09T10009_GetPaymentDocAndDate
Function that gets the Payment Doc and Date
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 10/11/2023
@param  cF5MKey, Character,  xFilial("F37")+"|"+F37->F37_PREFIX+"|"+F37->F37_NUM+"|"+F37->F37_PARCEL+"|"+F37->F37_TIPO+"|"+F37->F37_FORNEC+"|"+F37->F37_BRANCH
@return cRet, Character, Payment Doc and Date of the BS (if exists)
/*/
Static Function RU09T10009_GetPaymentDocAndDate(cF5MKey As Character) As Character

	Local cRet    As Character
	Local cQuery  As Character
	Local cTabF4C As Character

	cRet := ""

	// Check if we have a BS associated and returns Date and Bankord
	cQuery := " SELECT F4C_DTPAYM, F4C_BNKORD "
											
										   
	cQuery += " FROM " + RetSQLName("F4C") + " F4C "
	cQuery += " INNER JOIN " + RetSQLName("F5M") 
						   
	cQuery += " F5M ON (F5M_IDDOC=F4C_CUUID and F5M_FILIAL = '" + xFILIAL("F5M") + "') "
	cQuery += " WHERE F4C.D_E_L_E_T_ =' ' AND F5M.D_E_L_E_T_=' '"
	cQuery += " AND F5M_KEY like '" + cF5MKey + "%' and F5M_ALIAS='F4C' "
	cTabF4C := MPSysOpenQuery(ChangeQuery(cQuery))
	If !(cTabF4C)->(Eof())
		cRet :=  DToC(StoD((cTabF4C)->F4C_DTPAYM)) + " " + AllTrim((cTabF4C)->F4C_BNKORD)
	EndIf
	(cTabF4C)->(DbCloseArea())	

Return(cRet)

/*/{Protheus.doc} RU09T10010_Getf38VatCodes
Function that gets the VAT Codes of the Comercial Invoice
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 10/11/2023
@param  cFil,    Character, Branch of the F37 selected register
@param  cKey,    Character, Key of the F37 selected register
@return cVatCds, Character, List of all Vat Codes of the selected F38 registers
/*/
Static Function RU09T10010_Getf38VatCodes(cFil As Character, cKey As Character) As Character

	Local cVatCds As Character
	Local cTabF38  As Character
	Local cQuery   As Character

	cVatCds := ""

	// Search for all different Vat Codes in F38 table
	cQuery := "SELECT DISTINCT " + CRLF  
	cQuery += "    F38_VATCD2 VATCD2 " + CRLF 
	cQuery += "FROM " + CRLF 
	cQuery += "    " + RetSqlName("F38") + " F38 " + CRLF 
	cQuery += "WHERE " + CRLF 
	cQuery += "    F38_FILIAL = '" + cFil + "' AND " + CRLF  
	cQuery += "    F38_KEY = '" + cKey + "' AND " + CRLF  
	cQuery += "    D_E_L_E_T_  = ' '"
	cTabF38 := MPSysOpenQuery(ChangeQuery(cQuery))
	While !(cTabF38)->(Eof())
		cVatCds += Alltrim((cTabF38)->VATCD2) + ";"
	EndDo
	(cTabF38)->(DbCloseArea())	

	cVatCds := SubStr(cVatCds, 1, Len(cVatCds) - 1)

Return(cVatCds)

/*/{Protheus.doc} RU09T10011_GetF38Sums
Function that gets the sum of various F38 fields
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 10/11/2023
@param  cField, Character, Fields to be totalized
@param  cFil,   Character, Branch of the F37 selected register
@param  cKey,   Character, Key of the F37 selected register
@return nSum,   Numeric,   Sum of the F38 fields
/*/
Static Function RU09T10011_GetF38Sums(cField As Character, cFil As Character, cKey As Character) As Numeric

	Local nSum    As Numeric
	Local cQuery  As Character
	Local cTabF38 As Character

	nSum := 0

	// Check the total of F38 lines
	cQuery := "SELECT " + CRLF  
	cQuery += "    SUM(" + cField + ") F38FIELD " + CRLF 
	cQuery += "FROM " + CRLF 
	cQuery += "    " + RetSqlName("F38") + " F38 " + CRLF 
	cQuery += "WHERE " + CRLF 
	cQuery += "    F38_FILIAL = '" + cFil + "' AND " + CRLF  
	cQuery += "    F38_KEY = '" + cKey + "' AND " + CRLF  
	cQuery += "    D_E_L_E_T_  = ' '"
	cTabF38 := MPSysOpenQuery(ChangeQuery(cQuery))
	If !(cTabF38)->(Eof())
		nSum := (cTabF38)->F38FIELD
	EndIf
	(cTabF38)->(DbCloseArea())	

Return(nSum)

/*/{Protheus.doc} RU09T10012_ReturnF38VatCodData
Function that returns the F38 VatCode information
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 10/11/2023
@param  cUid,    Character, Uid code of the bill
@param  cE2TaxR, Character, Tax rate of the bill
@return cVatCod, Character, Vat code
/*/
Static Function RU09T10012_ReturnF38VatCodData(cUid As Character, cE2TaxR As Character) As Character

	Local lRet As Logical
	Local cQuery As Character
	Local cTabF5R As Character
	Local cTabF31 As Character
	Local cVatCod As Character

	lRet := .F.

	// Check if we have a legal contract associated
	cQuery := "SELECT " + CRLF  
	cQuery += "    F5R_VATCOD VATCOD " + CRLF 
	cQuery += "FROM " + CRLF 
	cQuery += "    " + RetSqlName("F5R") + " F5R " + CRLF 
	cQuery += "WHERE " + CRLF 
	cQuery += "    F5R_UID = '" + cUid + "' AND " + CRLF  
	cQuery += "    D_E_L_E_T_  = ' '"
	cTabF5R := MPSysOpenQuery(ChangeQuery(cQuery))
	If !(cTabF5R)->(Eof())
		If Empty((cTabF5R)->F5R_VATCOD)
			lRet := .T.
		Else
			cVatCod := (cTabF5R)->VATCOD
		EndIf
	Else
		lRet := .T.
	EndIf
	(cTabF5R)->(DbCloseArea())	

	// If there's no Legal Contract or the the F5R_VATCOD is empty, we must check the F30 table
	If lRet
		cQuery := "SELECT " + CRLF 
		cQuery += "    F31_CODE CODE " + CRLF
		cQuery += "FROM " + CRLF
		cQuery += "    " + RetSqlName("F31") + " F31, " + CRLF
		cQuery += "    " + RetSqlName("F30") + " F30 " + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "    F31_RATE = F30_CODE AND " + CRLF
		cQuery += "    SUBSTRING(F30.F30_RATE , 1, 2) = '" + cE2TaxR + "' AND " + CRLF 
		cQuery += "    F31.F31_RV_COD <> ' ' AND " + CRLF
		cQuery += "    F30_RATE LIKE '%/%' AND " + CRLF
		cQuery += "    F30.D_E_L_E_T_ = ' ' AND " + CRLF
		cQuery += "    F31.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "ORDER BY 1"
		cTabF31 := MPSysOpenQuery(ChangeQuery(cQuery))
		If !(cTabF31)->(Eof())
			cVatCod := (cTabF31)->CODE
		Else
			cVatCod := ""
		EndIf
		(cTabF31)->(DbCloseArea())	
	EndIf

Return(cVatCod)

/*/{Protheus.doc} RU09T10013_UpdateTotalFields
Function that updates the total fields
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 20/02/2024
@param  oModelIt, Object, active itens model
@return Nil
/*/
Function RU09T10013_UpdateTotalFields(oModelIt As Object) As Logical

	Local oView  := Nil As Object
	Local oModel := Nil As Object
	Local nVatBs := 0 As Numeric
	Local nVatGr := 0 As Numeric
	Local nVatVl := 0 As Numeric
	Local nVatB1 := 0 As Numeric
	Local nVatV1 := 0 As Numeric
	Local nValue := 0 As Numeric
	Local nLine		  As Numeric
	Local nLCtx  	  As Numeric
		
	Default oModelIt := Nil

	If oModelIt == Nil
		Return(.T.)
	EndIf

	If oModelIt:GetOperation() == MODEL_OPERATION_VIEW .Or. oModelIt:GetOperation() == MODEL_OPERATION_DELETE 
		Return(.T.)
	EndIf

	nVatBs := 0.0
	nVatGr := 0.0
	nVatVl := 0.0
	nVatB1 := 0.0
	nVatV1 := 0.0
	nValue := 0.0

	If oModelIt:GetId() == "F38detail"
		oView := FWViewActive()
		nLCtx := oModelIt:GetLine()					// store line context

		For nLine := 1 To oModelIt:Length()
			oModelIt:GoLine(nLine)
			nVatBs := FwFldGet("F38_VATBS")
			nVatGr := FwFldGet("F38_VALGR")
			nVatVl := FwFldGet("F38_VATVL")
			nVatB1 := FwFldGet("F38_VATBS1")
			nVatV1 := FwFldGet("F38_VATVL1")
			nValue := FwFldGet("F38_VALUE")
		Next nLine	

		oModelIt:SetLine(nLCtx)					// restore line context
		oModel := FwModelActive()
		oModel:GetModel("F37master"):LoadValue("F37_VATBS",  nVatBs) // VAT Base
		oModel:GetModel("F37master"):LoadValue("F37_VALGR",  nVatGr) // Gross Total 
		oModel:GetModel("F37master"):LoadValue("F37_VATVL",  nVatVl) // VAT Value   
		oModel:GetModel("F37master"):LoadValue("F37_VATBS1", nVatB1) // VAT Bs C1   
		oModel:GetModel("F37master"):LoadValue("F37_VATVL1", nVatV1) // VAT Vl C1   
		oModel:GetModel("F37master"):LoadValue("F37_VALUE",  nValue) // Total Value 

		If ValType(oView) == "O"
			oView:Refresh("VIEW_F37T")
		EndIf
	Else
		oView := FWViewActive()
		nLCtx := oModelIt:GetLine()					// store line context
	
		For nLine := 1 To oModelIt:Length()
			oModelIt:GoLine(nLine)
			nVatBs += oModelIt:GetValue("F36_VATBS")
			nVatGr += oModelIt:GetValue("F36_VALGR")
			nVatVl += oModelIt:GetValue("F36_VATVL")
			nVatB1 += oModelIt:GetValue("F36_VATBS1")
			nVatV1 += oModelIt:GetValue("F36_VATVL1")
			nValue += oModelIt:GetValue("F36_VALUE")
		Next nLine

		oModelIt:SetLine(nLCtx)					// restore line context
		oModel := FwModelActive()
		oModel:GetModel("F35MASTER"):LoadValue("F35_VATBS",  nVatBs) // VAT Base
		oModel:GetModel("F35MASTER"):LoadValue("F35_VALGR",  nVatGr) // Gross Total 
		oModel:GetModel("F35MASTER"):LoadValue("F35_VATVL",  nVatVl) // VAT Value   
		oModel:GetModel("F35MASTER"):LoadValue("F35_VATBS1", nVatB1) // VAT Bs C1   
		oModel:GetModel("F35MASTER"):LoadValue("F35_VATVL1", nVatV1) // VAT Vl C1   
		oModel:GetModel("F35MASTER"):LoadValue("F35_VALUE",  nValue) // Total Value 

		If ValType(oView) == "O"
			oView:Refresh("VIEW_F35T")
		EndIf
	EndIf

Return(.T.)

/*/{Protheus.doc} RU09T10014_GetVersion
Function Responsible to set the version of the to be shown filtered
@type  Static Function
@author eduardo.Flima
@project MA3 - Russia
@since 16/11/2023
@param cParPerg,  Character, Paramenters of fte pergunter in the following order : name_Of_Perguntye | Item of the pergunte
@return nVersion, Numeric,   Version Choosed 1- Simplified 2-Complete
/*/
Static Function RU09T10014_GetVersion(cParPerg As Character)

	Local aParams  As Array
	Local nVersion As Numeric

	nVersion := 1 // by defalt we will show simplified version

	If !Empty(cParPerg)
		aParams := Separa(cParPerg, "|")
		Pergunte(aParams[1], .F.)
		if ValType(&(aParams[2])) == 'N'
			nVersion := &(aParams[2])
		EndIf
	Endif 

Return(nVersion)

/*/{Protheus.doc} RU09T10015_GetLastVATKey
Function that returns the last value from the field F37_KEY.
@type  Static Function
@author artem.kostin
@project MA3 - Russia
@since 10/05/2017
@return nVersion, Numeric, Version Choosed 1- Simplified 2-Complete
/*/
Static Function RU09T10015_GetLastVATKey()

	Local cQuery As Character
	Local cTab As Character
	Local cRet As Character
	Local cProx As Character
	Local aArea As Array

	aArea := GetArea()

	cQuery := "SELECT " + CRLF
	cQuery += "    COALESCE(MAX(F37_KEY), '0') AS F37_KEY " + CRLF
	cQuery += "FROM " + RetSQLName("F37") + " T0 " + CRLF
	cQuery += "WHERE " + CRLF 
	cQuery += "	   T0.F37_FILIAL = '" + xFilial("F37") + "' AND " + CRLF
	cQuery += "    T0.D_E_L_E_T_ = ' '"
	cTab := MPSysOpenQuery(ChangeQuery(cQuery))

	DbSelectArea((cTab))
	(cTab)->(DbGoTop())

	While ((cTab)->(!Eof()))
		cProx := Soma1(AllTrim((cTab)->F37_KEY))
		cRet := StrZero(Val(cProx), TamSX3("F38_KEY")[1])
		
		(cTab)->(DbSkip())
	EndDo

	(cTab)->(DbCloseArea())

	RestArea(aArea) 

Return(cRet)

/*/{Protheus.doc} RU09T10016_PostValidF37
Prevalidation function for the fields of master model F37.
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 05/16/2018
@param oModelF37, Object,  F37 table's model
@return lRet,     Logical, If validation is ok
/*/
Static Function RU09T10016_PostValidF37(oModelF37 As Object) As Logical

	Local lRet As Logical 
	
	lRet := .T.

	// Inclusion Date must be earlier than Print Date.
	If (oModelF37:GetValue("F37_RDATE") < oModelF37:GetValue("F37_PDATE"))
		lRet := .F.
		Help("", 1, "RU09T10016_PostValidF3701",, STR0015, 1, 0) // "The VAT Invoice's Inclusion Date cannot be earlier than the Print Date" 
	EndIf

Return(lRet)

/*/{Protheus.doc} RU09T10017_ModelSave
Function that saves the model.
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 15/11/2023
@param oModel, Object,  Model to be saved
@return lRet,  Logical, If saving process is ok
/*/
Static Function RU09T10017_ModelSave(oModel As Object) As Logical

	Local lRet       As Logical
	Local cPerg      As Character
	Local lShowJE    As Logical
	Local lGroupJE   As Logical
	Local lOnlineJE  As Logical
	Local lContin    As Logical
	Local oModelF38  As Object
	Local oModelF37  As Object
	Local nOperation As Numeric
	Local nI         As numeric
	Local nItem      As numeric
	Local cCFExt     As Character
	Local cKey       As Character
	Local aRecBal    As Array		  

	lRet := .T.

	nOperation := oModel:GetOperation()
	cPerg := "RU09T03"
	lContin := .T.

	Pergunte(cPerg, .F.)

	lShowJE := (mv_par01 == 1)
	lGroupJE := (mv_par02 == 1)
	lOnlineJE := (mv_par03 == 1)

	oModelF37 := oModel:GetModel("F37master")
	oModelF38 := oModel:GetModel("F38detail")

	If nOperation == MODEL_OPERATION_INSERT
		cCFExt := ""
		nItem := 1

		For nI := 1 To oModelF38:Length()
			oModelF38:GoLine(nI)
			//Menyashina Alexandra: If we have delete items we should move items
			If !(oModelF38:Isdeleted())
				oModelF38:LoadValue("F38_ITEM", StrZero(nItem, TamSX3("F38_ITEM")[1]))
				nItem++
			EndIf
		Next nI

		For nI := 1 To oModelF38:Length()
			oModelF38:GoLine(nI)
			If !(oModelF38:Isdeleted())
				If !(oModelF38:GetValue("F38_VATCD2") $ cCFExt)
					cCFExt += AllTrim(oModelF38:GetValue("F38_VATCD2")) + ";"
				EndIf			
			EndIf
		Next nI
		If !Empty(cCFExt)
		// Crops last two symbols ", " to prepate string for SQL query.
		cCFExt := SubStr(cCFExt, 1, Len(cCFExt) - 1)
		EndIf
		lRet := lRet .And. oModelF37:LoadValue("F37_VATCD2", cCFExt)	// External VAT Codes
		lRet := lRet .And. oModelF37:LoadValue("F37_ITDATE", oModelF37:getvalue('F37_RDATE'))	
		lRet := lRet .And. oModelF37:LoadValue("F37_TDATE ", oModelF37:getvalue('F37_RDATE'))	
		cKey := RU09T10015()
		While !(MayIUseCode("RU09T10" + cKey))
			cKey := Soma1(cKey)
		EndDo
		FreeUsedCode(.T.)
		lRet := lRet .and. oModelF37:LoadValue("F37_KEY", cKey)
	EndIf

	If nOperation == MODEL_OPERATION_INSERT
		Begin Transaction
			lRet := lRet .And. FWFormCommit(oModel)
			If !lRet
				DisarmTransaction()
			EndIf
		End Transaction

		lRet := lRet .And. RU09D05Add(oModel, @aRecBal) // Adding Inflow VAT Balance
		lRet := lRet .And. RU09D04Add(oModel) 			// Adding Inflow VAT Movements
		lRet := lRet .And. RU09D09001(oModel) 			// Adding Outflow VAT Balance
		
		Begin Transaction
			If lRet .And. oModel:GetModel("F37master"):GetValue("F37_ATBOOK") == "1"
					lRet := lRet .And. RU09T10018(oModel, oModelF37, aRecBal) // Adding Purchase Book
			EndIf

			If lRet .And. oModel:GetModel("F37master"):GetValue("F37_TYPE") == "3" // Payment in Advance
				lRet := lRet .And. RU09D07Add(oModel) // Add Corrective VAT Invoice
			EndIf
				
			// Posting accounting entries.
			// RU09T10019(oModel, .T.)

			If !lRet
				DisarmTransaction()
				Help("", 1, "RU09T10017_ModelSave:01",, STR0944, 1, 0) // "Something went in a wrong way during the Inflow VAT Invoices commit"
			EndIf
		End Transaction

	ElseIf nOperation == MODEL_OPERATION_DELETE
		If lContin
			If oModel:GetModel("F37master"):GetValue("F37_TYPE") == "3" // Payment in Advance
				lRet := lRet .And. RU09D07Del(oModel)
			EndIf
			lRet := lRet .And. RU09D05Del(oModel) // Inflow VAT Balance
			lRet := lRet .And. RU09D04Del(oModel) // Inflow VAT Movements		
			lRet := lRet .And. RU09D09004(oModel) // Outflow VAT Balance
			// Posting accounting entries.
			// RU09T10019(oModel, .F.)
			
			Begin Transaction
				lRet := lRet .And. FWFormCommit(oModel)
				If !lRet
					DisarmTransaction()
					Help("", 1, "RU09T10017_ModelSave:02",, STR0944, 1, 0) // "Something went in a wrong way during the Inflow VAT Invoices commit"
				EndIf
			End Transaction
		EndIf
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		Begin Transaction
			lRet := lRet .And. FWFormCommit(oModel)
			If !lRet
				DisarmTransaction()
			EndIf
		End Transaction

		lRet := lRet .And. RU09D05Edt(oModel)
		lRet := lRet .And. RU09D04Edt(oModel)
		If oModel:GetModel("F37master"):GetValue("F37_TYPE") == "3" // Payment in Advance
			lRet := lRet .And. RU09D07Edt(oModel)
		EndIf

		// Posting accounting entries.
		// RU09T10019(oModel, .F.)

		If !lRet
			Help("", 1, "RU09T10017_ModelSave:03",, STR0944, 1, 0) // "Something went in a wrong way during the Inflow VAT Invoices commit"
		EndIf
	EndIf

Return(lRet)

/*/{Protheus.doc} RU09T10018_SaveInPurchaseBook
Function that saves the Invoice into Purchase Book
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 15/11/2023
@param oModel, Object,  Model to be saved
@return lRet,  Logical, If saving process is ok
/*/
Static Function RU09T10018_SaveInPurchaseBook(oModel As Object, oF37 As Object, aRecBal As Array) As Logical

	Local lRet 			As Logical
	// Model and submodels
	Local oBook     	As Object
	Local oModelF3B 	As Object
	Local oModelF64 	As Object
	Local oModelSE2 	As Object 
	Local nOperation	As Numeric
	Local lCanInsLin As Logical
	Local lCanUpdLin As Logical

	// SQL query and temporary table
	Local cQuery    	As Character
	Local cTab      	As Character
	Local cTabPBook 	As Character
	Local nRecValT 		As Numeric
	Local nLine	   		As Numeric
	Local cRealDate  	As Character
	Local dPrintDate 	As Date
	Local cPrtMonth  	As Character
	Local dFinalDate 	As Date
	Local aArea     	As Array
	Local aAreaF3B  	As Array
	Local aAreaF64  	As Array
	Local cNMBAlias 	As Character
	Local nRecRate   	As Numeric
	Local nUserRate  	As Numeric
	Local cTargCode  	As Character
	Local cCodeType  	As Character							
	Local cVatKey 		As Character
	Local cCdSupp 		As Character
	Local cBrSupp 		As Character
	Local cDoc 			As Character
	Local dRealDt 		As Character
	Local dPrntDt 		As Character
	Local cVATCdI 		As Character
	Local cVATCdE 		As Character
	Local cVATRat 		As Character
	Local nIniBal 		As Numeric
	Local nIniBas 		As Numeric
	Local cTabSE2 		As Character
	Local aF64    		As Array
	Local cPLBook		As Character
	Local aAreaF37		As Array

	aArea       := GetArea()
	aAreaF3B    := F3B->(GetArea())
	aAreaF64    := F64->(GetArea())
	cNMBAlias  := "PUBOOK"
	lRet       := .T.
	nRecValT   := 0
	nLine      := 0
	cQuery     := "" 
	cTab       := ""
	cTabPBook  := ""
	cTabSE2    := ""
	cRealDate  := DToS(oF37:GetValue("F37_RDATE"))
	dPrintDate := oF37:GetValue("F37_PDATE")
	cPrtMonth  := SubStr(DtoS(dPrintDate), 5, 2)
	nLine      := 0
	nRecRate   := 0
	nUserRate  := 100
	cTargCode  := ""
	cCodeType  := ""
	aF64       := {}	
	cPLBook	   := ""

	DbSelectArea("F3B")
	F3B->(DbSetOrder(1))

	DbSelectArea("F64")
	F64->(DbSetOrder(1))

	// Select the book from the database, where Purchase VAT Invoice can be put. 
	cQuery := "SELECT " + CRLF
	cQuery += "    T0.F3B_BOOKEY " + CRLF
	cQuery += "FROM " + RetSQLName("F3B") + " AS T0 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "    T0.F3B_FILIAL = '" + xFilial("F3B") + "' AND " + CRLF
	If (cPrtMonth $ "03|06|09|12") .And. (SToD(cRealDate) <= DaySum(LastDay(dPrintDate), EXTRA_DAYS_AFTER_TAX_PERIOD))
		cQuery += "    T0.F3B_FINAL >= '" + DtoS(dPrintDate) + "' AND " + CRLF
		cQuery += "    T0.F3B_INIT <= '" + DtoS(dPrintDate) + "' AND " + CRLF
	Else
		cQuery += "    T0.F3B_FINAL >= '" + cRealDate + "' AND " + CRLF
	EndIf
	cQuery += "    T0.F3B_INIT <= '" + cRealDate + "' AND " + CRLF
	cQuery += "    T0.F3B_STATUS = '1' AND " + CRLF
	cQuery += "    T0.F3B_AUTO = '1' AND " + CRLF
	cQuery += "    T0.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY T0.F3B_BOOKEY"
	cTabPBook := MPSysOpenQuery(ChangeQuery(cQuery))

	// If query result is not empty == Purchases Book already exists.
	(cTabPBook)->(DBGoTop())
	If !(cTabPBook)->(Eof())
		If F3B->(DbSeek(xFilial("F3B") + (cTabPBook)->F3B_BOOKEY))
			nOperation := MODEL_OPERATION_UPDATE
			cPLBook	   := AllTrim(F3B->F3B_CODE)
		Else
			lRet := .F.
			Help("", 1, "RU09T10018_SaveInPurchaseBook:01",, STR0943, 1, 0)
		EndIf
	Else
		nOperation := MODEL_OPERATION_INSERT
	EndIf
	(cTabPBook)->(DbCloseArea())

	// Loads Purchases Book model.
	oBook := FWLoadModel("RU09T05")
	oBook:SetOperation(nOperation)
	oBook:Activate()

	oModelF3B := oBook:GetModel("F3BMASTER")
	oModelF64 := oBook:GetModel("F64PDETAIL")
	oModelSE2 := oModel:GetModel("SE2detail")

	// If Automatic Book doesn't exist, we will create it.
	If nOperation == MODEL_OPERATION_INSERT
		cPLBook :=  AllTrim(RU09D03NMB(cNMBAlias, Nil, xFilial("F3B")))
		oModelF3B:LoadValue("F3B_FILIAL", xFilial("F3B"))
		oModelF3B:LoadValue("F3B_CODE",  cPLBook)
		oModelF3B:LoadValue("F3B_INIT",   SToD(SubStr(cRealDate, 1, 6) + "01"))
		oModelF3B:LoadValue("F3B_FINAL",  LastDay(SToD(cRealDate)))
		oModelF3B:LoadValue("F3B_STATUS", "1")
		oModelF3B:LoadValue("F3B_AUTO",   "1")
	EndIf

	dFinalDate := oModelF3B:GetValue("F3B_FINAL")
	// Selects data to fill the Automatic Book.
	cQuery := "SELECT " + CRLF
	cQuery += "    T0.F32_KEY AS VAT_KEY, " + CRLF
	cQuery += "    T0.F32_DOC AS DOC_NUM, " + CRLF
	cQuery += "    T0.F32_VATCOD AS INTCODE, " + CRLF
	cQuery += "    T0.F32_VATCD2 AS EXTCODE, " + CRLF
	cQuery += "    T0.F32_INIBS AS INIT_BASE, " + CRLF
	cQuery += "    T0.F32_INIBAL AS INIT_VALUE, " + CRLF
	cQuery += "    T0.F32_OPBS AS OPEN_BASE, " + CRLF
	cQuery += "    T0.F32_OPBAL AS OPEN_BALANCE, " + CRLF
	cQuery += "    T0.F32_PDATE AS PRINT_DATE, " + CRLF
	cQuery += "    T0.F32_VATRT AS VAT_RATE, " + CRLF
	cQuery += "    T1.F37_CNEE_B, " + CRLF
	cQuery += "    T1.F37_CNOR_C, " + CRLF
	cQuery += "    T1.F37_CNOR_B, " + CRLF
	cQuery += "    T1.F37_CNEE_C, " + CRLF
	cQuery += "    T1.F37_ADJNR, " + CRLF
	cQuery += "    T1.F37_ADJDT, " + CRLF
	cQuery += "    T0.F32_SUPPL AS SUPPL, " + CRLF
	cQuery += "    T0.F32_SUPUN AS SUPUN, " + CRLF
	cQuery += "    T2.A2_NOME AS SHORTNAME, " + CRLF
	cQuery += "    T1.F37_INVCUR, " + CRLF
	cQuery += "    T3.F31_CODE, " + CRLF
	cQuery += "    T3.F31_TG_COD, " + CRLF
	cQuery += "    T3.F31_TYPE " + CRLF
	cQuery += "FROM " + RetSQLName("F32") + " AS T0 LEFT JOIN " + RetSQLName("F37") + " T1 ON " + CRLF
	cQuery += "    T1.F37_FILIAL  = '" + xFilial("F37") + "' AND " + CRLF
	cQuery += "    T1.D_E_L_E_T_ = ' ' AND " + CRLF
	cQuery += "    T1.F37_KEY = T0.F32_KEY LEFT JOIN " + RetSQLName("SA2") + " T2 ON " + CRLF 
	cQuery += "        T2.A2_FILIAL = '" + xFilial("SA2") + "' AND " + CRLF
	cQuery += "        T2.D_E_L_E_T_ = ' ' AND " + CRLF
	cQuery += "        T2.A2_COD = T0.F32_SUPPL AND " + CRLF
	cQuery += "        T2.A2_LOJA = T0.F32_SUPUN LEFT JOIN " + RetSQLName("F31") + " T3 ON " + CRLF 
	cQuery += "            T3.F31_FILIAL = '" + xFilial("F31") + "' AND " + CRLF
	cQuery += "            T3.D_E_L_E_T_ = ' ' AND " + CRLF
	cQuery += "            T0.F32_VATCOD = T3.F31_CODE " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "    T0.F32_FILIAL = '" + xFilial("F32") + "' AND " + CRLF
	cQuery += "    T0.D_E_L_E_T_ = ' ' AND " + CRLF
	cQuery += "    T0.F32_OPBS > 0 AND " + CRLF

	If !FwIsInCallStack("RU06D07RUS")
		// Goes thought the grid and collects list of Doc Numbers, which are already in the Model.
		// Lines marked as deleted must be counted too, because user can undelete them.		
		For nLine := 1 to oModelF64:Length(.F.)
			oModelF64:GoLine(nLine)
			If !Empty(AllTrim(oModelF64:GetValue("F64_KEY")))
				// Adds conditions to exclude the records, which are already in the model, from SQL query.
				cQuery += "    NOT (T0.F32_KEY = '" + oF37:GetValue("F37_KEY") + "' AND " + CRLF
				cQuery += "    T0.F32_VATCOD = '" + oModelF64:GetValue("F64_VATCOD") + "') AND " + CRLF
			EndIf
		Next nLine
	Else
		cQuery += "    T0.F32_KEY = '" + aRecBal[1][01] + "' AND " + CRLF
	EndIf

	//cQuery += "    T0.F32_OPBS > 0 AND " + CRLF
	If (cPrtMonth $ "03|06|09|12")
		cQuery += "    T0.F32_PDATE <= '" + DtoS(dFinalDate) + "' AND " + CRLF
		cQuery += "    T0.F32_RDATE <= '" + DtoS(DaySum(LastDay(dFinalDate), EXTRA_DAYS_AFTER_TAX_PERIOD)) + "' AND " + CRLF   
	Else
		cQuery += "    T0.F32_RDATE <= '" + DtoS(dFinalDate) + "' AND " + CRLF    
	EndIf
	cQuery += "    T0.F32_VATCOD = '" + oModelF64:GetValue("F64_VATCOD") + "' AND " + CRLF
	cQuery += "    T0.F32_VATCD2 = '" + oModelF64:GetValue("F64_VATCD2") + "' AND " + CRLF
	cQuery += "    T0.F32_SUPPL = '" + oF37:GetValue("F37_FORNEC") + "' AND " + CRLF
	cQuery += "    T0.F32_SUPUN = '" + oF37:GetValue("F37_BRANCH") + "' " + CRLF
	cQuery += "ORDER BY " + CRLF
	cQuery += "    T0.F32_FILIAL, " + CRLF
	cQuery += "    T0.F32_SUPPL, " + CRLF
	cQuery += "    T0.F32_SUPUN, " + CRLF
	cQuery += "    T0.F32_DOC, " + CRLF
	cQuery += "    T0.F32_RDATE, " + CRLF
	cQuery += "    T0.F32_KEY, " + CRLF
	cQuery += "    T0.F32_VATCOD, " + CRLF
	cQuery += "    T0.F32_VATCD2"
	
	cTab := MPSysOpenQuery(cQuery)

	// Iterates through the open balances of this particular Purchases VAT Invoice.
	lCanUpdLin := oModelF64:CanUpdateLine()
	lCanInsLin := oModelF64:CanInsertLine()
	oModelF64:SetNoUpdateLine(.F.)
	oModelF64:SetNoInsertLine(.F.)

	// If there is no empty line, add new line and push new data to the bottom of the grid.
	// If there is already an empty line, data could be inserted starting from this empty line.
	If !Empty(AllTrim(oModelF64:GetValue("F64_KEY")))
		nLine := oModelF64:AddLine()
	Else
		nLine := oModelF64:Length(.F.)
	EndIf

	If !(cTab)->(Eof())
		(cTab)->(DBGoTop())

		cVatKey := oF37:GetValue("F37_KEY")
		cCdSupp := (cTab)->SUPPL
		cBrSupp := (cTab)->SUPUN
		cDoc    := (cTab)->DOC_NUM
		dRealDt := SToD((cTab)->PRINT_DATE)
		dPrntDt := SToD((cTab)->PRINT_DATE)
		cVATCdI := (cTab)->INTCODE
		cVATCdE := (cTab)->EXTCODE
		cVATRat := (cTab)->VAT_RATE
		nIniBal := (cTab)->INIT_VALUE
		nIniBas := (cTab)->INIT_BASE
		nOpenBs := (cTab)->OPEN_BASE

		cSE2Key := xFilial("SE2") + "|" + ;
			oModelSE2:GetValue("E2_PREFIXO") + "|" + ;
			oModelSE2:GetValue("E2_NUM") + "|" + ;
			oModelSE2:GetValue("E2_PARCELA") + "|" + ;
			oModelSE2:GetValue("E2_TIPO") + "|" + ;
			oModelSE2:GetValue("E2_FORNECE") + "|" + ;
			oModelSE2:GetValue("E2_LOJA")

		cQuery := "SELECT " + CRLF
		cQuery += "    FK2_DATA, " + CRLF
		cQuery += "    FK2_SEQ, " + CRLF
		cQuery += "    FK2_HISTOR, " + CRLF
		cQuery += "    FK2_IDFK2 " + CRLF
		cQuery += "FROM " + CRLF
		cQuery += "    " + RetSqlName("FK2") + " FK2 INNER JOIN " + RetSqlName("FK7") + " FK7 ON " + CRLF
		cQuery += "    FK2_FILIAL = FK7_FILIAL AND " + CRLF
		cQuery += "	   FK2_IDDOC = FK7_IDDOC " + CRLF
		cQuery += "WHERE " + CRLF  
		cQuery += "    FK7_FILIAL = '" + xFilial("FK7") + "' AND " + CRLF
		cQuery += "    FK2_FILIAL = '" + xFilial("FK2", xFilial("FK7")) + "' AND " + CRLF
		cQuery += "    FK7_CHAVE = '" + cSE2Key + "' AND " + CRLF
		cQuery += "    FK7.D_E_L_E_T_ = ' ' AND " + CRLF
		cQuery += "    FK2.D_E_L_E_T_ = ' '"
		cTabSE2 := MPSysOpenQuery(cQuery)

		lRet := lRet .And. oModelF64:LoadValue("F64_MDATE",  SToD((cTabSE2)->FK2_DATA))
		lRet := lRet .And. oModelF64:LoadValue("F64_MSEQ",   (cTabSE2)->FK2_SEQ)
		lRet := lRet .And. oModelF64:LoadValue("F64_HISTOR", (cTabSE2)->FK2_HISTOR)
		lRet := lRet .And. oModelF64:LoadValue("F64_IDFK",   (cTabSE2)->FK2_IDFK2)

		(cTabSE2)->(DbCloseArea())
	Else
		cVatKey := aRecBal[1][01]
		cCdSupp := aRecBal[1][02]
		cBrSupp := aRecBal[1][03]
		cDoc    := aRecBal[1][04]
		dRealDt := aRecBal[1][05]
		dPrntDt := aRecBal[1][06]
		cVATCdI := aRecBal[1][07]
		cVATCdE := aRecBal[1][08]
		cVATRat := aRecBal[1][09]
		nIniBal := aRecBal[1][10]
		nIniBas := aRecBal[1][11]
		nOpenBs := aRecBal[1][11]
	EndIf

	nRecRate := Min(nOpenBs / nIniBas * 100.00, nUserRate)

	lRet := lRet .And. oModelF64:LoadValue("F64_FILIAL", xFilial("F64"))
	lRet := lRet .And. oModelF64:LoadValue("F64_BOOKEY", oModelF3B:GetValue("F3B_BOOKEY"))
	lRet := lRet .And. oModelF64:LoadValue("F64_ITEM",   StrZero(nLine, GetSX3Cache("F64_ITEM", "X3_TAMANHO")))  // Number of the line in the Reclaim details table.
	lRet := lRet .And. oModelF64:LoadValue("F64_KEY",    cVatKey)	// Purchase VAT Invoice Key.
	lRet := lRet .And. oModelF64:LoadValue("F64_DOC",    SubStr(cDoc, 1, GetSX3Cache("F64_DOC", "X3_TAMANHO")))	// Purchase VAT Invoice Document Number.
	lRet := lRet .And. oModelF64:LoadValue("F64_PDATE",  dPrntDt) // Purchase VAT Invoice Print Date
	lRet := lRet .And. oModelF64:LoadValue("F64_VATCOD", cVATCdI) // Purchase VAT Invoice Internal Code.
	lRet := lRet .And. oModelF64:LoadValue("F64_VATCD2", cVATCdE) // Purchase VAT Invoice External (Operational) Code.
	lRet := lRet .And. oModelF64:LoadValue("F64_TYPE",   "1") // Type of register - 1=Adv Payment;2=Adv Receipt.

	// Virtual fields to inform user.
	lRet := lRet .And. oModelF64:LoadValue("F64_VATBS", nIniBas) // Purchase VAT Invoice Initial Base
	lRet := lRet .And. oModelF64:LoadValue("F64_VATRT", cVATRat)  // Purchase VAT Invoice Tax Rate
	lRet := lRet .And. oModelF64:LoadValue("F64_VATVL", oF37:GetValue("F37_VALUE")) // Purchase VAT Invoice Initial Tax Value
	// Last line will always exist and be empty for new user inputs.

	lRet := lRet .And. oModelF64:LoadValue("F64_ADJNR",  oF37:GetValue("F37_ADJNR"))
	lRet := lRet .And. oModelF64:LoadValue("F64_ADJDT",  oF37:GetValue("F37_ADJDT"))
	lRet := lRet .And. oModelF64:LoadValue("F64_SUCLNM", SubStr(Posicione("SA2", 1, xFilial("SA2") + cCdSupp + cBrSupp, "A2_NOME"), 1, TamSX3("F64_SUCLNM")[1]))
	lRet := lRet .And. oModelF64:LoadValue("F64_SUCL",   cCdSupp)
	lRet := lRet .And. oModelF64:LoadValue("F64_SUCLBR", cBrSupp)
	lRet := lRet .And. oModelF64:LoadValue("F64_INVCUR", oF37:GetValue("F37_INVCUR"))
	lRet := lRet .And. oModelF64:LoadValue("F64_ADSHNR", 0)
	lRet := lRet .And. oModelF64:LoadValue("F64_VALGR",  oF37:getvalue("F37_VALGR"))
	lRet := lRet .And. oModelF64:LoadValue("F64_ORIGGR", oF37:getvalue("F37_VALGR"))

	For nLine := 1 To oModelF64:Length(.F.)
		oModelF64:GoLine(nLine)
		// Calculates total. Sums not deleted lines and not empty values.
		If !oModelF64:IsDeleted() .And. !Empty(oModelF64:GetValue("F64_VATVL") .Or. !oModelF64:GetValue("F64_VATVL") == 0)
			nRecValT += oModelF64:GetValue("F64_VATVL")
		EndIf
	Next nLine
	oModelF3B:LoadValue("F3B_TOTAL", nRecValT)

	// Saves F64 info to use when updating balances at F32 table (after Purchase Books)
	aAdd(aF64, cVatKey + cVATCdI + cVATCdE)
	aAdd(aF64, nRecValT)
	aAdd(aF64, nIniBas)

	oModelF64:SetNoUpdateLine(!lCanInsLin)
	oModelF64:SetNoInsertLine(!lCanInsLin)

	// If the validation of the model is not successful.
	If lRet .And. !oBook:VldData()
		lRet := .F.
		Help("", 1, "RU09T10018_SaveInPurchaseBook:03",, STR0941, 1, 0)
		DisarmTransaction()
		
	// If commit not is successful.
	ElseIf lRet .And. !oBook:CommitData()
		lRet := .F.
		Help("", 1, "RU09T10018_SaveInPurchaseBook:04",, STR0942, 1, 0)
		DisarmTransaction()
	EndIf

	// Update Balances After Purchase Book
	RU09D05Edt(oBook, .T., aF64)
	oBook:DeActivate()

	If lRet 
		//Update F37 -> Purchase Ledger book code into F37_BOOK
		aAreaF37 := F37->(GetArea())
		DBSelectArea("F37")
		F37->(DBSetOrder(3)) //f37_filial + f37_key
		If F37->(MSSeek(xFilial("F37", oF37:GetValue('F37_FILIAL') + cVatKey)))
			RecLock("F37", .F.)		
  			F37->F37_BOOK := cPLBook		
  			F37->(MsUnlock())
		EndIf
		RestArea(aAreaF37)
	EndIf
	// TODO: here should be an accounting postings update.

	RestArea(aAreaF64)
	RestArea(aAreaF3B)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} RU09T10019_AccountingPost
Function thats posts accounting entries.
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 15/11/2023
@param oModel, Object,  Model to be saved
@param lInc,   Logical, Checks if is an inclusion
@return lRet,  Logical, If saving process is ok
/*/
Static Function RU09T10019_AccountingPost(oModel As Object, lInc As Logical) As Logical

	Local lRet      As Logical
	Local oModelF37 As Object
	Local oModelF38 As Object
	Local nHdlPrv   As Numeric
	Local cLoteFis  As Character
	Local cOrigem   As Character
	Local cArquivo  As Character
	Local nTotal    As Numeric
	Local lCommit   As Logical
	Local cPadrao   As Character
	Local cKeyF37   As Character
	Local cKeyF38   As Character
	Local aArea     As Array
	Local aAreaF37  As Array
	Local aAreaF38  As Array
	Local aAreaSF1  As Array
	Local aAreaSA2  As Array
	Local aAreaSB1  As Array
	Local aAreaSC7  As Array
	Local aAreaSB8  As Array
	Local aAreaSF4  As Array
	Local aAreaSFB  As Array
	Local lShowJE   As Logical
	Local lGroupJE  As Logical
	Local cPerg     As Character

	lRet := .T.

	cPerg := "RU09T10"

	Pergunte(cPerg, .F.)

	Begin Transaction
	oModelF37 := oModel:GetModel("F37master")
	oModelF38 := oModel:GetModel("F38detail")
	nHdlPrv   := 0
	cLoteFis  := LoteCont("FIS")
	cOrigem   := "RU09T10"
	cArquivo  := " "
	nTotal    := 0
	lCommit   := .F.
	// If it is an inclusion, must be used the Standard Entry 6AG to the header.
	// If it is a deletion, must be used the Standard Entry 6AH to the header.
	cPadrao := IIf(lInc, "6AG", "6AH")
	aArea := GetArea()
	aAreaF37 := F37->(GetArea())
	aAreaF38 := F38->(GetArea())
	aAreaSF1 := SE2->(GetArea())
	aAreaSA2 := SA2->(GetArea())
	aAreaSB1 := SB1->(GetArea())
	aAreaSC7 := SC7->(GetArea())
	aAreaSB8 := SB8->(GetArea())
	aAreaSF4 := SF4->(GetArea())
	aAreaSFB := SFB->(GetArea())
	lShowJE	:= (mv_par02 == 1)
	lGroupJE := (mv_par03 == 1)

	cKeyF37 := xFilial("F37") + oModelF37:GetValue("F37_FORNEC") + oModelF37:GetValue("F37_BRANCH") + DToS(oModelF37:GetValue("F37_PDATE")) + oModelF37:GetValue("F37_DOC") + oModelF37:GetValue("F37_TYPE")
		
	// Needs to set the records in tables F37, SF1 and SA1 to help the end user to work with Standard Entries 6AG and 6AH.
	DbSelectArea("F37")
	F37->(DbSetOrder(2))
	F37->(DbSeek(cKeyF37))

	DbSelectArea("SE2")
	SE2->(DbSetOrder(6))
	SE2->(DbSeek(xFilial("SE2") + F37->F37_FORNEC + F37->F37_BRANCH + SubStr(F37->F37_INVSER, 1, TamSX3("E2_PREFIXO")[1])) + SubStr(F37->F37_INVDOC, 1, TamSX3("E2_NUM")[1]))                                                                                                  

	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2") + F37->F37_FORNEC + F37->F37_BRANCH))

	DbSelectArea("F37")

	nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)

	If (nHdlPrv > 0)
		nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis,)
		cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lShowJE, lGroupJE)
		RodaProva(nHdlPrv, nTotal)
		
		// Updates the posting date.
		RecLock("F37", .F.)
		F37->F37_DTLA := dDataBase
		F37->(MsUnlock())
	EndIf

	// If it is an inclusion, must be used the Standard Entry 6AB to the items.
	// If it is a deletion, must be used the Standard Entry 6AD to the items.
	cPadrao := Iif(lInc, "6AB", "6AD")
	nItem := 1

	cKeyF38 := xFilial("F38") + oModelF38:GetValue("F38_KEY")

	DbSelectArea("F38")
	F38->(DbSetOrder(3))
	F38->(DbSeek(cKeyF38))

	nTotal := 0
	nHdlPrv := HeadProva(cLoteFis, cOrigem, SubStr(cUserName, 1, 6), @cArquivo)

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + F38->F38_ITMCOD))
	
	DbSelectArea("SFB")
	SFB->(DbSetOrder(1))
	SFB->(DbSeek(xFilial("SFB") + "VAT"))
	
	DbSelectArea("F38")
	F38->(DbSetOrder(1))
	F38->(DbSeek(cKeyF38 + StrZero(1, TamSX3("F38_ITEM")[1])))
	
	If (nHdlPrv > 0)
		nTotal += DetProva(nHdlPrv, cPadrao, cOrigem, cLoteFis,)
		
		RecLock("F38", .F.)
		F38->F38_DTLA := dDataBase
		F38->(MsUnlock())
	EndIf

	cA100Incl(cArquivo, nHdlPrv, 3, cLoteFis, lShowJE, lGroupJE)
	RodaProva(nHdlPrv, nTotal)

	RestArea(aArea)
	RestArea(aAreaF37)
	RestArea(aAreaF38)
	RestArea(aAreaSE2)
	RestArea(aAreaSA2)
	RestArea(aAreaSB1)
	RestArea(aAreaSC7)
	RestArea(aAreaSB8)
	RestArea(aAreaSF4)
	RestArea(aAreaSFB)
	End Transaction

Return(lRet)

/*/{Protheus.doc} RU09T10020_GetLegalContractInfo
Return Legal Contract description and name by key code (F5Q_CODE)
@type   Function
@author Konstantin Konovalov
@since  01/04/2024
@version version 
@param cCNumber, Character,	contract number (in)
@param cDescLC, Character, contract description (out)
@param cCName, Character, contract unique identificator (out)
@see  FI-VAT-37-3, FI-VAT-37-4
/*/
Function RU09T10020_GetLegalContractInfo(cCNumber as Character, cDescLC as Character, cCName as Character)
	Local cQuery	As Character
	Local cTabLC    As Character
	Local aArea		As Array

	Default cDescLC := ""
	Default cCName := ""
	aArea := GetArea()	
	cTabLC:= ""

	cQuery := "SELECT " + CRLF 
	cQuery += "    F5Q_DESCR, " + CRLF
	cQuery += "    F5R_UID " + CRLF
	cQuery += "FROM " + CRLF 
	cQuery += "    " + RetSQLName("F5Q") + " F5Q INNER JOIN " + RetSQLName("F5R") + " F5R ON " + CRLF
	cQuery += "    F5Q_CODE = F5R_CODE AND " + CRLF
	cQuery += "    F5Q_FILIAL = '" + xFilial("F5Q", xFilial("F5R")) + "' " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "    F5Q_CODE = '" + cCNumber + "' AND " + CRLF
	cQuery += "    F5Q_FILIAL = '" + xFilial("F5Q") + "' AND " + CRLF
	cQuery += "    F5Q.D_E_L_E_T_  = ' ' AND " + CRLF
	cQuery += "    F5R.D_E_L_E_T_  = ' '"

	cTabLC := MPSysOpenQuery(ChangeQuery(cQuery))
	DBSelectArea(cTabLC)

	If !(cTabLC)->(Eof())
		cDescLC := AllTrim((cTabLC)->F5Q_DESCR)
		cCName  := AllTrim(RU69T01004_Return_F5R_Common_Name((cTabLC)->F5R_UID))
	EndIf
	(cTabLC)->(DbCloseArea())

	RestArea(aArea)

Return()
                   
//Merge Russia R14 
                   
