#include 'PROTHEUS.CH'
#INCLUDE "RU06D07.CH"
#INCLUDE 'PARMTYPE.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D07
Payment Request Routine

@author Eduardo.FLima
@since 20/10/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D07RUS()
	Local aCoors     as Array
	Local aRes       as Array
	Local cIdTotal 	 as Character
	Local cIdBrowse  as Character
	Local oPanelDn   as Object
	Local oPanelUp   as Object
	Local oWin       as Object
	Local oFWFilter  as Object
	Local aTotFlds   as Object
	Local oDlgPrinc  as Object

	Private oBrowseUp   as Object
	Private oBrowseTot  as Object
	Private oTTbTotD07  as Object

	Private cCadastro   as Character // Included because of the MSDOCUMENT routine,
	Private aRotina     as Array     //but MSDOCUMENT needs the arotina and cCastro variables

	Private lDigita     as Logical   //.T.-display entries, .F.-not display
	Private lGeraLanc   as Logical   //.T.-account post OnLine, .F.-OffLine

	Private aFltDflt07  as Array     //Contains intial default filter setting for oBrowseUp

	lDigita    := .F.
	lGeraLanc  := .F.
	aCoors	   := FWGetDialogSize(oMainWnd) // size of a maximized window underneath the main Protheus window
	aRotina	   := {}
	aFltDflt07 := {}
	DbSelectArea('F4C') // start table
	DbSelectArea('F5M') // start table

	Define MsDialog oDlgPrinc Title OemToAnsi(STR0001) STYLE DS_MODALFRAME  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4]  OF oMainWnd Pixel  //Bank Statements
	oDlgPrinc:lMaximized := .T.
// Create container where panels will be situated
	oWin        := FWFormContainer():New(oDlgPrinc)
	cIdBrowse   := oWin:CreateHorizontalBox( 90 ) // Space that we reserve to the Browse
	cIdTotal    := oWin:CreateHorizontalBox( 10 ) // Space that we reserve to the Totals

	oWin:Activate(oDlgPrinc, .F.)

// Create panels where browses will be created
	oPanelUp    := oWin:GeTPanel(cIdBrowse) //Panel where we will create the Browse
	oPanelDn    := oWin:GeTPanel(cIdTotal) //Panel where we will create the Total
	oBrowseUp   := BrowseDef()
	oBrowseUp:SetOwner(oPanelUp)

	oBrowseTot := FWMBrowse():New()
	aTotFlds := {{"BEGBAL", STR0033 },;
		{"INBAL" , STR0034 },;
		{"OUTBAL", STR0035 },;
		{"ENDBAL", STR0036 } }
	aRes := RU06D07813_CreateTmpTabForTotBrowse(aTotFlds)
	oTTbTotD07 := aRes[1]
	oBrowseTot:SetAlias(oTTbTotD07:GetAlias())
	aFltDflt07 := RU06D07811_Filter(Pergunte("RUD607",.T., STR0018,.F.))
	If !Empty(aFltDflt07[1])
		oBrowseUp:SetFilterDefault(aFltDflt07[1])
	EndIf
	oBrowseTot:SetFields(RU06D0757_TotalFields(oTTbTotD07:GetAlias(),aRes[2]))
	oBrowseTot:SetUseFilter(.F.)
	oBrowseTot:SetUseCaseFilter(.F.)
	oBrowseTot:SetAmbiente(.F.)
	oBrowseTot:SetMenuDef("")
	oBrowseTot:SetIgnoreARotina(.T.)
	oBrowseTot:SetWalkThru(.F.)
	oBrowseTot:SetOwner(oPanelDn)
	oBrowseTot:DisableReport()
	oBrowseTot:DisableDetails(.T.)
	oBrowseTot:SetVScroll(.F.)

	oBrowseUp:Activate()
	oFWFilter := FWFilter():New(oBrowseUp)

	RU06D0758_QueryTotal()

	oBrowseTot:Activate()

//Block code which will be executed after applying User filter
	oBrowseUp:oFWFilter:SetValidExecute({|| RU06D0758_QueryTotal(),;
		oBrowseTot:Refresh()  })
//Block code which will be executed after executing 
//the operation defined for the button
	oBrowseUp:SetAfterExec({|| RU06D0758_QueryTotal(),;
		oBrowseTot:Refresh()  ,;
		RU06D07812_Unlock()   })
//Load the last selected values from pergunte without show in screen 
//invisible to the user
	RU06D07810_LoadAccountParametrization(.F.)
//Set that when the user press the key F12 we will open pergunte to
//the user choose the accounting way
	SetKey(VK_F12, {|| RU06D07810_LoadAccountParametrization()})

	Activate MsDialog oDlgPrinc Center
	oTTbTotD07:Delete()

