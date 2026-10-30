#include "protheus.ch"
#include "gema103.ch"

#define TIT_LENGHT     20

#define TIT_SELECT       1
#define TIT_ITEMPARCELA  2
#define TIT_TIPO         3
#define TIT_VENCTO       4
#define TIT_PRINCIPAL    5
#define TIT_JUROSFCTO    6
#define TIT_CMPRINCIPAL  7
#define TIT_CMJUROSFCTO  8
#define TIT_PRORATA      9
#define TIT_JUROSMORA   10
#define TIT_MULTA       11
#define TIT_DESCONTO    12
#define TIT_ABONO       13
#define TIT_VLRTITULO   14
#define TIT_PERCJUROS   15
#define TIT_PERCMULTA   16
#define TIT_PERCDESC    17
#define TIT_PREFIXO     18
#define TIT_NUMERO      19
#define TIT_PARCELA     20

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMA103   ºAutor  ³Reynaldo Miyashita  º Data ³  04.05.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento de quitacao de titulos, seja por antecipacao    º±±
±±º          ³ ou atraso.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMA103(cAlias,nReg,nOpc)
Local aArea := GetArea()

Private aRotina := {{ OemToAnsi(STR0001), "AxPesqui"    ,0,1},; //"Pesquisar"
                    { OemToAnsi(STR0002), "T_GMA103Dlg" ,0,2},; //"Visualizar"
                    { OemToAnsi(STR0003), "T_GMA103Dlg" ,0,4},; //"Simular"
                    { OemToAnsi(STR0004), "T_GMA105Dlg" ,0,6},; //"Quitar/Estornar"
                    { OemToAnsi(STR0055), "T_GMA105Dlg" ,0,7} } //"Cancelar"

Private cCadastro := OemToAnsi(STR0005) //"Renegociacao de parcelas"

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereca para a funcao MBrowse                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("LIT")
dbSetOrder(1)
MsSeek(xFilial("LIT"))
mBrowse(06,01,22,75,"LIT",,,,"LIT_STATUS == '1'")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura a Integridade da Rotina                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("LIT")
dbSetOrder(1)
dbClearFilter()

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GMA103Dlg ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 13.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina de Renegociacao de parcelas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³T_GMA103Dlg()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function GMA103Dlg(cAlias,nReg,nOpc)

Local lA103Inclui := .F.
Local lA103Visual := .F.
Local lA103Altera := .F.
Local lA103Exclui := .F.
Local lContinua   := .T.
Local lOk         := .F.
Local lPendente   := .F.

Local nRecLIZ     := 0
Local nX          := 0
Local nY          := 0
Local nCount      := 0

Local dHabite     := sTod("")

Local aDefFields  := {}
Local aSize       := {}
Local aObjects    := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aButtons    := {}
Local aUsrButtons := {}
Local aTitSelect  := {}
Local aArea       := GetArea()

Local oDlg 
Local oPainel
Local oPanel1
Local oPanel2
Local oOk := LoadBitmap( GetResources(), "LBOK" )
Local oNo := LoadBitmap( GetResources(), "LBNO" )

Local oChkPRatAtr
Local oChkProRata
Local oChkDescto
Local oGetPerc
Local oChkVenc
Local oChkJuros
Local oChkJurMora
Local oChkMulta
Local oGet1
Local oGet2
Local oGet3

Local oSay1Parc
Local oSal1Pena
Local oSay1Desc
Local oSay1Nego
Local oSay1Sald
Local oSay2Parc
Local oSay2Pena
Local oSay2Sald
Local oSayBco
Local oSayAgenc
Local oSayConta 

Private aGets[0]
Private aTela[0][0]
Private oEnch 
Private oLBoxTit
Private oGet1Parc 
Private oGet1Pena 
Private oGet1Desc 
Private oGet1Nego 
Private oGet2Parc
Private oGet2Pena
Private oGet2Sald
Private oGetBco
Private oGetAgenc
Private oGetConta 

Private aTitulos     := {}
Private lPRatAtr     := .F.
Private lDescto      := .F.
Private lVenc        := .F.
Private lJurosFcto   := .F.
Private lJurMora     := .T.
Private lMulta       := .T.
Private nPerDesc	 := 0
Private nVlrDesc	 := 0
Private nMaxDesc	 := 0
Private n1Parcela	 := 0
Private n1Penalidade := 0
Private n1Desconto   := 0
Private n1Negociado  := 0
Private a1AcuDesc    := {}
Private n2Parcela    := 0
Private n2Penalidade := 0
Private n2Total      := 0  

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case (aRotina[nOpc][4] == 2)
		lA103Visual := .T.
	Case (aRotina[nOpc][4] == 3)
		Inclui		:= .T.
		Altera      := .F.
		lA103Inclui	:= .T.
	Case (aRotina[nOpc][4] == 4)
		Inclui      := .F.
		Altera		:= .T.
		lA103Altera	:= .T.
	Case (aRotina[nOpc][4] == 5)
		lA103Exclui	:= .T.
		lA103Visual	:= .T.
EndCase

// caso exista a rotina, sera incluido os botoes especificos.
If ExistBlock("GMA103BTN")
	If ValType( aUsrButtons := ExecBlock( "GMA103BTN",.F., .F. ) ) == "A"
		aEval( aUsrButtons, { |x| aAdd( aButtons, x ) } )
	EndIf
EndIf

dbSelectArea(cAlias)
(cAlias)->(dbGoto(nReg))         
If (cAlias)->LIT_STATUS <> "1"
	lContinua := .F.
EndIf		

