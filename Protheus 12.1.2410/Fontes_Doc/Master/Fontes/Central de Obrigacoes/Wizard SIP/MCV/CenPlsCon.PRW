#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPlsCon

Manutencao de Tipos de Contrato

@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Function CenPlsCon(cFiltro)
    Local oBrowse	:= Nil

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias('BII')
    oBrowse:SetDescription("SIP - Os Tipos de Contratos abaixo estão com o campo Tp Plano (BII_TIPPLA) em branco. Favor ajustar.")
    oBrowse:SetFilterDefault(cFiltro)
    oBrowse:SetMenuDef( 'CenPlsCon' )
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

    aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CenPlsCon'	, 0 , 2 , 0 , NIL } ) //Visualizar
    aAdd( aRotina, { "Alterar"				, 'VIEWDEF.CenPlsCon'   , 0 , 4 , 0 , NIL } ) //Alterar

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela BII

@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oStruBII 	:= FWFormStruct( 1, 'BII', , )
    Local oModel	:= Nil

    oModel	:= MPFormModel():New( "SIP - Tipos de Contrato")
    oModel:AddFields( 'BIIMASTER', , oStruBII )
    oModel:GetModel( 'BIIMASTER' ):SetDescription( "SIP - Tipos de Contrato" )
    oModel:SetPrimaryKey( {"BII_FILIAL","BII_CODIGO"} )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela BII
@author José Paulo de Azevedo
@since 12/09/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel   := FWLoadModel( 'CenPlsCon' )
    Local oStruBII := FWFormStruct( 2, 'BII' )
    Local oView    := FWFormView():New()

    oStruBII:SetProperty( 'BII_DESCRI',MVC_VIEW_CANCHANGE,.f.)

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_BII' , oStruBII , 'BIIMASTER' )
    oView:CreateHorizontalBox( 'SUPERIOR', 100 )
    oView:SetOwnerView( 'VIEW_BII', 'SUPERIOR' )
    oView:EnableTitleView( 'VIEW_BII', 'SIP - Tipos de Contratos' )

Return oView

