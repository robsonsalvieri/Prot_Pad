#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PONA510.CH"

Static dIniFil		:= CtoD("")
Static dFimFil		:= CtoD("")
Static lIntTAE
Static lWenBtn		:= .F.
Static lBtnDwAsnd	:= .F.
Static oSign		:= NIL
Static aFiltroRel	:= {}
Static lUseFiltro	:= .F.
Static cUltFiltro	:= "1"

PUBLISH MODEL REST NAME PONA510

/*/{Protheus.doc} PONA510
Rotina para visualizar todos os arquivos integrados com o TAE
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Nil
/*/
Function PONA510()
	Local oMBrowse
	Local cFiltraRh

	aFiltroRel := {"1=Todos", "2=Espelho de Ponto", "3=Extrato Banco de Horas"}

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("SRA")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) // "Arquivos TAE"

	// Inicializa o filtro utilizando a funcao FilBrowse
	cFiltraRh := CHKRH("PONA510","SRA","1")
	oMBrowse:SetFilterDefault(cFiltraRh)

	GpLegMVC(@oMBrowse)

	oMBrowse:Activate()

	If oSign != NIL
		FreeObj(oSign)
	EndIf
Return

/*/{Protheus.doc} ModelDef
Rotina para visualizar todos os arquivos integrados com o TAE
@type function
@author Marco Nakazawa
@since 19/08/2026
@return oModel, Objeto de Modelagem
/*/
Static Function ModelDef()
	Local oModel
	Local oStructSRA
	Local oStruRS4CB
	Local oStruRS4TAE
	Local lTemRS4Rot	:= .F.
	
	DEFAULT lIntTAE		:= ChkFile("RS4") .And. RS4->(ColumnPos("RS4_TPDOC")) > 0 .And. FindFunction("FwTotvsSign")
	
	lTemRS4Rot 	:= ChkFile("RS4") .And. RS4->(ColumnPos("RS4_ROTINA")) > 0
	
	// Criação do Objeto de Modelagem de dados da tabela RS4
	oModel := MPFormModel():New("PONA510", NIL, NIL)
	oModel:SetDescription(OemToAnsi(STR0001)) //'Controle de Espelho de Ponto'
	
	// Estrutura de campos do Model //
	oStructSRA := FWFormStruct(1, "SRA", {|cCampo| AllTrim(cCampo) + "|" $ "RA_FILIAL|RA_MAT|RA_NOME|RA_ADMISSA|"})
	oStruRS4CB := FWFormStruct(1, "RS4")

	// Campos virtuais
	// Só adiciona o campo virtual de filtro se a tabela RS4 tiver o campo de RS4_ROTINA
	If lTemRS4Rot
		oStructSRA:AddField("Relatório", "Filtro de Relatórios", "FILREL", "C", 1, 0,,, aFiltroRel, .F., {||"1"})
	EndIf
	
	oStruRS4CB:AddField(" ", "RS4_LEG", "RS4_LEG", 'BT', 1, 0,,,, .F., {||Pn510Leg(.F.)})
	
	oModel:AddFields("PONA510_SRA",, oStructSRA)
	oModel:GetModel("PONA510_SRA"):SetOnlyQuery(.T.)

	oModel:AddGrid("PONA510_RS4", "PONA510_SRA", oStruRS4CB, {|oGrid, nLine, cAction, cField| Pn510DelOk(oGrid, nLine, cAction, cField)},,,, {|oGrid|CargaGrid(oGrid)})
	oModel:GetModel('PONA510_RS4'):SetOptional(.F.)

	// Não Permite Incluir linhas na formgrid
	oModel:GetModel("PONA510_RS4"):SetNoInsertLine()
	FWMemoVirtual(oStruRS4CB, {{"RS4_CODOBS", "RS4_OBSERV"}})
	oModel:GetModel("PONA510_RS4"):SetUniqueLine( {"RS4_PER", "RS4_CODEBA"})
	oModel:SetRelation("PONA510_RS4", {{"RS4_FILIAL", "xFilial('RS4')"}, {"RS4_MAT", "RA_MAT"}}, RS4->(IndexKey()))

	// Remove os campos referentes ao TAE da estrutura com os registros com o Código de barras
	oStruRS4CB:RemoveField("RS4_NDOC")
	oStruRS4CB:RemoveField("RS4_ID")
	oStruRS4CB:RemoveField("RS4_DTINTE")
	
	oModel:GetModel("PONA510_RS4"):SetOptional(.T.)
	
	// Cria uma nova estrutura da tabela RS4 para os registros integrados ao TAE 
	oStruRS4TAE := FWFormStruct(1, "RS4")	
	oStruRS4TAE:AddField(" ", "RS4_LEG", "RS4_LEG", "BT", 1, 0, ,,, .F., {||Pn510Leg(.F.)})
	oStruRS4TAE:SetProperty("RS4_STATUS", MODEL_FIELD_WHEN, {|| .T.})
	
	// Remove os campos referentes ao código de barras da estrutura com os registros referentes ao TAE
	oStruRS4TAE:RemoveField("RS4_CODEBA")
	
	// Cria o segundo grid com os arquivos enviados para o TAE
	oModel:AddGrid("PONA510_TAE", "PONA510_SRA", oStruRS4TAE, {|oGrid, nLine, cAction, cField| Pn510DelOk(oGrid, nLine, cAction, cField)},,,, {|oGrid|CargaGrid(oGrid)})
	oModel:GetModel("PONA510_TAE"):SetOptional(.T.)
	oModel:GetModel("PONA510_TAE"):SetNoInsertLine()
	
	FWMemoVirtual( oStruRS4CB, {{'RS4_CODOBS', 'RS4_OBSERV' }})
	oModel:GetModel("PONA510_TAE"):SetUniqueLine({"RS4_PER", "RS4_ID"})
	oModel:SetRelation("PONA510_TAE", {{"RS4_FILIAL", "xFilial('RS4')"}, {"RS4_MAT", "RA_MAT"}}, RS4->(IndexKey()))	
	
	// Filtra as informações de cada grid
	oModel:GetModel("PONA510_TAE"):SetLoadFilter(,"RS4_TPDOC = '1'")
	oModel:GetModel("PONA510_RS4"):SetLoadFilter(,"RS4_TPDOC <> '1'")

	oModel:SetVldActivate({|oModel| fResetFilt(oModel)})