If lContinua

	RegToMemory(cAlias,.F.)

	cContrato := (cAlias)->LIT_NCONTR
	cRevisa   := (cAlias)->LIT_REVISA
	dReneg    := dDatabase

	// Itens do Contrato
	dbSelectArea("LIU")
	dbSetOrder(3) //LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
	dbSeek(xFilial("LIU")+(cAlias)->(LIT_NCONTR))
	While LIU->(!eof()) .AND. (LIU->(LIU_FILIAL+LIU_NCONTR) == (cAlias)->(xFilial(cAlias)+LIT_NCONTR))
		// Unidades
		dbSelectArea("LIQ")
		dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
		If dbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)
		    // Empreendimento
			dbSelectArea("LK3")
			dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
			If dbSeek(xFilial("LK3")+LIQ->LIQ_CODEMP)
				// Juros de desconto por antecipacao    
				nPerDesc := LK3->LK3_JURDESC
				// Juros de desconto maximo por antecipacao    
				nMaxDesc := LK3->LK3_JURMAX
				// Habite do Empreendimento
				dHabite := iIf( !Empty( LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
				
			EndIf
			
		EndIf
		dbSelectArea("LIU")
		dbSkip()
	EndDo

	// Carrega os Titulos
	Processa({||aTitulos := A103LoadTitulo( cContrato ,cRevisa ,dHabite ,@lPendente )},STR0006) //"Selecionando títulos"
	
	If !lPendente
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o calculo automatico de dimensoes de  objetos    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aObjects, {  100 ,075 ,.T. ,.F. } )
		aAdd( aObjects, {  200 ,100 ,.T. ,.F. } )
		aAdd( aObjects, {  300 ,100 ,.T. ,.F. ,.T. } )
		aSize   := MsAdvSize()
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
		aPosObj := MsObjSize( aInfo ,aObjects ,.T. )
	
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
	                                                                              
		//
		// Painel 
		// 
		oGetCab := MsMGet():New("LIT",LIT->(RecNo()),1,,,,{"LIT_NCONTR" ,"LIT_REVISA" ,"LIT_CLIENT" ,"LIT_LOJA" ,"LIT_NOMCLI"  },aPosObj[1],,3,,,,oDlg,,,,,,.T.)
		oGetCab:oBox:Align := CONTROL_ALIGN_TOP
	
		//
		// Painel com listbox dos titulos a receber
		// 
		oPanel1 := TPanel():New( aPosObj[2,1] ,aPosObj[2,2] ,'' ,oDlg ,/*Fonte*/ ,.T. ,.T. ,,,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],.T.,.T. )
		oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
		
		@005,005 LISTBOX oLBoxTit FIELDS HEADER  " ", STR0007, STR0008, STR0009, ; //"Parcela"###"Tipo"###"Vencto"
		                                              STR0010, STR0011, STR0012, STR0013, ; //"Principal"###"Juros Fcto"###"CM"###"Pro Rata"
		                                              STR0014, STR0015, STR0016, STR0017  ; //"Juros Mora"###"Multa"###"Desconto"###"Total"
		                          SIZE 370,140 OF oPanel1 PIXEL ;
		                          ON DBLCLICK( DlgTit( @aTitulos ,oLBoxTit:nAt ) ,A103Refresh() )
	
		oLBoxTit:SetArray( aTitulos )
		oLBoxTit:bLine := {|| { Iif(aTitulos[oLBoxTit:nAt][TIT_SELECT ],oOk,oNo) ,;
		                        aTitulos[oLBoxTit:nAt][TIT_ITEMPARCELA ]                                  ,aTitulos[oLBoxTit:nAt][TIT_TIPO      ] ,;
		                        aTitulos[oLBoxTit:nAt][TIT_VENCTO  ]                                      ,Transform( aTitulos[oLBoxTit:nAt][TIT_PRINCIPAL ] ,x3Picture("E1_VALOR")) ,;
		                        Transform( aTitulos[oLBoxTit:nAt][TIT_JUROSFCTO ] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oLBoxTit:nAt][TIT_CMPRINCIPAL]+aTitulos[oLBoxTit:nAt][TIT_CMJUROSFCTO],x3Picture("E1_VALOR")) ,;
	 			                Transform( aTitulos[oLBoxTit:nAt][TIT_PRORATA   ] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oLBoxTit:nAt][TIT_JUROSMORA ] ,x3Picture("E1_VALOR")) ,;
	 			                Transform( aTitulos[oLBoxTit:nAt][TIT_MULTA     ] ,x3Picture("E1_VALOR")) ,Transform( aTitulos[oLBoxTit:nAt][TIT_DESCONTO  ] ,x3Picture("E1_VALOR")) ,;
	 			                Transform( aTitulos[oLBoxTit:nAt][TIT_VLRTITULO ] ,x3Picture("E1_VALOR")) }}
	 			                
		oLBoxTit:Align := CONTROL_ALIGN_ALLCLIENT
		
		// monta o painel com os totais
		oPanel2 := TPanel():New( aPosObj[3,1] ,aPosObj[3,2] ,'' ,oDlg ,/*Fonte*/ ,.T. ,.T. ,,,aPosObj[3,3] ,aPosObj[3,4] ,.T. ,.T. )
		oPanel2:Align := CONTROL_ALIGN_BOTTOM
	    
		//
		// Quadro com os Parametros da renegociacao
		//
		nX := 0
		nY := 5
		@nX+05,nY to nX+72,nY+195 PROMPT STR0018 Of oPanel2 PIXEL //" Parametros "
	
	   	@nX+10,nY+05 CHECKBOX oChkDescto   VAR lDescto   PROMPT STR0019 ; //"Conceder % Desconto"
	   	              ON CHANGE {iIf( lDescto ,oGetPerc:Enable(),oGetPerc:Disable()) ,oGetPerc:Refresh() ,A103Refresh() ,.T.} ;
	   	              Of oPanel2 PIXEL SIZE 075,010 WHEN !lA103Visual
	   	@nX+10,nY+080 MSGET oGetPerc VAR nPerDesc ;
	   	              VALID iIf(nPerDesc >= 0 .AND. nPerDesc <= 100 ,(A103Refresh(),.T.),.F.) ;
	   	              PICTURE "@E 999.99" ;
	   	              WHEN lDescto Of oPanel2 PIXEL SIZE 030,010 HASBUTTON
	
			@nX+10,nY+120 CHECKBOX oChkPRatAtr VAR lPRatAtr   PROMPT STR0020 ON CHANGE {a103Refresh() ,.T.} Of oPanel2 PIXEL SIZE 070,010 WHEN !la103Visual //"Aplicar Pro Rata Atraso"
	   	@nX+22,nY+120 CHECKBOX oChkJurMora VAR lJurMora   PROMPT STR0021 ON CHANGE {a103Refresh() ,.T.} Of oPanel2 PIXEL SIZE 070,010 WHEN !la103Visual //"Aplicar Juros Mora"
	   	@nX+34,nY+120 CHECKBOX oChkMulta   VAR lMulta     PROMPT STR0022 ON CHANGE {a103Refresh() ,.T.} Of oPanel2 PIXEL SIZE 070,010 WHEN !la103Visual //"Aplicar Multa"
	   	@nX+46,nY+120 CHECKBOX oChkJuros   VAR lJurosFcto PROMPT STR0023 ON CHANGE {A103Refresh() ,.T.} Of oPanel2 PIXEL SIZE 070,010 WHEN !la103Visual //"Retirar Juros Fcto"
	
		//
		// Quadro com a situação financeiros dos titulos em renegociacao.
		//
		nX := 0
		nY := aPosObj[3,3] - 290
	
	  	@nX+05,nY to nX+72,nY+95 PROMPT STR0024 Of oPanel2 PIXEL  //" NEGOCIADO "
		
		@nX+10,nY+05 SAY oSay1Parc VAR STR0025 Of oPanel2 PIXEL //"Parcelas:"
		@nX+22,nY+05 SAY oSay1Pena VAR STR0026 Of oPanel2 PIXEL //"Penalidades:"
		@nX+34,nY+05 SAY oSay1Desc VAR STR0027 Of oPanel2 PIXEL  //"Descontos:"
		@nX+46,nY+05 SAY oSay1Nego VAR STR0028 Of oPanel2 PIXEL  //"Negociado:"
		
		@nX+10,nY+40 MSGET oGet1Parc VAR n1Parcela	  PICTURE "@E 9,999,999.99" WHEN .F. Of oPanel2 PIXEL SIZE 040,010 
		@nX+22,nY+40 MSGET oGet1Pena VAR n1Penalidade PICTURE "@E 9,999,999.99" WHEN .F. Of oPanel2 PIXEL SIZE 040,010 
		@nX+34,nY+40 MSGET oGet1Desc VAR n1Desconto   PICTURE "@E 9,999,999.99" WHEN .F. Of oPanel2 PIXEL SIZE 040,010 
		@nX+46,nY+40 MSGET oGet1Nego VAR n1Negociado  PICTURE "@E 9,999,999.99" WHEN .F. Of oPanel2 PIXEL SIZE 040,010 

		//
		// Quadro com a situação financeira do contrato.
		//
		If !la103Visual
			nX := 0
			nY := aPosObj[3,3] - 90
		
			@nX+05,nY to nX+72,nY+95 PROMPT STR0029 Of oPanel2 PIXEL //" SALDO DO CONTRATO "
		
			@nX+10,nY+05 SAY oSay2Parc VAR STR0025 Of oPanel2 PIXEL //"Parcelas:"
			@nX+22,nY+05 SAY oSay2Pena VAR STR0026 Of oPanel2 PIXEL //"Penalidades:"
			@nX+34,nY+05 SAY oSay2Sald VAR STR0030 Of oPanel2 PIXEL //"Total do Saldo:"
			                                                           
			n2Total := n2Parcela + n2Penalidade
		
			@nX+10,nY+45 MSGET oGet2Parc VAR n2Parcela    PICTURE "@E 9,999,999.99" WHEN .F. Of oPanel2 PIXEL SIZE 040,010
			@nX+22,nY+45 MSGET oGet2Pena VAR n2Penalidade PICTURE "@E 9,999,999.99" WHEN .F. Of oPanel2 PIXEL SIZE 040,010
			@nX+34,nY+45 MSGET oGet2Sald VAR n2Total      PICTURE "@E 9,999,999.99" WHEN .F. Of oPanel2 PIXEL SIZE 040,010
		Else             
			//
			a103Refresh()
		EndIf
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||iIf( a103VldDlg( n1Parcela ,aTitulos ) ;
									                           ,(lOk := .T.,oDlg:End()) ,Nil ) ;
									                    },{||lOk := .F.,oDlg:End()},,aButtons) VALID lOk
	  
		If lOk .AND. (la103Inclui .Or. la103Altera .Or. la103Exclui)
			// Separa os titulos selecionados
			For nCount := 1 TO Len(aTitulos)
				// Se o Titulo foi selecionado
				If aTitulos[nCount][TIT_SELECT]
					aAdd( aTitSelect ,aTitulos[nCount] )
				EndIf
			Next nCount
			
			If len(aTitSelect) > 0
				Begin Transaction
					Processa({||a103Grava( aTitSelect ,lA103Altera ,lA103Exclui ,nReg ) } ,STR0031 ,STR0032 ,.F.) //"Processando os titulos"###"Aguarde..."
				End Transaction
			EndIf
			
		EndIf
	Else
		Aviso(STR0033 ,STR0034, {STR0035} )  //"Quitacao"###"Existem titulos em negociaçäo para este contrato."###"Ok"
	EndIf		
