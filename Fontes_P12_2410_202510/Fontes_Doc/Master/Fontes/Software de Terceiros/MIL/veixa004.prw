// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 34     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "VEIXA004.CH"
#include "PROTHEUS.CH"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±               		
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA004 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Entrada de Veiculos por Transferencia                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA004()
Local cFiltro     := ""
Private cCadastro := STR0001 // Entrada de Veiculos por Transferencia
Private aRotina   := MenuDef()
Private cCGCSM0 := ""
Private cCdCliA := ""
Private cLjCliA := ""
Private aHeader :={{"",""}}
Private cFilAntBkp := cFilAnt
Private aCores    := {;
					{'VVF->VVF_SITNFI == "1"','BR_VERDE'},;		// Valida
					{'VVF->VVF_SITNFI == "0"','BR_VERMELHO'},;	// Cancelada
					{'VVF->VVF_SITNFI == "2"','BR_PRETO'}}		// Transferida
Private cGruVei  := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1])) // Grupo do Veiculo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VVF")
dbSetOrder(1)
//
cFiltro := " VVF_OPEMOV='3' " // Filtra as Transferencias
//
mBrowse( 6, 1,22,75,"VVF",,,,,,aCores,,,,,,,,cFiltro)
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004_V ³ Autor ³ Thiago							³ Data ³ 07/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizar													          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004_V(cAlias,nReg,nOpc)
nOpc := 2
VXA004(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004_I ³ Autor ³ Thiago							³ Data ³ 07/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclui transferencia											          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004_I(cAlias,nReg,nOpc)
nOpc := 3
VXA004(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004_C ³ Autor ³ Thiago							³ Data ³ 07/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelar transferencia										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004_D(cAlias,nReg,nOpc)
nOpc := 4
VXA004(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004_C ³ Autor ³ Thiago							³ Data ³ 07/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelar transferencia										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004_R(cAlias,nReg,nOpc)
nOpc := 6
VXA004(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004_C ³ Autor ³ Thiago							³ Data ³ 07/02/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cancelar transferencia										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004_C(cAlias,nReg,nOpc)
nOpc := 5
VXA004(cAlias,nReg,nOpc)
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004   ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada das Funcoes de Inclusao e Visualizacao e Cancelamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004(cAlias,nReg,nOpc)
//
DBSelectArea("VVF")
if nOpc == 3 // INCLUSAO
	VXA004BRWVV0()
ElseIf nOpc == 4
	VXA004DEV(cFilAnt)
ElseIf nOpc == 6
	VXA004RET()
Else // VISUALIZACAO E CANCELAMENTO
	VEIXX000(/* xAutoCab */ , /* xAutoItens */ , /* xAutoCP */ , nOpc /* nOpc */ , "3" /* xOpeMov */ , /* xAutoAux */ , /* xMostraMsg */ , /* xSX5NumNota */ , /* xTIPDOC */ , /* xCodVDV */ , "VEIXA004" /* cRotOrigem */)	// VEIXX000(xAutoCab,xAutoItens,xAutoCP,nOpc,xOpeMov)
EndIf
//
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA004BRWVV0³ Autor ³Andre Luis Almeida / Luis Delorme³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem do Browse com as SAIDAS de Veiculos por Transferencia         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004BRWVV0()
Local aRotinaX := aClone(aRotina)      
Local aSM0     := {}
Local aOpcoes  := {}
Local aCliARG  := {}
Local cOrdVV0  := "VV0_FILIAL,VV0_NUMNFI,VV0_SERNFI"
Private cBrwCond2 := 'VV0->VV0_TIPO <> "D" .AND. VV0->VV0_OPEMOV$ "2" .AND. VV0->VV0_SITNFI=="1" .AND. VXA004FIL() ' // Condicao do Browse, validar ao Incluir/Alterar/Excluir

If cPaisLoc == "ARG"
	cBrwCond2 += '.AND. !Empty(VV0->VV0_REMITO)' // Condicao do Browse, validar ao Incluir/Alterar/Excluir
	cOrdVV0   := "VV0_FILIAL,VV0_REMITO,VV0_SERREM"
Else
	cBrwCond2 += '.AND. !Empty(VV0->VV0_NUMNFI)'
EndIf

//
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
cCGCSM0 := aSM0[18]
cCdCliA := ""
cLjCliA := ""
If cPaisLoc == "ARG"
	aCliARG := FGX_SM0SA1(cFilAnt) // Retorna o Cliente/Loja correspondete ao SM0 posicionado
	cCdCliA := aCliARG[1]
	cLjCliA := aCliARG[2]
EndIf
dbSelectArea("VV0")
dbSetOrder(4)
//   
cFilTop := "VV0.R_E_C_N_O_ IN ( SELECT VV0.R_E_C_N_O_ "
cFilTop += " FROM " + RetSQLName("SA1") + " A1 JOIN "+RetSQLName("VV0")+" VV0 ON VV0_FILIAL <> '" + xFilial("VV0") + "' AND VV0_CODCLI = A1_COD AND VV0_LOJA = A1_LOJA AND VV0_TIPO <> 'D' AND VV0.D_E_L_E_T_ = ' '"
cFilTop += " JOIN " + RetSQLName("VVA") + " VVA ON VVA_FILIAL = VV0_FILIAL AND VVA_NUMTRA = VV0_NUMTRA AND VVA.D_E_L_E_T_ = ' '"
cFilTop += " JOIN " + RetSQLName("VV1") + " VV1 ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = VVA.VVA_CHAINT AND VV1.VV1_NUMTRA = VV0_NUMTRA AND VV1.VV1_FILSAI = VV0_FILIAL AND VV1.VV1_SITVEI = '2' "
cFilTop += " AND VV1.VV1_ULTMOV = 'S'"
cFilTop += " AND VV1.D_E_L_E_T_ = ' '"
cFilTop += " WHERE A1.A1_FILIAL = '"+xFilial("SA1")+"'"
If cPaisLoc == "ARG"
	cFilTop +=  " AND A1.A1_COD  = '" + cCdCliA + "'"
	cFilTop +=  " AND A1.A1_LOJA = '" + cLjCliA + "'"
Else
	cFilTop +=  " AND A1.A1_CGC = '" + cCGCSM0 + "'"
EndIf
cFilTop +=  " AND A1.D_E_L_E_T_ = ' '"
cFilTop +=  " AND VV0_OPEMOV = '2'"
cFilTop +=  " AND VV0_SITNFI = '1'"
If cPaisLoc == "ARG"
	cFilTop +=  " AND VV0_REMITO <> ' '" // Transferencia trabalha apenas com Remito
Else
	cFilTop +=  " AND VV0_NUMNFI <> ' '"
EndIf
cFilTop +=  " ) "
//
aAdd(aOpcoes,{STR0003,"VXA004VIS()"}) // Visualizar Saida por Transferencia
aAdd(aOpcoes,{STR0012,"VXA004TRF('"+cFilAnt+"')"}) // Transferir
//
FGX_LBBROW(cCadastro,"VV0",aOpcoes,cFilTop,cOrdVV0,"VV0_DATMOV")
//
cFilAnt := cFilAntBkp
//
aRotina := aClone(aRotinaX)
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA004FIL ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa o filtro do browse das SAIDAS de veiculo por transferencia     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004FIL()
Local lVldSA1 := .f.
Local lRet := .f.
//
SA1->(DbSetOrder(1))
SA1->(DBSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA))
//
If cPaisLoc == "ARG"
	lVldSA1 := ( SA1->A1_COD+SA1->A1_LOJA == cCdCliA+cLjCliA )
Else
	lVldSA1 := ( SA1->A1_CGC == cCGCSM0 )
EndIf
// Verifica se o cliente da transf. e' a filial atual
If lVldSA1
	VVA->(DbSetOrder(1))
	VVA->(DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA))	
	VV1->(DbSetOrder(2))
	VV1->(DBSeek(xFilial("VV1")+VVA->VVA_CHASSI))
	// Verifica se a ultima movimentacao do veiculo foi o VV0 em questao ( SAIDA por Transferencia ) //
	If VV1->VV1_ULTMOV == "S" .and. VV1->VV1_FILSAI == VV0->VV0_FILIAL .and. VV1->VV1_NUMTRA == VV0->VV0_NUMTRA
		lRet := .t.
	EndIf
EndIf
//
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA004TRF ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz verificacoes finais e executa a transferencia via integracao com   ³±±
±±³          ³ o programa VEIXX000                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004TRF(c_xFil)
Local xAutoCab := {}
Local xAutoItens := {}
Local cLocPad, cLocaliz, lLocaliz
// Declaracao da ParamBox
Local aRet := {}
Local aParamBox := {}
Local aRetSelVei := {}
Local aSM0 := {}
Local nPosVet := 0
Local cQuery  := ""
Local lVldSA2 := .f.
Local aCliARG := {}
Local cTpFatR := "1" // 1=Fatura

Local lVVF_VEICU1 := ( VVF->(FieldPos("VVF_VEICU1")) > 0 )
Local lVVF_VEICU2 := ( VVF->(FieldPos("VVF_VEICU2")) > 0 )
Local lVVF_VEICU3 := ( VVF->(FieldPos("VVF_VEICU3")) > 0 )
Local lContabil   := ( VVG->(FieldPos("VVG_CENCUS")) > 0 .and. VVG->(FieldPos("VVG_CONTA")) > 0 .and. VVG->(FieldPos("VVG_ITEMCT")) > 0 .and. VVG->(FieldPos("VVG_CLVL")) > 0 ) // Campos para a contabilizacao das ENTRADAS de Veiculos
//
Local oFornece   := OFFornecedor():New()
//
Local lVVF_PLACA := ( VVF->(FieldPos("VVF_PLACA")) > 0 )

Default c_xFil := cFilAnt

cFilAnt := c_xFil

// Posiciona do SM0 para obter o CGC da filial que ORIGINOU a transferencia (saida)

aSM0 := FWArrFilAtu(cEmpAnt,VV0->VV0_FILIAL) 

if Len(aSM0) == 0 
	MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0014)//A Filial nro. ### nao encontrada. Impossivel continuar
	Return .f.
endif

cCGC := aSM0[18]

DBSelectArea("SA2")
If cPaisLoc == "ARG"
	aCliARG := FGX_SM0SA1(VV0->VV0_FILIAL) // Retorna o Cliente/Loja correspondete ao VV0->VV0_FILIAL
	cQuery := "SELECT R_E_C_N_O_ AS RECSA2 "
	cQuery += "  FROM " + RetSQLName("SA2") 
	cQuery += " WHERE A2_FILIAL  = '"+xFilial("SA2")+"'"
	cQuery += "   AND A2_CLIENTE = '"+aCliARG[1]+"'"
	cQuery += "   AND A2_LOJCLI  = '"+aCliARG[2]+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecSA2 := FM_SQL(cQuery)
	If nRecSA2 > 0
		SA2->(DbGoto(nRecSA2))
		lVldSA2 := .t.
	EndIf
Else
	SA2->(DBSetOrder(3))
	lVldSA2 := SA2->(DBSeek(xFilial("SA2")+cCGC))
EndIf

// Pesquisa o fornecedor pelo CGC da filial que ORIGINOU a transferencia (saida)
if !lVldSA2
	MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0016+": " + cCGC+ " "+STR0017)//A Filial nro. ### CGC ### nao foi encontrada no cadastro de fornecedores. Favor cadastrar
	Return .f.
