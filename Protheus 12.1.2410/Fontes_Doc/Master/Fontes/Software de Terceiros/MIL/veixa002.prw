// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 31     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "VEIXA002.CH"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIXA002 ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Entrada de Veiculos por Devolucao de Venda                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXA002()
Local cFiltro     := ""
Private cCadastro := STR0001 // Entrada de Veiculos por Devolucao de Venda
Private aRotina   := MenuDef()
Private aCores    := {}
If cPaisLoc $ "ARG|MEX"
	aCores := {;
	{'VVF->VVF_SITNFI == "1" .AND. VVF->VVF_STANCC<>"1"','BR_VERDE'},;		// Valida
	{'VVF->VVF_SITNFI == "1" .AND. VVF->VVF_STANCC=="1"','BR_AMARELO'},;	// Valida sem NCC
	{'VVF->VVF_SITNFI == "0"','BR_VERMELHO'}	}	// Cancelada
Else
	aCores := {;
	{'VVF->VVF_SITNFI == "1"','BR_VERDE'},;		// Valida
	{'VVF->VVF_SITNFI == "0"','BR_VERMELHO'}	}	// Cancelada
EndIf
Private cUsaGrVA := GetNewPar("MV_MIL0010","0") // O Módulo de Veículos trabalhará com Veículos Agrupados por Modelo no SB1 ? (0=Nao / 1=Sim)
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VVF")
dbSetOrder(1)
//
cFiltro := " VVF_OPEMOV='5' " // Filtra as Devolucoes de Venda
//
mBrowse( 6, 1,22,75,"VVF",,,,,,aCores,,,,,,,,cFiltro)
//
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXA002   ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada das Funcoes de Inclusao e Visualizacao e Cancelamento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA002(cAlias,nReg,nOpc)
Local cAliasVV9 := "SQLTMPVV9"
Local cQuery := ""
Local aArea
Local aAreaVV9
//
DBSelectArea("VVF")
If nOpc == 3 // INCLUSAO
	If cPaisLoc $ "ARG|MEX"
		nRecVVFNCC := 0 // Recno do VVF para gerar NCC
	EndIf

	VA002BVV0()

	If cPaisLoc $ "ARG|MEX"
		If nRecVVFNCC > 0 // Gerou a devolução
			If VX0000129_GeraNCC(nRecVVFNCC) // Gera NCC
				aArea := GetArea()
				aAreaVV9 := VV9->(GetArea())

				dbSelectArea("VVF")
				dbGoTo(nRecVVFNCC) // Posiciona no VFF

				cQuery := "SELECT VV9_NUMATE"
				cQuery += " FROM " + RetSqlName("VV9") + " VV9"
				cQuery += " WHERE VV9.D_E_L_E_T_ = ' '"
				cQuery += " AND VV9_STATUS <> 'C'"
				cQuery += " AND VV9_NUMATE IN ("
				cQuery += " SELECT VV0_NUMTRA"
				cQuery += " FROM " + RetSqlName("VV0") + " VV0"
				cQuery += " WHERE VV0_FILIAL = '" + VVF->VVF_FILIAL + "'"
				cQuery += " AND VV0_NUMNFI = '" + VVF->VVF_REMITO + "'"
				cQuery += " AND VV0_SERNFI = '" + VVF->VVF_SERREM + "'"
				cQuery += " AND VV0_CODCLI = '" + VVF->VVF_CODFOR + "'"
				cQuery += " AND VV0_LOJA   = '" + VVF->VVF_LOJA   + "'"
				cQuery += " AND VV0_REMITO = ' '"
				cQuery += " AND VV0.D_E_L_E_T_ = ' '"
				cQuery += " )"

				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasVV9, .F., .T. )
				While (cAliasVV9)->(!Eof())
					VXI001ATU((cAliasVV9)->VV9_NUMATE,"C") // Atualiza Status
					(cAliasVV9)->(dbSkip())
				End
				(cAliasVV9)->(dbCloseArea())

				RestArea(aAreaVV9)
				RestArea(aArea)
			EndIf
		EndIf
	EndIf
Else // VISUALIZACAO E CANCELAMENTO
	VEIXX000(/* xAutoCab */ , /* xAutoItens */ , /* xAutoCP */ , nOpc /* nOpc */ , "5" /* xOpeMov */ , /* xAutoAux */ , /* xMostraMsg */ , /* xSX5NumNota */ , /* xTIPDOC */ , /* xCodVDV */ , "VEIXA002" /* cRotOrigem */)
EndIf
//
return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA002BRWVV0³ Autor ³Andre Luis Almeida / Luis Delorme³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem do Browse com as SAIDAS de Veiculos por Venda                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VA002BVV0()
Local aRotinaX := aClone(aRotina) 
Local aOpcoes  := {}
Local cFilTop  := ""
Local cOrdVV0  := Iif(cPaisLoc $ "ARG|MEX", "VV0_FILIAL,VV0_REMITO,VV0_SERREM", "VV0_FILIAL,VV0_NUMNFI,VV0_SERNFI")
Private cBrwCond2 := 'VV0->VV0_OPEMOV=="0" .AND. VV0->VV0_SITNFI=="1" .AND. ' + Iif(cPaisLoc == "BRA", '!Empty(VV0->VV0_NUMNFI)', '(!Empty(VV0->VV0_NUMNFI) .OR. !Empty(VV0->VV0_REMITO))') // Condicao do Browse, validar ao Incluir/Alterar/Excluir

dbSelectArea("VV0")
dbSetOrder(4)

