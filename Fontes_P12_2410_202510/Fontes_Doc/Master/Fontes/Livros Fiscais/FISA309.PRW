#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA309.CH"

//------------------------------------------------------------------
/*/{Protheus.doc} FISA309

Rotina para cadastro e geração do arquivo SCANC REF.

@author Delleon Fernandes
@since 10/02/2023
@version 12.1.2210
/*/
//------------------------------------------------------------------
Function FISA309(lAutomato)

	Private oBrowse    := Nil
	Private oPanelBrw  := Nil
	Private c309Quadro := "" // Utilizo para definir filtro no Browser dos quadros. Antentar com os espaços também.
	Private lAutFis309 := .F.

	Default lAutomato := .F.

	lAutFis309 := lAutomato

	If ChkFile("CJO")
		// If !lAutFis309
		FWExecView(STR0001,'FISA309', MODEL_OPERATION_INSERT,, { || .T. } ,{ || .T. }  ) // "Processamento SCANC REF"
		// Endif
	Else
		Help("",1,"Help","Help",STR0002,1,0) // "Dicionário desatualizado, favor verificar atualizações do fiscal."
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Delleon Fernandes
@since 10/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
Return ( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Delleon Fernandes
@since 10/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStructABA := FWFormStruct( 1, 'CJO')

	oModel := MPFormModel():New('MODEL_ABA',,{|oModel| .T. },{|oModel| .T. })
	oModel:AddFields( 'MODEL_ABA' ,, oStructABA )
	oModel:SetPrimaryKey( { 'ABA_CMP1'} )
	oModel:SetDescription( 'TOTVS')

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Delleon Fernandes
@since 10/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel    := FWLoadModel( 'FISA309' )
	Local oView     := FWFormView():New()
	Local oStruABA  := FWFormStruct( 2, 'CJO' )

	oView:SetModel( oModel )

	oView:AddField( 'VIEW_ABA', oStruABA, 'MODEL_ABA' )

	oView:AddOtherObject( 'PANEL_TREE',  { |oPanel| MONTATREE( oPanel ) } )
	oView:AddOtherObject( 'PANEL_EMPTY', { |oPanel| } )
	oView:AddOtherObject( 'PANEL_BROWSE',{ |oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel ) } )

	oView:EnableTitleView('PANEL_TREE',STR0003) //"Rotinas Disponíveis"

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
Função que cria tree com as rotinas disponíveis do SCANC

