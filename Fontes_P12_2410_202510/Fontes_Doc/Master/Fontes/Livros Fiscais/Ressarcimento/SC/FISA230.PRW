#Include "FISA230.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISA230
  
DRCST - Demonstrativo para Apuração Mensal do Ressarcimento, da Restituição e da Complementação do 
ICMS Substituição Tributária, do Estado de Santa Catarina.
O método de apuração é determinado pelo Decreto Nº 1818 DE 28/11/2018 e pela Portaria SEF N° 378/2018.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FISA230()
	Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
	Private oBrowse
	Private oPanelBrw		

    If lVerpesssen
		If AliasIndic("F1I") .And. AliasIndic("F1J") .And. AliasIndic("F1K") .And. AliasIndic("F1L") .And. AliasIndic("F1M") .And. AliasIndic("F2W") .And. AliasIndic("F3M")
			DbSelectArea ("F1I")
			DbSelectArea ("F1J")
			DbSelectArea ("F1K")
			DbSelectArea ("F1L")
			DbSelectArea ("F1M")
			DbSelectArea ("F2W")
			DbSelectArea ("F3M")

			//---Carga inicial do Cadastro de Regras para Movimentos---//
			FwMsgRun(,{|oSay| FISA233C(oSay) }, STR0001, "") //---Processando Carga Inicial de Regras para Movimentos...---//

			FWExecView(STR0002,'FISA230', MODEL_OPERATION_INSERT,, { || .T. } ,{ || .T. }  ) //---Apuração do Ressarcimento, Restituição e Complementação do ICMS ST---//

		Else
			MsgStop(STR0003) //---Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias.---//
		EndIf
	EndIf 

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação de menu [MVC].

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu("FISA230")


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para criação do modelo [MVC].

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStruct := FWFormStruct(1,'F1I')

	oModel := MPFormModel():New('MODEL_MAIN',,{|oModel| .T. },{|oModel| .T. })
	oModel:AddFields('MODEL_MAIN',,oStruct)
	oModel:SetDescription('TOTVS')
Return oModel


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criação da view [MVC].

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel('FISA230')
Local oStruct := FWFormStruct(2,'F1I')
Local oView   := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('VIEW_MAIN', oStruct, 'MODEL_MAIN')

oView:AddOtherObject( 'PANEL_TREE'  ,{|oPanel| MONTATREE(oPanel)} )
oView:AddOtherObject( 'PANEL_EMPTY' ,{|oPanel| })
oView:AddOtherObject( 'PANEL_BROWSE',{|oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel )} )

oView:EnableTitleView('PANEL_TREE',STR0004) //---Rotinas Disponíveis---//

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

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaTree(oPanel)
Local oTree
Local aCoors  := FWGetDialogSize(oPanel)
Local bChange := {|| FChgTree(oTree,oPanel) }

oTree := DbTree():New(aCoors[1]+20, aCoors[2]+5, aCoors[3]-10, aCoors[4]-10, oPanel, bChange,, .T.)

oTree:AddTree(STR0005, .T., "FOLDER5" ,"FOLDER6",,,"000") //---Ressarcimento, Restituição e Complementação do ICMS ST---//
oTree:TreeSeek("001")
oTree:AddItem(STR0006,"001","BPMSEDT3","",,,2) //---Apuração do Ressarcimento /Restituição /Complementação---//
oTree:AddItem(STR0007,"002","BPMSEDT3","",,,2) //---Regras para Movimentos---//
oTree:AddItem(STR0008,"003","BPMSEDT3","",,,2) //---Relatório de Conferência---//
oTree:AddItem(STR0009,"004","BPMSEDT3","",,,2) //---Geração do Arquivo---//

Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FChgTree 

@author Ulisses P. Oliveira
@since 27/03/2019
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
aInfTree := FSA230FUNC(cIdTreePos,oTree)
FBrowseMon(oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4], aInfTree[5])
oBrowse:Refresh()

Return Nil


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function FBrowseMon(oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw, aFields)

Local cFunc := "MethIsMemberOf"

Default cFonteTree := ""
Default cAliasTree := ""
Default cFiltroBrw := ""
Default cDescBrw   := ""
Default aFields    := {}

oBrowse := FWmBrowse():New()

If &cFunc.(oBrowse,"SetMainProc")
	oBrowse:SetMainProc(cFonteTree)
EndIf

If Empty(cFonteTree) .And. Empty(cAliasTree)
	aInf       := FSA230FUNC()
	cFonteTree := aInf[1]
	cAliasTree := aInf[2]
	cFiltroBrw := aInf[3]
	cDescBrw   := aInf[4]
	aFields    := aInf[5]
EndIf

oBrowse:SetOwner( oPanel )
oBrowse:SetDescription( cDescBrw )
oBrowse:SetAlias( cAliasTree )

oBrowse:SetMenuDef( cFonteTree )
oBrowse:DisableDetails()
oBrowse:SetFilterDefault( cFiltroBrw )
oBrowse:SetOnlyFields(aFields)

oBrowse:Activate()

Return Nil


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FSA230FUNC
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Ulisses P. Oliveira
@since 27/03/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Function FSA230FUNC(cIdTreePos,oTree)
Local aRet      := Array(05)
Local lF1I_ORIG := F1I->(FieldPos("F1I_ORIGEM")) > 0

Do Case
	Case Empty(cIdTreePos)
		aRet[1] := 'FISA232'
		aRet[2] := 'F1I'
		aRet[3] := "@F1I_FILIAL = " + ValToSql(xFilial("F1I")) + Iif(lF1I_ORIG, " AND (F1I_ORIGEM = 'FISA230' OR F1I_ORIGEM = '')", "")
		aRet[4] := STR0002 //---Apuração do Ressarcimento, Restituição e Complementação do ICMS ST---//
		aRet[5] := {'F1I_FILIAL','F1I_ANOMES','F1I_SDREST','F1I_SDRESS','F1I_SDCOMP','F1I_SDICOP','F1I_VLACRE','F1I_VLACOM'}
	Case cIdTreePos == "001"
        FISA231()
		oTree:TreeSeek('000')
	Case cIdTreePos == "002"
        aRet[1] := "FISA233"
		aRet[2] := "F2W"
		aRet[3] := "F2W_FILIAL == " + ValToSql(xFilial("F2W"))
		aRet[4] := STR0010 //---Cadastro de Regras para Movimentos - Ressarcimento ICMS-ST---//
		aRet[5] := {'F2W_FILIAL','F2W_CFOP','F2W_DECFOP'}
	Case cIdTreePos == "003"		        
		FISR230()	
		oTree:TreeSeek('000')
	Case cIdTreePos == "004"
		FISA234()	
		oTree:TreeSeek('000')
	OtherWise
		aRet[1] := ""
		aRet[2] := ""
		aRet[3] := ""
		aRet[4] := ""
		aRet[5] := {}
EndCase

Return aRet