aAdd(aOpcoes,{STR0012,"VXA002DEV('"+cFilAnt+"')"}) // Devolver
//
cFilTop := "VV0_OPEMOV='0' AND VV0_SITNFI='1' AND " + Iif(cPaisLoc == "BRA", "VV0_NUMNFI <> ' '", "(VV0_NUMNFI <> ' ' OR VV0_REMITO <> ' ')") // Filtra as Saidas de Veiculos por Venda
//
FGX_LBBROW(cCadastro,"VV0",aOpcoes,cFilTop,cOrdVV0,"VV0_DATMOV")
//
aRotina := aClone(aRotinaX)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |VXA002DEV | Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a devolucao da nota fiscal selecionada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA002DEV(c_xFil)
Local xAutoCab    := {}
Local xAutoItens  := {}
Local xAutoAux    := {}
Local nRecVV0     := VV0->(RecNo())
Local cGruVei     := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1])) // Grupo do Veiculo
// Declaracao da ParamBox
Local aRet        := {1,"","","",""}
Local aParamBox   := {}
Local i           := 0
Local nQtdDev     := 0
Local nPosVet     := 0
Local cAliasVQ0   := "SQLVQ0"
Local lContabil   := ( VVG->(FieldPos("VVG_CENCUS")) > 0 .and. VVG->(FieldPos("VVG_CONTA")) > 0 .and. VVG->(FieldPos("VVG_ITEMCT")) > 0 .and. VVG->(FieldPos("VVG_CLVL")) > 0 ) // Campos para a contabilizacao - VVG
Local lVQ0_ITETRA := ( VQ0->(FieldPos("VQ0_ITETRA")) > 0 )
Local lVVF_DEVMER := ( VVF->(FieldPos("VVF_DEVMER")) > 0 )
Local lVVF_MENPAD := ( VVF->(FieldPos("VVF_MENPAD")) > 0 )
Local lVVF_MENNOT := ( VVF->(FieldPos("VVF_MENNOT")) > 0 )
Local lVVF_VEICU1 := ( VVF->(FieldPos("VVF_VEICU1")) > 0 )
Local lVVF_VEICU2 := ( VVF->(FieldPos("VVF_VEICU2")) > 0 )
Local lVVF_VEICU3 := ( VVF->(FieldPos("VVF_VEICU3")) > 0 )
Local lVVF_CLIRET := ( VVF->(FieldPos("VVF_CLIRET")) > 0 )
Local lVVF_CLIENT := ( VVF->(FieldPos("VVF_CLIENT")) > 0 )
Local lVVF_TPFRET := ( VVF->(ColumnPos("VVF_TPFRET")) > 0 )
Local cTpFrete := " "
//
Local cTitNum  := ""
Local cTitSer  := ""
Local cDefNum  := ""
Local cDefSer  := ""
Local cEdtNum  := ""
Local cEdtSer  := ""
Local cTpFatR  := "1" // 1 = Fatura (default)
//
Local cVldNFI  := ""
Local cVldSNF  := ""
Local lFGX_VLDSX3 := FindFunction("FGX_VLDSX3")
//
Local oCliente   := DMS_Cliente():New()
//
Local lVVF_PLACA := ( VVF->(ColumnPos("VVF_PLACA")) > 0 )

Private lFormPro := .f.
Private cLocxNFPV	:= ""
Private cIdPVArg	:= ""
Private cEspecie    := ""
Private lGerarCFD   := .F.
Private lAtuFiscal  := .T. // Atualiza Fiscal - uso no VX000VLDENC (evita erro variable does not exist)
Private PARxTIPDOC  := "1" // 1=NF / 2=SD3 (Mov.Internas) - uso no VX000VLDENC (evita erro variable does not exist)

Default c_xFil    := cFilAnt
cFilAnt := c_xFil

