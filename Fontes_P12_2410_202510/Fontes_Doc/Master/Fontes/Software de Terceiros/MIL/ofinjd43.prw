//Bibliotecas
#Include 'Protheus.ch'
#Include 'TOPCONN.CH'
#Include 'FwMVCDef.ch'
#Include 'OFINJD43.ch'

Static cMVMIL0006 := GetNewPar("MV_MIL0006","")

/*/{Protheus.doc} OFINJD43

Consulta de Itens Encomendados John Deere

@author Renato Vinicius
@since 08/07/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function OFINJD43()

	Local aSize       := FWGetDialogSize( oMainWnd )
	Local aCampos1    := {} // Array para campos da tabela temporária e campos da View
	Local aSeek       := {}
	Local nIdxFil     := 0
	Local aFil        := {}
	Local aFilis      := {}
	Local cBkpFil     := ""
	Local oFil        := DMS_FilialHelper():New()
	Local oDpmCfg     := DMS_DPM():New()

	Private aCampos2  := {} // Array para campos da tabela temporária e campos da View
	Private aCampos3  := {} // Array para campos da tabela temporária e campos da View
	Private aRotina   := {}
	Private cForLj    := ""

	aFilis  := oDpmCfg:GetFiliais()

	cBkpFil := cFilAnt
	for nIdxFil := 1 to LEN(aFilis)

		aFil := aFilis[nIdxFil]
		cFilAnt := aFil[1]

		dbSelectArea("SA2")
		dbGoTo( oFil:GetFornecedor( xFilial('VS1') ) )
		If !Empty(SA2->A2_COD)
			cForLj += "'"+SA2->A2_COD + SA2->A2_LOJA + "',"
		EndIf

	Next
	cForLj := Left(cForLj,Len(cForLj)-1)
	cFilAnt := cBkpFil

	aadd(aCampos1, {"TMP_FILIAL","C",GetSX3Cache("B1_FILIAL","X3_TAMANHO")	,0} ) // Filial do sistema
	aadd(aCampos1, {"TMP_GRUPO"	,"C",GetSX3Cache("B1_GRUPO"	,"X3_TAMANHO")	,0} ) // Grupo de Produto
	aadd(aCampos1, {"TMP_COD"	,"C",GetSX3Cache("B1_COD"	,"X3_TAMANHO")	,0} ) // Código
	aadd(aCampos1, {"TMP_CODITE","C",GetSX3Cache("B1_CODITE","X3_TAMANHO")	,0} ) // Código Interno
	aadd(aCampos1, {"TMP_DESITE","C",GetSX3Cache("B1_DESC"	,"X3_TAMANHO")	,0} ) // Descrição do Produto
	aadd(aCampos1, {"TMP_CODFAB","C",GetSX3Cache("B1_CODFAB","X3_TAMANHO")	,0} ) // Código da Fábrica
	aadd(aCampos1, {"TMP_ORDER"	,"N",6										,0} ) // Quantidade de Pedidos
	aadd(aCampos1, {"TMP_XFER"	,"N",6										,0} ) // Quantidade de Faturados
	aadd(aCampos1, {"TMP_TOTAL"	,"N",6										,0} ) // Total

	//Order
	aadd(aCampos2, {"ZZZ_FILIAL","C",GetSX3Cache("B1_FILIAL","X3_TAMANHO")	,0} ) // Filial do sistema
	aadd(aCampos2, {"ZZZ_COD"	,"C",GetSX3Cache("B1_COD"	,"X3_TAMANHO")	,0} ) // Código Produto
	aadd(aCampos2, {"ZZZ_NROPED","C",GetSX3Cache("C7_NUM"	,"X3_TAMANHO")	,0} ) // Nro Pedido
	aadd(aCampos2, {"ZZZ_PEDFAB","C",GetSX3Cache("C7_PEDFAB","X3_TAMANHO")	,0} ) // Pedido de Fabrica
	aadd(aCampos2, {"ZZZ_ORDER"	,"N",6										,0} ) // Quantidade de Pedidos

	//Transfer
	aadd(aCampos3, {"ZZY_FILORI","C",GetSX3Cache("B1_FILIAL","X3_TAMANHO")	,0} ) // Filial de Origem
	aadd(aCampos3, {"ZZY_FILDES","C",GetSX3Cache("VS1_FILDES","X3_TAMANHO")	,0} ) // Filial de Destino
	aadd(aCampos3, {"ZZY_COD"	,"C",GetSX3Cache("B1_COD"	,"X3_TAMANHO")	,0} ) // Código Produto
	aadd(aCampos3, {"ZZY_NROORC","C",GetSX3Cache("VS1_NUMORC","X3_TAMANHO")	,0} ) // Nro Orçamento
	aadd(aCampos3, {"ZZY_XFER"	,"N",6										,0} ) // Quantidade de xFer


	// Criando tabela temporária
	oTmpTable1 := OFDMSTempTable():New()
	oTmpTable1:cAlias := "TEMPA"
	oTmpTable1:aVetCampos := aCampos1
	oTmpTable1:AddIndex(, {"TMP_FILIAL","TMP_GRUPO","TMP_COD"} )
	oTmpTable1:CreateTable()

	oTmpTable1:InsertSQL( OJD430025_MontaTab() )

	//Order
	oTmpTable2 := OFDMSTempTable():New()
	oTmpTable2:cAlias := "TEMPB"
	oTmpTable2:aVetCampos := aCampos2
	oTmpTable2:AddIndex(, {"ZZZ_FILIAL","ZZZ_NROPED","ZZZ_COD"} )
	oTmpTable2:CreateTable()

	//Transfer
	oTmpTable3 := OFDMSTempTable():New()
	oTmpTable3:cAlias := "TEMPC"
	oTmpTable3:aVetCampos := aCampos3
	oTmpTable3:AddIndex(, {"ZZY_FILORI","ZZY_NROORC","ZZY_COD"} )
	oTmpTable3:CreateTable()

	Aadd( aSeek, { STR0001 +"+"+ STR0002 +"+"+ STR0004, {{"","C",GetSX3Cache("B1_COD"	,"X3_TAMANHO"),0,"","@!"}} } )	// "Filial+Grupo+Código"

	aCampos1 := {;
					{ STR0001	,"TMP_FILIAL"	,"C",30,0,""}, ;// Filial
					{ STR0002	,"TMP_GRUPO"	,"C",30,0,""}, ;// Grupo do Produto
					{ STR0003	,"TMP_COD"		,"C",30,0,""}, ;// Código do Produto
					{ STR0004	,"TMP_CODITE"	,"C",30,0,""}, ;// Código Interno
					{ STR0005	,"TMP_DESITE"	,"C",30,0,""}, ;// Descrição do Produto
					{ STR0006	,"TMP_ORDER"	,"C",15,0,""}, ;// Quantidade de Order
					{ STR0007	,"TMP_XFER"		,"C",15,0,""}, ;// Quantidade de Transfer
					{ STR0008	,"TMP_TOTAL"	,"C",15,0,""}  ;// Total de Encomendado
	}

	oDlg := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0009 , , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		// Criação do browse de tela
		oBrowseA := FWMBrowse():New( )
		oBrowseA:SetOwner(oDlg)
		oBrowseA:SetTemporary(.T.) 
		oBrowseA:DisableDetails()
		oBrowseA:DisableConfig()
		oBrowseA:SetFixedBrowse(.T.)
		oBrowseA:SetAlias("TEMPA")
		oBrowseA:SetFields(aCampos1)
		oBrowseA:SetMenuDef("OFINJD43")
		oBrowseA:ForceQuitButton()
		oBrowseA:SetSeek(.t.,aSeek)
		oBrowseA:SetDescription( STR0009 ) //"Consulta de Encomendado"
		oBrowseA:Activate()

	oDlg:Activate( , , , , , , ) //ativa a janela

	oTmpTable1:CloseTable()
	oTmpTable2:CloseTable()
	oTmpTable3:CloseTable()

Return

/*/{Protheus.doc} OFINJD43

