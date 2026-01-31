#INCLUDE "PROTHEUS.CH"
#INCLUDE "DLGA150.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE DLGA15001 "DLGA15001"

Static lMarkAll := .F. //Indicador de marca/desmarca todos.
Static nContDCF := 0   //Contador de Registros Marcados (ProcRegua).

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DLGA150  ³ Autor ³ Alex Egydio           ³ Data ³ 26.12.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Execucao de Servicos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Neste arq. se encontram todas as ordens de servico,        ³±±
±±³          ³ dividas em 4 categorias:                                   ³±±
±±³          ³                                                            ³±±
±±³          ³ 1 = Entradas, gerado atraves dos arquivos:                 ³±±
±±³          ³     SD1 - Itens das NF's de Entrada                        ³±±
±±³          ³     SD2 - Itens de venda da NF                             ³±±
±±³          ³     SD3 - Movimentacoes Internas                           ³±±
±±³          ³     SDA - Saldos a Distribuir                              ³±±
±±³          ³     SCM - Remitos de Entrada                               ³±±
±±³          ³                                                            ³±±
±±³          ³ 2 = Saidas, gerado atraves do arquivo:                     ³±±
±±³          ³     SC9 - Pedidos Liberados                                ³±±
±±³          ³     SCN - Remitos de Saida                                 ³±±
±±³          ³                                                            ³±±
±±³          ³ 4 = Ordem de Servico, gerado atraves do arquivo:           ³±±
±±³          ³     DCF - Ordens de servico manual                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLGA150()

Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local bKeyF5     := SetKey(VK_F5)
Local nRefreTela := SuperGetMV('MV_WMSREFS', .F., 10) //-- Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)

Private oBrowse   := Nil
Private cCadastro := OemToAnsi(STR0001) //'Execucao de Servicos'
Private cCusMed   := SuperGetMv('MV_CUSMED')
Private lEnd      := .T.


	If SuperGetMv("MV_WMSNEW",.F.,.F.)
		Return WMSA150()
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o custo medio e' calculado On-Line               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCusMed == 'O'
		Private nHdlPrv     := 0      //-- Endereco do arquivo de contra prova dos lanctos cont.
		Private lCriaHeader := .T. //-- Para criar o header do arquivo Contra Prova
		Private cLoteEst    := ''  //-- Numero do lote para lancamentos do estoque
		Private nTotal     := 0  // Total dos lancamentos contabeis
		Private cArquivo   := '' // Nome do arquivo contra prova
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona numero do Lote para Lancamentos do Faturamento     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SX5->(dbSetorder(1))
		cLoteEst := If(SX5->(DbSeek(xFilial('SX5')+'09EST',.F.)),Trim(X5Descri()),'EST ')
	EndIf
	
	If AMiIn(39,42) //-- Somente autorizado para OMS e WMS
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variaveis utilizadas como parametros p/filtrar as ordens de servico                 ³
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//³ mv_par01   // Servico       De  ?                                                   ³
		//³ mv_par02   //               Ate ?                                                   ³
		//³ mv_par03   // Status do Servico ?1-Nao Executados                                   ³
		//³                                  2-Interrompidos                                    ³
		//³                                  3-Ja Executados                                    ³
		//³                                  4-Aptos a Execucao (Nao Executados e Iterrompidos) ³
		//³                                  5-Aptos ao Estorno (Ja Executados e Interrompidos) ³
		//³                                  6-Todos                                            ³
		//³ mv_par04   // Documento     De  ?                                                   ³
		//³ mv_par05   //               Ate ?                                                   ³
		//³ mv_par06   // Data          De  ?                                                   ³
		//³ mv_par07   //               Ate ?                                                   ³
		//³ mv_par08   // Produto       De  ?                                                   ³
		//³ mv_par09   //               Ate ?                                                   ³
		//³ mv_par10   // Cliente/Forn  De  ?                                                   ³
		//³ mv_par11   //               Ate ?                                                   ³
		//³ mv_par12   // Loja          De  ?                                                   ³
		//³ mv_par13   //               Ate ?                                                   ³
		//³ mv_par14   // Tipo de Servico   ?1-Entradas                                         ³
		//³                                   2-Saidas                                          ³
		//³                                   3-Cargas                                          ³
		//³                                   4-Ordem de Servico                                ³
		//³                                   5-Todos                                           ³
		//³ mv_par15   //  Carga         De  ?                                                  ³
		//³ mv_par16   //                Ate ?                                                  ³
		//³ mv_par17   // Refresh Autom.Tela? Refresh 1o Reg                                    ³
		//³                                   Refresh Ult.Reg                                   ³
		//³                                   Sem Refresh                                       ³
		//³ mv_par18   // Habilita Estorno  ? Sim/Nao                                           ³
		//³ mv_par19   // Estorna Serv.Autom.?Sim/Nao                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		If !Pergunte('DLA150', .T.)
			Return Nil
		EndIf
	
		oBrowse:= FWMarkBrowse():New()
		oBrowse:SetDescription(cCadastro)
		oBrowse:SetMenuDef("DLGA150")
		oBrowse:SetAlias("DCF")
		oBrowse:SetFieldMark("DCF_OK")
		oBrowse:SetValid({||ValidMark()})
		oBrowse:SetAfterMark({||AfterMark(.F.,.F.)})
		oBrowse:SetAllMark({||AllMark()})
		oBrowse:SetFilterDefault("@"+DLA150Qry())
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetAmbiente(.F.)
		oBrowse:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='1'","GREEN" ,"O.S. Nao Executada")
		oBrowse:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='2'","YELLOW","O.S. Interrompida")
		oBrowse:AddLegend("!Empty(DCF_SERVIC).And.DCF_STSERV=='3'","RED"   ,"O.S. Executada")
		oBrowse:AddLegend("Empty(DCF_SERVIC)"                     ,"BLACK" ,"O.S. Sem Servico")
		oBrowse:SetTimer({|| Iif(mv_par17==2, DCF->(DbGoBottom()), Iif(mv_par17==1, DCF->(DbGoTop()), DCF->(DbGoTo(Recno())))), oBrowse:Refresh() }, Iif(nRefreTela<=0, 3600, nRefreTela) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oBrowse:oTimer:lActive := (mv_par17 < 3)})
		oBrowse:SetParam({|| DLA150Sele()})
	
		SetKey (VK_F5 , {|| Processa({|lEnd| oBrowse:Refresh()},cCadastro,OemToAnsi(STR0005),.T.)}) //'Selecionando Servicos...'
	
		oBrowse:Activate()
	
		SetKey (VK_F5 , bKeyF5)
	
		RestArea(aAreaDCF)
		RestArea(aAreaAnt)
	EndIf

Return NIL

/*/-----------------------------------------------------------------------------
 Monta o menu da rotina
-----------------------------------------------------------------------------/*/
Static Function MenuDef()
Local aRotina := {}

	Add OPTION aRotina TITLE STR0002 ACTION "DLA150Manut(,,1)" OPERATION 4 ACCESS 0 //'Executar'
	Add OPTION aRotina TITLE STR0009 ACTION "DLA150Manut(,,2)" OPERATION 4 ACCESS 0 //'Estornar'
	Add OPTION aRotina TITLE STR0008 ACTION "DLA150Sele()"  OPERATION 3 ACCESS 0 //'Selecionar'
	Add OPTION aRotina TITLE STR0027 ACTION "DLGA150Alt()"  OPERATION 3 ACCESS 0 //'Alterar Serviço'

	If ExistBlock("DL150MNU")
		aRotina := ExecBlock("DL150MNU", .F., .F., {aRotina})
	EndIf
	
Return aRotina

/*/-----------------------------------------------------------------------------
 Valida a marcação do registro
-----------------------------------------------------------------------------/*/
Static Function ValidMark()

