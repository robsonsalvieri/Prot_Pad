#Include "FISA196.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA196
  
Rotina de Apuração do ICMS Presumido e Efetivo.
Para o Estado de Rio Grande do Sul, o método de apuração é determinado pela decreto 54.308.

@author bruce.mello
@since 22/01/2019
@version 1.0

/*/
//---

Function FISA196()
	Private oBrowse
	Private oPanelBrw		
	Private lAutomato := Iif(IsBlind(),.T.,.F.)

    If AliasIndic("F3Q") .And. AliasIndic("F3R") .And. AliasIndic("F3S") .And. AliasIndic("F3T") 
		DbSelectArea ("F3Q") // Apur. ICMS rec. anteriormente
		DbSelectArea ("F3R") // Apur. ICMS Rec. Ant. Det. Item
		DbSelectArea ("F3S") // Apur. ICMS Rec. Ant. Detalhada
		DbSelectArea ("F3T") // Cadastro de Regra

		//Faz Chamada para verificação da carga inicial dos cadastros
		FwMsgRun(,{|oSay| F198Carga( oSay ) },STR0001,"") //"Processando carga inicial das Regras"
		//---Carga inicial do Cadastro de Regras para Movimentos---//
		FwMsgRun(,{|oSay| FISA196BC( oSay ) },STR0013,"") //---Processando Carga Inicial de Regras para Movimentos...---//

		FWExecView(STR0002,'FISA196', MODEL_OPERATION_INSERT,, { || .T. } ,{ || .T. }  ) //"Apur. ICMS Rec. Anteriormente"
    Else
		If !lAutomato
        	MsgStop(STR0003) //"Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias."
		EndIF
    EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação de menu [MVC].

@author Bruce.Mello
@since 22/01/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu("FISA196")

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para criação do modelo [MVC].

@author Bruce.Mello
@since 22/01/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStruct := FWFormStruct(1,'F3Q')

	oModel := MPFormModel():New('MODEL_MAIN',,{|oModel| .T. },{|oModel| .T. })
	oModel:AddFields('MODEL_MAIN',,oStruct)
	oModel:SetDescription('TOTVS')
Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criação da view [MVC].

@author Bruce.Mello
@since 22/01/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel('FISA196')
Local oStruct := FWFormStruct(2,'F3Q')
Local oView   := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_MAIN', oStruct, 'MODEL_MAIN')

oView:AddOtherObject( 'PANEL_TREE'  ,{|oPanel| MONTATREE(oPanel)} )
oView:AddOtherObject( 'PANEL_EMPTY' ,{|oPanel| })
oView:AddOtherObject( 'PANEL_BROWSE',{|oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel )} )

oView:EnableTitleView('PANEL_TREE',STR0004) //"Rotinas Disponíveis"

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

@author Bruce.Mello
@since 22/01/2019
@version 12.1.17

/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaTree(oPanel)
Local oTree
Local aCoors  := FWGetDialogSize(oPanel)
Local bChange := {|| FChgTree(oTree,oPanel) }

oTree := DbTree():New(aCoors[1]+20, aCoors[2]+5, aCoors[3]-10, aCoors[4]-10, oPanel, bChange,, .T.)

oTree:AddTree(STR0008, .T., "FOLDER5" ,"FOLDER6",,,"000") //"ICMS ST Rec. Anteriormente"
oTree:TreeSeek("001")
oTree:AddItem(STR0005,"001","PMSEDT3","",,,2) // Apuração
oTree:AddItem(STR0006,"002","PMSEDT3","",,,2) // Regras de Apuração
oTree:AddItem(STR0011,"003","PMSEDT3","",,,2) // Regras para Movimentos
oTree:AddItem(STR0007,"004","PMSEDT3","",,,2) // Relatório de Conferência

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FChgTree 

@author Bruce.Mello
@since 22/01/2019
@version 12.1.17

/*/
//--------------------------------------------------------------------------------------------------
Static Function FChgTree(oTree) 
Local cIdTreePos := ""
Local aInfTree   := {}

//---Busco a identificação de qual item da Tree estamos posicionadoss---//
cIdTreePos := oTree:GetCargo()
oPanelBrw:FreeChildren()
oBrowse:DeActivate()
aInfTree := FSA196FUNC(cIdTreePos,oTree)
FBrowseMon(oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4])
oBrowse:Refresh()

Return Nil

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon

@author Bruce.Mello
@since 22/01/2019
@version 12.1.17

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
	oBrowse:SetMainProc("FISA196")
EndIf

If Empty(cFonteTree) .And. Empty(cAliasTree)
	aInf       := FSA196FUNC()
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

If !lAutomato
	oBrowse:Activate()
EndIF

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA196FUNC
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Bruce.Mello
@since 22/01/2019
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA196FUNC(cIdTreePos,oTree)
Local aRet := Array(04)

Do Case
	Case Empty(cIdTreePos)
		aRet[1] := 'FISA196A'
		aRet[2] := 'F3Q'
		aRet[3] := ""
		aRet[4] := STR0009 //  "Apuração do ICMS ST Recolhido Anteriormente"
	Case cIdTreePos == "001"
        FISA196APU()
		oTree:TreeSeek('000')
	Case cIdTreePos == "002"
        aRet[1] 	:= 'FISA198'
		aRet[2] 	:= "F3T"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0010  //"Cadastro de Regras da Apuração por Código de Ajuste" 
	Case cIdTreePos == "003"
        aRet[1] 	:= 'FISA196B'
		aRet[2]		:= "F2W"
		aRet[3]		:= "F2W_FILIAL == " + ValToSql(xFilial("F2W"))
		aRet[4] 	:= STR0012  //"Cadastro de Regras para Movimentos - Ressarcimento ICMS-ST" 
	Case cIdTreePos == "004"        
		FISR196()	
		oTree:TreeSeek('000')
	
	OtherWise
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
EndCase

Return aRet