If &cBrwCond2 // Condicao do Browse 2, validar ao Devolver
	//
	If !Empty(VV0->VV0_CLIALI) .and. VV0->VV0_CATVEN=="7" // Alienado
		If oCliente:Bloqueado( VV0->VV0_CLIALI , VV0->VV0_LOJALI , .T. ) // Cliente Bloqueado ?
			Return .f.
		EndIf
	Else
		If oCliente:Bloqueado( VV0->VV0_CODCLI , VV0->VV0_LOJA , .T. ) // Cliente Bloqueado ?
			Return .f.
		EndIf
	EndIf
	//
	If lVVF_TPFRET
		DBSelectArea("SF2")
		DBSetOrder(1)
		If DBSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
			cTpFrete := SF2->F2_TPFRETE // Se Devolução, utilizar o mesmo Tipo de Frete da Saida
		EndIf
	EndIf
	//
	if cPaisLoc == "BRA" .and. MsgYesNo(STR0013,STR0011)//Formulario Proprio ? ### Atencao
		lFormPro := .t.
	endif
	//
	if !(lFormPro)
		cDefNum := space(TamSX3("VVF_NUMNFI")[1])
		cDefSer := space(FGX_MILSNF("VVF",6,"VVF_SERNFI"))
		If cPaisLoc $ "ARG|MEX"
			cTitNum := RetTitle("VVF_REMITO")
			cTitSer := RetTitle("VVF_SERREM")
			M->VVF_REMITO := cDefNum
			M->VVF_SERREM := cDefSer 
			If lFGX_VLDSX3
				cVldNFI := FGX_VLDSX3('VVF_REMITO','MV_PAR01') // Tras o VALID+VLDUSER do campo VVF_REMITO, utilizando o MV_PAR01
				cVldSNF := FGX_VLDSX3('VVF_SERREM','MV_PAR02') // Tras o VALID+VLDUSER do campo VVF_SERREM, utilizando o MV_PAR02
			EndIf
			If Empty(VV0->VV0_REMITO)
				cDefNum := VV0->VV0_NUMNFI
				cDefSer := VV0->VV0_SERNFI
				cEdtNum := ".f."
				cEdtSer := ".f."
			EndIf
		Else // Default
			cTitNum := STR0015 // Nota Fiscal
			cTitSer := STR0016 // Serie
			M->VVF_NUMNFI := cDefNum
			M->VVF_SERNFI := cDefSer 
			M->VVF_CODFOR := VV0->VV0_CODCLI
			M->VVF_LOJA	  := VV0->VV0_LOJA
			If lFGX_VLDSX3
				cVldNFI := FGX_VLDSX3('VVF_NUMNFI','MV_PAR01') // Tras o VALID+VLDUSER do campo VVF_NUMNFI, utilizando o MV_PAR01
				cVldSNF := FGX_VLDSX3('VVF_SERNFI','MV_PAR02') // Tras o VALID+VLDUSER do campo VVF_SERNFI, utilizando o MV_PAR02
			EndIf
		EndIf
		aAdd(aParamBox,{1,cTitNum,cDefNum,"",cVldNFI,"",cEdtNum,60,.T.})
		aAdd(aParamBox,{1,cTitSer,cDefSer,"",cVldSNF,"",cEdtSer,30,.F.})
		aAdd(aParamBox,{1,RetTitle("VVF_ESPECI"),Iif(cPaisLoc $ "ARG|MEX", "RFD", space(TamSX3("VVF_ESPECI")[1])),VVF->(X3Picture("VVF_ESPECI")),"Vazio() .or. ExistCpo('SX5','42'+MV_Par03)","42",Iif(cPaisLoc $ "ARG|MEX",".F.", ""),20,X3Obrigat("VVF_ESPECI")}) // Especie da NF
		aAdd(aParamBox,{1,STR0020,space(TamSX3("VVF_CHVNFE")[1]),VVF->(X3Picture("VVF_CHVNFE")),"VXVlChvNfe('0',Mv_Par03)","",Iif(cPaisLoc $ "ARG|MEX",".F.", ""),120,.f.}) // Chave da NFE
		aAdd(aParamBox,{1,RetTitle("VVF_NATURE"),Space(TamSX3("VVF_NATURE")[1]),"","FinVldNat( .F. )","SED","",80,.t.}) // Natureza
		aAdd(aParamBox,{1,RetTitle("VVF_DATEMI"),dDataBase,"@D","Mv_Par06<=dDataBase","","",50,.t.}) // Data de Emissão
		aAdd(aParamBox,{1,RetTitle("VVF_TRANSP"),Space(TAMSX3("VVF_TRANSP")[1]),/*X3Picture("VVF_TRANSP")*/,,"SA4"	,"",50,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VVF_PLIQUI"),0,X3Picture("VVF_PLIQUI"),,""		,"",50,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VVF_PBRUTO"),0,X3Picture("VVF_PBRUTO"),,""		,"",50,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VVF_VOLUM1"),0,X3Picture("VVF_VOLUM1"),,""		,"",30,.f.})
		aAdd(aParamBox,{1,RetTitle("VVF_ESPEC1"),space(TamSX3("VVF_ESPEC1")[1]),VVF->(X3Picture("VVF_ESPEC1")),"","","",50,.f.}) // Especie 1

		// Veículo Transportador (Integração MATA103 - CI 008022)
		If lVVF_VEICU1
			aAdd(aParamBox, {1, RetTitle("VVF_VEICU1"), space(TamSX3("VVF_VEICU1")[1]), VVF->(X3Picture("VVF_VEICU1")), "", "DA3", "", 50, .f.}) // Veículo 1
		EndIf

		If lVVF_VEICU2
			aAdd(aParamBox, {1, RetTitle("VVF_VEICU2"), space(TamSX3("VVF_VEICU2")[1]), VVF->(X3Picture("VVF_VEICU2")), "", "DA3", "", 50, .f.}) // Veículo 2
		EndIf

		If lVVF_VEICU3
			aAdd(aParamBox, {1, RetTitle("VVF_VEICU3"), space(TamSX3("VVF_VEICU3")[1]), VVF->(X3Picture("VVF_VEICU3")), "", "DA3", "", 50, .f.}) // Veículo 3
		EndIf

		If cPaisLoc == "BRA" .and. lVVF_CLIRET
			aAdd(aParamBox, {1, RetTitle("VVF_CLIRET"), space(TamSX3("VVF_CLIRET")[1]), VVF->(X3Picture("VVF_CLIRET")), "", "SA1", "", 50, .f.}) // Veículo 3
			aAdd(aParamBox, {1, RetTitle("VVF_LOJRET"), space(TamSX3("VVF_LOJRET")[1]), VVF->(X3Picture("VVF_LOJRET")), "", ""   , "", 25, .f.}) // Veículo 3
		EndIf

		If cPaisLoc == "BRA" .and. lVVF_CLIENT
			aAdd(aParamBox, {1, RetTitle("VVF_CLIENT"), space(TamSX3("VVF_CLIENT")[1]), VVF->(X3Picture("VVF_CLIENT")), "", "SA1", "", 50, .f.}) // Veículo 3
			aAdd(aParamBox, {1, RetTitle("VVF_LOJENT"), space(TamSX3("VVF_LOJENT")[1]), VVF->(X3Picture("VVF_LOJENT")), "", ""   , "", 25, .f.}) // Veículo 3
		EndIf

		if lVVF_TPFRET
			aCBOX_TPFret := X3CBOXAVET("VVF_TPFRET","1")
			aAdd(aParamBox,{2,RetTitle("VVF_TPFRET"),cTpFrete,aCBOX_TPFret,100,"",.f.}) // Tipo de Frete
		EndIf

		//Placa do Veículo Transportador (Integração MATA103 - CI 012236)
		If lVVF_PLACA
			aAdd(aParamBox, {1, RetTitle("VVF_PLACA"), space(TamSX3("VVF_PLACA")[1]), VVF->(X3Picture("VVF_PLACA")), "", "DA302", "", 80, .f.})
		EndIf

	Else
		aAdd(aParamBox,{1,RetTitle("VVF_ESPECI"),Iif(cPaisLoc $ "ARG|MEX", "RFD", space(TamSX3("VVF_ESPECI")[1])),VVF->(X3Picture("VVF_ESPECI")),"Vazio() .or. ExistCpo('SX5','42'+MV_Par01)","42",Iif(cPaisLoc $ "ARG|MEX",".F.", ""),20,X3Obrigat("VVF_ESPECI")}) // Especie da NF
		aAdd(aParamBox,{1,RetTitle("VVF_NATURE"),Space(TamSX3("VVF_NATURE")[1]),"","FinVldNat( .F. )","SED","",80,.T.})
		aAdd(aParamBox,{1,RetTitle("VVF_TRANSP"),Space(TAMSX3("VVF_TRANSP")[1]),/*X3Picture("VVF_TRANSP")*/,,"SA4"	,"",50,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VVF_PLIQUI"),0,X3Picture("VVF_PLIQUI"),,""		,"",50,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VVF_PBRUTO"),0,X3Picture("VVF_PBRUTO"),,""		,"",50,.f.}) 
		aAdd(aParamBox,{1,RetTitle("VVF_VOLUM1"),0,X3Picture("VVF_VOLUM1"),,""		,"",30,.f.})
		aAdd(aParamBox,{1,RetTitle("VVF_ESPEC1"),space(TamSX3("VVF_ESPEC1")[1]),VVF->(X3Picture("VVF_ESPEC1")),"","","",50,.f.}) // Especie 1

		//Variável nPosVet é utilizada somente para controle do posicionamento do campo MEMO no vetor aRet
		nPosVet := 8

		if cPaisLoc == "BRA" .and. lVVF_DEVMER
			aAdd(aParamBox,{2,RetTitle("VVF_DEVMER"),"",{"","S="+STR0025,"N="+STR0024},40,"",.f.}) // N=Nao / S=Sim
			nPosVet++
		EndIf

		// Veículo Transportador (Integração MATA103 - CI 008022)
		If lVVF_VEICU1
			aAdd(aParamBox, {1, RetTitle("VVF_VEICU1"), space(TamSX3("VVF_VEICU1")[1]), VVF->(X3Picture("VVF_VEICU1")), "", "DA3", "", 50, .f.}) // Veículo 1
			nPosVet++
		EndIf

		If lVVF_VEICU2
			aAdd(aParamBox, {1, RetTitle("VVF_VEICU2"), space(TamSX3("VVF_VEICU2")[1]), VVF->(X3Picture("VVF_VEICU2")), "", "DA3", "", 50, .f.}) // Veículo 2
			nPosVet++
		EndIf

		If lVVF_VEICU3
			aAdd(aParamBox, {1, RetTitle("VVF_VEICU3"), space(TamSX3("VVF_VEICU3")[1]), VVF->(X3Picture("VVF_VEICU3")), "", "DA3", "", 50, .f.}) // Veículo 3
			nPosVet++
		EndIf

		If cPaisLoc == "BRA" .and. lVVF_CLIRET
			aAdd(aParamBox, {1, RetTitle("VVF_CLIRET"), space(TamSX3("VVF_CLIRET")[1]), VVF->(X3Picture("VVF_CLIRET")), "", "SA1", "", 50, .f.}) // Veículo 3
			nPosVet++
			aAdd(aParamBox, {1, RetTitle("VVF_LOJRET"), space(TamSX3("VVF_LOJRET")[1]), VVF->(X3Picture("VVF_LOJRET")), "", ""   , "", 25, .f.}) // Veículo 3
			nPosVet++
		EndIf

		If cPaisLoc == "BRA" .and. lVVF_CLIENT
			aAdd(aParamBox, {1, RetTitle("VVF_CLIENT"), space(TamSX3("VVF_CLIENT")[1]), VVF->(X3Picture("VVF_CLIENT")), "", "SA1", "", 50, .f.}) // Veículo 3
			nPosVet++
			aAdd(aParamBox, {1, RetTitle("VVF_LOJENT"), space(TamSX3("VVF_LOJENT")[1]), VVF->(X3Picture("VVF_LOJENT")), "", ""   , "", 25, .f.}) // Veículo 3
			nPosVet++
		EndIf

		aAdd(aParamBox,{11,RetTitle("VVF_OBSENF"),space(200),"","",.f.}) //Variável nPosVet é utilizada somente para controle do posicionamento do campo MEMO no vetor aRet
		if lVVF_MENPAD
			aAdd(aParamBox,{1,RetTitle("VVF_MENPAD"),space(TamSX3("VVF_MENPAD")[1]),VVF->(X3Picture("VVF_MENPAD")),"texto().Or.Vazio()","SM4","",30,.f.}) // Mensagem padrao
		Endif
		if lVVF_MENNOT
			aAdd(aParamBox,{1,RetTitle("VVF_MENNOT"),space(TamSX3("VVF_MENNOT")[1]),VVF->(X3Picture("VVF_MENNOT")),"","","",200,.f.}) // Mensagem NF
		Endif
		if lVVF_TPFRET
			aCBOX_TPFret := X3CBOXAVET("VVF_TPFRET","1")
			aAdd(aParamBox,{2,RetTitle("VVF_TPFRET"),cTpFrete,aCBOX_TPFret,100,"",.f.}) // Tipo de Frete
		EndIf
		//Placa do Veículo Transportador (Integração MATA103 - CI 012236)
		If lVVF_PLACA
			aAdd(aParamBox, {1, RetTitle("VVF_PLACA"), space(TamSX3("VVF_PLACA")[1]), VVF->(X3Picture("VVF_PLACA")), "", "DA302", "", 80, .f.})
		EndIf
	endif
	//
	aRet := FGX_SELVEI("VV0",STR0017,VV0->VV0_FILIAL,VV0->VV0_NUMTRA,aParamBox,"VXA002VTES")
	//
	If Len(aRet) == 0 //!(ParamBox(aParamBox,STR0017,@aRet,,,,,,,,.f.)) //Dados do Retorno de Remessa
		Return .f.
	EndIf
	If lFormPro // Quando Formulario Proprio
		//Variável nPosVet é utilizada somente para controle do posicionamento do campo MEMO no vetor aRet
		aRet[1,nPosVet] := &("MV_PAR"+strzero(nPosVet,2)) // Prencher MEMO no Vetor de Retorno da Parambox pois o vetor não traz conteúdo nos campos MEMO
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array de integracao com o VEIXX000                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(xAutoCab,{"VVF_FILIAL"  ,xFilial("VVF")			,Nil})
	aAdd(xAutoCab,{"VVF_FORPRO"  ,IIF(lFormPro,"1","0")		,Nil})
	aAdd(xAutoCab,{"VVF_CLIFOR"  ,"C"   ,Nil})
	if ! lFormPro
		aAdd(xAutoCab,{"VVF_NUMNFI"  ,aRet[1,1]				,Nil})
		aAdd(xAutoCab,{"VVF_SERNFI"  ,FGX_UFSNF(aRet[1,2])	,Nil}) // coloquei FGX_UFSNF porque não tem picture no parambox, isso garante o padrao de nota DAV
		aAdd(xAutoCab,{"VVF_ESPECI"  ,aRet[1,3]				,Nil})
		aAdd(xAutoCab,{"VVF_CHVNFE"  ,aRet[1,4]				,Nil})
		aAdd(xAutoCab,{"VVF_NATURE"  ,aRet[1,5]				,Nil})
		aAdd(xAutoCab,{"VVF_DATEMI"  ,aRet[1,6]				,Nil})
		aAdd(xAutoCab,{"VVF_TRANSP"  ,aRet[1,7]				,Nil})
		aAdd(xAutoCab,{"VVF_PLIQUI"  ,aRet[1,8]				,Nil})
		aAdd(xAutoCab,{"VVF_PBRUTO"  ,aRet[1,9]				,Nil})
		aAdd(xAutoCab,{"VVF_VOLUM1"  ,aRet[1,10]			,Nil})
		aAdd(xAutoCab,{"VVF_ESPEC1"  ,aRet[1,11]			,Nil})

		// Veículo Transportador (Integração MATA103 - CI 008022)
		nPosVet := 12 // Última posíção válida para incremento

		If lVVF_VEICU1
			aAdd(xAutoCab,{"VVF_VEICU1" ,aRet[1,nPosVet++],Nil})
		EndIf

		If lVVF_VEICU2
			aAdd(xAutoCab,{"VVF_VEICU2" ,aRet[1,nPosVet++],Nil})
		EndIf

		If lVVF_VEICU3
			aAdd(xAutoCab,{"VVF_VEICU3" ,aRet[1,nPosVet++],Nil})
		EndIf

		If cPaisLoc == "BRA" .and. lVVF_CLIRET
			aAdd(xAutoCab,{"VVF_CLIRET"  ,aRet[1,nPosVet++]	,Nil})
			aAdd(xAutoCab,{"VVF_LOJRET"  ,aRet[1,nPosVet++]	,Nil})
		Else
			aAdd(xAutoCab,{"VVF_CLIRET"  ,VV0->VV0_CODCLI	,Nil})
			aAdd(xAutoCab,{"VVF_LOJRET"  ,VV0->VV0_LOJA		,Nil})
		EndIf

		If cPaisLoc == "BRA" .and. lVVF_CLIENT
			aAdd(xAutoCab,{"VVF_CLIENT"  ,aRet[1,nPosVet++]	,Nil})
			aAdd(xAutoCab,{"VVF_LOJENT"  ,aRet[1,nPosVet++]	,Nil})
		Else
			aAdd(xAutoCab,{"VVF_CLIENT"  ,VV0->VV0_CLIENT	,Nil})
			aAdd(xAutoCab,{"VVF_LOJENT"  ,VV0->VV0_LOJENT	,Nil})
		EndIf

		If lVVF_TPFRET
			cVVF_TPFRET := aRet[1,nPosVet++]
			If ! empty(cVVF_TPFRET)
				aAdd(xAutoCab,{"VVF_TPFRET" ,cVVF_TPFRET,Nil})
			EndIf
		EndIf

		//Placa do Veículo Transportador (Integração MATA103 - CI 012236)
		If lVVF_PLACA
			aAdd(xAutoCab,{"VVF_PLACA" ,aRet[1,nPosVet++],Nil})
		EndIf

	Else
		aAdd(xAutoCab,{"VVF_ESPECI"  ,aRet[1,1]				,Nil})
		aAdd(xAutoCab,{"VVF_NATURE"  ,aRet[1,2]				,Nil})
		aAdd(xAutoCab,{"VVF_TRANSP"  ,aRet[1,3]				,Nil})
		aAdd(xAutoCab,{"VVF_PLIQUI"  ,aRet[1,4]				,Nil})
		aAdd(xAutoCab,{"VVF_PBRUTO"  ,aRet[1,5]				,Nil})
		aAdd(xAutoCab,{"VVF_VOLUM1"  ,aRet[1,6]				,Nil})
		aAdd(xAutoCab,{"VVF_ESPEC1"  ,aRet[1,7]				,Nil})
		nPosVet := 8
		If cPaisLoc == "BRA" .and. lVVF_DEVMER
			If !Empty(aRet[1,nPosVet])
				aAdd(xAutoCab,{"VVF_DEVMER" ,aRet[1,nPosVet],Nil})
			EndIf
			nPosVet++
		EndIf

		// Veículo Transportador (Integração MATA103 - CI 008022)
		If lVVF_VEICU1
			aAdd(xAutoCab,{"VVF_VEICU1" ,aRet[1,nPosVet++],Nil})
		EndIf

		If lVVF_VEICU2
			aAdd(xAutoCab,{"VVF_VEICU2" ,aRet[1,nPosVet++],Nil})
		EndIf

		If lVVF_VEICU3
			aAdd(xAutoCab,{"VVF_VEICU3" ,aRet[1,nPosVet++],Nil})
		EndIf

		If cPaisLoc == "BRA" .and. lVVF_CLIRET
			aAdd(xAutoCab,{"VVF_CLIRET"  ,aRet[1,nPosVet++]	,Nil})
			aAdd(xAutoCab,{"VVF_LOJRET"  ,aRet[1,nPosVet++]	,Nil})
		Else
			aAdd(xAutoCab,{"VVF_CLIRET"  ,VV0->VV0_CODCLI	,Nil})
			aAdd(xAutoCab,{"VVF_LOJRET"  ,VV0->VV0_LOJA		,Nil})
		EndIf

		If cPaisLoc == "BRA" .and. lVVF_CLIENT
			aAdd(xAutoCab,{"VVF_CLIENT"  ,aRet[1,nPosVet++]	,Nil})
			aAdd(xAutoCab,{"VVF_LOJENT"  ,aRet[1,nPosVet++]	,Nil})
		Else
			aAdd(xAutoCab,{"VVF_CLIENT"  ,VV0->VV0_CLIENT	,Nil})
			aAdd(xAutoCab,{"VVF_LOJENT"  ,VV0->VV0_LOJENT	,Nil})
		EndIf

		aAdd(xAutoCab    ,{"VVF_OBSENF"  ,aRet[1,nPosVet++]	,Nil})
		if lVVF_MENPAD
			aAdd(xAutoCab,{"VVF_MENPAD"  ,aRet[1,nPosVet++]	,Nil})
		Endif
		if lVVF_MENNOT
			aAdd(xAutoCab,{"VVF_MENNOT"  ,aRet[1,nPosVet++]	,Nil})
		EndIf

		If lVVF_TPFRET
			cVVF_TPFRET := aRet[1,nPosVet++]
			If ! empty(cVVF_TPFRET)
				aAdd(xAutoCab,{"VVF_TPFRET" ,cVVF_TPFRET,Nil})
			EndIf
		EndIf

		//Placa do Veículo Transportador (Integração MATA103 - CI 012236)
		If lVVF_PLACA
			aAdd(xAutoCab,{"VVF_PLACA" ,aRet[1,nPosVet++] ,Nil})
		EndIf
	endif
	aAdd(xAutoCab,{"VVF_CODFOR"  ,IIF(!Empty(VV0->VV0_CLIALI).and.VV0->VV0_CATVEN=="7",VV0->VV0_CLIALI,VV0->VV0_CODCLI),	Nil})
	aAdd(xAutoCab,{"VVF_LOJA"    ,IIF(!Empty(VV0->VV0_CLIALI).and.VV0->VV0_CATVEN=="7",VV0->VV0_LOJALI,VV0->VV0_LOJA),	Nil})
	aAdd(xAutoCab,{"VVF_FORPAG"  ,VV0->VV0_FORPAG,						Nil})
	//
	DBSelectArea("VVA")
	DBSetOrder(1)

	For i := 1 to Len(aRet[2])

		If aRet[2,i,1] // Veículo está selecionado
			nQtdDev++
			DBSelectArea("VVA")
			DbGoto(aRet[2,i,2])
			DBSelectArea("SF4")
			DBSetOrder(1)
			DBSeek(xFilial("SF4")+aRet[2,i,3])

			cGruVei     := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VVA->VVA_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))

			// Posiciona corretamente na SB1 dependendo do parametro MV_MIL0010
			If ! FGX_VV1SB1("CHASSI", VVA->VVA_CHASSI , /* cMVMIL0010 */ , cGruVei )
				FMX_HELP("VA002E01", STR0021) // "Veículo não encontrado"
				Return .f.
			EndIf

			xAutoIt := {}
			aAdd(xAutoIt,{"VVG_FILIAL"  ,xFilial("VVG")					,Nil})
			aAdd(xAutoIt,{"VVG_CHASSI"  ,VVA->VVA_CHASSI 				,Nil})
			aAdd(xAutoIt,{"VVG_CODTES"  ,aRet[2,i,3]					,Nil})
			aAdd(xAutoIt,{"VVG_LOCPAD"  ,VV1->VV1_LOCPAD				,Nil})
			aAdd(xAutoIt,{"VVG_VALUNI"  ,VVA->VVA_VALMOV				,Nil})
			aAdd(xAutoIt,{"VVG_PICOSB"  ,"0"							,Nil})
			if lContabil
				if Len(aRet[2,i]) > 7
					aAdd(xAutoIt,{"VVG_CENCUS"  ,aRet[2,i,8],Nil})
					aAdd(xAutoIt,{"VVG_CONTA"   ,aRet[2,i,9],Nil})
					aAdd(xAutoIt,{"VVG_ITEMCT"  ,aRet[2,i,10],Nil})
					aAdd(xAutoIt,{"VVG_CLVL"    ,aRet[2,i,11],Nil})

					aAdd(xAutoIt,{"VVG_TOTFRE"   ,aRet[2,i,14],Nil})
					aAdd(xAutoIt,{"VVG_DESACE"   ,aRet[2,i,15],Nil})
					aAdd(xAutoIt,{"VVG_TOTSEG"   ,aRet[2,i,16],Nil})
				Endif	
			else 
					aAdd(xAutoIt,{"VVG_TOTFRE"   ,aRet[2,i,12],Nil})
					aAdd(xAutoIt,{"VVG_DESACE"   ,aRet[2,i,13],Nil})
					aAdd(xAutoIt,{"VVG_TOTSEG"   ,aRet[2,i,14],Nil})
			Endif

			//
			aAdd(xAutoItens,xAutoIt)
			// MONTA ARRAY AUXILIAR COM INFORMACOES DE CONTROLE DE RETORNO (ITEMSEQ, IDENTB6, ETC)
			xAutoIt := {}
			If cUsaGrVA == "1" // Usa Veiculos de forma Agrupada por Modelo no SB1
				If !FGX_VV2SB1(VV1->VV1_CODMAR, VV1->VV1_MODVEI, VV1->VV1_SEGMOD)
					FMX_HELP("VA002E04",STR0023)
					Return .f.
				Endif
			Endif
			DBSelectArea("SD2")
			DBSetOrder(3)
			if !Empty(VV0->VV0_CLIALI) .and. VV0->VV0_CATVEN=="7"
				If ! DBSeek(xFilial("SD2")+Iif(cPaisLoc $ "ARG|MEX" .and. !Empty(VV0->VV0_REMITO),VV0->VV0_REMITO+VV0->VV0_SERREM,VV0->VV0_NUMNFI+VV0->VV0_SERNFI)+VV0->VV0_CLIALI+VV0->VV0_LOJALI+SB1->B1_COD)
					FMX_HELP("VA002E02",STR0022  + CRLF + CRLF + ;
						AllTrim(RetTitle(Iif(cPaisLoc $ "ARG|MEX" .and. !Empty(VV0->VV0_REMITO), "VV0_REMITO", "VV0_NUMNFI"))) + ": " + Iif(cPaisLoc $ "ARG|MEX" .and. !Empty(VV0->VV0_REMITO), VV0->VV0_REMITO + "-" + VV0->VV0_SERREM, VV0->VV0_NUMNFI + "-" + VV0->VV0_SERNFI) + CRLF +;
						AllTrim(RetTitle("VV0_CLIALI")) + ": " + VV0->VV0_CLIALI + "-" + VV0->VV0_LOJALI + CRLF + ;
						AllTrim(RetTitle("B1_COD")) + "(SB1): " + SB1->B1_COD)
					Return .f.
				endif
			else
				If ! DBSeek(xFilial("SD2")+Iif(cPaisLoc $ "ARG|MEX" .and. !Empty(VV0->VV0_REMITO),VV0->VV0_REMITO+VV0->VV0_SERREM,VV0->VV0_NUMNFI+VV0->VV0_SERNFI)+VV0->VV0_CODCLI+VV0->VV0_LOJA+SB1->B1_COD)
					FMX_HELP("VA002E03",STR0022  + CRLF + CRLF + ;
						AllTrim(RetTitle(Iif(cPaisLoc $ "ARG|MEX" .and. !Empty(VV0->VV0_REMITO), "VV0_REMITO", "VV0_NUMNFI"))) + ": " + Iif(cPaisLoc $ "ARG|MEX" .and. !Empty(VV0->VV0_REMITO), VV0->VV0_REMITO + "-" + VV0->VV0_SERREM, VV0->VV0_NUMNFI + "-" + VV0->VV0_SERNFI) + CRLF +;
						AllTrim(RetTitle("VV0_CODCLI")) + ": " + VV0->VV0_CODCLI + "-" + VV0->VV0_LOJA + CRLF + ;
						AllTrim(RetTitle("B1_COD")) + "(SB1): " + SB1->B1_COD)
					Return .f.
				endif
			endif
			//
			aAdd(xAutoIt,{"D1_NFORI"   ,SD2->D2_DOC,Nil})
			aAdd(xAutoIt,{"D1_SERIORI" ,SD2->D2_SERIE,Nil})
			aAdd(xAutoIt,{"D1_ITEMORI" ,SD2->D2_ITEM,Nil})
			//
			DBSelectArea("SF4")
			DBSetOrder(1)
			DBSeek(xFilial("SF4")+SD2->D2_TES)
			If SF4->F4_PODER3=="D"
				aAdd(xAutoIt,{"D1_IDENTB6" ,SD2->D2_IDENTB6,Nil})
			endif
			//
			aAdd(xAutoAux,xAutoIt)
		Endif
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chama a integracao com o VEIXX000                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//
	lMsErroAuto := .f.
	//
	If cPaisLoc $ "ARG|MEX"
		cTpFatR := "2" // 2 = Remito
		DBSelectArea("VV0")		
		DBGoTo(nRecVV0)
		If Empty(VV0->VV0_REMITO)
			cTpFatR := "6" // 6=Não grava, é utilizado somente para DEVOLVER uma Venda sem Entrega (não possui REMITO de SAIDA)
		EndIf
		If cTpFatR == "2" // 2 = Remito
			cEspecie := aRet[1,1]
		EndIf
	EndIf
	//
	MSExecAuto({|x,y,w,z,k,l,m| VEIXX000(x,y,w,z,k,l,/*xMostraMsg*/,/*xSX5NumNota*/,/*xTIPDOC*/,/*xCodVDV*/,"VEIXA002"/*cRotOrigem*/,m)},xAutoCab,xAutoItens,{},3,"5",xAutoAux,cTpFatR)
	//
	If !(nQtdDev == Len(aRet[2])) // A Devolucao foi Parcial
		DBSelectArea("VV0")
		DBGoTo(nRecVV0)
		reclock("VV0",.f.)
		VV0->VV0_SITNFI := "1"
		msunlock()
	Endif
	For i := 1 to Len(aRet[2])
		If aRet[2,i,1] // Veículo está selecionado
			DBSelectArea("VVA")
			DbGoto(aRet[2,i,2])
			cQuery := "SELECT R_E_C_N_O_ RECNOVQ0 , VQ0.VQ0_FILATE , VQ0.VQ0_NUMATE "
			cQuery += "FROM "+RetSqlName("VQ0")+" VQ0 WHERE " 
			cQuery += "VQ0.VQ0_FILIAL='"+ xFilial("VQ0")+ "' AND VQ0.VQ0_FILATE='"+VVA->VVA_FILIAL+"' AND VQ0.VQ0_NUMATE='"+VVA->VVA_NUMTRA+"' AND "
			If lVQ0_ITETRA
				cQuery += "( VQ0.VQ0_ITETRA='"+VVA->VVA_ITETRA+"' OR VQ0.VQ0_ITETRA='  ' ) AND "
			EndIf
			cQuery += "VQ0.D_E_L_E_T_=' '"                                             
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVQ0, .T., .T. )
			Do While !( cAliasVQ0 )->( Eof() )
				if !Empty(( cAliasVQ0 )->VQ0_FILATE+( cAliasVQ0 )->VQ0_NUMATE) 
					dbSelectArea("VQ0")
					DbGoto(( cAliasVQ0 )->(RECNOVQ0))
					RecLock("VQ0",.f.)
					VQ0->VQ0_FILATE := ""
					VQ0->VQ0_NUMATE := ""
					If lVQ0_ITETRA
						VQ0->VQ0_ITETRA := ""
					EndIf
					MsUnLock()
				Endif
				dbSelectArea(cAliasVQ0)
				( cAliasVQ0 )->(dbSkip())
			Enddo
			(cAliasVQ0)->(dbCloseArea())   
		Endif
	Next	
	//
	If lMsErroAuto   
		DisarmTransaction()
		MostraErro()
		Return .f.
	EndIf
