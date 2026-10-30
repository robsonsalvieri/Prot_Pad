#INCLUDE "EICAXXX.CH"     
#Include "AVERAGE.CH"           

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ EICAXXX	³ Autor ³ Lucas/Claudia Cabral  ³ Data ³ 25/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Provisao de Gastos SIGAEICxSIGACONxSIGAFIN			  		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAEIC   							         					     ³±±
±±ÃÄÄÄÄÄÄÄÄÂÄÁÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA   ³ BOPS ³Prograd.³ALTERACAO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³25.08.01³XXXXXX³Lucas   ³Inicio do desenvolvimento...                  ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function EICAXXX()

PRIVATE aRotina := { { STR0004 ,"AxPesqui"  , 0 , 1},;	// Pesquisar
	{ STR0005 ,"AXXXVisual", 0 , 2},;	// Visualizar
	{ STR0006 ,"AXXXInclui", 0 , 3},;	// Incluir
	{ STR0008 ,"AXXXDeleta", 0 , 5} }	// Excluir

PRIVATE cCadastro := ""
PRIVATE nDecPais  := MSDECIMAIS(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas...								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Contabilizacao On-Line/Off-Line...			     ³
//³ mv_par02 - Mostra Lancto Contabeis...					     ³
//³ mv_par03 - Aglutinar Lanctos...							     ³
//³ mv_par04 - Tipo de Factura? Factura AA ou Outros Gastos...   ³
//³ mv_par05 - Tipo de Rateio? 1 - Peso, 2-Quantidade e 3-Valor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Pergunte("EICXXX",.T.)
	Return
EndIf

/* nopado por RNLP - 18/09/20 - OSSME-5260 - Função AXXXPerg não existente no sistema
Set Key VK_F12 To AXXXPerg()
*/

mBrowse( 6, 1,22,75,"SW6")

Set Key VK_F12 To

Return( .T. )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ AXXXVisual ³ Autor ³ Lucas/Claudia Cabral³ Data ³ 25.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de visualizacao das Notas de Cr‚dito...			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AXXXVisual(ExpC1,ExpN1,ExpN2) 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo											  ³±±
±±³		 	 ³ ExpN1 = Numero do registro 										  ³±±
±±³		 	 ³ ExpN2 = Numero da opcao selecionada 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ EICAXXX	 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AXXXVisual(cAlias,nReg,nOpcx)
LOCAL oDlg, oGet, lRet := .T., oFnt
LOCAL nI := 0
LOCAL nXXXFob := 0
LOCAL nXXXFrete := 0
LOCAL nXXXSeguro := 0
LOCAL aImpHAWB := {}
LOCAL aImpDespes := {}
LOCAL cAXXXFor
LOCAL cAXXXnome
LOCAL oAXXXFor
LOCAL oAXXXnome
LOCAL oXXXHawb
LOCAL nOpca := 0
LOCAL aGetArea := GetArea()

DEFINE FONT oFnt  NAME "Arial" SIZE 09,11 BOLD
DEFINE FONT oFnt1  NAME "Arial" SIZE 10,11 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0],aHeader,Continua,nOpc:=2,aCols:={}
PRIVATE nTotalFat := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas...								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Contabilizacao On-Line/Off-Line...					  ³
//³ mv_par02 - Mostra Lancto Contabeis...								  ³
//³ mv_par03 - Aglutinar Lanctos...								        ³
//³ mv_par04 - Tipo de Factura? Factura AA ou Outros Gastos...   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("EICXXX",.F.)

aHeader := {}

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("WD_DESPESA")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!",x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_DESCDES")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_VALOR_R")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_FORN")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_LOJA")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_GERFIN")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo,"!",x3_tamanho, x3_decimal,;
	'Pertence("SN")',x3_usado,x3_tipo, x3_arquivo, x3_context } )
DbSetOrder(1)

PRIVATE cAXXXHawb := SW6->W6_HAWB

If ! Empty(SW6->W6_DT_ENCE)
	//Help(" ",1,"CERRADO")
	MsgStop("Proceso ya cierrado!!!","Atenci¢n")
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche o aCOLS com base nos Valores FOB e Despesas...  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AXXXACOLS(nOpcx)

If Len(aCols) == 0
	//Help(" ",1,"NOPROV")
	MsgStop("No Hay Despesas o Impuestos para provisionar!!!","Atenci¢n")
	Return(.F.)
EndIf	


If MV_PAR04 == 1
	IF SY5->(DbSeek(xFilial("SY5")+SW6->W6_DESP) ) 
		cAXXXFor  := SY5->Y5_COD
		cAXXXNome := SY5->Y5_NOME
	ENDIF
Else	                          
	cAXXXFor  := ""
	cAXXXNome := "DIVERSOS"
Endif	

oBrowse	:=	GetMBrowse()
Setapilha()

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 37.8,80 OF oBrowse //oMainWnd

@ 16, 010 SAY OemtoAnsi(STR0001) SIZE 40, 7 OF oDlg PIXEL
@ 16, 050 MSGET oXXXHawb VAR cAXXXHawb PICTURE PesqPict("SW9","W9_HAWB") SIZE 50,11 PIXEL WHEN .F. OF oDlg

@ 32, 010 SAY OemtoAnsi(STR0009) SIZE 40, 7 OF oDlg PIXEL

@ 32, 050 SAY  alltrim(cAXXXFor) + " - " + cAXXXNome SIZE 150,11   of oDLG  PIXEL FONT oFnt COLOR CLR_HBLUE

oGet := MSGetDados():New(62,5,165,310,nOpcx,"AXXXLinOk","AXXXTudOk","",.T.)

@ 175, 010 SAY OemtoAnsi(STR0010) SIZE 120, 10 OF oDlg PIXEL	
@ 175, 241 MSGET nTotalFat PICTURE PesqPict("SE2","E2_VALOR") SIZE 70, 11 OF oDlg PIXEL  FONT oFnt1 COLOR CLR_BLACK   WHEN .F.

ACTIVATE MSDIALOG oDlg

