#include "PROTHEUS.CH"
#include "VEIXA030.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA030 ³ Autor ³ Andre Luis Almeida                ³ Data ³ 23/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faturamento Direto                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA030(lNoMBrowse,aRecInter)
Local nCntFor     := 0
Local cFiltro     := ""
Local cFilUser    := ""
Local aFatRem     := {}
Private cCadastro := STR0001
Private aRotina   := MenuDef()
Private aCores    := {	{'VV9->VV9_STATUS == "F"','BR_PRETO'   , STR0003 , "@ VV9_STATUS = 'F'"},;	// Finalizado
						{'VV9->VV9_STATUS == "C"','BR_VERMELHO', STR0004 , "@ VV9_STATUS = 'C'"},;	// Cancelado
						{'VV9->VV9_STATUS == "P"','BR_AMARELO' , STR0015 , "@ VV9_STATUS = 'P'"},;	// Pendente de Aprovacao
						{'VV9->VV9_STATUS == "O"','BR_BRANCO'  , STR0016 , "@ VV9_STATUS = 'O'"},;	// Pre-Aprovado
						{'VV9->VV9_STATUS == "L"','BR_AZUL'    , STR0017 , "@ VV9_STATUS = 'L'"},;	// Aprovado
						{'VV9->VV9_STATUS == "R"','BR_LARANJA' , STR0018 , "@ VV9_STATUS = 'R'"},;	// Reprovado
						{'VV9->VV9_STATUS == "A"','BR_VERDE'   , STR0002 , "@ VV9_STATUS = 'A'"}}	// Em Aberto
Private cMotivo   := "000001"
Default lNoMBrowse := .f.
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas

//////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos //
//////////////////////////////////////////////////////////////////////////////
If !AMIIn(11) .or. !FMX_AMIIN({"VEIXA030"})
	Return()
EndIf

// Ponto de Entrada para Filtro do Browse
If ExistBlock("VXA030FBRW")
	cFilUser := ExecBlock("VXA030FBRW", .f., .f.)
EndIf

//
SetKey(VK_F12,{ || VXA030F12(.t.) })
//

VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI")+__cUserID))
DbSelectArea("VV9")
DbSetOrder(1)

If lNoMBrowse
	If ( nOpc <> 0 ) .and. !Deleted()		
		bBlock := &( "{ |a,b,c,d| " + aRotina[ nOpc,2 ] + "(a,b,c,d) }" )
		Eval( bBlock , Alias() , (Alias())->(Recno()) , nOpc , aRecInter )
	EndIf