EndIf

RestArea( aArea )
	
Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a103LoadTi³ Autor ³ Reynaldo Miyashita    ³ Data ³ 04.10.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Carrega os titulos referentes ao contrato                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³a103LoadTitulo()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do Contrato                                     ³±±
±±³          ³ExpC2: Numero da revisao do Contrato                          ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a103LoadTitulo( cContrato ,cRevisa ,dHabite ,lPendente )
Local nVlrProRata   := 0
Local nVlrJurosFcto := 0
Local nVlrPrincipal := 0
Local nVlrParcela   := 0
Local nVlrCMPrinc   := 0
Local nVLrCMJuros   := 0
Local nVlrJurosMora := 0
Local nVlrMulta     := 0
Local nMes          := 0
Local nCntRegua     := 0
Local aAllTits      := {}
Local aRet          := {}
Local aVlrCM        := {}
Local cItParc       := ""
Local lNegociado    := .F.
Local aArea         := GetArea()
Local aAreaSE1      := SE1->(GetArea())
Local aAreaLIX      := LIX->(GetArea())
Local aAreaLJO      := LJO->(GetArea())

DEFAULT lPendente := .F.

	n2Parcela := 0

	nPorcJurMor := LIT->LIT_JURMOR
	nPorcMulta  := LIT->LIT_MULTA

	ProcRegua(100)
	nCntRegua := 0
	
	//
	// Detalhes da parcela
	//
	dbSelectArea("LIX")
	dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO
	MSSeek(xFilial("LIX")+cContrato )
	While LIX->(!Eof()) .AND. LIX->(LIX_FILIAL+LIX_NCONTR)==xFilial("LIX")+cContrato
		IncProc()
		nCntRegua++
		If nCntRegua >100
			ProcRegua(100)
			nCntRegua := 0
		EndIf
			
		// titulos a receber
		dbSelectArea("SE1")
		dbSetOrder(1)
		If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))
			//		
			If SE1->E1_SALDO > 0

				// titulos renegociar
				dbSelectArea("LK7")
				dbSetOrder(1)
				If dbSeek(xFilial("LK7")+LIX->(LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))
				
					lNegociado := (LK7->LK7_APROV == "1")
					If !lPendente .AND. Empty(LK7->LK7_APROV)
						lPendente := .T.
					EndIf
					
				Else
					lNegociado := .F.
				EndIf
				
				If !lNegociado
					aVlrCM      := GEMCmTit( LIX->(Recno()) ,dDatabase )
					cTaxa       := aVlrCM[1]
					nVlrCMPrinc := aVlrCM[2]
					nVlrCMJuros := aVlrCM[3]
					
					//
					// valor do titulo corrigido
					//
					nVlrPrincipal := LIX->LIX_ORIAMO 
					nVlrJurosFcto := LIX->LIX_ORIJUR 
					nVlrParcela   := nVlrPrincipal + nVlrCMPrinc + ; 
					                 nVlrJurosFcto + nVlrCMJuros
					
					nVlrProRata   := 0
					nVlrJurosMora := 0
					nVlrMulta     := 0
		
					// Condicao de venda
					dbSelectArea("LJO")
					dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
					If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND )
						// parcela em atraso, calcula-se a Pro-Rata por atraso diario, Juros Mora e Multa
		                cItParc := LIX->LIX_ITNUM + "/" + STRZERO(LJO->LJO_NUMPAR,TamSX3("LJO_NUMPAR")[1]) + "-" + LJO->LJO_ITEM
		
						If dTos(SE1->E1_VENCREA) < dTos(dDatabase)
					
							If left(dtos(dDatabase),6) > left(dtos(dHabite),6)
								cTaxa := iIf( Empty(cTaxa) ,LJO->LJO_INDPOS ,cTaxa )
								nMes  := LJO->LJO_NMES1
							Else
								cTaxa := iIf( Empty(cTaxa) ,LJO->LJO_IND ,cTaxa )
								nMes  := LJO->LJO_NMES2
							EndIf
							
							//
							// calcula a Pro-Rata Dia de Atraso, Juros mora e Multa do titulo
							//
							aRet := t_GEMAtraCalc( nVlrParcela ,SE1->E1_VENCREA ,cTaxa ,nMes ,LJO->LJO_DIACOR ,nPorcJurMor ,nPorcMulta ,dDataBase ,LIT->LIT_JURTIP ,SE1->E1_BAIXA )
							
							nVlrProRata   := aRet[1] // Pro-Rata dia (CM diaria) por atraso na baixa do titulo 
							nVlrJurosMora := aRet[2] // Juros Mora dia por atraso na baixa do titulo
							nVlrMulta     := aRet[3] // Multa por atraso na baixa do titulo
						EndIf
						
					EndIf
					
					aAdd( aAllTits ,Array(TIT_LENGHT) )
					aAllTits[Len(aAllTits)][TIT_SELECT      ] := lNegociado
					aAllTits[Len(aAllTits)][TIT_ITEMPARCELA ] := cItParc
					aAllTits[Len(aAllTits)][TIT_TIPO        ] := SE1->E1_TIPO   
					aAllTits[Len(aAllTits)][TIT_VENCTO      ] := SE1->E1_VENCTO
					aAllTits[Len(aAllTits)][TIT_PRINCIPAL   ] := nVlrPrincipal
					aAllTits[Len(aAllTits)][TIT_JUROSFCTO   ] := nVlrJurosFcto
					aAllTits[Len(aAllTits)][TIT_CMPRINCIPAL ] := nVlrCMPrinc
					aAllTits[Len(aAllTits)][TIT_CMJUROSFCTO ] := nVlrCMJuros
		
					aAllTits[Len(aAllTits)][TIT_PRORATA     ] := nVlrProRata   
					aAllTits[Len(aAllTits)][TIT_JUROSMORA   ] := nVlrJurosMora  
					aAllTits[Len(aAllTits)][TIT_MULTA       ] := nVlrMulta      
					aAllTits[Len(aAllTits)][TIT_DESCONTO    ] := SE1->E1_DECRESC
					aAllTits[Len(aAllTits)][TIT_ABONO       ] := 0
					aAllTits[Len(aAllTits)][TIT_VLRTITULO   ] := nVlrPrincipal+nVlrJurosFcto;
					                                            +nVlrCMPrinc+nVlrCMJuros;
					                                            +nVlrProRata+nVlrJurosMora+nVlrMulta-SE1->E1_DECRESC
					aAllTits[Len(aAllTits)][TIT_PREFIXO     ] := SE1->E1_PREFIXO
					aAllTits[Len(aAllTits)][TIT_NUMERO      ] := SE1->E1_NUM
					aAllTits[Len(aAllTits)][TIT_PARCELA     ] := SE1->E1_PARCELA
		                                                         
					aAllTits[Len(aAllTits)][TIT_PERCJUROS   ] := nPorcJurMor
					aAllTits[Len(aAllTits)][TIT_PERCMULTA   ] := nPorcMulta
					aAllTits[Len(aAllTits)][TIT_PERCDESC    ] := 0
				EndIf
				
				n2Parcela += SE1->E1_SALDO
			EndIf
		EndIf   
		
		dbSelectArea("LIX")	
		dbSkip()
	EndDo
	
	If len(aAllTits) == 0
		aAdd( aAllTits ,Array(TIT_LENGHT) )
		aAllTits[Len(aAllTits)][TIT_SELECT      ] := .F.            
		aAllTits[Len(aAllTits)][TIT_ITEMPARCELA ] := ""
		aAllTits[Len(aAllTits)][TIT_TIPO        ] := ""
		aAllTits[Len(aAllTits)][TIT_VENCTO      ] := ""
		aAllTits[Len(aAllTits)][TIT_VLRTITULO   ] := 0
		aAllTits[Len(aAllTits)][TIT_PRORATA     ] := 0
		aAllTits[Len(aAllTits)][TIT_JUROSMORA   ] := 0
		aAllTits[Len(aAllTits)][TIT_MULTA       ] := 0
		aAllTits[Len(aAllTits)][TIT_DESCONTO    ] := 0
		aAllTits[Len(aAllTits)][TIT_PRINCIPAL   ] := 0
		aAllTits[Len(aAllTits)][TIT_CMPRINCIPAL ] := 0
		aAllTits[Len(aAllTits)][TIT_JUROSFCTO   ] := 0
		aAllTits[Len(aAllTits)][TIT_CMJUROSFCTO ] := 0
		aAllTits[Len(aAllTits)][TIT_ABONO       ] := 0
		aAllTits[Len(aAllTits)][TIT_PREFIXO     ] := ""
		aAllTits[Len(aAllTits)][TIT_NUMERO      ] := ""
		aAllTits[Len(aAllTits)][TIT_PARCELA     ] := ""
		aAllTits[Len(aAllTits)][TIT_PERCJUROS   ] := 0
		aAllTits[Len(aAllTits)][TIT_PERCMULTA   ] := 0
		aAllTits[Len(aAllTits)][TIT_PERCDESC    ] := 0
	EndIf

