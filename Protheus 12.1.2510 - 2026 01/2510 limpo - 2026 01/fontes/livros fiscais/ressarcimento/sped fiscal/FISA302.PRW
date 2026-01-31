#Include "FISA302.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
Fonte responsavel pela Tela inicial -- FISA190
*/

/*/{Protheus.doc} FISA302()

    Rotina Responsavel pela apuração do ressarcimento de ICMS ST com base no modelo apresentado no leiaute 014  de 2019 do EFD SPED FISCAL
    
    @author Rafael.soliveira
    @since 04/11/2019
    @version 1.0
    /*/
Function FISA302()
    Private oBrowse
	Private oPanelBrw		
	Private lAutomato := Iif(IsBlind(),.T.,.F.)

    If AliasIndic("CIG") .and. AliasIndic("CIH") .and. AliasIndic("CII") .and. AliasIndic("CIJ") .and. AliasIndic("CIK") .and. AliasIndic("CIL") .and. AliasIndic("CIF") .and. AliasIndic("CIM") 
		//DbSelectArea ("CIF") //Cadastro Código de Motivos de Restituição e Complementação de ICMS
        DbSelectArea ("CIG") //Apuração  ressarcimento Total
        DbSelectArea ("CIH") //Apuração ressarcimento ICMS SPED - Totais por Enquadramento
        DbSelectArea ("CII") //Apuração ressarcimento ICMS SPED - Detalhe por item
        DbSelectArea ("CIJ") //Apuração ressarcimento ICMS SPED - Enquadramento Cabeçalho
        DbSelectArea ("CIK") //Apuração ressarcimento ICMS SPED - Enquadramento por Item
        DbSelectArea ("CIL") //Apuração ressarcimento ICMS SPED - Saldo

		//Faz Chamada para verificação da carga inicial dos cadastros
		FwMsgRun(,{|oSay| FISA302Carga( oSay ) },STR0001,"") //"Processando carga inicial das Regras"
		FwMsgRun(,{|oSay| F302CCarga( oSay ) },STR0001,"") //"Processando carga inicial das Regras"

		FWExecView(STR0002,'FISA302', MODEL_OPERATION_INSERT,, { || .T. } ,{ || .T. }  ) //"Apuração de Restituição ou complemento de ICMS ST"
    Else
		If !lAutomato
        	MsgStop(STR0003) //"Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias."
		EndIF
    EndIf


Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para criação de menu [MVC].

@author Rafael.soliveira
@since 04/11/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu("FISA302")

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para criação do modelo [MVC].

@author Rafael.soliveira
@since 04/11/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStruct := FWFormStruct(1,'CIG')

	oModel := MPFormModel():New('MODEL_MAIN',,{|oModel| .T. },{|oModel| .T. })
	oModel:AddFields('MODEL_MAIN',,oStruct)
	oModel:SetDescription('TOTVS')
Return oModel

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criação da view [MVC].

@author Rafael.soliveira
@since 04/11/2019
@version 1.0

/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel  := FWLoadModel('FISA302')
Local oStruct := FWFormStruct(2,'CIG')
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

@author Rafael.soliveira
@since 04/11/2019
@version 12.1.17

/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaTree(oPanel)
Local oTree
Local aCoors  := FWGetDialogSize(oPanel)
Local bChange := {|| FChgTree(oTree,oPanel) }

oTree := DbTree():New(aCoors[1]+20, aCoors[2]+5, aCoors[3]-10, aCoors[4]-10, oPanel, bChange,, .T.)

oTree:AddTree(STR0005, .T., "FOLDER5" ,"FOLDER6",,,"000") //"Ressarcimento do ICMS Retido por ST ou Antecipado"
oTree:TreeSeek("001")
oTree:AddItem(STR0006,"001","PMSEDT3","",,,2) //"Apuração do Ressarcimento / Complemento"
oTree:AddItem(STR0007,"002","PMSEDT3","",,,2) //"Saldos Iniciais"
oTree:AddItem(STR0008,"003","PMSEDT3","",,,2) //"Enquadramento de Apuração"
oTree:AddItem(STR0009,"004","PMSEDT3","",,,2) //"Regras por CFOP e CST"
oTree:AddItem(STR0011,"005","PMSEDT3","",,,2) //"Cadastro de Código de motivo de Restituição e Complemento"
oTree:AddItem(STR0010,"006","PMSEDT3","",,,2) //"Relatório de Conferência"  
oTree:EndTree()

oTree:AddTree(STR0012, .T., "FOLDER5" ,"FOLDER6",,,"007") //"Geração de Arquivos"
oTree:TreeSeek("007")
oTree:AddItem(STR0013,"008","PMSEDT3","",,,2) //"Restituição ST MG"
oTree:EndTree()

oTree:TreeSeek("000")

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FChgTree 

@author Rafael.soliveira
@since 04/11/2019
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
aInfTree := FSA302FUNC(cIdTreePos,oTree)
FBrowseMon(oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4])
oBrowse:Refresh()

Return Nil

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon

@author Rafael.soliveira
@since 04/11/2019
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
	oBrowse:SetMainProc("FISA302")
EndIf

If Empty(cFonteTree) .And. Empty(cAliasTree)
	aInf       := FSA302FUNC()
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
/*/{Protheus.doc} FSA302FUNC
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Rafael.soliveira
@since 04/11/2019
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA302FUNC(cIdTreePos,oTree)
Local aRet := Array(04)

Do Case
	Case Empty(cIdTreePos)
		aRet[1] 	:= 'FISA302D'
		aRet[2] 	:= 'CIG'
		aRet[3] 	:= ""
		aRet[4] 	:= STR0006 //  "Apuração do Ressarcimento / Complemento"		
	Case cIdTreePos == "001"
        FISA302C()
		oTree:TreeSeek('000')
	Case cIdTreePos == "002"
        aRet[1] 	:= 'FISA302B'
		aRet[2] 	:= "CIL"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0007  //"Saldos Iniciais"		
    Case cIdTreePos == "003"
        aRet[1] 	:= 'FISA302F'
		aRet[2] 	:= "CIM"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0008 //"Enquadramento de Apuração"		
    Case cIdTreePos == "004"		        
        aRet[1] 	:= "FISA302E"
		aRet[2] 	:= "CIJ"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0009 //"Regras por CFOP e CST"		
	Case cIdTreePos == "005"		        
        aRet[1] 	:= "FISA301"
		aRet[2] 	:= "CIF"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0011 //"Cadastro de codigo"	
	Case cIdTreePos == "006"        
		FISR302()			   //"Relatório de Conferência" 
		oTree:TreeSeek('000') 
	Case cIdTreePos == "008"        
		FISA302G()			   //"Geração de Arquivo Ressarcimento ST MG"
		oTree:TreeSeek('000') 
	OtherWise
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
EndCase

Return aRet