@author Renato Vinicius
@since 08/07/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function MenuDef()

	aRotina := {}

	ADD OPTION aRotina TITLE STR0010 ACTION 'OJD430015_Visualizar()' OPERATION 2 ACCESS 0 // "Visualizar"

Return aRotina


/*/{Protheus.doc} OFINJD43

@author Renato Vinicius
@since 08/07/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function OJD430015_Visualizar()

	cQuery := "DELETE FROM " + oTmpTable2:GetRealName()
	TCSqlExec(cQuery)

	cQuery := "DELETE FROM " + oTmpTable3:GetRealName()
	TCSqlExec(cQuery)

	OJD430045_MostraEncomendado(TEMPA->TMP_COD,TEMPA->TMP_GRUPO,TEMPA->TMP_CODITE)

Return

/*/{Protheus.doc} OFINJD43

@author Renato Vinicius
@since 08/07/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OJD430025_MontaTab()

	Local cQuery := ""
	Local oDpm   := DMS_DPM():New()
	Local oSqlHlp:= DMS_SqlHelper():New()

	// Quantidade de Transfers
	cQueryTrans := " ( "
	cQueryTrans += "    SELECT B1_COD, VS3_QTDITE QTDTOT "
	cQueryTrans += "      FROM " + oSqlHlp:NoLock('VS1')
	cQueryTrans += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS1_FILIAL = VS3_FILIAL           AND VS1_NUMORC = VS3_NUMORC AND VS1_STATUS <> 'C'        AND VS1_TIPORC     = '3' AND VS1.D_E_L_E_T_ = ' ' "
	cQueryTrans += "      JOIN " + oSqlHlp:NoLock('SF1') + " ON F1_FILIAL  = VS1_FILDES           AND F1_DOC     = VS1_NUMNFI AND F1_SERIE    = VS1_SERNFI AND SF1.D_E_L_E_T_ = ' ' "
	cQueryTrans += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO    = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQueryTrans += "     WHERE VS1_NUMNFI    <> ' ' "
	cQueryTrans += "       AND VS3.D_E_L_E_T_ = ' ' "
	cQueryTrans += "       AND F1_STATUS      = ' ' "
	cQueryTrans += "       AND " + oSqlHlp:Concat( { "SF1.F1_FORNECE" , "SF1.F1_LOJA" })+ " IN ("+cForLj+") "

	cQueryTrans += OJD430105_CondicoesCustomizadaTransfer( cQueryTrans )

	cQueryTrans += " UNION ALL "
	cQueryTrans += "    SELECT B1_COD, VS3_QTDITE QTDTOT "
	cQueryTrans += "      FROM " + oSqlHlp:NoLock('VS1')
	cQueryTrans += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS1_FILIAL = VS3_FILIAL           AND VS1_NUMORC = VS3_NUMORC AND VS1_TIPORC  = '3'        AND VS1.D_E_L_E_T_ = ' ' "
	cQueryTrans += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO    = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQueryTrans += "     WHERE VS3_DOCSDB    <> ' ' "
	cQueryTrans += "       AND VS1_STATUS    <> 'C' "
	cQueryTrans += "       AND VS1_STATUS    <> 'X' "
	cQueryTrans += "       AND VS1_NUMNFI     = ' ' "
	cQueryTrans += "       AND VS3.VS3_TRSFER = '1' " //Somente orçamentos de transferencia originados de XFER DPM JD
	cQueryTrans += "       AND VS3.D_E_L_E_T_ = ' ' "

	cQueryTrans += " ) ENCXFER "

	cQueryTrans := "SELECT B1_COD, SUM(QTDTOT) AS QTDTRANS FROM " + cQueryTrans + " GROUP BY B1_COD "

	//Quantidade de Orders
	cQueryOrder := 	" SELECT C7_PRODUTO, SUM(C7_QUANT - C7_QUJE) AS QTDORDER "
	cQueryOrder += 	" FROM " + oSqlHlp:NoLock('SC7')
	cQueryOrder += 	" WHERE C7_QUANT > C7_QUJE AND C7_ENCER = ' ' AND C7_RESIDUO = ' ' AND D_E_L_E_T_ = ' ' "

	cQueryOrder += OJD430095_CondicoesCustomizadaOrder( cQueryOrder )

	cQueryOrder += 	" GROUP BY C7_PRODUTO"

	cQuery := "SELECT SB1.B1_FILIAL, SB1.B1_GRUPO, SB1.B1_COD, SB1.B1_CODITE, SB1.B1_DESC, SB1.B1_CODFAB, "
	cQuery += 	" COALESCE(QTDORDER,0) AS ORDERS, "
	cQuery += 	" COALESCE(QTDTRANS,0) AS TRANSFERS, "
	cQuery += 	" COALESCE(QTDTRANS,0) + COALESCE(QTDORDER,0) AS TOTAL "
	cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += 	" INNER JOIN " + RetSqlName("SBM") + " SBM ON SBM.BM_FILIAL = '"+xFilial("SBM")+"' AND SB1.B1_GRUPO = SBM.BM_GRUPO AND BM_GRUPO IN " + oDpm:GetInGroups() + " AND SBM.D_E_L_E_T_ = ' ' "
	cQuery += 	" LEFT JOIN (" + cQueryOrder + ") PED ON SB1.B1_COD = PED.C7_PRODUTO "
	cQuery +=	" LEFT JOIN (" + cQueryTrans + ") ORC ON SB1.B1_COD = ORC.B1_COD "
	cQuery += " WHERE SB1.B1_FILIAL = '" +xFilial("SB1")+ "' "
	cQuery += 		"AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY 1,2,3"