Setapilha()
RestArea( aGetArea )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da janela									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(1)
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³AXXXInclui³ Autor ³ Lucas/Claudia Cabral  ³ Data ³ 21.01.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de inclusao de Provisao de Gastos de Importacao...³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AXXXInclui(ExpC1,ExpN1,ExpN2) 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo											  ³±±
±±³			 ³ ExpN1 = Numero do registro 										  ³±±
±±³			 ³ ExpN2 = Numero da opcao selecionada 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ EICAXXX  																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AXXXInclui(cAlias,nReg,nOpcx)
LOCAL oDlg, oGet, lRet := .T., oFnt
LOCAL nI := 0
LOCAL nXXXFob := 0
LOCAL nXXXFrete := 0
LOCAL nXXXSeguro := 0
LOCAL aImpHAWB := {}
LOCAL aImpDespes := {}
LOCAL cAXXXFor
LOCAL cAXXXnome
LOCAL oAXXXFor
LOCAL oAXXXnome
LOCAL oXXXHawb
LOCAL nOpca := 0
LOCAL aGetArea := GetArea()

DEFINE FONT oFnt  NAME "Arial" SIZE 09,11 BOLD
DEFINE FONT oFnt1  NAME "Arial" SIZE 10,11 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0],aHeader,Continua,nOpc:=3,aCols:={}
PRIVATE nTotalFat := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas...								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Contabilizacao On-Line/Off-Line...					  ³
//³ mv_par02 - Mostra Lancto Contabeis...								  ³
//³ mv_par03 - Aglutinar Lanctos...								        ³
//³ mv_par04 - Tipo de Factura? Factura AA ou Outros Gastos...   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("EICXXX",.f.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo de Contra-Prova para Contabilizacao On-Line...  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01 == 1
	ContabEIC("HEADER",,.T.,"EICAXXX")
EndIf	

aHeader := {}

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("WD_DESPESA")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!",x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_DESCDES")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_VALOR_R")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_FORN")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_LOJA")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_GERFIN")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo,"!",x3_tamanho, x3_decimal,;
	'Pertence("SN12")',x3_usado,x3_tipo, x3_arquivo, x3_context } )
DbSetOrder(1)

PRIVATE cAXXXHawb := SW6->W6_HAWB

If ! Empty(SW6->W6_DT_ENCE)
	//Help(" ",1,"CERRADO")
	MsgStop("Proceso ya cierrado!!!","Atenci¢n")
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche o aCOLS com base nos Valores FOB e Despesas...  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AXXXACOLS(nOpcx)

If Len(aCols) == 0
	//Help(" ",1,"NOPROV")
	MsgStop("No Hay Despesas o Impuestos para provisionar!!!","Atenci¢n")
	Return(.F.)
EndIf	

If MV_PAR04 == 1
	IF SY5->(DbSeek(xFilial("SY5")+SW6->W6_DESP) ) 
		cAXXXFor  := SY5->Y5_COD
		cAXXXNome := SY5->Y5_NOME
	ENDIF
Else	                          
	cAXXXFor  := ""
	cAXXXNome := "DIVERSOS"
Endif	

oBrowse	:=	GetMBrowse()
Setapilha()

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 37.8,80 OF oBrowse //oMainWnd

@ 16, 010 SAY OemtoAnsi(STR0001) SIZE 40, 7 OF oDlg PIXEL
@ 16, 050 MSGET oXXXHawb VAR cAXXXHawb PICTURE PesqPict("SW9","W9_HAWB") SIZE 50,11 PIXEL WHEN .F. OF oDlg

@ 32, 010 SAY OemtoAnsi(STR0009) SIZE 40, 7 OF oDlg PIXEL

@ 32, 050 SAY  alltrim(cAXXXFor) + " - " + cAXXXNome SIZE 150,11   of oDLG  PIXEL FONT oFnt COLOR CLR_HBLUE

oGet := MSGetDados():New(62,5,165,310,nOpcx,"AXXXLinOk","AXXXTudOk","",.T.)

@ 175, 010 SAY OemtoAnsi(STR0010) SIZE 120, 10 OF oDlg PIXEL	
@ 175, 241 MSGET nTotalFat PICTURE PesqPict("SE2","E2_VALOR") SIZE 70, 11 OF oDlg PIXEL  FONT oFnt1 COLOR CLR_BLACK   WHEN .F.

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGet:TudoOk(),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{|| oDlg:End()})

Setapilha()
RestArea( aGetArea )

If nOpca == 1
	AXXXGrava()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha ContabilizacÆo...												  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01 == 1
	ContabEIC("FOOTER")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da janela									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(1)
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ AXXXAltera ³ Autor ³ Lucas/Claudia Cabral³ Data ³ 25.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para alteracao da Provisao de Gastos/Importacao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AXXXAltera(ExpC1,ExpN1,ExpN2) 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo											  ³±±
±±³		 	 ³ ExpN1 = Numero do registro 										  ³±±
±±³		 	 ³ ExpN2 = Numero da opcao selecionada 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ EICAXXX	 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AXXXAltera(cAlias,nReg,nOpcx)
LOCAL oDlg, oGet, lRet := .T., oFnt
LOCAL nI := 0
LOCAL nXXXFob := 0
LOCAL nXXXFrete := 0
LOCAL nXXXSeguro := 0
LOCAL aImpHAWB := {}
LOCAL aImpDespes := {}
LOCAL cAXXXFor
LOCAL cAXXXnome
LOCAL oAXXXFor
LOCAL oAXXXnome
LOCAL oXXXHawb
LOCAL nOpca := 0
LOCAL aGetArea := GetArea()

DEFINE FONT oFnt  NAME "Arial" SIZE 09,11 BOLD
DEFINE FONT oFnt1  NAME "Arial" SIZE 10,11 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0],aHeader,Continua,nOpc:=4,aCols:={}
PRIVATE nTotalFat := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas...								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Contabilizacao On-Line/Off-Line...					  ³
//³ mv_par02 - Mostra Lancto Contabeis...								  ³
//³ mv_par03 - Aglutinar Lanctos...								        ³
//³ mv_par04 - Tipo de Factura? Factura AA ou Outros Gastos...   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("EICXXX",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo de Contra-Prova para Contabilizacao On-Line...  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01 == 1
	ContabEIC("HEADER",,.T.,"EICAXXX")
EndIf	

aHeader := {}

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("WD_DESPESA")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!",x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_DESCDES")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_VALOR_R")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_FORN")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_LOJA")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_GERFIN")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo,"!",x3_tamanho, x3_decimal,;
	'Pertence("SN12")',x3_usado,x3_tipo, x3_arquivo, x3_context } )
DbSetOrder(1)

PRIVATE cAXXXHawb := SW6->W6_HAWB

