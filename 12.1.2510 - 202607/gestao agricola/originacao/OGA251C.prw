#INCLUDE "OGA251C.ch"
#INCLUDE 'PROTHEUS.ch'
#INCLUDE "FWMVCDEF.CH"

Static __cTabNFs  := ""
Static __cNamNFs  := ""
Static __oBrwNFs  := Nil
Static oModelNJJ  := {}
Static oModelN9E  := {}
Static nOperation := 0


/*{Protheus.doc} OG251CAVU
Vincular NFs de origem para Nota Avulsa
@author Vanilda.moggio
@since 03/2025
@version 1.0
@type function
*/
Function OG251CAVU(oModel)

	oModelNJJ := oModel:GetModel("NJJUNICO")
		
	If !oModelNJJ:GetValue('NJJ_TIPO') $ "5"
		MsgAlert(STR0002, STR0001) // "Opção disponível apenas para Operação Entrada Compra" # Atenção
		Return .F.
	EndIf
	
	OG251CANFS(oModel)
	
Return .T.	


/*{Protheus.doc} OG251BDNFS
Vincular NFs de origem Avulsa para Entrada Compra
@author Vanilda.moggio
@since 03/2025
@version 1.0
@type function
*/
Function OG251CANFS(oModel)
	
	Local bKeyF12 := ""
	
	nOperation := oModel:GetOperation()
	oModelNJJ  := oModel:GetModel("NJJUNICO")
	oModelN9E  := oModel:GetModel("N9EUNICO")

	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		bKeyF12 := SetKey(VK_F12, {|| AtuBrwF12()})
	EndIf

	If !GetNJJAvu(oModelNJJ:GetValue('NJJ_FILIAL'),oModelNJJ:GetValue('NJJ_CODROM'))
		MsgAlert(STR0002, STR0001) // "Opção disponível apenas para Operação Entrada Compra" # Atenção
		Return .F.
	EndIf
		
	If oModelNJJ:GetValue('NJJ_TPFORM') == "2" .AND. (Empty(oModelNJJ:GetValue('NJJ_CODENT')) .OR. Empty(oModelNJJ:GetValue('NJJ_LOJENT')) .OR. Empty(oModelNJJ:GetValue('NJJ_CODPRO')) )
		MsgAlert(STR0003, STR0001) // "Os campos Entidade, Loja e Código do Produto são necessários para o vínculo das NFs" # Atenção
		Return .F.
	ElseIf oModelNJJ:GetValue('NJJ_TPFORM') == "1" .AND. Empty(oModelNJJ:GetValue('NJJ_CODPRO'))
		MsgAlert(STR0004, STR0001) // ###"O campo Código do Produto é necessário para o vínculo das NFs"
		Return .F.
	EndIf
						
	CriaBrowse()
		
Return .T.

/*{Protheus.doc} AtuBrwF12
Função chamada clicando no F12
@author Vanilda.moggio
@since 03/2025
@version 1.0
@type function
*/
Static Function AtuBrwF12()
	
	Local lProc := .F.

	lProc := InsRegNFs(.T.)
	
	If lProc
		__oBrwNFs:UpdateBrowse() // Atualiza os itens do browser
		__oBrwNFs:Refresh() // Aplica o Refresh no browser
	EndIf

Return .F.