Return (Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef 
Browse definition.
@author Eduardo.FLima
@since  20/10/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()

	Local oBrowse as Object

	oBrowse := FWLoadBrw("RU06D07")
	oBrowse:SetDescription(STR0002)	// Bank Statements
	oBrowse:SetMenuDef('RU06D07')
	oBrowse:DisableDetails()
	oBrowse:SetAlias('F4C')
	oBrowse:SetProfileID('1')
	oBrowse:ForceQuitButton()
	oBrowse:SetCacheView(.F.)

Return (oBrowse)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Definition.
@author natalia.khozyainova
@since 17/10/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()

	Local aRotina	AS ARRAY
	Local aAddOpc as Array

	aRotina :=  FWLoadMenuDef("RU06D07")
	AADD(aRotina,{STR0019, "RU06D0755_RUSResetFilterBtn()", 0, 3, 0, Nil})

	aAddOpc := {{STR0146, "RU06D07815()", 0, 2, 0, Nil},;   //"Track"
	{STR0008, "RU06D07816()", 0, 3, 0, Nil},; 	//"Add"
	{STR0009, "RU06D07817()", 0, 4, 0, Nil},; 	//"Edit"
	{STR0010, "RU06D07818()", 0, 5, 0, Nil}} 	//Delete

	AADD(aRotina, {STR0235, aAddOpc, 0, 3, 0, Nil}) //VAT Invoice

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.
@author Eduardo.FLima
@since 17/10/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()

	Local oModel as object

	oModel:= FwLoadModel("RU06D07")
	oModel:SetDescription(STR0002) // Bank Statements

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.
@author Eduardo.FLima
@since 17/10/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Return (FWLoadView("RU06D07"))


/*/{Protheus.doc} RU06D0755_RUSResetFilterBtn
Reset Filter Button
@private aFltDflt07, oBrowseUp, oBrowseTot
@author natalia.khozyainova
@since 23/11/2018
@edit  astepanov 05/April/2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0755_RUSResetFilterBtn()

	If Pergunte("RUD607",.T., STR0018,.F.)
		aFltDflt07 := RU06D07811_Filter(.T.)
		oBrowseUp:CleanFilter()
		If !Empty(aFltDflt07[1])
			oBrowseUp:SetFilterDefault(aFltDflt07[1])
		EndIf
		oBrowseUp:ExecuteFilter(.T.)
		oBrowseUp:GetOwner():Refresh()
	EndIf

Return (Nil)

/*/{Protheus.doc} RU06D0757_TotalFields
This function returns Field structure of Total browse
@param 
    Character cAlias alias to temporary table
    Array    aFields {{FieldName,FieldType,FldTamanho,
                       FldDecimal, FldPicture, 
                       FldTitle}...}
@author alexandra.menyashina
@since 12/12/2018
@edit  astepanov  04/April/2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0757_TotalFields(cAlias, aFields)

	Local aRet      as Array
	Local nX        as Numeric
	Local bBlk      as Block

	aRet  := {}
	For nX := 1 To Len(aFields)
		bBlk  := &("{|| "+cAlias+"->"+aFields[nX][1]+"}")
		AADD(aRet, {aFields[nX][6] ,; //[01] Column title
		bBlk           ,; //[02] Data load code-block
		aFields[nX][2] ,; //[03] Data type
		aFields[nX][5] ,; //[04] Mask
		0              ,; //[05] Alignment (0 = Centered, 1 = Left or 2 = Right)
		aFields[nX][3] ,; //[06] Size
		aFields[nX][4] ,; //[07] Decimal
		})
	Next nX

Return aRet

/*/{Protheus.doc} RU06D0758_QueryTotal
This function runs Query for Total and insert
result to temporary table which used by oBrowseTot
@return   Logical  .T.
@private oBrowseUp, aFltDflt07
@author alexandra.menyashina
@edit   astepanov 31 Jan 2020, 04 April 2020
@since 12/12/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0758_QueryTotal()
	Local cQuery     as Character
	Local cUsrFilter as Character
	Local cWhereSE8  as Character
	Local cWhereF4C  as Character
	Local cQr        as Character
	Local cAlias     as Character
	Local aFilters   as Array
	Local aArea      as Array
	Local nX         as Numeric
	Local nStat      as Numeric

	// Get default and user filters
	aFilters := IIF(ValType(oBrowseUp) == "O" .AND.  oBrowseUp:FwFilter() != Nil,;
		oBrowseUp:FwFilter():GetFilter(), {}                         )
	cUsrFilter  := ""
	For nX:=1 to Len(aFilters) // convert standard filters expressions to SQL format
		If !Empty(aFilters[nX][3])
			cUsrFilter += " AND "
			If SubStr(aFilters[nX][3], 1, 1) == "#"
				cUsrFilter += &(SubStr(aFilters[nX][3],2,Len(aFilters[1][3])-2))
			Else
				cUsrFilter += aFilters[nX][3]
			EndIf
		EndIf
	Next nX
	// Create where conditions for data selection
	// current E8_FILIAL is shared, so we can't filter
	// data in SE8 by filial, so current SE8 saldos we can get only
	// by all filials. If it will be private we should
	// transfer E8_FILIAL condition to If !(Empty(aFltDflt07[1]))
	// condition, and after that we can get correct SE8 saldo by filial
	cWhereSE8 := " WHERE E8_FILIAL  = '"+xFilial("SE8")+"' "
	cWhereSE8 += " AND D_E_L_E_T_ = ' ' "
	cWhereF4C := " WHERE "
	If !(Empty(aFltDflt07[1]))
		cWhereSE8 += " AND E8_DTSALAT < '"+aFltDflt07[5]+"' AND "
		cWhereSE8 += " E8_BANCO  >= '"+aFltDflt07[7]+"'     AND "
		cWhereSE8 += " E8_BANCO  <= '"+aFltDflt07[8]+"'         "
		If !Empty(aFltDflt07[9])
			cWhereSE8 += " AND "
			cWhereSE8 += "E8_MOEDA = '"+aFltDflt07[9]+"'        "
		EndIf
		cWhereF4C += aFltDflt07[2] + " AND "
	Else
		cWhereSE8 += " AND E8_DTSALAT < '"+"00000000"+"' "
	EndIf
	// F4C_STATUS   1 2 3 4 5 6 7
	// F4C_VALUE    + + 0 + + 0 +
	cWhereF4C += " F4C_STATUS IN ('1','2','4','5','7') AND      "
	cWhereF4C += " D_E_L_E_T_ = ' ' " + cUsrFilter

	// this query recieves BEGBAL, INBAL, OUTBAL AND ENDBAL from
	// F4C and SE8 tables. BEGBAL we get from SE8 table, we can
	// get BEGBAL from F4C table by calculating overturns
	// but it will be bad way.
	// formula from consultant:
	// BEGBAL - from SE8
	// INBAL and OUTBAL from F4C
	// ENDBAL = BEGBAL + INBAL - OUTBAL
	// So we group values by currencies, but according to strange
	// requirement from consultant we should summarize values in
	// different currencies. I don't know how we can add goats
	// to cows, but anyway you can apply minimum changes to this
	// query and get values in different currencies
	// exclude groupings:  GROUP BY TB2.MOEDA  and
	// GROUP BY SE8.E8_MOEDA and you will recieve values in
	// different currencies
	// We use UNION ALL, so field order is very important.
	cQuery := "SELECT SUM(BEGBAL) BEGBAL,                       "
	cQuery += "       SUM(INBAL)  INBAL,                        "
	cQuery += "       SUM(OUTBAL) OUTBAL,                       "
	cQuery += "       SUM(ENDBAL) ENDBAL                        "
	cQuery += "FROM (                                           "
	//subquery for getting INBAL and OUTBAL from F4C table
	cQuery += " SELECT COALESCE(SUM(TB3.BEGBAL),0) BEGBAL,      "
	cQuery += "        COALESCE(SUM(TB3.INBAL) ,0)  INBAL,      "
	cQuery += "        COALESCE(SUM(TB3.OUTBAL),0) OUTBAL,      "
	cQuery += "        COALESCE(SUM(TB3.ENDBAL),0) ENDBAL       "
	cQuery += " FROM (                                          "
	cQuery += "   SELECT CAST(TB2.MOEDA  AS NUMERIC) MOEDA,     "
	cQuery += "          0                           BEGBAL,    "
	cQuery += "          SUM(TB2.INBAL)              INBAL,     "
	cQuery += "          SUM(TB2.OUTBAL)             OUTBAL,    "
	cQuery += "          SUM(TB2.INBAL) -                       "
	cQuery += "          SUM(TB2.OUTBAL)             ENDBAL     "
	cQuery += "   FROM (                                        "
	cQuery += "     SELECT  F4C_CURREN                  MOEDA,  "
	cQuery += "             CASE WHEN F4C_OPER = '1'            "
	cQuery += "                  THEN F4C_VALUE                 "
	cQuery += "                  ELSE 0                         "
	cQuery += "             END                         INBAL,  "
	cQuery += "             CASE WHEN F4C_OPER = '2'            "
	cQuery += "                  THEN F4C_VALUE                 "
	cQuery += "                  ELSE 0                         "
	cQuery += "             END                         OUTBAL  "
	cQuery += "     FROM " + RetSQLName("F4C") + "              "
	cQuery +=       cWhereF4C
	cQuery += "        ) TB2                                    "
	cQuery += "   GROUP BY TB2.MOEDA                            "
	cQuery += "      ) TB3                                      "
	//-----------------------------------------------------------
	cQuery += " UNION ALL                                       "
	//-----------------------------------------------------------
	//subquery for getting BEGBAL from SE8
	cQuery += " SELECT COALESCE(SUM(TB4.BEGBAL),0) BEGBAL,      "
	cQuery += "        COALESCE(SUM(TB4.INBAL) ,0)  INBAL,      "
	cQuery += "        COALESCE(SUM(TB4.OUTBAL),0) OUTBAL,      "
	cQuery += "        COALESCE(SUM(TB4.ENDBAL),0) ENDBAL       "
	cQuery += " FROM (                                          "
	cQuery += "   SELECT CAST(SE8.E8_MOEDA AS NUMERIC) MOEDA,   "
	cQuery += "          SUM(SE8.E8_SALATUA)           BEGBAL,  "
	cQuery += "          0                             INBAL,   "
	cQuery += "          0                             OUTBAL,  "
	cQuery += "          SUM(SE8.E8_SALATUA)           ENDBAL   "
	cQuery += "   FROM   "+RetSQLName("SE8")+ " SE8             "
	cQuery += "   INNER JOIN (                                  "
	cQuery += "                SELECT E8_FILIAL,                "
	cQuery += "                       E8_BANCO,                 "
	cQuery += "                       E8_AGENCIA,               "
	cQuery += "                       E8_CONTA,                 "
	cQuery += "                       E8_MOEDA,                 "
	cQuery += "                       MAX(E8_DTSALAT) E8_DTSALAT"
	cQuery += "                FROM "+RetSQLName("SE8")+"       "
	cQuery +=                  cWhereSE8
	cQuery += "                GROUP BY E8_FILIAL,  E8_BANCO,   "
	cQuery += "                         E8_AGENCIA, E8_CONTA,   "
	cQuery += "                         E8_MOEDA                "
	cQuery += "              ) TB1                              "
	cQuery += "   ON ( SE8.E8_FILIAL  = TB1.E8_FILIAL           "
	cQuery += "    AND SE8.E8_BANCO   = TB1.E8_BANCO            "
	cQuery += "    AND SE8.E8_AGENCIA = TB1.E8_AGENCIA          "
	cQuery += "    AND SE8.E8_CONTA   = TB1.E8_CONTA            "
	cQuery += "    AND SE8.E8_MOEDA   = TB1.E8_MOEDA            "
	cQuery += "    AND SE8.E8_DTSALAT = TB1.E8_DTSALAT          "
	cQuery += "    AND SE8.D_E_L_E_T_ = ' '           )         "
	cQuery += "   GROUP BY SE8.E8_MOEDA                         "
	cQuery += "      ) TB4                                      "
	cQuery += ") BLN                                            "
	cQuery := ChangeQuery(cQuery)
	aArea  := GetArea()
	If (oTTbTotD07:GetAlias())->(LastRec()) == 0
		cQr :=    " INSERT INTO " + oTTbTotD07:GetRealName() + "  "+;
			" (BEGBAL, INBAL, OUTBAL, ENDBAL) "        + cQuery
		nStat := TCSqlExec(cQr)
	Else
		cAlias := MPSysOpenQuery(cQuery)
		DBSelectArea(cAlias)
		(cAlias)->(DBGoTop())
		While !Eof()
			cQr := " UPDATE "  + oTTbTotD07:GetRealName() + " "
			cQr += " SET BEGBAL = " + cValToChar((cAlias)->BEGBAL) + ", "
			cQr += "     INBAL  = " + cValToChar((cAlias)->INBAL ) + ", "
			cQr += "     OUTBAL = " + cValToChar((cAlias)->OUTBAL) + ", "
			cQr += "     ENDBAL = " + cValToChar((cAlias)->ENDBAL) + "  "
			nStat := TCSqlExec(cQr)
			(cAlias)->(DBSkip())
		EndDo
		(cAlias)->(DBCloseArea())
	EndIf
	(oTTbTotD07:GetAlias())->(DBGoTop())
	RestArea(aArea)
Return (.T.)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07810_LoadAccountParametrization

Function used to load the parametrization of accounting post

@param       Logical          lShow   : flag that inform if we must show the ask screen
                                        to the user, if it is .F. we only load the values 
                                        stored previously in private variables
@return      Logical          lRet
@private     lGeraLanc, nBSPos, lDigita 
@example     
@author      astepanov
@since       September/23/2019
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07810_LoadAccountParametrization(lShow)

    Local    lRet       As Logical
    Local    lConfirm   As Logical
    Local    nLenPerg   As Numeric
    Local    nX         As Numeric
    Local    cPergunta  As Character
    Local    aParFilter As Array
    Default  lShow      := .T.

    lRet       := .F.
    lConfirm   := .F.
    aParFilter := {}
    //First we need to save the values related to the Filter pergunte, after we set the
    //private variables we need to set it back
    nLenPerg := FGetLenPgt("RUD607") //Returns # of questns from the question group in use
    //Store in an array the values of this pergunte
    For nX := 1 To nLenPerg                                              
        cPergunta := "mv_par" + StrZero(nX,2)
        AADD(aParFilter, &(cPergunta))
    Next nX
    //Access the pergunte related to the accounting post and according to the variable lShow
    //show or not the choices screen
    lConfirm := Pergunte("RUD67CTB", lShow, STR0168) //Accounting configurations
    If !lShow .OR. lConfirm
        //Define variables , if choise screen is non-visible we load values, otherwise
        //we load them only if the user confirmed your own choice
        lGeraLanc   := (MV_PAR01 == 1)
        lDigita     := (MV_PAR03 == 1)
    EndIf
    //Restore mv_parXX
    For nX := 1 To nLenPerg
        cPergunta    := "mv_par" + StrZero(nX,2)
        &(cPergunta) := aParFilter[nX]
    Next nX

    lRet := .T.
    
Return (lRet) /*-------------------------------------RU06D07810_LoadAccountParametrization*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07811_Filter

Function used to load intitial default filter data according to Pergunta RUD607

@param      Logical          lOk    : .T. - if we pressed in pergunte OK, .F. - if we 
                                      pressed Cancel
@return     Array            aRet  [cFltADVPL, cFltSQL, cFilialBeg, cFilialEnd, cDtTranBeg, 
                                    cDtTranEnd, cBnkCodBeg, cBnkCodEnd, cCurren           ]
@example     
@author      aVelmoznaia
@since       March/11/2020
@edit        astepanov  April/03/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07811_Filter(lOk)

    Local aRet       As Array
    Local cFltADVPL  As Character
    Local cFltSQL    As Character
    Local cAND       As Character
    Local cFilialBeg As Character
    Local cFilialEnd As Character
    Local cDtTranBeg As Character
    Local cDtTranEnd As Character
    Local cBnkCodBeg As Character
    Local cBnkCodEnd As Character
    Local cCurren    As Character

    Default  lOk     := .F.
    aRet      := {}
    cFltADVPL := "" //default filter in ADVPL
    cFltSQL   := "" //default filter in SQL
    cFilialBeg := IIF(Empty(MV_PAR01)                           ,;
                      Replicate(" ",TamSX3("F4C_FILIAL")[1])    ,;
                      PADR(MV_PAR01,TamSX3("F4C_FILIAL")[1]," ") )
    cFilialEnd := IIF(Empty(MV_PAR02)                           ,;
                      Replicate("z",TamSX3("F4C_FILIAL")[1])    ,;
                      PADR(MV_PAR02,TamSX3("F4C_FILIAL")[1]," ") )
    cDtTranBeg := IIF(Empty(MV_PAR03)                           ,;
                      "00000000"                                ,;
                      DTOS(MV_PAR03)                             )
    cDtTranEnd := IIF(Empty(MV_PAR04)                           ,;
                      "99991231"                                ,;
                      DTOS(MV_PAR04)                             )
    cBnkCodBeg := IIF(Empty(MV_PAR05)                           ,;
                      Replicate(" ",TamSX3("E8_BANCO")[1])      ,;
                      PADR(MV_PAR05,TamSX3("E8_BANCO")[1], " ")  )
    cBnkCodEnd := IIF(Empty(MV_PAR06)                           ,;
                      Replicate("z",TamSX3("E8_BANCO")[1])      ,;
                      PADR(MV_PAR06,TamSX3("E8_BANCO")[1], " ")  )
    // at this moment E8_MOEDA looks like " 1" , but not "01"
    // should be changed if currency representation will be
    // changed in E8_MOEDA
    cCurren    := IIF(Empty(MV_PAR07)                           ,;
                      Replicate(" ",TamSX3("E8_MOEDA")[1])      ,;
                      PADL(AllTrim(Str(Val(MV_PAR07))),;
                                    TamSX3("E8_MOEDA")[1], " ")  )
    If lOk //was pressed Ok in Pergunte
        cAND    := " .AND. "
        If !(Empty(MV_PAR01))
            cFltADVPL += " F4C_FILIAL >=       '" + cFilialBeg + "' "
            cFltADVPL += cAND
        EndIf
        If !(Empty(MV_PAR02))
            cFltADVPL += " F4C_FILIAL <=       '" + cFilialEnd + "' "
            cFltADVPL += cAND  
        EndIf
        If !(Empty(MV_PAR03))
            cFltADVPL += " DTOS(F4C_DTTRAN) >= '" + cDtTranBeg + "' "
            cFltADVPL += cAND        
        EndIf
        If !(Empty(MV_PAR04))
            cFltADVPL += " DTOS(F4C_DTTRAN) <= '" + cDtTranEnd + "' "
            cFltADVPL += cAND      
        EndIf
        If !(Empty(MV_PAR07))
            cFltADVPL += " F4C_CURREN = '" + MV_PAR07 + "'          "
            cFltADVPL += cAND
        EndIf
        //If F4C_OPER = Outflow, filter by F4C_BNKPAY
        //If F4C_OPER = Inflow, filter by F4C_BNKREC
        cFltADVPL += " ("
        cFltADVPL += "  (F4C_OPER = '2'                         "
        cFltADVPL +=     cAND
        cFltADVPL += "   F4C_BNKPAY >= '" + cBnkCodBeg  + "'    "
        cFltADVPL +=     cAND
        cFltADVPL += "   F4C_BNKPAY <= '" + cBnkCodEnd  + "' )  "
        //---
        cFltADVPL += " .OR. "
        //--
        cFltADVPL += "  (F4C_OPER = '1'                         "
        cFltADVPL +=     cAND
        cFltADVPL += "   F4C_BNKREC >= '" + cBnkCodBeg  + "'    "
        cFltADVPL +=     cAND
        cFltADVPL += "   F4C_BNKREC <= '" + cBnkCodEnd  + "' )  "
        cFltADVPL += ") "
        cFltADVPL += cAND 
        If !Empty(cFltADVPL)
            cFltADVPL := SubStr(cFltADVPL,1,Len(cFltADVPL)-Len(cAND))
            //be careful with conversion
            cFltSQL   := StrTran(cFltADVPL," .OR. ", " OR ",/*nStart*/,/*nCount*/)
            cFltSQL   := StrTran(cFltSQL," .AND. ", " AND ",/*nStart*/,/*nCount*/)
            cFltSQL   := StrTran(cFltSQL," DTOS(F4C_DTTRAN) "," F4C_DTTRAN "     )
        EndIf
    EndIf
    AADD(aRet, cFltADVPL )
    AADD(aRet, cFltSQL   )
    AADD(aRet, cFilialBeg)
    AADD(aRet, cFilialEnd)
    AADD(aRet, cDtTranBeg)
    AADD(aRet, cDtTranEnd)
    AADD(aRet, cBnkCodBeg)
    AADD(aRet, cBnkCodEnd)
    AADD(aRet, cCurren   )

