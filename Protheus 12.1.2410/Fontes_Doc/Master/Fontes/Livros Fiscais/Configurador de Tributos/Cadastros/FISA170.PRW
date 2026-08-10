
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA170.CH"

PUBLISH MODEL REST NAME FISA170 SOURCE FISA170

#DEFINE	cNodFin	'200'

STATIC lCustoEstoque //Verifica se possui funcionalidades regra de custo

//------------------------------------------------------------------
/*/{Protheus.doc} FISA170

Rotina com a concetração de todos os cadastros do motor fiscal tributário

@author Erick G. Dias
@since 21/06/1028
@version 12.1.17

/*/
//------------------------------------------------------------------
Function FISA170(lAutomato)

	Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
	Private oBrowse
	Private oPanelBrw
	Private lclicked     := .T.
	Private lclickedI     := .T.
	Private lclickedO     := .T.
	Private c170AlsHist  := ""

	Default lAutomato := .F.

    If lVerpesssen
		If AliasIndic("F20")

			DbSelectArea ("F20")
			DbSelectArea ("F21")
			DbSelectArea ("F22")
			DbSelectArea ("F23")
			DbSelectArea ("F24")
			DbSelectArea ("F25")		
			DbSelectArea ("F26")
			DbSelectArea ("F27")
			DbSelectArea ("F28")
			DbSelectArea ("F29")
			DbSelectArea ("F2A")
			DbSelectArea ("F2B")
			DbSelectArea ("F2C")
			DbSelectArea ("F2E")
			DbSelectArea ("F2F")
			DbSelectArea ("F2G")
			DbSelectArea ("F2H")
			DbSelectArea ("F2I")
			DbSelectArea ("F2J")
			DbSelectArea ("F2K")
			DbSelectArea ("F2L") 
			DbSelectArea ("F2M")
			DbSelectArea ("F2N")
			If AliasIndic("CIQ") .and. AliasIndic("CIR")
				DbSelectArea ("CIQ")
				DbSelectArea ("CIR")
			Endif
			If AliasIndic("CIS") .AND. AliasIndic('CIT') .AND. AliasIndic('CIU')
				DbSelectArea ("CIS")
				DbSelectArea ("CIT")
				DbSelectArea ("CIU")
				DbSelectArea ("CIZ")
			Endif
			If AliasIndic("CIV")
				DbSelectArea ("CIv")
			EndIf
			If AliasIndic("CIX") .And. AliasIndic("CIY")
				DbSelectArea ("CIX")
				DbSelectArea ("CIY")
			EndIf
			If AliasIndic("CJ0") .And. AliasIndic("CJ1")
				DbSelectArea ("CJ0")
				DbSelectArea ("CJ1")
			EndIf
			If AliasIndic("CJ2")
				DbSelectArea ("CJ2")
			EndIf			
			If AliasIndic("CJ4")
				DbSelectArea ("CJ4")
			EndIf
			If AliasIndic("CJ5") .And. AliasIndic("CJ6") .And. AliasIndic("CJ7")
				DbSelectArea ("CJ5")
				DbSelectArea ("CJ6")
				DbSelectArea ("CJ7")
			EndIf
			If AliasIndic('F0R') 
				DbSelectArea ("F0R")
			Endif
			if AliasIndic('CJ8') 
				DbSelectArea ("CJ8")
			Endif

			//Ajuste de Dicionario Valid do campo F24_CDPROD
			FSA166X3()

			//Faz Chamada para verificação da carga inicial dos cadastros			
			FwMsgRun(,{|oSay| x170Carga(lAutomato,  oSay ) },STR0001,"") //"Processando carga inicial dos perfis"
			
			If !lAutomato
				FWExecView(STR0002,'FISA170', MODEL_OPERATION_INSERT,, { || .T. } ,{ || .T. }  ) //"Rotinas do Motor de Cálculo de Tributos Fiscais"
			Endif
		Else
			Alert(STR0003) //"Dicionário desatualizado, favor verificar atualizações do motor de cálculo fiscal."
		EndIf
	EndIf 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
 
Local aRotina := {}

Return ( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStructABA := FWFormStruct( 1, 'F2B')

oModel	:=	MPFormModel():New('MODEL_ABA',,{|oModel| .T. },{|oModel| .T. })
oModel:AddFields( 'MODEL_ABA' ,, oStructABA )
oModel:SetPrimaryKey( { 'ABA_CMP1'} )
oModel:SetDescription( 'TOTVS')

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel    := FWLoadModel( 'FISA170' )
Local oView     := FWFormView():New()
Local oStruABA   := FWFormStruct( 2, 'F2B' )

oView:SetModel( oModel )

oView:AddField( 'VIEW_ABA', oStruABA, 'MODEL_ABA' )

//Retiro o ID da view
oStruABA:RemoveField('F2B_ID')

oView:AddOtherObject( 'PANEL_TREE',  { |oPanel| MONTATREE( oPanel ) } )
oView:AddOtherObject( 'PANEL_EMPTY', { |oPanel| } )
oView:AddOtherObject( 'PANEL_BROWSE',{ |oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel ) } )

oView:EnableTitleView('PANEL_TREE',STR0005) //"Rotinas Disponíveis"

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

oView:AddUserButton(STR0046,"", {|| x174Rotinas() }) //"Relação de Rotinas"

Return oView       

