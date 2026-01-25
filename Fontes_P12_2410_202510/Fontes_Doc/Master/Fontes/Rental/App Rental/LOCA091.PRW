//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOCA091.ch' 
//Variáveis Estáticas
Static cTitulo := STR0001 //"Check list"
 
/*/{Protheus.doc} LOCA091
Fun��o para Visualizar cadastro de CheckList
@author Dennis Calabrez
@since 06/09/2024
@version 1.0
/*/
 
Function LOCA091()
Local aArea     := GetArea()
Local oBrowse
Private aRotina := {}

    // Troca do campo sobre status da FPX
    If FindFunction( "LOCW002A" ) .and. FPX->(FIELDPOS("FPX_OBS")) > 0
        LOCW002A()
    EndIf    

    //Definicao do menu
    aRotina := MenuDef()    
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro 
    oBrowse:SetAlias("FQC")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Dennis Calabrez                                                |
 | Data:  03/09/2024                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
Local aRot := {}
    //FQC->(DbSetOrder(1))
    //Adicionando opções
    ADD OPTION aRot TITLE STR0002  ACTION 'VIEWDEF.LOCA091' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //"Visualizar"
    ADD OPTION aRot TITLE STR0008 ACTION "LOCA091A" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //"Conhecimento"
    
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Dennis Calabrez                                                |
 | Data:  03/09/2024                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
Local oModel         := Nil
Local oStPai         := FWFormStruct(1, 'FQC')
Local oStFilho       := FWFormStruct(1, 'FPX')
Local aFPXRel        := {}
     
    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New('LOCA091')
    oModel:AddFields('FQCMASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('FPXDETAIL','FQCMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
     
    //Fazendo o relacionamento entre o Pai e Filho
    aAdd(aFPXRel, {'FPX_FILIAL','FQC_FILIAL'} )
    aAdd(aFPXRel, {'FPX_CODCHE','FQC_CODCHE'})
    
    oModel:SetRelation('FPXDETAIL', aFPXRel,) //IndexKey -> quero a ordenação e depois filtrado
    oModel:GetModel('FPXDETAIL'):SetUniqueLine({"FPX_CODCHE"})    //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({})
     
    //Setando as descrições
    oModel:SetDescription("Cadastro do CheckList")
    oModel:GetModel('FQCMASTER'):SetDescription(STR0003) //'Cabe�alho'
    oModel:GetModel('FPXDETAIL'):SetDescription(STR0004) //'Itens'
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Dennis Calabrez                                                |
 | Data:  03/09/2024                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel('LOCA091')
Local oStPai       := FWFormStruct(2, 'FQC')
Local oStFilho     := FWFormStruct(2, 'FPX')
     
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_FQC',oStPai,'FQCMASTER')
    oView:AddGrid('VIEW_FPX',oStFilho,'FPXDETAIL')
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_FQC','CABEC')
    oView:SetOwnerView('VIEW_FPX','GRID')
     
    //Habilitando título
    oView:EnableTitleView('VIEW_FQC',STR0005) //'Cabe�alho - Cadastro'
    oView:EnableTitleView('VIEW_FPX',STR0006) //'Grid - Itens'
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
    
    oView:AddUserButton( STR0007, STR0007 , {|oView| LOCA091B() } ) // "Conhecimento - Itens"

Return oView

/*/{Protheus.doc} LOCA091A
Banco de conhecimento para o cabe�alho
@type function
@author Dennis
@since 6/11/2025
/*/
Function LOCA091A()

    MpDocument("FQC",FQC->(Recno()), 2)     

return (NIL)

/*/{Protheus.doc} LOCA091B
Banco de conhecimento para os itens
@type function
@author Frank Zwarg Fuga
@since 6/11/2025
/*/
Function LOCA091B
Local oModel := FWModelActive()
Local oModelFPX := oModel:GetModel("FPXDETAIL")
Local cCheck := oModelFPX:GetValue("FPX_CODCHE")
Local cItem := oModelFPX:GetValue("FPX_CODITE")
Local cCodTop := oModelFPX:GetValue("FPX_CODTOP")

    FPX->(dbSetOrder(1))
    If FPX->(dbSeek(xFilial("FPX")+cCheck+cCodTop+cItem))
        MpDocument("FPX",FPX->(Recno()), 2)     
    EndIf

return (NIL)

/*/{Protheus.doc} LOCA091C
Gera os dados para o campo memo da FPX
@type function
@author Frank Zwarg Fuga
@since 6/11/2025
Exemplo para o uso:
FPX->FPX_OBS := LOCA091C("TESTE.JPG", cCheck, cItem, cCodTop, "observacao observacao"  )
/*/
Function LOCA091C(cArq, cCheck, cItem, cCodTop, cObs)
Local cJason := ""
    cJason := '{'
    cJason += '"FPX_FILIAL":"'+xFilial("FPX")+'",'
    cJason += '"FPX_CODCHE":"'+cCheck+'",'
    cJason += '"FPX_CODTOP":"'+cCodTop+'",'
    cJason += '"FPX_CODITE":"'+cItem+'",'
    cJason += '"FPX_OBS":"'+cObs+'",'
    cJason += '"FPX_IMAGEM":"'+cArq+'"'
    cJason += '}'
Return cJason
