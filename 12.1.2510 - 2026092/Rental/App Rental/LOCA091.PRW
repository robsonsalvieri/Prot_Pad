//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOCA091.ch' 
//Variáveis Estáticas
Static cTitulo := STR0001 //"Check list"
  
/*/{Protheus.doc} LOCA091
Função para Visualizar cadastro de CheckList
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
    ADD OPTION aRot TITLE "Estornar Checklist" ACTION "LOCA091EST" OPERATION MODEL_OPERATION_VIEW   ACCESS 0

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

    //Campo virtual para legenda de status nos itens (grid)
    oStFilho:AddField( ;
        '' , ;                                  // [01] C Titulo do campo
        '' , ;                                  // [02] C ToolTip do campo
        'FPX_LEGND' , ;                         // [03] C ID do Field
        'C' , ;                                 // [04] C Tipo do campo
        50 , ;                                  // [05] N Tamanho do campo
        0 , ;                                   // [06] N Decimal do campo
        NIL , ;                                 // [07] B Validacao do campo
        NIL , ;                                 // [08] B Validacao When
        NIL , ;                                 // [09] A Lista de valores permitidos
        NIL , ;                                 // [10] L Obrigatorio
        { || LOCA091F() } , ;                   // [11] B Code-block de inicializacao
        NIL , ;                                 // [12] L Campo chave
        NIL , ;                                 // [13] L Pode alterar em update
        .T. )                                   // [14] L Campo virtual

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
    oModel:GetModel('FQCMASTER'):SetDescription(STR0003) //'Cabeçalho'
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

    //Campo virtual para legenda de status nos itens (grid) com picture @BMP
    oStFilho:AddField( ;
        'FPX_LEGND'                        , ;  // [01] C Nome do Campo
        '00'                               , ;  // [02] C Ordem (primeiro no grid)
        'Legenda'                          , ;  // [03] C Titulo do campo
        'Status do Item'                   , ;  // [04] C Descricao do campo
        { 'Legenda' }                      , ;  // [05] A Array com Help
        'C'                                , ;  // [06] C Tipo do campo
        '@BMP'                             , ;  // [07] C Picture
        NIL                                , ;  // [08] B Bloco de Picture Var
        ''                                 , ;  // [09] C Consulta F3
        .T.                                , ;  // [10] L Indica se o campo eh alteravel
        NIL                                , ;  // [11] C Pasta do campo
        NIL                                , ;  // [12] C Agrupamento do campo
        NIL                                , ;  // [13] A Lista de valores permitido do campo (Combo)
        NIL                                , ;  // [14] N Tamanho maximo da maior opcao do combo
        NIL                                , ;  // [15] C Inicializador de Browse
        .T.                                , ;  // [16] L Indica se o campo eh virtual
        NIL                                , ;  // [17] C Picture Variavel
        NIL )                                   // [18] L Indica pulo de linha apos o campo

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
     
    //Habilitando tÃ­tulo
    oView:EnableTitleView('VIEW_FQC',STR0005) //'Cabeçalho - Cadastro'
    oView:EnableTitleView('VIEW_FPX',STR0006) //'Grid - Itens'
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
    
    oView:AddUserButton( STR0007, STR0007 , {|oView| LOCA091B() } ) // "Conhecimento - Itens"
    oView:AddUserButton( STR0030, STR0030 , {|oView| LOCA091G() } ) // "Legenda - Status I.A."

Return oView

/*/{Protheus.doc} LOCA091A
Banco de conhecimento para o cabeçalho
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

/*/{Protheus.doc} LOCA091F
Retorna o recurso BMP correspondente ao status da FPX para legenda no grid
@type function
@author Correcao - Dennis Calabrez
@since 31/03/2026
//*/
Function LOCA091F()
Local cRet := ""

    If FPX->(FieldPos("FPX_STATIA")) > 0
        Do Case
            Case AllTrim(FPX->FPX_STATIA) == '1'
                cRet := "BR_VERMELHO"
            Case AllTrim(FPX->FPX_STATIA) == '2'
                cRet := "BR_AZUL"
            Case AllTrim(FPX->FPX_STATIA) == '3'
                cRet := "BR_CINZA"
            Case AllTrim(FPX->FPX_STATIA) == '4'
                cRet := "BR_AMARELO"
            Case AllTrim(FPX->FPX_STATIA) == '5'
                cRet := "BR_VERDE"
            Otherwise
                cRet := "BR_BRANCO"
        EndCase
    EndIf

Return(cRet)

/*/{Protheus.doc} LOCA091G
Exibe a legenda de cores do status I.A. dentro da visualizacao MVC
@type function
@author Correcao - Dennis Calabrez
@since 31/03/2026
//*/
Function LOCA091G()
Local aLegenda := {}

    //Monta as cores da legenda
    AADD(aLegenda,{"BR_VERMELHO", STR0029       }) //"Danos Graves"
    AADD(aLegenda,{"BR_AZUL",     STR0026       }) //"Desgaste Grande"
    AADD(aLegenda,{"BR_CINZA",    STR0022       }) //"Desgaste Pequeno"
    AADD(aLegenda,{"BR_AMARELO",  STR0027       }) //"Pequenas Mudancas"
    AADD(aLegenda,{"BR_VERDE",    STR0024       }) //"Melhorou ou Manteve"
    AADD(aLegenda,{"BR_BRANCO",   STR0032       })//"Sem Ocorrência"

    BrwLegenda(STR0028, STR0028, aLegenda) //STR0028 //"Status I.A."

Return
