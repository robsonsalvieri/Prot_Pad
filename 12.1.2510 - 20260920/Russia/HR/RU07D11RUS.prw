#Include "RU07D11RUS.CH"
#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "REPORT.CH"
#Include "PARMTYPE.CH"
#Include "FWMVCDEF.CH"
#Include "FWMBROWSE.CH"

/*
*    Defenition of constants.
*/
#Define MIN_RPO_VERSION "12.1.2310"
#Define PROGRAM_NAME "RU07D11RUS"
#Define MAIN_TABLE "F5I"
#Define PERGUNTE_CALCULATION "RU07D11" // Using for calculation.
#Define PERGUNTE_GENERATION "RU07RG11" // Using for integration into RGB.
#Define PERGUNTE_REPORT "RU07R11" // Using for make a report.
#Define PERGUNTE_DELETE_DATA "RU07D11DEL" // Using for delete previous calculated data.
#Define PERGUNTE_VIEW_DATA "RU07D11V" // Using for view calculated data.
#Define PAYMENT_FOR_RETRO "S" // Payment is included in recalculation. 
#Define SALARY_SCENARIO_NAME "FOL"
#Define TAX_DEDUCTION_CANCELED "1" // F5D_CANCEL.
#Define TAX_DEDUCTION_ACTIVE "2"  // F5D_CANCEL.
#Define MIN_REFERENCE_DAY 28
#Define PAYMENT_IS_INTEGRATED "S" // Payment is integrated.

/*
*    Defenition of static variables.
*/
Static __cPeriodCalc
Static __cProcesCalc
Static __cNumPgCalc
Static lIntegDef := FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI")
Static cFilAnterior := cFilAnt
Static lValInfo := .F. // Remove mention of variable when release 12.1.23 dies.




/*{Protheus.doc} RU07D11RUS()
    Main function for routine Retro calculation.

    @type Function
    @author vselyakov
    @since 31.01.2024
    @version 12.1.2310
*/
Function RU07D11RUS(nPosaRotina, aItens)
    Local lCanContinue := .T. As Logical
    Local aArea := GetArea() As Array
    Local aSRVArea := SRV->(GetArea()) As Array

    Local aOfusca	:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
    Local aFldRel	:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})

    /*
    *    Defenition of private variable.
    *    Initializes execution variables.
    *
    *    WHEN DECLARING PRIVATE VARIABLES HERE, BE CAREFUL IF 
    *    IT WILL BE NECESSARY TO DECLARE IT IN GPEM020 ON ACCOUNT OF THE GRID (Gpem020Amb)
    */
    Private lOfusca := Len(aFldRel) > 0 As Logical
    Private aErrProc := Array(2, 0) As Array
    Private aRotina := {} As Array // Adjustment for version 9.12 - call of the MenuDef() function that contains the Routine.
    Private cCadastro := STR0006 As Character // "Retrocalculation".
    Private bFiltraBrw := {|| Nil} // Variable for filter.
    Private lGP690SAL := ExistBlock("GP690SAL") As Logical
    Private lGP690Fil := ExistBlock("GP690FIL") As Logical
    Private cProcesso := "" As Character
    Private cFilRCJ := "" As Character
    Private aMnemo := {} As Array
    Private lAuto As Logical
    Private nDisSalInc := 0 As Numeric
    Private cPerg := PERGUNTE_CALCULATION As Character

    Static aDados := {}

    DEFAULT nPosaRotina := 0

    aDados := If(Empty(aItens), {}, aItens)
    cFilAnterior := cFilAnt
    lValInfo := F5I->(ColumnPos("F5I_VALINF")) > 0
    aRotina := MenuDef()

    // Checks if the file is empty.
    If !ChkVazio("SRA")
        lCanContinue := .F.
    EndIf

    If GetRPORelease() < MIN_RPO_VERSION
        MsgStop("Your RPO version is old. Update your system!", "Error")
        lCanContinue := .F.
    EndIf

    If lCanContinue
        DbSelectArea("SRV")
        If Len(SRV->(RV_CODFOL)) == 3
            //"Attention", "Before proceeding, you must follow the procedures in the technical bulletin - update the ID field for calculation".
            Help("", 1, STR0019, Nil, STR0137, 1, 0)
            lCanContinue := .F.
        EndIf
    EndIf

    If lCanContinue
        SetMnemonicos(NIL, @aMnemo, .T.) // Loads mnemonics.

        If lAuto := !Empty(nPosaRotina) .And. (!Empty(aDados) .Or. (Empty(aDados) .And. nPosaRotina != 2))
            If nPosArotina > 4
                &(aRotina[nPosArotina, 2])
            Else
                &(aRotina[nPosArotina, 2] + "()")
            EndIf
        Else
            // Create Browse.
            oBrwSRA := FwMBrowse():New()
            oBrwSRA:SetAlias("SRA")
            oBrwSRA:SetDescription(cCadastro)
            oBrwSRA:SetmenuDef("RU07D11")
            GpLegMVC(@oBrwSRA) // Add the subtitle in the browse.
            oBrwSRA:Activate()
        EndIf
    EndIf

    SRV->(RestArea(aSRVArea))
    RestArea(aArea)

Return


/*{Protheus.doc} MenuDef()
    Menu for routine Retro calculation.

    @type Static Function
    @author vselyakov
    @since 31.01.2024
    @version 12.1.2310
*/
Static Function MenuDef()
    Local aMenuItems := {} As Array
    Local lIsMenuCustom := ExistBlock("RU7D11MN") As Logical
    Local aCustomMenuItems := {} As Array

    aAdd(aMenuItems, {STR0001, "PesqBrw",         0, 1, 0, NIL}) // "Search".
    aAdd(aMenuItems, {STR0002, "RU07D11001()",    0, 4, 0, NIL}) // "Calculation".
    aAdd(aMenuItems, {STR0003, "VIEWDEF.RU07D11", 0, 2, 0, NIL}) // "View".
    aAdd(aMenuItems, {STR0212, "RU07R11008()",    0, 4, 0, NIL}) // "Integration".
    aAdd(aMenuItems, {STR0064, "RU07D11015()",    0, 5, 0, NIL}) // "Delete".
    aAdd(aMenuItems, {STR0004, "RU07R11007()",    0, 4, 0, NIL}) // "Print".
    aAdd(aMenuItems, {STR0225, "RU07D11023()",    0, 4, 0, NIL}) // "Export to Excel".

    /*
        The custom function "RU7D11U01" must return an array of menu items.
        If there is an extension point then execute it and add elements to the menu items array.
    */
    If lIsMenuCustom
        aCustomMenuItems := ExecBlock("RU7D11U01", .F., .F.)
        aAdd(aMenuItems, aCustomMenuItems)
    EndIf

Return aMenuItems

/*{Protheus.doc} ModelDef()
    Defenition of model.

    @type Static Function
    @return Object, MpFormModel object.
    @author vselyakov
    @since 13.02.2024
    @version 12.1.2310
*/
Static Function ModelDef()
    Local oModel As Object
    Local oStructSRA As Object
    Local oStructF5I As Object

    Private cMesAnoIni := "" As Character
    Private cMesAnoFim := "" As Character

    oModel:= MpFormModel():New("RU07D11RUS", /*Pre-Validacao*/, , /*Commit*/, /*bCancel*/)

    // SRA structure.
    oStructSRA := FWFormStruct(1, "SRA", {|cCampo| AllTrim(cCampo) + "|" $ "RA_FILIAL|RA_MAT|RA_NOMECMP|RA_ADMISSA|"})

    oModel:AddFields("RU07D11_MSRA", /*cOwner*/, oStructSRA, /*Pre-Validacao*/, /*Pos-Validacao*/, {|oFieldModel| ViewF5I(oFieldModel, 1)} /*Charge*/)
    oModel:GetModel("RU07D11_MSRA"):SetOnlyView( .T. )
    oModel:GetModel("RU07D11_MSRA"):SetOnlyQuery( .T. )

    // F5I structure.
    oStructF5I := GetF5IStruct(1)
    oModel:AddGrid("RU07D11_MF5I", "RU07D11_MSRA", oStructF5I,/*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/, {|oGrid| ViewF5I(oGrid, 2)}/*bLoad*/)
    oModel:GetModel("RU07D11_MF5I"):SetDescription(STR0006)

    oStructF5I:AddTrigger("VERBORI", "DESCVOR", {|| .T. }, {|oModel| RetValSRV(oModel:GetValue("VERBORI"), xFilial("SRV"), "RV_DESC")})
    oStructF5I:SetProperty("VERBORI", MODEL_FIELD_VALID, {|oModel| ExistCpo("SRV")})

    oModel:GetModel("RU07D11_MF5I"):SetNoInsertLine(.F.)
    oModel:GetModel("RU07D11_MF5I"):SetNoDeleteLine(.F.)
    oModel:GetModel("RU07D11_MF5I"):SetNoUpdateLine(.F.)
    oModel:GetModel("RU07D11_MF5I"):SetOptional(.T.)

    oModel:SetRelation("RU07D11_MF5I", {{'F5I_FILIAL', 'FwxFilial("F5I")'}, {'F5I_MAT', 'RA_MAT'}}, F5I->(IndexKey(1)))
    oModel:GetModel("RU07D11_MF5I"):SetOnlyQuery(.T.)

Return oModel


/*{Protheus.doc} ViewF5I
    Return structure of F5I table.
    Copy of ViewRHH.

    @type Static Function
    @param oGrid, Object, Object of table structure.
    @param nTipo, Numeric, 1=Model;2=View.
    @return Object, Updated object of table structure.
    @author vselyakov
    @since 13.02.2024
    @version 12.1.2310
*/
Static Function ViewF5I(oGrid, nTipo)
    Local aResults := {} As Array
    Local lCanContinue := .T. As Logical
    Local aArea := GetArea() As Array
    Local aCodFol := {} As Array
    Local cDescVbOr := "" As Character
    Local cDescVbPg := "" As Character
    Local cPeriodFrom := "" As Character
    Local cPeriodTo := "" As Character
    Local cQuery := "" As Character
    Local oStatement := FWPreparedStatement():New() As Object
    Local cAlias := "" As Character

    Default nTipo := 0

    cPeriodFrom := Right(MV_PAR01, 4) + Left(MV_PAR01, 2)
    cPeriodTo := Right(MV_PAR02, 4) + Left(MV_PAR02, 2)

    If ValType(oGrid) <> "O"
        lCanContinue := .F.
    EndIf

    If lCanContinue .And. nTipo == 1
        aResults := FormLoadField(oGrid, .T.)
    EndIf

    // Upload funds registration for later filtering.
    If !Fp_CodFol(@aCodFol, xFilial("SRA", SRA->RA_FILIAL))
        lCanContinue := .F.
    Endif

    If lCanContinue .And. nTipo == 2
        // Loading data from F5I for selected employee using by SQL.
        cQuery := " SELECT "
        cQuery += "     R_E_C_N_O_ AS RECNO, F5I_DATA, F5I_SEMANA, F5I_VB, F5I_VERBA, F5I_VL, F5I_CALC, F5I_VALINF, F5I_VALOR, F5I_HORAS, F5I_COMPL_, F5I_INTEGR, F5I_ROTEIR, F5I_MESANO "
        cQuery += " FROM " + RetSqlName("F5I") 
        cQuery += " WHERE                     "
        cQuery += "     D_E_L_E_T_ = ' '      "
        cQuery += "     AND F5I_FILIAL = ?    "
        cQuery += "     AND F5I_MAT = ?       "
        cQuery += "     AND F5I_DATA >= ?     "
        cQuery += "     AND F5I_DATA <= ?     "
        cQuery += " ORDER BY F5I_DATA, F5I_VB "
        
        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, SRA->RA_FILIAL)
        oStatement:SetString(2, SRA->RA_MAT)
        oStatement:SetString(3, cPeriodFrom)
        oStatement:SetString(4, cPeriodTo)
        
        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())
        
        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())

        While !(cAlias)->(Eof())
            cDescVbOr := fDesc("SRV", (cAlias)->F5I_VB, "RV_DESC")
            cDescVbPg := fDesc("SRV", (cAlias)->F5I_VERBA, "RV_DESC")
            
            aAdd(aResults, { (cAlias)->RECNO                             ,;
            {                                                             ;
                (cAlias)->F5I_DATA                                       ,;
                (cAlias)->F5I_SEMANA                                     ,;
                (cAlias)->F5I_VB                                         ,;
                cDescVbOr                                                ,;
                (cAlias)->F5I_VERBA                                      ,;
                cDescVbPg                                                ,;
                (cAlias)->F5I_VL                                         ,;
                (cAlias)->F5I_CALC                                       ,;
                (cAlias)->F5I_VALINF                                     ,;
                Iif(!Empty((cAlias)->F5I_VALOR), (cAlias)->F5I_VALOR, 0) ,;
                (cAlias)->F5I_HORAS                                      ,;
                Iif((cAlias)->F5I_COMPL_ == "S", STR0043, STR0044)       ,; // "Yes", "No".
                Iif((cAlias)->F5I_INTEGR == "S", STR0043, STR0044)       ,; // "Yes", "No".
                (cAlias)->F5I_ROTEIR                                     ,;
                (cAlias)->F5I_MESANO                                      ;
            }})

            (cAlias)->(DbSkip())
        EndDo

        (cAlias)->(DbCloseArea())
    EndIf

    If Empty(aResults)
        aAdd(aResults, {0, {"", "", "", "", "", "", 0, 0, 0, 0, 0, "", "N", "", CToD("//"), ""}})
    EndIf

    RestArea(aArea)

Return aResults

/*{Protheus.doc} FiltraVb
    Filters funding codes that should not be displayed in screen or listed in the report.

    @type Static Function
    @param aCodFol, Array, Array of payments.
    @return Character, Line listing payment types.
    @author vselyakov
    @since 13.02.2024
    @version 12.1.2310
*/
Static Function FiltraVb(aCodFol)
    Local cNotCods := "" As Charater

    // LEAVE IT
    // For example: cNotCods := aCodFol[012, 1] + "," + aCodFol[066, 1]

Return cNotCods


/*{Protheus.doc} ViewDef
    Defenition of view object.

    @type Static Function
    @return Object, FWFormView object.
    @author vselyakov
    @since 13.02.2024
    @version 12.1.2310
*/
Static Function ViewDef()
    Local oModel := FwLoadModel("RU07D11RUS") As Object
    Local oStructSRA As Object
    Local oStructF5I As Object
    Local oView As Object
    
    oView := FWFormView():New()
    oView:SetModel(oModel)

    oStructSRA := FWFormStruct(2, "SRA", {|cCampo| AllTrim(cCampo) + "|" $ "RA_MAT|RA_NOMECMP|RA_ADMISSA|"})
    oStructSRA:SetNoFolder()

    oView:AddField("RU07D11_VSRA", oStructSRA, "RU07D11_MSRA")

    oStructF5I := GetF5IStruct(2) // Get F5I strucure.
    oView:AddGrid("RU07D11_VF5I", oStructF5I, "RU07D11_MF5I")

    oView:CreateHorizontalBox("SRA_HEAD", 20)
    oView:createHorizontalBox("FORMGRID", 80)

    oView:SetOwnerView("RU07D11_VSRA", "SRA_HEAD")
    oView:SetOwnerView("RU07D11_VF5I", "FORMGRID")

    oView:SetOnlyView("RU07D11_VSRA")

    oView:SetCloseOnOk({|| .T.})
    oView:ShowUpdateMsg(.F.)
    oView:SetViewCanActivate({|oModel| RU07D11010_ViewValidation(oModel, oModel:GetOperation())})

Return oView


/*{Protheus.doc} GetF5IStruct
    Getting F5I Structure.
    Copy of GP690StrRHH.

    @type Static Function
    @param nTipo, Numeric, 1=Model;2=View.
    @return Object, FWFormViewStruct or FWFormModelStruct object.
    @author vselyakov
    @since 13.02.2024
    @version 12.1.2310
*/
Static Function GetF5IStruct(nTipo)
    Local aArea := GetArea() As Array
    Local bValid := Nil
    Local bWhen := {|| .F. }
    Local bNewWhen := {|oModel| oModel:IsInserted()}
    Local bRelac := Nil
    Local aTitles := {} As Array
    Local nI := 1 As Numeric
    Local oStruct As Object

    Default nTipo := 1

    If nTipo == 1
        oStruct := FWFormModelStruct():New()
    Else
        oStruct := FWFormViewStruct():New()
    EndIf

    aTitles := {    { STR0014, STR0014, 'DATREFE', 'C', TamSX3("F5I_DATA")[1],   TamSX3("F5I_DATA")[2],   GetSx3Cache("F5I_DATA",   "X3_PICTURE"), .T., Nil,      bNewWhen} ,; // "Reference date".
                    { STR0081, STR0081, 'SEMANA' , 'C', TamSX3("F5I_SEMANA")[1], TamSX3("F5I_SEMANA")[2], GetSx3Cache("F5I_SEMANA", "X3_PICTURE"), .T., Nil,      bNewWhen} ,; // "Payment no.".
                    { STR0012, STR0012, 'VERBORI', 'C', TamSX3("F5I_VB")[1],     TamSX3("F5I_VB")[2],     GetSx3Cache("F5I_VB",     "X3_PICTURE"), .T., 'SRV',    bNewWhen} ,; // "Original payment code".
                    { STR0056, STR0056, 'DESCVOR', 'C', TamSX3("F5I_DESCVB")[1], TamSX3("F5I_DESCVB")[2], GetSx3Cache("F5I_DESCVB", "X3_PICTURE"), .F., Nil,      bWhen}    ,; // "Description".
                    { STR0015, STR0015, 'VERBPGT', 'C', TamSX3("F5I_VERBA")[1],  TamSX3("F5I_VERBA")[2],  GetSx3Cache("F5I_VERBA",  "X3_PICTURE"), .F., Nil,      bWhen}    ,; // "Payment code".
                    { STR0056, STR0056, 'DESCVPG', 'C', TamSX3("F5I_DESCVB")[1], TamSX3("F5I_DESCVB")[2], GetSx3Cache("F5I_DESCVB", "X3_PICTURE"), .F., Nil,      bWhen}    ,; // "Description".
                    { STR0013, STR0013, 'VALORI' , 'N', TamSX3("F5I_VL")[1],     TamSX3("F5I_VL")[2],     GetSx3Cache("F5I_VL",     "X3_PICTURE"), .F., Nil,      bWhen}    ,; // "Initial values".
                    { STR0017, STR0017, 'VALCAL' , 'N', TamSX3("F5I_CALC")[1],   TamSX3("F5I_CALC")[2],   GetSx3Cache("F5I_CALC",   "X3_PICTURE"), .F., Nil,      bWhen}    ,; // "Estimated value".
                    { STR0162, STR0162, 'VALINF' , 'N', TamSX3("F5I_VALINF")[1], TamSX3("F5I_VALINF")[2], GetSx3Cache("F5I_VALINF", "X3_PICTURE"), .T., Nil,{|oModel| oModel:GetValue('VERBORI') <> '000' }} ,; // "Decree. price".
                    { STR0018, STR0018, 'VALPAG' , 'N', TamSX3("F5I_VALOR")[1],  TamSX3("F5I_VALOR")[2],  GetSx3Cache("F5I_VALOR",  "X3_PICTURE"), .F., Nil,      bWhen}    ,; // "Amount to be paid".
                    { STR0218, STR0218, 'HORAS'  , 'N', TamSX3("F5I_HORAS")[1],  TamSX3("F5I_HORAS")[2],  GetSx3Cache("F5I_HORAS",  "X3_PICTURE"), .F., Nil,      bWhen}    ,; // "Days/Hours". 
                    { STR0052, STR0052, 'COMPL_' , 'C', TamSX3("F5I_COMPL_")[1], TamSX3("F5I_COMPL_")[2], GetSx3Cache("F5I_COMPL_", "X3_PICTURE"), .F., Nil,      bWhen}    ,; // "Selected".
                    { STR0123, STR0123, 'INTEGR' , 'C', TamSX3("F5I_INTEGR")[1], TamSX3("F5I_INTEGR")[2], GetSx3Cache("F5I_INTEGR", "X3_PICTURE"), .F., Nil,      bWhen}    ,; // "Integrated".
                    { STR0139, STR0139, 'ROTEIR' , 'C', TamSX3("F5I_ROTEIR")[1], TamSX3("F5I_ROTEIR")[2], GetSx3Cache("F5I_ROTEIR", "X3_PICTURE"), .T., 'SRYDES', bNewWhen} ,; // "Original scenario".
                    { STR0200, STR0200, 'MESANO' , 'D', TamSX3("F5I_MESANO")[1], TamSX3("F5I_MESANO")[2], GetSx3Cache("F5I_MESANO", "X3_PICTURE"), .F., Nil,      bWhen}}      // "Payment period".


    For nI := 1 To Len(aTitles)
        If nTipo = 1
            oStruct:AddField(   ;
            aTitles[nI][1]     ,; // [01] Field title.
            aTitles[nI][2]     ,; // [02] Field ToolTip.
            aTitles[nI][3]     ,; // [03] Field ID.
            aTitles[nI][4]     ,; // [04] Field type.
            aTitles[nI][5]     ,; // [05] Field Size.
            aTitles[nI][6]     ,; // [06] Field decimal.
            bValid             ,; // [07] Field validation code-block.
            aTitles[nI][10]    ,; // [08] Field validation When code-block.
            Nil                ,; // [09] List of allowed field values.
            .F.                ,; // [10] Indicates whether the field is mandatory.
            bRelac             ,; // [11] Field initialization code-block.
            NIL                ,; // [12] Indicates whether it is a key field.
            .F.                ,; // [13] Indicates whether the field cannot receive a value in an update operation..
            .F.)                  // [14] Indicates whether the field is virtual.
        Else
            oStruct:AddField(              ;
                aTitles[nI][3]            ,; // [01] Field.
                alltrim(strzero(nI,2))    ,; // [02] Order.
                aTitles[nI][1]            ,; // [03] Title.
                aTitles[nI][1]            ,; // [04] Description.
                NIL                       ,; // [05] Help.
                "GET"                     ,; // [06] COMBO, GET or CHECK field type.
                aTitles[nI][7]            ,; // [07] Picture.
                Nil                       ,; // [08] PictVar.
                aTitles[nI][9]            ,; // [09] F3.
                aTitles[nI][8]            ,; // [10] Editable.
                Nil                       ,; // [11] Folder.
                Nil                       ,; // [12] Group.
                Nil                       ,; // [13] Combo List.
                Nil                       ,; // [14] Tam Max Combo.
                Nil                       ,; // [15] Start. Browse.
                .F.)                         // [16] Virtual.

        EndIf
    Next nI

    RestArea(aArea)

Return oStruct


