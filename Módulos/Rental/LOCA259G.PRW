#INCLUDE "LOCA259G.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "MSMGADD.CH"

/*/{Protheus.doc} LOCA259G
Visualização dos documento e responsabilidades x Demandas
@author Frank Zwarg Fuga
@since 23/04/2025
/*/
FUNCTION LOCA259G()
    FWExecView("",'LOCA259G', MODEL_OPERATION_VIEW, , { || .T. }  )
Return NIL

/*/{Protheus.doc} ModelDef
Declaração do modelo de dados
@author Frank Zwarg Fuga
@since 23/04/2025
/*/

Static Function ModelDef()
Local oModel    := Nil
Local oStPai    := FWFormStruct(1, "FQT")
Local oStFilh1  := FWFormStruct(1, "FP6")
Local oStFilh2  := FWFormStruct(1, "FPB")

    oModel := MPFormModel():New("LOCA259G")
    
    oModel:AddFields("MASTER",,oStPai)
    oModel:AddGrid("FP6DETAIL","MASTER",oStFilh1)
    oModel:AddGrid("FPBDETAIL","MASTER",oStFilh2)

    oModel:SetPrimaryKey({})

    oModel:GetModel("MASTER"):SetDescription(STR0002) // "Demanda"
    oModel:GetModel("FPBDETAIL"):SetDescription(STR0004) // "Documentos"
    oModel:GetModel("FP6DETAIL"):SetDescription(STR0003) // "Responsabilidades"
    // Setando o Relacionamento Lembrar para tirar
    oModel:SetRelation( "FPBDETAIL", { { 'FPB_FILIAL', 'xFilial("FPB")' } ,{"FPB_PROJET","FQT_PROJET"},{"FPB_OBRA","FQT_OBRA"}}, FPB->( IndexKey( 1 ) ) )
    oModel:SetRelation( "FP6DETAIL", { { 'FP6_FILIAL', 'xFilial("FP6")' } ,{"FP6_PROJET","FQT_PROJET"},{"FP6_OBRA","FQT_OBRA"}}, FP6->( IndexKey( 1 ) ) )

    oModel:GetModel('FP6DETAIL'):SetOptional(.T.)
    oModel:GetModel('FPBDETAIL'):SetOptional(.T.)

Return oModel

/*/{PROTHEUS.DOC} ViewDef
ITUP BUSINESS - TOTVS RENTAL
@AUTHOR FRANK ZWARG FUGA
@SINCE 24/04/2025
/*/

Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel("LOCA259G")
Local oStPai     := FWFormStruct(2, "FQT")
Local oStFilh1   := FWFormStruct(2, "FP6")
Local oStFilh2   := FWFormStruct(2, "FPB")
Local bPreenche2 := {|| LOCA259G1()}
Local bPreenche1 := {|| LOCA259G2()}

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField("VIEW_FQT",oStPai,"MASTER")
    oView:AddGrid("VIEW_FP6",oStFilh1,"FP6DETAIL")
    oView:AddGrid("VIEW_FPB",oStFilh2,"FPBDETAIL")
    
    oModel:SetDescription(STR0001) // "Documentos e Responsabilidades"
    
    oView:CreateHorizontalBox( 'CABEC', 00)	
    oView:CreateHorizontalBox( 'BOX3', 100)
    
    oView:CreateFolder( 'FOLDER1', 'BOX3')	
    
    oView:AddSheet('FOLDER1','SHEET1', STR0004, bPreenche1 ) // "Documentos"
    oView:AddSheet('FOLDER1','SHEET2', STR0003, bPreenche2 ) // "Responsabilidades"
    
    oView:CreateHorizontalBox( 'PASTA1A', 100, , , 'FOLDER1', 'SHEET1') 
    oView:CreateHorizontalBox( 'PASTA1B', 100, , , 'FOLDER1', 'SHEET2') 
        
    oView:SetOwnerView('VIEW_FQT','CABEC') 
    oView:SetOwnerView('VIEW_FPB','PASTA1A')
    oView:SetOwnerView('VIEW_FP6','PASTA1B')
    

    oView:cdescription := STR0005 // "Visualizar"

Return oView


/*/{PROTHEUS.DOC} LOCA259G1
ITUP BUSINESS - TOTVS RENTAL
Alimenta a grid das responsabilidades
Frank Z Fuga
24/09/2024
/*/

Function LOCA259G1
	Processa({||LOCA259GX()},STR0006) // "Aguarde... localizando os registros"
Return

/*/{PROTHEUS.DOC} LOCA259G2
ITUP BUSINESS - TOTVS RENTAL
Alimenta a grid dos documentos
Frank Z Fuga
24/09/2024
/*/

Function LOCA259G2
	Processa({||LOCA259GY()},STR0006) // "Aguarde... localizando os registros"
Return

/*/{PROTHEUS.DOC} LOCA259GX
ITUP BUSINESS - TOTVS RENTAL
Alimenta a grid das responsabilidades
Frank Z Fuga
24/09/2024
/*/