restArea(aAreaLJO)
restArea(aAreaLIX)
restArea(aAreaSE1)
restArea(aArea)
		
Return( aAllTits )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a103Refres³ Autor ³ Reynaldo Miyashita    ³ Data ³ 04.10.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza os objetos do painel inferior e o browse            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³a103Refresh()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function a103Refresh(lCalc)
Local nX          := 0
Local nVlrParc    := 0
Local nValor      := 0
Local nPercent    := 0
Local nIndProRata := 0
Local nMeses      := 0

Default lCalc := .T.

	n1Parcela	 := 0
	n1Residuo	 := 0
	n1Penalidade := 0
	n1Desconto   := 0
	n1Negociado  := 0
    
	a1AcuDesc    := Array(4)
	aFill(a1AcuDesc,0)

	For nX := 1 To len(aTitulos)
	
	    // Titulo selecionado
		If aTitulos[nX][TIT_SELECT]
			// Saldo da Parcela 
			nVlrParc := aTitulos[nX ,TIT_PRINCIPAL]+aTitulos[nX ,TIT_JUROSFCTO]+aTitulos[nX ,TIT_CMPRINCIPAL]+aTitulos[nX ,TIT_CMJUROSFCTO]
			n1Parcela += nVlrParc
			
			aTitulos[nX ,TIT_ABONO] := 0
			
			// Retira o Juros da prestacao somente de prestacoes a vencer.
			If lJurosFcto .AND. SubStr(DTOS(aTitulos[nX][TIT_VENCTO]),1,6) > SubStr(DTOS(dDataBase),1,6)
				a1AcuDesc[1] += aTitulos[nX ,TIT_JUROSFCTO]
				a1AcuDesc[1] += aTitulos[nX ,TIT_CMJUROSFCTO]
				aTitulos[nX ,TIT_ABONO] += aTitulos[nX ,TIT_JUROSFCTO]+aTitulos[nX ,TIT_CMJUROSFCTO]
			Endif   
			
			// Se aplica Juros Mora
			n1Penalidade += aTitulos[nX][TIT_JUROSMORA]
			If !lJurMora  
				a1AcuDesc[2] += aTitulos[nX][TIT_JUROSMORA]
				aTitulos[nX ,TIT_ABONO] += aTitulos[nX][TIT_JUROSMORA]
			Endif
			
			// Se aplica Multa
			n1Penalidade += aTitulos[nX][TIT_MULTA]
			If !lMulta
				a1AcuDesc[3] += aTitulos[nX][TIT_MULTA]
				aTitulos[nX ,TIT_ABONO] += aTitulos[nX][TIT_MULTA]
			EndIf
			
			n1Penalidade += aTitulos[nX][TIT_PRORATA]
			If !lPRatAtr
				a1AcuDesc[3] += aTitulos[nX][TIT_PRORATA]
				aTitulos[nX ,TIT_ABONO] += aTitulos[nX][TIT_PRORATA]
			EndIf
			
			If !lDescto
				aTitulos[nX][TIT_DESCONTO] := 0
			Else
				a1AcuDesc[4] += aTitulos[nX][TIT_DESCONTO]
			EndIf
		EndIf
	Next nX
	                   
	aEval( a1AcuDesc,{|nValor| n1Desconto += nValor })
	n1Negociado := NoRound( (n1Parcela+n1Residuo+n1Penalidade)-n1Desconto ,TamSX3("E1_SALDO")[2])
	
	oLBoxTit:refresh()

	oGet1Parc:refresh()
	oGet1Pena:refresh()
	oGet1Desc:refresh()
	oGet1Nego:refresh()
	
Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a103Grava ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 04.10.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os titulos a receber referentes ao contrato            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³a103Grava()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1:                                                        ³±±
±±³          ³ExpL2:                                                        ³±±
±±³          ³ExpL3:                                                        ³±±
±±³          ³ExpL4:                                                        ³±±
±±³          ³ExpN5:                                                        ³±±
±±³          ³ExpN6:                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a103Grava( aTitSelect ,lA103Altera ,lA103Exclui ,nRecLIT )
Local aArea      := GetArea()
Local aAreaLIT   := LIT->(GetArea())
Local aAreaLIX   := LIX->(GetArea())
Local aAreaSE1   := SE1->(GetArea())
Local aAreaLK7   := LK7->(GetArea())

