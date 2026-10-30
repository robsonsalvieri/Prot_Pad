#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RU06D10.CH"

/*{Protheus.doc} RU06D10
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return 
@type function
@description Client-bank import
*/
Function RU06D10()
    Local oBrowse    as Object
    Local aSaveArea  as Array
    Static lParsed   as Logical
    Static lStopFile as Logical
    Private aRotina as ARRAY

    aRotina	:= MenuDef()

    lParsed := .T.
    aSaveArea := GetArea() 

    dbSelectArea("F6X")
    dbSelectArea("F6W")

    RU06D10037_checkF6J()

    oBrowse :=  BrowseDef()

    oBrowse:Activate()
    RestArea(aSaveArea) 
Return 

/*{Protheus.doc} BrowseDef
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return oBrowse
@type function
@description RU06D10 BrowseDef
*/
Static Function BrowseDef()
    Local oBrowse as OBJECT
    oBrowse := FWMBrowse():New()
    oBrowse:AddLegend("F6X_STATUS=='1'", "WHITE", STR0001)  // Not related
    oBrowse:AddLegend("F6X_STATUS=='2'", "GREEN", STR0002)	// Related to BS
    oBrowse:AddLegend("F6X_STATUS=='3'", "BLUE", STR0013)   // Posted in Finance
    oBrowse:AddLegend("F6X_STATUS=='4'", "ORANGE", STR0014) // Posted in Accounting
    oBrowse:AddLegend("F6X_STATUS=='5'", "RED", STR0015)	// Partially posted in Finance
    oBrowse:AddLegend("F6X_STATUS=='6'", "BLACK", STR0016)  // Partially posted in Accounting
    oBrowse:SetAlias("F6X")
    oBrowse:SetDescription(STR0003) // Import from client-bank

Return oBrowse

/*{Protheus.doc} MenuDef
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return aRotina
@type function
@description RU06D10 MenuDef
*/
Static Function MenuDef()
    Local aRotina as ARRAY
    aRotina := {} 

	aRotina := {{STR0004, "RU06D10009_Pergunte()", 0, 3, 0, Nil},;  // Import
                {STR0005, 'VIEWDEF.RU06D10', 0, 2, 0, Nil},;	//View
				{STR0006, 'VIEWDEF.RU06D10', 0, 4, 0, Nil},; 	//Edit
				{STR0007, "RU06D10010_Delete()", 0, 5, 0, Nil},; 	//Delete
                {STR0008, "RU06D10034_CreateBS()", 0, 0, 0, Nil},; 	//Create bankstatement
                {STR0010, "RU06D10012_PostedToFI()", 0, 0, 0, Nil},;  	//Posted to finance
                {STR0064, "RU06D10040_PostedToFIWithoutPO()", 0, 0, 0, Nil},;  	//Posted to finance without PO
                {STR0011, "RU06D10013_PostedToAcnt()", 0, 0, 0, Nil},;  	//Posted to account
                {STR0009, "RU06D10014_Legenda()", 0, 0, 0, Nil};  	//Legenda
                }

Return aRotina

/*{Protheus.doc} ViewDef
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return oView
@type function
@description RU06D10 ViewDef
*/
Static Function ViewDef()
    Local oView		as object
    Local oModel	as object	 
    Local oStruHead	as object
    Local oStruDet	as object
    Local aOper      As Array

    aOper := {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE}

    oModel	:= FWLoadModel("RU06D10") 	 

    oStruHead	:= FWFormStruct(2,"F6X", {|x| ! AllTrim(x) $ "F6X_UUID"})
    oStruDet    := FWFormStruct(2, "F6W", {|x| ! AllTrim(x) $ "F6W_UIDF6X|F6W_UIDF49|F6W_UIDF5Q|F6W_UIDF4C|F6X_USRIMP|F6X_USERGA|F6X_USERGI"}) 

    oView := FWFormView():New()

    oView:SetModel(oModel)

    oView:AddField("HEAD_F6X", oStruHead, "F6XMASTER") 
    oView:AddGrid("CHILD_F6W", oStruDet, "F6WDETAIL")

    oView:CreateHorizontalBox("MAIN",30)
    oView:CreateHorizontalBox("DETAIL",70)

    oView:SetOwnerView("HEAD_F6X", "MAIN")
    oView:SetOwnerView("CHILD_F6W", "DETAIL")
    oView:SetViewProperty("CHILD_F6W", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU06D10048_2Click(oFormula, cFieldName, nLineGrid, nLineModel)}})

    oView:AddUserButton(STR0034, "", {|| RU06D10017_UpdateRef()},,,aOper)  // update ref
    oView:AddUserButton(STR0008, "", {|| RU06D10034_CreateBS()},,,aOper) 	//Create bankstatement
    oView:AddUserButton(STR0010, "", {|| RU06D10012_PostedToFI()},,,aOper)  //Posted to finance
    oView:AddUserButton(STR0064, "", {|| RU06D10040_PostedToFIWithoutPO()},,,aOper)  //Posted to finance without po
    oView:AddUserButton(STR0011, "", {|| RU06D10013_PostedToAcnt()},,,aOper) //Posted to account

Return oView

/*{Protheus.doc} ModelDef
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return oModel
@type function
@description construction of oModel 
*/
Static Function ModelDef()
    Local oModel	as object	 
    Local oStruHead	as object
    Local oStruDet	as object
    Local oModelEvent as object

    oStruHead	:= FWFormStruct(1,"F6X")
    oStruDet    := FWFormStruct(1,"F6W")
    
    oModel		:= MPFormModel():New("RU06D10", /* Pre-valid */, /* Pos-Valid */, /* Commit */)

    oStruDet:AddTrigger("F6W_WRITT","F6W_WRITT",{|| .T. },{ || RU06D10016_UpdTotal("F6W_WRITT", oModel)  })
    oStruDet:AddTrigger("F6W_RECEIV","F6W_RECEIV",{|| .T. },{ || RU06D10016_UpdTotal("F6W_RECEIV", oModel)  })
    
    oModel:AddFields("F6XMASTER", /*cOwner*/, oStruHead)
    oModel:AddGrid("F6WDETAIL", "F6XMASTER", oStruDet, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)

    oModel:GetModel("F6XMASTER"):SetDescription(STR0003) // Import from client-bank
    oModel:SetDescription(STR0003) // Import from client-bank
    oModel:SetRelation("F6WDETAIL", {{"F6W_FILIAL","XFILIAL('F6W')"},{"F6W_UIDF6X","F6X_UUID"}}, F6W->(IndexKey(2)))
    oModelEvent := RU06D10EventRUS():New()
    oModel:InstallEvent("oModelEvent"	,/*cOwner*/,oModelEvent)

Return oModel

/*/{Protheus.doc} RU06D10001_Moeda
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return cMoedaDesc
@type function
*/
Function RU06D10001_Moeda()
    Local cMoedaDesc as Character
    Local nMoeda     as Numeric
    Local aSaveArea  as Array
    Local aAreaSA6   as Array
    Local aAreaCTO   as Array

    aSaveArea := GetArea() 
    aAreaSA6 := SA6->(GetArea())
    aAreaCTO := CTO->(GetArea())
    cMoedaDesc  := " "
    dbSelectArea("SA6")
    SA6->(dbSetOrder(1))

    If !EMPTY(AllTrim(F6X->F6X_BNKCOD)) 
        If SA6->(dbSeek(xFilial("SA6")+F6X->F6X_BNKCOD+F6X->F6X_BIK+F6X->F6X_ACCNT))
            nMoeda := SA6->A6_MOEDA
            cMoedaDesc := Posicione("CTO",1,xFilial("CTO")+StrZero(nMoeda,2),"CTO_SIMB")
        EndIf
    ElseIf !EMPTY(AllTrim(MV_PAR01))
        If SA6->(dbSeek(xFilial("SA6")+MV_PAR01+MV_PAR02+MV_PAR03))
            nMoeda := SA6->A6_MOEDA
            cMoedaDesc := Posicione("CTO",1,xFilial("CTO")+StrZero(nMoeda,2),"CTO_SIMB")
        EndIf
    EndIf

    RestArea(aAreaCTO)  
    RestArea(aAreaSA6)  
    RestArea(aSaveArea) 

Return cMoedaDesc 

/*/{Protheus.doc} RU06D10002_VldBeforeSave
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params oModel as Object
@return lRet as Logical
@type function
@description validation before save
*/
Function RU06D10002_VldBeforeSave(oModel as Object)
    Local lRet         as Logical
    Local oModelDetail as Object
    Local nX           as Numeric

    oModelDetail := oModel:GetModel("F6WDETAIL")
    lRet := .T. // Flag that necessary fields are not empty

    For nX := 1 to oModelDetail:Length()
        oModelDetail:GoLine(nX)
        lRet := lRet .AND. (!EMPTY(oModelDetail:GetValue("F6W_RECEIV")) .OR. !EMPTY(oModelDetail:GetValue("F6W_WRITT")))
        lRet := lRet .AND. !EMPTY(oModelDetail:GetValue("F6W_CONCOD"))
        If !lRet
            Help("",1,STR0039,,STR0017 + cValToChar(nX),1,0) // Required fields: Written or Received and Account
            EXIT
        Endif
    Next nX

Return lRet

/*/{Protheus.doc} RU06D10003
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params cFilePath as Character
@return aLinesFile as Array
@type function
@description takes the path of file and returns the array with strings from file
*/
Function RU06D10003(cFilePath)
    LOCAL aLinesFile := {}
    Local cBuffer := ""
    Local cSep := Chr(13) + Chr(10)
    LOCAL nSize
    
    cFilePath := AllTrim(cFilePath)
    Private nHdl := fOpen(cFilePath,68)
    If nHdl == -1
        Help("",1,STR0019,,STR0020,1,0) // File not found
    Else
        nSize := FSEEK(nHdl, 0, 2) // Define size of flie.
        FSEEK(nHdl, 0, 0) // Return to the begin
        cBuffer := FREADSTR(nHdl, nSize)
        fClose(nHdl)
    Endif
    aLinesFile := StrTokArr(cBuffer, cSep)

Return aLinesFile