//-------------------------------------------------------------------
/*/{Protheus.doc} x174Rotinas

@author joao.pellegrini
@since 26/10/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function x174Rotinas(lAutomato)

Local oDialog := NIL
Local aRotinas := {}
Local aLines := {}
Local aSize := MsAdvSize()
Local oBrwRot := NIL
Local oColluns := NIL
Local oPanel := NIL
Local nX := 0
Local aData := {}

Default lAutomato := .F.


aAdd(aRotinas, {"FISA170.PRW", STR0084}) //"Fonte principal do configurador de tributos"
aAdd(aRotinas, {"FISA168.PRW", STR0007}) //"Tributo"
aAdd(aRotinas, {"FISA167.PRW", STR0008}) //"Unidade Ref. Fiscal"
aAdd(aRotinas, {"FISA160A.PRW",STR0063}) //"Regra de tabela Progressiva"
aAdd(aRotinas, {"FISA160B.PRW",STR0064}) //"Regras por NCM"
aAdd(aRotinas, {"FISA160C.PRW",STR0065}) //"Regra por Dependentes"
aAdd(aRotinas, {"FISA160D.PRW",STR0072}) //"Regras por ISS"
aAdd(aRotinas, {"FISA160H.PRW",STR0085}) //"Histórico de alterações da rotina"
aAdd(aRotinas, {"FISA160I.PRW",STR0073}) //"Código Situação Tributária"
aAdd(aRotinas, {"FISA160K.PRW",STR0086}) //"Acertos Fiscais dos Tributos Genéricos"
aAdd(aRotinas, {"FISA160L.PRW",STR0077}) //"Guia de Escrituração"
aAdd(aRotinas, {"FISA160M.PRW",STR0076}) //"Guia de Escrituração"
aAdd(aRotinas, {"FISA121.PRW",STR0079})  //"Indicadores Econômicos FCA"

aAdd(aRotinas, {"FisCompFor.PRW",STR0087}) //"Componentes das Fórmulas" 
aAdd(aRotinas, {"FisFormula.PRW",STR0088}) //"Execução das Fórmulas"

aAdd(aRotinas, {"FISA163.PRW", STR0014}) //"Perfil de Origem/Destino"
aAdd(aRotinas, {"FISA164.PRW", STR0013}) //"Perfil de Participante"
aAdd(aRotinas, {"FISA165.PRW", STR0012}) //"Perfil de Operação"
aAdd(aRotinas, {"FISA166.PRW", STR0011}) //"Perfil de Produto"

aAdd(aRotinas, {"CALCODLAN.PRW", STR0089 }) //"Códigos de Lançamento"
aAdd(aRotinas, {"FISA181.PRW"  , STR0090 }) //"Regras de Lançamento"
aAdd(aRotinas, {"FISXDESCR.prw", STR0091 }) //"Conversor de Referências da Matxfis"

aAdd(aRotinas, {"FISA161.PRW", STR0009}) //"Regra de Base de Cálculo"
aAdd(aRotinas, {"FISA162.PRW", STR0010}) //"Regra de Alíquota"
aAdd(aRotinas, {"FISA160J.PRW",STR0074}) //"Regra de Escrituração"
aAdd(aRotinas, {"FISA160.PRW", STR0016}) //"Regra de Cálculo - Documentos Fiscais"
aAdd(aRotinas, {"FISA178.PRW", STR0092})  //"Cadastro de Mensagem"

aAdd(aRotinas, {"FISA169.PRW", STR0015}) //"Regra de Apuração"
aAdd(aRotinas, {"FISA171.PRW", STR0047}) //"dor de Manutenção - Perfis Tributários"
aAdd(aRotinas, {"FISA172.PRW", STR0048}) //"Facilitador de Amarração - Perfis Tributários"
aAdd(aRotinas, {"FISA173.PRW", STR0018}) //"Apuração dos Tributos Genéricos"
aAdd(aRotinas, {"FISA174.PRW", STR0049}) //"Visualização da Apuração"
aAdd(aRotinas, {"FISA174AJU.PRW", STR0050}) //"Detalhamento dos Ajustes de Apuração"
aAdd(aRotinas, {"FISA174DET.PRW", STR0051}) //"Detalhamento dos Saldos de Apuração"
aAdd(aRotinas, {"FISA175.PRW", STR0055}) //"Processamento da Apuração"
aAdd(aRotinas, {"FISA175WIZ.PRW", STR0052}) //"Wizard de Parametrização da Apuração"
aAdd(aRotinas, {"FISA176.PRW", STR0017}) //"Regra de Título da Apuração"
aAdd(aRotinas, {"FISR160.PRW", STR0042}) //"Relatório dos Tributos Genéricos por Documento Fiscal"
aAdd(aRotinas, {"FISR161.PRW", STR0057}) //"Relatório de Conferência de Apuração"
aAdd(aRotinas, {"FISR160A.PRW", STR0078}) //"Relatório de Conferência de Apuração"
aAdd(aRotinas, {"FISR181.PRW", STR0083}) //"Relatório de Conferência Estorno ICMS"

aAdd(aRotinas, {"FINA024CAL.PRW", STR0023}) //"Regra de Cálculo - Tìtulos Financeiros"
aAdd(aRotinas, {"FINA024CUM.PRW", STR0026}) //"Regra de Cumulatividade"
aAdd(aRotinas, {"FINA024DED.PRW", STR0021}) //"Regra de Dedução"
aAdd(aRotinas, {"FINA024RET.PRW", STR0025}) //"Regra de Retenção"
aAdd(aRotinas, {"FINA024RFI.PRW", STR0028}) //"Regra Financeira"
aAdd(aRotinas, {"FINA024TIT.PRW", STR0020}) //"Regra de Título"
aAdd(aRotinas, {"FINA024TPR.PRW", STR0022}) //"Regra de Tabelas Progressivas"
aAdd(aRotinas, {"FINA024VA.PRW",  STR0027}) //"Regra de Valores Acessórios"
aAdd(aRotinas, {"FINA024VCT.PRW", STR0024}) //"Regra de Vencimento"

aAdd(aRotinas, {"CONFXFIS.PRW", STR0093}) //"Motor de cálculo do Configurador de Tributos"
aAdd(aRotinas, {"IMPXFIS.PRW" , STR0053}) //"Rotina Auxiliar de Cálculo de Tributos"
aAdd(aRotinas, {"MATXFIS.PRX" , STR0054}) //"Rotina de Cálculo de Tributos"
aAdd(aRotinas, {"backoffice.fiscal.configurador.tax.classification.registration.tlpp", STR0097}) //'Tabela cClassTrib-IBS/CBS'

IF !lAutomato
	oDialog := FWDialogModal():New()
	oDialog:SetBackground(.T.) // .T. -> escurece o fundo da janela 
	oDialog:SetTitle(STR0046) //"Relação de Rotinas"
	oDialog:SetEscClose(.F.)//permite fechar a tela com o ESC
	oDialog:SetSize(aSize[4] * 0.8, aSize[3] * 0.8) // chamar sempre antes do CreateDialog
	oDialog:EnableFormBar(.T.) 
	oDialog:CreateDialog() //cria a janela (cria os paineis)
	oDialog:addCloseButton()
	oDialog:CreateFormBar()//cria barra de botoes

	// Crio as linhas do browse com base na lista de rotinas relacionadas
	For nX := 1 to Len(aRotinas)

		aData := GetAPOInfo( aRotinas[nX, 1] )

		If Len(aData) >= 5

			aAdd(aLines, {})
			aAdd(aLines[Len(aLines)], .F.)
			aAdd(aLines[Len(aLines)], aRotinas[nX, 1]) // Rotina
			aAdd(aLines[Len(aLines)], aRotinas[nX, 2]) // Descrição
			aAdd(aLines[Len(aLines)], DtoC(aData[4])) // Data no RPO
			aAdd(aLines[Len(aLines)], aData[5]) // Horário no RPO

		EndIf

	Next nX

	oPanel := oDialog:GetPanelMain()

	DEFINE FWBROWSE oBrwRot DATA ARRAY ARRAY aLines LINE BEGIN 1 OF oPanel

	ADD COLUMN oColluns DATA &("{ || aLines[oBrwRot:At()][2]}") TITLE STR0043 SIZE 10 OF oBrwRot // "Rotina"
	ADD COLUMN oColluns DATA &("{ || aLines[oBrwRot:At()][3]}") TITLE STR0056 SIZE 100 OF oBrwRot // "Descrição"
	ADD COLUMN oColluns DATA &("{ || aLines[oBrwRot:At()][4]}") TITLE STR0044 SIZE 10 OF oBrwRot // "Data no RPO"
	ADD COLUMN oColluns DATA &("{ || aLines[oBrwRot:At()][5]}") TITLE STR0045 SIZE 10 OF oBrwRot // "Hora no RPO"

	oBrwRot:OptionConfig(.F.)


	ACTIVATE FWBROWSE oBrwRot

	oDialog:Activate()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTree
Função que cria tree com as rotinas disponíveis

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

STATIC FUNCTION MontaTree(oPanel)

Local oTree
Local aCoors 	:= {} //FWGetDialogSize( oPanel )
Local bChange 	:= { || FChgTree( oTree )  }
Local aNodes	:= {}
Local IMAGE1 	:= "FOLDER5"
Local IMAGE2 	:= "FOLDER6"
Local Icon		:= "PMSEDT3"
Local lOnda2 	:= (AliasIndic("CIN") .and. FindFunction("FisExecNPI"))
Local lVersao 	:= GetVerRls()

aadd(aNodes,{'00',"000","",STR0006,IMAGE1,IMAGE2})  //"Regras Fiscais"
//*************************
//CADASTROS
//*************************
aadd(aNodes,{'01',"000","",STR0066,IMAGE1,IMAGE2})  //"Cadastros"
aadd(aNodes,{'02',"001","",STR0007 + Space(10),Icon,Icon})  //"Tributo"
aadd(aNodes,{'02',"002","",STR0008,Icon,Icon})  //"Unidade Ref. Fiscal"
IF lOnda2
	aadd(aNodes,{'02',"003","",STR0063,Icon,Icon})  //"Regra de Tabela Progressiva"
	aadd(aNodes,{'02',"004","",STR0064,Icon,Icon})  //"Regras por NCM"
	aadd(aNodes,{'02',"005","",STR0065,Icon,Icon})  //"Dependentes"
	aadd(aNodes,{'02',"006","",STR0072,Icon,Icon})  //"ISS"
	aadd(aNodes,{'02',"007","",STR0073,Icon,Icon})  //"CST
	aadd(aNodes,{'02',"008","",STR0077,Icon,Icon})  //"Guia de Escrituração"
	aadd(aNodes,{'02',"009","",STR0076,Icon,Icon})  //"Código da Receita"
EndIf
aadd(aNodes,{'02',"010","",STR0079,Icon,Icon})  //""Indicadores Econômicos FCA""
aadd(aNodes,{'02',"011","",STR0097,Icon,Icon})  //'Tabela cClassTrib-IBS/CBS'

//*************************
//PERFIS
//*************************
aadd(aNodes,{'01',"000","",STR0067,IMAGE1,IMAGE2})  //"Perfis"
aadd(aNodes,{'02',"021","",STR0011,Icon,Icon})  //"Perfil de Produto"
aadd(aNodes,{'02',"022","",STR0012,Icon,Icon})  //"Perfil de Operação"
aadd(aNodes,{'02',"023","",STR0013,Icon,Icon})  //"Perfil de Participante"
aadd(aNodes,{'02',"024","",STR0014,Icon,Icon})  //"Perfil de Origem/Destino"

//*************************
//REGRAS
//*************************
aadd(aNodes,{'01',"000","",STR0068,IMAGE1,IMAGE2})  //"Regras de Cálculo"
aadd(aNodes,{'02',"041","",STR0009,Icon,Icon})  //"Regra de Base de Cálculo"
aadd(aNodes,{'02',"042","",STR0010,Icon,Icon})  //"Regra de Alíquota"
If lOnda2
	aadd(aNodes,{'02',"043","",STR0074,Icon,Icon})  //"Regra de Escrituração"
EndIf
aadd(aNodes,{'02',"044","",STR0016,Icon,Icon})  //"Regra de Cálculo - Documentos Fiscais" 


//********************************
//REGRAS DE AJUSTES DE LANÇAMENTO
//********************************
If lVersao
	aadd(aNodes,{'01',"000","","Regra de Ajuste de Lançamento",IMAGE1,IMAGE2})  //"Regras de Ajuste de Lançamento"
	aadd(aNodes,{'02',"045","","Cadastro de Mensagem",Icon,Icon})  //""Cadastro de Mensagem""
	aadd(aNodes,{'02',"046","","Regra de Ajuste de Lançamento",Icon,Icon})  //"Regra de Ajuste de Lançamento"
Endif


//*************************
//APURAÇÂO
//*************************
aadd(aNodes,{'01',"000","",STR0069,IMAGE1,IMAGE2})  //"Apuração"
aadd(aNodes,{'02',"061","",STR0017,Icon,Icon})  //"Regra de Título da Apuração"
aadd(aNodes,{'02',"062","",STR0015,Icon,Icon})  //"Regra de Apuração"
aadd(aNodes,{'02',"063","",STR0018,Icon,Icon})  //"Apuração dos Tributos Genéricos"

//*************************
//RELATÓRIOS
//*************************
aadd(aNodes,{'01',"000","",STR0070,IMAGE1,IMAGE2})  //"Relatórios"
aadd(aNodes,{'02',"081","",STR0042,Icon,Icon})  //"Relatório dos Tributos Genéricos por Documento Fiscal"
aadd(aNodes,{'02',"082","",STR0078,Icon,Icon})  //"Relatório dos Tributos Genéricos por Documento Fiscal"
aadd(aNodes,{'02',"083","",STR0083,Icon,Icon})  //"Relatório dos Tributos Genéricos por Documento Fiscal"

//-----------------------------------------------------------------------------------------

aadd(aNodes,{'00',"200","",STR0019,IMAGE1,IMAGE2}) //"Regras Financeiras"
aadd(aNodes,{'01',"201","",STR0020,Icon,Icon})  //"Regra de Título"
aadd(aNodes,{'01',"202","",STR0021,Icon,Icon})  //"Regra de Dedução"
aadd(aNodes,{'01',"203","",STR0022,Icon,Icon})  //"Regra de Tabelas Progressivas"
aadd(aNodes,{'01',"204","",STR0023,Icon,Icon})  //"Regra de Cálculo - Tìtulos Financeiros"
aadd(aNodes,{'01',"205","",STR0024,Icon,Icon}) //"Regra de Vencimento"
aadd(aNodes,{'01',"206","",STR0025,Icon,Icon})  //"Regra de Retenção"
aadd(aNodes,{'01',"207","",STR0026,Icon,Icon})  //"Regra de Cumulatividade"
aadd(aNodes,{'01',"208","",STR0027,Icon,Icon}) //"Regra de Valores Acessórios"
aadd(aNodes,{'01',"209","",STR0028,Icon,Icon})  //"Regra Financeira"


// tratamento para disponibilizar os folders referente a regra de custo do modulo de estoque/custos
If HasCustEst()
	FISA170EST(@aNodes, "00", "300", {IMAGE1, IMAGE2}, {Icon, Icon}) // declaração no fonte FISA170xEST.PRW
EndIf


oSize := FwDefSize():New(.T.,,,.T.)
oSize:AddObject('PANEL_TREE'  ,100,100,.T.,.T.)
oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 0, 0, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process()

aAdd(aCoors,{oSize:GetDimension("PANEL_TREE", "COLINI"),oSize:GetDimension("PANEL_TREE", "LININI"),oSize:GetDimension("PANEL_TREE", "YSIZE")*0.97,oSize:GetDimension("PANEL_TREE", "COLEND")*0.26})

oTree := DbTree():New( aCoors[1][2], aCoors[1][1], aCoors[1][3], aCoors[1][4], oPanel,bChange , , .T. )
oTree:PTSendTree( aNodes )
oTree:CurrentNodeId := "000" 
oTree:TreeSeek("000")
oTree:SetScroll(1,.T.)
oTree:SetScroll(2,.T.)
//oTree:SetCss(GetCssTree())
oTree:PTRefresh()

Return ()

//-------------------------------------------------------------------
/*/{Protheus.doc} FChgTree 

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function FChgTree(oTree) 

