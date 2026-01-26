#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA312.CH"
#Include "Dbstruct.ch"


//-------------------------------------------------------------------
/*/{Protheus.doc} FISA312
Rotina que irá fazer o cadastro das informações para o registro 1601 do SPED FISCAL, com opção de importação de infos do financeiro.

@author Matheus Massarotto_
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Function FISA312

if aliasindic("CJQ") .and. aliasindic("CJR") .and. aliasindic("CJS")
    Private oBrowse
	Private oPanelBrw

    FWExecView(STR0001,'FISA312', MODEL_OPERATION_INSERT,,{ || .T. }, { || .T. } )//'Opções com instrumentos de pagamentos eletrônicos para o registro 1601'
else
	Help(" ",1,"Help","Help",STR0002,1,0)//'Dicionário desatualizado, favor verificar atualizações do Dicionário de dados'
endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu
@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}

	ADD OPTION aRotina TITLE STR0003 ACTION 'FSA312A' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'FSA312A' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'FSA312A' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'FSA312A' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'PERG313()'	OPERATION 3 ACCESS 0 // Processar valores do financeiro

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStructABA := FWFormStruct( 1, 'CJQ')

	oModel	:=	MPFormModel():New('MODEL_ABA')
    
	oModel:AddFields( 'MODEL_ABA' ,, oStructABA )
	oModel:SetPrimaryKey( { 'ABA_CMP1'} )
	oModel:SetDescription( 'TOTVS')

Return oModel



//-------------------------------------------------------------------
/*/{Protheus.doc} FSA312A
Funcao para chamada do MVC de manutenção no cadastro de movimento de apuração.

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Function FSA312A(cAlias,nReg,nOpc)
    
    FISA313(cAlias,nReg,nOpc)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Matheus Massarotto
@since 17/04/2023
@version 12.1.2210
/*/
//---------------------------------------------------------------------
Static Function ViewDef()
	Local oModel    := FWLoadModel( 'FISA312' )
	Local oView     := FWFormView():New()
	Local oStruABA  := FWFormStruct( 2, 'CJQ' )

	oView:SetModel( oModel )

	oView:AddField( 'VIEW_ABA', oStruABA, 'MODEL_ABA' )

	oView:AddOtherObject( 'PANEL_TREE',  { |oPanel| MONTATREE( oPanel ) } )
	oView:AddOtherObject( 'PANEL_EMPTY', { |oPanel| } )
	oView:AddOtherObject( 'PANEL_BROWSE',{ |oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel ) } )

	oView:EnableTitleView('PANEL_TREE',STR0029)//'Rotinas Disponíveis'

	oView:CreateHorizontalBox( 'INFO_FUNC'	  	,00 )
	oView:CreateHorizontalBox( 'EVENTO_FUNC'	,98 )
	oView:CreateHorizontalBox( 'FIM_TELA'   	,02 )

	oView:CreateVerticalBox( 'INFO_FUNC_ESQ'		, 100	,'INFO_FUNC' )
	oView:CreateVerticalBox( 'EVENTO_FUNC_ESQ'		, 27	,'EVENTO_FUNC' )
	oView:CreateVerticalBox( 'EVENTO_FUNC_CENTER'	, 01	,'EVENTO_FUNC' )
	oView:CreateVerticalBox( 'EVENTO_FUNC_DIR'		, 72	,'EVENTO_FUNC' )
	oView:CreateVerticalBox( 'FIM_TELA_EMPTY'		, 100	, 'FIM_TELA' )

	oView:SetOwnerView( 'VIEW_ABA'		, 'INFO_FUNC_ESQ' )
	oView:SetOwnerView( 'PANEL_TREE'	, 'EVENTO_FUNC_ESQ' )
	oView:SetOwnerView( 'PANEL_EMPTY'	, 'EVENTO_FUNC_CENTER' )
	oView:SetOwnerView( 'PANEL_BROWSE'	, 'EVENTO_FUNC_DIR' )
	oView:SetOwnerView( 'PANEL_EMPTY'	, 'FIM_TELA_EMPTY' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTree
Função que cria tree com as rotinas disponíveis
 
@author Matheus Massarotto
@since 03/05/2023
@version 12.1.2210

/*/
//-------------------------------------------------------------------

