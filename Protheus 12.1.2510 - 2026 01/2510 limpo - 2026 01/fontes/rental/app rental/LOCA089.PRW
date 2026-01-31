//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOCA089.CH'
 
//Variáveis Estáticas
Static cTitulo := STR0001 //"Itens do Cheklist"
 
/*/{Protheus.doc} LOCA089
Rotina que cadastra ITENS do check-list
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/
Function LOCA089()
Local oBrowse
Private aRotina := {}

    //Definicao do menu
    aRotina := MenuDef()

    //Instanciando o browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("FQ6")
    //oBrowse:SetMenuDef("LOCA089")
    oBrowse:SetDescription(cTitulo)
    //oBrowse:DisableDetails()

    //Ativa a Browse
    oBrowse:Activate()

    //FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/

Static Function MenuDef()
Local aRotina := {}

    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.LOCA089" OPERATION 1 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.LOCA089" OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOCA089" OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOCA089" OPERATION 5 ACCESS 0 //"Excluir"


Return aRotina    

/*/{Protheus.doc} ModelDef
Modelo de dados
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/

Static Function ModelDef()

Local oStruct		:= FWFormStruct( 1, 'FQ6' )
Local oModel		// Modelo de dados que será construído

    oModel := MPFormModel():New( 'LOCA089' )
    //Antiga enchoice
    oModel:AddFields( 'FQ6MASTER', /*cOwner*/, oStruct )
    //Descrição do modelo
    oModel:SetDescription( cTitulo ) 		//"Cadastro de operações com controle de aprovação"

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/

Static Function ViewDef()
Local oModel 	:= FWLoadModel( 'LOCA089' ) 		// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruFNH 	:= FWFormStruct( 2, 'FQ6' ) 		// Cria a estrutura a ser usada na View
Local oView  									// Interface de visualização construída

    // Cria o objeto de View
    oView := FWFormView():New()
    // Define qual o Modelo de dados será utilizado na View
    oView:SetModel( oModel )
    // Adiciona no nosso View um controle do tipo formulário
    oView:AddField( 'VIEWFQ6', oStruFNH, 'FQ6MASTER' )
    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'TELA' , 100 )
    // Relaciona o identificador (ID) da View com o "box" para exibição
    oView:SetOwnerView( 'VIEWFQ6', 'TELA' )
    /* Desabilita o novo botao "salvar e criar novo" */
    oView:SetCloseOnOK({ || .T. })

Return oView
