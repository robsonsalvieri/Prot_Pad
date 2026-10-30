#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "topconn.ch"
#INCLUDE "ru09t11.ch"
#INCLUDE "ru09xxx.ch"

#DEFINE RU09T11_F35_FIELDS "F35_IDATE;F35_INVSER;F35_INVDOC;F35_CURR;F35_CONUNI;F35_MOEDA;F35_MOEDES;F35_INVDT"
#DEFINE RU09T11_F36_FIELDS "F36_FILIAL;F36_KEY;F36_DOCKEY;F36_TYPE;F36_DOC;F36_EXC_V1;F36_VATVS1;F36_EXC_V1;F36_DTLA;F36_INVCUR;F36_INVSER;F36_INVDOC;F36_INVIT;F36_INVDT;F36_ITDATE"
#DEFINE RU09T11_F5P_FIELDS "F5P_KEY;"
#DEFINE RU09T11_SE1_FIELDS "E1_FILIAL;E1_PREFIXO;E1_NUM;E1_PARCELA;E1_TIPO;E1_CLIENTE;E1_LOJA;E1_EMISSAO;E1_VENCREA;E1_VALOR;E1_SALDO;E1_TXMOEDA;E1_CONUNI;E1_MOEDA;E1_VLCRUZ"

/* {Protheus.doc} RU09T11
Routine to deal with VAT Advances Received
@type Function
@author Fernando Nicolau
@since 13/11/2023
@version 1.0
@project MA3 - Russia
*/
Function RU09T11() As Logical

	Local oBrowse As Object
	Local lRet    As Logical

	lRet := .T.

	DbSelectArea("F35")
	DbSelectArea("F36")

	oBrowse := FWLoadBrw("RU09T11")
	aRotina := MenuDef()
	oBrowse:Activate()

Return(lRet)

/* {Protheus.doc} BrowseDef
Browse definitions
@type Function
@author Fernando Nicolau
@since 13/11/2023
@project MA3 - Russia
*/
Static Function BrowseDef()

	Local oBrowse As Object

	oBrowse	:= FWMBrowse():New()
	oBrowse:SetDescription(STR0001) //Advances Received
	oBrowse:SetAlias("F35")

Return(oBrowse)

/* {Protheus.doc} MenuDef
Menu definitions
@type Function
@author Fernando Nicolau
@since 13/11/2023
@project MA3 - Russia
*/
Static Function MenuDef()

	Local aButtons As Array

	aButtons := { ;
		{STR0002, "FwExecView('" + STR0002 + "', 'RU09T11', " + Str(MODEL_OPERATION_VIEW)   + ")", 0, 2, 0, Nil}, ; //View
	{STR0003, "FwExecView('" + STR0003 + "', 'RU09T11', " + Str(MODEL_OPERATION_INSERT) + ")", 0, 3, 0, Nil}, ; //Add
	{STR0004, "FwExecView('" + STR0004 + "', 'RU09T11', " + Str(MODEL_OPERATION_UPDATE) + ")", 0, 4, 0, Nil}, ; //Edit
	{STR0005, "FwExecView('" + STR0005 + "', 'RU09T11', " + Str(MODEL_OPERATION_DELETE) + ")", 0, 5, 0, Nil}}   //Delete

Return()

/*/{Protheus.doc} ModelDef
Creates the model of Advances VAT Invoice.
@type Function
@author Fernando Nicolau
@since 07/11/2023
@project MA3 - Russia
@return Object, Menu instance of the routine
/*/ 		 
Static Function ModelDef()

	Local oStructF35 As Object
	Local oStructF36 As Object
	Local oStructF5P as Object
	Local oStructSE1 As Object

	Private oModel As Object

	oStructF35 := FWFormStruct(1, "F35")
	oStructF36 := FWFormStruct(1, "F36")
	oStructF5P := FWFormStruct(1, "F5P")
	oStructSE1 := FWFormStruct(1, "SE1", {|x| (AllTrim(x) $ RU09T11_SE1_FIELDS)})

	oModel := MPFormModel():New("RU09T11", /*bPre*/, /*bPost*/, {|oModel| RU09T11017(oModel)}/*bCommit*/, /*bCancel*/)
	oModel:SetDescription(STR0006)	// "Sales VAT Invoices"

	oModel:AddFields("F35MASTER", Nil, oStructF35, {|oModel, cAction, cField, xValue| RU09T11005(oModel, cAction, cField, xValue)} /*bPre*/, {|oModel| RU09T11016(oModel)}/*bPost*/)
	oModel:GetModel("F35MASTER"):SetDescription(STR0008) // "VAT Invoices Headers"
	oModel:AddGrid("F36DETAIL", "F35MASTER", oStructF36)
	oModel:AddGrid("F5PDETAIL", "F35MASTER", oStructF5P)
	oModel:AddGrid("SE1DETAIL", "F35MASTER", oStructSE1)
	oModel:GetModel("F36DETAIL"):SetDescription(STR0009) // "VAT Invoices Items"
	oModel:SetRelation("F36DETAIL", {;
		{"F36_FILIAL", "xFilial('F36')"}, ;
		{"F36_KEY", "F35_KEY"}, ;
		{"F36_DOC", "F35_DOC"}}, ;
		F36->(IndexKey(1)))
	oModel:SetRelation("F5PDETAIL", {{"F5P_FILIAL", "xFilial('F5P')"}, {"F5P_KEY", "F35_KEY"}}, F5P->(IndexKey(1)))
	oModel:SetRelation("SE1DETAIL", {;
		{"E1_FILIAL", "xFilial('SE1')"}, ;
		{"E1_PREFIXO", "F35_PREFIX"}, ;
		{"E1_NUM", "F35_NUM"}, ;
		{"E1_PARCELA", "F35_PARCEL"}, ;
		{"E1_TIPO", "F35_TIPO"}, ;
		{"E1_CLIENTE", "F35_CLIENT"}, ;
		{"E1_LOJA", "F35_BRANCH"}}, ;
		SE1->(IndexKey(1)))
	oModel:SetPrimaryKey({"F35_FILIAL", "F35_CLIENT", "F35_BRANCH", "F35_PDATE", "F35_DOC", "F35_TYPE"})
	oModel:GetModel("F36DETAIL"):SetUniqueLine({"F36_ITEM"})

	oModel:SetOnlyQuery("SE1DETAIL")
	oModel:GetModel("SE1DETAIL"):SetOptional(.T.)
	oModel:GetModel("F5PDETAIL"):SetOptional(.T.)

	oStructF36:SetProperty("F36_VATBS",  MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})
	oStructF36:SetProperty("F36_VALGR",  MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})
	oStructF36:SetProperty("F36_VATVL",  MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})
	oStructF36:SetProperty("F36_VATBS1", MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})
	oStructF36:SetProperty("F36_VATVL1", MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})
	oStructF36:SetProperty("F36_VALUE",  MODEL_FIELD_VALID, {| oModel | RU09T10013(oModel)})