Local nQtdTit    := 0
Local nLoopTit   := 0

Local aAcumula   := {}

If ! lA103Exclui

	If lA103Altera
		// LIT - cadastro de contratos
		dbSelectArea("LIT")
		dbSetOrder(1)
		dbGoTo(nRecLIT)
		
		aAcumula := aClone(a1AcuDesc)
		nQtdTit  := Len(aTitSelect)
		
		// Grava os Titulos renegociados
		For nLoopTit := 1 TO nQtdTit
			// Se o Titulo foi selecionado
			If aTitSelect[nLoopTit][TIT_SELECT]
				
				//
				// Detalhes do titulos a receber
				//
				dbSelectArea("LIX")
				dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO
				If MsSeek( xFilial("LIX")+LIT->LIT_NCONTR+aTitSelect[nLoopTit ,TIT_PREFIXO]+aTitSelect[nLoopTit ,TIT_NUMERO]+aTitSelect[nLoopTit ,TIT_PARCELA]+aTitSelect[nLoopTit ,TIT_TIPO] )
				
					// baixa os titulos a receber selecionados
					dbSelectArea("SE1")
					dbSetOrder(1)
					If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO))
						// titulos renegociados
						dbSelectArea("LK7")
						dbSetOrder(1)
						RecLock("LK7",!dbSeek(xFilial("LK7")+LIX->(LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCELA+LIX_TIPO)))
							LK7->LK7_FILIAL := xFilial("LK7")
							LK7->LK7_NCONTR := LIT->LIT_NCONTR
							LK7->LK7_PREFIX := aTitSelect[nLoopTit ,TIT_PREFIXO]
							LK7->LK7_NUM    := aTitSelect[nLoopTit ,TIT_NUMERO]
							LK7->LK7_PARCEL := aTitSelect[nLoopTit ,TIT_PARCELA]
							LK7->LK7_TIPO   := aTitSelect[nLoopTit ,TIT_TIPO]
							LK7->LK7_VENCTO := aTitSelect[nLoopTit ,TIT_VENCTO]
							
							LK7->LK7_AMORT  := aTitSelect[nLoopTit ,TIT_PRINCIPAL]
							LK7->LK7_JURFCT := aTitSelect[nLoopTit ,TIT_JUROSFCTO]
							
							LK7->LK7_CMAMOR := aTitSelect[nLoopTit ,TIT_CMPRINCIPAL]
							LK7->LK7_CMJRFC := aTitSelect[nLoopTit ,TIT_CMJUROSFCTO]
							
							LK7->LK7_PRORAT := aTitSelect[nLoopTit ,TIT_PRORATA]
							LK7->LK7_JURMOR := aTitSelect[nLoopTit ,TIT_JUROSMORA]
							LK7->LK7_MULTA  := aTitSelect[nLoopTit ,TIT_MULTA]
							LK7->LK7_DESC   := aTitSelect[nLoopTit ,TIT_PERCDESC]
							LK7->LK7_ABONO  := aTitSelect[nLoopTit ,TIT_ABONO]

						MsUnLock()
					EndIf	
                Endif
			EndIf
		Next nLoopTit
	EndIf