Return (aRet) /*---------------------------------------------------------RU06D07811_Filter*/

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07812_Unlock
@return      Logical      .T. // this function temporary solves temporary problem with 
                              // mBrowse()
@example     
@author      astepanov
@since       April/04/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07812_Unlock()
    //Three lines below included because Browse create strange situation:
    //it locks current record but don't unlock it.
    //So this is temporary fix for unlocking current line in Browse,
    //until real problem will be found.
    If Len(("F4C")->(DBRLockList())) > 0 
        F4C->( MsUnlock() )
    EndIf
    //Line below fix F12 key trouble for Browse
    SetKey(VK_F12, {|| RU06D07810_LoadAccountParametrization()})

Return (.T.) /*----------------------------------------------------------RU06D07812_Unlock*/


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RU06D07813_CreateTmpTabForTotBrowse
Function returns clear temporary table for oBrowseTot
@param       Array       aTotFlds {{"BEGBAL","Tit"}, {"INBAL","Tit"}, 
                                  {"OUTBAL","Tit"}, {"ENDBAL","Tit"}...}
@return      Array       {Object oTmpTab, Array aFields} 
@example     
@author      astepanov
@since       April/04/2020
@version     1.0
@project     MA3
@see         None
//---------------------------------------------------------------------------------------/*/
Function RU06D07813_CreateTmpTabForTotBrowse(aTotFlds)
    
    Local oTmpTab    as Object
    Local aFields    as Array
    Local nX         as Numeric
    oTmpTab := FWTemporaryTable():New(CriaTrab(,.F.))
    aFields := {}
    For nX := 1 To Len(aTotFlds)
        AADD(aFields,{ aTotFlds[nX][1],;
                       GetSX3Cache("F4C_VALUE","X3_TIPO"),;
                       GetSX3Cache("F4C_VALUE","X3_TAMANHO"),;
                       GetSX3Cache("F4C_VALUE","X3_DECIMAL"),;
                       GetSX3Cache("F4C_VALUE","X3_PICTURE"),;
                       aTotFlds[nX][2]                       })
    Next nX
    oTmpTab:SetFields(aFields)
    oTmpTab:Create()