Function LOCA259GX
Local oModel := FWModelActive()
Local oModelFP6 := oModel:GetModel("FP6DETAIL")
Local oView := FWViewActive() 
Local aStruct := {} 
Local nX
Local cCampo
Local cVirtual
Local aCampos := {}
Local cDemand := FQT->FQT_DEMAND
Local cObra := FQT->FQT_OBRA
Local aBindParam := {}
Local aResult := {}
Local nY
Local lFirst := .T.
Local cQuery := ""

    oModel:DEActivate()
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

	ProcRegua(0)

    If empty(cDemand)
        Return
    EndIf

    aStruct := FWSX3Util():GetListFieldsStruct( "FP6" , .T.)
    For nX := 1 to len(aStruct)
        IncProc()
        cCampo := GetSx3Cache(alltrim(aStruct[nX][01]),"X3_CAMPO")
        cVirtual := GetSx3Cache(alltrim(aStruct[nX][01]),"X3_CONTEXT")
        If (x3Uso(GetSx3Cache(alltrim(aStruct[nX][01]),"X3_USADO")) .and. cVirtual <> "V") 
            aadd(aCampos,{cCampo})
        EndIF
    Next  

	oModelFP6:ClearData()

    If select("TRBFQ5") > 0
        TRBFQ5->(dbCloseArea())
    EndIf
    cQuery := " SELECT FQ5.FQ5_SOT, FQ5.FQ5_OBRA, FQ5.FQ5_SEQVIA "
    cQuery += " FROM " + RETSQLNAME("FQ5") + " FQ5 "
    cQuery += " WHERE FQ5.D_E_L_E_T_ = ' ' AND FQ5.FQ5_DEMAND = ? "
    cQuery += " AND FQ5.FQ5_OBRA = ? AND FQ5.FQ5_FILIAL = '"+xFilial("FQ5")+"' "
    Aadd( aBindParam, cDemand )
    Aadd( aBindParam, cObra )
    cQuery := CHANGEQUERY(cQuery)
    MPSysOpenQuery(cQuery,"TRBFQ5",,,aBindParam)

    While !TRBFQ5->(Eof())
        IncProc()
        aadd(aResult,{TRBFQ5->FQ5_SOT, TRBFQ5->FQ5_OBRA, TRBFQ5->FQ5_SEQVIA})
        TRBFQ5->(dbSkip())
	EndDo
    TRBFQ5->(dbCloseArea())

    For nX := 1 to len(aResult)
        IncProc()
        FP6->(dbSetOrder(2))
        If FP6->(dbSeek(xFilial("FP6")+aResult[nX,1]+aResult[nX,2]+aResult[nX,3]))
            While !FP6->(Eof()) .and. FP6->(FP6_FILIAL+FP6_PROJET+FP6_OBRA+FP6_SEQGUI) == xFilial("FP6")+aResult[nX,1]+aResult[nX,2]+aResult[nX,3]

                If !lFirst
                    oModelFP6:AddLine()
                    oModelFP6:GoLine(oModelFP6:Length())
                EndIf

                For nY := 1 to len(aCampos)
                    oModelFP6:LoadValue( aCampos[nY,1], &("FP6->"+aCampos[nY,1]) )
                Next

                lFirst := .F.

                FP6->(dbSkip())
            EndDo
        EndIf
    Next

	oModelFP6:GoLine(1)
	oView:Refresh()
	IncProc()

    oModel:DEActivate()
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

Return

/*/{PROTHEUS.DOC} LOCA259GY
ITUP BUSINESS - TOTVS RENTAL
Alimenta a grid dos documentos
Frank Z Fuga
24/09/2024
/*/

Function LOCA259GY
Local oModel := FWModelActive()
Local oModelFPB := oModel:GetModel("FPBDETAIL")
Local oView := FWViewActive() 
Local aStruct := {} 
Local nX
Local cCampo
Local cVirtual
Local aCampos := {}
Local cProjet := FQT->FQT_PROJET
Local cObra := FQT->FQT_OBRA
Local aBindParam := {}
Local nY
Local lFirst := .T.
Local cQuery := ""

    oModel:DEActivate()
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

	ProcRegua(0)

    aStruct := FWSX3Util():GetListFieldsStruct( "FPB" , .T.)
    For nX := 1 to len(aStruct)
        IncProc()
        cCampo := GetSx3Cache(alltrim(aStruct[nX][01]),"X3_CAMPO")
        cVirtual := GetSx3Cache(alltrim(aStruct[nX][01]),"X3_CONTEXT")
        If (x3Uso(GetSx3Cache(alltrim(aStruct[nX][01]),"X3_USADO")) .and. cVirtual <> "V") 
            aadd(aCampos,{cCampo})
        EndIF
    Next  

	oModelFPB:ClearData()

    If select("TRBFPB") > 0
        TRBFPB->(dbCloseArea())
    EndIf
    cQuery := " SELECT FPB.R_E_C_N_O_ REG "
    cQuery += " FROM " + RETSQLNAME("FPB") + " FPB "
    cQuery += " WHERE FPB.D_E_L_E_T_ = ' ' AND FPB.FPB_PROJET = ? "
    cQuery += " AND FPB.FPB_OBRA = ? AND FPB.FPB_FILIAL = '"+xFilial("FPB")+"' "
    Aadd( aBindParam, cProjet )
    Aadd( aBindParam, cObra )
    cQuery := CHANGEQUERY(cQuery)
    MPSysOpenQuery(cQuery,"TRBFPB",,,aBindParam)

    While !TRBFPB->(Eof())
        IncProc()
        FPB->(dbGoto(TRBFPB->REG))

        If !lFirst
            oModelFPB:AddLine()
            oModelFPB:GoLine(oModelFPB:Length())
        EndIf

        For nY := 1 to len(aCampos)
            oModelFPB:LoadValue( aCampos[nY,1], &("FPB->"+aCampos[nY,1]) )
        Next

        lFirst := .F.

        TRBFPB->(dbSkip())
	EndDo
    TRBFPB->(dbCloseArea())

	oModelFPB:GoLine(1)
	oView:Refresh()
	IncProc()

    oModel:DEActivate()
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

Return