EndIf
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³Andre Luis Almeida / Luis Delorme  ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Entrada de Veiculos por Devolucao de Venda            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {;
{ (STR0002) ,"AxPesqui" , 0 , 1},;			//Pesquisar
{ (STR0003) ,"VXA002_2"     	, 0 , 2},;		//Visualizar
{ (STR0004) ,"VXA002_3"    		, 0 , 3,,.f.},;		//Devolver
{ (STR0005) ,"VXA002_5"    	 	, 0 , 5,,.f.},;		//Cancelar
{ (STR0006) ,"VXA002LEG" 	 	, 0 , 6},;		//Legenda
{ (STR0007) ,"FGX_PESQBRW('E','5',.t.)" , 0 , 2}}	// Pesquisa Avancada ( E-Entrada por 5-Devolucao de Venda )
//
If cPaisLoc $ "ARG|MEX"
	AAdd(aRotina,{STR0026, "VXA002NCC", 0 , 6}) // Gerar NCC
EndIf
//
Return aRotina

Function VXA002_2(cAlias,nReg,nOpc)
VXA002(cAlias,nReg,2)
Return .t.
Function VXA002_3(cAlias,nReg,nOpc)
VXA002(cAlias,nReg,3)
Return .t.
Function VXA002_5(cAlias,nReg,nOpc)
VXA002(cAlias,nReg,5)
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA002VF  ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Entrada de Veiculos por Devolucao de Venda                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Function VXA002VF()
if MV_PAR01 == 1
	MV_PAR02 := space(TamSX3("VVF_NUMNFI")[1])
	MV_PAR03 := space(TamSX3("VVF_SERNFI")[1])
	return .f.