If ! Empty(SW6->W6_DT_ENCE)
	//Help(" ",1,"CERRADO")
	MsgStop("Proceso ya cierrado!!!","Atenci¢n")
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche o aCOLS com base nos Valores FOB e Despesas...  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AXXXACOLS(nOpcx)

If Len(aCols) == 0
	//Help(" ",1,"NOPROV")
	MsgStop("No Hay Despesas o Impuestos para provisionar!!!","Atenci¢n")
	Return(.F.)
EndIf	


If MV_PAR04 == 1
	IF SY5->(DbSeek(xFilial("SY5")+SW6->W6_DESP) ) 
		cAXXXFor  := SY5->Y5_COD
		cAXXXNome := SY5->Y5_NOME
	ENDIF
Else	                          
	cAXXXFor  := ""
	cAXXXNome := "DIVERSOS"
Endif	

oBrowse	:=	GetMBrowse()
Setapilha()

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 37.8,80 OF oBrowse //oMainWnd

@ 16, 010 SAY OemtoAnsi(STR0001) SIZE 40, 7 OF oDlg PIXEL
@ 16, 050 MSGET oXXXHawb VAR cAXXXHawb PICTURE PesqPict("SW9","W9_HAWB") SIZE 50,11 PIXEL WHEN .F. OF oDlg

@ 32, 010 SAY OemtoAnsi(STR0009) SIZE 40, 7 OF oDlg PIXEL

@ 32, 050 SAY  alltrim(cAXXXFor) + " - " + cAXXXNome SIZE 150,11   of oDLG  PIXEL FONT oFnt COLOR CLR_HBLUE

oGet := MSGetDados():New(62,5,165,310,nOpcx,"AXXXLinOk","AXXXTudOk","",.T.)

@ 175, 010 SAY OemtoAnsi(STR0010) SIZE 120, 10 OF oDlg PIXEL	
@ 175, 241 MSGET nTotalFat PICTURE PesqPict("SE2","E2_VALOR") SIZE 70, 11 OF oDlg PIXEL  FONT oFnt1 COLOR CLR_BLACK   WHEN .F.

ACTIVATE MSDIALOG  oDlg ON INIT EnchoiceBar(oDlg,{||If(oGet:TudoOk(),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{|| oDlg:End()})

Setapilha()
RestArea( aGetArea )

If nOpca == 1
	AXXXExclui()
	AXXXGrava()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha ContabilizacÆo...												  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01 == 1
	ContabEIC("FOOTER")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da janela									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(1)
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ AXXXDeleta ³ Autor ³ Lucas/Claudia Cabral³ Data ³ 25.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para exclusao  da Provisao de Gastos/Importacao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AXXXDeleta(ExpC1,ExpN1,ExpN2) 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo											  ³±±
±±³		 	 ³ ExpN1 = Numero do registro 										  ³±±
±±³		 	 ³ ExpN2 = Numero da opcao selecionada 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ EICAXXX	 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AXXXDeleta(cAlias,nReg,nOpcx)
LOCAL oDlg, oGet, lRet := .T., oFnt
LOCAL nI := 0
LOCAL nXXXFob := 0
LOCAL nXXXFrete := 0
LOCAL nXXXSeguro := 0
LOCAL aImpHAWB := {}
LOCAL aImpDespes := {}
LOCAL cAXXXFor
LOCAL cAXXXnome
LOCAL oAXXXFor
LOCAL oAXXXnome
LOCAL oXXXHawb
LOCAL nOpca := 0
LOCAL aGetArea := GetArea()

DEFINE FONT oFnt  NAME "Arial" SIZE 09,11 BOLD
DEFINE FONT oFnt1  NAME "Arial" SIZE 10,11 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0],aGETS[0],aHeader,Continua,nOpc:=5,aCols:={}
PRIVATE nTotalFat := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas...								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Contabilizacao On-Line/Off-Line...					  ³
//³ mv_par02 - Mostra Lancto Contabeis...								  ³
//³ mv_par03 - Aglutinar Lanctos...								        ³
//³ mv_par04 - Tipo de Factura? Factura AA ou Outros Gastos...   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("EICXXX",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo de Contra-Prova para Contabilizacao On-Line...  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01 == 1
	ContabEIC("HEADER",,.T.,"EICAXXX")
EndIf	

aHeader := {}

DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("WD_DESPESA")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, "@!",x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_DESCDES")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_VALOR_R")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_FORN")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_LOJA")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal,;
	".F.",x3_usado, x3_tipo, x3_arquivo, x3_context } )
DbSeek("WD_GERFIN")
AADD(aHeader,{ TRIM(X3Titulo()), x3_campo,"!",x3_tamanho, x3_decimal,;
	'Pertence("SN12")',x3_usado,x3_tipo, x3_arquivo, x3_context } )
DbSetOrder(1)

PRIVATE cAXXXHawb := SW6->W6_HAWB

If ! Empty(SW6->W6_DT_ENCE)
	//Help(" ",1,"CERRADO")
	MsgStop("Proceso ya cierrado!!!","Atenci¢n")
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preenche o aCOLS com base nos Valores FOB e Despesas...  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AXXXACOLS(nOpcx)

If Len(aCols) == 0
	//Help(" ",1,"NOPROV")
	MsgStop("No Hay Despesas o Impuestos para provisionar!!!","Atenci¢n")
	Return(.F.)
EndIf	


If MV_PAR04 == 1
	IF SY5->(DbSeek(xFilial("SY5")+SW6->W6_DESP) ) 
		cAXXXFor  := SY5->Y5_COD
		cAXXXNome := SY5->Y5_NOME
	ENDIF
Else	                          
	cAXXXFor  := ""
	cAXXXNome := "DIVERSOS"
Endif	

oBrowse	:=	GetMBrowse()
Setapilha()

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 37.8,80 OF oBrowse //oMainWnd

@ 16, 010 SAY OemtoAnsi(STR0001) SIZE 40, 7 OF oDlg PIXEL
@ 16, 050 MSGET oXXXHawb VAR cAXXXHawb PICTURE PesqPict("SW9","W9_HAWB") SIZE 50,11 PIXEL WHEN .F. OF oDlg

@ 32, 010 SAY OemtoAnsi(STR0009) SIZE 40, 7 OF oDlg PIXEL

@ 32, 050 SAY  alltrim(cAXXXFor) + " - " + cAXXXNome SIZE 150,11   of oDLG  PIXEL FONT oFnt COLOR CLR_HBLUE

oGet := MSGetDados():New(62,5,165,310,nOpcx,"AXXXLinOk","AXXXTudOk","",.T.)