@author Delleon Fernandes
@since 10/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function MontaTree(oPanel)

	Local oTree
	Local bChange := { || FChgTree( oTree )  }
	Local aNodes  := {}
	Local IMAGE1  := "FOLDER5"
	Local IMAGE2  := "FOLDER6"
	Local Icon	  := "PMSEDT3"

	aadd(aNodes,{'00',"001","",STR0004,IMAGE1,IMAGE2}) // "SCANC REF "
	aadd(aNodes,{'01',"002","",STR0005 ,Icon,Icon})    // "Geração do arquivo"
	aadd(aNodes,{'01',"006","",STR0006 + STR0007,Icon,Icon})  // "ANEXO VI " + "Quadro 4.1"
	aadd(aNodes,{'01',"007","",STR0006 + STR0008,Icon,Icon})  // "ANEXO VI " + "Quadro 4.2"
	aadd(aNodes,{'01',"008","",STR0006 + STR0009,Icon,Icon})  // "ANEXO VI " + "Quadro 4.3"
	aadd(aNodes,{'01',"009","",STR0006 + STR0010,Icon,Icon})  // "ANEXO VI " + "Quadro 5"
	aadd(aNodes,{'01',"010","",STR0006 + STR0011,Icon,Icon})  // "ANEXO VI " + "Quadro 6.1"
	aadd(aNodes,{'01',"011","",STR0006 + STR0012,Icon,Icon})  // "ANEXO VI " + "Quadro 6.2"
	aadd(aNodes,{'01',"012","",STR0006 + STR0013,Icon,Icon})  // "ANEXO VI " + "Quadro 6.3"
	aadd(aNodes,{'01',"013","",STR0006 + STR0014,Icon,Icon})  // "ANEXO VI " + "Quadro 7.1"
	aadd(aNodes,{'01',"014","",STR0006 + STR0015,Icon,Icon})  // "ANEXO VI " + "Quadro 7.2"
	aadd(aNodes,{'01',"015","",STR0006 + STR0016,Icon,Icon})  // "ANEXO VI " + "Quadro 7.3"
	aadd(aNodes,{'01',"016","",STR0006 + STR0017,Icon,Icon})  // "ANEXO VI " + "Quadro 8"
	aadd(aNodes,{'01',"017","",STR0006 + STR0018,Icon,Icon})  // "ANEXO VI " + "Quadro 9.1"
	aadd(aNodes,{'01',"018","",STR0006 + STR0019,Icon,Icon})  // "ANEXO VI " + "Quadro 9.2"
	aadd(aNodes,{'01',"019","",STR0006 + STR0020,Icon,Icon})  // "ANEXO VI " + "Quadro 9.3"
	aadd(aNodes,{'01',"020","",STR0006 + STR0021,Icon,Icon})  // "ANEXO VI " + "Quadro 10"
	aadd(aNodes,{'01',"021","",STR0006 + STR0022,Icon,Icon})  // "ANEXO VI " + "Quadro 11"
	aadd(aNodes,{'01',"022","",STR0006 + STR0023,Icon,Icon})  // "ANEXO VI " + "Quadro 12"
	aadd(aNodes,{'01',"023","",STR0006 + STR0024,Icon,Icon})  // "ANEXO VI " + "Quadro 13"
	aadd(aNodes,{'01',"024","",STR0006 + STR0025,Icon,Icon})  // "ANEXO VI " + "Quadro 14"
	aadd(aNodes,{'01',"025","",STR0006 + STR0026,Icon,Icon})  // "ANEXO VI " + "Quadro 15"

	oSize := FwDefSize():New(.T.,,,.T.)
	oSize:AddObject('PANEL_TREE'  ,100,100,.T.,.T.)
	oSize:lProp 	:= .T. // Proporcional
	oSize:aMargins 	:= { 0, 0, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3
	oSize:Process()

	oTree := DbTree():New( ;
		oSize:GetDimension("PANEL_TREE", "LININI"),;
		oSize:GetDimension("PANEL_TREE", "COLINI"),;
		oSize:GetDimension("PANEL_TREE", "YSIZE")*0.97,;
		oSize:GetDimension("PANEL_TREE", "COLEND")*0.26,;
		oPanel, bChange , , .T. )
	oTree:PTSendTree( aNodes )
	oTree:CurrentNodeId := "000"
	oTree:TreeSeek("000")
	oTree:SetScroll(1,.T.)
	oTree:SetScroll(2,.T.)
	oTree:PTRefresh()

Return ()

//-------------------------------------------------------------------
/*/{Protheus.doc} FChgTree 
Adiciona ações para cada nó do Tree	 

@author Delleon Fernandes
@since 10/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------

Static Function FChgTree(oTree)

	Local cIdTreePos := ""
	Local aInfTree   := {}

	//Busco a identificação de qual item da Tree estamos posicionados
	oTree:PTRefresh()
	cIdTreePos := oTree:CurrentNodeId
	oPanelBrw:FreeChildren()
	oBrowse:DeActivate()

	aInfTree := FSA309FUNC( cIdTreePos )
	FBrowseMon( oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4], aInfTree[5])
	oBrowse:Refresh()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon
Browser para cada nó que selecionar

@author Delleon Fernandes
@since 14/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function FBrowseMon( oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw, cIndxBrw )

	Default cFonteTree := ""
	Default cAliasTree := ""
	Default cFiltroBrw := ""
	Default cDescBrw   := ""
	Default cIndxBrw   := ""

	oBrowse := FWmBrowse():New()

	If MethIsMemberOf(oBrowse,"SetMainProc")
		oBrowse:SetMainProc("FISA309")
	EndIf

	If !Empty(cAliasTree)
		oBrowse:SetOwner( oPanel )
		oBrowse:SetDescription( cDescBrw )
		oBrowse:SetAlias( cAliasTree )

		oBrowse:SetMenuDef( cFonteTree )
		oBrowse:DisableDetails()
		oBrowse:SetFilterDefault( cFiltroBrw )

		oBrowse:Activate()
	EndIF

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA309FUNC
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Delleon Fernandes
@since 13/02/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Function FSA309FUNC( cIdTreePos )

	Local aRet := Array( 05 )

	Do Case
	Case cIdTreePos == "002" // "Geração do arquivo"
		FISA309AR()
		aRet[1] 	:= ''
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= "" //"Geração do arquivo"

	Case cIdTreePos == "006" // "Quadro 4.1"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q4' .And. CJO->CJO_SUBQUA == '1'"
		aRet[4] 	:= STR0004 + STR0006 + STR0007 // "SCANC REF ANEXO VI Quadro 4.1"
		c309Quadro  := "A6#Q4#1"

	Case cIdTreePos == "007" // "Quadro 4.2"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q4' .And. CJO->CJO_SUBQUA == '2'"
		aRet[4] 	:= STR0004 + STR0006 + STR0008 // "SCANC REF ANEXO VI Quadro 4.2"
		c309Quadro  := "A6#Q4#2"

	Case cIdTreePos == "008" // "Quadro 4.3"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q4' .And. CJO->CJO_SUBQUA == '3'"
		aRet[4] 	:= STR0004 + STR0006 + STR0009 // "SCANC REF ANEXO VI Quadro 4.3"
		c309Quadro  := "A6#Q4#3"

	Case cIdTreePos == "009" // "Quadro 5"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q5' .And. CJO->CJO_SUBQUA == ' '"
		aRet[4] 	:= STR0004 + STR0006 + STR0010 // "SCANC REF ANEXO VI Quadro 5"
		c309Quadro  := "A6#Q5# "

	Case cIdTreePos == "010" // "Quadro 6.1"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q6' .And. CJO->CJO_SUBQUA == '1'"
		aRet[4] 	:= STR0004 + STR0006 + STR0011 // "SCANC REF ANEXO VI Quadro 6.1"
		c309Quadro  := "A6#Q6#1"

	Case cIdTreePos == "011" // "Quadro 6.2"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q6' .And. CJO->CJO_SUBQUA == '2'"
		aRet[4] 	:= STR0004 + STR0006 + STR0012 // "SCANC REF ANEXO VI Quadro 6.2"
		c309Quadro  := "A6#Q6#2"

	Case cIdTreePos == "012" // "Quadro 6.3"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q6' .And. CJO->CJO_SUBQUA == '3'"
		aRet[4] 	:= STR0004 + STR0006 + STR0013 // "SCANC REF ANEXO VI Quadro 6.3"
		c309Quadro  := "A6#Q6#3"

	Case cIdTreePos == "013" // "Quadro 7.1"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q7' .And. CJO->CJO_SUBQUA == '1'"
		aRet[4] 	:= STR0004 + STR0006 + STR0014 // "SCANC REF ANEXO VI Quadro 7.1"
		c309Quadro  := "A6#Q7#1"

	Case cIdTreePos == "014" // "Quadro 7.2"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q7' .And. CJO->CJO_SUBQUA == '2'"
		aRet[4] 	:= STR0004 + STR0006 + STR0015 // "SCANC REF ANEXO VI Quadro 7.2"
		c309Quadro  := "A6#Q7#2"

	Case cIdTreePos == "015" // "Quadro 7.3
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q7' .And. CJO->CJO_SUBQUA == '3'"
		aRet[4] 	:= STR0004 + STR0006 + STR0016 // "SCANC REF ANEXO VI Quadro 7.3"
		c309Quadro  := "A6#Q7#3"

	Case cIdTreePos == "016" // "Quadro 8"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q8' .And. CJO->CJO_SUBQUA == ' '"
		aRet[4] 	:= STR0004 + STR0006 + STR0017 // "SCANC REF ANEXO VI Quadro 8"
		c309Quadro  := "A6#Q8# "

	Case cIdTreePos == "017" // "Quadro 9.1"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q9' .And. CJO->CJO_SUBQUA == '1'"
		aRet[4] 	:= STR0004 + STR0006 + STR0018 // "SCANC REF ANEXO VI Quadro 9.1"
		c309Quadro  := "A6#Q9#1"

	Case cIdTreePos == "018" // "Quadro 9.2"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q9' .And. CJO->CJO_SUBQUA == '2'"
		aRet[4] 	:= STR0004 + STR0006 + STR0019 // "SCANC REF ANEXO VI Quadro 9.2"
		c309Quadro  := "A6#Q9#2"

	Case cIdTreePos == "019" // "Quadro 9.3"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q9' .And. CJO->CJO_SUBQUA == '3'"
		aRet[4] 	:= STR0004 + STR0006 + STR0020 // "SCANC REF ANEXO VI Quadro 9.3"
		c309Quadro  := "A6#Q9#3"

	Case cIdTreePos == "020" // "Quadro 10"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q10' .And. CJO->CJO_SUBQUA == ' '"
		aRet[4] 	:= STR0004 + STR0006 + STR0021 // "SCANC REF ANEXO VI Quadro 10"
		c309Quadro  := "A6#Q10# "

	Case cIdTreePos == "021" // "Quadro 11"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q11' .And. CJO->CJO_SUBQUA == ' '"
		aRet[4] 	:= STR0004 + STR0006 + STR0022 // "SCANC REF ANEXO VI Quadro 11"
		c309Quadro  := "A6#Q11# "

	Case cIdTreePos == "022" // "Quadro 12"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q12' .And. CJO->CJO_SUBQUA == ' '"
		aRet[4] 	:= STR0004 + STR0006 + STR0023 // "SCANC REF ANEXO VI Quadro 12"
		c309Quadro  := "A6#Q12# "

	Case cIdTreePos == "023" // "Quadro 13"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q13' .And. CJO->CJO_SUBQUA == ' '"
		aRet[4] 	:= STR0004 + STR0006 + STR0024 // "SCANC REF ANEXO VI Quadro 13"
		c309Quadro  := "A6#Q13# "

	Case cIdTreePos == "024" // "Quadro 14"
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q14' .And. CJO->CJO_SUBQUA == ' '"
		aRet[4] 	:= STR0004 + STR0006 + STR0025 // "SCANC REF ANEXO VI Quadro 14"
		c309Quadro  := "A6#Q14# "

	Case cIdTreePos == "025" // "Quadro 15
		aRet[1] 	:= 'FISA310'
		aRet[2] 	:= "CJO"
		aRet[3] 	:= "CJO->CJO_ANEXO == 'A6' .And. CJO->CJO_QUADRO == 'Q15' .And. CJO->CJO_SUBQUA == ' '"
		aRet[4] 	:= STR0004 + STR0006 + STR0026 // "SCANC REF ANEXO VI Quadro 15"
		c309Quadro  := "A6#Q15# "

	OtherWise
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= ""
		c309Quadro  := ""
	EndCase

Return ( aRet )

//-----------------------------------------------------------------------
/*/{Protheus.doc} FISA309AR
	(Chamada de geração do arquivo SCANC REF Anexo VI)

	@type  Static Function
	@author Delleon Fernandes
	@since 13/02/2023
	@version 12.1.2210
/*/
//-----------------------------------------------------------------------
Static Function FISA309AR()
	Local aPerg   	:= {}
	Local aParam  	:= {Space(6),Space(2),Space(250),Space(250),Padr("1-Não",11)}
	Local cParScanc := SM0->M0_CODIGO+SM0->M0_CODFIL+"FISA309"
	Local lObrigat  := .F.
	Local aFil      := {}
	Local oProcess
	Local lEnd      := .F.

	Local cMesAno  := ""
	Local cUfDest  := ""
	Local cDestArq := ""
	Local cNomeArq := ""
	Local cSelecFil:= ""
	Local lSelecFil:= .F.

	aadd(aPerg,{1,STR0029,aParam[01],"999999",".T.","",".T.",30,lObrigat}) // "Mês / Ano Referência"
	aadd(aPerg,{1,STR0030,aParam[02],"@!",'ExistCpo("SX5","12"+MV_PAR02)',"12",".T.",30,lObrigat}) // "Uf Destinatário"
	aadd(aPerg,{6,STR0031,aParam[03],"","FISA309Vld(mv_par03)","!empty(mv_par03)",80,lObrigat,"Arquivos TXT |*.TXT","",GETF_RETDIRECTORY+GETF_LOCALHARD,.T.}) // "Diretório de destino"
	aadd(aPerg,{1,STR0032,aParam[04],"",".T.","",".T.",100,lObrigat}) // "Nome do arquivo"
	aadd(aPerg,{2,STR0033, "1-Não", {"1-Não","2-Sim"},40,".T.",lObrigat,}) // "Seleciona Filiais"

	aParam[01] := ParamLoad(cParScanc,aPerg,1,aParam[01])
	aParam[02] := ParamLoad(cParScanc,aPerg,2,aParam[02])
	aParam[03] := ParamLoad(cParScanc,aPerg,3,aParam[03])
	aParam[04] := ParamLoad(cParScanc,aPerg,4,aParam[04])
	aParam[05] := ParamLoad(cParScanc,aPerg,5,aParam[05])

	If ParamBox(aPerg,STR0034,@aParam,,,,,,,cParScanc,.T.,.T.) // "Arquivo SCANC REF"

		cMesAno  := MV_PAR01
		cUfDest  := MV_PAR02
		cDestArq := Alltrim(MV_PAR03)
		cNomeArq := Alltrim(MV_PAR04)
		cSelecFil:= MV_PAR05
		lSelecFil:= Substr(cSelecFil,1,1)=='2'

		If lSelecFil
			// If lAutFis309
			// 	aFil := MatFilCalc( .F., {.T., cFilAnt} )
			// Else
			// Chama função para usuário escolher filial
			aFil := MatFilCalc( .T.,,,,,,.T. )
			// EndIf
		Else
			aFil := {{.T., cFilAnt}}
		EndIf

		oProcess:= FISProgress():New({|lEnd| lEnd := FISA309PROC(@lEnd, oProcess, cMesAno, cUfDest, cDestArq, cNomeArq, aFil) }, STR0036) // "Aguarde, exportando arquivos"
		oProcess:Activate()

	EndIf

Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} FISA309Vld
Verifica se o diretório de destino para exportação do TXT existe.

@author  Delleon Fernandes
@since   13/02/2023
@version 12.1.2210
/*/
//-----------------------------------------------------------------------
Function FISA309Vld(cDestino)

	Local lOk := .T.

	If !Empty(cDestino)
		lOk := ExistDir( Alltrim(cDestino), , .f.)
	EndIf

	If !lOk
		Help(NIL, NIL, "Help", NIL, STR0027, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0028}) // "Caminho para destino do arquivo não existe!"  "Informe um caminho existente"
	EndIf

