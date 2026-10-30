#INCLUDE "QIEM040.CH"
#INCLUDE "TOTVS.CH"

#DEFINE NORMAL   "1"
#DEFINE ATRIBUTO "2"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ QIEM040	³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 25/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de geracao das Cartas de Controle				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaQIE													  ³±±
±±³			 ³ Obs.: Se nao especificar a revisao do produto, considera a ³±±
±±³			 ³ revisao vigente na data de Entrada limite (ate), para exi- ³±±
±±³			 ³ bir os ensaios para escolha e para identificar os Limites  ³±±
±±³			 ³ Engenharia. Neste caso (revisao em branco) serao conside-  ³±±
±±³			 ³ radas as medicoes de todas as revisoes que existirem no	  ³±±
±±³			 ³ periodo, mesmo que haja diferenca de especificacao do en-  ³±±
±±³			 ³ saio, de uma revisao para outra. 						  ³±±
±±³			 ³ Obs.: por enquanto, somente estao disponiveis os graficos  ³±±
±±³			 ³ 		das cartas IND, XBR e XBS. 						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data	³ BOPS ³  Motivo da Alteracao 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Vera        ³20/04/99³------³ Inclusao da Loja do Fornecedor           ³±±
±±³CesarValadao³17/09/99³PROTHE³ Retirada a Verificacao de Diretorio.     ³±±
±±³            ³        ³      ³ DiskName() e DiskChange() Nao Suportada. ³±±
±±³Vera        ³13/01/00³------³ Passa LIE,LSE e Nominal como parametro   ³±±
±±³            ³        ³      ³ DiskName() e DiskChange() Nao Suportada. ³±±
±±³Vera        ³13/01/00³------³ Passa LIE,LSE e Nominal como parametro   ³±±
±±³Paulo Emidio³21/05/01³META  ³ Incluida a opcao par selecionar o tipo de³±±
±±³       	   ³		³	   ³ Entrada se a mesma sera:				  ³±±
±±³       	   ³		³	   ³ 1)Normal 2)Beneficiamento 3)Devolucao 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QIEM040()
Local cAlias := Alias()
Local cRevi  := ""
Local cTit   := OemToAnsi(STR0004) // "Cartas de Controle"
Local lCont  := .t.

Private cIndex1
Private nIndex
Private nOpt1  := 1
Private cMarca := GetMark()
Private cLIE := Space(TamSX3("QE7_LIE")[1])
Private cLSE := Space(TamSX3("QE7_LSE")[1])
Private cSenhas := "1"
Private lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A" //controle se executa o grafico modelo novo ou por DLL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecao da geracao das Cartas de Controle:						       ³
//³ mv_par01 = Produto													   ³
//³ mv_par02 = Revisao													   ³
//³ mv_par03 = Fornecedor	   De 										   ³
//³ mv_par04 = Fornecedor	   Ate'                               		   ³
//³ mv_par05 = Data de Entrada De 										   ³
//³ mv_par06 = Data de Entrada Ate'                               		   ³
//³ mv_par07 = Lote			   De 										   ³
//³ mv_par08 = Lote			   Ate'                               		   ³
//³ mv_par09 = Ensaiador 	   De 										   ³
//³ mv_par10 = Ensaiador 	   Ate'                               		   ³
//³ mv_par11 = Laboratorio     De 										   ³
//³ mv_par12 = Laboratorio     Ate'                               		   ³
//³ mv_par13 = Considera Entradas ? 1=Normais 2=Beneficiamento 3=Devolucoes³
//³ mv_par14 = Filial de?                                                  ³
//³ mv_par15 = Filial ate?                                                 ³
//³ mv_par16 = Loja Forn. de                                               ³
//³ mv_par17 = Loja Forn. ate                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Pergunte("QEM040",.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida o Produto / Revisao										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mv_par01 := Upper(mv_par01)
	
	If Empty(mv_par02)	// Nao especificou a revisao
		QE6->(dbSetOrder(1))
		If !QE6->(dbSeek(xFilial("QE6")+mv_par01))
			Help(" ",1,"QIEPRODNAO")   // "Produto nao cadastrado."
			lCont := .F.
		EndIf
	Else
		If !QE6->(dbSeek(xFilial("QE6")+mv_par01+Inverte(mv_par02)))
			Help(" ",1,"QIEPRRVNAO")   // "Produto/Revisao nao cadastrados."
			lCont := .F.
		EndIf
	EndIf

	If lCont
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Identifica a revisao a ser adotada 								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Assume a revisao corrente, caso nao tenha sido especificada.		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(mv_par02)
			cRevi := mv_par02
		Else
			cRevi := QA_UltRevEsp(mv_par01,mv_par06,,,"QIE")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chamada da Funcao para montar o Browse para escolha dos ensaios  ³
		//³ e chamada da funcao para gerar os arquivos	                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M040MontBrw(cRevi,cTit)

	EndIf
