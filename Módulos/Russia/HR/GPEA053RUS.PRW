#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA053.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} GPEA053RUS
    Mass vacation schedule (Russia).

    @type Function
    @version 12.1.2310
    @author vselyakov
    @since 13.05.2024
/*/
Function GPEA053RUS()
    Local nPercReduc:= 15 As Numeric
    Local cPergunte	:= "GPEA053" As Character
    Local oModelAct	:= Nil As Object

    Private lCanEdit:= .T. As Logical
    
    If Pergunte(cPergunte,.T.)
        oModelAct := ModelDef() 
        oModelAct:SetOperation(MODEL_OPERATION_INSERT)
        oModelAct:Activate()

        If(OnLoad(oModelAct:GetModel('SRADETAIL')))
            lCanEdit := .F.
            oModelAct:LoadValue('GPEA050_SRF','RF_DATAINI',Date())
            oModelAct:LoadValue('GPEA050_SRF','RF_DATAINI',cToD("//"))
            oModelAct:GetModel("SRADETAIL"):lInsertLine := .F.

            FWExecView(STR0002, 'GPEA053', MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.}, /*bOk*/, nPercReduc, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, oModelAct)
        Else
            // "Invalid filter.", "Display data absent"
            Help( ,, STR0004,, STR0005, 1, 0)
        EndIf
    EndIf
Return


/*/{Protheus.doc} ModelDef
    Defenition of model for routine.

    @type Function
    @version 12.1.2310
    @author vselyakov
    @since 13.05.2024
    @return Object, ModelDef of GPEM030 routine.
/*/
Static Function ModelDef()
    Local cCampos := "RF_DATAINI|RF_DFEPRO1|RF_DABPRO1|RF_DATINI2|RF_DFEPRO2|RF_DABPRO2|RF_DATINI3|RF_DFEPRO3|RF_DABPRO3|RF_DATINI4|RF_DFEPRO4|RF_DABPRO4|RF_DATINI5|RF_DFEPRO5|RF_DABPRO5|RF_DATINI6|RF_DFEPRO6|RF_DABPRO6|RF_TEMABPE|RF_ABOPEC" As Character
    Local oStructMst := FWFormStruct(1, "SRF", {|x| AllTrim(x) $ cCampos}) As Obejct
    Local oStructGrd := FWFormStruct(1, "SRA", {|x| AllTrim(x) $ "RA_FILIAL|RA_MAT|RA_NOME|RA_CC|RA_DEPTO"}) As Obejct
    Local oModel := Nil As Obejct
    Local bCommit := {|x| OnCommit(x)} As Object

    oStructGrd:SetProperty("*" , MODEL_FIELD_WHEN, {|| CanEdit()})

    oStructGrd:AddField(STR0006, STR0006, "RA_DESCCC", "C", TamSx3("CTT_DESC01")[1], 0, {||.T.}, /*bWhen*/, /*aValues*/, /*lObrigat*/, /*bInit*/, /*lKey*/, .T., .T.)
    oStructGrd:AddField(STR0007, STR0007, "RA_DDEPTO", "C", TamSx3("QB_DESCRIC")[1], 0, {||.T.}, {||}, /*aValues*/, /*lObrigat*/, /*bInit*/, /*lKey*/, .T., .T.)

    oModel := MPFormModel():New("GPEA053RUS", /*bPreValidacao*/, /*bPosValidacao*/, bCommit, /*bCancel*/ )
    oModel:AddFields("GPEA050_SRF", /*cOwner*/, oStructMst)
    oModel:AddGrid("SRADETAIL", "GPEA050_SRF", oStructGrd, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/)
    oModel:SetRelation("SRADETAIL", {{"RA_FILIAL", "RF_FILIAL"}, {"RA_MAT", "RF_MAT"}}, SRA->(IndexKey(1))) // Generic relationship. Record loading is done by the question group.
    oModel:SetPrimaryKey({})

    oModel:SetDescription(STR0001) // "Planned vacation in couples.".
Return oModel


