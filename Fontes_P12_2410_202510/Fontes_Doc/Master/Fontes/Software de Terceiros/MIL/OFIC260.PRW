#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#Include "OFIC260.CH"

//CONSULTA DADOS DA NEGOCIAÇÃO DO ORCAMENTO DE PEÇAS BALCÃO
Function OFIC260( cFilOrc , cNumOrc , nQualVAI )

Local oBrwOC260
Local cFaseSep  := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase Aguardando Separação / Conferencia
Private nTipUsr := 0
Private aRotina := {}
Default cFilOrc := ""
Default cNumOrc := ""
Default nQualVAI := 0 // 0 = Pergunta qual VAI utilizar / 1 = Vendedor / 2 = Usuário Logado

nTipUsr := nQualVAI // 0 = Pergunta qual VAI utilizar / 1 = Vendedor / 2 = Usuário Logado

If Empty(cFilOrc+cNumOrc)
	
	DbSelectArea("VS1")
	oBrwOC260 := FWMBrowse():New()
	oBrwOC260:SetAlias("VS1")
	oBrwOC260:DisableLocate()
	oBrwOC260:DisableDetails()
	oBrwOC260:SetAmbiente(.F.)
	oBrwOC260:SetWalkthru(.F.)
	oBrwOC260:SetDescription(STR0001) // Visualiza Dados da Negociação do Orçamento de Peças Balcão
	oBrwOC260:SetMenuDef("OFIC260") // Mostra Botao Visualizar
	oBrwOC260:AddFilter( STR0002 ,"@ VS1_TIPORC='1' AND VS1_STATUS IN ('0','2','3','"+cFaseSep+"','5','R','T') ",.t.,.t.,) // Filtro Padrão - nao deixa desmarcar
	oBrwOC260:AddLegend( " VS1_STATUS == '0' "           , "BR_VERDE"  , STR0003 ) // Orçamento Balcão Digitado
	oBrwOC260:AddLegend( " VS1_STATUS == '2' "           , "BR_PINK"   , STR0004 ) // Orçamento Balcão Margem Pendente
	oBrwOC260:AddLegend( " VS1_STATUS == '3' "           , "BR_BRANCO" , STR0005 ) // Orçamento Balcão Avaliação de Crédito
	oBrwOC260:AddLegend( " VS1_STATUS == '"+cFaseSep+"'" , "BR_AZUL"   , STR0006 ) // Orçamento Balcão Aguardando Separação
	oBrwOC260:AddLegend( " VS1_STATUS == '5' "           , "BR_MARROM" , STR0007 ) // Orçamento Balcão Aguardando Lib.Divergência
	oBrwOC260:AddLegend( " VS1_STATUS $ 'RT' "           , "BR_CINZA"  , STR0008 ) // Orçamento Balcão Aguardando Reserva
	oBrwOC260:SetInsert(.f.)
	oBrwOC260:SetUseFilter()
	oBrwOC260:Activate()

Else

	VS1->(DBSetOrder(1))
	If !VS1->(DBSeek(cFilOrc+cNumOrc))
		MsgStop(STR0009,STR0010) // Orçamento não encontrado! / Atenção
		Return()
	EndIf
	If VS1->VS1_TIPORC $ '1/P' // Orçamento Balcão ou Pedido
		Do Case
			Case VS1->VS1_STATUS $ '023'+cFaseSep+'5RT'
				OC2600011_VisualizarDados() // Visualiza Dados da Negociação do Orçamento Balcão - Tela
			Case VS1->VS1_STATUS == "F"
				MsgStop(STR0011,STR0010) // Impossivel visualizar para Orçamentos com Status Liberado para Faturar. / Atenção
			Case VS1->VS1_STATUS == "X"
				MsgStop(STR0012,STR0010) // Impossivel visualizar para Orçamentos com Status Faturado. / Atenção
			Case VS1->VS1_STATUS == "C"
				MsgStop(STR0013,STR0010) // Impossivel visualizar para Orçamentos com Status Cancelado. / Atenção
			OtherWise
				MsgStop(STR0038+" '"+VS1->VS1_STATUS+"'.",STR0010) // Impossivel visualizar para Orçamentos com Status / Atenção
		EndCase
	Else
		MsgStop(STR0014,STR0010) // Opção disponível apenas para Orçamentos de Peças Balcão. Impossivel continuar. / Atenção
	EndIf