Return oModel

/*/{Protheus.doc} ViewDef
Rotina para visualizar todos os arquivos integrados com o TAE
@type function
@author Marco Nakazawa
@since 19/08/2026
@return oView, Objeto de View
/*/
Static Function ViewDef()	
	Local oView
	Local oModel
	Local oStructSRA
	Local oStruRS4CB
	Local oStruRS4TAE
	Local lTemRS4Rot	:= .F.
	
	DEFAULT lIntTAE := ChkFile("RS4") .And. RS4->(ColumnPos("RS4_TPDOC")) > 0 .And. FindFunction("FwTotvsSign")

	lTemRS4Rot 	:= ChkFile("RS4") .And. RS4->(ColumnPos("RS4_ROTINA")) > 0
	
	// Criacao da Interface
	oView := FWFormView():New()
	
	// Vincular o View ao Model
	oModel := FWLoadModel("PONA510")
	oView:SetModel(oModel)
	
	oStructSRA := FWFormStruct(2, "SRA", {|cCampo| AllTrim(cCampo) + "|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"})
	
	If lTemRS4Rot
		oStructSRA:AddField("FILREL", "4", "Filtro Relatório", "Filtre pelos os relatórios desejados",, "C", "@!",,, .T.,,, aFiltroRel,,, .T.)
		oStructSRA:SetProperty("FILREL", MVC_VIEW_CANCHANGE, .T.)
		oView:SetFieldAction("FILREL", {|| fFiltraRel()})
	EndIf

	oStructSRA:SetProperty("RA_MAT", MVC_VIEW_CANCHANGE, .F.)
    oStructSRA:SetProperty("RA_NOME", MVC_VIEW_CANCHANGE, .F.)
    oStructSRA:SetProperty("RA_ADMISSA", MVC_VIEW_CANCHANGE, .F.)

	oStructSRA:SetNoFolder()
	
	oView:AddField("PONA510_SRA", oStructSRA)
	
	oStruRS4CB := FWFormStruct(2, "RS4")
	
	// Adiciona campo legenda.
	oStruRS4CB:AddField("RS4_LEG", "01", "", "", , "BT")
	
	oStruRS4CB:RemoveField("RS4_MAT")
	
	oView:AddGrid("PONA510_RS4", oStruRS4CB)
	
	oView:createHorizontalBox("FORMFIELD", 15)
	oView:createHorizontalBox("GRID"     , 85)
	
	// Remove os campos referentes ao TAE da estrutura com os registros com o Código de barras
	oStruRS4CB:RemoveField("RS4_NDOC")
	oStruRS4CB:RemoveField("RS4_ID")
	oStruRS4CB:RemoveField("RS4_DTINTE")
	oStruRS4CB:RemoveField("RS4_TPDOC")
	oStruRS4CB:RemoveField("RS4_ROTINA")
	
	// Cria uma nova estrutura da tabela RS4 para os registros integrados ao TAE 
	oStruRS4TAE := FWFormStruct(2, "RS4")
	oStruRS4TAE:AddField("RS4_LEG", "01", "", "", , "BT")
	oStruRS4TAE:SetProperty("RS4_STATUS", MVC_VIEW_CANCHANGE, .F.)
	oStruRS4TAE:SetProperty("RS4_NDOC", MVC_VIEW_CANCHANGE, .F.)
	oStruRS4TAE:SetProperty("RS4_ID", MVC_VIEW_CANCHANGE, .F.)
	oStruRS4TAE:SetProperty("RS4_DTINTE", MVC_VIEW_CANCHANGE, .F.)
	
	oStruRS4TAE:RemoveField("RS4_MAT" )
	oStruRS4TAE:RemoveField("RS4_CODEBA")
	oStruRS4TAE:RemoveField("RS4_TPDOC")
	oStruRS4TAE:RemoveField("RS4_ROTINA")
	
	oView:AddGrid("PONA510_TAE", oStruRS4TAE)
	
	// Adiciona a barra com os botões
	oView:AddOtherObject("VIEW_BUTTONBAR", {|oPanel| ButtonBar(oPanel)})
	oView:SetViewProperty("PONA510_TAE", "CHANGELINE", {{|oView| ButtonsWhen(oView)}})
	oView:SetAfterViewActivate({|oView| ButtonsWhen(oView)})
	
	//Cria as abas 
	oView:CreateFolder("PASTAS", "GRID")
	oView:addSheet("PASTAS", "TAE", "Assinatura Eletrônica")
	oView:addSheet("PASTAS", "CodBar", "Código de barras")
	
	oView:CreateHorizontalBox( "BUTTONBAR", 5,,, "PASTAS", "TAE" )
	oView:CreateHorizontalBox( "GRIDTAE"  , 95,,, "PASTAS", "TAE" )
	
	oView:CreateHorizontalBox( "GRIDCD", 100,,, "PASTAS", "CodBar" )
	
	oView:SetOwnerView("VIEW_BUTTONBAR", "BUTTONBAR")
	oView:SetOwnerView("PONA510_TAE", "GRIDTAE")
	oView:SetOwnerView("PONA510_RS4", "GRIDCD")
	oView:SetOwnerView("PONA510_SRA", "FORMFIELD")
	
	oView:EnableControlBar(.T.)
	
	oView:AddUserButton(STR0002, "", {|oView|Pn510Leg(.T.)}) // "Legenda"
	
	oView:SetCloseOnOk({|| .T. })