/*/{Protheus.doc} ViewDef
    Defenition of view for routine.

    @type Function
    @version 12.1.2310
    @author vselyakov
    @since 13.05.2024
    @return Object, ViewDef of GPEM030 routine.
/*/
Static Function ViewDef()
    Local cCampos := "RF_DATAINI|RF_DFEPRO1|RF_DABPRO1|RF_DATINI2|RF_DFEPRO2|RF_DABPRO2|RF_DATINI3|RF_DFEPRO3|RF_DABPRO3|RF_DATINI4|RF_DFEPRO4|RF_DABPRO4|RF_DATINI5|RF_DFEPRO5|RF_DABPRO5|RF_DATINI6|RF_DFEPRO6|RF_DABPRO6|RF_TEMABPE|RF_ABOPEC" As Character
    Local oStructMst := FWFormStruct(2, "SRF" ,{|x| AllTrim(x) $ cCampos}) As Obejct
    Local oModel := FWLoadModel("GPEA053RUS") As Object
    Local oView := Nil As Object
    Local oStructGrd := Nil As Object

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oStructGrd := FWFormStruct(2, "SRA", {|x| AllTrim(x) $ "RA_FILIAL|RA_MAT|RA_NOME|RA_CC|RA_DEPTO"})

    oStructGrd:AddField("RA_FILIAL", "01", STR0008, STR0008, NIL, "C", "@!", NIL , "", .F., "", "", {}, 0, "", .F.) // "Branch", "Branch".
    oStructGrd:AddField("RA_DESCCC", "05", STR0006, STR0006, NIL, "C", "@!", NIL , "", .F., "", "", {}, 0, "", .F.) // "Desc. CC", "Desc. CC".
    oStructGrd:AddField("RA_DDEPTO", "06", STR0007, STR0007, NIL, "C", "@!", NIL , "", .F., "", "", {}, 0, "", .F.) // "Dept. Desc.", "Dept. Desc.".

    oStructGrd:SetProperty("RA_FILIAL", MVC_VIEW_ORDEM, "01")
    oStructGrd:SetProperty("RA_MAT",    MVC_VIEW_ORDEM, "02")
    oStructGrd:SetProperty("RA_NOME",   MVC_VIEW_ORDEM, "03")
    oStructGrd:SetProperty("RA_CC",     MVC_VIEW_ORDEM, "04")
    oStructGrd:SetProperty("RA_DESCCC", MVC_VIEW_ORDEM, "05")
    oStructGrd:SetProperty("RA_DEPTO",  MVC_VIEW_ORDEM, "06")
    oStructGrd:SetProperty("RA_DDEPTO", MVC_VIEW_ORDEM, "07")

    oView:AddField("VIEW_MASTER", oStructMst, "GPEA050_SRF")
    oView:AddGrid("VIEW_GRID", oStructGrd, "SRADETAIL")
    oView:EnableTitleView("VIEW_GRID", STR0003) // "Filtered Employees".

    oView:CreateHorizontalBox("SUPERIOR", 30)
    oView:CreateHorizontalBox("INFERIOR", 70)
    oView:SetOwnerView("VIEW_MASTER", "SUPERIOR")
    oView:SetOwnerView("VIEW_GRID", "INFERIOR")
Return oView

