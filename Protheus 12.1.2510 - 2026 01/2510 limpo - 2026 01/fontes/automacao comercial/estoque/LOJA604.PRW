#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA604.CH'

/*/{Protheus.doc} LOJA604
Cadastro de Ponto de Integração
@author joao.marcos
@since 11/08/2025
@version V1.0
/*/
Function LOJA604()
Local oBrowse

Private aRotina := MenuDef()

If AmIIn(12) // Acesso apenas para modulo e licença do Varejo

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias( "MI3" )
    oBrowse:SetDescription( STR0001 ) // "Regra de Estoque Flexível"

    oBrowse:Activate()     
EndIf

Return NIL

/*/{Protheus.doc} MenuDef
Menu
@type  Static Function
@author joao.marcos
@since 11/08/2025
@version V1.0
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0010  Action "PesqBrw"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0002  Action "VIEWDEF.LOJA604" OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina Title STR0003  Action "VIEWDEF.LOJA604" OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina Title STR0004  Action "VIEWDEF.LOJA604" OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina Title STR0005  Action "VIEWDEF.LOJA604" OPERATION 5 ACCESS 0 //Excluir

Return aRotina

/*/{Protheus.doc} ModelDef
Estrutura o Model
@type  Static Function
@author joao.marcos
@since 11/08/2025
@version V1.0
/*/
Static Function ModelDef()
Local oStruMI3  := FWFormStruct( 1, "MI3", /*bAvalCampo*/, /*lViewUsado*/ )
Local bPosValid := {|| LjPSEValid() }
Local oModel    :=  MPFormModel():New( "LOJA604_M", /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/ ) 

oModel:SetDescription( "Produtos" ) // "Ponto de Integração"
oModel:AddFields( "MI3MASTER", /*cOwner*/, oStruMI3 )
oModel:SetPrimaryKey({"MI3_FILIAL", "MI3_COD"})

oModel:GetModel( 'MI3MASTER' ):SetDescription( STR0001 ) // "Regra de Estoque Flexível" 

Return oModel

/*/{Protheus.doc} ViewDef
Estrutura a View da Tela
@type  Static Function
@author joao.marcos
@since 11/08/2025
@version V1.0
/*/
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( "LOJA604" )
Local oView
Local oStruMI3 := FWFormStruct( 2, "MI3" )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "VIEW_MI3", oStruMI3, "MI3MASTER" )
oView:CreateHorizontalBox( "PRODUTOS", 100 )
oView:EnableTitleView('VIEW_MI3', STR0006 )   // 'Dados da Regra'
oView:SetOwnerView( "VIEW_MI3", "PRODUTOS" )

oStruMI3:SetProperty('MI3_COD', MVC_VIEW_CANCHANGE, .F. )


oStruMI3:RemoveField('MI3_FILIAL')

Return oView

/*/{Protheus.doc} LjPSEValid
Faz as validações antes de permitir a inclusão/alteração
@type  Function
@author joao.marcos
@since 11/08/2025
@version V1.0
/*/
Function LjPSEValid()
Local lRet          := .T.
Local oModel        := FWModelActive()
Local nOperation    := oModel:GetOperation()    // Operaçao em andamento (Inclusão/Alteracçao/Exclusao)
Local aArea         := GetArea()				// Salva a area atual
Local cCodRegra     := Upper(AllTrim(oModel:GetValue("MI3MASTER","MI3_COD")))

If ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE )
    Do Case
        Case ( Empty(oModel:GetValue("MI3MASTER","MI3_CODPRO")) .AND. Empty(oModel:GetValue("MI3MASTER","MI3_GRUPO")) .AND. Empty(oModel:GetValue("MI3MASTER","MI3_CATEGO")) )
            Help( " ", 1, STR0007,, STR0008,1,0,,,,,,{STR0009})//"Campos Obrigatórios"#"É obrigatório informar ao menos um dos campos: Código do Produto, Grupo ou Categoria."#"Preencher o campo Código do Produto ou Grupo ou Categoria"
            lRet := .F.
    EndCase

    If lRet
        DbSelectArea("MI3")

        If !Empty(oModel:GetValue("MI3MASTER","MI3_CODPRO"))
            DbSetOrder(2)  //MI3_FILIAL+MI3_CODPRO
            If DbSeek(xFilial("MI3") + oModel:GetValue("MI3MASTER","MI3_CODPRO")) .AND. ( cCodRegra <> Upper(AllTrim(MI3->MI3_COD)) )
                Help( " ", 1, STR0011,,STR0012,1,0,,,,,,{STR0013})//"A T E N Ç Ã O"#"Não é permitido incluir um código de produto já cadastrado"#"Para concluir o cadastro, altere o código de produto. Caso queria alterar a regra de estoque flexível é preciso alterar a regra já cadastrada para esse produto."
                lRet := .F.
            EndIF
        EndIf

        If !Empty(oModel:GetValue("MI3MASTER","MI3_GRUPO"))
            DbSetOrder(3) //MI3_FILIAL+MI3_GRUPO
            If DbSeek(xFilial("MI3") + oModel:GetValue("MI3MASTER","MI3_GRUPO")) .AND. ( cCodRegra <> Upper(AllTrim(MI3->MI3_COD)) )
                Help( " ", 1, STR0011,,STR0014,1,0,,,,,,{STR0015})//"A T E N Ç Ã O"#"Não é permitido incluir um Grupo de Produtos já cadastrado"#"Para concluir o cadastro, altere o Grupo de Produto. Caso queria alterar a regra de estoque flexível é preciso alterar a regra já cadastrada para esse Grupo de Produtos."
                lRet := .F.
            EndIf
        EndIf

        If !Empty(oModel:GetValue("MI3MASTER","MI3_CATEGO"))
            DbSetOrder(4) //MI3_FILIAL+MI3_CATEGO
            If DbSeek(xFilial("MI3") + oModel:GetValue("MI3MASTER","MI3_CATEGO")) .AND. ( cCodRegra <> Upper(AllTrim(MI3->MI3_COD)) )
                Help( " ", 1, STR0011,,STR0016,1,0,,,,,,{STR0017})////"A T E N Ç Ã O"#"Não é permitido incluir uma Categoria de Produtos já cadastrado"#"Para concluir o cadastro, altere a Categoria de Produtos. Caso queria alterar a regra de estoque flexível é preciso alterar a regra já cadastrada para essa Categoria de Produtos."
                lRet := .F.
            EndIf
        EndIf

        RestArea(aArea)
    EndIf
EndIf

Return lRet