Return ({oTmpTab,aFields}) /*--------------------------RU06D07813_CreateTmpTabForTotBrowse*/

/*/{Protheus.doc} RU06D07814_ValidatDateFieldsInPergRUD607
@type           Function
@description    Function of validation of fields with dates "Date from" and "Date to" in pergunt RUD607.
                The "Date From" field value must not exceed the "Date To" value.
@author         Nikita.Lysenko
@since          08/04/2021
@version        1.0
@project        MA3 - Russia
/*/
Function RU06D07814_ValidatDateFieldsInPergRUD607()
    Local lRet as logical

    If Empty(MV_PAR04)  //Checking for compliance with the field requirements: "Date from" <= "Date to"
        lRet := .T.
    Else
        lRet := MV_PAR03 <= MV_PAR04
    EndIf

    If .Not. lRet //The display of an informational message depends on the field on which the cursor is positioned.
        RU99XFUN05_Help(STR0209)
    EndIf
Return lRet

/*/{Protheus.doc} RU06D07815_TrackVATInvoice
Tracks a VAT Invoice
@type Function
@author Fernando Nicolau
@since 15/12/2023
@version version
/*/
Function RU06D07815_TrackVATInvoice()

	// Working areas
	Local aArea As Array
	Local aAreaF4C As Array
	Local aAreaF5M As Array
	Local aAreaSE1 As Array
	Local aAreaSE2 As Array

	Local cTitle As Character
	Local cHelp  As Character

	Local oModel As Object

	Local cCustomer As Character
	Local cBranch As Character
	Local cSupplier As Character

	cTitle := ""
	cHelp  := ""

	cCustomer := ""
	cBranch := ""
	cSupplier := ""

	aArea := GetArea()
	aAreaF4C := F4C->(GetArea())
	aAreaF5M := F5M->(GetArea())
	aAreaSE1 := SE1->(GetArea())
	aAreaSE2 := SE2->(GetArea())

	DbSelectArea("F4C")
	F4C->(DbSetOrder(1))

	DbSelectArea("F5M")
	F5M->(DbSetOrder(1))

	If RU06D07819()

		If F4C->F4C_OPER == "1" //Inflow

			If RU06D07820()
				FWExecView(STR0146, "RU09T11", MODEL_OPERATION_VIEW,, {|| .T.})
			Else

				cTitle := "RU06D07815_TrackVATInvoice"
				cHelp := STR0238 + CRLF + STR0239 //"There is no Inflow VAT Invoice for the Receipt in Advance created at this Bank Statement. | Would you like to create the Inflow VAT Invoice?"

				If IsBlind() .Or. MsgYesNo(cHelp, cTitle)

					cCustomer := SE1->E1_CLIENTE
					cBranch   := SE1->E1_LOJA

					// If it is everything OK, must to show a window to the end user to continue to add a Sales VAT Invoice.
					oModel := FwLoadModel("RU09T11")
					oModel:SetOperation(MODEL_OPERATION_INSERT)
					oModel:SetDescription(STR0236) //Advances Received
					oModel:Activate()
					oModel := RU09T11008(oModel, , , cCustomer, cBranch)
					oModel:GetModel("F36DETAIL"):SetNoInsertLine(.F.)
					oModel:GetModel("SE1DETAIL"):SetNoInsertLine(.T.)
					FwExecView(STR0008, "RU09T11", MODEL_OPERATION_INSERT,, {|| .T.},,,,,,, oModel) // "Add"

				EndIf

			EndIf

		ElseIf F4C->F4C_OPER == "2" //Outflow

			If RU06D07820()
				FWExecView(STR0146, "RU09T10", MODEL_OPERATION_VIEW,, {|| .T.})
			Else

				cTitle := "RU06D07815_TrackVATInvoice"
				cHelp := STR0240 + CRLF + STR0241 //"There is no Outflow VAT Invoice for the Payment in Advance created at this Bank Statement. | Would you like to create the Outflow VAT Invoice?"

				If IsBlind() .Or. MsgYesNo(cHelp, cTitle)

					cSupplier := SE2->E2_FORNECE
					cBranch   := SE2->E2_LOJA

					// If it is everything OK, must to show a window to the end user to continue to add a Sales VAT Invoice.
					oModel := FwLoadModel("RU09T10")
					oModel:SetOperation(MODEL_OPERATION_INSERT)
					oModel:SetDescription(STR0237) //Advances Payment
					oModel:Activate()
					oModel := RU09T10008(oModel, , , cSupplier, cBranch)
					oModel:GetModel("F38detail"):SetNoInsertLine(.F.)
					oModel:GetModel("SE2detail"):SetNoInsertLine(.T.)
					FwExecView(STR0008, "RU09T10", MODEL_OPERATION_INSERT,, {|| .T.},,,,,,, oModel) // "Add"

				EndIf

			EndIf

		EndIf

	Else

		cTitle := "RU06D07815_TrackVATInvoice"
		cHelp := Iif(F4C->F4C_OPER == "1", STR0242, STR0243) //There is no Receipt/Payment in Advance for the selected document

		Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,,)

	EndIf

	RestArea(aAreaSE2)
	RestArea(aAreaSE1)
	RestArea(aAreaF5M)
	RestArea(aAreaF4C)
	RestArea(aArea)

