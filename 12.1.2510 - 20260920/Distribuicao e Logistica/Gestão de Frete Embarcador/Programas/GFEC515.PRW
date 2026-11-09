#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' 
//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC515
Monitor de Pontos de Controle
Generico

@sample    
GFEC515()

@author Helder Fuckner dos Santos
@since 23/04/14
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Function GFEC515()
	Local aCoors		:= FWGetDialogSize( oMainWnd )
	Local oBrowse
	Private cTitulo	:= 'Monitor de Pontos de Controle'
	Private oGrid1, oGrid2
	Private aGrid1, aGrid2
	Private oPnl1, oPnl2
	Private cAlias1, cAlias2
	Private oRelacGX4
	
		
	Define MsDialog oDlg Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	/*Criando objeto Layer*/
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	
	oFWLayer:AddLine('LINEMV1',30,.F.)
	oFWLayer:AddLine('LINEMV2',70,.F.)
	oFWLayer:AddCollumn('COL_BRWMOV',100,.T.,'LINEMV1')
	oFWLayer:AddCollumn('COL_BRWPTC',100,.T.,'LINEMV2')

	oPnl1 := oFWLayer:GetColPanel('COL_BRWMOV','LINEMV1')
	oPnl2 := oFWLayer:GetColPanel('COL_BRWPTC','LINEMV2')
	
	oDlg:Activate(,,,.T.,,,{|| Processa({|| Iniciar() }) })

	GFEDelTab(cAlias1)
	GFEDelTab(cAlias2)

Return


Static Function Iniciar()
	Local nCount

	//Browses
	CursorWait()
//	oPnl1:SetUpdatesEnabled(.F.)
//	oPnl2:SetUpdatesEnabled(.F.)


	// BROWSE MOVIMENTACAO GX3
	aGrid2 := {;
				{"Pto Contr"			,"GX4_CDPTCT"	,"C",TamSX3("GX4_CDPTCT")[1],0,"",1,10},;
				{"Nr Movim"			,"GX4_NRMOV"	,"C",TamSX3("GX4_NRMOV")[1],0,"",1,10},;
				{"Operação"			,"GX3_CDOPER"	,"C",TamSX3("GX3_CDOPER")[1],0,"",1,10},;
				{"Seq"					,"GX3_SEQ"		,"C",TamSX3("GX3_SEQ")[1],0,"",1,10},;
				{"Desc Config"		,"GVI_DSCONF"	,"C",TamSX3("GVI_DSCONF")[1],0,"",1,10},;
				{"Situação"			,"GX3_SIT"		,"C",20,0,"",1,10},;
				{"Endereço"			,"GVD_DSENDE"	,"C",TamSX3("GVD_DSENDE")[1],0,"",1,10},;
				{"Veículo"				,"GU8_PLACA"	,"C",100,0,"",1,10},;
				{"Emitente"			,"GU3_NMEMIT"	,"C",TamSX3("GU3_NMEMIT")[1],0,"",1,10},;
				{"Próx Pto Controle"	,"VAIPARA","C",50,0,"",1,10} }
	
	cAlias2 := LoadMvto()

	oGrid2:= FWMBrowse():New()
	oGrid2:SetOwner(oPnl2)
	oGrid2:SetDescription("Movimentações")
	oGrid2:SetAlias(cAlias2)
	oGrid2:SetLocate()
	oGrid2:DisableDetails()
	oGrid2:DisableConfig()
