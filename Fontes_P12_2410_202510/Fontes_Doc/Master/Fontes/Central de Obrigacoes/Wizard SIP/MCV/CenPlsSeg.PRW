#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPlsSeg

Manutencao de Segmentações

@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Function CenPlsSeg(cFiltro)
    Local oBrowse	:= Nil

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias('BI6')
    oBrowse:SetDescription("SIP - As Segmentações abaixo estão com o campo Seg.SIP (BI6_SEGSIP) em branco. Favor ajustar.")
    oBrowse:SetFilterDefault(cFiltro)
    oBrowse:SetMenuDef( 'CenPlsSeg' )
    oBrowse:Activate()

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
    Private aRotina	:= {}

    aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CenPlsSeg'	, 0 , 2 , 0 , NIL } ) //Visualizar
    aAdd( aRotina, { "Alterar"				, 'VIEWDEF.CenPlsSeg'   , 0 , 4 , 0 , NIL } ) //Alterar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela BI6

@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oStruBI6 	:= FWFormStruct( 1, 'BI6', , )
    Local oModel	:= Nil

    oModel	:= MPFormModel():New( "SIP - Segmentações")
    oModel:AddFields( 'BI6MASTER', , oStruBI6 )
    oModel:GetModel( 'BI6MASTER' ):SetDescription( "SIP - Segmentações" )
    oModel:SetPrimaryKey( {"BI6_FILIAL","BI6_CODSEG"} )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela BI6
@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel   := FWLoadModel( 'CenPlsSeg' )
    Local oStruBI6 := FWFormStruct( 2, 'BI6' )
    Local oView    := FWFormView():New()

    oStruBI6:RemoveField('BI6_CODEDI')
    oStruBI6:RemoveField('BI6_PERDES')
    oStruBI6:SetProperty( 'BI6_DESCRI' ,MVC_VIEW_CANCHANGE,.f.)
    oStruBI6:SetProperty( 'BI6_MEDICO' ,MVC_VIEW_CANCHANGE,.f.)
    oStruBI6:SetProperty( 'BI6_ODONTO'  ,MVC_VIEW_CANCHANGE,.f.)

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_BI6' , oStruBI6 , 'BI6MASTER' )
    oView:CreateHorizontalBox( 'SUPERIOR', 100 )
    oView:SetOwnerView( 'VIEW_BI6', 'SUPERIOR' )
    oView:EnableTitleView( 'VIEW_BI6', 'SIP - Segmentações' )

Return oView