Else
	If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
		Return .f.
	EndIf
endif
If &cBrwCond2 // Condicao do Browse 2, validar a Transferencia
	aAdd(aParamBox,{1,STR0018,SA2->A2_COD,"","","",".F.",60,.T.})//Fornecedor
	aAdd(aParamBox,{1,STR0019,SA2->A2_LOJA,"","","",".F.",30,.T.})//Loja
	aAdd(aParamBox,{1,STR0020,Left(SA2->A2_NOME,20),"","","",".F.",120,.T.})//Nome
	If cPaisLoc == "ARG"
		aAdd(aParamBox,{1,RetTitle("VV0_REMITO"),VV0->VV0_REMITO,"","","",".F.",60,.T.})//Remito
		aAdd(aParamBox,{1,RetTitle("VV0_SERREM"),VV0->VV0_SERREM,"","","",".F.",30,.T.})//Serie do Remito
	Else
		aAdd(aParamBox,{1,STR0021,VV0->VV0_NUMNFI,"","","",".F.",60,.T.})//Nota Fiscal
		aAdd(aParamBox,{1,STR0022,VV0->VV0_SERNFI,"","","",".F.",30,.T.})//Serie
	EndIf
	aAdd(aParamBox,{1,RetTitle("VVG_OPER"),Space(TamSX3("VVG_OPER")[1]),"","VAZIO() .OR. VXA004OPER(VV0->VV0_FILIAL,VV0->VV0_NUMTRA,MV_PAR06,cCGC)","DJ","",40,.f.})//OPER

	nPosVet := 7 // Posição do Vetor Retorno dos Parametros ( 7 = VVF_ESPECI )
	aAdd(aParamBox,{1,RetTitle("VVF_ESPECI"),space(TamSX3("VVF_ESPECI")[1]),VVF->(X3Picture("VVF_ESPECI")),"Vazio() .or. ExistCpo('SX5','42'+MV_Par07)","42","",80,X3Obrigat("VVF_ESPECI")}) // Especie da NF

	If cPaisLoc == "BRA"
		nPosVet++
		aAdd(aParamBox,{1,STR0026,VXA004CNFE(VV0->VV0_FILIAL,VV0->VV0_NUMNFI , VV0->VV0_SERNFI , VV0->VV0_CODCLI , VV0->VV0_LOJA, VV0->VV0_DATEMI),VVF->(X3Picture("VVF_CHVNFE")),"VXVlChvNfe('0',Mv_Par07)","","",120,.F.})//Chave da NFE
	EndIf
	nPosVet++
	aAdd(aParamBox,{1,RetTitle("VVF_TRANSP"),Space(TAMSX3("VVF_TRANSP")[1]),/*X3Picture("VVF_TRANSP")*/,,"SA4"	,"",30,.f.}) 
	nPosVet++
	aAdd(aParamBox,{1,RetTitle("VVF_PLIQUI"),0,X3Picture("VVF_PLIQUI"),,""		,"",50,.f.}) 
	nPosVet++
	aAdd(aParamBox,{1,RetTitle("VVF_PBRUTO"),0,X3Picture("VVF_PBRUTO"),,""		,"",50,.f.}) 
	nPosVet++
	aAdd(aParamBox,{1,RetTitle("VVF_VOLUM1"),0,X3Picture("VVF_VOLUM1"),,""		,"",30,.f.})
	nPosVet++
	aAdd(aParamBox,{1,RetTitle("VVF_ESPEC1"),space(TamSX3("VVF_ESPEC1")[1]),VVF->(X3Picture("VVF_ESPEC1")),"","","",50,.f.}) // Especie 1
	nPosVet++
	aAdd(aParamBox,{1,RetTitle("VVF_TOTFRE"),VV0->VV0_VALFRE,X3Picture("VVF_TOTFRE"),,"","",50,.f.}) 
	nPosVet++
	aAdd(aParamBox,{1,RetTitle("VVF_NATURE"),VV0->VV0_NATFIN,"","Vazio() .or. FinVldNat( .F. )","SED","",80,.F.}) // Natureza

	If lVVF_VEICU1
		nPosVet++
		aAdd(aParamBox, {1, RetTitle("VVF_VEICU1"), space(TamSX3("VVF_VEICU1")[1]), VVF->(X3Picture("VVF_VEICU1")), "", "DA3", "", 50, .f.}) // Veículo 1
	EndIf
	If lVVF_VEICU2
		nPosVet++
		aAdd(aParamBox, {1, RetTitle("VVF_VEICU2"), space(TamSX3("VVF_VEICU2")[1]), VVF->(X3Picture("VVF_VEICU2")), "", "DA3", "", 50, .f.}) // Veículo 2
	EndIf
	If lVVF_VEICU3
		nPosVet++
		aAdd(aParamBox, {1, RetTitle("VVF_VEICU3"), space(TamSX3("VVF_VEICU3")[1]), VVF->(X3Picture("VVF_VEICU3")), "", "DA3", "", 50, .f.}) // Veículo 3
	EndIf

	nPosVet++
	aAdd(aParamBox,{11,RetTitle("VVF_OBSENF"),space(200),"","",.f.}) // MV_PAR16 ou MV_PAR19
	nPosMemo := nPosVet

	//Placa do Veículo Transportador (Integração MATA103 - CI 012236)
	If lVVF_PLACA
		nPosVet++
		aAdd(aParamBox, {1, RetTitle("VVF_PLACA"), space(TamSX3("VVF_PLACA")[1]), VVF->(X3Picture("VVF_PLACA")), "", "DA302", "", 50, .f.})
	EndIf
	
	//
	lPassou := .f.
	while !lPassou
		lPassou := .t.
		//
		aRetSelVei := FGX_SELVEI("VV0",STR0017,VV0->VV0_FILIAL,VV0->VV0_NUMTRA,aParamBox, 'VA0004001B_ValidaTES')
		//
		If Len(aRetSelVei) == 0 //!(ParamBox(aParamBox,STR0017,@aRet,,,,,,,,.f.)) //Dados do Retorno de Remessa
			Return .f.
		Endif
	Enddo
	//
	aRetSelVei[1,nPosMemo] := &("MV_PAR"+strzero(nPosMemo,2)) // Prencher MEMO no Vetor de Retorno da Parambox
    //
    
	lLocaliz := .f.
	// USA LOCALIZACAO DE VEICULOS
	if GetNewPar("MV_LOCVZL","N")=="S" .and. VVG->(FieldPos("VVG_LOCALI")) <> 0
		lLocaliz := .t.
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array de integracao com o VEIXX000                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(xAutoCab,{"VVF_FILIAL"  ,xFilial("VVF")		,Nil})
	aAdd(xAutoCab,{"VVF_FORPRO"  ,"0"   		 		,Nil})
	aAdd(xAutoCab,{"VVF_CLIFOR"  ,"F" 					,Nil})
	If cPaisLoc == "ARG"
		aAdd(xAutoCab,{"VVF_NUMNFI"  ,VV0->VV0_REMITO	,Nil})
		aAdd(xAutoCab,{"VVF_SERNFI"  ,VV0->VV0_SERREM	,Nil})
	Else
		aAdd(xAutoCab,{"VVF_NUMNFI"  ,VV0->VV0_NUMNFI	,Nil})
		aAdd(xAutoCab,{"VVF_SERNFI"  ,VV0->VV0_SERNFI	,Nil})
	EndIf
	aAdd(xAutoCab,{"VVF_CODFOR"  ,SA2->A2_COD			,Nil})
	aAdd(xAutoCab,{"VVF_LOJA "   ,SA2->A2_LOJA			,Nil})
	aAdd(xAutoCab,{"VVF_FORPAG"  ,VV0->VV0_FORPAG  		,Nil})
	aAdd(xAutoCab,{"VVF_DATEMI"  ,VV0->VV0_DATMOV		,Nil})

	nPosVet := 7 // Posição do Vetor Retorno dos Parametros ( 7 = VVF_ESPECI )
	
	aAdd(xAutoCab,{"VVF_ESPECI"  ,aRetSelVei[1,nPosVet++],Nil})
	If cPaisLoc == "BRA"
		aAdd(xAutoCab,{"VVF_CHVNFE"  ,aRetSelVei[1,nPosVet++]	,Nil})
	EndIf
	aAdd(xAutoCab,{"VVF_TRANSP"  ,aRetSelVei[1,nPosVet++]	,Nil})
	aAdd(xAutoCab,{"VVF_PLIQUI"  ,aRetSelVei[1,nPosVet++]	,Nil})
	aAdd(xAutoCab,{"VVF_PBRUTO"  ,aRetSelVei[1,nPosVet++]	,Nil})
	aAdd(xAutoCab,{"VVF_VOLUM1"  ,aRetSelVei[1,nPosVet++]	,Nil})
	aAdd(xAutoCab,{"VVF_ESPEC1"  ,aRetSelVei[1,nPosVet++]	,Nil})
	aAdd(xAutoCab,{"VVF_TOTFRE"  ,aRetSelVei[1,nPosVet++]	,Nil})

	If !Empty(aRetSelVei[1,nPosVet])
		aAdd(xAutoCab,{"VVF_NATURE"  ,aRetSelVei[1,nPosVet],Nil})
	elseif !Empty(VV0->VV0_NATFIN)
		aAdd(xAutoCab,{"VVF_NATURE"  ,VV0->VV0_NATFIN	,Nil})
	endif
	nPosVet++

	// Veículo Transportador (Integração MATA103 - CI 008022)
	If lVVF_VEICU1
		aAdd(xAutoCab,{"VVF_VEICU1" ,aRetSelVei[1,nPosVet++],Nil})
	EndIf
	If lVVF_VEICU2
		aAdd(xAutoCab,{"VVF_VEICU2" ,aRetSelVei[1,nPosVet++],Nil})
	EndIf
	If lVVF_VEICU3
		aAdd(xAutoCab,{"VVF_VEICU3" ,aRetSelVei[1,nPosVet++],Nil})
	EndIf

	aAdd(xAutoCab,{"VVF_OBSENF"  ,aRetSelVei[1,nPosVet++]		,Nil})

	//Placa do Veículo Transportador (Integração MATA103 - CI 012236)
	If lVVF_PLACA
		aAdd(xAutoCab,{"VVF_PLACA" ,aRetSelVei[1,nPosVet++],Nil})
	EndIf
	
	//
	DBSelectArea("VVA")
	DBSetOrder(4)
	DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA)
	//
	nVeic := 0
	cStr  := STR0028 + CRLF
	cStr  += Repl("-",40) +CRLF
	while !eof() .and. VV0->VV0_FILIAL+VV0->VV0_NUMTRA == VVA->VVA_FILIAL + VVA->VVA_NUMTRA
	
		DBSelectArea("VV1")
		DBSetOrder(2)
		DBSeek(xFilial("VV1")+VVA->VVA_CHASSI)
		cGruVei := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VVA->VVA_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))

		if lLocaliz
			VZL->(DBSetOrder(1))
			aParamBox := {}
			aRet := {}
			MV_PAR01 := ""
			MV_PAR02 := ""
			M->VVG_LOCPAD := VV1->VV1_LOCPAD // Variavel utilizada na consulta padrao VZL
			aAdd(aParamBox,{1,RetTitle("VVG_LOCPAD"),VV1->VV1_LOCPAD,"","VXA004VLOC()","NNR","",0,X3Obrigat("VVG_LOCPAD")})
			aAdd(aParamBox,{1,RetTitle("VVG_LOCALI"),Space(TamSX3("VVG_LOCALI")[1]),"","VZL->(DBSeek(xFilial('VZL')+MV_PAR01+MV_PAR02))","VZL","",0,X3Obrigat("VVG_LOCALI")})
			If !(ParamBox(aParamBox,STR0025+Alltrim(VVA->VVA_CHASSI),@aRet,,,,,,,,.F.))
				Return .f.
			endif
			cLocPad := aRet[1]
			cLocaliz := aRet[2]
		else
			cLocPad := VV1->VV1_LOCPAD
			cLocaliz := ""
		Endif
	   nVeic := Ascan(aRetSelVei[2],{|x| x[4] == VVA->VVA_CHASSI })
		If nVeic == 0
			/*+----------------------------------------------------------------------------+
			  | Marcelo Iuspa em 15/01/2025                                                |
			  | DVARMIL-7068 - Error.log em Entrada por Transferência (aScan retorna zero) |
			  +----------------------------------------------------------------------------+*/
			FMX_HELP("CHASSI_NE", STR0032 + CRLF + RetTitle("VV1_CHASSI") + " " + VVA->VVA_CHASSI, STR0033)  //  "O chassi abaixo não foi encontrado na tabela de veículos (VV1)" // "Verifique se o chassi está preenchido ou se estão corretamente relacionadas nas tabelas Cadastro de Veículos (VV1) e Itens das Saídas de Veículos (VVA)"
			Return(.F.)
		Endif

		xAutoIt := {}
		aAdd(xAutoIt,{"VVG_FILIAL"  ,xFilial("VVG")		,Nil})
		aAdd(xAutoIt,{"VVG_CHASSI"  ,VVA->VVA_CHASSI 	,Nil})
		aAdd(xAutoIt,{"VVG_CODTES"  ,aRetSelVei[2,nVeic,3]			,Nil})
		aAdd(xAutoIt,{"VVG_LOCPAD"  ,cLocPad			,Nil})
		if lLocaliz
			aAdd(xAutoIt,{"VVG_LOCALI"  ,cLocaliz		,Nil})
		endif
		aAdd(xAutoIt,{"VVG_VALUNI"  ,VVA->VVA_VALMOV	,Nil})
		aAdd(xAutoIt,{"VVG_PICOSB"  ,"0"				,Nil})

		If lContabil
			if Len(aRetSelVei[2,nVeic]) > 7
				aAdd(xAutoIt,{"VVG_CENCUS",aRetSelVei[2,nVeic,8]	,Nil})
				aAdd(xAutoIt,{"VVG_CONTA" ,aRetSelVei[2,nVeic,9]	,Nil})
				aAdd(xAutoIt,{"VVG_ITEMCT",aRetSelVei[2,nVeic,10]	,Nil})
				aAdd(xAutoIt,{"VVG_CLVL"  ,aRetSelVei[2,nVeic,11]	,Nil})
			EndIf
		EndIf
		//
		aAdd(xAutoItens,xAutoIt)
		cStr += Left(VVA->VVA_CHASSI + SPACE(30),30) + Right(SPACE(20)+Transform(VVA->VVA_VALMOV,"@E 999,999,999.99"),20) + CRLF
		DBSelectArea("VVA")
		DBSkip()

	enddo
	cStr  += Repl("-",40) +CRLF
	cStr  += STR0029+"           " + Transform(VV0->VV0_VALTOT,"@E 999,999,999.99") + CRLF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a integracao com o VEIXX000                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	lMsErroAuto := .f.
	//
	if !MsgYesNo(cStr)
		Return .f.
	endif
	If cPaisLoc == "ARG"
		cTpFatR := "2" // 2=Remito (SEMPRE REMITO PARA TRANSFERENCIA)
	EndIf
	MSExecAuto({|x,y,w,z,k,a| VEIXX000(x /* xAutoCab */ , y /* xAutoItens */ , w /* xAutoCP */ , z /* nOpc */ , k /* xOpeMov */ , /* xAutoAux */ , /* xMostraMsg */ , /* xSX5NumNota */ , /* xTIPDOC */ , /* xCodVDV */ , "VEIXA004" /* cRotOrigem */ , a /* cTpFatR */ )},xAutoCab,xAutoItens,{},3,"3",cTpFatR)
	//
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		Return .f.
	EndIf