Return(oModel)

/*/{Protheus.doc} ViewDef
Creates the view of Advances VAT Invoice.
@type Static function
@author Fernando Nicolau
@since 06/11/2023
@project MA3 - Russia
@return oView, Object, View instance of the routine
/*/
Static Function ViewDef()

	Local oView As Object
	Local oModel As Object
	Local oStructF35 As Object
	Local oStrucTots As Object
	Local oStructF36 As Object
	Local oStructF5P as Object
	Local oStructSE1 As Object
	Local cCmpF35_T As Character
	Local lHide As Logical

	lHide := .F.

	// Defines which fields want to show on the upper part of screenfields for bottom part - Totals.
	cCmpF35_T := "F35_VALUE;F35_EXC_VL;F35_VATBS;F35_VATVL;F35_VATBS1;F35_VATVL1;F35_VALGR"

	oModel := FwLoadModel("RU09T11")

	oStructF35 := FWFormStruct(2, "F35", {|x| !(AllTrim(x) $ RU09T11_F35_FIELDS )})
	oStructF36 := FWFormStruct(2, "F36", {|x| !(AllTrim(x) $ RU09T11_F36_FIELDS)})
	oStructF5P := FWFormStruct(2, "F5P", {|x| !(AllTrim(x) $ RU09T11_F5P_FIELDS)})
	oStrucTots := FWFormStruct(2, "F35", {|x| (AllTrim(x) $ cCmpF35_T)})
	oStructSE1 := FWFormStruct(2, "SE1", {|x| (AllTrim(x) $ RU09T11_SE1_FIELDS)})

	oStrucTots:SetNoFolder()

	If (lHide)
		oStructF36:RemoveField("F36_ORIGIN")
		oStructF36:RemoveField("F36_NUMDES")
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetDescription(STR0006) // "Sales VAT Invoices"

	oView:AddField("VIEW_F35M", oStructF35, "F35MASTER")
	oView:AddGrid("VIEW_SE1D", oStructSE1, "SE1DETAIL")
	oView:AddGrid("VIEW_F36D",  oStructF36, "F36DETAIL")
	oView:AddGrid("VIEW_F5PD",  oStructF5P, "F5PDETAIL")
	oView:AddField("VIEW_F35T", oStrucTots, "F35MASTER")

	oView:CreateHorizontalBox("HEADERBOX", 55)
	oView:CreateHorizontalBox("ITEMBOX", 35)
	oView:CreateHorizontalBox("TOTALBOX", 10)

	oView:CreateFolder('FOLDER1', 'HEADERBOX')
	oView:AddSheet('FOLDER1', 'Sheet1', STR0010) // "VAT Invoice"
	oView:AddSheet('FOLDER1', 'Sheet2', STR0020) // "Payment Documents"
	oView:AddSheet('FOLDER1', 'Sheet3', STR0011) // "Receivement Advances"

	oView:CreateHorizontalBox("F35HEADERBOX", 100/*%*/,,,'FOLDER1', 'Sheet1')
	oView:SetOwnerView("VIEW_F35M", "F35HEADERBOX")

	oView:SetOwnerView("VIEW_F36D", "ITEMBOX")
	oView:SetOwnerView("VIEW_F35T", "TOTALBOX")
	oView:SetCloseOnOk({|| .T.})

	oView:SetViewProperty("VIEW_SE1D", "GRIDDOUBLECLICK", {{|oModel| RU09T11006(oModel)}})

	oView:CreateHorizontalBox("F5PHEADERBOX", 100,,, 'FOLDER1', 'Sheet2')
	oView:SetOwnerView("VIEW_F5PD", "F5PHEADERBOX")
	
	oView:CreateHorizontalBox("SE1HEADERBOX", 100,,, 'FOLDER1', 'Sheet3')
	oView:SetOwnerView("VIEW_SE1D", "SE1HEADERBOX")

	oView:SetNoInsertLine("VIEW_SE1D")
	oView:SetNoUpdateLine("VIEW_SE1D")
	oView:SetNoDeleteLine("VIEW_SE1D")
	oView:SetNoInsertLine("VIEW_F36D")
	oView:SetNoUpdateLine("VIEW_F36D")
	oView:SetNoDeleteLine("VIEW_F36D")
	oStructF35:RemoveField("F35_F5QUID")
	
	oView:AddIncrementField("VIEW_F36D", "F36_ITEM")
	oView:AddIncrementField("VIEW_F5PD", "F5P_ITEM")

Return(oView)