Return oView

/*/{Protheus.doc} Pn510DelOk
Valida Possibilidade de deleção da linha.
@type function
@author Marco Nakazawa
@since 19/08/2026
@return lRet, informa se a linha pode ser excluída ou não
/*/
Static Function Pn510DelOk(oGrid, nLine, cAction, cField)
	Local lRet := .T.
	DEFAULT lIntTAE := ChkFile("RS4") .And. RS4->(ColumnPos("RS4_TPDOC")) > 0 .And. FindFunction("FwTotvsSign")

	If cAction == "DELETE"
		If lIntTAE .And. oGrid:GetValue("RS4_TPDOC") == "1" .And. oGrid:GetValue("RS4_STATUS") == "2"
			lRet := fDelArqTae(.T.)
			
			If !lRet
				Help(,, STR0003,, STR0038, 1,,,,,,, {STR0039 + STR0040})
			EndIf
		ElseIf oGrid:GetValue("RS4_STATUS") == "1"
	    	Help(,,STR0003,, STR0004,1,0 ) // "Arquivos entregues não podem ser excluídos."
			lRet := .F.
		EndIf
	ElseIf cAction == "UNDELETE" .And. lIntTAE .And. oGrid:GetValue("RS4_TPDOC") == "1"
		Help(,, STR0003,, STR0005, 1, 0 ) // "O documento foi excluído do Totvs Assinatura Eletrônica, não é possível desfazer essa ação."
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} Pn510Leg
Monta a legenda dos registros apresentados no Grid.
@type function
@author Marco Nakazawa
@since 19/08/2026
@return cRet, cor da legenda
/*/
Function Pn510Leg(lTela)
	Local oLegenda	:= Nil
	Local cRet		:= Nil

	If lTela
		oLegenda := FwLegend():New()
		oLegenda:add("RS4->RS4_STATUS==1", "GREEN" , STR0006)		// "Devolvido"
		oLegenda:add("RS4->RS4_STATUS==2", "YELLOW", STR0007)		// "Pendente"
		oLegenda:add("RS4->RS4_STATUS==3", "RED"   , STR0008)		// "Cancelado"
		oLegenda:View()
		oLegenda := Nil
	Else
		If RS4->RS4_STATUS == "1"	 // Devolvido
			cRet := 'br_verde'
		ElseIf RS4->RS4_STATUS ==  "3" // Cancelado
			cRet := "br_vermelho"
		Else // Pendente
			cRet := "br_amarelo"
		EndIf
	EndIf
Return cRet

/*/{Protheus.doc} Pn510Baixa
Abre o pop up para dar baixa nos relatórios entregues
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Nil
/*/
Function Pn510Baixa()
	Local cCodeBar		:= Space(60)
	Local cObservacao	:= Space(80)
	Local aDadosFunc	:= {Space(20), Space(100), Space(20), Space(30)}
	Local lVldOk		:= .F.
	Local oDlg
	Local oGroup
	Local oFont
	Local oCodeBar
	Local oBtnGravar
	Local oBtnOk
	Local oSize			

	SetKey(VK_F5, {|| iif(lVldOk .And. Pn510Grv(cObservacao), Pn510Clear(@cCodeBar, @cObservacao, @aDadosFunc), Nil)})
	SetKey(VK_F6, {|| iif(lVldOk .And. Pn510Grv(cObservacao), oDlg:End(), Nil)})

	//Monta as Dimensoes dos Objetos
	oSize := FwDefSize():New(.F.)
	oSize:AddObject("CABECALHO",(oSize:aWindSize[3] * 1.1), 220 , .F., .F.)	// Não dimensionavel
	oSize:aMargins := {0, 0, 0, 0}											// Espaco ao lado dos objetos 0, entre eles 3
	oSize:lProp := .F.														// Proporcional
	oSize:Process()															// Dispara os calculos

	DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
	DEFINE MSDIALOG oDlg FROM 0, 0 TO 220, (oSize:aWindSize[3] * 1.1) TITLE OemToAnsi(STR0009) PIXEL // "Dar baixa nos relatórios"

	@oSize:GetDimension("CABECALHO","LININI") + 3,	oSize:GetDimension("CABECALHO","COLINI") + 3 GROUP oGroup TO oSize:GetDimension("CABECALHO","LINEND") * 0.39, (oSize:GetDimension("CABECALHO","COLEND") * 0.5) OF oDlg PIXEL
	
	@oSize:GetDimension("CABECALHO","LININI") + 10,	oSize:GetDimension("CABECALHO","COLINI") + 15	SAY STR0010 Of oDlg Pixel FONT oFont // "Código de Barras"
	@oSize:GetDimension("CABECALHO","LININI") + 18,	oSize:GetDimension("CABECALHO","COLINI") + 15	MSGET oCodeBar Var cCodeBar PICTURE "@!" VALID Pn510VldCode(cCodeBar, @aDadosFunc, @lVldOk) SIZE oSize:aWindSize[3] * 0.52, 10 OF oDlg PIXEL HASBUTTON
	
	@oSize:GetDimension("CABECALHO","LININI") + 35,	oSize:GetDimension("CABECALHO","COLINI") + 15	SAY STR0011 Of oDlg Pixel FONT oFont // "Observação"
	@oSize:GetDimension("CABECALHO","LININI") + 43,	oSize:GetDimension("CABECALHO","COLINI") + 15	MSGET oObservacao Var cObservacao PICTURE "@!" SIZE oSize:aWindSize[3] * 0.52, 10 OF oDlg PIXEL HASBUTTON

	@oSize:GetDimension("CABECALHO","LININI") + 60,	oSize:GetDimension("CABECALHO","COLINI") + 15	SAY STR0012  Of oDlg Pixel FONT oFont // "Filial:"
	@oSize:GetDimension("CABECALHO","LININI") + 60,	oSize:GetDimension("CABECALHO","COLINI") + 40	SAY aDadosFunc[1] Of oDlg Pixel

	@oSize:GetDimension("CABECALHO","LININI") + 60,	oSize:GetDimension("CABECALHO","COLINI") + 75	SAY STR0013  Of oDlg Pixel FONT oFont // "Funcionário:"
	@oSize:GetDimension("CABECALHO","LININI") + 60,	oSize:GetDimension("CABECALHO","COLINI") + 110	SAY aDadosFunc[2] Of oDlg Pixel

	@oSize:GetDimension("CABECALHO","LININI") + 75,	oSize:GetDimension("CABECALHO","COLINI") + 15	SAY STR0014  Of oDlg Pixel FONT oFont // "Período:"
	@oSize:GetDimension("CABECALHO","LININI") + 75,	oSize:GetDimension("CABECALHO","COLINI") + 40	SAY aDadosFunc[3] Of oDlg Pixel

	@oSize:GetDimension("CABECALHO","LININI") + 75,	oSize:GetDimension("CABECALHO","COLINI") + 110	SAY aDadosFunc[4] Of oDlg Pixel FONT oFont COLOR CLR_RED

	oBtnGravar	:= TButton():New(oSize:GetDimension("CABECALHO","LININI") + 95, oSize:GetDimension("CABECALHO","COLEND") / 2 - 140,	"&" + STR0015 ,,{|| Iif(Pn510Grv(cObservacao), Pn510Clear(@cCodeBar, @cObservacao, @aDadosFunc), Nil)}, 040, 012,,,, .T.,,,, {||lVldOk}) // "Gravar"
	oBtnOk		:= TButton():New(oSize:GetDimension("CABECALHO","LININI") + 95, oSize:GetDimension("CABECALHO","COLEND") / 2 - 90,	"&" + STR0016 ,,{|| Iif(Pn510Grv(cObservacao), oDlg:End(), Nil)}, 040, 012,,,, .T.,,,, {||lVldOk}) // "Gravar e Sair"
	oBtnFechar	:= TButton():New(oSize:GetDimension("CABECALHO","LININI") + 95, oSize:GetDimension("CABECALHO","COLEND") / 2 - 40,	"&" + STR0017 ,,{|| oDlg:End()}, 040, 012,,,, .T.) // "Fechar"

	ACTIVATE MSDIALOG oDlg CENTERED

	SetKey(VK_F5, {||NIL})
	SetKey(VK_F6, {||NIL})
Return

/*/{Protheus.doc} Pn510VldCode
Valida código de barras digitado
@type function
@author Marco Nakazawa
@since 19/08/2026
@return .T. - Sempre retorna .T. para que valor label seja alterado.
/*/
Static Function Pn510VldCode(cCodeBar, aDadosFunc, lVldOk)
	Local lRet		:= .F.

	DbSelectArea("SRA")
	DbSetOrder(1)

	DbSelectArea("RS4")
	DbSetOrder(2) //RS4_CODEBA

	aDadosFunc[4] := ""

	If DbSeek(AllTrim(cCodeBar))
		If AllTrim(RS4->RS4_CODEBA) == AllTrim(cCodeBar) // Confirma que código de barras esta completo.
			lRet 	:= .T.
			lVldOk 	:= .T.
			If RS4->RS4_STATUS <> "2"
				lVldOk := .F.
				aDadosFunc[4] := STR0054 // "Registro já processado."
			EndIf
		EndIf
	EndIf

	If lRet
		SRA->(DbSeek(RS4->RS4_FILIAL + RS4->RS4_MAT))
		aDadosFunc[1] := RS4->RS4_FILIAL
		aDadosFunc[2] := RS4->RS4_MAT + " - " + SRA->RA_NOME
		aDadosFunc[3] := DtoC(RS4->RS4_DATAI) + " - " + DtoC(RS4->RS4_DATAF)
	Else
		aDadosFunc[1] := ""
		aDadosFunc[2] := ""
		aDadosFunc[3] := ""
		aDadosFunc[4] := STR0018 // "Nenhum registro encontrado"
		lVldOk := .F.
	EndIf
Return .T. 

/*/{Protheus.doc} Pn510Grv
Grava baixa do arquivo (relatório)
@type function
@author Marco Nakazawa
@since 19/08/2026
@return .T. - Sempre retorna .T.
/*/
Static Function Pn510Grv(cObservacao)
	Local cMemoAux	:= ""

	If !Empty(cObservacao)
		cMemoAux := MSMM(RS4->RS4_CODOBS,,, cObservacao, 1,,, "RS4", "RS4_CODOBS")
	EndIf

	RecLock("RS4",.F.)
		RS4->RS4_STATUS := "1"
		RS4->RS4_CODOBS := cMemoAux
	MsUnLock()
Return .T.

/*/{Protheus.doc} Pn510Clear
Limpa dados da tela
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Nil
/*/
Static Function Pn510Clear(cCodeBar, cObservacao, aDadosFunc)
	cCodeBar		:= Space(60)
	cObservacao		:= Space(80)
	aDadosFunc[1]	:= ""
	aDadosFunc[2]	:= ""
	aDadosFunc[3]	:= ""
	aDadosFunc[4]	:= ""
Return

/*/{Protheus.doc} Pn510Filtro
Filtra os arquivos exibidos na getdados por data
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Nil
/*/
Function Pn510Filtro()
	Local dDataIni	:= dIniFil
	Local dDataFim	:= dFimFil
	Local oDataIni
	Local oDataFim
	Local oSize
	Local oDlg
	Local oFont
	Local nOpcA := 0
	
	// Monta as Dimensoes dos Objetos
	oSize := FwDefSize():New(.T.)
	oSize:AddObject("CABECALHO", 150, 100, .F., .F.) // Não dimensionavel
	oSize:aMargins := {0, 0, 0, 0} // Espaco ao lado dos objetos 0, entre eles 3
	oSize:lProp := .F. // Proporcional
	oSize:Process() // Dispara os calculos
	
	bSet15 := {|| If(Pn510FilData(dDataIni, dDataFim), (nOpcA := 1, oDlg:End()), Nil)}
	bSet24 := {|| nOpcA := 2, oDlg:End()}
	
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg FROM 0, 0 TO 200, 400 TITLE OemToAnsi(STR0019) PIXEL // "Filtrar arquivos"
	
	@oSize:GetDimension("CABECALHO","LININI") + 10, oSize:GetDimension("CABECALHO","COLINI") + 15 SAY STR0020 Of oDlg Pixel FONT oFont // "Data inicio"
	@oSize:GetDimension("CABECALHO","LININI") + 18, oSize:GetDimension("CABECALHO","COLINI") + 15 MSGET oDataIni Var dDataIni PICTURE "@!" SIZE 60, 10 OF oDlg PIXEL HASBUTTON
	@oSize:GetDimension("CABECALHO","LININI") + 35, oSize:GetDimension("CABECALHO","COLINI") + 15 SAY STR0021 Of oDlg Pixel FONT oFont // "Data fim"
	@oSize:GetDimension("CABECALHO","LININI") + 43, oSize:GetDimension("CABECALHO","COLINI") + 15 MSGET oDataFim Var dDataFim PICTURE "@!" SIZE 60, 10 OF oDlg PIXEL HASBUTTON
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bSet15, bSet24)
	
	If nOpcA == 1
		dIniFil	:= dDataIni
		dFimFil	:= dDataFim
	EndIf
Return

/*/{Protheus.doc} Pn510FilData(dDataIni, dDataFim)
Valida datas para filtro dos arquivos
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Lógico que informa se as datas são válidas
/*/
Static Function Pn510FilData(dDataIni, dDataFim)
	Local lRet	:= .T.

	If dDataFim < dDataIni
		Help(,, STR0003,, STR0022, 1, 0) // "A data final deve ser maior que a data inicial."
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} CargaGrid
Carrega grid filtrado
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Array com os dados filtrados para o grid
/*/
Static Function CargaGrid(oGrid)
	Local aRet 			:= {}
	Local aRet2			:= {}
	Local nX			:= 0
	Local nPosAux		:= 0
	
	aRet2 := FormLoadGrid(oGrid)
	
	If Empty(dIniFil) .and. Empty(dFimFil)
		aRet := aClone(aRet2)
	Else
		nPosAux := oGrid:GetIdField("RS4_DATAI")
		
		For nX:= 1 to Len(aRet2)
			If aRet2[nX, 2, nPosAux] >= dIniFil .and. aRet2[nX, 2, nPosAux] <= dFimFil
				aAdd(aRet, aClone(aRet2[nX]))
			EndIf
		Next
	EndIf