EndIf
VV0->(dbGotop())
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004OPER³Autor ³Manoel                             ³ Data ³ 09/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validação da Operação e Retorno da TES                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004OPER(_cFilTI , _cNroTI , _cCodOperTI , _cCGCForTI )
Local aArea  := GetArea()
Local ii  := 0

If !ExistCpo("SX5","DJ"+_cCodOperTI)
	Return .F.
Else
	For ii = 1 to Len(aIteVei)
		DBSelectArea("VVA")
		DBSetOrder(1)
		DBSeek(_cFilTI + _cNroTI)
		DBSelectArea("SB1")
		DBSetOrder(7)
		If FGX_VV1SB1("CHAINT", aIteVei[ii,7] , /* cMVMIL0010 */ , cGruVei )
			cTes := MaTesInt(1,_cCodOperTI,SA2->A2_COD,SA2->A2_LOJA,"F",SB1->B1_COD)

			If !Empty(cTes)
				If VA0004001B_ValidaTES(cTes, aIteVei, ii, aIteVei[ii, 4])
					aIteVei[ii,3] := cTes
				else
					Return .F.
				Endif
			Endif
		Endif
	Next

	oLbIteVei:refresh()

Endif
    
RestArea( aArea )

Return .T.       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA004VLOC  ³ Autor ³ Rubens                         ³ Data ³ 14/04/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da Localizacao na Parambox                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004VLOC()

