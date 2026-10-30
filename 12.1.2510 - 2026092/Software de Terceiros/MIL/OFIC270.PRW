#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#Include "OFIC270.CH"

// Posições do vetor aVetTTP (OFIXX100)
#DEFINE ATT_VETSEL  01 // Controle para Marcar o TT para Fechamento
#DEFINE ATT_NUMOSV  02 // OS
#DEFINE ATT_TIPTEM  03 // Tipo de Tempo
#DEFINE ATT_CLIENTE 04 // Faturar Para
#DEFINE ATT_LOJA    10 // Loja do Cliente Faturar Para
#DEFINE ATT_LIBVOO  20 // Numero da Liberacao (VOO_LIBVOO)

//CONSULTA DADOS DA NEGOCIAÇÃO DE PEÇAS DA ORDEM DE SERVICO
Function OFIC270( aTTPo , aHVO3 , aCVO3 )
	Local oWorkArea
	Local aSize      := FWGetDialogSize( oMainWnd )
	Local aCampos1   := {} // Array para campos da tabela temporária e campos da View
	Local aCampos2   := {} // Array para campos da tabela temporária e campos da View
	Private cCadastro := STR0001 // Visualiza Dados da Negociação de Peças da Ordem de Serviço
	Private aRotina  := {}
	Private aVetTTPo := {}
	Private aHeadVO3 := {}
	Private aColsVO3 := {}
	Default aTTPo    := {}
	Default aHVO3    := {}
	Default aCVO3    := {}

	If len(aTTPo) == 0 .or. len(aHVO3) == 0 .or. len(aCVO3) == 0
		MsgInfo(STR0027,STR0026) // Não existem dados para essa consulta. / Atenção
		Return
	EndIf

	aVetTTPo := aClone(aTTPo)
	aHeadVO3 := aClone(aHVO3)
	aColsVO3 := aClone(aCVO3)