Endif

RestArea(aAreaLK7)
RestArea(aAreaSE1)
RestArea(aAreaLIX)
RestArea(aAreaLIT)
RestArea(aArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a103VldDlg³ Autor ³ Reynaldo Miyashita    ³ Data ³ 04.10.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a dialog                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³a103VldDlg()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1:                                                        ³±±
±±³          ³ExpA2:                                                        ³±±
±±³          ³ExpC3:                                                        ³±±
±±³          ³ExpC4:                                                        ³±±
±±³          ³ExpC5:                                                        ³±±
±±³          ³ExpN6:                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function a103VldDlg( n1Parcela ,aTitulos )
Local lRetorno  := .F.

Default n1Parcela := 0

	If n1Parcela > 0

		lRetorno := .T.
						
	Else
		MsgAlert(STR0036) //"Não foi selecionado parcelas."
	EndIf

Return( lRetorno )             

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³DlgTit    ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 04.10.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³DlgTit()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1:                                                        ³±±
±±³          ³ExpA2:                                                        ³±±
±±³          ³ExpC3:                                                        ³±±
±±³          ³ExpC4:                                                        ³±±
±±³          ³ExpC5:                                                        ³±±
±±³          ³ExpN6:                                                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DlgTit( aTitulos ,nPosTit )

Local cCadastro := ""
Local nX        := 10
Local nY        := 10
Local lOk       := .F.
Local aTit      := {}
Local oBold
Local oDlg
Local oGetDesc
Local nCM       := 0
Local nPorc     := 0
Local nTotal    := 0

	aTit := aClone(aTitulos[nPosTit])
	aTit[TIT_ABONO] := 0
	
	If lJurosFcto
		aTit[TIT_ABONO] += aTit[TIT_JUROSFCTO]
		aTit[TIT_ABONO] += aTit[TIT_CMJUROSFCTO]
	EndIf

	If !lPRatAtr     
		aTit[TIT_ABONO] += aTit[TIT_PRORATA]
	EndIf                     
	
	If !lJurMora
		aTit[TIT_ABONO] += aTit[TIT_JUROSMORA]
	EndIf
	
	If !lMulta
		aTit[TIT_ABONO] += aTit[TIT_MULTA]
	EndIf
	
    nCM    :=  aTit[TIT_CMPRINCIPAL]+aTit[TIT_CMJUROSFCTO]
	nTotal := 0
	nTotal := aTit[TIT_PRINCIPAL]+aTit[TIT_JUROSFCTO]+aTit[TIT_CMPRINCIPAL]+aTit[TIT_CMJUROSFCTO];
	        + aTit[TIT_PRORATA]+aTit[TIT_JUROSMORA]+aTit[TIT_MULTA]-aTit[TIT_ABONO]
	        
	aTit[TIT_VLRTITULO] := nTotal
	
	If lDescto
		If aTit[TIT_DESCONTO] == 0
			nMeses := GmDateDiff(dDataBase ,aTit[TIT_VENCTO] ,"m")
			nPorc := nPerDesc*nMeses
		
			VldDesc( "1" ,aTit ,nPorc ,@aTit[TIT_DESCONTO] )
		Else
			nPorc := (aTit[TIT_DESCONTO]/nTotal)*100
			
		EndIf
	Else
		nPorc := 0
		aTit[TIT_DESCONTO] := 0
			
	EndIf

	aTit[TIT_VLRTITULO] -= aTit[TIT_DESCONTO]
	
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlg FROM 114,150 TO 460,600 TITLE STR0037 Of oMainWnd PIXEL //"Titulo a receber"

		@nX+10,nY+05 SAY STR0038    Of oDLG PIXEL //"Parcela:"
		@nX+10,nY+60 MSGET aTit[TIT_ITEMPARCELA]	  PICTURE "@!" WHEN .F. Of oDLG PIXEL SIZE 040,010 
	
		@nX+10,nY+100 SAY STR0039    Of oDLG PIXEL //"Tipo: "
		@nX+10,nY+130 MSGET aTit[TIT_TIPO]	  PICTURE "@!" WHEN .F. Of oDLG PIXEL SIZE 040,010 
		
		@nX+22,nY+05 SAY STR0040    Of oDLG PIXEL //"Data de Vencimento:"
		@nX+22,nY+60 MSGET aTit[TIT_VENCTO]	  PICTURE "@E 9,999,999.99" WHEN .F. Of oDLG PIXEL SIZE 040,010 
		
		nX += 10
		@nX+34,nY+045 SAY STR0041    Of oDLG PIXEL //"Principal:"
		@nX+34,nY+100 MSGET aTit[TIT_PRINCIPAL]	  PICTURE "@E 9,999,999.99" WHEN .F. Of oDLG PIXEL SIZE 040,010 
		
		@nX+46,nY+045 SAY STR0042    Of oDLG PIXEL //"Juros Fcto:"
		@nX+46,nY+100 MSGET aTit[TIT_JUROSFCTO]	  PICTURE "@E 9,999,999.99" WHEN .F. Of oDLG PIXEL SIZE 040,010 
		
		@nX+58,nY+045 SAY STR0043    Of oDLG PIXEL //"Correcao Monetaria:"
		@nX+58,nY+100 MSGET nCM PICTURE "@E 9,999,999.99" WHEN .F. Of oDLG PIXEL SIZE 040,010 
		
		@nX+70,nY+045 SAY STR0044    Of oDLG PIXEL //"Pro-rata:"
		@nX+70,nY+100 MSGET aTit[TIT_PRORATA]	  PICTURE "@E 9,999,999.99" WHEN .F. Of oDLG PIXEL SIZE 040,010 
		
		@nX+82,nY+045 SAY STR0045    Of oDLG PIXEL //"Juros Mora:"
		@nX+82,nY+100 MSGET aTit[TIT_JUROSMORA]	  PICTURE "@E 9,999,999.99" WHEN .F. Of oDLG PIXEL SIZE 040,010 
		
		@nX+94,nY+045 SAY STR0046    Of oDLG PIXEL //"Multa:"
		@nX+94,nY+100 MSGET aTit[TIT_MULTA]	  PICTURE "@E 9,999,999.99" WHEN .F. Of oDLG PIXEL SIZE 040,010 
		
		@nX+106,nY+045 SAY STR0047    Of oDLG PIXEL //"Abono:"
		@nX+106,nY+100 MSGET aTit[TIT_ABONO]	  PICTURE "@E 9,999,999.99" WHEN .F. Of oDLG PIXEL SIZE 040,010 
		               		
		@nX+118,nY+045 SAY STR0048    Of oDLG PIXEL //"Desconto:"
		@nX+118,nY+100 MSGET oGetDesc VAR aTit[TIT_DESCONTO]	;  
		              PICTURE "@E 9,999,999.99" ;
		              VALID iIf( VldVlrDesc( aTit ,aTit[TIT_DESCONTO] ,@nPorc ) ;
		                        ,( oGetPorc:Refresh() ,oGetDesc:Refresh() ;
		                          ,aTit[TIT_VLRTITULO] := nTotal-aTit[TIT_DESCONTO] ,oGetTotal:Refresh() ,.T. ) ;
		                        ,.F. ) ;
		              WHEN lDescto ; 
		              Of oDLG PIXEL SIZE 040,010 

		@nX+118,nY+150 MSGET oGetPorc VAR nPorc	;  
		              PICTURE "@E 999.99%" ;
		              VALID iIf( VldPercDesc( nPorc ) ;
		                        ,(VldDesc( "1" ,aTit ,nPorc ,@aTit[TIT_DESCONTO] ) ,oGetPorc:Refresh() ,oGetDesc:Refresh() ,aTit[TIT_VLRTITULO] := nTotal-aTit[TIT_DESCONTO] ,oGetTotal:Refresh() ,.T. ) ;
		                        ,.F. ) ;
		              WHEN lDescto ; 
		              Of oDLG PIXEL SIZE 040,010 
		              
		@nX+130,nY+045 SAY STR0049    Of oDLG PIXEL //"Total:"
		@nX+130,nY+100 MSGET oGetTotal VAR aTit[TIT_VLRTITULO] ;
		               PICTURE "@E 9,999,999.99" WHEN .F. Of oDLG PIXEL SIZE 040,010 
		               		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{|| lOk:=.F.,oDlg:End()}) CENTERED

	If lOk
		aTitulos[nPosTit ,TIT_SELECT]    := .T.
		aTitulos[nPosTit ,TIT_DESCONTO]  := aTit[TIT_DESCONTO]
		aTitulos[nPosTit ,TIT_ABONO]     := aTit[TIT_ABONO]	  
		aTitulos[nPosTit ,TIT_VLRTITULO] := aTit[TIT_VLRTITULO]
		aTitulos[nPosTit ,TIT_PERCDESC]  := nPorc

	Else
		aTitulos[nPosTit ,TIT_SELECT]    := .F.
		aTitulos[nPosTit ,TIT_DESCONTO]  := 0
		aTitulos[nPosTit ,TIT_VLRTITULO] := nTotal
		aTitulos[nPosTit ,TIT_ABONO]     := 0
		aTitulos[nPosTit ,TIT_PERCDESC]  := 0
	EndIf
	
	a103Refresh(.T.)
	
