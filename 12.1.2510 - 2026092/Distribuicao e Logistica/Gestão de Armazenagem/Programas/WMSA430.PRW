#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "WMSA430.CH"

//-----------------------------------
/*{Protheus.doc}
Desfragmentador de Estoque

@author Felipe Machado de Oliveira
@version P12
@Since	25/07/13
@obs Desfragmentador de Estoque
*/
//-----------------------------------
Static __cServico := ""
Static __cTarefa := ""
Function WMSA430()
Local lAtiva    := .F.
Local aCols     := {}
Local aColsSX3  := {}
Local aSeek     := {}
Local aIndex    := {}
Local aProdSX3  := {}
Local aEndSX3   := {}
Local aCoors    := FWGetDialogSize(oMainWnd)
Local oLayer    := Nil
Local oRight    := Nil
Local oLeft     := Nil
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)

Private oDlg := Nil
Private oMrkBrw := Nil
Private aMainPar	:= {}
Private aCamposTmp := {}
Private cAliasTmp
Private aLibSDB := {}
Private oGrafLeft := Nil
Private oGrafRight := Nil
Private aDadosGraf := {}
Private aParam150	:= {}
Private cMvProdDe := ""
Private cMvProdAte := ""
Private cMvZona := ""
Private cMvLocal := ""
Private cMvEndDe := ""
Private cMvEndAte := ""
	
	If lWmsNew
		Return WMSA431()
	EndIf
	lAtiva := ValDC5()
	
	If lAtiva .And. !Pergunte("WMSA430")
		lAtiva := .F.
	EndIf
	
	If lAtiva
		cMvProdDe  := MV_PAR01
		cMvProdAte := MV_PAR02
		cMvZona    := MV_PAR03
		cMvLocal   := MV_PAR04
		cMvEndDe   := MV_PAR05
		cMvEndAte  := MV_PAR06
		
		// Cria tabela temporária
		CriaTemp()
		
		Processa( {|| ProcRegua(0), Processa( {|| WmsEndOcup("",.T.) } , '', STR0012 + "...", .F. )  } , '', STR0012 + "...", .F. ) // Desfragmentando
				
		If Empty(aMainPar)
			Help(,,STR0001,,STR0002,1,0) // Aviso // Não foram encontrados endereços passíveis de desfragmentação
			lAtiva := .F.
		EndIf
		
		If lAtiva
			DEFINE MsDialog oDlg TITLE STR0003 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL // Desfragmentador de Estoque			
    		oLayer := FWLayer():New()
    		oLayer:Init(oDlg,.F.,.T.)
    		oLayer:AddLine("TOP",60,.T.)
    		oLayer:AddLine("BOTTOM",40,.T.)
    		oLayer:AddCollumn( "LEFT",50,.T.,"BOTTOM" )
    		oLayer:AddCollumn( "RIGHT",50,.T.,"BOTTOM" )
			
    		oLnTop := oLayer:GetLinePanel("TOP")
    		oLeft := oLayer:GetColPanel("LEFT","BOTTOM" )
    		oRight := oLayer:GetColPanel("RIGHT","BOTTOM" )
			
			aAdd(aCols,{buscarSX3("BF_PRODUTO",,aColsSX3),"TMP_PRODUT","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			aAdd(aCols,{buscarSX3("B1_DESC",,aColsSX3),"TMP_DESPRO","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			aAdd(aCols,{buscarSX3("BF_LOCAL",,aColsSX3),"TMP_LOCAL","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			aAdd(aCols,{buscarSX3("BF_QUANT",,aColsSX3),"TMP_QTD","N",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			aAdd(aCols,{buscarSX3("BF_LOTECTL",,aColsSX3),"TMP_LOTE","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			aAdd(aCols,{buscarSX3("BF_NUMLOTE",,aColsSX3),"TMP_SULOTE","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
			aAdd(aCols,{buscarSX3("BF_LOCALIZ",STR0004,aColsSX3),"TMP_ENDORI","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // End. Origem
			aAdd(aCols,{buscarSX3("BF_LOCALIZ",STR0005,aColsSX3),"TMP_ENDDST","C",aColsSX3[3],aColsSX3[4],aColsSX3[2]}) // End. Destino
			
			buscarSX3("BF_PRODUTO",,aProdSX3)
			buscarSX3("BF_LOCALIZ",,aEndSX3)
			
			// Opção de índice da pesquisa
			aAdd( aSeek, { StrTran(aProdSX3[1]," ",""), { {"SB1","C",aProdSX3[3],aProdSX3[4],aProdSX3[1],aProdSX3[2]} },1 } )
			aAdd( aSeek, { STR0004+"+"+STR0005, { {"SBE","C",aEndSX3[3],aEndSX3[4],STR0004,aEndSX3[2]}, {"SBE","C",aEndSX3[3],aEndSX3[4],STR0005,aEndSX3[2]} },1 } ) // End. Origem// End. Destino"
			
    		// Campos do índice
    		aAdd( aIndex, "TMP_PRODUT" )
    		aAdd( aIndex, "TMP_ENDORI+TMP_ENDDST" )
			
			oMrkBrw := FWMarkBrowse():New()
			oMrkBrw:SetOwner(oLnTop)
			oMrkBrw:SetAlias(cAliasTmp)
			oMrkBrw:oBrowse:SetQueryIndex(aIndex)
    		oMrkBrw:SetTemporary(.T.)
    		oMrkBrw:SetSeek(,aSeek)
			oMrkBrw:SetFields(aCols)
			oMrkBrw:SetFieldMark("TMP_OK")
			oMrkBrw:SetDescription(STR0003) // Desfragmentador de Estoque
			oMrkBrw:ForceQuitButton()
			oMrkBrw:oBrowse:SetFixedBrowse(.T.)
			oMrkBrw:oBrowse:SetMenuDef("WMSA430")
			oMrkBrw:AllMark()
			oMrkBrw:SetAfterMark( {|| AfterMark() } )
			oMrkBrw:SetAllMark( {|| AllMark() } )
			
			// Cria objetos gráficos
			oGrafLeft := FWChartFactory():New()
			oGrafLeft := oGrafLeft:GetInstance(BARCHART)
			oGrafLeft:Init(oLeft,.F.,.F.)
			oGrafLeft:SetMaxY(100)
			oGrafLeft:SetTitle(STR0006 , CONTROL_ALIGN_CENTER) // Situação Atual
			oGrafLeft:SetLegend(CONTROL_ALIGN_RIGHT)
			
			// Adiciona as colunas do gráfico esquerdo - Situação Atual
			oGrafLeft:AddSerie( "% "+STR0007, NoRound(aDadosGraf[1][3],2) ) // Endereços Ocupados
			oGrafLeft:AddSerie( "% "+STR0008, NoRound(aDadosGraf[1][4],2) ) // Endereços Livres
			
			oGrafRight := FWChartFactory():New()
			oGrafRight := oGrafRight:GetInstance( BARCHART )
			oGrafRight:Init( oRight, .F., .F. )
			oGrafRight:SetMaxY( 100 )
			oGrafRight:SetTitle( STR0009, CONTROL_ALIGN_CENTER ) // Situação Pós-Desfragmentação
			oGrafRight:SetLegend( CONTROL_ALIGN_RIGHT )
			
			// Adiciona as colunas do gráfico direito - Situação Pós-Desfragmentação
			oGrafRight:AddSerie( "% "+STR0007, NoRound(aDadosGraf[2][3],2) ) // Endereços Ocupados
			oGrafRight:AddSerie( "% "+STR0008, NoRound(aDadosGraf[2][4],2) ) // Endereços Livres
			
			oMrkBrw:Activate()
			oGrafLeft:Build()
			oGrafRight:Build()
				
			ACTIVATE MsDialog oDlg CENTER
		EndIf
		DelTabTmp( cAliasTmp )
	EndIf
Return Nil
//-----------------------------------
/*{Protheus.doc}
MenuDef

@author Felipe Machado de Oliveira
@version P12
@Since	26/07/13
@obs
*/
//-----------------------------------
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0010 ACTION "WMSA430EXC()" OPERATION 4 ACCESS 0 DISABLE MENU // Executar
	ADD OPTION aRotina TITLE STR0011 ACTION "WMSA430SLN()" OPERATION 3 ACCESS 0 DISABLE MENU // Selecionar
Return aRotina
//-----------------------------------
/*{Protheus.doc}
Executar a Desfragmentação

@author Felipe Machado de Oliveira
@version P12
@Since	26/07/13
@obs Executar a Desfragmentação
*/
//-----------------------------------
Function WMSA430EXC()
	Processa( {|| ProcRegua(0), Processa( {|| WMSA430EXD() } , STR0010, STR0012 + "...", .F. )  } , STR0010, STR0012 + "...", .F. ) // Executar // Desfragmentando	
Return .T.
//-----------------------------------
/*{Protheus.doc}
Executa a Desfragmentação

@author Felipe Machado de Oliveira
@version P12
@Since	26/07/13
@obs Executa a Desfragmentação
*/
//-----------------------------------
Function WMSA430EXD()
Local lRet := .T.
Local aPar150Aux := {}
Local lDiferente := .F.
Local lInvert := oMrkBrw:IsInvert()
Local cMarca := oMrkBrw:Mark()
	// Monta o array com os itens selecionados do MarkBrowse
	aPar150Aux := GetSlcted(cMarca,lInvert)
	
	If Empty(aPar150Aux)
		Help(,,STR0001,,STR0013,1,0) // Aviso // Selecione um item da lista
		lRet := .F.
	EndIf
	
	If lRet
		// Avalia os endereços para validar se houve movimentação antes de executar
		If !CheckEnd(aPar150Aux)
			Help(,,STR0001,,STR0014,1,0) // Aviso // Houve movimentação nos endereços. Rever análise.
			lDiferente := .T.
		EndIf
		
		// Se houve movimentação não executa
		If !lDiferente
			If Len(aPar150Aux) > 0
				WMSDesfrag(aPar150Aux)
			EndIf
		EndIf
		
		// Atualiza os itens do MarkBrowse
		WmsEndOcup(cMarca,lInvert)
	
		If Empty(aMainPar)
			oDlg:End()
		Else
			AtuGrafs()
			oMrkBrw:Refresh()
		EndIf
	EndIf
Return lRet
//-----------------------------------
/*{Protheus.doc}
Valida Serviço x Tarefa

@author Felipe Machado de Oliveira
@version P12
@Since	25/07/13
@obs Validação do Serviço x Tarefa
*/
//-----------------------------------
Static Function ValDC5()
Local lRet := .F.
Local cQuery := ""
Local cAliasDC5 := GetNextAlias()
	// Validação antes da abertura do programa
	cQuery := "SELECT DC5_SERVIC,"
	cQuery +=       " DC5_TAREFA,"
	cQuery +=       " DC5_FUNEXE"
	cQuery +=  " FROM "+RetSqlName("DC5")
	cQuery += " WHERE DC5_FILIAL = '"+xFilial("DC5")+"'"
	cQuery +=   " AND DC5_TIPO = '3'"
	cQuery +=   " AND DC5_FUNEXE <> ' ' "
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cAliasDC5 := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDC5,.T.,.T.)
	Do While (cAliasDC5)->(!Eof()) .And. !lRet

		If Upper(AllTrim(Tabela("L6",(cAliasDC5)->DC5_FUNEXE))) == "DLDESFRAG()"
			__cServico := (cAliasDC5)->DC5_SERVIC
			__cTarefa := (cAliasDC5)->DC5_TAREFA
			lRet := .T.
		EndIf

		(cAliasDC5)->(dbSkip())
	EndDo
	(cAliasDC5)->(dbCloseArea())
	
	If Empty(__cServico) .Or. Empty(__cTarefa)
		Help(,,STR0001,,STR0015,1,0) // Aviso // Não existe Serviço x Tarefa de Desfragmentar Estoque que seja Movimentação Interna com Tarefa de Transferência.
	EndIf
Return lRet

//-----------------------------------
/*{Protheus.doc}
Cria a tabela temporária

@author Felipe Machado de Oliveira
@version P12
@Since	26/07/13
@obs Cria a tabela temporária
*/
//-----------------------------------
Static Function CriaTemp()
Local aColsSX3 := {}
	
	Aadd(aCamposTmp,{"TMP_OK","C",2,0}) // Marca
	
	buscarSX3("BF_PRODUTO",,aColsSX3)
	Aadd(aCamposTmp,{"TMP_PRODUT","C",aColsSX3[3],aColsSX3[4]}) // Produto
	
	buscarSX3("B1_DESC",,aColsSX3)
	Aadd(aCamposTmp,{"TMP_DESPRO","C",aColsSX3[3],aColsSX3[4]}) // Descrição do Produto
	
	buscarSX3("BF_LOCAL",,aColsSX3)
	Aadd(aCamposTmp,{"TMP_LOCAL","C",aColsSX3[3],aColsSX3[4]}) // Armazem
	
	buscarSX3("BF_QUANT",,aColsSX3)
	Aadd(aCamposTmp,{"TMP_QTD","N",aColsSX3[3],aColsSX3[4]}) // Quantidade a ser transferida
	
	buscarSX3("BF_LOTECTL",,aColsSX3)
	Aadd(aCamposTmp,{"TMP_LOTE","C",aColsSX3[3],aColsSX3[4]}) // Lote
	
	buscarSX3("BF_NUMLOTE",,aColsSX3)
	Aadd(aCamposTmp,{"TMP_SULOTE","C",aColsSX3[3],aColsSX3[4]}) // SubLote
	
	buscarSX3("BF_LOCALIZ",,aColsSX3)
	Aadd(aCamposTmp,{"TMP_ENDORI","C",aColsSX3[3],aColsSX3[4]}) // Endereço de Origem 
	Aadd(aCamposTmp,{"TMP_ENDDST","C",aColsSX3[3],aColsSX3[4]}) // Endereço de Destino
	
	cAliasTmp := CriaTabTmp(aCamposTmp,{"TMP_PRODUT","TMP_ENDORI+TMP_ENDDST"},cAliasTmp)
Return Nil
//-----------------------------------
/*{Protheus.doc}
Busca um endereço parcialmente ocupado por outro produto

@author Evaldo Cevinscki Jr.
@version P12
@Since	25/07/13
@param cLocal    = Local
		cZona     = Zona
		cProdDe   = Produto De
		cProdAte  = Produto Até
@obs Busca um endereço parcialmente ocupado por outro produto
*/
//-----------------------------------
Static Function WmsEndOcup(cMarca,lInvert)
Local cAliasQry := GetNextAlias()
Local aAreaSBE := SBE->( GetArea() )
Local lRet := .F.
Local cProdArm := ""
Local cEndsOcup := "" 
Local cLote := ""
Local cSubLote := ""
Local lCompartilha := .F.
Local i := 1
Local j := 1
Local x := 0
Local aEndComp := {}
Local aAux := {}
Local aArrayTmp := {}
Local aGrafLeft := {}
Local aGrafRight := {}
Local nQtdEndere := 0
	// Query para busca enderecos ocupados
	cQuery := "SELECT SBE.R_E_C_N_O_ NRECSBE, SBF.R_E_C_N_O_ NRECSBF, SDB.R_E_C_N_O_ NRECSDB"
	cQuery += "  FROM "+RetSqlName('SBE')+" SBE"
	cQuery += " INNER JOIN "+RetSqlName('DC8')+" DC8"
	cQuery += "    ON DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
	cQuery += "   AND DC8.DC8_CODEST = SBE.BE_ESTFIS"
	cQuery += "   AND DC8.DC8_TPESTR = '1'" // Somente Pulmão
	cQuery += "   AND DC8.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN "+RetSqlName('SBF')+" SBF"
	cQuery += "    ON SBF.BF_FILIAL = '"+xFilial('SBF')+"'"
	cQuery += "   AND SBF.BF_LOCAL = SBE.BE_LOCAL"
	cQuery += "   AND SBF.BF_LOCALIZ = SBE.BE_LOCALIZ"
	cQuery += "   AND SBF.BF_ESTFIS = SBE.BE_ESTFIS"
	cQuery += "   AND SBF.BF_PRODUTO BETWEEN '"+cMvProdDe+"' AND '"+cMvProdAte+"'"
	cQuery += "   AND SBF.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN "+RetSqlName('SDB')+" SDB"
	cQuery += "    ON SDB.DB_FILIAL = '"+xFilial('SDB')+"'"
	cQuery += "   AND SDB.DB_ESTORNO = ' '"
	cQuery += "   AND SDB.DB_ATUEST = 'N'"
	cQuery += "   AND SDB.DB_LOCAL = SBE.BE_LOCAL"
	cQuery += "   AND SDB.DB_ENDDES = SBE.BE_LOCALIZ"
	cQuery += "   AND SDB.DB_ESTDES = SBE.BE_ESTFIS"
	cQuery += "   AND SDB.DB_PRODUTO BETWEEN '"+cMvProdDe+"' AND '"+cMvProdAte+"'"
	cQuery += "   AND SDB.DB_STATUS IN ('-','2','3','4')"
	cQuery += "   AND SDB.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SBE.BE_FILIAL = '"+xFilial('SBE')+"'"
	cQuery += "   AND SBE.BE_LOCAL = '"+cMvLocal+"'"
	cQuery += "   AND SBE.BE_CODZON = '"+cMvZona+"'"
	cQuery += "   AND SBE.BE_LOCALIZ BETWEEN '"+cMvEndDe+"' AND '"+cMvEndAte+"'"
	cQuery += "   AND SBE.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY SBE.BE_LOCALIZ"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	
	aMainPar := {}
	aDadosGraf := {}
	aGrafLeft := Array(2)
	aGrafLeft[1] := 0
	aGrafLeft[2] := 0
	aGrafRight := Array(2)
	aGrafRight[1] := 0
	aGrafRight[2] := 0
	
	While (cAliasQry)->( !EOF() )
	
		nQtdEndere += 1 // Qtd endereços estrutura pulmão selecionados
		lCompartilha := .F.
		
		SBE->( DbGoTo((cAliasQry)->NRECSBE) )
		
		// Retorna o saldo no endereço
		nSaldoSBF := WmsSaldoSBF(SBE->BE_LOCAL,SBE->BE_LOCALIZ,Space(Len(SB1->B1_COD)),,,,.T.,.T.,.T.,.F.,'2')
	
		If nSaldoSBF > 0 // Qtd endereços Ocupados - Sit. Atual
			aGrafLeft[1] += 1
		EndIf
		If nSaldoSBF == 0
			aGrafLeft[2] += 1 // Qtd endereços livres - Sit. Atual
		EndIf
		
		If Empty( (cAliasQry)->NRECSBF ) .And. Empty( (cAliasQry)->NRECSDB )
			(cAliasQry)->( DbSkip() )
			Loop
		ElseIf !Empty( (cAliasQry)->NRECSBF ) 
			SBF->( DbGoTo((cAliasQry)->NRECSBF) )
			cProdArm	:= SBF->BF_PRODUTO
			cAliasQ	:= "SBF"
			nRecQ		:= (cAliasQry)->NRECSBF
			cLote		:= SBF->BF_LOTECTL
			cSubLote	:= SBF->BF_NUMLOTE
		ElseIf !Empty( (cAliasQry)->NRECSDB )
			SDB->( DbGoTo( (cAliasQry)->NRECSDB) )
			cProdArm	:= SDB->DB_PRODUTO
			cAliasQ	:= "SDB"
			nRecQ		:= (cAliasQry)->NRECSDB
			cLote		:= SDB->DB_LOTECTL
			cSubLote	:= SDB->DB_NUMLOTE
		EndIf
		
		// efetua a análise do produto que já estiver armazenado no endereço (2o passo abaixo). 	
		
		lCompartilha := (Posicione('DC3',2,xFilial('DC3')+cProdArm+SBE->BE_LOCAL+SBE->BE_ESTFIS,'DC3_TIPEND') == '4')
		
		// Retorna a Norma do endereço
		nQtdNorma := DLQtdNorma(cProdArm, SBE->BE_LOCAL, SBE->BE_ESTFIS)
		
		If nSaldoSBF > 0 .And. nSaldoSBF < nQtdNorma
			
			If aScan(aEndComp,{|x| x[2]+x[3] == SBE->BE_LOCAL+SBE->BE_LOCALIZ}) == 0
				aAdd(aEndComp,{cProdArm,SBE->BE_LOCAL,SBE->BE_LOCALIZ,nSaldoSBF,(nQtdNorma-nSaldoSBF),lCompartilha,cLote,cSubLote,SBE->BE_ESTFIS})
			EndIf
			
			lRet := .T.
			
		EndIf
		
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->( dbCloseArea() )
	RestArea(aAreaSBE)
	
	// aDadosGraf[n][1] = Qtd. Endereços Ocupados
	// aDadosGraf[n][2] = Qtd. Endereços Livres
	// aDadosGraf[n][3] = % Endereços Ocupados
	// aDadosGraf[n][4] = % Endereços Livre
	// aDadosGraf[1][5] = Qtd. Endereços
	
	aAdd(aDadosGraf, {aGrafLeft[1],aGrafLeft[2],0,0,nQtdEndere} )
	
	aGrafLeft[1] := ( aGrafLeft[1] / nQtdEndere ) * 100 // % endereços livres Situação Atual
	aGrafLeft[2] := ( aGrafLeft[2] / nQtdEndere ) * 100 // % endereços ocupados Situação Atual
	
	aDadosGraf[1][3] := aGrafLeft[1]
	aDadosGraf[1][4] := aGrafLeft[2]
	
	If Len(aEndComp) > 0
	
		aSort(aEndComp,,, {|x, y| x[1]+x[2]+x[3]+StrZero(x[4],6) < y[1]+y[2]+y[3]+StrZero(y[4],6)})
		aAux := aClone(aEndComp)
		
		For i := 1 to Len(aEndComp)
			
			nEspaco := aEndComp[i][5]
			For j := i + 1 to Len(aAux)
				
				// verifica se o endereco ja nao esta na lista(aMainPar) pra ser realocado
				If aScan(aMainPar,{|x| Str(x[9],3) == Str(j,3) }) == 0
					// verifica 1o se o produto eh igual ou se permite compartilhamento
					If aEndComp[i][1] == aAux[j][1] .Or. aEndComp[i][6]
						// verifica se a quantidade desse 2o endereço eh comportada pelo 1o endereço  
						If aAux[j][4] <= nEspaco 
	
							If aScan(aMainPar, { |x| x[6] == aAux[j][3] }) == 0 .And. aScan(aMainPar, { |x| x[6] == aEndComp[i][3] }) == 0 .And. ;
								aScan(aMainPar, { |x| x[8] == aAux[j][3] }) == 0 .And. aScan(aMainPar, { |x| x[8] == aEndComp[i][3] }) == 0
								
								aGrafRight[1] += 1 // Qtd endereços que serão desocupados - Pós-Desfragmentação
								
								nSaldoProd := WmsSaldoSBF(aAux[j][2],aAux[j][3],aAux[j][1],'',,,.T.,.T.,.T.,.F.,'1')
								
								// grava array com informacoes do que sera movimentado para desfragmentar o estoque
								aAdd(aMainPar,{aAux[j][1],aAux[j][2],/*aAux[j][4]*/nSaldoProd,aAux[j][7],aAux[j][8],aAux[j][3],aAux[j][9],aEndComp[i][3],j})
								                  // produto,armazem   ,qtd       ,lote      ,sublote   ,cEndeOri  ,cEstFOri  ,cEndDest
							                  
								aAdd(aArrayTmp,{IIF(lInvert,"  ",cMarca),;
										aAux[j][1], ; // Produto
	                  				Posicione("SB1",1,xFilial("SB1")+aAux[j][1],"B1_DESC"), ; // Descrição do Produto
	     	            	  			aAux[j][2], ; // Armazém
										nSaldoProd, ; // Quantidade
										aAux[j][7], ; // Lote
	    		              		aAux[j][8], ; // Sub-Lote
										aAux[j][3], ; // Endereço de Origem
										aEndComp[i][3]}) // Endereço de Destino
							
								nEspaco -= nSaldoProd // aAux[j][4]
								If nEspaco == 0
									Exit
								EndIf
							EndIf						     
						EndIf  
					EndIf
				EndIf	 							
			Next j
		Next i
		
		aAdd(aDadosGraf, {aDadosGraf[1][1] - aGrafRight[1],aDadosGraf[1][2] + aGrafRight[1],0,0,0} )
		
		aGrafRight[1] := (( aDadosGraf[2][1] ) / nQtdEndere ) * 100 // % endereços livres Pós-desfragmentação
		aGrafRight[2] := (( aDadosGraf[2][2] ) / nQtdEndere ) * 100 // % endereços ocupados Pós-desfragmentação
		
		aDadosGraf[2][3] := aGrafRight[1]
		aDadosGraf[2][4] := aGrafRight[2]
		
		cAliasTmp := MntCargDad(cAliasTmp,aArrayTmp,aCamposTmp)
		
	EndIf
	RestArea(aAreaSBE)
Return Nil
//-----------------------------------
/*{Protheus.doc}
Itens selecionados do MarkBrowse

@author Felipe Machado de Oliveira
@version P12
@Since	26/07/13
@obs Itens selecionados do MarkBrowse
*/
//-----------------------------------
Static Function GetSlcted(cMarca,lInvert)
Local aPar150Aux := {}
Local nPosi := 1
	(cAliasTmp)->( dbGoTop() )
	While (cAliasTmp)->( !EOF() )
		If IIF( lInvert, (cAliasTmp)->TMP_OK == "  " , (cAliasTmp)->TMP_OK == cMarca )
			nPosi := aScan(aMainPar,{|x| x[1]+x[2]+NToC(x[3],10)+x[4]+x[5]+x[6] == (cAliasTmp)->TMP_PRODUT+(cAliasTmp)->TMP_LOCAL+NToC((cAliasTmp)->TMP_QTD,10)+(cAliasTmp)->TMP_LOTE+(cAliasTmp)->TMP_SULOTE+(cAliasTmp)->TMP_ENDORI })
			
			If nPosi != 0
				aAdd(aPar150Aux, {aMainPar[nPosi][1],; // Produto
									aMainPar[nPosi][2],; // Armazém
									aMainPar[nPosi][3],; // Quantidade
									aMainPar[nPosi][4],; // Lote
									aMainPar[nPosi][5],; // Sub-Lote
									aMainPar[nPosi][6],; // Endereço Origem
									aMainPar[nPosi][7],; // Estrutura Fisica
									aMainPar[nPosi][8],; // Endereço Destino
									aMainPar[nPosi][9]}) // Endereço Compartilhado
			EndIf
		EndIf
		(cAliasTmp)->( dbSkip() )
	EndDo
	(cAliasTmp)->( dbGoTop() )
Return aPar150Aux
//-----------------------------------
/*{Protheus.doc}
Avalia os endereços se houve movimentação

@author Felipe Machado de Oliveira
@version P12
@Since	05/08/13
@obs Avalia os endereços se houve movimentação
*/
//-----------------------------------
Static Function CheckEnd(aPar150Aux)
Local lRet := .T.
Local i := 1
Local nSaldoSBF := 1
Local nQtdNorma := 1
Local nQtdDefrag := 1
	For i := 1 To Len(aPar150Aux)
		nQtdDefrag := aPar150Aux[i][3]
		
		// Retorna o saldo no endereço destino
		nSaldoSBF := WmsSaldoSBF(aPar150Aux[i][2],aPar150Aux[i][8],Space(Len(SB1->B1_COD)),,,,.T.,.T.,.T.,.F.,'2')
		
		// Retorna a Norma do endereço destino
		nQtdNorma := DLQtdNorma(aPar150Aux[i][1], aPar150Aux[i][2], aPar150Aux[i][7])
		
		// Se a quantidade a ser transferida for maior que o espaço livre do endereço destino
		// foi por que houve movimentação no endereço destino de tal forma a impedir a transferência
		If  nQtdDefrag > ( nQtdNorma - nSaldoSBF )
			lRet := .F.
		EndIf
		
		If lRet
			// Retorna o saldo no endereço origem
			nSaldoSBF := WmsSaldoSBF(aPar150Aux[i][2],aPar150Aux[i][6],/*Space(Len(SB1->B1_COD))*/aPar150Aux[i][1],'',,,.T.,.T.,.T.,.F.,'1')
			
			// Se a quantidade no endereço origem alterar for por que houve movimentação
			If nQtdDefrag != nSaldoSBF
				lRet := .F.
			EndIf
		EndIf
		If !lRet
			Exit
		EndIf
	Next i
Return lRet
//-----------------------------------
/*{Protheus.doc}
Processa a Desfragmentação dos Endereços

@author Evaldo Cevinscki Jr.
@version P12
@Since	26/07/13
@obs Processa a Desfragmentação dos Endereços selecionados
*/
//-----------------------------------
Static Function WMSDesfrag(aPar150Aux)
Local i := 1
Local aOrigem := {}
Local aDestino := {}
Local cDocIni := ""
Local cDocFim := ""
Local lRadioF := SuperGetMV("MV_RADIOF",.F.,"N") == "S"
Local cFuncDesfr := ""

Local aRotAuto   := {}
Local cWmsUMI    :=  ""
Local dDtUsa261  := CtoD("31/05/2023")
Local dDtValid   := CtoD('  /  /  ')
Local lRet := .T. 

// Variaveis visiveis na funcao a260Processa()
Private cCusMed := SuperGetMv("MV_CUSMED",.F.,"")
Private aRegSD3 := {}
Private nFCICalc := SuperGetMV("MV_FCICALC",.F.,0)
Private lMsErroAuto := .F.
	
	For i := 1 to Len(aPar150Aux)
		cProduto := aPar150Aux[i][1]
		cArmazem := aPar150Aux[i][2]
		nQtd     := aPar150Aux[i][3]
		cLoteCtl := aPar150Aux[i][4]
		cNumLote := aPar150Aux[i][5]
		cEndeOri := aPar150Aux[i][6]
		cEstFOri := aPar150Aux[i][7]
		cEndDest := aPar150Aux[i][8]
		cEstDest := aPar150Aux[i][7]

		If Rastro(cProduto)
			DbSelectArea('SB8')
			SB8->(DbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
			If SB8->(DbSeek(xFilial('SB8')+cProduto+cArmazem+cLoteCtl+If(Rastro(cProduto, 'S'),cNumLote,''), .F.))
				dDtValid := SB8->B8_DTVALID
			EndIf
		EndIf

		dbSelectArea("SB1")
		SB1->(dbSeek(xFilial("SB1")+cProduto))
		cWmsUMI := SB1->B1_UM
			
		lRet := .T.
	    cDocto := GetSX8Num('DCF','DCF_DOCTO')
	
		If Empty(cDocIni)
			cDocIni := cDocto
		EndIf
	  	
		// A funcao a260Processa criara as tabelas da movimentacao na seguinte sequencia:
		// SD3 - MOVMTOS INTERNOS
		// SDB - MOVTOS DE DISTRIBUICAO						
		// SDA - SALDO A DISTRIBUIR
		// DCF - ORDEM DE SERVICO
	    Begin Transaction
			If GetApoInfo("MATA261.PRX")[4] < dDtUsa261
				lRet := a260Processa(cProduto, ;						 // Codigo do Produto Origem    - Obrigatorio                                                                                           
			   			  		 	cArmazem, ;						 // Almox Origem                - Obrigatorio                                                                   
			   			  		 	nQtd, ;							 // Quantidade 1a UM            - Obrigatorio                                                                   
									cDocto, ;							 // Documento                   - Obrigatorio                                                                   
			   			  		 	dDataBase, ;						 // Data                        - Obrigatorio                                                                   
			   			  		 	ConvUm(cProduto, nQtd, 0, 2), ;  // Quantidade 2a UM                                                                   
			   			  		 	cNumLote, ;						 // Sub-Lote                    - Obrigatorio se usa Rastro "S"                                                                   
			   			  		 	cLoteCtl, ;						 // Lote                        - Obrigatorio se usa Rastro                                                                   
			   			  		 	Nil, ;								 // Validade                    - Obrigatorio se usa Rastro                                                                   
			   			  		 	Nil, ;								 // Numero de Serie                                                                   
			   			  		 	cEndeOri, ;						 // Localizacao Origem                                                                   
			   			  		 	cProduto, ;						 // Codigo do Produto Destino   - Obrigatorio                                                                   
			   			  		 	cArmazem, ;						 // Almox Destino               - Obrigatorio                                                                   
			   			  		 	cEndDest, ;					 	 // Endereco Destino            - Obrigatorio p/a Transferencia                                                                   
			   			  		 	.F., ;								 // Indica se movimento é estorno                                                                   
			   			  		 	0, ;								 // Numero do registro origem no SD3  - Obrigatorio se for Estorno                                                                   
			   			  		 	0, ;								 // Numero do registro destino no SD3 - Obrigatorio se for Estorno                                                                   
			   			  		 	'MATA260', ;						 // Indicacao do programa que originou os lancamentos                                                                   
			   			  		 	/*cEstFOri*/,;					 // Estrutura Fisica Padrao
			   			  		 	__cServico,;							 // Servico
			   			  		 	/*cTarefa*/,;						 // Tarefa   
			   			  		 	'',;								 // Atividade
			   			  		 	'',;								 // Anomalia
			   			  		 	/*cEstDest*/,;					 // Estrutura Fisica Destino
			   			  		 	/*cEndDest*/,;					 // Endereco Destino
			   			  		 	'',;								 // Hora Inicio
			   			  		 	IIF( lRadioF,"N","S" ),;			 // Atualiza Estoque
			   			  			'',;								 // Numero da Carga
			   			  		 	'',;								 // Numero do Unitizador
			   			  		 	/*aParam150[28]*/,;				 // Ordem da Tarefa
			   			  		 	/*'ZZ'*/,;							 // Ordem da Atividade
			   			  		 	'',;								 // Recurso Humano                                                                   
			   			  		 	'')									 // Recurso Fisico	                                                                   
		
				If lRet .And. __lSX8
					ConfirmSX8()
				EndIf
			Else
				//Executa o MATA261 via execauto devido a descontinuação da rotina mata260
				aAdd(aRotAuto, {cDocto, dDataBase})
				aAdd(aRotAuto,{})
				aAdd(aRotAuto[02],{"D3_COD"    , cProduto, Nil}) // [01] Produto origem
				aAdd(aRotAuto[02],{"D3_DESCRI" , cProduto, Nil}) // [02] Descrição origem  //ROSE VER o que colocar
				aAdd(aRotAuto[02],{"D3_UM"     , cWmsUMI, Nil}) // [03] Unidade de medica origem
				aAdd(aRotAuto[02],{"D3_LOCAL"  , cArmazem, Nil}) // [04] Armazém origem
				aAdd(aRotAuto[02],{"D3_LOCALIZ", cEndeOri, Nil}) // [05] Endereço origem
				aAdd(aRotAuto[02],{"D3_COD"    , cProduto, Nil}) // [06] Produto destino
				aAdd(aRotAuto[02],{"D3_DESCRI" , cProduto, Nil}) // [07] Descrição origem
				aAdd(aRotAuto[02],{"D3_UM"     , cWmsUMI, Nil}) // [08] Unidade de medida destino
				aAdd(aRotAuto[02],{"D3_LOCAL"  , cArmazem, Nil}) // [09] Armazém destino
				aAdd(aRotAuto[02],{"D3_LOCALIZ", cEndDest, Nil}) // [10] Endereço destino DH1->DH1_LOCALI
				aAdd(aRotAuto[02],{"D3_NUMSERI", "", Nil}) // [11] Numero de série
				aAdd(aRotAuto[02],{"D3_LOTECTL", cLoteCtl, Nil}) // [12] Lote
				aAdd(aRotAuto[02],{"D3_NUMLOTE", cNumLote, Nil}) // [13] Sub-Lote
				aAdd(aRotAuto[02],{"D3_DTVALID", dDtValid, Nil}) // [14] Data de validade
				aAdd(aRotAuto[02],{"D3_POTENCI", CriaVar("D3_POTENCI"), Nil}) // [15]
				aAdd(aRotAuto[02],{"D3_QUANT"  , nQtd, Nil}) // [16] Quantidade
				aAdd(aRotAuto[02],{"D3_QTSEGUM", ConvUm(cProduto, nQtd, 0, 2), Nil}) // [17]
				aAdd(aRotAuto[02],{"D3_ESTORNO", .F., Nil}) // [18]
				aAdd(aRotAuto[02],{"D3_NUMSEQ" , "", Nil}) // [19] Numero sequencial
				aAdd(aRotAuto[02],{"D3_LOTECTL", cLoteCtl, Nil}) // [20] Lote destino
				aAdd(aRotAuto[02],{"D3_DTVALID", dDtValid, Nil}) // [21] Data de validade destino
				aAdd(aRotAuto[02],{"D3_SERVIC" , __cServico, Nil}) // [22] Servico
				aAdd(aRotAuto[02],{"D3_ITEMGRD", CriaVar("D3_ITEMGRD"), Nil}) // [23]

				MSExecAuto({|x,y,Z| MATA261(x,y,Z)}, aRotAuto, 3) //Estorno ou Inclusão
				If lMsErroAuto
					MostraErro()
					lRet := .F.
				EndIf
			ENDIF	

			If lRet .AND. !Empty(aLibSDB) // So entrara se o servico estiver com execucao automatica DC5_TPEXEC == '2'
				WmsExeDCF('2')
			EndIf

		End Transaction
	
	Next i
	cDocFim := cDocto
	
	// chama relatorio das movimentacoes quando nao utiliza RF MV_RADIOF = 'N'
	If !lRadioF .And. !Empty(aLibSDB)
		If MsgYesNo(STR0016,STR0017) // Deseja imprimir o relatório de movimentações? // Atenção
			WmsR310(.F.,{__cServico,__cServico,__cTarefa,__cTarefa,cDocIni,cDocFim,' ','ZZZZZZ',5,1})
		EndIf	
	EndIf
Return Nil
//-----------------------------------
/*{Protheus.doc}
Seleciona a linha da grid

@author Felipe Machado de Oliveira
@version P12
@Since	30/07/13
@obs Seleciona a linha da grid
*/
//-----------------------------------
Function WMSA430SLN()
	oMrkBrw:MarkRec()
Return .T.
//-----------------------------------
/*{Protheus.doc}
AfterMark

@author Felipe Machado de Oliveira
@version P12
@Since	29/07/13
@obs AfterMark
*/
//-----------------------------------
Static Function AfterMark()
Local IsMark := oMrkBrw:IsMark(oMrkBrw:Mark())
	// Adiciona ou diminui 1 ao gráfico da direita quando marcado o item do MarkBrowse
	If !IsMark
		aDadosGraf[2][1] += 1
		aDadosGraf[2][2] -= 1
	Else
		aDadosGraf[2][1] -= 1
		aDadosGraf[2][2] += 1
	EndIf
	
	aDadosGraf[2][3] := ( aDadosGraf[2][1] / aDadosGraf[1][5] ) * 100
	aDadosGraf[2][4] := ( aDadosGraf[2][2] / aDadosGraf[1][5] ) * 100
	
	// Atualiza as quantidades das colunas
	oGrafRight:Reset()
	oGrafRight:AddSerie( "% "+STR0007, NoRound(aDadosGraf[2][3],2) ) // Endereços Ocupados
	oGrafRight:AddSerie( "% "+STR0008, NoRound(aDadosGraf[2][4],2) ) // Endereços Livres
	oGrafRight:Build()
Return .T.
//-----------------------------------
/*{Protheus.doc}
AllMark

@author Felipe Machado de Oliveira
@version P12
@Since	29/07/13
@obs AllMark
*/
//-----------------------------------
Static Function AllMark()
Local cMarca := oMrkBrw:Mark()
Local lInvert
Local aEndSelec := {}
Local nQtdSel := 1
	oMrkBrw:AllMark()
	lInvert   := oMrkBrw:IsInvert()
	aEndSelec := GetSlcted(cMarca,lInvert)
	nQtdSel   := Len(aEndSelec)
	// Atualiza as quantidades das colunas do gráfico da direita
	aDadosGraf[2][1] := aDadosGraf[1][1]
	aDadosGraf[2][2] := aDadosGraf[1][2]
	aDadosGraf[2][1] -= nQtdSel
	aDadosGraf[2][2] += nQtdSel
	
	aDadosGraf[2][3] := ( aDadosGraf[2][1] / aDadosGraf[1][5] ) * 100
	aDadosGraf[2][4] := ( aDadosGraf[2][2] / aDadosGraf[1][5] ) * 100
	
	oGrafRight:Reset()
	oGrafRight:AddSerie( "% "+STR0007, NoRound(aDadosGraf[2][3],2) ) // Endereços Ocupados
	oGrafRight:AddSerie( "% "+STR0008, NoRound(aDadosGraf[2][4],2) ) // Endereços Livres
	oGrafRight:Build()
Return .T.
//-----------------------------------
/*{Protheus.doc}
Atualização dos graficos

@author Felipe Machado de Oliveira
@version P12
@Since	29/07/13
@obs Atualização dos graficos
*/
//-----------------------------------
Static Function AtuGrafs()
	oGrafLeft:Reset()
	oGrafRight:Reset()
	
	oGrafLeft:AddSerie( "% "+STR0007, NoRound(aDadosGraf[1][3],2) ) // Endereços Ocupados
	oGrafLeft:AddSerie( "% "+STR0008, NoRound(aDadosGraf[1][4],2) ) // Endereços Livres
	
	oGrafRight:AddSerie( "% "+STR0007, NoRound(aDadosGraf[2][3],2) ) // Endereços Ocupados
	oGrafRight:AddSerie( "% "+STR0008, NoRound(aDadosGraf[2][4],2) ) // Endereços Livres
	
	oGrafLeft:Build()
	oGrafRight:Build()
Return Nil