Local lRetorno

VZL->(dbSetOrder(1))
lRetorno := VZL->(DBSeek(xFilial('VZL')+MV_PAR01))

M->VVG_LOCPAD := MV_PAR01

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Entrada de Veiculos por Transferencia                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { ;
{ OemtoAnsi(STR0002) ,"AxPesqui" , 0 , 1},;			// Pesquisar
{ OemtoAnsi(STR0003) ,"VXA004_V"     		, 0 , 2},;		// Visualizar
{ OemtoAnsi(STR0004) ,"VXA004_I"    		, 0 , 3,,.f.},;		// Devolver
{ OemtoAnsi(STR0005) ,"VXA004_C"    	 	, 0 , 5,,.f.},;		// Cancelar
{ OemtoAnsi(STR0006) ,"VXA004LEG" 	 	, 0 , 6},;		// Legenda
{ OemtoAnsi(STR0007) ,"FGX_PESQBRW('E','3')" , 0 , 1}}	// Pesquisa Avancada ( E-Entrada por 3-Transferencia )

If cPaisLoc == "BRA"
	aAdd(aRotina,{ OemtoAnsi(STR0034) ,"VXA004_D" , 0 , 3,,.f.}) // "Devolver"
	aAdd(aRotina,{ OemtoAnsi(STR0035) ,"VXA004_R" , 0 , 3,,.f.}) // "Retornar"
EndIf

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA004LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Entrada de Veiculos por Transferencia                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004LEG()
Local aLegenda := {;
{'BR_VERDE',STR0008},;
{'BR_VERMELHO',STR0009},;
{'BR_PRETO',STR0010}}
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA004VIS ³ Autor ³ Manoel                            ³ Data ³ 07/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a vizualização da Nota de Transferencia de Saida                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004VIS()
// Declaracao da ParamBox
Local aSM0 := {}   
Local lRet := .t.
Local cQuery  := ""
Local lVldSA2 := .f.
Local aCliARG := {}

c_xFil := VV0->VV0_FILIAL

//
cFilBkp := cFilAnt
cFilAnt := c_xFil

// Posiciona do SM0 para obter o CGC da filial que ORIGINOU a transferencia (saida)

aSM0 := FWArrFilAtu(cEmpAnt,VV0->VV0_FILIAL) 

if Len(aSM0) == 0 
	MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0014)//A Filial nro. ### nao encontrada. Impossivel continuar
	Return .f.
endif

cCGC := aSM0[18]

DBSelectArea("SA2")
If cPaisLoc == "ARG"
	aCliARG := FGX_SM0SA1(VV0->VV0_FILIAL) // Retorna o Cliente/Loja correspondete ao VV0->VV0_FILIAL
	cQuery := "SELECT R_E_C_N_O_ AS RECSA2 "
	cQuery += "  FROM " + RetSQLName("SA2") 
	cQuery += " WHERE A2_FILIAL  = '"+xFilial("SA2")+"'"
	cQuery += "   AND A2_CLIENTE = '"+aCliARG[1]+"'"
	cQuery += "   AND A2_LOJCLI  = '"+aCliARG[2]+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	nRecSA2 := FM_SQL(cQuery)
	If nRecSA2 > 0
		SA2->(DbGoto(nRecSA2))
		lVldSA2 := .t.
	EndIf
Else
	SA2->(DBSetOrder(3))
	lVldSA2 := SA2->(DBSeek(xFilial("SA2")+cCGC))
EndIf

// Pesquisa o fornecedor pelo CGC da filial que ORIGINOU a transferencia (saida)
if !lVldSA2
	MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0016+": " + cCGC+ " "+STR0017)//A Filial nro. ### CGC ### nao foi encontrada no cadastro de fornecedores. Favor cadastrar
	Return .f.
endif
//
DBSelectArea("VV0")
cAlias := "VV0"
nReg := VV0->( recno() )
nOpc := 2
lRet = VEIXX001(NIL,NIL,NIL,nOpc,"2")
//
cFilAnt := cFilBkp
Return lRet


Function VA0004001B_ValidaTES(cTES, aItevei, nLha, cChassi)
	Local cFilBkp := cFilAnt
	Local cEstoque
	DBSelectArea("SF4")
	DBSetOrder(1)
	DBSeek(xFilial("SF4")+cTes)
	cEstoque := SF4->F4_ESTOQUE
	DBSelectArea("VVA")
	DBSetOrder(1)
	DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA+cChassi)
	
	cFilAnt := VV0->VV0_FILIAL // Mudar cFilAnt pq o Cadastro de TES pode ser EXCLUSIVO
	DBSelectArea("SF4")
	DBSetOrder(1)
	DBSeek(xFilial("SF4")+VVA->VVA_CODTES)
	cFilAnt := cFilBkp

	if SF4->F4_ESTOQUE == "S"
		cMsg := STR0030
	else
		cMsg := STR0031
	endif
	if cEstoque != SF4->F4_ESTOQUE
		MsgInfo(STR0023 + cMsg, STR0011)
		return .F.
	endif
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VVXA004CNFE³Autor ³Jose Luis                         ³ Data ³ 05/08/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a chave eletrônica da Nota Fiscal de Saida por Transferencia   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004CNFE(_cFilial, _cDocNfe , _cSerNfe , _cCodCli , _cCodLoj, _dDatEmis )
Local cQuery := ""
Local cChvNfe := ""

	cQuery := "SELECT F2_CHVNFE FROM " + RetSqlName('SF2')
	cQuery += " WHERE F2_FILIAL = '" + _cFilial + "' "
	cQuery += "   AND F2_DOC = '"+ _cDocNfe +"' AND F2_SERIE = '"+ _cSerNfe +"'"
	cQuery += "   AND F2_CLIENTE = '"+ _cCodCli +"' AND F2_LOJA = '"+ _cCodLoj +"'"
	cQuery += "   AND F2_EMISSAO = '"+ DtoS(_dDatEmis) +"'
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cChvNfe := FM_SQL(cQuery)

Return cChvNfe

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA009BRWVV0³ Autor ³Andre Luis Almeida / Luis Delorme³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem do Browse com as SAIDAS de Veiculos por Transferencia         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA004RET()

	Local aRotinaX := aClone(aRotina)
	Local aSM0     := {}
	Local aOpcoes  := {}
	Local cOrdVV0  := "VV0_FILIAL,VV0_NUMNFI,VV0_SERNFI"

	Private cBrwCond2 := 'VV0->VV0_OPEMOV$ "2" .AND. VV0->VV0_SITNFI=="1" .AND. VV0->VV0_TIPO == "D" .AND. !Empty(VV0->VV0_NUMNFI)' // Condicao do Browse, validar ao Incluir/Alterar/Excluir

	aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
	cCGCSM0 := aSM0[18]
	cCdCliA := ""
	cLjCliA := ""
	dbSelectArea("VV0")
	dbSetOrder(4)

	cFilTop := "VV0.R_E_C_N_O_ IN ( SELECT VV0.R_E_C_N_O_ "
	cFilTop += " FROM " + RetSQLName("SA2") + " A2 JOIN "+RetSQLName("VV0")+" VV0 ON VV0_FILIAL <> '" + xFilial("VV0") + "' AND VV0_CODCLI = A2_COD AND VV0_LOJA = A2_LOJA AND VV0_TIPO = 'D' AND VV0.D_E_L_E_T_ = ' '"
	cFilTop += " JOIN " + RetSQLName("VVA") + " VVA ON VVA_FILIAL = VV0_FILIAL AND VVA_NUMTRA = VV0_NUMTRA AND VVA.D_E_L_E_T_ = ' '"
	cFilTop += " JOIN " + RetSQLName("VV1") + " VV1 ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = VVA.VVA_CHAINT AND VV1.VV1_FILSAI = VV0_FILIAL AND VV1.VV1_NUMTRA = VV0_NUMTRA AND VV1.VV1_SITVEI = '2' "
	cFilTop += " AND VV1.VV1_ULTMOV = 'S'"
	cFilTop += " AND VV1.D_E_L_E_T_ = ' '"
	cFilTop += " WHERE A2.A2_FILIAL = '"+xFilial("SA2")+"'"
	cFilTop +=  " AND A2.A2_CGC = '" + cCGCSM0 + "'"
	cFilTop +=  " AND A2.D_E_L_E_T_ = ' '"
	cFilTop +=  " AND VV0_OPEMOV = '2'"
	cFilTop +=  " AND VV0_SITNFI = '1'"
	cFilTop +=  " AND VV0_NUMNFI <> ' '"
	cFilTop +=  " ) "

	aAdd(aOpcoes,{STR0035,"VA0040025_ConfirmaRetorno('"+cFilAnt+"')"}) // "Retornar"

	FGX_LBBROW(cCadastro,"VV0",aOpcoes,cFilTop,cOrdVV0,"VV0_DATMOV")

	cFilAnt := cFilAntBkp

	aRotina := aClone(aRotinaX)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VA0040002 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz verificacoes finais e executa a transferencia via integracao com   ³±±