@ 175, 010 SAY OemtoAnsi(STR0010) SIZE 120, 10 OF oDlg PIXEL	
@ 175, 241 MSGET nTotalFat PICTURE PesqPict("SE2","E2_VALOR") SIZE 70, 11 OF oDlg PIXEL  FONT oFnt1 COLOR CLR_BLACK   WHEN .F.

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGet:TudoOk(),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{|| oDlg:End()})

Setapilha()
RestArea( aGetArea )

If nOpca == 1
	AXXXExclui()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha ContabilizacÆo...												  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par01 == 1
	ContabEIC("FOOTER")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da janela									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
dbSetOrder(1)
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ AXXXGrava  ³ Autor ³ Lucas/Claudia Cabral³ Data ³ 25.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para gravacao da Provisao de Gastos/Importacao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AXXXGrava()															     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                            										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ EICAXXX	 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AXXXGrava()
LOCAL nI := 0, lRet := .T.
LOCAL aCampos   := {}
LOCAL nItem     := 0
LOCAL cDescDes  := ""
LOCAL cAXXXForn := ""
LOCAL cAXXXLoja := ""

AADD(aCampos,{"TR_HAWB"   ,"C",17,0})
AADD(aCampos,{"TR_ITEM"   ,"C",02,0})
AADD(aCampos,{"TR_DESPESA","C",03,0})
AADD(aCampos,{"TR_DESCDES","C",30,0})
AADD(aCampos,{"TR_VALOR_R","N",16,2})
AADD(aCampos,{"TR_FORN"   ,"C",06,0})
AADD(aCampos,{"TR_LOJA"   ,"C",02,0})
AADD(aCampos,{"TR_GERFIN" ,"C",01,0})
AADD(aCampos,{"TR_DES_ADI","D",08,0})

cFileWork := E_CriaTrab(,aCampos,"TRB")
E_IndRegua("TRB",cFileWork+TEOrdBagExt(),"TR_HAWB+TR_ITEM")

#IFNDEF TOP
	dbClearIndex()
	//MFR OSSME-1974 26/12/2018
	dbSetIndex(cFileWork+TeOrdBagExt())
#ENDIF                 

For nI := 1 To Len(aCOLS)
	If ! aCOLS[nI][Len(aCOLS[nI])]
		RecLock("TRB",.T.)
		Replace TR_HAWB		With cAXXXHawb
		Replace TR_ITEM		With StrZero(nI,2)
		Replace TR_DESPESA	With aCOLS[nI][1]
		Replace TR_DESCDES	With aCOLS[nI][2]
		Replace TR_VALOR_R	With aCOLS[nI][3]
		Replace TR_FORN		With aCOLS[nI][4]
		Replace TR_LOJA		With aCOLS[nI][5]
		Replace TR_GERFIN	With aCOLS[nI][6]
		Replace TR_DES_ADI	With If(Empty(aCOLS[nI][7]),dDataBase,aCOLS[nI][07])
		MsUnLock()
		
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravar Anticipo no TRB para efetuar a integracao FIN e CON,  ³
//³ somente quando Fatcura do Agente da Aduana...					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nItem := TRB->(EasyRecCount())
If MV_PAR04 == 1 // FATURA AGENTE ADUANA
	DbSelectArea("SWD")
	DbSetOrder(1)
	DbSeek(xFilial("SWD")+SW6->W6_HAWB)
	While ! SWD->(Eof()) .and. SWD->WD_HAWB == SW6->W6_HAWB
		
		cDescDes := E_Field("WD_DESPESA","YB_DESCR","G",,1)
		
		If SWD->WD_DESPESA $ "901"
			nItem += 1
			RecLock("TRB",.T.)
			Replace TR_HAWB		With cAXXXHawb
			Replace TR_ITEM		With StrZero(nItem,2)
			Replace TR_DESPESA	With SWD->WD_DESPESA
			Replace TR_DESCDES	With cDescDes
			Replace TR_VALOR_R	With SWD->WD_VALOR_R
			Replace TR_FORN		With SWD->WD_FORN
			Replace TR_LOJA		With SWD->WD_LOJA
			Replace TR_GERFIN	With SWD->WD_GERFIN
			Replace TR_DES_ADI	With SWD->WD_DES_ADI
			MsUnLock()
		EndIf			
		DbSelectArea("SWD")
		DbSkip()
	End
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gerar t¡tulo no Financeiro...										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("TRB")
IndRegua("TRB",cFileWork,"TR_HAWB+TR_FORN+TR_LOJA+TR_ITEM",,,OemToAnsi("Indexando..."))
#IFNDEF TOP
	dbClearIndex()
	//MFR OSSME-1974 26/12/2018
	dbSetIndex(cFileWork+TeOrdBagExt())
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definir variaveis...													  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAXXXForn := ""
cAXXXLoja := ""
cAXXXNum := ""

nValorPA := 0.00
nTotalFat := 0.00                 