Else
	////////////////////////////////////////////
	// Filtro do Browse - Faturamento Direto  //
	////////////////////////////////////////////
	cFiltro := " EXISTS ( SELECT VV0.VV0_CODVEN FROM "+RetSQLName("VV0")+" VV0 WHERE "
	cFiltro += "VV0.VV0_FILIAL=VV9_FILIAL AND VV0.VV0_NUMTRA=VV9_NUMATE AND VV0.VV0_TIPFAT='2' AND "
	If Empty(VAI->VAI_ATEOUT) .or. VAI->VAI_ATEOUT == "0" // Nao Visualiza Atendimentos de outros vendedores
		cFiltro += "VV0.VV0_CODVEN='"+VAI->VAI_CODVEN+"' AND " // NAO visualiza Atendimentos de outros vendedores
	EndIf
	cFiltro += "VV0.D_E_L_E_T_=' ') "
	cFiltro += IIf(Empty(cFilUser), "", " AND " + cFilUser)

	aSize     := FWGetDialogSize( oMainWnd )
	oDlgVX030 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
	oWorkArea := FWUIWorkArea():New( oDlgVX030 )

	oWorkArea:CreateHorizontalBox( "LINE01", 100 , .f. ) // Não é PIXEL fixo, trabalha com % nos tamanhos dos Objetos Browse's
	oWorkArea:SetBoxCols( "LINE01", { "OBJVV9" } )

	if cPaisLoc == "ARG"
		oWorkArea:CreateHorizontalBox( "LINE02", 135 , .t. ) // Monta area fixa 135pix para Argentina com as Faturas e Remitos
		oWorkArea:SetBoxCols( "LINE02", { "OBJARG" } )	
	Endif

	oWorkArea:Activate()

	if cPaisLoc == "ARG"
		oLbXA30FR := TWBrowse():New(1,1,1,1,,,,oWorkarea:GetPanel("OBJARG"),,,,,/*{ || .t. }*/,,,,,,,.F.,,.T.,,.F.,,,)
		oLbXA30FR:addColumn( TCColumn():new( STR0019 , { || aFatRem[oLbXA30FR:nAt,1] } ,,,,"LEFT" , 70,.F.,.F.,,,,.F.,) ) // Tipo
		oLbXA30FR:addColumn( TCColumn():new( STR0020 , { || aFatRem[oLbXA30FR:nAt,2] } ,,,,"LEFT" , 70,.F.,.F.,,,,.F.,) ) // Documento
		oLbXA30FR:addColumn( TCColumn():new( STR0021 , { || aFatRem[oLbXA30FR:nAt,3] } ,,,,"LEFT" , 35,.F.,.F.,,,,.F.,) ) // Serie
		oLbXA30FR:addColumn( TCColumn():new( STR0022 , { || aFatRem[oLbXA30FR:nAt,4] } ,,,,"LEFT", 200,.F.,.F.,,,,.F.,) ) // Fornecedor/Cliente
		oLbXA30FR:Align := CONTROL_ALIGN_ALLCLIENT
		oLbXA30FR:nAT := 1
		oLbXA30FR:SetArray(aFatRem)
	EndIf

	oBrowse := FWMBrowse():New() 
	oBrowse:SetOwner(oWorkarea:GetPanel("OBJVV9"))
	oBrowse:SetAlias("VV9")
	oBrowse:DisableLocate()
	oBrowse:DisableDetails()
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetMenuDef("VEIXA030")
	oBrowse:SetDescription(cCadastro)
	oBrowse:SetFilterDefault("@ "+cFiltro)
	For nCntFor := 1 to len(aCores)
		oBrowse:AddLegend( aCores[nCntFor,1] , aCores[nCntFor,2] , IIf(len(aCores[nCntFor])>2,aCores[nCntFor,3],"") , , .f. )
		If len(aCores[nCntFor]) > 3
			oBrowse:AddFilter(STR0023+": "+UPPER(aCores[nCntFor,3]),aCores[nCntFor,4],.f.,.f.,) // STATUS
		EndIf
	Next
	if cPaisLoc == "ARG"
		If ( VV0->(FieldPos("VV0_STAFDI")) > 0 )
			cFiltro := " EXISTS ( SELECT VV0.VV0_CODVEN FROM "+RetSQLName("VV0")+" VV0 WHERE "
			cFiltro += "VV0.VV0_FILIAL=VV9_FILIAL AND VV0.VV0_NUMTRA=VV9_NUMATE AND VV0.VV0_TIPFAT='2' AND VV0.D_E_L_E_T_=' '"
			oBrowse:AddFilter(STR0033,"@ "+cFiltro+" AND VV0.VV0_STAFDI IN (' ','0') )",.f.,.f.,) // Sem Faturas e Remitos de Entrada e Saida
			oBrowse:AddFilter(STR0034,"@ "+cFiltro+" AND VV0.VV0_STAFDI IN ('1','2','3','4') )",.f.,.f.,) // Com alguma Fatura ou Remito de Entrada ou Saida
			oBrowse:AddFilter(STR0035,"@ "+cFiltro+" AND VV0.VV0_STAFDI IN ('1','2') )",.f.,.f.,) // Com alguma Fatura ou Remito de Entrada sem Saida
			oBrowse:AddFilter(STR0036,"@ "+cFiltro+" AND VV0.VV0_STAFDI = '2' )",.f.,.f.,) // Com todas Faturas e Remitos de Entrada sem Saida
			oBrowse:AddFilter(STR0037,"@ "+cFiltro+" AND VV0.VV0_STAFDI IN ('3','4') )",.f.,.f.,) // Com Faturas e Remitos de Entrada e alguma Saida
			oBrowse:AddFilter(STR0038,"@ "+cFiltro+" AND VV0.VV0_STAFDI = '4' )",.f.,.f.,) // Com todas Faturas e Remitos de Entrada e Saida
		EndIf
		oBrowse:SetChange( { || aFatRem := VXX030061_Levanta_Faturas_e_Remitos(VV9->VV9_FILIAL,VV9->VV9_NUMATE) , oLbXA30FR:SetArray(aFatRem) , oLbXA30FR:Refresh() } )
	EndIf
	oBrowse:SetInsert(.f.)
	oBrowse:SetUseFilter()
	oBrowse:lOptionReport := .f.
	oBrowse:Activate()

	oDlgVX030:Activate( , , , , , , ) //ativa a janela