Return()

/*/{Protheus.doc} RU06D07816_AddVATInvoice
Add a VAT Invoice
@type Function
@author Fernando Nicolau
@since 15/12/2023
@version version
/*/
Function RU06D07816_AddVATInvoice()

	// Working areas
	Local aArea As Array
	Local aAreaF4C As Array
	Local aAreaF5M As Array
	Local aAreaSE1 As Array
	Local aAreaSE2 As Array

	Local cTitle As Character
	Local cHelp  As Character

	Local oModel As Object

	Local cCustomer As Character
	Local cBranch As Character
	Local cSupplier As Character

	cTitle := ""
	cHelp  := ""

	cCustomer := ""
	cBranch := ""
	cSupplier := ""

	aArea := GetArea()
	aAreaF4C := F4C->(GetArea())
	aAreaF5M := F5M->(GetArea())
	aAreaSE1 := SE1->(GetArea())
	aAreaSE2 := SE2->(GetArea())

	DbSelectArea("F4C")
	F4C->(DbSetOrder(1))

	DbSelectArea("F5M")
	F5M->(DbSetOrder(1))

	If RU06D07819()

		If F4C->F4C_OPER == "1" //Inflow

			If RU06D07820()
				cTitle := "RU06D07816_AddVATInvoice"
				cHelp := STR0244 + F35->F35_DOC + STR0245 + CRLF + ; // "A Inflow VAT Invoice number: " + F35->F35_DOC + " was found for the Receipt in Advance created by selected Bank Statement." + CRLF + ;
					STR0246 //"Would you like to view this Inflow VAT Invoice??"

				If IsBlind() .Or. MsgYesNo(cHelp, cTitle)
					FWExecView(STR0008, "RU09T11", MODEL_OPERATION_VIEW,, {|| .T.})
				EndIf
			Else

				cCustomer := SE1->E1_CLIENTE
				cBranch   := SE1->E1_LOJA

				// If it is everything OK, must to show a window to the end user to continue to add a Sales VAT Invoice.
				oModel := FwLoadModel("RU09T11")
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:SetDescription(STR0236) // "Receives in Advance"
				oModel:Activate()
				oModel := RU09T11008(oModel, , , cCustomer, cBranch)
				oModel:GetModel("F36DETAIL"):SetNoInsertLine(.F.)
				oModel:GetModel("SE1DETAIL"):SetNoInsertLine(.T.)
				FwExecView(STR0008, "RU09T11", MODEL_OPERATION_INSERT,, {|| .T.},,,,,,, oModel) // "Add"

			EndIf

		ElseIf F4C->F4C_OPER == "2" //Outflow

			If RU06D07820()
				cTitle := "RU06D07816_AddVATInvoice"
				cHelp := STR0247 + F37->F37_DOC + STR0248 + CRLF + ; // "A Outflow VAT Invoice number: " + F37->F37_DOC + " was found for the Payment in Advance created by selected Bank Statement." + CRLF + ;
					STR0249 //"Would you like to view this Outflow VAT Invoice??"

				If IsBlind() .Or. MsgYesNo(cHelp, cTitle)
					FWExecView(STR0008, "RU09T10", MODEL_OPERATION_VIEW,, {|| .T.})
				EndIf
			Else

				cSupplier := SE2->E2_FORNECE
				cBranch   := SE2->E2_LOJA

				// If it is everything OK, must to show a window to the end user to continue to add a Sales VAT Invoice.
				oModel := FwLoadModel("RU09T10")
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:SetDescription(STR0237) // "Payments in Advance"
				oModel:Activate()
				oModel := RU09T10008(oModel, , , cSupplier, cBranch)
				oModel:GetModel("F38detail"):SetNoInsertLine(.F.)
				oModel:GetModel("SE2detail"):SetNoInsertLine(.T.)
				FwExecView(STR0008, "RU09T10", MODEL_OPERATION_INSERT,, {|| .T.},,,,,,, oModel) // "Add"

			EndIf

		EndIf

	Else

		cOper  := Iif(F4C->F4C_OPER == "1", STR0242, STR0243) //There is no Receipt/Payment in Advance for the selected document
		cOper2 := Iif(F4C->F4C_OPER == "1", STR0250, STR0251) //It will be impossible to create a Inflow/Outflow VAT Document for this Bank Statement.

		cTitle := "RU06D07816_AddVATInvoice"
		cHelp := cOper + CRLF + cOper2

		Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,,)

	EndIf

	RestArea(aAreaSE2)
	RestArea(aAreaSE1)
	RestArea(aAreaF5M)
	RestArea(aAreaF4C)
	RestArea(aArea)