/* {Protheus.doc} RU09T11001_AdvancesScreen
Function shows all the Payment Advances.
@type Static Function
@author Fernando Nicolau
@since 06/11/2023
@project MA3 - Russia
@param cParPerg, Character, Paramenters of the Pergunte in the following order: Pergunte's Name | Pergunte's Item
@return lRet, Logical, If the routine runs ok
*/
Function RU09T11001_AdvancesScreen(cParPerg as Character) As Logical

	Local lRet As Logical
	// Working areas
	Local aArea As Array
	Local aHeader As Array
	Local aCols As Array
	Local aRotina As Array
	Local oDlg As Object
	Local oData As Object
	Local oModel As Object
	Local nPosCus As Numeric
	Local nPosBranch As Numeric
	Local nLinha As Numeric
	Local cFilBkp As Character
	Local cCustomer As Character
	Local cBranch As Character

	Default cParPerg := ""

	aArea   := GetArea()
	aHeader := RU09T11003_ReturnHeader()

	lRet := .T.

	// Variables initialisation
	aCols   := {}
	aRotina := {}
	cFilBkp := cFilAnt

	If RU09T11002(aCols)
		If Len(aCols) > 0
			oDlg := MsDialog():New(160, 160, 400, 1200, STR0007 , , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // "Receives in Advance"

			oData := MsNewGetDados():New(1, 1, , 1,,,,,,, 999,,,, oDlg, aHeader, aCols,,)
			oData:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
			oDlg:bInit := EnchoiceBar(oDlg, {|| lRet := .T., oDlg:End()}, {|| lRet := .F., oDlg:End()})
			oDlg:Activate(, , , .T., {|| .T.}, , {|| .F.})
		Else
			// If there is no record to create a Advance VAT Invoice, must be canceled and closed this window.
			lRet := .F.
			Help("", 1, "RU09T11001_AdvancesScreen01",, STR0012, 1, 0) // "According to your filters, no records were found"
		EndIf
	Else
		// Questions window was escaped or cancelled.
		lRet := .F.
	EndIf

	If (lRet)
		nPosCus := aScan(aHeader, {|x| AllTrim(x[2]) == "E1_CLIENTE"})
		nPosBranch := aScan(aHeader, {|x| AllTrim(x[2]) == "E1_LOJA"})
		nLinha := oData:nAt

		cCustomer := oData:aCols[nLinha][nPosCus]
		cBranch := oData:aCols[nLinha][nPosBranch]

		// If it is everything OK, must to show a window to the end user to continue to add a Sales VAT Invoice.
		oModel := FwLoadModel("RU09T11")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:SetDescription(STR0007) // "Receives in Advance"
		oModel:Activate()
		oModel := RU09T11008(oModel, oData, aHeader, cCustomer, cBranch)
		oModel:GetModel("F36DETAIL"):SetNoInsertLine(.F.)
		oModel:GetModel("SE1DETAIL"):SetNoInsertLine(.T.)
		FwExecView(STR0003, "RU09T11", MODEL_OPERATION_INSERT,, {|| .T.},,,,,,, oModel) // "Add"
	EndIf

	cFilAnt := cFilBkp

	RestArea(aArea)

Return(lRet)

/* {Protheus.doc} RU09T11002_ReturnData ()
Function that returns all records allowed to create a Outflow VAT Invoice.
@type Function
@author Fernando Nicolau
@since 03/11/2023
@project MA3 - Russia
@param aRet,  Array,   aCols from the calling routine
*/
Static Function RU09T11002_ReturnData(aRet As Array) As Logical

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
	Local cFrArN As Character
	Local cToArN As Character
	Local cFrIns As Character
	Local cToIns As Character
	Local cFrCus As Character
	Local cFrBra As Character
	Local cToCus As Character
	Local cToBra As Character
	Local dFrIDt As Date
	Local dToIDt As Date
	Local cIn As Character
	Local cSe1Key As Character

	Private cRetSX505 As Character // This variable is used in the Pergunte RU09T0202

	Default aRet := {}

	lRet := .T.
	cIn := ""
	cRetSX505 := ""
	cPerg := "RU09T0202"

	// Opens the window with questions "From" - "To" used as filter.
	If (Pergunte(cPerg, .T.))

		cType  := AllTrim(MV_PAR01)
		cFrArN := AllTrim(MV_PAR02)
		cToArN := AllTrim(MV_PAR03)
		cFrPre := AllTrim(MV_PAR04)
		cToPre := AllTrim(MV_PAR05)
		cFrIns := AllTrim(MV_PAR06)
		cToIns := AllTrim(MV_PAR07)
		cFrCus := AllTrim(MV_PAR08)
		cFrBra := AllTrim(MV_PAR09)
		cToCus := AllTrim(MV_PAR10)
		cToBra := AllTrim(MV_PAR11)
		dFrIDt := MV_PAR12
		dToIDt := MV_PAR13

		cQuery := " SELECT " + CRLF
		cQuery += "    E1.E1_FILIAL, " + CRLF
		cQuery += "    E1.E1_PREFIXO, " + CRLF
		cQuery += "    E1.E1_NUM, " + CRLF
		cQuery += "    E1.E1_PARCELA, " + CRLF
		cQuery += "    E1.E1_TIPO, " + CRLF
		cQuery += "    E1.E1_CLIENTE, " + CRLF
		cQuery += "    E1.E1_LOJA, " + CRLF
		cQuery += "    A1.A1_NOME, " + CRLF
		cQuery += "    E1.E1_EMISSAO, " + CRLF
		cQuery += "    E1.E1_VENCREA, " + CRLF
		cQuery += "    E1.E1_VALOR, " + CRLF
		cQuery += "    E1.E1_SALDO, " + CRLF
		cQuery += "    E1.E1_TXMOEDA, " + CRLF
		cQuery += "    E1.E1_CONUNI, " + CRLF
		cQuery += "    E1.E1_MOEDA, " + CRLF
		cQuery += "    E1.E1_VLCRUZ " + CRLF
		cQuery += "FROM " + RetSQLName("SE1") + " E1 INNER JOIN " + RetSQLName("SA1") + " A1 ON " + CRLF
		cQuery += "    (A1.A1_FILIAL = '" + xFilial("SA1") + "' AND " + CRLF
		cQuery += "    A1.A1_COD = E1.E1_CLIENTE AND " + CRLF
		cQuery += "    A1.A1_LOJA = E1.E1_LOJA AND " + CRLF
		cQuery += "    A1.D_E_L_E_T_ = ' ') " + CRLF
		cQuery += "WHERE " + CRLF
		cQuery += "    E1.E1_FILIAL = '" + xFilial("SE1") + "' AND " + CRLF
		If (!Empty(cType))
			cIn := FormatIn(cType, ";")
			cQuery += "    E1.E1_TIPO IN " + cIn + " AND " + CRLF
		EndIf

		cQuery += "    E1.E1_PREFIXO BETWEEN '" + cFrPre + "' AND '" + cToPre + "' AND " + CRLF
		cQuery += "    E1.E1_NUM BETWEEN '" + cFrArN + "' AND '" + cToArN + "' AND " + CRLF
		cQuery += "    E1.E1_PARCELA BETWEEN '" + cFrIns + "' AND '" + cToIns + "' AND " + CRLF
		cQuery += "    E1.E1_CLIENTE BETWEEN '" + cFrCus + "' AND '" + cToCus + "' AND " + CRLF
		cQuery += "    E1.E1_LOJA BETWEEN '" + cFrBra + "' AND '" + cToBra + "' AND " + CRLF
		cQuery += "    E1.E1_EMISSAO BETWEEN '" + DtoS(dFrIDt) + "' AND '" + DtoS(dToIDt) + "' AND " + CRLF
		cQuery += "    E1.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "	AND NOT EXISTS " + CRLF
		cQuery += " ( " + CRLF
		cQuery += "	    SELECT " + CRLF
		cQuery += "	    	1 " + CRLF
		cQuery += "	    FROM " + CRLF
		cQuery += "	    	" + RetSQLName("F35") + " F35 " + CRLF
		cQuery += "	    WHERE " + CRLF
		cQuery += "	    	F35.F35_FILIAL = '" + xFilial("F35") + "' " + CRLF
		cQuery += "	    	AND F35.F35_PREFIX = E1.E1_PREFIXO " + CRLF
		cQuery += "	    	AND F35.F35_NUM    = E1.E1_NUM " + CRLF
		cQuery += "	    	AND F35.F35_PARCEL = E1.E1_PARCELA " + CRLF
		cQuery += "	    	AND F35.F35_TIPO   = E1.E1_TIPO " + CRLF
		cQuery += "	    	AND F35.F35_CLIENT = E1.E1_CLIENTE " + CRLF
		cQuery += "	    	AND F35.F35_BRANCH = E1.E1_LOJA " + CRLF
		cQuery += "	    	AND F35.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += " ) " + CRLF
		cQuery += " ORDER BY " + CRLF
		cQuery += "    E1.E1_PREFIXO, " + CRLF
		cQuery += "    E1.E1_NUM, " + CRLF
		cQuery += "    E1.E1_PARCELA, " + CRLF
		cQuery += "    E1.E1_TIPO " + CRLF
		
		cTab := MPSysOpenQuery(ChangeQuery(cQuery))
		DbSelectArea((cTab))
		(cTab)->(DbGoTop())

		While ((cTab)->(!Eof()))
		cSe1Key := (cTab)->E1_FILIAL + "|" + ;
				(cTab)->E1_PREFIXO + "|" + ;
				(cTab)->E1_NUM + "|" + ;
				(cTab)->E1_PARCELA + "|" + ;
				(cTab)->E1_TIPO + "|" + ;
				(cTab)->E1_CLIENTE + "|" + ;
				(cTab)->E1_LOJA

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
			cQuery += "    F5M_KEY = '" + cSe1Key + "' AND " + CRLF 
			cQuery += "    F5M_ALIAS = 'F4C' AND F5M.D_E_L_E_T_ = ' '"
			cTab2 := MPSysOpenQuery(ChangeQuery(cQuery))
			DbSelectArea((cTab2))
			(cTab2)->(DbGoTop())

			aAdd(aRet, ;
				{(cTab2)->F4C_BNKORD, ;
				DToC(SToD((cTab2)->F4C_DTPAYM)), ;
				(cTab2)->F4C_INTNUM, ;
				DToC(SToD((cTab2)->F4C_DTTRAN)), ;
				(cTab)->E1_PREFIXO, ;
				(cTab)->E1_NUM, ;
				(cTab)->E1_PARCELA, ;
				(cTab)->E1_TIPO, ;
				(cTab)->E1_CLIENTE, ;
				(cTab)->E1_LOJA, ;
				(cTab)->A1_NOME, ;
				DToC(SToD((cTab)->E1_EMISSAO)), ;
				DToC(SToD((cTab)->E1_VENCREA)), ;
				(cTab)->E1_VALOR, ;
				(cTab)->E1_SALDO, ;
				(cTab)->E1_TXMOEDA, ;
				(cTab)->E1_CONUNI, ;
				(cTab)->E1_MOEDA, ;
				(cTab)->E1_VLCRUZ, ;
				.F.})

			(cTab)->(DbSkip())
		EndDo

		(cTab)->(DbCloseArea())
	Else
		// If user closes the questions window, nothing happens.
		lRet := .F.
	EndIf