Local cIdTreePos := ""

Local aInfTree := {}

//Busco a identificação de qual item da Tree estamos posicionadoss
oTree:PTRefresh()
cIdTreePos := oTree:CurrentNodeId
oPanelBrw:FreeChildren()
oBrowse:DeActivate()
aInfTree := FSA170FUNC( cIdTreePos )
FBrowseMon( oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4] , oTree:GetPrompt(.T.) == STR0019, cIdTreePos,aInfTree[5]) //"Regras Financeiras"
oBrowse:Refresh()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon

@author Erick G. Dias
@since 07/03/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function FBrowseMon( oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw, lFinanceiro, cIdTreePos, cIndxBrw )
Local cFunc := "MethIsMemberOf"

Default cFonteTree := ""
Default cAliasTree := ""
Default cFiltroBrw := ""
Default cDescBrw   := ""
Default cIndxBrw   := ""
Default cIdTreePos	:= "000"

oBrowse := FWmBrowse():New()

If &cFunc.(oBrowse,"SetMainProc")
	oBrowse:SetMainProc("FISA170")
EndIf

If Empty( cFonteTree ) .And. Empty( cAliasTree ) 
	aInf := FSA170FUNC("")

	cFonteTree := aInf[1]
	cAliasTree := aInf[2]
	cFiltroBrw := aInf[3]
	cDescBrw   := aInf[4]		
	cIndxBrw   := aInf[5]
