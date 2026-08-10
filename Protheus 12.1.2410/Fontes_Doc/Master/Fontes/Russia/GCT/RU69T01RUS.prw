#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RU69T01RUS.CH"

#DEFINE  MENUDEF_COPY_OPERATION 9
#DEFINE  MENUDEF_OPERATION_POS  4
#DEFINE  MENUDEF_FUNCTION_POS   2

Static _lRplcCopFn := .T. //Replace Standard Copy function to Customized variant in Menu
Static _cCstmCopFn := "RU69T01Copy()" //Customized copy function

/*{Protheus.doc} RU69T01RUS
    @author Konstantin Cherchik
    @since 10/31/2018
    @version P12.1.23
    @return 
    @type function
    @description Legal Contract
*/
Function RU69T01RUS()

    Local oBrowse as OBJECT

    dbSelectArea("F5Q")
    dbSetOrder(1)	
        
    oBrowse := FWLoadBrw("RU69T01RUS")
    oBrowse:Activate()

Return

/*{Protheus.doc} BrowseDef
    @author Konstantin Cherchik
    @since 10/31/2018
    @version P12.1.23
    @return oBrowse
    @type function
    @description RU09D06 BrowseDef
*/
Static Function BrowseDef()

    Local oBrowse as OBJECT
    oBrowse := FWLoadBrw("RU69T01")

Return oBrowse

/*{Protheus.doc} MenuDef
    @author Konstantin Cherchik
    @since 10/31/2018
    @version P12.1.23
    @return aRotina
    @type function
    @description RU69T01RUS MenuDef
*/
Static Function MenuDef()

    Local aRotina as ARRAY
    Local aRotAdd as ARRAY	// array of Entry point

    aRotina := FwLoadMenuDef("RU69T01")

    If _lRplcCopFn
        RplcCopyFn(@aRotina)
    EndIf

    /* Entrypoint for adding buttons to aRotina */
    If ExistBlock("MA300006")
        aRotAdd := ExecBlock("MA300006",.F., .F.)
        If ValType(aRotAdd) == "A"
            aEval(aRotAdd,{|x| aAdd(aRotina,x) })
        EndIf
    EndIf

    aAdd(aRotina,{STR0030, "RU34XREP01('RU69T01RUS', .T.)", 0, 2})	

Return aRotina

/*{Protheus.doc} ViewDef
    @author Konstantin Cherchik
    @since 10/31/2018
    @version P12.1.23
    @return oView
    @type function
    @description RU69T01RUS ViewDef
*/
Static Function ViewDef()

    Local oView		as object
    Local oModel	as object	 
    Local oStruHead	as object
    Local oStruDet	as object

    oModel	:= FWLoadModel("RU69T01RUS") 	 

    oStruHead	:= FWFormStruct(2,"F5Q", {|x| ! AllTrim(x) $ "F5Q_UID"})
    oStruDet    := FWFormStruct(2,"F5R", {|x| ! AllTrim(x) $ "F5R_REV|F5R_CODE|F5R_UID|F5R_UIDF5Q"}) 

    oView := FWLoadView("RU69T01")

    oView:SetModel(oModel)

    oView:AddField("HEAD_F5Q", oStruHead, "F5QMASTER") 
    oView:AddField("CHILD_F5R", oStruDet, "F5RDETAIL")

    oView:CreateHorizontalBox("MAIN",50)
    oView:CreateHorizontalBox("DETAIL",50)

    oView:SetOwnerView("HEAD_F5Q", "MAIN")
    oView:SetOwnerView("CHILD_F5R", "DETAIL")

    //oView:AddUserButton(STR0006, '', {|oViewLc, oButton| LoadTimeSpanManagement(oViewLc, oButton)}) 
    oView:AddUserButton(STR0029, '', {|| RU34XREP01("RU69T01RUS", .F.)},,,{MODEL_OPERATION_VIEW}) 

Return oView

/*{Protheus.doc} LoadTimeSpanManagement
    @author 
    @since 
    @version 
    @return 
    @type function
    @description 
*/
Static Function LoadTimeSpanManagement(oViewLc as Object, oButton as Object)

    Local nOper			as Numeric
    Local oModel		as Object

    oModel		:= oViewLc:GetModel()
    nOper		:= oModel:GetOperation()

    If nOper <> MODEL_OPERATION_UPDATE .And. nOper <> MODEL_OPERATION_VIEW
        Help("",1,"RU69T01TIMESPANOP",,STR0013,1,0)
    ElseIf ! Empty(RU69T0201_GetChild("F5Q", "F5R", F5Q->F5Q_UID, dDataBase, .F.))
        RU69T02RUS(nOper)
    EndIf