Return cQuery

/*/{Protheus.doc} OFINJD43

@author Renato Vinicius
@since 08/07/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OJD430045_MostraEncomendado( cCODB1, cGRP, cCODITE )

	Local nCount := 0
	Local aSize     := FWGetDialogSize( oMainWnd )

	aCampos2 := {;
					{ STR0001	,"ZZZ_FILIAL"	,"C",50,0,"",0,15,.f.},;// Filial
					{ STR0011	,"ZZZ_NROPED"	,"C",50,0,"",0,15,.f.},;// Numero do pedido
					{ STR0012	,"ZZZ_PEDFAB"	,"C",50,0,"",0,15,.f.},;// Pedido de Fábrica
					{ STR0013	,"ZZZ_ORDER"	,"C",30,0,"",0,15,.f.} ;// Quantidade do pedido
	}

	aCampos3 := {;
					{ STR0014	,"ZZY_FILORI"	,"C",50,0,"",0,15,.f.},;// Filial de Origem
					{ STR0015	,"ZZY_FILDES"	,"C",50,0,"",0,15,.f.},;// Filial de Destino
					{ STR0016	,"ZZY_NROORC"	,"C",50,0,"",0,15,.f.},;// Numero do Orçamento
					{ STR0017	,"ZZY_XFER"		,"C",30,0,"",0,15,.f.} ;// Quantidade do Orçamento
	}

	OJD430075_LevantaOrders(cCODB1)
	OJD430085_LevantaTransfer(cGRP,cCODITE)

	oDlgOJD43 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0018 , , , , , , , , , .T., , , , .F. ) // "Encomendado"

		oLayerDet := FWLayer():new()
		oLayerDet:Init(oDlgOJD43,.f.)

		//Cria as linhas do Layer
		oLayerDet:addLine( 'L1', 49, .F. )
		oLayerDet:addLine( 'L2', 50, .F. )

		//Cria as colunas do Layer
		oLayerDet:addCollumn('C1L1',99,.F.,"L1") 
		oLayerDet:addCollumn('C1L2',99,.F.,"L2")

		cL1C1 := oLayerDet:getColPanel('C1L1','L1')
		cL2C1 := oLayerDet:getColPanel('C1L2','L2')

		oBrwPed:= FWMBrowse():New()
		oBrwPed:SetOwner(cL1C1)
		oBrwPed:SetDescription( "Orders" )
		oBrwPed:SetAlias("TEMPB")
		oBrwPed:SetLocate()
		oBrwPed:DisableDetails()
		oBrwPed:DisableConfig()
		oBrwPed:SetAmbiente(.F.)
		oBrwPed:SetWalkthru(.F.)

		oBrwPed:SetFilterDefault(" ZZZ_COD = '" + cCODB1 + "' ")

		oBrwPed:SetMenuDef("")
		oBrwPed:AddButton( STR0019 ,{|| oDlgOJD43:End()},,1) //"Sair"
		oBrwPed:AddButton( STR0010 ,{|| OJD430065_VisualizaPedido( TEMPB->ZZZ_FILIAL, TEMPB->ZZZ_NROPED ) },,2) // "Visualizar"
		
		For nCount := 1 To Len(aCampos2)
			oBrwPed:AddColumn(;
								{	aCampos2[nCount][1],; // Título da coluna
									&("{|| TEMPB->" + aCampos2[nCount][2] + "}"),; // Code-Block de carga dos dados
									aCampos2[nCount][3],; // Tipo de dados
									aCampos2[nCount][6],; // Máscara
									aCampos2[nCount][7],; // Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
									aCampos2[nCount][8],; // Tamanho
									aCampos2[nCount][5],; // Decimal
									.F.,; // Indica se permite a edição
									{||.T.},; // Code-Block de validação da coluna após a edição
									aCampos2[nCount][9],; // Indica se exibe imagem
									{||.T.},; // Code-Block de execução do duplo clique
									NIL,; // Variável a ser utilizada na edição (ReadVar)
									{||.T.},; // Code-Block de execução do clique no header
									.F.,; // Indica se a coluna está deletada
									.F.,; // Indica se a coluna será exibida nos detalhes do Browse
									{}; // Opções de carga dos dados (Ex: 1=Sim, 2=Não)
								};
							)
		Next nCount

		oBrwPed:Activate()

		oBrwxFer:= FWMBrowse():New()
		oBrwxFer:SetOwner(cL2C1)
		oBrwxFer:SetDescription( STR0020 ) //"Transfers"
		oBrwxFer:SetAlias("TEMPC")
		oBrwxFer:SetLocate()
		oBrwxFer:DisableDetails()
		oBrwxFer:DisableConfig()
		oBrwxFer:SetAmbiente(.F.)
		oBrwxFer:SetWalkthru(.F.)

		oBrwxFer:SetFilterDefault(" ZZY_COD = '" + cCODB1 + "' ")

		oBrwxFer:SetMenuDef("")
		oBrwxFer:AddButton( STR0010 ,{|| OJD430055_VisualizaOrcamento( TEMPC->ZZY_FILORI, TEMPC->ZZY_NROORC ) },,2) // "Visualizar"
		
		For nCount := 1 To Len(aCampos3)
			oBrwxFer:AddColumn(;
								{	aCampos3[nCount][1],; // Título da coluna
									&("{|| TEMPC->" + aCampos3[nCount][2] + "}"),; // Code-Block de carga dos dados
									aCampos3[nCount][3],; // Tipo de dados
									aCampos3[nCount][6],; // Máscara
									aCampos3[nCount][7],; // Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
									aCampos3[nCount][8],; // Tamanho
									aCampos3[nCount][5],; // Decimal
									.F.,; // Indica se permite a edição
									{||.T.},; // Code-Block de validação da coluna após a edição
									aCampos3[nCount][9],; // Indica se exibe imagem
									{||.T.},; // Code-Block de execução do duplo clique
									NIL,; // Variável a ser utilizada na edição (ReadVar)
									{||.T.},; // Code-Block de execução do clique no header
									.F.,; // Indica se a coluna está deletada
									.F.,; // Indica se a coluna será exibida nos detalhes do Browse
									{}; // Opções de carga dos dados (Ex: 1=Sim, 2=Não)
								};
							)
		Next nCount

		oBrwxFer:Activate()

	oDlgOJD43:Activate( , , , .t. , , , ) //ativa a janela

Return

/*/{Protheus.doc} OFINJD43

	Visualiza o orçamento selecionado no grid