Endif
dbSelectArea(cAlias)
Return NIL
            

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M040MontBrw³ Autor ³ Vera Lucia S. Simoes³ Data ³ 25/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta browse para a escolha dos ensaios - MarkBrowse		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ M040MontBrw(ExpC1,ExpC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Revisao											  ³±±
±±³			 ³ ExpC2 = Titulo da Janela									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEM040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M040MontBrw(cRevi,cTit)
Local aButtons   := {}
Local aCpos      := {}
Local aStru      := {}
Local cDir       := ""
Local nOpcA      := 0
Local oDlg       := NIL
Local oLIE       := NIL
Local oLSE       := NIL
Local oMark      := NIL
Local oTempTable := NIL

Private lInverte := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho para a escolha dos ensaios ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TB_OK"      ,  "C",02,0} )
Aadd( aStru,{ "TB_ENSAIO"  ,  "C",TamSX3("QE7_ENSAIO")[1],0} )
Aadd( aStru,{ "TB_DESCRI"  ,  "C",TamSX3("QE1_DESCPO")[1],0} )
Aadd( aStru,{ "TB_CARTA"   ,  "C",TamSX3("QE1_CARTA" )[1],0} )
Aadd( aStru,{ "TB_SELECAO" ,  "C",TamSX3("QE1_CARTA" )[1],0} )
Aadd( aStru,{ "TB_TAMAMO"  ,  "N",TamSX3("QE1_QTDE"  )[1],0} )
Aadd( aStru,{ "TB_LABOR"   ,  "C",TamSX3("QE7_LABOR" )[1],0} )
Aadd( aStru,{ "TB_FILIAL"  ,  "C",TamSX3("QE7_FILIAL")[1],0} )
oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_FILIAL","TB_ENSAIO"} )
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefinicao do aCpos para utilizar no MarkBrow ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCpos := {{"TB_OK"      ,"",OemToAnsi(STR0006)},;	  //"Ok"
	       {"TB_ENSAIO"   ,"",OemToAnsi(STR0007)},;  //"Ensaio"
		   {"TB_DESCRI"   ,"",OemToAnsi(STR0008)},;  //"Descricao"
		   {"TB_CARTA"    ,"",AllTrim(TitSX3("QE1_CARTA")[1])},;
		   {"TB_SELECAO"  ,"",OemToAnsi(STR0015)},;  //"Selecao"
		   {"TB_TAMAMO"   ,"",AllTrim(TitSX3("QE1_QTDE")[1])},;
		   {"TB_LABOR"    ,"",AllTrim(TitSX3("QE7_LABOR")[1])},;
		   {"TB_FILIAL"   ,"",AllTrim(TitSX3("QE7_FILIAL")[1])}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta arquivo temporario com os ensaios dos Produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QE7->(dbSetOrder(1))
QE7->(dbSeek(xFilial("QE7")+mv_par01+cRevi))
While !QE7->(Eof()) .And. (QE7->QE7_FILIAL >= mv_par14 .And. QE7->QE7_FILIAL <= mv_par15);
		.And. QE7->QE7_PRODUT == mv_par01 .And. QE7->QE7_REVI == cRevi
	        
	//Filtra os Laboratorios
	If (QE7->QE7_LABOR < mv_par11) .Or. (QE7->QE7_LABOR > mv_par12)
		QE7->(dbSkip())
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a carta do Ensaio										  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QE1->(dbSetOrder(1))
	QE1->(dbSeek(xFilial("QE1")+QE7->QE7_ENSAIO))

	If QE1->QE1_CARTA $ "IND.XBR.XBS.HIS"
		RecLock("TRB",.T.)
		TRB->TB_ENSAIO := QE7->QE7_ENSAIO
		TRB->TB_DESCRI := QIEXDeEn(QE7->QE7_ENSAIO)
		TRB->TB_LABOR  := QE7->QE7_LABOR
		TRB->TB_TAMAMO := QE1->QE1_QTDE
		TRB->TB_CARTA  := QE1->QE1_CARTA
		TRB->TB_FILIAL := QE7->QE7_FILIAL
		MsUnlock()
	EndIf
	QE7->(dbSkip())
EndDo

dbSelectArea("TRB")
dbGoTop()
If BOF() .and. EOF()
	MessageDlg(OemtoAnsi(STR0013),,3)
Else

	DEFINE MSDIALOG oDlg TITLE cTit From 9,0 To 28,63 OF oMainWnd
	oMark := MsSelect():New("TRB","TB_OK",,acpos,lInverte,cMarca,{35,3,100,245})
	oMark:oBrowse:lCanAllMark:=.T.
	oMark:oBrowse:lHasMark	 :=.T.
	oMark:bMark 			 :={||M040Escol(cMarca,lInverte,oDlg)}
	oMark:oBrowse:bAllMark	 :={||M040MarkAll(cMarca,oDlg)}
	Aadd(aButtons,{"SDUPROP",{||QEBuildGraf(Substr(TRB->TB_ENSAIO,1,8),TRB->TB_CARTA)},OemToAnsi(STR0016),OemToAnsi(STR0022)}) //"Escolha da Carta de Controle..."###"Esc.Cart"
	
	@ 102,2 TO 135,245 LABEL OemToAnsi("") Of oDlg Pixel 
   
	@ 109, 009 Say OemToAnsi(STR0021) Size  50,6 Of oDlg Pixel //"Valor Limite LIC : "
	@ 121, 009 Say OemToAnsi(STR0020) Size  50,6 Of oDlg Pixel //"Valor Limite LSC : "
	
	@ 109,060 MSGET	oLIE VAR cLIE VALID If(!QA_VerNum(@cLIE),(HELP(" ",1,"QA_NUMINV"),.F.),.T.) OF oDlg	PIXEL SIZE 53.5,7
	oLIE:cSX1Hlp := "QE7_LIE"

	@ 121,060 MSGET	oLSE VAR cLSE VALID If(!QA_VerNum(@cLSE),(HELP(" ",1,"QA_NUMINV"),.F.),.T.) OF oDlg	PIXEL SIZE 53.5,7
	oLSE:cSX1Hlp := "QE7_LSE"
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpcA:=0,oDlg:End()},,aButtons)
	If nOpcA == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Obtem o diretorio para a criacao dos arquivos SPC ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDir := GetMv("MV_QDIRGRA")          
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o diretorio do grafico e um  diretorio Local ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !QA_VerQDir(cDir) 
			Return
		EndIf 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Rotina que gera os graficos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M040GerCC(cRevi,cDir)
	Endif
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Arquivo Temporario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable:Delete()
Return Nil


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M040Marca  ³ Autor ³ Vera Lucia S. Simoes³ Data ³ 26/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Avalia Marca.											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEM040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M040Marca()