Return(lRet)

/*/{Protheus.doc} RU09T11003_ReturnHeader
Function that returns the header to select an Inflow Invoice to create an Advances VAT Invoice.
@type Static Function
@author Fernando Nicolau
@project MA3 - Russia
@since 07/11/2023
@return aRet, Array, Returns an array with the fields of the SE1 screen's header
/*/
Static Function RU09T11003_ReturnHeader() As Array

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
	aAdd(aCampos, "E1_PREFIXO")
	aAdd(aCampos, "E1_NUM")
	aAdd(aCampos, "E1_PARCELA")
	aAdd(aCampos, "E1_TIPO")
	aAdd(aCampos, "E1_CLIENTE")
	aAdd(aCampos, "E1_LOJA")
	aAdd(aCampos, "A1_NOME")
	aAdd(aCampos, "E1_EMISSAO")
	aAdd(aCampos, "E1_VENCREA")
	aAdd(aCampos, "E1_VALOR")
	aAdd(aCampos, "E1_SALDO")
	aAdd(aCampos, "E1_TXMOEDA")
	aAdd(aCampos, "E1_CONUNI")
	aAdd(aCampos, "E1_MOEDA")
	aAdd(aCampos, "E1_VLCRUZ")

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

/*{Protheus.doc} RU09T11005_PreValidF35
Prevalidation function for the fields of master model F35.
@type Static Function
@author Fernando Nicolau
@project MA3 - Russia
@since 07/11/2023
@param oModelF35, Object,  Active model
@param cAction,   Character, The action that is being performed
@param cField,    Character, The field that is being validated
@param xValue,    Variant,   Value of the field that is being validated
@return lRet,     Logical,   If the routine runs ok
*/
Static Function RU09T11005_PreValidF35(oModelF35 as Object, cAction as Character, cField as Character, xValue As Variant) As Logical

	Local lRet As Logical

	lRet := .T.

	// If user changes Inclusion Date.
	If ((cAction == "SETVALUE") .and. (cField == "F35_ITDATE"))
		If (xValue /*F35_ITDATE*/ < oModelF35:GetValue("F35_PDATE"))
			lRet := .F.
			Help("", 1, "RU09T1100501",, STR0013, 1, 0) // "The VAT Invoice's Inclusion Date cannot be earlier than the Print Date"
		EndIf
	EndIf

