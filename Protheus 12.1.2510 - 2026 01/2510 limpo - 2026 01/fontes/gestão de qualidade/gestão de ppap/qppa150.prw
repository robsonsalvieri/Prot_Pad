#INCLUDE "QPPA150.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} QPPA150AuxClass
Classe geral do QPPA150
@author Jefferson Possidonio
@since 18/09/2024
@version 1.0
/*/
CLASS QPPA150AuxClass FROM LongNameClass
	METHOD criaPaineisParaLayoutDeTela(oDlg, oPanel1, oPanel2)
ENDCLASS

/*/{Protheus.doc} criaPaineisParaLayoutDeTela
Cria Paineis para ajustar os componentes na tela
@author Jefferson Possidonio
@since  18/09/2024
@param 01 - oDlg   , objeto, objeto de Tela
@param 02 - oPanel1, objeto, objeto para posicionar campos
@param 03 - oPanel2, objeto, objeto para posicionar MSGetDados
@version 1.0
/*/
METHOD criaPaineisParaLayoutDeTela(oDlg, oPanel1, oPanel2) CLASS QPPA150AuxClass

Local oFwLayer := Nil

oFwLayer := FwLayer():New
oFwLayer:init(oDlg,.F.)

oFwLayer:addLine("CABECALHO", 020, .F.)
oFwLayer:addLine("CORPO"    , 070, .F.)

oFwLayer:AddColumn("SELECAO", 100, .T., "CABECALHO")
oFwLayer:AddColumn("GRID"   , 100, .T., "CORPO")

oPanel1 := oFwLayer:getColPanel("SELECAO" ,"CABECALHO")
oPanel2 := oFwLayer:getColPanel("GRID"    ,"CORPO")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA150  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Diagrama de Fluxo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA150(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³19.03.02³ META ³ Alt. para cadastrar +99 fluxos e       ³±±
±±³              ³        ³      ³ melhorias na rotina                    ³±±
±±³ Robson Ramiro³23.08.02³xMETA ³ Melhoria para inclusao de operacoes    ³±±
±±³              ³        ³      ³ entre operacoes ja existentes          ³±±
±±³ Robson Ramiro³15/05/03³      ³ Tratamento dinamico da qtde de itens da³±±
±±³              ³        ³      ³ getdados caso necessite customizacao   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotAdic  := {}
Private aRotina := { {OemToAnsi(STR0019) , "AxPesqui"    , 0 , 1,,.F.},; // "Pesquisa"
	    			 {OemToAnsi(STR0020) , "PPA150Visu"  , 0 , 2     },; // "Visualiza"
		    		 {OemToAnsi(STR0021) , "PPA150Incl"  , 0 , 3     },; // "Inclui"
			    	 {OemToAnsi(STR0022) , "PPA150Alte"  , 0 , 4     },; // "Altera"
				     {OemToAnsi(STR0023) , "PPA150Excl"  , 0 , 5     },; // "Exclui"
					 {OemToAnsi(STR0027) , "QPPR150(.T.)", 0 , 6,,.T.}}  // "Imprimir"

If ExistBlock("QPP150ROT")
	aRotAdic := ExecBlock("QPP150ROT", .F., .F.)
	If ValType(aRotAdic) == "A" .And. Len(aRotAdic)==1
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina

Function QPPA150()

Private aBMP      := {}
Private aMsSize   := MsAdvSize()
Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0001) //"Diagrama de Fluxo"
Private cFiltro   := ""
Private lExecB    := ExistBlock("QPP150BMP")
Private nTamGet   := QPPTAMGET("QKN_ITEM",1)
Private nTamItem  := QPPTAMGET("QKN_ITEM",2)

DbSelectArea("QKN")
DbSetOrder(1)

If Len(QKN_SEQ) <> nTamItem
	Alert(OemToAnsi(STR0028)) //"Quando customizada a quantidade de itens, e necessario a compatibilizacao do campo QKN_SEQ"
	Return .F.
Endif

cFiltro := "QKN_ITEM == '"+StrZero(1,nTamItem)+"'"

Set Filter To &cFiltro
mBrowse(6,1,22,75,"QKN",,,,,,)
Set Filter To

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA150Visu³ Autor ³ Robson Ramiro A. Olive³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Visualizacao dos Diagrama de Fluxo             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA150Visu()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA150Visu(cAlias, nReg, nOpc)

Local aButtons := {}
Local oDlg     := NIL
Local oGet_1   := NIL
Local oGet_2   := NIL
Local oGet_3   := NIL
Local oGet_4   := NIL
Local oPanel1  := Nil
Local oPanel2  := Nil

Private aCols   := {}
Private aHeader := {}
Private nUsado  := 0
Private oGet    := NIL

RegToMemory("QKN")

// Monta vetor aHeader a ser utilizado na getdados
A150Ahead("QKN")
DbSelectArea("QKN")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel // "Diagrama de Fluxo"

QPPA150AuxClass():criaPaineisParaLayoutDeTela(oDlg, @oPanel1, @oPanel2 )

@ 005,003 SAY TitSX3("QKN_PECA")[1] SIZE 56,07 OF oPanel1 PIXEL
@ 005,061 MSGET oGet_1 VAR M->QKN_PECA PICTURE PesqPict("QKN","QKN_PECA") ;
						ReadOnly F3 "QPP" SIZE 66,10 OF oPanel1 PIXEL

@ 005,141 SAY TitSX3("QKN_REV")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 005,199 MSGET oGet_2 VAR M->QKN_REV PICTURE PesqPict("QKN","QKN_REV") ;
                        WHEN .F.;
					   	SIZE 15,10 OF oPanel1 PIXEL
					   	
@ 023,003 SAY TitSX3("QKN_APRPOR")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 023,061 MSGET oGet_3 VAR M->QKN_APRPOR PICTURE PesqPict("QKN","QKN_APRPOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oPanel1 PIXEL

@ 023,141 SAY TitSX3("QKN_DTAPR")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 023,199 MSGET oGet_4 VAR M->QKN_DTAPR PICTURE PesqPict("QKN","QKN_DTAPR") ;
						WHEN .F.;
					   	SIZE 40,10 OF oPanel1 PIXEL
					   	
A150Acols(nOpc)

oGet := MSGetDados():New(75,02,198,333, nOpc,"AllwaysTrue","AllwaysTrue","+QKN_ITEM",.T.,,,,nTamGet,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

aButtons := { 	{"BMPVISUAL",	{ || QPPR150()}, 		 OemToAnsi(STR0003), OemToAnsi(STR0029) },;	//"Visualizar/Imprimir"###"Vis/Prn"
				{"RELATORIO",	{ || QPP150OBSE(nOpc) }, OemToAnsi(STR0024), OemToAnsi(STR0030) } }	//"Observacoes"###"Obs"

If ExistBlock("QP150BUT")              
	aButtons := ExecBlock("QP150BUT",.F., .F., {nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons)CENTERED

DbSelectArea("QKN")
DbSetOrder(1)
Set Filter To &cFiltro

n := 0

Return          

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA150Incl³ Autor ³ Robson Ramiro A. Olive³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Inclusao dos Diagrama de Fluxo                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPPA150Incl()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA150Incl(cAlias, nReg, nOpc)

Local aButtons := {}
Local lOk      := .F.
Local oDlg     := NIL
Local oGet_1   := NIL
Local oGet_2   := NIL
Local oGet_3   := NIL
Local oGet_4   := NIL
Local oPanel1  := Nil
Local oPanel2  := Nil

Private aCols   := {}
Private aHeader := {}
Private nUsado  := 0
Private oGet    := NIL

RegToMemory("QKN",.T.)

// Monta vetor aHeader a ser utilizado na getdados
A150Ahead("QKN")
DbSelectArea("QKN")
Set Filter To

nUsado	:= Len(aHeader)      

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel // "Diagrama de Fluxo"

QPPA150AuxClass():criaPaineisParaLayoutDeTela(oDlg, @oPanel1, @oPanel2 )

@ 005,003 SAY TitSX3("QKN_PECA")[1] SIZE 56,07 OF oPanel1 PIXEL
@ 005,061 MSGET oGet_1 VAR M->QKN_PECA PICTURE PesqPict("QKN","QKN_PECA") ;
						Valid NaoVazio();
						F3 "QPP" SIZE 66,10 OF oPanel1 PIXEL  

@ 005,141 SAY TitSX3("QKN_REV")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 005,199 MSGET oGet_2 VAR M->QKN_REV PICTURE PesqPict("QKN","QKN_REV") ;
                        VALID CheckSx3("QKN_REV",M->QKN_REV);
					   	SIZE 15,10 OF oPanel1 PIXEL
					   					   	
@ 023,003 SAY TitSX3("QKN_APRPOR")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 023,061 MSGET oGet_3 VAR M->QKN_APRPOR PICTURE PesqPict("QKN","QKN_APRPOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oPanel1 PIXEL					   		

@ 023,141 SAY TitSX3("QKN_DTAPR")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 023,199 MSGET oGet_4 VAR M->QKN_DTAPR PICTURE PesqPict("QKN","QKN_DTAPR") ;
						WHEN .F.;
					   	SIZE 40,10 OF oPanel1 PIXEL					   		

A150Acols(nOpc)

oGet := MSGetDados():New(75,02,198,333, nOpc,"PP150LinOk" ,"PP150TudOk","+QKN_ITEM",.T.,,,,nTamGet,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

aButtons := {	{"BMPINCLUIR", { || QPPCarOpe()      }, OemToAnsi(STR0004), OemToAnsi(STR0031) },; //"Inclusao Automatica"###"Inc Auto"
				{"EDIT",  	   { || QPP150APRO(nOpc) },	OemToAnsi(STR0002), OemToAnsi(STR0032) },; //"Aprovar/Desaprovar"###"Apro/Des"
				{"OBJETIVO",   { || QPPA150BMP(nOpc) }, OemToAnsi(STR0005), OemToAnsi(STR0015) },; //"Escolha a Operacao"###"Operacao"
				{"RELATORIO",  { || QPP150OBSE(nOpc) }, OemToAnsi(STR0024), OemToAnsi(STR0030) } } //"Observacoes"###"Obs"
				
If ExistBlock("QP150BUT")              
	aButtons := ExecBlock("QP150BUT",.F., .F., {nOpc,aButtons})
EndIf				

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP150TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
    PPA150Grav(nOpc)
Endif

DbSelectArea("QKN")
DbSetOrder(1)
Set Filter To &cFiltro

n := 0

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA150Alte³ Autor ³ Robson Ramiro A. Olive³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Alteracao dos Diagrama de Fluxo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA150Alte()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA150Alte(cAlias, nReg, nOpc)

Local aButtons := {}
Local lOk      := .F.
Local oDlg     := NIL
Local oGet_1   := NIL
Local oGet_2   := NIL
Local oGet_3   := NIL
Local oGet_4   := NIL
Local oPanel1  := Nil
Local oPanel2  := Nil

Private aCols   := {}
Private aHeader := {}
Private nUsado  := 0
Private oGet    := NIL

If !QPPVldAlt(QKN->QKN_PECA,QKN->QKN_REV,QKN->QKN_APRPOR)
	Return
Endif

RegToMemory("QKN")

// Monta vetor aHeader a ser utilizado na getdados
A150Ahead("QKN")
DbSelectArea("QKN")
Set Filter To

nUsado	:= Len(aHeader)      

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel // "Diagrama de Fluxo"

QPPA150AuxClass():criaPaineisParaLayoutDeTela(oDlg, @oPanel1, @oPanel2 )

@ 005,03 SAY TitSX3("QKN_PECA")[1] SIZE 56,07 OF oPanel1 PIXEL
@ 005,61 MSGET oGet_1 VAR M->QKN_PECA PICTURE PesqPict("QKN","QKN_PECA") ;
						ReadOnly F3 "QPP" SIZE 66,10 OF oPanel1 PIXEL

@ 005,141 SAY TitSX3("QKN_REV")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 005,199 MSGET oGet_2 VAR M->QKN_REV PICTURE PesqPict("QKN","QKN_REV") ;
						WHEN .F. ;			
					   	SIZE 15,10 OF oPanel1 PIXEL
					   	
@ 023,003 SAY TitSX3("QKN_APRPOR")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 023,061 MSGET oGet_3 VAR M->QKN_APRPOR PICTURE PesqPict("QKN","QKN_APRPOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oPanel1 PIXEL

@ 023,141 SAY TitSX3("QKN_DTAPR")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 023,199 MSGET oGet_4 VAR M->QKN_DTAPR PICTURE PesqPict("QKN","QKN_DTAPR") ;
						WHEN .F.;
					   	SIZE 40,10 OF oPanel1 PIXEL
		   		
A150Acols(nOpc)

oGet := MSGetDados():New(75,02,198,333, nOpc,"PP150LinOk" ,"PP150TudOk","+QKN_ITEM",.T.,,1,,nTamGet,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

aButtons := {	{"EDIT",  		{ || QPP150APRO(nOpc) }, OemToAnsi(STR0002), OemToAnsi(STR0032) },; //"Aprovar/Desaprovar"###"Apro/Des"
				{"BMPINCLUIR",	{ || QPPA150BMP(nOpc) }, OemToAnsi(STR0005), OemToAnsi(STR0015) },; //"Escolha a Operacao"###"Operacao"
				{"RELATORIO", 	{ || QPP150OBSE(nOpc) }, OemToAnsi(STR0024), OemToAnsi(STR0030) } } //"Observacoes"###"Obs"
	 
If ExistBlock("QP150BUT")              
	aButtons := ExecBlock("QP150BUT",.F., .F., {nOpc,aButtons})
EndIf
					
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lOk := PP150TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons) CENTERED

If lOk
	PPA150Grav(nOpc)
Endif

DbSelectArea("QKN")
DbSetOrder(1)
Set Filter To &cFiltro

n := 0

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA150Excl³ Autor ³ Robson Ramiro A. Olive³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Exclusao dos Diagrama de Fluxo                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA150Excl()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA150Excl(cAlias, nReg, nOpc)

Local aButtons := {}
Local oDlg     := NIL
Local oGet_1   := NIL
Local oGet_2   := NIL
Local oGet_3   := NIL
Local oGet_4   := NIL
Local oPanel1  := Nil
Local oPanel2  := Nil

Private aCols   := {}
Private aHeader := {}
Private nUsado  := 0
Private oGet    := NIL

If !QPPVldExc(QKN->QKN_REV,QKN->QKN_APRPOR)
	Return
Endif

RegToMemory("QKN")

// Monta vetor aHeader a ser utilizado na getdados
A150Ahead("QKN")
DbSelectArea("QKN")
Set Filter To

nUsado	:= Len(aHeader)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aMsSize[7],000 TO aMsSize[6],aMsSize[5] OF oMainWnd Pixel //"Diagrama de Fluxo"

QPPA150AuxClass():criaPaineisParaLayoutDeTela(oDlg, @oPanel1, @oPanel2 )

@ 005,03 SAY TitSX3("QKN_PECA")[1] SIZE 56,07 OF oPanel1 PIXEL
@ 005,61 MSGET oGet_1 VAR M->QKN_PECA PICTURE PesqPict("QKN","QKN_PECA") ;
						ReadOnly F3 "QPP" SIZE 66,10 OF oPanel1 PIXEL

@ 005,141 SAY TitSX3("QKN_REV")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 005,199 MSGET oGet_2 VAR M->QKN_REV PICTURE PesqPict("QKN","QKN_REV") ;
						WHEN .F. ;
					   	SIZE 15,10 OF oPanel1 PIXEL

@ 023,003 SAY TitSX3("QKN_APRPOR")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 023,061 MSGET oGet_3 VAR M->QKN_APRPOR PICTURE PesqPict("QKN","QKN_APRPOR") ;
						WHEN .F.;
					   	SIZE 66,10 OF oPanel1 PIXEL					   		

@ 023,141 SAY TitSX3("QKN_DTAPR")[1] SIZE 56, 7 OF oPanel1 PIXEL
@ 023,199 MSGET oGet_4 VAR M->QKN_DTAPR PICTURE PesqPict("QKN","QKN_DTAPR") ;
						WHEN .F.;
					   	SIZE 40,10 OF oPanel1 PIXEL					   		
					   	
A150Acols(nOpc)

oGet := MSGetDados():New(75,02,198,333, nOpc,"AllwaysTrue","AllwaysTrue","+QKN_ITEM",.T.,,,,nTamGet,,,,,oPanel2)
oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

aButtons := { 	{"BMPVISUAL",	{ || QPPR150() }, 		 OemToAnsi(STR0003), OemToAnsi(STR0029) },;	//"Visualizar/Imprimir"###"Vis/Prn"
				{"RELATORIO", 	{ || QPP150OBSE(nOpc) }, OemToAnsi(STR0024), OemToAnsi(STR0030) } }	//"Observacoes"###"Obs"

If ExistBlock("QP150BUT")              
	aButtons := ExecBlock("QP150BUT",.F., .F., {nOpc,aButtons})
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| A150Dele(),oDlg:End()},{||oDlg:End()}, , aButtons) CENTERED

DbSelectArea("QKN")
DbSetOrder(1)
Set Filter To &cFiltro

n := 0

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A150Acols³ Autor ³ Robson Ramiro A. Olive³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150Acols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A150Acols(nOpc)

Local nI      := 0
Local nPos    := aScan(aHeader, { |x| AllTrim(x[2]) == "QKN_ITEM" })
Local nPosSEQ := aScan(aHeader, { |x| AllTrim(x[2]) == "QKN_SEQ" })

// Montagem do aCols
If nOpc == 3

	aCols := Array(1,nUsado+1)
	For nI = 1 To Len(aHeader)
		If aHeader[nI,8] == "C"
			aCols[1,nI] := Space(aHeader[nI,4])
		ElseIf aHeader[nI,8] == "N"
			aCols[1,nI] := 0
		ElseIf aHeader[nI,8] == "D"
			aCols[1,nI] := dDataBase
		ElseIf aHeader[nI,8] == "M"
			aCols[1,nI] := ""
		Else
			aCols[1,nI] := .F.
		EndIf
	Next nI
	aCols[1,nPos]		:= StrZero(1,Len(aCols[1,nPos]))
	aCols[1,nPosSEQ] 	:= StrZero(10,nTamItem)
	
	aCols[1,nUsado+1] := .F.
Else
	
	DbSelectArea("QKN")
	DbSetOrder(1)
	DbSeek(xFilial()+M->QKN_PECA+M->QKN_REV)

	Do While QKN->(!Eof()) .and. xFilial() == QKN->QKN_FILIAL .and.;
				QKN->QKN_PECA+QKN->QKN_REV == M->QKN_PECA+M->QKN_REV
			 	
		aAdd(aCols,Array(nUsado+1))
	
		For nI := 1 to nUsado
   	
			If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Else										// Campo Virtual
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])
  			Endif
 			
		Next nI
  			
		aCols[Len(aCols),nUsado+1] := .F.
    	
		DbSkip()

	Enddo
		
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A150Ahead³ Autor ³ Robson Ramiro A. Olive³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150Ahead()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A150Ahead(cAlias)

Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX         := 0

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//Ignora campos que nao devem aparecer na getdados
	If  Upper(AllTrim(aStruAlias[nX,1])) == "QKN_PECA" 	 .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKN_REV"  	 .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKN_REVINV" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKN_APRPOR" .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKN_DTAPR"
		Loop
	Endif
	
	If cNivel >= GetSX3Cache(aStruAlias[nX,1],"X3_NIVEL")
		nUsado++
 		aAdd(aHeader,{ Trim(QAGetX3Tit(aStruAlias[nX,1])),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_CAMPO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_PICTURE'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_TAMANHO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_DECIMAL'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_VALID'),;              
		              GetSx3Cache(aStruAlias[nX,1],'X3_USADO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_TIPO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_ARQUIVO'),;
		              GetSx3Cache(aStruAlias[nX,1],'X3_CONTEXT')})
	Endif	
Next nX 

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A150Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao dos Diagrama de Fluxo                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A150Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A150Dele()

DbSelectArea("QKN")
DbSetOrder(1)
DbSeek(xFilial() + M->QKN_PECA + M->QKN_REV)

Begin Transaction

Do While QKN->(!Eof()) .and. xFilial() == QKN->QKN_FILIAL   .and.;
			QKN->QKN_PECA + QKN->QKN_REV == M->QKN_PECA + M->QKN_REV
		 
	RecLock("QKN",.F.)
	DbDelete()
	MsUnLock()
	FKCOMMIT()
		
	DbSkip()
		
Enddo

End Transaction

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA150Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao dos Diagrama de Fluxo - Incl./Alter   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA150Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA150Grav(nOpc)

Local cAtividade := "04 " // Definido no ID - QKZ
Local lGraOk     := .T.
Local nCpo       := 0
Local nIt        := 0
Local nNumItem   := 0
Local nPosDel    := Len(aHeader) + 1
Local nPosSEQ    := aScan(aHeader, { |x| AllTrim(x[2]) == "QKN_SEQ" })

DbSelectArea("QKN")
DbSetOrder(1)
	
aCols := aSort(aCols,,,{|x,y| x[nPosSEQ] < y[nPosSEQ]}) // Ordena o aCols pelo codigo da sequencia

Begin Transaction

nNumItem := 1  // Contador para os Itens
	
For nIt := 1 To Len(aCols)
	
	If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

		If ALTERA
			If DbSeek(xFilial("QKN")+ M->QKN_PECA + M->QKN_REV + StrZero(nIt,nTamItem))
				RecLock("QKN",.F.)
			Else
				RecLock("QKN",.T.)
			Endif
		Else	                   
			RecLock("QKN",.T.)
		Endif
			
		For nCpo := 1 To Len(aHeader)
			If aHeader[nCpo, 10] <> "V"
  				QKN->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
			Endif
		Next nCpo
                                                                              
		// Controle de itens do acols / Chave invertida 
        QKN->QKN_ITEM   := StrZero(nNumItem,nTamItem)
		QKN->QKN_REVINV := Inverte(M->QKN_REV)

		// Dados da Enchoice
		QKN->QKN_FILIAL := xFilial("QKN")
		QKN->QKN_PECA   := M->QKN_PECA
		QKN->QKN_REV    := M->QKN_REV
		QKN->QKN_APRPOR := M->QKN_APRPOR    
		QKN->QKN_DTAPR  := M->QKN_DTAPR            

		nNumItem++			
	
		MsUnLock()					
	Else
		If DbSeek(xFilial("QKN")+ M->QKN_PECA + M->QKN_REV + StrZero(nIt,nTamItem))
			RecLock("QKN",.F.)
			QKN->(DbDelete())
			MsUnLock()								
		Endif
	Endif
	                                
Next nIt
FKCOMMIT()

End Transaction

If !Empty(QKN->QKN_DTAPR) .and. !Empty(QKN->QKN_APRPOR)
	QPP_CRONO(QKN->QKN_PECA,QKN->QKN_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
Endif
				
DbSelectArea("QKN")
DbSetOrder(1)

Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP150LinOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP150LinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/                     
Function PP150LinOk

Local lRetorno  := .T.
Local nCont     := 0
Local nPosDel   := Len(aHeader) + 1
Local nPosItem  := aScan(aHeader,{ |x| AllTrim(x[2]) == "QKN_ITEM" })
Local nPosSEQ   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_SEQ" })
Local nPosSIMB1 := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_SIMB1"})
Local nPosSIMB2 := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_SIMB2"})

// verifica se algo foi preenchido
If !aCols[n, nPosDel] .and. Empty(aCols[n, nPosSIMB1]) .and. Empty(aCols[n, nPosSIMB2])
	lRetorno := .F.
EndIf

aEval(aCols, { |x| Iif( x[nPosDel] == .F. .and. x[nPosSEQ] == aCols[n, nPosSEQ], nCont++, nCont) })

If nCont > 1
	Help( " ", 1, "QPP110JAEX") // "Informacao ja cadastrada"
	lRetorno := .F.
Endif

// Re-Organiza o Acols
If lRetorno
	aCols := aSort(aCols,,,{|x,y| x[nPosSEQ]+x[nPosItem] < y[nPosSEQ]+y[nPosItem ]}) 
	oGet:oBrowse:Refresh()    
Endif

Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP150TudOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consistencia para inclusao/alteracao geral                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP150TudOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PP150TudOk

Local lRetorno  := .T.
Local nCont     := 0
Local nIt       := 0
Local nPosDel   := Len(aHeader) + 1
Local nPosSEQ   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_SEQ" })
Local nPosSIMB1 := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_SIMB1"})
Local nPosSIMB2 := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_SIMB2"})
Local nTot      := 0

For nIt := 1 To Len(aCols)
	If aCols[nIt, nPosDel]
		nTot ++
	Endif
Next nIt

If Empty(M->QKN_PECA) .or. Empty(M->QKN_REV) .or. nTot == Len(aCols)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

aEval(aCols, { |x| Iif( x[nPosDel] == .F. .and. x[nPosSEQ] == aCols[n, nPosSEQ], nCont++, nCont) })

If nCont > 1
	Help( " ", 1, "QPP110JAEX") // "Informacao ja cadastrada"
	lRetorno := .F.
Endif

If !aCols[n, nPosDel] .and. Empty(aCols[n, nPosSIMB1]) .and. Empty(aCols[n, nPosSIMB2])
	lRetorno := .F.
EndIf

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP150APRO³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 09.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova Fluxo                             				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP150APRO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP150APRO(nOpc)

If nOpc == 3 .or. nOpc == 4                                                  
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QKN_DTAPR 	:= Iif(Empty(M->QKN_DTAPR) ,dDataBase ,CtoD(" / / "))
		M->QKN_APRPOR 	:= Iif(Empty(M->QKN_APRPOR),cUserName,Space(40))
	Else
		messagedlg(STR0033) //"O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá ser o aprovador"
	Endif
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPCarOpe ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 09/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega vetor com as Opercoes Cadastradas   				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPPCarOpe                                    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA150													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPPCarOpe()

Local lRet      := .T.
Local nCnt      := 1
Local nI        := 0
Local nPosDESC  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_DESC" })
Local nPosITEM  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_ITEM" })
Local nPosNOPE  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_NOPE" })
Local nPosSEQ   := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_SEQ" })
Local nPosSIMB1 := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "QKN_SIMB1"})

If INCLUI
	If Empty(M->QKN_PECA) .or. Empty(M->QKN_REV)
		lRet := .F.
		MsgAlert(STR0006) //"Peca e Revisao Nao Informados !"
	Else
		If Len(aCols) == 1 .and. Empty(aCols[1, nPosNOPE]) .and. Empty(aCols[1,nPosSIMB1])
			DbSelectArea("QKK")
			DbSetOrder(1)
			If DbSeek(xFilial("QKK")+M->QKN_PECA+M->QKN_REV)
				If MsgYesNo(STR0007,STR0008) //"Deseja Incluir Automaticamente as Operacoes ?"###"Operacoes"
					aCols := {}

					Do While QKK->QKK_FILIAL == xFilial("QKK") .and. QKK->QKK_PECA == M->QKN_PECA ;
								.and. QKK->QKK_REV == M->QKN_REV .and. !Eof()

						aAdd(aCols,Array(nUsado+1))
						
						For nI := 1 To Len(aHeader)
							If aHeader[nI,8] == "C"
								aCols[Len(aCols),nI] := Space(aHeader[nI,4])
							Elseif aHeader[nI,8] == "N"
								aCols[Len(aCols),nI] := 0
							Elseif aHeader[nI,8] == "D"
								aCols[Len(aCols),nI] := CtoD(" / / ")
							Elseif aHeader[nI,8] == "M"
								aCols[Len(aCols),nI] := ""
							Else
								aCols[Len(aCols),nI] := .F.
							EndIf
						Next nI

						aCols[nCnt][nPosITEM] 	:= StrZero(nCnt,nTamItem)
						aCols[nCnt][nPosSEQ] 	:= StrZero(nCnt*10,nTamItem)
						aCols[nCnt][nPosSIMB1]	:= QKK->QKK_SBOPE
						aCols[nCnt][nPosNOPE] 	:= QKK->QKK_NOPE
						aCols[nCnt][nPosDESC] 	:= QKK->QKK_DESC
						aCols[Len(aCols),nUsado+1] := .F.
						nCnt++

						DbSkip()
						
						If QKK->QKK_FILIAL == xFilial("QKK") .and. QKK->QKK_PECA == M->QKN_PECA ;
								.and. QKK->QKK_REV == M->QKN_REV .and. !Eof()
						
							aAdd(aCols,Array(nUsado+1))
						
							For nI := 1 To Len(aHeader)
								If aHeader[nI,8] == "C"
									aCols[Len(aCols),nI] := Space(aHeader[nI,4])
								Elseif aHeader[nI,8] == "N"
									aCols[Len(aCols),nI] := 0
								Elseif aHeader[nI,8] == "D"
									aCols[Len(aCols),nI] := CtoD(" / / ")
								Elseif aHeader[nI,8] == "M"
									aCols[Len(aCols),nI] := ""
								Else
									aCols[Len(aCols),nI] := .F.
								EndIf
							Next nI
								
							aCols[nCnt][nPosITEM] 	:= StrZero(nCnt,nTamItem)
							aCols[nCnt][nPosSEQ] 	:= StrZero(nCnt*10,nTamItem)
							aCols[nCnt][nPosSIMB1]	:= "F3"
							aCols[Len(aCols),nUsado+1] := .F.
							nCnt++
						Endif						
					Enddo
				Endif
			Else
				lRet:= .F.
				MsgAlert(STR0034)//"Para usar o preenchimento automatico, e necessario que exista Operacoes cadastradas para a peca selecionada!"
			Endif
		Else
			lRet:= .F.
			MsgAlert(STR0009) //"Para usar o preenchimento automatico, eh necessario que nao tenha nenhum item preenchido !"
		Endif
	Endif
Endif

DbSelectArea("QKN")

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPPA150BMP³ Autor ³ Robson Ramiro A Olivei³ Data ³ 24/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Escolhe operacao do fluxo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA150													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPPA150BMP(nOpc)

Local bBloco     := {|o| GravaBMP(o,nOpc)}
Local lQP150TIT  := ExistBlock("QP150TIT")
Local nLUBmp     := 0 // Numero da Linha do Ultimo BMP Padrao
Local oBmp1      := Nil
Local oBmp10     := Nil
Local oBmp11     := Nil
Local oBmp12     := Nil
Local oBmp13     := Nil
Local oBmp14     := Nil
Local oBmp15     := Nil
Local oBmp16     := Nil
Local oBmp17     := Nil
Local oBmp18     := Nil
Local oBmp19     := Nil
Local oBmp2      := Nil
Local oBmp3      := Nil
Local oBmp4      := Nil
Local oBmp5      := Nil
Local oBmp6      := Nil
Local oBmp7      := Nil
Local oBmp8      := Nil
Local oBmp9      := Nil
Local oDlg       := Nil
Local oScrollBox := Nil

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0010+StrZero(n,nTamItem)); //"Operacao do Item"
						FROM 120,050 TO 258,385 OF oMainWnd PIXEL

oScrollBox := TScrollBox():New(oDlg,10,03,50,135,.T.,.F.,.T.)

DEFINE SBUTTON FROM 30,140 TYPE 1 ACTION IncluiBMP(oDlg) ENABLE OF oDlg
DEFINE SBUTTON FROM 45,140 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

@ 005,05 BITMAP oBmp1 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp1:SetBmp("note")
oBmp1:lAutoSize		:= .F.
oBmp1:cToolTip 		:= STR0011 //"Duplo Click para APAGAR !"
oBmp1:BlDblClick 	:= bBloco

@ 005,35 BITMAP oBmp2 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp2:SetBmp("B8")
oBmp2:lAutoSize		:= .F.
oBmp2:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"B8",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp2:BlDblClick 	:= bBloco
oBmp2:lTransparent 	:= .T.

@ 005,65 BITMAP oBmp3 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp3:SetBmp("D7")
oBmp3:lAutoSize		:= .F.
oBmp3:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"D7",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp3:BlDblClick 	:= bBloco
oBmp3:lTransparent 	:= .T.

@ 005,95 BITMAP oBmp4 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp4:SetBmp("F7")
oBmp4:lAutoSize		:= .F.
oBmp4:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"F7",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp4:BlDblClick 	:= bBloco
oBmp4:lTransparent 	:= .T.

@ 030,05 BITMAP oBmp5 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp5:SetBmp("E5")
oBmp5:lAutoSize		:= .F.
oBmp5:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"E5",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp5:BlDblClick 	:= bBloco
oBmp5:lTransparent 	:= .T.

@ 030,35 BITMAP oBmp6 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp6:SetBmp("E7")
oBmp6:lAutoSize		:= .F.
oBmp6:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"E7",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp6:BlDblClick 	:= bBloco
oBmp6:lTransparent 	:= .T.

@ 030,65 BITMAP oBmp7 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp7:SetBmp("F8")
oBmp7:lAutoSize		:= .F.
oBmp7:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"F8",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp7:BlDblClick 	:= bBloco
oBmp7:lTransparent 	:= .T.

@ 030,95 BITMAP oBmp8 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp8:SetBmp("E9")
oBmp8:lAutoSize		:= .F.
oBmp8:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"E9",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp8:BlDblClick 	:= bBloco
oBmp8:lTransparent 	:= .T.

@ 055,05 BITMAP oBmp9 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp9:SetBmp("F2")
oBmp9:lAutoSize		:= .F.
oBmp9:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"F2",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp9:BlDblClick 	:= bBloco
oBmp9:lTransparent 	:= .T.

@ 055,35 BITMAP oBmp10 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp10:SetBmp("F3")
oBmp10:lAutoSize		:= .F.
oBmp10:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"F3",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp10:BlDblClick 		:= bBloco
oBmp10:lTransparent 	:= .T.

@ 055,65 BITMAP oBmp11 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp11:SetBmp("F4")
oBmp11:lAutoSize		:= .F.
oBmp11:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"F4",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp11:BlDblClick 		:= bBloco
oBmp11:lTransparent 	:= .T.

@ 055,95 BITMAP oBmp12 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp12:SetBmp("F5")
oBmp12:lAutoSize		:= .F.
oBmp12:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"F5",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp12:BlDblClick 		:= bBloco
oBmp12:lTransparent 	:= .T.

@ 080,05 BITMAP oBmp13 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp13:SetBmp("F6")
oBmp13:lAutoSize		:= .F.
oBmp13:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"F6",STR0012}),STR0012) //"Duplo Click para Escolher"
oBmp13:BlDblClick 		:= bBloco
oBmp13:lTransparent 	:= .T.

@ 080,35 BITMAP oBmp14 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp14:SetBmp("E8")
oBmp14:lAutoSize		:= .F.
oBmp14:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"E8",STR0013}),STR0013) //"Transporte"
oBmp14:BlDblClick 		:= bBloco
oBmp14:lTransparent 	:= .T.

@ 080,65 BITMAP oBmp15 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp15:SetBmp("F1")
oBmp15:lAutoSize		:= .F.
oBmp15:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"F1",STR0014}),STR0014) //"Operacao com Inspecao"
oBmp15:BlDblClick 		:= bBloco
oBmp15:lTransparent 	:= .T.

@ 080,95 BITMAP oBmp16 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp16:SetBmp("A3")
oBmp16:lAutoSize		:= .F.
oBmp16:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"A3",STR0015}),STR0015) //"Operacao"
oBmp16:BlDblClick 		:= bBloco
oBmp16:lTransparent 	:= .T.

@ 105,05 BITMAP oBmp17 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp17:SetBmp("B4")
oBmp17:lAutoSize		:= .F.
oBmp17:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"B4",STR0016}),STR0016) //"Inspecao"
oBmp17:BlDblClick 		:= bBloco
oBmp17:lTransparent 	:= .T.

@ 105,35 BITMAP oBmp18 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp18:SetBmp("C7")
oBmp18:lAutoSize		:= .F.
oBmp18:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"C7",STR0017}),STR0017) //"Estocagem"
oBmp18:BlDblClick 		:= bBloco
oBmp18:lTransparent 	:= .T.

@ 105,65 BITMAP oBmp19 REPOSITORY SIZE 030,030 OF oScrollBox NOBORDER PIXEL

oBmp19:SetBmp("D9")
oBmp19:lAutoSize		:= .F.
oBmp19:cToolTip 		:= Iif(lQP150TIT,ExecBlock("QP150TIT", .F., .F.,{"D9",STR0018}),STR0018) //"Decisao"
oBmp19:BlDblClick 		:= bBloco
oBmp19:lTransparent 	:= .T.

If lExecB
   aBmp:=aClone(ExecBlock("QPP150BMP",.F.,.F.))
   nLUBmp := 105 // Linha ultimo BMP Padrao   
   MontaBMP(@oScrollBox,@bBloco,nLUBmp)
Endif                                

ACTIVATE MSDIALOG oDlg

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³GravaBMP  ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 24/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava o BMP que identifica a Operacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GravaBMP(ExpO1, ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Clickado                                    ³±±
±±³          ³ ExpN1 = Opcao do Menu                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA150													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GravaBMP(o,nOpc)

Local cLogo     := o:cResName
Local nPosColun := oGet:oBrowse:nColPos

If Subs(AllTrim(aHeader[nPosColun, 2]),1,8) == "QKN_SIMB"
	aCols[n,nPosColun] := Iif(Len(AllTrim(cLogo))>2,"  ",AllTrim(cLogo))
	oGet:oBrowse:Refresh()
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³QPP150OBSE³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 19.03.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastra Observacoes                        				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QPP150OBSE(ExpN1)                               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ QPPA150													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP150OBSE(nOpc)

Local cCabec    := OemToAnsi(STR0025) //"Texto da Observacao"
Local cChave    := ""
Local cEspecie  := "QPPA150 " //Para gravacao de textos
Local cInf      := ""
Local cTitulo   := OemToAnsi(STR0024) //"Observacoes"
Local lEdit     := .F.
Local nPosChave := aScan(aHeader,{ |x| AllTrim(x[2]) == "QKN_CHAVE" } )
Local nSaveSX8  := GetSX8Len()
Local nTamLin   := TamSX3("QKO_TEXTO")[1]

If nOpc == 3 .or. nOpc == 4
	lEdit := .T.
Endif

axTextos	:= {} 	//Vetor que contem os textos dos Produtos

// Gera/obtem a chave de ligacao com o texto da Peca/Rv
If Empty(aCols[n,nPosChave])
	cChave := GetSXENum("QKN", "QKN_CHAVE",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

	aCols[n,nPosChave] := cChave
Else
	cChave := aCols[n,nPosChave]
EndIf
                                              
cInf := AllTrim(M->QKN_PECA) + " " + M->QKN_REV + STR0026 + StrZero(n,nTamItem) //" Item - "

// Digita a Observacao da Peca
If QO_TEXTO(cChave,cEspecie,nTamlin,cTitulo,cInf, @axtextos,1,cCabec,lEdit)
	// Grava Texto da Peca no QKO
	QO_GrvTxt(cChave,cEspecie,1,@axTextos) 	//QPPXFUN
Endif

DbSelectArea("QKN")
DbSetOrder(1)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA150Seq ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 22/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Acha a Proxima dezena para seguencia (que ainda nao existe)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA150Seq()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA150Seq()

Local lLoop    := .T.
Local nCont    := 0
Local nPosDel  := Len(aHeader) + 1
Local nPosSEQ  := aScan(aHeader, { |x| AllTrim(x[2]) == "QKN_SEQ" })
Local nRetorno := 0
Local nSeed    := 0

If Type("n") <> "U"
	If n > 1
		nSeed 		:= Val(aCols[(n-1),nPosSEQ])
		nRetorno 	:= (nSeed - Mod(nSeed,10)) + 10

		Do While lLoop

			lLoop := .F.
				
			For nCont := 1 To (Len(aCols) - 1)
				If nRetorno == Val(aCols[nCont,nPosSEQ]) .and. !aCols[nCont, nPosDel]
					lLoop 		:= .T.
					nRetorno 	:= (nRetorno - Mod(nRetorno,10)) + 10
					Exit
				Endif
			Next nCont

		Enddo
	Endif
Endif

Return StrZero(nRetorno,nTamItem)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaBMP  ºAutor  ³Microsiga           º Data ³  04/12/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta BMP's Customizados                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MontaBMP(oScrollBox, bBloco, nLUBmp)

Local cAux   := ""
Local nI     := 0
Local oBmp88 := Nil
Local oBmp89 := Nil
Local oBmp90 := Nil
Local oBmp91 := Nil
Local oBmp92 := Nil
Local oBmp93 := Nil
Local oBmp94 := Nil
Local oBmp95 := Nil
Local oBmp96 := Nil
Local oBmp97 := Nil
Local oBmp98 := Nil
Local oBmp99 := Nil

For nI:=1 to if(len(aBmp)<=12,len(aBmp),12)   
	
	If nI == 1    
		cAux := aBmp[1][1]
		If UPPER(cAux) <> "Z1"
			MsgAlert("O nome do primeiro BMP customizado deve ser igual a Z1") 
			Return			
		EndIf
		@ nLUBmp+25,05 BITMAP oBmp88 REPOSITORY aBmp[1][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp88:SetBmp(cAux)
		oBmp88:lAutoSize		:= .F.
		oBmp88:cToolTip 		:= aBmp[1][2]
		oBmp88:BlDblClick 		:= bBloco
		oBmp88:lTransparent 	:= .T.
    EndIf

	If nI == 2
		cAux := aBmp[2][1]   
		If UPPER(cAux) <> "Z2"
			MsgAlert("O nome do segundo BMP customizado deve ser igual a Z2") 
			Return			
		EndIf		
		@ nLUBmp+25,35 BITMAP oBmp89 REPOSITORY aBmp[2][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp89:SetBmp(cAux)
		oBmp89:lAutoSize		:= .F.
		oBmp89:cToolTip 		:= aBmp[2][2]
		oBmp89:BlDblClick 		:= bBloco
		oBmp89:lTransparent 	:= .T.
    EndIf

	If nI == 3    
		cAux := aBmp[3][1]       
		If UPPER(cAux) <> "Z3"
			MsgAlert("O nome do terceiro BMP customizado deve ser igual a Z3") 
			Return			
		EndIf
		@ nLUBmp+25,65 BITMAP oBmp90 REPOSITORY aBmp[3][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp90:SetBmp(cAux)
		oBmp90:lAutoSize		:= .F.
		oBmp90:cToolTip 		:= aBmp[3][2]
		oBmp90:BlDblClick 		:= bBloco
		oBmp90:lTransparent 	:= .T.
    EndIf

	If nI == 4    
		cAux := aBmp[4][1]  
		If UPPER(cAux) <> "Z4"
			MsgAlert("O nome do quarto BMP customizado deve ser igual a Z4") 
			Return			
		EndIf
		@ nLUBmp+25,95 BITMAP oBmp91 REPOSITORY aBmp[4][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp91:SetBmp(cAux)
		oBmp91:lAutoSize		:= .F.
		oBmp91:cToolTip 		:= aBmp[4][2]
		oBmp91:BlDblClick 		:= bBloco
		oBmp91:lTransparent 	:= .T.
    EndIf

	If nI == 5
		cAux := aBmp[5][1]
		If UPPER(cAux) <> "Z5"
			MsgAlert("O nome do quinto BMP customizado deve ser igual a Z5") 
			Return			
		EndIf
		@ nLUBmp+50,05 BITMAP oBmp92 REPOSITORY aBmp[5][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp92:SetBmp(cAux)
		oBmp92:lAutoSize		:= .F.
		oBmp92:cToolTip 		:= aBmp[5][2]
		oBmp92:BlDblClick 		:= bBloco
		oBmp92:lTransparent 	:= .T.
    EndIf

	If nI == 6    
		cAux := aBmp[6][1]       
		If UPPER(cAux) <> "Z6"
			MsgAlert("O nome do sexto BMP customizado deve ser igual a Z6") 
			Return			
		EndIf
		@ nLUBmp+50,35 BITMAP oBmp93 REPOSITORY aBmp[6][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp93:SetBmp(cAux)
		oBmp93:lAutoSize		:= .F.
		oBmp93:cToolTip 		:= aBmp[6][2]
		oBmp93:BlDblClick 		:= bBloco
		oBmp93:lTransparent 	:= .T.
    EndIf

	If nI == 7    
		cAux := aBmp[7][1]  
		If UPPER(cAux) <> "Z7"
			MsgAlert("O nome do setimo BMP customizado deve ser igual a Z7") 
			Return			
		EndIf
		@ nLUBmp+50,65 BITMAP oBmp94 REPOSITORY aBmp[7][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp94:SetBmp(cAux)
		oBmp94:lAutoSize		:= .F.
		oBmp94:cToolTip 		:= aBmp[7][2]
		oBmp94:BlDblClick 		:= bBloco
		oBmp94:lTransparent 	:= .T.
    EndIf

	If nI == 8    
		cAux := aBmp[8][1]       
		If UPPER(cAux) <> "Z8"
			MsgAlert("O nome do oitavo BMP customizado deve ser igual a Z8") 
			Return			
		EndIf
		@ nLUBmp+50,95 BITMAP oBmp95 REPOSITORY aBmp[8][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp95:SetBmp(cAux)
		oBmp95:lAutoSize		:= .F.
		oBmp95:cToolTip 		:= aBmp[8][2]
		oBmp95:BlDblClick 		:= bBloco
		oBmp95:lTransparent 	:= .T.
    EndIf

	If nI == 9    
		cAux := aBmp[9][1]                                               
		If UPPER(cAux) <> "Z9"
			MsgAlert("O nome do nono BMP customizado deve ser igual a Z9") 
			Return			
		EndIf
		@ nLUBmp+75,05 BITMAP oBmp96 REPOSITORY aBmp[9][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp96:SetBmp(cAux)
		oBmp96:lAutoSize		:= .F.
		oBmp96:cToolTip 		:= aBmp[9][2]
		oBmp96:BlDblClick 		:= bBloco
		oBmp96:lTransparent 	:= .T.
    EndIf

	If nI == 10    
		cAux := aBmp[10][1]        
		If UPPER(cAux) <> "ZA"
			MsgAlert("O nome do decimo BMP customizado deve ser igual a ZA") 
			Return			
		EndIf
		@ nLUBmp+75,35 BITMAP oBmp97 REPOSITORY aBmp[10][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp97:SetBmp(cAux)
		oBmp97:lAutoSize		:= .F.
		oBmp97:cToolTip 		:= aBmp[10][2]
		oBmp97:BlDblClick 		:= bBloco
		oBmp97:lTransparent 	:= .T.
    EndIf
    
	If nI == 11    
		cAux := aBmp[11][1]
		If UPPER(cAux) <> "ZB"
			MsgAlert("O nome do decimo-primeiro BMP customizado deve ser igual a ZB") 
			Return			
		EndIf
		@ nLUBmp+75,65 BITMAP oBmp98 REPOSITORY aBmp[11][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp98:SetBmp(cAux)
		oBmp98:lAutoSize		:= .F.
		oBmp98:cToolTip 		:= aBmp[11][2]
		oBmp98:BlDblClick 		:= bBloco
		oBmp98:lTransparent 	:= .T.
    EndIf

	If nI == 12    
		cAux := aBmp[12][1]                    
		If UPPER(cAux) <> "ZC"
			MsgAlert("O nome do decimo-segundo BMP customizado deve ser igual a ZC") 
			Return			
		EndIf
		@ nLUBmp+75,95 BITMAP oBmp99 REPOSITORY aBmp[12][1] SIZE 030,030 OF oScrollBox NOBORDER PIXEL
		oBmp99:SetBmp(cAux)
		oBmp99:lAutoSize		:= .F.
		oBmp99:cToolTip 		:= aBmp[12][2]
		oBmp99:BlDblClick 		:= bBloco
		oBmp99:lTransparent 	:= .T.
    EndIf
Next nI	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IncluiBMP ºAutor  ³Leandro Sabino      º Data ³  20/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permitir incluir uma nova linha quando escolhe somente o BMPº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QPPA150                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IncluiBMP(oDlg)
oGet:LNEWLINE := .F.
oDlg:End()
Return
