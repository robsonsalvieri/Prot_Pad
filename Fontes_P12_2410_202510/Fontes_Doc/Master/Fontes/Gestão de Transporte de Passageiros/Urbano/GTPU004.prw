#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GTPU004.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU004
Seção - Urbano

@author Mick William da Silva
@since 08/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------

Function GTPU004()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0001) //"Seção - Urbano"
	oBrowse:SetAlias("H6W")
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

    @author Mick William da Silva
    @since 08/02/2024
    @version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0002 , "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003 , "VIEWDEF.GTPU004", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004 , "VIEWDEF.GTPU004", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005 , "VIEWDEF.GTPU004", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006 , "VIEWDEF.GTPU004", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007 , "VIEWDEF.GTPU004", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

    Função responsavel pela definição do modelo
    @author Mick William da Silva
    @since 08/02/2024
    @return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel    := Nil
	Local oStH6W    := FWFormStruct(1, 'H6W')
	Local oStH6X    := FWFormStruct(1, 'H6X')
    Local oStH85    := Nil 
    Local lH85      := AliasInDic('H85')
    
    If lH85
        oStH85 := FWFormStruct(1, 'H85')
    Endif

	oModel := MPFormModel():New("GTPU004",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields('H6WMASTER',,oStH6W, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:AddGrid('H6XDETAIL','H6WMASTER',oStH6X,/*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/)

    oModel:SetRelation("H6XDETAIL", {{'H6X_FILIAL' ,  "xFilial('H6X')"}, {'H6X_CODIGO' ,  'H6W_CODIGO' }}, H6X->( IndexKey( 1 )))   //Amarração linhas

	oModel:GetModel('H6WMASTER'):SetDescription(STR0008)  //"Seção"
	oModel:GetModel('H6XDETAIL'):SetDescription(STR0009)  //"Linhas"

    oModel:GetModel('H6XDETAIL'):SetUniqueLine({"H6X_CODLIN"})     

    oModel:SetOptional( "H6XDETAIL" , .T. )

    If lH85 
        oModel:AddGrid('H85DETAIL','H6WMASTER',oStH85,/*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/) 
        oModel:SetRelation("H85DETAIL", {{'H85_FILIAL' ,  "xFilial('H85')"}, {'H85_CODH6W' ,  'H6W_CODIGO' }}, H85->( IndexKey( 1 )))   //Amarração tarifas
        oModel:GetModel('H85DETAIL'):SetDescription(STR0010)  //"Tarifas"
        oModel:GetModel('H85DETAIL'):SetUniqueLine({"H85_CODH6S"}) 
        oModel:SetOptional( "H85DETAIL" , .T. )
    Endif

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

    Função responsavel pela definição da view
    @type Static Function
    @author Mick William da Silva
    @since 08/02/2024
    @version 1.0
    @return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
    
    Local oView 	:= Nil
    Local oModel 	:= FWLoadModel("GTPU004")    
    Local oStH6W    := FWFormStruct(2, "H6W")
    Local oStH6X    := FWFormStruct(2, 'H6X')
    Local oStH85    := Nil
    Local lH85      := AliasInDic('H85')

    If lH85
        oStH85 := FWFormStruct(2, 'H85')
    Endif

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField('VIEW_H6W', oStH6W, 'H6WMASTER')
    oView:AddGrid('VIEW_H6X' , oStH6X, 'H6XDETAIL')
     
    oView:CreateHorizontalBox('CABEC', 40)
    oView:CreateHorizontalBox('GRID1', 20)
    oView:CreateHorizontalBox('GRID2', 20)
     
    oView:SetOwnerView('VIEW_H6W', 'CABEC')
    oView:SetOwnerView('VIEW_H6X', 'GRID1')    
        
    oView:EnableTitleView('VIEW_H6W', STR0008) //"Seção"
    oView:EnableTitleView('VIEW_H6X', STR0009) //"Linhas"

    If lH85
        oView:AddGrid('VIEW_H85' , oStH85, 'H85DETAIL')
        oView:SetOwnerView('VIEW_H85', 'GRID2')
        oView:EnableTitleView('VIEW_H85', STR0010) //"Tarifas"
    Endif

Return oView