/*{Protheus.doc} RU07D11001
    Start process of calculation.
    Copy of GP690CALC.

    @type Function
    @author vselyakov
    @since 31.01.2024
    @version 12.1.2310
*/
Function RU07D11001()
    Local aArea := GetArea() As Array
    Local aRCJArea := RCJ->(GetArea()) As Array
    Local bProcess := {|oSelf| RU07D11002(oSelf)}
    Local cDescription := STR0050 As Character // "Calculation for reverse salary agreement.";

    aErrProc:= Array(2, 0)
    cFilAnt := cFilAnterior	
    cPerg := PERGUNTE_CALCULATION
    
    Pergunte(cPerg, .F.) // Load parameters.

    // Create a dialog screen.
    cCadastro := STR0006 // "Retrocalculation".
    cProcesso := MV_PAR01

    If !Empty(cProcesso)
        DbSelectArea("RCJ")
        RCJ->(DbSetOrder(1)) // "RCJ_FILIAL+RCJ_CODIGO".
        
        If RCJ->(DbSeek(xFilial("RCJ") + cProcesso))
            cFilRCJ := xFilial("RCH", SRA->RA_FILIAL)
        EndIf
    EndIf

    If !lAuto
        TNewProcess():New(PROGRAM_NAME, cCadastro, bProcess, cDescription, cPerg, , .T., 20, cDescription, .T., .T.)
    Else
        RU07D11002()
    EndIf

    RCJ->(RestArea(aRCJArea))
    RestArea(aArea)
Return

/*{Protheus.doc} RU07D11002
    Retrocalculation function.
    Copy of GP690CAL.

    @type Function
    @author vselyakov
    @since 31.01.2024
    @version 12.1.2310
*/
Function RU07D11002(oSelf, lRecalculo)
    Local aArea := GetArea() As Array
    Local aF5IArea := F5I->(GetArea()) As Array
    Local aMeses := {} As Array
    Local aPerAberto := {} As Array
    Local aPerFechado := {} As Array
    Local aPerTodos := {} As Array
    Local aProcessoLog := {} As Array
    Local aSavMsgLog := {} As Array
    Local aSavProcLog := {} As Array
    Local aIndex := {} As Array
    Local aIRMV := {} As Array
    Local aHdrMestre := {} As Array
    Local cMesAnoDe := "" As Character
    Local cMesAnoAte := "" As Character
    Local cMesCabec := "" As Character
    Local cMsgLog := "" As Character
    Local cQuery := "" As Character
    Local cUltDia := "" As Character
    Local cExpFiltro := "" As Character // Variable with filter return.
    Local cAuxFiltro := "" As Character // Filter return with branch.
    Local cTabMestra := "SRA" As Character // Master table name.
    Local cAliasSRA := "QSRA" As Character
    Local cSit := "" As Character
    Local cCat := "" As Character
    Local cFilRange := "" As Character
    Local cCCRange := "" As Character
    Local cMatRange := "" As Character
    Local cWhere := "" As Character
    Local nPos := 0 As Numeric
    Local nRecCount := 0 As Numeric
    Local nI := 0 As Numeric
    Local nJ := 0 As Numeric
    Local nQtPer := 0 As Numeric
    Local nLog := 0 As Numeric
    Local nTReg := 0 As Numeric
    Local lNewMultV := .F. As Logical
    Local dDtMesApur := CToD("//") As Date
    Local dDtFimAcord := CToD("//") As Date
    Local cRoteiro := MV_PAR02 As Character // Script code.
    Local cAnoMesCal := MV_PAR03 As Character // Calculation period.
    Local cCategoria := MV_PAR12 As Character
    Local cArqInf := "" As Character
    Local cFilRot := "" As Character
    Local lIntegr := .F. As Logical
    Local aPerAtual := {} As Array
    Local nMonthDif := 0 As Numeric
    Local lCanContinue := .T. As Logical
    Local oStatement := Nil As Object
    Local cAliasF5I := "" As Object

    /*
    *    Private variables.
    */
    Private cAxTabMestra := "" As Character
    Private lCalIRMV := .F. As Logical // Variable used to determine whether IRMV is calculated.
    Private aGpem020Log := {} As Array
    Private aGpem020TitLog := {} As Array
    Private cFterAux := "" As Character
    Private nMinGrid := GetMvRH("MV_MINGRID",, 0) As Numeric
    Private lDissidio := .T. As Logical
    If Type("lGrid") == "U"
        Private lGrid := GetMvRH("MV_GRID", , .F.) As Logical // If the parameter is configured to use GRID.
    EndIf
    Private cSvProcesCalc := "" As Character
    Private cSvPeriodCalc := "" As Character
    Private cSvNumPgCalc := "" As Character
    Private cSvRoteiro := "" As Character
    Private cPergEspec := "" As Character
    Private cPergBen := "" As Character
    Private cCompPer := "" As Character // Competence of the Period.
    Private nBaseMesAux	:= 0 As Numeric
    Private cSemana := "  " As Character //If( cSemPerg == 2, "01", "  " ) 			// 1=nao calcula ; 2=calcula para semanalistas
    Private cSemPag := MV_PAR04 //Semana Pagamento  UTILIZADADO NA FUNCAO GRAVADISSIDIO
    Private cSituacao := MV_PAR12 As Character
    Private cTipoAum := "T01" As Character
    Private lProAdm := .T. As Logical // Proportional Admission(1-No;2-Yes).
    Private nMesProp := 0 As Numeric // Month number of proportional.
    Private cMesAnoCalc := MV_PAR03 As Character // Ssed in the fSalDiss function.
    Private cMesAnoDiss := MV_PAR03 As Character
    Private cIdCmpl := cCompl As Character
    Private aHeader := {} As Array
    Private aTELA := {0, 0} As Array
    Private aGETS := { 0 } As Array
    Private nUsado := 0 As Numeric
    Private aCols := {{}} As Array
    Private nLinGetD := 0 As Numeric
    Private cTitPerc := STR0008 As Character // "INDEX TO INCREASE ADDITIONAL.".
    Private aC := {} As Array
    Private aR := {} As Array
    Private aCGD := {} As Array
    Private cExclui := "" As Character
    Private aFaixas := {} As Array
    Private aCodFol := {} As Array
    Private aPercDif := {} As Array
    Private aFilRCH := {} As Array
    Private lAbortPrint := .F. As Logical
    Private nVlPiso := 0 As Numeric
    Private nPisoMes := nVlPiso As Numeric
    Private nPisoDia := (nVlPiso) / 30 As Numeric
    Private nPisoHora := (nVlPiso) / 220 As Numeric
    Private nPercDif := 0 As Numeric
    Private nPercProp := 0 As Numeric
    Private nValAum := 0 As Numeric
    Private cDatArq := "" As Character
    Private dDInicioTar := CToD("//") As Date
    Private aSalInc := {} As Array
    Private aTotRegs := Array(2) As Array
    Private aLog := {} As Array
    Private aTitle := {} As Array
    Private cAnoMesProp := "" As Character
    Private nOrigHor := 0 As Numeric
    Private nOrigVal := 0 As Numeric
    Private nOrigHrMat := 0 As Numeric
    Private nOrigVlMat := 0 As Numeric
    Private lContrInt := If(SRC->(ColumnPos("RC_CONVOC")) > 0, .T., .F.) As Logical
    Private oPercDif As Object

    Default lRecalculo := .F.

    MakeSqlExpr(cPerg) // Transforms Range type questions into SQL expression.

    // Checks whether the process was selected for validation of the corresponding period.
    If !IsBlind() .And. (Empty(cFilRCJ) .And. !Empty(xFilial("RCJ")))
        Help( ,, STR0019,, STR0151 , 1,,,,,,, {STR0152}) // "Attention", "The billing period could not be found.", "Select the process again to have the system update the period data.".
        lCanContinue := .F. // Return .F.
    Else
        cFilRCJ := Iif(Empty(cFilRCJ), xFilial("RCH"), cFilRCJ)
    EndIf

    If lCanContinue
        // Validates the calculation periods for other branches defined in the Branch question.
        aFilRCH := GetPeriod(cRoteiro)

        If Len(aFilRCH) > 0
            For nQtPer := 1 To Len(aFilRCH)
                If !Empty(aFilRCH[nQtPer, 2])
                    Help(' ', 1, 'PER_FECHADO')
                    lCanContinue := .F.
                EndIf

                aPerAtual := {}

                If lCanContinue .And. fGetPerAtual(@aPerAtual, aFilRCH[nQtPer, 1], cProcesso, cRoteiro)
                    If aFilRCH[nQtPer, 4] != aPerAtual[1, 1]
                        Help( ,, STR0019,, STR0196 + aFilRCH[nQtPer, 3], 1,,,,,,, {STR0153}) // "Attention", "Payment period: not open for branch:", "Select the process again to have the system update the period data.".
                        lCanContinue := .F.
                    EndIf
                Else
                    Help(" ", 1, "GPCALEND", ) // There is no registered period.
                    lCanContinue := .F.
                EndIf
            Next nQtPer
        Else
            Help(" ", 1, "GPCALEND", ) // There is no registered period.
            lCanContinue := .F.
        EndIf
    EndIf

    // Check selected period.
    If lCanContinue .And. Empty(MV_PAR03)
        Help("", 1, STR0019, Nil, STR0090, 1, 0) // "Attention", "Fill in the 'Month/year of calculation' parameter".
        lCanContinue := .F.
    EndIf

    If lCanContinue
        dDtMesApur := CToD("01/" + SubStr(cAnoMesCal, 5, 2) + "/" + SubStr(cAnoMesCal, 1, 4), "DDMMYYYY")
        cUltDia := Str(Last_Day(dDtMesApur))
        dDtFimAcord := CToD(cUltDia + "/" + SubStr(cAnoMesCal, 5, 2) + "/" + SubStr(cAnoMesCal, 1, 4), "DDMMYYYY")

        aFill(aTotRegs, 0)

        // Adjusts work variables.
        If Empty(MV_PAR05) .Or. Empty(MV_PAR06)
            Help("", 1, STR0019, Nil, STR0062, 1, 0) // "Attention", "Fill out the negotiation settlement period".
            lCanContinue := .F.
        EndIf

        cMesCabec := SubStr(MV_PAR05, 3, 4) + SubStr(MV_PAR05, 1, 2)
        cMesAnoDe := SubStr(MV_PAR05, 3, 4) + SubStr(MV_PAR05, 1, 2)
        cMesAnoAte := SubStr(MV_PAR06, 3, 4) + SubStr(MV_PAR06, 1, 2)

        If cAnoMesCal + MV_PAR04 == cMesAnoDe + "01" .Or. cAnoMesCal + MV_PAR04 == cMesAnoAte + "01"
            Help("", 1, STR0019, Nil, STR0194, 1, 0) // "Attention", "Correct the month and year (from/to), decree. in the parameters, since they both must be related to closed. periods.".
            lCanContinue := .F.
        EndIf

        If cMesAnoDe <= cMesAnoAte
            If (Right(cMesAnoDe, 2) < "01" .Or. Right(cMesAnoDe, 2) > "12") .Or. (Right(cMesAnoAte, 2) < "01" .Or. Right(cMesAnoAte, 2) > "12")
                Help("", 1, STR0019, Nil, STR0058, 1, 0) // "Attention", "Correct the values from/to month and year, within the parameters, since both should be. between 01 (January) and 12 (December)".
                lCanContinue := .F.
            EndIf
        Else
            Help("", 1, STR0019, Nil, STR0061, 1, 0) // "Attention", "Check data entry compatibility.".
            lCanContinue := .F.
        EndIf
    EndIf

    /*
    *    Checks whether the calculation has already been carried out.
    */
    If lCanContinue .And. !lRecalculo
        cQuery := " SELECT F5I_FILIAL, F5I_DATA, F5I_MAT, F5I_MESANO, F5I_VB, F5I_CC, F5I_ITEM, F5I_CLVL, F5I_INTEGR "
        cQuery += " FROM " + RetSqlName("F5I") + " AS F5I "
        cQuery += " INNER JOIN " + RetSqlName("SRA")  + " AS SRA "
        cQuery += "     ON RA_FILIAL = F5I_FILIAL AND RA_MAT = F5I_MAT "
        cQuery += " WHERE "
        cQuery += "     F5I.F5I_DATA BETWEEN '" + cMesAnoDe + "' AND '" + cMesAnoAte + "' "
        cQuery += "     AND F5I.F5I_MESANO = '" + cMesAnoCalc + "' "

        // RA_CC.
        If !Empty(MV_PAR08)
            cQuery += " AND " + Replace(MV_PAR08, "RA_", "F5I_")
        EndIf

        // RA_MAT.
        If !Empty(MV_PAR09)
            cQuery += " AND " + Replace(MV_PAR09, "RA_", "F5I_")
        EndIf

        // RA_SITFOLH.
        If !Empty(MV_PAR10)
            cSitQuery := ""
            cSituacao := MV_PAR10

            For nI := 1 To Len(cSituacao)
                cSitQuery += "'" + Subs(cSituacao, nI, 1) + "'"

                If (nI + 1) <= Len(cSituacao)
                    cSitQuery += ","
                EndIf
            Next nI

            If !Empty(cSitQuery)
                cQuery += " AND "
                cQuery += " ( RA_SITFOLH IN (" + cSitQuery + ")) "
            EndIF
        EndIf

        // RA_CATFUNC.
        If !Empty(MV_PAR11)
            cCatQuery := ""
            cCategoria := MV_PAR11

            For nI := 1 To Len(cCategoria)
                cCatQuery += "'" + Subs(cCategoria, nI, 1) + "'"
                
                If (nI + 1) <= Len(cCategoria)
                    cCatQuery += ","
                Endif
            Next nI
            
            If !Empty(cCatQuery)
                cQuery += " AND "
                cQuery += "( RA_CATFUNC IN (" + cCatQuery + ")) "
            EndIf
        EndIf

        If !Empty(cProcesso)
            cQuery += " AND F5I_PROCES = '" + cProcesso + "' "
        EndIf

        cQuery += "     AND F5I.D_E_L_E_T_ = ' ' "
        cQuery += "     AND SRA.D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY F5I_FILIAL, F5I_DATA, F5I_MAT, F5I_MESANO, F5I_VB, F5I_CC, F5I_ITEM, F5I_CLVL "

        oStatement := FWPreparedStatement():New(cQuery)
        cAliasF5I := MPSysOpenQuery(oStatement:GetFixQuery())

        DbSelectArea(cAliasF5I)
        (cAliasF5I)->(DbGoTop())

        While !((cAliasF5I)->(Eof()))
            nTReg := nTReg + 1

            If (cAliasF5I)->F5I_INTEGR == PAYMENT_IS_INTEGRATED
                lIntegr := .T.
            EndIf

            (cAliasF5I)->(DBSkip())
        EndDo

        (cAliasF5I)->(DbCloseArea())
        oStatement:Destroy()

        // If any entries are found in F5I, the calculation stops.
        If nTReg > 0
            If !lAuto
                If lIntegr
                    MsgStop(STR0197, STR0019) // "Cannot recalculate because the selected period has already been integrated into the payroll. Check the settings. Pre-delete the integrated data in the salary calculation", "Warning".
                Else
                    MsgStop(STR0223, STR0019) // "The calculation has already been completed. Delete data first", "Warning".
                EndIf
            Else
                If lIntegr
                    ConOut("Cannot recalculate because the selected period has already been integrated into the payroll. Check the settings. Pre-delete the integrated data in the salary calculation")
                Else
                    ConOut("The calculation has already been completed. Delete data first")
                EndIf
            EndIf

            RestArea(aArea)
            lCanContinue := .F.
        EndIf
    EndIf

    If lCanContinue
        cFilRange := MV_PAR07 // Pergunte range of filials.
        cCCRange := MV_PAR08 // Pergunte range of cost centers.
        cMatRange := MV_PAR09 // Pergunte range of employee numbers.

        If !Empty(cFilRange)
            cWhere += " AND " + cFilRange
        EndIf

        If !Empty(cCCRange)
            cWhere += " AND " + cCCRange
        EndIf

        If !Empty(cMatRange)
            cWhere += " AND " + cMatRange
        EndIf

        If !Empty(cProcesso)
            cWhere += " AND (RA_PROCES = '" + cProcesso + "') "
        Endif

        For nPos := 1 To Len(cSituacao)
            If SubStr(cSituacao, nPos, 1) <> "*"
                cSit += "'" + SubStr(cSituacao, nPos, 1) + "',"
            EndIf
        Next nPos

        If Len(cSit) > 1
            cSit := SubStr(cSit, 1, Len(cSit) - 1)
            cWhere += " AND RA_SITFOLH IN(" + cSit + ") "
            nPos := 0
        EndIf

        For nPos := 1 To Len(cCategoria)
            If SubStr(cCategoria, nPos, 1) <> "*" .And. !Empty(SubStr(cCategoria, nPos, 1))
                cCat += "'" + SubStr(cCategoria, nPos, 1) + "',"
            EndIf
        Next nPos

        If Len(cCat) > 1
            cCat := SubStr(cCat, 1, Len(cCat) - 1)
            cWhere += " AND RA_CATFUNC IN(" + cCat + ") "
            nPos := 0
        EndIf

        cQuery := " SELECT "
        cQuery += "     RA_FILIAL, RA_MAT, RA_NOME, RA_SALARIO, RA_CC, R_E_C_N_O_ AS RECNO, RA_ADMISSA "
        cQuery += " FROM " + RetSQLName("SRA") + " WHERE "
        cQuery += "     D_E_L_E_T_ = ' ' "

        If !Empty(cWhere)
            cQuery += cWhere
        EndIf

        oStatement := FWPreparedStatement():New(cQuery)
        cAliasSRA := MPSysOpenQuery(oStatement:GetFixQuery())

        DbSelectArea(cAliasSRA)
        (cAliasSRA)->(DbGoTop())

        nTReg := 0

        While !((cAliasSRA)->(Eof()))
            nTReg := nTReg + 1
            (cAliasSRA)->(DBSkip())
        EndDo

        If !lAuto .And. !lRecalculo
            ProcRegua(nTReg)
            oSelf:SetRegua1(nTReg)
        EndIf

        cFilAnte := Replicate("!", FWGETTAMFILIAL)
        cFilSRVant := Replicate("!", FWGETTAMFILIAL)
        aCodFol := {}

        If ValType(oPercDif) == "O"
            HMClean(oPercDif)
            FreeObj(oPercDif)
            oPercDif := Nil
        EndIf

        oPercDif := HMNew() // Create hash map.

        (cAliasSRA)->(DbGoTop())

        While !(cAliasSRA)->(Eof())
            // Get monthes for calculations for every employee. Fill hashmap for every employee in every monthes.
            // IMPORTANT! If the hashtable does not contain an entry for each month for an employee, then the recalculation data will not be recorded!
            nMonthDif := DateDiffMonth(SToD(cMesAnoDe + "01"), SToD(cMesAnoAte + "01"))

            For nI := 0 To nMonthDif
                If (AnoMes(MonthSum(SToD(cMesAnoDe + "01"), nI)) <= cMesAnoAte) .And. AnoMes(SToD((cAliasSRA)->RA_ADMISSA)) <= AnoMes(MonthSum(SToD(cMesAnoDe + "01"), nI))
                    aAdd(aPercDif, {(cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + AnoMes(MonthSum(SToD(cMesAnoDe + "01"), nI)), 0, (cAliasSRA)->RA_SALARIO, (cAliasSRA)->RA_CC})
                    HMSet(oPercDif, (cAliasSRA)->RA_FILIAL + (cAliasSRA)->RA_MAT + AnoMes(MonthSum(SToD(cMesAnoDe + "01"), nI)), aPercDif[Len(aPercDif)])
                EndIf
            Next nI

            (cAliasSRA)->(DbSkip())
        EndDo

        (cAliasSRA)->(DbCloseArea())
        oStatement:Destroy()
        FwFreeObj(oStatement)

        If !lRecalculo
            aDissInf := {}
        EndIf

        If !lRecalculo
            If !Empty(cArqInf) // Load information from CSV file.
                fLoadCSV(cArqInf, @aDissInf)
            EndIf

            If Len(aDissInf) > 0
                aSort(aDissInf, , , {|x, y| x[1]+x[2]+x[4]+x[5]+x[6]+x[8] < y[1]+y[2]+y[4]+y[5]+x[6]+y[8]}) // Order by employee and period.
            EndIf
        EndIf

        // Recalculates the Payroll based on Adjusted Salaries.
        dDtBsOld := dDataBase

        /*
        *   Create filter for start GPEM020.
        */
        MakeAdvplExpr(cPerg)

        cExpFiltro := " "

        // Filials (RA_FILIAL).
        If !Empty(MV_PAR07)
            If At("$", MV_PAR07) > 0
                cExpFiltro += StrTran(MV_PAR07, " $ ", " $(") + ")"
                cExpFiltro := StrTran(cExpFiltro, ",", "','")
            Else
                cExpFiltro += MV_PAR07
            EndIf
        EndIf

        // Employee number (RA_MAT).
        If !Empty(MV_PAR08)
            If !Empty(cExpFiltro)
                cExpFiltro += " .AND. "
            EndIf

            If At("$", MV_PAR08) > 0
                MV_PAR08 := StrTran(MV_PAR08, " $ ", " $(") + ")"
                cExpFiltro += StrTran(MV_PAR08, ",", "','")
            Else
                cExpFiltro += MV_PAR08
            EndIf
        EndIf

        // Cost center (RA_CC).
        If !Empty(MV_PAR09)
            If !Empty(cExpFiltro)
                cExpFiltro += " .AND. "
            EndIf

            If At("$", MV_PAR09) > 0
                MV_PAR09 := StrTran(MV_PAR09, " $ ", " $(") + ")"
                cExpFiltro += StrTran(MV_PAR09, ",", "','")
            Else
                cExpFiltro += MV_PAR09
            EndIf
        EndIf

        // Employee status (RA_SITFOLH).
        If !Empty(MV_PAR10)
            cSitQuery := ""
            cSituacao := MV_PAR10

            For nI := 1 To Len(cSituacao)
                cSitQuery += "'" + Subs(cSituacao, nI, 1) + "'"
                
                If (nI + 1) <= Len(cSituacao)
                    cSitQuery += ","
                Endif
            Next nI

            If !Empty(cSitQuery)
                If !Empty(cExpFiltro)
                    cExpFiltro += " .AND. "
                EndIf

                cExpFiltro += "(RA_SITFOLH $ ("+ cSitQuery +"))"
            EndIF
        EndIf

        // Employee category (RA_CATFUNC).
        If !Empty(MV_PAR11)
            cCatQuery	:= ""
            cCategoria	:= MV_PAR11

            For nI := 1 To Len(cCategoria)
                cCatQuery += "'" + Subs(cCategoria, nI, 1) + "'"
                
                If (nI + 1) <= Len(cCategoria)
                    cCatQuery += ","
                Endif
            Next nI

            If !Empty(cCatQuery)
                If !Empty(cExpFiltro)
                    cExpFiltro += " .AND. "
                EndIf
                cExpFiltro += "(RA_CATFUNC $ ("+ cCatQuery +"))"
            EndIf
        EndIf
        
        // Role (RA_CC).
        If !Empty(MV_PAR12)
            If !Empty(cExpFiltro)
                cExpFiltro += " .AND. "
            EndIf

            If At("$", MV_PAR12) > 0
                MV_PAR12 := StrTran(MV_PAR12, " $ ", " $(") + ")"
                cExpFiltro += StrTran(MV_PAR12, ",", "','")
            Else
                cExpFiltro += MV_PAR12
            EndIf
        EndIf

        If Empty(MV_PAR07) .And. Empty(MV_PAR08) .And. Empty(MV_PAR09) .And. Empty(MV_PAR12)
            lCanContinue := MsgYesNo(STR0234, STR0019) // "No filter specified. The entire table will be processed. Continue?", "Attention".
        EndIf
    EndIf

    If lCanContinue
        // Get monthes for calculations.
        aMeses := {}
        nMonthDif := DateDiffMonth(SToD(cMesCabec + "01"), SToD(cMesAnoAte + "01"))

        For nI := 0 To nMonthDif
            If (AnoMes(MonthSum(SToD(cMesAnoDe + "01"), nI)) <= cMesAnoAte)
                aAdd(aMeses, MonthSum(SToD(cMesAnoDe + "01"), nI))
            EndIf
        Next nI

        oSelf:SetRegua1(Len(aMeses))

        For nI := 1 To Len(aMeses)
            oSelf:IncRegua1(STR0129 + " " + AnoMes(aMeses[nI]))

            For nQtPer := 1 To Len(aFilRCH)
                aPerFechado := {}
                aPerAberto := {}
                aPerTodos := {}

                RstGpexIni() // Reset variables at each branch change.

                fRetPerComp(    StrZero(Month(aMeses[nI]), 2) ,; // Required - Month to locate information.
                                StrZero(Year(aMeses[nI]), 4)  ,; // Mandatory - Year to locate information.
                                aFilRCH[nQtPer, 1]            ,; // Optional - Branch to Search.
                                cProcesso                     ,; // Mandatory - Filter by Process.
                                Nil                           ,; // Optional - Filter by Itinerary.
                                @aPerAberto                   ,; // By Reference - Array with Open periods.
                                @aPerFechado                  ,; // By Reference - Array with Closed periods.
                                @aPerTodos                     ; // By Reference - Array with Open and Closed periods in Ascending Order.
                            )

                P_MULTV := lNewMultV // Resets mnemonic to original value.

                If Len(aPerFechado) == 0
                    aAdd(aSavMsgLog, STR0149) // "Error in the period register.".
                    aAdd(aSavProcLog, STR0155 + aFilRCH[nQtPer, 1]) // "Processed branch:"
                    aAdd(aSavProcLog, STR0150 + AnoMes(aMeses[nI]) + STR0151 + cProcesso + "." ) // "No period recorded for the period", "process".
                EndIf

                aSort(aPerFechado, , , {|x, y| x[1] + x[2] + x[8] < y[1] + y[2] + y[8]}) // You must run route 132 before FOL to calculate the difference based on F5I.
                cRotOrig := ""

                For nJ := 1 To Len(aPerFechado)
                    // only LEAF and 13.
                    If fGetTipoRot(aPerFechado[nJ][8]) == "1" .Or. fGetTipoRot(aPerFechado[nJ][8]) == "6"
                        cSvProcesCalc := SetProcesCalc(aPerFechado[nJ][7]) // Set the Process for Calculation.
                        cSvPeriodCalc := SetPeriodCalc(aPerFechado[nJ][1]) // Set the Period for Calculation.

                        // Initialize variable for 13 Salary filter used in Gpem020 Processes.
                        If fGetTipoRot(aPerFechado[nJ][8]) == "6"
                            dPerFim := aPerFechado[nJ][6]
                        EndIf

                        cSvNumPgCalc := SetNumPgCalc(aPerFechado[nJ][2]) // Set the Calculation Payment Number.
                        cRoteiro := aPerFechado[nJ][8] // Arrow the Calculation Script.

                        If cRotOrig <> cRoteiro
                            cRot := ""
                            cFilCalc := "######"
                        EndIf

                        cRotOrig := cRoteiro
                        cSvRoteiro := SetRotExec(aPerFechado[nJ][8])
                        cPeriodo := cCompPer := aPerFechado[nJ][1]

                        DbSelectArea("SRY")
                        SRY->(DbSetOrder(1)) // "RY_FILIAL+RY_CALCULO".

                        If SRY->(DbSeek(xFilial("SRY", aFilRCH[nQtPer, 3]) + cRoteiro))
                            If !Empty(SRY->RY_PERGUNT)
                                If nQtPer > 1 .And. cFilRot == xFilial("SRY", aFilRCH[nQtPer, 3]) + cRoteiro
                                    Pergunte(SRY->RY_PERGUNT, .F.)
                                Else
                                    Pergunte(SRY->RY_PERGUNT, .T.)
                                EndIf

                                cFilRot := xFilial("SRY", aFilRCH[nQtPer, 3]) + cRoteiro
                                cPergEspec := SRY->RY_PERGUNT
                            EndIf
                        EndIf

                        cMsgLog := ""
                        aProcessoLog := {}
                        aIndex := {}
                        nRecCount := 0
                        aIRMV := {}
                        aHdrMestre := {}
                        cAxTabMestra := ""
                        lCalIRMV := .F. // Variable used to determine whether IRMV is calculated.
                        aGpem020Log := {}
                        aGpem020TitLog := {}
                        cDatArq := cMesAnoDe

                        // Assigns the branch being processed to the filter.
                        cAuxFiltro := cExpFiltro + If(!Empty(cExpFiltro), " AND ", " ") + "RA_FILIAL = '" + aFilRCH[nQtPer, 3] + "'"

                        M020FilFun(@lGrid, @nRecCount, cTabMestra, cProcesso, cAuxFiltro, aFilRCH[nQtPer, 1], cRoteiro, cFterAux, @cMsgLog, @aProcessoLog, @aIndex, @lCalIRMV, @aIRMV, @aHdrMestre)

                        /*
                        *    Start calculations.
                        */
                        If nRecCount > 0
                            // Recalculates the Payroll based on Adjusted Salaries and different gravel in dissidio file (F5I).
                            If lGrid
                                MsAguarde({|lEnd| Gpem020Processa(cAuxFiltro, cTabMestra, cRoteiro, .T., cFterAux, nRecCount, cMsgLog, aProcessoLog, aIndex, lCalIRMV, aIRMV, aHdrMestre)}, "", STR0148) // "Waiting...", "Preparing data for GRID...".
                            Else
                                If !lAuto
                                    Proc2BarGauge({|lEnd| Gpem020Processa(cAuxFiltro, cTabMestra, cRoteiro, .T., cFterAux, nRecCount, cMsgLog, aProcessoLog, aIndex, lCalIRMV, aIRMV, aHdrMestre)}, Nil, Nil, Nil, .T., .T., .F., .F.)
                                Else
                                    Gpem020Processa(cAuxFiltro, cTabMestra, cRoteiro, .T., cFterAux, nRecCount, cMsgLog, aProcessoLog, aIndex, lCalIRMV, aIRMV, aHdrMestre, lAuto)
                                EndIf
                            EndIf
                        Else
                            If Select(cAxTabMestra) > 0
                                (cAxTabMestra)->(DbCloseArea())
                            EndIf
                        EndIf

                        If nRecCount == 0 .Or. Len(aProcessoLog) > 0
                            If Empty(aSavMsgLog)
                                aAdd(aSavMsgLog, STR0153) // "JOURNAL Processing".
                            EndIf

                            aAdd(aSavProcLog, STR0154 + aFilRCH[nQtPer, 1]) // "Processed branch:".
                            aAdd(aSavProcLog, STR0156 + StrZero(Year(aMeses[nI]), 4) + "/" + StrZero(Month(aMeses[nI]), 2)) // "Checkout link:".

                            For nLog := 1 To Len(aProcessoLog)
                                If !Empty(aProcessoLog[nLog])
                                    aAdd(aSavProcLog, aProcessoLog[nLog])
                                EndIf
                            Next nLog

                            aAdd(aSavProcLog, "")
                            aAdd(aSavProcLog, Replicate("-", 220))
                        EndIf

                    EndIf
                Next nJ
            Next nQtPer
        Next
    EndIf

    If !Empty(aSavProcLog)
        aAdd(aSavProcLog, "")
        aAdd(aSavProcLog, Replicate("-", 220))
        aAdd(aSavProcLog, STR0156 + StrZero(Len(aFilRCH), 5)) // "Total branches processed:".
        // fMakeLog({aSavProcLog}, aSavMsgLog, cPerg, Nil, FunName(), STR0073, Nil, Nil, Nil, .F.) // "Event Log - Recalculation".
    EndIf

    // Show regular log of events.
    If !Empty(aErrProc[2])
        fMakeLog(aErrProc[2], aErrProc[1], cPerg, Nil, FunName() , STR0073 , Nil, Nil, Nil, .F.) // "Event Log - Recalculation".
    EndIf

    If Type("dDtBsOld") <> "U" .And. lCanContinue
        dDataBase := dDtBsOld
    EndIf

    If ValType(oPercDif) == "O"
        HMClean(oPercDif)
        FreeObj(oPercDif)
        oPercDif := Nil
    EndIf

    F5I->(RestArea(aF5IArea))
    RestArea(aArea)

Return lCanContinue

/*/{Protheus.doc} RU07D11010_ViewValidation
    Function for Initial View validation.
    Copy of GPM690VldIni.

    @type Function
    @param oModel, Object, Object of MpFormModel.
    @param nOperation, Numeric, Type of operation.
    @author vselyakov
    @since 16.02.2024
    @version 12.1.2310
    @return Logical, Result of validation.
    @example "oView:SetViewCanActivate({|oModel| RU07D11010_ViewValidation(oModel, oModel:GetOperation())})"
/*/
Function RU07D11010_ViewValidation(oModel, nOperation)
    Local aArea := GetArea() As Array
    Local aF5IArea := F5I->(GetArea()) As Array
    Local lResult := .T. As Logical
    Local cStartPeriod := "" As Character
    Local cEndPeriod := "" As Character

    // Upload Questions for Period to be Viewed.
    If !Pergunte(PERGUNTE_VIEW_DATA, .T.)
        lResult := .F.
    EndIf

    If lResult
        cStartPeriod := Right(MV_PAR01, 4) + Left(MV_PAR01, 2)
        cEndPeriod := Right(MV_PAR02, 4) + Left(MV_PAR02, 2)

        If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
            // "Attention", "Fill out the negotiation settlement period".
            Help("", 1, STR0019, Nil, STR0062, 1, 0)
            lResult := .F.
        EndIf

        If lResult
            // Before opening the window for viewing, the number of records in F5I in the specified period is checked.
            If GetF5ICountLines(SRA->RA_FILIAL, SRA->RA_MAT, cStartPeriod, cEndPeriod) <= 0
                // "Attention", "Reverse agreement calculation failed".
                Help("", 1, STR0019, Nil, STR0024, 1, 0)
                lResult := .F.
            EndIf
        EndIf
    EndIf
    
    F5I->(RestArea(aF5IArea))
    RestArea(aArea)

Return lResult


/*/{Protheus.doc} GetPeriod
    Validates the calculation periods of the other branches that will be processed in the dispute.
    Note: the question Branch in the dispute is of the Range type, so a query was created to return the periods of the selected branches.
    However, the RCH can be exclusive or not, so we link with the SRA to restrict the query using the SQL expression from the Branch question

    @type Static Function
    @param cScript, Character, Scenario code.
    @author vselyakov
    @since 16.02.2024
    @version 12.1.2310
    @return Array, Array of filials.
    @example "aFilRCH := GetPeriod(cRoteiro)"
/*/
Static Function GetPeriod(cScript)
    Local aArea := GetArea() AS Array
    Local cAliasRCH := "QRCH" As Character
    Local aFilRCH := {} As Character
    Local cQuery := "" As Character
    Local oStatement := Nil As Object

    Default cScript := ""

    cQuery := " SELECT DISTINCT RCH.RCH_FILIAL, RCH.RCH_PER, SRA.RA_PROCES, RCH.RCH_DTFECH, SRA.RA_FILIAL FROM  " + RetSqlName("RCH") + " RCH "
    cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA ON "
    cQuery += "     RCH.RCH_PROCES = SRA.RA_PROCES "
    cQuery += "     AND SUBSTR(SRA.RA_FILIAL, 1, 4) = SUBSTR(RCH.RCH_FILIAL, 1, 4) "
    cQuery += " WHERE                     "
    cQuery += "     SRA.D_E_L_E_T_ = ' ' "
    cQuery += "     AND RCH.D_E_L_E_T_ = ' ' "

    If !Empty(MV_PAR08)
        // Previously was executed funciton MakeSqlExpr(cPerg).
        cQuery += " AND " + MV_PAR08
    EndIf

    cQuery += "     AND RCH.RCH_PROCES = ? "
    cQuery += "     AND RCH.RCH_PER = ? "
    cQuery += "     AND RCH.RCH_NUMPAG = ? "
    cQuery += "     AND RCH.RCH_ROTEIR = ? "
    cQuery += " ORDER BY "
    cQuery += "     RCH.RCH_FILIAL "
    cQuery += "     , RCH.RCH_PER
    cQuery += "     , SRA.RA_PROCES "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cProcesso)
    oStatement:SetString(2, cMesAnoCalc)
    oStatement:SetString(3, cSemPag)
    oStatement:SetString(4, cScript)

    cAliasRCH := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cAliasRCH)
    (cAliasRCH)->(DbGoTop())

    If (cAliasRCH)->(!Eof())
        While (cAliasRCH)->(!Eof())
            aAdd(aFilRCH, {(cAliasRCH)->RCH_FILIAL, (cAliasRCH)->RCH_DTFECH, (cAliasRCH)->RA_FILIAL, RCH_PER})
            (cAliasRCH)->(DbSkip())
        EndDo
    EndIf

    (cAliasRCH)->(DbCloseArea())
    RestArea(aArea)

