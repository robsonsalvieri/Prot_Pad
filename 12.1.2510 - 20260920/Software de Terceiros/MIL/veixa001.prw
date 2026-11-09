// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 10     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
 
#include "VEIXA001.CH"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VEIXA001 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Entrada de Veiculos por Compra                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA001()
Local cFiltro     := ""
Local nCntFor     := 0
Local lTIPMOV     := ( VVF->(FieldPos("VVF_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Local lArgCotUsa  := ( cPaisLoc == "ARG" .and. FWAliasInDic("VWM") )
Local aSlvRotina  := {}
Private cCadastro := STR0001						// Entrada de Veiculos por Compra
Private aRotina   := MenuDef()
Private aCores    := {}
Private cSitVei := " 18" 					// COMPATIBILIDADE COM O SXB - Consulta V11

If cPaisLoc $ "ARG|MEX" // ARGENTINA|MEXICO
	aAdd(aCores,{'VVF->VVF_TPFATR <> "4" .AND. ( VVF->VVF_SITNFI == "1" .AND. VVF->VVF_TIPDOC <> "2" .AND. Empty(VVF->VVF_NUMNFI) .AND. !Empty(VVF->VVF_REMITO) )','BR_AMARELO',STR0008+" - "+STR0021,"@ VVF_TPFATR <> '4' AND ( VVF_SITNFI = '1' AND VVF_TIPDOC <> '2' AND VVF_NUMNFI = ' ' AND VVF_REMITO <> ' ' )"})	// Valida - Remito Efetivado
	aAdd(aCores,{'VVF->VVF_TPFATR <> "4" .AND. ( VVF->VVF_SITNFI == "1" .AND. ( VVF->VVF_TIPDOC == "2" .OR. !Empty(VVF->VVF_NUMNFI) ) )','BR_VERDE',STR0008+" - "+STR0022+" / "+STR0023,"@ VVF_TPFATR <> '4' AND ( VVF_SITNFI = '1' AND ( VVF_TIPDOC = '2' OR VVF_NUMNFI <> ' ' ) )"})	// Valida - Fatura Efetivada / Mov.Interna
	If cPaisLoc == "ARG"
		aAdd(aCores,{'VVF->VVF_TPFATR == "4" .AND. VVF->VVF_SITNFI == "1"','BR_LARANJA',STR0026,"@ VVF_TPFATR = '4' AND VVF_SITNFI = '1'"})	// Entrega Futura (Aguardando Remito)
	ElseIf cPaisLoc == "MEX"
		aAdd(aCores,{'VVF->VVF_SITNFI == "3"','BR_LARANJA',STR0010,"@ VVF_SITNFI = '3'"})	// Devol.Parcial
	EndIf
Else // DEMAIS PAISES
	aAdd(aCores,{'VVF->VVF_SITNFI == "1"','BR_VERDE',STR0008,"@ VVF_SITNFI = '1'"})	// Valida
EndIf
aAdd(aCores,{'VVF->VVF_SITNFI == "0"','BR_VERMELHO',STR0009,"@ VVF_SITNFI = '0'"})	// Cancelada
aAdd(aCores,{'VVF->VVF_SITNFI == "2"','BR_PRETO',STR0010,"@ VVF_SITNFI = '2'"})		// Devolvida


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VVF")
dbSetOrder(1)
//
SETKEY(VK_F12,{|| VXA001Ativa() })
//
cFiltro := " VVF_OPEMOV='0' " // Filtra as Compras
If lTIPMOV
	cFiltro += "AND ( VVF_TIPMOV=' ' OR VVF_TIPMOV='0' ) "
EndIf
//
aSize     := FWGetDialogSize( oMainWnd )
oDlgVXA001 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

	oWorkArea := FWUIWorkArea():New( oDlgVXA001 )
	oWorkArea:CreateHorizontalBox( "LINE01", 100 , .f. ) // Não é PIXEL fixo, trabalha com % nos tamanhos dos Objetos Browse's
	oWorkArea:SetBoxCols( "LINE01", { "OBJVVF" } )
	If lArgCotUsa // Argentina com possibilidade de Cotitulares na Entrada de Usados
		oWorkArea:CreateHorizontalBox( "LINE02", 250 , .t. ) // Monta area fixa 250pix para Argentina com possibilidade de Cotitulares na Entrada de Usados
		oWorkArea:SetBoxCols( "LINE02", { "OBJVWM" } )	
	Endif
	oWorkArea:Activate()

	oBrowse := FWMBrowse():New() 
	oBrowse:SetOwner(oWorkarea:GetPanel("OBJVVF"))
	oBrowse:SetAlias("VVF")
	oBrowse:DisableLocate()
	oBrowse:DisableDetails()
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetMenuDef("VEIXA001")
	oBrowse:SetDescription(cCadastro)
	If !Empty(cFiltro)
		oBrowse:SetFilterDefault("@ "+cFiltro)
	EndIf
	For nCntFor := 1 to len(aCores)
		oBrowse:AddLegend( aCores[nCntFor,1] , aCores[nCntFor,2] , IIf(len(aCores[nCntFor])>2,aCores[nCntFor,3],"") , , .f. )
		If len(aCores[nCntFor]) > 3
			oBrowse:AddFilter(STR0031+": "+UPPER(aCores[nCntFor,3]),aCores[nCntFor,4],.f.,.f.,) // STATUS
		EndIf
	Next
	oBrowse:SetInsert(.f.)
	oBrowse:SetUseFilter()
	oBrowse:Activate()

	If lArgCotUsa // Argentina com possibilidade de Cotitulares na Entrada de Usados
		aSlvRotina := aClone(aRotina)
		aRotina := {}
		oBrwVWM := FwMBrowse():New()
		oBrwVWM:SetOwner(oWorkarea:GetPanel("OBJVWM"))
		oBrwVWM:SetDescription( STR0032 ) // Cotitulares de Usados
		oBrwVWM:SetMenuDef( '' )
		If FindFunction("VA3560071_Limpa_relacionamento_VWM")
			oBrwVWM:AddButton( STR0033 , { || VA3560071_Limpa_relacionamento_VWM( VVF->VVF_TRACPA , .t. ) } ) // Cancelar o vinculo
		EndIf
		oBrwVWM:SetAlias('VWM')
		oBrwVWM:DisableLocate()
		oBrwVWM:DisableDetails()
		oBrwVWM:SetAmbiente(.F.)
		oBrwVWM:SetWalkthru(.F.)
		oBrwVWM:SetInsert(.f.)
		oBrwVWM:SetUseFilter()
		oBrwVWM:lOptionReport := .f.
		oBrwVWM:Activate()
		oRelacVWM:= FWBrwRelation():New()
		oRelacVWM:AddRelation( oBrowse , oBrwVWM , {{ "VWM_FILIAL", "VVF_FILIAL" }, { "VWM_TRACPA", "VVF_TRACPA" } })
		oRelacVWM:Activate()
		aRotina := aClone(aSlvRotina)
	EndIf

oDlgVXA001:Activate( , , , , , , ) //ativa a janela

SetKey(VK_F12,Nil)

//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA001_X ³ Autor ³ Andre Luis Almeida                ³ Data ³ 06/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada das Funcoes de Inclusao e Visualizacao e Cancelamento          ³±±
±±³          ³ forcando a variavel nOpc                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA001_2(cAlias,nReg,nOpc)
VXA001(cAlias,nReg,2)
Return .t.
Function VXA001_3(cAlias,nReg,nOpc)
VXA001(cAlias,nReg,3)
Return .t.
Function VXA001_5(cAlias,nReg,nOpc)
VXA001(cAlias,nReg,5)
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ VXA001   ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Montagem da Janela de Entrada de Veiculos por Compra                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA001(cAlias,nReg,nOpc)
//
DBSelectArea("VVF")
VEIXX000( /* xAutoCab */ , /* xAutoItens */ , /* xAutoCP */ , nOpc /* nOpc */ , "0" /* xOpeMov */ , /* xAutoAux */ , /* xMostraMsg */ , /* xSX5NumNota */ , /* xTIPDOC */ , /* xCodVDV */ , "VEIXA001" /* cRotOrigem */ )
//
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ MenuDef  ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Menu (AROTINA) - Entrada de Veiculos por Compra                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRecebe := {}
Local aRotina := {}

aAdd(aRotina,{ STR0002 ,"AxPesqui" 	, 0 , 1}) // Pesquisar
aAdd(aRotina,{ STR0003 ,"VXA001_2"  , 0 , 2}) // Visualizar
aAdd(aRotina,{ STR0004 ,"VXA001_3"  , 0 , 3}) // Incluir
aAdd(aRotina,{ STR0011 ,"VX001BCO"  , 0 , 4}) // Banco de conhecimento
aAdd(aRotina,{ STR0005 ,"VXA001_5"  , 0 , 5}) // Cancelar
If cPaisLoc $ "ARG|MEX"
	aAdd(aRotina,{ STR0027 ,"VX0000061_Fatura_com_Remito"	, 0 , 4})		// "Fatura sobre Remito"
	If cPaisLoc == "ARG"
		aAdd(aRotina,{ STR0025 ,"VX0000119_RemitoEntregaFutura"	, 0 , 4})	// Remito Entrega Futura
	EndIf
	aAdd(aRotina,{ STR0028 ,"VX0010015_CancelamentoFatura"	, 0 , 4})		// Cancelar Fatura
	If cPaisLoc == "ARG"
		aAdd(aRotina,{ STR0037 ,"VX0010021_CancelamentoRemito"	, 0 , 4})	// Cancelar Remito
	EndIf
	If FindFunction("VX0000241_GeraNCP") // Funcao que sera chamada no VEIXX000
		AAdd(aRotina,{STR0034, "VX0000131_GeraNCP()", 0 , 6}) // Gerar NCP
	EndIf
EndIf
aAdd(aRotina,{ STR0006 ,"VXA001LEG"	, 0 , 7}) // Legenda
aAdd(aRotina,{ STR0016 ,"VXA001CAD"	, 0 , 8}) // Cadastrar Veículo
If FindFunction("U_IMPXMLV")
	aAdd(aRotina,{ STR0017 , "U_IMPXMLV" , 0 , 3}) // Importar XML
EndIf   
If FindFunction("U_IXMLVJD")
	aAdd(aRotina,{ STR0017+" JD" , "U_IXMLVJD" , 0 , 3}) // Importar XML JD
EndIf
aAdd(aRotina,{ STR0007 ,"FGX_PESQBRW('E','0')" , 0 , 1}) // Pesq.Avancada   
If FindFunction("MDeMata103") // Mesmo IF do MATA103

	aRotinaM  := {	{STR0019,"VXA001MNF",0,2,0,nil},;		//"210200 - Confirmação da Operação"
					{STR0020,"VXA001MNF",0,2,0,nil}}		//"210210 - Ciência da Operação"

	aAdd(aRotina,{STR0018, aRotinaM, 0 , 2, 0, nil})//"Manifestar" - //DSERTSS1-177 inclusao de um submenu

Endif	

If ExistBlock("VA01AROT")
	aRecebe := ExecBlock("VA01AROT",.f.,.f.,{aRotina} )
	If Valtype(aRecebe) == "A"
		aRotina := aClone(aRecebe)
	Endif
Endif

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³VXA001LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Legenda - Entrada de Veiculos por Compra                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso      ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA001LEG()
Local aLegenda := {}
If cPaisLoc $ "ARG|MEX" // ARGENTINA E MEXICO
	aAdd(aLegenda,{'BR_AMARELO',STR0008+" - "+STR0021})	// Valida - Remito sem Fatura
	aAdd(aLegenda,{'BR_VERDE',STR0008+" - "+STR0022+" / "+STR0023})	// Valida - Fatura já Efetivada / Mov.Interna
	IF cPaisLoc == "ARG"
		aAdd(aLegenda,{'BR_LARANJA',STR0026})	// Entrega Futura (Aguardando Remito)
	ElseIf cPaisLoc == "MEX"
		aAdd(aLegenda,{'BR_LARANJA',STR0010})	// Dev. Parcial
	EndIf
Else // DEMAIS PAISES
	aAdd(aLegenda,{'BR_VERDE',STR0008})		// Valida
EndIf
aAdd(aLegenda,{'BR_VERMELHO',STR0009})		// Cancelada
aAdd(aLegenda,{'BR_PRETO',STR0010})			// Devolvida
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return


/*/{Protheus.doc} VXA001MNF
	Chamada da Funcao para Manifestar NFe MATA103

	@author Andre Luis Almeida
	@since 27/09/2017
/*/
Function VXA001MNF(cAlias,nReg,nOpcx)

Local cSFunName := FunName() // Salvar o FUNNAME

DbSelectArea("SF1")
DbSetOrder(1) // F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA
If DbSeek( xFilial("SF1") + VVF->VVF_NUMNFI + VVF->VVF_SERNFI + VVF->VVF_CODFOR + VVF->VVF_LOJA )
	//
	nModulo := 2 // Setar Modulo 2 Compras
	SetFunName("MATA103") // Setar FUNNAME com MATA103
	//
	A103Manif(cAlias,nReg,nOpcx) // Funcao de Manifestar NFe esta dentro do MATA103
	//
	nModulo := 11 // Voltar Modulo 11 Veiculos
	SetFunName(cSFunName) // Voltar o FUNNAME
	//
EndIf
DbSelectArea("VVF")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±|Programa  ³ VX001BCO | Autor ³ Thiago	         | Data ³  28/10/13   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Descricao ³ Chamada da funcao Banco de conhecimento.                   |±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX001BCO(cAlias,nReg,nOpc)
FGX_MSDOC(cAlias,nReg,nOpc)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VXA001Ativa ³ Autor ³ Thiago		        ³ Data ³ 13.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a pergunte do mata103                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VXA001Ativa()
	
	//Isto foi criado devido a necessidade de parametros específicos da rotina.
	//Caso existam reclamações dos clientes, poderemos futuramente ficar com 2 perguntes. Orientação do Rubens.
	If FWSX1Util():ExistPergunte("VXA001")
		Pergunte("VXA001",.T.)
	Else
		Pergunte("MTA103",.T.)
	End
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VXA001CAD ³ Autor ³ Thiago		        ³ Data ³ 18.05.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Criacao do veiculo no SB1 e VV1.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA001CAD(cAlias,nReg,nOpc)
// 
Local nOpcA := 0
Private cChassi	   := space(TamSX3("VV1_CHASSI")[1])
Private cChassiDig := space(TamSX3("VV1_CHASSI")[1])
Private aCampos    := {}
Private inclui     := .t.
&& Define a tela
DEFINE MSDIALOG oDlgV TITLE STR0012 From 9,0 to 15,64	of oMainWnd    
	
	
@ 008,003 SAY STR0013 OF oDlgV PIXEL COLOR CLR_BLUE   
@ 008,033 MSGET oVeic VAR cChassiDig PICTURE "@!" SIZE 200,4 OF oDlgV PIXEL COLOR CLR_BLUE
	
DEFINE SBUTTON oBtOk     FROM 025,101 TYPE 1 ACTION (nOpcA:=1,oDlgV:End()) ENABLE OF oDlgV
DEFINE SBUTTON oBtCancel FROM 025,141 TYPE 2 ACTION (nOpcA:=2,oDlgV:End()) ENABLE OF oDlgV
		
ACTIVATE MSDIALOG oDlgV CENTER     

if nOpcA == 1                      

	cChassi 	:= cChassiDig 			// preenchimento da variavel de integracao

	// TENTA PROCURAR O CHASSI NO CADASTRO SE ENCONTRAR VERIFICA SE JA NAO ESTA NO
	// ESTOQUE CASO CONTRARIO CADASTRA O VEICULO CHAMANDO A FUNCAO DO VEIVA010
	if !Empty(cChassi) 
		M->VV1_CHASSI := cChassi 			// preenchimento da variavel de integracao
		lAchou := FG_POSVEI("cChassi","VV1->VV1_CHASSI")
		If !lAchou
			cTmpVarObs := ""
			cChassiPre :=  cChassi
			lRetVA010 := VA0700103_InclusaoNovoChassi(cChassi)
		Else
			MSGStop(STR0014)
		EndIf
	Else
		MSGStop(STR0015)
	Endif
Endif
	     
Return

/*/{Protheus.doc} VX0010015_CancelamentoFatura

	Cancelamento somente da Fatura

@type function
@version 1.0
@author Renato Vinicius
@since 22/10/2025
/*/
Function VX0010015_CancelamentoFatura(cAlias,nReg,nOpc)
	Local aQUltMov := {}
	Private acols := {} // Para compatibilidade da função VX000GRV
	Private lMostraMsg := .t. // Para compatibilidade da função VX000GRV
	Private lVX000Auto := .t. // Para compatibilidade da função VX000GRV

	If VVF->VVF_SITNFI <> "1" // Diferente de 1=Valida
		MsgStop(STR0035,STR0030) // Status da Entrada por Compra indisponível para Cancelamento. Impossível continuar. / Atenção
		Return
	EndIf	
	If !Empty(VVF->VVF_NUMNFI) .and. !Empty(VVF->VVF_REMITO)
		VVG->(DbSetOrder(1))
		VVG->(DbSeek(VVF->VVF_FILIAL+VVF->VVF_TRACPA))
		While !VVG->(Eof()) .and. ( VVG->VVG_FILIAL + VVG->VVG_TRACPA ) == ( VVF->VVF_FILIAL + VVF->VVF_TRACPA )
			aQUltMov := FM_VEIUMOV( VVG->VVG_CHASSI ) // CHASSI
			If len(aQUltMov) > 0
				If aQUltMov[1] == "S" .or. ( VVF->VVF_FILIAL+VVF->VVF_TRACPA <> aQUltMov[2]+aQUltMov[3] )
					MsgStop(STR0038+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VVG->VVG_CHASSI,STR0030) // Para realizar o Cancelamento é necessário que a Entrada por Compra seja a ultima movimentação do Chassi. / Atenção
					Return
				EndIf
			EndIf
			VVG->(DbSkip())
		EndDo
		If MsgNoYes(STR0029,STR0030) // "Deseja efetuar o cancelamento somente da fatura?" // "Atenção"
			VX000GRV(5,"0",,,,"VEIXA001",,/*lCanRemito*/.f.,,/*lExcluiNF*/.t.)
		EndIf
	ElseIf !Empty(VVF->VVF_NUMNFI) .and. Empty(VVF->VVF_REMITO)
		VXA001_5("VVF",VVF->(RecNo()),5) // Cancelamento tela e processo padrão
	Else
		MsgInfo(STR0036,STR0030) // Opção disponível apenas quando existem Fatura e Remito para esta Entrada por Compra. / Atenção
	EndIf

Return

/*/{Protheus.doc} VX0010021_CancelamentoRemito

	Cancelamento somente do Remito

@type function
@version 1.0
@author Andre Luis Almeida
@since 19/08/2026
/*/
Function VX0010021_CancelamentoRemito(cAlias,nReg,nOpc)
	Local aQUltMov := {}
	Private acols := {} // Para compatibilidade da função VX000GRV
	Private lMostraMsg := .t. // Para compatibilidade da função VX000GRV
	Private lVX000Auto := .t. // Para compatibilidade da função VX000GRV
	If VVF->VVF_SITNFI <> "1" // Diferente de 1=Valida
		MsgStop(STR0035,STR0030) // Status da Entrada por Compra indisponível para Cancelamento. Impossível continuar. / Atenção
		Return
	EndIf	
	If !Empty(VVF->VVF_REMITO) .and. !Empty(VVF->VVF_NUMNFI)
		VVG->(DbSetOrder(1))
		VVG->(DbSeek(VVF->VVF_FILIAL+VVF->VVF_TRACPA))
		While !VVG->(Eof()) .and. ( VVG->VVG_FILIAL + VVG->VVG_TRACPA ) == ( VVF->VVF_FILIAL + VVF->VVF_TRACPA )
			aQUltMov := FM_VEIUMOV( VVG->VVG_CHASSI ) // CHASSI
			If len(aQUltMov) > 0
				If aQUltMov[1] == "S" .or. ( VVF->VVF_FILIAL+VVF->VVF_TRACPA <> aQUltMov[2]+aQUltMov[3] )
					MsgStop(STR0038+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VVG->VVG_CHASSI,STR0030) // Para realizar o Cancelamento é necessário que a Entrada por Compra seja a ultima movimentação do Chassi. / Atenção
					Return
				EndIf
			EndIf
			If VVG->VVG_CODTES == VVG->VVG_TESREM // Mesmo TES - Fatura sobre Remito
				MsgStop(STR0039,STR0030) // Opção não disponivel quando a Entrada por Compra foi realizada via Fatura sobre Remito. / Atenção
				Return
			EndIf
			VVG->(DbSkip())
		EndDo
		If MsgNoYes(STR0040,STR0030) // Deseja efetuar o cancelamento somente do Remito? / Atenção
			VX000GRV(5,"0",,,,"VEIXA001",,/*lCanRemito*/.t.,,/*lExcluiNF*/.f.)
		EndIf
	ElseIf !Empty(VVF->VVF_REMITO) .and. Empty(VVF->VVF_NUMNFI)
		VXA001_5("VVF",VVF->(RecNo()),5) // Cancelamento tela e processo padrão
	Else
		MsgInfo(STR0036,STR0030) // Opção disponível apenas quando existem Fatura e Remito para esta Entrada por Compra. / Atenção
	EndIf

Return

/*/{Protheus.doc} VX0000131_GeraNCP
Chamada da geração de NCP referente a Fatura de Entrada por Compra (VEIXX000)

@type function
@author Andre Luis Almeida
@since 11/08/2026
/*/
Function VX0000131_GeraNCP()
	Processa( { || VX0000241_GeraNCP( VVF->(RecNo()) , 0 , .t. , "1" ) } ) // Chama Funcao VX0000241_GeraNCP do VEIXX000
Return