#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "GRRA020.CH" 

PUBLISH MODEL REST NAME GRRA020 SOURCE GRRA020


Static lR2410       := GetRPORelease() >= "12.1.2410"
//-------------------------- GRRA020 --------------------------------
// Funções de controle para o modelo MVC do plano x itens.
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRA020
Receita Recorrente – Planos x Itens

@author Claudio Donetti
@since 01/04/2022
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function GRRA020()
	Local oBrowse := FWmBrowse():New()

	// TODO - Precisa colocar os campos HRD_REFERE e HRD_ACTIVE com X3_BROWSE desabilitado e
	// Colocar no X3_INIBRW do campo HRD_PAYMET alguma coisa pra colocar a descrição na coluna.

	oBrowse:SetAlias( 'HRD' )
	oBrowse:SetDescription( STR0001 )	//"Planos x Itens Recorrentes"
	oBrowse:AddLegend( "HRD_ACTIVE == '1' ", "GREEN", STR0002 )		//"Ativo"
	oBrowse:AddLegend( "HRD_ACTIVE == '2' ", "RED", STR0003 )		//"Inativo"
	oBrowse:DisableDetails()
	oBrowse:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Claudio Donetti
@since 01/04/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GRRA020" OPERATION 1 ACCESS 0	//"Visualizar"
	// schedule, disponiveis somente a partir da release 2410
	If lR2410
		ADD OPTION aRotina TITLE STR0009	ACTION "callSchedule('GRRJobCommand')"	OPERATION MODEL_OPERATION_VIEW		ACCESS 0	//-- GRR Job Schedule
	EndIf

	// ADD OPTION aRotina TITLE STR0005	ACTION "GRRA020A" OPERATION 1 ACCESS 0	//Gerar Pedido"
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Claudio Donetti
@since 01/04/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel	:= NIL
	Local oStruHRD  := FWFormStruct( 1, 'HRD' )
	Local oStruHRE  := FWFormStruct( 1, 'HRE' )

	//-----------------------------------------
	//Para utilizar multiget no campo
	//-----------------------------------------
	oStruHRD:SetProperty( 'HRD_DESCRI', MODEL_FIELD_TIPO, 'M' )

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "GRRA020", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/ )
	oModel:SetDescription( STR0006 )	//"Modelo de Dados Receita Recorrente – Planos x Itens"

	oModel:AddFields( 'HRDMASTER', /*cOwner*/, oStruHRD )
	oModel:GetModel( 'HRDMASTER' ):SetPrimaryKey( { 'HRD_FILIAL', 'HRD_CODE' } )

	oModel:AddGrid( 'HREDETAIL' , 'HRDMASTER', oStruHRE )
	oModel:GetModel( 'HREDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'HREDETAIL' ):SetUniqueLine( { 'HRE_ITEM' } )
	oModel:GetModel( 'HREDETAIL' ):SetMaxLine( 999 )

	oModel:SetRelation( 'HREDETAIL', { { 'HRE_FILIAL', 'xFilial( "HRE" )' }, { 'HRE_PLAN', 'HRD_CODE' } }, HRE->( IndexKey(1) ) )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Claudio Donetti
@since 01/04/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local   oModel      :=  FWLoadModel( 'GRRA020' )
	Local   oStruHRD    :=  FWFormStruct( 2, 'HRD' )
	Local   oStruHRE    :=  FWFormStruct( 2, 'HRE' )
	Local   oView       :=  FWFormView():New()

	oStruHRE:RemoveField( "HRE_PLAN" )
	oStruHRE:RemoveField( "HRE_ITPLID" )
	oStruHRE:RemoveField( "HRE_ITEMID" )
	oStruHRE:RemoveField( "HRE_FILPRD" )

	oView:SetModel( oModel )
	oView:SetDescription( STR0001 )	//"Planos x Itens Recorrentes"

	/*-------------------------------------------
				Esrutura da View
	---------------------------------------------*/
	oView:AddField( 'GRRA020_HRD', oStruHRD, 'HRDMASTER' )
	oView:EnableTitleView( 'HRDMASTER', STR0007 )		//'Plano'

	oView:AddGrid( 'GRRA020_HRE', oStruHRE, 'HREDETAIL' )
	oView:EnableTitleView( 'GRRA020_HRE',  STR0008 )	//'Itens do Plano'
	oView:AddIncrementField( 'GRRA020_HRE', 'HRE_ITEM' )

	/*-----------------------------------------
			Estrutura do Folder
	-------------------------------------------*/
	oView:CreateHorizontalBox( 'FIELDSHRD', 55 )
	oView:CreateHorizontalBox( 'GRIDHRE',   45 )

	/*-----------------------------------------
	Amarração para exibição das informações
	-------------------------------------------*/
	oView:SetOwnerView( 'HRDMASTER', 'FIELDSHRD' )
	oView:SetOwnerView( 'HREDETAIL', 'GRIDHRE' )
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRVlPPayment
Avalia se a forma de pagamento pode ser utilizada pelo plano.

@param cAutoContent, caracter, conteúdo vindo pelo ADVPR

@return boolean, indica se a forma de pagamento está válida
@author Marcia Junko
@since 04/05/2022
/*/
//-------------------------------------------------------------------
Function GRRVlPPayment( cAutoContent )
	LOCAL cVar      := AllTrim( ReadVar() )
	LOCAL cContent := &( cVar )
	Local cOption := ''
	Local nI := 0
	Local aContent := {}
	Local lRet := .F.

	Default cAutoContent := ""

	IF !Empty( cAutoContent )
		cContent := cAutoContent
	EndIf

	iF !Empty( cContent )
		aContent := StrTokArr2( Alltrim( cContent ), "|" )
		cOption := GRRPlanCbx(  )
		
		For nI := 1 to len( aContent )
			lRet := aContent[ nI ] + "=" $ cOption

			If !lRet
				Exit
			EndIf
		Next
	EndIf
Return lRet 