Return()

/*/{Protheus.doc} RU06D07817_EditVATInvoice
Edits a VAT Invoice
@type Function
@author Fernando Nicolau
@since 15/12/2023
@version version
/*/
Function RU06D07817_EditVATInvoice()

	// Working areas
	Local aArea As Array
	Local aAreaF4C As Array
	Local aAreaF5M As Array
	Local aAreaSE1 As Array
	Local aAreaSE2 As Array

	Local cTitle As Character
	Local cHelp  As Character

	cTitle := ""
	cHelp  := ""

	aArea := GetArea()
	aAreaF4C := F4C->(GetArea())
	aAreaF5M := F5M->(GetArea())
	aAreaSE1 := SE1->(GetArea())
	aAreaSE2 := SE2->(GetArea())

	DbSelectArea("F4C")
	F4C->(DbSetOrder(1))

	DbSelectArea("F5M")
	F5M->(DbSetOrder(1))

	If RU06D07819()

		If RU06D07820()

			If F4C->F4C_OPER == "1" //Inflow
				FWExecView("", "RU09T11", MODEL_OPERATION_UPDATE,, {|| .T.})
			ElseIf F4C->F4C_OPER == "2" //Outflow
				FWExecView("", "RU09T10", MODEL_OPERATION_UPDATE,, {|| .T.})
			EndIf
            
		Else

			cOper  := Iif(F4C->F4C_OPER == "1", STR0252, STR0253)

			cTitle := "RU06D07817_EditVATInvoice"
			cHelp := cOper //Inflow/Outflow VAT not found for the selected Bank Statement.

			Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,,)

		EndIf

	Else

		cOper  := Iif(F4C->F4C_OPER == "1", STR0242, STR0243) //There is no Receipt/Payment in Advance for the selected document
		cOper2 := Iif(F4C->F4C_OPER == "1", STR0254, STR0255) //It will be impossible to edit the Inflow/Outflow VAT Document for this Bank Statement.

		cTitle := "RU06D07817_EditVATInvoice"
		cHelp := cOper + CRLF + cOper2

		Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,,)

	EndIf

	RestArea(aAreaSE2)
	RestArea(aAreaSE1)
	RestArea(aAreaF5M)
	RestArea(aAreaF4C)
	RestArea(aArea)

Return()


/*/{Protheus.doc} RU06D07818_DeleteVATInvoice
Deletes a VAT Invoice
@type Function
@author Fernando Nicolau
@since 15/12/2023
@version version
/*/
Function RU06D07818_DeleteVATInvoice()

	// Working areas
	Local aArea As Array
	Local aAreaF4C As Array
	Local aAreaF5M As Array
	Local aAreaSE1 As Array
	Local aAreaSE2 As Array
	Local nRecM	   As Numeric

	aArea := GetArea()
	aAreaF4C := F4C->(GetArea())
	aAreaF5M := F5M->(GetArea())
	aAreaSE1 := SE1->(GetArea())
	aAreaSE2 := SE2->(GetArea())

	DbSelectArea("F4C")
	F4C->(DbSetOrder(1))
	DbSelectArea("F5M")
	F5M->(DbSetOrder(1))

	If RU06D07822(@nRecM)
		If F4C->F4C_OPER == "1" //Inflow
			// Tune context (master)
			F35->(dbGoto(nRecM))
			FWExecView(STR0010, "RU09T11", MODEL_OPERATION_DELETE,, {|| .T.})
		ElseIf F4C->F4C_OPER == "2" //Outflow
			// Tune context (master)
			F37->(dbGoto(nRecM))
			FWExecView(STR0010, "RU09T10", MODEL_OPERATION_DELETE,, {|| .T.})
		EndIf
	EndIf

	RestArea(aAreaSE2)
	RestArea(aAreaSE1)
	RestArea(aAreaF5M)
	RestArea(aAreaF4C)
	RestArea(aArea)

Return()

