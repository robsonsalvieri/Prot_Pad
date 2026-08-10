#INCLUDE 'FWMVCDEF.CH'
#include 'RU02T01.CH'
#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} RU02T01
    Function Dialog with choice of Purchase Request or Partnership contracts (depends on nTypeOrder)
    (Upgrade MSSelect and avoid of bug with mark image)
    @type function
    @author ALexandra Velmozhnaya / Oleg Ivanov 
    @since 2021/10/12
    @version 1.0
    @param  nTypeOrder  Numeric   Type of Purchase order (1 - Purchase Request; 2 - Partnership contract)
            aMarca      Array     Choosen records 
            cMarca      Character Mark of Session
            aButEnc     Array     Button Array
            aFields     Array     Fields for columns
            cCampoOk    Character Field with Mark
            cFilter     Character Default fiter
            oMark       Object    Browse Object
    @return nRet    Array   Option 1 if close window by Save and start proccess filling of grid
 
    @see specification RULOC-1751 - refactoring MSSelect for FWMarkBrowse
    @use a120PID
/*/
Function RU02T01000(nTypeOrder, aMarca, cMarca, aButEnc, aFields,cCampoOk,cFilter,oMark)
    Local aSize as Array
    Local aFldUsr as Array
    Local aFldUsrFlt as Array
    Local oDlg as Object
    Local oOneColumn as Object
    Local aColumns as Array
    Local cAliasPID as Character
    Local cFldMarkID as Character
    Local cTitle as Character
    Local nX as Numeric
    Local nRet as Numeric
    Local aUsrBut as Array
    Local aFilter as Array
    Local aTmpRot as Array
    Local aSeek as Array

    aSize := MSADVSIZE()
    cTitle := Iif(nTypeOrder == 2,STR0001,STR0002)
    cAliasPID := Iif(nTypeOrder == 2,"SC3","SC1")
    cFldMarkID := Iif(nTypeOrder == 2,"|C3_OK|","|C1_OK|")
    aFldUsr := {}
    aFldUsrFlt := {}
    aFilter := {}
    aSeek   := {}
    nRet := 0

    If nTipoPed == 2
		dbSelectArea("SC3")
		dbSetOrder(1)
		dbClearFilter()
	Else
		dbSelectArea("SC1")
		dbSetOrder(1)
		dbClearFilter()
	Endif
    //Add user field for FILTER and Seek line
    If ExistBlock("MA300013")
        aFldUsrFlt := ExecBlock("MA300013", .F., .F.,{nTipoPed,aFields})
        For nX := 1 to Len(aFldUsrFlt)
            AADD(aFields,aFldUsrFlt[nX])
        Next nX
    EndIf
    //Add field for FILTER and Seek line
    For nX := 1 To Len(aFields)
        If !(aFields[nX][1] $(cFldMarkID))
            aAdd(aSeek,{RetTitle(aFields[nX][1])/*Title*/,{{""/*LookUp*/, TamSX3(aFields[nX][1])[3]/*Type*/, TamSX3(aFields[nX][1])[1]/*Size*/,;
                           TamSX3(aFields[nX][1])[2]/*Decimal*/,aFields[nX][4]}}} )
            aAdd(aFilter, {aFields[nX][1], RetTitle(aFields[nX][1]), TamSX3(aFields[nX][1])[3], TamSX3(aFields[nX][1])[1],; 
                           TamSX3(aFields[nX][1])[2], aFields[nX][4]} )
        EndIf
    Next nX 

    oDlg := MsDialog():New(aSize[7], aSize[2], aSize[6], aSize[5], cTitle, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.)

    oMark := FWMarkBrowse():New()
    oMark:SetFieldMark(cCampoOk)
    oMark:SetOwner(oDlg)
    oMark:SetDataTable(.T.)

    aTmpRot  := IIF(aRotina == Nil, Nil, ACLONE(aRotina))

    oMark:SetAlias(cAliasPID)
    oMark:SetAllMark({|| A120AllMark(cMarca, aMarca)})
    oMark:bMark := ({|| A120AddMark(cMarca, aMarca , oMark, lMarkAll)})
    oMark:SetMark(cMarca, cAliasPID, cCampoOk)
    oMark:SetDescription(cTitle)

    //Addition columns which not on Browse of SC1(SC3) table
    If ExistBlock("MA300010")
        aFldUsr := ExecBlock("MA300010", .F., .F.,{aFields})
        
        If ValType(aFldUsr) == 'A'
            aColumns := {}
            For nX := 1 TO Len(aFldUsr)
                oOneColumn := FWBrwColumn():New()
                oOneColumn:SetTitle(aFields[nX][3])
                oOneColumn:SetData(&("{||"+aFields[nX][1]+"}"))
                oOneColumn:SetSize(TamSx3(aFields[nX][1])[1])
                oOneColumn:SetDecimal(TamSx3(aFields[nX][1])[2])
                oOneColumn:SetPicture(aFields[nX][4])
                AADD(aColumns, oOneColumn)
            Next nX
            oMark:SetColumns(aColumns)
        EndIf
    EndIf
    
    oMark:DisableReport()
    oMark:DisableSaveConfig()
    oMark:DisableConfig()
    oMark:SetMenuDef("")
    oMark:SetIgnoreARotina(.T.)
    oMark:SetSeeAll(.F.)
    oMark:SetSeek(.T., aSeek)
    
    //add Filter
    oMark:SetUseFilter(.T.)
    oMark:SetProfileID("RU02T01ENS")  //ID for filter
    oMark:SetFieldFilter(aFilter) //Set Filters
    oMark:SetDBFFilter(.T.)
    oMark:SetFilterDefault(cFilter)

    // Add Buttons
    oMark:AddButton(STR0006, {||(nRet:=1),(oDlg:End())}, 0, 3)              //"Save"
    oMark:AddButton(STR0005, {|| a120VisuSC(RecNo(),cFilter)}, 0, 2)        //"View"
    oMark:AddButton(STR0004, {|| RU02T02001(oMark,.T.,nTypeOrder)} ,0, 1)   //"Search"
    

    oMark:Activate()

    //Use for addition buttons
    If ExistBlock("MA300009")
        aUsrBut := ExecBlock("MA300009", .F., .F.,{})
        If ValType(aUsrBut) <> 'A'
            For nX := 1 To aUsrBut
                oMark:AddButton(aUsrBut[nX][1], {|| aUsrBut[nX][2]}, aUsrBut[nX][3], aUsrBut[nX][4])  
            Next nX
        EndIf
    EndIf

    oDlg:Activate(,,,.T.,,,)
    
    aRotina  := aTmpRot
Return nRet

/*/{Protheus.doc} RU02T02001_a120Pesqui
    Function Search in MarkBrowse
    @type function
    @author ALexandra Velmozhnaya
    @since 2021/10/12
    @version 1.0
    @param  oGetDados  Object   Object where seach
            lSC        Logical     Choosen records 
            nTypeOrder  Numeric   Type of Purchase order (1 - Purchase Request; 2 - Partnership contract)

    @return True

    @see specification RULOC-1751 - refactoring MSSelect for FWMarkBrowse
    @use a120PID
    /*/
Function RU02T02001_a120Pesqui(oGetDados,lSC, nTypeOrder)

    DEFAULT lSC := .F.
    axPesqui()

    If !lSC .Or. IIf(nTypeOrder == 2,SC3->(EOF()),SC1->(EOF()))
        If ValType(oGetDados) == "O"
            oGetDados:oBrowse:Refresh()
        EndIf
    Else
        If nTypeOrder == 2
            oGetDados:GoTo(SC3->(Recno()),.T.)
        Else
            oGetDados:GoTo(SC1->(Recno()),.T.)
        EndIf
    Endif

Return  .T.

//End of file
//Merge Russia R14                   