EndIf

DbSelectArea("VV9")

SetKey(VK_F12,Nil)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA030?  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 23/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem da Janela de Faturamento Direto                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA030V(cAlias,nReg,nOpc)
nOpc := 2 // Visualizar
VXA030(cAlias,nReg,nOpc)
Return()
//
Function VXA030I(cAlias,nReg,nOpc,aRecInter)
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas
nOpc := 3 // Incluir
VXA030(cAlias,nReg,nOpc,aRecInter)
Return()
//
Function VXA030A(cAlias,nReg,nOpc)
nOpc := 4 // Alterar
VXA030(cAlias,nReg,nOpc)
Return()
//
Function VXA030C(cAlias,nReg,nOpc)
nOpc := 5 // Cancelar
VXA030(cAlias,nReg,nOpc)
Return()
///////////////////////////////////////////////////////
// Montagem da Janela de Faturamento Direto          //
///////////////////////////////////////////////////////
Function VXA030(cAlias,nReg,nOpc,aRecInter)
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas
//
DbSelectArea("VV9")
If nOpc == 4 .or. nOpc == 5
	If !Softlock("VV9")
		Return .f.
	EndIf
EndIf
//
SetKey(VK_F12,Nil)
//
VEIXX030(NIL,NIL,NIL,nOpc,aRecInter)
//
SetKey(VK_F12,{ || VXA030F12(.t.) })
//
MsUnlockAll()
//
SA1->(MsUnlock()) // Nao remover, pois quando integrado com o Venda Direta o registro permanecia bloqueado
//
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Andre Luis Almeida                ³ Data ³ 23/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Faturamento Direto                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local  aRotina := {	{STR0005,"AxPesqui"		,0,1},; 		// Pesquisar
					{STR0006,"VXA030V"		,0,2},;  		// Visualizar
					{STR0007,"VXA030I"		,0,3},;   		// Incluir
					{STR0008,"VXA030A"		,0,4},;   		// Alterar
					{STR0009,"VXA030C"		,0,5},;   		// Cancelar
					{STR0010,"VXA030LEG"	,0,4,2,.f.},;	// Legenda
					{STR0011,"VXA030011_Chamada_VEIVM180()",0,6}} // Gerar NF/Titulos
If cPaisLoc == "ARG"
	aAdd(aRotina,{STR0024,"VEIA341(1)",0,4}) // Gerar Fatura de Entrada
	aAdd(aRotina,{STR0025,"VEIA341(2)",0,4}) // Gerar Remito de Entrada
	aAdd(aRotina,{STR0026,"VEIA342(1)",0,4}) // Gerar Fatura de Saida
	aAdd(aRotina,{STR0027,"VEIA342(2)",0,4}) // Gerar Remito de Saida
	aAdd(aRotina,{STR0028,"VXA030021_Cancelamento_Faturas_Remitos()",0,4}) // Cancelamento das Faturas e Remitos
EndIf
If (ExistBlock("VXA030MD")) // Ponto de Entrada para adicionar opções no Menu
	aRotina := ExecBlock("VXA030MD", .f., .f., {aRotina})
EndIf
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA030LEG³ Autor ³ Andre Luis Almeida                ³ Data ³ 23/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Faturamento Direto                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA030LEG()
Local aLegenda := {	{'BR_VERDE'   , STR0002 },; // Em Aberto
					{'BR_AMARELO' , STR0015 },; // Pendente de Aprovacao
					{'BR_BRANCO'  , STR0016 },; // Pre-Aprovado
					{'BR_AZUL'    , STR0017 },; // Aprovado
					{'BR_LARANJA' , STR0018 },; // Reprovado
					{'BR_PRETO'   , STR0003 },; // Finalizado
					{'BR_VERMELHO', STR0004 }}  // Cancelado
BrwLegenda(cCadastro,STR0010,aLegenda) // Legenda
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA030F12³ Autor ³ Andre Luis Almeida                ³ Data ³ 19/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ F12 - Parametros da Rotina                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA030F12(lMostra)
Local cPerg := "VXA030"
//
If lMostra
	SetKey(VK_F12, Nil )