//	oGrid2:SetAmbiente(.F.)
	oGrid2:SetWalkthru(.F.)
	oGrid2:SetProfileID("2")
	oGrid2:SetMenuDef("GFEC515")
	oGrid2:SetFixedBrowse(.T.)
	oGrid2:ForceQuitButton(.T.)
	
	For nCount := 1 To Len(aGrid2)
		oGrid2:AddColumn({ aGrid2[nCount][1],;
						     &("{|| (cAlias2)->" + aGrid2[nCount][2] + "}"),;
						     aGrid2[nCount][3],;
						     aGrid2[nCount][6],;
						     aGrid2[nCount][7],;
						     aGrid2[nCount][8],;
						     aGrid2[nCount][5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount

	

	//...Relation
	
	oGrid2:Activate()

	// BROWSE PONTO DE CONTROLE GX4
	aGrid1 := {;
				{"Filial"							,"GX4_FILIAL"	,"C",TamSX3("GX4_FILIAL")[1],0,"",1,10},;
				{"Ponto de Controle"				,"GVF_DSPTCT"	,"C",TamSX3("GVF_DSPTCT")[1],0,"",1,10},;
				{"Qtd Movimentações"				,"QTD_VEI"		,"N",9,0,"",1,10},;
				{"Qtd movimentações Previstas"	,"QTD_VEIPRE"	,"N",9,0,"",1,10} }

	cAlias1 := LoadPtCt()

	oGrid1:= FWMBrowse():New()
	oGrid1:SetOwner(oPnl1)
	oGrid1:SetDescription("Pontos de Controle")
	oGrid1:SetAlias(cAlias1)
	oGrid1:SetLocate()
	oGrid1:DisableDetails()
	oGrid1:DisableConfig()
	oGrid1:SetAmbiente(.F.)
	oGrid1:SetWalkthru(.F.)
	oGrid1:SetProfileID("1") 
	oGrid1:SetMenuDef("")
	oGrid1:SetFixedBrowse(.T.)
	
	For nCount := 1 To Len(aGrid1)
		oGrid1:AddColumn({ aGrid1[nCount][1],;
						     &("{|| (cAlias1)->" + aGrid1[nCount][2] + "}"),;
						     aGrid1[nCount][3],;
						     aGrid1[nCount][6],;
						     aGrid1[nCount][7],;
						     aGrid1[nCount][8],;
						     aGrid1[nCount][5],;
						     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount
	
	oGrid1:Activate()
	
	oRelacGX4:= FWBrwRelation():New()
	oRelacGX4:AddRelation(oGrid1, oGrid2, {{'GX4_FILIAL', 'GX4_FILIAL'}, {'GX4_CDPTCT', 'GX4_CDPTCT'}})
	
	oRelacGX4:Activate()
	
//	oPnl1:SetUpdatesEnabled(.T.)
//	oPnl2:SetUpdatesEnabled(.T.)

	CursorArrow()	
Return Nil

//-------------------------------------------------------------------

Static Function LoadPtCt()
	Local cQuery	:= ''
	Local cSit		:= ''
	Local cDesPto := ''
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local cTmp
	Local aStruct := {}

	aFields := {;
				{"Filial"						,"GX4_FILIAL"	,"C",TamSX3("GX4_FILIAL")[1],0},;
				{"Ponto Controle"				,"GX4_CDPTCT"	,"C",TamSX3("GX4_CDPTCT")[1],0},;
				{"Ponto Controle"				,"GVF_DSPTCT"	,"C",TamSX3("GVF_DSPTCT")[1],0},;
				{"Qtd Movimentações"				,"QTD_VEI"		,"N",9,0},;
				{"Qtd movimentações Previstas"	,"QTD_VEIPRE"	,"N",9,0} }

	aIndices := {"GX4_FILIAL+GX4_CDPTCT"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	// ####### PONTOS DE CONTROLE #######
	cQuery := "SELECT	GX4.GX4_FILIAL, GX4.GX4_CDPTCT,"
	cQuery += "		COUNT(DISTINCT ATUAL.GX4_NRMOV) QTD_VEI,"
	cQuery += "		COUNT(DISTINCT PREV.GX4_NRMOV) QTD_VEIPRE"
	cQuery += "  FROM "+ RetSQLName("GX3") +" GX3"
	cQuery += " INNER JOIN "+ RetSQLName("GX4") +" GX4 ON GX4.GX4_FILIAL = GX3.GX3_FILIAL"
	cQuery += "                      AND GX4.GX4_NRMOV = GX3.GX3_NRMOV"
	cQuery += "  LEFT JOIN ("
	cQuery += " 		SELECT GX41.GX4_FILIAL, GX41.GX4_NRMOV, MIN(GX41.GX4_SEQ) SEQ"
	cQuery += "		  FROM "+ RetSQLName("GX3") +" GX31"
	cQuery += "		 INNER JOIN "+ RetSQLName("GX4") +" GX41 ON GX41.GX4_FILIAL = GX31.GX3_FILIAL AND GX41.GX4_NRMOV = GX31.GX3_NRMOV"
	cQuery += "		 INNER JOIN "+ RetSQLName("GVF") +" GVF1 ON GVF1.GVF_FILIAL = GX41.GX4_FILIAL AND GVF1.GVF_CDPTCT = GX41.GX4_CDPTCT"
	cQuery += "		 WHERE GX31.D_E_L_E_T_ = ''"
	cQuery += "		   AND GX41.D_E_L_E_T_ = ''"
	cQuery += "		   AND GVF1.D_E_L_E_T_ = ''"
	cQuery += "		   AND GX31.GX3_SIT NOT IN ('5','6')"
	cQuery += "		   AND ((GX41.GX4_DTENTR != '' AND GX41.GX4_DTSAI != '' AND GX41.GX4_SIT = '3' AND GVF1.GVF_IDIMPE = '1') OR"
	cQuery += "				 (GX41.GX4_DTENTR = '' OR GX41.GX4_DTSAI = ''))"
	cQuery += "		 GROUP BY GX41.GX4_FILIAL, GX41.GX4_NRMOV"
	cQuery += " ) ATUAL ON ATUAL.GX4_FILIAL = GX4.GX4_FILIAL"
	cQuery += "        AND ATUAL.GX4_NRMOV  = GX4.GX4_NRMOV"
	cQuery += "        AND ATUAL.SEQ        = GX4.GX4_SEQ"
	cQuery += "  LEFT JOIN ("
	cQuery += "      	SELECT GX41.GX4_FILIAL, GX41.GX4_CDPTCT, GX41.GX4_SEQ, GX4_NRMOV"
	cQuery += "		  FROM "+ RetSQLName("GX3") +" GX31"
	cQuery += "		 INNER JOIN "+ RetSQLName("GX4") +" GX41 ON GX41.GX4_FILIAL = GX31.GX3_FILIAL AND GX41.GX4_NRMOV = GX31.GX3_NRMOV"
	cQuery += "		 WHERE GX31.D_E_L_E_T_ = ''"
	cQuery += "		   AND GX41.D_E_L_E_T_ = ''"
	cQuery += "		   AND GX31.GX3_SIT NOT IN ('5','6')"
	cQuery += "		   AND GX41.GX4_DTENTR = ''"
	cQuery += " ) PREV ON PREV.GX4_FILIAL  = GX4.GX4_FILIAL"
	cQuery += "        AND PREV.GX4_CDPTCT = GX4.GX4_CDPTCT"
	cQuery += "        AND PREV.GX4_NRMOV  = GX4.GX4_NRMOV"
	cQuery += "        AND (PREV.GX4_SEQ   > ATUAL.SEQ OR ATUAL.SEQ IS NULL)"
	cQuery += " WHERE GX4.D_E_L_E_T_ = ''"
	cQuery += "   AND GX3.D_E_L_E_T_ = ''"
	cQuery += "   AND GX3.GX3_SIT NOT IN ('5','6')"
	cQuery += " GROUP BY GX4.GX4_FILIAL, GX4.GX4_CDPTCT"


	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())

	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)

			cDesPto := Posicione("GVF",1,xFilial("GVF")+(cTmp)->GX4_CDPTCT,"GVF_DSPTCT")

			(cAlias)->GX4_FILIAL	 	:= (cTmp)->GX4_FILIAL
			(cAlias)->GX4_CDPTCT	 	:= (cTmp)->GX4_CDPTCT
			(cAlias)->GVF_DSPTCT		:= cDesPto
			(cAlias)->QTD_VEI			:= (cTmp)->QTD_VEI
			(cAlias)->QTD_VEIPRE		:= (cTmp)->QTD_VEIPRE

		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())
	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(1))
Return cAlias


Static Function LoadMvto()
	Local cQuery	:= ''
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local cTmp
	Local cSit		:= ''
	Local cCodVei	:= ''
	Local cLstVei	:= ''
	Local cVaiPar	:= ''
	Local aStruct := {}
	Local cPictPlaca := PesqPict('GU8','GU8_PLACA')

	aFields := {;
				{"Filial"		,"GX4_FILIAL"	,"C",TamSX3("GX4_FILIAL")[1],0},;
				{"Pto Contr"	,"GX4_CDPTCT"	,"C",TamSX3("GX4_CDPTCT")[1],0},;
				{"Nr Movim"	,"GX4_NRMOV"	,"C",TamSX3("GX4_NRMOV")[1],0},;
				{"Operação"	,"GX3_CDOPER"	,"C",TamSX3("GX3_CDOPER")[1],0},;
				{"Seq"			,"GX3_SEQ"		,"C",TamSX3("GX3_SEQ")[1],0},;
				{"Desc Config","GVI_DSCONF"	,"C",TamSX3("GVI_DSCONF")[1],0},;
				{"Situação"	,"GX3_SIT"		,"C",20,0},;
				{"Endereço"	,"GVD_DSENDE"	,"C",TamSX3("GVD_DSENDE")[1],0},;
				{"Veículo"		,"GU8_PLACA"	,"C",100,0},;
				{"Emitente"	,"GU3_NMEMIT"	,"C",TamSX3("GU3_NMEMIT")[1],0},;
				{"Próx Pto Controle","VAIPARA","C",50,0} } 

	aIndices := {"GX4_FILIAL+GX4_CDPTCT+GX4_NRMOV"}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  // Nome do campo
						aFields[nCont][3],;  // Tipo
						aFields[nCont][4],;  // Tamanho
						aFields[nCont][5]})	// Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	// MOVIMENTAÇÕES
	cQuery := " SELECT 	GX4.GX4_FILIAL FILMOV," 
	cQuery += "       	GX4.GX4_CDPTCT PTCTMOV," 
	cQuery += "       	GX4.GX4_NRMOV," 
	cQuery += "			GX3.GX3_CDOPER," 
	cQuery += "			GX3.GX3_SEQ," 
	cQuery += "			GX3.GX3_SIT," 
	cQuery += "			GX3.GX3_CDEMIT," 
	cQuery += "			GX4.GX4_CDENDE,"
	cQuery += "			MIN(PROXIMO.GX4_SEQ) VAIPARA"		
	cQuery += "   FROM "+ RetSQLName("GX3") +" GX3"
	cQuery += "  INNER JOIN "+ RetSQLName("GX4") +" GX4 ON GX4.GX4_FILIAL = GX3.GX3_FILIAL"
	cQuery += "                       AND GX4.GX4_NRMOV = GX3.GX3_NRMOV"
	cQuery += "  INNER JOIN ("
	cQuery += "  		SELECT GX41.GX4_FILIAL, GX41.GX4_NRMOV, MIN(GX41.GX4_SEQ) SEQ"
	cQuery += " 		  FROM "+ RetSQLName("GX3") +" GX31"
	cQuery += " 		 INNER JOIN "+ RetSQLName("GX4") +" GX41 ON GX41.GX4_FILIAL = GX31.GX3_FILIAL AND GX41.GX4_NRMOV = GX31.GX3_NRMOV"
	cQuery += " 		 INNER JOIN "+ RetSQLName("Gvf") +" GVF1 ON GVF1.GVF_CDPTCT = GX41.GX4_CDPTCT"
	cQuery += " 		 WHERE GX31.D_E_L_E_T_ = ''"
	cQuery += " 		   AND GX41.D_E_L_E_T_ = ''"
	cQuery += " 		   AND GX31.GX3_SIT NOT IN ('5','6')"
	cQuery += " 		   AND ((GX41.GX4_DTENTR != '' AND GX41.GX4_DTSAI != '' AND GX41.GX4_SIT = '3' AND GVF1.GVF_IDIMPE = '1') OR (GX41.GX4_DTENTR = '' OR GX41.GX4_DTSAI = ''))" 
	cQuery += " 		 GROUP BY GX41.GX4_FILIAL, GX41.GX4_NRMOV"	
	cQuery += "  ) ATUAL ON ATUAL.GX4_FILIAL = GX4.GX4_FILIAL"
	cQuery += "         AND ATUAL.GX4_NRMOV = GX4.GX4_NRMOV"
	cQuery += "         AND ATUAL.SEQ = GX4.GX4_SEQ"
	cQuery += "  LEFT JOIN ("
	cQuery += " 		SELECT GX41.GX4_FILIAL, GX41.GX4_NRMOV, GX41.GX4_SEQ"
	cQuery += " 		  FROM "+ RetSQLName("GX3") +" GX31"
	cQuery += " 		 INNER JOIN "+ RetSQLName("GX4") +" GX41 ON GX41.GX4_FILIAL = GX31.GX3_FILIAL AND GX41.GX4_NRMOV = GX31.GX3_NRMOV"
	cQuery += " 		 INNER JOIN "+ RetSQLName("Gvf") +" GVF1 ON GVF1.GVF_CDPTCT = GX41.GX4_CDPTCT"
	cQuery += " 		 WHERE GX31.D_E_L_E_T_ = ''"
	cQuery += " 		   AND GX41.D_E_L_E_T_ = ''"
	cQuery += " 		   AND GX31.GX3_SIT NOT IN ('5','6')"
	cQuery += " 		   AND ((GX41.GX4_DTENTR != '' AND GX41.GX4_DTSAI != '' AND GX41.GX4_SIT = '3' AND GVF1.GVF_IDIMPE = '1') OR (GX41.GX4_DTENTR = '' OR GX41.GX4_DTSAI = ''))" 
	cQuery += "  ) PROXIMO  ON GX4.GX4_FILIAL = PROXIMO.GX4_FILIAL"
	cQuery += " 		   AND GX4.GX4_NRMOV = PROXIMO.GX4_NRMOV"
	cQuery += " 		   AND PROXIMO.GX4_SEQ > ATUAL.SEQ"
	cQuery += "  WHERE GX4.D_E_L_E_T_ = ''"
	cQuery += "    AND GX3.D_E_L_E_T_ = ''"
	cQuery += "    AND GX3.GX3_SIT NOT IN ('5','6')" 
	cQuery += "  GROUP BY GX4.GX4_FILIAL,"
	cQuery += "        	 GX4.GX4_CDPTCT,"
	cQuery += "        	 GX4.GX4_NRMOV,"
	cQuery += " 			 GX3.GX3_CDOPER,"
	cQuery += " 			 GX3.GX3_SEQ,"
	cQuery += " 			 GX3.GX3_SIT,"
	cQuery += " 			 GX3.GX3_CDEMIT,"
	cQuery += " 			 GX4.GX4_CDENDE"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())

	While (cTmp)->(!Eof())
	
		DO CASE
			CASE (cTmp)->GX3_SIT = '1'
				cSit := "Aberto"
			CASE (cTmp)->GX3_SIT = '2'
				cSit := "Movimentado"
			CASE (cTmp)->GX3_SIT = '3'
				cSit := "Em Fila"
			CASE (cTmp)->GX3_SIT = '4'
				cSit := "Endereçado"
			CASE (cTmp)->GX3_SIT = '5'
				cSit := "Cancelado"
			CASE (cTmp)->GX3_SIT = '6'
				cSit := "Concluído"
		ENDCASE

		// Lista de Veiculos da Movimentação
		cLstVei := ''
	  	dbSelectArea("GX6")
		GX6->( dbSetOrder(1) ) // GX6_FILIAL + GX6->GX6_NRMOV + GX6_CDVEIC
		If GX6->( dbSeek((cTmp)->FILMOV + (cTmp)->GX4_NRMOV ) )
			While GX6->( !Eof() ) .And. GX6->GX6_FILIAL == (cTmp)->FILMOV .And. GX6->GX6_NRMOV == (cTmp)->GX4_NRMOV 

				cCodVei := Posicione("GU8",1,xFilial("GU8")+GX6->GX6_CDVEIC,"GU8_PLACA") 

				If !Empty(cCodVei)
					cCodVei := Transform(cCodVei,cPictPlaca)

					If cLstVei == ''
						cLstVei := cCodVei
					Else
						cLstVei += ", " + cCodVei
					EndIf
				EndIf
				
				GX6->( dbSkip() )
			EndDo
		EndIf
		
		// Vai Para
	  	dbSelectArea("GX4")
		GX4->( dbSetOrder(1) )
		If GX4->( dbSeek((cTmp)->FILMOV + (cTmp)->GX4_NRMOV ) )
			While GX4->( !Eof() ) .And. GX4->GX4_FILIAL == (cTmp)->FILMOV .And. GX4->GX4_NRMOV == (cTmp)->GX4_NRMOV 
				If GX4->GX4_SEQ == (cTmp)->VAIPARA
					cVaiPar := Posicione("GVF",1,xFilial("GVF")+GX4->GX4_CDPTCT,"GVF_DSPTCT")
					Exit
				EndIf
				
				GX4->( dbSkip() )
			EndDo
		EndIf

		RecLock(cAlias,.T.)

			(cAlias)->GX4_FILIAL	:= (cTmp)->FILMOV
			(cAlias)->GX4_CDPTCT	:= (cTmp)->PTCTMOV
			(cAlias)->GX4_NRMOV	:= (cTmp)->GX4_NRMOV
			(cAlias)->GX3_CDOPER	:= (cTmp)->GX3_CDOPER
			(cAlias)->GX3_SEQ		:= (cTmp)->GX3_SEQ
			(cAlias)->GVI_DSCONF	:= Posicione("GVI",1,xFilial("GVI")+(cTmp)->GX3_CDOPER + (cTmp)->GX3_SEQ,"GVI_DSCONF")
			(cAlias)->GX3_SIT		:= cSit
			(cAlias)->GVD_DSENDE	:= Posicione("GVD",1,xFilial("GVD")+(cTmp)->GX4_CDENDE,"GVD_DSENDE")
			(cAlias)->GU8_PLACA	:= cLstVei
			(cAlias)->GU3_NMEMIT	:= Posicione("GU3",1,xFilial("GU3")+(cTmp)->GX3_CDEMIT,"GU3_NMEMIT")
			(cAlias)->VAIPARA 	:= cVaiPar

		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())
	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(1))
Return cAlias


Function C515VisualMov()

	dbSelectArea("GX3")
	GX3->(dbSetOrder(1))
	If GX3->(dbSeek((cAlias2)->( xFilial("GX3") + GX4_NRMOV )))
		FWExecView("Visualizar", "GFEC510")
	EndIf

Return Nil

Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE "Visualizar" ACTION "C515VisualMov()" OPERATION 2 ACCESS 0 //"Visualizar"
Return aRotina