/*/{Protheus.doc} RU06D07819_CheckAdvances
Checks if there is an Advance Document on the Bank Statement register
@type Static Function
@author Fernando Nicolau
@since 15/12/2023
@version version
@return	lRet, Logical, .T. if Advance Receivement/Payment on the Bank Statement register, otherwise .F.
/*/
Static Function RU06D07819_CheckAdvances() As Logical

	Local lRet As Logical
	Local cKey As Character

	lRet := .F.
	cKey := ""

	DbSelectArea("F4C")
	F4C->(DbSetOrder(1))

	DbSelectArea("F5M")
	F5M->(DbSetOrder(1))

	If F5M->(MsSeek(xFilial("F5M", F4C->F4C_FILIAL) + "F4C" + F4C->F4C_CUUID))

		While !F5M->(Eof()) .And. F5M->F5M_FILIAL == xFilial("F5M", F4C->F4C_FILIAL) .And. F5M->F5M_ALIAS == "F4C" .And. F5M->F5M_IDDOC == F4C->F4C_CUUID .And. !lRet

			If F5M->F5M_KEYALI == "SE1"

				DbSelectArea("SE1")
				SE1->(DbSetOrder(1))

				cKey := Rtrim(StrTran(F5M->F5M_KEY, "|", ""))

				If SE1->(MsSeek(cKey))
					If SE1->E1_TIPO $ MVRECANT
						lRet := .T.
						Exit
					EndIf
				EndIf

			ElseIf F5M->F5M_KEYALI == "SE2"

				DbSelectArea("SE2")
				SE2->(DbSetOrder(1))

				cKey := Rtrim(StrTran(F5M->F5M_KEY, "|", ""))

				If SE2->(MsSeek(cKey))
					If SE2->E2_TIPO $ MVPAGANT
						lRet := .T.
						Exit
					EndIf
				EndIf

			EndIf

			F5M->(DbSkip())
		End

	EndIf

Return(lRet)

/*/{Protheus.doc} RU06D07820_CheckVATonAdvances
Checks if there is a VAT Invoice for the Advance Receivement/Payment
@type Static Function
@author Fernando Nicolau
@since 15/12/2023
@version version
@param nRecM, Numeric, F35/F37 current record context (out) if VAT invoice found
@return	lRet, Logical, .T. if Advance Receivement/Payment has VAT Invoice, otherwise .F.
/*/
Static Function RU06D07820_CheckVATonAdvances(nRecM as Numeric) As Logical

	Local cQuery 	As Character
	Local cAlias 	As Character
	Local lRet   	As Logical
	Local aArea  	As Array
	Local aAreaF37 	As Array
	Local aAreaF35	As Array

	DEFAULT nRecM := 0

	cQuery := ""
	cAlias := ""
	lRet   := .F.
	aArea := GetArea()

	If F4C->F4C_OPER == "1" //Inflow

		cQuery := "SELECT F35_FILIAL, " + CRLF
		cQuery += "       F35_CLIENT, " + CRLF
		cQuery += "       F35_BRANCH, " + CRLF
		cQuery += "       F35_PDATE, " + CRLF
		cQuery += "       F35_DOC, " + CRLF
		cQuery += "       F35_TYPE, " + CRLF
		cQuery += "       F35_KEY " + CRLF
		cQuery += "  FROM " + RetSQLName("F35")  + CRLF
		cQuery += "    WHERE F35_FILIAL  = '" + xFilial("F35", SE1->E1_FILIAL) + "' " + CRLF
		cQuery += "      AND F35_PREFIX  = '" + SE1->E1_PREFIXO + "' " + CRLF
		cQuery += "      AND F35_NUM     = '" + SE1->E1_NUM + "' " + CRLF
		cQuery += "      AND F35_PARCEL  = '" + SE1->E1_PARCELA + "' " + CRLF
		cQuery += "      AND F35_TIPO    = '" + SE1->E1_TIPO + "' " + CRLF
		cQuery += "      AND F35_CLIENT  = '" + SE1->E1_CLIENTE + "' " + CRLF
		cQuery += "      AND F35_BRANCH  = '" + SE1->E1_LOJA + "' " + CRLF
		cQuery += "      AND D_E_L_E_T_  = ' ' "

		cQuery := ChangeQuery(cQuery)

		cAlias := MPSysOpenQuery(cQuery)
		DBSelectArea(cAlias)

		If !(cAlias)->(Eof())

			aAreaF35 := F35->(GetArea())
			DBSelectArea("F35")
			F35->(DBSetOrder(3)) //f35_filial + f35_key
			If F35->(MSSeek(xFilial("F35", (cAlias)->F35_FILIAL) + (cAlias)->F35_KEY))
				nRecM := F35->(Recno())
				lRet := .T.
			EndIf
			RestArea(aAreaF35)
		EndIf

	Else

		cQuery := "SELECT F37_FILIAL, " + CRLF
		cQuery += "       F37_FORNEC, " + CRLF
		cQuery += "       F37_BRANCH, " + CRLF
		cQuery += "       F37_PDATE, " + CRLF
		cQuery += "       F37_DOC, " + CRLF
		cQuery += "       F37_TYPE, " + CRLF
		cQuery += "       F37_KEY " + CRLF
		cQuery += "  FROM " + RetSQLName("F37")  + CRLF
		cQuery += "    WHERE F37_FILIAL  = '" + xFilial("F37", SE2->E2_FILIAL) + "' " + CRLF
		cQuery += "      AND F37_PREFIX  = '" + SE2->E2_PREFIXO + "' " + CRLF
		cQuery += "      AND F37_NUM     = '" + SE2->E2_NUM + "' " + CRLF
		cQuery += "      AND F37_PARCEL  = '" + SE2->E2_PARCELA + "' " + CRLF
		cQuery += "      AND F37_TIPO    = '" + SE2->E2_TIPO + "' " + CRLF
		cQuery += "      AND F37_FORNEC  = '" + SE2->E2_FORNECE + "' " + CRLF
		cQuery += "      AND F37_BRANCH  = '" + SE2->E2_LOJA + "' " + CRLF
		cQuery += "      AND D_E_L_E_T_  = ' ' "

		cQuery := ChangeQuery(cQuery)

		cAlias := MPSysOpenQuery(cQuery)
		DBSelectArea(cAlias)

		If !(cAlias)->(Eof())

			aAreaF37 := F37->(GetArea())
			DBSelectArea("F37")
			F37->(DBSetOrder(3)) //f37_filial + f37_key
			If F37->(MSSeek(xFilial("F37", (cAlias)->F37_FILIAL) + (cAlias)->F37_KEY))
				nRecM := F37->(Recno())
				lRet := .T.
			EndIf
			RestArea(aAreaF37)
		EndIf

	EndIf
	RestArea(aArea)

Return(lRet)