/*{Protheus.doc} CriaBrowse
Cria browse das notas fiscais de venda para devolução
@author Vanilda.moggio
@since 03/2025
@version 1.0
@type function
*/
Static Function CriaBrowse()	
	Local aStrcNFs   := {{"", "T_OK", "C", 1,, "@!"}}
	Local aIndNFs    := {}	
	Local aCoors     := FWGetDialogSize(oMainWnd)
	Local oDlg	     := Nil
	Local oFWL		 := Nil
	Local aSize		 := Nil
	Local oSize1     := Nil
	Local oSize2     := Nil
	Local oSize3     := Nil
	Local oPnl1      := Nil
	//Local oPnlWnd1	 := Nil
	Local oPnlWnd2	 := Nil
	Local aFilBrwNFs := {}		
	Local nCont		 := 0	
	Local nOpcX	     := 1	
	Local aHeader	 := {}
	Local lRetorno   := .T.
	Local aIndSeek	 := {}
	Local aCpsNFsSk  := {}
	Local nCol		 := 1
	Local nPosFil	 := 0
	Local cCmpsTit	 := ""
	Local nCmpsTam	 := 0
		
	// Estrutura da tabela temporária de notas fiscais de origem	
	AAdd(aStrcNFs, {RetTitle("D1_DOC"),     "T_DOC",    TamSX3("D1_DOC")[3],     TamSX3("D1_DOC") [1],    TamSX3("D1_DOC") [2],    PesqPict("SD1","D1_DOC")})
	AAdd(aStrcNFs, {RetTitle("D1_SERIE"),   "T_SERIE",  TamSX3("D1_SERIE")[3],   TamSX3("D1_SERIE")[1],   TamSX3("D1_SERIE")[2],   PesqPict("SD1","D1_SERIE")})	
	AAdd(aStrcNFs, {RetTitle("D1_FORNECE"), "T_CLIENT", TamSX3("D1_FORNECE")[3], TamSX3("D1_FORNECE")[1], TamSX3("D1_FORNECE")[2], PesqPict("SD1","D1_FORNECE")})
	AAdd(aStrcNFs, {RetTitle("D1_LOJA"),    "T_LOJA",   TamSX3("D1_LOJA")[3],    TamSX3("D1_LOJA")[1],    TamSX3("D1_LOJA")[2],    PesqPict("SD1","D1_LOJA")})		
	AAdd(aStrcNFs, {RetTitle("D1_ITEM"),    "T_ITEDOC", TamSX3("D1_ITEM")[3],    TamSX3("D1_ITEM")[1],    TamSX3("D1_ITEM")[2],    PesqPict("SD1","D1_ITEM")})
	AAdd(aStrcNFs, {RetTitle("D1_EMISSAO"), "T_DOCEMI", TamSX3("D1_EMISSAO")[3], TamSX3("D1_EMISSAO")[1], TamSX3("D1_EMISSAO")[2], PesqPict("SD1","D1_EMISSAO")})
	AAdd(aStrcNFs, {STR0011,            	"T_QTDRET", TamSX3("D1_QUANT")[3],   TamSX3("D1_QUANT")[1],   TamSX3("D1_QUANT")[2],   PesqPict("SD1","D1_QUANT")}) // Qtd. Ret.
	AAdd(aStrcNFs, {RetTitle("NJM_CODCTR"), "T_CTRVND", TamSX3("NJM_CODCTR")[3], TamSX3("NJM_CODCTR")[1], TamSX3("NJM_CODCTR")[2], PesqPict("NJM","NJM_CODCTR")})
	AAdd(aStrcNFs, {RetTitle("NJM_ITEROM"),   "T_ETGVND", TamSX3("NJM_ITEROM")[3],   TamSX3("NJM_ITEROM")[1],   TamSX3("NJM_ITEROM")[2],   PesqPict("NJM","NJM_ITEROM")})
	
	// Definição dos índices da tabela
	aIndNFs := {{"CHAVE","T_DOC,T_SERIE,T_CLIENT,T_LOJA,T_ITEDOC"}, {"SELEC", "T_OK"}}
		
	Processa({|| OG710ACTMP(@__cTabNFs, @__cNamNFs, aStrcNFs, aIndNFs)}, STR0004) // Aguarde. Carregando a tela
		
	// Carrega os registros das tabelas temporárias das notas fiscais	
	Processa({|| InsRegNFs(.F.)}, STR0005) // Aguarde. Selecionando notas fiscais disponíveis

	/************* TELA PRINCIPAL ************************/
	aSize := MsAdvSize()

	//tamanho da tela principal
	oSize1 := FWDefSize():New(.T.)
	oSize1:AddObject('DLG',100,100,.T.,.T.)
	oSize1:SetWindowSize(aCoors)
	oSize1:lProp 	:= .T.
	oSize1:aMargins := {0,0,0,0}
	oSize1:Process()

	oDlg := TDialog():New(oSize1:aWindSize[1], oSize1:aWindSize[2], oSize1:aWindSize[3], oSize1:aWindSize[4], STR0006, , , , , CLR_BLACK, CLR_WHITE, , , .T.) // Vincular NFs de origem

	// Desabilita o fechamento da tela através da tela ESC.
	oDlg:lEscClose := .F.

	oPnl1:= tPanel():New(oSize1:aPosObj[1,1], oSize1:aPosObj[1,2],, oDlg,,,,,, oSize1:aPosObj[1,4], oSize1:aPosObj[1,3] - 30)

	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init(oPnl1, .F.)

	// Cria as divisões horizontais
	oFWL:addLine('MASTER', 100, .F.)
	oFWL:addCollumn('CENTER', 100, .F., 'MASTER')

	//cria as janelas
	//oFWL:addWindow('CENTER', 'Wnd1', STR0007, 25/*tamanho*/, .F., .T.,, 'MASTER') //"Total de notas fiscais"
	oFWL:addWindow('CENTER', 'Wnd2', STR0008, 75/*tamanho*/, .F., .T.,, 'MASTER') //"Notas fiscais"
	
	//oPnlWnd1 := oFWL:getWinPanel('CENTER', 'Wnd1', 'MASTER')
	oPnlWnd2 := oFWL:getWinPanel('CENTER', 'Wnd2', 'MASTER')
	
	/***********************************************************/
	
	//- Recupera coordenadas 
	oSize2 := FWDefSize():New(.F.)
	oSize2:AddObject(STR0007,100,100,.T.,.T.) // Total de notas fiscais
	//oSize2:SetWindowSize({0,0,oPnlWnd1:NHEIGHT, oPnlWnd1:NWIDTH})
	oSize2:lProp 	:= .T.
	oSize2:aMargins := {0,0,0,0}
	oSize2:Process()
			
	/****************** NFs de Origem ********************************/
	
	aHeader := {}
	
	nPosFil := AScan(aIndNFs, {|x| AllTrim(x[1]) == "CHAVE"})
	cChave  := aIndNFs[nPosFil][2]
	
	For nCont := 2 to Len(aStrcNFs)
	
		If !aStrcNFs[nCont][2] $ "NJM_FILORG|NJM_CODINE" .AND. At(aStrcNFs[nCont][2], cChave) > 0
			If !Empty(cCmpsTit)
				cCmpsTit += "+"
			EndIf
			
			cCmpsTit += AllTrim(aStrcNFs[nCont][1])
			nCmpsTam += aStrcNFs[nCont][4]			
		EndIf
				
		Aadd(aCpsNFsSk, {aStrcNFs[nCont][2], aStrcNFs[nCont][3], aStrcNFs[nCont][4], aStrcNFs[nCont][5], aStrcNFs[nCont][1], aStrcNFs[nCont][6]})
	 	
	 	// Monta as colunas
	    If !aStrcNFs[nCont][2] $ "NJM_CODINE|NJM_CODCTR|NJM_ITEROM|NJM_SEQPRI" // Não mostra os campos no browse	    	   
	    	AAdd(aHeader,FWBrwColumn():New())
			aHeader[nCol]:SetData(&("{||"+aStrcNFs[nCont][2]+"}"))
			aHeader[nCol]:SetTitle(aStrcNFs[nCont][1])
			aHeader[nCol]:SetPicture(aStrcNFs[nCont][6])
			aHeader[nCol]:SetType(aStrcNFs[nCont][3])
			aHeader[nCol]:SetSize(aStrcNFs[nCont][4])
			aHeader[nCol]:SetReadVar(aStrcNFs[nCont][2])
			nCol++
							   	    	
	    	Aadd(aFilBrwNFs, {aStrcNFs[nCont][2], aStrcNFs[nCont][1], aStrcNFs[nCont][3], aStrcNFs[nCont][4], aStrcNFs[nCont][5], aStrcNFs[nCont][6]})    	    
	    EndIf	    
    Next nCont
	
	//- Recupera coordenadas 
	oSize3 := FWDefSize():New(.F.)
	oSize3:AddObject(STR0008,100,100,.T.,.T.) //"Notas fiscais"
	oSize3:SetWindowSize({0, 0, oPnlWnd2:NHEIGHT, oPnlWnd2:NWIDTH})
	oSize3:lProp 	:= .T.
	oSize3:aMargins := {0,0,0,0}
	oSize3:Process()
					                       
	__oBrwNFs := FWFormBrowse():New()
	__oBrwNFs:SetOwner(oPnlWnd2)
	__oBrwNFs:SetDataTable(.T.)
	__oBrwNFs:SetTemporary(.T.)
    __oBrwNFs:SetAlias(__cTabNFs)
    __oBrwNFs:SetProfileID("NFS")    
                
    // Filtro
    __oBrwNFs:SetUseFilter(.T.)
	__oBrwNFs:SetUseCaseFilter(.T.)                         
    __oBrwNFs:SetFieldFilter(aFilBrwNFs)   
    __oBrwNFs:SetDBFFilter(.T.)
          
    __oBrwNFs:Acolumns := {}
    __oBrwNFs:AddMarkColumns({||IIf((__cTabNFs)->T_OK == "1", "LBOK", "LBNO")}, {|| MarkBrw(__oBrwNFs)}, )
        
	Aadd(aIndSeek,{cCmpsTit ,{{"", 'C' , nCmpsTam, 0 , "@!" }}, 2, .T.})
    
	__oBrwNFs:SetSeek(,aIndSeek)
	__oBrwNFs:SetColumns(aHeader)	   
    __oBrwNFs:DisableReport(.T.)
    __oBrwNFs:DisableDetails()
    __oBrwNFs:Activate()
	
	oDlg:Activate(,,, .T.,,, EnchoiceBar(oDlg, {|| nOpcX := 1, IIF(vldQtdVinc(1),ODlg:End(),nOpcX := 0)} /*OK*/, {|| nOpcX := 0, oDlg:End()} /*Cancel*/ ) )
	
	If nOpcX = 1 .AND. nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		Processa({|| lRetorno := VincRom()}, STR0013) // Aguarde. Vinculando notas fiscais no romaneio.		
	EndIf
		