Return(lRet)

/*{Protheus.doc} RU09T11006_ViewAdvances
Open View of checked Advances Received
@type  Function
@author Fernando Nicolau
@project MA3 - Russia
@since 10/11/2023
@param oModel, Object, Active model
*/
Static Function RU09T11006_ViewAdvances(oModel As Object)

	// Working areas
	Local aArea As Array
	Local aAreaSE1 As Array
	// Model objects
	Local oModelSE1 As Object
	// Keys for dbSeek()
	Local cKeySE1 As Character

	// Overwriting existing buttons.
	Private aRotina As Array

	Default oModel := FWLoadModel("RU09T11")

	aRotina	:= {{"", "", 0, 2, 0, Nil}, ;
		{"", "", 0, 2, 0, Nil}, ;
		{"", "", 0, 2, 0, Nil}, ;
		{"", "", 0, 2, 0, Nil}}

	aArea := GetArea()
	aAreaSE1 := SE1->(GetArea())

	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))

	oModelSE1 := oModel:GetModel("SE1DETAIL")
	cKeySE1 := xFilial("SE1") + ;
		oModelSE1:GetValue("E1_CLIENTE") + ;
		oModelSE1:GetValue("E1_LOJA") + ;
		oModelSE1:GetValue("E1_PREFIXO") + ;
		oModelSE1:GetValue("E1_NUM") + ;
		oModelSE1:GetValue("E1_PARCELA") + ;
		oModelSE1:GetValue("E1_TIPO")

	SE1->(DbSetOrder(2))
	If SE1->(DbSeek(cKeySE1))
		RU09T11007(cKeySE1) //open View of SE1
	EndIf

	RestArea(aAreaSE1)
	RestArea(aArea)

Return()

/*/{Protheus.doc} RU09T11007_ViewARDetails
Option to see details of receipt in advance
@type Function
@author Fernando Nicolau
@project MA3 - Russia
@since 10/11/2023
@param cSE1Key, Character, The key of SE1 table
/*/
Static Function RU09T11007_ViewARDetails(cSE1Key As Character)

	Private cCadastro As Character

	DbSelectArea("SE1")
	SE1->(DbSetOrder(2))
	If SE1->(DbSeek(cSE1Key))
		cCadastro := STR0019 // "Accounts Receivable"
		AxVisual("SE1", SE1->(RecNo()), 2)
	EndIf
	SE1->(DbCloseArea())

Return()