/*/{Protheus.doc} RU06D07821_IntegrityCheckVATIvsBooks
If there is(are) a record(s) in Sales/Purchase Book  for VAT Invoice
before delete we must delete book's record first
@type   Static Function
@author Konstantin Konovalov
@since  09/04/2024
@version version
@param	lShowMsg, Logical,	when .F. no messages will be shown on UI
@return	lRet,	Logical, 	.F. - we can delete record now, otherwise .T.
@see  FI-VAT-37-3, FI-VAT-37-4
/*/
Static Function RU06D07821_IntegrityCheckVATIvsBooks(lShowMsg as Logical) As Logical

	Local cQuery As Character
	Local cAlias As Character
	Local aArea	 As Array
	Local cOper  As Character
	Local cTitle As Character
	Local lRet   As Logical
	// F35/F37 -> F3A/F3C,(F3E ?) records exists, so simply delete book's record and try again to delete VAT Invoice
	DEFAULT lShowMsg = .T.

	cQuery := ""
	cAlias := ""
	lRet   := .T.
	aArea := GetArea()

	If F4C->F4C_OPER == "1" //Inflow

		cQuery := "SELECT F39_CODE, " + CRLF
		cQuery += "       F39_INIT, " + CRLF
		cQuery += "       F39_FINAL, " + CRLF
		cQuery += "       F3A_BOOKEY " + CRLF
		cQuery += "  FROM " + RetSQLName("F35") + " F INNER JOIN " + CRLF
		cQuery += "       " + RetSQLName("F3A") + " FA " + CRLF
		cQuery += "      ON F35_FILIAL = FA.F3A_FILIAL " + CRLF 
		cQuery += "      AND F35_DOC = FA.F3A_DOC " + CRLF
		cQuery += "      AND F35_PDATE = FA.F3A_PDATE INNER JOIN " + CRLF
		cQuery += "       " + RetSQLName("F39")  +  " F2 " + CRLF
		cQuery += "      ON F39_FILIAL = FA.F3A_FILIAL " + CRLF
		cQuery += "      AND F39_CODE = FA.F3A_CODE " + CRLF 
		cQuery += "  WHERE F35_FILIAL  = '" + xFilial("F35", SE1->E1_FILIAL) + "' " + CRLF
		cQuery += "      AND F35_PREFIX  = '" + SE1->E1_PREFIXO + "' " + CRLF
		cQuery += "      AND F35_NUM     = '" + SE1->E1_NUM + "' " + CRLF
		cQuery += "      AND F35_PARCEL  = '" + SE1->E1_PARCELA + "' " + CRLF
		cQuery += "      AND F35_TIPO    = '" + SE1->E1_TIPO + "' " + CRLF
		cQuery += "      AND F35_CLIENT  = '" + SE1->E1_CLIENTE + "' " + CRLF
		cQuery += "      AND F35_BRANCH  = '" + SE1->E1_LOJA + "' " + CRLF
		cQuery += "      AND F.D_E_L_E_T_  = ' '  AND FA.D_E_L_E_T_  = ' ' "

		cQuery := ChangeQuery(cQuery)
		cAlias := MPSysOpenQuery(cQuery)
		DBSelectArea(cAlias)

		If !(cAlias)->(Eof())
			lRet := .F.
			If lShowMsg
				// Message to UI:
				cOper := STR0259 + CRLF 
				cOper += STR0260 + AllTrim((cAlias)->F39_CODE) + " ," + CRLF
				cOper += STR0261 + DTOC(STOD((cAlias)->F39_INIT)) + STR0262 + DTOC(STOD((cAlias)->F39_FINAL)) 
				cTitle := "RU06D07821_IntegrityCheckVIvsBooks"
				Help(Nil, Nil, cTitle, Nil, cOper, 1, 0,,,,,,)
			EndIf
		EndIf

	Else    //Outflow

		cQuery := "SELECT F3B_CODE, " + CRLF
    	cQuery += "       F3B_INIT, " + CRLF 
    	cQuery += "      F3B_FINAL, " + CRLF 
    	cQuery += "      F3C_BOOKEY " + CRLF
  		cQuery += "  FROM " + RetSQLName("F37") + " F INNER JOIN " + CRLF
		cQuery += "       " + RetSQLName("F3C") + " FC " + CRLF	
		cQuery += "      ON F37_FILIAL = FC.F3C_FILIAL " + CRLF 
		cQuery += "      AND F37_DOC = FC.F3C_DOC " + CRLF
		cQuery += "      AND F37_PDATE = FC.F3C_PDATE INNER JOIN " + CRLF
		cQuery += "      " + RetSQLName("F3B")  +  " F2 " + CRLF
		cQuery += "      ON F3B_FILIAL = FC.F3C_FILIAL " + CRLF
		cQuery += "      AND F3B_CODE = FC.F3C_CODE " + CRLF 
		cQuery += "  WHERE F37_FILIAL  = '" + xFilial("F37", SE2->E2_FILIAL) + "' " + CRLF
		cQuery += "      AND F37_PREFIX  = '" + SE2->E2_PREFIXO + "' " + CRLF
		cQuery += "      AND F37_NUM     = '" + SE2->E2_NUM + "' " + CRLF
		cQuery += "      AND F37_PARCEL  = '" + SE2->E2_PARCELA + "' " + CRLF
		cQuery += "      AND F37_TIPO    = '" + SE2->E2_TIPO + "' " + CRLF
		cQuery += "      AND F37_FORNEC  = '" + SE2->E2_FORNECE + "' " + CRLF
		cQuery += "      AND F37_BRANCH  = '" + SE2->E2_LOJA + "' " + CRLF
		cQuery += "      AND F.D_E_L_E_T_  = ' ' AND FC.D_E_L_E_T_  = ' ' "

		cQuery := ChangeQuery(cQuery)
		cAlias := MPSysOpenQuery(cQuery)
		DBSelectArea(cAlias)

		If !(cAlias)->(Eof())
			lRet := .F.
			If lShowMsg
				// Message to UI:
				cOper := STR0258 + CRLF 
				cOper += STR0260 + AllTrim((cAlias)->F3B_CODE) + " ," + CRLF
				cOper += STR0261 + DTOC(STOD((cAlias)->F3B_INIT)) + STR0262 + DTOC(STOD((cAlias)->F3B_FINAL)) 
				cTitle := "RU06D07821_IntegrityCheckVIvsBooks"
				Help(Nil, Nil, cTitle, Nil, cOper, 1, 0,,,,,,)
			EndIf
		EndIf

	EndIf

	(cAlias)->(DbCloseArea())
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} RU06D07822_VldDeleteVatInvoice
Validate deletion of VAT Invoice (wrapper for three separated validation)
@type   Static Function
@author eduardo.flima/Konstantin Konovalov
@since  09/04/2024
@version version
@param nRecM, Numeric, F35/F37 current record context (out) if VAT invoice found
@return	lRet,	Logical,	.T. - we can delete record now, otherwise .F.
@see  FI-VAT-37-3, FI-VAT-37-4
/*/
Static Function RU06D07822_VldDeleteVatInvoice(nRecM as Numeric) AS Logical
	Local lRet 		as Logical
	Local cOper 	as Character
	Local cOper2 	as Character
	Local cTitle 	As Character

	DEFAULT nRecM := 0

	lRet 	:=.T.
	cOper 	:=""
	cOper2	:=""
	cTitle	:= "RU06D07822_VldDeleteVatInvoice"

	lRet := RU06D07819()
	If !lRet
		cOper  := Iif(F4C->F4C_OPER == "1", STR0242, STR0243) //There is no Receipt/Payment in Advance for the selected document
		cOper2 := Iif(F4C->F4C_OPER == "1", STR0256, STR0257) //It will be impossible to delete the Inflow/Outflow VAT Document for this Bank Statement.
	Else
		lRet:= RU06D07820(@nRecM)
		If !lRet
			cOper  := Iif(F4C->F4C_OPER == "1", STR0252, STR0253)
		EndIf
	EndIf
	If lRet
		lRet:= RU06D07821()
	else
		cOper := cOper + Iif(!Empty(cOper2), CRLF + cOper2, "")  //Inflow/Outflow VAT not found for the selected Bank Statement.
		Help(Nil, Nil, cTitle, Nil, cOper, 1, 0,,,,,,)
	EndIf

Return lRet
                   
//Merge Russia R14 
                   
