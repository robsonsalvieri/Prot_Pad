#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TopConn.ch"
#INCLUDE "FWBROWSE.CH"

/*/{Protheus.doc} PrjMvcArt

Tela MVC para apresentação dos registros e execução de rotinas
referentes à Atualização de Artefatos

@author PLS Projetos
@since 07/2020
/*/

Function PrjMvcArt(cOwnConf)
	Local cDescript := "Atualizador de Artefatos" 
	Local oBrowse := nil
	Local cAlias := "BI8"
	Local lAutom := isBlind()
    Local cFiltro := ""//"@(BI8_FILIAL = '" + xFilial("BI8") + "') "
	Local lBI8 := FWAliasInDic("BI8", .F.)
	Local lBI9 := FWAliasInDic("BI9", .F.)
	Default cOwnConf := ""
	
	MV_PAR01 := cOwnConf

	If lBI8 .AND. lBI9
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( cAlias )
		oBrowse:SetFilterDefault(cFiltro)
		oBrowse:SetOnlyFields( { 'BI8_CODIGO','BI8_NOME','BI8_ULTVER','BI8_VERLOC','BI8_ATUAUT','BI8_STATAU','BI8_DATA','BI8_HORA','BI8_DESERR' } )
		oBrowse:SetDescription(cDescript)
		
		oBrowse:SetMenuDef( 'PrjMvcArt' )
		oBrowse:SetProfileID( 'PrjMvcArt' )
		oBrowse:ForceQuitButton()
		oBrowse:DisableDetails()

		oBrowse:AddLegend( "BI8_STATUS=='1'", "GREEN"	, "Status do Artefato: Atualizado" )
		oBrowse:AddLegend( "BI8_STATUS=='0'", "RED"		, "Status do Artefato: Desatualizado" )
		oBrowse:AddLegend( "BI8_STATUS $ ' ,2'", "BLUE"	, "Status do Artefato: Indefinido" )

		iif(!lAutom, oBrowse:Activate(), '')
	Else
		MsgAlert("As tabelas BI8 e BI9 não existem, atualize seu dicionário de dados.")
	EndIf

Return Nil
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author PLS Projetos
@since 07/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina	:= {}
	Add Option aRotina Title "Atualizar Catálogo de Artefatos"	Action "SvcAtuCfgArt(.F.)"		Operation MODEL_OPERATION_INSERT Access 0 
	Add Option aRotina Title "Painel do Artefato"				Action "VIEWDEF.PrjMvcArt" 		Operation MODEL_OPERATION_UPDATE Access 0 
	Add Option aRotina Title "Atualizar Artefato"				Action "PrjAtuArtefato()" 		Operation MODEL_OPERATION_UPDATE Access 0 
	Add Option aRotina Title "Importar Manualmente"				Action "PrjAtuManual (,'BI8')"	Operation MODEL_OPERATION_UPDATE Access 0 
	Add Option aRotina Title "Buscar Versões Anteriores"		Action "PrjMvcVers()"			Operation MODEL_OPERATION_VIEW Access 0  
Return aRotina
//-------- , NIL ------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para os Artefatos

@author PLS Projetos
@since 07/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruBI8 	:= FWFormStruct( 1, 'BI8')
	Local oStruBI9 	:= FWFormStruct( 1, 'BI9')
	Local oModel	:= Nil
	
	oModel := MPFormModel():New( 'PrjMvcArt', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	
	//Adição dos campos e Grids
	oModel:AddFields( 'BI8MASTER', /*cOwner*/ , oStruBI8 )
	oModel:AddGrid( 'BI9Detail'   , 'BI8MASTER' , oStruBI9  ,, ) 

	//Restrições de CRUD
	//oModel:GetModel( 'BI9Detail' ):SetNoDeleteLine( .T. )
	//oModel:GetModel( 'BI9Detail' ):SetNoInsertLine( .T. )
	//oModel:GetModel( 'BI9Detail' ):SetNoUpdateLine( .T. )

	//Descrição
	oModel:GetModel( 'BI8MASTER' ):SetDescription( "Artefatos Registrados" )
	oModel:GetModel( 'BI9Detail' ):SetDescription( "Artefatos Versões" )

	//Relacionamentos
	oModel:SetRelation( 'BI9Detail', { ;
		{ 'BI9_FILIAL'	, 'xFilial( "BI9" )' },;
		{ 'BI9_CODIGO'	, 'BI8_CODIGO'		 }});

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para os Artefatos

@author PLS Projetos
@since 07/2020
/*/
//--------------------------------------------------------------------------------------------------

Static Function ViewDef()
	Local oView		:= FWFormView():New()
	Local oModel	:= FWLoadModel( 'PrjMvcArt' )
	Local oStruBI8	:= FWFormStruct( 2, 'BI8' )
	Local oStruBI9	:= FWFormStruct( 2, 'BI9' )
	
	oView:SetModel( oModel )

	//Vistas principais
	oView:AddField( 'VIEW_BI8' , oStruBI8 , 'BI8MASTER' )
	oView:AddGrid( 'VIEW_BI9' , oStruBI9 , 'BI9Detail' )

	//Divisão das Vistas
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )

	//Vistas
	oView:SetOwnerView( 'VIEW_BI8', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_BI9', 'INFERIOR' )
	oView:EnableTitleView( 'VIEW_BI8', 'Detalhes do Artefato' )
	oView:EnableTitleView( 'VIEW_BI9', 'Versões Disponíveis' )
	oView:SetCloseOnOk({||.T.})

Return oView