EndIf

If !Empty(cAliasTree)
	oBrowse:SetOwner( oPanel )
	oBrowse:SetDescription( cDescBrw )
	oBrowse:SetAlias( cAliasTree )

	If (cIdTreePos >= "200" .And. cIdTreePos <= "300")
		(cAliasTree)->(DbSetOrder(2))
	EndIf

	IF !Empty(cIndxBrw)
		(cAliasTree)->(DbSetOrder(cIndxBrw))
	Endif

	Do Case
		Case cAliasTree == "FKK"
			oBrowse:AddLegend( "FKK_ATIVO == '1' " , "GREEN", STR0029 )  //"Regra Financeira Ativa"
			oBrowse:AddLegend( "FKK_ATIVO == '2' " , "RED"  , STR0030 )  //"Regra Financeira Inativa"
		Case cAliasTree == "F2H"
			oBrowse:AddLegend( "F2H_STATUS == '1' " , "BR_VERMELHO" , STR0031 ) //"Saldo Devedor - Não Gerou Título"
			oBrowse:AddLegend( "F2H_STATUS == '2' " , "BR_AMARELO"  , STR0032 ) //"Saldo Devedor - Título Gerado"
			oBrowse:AddLegend( "F2H_STATUS == '3' " , "BR_AZUL"     , STR0033 ) //"Saldo Credor"
			oBrowse:AddLegend( "F2H_STATUS == '4' " , "BR_BRANCO"   , STR0034 ) //"Sem Saldos"
			oBrowse:AddLegend( "F2H_STATUS == '5' " , "BR_VERDE"    , STR0035 ) //"Contabilizado"
		Case cAliasTree == "F2B" .and. F2B->(FieldPos("F2B_STATUS")) > 0
			oBrowse:AddLegend("F2B_STATUS == '1'", "YELLOW", "Regra em teste")
			oBrowse:AddLegend("F2B_STATUS == '2' .Or. F2B_STATUS == ' '", "GREEN", "Regra aprovada")
	EndCase

	oBrowse:SetMenuDef( cFonteTree )
	oBrowse:DisableDetails()
	oBrowse:SetFilterDefault( cFiltroBrw )

	oBrowse:Activate()
