#INCLUDE "GFEA084.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP

Static s_ICMBAPI := SuperGetMv("MV_ICMBAPI",.F.,"1") 
Static s_ISSBAPI := SuperGetMv("MV_ISSBAPI",.F.,"1") 

// Variável auxiliar para identificar quando é uma rotina automática (sem interface).
// Motivo: nesse caso específico o Model instancia a View para validar o modelo.
// Por isso, a função IsBlind() não consegue identificar quando é rotina automática
// TODO: se abrir a rotina visual, e depois a rotina automática, não funciona, 
// pois a variável permanece como True na memória mesmo depois do fechamento.
Static lView     := .F.
Static lVwNrCalc := .F.

/* 
GFEA084
Frete Combinado (Refeito) 

Author: Octávio Augusto Felippe de Macedo
Data: 19/09/2012
*/

Function GFEA084()

	Local oBrowse := nIL

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWF")
	oBrowse:SetMenuDef("GFEA084")
	oBrowse:SetDescription("Registro de Frete Combinado")

	If SuperGetMv("MV_DSESIM",.F.,.F.)//Filtro Default para trazer apenas os cálculos Informados ou Simulados
		oBrowse:SetFilterDefault("GWF_ORIGEM $ '2;4' .And. GWF_TPCALC $ '1236'")
	Else//Filtro Default para trazer apenas os cálculos Informados
		oBrowse:SetFilterDefault("GWF_ORIGEM == '2' .And. GWF_TPCALC $ '1236'")
	EndIf

	oBrowse:Activate()
Return Nil
//-------------------------------------------------------------------

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1  ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "GFEA084VW()"     OPERATION 2  ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GFEA084" OPERATION 3  ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0006 ACTION "GFEA084EX()"     OPERATION 5  ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA084VW
	View diferenciada para não exibir determinados campos na visualização.
@author siegklenes.beulke
@since 06/06/2017
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function GFEA084EX()
	lVwNrCalc := .T.
	
	FWExecView("Excluir","GFEA084",5,,{ || .T. },{ || .T. },0,,{ || .T. },,, )
	lVwNrCalc := .F.
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA084VW
	View diferenciada para não exibir determinados campos na visualização.
@author siegklenes.beulke
@since 06/06/2017
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function GFEA084VW()
	Local oFWMVCWindow := Nil
	Local aCoors       := {}
	Local oView        := Nil
	Local oModel       := Nil
	Local oStruct      := Nil
	
	lVwNrCalc := .T.
	
	oView   := FWLoadView('GFEA084')
	oModel  := FWLoadModel('GFEA084')
	oStruct := oView:GetViewStruct("GFEA084_GWF")

	oStruct:RemoveField("GWF_QTDCAL")
	oStruct:RemoveField("GWF_CRIRAT")
	
	aCoors := FWGetDialogSize(oMainWnd)
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()
	
	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)
	oView:SetOperation(MODEL_OPERATION_VIEW)
	oView:SetUseCursor(.F.)
	oView:SetCloseOnOk({|| .T.})

	oFWMVCWindow := FWMVCWindow():New()
	oFWMVCWindow:SetUseControlBar(.T.)
	oFWMVCWindow:SetView(oView)
	oFWMVCWindow:SetCentered(.T.)
	oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
	oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
	oFWMVCWindow:SetTitle("Visualizar")
	oFWMVCWindow:Activate(,,Nil,.F.)
	oModel:Deactivate()
	
	FreeObJ(oModel)
	FreeObJ(oView)
	FreeObJ(oFWMVCWindow)
	
	lVwNrCalc := .F.
Return Nil