Return .T.

Static Function vldQtdVinc(nMaxMk)
Local aAreaNFs := (__cTabNFs)->(GetArea())	
Local lRet2    := .T.	
Local nX:= 0
	
	DbSelectArea((__cTabNFs))
	(__cTabNFs)->(DbGoTop())
	(__cTabNFs)->(DbSetOrder(2)) // Notas Fiscais marcadas
	If (__cTabNFs)->(DbSeek("1"))
								 
		While (__cTabNFs)->(!Eof()) 		
			If (__cTabNFs)->T_OK == "1"  
				//Mark nao tem ter nenhum e no salvar nao pode ter 2
                nX += 1
				If nX > nMaxMk
					lRet2:= .F.
				EndIf	
			EndIf		
			(__cTabNFs)->(DbSkip())	
		EndDo									
	EndIf	

	If !lRet2
		MsgAlert(STR0019, STR0001) //###"Não é possivel selecionar mais que uma nota avulsa."
	EndIf
	
	RestArea(aAreaNFs)

Return lRet2


/*{Protheus.doc} MarkBrw
Seleção individual do browse de notas fiscais
@author Vanilda.moggio
@since 03/2025
@version 1.0
@type function
*/
Static Function MarkBrw(oBrwObj)
	Local lMarcar := .F.
		
	If Empty((oBrwObj:Alias())->(T_OK))
		lMarcar := .T.				
	EndIf
	
	If lMarcar .AND. !vldQtdVinc(0)
		Return .F.
	EndIf
			
	/* Atualiza a grid de notas fiscais */
	AtualizNFs(oBrwObj:Alias(), "N", lMarcar)

	oBrwObj:Refresh(.T.)
	
	oBrwObj:SetFocus() 
	oBrwObj:GoColumn(1)