±±³          ³ o programa VEIXX000                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA0040025_ConfirmaRetorno(c_xFil)

	Local xAutoCab := {}
	Local xAutoItens := {}
	Local cLocPad, cLocaliz, lLocaliz
	// Declaracao da ParamBox
	Local aRet := {}
	Local aParamBox := {}
	Local aRetSelVei := {}
	Local aSM0 := {}
	Local nPosVet := 0
	Local lVldSA2 := .f.

	Local lVVF_VEICU1 := ( VVF->(FieldPos("VVF_VEICU1")) > 0 )
	Local lVVF_VEICU2 := ( VVF->(FieldPos("VVF_VEICU2")) > 0 )
	Local lVVF_VEICU3 := ( VVF->(FieldPos("VVF_VEICU3")) > 0 )
	Local lContabil   := ( VVG->(FieldPos("VVG_CENCUS")) > 0 .and. VVG->(FieldPos("VVG_CONTA")) > 0 .and. VVG->(FieldPos("VVG_ITEMCT")) > 0 .and. VVG->(FieldPos("VVG_CLVL")) > 0 ) // Campos para a contabilizacao das ENTRADAS de Veiculos
	//
	Local oFornece   := OFFornecedor():New()
	//
	Local lVVF_PLACA := ( VVF->(FieldPos("VVF_PLACA")) > 0 )

	Local xAutoAux    := {}

	Default c_xFil := cFilAnt

	cFilAnt := c_xFil

	// Posiciona do SM0 para obter o CGC da filial que ORIGINOU a transferencia (saida)

	aSM0 := FWArrFilAtu(cEmpAnt,VV0->VV0_FILIAL) 

	if Len(aSM0) == 0 
		MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0014)//A Filial nro. ### nao encontrada. Impossivel continuar
		Return .f.
	endif

	cCGC := aSM0[18]

	DBSelectArea("SA2")
	SA2->(DBSetOrder(3))
	lVldSA2 := SA2->(DBSeek(xFilial("SA2")+cCGC))

	// Pesquisa o fornecedor pelo CGC da filial que ORIGINOU a transferencia (saida)
	if !lVldSA2
		MsgStop(STR0013+" "+VV0->VV0_FILIAL + " "+STR0016+": " + cCGC+ " "+STR0017)//A Filial nro. ### CGC ### nao foi encontrada no cadastro de fornecedores. Favor cadastrar
		Return .f.
	Else
		If oFornece:Bloqueado( SA2->A2_COD , SA2->A2_LOJA , .T. ) // Fornecedor Bloqueado ?
			Return .f.
		EndIf
	endif

	If &cBrwCond2 // Condicao do Browse 2, validar a Transferencia
		aAdd(aParamBox,{1,STR0018,SA2->A2_COD,"","","",".F.",60,.T.})//Fornecedor
		aAdd(aParamBox,{1,STR0019,SA2->A2_LOJA,"","","",".F.",30,.T.})//Loja
		aAdd(aParamBox,{1,STR0020,Left(SA2->A2_NOME,20),"","","",".F.",120,.T.})//Nome

		aAdd(aParamBox,{1,STR0021,VV0->VV0_NUMNFI,"","","",".F.",60,.T.})//Nota Fiscal
		aAdd(aParamBox,{1,STR0022,VV0->VV0_SERNFI,"","","",".F.",30,.T.})//Serie

		aAdd(aParamBox,{1,RetTitle("VVG_OPER"),Space(TamSX3("VVG_OPER")[1]),"","VAZIO() .OR. VXA009OPER(VV0->VV0_FILIAL,VV0->VV0_NUMTRA,MV_PAR06,cCGC)","DJ","",40,.f.})//OPER

		nPosVet := 7 // Posição do Vetor Retorno dos Parametros ( 7 = VVF_ESPECI )
		aAdd(aParamBox,{1,RetTitle("VVF_ESPECI"),space(TamSX3("VVF_ESPECI")[1]),VVF->(X3Picture("VVF_ESPECI")),"Vazio() .or. ExistCpo('SX5','42'+MV_Par07)","42","",80,X3Obrigat("VVF_ESPECI")}) // Especie da NF
		nPosVet++
		aAdd(aParamBox,{1,STR0026,VXA004CNFE(VV0->VV0_FILIAL,VV0->VV0_NUMNFI , VV0->VV0_SERNFI , VV0->VV0_CODCLI , VV0->VV0_LOJA, VV0->VV0_DATEMI),VVF->(X3Picture("VVF_CHVNFE")),"VXVlChvNfe('0',Mv_Par07)","","",120,.F.})//Chave da NFE
		nPosVet++
		aAdd(aParamBox,{1,RetTitle("VVF_TRANSP"),Space(TAMSX3("VVF_TRANSP")[1]),/*X3Picture("VVF_TRANSP")*/,,"SA4"	,"",30,.f.}) 
		nPosVet++
		aAdd(aParamBox,{1,RetTitle("VVF_PLIQUI"),0,X3Picture("VVF_PLIQUI"),,""		,"",50,.f.}) 
		nPosVet++
		aAdd(aParamBox,{1,RetTitle("VVF_PBRUTO"),0,X3Picture("VVF_PBRUTO"),,""		,"",50,.f.}) 
		nPosVet++
		aAdd(aParamBox,{1,RetTitle("VVF_VOLUM1"),0,X3Picture("VVF_VOLUM1"),,""		,"",30,.f.})
		nPosVet++
		aAdd(aParamBox,{1,RetTitle("VVF_ESPEC1"),space(TamSX3("VVF_ESPEC1")[1]),VVF->(X3Picture("VVF_ESPEC1")),"","","",50,.f.}) // Especie 1
		nPosVet++
		aAdd(aParamBox,{1,RetTitle("VVF_TOTFRE"),VV0->VV0_VALFRE,X3Picture("VVF_TOTFRE"),,"","",50,.f.}) 
		nPosVet++
		aAdd(aParamBox,{1,RetTitle("VVF_NATURE"),VV0->VV0_NATFIN,"","Vazio() .or. FinVldNat( .F. )","SED","",80,.F.}) // Natureza

		If lVVF_VEICU1
			nPosVet++
			aAdd(aParamBox, {1, RetTitle("VVF_VEICU1"), space(TamSX3("VVF_VEICU1")[1]), VVF->(X3Picture("VVF_VEICU1")), "", "DA3", "", 50, .f.}) // Veículo 1
		EndIf
		If lVVF_VEICU2
			nPosVet++
			aAdd(aParamBox, {1, RetTitle("VVF_VEICU2"), space(TamSX3("VVF_VEICU2")[1]), VVF->(X3Picture("VVF_VEICU2")), "", "DA3", "", 50, .f.}) // Veículo 2
		EndIf
		If lVVF_VEICU3
			nPosVet++
			aAdd(aParamBox, {1, RetTitle("VVF_VEICU3"), space(TamSX3("VVF_VEICU3")[1]), VVF->(X3Picture("VVF_VEICU3")), "", "DA3", "", 50, .f.}) // Veículo 3
		EndIf

		nPosVet++
		aAdd(aParamBox,{11,RetTitle("VVF_OBSENF"),space(200),"","",.f.}) // MV_PAR16 ou MV_PAR19
		nPosMemo := nPosVet

		//Placa do Veículo Transportador (Integração MATA103 - CI 012236)
		If lVVF_PLACA
			nPosVet++
			aAdd(aParamBox, {1, RetTitle("VVF_PLACA"), space(TamSX3("VVF_PLACA")[1]), VVF->(X3Picture("VVF_PLACA")), "", "DA302", "", 50, .f.})
		EndIf

		lPassou := .f.
		while !lPassou
			lPassou := .t.

			aRetSelVei := FGX_SELVEI("VV0",STR0017,VV0->VV0_FILIAL,VV0->VV0_NUMTRA,aParamBox, 'VXA016VTES')

			If Len(aRetSelVei) == 0 //!(ParamBox(aParamBox,STR0017,@aRet,,,,,,,,.f.)) //Dados do Retorno de Remessa
				Return .f.
			Endif
		Enddo

		aRetSelVei[1,nPosMemo] := &("MV_PAR"+strzero(nPosMemo,2)) // Prencher MEMO no Vetor de Retorno da Parambox

		lLocaliz := .f.
		// USA LOCALIZACAO DE VEICULOS
		if GetNewPar("MV_LOCVZL","N")=="S" .and. VVG->(FieldPos("VVG_LOCALI")) <> 0
			lLocaliz := .t.
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de integracao com o VEIXX000                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(xAutoCab,{"VVF_FILIAL"  ,xFilial("VVF")		,Nil})
		aAdd(xAutoCab,{"VVF_FORPRO"  ,"0"   		 		,Nil})
		aAdd(xAutoCab,{"VVF_CLIFOR"  ,"F" 					,Nil})
		aAdd(xAutoCab,{"VVF_NUMNFI"  ,VV0->VV0_NUMNFI	,Nil})
		aAdd(xAutoCab,{"VVF_SERNFI"  ,VV0->VV0_SERNFI	,Nil})
		aAdd(xAutoCab,{"VVF_CODFOR"  ,SA2->A2_COD			,Nil})
		aAdd(xAutoCab,{"VVF_LOJA "   ,SA2->A2_LOJA			,Nil})
		aAdd(xAutoCab,{"VVF_FORPAG"  ,VV0->VV0_FORPAG  		,Nil})
		aAdd(xAutoCab,{"VVF_DATEMI"  ,VV0->VV0_DATMOV		,Nil})

		nPosVet := 7 // Posição do Vetor Retorno dos Parametros ( 7 = VVF_ESPECI )
		
		aAdd(xAutoCab,{"VVF_ESPECI"  ,aRetSelVei[1,nPosVet++],Nil})
		If cPaisLoc == "BRA"
			aAdd(xAutoCab,{"VVF_CHVNFE"  ,aRetSelVei[1,nPosVet++]	,Nil})
		EndIf
		aAdd(xAutoCab,{"VVF_TRANSP"  ,aRetSelVei[1,nPosVet++]	,Nil})
		aAdd(xAutoCab,{"VVF_PLIQUI"  ,aRetSelVei[1,nPosVet++]	,Nil})
		aAdd(xAutoCab,{"VVF_PBRUTO"  ,aRetSelVei[1,nPosVet++]	,Nil})
		aAdd(xAutoCab,{"VVF_VOLUM1"  ,aRetSelVei[1,nPosVet++]	,Nil})
		aAdd(xAutoCab,{"VVF_ESPEC1"  ,aRetSelVei[1,nPosVet++]	,Nil})
		aAdd(xAutoCab,{"VVF_TOTFRE"  ,aRetSelVei[1,nPosVet++]	,Nil})

		If !Empty(aRetSelVei[1,nPosVet])
			aAdd(xAutoCab,{"VVF_NATURE"  ,aRetSelVei[1,nPosVet],Nil})
		elseif !Empty(VV0->VV0_NATFIN)
			aAdd(xAutoCab,{"VVF_NATURE"  ,VV0->VV0_NATFIN	,Nil})
		endif
		nPosVet++

		// Veículo Transportador (Integração MATA103 - CI 008022)
		If lVVF_VEICU1
			aAdd(xAutoCab,{"VVF_VEICU1" ,aRetSelVei[1,nPosVet++],Nil})
		EndIf
		If lVVF_VEICU2
			aAdd(xAutoCab,{"VVF_VEICU2" ,aRetSelVei[1,nPosVet++],Nil})
		EndIf
		If lVVF_VEICU3
			aAdd(xAutoCab,{"VVF_VEICU3" ,aRetSelVei[1,nPosVet++],Nil})
		EndIf

		aAdd(xAutoCab,{"VVF_OBSENF"  ,aRetSelVei[1,nPosVet++]		,Nil})

		//Placa do Veículo Transportador (Integração MATA103 - CI 012236)
		If lVVF_PLACA
			aAdd(xAutoCab,{"VVF_PLACA" ,aRetSelVei[1,nPosVet++],Nil})
		EndIf

		DBSelectArea("VVA")
		DBSetOrder(4)
		DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMTRA)

		nVeic := 0
		cStr  := STR0028 + CRLF
		cStr  += Repl("-",40) +CRLF
		while !eof() .and. VV0->VV0_FILIAL+VV0->VV0_NUMTRA == VVA->VVA_FILIAL + VVA->VVA_NUMTRA
		
			DBSelectArea("VV1")
			DBSetOrder(2)
			DBSeek(xFilial("VV1")+VVA->VVA_CHASSI)
			cGruVei := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VVA->VVA_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))

			if lLocaliz
				VZL->(DBSetOrder(1))
				aParamBox := {}
				aRet := {}
				MV_PAR01 := ""
				MV_PAR02 := ""
				M->VVG_LOCPAD := VV1->VV1_LOCPAD // Variavel utilizada na consulta padrao VZL
				aAdd(aParamBox,{1,RetTitle("VVG_LOCPAD"),VV1->VV1_LOCPAD,"","VXA004VLOC()","NNR","",0,X3Obrigat("VVG_LOCPAD")})
				aAdd(aParamBox,{1,RetTitle("VVG_LOCALI"),Space(TamSX3("VVG_LOCALI")[1]),"","VZL->(DBSeek(xFilial('VZL')+MV_PAR01+MV_PAR02))","VZL","",0,X3Obrigat("VVG_LOCALI")})
				If !(ParamBox(aParamBox,STR0025+Alltrim(VVA->VVA_CHASSI),@aRet,,,,,,,,.F.))
					Return .f.
				endif
				cLocPad := aRet[1]
				cLocaliz := aRet[2]
			else
				cLocPad := VV1->VV1_LOCPAD
				cLocaliz := ""
			Endif

			nVeic := Ascan(aRetSelVei[2],{|x| x[4] == VVA->VVA_CHASSI })
			If nVeic == 0
				/*+----------------------------------------------------------------------------+
				| Marcelo Iuspa em 15/01/2025                                                |
				| DVARMIL-7068 - Error.log em Entrada por Transferência (aScan retorna zero) |
				+----------------------------------------------------------------------------+*/
				FMX_HELP("CHASSI_NE", STR0032 + CRLF + RetTitle("VV1_CHASSI") + " " + VVA->VVA_CHASSI, STR0033)  //  "O chassi abaixo não foi encontrado na tabela de veículos (VV1)" // "Verifique se o chassi está preenchido ou se estão corretamente relacionadas nas tabelas Cadastro de Veículos (VV1) e Itens das Saídas de Veículos (VVA)"
				Return(.F.)
			Endif

			If !FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )
				FMX_HELP("VA002E01", STR0021) // "Veículo não encontrado"
				Return .f.
			EndIf

			xAutoIt := {}
			aAdd(xAutoIt,{"VVG_FILIAL"  ,xFilial("VVG")		,Nil})
			aAdd(xAutoIt,{"VVG_CHASSI"  ,VVA->VVA_CHASSI 	,Nil})
			aAdd(xAutoIt,{"VVG_CODTES"  ,aRetSelVei[2,nVeic,3]			,Nil})
			aAdd(xAutoIt,{"VVG_LOCPAD"  ,cLocPad			,Nil})
			if lLocaliz
				aAdd(xAutoIt,{"VVG_LOCALI"  ,cLocaliz		,Nil})
			endif
			aAdd(xAutoIt,{"VVG_VALUNI"  ,VVA->VVA_VALMOV	,Nil})
			aAdd(xAutoIt,{"VVG_PICOSB"  ,"0"				,Nil})

			If lContabil
				if Len(aRetSelVei[2,nVeic]) > 7
					aAdd(xAutoIt,{"VVG_CENCUS",aRetSelVei[2,nVeic,8]	,Nil})
					aAdd(xAutoIt,{"VVG_CONTA" ,aRetSelVei[2,nVeic,9]	,Nil})
					aAdd(xAutoIt,{"VVG_ITEMCT",aRetSelVei[2,nVeic,10]	,Nil})
					aAdd(xAutoIt,{"VVG_CLVL"  ,aRetSelVei[2,nVeic,11]	,Nil})
				EndIf
			EndIf

			aAdd(xAutoItens,xAutoIt)

			DBSelectArea("SD2")
			DBSetOrder(3)
			If ! DBSeek(VV0->VV0_FILIAL+VV0->VV0_NUMNFI+VV0->VV0_SERNFI+VV0->VV0_CODCLI+VV0->VV0_LOJA+SB1->B1_COD)
				FMX_HELP("VA002E03",STR0022  + CRLF + CRLF + ;
					AllTrim(RetTitle("VV0_NUMNFI")) + ": " + VV0->VV0_NUMNFI + "-" + VV0->VV0_SERNFI + CRLF +;
					AllTrim(RetTitle("VV0_CODCLI")) + ": " + VV0->VV0_CODCLI + "-" + VV0->VV0_LOJA + CRLF + ;
					AllTrim(RetTitle("B1_COD")) + "(SB1): " + SB1->B1_COD)
				Return .f.
			endif

			aAdd(xAutoIt,{"D1_FILORI"  ,SD2->D2_FILIAL,Nil})
			aAdd(xAutoIt,{"D1_NFORI"   ,SD2->D2_DOC,Nil})
			aAdd(xAutoIt,{"D1_SERIORI" ,SD2->D2_SERIE,Nil})
			aAdd(xAutoIt,{"D1_ITEMORI" ,SD2->D2_ITEM,Nil})

			DBSelectArea("SF4")
			DBSetOrder(1)
			DBSeek(xFilial("SF4")+SD2->D2_TES)
			If SF4->F4_PODER3=="D"
				aAdd(xAutoIt,{"D1_IDENTB6" ,SD2->D2_IDENTB6,Nil})
			endif

			aAdd(xAutoAux,xAutoIt)
			cStr += Left(VVA->VVA_CHASSI + SPACE(30),30) + Right(SPACE(20)+Transform(VVA->VVA_VALMOV,"@E 999,999,999.99"),20) + CRLF
			DBSelectArea("VVA")
			DBSkip()

		enddo

		cStr  += Repl("-",40) +CRLF
		cStr  += STR0029+"           " + Transform(VV0->VV0_VALTOT,"@E 999,999,999.99") + CRLF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a integracao com o VEIXX000                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		lMsErroAuto := .f.

		if !MsgYesNo(cStr)
			Return .f.
		endif

		MSExecAuto({|x,y,w,z,k,b | VEIXX000(x /* xAutoCab */ , y /* xAutoItens */ , w /* xAutoCP */ , z /* nOpc */ , k /* xOpeMov */ , b /* xAutoAux */ , /* xMostraMsg */ , /* xSX5NumNota */ , /* xTIPDOC */ , /* xCodVDV */ , "VEIXA004" /* cRotOrigem */ , /* cTpFatR */)},xAutoCab,xAutoItens,{},3,"3",xAutoAux)

		If lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Return .f.
		EndIf

	EndIf

	VV0->(dbGotop())

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VVXA009CNFE³Autor ³Jose Luis                         ³ Data ³ 05/08/22 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a chave eletrônica da Nota Fiscal de Saida por Transferencia   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VXA004DEV(c_xFil)