/*/{Protheus.doc} RU06D10004
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params aLinesFile as Array
        cFormatCode as Character
@return lRet as Logical
@type function
@description takes array of data, makes parsing and calls the window of creation
*/
Function RU06D10004(aLinesFile, cFormatCode)
    Local oModel           as Object

    lParsed := .F.

    oModel := FwLoadModel("RU06D10")
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()
    RU06D10006(oModel,aLinesFile, cFormatCode)

    If lStopFile
        oModel:DeActivate()
    Else
        RU06XFUN31_RelacaoRerun(oModel)
        oModel:GetModel("F6WDETAIL"):SetNoInsertLine(.T.)
        FwExecView(STR0018, "RU06D10", MODEL_OPERATION_INSERT,/* oDlg */, {|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel) // Creation
        lParsed := .T.
    Endif
RETURN NIL

/*/{Protheus.doc} RU06D10005
@author Olga Galyandina
@since 01/03/2024
@version 1
@return lCodExist as Logical
@type function
@description filling MV_PAR02 and MV_PAR03 and prefilling MV_PAR4 by MV_PAR01
*/
Function RU06D10005()
    Local lCodExist   as Logical
    Local aSaveArea   as Array
    Local aAreaSA6    as Array  

    lCodExist := ExistCpo("SA6", MV_PAR01)
    If lCodExist
        If aPergunta[1,8] <> MV_PAR01        
            aSaveArea := GetArea() 
            aAreaSA6 := SA6->(GetArea())
            dbSelectArea('SA6')
            SA6->(dbSetOrder(1))
            If SA6->(dbSeek(xFilial("SA6")+MV_PAR01))
                MV_PAR02 := SA6->A6_AGENCIA
                MV_PAR03 := AllTrim(SA6->A6_NUMCON)
                MV_PAR04 := SA6->A6_PATHI
            Endif
            RestArea(aAreaSA6)  
            RestArea(aSaveArea) 
        Endif
    Endif

Return lCodExist

/*/{Protheus.doc} RU06D10006
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params oModel as Object
        aLinesFile as Array
        cFormatCode as Character
@return NIL
@type function
@description fill data for model
*/
Function RU06D10006(oModel as Object, aLinesFile as Array, cFormatCode as Character)
    Local oModelMaster   as Object
    Local nCount         as Numeric
    Local aName          as Array

    nCount := 0
    aName := strTokArr(MV_PAR04, "\")

    oModelMaster := oModel:GetModel("F6XMASTER")

    oModelMaster:SetValue("F6X_BNKCOD", MV_PAR01)
    oModelMaster:SetValue("F6X_BIK", MV_PAR02)
    oModelMaster:SetValue("F6X_ACCNT", MV_PAR03)
    oModelMaster:SetValue("F6X_FILEIM", AllTrim(aName[LEN(aName)]))
    oModelMaster:SetValue("F6X_ACNAME", Posicione("SA6",1,xFilial("SA6")+MV_PAR01+MV_PAR02+MV_PAR03,"A6_ACNAME")) 
    
    RU06D10007_Parsing(oModel,aLinesFile, cFormatCode)
    IncRegua()
    RU06D10008_FillGrid(oModel)

    oModelMaster:SetValue("F6X_DTFROM", MV_PAR05) 
    oModelMaster:SetValue("F6X_DTTO", MV_PAR06) 

Return NIL

/*/{Protheus.doc} RU06D10007_Parsing
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params oModel as Object
        aLinesFile as Array
        cFormatCode as Character
@return lRet as Logical
@type function
@description make parsing array to structure f6w
*/
Function RU06D10007_Parsing(oModel as Object, aLinesFile as Array, cFormatCode as Character)
    Local lAddLine     as Logical
    Local lDocEnd      as Logical
    Local lSecEnd      as Logical
    Local lLnChckd     as Logical
    Local lNeedSkip    as Logical
    Local lHeadEnd     as Logical
    Local cDocEnd      as Character
    Local cSecEnd      as Character
    Local oModelDetail as Object
    Local oModelMaster as Object
    Local nX           as Numeric
    Local nCnt         as Numeric
    Local aTagVal      as Array
    Local aFields      as Array
    Local aValues      as Array
    Local aSaveArea    as Array
    Local aAreaF6J     as Array
    Local aAreaF5U     as Array
    Local aAreaF5V     as Array
    Local xValue
 
    lStopFile := .F.
    lAddLine := .T.
    lDocEnd  := .T. // Flag that now we outside "document"
    lSecEnd  := .T. // Flag that now we outside "section"
    lLnChckd := .F. // Flag that array with data was checked
    lNeedSkip := .F. // Flag that section of document doesn't sutisfy checks and may be skiped
    lHeadEnd := .F. // Flag that header of document is parsed already
    nX       := 1
    // in begining parsing is made to arrays aFields and aVaalues
    // if data sutisfies the checks that line of f6w is created
    aFields  := {}
    aValues  := {}

    oModelMaster := oModel:GetModel("F6XMASTER")
    oModelDetail := oModel:GetModel("F6WDETAIL")
    lAddLine := !EMPTY(AllTrim(oModelDetail:GetValue("F6W_OPDATE")))

    If oModelDetail:GetLine() != 1  //For synchronization of records
        oModelDetail:GoLine(nX)
    EndIf

    aSaveArea := GetArea() 
    aAreaF6J := F6J->(GetArea())
    aAreaF5U := F5U->(GetArea())
    aAreaF5V := F5V->(GetArea())
    dbSelectArea('F6J')
    F6J->(dbSetOrder(1))
    dbSelectArea('F5U')
    F5U->(dbSetOrder(2))
    dbSelectArea('F5V')
    F5V->(dbSetOrder(2))

    FOR nCnt := 1 TO LEN(aLinesFile)
        aTagVal := StrTokArr( aLinesFile[nCnt], "=" )
        If LEN(aTagVal) == 0
            LOOP
        Endif
        If !Empty(DecodeUTF8(aTagVal[1], "cp1251"))  // check of file's encoding: utf8 or cp1251                  
            aTagVal[1] := AllTrim(DecodeUTF8(aTagVal[1], "cp1251"))
            If LEN(aTagVal) > 1 .AND. !Empty(aTagVal[2])
                aTagVal[2] := AllTrim(DecodeUTF8(aTagVal[2], "cp1251")) 
            Endif
        Endif
        If lDocEnd
            F5U->(dbSeek(xFilial("F5U")+cFormatCode+aTagVal[1]))
            If F5U->F5U_SECTN == '1'
                cDocEnd := F5U->F5U_TGEND
                lDocEnd := .F.
                LOOP
            Endif
        Elseif cDocEnd == aTagVal[1]
            EXIT
        Endif
        If !Empty(oModelMaster:GetValue("F6X_DTFROM")) .AND. !Empty(oModelMaster:GetValue("F6X_DTTO"))
            If !(oModelMaster:GetValue("F6X_DTFROM") <= MV_PAR06 .AND. oModelMaster:GetValue("F6X_DTTO") >= MV_PAR05)
                lStopFile := .T.
                Help("",1,STR0019,,STR0012,1,0) // The data period in the file does not match the selected period
                EXIT
            Endif
        Endif
        
        If lSecEnd
            If F5U->(dbSeek(xFilial("F5U")+cFormatCode+aTagVal[1]))
                If F5U->F5U_SECTN <> '1'
                    lHeadEnd := .T.
                Endif
                If F5U->F5U_SECTN == '3'
                    cSecEnd := F5U->F5U_TGEND
                    lSecEnd := .F.
                    lLnChckd := .F.
                    aFields := {}
                    aValues := {}
                    If LEN(aTagVal) > 1 .AND. !Empty(aTagVal[2])
                        aAdd(aFields, "F6W_DOCTYP")
                        aAdd(aValues, aTagVal[2])
                    Endif
                    LOOP
                Endif
            Endif
        Elseif AllTrim(cSecEnd) == aTagVal[1]
            lSecEnd := .T.
            lNeedSkip := .F.
            If RU06D10019_CheckDelLine(aFields, aValues)
                aFields := {}
                aValues := {}
            Endif
            // after the end of section in file and checcking create line in grid and f6w
            lAddLine := RU06D10025_FillParsedFields(oModelDetail, aFields, aValues, lAddLine)
            LOOP
        Endif
        If lNeedSkip
            LOOP
        Endif
        If LEN(aTagVal) > 1 .AND. !Empty(aTagVal[2])
            If (F5V->(dbSeek(xFilial("F5V")+cFormatCode+"3"+aTagVal[1])).AND. !lSecEnd ) ;
             .OR. (F5V->(dbSeek(xFilial("F5V")+cFormatCode+"1"+aTagVal[1])) .AND. lSecEnd)
                If F5V->F5V_TAGTYP == "3"
                    xValue := VAL(aTagVal[2])
                elseif F5V->F5V_TAGTYP == "2"
                    xValue := CTOD(aTagVal[2])
                else
                    xValue := aTagVal[2]
                endif
                If F6J->(dbSeek(xFilial("F6J")+F5V->F5V_VALUE))
                    If F6J->F6J_RELTYP == "1" .AND. !lHeadEnd
                        oModelMaster:SetValue(F6J->F6J_BLOCK, xValue)
                    elseif F6J->F6J_RELTYP == "2"
                        If F6J->F6J_CONCAT == "1" .AND. aScan(aFields, AllTrim(F6J->F6J_BLOCK)) > 0
                            aValues[aScan(aFields, AllTrim(F6J->F6J_BLOCK))] += (Chr(13) + Chr(10)) + xValue
                        Else
                            aAdd(aFields, AllTrim(F6J->F6J_BLOCK))
                            aAdd(aValues, xValue)
                        Endif
                        If aScan(aFields, "F6W_OPDATE") == 0 
                            If aScan(aFields, "F6W_FRDATE") > 0 
                                aAdd(aFields, "F6W_OPDATE")
                                aAdd(aValues, aValues[aScan(aFields, "F6W_FRDATE")])
                            elseif aScan(aFields, "F6W_TODATE") > 0 
                                aAdd(aFields, "F6W_OPDATE")
                                aAdd(aValues, aValues[aScan(aFields, "F6W_TODATE")])
                            Endif                            
                        Endif                            
                        If !lLnChckd .AND. aScan(aFields, "F6W_DOCDAT") > 0 ;
                                .AND. aScan(aFields, "F6W_OPDATE") > 0 
                            If aValues[aScan(aFields, "F6W_DOCDAT")] < MV_PAR05 ; 
                                    .AND. aValues[aScan(aFields, "F6W_OPDATE")] < MV_PAR05 
                                aFields := {}
                                aValues := {}
                                lNeedSkip := .T.
                            Endif
                            lLnChckd := .T.
                            If aScan(aFields, "F6W_DOCDAT")> 0 .AND. aValues[aScan(aFields, "F6W_DOCDAT")] > MV_PAR06 ; 
                                    .AND. aScan(aFields, "F6W_OPDATE") > 0 .AND. aValues[aScan(aFields, "F6W_OPDATE")] > MV_PAR06  
                                aFields := {}
                                aValues := {}
                                EXIT
                            Endif
                        Endif                     
                    Endif    
                Endif
            Endif    
        Endif
    NEXT

    RestArea(aAreaF5V)
    RestArea(aAreaF5U)
    RestArea(aAreaF6J)  
    RestArea(aSaveArea) 

Return NIL

/*/{Protheus.doc} RU06D10008_FillGrid
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params oModel as Object
@return NIL
@type function
@description fill data in grid after parsing
*/
Function RU06D10008_FillGrid(oModel as Object)
    Local oModelDetail as Object
    Local oModelMaster as Object
    Local nSumWrtn     as Numeric
    Local nSumRecv     as Numeric
    Local nX           as Numeric
    Local nCnt         as Numeric
    Local aSaveArea    as Array
    Local aAreaF49     as Array
    Local aAreaF5Q     as Array
    Local aAreaF5R     as Array
    Local aAreaSA1     as Array
    Local aAreaSA2     as Array
    Local aF4Cdata     as Array

    nX       := 1
    nSumWrtn := 0
    nSumRecv := 0

    oModelMaster := oModel:GetModel("F6XMASTER")
    oModelDetail := oModel:GetModel("F6WDETAIL")
    
    aSaveArea := GetArea() 
    aAreaF49 := F49->(GetArea())
    aAreaF5Q := F5Q->(GetArea())
    aAreaF5R := F5R->(GetArea())
    aAreaSA1 := SA1->(GetArea())
    aAreaSA2 := SA2->(GetArea())   
    dbSelectArea('F49')
    F49->(DbOrderNickName('PAYREC'))   
    dbSelectArea('F5Q')
    F5Q->(dbSetOrder(1))  
    dbSelectArea('F5R')
    F5R->(dbSetOrder(3))
    dbSelectArea('SA1')
    SA1->(DbOrderNickName('KPPINN'))
    // SA1->(dbSetOrder(14))
    dbSelectArea('SA2')
    SA2->(DbOrderNickName('KPPINN'))
    // SA2->(dbSetOrder(11))

    FOR nCnt := 1 TO oModelDetail:Length(.T.)
        oModelDetail:GoLine(nCnt)
        
        If !EMPTY( oModelDetail:GetValue("F6W_FRDATE") )
            oModelDetail:SetValue("F6W_OPDATE", oModelDetail:GetValue("F6W_FRDATE"))
            oModelDetail:SetValue("F6W_WRITT", oModelDetail:GetValue("F6W_AMOUNT"))
            nSumWrtn += oModelDetail:GetValue("F6W_AMOUNT")
            // If Date Written filled than contragent is Reciever
            oModelDetail:SetValue("F6W_BNKACC", oModelDetail:GetValue("F6W_TOBACC"))
            // If Date Written filled - begin seek in Suppliers, atfer in Clients
            if SA2->(dbSeek(xFilial("SA2")+oModelDetail:GetValue("F6W_TOKPP")+oModelDetail:GetValue("F6W_TOINN")))
                oModelDetail:SetValue("F6W_TYPCON", '2')
                oModelDetail:SetValue("F6W_PAYTYP", '1')
                oModelDetail:SetValue("F6W_CONBRN", SA2->A2_LOJA)
                oModelDetail:LoadValue("F6W_CONNAM", SA2->A2_NOME)
                oModelDetail:SetValue("F6W_CONCOD", SA2->A2_COD)
            Elseif SA1->(dbSeek(xFilial("SA1")+oModelDetail:GetValue("F6W_TOKPP")+oModelDetail:GetValue("F6W_TOINN")))
                oModelDetail:SetValue("F6W_TYPCON", '1')
                oModelDetail:SetValue("F6W_PAYTYP", '2')
                oModelDetail:SetValue("F6W_CONBRN", SA1->A1_LOJA)
                oModelDetail:LoadValue("F6W_CONNAM", SA1->A1_NOME)
                oModelDetail:SetValue("F6W_CONCOD", SA1->A1_COD)
            Endif
            If RU06D10018_GetCountQuery(DTOS(oModelDetail:GetValue('F6W_DOCDAT')), oModelDetail:GetValue('F6W_FRBACC'), oModelDetail:GetValue('F6W_TOBACC')) == 1
                F49->(dbSeek(xFilial("F49")+DTOS(oModelDetail:GetValue('F6W_DOCDAT'))+oModelDetail:GetValue('F6W_FRBACC')+oModelDetail:GetValue('F6W_TOBACC')))
                If F49->F49_VALUE == oModelDetail:GetValue('F6W_AMOUNT')
                    oModelDetail:SetValue("F6W_UIDF49", F49->F49_IDF49)
                    oModelDetail:SetValue("F6W_PAYORD", F49->F49_PAYORD)
                    oModelDetail:SetValue("F6W_UIDF5Q", F49->F49_F5QUID)
                    oModelDetail:SetValue("F6W_CNT", F49->F49_CNT)
                    F5Q->(dbSetOrder(1))
                    If !Empty(F49->F49_F5QUID) .And. F5Q->(dbSeek(xFilial("F5Q")+F49->F49_F5QUID))
                        oModelDetail:LoadValue("F6W_CNTDES", F5Q->F5Q_DESCR)
                        F5R->(dbSetOrder(3))
                        If F5R->(dbSeek(xFilial("F5R")+F49->F49_F5QUID)) 
                            oModelDetail:SetValue("F6W_CLASS", F5R->F5R_NATURE)              
                        Endif          
                    Endif
                    aF4Cdata := RU06D10047_FillF4CbyF49(F49->F49_PAYORD, F49->F49_IDF49)
                    If Len(aF4Cdata) == 2
                        oModelDetail:LoadValue('F6W_BNKNUM', aF4Cdata[1])
                        oModelDetail:LoadValue('F6W_UIDF4C', aF4Cdata[2])
                    EndIf         
                Endif          
            Endif          
        elseif !EMPTY( oModelDetail:GetValue("F6W_TODATE") )
            oModelDetail:SetValue("F6W_OPDATE", oModelDetail:GetValue("F6W_TODATE"))
            oModelDetail:SetValue("F6W_RECEIV", oModelDetail:GetValue("F6W_AMOUNT"))
            nSumRecv += oModelDetail:GetValue("F6W_AMOUNT")
            // If Date Recieved filled than contragent is Payer
            oModelDetail:SetValue("F6W_BNKACC", oModelDetail:GetValue("F6W_FRBACC"))
            // If Date Recieved filled - begin seek in Clients, atfer in Suppliers
            If SA1->(dbSeek(xFilial("SA1")+oModelDetail:GetValue("F6W_FRKPP")+oModelDetail:GetValue("F6W_FRINN")))
                oModelDetail:SetValue("F6W_TYPCON", '1')
                oModelDetail:SetValue("F6W_PAYTYP", '1')
                oModelDetail:SetValue("F6W_CONBRN", SA1->A1_LOJA)
                oModelDetail:LoadValue("F6W_CONNAM", SA1->A1_NOME)
                oModelDetail:SetValue("F6W_CONCOD", SA1->A1_COD)
            Elseif SA2->(dbSeek(xFilial("SA2")+oModelDetail:GetValue("F6W_FRKPP")+oModelDetail:GetValue("F6W_FRINN")))
                oModelDetail:SetValue("F6W_TYPCON", '2')
                oModelDetail:SetValue("F6W_PAYTYP", '2')
                oModelDetail:SetValue("F6W_CONBRN", SA2->A2_LOJA)
                oModelDetail:LoadValue("F6W_CONNAM", SA2->A2_NOME)
                oModelDetail:SetValue("F6W_CONCOD", SA2->A2_COD)
            Endif         
        Endif
    NEXT

    oModelMaster:SetValue("F6X_TOTPAY", nSumWrtn)
    oModelMaster:SetValue("F6X_TOTREC", nSumRecv)
    lParsed := .T.

    RestArea(aAreaSA2)
    RestArea(aAreaSA1)
    RestArea(aAreaF49)  
    RestArea(aAreaF5R)  
    RestArea(aAreaF5Q)  
    RestArea(aSaveArea) 

Return NIL                                                                                                   

/*/{Protheus.doc} RU06D10009_Pergunte
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return lRet as Logical
@type function
@description calls window for parameters
*/
Function RU06D10009_Pergunte()
    Local cPerg  as Character

    cPerg  := "RU06D10"
    lStopFile := .T.

    /* Pergunte should not be closed, until user will not press Cancel or Formec code for export (F5N) will not be found */
    While lStopFile 
        lStopFile := Pergunte(cPerg,.T.,STR0003,.F.) // Import from client-bank
        If lStopFile
            RptStatus({||RU06D10031_CheckPergunte()}, STR0040,STR0041, .T. ) // Wait...
        Endif
    EndDo

Return lStopFile

/*/{Protheus.doc} RU06D10010_Delete
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return lRet as Logical
@type function
@description checks and deletes line of f6x
*/
Function RU06D10010_Delete()
    Local lRet      As Logical
    Local cStatus   As Character

    lRet  := .T.
    cStatus        := F6X->F6X_STATUS

    If cStatus != "1"    //try to delete
        HELP("",1, STR0029,,STR0030,1,0,,,,,,{STR0031}) // Deletion is impossible!
        lRet := .F.
    Else
        lRet := MSGYESNO(STR0032, STR0033) // Delete
    Endif

    If lRet
        FWExecView("","RU06D10",5,,{|| .T.})
    EndIf
Return lRet

/*/{Protheus.doc} RU06D10011_BnkStateCreation
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return NIL
@type function
@description creation bank statements through calling ru06d07
*/
Function RU06D10011_BnkStateCreation()
    Local lRes      as Logical
    Local lInclui := INCLUI  as Logical
    Local lBrowse := .F.  as Logical
    Local oModel    as Object
    Local oModelBS  as Object
    Local oModelF4C as Object
    Local oModelMaster as Object
    Local oModelDetail as Object
    Local aBSLines as Array
    Local aErrors as Array
    Local nCnt as Numeric
    Local aSaveArea    as Array
    Local aAreaF49     as Array
    Local aAreaF4N     as Array
    Local aAreaF6W     as Array
    Local aAreaFIL     as Array
    Local aAreaF5Q     as Array
    Local aAreaF5R     as Array
    Private cOperDirection As Character
    Private INCLUI := .T.  As Logical

    aSaveArea := GetArea() 
    aAreaSA6 := SA6->(GetArea())
    aAreaF49 := F49->(GetArea())
    aAreaF4N := F4N->(GetArea())
    aAreaF6W := F6W->(GetArea())
    aAreaFIL := FIL->(GetArea())
    aAreaF5Q := F5Q->(GetArea())
    aAreaF5R := F5R->(GetArea())
    dbSelectArea('F49')
    F49->(dbSetOrder(2))
    dbSelectArea('F4N')
    F4N->(dbSetOrder(4))   // F4N_FILIAL+F4N_CLIENT+F4N_LOJA+F4N_ACC 
    dbSelectArea('F6W')
    F6W->(dbSetOrder(2)) // F6W_FILIAL+F6W_UIDF6X+F6W_LINE
    dbSelectArea('FIL')
    FIL->(dbSetOrder(5))  // FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_CONTA    
    dbSelectArea('F5Q')
    F5Q->(dbSetOrder(1))  
    dbSelectArea('F5R')
    F5R->(dbSetOrder(3))
    dbSelectArea("SA6")
    SA6->(dbSetOrder(1))
    
    oModel := FWModelActive()
    If ValType(oModel) != "O" .Or. oModel:cId != "RU06D10"
        oModel := FwLoadModel("RU06D10")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()
        lBrowse := .T.
    Endif
    oModelMaster := oModel:GetModel("F6XMASTER")
    oModelDetail := oModel:GetModel("F6WDETAIL")
    aBSLines := {}
    FOR nCnt := 1 TO oModelDetail:Length(.F.)
        oModelDetail:GoLine(nCnt)
        If !oModelDetail:IsDeleted()
            If Empty(oModelDetail:GetValue("F6W_UIDF4C")) .And. oModelDetail:GetValue("F6W_PAYTYP") == "1"
                aAdd(aBSLines, nCnt)
            Endif
        Endif
    NEXT
    If Empty(aBSLines)
        AutoGrLog( STR0060 )
    Endif
    FOR nCnt := 1 TO Len(aBSLines)
        oModelDetail:GoLine(aBSLines[nCnt])
        If !Empty(oModelDetail:GetValue("F6W_PAYORD"))
            F49->(dbSetOrder(2))
            If F49->(dbSeek(xFilial("F49")+oModelDetail:GetValue("F6W_UIDF49")))
                If F49->F49_STATUS != "2"
                    AutoGrLog(STR0059 + oModelDetail:GetValue("F6W_LINE")) // Line 
                    AutoGrLog(STR0065) // PO must have status equel "2" for creating BS
                    LOOP
                Endif 
            Endif 
        Endif 
        cOperDirection := Iif(!Empty(oModelDetail:GetValue("F6W_RECEIV")),"1","2") + "|" + AllTrim(oModelDetail:GetValue("F6W_PAYTYP"))
        oModelBS := FwLoadModel("RU06D07")
        RU06D07739_SetAutoBs(.T.) // Set "Auto" mod 
        oModelBS:SetOperation(MODEL_OPERATION_INSERT)
        oModelBS:Activate()
        oModelF4C := oModelBS:GetModel("RU06D07_MHEAD")
        lRes := oModelF4C:SetValue("F4C_STATUS", "1")
        lRes := lRes .And. oModelF4C:SetValue("F4C_ADVANC", "1")
        If !Empty(oModelDetail:GetValue("F6W_PAYORD"))
            F49->(dbSetOrder(2))
            If F49->(dbSeek(xFilial("F49")+oModelDetail:GetValue("F6W_UIDF49")))
                lRes := lRes .And. oModelF4C:LoadValue("F4C_IDF49", oModelDetail:GetValue("F6W_UIDF49"))
                lRes := lRes .And. oModelF4C:SetValue("F4C_PAYORD", oModelDetail:GetValue("F6W_PAYORD"))
                lRes := lRes .And. oModelF4C:LoadValue("F4C_ADVANC", "1")
                lRes := lRes .And. oModelF4C:LoadValue("F4C_DTTRAN", oModelDetail:GetValue("F6W_OPDATE"))
                lRes := lRes .And. oModelF4C:LoadValue("F4C_CLASS", oModelDetail:GetValue("F6W_CLASS"))
            Endif
        Else
            lRes := lRes .And. oModelF4C:LoadValue("F4C_DTPAYM", oModelDetail:GetValue("F6W_OPDATE"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_BNKORD", SubStr(AllTrim(oModelDetail:GetValue("F6W_DOCNUM")),1,6))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_ADVANC", "1")
            lRes := lRes .And. oModelF4C:LoadValue("F4C_DTTRAN", oModelDetail:GetValue("F6W_OPDATE"))
            If oModelDetail:GetValue("F6W_TYPCON") == "1" 
                lRes := lRes .And. oModelF4C:LoadValue("F4C_CUST", oModelDetail:GetValue("F6W_CONCOD"))
                lRes := lRes .And. oModelF4C:LoadValue("F4C_CUNI", oModelDetail:GetValue("F6W_CONBRN"))       
            Elseif oModelDetail:GetValue("F6W_TYPCON") == "2" 
                lRes := lRes .And. oModelF4C:LoadValue("F4C_SUPP", oModelDetail:GetValue("F6W_CONCOD"))
                lRes := lRes .And. oModelF4C:LoadValue("F4C_UNIT", oModelDetail:GetValue("F6W_CONBRN"))
            Endif
            If !Empty(oModelDetail:GetValue("F6W_RECEIV"))
                lRes := lRes .And. oModelF4C:LoadValue("F4C_VALUE", oModelDetail:GetValue("F6W_RECEIV"))
                lRes := lRes .And. oModelF4C:LoadValue("F4C_BNKREC", oModelMaster:GetValue("F6X_BNKCOD"))
                If oModelDetail:GetValue("F6W_PAYTYP") == "1"
                    If F4N->(dbSeek(xFilial("F4N")+oModelDetail:GetValue("F6W_CONCOD")+oModelDetail:GetValue("F6W_CONBRN")+oModelDetail:GetValue("F6W_BNKACC")))
                        lRes := lRes .And. oModelF4C:LoadValue("F4C_BNKPAY", F4N->F4N_BANK)
                    Endif
                Elseif oModelDetail:GetValue("F6W_PAYTYP") == "2"
                    If FIL->(dbSeek(xFilial("FIL")+oModelDetail:GetValue("F6W_CONCOD")+oModelDetail:GetValue("F6W_CONBRN")+oModelDetail:GetValue("F6W_BNKACC")))
                        lRes := lRes .And. oModelF4C:LoadValue("F4C_BNKPAY", FIL->FIL_BANCO)
                    Endif
                Endif
            Else
                lRes := lRes .And. oModelF4C:LoadValue("F4C_VALUE", oModelDetail:GetValue("F6W_WRITT"))
                lRes := lRes .And. oModelF4C:LoadValue("F4C_BNKPAY", oModelMaster:GetValue("F6X_BNKCOD")) 
                If oModelDetail:GetValue("F6W_PAYTYP") == "1" .Or. ;
                        oModelDetail:GetValue("F6W_PAYTYP") == "3" .Or. ;
                        oModelDetail:GetValue("F6W_PAYTYP") == "5"
                    If FIL->(dbSeek(xFilial("FIL")+oModelDetail:GetValue("F6W_CONCOD")+oModelDetail:GetValue("F6W_CONBRN")+oModelDetail:GetValue("F6W_BNKACC")))
                        lRes := lRes .And. oModelF4C:LoadValue("F4C_BNKREC", FIL->FIL_BANCO)
                    Endif
                Elseif  oModelDetail:GetValue("F6W_PAYTYP") == "2"
                    If F4N->(dbSeek(xFilial("F4N")+oModelDetail:GetValue("F6W_CONCOD")+oModelDetail:GetValue("F6W_CONBRN")+oModelDetail:GetValue("F6W_BNKACC")))
                        lRes := lRes .And. oModelF4C:LoadValue("F4C_BNKREC", F4N->F4N_BANK)
                    Endif
                Endif
            Endif
            If SA6->(dbSeek(xFilial("SA6")+oModelMaster:GetValue("F6X_BNKCOD")+oModelMaster:GetValue("F6X_BIK")+oModelMaster:GetValue("F6X_ACCNT")))
                lRes := lRes .And. oModelF4C:LoadValue("F4C_CURREN", Padl(cValToChar(SA6->A6_MOEDA),2,"0"))
            Endif
            lRes := lRes .And. oModelF4C:LoadValue("F4C_UIDF5Q", oModelDetail:GetValue("F6W_UIDF5Q"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_CNT", oModelDetail:GetValue("F6W_CNT"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_CLASS", oModelDetail:GetValue("F6W_CLASS"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_KPPREC", oModelDetail:GetValue("F6W_TOKPP"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_RECBIK", oModelDetail:GetValue("F6W_TOBIK"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_RECACC", oModelDetail:GetValue("F6W_TOBACC"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_RECNAM", oModelDetail:GetValue("F6W_RECVER"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_KPPPAY", oModelDetail:GetValue("F6W_FRKPP"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_PAYBIK", oModelDetail:GetValue("F6W_FRBIK"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_PAYACC", oModelDetail:GetValue("F6W_FRBACC"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_PAYNAM", oModelDetail:GetValue("F6W_PAYER"))
            lRes := lRes .And. oModelF4C:LoadValue("F4C_REASON", oModelDetail:GetValue("F6W_REASON"))
            F5Q->(dbSetOrder(1))
            If F5Q->(dbSeek(xFilial("F5Q")+oModelDetail:GetValue("F6W_UIDF5Q")))
                lRes := lRes .And. oModelF4C:LoadValue("F4C_CTPRE", F5Q->F5Q_ADVAC)
                lRes := lRes .And. oModelF4C:LoadValue("F4C_CCPRE", F5Q->F5Q_EC02DB)
                lRes := lRes .And. oModelF4C:LoadValue("F4C_ITPRE", F5Q->F5Q_EC03DB)
                lRes := lRes .And. oModelF4C:LoadValue("F4C_CLPRE", F5Q->F5Q_ADVAR)
                lRes := lRes .And. oModelF4C:LoadValue("F4C_CTPOS", F5Q->F5Q_PRFAC)
                lRes := lRes .And. oModelF4C:LoadValue("F4C_CCPOS", F5Q->F5Q_EC02DB)
                lRes := lRes .And. oModelF4C:LoadValue("F4C_ITPOS", F5Q->F5Q_EC03DB)
                lRes := lRes .And. oModelF4C:LoadValue("F4C_CLPOS", F5Q->F5Q_PRFAR)
                F5R->(dbSetOrder(3))
                If F5R->(dbSeek(xFilial("F5R")+F49->F49_F5QUID))
                    lRes := lRes .And. oModelF4C:LoadValue("F4C_VATCOD", F5R->F5R_VATCOD)              
                    lRes := lRes .And. oModelF4C:LoadValue("F4C_VATRAT", F5R->F5R_VATRAT) 
                    lRes := lRes .And. oModelF4C:LoadValue("F4C_VATAMT", ROUND(oModelF4C:GetValue("F4C_VALUE")*F5R->F5R_VATRAT/(100+ F5R->F5R_VATRAT),2))              
                Endif          
            Endif
        Endif
        If lRes := oModelBS:VldData()
            lRes := oModelBS:CommitData()
        Endif
        AutoGrLog(STR0059 + oModelDetail:GetValue("F6W_LINE")) // Line 
        if lRes
            If lInclui
                oModelDetail:LoadValue("F6W_UIDF4C", oModelF4C:GetValue("F4C_CUUID")) 
                oModelDetail:LoadValue("F6W_BNKNUM", oModelF4C:GetValue("F4C_INTNUM"))
            Else 
                If F6W->(dbSeek(xFilial("F6W")+oModelDetail:GetValue("F6W_UIDF6X")+oModelDetail:GetValue("F6W_LINE")))
                    If F6W->(RecLock("F6W",.F.))
                        F6W->F6W_BNKNUM := oModelF4C:GetValue("F4C_INTNUM")
                        F6W->F6W_UIDF4C := oModelF4C:GetValue("F4C_CUUID")
                        F6W->(MsUnLock())
                    Endif
                Endif
            Endif
            AutoGrLog(STR0048 + oModelF4C:GetValue("F4C_INTNUM") + STR0049 + CRLF + CRLF) // "BS ", " created succesfully"
        Else
            aErrors := oModelBS:GetErrorMessage()
            If !Empty(aErrors[1])
                AutoGrLog(STR0050 + AllToChar( aErrors[1] ) + CRLF) // "Form ID Origin: "
            Endif
            If !Empty(aErrors[2])
                AutoGrLog(STR0051 + AllToChar( aErrors[2] ) + CRLF) // "Field Origin: "
            Endif
            If !Empty(aErrors[3])
                AutoGrLog(STR0052 + AllToChar( aErrors[3] ) + CRLF) // Form ID error: 
            Endif
            If !Empty(aErrors[4])
                AutoGrLog(STR0053 + AllToChar( aErrors[4] ) + CRLF) // "Field Error: "
            Endif
            If !Empty(aErrors[5])
                AutoGrLog(STR0054 + AllToChar( aErrors[5] ) + CRLF) // "Error ID: "
            Endif
            If !Empty(aErrors[6])
                AutoGrLog(STR0055 + AllToChar( aErrors[6] ) + CRLF) // "Error message: "
            Endif
            If !Empty(aErrors[7])
                AutoGrLog(STR0056 + AllToChar( aErrors[7] ) + CRLF) // Solution Message: 
            Endif
            If !Empty(aErrors[8])
                AutoGrLog(STR0057 + AllToChar( aErrors[8] ) + CRLF) // Value assigned: 
            Endif
            If !Empty(aErrors[9])
                AutoGrLog(STR0058 + AllToChar( aErrors[9] ) + CRLF + CRLF) // Previous value: 
            Endif
        Endif

        oModelBS:DeActivate()
        oModelBS:Destroy()
        RU06D07739_SetAutoBs(.F.) // Set not "Auto" mod 
    NEXT

    RestArea(aAreaFIL)
    RestArea(aAreaF4N) 
    RestArea(aAreaF6W) 
    RestArea(aAreaF49) 
    RestArea(aAreaF5R)
    RestArea(aAreaF5Q)
    RestArea(aAreaSA6)
    RestArea(aSaveArea)
    RU06D10042_SetStatus(oModel)
    If lBrowse
        oModel:DeActivate()
        oModel:Destroy()
    Endif

Return NIL

/*/{Protheus.doc} RU06D10012_PostedToFI
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return NIL
@type function
@description action for posting to Finance
*/
Function RU06D10012_PostedToFI()
    Local lPosted   as Logical
    Local lNotPO    as Logical
    Local lBrowse := .F.  as Logical
    Local oModel       as Object
    Local oModelMaster as Object
    Local oModelDetail as Object
    Local aBSLines as Array
    Local nCnt as Numeric
    Local aSaveArea    as Array
    Local aAreaF4C     as Array

    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())
    dbSelectArea('F4C')
    F4C->(dbSetOrder(5))   // F4C_FILIAL+F4C_CUUID
    
    oModel := FWModelActive()
    If ValType(oModel) != "O" .Or. oModel:cId != "RU06D10"
        oModel := FwLoadModel("RU06D10")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()
        lBrowse := .T.
    Endif
    oModelMaster := oModel:GetModel("F6XMASTER")
    oModelDetail := oModel:GetModel("F6WDETAIL")
    lPosted := .F.
    lNotPO := .F.
    aBSLines := {}
    FOR nCnt := 1 TO oModelDetail:Length(.F.)
        oModelDetail:GoLine(nCnt)
        If !oModelDetail:IsDeleted()
            If !Empty(oModelDetail:GetValue("F6W_UIDF4C")) .And. !Empty(oModelDetail:GetValue("F6W_PAYORD"))
                If F4C->(dbSeek(xFilial("F4C")+oModelDetail:GetValue("F6W_UIDF4C")))
                    If F4C->F4C_STATUS == '1' .Or. F4C->F4C_STATUS == '4'
                        aAdd(aBSLines, nCnt)
                    Else 
                        lPosted := .T.
                    Endif
                Endif
            Elseif !Empty(oModelDetail:GetValue("F6W_UIDF4C")) .And. Empty(oModelDetail:GetValue("F6W_PAYORD"))
                lNotPO := .T.
            Endif
        Endif
    NEXT
    If Empty(aBSLines) .And. lPosted
        Help("",1,STR0066,,STR0067,1,0) // "Posted", Journal already posted in Finance
    Elseif Empty(aBSLines) .And. !lPosted
        Help("",1,STR0068,,STR0069,1,0) // "Empty", "Not records for posting"
    Elseif !Empty(aBSLines) .And. lNotPO
        Help("",1,STR0070,,STR0071,1,0) // "Not PO", "In package mode only lines with references to payorders will be posted ti Finance!"
    Endif

    If !Empty(aBSLines)
        MsAguarde({|| RU06D10044_PostedToFI(oModel, aBSLines)}, STR0046, STR0079) // "Please wait", "Bank Statements are posting to Finance..."
        MostraErro()
    Endif
    
    RestArea(aAreaF4C) 
    RestArea(aSaveArea)
    RU06D10042_SetStatus(oModel)
    If lBrowse
        oModel:DeActivate()
        oModel:Destroy()
    Endif
Return NIL

/*/{Protheus.doc} RU06D10013_PostedToAcnt
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return NIL
@type function
@description action for posting to Accounting
*/
Function RU06D10013_PostedToAcnt()
    Local lErrStat  as Logical
    Local lRes      as Logical
    Local lBrowse := .F.  as Logical
    Local oModel    as Object
    Local oModelMaster as Object
    Local oModelDetail as Object
    Local aBSLines as Array
    Local nCnt     as Numeric
    Local nCntBS   as Numeric
    Local nPosted  as Numeric
    Local aSaveArea    as Array
    Local aAreaF4C     as Array

    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())
    dbSelectArea('F4C')
    F4C->(dbSetOrder(5))   // F4C_FILIAL+F4C_CUUID
    
    oModel := FWModelActive()
    If ValType(oModel) != "O" .Or. oModel:cId != "RU06D10"
        oModel := FwLoadModel("RU06D10")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()
        lBrowse := .T.
    Endif
    oModelMaster := oModel:GetModel("F6XMASTER")
    oModelDetail := oModel:GetModel("F6WDETAIL")
    lErrStat := .F.
    lRes := .T.
    nPosted := 0
    nCntBS := 0
    aBSLines := {}
    FOR nCnt := 1 TO oModelDetail:Length(.F.)
        oModelDetail:GoLine(nCnt)
        If !oModelDetail:IsDeleted()
            If !Empty(oModelDetail:GetValue("F6W_UIDF4C"))
                nCntBS += 1
                If F4C->(dbSeek(xFilial("F4C")+oModelDetail:GetValue("F6W_UIDF4C")))
                    If F4C->F4C_STATUS == '2'  .Or. F4C->F4C_STATUS == '5'
                        aAdd(aBSLines, nCnt)
                    Elseif F4C->F4C_STATUS == '7'
                        nPosted += 1
                        lErrStat := .T.
                    else
                        lErrStat := .T.
                    Endif
                Endif
            Endif
        Endif
    NEXT
    If lErrStat .And. nPosted == nCntBS
        Help("",1,STR0066,,STR0075,1,0) // "Posted","Journal already posted in Accounting"
        lRes := .F.
    Elseif !Empty(aBSLines) .And. lErrStat
        Help("",1,STR0073,,STR0074,1,0) // "Status","All bank statements must be posted in Finance"
        lRes := .F.
    Elseif Empty(aBSLines)
        Help("",1,STR0068,,STR0069,1,0) // "Empty",,"Not records for posting"
        lRes := .F.  
    Endif
    If lRes
        MsAguarde({|| RU06D10045_PostedToAcnt(oModel, aBSLines)}, STR0046, STR0080) // "Please wait", "Bank Statements are posting to Accounting..."
        MostraErro()
    Endif
    
    RestArea(aAreaF4C) 
    RestArea(aSaveArea)
    RU06D10042_SetStatus(oModel)
    If lBrowse
        oModel:DeActivate()
        oModel:Destroy()
    Endif
Return NIL

/*/{Protheus.doc} RU06D10014_Legenda
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return aRet as Array
@type function
@description calls windows with legend (status)
*/
Function RU06D10014_Legenda()
    Local aRet as Array 

    aRet := {}

    aAdd(aRet,{ "BR_BRANCO", STR0001 })     // Not related
    aAdd(aRet,{ "BR_VERDE", STR0002 })      // Related to BS
    aAdd(aRet,{ "BR_AZUL", STR0013 })       // Posted in Finance
    aAdd(aRet,{ "BR_LARANJA", STR0014 })    // Posted in Accounting
    aAdd(aRet,{ "BR_VERMELHO", STR0015 })   // Partially posted in Finance
    aAdd(aRet,{ "BR_PRETO", STR0016 })      // Partially posted in Accounting

    BrwLegenda(STR0003,STR0009, aRet) // Import from client-bank, Legend

Return aRet

/*/{Protheus.doc} RU06D10015_CheckAcc
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params aLinesFile as Array
@return lAccExists as Logical
@type function
@description checks account in file
*/
Function RU06D10015_CheckAcc(aLinesFile as Array)
    Local lAccExists as Logical
    Local nCnt as Numeric 

    lAccExists := .F.

    FOR nCnt := 1 TO LEN(aLinesFile)
        If (AllTrim(MV_PAR03) $ aLinesFile[nCnt]) // .OR. (AllTrim(MV_PAR03) $ DecodeUTF8(aLinesFile[nCnt], "cp1251"))
            lAccExists := .T.
            EXIT
        Endif
    NEXT
Return lAccExists

/*/{Protheus.doc} RU06D10016_UpdTotal
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params cField as Chacracter
        oModel as Object
        lVld as Logical
        lDel as Logical
        nLine as Number
@return nValue as Number
@type function
@description update the sum of values in lines of grid after changing or deleting lines
*/
Function RU06D10016_UpdTotal(cField, oModel, lVld, lDel, nLine)
    Local nSum as Numeric
    Local oModelDetail as Object
    Local oModelMaster as Object
    Local nCnt         as Numeric
    Local nValue       as Numeric
    Local lRet         as Logical
    DEFAULT lVld := .F.
    DEFAULT lDel := .F.
    DEFAULT nLine := oModel:GetModel("F6WDETAIL"):GetLine()
    
    oModelDetail := oModel:GetModel("F6WDETAIL")
    nValue := oModelDetail:GetValue(cField)

    If lParsed
        nSum := 0
        oModelMaster := oModel:GetModel("F6XMASTER")
        FOR nCnt := 1 TO oModelDetail:Length(.F.)
            lRet := .F.
            oModelDetail:GoLine(nCnt)
            lRet := !lVld .AND. oModelDetail:IsDeleted(nCnt)
            lRet := lRet .OR. (lVld .AND. lDel .AND. nCnt == nLine)
            If lRet
                LOOP
            Endif
            If cField == "F6W_WRITT"
                nSum += oModelDetail:GetValue("F6W_WRITT")
            elseif cField == "F6W_RECEIV"
                nSum += oModelDetail:GetValue("F6W_RECEIV")
            Endif
        NEXT
        If cField == "F6W_WRITT"
            oModelMaster:SetValue("F6X_TOTPAY", nSum)
        elseif cField == "F6W_RECEIV"
            oModelMaster:SetValue("F6X_TOTREC", nSum)
        Endif
        oModelDetail:GoLine(nLine)
    Endif
Return nValue

/*/{Protheus.doc} RU06D10017_UpdateRef
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return NIL
@type function
@description action for updating references
*/
Function RU06D10017_UpdateRef()
    Local lSeek     as Logical
    Local lIsBS     as Logical
    Local lIsPO     as Logical
    Local lWasDel   as Logical
    Local lWasUpd   as Logical
    Local oModel    as Object
    Local oModelDetail as Object
    Local cOper as Character
    Local cRectyp as Character
    Local cPaytyp as Character
    Local nCnt as Numeric
    Local aSaveArea    as Array
    Local aAreaF49     as Array
    Local aAreaF4C     as Array

    aSaveArea := GetArea() 
    aAreaF49 := F49->(GetArea())
    aAreaF4C := F4C->(GetArea())
    dbSelectArea('F49')
    F49->(DbOrderNickName('PAYREC')) // DTOS(F49_DTPAYM)+F49_PAYACC+F49_RECACC
    dbSelectArea('F4C')
    F4C->(DbOrderNickName('REFIMP'))    // DTOS(F4C_DTTRAN)+F4C_OPER+F4C_RECTYP+F4C_PAYTYP+F4C_RECACC+F4C_PAYACC
    
    oModel := FWModelActive()
    oModelDetail := oModel:GetModel("F6WDETAIL")
    lWasDel := .F.
    lWasUpd := .F.
    FOR nCnt := 1 TO oModelDetail:Length(.F.)
        oModelDetail:GoLine(nCnt)
        If !oModelDetail:IsDeleted()
            If !Empty(oModelDetail:GetValue("F6W_RECEIV"))
                cOper := "1"
                cRectyp := oModelDetail:GetValue("F6W_PAYTYP")
                cPaytyp := "0"
            Else 
                cOper := "2"
                cRectyp := "0"
                cPaytyp := oModelDetail:GetValue("F6W_PAYTYP")
            Endif 
            // DTOS(F49_DTPAYM)+F49_PAYACC+F49_RECACC
            lIsPO := .F.
            lSeek := F49->(dbSeek(xFilial("F49")+DTOS(oModelDetail:GetValue("F6W_DOCDAT")) + ;
                    oModelDetail:GetValue("F6W_FRBACC") + oModelDetail:GetValue("F6W_TOBACC")))
            WHILE lSeek
                If DTOS(oModelDetail:GetValue("F6W_DOCDAT")) == DTOS(F49->F49_DTPAYM) .And. ;
                        oModelDetail:GetValue("F6W_FRBACC") == F49->F49_PAYACC .And. oModelDetail:GetValue("F6W_TOBACC") == F49->F49_RECACC
                    If F49->F49_VALUE == oModelDetail:GetValue("F6W_AMOUNT")
                        lIsPO := .T.
                        lSeek := .F.
                    Else 
                        F49->(dbSkip())
                    Endif
                else
                    lSeek := .F.
                Endif
            EndDo
            If lIsPO 
                If oModelDetail:GetValue("F6W_UIDF49") != F49->F49_IDF49 .Or. oModelDetail:GetValue("F6W_PAYORD") != F49->F49_PAYORD
                    oModelDetail:LoadValue("F6W_UIDF49", F49->F49_IDF49)
                    oModelDetail:LoadValue("F6W_PAYORD", F49->F49_PAYORD)
                    lWasUpd := .T.
                Endif
            Else
                If !Empty(oModelDetail:GetValue("F6W_PAYORD"))
                    lWasDel := .T.
                Endif
                oModelDetail:LoadValue("F6W_UIDF49", oModelDetail:GetValue("F6W_LINE"))
                oModelDetail:LoadValue("F6W_PAYORD", Space(TamSX3("F6W_PAYORD")[1]))
            Endif
            // DTOS(F4C_DTTRAN)+F4C_OPER+F4C_RECTYP+F4C_PAYTYP+F4C_RECACC+F4C_PAYACC
            IF F4C->(dbSeek(xFilial("F4C")+DTOS(oModelDetail:GetValue("F6W_OPDATE"))+cOper+cRectyp+cPaytyp+ ;
                    oModelDetail:GetValue("F6W_TOBACC")+oModelDetail:GetValue("F6W_FRBACC") ) )
                If !Empty(oModelDetail:GetValue("F6W_PAYORD")) 
                    If oModelDetail:GetValue("F6W_PAYORD") == F4C->F4C_PAYORD
                        lIsBS := .T.
                    Else 
                        lIsBS := .F.
                    Endif
                else
                    lIsBS := .T.
                Endif
            Else
                lIsBS := .F.
            Endif
            If lIsBS
                If oModelDetail:GetValue("F6W_UIDF4C") != F4C->F4C_CUUID .Or. oModelDetail:GetValue("F6W_BNKNUM") != F4C->F4C_INTNUM
                    oModelDetail:LoadValue("F6W_UIDF4C", F4C->F4C_CUUID )
                    oModelDetail:LoadValue("F6W_BNKNUM", F4C->F4C_INTNUM)
                    lWasUpd := .T.
                Endif
            Else
                If !Empty(oModelDetail:GetValue("F6W_BNKNUM"))
                    lWasDel := .T.
                Endif
                oModelDetail:LoadValue("F6W_UIDF4C", Space(TamSX3("F6W_UIDF4C")[1]))
                oModelDetail:LoadValue("F6W_BNKNUM", Space(TamSX3("F6W_BNKNUM")[1]))
            Endif
        Endif
    NEXT
    If lWasDel
        MSGINFO( STR0061 )  // Some PO and/or BS were deleted. Make parsing of file from Client-Bank for this date   
    Elseif lWasUpd
        MSGINFO( STR0062 ) // References for some BS or/and PO were updated 
    Else
        MSGINFO( STR0063 ) // Data were actual and not changed
    Endif
    
    RestArea(aAreaF4C) 
    RestArea(aAreaF49)
    RestArea(aSaveArea)
Return NIL

/*/{Protheus.doc} RU06D10018_GetCountQuery
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params cDate as Chacracter
        cFrAcc as Chacracter
        cToAcc as Chacracter
@return nQnt as Number
@type function
@description checks count potential records in f49
*/
Function RU06D10018_GetCountQuery(cDate, cFrAcc, cToAcc)
    Local nCnt   as Numeric
    Local cQuery as Character
    Local cAlias as Character

    nCnt := 0

    cQuery := "SELECT COUNT(*) QTD FROM "
	cQuery += RetSqlName("F49") + " F49 "
	cQuery += " WHERE "                                    
	cQuery += "F49_FILIAL = '"+xFilial("F49")+"' AND "
	cQuery += "F49_DTPAYM = '" + AllTrim(cDate) + "' AND "
	cQuery += "F49_PAYACC = '" + AllTrim(cFrAcc) + "' AND "
	cQuery += "F49_RECACC = '" + AllTrim(cToAcc) + "' AND "
	cQuery += "F49.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()
    dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.T.)

	nQnt := cAlias->QTD
	cAlias->(dbCloseArea())	

Return nQnt

/*/{Protheus.doc} RU06D10019_CheckDelLine
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params aFields as Array
        aValues as Array
@return lRet as Logical
@type function
@description checks that records equels data from pergunte
*/
Function RU06D10019_CheckDelLine(aFields, aValues)
    Local lRet := .F.
    Local dDocdat as Date
    Local dOpdate as Date

    If aScan(aFields, "F6W_DOCDAT") > 0 .AND. aScan(aFields, "F6W_OPDATE") > 0
        dDocdat := aValues[aScan(aFields, "F6W_DOCDAT")] 
        dOpdate := aValues[aScan(aFields, "F6W_OPDATE")]
        If !((aScan(aFields, "F6W_TOBACC") > 0 .AND. AllTrim(aValues[aScan(aFields, "F6W_TOBACC")]) == AllTrim(MV_PAR03)) ;
                .OR. (aScan(aFields, "F6W_FRBACC") > 0 .AND. AllTrim(aValues[aScan(aFields, "F6W_FRBACC")]) == AllTrim(MV_PAR03)))
            lRet := .T.
        Endif
        if dDocdat < MV_PAR05 .OR. dOpdate < MV_PAR05 .OR. dDocdat > MV_PAR06 .OR. dOpdate > MV_PAR06
            If RU06D10020_GetF6WRecord(DTOS(dDocdat), DTOS(dOpdate), ;
                    aValues[aScan(aFields, "F6W_DOCNUM")], M->F6X_UUID, ;
                    aValues[aScan(aFields, "F6W_FRBACC")], aValues[aScan(aFields, "F6W_TOBACC")]) > 0
                lRet := .T.
            Endif
        Endif
    Endif
Return lRet

/*/{Protheus.doc} RU06D10020_GetF6WRecord
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params cDocdat as Chacracter
        cOpdate as Chacracter
        cDocnum as Chacracter
        cUIDF6X as Chacracter
        cFrAcc as Chacracter
        cToAcc as Chacracter
@return nQnt as Number
@type function
@description checks count cross records in f6w
*/
Function RU06D10020_GetF6WRecord(cDocdat, cOpdate, cDocnum, cUIDF6X, cFrAcc, cToAcc)
    Local nCnt   as Numeric
    Local cQuery as Character
    Local cAlias as Character

    nCnt := 0

    cQuery := "SELECT COUNT(*) QTD FROM "
	cQuery += RetSqlName("F6W") + " F6W "
	cQuery += " WHERE "                                    
	cQuery += "F6W_FILIAL = '"+xFilial("F6W")+"' AND "
	cQuery += "F6W_DOCNUM = '" + AllTrim(cDocnum) + "' AND "
	cQuery += "F6W_OPDATE = '" + AllTrim(cOpdate) + "' AND "
	cQuery += "F6W_DOCDAT = '" + AllTrim(cDocdat) + "' AND "
	cQuery += "F6W_FRBACC = '" + AllTrim(cFrAcc) + "' AND "
	cQuery += "F6W_TOBACC = '" + AllTrim(cToAcc) + "' AND "
	cQuery += "F6W_UIDF6X != '" + AllTrim(cUIDF6X) + "' AND "
	cQuery += "F6W.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()
    dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.T.)

	nQnt := cAlias->QTD
	cAlias->(dbCloseArea())	

Return nQnt

/*/{Protheus.doc} RU06D10021
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return lRet as Logical
@type function
@description help search for field F6W_PAYTYP
*/
Function RU06D10021()        
    Local lRet

    If !Empty(FwFldGet("F6W_WRITT"))
        lRet := ConPad1(,,,"EX")
    Else
        lRet := ConPad1(,,,"EY")
    EndIf                        

Return(lRet)

/*/{Protheus.doc} RU06D10022_FillF5QUID
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return cValue as Character
@type function
@description fills F6W_UIDF5Q after choice from f5q
*/
Function RU06D10022_FillF5QUID()
    Local cValue      as Character
    Local lRet        as Logical
    Local aSaveArea   as Array
    Local aAreaF5Q    as Array   

    cValue := ""
    lRet := .T.

    If AllTrim(F5Q->F5Q_CODE) == AllTrim(FwFldGet('F6W_CNT'))
        cValue := F5Q->F5Q_UID
    Else
        aSaveArea := GetArea() 
        aAreaF5Q := F5Q->(GetArea())    
        dbSelectArea("F5Q")
        F5Q->(dbSetOrder(2))
        
        If F5Q->(dbSeek(xFilial("F5Q")+FwFldGet('F6W_CNT')))
            while lRet
                If AllTrim(F5Q->F5Q_CODE) == AllTrim(FwFldGet('F6W_CNT')) ;
                    .AND. (AllTrim(F5Q->F5Q_A1COD) == AllTrim(FwFldGet('F6W_CONCOD')) ;
                    .AND. AllTrim(F5Q->F5Q_A1LOJ) == AllTrim(FwFldGet('F6W_CONBRN'))) ;
                    .OR. (AllTrim(F5Q->F5Q_A2COD) == AllTrim(FwFldGet('F6W_CONCOD'))  ;
                    .AND. AllTrim(F5Q->F5Q_A2LOJ) == AllTrim(FwFldGet('F6W_CONBRN')))
                    cValue := F5Q->F5Q_UID
                    lRet := .F.
                elseif F5Q->F5Q_CODE != AllTrim(FwFldGet('F6W_CNT'))
                    lRet := .F.
                else
                    F5Q->(dbSkip())
                Endif
            end
        Endif
        RestArea(aAreaF5Q)  
        RestArea(aSaveArea)
    Endif
Return cValue

/*/{Protheus.doc} RU06D10023_GetF6XRecord
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return aCross as Array
@type function
@description returns cross records from f6x
*/
Function RU06D10023_GetF6XRecord()
    Local aCross as Array
    Local cQuery as Character
    Local cAlias as Character
    Local nCnt   as Numeric

    aCross := {}

    cQuery := "SELECT F6X_IMPNUM, F6X_DTFROM, F6X_DTTO FROM "
	cQuery += RetSqlName("F6X") + " F6X "
	cQuery += " WHERE "                                    
	cQuery += "F6X_FILIAL = '"+xFilial("F6X")+"' AND "
	cQuery += "F6X_BIK = '" + AllTrim(MV_PAR02) + "' AND "
	cQuery += "F6X_ACCNT = '" + AllTrim(MV_PAR03) + "' AND "
	cQuery += "F6X_DTFROM <= '" + AllTrim(DTOS(MV_PAR06)) + "' AND "
	cQuery += "F6X_DTTO >= '" + AllTrim(DTOS(MV_PAR05)) + "' AND "
	cQuery += "F6X.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

    FOR nCnt := 1 TO 2
        nPos := AT("F6X_DT FROM", cQuery)
        If nPos > 0
            cQuery := STUFF(cQuery, nPos, 11, "F6X_DTFROM" )
        Endif
    NEXT

	cAlias := GetNextAlias()
    dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.T.)
    cAlias->(DbGoTop())
    If !(cAlias->(EOF()))
	    aCross := {cAlias->F6X_IMPNUM, cAlias->F6X_DTFROM, cAlias->F6X_DTTO}
    Endif
	cAlias->(dbCloseArea())	

Return aCross

/*/{Protheus.doc} RU06D10024
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return lRet as Logical
@type function
@description help search for field F6W_CONCOD
*/
Function RU06D10024()        
    Local lRet

    If FwFldGet("F6W_TYPCON") == "1"
        lRet := ConPad1(,,,"SA1")
    Else
        lRet := ConPad1(,,,"SA2")
    EndIf                        

Return(lRet)

/*/{Protheus.doc} RU06D10025_FillParsedFields
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params oModelDetail as Object
        aFields as Array
        aValues as Array
        lAddLine as Logical
@return lAddLine as Logical
@type function
@description filling parsed fields to structure f6w
*/
Function RU06D10025_FillParsedFields(oModelDetail, aFields, aValues, lAddLine)
    Local nCnt as Numeric

    If Len(aFields) > 0
        If lAddLine
            oModelDetail:AddLine()
        Else
            lAddLine := .T.
        EndIf
        oModelDetail:SetValue("F6W_LINE", cValToChar(oModelDetail:GetLine()))
        oModelDetail:SetValue("F6W_UIDF49", cValToChar(oModelDetail:GetLine()))
        oModelDetail:SetValue("F6W_UIDF6X",oModelDetail:oFormModelOwner:GetValue("F6X_UUID"))
        FOR nCnt := 1 TO LEN(aFields)
            oModelDetail:SetValue(aFields[nCnt], aValues[nCnt])
        NEXT
    Endif

Return lAddLine

/*/{Protheus.doc} RU06D10026_SQFilterF4C
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return lRet as Logical
@type function
@description filter for help search F6WF4C
*/
Function RU06D10026_SQFilterF4C()
    Local lRet
    lRet := .F.

    IF DTOS(F4C->F4C_DTTRAN) == DTOS(FwFldGet('F6W_OPDATE')) .AND. F4C->F4C_PAYTYP == FwFldGet('F6W_PAYTYP') ;
            .AND. F4C->F4C_PAYACC == FwFldGet('F6W_FRBACC') .AND. F4C->F4C_RECACC == FwFldGet('F6W_TOBACC') ;
            .AND. F4C->F4C_PAYBIK == FwFldGet('F6W_FRBBIK') .AND. F4C->F4C_RECBIK == FwFldGet('F6W_TOBIK') ;
            .AND. F4C->F4C_VALUE == FwFldGet('F6W_AMOUNT') .AND. aScan({"1","2","4","5","7"}, F4C->F4C_STATUS) > 0
        lRet := .T.
    Endif
Return lRet

/*/{Protheus.doc} RU06D10027_SQFilterF49
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return lIsConv as Logical
@type function
@description filter for help search F6WF49
*/
Function RU06D10027_SQFilterF49()
    Local lIsConv
    Local lEqSum

    lIsConv := .T.
    lEqSum := .F.

    IF DTOS(F49->F49_DTPAYM) == DTOS(FwFldGet('F6W_DOCDAT')) ;
            .AND. F49->F49_PAYACC == FwFldGet('F6W_FRBACC') .AND. F49->F49_RECACC == FwFldGet('F6W_TOBACC') ;  
            .AND. F49->F49_STATUS != '3' .AND. F49->F49_VALUE == FwFldGet('F6W_AMOUNT')
        lIsConv := .T.
    Endif

Return lIsConv

/*/{Protheus.doc} RU06D10028_FillF49UID
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return cValue as Character
@type function
@description fills F6W_UIDF49 after choice from f49
*/
Function RU06D10028_FillF49UID()
    Local cValue      as Character
    Local lRet        as Logical
    Local aSaveArea   as Array
    Local aAreaF49    as Array   

    cValue := FwFldGet('F6W_LINE')
    lRet := .T.
    If F49->F49_DTPAYM == FwFldGet('F6W_DOCDAT') .AND. F49->F49_PAYORD == FwFldGet('F6W_PAYORD')
        cValue := F49->F49_IDF49
    Else
        aSaveArea := GetArea() 
        aAreaF49 := F49->(GetArea())        
        dbSelectArea("F49")
        F49->(dbSetOrder(6))
        
        If F49->(dbSeek(xFilial("F49")+DTOS(FwFldGet('F6W_DOCDAT'))+AllTrim(FwFldGet('F6W_FRBACC'))+AllTrim(FwFldGet('F6W_TOBACC'))))
            while lRet
                If F49->F49_DTPAYM == FwFldGet('F6W_DOCDAT') .AND. F49->F49_PAYORD == FwFldGet('F6W_PAYORD')
                    cValue := F49->F49_IDF49
                    lRet := .F.
                elseif F49->F49_DTPAYM != FwFldGet('F6W_DOCDAT') .OR. F49->F49_PAYACC != FwFldGet('F6W_FRBACC') .OR. F49->F49_RECACC != FwFldGet('F6W_TOBACC')
                    lRet := .F.
                else
                    F49->(dbSkip())
                Endif
            end
        Endif
        RestArea(aAreaF49)  
        RestArea(aSaveArea)
    Endif
Return cValue

/*/{Protheus.doc} RU06D10029_BankStatWhen
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return lRet as Logical
@type function
@description changes the opportunity to edit field F6W_BNKNUM
*/
Function RU06D10029_BankStatWhen()
    Local lRet as Logical

    lRet := IIF(!Empty(FwFldGet("F6W_RECEIV")).AND.!Empty(FwFldGet("F6W_PAYTYP")).AND.!Empty(FwFldGet("F6W_CONCOD")),.T.,.F.)                 

Return lRet

/*/{Protheus.doc} RU06D10030_FillF4C
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params oModelDetail as Object
        nLine as Number
@return cValue as Character
@type function
@description fills data after choice from f4c
*/
Function RU06D10030_FillF4C(oModelDetail, nLine)
    Local cValue      as Character
    Local lRet        as Logical
    Local aSaveArea   as Array
    Local aAreaF4C    as Array   

    cValue := ""
    lRet := .T.
    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())

    oModelDetail:GoLine(nLine)
    
    dbSelectArea("F4C")
    F4C->(dbSetOrder(2))

    If F4C->(dbSeek(xFilial("F4C")+DTOS(oModelDetail:GetValue('F6W_OPDATE'))+oModelDetail:GetValue('F6W_BNKNUM')))
        oModelDetail:SetValue('F6W_UIDF4C', F4C->F4C_CUUID)
        lRet := MSGYESNO(STR0042, STR0033) // Incomplete fields will be updated. Continue?
        If lRet
            If Empty(oModelDetail:GetValue('F6W_PAYORD'))
                oModelDetail:LoadValue('F6W_PAYORD', F4C->F4C_PAYORD)
                oModelDetail:SetValue('F6W_UIDF49', F4C->F4C_IDF49)
            EndIf
            If Empty(oModelDetail:GetValue('F6W_CLASS'))
                oModelDetail:SetValue('F6W_CLASS', F4C->F4C_CLASS)
            EndIf
            If Empty(oModelDetail:GetValue('F6W_CNT'))
                oModelDetail:SetValue('F6W_CNT', F4C->F4C_CNT)
                oModelDetail:SetValue('F6W_UIDF5Q', F4C->F4C_UIDF5Q)
                oModelDetail:LoadValue("F6W_CNTDES", Posicione("F5Q",1,xFilial("F5Q")+F4C->F4C_UIDF5Q,"F5Q_DESCR"))
            EndIf
        EndIf
    Endif
    RestArea(aAreaF4C)  
    RestArea(aSaveArea)
Return cValue                                                                                                   

/*/{Protheus.doc} RU06D10031_CheckPergunte
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return NIL
@type function
@description checks data from pergunte
*/
Function RU06D10031_CheckPergunte()
    Local aLinesFile := {}
    Local lValid      as Logical
    Local cFormatCode as Character
    Local aCross      as Array
    Local aSaveArea   as Array
    Local aAreaSA6    as Array
    Local aAreaF5N    as Array
    Local cTexto      as Character
    Local nCnt      as Numeric

    lValid := .T.   // Flag to check, are necessary fields are not empty?
    aCross := {}
    cTexto := ""
    nCnt := 7
    SetRegua(nCnt)
    aSaveArea := GetArea() 
    aAreaSA6 := SA6->(GetArea())
    aAreaF5N := F5N->(GetArea())
    
    lValid := .T. // Redefine after last iteration
    // All fields must not be empty
    lValid := lValid .And. !EMPTY(MV_PAR01) 
    lValid := lValid .And. !EMPTY(MV_PAR02) 
    lValid := lValid .And. !EMPTY(MV_PAR03)
    lValid := lValid .And. !EMPTY(MV_PAR04)
    lValid := lValid .And. !EMPTY(MV_PAR05)
    lValid := lValid .And. !EMPTY(MV_PAR06)
    If lValid 
        IncRegua()
        // Check for existing record in f6x for this account in choose dates
        aCross := RU06D10023_GetF6XRecord()
        If Len(aCross) == 0
            IncRegua()
            // Check for existing account in sa6
            dbSelectArea("SA6")
            SA6->(dbSetOrder(1))
            If SA6->(dbSeek(xFilial("SA6")+MV_PAR01+MV_PAR02+MV_PAR03))
                IncRegua()
                // Check for existing import format for account
                cFormatCode := SA6->A6_FRMCDI
                dbSelectArea("F5N")
                F5N->(dbSetOrder(1))
                If F5N->(dbSeek(xFilial("F5N")+cFormatCode)) .And. F5N_FRMTYP == "2"
                    IncRegua()
                    // Check for existing file
                    If File(MV_PAR04)
                        IncRegua()
                        // Check for existing account in file
                        aLinesFile := RU06D10003(MV_PAR04)
                        If RU06D10015_CheckAcc(aLinesFile)
                            IncRegua()
                            // import
                            RU06D10004(aLinesFile, cFormatCode)
                        Else
                            Help("",1,STR0027,,STR0028,1,0) // Invalid account or file
                        Endif
                    Else
                        Help("",1,STR0019,,STR0020,1,0) // File not found
                    EndIf
                Else
                    Help("",1,STR0021,,STR0022,1,0) // Missing import format
                EndIf
            Else
                Help("",1,STR0023,,STR0024,1,0) // Bank account is not registered in the Banks table
            EndIf
        Else
            cTexto := STR0036+cValToChar(aCross[1])+STR0037+DTOC(STOD(cValToChar(aCross[2])))+STR0038+DTOC(STOD(cValToChar(aCross[3])))
            Help("",1,STR0035,,cTexto,1,0) // Intersection with records F6X
        EndIf
    Else
        Help("",1,STR0025,,STR0026,1,0) // All fields of pergunte must be filled in
    EndIf

    RestArea(aAreaF5N)  
    RestArea(aAreaSA6)  
    RestArea(aSaveArea) 

Return NIL

/*/{Protheus.doc} RU06D10032_ValidConcod
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return lValidCon as Logical
@type function
@description validation for F6W_CONCOD
*/
Function RU06D10032_ValidConcod()
    Local lValidCon    as Logical
    Local aSaveArea    as Array
    Local aAreaSA1     as Array
    Local aAreaSA2     as Array

    lValidCon := .F.                   
    
    aSaveArea := GetArea()    
    
    If FwFldGet("F6W_TYPCON")=="1"
        aAreaSA1 := SA1->(GetArea())
        dbSelectArea('SA1')
        SA1->(dbSetOrder(1))
        If SA1->(dbSeek(xFilial("SA1")+FwFldGet("F6W_CONCOD")+FwFldGet("F6W_CONBRN")))
            If (AllTrim(MV_PAR03) == AllTrim(FwFldGet("F6W_FRBACC")) .And. ;
                AllTrim(SA1->A1_CODZON) == AllTrim(FwFldGet("F6W_TOINN")) .And. ;
                AllTrim(SA1->A1_INSCGAN) == AllTrim(FwFldGet("F6W_TOKPP"))) .Or. ;
                (AllTrim(MV_PAR03) == AllTrim(FwFldGet("F6W_TOBACC")) .And. ;
                AllTrim(SA1->A1_CODZON) == AllTrim(FwFldGet("F6W_FRINN")) .And. ;
                AllTrim(SA1->A1_INSCGAN) == AllTrim(FwFldGet("F6W_FRKPP")))
                lValidCon := .T.
            Endif 
        Endif
        RestArea(aAreaSA1)
    Else
        aAreaSA2 := SA2->(GetArea())  
        dbSelectArea('SA2')
        SA2->(dbSetOrder(1))
        If SA2->(dbSeek(xFilial("SA2")+FwFldGet("F6W_CONCOD")+FwFldGet("F6W_CONBRN")))
            If (AllTrim(MV_PAR03) == AllTrim(FwFldGet("F6W_FRBACC")) .And. ;
                AllTrim(SA2->A2_CODZON) == AllTrim(FwFldGet("F6W_TOINN")) .And. ;
                AllTrim(SA2->A2_KPP) == AllTrim(FwFldGet("F6W_TOKPP"))) .Or. ;
                (AllTrim(MV_PAR03) == AllTrim(FwFldGet("F6W_TOBACC")) .And. ;
                AllTrim(SA2->A2_CODZON) == AllTrim(FwFldGet("F6W_FRINN")) .And. ;
                AllTrim(SA2->A2_KPP) == AllTrim(FwFldGet("F6W_FRKPP")))
                lValidCon := .T.
            Endif 
        Endif
        RestArea(aAreaSA2)
    Endif

    If !Empty(FwFldGet("F6W_CONCOD")) .And. !lValidCon
        Help("",1,STR0025,,STR0043,1,0) // Check INN/KPP contrpartner!
    Endif

    RestArea(aSaveArea) 

Return lValidCon

/*/{Protheus.doc} RU06D10033_FillOperTypeDescr
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return cValue as Character
@type function
@description fills data after choice from f4c
*/
Function RU06D10033_FillOperTypeDescr()
    Local cValue      as Character
    Local aSaveArea   as Array
    Local aAreaSX5    as Array   

    cValue := ""
    aSaveArea := GetArea() 
    aAreaSX5 := SX5->(GetArea())
    IF(!Empty(F6W->F6W_WRITT))
        cValue := Posicione("SX5",1,xFilial("SX5")+"EX"+F6W->F6W_PAYTYP,"X5DESCRI()")
    Else    
        cValue := Posicione("SX5",1,xFilial("SX5")+"EY"+F6W->F6W_PAYTYP,"X5DESCRI()")
    Endif
    RestArea(aAreaSX5)  
    RestArea(aSaveArea)
Return cValue  



/*/{Protheus.doc} RU06D10034_CreateBS
@author Olga Galyandina
@since 01/03/2024
@version 14
@return .T.
@type function
@description fuction create BS
*/
Function RU06D10034_CreateBS()        
    MsAguarde({|| RU06D10011_BnkStateCreation()}, STR0046, STR0047) // "Please wait", "Bank Statements are creating"
    MostraErro()

Return .T.


/*/{Protheus.doc} RU06D10035_FillCntdes
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return cValue as Character
@type function
@description fills F6W_CNTDES after choice from f5q
*/
Function RU06D10035_FillCntdes()
    Local cValue      as Character
    Local lRet        as Logical
    Local aSaveArea   as Array
    Local aAreaF5Q    as Array   

    cValue := ""
    lRet := .T.

    If AllTrim(F5Q->F5Q_CODE) == AllTrim(FwFldGet('F6W_CNT'))
        cValue := F5Q->F5Q_DESCR
    Else
        aSaveArea := GetArea() 
        aAreaF5Q := F5Q->(GetArea())    
        dbSelectArea("F5Q")
        F5Q->(dbSetOrder(2))
        
        If F5Q->(dbSeek(xFilial("F5Q")+FwFldGet('F6W_CNT')))
            while lRet
                If AllTrim(F5Q->F5Q_CODE) == AllTrim(FwFldGet('F6W_CNT')) ;
                    .AND. (AllTrim(F5Q->F5Q_A1COD) == AllTrim(FwFldGet('F6W_CONCOD')) ;
                    .AND. AllTrim(F5Q->F5Q_A1LOJ) == AllTrim(FwFldGet('F6W_CONBRN'))) ;
                    .OR. (AllTrim(F5Q->F5Q_A2COD) == AllTrim(FwFldGet('F6W_CONCOD'))  ;
                    .AND. AllTrim(F5Q->F5Q_A2LOJ) == AllTrim(FwFldGet('F6W_CONBRN')))
                    cValue := F5Q->F5Q_DESCR
                    lRet := .F.
                elseif F5Q->F5Q_CODE != AllTrim(FwFldGet('F6W_CNT'))
                    lRet := .F.
                else
                    F5Q->(dbSkip())
                Endif
            end
        Endif
    Endif

    RestArea(aAreaF5Q)  
    RestArea(aSaveArea)
Return cValue


/*/{Protheus.doc} RU06D10036_f3Tag
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@return lRet as Logical
@type function
@description help search for field F6J_TAG
*/
Function RU06D10036_f3Tag()        
    Local lRet

    If FwFldGet("F6J_RELTYP") == "1"
        lRet := ConPad1(,,,"IH")
    Else
        lRet := ConPad1(,,,"IP")
    EndIf                        

Return(lRet)

/*/{Protheus.doc} RU06D10037_checkF6J
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params 
@return NIL
@type function
@description checks and prefills f6j
*/
Function RU06D10037_checkF6J()
    Local nCnt   as Numeric
    Local cQuery as Character
    Local cAlias as Character

    nCnt := 0

    cQuery := "SELECT COUNT(*) QTD FROM "
	cQuery += RetSqlName("F6J") + " F6J "
	cQuery += " WHERE "                                    
	cQuery += "F6J_FILIAL = '"+xFilial("F6J")+"' AND "
	cQuery += "F6J.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()
    dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.T.)

	nQnt := cAlias->QTD
	cAlias->(dbCloseArea())	

    If nQnt == 0
        RU06D10038_prefillF6J()
    Endif

Return NIL

/*/{Protheus.doc} RU06D10038_prefillF6J
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params 
@return NIL
@type function
@description prefills f6j
*/
Function RU06D10038_prefillF6J()
    Local nX     as Numeric
    Local aInput := {}

    aadd(aInput, {"IH-01","F6X_DTFROM","1","2"})
    aadd(aInput, {"IH-02","F6X_DTTO","1","2"})
    aadd(aInput, {"IP-01","F6W_FRDATE","2","2"})
    aadd(aInput, {"IP-02","F6W_TODATE","2","2"})
    aadd(aInput, {"IP-03","F6W_DOCDAT","2","2"})
    aadd(aInput, {"IP-04","F6W_DOCNUM","2","2"})
    aadd(aInput, {"IP-05","F6W_PAYER","2","2"})
    aadd(aInput, {"IP-06","F6W_RECVER","2","2"})
    aadd(aInput, {"IP-07","F6W_FRBACC","2","2"})
    aadd(aInput, {"IP-08","F6W_TOBACC","2","2"})
    aadd(aInput, {"IP-09","F6W_AMOUNT","2","2"})
    aadd(aInput, {"IP-10","F6W_REASON","2","1"})
    aadd(aInput, {"IP-11","F6W_TOINN","2","2"})
    aadd(aInput, {"IP-12","F6W_TOKPP","2","2"})
    aadd(aInput, {"IP-13","F6W_FRINN","2","2"})
    aadd(aInput, {"IP-14","F6W_FRKPP","2","2"})
    aadd(aInput, {"IP-15","F6W_FRBANK","2","2"})
    aadd(aInput, {"IP-16","F6W_FRBIK","2","2"})
    aadd(aInput, {"IP-17","F6W_FRCORR","2","2"})
    aadd(aInput, {"IP-18","F6W_TOBANK","2","2"})
    aadd(aInput, {"IP-19","F6W_TOBIK","2","2"})
    aadd(aInput, {"IP-20","F6W_TOCORR","2","2"})
    aadd(aInput, {"IP-21","F6W_PAYCOD","2","2"})


    For nX := 1 to Len(aInput)
        ReClock("F6J",.T.)
        F6J->F6J_TAG := aInput[nX, 1]
        F6J->F6J_BLOCK := aInput[nX, 2]
        F6J->F6J_RELTYP := aInput[nX, 3]
        F6J->F6J_CONCAT := aInput[nX, 4]
        F6J->(MsUnlock())
    Next nX

Return NIL

/*/{Protheus.doc} RU06D10039
@author Olga Galyandina
@since 01/03/2024
@version 12.1.2310
@params 
@return NIL
@type function
@description validation F6W_PAYORD
*/
Function RU06D10039
    Local lValid
    Local aSaveArea   as Array
    Local aAreaF49    as Array   

    aSaveArea := GetArea() 
    aAreaF49 := F49->(GetArea())        
    dbSelectArea("F49")
    F49->(dbSetOrder(3))
    
    lValid := Vazio()
    If F49->(dbSeek(xFilial("F49")+DTOS(FwFldGet("F6W_DOCDAT"))+FwFldGet("F6W_PAYORD")))
        lValid := lValid .Or. (F49->F49_VALUE == FwFldGet("F6W_AMOUNT") .And. F49->F49_STATUS != "3")
    Endif
    RestArea(aAreaF49)  
    RestArea(aSaveArea)

Return lValid

/*/{Protheus.doc} RU06D10040_PostedToFIWithoutPO
@author Olga Galyandina
@since 01/03/2024
@version 14
@return NIL
@type function
@description action for posting to Finance
*/
Function RU06D10040_PostedToFIWithoutPO()
    Local lPosted   as Logical
    Local lBrowse := .F.  as Logical
    Local oModel    as Object
    Local oModelMaster as Object
    Local oModelDetail as Object
    Local aBSLines as Array
    Local nCnt as Numeric
    Local aSaveArea    as Array
    Local aAreaF4C     as Array

    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())
    dbSelectArea('F4C')
    F4C->(dbSetOrder(5))   // F4C_FILIAL+F4C_CUUID
    
    oModel := FWModelActive()    
    If ValType(oModel) != "O" .Or. oModel:cId != "RU06D10"
        oModel := FwLoadModel("RU06D10")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()
        lBrowse := .T.
    Endif
    oModelMaster := oModel:GetModel("F6XMASTER")
    oModelDetail := oModel:GetModel("F6WDETAIL")
    lPosted := .F.
    aBSLines := {}
    FOR nCnt := 1 TO oModelDetail:Length(.F.)
        oModelDetail:GoLine(nCnt)
        If !oModelDetail:IsDeleted()
            If !Empty(oModelDetail:GetValue("F6W_UIDF4C")) .And. Empty(oModelDetail:GetValue("F6W_PAYORD"))
                If F4C->(dbSeek(xFilial("F4C")+oModelDetail:GetValue("F6W_UIDF4C")))
                    If F4C->F4C_STATUS == '1' .Or. F4C->F4C_STATUS == '4'
                        aAdd(aBSLines, nCnt)
                    Else 
                        lPosted := .T.
                    Endif
                Endif
            Endif
        Endif
    NEXT
    If Empty(aBSLines) .And. lPosted
        Help("",1,STR0066,,STR0067,1,0) // "Posted","Journal already posted in Finance"
    Elseif Empty(aBSLines) .And. !lPosted
        Help("",1,STR0068,,STR0069,1,0) // "Empty","Not records for posting"
    Endif

    MsAguarde({|| RU06D10043_PostedToFIWithoutPO(oModel, aBSLines)}, STR0046, STR0079) // "Please wait", "Bank Statements are posting to Finance..."
    MostraErro()
    
    RestArea(aAreaF4C) 
    RestArea(aSaveArea)
    RU06D10042_SetStatus(oModel)
    If lBrowse
        oModel:DeActivate()
        oModel:Destroy()
    Endif

