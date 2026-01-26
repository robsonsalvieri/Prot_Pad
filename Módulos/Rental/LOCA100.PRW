#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOCA100.ch'
   
Static cTitulo := STR0001 //"Cadastro MTBF do Contrato: "
   
/*/{Protheus.doc} LOCA100
Função para cadastros de MTBF
@author Dennis Calabrez
@since 23/04/2025
@version 1.0
/*/
  
Function LOCA100()
Local aArea   := GetArea()
Local oBrowse
Private aRotina := {}

    aRotina := MenuDef()  
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("FH0")
    oBrowse:SetDescription(cTitulo  + FP0->FP0_PROJET)
    oBrowse:SetFilterDefault("FH0->FH0_PROJET == FP0->FP0_PROJET")
    oBrowse:Activate()
       
    RestArea(aArea)
Return Nil
  
Static Function MenuDef()
Local aRotina := {}
Local nCont := 0       
    ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.LOCA100' OPERATION 1 ACCESS 0 //'Visualizar'
    dbselectarea("FH0")
    FH0->(dbSeek(Xfilial("FH0")+FP0->FP0_PROJET))
    While !FH0->(Eof())
        nCont++
        FH0->(dbSkip())
    End    
    If nCont == 0
         ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.LOCA100' OPERATION 3 ACCESS 0 //'Incluir'
    EndIf  
    If nCont > 0   
        ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.LOCA100' OPERATION 4 ACCESS 0 //'Alterar'
    EndIf    
    ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.LOCA100' OPERATION 5 ACCESS 0 //'Excluir'
    ADD OPTION aRotina TITLE STR0006    ACTION 'LOCA103' OPERATION 3 ACCESS 0 //'Importar Mtbf'
Return aRotina
  
Static Function ModelDef()
Local oModel      := NIL
Local oStruCab     := FWFormStruct(1, 'FH0', {|cCampo| AllTRim(cCampo) $ "FH0_PROJET;"})
Local oStruGrid := fModStruct()
  
    oModel := MPFormModel():New('LOCA100M', /*bPreValidacao*/, /*{|oModel| fValidGrid(oModel)}*/, /*bCommit*/, /*bCancel*/ )
    oStruGrid:AddTrigger( "FH0_CODPRO"   , "FH0_DESPRO"   , {|| .T. }  , {|oModel| Posicione("SB1",1,xFilial("SB1")+FWFldGet("FH0_CODPRO"), "B1_DESC") } )
    oModel:AddFields('MdFieldFH0', NIL, oStruCab)
    oModel:AddGrid('MdGridFH0', 'MdFieldFH0', oStruGrid, , )
  
    oModel:SetRelation('MdGridFH0', {;
            {'FH0_FILIAL', 'xFilial("FH0")'},;
            {"FH0_PROJET",  "FH0_PROJET"};
        }, FH0->(IndexKey(1)))

    oModel:GetModel('MdGridFH0'):SetUniqueLine({"FH0_CODPRO"})        
      
    oModel:GetModel("MdGridFH0"):SetMaxLine(9999)
    oModel:SetDescription(STR0007) //"Cadastro MTBF"
    oModel:SetPrimaryKey({"FH0_FILIAL", "FH0_PROJET"})
  
Return oModel
  
Static Function ViewDef()
Local oView        := NIL
Local oModel    := FWLoadModel('LOCA100')
Local oStruCab  := FWFormStruct(2, "FH0", {|cCampo| AllTRim(cCampo) $ "FH0_PROJET;"})
Local oStruGRID := fViewStruct()
  
    oStruCab:SetNoFolder()
  
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
  
    oView:AddField('VIEW_FH0', oStruCab, 'MdFieldFH0')
    oView:AddGrid ('GRID_FH0', oStruGRID, 'MdGridFH0' )
  
    oView:CreateHorizontalBox("MAIN", 25)
    oView:CreateHorizontalBox("GRID", 75)
  
    oView:SetOwnerView('VIEW_FH0', 'MAIN')
    oView:SetOwnerView('GRID_FH0', 'GRID')
    oView:EnableControlBar(.T.)
  
    oView:SetViewProperty("GRID_FH0", "GRIDSEEK",    {.T.})
    oView:SetViewProperty("GRID_FH0", "GRIDFILTER",  {.T.})

    oView:SetAfterViewActivate({|oView| LOCA100X(oView) })
Return oView
  
//Função chamada para montar o modelo de dados da Grid
Static Function fModStruct()
Local oStruct
    oStruct := FWFormStruct(1, 'FH0')
Return oStruct
  
//Função chamada para montar a visualização de dados da Grid
Static Function fViewStruct()
Local cCampoCom := "FH0_FILIAL;FH0_PROJET;"
Local oStruct
  
    oStruct := FWFormStruct(2, "FH0", {|cCampo| !(Alltrim(cCampo) $ cCampoCom)})
Return oStruct

/*/{Protheus.doc} LOCA100X
Preenchimento do campo FH0_PROJET para efeito de gravação do modelo MVC
@type function
@version  
@author Frank Zwarg Fuga
@since 22/08/2025
/*/
Function LOCA100X(oView)
Local oModel := FWModelActive()
Local oModelFH0 := oModel:GetModel("MdFieldFH0")
    If oModel:GetOperation() == 3
        oModelFH0:SetValue("FH0_PROJET", "" )   
        oModelFH0:SetValue("FH0_PROJET", FP0->FP0_PROJET )   
        oView:Refresh()
    EndIf
Return
