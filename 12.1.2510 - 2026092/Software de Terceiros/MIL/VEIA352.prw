#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA352.CH"

/*/{Protheus.doc} VEIA352

ARGENTINA - Remito Saida e Entrada de Transferência para possibilitar Entrega em outra Filial (pela rotina VEIA351)

@author Andre Luis Almeida
@since 21/06/2026
/*/
Function VEIA352()
Local cFilSD2 := xFilial("SD2")
Local aSize   := FWGetDialogSize( oMainWnd )
Local nCntFor := 0
Local aVWCVEI := {}
Local oBrw352
Local aCores := {{'VWC->VWC_STATUS == "1" .AND. VWC->VWC_FILSAI="'+cFilSD2+'"','BR_BRANCO'  , STR0002 , "@ VWC_STATUS='1' AND VWC_FILSAI='"+cFilSD2+"'"},;	// Saida Efetivada aguardando Entrada em Outra Filial
				 {'VWC->VWC_STATUS == "1" .AND. VWC->VWC_FILENT="'+cFilSD2+'"','BR_AMARELO' , STR0003 , "@ VWC_STATUS='1' AND VWC_FILENT='"+cFilSD2+"'"},;	// Saida Efetivada aguardando Entrada na Filial Logada
				 {'VWC->VWC_STATUS == "2"'                                    ,'BR_VERDE'   , STR0004 , "@ VWC_STATUS='2'"                             },;	// Transferência Concluida
				 {'VWC->VWC_STATUS == "3"'                                    ,'BR_LARANJA' , STR0005 , "@ VWC_STATUS='3'"                             },;	// Transferência Cancelada somente na Filial de Entrada
				 {'VWC->VWC_STATUS == "4"'                                    ,'BR_VERMELHO', STR0006 , "@ VWC_STATUS='4'"                             }}	// Transferência Cancelada

If cPaisLoc <> "ARG"
	FMX_HELP("VEIA352ERR01",STR0007) // Rotina disponível apenas para Argentina.
	Return
EndIf