Return aFilRCH


/*/{Protheus.doc} fLoadCSV
    Load information from CSV file

    @type Static Function
    @param cPath, Character, Path to file.
    @param aDissInf, Array, Array of payment for calculation.
    @author vselyakov
    @since 16.02.2024
    @version 12.1.2310
    @return Logical, Result of operation.
    @example fLoadCSV(cArqInf, @aDissInf)
/*/
Static Function fLoadCSV(cPath, aDissInf)
    Local aArea := GetArea() As Array
    Local aAreaSRA := SRA->(GetArea()) As Array
    Local aErrors := {} As Array
    Local aData := {} As Array
    Local cLine := "" As Character
    Local cFilAux := "" As Character
    Local cPdFGTS := fGetCodFol("0018") + "/" + fGetCodFol("0109") As Character
    Local cPdINSS := fGetCodFol("0013") + "/" + fGetCodFol("0019") + "/" + fGetCodFol("0064") + "/" + fGetCodFol("0065") + "/" + fGetCodFol("0070") As Character
    Local cPeriodFrom := SubStr(MV_PAR05, 3, 4) + SubStr(MV_PAR05, 1, 2) As Character
    Local cPeriodTo := SubStr(MV_PAR06, 3, 4) + SubStr(MV_PAR06, 1, 2) As Character
    Local nHandle := 0 As Numeric
    Local nLine := 0 As Numeric
    Local nX := 0 As Numeric
    Local nPos := 0 As Numeric
    Local lPrevSearch := .F. As Logical

    Begin Sequence

        If File(cPath)
            nHandle := FT_FUse(cPath)

            // If there is an opening error, processing is abandoned.
            If nHandle = -1
                aAdd(aErrors, STR0182) // "Failed to open file".
                Break
            EndIf

            FT_FGoTop()

            While !FT_FEOF()
                cLine := FT_FReadLn() // Returns the current line.
                nLine++

                If Empty(StrTran(cLine, ";"))
                    aAdd(aErrors, STR0183 + AllTrim(Str(nLine)) + " - " + cLine) // "Invalid string."
                    Loop
                EndIf

                aAdd(aData, StrTokArr2(cLine, ";"))
                FT_FSKIP()
            EndDo

            // Close the File.
            FT_FUSE()

            lPrevSearch := aScan(aDissInf, {|x| x[8] == "X"})> 0 // Performance, will only perform searches if there are previously imported records
            SRA->(DbSetOrder(1)) // "RA_FILIAL+RA_MAT+RA_NOME".

            For nX := 1 To Len(aData)
                cFilAux := Padr(aData[nX, 1], FWGETTAMFILIAL)

                If !SRA->(DbSeek(cFilAux + aData[nX, 2]))
                    aAdd(aErrors, STR0184 + cFilAux + " - " + aData[nX, 2] + " / " + STR0185 + AllTrim(Str(nX))) // "Employee does not exist:", "Page"
                    Loop
                EndIf
                If !SRV->(DbSeek(xFilial("SRV", cFilAux) + aData[nX, 6]))
                    aAdd(aErrors, STR0186 + cFilAux + " - " + aData[nX, 6] + " / " + STR0185 + AllTrim(Str(nX))) // "Not acceptable. budget:", "Page"
                    Loop
                EndIf
                If aData[nX, 4] < cPeriodFrom .or. aData[nX, 4] > cPeriodTo
                    aAdd(aErrors, STR0187 + aData[nX,4] + " / " + STR0185 + AllTrim(Str(nX))) // "The period differs from the calculated one:", "Page"
                    Loop
                EndIf
                If Val(aData[nX, 7]) <= 0
                    aAdd(aErrors, STR0188 + aData[nX, 7] + " / " + STR0185 + AllTrim(Str(nX))) // "The entered value d.b. Above zero:", "Page"
                    Loop
                EndIf

                If aData[nX, 6] $ cPdINSS  // Base INSS and INSS
                    // "You can change the INSS both in the main fund and in the discount fund. The system will not recalculate the amount specified in only one of the funds.", "Page"
                    aAdd(aErrors, STR0190 + " / " + STR0185 + AllTrim(Str(nX)))
                EndIf
                If aData[nX, 6] $ cPdFGTS // FGTS
                    // "Changes in the insurance premium fund will not affect the recalculation.", "Page"
                    aAdd(aErrors, STR0193 + " / " + STR0185 + AllTrim(Str(nX))) 
                    Loop
                EndIf
                If lPrevSearch .And. (nPos := aScan(aDissInf, {|x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[8] == cFilAux+aData[nX, 2] + aData[nX, 3] + aData[nX, 4] + aData[nX, 5] + aData[nX, 6] + "X"})) > 0
                    aDissInf[nPos, 7] := Val(aData[nX, 7])
                Else
                    aAdd(aDissInf, {cFilAux, aData[nX, 2], aData[nX, 3], aData[nX, 4], aData[nX, 5], aData[nX, 6], Val(aData[nX, 7]), "X", CToD("//")})
                EndIf

            Next nX
        EndIf

    End Sequence

    If !Empty(aErrors)
        aAdd(aErrProc[1], STR0189 + cPath) // "Amount File Log:".
        aAdd(aErrProc[2], aErrors)
    EndIf

    RestArea(aAreaSRA)
    RestArea(aArea)
Return Nil

/*/{Protheus.doc} ChangeNew
    Function to open another companies SX2.

    @type Static Function
    @param aAliasNewCompany, Array, Array of table
    @param cCompany, Character, Comapny code
    @param cBranch, Character, Filial
    @author vselyakov
    @since 16.02.2024
    @version 12.1.2310
    @return Logical, Result of operation.
    @example ChangeNew({"SRA", "RGB", "SRK", "RFC", "SR3", "SR7", "SRJ", "SQ3", "SRV"}, aDados[4], aDados[1])
/*/
Static Function ChangeNew(aAliasNewCompany, cCompany, cBranch)
    Local nX := 0 As Numeric
    Local cModo := "" As Character
    Local cAlias := "" As Character

    fOpenSx2(cCompany)
    FWClearXFilialCache()

    For nX := 1 To Len(aAliasNewCompany)
        cAlias := aAliasNewCompany[nX]
        UniqueKey(Nil, cAlias, .T.)
        EmpOpenFile(cAlias, cAlias, 1, .T., cCompany, @cModo)
    Next nX

Return .T.


/*/{Protheus.doc} fOpenSx2
    Function to open another companies SX2.

    @type Static Function
    @param cCompany, Character, Comapny code
    @author vselyakov
    @since 16.02.2024
    @version 12.1.2310
    @return Logical, Result of operation.
    @example fOpenSx2(cEmp)
/*/
Static Function fOpenSx2(cCompany)
    Local lOk := .T. As Logical

    SX2->(DBCloseArea())
    OpenSXS(,,,, cCompany, "SX2", "SX2", , .F.)
    
    If Select("SX2") == 0
        lOk := .F.
    Endif

Return lOk


/*
*    WRITE DATA AFTER RETROCALCULATION.
*/