//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel     := Nil
	Local oStructGWF := FWFormStruct(1, "GWF")
	Local oStructGWI := FWFormStruct(1, "GWI")
	Local oStructGWH := FWFormStruct(1, "GWH")
	Local oStructGWG := FWFormStruct(1, "GWG")
	
	oStructGWF:SetProperty("GWF_NRCALC", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_VLAJUS", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_PCREIC", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_ICMRET", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NRROM" , MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_FILPRE", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NRPREF", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NRCONT", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_IDFRVI", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_ORIGEM", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_FINCAL", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_ENDENT", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_BAIENT", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_CIDENT", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_CARREG", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_SEQTRE", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_EMIREM", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NMREM" , MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_EMIDES", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NMDEST", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_EMIRED", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NMRED" , MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_EMIPAG", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NMPAG" , MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_TRANSP", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NMTRP" , MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_CIDORI", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NMCIOR", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_CIDDES", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NMCIDE", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_TPTRIB", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_BASISS", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_PCISS" , MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_VLISS" , MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_BASICM", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_PCICMS", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_VLICMS", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_BAPICO", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_IMPOST", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_TPCALC", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_TPFRET", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWF:SetProperty("GWF_NRCALC", MODEL_FIELD_INIT, Nil)

	If GFXCP2510('GWF_BASIBS')
		oStructGWF:SetProperty("GWF_BASIBS", MODEL_FIELD_OBRIGAT, .F.)
	EndIf
	If GFXCP2510('GWF_PCIBS')
		oStructGWF:SetProperty("GWF_PCIBS", MODEL_FIELD_OBRIGAT, .F.)
	EndIf
	If GFXCP2510('GWF_VLRIBS')
		oStructGWF:SetProperty("GWF_VLRIBS", MODEL_FIELD_OBRIGAT, .F.)
	EndIf
	If GFXCP2510('GWF_BASCBS')
		oStructGWF:SetProperty("GWF_BASCBS", MODEL_FIELD_OBRIGAT, .F.)
	EndIf
	If GFXCP2510('GWF_PCCBS')
		oStructGWF:SetProperty("GWF_PCCBS", MODEL_FIELD_OBRIGAT, .F.)
	EndIf
	If GFXCP2510('GWF_VLRCBS')
		oStructGWF:SetProperty("GWF_VLRCBS", MODEL_FIELD_OBRIGAT, .F.)
	EndIf

	oStructGWI:SetProperty("GWI_VLLIQ", MODEL_FIELD_OBRIGAT, .F.)
	oStructGWG:SetProperty("GWG_NRCALC", MODEL_FIELD_OBRIGAT, .F.)

	//Cria os campos virtuais na tela para o oStruct da GWI
	oStructGWF:AddField("Qtde Cálculo",;                              // Titulo do campo  ----- Selecionado
						"Quantidade de Cálculo",;                     // ToolTip do campo ----- Selecionado
						'GWF_QTDCAL',;                                // Nome do Campo
						'C',;                                         // Tipo do campo
						1 ,;                                          // Tamanho do campo
						0,;                                           // Decimal do campo
						NIL,;                                         // Code-block de validação do campo // {|| Pertence("12") }
						{|| GFE084QTCL() },;                          // When -- habilitado apenas quando “Frete Viagem”
						{ '1=Um por romaneio','2=Um por entrega' }, ; // Lista de valores permitido do campo
						.F.,;                                         // Indica se o campo tem preenchimento obrigatório
						{|| "1" },;                                   // Code-block de inicializacao do campo
						NIL,;                                         // Indica se trata de um campo chave
						NIL,;                                         // Indica se o campo pode receber valor em uma operação de update.
						.T.)                                          // Indica se o campo é virtual

	oStructGWF:AddField("Critério Rateio",;                           // Titulo do campo  ----- Selecionado
						"Critério de Rateio",;                        // ToolTip do campo ----- Selecionado
						'GWF_CRIRAT',;                                // Nome do Campo
						'C',;                                         // Tipo do campo
						1,;                                           // Tamanho do campo
						0,;                                           // Decimal do campo
						NIL,;                                         // Code-block de validação do campo	// {|| Pertence("12") }
						{|| GFE084CTRT() },;                          // When -- habilitado apenas quando “Qtde Cálculo” for “Um por Entrega”.
						{ "1=Peso Mercadoria","2=Valor Mercadoria","3=Volume","4=Quantidade" },; // Lista de valores permitido do campo
						.F.,;                                         // Indica se o campo tem preenchimento obrigatório
						{|| SuperGetMv("MV_CRIRAT",, "1") },;         // Code-block de inicializacao do campo
						NIL,;                                         // Indica se trata de um campo chave
						NIL,;                                         // Indica se o campo pode receber valor em uma operação de update.
						.T.)                                          // Indica se o campo é virtual

	
	//Cria os campos virtuais na tela para o oStruct da GWH
	oModel := MPFormModel():New("GFEA084", /*bPre*/, {|oModel| GFEA084POS(oModel)}/* bPost*/, {|oModel| GFEA084CMT(oModel)}/*bCommit*/, /*bCancel*/)

	oModel:AddFields("GFEA084_GWF", Nil, oStructGWF, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:AddGrid("GFEA084_GWI", "GFEA084_GWF", oStructGWI, /*bLinePre*/,, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:SetRelation("GFEA084_GWI", {{"GWI_FILIAL","xFilial('GWI')"},{"GWI_NRCALC","GWF_NRCALC"}},"GWI_FILIAL+GWI_NRCALC")
	
	oModel:GetModel("GFEA084_GWI"):SetUniqueLine( {"GWI_CDCOMP"})
	
	oModel:GetModel("GFEA084_GWI"):SetDelAllLine(.T.)
	
	oModel:AddGrid("GFEA084_GWH", "GFEA084_GWF", oStructGWH, /*bLinePre*/, {|oModel| GFE084PreT(oModel), GFEA084PSG(oModel)}, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:SetRelation("GFEA084_GWH", {{"GWH_FILIAL","xFilial('GWH')"},{"GWH_NRCALC","GWF_NRCALC"}},"GWH_FILIAL+GWH_NRCALC")
	oModel:GetModel("GFEA084_GWH"):SetUniqueLine({"GWH_FILIAL", "GWH_CDTPDC", "GWH_EMISDC", "GWH_SERDC", "GWH_NRDC"})

	oModel:GetModel("GFEA084_GWH"):SetDelAllLine(.T.)
	oModel:GetModel("GFEA084_GWH"):SetMaxLine(9999)
	oModel:SetDescription("Registro de Frete Combinado")

	oModel:AddGrid("GFEA084_GWG", "GFEA084_GWF", oStructGWG, /*bLinePre*/, , /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:SetRelation("GFEA084_GWG", {{"GWG_FILIAL","xFilial('GWG')"},{"GWG_NRCALC","GWF_NRCALC"}}, "GWG_FILIAL+GWG_NRCALC" )	
	oModel:GetModel("GFEA084_GWG"):SetUniqueLine({"GWG_FILIAL", "GWG_NRCALC", "GWG_CDCLFR", "GWG_CDTPOP", "GWG_CDEMIT", "GWG_NRTAB", "GWG_NRNEG", "GWG_CDFXTV", "GWG_NRROTA"})
	
	oModel:GetModel("GFEA084_GWG"):SetDelAllLine(.T.)
	oModel:GetModel("GFEA084_GWG"):SetOptional(.T.)

	oModel:SetDescription("Tabela do Calculo de Frete")	

Return oModel
//-------------------------------------------------------
Static Function ViewDef()
	Local oModel     := FWLoadModel("GFEA084")
	Local oView      := Nil
	Local oStructGWF := FWFormStruct(2, "GWF")
	Local oStructGWI := FWFormStruct(2, "GWI")
	Local oStructGWH := FWFormStruct(2, "GWH", ,.F.,.F.,.T.)
	
	// A função ViewDef somente é executada quando possui interface
	lView := .T.

	// Aba "DIVERSOS"
	oStructGWF:AddField('GWF_QTDCAL',;            // Nome do Campo
						'50',;                    // Ordem
						'Qtde Cálculo',;          // Titulo do campo  ---- Selecionado
						'Quantidade de Cálculo',; // Descrição do campo  ---- Selecionado
						{'...'},;                 // Array com Help  ---- Selecionado
						'C',;                     // Tipo do campo
						'@!',;                    // Picture
						NIL,;                     // Bloco de Picture Var
						'',;                      // Consulta F3
						.T.,;                     // Indica se o campo é editável
						'3',;                     // Pasta do campo
						NIL,;                     // Agrupamento do campo
						{ '1=Um por romaneio','2=Um por entrega' }, ; // Lista de valores permitido do campo (Combo)
						NIL,;                     // Tamanho Maximo da maior opção do combo
						NIL,;                     // Inicializador de Browse
						.T.,;                     // Indica se o campo é virtual
						NIL)                      // Picture Variável

	oStructGWF:AddField('GWF_CRIRAT',;            // Nome do Campo
						'51',;                    // Ordem
						'Critério Rateio',;       // Titulo do campo  ---- Selecionado
						'Critério de Rateio',;    // Descrição do campo  ---- Selecionado
						{'...'},;                 // Array com Help  ---- Selecionado
						'C',;                     // Tipo do campo
						'@!',;                    // Picture
						NIL,;                     // Bloco de Picture Var
						'',;                      // Consulta F3
						.T.,;                     // Indica se o campo é editável
						'3',;                     // Pasta do campo
						NIL,;                     // Agrupamento do campo
						{ "1=Peso Mercadoria","2=Valor Mercadoria","3=Volume","4=Quantidade"}, ; // Lista de valores permitido do campo (Combo)
						NIL,;                     // Tamanho Maximo da maior opção do combo
						NIL,;                     // Inicializador de Browse
						.T.,;                     // Indica se o campo é virtual
						NIL)                      // Picture Variável

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("GFEA084_GWF", oStructGWF)

	oStructGWF:SetProperty("GWF_OBS", MVC_VIEW_TITULO, STR0016) //"Justificativa"
	
	If !lVwNrCalc
		oStructGWF:RemoveField("GWF_NRCALC")
	EndIf 
	oStructGWF:RemoveField("GWF_VLAJUS")
	oStructGWF:RemoveField("GWF_PCREIC")
	oStructGWF:RemoveField("GWF_NRROM" )
	oStructGWF:RemoveField("GWF_FILPRE")
	oStructGWF:RemoveField("GWF_NRPREF")
	oStructGWF:RemoveField("GWF_NRCONT")
	oStructGWF:RemoveField("GWF_AGRUP" )
	oStructGWF:RemoveField("GWF_ORIGEM")
	oStructGWF:RemoveField("GWF_FINCAL")
	oStructGWF:RemoveField("GWF_ENDENT")
	oStructGWF:RemoveField("GWF_BAIENT")
	oStructGWF:RemoveField("GWF_CIDENT")
	oStructGWF:RemoveField("GWF_CARREG")
	oStructGWF:RemoveField("GWF_SEQTRE")
	oStructGWF:RemoveField("GWF_EMIREM")
	oStructGWF:RemoveField("GWF_NMREM" )
	oStructGWF:RemoveField("GWF_EMIDES")
	oStructGWF:RemoveField("GWF_NMDEST")
	oStructGWF:RemoveField("GWF_EMIRED")
	oStructGWF:RemoveField("GWF_NMRED" )
	oStructGWF:RemoveField("GWF_EMIPAG")
	oStructGWF:RemoveField("GWF_NMPAG" )
	oStructGWF:RemoveField("GWF_TRANSP")
	oStructGWF:RemoveField("GWF_NMTRP" )
	oStructGWF:RemoveField("GWF_CIDORI")
	oStructGWF:RemoveField("GWF_NMCIOR")
	oStructGWF:RemoveField("GWF_CIDDES")
	oStructGWF:RemoveField("GWF_NMCIDE")
	oStructGWF:RemoveField("GWF_TPTRIB")
	oStructGWF:RemoveField("GWF_BASISS")
	oStructGWF:RemoveField("GWF_PCISS" )
	oStructGWF:RemoveField("GWF_VLISS" )
	oStructGWF:RemoveField("GWF_BASICM")
	oStructGWF:RemoveField("GWF_PCICMS")
	oStructGWF:RemoveField("GWF_VLICMS")
	oStructGWF:RemoveField("GWF_BAPICO")
	oStructGWF:RemoveField("GWF_IMPOST")
	oStructGWF:RemoveField("GWF_VLPIS" )
	oStructGWF:RemoveField("GWF_VLCOFI")
	oStructGWF:RemoveField("GWF_TPCALC")
	oStructGWF:RemoveField("GWF_TPFRET")
	If GFXCP2510('GWF_BASIBS')
		oStructGWF:RemoveField("GWF_BASIBS")
	EndIf
	If GFXCP2510('GWF_PCIBS')
		oStructGWF:RemoveField("GWF_PCIBS")
	EndIf
	If GFXCP2510('GWF_VLRIBS')
		oStructGWF:RemoveField("GWF_VLRIBS")
	EndIf
	If GFXCP2510('GWF_BASCBS')
		oStructGWF:RemoveField("GWF_BASCBS")
	EndIf
	If GFXCP2510('GWF_PCCBS')
		oStructGWF:RemoveField("GWF_PCCBS")
	EndIf
	If GFXCP2510('GWF_VLRCBS')
		oStructGWF:RemoveField("GWF_VLRCBS")
	EndIf

	If AScan(oStructGWF:aFields,{|x| x[1] == "GWF_FILIAL"}) != 0
		oStructGWF:RemoveField("GWF_FILIAL")
	EndIf

	oView:AddGrid("GFEA084_GWI", oStructGWI)

	oStructGWI:RemoveField("GWI_FILIAL")
	oStructGWI:RemoveField("GWI_NRCALC")
	oStructGWI:RemoveField("GWI_CDCLFR")
	oStructGWI:RemoveField("GWI_CDTPOP")
	oStructGWI:RemoveField("GWI_QTCALC")
	oStructGWI:RemoveField("GWI_IDMIN" )
	oStructGWI:RemoveField("GWI_TOTFRE")
	oStructGWI:RemoveField("GWI_VLLIQ")

	oStructGWI:SetProperty("GWI_CDCOMP", MVC_VIEW_ORDEM, '01')
	oStructGWI:SetProperty("GWI_VLFRET", MVC_VIEW_ORDEM, '02')
	oStructGWI:SetProperty("GWI_BASICM", MVC_VIEW_ORDEM, '03')
	oStructGWI:SetProperty("GWI_BASPIS", MVC_VIEW_ORDEM, '04')

	oView:AddGrid("GFEA084_GWH", oStructGWH)

	oStructGWH:RemoveField("GWH_NRCALC")

	oStructGWH:SetProperty("GWH_FILIAL", MVC_VIEW_ORDEM, '06')
	oStructGWH:SetProperty("GWH_NRDC"  , MVC_VIEW_ORDEM, '01')
	oStructGWH:SetProperty("GWH_CDTPDC", MVC_VIEW_ORDEM, '02')
	oStructGWH:SetProperty("GWH_EMISDC", MVC_VIEW_ORDEM, '03')
	oStructGWH:SetProperty("GWH_SERDC" , MVC_VIEW_ORDEM, '04')
	oStructGWH:SetProperty("GWH_TRECHO", MVC_VIEW_ORDEM, '05')
	oStructGWH:SetProperty("GWH_TRECHO", MVC_VIEW_TITULO, 'Trecho')

	oView:CreateHorizontalBox("MASTER", 50)
	oView:CreateHorizontalBox("DETAIL", 50)

	oView:CreateFolder("IDFOLDER", "DETAIL")
	oView:AddSheet("IDFOLDER", "IDSHEET01", STR0017) //"Componentes de Frete"
	oView:AddSheet("IDFOLDER", "IDSHEET02", STR0018) //"Documentos de Carga"

	oView:CreateHorizontalBox("DETAIL_GWI", 100,,, "IDFOLDER", "IDSHEET01" )

	oView:CreateVerticalBox("EMBAIXOESQ", 90,,, "IDFOLDER", "IDSHEET02" )
	oView:CreateVerticalBox("EMBAIXODIR", 10,,, "IDFOLDER", "IDSHEET02" )

	oView:SetOwnerView("GFEA084_GWF", "MASTER")

	oView:CreateVerticalBox("EMBAIXOESQ", 90,,, "IDFOLDER", "IDSHEET02" )
	oView:CreateVerticalBox("EMBAIXODIR", 10,,, "IDFOLDER", "IDSHEET02" )

	oView:SetOwnerView("GFEA084_GWF", "MASTER")

	oView:SetOwnerView("GFEA084_GWI", "DETAIL_GWI")
	oView:SetOwnerView("GFEA084_GWH", "EMBAIXOESQ")

	oView:AddOtherObject("OTHER_PANEL", {|oPanel, oModel| GFEA084ADD(oPanel,oModel)})
	oView:SetOwnerView("OTHER_PANEL", "EMBAIXODIR")
	
	oView:SetViewAction( 'BUTTONCANCEL', { |oView| ROLLBACKSXE() } )

Return oView

//-------------------------------------------------------------------

Static Function GFEA084ADD(oPanel, oView)

	@ 10, 10 Button STR0050 Size 36, 13 Message STR0051 Pixel Action GFEADOCRE() OF oPanel //"Doc.Relac." ### "Documentos Relacionados"

Return .T.
//-------------------------------------------------------------------

Static Function GFEADOCRE()

	Local oView      := FWViewActive()
	Local aAreaGW1   := {}
	Local aAreaGWU   := GWU->( GetArea() )
	Local oModel     := oView:GetModel()
	Local oModelGWH  := oModel:GetModel("GFEA084_GWH")
	Local cTrecho    := ""
	Local cCdDest    := ""
	Local cQuery     := ""
	Local cAliasGW1  := ""
	Local cFilRom    := ""
	Local cNrRom	 := ""
	Local nTotLines  := 0
	Local nLine      := oModelGWH:GetLine()
	Local aChavAgrDC := ""
	Local cDocs      := ""
	Local lNaoRelac  := .F.
	Local nTotDC     := 0
	Local nDCAd      := 0
	Local lCalcFCRel := .F.
	Local lCpoSDOC   := GfeVerCmpo({"GW1_SDOC"})

	aChavAgrDC := GFEA084AGR(oModelGWH)

	If oModelGWH:IsEmpty()
		Help(,, 'HELP',, "Informe pelo menos um Documento de Carga para buscar os relacionados.", 1, 0) //""
		Return .F.
	EndIf

	If oModelGWH:IsDeleted()
		Help(,, 'HELP',, "O Registro está deletado. Selecione um registro ativo.", 1, 0) //""
		Return .F.
	EndIf

	If oModelGWH:SeekLine({{"GWH_TRECHO", "  "}}) .And. !oModelGWH:IsDeleted()

		Help(,, 'HELP',, "Todos os Documentos de Carga vinculados devem possuir trecho informado.", 1, 0) //"Todos os Documentos de Carga vinculados devem possuir trecho informado."
		oModelGWH:GoLine(nLine)      
		Return .F.
 
	EndIf  
	
	oModelGWH:GoLine(nLine)
	
	dbSelectArea("GW1")
	GW1->( dbSetOrder(1) )
	If GW1->( dbSeek(xFilial("GW1") + oModelGWH:GetValue("GWH_CDTPDC") + oModelGWH:GetValue("GWH_EMISDC") + oModelGWH:GetValue("GWH_SERDC") + oModelGWH:GetValue("GWH_NRDC")) )

		If GFXCP1212210('GW1_FILROM') .And. !Empty(GW1->GW1_FILROM)
			cFilRom := GW1->GW1_FILROM
		Else
			cFilRom := GW1->GW1_FILIAL
		EndIf
		cNrRom  := GW1->GW1_NRROM

		dbSelectArea("GWN")
		GWN->( dbSetOrder(1) )
		If GWN->( dbSeek(cFilRom + cNrRom) )

			cTrecho := oModelGWH:GetValue('GWH_TRECHO')
			
			cAliasGW1 := GetNextAlias()
			cQuery := "SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC,GW1_NRROM,GW1_CDDEST, GW1_SDOC " 
			cQuery += "FROM  "+RetSqlName("GW1") 
			cQuery += " WHERE  GW1_FILIAL = '"+GW1->GW1_FILIAL+"' " 
			cQuery += "AND GW1_NRROM  = '"+GWN->GWN_NRROM+"' " 
			cQuery += "AND D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY GW1_FILIAL, GW1_NRROM, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, R_E_C_N_O_"
			cQuery := ChangeQuery(cQuery)
		
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW1, .F., .T.)
			
			(cAliasGW1)->( dbGoTop() )

			While !(cAliasGW1)->( Eof() ) .And. (cAliasGW1)->GW1_FILIAL == GW1->GW1_FILIAL .And. (cAliasGW1)->GW1_NRROM == GWN->GWN_NRROM

				nTotDC++
				lCalcFCRel := .F.
				
				//Verifica se já não existe Cálculo de Frete Combinado para o Documento de Carga
				dbSelectArea("GWH")
				GWH->( dbSetOrder(2) )
				GWH->( dbSeek((cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_CDTPDC + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC) )
				While !GWH->( Eof() ) .And. (cAliasGW1)->GW1_FILIAL == GWH->GWH_FILIAL .And. (cAliasGW1)->GW1_CDTPDC == GWH->GWH_CDTPDC .And. ;
					  (cAliasGW1)->GW1_EMISDC == GWH->GWH_EMISDC .And. (cAliasGW1)->GW1_SERDC == GWH->GWH_SERDC .And. (cAliasGW1)->GW1_NRDC == GWH->GWH_NRDC

					dbSelectArea("GWF")
					GWF->( dbSetOrder(1) )
					If GWF->( dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC) ) .And. GWF->GWF_ORIGEM $ "2;4" .And. AllTrim(GWF->GWF_SEQTRE) == AllTrim(cTrecho)
						lCalcFCRel := .T.
						Exit
					EndIf

					GWH->( dbSkip() )

				EndDo

				If lCalcFCRel
					(cAliasGW1)->( dbSkip() )
					Loop
				EndIf

				//Verifica se o trecho existe para o Documento de Carga
				dbSelectArea("GWU")
				GWU->( dbSetOrder(1) )
				If !GWU->( dbSeek((cAliasGW1)->GW1_FILIAL + (cAliasGW1)->GW1_CDTPDC + (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC + cTrecho) )
					RestArea(aAreaGWU)
					(cAliasGW1)->( dbSkip() )
					Loop
				EndIf

				RestArea(aAreaGWU)

				//Verifica se o destinatário é o mesmo do Documento de Carga principal
				aAreaGW1 := (cAliasGW1)->( GetArea() )

				cCdDest := (cAliasGW1)->GW1_CDDEST
				
				nTotLines := oModelGWH:Length() + 1
							
				dbSelectArea("GW1")
				GW1->( dbSetOrder(1) )
				If GW1->( dbSeek(aChavAgrDC[1]) )

					If oModel:GetModel("GFEA084_GWF"):GetValue("GWF_IDFRVI") != "1" .And. cCdDest != GW1->GW1_CDDEST .And. Posicione("GU3", 1, xFilial("GU3") + Posicione("GWU", 1, aChavAgrDC[2], "GWU_CDTRP"), "GU3_AUTON") != "1"
						RestArea(aAreaGW1)

						If Empty(cDocs)
							cDocs += AllTrim(GW1->GW1_NRDC)
						Else
							cDocs += ", " + AllTrim(GW1->GW1_NRDC)
						EndIf

						lNaoRelac := .T.

						nDCAd++
						RestArea(aAreaGW1)
						(cAliasGW1)->( dbSkip() )
						Loop
					EndIf
 
				EndIf

				RestArea(aAreaGW1)

				If !(oModelGWH:SeekLine({{"GWH_CDTPDC", (cAliasGW1)->GW1_CDTPDC},{"GWH_EMISDC", (cAliasGW1)->GW1_EMISDC}, ;
									     {"GWH_SERDC", (cAliasGW1)->GW1_SERDC},{"GWH_NRDC", (cAliasGW1)->GW1_NRDC},{"GWH_TRECHO", cTrecho}}) .And. ;
				   						 !oModelGWH:IsDeleted())

			    	If oModelGWH:AddLine(.T.) != nTotLines
			    		oModelGWH:GoLine(nLine)
						oView:Refresh()
						Help(,,'HELP',, oModel:GetErrorMessage()[6], 1, 0)
			    		Return .F.

			    	Else

					    nDCAd++

						oModelGWH:SetValue('GWH_CDTPDC', (cAliasGW1)->GW1_CDTPDC)
						oModelGWH:SetValue('GWH_EMISDC', (cAliasGW1)->GW1_EMISDC)
						oModelGWH:SetValue('GWH_SERDC' , (cAliasGW1)->GW1_SERDC )
						oModelGWH:SetValue('GWH_NRDC'  , (cAliasGW1)->GW1_NRDC  )
						oModelGWH:SetValue('GWH_TRECHO', cTrecho        )
						If lCpoSDOC
							oModelGWH:SetValue('GWH_SDOCDC', (cAliasGW1)->GW1_SDOC)
						EndIf

					EndIf

			   	EndIf

				(cAliasGW1)->( dbSkip() )   
			EndDo

			(cAliasGW1)->(dbCloseArea())
		EndIf

		If nTotDC <= 1
			Help(,, 'HELP',, "Não há Documentos de Carga relacionados a este.", 1, 0)
		ElseIf nDCAd == 0
			Help(,, 'HELP',, "Todos os Documentos de Carga relacionados já foram vinculados.", 1, 0)
		ElseIf lNaoRelac
			If "," $ cDocs
				Help( ,, 'HELP',, "Os Documentos de Carga de número " + AllTrim(cDocs) + " estão relacionados mas não foram inclusos, pois, os destinatários são diferentes do Documento de Carga " + AllTrim(oModelGWH:GetValue("GWH_NRDC", 1)) + ", não sendo Frete Viagem nem tendo Transportador Autônomo.", 1, 0) //""
			Else
				Help( ,, 'HELP',, "O Documento de Carga de número " + AllTrim(cDocs) + " está relacionado mas não foi incluso, pois, o destinatário é diferente do Documento de Carga " + AllTrim(oModelGWH:GetValue("GWH_NRDC", 1)) + ", não sendo Frete Viagem nem tendo Transportador Autônomo.", 1, 0) //""
			EndIf
		EndIf

	EndIf
	
	oModelGWH:GoLine(nLine)

	oView:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA084POS

	Função executada no evento Post do Model

	@author  Equipe GFE
	@example GFEA084POS(oModel)
	@param   oModel, Objeto, Model do MVC
	@return  Booleano
	@table   GWF, GWI, GWH
/*/
//-------------------------------------------------------------------
Function GFEA084POS(oModel)

	Local nOp       := oModel:GetOperation()
	Local oModelGWF := oModel:GetModel("GFEA084_GWF")
	Local oModelGWI := oModel:GetModel("GFEA084_GWI")
	Local oModelGWH := oModel:GetModel("GFEA084_GWH")
	Local nLineGWH  := oModelGWH:GetLine()
	Local aAgrDC    := GFEA084AGR(oModelGWH)
	Local nCount
	Local aRetCalc
	//Valor do Pis a ser retirado da base
	Local nVlPIS
	Local nVlCOFINS
	//Array que irá indicar os cálculos a serem excluídos
	Local aDelCalc := {}
	//Indica se o transportador é autônomo
	Local lAuton
	Local lCalcCot := IsInCallStack("GFEInsGWF")
	
	//Valor do critério de rateio
	Local cParamRat
	Local nQtdPISCOF := 0
	Local lTrechoPC
	Local nQtdTotal := 0
	Local nCont
	Local nLineGWH2 := 1
	
	Local nX,nY,nZ,nDcValid
	Local cCriterio
	Local aDocs := {}
	Local aDoc
	Local aRet
	Local aSomaCrit := {0,0}
	Local nTotalCrit := 0 //Total do critério
	Local lPesoCub
	Local aEntregas // Docs x cálculos, separados por entregas/origem/destino
	Local aCalcXEntr := {} // Relacionamento cálculo x entrega
	Local aCalcxCrit := {} // Relacionamento cálculo x valor total do critério de rateio escolhido
	Local aCalcxComb := {} //Relacionamento cálculo x valor combinado sem imposto
	Local aCalcDel   := {} //Calculos a serem deletados 
	Local oRetValid 	   //Armazena objeto da classe GFEXFBB
	Local cDelNrRom
	Local cOrigem
	Local cCalc
	Local cQuery
	Local cAliasGWF
	Local nValComp
	Local nComps := 0
	Local aGWFCopy    := {}
	Local aGWICopy    := {}
	Local aGWFClone   := {}
	Local aGWIClone   := {}
	Local aGWHClone   := {}
	Local cDelTpCalc  := ""
	Local lExcTodos   := .F.
	Local cNrCalcGWF  := ""
	Local nF          := 0
	Local nValLiq     := 0
	Local nDocs 	  := 0
	Local nTotValComp := 0
	Local nTotValLiq  := 0
	Local cAliasGWN   := Nil
	Local aAuxCalc    := {}
	Local cJoin       := Nil

	Static aCalcResult := {}
	
	If nOp == MODEL_OPERATION_INSERT .Or. nOp == MODEL_OPERATION_UPDATE
		
		If !lCalcCot .And. Empty(oModelGWF:GetValue("GWF_OBS"))
			Help( ,, 'HELP',, STR0021, 1, 0) //"Justificativa para Cálculo Combinado deve ser informado."
			Return .F.
		EndIf

		If oModelGWH:SeekLine({{"GWH_TRECHO", "  "}}) .And. !oModelGWH:IsDeleted()

			Help(,, 'HELP',, "Todos os Documentos de Carga vinculados devem possuir trecho informado.", 1, 0) //"Todos os Documentos de Carga vinculados devem possuir trecho informado."
			oModelGWH:GoLine(nLineGWH)
			Return .F.

		EndIf

		oModelGWH:GoLine(nLineGWH)

		nDcValid := 0
		nF := oModelGWH:Length()
		For nCount := 1 To nF
			oModelGWH:GoLine(nCount)

			If !oModelGWH:IsDeleted()
				nDcValid++

				dbSelectArea("GWH")
				GWH->( dbSetOrder(2) )
				GWH->( dbSeek(oModelGWH:GetValue("GWH_FILIAL") + oModelGWH:GetValue("GWH_CDTPDC") + oModelGWH:GetValue("GWH_EMISDC") + oModelGWH:GetValue("GWH_SERDC") + oModelGWH:GetValue("GWH_NRDC")) )
				While !GWH->( Eof() ) .And. GWH->GWH_FILIAL == oModelGWH:GetValue("GWH_FILIAL") ;
									  .And. GWH->GWH_CDTPDC == oModelGWH:GetValue("GWH_CDTPDC") ;
									  .And. GWH->GWH_EMISDC == oModelGWH:GetValue("GWH_EMISDC") ;
									  .And. GWH->GWH_SERDC == oModelGWH:GetValue("GWH_SERDC") ;
									  .And. GWH->GWH_NRDC == oModelGWH:GetValue("GWH_NRDC")

					dbSelectArea("GWF")
					GWF->( dbSetOrder(1) )
					If GWF->( dbSeek(xFilial("GWF") + GWH->GWH_NRCALC) )

						If !(GWF->GWF_ORIGEM $ "2;4")

							If !GFEVldDocFrete(GWF->GWF_NRCALC)
								Help( ,, 'HELP',,STR0042 + GWF->GWF_NRCALC + STR0043, 1, 0) //"Um dos documentos de carga do cálculo " ### " está vinculado a documento de frete."
								Return .F.
							EndIf

							If !GFEVldPreFat(GWF->GWF_NRCALC)
								Help( ,, 'HELP',,STR0037 + GWF->GWF_NRCALC + STR0039, 1, 0) //"Cálculo" ### " está associado a pré-fatura de frete."
								Return .F.
							EndIf

							If !GFEVldContr(GWF->GWF_NRCALC)
								Help( ,, 'HELP',,STR0037 + GWF->GWF_NRCALC + STR0038, 1, 0) //"Cálculo " ### " está associado a contrato com autônomo."
								Return .F.
							EndIf
							
							If !ValCalcLot()
								Help( ,, 'HELP',,STR0037 + GWF->GWF_NRCALC + " vinculado a lote de provisão", 1, 0) //"Cálculo "  
								Return .F.
							EndIf

							AAdd(aDelCalc, GWF->GWF_NRCALC)

						ElseIf nOp == MODEL_OPERATION_INSERT .And. AllTrim(GWF->GWF_SEQTRE) == AllTrim(oModelGWH:GetValue("GWH_TRECHO", aAgrDC[3]))
							Help( ,, 'HELP',, STR0045, 1, 0) //"Já existe um Frete Combinado para o trecho do documento de carga informado."
							Return .F.
						EndIf

					EndIf

					GWH->( dbSkip() )

				EndDo

			EndIf

		Next nCount
		
		If nDcValid == 0
			Help( ,, 'HELP',, "Não existem documentos de carga válidos. Verifique a aba 'Documentos de carga'", 1, 0)
			Return .F.
		EndIf

		// Posiciona no primeiro registro não deletado
		nLineGWH := 1
		oModelGWH:GoLine(nLineGWH)

		nF := oModelGWH:Length()
		Do While nLineGWH <= nF .And. oModelGWH:IsDeleted()
			nLineGWH++
			oModelGWH:GoLine(nLineGWH)
		EndDo

		//Cálculo dos valores
		aRetCalc := GFEA084CLC(oModel)
		nPos := IIf(oModelGWF:GetValue("GWF_QTDCAL") == '1',1,aScan( aRetCalc, { |x| x[25] == nLineGWH }))

		dbSelectArea("GU3")
		GU3->( dbSetOrder(1) )
		If GU3->( dbSeek(xFilial("GU3") + aRetCalc[nPos][9]) )
			lAuton := (GU3->GU3_AUTON == "1")
		EndIf

		//Atribuição dos valores
		oModelGWF:LoadValue("GWF_IMPOST", aRetCalc[nPos][1] )
		oModelGWF:LoadValue("GWF_EMIREM", aRetCalc[nPos][4] )
		oModelGWF:LoadValue("GWF_EMIDES", aRetCalc[nPos][5] )
		oModelGWF:LoadValue("GWF_CIDORI", aRetCalc[nPos][6] )
		oModelGWF:LoadValue("GWF_CIDDES", aRetCalc[nPos][7] )
		oModelGWF:LoadValue("GWF_EMIRED", aRetCalc[nPos][8] )
		oModelGWF:LoadValue("GWF_TRANSP", aRetCalc[nPos][9] )
		oModelGWF:LoadValue("GWF_EMIPAG", aRetCalc[nPos][10])
		oModelGWF:LoadValue("GWF_TPFRET", aRetCalc[nPos][11])
		oModelGWF:LoadValue("GWF_NRROM" , aRetCalc[nPos][12])
		oModelGWF:LoadValue("GWF_FINCAL", aRetCalc[nPos][13])
		oModelGWF:LoadValue("GWF_TPCALC", aRetCalc[nPos][14])
		oModelGWF:LoadValue("GWF_TPTRIB", aRetCalc[nPos][21])

		oModelGWF:LoadValue("GWF_FILROM", Iif(!Empty("GWF_NRROM"), aRetCalc[nPos][32], ""))

		If !lAuton

			oModelGWF:LoadValue("GWF_PCICMS", aRetCalc[nPos][2])
			oModelGWF:LoadValue("GWF_PCISS" , aRetCalc[nPos][3])

			If aRetCalc[nPos][1] == "1"
				oModelGWF:LoadValue("GWF_BASISS", 0)
				oModelGWF:LoadValue("GWF_BASICM", aRetCalc[nPos][19])
			Else
				oModelGWF:LoadValue("GWF_BASISS", aRetCalc[nPos][20])
				oModelGWF:LoadValue("GWF_BASICM", 0)
			EndIf
			
			oModelGWF:LoadValue("GWF_VLISS" , aRetCalc[nPos][17])
			oModelGWF:LoadValue("GWF_VLICMS", aRetCalc[nPos][18])
			oModelGWF:LoadValue("GWF_PCREIC", aRetCalc[nPos][24])

			If GFXCP2510('GWF_BASIBS')
				oModelGWF:LoadValue("GWF_BASIBS", aRetCalc[nPos][26])
			EndIf
			If GFXCP2510('GWF_PCIBS')
				oModelGWF:LoadValue("GWF_PCIBS", aRetCalc[nPos][27])
			EndIf
			If GFXCP2510('GWF_VLRIBS')
				oModelGWF:LoadValue("GWF_VLRIBS", aRetCalc[nPos][28])
			EndIf
			If GFXCP2510('GWF_BASCBS')
				oModelGWF:LoadValue("GWF_BASCBS", aRetCalc[nPos][29])
			EndIf
			If GFXCP2510('GWF_PCCBS')
				oModelGWF:LoadValue("GWF_PCCBS", aRetCalc[nPos][30])
			EndIf
			If GFXCP2510('GWF_VLRCBS')
				oModelGWF:LoadValue("GWF_VLRCBS", aRetCalc[nPos][31])
			EndIf
		EndIf

		oModelGWH:GoLine(nLineGWH2)
		While nLineGWH2 <= oModelGWH:Length() .And. oModelGWH:IsDeleted()
			nLineGWH2++
			oModelGWH:GoLine(nLineGWH2)
		EndDo
		oModelGWF:LoadValue("GWF_SEQTRE", oModelGWH:GetValue("GWH_TRECHO"))
		If Empty(oModelGWF:GetValue("GWF_ORIGEM")) .Or. oModelGWF:GetValue("GWF_ORIGEM") == "1"
			oModelGWF:LoadValue("GWF_ORIGEM", '2')
		EndIf

		//Rateio do Imposto para os componentes///

		If !lAuton
		    //Chamado TRRFNX - Cópia da regra de tributação Pis/Cofins do Documento de Frete
		    cParamRat := GetNewPar('MV_CRIRAT', '5')

		    If cParamRat == '5'
		    	GFEMsgErro("Parâmetro MV_CRIRAT (Critério de Rateio) não está cadastrado")
		    EndIf

		 	If cParamRat $ '1;4'

			 	For nCont := 1 To oModelGWH:GetQtdLine()

					oModelGWH:GoLine( nCont )

					If !(oModelGWH:IsDeleted(nCont))

						//Verificação para que caso o Parametro de Rateio seja por peso ou volume e os mesmos
						//venham zerados, seja atribuido a quantidade.
						
						dbSelectArea("GW8")
					    dbSetOrder(1)
					    dbSeek(oModelGWH:GetValue("GWH_FILIAL")+oModelGWH:GetValue("GWH_CDTPDC")+oModelGWH:GetValue("GWH_EMISDC")+oModelGWH:GetValue("GWH_SERDC")+oModelGWH:GetValue("GWH_NRDC"))
					    While !Eof() .And. oModelGWH:GetValue("GWH_FILIAL")+oModelGWH:GetValue("GWH_CDTPDC")+oModelGWH:GetValue("GWH_EMISDC")+oModelGWH:GetValue("GWH_SERDC")+oModelGWH:GetValue("GWH_NRDC") == GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC

					    	If cParamRat == '1' //Peso

					        	If GW8->GW8_TRIBP == '1'
					        		If GW8->GW8_PESOR > GW8->GW8_PESOC
						        		nQtdPISCOF += GW8->GW8_PESOR
					        		Else
						        		nQtdPISCOF += GW8->GW8_PESOC
					        		EndIf
						    	EndIf

					    	ElseIf cParamRat == '3' //Volume

				    			If GW8->GW8_TRIBP == '1'
						    		nQtdPISCOF += GW8->GW8_VOLUME
						    	EndIf

					    	EndIf

							GW8->( dbSkip() )
					   	EndDo

					EndIf

				Next nCont

		 		If nQtdPISCOF == 0
					cParamRat := '4'
				Else
					//Zera a variavel para não influenciar no cálculo de PIS e Cofins
					nQtdPISCOF := 0
				EndIf

		 	EndIf


			For nCont := 1 To oModelGWH:GetQtdLine()

				oModelGWH:GoLine( nCont )

				If !(oModelGWH:IsDeleted(nCont))
						
					dbSelectArea("GW8")
					dbSetOrder(1)
					dbSeek(oModelGWH:GetValue("GWH_FILIAL")+oModelGWH:GetValue("GWH_CDTPDC")+oModelGWH:GetValue("GWH_EMISDC")+oModelGWH:GetValue("GWH_SERDC")+oModelGWH:GetValue("GWH_NRDC"))
					While !Eof() .And. oModelGWH:GetValue("GWH_FILIAL")+oModelGWH:GetValue("GWH_CDTPDC")+oModelGWH:GetValue("GWH_EMISDC")+oModelGWH:GetValue("GWH_SERDC")+oModelGWH:GetValue("GWH_NRDC") == GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC

						If GW8->GW8_TRIBP == '1'
				        	lTrechoPC := .T.
				        EndIf
				        If cParamRat == '1' //Peso

				        	If GW8->GW8_TRIBP== '1'
				        		If GW8->GW8_PESOR > GW8->GW8_PESOC
					        		nQtdPISCOF += GW8->GW8_PESOR
				        		Else
					        		nQtdPISCOF += GW8->GW8_PESOC
				        		EndIf
					    	EndIf

						   	If GW8->GW8_PESOR > GW8->GW8_PESOC
					    		nQtdTotal += GW8->GW8_PESOR
				    		Else
					    		nQtdTotal += GW8->GW8_PESOC
				    		EndIf

			    		ElseIf cParamRat == '2' //Valor

			    			If GW8->GW8_TRIBP== '1'
					    		nQtdPISCOF += GW8->GW8_VALOR
					    	EndIf

				    		nQtdTotal += GW8->GW8_VALOR

				    	ElseIf cParamRat == '4' //Quantidade

			    			If GW8->GW8_TRIBP== '1'
					    		nQtdPISCOF += GW8->GW8_QTDE
					    	EndIf

				    		nQtdTotal += GW8->GW8_QTDE

			    		ElseIf cParamRat == '3' //Volume

			    			If GW8->GW8_TRIBP== '1'
					    		nQtdPISCOF += GW8->GW8_VOLUME
					    	EndIf

				    		nQtdTotal += GW8->GW8_VOLUME

				    	EndIf
				    	dbSelectArea("GW8")
						DbSkip()
				    EndDo

				EndIf
			Next nCont
 
			If s_ICMBAPI == '3'
				aRetCalc[nPos][23] :=  (aRetCalc[nPos][23] - aRetCalc[nPos][18])
			EndIf 

			nVlBasePIS := aRetCalc[nPos][23]
			nVlBaseCO  := aRetCalc[nPos][23]

			nVlPIS := GFETratDec((nVlBasePIS * (GetNewPar('MV_PCPIS' , 0) / 100)),0,.T.)
			nVlCOFINS	:= GFETratDec((nVlBaseCO  * (GetNewPar('MV_PCCOFI', 0) / 100)),0,.T.)

			If !lTrechoPC .Or. (nVlBasePIS == 0 .And. nVlBaseCO == 0)
				oModelGWF:LoadValue("GWF_CRDPC", "2")
			Else
				oModelGWF:SetValue("GWF_BAPICO", nVlBaseCO)
				oModelGWF:SetValue("GWF_VLCOFI" , nVlCOFINS)
				oModelGWF:SetValue("GWF_VLPIS" , nVLPIS)
			EndIf
		Else

			oModelGWF:SetValue("GWF_ADICIS", "2")

		EndIf

		//Exibe os valores em tela
		aCalcResult := {}
 		cCriterio := oModelGWF:GetValue("GWF_CRIRAT")
		If Empty(cCriterio) .Or. !(cCriterio $ '1234')
			cCriterio := '1'
		EndIf

		For nCount := 1 To oModelGWI:Length()

			oModelGWI:GoLine(nCount)

			If !oModelGWI:IsDeleted() 

				If oModelGWI:GetValue("GWI_BASICM") == "1" .And. aRetCalc[nPos][1] == "1" .And. !lAuton .And. !(aRetCalc[nPos][21] == "5" .And. FwFldGet("GWF_ADICIS") == "2")
					oModelGWI:SetValue("GWI_VLLIQ", ((oModelGWI:GetValue("GWI_VLFRET") / aRetCalc[nPos][22]) * aRetCalc[nPos][15]))
				Else
					oModelGWI:SetValue("GWI_VLLIQ", oModelGWI:GetValue("GWI_VLFRET"))
				EndIf
			EndIf
		Next nCount

		For nX := 1 To oModelGWH:Length()
			If !oModelGWH:IsDeleted(nX)
				aDoc := { oModelGWH:GetValue("GWH_FILIAL",nX),;
						  oModelGWH:GetValue("GWH_CDTPDC",nX),;
						  oModelGWH:GetValue("GWH_EMISDC",nX),;
						  oModelGWH:GetValue("GWH_SERDC" ,nX),;
						  oModelGWH:GetValue("GWH_NRDC"  ,nX)}

				aRet := GetDatCrit(aClone(aDoc),cCriterio)
				aAdd(aDoc,aRet[1])
				aAdd(aDoc,aRet[2])
				aAdd(aDocs,aClone(aDoc))
				aSomaCrit[1] += aRet[1]
				aSomaCrit[2] += aRet[2]
			EndIf
		Next nX
		
		If aSomaCrit[2] > aSomaCrit[1]
			nTotalCrit := aSomaCrit[2]
			lPesoCub := .T.
		Else
			nTotalCrit := aSomaCrit[1]
			lPesoCub := .F.
		EndIf
		
		If oModelGWF:GetValue("GWF_QTDCAL") == '2' .And. oModelGWF:GetValue("GWF_IDFRVI") == '1' .And. nDcValid > 1
			aEntregas := GF50AGRENT(aDocs,oModelGWF:GetValue("GWF_TRANSP"),AllTrim(oModelGWF:GetValue("GWF_SEQTRE")))
		Else
			aEntregas := { {  } }
			For nX := 1 To Len(aDocs)
				aLinha := Array(14)
				aLinha[1]  := aDocs[nX,1]
				aLinha[2]  := aDocs[nX,2]
				aLinha[3]  := aDocs[nX,3]
				aLinha[4]  := aDocs[nX,4]
				aLinha[5]  := aDocs[nX,5]
				aLinha[8]  := oModelGWF:GetValue('GWF_EMIREM')
				aLinha[9]  := oModelGWF:GetValue('GWF_EMIDES')
				aLinha[13] := oModelGWF:GetValue('GWF_CIDORI')
				aLinha[14] := oModelGWF:GetValue('GWF_CIDDES')
				
				aAdd(aEntregas[1],aClone(aLinha))
			Next nX
		EndIf
		
		For nX := 1 To Len(aEntregas)
			aAdd(aCalcxCrit,0)
			For nY := 1 To Len(aEntregas[nX])
				nZ := aScan(aDocs,{|x|x[1] == aEntregas[nX][nY][1] .And.;
									  x[2] == aEntregas[nX][nY][2] .And.;
									  x[3] == aEntregas[nX][nY][3] .And.;
									  x[4] == aEntregas[nX][nY][4] .And.;
									  x[5] == aEntregas[nX][nY][5]})
				If nTotalCrit != 0
					If lPesoCub					  
						aCalcxCrit[nX] += aDocs[nZ][7]
					Else
						aCalcxCrit[nX] += aDocs[nZ][6]
					EndIf
				Else
					aCalcxCrit[nX] += 1
				EndIf
			Next nY
		Next nX
		
		If nTotalCrit == 0
			nTotalCrit := nDcValid
		EndIf
		cNrCalcGWF := "00000000"
		For nX := 1 To oModelGWH:Length()
			nDocs++
			oModelGWH:GoLine(nX)
			If !oModelGWH:IsDeleted()
				nPos := IIf(oModelGWF:GetValue("GWF_QTDCAL") == '1',1,aScan( aRetCalc, { |x| x[25] == nX }))
				For nY := 1 To Len(aEntregas)
					If aScan(aEntregas[nY],{|x| x[1] == oModelGWH:GetValue("GWH_FILIAL") .And. ;
												x[2] == oModelGWH:GetValue("GWH_CDTPDC") .And. ;
												x[3] == oModelGWH:GetValue("GWH_EMISDC") .And. ;
												x[4] == oModelGWH:GetValue("GWH_SERDC" ) .And. ;
												x[5] == oModelGWH:GetValue("GWH_NRDC"  )}) != 0

						If Len(aCalcXEntr) < nY
							nComps := 0
							
							If Empty(aCalcXEntr)
								
								aAdd(aCalcXEntr, cNrCalcGWF)
								
								aGWFCopy :=  GFECPMDDAT( oModelGWF )
								
								For nZ := 1 To oModelGWI:Length()
									oModelGWI:GoLine(nZ)
									If !oModelGWI:IsDeleted()
										aAdd(aGWICopy,GFECPMDDAT(oModelGWI ))
									EndIf
								Next nZ
							Else
								cNrCalcGWF := Soma1(cNrCalcGWF)
								aAdd(aCalcXEntr, cNrCalcGWF)
							EndIf
							
							aGWFClone := aClone(aGWFCopy)
							aGWIClone := aClone(aGWICopy)
							GFEALTDAT(aGWFClone,{ {'GWF_FILIAL', xFilial('GWF')},;
												  {'GWF_EMIREM', aEntregas[nY][1][8]},;
												  {'GWF_EMIDES', aEntregas[nY][1][9]},;
												  {'GWF_CIDORI', aEntregas[nY][1][13]},;
												  {'GWF_CIDDES', aEntregas[nY][1][14]},;
												  {'GWF_PCICMS', aRetCalc[nPos][2]},;
												  {'GWF_PCISS' , aRetCalc[nPos][3]},;
												  {'GWF_BAPICO', NoRound(GFEGETDAT(aGWFClone,"GWF_BAPICO") * ( aCalcxCrit[nY] / nTotalCrit ) , 2)},;
												  {'GWF_VLCOFI', NoRound(GFEGETDAT(aGWFClone,"GWF_VLCOFI") * ( aCalcxCrit[nY] / nTotalCrit ) , 2)},;
												  {'GWF_VLPIS' , NoRound(GFEGETDAT(aGWFClone,"GWF_VLPIS" ) * ( aCalcxCrit[nY] / nTotalCrit ) , 2)},;
												  {'GWF_BASISS', NoRound(aRetCalc[nPos][20] * ( aCalcxCrit[nY] / nTotalCrit ) , 2)},;
												  {'GWF_BASICM', NoRound(aRetCalc[nPos][19] * ( aCalcxCrit[nY] / nTotalCrit ) , 2)},;
												  {'GWF_VLISS' , NoRound(aRetCalc[nPos][17] * ( aCalcxCrit[nY] / nTotalCrit ) , 2)},;
												  {'GWF_VLICMS', NoRound(aRetCalc[nPos][18] * ( aCalcxCrit[nY] / nTotalCrit ) , 2)},;
												  {'GWF_IMPOST', aRetCalc[nPos][1]};
												})
								// Bloco de calculo para definição dos valores dos campos GWI_VLFRET e GWI_VLLIQ 
								For nZ := 1 To Len(aGWIClone) 
									nComps++

									//doc carga igual a 1	
									If Len(aDocs) == 1
										Do Case
											// Um ou mais componentes - Sem Impostos
											Case oModelGWF:GetValue("GWF_ADICIS") == "2"
												oModelGWI:GoLine(nCount)
												If !oModelGWI:IsDeleted() 
													nValComp:= 	oModelGWI:GetValue("GWI_VLFRET", nZ)
													nValLiq := nValComp
												EndIf	

											// Um ou mais componentes - Com Imposto
											Case oModelGWF:GetValue("GWF_ADICIS") == "1"
												nValLiq := oModelGWI:GetValue("GWI_VLFRET", nZ)

											If oModelGWI:GetValue("GWI_BASICM", nZ) == "1"	
												nValComp:= oModelGWI:GetValue("GWI_VLFRET", nZ) / (1-aRetCalc[1][2]/100)
											Else
												nValComp := nValLiq
											EndIf	
										EndCase
									EndIf 

									// Mais de um doc carga E um por romaneio
									If Len(aDocs) > 1 .And. oModelGWF:GetValue("GWF_QTDCAL") == '1'
										Do Case
											// Um componente - Sem Imposto
											Case Len(aGWIClone) == 1 .And. oModelGWF:GetValue("GWF_ADICIS") == "2"
												nValComp:= 	oModelGWI:GetValue("GWI_VLFRET", nZ)
												nValLiq := nValComp

											// Mais de um componente - Sem Imposto	
											Case Len(aGWIClone) > 1 .And. oModelGWF:GetValue("GWF_ADICIS") == "2"
												nValComp := oModelGWI:GetValue("GWI_VLFRET", nZ)  * ( aCalcxCrit[nY] / nTotalCrit)
												nValLiq := nValComp

											// 1 componente - Com Imposto
											Case Len(aGWIClone) == 1 .And. oModelGWF:GetValue("GWF_ADICIS") == "1"

												nValLiq := oModelGWI:GetValue("GWI_VLFRET", nZ)

												If oModelGWI:GetValue("GWI_BASICM", nZ) == "1"
													nValComp := oModelGWI:GetValue("GWI_VLFRET", nZ) / (1-aRetCalc[1][2]/100)
												Else
													nValComp := nValLiq
												EndIf	
												

											// Mais de um componente - Com Imposto
											Case Len(aGWIClone) > 1 .And. oModelGWF:GetValue("GWF_ADICIS") == "1"

												nValLiq:= oModelGWI:GetValue("GWI_VLFRET", nZ) * ( aCalcxCrit[nY] / nTotalCrit)

												If oModelGWI:GetValue("GWI_BASICM", nZ) == "1"
													nValComp:= oModelGWI:GetValue("GWI_VLFRET", nZ) * ( aCalcxCrit[nY] / nTotalCrit) / (1-aRetCalc[1][2]/100)
												Else
													nValComp := nValLiq
												EndIf
												
										EndCase
									EndIf

									// Mais de um doc carga E um por entrega
									If Len(aDocs) > 1 .And. oModelGWF:GetValue("GWF_QTDCAL") == '2'
										DO Case
											// 1 componente - Sem Imposto
											Case Len(aGWIClone) == 1 .And. oModelGWF:GetValue("GWF_ADICIS") == "2"
												nValComp:= 	oModelGWI:GetValue("GWI_VLFRET", nZ) * ( aCalcxCrit[nY] / nTotalCrit )
												nValLiq := nValComp

											// Mais de um componente - Sem Imposto	
											Case Len(aGWIClone) > 1 .And. oModelGWF:GetValue("GWF_ADICIS") == "2"
												nValComp := oModelGWI:GetValue("GWI_VLFRET", nZ) * ( aCalcxCrit[nY] / nTotalCrit)
												nValLiq := nValComp

											// 1 componente - Com Imposto
											Case Len(aGWIClone) == 1 .And. oModelGWF:GetValue("GWF_ADICIS") == "1"

												nValLiq := aRetCalc[nPos][15] * ( aCalcxCrit[nY] / nTotalCrit )

												If oModelGWI:GetValue("GWI_BASICM", nZ) == "1"
													nValComp := aRetCalc[nPos][16] * ( aCalcxCrit[nY] / nTotalCrit )
												Else
													nValComp := nValLiq
												EndIf
												

											// Mais de um componente - Com Imposto
											Case Len(aGWIClone) > 1 .And. oModelGWF:GetValue("GWF_ADICIS") == "1"

												nValLiq := oModelGWI:GetValue("GWI_VLFRET", nZ) * ( aCalcxCrit[nY] / nTotalCrit )

												If oModelGWI:GetValue("GWI_BASICM", nZ) == "1"
													nValComp := (oModelGWI:GetValue("GWI_VLFRET", nZ) * ( aCalcxCrit[nY] / nTotalCrit )) / (1-aRetCalc[1][2]/100)
												Else
													nValComp := nValLiq
												EndIf
										EndCase
									EndIf
										
									nTotValComp += noRound(nValComp,8)
									nTotValLiq += noRound(nValLiq,8)

									// Arredondamento dos valores - adiciona diferença no ultimo componente se necessario.
									If oModelGWF:GetValue("GWF_ADICIS") == "1" .And. Len(aDocs) == nDocs .And. Len(aGWIClone) == nComps

										nValComp := nValComp + ((aRetCalc[nPos][15] / (1-aRetCalc[1][2]/100))- nTotValComp)
										nValLiq := nValLiq + (aRetCalc[nPos][15] - nTotValLiq)

									ElseIf oModelGWF:GetValue("GWF_ADICIS") == "2" .And. Len(aDocs) == nDocs .And. Len(aGWIClone) == nComps

										If aRetCalc[nPos][15] <> nTotValComp
											nValComp += 0.01
											nValLiq += 0.01
										EndIf

									EndIf

									GFEALTDAT(aGWIClone[nZ],{{'GWI_FILIAL', xFilial('GWI')},;
																{"GWI_VLFRET",nValComp}})
									GFEALTDAT(aGWIClone[nZ],{{'GWI_FILIAL', xFilial('GWI')},;
																{"GWI_VLLIQ",nValLiq}})
									
								Next nZ
							
							aAdd(aCalcResult,{aClone(aGWFClone), aClone(aGWIClone) , {} })
						EndIf

						aGWHClone := GFECPMDDAT(oModelGWH )
						GFEALTDAT(aGWHClone, {{'GWH_FILIAL', aTail(aGWHClone[1])}})
						aAdd(aCalcResult[nY,3],aClone(aGWHClone))
						
						Exit // Um documento não estará em duas entregas.
					EndIf
				Next nY
			EndIf
		Next nX
		
		For nX := 1 To Len(aCalcxCrit)
			aAdd(aCalcxComb, NoRound( aRetCalc[nPos][15] * ( aCalcxCrit[nX] / nTotalCrit ) , 2) )
			
		Next nX
		
		If !lCalcCot .And. !GFEA084LD(aCalcxComb)
			For nX := 1 To Len(aCalcxCrit) - 1
				ROLLBACKSXE()
			Next nX
			Help( ,, 'HELP',, STR0046, 1, 0) //"Formulário não foi salvo."
			Return .F.
		EndIf
			

		For nCount := 1 To Len(aDelCalc)

			GFEDelCalc(aDelCalc[nCount],,.T.)

		Next nCount
	ElseIf nOp == MODEL_OPERATION_DELETE
		oRetValid 	:= GFEXFBB():New()
		cDelNrRom 	:= oModelGWF:GetValue("GWF_NRROM")
		cOrigem   	:= oModelGWF:GetValue("GWF_ORIGEM")
		cCalc 	   	:= oModelGWF:GetValue("GWF_NRCALC")
		cDelTpCalc 	:= oModelGWF:GetValue("GWF_TPCALC")
		cAliasGWF  	:= GetNextAlias()

		If Empty(cDelNrRom)	// Se variavel vazia pode ser um agrupamento de calculo portanto precisamos buscar todos romaneios relacionados a esse calculo
			
			If GFXCP1212210('GW1_FILROM')
				cJoin := "GWN_FILIAL = GW1_FILROM"
			Else
				cJoin := "GWN_FILIAL = GW1_FILIAL"
			EndIf
			cJoin := "%" + cJoin + "%"
		
			cAliasGWN := GetNextAlias()
			BeginSql Alias cAliasGWN
				SELECT GWN.R_E_C_N_O_ AS RECNOGWN
					FROM %Table:GWH% GWH
					INNER JOIN %Table:GW1% GW1
					ON GW1_FILIAL = GWH_FILIAL
					AND GW1_CDTPDC = GWH_CDTPDC
					AND GW1_EMISDC = GWH_EMISDC
					AND GW1_SERDC = GWH_SERDC
					AND GW1_NRDC = GWH_NRDC
					AND GW1.%NotDel%
					LEFT JOIN %Table:GWN% GWN
					ON %Exp:cJoin% 
					AND GWN_NRROM = GW1_NRROM
					AND GWN.%NotDel%
				WHERE GWH.GWH_FILIAL = %xFilial:GWH%
				AND GWH.GWH_NRCALC = %Exp:cCalc%
				AND GWH.%NotDel%
			EndSql
			While (cAliasGWN)->(!Eof())
				aadd(aAuxCalc, (cAliasGWN)->RECNOGWN)

				(cAliasGWN)->(DbSkip())
			EndDo
			(cAliasGWN)->(dbCloseArea())
		EndIf

		If !GFEVldLotProvisao(cCalc)
            GFEHelp("Cálculo já relacionado à Lote de Provisão.","Realize a exclusão do Lote de Provisão.","Help")
            oRetValid:Destroy() 
            Return .F.
        EndIf
		
		cQuery := "SELECT GWF_FILIAL, GWF_NRCALC, GWF_ORIGEM, GWF_NRROM"
		cQuery +=  " FROM " + RetSqlName("GWF") 
		cQuery +=  " WHERE GWF_NRROM = '"+ cDelNrRom  +"'"
		cQuery +=  " AND GWF_FILIAL = '" + xFilial("GWF") + "'"
		cQuery +=  " AND D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),cAliasGWF, .F., .T.)

		(cAliasGWF)->( dbGoTop() )
		While !(cAliasGWF)->(Eof())
			oRetValid:setNrCalc((cAliasGWF)->GWF_NRCALC)
			oRetValid:setOrigem((cAliasGWF)->GWF_ORIGEM)
			oRetValid:setVldOrigem(.F.)
			If oRetValid:getOrigem() != "4"
				oRetValid:Validar()
				If !oRetValid:getStatus() .OR. cOrigem == "4" .Or. oRetValid:getOrigem() != "2"
					aCalcDel := ARRAY(0)
					EXIT
				EndIf
				aAdd(aCalcDel,oRetValid:getNrCalc())
			EndIf
			(cAliasGWF)->( dbSkip() )
		EndDo
		(cAliasGWF)->(dbCloseArea() )

		If LEN(aCalcDel) > 1 .AND. msgyesno("Deseja desfazer os demais cálculos combinados pertencentes ao mesmo romaneio deste cálculo?")
			lExcTodos := .T.
			GFEDelCalc(,,.T.,aCalcDel)
			oRetValid:Destroy()
			aCalcDel := ARRAY(0)
		Else
			oRetValid:ClearData()
			oRetValid:setNrCalc(cCalc)
			oRetValid:setVldOrigem(.F.)
			oRetValid:Validar()
			If !oRetValid:getStatus()
				Help( ,, 'HELP',,oRetValid:getMensagem(), 1, 0)
				oRetValid:Destroy()
				Return	.F.
			EndIf
			If !IsBlind() .And. cOrigem == "4" .And. !MsgYesNo("Este cálculo foi simulado pelo ERP. Deseja realmente excluí-lo?")
				Help( ,, 'HELP',,"Cancelado pelo usuário.", 1, 0)
				oRetValid:Destroy() 
				Return .F.
			EndIf 	
			GFEDelCalc(oRetValid:getNrCalc(),,.T.)
			oRetValid:Destroy()
		EndIf
		
		If cDelTpCalc != "2" .And. cDelTpCalc != "3"
			// Verificação de Nr do Romaneio, se variavel vazia pq é um agrupamento de romaneios com isso temos que buscar o numero do romaneio que não tem na GWF
			If Empty(cDelNrRom) .And. Len(aAuxCalc) > 0
				For nCount := 1 To Len(aAuxCalc)
					GWN->(DbGoto(aAuxCalc[nCount]))
					RecLock("GWN", .F.)
						GWN->GWN_CALC   := "4"
						GWN->GWN_MTCALC := ""
						GWN->GWN_DTCALC := CToD("  /  /    ")
						GWN->GWN_HRCALC := ""
						If GWN->GWN_AGRUP == "1"
							GWN->GWN_AGRUP := "2"
						EndIf
					MsUnLock("GWN")
				Next
			Else
				GWN->( dbSetOrder(1) )
				If GWN->( dbSeek(xFilial("GWN") + cDelNrRom))
					RecLock("GWN", .F.)
						GWN->GWN_CALC   := "4"
						GWN->GWN_MTCALC := ""
						GWN->GWN_DTCALC := CToD("  /  /    ")
						GWN->GWN_HRCALC := ""
						If GWN->GWN_AGRUP == "1"
							GWN->GWN_AGRUP := "2"
						EndIf
					MsUnLock("GWN")
				EndIf
			EndIf
		EndIf
		If lExcTodos
			GW1->(dbSetOrder(1))			
			oModelGWH:GoLine(nLineGWH)
			For nCount := 1 To oModelGWH:Length()
				oModelGWH:GoLine(nCount)
				If !oModelGWH:IsDeleted()
					If GW1->( dbSeek(oModelGWH:GetValue("GWH_FILIAL", nCount) + ; 
									 oModelGWH:GetValue("GWH_CDTPDC", nCount) + ;
									 oModelGWH:GetValue("GWH_EMISDC", nCount) + ;
									 oModelGWH:GetValue("GWH_SERDC", nCount) + ;
									 oModelGWH:GetValue("GWH_NRDC", nCount) ) )

						While !GW1->(Eof()) .And. (GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC ==;
													oModelGWH:GetValue("GWH_FILIAL", nCount) + oModelGWH:GetValue("GWH_CDTPDC", nCount) + oModelGWH:GetValue("GWH_EMISDC", nCount) + oModelGWH:GetValue("GWH_SERDC", nCount) + oModelGWH:GetValue("GWH_NRDC", nCount))
							GWU->(dbSetOrder(1))
							If GWU->(dbSeek(oModelGWH:GetValue("GWH_FILIAL", nCount) + ; 
											oModelGWH:GetValue("GWH_CDTPDC", nCount) + ;
											oModelGWH:GetValue("GWH_EMISDC", nCount) + ;
											oModelGWH:GetValue("GWH_SERDC", nCount) + ;
											oModelGWH:GetValue("GWH_NRDC", nCount) ) )
							
								While !GWU->(Eof()) .And. (GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC ==;
															oModelGWH:GetValue("GWH_FILIAL", nCount) + oModelGWH:GetValue("GWH_CDTPDC", nCount) + oModelGWH:GetValue("GWH_EMISDC", nCount) + oModelGWH:GetValue("GWH_SERDC", nCount) + oModelGWH:GetValue("GWH_NRDC", nCount))
									RecLock("GWU",.F.)
										GWU->GWU_DTPENT := CToD("  /  /    ")
										GWU->GWU_HRPENT	:= ""
									GWU->(MsUnLock())
								GWU->(dbSkip())	
								EndDo
							EndIf
						GW1->(dbSkip())	
						EndDo	
					EndIf
				EndIf
			Next nCount 	
		Else
			GWU->(dbSetOrder(1))
			oModelGWH:GoLine(nLineGWH)
			For nCount := 1 To oModelGWH:Length()
				oModelGWH:GoLine(nCount)
				If !oModelGWH:IsDeleted()
					If GWU->(dbSeek(oModelGWH:GetValue("GWH_FILIAL", nCount) + ; 
									oModelGWH:GetValue("GWH_CDTPDC", nCount) + ;
									oModelGWH:GetValue("GWH_EMISDC", nCount) + ;
									oModelGWH:GetValue("GWH_SERDC", nCount) + ;
									oModelGWH:GetValue("GWH_NRDC", nCount) + ;
									oModelGWH:GetValue("GWH_TRECHO", nCount)) )
						RecLock("GWU",.F.)
							GWU->GWU_DTPENT := CToD("  /  /    ")
							GWU->GWU_HRPENT	:= ""
						GWU->(MsUnLock())
					EndIf
				EndIf
			Next nCount	
		EndIf
	EndIf

	If nOp == MODEL_OPERATION_INSERT
		GWU->(dbSetOrder(1))
		oModelGWH:GoLine(nLineGWH)
		For nCount := 1 To oModelGWH:Length()
			oModelGWH:GoLine(nCount)
			If !oModelGWH:IsDeleted()
				If GWU->(dbSeek(oModelGWH:GetValue("GWH_FILIAL", nCount) + ; 
								oModelGWH:GetValue("GWH_CDTPDC", nCount) + ;
								oModelGWH:GetValue("GWH_EMISDC", nCount) + ;
							 	oModelGWH:GetValue("GWH_SERDC", nCount) + ;
							 	oModelGWH:GetValue("GWH_NRDC", nCount)   + ;
								oModelGWH:GetValue("GWH_TRECHO")) )
					RecLock("GWU",.F.)
						GWU->GWU_DTPENT := oModelGWF:GetValue("GWF_DTPREN")
						GWU->GWU_HRPENT	:= oModelGWF:GetValue("GWF_HRPREN")

						// Grava o valor fixo de quant de prazo igual a 0 e o tipo igual a 3-Informado.
						If GFXCP12137('GWU_QTPRAZ') .And. GFXCP12137('GWU_TPPRAZ')
							GWU->GWU_QTPRAZ := 0
							GWU->GWU_TPPRAZ := "3" 
						EndIf

						If GFXCP12137('GWU_DTPENO') .And. GFXCP12137('GWU_HRPENO') .And. Empty(GWU->GWU_DTPENO)
							GWU->GWU_DTPENO := oModelGWF:GetValue("GWF_DTPREN")
							GWU->GWU_HRPENO := oModelGWF:GetValue("GWF_HRPREN")
						EndIf
					GWU->(MsUnLock())
				EndIf
			EndIf
		Next nCount
	EndIf

	IF SuperGetMV('MV_INTFRE',.F.,'1') == '2'

		GW1->(dbSetOrder(1))
		oModelGWH:GoLine(nLineGWH)
		For nCount := 1 To oModelGWH:Length()
	
			oModelGWH:GoLine(nCount)
	
			If !oModelGWH:IsDeleted()
				If GW1->(dbSeek(oModelGWH:GetValue("GWH_FILIAL", nCount) + ; 
								oModelGWH:GetValue("GWH_CDTPDC", nCount) + ;
								oModelGWH:GetValue("GWH_EMISDC", nCount) + ;
							 	oModelGWH:GetValue("GWH_SERDC", nCount) + ;
							 	oModelGWH:GetValue("GWH_NRDC", nCount)) )
					
					//GW1->GW1_SITFRE - 1=Nao Enviado;2=Pendente;3=Rejeitado;4=Atualizado;5=Pendente Desatualizacao;6=Nao se Aplica
					//GW1->GW1_ORIGEM - 1=Usuario;2=ERP;3=SIGATMS;9=Outros
					If GW1->GW1_SITFRE != '6' .And. GW1->GW1_ORIGEM == '2'
						RecLock("GW1", .F.)
							GW1->GW1_SITFRE := "2"
							GW1->GW1_MOTFRE := "GFEA084 - Inclusao de Frete Combinado"
							GW1->GW1_DTFRE := Date()
						GW1->(MsUnlock()) 
					EndIf
				EndIf
			EndIf
		Next nCount
	EndIf
Return .T.
//-------------------------------------------------------------------

Function GFEA084ATU(oModel)
//Altera o Romaneio para calculado
//-------------------------------------------------------------------
	Local nOp       := oModel:GetOperation()
	Local oModelGWH := oModel:GetModel("GFEA084_GWH")
	Local nContGWU  := 0
	Local nContGWF	:= 0
	Local cFilGW1	:= ""
	Local cFilGWN	:= ""
	Local cNrRom	:= ""
	
 	If nOp != MODEL_OPERATION_DELETE
		// Realiza a busca de todos os trechos que fazem parte do romaneio
		dbSelectArea("GWH")
		GWH->( dbSetOrder(2) )
		If GWH->( dbSeek(xFilial("GWH") + oModelGWH:GetValue("GWH_CDTPDC") + oModelGWH:GetValue("GWH_EMISDC") + oModelGWH:GetValue("GWH_SERDC") + oModelGWH:GetValue("GWH_NRDC")) )
			dbSelectArea("GW1")
			GW1->( dbSetOrder(1) )
			If GW1->( dbSeek(xFilial("GW1") + oModelGWH:GetValue("GWH_CDTPDC", 1) + oModelGWH:GetValue("GWH_EMISDC", 1) + oModelGWH:GetValue("GWH_SERDC", 1) + oModelGWH:GetValue("GWH_NRDC", 1)) )
				cFilGW1 := GW1->GW1_FILIAL
				cNrRom  := GW1->GW1_NRROM
				If GFXCP1212210('GW1_FILROM') .And. !Empty(GW1->GW1_FILROM)
					cFilGWN := GW1->GW1_FILROM
				EndIf
			EndIf
		EndIf
		
		nContGWU := 0
		nContGWF := 0
		
		GW1->(dbSetOrder(9))
		GW1->(dbSeek(cFilGW1 + cNrRom))
		While !GW1->(Eof()) .And. (GW1->GW1_FILIAL + GW1->GW1_NRROM == cFilGW1 + cNrRom)
			GWU->(dbSetOrder(1))
			GWU->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
			While(!GWU->(Eof()) .And. (GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC ==;
								   		   GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
				
				If GWU->GWU_PAGAR == "1"
					nContGWU++
				EndIf
				
				GWU->(dbSkip())
			EndDo
					
			GWH->(dbSetOrder(2))
			GWH->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
			While(!GWH->(Eof()) .And. (GWH->GWH_FILIAL + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC ==;
										   GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
				nContGWF++
					
				GWH->(dbSkip())
			EndDo
						
			GW1->(dbSkip())
		EndDo
		
		// Verifica se existe cálculos para todos os trechos dos documentos de carga
		If nContGWU == nContGWF 
			If !GFXCP1212210('GW1_FILROM')
				cFilGWN := cFilGW1
			EndIf
			
			dbSelectArea("GWN")
			GWN->( dbSetOrder(1) )
			If GWN->( dbSeek(cFilGWN + cNrRom) )
				// Troca a situação do romaneio para "Calculado com sucesso"              		
				RecLock("GWN", .F.)
					GWN->GWN_CALC   := "1"
					GWN->GWN_MTCALC := ""
					GWN->GWN_DTCALC := dDataBase
					GWN->GWN_HRCALC := Time()
				MsUnLock("GWN")
          	EndIf
       EndIf
    EndIf

Return .T.

//-------------------------------------------------------------------
// Cálculo combinado
Function GFEA084CLC(oModel)
	Local lAuton
	Local lCalcCot    := IsInCallStack("GFEInsGWF")
	Local oModelGWI   := oModel:GetModel("GFEA084_GWI")
	Local oModelGWH   := oModel:GetModel("GFEA084_GWH")
	Local oModelGWF   := oModel:GetModel("GFEA084_GWF")
	Local aRetCalc    := {}
	Local aRetIcm     := {}
	Local aArAuxGWU   := {}
	Local cDecCom     := SuperGetMV("MV_DECCOM",.F.,"1")
	Local cTrecho     := ""
	Local cApuISS     := ""
	Local cCidOri     := ""
	Local cCidDest    := ""
	Local cCidTransp  := GU3->GU3_NRCID
	Local cFilRom     := ""
	Local cNrRom      := ""
	Local nLineGWI    := oModelGWI:GetLine()
	Local nCountGWI   := 0
	Local nI          := 0
	Local nF          := 0
	Local nGWH        := 0
	Local nBaseICMS   := 0
	Local nLineGWH    := 1
	Local nFatRed     := 1
	Local nValDifICMS := 0
	Local cTpOpDoc    := ""

	Local nX		:= 0
	Local aRetCT    := Nil
	Local cCliFor   := Nil
	Local cLoja     := Nil
	Local cQuery    := ""
	Local cTpCliFor := "C"
	Local cTipoNF   := "N"
	Local cAliasSX5 := Nil
	Local cPrdFrete := SuperGetMv("MV_PRITDF",.F.,"")
	Local oCTProcessing := Nil
	
	// Posiciona no primeiro registro não deletado
	oModelGWH:GoLine(nLineGWH)

	nF := oModelGWH:Length()
	Do While nLineGWH <= nF .And. oModelGWH:IsDeleted()
		nLineGWH++
		oModelGWH:GoLine(nLineGWH)
	EndDo
	// Caso seja cálculo por romaneio busca as informações somente para o primeiro registro
	// Caso contrário busca para todos os não deletados
	nF := IIf(oModelGWF:GetValue("GWF_QTDCAL") == '1',nLineGWH,oModelGWH:Length())
	For nI := nLineGWH To nF
		nValDifICMS := 0
		oModelGWH:GoLine(nI)
		If !oModelGWH:IsDeleted()
			// Inicializa variáveis
			nGWH++
			nBaseICMS := 0
			// Inicializa array
			aAdd(aRetCalc,{"",;  //1 Tipo Imposto
							0,;  //2 Percentual ICMS
							0,;  //3 Percentual ISS
							"",; //4 Remetente
							"",; //5 Destinatario
							"",; //6 Cidade Origem
							"",; //7 Cidade Destino
							"",; //8 Redespachante
							"",; //9 Transportador
							"",; //10 Pagador
							"",; //11 Tipo Frete
							"",; //12 Número Romaneio
							"",; //13 Finalidade
							"",; //14 Tipo Cálculo
							0,;  //15 Valor Combinado
							0,;  //16 Valor Total
							0,;  //17 Valor ISS
							0,;  //18 Valor ICMS
							0,;  //19 BASE ICMS
							0,;  //20 BASE ISS
							"",; //21 Tipo de tributação
							0,;  //22 Base total do ICMS
							0,;  //23 Base PIS/COFINS
							"",; //24 Redução ICMS*/
							nI,; //25 Linha GWH
							0,;  //26 BASE IBS
							0,;  //27 Aliq. IBS
							0,;  //28 Valor IBS
							0,;  //29 BASE CBS
							0,;  //30 Aliq. CBS
							0,;  //31 Valor CBS
							""}) // 32 Filial do Romaneio

			cTrecho := oModelGWH:GetValue("GWH_TRECHO")

			//O preenchimento do array de valores será de acordo com o primeiro Documento de Carga não deletado
			dbSelectArea("GW1")
			GW1->( dbSetOrder(1) )
			If GW1->( dbSeek(oModelGWH:GetValue("GWH_FILIAL") + oModelGWH:GetValue("GWH_CDTPDC") + oModelGWH:GetValue("GWH_EMISDC") + ;
							 oModelGWH:GetValue("GWH_SERDC") + oModelGWH:GetValue("GWH_NRDC")) )
				
				If GFXCP1212210('GW1_FILROM')  .And. !Empty(GW1->GW1_FILROM)
					cFilRom := GW1->GW1_FILROM
				Else
					cFilRom := GW1->GW1_FILIAL
				EndIf
				cNrRom  := GW1->GW1_NRROM

				dbSelectArea("GWU")
				GWU->( dbSetOrder(1) )
				If GWU->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + cTrecho) )
					dbSelectArea("GW8")
					GW8->( dbSetOrder(1) )
					If GW8->( dbSeek( GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
						lAuton := (Posicione("GU3", 1, xFilial("GU3") + GWU->GWU_CDTRP, "GU3_AUTON") == "1" )
						//Selecionando a cidade origem e destino e o transportador
						If cTrecho == "01"
							cCidOri := GWU->GWU_NRCIDO
							//Testar campo da GW1 para a 'cidade de entrega'? Não deveria ser no ultimo trecho apenas?
							cCidDest := GWU->GWU_NRCIDD
							//Transportador
							If lCalcCot .And. Empty( GW1->GW1_NRROM)
								aRetCalc[nGWH][9] := Posicione("GWU", 1, xFilial("GWU") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + cTrecho, "GWU_CDTRP")
							Else
								aRetCalc[nGWH][9] := Posicione("GWN", 1, cFilRom + cNrRom, "GWN_CDTRP")
								If Empty(aRetCalc[nGWH][9])
									aRetCalc[nGWH][9] := Posicione("GWU", 1, xFilial("GWU") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + cTrecho, "GWU_CDTRP")
								EndIf
							EndIf
							//Tipo de Cálculo = Normal
							aRetCalc[nGWH][14] := "1"
						Else
							aArAuxGWU := GWU->( GetArea() )
							dbSelectArea("GWU")
							GWU->( dbSetOrder(1) )
							If GWU->( dbSeek(xFilial("GWU") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + StrZero(Val(cTrecho) - 1, 2)) )
								cCidOri := GWU->GWU_NRCIDD
							EndIf
							RestArea(aArAuxGWU)

							cCidDest := GWU->GWU_NRCIDD
							//Transportador
							aRetCalc[nGWH][9] := GWU->GWU_CDTRP
							//Tipo de Cálculo = Redespacho
							aRetCalc[nGWH][14] := "6"
						EndIf

						//Atibrui os valores de Rementente e Destinatário
						aRetCalc[nGWH][4] := GW1->GW1_CDREM
						aRetCalc[nGWH][5] := GW1->GW1_CDDEST

						//Atribui o valor da Cidade de Origem e Destino
						aRetCalc[nGWH][6] := cCidOri
						aRetCalc[nGWH][7] := cCidDest

						//Definindo os valores do ICMS ou ISS
						If cCidOri != cCidDest
							aRetCalc[nGWH][1] := "1"
							cTpOpDoc := GWU->GWU_CDTPOP
							aRetIcm := GFEFnIcms(GWU->GWU_CDTRP, ;  //Código do transportador
												GW1->GW1_CDREM, ;   //Código do remetente
												GW1->GW1_CDDEST, ;	//Código do destinatario
												cCidOri, ;			//Número da cidade de origem
												cCidDest, ;		  	//Número da cidade de destino	
												GW1->GW1_USO, ;	  	//Forma de utilização da mercadoria
												GW8->GW8_TPITEM, ;  //Tipo de item
												GW8->GW8_CDCLFR, ;  //Classificação de frete
												GW1->GW1_ICMSDC, ;  //Mercadoria é tributada de ICMS?
												IIF(!Empty(cTpOpDoc),cTpOpDoc,Posicione("GWN", 1, cFilRom + cNrRom, "GWN_CDTPOP")),; //Tipo de Operação do Agrupador do Documento de Carga
												xFilial("GWF"))     //Filial do cálculo - Usado no parâmetro MV_GFECRIC para as exceções das filiais que não tem direito a crédito

							aRetCalc[nGWH][2]  := aRetIcm[1]
							aRetCalc[nGWH][21] := aRetIcm[2]
							aRetCalc[nGWH][24] := aRetIcm[3]
						Else
							aRetCalc[nGWH][1] := "2"
							If empty(POSICIONE("GU3",1,XFILIAL("GU3")+GWU->GWU_CDTRP,"GU3_PCISS"))
								aRetCalc[nGWH][3] := Posicione("GU7", 1, xFilial("GU7") + cCidOri, "GU7_PCISS") //Busca a aliquota no cadastro de cidades
							else 
								aRetCalc[nGWH][3] := (POSICIONE("GU3",1,XFILIAL("GU3")+GWU->GWU_CDTRP,"GU3_PCISS"))
							endif 
						EndIf

						//Definindo a finalidade do Cálculo
						If Posicione("GU3", 1, xFilial("GU3") + aRetCalc[nGWH][9], "GU3_AUTON") == "1"
							aRetCalc[nGWH][13] := "3"	// Contrato com Autonomo
						Else
							If cCidOri != cCidDest
								aRetCalc[nGWH][13] := "1"	// Conhecimento de Carga (CTRC)
							Else
								aRetCalc[nGWH][13] := "2"	// Nota Fiscal de Servico (NFS)
							EndIf
						EndIf

						//Emitente que pagará o frete
						If (aRetCalc[nGWH][11] := GW1->GW1_TPFRET) $ "12"
							aRetCalc[nGWH][10] := GW1->GW1_CDREM
						Else
							aRetCalc[nGWH][10] := GW1->GW1_CDDEST
						EndIf

						aArAuxGWU := GWU->( GetArea() )

						//Redespachante
						dbSelectArea("GWU")
						GWU->( dbSetOrder(1) )
						If GWU->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + StrZero(Val(cTrecho) + 1, 2)) )
							aRetCalc[nGWH][8] := GWU->GWU_CDTRP
						EndIf
						RestArea(aArAuxGWU)

						//Romaneio do Cálculo
						aRetCalc[nGWH][12] := GW1->GW1_NRROM
						aRetCalc[nGWH][32] := GW1->GW1_FILROM
						//Somar valor total do Frete
						For nCountGWI := 1 To oModelGWI:Length()
							oModelGWI:GoLine(nCountGWI)
							If !oModelGWI:IsDeleted()
								If oModelGWI:GetValue("GWI_BASICM", nCountGWI) == "1"
									nBaseICMS    += FwFldGet("GWI_VLFRET")
									aRetCalc[nGWH][22] += FwFldGet("GWI_VLFRET")
								Else
									nValDifICMS += FwFldGet("GWI_VLFRET")
								EndIf
								If oModelGWI:GetValue("GWI_BASPIS") == "1"
									//Base PIS/COFINS
									aRetCalc[nGWH][23] += FwFldGet("GWI_VLFRET")
								EndIf
								//Valor Combinado
								aRetCalc[nGWH][15] += FwFldGet("GWI_VLFRET")
							EndIf
						Next nCountGWI

						oModelGWI:GoLine(nLineGWI)

						If !lAuton
							//Calcula o fator de Redução de ICMS
							If aRetCalc[nGWH][21] == "5"
								nFatRed := 1 - aRetCalc[nGWH][24]/100
							EndIf
							//Verifica se adiciona ou não ICMS/ISS
							If FwFldGet("GWF_ADICIS") == "1" //Adiciona
								If aRetCalc[nGWH][1] == "1" //ICMS

								// Ratear o valor para calculo da Base de ICMS para cada nota
									
									nBaseICms    := nBaseICms / (1-((aRetCalc[nGWH][2]/100) * nFatRed))
									nBaseICms    := GFETratDec(nBaseICms)
									aRetCalc[nGWH][19] := nBaseICms
									aRetCalc[nGWH][16] := nBaseICms
									aRetCalc[nGWH][23] := nBaseICms


									If cDecCom == "1"
										aRetCalc[nGWH][18] := aRetCalc[nGWH][16] - (aRetCalc[nGWH][15] - nValDifICMS)
									Else
										aRetCalc[nGWH][18] := Round(aRetCalc[nGWH][16] - aRetCalc[nGWH][15], 2)
									EndIf
	
								Else //ISS
									If GU3->GU3_CONISS == "1"
										aRetCalc[nGWH][20] := (nBaseICms / (1-(aRetCalc[nGWH][3]/100)))
										If cDecCom == "1"
											aRetCalc[nGWH][17] := (aRetCalc[nGWH][20] * aRetCalc[nGWH][3]) /100
										Else
											aRetCalc[nGWH][17] := Round((aRetCalc[nGWH][20] * aRetCalc[nGWH][3]) /100, 2)
										EndIf
									Else
										aRetCalc[nGWH][17] := 0
										aRetCalc[nGWH][20] := 0
										aRetCalc[nGWH][3]  := 0
									Endif
									aRetCalc[nGWH][16] := aRetCalc[nGWH][15] + aRetCalc[nGWH][17]
								EndIf

							Else //Não Adiciona
								If aRetCalc[nGWH][1] == "1" //ICMS
									aRetCalc[nGWH][16] := aRetCalc[nGWH][15]
									aRetCalc[nGWH][19] := nBaseICms * nFatRed
									If cDecCom == "1"
										aRetCalc[nGWH][18] := (GFETratDec(nBaseICms) * (aRetCalc[nGWH][2]/100) * nFatRed )
									Else
										aRetCalc[nGWH][18] := Round((GFETratDec(nBaseICms) * (aRetCalc[nGWH][2]/100) * nFatRed ), 2)
									EndIf
								Else //ISS
									If GU3->GU3_CONISS == "1"
										If cDecCom == "1"
											aRetCalc[nGWH][17] := (aRetCalc[nGWH][15] * aRetCalc[nGWH][3]) /100
										Else
											aRetCalc[nGWH][17] := Round((aRetCalc[nGWH][15] * aRetCalc[nGWH][3]) /100, 2)
										EndIf

										aRetCalc[nGWH][20] := aRetCalc[nGWH][15]
									Else
										aRetCalc[nGWH][17] := 0
										aRetCalc[nGWH][20] := 0
										aRetCalc[nGWH][3]  := 0
									EndIf
									aRetCalc[nGWH][16] := aRetCalc[nGWH][15]
								EndIf
							EndIf

							If aRetCalc[nGWH][1] == "2"
								If aRetCalc[nGWH][17] > 0 .And. GU3->GU3_CONISS == "1"
									IF GFXCP1212410("GU3_APISSO") .AND. cCidTransp != cCidOri .AND. cCidTransp != cCidDest
										cApuISS := Posicione("GU3", 1, xFilial("GU3") + aRetCalc[nGWH][9], "GU3_APISSO")
									ELSE
										cApuISS := Posicione("GU3", 1, xFilial("GU3") + aRetCalc[nGWH][9], "GU3_APUISS")
									ENDIF
									If cApuISS == "1" 
										aRetCalc[nGWH][21] := "1"
									ElseIf cApuISS == "2" 
										aRetCalc[nGWH][21] := "3"
									EndIf
								Else
									aRetCalc[nGWH][21] := "2"
								EndIf
							EndIf
						Else
							aRetCalc[nGWH][16] := aRetCalc[nGWH][15]
							aRetCalc[nGWH][21] := "6"
						EndIf

						
						// Trata valores IBS/CBS
						If FindClass("totvs.protheus.backoffice.fiscal.tciclass.TCIProcessing")

							GU3->(dbSetOrder(1))	// GU3_FILIAL+GU3_CDEMIT
							If GU3->(dbSeek(xFilial('GU3') + GW1->GW1_CDDEST))
								cCliFor := GU3->GU3_CDERP
								cLoja   := GU3->GU3_CDCERP

								cTpCliFor := iif(Alltrim(Posicione("GV5", 1, xFilial("GV5") + GW1->GW1_CDTPDC, "GV5_SENTID")) == '2', 'C', 'F')

								cAliasSX5 := GetNextAlias()
								cQuery := "SELECT SX5.X5_CHAVE AS CHAVE"
								cQuery += " FROM " + RetSqlName("SX5") + " SX5"
								cQuery += " WHERE SX5.X5_FILIAL = ?"
								cQuery += " AND SX5.X5_DESCRI = ?"
								cQuery += "	AND SX5.D_E_L_E_T_ = ''"
								cQuery := ChangeQuery(cQuery)
								oQry := FWExecStatement():New(cQuery)

								oQry:SetString(1, xFilial("SX5"))
								oQry:SetString(2, GW1->GW1_CDTPDC)

								cAliasSX5 := oQry:OpenAlias()

								If (cAliasSX5)->(!EoF())
									cTipoNF := Alltrim((cAliasSX5)->CHAVE) // "N","D","B","C","P","I")
								EndIf
								(cAliasSX5)->(dbCloseArea())
							EndIf
						
							If !Empty(GW8->GW8_CFOP)
								// Inicialização do MatXFis e classe TCIProcessing
								MaFisSave()
								MaFisEnd()
								MaFisIni(cCliFor,;	// 1-Codigo Cliente/Fornecedor
										cLoja,;		// 2-Loja do Cliente/Fornecedor
										cTpCliFor,;	// 3-C:Cliente , F:Fornecedor
										cTipoNF,;	// 4-Tipo da NF
										Nil,;		// 5-Tipo do Cliente/Fornecedor
										Nil,;		// 06 - Relacao de Impostos que suportados no arquivo
										,;			// 07
										.F.,;		// 08
										,;			// 09
										,;			// 10
										,;			// 11
										,;			// 12
										,;			// 13
										,;			// 14
										,;			// 15
										,;			// 16
										,;			// 17
										,;			// 18
										,;			// 19
										,;			// 20
										,;			// 21
										,;			// 22
										,;			// 23
										,;			// 24
										,;			// 25
										,;			// 26
										,;			// 27
										,;			// 28
										,;			// 29
										,;			// 30
										,;			// 31
										,;			// 32
										.T.,;		// 33
										,;
										,;
										,.T. )

								//-- Agrega os itens para a funcao fiscal.
								SB1->(MsSeek(FWxFilial("SB1") + cPrdFrete))

								MaFisAdd(SB1->B1_COD,;  		// 1-Codigo do Produto ( Obrigatorio )
										 ,;   					// 2-Codigo do TES ( Opcional )
										 1,;  					// 3-Quantidade ( Obrigatorio )
										 aRetCalc[nGWH][15],;	// 4-Preco Unitario ( Obrigatorio )
										 0,;	 				// 5-Valor do Desconto ( Opcional )
										 "",;	   				// 6-Numero da NF Original ( Devolucao/Benef )
										 "",;					// 7-Serie da NF Original ( Devolucao/Benef )
										 0,;					// 8-RecNo da NF Original no arq SD1/SD2
										 0,;					// 9-Valor do Frete do Item ( Opcional )
										 0,;					// 10-Valor da Despesa do item ( Opcional )
										 0,;					// 11-Valor do Seguro do item ( Opcional )
										 0,;					// 12-Valor do Frete Autonomo ( Opcional )
										 aRetCalc[nGWH][15],;	// 13-Valor da Mercadoria ( Obrigatorio )
										 ,,,,,,;         		// parâmetros opcionais que não serão utilizados por enquanto
										 GW8->GW8_CFOP,;        // 20-CFOP ( Obrigatorio se não passou TES )
										 ,,,,,,,SB1->B1_ORIGEM; // 28-Classificação Fiscal
										)
								
								MaFisAlt("IT_CF", GW8->GW8_CFOP, 1)

								oCTProcessing := GFEConfigTributosProcessing():New()
								oCTProcessing:getDataItemProcessing()
								aRetCT := oCTProcessing:processResponseSearchList()
								If !Empty(aRetCT)
									For nX := 1 To Len(aRetCT)
										If Alltrim(aRetCT[nX][3]) $ '000060;000061' .And. !Empty(aRetCT[nX][1])
											aRetCalc[nGWH][26] += aRetCT[nX][4]  // Base IBS
											aRetCalc[nGWH][27] += aRetCT[nX][5]  // Aliq. IBS
											aRetCalc[nGWH][28] += aRetCT[nX][6]  // Valor IBS

										ElseIf Alltrim(aRetCT[nX][3]) $ '000062' .And. !Empty(aRetCT[nX][1])
											aRetCalc[nGWH][29] += aRetCT[nX][4]  // Base CBS
											aRetCalc[nGWH][30] += aRetCT[nX][5]  // Aliq. CBS
											aRetCalc[nGWH][31] += aRetCT[nX][6]  // Valor CBS
										EndIf
									Next
								EndIf

								MaFisEnd()
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	Next nI
	If Empty(aRetCalc)
		// Inicializa array
		aAdd(aRetCalc,{"",;  // Tipo Imposto
						0,;  // Percentual ICMS
						0,;  // Percentual ISS
						"",; // Remetente
						"",;  // Destinatario
						"",;  // Cidade Origem
						"",;  // Cidade Destino
						"",;  // Redespachante
						"",;  // Transportador
						"",;  // Pagador
						"",;  // Tipo Frete
						"",;  // Número Romaneio
						"",;  // Finalidade
						"",;  // Tipo Cálculo
						0,;   // Valor Combinado
						0,;   // Valor Total
						0,;   // Valor ISS
						0,;   // Valor ICMS
						0,;   // BASE ICMS
						0,;   // BASE ISS
						"",;  // Tipo de tributação
						0,;   // Base total do ICMS
						0,;   //Base PIS/COFINS
						"",;  // Redução ICMS*/
						0;   // Linha GWH
						})
	EndIf
Return aRetCalc

Function GFEA084PSG(oModel)

	Local aAreaGW1 := GW1->( GetArea() )
	Local aAreaGWU := GWU->( GetArea() )
	Local aAreaGWH := GWH->( GetArea() )
	Local aAreaGWF := GWF->( GetArea() )
	Local aAreaGU3 := GU3->( GetArea() )
	Local aAreaGWN := GWN->( GetArea() )
	Local lRet     := .T.
	
	//O primeiro Documento de Carga servirá como base para o preenchimento dos valores do cálculo e validação dos demais DC's
	Local aKeyAgrDC := GFEA084AGR(oModel)
	//Documento de Carga posicionado
	Local cKeyDC    := oModel:GetValue("GWH_FILIAL") + oModel:GetValue("GWH_CDTPDC") + oModel:GetValue("GWH_EMISDC") + ;
				       oModel:GetValue("GWH_SERDC") + oModel:GetValue("GWH_NRDC")
	//Indica que o Documento de Carga posicionado é o primeiro
	Local lMesmoDC  := (cKeyDC == aKeyAgrDC[1])

	//Variáveis com informações do primeiro Documento de Carga
	Local cAgrDCRom
	Local cAgrDCDest
	Local cAgrDCTrp
	Local cFilRom := Nil
	Local cNrRom  := Nil

	Local lCalcCot := IsInCallStack("GFEInsGWF") .OR. IsInCallStack("OMSM011NFS") .OR. IsInCallStack("GFEM011NFS")
	
	Begin Sequence

		dbSelectArea("GWH")
		GWH->( dbSetOrder(2) )
		GWH->( dbSeek(cKeyDC) )
		While !GWH->( Eof() ) .And. cKeyDC == GWH->GWH_FILIAL + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC

			dbSelectArea("GWF")
			GWF->( dbSetOrder(1) )
			If !lCalcCot .And. GWF->( dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC) ) .And. GWF->GWF_ORIGEM $ "2;4" .And. AllTrim(GWF->GWF_SEQTRE) == AllTrim(oModel:GetValue("GWH_TRECHO"))
				Help( ,, 'HELP',, "O Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + " já está vinculado a um cálculo de Frete Combinado.", 1, 0) //""
				lRet := .F.
				Break
			EndIf

			GWH->( dbSkip() )

		EndDo

		//Caso o registro posicionado não seja o primeiro Documento de Carga, pegar informação do primeiro para validar com o posicionado
		If !lMesmoDC

			dbSelectArea("GW1")
			GW1->( dbSetOrder(1) )
			If GW1->( dbSeek(aKeyAgrDC[1]) )

				dbSelectArea("GWU")
				GWU->( dbSetOrder(1) )
				If GWU->( dbSeek(aKeyAgrDC[2]) )

					cAgrDCTrp := GWU->GWU_CDTRP

				EndIf

				cAgrDCRom  := GW1->GW1_NRROM
				cAgrDCDest := GW1->GW1_CDDEST

			EndIf

		EndIf

		dbSelectArea("GW1")
		GW1->( dbSetOrder(1) )
		If GW1->( dbSeek(cKeyDC) )

			If Empty(GW1->GW1_NRROM) .And. !lCalcCot
				Help( ,, 'HELP',, "O Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + " não está vinculado a um Romaneio.", 1, 0) //""
				lRet := .F.
				Break
			EndIf
			
			dbSelectArea('GWN')
			If GWN->(FieldPos('GWN_VIAGEM')) > 0
				If GFXCP1212210('GW1_FILROM')  .And. !Empty(GW1->GW1_FILROM)
					cFilRom := GW1->GW1_FILROM
				Else
					cFilRom := GW1->GW1_FILIAL
				EndIf
				cNrRom := GW1->GW1_NRROM
				GWN->(dbSetOrder(1))
				If GWN->(dbSeek(cFilRom + cNrRom))
					If !Empty(GWN->GWN_VIAGEM)
						Help( ,, 'HELP',, "O Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + " está relacionado ao romaneio " + GW1->GW1_NRROM + " que possui viagem informada.", 1, 0)
						lRet := .F.
						Break
					EndIf
				EndIf
			EndIf

			dbSelectArea("GWU")
			GWU->( dbSetOrder(1) )
			If GWU->( dbSeek(cKeyDC + oModel:GetValue("GWH_TRECHO")) )

				If GWU->GWU_PAGAR != "1" .And. !lCalcCot
					Help( ,, 'HELP',, "Somente Trechos pagos podem fazer parte do Frete Combinado. O Trecho do Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + " não é pago.", 1, 0) //""
					lRet := .F.
					Break
				EndIf

				If !lMesmoDC .And. cAgrDCTrp != GWU->GWU_CDTRP
					Help( ,, 'HELP',, "O Transportador do Trecho do Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + " dever ser igual ao Transportador do Trecho do primeiro Documento de Carga: " + AllTrim(cAgrDCTrp) + " ", 1, 0) //""
					lRet := .F.
					Break
				EndIf

				dbSelectArea("GU3")
				GU3->( dbSetOrder(1) )
				If GU3->( dbSeek(xFilial("GU3") + GWU->GWU_CDTRP) )

					If GU3->GU3_FRCOMB != "1" .And. !lCalcCot 
						Help( ,, 'HELP',, "Transportador do Trecho do Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + " não está parametrizado para realizar Frete Combinado.", 1, 0) //""
						lRet := .F.
						Break
					EndIf

				Else
					If !lCalcCot
						Help( ,, 'HELP',, "Não foi encontrado Emitente correspondente ao Transportador do Trecho informado para o Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + ".", 1, 0) //""
						lRet := .F.
						Break
					EndIf
				EndIf

			Else
				Help( ,, 'HELP',, "Trecho informado para o Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + " não existe.", 1, 0) //""
				lRet := .F.
				Break
			EndIf

			If !lMesmoDC

				If GW1->GW1_NRROM != cAgrDCRom .And. !lCalcCot
					Help( ,, 'HELP',, "O Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + " deve estar relacionado ao mesmo Romaneio que o Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC", 1)) + ".", 1, 0) //""
					lRet := .F.
					Break
				EndIf

				If oModel:GetValue("GWH_TRECHO") != oModel:GetValue("GWH_TRECHO", 1)
					Help( ,, 'HELP',, "O Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + " deve possuir mesma sequência de Trecho do Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC", 1)) + ".", 1, 0) //""
					lRet := .F.
					Break
				EndIf

				If oModel:GetModel():GetModel("GFEA084_GWF"):GetValue("GWF_IDFRVI") != "1" .And. GW1->GW1_CDDEST != cAgrDCDest .And. Posicione("GU3", 1, xFilial("GU3") + cAgrDCTrp, "GU3_AUTON") != "1"
					Help( ,, 'HELP',, "O Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC")) + " deve possuir mesmo Destinatário que o Documento de Carga de número " + AllTrim(oModel:GetValue("GWH_NRDC", 1)) + ".", 1, 0) //""
					lRet := .F.
					Break
				EndIf

			EndIf

		Else
			Help( ,, 'HELP',, "Documento de Carga inexistente.", 1, 0) //""
			lRet := .F.
			Break
		EndIf

	End Sequence

	RestArea(aAreaGWF)
	RestArea(aAreaGWH)
	RestArea(aAreaGU3)
	RestArea(aAreaGWU)
	RestArea(aAreaGW1)
	RestArea(aAreaGWN)
Return lRet

//-------------------------------------------------------------------

Static Function GetDatCrit(aDoc,cCriterio)
	Local aValor    := {0,0}
	Local cAliasGW8 := GetNextAlias()
	Local cCampos   := ""

	Do Case //"1=Peso Mercadoria","2=Valor Mercadoria","3=Volume","4=Quantidade"
		Case cCriterio == "1"
			cCampos += "SUM(GW8_PESOR) PESOREAL, SUM(GW8_PESOC) PESOCUBADO "
		Case cCriterio == "2"
			cCampos += "SUM(GW8_VALOR) CRIT "
		Case cCriterio == "3"
			cCampos += "SUM(GW8_VOLUME) CRIT "
		Case cCriterio == "4"
			cCampos += "SUM(GW8_QTDE) CRIT "
	EndCase
	cCampos := "%"+cCampos+"%"
	
	BeginSql Alias cAliasGW8
		SELECT %Exp:cCampos%
		FROM %Table:GW8% GW8
		WHERE GW8.GW8_FILIAL = %Exp:aDoc[1]%
		AND GW8.GW8_CDTPDC = %Exp:aDoc[2]%
		AND GW8.GW8_EMISDC = %Exp:aDoc[3]%
		AND GW8.GW8_SERDC = %Exp:aDoc[4]%
		AND GW8.GW8_NRDC = %Exp:aDoc[5]%
		AND GW8.%NotDel%
	EndSql
	If(cAliasGW8)->(!Eof())
		If cCriterio == "1"
			aValor := {(cAliasGW8)->PESOREAL,(cAliasGW8)->PESOCUBADO}
		Else
			aValor := {(cAliasGW8)->CRIT,0}
		EndIf
	EndIf
	(cAliasGW8)->(dbCloseArea())
Return aValor

/*/{Protheus.doc} GFEA084CMT

	Função executada no evento Commit do Model

	@author  Equipe GFE
	@example GFEA084CMT(oModel)
	@param   oModel, Objeto, Objeto Model do MVC
	@return  Booleano
	@table   GWF, GWH, GWI
	@version 12.1.25
	@link    http://jiraproducao.totvs.com.br/browse/DLOGGFE-9573?page=com.totvs.jira.plugin.pluginTotvs%3Aissue-zendesk-tab-panel
	@link    http://jiraproducao.totvs.com.br/browse/DLOGGFE-7357
	@history 28/06/2019, andre.alvarez, Feito um revert da Issue DLOGGFE-7357, Motivo: gerando chave duplicada. Solução: criado um novo ponto de entrada específico para esse caso.
/*/
Function GFEA084CMT(oModel)
	Local lGFEA0841  := ExistBlock("GFEA0841")
	Local aFields    := {}
	Local aGWF       := {}
	Local aGWH       := {}
	Local aGWI       := {}
	Local aLinha     := {}
	Local oModelTmp  := Nil // Model auxiliar para realizar o Commit, disparar o evento MODELCOMMITNTTS e executar o ponto de entrada do cliente (caso exista)
	Local _oModelGWF := Nil
	Local oModelGWI  := Nil
	Local oModelGWH  := Nil
	Local oModelGWG  := Nil
	Local _oModelGWG := Nil
	Local oStructGWF := FWFormStruct(1, "GWF")
	Local oStructGWI := FWFormStruct(1, "GWI")
	Local oStructGWH := FWFormStruct(1, "GWH")
	Local oStructGWG := FWFormStruct(1, "GWG")
	Local nOp        := oModel:GetOperation()
	Local nX         := 0
	Local nY         := 0
	Local nZ         := 0

	If nOp != MODEL_OPERATION_DELETE
		
		If !Empty(aCalcResult)
			For nX := 1 To Len(aCalcResult)
				aGWF := aCalcResult[nX,1]
				aGWI := aCalcResult[nX,2]
				aGWH := aCalcResult[nX,3]

				oModelTmp := MPFormModel():New("GFEA084", /*bPre*/, /* bPost*/, /*bCommit*/, /*bCancel*/)
				oModelTmp:AddFields("GFEA084_GWF", Nil, oStructGWF, /*bPre*/, /*bPost*/, /*bLoad*/)
				
				oModelTmp:AddGrid("GFEA084_GWI", "GFEA084_GWF", oStructGWI, /*bLinePre*/,, /*bPre*/, /*bPost*/, /*bLoad*/)
				oModelTmp:SetRelation("GFEA084_GWI", {{"GWI_FILIAL","xFilial('GWI')"},{"GWI_NRCALC","GWF_NRCALC"}},"GWI_FILIAL+GWI_NRCALC")

				oModelTmp:AddGrid("GFEA084_GWH", "GFEA084_GWF", oStructGWH, /*bLinePre*/,, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
				oModelTmp:GetModel("GFEA084_GWH"):SetMaxLine(9999)
				oModelTmp:SetRelation("GFEA084_GWH", {{"GWH_FILIAL","xFilial('GWH')"},{"GWH_NRCALC","GWF_NRCALC"}},"GWH_FILIAL+GWH_NRCALC")	

				oModelTmp:AddGrid("GFEA084_GWG", "GFEA084_GWF", oStructGWG, /*bLinePre*/, , /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
				oModelTmp:SetRelation("GFEA084_GWG", {{"GWG_FILIAL","xFilial('GWG')"},{"GWG_NRCALC","GWF_NRCALC"}}, "GWG_FILIAL+GWG_NRCALC" )

				oModelTmp:SetOperation(nOp)
				oModelTmp:Activate()

				_oModelGWF := oModelTmp:GetModel("GFEA084_GWF")
				oModelGWI := oModelTmp:GetModel("GFEA084_GWI")
				oModelGWH := oModelTmp:GetModel("GFEA084_GWH")
				oModelGWG := oModel:GetModel("GFEA084_GWG")
				_oModelGWG := oModelTmp:GetModel("GFEA084_GWG")

				For nY := 1 To Len(aGWF)
					// Grava os campos da GWF exceto o número do calculo que está reservado pelo model
					If !(aGWF[nY,1] == "GWF_NRCALC")
						_oModelGWF:LoadValue( aGWF[nY,1], aGWF[nY,2] )
					EndIf
				Next nY
				
				For nY := 1 To Len(aGWI)
					aLinha := aGWI[nY]
					
					If nY > oModelGWI:Length()
						oModelGWI:AddLine()
					EndIf

					For nZ := 1 To Len(aLinha)
						oModelGWI:LoadValue( aLinha[nZ,1], aLinha[nZ,2] )
					Next nZ
				Next nY
				
				For nY := 1 To Len(aGWH)
					aLinha := aGWH[nY]

					If nY > oModelGWH:Length()
						oModelGWH:AddLine()
					EndIf

					For nZ := 1 To Len(aLinha)
						oModelGWH:LoadValue( aLinha[nZ,1], aLinha[nZ,2] )
					Next nZ
				Next nY

				If !Empty(oModelGWG:getValue('GWG_NRTAB'))
					For nY := 1 To oModelGWG:Length()
						oModelGWG:GoLine(nY)
						aFields := oModelGWG:GetStruct():GetFields()
						
						If nY > _oModelGWG:Length()
							_oModelGWG:AddLine()
						EndIf
							
						For nX := 1 To Len( aFields )
							_oModelGWG:LoadValue( aFields[nX][3], oModelGWG:getValue(aFields[nX][3]) )
						Next nX	
					Next nY
				EndIf
				
				FWFormCommit(oModelTmp)
				GFERatCal(.F., _oModelGWF:GetValue("GWF_NRCALC"))
				
				// Ponto de entrada substituto do MVC, no evento MODELCOMMITNTTS. Informações enviadas:
				// - Cálculo de Frete (GWF)
				// - Componente do Cálculo de Frete (GWI)
				// - Documento do Cálcu de Frete (GWH)
				If lGFEA0841
					ExecBlock( "GFEA0841", .F., .F., {aGWF, aGWI, aGWH} )
				EndIf

				oModelTmp:Deactivate()
				FreeObJ(oModelTmp)
				FreeObJ(_oModelGWF)
				FreeObJ(oModelGWI)
				FreeObJ(oModelGWH)
				FreeObJ(_oModelGWG)
			Next nX
		EndIf
		GFEA084ATU(oModel)
	Else
		FWFormCommit(oModel)
	EndIf
	FreeObJ(oStructGWF)
	FreeObJ(oStructGWI)
	FreeObJ(oStructGWH)
	FreeObJ(oStructGWG)
Return .T.
//-------------------------------------------------------------------

Static Function GFEA084AGR(oModel)
	Local nLine     := oModel:GetLine()
	Local nLen      := oModel:Length()
	Local nDc       := 0
	Local aChave    := {"", "", 0}
	Local cAliasGWU := Nil 

	If !oModel:IsEmpty()

		For nDc := 1 To nLen

			oModel:GoLine(nDc)
			If !oModel:IsDeleted()
				
				cAliasGWU := GetNextAlias()
				BeginSql Alias cAliasGWU
					SELECT GWU.GWU_CDTPDC,
							GWU.GWU_EMISDC,
							GWU.GWU_SERDC,
							GWU.GWU_NRDC,
							GWU.GWU_SEQ
					FROM %Table:GWU% GWU
					WHERE GWU.GWU_FILIAL = %xFilial:GWU%
					AND GWU.GWU_CDTPDC = %Exp:oModel:GetValue("GWH_CDTPDC")%
					AND GWU.GWU_EMISDC = %Exp:oModel:GetValue("GWH_EMISDC")%
					AND GWU.GWU_SERDC = %Exp:oModel:GetValue("GWH_SERDC")%
					AND GWU.GWU_NRDC = %Exp:oModel:GetValue("GWH_NRDC")%
					AND GWU.GWU_SEQ = %Exp:oModel:GetValue("GWH_TRECHO")%
					AND GWU.%NotDel%
				EndSql
				If (cAliasGWU)->(!Eof())
					aChave[1] := xFilial("GWU") + (cAliasGWU)->GWU_CDTPDC + (cAliasGWU)->GWU_EMISDC + (cAliasGWU)->GWU_SERDC + (cAliasGWU)->GWU_NRDC
					aChave[2] := xFilial("GWU") + (cAliasGWU)->GWU_CDTPDC + (cAliasGWU)->GWU_EMISDC + (cAliasGWU)->GWU_SERDC + (cAliasGWU)->GWU_NRDC + (cAliasGWU)->GWU_SEQ
					aChave[3] := nDc

					(cAliasGWU)->(dbCloseArea())
					Exit
				EndIf

				(cAliasGWU)->(dbCloseArea())
			EndIf
		Next nDc
		oModel:GoLine(nLine)
	EndIf
Return aChave

// Prepara campos para chamar tela de escolha de Doc. Carga, caso exista mais de um com as seguintes chaves em parâmetro
Static Function GFE084PreT(oModel)
	Local nLine  := oModel:GetLine()
	Local oView  := FWViewActive()
	Local cTpDc  := oModel:GetValue("GWH_CDTPDC")
	Local cEmiDc := oModel:GetValue("GWH_EMISDC")
	Local cSerDc := oModel:GetValue("GWH_SERDC") 
	Local cNrDc  := oModel:GetValue("GWH_NRDC")
	Local aRet   := {}
	

	If TamSx3("GWH_SERDC")[1] == 14
		aRet := GFE517TLDC( cNrDc , cTpDc , cEmiDc , cSerDc )	

		If Len(aRet) > 0

			If !oModel:IsDeleted()
				oModel:GoLine(nLine)

				oModel:SetValue('GWH_CDTPDC',	aRet[6])
				oModel:SetValue('GWH_EMISDC',	aRet[2])
				oModel:SetValue('GWH_SERDC',	aRet[4])
				oModel:SetValue('GWH_NRDC',		aRet[5])
			EndIf
		
			oView:Refresh()	
		EndIf
	EndIf
		
Return Nil
Static Function GFE084QTCL()
	Local lRet      := .T.
	Local oModel    := FwModelActive()
	Local oModelGWF := oModel:GetModel("GFEA084_GWF")

	If oModelGWF:GetValue("GWF_IDFRVI") == '1'
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Return lRet

Static Function GFE084CTRT()
	Local lRet      := .T.
	Local oModel    := FwModelActive()
	Local oModelGWF := oModel:GetModel("GFEA084_GWF")

	If oModelGWF:GetValue("GWF_QTDCAL") == '2' .And. oModelGWF:GetValue("GWF_IDFRVI") == '1'
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Return lRet

Static Function GFECPMDDAT( oModel)
	Local aDados  := {}
	Local nX      := 0
	Local aFields := oModel:GetStruct():GetFields()
	
	For nX := 1 To Len( aFields )
		If aFields[nX,14] == .F.
			aAdd( aDados, { PadR( aFields[nX][3], 10 ), oModel:GetValue(aFields[nX][3]) } )
		EndIf
	Next nX

Return aDados

Static Function GFEALTDAT(aDados,aCposAlt)
	Local nI   := 0
	Local nAux := 0
	
	For nI := 1 To Len( aCposAlt )
		If ( nAux := aScan( aDados, { |x| x[1] == PadR( aCposAlt[nI][1], 10 ) } ) ) > 0
			aDados[nAux][2] := aCposAlt[nI][2]
		Endif
	Next nI
	
Return

Static Function GFEGETDAT(aDados,cCampo)
	Local nAux := 0
	cCampo := PadR( cCampo, 10 )
	If ( nAux := aScan( aDados, { |x| x[1] == cCampo } ) ) > 0
		Return aDados[nAux,2]
	EndIf
Return 

Function GFEA084LD(aCalcxComb)
	
	Local oFWMVCWindow, aCoors
	Local lRet        := .T.
	Local oView       := NIL
	Local oModel      := Nil
	Local oModelGWFA  := Nil
	Local oModelGWFB  := Nil
	Local oModelGWH   := Nil
	Local oModelGWI   := Nil
	Local oDummy      := Nil
	Local nX          := 0
	Local nY          := 0
	Local nZ          := 0
	Local aGWF        := {}
	Local aGWH        := {}
	Local aGWI        := {}
	Local aLinha      := {}
	Local oViewBkp    := FwViewActive()
	Local oModelBkp   := FwModelActive()
	Local nVlrCalc    := 0
	
	Private aAuxCalc2 := {}
    
	IF Len(aCalcResult) > 0
		aAuxCalc2 := aCalcResult[1,1]
	EndIf
	oView      := FWLoadView('GFEA084A')
	oModel     := oView:oModel
	// Se tem interface com o usuário
	If !ISBLIND() .And. lView
		aCoors := FWGetDialogSize(oMainWnd)
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		
		oModelGWFA := oModel:GetModel("GFEA084A_GWFA")
		oModelGWFB := oModel:GetModel("GFEA084A_GWFC")
		oModelGWH := oModel:GetModel("GFEA084A_GWH")
		oModelGWI := oModel:GetModel("GFEA084A_GWI")
		oDummy := oModel:GetModel("Fantasma")
		oDummy:SetValue("COMMIT","S")
		
		For nX := 1 To Len(aCalcResult)
			aGWF := aCalcResult[nX,1]
			aGWI := aCalcResult[nX,2]
			aGWH := aCalcResult[nX,3]
			
			If nX != 1
				oModelGWFA:AddLine(.T.)
			EndIf
			
			nVlrCalc := 0
			For nY := 1 To Len(aGWF)
				If GF84ACAMPOS("GWF",aGWF[nY,1])
					oModelGWFA:SetValue(aGWF[nY,1],aGWF[nY,2])
					oModelGWFB:SetValue(aGWF[nY,1],aGWF[nY,2])
				EndIf
			Next nY
			
			For nY := 1 To Len(aGWI)
				If nY != 1
					oModelGWI:AddLine(.T.)
				EndIf
				aLinha := aGWI[nY]
				For nZ := 1 To Len(aLinha)
					If GF84ACAMPOS("GWI",aLinha[nZ,1])
						oModelGWI:SetValue(aLinha[nZ,1],aLinha[nZ,2])
						If AllTrim(aLinha[nZ,1]) == 'GWI_VLFRET'
							nVlrCalc += aLinha[nZ,2]
						EndIf
					EndIf
				Next nZ
			Next nY
			oModelGWI:GoLine(1)
			oModelGWFA:SetValue("TOTFRE",nVlrCalc)
			oModelGWFA:SetValue("COMB",aCalcxComb[nX])
			
			For nY := 1 To Len(aGWH)
				If nY != 1
					oModelGWH:AddLine(.T.)
				EndIf
				aLinha := aGWH[nY]
				For nZ := 1 To Len(aLinha)
					If GF84ACAMPOS("GWH",aLinha[nZ,1])
						oModelGWH:SetValue(aLinha[nZ,1],aLinha[nZ,2])
					EndIf
				Next nZ
			Next nY
			oModelGWH:GoLine(1)
			
		Next nX
		oModelGWFA:GoLine(1)

		oView:SetNoInsertLine("GFEA084A_GWFA")
		oView:SetNoUpdateLine("GFEA084A_GWFA")
		oView:SetNoDeleteLine("GFEA084A_GWFA")
		
		oView:SetNoInsertLine("GFEA084A_GWH")
		oView:SetNoUpdateLine("GFEA084A_GWH")
		oView:SetNoDeleteLine("GFEA084A_GWH")
		
		oView:SetNoInsertLine("GFEA084A_GWI")
		oView:SetNoUpdateLine("GFEA084A_GWI")
		oView:SetNoDeleteLine("GFEA084A_GWI")
		
		oView:EnableControlBar(.T.)
		oView:SetOperation(MODEL_OPERATION_INSERT)
		oView:SetUseCursor(.F.)
		oView:SetCloseOnOk({|| .T.})
	
		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
		oFWMVCWindow:SetTitle("Frete Combinado")
		oFWMVCWindow:Activate(,,Nil,.F.)
		
		If oView:GetbuttonWasPressed() == 1
			lRet := .F.
		ElseIf oView:GetbuttonWasPressed() == 0	// Botão OK / Salvar
			lRet := .T.
		EndIf
		
		oModel:Deactivate()
		FreeObJ(oModel)
		FreeObJ(oView)
		FreeObJ(oFWMVCWindow)
		FwViewActive(oViewBkp)
		FwModelActive(oModelBkp)
	EndIf
Return lRet

Static Function ValCalcLot()
	Local lRet      := .T.
	Local cAliasGXD := GetNextAlias()
	
	BeginSql Alias cAliasGXD
		SELECT 1
		FROM %Table:GXD% GXD
		WHERE GXD.GXD_FILCAL = %Exp:GWF->GWF_FILIAL%
		AND GXD.GXD_NRCALC = %Exp:GWF->GWF_NRCALC%
		AND GXD.%NotDel%
	EndSql
	If(cAliasGXD)->(!Eof())
		lRet := .F.
	EndIf
	(cAliasGXD)->(dbCloseArea())
Return lRet

Function ExistDCCpo()
	Local cCodFil := FwFldGet("GWH_FILIAL")
	Local cNumDC  := FwFldGet("GWH_NRDC")
	Local lRet 	  := .F.

	lRet := ExistCpo("GW1", , 8)
	If !lRet
		GW1->(dbSetOrder(8))
		If GW1->(dbSeek(cCodFil + cNumDC))
			lRet := .T.
		EndIf
	EndIf

Return lRet