Return Nil

/*{Protheus.doc} ModelDef
    @author Konstantin Cherchik
    @since 10/31/2018
    @version P12.1.23
    @return oModel
    @type function
    @description construction of oModel 
*/
Static Function ModelDef()
Local oModel	as object
Local oEAIEVENT := np.framework.eai.MVCEvent():New('RU69T01')
oModel := FWLoadModel("RU69T01")
oModel:GetModel("F5QMASTER"):GetStruct():SetProperty('F5Q_CTYPE', MODEL_FIELD_WHEN, {|| ChkWhen('')})
oModel:GetModel("F5QMASTER"):GetStruct():SetProperty('F5Q_A1COD', MODEL_FIELD_WHEN, {|| ChkWhen('F5Q_A1')})
oModel:GetModel("F5QMASTER"):GetStruct():SetProperty('F5Q_A2COD', MODEL_FIELD_WHEN, {|| ChkWhen('F5Q_A2')})
oModel:GetModel("F5QMASTER"):GetStruct():SetProperty('F5Q_A1LOJ', MODEL_FIELD_WHEN, {|| ChkWhen('F5Q_A1')})
oModel:GetModel("F5QMASTER"):GetStruct():SetProperty('F5Q_A2LOJ', MODEL_FIELD_WHEN, {|| ChkWhen('F5Q_A2')})
oModel:InstallEvent("NPEAI"	,,oEAIEVENT)
Return oModel

/*{Protheus.doc} ModelDef
    @author Konstantin Cherchik
    @since 11/16/2018
    @version P12.1.23
    @return oModel
    @type function
    @description Copying contracts between branches 
*/
Function RU69T01Copy()

    Local oModel 	as Object
    Local aSelFil	as Array
    Local aAreaSX2  as Array
    Local aAreaF5Q  as Array
    Local cCurFil	as Character
    Local cF5QKey	as Character
    Local nX 		as Numeric
    Local nKeyOrd   as Numeric

    aSelFil	:= {}
    cCurFil	:= cFilAnt
    nKeyOrd := 1
    aSelFil := AdmGetFil(.F.,.T.,"F5Q") //TODO: Need control, If table is Shared? Then just put in aSelFil one empty branch value " ". So, function will create 1 copy with empty branch.
    cF5QKey	:= &(F5Q->(IndexKey(nKeyOrd)))
    If !(empty(aSelFil))
        For nX := 1 to len(aSelFil)
            aAreaF5Q	:= F5Q->(GetArea())
            dbSelectArea("F5Q")
            dbSetOrder(nKeyOrd) 
            If F5Q->(dbSeek(cF5QKey))
                oModel := FWLoadModel("RU69T01RUS")
                oModel:SetOperation(1)
                oModel:Activate(.T.) 
                cFilAnt := aSelFil[nX]

                oModel:GetModel("F5QMASTER"):SetValue("F5Q_CODE",oModel:GetModel("F5QMASTER"):InitValue("F5Q_CODE")) //init F5Q_CODE, x3_valid should be empty

                /* Due to the fact that to load the inherited data into the model, to copy the contract,
                we used the VIEW operation, we must generate new UID for F5Q & F5R. */
                oModel:GetModel("F5QMASTER"):LoadValue("F5Q_UID", RU01UUIDV4()) 
                oModel:GetModel("F5RDETAIL"):LoadValue("F5R_UID", RU01UUIDV4()) 

                aAreaSX2	:= SX2->(GetArea())
                dbSelectArea("SX2")
                If SX2->(dbSeek("SA1"))
                    If SX2->X2_MODO == "E"
                        oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A1COD",oModel:GetModel("F5QMASTER"):InitValue("F5Q_A1COD"))
                    EndIf
                EndIf
                If SX2->(dbSeek("SA2"))
                    If SX2->X2_MODO == "E"
                        oModel:GetModel("F5QMASTER"):LoadValue("F5Q_A2COD",oModel:GetModel("F5QMASTER"):InitValue("F5Q_A2COD"))
                    EndIf
                EndIf
                If SX2->(dbSeek("F30"))
                    If SX2->X2_MODO == "E"
                        oModel:GetModel("F5RDETAIL"):LoadValue("F5R_VATCOD",oModel:GetModel("F5RDETAIL"):InitValue("F5R_VATCOD"))
                    EndIf
                EndIf
                If SX2->(dbSeek("SED"))
                    If SX2->X2_MODO == "E"
                        oModel:GetModel("F5RDETAIL"):LoadValue("F5R_NATURE",oModel:GetModel("F5RDETAIL"):InitValue("F5R_NATURE"))
                    EndIf
                EndIf
                If SX2->(dbSeek("SE4"))
                    If SX2->X2_MODO == "E"
                        oModel:GetModel("F5RDETAIL"):LoadValue("F5R_COND",oModel:GetModel("F5RDETAIL"):InitValue("F5R_COND"))
                    EndIf
                EndIf
                If SX2->(dbSeek("CTO"))
                    If SX2->X2_MODO == "E"
                        oModel:GetModel("F5QMASTER"):LoadValue("F5Q_MOEDA",oModel:GetModel("F5QMASTER"):InitValue("F5Q_MOEDA"))
                    EndIf
                EndIf
                RestArea(aAreaSX2)

                dbSelectArea("F5Q")
                dbSetOrder(2)
                
                FWExecView( STR0024 , "RU69T01RUS", MODEL_OPERATION_INSERT, /*oDlg*/, {|| .T. },  , /*nPercReducao*/, , /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,oModel)
                cFilAnt := cCurFil
                oModel:DeActivate()
            EndIf
        Next nX
        RestArea(aAreaF5Q)
    EndIf