/*{Protheus.doc} RU07D11014_WriteRetroResults()
    Function for recording the results obtained during recalculation.

    Here will be function analog GravaDissidio (from GPEXUSUA).
    Using into GPEXINI.PRX in function 'GravaCalc()'.

    @type Function
    @author vselyakov
    @since 06.02.2024
    @version 12.1.2310
*/
Function RU07D11014_WriteRetroResults(aVerbas, aPdOld, aPercDis, aCodFol)
    Local aArea := GetArea() As Array
    Local aSRAArea := SRA->(GetArea()) As Array
    Local aF5IArea := F5I->(GetArea()) As Array
    Local aSRVArea := SRV->(GetArea()) As Array
    Local aVerbasLanc := {} As Array
    Local aPerAberto := {} As Array
    Local aPerFechado := {} As Array
    Local nI := 0 As Numeric
    Local nPosPD := 0 As Numeric
    Local nSvRec := 0 As Numeric
    Local cChave := "" As Character
    Local cVbPrvAdc := "" As Character
    Local cVbBasAdc := "" As Character
    Local cCodDif := "" As Character
    Local cIndComp := "" As Character
    Local lRet := .T. As Logical
    Local lAppend := .T. As Logical
    Local lSrvRRA := .F. As Logical
    Local lTemRRA := .F. As Logical
    Local cAliasDis := "F5I" // Treatment of the existence of the New Permanent Dissidiation Table (F5I)
    Local nBsInssDis := 0.00 As Numeric
    Local cAnoMesDis := "" As Character
    Local nPosDed := 0 As Numeric
    Local nPos1 := 0 As Numeric
    Local nPos2 := 0 As Numeric
    Local nPos3 := 0 As Numeric
    Local nPos4 := 0 As Numeric
    Local nPos5 := 0 As Numeric
    Local nValOrig := 0.00 As Numeric
    Local cTpContr := Iif(SRA->RA_TPCONTR $ "12", SRA->RA_TPCONTR, "1") As Character // Var to control the type of employee contract.
    Local cPer := GetPeriodCalc() As Character
    Local cLimpa := "" As Character
    Local lPagDifs := .F. As Logical
    Local lTemVb13Mat := (Len(aCodFol) >= 1447) As Logical
    Local nTamCC := GetSx3Cache("F5I_CC", "X3_TAMANHO") As Numeric
    Local nTamIt := GetSx3Cache("F5I_ITEM", "X3_TAMANHO") As Numeric
    Local nTamCl := GetSx3Cache("F5I_CLVL", "X3_TAMANHO") As Numeric
    Local cPdFMs := "" As Character
    Local lAux := .F. As Logical
    Local lValInfo := F5I->(ColumnPos("F5I_VALINF")) > 0
    Local nPosOld := 0 As Numeric
    Local nPosPdOld := 0 As Numeric
    Local nPosAux := 0 As Numeric
    Local aPdOld2 := {} As Array
    Local nPos6 := 0 As Numeric
    Local uRet
    Local lItemClVl := GetMvRH("MV_ITMCLVL", .F., "2") $ "1*3" As Logical // Item and Value Class are used.
    Local lCanContinue := .T. As Logical
    Local nIndexOldPd := 0 As Numeric
    Local aNotFoundPayments := {} As Array // Payments from aPdOld what do not found into aVerbas. It is only discount.

    Private aInssEmpAM As Array
    Private aGPSPer As Array

    If (Type("cSituacao") # "U" .And. !(SRA->RA_SITFOLH $ cSituacao))
        lCanContinue := .F.
    EndIf

    If aPercDis <> Nil
        If aScan(aPercDis, {|x| x[1] == SRA->RA_FILIAL + SRA->RA_MAT + cPer}) == 0
            lCanContinue := .F.
        EndIf
        
        If lCanContinue
            // Defines the Year and Month of the collective bargaining agreement calculation.
            cAnoMesDis := SubStr(aPercDis[1,1], Len(SRA->RA_FILIAL + SRA->RA_MAT) + 1, Len(aPercDis[1, 1]))
        EndIf
    Else
        If !HMGet(oPercDif, SRA->RA_FILIAL + SRA->RA_MAT + cPer, uRet)
            lCanContinue := .F.
        EndIf
        
        If lCanContinue
            // Defines the Year and Month of the collective bargaining agreement calculation.
            cAnoMesDis := SubStr(uRet[1], Len(SRA->RA_FILIAL + SRA->RA_MAT) + 1, Len(uRet[1]))
        EndIf
    EndIf

    If lCanContinue
        // Search payments from aPdOld what not found into aVerbas. This payments only discount.
        For nI := 1 To Len(aPdOld)
            If aScan(aVerbas, {|x| x[1] == aPdOld[nI, 1]}) <= 0
                aAdd(aNotFoundPayments, aClone(aPdOld[nI]))
            EndIf
        Next nI

        // Retrieves third-party percentages stored in parameter 15.
        fGPSVal(SRA->RA_FILIAL, "999999", @aGPSPer, cTpContr)

        // Load Inss of the Month/Year into calculation.
        fInssEmp(SRA->RA_FILIAL, @aInssEmpAM,, cAnoMesDis)

        // Adds the Month/Year Inss Base in calculation.
        aEval(aPdOld, {|x| nBsInssDis += If(X[1] $ aCodFol[13,1] + "/" + aCodFol[14,1] + "/" + aCodFol[19,1] + "/" + aCodFol[20,1], x[5], 0.00)})

        // Check the vacation days in the calculation.
        nDiasMes := nDiasMse := 0
        aEval(aPdOld, {|x| If(x[1] == aCodFol[72,1], nDiasMes := Max(nDiasMes, x[4]), Nil)})
        aEval(aPdOld, {|x| If(x[1] == aCodFol[73,1], nDiasMse := Max(nDiasMse, x[4]), Nil)})

        If nDiasMes + nDiasMse == 0
            aEval(aPdOld, { |x| If(x[1] == aCodFol[75,1], nDiasMes := Max(nDiasMes, x[4]), Nil)})
            aEval(aPdOld, { |x| If(x[1] == aCodFol[76,1], nDiasMse := Max(nDiasMse, x[4]), Nil)})
        EndIf
        aEval(aPdOld, {|x| If(x[1] == aCodFol[205,1], nDAbMse := Max(nDAbMse, x[4]), Nil)})

        // Calculate Company Inss at the time of actual payment to determine the difference - Only MV_ENCINSS equals 'N'.
        lTemRRA := Type(cIdCmpl) # "U" .And. !Empty(cIdCmpl)

        If !LDISSFER11
            fSomaDifs(@aPdOld, SRA->RA_FILIAL)
        EndIf

        // If it is 132, look for 13th supplementary funds paid on payroll.
        If cTipoRot == "6"
            fRetPerComp(SubStr(cPer,5,2), SubStr(cPer,1,4), Nil, Nil, fGetRotOrdinar(), @aPerAberto, @aPerFechado)
            aVerbasLanc := RetornaVerbasFunc(SRA->RA_FILIAL,SRA->RA_MAT,NIL,fGetRotOrdinar(),,aPerAberto,aPerFechado,,"RV_REF13=='S'")
            For nPos1 := 1 to Len(aVerbasLanc)
                If aVerbasLanc[nPos1,3] == aCodFol[348,1] // Negative mean difference.
                    lPagDifs := .T.
                ElseIf aVerbasLanc[nPos1,3] == aCodFol[28,1] // Positive mean difference.
                    lPagDifs := .T.
                    aPdOld2 := aClone(aPd)
                    aPd := {}
                    
                    // Only records the 13th difference amount in the aPD to calculate the charges.
                    FMatriz(aVerbasLanc[nPos1,3],aVerbasLanc[nPos1,7]) 
                    
                    // Generates INSS 13th Base funds.
                    FCINSS13(ACODFOL,IF(CTIPOROT $ "5*6",ATINSS13,ATINSS),,NINSSP,NBATLIM,NBACLIM)
                    
                    // Mark funds that are not salary contributions as deleted.
                    aEval(aPd,{|x| x[9] := IF(x[1] $ AcodFol[19,1]+"/"+aCodFol[20,1], " ", "D") } ) 
                    
                    // Calculates charges.
                    fCalcInssFun()
                    
                    // Deletes contribution salary funds.
                    aEval(aPd, {|x| x[9] := IF(x[1] $ AcodFol[19,1]+"/"+aCodFol[20,1], "D", x[9]) } )
                    
                    // Add the value corresponding to the 13th to the original value.
                    For nPos6 := 1 to Len(aPd)
                        aEval(aPdOld,{|x| x[5] += If(x[1] == aPd[nPos6,1] .And. aPd[nPos6,9] # "D", aPd[nPos6,5], 0.00)} ) 
                    Next nPos6 
                    
                    // Returns the original Apd content.
                    aPd 	:= aClone( aPdOld2 )
                // It is necessary to incorporate the complement values as 132 is recalculated based on the final value of December (including the difference).
                ElseIf ( nPos := aScan(aPdOld,{|x| x[1] $ aVerbasLanc[nPos1,3] }) ) > 0
                    aPdOld[nPos,5] += aVerbasLanc[nPos1,7]
                EndIf
            Next nPos1

            If lPagDifs
                If lTemVb13Mat .And. ( nPos := aScan(aPdOld, {|x| x[1] $ aCodFol[1436,1]}) ) > 0 // Total Means in Maternity Value.
                    aPdOld[nPos,5] := nOrigVlMat
                EndIf
                
                If lTemVb13Mat .And. ( nPos := aScan(aPdOld, {|x| x[1] $ aCodFol[1437,1]}) ) > 0 // Total Averages in Maternity Hours.
                    aPdOld[nPos,5] := nOrigHrMat
                EndIf

                If ( nPos := aScan(aPdOld, {|x| x[1] $ aCodFol[123,1]}) ) > 0 // Total Averages in Value.
                    aPdOld[nPos,5] := nOrigVal
                EndIf

                If ( nPos := aScan(aPdOld, {|x| x[1] $ aCodFol[124,1]}) ) > 0 // Total Averages in Hours.
                    aPdOld[nPos,5] := nOrigHor - If(nOrigHrMat > 0, nOrigHrMat, 0)
                EndIf
            EndIf
        EndIf

        // If it is FOL and has a Dif of 132, look for the 13th difference amount paid on the payroll.
        If cTipoRot == "1"
            If (nPosPD := aScan(aPd, {|x| x[1] == aCodFol[28,1]})) > 0 .And. (nPosOld := aScan(aPdOld, {|x| x[1] == aCodFol[28,1]})) > 0 // Positive mean difference.
                // The INSS and FGTS 13th paid on payroll should not change as the entire calculation was done in script 132.
                cLimpa := aCodFol[108,1] +'*'+ aCodFol[109,1] +'*'+ aCodFol[19,1] +'*'+ aCodFol[20,1] +'*'+ aCodFol[70,1]
                For nPosPd := 1 to Len(aPd)
                    If aPd[nPosPd,1] $ cLimpa
                        aPd[nPosPd,5] := 0
                        If(nPos := aScan(aPdOld, {|x| x[1] == aPd[nPosPd,1] .and. x[9] <> 'D'})) > 0
                            aPd[nPosPd,5] := aPdOld[nPos,5]
                        EndIf
                    EndIf
                Next nPosPd
            EndIf
        EndIf

        cPdFMs := aCodFol[89,1] + "*" + aCodFol[91,1] + "*" + aCodFol[93,1] + "*" + aCodFol[97,1] + "*" + ;
                    aCodFol[99,1] + "*" + aCodFol[162,1] + "*" + aCodFol[207,1] + "*" + aCodFol[208,1] + "*" + ;
                    aCodFol[73,1] + "*" + aCodFol[78,1] + "*" + aCodFol[232,1] + "*" + aCodFol[76,1] + "*" + ;
                    aCodFol[83,1] + "*" + aCodFol[81,1] + "*" + aCodFol[93,1] + "*" + aCodFol[205,1] + "*" + ;
                    aCodFol[206,1] + "*" + aCodFol[207,1] + "*" + aCodFol[208,1] + "*" + aCodFol[633,1] + "*" + ;
                    aCodFol[634,1] + "*" + aCodFol[1331,1] + "*" + aCodFol[1405,1] + "*" + aCodFol[1406,1] + "*" + ;
                    aCodFol[1409,1] + "*" + aCodFol[1410,1] + "*" + aCodFol[1418,1] + "*"  +  aCodFol[1419,1]

        // Treatment for unhealthy conditions, but other additional items must be included in due course.
        cVbBasAdc := aCodFol[672,1]
        cVbPrvAdc := aCodFol[37,1] + "*" + aCodFol[38,1] + "*" + aCodFol[39,1] + "*" + aCodFol[1282,1] + "*"

        // If you had the holiday INSS and payroll INSS funds in the accrual, if there is a situation where the holiday INSS reaches the ceiling, 
        // it generates the payroll INSS amount with a zero value to compensate for the vacation adjustment.
        If ( nPos1 := aScan(aPdOld, {|x| x[1] == aCodFol[65,1]} ) ) > 0 .And. ( nPos2 := aScan(aPdOld, {|x| x[1] == aCodFol[64,1]} ) ) > 0 .And. ( nPos3 := aScan(aVerbas, {|x| x[1] == aCodFol[65,1]} ) ) > 0
            If ( nPos4 := aScan(aVerbas, {|x| x[1] == aCodFol[64,1]} ) ) == 0
                aAdd( aVerbas, aClone(aVerbas[nPos3]) )
                aVerbas[Len(aVerbas), 1] := aCodFol[64,1]
                aVerbas[Len(aVerbas), 5] := 0.00
                lAux := .T.
            ElseIf aVerbas[nPos4, 9] == "D"
                aVerbas[nPos4, 5] := 0.00
                aVerbas[nPos4, 9] := ""
                lAux := .T.
            ElseIf ( nPos5 := aScan(aPdOld, {|x| x[1] == aCodFol[289,1]} ) ) > 0 .And. ( aPdOld[nPos1, 5] + aPdOld[nPos2, 5] + aPdOld[nPos5, 5] == NoRound(aTInss[Len(aTInss),1] * aTInss[Len(aTInss),2], 2))
                If nPos4 > 0
                    aVerbas[nPos4, 5] := ( aPdOld[nPos1, 5] + aPdOld[nPos2, 5] ) - aVerbas[nPos3, 5]
                EndIf
            EndIf
            If lAux
                aVerbas[nPos3, 5] := aPdOld[nPos1, 5] + aPdOld[nPos2, 5]
            EndIf
        // If you only had INSS on vacation with ceiling payment and MULTV, do not readjust the amount of the amount so as not to generate a difference.
        ElseIf ( nPos1 := aScan(aPdOld, {|x| x[1] == aCodFol[65,1]} ) ) > 0 .And. aScan(aPdOld, {|x| x[1] == aCodFol[64,1]} ) == 0 .And. ( nPos2 := aScan(aPdOld, {|x| x[1] == aCodFol[289,1]} ) ) > 0 .And. (aPdOld[nPos1, 5] + aPdOld[nPos2, 5] == NoRound(aTInss[Len(aTInss),1] * aTInss[Len(aTInss),2], 2) )
            If ( nPos2 := aScan(aVerbas, {|x| x[1] == aCodFol[65,1]} ) ) > 0
                aVerbas[nPos2, 5] := aPdOld[nPos1, 5]
            EndIf
        EndIf

        nPosPd := 0 // reset so as not to delete the aPdOld position before saving the funds in F5I.
        nPosPdOld := 0

        For nI := 1 To Len(aVerbas)

            If aVerbas[nI, 7] == "R" .Or. If(!(Type("lUtiMultiV") <> "U" .And. lUtiMultiV), aVerbas[nI, 9] == "D", .F.)
                Loop
            EndIf

            SRV->(DbSeek(FwxFilial("SRV", SRA->RA_FILIAL) + aVerbas[nI, 1]))
            nSvRec := SRV->(Recno())

            If nPosPd <> 0
                If aPdOld[nPosPd, 1] == aCodFol[123, 1]
                    nOrigVal := 0 // In cases of apportionment, it is necessary to clear the average value so as not to generate 2 releases with the same origin value, generating a negative difference.
                ElseIf aPdOld[nPosPd, 1] == aCodFol[124, 1]
                    nOrigHor := 0
                ElseIf lTemVb13Mat .And. aPdOld[nPosPd, 1] == aCodFol[1436, 1]
                    nOrigVlMat := 0
                ElseIf lTemVb13Mat .And. aPdOld[nPosPd, 1] == aCodFol[1437, 1]
                    nOrigHrMat := 0
                EndIf

                aDel(aPdOld, nPosPd)
                aSize(aPdOld, Len(aPdOld) - 1)
            EndIf

            nPosPD := aScan(aPdOld, {|X| X[1] == SRV->RV_COD .And. X[3] = aVerbas[nI, 3] .And. X[2] = aVerbas[nI, 2] .And. Iif(lItemClVl, X[13] = aVerbas[nI, 13] .And. X[14] = aVerbas[nI, 14], X[11] = aVerbas[nI, 11])})
            If nPosPD == 0
                nPosPD := Ascan(aPdOld,{|X| X[1] == SRV->RV_COD .And. X[3] = aVerbas[nI, 3] .And. X[11] = aVerbas[nI, 11]})
            EndIf
            If nPosPD == 0
                nPosPD := Ascan(aPdOld,{|X| X[1] == SRV->RV_COD .And. X[3] = aVerbas[nI, 3] .And. X[2] = aVerbas[nI, 2]})
            EndIf
            If nPosPD == 0
                nPosPD := Ascan(aPdOld,{|X| X[1] == SRV->RV_COD .And. X[3] = aVerbas[nI, 3]})
            EndIf

            If SRV->RV_INSS == "S" .OR. SRV->RV_FGTS == "S" .OR. SRV->RV_COMPL_ == "S" .Or. SRV->RV_CODFOL $ "1412"
                cCodDif := SRV->RV_RETROAP

                // Checks whether the destination budget code has FGTS/INSS incidence. If so, it generates an inconsistency log.
                SRV->(DbSeek(FwxFilial("SRV", SRA->RA_FILIAL) + cCodDif))

                If lTemRRA
                    lSrvRRA := SRV->RV_RRA == "1"
                EndIf

                If SRV->RV_INSS == "S" .Or. SRV->RV_FGTS == "S"
                    If aTotRegs[1] # 0                                                                                         '
                        If len(aLog) >= aTotRegs[1]
                            nPos := (Ascan( aLog[aTotRegs[1]],SRV->RV_COD))
                        Else
                            nPos := 0
                        EndIf
                    Else
                        nPos := 0
                    EndIf

                    If nPos == 0
                        If aTotRegs[1] == 0 .Or. Len(aLog) == 0
                            cLog := STR0024 // "Destination funds are subject to FGTS/INSS".
                            aAdd(aTitle,cLog)
                            aAdd(aLog,{})
                            aTotRegs[1] := Len(aLog)
                        EndIf

                        aAdd(aLog[aTotRegs[1]], SRV->RV_COD + " - " + SRV->RV_DESC)
                    EndIf

                    lRet := .F.
                EndIf

                // TEST ELEMENT 9 IF IT IS DELETED.
                If (Iif(!(Type("lUtiMultiV")<> "U" .And. lUtiMultiV), aVerbas[nI,9] # "D", .T.)) .And. aVerbas[nI,3] == cSemana
                    cIndComp := If(Empty(aVerbas[nI, 2]), Space(nTamCc), aVerbas[nI, 2])
                    cIndComp += If(Empty(aVerbas[nI, 13]), Space(nTamIt), aVerbas[nI, 13])
                    cIndComp += If(Empty(aVerbas[nI, 14]), Space(nTamCl), aVerbas[nI, 14])

                    // Records the amounts with calculated differences.
                    SRV->(DbGoTo(nSvRec))

                    DbSelectArea(cAliasDis)
                    (cAliasDis)->(DbSetOrder(1)) // "F5I_FILIAL+F5I_MAT+F5I_MESANO+F5I_DATA+F5I_VB+F5I_CC+F5I_ITEM+F5I_CLVL+F5I_SEMANA+F5I_SEQ+F5I_ROTEIR".

                    // Tests the existence of the launch in the dispute table before inclusion, as in the cases of IRMULTV the budget is already may exist and must be re-recorded.
                    // Check if there are multiple links.
                    cChave := (SRA->(RA_FILIAL + RA_MAT) + cMesAnoCalc + cPer + SRV->RV_COD + cIndComp + cSemPag + aVerbas[nI,11] + cRotOrig)

                    If (cAliasDis)->(DbSeek(cChave))
                        lAppend := !Found()

                        // If a Sequence exists in the TRB/F5I table, it tests whether the corresponding record also exists so as not to add one more.
                        IF !lAppend .and. FieldPos( (cAliasDis)+"_SEQ" ) # 0
                            While (cAliasDis)->(!Eof()) .and. ( cChave == (SRA->(RA_FILIAL+RA_MAT)+cMesAnoCalc+cPer+(cAliasDis)->&((cAliasDis)+"_VB")+cIndComp+cSemPag+alltrim(Str(val(csemana)))))
                                IF (cAliasDis)->&((cAliasDis)+"_SEQ") == aVerbas[nI,11]
                                    lAppend := .F.
                                    Exit
                                Else
                                    lAppend := .T.
                                EndIf
                                (cAliasDis)->(DbSkip())
                            End While
                        EndIf
                        RecLock( cAliasDis, lAppend, .T. )

                        If Type("lUtiMultiV")<> "U" .And. lUtiMultiV .And. aVerbas[nI,9] == "D"
                            (cAliasDis)->(DbDelete())
                            (cAliasDis)->(MsUnlock())
                            Loop
                        EndIf
                    Else
                        If Type("lUtiMultiV")<> "U" .And. lUtiMultiV .And. aVerbas[nI,9] == "D"
                            Loop
                        EndIf

                        RecLock(cAliasDis, .T., .T.)
                    EndIf

                    (cAliasDis)->&((cAliasDis) + "_FILIAL") := SRA->RA_FILIAL
                    (cAliasDis)->&((cAliasDis) + "_MAT") := SRA->RA_MAT
                    (cAliasDis)->&((cAliasDis) + "_VB") := SRV->RV_COD // Original payment.
                    (cAliasDis)->&((cAliasDis) + "_CC") := aVerbas[nI, 2]
                    (cAliasDis)->&((cAliasDis) + "_DATA") := cPeriodo // Year/Month(dDataBase).

                    // Destination budget.
                    If Empty(SRV->RV_RETROAP) .And. !(SRV->RV_CODFOL $ "0072/0074/0077/0079/0084/1412")
                        If aTotRegs[2] # 0
                            If len(aLog) >= aTotRegs[2]
                                nPos := (aScan(aLog[aTotRegs[2]],SRV->RV_COD))
                            Else
                                nPos := 0
                            EndIf
                        Else
                            nPos := 0
                        EndIf

                        If nPos == 0
                            If aTotRegs[2] == 0 .or. Len(aLog) < aTotRegs[2]
                                cLog := STR0025 // "Destination budget was not informed".
                                aAdd(aTitle, cLog)
                                aAdd(aLog, {})
                                aTotRegs[2] := Len(aLog)
                            EndIf

                            aAdd(aLog[aTotRegs[2]], SRV->RV_COD + " - " + SRV->RV_DESC)
                        EndIf
                    Else
                        (cAliasDis)->&((cAliasDis) + "_VERBA") := SRV->RV_RETROAP
                    EndIf

                    // Calculates the original value when MV_ENCINSS equals N.
                    nValOrig := 0.00 // Original Value for Charges.
                    nPosDed := 0 // Job Position.

                    // If this condition is entered, it indicates that there were holidays in the month of the dispute to be recorded.
                    If nDiasMes > 0 .And. (nDiasMse + nDAbMse) > 0
                        If lDissFer11
                        // There was payment in the Month/Year of the Dispute to be Recorded.
                            If nPosPD > 0
                                (cAliasDis)->&((cAliasDis)+"_VL") := aPdOld[nPosPD, 5]

                            // Check whether the amount refers to Holiday IDs.
                            ElseIf aVerbas[nI,1] $ 	aCodFol[89,1]+'*'+aCodFol[91,1]+'*'+aCodFol[93,1]+'*'+aCodFol[97,1]+'*'+;
                                                    aCodFol[99,1]+'*'+aCodFol[162,1]+'*'+aCodFol[207,1]+'*'+aCodFol[208,1]+'*'+aCodFol[839,1]+'*'+aCodFol[1451,1]+'*'+aCodFol[1418,1]+'*'+aCodFol[1419,1]
                                (cAliasDis)->&((cAliasDis)+"_VL") := aVerbas[nI,5]

                            // If PosTed is greater than 1, it indicates that it is the amount of Charges in the Month of the Dissidio to be recorded in the same month as the Holidays.
                            // If PosTed has ZERO it indicates that MV_ENCINSS is equal to "S" or that there is no Charges amount in the same month as Holidays.
                            ElseIf nPosDed > 0
                                (cAliasDis)->&((cAliasDis)+"_VL") := nValOrig

                            Else
                                (cAliasDis)->&((cAliasDis)+"_VL") := 0.00 // Writes Zeros if it does not meet any of the above conditions.
                            EndIf
                        Else
                            // There was payment in the Month/Year of the Dispute to be Recorded.
                            If nPosPD > 0 .And. !(aVerbas[nI,1] $ cPdFMs)
                                (cAliasDis)->&((cAliasDis)+"_VL") += aPdOld[nPosPD, 5]

                            // Check whether the amount refers to Holiday IDs.
                            ElseIf aVerbas[nI,1] $ cPdFMs
                                (cAliasDis)->&((cAliasDis)+"_VL") += aVerbas[nI, 5]

                            // If PosTed is greater than 1, it indicates that it is the amount of Charges in the Month of the Dissidio to be recorded in the same month as the Holidays.
                            // If PosTed has ZERO it indicates that MV_ENCINSS is equal to "S" or that there is no Charges amount in the same month as Holidays.
                            ElseIf nPosDed > 0
                                (cAliasDis)->&((cAliasDis)+"_VL") := nValOrig

                            Else
                                If aVerbas[nI,1] $ (aCodFol[88,1]+'*'+aCodFol[90,1]+'*'+aCodFol[92,1]+'*'+aCodFol[96,1]+'*'+;
                                                    aCodFol[98,1]+'*'+aCodFol[161,1]+'*'+aCodFol[94,1]+'*'+aCodFol[95,1]+'*'+;
                                                    aCodFol[72,1]+'*'+aCodFol[77,1])
                                    (cAliasDis)->&((cAliasDis)+"_VL") := aVerbas[nI, 19]
                                Else
                                    (cAliasDis)->&((cAliasDis)+"_VL") := 0.00 // Writes Zeros if it does not meet any of the above conditions.
                                EndIf
                            EndIf
                        EndIf
                    Else
                        (cAliasDis)->&((cAliasDis) + "_VL") := If(nPosPD > 0, aPdOld[nPosPD, 5], 0)
                    EndIf

                    // Handles the return of the Holiday Inss that was generated on the sheet (Id 1412).
                    // Add to the updated Inss the amount that was returned to the employee.
                    If (cAliasDis)->&((cAliasDis) + "_VB") == aCodFol[64,1]
                        If( Len(aCodFol) >= 1412 .And. !Empty(aCodFol[1412,1]) )
                            nPosPdOld := nPosPD
                            nPosPD := Ascan( aPdOld,{|X| X[1] == aCodFol[1412,1] })
                            If nPosPD > 0
                                aVerbas[nI,5] += aPdOld[nPosPD,5]
                            EndIf
                            nPosPD := nPosPdOld
                        EndIf
                    EndIf

                    If lAppend
                        (cAliasDis)->&((cAliasDis) + "_CALC") := aVerbas[nI, 5] // Calculated Value.
                    Else
                        (cAliasDis)->&((cAliasDis) + "_CALC") += aVerbas[nI, 5] // Calculated Value.
                    EndIf
                    
                    (cAliasDis)->&((cAliasDis) + "_VALOR") := (cAliasDis)->&((cAliasDis) + "_CALC") - (cAliasDis)->&((cAliasDis) + "_VL") // Difference

                    If ((cAliasDis)->&((cAliasDis) + "_VALOR") < 0)
                        (cAliasDis)->&((cAliasDis) + "_VERBA") := SRV->RV_RETROAD
                    EndIf

                    If !Empty(SRV->RV_RETROAP) .and. SRV->RV_COMPL_ == "S"
                        (cAliasDis)->&((cAliasDis) + "_COMPL_") := "S"
                    Else
                        (cAliasDis)->&((cAliasDis) + "_COMPL_") := "N"
                    EndIf

                    (cAliasDis)->&((cAliasDis) + "_SEMANA") := cSemPag
                    (cAliasDis)->&((cAliasDis) + "_MESANO") := cMesAnoCalc
                    (cAliasDis)->&((cAliasDis) + "_TIPO1") := aVerbas[nI, 6]
                    (cAliasDis)->&((cAliasDis) + "_TIPO2") := aVerbas[nI, 7]

                    // Calculate difference between old days/hours and new days/hours.
                    nIndexOldPd := aScan(aPdOld, {|x| x[1] == aVerbas[nI, 1]})

                    If nIndexOldPd > 0 .And. SRV->RV_CODFOL # "0066"
                        (cAliasDis)->&((cAliasDis) + "_HORAS") := Abs(aPdOld[aScan(aPdOld, {|x| x[1] == aVerbas[nI, 1]}), 4] - aVerbas[nI, 4])
                    Else
                        (cAliasDis)->&((cAliasDis) + "_HORAS") := aVerbas[nI, 4]
                    EndIf

                    (cAliasDis)->&((cAliasDis) + "_SEQ") := aVerbas[nI, 11]
                    (cAliasDis)->&((cAliasDis) + "_DTPGT") := aVerbas[nI, 10]

                    If lTemRRA
                        (cAliasDis)->&((cAliasDis) + "_IDCMPL") := cIdCmpl
                        // If the month and year of payment is different from the month and year of the reference, RRA must be generated
                        If SubStr(cPer, 1, 4) < SubStr(cMesAnoCalc, 1, 4) .and. lSrvRRA
                            (cAliasDis)->&((cAliasDis) + "_RRA") := "1"
                        Else
                            (cAliasDis)->&((cAliasDis) + "_RRA") := "0"
                        EndIf
                    EndIf

                    (cAliasDis)->&((cAliasDis) + "_PROCES") := cProcesso
                    (cAliasDis)->&((cAliasDis) + "_ROTEIR") := cRotOrig
                    (cAliasDis)->&((cAliasDis) + "_ITEM") := aVerbas[nI, 13]
                    (cAliasDis)->&((cAliasDis) + "_CLVL") := aVerbas[nI, 14]
                    
                    If lValInfo
                        If Len(aDissInf) > 0 .and. ( nPosAux := aScan( aDissInf, { | X | SRA->RA_FILIAL + SRA->RA_MAT + cRotOrig + cPer + cSemPag + SRV->RV_COD  == X[1] + X[2] + X[3] + X[4] + X[5] + X[6] } ) ) > 0
                            (cAliasDis)->&((cAliasDis) + "_VALINF") := aDissInf[nPosAux,7]
                            (cAliasDis)->&((cAliasDis) + "_TIPO3")  := aDissInf[nPosAux,8]
                        Else
                            (cAliasDis)->&((cAliasDis) + "_TIPO3") := "C"
                        EndIf
                    EndIf

                    // P.E. to change information in the recording of the dispute file (TRB/RHH)
                    // If ExistBlock( "GP020VBDI" )
                    // 	ExecBlock( "GP020VBDI" ,.F.,.F. )
                    // EndIf

                    (cAliasDis)->(MsUnlock())

                EndIf
            EndIf
        Next
    EndIf

    For nI := 1 To Len(aNotFoundPayments)
        If !F5IInsert(aNotFoundPayments[nI])
            ConOut("Error on wrtie aNotFoundPayments: " + AllTrim(Str(nI)))
        EndIf
    Next nI

    aVerbas	:= {}
    aPdOld	:= {}

    SRV->(RestArea(aSRVArea))
    F5I->(RestArea(aSRAArea))
    SRA->(RestArea(aF5IArea))
    RestArea(aArea)

Return lRet


/*
*    DELETE DATA.
*/

/*{Protheus.doc} RU07D11015_DeleteData()
    Function for delete data of previous calculations from F5I.
    Update from 19.03.2024 - delete integrated data from RGB also.

    @type Function
    @author vselyakov
    @since 31.01.2024
    @version 12.1.2310
*/
Function RU07D11015_DeleteData()
    Local lResult := .T. As Logical
    
    If !lAuto
        TNewProcess():New("RU07D11", STR0209, {|oSelf| lResult := DeleteData(oSelf)}, STR0210, PERGUNTE_DELETE_DATA, , .T., 20, STR0160, .T., .T.)
    Else
        lResult := DeleteData()
    EndIf

Return


/*{Protheus.doc} DeleteData()
    Function for delete data of previous calculations from F5I.

    @type Static Function
    @author vselyakov
    @since 31.01.2024
    @version 12.1.2310
    @return Logical, Result status of operation.
*/
Static Function DeleteData(oSelf)
    Local aArea := GetArea() As Array
    Local aSRAArea := SRA->(GetArea()) As Array
    Local aF5IArea := F5I->(GetArea()) As Array
    Local cQuery := "" As Character
    Local oStatement := FWPreparedStatement():New() As Object
    Local cAlias := "" As Character
    Local nI := 0 As Numeric
    Local cStatus := "" As Character
    Local cCategory := "" As Character
    Local aSRANumbers := {} As Array
    Local cPeriodStart := "" As Character
    Local cPeriodEnd := "" As Character
    Local aRetroPayments := GetRetroPayments() As Array
    Local aPerActual := {} As Array
    Local lCanContinue := .T. As Logical
    Local cLog := "" As Character
    Local aTDCanceled := {} As Array

    Pergunte(PERGUNTE_DELETE_DATA, .F.)
    cPeriodStart := SubStr(MV_PAR01, 3, 4) + SubStr(MV_PAR01, 1, 2) // MV_PAR01
    cPeriodEnd := SubStr(MV_PAR02, 3, 4) + SubStr(MV_PAR02, 1, 2) // MV_PAR02

    MakeSQLExpr(PERGUNTE_DELETE_DATA)

    // Get SRA lines by filter.
    cQuery := " SELECT RA_FILIAL, RA_MAT, RA_PROCES, RA_NOMECMP FROM " + RetSqlName("SRA") + " WHERE "
    cQuery += "     D_E_L_E_T_ = ' ' "

    // RA_FILIAL.
    If !Empty(MV_PAR03)
        cQuery += " AND " + MV_PAR03
    EndIf

    // RA_CC.
    If !Empty(MV_PAR04)
        cQuery += " AND " + MV_PAR04
    EndIf

    // RA_MAT.
    If !Empty(MV_PAR05)
        cQuery += " AND " + MV_PAR05
    EndIf

    // Status processing.
    If !Empty(MV_PAR06)
        For nI := 1 To Len(MV_PAR06)
            If SubStr(MV_PAR06, nI, 1) <> "*"
                cStatus += "'" + SubStr(MV_PAR06, nI, 1) + "',"
            EndIf
        Next nI

        If Len(cStatus) > 1
            cStatus := SubStr(cStatus, 1, Len(cStatus) - 1)
            cQuery += " AND RA_SITFOLH IN (" + cStatus + ") "
        EndIf
    EndIf

    // Category processing.
    If !Empty(MV_PAR07)
        For nI := 1 To Len(MV_PAR07)
            If SubStr(MV_PAR07, nI, 1) <> "*" .And. !Empty(SubStr(MV_PAR07, nI, 1))
                cCategory += "'" + SubStr(MV_PAR07, nI, 1) + "',"
            EndIf
        Next nI

        If Len(cCategory) > 1
            cCategory := SubStr(cCategory, 1, Len(cCategory) - 1)
            cQuery += " AND RA_CATFUNC IN (" + cCategory + ") "
        EndIf
    EndIf

    // Roles. RA_CODFUNC.
    If !Empty(MV_PAR08)
        cQuery += " AND " + MV_PAR08
    EndIf

    // Unions. RA_SINDICA.
    If !Empty(MV_PAR09)
        cQuery += " AND " + MV_PAR009
    EndIf

    oStatement := FWPreparedStatement():New(cQuery)
    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
    
    While !((cAlias)->(Eof()))
        aAdd(aSRANumbers, {(cAlias)->RA_FILIAL, (cAlias)->RA_MAT, (cAlias)->RA_PROCES, (cAlias)->RA_NOMECMP})

        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    // Set maximum for progressBar.
    oSelf:SetRegua1(Len(aSRANumbers))

    Begin Transaction 

    // Delete retrocalculation results by employee.
    For nI := 1 To Len(aSRANumbers)
        // Increment of progressBar.
        oSelf:IncRegua1(STR0138 + ": " + aSRANumbers[nI, 2] + " - " + aSRANumbers[nI, 4]) // "Employee: ".
    
        If !lCanContinue
            Exit
        EndIf

        // Getting current period for employee by process.
        fGetPerAtual(@aPerActual, FwXFilial("RCJ"), aSRANumbers[nI, 3], fGetCalcRot("1"))

        If Empty(aPerActual)
            Help(" ", 1, "GPCALEND", )
            lCanContinue := .F.
            ConOut("RU07D11RUS (DeleteData): When deleting data the current period for the employee is not determined.")
        EndIf

        // Delete datat from RGB.
        If lCanContinue
            cQuery := " DELETE FROM " + RetSqlName("RGB") 
            cQuery += " WHERE                                             "
            cQuery += "     D_E_L_E_T_ = ' '                              "
            cQuery += "     AND RGB_FILIAL = '" + aSRANumbers[nI, 1] + "' "
            cQuery += "     AND RGB_MAT = '" + aSRANumbers[nI, 2] + "'    "
            cQuery += "     AND RGB_PERIOD = '" + aPerActual[1, 1] + "'     "
            cQuery += "     AND RGB_PD IN (?)                             "

            oStatement := FWPreparedStatement():New(cQuery)
            oStatement:SetIn(1, aRetroPayments)

            // Execute SQL-query.
            If TcSqlExec(oStatement:GetFixQuery()) < 0
                lCanContinue := .F.
                ConOut("RU07D11RUS (DeleteData): An error occurred when deleting data from RGB")
            EndIf
        EndIf

        
        // Delete data from F5I.
        If lCanContinue
            cQuery := " DELETE FROM " + RetSqlName("F5I") 
            cQuery += " WHERE                                             "
            cQuery += "         F5I_FILIAL = '" + aSRANumbers[nI, 1] + "' "
            cQuery += "     AND F5I_MAT = '" + aSRANumbers[nI, 2] + "'    "
            cQuery += "     AND F5I_DATA >= '" + cPeriodStart + "'        "
            cQuery += "     AND F5I_DATA <= '" + cPeriodEnd + "'          "
            cQuery += "     AND D_E_L_E_T_ = ' '                          "

            // Execute SQL-query.
            If TcSqlExec(cQuery) < 0
                lCanContinue := .F.
                ConOut("RU07D11RUS (DeleteData): An error occurred when deleting data from F5I")
            EndIf
        EndIf

        // Cancel deduation payments into F5D for retrocalculations.
        aTDCanceled := CancelDeductionPayments(aSRANumbers[nI, 1], aSRANumbers[nI, 2], cPeriodStart, cPeriodEnd)

        // Cancel changes if sql query has error on execution.
        If !lCanContinue
            DisarmTransaction()
            ConOut("RU07D11RUS (DeleteData): Cancel transaction")
        EndIf
    Next nI

    End Transaction

    oStatement:Destroy()
    FwFreeObj(oStatement)

    /*
    *    Show result of process.
    */
    // Show message to user about status of operation.
    If !lAuto
        If lCanContinue
            MsgInfo(STR0211) // Message about end of process "The process of deleting previous calculations is completed".
        Else
            MsgStop(STR0221) // "An error occurred when deleting allocation data. The transaction was canceled".
        EndIf
    Else
        If lCanContinue
            cLog := "Process of removing retrocalculation data is successfully done!"
        Else
            cLog := "An error occurred when deleting allocation data. The transaction was canceled"
        EndIf

        ConOut(cLog)
    EndIf

    // Write log into appserver about process.
    cLog := "RU07D11RUS: Process of removing retrocalculation data " + Iif(lCanContinue, "is successfully", "was not") + " done!"
    ConOut(cLog)

    F5I->(RestArea(aF5IArea))
    SRA->(RestArea(aSRAArea))
    RestArea(aArea)
Return lCanContinue


/*
*    INTEGRATION TO RGB AND ANOTHER TABLES.
*/

/*{Protheus.doc} RU07R11008_IntegrationProcess()
    Function for starting a process integration recalculation data.
    Copy of GP690Grv.

    @type Function
    @author vselyakov
    @since 06.02.2024
    @version 12.1.2310
*/
Function RU07R11008_IntegrationProcess()
    Local aArea := GetArea() As Array
    Local aSRAArea := SRA->(GetArea()) As Array
    Local aFilterExp := {} As Array // Filter Expression.
    Local aInfoCustom := {} As Array
    Local lResultIntegration := .F. As Logical
    Local bProcess := {|oSelf| lResultIntegration := RU07D11009(oSelf)}

    /*
    *    PRIVATE VARIABLES.
    */
    Private aRetFiltro
    Private cSraFilter

    // Create a dialog screen.
    /* Return the Filters that contain the Alias Below */
    aAdd(aFilterExp, {"FILTRO_ALS", "SRA", .T.})

    /* That Are Defined for the Role */
    aAdd(aFilterExp, {"FILTRO_PRG", FunName(), Nil, Nil})

    aAdd(aInfoCustom, {STR0213, {|oCenterPanel| aRetFiltro := FilterBuildExpr(aFilterExp)}, "TK_FIND"}) // "Filter".
    cFilAnt := cFilAnterior

    If !lAuto
        TNewProcess():New(PROGRAM_NAME, STR0213, bProcess, STR0213, PERGUNTE_GENERATION, , .T., 20, STR0213, .T., .T.)
    Else
        RU07D11009()
    EndIf

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return

/*{Protheus.doc} RU07D11009_Integration()
    Function for integration recalculation data.
    Analog of GP690Proc function into GPEM690.

    @type Function
    @author vselyakov
    @since 06.02.2024
    @version 12.1.2310
*/
Function RU07D11009_Integration(oSelf)
    Local aArea := GetArea() As Array
    Local aAreaSR3 := SR3->(GetArea()) As Array
    Local aAreaSR7 := SR7->(GetArea()) As Array
    Local aAreaSRA := SRA->(GetArea()) As Array
    Local aF5IArea := F5I->(GetArea()) As Array
    Local nI := 0 As Numeric
    Local aRetroPd := {} As Array
    Local cFilFrom := "" As Character
    Local cFilTo := "" As Character
    Local cCCFrom := "" As Character
    Local cCCTo := "" As Character
    Local cMatFrom := "" As Character
    Local cMatTo := "" As Character
    Local cKey := "" As Character
    Local aTransfFun := {} As Array
    Local aDados := {} As Array
    Local nX := 0 As Numeric
    Local cF5IKey := "" As Character
    Local cBusca := "" As Character
    Local cNotCods := "" As Character
    Local cAntFil := "" As Character
    Local aCodFol := {} As Array
    Local dDtReaj := CTod("//") As Date
    Local dTransf := CToD("//") As Date
    Local nFirstRec := 0 As Numeric
    Local nValAnt := 0 As Numeric
    Local nEnvFunc := 3 As Numeric
    Local cFilRFC := "" As Character
    Local cMatRFC := "" As Character
    Local cCCRFC := "" As Character
    Local lClasse := GetMvRH("MV_ITMCLVL", .F., "2") $ "13"
    Local cQuery := "" As Character
    Local nTReg := 0 As Numeric
    Local cAliasSRA := "QSRA" As Character
    Local cSit := "" As Character
    Local nPos := 0 As Numeric
    Local cFilRange :=  "" As Character
    Local cCCRange :=  "" As Character
    Local cMatRange :=  "" As Character
    Local cWhere := "" As Character
    Local cSitFolAtu := "" As Character
    Local cResRAISAt := "" As Character
    Local cCodConvoc := "" As Character
    Local __cEmpAnte := "" As Character
    Local __cFilAnte := "" As Character
    Local cFilMatAnt := "" As Character
    Local cSeq := " " As Character
    Local lEmpDif := .F. As Logical
    Local lTemRGB := .F. As Logical
    Local lTrfEmp := .F. As Logical
    Local nRecSRA := 0 As Numeric
    Local aConvoc := {} As Array
    Local cIdCmpl := "" As Character
    Local lRateio := .T. As Logical // Consider cost center
    Local lResult := .T. As Logical
    Local aTDPayments := {} As Array
    Local nTDIndex := 0 As Numeric
    Local aActualPeriod := {} As Array
    Local oStatement := FWPreparedStatement():New() As Object
    Local cAlias := "" As Character
    Local aSRANumbers := {} As Array
    Local nSRACount := 0 As Numeric
    Local nSRAIterator := 0 As Numeric
    Local aF5IRecnos := {} As Array

    /*
    *    PRIVATE VARIABLES.
    */
    Private cExclui := "" As Character
    Private aLog := {} As Array
    Private aTitle := {} As Array
    Private aTotRegs := Array(4) As Array
    Private nIndSRK := 0 As Array
    Private aPdv := {} As Array
    Private aPd := {} As Array
    Private cProcesso := "" As Character
    Private cRoteiro := "" As Character
    Private lContrInt := Iif(SRC->(ColumnPos("RC_CONVOC")) > 0, .T., .F.) As Logical

    aFill(aTotRegs, 0)

    /* 
    *    If field F5I_MESANO does not exist or empty - stop function.
    */
    F5I->(DbGoTop())
    If F5I->(FieldPos("F5I_MESANO")) == 0 .Or. Empty(F5I->F5I_MESANO)
        // "Attention", "Invalid data structure. Calculate the employment contract again."
        Help("", 1, STR0019, Nil, STR0109, 1, 0)
        lResult := .F.
    EndIf

    /* 
    *    Load parameters and check it.
    */
    If lResult
		Pergunte(PERGUNTE_GENERATION, .F.) // Load SX1 questions.
		
		// Adjusts work variables.
		cProcesso := MV_PAR01
		cRoteiro := MV_PAR02
		cAnoMes := MV_PAR03
		cSemana := MV_PAR04
		dDatVen := Iif(Empty(MV_PAR05), dDataBase, MV_PAR05) // "Due Date".
		nAtuLanc := MV_PAR09 // "Update entry" (INT, 1 or 2).
		cSituacao := MV_PAR10 // "Status".
		lTransfAtu := .T. // Option '2-No' discontinued.
		
		If Empty(cAnoMes)
			// "Attention", "Fill in the 'Month/year of calculation' parameter".
			Help("", 1, STR0019, Nil, STR0089, 1, 0)
			lResult := .F.
		EndIf
		
		// Checking the open period and specified in the parameters.
		fGetPerAtual(@aActualPeriod, FwXFilial("RCJ"), cProcesso, fGetCalcRot("1"))
		
		If ValType(aActualPeriod) == "A" .And. Len(aActualPeriod) > 0
			If aActualPeriod[1, 1] != cAnoMes
				If !lAuto
					MsgStop(STR0224, STR0019) // "The specified period has already closed. Specify the current period", "Warning".
				EndIf

                ConOut("RU07D11009_Integration: The specified period has already closed. Specify the current period")
				lResult := .F.
			EndIf
        Else
            lResult := .F.

            If !lAuto
                Help(" ", 1, "GPCALEND", )
            EndIf

            ConOut("RU07D11009_Integration: Failed to load period")
        EndIf
    EndIf

    /* 
    *    Get count F5I lines for employee.
    */
    If lResult
        MakeSqlExpr(PERGUNTE_GENERATION) // Transforms Range type questions into SQL expression.

        cQuery := " SELECT F5I_FILIAL, F5I_MESANO, F5I_DATA, F5I_MAT, F5I_CC, R_E_C_N_O_ AS RECNO "
        cQuery += " FROM " + RetSqlName("F5I") + " F5I "
        cQuery += " WHERE F5I.D_E_L_E_T_ = ' ' "

        If !Empty(MV_PAR06)
            cQuery += " AND " + Replace(MV_PAR06, "RA_", "F5I_")
        EndIf

        If !Empty(MV_PAR07)
            cQuery += " AND " + Replace(MV_PAR07, "RA_", "F5I_")
        EndIf

        If !Empty(MV_PAR08)
            cQuery += " AND " + Replace(MV_PAR08, "RA_", "F5I_")
        EndIf

        cQuery += " AND F5I.F5I_MESANO = '" + cAnoMes   + "' "
        cQuery += " AND F5I.F5I_SEMANA = '" + cSemana   + "' "
        cQuery += " AND F5I.F5I_PROCES = '" + cProcesso + "' "
        cQuery += " AND F5I.F5I_ROTEIR = '" + cRoteiro  + "' "
        cQuery += " AND F5I.F5I_INTEGR <> 'S' " // Not inegrated data.

        cQuery := ChangeQuery(cQuery)
        oStatement := FWPreparedStatement():New(cQuery)
        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())
    
        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())

        // Write F5I lines.
        While !(cAlias)->(Eof())
            aAdd(aF5IRecnos, {(cAlias)->(F5I_FILIAL), (cAlias)->(F5I_MAT), (cAlias)->(F5I_DATA), (cAlias)->(F5I_CC), (cAlias)->(RECNO)})

            (cAlias)->(DbSkip())
        EndDo
        
        nTReg := Len(aF5IRecnos)
        
        (cAlias)->(DbCloseArea())
        oStatement:Destroy()
        FwFreeObj(oStatement)

        If nTReg <= 0
            // "Attention", "Reverse agreement calculation failed".
            Help("", 1, STR0019, Nil, STR0024, 1, 0)
            lResult := .F.
        EndIf
    EndIf

    /*
    *   Let's get all employees (SRA) for whom integration is being performed.
    *   If there are more than zero SRA records, then the integration will continue.
    */
    If lResult
        //Include employees dismissed as transferred, when the "Normal" situation is selected.
        //Do not include transferred employees, when only the "Dismissed" option is selected.
        If  (!("D" $ cSituacao) .And. (" " $ cSituacao))
            cSituacao += "D"
            nEnvFunc := 1
        ElseIf ("D" $ cSituacao) .And. (" " $ cSituacao)
            nEnvFunc := 3
        ElseIf ("D" $ cSituacao) .And. !(" " $ cSituacao)
            nEnvFunc := 2
        EndIf

        // Positions SRA file pointers.
        cFilRange :=  MV_PAR06
        cCCRange  :=  MV_PAR07
        cMatRange :=  MV_PAR08

        // RA_FILIAL.
        If !Empty(cFilRange)
            cWhere += " AND " + cFilRange
        EndIf

        // RA_CC.
        If !Empty(cCCRange)
            cWhere += " AND " + cCCRange
        EndIf

        // RA_MAT.
        If !Empty(cMatRange)
            cWhere += " AND " + cMatRange
        EndIf

        // RA_SITFOLH. Statuses of employee.
        For nPos := 1 To Len(cSituacao)
            If SubStr(cSituacao, nPos, 1) <> "*"
                cSit += "'" + SubStr(cSituacao, nPos, 1) + "',"
            EndIf
        Next nPos

        If Len(cSit) > 1
            cSit := SubStr(cSit, 1, Len(cSit) - 1)
            cWhere += " AND RA_SITFOLH IN (" + cSit + ") "
            nPos := 0
        EndIf

        cWhere := "D_E_L_E_T_ = ' ' " + cWhere

        // Prepare SQL-query for execution.
        cQuery := " SELECT RA_FILIAL, RA_MAT, RA_NOMECMP, RA_CC, R_E_C_N_O_ RECNO FROM " + RetSQLName("SRA") + " SRA "
        cQuery += " WHERE " + cWhere
        cQuery += " ORDER BY RA_FILIAL, RA_MAT "

        oStatement := FWPreparedStatement():New(cQuery)
        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())
    
        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())

        // Write SRA lines.
        While !(cAlias)->(Eof())
            aAdd(aSRANumbers, {(cAlias)->(RA_FILIAL), (cAlias)->(RA_MAT), (cAlias)->(RA_NOMECMP), (cAlias)->(RA_CC), (cAlias)->(RECNO)})

            (cAlias)->(DbSkip())
        EndDo

        (cAlias)->(DbCloseArea())
        oStatement:Destroy()
        FwFreeObj(oStatement)

        // Check SRA lines. If more then 0 then start integration process.
        nSRACount := Len(aSRANumbers) // Get count SRA lines.

        If nSRACount > 0
            If !lAuto
                oSelf:SetRegua1(Len(aSRANumbers))
            EndIf
        Else
            lResult := .F.
        EndIf
    EndIf

    /* 
    *    Load filters.
    */
    // If lResult
    //     cSraFilter := GpFltAlsGet(aRetFiltro, "SRA") // Load the Filters.
    // EndIf

    /*
    * Beginning of the integration process. 
    * Cycle through SRA records.
    */
    If lResult
        Begin Transaction

        DbSelectArea("SRA")

        For nSRAIterator := 1 To nSRACount
            SRA->(DbGoto(aSRANumbers[nSRAIterator, 5]))

            // Checks user access to the employee's branch.
            If !(SRA->RA_FILIAL $ fValidFil())
                Loop
            EndIf

            // Move the cursor to move the bar.
            If !lAuto
                oSelf:IncRegua1(SRA->RA_FILIAL + ' - ' + SRA->RA_MAT + If(lOfusca, "", ' - ' + SRA->RA_NOMECMP))
            EndIf

            cSitFolAtu := SRA->RA_SITFOLH
            cResRAISAt := SRA->RA_RESCRAI
            nRecSRA := aSRANumbers[nSRAIterator, 5]

            // Checks whether there was a calculation for the employee.
            DbSelectArea("F5I")
            F5I->(DbSetOrder(RetOrder("F5I", "F5I_FILIAL+F5I_PROCES+F5I_MAT+F5I_MESANO+F5I_SEMANA+F5I_ROTEIR+F5I_IDCMPL")))
            F5I->(DbGoTop())
            cF5IKey := aSRANumbers[nSRAIterator, 1] + cProcesso + aSRANumbers[nSRAIterator, 2] + cAnoMes + cSemana + cRoteiro

            If F5I->(DbSeek(cF5IKey))
                // Check transfers of employee.
                If lTransfAtu
                    aDados := {}
                    aTransfFun := {}
                    lEmpDif := .F.
                    lTrfEmp := .F.
                    cFilMatAnt := ""
                    cSeq := ""
                    dTransf := CToD("//")
                    
                    fTransfAll(@aTransfFun, , , .T.) // Search All Transfers on SRE.

                    For nX := 1 To Len(aTransfFun)
                        If AnoMes(aTransfFun[nx, 7]) >= F5I->F5I_DATA
                            If aTransfFun[nX, 1] == aTransfFun[nX, 4] // There was no transfer between companies.
                                If nX > 1
                                    If aTransfFun[nX, 7] > dTransf
                                        aDados := { aTransfFun[nX, 10] ,; // Filial.
                                                    aTransfFun[nX, 11] ,; // RA_MAT.
                                                    aTransfFun[nX, 06] ,; // RA_CC.
                                                    aTransfFun[nX, 04] }  // Company.
                                    EndIf
                                Else
                                    aDados := { aTransfFun[nX, 10],; // Filial
                                                aTransfFun[nX, 11],; // RA_MAT
                                                aTransfFun[nX, 06],; // RA_CC
                                                aTransfFun[nX, 04]}  // Company
                                EndIf
                            Else // There was a transfer between companies.
                                If nX > 1
                                    If aTransfFun[nX,7] > dTransf
                                        aDados := { aTransfFun[nX, 10],; // Filial
                                                    aTransfFun[nX, 11],; // RA_MAT
                                                    aTransfFun[nX, 06],; // RA_CC
                                                    aTransfFun[nX, 04]}  // Company
                                        If cEmpAnt != aTransfFun[nX, 4]
                                            cFilMatAnt := aTransfFun[nX, 1] + aTransfFun[nX, 2]
                                            lEmpDif := .T.
                                        EndIf
                                    EndIf
                                Else
                                    aDados := { aTransfFun[nX, 10],; // Filial
                                                aTransfFun[nX, 11],; // RA_MAT
                                                aTransfFun[nX, 06],; // RA_CC
                                                aTransfFun[nX, 04]}  // Company
                                    If cEmpAnt != aTransfFun[nX, 4]
                                        cFilMatAnt := aTransfFun[nX, 1] + aTransfFun[nX, 2]
                                        lEmpDif := .T.
                                    EndIf
                                EndIf

                                lTrfEmp := .T.
                            EndIf

                            dTransf := aTransfFun[nx, 7]
                            
                            If Len(aDados) > 0 .And. SRA->(DbSeek(aDados[1] + aDados[2]))
                                cSitFolAtu := SRA->RA_SITFOLH
                                cResRAISAt := SRA->RA_RESCRAI

                                SRA->(DbGoto(nRecSRA))
                            EndIf
                        EndIf
                    Next

                    If Len(aDados) > 0
                        If  ((aDados[1] < cFilFrom .Or. aDados[1] > cFilTo) .And. !Empty(cFilTo)) .Or. ;
                            ((aDados[2] < cMatFrom .Or. aDados[2] > cMatTo) .And. !Empty(cMatTo)) .Or. ;
                            ((aDados[3] < cCCFrom  .Or. aDados[3] > cCCTo ) .And. !Empty(cCCTo))

                            If aTotRegs[2] == 0
                                cLog := STR0087 + STR0088 // "Not created -", "Branch/TN/Cost Center does not meet the selected parameters".
                                aAdd(aTitle, cLog)
                                aAdd(aLog, {})
                                aTotRegs[2] := Len(aLog)
                            EndIf

                            cBusca := aDados[1] + "-" + aDados[2] + " - " + SRA->RA_NOME
                            If Len(aLog[1]) > 0
                                If aScan(aLog, {|x| x[1] == cBusca}) == 0
                                    aAdd(aLog[aTotRegs[2]], cBusca)
                                EndIf
                            Else
                                aAdd(aLog[aTotRegs[2]], cBusca)
                            EndIf

                            (cAliasSRA)->(DbSkip())
                            Loop
                        EndIf
                    EndIf
                EndIf

                // Include employees dismissed as transferred, when the "Normal" situation is selected.
                // Do not include transferred employees, when only the "Dismissed" option is selected.
                If (cSitFolAtu == "D" .And. ((nEnvFunc == 1 .And. !(cResRAISAt $ '30/31') ) .Or. (nEnvFunc == 2 .And. (cResRAISAt $ '30/31'))))
                    Loop
                EndIf

                If nAtuLanc == 1 .And. ( cSitFolAtu == "D" .And. !(cResRAISAt $ '30/31')) // Generate in Monthly Release and the employee is fired.
                    If aTotRegs[1] == 0
                        cLog := STR0086 + STR0215 // "Not created -", "Fired employee cannot be sent to monthly releases".
                        aAdd(aTitle, cLog)
                        aAdd(aLog, {})
                        aTotRegs[1] := Len(aLog)
                    EndIf

                    cBusca := SRA->RA_FILIAL + "-" + SRA->RA_MAT + " - " + SRA->RA_NOME

                    If Len(aLog[1]) > 0
                        If aScan(aLog, {|x| x[1] == cBusca}) == 0
                            aAdd(aLog[aTotRegs[1]], cBusca)
                        EndIf
                    Else
                        aAdd(aLog[aTotRegs[1]], cBusca)
                    EndIf

                    Loop
                EndIf

                // Saves the first increase "order" to record it if there is no increase on the date (any type
                // increase or any record of increase for any date).
                nFirstRec := F5I->(Recno())
                nValAnt := 0

                If lEmpDif
                    // Saves the company and branch, as they will be changed in the ChangeNew function.
                    __cEmpAnte := cEmpAnt
                    __cFilAnte := cFilAnt
                    nRecSRA := aSRANumbers[nSRAIterator, 5]

                    // Opens the target company group tables.
                    ChangeNew({"SRA", "RGB", "SRK", "RFC", "SR3", "SR7", "SRJ", "SQ3", "SRV"}, aDados[4], aDados[1])
                    cEmpAnt := aDados[4]
                    cFilAnt := aDados[1]
                    SRA->(DbSetOrder(1))
                    SRA->(DbSeek(aDados[1] + aDados[2]))
                EndIf

                While F5I->(!Eof())
                    If !(F5I->(F5I_FILIAL + F5I_PROCES + F5I_MAT + F5I_MESANO + F5I_SEMANA + F5I_ROTEIR) == cF5IKey)
                        Exit
                    EndIf

                    If !Empty(cIdCmpl) .And. F5I->F5I_IDCMPL <> cIdCmpl
                        F5I->(DbSkip())
                        Loop
                    EndIf

                    // If the entry is integrated then skip it.
                    If Empty(F5I->F5I_INTEGR) .And. F5I->F5I_INTEGR == PAYMENT_IS_INTEGRATED
                        F5I->(DbSkip())
                        Loop
                    EndIf

                    // Considers the Admission date for employees hired in the month of the dispute.
                    IF  SubStr(DToS(SRA->RA_ADMISSA), 1, 6) >= F5I->F5I_DATA
                        dDtReaj := SRA->RA_ADMISSA
                    Else
                        dDtReaj := CToD("01/" + SubStr(F5I->F5I_DATA, 5, 2) + "/" + SubStr(F5I->F5I_DATA, 1, 4))
                    Endif

                    /*
                    *    Update employee total matrix.
                    *    There was an update to the PO history here, but it is disabled now.
                    */
                    // Upload funds registration for later filtering.
                    If cAntFil <> F5I->F5I_FILIAL
                        If !Fp_CodFol(@aCodFol, xFilial("SRA", F5I->F5I_FILIAL))
                            Exit
                        Endif

                        cAntFil := F5I->F5I_FILIAL
                        cNotCods := FiltraVb(aCodFol) // Feeds cNotCods with codes that should not be listed.
                    EndIf

                    // Filling the array with payment types for integration.
                    If F5I->F5I_COMPL_ == PAYMENT_FOR_RETRO .And. !(F5I->F5I_VB $ cNotCods)
                        nLinha := 0

                        If lTransfAtu .And. Len(aDados) > 0
                            aAdd(aRetroPd, {aDados[1], aDados[2], F5I->F5I_VERBA, aDados[3], F5I->F5I_VALOR, F5I->F5I_DATA, SRA->RA_ITEM, SRA->RA_CLVL, F5I->F5I_HORAS})
                        Else
                            aAdd(aRetroPd, {SRA->RA_FILIAL, SRA->RA_MAT, F5I->F5I_VERBA, F5I->F5I_CC, F5I->F5I_VALOR, F5I->F5I_DATA, SRA->RA_ITEM, SRA->RA_CLVL, F5I->F5I_HORAS})
                        EndIf
                    EndIf

                    If lTransfAtu .and. Len(aDados) > 0
                        cFilRFC := aDados[1]
                        cMatRFC := aDados[2]
                        cCCRFC  := aDados[3]
                    Else
                        cFilRFC := SRA->RA_FILIAL
                        cMatRFC := SRA->RA_MAT
                        cCCRFC  := SRA->RA_CC
                    EndIf

                    DbSelectArea("F5I")

                    If F5I->(RecLock("F5I", .F., .F.))
                        F5I->F5I_INTEGR := "S"
                        F5I->(MsUnlock())
                    Else
                        lResult := .F.
                    EndIf

                    F5I->(DbSkip())
                EndDo

                /*
                *    Writes calculated values to the future postings file (RGB).
                */
                For nI := 1 To Len(aRetroPd)
                    If !lResult
                        Loop
                    EndIf

                    // If there is no change by this payment then go to next payment.
                    If aRetroPd[nI, 5] == 0
                        Loop
                    EndIf
                    
                    /*
                    *     This code is responsible for ensuring that only positive values are written to RGB.
                    *     Below we will add logic to record the difference modulo (using the Abs() function).
                    */
                    If lTransfAtu .And. Len(aDados) > 0
                        cKey := aDados[1] + aDados[2]
                    Else
                        cKey := SRA->RA_FILIAL + SRA->RA_MAT
                    EndIf

                    If cKey # aRetroPd[nI, 1] + aRetroPd[nI, 2]
                        Loop
                    EndIf

                    /*
                    *    For now, only "Monthly Values" will be used (nAtuLanc = 1), 
                    *    so the logic for "Future Values" (loading into SRK) has been removed. 
                    *    If necessary, look in GPEM690 in the GP690Proc function (nAtuLanc = 1).
                    */
                    If nAtuLanc == 1 // Monthly values.
                        // Search unique tax deduction payment and change ref. data.
                        nTDIndex := aScan(aTDPayments, {|x| x[1] == aRetroPd[nI, 3]})

                        If nTDIndex > 0
                            aAdd(aTDPayments, {aRetroPd[nI, 3], dDatVen})
                            dDatVen := aTDPayments[nTDIndex, 2] - 1
                        Else
                            aAdd(aTDPayments, {aRetroPd[nI, 3], dDatVen})
                        EndIf

                        DbSelectArea("RGB")
                        RGB->(DbSetOrder(RetOrder("RGB", "RGB_FILIAL + RGB_MAT + RGB_PD + RGB_CC + RGB_ITEM + RGB_CLVL + RGB_SEMANA + RGB_SEQ")))

                        lTemRGB := .F.
                        cCodConvoc := ""

                        If lContrInt .And. SRA->RA_TPCONTR == "3" .And. SRA->RA_SALARIO == 0
                            aConvoc := BuscaConv(SToD(cAnoMes + "01"), SToD(cAnoMes + AllTrim(Str(Last_Day(SToD(cAnoMes + "01"))))))
                            
                            If !Empty(aConvoc)
                                cCodConvoc := aConvoc[1, 1] // Call code.
                            EndIf
                        EndIf

                        // If this is a payment type for personal income tax recalculation, then RGB_CONVOC is indicated.
                        If aRetroPd[nI, 3] $ "AAY*AAZ"
                            cCodConvoc := AllTrim(Str(aRetroPd[nI, 9]))
                        EndIf

                        /*
                        *   Write to RGB.
                        */
                        If RGB->(RecLock("RGB", .T.))
                            If lTransfAtu .And. Len(adados) > 0
                                RGB->RGB_FILIAL := aDados[1]
                                RGB->RGB_MAT := aDados[2]
                                RGB->RGB_CC := aDados[3]
                            Else
                                RGB->RGB_FILIAL := SRA->RA_FILIAL
                                RGB->RGB_MAT := SRA->RA_MAT
                                RGB->RGB_CC := If(lRateio, aRetroPd[nI, 4], SRA->RA_CC)
                            EndIf

                            RGB->RGB_PD := aRetroPd[nI, 3]
                            RGB->RGB_SEMANA := cSemana
                            RGB->RGB_TIPO1 := "V"
                            RGB->RGB_TIPO2 := "G"
                            RGB->RGB_HORAS := aRetroPd[nI, 9]
                            RGB->RGB_VALOR := Abs(aRetroPd[nI, 5])
                            RGB->RGB_PARCEL := 0
                            RGB->RGB_SEQ := cSeq
                            RGB->RGB_PROCES := cProcesso
                            RGB->RGB_PERIOD := cAnoMes
                            RGB->RGB_ROTEIR := cRoteiro
                            RGB->RGB_DTREF := dDatVen
                            RGB->RGB_DEPTO := SRA->RA_DEPTO
                            RGB->RGB_IDCMPL := cIdCmpl
                            RGB->RGB_DTREFC := aRetroPd[nI, 6] // F5I_DATA.

                            If (lClasse .And. (!Empty(aRetroPd[nI, 7]) .Or. !Empty(aRetroPd[nI, 8])))
                                fGravaItem("RGB", aRetroPd[nI], 7) // The routine can be found in the source: GPEM700.
                            EndIf

                            If !Empty(cCodConvoc)
                                RGB->RGB_CONVOC := cCodConvoc
                            EndIf

                            RGB->(MsUnLock())
                        Else
                            lResult := .F.
                        EndIf
                    EndIf
                Next

                If lEmpDif
                    cEmpAnt := __cEmpAnte
                    cFilAnt := __cFilAnte

                    // Opens the target company group tables.
                    ChangeNew({"SRA", "RGB", "SRK", "RFC", "SR3", "SR7", "SRJ", "SQ3", "SRV"}, cEmpAnt, cFilAnt)

                    SRA->(DbGoTo(nRecSRA))
                EndIf
            EndIf

        Next nI

        // Cancel transaction if some error exists.
        If !lResult
            DisarmTransaction()
            ConOut("RU07D11009_Integration: Cancel transaction")
        EndIf

        End Transaction
    EndIf

    /*
    *    Show result of process.
    */

    // Calls the Occurrence Log routine.
    // NOW LOG WILL NOT BE SHOW TO USER. DATA IS EMPTY!
    // aAdd(aTitle, {STR0213})
    // MsAguarde({|| fMakeLog(aLog, aTitle, Nil, Nil, FunName(), STR0059, , , , .F.)}, STR0060)

    If !lAuto
        If lResult
            MsgInfo(STR0219) // "Integration process finished successeful"
        Else
            MsgAlert(STR0220) // "Integration process finished with error."
        EndIf
    EndIf

    F5I->(RestArea(aF5IArea))
    SRA->(RestArea(aAreaSRA))
    SR3->(RestArea(aAreaSR3))
    SR7->(RestArea(aAreaSR7))
    RestArea(aArea)
Return lResult



/*
*    Standard TReport.
*/

/*{Protheus.doc} RU07R11007_StandardReport()
    Function for starting a process print a report.
    Analog of GP690Imp.

    @type Function
    @author vselyakov
    @since 07.02.2024
    @version 12.1.2310
*/
Function RU07R11007_StandardReport()
    Local oReport As Object

    Pergunte(PERGUNTE_REPORT, .F.)

    oReport := ReportDef()
    oReport:PrintDialog()

Return


/*{Protheus.doc} ReportDef()
    Definition of the report.

    @type Static Function
    @author vselyakov
    @since 07.02.2024
    @version 12.1.2310
    @return oReport, Object, Object of REPORT.
*/
Static Function ReportDef()
    Local oReport As Object
    Local oSection1 As Object
    Local oSection2 As Object
    Local cDesc := STR0006 + ". " + STR0026 + " " + STR0027 As Character // "Recalculation", "Will print according to the options selected", "user".
    Local aOrd := {} As Array

    aAdd(aOrd, STR0028) // "Personnel Number".
    aAdd(aOrd, STR0029) // "Cost center".
    aAdd(aOrd, STR0030) // "Name".

    // Home definition of the Report.
    DEFINE REPORT oReport NAME "RU07D11REPORT" TITLE STR0006 PARAMETER PERGUNTE_REPORT ACTION {|oReport| PrintReport(oReport)} DESCRIPTION cDesc // "Recalculation".

    // Officials Section
    DEFINE SECTION oSection1 OF oReport TABLES "SRA" ORDERS aOrd TITLE STR0077 // "Employees".
    oSection1:SetHeaderBreak(.T.)

    DEFINE CELL NAME "RA_MAT"     OF oSection1 ALIAS "SRA"
    DEFINE CELL NAME "RA_NOMECMP" OF oSection1 ALIAS "SRA"

    // Section of the Temporary Table - Retroactive Dissidio.
    DEFINE SECTION oSection2 OF oReport TABLES MAIN_TABLE TITLE STR0006

    DEFINE CELL NAME "F5I_DATA"   OF oSection2 ALIAS MAIN_TABLE TITLE STR0014 BLOCK {|| F5I->F5I_DATA}
    DEFINE CELL NAME "F5I_VB"     OF oSection2 ALIAS MAIN_TABLE TITLE STR0012 BLOCK {|| F5I->F5I_VB + " - " + If(F5I_VB =="000", Left(STR0217 + Space(20), 20), Left(RetValSRV(F5I->F5I_VB, SRA->RA_FILIAL, "RV_DESC") + Space(20), 20))} SIZE 27
    DEFINE CELL NAME "F5I_VL"     OF oSection2 ALIAS MAIN_TABLE TITLE STR0013 PICTURE "@E 9,999,999.99" SIZE 15
    DEFINE CELL NAME "F5I_CALC"   OF oSection2 ALIAS MAIN_TABLE TITLE STR0017 PICTURE "@E 9,999,999.99" SIZE 15
    DEFINE CELL NAME "F5I_VALOR"  OF oSection2 ALIAS MAIN_TABLE TITLE STR0018 PICTURE "@E 999,999.99"   SIZE 12
    DEFINE CELL NAME "F5I_VERBA"  OF oSection2 ALIAS MAIN_TABLE TITLE STR0015
    DEFINE CELL NAME "F5I_COMPL_" OF oSection2 ALIAS MAIN_TABLE TITLE STR0052
Return oReport


/*{Protheus.doc} PrintReport()
    Definition of the report.

    @type Static Function
    @param oReport, Object, Object of REPORT.
    @author vselyakov
    @since 07.02.2024
    @version 12.1.2310
*/
Static Function PrintReport(oReport)
    Local aArea := GetArea() As Array
    Local SRAArea := SRA->(GetArea()) As Array
    Local aF5IArea := F5I->(GetArea()) As Array
    Local nOrdem := oReport:Section(1):GetOrder() As Numeric
    Local nReg := 0 As Numeric
    Local nI := 0 As Numeric
    Local oSection1 := oReport:Section(1) As Object
    Local oSection2 := oReport:Section(2) As Object
    Local cFilter := "" As Character
    Local cFil := "" As Character
    Local cCC := "" As Character
    Local cDescTot := "" As Character
    Local cDtaAnt := "" As Character
    Local aTotal := {} As Array
    Local aTotPD := {} As Array
    Local aFilial := {} As Array
    Local aCC := {} As Array
    Local aFunc := {} As Array
    Local cPeriodo := "" As Character
    Local lImpTot := .F. As Logical

    If MV_PAR01 == 3 .And. nOrdem != 1
        // "Attention", "Invalid printing order for summary detail format. Select Registration as the print order.".
        Help("", 1, STR0019, Nil, STR0107, 1, 0 )
        Return Nil
    Endif

    // Orders and positions at the beginning of the SRA.
    SRA->(DbSetOrder(nOrdem))
    SRA->(DBGoTop())

    // Adjusts work variables.
    nTipo := MV_PAR01 // Type of report.
    MV_PAR05 := SubStr(MV_PAR05, 3, 4) + SubStr(MV_PAR05, 1, 2) // Month/Year.
    cPeriodo := MV_PAR05

    // Filter the file...
    // Transforms Range type parameters into ADVPL expression to be used in the filter.
    MakeAdvplExpr(PERGUNTE_REPORT)

    // Filial.
    If !Empty(MV_PAR02)
        cFilter += MV_PAR02
    EndIf

    // Cost center.
    If !Empty(MV_PAR03)
        If !Empty(cFilter)
            cFilter += " .AND. "
        EndIf

        cFilter += MV_PAR03
    EndIf

    // Personnel number.
    If !Empty(MV_PAR04)
        If !Empty(cFilter)
            cFilter += " .AND. "
        EndIf

        cFilter += MV_PAR04
    EndIf

    // Filter the Employee table according to your questions.
    If !Empty(cFilter)
        oSection1:SetFilter(cFilter)
    EndIf

    // Filter recalculation compliant with Month/Year recalculation parameter.
    If !Empty(cPeriodo)
        oSection2:SetFilter(' ( F5I_MESANO == "' + cPeriodo + '" )')
    EndIf

    // Select employee table.
    DbSelectArea("SRA")

    // Defines the total run of the report processing fabric.
    oReport:SetMeter(SRA->(RecCount()))

    // Initializes print control variables.
    aTotal := {}
    aTotPD := {}
    aFilial := {}
    aCC := {}
    cFil := SRA->RA_FILIAL
    cCC := SubStr(SRA->RA_CC + Space(20), 1, 20)

    While !SRA->(Eof())
        If nTipo != 3
            aFunc := {}
        EndIf

        // Increments the ruler on the report processing screen.
        oReport:IncMeter()

        // Checks if the user has canceled printing of the report.
        If oReport:Cancel()
            Exit
        EndIf

        // Checks whether there was a calculation for the employee.
        DbSelectArea("F5I")
        F5I->(DbSetOrder(1)) // "F5I_FILIAL+F5I_MAT+F5I_MESANO+F5I_DATA+F5I_VB+F5I_CC+F5I_ITEM+F5I_CLVL+F5I_SEMANA+F5I_SEQ+F5I_ROTEIR".
        F5I->(DbGoTop())

        If F5I->(DbSeek(FwXFilial("F5I") + SRA->RA_MAT))

            // Prints the employee's calculations.

            // Start printing.
            If nTipo != 3
                oSection1:Init()
                oSection1:PrintLine()
                oSection1:Finish()
            EndIf

            oSection2:Init()
            cFunc := SRA->RA_MAT + "-" + Iif(lOfusca, Replicate("*", Len(SRA->RA_NOMECMP)), SRA->RA_NOMECMP)

            Do While F5I->(!Eof()) .And. F5I->F5I_FILIAL + F5I->F5I_MAT = SRA->RA_FILIAL + SRA->RA_MAT
                // Analytical.
                If nTipo = 1
                    oSection2:PrintLine()
                Endif

                If F5I->F5I_COMPL_ == "S"

                    // Updates employee total matrix for printing SubTotals.
                    If nTipo == 3
                        If (nLinha := Ascan(aFunc, {|X| X[1] + X[2] = F5I->F5I_DATA + F5I->F5I_VERBA})) > 0
                            aFunc[nLinha, 3] += F5I->F5I_VALOR
                        Else
                            aAdd(aFunc, {F5I->F5I_DATA, F5I->F5I_VERBA, F5I->F5I_VALOR, F5I->F5I_DATA})
                        Endif
                    Else
                        // Update employee total matrix.
                        If (nReg := Ascan(aFunc, {|X| X[2] = F5I->F5I_VERBA})) > 0
                            aFunc[nReg, 3] += Iif(!Empty(F5I->F5I_VALOR), F5I->F5I_VALOR, 0)
                        Else
                            aAdd(aFunc, {F5I->F5I_DATA, F5I->F5I_VERBA, Iif(!Empty(F5I->F5I_VALOR), F5I->F5I_VALOR, 0)})
                        Endif
                    Endif

                    // Update branch total matrix.
                    If (nReg := aScan(aFilial, {|X| X[2] = F5I->F5I_VERBA})) > 0
                        aFilial[nReg, 3] += Iif(!Empty(F5I->F5I_VALOR), F5I->F5I_VALOR, 0)
                    Else
                        aAdd(aFilial, {F5I->F5I_DATA, F5I->F5I_VERBA, Iif(!Empty(F5I->F5I_VALOR), F5I->F5I_VALOR, 0), F5I->F5I_FILIAL})
                    Endif

                    // Updates cost center total matrix.
                    If (nReg := aScan(aCC, {|X| X[2] = F5I->F5I_VERBA})) > 0
                        aCC[nReg, 3] += Iif(!Empty(F5I->F5I_VALOR), F5I->F5I_VALOR, 0)
                    Else
                        aAdd(aCC, {F5I->F5I_DATA, F5I->F5I_VERBA, Iif(!Empty(F5I->F5I_VALOR), F5I->F5I_VALOR, 0)})
                    Endif

                    // Updates grand totalization matrix.
                    If (nReg := aScan(aTotal, {|X| X[2] = F5I->F5I_VERBA})) > 0
                        aTotal[nReg, 3] += Iif(!Empty(F5I->F5I_VALOR), F5I->F5I_VALOR, 0)
                    Else
                        aAdd(aTotal, {F5I->F5I_DATA, F5I->F5I_VERBA, Iif(!Empty(F5I->F5I_VALOR), F5I->F5I_VALOR, 0)})
                    Endif
                EndIf

                // Updates total Funds matrix.
                If (nReg := aScan(aTotPd, {|X| X[2] = F5I->F5I_VB})) > 0
                    aTotPd[nReg, 3] += F5I->F5I_VL
                    aTotPd[nReg, 4] += F5I->F5I_CALC
                    aTotPd[nReg, 5] += Iif(!Empty(F5I->F5I_VALOR), F5I->F5I_VALOR, 0)
                Else
                    aAdd(aTotPd, {F5I->F5I_DATA, F5I->F5I_VB, F5I->F5I_VL, F5I->F5I_CALC, Iif(!Empty(F5I->F5I_VALOR), F5I->F5I_VALOR, 0), Left(RetValSRV(F5I->F5I_VB, SRA->RA_FILIAL, "RV_DESC") + Space(20), 20), F5I->F5I_VERBA, F5I->F5I_COMPL_} )
                EndIf

                F5I->(DbSkip())
            EndDo

            oSection2:Finish()

            // Print total of the official.
            If nTipo != 3
                If Len(aFunc) > 0
                    cDescTot := ""

                    If Len(aFunc) = 1
                        cDescTot := Pad(STR0034 + ": " + cFunc, 57) // "Overall result - employee".
                    Else
                        cDescTot := Pad(STR0035 + " " + cFunc, 90) // "Total amount for employee position".
                    EndIf

                    oReport:SkipLine()
                    oReport:PrintText(cDescTot)
                    oSection2:SetHeaderSection(.F.)
                    oSection2:Init(.F.)

                    For nReg := 1 To Len(aFunc)
                        If !Empty(aFunc[nReg, 1])
                            // Change Section values.
                            oSection2:Cell("F5I_DATA"):SetValue(aFunc[nReg, 1])
                            oSection2:Cell("F5I_VB"):SetValue(aFunc[nReg, 2] + " - " + RetValSRV(aFunc[nReg, 2], SRA->RA_FILIAL, "RV_DESC"))
                            oSection2:Cell("F5I_VL"):SetValue(0)
                            oSection2:Cell("F5I_CALC"):SetValue(0)
                            oSection2:Cell("F5I_VALOR"):SetValue(aFunc[nReg, 3])
                            oSection2:Cell("F5I_VERBA"):SetValue("")
                            oSection2:Cell("F5I_COMPL_"):SetValue("")

                            oSection2:PrintLine()
                        EndIf
                    Next

                    oSection2:Finish()
                    oSection2:SetHeaderSection(.T.)
                EndIf
                
                oReport:ThinLine()
                oReport:SkipLine()
            EndIf
        EndIf

        // Prints the monthly SubTotals.
        If nTipo = 3 .And. !(SRA->(&(cFilter))) .And. !Empty(aFunc)
            aFunc := aSort(aFunc, , , {|x, y| x[1] + x[2] < y[1] + y[2]})

            For nI := 1 To Len(aFunc)
                If !Empty(aFunc[nI, 2])

                    If !(cDtaAnt == aFunc[nI, 4]) .And. (nI > 1)
                        oReport:SkipLine()
                    EndIf

                    // Change Section values.
                    oSection2:Cell("F5I_DATA"):SetValue(aFunc[nI, 1])
                    oSection2:Cell("F5I_VB"):SetValue(aFunc[nI, 2] + " - " + RetValSRV(aFunc[nI, 2], SRA->RA_FILIAL, "RV_DESC"))
                    oSection2:Cell("F5I_VL"):SetValue(0)
                    oSection2:Cell("F5I_CALC"):SetValue(0)
                    oSection2:Cell("F5I_VALOR"):SetValue(aFunc[nI, 3])
                    oSection2:Cell("F5I_VERBA"):SetValue("")
                    oSection2:Cell("F5I_COMPL_"):SetValue("")
                    oSection2:Cell("F5I_DATA"):SetBlock({|| Right(aFunc[nI, 4], 2) + '/' + Left(aFunc[nI, 4], 4)})

                    oSection2:PrintLine()

                    cDtaAnt := aFunc[nI, 3]
                    lImpTot := .T. // Determines whether totals can be printed.
                EndIf
            Next
        Endif

        If cCC != SRA->RA_CC .And. nOrdem = 2 .And. Len(aCC) > 0 .And. lImpTot
            // Prints total for the Cost Center.
            oReport:SkipLine()
            oReport:PrintText(Pad(STR0046 + cCC, 57)) // "Subtotal - cost centers:".
            oSection2:Init(.F.)

            For nReg := 1 To Len(aCC)
                If !Empty(aCC[nReg, 2])
                    // Change Section values.
                    oSection2:Cell("F5I_DATA"):SetValue(aCC[nReg, 1])
                    oSection2:Cell("F5I_VB"):SetValue(aCC[nReg, 2] + " - " + RetValSRV(aCC[nReg, 2], SRA->RA_FILIAL, "RV_DESC"))
                    oSection2:Cell("F5I_VL"):SetValue(0)
                    oSection2:Cell("F5I_CALC"):SetValue(0)
                    oSection2:Cell("F5I_VALOR"):SetValue(aCC[nReg, 3])
                    oSection2:Cell("F5I_VERBA"):SetValue("")
                    oSection2:Cell("F5I_COMPL_"):SetValue("")

                    oSection2:PrintLine()
                EndIf
            Next

            oSection2:Finish()

            oReport:ThinLine()
            oReport:EndPage()

            cCC := SubStr(SRA->RA_CC + Space(20), 1, 20)
            aCC := {}
        Endif

        If cFil != SRA->RA_FILIAL .And. Len(aFilial) > 0 .Or. lImpTot
            // Print branch total.
            cDescTot := ""

            If Len(aFilial) = 1
                cDescTot := Pad(STR0037 + " " + aFilial[1, 4], 57) // "Subtotal - branch:"
            Else
                cDescTot := Pad(STR0038 + " " + aFilial[1, 4], 57) // "Subtotal - values for the branch's funds:"
            EndIf

            oReport:SkipLine()
            oReport:PrintText(cDescTot)
            oSection2:Init(.F.)

            For nReg := 1 To Len(aFilial)
                If !Empty(aFilial[nReg, 2])
                    // Change Section values.
                    oSection2:Cell("F5I_DATA"):SetValue(aFilial[nReg, 1])
                    oSection2:Cell("F5I_VB"):SetValue(aFilial[nReg, 2] + " - " + RetValSRV(aFilial[nReg, 2], SRA->RA_FILIAL, "RV_DESC"))
                    oSection2:Cell("F5I_VL"):SetValue(0)
                    oSection2:Cell("F5I_CALC"):SetValue(0)
                    oSection2:Cell("F5I_VALOR"):SetValue(aFilial[nReg, 2])
                    oSection2:Cell("F5I_VERBA"):SetValue("")
                    oSection2:Cell("F5I_COMPL_"):SetValue("")

                    oSection2:PrintLine()
                EndIf
            Next

            oSection2:Finish()
            oReport:ThinLine()
            oReport:EndPage()

            cFil := SRA->RA_FILIAL
            aFilial := {}
        Endif

        oSection2:Cell("F5I_DATA"):SetValue()
        oSection2:Cell("F5I_VB"):SetValue()
        oSection2:Cell("F5I_VL"):SetValue()
        oSection2:Cell("F5I_CALC"):SetValue()
        oSection2:Cell("F5I_VALOR"):SetValue()
        oSection2:Cell("F5I_VERBA"):SetValue()
        oSection2:Cell("F5I_COMPL_"):SetValue()
        oSection2:Cell("F5I_DATA"):SetBlock({|| Right(F5I->F5I_DATA, 2) + '/' + Left(F5I->F5I_DATA, 4)})
        oSection2:Cell("F5I_VB"):SetBlock({|| F5I->F5I_VB + " - " + If(F5I->F5I_VB == "000", Left(STR0080 + Space(20), 20), Left(RetValSRV(F5I->F5I_VB, SRA->RA_FILIAL, "RV_DESC") + Space(20), 20))}) // "Salary".

        SRA->(DbSkip())
    EndDo

    // Prints grand total.
    If Len(aTotPD) > 0
        aSort(aTotPD, , ,{|x, y| x[1] < y[1]})

        oReport:EndPage()
        oReport:SkipLine(2)
        oReport:PrintText(Pad(STR0080, 57)) // "Total amount of calculated funds".
        oReport:SkipLine()
        oSection2:Init(.F.)

        For nReg := 1 To Len(aTotPD)
            If aTotPD[nReg, 1] # "000"
                // Change Section values.
                oSection2:Cell("F5I_DATA"):SetValue(aTotPd[nReg, 1])
                oSection2:Cell("F5I_VB"):SetValue(aTotPd[nReg, 2] + " - " + aTotPd[nReg, 6])
                oSection2:Cell("F5I_VL"):SetValue(aTotPD[nReg, 3])
                oSection2:Cell("F5I_CALC"):SetValue(aTotPD[nReg, 4])
                oSection2:Cell("F5I_VALOR"):SetValue(Iif(!Empty(aTotPD[nReg, 5]), aTotPD[nReg, 5], 0))
                oSection2:Cell("F5I_VERBA"):SetValue(aTotPD[nReg, 7])
                oSection2:Cell("F5I_COMPL_"):SetValue(aTotPD[nReg, 8])

                oSection2:PrintLine()
            EndIf
        Next nReg

        oSection2:Finish()
        oReport:ThinLine()
        oReport:SkipLine()
    EndIf

    If Len( aTotal ) > 0
        oReport:EndPage()

        If Len(aTotal) = 1
            cDescTot := Pad(STR0040, 57) // "Total payable".
        Else
            cDescTot := Pad(STR0040, 57) // "Total value by means".
        Endif

        oReport:SkipLine(2)
        oReport:PrintText(cDescTot)
        oReport:SkipLine()
        oSection2:Init(.F.)

        For nReg := 1 To Len(aTotal)
            If !Empty(aTotal[nReg, 2])
                // Change Section values.
                oSection2:Cell("F5I_DATA"):SetValue(aTotal[nReg, 1])
                oSection2:Cell("F5I_VB"):SetValue(aTotal[nReg, 2] + " - " + RetValSRV(aTotal[nReg, 2], SRA->RA_FILIAL, "RV_DESC"))
                oSection2:Cell("F5I_VL"):SetValue(0)
                oSection2:Cell("F5I_CALC"):SetValue(0)
                oSection2:Cell("F5I_VALOR"):SetValue(aTotal[nReg, 3])
                oSection2:Cell("F5I_VERBA"):SetValue("")
                oSection2:Cell("F5I_COMPL_"):SetValue("")

                oSection2:PrintLine()
            EndIf
        Next

        oSection2:Finish()
        oReport:ThinLine()
    EndIf

    F5I->(RestArea(aF5IArea))
    SRA->(RestArea(SRAArea))
    RestArea(aArea)

Return Nil


/*
*    Validations.
*/

/*/{Protheus.doc} RU07D11011_ValidationPeriod
    Validation of the script and load of other questions.
    Copy of function Gpem690Rot.

    @type Function
    @param cProces, Object, Object of MpFormModel.
    @author vselyakov
    @since 16.02.2024
    @version 12.1.2310
    @return Logical, Result of validation.
    @example "RU07D11011(MV_PAR01)"
/*/
Function RU07D11011_ValidationPeriod(cProces)
    Local aActualPeriod := {} As Array
    Local cScript := &(ReadVar()) As Character
    Local lResult := .T. As Logical

    If lResult .And. Empty(cProces)
        lResult := .T.
    EndIf

    If lResult .And. Empty(cProces)
        Help(" ", 1, "GPER20PROC")
        lResult := .F.
    EndIf

    If lResult
        If !fGetPerAtual(@aActualPeriod, FwXFilial("RCJ"), cProces, cScript)
            Help(" ", 1, "GPCALEND", )
            lResult := .F.
        Else
            MV_PAR03 := aActualPeriod[1, 1] // Period.
            MV_PAR04 := aActualPeriod[1, 2] // Payment number.
        EndIf
    EndIf

Return lResult

/*/{Protheus.doc} RU07D11016_ValidationEmployeeNumbers
    Function for validation of field "Personnel Numbers".

    @type Function
    @param cEmpNumbers, Character, Personnel Numbers like "000299;000300-000302;".
    @author vselyakov
    @since 09.02.2024
    @version 12.1.2310
    @return Logical, Result of validation.
    @example "RU07D11016(MV_PAR09)"
/*/
Function RU07D11016_ValidationEmployeeNumbers(cEmpNumbers)
    Local lValid := .F. As Logical
    Local aEmpNumbers := {} As Array
    Local nI := 0 As Numeric
    Local aArea := GetArea() As Array
    Local aSRAArea := SRA->(GetArea()) As Array
    Local nLenTabelNumber := TamSX3("RA_MAT")[1] As Numeric

    Default cEmpNumbers := ""

    cEmpNumbers := AllTrim(cEmpNumbers)
    aEmpNumbers := StrToKArr(cEmpNumbers, ";*-")

    If Empty(cEmpNumbers)
        lValid := .T.
    Else
        DbSelectArea("SRA")
        SRA->(DbSetOrder(1)) // "RA_FILIAL+RA_MAT+RA_NOME".

        For nI := 1 To Len(aEmpNumbers)
            If !Empty(aEmpNumbers[nI])

                If Len(aEmpNumbers[nI]) > nLenTabelNumber
                    lValid := .F.
                Else
                    SRA->(DbGoTop())
                    lValid := SRA->(DbSeek(FwXFilial("SRA") + PadR(aEmpNumbers[nI], nLenTabelNumber)))
                EndIf

                If !lValid
                    // "Error", "Error in the field", "TN", "Not found a record", "Select existed record"
                    Help( ,, STR0226,, STR0222 + " " + STR0028 + CRLF + STR0230 + ": " + aEmpNumbers[nI], 1,,,,,,, {STR0231})
                    Exit
                EndIf

            EndIf
        Next nI

        SRA->(DbCloseArea())
    EndIf

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return lValid

/*/{Protheus.doc} RU07D11017_ValidationCostCenter
    Function for validation of field "Cost Center".

    @type Function
    @param cCostCenter, Character, Cost Center.
    @author vselyakov
    @since 09.02.2024
    @version 12.1.2310
    @return Logical, Result of validation.
    @example "RU07D11017(MV_PAR08)"
/*/
Function RU07D11017_ValidationCostCenter(cCostCenter)
    Local lValid := .F. As Logical
    Local aCCCodes := {} As Array
    Local nI := 0 As Numeric
    Local aArea := GetArea() As Array
    Local aCTTArea := CTT->(GetArea()) As Array

    Default cCostCenter := ""

    cCostCenter := AllTrim(cCostCenter)
    aCCCodes := StrToKArr(cCostCenter, ";*-")

    If Empty(cCostCenter)
        lValid := .T.
    Else
        DbSelectArea("CTT")
        CTT->(DbSetOrder(1)) // "CTT_FILIAL+CTT_CUSTO".

        For nI := 1 To Len(aCCCodes)
            If !Empty(aCCCodes[nI])
                CTT->(DbGoTop())
                lValid := CTT->(DbSeek(FwXFilial("CTT") + PadR(aCCCodes[nI], TamSX3("CTT_CUSTO")[1])))

                If !lValid
                    // "Error", "Error in the field", "Cost center", "Not found a record", "Select existed record"
                    Help( ,, STR0226,, STR0222 + " " + STR0028 + CRLF + STR0230 + ": " + aCCCodes[nI], 1,,,,,,, {STR0231})
                    Exit
                EndIf
            EndIf
        Next nI
    EndIf

    CTT->(RestArea(aCTTArea))
    RestArea(aArea)

Return lValid

/*/{Protheus.doc} RU07D11018_ValidationRoles
    Function for validation of field "Role".

    @type Function
    @param cRoles, Character, Roles.
    @author vselyakov
    @since 09.02.2024
    @version 12.1.2310
    @return Logical, Result of validation.
    @example "RU07D11018(MV_PAR13)"
/*/
Function RU07D11018_ValidationRoles(cRoles)
    Local lValid := .F. As Logical
    Local aRoles := {} As Array
    Local nI := 0 As Numeric
    Local aArea := GetArea() As Array
    Local aSRJArea := SRJ->(GetArea()) As Array

    Default cRoles := ""

    cRoles := AllTrim(cRoles)
    aRoles := StrToKArr(cRoles, ";*-")

    If Empty(cRoles)
        lValid := .T.
    Else
        DbSelectArea("SRJ")
        SRJ->(DbSetOrder(1)) // "RJ_FILIAL+RJ_FUNCAO".
        
        For nI := 1 To Len(aRoles)
            If !Empty(aRoles[nI])
                SRJ->(DbGoTop())
                lValid := SRJ->(DbSeek(FwXFilial("SRJ") + PadR(aRoles[nI], TamSX3("RJ_FUNCAO")[1])))

                If !lValid
                    // "Error", "Error in the field", "Role", "Not found a record", "Select existed record"
                    Help( ,, STR0226,, STR0222 + " " + STR0229 + CRLF + STR0230 + ": " + aRoles[nI], 1,,,,,,, {STR0231})
                    Exit
                EndIf
            EndIf
        Next nI
    EndIf

    SRJ->(RestArea(aSRJArea))
    RestArea(aArea)

Return lValid

/*/{Protheus.doc} RU07D11019_ValidationFilials
    Function for validation of field "Filial".

    @type Function
    @param cBranches, Character, Filials.
    @author vselyakov
    @since 09.02.2024
    @version 12.1.2310
    @return Logical, Result of validation.
    @example "RU07D11019(MV_PAR07)"
/*/
Function RU07D11019_ValidationFilials(cBranch)
    Local lValid := .F. As Logical
    Local aBrances := {} As Array
    Local nI := 0 As Numeric
    Local aArea := GetArea() As Array
    Local aSM0Area := SM0->(GetArea()) As Array

    Default cBranch := ""

    cBranch := AllTrim(cBranch)
    aBrances := StrToKArr(AllTrim(cBranch), ";*-")

    If Empty(cBranch)
        lValid := .T.
    Else
        For nI := 1 To Len(aBrances)
            If !Empty(aBrances[nI])
                lValid := FwFilExist(cEmpAnt, aBrances[nI])

                If !lValid
                    // "Error", "Error in the field", "Filial", "Not found a record", "Select existed record"
                    Help( ,, STR0226,, STR0222 + " " + STR0228 + CRLF + STR0230 + ": " + aBrances[nI], 1,,,,,,, {STR0231})
                    Exit
                EndIf
            EndIf
        Next nI
    EndIf

    SM0->(RestArea(aSM0Area))
    RestArea(aArea)

Return lValid

/*/{Protheus.doc} RU07D11020_ValidationUnions
    Function for validation of field "Union".

    @type Function
    @param cUnions, Character, Unions.
    @author vselyakov
    @since 16.02.2024
    @version 12.1.2310
    @return Logical, Result of validation.
    @example "RU07D11020(MV_PAR09)"
/*/
Function RU07D11020_ValidationUnions(cUnions)
    Local lValid := .F. As Logical
    Local aUnions := {} As Array
    Local nI := 0 As Numeric
    Local aArea := GetArea() As Array
    Local aRCEArea := RCE->(GetArea()) As Array

    Default cUnions := ""

    cUnions := AllTrim(cUnions)
    aUnions := StrToKArr(cUnions, ";*-")

    If Empty(cUnions)
        lValid := .T.
    Else
        DbSelectArea("RCE")
        RCE->(DbSetOrder(1)) // "RCE_FILIAL+RCE_CODIGO".
        
        For nI := 1 To Len(aUnions)
            If !Empty(aUnions[nI])
                RCE->(DbGoTop())
                lValid := RCE->(DbSeek(FwXFilial("RCE") + PadR(aUnions[nI], TamSX3("RCE_CODIGO")[1])))

                If !lValid
                    // "Error", "Error in the field", "Trade union",, "Not found a record", "Select existed record"
                    Help( ,, STR0226,, STR0222 + " " + STR0131 + CRLF + STR0230 + ": " + aBrances[nI], 1,,,,,,, {STR0231})
                    Exit
                EndIf
            EndIf
        Next nI
    EndIf

    RCE->(RestArea(aRCEArea))
    RestArea(aArea)

Return lValid

/*/{Protheus.doc} RU07D11022_CheckIntegrationDate
    Function for validation of field "Reference date" on integration.

    @type Function
    @param dDateIntegration, Date, Reference date.
    @author vselyakov
    @since 15.04.2024
    @version 12.1.2310
    @return Logical, Result of validation.
    @example "RU07D11022(MV_PAR05)"
/*/
Function RU07D11022_CheckIntegrationDate(dDateIntegration)
    Local lResult := .T. As Logical

    Default dDateIntegration := CToD("//")

    If !Empty(dDateIntegration)
        If Day(dDateIntegration) < MIN_REFERENCE_DAY
            If !lAuto
                MsgStop(STR0227, STR0226) // "The specified date cannot be less than the 28th", "Error".
            Else
                ConOut("The specified date cannot be less than the 28th")
            EndIf

            lResult := .F.
        EndIf
    EndIf

Return lResult

/*/{Protheus.doc} GetF5ICountLines
    Function return F5I count lines for employee in selected period.

    @type Static Function
    @param cSRABranch, Character, Branch of employee.
    @param cSRANumber, Character, Personnel number of employee.
    @param cStartPeriod, Character, Start of selected period.
    @param cEndPeriod, Character, End of selected period.
    @author vselyakov
    @since 18.03.2024
    @version 12.1.2310
    @return Logical, Result of validation.
    @example ""
/*/
Static Function GetF5ICountLines(cSRABranch, cSRANumber, cStartPeriod, cEndPeriod)
    Local nCount := 0 As Numeric
    Local aArea := GetArea()
    Local cQuery := "" As Character
    Local oStatement := FWPreparedStatement():New() As Object
    Local cAlias := "" As Character
    
    cQuery := " SELECT COUNT(F5I_VB) AS RESCOUNT FROM " + RetSqlName("F5I") 
    cQuery += " WHERE                  "
    cQuery += "     D_E_L_E_T_ = ' '   "
    cQuery += "     AND F5I_FILIAL = ? "
    cQuery += "     AND F5I_MAT = ?    "
    cQuery += "     AND F5I_DATA >= ?  "
    cQuery += "     AND F5I_DATA <= ?  "
    
    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cSRABranch)
    oStatement:SetString(2, cSRANumber)
    oStatement:SetString(3, cStartPeriod)
    oStatement:SetString(4, cEndPeriod)
    
    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())
    
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
    
    nCount := (cAlias)->(RESCOUNT)
    
    (cAlias)->(DbCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)
    
    RestArea(aArea)