DbGoTop()

	While ! Eof()
		
		cAXXXForn := TRB->TR_FORN
		cAXXXLoja := TRB->TR_LOJA
		cAxxxNum := ""
		While ! Eof() .and. TRB->TR_FORN==cAXXXForn .and. TRB->TR_LOJA==cAXXXLoja
		
			If mv_par04 == 1 .and. TRB->TR_DESPESA $ "901"
				nValorPA	:= nValorPA + TRB->TR_VALOR_R
			Else	
				If TRB->TR_GERFIN $ "SY1"
					nTotalFat := nTotalFat + TRB->TR_VALOR_R 
				EndIf	
			EndIf
	
			SWD->(DbSeek(xFilial("SWD")+TRB->TR_HAWB+TRB->TR_DESPESA))
			IF cAXXXNum == "" .and. (nValorPa > 0 .or. nTotalFat > 0)
				cAXXXNum = GetSXENum("SWD","WD_CTRFIN1")
	        	ConfirmSx8()
	      EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada para Obter o Numero do Titulo definido pelo ³
			//³ Usuario...																	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If EasyEntryPoint("EIXXXSE2")
				ExecBlock("EIXXXSE2",.F.,.F.)
			EndIf
	      If nValorPa > 0 .or. nTotalFat > 0     
	        	If SWD->(Found())
			      SWD->(RECLOCK("SWD",.F.))
				   SWD->WD_CTRFIN1 := cAXXXNum
	    		   SWD->WD_DTENVF := dDataBase
				   SWD->(MSUNLOCK())         
				EndIf    
			EndIf   
			SA2->(DbSeek(xFilial("SA2")+TRB->TR_FORN+TRB->TR_LOJA))
		
			If TRB->TR_DESPESA $ "EIV.EDI.IVA"
				ContabEIC("DETAIL","990",.T.)
			ElseIf TRB->TR_DESPESA $ "901" .OR. SUBS(TRB->TR_DESPESA,1,1) $ "34567"
				ContabEIC("DETAIL","994",.T.)
			EndIf
		
			DbSelectArea("TRB")
			DbSkip()
		End
		
		If nValorPA > 0 .or. nTotalFat > 0
	
			SW9->(DbSetOrder(3))
			SW9->(DbSeek(xFilial("SW9")+cAXXXHawb))
		
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+ cAXXXForn + cAXXXLoja))
		
			If nValorPA > 0
				GeraDupEIC(cAXXXNum,nValorPA,dDataBase,dDataBase,,"EIC",;
								"PA ",1,cAXXXForn,cAXXXLoja,"SIGAEIC","ANTICIPO AG. ADUANA")
			EndIf
			If nTotalFat > 0
				GeraDupEIC(cAXXXNum,nTotalFat,dDataBase,dDataBase,,"EIC",;
							"NF ",1,cAXXXForn,cAXXXLoja,"SIGAEIC","INGRESO A PAGAR")
			EndIf				
		EndIf
		DbSelectArea("TRB")
	EndDo

aRotina[3][4] := 1	
DbSelectArea("TRB")
DbCloseArea()
FErase(cFileWork+".DBF")
//MFR OSSME-1974 26/12/2018
FErase(cFileWork+TeOrdBagExt())

Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ AXXXExclui ³ Autor ³ Lucas/Claudia Cabral³ Data ³ 25.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para gravacao da Provisao de Gastos/Importacao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AXXXExclui()														     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                            										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ EICAXXX	 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AXXXExclui()
LOCAL nI := 0, lRet := .T.
LOCAL aCampos   := {}
LOCAL cAXXXForn := ""
LOCAL cAXXXLoja := ""

AADD(aCampos,{"TR_HAWB"   ,"C",17,0})
AADD(aCampos,{"TR_ITEM"   ,"C",02,0})
AADD(aCampos,{"TR_DESPESA","C",03,0})
AADD(aCampos,{"TR_DESCDES","C",30,0})
AADD(aCampos,{"TR_VALOR_R","N",16,2})
AADD(aCampos,{"TR_FORN"   ,"C",06,0})
AADD(aCampos,{"TR_LOJA"   ,"C",02,0})
AADD(aCampos,{"TR_GERFIN","C",01,0})
AADD(aCampos,{"TR_DES_ADI","D",08,0})

cFileWork := E_CriaTrab(,aCampos,"TRB")
E_IndRegua("TRB",cFileWork+TEOrdBagExt(),"TR_HAWB+TR_ITEM")

#IFNDEF TOP
	dbClearIndex()
	//MFR OSSME-1974 26/12/2018
	dbSetIndex(cFileWork+TeOrdBagExt())
#ENDIF

For nI := 1 To Len(aCOLS)
	If ! aCOLS[nI][Len(aCOLS[Ni])]
		RecLock("TRB",.T.)
		Replace TR_HAWB		With cAXXXHawb
		Replace TR_ITEM		With StrZero(nI,2)
		Replace TR_DESPESA	With aCOLS[nI][1]
		Replace TR_DESCDES	With aCOLS[nI][2]
		Replace TR_VALOR_R	With aCOLS[nI][3]
		Replace TR_FORN		With aCOLS[nI][4]
		Replace TR_LOJA		With aCOLS[nI][5]
		Replace TR_GERFIN	With aCOLS[nI][6]
		Replace TR_DES_ADI	With If(Empty(aCOLS[nI][7]),dDataBase,aCOLS[nI][07])
		MsUnLock()
	EndIf
Next nI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravar Anticipo no TRB para efetuar a integracao FIN e CON,  ³
//³ somente quando Fatcura do Agente da Aduana...					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nItem := TRB->(EasyRecCount())
If mv_par04 == 1
	DbSelectArea("SWD")
	DbSetOrder(1)
	DbSeek(xFilial("SWD")+SW6->W6_HAWB)
	While ! SWD->(Eof()) .and. SWD->WD_HAWB == SW6->W6_HAWB
		
		cDescDes := E_Field("WD_DESPESA","YB_DESCR","G",,1)
		
		If SWD->WD_DESPESA $ "901"
			nItem += 1
			RecLock("TRB",.T.)
			Replace TR_HAWB		With cAXXXHawb
			Replace TR_ITEM		With StrZero(nItem,2)
			Replace TR_DESPESA	With SWD->WD_DESPESA
			Replace TR_DESCDES	With cDescDes
			Replace TR_VALOR_R	With SWD->WD_VALOR_R
			Replace TR_FORN		With SWD->WD_FORN
			Replace TR_LOJA		With SWD->WD_LOJA
			Replace TR_GERFIN	With SWD->WD_GERFIN
			Replace TR_DES_ADI	With SWD->WD_DES_ADI
			MsUnLock()
		EndIf			
		DbSelectArea("SWD")
		DbSkip()
	End
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gerar t¡tulo no Financeiro...										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("TRB")
IndRegua("TRB",cFileWork,"TR_HAWB+TR_FORN+TR_LOJA+TR_ITEM",,,OemToAnsi("Indexando..."))
#IFNDEF TOP
	dbClearIndex()
	//MFR OSSME-1974 26/12/2018
	dbSetIndex(cFileWork+TeOrdBagExt())
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definir variaveis...													  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAXXXForn := ""
cAXXXLoja := ""
cAXXXNum := ""

nValorPA := 0.00
nTotalFat := 0.00                 