Return

/*{Protheus.doc} ModelDef
    @author Konstantin Cherchik
    @since 11/16/2018
    @version P12.1.23
    @return oModel
    @type function
    @description Copying contracts between branches 
*/
Function RU69T01Descr(cExtNumber as Char, dExtDate as Date)

    Local cLegDescr As Char

    cLegDescr := STR0022 + AllTrim(cExtNumber)+STR0023+DTOC(dExtDate)

Return cLegDescr

/*/{Protheus.doc} RplcCopyFn
	Change standard copy fun to customized variant in Menu
	@type  Static Function
	@author astepanov
	@since 13/10/2022
	@version version
	@param aRotina, Array, Menu generated by FwLoadMenuDef()
	@return lRet, Logical, .T.
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RplcCopyFn(aRotina)

	Local lRet      As Logical
	Local nMnItmPos As Numeric

	lRet := .T.
	nMnItmPos := ASCAN(aRotina,{|x| x[MENUDEF_OPERATION_POS] == MENUDEF_COPY_OPERATION})
	If nMnItmPos > 0
		aRotina[nMnItmPos][MENUDEF_FUNCTION_POS] := _cCstmCopFn
	EndIf

Return lRet

/*/{Protheus.doc} RU69T01001_GetRuleItems(cType, cEdate, cCode)
    This function uses for query F5S data

    @type Function
    @param cType  = string, with contract type (F5Q_CTYPE)
    @param cEdate = string, with contract date (F5Q_EDATE)
    @param cCode  = string, with contract code (F5Q_CODE)
    @param cGroup  = string, with counterparty group code (F5Q_GRCNS)
    @return aRuleItem

    @author Dmitry Borisov
    @since 2023/11/17
    @version 12.1.33
    @example RU69T01001(cType, cEdate, cCode, cGroup)
*/
Function RU69T01001_GetRuleItems(cType, cEdate, cCode, cGroup)
    Local cQuery     := ''
    Local cTab       := GetNextAlias()
    Local aRuleItem  := {}
    Local aArea      := {}

    cQuery := "SELECT F5S_F5QCOD, R_E_C_N_O_ As RecNo"
    cQuery += " FROM " + RetSqlName('F5S')
    cQuery += " WHERE D_E_L_E_T_ = '' "
    cQuery += " AND F5S_FILIAL =  '" + xFilial('F5S')+"'"
    cQuery += " AND F5S_CTYPE  =  '" + cType + "'"
    cQuery += " AND F5S_GRCNS  =  '" + cGroup + "'"
    cQuery += " AND F5S_DVALST <= '" + cEdate + "'"
    cQuery += " AND F5S_DVALEN >= '" + cEdate + "'"
    cQuery += " AND (F5S_F5QCOD = '" + cCode + "' OR F5S_F5QCOD =  '')"
    cQuery += " ORDER BY F5S_F5QCOD DESC"
    cQuery := ChangeQuery(cQuery)

    aArea := F5S->(GetArea())
    DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTab)

    While (cTab)->(!EOF())
        If Len(aRuleItem) > 0
            Exit
        EndIf
        aAdd(aRuleItem, (cTab)->RecNo)
        (cTab)->(DbSkip())
    End

    (cTab)->(dbCloseArea())
    RestArea(aArea)

