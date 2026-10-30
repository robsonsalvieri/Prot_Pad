#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCDEP

Manutencao de Dependentes

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCDEP()
	Local oBrowse	:= Nil
	Local lAuto     := Isblind()
	Private CENUF	:= ""

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B8Z')
	oBrowse:SetDescription("DIOPS - Dependencias") //Operadoras
	oBrowse:SetMenuDef( 'PLSMVCDEP' )

	if lHabMetric .and. lLibSupFw .and. lVrsAppSw
		FWMetrics():addMetrics("DIOPS Dependências", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
	endif

	If !lAuto
		oBrowse:Activate()
	EndIf

Return( NIL )
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}

	aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'					, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSMVCDEP'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { "Incluir"				, 'VIEWDEF.PLSMVCDEP'	, 0 , 3 , 0 , NIL } ) //Incluir
	aAdd( aRotina, { "Alterar"				, 'VIEWDEF.PLSMVCDEP'	, 0 , 4 , 0 , NIL } ) //Alterar
	aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSMVCDEP'	, 0 , 5 , 0 , NIL } ) //Excluir

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela B8Z

@return oModel	objeto model criado

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB8Z 	:= FWFormStruct( 1, 'B8Z', , )
	Local oModel		:= Nil
	Local bEnvCad		:= { || DIOPSEnvCad() }

	oModel := MPFormModel():New( "DIOPS - Dependencias", /*bPreValidacao*/, bEnvCad/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B8ZMASTER', , oStruB8Z )
	oModel:GetModel( 'B8ZMASTER' ):SetDescription( "DIOPS - Dependencias" )

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B8Z

@return oView	objeto view criado

@author timoteo.bega
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCDEP' )
	Local oStruB8Z := FWFormStruct( 2, 'B8Z' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B8Z' , oStruB8Z , 'B8ZMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:EnableTitleView( 'VIEW_B8Z', 'DIOPS - Dependentes' )

Return oView
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B8NCargo

Retorna a descricao do cargo do dependente

@return cDescri	Descricao do cargo

@author timoteo.bega
@since 08/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function B8NCargo()
	Local aDescri := GetTabCargo()
	Local cDescri	:= ""
	Local cCod		:= ""
	Local nPos		:= 0

	If Inclui
		cCod := M->B8N_CARGO
	Else
		cCod := B8N->B8N_CARGO
	EndIf

	nPos :=	aScan(aDescri,{ |x| x[1] == cCod})
	If nPos > 0
		cDescri := aDescri[nPos,2]
	EndIf

Return cDescri
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B8NPais

Retorna a descricao do pais

@return cDescri	Descricao do pais

@author timoteo.bega
@since 05/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function B8NPais()
	Local aDescri 	:= GetTabPais()
	Local cDescri	:= ""
	Local cCod		:= ""
	Local nPos		:= 0

	If Inclui .Or. Altera
		cCod := M->B8N_PAIS
	Else
		cCod := B8N->B8N_PAIS
	EndIf

	cCod := StrZero(Val(cCod),3)

	nPos :=	aScan(aDescri,{ |x| x[1] == cCod})
	If nPos > 0
		cDescri := aDescri[nPos,2]
	EndIf

Return cDescri