Return .T.

/*/{Protheus.doc} RU06D10041
@author Olga Galyandina
@since 01/03/2024
@version 14
@return NIL
@type function
@description validation F6W_BNKNUM
*/
Function RU06D10041
    Local lValid
    Local aSaveArea   as Array
    Local aAreaF4C    as Array   

    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())        
    dbSelectArea("F4C")
    F4C->(dbSetOrder(1))
    
    lValid := Vazio()
    If F4C->(dbSeek(xFilial("F4C")+FwFldGet("F6W_BNKNUM")))
        lValid := lValid .Or. aScan({"1","2","4","5","7"}, F4C->F4C_STATUS) > 0 
    Endif
    RestArea(aAreaF4C)  
    RestArea(aSaveArea)

Return lValid

/*/{Protheus.doc} RU06D10042_SetStatus
@author Olga Galyandina
@since 01/03/2024
@version 14
@return NIL
@type function
@description sat statusafter changes
*/
Function RU06D10042_SetStatus(oModel)
    Local cStatus as Character
    Local oModelDetail as Object
    Local nCnt as Numeric
    Local nCntLines as Numeric
    Local nInFin as Numeric
    Local nInACC as Numeric
    Local nHasBS as Numeric
    Local aSaveArea    as Array
    Local aAreaF4C     as Array

    cStatus := F6X->F6X_STATUS
    nCntLines := 0
    nInFin := 0
    nInACC := 0
    nHasBS := 0
    oModelDetail := oModel:GetModel("F6WDETAIL")
    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())
    dbSelectArea('F4C')
    F4C->(dbSetOrder(5))   // F4C_FILIAL+F4C_CUUID
    FOR nCnt := 1 TO oModelDetail:Length(.F.)
        oModelDetail:GoLine(nCnt)
        If !oModelDetail:IsDeleted()
            If oModelDetail:GetValue("F6W_PAYTYP") == "1"
                nCntLines += 1
                If !Empty(oModelDetail:GetValue("F6W_UIDF4C"))
                    nHasBS += 1
                    If F4C->(dbSeek(xFilial("F4C")+oModelDetail:GetValue("F6W_UIDF4C")))
                        If F4C->F4C_STATUS == '2' .Or. F4C->F4C_STATUS == '5'
                            nInFin += 1
                        Elseif F4C->F4C_LA == 'S' 
                            nInACC += 1
                        Endif
                    Endif
                Endif
            Endif
        Endif
    NEXT
    If nInAcc == nCntLines
        cStatus := "4"
    Elseif nInAcc > 0
        cStatus := "6"
    Elseif nInFin == nCntLines
        cStatus := "3"
    Elseif nInFin > 0
        cStatus := "5"
    Elseif nHasBS == nCntLines
        cStatus := "2"
    Else
        cStatus := "1"
    Endif

    If cStatus != F6X->F6X_STATUS
        If F6X->(RecLock("F6X",.F.))
            F6X->F6X_STATUS := cStatus
            F6X->(MsUnLock())
        Endif
    Endif

    RestArea(aAreaF4C)  
    RestArea(aSaveArea)