DbGoTop()
SWD->(DbSetOrder(1))
While ! Eof()
	
	cAXXXForn := TRB->TR_FORN
	cAXXXLoja := TRB->TR_LOJA
	cAXXXNum := "" 
	While ! Eof() .and. TRB->TR_FORN==cAXXXForn .and. TRB->TR_LOJA==cAXXXLoja
	
		If mv_par04 == 1 .and. TRB->TR_DESPESA $ "901"
			nValorPA	:= nValorPA + TRB->TR_VALOR_R
		Else	
			If TRB->TR_GERFIN $ "S1Y"
				nTotalFat := nTotalFat + TRB->TR_VALOR_R 
			EndIf	
		EndIf

		SWD->(DbSeek(xFilial("SWD")+TRB->TR_HAWB+TRB->TR_DESPESA))
		SA2->(DbSeek(xFilial("SA2")+TRB->TR_FORN+TRB->TR_LOJA))
	

		IF nValorPa > 0 .or. ntotalFat > 0
			If SWD->(Found())
				 cAXXXNum = SWD->WD_CTRFIN1
			    SWD->(RECLOCK("SWD",.F.))
			    SWD->WD_CTRFIN1:= ""
    		    SWD->WD_DTENVF :=CTOD("")
			    SWD->(MSUNLOCK())         
			EndIF			    
		Endif 
		If TRB->TR_DESPESA $ "EIV.EDI.IVA"
			ContabEIC("DETAIL","999",.T.)
		ElseIf TRB->TR_DESPESA $ "901" .OR. SUBS(TRB->TR_DESPESA,1,1) $ "34567"
			ContabEIC("DETAIL","998",.T.)
		EndIf
	
		DbSelectArea("TRB")
		DbSkip()
	End
	
	If nValorPA > 0 .or. nTotalFat > 0

		SW9->(DbSetOrder(3))
		SW9->(DbSeek(xFilial("SW9")+cAXXXHawb))
	
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+ cAXXXForn + cAXXXLoja))
	
		If nValorPa > 0
			DeleDupEIC("EIC",cAXXXNum,1,"PA ",cAXXXForn,cAXXXLoja,"SIGAEIC")
		EndIf
		If nTotalFat > 0
			DeleDupEIC("EIC",cAXXXNum,1,"NF ",cAXXXForn,cAXXXLoja,"SIGAEIC")			
		EndIf	
	EndIf
	DbSelectArea("TRB")
End

DbSelectArea("TRB")
DbCloseArea()
FErase(cFileWork+".DBF")
//MFR OSSME-1974 26/12/2018
FErase(cFileWork+TeOrdBagExt())
Return( lRet )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ AXXXACOLS  ³ Autor ³ Lucas/Claudia Cabral³ Data ³ 25.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preencher o ACOLS com base em SW6 e SWD...					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AXXXACOLS()															     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                            										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ EICAXXX	 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AXXXACOLS(nOpcx)
LOCAL nI := 0
LOCAL nXXXFob := 0
LOCAL nXXXFrete := 0
LOCAL nXXXSeguro := 0
LOCAL aImpHAWB := {}
LOCAL aImpDespes := {}
LOCAL cNCM
LOCAL cExNCM
LOCAL cExNBM
LOCAL cTes
LOCAL cTec, cAXXXForDesp, cAXXXLojDesp, cdescdes
LOCAL nSomanoCif := 0
LOCAL aGetArea := GetArea()
LOCAL nTotQtde := 0
LOCAL nTotPeso := 0   
LOCAL aImpTes := {}
LOCAL nITES :=0
nTotalFat := 0



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obter valor FOB, Frete e Seguro e comverter para moeda LOCAL ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nXXXFob += ( SW6->W6_FOB_TOT * SW6->W6_TX_FOB )
nXXXFrete += ( SW6->W6_VL_FRET * SW6->W6_TX_FRET )
nXXXSeguro += ( SW6->W6_VL_USSE * SW6->W6_TX_SEG )

cAXXXForDesp := PADR(GETNEWPAR("MV_FORDESP",' '),LEN(SA2->A2_COD))
cAXXXLojDesp := PADR(GETNEWPAR("MV_LOJDESP",' '),LEN(SA2->A2_LOJA))
	