Return( .T. )

//
// Calcula o valor ou a porcentagem do desconto
//
Static Function CalcDesc( nVlrCalc ,nPerc ,nValor )
Local nRetorno := 0

	// calcula a porcentagem
	If (nPerc == NIL) .AND. !(nValor == NIL)
		nRetorno  := Round((nValor/nVlrCalc)*100,2)
	EndIf

	// calcula o valor
	If (nValor == NIL) .AND. !(nPerc == NIL)
		nRetorno := Round(nVlrCalc*(nPerc/100),2)
	EndIf
	
Return( nRetorno )

//
// Valida o valor ou a porcentagem do desconto
//
Static Function VldDesc( cTipo ,aTitulo ,nPorc ,nValor )
Local lRet := .T.

DEFAULT cTipo := "1"

	// o desconto é aplicado para titulos a receber com 
	// data de vencimento superior a database
	If left(dTos(aTitulo[TIT_VENCTO]),6) > left(dTos(dDataBase),6)
	
		nVlrTit := aTitulo[TIT_VLRTITULO]
        
		// Calcula o Valor do desconto
		If cTipo == "1"
			nValor := CalcDesc( nVlrTit ,nPorc )
		EndIf
		
		// Calcula a porcentagem do desconto
		If cTipo == "2"
			nPorc := CalcDesc( nVlrTit ,,nValor)
		EndIf
	    
	EndIf
	
