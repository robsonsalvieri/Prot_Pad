#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'WMSA360.CH'
#DEFINE CRLF CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ WMSA361 ³ Autor ³ Alex Egydio              ³Data³17.04.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Conferencia dos Mapas de Separação Fracionado e Embalado   ³±±
±±³          ³ Esta conferencia eh efetuada no endereco de servico        ³±±
±±³          ³ pre-determinado pela rotina WMSA370.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function WmsA361()

Static lWmsE006 := ExistBlock('WMSE006')   // Ponto de entrada para emissao de etiquetas
Local aAreaAnt := GetArea()
Local aAreaD12	:= D12->(GetArea())
Local aEtiqueta:= {}
Local aOcorr	:= {}
// Vetor com dados informados pelo usuario
Local aTotPrdUSU:= {}
// Vetor com dados do sistema
Local aTotPrdSYS:= {}
// Vetor utilizado pelo listbox
Local aProdutos := {}
// Controle de dimensoes de objetos
Local aSize		:= {}
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
// MsDialog
Local aButtons	:= {}
// ListBox
Local oMapa
Local oProd
Local oLBox
Local oNomeEmb
Local oDescPro
// Digitacao
Local cMapSep  := Space(Len(D12->D12_MAPSEP))
Local cMapNext := ""
Local cRecCon  := Space(Len(D12->D12_RECHUM))
Local cNomeCon := ''
Local cRecEmb  := Space(Len(D12->D12_RECHUM))
Local cNomeEmb := ''
Local cRecSep  := Space(Len(D12->D12_RECHUM))
Local cNomeSep := ''
Local cProduto := Space(Len(SB1->B1_COD))
Local cDescPro := Space(Len(SB1->B1_DESC))
Local cNext1   := ''
Local cNext2   := ''
Local cNext3   := ''
Local lDigita  := (SuperGetMV('MV_DLCOLET',.F.,'N')=='N') // Se sim leitura atraves codigo de barras, se nao digitacao
Local nErro    := 0
Local nQtdInf  := 0
Local nCntFor  := 0

