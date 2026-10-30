
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA919.ch'

Static __aRetCbx As Array

/*/{Protheus.doc} FINA919
Cria tela responsavel por realizar a amarracao entre tipo de negociacao e situacao de cobranca.

@author Cesar Almeida
@since 19/01/2026
@version 2510
/*/
Function FINA919()

    Local aArea     As Array
    Local oBrowse   As Object     

    aArea   := FwGetArea()
    oBrowse := FWMBrowse():New()         

    oBrowse:SetAlias("F7U") 
    oBrowse:SetDescription(STR0001) // Cadastro Tipo de Negociacao vs Situacao de Cobranca
     
    oBrowse:AddLegend( "F7U->F7U_BAIXA == '1'", "GREEN",    "Sim" )
    oBrowse:AddLegend( "F7U->F7U_BAIXA == '2'", "RED",      "Não" )
     
    oBrowse:Activate()
     
    FwRestArea(aArea)

Return Nil
 
//-------------------------------------------------------------------

Static Function MenuDef()

    Local aRot As Array

    aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.FINA919' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.FINA919' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.FINA919' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.FINA919' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
//-------------------------------------------------------------------
 
Static Function ModelDef()

    Local oModel    As Object 
    Local oStF7U    As Object 
    Local aTrigger  As Array 
    Local bVldPos   As Block

    bVldPos := {||F919VldNeg() }

    oModel   := MPFormModel():New("FINA919",/*bPre*/, bVldPos,/*bCommit*/,/*bCancel*/)
    oStF7U   := FWFormStruct(1, "F7U")    
    aTrigger := FwStruTrigger("F7U_TPNEG" ,"F7U_DESCNE" ,'F919RetCbx(FwFldGet("F7U_TPNEG"))',.F.,,,)

    oStF7U:AddTrigger( aTrigger[1], aTrigger[2], aTrigger[3], aTrigger[4] )
     
    oModel:AddFields("FORMF7U",/*cOwner*/,oStF7U)    
    oModel:SetPrimaryKey({'F7U_FILIAL','F7U_TPNEG','F7U_SITUAC'})
    oModel:SetDescription(STR0001)     
    oModel:GetModel("FORMF7U"):SetDescription(STR0002) //Tipo de Negociacao vs Situacao de Cobranca

Return oModel
 
//-------------------------------------------------------------------
 
Static Function ViewDef()

    Local oModel As Object  
    Local oStF7U As Object 
    Local oView  As Object

    oModel := FWLoadModel("FINA919")     
    oStF7U := FWFormStruct(2, "F7U")  
    oView  := FWFormView():New()

    oStF7U:SetProperty("F7U_TPNEG", 13, F919RetCbx())
    
    oView:SetModel(oModel)     
    oView:AddField("VIEW_F7U", oStF7U, "FORMF7U")
    oView:CreateHorizontalBox("TELA",100)
    oView:EnableTitleView('VIEW_F7U', STR0002 )  
    oView:SetCloseOnOk({||.T.})
    oView:SetOwnerView("VIEW_F7U","TELA")

Return oView

/*/{Protheus.doc} F919RetCbx
Retorna o cBox do campo F7U_TPNEG e F7U_DESCNEG

OBS: Conforme orientação do GCAD, criado os códigos no código e não na SX5.

@author Cesar Almeida
@since 19/01/2026
@version 2510
/*/
Function F919RetCbx(cTpNeg As Character)
    
    Local aAuxRetCbx As Array
    Local cTpDesc    As Character
    Local nPosNeg    As Numeric
    Local nTamDesc   As Numeric

    Default cTpNeg := ""

    aAuxRetCbx  := {}
    cTpDesc     := ""
    nPosNeg     := 0
    nTamDesc    := TamSX3('F7U_DESCNEG')[1] 

    __aRetCbx   := {"AL= A Liquidar (Agenda Livre)",;
                    "AC= Agenda Cessão / Cessão Efetivada",;
                    "CL= Cessão Liquidada",;
                    "CS= Cessão em Suspenso / Cessão Fumaça",;
                    "LF= Livre Futuro / Liquidação Futura",;
                    "GF= Gravame Financeiro",;
                    "GV= Gravado / Gravame"}  

    If !Empty(cTpNeg)  
        nPosNeg     := aScan(__aRetCbx,{|x| SubStr(x,1,2) == cTpNeg })
        aAuxRetCbx  := StrToKArr(__aRetCbx[nPosNeg],"=")
        cTpDesc     := Left(AllTrim(Alltrim(aAuxRetCbx[2])), nTamDesc)    
    EndIf
	
Return Iif(!Empty(cTpNeg), cTpDesc, __aRetCbx)

/*/{Protheus.doc} F919VldNeg
    Valida se ja existe determinado tipo de negociacao cadastrada.

    @author Cesar Almeida
    @since 19/01/2026
    @version 2510
/*/
Function F919VldNeg() As Logical

    Local aArea     As Array
    Local oModel    As Object
    Local cTpNeg    As Character
    Local lRet      As Logical

    aArea   := FwGetArea()
    oModel  := FWModelActive()     
    cTpNeg  := oModel:GetValue('FORMF7U','F7U_TPNEG')
    lRet    := .T.

    If oModel:GetOperation()  == MODEL_OPERATION_INSERT
        DbSelectArea("F7U")
        DbSetOrder(1)
        If DbSeek(xFilial("F7U") + cTpNeg )
            Help(" ",1,"A919Reg",,STR0003 ,1,0,,,,,,{STR0004}) 
            lRet := .F. 
        EndIf
    EndIf

    FwRestArea(aArea)

Return lRet
    