Return lOk

//-----------------------------------------------------------------------
/*/{Protheus.doc} FISA309PROC
Função para implementar a classe do arquivo e gerar o arquivo magnetico
@type function
@version  12.1.2210
@author rodrigo.ccandido
@since 17/02/2023
@param cMesAno, character, param_description
@param cUfDest, character, param_description
@param cDestArq, character, param_description
@param cNomeArq, character, param_description
@param aFil, array, param_description
@return variant, return_description
/*/
//-----------------------------------------------------------------------
Static Function FISA309PROC(lEnd, oProcess, cMesAno, cUfDest, cDestArq, cNomeArq, aFil)

	Local nI 		:= 0
	Local aFiliais	:= {}
	Local cFilePath := cDestArq + cNomeArq
	Local oWriter 	:= FWFileWriter():New(cFilePath, .T., 30000)
	Local oScancRefFileWriter := Nil
	Local oFile 	:= Nil
	Local cFileName	:= ""
	Local TimeFim   := Time()
	Local TimeIni   := Time()
	Local cSucessArq:= ""

	If oWriter:Exists()
		oWriter:Erase()
	EndIf

	oProcess:SetDetProgress(STR0041,TimeIni,; // "Início do Processamento"
	STR0042, "",; // "Fim Do processamento"
	STR0043, "","","") // "Tempo de processamento"

	If !oWriter:Create()
		oProcess:Inc1Progress(STR0038) // "Não foi possível gerar o arquivo"
		oProcess:Inc2Progress(oWriter:Error():Message)

		TimeFim := Time()
		oProcess:SetDetProgress(STR0041,TimeIni,; // "Início do Processamento"
		STR0042, TimeFim,; // "Fim do Processamento"
		STR0043, ELAPTIME(TimeIni,TimeFim),"","") // "Tempo de Processamento"

		Return .F.
	Endif

	oScancRefFileWriter := backoffice.fiscal.arquivos.estadual.scancref.file.ScancRefFileWriter():New(oWriter)

	For nI := 1 To Len(aFil)
		If aFil[nI][1]
			aADD(aFiliais, aFil[nI][2])
		EndIf
	Next nI

	For nI := 1 To Len(aFiliais)

		oProcess:Inc1Progress(STR0040 + aFiliais[nI]) // "Processando Filial : "
		oProcess:Inc2Progress(STR0044) // "Processando registros"
		oProcess:Inc2Progress(STR0045) // "Gerando arquivo"
		oScancRefFileWriter:write(StrZero(nI, 4), cMesAno, cUfDest, aFiliais[nI])

	Next nI

	If oWriter:Exists()

		oProcess:Inc2Progress(STR0046) // "Analizando arquivo"

		cFileName := oWriter:cFilename

		oWriter:Close()

		oFile := FWFileReader():New(cFileName)

		If oFile:Open() .AND. oFile:getFileSize() > 0
			cSucessArq := " - " + STR0039 + cFileName // "Arquivo criado no diretório "
			oFile:Close()
		EndIf

	EndIf

	oProcess:Inc2Progress(STR0047 + cSucessArq) // "Concluído"
	TimeFim := Time()
	oProcess:SetDetProgress(STR0041,TimeIni,; // "Início do Processamento"
	STR0042, TimeFim,; // "Fim do Processamento"
	STR0043, ELAPTIME(TimeIni,TimeFim),"","") // "Tempo de Processamento"

	oScancRef := Nil
	oWriter := Nil
	oFile := Nil

	FreeObj(oScancRef)
	FreeObj(oWriter)
	FreeObj(oFile)

Return .T.