If LastKey() == K_ENTER
	RecLock("TRB",.F.)
	TRB->TB_OK := Iif(Empty(TRB->TB_OK),cMarca," ")
	MsUnlock()
ElseIf LastKey() == K_ALT_M				// Marca todos
	dbSelectArea("TRB")
	dbGotop()
	While !Eof()
		RecLock("TRB",.F.)
		TRB->TB_OK := cMarca
		MsUnlock()
		dbSkip()
	EndDo
	dbSelectArea("TRB")
	dbGotop()
ElseIf LastKey() == K_ALT_R				// Remove todas as marcas
	dbSelectArea("TRB")
	dbGotop()
	While !Eof()
		RecLock("TRB",.F.)
		TRB->TB_OK := " "
		MsUnlock()
		dbSkip()
	EndDo
	dbSelectArea("TRB")
	dbGotop()
EndIf
Return Nil


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M040Escol  ³ Autor ³ Vera Lucia S. Simoes³ Data ³ 08/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe os Ensaios										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEM040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M040Escol(cMarca,lInverte,oDlg)
iF IsMark("TB_OK",cMarca,lInverte)
	RecLock("TRB",.F.)
	If !lInverte
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
Else
	RecLock("TRB",.F.)
	If !lInverte
		TRB->TB_OK	:= "  "
	Else
		TRB->TB_OK	:= cMarca
	Endif
	MsUnlock()