Local lRet := .F.

	If mv_par03 == 1 .Or. mv_par03 == 2 .Or. mv_par03 == 4 //-- Verde - Apto a Executar
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Status do Servico                                                     ³
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//³ 1 = Nao Executado  // Verde                                           ³
		//³ 2 = Interrompido   // Verde                                           ³
		//³ 3 = Executado      // Vermelho                                        ³
		//³ 4 = Em Conferencia // Azul                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(DCF->DCF_STSERV=='3').And.!(DCF->DCF_STSERV=='4')  //-- Se for Interrompido ou Nao Executado
			lRet := .T.
		EndIf
	ElseIf mv_par03 == 2 .Or. mv_par03 == 3 .Or. mv_par03 == 5 //-- Verde - Apto a Estornar
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Status do Servico                                                     ³
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//³ 1 = Nao Executado  // Vermelho                                        ³
		//³ 2 = Interrompido   // Verde                                           ³
		//³ 3 = Executado      // Verde                                           ³
		//³ 4 = Em Conferencia // Azul                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (DCF->DCF_STSERV == '2' .Or. DCF->DCF_STSERV == '3') //-- Se for Interrompido ou Executado
			lRet := .T.
		EndIf
	EndIf

Return lRet

/*/-----------------------------------------------------------------------------
 Rotina após a marcação do registro
-----------------------------------------------------------------------------/*/
Static Function AfterMark(lMarkAll,lMarkRec)
Static lDLA150Pe  := ExistBlock('DLGA150M')
Static lDla150Mk  := ExistBlock('DLA150MK')
Local aAreaAnt    := GetArea()
Local lRet        := .T.

	If lDla150Mk
		lRet := ExecBlock('DLA150MK',.F.,.F.,oBrowse:cMark)
	EndIf
	If lRet
		If lMarkAll
			Reclock('DCF',.F.)
			DCF->DCF_OK := Iif(lMarkRec,oBrowse:cMark,Space(TamSx3("DCF_OK")[1]))
			MsUnlock()
			Iif(!Empty(DCF->DCF_OK), nContDCF++, nContDCF--)
		Else
			Iif(oBrowse:IsMark(), nContDCF++, nContDCF--)
			MarcaSimil(oBrowse:IsMark(),oBrowse:cMark,Space(TamSx3("DCF_OK")[1])) //-- Marca ou Desmarca todos os servicos de uma mesma Carga/Documento
		EndIf
	EndIf
	If lDLA150Pe
		ExecBlock("DLGA150M",.F.,.F.,oBrowse:cMark)
	EndIf
	RestArea(aAreaAnt)
Return lRet

/*/-----------------------------------------------------------------------------
 Marca ou desmarca todos os servicos da mesma Carga/Documento
 Impede que estes servicos sejam executados separadamente
-----------------------------------------------------------------------------/*/
Static Function MarcaSimil(cMarca)
Local aAreaDCF  := DCF->(GetArea())
Local cAliasDCF := ""
Local cChave    := ""
Local cCompar   := ""
Local nRecnoDCF := 0
Local cQuery    := ""

	If ExistBlock('DLGA150M') .OR. ExistBlock('DLA150MK')
		// Define a chave de pesquisa para encontrar as ordens de serviço similares
		If WmsCarga(DCF->DCF_CARGA)
			cChave := "xFilial('DCF')+DCF->DCF_SERVIC+DCF->DCF_CARGA"
		Else
			cChave := "xFilial('DCF')+DCF->DCF_SERVIC+DCF->DCF_DOCTO+DCF->DCF_CLIFOR+DCF->DCF_LOJA"
		EndIf
	
		// Define a string de comparação com base na DCF posicionada
		cCompar := &cChave
	
		// Busca alias do próprio browse, que neste caso é a DCF
		cAliasDCF := oBrowse:Alias()
		nRecnoDCF := (cAliasDCF)->(Recno())
		
		// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
		// a regra de marcação será executada apenas para os registros que o usuário vê em tela
		(cAliasDCF)->(DbGoTop())
		
		While (cAliasDCF)->(!Eof())
			// Marca apenas se for um registro similar
			If &cChave == cCompar .And. nRecnoDCF != (cAliasDCF)->(Recno())
				AfterMark(.T.,!Empty(cMarca))
			EndIf
			(cAliasDCF)->(DbSkip())
		EndDo
	Else		
		cQuery := "UPDATE " + RetSqlName("DCF")
		cQuery += " SET DCF_OK = '" + Iif(!Empty(cMarca), oBrowse:Mark(), " ") + "' "
		cQuery += "	WHERE R_E_C_N_O_ IN (SELECT R_E_C_N_O_ FROM " + RetSqlName("DCF") + " WHERE "
		cQuery += DLA150Qry() + " AND D_E_L_E_T_ = ' '"
		If WmsCarga(DCF->DCF_CARGA)
			cQuery += " AND DCF_SERVIC = '" + DCF->DCF_SERVIC +"'" 
			cQuery += " AND DCF_CARGA = '"+ DCF->DCF_CARGA + "')"
		Else
		    cQuery += " AND DCF_SERVIC = '" + DCF->DCF_SERVIC +"'"
		    cQuery += " AND DCF_DOCTO = '" + DCF->DCF_DOCTO +"'"
		    cQuery += " AND DCF_CLIFOR = '" + DCF->DCF_CLIFOR +"'"
		    cQuery += " AND DCF_LOJA = '" + DCF->DCF_LOJA +"')"
		EndIf
		If TcSQLExec(cQuery) < 0
			WmsMessage(STR0038 + CRLF + TcSQLError()) //'Erro na marcação dos registros exibidos.'
		EndIf
		nContDCF := CountDCF()
	EndIf
	
	
	RestArea(aAreaDCF)
	oBrowse:Refresh()
Return Nil

/*/-----------------------------------------------------------------------------
 Marca todos os registros da seleção
-----------------------------------------------------------------------------/*/
Static Function AllMark()
Local aAreaDCF  := DCF->(GetArea())
Local cAliasDCF := ""
Local cQuery    := ""

	lMarkAll := !lMarkAll
	If lMarkAll
		nContDCF := 0
	EndIf
	// Busca alias do próprio browse, que neste caso é a DCF
	If ExistBlock('DLGA150M') .OR. ExistBlock('DLA150MK')
		cAliasDCF := oBrowse:Alias()
		// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
		// a regra de marcação será executada apenas para os registros que o usuário vê em tela
		(cAliasDCF)->(DbGoTop())
		While (cAliasDCF)->(!Eof())
			AfterMark(.T.,lMarkAll)
			(cAliasDCF)->(DbSkip())
		EndDo
		
	Else		
		cQuery := "UPDATE " + RetSqlName("DCF")
		cQuery += " SET DCF_OK = '" + Iif(lMarkAll, oBrowse:Mark(), " ") + "' "
		cQuery += "	WHERE R_E_C_N_O_ IN (SELECT R_E_C_N_O_ FROM " + RetSqlName("DCF") + " WHERE "
		cQuery += DLA150Qry() + " AND D_E_L_E_T_ = ' ')"
		If TcSQLExec(cQuery) < 0
			WmsMessage(STR0038 + CRLF + TcSQLError()) //'Erro na marcação dos registros exibidos.' 
		Else
   			DCF->(dbGoTo(0))
		EndIf
		
		If lMarkAll
		   nContDCF := CountDCF()
		Endif 	
	EndIf
	If !lMarkAll
		nContDCF := 0
	EndIf
	RestArea(aAreaDCF)
	oBrowse:Refresh()
Return Nil