Private lFirst    := .T. //	Alterado para execucao do VALID no campo cMapSep
Private lSecond   := .F. //	Criado para execucao do VALID no campo cMapSep
Private l361TOk   := .F.
Private cCadastro := STR0001 //	Conferência Mapa de Separação
Private cMapaAtual:= ""
Private bLine     := {||.T.}
Private oDlg

	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		Return WMSA360()
	EndIf
	
	// Botao para emissao de etiqueta
	If lWmsE006
	   Aadd(aButtons, {STR0002,{||WmsA361Eti(aEtiqueta)},STR0007}) // RELATORIO // Etiqueta
	EndIf
	
	AAdd(aObjects,{100,085,.T.,.F.})
	AAdd(aObjects,{100,190,.T.,.F.})
	aSize   := MsAdvSize()
	aInfo   := {aSize[1],aSize[2],aSize[3],aSize[4],2,2}
	aPosObj := MsObjSize(aInfo, aObjects)
	
	// Cria linha vazia
	aProdutos  := {}
	AAdd(aProdutos,{Space(Len(D12->D12_IDUNIT)),Space(Len(D12->D12_PRODUT)),Space(Len(SB1->B1_UM)),Space(Len(SB1->B1_DESC)),Space(Len(SB1->B1_CODBAR)),Space(Len(D12->D12_CARGA))})
	bLine := { || {aProdutos[oLBox:nAT,1],aProdutos[oLBox:nAT,2],aProdutos[oLBox:nAT,3],aProdutos[oLBox:nAT,4],aProdutos[oLBox:nAT,5],aProdutos[oLBox:nAT,6]}}
	DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5] TITLE OemToAnsi(cCadastro) OF oMainWnd PIXEL
	//STYLE nOr( DS_MODALFRAME, WS_POPUP )
	@ aPosObj[1,1], aPosObj[1,2] TO aPosObj[1,3], aPosObj[1,4] LABEL OemToAnsi(cCadastro) OF oDlg PIXEL
	// Mapa de Separacao
	@ aPosObj[1,1]+013,aPosObj[1,2]+009 SAY OemtoAnsi(STR0003) SIZE 28,13  OF oDlg PIXEL // Mapa
	@ aPosObj[1,1]+010,aPosObj[1,2]+043 MSGET oMapa VAR cMapSep PICTURE PesqPict('D12','D12_MAPSEP') VALID WmsA361D12(oLBox,cMapSep,@cRecSep,@cNomeSep,@cRecCon,@cNomeCon,aTotPrdSYS,aTotPrdUSU,aProdutos) WHEN .T. SIZE 30,09  OF oDlg PIXEL
	@ aPosObj[1,1]+010,aPosObj[1,2]+043 MSGET cMapNext PICTURE PesqPict('D12','D12_MAPSEP') WHEN lFirst SIZE 01,01 OF oDlg PIXEL // Campo adcionado para execucao do VALID no campo cMapSep
	// Conferente
	@ aPosObj[1,1]+028,aPosObj[1,2]+009 SAY OemtoAnsi(STR0004) SIZE 28,13  OF oDlg PIXEL // Conferente
	@ aPosObj[1,1]+026,aPosObj[1,2]+043 MSGET cRecCon PICTURE PesqPict('D12','D12_RECHUM') WHEN .F. SIZE 30,09 OF oDlg PIXEL
	@ aPosObj[1,1]+026,aPosObj[1,2]+083 MSGET cNomeCon WHEN .F. SIZE 150,09 OF oDlg PIXEL
	// Separador
	@ aPosObj[1,1]+028,aPosObj[1,2]+238 SAY OemtoAnsi(STR0005) SIZE 28,13 OF oDlg PIXEL // Separador
	@ aPosObj[1,1]+026,aPosObj[1,2]+272 MSGET cRecSep PICTURE PesqPict('D12','D12_RECHUM') WHEN .F. SIZE 30,09  OF oDlg PIXEL
	@ aPosObj[1,1]+026,aPosObj[1,2]+312 MSGET cNomeSep WHEN .F. SIZE 150,09 OF oDlg PIXEL
	// Embalador
	@ aPosObj[1,1]+044,aPosObj[1,2]+009 SAY OemtoAnsi(STR0008)  SIZE 28,13  OF oDlg PIXEL  // Embalador
	@ aPosObj[1,1]+042,aPosObj[1,2]+043 MSGET cRecEmb F3 'DCD' PICTURE PesqPict('D12','D12_RECHUM') VALID WmsA361Rec(cRecEmb,@cNomeEmb,@oNomeEmb) WHEN lFirst SIZE 30,09  OF oDlg PIXEL
	@ aPosObj[1,1]+042,aPosObj[1,2]+083 MSGET oNomeEmb VAR cNomeEmb WHEN .F. SIZE 150,09 OF oDlg PIXEL
	@ aPosObj[1,1]+042,aPosObj[1,2]+083 MSGET cNext1 PICTURE '@!' SIZE 01,01 OF oDlg PIXEL
	// Produto
	@ aPosObj[1,1]+058,aPosObj[1,2]+009 SAY OemtoAnsi(STR0006) SIZE 28,13 OF oDlg PIXEL // Produto
	@ aPosObj[1,1]+068,aPosObj[1,2]+009 MSGET oProd VAR cProduto F3 'SB1' PICTURE PesqPict('D12','D12_PRODUT') VALID Wmsa361VlPro(@cProduto,@cDescPro,@nQtdInf,aTotPrdSYS,aProdutos,@oDescPro) WHEN .T. SIZE  68,09 OF oDlg PIXEL
	@ aPosObj[1,1]+068,aPosObj[1,2]+083 MSGET oDescPro VAR cDescPro WHEN .F. SIZE 150,09 OF oDlg PIXEL
	@ aPosObj[1,1]+068,aPosObj[1,2]+083 MSGET cNext2 PICTURE '@!' SIZE 01,01 OF oDlg PIXEL
	// Quantidade
	@ aPosObj[1,1]+058,aPosObj[1,2]+288 SAY OemToAnsi(STR0009) SIZE 28,13 OF oDlg PIXEL // Quantidade
	@ aPosObj[1,1]+068,aPosObj[1,2]+288 MSGET nQtdInf PICTURE PesqPictQt('D12_QTDMOV',12) VALID Wmsa361TOk(oMapa,oProd,oLBox,@cProduto,@cDescPro,@nQtdInf,@nErro,@cRecCon,@cNomeCon,@cRecEmb,@cNomeEmb,@cRecSep,@cNomeSep,@cMapSep,aEtiqueta,aTotPrdUSU,aTotPrdSYS,aProdutos) WHEN .T. SIZE 68,09 OF oDlg PIXEL
	@ aPosObj[1,1]+068,aPosObj[1,2]+288 MSGET cNext3 PICTURE '@!' SIZE 01,01 OF oDlg PIXEL
	// Itens
	@ aPosObj[2,1], aPosObj[2,2] LISTBOX oLBox VAR cVar FIELDS HEADER RetTitle('D12_IDUNIT'), RetTitle('D12_PRODUT'), RetTitle('B1_UM'), RetTitle('B1_DESC'), RetTitle('B1_CODBAR'), RetTitle('D12_CARGA');
	SIZE aPosObj[2,4]-aPosObj[2,2], aPosObj[2,3]-aPosObj[2,1] WHEN .T. OF oDlg PIXEL
	oLBox:LNOHSCROLL := .T.
	oLBox:LHSCROLL   := .F.
	oLBox:SetArray(aProdutos)
	oLBox:bLine := bLine
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,aButtons) VALID .F.
	If	!l361TOk .And. !Empty(aTotPrdSYS)
		aTotPrdUSU:= {}
		aOcorr := {}
		For nCntFor := 1 To Len(aTotPrdSYS)
			// Erro na quantidade digitada
			AAdd(aOcorr,{aTotPrdSYS[nCntFor,1],aTotPrdSYS[nCntFor,2],aTotPrdSYS[nCntFor,1],0})
			If	aScan(aTotPrdUSU,{|x|x[1]==aTotPrdSYS[nCntFor,1]}) == 0
				AAdd(aTotPrdUSU,{aTotPrdSYS[nCntFor,1],0})
			EndIf
		Next
	   MsgRun(STR0016,STR0017,{||WmsA361Proc(aOcorr,1,cRecCon,cNomeCon,cRecEmb,cRecSep,cNomeSep,cMapSep,,aTotPrdUSU,aTotPrdSYS)}) // Finalizando a Conferencia. // Aguarde...
	EndIf
	RestArea(aAreaD12)
	RestArea(aAreaAnt)
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Wmsa361D12³ Autor ³Flavio Luiz Vicco        ³Data³17.04.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Obtem dados do mapa de separacao e preenche vetores com a  ³±±
±±³          ³ quantidade do sistema.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto listbox                                     ³±±
±±³          ³ ExpC1 - Mapa de separacao                                  ³±±
±±³          ³ ExpC2 - Codigo do separador de produtos                    ³±±
±±³          ³ ExpC3 - Nome   do separador de produtos                    ³±±
±±³          ³ ExpA1 - Vetor com qtde de produtos obtida pelo sistema     ³±±
±±³          ³ ExpA2 - Vetor com qtde de produtos informada pelo usuario  ³±±
±±³          ³ ExpA3 - Vetor utilizado no listbox                         ³±±
±±³          ³ ExpC4 - Conferente pre-determinado pelo WMSA370            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Wmsa361D12(oObj,cMapSep,cRecSep,cNomeSep,cRecCon,cNomeCon,aTotPrdSYS,aTotPrdUSU,aProdutos)
Local aAreaAnt   := GetArea()
Local nPos       := 0
Local lRet       := .F.
Local cVzRecHum  := Space(Len(D12->D12_RECHUM))
Local cVzEndSer  := Space(Len(D12->D12_ENDCON))
Local aTam       := {}
Local cAliasNew  := ""
Local cQuery     := ""
Local aAtiv      := {}
Local nSeek      := 0
Local oMovimento := WMSDTCMovimentosServicoArmazem():New()

	If Empty(cMapSep)
		WmsMessage(STR0042,,1) //Informe o código do mapa de separação!
		Return(.F.)
	EndIf
	If cMapaAtual == cMapSep
		Return (.T.)
	EndIf
	// Nao abre o mapa para conferencia se houver registros com status igual a 2-Com Problema ou 3-Em Execucao
	If !WmsA361Chk(cMapSep)
		Return(.F.)
	EndIf

	aProdutos  := {}
	aTotPrdSYS := {}
	aTotPrdUSU := {}
	
	cAliasNew := GetNextAlias()
	cQuery := " SELECT D12.D12_FILIAL,D12.D12_MAPSEP,D12.D12_LOCORI,D12.D12_PRODUT,D12.D12_SERVIC,"
	cQuery +=         "D12.D12_CARGA,D12.D12_ENDDES,D12.D12_IDUNIT,D12.D12_QTDMOV,D12.D12_LOTECT,D12.D12_RECHUM,D12.D12_RECCON,"
	cQuery +=         "D12.D12_IDMOV,D12.R_E_C_N_O_ D12RECNO"
	cQuery +=  " FROM " +RetSqlName('D12')+" D12"
	cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	cQuery +=   " AND D12.D12_MAPSEP = '"+cMapSep+"'"
	cQuery +=   " AND D12.D12_STATUS = '4'"
	cQuery +=   " AND D12.D12_RECHUM <> '"+cVzRecHum+"'"
	cQuery +=   " AND D12.D12_ENDCON <> '"+cVzEndSer+"'"
	cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D12.D12_FILIAL,D12.D12_MAPSEP,D12.D12_LOCORI,D12.D12_PRODUT,D12.D12_SERVIC,D12.D12_CARGA,D12.D12_ENDDES,D12.D12_IDUNIT"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	
	aTam := TamSx3("D12_QTDMOV")
	TCSetField(cAliasNew,"D12_QTDMOV","N",aTam[1],aTam[2])
	
	If (cAliasNew)->(!Eof())
		If Empty(cRecSep)
			cRecSep := (cAliasNew)->D12_RECHUM
			DCD->(DbSetOrder(1))
			DCD->(MsSeek(xFilial('DCD')+cRecSep))
			cNomeSep := DCD->DCD_NOMFUN
		EndIf
		If Empty(cRecCon)
			cRecCon := (cAliasNew)->D12_RECCON
			DCD->(DbSetOrder(1))
			DCD->(MsSeek(xFilial('DCD')+cRecCon))
			cNomeCon := DCD->DCD_NOMFUN
		EndIf
	EndIf
	
	While (cAliasNew)->(!Eof())
		//------------------------------------------
		// Seta DB_STATUS para Servico em Execucao
		oMovimento:GoToD12((cAliasNew)->D12RECNO)
		If oMovimento:LockD12()
			
			If oMovimento:GetStatus() == '4'
				oMovimento:SetStatus('3') //Interrompida
				oMovimento:UpdateD12()
				// Inclui produto no ListBox
				If (nPos:=aScan(aProdutos, {|x|x[2]==(cAliasNew)->D12_PRODUT})) == 0
					AAdd(aProdutos, {(cAliasNew)->D12_IDUNIT, (cAliasNew)->D12_PRODUT, oMovimento:oMovPrdLot:GetUM(), oMovimento:oMovPrdLot:GetDesc(), oMovimento:oMovPrdLot:GetCodBar(),(cAliasNew)->D12_CARGA})
				EndIf
				// Inclui produto no array aTotPrdSY
				nSeek := AScan(aAtiv,{|x| x == (cAliasNew)->D12_IDMOV}) // Tratamento para não somar quantidade de atividades de um mesmo movimento
				If nSeek <= 0
					AAdd(aAtiv, (cAliasNew)->D12_IDMOV)
					If (nPos:=aScan(aTotPrdSYS, {|x| x[1]==(cAliasNew)->D12_PRODUT})) == 0
						AAdd(aTotPrdSYS, {(cAliasNew)->D12_PRODUT, (cAliasNew)->D12_QTDMOV, (cAliasNew)->D12_ENDDES, {} })
						nPos := Len(aTotPrdSYS)
					Else
						// Soma a quantidade
						aTotPrdSYS[nPos, 2] += (cAliasNew)->D12_QTDMOV
					EndIf
				EndIf
				// Inclui nr.do registro do D12
				AAdd(aTotPrdSYS[nPos,4],(cAliasNew)->D12RECNO)
			EndIf
			
			oMovimento:UnLockD12()
		EndIf
		(cAliasNew)->(DbSkip())
	EndDo
	(cAliasNew)->(DbCloseArea())
	If lRet
		oObj:SetArray(aProdutos)
		oObj:bLine := bLine
		oObj:Refresh()
		cMapaAtual := cMapSep
	Else
		Aviso('WMSA36104',STR0014+CRLF+;
							STR0015+CRLF+;
							STR0022+CRLF+;
							STR0023+CRLF+;
							STR0041+CRLF+;
							STR0024,{'OK'})      // Servico de conferencia nao encontrado! // Certifique-se que: // - O mapa de separacao foi gerado; // - O separador foi atribuido ao mapa consolidado; // - O endereco de servico foi atribuido ao mapa consolidado; // - O status do servico de conferencia esteja "Apto a Executar"
		aProdutos:= {}
		AAdd(aProdutos,{Space(Len(D12->D12_IDUNIT)),Space(Len(D12->D12_PRODUT)),Space(Len(SB1->B1_UM)),Space(Len(SB1->B1_DESC)),Space(Len(SB1->B1_CODBAR)),Space(Len(D12->D12_CARGA))})	
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Wmsa361Rec³ Autor ³Flavio Luiz Vicco        ³Data³17.04.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o conferente, separador e embalador                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Acao executada pela funcao                         ³±±
±±³          ³         1 = Validacoes para o conferente                   ³±±
±±³          ³ ExpC2 - Codigo do recurso humano                           ³±±
±±³          ³ ExpC3 - Nome do recurso humano                             ³±±
±±³          ³ ExpL1 - .T. = Desabilita os gets                           ³±±
±±³          ³ ExpC4 - Conferente pre-determinado pelo WMSA370            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function WmsA361Rec(cRecHum,cNome,oNomeEmb)
Local lRet := .T.

	cNome := Space(Len(DCD->DCD_NOMFUN))
	If Empty(cRecHum)
	   WmsMessage(STR0043,,1) // Informe um embalador!
	   lRet := .F.
	EndIf
	If lRet
	   DCD->(DbSetOrder(1))
	   If DCD->(MsSeek(xFilial('DCD')+cRecHum))
	      cNome := DCD->DCD_NOMFUN
	      oNomeEmb:CtrlRefresh()
	      oDlg:Refresh()
	   Else
	      WmsMessage(STR0044+AllTrim(cRecHum)+STR0045,,1) // Recurso '######' não cadastrado! (DCD)
	      lRet :=.F.
	   EndIf
	EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Wmsa361VlPro³ Autor ³Flavio Luiz Vicco      ³Data³13.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o codigo do produto                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo do produto                                  ³±±