/*/{Protheus.doc} OnLoad
    Load records into the Model Grid

    @type Static Function
    @version 12.1.2310
    @author vselyakov
    @since 13.05.2024
    @return Logical, Result of loading.
/*/
Static Function OnLoad(oGridModel)
    Local aArea := GetArea() As Array
    Local cMyAlias := GetNextAlias() As Character
    Local cQuery := "" As Character
    Local nLine := 0 As Numeric
    Local lResult := .T. As Logical
    Local nI := 0 As Numeric
    Local cIn := "" As Character
    Local nTam := 1 As Numeric

    cQuery := " SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, RA_DEPTO, CTT_DESC01 AS RA_DESCCC, QB_DESCRIC AS RA_DDEPTO FROM " + RetSqlName("SRA") + " SRA" 
    cQuery += " INNER JOIN "+ RetSqlName("CTT") + " CTT ON(" + FWJoinFilial("CTT", "SRA") + " AND CTT_CUSTO = SRA.RA_CC AND CTT.D_E_L_E_T_ = '')" 
    cQuery += " LEFT  JOIN "+ RetSqlName("SQB") + " SQB ON(" + FWJoinFilial("SQB", "SRA") + " AND QB_DEPTO = SRA.RA_DEPTO AND SQB.D_E_L_E_T_ = '')"
    cQuery += " WHERE SRA.D_E_L_E_T_ = '' "

    If !(Empty(MV_PAR01) .And. Empty(MV_PAR02))
        cQuery += " AND RA_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
    EndIf

    If !(Empty(MV_PAR03) .And. Empty(MV_PAR04))
        cQuery += " AND RA_CC BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'"
    EndIf

    If !(Empty(MV_PAR05) .And. Empty(MV_PAR06))
        cQuery += " AND RA_DEPTO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "'"	
    EndIf

    If !(Empty(MV_PAR07) .And. Empty(MV_PAR08))
        cQuery += " AND RA_MAT BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
    EndIf

    cIn := ""
    nTam := TamSx3("RA_CATFUNC")[1]

    For nI := 1 To Len(MV_PAR09)
        cIn += "'" + SubStr(MV_PAR09, nI, nTam) + "'"

        If (nI < Len(MV_PAR09))
            cIn += ","
        EndIf
    Next nI

    cQuery += " AND RA_CATFUNC IN(" + cIn + ")"

    cIn := ""
    nTam := TamSx3("RA_SITFOLH")[1]

    For nI := 1 To Len(MV_PAR10)
        cIn += "'"+ SubStr(MV_PAR10, nI, nTam) + "'"
        
        If (nI < Len(MV_PAR10))
            cIn += ","
        EndIf
    Next nI

    cQuery += " AND RA_SITFOLH IN(" + cIn + ")"
    cQuery += " ORDER BY RA_FILIAL,RA_MAT,RA_CC"

    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMyAlias, .F., .T.)

    If ((cMyAlias)->(!Eof()))
        While ((cMyAlias)->(!Eof()))

            If (nLine == 0)
                nLine++
            Else
                nLine := oGridModel:AddLine()
            EndIf

            oGridModel:GoLine(nLine)

            If (nLine > 0)
                oGridModel:GoLine(nLine)
                oGridModel:LoadValue("RA_FILIAL", (cMyAlias)->RA_FILIAL)
                oGridModel:LoadValue("RA_MAT",    (cMyAlias)->RA_MAT)
                oGridModel:LoadValue("RA_NOME",   (cMyAlias)->RA_NOME)
                oGridModel:LoadValue("RA_CC",     (cMyAlias)->RA_CC)
                oGridModel:LoadValue("RA_DEPTO",  (cMyAlias)->RA_DEPTO)
                oGridModel:LoadValue("RA_DESCCC", (cMyAlias)->RA_DESCCC)
                oGridModel:LoadValue("RA_DDEPTO", (cMyAlias)->RA_DDEPTO)
            EndIf

            (cMyAlias)->(DbSkip())
        End
    Else 
        lResult := .F.
    EndIf

    (cMyAlias)->(DbCloseArea())

    RestArea(aArea)
Return lResult

