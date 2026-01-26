#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "Fwlibversion.ch"
#INCLUDE "TOTVS.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENMVCRIS

Capital Baseado em Riscos - Risco de Mercado - ALM

@author Cesar Almeida
@since 20/07/2023
/*/
//--------------------------------------------------------------------------------------------------
Function CENMVCRIS()

	Local oBrowse := Nil
	Local cB3DTri :=(B3D->B3D_ANO + B3D->B3D_CODIGO)
	Default lAuto := .F.
	Default cTri := "2023003"

	If  cB3DTri < cTri
		MsgInfo("O Quadro de Risco de Mercado somente deve ser utilizado para gerar movimentações para compromissos a partir do 3º Tri/23")
		Return .F.
	EndIf

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('BVU')
	oBrowse:SetDescription("DIOPS - Capital Baseado em Riscos - Risco de Mercado - ALM") 
	oBrowse:AddLegend( "BVU_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "BVU_STATUS=='2'", "GREEN" ,	"Valido" )
	oBrowse:AddLegend( "BVU_STATUS=='3'", "RED"   , "Invalido" )
	oBrowse:SetFilterDefault( "BVU_FILIAL=B3D->B3D_FILIAL .And. BVU_CODOPE=B3D->B3D_CODOPE .And. BVU_CODOBR=B3D->B3D_CDOBRI .And. BVU_ANOCMP=B3D->B3D_ANO .And. BVU_CDCOMP=B3D->B3D_CODIGO" )
	oBrowse:SetMenuDef('CENMVCRIS')
	
	oBrowse:Activate()	

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definicao das opcoes do menu

@author Cesar Almeida
@since 20/07/2023
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina	:= {}

	aAdd( aRotina, { "Críticas"				, 'PlCenFilCri("BVU", BVU->(Recno()) ) ' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.CENMVCRIS'	, 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.CENMVCRIS'	, 0 , 3 , 0 , NIL } )
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.CENMVCRIS'	, 0 , 5 , 0 , NIL } )
	aAdd( aRotina, { "Imprimir Quadro"		, 'CENRRISCO(.F.)'		, 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Validar Quadro"		, 'CenVldQdMn("27")' 	, 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Excluir Quadro"		, 'CenLimpBlc(GetTabRIS())'	, 0 , 7 , 0 , NIL } )
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.CENMVCRIS'   , 0 , 4 , 0 , NIL } )

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela BVU

@return oModel	objeto model criado

@author Cesar Almeida
@since 20/07/2023
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oStruBVU 	:= FWFormStruct( 1, 'BVU', , )
	Local oModel		:= Nil
	Local bPosValida	:= { |oModel| preValidaDIOPS(oModel, 'BVUMASTER', 'BVU_CODOPE', 'BVU_CODOBR', 'BVU_CDCOMP', 'BVU_ANOCMP', 'BVU_REFERE', 'BVU_STATUS') }
	

	oModel	:= MPFormModel():New( "CENMVCRIS", /*bPreValidacao*/, bPosValida/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'BVUMASTER', , oStruBVU )
	oModel:GetModel( 'BVUMASTER' ):SetDescription( "DIOPS - Capital Baseado em Riscos - Risco de Mercado - ALM" )
	oModel:SetPrimaryKey({'BVU_FILIAL','BVU_CODOPE', 'BVU_CODOBR', 'BVU_CDCOMP', 'BVU_ANOCMP', 'BVU_REFERE',;
						  'BVU_CONTA','BVU_VALOR','BVU_ESCX','BVU_MESES','BVU_INDEXA'})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela BVU

@return oView	objeto view criado

@author Cesar Almeida
@since 20/07/2023
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'CENMVCRIS' )
	Local oStruBVU := FWFormStruct( 2, 'BVU' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_BVU' , oStruBVU , 'BVUMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_BVU', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_BVU', 'DIOPS - Capital Baseado em Riscos - Risco de Mercado - ALM' )

Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getTabIDSA

Retorna tabela do quadro Capital Baseado em Riscos - Risco de Mercado - ALM

@author Cesar Almeida
@since 26/07/2023
/*/
//--------------------------------------------------------------------------------------------------
Function GetTabRIS()
Return "BVU"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRegrasAGI

Retorna array de regras para validar o quadro Capital Baseado em Riscos - Risco de Mercado - ALM

@author Cesar Almeida
@since 26/07/2023
/*/
//--------------------------------------------------------------------------------------------------
Function GetRegRis()

	local aRegrasAll := {}
	local aRegras := {}
	local aRegrasRis := {}//Passar a clausula where pronta

	aAdd( aRegrasAll, {"RIS01","    ","AllwaysTrue()", "","", "" } )
	aAdd( aRegrasRis, {"RIS02","    ","AllwaysTrue()", "","", "" } )

	aRegras := { GetTabRIS(), aRegrasAll,aRegrasRis}

Return aRegras


