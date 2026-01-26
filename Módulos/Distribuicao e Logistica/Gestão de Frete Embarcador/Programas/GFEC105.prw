#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC105
Nova consulta de lotes de estorno.

@author  Elynton Fellipe Bazzo
@since   26/12/2016
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEC105( lBrowse )

	Local oBrowse
	Default lBrowse := .T.
	
	If lBrowse
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( "GXN" )
		oBrowse:SetMenuDef( "GFEC105" )
		oBrowse:SetDescription( "Sublote Estorno de Provisão" )
		oBrowse:SetWalkthru(.F.)
		oBrowse:SetAmbiente(.F.)
		oBrowse:Activate()
	Else
		FWExecView( ,"GFEC105",,,{|| .T.} )
	EndIf
	
Return Nil

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Monta menu da consulta.

@author  Elynton Fellipe Bazzo
@since   26/12/2016
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function MenuDef()

	Local aRotina := {}
	
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE "Pesquisar"  	ACTION "AxPesqui"        OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"	ACTION "VIEWDEF.GFEC105" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"   	ACTION "VIEWDEF.GFEC105" OPERATION 8 ACCESS 0
	
Return aRotina

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} ModelDef

@author  Elynton Fellipe Bazzo
@since   26/12/2016
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ModelDef()

	Local oModel     := MPFormModel():New("GFEC105", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	Local oStructGXN := FWFormStruct( 1,"GXN" )
	Local oStructGXD := FWFormStruct( 1,"GXD" )
	Local oStructGXO := FWFormStruct( 1,"GXO" )
	
	oModel:AddFields( "GFEC105_GXN", Nil, oStructGXN,/*bPre*/,/*bPost*/,/*bLoad*/ )
	oModel:SetPrimaryKey({ "GXN_FILIAL", "GXN_CODLOT" })
		
	oModel:AddGrid( "GFEC105_GXD", "GFEC105_GXN", oStructGXD )
	oModel:SetRelation( 'GFEC105_GXD', {{'GXD_FILIAL',"xFilial('GXD')"},{'GXD_CODLOT','GXN_CODLOT'},{'GXD_CODEST','GXN_CODEST'}} , GXD->( IndexKey(3) ) )
	
	oModel:AddGrid( "GFEC105_GXO","GFEC105_GXN", oStructGXO )
	oModel:SetRelation( 'GFEC105_GXO', {{'GXO_FILIAL',"xFilial('GXO')"},{'GXO_CODLOT','GXN_CODLOT'},{'GXO_CODEST','GXN_CODEST'}} , GXO->( IndexKey(1) ) )
	
	oModel:SetDescription( "Sublote Estorno de Provisão" )
	oModel:GetModel("GFEC105_GXN"):SetDescription( "Sublote Estorno de Provisão" )
	oModel:GetModel("GFEC105_GXD"):SetDescription( "Cálculos" )
	oModel:GetModel("GFEC105_GXO"):SetDescription( "Lançamentos de estorno" )

Return oModel

/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} ViewDef

@author  Elynton Fellipe Bazzo
@since   26/12/2016
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Static Function ViewDef()

	Local oModel     := FWLoadModel( "GFEC105" )
	Local oStructGXN := FWFormStruct( 2,"GXN" )
	Local oStructGXD := FWFormStruct( 2,"GXD" )
	Local oStructGXO := FWFormStruct( 2,"GXO" )
	Local oView      := FWFormView():New()
	
	oView:SetModel( oModel )
	oView:AddField( "GFEC105_GXN", oStructGXN )
	oView:AddGrid( "GFEC105_GXD", oStructGXD )
	oView:AddGrid( "GFEC105_GXO", oStructGXO )
	
	//Remove campo filial da tela
	oStructGXN:RemoveField( "GXN_FILIAL" )
	
	//Remove campo código lote e código estorno da grid 
	oStructGXD:RemoveField( "GXD_CODLOT" )
	oStructGXD:RemoveField( "GXD_CODEST" )

	//Remove campo código lote, código estorno e data lançamento da grid
	oStructGXO:RemoveField( "GXO_CODLOT" )
	oStructGXO:RemoveField( "GXO_CODEST" )
	oStructGXO:RemoveField( "GXO_DATA" )
	
	oView:CreateHorizontalBox( "MASTER", 55 )
	oView:CreateHorizontalBox( "DETAIL", 45 )
	
	oView:CreateFolder( "IDFOLDER", "DETAIL" )
	oView:AddSheet( "IDFOLDER", "IDSHEET01", "Cálculos" )
	oView:AddSheet( "IDFOLDER", "IDSHEET02", "Lançamentos de estorno" )
	
	oView:CreateHorizontalBox( "DETAIL_GXD", 100,,,"IDFOLDER","IDSHEET01" )
	oView:CreateHorizontalBox( "DETAIL_GXO", 100,,,"IDFOLDER","IDSHEET02" )
	
	oView:SetOwnerView( "GFEC105_GXN", "MASTER"     )
	oView:SetOwnerView( "GFEC105_GXD", "DETAIL_GXD" )
	oView:SetOwnerView( "GFEC105_GXO", "DETAIL_GXO" )
	
Return oView