Local aRotinaX := aClone(aRotina)
Local aOpcoes  := {}
Local cFiltroPrw := '!Empty(VVF->VVF_NUMNFI)'
Local cFiltroSql := "VVF_NUMNFI<> ' '"
Local cOrdemSql  := ""
Private cBrwCond2 := 'VVF->VVF_OPEMOV=="3" .AND. VVF->VVF_SITNFI=="1" .AND. ' + cFiltroPrw + ' .AND. xFilial("VVF")==VVF->VVF_FILIAL .AND. VXA016FIL()' // Condicao do Browse, validar ao Incluir/Alterar/Excluir
//
aAdd(aOpcoes,{STR0034,"VA0040035_ConfirmaDevolucao('"+cFilAnt+"')"}) // Devolver
//
dbSelectArea("VVF")
dbSetOrder(4)
//
cFilTop := "VVF_OPEMOV='3' AND VVF_SITNFI='1' AND " + cFiltroSql + " AND '"+xFilial("VVF")+"' = VVF_FILIAL AND "
cFilTop += "EXISTS ( "
cFilTop += " SELECT VVG.VVG_TRACPA "
cFilTop +=   " FROM "+RetSQLName("VVG")+" VVG "
cFilTop +=          " INNER JOIN "+RetSQLName("VV1")+" VV1 "
cFilTop +=           " ON VV1.VV1_FILIAL  = '"+xFilial("VV1")+"'"
cFilTop +=          " AND VV1.VV1_CHASSI = VVG.VVG_CHASSI "
cFilTop +=          " AND VV1.VV1_ULTMOV = 'E' "
cFilTop +=          " AND VV1.VV1_FILENT = VVG.VVG_FILIAL "
cFilTop +=          " AND VV1.D_E_L_E_T_ = ' ' "
cFilTop +=  " WHERE VVG.VVG_FILIAL = '"+xFilial("VVG")+"'"
cFilTop +=    " AND VVG.VVG_TRACPA = VVF_TRACPA "
cFilTop +=    " AND VVG.D_E_L_E_T_ = ' ' )"