// Visualiza Dados da Negociação de Peças da Ordem de Serviço - Tela

	// Criando tabela temporária
	aadd(aCampos1, {"WZ1_NUMOSV",GetSX3Cache("VO1_NUMOSV","X3_TIPO"),GetSX3Cache("VO1_NUMOSV","X3_TAMANHO")	,0} ) // Numero da OS
	aadd(aCampos1, {"WZ1_TIPTEM",GetSX3Cache("VO3_TIPTEM","X3_TIPO"),GetSX3Cache("VO3_TIPTEM","X3_TAMANHO")	,0} ) // Tipo de Tempo
	aadd(aCampos1, {"WZ1_LIBVOO",GetSX3Cache("VO3_LIBVOO","X3_TIPO"),GetSX3Cache("VO3_LIBVOO","X3_TAMANHO")	,0} ) // Liberação
	aadd(aCampos1, {"WZ1_CODVEN",GetSX3Cache("VAI_CODVEN","X3_TIPO"),30	,0} ) // Vendedor
	aadd(aCampos1, {"WZ1_DESPEC",GetSX3Cache("VAI_DESPEC","X3_TIPO"),GetSX3Cache("VAI_DESPEC","X3_TAMANHO")	,GetSX3Cache("VAI_DESPEC","X3_DECIMAL")} ) // % Max. do Vendedor para Desconto de Peças
	aadd(aCampos1, {"WZ1_FORPAG",GetSX3Cache("VOO_CONDPG","X3_TIPO"),30	,0} ) // Condição de Pagamento
	aadd(aCampos1, {"WZ1_PERREM",GetSX3Cache("VOO_PERREM","X3_TIPO"),GetSX3Cache("VOO_PERREM","X3_TAMANHO")	,GetSX3Cache("VOO_PERREM","X3_DECIMAL")} ) // % Remuneração

	// Criando tabela temporária
	aadd(aCampos2, {"WZ2_CORLEG","C",1,0} ) // Cor Legenda - Filtros
	aadd(aCampos2, {"WZ2_GRUITE",GetSX3Cache("VS7_GRUITE","X3_TIPO"),GetSX3Cache("VS7_GRUITE","X3_TAMANHO")	,0} ) // Grupo do Item
	aadd(aCampos2, {"WZ2_CODITE",GetSX3Cache("VS7_CODITE","X3_TIPO"),GetSX3Cache("VS7_CODITE","X3_TAMANHO")	,0} ) // Codigo do Item
	aadd(aCampos2, {"WZ2_DESITE",GetSX3Cache("B1_DESC","X3_TIPO"),GetSX3Cache("B1_DESC","X3_TAMANHO")	,0} ) // Descrição
	aadd(aCampos2, {"WZ2_QTDITE",GetSX3Cache("VS7_QTDITE","X3_TIPO"),GetSX3Cache("VS7_QTDITE","X3_TAMANHO")	,GetSX3Cache("VS7_QTDITE","X3_DECIMAL")} ) // Quantidade do Item
	aadd(aCampos2, {"WZ2_VALORI",GetSX3Cache("VO3_VALBRU","X3_TIPO"),GetSX3Cache("VO3_VALBRU","X3_TAMANHO")	,GetSX3Cache("VO3_VALBRU","X3_DECIMAL")} ) // Valor Original
	aadd(aCampos2, {"WZ2_DESPER",GetSX3Cache("VS7_DESPER","X3_TIPO"),GetSX3Cache("VS7_DESPER","X3_TAMANHO")	,GetSX3Cache("VS7_DESPER","X3_DECIMAL")} ) // % Desconto Permitido
	aadd(aCampos2, {"WZ2_VALPER",GetSX3Cache("VO3_VALBRU","X3_TIPO"),GetSX3Cache("VO3_VALBRU","X3_TAMANHO")	,GetSX3Cache("VO3_VALBRU","X3_DECIMAL")} ) // Valor Permitido
	aadd(aCampos2, {"WZ2_DESDES",GetSX3Cache("VS7_DESDES","X3_TIPO"),GetSX3Cache("VS7_DESDES","X3_TAMANHO")	,GetSX3Cache("VS7_DESDES","X3_DECIMAL")} ) // % Desconto Desejado
	aadd(aCampos2, {"WZ2_VALDES",GetSX3Cache("VO3_VALBRU","X3_TIPO"),GetSX3Cache("VO3_VALBRU","X3_TAMANHO")	,GetSX3Cache("VO3_VALBRU","X3_DECIMAL")} ) // Valor Desejado
	aadd(aCampos2, {"WZ2_MARLUC",GetSX3Cache("VS7_MARLUC","X3_TIPO"),GetSX3Cache("VS7_MARLUC","X3_TAMANHO")	,GetSX3Cache("VS7_MARLUC","X3_DECIMAL")} ) // Margem de Lucro
	aadd(aCampos2, {"WZ2_MARPER",GetSX3Cache("VS7_MARPER","X3_TIPO"),GetSX3Cache("VS7_MARPER","X3_TAMANHO")	,GetSX3Cache("VS7_MARPER","X3_DECIMAL")} ) // Margem Permitida

	oTmpTable1 := OFDMSTempTable():New()
	oTmpTable1:cAlias := "TEMPA"
	oTmpTable1:aVetCampos := aCampos1
	oTmpTable1:AddIndex(, {"WZ1_NUMOSV","WZ1_TIPTEM"} )
	oTmpTable1:CreateTable()

	oTmpTable2 := OFDMSTempTable():New()
	oTmpTable2:cAlias := "TEMPB"
	oTmpTable2:aVetCampos := aCampos2
	oTmpTable2:AddIndex(, {"WZ2_GRUITE","WZ2_CODITE"} )
	oTmpTable2:CreateTable()

	aCampos1 := {;
					{STR0002,"WZ1_NUMOSV", GetSX3Cache("VO1_NUMOSV"	,"X3_TIPO"),15,0, Alltrim(GetSX3Cache("VO1_NUMOSV"	,"X3_PICTURE")),0,.f.},;// Numero da OS
					{STR0003,"WZ1_TIPTEM", GetSX3Cache("VO3_TIPTEM"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VO3_TIPTEM"	,"X3_PICTURE")),0,.f.},;// Tipo de Tempo
					{STR0004,"WZ1_LIBVOO", GetSX3Cache("VO3_LIBVOO"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VO3_LIBVOO"	,"X3_PICTURE")),0,.f.},;// Liberação
					{STR0005,"WZ1_CODVEN", GetSX3Cache("VAI_CODVEN"	,"X3_TIPO"),20,0, Alltrim(GetSX3Cache("VAI_CODVEN"	,"X3_PICTURE")),0,.f.},;// Vendedor
					{STR0006,"WZ1_DESPEC", GetSX3Cache("VAI_DESPEC"	,"X3_TIPO"),15,0, Alltrim(GetSX3Cache("VAI_DESPEC"	,"X3_PICTURE"))+" %",GetSX3Cache("VAI_DESPEC","X3_DECIMAL"),.f.},;// % Max. do Vendedor para Desconto de Peças
					{STR0007,"WZ1_FORPAG", GetSX3Cache("VOO_CONDPG"	,"X3_TIPO"),15,0, Alltrim(GetSX3Cache("VOO_CONDPG"	,"X3_PICTURE")),0,.f.},;// Condição de Pagamento
					{STR0008,"WZ1_PERREM", GetSX3Cache("VOO_PERREM"	,"X3_TIPO"),15,2, Alltrim(GetSX3Cache("VOO_PERREM"	,"X3_PICTURE"))+" %",GetSX3Cache("VOO_PERREM","X3_DECIMAL"),.f.} ;// % Remuneração
	}

	aCampos2 := {;
					{STR0009,"WZ2_GRUITE", GetSX3Cache("VS7_GRUITE"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_GRUITE"	,"X3_PICTURE")),GetSX3Cache("VS7_GRUITE","X3_DECIMAL"),.f.},;// Grupo do Item
					{STR0010,"WZ2_CODITE", GetSX3Cache("VS7_CODITE"	,"X3_TIPO"),15,0, Alltrim(GetSX3Cache("VS7_CODITE"	,"X3_PICTURE")),GetSX3Cache("VS7_CODITE"	,"X3_DECIMAL"),.f.},;// Código do Item
					{STR0011,"WZ2_DESITE", GetSX3Cache("B1_DESC"	,"X3_TIPO"),15,0, Alltrim(GetSX3Cache("B1_DESC"   	,"X3_PICTURE")),GetSX3Cache("B1_DESC"	,"X3_DECIMAL"),.f.},;// Descrição
					{STR0013,"WZ2_QTDITE", GetSX3Cache("VS7_QTDITE"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_QTDITE"	,"X3_PICTURE")),GetSX3Cache("VS7_QTDITE","X3_DECIMAL"),.f.},;// Quantidade
					{STR0012,"WZ2_VALORI", GetSX3Cache("VO3_VALBRU"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VO3_VALBRU"	,"X3_PICTURE")),GetSX3Cache("VO3_VALBRU","X3_DECIMAL"),.f.},;// Valor Original
					{STR0014,"WZ2_DESPER", GetSX3Cache("VS7_DESPER"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_DESPER"	,"X3_PICTURE"))+" %",GetSX3Cache("VS7_DESPER","X3_DECIMAL"),.f.},;// % Desconto Permitido
					{STR0015,"WZ2_VALPER", GetSX3Cache("VO3_VALBRU"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VO3_VALBRU"	,"X3_PICTURE")),GetSX3Cache("VO3_VALBRU","X3_DECIMAL"),.f.},;// Valor Permitido
					{STR0016,"WZ2_DESDES", GetSX3Cache("VS7_DESDES"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_DESDES"	,"X3_PICTURE"))+" %",GetSX3Cache("VS7_DESDES","X3_DECIMAL"),.f.},;// % Desconto Desejado
					{STR0017,"WZ2_VALDES", GetSX3Cache("VO3_VALBRU"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VO3_VALBRU"	,"X3_PICTURE")),GetSX3Cache("VO3_VALBRU","X3_DECIMAL"),.f.},;// Valor Desejado
					{STR0018,"WZ2_MARLUC", GetSX3Cache("VS7_MARLUC"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_MARLUC"	,"X3_PICTURE"))+" %",GetSX3Cache("VS7_MARLUC","X3_DECIMAL"),.f.},;// Margem de Lucro
					{STR0019,"WZ2_MARPER", GetSX3Cache("VS7_MARPER"	,"X3_TIPO"),10,0, Alltrim(GetSX3Cache("VS7_MARPER"	,"X3_PICTURE"))+" %",GetSX3Cache("VS7_MARPER","X3_DECIMAL"),.f.} ;// Margem Permitida
	}

	OC2700011_LevantaDados()

	oDlgOC270 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		oWorkArea := FWUIWorkArea():New( oDlgOC270 )
		
		oWorkArea:CreateHorizontalBox( "LINE01", 35 )
		oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
		oWorkArea:CreateHorizontalBox( "LINE02", 65 )
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
		oBrowseA:AddButton(STR0020, {|| oDlgOC270:End() },,,, .F., 2) // Fechar
		oBrowseA:ForceQuitButton()
		oBrowseA:SetDescription(cCadastro)
		oBrowseA:Activate()

		// Criação do browse de tela
		oBrowseB := FWMBrowse():New( )
		oBrowseB:SetOwner(oWorkarea:GetPanel("OBJ2"))
		oBrowseB:SetTemporary(.T.) 
		oBrowseB:DisableDetails()
		oBrowseB:AddLegend(" WZ2_CORLEG == '0' ", "WHITE"  , STR0021) // Item sem problemas
		oBrowseB:AddLegend(" WZ2_CORLEG == '1' ", "YELLOW" , STR0022) // Item com problema de Desconto
		oBrowseB:AddLegend(" WZ2_CORLEG == '2' ", "ORANGE" , STR0023) // Item com problema de Margem
		oBrowseB:AddLegend(" WZ2_CORLEG == '3' ", "RED"    , STR0024) // Item com problema de Desconto e Margem
		oBrowseB:DisableConfig()
		oBrowseB:DisableReport()
		oBrowseB:SetFixedBrowse(.T.)
		oBrowseB:SetAlias("TEMPB")
		oBrowseB:SetFields(aCampos2)
		oBrowseB:SetMenuDef("")
		oBrowseB:ForceQuitButton()
		oBrowseB:SetDescription(STR0025+" ( "+STR0028+" )") // Itens / valores unitários
		oBrowseB:Activate()

	oDlgOC270:Activate( , , , , , , /*EnchoiceBar( oDlgOC270, { || oDlgOC270:End() }, { || oDlgOC270:End() }, , , , , , , .F., .T. )*/ ) //ativa a janela

	oTmpTable1:CloseTable()
	oTmpTable2:CloseTable()

Return

/*/{Protheus.doc} OC2700011_LevantaDados
Levanta Dados da Negociação de Peças da Ordem de Serviço para apresentação

@author Andre Luis Almeida
@since 07/04/2022
/*/
Static Function OC2700011_LevantaDados()
Local dDatRef  := dDataBase
Local nCntFor  := 0
Local nValPerm := 0
Local nDesPerm := 0
Local aRetDes  := {}
Local cCorLeg  := "0"
Local nVO3GruIte := FG_POSVAR("VO3_GRUITE","aHeadVO3")
Local nVO3CodIte := FG_POSVAR("VO3_CODITE","aHeadVO3")
Local nVO3QtdReq := FG_POSVAR("VO3_QTDREQ","aHeadVO3")
Local nVO3ValPec := FG_POSVAR("VO3_VALPEC","aHeadVO3")
Local nVO3PerDes := FG_POSVAR("VO3_PERDES","aHeadVO3")
Local nVO3ValDes := FG_POSVAR("VO3_VALDES","aHeadVO3")
Local nVO3MarLuc := FG_POSVAR("VO3_MARLUC","aHeadVO3")
Local nPosTTP    := 0
Local cCodCli    := ""
Local cLojCli    := ""

VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI")+__cUserID))

SA3->(DbSetOrder(1))
SA3->(DbSeek(xFilial("SA3")+VAI->VAI_CODVEN))

SE4->(DbSetOrder(1))
SE4->(DbSeek(xFilial("SE4")+M->VOO_CONDPG)) // Pegar Condição que esta informada na tela

For nPosTTP := 1 to len(aVetTTPo)

	If aVetTTPo[nPosTTP,ATT_VETSEL] // Selecionado

		cCodCli := aVetTTPo[nPosTTP,ATT_CLIENTE]
		cLojCli := aVetTTPo[nPosTTP,ATT_LOJA]
		RecLock("TEMPA",.T.)
			TEMPA->WZ1_NUMOSV := aVetTTPo[nPosTTP,ATT_NUMOSV]
			TEMPA->WZ1_TIPTEM := aVetTTPo[nPosTTP,ATT_TIPTEM]
			TEMPA->WZ1_LIBVOO := aVetTTPo[nPosTTP,ATT_LIBVOO]
			TEMPA->WZ1_CODVEN := VAI->VAI_CODVEN+" - "+SA3->A3_NOME
			TEMPA->WZ1_DESPEC := VAI->VAI_DESPEC
			TEMPA->WZ1_FORPAG := M->VOO_CONDPG+" - "+SE4->E4_DESCRI
			TEMPA->WZ1_PERREM := M->VOO_PERREM
		TEMPA->(MsUnlock())

	EndIf

Next

For nCntFor := 1 to len(aColsVO3)
	SBM->(DbSetOrder(1))
	SBM->(DbSeek(xFilial("SBM")+aColsVO3[nCntFor,nVO3GruIte]))
	SB1->(DbSetOrder(7))
	SB1->(DbSeek(xFilial("SB1")+aColsVO3[nCntFor,nVO3GruIte]+aColsVO3[nCntFor,nVO3CodIte]))
	// 3 - Retorna Valor, Desconto e Margem
	aRetDes := OX005PERDES(SBM->BM_CODMAR,VAI->VAI_CC,SB1->B1_GRUPO,SB1->B1_CODITE,aColsVO3[nCntFor,nVO3QtdReq],aColsVO3[nCntFor,nVO3PerDes],.t.,cCodCli,cLojCli,"3",aColsVO3[nCntFor,nVO3ValPec],3,M->VOO_CONDPG,,,,M->VOO_CONPRO,dDatRef,M->VOO_PERREM)
	//
	nDesPerm := IIf( aRetDes[2] >= VAI->VAI_DESPEC                              , aRetDes[2] - M->VOO_PERREM                                                           , VAI->VAI_DESPEC - M->VOO_PERREM )
	nDesPerm := IIf( nDesPerm < 0 .or. ( len(aRetDes)>3 .and. aRetDes[4]=="0" ) , 0                                                                                    , nDesPerm                        ) // 0 = NAO PODE DAR DESCONTO EM PROMOCAO
	nValPerm := IIf( aRetDes[1] > 0                                             , aRetDes[1]                                                                           , aColsVO3[nCntFor,nVO3ValPec]    )
	nValPerm := IIf( nDesPerm > 0                                               , ( aColsVO3[nCntFor,nVO3ValPec] - ( aColsVO3[nCntFor,nVO3ValPec]*( nDesPerm/100 ) ) ) , nValPerm                        )
	//
	cCorLeg  := IIf( aColsVO3[nCntFor,nVO3PerDes] > nDesPerm                        , "1" , "0"     ) // 1 = Problema de Desconto
	cCorLeg  := IIf( aColsVO3[nCntFor,nVO3MarLuc] < aRetDes[3] .and. cCorLeg == "0" , "2" , cCorLeg ) // 2 = Problema de Margem
	cCorLeg  := IIf( aColsVO3[nCntFor,nVO3MarLuc] < aRetDes[3] .and. cCorLeg <> "0" , "3" , cCorLeg ) // 3 = Problema de Margem e Desconto
	//
	RecLock("TEMPB",.T.)
		TEMPB->WZ2_CORLEG := cCorLeg
		TEMPB->WZ2_GRUITE := aColsVO3[nCntFor,nVO3GruIte]
		TEMPB->WZ2_CODITE := aColsVO3[nCntFor,nVO3CodIte]
		TEMPB->WZ2_DESITE := SB1->B1_DESC
		TEMPB->WZ2_QTDITE := aColsVO3[nCntFor,nVO3QtdReq]
		TEMPB->WZ2_VALORI := aColsVO3[nCntFor,nVO3ValPec]
		TEMPB->WZ2_DESPER := nDesPerm
		TEMPB->WZ2_VALPER := nValPerm
		TEMPB->WZ2_DESDES := aColsVO3[nCntFor,nVO3PerDes]
		TEMPB->WZ2_VALDES := aColsVO3[nCntFor,nVO3ValPec]-(aColsVO3[nCntFor,nVO3ValDes]/aColsVO3[nCntFor,nVO3QtdReq])
		TEMPB->WZ2_MARLUC := aColsVO3[nCntFor,nVO3MarLuc]
		TEMPB->WZ2_MARPER := aRetDes[3]
	TEMPB->(MsUnlock())
Next
Return