Endif
oDlg:Refresh()
Return .T.


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M040MarkAll³ Autor ³Vera Lucia S. Simoes ³ Data ³ 08/07/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inverte os Ensaios Marcados/Desmarcados					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ QIEM040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M040MarkAll(cMarca,oDlg)
Local nRecno:=Recno()
dbGotop()
Do While !Eof()
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		TRB->TB_OK	:= cMarca
	Else
		TRB->TB_OK	:= "  "
	Endif
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
oDlg:Refresh()
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³M040GerCC ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 29/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera arquivo (SPC) para gerar o grafico					  ³±±
±±³			 ³ Gera 1 arquivo para cada ensaio selecionado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ M040GerCC(ExpC1,ExpC2)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Revisao do Produto								  ³±±
±±³			 ³ ExpC2: Diretorio para a geracao dos arquivos SPC			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M040GerCC(cRevi,cDir)
Local aEnsaios   := {}
Local aMed       := {}
Local aMed64     := {}
Local aMedicoes  := {}
Local aMedTmp    := {}
Local aRecTMP    := {}
Local aStru      := {}
Local aTabela    := {}
Local aTitCarCon := {}
Local cArqSPC    := ""
Local cCarta     := ""
Local cCartaOri  := ""
Local cChvMed    := ""
Local cChvQER    := ""
Local cCpo       := ""
Local cEnsaio    := ""
Local cFilEns    := ""
Local cMedi      := ""
Local cModelo    := ""
Local lGera      := .F.
Local lQCALLIM   := SuperGetMV("MV_QCALLIM")
Local lQIEM040F  := ExistBlock("QIEM040F")
Local lQIEM040T  := ExistBlock("QIEM040T")
Local nCnt       := 0
Local nCountGrp  := 0
Local nDec       := 0
Local nI         := 0
Local nLoop      := 0
Local nPos       := 0
Local nQtde      := 1
Local nTamAmo    := 0
Local nX         := 0
Local nY         := 0
Local oDlg       := NIL
Local oLbx       := NIL
Local oTempTable := NIL


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho para guardar as meds. dos ensaios   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TMP_ENSAIO"  ,  "C",TamSX3("QE7_ENSAIO")[1],0} )
Aadd( aStru,{ "TMP_LABOR"   ,  "C",6,0} )
Aadd( aStru,{ "TMP_DTMEDI"  ,  "D",8,0} )
Aadd( aStru,{ "TMP_HRMEDI"  ,  "C",5,0} )
Aadd( aStru,{ "TMP_MEDI01"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI02"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI03"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI04"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI05"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI06"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI07"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI08"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI09"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_MEDI10"  ,  "C",8,0} )
Aadd( aStru,{ "TMP_CARTA"   ,  "C",3,0} )
Aadd( aStru,{ "TMP_CARTOR"  ,  "C",3,0} )
Aadd( aStru,{ "TMP_TAMAMO"  ,  "N",2,0} )
Aadd( aStru,{ "TMP_FILIAL"  ,  "C",FWSIZEFILIAL(),0} )

oTempTable := FWTemporaryTable():New( "TMP" )
oTempTable:SetFields( aStru )
//oTempTable:AddIndex("indice1", {"TMP_FILIAL","TMP_ENSAIO","TMP_DTMEDI","TMP_HRMEDI"} )
oTempTable:Create()

dbSelectArea("TRB")
dbGoTop()
While !Eof()
	If !Empty(TB_OK)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ [1] - Ensaio                            ³
		//³ [2] - Tem Medicoes                      ³
		//³ [3] - Nome do Arquivo                   ³
		//³ [4] - Modelo                            ³
		//³ [5] - Laboratorio                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aEnsaios,{ TB_ENSAIO,.F.,cArqSpc,"",TB_LABOR,TB_CARTA,TB_SELECAO,TB_TAMAMO, TB_FILIAL})
		Aadd(aMed,{})
	EndIf
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona as Entradas com medicoes no periodo				 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QEK->(dbSetOrder(3))
QEK->(dbSeek(xFilial("QEK")+mv_par01+Inverte(mv_par06), .T.))
While !QEK->(Eof()) .And.(QEK->QEK_FILIAL >= mv_par14 .And. QEK->QEK_FILIAL <= mv_par15) .And. ;
		QEK->QEK_PRODUT == mv_par01 .And. QEK->QEK_DTENTR >= mv_par05 .And.;
		QEK->QEK_DTENTR <= mv_par06

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Revisao do Produto									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(mv_par02) .And. QEK->QEK_REVI <> mv_par02
		QEK->(dbSkip())
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Fornecedor											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(mv_par03) .And. QEK->QEK_FORNEC < mv_par03) .Or. ;
		(!Empty(mv_par04) .And. QEK->QEK_FORNEC > mv_par04)
		QEK->(dbSkip())
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Loja Forenecedor  							       	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(mv_par16) .And. QEK->QEK_LOJFOR < mv_par16) .Or. ;
		(!Empty(mv_par17) .And. QEK->QEK_LOJFOR > mv_par17)
		QEK->(dbSkip())
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Lote													  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(mv_par07) .And. QEK->QEK_LOTE < mv_par07) .Or. ;
		(!Empty(mv_par08) .And. QEK->QEK_LOTE > mv_par08)
		QEK->(dbSkip())
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Tipo de Entrada a ser considerada				   	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	If mv_par13 == 1
 		If !(QEK->QEK_TIPONF == "N" .Or. QEK->QEK_TIPONF == " ")
 			QEK->(dbSkip())
 			Loop
 		EndIf   
 		
 	ElseIf mv_par13 == 2
 		If !(QEK->QEK_TIPONF == "B")
 			QEK->(dbSkip())
 			Loop	
 		EndIf

 	ElseIf mv_par13 == 3
 		If !(QEK->QEK_TIPONF == "D")
 			QEK->(dbSkip())
 			Loop
 		EndIf

 	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona as medicoes da Entrada								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChvQER := QEK->QEK_FILIAL+QEK->QEK_PRODUT+QEK->QEK_REVI+QEK->QEK_FORNEC+;
		QEK->QEK_LOJFOR+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE
	QER->(dbSetOrder(1))
	QER->(dbSeek(cChvQER))
	While !QER->(Eof()) .And. QER->QER_FILIAL+QER->QER_PRODUT+QER->QER_REVI+;
		QER->QER_FORNEC+QER->QER_LOJFOR+Dtos(QER->QER_DTENTR)+QER->QER_LOTE == cChvQER

		aMedTmp := {}

		// Verifica o Ensaiador
		If (!Empty(mv_par09) .And. QER->QER_ENSR < mv_par09) .Or. ;
			(!Empty(mv_par10) .And. QER->QER_ENSR > mv_par10)
			QER->(dbSkip())
			Loop
		EndIf

		// Guarda as medicoes de acordo com o ensaio, se ele foi escolhido
		nPos := Ascan(aEnsaios, { |x| Alltrim(x[1]) == Alltrim(QER->QER_ENSAIO) .AND. x[9] == xFilial("QE7") })
		
		If nPos <> 0
			// Posiciona no arquivo de ensaios para saber a carta
			QE1->(dbSetOrder(1))
			QE1->(dbSeek(xFilial("QE1")+QER->QER_ENSAIO))

			// Obtem a chave de ligacao da medicao com os outros arquivos
			cChvMed := QER->QER_CHAVE
			cCartaOri	:= aEnsaios[nPos,6]
			cCarta		:= Iif(Empty(aEnsaios[nPos,7]),aEnsaios[nPos,6],aEnsaios[nPos,7])

			// Grava no arquivo auxiliar de medicoes
			RecLock("TMP", .T.)
			TMP->TMP_FILIAL := QER->QER_FILIAL
			TMP->TMP_ENSAIO := QER->QER_ENSAIO
			TMP->TMP_LABOR  := QER->QER_LABOR
			TMP->TMP_DTMEDI := QER->QER_DTMEDI
			TMP->TMP_HRMEDI := QER->QER_HRMEDI
			TMP->TMP_CARTA	:= cCarta
			TMP->TMP_CARTOR	:= cCartaOri
			TMP->TMP_TAMAMO	:= aEnsaios[nPos,8]

			nPos := 0
			nPos := ASCAN(aRecTMP, {|x| x[1]+x[2] == TMP->TMP_FILIAL+TMP->TMP_ENSAIO})
			If nPos == 0
				AADD( aRecTMP, {TMP->TMP_FILIAL,;	
								TMP->TMP_ENSAIO,;
								TMP->TMP_LABOR,;	
								TMP->TMP_DTMEDI,;	
								TMP->TMP_HRMEDI,;
								TMP->TMP_CARTA,;	
								TMP->TMP_CARTOR,;	
								TMP->TMP_TAMAMO, {} } )
			EndIf
			// Grava as medicoes
			nI := 1
			// Para cartas C e NP grava o Tamanho da Amostra antes de cada medicao
			If QE1->QE1_CARTA $ "C  .NP "
				TMP->TMP_MEDI01 := StrZero(QE1->QE1_QTDE,8)
				AADD(aMedTmp, TMP->TMP_MEDI01)
				nI++
			EndIf
			
			QES->(dbSetOrder(1))
			QES->(dbSeek(xFilial("QES")+cChvMed))
			While QES->QES_FILIAL+QES->QES_CODMED == xFilial("QES")+cChvMed .And. !QES->(Eof())
				cCpo := "TMP_MEDI"+StrZero(nI,2)
				// Troca "," por "." pq. o WINCEP nao reconhece "," como decimal
				TMP->&(cCpo) := QES->QES_MEDICA

				AADD( aMedTmp, TMP->&(cCpo) )

				QES->(dbSkip())
				nI++
			EndDo

			nPos := 0
			nPos := ASCAN(aRecTMP, {|x| x[1]+x[2] == TMP->TMP_FILIAL+TMP->TMP_ENSAIO})
			If nPos <> 0
				AADD( aRecTMP[nPos, 9], aMedTmp )
			EndIf

		EndIf
		QER->(dbSkip())
	EndDo
	QEK->(dbSkip())