Return .T.

/*{Protheus.doc} AtualizNFs
Atualiza a grid de notas fiscais

@author vanilda.moggio
@since  09/03/2025
@version 1.0
@param cAliasBrw, character, Alias do objeto do browser marcado
@param cBrwName, characters, Nome do browser ("T"=Totais;"N"=Notas Fiscais)
@param lMarcar, logical, .T. - Marcar; .F. - Desmarcar
@param lQtdMan, logical, .T. - Digitado quantidade vinculada
@param nQtdMax, numerico, quantidade máxima (selecionada) - utilizada para quando informa uma quantidade manualmente
na parte "Totais de notas fiscais"
@param lMarcarT, logical, .T. - Marcar todos;
@type function
*/
Static Function AtualizNFs(cAliasBrw, cBrwName, lMarcar, lQtdMan, nQtdMax, lMarcarT)
	Local aAreaNFs := (__cTabNFs)->(GetArea())
	
		If RecLock(cAliasBrw, .F.)
			(cAliasBrw)->T_OK     := IIf(lMarcar, "1", "")				
			(cAliasBrw)->(MsUnlock())
		EndIf
	
	RestArea(aAreaNFs)

Return .T.

/*{Protheus.doc} InsRegNFs
Seleção das notas fiscais 
@author Vanilda.moggio
@since 03/2025
@version 1.0
@type function
*/
Static Function InsRegNFs(lF12)
	Local cQuery     := ""
	Local cAliasNFs  := ""
	Local cQryInsert := ""
	Local cMark		 := ""
	Local cFornec    := POSICIONE('NJ0',1,XFILIAL('NJ0') + oModelNJJ:GetValue('NJJ_CODENT') + oModelNJJ:GetValue('NJJ_LOJENT') ,'NJ0_CODFOR')
	Local cLojFor    := POSICIONE('NJ0',1,XFILIAL('NJ0') + oModelNJJ:GetValue('NJJ_CODENT') + oModelNJJ:GetValue('NJJ_LOJENT') ,'NJ0_LOJFOR')
	Local nX         := 0
	
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		If !Pergunte("OGA251B001", .T.)		
			If lF12	
				Return .F.
			EndIf
		EndIf
	EndIf
						
	// Limpa a tabela temporária
	DbSelectArea(__cTabNFs)
	(__cTabNFs)->(DbSetorder(1))
	ZAP
				    
    // Monta a query de busca
    cQuery := "SELECT D1_FILIAL  AS FILIAL, "
    cQuery += "       D1_DOC     AS DOC, "
	cQuery += " 	  D1_SERIE   AS SERIE, "
	cQuery += " 	  D1_FORNECE AS FORNECEDOR, "
	cQuery += " 	  D1_LOJA    AS LOJA, "
	cQuery += " 	  D1_ITEM    AS ITEDOC, "
	cQuery += " 	  D1_EMISSAO  AS DOCEMI, "		
	cQuery += " 	  NJM.NJM_CODCTR  AS CTR, "
	cQuery += " 	  NJM.NJM_ITEROM    AS ITEMROM," 
	cQuery += "       D1_QUANT  AS QTD"
    cQuery += " FROM " + RetSqlName("NJM") + " NJM "
	cQuery += "	LEFT JOIN " + RetSqlName("SD1") + " D1 "
    cQuery +=  " ON D1_FILIAL = NJM.NJM_FILIAL "
    cQuery += "   AND D1_COD      = '"+oModelNJJ:GetValue('NJJ_CODPRO')+"' "
	cQuery += "   AND D1_FORNECE  = '"+ cFornec + "' "
	cQuery += "   AND D1_LOJA     = '" + cLojFor + "' "
	cQuery += "   AND D1_CODROM   = '' "
	cQuery += "   AND (D1_QUANT - D1_QTDEDEV) > 0		
	cQuery += "   AND  D1.D_E_L_E_T_ = '' "			

	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE	
		If !Empty(MV_PAR01)  // Data de Emissão De? 
			cQuery += " AND (D1_EMISSAO >= '" + dToS(MV_PAR01) + "') "
		EndIf
	
		If !Empty(MV_PAR02)  // Data de Emissão Até?
			cQuery += " AND (D1_EMISSAO <= '" + dToS(MV_PAR02) + "') "
		EndIf
	EndIf
			
	cQuery += " where  NJM.NJM_FILIAL = '" + fwxFilial( 'NJM' ) + "'"	
	cQuery += "   AND NJM.NJM_CODROM = '" + oModelNJJ:GetValue('NJJ_CODROM') + "' "	
	cQuery += "	GROUP BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_ITEM, D1_EMISSAO, "
	cQuery += "	         NJM.NJM_CODCTR, NJM.NJM_ITEROM, D1_QUANT "
	cQuery += "	 ORDER BY  D1_EMISSAO DESC "
	cQuery := ChangeQuery(cQuery)
	cAliasNFs := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasNFs,.F.,.T.)
		
	If (cAliasNFs)->(!EoF())
		While (cAliasNFs)->(!EoF())

			If ! GetN9EAvu((cAliasNFs)->FILIAL,(cAliasNFs)->DOC,(cAliasNFs)->SERIE,(cAliasNFs)->FORNECEDOR ,(cAliasNFs)->LOJA,oModelNJJ:GetValue('NJJ_CODROM') ) 								
				IF oModelN9E != NIL 
					cMark:= " "	
					For nX := 1 to oModelN9E:Length()
						If .Not. oModelN9E:IsDeleted()
							If oModelN9E:GetValue('N9E_ORIGEM', nX) ==  "8     " .AND. oModelN9E:GetValue('N9E_DOC', nX) == (cAliasNFs)->DOC .AND.;
							oModelN9E:GetValue('N9E_SERIE' , nX) == (cAliasNFs)->SERIE .AND. oModelN9E:GetValue('N9E_ITEDOC', nX) == (cAliasNFs)->ITEDOC .AND.;
							oModelN9E:GetValue('N9E_CLIFOR', nX) == (cAliasNFs)->FORNECEDOR .AND. oModelN9E:GetValue('N9E_LOJA', nX) == (cAliasNFs)->LOJA 						 
								cMark:= "1"			 
								EXIT
							EndIf			
						EndIf	
					Next nX
				EndIf
																						
				cQryInsert := "('"+(cAliasNFs)->DOC+"', '"+(cAliasNFs)->SERIE+"', '"+(cAliasNFs)->FORNECEDOR+"', '"+(cAliasNFs)->LOJA+"', '"+ (cAliasNFs)->ITEDOC +"', '"+(cAliasNFs)->DOCEMI+"', '"+AllTrim(STR((cAliasNFs)->QTD))+"', '"+(cAliasNFs)->ITEMROM+"','"+(cAliasNFs)->CTR+"', '"+cMark+"') "
				TCSqlExec("INSERT INTO "+__cNamNFs+" (T_DOC, T_SERIE, T_CLIENT, T_LOJA, T_ITEDOC, T_DOCEMI, T_QTDRET, T_ETGVND,T_CTRVND, T_OK) VALUES " + cQryInsert)			  
			EndIf

			(cAliasNFs)->(DbSkip())
		EndDo
	EndIf
	
	(cAliasNFs)->(DbCloseArea())	

	// Refresh nos browsers
	TCRefresh(__cNamNFs)
				