Return .T.

/*/{Protheus.doc} RU06D10043_PostedToFIWithoutPO
@author Olga Galyandina
@since 01/03/2024
@version 14
@return NIL
@type function
@description action for posting to Finance
*/
Function RU06D10043_PostedToFIWithoutPO(oModel as Object, aBSLines as Array)
    Local lRes      as Logical
    Local oModelBS as Object
    Local oModelMaster as Object
    Local oModelDetail as Object
    Local nCnt as Numeric
    Local aSaveArea    as Array
    Local aAreaF4C     as Array
    Private lGeraLanc := .F.  As Logical
    Private lDigita := .F.  As Logical
    Private lCmtRU6D7  := .F.
    Private lIsFinPost := .T.

    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())
    dbSelectArea('F4C')
    F4C->(dbSetOrder(5))   // F4C_FILIAL+F4C_CUUID    
    
    oModelMaster := oModel:GetModel("F6XMASTER")
    oModelDetail := oModel:GetModel("F6WDETAIL")
    FOR nCnt := 1 TO Len(aBSLines)
        oModelDetail:GoLine(aBSLines[nCnt])
        If F4C->(dbSeek(xFilial("F4C")+oModelDetail:GetValue("F6W_UIDF4C")))
            oModelBS := FwLoadModel("RU06D07")
            RU06D07739_SetAutoBs(.T.) // Set "Auto" mod 
            oModelBS := RU06D0728_TuneModelBeforePostingInFinancial(oModelBS, 1, MODEL_OPERATION_UPDATE)
            lRes := RU06D0732_FinancialPost(oModelBS)
            AutoGrLog(STR0059 + oModelDetail:GetValue("F6W_LINE")) // Line
            if lRes                
                AutoGrLog(STR0048 + oModelDetail:GetValue("F6W_BNKNUM") + STR0072) // "BS ", " posted to Finance successfully"
            Else
                aErrors := oModelBS:GetErrorMessage()
                If !Empty(aErrors[1])
                    AutoGrLog(AllToChar( aErrors[1] ) + CRLF) 
                Endif
                If !Empty(aErrors[2])
                    AutoGrLog(AllToChar( aErrors[2] ) + CRLF) 
                Endif
                If !Empty(aErrors[3])
                    AutoGrLog(AllToChar( aErrors[3] ) + CRLF) 
                Endif
                If !Empty(aErrors[4])
                    AutoGrLog(AllToChar( aErrors[4] ) + CRLF) 
                Endif
                If !Empty(aErrors[5])
                    AutoGrLog(AllToChar( aErrors[5] ) + CRLF) 
                Endif
                If !Empty(aErrors[6])
                    AutoGrLog(AllToChar( aErrors[6] ) + CRLF) 
                Endif
                If !Empty(aErrors[7])
                    AutoGrLog(AllToChar( aErrors[7] ) + CRLF) 
                Endif
                If !Empty(aErrors[8])
                    AutoGrLog(AllToChar( aErrors[8] ) + CRLF) 
                Endif
                If !Empty(aErrors[9])
                    AutoGrLog(AllToChar( aErrors[9] ) + CRLF + CRLF) 
                Endif
            Endif
            RU06D07739_SetAutoBs(.F.) // Set not "Auto" mod 
            If oModelBS:IsActive()
                oModelBS:DeActivate()
                oModelBS:Destroy()
            Endif            
        Endif
    NEXT
    
    RestArea(aAreaF4C) 
    RestArea(aSaveArea)