Return( lRet )

Static Function VldVlrDesc( aTitulo ,nValor ,nPerc )
Local lRet    := .F.
Local nVlrTit := 0

	nVlrTit := aTitulo[TIT_PRINCIPAL]
	If lJurosFcto
		nVlrTit += aTitulo[TIT_CMPRINCIPAL]
	Else
		nVlrTit += aTitulo[TIT_JUROSFCTO]+aTitulo[TIT_CMPRINCIPAL]+aTitulo[TIT_CMJUROSFCTO]
    EndIf

	If !(nValor > nVlrTit)
		nPerc := CalcDesc( nVlrTit ,,nValor)
		lRet := .T.
	Else
		MsgAlert(STR0050) //"Valor do desconto não pode ser superior ao valor do titulo. Verifique."
		
	EndIf
	
Return( lRet )

Static Function VldPercDesc( nPorc )
Local lRet      := .T.
Local nResposta := 0
    
	If nPorc <= 100    
		If nMaxDesc <> 0 .and. nMaxDesc <= nPorc
			// Adverte se o desconto for superior
			nResposta := Aviso( STR0016 ,STR0051+ Transform(nMaxDesc,"99.99")+ STR0052 ; //"Desconto"###"A porcentagem de desconto informado é superior a "###"% que foi definido. Deseja continuar?"
			                   ,{STR0053,STR0054} ,3 ) //"Sim"###"Não"
		
			If nResposta == 2
				lRet := .F.
			EndIf
			
		EndIf
	EndIf
		
Return( lRet )