Return .T.

/*{Protheus.doc} VincRom
Vincula das NFs no romaneio para Devolução de Venda

@author vanilda.moggio
@since  24/08/2018
@type function
*/
Static Function VincRom()
	Local aAreaNFs := (__cTabNFs)->(GetArea())	
	Local lRet	   := .T.
	Local nI	   := 0
						
	For nI := 1 to oModelN9E:Length()
		oModelN9E:GoLine(nI)
		oModelN9E:DeleteLine()
	Next nI
	
	DbSelectArea((__cTabNFs))
	(__cTabNFs)->(DbGoTop())
	(__cTabNFs)->(DbSetOrder(2)) // Notas Fiscais marcadas
	If (__cTabNFs)->(DbSeek("1"))
								 
		While (__cTabNFs)->(!Eof()) .AND. (__cTabNFs)->T_OK == "1"
		
			oModelN9E:AddLine()
			oModelN9E:SetValue("N9E_ORIGEM", "8")
			oModelN9E:SetValue("N9E_CODCTR", (__cTabNFs)->T_CTRVND)
			oModelN9E:SetValue("N9E_ITEM", (__cTabNFs)->T_ETGVND)
			oModelN9E:SetValue("N9E_SEQPRI", '001')
			oModelN9E:SetValue("N9E_DOC", (__cTabNFs)->T_DOC)
			oModelN9E:SetValue("N9E_SERIE", (__cTabNFs)->T_SERIE)
			oModelN9E:SetValue("N9E_CLIFOR", (__cTabNFs)->T_CLIENT)
			oModelN9E:SetValue("N9E_LOJA", (__cTabNFs)->T_LOJA)
			oModelN9E:SetValue("N9E_ITEDOC", (__cTabNFs)->T_ITEDOC)
			oModelN9E:SetValue("N9E_QTDRET", (__cTabNFs)->T_QTDRET)						

			(__cTabNFs)->(DbSkip())	
		EndDo	
								
	EndIf	
			
	RestArea(aAreaNFs)		
		