Return NIL

/*/{Protheus.doc} RU06D10044_PostedToFI
@author Olga Galyandina
@since 01/03/2024
@version 14
@return NIL
@type function
@description action for posting to Finance
*/
Function RU06D10044_PostedToFI(oModel as Object, aBSLines as Array)
    Local lRes        as Logical
    Local oModelBS    as Object
    Local oModelMaster as Object
    Local oModelDetail as Object
    Local nCnt as Numeric
    Local aSaveArea    as Array
    Local aAreaF4C     as Array
    Private lGeraLanc := .F.  As Logical
    Private lDigita := .F.  As Logical

    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())
    dbSelectArea('F4C')
    F4C->(dbSetOrder(5))   // F4C_FILIAL+F4C_CUUID
        
    oModelMaster := oModel:GetModel("F6XMASTER")
    oModelDetail := oModel:GetModel("F6WDETAIL")
    
    FOR nCnt := 1 TO Len(aBSLines)
        oModelDetail:GoLine(aBSLines[nCnt])
        If F4C->(dbSeek(xFilial("F4C")+oModelDetail:GetValue("F6W_UIDF4C")))
            oModelBS := FwLoadModel("RU06D07")
            RU06D07739_SetAutoBs(.T.) // Set "Auto" mod 
            oModelBS:SetOperation(MODEL_OPERATION_UPDATE)
            oModelBS:Activate()            
            lRes := RU06D0732_FinancialPost(oModelBS)
            AutoGrLog(STR0059 + oModelDetail:GetValue("F6W_LINE")) // Line
            if lRes                
                AutoGrLog(STR0048 + oModelDetail:GetValue("F6W_BNKNUM") + STR0072)  // "BS ", "BS posted to Finance successfully"
            Else
                aErrors := oModelBS:GetErrorMessage()
                If !Empty(aErrors[1])
                    AutoGrLog(AllToChar( aErrors[1] ) + CRLF) 
                Endif
                If !Empty(aErrors[2])
                    AutoGrLog(AllToChar( aErrors[2] ) + CRLF) 
                Endif
                If !Empty(aErrors[3])
                    AutoGrLog(AllToChar( aErrors[3] ) + CRLF) 
                Endif
                If !Empty(aErrors[4])
                    AutoGrLog(AllToChar( aErrors[4] ) + CRLF) 
                Endif
                If !Empty(aErrors[5])
                    AutoGrLog(AllToChar( aErrors[5] ) + CRLF) 
                Endif
                If !Empty(aErrors[6])
                    AutoGrLog(AllToChar( aErrors[6] ) + CRLF) 
                Endif
                If !Empty(aErrors[7])
                    AutoGrLog(AllToChar( aErrors[7] ) + CRLF) 
                Endif
                If !Empty(aErrors[8])
                    AutoGrLog(AllToChar( aErrors[8] ) + CRLF) 
                Endif
                If !Empty(aErrors[9])
                    AutoGrLog(AllToChar( aErrors[9] ) + CRLF + CRLF) 
                Endif
            Endif
            RU06D07739_SetAutoBs(.F.) // Set not "Auto" mod 
            If oModelBS:IsActive()
                oModelBS:DeActivate()
                oModelBS:Destroy()
            Endif            
        Endif
    NEXT
    
    RestArea(aAreaF4C) 
    RestArea(aSaveArea)