EndIF

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA170FUNC
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function FSA170FUNC( cIdTreePos )

Local aRet   			:= Array( 05 )


Do Case

	//*************************
	//CADASTROS
	//*************************
	Case cIdTreePos == "001" //Tributo
		aRet[1] 	:= 'FISA168'
		aRet[2] 	:= "F2E"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0007	 //"Tributo"	
	Case cIdTreePos == "002" // unidade referencial fiscal		
        aRet[1] 	:= 'FISA167'
		aRet[2] 	:= "F29"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0008 //"Unidade Ref. Fiscal"
	Case cIdTreePos == "003" //Tabela Progressiva
		aRet[1] 	:= 'FISA160A'
		aRet[2] 	:= IIF ((AliasIndic("CIQ") .and. AliasIndic("CIR")),"CIQ", HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0063	 //"Regra de Tabela Progressiva"
	Case cIdTreePos == "004" //Enquadramento por NCM
		aRet[1] 	:= 'FISA160B'
		aRet[2] 	:= IIF ((AliasIndic("CIS") .AND. AliasIndic('CIT') .AND. AliasIndic('CIU')),"CIS", HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0064	 //"Regras por NCM"

	Case cIdTreePos == "005" //Regra por Dependentes
        aRet[1] 	:= 'FISA160C'
		aRet[2] 	:= IIF ((AliasIndic("CIV")),"CIV", HelpDic() )
		aRet[3] 	:= "CIV_ALTERA == '2'"
		aRet[4] 	:= STR0065 //"Regra por Dependentes"
	
	Case cIdTreePos == "006" //Regra de ISS
        aRet[1] 	:= 'FISA160D'
		aRet[2] 	:= IIF ((AliasIndic("CIX") .And. AliasIndic("CIY") .And. AliasIndic("CIT")),"CIX", HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0072//"Regra por ISS"

	Case cIdTreePos == "007" //Cadastro de CST
        aRet[1] 	:= 'FISA160I'
		aRet[2] 	:= IIF( AliasIndic("CJ0") .And. AliasIndic("CJ1") ,"CJ0" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0073 //"Código Situação Tributária"
		aRet[5] 	:= 2// Indice a ser utilizado no browser

	Case cIdTreePos == "008" //Regras para geração da Guia de Escrituração
        aRet[1] 	:= 'FISA160L'
		aRet[2] 	:= IIF( AliasIndic("CJ4"),"CJ4" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0077
		aRet[5] 	:= 1// Indice a ser utilizado no browser

	Case cIdTreePos == "009" //Regras para geração da Guia de Escrituração
        aRet[1] 	:= 'FISA160M'
		aRet[2] 	:= IIF( AliasIndic("CJ5"),"CJ5" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0076
		aRet[5] 	:= 1// Indice a ser utilizado no 
	Case cIdTreePos == "010" //Indicadores Econômicos FCA (Fator de Conversão e Atualização)
        aRet[1] 	:= 'FISA121'
		aRet[2] 	:= IIF( AliasIndic("F0R"),"F0R" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0079
		aRet[5] 	:= 1// Indice a ser utilizado no browser			
	Case cIdTreePos == "011" 
        aRet[1] 	:= 'totvs.protheus.backoffice.fiscal.configurador.tax.classification.registration.TaxClassification'
		aRet[2] 	:= IIF( AliasIndic('CKB'),'CKB' , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= STR0097 //'Tabela CST cClassTrib'
		aRet[5] 	:= 1// Indice a ser utilizado no browser			

	//*************************
	//PERFIS
	//*************************
    Case cIdTreePos == "021" //Perfil de Produto		
        aRet[1] 	:= 'FISA166'
		aRet[2] 	:= "F20"
		aRet[3] 	:= "F20_TIPO == '04'"
		aRet[4] 	:= STR0011 //"Perfil de Produto"

    Case cIdTreePos == "022" // perfil de operação		
        aRet[1] 	:= 'FISA165'
		aRet[2] 	:= "F20"
        aRet[3] 	:= "F20_TIPO == '03'"
		aRet[4] 	:= STR0012 //"Perfil de Operação"

	Case cIdTreePos == "023" //Perfil de Participante		
        aRet[1] 	:= 'FISA164'
		aRet[2] 	:= "F20"
		aRet[3] 	:= "F20_TIPO == '02'"
		aRet[4] 	:= STR0013 //"Perfil de Participante"

	Case cIdTreePos == "024" //Perfil de Origem e Destino		
		aRet[1] 	:= 'FISA163'
		aRet[2] 	:= "F20"
		aRet[3] 	:= "F20_TIPO == '01'"
		aRet[4] 	:= STR0014 //"Perfil de Origem/Destino"

	//*************************
	//REGRAS
	//*************************
	Case cIdTreePos == "041"		        
        aRet[1] 	:= 'FISA161'
		aRet[2] 	:= "F27"
		aRet[3] 	:= "F27_ALTERA == '2'"
		aRet[4] 	:= STR0009 //"Regra de Base de Cálculo"

	Case cIdTreePos == "042" //Cadastro de Regra de Alíquota
        aRet[1] 	:= 'FISA162'
		aRet[2] 	:= "F28"
		aRet[3] 	:= "F28_ALTERA == '2'"
		aRet[4] 	:= STR0010 //"Regra de Alíquota"

	Case cIdTreePos == "043" //Cadastro de Regra de Escrituração
        aRet[1] 	:= 'FISA160J'
		aRet[2] 	:= IIF( AliasIndic("CJ2") ,"CJ2" , HelpDic() )
		aRet[3] 	:= "CJ2_ALTERA == '2'"
		aRet[4] 	:= STR0074 //"Regra de Escrituração"

	Case cIdTreePos == "044" //Regra de Cálculo
		aRet[1] 	:= 'FISA160'
		aRet[2] 	:= "F2B"
		aRet[3] 	:= Iif(F2B->(Fieldpos("F2B_ALTERA")) > 0,"F2B_ALTERA =='2' .or. Empty(F2B_ALTERA)","")
		aRet[4] 	:= STR0016 //"Regra de Cálculo - Documentos Fiscais"


	
	//********************************
	//REGRAS DE AJUSTES DE LANÇAMENTO
	//********************************
	Case cIdTreePos == "045"		        
        aRet[1] 	:= 'FISA178'
		aRet[2] 	:= IIF( AliasIndic("CJ8") ,"CJ8" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= "Cadastro de Mensagem"
	Case cIdTreePos == "046" //Cadastro de Regra de Ajuste de Lançamento.
        aRet[1] 	:= 'FISA181'
		aRet[2] 	:= IIF( AliasIndic("CJ9") .And. AliasIndic("CJA") ,"CJ9" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= "Regra de Ajuste de Lançamento"


	//*************************
	//APURAÇÂO
	//*************************
	Case cIdTreePos == "061"
		aRet[1] 	:= 'FISA176'
		aRet[2] 	:= "F2N"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0017 //"Regra de Título da Apuração"

	Case cIdTreePos == "062" //Regra de Apuração
		aRet[1] 	:= 'FISA169'
		aRet[2] 	:= "F2G"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0015 //"Regra de Apuração"

	Case cIdTreePos == "063"
		aRet[1] 	:= 'FISA173'
		aRet[2] 	:= "F2H"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0018 //"Apuração dos Tributos Genéricos"

	//*************************
	//RELATÓRIOS
	//*************************
	Case cIdTreePos == "081"
		FISR160()	
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= ""

	Case cIdTreePos == "082"
		FISR160A()	
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= ""

	Case cIdTreePos == "083"
		//totvs.protheus.backoffice.fiscal.relatorioEstornocredito()
		FISR181()
		aRet[1] 	:= ""
		aRet[2] 	:= IIF( AliasIndic("CJM") ,"CJM" , HelpDic() )
		aRet[3] 	:= ""
		aRet[4] 	:= ""

		//Menu Financeiro
	Case cIdTreePos == "200" // Motor Financeiro		
        aRet[1] 	:= ''
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= "" //"Motor Financeiro"
		
	Case cIdTreePos == "201" //Regra de Títulos
		aRet[1] 	:= 'FINA024TIT'
		aRet[2] 	:= "FKL"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0020 //"Regra de Título"
	
	Case cIdTreePos == "202" //Regra de Deduções
		aRet[1] 	:= 'FINA024DED'
		aRet[2] 	:= "FKV"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0021 //"Regra de Dedução"
		
	Case cIdTreePos == "203" //Regras Tabelas Progressivas
		aRet[1] 	:= 'FINA024TPR'
		aRet[2] 	:= "FKS"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0022 //"Regra de Tabelas Progressivas"
			
	Case cIdTreePos == "204" //Regra de Cálculo
		aRet[1] 	:= 'FINA024CAL'
		aRet[2] 	:= "FKN"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0023 //"Regra de Cálculo - Tìtulos Financeiros"
		
	Case cIdTreePos == "205" //Regra de Vencimento
		aRet[1] 	:= 'FINA024VCT'
		aRet[2] 	:= "FKP"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0024 //"Regra de Vencimento"

	Case cIdTreePos == "206" //Regra de Retenção
		aRet[1] 	:= 'FINA024RET'
		aRet[2] 	:= "FKO"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0025 //"Regra de Retenção"
	
	Case cIdTreePos == "207" //Regra de Cumulatividade
		aRet[1] 	:= 'FINA024CUM'
		aRet[2] 	:= "FKT"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0026 //"Regra de Cumulatividade"

	Case cIdTreePos == "208" //Regra Valores Acessórios
		aRet[1] 	:= 'FINA024VA'
		aRet[2] 	:= "FKU"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0027 //"Regra de Valores Acessórios"
	
	Case cIdTreePos == "209" //Regras Financeiras de Retenção
		aRet[1] 	:= 'FINA024RFI'
		aRet[2] 	:= "FKK"
		aRet[3] 	:= ""
		aRet[4] 	:= STR0028 //"Regra Financeira"

    OtherWise
		aRet[1] 	:= ""
		aRet[2] 	:= ""
		aRet[3] 	:= ""
		aRet[4] 	:= ""		      

   // Tratamento para adicionar o cadastro de regra de custo (MATA041) do modulo SIGAEST
	if HasCustEst() 
		if cIdTreePos == "301" //Regras Custo
			MATA041Inf(@aRet) // declaração no fonte MATA041.PRW
		EndIF
	EndIf

EndCase

Return ( aRet )

//------------------------------------------------------------------
/*/{Protheus.doc} x170Carga

Função que fará a chamada da carga inicial das tabelas de cadastros

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Function x170Carga( lAutomato, oSay ) 
Local lCIN := AliasIndic("CIN") .And. FindFunction("xFisFormul") .and. F2B->(FieldPos("F2B_ALTERA")) > 0 .and. F2B->(FieldPos("F2B_DTALT")) > 0  .and. F2B->(FieldPos("F2B_HRALT")) > 0
Local lCJ := AliasIndic("CJ1") .And. AliasIndic("CJ0")
Local lCK2 := AliasIndic("CK2") 
Local lF2BStatus := lCIN .and. F2B->(FieldPos("F2B_STATUS")) > 0
Local lCpoFNPIMemo := fisExtCmp( '12.1.2410' , .T., 'CIN' , 'CIN_FNPI_M' )

Default lAutomato	:= .F.

Begin Transaction

//Faz Carga inicial do perfil de Origem e Destino
AtualizaMsg( oSay, STR0036, lAutomato ) //"Processando carga inicial dos perfis de origem e destino"
FSA163CARG()

//Faz carga/atualização dos ID's internos dos tributos.
AtualizaMsg( oSay, STR0037, lAutomato ) //"Processando carga/atualização dos ID's internos"
FSA168F2C()

AtualizaMsg( oSay, STR0038, lAutomato ) //"Processando carga dos tributos"
FSA168F2E()

AtualizaMsg( oSay,  STR0039, lAutomato ) //"Processando carga dos perfis de operação"
FSA165CARG()

AtualizaMsg( oSay,  STR0040, lAutomato ) //"Processando carga das regras de apuração"
FSA169CARG()

If lCIN
	AtualizaMsg( oSay,  STR0058, lAutomato ) //"Processando carga dos operandos primários"
	FORMCARG()

	AtualizaMsg( oSay,  STR0062, lAutomato ) //"Processando carga Formulas de moedas estaduais"
	FSA167F29()	

	AtualizaMsg( oSay,  STR0061, lAutomato ) //"Processando carga Formulas de regras de Aliquota"
	FSA161F27()
	
	AtualizaMsg( oSay,  STR0060, lAutomato ) //"Processando carga Formulas de regras de base de cálculo"		
	FSA162F28()

	AtualizaMsg( oSay,  STR0059, lAutomato ) //"Processando carga Formulas de regras de cálculo dos tributos"
	FSA160F2B()

	If lF2BStatus
		AtualizaMsg( oSay, "Processando carga do campo Status das regras de cálculo" /*STR0069*/, lAutomato )
		AtuF2BStatus() // Atualiza campo F2B_STATUS na tabela F2B
	EndIf

	If lCpoFNPIMemo
		AtualizaMsg( oSay,  STR0099, lAutomato ) //"Processando carga do novo campo de fórmulas NPI ( CIN_FNPI_M )" 
		FSA170CIN()
	EndIf

Endif

If lCJ
	AtualizaMsg( oSay,  STR0075, lAutomato ) //"Processando carga do Código Situação Tributária"
	FSA160ICJ0()
EndIf

AtuTpPF01() // Atualiza campos de tipo de perfil nas tabelas F21,F22,F23,F26,CIO,F24,F25

AtuTpPF02() // Atualiza campos de tipo de perfil nas tabelas F21,F22,F23,F26,CIO,F24,F25

AtuTpPF03() // Atualiza campos de tipo de perfil nas tabelas F21,F22,F23,F26,CIO,F24,F25

AtuTpPF04() // Atualiza campos de tipo de perfil nas tabelas F24,F25

If lCK2
	ChargeCk2() // Atualiza a tabela de dados adicionais (CK2)
EndIf

AtualizaMsg( oSay, STR0041, lAutomato ) //"Cargas Concluídas"

End Transaction

Return

//------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Erick G. Dias
@since 21/06/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function AtualizaMsg( oSay, cMsg, lAutomato )

If !lAutomato
	oSay:cCaption := (cMsg)
	ProcessMessages()
EndIF

Return

//------------------------------------------------------------------
/*/{Protheus.doc} GetCssTree

Função que monta o CSS do menu lateral

@author Erick G. Dias
@since 04/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
static function GetCssTree()

Local cCSS	:= ""

cCSS +=	 "QTreeView{"
cCSS += "  font-size: 14px; /*tamanho do fonte*/"
cCSS +="  border: 2px solid #40698d; /*cor da borda*/"
cCSS +="  background: #F5FBE7"
cCSS +="}"
cCSS +="/*Caracteristicas do item*/"
cCSS +="QTreeView::item {"
cCSS +="  color: #40698d; /*cor da font*/"
cCSS +=""
cCSS +="  /*Pintura da barra esquerda do item selecionado*/"
cCSS +="  border: 1px solid #40698d; "
cCSS +="  border-top-color: transparent;"
cCSS +="  border-bottom-color: transparent;"
cCSS +="}"
cCSS +="/*Caracteristicas do item selecionado*/"
cCSS +="QTreeView::item:selected {"
cCSS +="  background: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,"
cCSS +="              stop: 0 #FAC08F, stop: 1 #FDEADA); /*cor de fundo*/"
cCSS +="}"
cCSS +="/*Caracteristicas do item, quando mouse posicionado sobre ele*/"
cCSS +="QTreeView::item:hover {"
cCSS +="  background: #d8dfe7; /*cor de fundo*/"
cCSS += "}"

Return cCSS

//------------------------------------------------------------------
/*/{Protheus.doc} DicConf
    (Funcao responsável por Exibir Help de dicionario)
    
    @author Rafael Oliveira
    @since 16/06/2020
    @version P12.1.27
/*/
//------------------------------------------------------------------
Static Function HelpDic()
	Help("",1,"Help","Help",STR0003 ,1,0) //"Dicionário desatualizado, favor verificar atualizações do motor de cálculo fiscal."
Return ""


//-------------------------------------------------------------------
/*/{Protheus.doc} GetVerRls Retorna a versao do release para liberar acesso as novas rotinas. 
@description Com essa função podemos restringir a liberação de algumas melhorias por release.
@author Bruce Mello
@since 22/02/2022
@version 12.1.37
/*/
//------------------------------------------------------------------
Function GetVerRls()
Local cVersao 	:= GetRpoRelease()
Local lVersao   := .F.

	If cVersao ==  ("12.1.033") .or. cVersao >= ("12.1.2210") 
		lVersao  := .T.
	EndIf

Return lVersao
//------------------------------------------------------------------
/*/{Protheus.doc} HasCustEst
    (Funcao responsável por checar regra de custo)
    
    @author Reynaldo Miyashita
    @since 20/02/2025

/*/
//------------------------------------------------------------------
Function HasCustEst()

	If lCustoEstoque == Nil
		lCustoEstoque := .F.
		If FindFunction('backoffice.stock.calculationcost.HasRulesCust', .T.)
			lCustoEstoque := backoffice.stock.calculationcost.HasRulesCust()
		EndIf
	EndIf
return lCustoEstoque

//------------------------------------------------------------------
/*/{Protheus.doc} FSA170CIN
    (Funcao responsável por dar carga no campo memo CIN_FNPI_M 
     conforme a fórmula retornada no formato NPI contida no campo 
     CIN_FORMUL para tratar fórmulas extensas que não couberem no
     campo CIN_FNPI)
    
    @author Nilson César
    @since 04/07/2025
    @version P12.1.2410
/*/
//------------------------------------------------------------------
Static function FSA170CIN()

Local oCIN  as object
Local cSelect      := ''
Local cFrom        := ''
Local cWhere       := ''
Local cQuery       := ''
Local cAliasQryCNI := ''

    //Query na CIN
    cSelect += "SELECT "
    cSelect += " R_E_C_N_O_ RECNO"
    cFrom   += " FROM "+RetSqlName("CIN")
    cWhere  += " WHERE CIN_FILIAL = ? AND CIN_FNPI_M IS NULL"

    cQuery := ChangeQuery(cSelect+cFrom+cWhere)
    oCIN   := FwExecStatement():New(cQuery)

    oCIN:SetString(1,xFilial("CIN"))

    cAliasQryCNI := oCIN:OpenAlias()

    While !(cAliasQryCNI)->(Eof())
        CIN->(DbGoTo(  (cAliasQryCNI)->RECNO   ))
        CIN->(RecLock("CIN",.F.))
        CIN->CIN_FNPI_M := xFisSYard( CIN->CIN_FORMUL )
        CIN->(MsUnlock())
        (cAliasQryCNI)->(DbSkip())
    EndDo

    // Fechar o alias após o uso
    (cAliasQryCNI)->(DBCloseArea())

    oCIN:Destroy()
    oCIN := nil

Return