Return nCount

/*
*   For formulas.
*/

/*/{Protheus.doc} RU07D11021_GetRGBData
    Get payments from RGB if RGB_DTREF for previous period.

    @type Function
    @author vselyakov
    @since 16.03.2024
    @version 12.1.2310
    @return Logical, Result of getting a data.
    @example "RU07D11021_GetRGBData()"
/*/
Function RU07D11021_GetRGBData()
    Local aArea := GetArea() As Array
    Local aRGBArea := RGB->(GetArea()) As Array
    Local cActPeriod := "" As Character
    Local cActPaymentNumber := "" As Character
    Local lCanContinue := .T. As Logical
    Local lUsePLS := If(!Empty(TamSX3("RGB_LOTPLS")) .And. RGB->(ColumnPos("RGB_LOTPLS")) > 0, .T., .F.) As Logical
    Local nPosition := 0 As Numeric

    Pergunte(PERGUNTE_CALCULATION, .F.)

    cActPeriod := MV_PAR03
    cActPaymentNumber := MV_PAR04

    If Empty(cActPeriod) .Or. Empty(cActPaymentNumber)
        Help(' ', 1, 'PER_FECHADO')
        lCanContinue := .F.
    EndIf

    If lCanContinue
        DbSelectArea("RGB")
        RGB->(DbSetOrder(6)) // RGB_FILIAL+RGB_MAT+RGB_PERIOD+RGB_ROTEIR+RGB_SEMANA+RGB_PD
        
        If RGB->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cActPeriod + fGetCalcRot("1") + cActPaymentNumber))
            While !Eof() .And. RGB->RGB_FILIAL+RGB->RGB_MAT+RGB->RGB_PERIOD == SRA->RA_FILIAL+SRA->RA_MAT+cActPeriod
                If AnoMes(RGB->RGB_DTREF) == cPeriodo .And. RGB->RGB_PERIODO != cPeriodo
                    FMatriz(RGB->RGB_PD, RGB->RGB_VALOR, RGB->RGB_HORAS, RGB->RGB_SEMANA, RGB->RGB_CC, RGB->RGB_TIPO1, RGB->RGB_TIPO2, RGB->RGB_PARCEL, , RGB->RGB_DTREF,,RGB->RGB_SEQ,RGB->RGB_QTDSEM,,,RGB->RGB_NUMID,,RGB->RGB_IDCMPL, RGB->RGB_DTREF,,,,RGB->RGB_CONVOC,,If(lUsePLS,RGB_LOTPLS,""),If(lUsePLS,RGB_CODRDA,""))
                EndIf

                RGB->(DbSkip())
            End While
        EndIf
    EndIf

    // Find data from SRD like as payments 410.
    nPosition := aScan(aPdOld, {|x| x[1] == aCodFol[0007, 1]}) // Search payment 410 into old array aPd.

    If nPosition > 0
        aAdd(aPd, aClone(aPdOld[nPosition]))
    EndIf

    RGB->(RestArea(aRGBArea))
    RestArea(aArea)