/*/{Protheus.doc} RU09T11008_FillFieldsAtInclusion
Function that fills automatically the fields at the moment of inclusion.
@type Static Function
@author Fernando Nicolau
@project MA3 - Russia
@since 03/12/2023
@param oModel,    Object,    Active model
@param oData,     Object,    Active GetDados
@param aHeader,   Array,     Active aHeader
@param cCustomer, Character, The Customer of the selected bill
@param cBranch,   Character, The Customer's branch of the selected bill
@return oModel,   Object,    Active model
/*/
Function RU09T11008_FillFieldsAtInclusion(oModel As Object, oData As Object, aHeader As Array, cCustomer As Character, cBranch As Character) As Object

	Local lRet As Logical
	// Working areas
	Local aArea As Array
	Local aAreaSE1 As Array
	Local aAreaSA1 As Array
	Local aAreaF31 As Array
	// Positioning of user's selection.
	Local nPosPre As Numeric
	Local nPosNum As Numeric
	Local nPosCus As Numeric
	Local nPosBra As Numeric
	Local nLinha As Numeric
	// Submodels
	Local oModelF35 As Object
	Local oModelF36 As Object
	Local oModelF5P As Object
	Local oModelSE1 As Object
	// Holds CanInsertLine property.
	Local lCanInsLin As Logical
	// Internal VAT key
	Local cVATKey As Character
	// Character variables for the filter.
	Local cFil As Character
	Local cNum As Character
	Local cCus As Character
	Local cBra As Character
	// Variables for SQL requests.
	Local cQuery As Character
	Local cTabSE1 As Character
	Local lConUni As Logical

	lRet := .T.
	aArea := GetArea()
	aAreaSE1 := SE1->(GetArea())
	aAreaSA1 := SA1->(GetArea())
	aAreaF31 := F31->(GetArea())

	If IsInCallStack("RU06D07RUS")

		cFil := xFilial("SE1")
		cNum := SE1->E1_NUM
		cPre := SE1->E1_PREFIXO
		cCus := SE1->E1_CLIENTE
		cBra := SE1->E1_LOJA

	Else
		nPosNum	:= aScan(aHeader, {|x| AllTrim(x[2]) == "E1_NUM"})
		nPosPre := aScan(aHeader, {|x| AllTrim(x[2]) == "E1_PREFIXO"})
		nPosCus := aScan(aHeader, {|x| AllTrim(x[2]) == "E1_CLIENTE"})
		nPosBra := aScan(aHeader, {|x| AllTrim(x[2]) == "E1_LOJA"})
		nLinha  := oData:nAt

		cFil := xFilial("SE1")
		cNum := oData:aCols[nLinha][nPosNum]
		cPre := oData:aCols[nLinha][nPosPre]
		cCus := oData:aCols[nLinha][nPosCus]
		cBra := oData:aCols[nLinha][nPosBra]
	EndIf

	// Selects a particular Inflow Invoice using a context chosen by user.
	cQuery := "SELECT " + CRLF
	cQuery += "    * " + CRLF
	cQuery += "FROM " + RetSQLName("SE1") + " " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "    E1_FILIAL = '" + cFil + "' AND " + CRLF
	cQuery += "    E1_NUM = '" + cNum + "' AND " + CRLF
	cQuery += "    E1_PREFIXO = '" + cPre + "' AND " + CRLF
	cQuery += "    E1_CLIENTE = '" + cCus + "' AND " + CRLF
	cQuery += "    E1_LOJA = '" + cBra + "' AND " + CRLF
	cQuery += "    D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY " + CRLF
	cQuery += "    E1_FILIAL, " + CRLF
	cQuery += "    E1_NUM, " + CRLF
	cQuery += "    E1_PREFIXO, " + CRLF
	cQuery += "    E1_CLIENTE, " + CRLF
	cQuery += "    E1_LOJA"
	cTabSE1 := MPSysOpenQuery(ChangeQuery(cQuery))

	DbSelectArea("F31")
	F31->(DbSetOrder(1))

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + cCustomer + cBranch))

	// If at least one Inflow Invoice is returned by select (and should be only one).
	If (!(cTabSE1)->(Eof()))
		oModelF35 := oModel:GetModel("F35MASTER")
		oModelF36 := oModel:GetModel("F36DETAIL")
		oModelF5P := oModel:GetModel("F5PDETAIL")
		oModelSE1 := oModel:GetModel("SE1DETAIL")

		cVATKey := RU09T11015()
		While !MayIUseCode("RU09T11" + cVATKey)
			cVATKey := Soma1(cVATKey)
		EndDo

		// Check if the bill is in convemtional units
		lConUni := IIf((cTabSE1)->E1_CONUNI == "1", .T., .F.)

		lRet := lRet .And. oModelF35:LoadValue("F35_FILIAL", xFilial("F35")) // Filial
		lRet := lRet .And. oModelF35:LoadValue("F35_ORIGIN", "4")	// Account receivables
		lRet := lRet .And. oModelF35:LoadValue("F35_TYPE",   "6")	// Advances Receivable
		lRet := lRet .And. oModelF35:LoadValue("F35_PDATE",  SToD((cTabSE1)->E1_EMISSAO))	// Issue Date
		aCompBranch := GetCoBrRUS()
		lRet := lRet .And. oModelF35:LoadValue("F35_DOC",    RU09D03NMB("VATINV", Nil, xFilial("F35")) + IIf(aCompBranch[2][7][2] == "1", "/" + AllTrim(aCompBranch[2][11][2]), ""))	// Document Number
		lRet := lRet .And. oModelF35:LoadValue("F35_CONUNI", (cTabSE1)->E1_CONUNI) // Conventional Units
		lRet := lRet .And. oModelF35:SetValue("F35_CLIENT", (cTabSE1)->E1_CLIENTE)	// Customer
		lRet := lRet .And. oModelF35:SetValue("F35_BRANCH", (cTabSE1)->E1_LOJA) // Customer Branch
		lRet := lRet .And. oModelF35:SetValue("F35_CONTRA", (cTabSE1)->E1_F5QCODE) // Legal Contract Code
		
		lRet := lRet .And. oModelF35:LoadValue("F35_INVCUR", IIf(lConUni, AllTrim(Str((cTabSE1)->E1_MOEDA)), "01")) // Commercial Invoice Currency
		lRet := lRet .And. oModelF35:LoadValue("F35_C_RATE", IIf(lConUni,  (cTabSE1)->E1_TXMOEDA, 1))	// Currency Rate
		lRet := lRet .And. oModelF35:LoadValue("F35_KPP_CL", SA1->A1_INSCGAN)	// Customer KPP
		lRet := lRet .And. oModelF35:LoadValue("F35_KPP_CO", aCompBranch[2][5][2]) // Branch KPP
		lRet := lRet .And. oModelF35:LoadValue("F35_KEY",    cVATKey)	// Unique Internal Key
		
		lRet := lRet .And. oModelF35:LoadValue("F35_CNRVEN", "1")	// Consignor
		lRet := lRet .And. oModelF35:LoadValue("F35_CNECLI", "1")	// Consignee
		lRet := lRet .And. oModelF35:LoadValue("F35_VATBS",  0) // VAT Base
		lRet := lRet .And. oModelF35:LoadValue("F35_VALGR",  0) // Gross Total
		lRet := lRet .And. oModelF35:LoadValue("F35_VATVL",  0) // VAT Value
		lRet := lRet .And. oModelF35:LoadValue("F35_VATBS1", 0) // VAT Bs C1
		lRet := lRet .And. oModelF35:LoadValue("F35_VATVL1", 0) // VAT Vl C1
		lRet := lRet .And. oModelF35:LoadValue("F35_VALUE",  0) // Total Value
		lRet := lRet .And. oModelF35:LoadValue("F35_TDATE",  SToD((cTabSE1)->E1_EMISSAO)) // Input Date
		lRet := lRet .And. oModelF35:LoadValue("F35_ATBOOK", "1") // Automatic Sales Book?
		lRet := lRet .And. oModelF35:LoadValue("F35_ITDATE", SToD((cTabSE1)->E1_EMISSAO))	// Invoice Typed Date
		lRet := lRet .And. oModelF35:LoadValue("F35_PREFIX", (cTabSE1)->E1_PREFIXO) // Bill Prefix
		lRet := lRet .And. oModelF35:LoadValue("F35_NUM",    (cTabSE1)->E1_NUM)     // Bill Number
		lRet := lRet .And. oModelF35:LoadValue("F35_PARCEL", (cTabSE1)->E1_PARCELA) // Bill Amendment
		lRet := lRet .And. oModelF35:LoadValue("F35_TIPO",   (cTabSE1)->E1_TIPO)    // Bill Type

		// Iterates all over the details returned by select.
		lCanInsLin := oModel:GetModel("F36DETAIL"):CanInsertLine()
		oModel:GetModel("F36DETAIL"):SetNoInsertLine(.F.)

		lRet := lRet .And. oModelF36:LoadValue("F36_ITDATE", SToD((cTabSE1)->E1_EMISSAO))
		lRet := lRet .And. oModelF36:LoadValue("F36_ITEM",   StrZero(1, TamSX3("F36_ITEM")[1]))		
		If !Empty(FwFldGet("F35_CONTRA"))
			lRet := lRet .And. oModelF36:LoadValue("F36_DESC", Posicione("F5R", 2, xFilial("F5R") + FwFldGet("F35_CONTRA"), "F5R_CMNAME"))
		EndIf
		lRet := lRet .And. oModelF36:SetValue("F36_VALUE",  IIf(lConUni, (cTabSE1)->E1_VLCRUZ, (cTabSE1)->E1_VALOR)) // Total Value		
		lRet := lRet .And. oModelF36:LoadValue("F36_DOCKEY", (cTabSE1)->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
		cIniPad := (cTabSE1)->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)
		oModel:GetModel("F36DETAIL"):GetStruct():SetProperty('F36_DOCKEY', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'" + cIniPad + "'"))
		oModel:GetModel("F36DETAIL"):SetNoInsertLine(!lCanInsLin)
	
		// Autofill Bill fields
		lRet := lRet .And. oModelSE1:LoadValue("E1_PREFIXO", (cTabSE1)->E1_PREFIXO)       // Prefix
		lRet := lRet .And. oModelSE1:LoadValue("E1_NUM",     (cTabSE1)->E1_NUM)           // Number
		lRet := lRet .And. oModelSE1:LoadValue("E1_PARCELA", (cTabSE1)->E1_PARCELA)       // Installment
		lRet := lRet .And. oModelSE1:LoadValue("E1_TIPO",    (cTabSE1)->E1_TIPO)          // Type
		lRet := lRet .And. oModelSE1:LoadValue("E1_CLIENTE", (cTabSE1)->E1_CLIENTE)       // Customer
		lRet := lRet .And. oModelSE1:LoadValue("E1_LOJA",    (cTabSE1)->E1_LOJA)          // Branch
		lRet := lRet .And. oModelSE1:LoadValue("E1_EMISSAO", SToD((cTabSE1)->E1_EMISSAO)) // Issue Date
		lRet := lRet .And. oModelSE1:LoadValue("E1_VENCREA", SToD((cTabSE1)->E1_VENCREA)) // Due Date
		lRet := lRet .And. oModelSE1:LoadValue("E1_VALOR",   (cTabSE1)->E1_VALOR)         // Value
		lRet := lRet .And. oModelSE1:LoadValue("E1_SALDO",   (cTabSE1)->E1_SALDO)         // Balance
		lRet := lRet .And. oModelSE1:LoadValue("E1_TXMOEDA", (cTabSE1)->E1_TXMOEDA)       // Exch. Rate
		lRet := lRet .And. oModelSE1:LoadValue("E1_MOEDA",   (cTabSE1)->E1_MOEDA)   	  // Currency
		lRet := lRet .And. oModelSE1:LoadValue("E1_VLCRUZ",  (cTabSE1)->E1_VLCRUZ)        // Value in local currency
	
		// Autofill BankStatement fields
		If IsInCallStack("RU06D07RUS") .OR. IsInCallStack("RU09T02RUS")
			lRet := lRet .And. oModelF5P:LoadValue("F5P_UIDF4C", F4C->F4C_CUUID)  // BS UID
			lRet := lRet .And. oModelF5P:LoadValue("F5P_ADVDOC", F4C->F4C_BNKORD) // Adv Doc Num
			lRet := lRet .And. oModelF5P:LoadValue("F5P_ADVDT" , F4C->F4C_DTPAYM) // Adv Doc Date
			cVatCod := RU09T11012(F4C->F4C_UIDF5Q)
		Else
			cVatCod := RU09T11012((cTabSE1)->E1_F5QUID)			
		EndIf
				
		If !empty(cVatCod)
			lRet := lRet .And. oModelF36:SetValue("F36_VATCOD", cVatCod)
			lRet := lRet .And. oModelF36:LoadValue("F36_VATCD2", Posicione("F31", 1, xFilial("F31") + cVatCod, "F31_OPCODE")) // Ext. VAT Cd.
			lRet := lRet .And. oModelF35:LoadValue("F35_VATCD2", Posicione("F31", 1, xFilial("F31") + cVatCod, "F31_OPCODE")) // Ext. VAT Cds
		else
			lRet := .F.
		EndIf		
		// PLease, do not insert SetValue or LoadValue after this line
		// The final message about if at least one field was not loaded into the model here:
		If !lRet
			Help("", 1, "RU09T11008_FillFieldsAtInclusion05",, STR0014, 1, 0) // "The field is not loaded into the model"
		EndIf
	Else
		Help("", 1, "RU09T11008_FillFieldsAtInclusion04",, STR0015, 1, 0) // "No Accounts receivables found"
	EndIf

	CloseTempTable(cTabSE1)

	RestArea(aAreaF31)
	RestArea(aAreaSA1)
	RestArea(aAreaSE1)
	RestArea(aArea)

Return(oModel)

/*/{Protheus.doc} RU09T11012_ReturnF36VATCODData
Function that returns the F36 VatCode information
@type Static Function
@author Fernando Nicolau
@project MA3 - Russia
@since 10/11/2023
@param  cUid,    Character, Uid code of the bill
@param  cE1TaxR, Character, Tax rate of the bill
@return cVatCod, Character, Vat code
/*/
Static Function RU09T11012_ReturnF36VATCODData(cUid As Character) As Character

	Local cQuery 	As Character
	Local cTabF5R 	As Character
	Local cTabF31   As Character
	Local cVatCod 	As Character

	cQuery		:=""
	cTabF5R		:=""
	cTabF31     :=""
	cVatCod		:=""

	// Check if we have a legal contract associated
	cQuery := "SELECT F5R_VATCOD " 
	cQuery += " FROM " + RetSqlName("F5R") + " F5R, "
	cQuery += " WHERE "
	cQuery += " F5R_FILIAL = '" + xFilial("F5R") + "' AND "
	cQuery += " F5R_UIDF5Q = '" + cUid + "' AND "
	cQuery += " F5R.D_E_L_E_T_ = ' ' "

	cTabF5R := MPSysOpenQuery(ChangeQuery(cQuery))

	DbSelectArea((cTabF5R))
	(cTabF5R)->(DbGoTop())
	If !(cTabF5R)->(Eof())
		cVatCod := (cTabF5R)->F5R_VATCOD
	EndIf
	(cTabF5R)->(DbCloseArea())

	// Final part of extraction VAT code - validation before assignment (F31)
	if !empty(cVatCod)
		cQuery :=""
		cQuery := "SELECT  F31_CODE " 
		cQuery += " FROM " + RetSqlName("F31") + " F31 INNER JOIN " + RetSqlName("F30") + " F30 ON "
		cQuery += " F31.F31_RATE = F30.F30_CODE "
		cQuery += " WHERE "
		cQuery += " F31_FILIAL = '" + xFilial("F31") + "' AND "
		cQuery += " F30_CODE = '" + cVatCod + "' AND "
		cQuery += " F31.D_E_L_E_T_ = ' '  AND F30.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY 1"

		cTabF31 := MPSysOpenQuery(ChangeQuery(cQuery))

		DbSelectArea((cTabF31))
		(cTabF31)->(DbGoTop())
		// VAT code from Legal Contract does not exist in file, so the user will have to fill in during the input 
		If (cTabF31)->(Eof())
			cVatCod := ""
		EndIf
		(cTabF31)->(DbCloseArea())
	EndIf

	if empty(cVatCod)
		Help("", 1, "RU09T11012_ReturnF36VATCODData",, STR0021, 1, 0) // Please fill in the VAT code
	EndIf
	
Return(cVatCod)

/*/{Protheus.doc} RU09T11015_GetLastVATKey
Function that returns the last value from the field F35_KEY.
@type  Static Function
@author Fernando Nicolau
@project MA3 - Russia
@since 03/12/2023
@return nVersion, Numeric, Version Choosed 1- Simplified 2-Complete
/*/
Static Function RU09T11015_GetLastVATKey()

	Local cQuery As Character
	Local cTab As Character
	Local cRet As Character
	Local cProx As Character
	Local aArea As Array

	aArea := GetArea()

	cQuery := "SELECT " + CRLF
	cQuery += "    COALESCE(MAX(F35_KEY), '0') AS F35_KEY " + CRLF
	cQuery += "FROM " + RetSQLName("F35") + " T0 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "	   T0.F35_FILIAL = '" + xFilial("F35") + "' AND " + CRLF
	cQuery += "    T0.D_E_L_E_T_ = ' '"
	cTab := MPSysOpenQuery(ChangeQuery(cQuery))

	DbSelectArea((cTab))
	(cTab)->(DbGoTop())

	While ((cTab)->(!Eof()))
		cProx := Soma1(AllTrim((cTab)->F35_KEY))
		cRet := StrZero(Val(cProx), TamSX3("F35_KEY")[1])

		(cTab)->(DbSkip())
	EndDo

	(cTab)->(DbCloseArea())

	RestArea(aArea)

Return(cRet)

/*{Protheus.doc} RU09T11016_PostValidF35
Prevalidation function for the fields of master model F35.
@type Static Function
@author Fernando Nicolau
@project MA3 - Russia
@since 03/12/2023
@param oModelF35, Object,  F35 table's model
@return lRet,     Logical, If validation is ok
*/
Static Function RU09T11016_PostValidF35(oModelF35 As Object) As Logical

	Local lRet As Logical

	lRet := .T.

	// Inclusion Date must be earlier than Print Date.
	If (oModelF35:GetValue("F35_ITDATE") < oModelF35:GetValue("F35_PDATE"))
		lRet := .F.
		Help("", 1, "RU09T11016_PostValidF3501",, STR0013, 1, 0) // "The VAT Invoice's Inclusion Date cannot be earlier than the Print Date"
	EndIf

Return(lRet)

/*/{Protheus.doc} RU09T11017_ModelSave
Function that saves the model.
@type Static Function
@author Fernando Nicolau
@project MA3 - Russia
@since 15/11/2023
@param oModel, Object,  Model to be saved
@return lRet,  Logical, If saving process is ok
/*/
Static Function RU09T11017_ModelSave(oModel As Object) As Logical

	Local lRet       As Logical
	Local oModelF36  As Object
	Local oModelF35  As Object
	Local nOperation As Numeric

	lRet := .T.

	nOperation := oModel:GetOperation()

	oModelF35 := oModel:GetModel("F35MASTER")
	oModelF36 := oModel:GetModel("F36DETAIL")

	Begin Transaction
		If nOperation == MODEL_OPERATION_INSERT
			lRet := lRet .And. FWFormCommit(oModel)
			lRet := lRet .And. RU09D07Add(oModel) // Creating Outflow VAT Movements

			If (oModel:GetModel("F35MASTER"):GetValue("F35_ATBOOK") == "1")
				lRet := lRet .And. RU09T02007_gravaBook(oModel)
			EndIf

			If !lRet
				DisarmTransaction()
				Help("", 1, "RU09T11017_ModelSave:01",, STR0016, 1, 0) // "Something went in a wrong way during the Sales VAT Invoices commit"
			EndIf
		ElseIf nOperation == MODEL_OPERATION_DELETE
			If Empty(oModelF35:GetValue("F35_BOOK"))
				lRet := lRet .And. FWFormCommit(oModel)
				lRet := lRet .And. RU09D07Del(oModel) // Creating Outflow VAT Movements

				If !lRet
					DisarmTransaction()
					Help("", 1, "RU09T11017_ModelSave:02",, STR0016, 1, 0) // "Something went in a wrong way during the Sales VAT Invoices commit"
				EndIf
			Else
				lRet := .F.
				RU99XFUN05_Help(STR0018) //Action is prohibited. Recorded in the Sales Book
			EndIf
		ElseIf nOperation == MODEL_OPERATION_UPDATE
			lRet := lRet .And. FWFormCommit(oModel)
			lRet := lRet .And. RU09D07Edt(oModel) // Updating Outflow VAT Movements

			If !lRet
				DisarmTransaction()
				Help("", 1, "RU09T11017_ModelSave:01",, STR0016, 1, 0) // "Something went in a wrong way during the Sales VAT Invoices commit"
			EndIf
		EndIf
	End Transaction

Return(lRet)
                   
//Merge Russia R14 
                   