Return aRet

/*/{Protheus.doc} MenuDef
Criação do menu do browse
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Array com os botões do menu do browse
/*/
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0023  ACTION "PESQBRW"         	OPERATION 1 ACCESS 0 DISABLE MENU 	// "Pesquisar"
	ADD OPTION aRotina TITLE STR0024  ACTION "VIEWDEF.PONA510" 	OPERATION 2 ACCESS 0 				// "Visualizar"
	ADD OPTION aRotina TITLE STR0025  ACTION "VIEWDEF.PONA510" 	OPERATION 4 ACCESS 0				// "Manutenção"
	ADD OPTION aRotina TITLE STR0026  ACTION "Pn510Baixa()" 	OPERATION 5 ACCESS 0				// "Baixar"
	ADD OPTION aRotina TITLE STR0019  ACTION "Pn510Filtro()"	OPERATION 5 ACCESS 0				// "Filtrar arquivos"
	
	// Integração com o Totvs Assinatura eletrônica
	ADD OPTION aRotina TITLE STR0027 ACTION "ConfigTAE()"		OPERATION 6 ACCESS 0				// "Config. Assina. Eletr."
	ADD OPTION aRotina TITLE STR0028 ACTION "fTAEStatus()"		OPERATION 6 ACCESS 0				// "Verificar assinaturas"