Return NIL

/*/{Protheus.doc} RU06D10045_PostedToAcnt
@author Olga Galyandina
@since 01/03/2024
@version 14
@return NIL
@type function
@description action for posting to Accounting
*/
Function RU06D10045_PostedToAcnt(oModel as Object, aBSLines as Array)
    Local lRes      as Logical
    Local oModelMaster as Object
    Local oModelDetail as Object
    Local nCnt     as Numeric
    Local aSaveArea    as Array
    Local aAreaF4C     as Array
    Private lGeraLanc := .T.  As Logical
    Private lDigita := .F.  As Logical

    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())
    dbSelectArea('F4C')
    F4C->(dbSetOrder(5))   // F4C_FILIAL+F4C_CUUID
    
    oModelMaster := oModel:GetModel("F6XMASTER")
    oModelDetail := oModel:GetModel("F6WDETAIL")
          
    FOR nCnt := 1 TO Len(aBSLines)
        oModelDetail:GoLine(aBSLines[nCnt])
        lRes := .T.
        If F4C->(dbSeek(xFilial("F4C")+oModelDetail:GetValue("F6W_UIDF4C")))
            If RecLock("F4C",.F.)
                lRes := lRes .AND. RU06D07009_PostInAccounting(.F.)
                F4C->(MSUnlock())
            Else
                lRes := .F. // stop postings, we can't lock F4C record
                AutoGrLog(STR0048 + F4C->F4C_INTNUM + STR0076) // "BS ", " is not locked"
            EndIf
            if lRes                
                AutoGrLog(STR0048 + F4C->F4C_INTNUM + STR0077) // "BS ", " posted to Finance successfully"
            Else
                AutoGrLog(STR0048 + F4C->F4C_INTNUM + STR0078) // "BS ", " was not posted to Accounting"
            Endif          
        Endif
    NEXT
    
    RestArea(aAreaF4C) 
    RestArea(aSaveArea)
