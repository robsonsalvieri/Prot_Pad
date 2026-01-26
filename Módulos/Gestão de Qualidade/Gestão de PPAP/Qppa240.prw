#INCLUDE "QPPA240.CH"
#INCLUDE "TOTVS.CH"

Static oSize := Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA240  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 08.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprovacao Interina GM                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA240(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PPAP                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 	0, 1,,.F.},; //"Pesquisar"
					{ OemToAnsi(STR0002), "PPA240Visu", 	0, 2     },; //"Visualizar"
					{ OemToAnsi(STR0003), "PPA240Incl", 	0, 3     },; //"Incluir"
					{ OemToAnsi(STR0004), "PPA240Alte", 	0, 4     },; //"Alterar"
					{ OemToAnsi(STR0005), "PPA240Excl", 	0, 5     },; //"Excluir"
					{ OemToAnsi(STR0025), "QPPR240(.T.)", 	0, 6,,.T.} } //"Imprimir"

Return aRotina

Function QPPA240()

// Define o cabecalho da tela de atualizacoes
Private cCadastro := OemToAnsi(STR0006) //"Aprovacao Interina GM"

Private aRotina := MenuDef()

DbSelectArea("QKH")
DbSetOrder(1)

mBrowse( 6, 1, 22, 75,"QKH",,,,,,)

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA240Visu  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³08.02.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA240Visu(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA240Visu(cAlias,nReg,nOpc)

Local aButtons    := {}
Local aCposVis    := {}
Local oDlg        := NIL
Local oEnch       := Nil
Local oQPPA240Aux := QPPA240AuxClass():New()

Private cAssunto  := .F.
Private cChave    := .F.
Private cInterina := .F.
Private cPlano    := .F.
Private cRazao    := .F.
Private lFLCLAS1  := .F.
Private lFLCLAS2  := .F.
Private lFLCLAS3  := .F.
Private lFLCLAS4  := .F.
Private lFLCLAS5  := .F.
Private oGet      := NIL

aCposVis := {	"QKH_PECA"	, "QKH_REV"		, "QKH_NRA"		, ;
				"QKH_DATA"	, "QKH_GRUPO"	, "QKH_PESO"	, ;
				"QKH_DTATE"	, "QKH_QTDE"	, "QKH_RGMB"	, ;
				"QKH_DTGMB" , "QKH_APRFOR"	, "QKH_CARGO"	, ;
				"QKH_TEL"	, "QKH_FAX"		, "QKH_DTAPR"	, ;
				"QKH_APRQUA", "QKH_DTQUA" 	, "QKH_APRPRO"	, ;
				"QKH_DTPRO" , "QKH_APRCOM" 	, "QKH_DTCOM"	, ;
				"QKH_APRPRJ", "QKH_DTPRJ"	, "QKH_APRAPA"	, ;
				"QKH_DTAPA" , "QKH_AMADIC" 	, "QKH_ECL"		, ;
				"QKH_DTECL"	, "QKH_DTECL"	, "QKH_PKG"		, ;
				"QKH_INTERI" }
				
aButtons := {{ "BMPVISUAL", { || QPPR240() }, OemToAnsi(STR0007), OemToAnsi(STR0026) }} //"Visualizar/Imprimir"###"Vis/Prn"

DbSelectArea(cAlias)

// Monta o oSize
oQPPA240Aux:calculaDimensoesTela()

// Monta Dialog
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Aprovacao Interina GM"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

// Monta o TFolder
oFolder := oQPPA240Aux:montaFolder(oDlg)

RegToMemory("QKH")

// Monta Enchoice
oEnch:=MsMGet():New("QKH",nReg,nOpc, , , ,aCposVis,oSize:aPosObj[1],,,,,,oFolder:aDialogs[1],,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oQPPA240Aux:montaTela(nOpc, oFolder:aDialogs[2])
                        
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA240Incl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³08.02.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA240Incl(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA240Incl(cAlias,nReg,nOpc)

Local aCposVis    := {}
Local lOk         := .F.
Local oDlg        := NIL
Local oEnch       := Nil
Local oQPPA240Aux := QPPA240AuxClass():New()

Private cAssunto  := ""
Private cChave    := ""
Private cInterina := ""
Private cPlano    := ""
Private cRazao    := ""
Private lFLCLAS1  := .F.
Private lFLCLAS2  := .F.
Private lFLCLAS3  := .F.
Private lFLCLAS4  := .F.
Private lFLCLAS5  := .F.
Private oFolder   := NIL

aCposVis := {	"QKH_PECA"	, "QKH_REV"		, "QKH_NRA"		, ;
				"QKH_DATA"	, "QKH_GRUPO"	, "QKH_PESO"	, ;
				"QKH_DTATE"	, "QKH_QTDE"	, "QKH_RGMB"	, ;
				"QKH_DTGMB" , "QKH_APRFOR"	, "QKH_CARGO"	, ;
				"QKH_TEL"	, "QKH_FAX"		, "QKH_DTAPR"	, ;
				"QKH_APRQUA", "QKH_DTQUA" 	, "QKH_APRPRO"	, ;
				"QKH_DTPRO" , "QKH_APRCOM" 	, "QKH_DTCOM"	, ;
				"QKH_APRPRJ", "QKH_DTPRJ"	, "QKH_APRAPA"	, ;
				"QKH_DTAPA" , "QKH_AMADIC" 	, "QKH_ECL"		, ;
				"QKH_DTECL"	, "QKH_DTECL"	, "QKH_PKG"		, ;
				"QKH_INTERI" }
DbSelectArea(cAlias)

// Monta o oSize
oQPPA240Aux:calculaDimensoesTela()

// Monta Dialog
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  // "Aprovacao Interina GM"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
						
// Monta o TFolder
oFolder := oQPPA240Aux:montaFolder(oDlg)

RegToMemory("QKH",.T.)

EnchoiceBar(oDlg,{||lOk := PP240TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , )

// Monta Enchoice
oEnch:=MsMGet():New("QKH",nReg,nOpc, , , ,aCposVis,oSize:aPosObj[1],,,,,,oFolder:aDialogs[1],,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oQPPA240Aux:montaTela(nOpc, oFolder:aDialogs[2])

ACTIVATE MSDIALOG oDlg 

If lOk
	PPA240Grav(nOpc)
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA240Alte  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³08.02.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Alteracao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA240Alte(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PPA240Alte(cAlias,nReg,nOpc)

Local aCposVis    := {}
Local lOk         := .F.
Local oDlg        := NIL
Local oEnch       := Nil
Local oQPPA240Aux := QPPA240AuxClass():New()

Private cAssunto  := ""
Private cChave    := ""
Private cInterina := ""
Private cPlano    := ""
Private cRazao    := ""
Private lFLCLAS1  := .F.
Private lFLCLAS2  := .F.
Private lFLCLAS3  := .F.
Private lFLCLAS4  := .F.
Private lFLCLAS5  := .F.
Private oGet      := NIL

aCposVis := {	"QKH_PECA"	, "QKH_REV"		, "QKH_NRA"		, ;
				"QKH_DATA"	, "QKH_GRUPO"	, "QKH_PESO"	, ;
				"QKH_DTATE"	, "QKH_QTDE"	, "QKH_RGMB"	, ;
				"QKH_DTGMB" , "QKH_APRFOR"	, "QKH_CARGO"	, ;
				"QKH_TEL"	, "QKH_FAX"		, "QKH_DTAPR"	, ;
				"QKH_APRQUA", "QKH_DTQUA" 	, "QKH_APRPRO"	, ;
				"QKH_DTPRO" , "QKH_APRCOM" 	, "QKH_DTCOM"	, ;
				"QKH_APRPRJ", "QKH_DTPRJ"	, "QKH_APRAPA"	, ;
				"QKH_DTAPA" , "QKH_AMADIC" 	, "QKH_ECL"		, ;
				"QKH_DTECL"	, "QKH_DTECL"	, "QKH_PKG"		, ;
				"QKH_INTERI" }
				
If !QPPVldAlt(QKH->QKH_PECA,QKH->QKH_REV)
	Return
Endif

DbSelectArea(cAlias)

// Monta o oSize
oQPPA240Aux:calculaDimensoesTela()

// Monta Dialog
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Aprovacao Interina GM"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

// Monta o TFolder
oFolder := oQPPA240Aux:montaFolder(oDlg)

RegToMemory("QKH")

EnchoiceBar(oDlg,{||lOk := PP240TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , )

// Monta Enchoice
oEnch:=MsMGet():New("QKH",nReg,nOpc, , , ,aCposVis,oSize:aPosObj[1],,,,,,oFolder:aDialogs[1],,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oQPPA240Aux:montaTela(nOpc, oFolder:aDialogs[2])
                        
ACTIVATE MSDIALOG oDlg

If lOk
	PPA240Grav(nOpc)
Endif

Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA240Excl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³08.02.02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Exclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Void PPA240Excl(ExpC1,ExpN1,ExpN2)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                     ³±±
±±³          ³ ExpN1 = Numero do registro                                   ³±±
±±³          ³ ExpN2 = Numero da opcao                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA240Excl(cAlias,nReg,nOpc)

Local aButtons    := {}
Local aCposVis    := {}
Local oDlg        := NIL
Local oEnch       := Nil
Local oQPPA240Aux := QPPA240AuxClass():New()

Private cAssunto  := ""
Private cChave    := ""
Private cInterina := ""
Private cPlano    := ""
Private cRazao    := ""
Private lFLCLAS1  := .F.
Private lFLCLAS2  := .F.
Private lFLCLAS3  := .F.
Private lFLCLAS4  := .F.
Private lFLCLAS5  := .F.
Private oGet      := NIL

aCposVis := {	"QKH_PECA"	, "QKH_REV"		, "QKH_NRA"		, ;
				"QKH_DATA"	, "QKH_GRUPO"	, "QKH_PESO"	, ;
				"QKH_DTATE"	, "QKH_QTDE"	, "QKH_RGMB"	, ;
				"QKH_DTGMB" , "QKH_APRFOR"	, "QKH_CARGO"	, ;
				"QKH_TEL"	, "QKH_FAX"		, "QKH_DTAPR"	, ;
				"QKH_APRQUA", "QKH_DTQUA" 	, "QKH_APRPRO"	, ;
				"QKH_DTPRO" , "QKH_APRCOM" 	, "QKH_DTCOM"	, ;
				"QKH_APRPRJ", "QKH_DTPRJ"	, "QKH_APRAPA"	, ;
				"QKH_DTAPA" , "QKH_AMADIC" 	, "QKH_ECL"		, ;
				"QKH_DTECL"	, "QKH_DTECL"	, "QKH_PKG"		, ;
				"QKH_INTERI" }
				
aButtons := {{ "BMPVISUAL", { || QPPR240() }, OemToAnsi(STR0007), OemToAnsi(STR0026) }} //"Visualizar/Imprimir"###"Vis/Prn"

DbSelectArea(cAlias)

// Monta o oSize
oQPPA240Aux:calculaDimensoesTela()

// Monta Dialog
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006 ) ;  //"Aprovacao Interina GM"
						FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

// Monta o TFolder
oFolder := oQPPA240Aux:montaFolder(oDlg)

RegToMemory("QKH")

EnchoiceBar(oDlg,{|| A240Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)

// Monta Enchoice
oEnch:=MsMGet():New("QKH",nReg,nOpc, , , ,aCposVis,oSize:aPosObj[1],,,,,,oFolder:aDialogs[1],,,,,,,,,)
oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oQPPA240Aux:montaTela(nOpc, oFolder:aDialogs[2])
                        
ACTIVATE MSDIALOG oDlg

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP240Chec³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 08.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza conteudo das Variaveis                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP240Chec()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA240                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP240Chec()

Local nTamLin 	:= 75 // Tamanho da linha do texto
Local cEspecie 	:= "QPPA240"

If !Empty(M->QKH_FLCLAS)
	Do Case
		Case M->QKH_FLCLAS == "A"
			lFLCLAS1 := .T.
		Case M->QKH_FLCLAS == "B"
			lFLCLAS2 := .T.
		Case M->QKH_FLCLAS == "C"
			lFLCLAS3 := .T.
		Case M->QKH_FLCLAS == "D"
			lFLCLAS4 := .T.
		Case M->QKH_FLCLAS == "E"
			lFLCLAS5 := .T.
	Endcase
Endif

If !Empty(M->QKH_CHAV01)
	cRazao		:= QO_Rectxt(M->QKH_CHAV01,cEspecie+"A",1, nTamLin,"QKO")
	cAssunto	:= QO_Rectxt(M->QKH_CHAV01,cEspecie+"B",1, nTamLin,"QKO")
	cPlano		:= QO_Rectxt(M->QKH_CHAV01,cEspecie+"C",1, nTamLin,"QKO")
	cInterina 	:= QO_Rectxt(M->QKH_CHAV01,cEspecie+"D",1, nTamLin,"QKO")
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP240Opt ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 25.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla opcoes da classificacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP240Opt(ExpA1, ExpN1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array contendo os objetos do check                 ³±±
±±³          ³ ExpN1 = Numero da variavel                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA240                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP240Opt(aObjects,nCheck)

Local nCont
                
lFLCLAS1 := .F. ; lFLCLAS2 := .F. 
lFLCLAS3 := .F. ; lFLCLAS4 := .F. ; lFLCLAS5 := .F.

Do Case
	Case nCheck == 1 
		lFLCLAS1 := .T.
	Case nCheck == 2
		lFLCLAS2 := .T.
	Case nCheck == 3
		lFLCLAS3 := .T.
	Case nCheck == 4
		lFLCLAS4 := .T.
	Case nCheck == 5 
		lFLCLAS5 := .T.
Endcase	

For nCont := 1 To Len(aObjects)
	aObjects[nCont]:Refresh()
Next nCont

SysRefresh()

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA240Grav³ Autor ³ Robson Ramiro A Olivei³ Data ³ 08.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao da Aprovacao Interina - Incl./Alter.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA240Grav(ExpC1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA240                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PPA240Grav(nOpc)

Local nCont
Local bCampo	:= { |nCPO| Field(nCPO) }
Local lGraOk	:= .T.
Local aRazao	:= {}  // Array para converter os textos
Local aAssunto 	:= {}
Local aPlano	:= {}
Local aInterina := {}
Local nTamLin	:= 75
Local cEspecie	:= "QPPA240"
Local nSaveSX8	:= GetSX8Len()

DbSelectArea("QKH")
	
Begin Transaction

If ALTERA
	RecLock("QKH",.F.)
Else
	RecLock("QKH",.T.)
Endif

For nCont := 1 To FCount()
	If "FILIAL"$Field(nCont)
		FieldPut(nCont,xFilial("QKH"))
	Else
		FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
	Endif
Next nCont

QKH->QKH_REVINV := Inverte(M->QKH_REV)

Do Case
	Case lFLCLAS1
		QKH_FLCLAS := "A"
	Case lFLCLAS2
		QKH_FLCLAS := "B"
	Case lFLCLAS3
		QKH_FLCLAS := "C"
	Case lFLCLAS4
		QKH_FLCLAS := "D"
	Case lFLCLAS5
		QKH_FLCLAS := "E"

	OtherWise
		QKH_FLCLAS := " "
Endcase

// Verifica se existe texto antes de criar chave
If Empty(cChave) .and. (	!Empty(cRazao) .or. !Empty(cAssunto) .or. ;
							!Empty(cPlano) .or. !Empty(cInterina) )

	cChave := GetSXENum("QKH", "QKH_CHAV01",,3)

	While (GetSX8Len() > nSaveSx8)
		ConfirmSX8()
	End

Endif

If !Empty(cRazao)
	QKH->QKH_CHAV01 := cChave
	aRazao := GeraText(nTamLin, cRazao)
	QO_GrvTxt(cChave,cEspecie+"A",1,@aRazao) 	//QPPXFUN
Endif

If !Empty(cAssunto)
	QKH->QKH_CHAV01 := cChave
	aAssunto := GeraText(nTamLin, cAssunto)
	QO_GrvTxt(cChave,cEspecie+"B",1,@aAssunto)
Endif

If !Empty(cPlano)
	QKH->QKH_CHAV01 := cChave
	aPlano := GeraText(nTamLin, cPlano)
	QO_GrvTxt(cChave,cEspecie+"C",1,@aPlano)
Endif

If !Empty(cInterina)
	QKH->QKH_CHAV01 := cChave
	aInterina := GeraText(nTamLin, cInterina)
	QO_GrvTxt(cChave,cEspecie+"D",1,@aInterina)
Endif

MsUnLock()
	
End Transaction

			
Return lGraOk

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PP240TudOk ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 08.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP240TudOk                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ QPPA240                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP240TudOk

Local lRetorno	:= .T.

If Empty(M->QKH_PECA) .or. Empty(M->QKH_REV)
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
Endif

If INCLUI
	If !ExistChav("QKH",M->QKH_PECA+M->QKH_REV)
		lRetorno := .F.
		Help(" ",1,"JAGRAVADO")  // Campo ja Existe
	Endif
	If !ExistCpo("QK1",M->QKH_PECA+M->QKH_REV)
		lRetorno := .F.
		Help(" ",1,"REGNOIS")  // Nao existe amarracao
	Endif
Endif

Return lRetorno


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A240Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 08.02.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Fucao para exclusao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A240Dele()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA240                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A240Dele()

Local cEspecie := "QPPA240"

DbSelectArea("QKH")

Begin Transaction

If !Empty(QKH->QKH_CHAV01)
	QO_DelTxt(QKH->QKH_CHAV01,cEspecie+"A")	//QPPXFUN
	QO_DelTxt(QKH->QKH_CHAV01,cEspecie+"B")
	QO_DelTxt(QKH->QKH_CHAV01,cEspecie+"C")
	QO_DelTxt(QKH->QKH_CHAV01,cEspecie+"D")
Endif

RecLock("QKH",.F.)
DbDelete()
MsUnLock()
		
End Transaction

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraText  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 05.03.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transformacao do campo memo em array para gravacao no QKO  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GeraText(ExpN1,ExpN2,ExpC1)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Tamanho da linha 								  ³±±
±±³          ³ ExpC1 = String a ser convertida 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA240                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GeraText(nTamlin, cVar)

Local cDescricao
Local nLinTotal
Local nPasso
Local axTextos := {}
Local nLi
Local nPos

cDescricao := ""
	
nLinTotal  := MlCount(cVar, nTamLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza vetor com o texto digitado		   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPasso := 1 to nLinTotal
	cDescricao += MemoLine( cVar, nTamLin, nPasso ) + Chr(13)+Chr(10)
Next nPasso
		
nLi := 1

nPos := aScan(axTextos, {|x| x[1] == nLi })

If nPos == 0
	Aadd(axTextos, { nLi, cDescricao } )
Else
	axTextos[nPos][2] := cDescricao
Endif

Return(axTextos)

/*/{Protheus.doc} QPPA240AuxClass
Classe agrupadora de métodos auxiliares do QPPA240
@author Jefferson Possidonio
@since 28/08/2024
@version 1.0
/*/
CLASS QPPA240AuxClass FROM LongNameClass

    METHOD new() Constructor
    
	METHOD calculaDimensoesTela()
	METHOD montaFolder(oDlg)
	METHOD montaTela(nOpc, oDlg)

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author Jefferson Possidonio
@since 28/08/2024
@version 1.0
/*/
METHOD new() CLASS QPPA240AuxClass

Return Self

/*/{Protheus.doc} calculaDimensoesTela
Método que monta o oSize
@author Jefferson Possidonio
@since 28/08/2024
@version 1.0
/*/
METHOD calculaDimensoesTela() CLASS QPPA240AuxClass

	oSize := FwDefSize():New( .F. )
	oSize:AddObject( "DIALOG", 100, 100, .T., .T., .T. ) // Totalmente dimensionavel
	oSize:lProp := .T.                                   // Proporcional             
	oSize:aMargins := { 3, 3, 3, 3 }                     // Espaco ao lado dos objetos 0, entre eles 3 
	oSize:Process()                                      // Dispara os calculos  

RETURN

/*/{Protheus.doc} montaFolder
Método que monta o Folder
@author Jefferson Possidonio
@since 28/08/2024
@version 1.0
@param - oDlg, objeto, Objeto da tela 
@return oFolder
/*/
METHOD montaFolder(oDlg) CLASS QPPA240AuxClass

	Local aPaginas := {}
	Local aTitulos := {}

	//Montagem do folder
    Aadd(aTitulos,OemToAnsi(STR0048)) // Dados da Peça
    Aadd(aTitulos,OemToAnsi(STR0009)) // Avaliação
    
    Aadd(aPaginas, STR0049) // Peca
    Aadd(aPaginas, STR0050) // Avaliacao

	oFolder := TFolder():New(oSize:GetDimension("DIALOG","LININI"), oSize:GetDimension("DIALOG","COLINI"),aTitulos,aPaginas,oDlg,,,, .T., .F.,oSize:GetDimension("DIALOG","XSIZE"),oSize:GetDimension("DIALOG","YSIZE"))
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

RETURN oFolder

/*/{Protheus.doc} montaTela
Método que monta o Tela de Avaliação
@author Jefferson Possidonio
@since 28/08/2024
@version 1.0
@param 01 - nOpc, numerico, Opção de operação (Inc, Alt, Exc) 
@param 02 - oDlg, objeto  , Objeto da tela
/*/
METHOD montaTela(nOpc, oDlg) CLASS QPPA240AuxClass

Local aObjects   := {}
Local oAssunto   := Nil
Local oAVAPA     := Nil
Local oAVCEP     := Nil
Local oAVDIM     := Nil
Local oAVENG     := Nil
Local oAVLAB     := Nil
Local oCkFLCLAS1 := Nil
Local oCkFLCLAS2 := Nil
Local oCkFLCLAS3 := Nil
Local oCkFLCLAS4 := Nil
Local oCkFLCLAS5 := Nil
Local oFwLayer   := Nil
Local oInterina  := Nil
Local oPanel1    := Nil
Local oPanel2    := Nil
Local oPlano     := Nil
Local oRazao     := Nil
Local oScrollBox := Nil

If nOpc <> 3
	QPP240CHEC()
Endif

//Criando a camada
oFwLayer := FwLayer():New()
oFwLayer:init(oDlg,.F.)

//Adicionando linhas 
oFWLayer:addLine("INTERINA" , 98, .F.)

//Adicionando as colunas das linhas
oFWLayer:addCollumn("COLCLASSE" , 050, .F., "INTERINA")
oFWLayer:addCollumn("COLMEMO"   , 050, .F., "INTERINA")

oFWLayer:AddWindow("COLCLASSE" ,"oPanel1", STR0051 ,100,.F.,.F.,,"INTERINA" ,{ || }) // "Classificação"
oFWLayer:AddWindow("COLMEMO"   ,"oPanel2", STR0052 ,100,.F.,.F.,,"INTERINA" ,{ || }) // "Descrições"

//Criando os paineis
oPanel1 := oFWLayer:GetWinPanel("COLCLASSE"  ,"oPanel1" ,"INTERINA")
oPanel2 := oFWLayer:GetWinPanel("COLMEMO"    ,"oPanel2" ,"INTERINA")

oScrollBox := TScrollBox():New(oPanel2,,,,,.T.,.F.,.T.)
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

@ 001,080 SAY OemToAnsi(STR0008) SIZE 150,010 COLOR CLR_RED OF oPanel1 PIXEL;  //"A = Aprovado      I = Interina       N = Nao Realizado"						

@ 015,001 SAY OemToAnsi(STR0009) SIZE 040,010 OF oPanel1 PIXEL  //"Avaliacao"

@ 015,045 SAY OemToAnsi(STR0010) SIZE 015,010 OF oPanel1 PIXEL //"DIM"

@ 015,065 MSGET oAVDIM VAR M->QKH_AVDIM PICTURE PesqPict("QKH", "QKH_AVDIM");
			SIZE 005,005 OF oPanel1 PIXEL VALID CheckSx3("QKH_AVDIM",M->QKH_AVDIM)

@ 015,100 SAY OemToAnsi(STR0011) SIZE 019,010 OF oPanel1 PIXEL  //"APAR"

@ 015,120 MSGET oAVAPA VAR M->QKH_AVAPA PICTURE PesqPict("QKH", "QKH_AVAPA");
			SIZE 005,005 OF oPanel1 PIXEL  VALID CheckSx3("QKH_AVAPA",M->QKH_AVAPA)

@ 015,155 SAY OemToAnsi(STR0012) SIZE 015,010 OF oPanel1 PIXEL  //"LAB"

@ 015,175 MSGET oAVLAB VAR M->QKH_AVLAB PICTURE PesqPict("QKH", "QKH_AVLAB");
			SIZE 005,005 OF oPanel1 PIXEL  VALID CheckSx3("QKH_AVLAB",M->QKH_AVLAB)

@ 015,210 SAY OemToAnsi(STR0013) SIZE 019,010 OF oPanel1 PIXEL  //"PROC"

@ 015,230 MSGET oAVCEP VAR M->QKH_AVCEP PICTURE PesqPict("QKH", "QKH_AVCEP");
			SIZE 005,005 OF oPanel1 PIXEL VALID CheckSx3("QKH_AVCEP",M->QKH_AVCEP)

@ 015,265 SAY OemToAnsi(STR0014) SIZE 015,010 OF oPanel1 PIXEL //"ENG"

@ 015,285 MSGET oAVENG VAR M->QKH_AVENG PICTURE PesqPict("QKH", "QKH_AVENG");
			SIZE 005,005 OF oPanel1 PIXEL VALID CheckSx3("QKH_AVENG",M->QKH_AVENG)


@ 022,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oPanel1 PIXEL

@ 035,001 SAY OemToAnsi(STR0015) SIZE 150,010 COLOR CLR_RED OF oPanel1 PIXEL;  //"Classificacao Interina"

@ 050,003 CHECKBOX oCkFLCLAS1 VAR lFLCLAS1 SIZE 008,006 OF oPanel1 PIXEL;
			ON CLICK Iif(lFLCLAS1,QPP240Opt(aObjects,1), )

@ 050,015 SAY OemToAnsi(STR0016) SIZE 452,010 OF oPanel1 PIXEL //"Classe A - Pecas foram produzidas usando 100% ferramental, porem nem todos os requisitos foram satisfeitos"

@ 065,003 CHECKBOX oCkFLCLAS2 VAR lFLCLAS2 SIZE 008,006 OF oPanel1 PIXEL;
			ON CLICK Iif(lFLCLAS2,QPP240Opt(aObjects,2), )
			 	 
@ 065,015 SAY OemToAnsi(STR0017) SIZE 452,010 OF oPanel1 PIXEL //"Classe B - Pecas foram produzidas usando 100% ferramental, e requerem retrabalho para satisfazer os requisitos"

@ 080,003 CHECKBOX oCkFLCLAS3 VAR lFLCLAS3 SIZE 008,006 OF oPanel1 PIXEL;
			ON CLICK Iif(lFLCLAS3,QPP240Opt(aObjects,3), )
			 	 
@ 080,015 SAY OemToAnsi(STR0018) SIZE 452,010 OF oPanel1 PIXEL //"Classe C - Pecas nao sao produzidas usando 100% ferramental de producao,porem satisfaz as especificacoes"

@ 095,003 CHECKBOX oCkFLCLAS4 VAR lFLCLAS4 SIZE 008,006 OF oPanel1 PIXEL;
			ON CLICK Iif(lFLCLAS4,QPP240Opt(aObjects,4), )
			 	 
@ 095,015 SAY OemToAnsi(STR0019) SIZE 452,010 OF oPanel1 PIXEL //"Classe D - Pecas nao satisfazem especificacoes de registro de projeto"

@ 110,003 CHECKBOX oCkFLCLAS5 VAR lFLCLAS5 SIZE 008,006 OF oPanel1 PIXEL;
			ON CLICK Iif(lFLCLAS5,QPP240Opt(aObjects,5), )
	 	 
@ 110,015 SAY OemToAnsi(STR0020) SIZE 452,010 OF oPanel1 PIXEL //"Classe E - Pecas nao satisfazem especificacoes de registro de projeto, Pecas Classe E exigem substituicao para venda"

aObjects := { oCkFLCLAS1, oCkFLCLAS2, oCkFLCLAS3, oCkFLCLAS4, oCkFLCLAS5 }

@ 016,003 SAY OemToAnsi(STR0021) SIZE 070,010 COLOR CLR_RED OF oScrollBox PIXEL  //"Resumo das Razoes"

@ 026,040 GET oRazao VAR cRazao MEMO NO VSCROLL SIZE 231, 051 OF oScrollBox PIXEL


@ 076,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL 

@ 091,003 SAY OemToAnsi(STR0022) SIZE 216,010 COLOR CLR_RED OF oScrollBox PIXEL  //"Assuntos:(Relacione DIM, APP, Questoes de Lancamentos)"

@ 101,040 GET oAssunto VAR cAssunto MEMO NO VSCROLL SIZE 231, 051 OF oScrollBox PIXEL


@ 151,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL 

@ 161,003 SAY OemToAnsi(STR0023) SIZE 136,010 COLOR CLR_RED OF oScrollBox PIXEL  //"Plano de Acao (fornecer com prazos)"

@ 176,040 GET oPlano VAR cPlano MEMO NO VSCROLL SIZE 231, 051 OF oScrollBox PIXEL


@ 226,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL 

@ 236,003 SAY OemToAnsi(STR0024) SIZE 280,010 COLOR CLR_RED OF oScrollBox PIXEL  //"Estao os assuntos referentes a interina mencionadas no plano GP-12 (Explique)"

@ 251,040 GET oInterina VAR cInterina MEMO NO VSCROLL SIZE 231, 051 OF oScrollBox PIXEL

@ 316,003 SAY REPLICATE(OemToAnsi("_"),150) SIZE 310,007 OF oScrollBox PIXEL 

If nOpc <> 3 .and. nOpc <> 4
	oAVDIM:lReadOnly		:= .T.
	oAVAPA:lReadOnly		:= .T.
	oAVLAB:lReadOnly		:= .T.
	oAVCEP:lReadOnly		:= .T.
	oAVENG:lReadOnly		:= .T.
	oCkFLCLAS1:lReadOnly	:= .T.
	oCkFLCLAS2:lReadOnly	:= .T.	
	oCkFLCLAS3:lReadOnly	:= .T.
	oCkFLCLAS4:lReadOnly	:= .T.
	oCkFLCLAS5:lReadOnly	:= .T.
	oRazao:lReadOnly		:= .T.
	oAssunto:lReadOnly		:= .T.
	oPlano:lReadOnly		:= .T.
	oInterina:lReadOnly		:= .T.
Endif

If !Empty(M->QKH_CHAV01)
	cChave := M->QKH_CHAV01
Endif

Return