Return aRotina

/*/{Protheus.doc} ButtonBar
Cria os botões para realizar integrações com o TAE (Exlucão, Verificação de assinatura, Reenvio de e-mail, Download do documento e Download do documento assinado)
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Nil
/*/
Static Function ButtonBar(oPanel)
	Local oBar
	
	DEFINE FONT oFont NAME "Arial" SIZE 0, -12 BOLD
	
	oBar := TBar():New(oPanel, oPanel:nHeight, oPanel:nHeight, .F.,,,, .T.)
	
	oPanel:lShowHint := .T.
	
	// Exclui o documento no TAE
	DEFINE BUTTON oBtApoDel RESOURCE "DELWEB.PNG" OF oBar WHEN lWenBtn ACTION MsAguarde({|| fDelArqTae()}, STR0029, STR0030, .F.) // "Aguarde" - "Excluindo/cancelando o arquivo"
	oBtApoDel:Align := CONTROL_ALIGN_LEFT
	oBtApoDel:cToolTip := OemToAnsi(STR0049) // "Excluir/Cancelar"
	oBtApoDel:cTitle := ""
	
	// Verificar assinatura
	DEFINE BUTTON oBtApoAb RESOURCE "TK_VERTIT.PNG" OF oBar WHEN lWenBtn ACTION MsAguarde({|| fAtuStaTae()}, STR0029, STR0031, .F.) // "Aguarde" - "Atualizando status do documento"
	oBtApoAb:Align := CONTROL_ALIGN_LEFT
	oBtApoAb:cToolTip := OeMToAnsi(STR0050) // "Verificar assinatura" 
	oBtApoAb:cTitle	:= ""
	
	// Reenviar e-mail
	DEFINE BUTTON oBtApoAb RESOURCE "GEOEMAIL.PNG" OF oBar WHEN lWenBtn ACTION MsAguarde({|| fSndMaiTae()}, STR0029, STR0032, .F.) // "Aguarde" - "Enviando e-mail"
	oBtApoAb:Align := CONTROL_ALIGN_LEFT
	oBtApoAb:cToolTip := OeMToAnsi(STR0051) // "Solicitar Assinatura"
	oBtApoAb:cTitle	:= ""
	
	// Download do documento
	DEFINE BUTTON oBtApoAb RESOURCE "TOTVSPRINTER_PDF.PNG" OF oBar ACTION MsAguarde({|| fDwnArqTae()}, STR0029, STR0033, .F.) // "Aguarde" - "Salvando arquivo"
	oBtApoAb:Align := CONTROL_ALIGN_LEFT
	oBtApoAb:cToolTip := OeMToAnsi(STR0052)  // "Download"
	oBtApoAb:cTitle	:= ""
	
	// Download do documento assinado
	DEFINE BUTTON oBtApoAb RESOURCE "SELECTALL_OCEAN.PNG" OF oBar WHEN lBtnDwAsnd ACTION MsAguarde({|| fDwnAsdTae()}, STR0048, STR0033, .F.) // "Salvando arquivo"
	oBtApoAb:Align := CONTROL_ALIGN_LEFT
	oBtApoAb:cToolTip := OeMToAnsi(STR0053) // "Download do documento assinado"
	oBtApoAb:cTitle	:= ""
