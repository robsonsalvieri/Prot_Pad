#Include "FISA202.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA202
  
Rotina de Apuração do Ressarcimento ou Complemento do ICMS Retido por Substituição Tributária.
Para o Estado de Minas Gerais, o método de apuração é determinado pelo decreto 47.457/2018.

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA202()
	Private oBrowse
	Private oPanelBrw		

    If AliasIndic("F3X") .And. AliasIndic("F3Y")
		DbSelectArea ("F3X")
		DbSelectArea ("F3Y")

		FWExecView(STR0001,'FISA202', MODEL_OPERATION_INSERT,, { || .T. } ,{ || .T. }  ) //STR0001 //"Apuração do Ressarcimento do ICMS Retido por ST"
    Else
        MsgStop(STR0002) //STR0002 //"Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias."
    EndIf

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação de menu [MVC].

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu("FISA202")


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para criação do modelo [MVC].

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStruct := FWFormStruct(1,'F3X')

	oModel := MPFormModel():New('MODEL_MAIN',,{|oModel| .T. },{|oModel| .T. })
	oModel:AddFields('MODEL_MAIN',,oStruct)
	oModel:SetDescription('TOTVS')
Return oModel


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criação da view [MVC].

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel('FISA202')
Local oStruct := FWFormStruct(2,'F3X')
Local oView   := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_MAIN', oStruct, 'MODEL_MAIN')

oView:AddOtherObject( 'PANEL_TREE'  ,{|oPanel| MONTATREE(oPanel)} )
oView:AddOtherObject( 'PANEL_EMPTY' ,{|oPanel| })
oView:AddOtherObject( 'PANEL_BROWSE',{|oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel )} )

oView:EnableTitleView('PANEL_TREE',STR0003) //STR0003 //"Rotinas Disponíveis"

oView:CreateHorizontalBox( 'INFO_FUNC'	  	,00 )
oView:CreateHorizontalBox( 'EVENTO_FUNC'	,98 )
oView:CreateHorizontalBox( 'FIM_TELA'   	,02 )

oView:CreateVerticalBox( 'INFO_FUNC_ESQ'		, 100	,'INFO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_ESQ'		, 27	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_CENTER'	, 01	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_DIR'		, 72	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'FIM_TELA_EMPTY'		, 100	, 'FIM_TELA' )

oView:SetOwnerView( 'VIEW_MAIN'		, 'INFO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_TREE'	, 'EVENTO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'EVENTO_FUNC_CENTER' )
oView:SetOwnerView( 'PANEL_BROWSE'	, 'EVENTO_FUNC_DIR' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'FIM_TELA_EMPTY' )

Return oView       


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaTree
Função que cria tree com as rotinas disponíveis

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaTree(oPanel)
Local oTree
Local aCoors  := FWGetDialogSize(oPanel)
Local bChange := {|| FChgTree(oTree,oPanel) }

oTree := DbTree():New(aCoors[1]+20, aCoors[2]+5, aCoors[3]-10, aCoors[4]-10, oPanel, bChange,, .T.)

oTree:AddTree(STR0004, .T., "FOLDER5" ,"FOLDER6",,,"000") //STR0004 //"Ressarcimento do ICMS Retido por ST"
oTree:TreeSeek("001")
oTree:AddItem(STR0005 ,"001","PMSEDT3","",,,2) //STR0005 //"Apuração do Ressarcimento / Complemento"
oTree:AddItem(STR0006 ,"002","PMSEDT3","",,,2) //STR0006 //"Relatório de Conferência"

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FChgTree 

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function FChgTree(oTree) 
Local cIdTreePos := ""
Local aInfTree   := {}

//---Busco a identificação de qual item da Tree estamos posicionadoss---//
cIdTreePos := oTree:GetCargo()
oPanelBrw:FreeChildren()
oBrowse:DeActivate()
aInfTree := FSA202FUNC(cIdTreePos,oTree)
FBrowseMon(oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4])
oBrowse:Refresh()

Return Nil


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function FBrowseMon(oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw)

Local cFunc := "MethIsMemberOf"

Default cFonteTree := ""
Default cAliasTree := ""
Default cFiltroBrw := ""
Default cDescBrw   := ""

oBrowse := FWmBrowse():New()

If &cFunc.(oBrowse,"SetMainProc")
	oBrowse:SetMainProc("FISA202")
EndIf

If Empty(cFonteTree) .And. Empty(cAliasTree)
	aInf       := FSA202FUNC()
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

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA202FUNC
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Eduardo Vicente da Silva
@since 21/02/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function FSA202FUNC(cIdTreePos,oTree)
Local aRet := Array(04)

Do Case
	Case Empty(cIdTreePos)
		aRet[1] := 'FISA204'
		aRet[2] := 'F3X'
		aRet[3] := ""
		aRet[4] := STR0001  //STR0001 //"Apuração do Ressarcimento do ICMS Retido por ST"
	Case cIdTreePos == "001"
        FISA203()
		oTree:TreeSeek('000')	
	Case cIdTreePos == "002"		        
		FISR202()	
		oTree:TreeSeek('000')
	OtherWise
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= ""
EndCase

Return aRet
