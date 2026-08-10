//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOCA090.ch' 
//Variáveis Estáticas
Static cTitulo := STR0001 //"Cadastro Check list"
 
/*/{Protheus.doc} LOCA090
cadastro de FORMULARIO Check-List
@author Dennis Calabrez
@since 11/09/2024
@version 1.0
/*/
 
Function LOCA090()
Local aArea   := GetArea()
Local oBrowse
Private aRotina := {}

    //Definicao do menu
    aRotina := MenuDef()    
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de T�picos
    oBrowse:SetAlias("FQM")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Dennis Calabrez                                              |
 | Data:  11/09/2024                                                   |
 | Desc:  Criação do menu MVC                                        |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
Local aRot := {}

    ADD OPTION aRot TITLE STR0002 ACTION 'VIEWDEF.LOCA090' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1 //'Visualizar'
    ADD OPTION aRot TITLE STR0003    ACTION 'VIEWDEF.LOCA090' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3 //'Incluir'
    ADD OPTION aRot TITLE STR0004    ACTION 'VIEWDEF.LOCA090' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4 //'Alterar'
    ADD OPTION aRot TITLE STR0005    ACTION 'VIEWDEF.LOCA090' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5     //'Excluir'
    
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Dennis Calabrez                                              |
 | Data:  11/09/2024                                                   |
 | Desc:  Criação do modelo de dados MVC                             |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
Local oModel   := Nil
Local oStPai   := FWFormStruct(1, 'FQM')
Local oStFilho := FWFormStruct(1, 'FQN')
Local aFQNRel  := {}

    
    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New('LOCA090M')
    oModel:AddFields('FQMMASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('FQNDETAIL','FQMMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

    oStFilho:AddTrigger( "FQN_CODITE"   , "FQN_DESITE"   , {|| .T. }  , {|oModel| Posicione("FQ6",1,xFilial("FQ6")+FWFldGet("FQN_CODITE"), "FQ6_DESC") } )
     
    //Fazendo o relacionamento entre o Pai e Filho
    aAdd(aFQNRel, {'FQN_FILIAL','xFilial("FQN")'})
    aAdd(aFQNRel, {'FQN_CODTOP','FQM_CODIGO'})

     
    //oModel:SetRelation('FQNDETAIL', aFQNRel, FQN->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
    oModel:SetRelation('FQNDETAIL', aFQNRel, ) //IndexKey -> quero a ordenação e depois filtrado
    oModel:GetModel('FQNDETAIL'):SetUniqueLine({"FQN_CODITE"})    //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({})
     
    //Setando as descrições
    oModel:SetDescription(cTitulo)
    oModel:GetModel('FQMMASTER'):SetDescription(STR0006) //'T�pico'
    oModel:GetModel('FQNDETAIL'):SetDescription(STR0007) //'Itens do T�pico'
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Dennis Calabrez                                              |
 | Data:  11/09/2024                                                   |
 | Desc:  Criação da visão MVC                                      |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
Local oView    := Nil
Local oModel   := FWLoadModel('LOCA090')
Local oStPai   := FWFormStruct(2, 'FQM')
Local oStFilho := FWFormStruct(2, 'FQN')
     
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_FQM',oStPai,'FQMMASTER')
    oView:AddGrid('VIEW_FQN',oStFilho,'FQNDETAIL')
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_FQM','CABEC')
    oView:SetOwnerView('VIEW_FQN','GRID')
     
    //Habilitando título
    oView:EnableTitleView('VIEW_FQM','T�picos')
    oView:EnableTitleView('VIEW_FQN','Itens do T�pico')
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //Remove os campos 
    //oStFilho:RemoveField('FQN_CODFOR')
    //oStFilho:RemoveField('FQN_CODFAM')
    //oStFilho:RemoveField('FQN_SEQ')
    //oStFilho:RemoveField('FQN_CODTOP')
Return oView