EndIf
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunte para Configuracao da Rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AADD(aRegs,{STR0012,STR0012,STR0012,"MV_CH1","N",1 ,0,2,"C",'',"MV_PAR01",STR0013,STR0013,STR0013,"","",STR0014,STR0014,STR0014,'','','','','','','','','','','','','','','','','','S','','','',''})
//
Pergunte(cPerg,lMostra,,,,.f.)
//
If lMostra
	SetKey(VK_F12,{ || VXA030F12(.t.) })
EndIf
//
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA030OPORT³ Autor ³ Andre Luis Almeida              ³ Data ³ 10/06/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Incluir Fat.Direto atraves da tela de Oportunidade de Vendas           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aRecInter = RecNo's dos Interesses da Oportunidade de Vendas           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA030OPORT(aRecInter)
Local cBkpFunName := FunName()
Default aRecInter := {} // RecNo's dos Interesses da Oportunidade de Vendas
//
SetFunName("VEIXA030") 
nOpc := 3
dbSelectArea("VV9") 
VEIXA030(.T.,aRecInter)
SetFunName(cBkpFunName)
//
Return()

/*/{Protheus.doc} VXA030011_Chamada_VEIVM180
Chamada do VEIVM180 para geração de nota e titulos de comissão de faturamento direto

@author Andre Luis Almeida
@since 31/01/2025
@version undefined
@type function
/*/
Function VXA030011_Chamada_VEIVM180()
SetKey(VK_F12, Nil )
VEIVM180(VV9->(RecNo()))
SetKey(VK_F12,{ || VXA030F12(.t.) })
Return

/*/{Protheus.doc} VXA030021_Cancelamento_Faturas_Remitos
ARGENTINA - Cancelamento das Faturas e Remitos
Entradas ( 1 = Fatura / 2 = Remito )
Saidas ( 3 = Fatura / 4 = Remito )

@author Andre Luis Almeida
@since 17/06/2026
@version undefined
@type function
/*/
Function VXA030021_Cancelamento_Faturas_Remitos()
Local oProcess // incluído o parâmetro lEnd para controlar o cancelamento da janela
Local nCntFor   := 0
Local nOpcAviso := 0
Local cOpcAviso := ""
Local aOpcAviso := {}
Local lVV0_STAFDI := ( VV0->(FieldPos("VV0_STAFDI")) > 0 )
Local aFatRem   := VXX030061_Levanta_Faturas_e_Remitos(VV9->VV9_FILIAL,VV9->VV9_NUMATE)
If lVV0_STAFDI .and. VXA030051_valida_Veiculos(VV9->VV9_FILIAL,VV9->VV9_NUMATE)
	If !Empty(aFatRem[1,1]) // Status de Fatura e Remitos ( Argentina )
		For nCntFor := 1 to len(aFatRem)
			cOpcAviso += CHR(13)+CHR(10)+"( "+strzero(nCntFor,1)+" ) "+aFatRem[nCntFor,1]+": "+aFatRem[nCntFor,2]+"-"+aFatRem[nCntFor,3]+CHR(13)+CHR(10)
			If nCntFor == len(aFatRem)
				aAdd(aOpcAviso,"( "+strzero(nCntFor,1)+" ) "+aFatRem[nCntFor,1])
			EndIf
		Next
		If len(aFatRem) > 1
			aAdd(aOpcAviso,STR0029) // Todas Faturas e Remitos
		EndIf
		aAdd(aOpcAviso,STR0030) // Fechar
		nOpcAviso := Aviso(STR0028,cOpcAviso,aOpcAviso,2) // Cancelamento das Faturas e Remitos
		oProcess := MsNewProcess():New({|lEnd| VXA030031_processa_Cancelamentos_Faturas_e_Remitos( nOpcAviso , aFatRem , @oProcess , @lEnd ) },STR0001,"",.T.) // Faturamento Direto
		oProcess:Activate()
	Else
		FMX_HELP("VXA30ERR001",STR0031,STR0032) // Não existem Faturas e Remitos gerados. / Impossivel continuar.
	EndIf
EndIf
Return

