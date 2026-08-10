#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPU010.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU010
Cadastro de Escalas

@author Silas Gomes
@since 18/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function GTPU010() 

    Local oBrowse

    oBrowse := FWMBrowse():New()
    oBrowse:SetDescription(STR0001) //"Cadastro de Escalas"
    oBrowse:SetAlias("H76")
    oBrowse:SetLocate()
    oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef - Menu Funcional

    @return aRotina - Estrutura
    [n,1] Nome a aparecer no cabecalho
    [n,2] Nome da Rotina associada
    [n,3] Reservado
    [n,4] Tipo de Transação a ser efetuada:
    1 - Pesquisa e Posiciona em um Banco de Dados
    2 - Simplesmente Mostra os Campos
    3 - Inclui registros no Bancos de Dados
    4 - Altera o registro corrente
    5 - Remove o registro corrente do Banco de Dados
    6 - Alteração sem inclusão de registros
    7 - Cópia
    8 - Imprimir
    [n,5] Nivel de acesso
    [n,6] Habilita Menu Funcional

    @author Silas Gomes
    @since 18/03/2024
    @version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina as array

	aRotina := {}

	aAdd( aRotina, { STR0002	, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003	, "VIEWDEF.GTPU010", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004	, "VIEWDEF.GTPU010", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005	, "VIEWDEF.GTPU010", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006	, "VIEWDEF.GTPU010", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007 	, "VIEWDEF.GTPU010", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

    Função responsavel pela definição do modelo
    @author Silas Gomes
    @since 18/03/2024
    @return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

    Local oStrH76 as object
    Local oStrH77 as object
    Local oStrH78 as object
    Local oModel  as object

    oStrH76 := FWFormStruct( 1, "H76" )

    oStrH77 := FWFormStruct( 1, "H77" )
    oStrH78 := FWFormStruct( 1, "H78" )

    oModel := MPFormModel():New( "GTPU010",,,,)
    oModel:AddFields( 'H76MASTER',, oStrH76 ) 

    oModel:AddGrid( 'H77DETAIL', 'H76MASTER', oStrH77 )
    oModel:AddGrid( 'H78DETAIL', 'H76MASTER', oStrH78 )

    oModel:GetModel('H78DETAIL'):SetOptional(.T.)

    oModel:SetRelation( 'H77DETAIL', {{ 'H77_FILIAL', 'xFilial( "H77" )' }, { 'H77_CODH76', 'H76_CODIGO' }}, H77->(IndexKey(1)))
    oModel:SetRelation( 'H78DETAIL', {{ 'H78_FILIAL', 'xFilial( "H78" )' }, { 'H78_CODH76', 'H76_CODIGO' }}, H78->(IndexKey(1)))

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

    Função responsavel pela definição da view
    @type Static Function
    @author Silas Gomes
    @since 18/03/2024
    @version 1.0
    @return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

    Local oView   as object
    Local oModel  as object
    Local oStrH76 as object
    Local oStrH77 as object
    Local oStrH78 as object

    oView   := FWFormView():New()
    oModel  := FWLoadModel( 'GTPU010' )
    oStrH76 := FWFormStruct( 2, 'H76' )
    oStrH77 := FWFormStruct( 2, 'H77' )
    oStrH78 := FWFormStruct( 2, 'H78' )

    oStrH76:RemoveField("H76_CODIGO")
    oStrH77:RemoveField("H77_CODH76")
    oStrH78:RemoveField("H78_CODH76")

    oView:SetModel( oModel )

    oView:AddField( 'VIEWH76', oStrH76, 'H76MASTER' )

    oView:AddGrid( 'VIEWH77', oStrH77, 'H77DETAIL' )
    oView:EnableTitleView( "VIEWH77", STR0008 ) //Complemento - Dados Veículo

    oView:AddGrid( 'VIEWH78', oStrH78, 'H78DETAIL' )
    oView:EnableTitleView( "VIEWH78", STR0009 ) //Complemento - Dados Veículo

    oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
    oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

    oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0010 )

    oView:CreateHorizontalBox( 'FIELDS_H76', 050,,, 'FOLDER_SUPERIOR', 'ABA01')
    oView:CreateHorizontalBox( 'GRID_H77', 025,,, 'FOLDER_SUPERIOR', 'ABA01')
    oView:CreateHorizontalBox( 'GRID_H78', 025,,, 'FOLDER_SUPERIOR', 'ABA01')

    oView:SetOwnerView( 'VIEWH76', 'FIELDS_H76' )
    oView:SetOwnerView( 'VIEWH77', 'GRID_H77' )
    oView:SetOwnerView( 'VIEWH78', 'GRID_H78' )

Return oView