STATIC FUNCTION MontaTree(oPanel)

	Local oTree
	Local aCoors := {}
	Local bChange := { || FChgTree( oTree )  }

	oSize := FwDefSize():New(.T.,,,.T.)
	oSize:AddObject('PANEL_TREE'  ,100,100,.T.,.T.)
	oSize:lProp 	:= .T. // Proporcional
	oSize:aMargins 	:= { 0, 0, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3
	oSize:Process()

	aAdd(aCoors,{oSize:GetDimension("PANEL_TREE", "COLINI"),oSize:GetDimension("PANEL_TREE", "LININI"),oSize:GetDimension("PANEL_TREE", "YSIZE")*0.97,oSize:GetDimension("PANEL_TREE", "COLEND")*0.26})

	oTree := DbTree():New( aCoors[1][2], aCoors[1][1], aCoors[1][3], aCoors[1][4], oPanel,bChange , , .T. )

	oTree:AddTree( Padr(STR0026,40), .T., "FOLDER5" ,"FOLDER6",,,"000" )//"Movimentos de operações com instrumentos pagtos eletônicos"
	oTree:TreeSeek( "000" )
	oTree:AddItem(STR0007,"001","PMSEDT3","",,,2) //"Processar valores do financeiro"
	IF Findfunction('FISA314')
		oTree:AddItem(STR0027,"002","PMSEDT3","",,,2)//"Forma de pagamento por regime"
	EndIf

return (nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} FChgTree
 
@author Matheus Massarotto
@since 03/05/2023
@version 12.1.2210

/*/
//-------------------------------------------------------------------

Static Function FChgTree( oTree )

	Local cIdTreePos := ""

	Local aInfTree := {}

	//Busco a identificação de qual item da Tree estamos posicionadoss
	cIdTreePos := oTree:GetCargo()
	oPanelBrw:FreeChildren()
	oBrowse:DeActivate()
	aInfTree := FSA312FUNC( cIdTreePos ,oTree)
	FBrowseMon( oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4] )
	oBrowse:Refresh()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon
 
@author Matheus Massarotto
@since 03/05/2023
@version 12.1.2210

/*/
//-------------------------------------------------------------------
Static Function FBrowseMon( oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw )

	Local aInf := {}
	Local cFunc := "MethIsMemberOf"

	Default cFonteTree := ""
	Default cAliasTree := ""
	Default cFiltroBrw := ""
	Default cDescBrw   := ""

	oBrowse := FWmBrowse():New()

	If &cFunc.(oBrowse,"SetMainProc")
		oBrowse:SetMainProc(cFonteTree)
	EndIf


	If Empty( cFonteTree ) .And. Empty( cAliasTree )
		aInf := FSA312FUNC()

		cFonteTree := aInf[1]
		cAliasTree := aInf[2]
		cFiltroBrw := aInf[3]
		cDescBrw   := aInf[4]

	EndIf

	oBrowse:SetOwner( oPanel )
	oBrowse:SetDescription( cDescBrw )
	oBrowse:SetAlias( cAliasTree )

	oBrowse:SetMenuDef( cFonteTree )
	oBrowse:DisableDetails()
	oBrowse:SetFilterDefault( cFiltroBrw )

	oBrowse:Activate()

Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA312FUNC
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Matheus Massarotto
@since 03/05/2023
@version 12.1.2210

/*/
//-------------------------------------------------------------------
Function FSA312FUNC( cIdTreePos ,oTree, aReprocess, aAutoFil)

	Local aRet   		:= Array( 04 )
	Default aReprocess	:= {}
	Default aAutoFil	:= {{.T., cFilAnt}}
	Default cIdTreePos 	:= ""

	Do Case

	Case EmptY(cIdTreePos)
		aRet[1] := 'FISA312'
		aRet[2] := 'CJQ'
		aRet[3] := ""
		aRet[4] := STR0028 //"Rotina de apuração dos movimentos com instrumentos pagtos eletônicos"  
	Case cIdTreePos == "001"
		
        PERG313(aAutoFil)

		If !IsBlind()
        	oTree:TreeSeek('000')
		Endif	

	Case cIdTreePos == "002"
		aRet[1] := 'FISA314'
		aRet[2] := 'CJS'
		aRet[3] := ""
		aRet[4] := STR0027 //"Forma de pagto por regime"//
	OtherWise
		aRet[1] := ""
		aRet[2] := ""
		aRet[3] := ""
		aRet[4] := ""
	EndCase

Return ( aRet )