Return NIL

/*/{Protheus.doc} RU06D10046_FillAfterF49
@author Olga Galyandina
@since 01/03/2024
@version 14
@params oModelDetail as Object
        nLine as Number
@return NIL
@type function
@description fills data after choice from f49
*/
Function RU06D10046_FillAfterF49(oModelDetail, nLine)
    Local lFound      as Logical
    Local aSaveArea   as Array
    Local aAreaF4C    as Array   
    Local aAreaF49    as Array 
    Local aF4Cdata    as Array    

    lFound := .T.
    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())
    aAreaF49 := F49->(GetArea())

    oModelDetail:GoLine(nLine)
    
    dbSelectArea("F4C")
    F4C->(dbSetOrder(3)) // F4C_FILIAL + F4C_PAYORD
    dbSelectArea("F49")
    // F49->(dbSetOrder(2)) // F49_FILIAL + F49_IDF49
    oModelDetail:LoadValue('F6W_UIDF4C', Space(TamSX3("F6W_UIDF4C")[1]))
    oModelDetail:LoadValue('F6W_BNKNUM', Space(TamSX3("F6W_BNKNUM")[1]))

    If Empty(oModelDetail:GetValue('F6W_PAYORD'))
        oModelDetail:LoadValue('F6W_UIDF49', oModelDetail:GetValue("F6W_LINE"))
    Else
        If F49->F49_PAYORD == oModelDetail:GetValue('F6W_PAYORD') .And. F49->F49_DTPAYM == oModelDetail:GetValue('F6W_DOCDAT')
            oModelDetail:LoadValue("F6W_UIDF49", F49->F49_IDF49)
        else
            F49->(dbSetOrder(3)) // F49_FILIAL + DTOS(F49_DTPAYM) + F49_PAYORD + F49_BNKORD
            If F49->(dbSeek(xFilial("F49")+DTOS(oModelDetail:GetValue("F6W_DOCDAT"))+oModelDetail:GetValue("F6W_PAYORD")))
                oModelDetail:LoadValue("F6W_UIDF49", F49->F49_IDF49)
            Else
                lFound := .F.
            Endif
        Endif
        If !lFound
            oModelDetail:LoadValue('F6W_UIDF49', oModelDetail:GetValue("F6W_LINE"))
            oModelDetail:LoadValue('F6W_UIDF4C', Space(TamSX3("F6W_UIDF4C")[1]))
            oModelDetail:LoadValue('F6W_BNKNUM', Space(TamSX3("F6W_BNKNUM")[1]))
            oModelDetail:LoadValue('F6W_PAYORD', Space(TamSX3("F6W_PAYORD")[1]))
        Else 
            aF4Cdata := RU06D10047_FillF4CbyF49(F49->F49_PAYORD, F49->F49_IDF49)
            If Len(aF4Cdata) == 2
                oModelDetail:LoadValue('F6W_BNKNUM', aF4Cdata[1])
                oModelDetail:LoadValue('F6W_UIDF4C', aF4Cdata[2])
            EndIf
        EndIf
    EndIf
    RestArea(aAreaF49)  
    RestArea(aAreaF4C)  
    RestArea(aSaveArea)