Return lRet

/*/{Protheus.doc} GetN9EAvu
Descartar nota avulsa para informar como nota de origem que ja tenha romaneio
@type function
@version 1  
@author Vanilda Moggio
@since 20/03/2025
@return logical, .F. Se falso nao ha romaneio com esta nota e pode listar para selecionar
/*/
Static Function GetN9EAvu (cFILIAL,cDOC,cSERIE,cFORNECEDOR ,cLOJA,cRomaneio )
	Local cQuery    := ""
	Local cAliasQry := ""
	Local lRet      := .F. // Se falso nao ha romaneio com esta nota e pode listar para selecionar
	
	// Monta a query de busca
    cQuery := "SELECT 1 FROM " + RetSqlName("N9E") + " N9E "
    cQuery += "   where  N9E.N9E_Filial = '" + cFILIAL + "'"	
	cQuery += "   AND N9E.N9E_ORIGEM = '8' AND N9E.N9E_DOC = '" + cDOC + "'"
	cQuery += "	  AND N9E.N9E_SERIE = '" + cSERIE + "'" "
	cQuery += "	  AND N9E.N9E_CLIFOR = '" + cFORNECEDOR + "'" "
	cQuery += "	  AND N9E.N9E_LOJA = '" + cLOJA + "'" "
	cQuery += "   AND N9E.N9E_CODROM <>  '" + cRomaneio + "'" 	
	cQuery += "   AND N9E.D_E_L_E_T_ = '' "		
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
	If (cAliasQry)->(!EoF())
		lRet := .T.
	EndIf
	
	(cAliasQry)->(DbCloseArea())	
			
Return lRet


/*/{Protheus.doc} GetN9EAvu
Descartar nota avulsa para informar como nota de origem que ja tenha romaneio
@type function
@version 1  
@author Vanilda Moggio
@since 20/03/2025
@return logical, .F. Se falso nao ha romaneio com esta nota e pode listar para selecionar
/*/
Static Function GetNJJAvu (cFILIAL,cRomaneio )
	Local cQuery    := ""
	Local cAliasQry := ""
	Local lRet      := .F. // Se falso nao ha romaneio com tipo 5, nao pode continuar
	
	// Monta a query de busca
    cQuery := "SELECT 1 FROM " + RetSqlName("NJJ") + " NJJ "
    cQuery += "   where  NJJ.NJJ_Filial = '" + cFILIAL + "'"	
	cQuery += "   AND NJJ.NJJ_CODROM    =  '" + cRomaneio + "'" 	
	cQuery += "   AND NJJ.NJJ_TIPO      =  '5'" 	
	cQuery += "   AND NJJ.D_E_L_E_T_ = '' "		
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
	If (cAliasQry)->(!EoF())
		lRet := .T.
	EndIf
	
	(cAliasQry)->(DbCloseArea())	
			
Return lRet