/*/-----------------------------------------------------------------------------
 Desmarca todos os registros da seleção
-----------------------------------------------------------------------------/*/
Static Function UncheckAll(cWhere)
Local aArea  := GetArea()
Local cQuery := ""

	cQuery := "UPDATE " + RetSqlName("DCF")
	cQuery +=   " SET DCF_OK = ' '"
	cQuery += " WHERE "+cWhere+" AND DCF_OK = '"+oBrowse:cMark+"' AND D_E_L_E_T_ = ' '"
	If TcSQLExec(cQuery) < 0
		WmsMessage(STR0037 + CRLF + TcSQLError(),DLGA15001,2) // "Problema ao tentar demarcar os registros DCF: "
	EndIf

	nContDCF := 0

	RestArea(aArea)
	oBrowse:Refresh()
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLA150Qry ³ Autor ³Alex Egydio              ³Data³13.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna expressao do filtro                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function DLA150Qry()
Local cQuery := ''
Local nStServ:= mv_par03

		cQuery  := " DCF_FILIAL = '"+xFilial('DCF')+"' And "
		cQuery  += "DCF_SERVIC >= '"+mv_par01+"' And "
		cQuery  += "DCF_SERVIC <= '"+mv_par02+"' And "
		cQuery  += "DCF_DOCTO  >= '"+mv_par04+"' And "
		cQuery  += "DCF_DOCTO  <= '"+mv_par05+"' And "
		cQuery  += "DCF_DATA   >='"+DtoS(mv_par06)+"' And "
		cQuery  += "DCF_DATA   <='"+DtoS(mv_par07)+"' And "
		cQuery  += "DCF_CODPRO >= '"+mv_par08+"' And "
		cQuery  += "DCF_CODPRO <= '"+mv_par09+"' And "
		cQuery  += "DCF_CLIFOR >= '"+mv_par10+"' And "
		cQuery  += "DCF_LOJA   >= '"+mv_par12+"' And "
		cQuery  += "DCF_LOJA   <= '"+mv_par13+"' And "
		cQuery  += "DCF_CLIFOR <= '"+mv_par11+"' And "
		cQuery  += "DCF_CARGA  >= '"+mv_par15+"' And "
		cQuery  += "DCF_CARGA  <= '"+mv_par16+"' And "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tipo de Servico   ? 1-Entradas                                        ³
	//³                     2-Saidas                                          ³
	//³                     3-Cargas Unitizadas                               ³
	//³                     4-Internos                                        ³
	//³                     5-Todos                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par14 == 1    //-- Entradas
		cQuery  += "DCF_ORIGEM IN ('SD1','SD2','SDA','SCM') And "
	ElseIf mv_par14 == 2 //-- Saidas
		cQuery  += "DCF_ORIGEM IN ('SC9','SCN','SD4') And "
	ElseIf mv_par14 == 3 //-- -> Não usado <- (Removido)
		cQuery  += "DCF_ORIGEM = '   ' And "
	ElseIf mv_par14 == 4 //-- Internos
		cQuery  += "DCF_ORIGEM IN ('DCF','SD3') And "
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Status do Servico ? 1-Nao Executados                                  ³
	//³                     2-Interrompidos                                   ³
	//³                     3-Ja Executados                                   ³
	//³                     4-Aptos a Execucao (Nao Executados e Iterrompidos)³
	//³                     5-Aptos ao Estorno (Ja Executados e Interrompidos)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nStServ == 1      //-- Mostra Somente Servicos ainda Nao Executados
		cQuery += "DCF_STSERV IN ('1','4')"
	ElseIf  nStServ == 2 //-- Mostra Somente Servicos Interrompidos
		cQuery += "DCF_STSERV = '2'"
	ElseIf  nStServ == 3 //-- Mostra somente Servicos Ja Executados
		cQuery += "DCF_STSERV = '3'"
	ElseIf  nStServ == 4 //-- Mostra somente Servicos Aptos a Execucao (Nao Executados e Iterrompidos)
		cQuery += "DCF_STSERV IN ('1','2')"
	Else //-- Mostra somente Servicos Aptos ao Estorno (Ja Executados e Interrompidos)
		cQuery += "DCF_STSERV IN ('3','2')"
		cQuery += "AND NOT EXISTS (SELECT 1" 
		cQuery +=                  " FROM "+RetSqlName('SC9')+" SC9" 
		cQuery +=                 " WHERE SC9.C9_FILIAL     = '"+xFilial('SC9')+"'"
		cQuery +=                     " AND SC9.C9_IDDCF    = DCF_ID"
		cQuery +=                     " AND SC9.C9_NFISCAL <> ' ' "
		cQuery +=                     " AND SC9.D_E_L_E_T_  = ' ')"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada DL150FIL para a alteracao do Filtro executado pelo programa            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock('DL150FIL')
		If ValType(cQueryPE:=ExecBlock('DL150FIL',.F.,.F.,{cQuery,.T.})) == 'C'
			cQuery := cQueryPE
		EndIf
	EndIf