EndDo
QEK->(dbSetOrder(1))

// Gera os arquivos de grafico
FOR nX := 1 TO LEN(aRecTMP)

	cFilEns  := aRecTMP[nX, 1]
	cEnsaio  := aRecTMP[nX, 2]
	cLabor	 := aRecTMP[nX, 3]
	cCarta	 := aRecTMP[nX, 6]
	cCartaOri:= aRecTMP[nX, 7]

	//Posiciona a medição no ensaio correto.
	nCnt := Ascan(aEnsaios,{|x| Substr(x[1],1,8) == cEnsaio .And. x[9] == xFilial("QE7") })

	if nCnt == 0
		TMP->(dbSkip())
		Loop
	EndIf

	Aadd(aMed64,{AllTrim(xFilial("QE7")) +" - "+ AllTrim(cEnsaio), {}})

	QE1->(dbSetOrder(1))
	QE1->(dbSeek(xFilial("QE1")+cEnsaio))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o modelo do grafico e a quantidade de medicoes			  ³
	//³ IND = 5 														  ³
	//³ XBR = 6 														  ³
	//³ XBS = 7 														  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nQtde := QE1->QE1_QTDE	// Qtde de Medicoes

	Do Case
		Case aRecTMP[nX, 6] == 'XBR'
				cModelo := "6"
		Case aRecTMP[nX, 6] == 'XBS'
				cModelo := "7"
		Case aRecTMP[nX, 6] == 'IND'
				cModelo := "5"
			If cCarta == cCartaOri
				nQtde := 1
			EndIf
	EndCase
	nQtdeOri	:= nQtde
	nTamAmo	    := aRecTMP[nX, 8]//TMP->TMP_TAMAMO

	// Identifica o no. de casas decimais
	QE7->(dbSetOrder(1))
	QE7->(dbSeek(xFilial("QE7")+mv_par01+cRevi+cEnsaio))
	nDec := QA_NumDec(QE7->QE7_NOMINA)

	// Monta vetor com os valores das medicoes e checa as menores/maiores datas
	aMedicoes := {}
	Aadd(aMedicoes,"QACHART.DLL - NORMAL")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Indica se os Limites serao recalculados na Carta de Controle					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cLSE) .And. Empty(cLIE) .And. !lQCALLIM // Verifica o parametro somente quando os limites manuais nao forem informados
		Aadd(aMedicoes,"[CALCULA LIMITE]")
		Aadd(aMedicoes,"FALSE")	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o LSE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aMedicoes,"[USL]")
	If Empty(cLSE)
		Aadd(aMedicoes,StrTran(Str(SuperVal(If(!Empty(QE7->QE7_LSC),QE7->QE7_LSC,QE7->QE7_LSE)),8,nDec),".",","))
	Else
		Aadd(aMedicoes,StrTran(Str(SuperVal(cLSE),8,nDec),".",","))
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o LIE  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aMedicoes,"[LSL]")
	If Empty(cLIE)
		Aadd(aMedicoes,StrTran(Str(SuperVal(If(!Empty(QE7->QE7_LIC),QE7->QE7_LIC,QE7->QE7_LIE)),8,nDec),".",","))
	Else
		Aadd(aMedicoes,StrTran(Str(SuperVal(cLIE),8,nDec),".",","))
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o Nominal ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aMedicoes,"[TARGET]")
	Aadd(aMedicoes,StrTran(Str(SuperVal(QE7->QE7_NOMINA),8,nDec),".",","))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto Entrada para impressao do titulo no grafico.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQIEM040T
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Titulo  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aMedicoes,"[TITLE]")
		Aadd(aMedicoes,ExecBlock("QIEM040T",.F.,.F.))
	EndIf  

	Aadd(aMedicoes,"[LANGUAGE]")
	Aadd(aMedicoes,Upper(__Language) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto Entrada para impressao do titulo no grafico.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lQIEM040F
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Rodape  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(aMedicoes,"[FOOT]")
		Aadd(aMedicoes,ExecBlock("QIEM040F",.F.,.F.))
	EndIF
	
	Aadd(aMedicoes,"[INICIO DE DADOS]")
	nAmostra:= 0

	nPos := 0
	nPos := ASCAN(aRecTMP, {|x| ALLTRIM(x[1])+ALLTRIM(x[2])+ALLTRIM(x[3]) == ALLTRIM(cFilEns)+ALLTRIM(cEnsaio)+ALLTRIM(cLabor)})
	If nPos <> 0
		For nY := 1 To Len(aRecTMP[nPos, 9])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua controle caso haja troca da Carta de Controle para visualizacao do Grafico³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aRecTMP[nPos, 6] <> aRecTMP[nPos, 7] 
				If aRecTMP[nPos, 7]  == "IND"
					nQtde := 1
					nCountGrp:= 0
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta vetor com os valores das medicoes ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMedi := StrZero(Day(aRecTMP[nPos,4]),2)+"/"+;
						StrZero(Month(aRecTMP[nPos,4]),2)+"/"+Str(Year(aRecTMP[nPos,4]),4)+;
						Substr(aRecTMP[nPos,5],1,3)+StrZero(nCountGrp,2)	
			
			Aadd(aMed[nCnt],{})
			nAmostra++
			For nLoop := 1 to nQtde
				cCpo := "TMP_MEDI"+StrZero(nLoop,2)
				cMedicao := cMedi+StrTran(AllTrim(aRecTMP[nPos,9,nY,nLoop]),".",",")
				Aadd(aMedicoes,cMedicao)
				Aadd(aMed[nCnt,nAmostra],StrTran(AllTrim(aRecTMP[nPos,9,nY,nLoop]),".",","))
				Aadd(aMed64[LEN(aMed64)][2],StrTran(AllTrim(aRecTMP[nPos,9,nY,nLoop]),".",","))
			Next

		Next nY

	EndIf
	Aadd(aMedicoes,"[FIM DE DADOS]")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reavalia o Tamanho da Amostra caso seja alterada a carta.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCarta <> cCartaOri
		nQtde := Iif(nTamAmo>0,nTamAmo,1)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava o tamanho do sub-grupo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(aMedicoes,"[SUBGRUPO]")
	Aadd(aMedicoes,Str(nQtde,4)) // Tamanho do Subgrupo para o grafico Ind eh 1 mesmo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o ensaio apresenta mais de 2 sub-grupos de medicoes,³
	//³ necessarios para a geracao dos graficos.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aMedicoes) > 7	// Header, Linha de Inicio e Fim de Dados

		nPos := Ascan(aEnsaios, { |x| x[1] == cEnsaio .AND. x[9] == xFilial("QE7")})
		If nPos <> 0

			// Atualiza aEnsaios indicando que tem medicoes suficientes p/ o grafico
			aEnsaios[nPos][2] := .T.
			
			// Identifica o modelo do grafico
			aEnsaios[nPos][4] := cModelo
		EndIf

		IF !lExistChart
			// Gera o nome do arquivo SPC
			cArqSPC := M040NoArq(cDir)

			If !Empty(cArqSPC)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o arquivo SPC ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lGera := GeraTxt32(aMedicoes ,cArqSPC, cDir)

				If !lGera
					Exit
				EndIf

				// Atualiza o nome do arquivo SPC gerado no array de ensaios
				If nPos <> 0
					aEnsaios[nPos][3] := cArqSpc
				EndIf
			EndIf
		Else
			lGera := .T.
		EndIF
	EndIf
NEXT nX

If lGera
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega array para o ListBox somente os que estao marcados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nLoop := 1 to Len(aEnsaios)
		If aEnsaios[nLoop][2]
			Aadd( aTabela, {AllTrim(aEnsaios[nLoop][9])+" - "+AllTrim(aEnsaios[nLoop][1]), aEnsaios[nLoop][3], aEnsaios[nLoop][4]} )

			lXbXbr := .F.

			If (aEnsaios[nLoop][6] == "XBS" .And. Empty(aEnsaios[nLoop][7])) .Or. aEnsaios[nLoop][7] == "XBS"
				aTitCarCon := {"Media", "Desvio Padrao"}
				lXbXbr := .T.
			ElseIf (aEnsaios[nLoop][6] == "XBR" .And. Empty(aEnsaios[nLoop][7])) .Or. aEnsaios[nLoop][7] == "XBR"
				aTitCarCon := {"Media", "Amplitude"}
				lXbXbr := .T.
			Else
				aTitCarCon := {"Valores Individuais", "Amplitude Movel"}
			EndIf
			
			If nLoop == 1
				aMed64 := {}
			EndIf
			AADD( aMed64, {aTabela[nLoop, 1], QIEA215Med(aMed[nLoop]), aMed[nLoop], aTitCarCon, lXbXbr, aEnsaios[nLoop,8]} )
			AADD(aMed64[LEN(aMed64)], aEnsaios[nLoop][6]) //Carta do Ensaio
			AADD(aMed64[LEN(aMed64)], aEnsaios[nLoop][7]) //Carta Escolhida

		EndIf
	Next nLoop
	
	If Len(aTabela) > 0

		nPosTar := ASCAN( aMedicoes, "[TARGET]" ) + 1
		nPosLSL := ASCAN( aMedicoes, "[LSL]" ) + 1
		nPosUSL := ASCAN( aMedicoes, "[USL]" ) + 1
		aLimites := {}
		aLimites := {SUPERVAL(aMedicoes[nPosTar]), SUPERVAL(aMedicoes[nPosLSL]), SUPERVAL(aMedicoes[nPosUSL])}
				
		DEFINE MSDIALOG oDlg FROM	18,16 TO 246,561 TITLE OemToAnsi(STR0011) PIXEL // "Dados gerados"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Controle para abertura do grafico. Caso o grafico fique aberto por mais de 3 minutos ³
		//³ nao perca a conexao.																 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PtInternal(9,"FALSE")
		
		If lExistChart
			@ 0.3,0.3 LISTBOX oLbx FIELDS HEADER AllTrim(TitSX3("QE1_FILIAL")[1])+" - "+AllTrim(TitSX3("QE1_ENSAIO")[1]),OemToAnsi(STR0012);	// "Arquivo"
				SIZE 240,100 OF oDlg ON DBLCLICK (QIEMGRAFIC(aMed64[Ascan(aMed64, {|x| x[1] == aTabela[oLbx:nAt,1]}), 2], 1, aMed64[Ascan(aMed64, {|x| x[1] == aTabela[oLbx:nAt,1]}),3], aMed64[Ascan(aMed64, {|x| x[1] == aTabela[oLbx:nAt,1]}),4], aLimites,,,aMed64[Ascan(aMed64, {|x| x[1] == aTabela[oLbx:nAt,1]}), 5]), .T.)
		Else
			@ 0.3,0.3 LISTBOX oLbx FIELDS HEADER AllTrim(TitSX3("QE1_FILIAL")[1])+" - "+AllTrim(TitSX3("QE1_ENSAIO")[1]),OemToAnsi(STR0012);
				SIZE 240,100 OF oDlg ON DBLCLICK IIf(QGerGraf(aMedicoes, aEnsaios), Calldll32("ShowChart",aTabela[oLbx:nAt,2],aTabela[oLbx:nAt,3],cDir,NORMAL,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO")), .T.)
		EndIf
		oLbx:SetArray( aTabela )
		oLbx:bLine := { || {aTabela[oLbx:nAT,1],aTabela[oLbx:nAT,2]} }

		If lExistChart
			DEFINE SBUTTON FROM 05, 243 TYPE 1 ENABLE OF oDlg Action (QIEMGRAFIC(aMed64[Ascan(aMed64, {|x| x[1] == aTabela[oLbx:nAt,1]}), 2], 1, aMed64[Ascan(aMed64, {|x| x[1] == aTabela[oLbx:nAt,1]}), 3], aMed64[Ascan(aMed64, {|x| x[1] == aTabela[oLbx:nAt,1]}), 4], aLimites,,,aMed64[Ascan(aMed64, {|x| x[1] == aTabela[oLbx:nAt,1]}), 5]), .T.)
		Else
			DEFINE SBUTTON FROM 05, 243 TYPE 1 ENABLE OF oDlg Action IIf(QGerGraf(aMedicoes, aEnsaios), Calldll32("ShowChart",aTabela[oLbx:nAt,2],aTabela[oLbx:nAt,3],cDir,NORMAL,Iif(!Empty(cSenhas),Encript(Alltrim(cSenhas),0),"PADRAO")), .T.)
		EndIf

		DEFINE SBUTTON FROM 18, 243 TYPE 2 ENABLE OF oDlg Action oDlg:End()

		If lExistChart
			@ 031,243 BUTTON oBtn3 PROMPT OemToAnsi(STR0024) OF oDlg PIXEL SIZE 30,13 ; //"Histograma"
			ACTION QIEMGRAFIC(aMed64[oLbx:nAt, 2], 3, aMed64[oLbx:nAt, 3],,aLimites,,,aMed64[oLbx:nAt, 5],,aMed64[oLbx:nAt, 7],aMed64[oLbx:nAt, 8],aMed64[oLbx:nAt, 6])

			oBtn3:lReadOnly := .F.
		EndIf

		ACTIVATE MSDIALOG oDlg CENTERED

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui os arquivos (SPC) gerados agora ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A040DelSpc( cDir, aTabela )
		PtInternal(9,"TRUE")

	Else
		MessageDlg(OemtoAnsi(STR0013),,3)	// "Não há ensaios com medições suficientes para gerar o gráfico."
		
	Endif
Else
	MessageDlg(OemtoAnsi(STR0013),,3)	// "Não há ensaios com medições suficientes para gerar o gráfico."
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o arquivo auxiliar ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTempTable:Delete()

Return NIL


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³M040NoArq ³ Autor ³ Vera Lucia S. Simoes  ³ Data ³ 30/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera nome do arquivo SPC									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM040													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M040NoArq(cDir)

Local cArq	:= ""
Local nI 	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o arquivo disponivel com extensao SPC ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 to 99999
	cArq := "QIE" + StrZero(nI,5) + ".SPC"
	If !File(Alltrim(cDir)+cArq)
		Exit
	EndIf
Next nI

Return cArq


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³A040DelSpc³ Autor ³ Fernando Godoy		³ Data ³ 1/26/1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Deleta os arquivos SPC gerados 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Diretorio dos SPC									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function A040DelSpc( cDir, aTabela )
AEval(aTabela, {|aFile| Ferase(cDir+aFile[2])})
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QEBuildGraf ³ Autor ³Eduardo de Souza       ³ Data ³ 10/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o tipo da Carta que sera apresentada no Grafico.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QEBuildGraf(ExpC1,ExpC2)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Ensaio                                               ³±±
±±³          ³ ExpC2 - Tipo de Carta                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM040                              				        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QEBuildGraf(cEnsaio,cCarta)

Local oDlg
Local oPanel
Local oRadio
Local oTamAmo
Local nRadio
Local cRadCarta	:= "INDXBRXBS"
Local nOpca		:= 0
Local nTamAmo	:= CriaVar("QE1_QTDE")
Local aCords	:= {0,0,100,120}

cRadCarta	:= StrTran(cRadCarta,cCarta,"")


//- Coordenadas da area total da Dialog
oSize:= FWDefSize():New()
oSize:AddObject("TEXT",100,30,.T.,.T.)
oSize:AddObject("RADIO",100,30,.T.,.T.)
oSize:AddObject("GET",100,40,.T.,.T.)
oSize:SetWindowSize(aCords)
oSize:lProp 	:= .T.      
oSize:aMargins := {5,5,5,5}      
oSize:Process()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o Tamanho da Amostra com 5      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTamAmo := Iif(Substr(cRadCarta,1,3) == "IND",1,5)

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0017) From 19,0 To 31.5,46 OF oMainWnd //"Selecao da Carta de Controle"

@ oSize:GetDimension("TEXT","LININI"),oSize:GetDimension("TEXT","COLINI")      SAY cEnsaio SIZE 40,7 OF oDlg PIXEL COLOR CLR_BLUE // Ensaio
@ oSize:GetDimension("TEXT","LININI"),oSize:GetDimension("TEXT","COLINI")+48   SAY cCarta  SIZE 20,7 OF oDlg PIXEL COLOR CLR_BLUE //Carta

@ oSize:GetDimension("RADIO","LININI"),oSize:GetDimension("RADIO","COLINI")       SAY OemToAnsi(STR0018) SIZE 150,7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //'Selecione o tipo do grafico:'
@ oSize:GetDimension("RADIO","LININI")+10,oSize:GetDimension("RADIO","COLINI")+5  Radio oRadio VAR nRadio ITEMS Substr(cRadCarta,1,3),Substr(cRadCarta,4,6) 3D ;
			ON CLICK QEChgRadio(nRadio,cRadCarta,@nTamAmo,@oTamAmo)  SIZE 50,10 OF oDlg PIXEL

@ oSize:GetDimension("GET","LININI")+30,oSize:GetDimension("GET","COLINI")	   SAY OemToAnsi(STR0019) SIZE 80, 7 OF oDlg PIXEL FONT oFont COLOR CLR_BLUE //"Tamanho das Amostras:"
@ oSize:GetDimension("GET","LININI")+30,oSize:GetDimension("GET","COLINI")+80  MSGET oTamAmo VAR nTamAmo	PICTURE "99" Valid QEVldTam(nTamAmo) SIZE 20, 9 OF oDlg PIXEL
oTamAmo:cSX1Hlp := "QE1_QTDE"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa na primeira vez que montar o objeto Radio. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
QEChgRadio(nRadio,cRadCarta,@nTamAmo,oTamAmo)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||nOpca:=0,oDlg:End()})