Return

/*/{Protheus.doc} ButtonsWhen
Controla quando os botões estarão ativos na tela
@type function
@author Marco Nakazawa
@since 19/08/2026
@return .T. - Sempre retorna .T.
/*/
Static Function ButtonsWhen(oView)
	Local oModel		:= oView:GetModel()
	Local oModelGrid 	:= oModel:GetModel("PONA510_TAE")
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		lWenBtn := If(oModelGrid:GetValue("RS4_STATUS") == "2", .T., .F.)
		lBtnDwAsnd := If(oModelGrid:GetValue("RS4_STATUS") == "1", .T., .F.)
		oView:Refresh("VIEW_BUTTONBAR")
		oView:Refresh("PONA510_SRA")
	Else
		lBtnDwAsnd := .F.
		lWenBtn := .F.
	EndIf
Return .T.

/*/{Protheus.doc} fDelArqTae
Valida se é possível e realiza a exclusão do documento no TAE 
@type  Static Function
@author Cícero Alves
@since 03/03/2022
@return lRet, Lógico, Indica se foi feita a exclusão do registro
/*/
Static Function fDelArqTae(lModelCall)
	Local oModel 		:= FWModelActivate()
	Local oGrid			:= oModel:GetModel("PONA510_TAE")
	Local oView			:= FWViewActive()
	Local cSeek			:= ""
	Local lRet			:= .T.
	Local lCpoRotRS4	:= RS4->(ColumnPos("RS4_ROTINA")) > 0
	Local aRespTae		:= {}
	
	Default lModelCall := .F.

	If oSign == Nil .Or. (ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado)
		oSign := PONXTAE():New("", .T.)
	EndIf

	If ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado
		FreeObj(oSign)
		Return .F.
	EndIf

	DbSelectArea("RS4")

	If lCpoRotRS4
		RS4->(dbSetOrder(RetOrder("RS4", "RS4_FILIAL+RS4_MAT+STR(RS4_ID)"))) // RS4_FILIAL + RS4_MAT + STR(RS4_ID)
		cSeek := xFilial("RS4", SRA->RA_FILIAL) + SRA->RA_MAT + cValToChar(oGrid:GetValue("RS4_ID"))
	Else
		RS4->(dbSetOrder(1)) // RS4_FILIAL + RS4_MAT + RS4_PER
		cSeek := xFilial("RS4", SRA->RA_FILIAL) + SRA->RA_MAT + dTos(oGrid:GetValue("RS4_DATAI")) + DToS(oGrid:GetValue("RS4_DATAF"))
	EndIf

	aRespTae := oSign:statusDoc(oGrid:GetValue("RS4_ID"))
	
	If aRespTae[1] .And. aRespTae[2] == 5 // Documento em rascunho
		// "O documento também será excluído do Totvs assinatura eletrônica."
		// "Essa ação não poderá ser desfeita."
		// "Deseja continuar?"
		If lRet := MsgYesNo(STR0034 + CRLF + STR0035 + CRLF + STR0036, STR0003)
			If oSign:deleteDoc(oGrid:GetValue("RS4_ID"))
				If RS4->(dbSeek(cSeek))
					RecLock("RS4",.F.)
					dbDelete()
					MsUnLock()
				EndIf
				
				ButtonsWhen(oView)
				
				oView:Refresh("PONA510_TAE")
			EndIf
		ElseIf lModelCall
			Help(,, STR0003,, STR0055, 1,,,,,,, {}) // "O documento não foi excluído"
		EndIf
	ElseIf aRespTae[1] .And. aRespTae[2] == 0 // Documento pendente de assinatura.
		// "O documento também será cancelado do Totvs assinatura eletrônica."
		// "Essa ação não poderá ser desfeita."
		// "Deseja continuar?"
		If lRet := MsgYesNo(STR0037 + CRLF + STR0035 + CRLF + STR0036, STR0003)
			If oSign:cancelDoc(oGrid:GetValue("RS4_ID"))
				If RS4->(dbSeek(cSeek))
					RecLock("RS4", .F.)
					RS4->RS4_STATUS := "3"
					MsUnLock()
				EndIf
				
				ButtonsWhen(oView)

				oView:Refresh("PONA510_TAE")
			EndIf
		EndIf
	Else
		// "Erro ao cancelar ou excluir o documento."
		// "Apenas documentos com o Status 'Rascunho' podem ser excluídos"
		// " ou apenas documentos com o Status 'pendentes' podem ser cancelados."
		lRet := .F.
		If !lModelCall
			Help(,, STR0003,, STR0038, 1,,,,,,, {STR0039 + STR0040})
		EndIf
		fAtuStaTae(.F.)
	EndIf