Return(cQuery)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLA150Sele ³ Autor ³ Fernando Joly Siquini³ Data ³24.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite Selecionar Novamente o Intervalo                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLA150Sele()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA150Sele()
Local lRet       := .T.
Local cWhere     := ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas como parametros p/filtrar as ordens de servico                 ³
	//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
	//³ mv_par01   // Servico       De  ?                                                  ³
	//³ mv_par02   //               Ate ?                                                  ³
	//³ mv_par03   // Status do Servico?1-Nao Executados                                   ³
	//³                                  2-Interrompidos                                    ³
	//³                                  3-Ja Executados                                    ³
	//³                                  4-Aptos a Execucao (Nao Executados e Iterrompidos) ³
	//³                                  5-Aptos ao Estorno (Ja Executados e Interrompidos) ³
	//³                                  6-Todos                                            ³
	//³ mv_par04   // Documento     De  ?                                                  ³
	//³ mv_par05   //               Ate ?                                                  ³
	//³ mv_par06   // Data          De  ?                                                  ³
	//³ mv_par07   //               Ate ?                                                  ³
	//³ mv_par08   // Produto       De  ?                                                  ³
	//³ mv_par09   //               Ate ?                                                  ³
	//³ mv_par10   // Cliente/Forn  De  ?                                                  ³
	//³ mv_par11   //               Ate ?                                                  ³
	//³ mv_par12   // Loja          De  ?                                                  ³
	//³ mv_par13   //               Ate ?                                                  ³
	//³ mv_par14   // Tipo de Servico   ?1-Entradas                                        ³
	//³                                   2-Saidas                                          ³
	//³                                   3-Cargas                                          ³
	//³                                   4-Ordem de Servico                                ³
	//³                                   5-Todos                                           ³
	//³ mv_par15   // Carga         De  ?                                                  ³
	//³ mv_par16   //               Ate ?                                                  ³
	//³ mv_par17   // Refresh Autom.Tela? Refresh 1o Reg                                    ³
	//³                                   Refresh Ult.Reg                                   ³
	//³                                   Sem Refresh                                       ³
	//³ mv_par18   // Habilita Estorno  ? Sim/Nao                                           ³
	//³ mv_par19   // Estorna Serv.Autom.?Sim/Nao                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nContDCF > 0
		cWhere := DLA150Qry()
	EndIf
	lRet := Pergunte('DLA150', .T.)
	If lRet
		//-- Antes de selecionar novos registros, eh obrigatoria a chamada da funcao AllMark para desmarcar todos os
		//-- registros selecionados anteriormente. Isto evita que fiquem marcas repetidas gravadas no campo DCF_OK
		If nContDCF > 0
			UncheckAll(cWhere)
		EndIf
		oBrowse:oBrowse:oTimer:lActive := (mv_par17 < 3)
		//-- Selecionar servicos conforme a parametrizacao do usuario.
		oBrowse:SetFilterDefault("@"+DLA150Qry())
		oBrowse:Refresh()
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLA150Manut³ Autor ³ Alex Egydio          ³ Data ³ 26.12.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Execucao de Servicos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLA150Manut(ExpC1,ExpN1,ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ DLGA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA150Manut( cAlias, nReg, nOpcx )
Local lRetPE := .T.

	//-- Ponto de Entrada DL150AEX - Antes Execucao/Estorno O.S.WMS.
	If ExistBlock( "DL150BEX" )
		lRetPE := ExecBlock( "DL150BEX", .F., .F., {nOpcx} )
		If ValType(lRetPE) == 'L' .And. !lRetPE
			Return Nil
		EndIf 
	EndIf
	
	If nOpcx == 1 //-- Executa
		//-- Selecionou o.s.wms aptas a estornar e tentou executar
		If mv_par03 == 5 .OR. mv_par03 == 3
			Aviso('DLGA15001',STR0018, {STR0020}) //'Para executar o servico voce deve habilitar esta opcao atraves das Perguntas desta rotina'##'Ok'
		Else
			Processa({|lEnd| DLA150Serv(@lEnd)},cCadastro,OemToAnsi(STR0004),.T.)   //'Executando Servicos...'
		EndIf
	Else //-- Estorna
		If mv_par18 == 2 .OR. mv_par03 == 1 .OR. mv_par03 == 4
			Aviso('DLGA15002',STR0019, {STR0020}) //'Para executar o Estorno voce deve habilitar esta opcao atraves das Perguntas desta rotina'##'Ok'
		Else
			Processa({|lEnd| DLA150Esto(@lEnd)},cCadastro,OemToAnsi(STR0021),.T.) //'Estornando Servicos...'
		EndIf
	EndIf
	
	//-- Ponto de Entrada DL150AEX - Apos Execucao/Estorno O.S.WMS.
	If ExistBlock( "DL150AEX" )
		ExecBlock( "DL150AEX", .F., .F., {nOpcx} )
	EndIf

	//Executa novamente o pergunte pois o MATA261 pode alterar os valores
	Pergunte('DLA150', .F.)
	oBrowse:Refresh()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLA150Serv³ Autor ³ Alex Egydio           ³ Data ³17.01.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Executa os Servicos Selecionados                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLA150Serv(ExpL1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Cancelar o processamento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 = Se .T. a rotina foi Cancelada, .F. caso contrario  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA150Serv(lEnd)
Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local nStServ    := mv_par03
Local cQuery     := ''
Local cAliasNew  := 'DCF'
Local cSrvVazio  := Space(Len(DCF->DCF_SERVIC))
Local aDocsDesfr := {}
Local cDocto     := ''
Local cMensagem  := ''
Local lRadioF    := (SuperGetMV('MV_RADIOF', .F., 'N')=='S') //-- Como Default o parametro MV_RADIOF e verificado

//-- Variaveis utilizadas pela funcao wmsexedcf
Private aLibSDB  := {}
Private aWmsAviso:= {}
Private aWmsDCF  := {}
Private aWmsReab := {}
Private aLogSld  := {}
Private aLogEnd  := {}

	WmsLogEnd(.F.)
	WmsLogSld(.F.)
	
	dbSelectArea('SD1')
	dbSetOrder(1)
	
	dbSelectArea('SD2')
	dbSetOrder(3)
	
	dbSelectArea('SD3')
	dbSetOrder(2)
	
	dbSelectArea('SC9')
	dbSetOrder(1)
	
	dbSelectArea('DC5')
	dbSetOrder(1)
	
	dbSelectArea('DC6')
	dbSetOrder(1)
	
	If cPaisLoc <> "BRA"
		dbSelectArea('SCM')
		dbSetOrder(9)
	
		dbSelectArea('SCN')
		dbSetOrder(6)
	EndIf
	dbSelectArea('DCF')
	//-- Verificar data do ultimo fechamento em SX6.
	If MVUlmes() >= dDataBase
		Help (' ', 1, 'FECHTO')
		Return Nil
	EndIf
	//-- Status do Servico ? 1-Nao Executados
	//--                     2-Interrompidos
	//--                     3-Ja Executados
	//--                     4-Aptos a Execucao (Nao Executados e Iterrompidos)
	//--                     5-Aptos ao Estorno (Ja Executados e Interrompidos)
	
	cAliasNew := GetNextAlias()
	cQuery := "SELECT R_E_C_N_O_ RECNODCF,"+SqlOrder(DCF->(IndexKey(IndexOrd())))
	cQuery += "  FROM "+RetSqlName('DCF')
	cQuery += " WHERE DCF_FILIAL = '"+xFilial("DCF")+"'"
	If mv_par01 == mv_par02
		cQuery += " AND DCF_SERVIC = '"+mv_par01+"'"
	Else
		cQuery += " AND DCF_SERVIC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	EndIf
	If Empty(mv_par01) .Or. Empty(mv_par02)
		cQuery += " AND DCF_SERVIC <> '"+cSrvVazio+"'"
	EndIf
	If nStServ == 1         //-- Executa Somente Servicos ainda Nao Executados
		cQuery += " AND DCF_STSERV IN (' ','1')"
	ElseIf nStServ == 2     //-- Executa Somente Servicos Interrompidos
		cQuery += " AND DCF_STSERV = '2'"
	ElseIf nStServ == 4     //-- Executa Somente Servicos Aptos a Execucao (Nao Executados e Iterrompidos)
		cQuery += " AND DCF_STSERV IN ('1','2')"
	EndIf
	cQuery += " AND DCF_OK = '"+oBrowse:cMark+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY "
	If ExistBlock('DL150OEX')
		cQuery += ExecBlock('DL150OEX', .F., .F.)
	Else
		cQuery += SqlOrder(DCF->(IndexKey(IndexOrd())))
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)
	
	ProcRegua(nContDCF)
	If (cAliasNew)->(!Eof()) .And. ChkWmsPrio()
		While (cAliasNew)->(!Eof()) .And. !lEnd
	
			DCF->(DbGoTo((cAliasNew)->RECNODCF))
	
			If DCF->(SimpleLock()) .And. (DCF->DCF_STSERV $ '12') .And. !(Empty(DCF->DCF_OK))
				IncProc(DCF->(DCF_SERVIC+" - "+If(Empty(DCF_CARGA),Trim(DCF_DOCTO)+"/"+Trim(SerieNfId("DCF",2,"DCF_SERIE")),Trim(DCF_CARGA))+"/"+Trim(DCF_CODPRO)))
				ProcessMessage() // Minimiza o efeito de 'congelamento' da aplicação
	
				WmsExeDCF('1',.F.)
	
	//			If GetVersao(.F.) >= '12' .And. DCF->DCF_STSERV != "2" .And. !lRadioF .And. a150Desfrg(DCF->DCF_SERVIC,DCF->DCF_ID)
	//				If DCF->DCF_DOCTO != cDocto
	//					AAdd( aDocsDesfr, {DCF->DCF_DOCTO,DCF->DCF_SERVIC} )
	//					cDocto := DCF->DCF_DOCTO
	//				EndIf
	//			EndIf
	
				//-- Usado na regra de sequencia para verificar itens processados anteriormente.
				If aScan(aWmsDCF,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]==DCF->DCF_LOCAL+DCF->DCF_SERVIC+DCF->DCF_CARGA+DCF->DCF_DOCTO+DCF->DCF_CLIFOR+DCF->DCF_LOJA}) == 0
					aAdd(aWmsDCF,{DCF->DCF_LOCAL,DCF->DCF_SERVIC,DCF->DCF_CARGA,DCF->DCF_DOCTO,DCF->DCF_CLIFOR,DCF->DCF_LOJA})
				EndIf
	
				(cAliasNew)->(DbSkip())
			Else
				(cAliasNew)->(DbSkip())
			EndIf
			DCF->(MsUnLock())
		EndDo
		(cAliasNew)->(DbCloseArea())
	
		//-- O wms devera avaliar as regras para convocacao do servico e disponibilizar os
		//-- registros do SDB para convocacao
		WmsExeDCF('2')
	
		//-- Exibe as mensagens de reabastecimento
		If SuperGetMV('MV_WMSEMRE',.F.,.T.) .And. !Empty(aWmsReab)
			TmsMsgErr(aWmsReab, STR0035) //Reabastecimentos pendentes:
		EndIf
	
	//	//Impressao do relatorio de movimentacao quando servico igual a desfragmentacao e MV_RADIOF = "N"
	//	If GetVersao(.F.) >= '12' .And. !lRadioF .And. !Empty(aDocsDesfr)
	//		ImpriMovim(aDocsDesfr)
	//	EndIf
	
		If Len(aLogEnd) > 0 .And. FindFunction("WmsLogEnd") .And. (WmsLogEnd() .Or. SuperGetMV('MV_WMSRLEN',.F.,.F.))
			//-- Se a impressão é forçada, não mostra a mensagem de OS não atendida
			If !SuperGetMV('MV_WMSRLEN',.F.,.F.)
				cMensagem := STR0006+CHR(13)+CHR(10) //"Existem ordens de serviço de endereçamento que não foram totalmente atendidas."
			EndIf
			cMensagem += STR0007 //"Deseja imprimir o relatório de busca de endereços para a armazenagem?"
			If WmsQuestion(cMensagem)
				WMSR120()
			EndIf
		EndIf
		If Len(aLogSld) > 0 .And. FindFunction("WmsLogSld") .And. (WmsLogSld() .Or. SuperGetMV('MV_WMSRLSA',.F.,.F.))
			//-- Se a impressão é forçada, não mostra a mensagem de OS não atendida
			If !SuperGetMV('MV_WMSRLSA',.F.,.F.)
				cMensagem := STR0010+CHR(13)+CHR(10) //"Existem ordens de serviço de apanhe que não foram totalmente atendidas."
			EndIf
			cMensagem += STR0011 //"Deseja imprimir o relatório de busca de saldo para o apanhe?"
			If WmsQuestion(cMensagem)
				WMSR110()
			EndIf
		EndIf
	
	EndIf
	WmsLogEnd(.F.)
	WmsLogSld(.F.)
	
	RestArea(aAreaDCF)
	RestArea(aAreaAnt)