oDlgVA352 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001 , , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Transferência para possibilitar Entrega em Outra Filial

	oWorkArea := FWUIWorkArea():New( oDlgVA352 )
	oWorkArea:CreateHorizontalBox( "LINE01", 100 , .f. ) // Não é PIXEL fixo, trabalha com % nos tamanhos dos Objetos Browse's
	oWorkArea:SetBoxCols( "LINE01", { "OBJVWC" } )
	oWorkArea:CreateHorizontalBox( "LINE02", 100 , .t. ) // Monta area fixa 100pix para listar os VEICULOS relacionados (VVA)
	oWorkArea:SetBoxCols( "LINE02", { "OBJVEI" } )	
	oWorkArea:Activate()

	oLbV352VEI := TWBrowse():New(1,1,1,1,,,,oWorkarea:GetPanel("OBJVEI"),,,,,{ || VEIVC140(aVWCVEI[oLbV352VEI:nAt,2],) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbV352VEI:addColumn( TCColumn():new( RetTitle("VV1_CHAINT") , { || aVWCVEI[oLbV352VEI:nAt,1] } ,,,,"LEFT" , 40,.F.,.F.,,,,.F.,) ) // ChaInt
	oLbV352VEI:addColumn( TCColumn():new( RetTitle("VV1_CHASSI") , { || aVWCVEI[oLbV352VEI:nAt,2] } ,,,,"LEFT" ,130,.F.,.F.,,,,.F.,) ) // Chassi
	oLbV352VEI:addColumn( TCColumn():new( RetTitle("VV1_CODMAR") , { || aVWCVEI[oLbV352VEI:nAt,3] } ,,,,"LEFT" , 40,.F.,.F.,,,,.F.,) ) // Marca
	oLbV352VEI:addColumn( TCColumn():new( RetTitle("VV1_MODVEI") , { || aVWCVEI[oLbV352VEI:nAt,4] } ,,,,"LEFT" ,200,.F.,.F.,,,,.F.,) ) // Modelo
	oLbV352VEI:Align := CONTROL_ALIGN_ALLCLIENT
	oLbV352VEI:nAT := 1
	oLbV352VEI:SetArray(aVWCVEI)

	oBrw352 := FWMBrowse():New()
	oBrw352:SetOwner(oWorkarea:GetPanel("OBJVWC"))
	oBrw352:lChgAll := .f. // nao apresentar a tela para escolher a filial
	oBrw352:SetAlias('VWC')
	oBrw352:DisableLocate()
	oBrw352:DisableDetails()
	oBrw352:SetAmbiente(.F.)
	For nCntFor := 1 to len(aCores)
		oBrw352:AddLegend( aCores[nCntFor,1] , aCores[nCntFor,2] , aCores[nCntFor,3] , , .f. )
		oBrw352:AddFilter(aCores[nCntFor,3],aCores[nCntFor,4],.f.,.f.,) // STATUS
	Next
	oBrw352:SetWalkthru(.F.)
	oBrw352:SetMenuDef("VEIA352")
	oBrw352:SetDescription(STR0001) // Transferência para possibilitar Entrega em Outra Filial
	oBrw352:SetFilterDefault("@ ( VWC_FILSAI='"+cFilSD2+"' OR VWC_FILENT='"+cFilSD2+"' )")
	oBrw352:SetChange( { || aVWCVEI := VA3520081_Lista_Veiculos() , oLbV352VEI:SetArray(aVWCVEI) , oLbV352VEI:Refresh() } )
	oBrw352:Activate()

oDlgVA352:Activate( , , , , , , ) //ativa a janela

Return

Static Function MenuDef()

	Local aRotina 	:= {}

	ADD OPTION aRotina Title STR0008 Action 'VA3520011_Saida()'    OPERATION 3 ACCESS 0 // Nova Transferência (Saida)
	ADD OPTION aRotina Title STR0009 Action 'VA3520061_Entrada()'  OPERATION 4 ACCESS 0 // Entrada da Transferência
	ADD OPTION aRotina Title STR0010 Action 'VA3520071_Cancelar()' OPERATION 5 ACCESS 0 // Cancelar a Transferência
	
Return aRotina

/*/{Protheus.doc} VA3520011_Saida
	Tela para selecionar o Atendimento que é possivel alterar a Filial de Entrega

	@author Andre Luis Almeida
	@since 21/06/2026
/*/
Function VA3520011_Saida()
	Local aSize   := FWGetDialogSize( oMainWnd )
	Local cTitFil := STR0011+": "+cFilAnt+" - "+STR0012 // Filial / Selecione o Atendimento que deseja trocar a Filial de Entrega
	Local cBkpFil := cFilAnt
	//	
	Local oBrwVV0 // Atendimentos aguardando Remito de Entrega
	Local cQryVV0 := VA3520021_QueryBrowse() // Query Browse
	Local aIndVV0 := VA3520031_IndexBrowse() // Indices Browse
	Local aSekVV0 := VA3520041_SeeksBrowse() // Seeks Browse
	Local aColVV0 := VA3520051_ColunBrowse() // Colunas Browse

	oVEIA352 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cTitFil, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		oBrwVV0 := FWFormBrowse():New( )
		oBrwVV0:SetOwner(oVEIA352)
		oBrwVV0:SetDataQuery(.T.)
		oBrwVV0:SetAlias("TEMPVV0")
		oBrwVV0:SetQueryIndex(aIndVV0)
		oBrwVV0:SetQuery(cQryVV0)
		oBrwVV0:SetSeek(,aSekVV0)
		oBrwVV0:SetDescription( cTitFil )
		oBrwVV0:SetMenuDef("")
		oBrwVV0:AddButton( STR0013 , {|| IIf(!Empty(TEMPVV0->VV9_NUMATE).and.VEIA354(oBrwVV0,cBkpFil),oVEIA352:End(),.t.) } ,,2,2) // Atendimento posicionado
		oBrwVV0:AddButton( STR0014 , {|| IIf(!Empty(TEMPVV0->VVA_CHASSI),VEIVC140(TEMPVV0->VVA_CHASSI,),.t.) },,2,2) // Rastreamento Veículo/Máquina
		oBrwVV0:DisableDetails()
		oBrwVV0:DisableReport()
		oBrwVV0:DisableConfig()
		oBrwVV0:SetUseFilter(.t.)
		oBrwVV0:SetColumns(aColVV0)
		oBrwVV0:ForceQuitButton(.T.)
		oBrwVV0:Activate()

	oVEIA352:Activate( , , , , , , ) //ativa a janela

	cFilAnt := cBkpFil

Return .t.

/*/{Protheus.doc} VA3520021_QueryBrowse
	Retorna a Query do Browse ( browse em SQL )

	@author Andre Luis Almeida
	@since 21/06/2026
/*/
Static Function VA3520021_QueryBrowse()
Local cAliasVV9 := "SQLVV9"
Local cFilVV9 := "'"+xFilial("VV9")+"'"
Local cQuery  := ""
cQuery := "SELECT DISTINCT VV9_FILIAL"
cQuery += "  FROM "+RetSqlName("VV9")
cQuery += " WHERE VV9_FILIAL <> "+cFilVV9
cQuery += "   AND VV9_STATUS = 'F'"
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVV9, .T., .T. )
Do While !( cAliasVV9 )->( Eof() )
	cFilVV9 += ",'"+( cAliasVV9 )->( VV9_FILIAL )+"'"
	( cAliasVV9 )->(dbSkip())
Enddo
(cAliasVV9)->(dbCloseArea())
DbSelectArea("VWC") // Alias do Browse inicial
cQuery := "SELECT * FROM ( SELECT "
cQuery += "VV0.VV0_FILREM , VV9.VV9_FILIAL , VV9.VV9_NUMATE , VV0.VV0_DATMOV , "
cQuery += "VVA.VVA_CHASSI , VVA.VVA_CHAINT , VVA.VVA_CODMAR , VVA.VVA_MODVEI , "
cQuery += "VV0.VV0_NUMNFI , VV0.VV0_SERNFI , "
cQuery += "VV0.VV0_CODCLI , VV0.VV0_LOJA , SA1.A1_NOME , SA1.A1_MUN , SA1.A1_EST "
cQuery += "  FROM "+RetSqlName("VV9")+" VV9 "
cQuery += "  JOIN "+RetSqlName("VV0")+" VV0 "
cQuery += "    ON VV0.VV0_FILIAL = VV9.VV9_FILIAL "
cQuery += "   AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE "
cQuery += "   AND VV0.VV0_SITNFI = '1'" // 1=Saida Valida
cQuery += "   AND VV0.VV0_GERFIN = '1'" // 1=Gerou Financeiro (Titulos)
cQuery += "   AND VV0.VV0_TIPFAT <> '2'"
cQuery += "   AND VV0.VV0_TPFATR = '1'"
cQuery += "   AND VV0.VV0_REMITO = ' '"
cQuery += "   AND VV0.VV0_FILREM IN ('  ','"+xFilial("SD2")+"')"
cQuery += "   AND VV0.D_E_L_E_T_ = ' '"
cQuery += "  JOIN "+RetSqlName("VVA")+" VVA "
cQuery += "    ON VVA.VVA_FILIAL = VV9.VV9_FILIAL "
cQuery += "   AND VVA.VVA_NUMTRA = VV9.VV9_NUMATE "
cQuery += "   AND VVA.D_E_L_E_T_ = ' '"
cQuery += "  JOIN "+RetSqlName("SA1")+" SA1 "
cQuery += "    ON SA1.A1_FILIAL  = '"+xFilial("SA1")+"'"
cQuery += "   AND SA1.A1_COD     = VV0.VV0_CODCLI "
cQuery += "   AND SA1.A1_LOJA    = VV0.VV0_LOJA "
cQuery += "   AND SA1.D_E_L_E_T_ = ' '"
cQuery += " WHERE VV9.VV9_FILIAL IN ("+cFilVV9+")"
cQuery += "   AND VV9.VV9_STATUS = 'F'"
cQuery += "   AND VV9.D_E_L_E_T_ = ' '"
cQuery += ") TEMPVV0"
Return cQuery

/*/{Protheus.doc} VA3520031_IndexBrowse
	Retorna os Indices do Browse ( browse em SQL )

	@author Andre Luis Almeida
	@since 21/06/2026
/*/
Static Function VA3520031_IndexBrowse()
Local aIndex := {}
Aadd( aIndex, "VV9_FILIAL+VV9_NUMATE")
Aadd( aIndex, "VV0_DATMOV")
Aadd( aIndex, "VVA_CHASSI" )
Aadd( aIndex, "VVA_CHAINT" )
Aadd( aIndex, "VVA_CODMAR+VVA_MODVEI" )
Aadd( aIndex, "VV0_CODCLI+VV0_LOJA" )
Aadd( aIndex, "VV0_NUMNFI+VV0_SERNFI" )
Return aClone(aIndex)

/*/{Protheus.doc} VA3520041_SeeksBrowse
	Retorna os Seek do Browse ( browse em SQL )

	@author Andre Luis Almeida
	@since 21/06/2026
/*/
Static Function VA3520041_SeeksBrowse()
Local aSeek := {}
Aadd( aSeek, { STR0015 + " + " + Alltrim(RetTitle("VV9_NUMATE")) , {{"","C",TamSX3("VV9_FILIAL")[1],0, Alltrim(RetTitle("VV9_FILIAL")),,},{"","C",TamSX3("VV9_NUMATE")[1],0,Alltrim(RetTitle("VV9_NUMATE")),,}}}) // Filial Venda
Aadd( aSeek, { Alltrim(RetTitle("VV0_DATMOV")), {{"","D",TamSX3("VV0_DATMOV")[1],0,Alltrim(RetTitle("VV0_DATMOV")),,}} } )
Aadd( aSeek, { Alltrim(RetTitle("VVA_CHASSI")), {{"","C",TamSX3("VVA_CHASSI")[1],0,Alltrim(RetTitle("VVA_CHASSI")),,}} } )
Aadd( aSeek, { Alltrim(RetTitle("VVA_CHAINT")), {{"","C",TamSX3("VVA_CHAINT")[1],0,Alltrim(RetTitle("VVA_CHAINT")),,}} } )
Aadd( aSeek, { Alltrim(RetTitle("VVA_CODMAR")) + " + " + Alltrim(RetTitle("VVA_MODVEI")) , {{"","C",TamSX3("VVA_CODMAR")[1],0, Alltrim(RetTitle("VVA_CODMAR")),,},{"","C",TamSX3("VVA_MODVEI")[1],0,Alltrim(RetTitle("VVA_MODVEI")),,}}})
Aadd( aSeek, { Alltrim(RetTitle("VV0_CODCLI")) + " + " + Alltrim(RetTitle("VV0_LOJA"))   , {{"","C",TamSX3("VV0_CODCLI")[1],0, Alltrim(RetTitle("VV0_CODCLI")),,},{"","C",TamSX3("VV0_LOJA")[1]  ,0,Alltrim(RetTitle("VV0_LOJA"))  ,,}}})
Aadd( aSeek, { Alltrim(RetTitle("VV0_NUMNFI")) + " + " + Alltrim(RetTitle("VV0_SERNFI")) , {{"","C",TamSX3("VV0_NUMNFI")[1],0, Alltrim(RetTitle("VV0_NUMNFI")),,},{"","C",TamSX3("VV0_SERNFI")[1],0,Alltrim(RetTitle("VV0_SERNFI")),,}}})
Return aClone(aSeek)

/*/{Protheus.doc} VA3520051_ColunBrowse
	Retorna as Colunas do Browse ( browse em SQL )

	@author Andre Luis Almeida
	@since 21/06/2026
/*/
Static Function VA3520051_ColunBrowse()
Local nCol     := 0
Local aColTot  := {}
Local aColumns := {}
aAdd(aColTot,{"VV0_FILREM"      ,"VV0_FILREM",10,STR0016}) // Filial Entrega
aAdd(aColTot,{"VV9_FILIAL"      ,"VV9_FILIAL",10,STR0015}) // Filial Venda
aAdd(aColTot,{"VV9_NUMATE"      ,"VV9_NUMATE",10,""})
aAdd(aColTot,{"Stod(VV0_DATMOV)","VV0_DATMOV", 8,""})
aAdd(aColTot,{"VVA_CHASSI"      ,"VVA_CHASSI",30,""})
aAdd(aColTot,{"VVA_CHAINT"      ,"VVA_CHAINT", 8,""})
aAdd(aColTot,{"VVA_CODMAR"      ,"VVA_CODMAR", 5,""})
aAdd(aColTot,{"VVA_MODVEI"      ,"VVA_MODVEI",13,""})
aAdd(aColTot,{"VV0_NUMNFI"      ,"VV0_NUMNFI",10,""})
aAdd(aColTot,{"VV0_SERNFI"      ,"VV0_SERNFI", 5,""})
aAdd(aColTot,{"VV0_CODCLI"      ,"VV0_CODCLI",10,""})
aAdd(aColTot,{"VV0_LOJA"        ,"VV0_LOJA"  , 5,""})
aAdd(aColTot,{"A1_NOME"         ,"A1_NOME"   ,17,""})
aAdd(aColTot,{"A1_MUN"          ,"A1_MUN"    ,17,""})
aAdd(aColTot,{"A1_EST"          ,"A1_EST"    , 7,""})
For nCol := 1 to len(aColTot)
	aAdd(aColumns,FWBrwColumn():New())
		aColumns[nCol]:SetData( &("{|| "+aColTot[nCol,1]+" }") )
		aColumns[nCol]:SetTitle(IIf(!Empty(aColTot[nCol,4]),aColTot[nCol,4],RetTitle(aColTot[nCol,2])))
		aColumns[nCol]:SetSize(aColTot[nCol,3]) // %
Next
Return aClone(aColumns)

/*/{Protheus.doc} VA3520061_Entrada
	Chamada dos Parametros para gerar a Entrada do Remito que possibilita a Entrega

	@author Andre Luis Almeida
	@since 23/06/2026
/*/
Function VA3520061_Entrada()
If VWC->VWC_STATUS $ "3/4" // STATUS - Cancelado
	FMX_HELP("VEIA352ERR05",STR0018,STR0017) // Transferência já Cancelada. / Impossivel continuar
	Return
ElseIf VWC->VWC_STATUS == "2" // STATUS - Concluido
	FMX_HELP("VEIA352ERR06",STR0019,STR0017) // Transferência já Concluida com Saida e Entrada. / Impossivel continuar
	Return
Else
	If VWC->VWC_FILENT == xFilial("SD2")
		VEIA355(VWC->(RecNo())) // Executa processo
	Else
		FMX_HELP("VEIA352ERR07",STR0020,STR0017) // Filial de Entrada diferente da Filial logada. / Impossivel continuar
		Return
	EndIf
EndIf
Return

/*/{Protheus.doc} VA3520071_Cancelar
	Cancelar Remitos de Entrada/Saida
	- VWC_STATUS == "1" ( Saida Efetivada aguardando Entrada em outra Filial )
	- VWC_STATUS == "2" ( Transferência Concluida )
	- VWC_STATUS == "3" ( Transferência Cancelada somente na Filial de Entrada )
	- VWC_STATUS == "4" ( Transferência Cancelada )

	@author Andre Luis Almeida
	@since 23/06/2026
/*/
Function VA3520071_Cancelar()
Local cFilSD2 := xFilial("SD2")
Local nCntFor := 0
Local lQtdSB2 := .f.
Local cQuery  := ""
Local cGruVei := ""
Local cMV_GV  := Left(GetMV("MV_GRUVEI")+Space(50),TamSX3("B1_GRUPO")[1])
Local cMV_VN  := GETMV("MV_LOCVEIN")
Local cMV_VU  := GETMV("MV_LOCVEIU")
Local cMV_VC  := GETMV("MV_LOCVEIC")
Local aVWCVEI := {}
If VWC->VWC_STATUS == "4" // Veififica STATUS - Cancelado
	FMX_HELP("VEIA352ERR02",STR0018,STR0017) // Transferência já Cancelada. / Impossivel continuar
	Return
EndIf
If VWC->VWC_FILSAI == cFilSD2 // SAIDA
	If VWC->VWC_STATUS == "2"
		FMX_HELP("VEIA352ERR03",STR0019,STR0021) // Transferência já Concluida com Saida e Entrada. / Necessário Cancelar a Entrada antes.
		Return
	EndIf
	If MsgYesNo(STR0022,STR0023) // Confirma o Cancelamento da Saida? / Transferência
		Processa( { || VA3540051_Cancelar_Saida() } ) // Cancelar Remito Saida
	EndIf
ElseIf VWC->VWC_FILENT == cFilSD2 // ENTRADA
	If VWC->VWC_STATUS == "3"
		FMX_HELP("VEIA352ERR04",STR0018,STR0017) // Transferência já Cancelada. / Impossivel continuar
		Return
	ElseIf VWC->VWC_STATUS == "2" // Transferencia Confirmada tem que ser a ultima movimentação valida
		cQuery := "SELECT MAX(VWC_CODIGO) "
		cQuery += "  FROM "+RetSQLName("VWC")
		cQuery += " WHERE VWC_FILIAL = '"+VWC->VWC_FILIAL+"'"
		cQuery += "   AND VWC_FILTRA = '"+VWC->VWC_FILTRA+"'"
		cQuery += "   AND VWC_NUMTRA = '"+VWC->VWC_NUMTRA+"'"
		cQuery += "   AND VWC_STATUS <> '4'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		If FM_SQL(cQuery) <> VWC->VWC_CODIGO
			FMX_HELP("VEIA352ERR08",STR0025,STR0017) // A Transferência não é a ultima para este Atendimento. / Impossivel continuar
			Return
		EndIf
		aVWCVEI := VA3520081_Lista_Veiculos()
		Pergunte("MTA260", .F.) // pega config de saldo de terceiros para o MV_PAR03
		For nCntFor := 1 to len(aVWCVEI)
			cGruVei := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(aVWCVEI[nCntFor,1]),cMV_GV)
			If FGX_VV1SB1("CHASSI", aVWCVEI[nCntFor,2] , /* cMVMIL0010 */ , cGruVei )
				cLocVei := VV1->VV1_LOCPAD
				If Empty(VV1->VV1_LOCPAD)
					cLocVei := IIf(VV1->VV1_ESTVEI<>"1",cMV_VN,cMV_VU) //Novo/Usado
					cLocVei := IIf(VV1->VV1_SITVEI=="4",cMV_VC,cLocVei) //Consignado
				EndIf
				SB2->(dbSetOrder(1))
				SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD + cLocVei ) )
				lQtdSB2 := ( SaldoMov(,,, If(MV_PAR03 == 1, .F., .T.),,,,) > 0 )
			EndIf
			If !lQtdSB2 // NAO existe estoque do Veiculo na SB2
				FMX_HELP("VEIA352ERR09",STR0026,STR0017) // Veículo/Máquina não esta mais no Estoque. / Impossivel continuar
				Return
			EndIf
		Next
	EndIf
	If MsgYesNo(STR0024,STR0023) // Confirma o Cancelamento da Entrada? / Transferência
		Processa( { || VA3550051_Cancelar_Entrada() } ) // Cancelar Remito Entrada
	EndIf