Return lCanContinue


/* 
*   Another static functions.
*/

/*/{Protheus.doc} GetRetroPayments
    Get payments for retrocalculation.

    @type Static Function
    @author vselyakov
    @since 19.03.2024
    @version 12.1.2310
    @return Array, Payment is included in recalculation.
    @example "aRetroPayments := GetRetroPayments()"
/*/
Static Function GetRetroPayments()
    Local aPayments := {} As Array
    Local aArea := GetArea() As Array
    Local cQuery := "" As Character
    Local oStatement := FWPreparedStatement():New() As Object
    Local cAlias := "" As Character
    
    cQuery := " SELECT RV_RETROAP, RV_RETROAD FROM " + RetSqlName("SRV") 
    cQuery += " WHERE                  "
    cQuery += "     D_E_L_E_T_ = ' '   "
    cQuery += "     AND RV_FILIAL = ?  "
    cQuery += "     AND RV_COMPL_ = ?  "
    
    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FwXFilial("SRV"))
    oStatement:SetString(2, PAYMENT_FOR_RETRO)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())
    
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
    
    While (cAlias)->(!Eof())
        If !Empty((cAlias)->(RV_RETROAP))
            aAdd(aPayments, (cAlias)->(RV_RETROAP))
        EndIf

        If !Empty((cAlias)->(RV_RETROAD))
            aAdd(aPayments, (cAlias)->(RV_RETROAD))
        EndIf

        (cAlias)->(DbSkip())
    EndDo
    
    (cAlias)->(DbCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)