Return lEnd

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ DLA150Esto ³ Autor ³Alex Egydio/Fernando Joly³Data³27.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Estorna os servicos selecionados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 - .F. Interrompe o processamento                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 = Se .T. a rotina foi Cancelada, .F. caso contrario    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function DLA150Esto(lEnd)
Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local lRet       := .T.
Local aDocOri    := {}
Local aVisErr    := {}
Local cAliasNew  := GetNextAlias()
Local cQuery     := ""
Local nStServ    := mv_par03
Local cSrvVazio  := Space(Len(DCF->DCF_SERVIC))
Local cMsg       := ""

	//-- Verificar data do ultimo fechamento em SX6
	If MVUlmes() >= dDataBase
		Help (' ', 1, 'FECHTO')
		Return NIL
	EndIf

	cQuery := "SELECT R_E_C_N_O_ RECNODCF,"+SqlOrder(DCF->(IndexKey(IndexOrd())))
	cQuery +=  " FROM "+RetSqlName('DCF')
	cQuery += " WHERE DCF_FILIAL = '"+xFilial("DCF")+"'"
	If mv_par01 == mv_par02
		cQuery += " AND DCF_SERVIC = '"+mv_par01+"'"
	Else
		cQuery += " AND DCF_SERVIC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	EndIf
	If Empty(mv_par01) .Or. Empty(mv_par02)
		cQuery += " AND DCF_SERVIC <> '"+cSrvVazio+"'"
	EndIf
	If nStServ == 2         //-- Estorna Somente Servicos Executados
		cQuery += " AND DCF_STSERV = '2'"
	ElseIf nStServ == 3     //-- Estorna Somente Servicos Interrompidos
		cQuery += " AND DCF_STSERV = '3'"
	ElseIf nStServ == 5     //-- Estorna Somente Servicos Aptos ao Estorno (Executados e Iterrompidos)
		cQuery += " AND DCF_STSERV IN ('2','3')"
	EndIf
	cQuery += " AND DCF_OK = '"+oBrowse:cMark+"'"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY "+SqlOrder(DCF->(IndexKey(IndexOrd())))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	ProcRegua(nContDCF)
	While (cAliasNew)->(!Eof()) .And. !lEnd

		DCF->(DbGoTo((cAliasNew)->RECNODCF))

		If DCF->(SimpleLock()) .AND. (DCF->DCF_STSERV $ '23')

			IncProc(DCF->(DCF_SERVIC+" - "+If(Empty(DCF_CARGA),DCF_DOCTO+"/"+SerieNfId("DCF",2,"DCF_SERIE"),DCF_CARGA)+"/"+DCF_CODPRO))
			ProcessMessage() // Minimiza o efeito de 'congelamento' da aplicação

			If (lRet := VldEstDCF(@cMsg))
				//-- Estorno da execucao de servicos
				WmsEstAll('1',(mv_par19 == 1),aDocOri,.T.)
			Else
				AAdd(aVisErr,{cMsg})
			EndIf

			(cAliasNew)->(DbSkip())
		Else
			(cAliasNew)->(DbSkip())
		EndIf

		DCF->(MsUnLock())

	EndDo
	(cAliasNew)->(DbCloseArea())

	//-- Estorna todos os documentos com referencia a carga ou documento original
	If !Empty(aDocOri)
		WmsEstAll('2',.F.,aDocOri,.T.)
	EndIf

	If !Empty(aVisErr)
		TmsMsgErr (aVisErr, STR0014 ) //Os Serviços abaixo não foram estornados!
	EndIf

	RestArea(aAreaDCF)
	RestArea(aAreaAnt)