±±³          ³ ExpC2 - Descricao do produto                               ³±±
±±³          ³ ExpN1 - Quantidade informada                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Wmsa361VlPro(cProduto,cDescPro,nQtdInf,aTotPrdSYS,aProdutos,oDescPro)
Local aProduto := {}
Local cTipId   := ''
Local lRet     := .F.
Local lDigita  := (SuperGetMV('MV_DLCOLET',.F.,'N')=='N') // Se sim leitura atraves codigo de barras, se nao digitacao

	If !Empty(cProduto)
	   If !lDigita
	      cTipId:=CBRetTipo(cProduto)
	      If cTipId $ 'EAN8OU13-EAN14-EAN128'
	         aProduto := CBRetEtiEAN(cProduto)
	      Else
	         aProduto := CBRetEti(cProduto,'01')
	      EndIf
	      If Empty(aProduto)
	         Aviso('WMSA36105',STR0037,{'OK'}) // Etiqueta invalida!
	         lRet := .F.
	      Else
	         cProduto := aProduto[1]
	         lRet := .T.
	      EndIf
	   EndIf
	   DbSelectArea('SB1')
	   SB1->(DbSetOrder(1))
	   If (lRet:=SB1->(MSSeek(xFilial('SB1')+cProduto)))
	      cDescPro := SB1->B1_DESC
	   Else
	      Aviso('WMSA36106',STR0038+AllTrim(cProduto)+STR0039,{'OK'}) // O Produto "###" nao esta cadastrado. ATENCAO: Quando leitura de codigo de barras, deixe o parametro MV_DLCOLET igual a 'S'
	   EndIf
	   If !lRet
	      cProduto:=Space(Len(cProduto))
	      cDescPro:=Space(Len(cDescPro))
	   Else
	      If aScan(aTotPrdSYS,{|x|x[1]==cProduto}) == 0
	         WmsMessage(STR0048+AllTrim(cProduto)+STR0049,,1) //O produto '######' não pertence ao mapa de separação!
	         lRet := .F.
	      EndIf
	   EndIf
	   nQtdInf := 0
	Else
	   // Conferencia finalizada e o conferente ira abrir um novo mapa
	   If Len(aProdutos)>0 .And. Empty(aProdutos[1,2])
	      lRet := .T.
	   EndIf
	EndIf
	If lRet
	   oDescPro:CtrlRefresh()
	   oDlg:Refresh()
	EndIf
