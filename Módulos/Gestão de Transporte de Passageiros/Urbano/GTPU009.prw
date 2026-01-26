#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPU009.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU009
	Programação de horários/linhas - Urbano

	@author Breno Gomes
    @since 05/03/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Function GTPU009()
	Local oBrowse := FWMBrowse():New()

	oBrowse:SetDescription(STR0001) //'Programação de horários/linhas'
	oBrowse:SetAlias("H71")
	oBrowse:SetFilterDefault ( "H71_STATUS == '1'")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return Nil

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

    @author Breno Gomes
    @since 05/03/2024
    @version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

    aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.GTPU009", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.GTPU009", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.GTPU009", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.GTPU009", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.GTPU009", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

    Função responsavel pela definição do modelo
    @author Breno Gomes
    @since 05/03/2024
    @return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel        := Nil
	Local oStructH71    := FWFormStruct(1, 'H71')
	Local oStructH73    := FWFormStruct(1, 'H73')
	Local oStructH74    := FWFormStruct(1, 'H74')
	Local oStructH75    := FWFormStruct(1, 'H75')
	Local aH73Relation  := {}
	Local aH74Relation  := {}
	Local aH75Relation  := {}

	oModel := MPFormModel():New("GTPU009",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
	oModel:AddFields('H71MASTER',/*cOwner*/,oStructH71)
	oModel:GetModel( "H71MASTER" ):SetDescription( "H71MASTER" ) //"Cabecalho programação de linha"

	//2º NIVEL
	oModel:AddGrid('H73DETAIL','H71MASTER',oStructH73) 
	aAdd(aH73Relation, { 'H73_FILIAL', "xFilial('H73')" })
	aAdd(aH73Relation, { 'H73_CODH71', 'H71_CODIGO'     })
	oModel:SetRelation('H73DETAIL', aH73Relation, H73->(IndexKey(1)))

	//3º NIVEL
	oModel:AddGrid('H74DETAIL','H73DETAIL',oStructH74) 
	aAdd(aH74Relation, { 'H74_FILIAL' ,  "xFilial('H74')" })
	aAdd(aH74Relation, { 'H74_CODH71' ,  'H71_CODIGO'     })
	aAdd(aH74Relation, { 'H74_CODH73' ,  'H73_CODIGO'     })
	oModel:SetRelation('H74DETAIL', aH74Relation, H74->(IndexKey(2)))
	
	//4º NIVEL
	oModel:AddGrid('H75DETAIL','H74DETAIL',oStructH75) 
	aAdd(aH75Relation, { 'H75_FILIAL' ,  "xFilial('H75')" })
	aAdd(aH75Relation, { 'H75_CODH71' ,  'H71_CODIGO'     })
	aAdd(aH75Relation, { 'H75_CODH73' ,  'H73_CODIGO'     })
	aAdd(aH75Relation, { 'H75_CODH74' ,  'H74_CODIGO'     })	
	oModel:SetRelation('H75DETAIL', aH75Relation, H75->(IndexKey(2)))

	oModel:GetModel('H73DETAIL'):SetUniqueLine({"H73_CODH71","H73_CODIGO"}) 
	oModel:GetModel('H74DETAIL'):SetUniqueLine({"H74_CODH71","H74_CODH73","H74_CODIGO"}) 
	oModel:GetModel('H75DETAIL'):SetUniqueLine({"H75_CODH71","H75_CODH73","H75_CODH74","H75_CODIGO"}) 

	oModel:GetModel( 'H74DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'H75DETAIL' ):SetOptional(.T.)

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

    Função responsavel pela definição da view
    @type Static Function
    @author Breno Gomes
    @since 05/03/2024
    @version 1.0
    @return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView      := Nil
	Local oModel     := FWLoadModel("GTPU009")    
	Local oStructH71 := FWFormStruct(2, "H71")
	Local oStructH73 := FWFormStruct(2, 'H73')
	Local oStructH74 := FWFormStruct(2, 'H74')
	Local oStructH75 := FWFormStruct(2, 'H75')

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField('VIEW_H71', oStructH71, 'H71MASTER')
    oView:AddGrid('VIEW_H73' , oStructH73, 'H73DETAIL')
	oView:AddGrid('VIEW_H74' , oStructH74, 'H74DETAIL')
	oView:AddGrid('VIEW_H75' , oStructH75, 'H75DETAIL')
     
    oView:CreateHorizontalBox('CABEC', 30)
    oView:CreateHorizontalBox('GRIDH73' , 20)
	oView:CreateHorizontalBox('GRIDH74' , 20)
	oView:CreateHorizontalBox('GRIDH75' , 30)
     
    oView:SetOwnerView('VIEW_H71', 'CABEC')
    oView:SetOwnerView('VIEW_H73', 'GRIDH73')
	oView:SetOwnerView('VIEW_H74', 'GRIDH74')
	oView:SetOwnerView('VIEW_H75', 'GRIDH75')

	oStructH73:RemoveField("H73_CODH71")
	oStructH74:RemoveField("H74_CODH73")
	oStructH75:RemoveField("H75_CODH74")
        
    oView:EnableTitleView('VIEW_H71', STR0008 ) //"Cadastrar programação de Horários/Linhas"
	oView:EnableTitleView('VIEW_H73', STR0009 ) //"Requisitos da programação"
	oView:EnableTitleView('VIEW_H74', STR0010 ) //"Programação do requisito"
	oView:EnableTitleView('VIEW_H75', STR0011 ) //"Detalhes x Programação do requisito"

	oStructH71:SetProperty( '*', MVC_VIEW_CANCHANGE, .F. )

	oView:SetNoInsertLine('VIEW_H73')
	oView:SetNoUpdateLine('VIEW_H73')

	oView:SetNoInsertLine('VIEW_H74')
	oView:SetNoUpdateLine('VIEW_H74')

	oView:SetNoInsertLine('VIEW_H75')
	oView:SetNoUpdateLine('VIEW_H75')
	
        
Return oView