Return lRet

/*/{Protheus.doc} fAtuStaTae
Verifica o status do documento posicionado no grid e atualiza a tabela RS4
@param lShowMsg, Lógico, define se irá apresentar a mensagem ao término do processamento
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Nil
/*/
Static Function fAtuStaTae(lShowMsg)
	Local oModel 		:= FWModelActivate()
	Local oGrid			:= oModel:GetModel("PONA510_TAE")
	Local oView			:= FWViewActive()
	Local cStatus		:= ""
	Local cSeek			:= ""
	local aRespTae		:= {}
	Local lCpoRotRS4	:= RS4->(ColumnPos("RS4_ROTINA")) > 0

	Default lShowMsg := .T.
	
	If oSign == Nil .Or. (ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado)
		oSign := PONXTAE():New("", .T.)
	EndIf

	If ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado
		FreeObj(oSign)
		Return
	EndIf
	
	aRespTae := oSign:statusDoc(oGrid:GetValue("RS4_ID"))

	If aRespTae[1]
		If aRespTae[2] == 2 // Finalizado
			cStatus := "1"
		ElseIf aRespTae[2] == 4 .Or. aRespTae[2] == 7 // Rejeitado ou Cancelado
			cStatus := "3"
		EndIf
	EndIf
	
	If !Empty(cStatus)
		oGrid:SetValue("RS4_STATUS", cStatus)
		
		DbSelectArea("RS4")
		If lCpoRotRS4
			RS4->(dbSetOrder(RetOrder("RS4", "RS4_FILIAL+RS4_MAT+STR(RS4_ID)"))) // RS4_FILIAL + RS4_MAT + STR(RS4_ID)
			cSeek := xFilial("RS4", SRA->RA_FILIAL) + SRA->RA_MAT + cValToChar(oGrid:GetValue("RS4_ID"))
		Else
			RS4->(dbSetOrder(1)) // RS4_FILIAL + RS4_MAT + RS4_PER
			cSeek := xFilial("RS4", SRA->RA_FILIAL) + SRA->RA_MAT + dTos(oGrid:GetValue("RS4_DATAI")) + DToS(oGrid:GetValue("RS4_DATAF"))
		EndIf
		
		If RS4->(dbSeek(cSeek))
			RecLock("RS4", .F.)
			RS4->RS4_STATUS := cStatus
			MsUnLock()
		EndIf
		
		ButtonsWhen(oView)
		
		If lCpoRotRS4
			fFiltraRel()
		EndIf
	EndIf
	
	If lShowMsg
		MsgInfo(STR0041, "OK") // "Registro atualizado"
	EndIf
Return

/*/{Protheus.doc} fSndMaiTae
Envia email para os assinates pendentes do documento posicionado no grid
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Nil
/*/
Static Function fSndMaiTae()
	Local oModel 	:= FWModelActivate()
	Local oGrid		:= oModel:GetModel("PONA510_TAE")
	Local aRespTae	:= {}
	
	If oSign == Nil .Or. (ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado)
		oSign := PONXTAE():New("", .T.)
	EndIf

	If ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado
		FreeObj(oSign)
		Return
	EndIf

	aRespTae := oSign:statusDoc(oGrid:GetValue("RS4_ID"))
	
	If aRespTae[1] .And. aRespTae[2] == 0
		If oSign:SendMail(cValToChar(oGrid:GetValue("RS4_ID")))
			MsgInfo(STR0042, "OK") // "E-mail enviado com sucesso"
		EndIf
	Else
		Help(,, STR0003,, STR0043, 1,,,,,,, {STR0044}) // "O e-mail não pode ser enviado" - "O e-mail é enviado apenas para documentos com o Status 'Pendente'"
		fAtuStaTae(.F.)
	EndIf	