EndIf

Return

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 18/03/2022
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0015 ACTION 'OC2600011_VisualizarDados' OPERATION 2 ACCESS 0 // Visualizar Dados
ADD OPTION aRotina TITLE STR0016 ACTION 'OC2600031_VisualizaOrcamento' OPERATION 2 ACCESS 0 // Visualizar Orçamento

Return aRotina

/*/{Protheus.doc} OC2600011_VisualizarDados
Visualiza Dados da Negociação do Orçamento de Peças Balcão - Tela

@author Andre Luis Almeida
@since 18/03/2022
/*/
Function OC2600011_VisualizarDados()

	Local oWorkArea
	Local nSelUsr   := 0
	Local cObsVend  := ""
	Local aCampos1  := {} // Array para campos da tabela temporária e campos da View
	Local aCampos2  := {} // Array para campos da tabela temporária e campos da View
	Local aSize     := FWGetDialogSize( oMainWnd )
	Private cCadastro := STR0001 // Visualiza Dados da Negociação do Orçamento de Peças Balcão
 
 	// Posiciona no VAI
	nSelUsr := OC2600041_PosicionaVAI()
	If nSelUsr == 2 // Se foi selecionado Usuario Logado
		cObsVend := " ( "+STR0039+" )" // Usuário Logado
	ElseIf nSelUsr == 3 // Cancelada a tela
		Return
	EndIf	

	// Criando tabela temporária
	aadd(aCampos1, {"WZ1_CODVEN",GetSX3Cache("VS1_CODVEN","X3_TIPO"),35	,0} ) // Vendedor
	aadd(aCampos1, {"WZ1_DESPEC",GetSX3Cache("VAI_DESPEC","X3_TIPO"),GetSX3Cache("VAI_DESPEC","X3_TAMANHO")	,GetSX3Cache("VAI_DESPEC","X3_DECIMAL")} ) // % Max. do Vendedor para Desconto de Peças
	aadd(aCampos1, {"WZ1_FORPAG",GetSX3Cache("VS1_FORPAG","X3_TIPO"),35	,0} ) // Condição de Pagamento
	aadd(aCampos1, {"WZ1_PERREM",GetSX3Cache("VS1_PERREM","X3_TIPO"),GetSX3Cache("VS1_PERREM","X3_TAMANHO")	,GetSX3Cache("VS1_PERREM","X3_DECIMAL")} ) // % Remuneração

	// Criando tabela temporária
	aadd(aCampos2, {"WZ2_CORLEG","C",1,0} ) // Cor Legenda - Filtros
	aadd(aCampos2, {"WZ2_GRUITE",GetSX3Cache("VS7_GRUITE","X3_TIPO"),GetSX3Cache("VS7_GRUITE","X3_TAMANHO")	,0} ) // Grupo do Item
	aadd(aCampos2, {"WZ2_CODITE",GetSX3Cache("VS7_CODITE","X3_TIPO"),GetSX3Cache("VS7_CODITE","X3_TAMANHO")	,0} ) // Codigo do Item
	aadd(aCampos2, {"WZ2_DESITE",GetSX3Cache("B1_DESC","X3_TIPO"),GetSX3Cache("B1_DESC","X3_TAMANHO")	,0} ) // Descrição
	aadd(aCampos2, {"WZ2_QTDITE",GetSX3Cache("VS7_QTDITE","X3_TIPO"),GetSX3Cache("VS7_QTDITE","X3_TAMANHO")	,GetSX3Cache("VS7_QTDITE","X3_DECIMAL")} ) // Quantidade do Item
	aadd(aCampos2, {"WZ2_VALORI",GetSX3Cache("VS3_VALTOT","X3_TIPO"),GetSX3Cache("VS3_VALTOT","X3_TAMANHO")	,GetSX3Cache("VS3_VALTOT","X3_DECIMAL")} ) // Valor Original
	aadd(aCampos2, {"WZ2_DESPER",GetSX3Cache("VS7_DESPER","X3_TIPO"),GetSX3Cache("VS7_DESPER","X3_TAMANHO")	,GetSX3Cache("VS7_DESPER","X3_DECIMAL")} ) // % Desconto Permitido
	aadd(aCampos2, {"WZ2_VALPER",GetSX3Cache("VS3_VALTOT","X3_TIPO"),GetSX3Cache("VS3_VALTOT","X3_TAMANHO")	,GetSX3Cache("VS3_VALTOT","X3_DECIMAL")} ) // Valor Permitido
	aadd(aCampos2, {"WZ2_DESDES",GetSX3Cache("VS7_DESDES","X3_TIPO"),GetSX3Cache("VS7_DESDES","X3_TAMANHO")	,GetSX3Cache("VS7_DESDES","X3_DECIMAL")} ) // % Desconto Desejado
	aadd(aCampos2, {"WZ2_VALDES",GetSX3Cache("VS3_VALTOT","X3_TIPO"),GetSX3Cache("VS3_VALTOT","X3_TAMANHO")	,GetSX3Cache("VS3_VALTOT","X3_DECIMAL")} ) // Valor Desejado
	aadd(aCampos2, {"WZ2_MARLUC",GetSX3Cache("VS7_MARLUC","X3_TIPO"),GetSX3Cache("VS7_MARLUC","X3_TAMANHO")	,GetSX3Cache("VS7_MARLUC","X3_DECIMAL")} ) // Margem de Lucro
	aadd(aCampos2, {"WZ2_MARPER",GetSX3Cache("VS7_MARPER","X3_TIPO"),GetSX3Cache("VS7_MARPER","X3_TAMANHO")	,GetSX3Cache("VS7_MARPER","X3_DECIMAL")} ) // Margem Permitida

	oTmpTable1 := OFDMSTempTable():New()
	oTmpTable1:cAlias := "TEMPA"
	oTmpTable1:aVetCampos := aCampos1
	oTmpTable1:AddIndex(, {"WZ1_CODVEN"} )
	oTmpTable1:CreateTable()

	oTmpTable2 := OFDMSTempTable():New()
	oTmpTable2:cAlias := "TEMPB"
	oTmpTable2:aVetCampos := aCampos2
	oTmpTable2:AddIndex(, {"WZ2_GRUITE","WZ2_CODITE"} )
	oTmpTable2:CreateTable()

	aCampos1 := {;
					{STR0017+cObsVend,"WZ1_CODVEN", GetSX3Cache("VS1_CODVEN"	,"X3_TIPO"),30,0, Alltrim(GetSX3Cache("VS1_CODVEN"	,"X3_PICTURE")),0,.f.},;// Vendedor
					{STR0018,"WZ1_DESPEC", GetSX3Cache("VAI_DESPEC"	,"X3_TIPO"),25,0, Alltrim(GetSX3Cache("VAI_DESPEC"	,"X3_PICTURE"))+" %",GetSX3Cache("VAI_DESPEC","X3_DECIMAL"),.f.},;// % Max. do Vendedor para Desconto de Peças
					{STR0019,"WZ1_FORPAG", GetSX3Cache("VS1_FORPAG"	,"X3_TIPO"),25,0, Alltrim(GetSX3Cache("VS1_FORPAG"	,"X3_PICTURE")),0,.f.},;// Condição de Pagamento
					{STR0020,"WZ1_PERREM", GetSX3Cache("VS1_PERREM"	,"X3_TIPO"),20,2, Alltrim(GetSX3Cache("VS1_PERREM"	,"X3_PICTURE"))+" %",GetSX3Cache("VS1_PERREM","X3_DECIMAL"),.f.} ;// % Remuneração
	}

	aCampos2 := {;
					{STR0021,"WZ2_GRUITE", GetSX3Cache("VS7_GRUITE"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_GRUITE"	,"X3_PICTURE")),GetSX3Cache("VS7_GRUITE","X3_DECIMAL"),.f.},;// Grupo do Item
					{STR0022,"WZ2_CODITE", GetSX3Cache("VS7_CODITE"	,"X3_TIPO"),15,0, Alltrim(GetSX3Cache("VS7_CODITE"	,"X3_PICTURE")),GetSX3Cache("VS7_CODITE"	,"X3_DECIMAL"),.f.},;// Código do Item
					{STR0023,"WZ2_DESITE", GetSX3Cache("B1_DESC"	,"X3_TIPO"),15,0, Alltrim(GetSX3Cache("B1_DESC"   	,"X3_PICTURE")),GetSX3Cache("B1_DESC"	,"X3_DECIMAL"),.f.},;// Descrição
					{STR0025,"WZ2_QTDITE", GetSX3Cache("VS7_QTDITE"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_QTDITE"	,"X3_PICTURE")),GetSX3Cache("VS7_QTDITE","X3_DECIMAL"),.f.},;// Quantidade
					{STR0024,"WZ2_VALORI", GetSX3Cache("VS3_VALTOT"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS3_VALTOT"	,"X3_PICTURE")),GetSX3Cache("VS3_VALTOT","X3_DECIMAL"),.f.},;// Valor Original
					{STR0026,"WZ2_DESPER", GetSX3Cache("VS7_DESPER"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_DESPER"	,"X3_PICTURE"))+" %",GetSX3Cache("VS7_DESPER","X3_DECIMAL"),.f.},;// % Desconto Permitido
					{STR0027,"WZ2_VALPER", GetSX3Cache("VS3_VALTOT"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS3_VALTOT"	,"X3_PICTURE")),GetSX3Cache("VS3_VALTOT","X3_DECIMAL"),.f.},;// Valor Permitido
					{STR0028,"WZ2_DESDES", GetSX3Cache("VS7_DESDES"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_DESDES"	,"X3_PICTURE"))+" %",GetSX3Cache("VS7_DESDES","X3_DECIMAL"),.f.},;// % Desconto Desejado
					{STR0029,"WZ2_VALDES", GetSX3Cache("VS3_VALTOT"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS3_VALTOT"	,"X3_PICTURE")),GetSX3Cache("VS3_VALTOT","X3_DECIMAL"),.f.},;// Valor Desejado
					{STR0030,"WZ2_MARLUC", GetSX3Cache("VS7_MARLUC"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_MARLUC"	,"X3_PICTURE"))+" %",GetSX3Cache("VS7_MARLUC","X3_DECIMAL"),.f.},;// Margem de Lucro
					{STR0031,"WZ2_MARPER", GetSX3Cache("VS7_MARPER"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_MARPER"	,"X3_PICTURE"))+" %",GetSX3Cache("VS7_MARPER","X3_DECIMAL"),.f.} ;// Margem Permitida
	}

	OC2600021_LevantaDados()

	oDlgOC260 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		oWorkArea := FWUIWorkArea():New( oDlgOC260 )
		
		oWorkArea:CreateHorizontalBox( "LINE01", 30 )
		oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
		oWorkArea:CreateHorizontalBox( "LINE02", 70 )
		oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )
		oWorkArea:Activate()

		// Criação do browse de tela
		oBrowseA := FWMBrowse():New( )
		oBrowseA:SetOwner(oWorkarea:GetPanel("OBJ1"))
		oBrowseA:SetTemporary(.T.) 
		oBrowseA:DisableDetails()
		oBrowseA:DisableConfig()
		oBrowseA:DisableReport()
		oBrowseA:SetFixedBrowse(.T.)
		oBrowseA:SetAlias("TEMPA")
		oBrowseA:SetFields(aCampos1)
		oBrowseA:SetMenuDef("")
		oBrowseA:SetInsert(.f.)
		oBrowseA:SetUseFilter(.f.)
		oBrowseA:AddButton(STR0032, {|| oDlgOC260:End() },,,, .F., 2) // Fechar
		oBrowseA:ForceQuitButton()
		oBrowseA:SetDescription(cCadastro+": "+VS1->VS1_NUMORC)
		oBrowseA:Activate()

		// Criação do browse de tela
		oBrowseB := FWMBrowse():New( )
		oBrowseB:SetOwner(oWorkarea:GetPanel("OBJ2"))
		oBrowseB:SetTemporary(.T.) 
		oBrowseB:DisableDetails()
		oBrowseB:AddLegend(" WZ2_CORLEG == '0' ", "WHITE"  , STR0033) // Item sem problemas
		oBrowseB:AddLegend(" WZ2_CORLEG == '1' ", "YELLOW" , STR0034) // Item com problema de Desconto
		oBrowseB:AddLegend(" WZ2_CORLEG == '2' ", "ORANGE" , STR0035) // Item com problema de Margem
		oBrowseB:AddLegend(" WZ2_CORLEG == '3' ", "RED"    , STR0036) // Item com problema de Desconto e Margem
		oBrowseB:DisableConfig()
		oBrowseB:DisableReport()
		oBrowseB:SetFixedBrowse(.T.)
		oBrowseB:SetAlias("TEMPB")
		oBrowseB:SetFields(aCampos2)
		oBrowseB:SetMenuDef("")
		oBrowseB:ForceQuitButton()
		oBrowseB:SetDescription(STR0037+" ( "+STR0044+" )") // Itens / valores unitários
		oBrowseB:Activate()

	oDlgOC260:Activate( , , , , , , /*EnchoiceBar( oDlgOC260, { || oDlgOC260:End() }, { || oDlgOC260:End() }, , , , , , , .F., .T. )*/ ) //ativa a janela

	oTmpTable1:CloseTable()
	oTmpTable2:CloseTable()

Return

/*/{Protheus.doc} OC2600021_LevantaDados
Levanta Dados da Negociação do Orçamento para apresentação

@author Andre Luis Almeida
@since 21/03/2022
/*/
Static Function OC2600021_LevantaDados()

Local nValPerm := 0
Local nDesPerm := 0
Local aRetDes  := {}
Local cCorLeg  := "0"
Local dDatRef  := dDataBase

If VAI->VAI_DTCDES == "1" // Utilizar 1=Data de Inclusão do Orçamento para validar a Politica de Desconto
	dDatRef := VS1->VS1_DATORC
EndIf

SA3->(DBSetOrder(1))
SA3->(DBSeek(xFilial("SA3")+VAI->VAI_CODVEN))

SE4->(DBSetOrder(1))
SE4->(DBSeek(xFilial("SE4")+VS1->VS1_FORPAG))

RecLock("TEMPA",.T.)
	TEMPA->WZ1_CODVEN := VAI->VAI_CODVEN+" - "+SA3->A3_NOME
	TEMPA->WZ1_DESPEC := VAI->VAI_DESPEC
	TEMPA->WZ1_FORPAG := VS1->VS1_FORPAG+" - "+SE4->E4_DESCRI
	TEMPA->WZ1_PERREM := VS1->VS1_PERREM
TEMPA->(MsUnlock())

DBSelectArea("VS3")
DBSetOrder(1)
DBSeek(VS1->VS1_FILIAL+VS1->VS1_NUMORC)
while !eof() .and. VS1->VS1_FILIAL+VS1->VS1_NUMORC == VS3->VS3_FILIAL+VS3->VS3_NUMORC
	SBM->(dbSetOrder(1))
	SBM->(dbSeek(xFilial("SBM")+VS3->VS3_GRUITE))
	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
	// 3 - Retorna Valor, Desconto e Margem
	aRetDes := OX005PERDES(SBM->BM_CODMAR,VS1->VS1_CENCUS,VS3->VS3_GRUITE,VS3->VS3_CODITE,VS3->VS3_QTDITE,VS3->VS3_PERDES,.t.,VS1->VS1_CLIFAT,VS1->VS1_LOJA,VS1->VS1_TIPVEN,VS3->VS3_VALTOT/VS3->VS3_QTDITE,3,VS1->VS1_FORPAG,,,,VS1->VS1_CONPRO,dDatRef,VS1->VS1_PERREM)
	If aRetDes[2] >= VAI->VAI_DESPEC
		nDesPerm := aRetDes[2] - VS1->VS1_PERREM
	Else
		nDesPerm := VAI->VAI_DESPEC - VS1->VS1_PERREM
	EndIf
	If nDesPerm < 0 .or. ( len(aRetDes) > 3 .and. aRetDes[4] == "0" ) // 0 = NAO PODE DAR DESCONTO EM PROMOCAO
		nDesPerm := 0
	EndIf
	If nDesPerm > 0
		nValPerm := ( VS3->VS3_VALPEC - ( VS3->VS3_VALPEC * ( nDesPerm / 100 ) ) )
	ElseIf aRetDes[1] > 0
		nValPerm := aRetDes[1]
	Else
		nValPerm := VS3->VS3_VALPEC
	EndIf
	cCorLeg := "0"
	if VS3->VS3_PERDES > nDesPerm
		cCorLeg := "1" // Problema de Desconto
	endif
	if VS3->VS3_MARLUC < aRetDes[3]
		If cCorLeg == "0"
			cCorLeg := "2" // Problema de Margem
		Else
			cCorLeg := "3" // Problema de Desconto e Margem
		EndIf
	endif
	RecLock("TEMPB",.T.)
		TEMPB->WZ2_CORLEG := cCorLeg
		TEMPB->WZ2_GRUITE := VS3->VS3_GRUITE
		TEMPB->WZ2_CODITE := VS3->VS3_CODITE
		TEMPB->WZ2_DESITE := SB1->B1_DESC
		TEMPB->WZ2_QTDITE := VS3->VS3_QTDITE
		TEMPB->WZ2_VALORI := VS3->VS3_VALPEC
		TEMPB->WZ2_DESPER := nDesPerm
		TEMPB->WZ2_VALPER := nValPerm
		TEMPB->WZ2_DESDES := VS3->VS3_PERDES
		TEMPB->WZ2_VALDES := VS3->VS3_VALPEC - (VS3->VS3_VALDES/VS3->VS3_QTDITE)
		TEMPB->WZ2_MARLUC := VS3->VS3_MARLUC
		TEMPB->WZ2_MARPER := aRetDes[3]
	TEMPB->(MsUnlock())
	DBSelectArea("VS3")
	DBSkip()
Enddo
Return

/*/{Protheus.doc} OC2600031_VisualizaOrcamento
Visualiza Orçamento

@author Andre Luis Almeida
@since 22/03/2022
/*/
Function OC2600031_VisualizaOrcamento()

If !IsInCallStack("OFIC170") // Se não chamou por ela mesma
	OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
EndIf

Return

/*/{Protheus.doc} OC2600041_PosicionaVAI
Visualiza Orçamento

@author Andre Luis Almeida
@since 11/05/2022
/*/
Static Function OC2600041_PosicionaVAI()
Local nSelUsr := nTipUsr
Local cMensag := ""
Do Case
	Case nSelUsr == 0 // Pergunta qual VAI utilizar
		VAI->(DBSetOrder(4))
		VAI->(DBSeek(xFilial("VAI")+__cUserID))
		If VAI->VAI_CODVEN <> VS1->VS1_CODVEN
			cMensag := STR0001+CHR(13)+CHR(10)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Visualiza Dados da Negociação do Orçamento de Peças Balcão
			cMensag += STR0040+": "+VS1->VS1_FILIAL+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Filial
			cMensag += STR0041+": "+VS1->VS1_NUMORC+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Nro.Orçamento
			cMensag += STR0042+": "+VS1->VS1_CLIFAT+"-"+VS1->VS1_LOJA+" "+left(VS1->VS1_NCLIFT,35)+CHR(13)+CHR(10)+CHR(13)+CHR(10) // Cliente
			cMensag += STR0017+": "+VS1->VS1_CODVEN+" "+left(FM_SQL("SELECT A3_NOME FROM "+RetSqlName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+VS1->VS1_CODVEN+"' AND D_E_L_E_T_=' '"),30) // Vendedor
			// Pergunta qual VAI utilizar
			nSelUsr := Aviso(STR0010, cMensag , { STR0017 , STR0039 , STR0043 } , 3 ) // Atenção / Vendedor / Usuário Logado / Cancelar
			If nSelUsr == 1 // Vendedor
				VAI->(DBSetOrder(6))
				VAI->(DBSeek(xFilial("VAI")+VS1->VS1_CODVEN))
			EndIf
		EndIf
	Case nSelUsr == 1 // Vendedor
		VAI->(DBSetOrder(6))
		VAI->(DBSeek(xFilial("VAI")+VS1->VS1_CODVEN))
	Case nSelUsr == 2 // Usuario Logado
		VAI->(DBSetOrder(4))
		VAI->(DBSeek(xFilial("VAI")+__cUserID))
EndCase
Return nSelUsr