@author Renato Vinicius
@since 08/07/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OJD430055_VisualizaOrcamento( cFilVS1, cNroOrc )

	dbSelectArea("VS1")
	dbSetOrder(1)
	if dbSeek(cFilVS1+cNroOrc)
		OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
	EndIf

Return

/*/{Protheus.doc} OFINJD43

	Visualiza o pedido selecionado no grid

@author Renato Vinicius
@since 08/07/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OJD430065_VisualizaPedido( cFilSC7, cNroPed )

	Local aBKPRotina := aClone(aRotina)
	Local aArea      := GetArea()

	Private l120Auto := .F. //-- Variavel utilizada pelo MATA120
	Private nTipoPed := 1   //-- Variavel utilizada pelo MATA120
	Private cCadastro:= STR0021

	SC7->(DbSetOrder(1))
	SC7->(DbSeek(cFilSC7+cNroPed))

	INCLUI := .F.
	ALTERA := .F.

	aRotina := {}
	AAdd( aRotina, { '' , '' , 0, 1 } )
	AAdd( aRotina, { '' , '' , 0, 2 } )
	AAdd( aRotina, { '' , '' , 0, 3 } )
	AAdd( aRotina, { '' , '' , 0, 4 } )
	AAdd( aRotina, { '' , '' , 0, 5 } )

	A120Pedido( 'SC7', SC7->( Recno() ), 2 )

	aRotina := aClone(aBKPRotina)

	RestArea(aArea)

Return


/*/{Protheus.doc} OFINJD43