Return lEnd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLA150Stat³ Autor ³ Alex Egydio           ³ Data ³17.01.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Status do Servico                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ DLA150Stat(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Status do Servico                                  ³±±
±±³          ³         3 = Executado                                      ³±±
±±³          ³         2 = Interrompido                                   ³±±
±±³          ³         1 = Nao Executado                                  ³±±
±±³          ³ Obs.: Deve estar posicionado no Registro do DCF a atualizar³±±
±±³          ³ ExpC2 = Codigo do servico a ser alterado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ DLGA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function DLA150Stat(cStatus, cServico)

Static lDL150STA := ExistBlock( "DL150STA" )

Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local aAreaAntA  := {}
Local lRadioF    := (SuperGetMV('MV_RADIOF', .F., 'N')=='S')
Local cSeek      := ''
Local cPedido    := ''
Local cItem      := ''
Local cSequencia := ''
Local cCarga     := ''
Local cUnitiza   := ''
Local cDoc       := ''
Local cSerie     := ''
Local cCliFor    := ''
Local cLoja      := ''
Local cLocal     := ''
Local cProduto   := ''
Local dData      := CtoD('  /  /  ')
Local nRegSD1    := 0
Local cAliasNew  := ""
Local cQuery     := ""

Private cCompara := ''

Default cStatus    := '3'
Default cServico   := Nil

	RecLock('DCF',.F.)
	DCF->DCF_STSERV := cStatus
	DCF->DCF_OK     := '  '
	MsUnLock()
	
	If DCF->DCF_ORIGEM == 'SD1'
		cDoc       := PadR(DCF->DCF_DOCTO,  Len(SD1->D1_DOC    ))
		cSerie     := PadR(DCF->DCF_SERIE,  Len(SD1->D1_SERIE  ))
		cCliFor    := PadR(DCF->DCF_CLIFOR, Len(SD1->D1_FORNECE))
		cLoja      := PadR(DCF->DCF_LOJA,   Len(SD1->D1_LOJA   ))
		cProduto   := PadR(DCF->DCF_CODPRO, Len(SD1->D1_COD    ))
		cSequencia := PadR(DCF->DCF_NUMSEQ, Len(SD1->D1_NUMSEQ ))
		cSeek      := xFilial('SD1')+cDoc+cSerie+cCliFor+cLoja+cProduto
		dbSelectArea('SD1')
		aAreaAntA := GetArea()
		SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		If SD1->(MsSeek(cSeek))
			Do While SD1->(!Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD==cSeek)
				If Iif(Empty(SD1->D1_NUMSEQ), .T., SD1->D1_NUMSEQ==cSequencia) //-- Soh preenche o D1_NUMSEQ na classificacao da NF
					nRegSD1 := SD1->(Recno()) //-- Guarda registro do SD1
					RecLock('SD1', .F.)
					SD1->D1_STSERV := cStatus
					If !(cServico==Nil)
						SD1->D1_SERVIC := cServico
					EndIf
					MsUnLock()
				EndIf
				SD1->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaAntA)
		If nRegSD1 > 0
			SD1->(dbGoto(nRegSD1)) //-- Posiciona registro do SD1
		EndIf
	ElseIf DCF->DCF_ORIGEM == 'SD2'
		cDoc       := PadR(DCF->DCF_DOCTO,  Len(SD2->D2_DOC    ))
		cSerie     := PadR(DCF->DCF_SERIE,  Len(SD2->D2_SERIE  ))
		cCliFor    := PadR(DCF->DCF_CLIFOR, Len(SD2->D2_CLIENTE))
		cLoja      := PadR(DCF->DCF_LOJA,   Len(SD2->D2_LOJA   ))
		cProduto   := PadR(DCF->DCF_CODPRO, Len(SD2->D2_COD    ))
		cSequencia := PadR(DCF->DCF_NUMSEQ, Len(SD2->D2_NUMSEQ ))
		cSeek      := xFilial('SD2')+cDoc+cSerie+cCliFor+cLoja+cProduto
		dbSelectArea('SD2')
		aAreaAntA := GetArea()
		SD2->(DbSetOrder(3))
		If SD2->(MsSeek(cSeek))
			While SD2->(!Eof() .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD==cSeek)
				If SD2->D2_NUMSEQ == cSequencia
					RecLock('SD2', .F.)
					SD2->D2_STSERV := cStatus
					If !(cServico==Nil)
						SD2->D2_SERVIC := cServico
					EndIf
					MsUnLock()
				EndIf
				SD2->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaAntA)
	ElseIf DCF->DCF_ORIGEM == 'SD3'
		cDoc       := PadR(DCF->DCF_DOCTO, Len(SD3->D3_DOC   ))
		cLocal     := PadR(DCF->DCF_LOCAL, Len(SD3->D3_LOCAL ))
		cProduto   := PadR(DCF->DCF_CODPRO,Len(SD3->D3_COD   ))
		cSequencia := PadR(DCF->DCF_NUMSEQ,Len(SD3->D3_NUMSEQ))
		cSeek      := xFilial('SD3')+cProduto+cLocal+cSequencia
		dbSelectArea('SD3')
		aAreaAntA := GetArea()
		SD3->(DbSetOrder(3)) //-- D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ
		If SD3->(MsSeek(cSeek))
			RecLock('SD3', .F.)
			SD3->D3_STSERV := cStatus
			If !(cServico==Nil)
				SD3->D3_SERVIC := cServico
			EndIf
			MsUnLock()
		EndIf
		RestArea(aAreaAntA)
	ElseIf DCF->DCF_ORIGEM == 'SC9'
		cPedido    := PadR(DCF->DCF_DOCTO,  Len(SC9->C9_PEDIDO ))
		cItem      := PadR(DCF->DCF_SERIE,  Len(SC9->C9_ITEM   ))
		cSequencia := PadR(DCF->DCF_NUMSEQ, Len(SC9->C9_SEQUEN ))
		cProduto   := PadR(DCF->DCF_CODPRO, Len(SC9->C9_PRODUTO))
		cCarga     := PadR(DCF->DCF_CARGA,  Len(SC9->C9_CARGA  ))
		dbSelectArea('SC9')
		aAreaAntA := GetArea()
		//--
		cAliasNew := GetNextAlias()
		cQuery := "SELECT C9_PRODUTO, C9_SERVIC, SC9.R_E_C_N_O_ SC9RECNO "
		cQuery += " FROM "
		cQuery += RetSqlName('SC9')+" SC9 "
		cQuery += " WHERE "
		cQuery += " C9_FILIAL     = '"+xFilial("SC9")+"'"
		If WmsCarga(cCarga)
			cQuery += " AND C9_CARGA  = '"+cCarga+"'"
		Else
			cQuery += " AND C9_PEDIDO  = '"+cPedido+"'"
			cQuery += " AND C9_ITEM    = '"+cItem+"'"
		EndIf
		cQuery += " AND SC9.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
		Do While (cAliasNew)->(!Eof())
			If cProduto == (cAliasNew)->C9_PRODUTO .And. !Empty((cAliasNew)->C9_SERVIC)
				SC9->(dbGoto((cAliasNew)->SC9RECNO))
				RecLock('SC9', .F.)
				SC9->C9_STSERV := cStatus
				If !(cServico==Nil)
					SC9->C9_SERVIC := cServico
				EndIf
				MsUnLock()
			EndIf
			(cAliasNew)->(dbSkip())
		EndDo
		(cAliasNew)->(DbCloseArea())
		RestArea(aAreaAntA)
	ElseIf DCF_ORIGEM == 'SCM'
		cDoc       := PadR(DCF_DOCTO,  Len(SD2->D2_DOC   ))
		cSequencia := PadR(DCF_NUMSEQ, Len(SC9->C9_SEQUEN))
		cSeek      := xFilial('SCM')+cDoc+cSequencia
		dbSelectArea('SCM')
		aAreaAntA := GetArea()
		dbSetOrder(9)
		If dbSeek(cSeek, .F.)
			RecLock('SCM', .F.)
			Replace CM_STSERV With cStatus
			If !(cServico==Nil)
				Replace CM_SERVIC With cServico
			EndIf
			MsUnLock()
		EndIf
		RestArea(aAreaAntA)
	ElseIf DCF_ORIGEM == 'SCN'
		cSequencia := PadR(DCF_NUMSEQ, Len(SC9->C9_SEQUEN))
		dData      := DCF_DATA
		cSeek      := xFilial('SCN')+DtoS(dData)+cSequencia
		dbSelectArea('SCN')
		aAreaAntA := GetArea()
		dbSetOrder(6)
		If dbSeek(cSeek, .F.)
			RecLock('SCN', .F.)
			Replace CN_STSERV With cStatus
			If !(cServico==Nil)
				Replace CN_SERVIC With cServico
			EndIf
			MsUnLock()
		EndIf
		RestArea(aAreaAntA)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada DL150STA - Apos gravacao do status do Servico ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDL150STA
		ExecBlock( "DL150STA", .F., .F. )
	EndIf
	
	RestArea(aAreaDCF)
	RestArea(aAreaAnt)

Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLA150ChkSt ³ Autor ³Alex Egydio/Fernando Joly³Data³27.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica status do servico para estorno                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Status do servico                                    ³±±
±±³          ³ ExpN1 - Status desejado                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 = .T. indica que esta apto para o estorno              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function DlA150ChkSt(cStatus,nStServ)
Local lRet := .T.
	//-- Status do Servico
	//-- 1-Nao Executados
	//-- 2-Interrompidos
	//-- 3-Ja Executados
	//-- 4-Aptos a Execucao (Nao Executados e Iterrompidos)
	//-- 5-Aptos ao Estorno (Ja Executados e Interrompidos)
	cStatus := If(Empty(cStatus),'1',cStatus)
	If nStServ == 2          //-- Estorna Somente Servicos Interrompidos
		If ! cStatus == '2'
			lRet := .F.
		EndIf
	ElseIf nStServ == 3     //-- Estorna Somente Servicos Ja Executados
		If ! cStatus == '3'
			lRet := .F.
		EndIf
	Elseif nStServ == 5     //-- Estorna Somente Servicos Aptos ao Estorno (Ja Executados e Interrompidos)
		If !(cStatus$'3ú2')
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
Return(lRet)
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DLA150Carga | Autor ³ Alex Egydio             ³Data³27.12.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Se nao houver pedidos com bloqueio de wms na carga, liberar  ³±±
±±³          ³ o DAK.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Codigo da carga                                      ³±±
±±³          ³ ExpA1 - Vetor com os codigos das cargas ja analisadas.       ³±±
±±³          ³         Este vetor foi definido na funcao dla150serv e       ³±±
±±³          ³         eh passado como referencia                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function DLA150Carga(cCarga,aCarga)
Default aCarga := {}
	//-- Se houver carga
	If !Empty(cCarga)
		//-- Se a carga ainda nao foi analisada
		If aScan(aCarga,cCarga) == 0
			aAdd(aCarga,cCarga)
			//-- Analisa todos os pedidos da carga verificando se ha bloqueio de wms
			WmsCarga(cCarga,.F.,{{'BLWMS',{'01'},4}})
		EndIf
	EndIf