If nOpca == 1
	RecLock("TRB",.F.)
	TRB->TB_SELECAO	:= Iif(nRadio==1,Substr(cRadCarta,1,3),Substr(cRadCarta,4,6))
	TRB->TB_TAMAMO	:= nTamAmo
	MsUnlock()
EndIf

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QEChgRadio  ³ Autor ³Eduardo de Souza       ³ Data ³ 10/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza o Tamanho da Amostra conforme a Carta               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QEChgRadio(ExpN1,ExpC1,ExpN2,ExpO1)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao do Radio                                     ³±±
±±³          ³ ExpC1 - Tipo da Carta                                        ³±±
±±³          ³ ExpN1 - Numero de Amostras                                   ³±±
±±³          ³ ExpO1 - Objeto                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM040                							            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QEChgRadio(nRadio,cRadCarta,nTamAmo,oTamAmo)

If nRadio == 1 .And. Substr(cRadCarta,1,3) == "IND"
	nTamAmo	:= 1
	oTamAmo:Disable()
	oTamAmo:Refresh()
Else
	nTamAmo	:= 5
	oTamAmo:EnaBle()
	oTamAmo:Refresh()
EndIf

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QEVldTam    ³ Autor ³Eduardo de Souza       ³ Data ³ 10/03/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o Tamanho da Amostra - Devera estar entre 5 e 10      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QEVldTam(ExpN1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Tamanho da Amostra                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM040               								        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function QEVldTam(nTamAmo)

Local lRet	:= .T.
If nTamAmo < 2 .Or. nTamAmo > 10
	Help(" ",1,"QPNTAMAMO")
	lRet	:= .F.
EndIf

Return(lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QGerGraf    ³ Autor ³Marcelo Cardoso        ³ Data ³ 06/02/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Verifica se o Ensaio tipo IND possui ao menos 4 medicoes     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QGerGraf(ExpA1, ExpA2)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 - Medicoes                                             ³±±
±±           ³ ExpA2 - Ensaios                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QIEM040               								        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QGerGraf(aMedica, aEnsaia)
	
	Local nMd 		:= 1
	Local nEn 		:= 1
	Local lDados 	:= .F.
	Local nMedicas  := 0
	Local lInd     	:= .F.
	Local lOkGraf   := .T.
	
	If Len(aMedica) > 0
	
		For nMd := 1 To Len(aMedica)
			
			If aMedica[nMd] == "[INICIO DE DADOS]"
				lDados := .T.
				Loop
			EndIf
			
			If aMedica[nMd] == "[FIM DE DADOS]"
				lDados := .F.
				Loop
			EndIf

			If lDados
				nMedicas += 1
			EndIf 		
			
		Next
		
	EndIf
	
	If Len(aEnsaia) > 0
	
		For nEn := 1 To Len(aEnsaia)
			
			If aEnsaia[nEn][6] == "IND"
				lInd 		:= .T.
			EndIf
			
		Next
		
	EndIf
	
	If lInd .and. nMedicas < 4
		
		FwAlertError(STR0023, STR0010) //"Atenção" // "Não é possível gerar o gráfico. Ensaios tipo IND requerem ao menos 4 medições." 
		
//		Aviso(STR0010, STR0023, {STR0006}) //"Atenção" // "Não é possível gerar o gráfico. Ensaios tipo IND requerem ao menos 4 medições." // "OK" 
		lOkGraf := .F.	
		
	EndIf 
	
Return(lOkGraf)

/*/{Protheus.doc} QIEA215Med
Retorna um array contendo a media das medições da linha da medição do ensaio XBS/XBS
@type  Static Function
@author rafael.kleestadt
@since 10/08/2020
@version 1.0
@param aArrMedic, array, matriz xy contendo as medições
@return aRet, array, array contendo a média das medições
@example
(examples)
@see (links_or_references)
/*/
Function QIEA215Med(aArrMedic)
Local nX     := 0
Local nY     := 0
Local nSoma  := 0
Local cMedia := ""
Local aRet   := {}

FOR nX := 1 TO LEN(aArrMedic)
	nSoma := 0
	FOR nY := 1 TO LEN(aArrMedic[nX])
		nSoma += SUPERVAL(aArrMedic[nX, nY])
	NEXT nY
	cMedia := CVALTOCHAR( nSoma / LEN(aArrMedic[nX]) )
	AADD(aRet, cMedia)
NEXT Nx
	
Return aRet