FGX_LBBROW(cCadastro,"VVF",aOpcoes,cFilTop,"VVF_FILIAL,VVF_CODFOR,VVF_LOJA,VVF_NUMNFI,VVF_SERNFI" + cOrdemSql,"VVF_DATMOV")

aRotina := aClone(aRotinaX)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VA0040002 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 19/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz verificacoes finais e executa a transferencia via integracao com   ³±±
±±³          ³ o programa VEIXX000                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA0040035_ConfirmaDevolucao(c_xFil)

	Local xAutoCab := {}
	Local xAutoItens := {}
	Local xAutoAux := {}
	Local nRecVVF := VVF->(RecNo())
	Local nQtdDev := 0
	Local cGruVei  := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1])) // Grupo do Veiculo
	Local lContEst := .T.
	Local lCodTes := .T.
	// Declaracao da ParamBox
	Local aRet := {}
	Local aParamBox := {}
	Local i := 0    
	Local lContabil := ( VVA->(FieldPos("VVA_CENCUS")) > 0 .and. VVA->(FieldPos("VVA_CONTA")) > 0 .and. VVA->(FieldPos("VVA_ITEMCT")) > 0 .and. VVA->(FieldPos("VVA_CLVL")) > 0 ) // Campos para a contabilizacao - VVA

	Local aIndPre  := X3CBOXAVET("VV0_INDPRE","0")
	Local aTipoFre := X3CBOXAVET("VV0_TPFRET","1")

	Local oFornece   := OFFornecedor():New()
	Local cNumero    := "" // Número da nota fiscal de entrada
	Local cSerie     := "" // Série da nota fiscal de entrada

	Private cUsaGrVA := GetNewPar("MV_MIL0010","0") // O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)

	Default c_xFil := cFilAnt

	cFilAnt := c_xFil

	VVF->(dbClearFilter())
	If &cBrwCond2 // Condicao do Browse 2, validar ao Devolver

		If oFornece:Bloqueado( VVF->VVF_CODFOR , VVF->VVF_LOJA , .T. ) // Fornecedor Bloqueado ?
			Return .f.
		EndIf

		aAdd(aParamBox,{2,RetTitle("VV0_INDPRE"),,aIndPre,80,"",.f.}) 

		aAdd(aParamBox,{1,RetTitle("VV0_PESOL" ),0,X3Picture("VV0_PESOL" ),,""		,"",50,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VV0_PBRUTO"),0,X3Picture("VV0_PBRUTO"),,""		,"",50,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VV0_VOLUME"),0,X3Picture("VV0_VOLUME"),,""		,"",40,.f.})
		aAdd(aParamBox,{1,RetTitle("VV0_ESPECI"),Space(TAMSX3("VV0_ESPECI")[1]),/*X3Picture("VV0_ESPECI")*/,,""		,"",40,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VV0_VEICUL"),Space(TAMSX3("VV0_VEICUL")[1]),/*X3Picture("VV0_VEICUL")*/,,"DA3"	,"",40,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VV0_SEGURO"),0,X3Picture("VV0_SEGURO"),,""		,"",60,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VV0_CODTRA"),Space(TAMSX3("VV0_CODTRA")[1]),/*X3Picture("VV0_CODTRA")*/,,"SA4"	,"",40,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VV0_DESACE"),0,X3Picture("VV0_DESACE"),,""		,"",60,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VV0_VALFRE"),0,X3Picture("VV0_VALFRE"),,""		,"",60,.f.}) 
		aAdd(aParamBox,{2,RetTitle("VV0_TPFRET"),,aTipoFre,100,"",.f.}) 
		aAdd(aParamBox,{11,RetTitle("VV0_OBSENF"),space(200),"","",.f.}) // MV_PAR12

		DBSelectArea("SA3")
		DBSetOrder(7)

		if !DBSeek(xFilial("SA3")+__cUserId)
			MsgStop(STR0037,STR0011) //Usuario nao possui registro no cadastro de vendedor. Favor providenciar. ### Atencao
			Return .f.
		endif

		aRet := FGX_SELVEI("VVF",STR0043,VVF->VVF_FILIAL,VVF->VVF_TRACPA,aParamBox,"VXA012VTES") // "Dados da Devolucao"

		If Len(aRet) == 0 
			Return .f.
		Endif

		aRet[1,12] := MV_PAR12 // Prencher MEMO no Vetor de Retorno da Parambox

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array de integracao com o VEIXX001                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd(xAutoCab,{"VV0_FILIAL"  ,xFilial("VVF")		,Nil})
		aAdd(xAutoCab,{"VV0_FORPRO"  ,"1"					,Nil})
		aAdd(xAutoCab,{"VV0_CODCLI"  ,VVF->VVF_CODFOR		,Nil})
		aAdd(xAutoCab,{"VV0_LOJA"    ,VVF->VVF_LOJA			,Nil})
		aAdd(xAutoCab,{"VV0_FORPAG"  ,VVF->VVF_FORPAG		,Nil})
		aAdd(xAutoCab,{"VV0_CODVEN"  ,SA3->A3_COD			,Nil})
		aAdd(xAutoCab,{"VV0_NATFIN"  ,VVF->VVF_NATURE		,Nil})
		aAdd(xAutoCab,{"VV0_INDPRE"  ,aRet[1,1]				,Nil})

		If VV0->(FieldPos("VV0_PESOL")) > 0
			aAdd(xAutoCab,{"VV0_PESOL"   ,aRet[1,2]				,Nil})
		EndIf
		If VV0->(FieldPos("VV0_PBRUTO")) > 0
			aAdd(xAutoCab,{"VV0_PBRUTO"  ,aRet[1,3]				,Nil})
		EndIf
		If VV0->(FieldPos("VV0_VOLUME")) > 0
			aAdd(xAutoCab,{"VV0_VOLUME"  ,aRet[1,4]				,Nil})
		EndIf
		If VV0->(FieldPos("VV0_ESPECI")) > 0
			aAdd(xAutoCab,{"VV0_ESPECI"  ,aRet[1,5]				,Nil})
		EndIf
		If VV0->(FieldPos("VV0_VEICUL")) > 0
			aAdd(xAutoCab,{"VV0_VEICUL"  ,aRet[1,6]				,Nil})
		EndIf
		If VV0->(FieldPos("VV0_SEGURO")) > 0
			aAdd(xAutoCab,{"VV0_SEGURO"  ,aRet[1,7]				,Nil})
		EndIf
		
		aAdd(xAutoCab,{"VV0_CODTRA"  ,aRet[1,8]					,Nil})
		aAdd(xAutoCab,{"VV0_DESACE"  ,aRet[1,9]					,Nil})
		aAdd(xAutoCab,{"VV0_VALFRE"  ,aRet[1,10]				,Nil})
		aAdd(xAutoCab,{"VV0_TPFRET"  ,aRet[1,11]				,Nil})
		aAdd(xAutoCab,{"VV0_OBSENF"  ,aRet[1,12]				,Nil})
		aAdd(xAutoCab,{"VV0_CLIFOR"  ,"F"   					,Nil})
		//
		DBSelectArea("VVG")
		DBSetOrder(1)

		If Len(aRet[2]) == 0
			MsgStop(STR0036,STR0011) //Não existe(m) veiculos(s) para o registro selecionado! ### Atencao
			Return .f.
		Endif

		For i := 1 to Len(aRet[2])

			If aRet[2,i,1] // Veículo está selecionado

				nQtdDev++
				DBSelectArea("VVG")
				DbGoto(aRet[2,i,2])
				cGruVei := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VVG->VVG_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))

				lTemAlgum := .t.
				xAutoIt := {}
				aAdd(xAutoIt,{"VVA_FILIAL"  ,xFilial("VVG")	,Nil})
				aAdd(xAutoIt,{"VVA_CHASSI"  ,VVG->VVG_CHASSI,Nil})
				aAdd(xAutoIt,{"VVA_VALMOV"  ,VVG->VVG_VALUNI,Nil})
				aAdd(xAutoIt,{"VVA_SEGVIA"  ,VVG->VVG_TOTSEG,Nil})
				aAdd(xAutoIt,{"VVA_VALFRE"  ,VVG->VVG_TOTFRE,Nil})
				aAdd(xAutoIt,{"VVA_DESVEI"  ,VVG->VVG_DESACE,Nil})
				aAdd(xAutoIt,{"VVA_CODTES"  ,aRet[2,i,3]	,Nil})
				if lContabil
					aAdd(xAutoIt,{"VVA_CENCUS"  ,aRet[2,i,8],Nil})
					aAdd(xAutoIt,{"VVA_CONTA"   ,aRet[2,i,9],Nil})
					aAdd(xAutoIt,{"VVA_ITEMCT"  ,aRet[2,i,10],Nil})
					aAdd(xAutoIt,{"VVA_CLVL"    ,aRet[2,i,11],Nil})
				Endif
				//
				aAdd(xAutoItens,xAutoIt)

				// MONTA ARRAY AUXILIAR COM INFORMACOES DE CONTROLE DE RETORNO (ITEMSEQ, IDENTB6, ETC)
				xAutoIt := {}
				If !FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )
					FMX_HELP("VA017E01", STR0038 ) //  Veiculo Nao encontrado
					Return .f.
				endif

				If cUsaGrVA == "1" // Usa Veiculos de forma Agrupada por Modelo no SB1
					If !FGX_VV2SB1(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
						MsgStop(STR0039,STR0011) // "Não existe o Produto Agrupado para este Modelo de Veículo no SB1! Impossível Continuar!"
						Return .f.
					Endif
				Endif

				// Número e Série da nota fiscal de entrada
				cNumero := VVF->VVF_NUMNFI
				cSerie  := VVF->VVF_SERNFI

				DBSelectArea("SD1")                             
				DBSetOrder(1)
				if !DBSeek(xFilial("SD1")+cNumero+cSerie+VVF->VVF_CODFOR+VVF->VVF_LOJA+SB1->B1_COD)
					MsgInfo(STR0040,"VA017E02")//"Item da nota de entrada não encontrado"
					Return .f.
				endif

				////////////////////////////////////////////////////////////
				// Verifica se o chassi foi movimentado por outro módulo, o
				// que deixa o veículo sem estoque, no entanto com o Status
				// de Estoque no módulo de Veiculos (VV1_SITVEI)
				////////////////////////////////////////////////////////////
				//Antes verifico se a TES controla estoque.
				lCodTes := VXA012TORI(xFilial("SD1"), cNumero , cSerie , VVF->VVF_CODFOR , VVF->VVF_LOJA, VVF->VVF_DATEMI, SB1->B1_COD)

				DBSelectArea("SF4")
				DBSetOrder(1)
				DBSeek(xFilial("SF4")+aRet[2,i,3])
				lContEst := IIf(SF4->F4_ESTOQUE=="S",.T.,.F.)

				If lContEst # lCodTes // TES (F4_ESTOQUE) diferente entre a Entrada e a Devolução da Entrada
					MsgStop( STR0041 +;
					Chr(13)+Chr(10),STR0011) // "Impossível Continuar! Situação de Estoque do TES da Compra, difere do TES da Devolução!" // Atenção
					Return .f.
				Endif

				DbSelectArea("SB2")
				dbSetOrder(1)
				DBSeek(xFilial("SB2")+SB1->B1_COD+VVG->VVG_LOCPAD)

				If SaldoSB2() <= 0
					MsgStop( STR0042 +;
					Chr(13)+Chr(10)+Left(RetTitle("VV1_CHASSI"),7)+": "+VV1->VV1_CHASSI+Chr(13)+Chr(10)+Left(RetTitle("B5_COD"),7)+": "+SB1->B1_COD, STR0011 ) // "Impossível Continuar! Não existe Saldo Disponivel para esta movimentação! Favor verificar se houve movimentação deste produto fora do Módulo de Veículos!" // Atenção
					Return .f.
				Endif

				aAdd(xAutoIt,{"C6_NFORI"   ,SD1->D1_DOC		,Nil})
				aAdd(xAutoIt,{"C6_SERIORI" ,SD1->D1_SERIE		,Nil})
				aAdd(xAutoIt,{"C6_ITEMORI" ,SD1->D1_ITEM		,Nil})

				aAdd(xAutoAux,xAutoIt)

			Endif
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama a integracao com o VEIXX001                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		lMsErroAuto := .f.

		MSExecAuto({|x,y,w,z,k,l,m| VEIXX001(x /* xAutoCab */ , y /* xAutoItens */ , w /* xAutoCP */ , z /* nOpc */ , k /* xOpeMov */ , l /* xAutoAux */ , /* xMostraMsg */ , /* xSX5NumNota */ , /* xTIPDOC */ , /* xCodVDV */ , m /* cRotOrigem */, /* cTpFatR */ , /* xAutoArg */ )},xAutoCab,xAutoItens,{},3,"2",xAutoAux,"VEIXA014" )

		If !(nQtdDev == Len(aRet[2])) // A Devolucao foi Parcial
			DBSelectArea("VVF")
			DBGoTo(nRecVVF)
			reclock("VVF",.f.)
			VVF->VVF_SITNFI := "1"
			msunlock()
		Endif

		if lMsErroAuto
			DisarmTransaction()
			MostraErro()
			Return .f.
		EndIf

	EndIf

Return .t.