Return NIL

/*/{Protheus.doc} RU06D10047_FillF4CbyF49
@author Olga Galyandina
@since 01/03/2024
@version 14
@params cPayord as Character
        cIdF49 as Character
@return aF4Cdata: 1 - F4C->F4C_INTNUM, 2 - F4C->F4C_CUUID
@type function
@description fills number f4c by data from f49
*/
Function RU06D10047_FillF4CbyF49(cPayord, cIdF49)
    Local lSeek       as Logical
    Local aSaveArea   as Array
    Local aAreaF4C    as Array  
    Local aF4Cdata    as Array   

    aSaveArea := GetArea() 
    aAreaF4C := F4C->(GetArea())

    aF4Cdata := {}
    dbSelectArea("F4C")
    F4C->(dbSetOrder(3)) // F4C_FILIAL + F4C_PAYORD
    If !Empty(cPayord)
        lSeek := F4C->(dbSeek(xFilial("F4C")+cPayord))
        WHILE lSeek
            If cIdF49 == F4C->F4C_IDF49
                aAdd(aF4Cdata, F4C->F4C_INTNUM)
                aAdd(aF4Cdata, F4C->F4C_CUUID)
                lSeek := .F.
            Elseif cPayord == F4C->F4C_PAYORD
                F4C->(dbSkip())
            else
                lSeek := .F.
            Endif
        EndDo
    Endif
    RestArea(aAreaF4C)  
    RestArea(aSaveArea)
Return aF4Cdata   

/*/{Protheus.doc} RU06D10048_2Click
@author Olga Galyandina
@since 01/03/2024
@version 14
@params oFormula as Object
        cFieldName as Character
        nLineGrid as Numeric
        nLineModel as Numeric
@return lRes as Logical
@type function
@description open some routines by doubleclick
*/
Function RU06D10048_2Click(oFormula, cFieldName, nLineGrid, nLineModel)
    Local aSaveArea    as Array
    Local aAreaTab     as Array
    Local oModel       as Object
    Local oModelDetail as Object
    Local oModelOut    as Object
    Local cModelOut    as Character
    Local cAliasH   as Character
    Local nCnt      as Numeric
    Local lRes      as Logical
    Local lFound    as Logical
    Local oStruView	as object
    Private cCadastro
    
    lRes := .F.
    oModel := FwModelActive()
    oModelDetail := oModel:GetModel("F6WDETAIL")
    oModelDetail:GoLine(nLineModel)
    If oModel:GetOperation() == 1
        lRes := .F.
    Else 
        oStruView   := FWFormStruct(2,"F6W")
        FOR nCnt := 1 TO Len(oStruView:aFields)
            If aScan(oStruView:aFields[nCnt], cFieldName) == 1
                lRes := oStruView:aFields[nCnt][10]
                Exit
            Else 
                Loop
            Endif
        NEXT
        If lRes
            lRes := oModelDetail:CanSetValue(cFieldName)
        Endif
    Endif
   
    If !lRes .And. !Empty(oModelDetail:GetValue(cFieldName))
        Do Case 
            Case cFieldName == "F6W_CONCOD"
            If oModelDetail:GetValue("F6W_TYPCON") == '1'
                cModelOut := "CRMA980"
                cAliasH:="SA1"
                aSaveArea := GetArea() 
                aAreaTab := (cAliasH)->(GetArea())
                dbSelectArea(cAliasH)
                (cAliasH)->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
                If (cAliasH)->(dbSeek(xFilial(cAliasH)+oModelDetail:GetValue("F6W_CONCOD")+oModelDetail:GetValue("F6W_CONBRN")))
                    lFound := .T.
                Endif
            Else 
                cModelOut := "MATA020"
                cAliasH:="SA2"
                aSaveArea := GetArea() 
                aAreaTab := (cAliasH)->(GetArea())
                dbSelectArea(cAliasH)
                (cAliasH)->(dbSetOrder(1)) // A2_FILIAL+A2_COD+A2_LOJA
                If (cAliasH)->(dbSeek(xFilial(cAliasH)+oModelDetail:GetValue("F6W_CONCOD")+oModelDetail:GetValue("F6W_CONBRN")))
                    lFound := .T.
                Endif
            Endif

            Case cFieldName == "F6W_BNKACC"
            If oModelDetail:GetValue("F6W_TYPCON") == '1'
                cModelOut := "RU06D03"
                cAliasH:="F4N"
                aSaveArea := GetArea() 
                aAreaTab := (cAliasH)->(GetArea())
                dbSelectArea(cAliasH)
                (cAliasH)->(dbSetOrder(4)) // F4N_FILIAL+F4N_CLIENT+F4N_LOJA+F4N_ACC
                If (cAliasH)->(dbSeek(xFilial(cAliasH)+oModelDetail:GetValue("F6W_CONCOD")+oModelDetail:GetValue("F6W_CONBRN")+oModelDetail:GetValue("F6W_BNKACC")))
                    lFound := .T.
                Endif
            Else 
                cAliasH:="FIL"
                aSaveArea := GetArea() 
                aAreaTab := (cAliasH)->(GetArea())
                dbSelectArea(cAliasH)
                (cAliasH)->(dbSetOrder(5)) // FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_CONTA
                If (cAliasH)->(dbSeek(xFilial(cAliasH)+oModelDetail:GetValue("F6W_CONCOD")+oModelDetail:GetValue("F6W_CONBRN")+oModelDetail:GetValue("F6W_BNKACC")))
                    lFound := .T.
                Endif
            Endif

            Case cFieldName == "F6W_CNT"
            cModelOut := "RU69T01"
            cAliasH:="F5Q"
            aSaveArea := GetArea() 
            aAreaTab := (cAliasH)->(GetArea())
            dbSelectArea(cAliasH)
            (cAliasH)->(dbSetOrder(1)) // F5Q_FILIAL+F5Q_UID
            If (cAliasH)->(dbSeek(xFilial(cAliasH)+oModelDetail:GetValue("F6W_UIDF5Q")))
                lFound := .T.
            Endif

            Case cFieldName == "F6W_BNKNUM"
            cModelOut := "RU06D07"
            cAliasH:="F4C"
            aSaveArea := GetArea() 
            aAreaTab := (cAliasH)->(GetArea())
            dbSelectArea(cAliasH)
            (cAliasH)->(dbSetOrder(5)) // F4C_FILIAL + F4C_CUUID
            If (cAliasH)->(dbSeek(xFilial(cAliasH)+oModelDetail:GetValue("F6W_UIDF4C")))
                lFound := .T.
            Endif

            Case cFieldName == "F6W_PAYORD"
            cModelOut := "RU06D05"
            cAliasH:="F49"
            aSaveArea := GetArea() 
            aAreaTab := (cAliasH)->(GetArea())
            dbSelectArea(cAliasH)
            (cAliasH)->(dbSetOrder(2)) // F49_FILIAL + F49_IDF49
            If (cAliasH)->(dbSeek(xFilial(cAliasH)+oModelDetail:GetValue("F6W_UIDF49")))
                lFound := .T.
            Endif
        EndCase
        If lFound .And. cAliasH=="FIL"
            AxVisual(cAliasH, (cAliasH)->(RECNO()) , 2)
        Elseif lFound
            oModelOut := FwLoadModel(cModelOut)
            FwExecView(STR0005, cModelOut, MODEL_OPERATION_VIEW,/* oDlg */, {|| .T.},/* ok */,/*nPercReducation*/,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModelOut)
        Endif
        RestArea(aAreaTab)  
        RestArea(aSaveArea)
    Endif
Return (lRes)
                   
//Merge Russia R14 
                   