SY5->(DbSetOrder(1))
If SY5->(DbSeek(xFilial("SY5")+SW6->W6_DESP))
	cAXXXForDesp := SY5->Y5_FORNECE
	cAXXXLojDesp := SY5->Y5_LOJAF
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obter dados para a Factura Agente da Aduana...               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par04 == 1
	
	DbSelectArea("SWD")
	DbSetOrder(1)
	SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB))
	If !Found()
		MsgStop("No hay registros en SWD (Gastos) !!!","Atenci¢n")
		Return(.F.)
	EndIf	                         
	While !Eof() .and. SWD->WD_HAWB == cAXXXHawb
		If SWD->WD_FORN == cAXXXForDesp .and. SWD->WD_LOJA == cAXXXLojdesp
			If nOpcx == 3 .and. ! Empty(SWD->WD_DTLANC)
				MsgStop("Factura del Agente de Aduana ya Contabilizada !!!","Atenci¢n")
				Return(.F.)			
			EndIf
			If nOpcx <> 3 .and. Empty(SWD->WD_DTLANC)
				MsgStop("Factura del Agente de Aduana no Contabilizada !!!","Atenci¢n")
				Return(.F.)			
			EndIf
			SYB->(DbSeek(XFilial("SYB") + SWD->WD_DESPESA))
			IF SYB->YB_BASEIMP $ "SY1" .and. SUBS(SWD->WD_DESPESA,1,1) $ "34567"
				nSomaNoCIF+=SWD->WD_VALOR_R
			ENDIF
		EndIf	
		
		DbSkip()
	End	

	DbSelectArea("SW9")
	DbSetOrder(3)
	SW9->(DbSeek(xFilial("SW9")+SW6->W6_HAWB))
	nTotQtde := 0
	nTotPeso := 0
	While ! SW9->(Eof()) .and. SW9->W9_FILIAL == xFilial("SW9") .and.;
			SW9->W9_HAWB == SW6->W6_HAWB
		
		SW8->(DbSetOrder(1))	
		SW8->(DbSeek(xFilial("SW8")+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN))
		
		While ! SW8->(Eof()) .and. SW8->W8_HAWB == SW9->W9_HAWB .and.;
				SW8->W8_INVOICE == SW9->W9_INVOICE .and.;
				SW8->W8_FORN == SW9->W9_FORN
			
			SW7->(DbSetOrder(4))
			SW7->(DbSeek(xFilial("SW7")+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO))
			
			SB1->(DbSeek(xFilial("SB1")+SW7->W7_COD_I))
			SW2->(DbSeek(xFilial("SW2")+SW7->W7_PO_NUM))
			
			ntotQtde +=  SW8->W8_QTDE

			nTotPeso += (SW8->W8_QTDE * SB1->B1_PESO)

			nFob      := DITrans(SW8->W8_PRECO * SW8->W8_QTDE,2)
	
			nRateioDes:= DITRANS((SW9->W9_INLAND  *(nFob/SW9->W9_FOB_TOT))+;
	    			             (SW9->W9_PACKING *(nFob/SW9->W9_FOB_TOT))-;
	                	         (SW9->W9_DESCONTO*(nFob/SW9->W9_FOB_TOT)))
	
			nValMerc  := nFob + nRateioDes                     
	
						
			cNCM   := SB1->B1_POSIPI
			cExNCM := SB1->B1_EX_NCM
			cExNBM := SB1->B1_EX_NBM
			
			If PosO1_ItPedidos(SW7->W7_PO_NUM,SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_FABR,SW7->W7_FORN,SW7->W7_REG,0)
				If ! Empty(SW3->W3_TEC)
					cNCM   := SW3->W3_TEC
					cExNCM := SW3->W3_EX_NCM
					cExNBM := SW3->W3_EX_NBM
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcular os Impostos do Processo de Importacao com base nos  ³
			//³ valores acima e o TES.													  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SW5")
			DbSetOrder(1)
			DbSeek(xFilial("SW5")+cAXXXHawb)
			
			DbSelectArea("SYD")
			DbSetOrder(1)
			DbSeek(xFilial("SYD")+ cNCM + cExNCM + cExNBM )
			cTes := ""
			If Found()
				cTEC := cNCM + cExNCM + cExNBM
				cTES := SYD->YD_TES	
			EndIf                 
			
			AADD(aImpTes,{cTES,nValMerc,cTEC,SW8->W8_QTDE,(SW8->W8_QTDE * SB1->B1_PESO)})
			
			DbSelectArea("SW8")
			DbSkip()
		End
		DbSelectArea("SW9")
		DbSkip()
	End 
    /* Calcular os Impostos Gerais e dos Itens */
	For nITES = 1 to Len(aImpTes)
		nSomanoCif :=  DITrans(nSomanoCif * ( aImpTes [nITES] [2] / SW6->W6_Fob_TOT ) ,2)		

		nTotSEGURO:= DITrans(SW6->W6_VL_USSE * SW6->W6_TX_SEG)
	
		nSeguro   := DITrans(ntotSeguro * (  aImpTes [nITES] [2] / SW6->W6_Fob_TOT ) ,2)
	
		nTotFRETE := DITrans(SW6->W6_VL_FRET * SW6->W6_TX_FRET) + SW6->W6_VLFR_CO
	
		nRatFrete :=  aImpTes [nITES] [2]/SW6->W6_FOB_TOT // rateio por valor
	
		IF MV_PAR05 = 2 // rateio por quantidade
		   nRatFrete :=  aImpTes [nITES] [4] /nTotQtde 
		ElseIf MV_PAR05 = 1 // rateio por peso
		   nRatFrete:=  aImpTes [nITES] [5] /nTotPeso 
		ENDIF
	
		nFrete  := DITrans(nTotFrete * nRatFrete ,2)
	
		nValCif   := ( aImpTes [nITES] [2] * SW6->W6_Tx_Fob) + nFrete + nSeguro + nSomanoCif
		
		aImpHawb := CalcImpGer(aImpTes [nITES] [1],aImpTes [nITES] [4],nValCif,nValCif,;
				0,0,"",{},aImpTes [nITES] [3],nValCif,.F.)

		SFB->(DbSetOrder(1))

		For nI := 1 To Len(aImpHawb[6])
			SFB->(DbSeek(xFilial("SFB")+aImpHawb[6][nI][1]))
			If aImpHawb[6][nI][4] > 0		
				SFB->(DbSeek(xFilial("SFB")+aImpHawb[6][nI][1]))
				nE := AScan( aCols ,{|x| x[1] == aImpHawb[6][nI][1] } )
				If nE == 0
					AADD(aCOLS,{aImpHawb [6][nI][1],SFB->FB_DESCR,aImpHawb[6] [nI][4],;
		 					cAXXXForDesp,cAXXXLojDesp,"S",.F.})
		 		Else 
		 			aCols [nE] [3] += 	aImpHawb[6][nI][4]
		 		Endif			
				nTotalFat += aImpHawb[6][nI][4]					
			EndIf
		Next nI		
	Next nITES
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcular os Impostos das Despesas...								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SWD")
	DbSetOrder(1)
	If DbSeek(xFilial("SWD")+cAXXXHawb)
				
		While !Eof() .and. SWD->WD_FILIAL==xFilial("SWD") ;
						 .and. SWD->WD_HAWB == cAXXXHawb
			cDescDes := E_Field("WD_DESPESA","YB_DESCR","G",,1)
			SYB->(DbSeek(XFilial("SYB") + SWD->WD_DESPESA))
			
			If SUBS(SWD->WD_DESPESA,1,1) $ "34567" .and. SWD->WD_FORN == cAXXXForDesp .and. SWD->WD_LOJA == cAXXXLojDesp
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se calcula impostos para Despesas...		  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SWD->WD_GERFIN $ "S1Y"
					AADD(aCOLS,{SWD->WD_DESPESA,cDESCDES,SWD->WD_VALOR_R,;
						SWD->WD_FORN,SWD->WD_LOJA,SWD->WD_GERFIN,.F.})
					nTotalFat += aCols[Len(aCols)] [3]					
					aImpDespesa := CalcImpGer(SYB->YB_TES,1,SWD->WD_VALOR_R,SWD->WD_VALOR_R,;
													0,0,"",{},,SWD->WD_VALOR_R,.F.)
							
					For nI := 1 to Len(aImpDespesa[6])
						SFB->(DbSeek(xFilial("SFB")+aImpDespesa[6][nI][1]))
						If aImpDespesa [6][nI][4] > 0		
							AADD(aCOLS,{aImpDespesa[6] [nI][1],SFB->FB_DESCR,aImpDespesa [6][nI][4],;
								SWD->WD_FORN,SWD->WD_LOJA,SWD->WD_GERFIN,.F.})
							nTotalFat += aCols[Len(aCols)] [3]
						EndIf
					Next nI
				EndIf
			EndIf	
			DbSelectArea("SWD")
			DbSkip()
		End
	EndIf

	If nSomanoCif > 0
			
		aImpHawb := CalcImpGer(cTES,1,nXXXFob+nXXXFrete+nXXXSeguro+nSomanoCif,nXXXFob+nXXXFrete+nXXXSeguro+nSomanoCif,;
								0,0,"",{},cTEC,nXXXFob+nXXXFrete+nXXXSeguro+nSomaNoCif,.F.)
					
		For nI := 1 To Len(aImpHawb[6])
			SFB->(DbSeek(xFilial("SFB")+aImpHawb[6][nI][1]))
			If aImpHawb[6][nI][4] > 0	
				nE := AScan( aImpHawb[6],{|x| x[1] == aImpHawb[6][nI][1] } )
				nTotalFat -=  aCols [nE] [3]
				aCols [nE] [3] := 	aImpHawb[6][nI][4]
				nTotalFat += aCols [nE] [3]
			EndIf
		Next nI										
	EndIf