Return lRet
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WmsA361TOk| Autor ³ Alex Egydio              ³Data³21.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao geral do conferencia                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 - Objeto listbox                                       ³±±
±±³          ³ ExpC1 - Codigo do produto                                    ³±±
±±³          ³ ExpC2 - Descricao do produto                                 ³±±
±±³          ³ ExpN1 - Quantidade do produto                                ³±±
±±³          ³ ExpN2 - Quantidade de erros                                  ³±±
±±³          ³ ExpC3 - Codigo do conferente                                 ³±±
±±³          ³ ExpC4 - Nome do conferente                                   ³±±
±±³          ³ ExpC5 - Codigo do embalador                                  ³±±
±±³          ³ ExpC6 - Codigo do separador                                  ³±±
±±³          ³ ExpC7 - Nome do separador                                    ³±±
±±³          ³ ExpC8 - Mapa de separacao                                    ³±±
±±³          ³ ExpA1 - Vetor utilizado na impressao das etiquetas           ³±±
±±³          ³ ExpA2 - Vetor com a contagem do usuario                      ³±±
±±³          ³ ExpA3 - Vetor com a contagem do sistema                      ³±±
±±³          ³ ExpA4 - Vetor utilizado no listbox                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function Wmsa361TOk(oMapa,oProd,oLBox,cProduto,cDescPro,nQtdInf,nErro,cRecCon,cNomeCon,cRecEmb,cNomeEmb,cRecSep,cNomeSep,cMapSep,aEtiqueta,aTotPrdUSU,aTotPrdSYS,aProdutos)
// Vetor de ocorrencias
Local aOcorr   := {}
Local lRet     := .F.
Local lDigita  := (SuperGetMV('MV_DLCOLET',.F.,'N')=='N') // Se sim leitura atraves codigo de barras, se nao digitacao
Local n1Cnt    := 0
Local nMaxConta := Val(SuperGetMV('MV_MAXCONT',.F.,'3'))
Local nAcao    := 0
Local nPos     := 0
Local nPosUSU  := 0
Local nPosSYS  := 0
Local nTotUSU  := 0
Local nTotSYS  := 0

	If Empty(cProduto)
	   Return (.T.)
	EndIf
	
	If !Empty(cProduto) .And. !Empty(nQtdInf) .And. !Empty(aProdutos[1,2])
	   l361TOk := .T.
	   // Adiciona o Produto e a Quantidade informada pelo usuario no vetor aTotPrdUSU
	   If (nPosUSU:=aScan(aTotPrdUSU,{|x|x[1]==cProduto})) == 0
	      AAdd(aTotPrdUSU,{cProduto,nQtdInf})
	      nPosUSU := Len(aTotPrdUSU)
	   Else
	      // Soma a quantidade
	      aTotPrdUSU[nPosUSU,2] += nQtdInf
	   EndIf
	   nTotUSU += aTotPrdUSU[nPosUSU,2]
	
	   nPosSYS:=aScan(aTotPrdSYS,{|x|x[1]==cProduto})
	   nTotSYS := aTotPrdSYS[nPosSYS,2]
	   If nTotSYS > 0 .And. (nPos:=aScan(aProdutos,{|x|x[2]==cProduto}))>0
	      If nTotSYS == nTotUSU
	         aDel(aProdutos,nPos)
	         aSize(aProdutos,Len(aProdutos)-1)
	         If Empty(aProdutos)
	            aAdd(aProdutos,{Space(Len(D12->D12_IDUNIT)),Space(Len(D12->D12_PRODUT)),Space(Len(SB1->B1_UM)),Space(Len(SB1->B1_DESC)),Space(Len(SB1->B1_CODBAR)),Space(Len(D12->D12_CARGA))})
	            lFirst := .F.
	         EndIf
	         oLBox:SetArray(aProdutos)
	         oLBox:bLine := bLine
	         oLBox:Refresh()
	      Else
	         // Erro na quantidade digitada
	         AAdd(aOcorr,{aTotPrdSYS[nPosSYS,1],aTotPrdSYS[nPosSYS,2],aTotPrdUSU[nPosUSU,1],aTotPrdUSU[nPosUSU,2]})
	         nErro++
	         l361TOk := .F.
	      EndIf
	   EndIf
	
	   If nTotSYS > 0 .And. Len(aOcorr)==0
	      MsgRun(STR0016,STR0017,{||WmsA361Proc(,,cRecCon,,cRecEmb,,,,aEtiqueta,aTotPrdUSU,aTotPrdSYS)}) // Finalizando a Conferencia. // Aguarde...
	   ElseIf nErro >= nMaxConta .Or. (nAcao:=Aviso('WMSA36101',STR0010+AllTrim(Str(nErro))+STR0011, {STR0012,STR0013})) == 2 // Foram encontradas Divergencias na "###" Conferencia.###"Confere Novamente"###"Registra Ocorrencias
	      MsgRun(STR0016,STR0017,{||WmsA361Proc(aOcorr,nErro,cRecCon,cNomeCon,cRecEmb,cRecSep,cNomeSep,cMapSep,,aTotPrdUSU,aTotPrdSYS,cProduto)}) // Finalizando a Conferencia. // Aguarde...
	      If nPos > 0
	         aDel(aProdutos,nPos)
	         aSize(aProdutos,Len(aProdutos)-1)
	         If Empty(aProdutos)
	            aAdd(aProdutos,{Space(Len(D12->D12_IDUNIT)),Space(Len(D12->D12_PRODUT)),Space(Len(SB1->B1_UM)),Space(Len(SB1->B1_DESC)),Space(Len(SB1->B1_CODBAR)),Space(Len(D12->D12_CARGA))})
	            lFirst := .F.
	         EndIf
	         oLBox:SetArray(aProdutos)
	         oLBox:bLine := bLine
	         oLBox:Refresh()
	      EndIf
	   EndIf
	   // Limpa variaveis Get
	   cProduto:= Space(Len(SB1->B1_COD))
	   cDescPro:= Space(Len(SB1->B1_DESC))
	   nQtdInf := 0
	   lRet  := .T.
	
	   If nAcao == 1
	      l361TOk := .F.
	   EndIf
	   aTotPrdUSU  := {}
	   If !lFirst
	      lFirst      := .T.
	      lSecond     := .F.
	      cRecSep     := ""
	      cNomeSep    := ""
	      cRecCon     := ""
	      cNomeCon    := ""
	      cRecEmb     := Space(Len(D12->D12_RECHUM))
	      cNomeEmb    := ""
	      cMapaAtual  := ""
	      cMapSep     := Space(Len(D12->D12_MAPSEP))
	      oMapa:SetFocus()
	   Else
	      oProd:SetFocus()
	   EndIf
	EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Wmsa361Proc³ Autor ³Flavio Luiz Vicco       ³Data³17.04.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa a Separacao dos Itens Conferidos ou registra a    ³±±