Return NIL
//-----------------------------------
/*{Protheus.doc}
Chama relatorio das movimentacoes quando nao utiliza RF MV_RADIOF = 'N'

@author Felipe Machado de Oliveira
@version P12
@Since   05/08/13
@obs Chama relatorio das movimentacoes quando nao utiliza RF MV_RADIOF = 'N'
*/
//-----------------------------------
Static Function ImpriMovim(aDocsDesfr)
Local cServico := ""
Local cTarefa := ""
//Salva as variaveis de parametro do programa
Local cMvAnt01 := MV_PAR01
Local cMvAnt02 := MV_PAR02
Local cMvAnt03 := MV_PAR03
Local cMvAnt04 := MV_PAR04
Local cMvAnt05 := MV_PAR05
Local cMvAnt06 := MV_PAR06
Local cMvAnt07 := MV_PAR07
Local cMvAnt08 := MV_PAR08
Local cMvAnt09 := MV_PAR09
Local cMvAnt10 := MV_PAR10

	DC5->( dbSeek(xFilial('DC5')+aDocsDesfr[1][2]) )
	cServico := DC5->DC5_SERVIC
	cTarefa := DC5->DC5_TAREFA
	
	If MsgYesNo(STR0016,STR0017) //"Deseja imprimir o relatório de movimentações?"##"Atenção"
		WmsR310(.F.,{cServico,cServico,cTarefa,cTarefa,aDocsDesfr[1][1],aDocsDesfr[Len(aDocsDesfr)][1],' ','ZZZZZZ',5,1})
	EndIf
	
	MV_PAR01 := cMvAnt01
	MV_PAR02 := cMvAnt02
	MV_PAR03 := cMvAnt03
	MV_PAR04 := cMvAnt04
	MV_PAR05 := cMvAnt05
	MV_PAR06 := cMvAnt06
	MV_PAR07 := cMvAnt07
	MV_PAR08 := cMvAnt08
	MV_PAR09 := cMvAnt09
	MV_PAR10 := cMvAnt10

Return Nil
//-----------------------------------
/*{Protheus.doc}
Valida se serviço é Desfragmentar Estoque

@author Felipe Machado de Oliveira
@version P12
@Since   25/10/13
@obs Valida se serviço é Desfragmentar Estoque
*/
//-----------------------------------
Static Function a150Desfrg(cServico,cIdDCF)
Local lRet := .F.
Local cAliasDC5 := GetNextAlias()

	cQuery := "SELECT 1 FROM "+RetSqlName("SX5")
	cQuery += " WHERE X5_FILIAL = '"+xFilial("SX5")+"' "
	cQuery += "    AND X5_CHAVE IN (SELECT DC5_FUNEXE FROM "+RetSqlName("DC5")
	cQuery += "                     WHERE DC5_FILIAL='"+xFilial("DC5")+"'"
	cQuery += "                      AND DC5_SERVIC='"+cServico+"'"
	cQuery += "                         AND DC5_ORDEM IN (SELECT DISTINCT(DB_ORDTARE) FROM "+RetSqlName("SDB")
	cQuery += "                                          WHERE DB_FILIAL = '"+xFilial("SDB")+"' AND DB_IDDCF='"+cIdDCF+"'))"
	cQuery += "   AND X5_TABELA = 'L6' AND X5_DESCRI='DLDesfrag()'"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDC5,.T.,.T.)
	
	(cAliasDC5)->(dbGoTop())
	If (cAliasDC5)->(!Eof())
		lRet := .T.
	EndIf
	
	(cAliasDC5)->(dbCloseArea())

Return lRet
//-----------------------------------
/*{Protheus.doc}
Verifica o tamanho das informações contidas no parametro MV_WMSPRIO

@author Felipe Machado de Oliveira
@version P11
@Since   16/12/13
@obs Verifica o tamanho das informações contidas no parametro MV_WMSPRIO
*/
//-----------------------------------
Static Function ChkWmsPrio()
Local lRet := .T.
Local cParam := SuperGetMv("MV_WMSPRIO",.F.,"")
Local aTamSx3 := TamSx3("DB_PRIORI")
Local cCont := ""
Local cError := ""
Local oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})

	dbSelectArea("SDB")
	SDB->(dbGoTop())
	cCont := &cParam
	
	If !Empty(cError)
		lRet := .F.
		MsgInfo(STR0025,"Info") //"Valor inválido rever parâmetro MV_WMSPRIO (Sequência de Prioridade)."
	EndIf
	
	If lRet .And. Len(cCont) > aTamSx3[1]-4
		lRet := .F.
		MsgInfo(WmsFmtMsg(STR0026,{{"[VAR01]",LTrim(Str(aTamSx3[1]-4))}}),"Info") //"Quantidade de caracteres da expressão configurada no parâmetro MV_WMSPRIO (Sequência de Prioridade) é maior que [VAR01]."
	EndIf
	
	ErrorBlock(oLastError)
Return lRet