/*/{Protheus.doc} OnCommit
    Saves changes to the database.

    @type Static Function
    @version 12.1.2310
    @author vselyakov
    @since 13.05.2024
    @return lResult, .T. if saved successfully.
/*/
Static Function OnCommit(oModel)
    Local aArea := GetArea() As Array
    Local oGrid := oModel:GetModel("SRADETAIL") As Object
    Local nI := 0 As Numeric
    Local lResult := .T. As Logical
    Local cChave := "" As Character
    Local oHead := oModel:GetModel("GPEA050_SRF") As Object
    Local aCampos := {} As Array
    Local aLogErros := {} As Array
    Local aLog := {} As Array
    Local aTitleLog := {} As Array
    Local nX := 0 As Numeric
    Local lGrava := .T. As Logical
    Local lProg1 := .T. As Logical
    Local lProg2 := .T. As Logical
    Local lProg3 := .T. As Logical
    Local lNsobrepoe := ValType(MV_PAR11) <> "N" .or. (ValType(MV_PAR11) == "N" .and. MV_PAR11 == 2) As Logical

    aCampos := oHead:GetStruct()
    aCampos := aCampos:GetFields()

    SRF->(DbSetOrder(1)) // "RF_FILIAL+RF_MAT+DTOS(RF_DATABAS)+RF_PD".

    For nI := 1 To oGrid:Length()
        oGrid:GoLine(nI)

        If (!oGrid:IsDeleted())
            cChave := oGrid:GetValue("RA_FILIAL")
            cChave += oGrid:GetValue("RA_MAT")
            
            If (SRF->(dbSeek(cChave))) 
                While SRF->(!EoF()) .And. cChave == SRF->RF_FILIAL + SRF->RF_MAT 
                    If SRF->RF_STATUS == "1"
                        lProg1 := .T.
                        lProg2 := .T.
                        lProg3 := .T.
                        lGrava := .T.
                    
                        If lNsobrepoe // do not overlap.
                            // If the date of the new schedule clashes with the existing schedule, you should not carry out the new schedule.
                            If !Empty(SRF->RF_DATAINI) .And. !Empty(oHead:GetValue("RF_DATAINI"))
                                aAdd(aLogErros, SRF->RF_MAT + Chr(13) + Chr(10) + STR0014 + Chr(13) + Chr(10) + STR0013 + Chr(13) + Chr(10)) // "Schedule 1", "New schedule does not match the existing schedule.".
                                lProg1 := .F.
                            EndIf

                            If !Empty(SRF->RF_DATINI2) .And. !Empty(oHead:GetValue("RF_DATINI2"))
                                aAdd(aLogErros, SRF->RF_MAT + Chr(13) + Chr(10) + STR0015 + Chr(13) + Chr(10) + STR0013 + Chr(13) + Chr(10))  // "Schedule 2", "New schedule does not match the existing schedule.".
                                lProg2 := .F.
                            EndIf

                            If !Empty(SRF->RF_DATINI3) .And. !Empty(oHead:GetValue("RF_DATINI3"))
                                aAdd(aLogErros, SRF->RF_MAT + Chr(13) + Chr(10) + STR0016 + Chr(13) + Chr(10) + STR0013 + Chr(13) + Chr(10)) // "Schedule 3", "New schedule does not match the existing schedule.".
                                lProg3 := .F.
                            EndIf
                        EndIf

                        If lProg1 .Or. lProg2 .Or. lProg3
                            lGrava := .T.
                        Else
                            lGrava := .F.
                        EndIf

                        If oHead:GetValue("RF_DATAINI") <= SRF->RF_DATABAS
                            aAdd(aLogErros, SRF->RF_MAT + Chr(13) + Chr(10) + STR0009 + Chr(13) + Chr(10)) // "The Start Date of the schedule must be later than the Start Date of the Period"
                            lGrava := .F.
                        EndIf

                        If (oHead:GetValue("RF_DFEPRO1") + oHead:GetValue("RF_DABPRO1") + oHead:GetValue("RF_DFEPRO2") + oHead:GetValue("RF_DABPRO2") + oHead:GetValue("RF_DFEPRO3") + oHead:GetValue("RF_DABPRO3")) + SRF->RF_DFERANT > 30
                            aAdd(aLogErros, SRF->RF_MAT + Chr(13) + Chr(10) + STR0010 + Chr(13) + Chr(10)) // "The number of vacation days and bonus days for the three schedules exceeds 30 days."
                            lGrava := .F.
                        EndIf

                        If lGrava
                            RecLock("SRF", .F.)
                            
                            For nX := 1 To Len(aCampos)
                                If (aCampos[nX][3] == "RF_DATAINI" .or. aCampos[nX][3] == "RF_DFEPRO1") 
                                    If lProg1
                                        SRF->&(aCampos[nX][3]) := oHead:GetValue(aCampos[nX][3])
                                    EndIf
                                ElseIf (aCampos[nX][3] == "RF_DATINI2" .or. aCampos[nX][3] == "RF_DFEPRO2")  
                                    If lProg2
                                        SRF->&(aCampos[nX][3]) := oHead:GetValue(aCampos[nX][3])
                                    EndIf
                                ElseIf (aCampos[nX][3] == "RF_DATINI3" .or. aCampos[nX][3] == "RF_DFEPRO3")
                                    If lProg3
                                        SRF->&(aCampos[nX][3]) := oHead:GetValue(aCampos[nX][3])
                                    EndIf
                                Else
                                    SRF->&(aCampos[nX][3]) := oHead:GetValue(aCampos[nX][3])
                                EndIf
                            Next nX

                            SRF->(MsUnLock())
                        EndIf

                        Exit
                    EndIf

                    SRF->(DbSkip())
                End While
            EndIf
        EndIf
    Next nI
    
    
    If Len(aLogErros) > 0
        If Empty(aLog)
            aAdd(aTitleLog, STR0011) // "Unchanged registrations:".
            aAdd(aLog, {})
        EndIf
    
        nPosLog := Len(aLog)

        For nX := 1 To Len(aLogErros)
            aAdd(aLog[nPosLog], aLogErros[nX])
        Next nX
    EndIf
        
    If !Empty(aLog)
        MsAguarde({|| fMakeLog(aLog, aTitleLog, "GPEA053RUS", NIL, FunName(), STR0001)})
    EndIf
    
    RestArea(aArea)
Return lResult

/*/{Protheus.doc} CanEdit
    Evaluates whether it is possible to change the grid cells or not.

    @type Static Function
    @version 12.1.2310
    @author vselyakov
    @since 13.05.2024
    @return lResult, True if it is possible to edit.
/*/
Static Function CanEdit()
    Local lResult := .T. As Logical

    If !(ValType("lCanEdit") == "U") // If the model is called from elsewhere!
        lResult := lCanEdit
    EndIf
Return lResult