±±³          ³ ocorrencia                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Vetor de ocorrencias                               ³±±
±±³          ³ ExpN1 - Quantidade de erros                                ³±±
±±³          ³ ExpC1 - Codigo do conferente                               ³±±
±±³          ³ ExpC2 - Nome do conferente                                 ³±±
±±³          ³ ExpC3 - Codigo do embalador                                ³±±
±±³          ³ ExpC4 - Codigo do separador                                ³±±
±±³          ³ ExpC5 - Nome do separador                                  ³±±
±±³          ³ ExpC6 - Mapa de separacao                                  ³±±
±±³          ³ ExpA2 - Vetor utilizado na impressao das etiquetas         ³±±
±±³          ³ ExpA3 - Vetor com a contagem do usuario                    ³±±
±±³          ³ ExpA4 - Vetor com a contagem do sistema                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Wmsa361Proc(aOcorr,nErro,cRecCon,cNomeCon,cRecEmb,cRecSep,cNomeSep,cMapSep,aEtiqueta,aTotPrdUSU,aTotPrdSYS,cProduto)
Local cCarga   := ''
Local cLogFile := ''
Local cPictQtd := '@E 999999999.99'
Local cWmsDoc  := SuperGetMV('MV_WMSDOC',.F.,'')
Local lRet     := .F.
Local n1Cnt    := 0
Local n2Cnt    := 0
Local nHandle   := 0
Local aLog      := {}
Local oMovimento := WMSDTCMovimentosServicoArmazem():New()
DEFAULT aOcorr := {}
DEFAULT cProduto:= ''
Private lAutoErrNoFile := .T.

	If !Empty(aOcorr)
	   Begin Transaction
	      For n1Cnt := 1 To Len(aTotPrdSYS)
	         If aTotPrdSYS[n1Cnt,2]>0
	            For n2Cnt := 1 To Len(aTotPrdSYS[n1Cnt,4])
	               oMovimento:GoToD12(aTotPrdSys[n1Cnt,4,n2Cnt])
	               If oMovimento:GetStatus() == '3' .AND. Iif(Empty(cProduto),.T.,oMovimento:oMovPrdLot:GetProduto() == cProduto)
	                  cCarga := oMovimento:oOrdServ:GetCarga()
	                  oMovimento:SetStatus('2') // com Problemas
	                  oMovimento:SetDataIni(dDataBase)
	                  oMovimento:SetHoraIni(Time())
	                  oMovimento:SetAnomal('S')
	                  oMovimento:SetQtdErro(Soma1(oMovimento:GetQtdErro()))
	                  If Empty(oMovimento:GetRecCon())
	                     oMovimento:SetRecCon(cRecCon)
	                  EndIf
	                  oMovimento:UpdateD12()
	               EndIf
	            Next
	         EndIf
	      Next
	   End Transaction
	   MsUnlockAll() // Tira o lock da softlock
	   // LOG de Ocorrencias na Conferencia
	   // Arquivo TEXTO com o nome EXnnnnnn.LOG - nnnnnn = nro do Mapa
	   If !Empty(cCarga)
	      cLogFile := 'EX' + PadR(cCarga,6) + '.LOG'
	      // MV_WMSDOC - Define o diretorio onde serao armazenados os documentos/logs gerados pelo WMS.
	      // Este parametro deve estar preenchido com um diretorio criado abaixo do RootPath.
	      // Exemplo: Preencha o parametro com \WMS para o sistema mover o log de ocorrencias do diretorio
	      // C:\MP8\SYSTEM p/o diretorio C:\MP8\WMS
	      If !Empty(cWmsDoc)
	         cWmsDoc := AllTrim(cWmsDoc)
	         If Right(cWmsDoc,1)$'/\'
	            cWmsDoc := Left(cWmsDoc,Len(cWmsDoc)-1)
	         EndIf
	         cLogFile := cWmsDoc+"\"+cLogFile
	      EndIf
	      // ---- Gera array Log
	      AutoGrLog(OemToAnsi(STR0019) + cLogFile + ')') // Microsiga Protheus WMS - LOG de Ocorrencias na Conferencia (
	      AutoGrLog(OemToAnsi(STR0020) + DtoC(dDataBase) + OemToAnsi(STR0021) + Time()) // Log gerado em "###", as 
	      AutoGrLog(OemToAnsi(STR0003+': ') + AllTrim(cMapSep)) // Mapa
	      AutoGrLog(OemToAnsi(STR0004+': ') + AllTrim(cRecCon)+' - '+AllTrim(cNomeCon)) // Conferente
	      AutoGrLog(OemToAnsi(STR0008+': ') + AllTrim(cRecEmb))                        // Embalador
	      AutoGrLog(OemToAnsi(STR0005+': ') + AllTrim(cRecSep) +' - '+AllTrim(cNomeSep))  // Separador
	      AutoGrLog(OemToAnsi(STR0026) + AllTrim(Str(nErro))) // Contagem no.: 
	      AutoGrLog(If(Len(aOcorr)>1, OemToAnsi(STR0027) + AllTrim(Str(Len(aOcorr))) + ') :  ', OemToAnsi(STR0028))) // Ocorrencias ("###"Ocorrencia :
	      AutoGrLog('--------------------------------------++--------------------------------')
	      AutoGrLog(PadC(STR0029,38)+'||'+PadC(STR0030,32)) // Contagem do Sistema"###"Contagem do Usuario
	      AutoGrLog('-----+-----------------+--------------++-----------------+--------------')
	      AutoGrLog(PadR(STR0031,5)+'|'+PadR(STR0006,17)+'|'+PadR(STR0009,14)+'||'+PadR(STR0006,17)+'|'+PadR(STR0009,14)) // Item // Produto // Quantidade // Produto // Quantidade"
	      AutoGrLog('-----+-----------------+--------------++-----------------+--------------')
	      For n1Cnt := 1 To Len(aOcorr)
	         AutoGrLog(StrZero(n1Cnt,3) + '  |' +  PadR(aOcorr[n1Cnt,1],16) + ' | ' + Transform(aOcorr[n1Cnt,2],cPictQtd) + ' ||' + PadR(aOcorr[n1Cnt,3],16) + ' | ' + Transform(aOcorr[n1Cnt,4],cPictQtd))
	      Next
	      AutoGrLog('-----+-----------------+--------------++-----------------+--------------')
	      // Grava Arquivo Log
	      aLog := GetAutoGRLog()
	      If !File(cLogFile)
	         If (nHandle := MSFCreate(cLogFile,0)) <> -1
	            lRet := .T.
	         EndIf
	      Else
	         If (nHandle := FOpen(cLogFile,2)) <> -1
	            FSeek(nHandle,0,2)
	            lRet := .T.
	         EndIf
	      EndIf
	      If lRet
	         For n1Cnt := 1 To Len(aLog)
	            FWrite(nHandle,aLog[n1Cnt]+CRLF)
	         Next n1Cnt
	         FClose(nHandle)
	      EndIf
	      Aviso('WMSA36103',STR0032 + cLogFile + STR0033,{'OK'}) // O LOG "###" foi gerado. Entre em contato com seu Supervisor.
	   EndIf
	Else
	   Begin Transaction
	      For n1Cnt := 1 To Len(aTotPrdSYS)
	         If aTotPrdSYS[n1Cnt,2]>0 .And. AScan(aTotPrdUSU,{|x|x[1]==aTotPrdSYS[n1Cnt,1]})>0
	            For n2Cnt := 1 To Len(aTotPrdSYS[n1Cnt,4])
	               oMovimento:GoToD12(aTotPrdSYS[n1Cnt,4,n2Cnt])
	               If oMovimento:GetStatus() == '3'
	                  // Confirma a distribuicao atualizando o estoque
	                  If oMovimento:IsUpdEst() .And. (oMovimento:oMovServic:ChkSepNorm() .Or. oMovimento:oMovServic:ChkReabast()) // Apanhe normal e  Re-Abastecimento
	                     lRet := oMovimento:RecExit()
	                  EndIf
	                  // Grava status como Executado ou Com Problema
	                  oMovimento:SetStatus(Iif(lRet,'1','2'))
	                  oMovimento:SetDataFim(dDataBase)
	                  oMovimento:SetHoraFim(Time())
	                  If Empty(oMovimento:GetRecCon())
	                     oMovimento:SetRecCon(cRecCon)
	                  EndIf
	                  oMovimento:SetRecEmb(cRecEmb)
	                  oMovimento:UpdateD12()
	                  If lRet
	                     aTotPrdSYS[n1Cnt,2] -= oMovimento:GetQtdMov()
	                  EndIf
	
	                  // Alimenta o vetor aEtiqueta utilizado no ponto de entrada de emissao de etiquetas
	                  If lRet .And. lWmsE006
	                     If AScan(aEtiqueta,{|x|x[1]+x[2]+x[3]+x[4]+x[5]==oMovimento:oOrdServ:GetCarga()+oMovimento:oOrdServ:GetCliFor()+oMovimento:oMovEndOri:GetArmazem()+oMovimento:GetMapSep()+oMovimento:GetEndCon()})==0
	                        AAdd(aEtiqueta,{oMovimento:oOrdServ:GetCarga(),oMovimento:oOrdServ:GetCliFor(),oMovimento:oMovEndOri:GetArmazem(),oMovimento:GetMapSep(),oMovimento:GetEndCon(),oMovimento:GetRecCon()})
	                     EndIf
	                  EndIf
	               EndIf
	            Next
	         EndIf
	      Next
	   End Transaction
	   MsUnlockAll() // Tira o lock da softlock
	EndIf
	// Apaga vetor com dados informados pelo usuario
	aTotPrdUSU := {}