EndIf

If mv_par04 == 2 // Factura Outros Gastos
	
	DbSelectArea("SWD")
	DbSetOrder(1)
	SWD->(DbSeek(xFilial("SWD")+SW6->W6_HAWB))
	If !Found()
		MsgStop("No hay registros en SWD (Gastos) !!!","Atenci¢n")
		Return(.F.)
	EndIf	
	nContab := 0	
	
	While !Eof() .and. SWD->WD_HAWB == cAXXXHawb
		If SWD->WD_FORN+SWD->WD_LOJA <> cAXXXForDesp+cAXXXLojDesp
			If nOpcx == 3 .and. !Empty(SWD->WD_DTLANC)
				nContab ++
			EndIf
		EndIf	
		DbSkip()
	End
	
	If nContab > 0	
		MsgStop("Factura Otros Gastos ya Contabilizada !!!","Atenci¢n")
		Return(.F.)
	EndIf				
    
	DbSelectArea("SW9")
	DbSetOrder(3)
	SW9->(DbSeek(xFilial("SW9")+SW6->W6_HAWB))

	While ! SW9->(Eof()) .and. SW9->W9_FILIAL == xFilial("SW9") .and.;
			SW9->W9_HAWB == SW6->W6_HAWB
		
		SW8->(DbSetOrder(1))	
		SW8->(DbSeek(xFilial("SW8")+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN))
		
		While ! SW8->(Eof()) .and. SW8->W8_HAWB == SW9->W9_HAWB .and.;
				SW8->W8_INVOICE == SW9->W9_INVOICE .and.;
				SW8->W8_FORN == SW9->W9_FORN
			
			SW7->(DbSetOrder(4))
			SW7->(DbSeek(xFilial("SW7")+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO))
			
			SB1->(DbSeek(xFilial("SB1")+SW7->W7_COD_I))
			SW2->(DbSeek(xFilial("SW2")+SW7->W7_PO_NUM))
			
			cNCM   := SB1->B1_POSIPI
			cExNCM := SB1->B1_EX_NCM
			cExNBM := SB1->B1_EX_NBM
			
			If PosO1_ItPedidos(SW7->W7_PO_NUM,SW7->W7_CC,SW7->W7_SI_NUM,SW7->W7_COD_I,SW7->W7_FABR,SW7->W7_FORN,SW7->W7_REG,0)
				If ! Empty(SW3->W3_TEC)
					cNCM   := SW3->W3_TEC
					cExNCM := SW3->W3_EX_NCM
					cExNBM := SW3->W3_EX_NBM
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcular os Impostos do Processo de Importacao com base nos  ³
			//³ valores acima e o TES.													  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SW5")
			DbSetOrder(1)
			DbSeek(xFilial("SW5")+cAXXXHawb)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcular os Impostos das Facturas de Outras Despesas...		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SWD")
			DbSetOrder(1)
			If DbSeek(xFilial("SWD")+cAXXXHawb)
				While !Eof() .and. SWD->WD_HAWB == cAXXXHawb
					DbSelectArea("SYB")
					DbSetOrder(1)
					DbSeek(xFilial("SYB")+ SWD->WD_DESPESA )
					cTes := ""
					If Found()
						cTES := SYB->YB_TES	
					EndIf	
					If SWD->WD_DESPESA <> "901" .AND. !SUBS(SWD->WD_DESPESA,1,1) $ "12" .AND. ;
							 SWD->WD_FORN + SWD->WD_LOJA <> cAXXXForDesp + cAXXXLojDesp

						cDescDes := E_Field("WD_DESPESA","YB_DESCR","G",,1)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se calcula impostos para Despesas...		  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SWD->WD_GERFIN $ "S1Y"
							AADD(aCOLS,{SWD->WD_DESPESA,cDESCDES,SWD->WD_VALOR_R,;
								SWD->WD_FORN,SWD->WD_LOJA,SWD->WD_GERFIN,.F.})
							nTotalFat += aCOLS[Len(aCOLS)][3]
							
							aImpDespesa := CalcImpGer(cTES,1,SWD->WD_VALOR_R,SWD->WD_VALOR_R,;
												0,0,"",{},cTEC,SWD->WD_VALOR_R,.F.)
							
							For nI := 1 to Len(aImpDespesa [6])
								SFB->(DbSeek(xFilial("SFB")+aImpDespesa [6][nI][1]))
								If aImpDespesa [6][nI][4] > 0		
									AADD(aCOLS,{aImpDespesa [6][nI][1],SFB->FB_DESCR,aImpDespesa [6] [nI][4],;
										         SWD->WD_FORN,SWD->WD_LOJA,SWD->WD_GERFIN,.F.})
									nTotalFat += aCOLS[Len(aCOLS)][3]
								EndIf
							Next nI
						Else			
							AADD(aCOLS,{SWD->WD_DESPESA,cDESCDES,SWD->WD_VALOR_R,;
								         SWD->WD_FORN,SWD->WD_LOJA,SWD->WD_GERFIN,.F.})
							nTotalFat += aCOLS[Len(aCOLS)][3]
						EndIf
					EndIf	
					DbSelectArea("SWD")
					DbSkip()
				End
			EndIf
			DbSelectArea("SW8")
			DbSkip()	
			Exit			
		End				
		DbSelectArea("SW9")
		Exit
	End		
EndIf
RestArea(aGetArea)
Return( .t. )


Function AXXXLINOK()
If Empty(aCols[n] [1])
	MsgStop ("No es posible incluyer nuevos registros")
	Return .F.
Endif		
Return .t.

Function AXXXTudOK()
Return .t.

Function AXXXVldFat()
Return .T.


/*
*------------------------------------*
Static Function DITrans(nVal)
*------------------------------------*
Return ROUND(nVal,nDecPais)
  */