Return aPayments


/*/{Protheus.doc} CancelDeductionPayments
    Cancel deduction payments for removing 
    retrocalculation results.

    @type Static Function
    @author vselyakov
    @since 22.03.2024
    @version 12.1.2310
    @return Array, Array of deductions with canceled payments into F5D.
    @example "aTDCanceled := CancelDeductionPayments()"
/*/
Static Function CancelDeductionPayments(cBranch, cEmpNumber, cStartPeriod, cEndPeriod)
    Local aDeductions := {} As Array
    Local aArea := GetArea() As Array
    Local cQuery := "" As Character
    Local oStatement := FWPreparedStatement():New() As Object
    Local cAlias := "" As Character
    Local aMonthes := {} As Array
    Local dTmpDate := SToD(cStartPeriod + "01") As Date
    Local nI := 0 As Numeric
    Local nDiffMonth := DateDiffMonth(SToD(cEndPeriod + "01"), SToD(cStartPeriod + "01")) As Numeric

    // 1. Formation of an array of periods for data deletion.
    For nI := 0 To nDiffMonth
        aAdd(aMonthes, AnoMes(MonthSum(dTmpDate, nI)))
    Next nI

    // 2. Search F5D lines for retrocalculations in selected periods.
    cQuery := " SELECT F5D_COD, R_E_C_N_O_ AS RECNO FROM " + RetSqlName("F5D") 
    cQuery += " WHERE                                  "
    cQuery += "     D_E_L_E_T_ = ' '                   "
    cQuery += "     AND F5D_FILIAL = ?                 "
    cQuery += "     AND F5D_MAT = ?                    "
    cQuery += "     AND F5D_ROTEIR = ?                 "
    cQuery += "     AND F5D_PER IN (?)                 "
    cQuery += "     AND F5D_PER <> LEFT(F5D_DTVCPM, 6) "
        
    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cBranch)
    oStatement:SetString(2, cEmpNumber)
    oStatement:SetString(3, SALARY_SCENARIO_NAME)
    oStatement:SetIn(4, aMonthes)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())
        
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
        
    While (cAlias)->(!Eof())
        aAdd(aDeductions, {(cAlias)->F5D_COD, (cAlias)->RECNO})

        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())
    oStatement:Destroy()

    // 3. Update every F5D line: set F5D_CANCEL = '1' (canceled payment).
    cQuery := " UPDATE " + RetSqlName("F5D") + " SET F5D_CANCEL = ? WHERE R_E_C_N_O_ = ? "

    For nI := 1 To Len(aDeductions)
        // Update F5D line.
        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, TAX_DEDUCTION_CANCELED)
        oStatement:SetNumeric(2, aDeductions[nI, 2])

        // Execute SQL-query.
        If TcSqlExec(oStatement:GetFixQuery()) < 0
            ConOut("RU07D11RUS (CancelDeductionPayments): An error occurred when deleting data from tax deductions (F5D)")
        EndIf
    Next nI

    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)