Return NIL
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WmsA361Eti| Autor ³ Alex Egydio              ³Data³21.09.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa rotina especifica de impressao de etiquetas          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Vetor utilizado na impressao das etiquetas           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function WmsA361Eti(aEtiqueta)
Local n1Cnt := 0
Local lRet  := .T.
	If lWmsE006 .And. !Empty(aEtiqueta)
	   For n1Cnt := 1 To Len(aEtiqueta)
	      lRet:=ExecBlock('WMSE006',.F.,.F.,{aEtiqueta[n1Cnt,1],aEtiqueta[n1Cnt,2],aEtiqueta[n1Cnt,3],aEtiqueta[n1Cnt,4],aEtiqueta[n1Cnt,5],aEtiqueta[n1Cnt,6]})
	   Next
	   If ValType(lRet)=='L' .And. lRet
	      aEtiqueta:={}
	   EndIf
	EndIf
Return NIL
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WmsA361Chk| Autor ³ Alex Egydio              ³Data³20.08.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Nao abre o mapa para conferencia se houver registros com     ³±±
±±³          ³ status igual a 2-Com Problema ou 3-Em Execucao               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function WmsA361Chk(cMapSep)
Local aAreaAnt  := GetArea()
Local cAliasNew := ""
Local cQuery    := ""
Local lRet      := .T.

   cAliasNew := GetNextAlias()
   cQuery := "SELECT D12.R_E_C_N_O_ D12RECNO"
   cQuery +=  " FROM " + RetSqlName('D12')+" D12"
   cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
   cQuery +=   " AND D12.D12_MAPSEP = '"+cMapSep+"'"
   cQuery +=   " AND D12.D12_STATUS IN('2','3')"
   cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
   If (cAliasNew)->(!Eof())
      WmsMessage(STR0046+cMapSep+STR0047,,1) // Exitem itens do mapa de separação '#####' que não estão aptos a conferir!
      lRet := .F.
   EndIf
   (cAliasNew)->(DbCloseArea())
	RestArea(aAreaAnt)
Return(lRet)