Return

/*/{Protheus.doc} fDwnArqTae
Realiza o download do arquivo posicionado no grid
@type function
@author Marco Nakazawa
@since 19/08/2026
@return Nil
/*/
Static Function fDwnArqTae()
	Local oModel 	:= FWModelActivate()
	Local oGrid		:= oModel:GetModel("PONA510_TAE")
	Local cPath		:= ""
	
	If oSign == Nil .Or. (ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado)
		oSign := PONXTAE():New("", .T.)
	EndIf

	If ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado
		FreeObj(oSign)
		Return
	EndIf
	
	cPath := cGetFile("PDF|", STR0045, 0, , .F., GETF_LOCALHARD + GETF_RETDIRECTORY,.F.,) // "Selecione o Diretorio"
	
	If !Empty(cPath) .And. oSign:getDocument(cValToChar(oGrid:GetValue("RS4_ID")), cPath, "1", AllTrim(oGrid:GetValue("RS4_NDOC")))
		MsgInfo(STR0046 + AllTrim(oGrid:GetValue("RS4_NDOC")) + " " + STR0047, "") //"Arquivo " - "salvo com sucesso"
	EndIf
Return

/*/{Protheus.doc} fDwnAsdTae
Realiza o download do arquivo assinado
@type  Static Function
@author Cícero Alves
@since 03/03/2022
/*/
Static Function fDwnAsdTae()	
Local oModel 		:= FWModelActivate()
Local oGrid			:= oModel:GetModel("PONA510_TAE")
Local cPath			:= ""
Local cTipoAssnt	:= ""
Local cIdDoc		:= ""
Local cNomeArq		:= ""

If oSign == Nil .Or. (ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado)
	oSign := PONXTAE():New("", .T.)
EndIf

If ValType(oSign:lLogado) <> "L" .Or. !oSign:lLogado
	FreeObj(oSign)
	Return .F.
EndIf

cPath := cGetFile("PDF|", STR0051, 0, , .F., GETF_LOCALHARD + GETF_RETDIRECTORY,.F.,) // "Selecione o Diretorio"

If !Empty(cPath)
	cNomeArq	:= AllTrim(oGrid:GetValue("RS4_NDOC"))
	cIdDoc		:= cValToChar(oGrid:GetValue("RS4_ID"))
	cTipoAssnt	:= oSign:chkSubType(cIdDoc)

	If !Empty(cPath) .And. !Empty(cTipoAssnt) .And. oSign:getDocument(cIdDoc, cPath, cTipoAssnt, cNomeArq)
		MsgInfo(STR0046 + cNomeArq + " " + STR0047, "") // "Arquivo " "salvo com sucesso"
	Else
		MsgInfo(STR0048, STR0003) // "Não foi possível salvar o documento. Verifique o diretório selecionado."
	EndIf
EndIf
Return

/*/{Protheus.doc} fFiltraRel
Aplica filtro no grid conforme seleção do combo box
@type function
@author Marco Nakazawa
@since 20/08/2026
@param oView, Objeto, View ativa
@param cFiltro, Caracter, Valor selecionado no combo (1/2/3/4)
@return Nil
/*/
Static Function fFiltraRel()
	Local oModel		:= FWModelActive()
	Local oView			:= FwViewActive()
	Local cFiltro		:= ""
	Local cComboVal		:= ""
	
	cComboVal := oModel:GetModel('PONA510_SRA'):GetValue('FILREL')

	If Empty(cComboVal)
		cComboVal := cUltFiltro
    EndIf
	
	If cComboVal == "1" .Or. Empty(cComboVal) // Todos
		cFiltro := "RS4_TPDOC = '1'"
		cUltFiltro := "1"
	ElseIf cComboVal == "2" // Espelho de Ponto
		cFiltro := "(RS4_TPDOC = '1' AND RS4_ROTINA IN ('PONR010', ' '))"
		cUltFiltro := "2"
	ElseIf cComboVal == "3" // Extrato Banco de Horas
		cFiltro := "(RS4_TPDOC = '1' AND RS4_ROTINA = 'PONR190')"
		cUltFiltro := "3"
	EndIf
	
	lUseFiltro := .T.
	
	oModel:DeActivate()
	oModel:GetModel("PONA510_TAE"):ClearData(.F., .F.) 
	oModel:GetModel("PONA510_TAE"):SetLoadFilter( {}, cFiltro)
	oModel:Activate()
	oModel:GetModel("PONA510_TAE"):GoLine(1)
	
	lUseFiltro := .F.
	oView:Refresh("PONA510_TAE")
Return

/*/{Protheus.doc} fResetFilt
Reseta o filtro do grid TAE ao ativar o modelo com um novo funcionário
@type function
@author Marco Nakazawa
@since 21/08/2026
@param oModel, Objeto, Modelo ativo
@return .T., Lógico, Sempre retorna verdadeiro para permitir ativação
/*/
Static Function fResetFilt(oModel)
	If !lUseFiltro
		oModel:GetModel("PONA510_TAE"):SetLoadFilter(, "RS4_TPDOC = '1'")
		cUltFiltro := "1"
	EndIf
Return .T.