Return aRuleItem

/*/{Protheus.doc} RU69T01002_GetF5QCode(cType, cTDoc)
    This function uses for search relevant serial number (F33)
    Run from triggers F5Q_CTYPE, F5Q_TDOC

    @type Function
    @param cType = string, with contract type (F5Q_CTYPE)
    @param cTDoc = string, with contract type doc (F5Q_TDOC) - Main/Detailed
    @return cRetSeq

    @author Dmitry Borisov
    @since 2023/11/20
    @version 12.1.33
    @example RU69T01002(cType, cTDoc)
*/
Function RU69T01002_GetF5QCode(cType, cTDoc)
    Local cSerie    := ''
    Local cRetSeq   := ''
    Local aArea := F65->(GetArea())
    DbSelectArea('F65')
    DbSetOrder(1) // F65_FILIAL+F65_CTYPE+F65_TDOC+F65_SERIE

    If F65->(DbSeek(xFilial('F65')+cType+cTDoc))
        cSerie := F65->F65_SERIE
        cRetSeq := RU09D03Nmb("LGCONT", cSerie)
    EndIf

    RestArea(aArea)
Return cRetSeq

/*/{Protheus.doc} RU69T01003_CheckCondition()
    This function uses for search relevant serial number (F33)
    Run from triggers F5Q_CTYPE, F5Q_TDOC

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/11/20
    @version 12.1.33
    @example RU69T01003()
*/
Function RU69T01003_CheckCondition()
    Local lRet    := .F.
    Local oModel  := FWModelActive()
    
    If !Empty(AllTrim(oModel:GetValue("F5QMASTER", "F5Q_CTYPE"))) .And. !Empty(AllTrim(oModel:GetValue("F5QMASTER", "F5Q_TDOC")))
        lRet := .T.
    EndIf

Return (lRet)


/*/{Protheus.doc} RU69T01004_Return_F5R_Common_Name
    This function Returns the content of the memofield F5R_CMNAME 
    using as base de UUID from the Legal Contract Revision
    @type  Function
    @author eduardo.Flima
    @since 06/02/2024
    @version 06/02/2024
    @param cUUid    , Character , uniqui identifier of the Legal Contract Revision
    @return cComNam , Character , Common name 
/*/
Function RU69T01004_Return_F5R_Common_Name(cUUid as Character)
    Local aArea     as Array
    Local aAreaF5R  as Array
    Local cComNam   as Character
    cComNam     :=""
    aArea       := GetArea()
        aAreaF5R	:= F5R->(GetArea())
            dbSelectArea("F5R")
            dbSetOrder(1) 
            If F5R->(dbSeek(xFilial("F5R")+cUUid))
                cComNam := F5R->F5R_CMNAME    
            EndIf        
        RestArea(aArea)
    RestArea(aAreaF5R)
Return (cComNam)

/*/{Protheus.doc} ChkWhen()
    This function uses for WHEN condition for fields

    @type Static Function
    @return lRet

    @author Dmitry Borisov
    @since 2024/01/12
    @example ChkWhen()
*/
Static Function ChkWhen(cField)
    Local lRet     := .T.
    Local oModel   := FWModelActive()
    Local aArea    := {}
    Local cRelType := ''
    
    If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. Empty(cField) .And. !Empty(AllTrim(oModel:GetValue("F5QMASTER", "F5Q_CTYPE")))
        lRet := .F.
    EndIf

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !Empty(cField) .And. !Empty(AllTrim(oModel:GetValue("F5QMASTER", "F5Q_TYPE")))
        lRet := .F.
        aArea := F4Y->(GetArea())

        dbSelectArea("F4Y")
        dbSetOrder(1) // F4Y_FILIAL+F4Y_TYPE

        If F4Y->(dbSeek(xFilial("F4Y") + oModel:GetValue("F5QMASTER", "F5Q_TYPE")))
            cRelType := F4Y->F4Y_CLISUP
        EndIf

        RestArea(aArea)
        
        If cRelType == '1' .And. cField == 'F5Q_A1'
            lRet := .T.
        EndIf
        If cRelType == '2' .And. cField == 'F5Q_A2'
            lRet := .T.
        EndIf
    EndIf

Return (lRet)
                   
//Merge Russia R14 
                   