EndIf
Return

/*/{Protheus.doc} VA3520081_Lista_Veiculos
Lista Veiculos/Maquinas relacionadas ao Remito (SF1)

@author Andre Luis Almeida
@since 26/06/2026
/*/
Static Function VA3520081_Lista_Veiculos()
Local aVWCVEI := {}
Local cSQLAux := "SQLVVA"
Local cQuery  := ""
VV2->(DbSetOrder(1))
VVC->(DbSetOrder(1))
cQuery := "SELECT VVA_CHAINT , VVA_CHASSI , VVA_CODMAR , VVA_MODVEI , VVA_SEGMOD "
cQuery += "  FROM "+RetSqlName("VVA")
cQuery += " WHERE VVA_FILIAL = '"+VWC->VWC_FILTRA+"'"
cQuery += "   AND VVA_NUMTRA = '"+VWC->VWC_NUMTRA+"'"
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux, .F., .T. )
While !(cSQLAux)->(Eof())
	VV2->(MsSeek(xFilial("VV2")+(cSQLAux)->( VVA_CODMAR )+(cSQLAux)->( VVA_MODVEI )+(cSQLAux)->( VVA_SEGMOD )))
	aAdd(aVWCVEI,{	(cSQLAux)->( VVA_CHAINT ) ,;
					(cSQLAux)->( VVA_CHASSI ) ,;
					(cSQLAux)->( VVA_CODMAR ) ,;
					Alltrim((cSQLAux)->( VVA_MODVEI ))+" - "+Alltrim(VV2->VV2_DESMOD) })
	(cSQLAux)->(dbSkip())
EndDo
(cSQLAux)->(dbCloseArea())
DbSelectArea("VWC")
Return aVWCVEI