//-----------------------------------
/*{Protheus.doc}
Altera o Serviço das Ordens de Serviço selecionadas

@author Tiago Filipe da Silva
@version P11
@Since   05/02/14
@obs
*/
//-----------------------------------
Function DLGA150Alt()
Local lRet       := .T.
Local nStServ    := mv_par03
Local cSrvVazio  := Space(Len(DCF->DCF_SERVIC))
Local cTipoServ  := ""
Local cCodServ   := ""
Local cServico   := Space(Len(DCF->DCF_SERVIC))
Local cDoc       := ""
Local cOrigem    := ""
Local lOk        := .T.
Local oDlg, oDlg2, oPanel1, oGet, cAliasDCF

	If nStServ == 1 .OR. nStServ == 4
		cAliasDCF := GetNextAlias()
		cQuery := " SELECT DCF.DCF_SERVIC, DCF.R_E_C_N_O_ RECNODCF FROM "+RetSqlName('DCF')+" DCF"
		cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	
		If mv_par01 == mv_par02
			cQuery += " AND DCF.DCF_SERVIC = '"+mv_par01+"'"
		Else
			cQuery += " AND DCF.DCF_SERVIC BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
		EndIf
	
		If Empty(mv_par01) .Or. Empty(mv_par02)
			cQuery += " AND DCF.DCF_SERVIC <> '"+cSrvVazio+"'"
		EndIf
	
		If nStServ == 1         //-- Executa Somente Servicos ainda Nao Executados
			cQuery += " AND DCF.DCF_STSERV IN (' ','1')"
		ElseIf nStServ == 2     //-- Executa Somente Servicos Interrompidos
			cQuery += " AND DCF.DCF_STSERV = '2'"
		ElseIf nStServ == 4     //-- Executa Somente Servicos Aptos a Execucao (Nao Executados e Iterrompidos)
			cQuery += " AND DCF.DCF_STSERV IN ('1','2')"
		EndIf
	
		cQuery += " AND DCF.DCF_OK = '"+oBrowse:cMark+"'"
		cQuery += " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCF,.F.,.T.)
		//Obtem o primeiro servico para comparacao
		cCodServ   := (cAliasDCF)->DCF_SERVIC
		//Busca o tipo de servico
		dbSelectArea("DC5")
		DC5->(dbSetOrder(1))
		DC5->(dbSeek(xFilial('DC5')+cCodServ))
		cTipoServ := DC5->DC5_TIPO
	
		If (cAliasDCF)->(!Eof())
			While (cAliasDCF)->(!Eof())
				//Verifica se o tipo de servico das ordens de servico selecionadas são
				DC5->(dbGoTop())
				DC5->(dbSeek(xFilial('DC5')+(cAliasDCF)->DCF_SERVIC))
				
				If cTipoServ <> DC5->DC5_TIPO
					lOk := .F.
					Exit
				EndIf
				(cAliasDCF)->(DbSkip())
			EndDo
	
			If lOk
				lAchou := .F.
				While !lAchou
					If ConPad1(,,, 'DC5',,, .F.)
						cServico := DC5->DC5_SERVIC					
						If !Empty(cServico) .AND. ChkTipServ(cServico, cTipoServ)
							lAchou := .T.
						EndIf
					Else
						lAchou := .T.
						lOk    := .F.
					EndIf
				EndDo 
	
				If lOk .And. !Empty(cServico)
					If MsgYesNo(STR0032) //"Todos os itens marcados serao alterados, deseja confimar?"
						(cAliasDCF)->(dbGoTop())
						dbSelectArea('DCF')
						While (cAliasDCF)->(!Eof())
							DCF->( dbGoto((cAliasDCF)->RECNODCF) )
							If DCF->DCF_STSERV == '1' .OR. DCF->DCF_STSERV == '2'
								//Atualiza dados da DCF
								RecLock('DCF',.F.)
								DCF->DCF_SERVIC := cServico
								DCF->(MsUnLock())
								//Atualiza dados das tabelas de Origem do documento
								If DCF->DCF_ORIGEM == 'SD1' //Documentos de Entrada
									dbSelectArea('SD1')
									SD1->(dbSetOrder(4)) //D1_FILIAL+D1_NUMSEQ
									If SD1->(dbSeek(xFilial('SD1')+DCF->DCF_NUMSEQ))
										RecLock('SD1')
										SD1->D1_SERVIC := cServico
										SD1->(MsUnlock())
									EndIf
								ElseIf DCF->DCF_ORIGEM == 'SD3' //Movimentos Internos
									dbSelectArea('SD3')
									SD3->(dbSetOrder(8)) //D3_FILIAL+D3_DOC+D3_NUMSEQ
									If SD3->(dbSeek(xFilial('SD3')+DCF->DCF_DOCTO+DCF->DCF_NUMSEQ))
										RecLock('SD3')
										SD3->D3_SERVIC := cServico
										SD3->(MsUnlock())
									EndIf
								ElseIf DCF->DCF_ORIGEM == 'SC9' //Pedidos de Venda
									//Atualiza dados do documento de saida
									dbSelectArea("SC9")
									SC9-> (dbSetOrder(9)) //C9_FILIAL+C9_IDDCF
									If SC9->(dbSeek(xFilial("SC9")+DCF->DCF_ID))
										RecLock("SC9",.F.)
										SC9->C9_SERVIC := cServico
										SC9->(MsUnlock())
										dbSelectArea("SC6")
										SC6->(dbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
										If DBSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO) .AND. SC9->C9_SERVIC <> SC6->C6_SERVIC
											RecLock("SC6",.F.)
											SC6->C6_SERVIC := SC9->C9_SERVIC
											SC6->(MsUnlock())
										EndIf
									EndIf
								EndIf
							EndIf
							(cAliasDCF)->( dbSkip())
						EndDo
					EndIf
				EndIf
			Else
				Help(,,'HELP',,STR0030,1,0,) //"Ha Ordens de Servico marcadas com Tipo de Servico diferente."
				lRet := .F.
			EndIf
		Else
			Help(,,'HELP',,STR0029,1,0,) //"Nenhuma Ordem de Servico foi selecionada."
		EndIf
	Else
		Help(,,'HELP',,STR0028,1,0,) //"Parametro 'Status do Servico' nao permite alteracao."
		lRet := .F.
	EndIf

Return lRet

//-----------------------------------
/*{Protheus.doc}
Altera o Servico das Ordens de Servico selecionadas

@author Tiago Filipe da Silva
@version P11
@Since   05/02/14
@obs
*/
//-----------------------------------
Static Function DLGA150Ser(cServico)
Local lRet := .T.
Default cServico := ""
	If Empty(cServico)
		Help(,,'HELP',,STR0033,1,0,) //"Campo Servico deve ser diferente de branco."
		lRet := .F.
	EndIf

Return lRet

//-----------------------------------
/*{Protheus.doc}
Verifica se existe alguma atividade da ordem de serviço com status "Em Execução"

@author Guilherme Alexandre Metzger
@version P11
@Since   12/02/14
@obs Verifica se existe alguma atividade da ordem de serviço com status "Em Execução", se existir retorna falso
*/
//-----------------------------------
Function DLA150ChDb(cDocumento,cSerie,cCliFor,cLoja,cServico,cDcfId)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cAliasNew := ''
Local cQuery    := ''

Default cDcfId := ""

	cAliasNew := GetNextAlias()
	cQuery := "SELECT DB_STATUS"
	cQuery +=  " FROM "+RetSqlName('SDB')
	cQuery += " WHERE DB_FILIAL  = '"+xFilial('SDB')+"'"
	cQuery +=   " AND DB_DOC     = '"+cDocumento+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_CLIFOR  = '"+cCliFor+"'"
	cQuery +=   " AND DB_LOJA    = '"+cLoja+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_STATUS  = '3'"
	cQuery +=   " AND DB_IDDCF   = '"+cDcfId+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasNew,.F.,.T.)

	If (cAliasNew)->(!Eof())
		lRet := .F.
	EndIf
	(cAliasNew)->(DbCloseArea())

	RestArea(aAreaAnt)
Return lRet

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkTipServ
Verifica se o tipo de serviço do servico informado é igual ao tipo de serviço das ordens de servico selecionadas
@author felipe.m
@since 23/10/2014
@version 1.0
@param cServico, character, Código do serviço selecionado
@param cTipoServ, character, Tipo de serviço atual
/*/
//-------------------------------------------------------------------------------------------
Static Function ChkTipServ(cServico, cTipoServ)
Local lRet := .T.

	dbSelectArea("DC5")
	DC5->(dbSetOrder(1))
	If DC5->(dbSeek(xFilial('DC5')+cServico))
		If DC5->DC5_TIPO <> cTipoServ
			Help(,,'HELP',,STR0034,1,0,) //"O Tipo do Servico informado difere do tipo de Servico dos itens marcados."
			lRet := .F.
		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} CountDCF
//Função para fazer o count dos registros marcados na DCF
@author roselaine.adriano
@since 21/02/2020
@version 1.0

@type function
/*/
Static Function CountDCF()
Local cWhere   := ""
Local nResultDCF := 0
Local cAliasDCF := "" 
 
	cWhere := "%"
	cWhere += " AND " + DLA150Qry()
	cWhere += "%"
			
	cAliasDCF := GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT COUNT(*) AS CounTDCF
		FROM %Table:DCF% DCF
		WHERE DCF_OK = %EXP:oBrowse:Mark()%
		AND %NotDel%
		%Exp:cWhere%
	EndSql 
	If (cAliasDCF)->(!Eof())
		nResultDCF :=(cAliasDCF)->CounTDCF
	EndIf 
	(cAliasDCF)->(DbCloseArea())
	
Return nResultDCF 