endif
//
Return .t.
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA002LEG ³ Autor ³ Andre Luis Almeida / Luis Delorme ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Entrada de Veiculos por Devolucao de Venda                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA002LEG()
Local aLegenda :={}
If cPaisLoc $ "ARG|MEX"
	aLegenda :={;
	{'BR_VERDE',STR0008},; // Valida
	{'BR_AMARELO',STR0027},; // Valida sem NCC
	{'BR_VERMELHO',STR0009} } // Cancelada
Else
	aLegenda :={;
	{'BR_VERDE',STR0008},;
	{'BR_VERMELHO',STR0009} }
EndIf
//
BrwLegenda(cCadastro,STR0006,aLegenda)
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA002VTES³ Autor ³Andre Luis Almeida                 ³ Data ³ 12/04/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do TES da Entrada de Veiculos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA002VTES(cCodTes)
DBSelectArea("SF4")
DBSetOrder(1)
If DBSeek(xFilial("SF4")+cCodTes)
	If SF4->F4_TIPO == "S"
		Help("  ",1,"INV_TE")
		return .f.
	endif
Else
	Help("  ",1,"INV_TE")
	return .f.
endif
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VXA002NCC ³ Autor ³ João Carlos da Silva              ³ Data ³ 18/10/24 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerar NCC                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXA002NCC(cAlias,nReg,nOpc)
VX0000129_GeraNCC(nReg) // Gera NCC
Return .t.