Return aDeductions

/*/{Protheus.doc} F5IInsert
    The function writes to F5I data from the previous calculation that is not written during recalculation.
    This is due to the fact that when recording, a cycle goes through new types of payments, but some may not exist.

    @type Static Function
    @author vselyakov
    @since 15.04.2024
    @version 12.1.2310
    @return Array, Array of deductions with canceled payments into F5D.
    @example "F5IInsert(aNotFoundPayments[nI])"
/*/
Static Function F5IInsert(aPayment)
    Local lResult := .T. As Logical
    Local cRetroUse := "" As Character
    Local lRetroUse := .F. As Logical

    cRetroUse := RetValSRV(aPayment[1], SRA->RA_FILIAL, "RV_COMPL_")
    lRetroUse := cRetroUse == PAYMENT_FOR_RETRO

    If ValType(aPayment) == "A" .And. aPayment[9] != "D" .And. lRetroUse
        If RecLock("F5I", .T.)
            F5I->F5I_FILIAL := SRA->RA_FILIAL
            F5I->F5I_MAT := SRA->RA_MAT
            F5I->F5I_VB := aPayment[1]
            F5I->F5I_CC := aPayment[2]
            F5I->F5I_DATA := cPeriodo
            F5I->F5I_VERBA := RetValSRV(aPayment[1], SRA->RA_FILIAL, "RV_RETROAD")
            F5I->F5I_VL := aPayment[5]
            F5I->F5I_CALC := 0
            F5I->F5I_VALOR := (-1) * aPayment[5]
            F5I->F5I_COMPL_ := cRetroUse
            F5I->F5I_SEMANA := cSemPag
            F5I->F5I_MESANO := cMesAnoCalc
            F5I->F5I_TIPO1 := aPayment[6]
            F5I->F5I_TIPO2 := aPayment[7]
            F5I->F5I_HORAS := aPayment[4]
            F5I->F5I_SEQ := aPayment[11]
            F5I->F5I_DTPGT := aPayment[10]
            F5I->F5I_PROCES := cProcesso
            F5I->F5I_ROTEIR := "FOL"
            F5I->F5I_ITEM := aPayment[13]
            F5I->F5I_CLVL := aPayment[14]

            F5I->(MsUnlock())

            lResult := .T.
        Else
            lResult := .F.
        EndIf
    EndIf

Return lResult

/*/{Protheus.doc} RU07D11023_ExportToExcel
    Function for start a process for export data to Excel

    Variants for make this:
    * DlgToExcel (see https://udesenv.com.br/post/dlgtoexcel)
    * https://tdn.totvs.com/display/public/framework/FWMsExcel

    @type Function
    @author vselyakov
    @since 18.04.2024
    @version 12.1.2310
    @return Nil, Nil
    @example "RU07D11023"
/*/
Function RU07D11023_ExportToExcel()
    Local aArea := GetArea() As Array
    Local lHtml := (GetRemoteType() == 5) //Checks if the environment is SmartClientHtml

    If !lAuto
        If !lHtml
            MsgRun(STR0159, STR0225, {|| ExcelExport() }) // "Wait", "Export to Excel".
        Else
            MsgStop("Error to Excel export: can not start on WEB")
        EndIf
    EndIf

    RestArea(aArea)
Return

/*/{Protheus.doc} RU07D11023_ExportToExcel
    Function for export data of retrocalculation into Excel.

    Variants for make this:
    * DlgToExcel (see https://udesenv.com.br/post/dlgtoexcel)
    * https://tdn.totvs.com/display/public/framework/FWMsExcel

    @type Static Function
    @author vselyakov
    @since 23.04.2024
    @version 12.1.2310
    @return Nil, Nil
    @example "RU07D11023"
/*/
Static Function ExcelExport()
    Local aArea := GetArea() As Array
    Local aF5IArea := F5I->(GetArea()) As Array
    Local cQuery := "" As Character
    Local oPreparedStatement := Nil As Object
    Local oFWMsExcel := Nil As Object
    Local oExcel := Nil As Object
    Local cWorkSheet := STR0006 As Character
    Local cTitulo := STR0006 As Character
    Local cPath := "" As Character
    Local cFilter := "" As Character
    Local nResult := 0 As Numeric

    Pergunte(PERGUNTE_REPORT, .F.)
    MakeSQLExpr(PERGUNTE_REPORT)

    // Filial.
    If !Empty(MV_PAR02)
        cFilter += " AND " + MV_PAR02
    EndIf

    // Cost center.
    If !Empty(MV_PAR03)
        cFilter += " AND " + MV_PAR03
    EndIf

    // Personnel number.
    If !Empty(MV_PAR04)
        cFilter += " AND " + MV_PAR04
    EndIf

    If !Empty(MV_PAR05)
        cFilter += " AND F5I_MESANO = '" +  SubStr(MV_PAR05, 3, 4) + SubStr(MV_PAR05, 1, 2) + "'" // Month/Year.
    EndIf

    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet(cWorkSheet)
    oFWMsExcel:AddTable(cWorkSheet, cTitulo)

    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0228, 1, 1, .F.) // "Filial".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0028, 1, 1, .F.) // "Number employee".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0030, 1, 1, .F.) // "Name".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0014, 1, 1, .F.) // "Reference date".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0081, 1, 1, .F.) // "Payment number".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0012, 1, 1, .F.) // "Souce payment code".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0056, 1, 1, .F.) // "Description".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0013, 3, 2, .F.) // "Source value".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0015, 1, 1, .F.) // "Payment code".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0056, 1, 1, .F.) // "Description".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0017, 3, 2, .F.) // "Calculated value".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0018, 3, 2, .F.) // "Total value".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0218, 3, 2, .F.) // "Hours/Days".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0052, 1, 1, .F.) // "Selected".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0123, 1, 1, .F.) // "Integrated".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0139, 1, 1, .F.) // "Source scenario".
    oFWMsExcel:AddColumn(cWorkSheet, cTitulo, STR0200, 1, 1, .F.) // "Payment period".

    cQuery := "SELECT F5I.F5I_FILIAL, F5I.F5I_MAT, SRA.RA_NOMECMP NAME, F5I.F5I_DATA, F5I.F5I_SEMANA, F5I.F5I_VB, SRV.RV_DESC DESC1, F5I.F5I_VL, F5I.F5I_VERBA, SRV2.RV_DESC DESC2, F5I.F5I_CALC, F5I.F5I_VALOR, F5I.F5I_HORAS, F5I.F5I_COMPL_, F5I.F5I_INTEGR, F5I.F5I_ROTEIR, F5I.F5I_MESANO "
    cQuery += " FROM " + RetSQLName("F5I") + " AS F5I "
    cQuery += " LEFT JOIN " + RetSQLName("SRV") + " AS SRV ON SRV.RV_COD = F5I.F5I_VB "
    cQuery += " LEFT JOIN " + RetSQLName("SRV") + " AS SRV2 ON SRV2.RV_COD = F5I.F5I_VERBA "
    cQuery += " LEFT JOIN " + RetSQLName("SRA") + " AS SRA ON SRA.RA_FILIAL = F5I.F5I_FILIAL AND SRA.RA_MAT = F5I.F5I_MAT "
    cQuery += " WHERE F5I.D_E_L_E_T_ = ' ' "
    cQuery += cFilter

    oPreparedStatement := FWPreparedStatement():New(cQuery)
    cAlias := MPSysOpenQuery(oPreparedStatement:GetFixQuery())
        
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
        
    While (cAlias)->(!Eof())
        oFWMsExcel:AddRow(cWorkSheet, cTitulo, { ;
            (cAlias)->F5I_FILIAL                ,;
            (cAlias)->F5I_MAT                   ,;
            AllTrim((cAlias)->NAME)             ,;
            (cAlias)->F5I_DATA                  ,;
            (cAlias)->F5I_SEMANA                ,;
            (cAlias)->F5I_VB                    ,;
            AllTrim((cAlias)->DESC1)            ,;
            (cAlias)->F5I_VL                    ,;
            (cAlias)->F5I_VERBA                 ,;
            AllTrim((cAlias)->DESC2)            ,;
            (cAlias)->F5I_CALC                  ,;
            (cAlias)->F5I_VALOR                 ,;
            (cAlias)->F5I_HORAS                 ,;
            Iif((cAlias)->F5I_COMPL_ == PAYMENT_FOR_RETRO, STR0043, STR0044)     ,; // "Yes", "No".
            Iif((cAlias)->F5I_INTEGR == PAYMENT_IS_INTEGRATED, STR0043, STR0044) ,; // "Yes", "No".
            (cAlias)->F5I_ROTEIR                ,;
            (cAlias)->F5I_MESANO                 ;
        })

        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())
    oPreparedStatement:Destroy()
    FwFreeObj(oPreparedStatement)

    // Activating the file and generating the xml.
    cPath := cGetFile(, , 0, "", .F., nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE, 128, 256),.T., .T. )

    If !Empty(cPath)
        cPath += "retrocalculation_" + FwTimeStamp(1) + ".xls"

        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cPath)
        oFWMsExcel:DeActivate()

        // Opening excel and opening the xml file.
        If GetRemoteType() == 2 // Linux
            cPath := StrTran(cPath, "\", "/")
            nResult := ShellExecute("open", "xdg-open", StrToKArr(cPath, ":")[2], "/", 1)

            If nResult != 0
                MsgAlert("Cannot run file: " + Str(nResult), STR0226) // "Cannot run file", "Error".
            EndIf
        ElseIf GetRemoteType() == 1 // Windows
            oExcel := MsExcel():New()
            oExcel:WorkBooks:Open(cPath)
            oExcel:SetVisible(.T.)
            oExcel:Destroy()
        EndIf
    EndIF

    F5I->(RestArea(aF5IArea))
    RestArea(aArea)
Return