/*/{Protheus.doc} VXA030031_processa_Cancelamentos_Faturas_e_Remitos
ARGENTINA - Processa (REGUA) Cancelamento das Faturas e Remitos
Entradas ( 1 = Fatura / 2 = Remito )
Saidas ( 3 = Fatura / 4 = Remito )

@author Andre Luis Almeida
@since 18/06/2026
@version undefined
@type function
/*/
Static Function VXA030031_processa_Cancelamentos_Faturas_e_Remitos( nOpcAviso , aFatRem , oProcess , lEnd )
Local nCntFor := 0
oProcess:SetRegua1(0)
oProcess:IncRegua1(STR0028) // Cancelamento das Faturas e Remitos
If nOpcAviso == 1 // Ultima Fatura/Remito
	nCntFor := len(aFatRem)
	oProcess:SetRegua2(2)
	oProcess:IncRegua2(aFatRem[nCntFor,1]+": "+aFatRem[nCntFor,2]+"-"+aFatRem[nCntFor,3])
		VXA030041_executa_Cancelamento_Faturas_Remitos(nCntFor,VV0->(RecNo()))
	oProcess:IncRegua2(aFatRem[nCntFor,1]+": "+aFatRem[nCntFor,2]+"-"+aFatRem[nCntFor,3])
ElseIf len(aFatRem) > 1 .and. nOpcAviso == 2 // Todas Faturas/Remitos
	oProcess:SetRegua2(len(aFatRem))
	For nCntFor := len(aFatRem) to 1 step -1 // Order decrescente
		oProcess:IncRegua2(aFatRem[nCntFor,1]+": "+aFatRem[nCntFor,2]+"-"+aFatRem[nCntFor,3])
		If !VXA030041_executa_Cancelamento_Faturas_Remitos(nCntFor,VV0->(RecNo()))
			Exit
		EndIf
	Next
EndIf
Return

/*/{Protheus.doc} VXA030041_executa_Cancelamento_Faturas_Remitos
ARGENTINA - Executa o Cancelamento das Faturas e Remitos
Entradas ( 1 = Fatura / 2 = Remito )
Saidas ( 3 = Fatura / 4 = Remito )

@author Andre Luis Almeida
@since 17/06/2026
@version undefined
@type function
/*/
Static Function VXA030041_executa_Cancelamento_Faturas_Remitos(nFatRem,nRECVV0)
Local lOkExec := .t.
If nFatRem <= 2 // Entradas ( 1 = Fatura / 2 = Remito )
	lOkExec := VA3410071_Cancelar_Entrada(nFatRem,nRECVV0)
Else // Saidas ( 3 = Fatura / 4 = Remito )
	lOkExec := VA3420061_Cancelar_Saida(nFatRem,nRECVV0)
EndIf
Return lOkExec

/*/{Protheus.doc} VXA030051_valida_Veiculos
ARGENTINA - Valida se o Veiculo esta Vendido para poder realizar o processo
Obs.: Se TODOS os Veiculos dos VVAs estiverem 1=Vendido vai retornar .t.

@author Andre Luis Almeida
@since 20/06/2026
@version undefined
@type function
/*/
Function VXA030051_valida_Veiculos(cFilTra,cNumTra)
Local aQUltMov := {}
Local cQAlSQL  := "SQLVV1"
Local cChassi  := ""
Local lRet     := .t.
Local cQuery   := ""
cQuery := "SELECT VV1.VV1_CHASSI , VV1.VV1_SITVEI "
cQuery += "  FROM "+RetSQLName("VVA")+" VVA "
cQuery += "  JOIN "+RetSQLName("VV1")+" VV1 "
cQuery += "       ON VV1.VV1_FILIAL='"+xFilial("VV1")+"'"
cQuery += "       AND VV1.VV1_CHAINT=VVA.VVA_CHAINT"
cQuery += "       AND VV1.D_E_L_E_T_=' '"
cQuery += " WHERE VVA.VVA_FILIAL='"+cFilTra+"'"
cQuery += "   AND VVA.VVA_NUMTRA='"+cNumTra+"'"
cQuery += "   AND VVA.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .F., .T. )
While !( cQAlSQL )->( Eof() ) .and. lRet
	cChassi := ( cQAlSQL )->( VV1_CHASSI )
	lRet := ( ( cQAlSQL )->( VV1_SITVEI ) == "1" )
	If lRet
		aQUltMov := FM_VEIUMOV( cChassi , "E" , ) // Verifica se possui Entrada valida VVF/VVG
		lRet := ( len(aQUltMov) == 0 )
	EndIf
	( cQAlSQL )->( DbSkip() )
EndDo
( cQAlSQL )->( DbCloseArea() )
DbSelectArea("VV0")
If !lRet
	FMX_HELP("VXA30ERR002",STR0039+CHR(13)+CHR(10)+cChassi,STR0032) // O Veiculo/Maquina já possui movimentação posterior. / Impossivel continuar.
EndIf
Return lRet