@author Renato Vinicius
@since 08/07/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OJD430075_LevantaOrders( cCodProduto )

	cQuery := "SELECT C7_FILIAL, C7_PRODUTO, C7_NUM, C7_PEDFAB , C7_QUANT - C7_QUJE AS QTDENC"
	cQuery += " FROM " + RetSQLName("SC7") + " SC7 "
	cQuery += " WHERE C7_QUANT > C7_QUJE AND C7_PRODUTO = '" +cCodProduto+ "' AND C7_ENCER = ' ' AND C7_RESIDUO = ' ' AND D_E_L_E_T_ = ' ' "

	cQuery += OJD430095_CondicoesCustomizadaOrder( cQuery )

	oTmpTable2:ClearTable()
	oTmpTable2:InsertSQL( cQuery )

Return

/*/{Protheus.doc} OFINJD43

@author Renato Vinicius
@since 08/07/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OJD430085_LevantaTransfer( cGruProduto, cCodProduto )

	Local cQuery   := ""
	Local oSqlHlp  := DMS_SqlHelper():New()

	cQuery := ""
	cQuery += "    SELECT 'ORIGEM' VS1_FILORI, VS1_FILDES, VS1_NUMORC, B1_COD, VS3_QTDITE QTDTOT "
	cQuery += "      FROM " + oSqlHlp:NoLock('VS1')
	cQuery += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS1_FILIAL = VS3_FILIAL           AND VS1_NUMORC = VS3_NUMORC AND VS1_STATUS <> 'C'        AND VS1_TIPORC     = '3' AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN " + oSqlHlp:NoLock('SF1') + " ON F1_FILIAL  = VS1_FILDES           AND F1_DOC     = VS1_NUMNFI AND F1_SERIE    = VS1_SERNFI AND SF1.D_E_L_E_T_ = ' ' "
	cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO    = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "     WHERE VS1_NUMNFI    <> ' ' "
	cQuery += "       AND VS3_GRUITE    = '" + cGruProduto + "' "
	cQuery += "       AND VS3_CODITE    = '" + cCodProduto + "' "
	cQuery += "       AND VS3.D_E_L_E_T_ = ' ' "
	cQuery += "       AND F1_STATUS      = ' ' "
	cQuery += "       AND " + oSqlHlp:Concat( { "SF1.F1_FORNECE" , "SF1.F1_LOJA" })+ " IN ("+cForLj+") "

	cQuery += OJD430105_CondicoesCustomizadaTransfer( cQuery )

	if VS3->(FieldPos("VS3_TRSFER")) > 0
		cQuery += " UNION ALL "
		cQuery += "    SELECT VS1_FILIAL VS1_FILORI, VS1_FILDES, VS1_NUMORC, B1_COD, VS3_QTDITE QTDTOT "
		cQuery += "      FROM " + oSqlHlp:NoLock('VS1')
		cQuery += "      JOIN " + oSqlHlp:NoLock('VS3') + " ON VS1_FILIAL = VS3_FILIAL           AND VS1_NUMORC = VS3_NUMORC AND VS1_TIPORC  = '3'        AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "      JOIN " + oSqlHlp:NoLock('SB1') + " ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VS3_CODITE AND B1_GRUPO    = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "     WHERE VS3_DOCSDB    <> ' ' "
		cQuery += "       AND VS1_STATUS    <> 'C' "
		cQuery += "       AND VS1_STATUS    <> 'X' "
		cQuery += "       AND VS1_NUMNFI     = ' ' "
		cQuery += "       AND VS3_GRUITE    = '" + cGruProduto + "' "
		cQuery += "       AND VS3_CODITE    = '" + cCodProduto + "' "
		cQuery += "       AND VS3.VS3_TRSFER = '1' " //Somente orçamentos de transferencia originados de XFER DPM JD
		cQuery += "       AND VS3.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery := " SELECT VS1_FILORI, VS1_FILDES, B1_COD, VS1_NUMORC, SUM(QTDTOT) QTDTOT FROM ("+cQuery+") X GROUP BY VS1_FILORI, VS1_FILDES, VS1_NUMORC, B1_COD "

	oTmpTable3:ClearTable()
	oTmpTable3:InsertSQL( cQuery )

Return


/*/{Protheus.doc} OFINJD43

@author Renato Vinicius
@since 12/08/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OJD430095_CondicoesCustomizadaOrder( cQOrder )

	Local cQuery := ""

	If ( ExistBlock("OJD06EORD") )  // Insere condição customizada no levantamento de Orders
		cQryORD := ExecBlock("OJD06EORD",.f.,.f.,{cQOrder})
		If !Empty(cQryORD)
			cQuery += " AND " + cQryORD
		EndIf
	EndIf

Return cQuery


/*/{Protheus.doc} OFINJD43

@author Renato Vinicius
@since 12/08/2024
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OJD430105_CondicoesCustomizadaTransfer( cQTransfer )

	Local cQuery := ""

	If ( ExistBlock("OJD06ETRF") )  // Insere condição customizada no levantamento de transfers
		cQryTRF := ExecBlock("OJD06ETRF",.f.,.f.,{cQTransfer})
		If !Empty(cQryTRF)
			cQuery += " AND " + cQryTRF
		EndIf
	EndIf

Return cQuery