#INCLUDE "TOTVS.CH"
#INCLUDE "QPPA160.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPA160  ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 20.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Plano de Controle                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPA160(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPPAP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Robson Ramiro³20/02/02³VERSAO³ Efetuado os ajustes 609 x 710          ³±±
±±³ Robson Ramiro³25/06/02³Melhor³ Permissao para inclusao de +1 Operacao ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
Local aRotina := { 	{ OemToAnsi(STR0001), "AxPesqui"  , 0, 1,,.F.},;  	//"Pesquisar"
					{ OemToAnsi(STR0002), "PPA160Visu", 0, 2},;		 	//"Visualizar"
					{ OemToAnsi(STR0003), "PPA160Incl", 0, 3},;		  	//"Incluir"
					{ OemToAnsi(STR0004), "PPA160Alte", 0, 4},;		  	//"Alterar"
					{ OemToAnsi(STR0005), "PPA160Excl", 0, 5},;			//"Excluir"
					{ OemToAnsi(STR0009), "QPPR160(.T.)", 0, 6,,.T.} }	//"Imprimir"

Return aRotina

Function QPPA160()
//Define o cabecalho da tela de atualizacoes
Private cCadastro := OemToAnsi(STR0006)  //"Plano de Controle"
Private aRotina := MenuDef()                       

DbSelectArea("QKL")    
DbSetOrder(1)
mBrowse( 6, 1, 22, 75,"QKL",,,,,,)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA160Visu  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³20.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Visualizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA160Visu(ExpC1,ExpN1,ExpN2)                                ³±±
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
Function PPA160Visu(cAlias,nReg,nOpc)
Local aButtons := {}
Local oDlg     := NIL

Private aCols    := {}
Private aHeader  := {}
Private aSize    := MsAdvSize()
Private nUsado   := 0
Private oGet     := NIL
Private oGetPlan := NIL

DbSelectArea(cAlias)

//Monta Enchoice Modelo3
DEFINE MSDIALOG oDlg TITLE cCadastro ; //"Plano de Controle"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

aButtons := {	{ "EDIT"	  , { || QPP160APRO(nOpc) }	, OemToAnsi(STR0007), OemToAnsi(STR0010) },; //"Aprovar / Limpar"###"Apro/Lim"
				{ "BMPVISUAL" , { || QPPR160() }		, OemToAnsi(STR0008), OemToAnsi(STR0011) }}  //"Visualizar/Imprimir"###"Vis/Prn"
			
//Ponto de Entrada criado para inclusao de botoes auxiliares na enchoicebar
If ExistBlock("QPPAPBUTAUX")
	aButtons := ExecBlock("QPPAPBUTAUX",.f., .f., {nOpc,aButtons})
EndIf

EnchoiceBar(oDlg,{|| oDlg:End()},{||oDlg:End()}, , aButtons)

RegToMemory("QKL")

oGetPlan := MsMGet():New("QKL",nReg,nOpc,,,,,{014,003,IF(aSize[4]<=206,100,140),aSize[3]},,,,,,oDlg)
oGetPlan:oBox:Align := CONTROL_ALIGN_TOP

//Monta vetor aHeader a ser utilizado na getdados
PP160Ahead("QKM")

nUsado	:= Len(aHeader)              

PP160Acols(nOpc)

oGet := MSGetDados():New(138,00,198,333, nOpc,"AllwaysTrue","AllwaysTrue","+QKM_ITEM",.T.)
If SetMDIChild()
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif	

ACTIVATE MSDIALOG oDlg ON INIT(oGet:oBrowse:Refresh())

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA160Incl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³20.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Inclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA160Incl(ExpC1,ExpN1,ExpN2)                                ³±± 
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
Function PPA160Incl(cAlias,nReg,nOpc)
Local aButtons := {}
Local lOk      := .F.
Local nTamGet  := QPPTAMGET("QKM_ITEM",1)
Local oDlg     := NIL

Private aCols    := {}
Private aHeader  := {}
Private aSize    := MsAdvSize()
Private nUsado   := 0
Private oGet     := NIL
Private oGetPlan := NIL

DbSelectArea(cAlias)

// Monta Enchoice Modelo3
DEFINE MSDIALOG oDlg TITLE cCadastro ; // //"Plano de Controle"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

aButtons := {{ "EDIT" , { || QPP160APRO(nOpc) }, OemToAnsi(STR0007), OemToAnsi(STR0010) }} //"Aprovar / Limpar"###"Apro/Lim"

//Ponto de Entrada criado para inclusao de botoes auxiliares na enchoicebar  
If ExistBlock("QPPAPBUTAUX")
	aButtons := ExecBlock("QPPAPBUTAUX",.f., .f., {nOpc,aButtons})
EndIf

EnchoiceBar(oDlg,{||lOk := PP160TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

RegToMemory("QKL",.T.)						

oGetPlan := MsMGet():New("QKL",nReg,nOpc,,,,,{014,003,IF(aSize[4]<=206,100,140),aSize[3]},,,,,,oDlg)
oGetPlan:oBox:Align := CONTROL_ALIGN_TOP

//Monta vetor aHeader a ser utilizado na getdados
PP160Ahead("QKM")

nUsado	:= Len(aHeader)

PP160Acols(nOpc)
				
DbSelectArea("QKM")	

oGet := MSGetDados():New(138,00,198,333, nOpc,"PP160LinOk","PP160TudOk","+QKM_ITEM",.T.,,,,nTamGet)
oGet:oBrowse:bGotFocus := {|| QPAVLDIN()}
If SetMDIChild()
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif	

ACTIVATE MSDIALOG oDlg CENTERED

If lOk
	A160Grav(nOpc)
	If ExistBlock("QPP160GRV")
		ExecBlock("QPP160GRV", .f., .f., {nOpc,nReg})
	EndIf
Endif
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA160Alte  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³20.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Alteracao                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA160Alte(ExpC1,ExpN1,ExpN2)                                ³±±
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
Function PPA160Alte(cAlias,nReg,nOpc)
Local aArea    := {}
Local aButtons := {}
Local cTpPro   := ""
Local lOk      := .F.
Local nTamGet  := QPPTAMGET("QKM_ITEM",1)
Local oDlg     := NIL

Private aCols    := {}
Private aHeader  := {}
Private aSize    := MsAdvSize()
Private nUsado   := 0
Private oGet     := NIL
Private oGetPlan := NIL

If !QPPVldAlt(QKL->QKL_PECA,QKL->QKL_REV,QKL->QKL_APRFOR)
	Return
Endif

/*If !Empty(QKL->QKL_APRFOR) .And. QKL->QKL_APRFOR <> cUserName
	Alert(STR0012)//"Plano de Controle se encontra aprovado por outro usuario! Sendo possivel apenas sua visualizacao."
	PPA160Visu(cAlias,nReg,2)
	Return()
Endif*/

If cAlias == "QKL"
	aArea := GetArea()
	DBSeek(xFilial("QKL")+QKL->QKL_PECA+QKL->QKL_REV+"Z",.T.)
	DbSkip(-1)
	cTpPro := QKL->QKL_TPPRO
	RestArea(aArea)
	If !Empty(AllTrim(cTpPro)) .AND. Val(cTpPro) > Val(QKL->QKL_TPPRO)
		Alert( OemToAnsi(STR0021))//"Plano de Controle se encontra bloqueado pois já existe para a mesma peça/revisão uma outra fase de produção."
		PPA160Visu(cAlias,nReg,2)
		Return()
	Endif  
EndIf

DbSelectArea(cAlias)
				
aCposAlt := {	"QKL_TPPRO"		,"QKL_PLAN"		,"QKL_DTREV"	,;
				"QKL_EQPRIN"	,"QKL_APRFOR" 	,"QKL_DTAFOR"	,;
				"QKL_DTINI"		,"QKL_APENCL"	,"QKL_DTAENG"	,;
				"QKL_APQUCL"	,"QKL_DTAQUA"	,"QKL_CONTAT" 	,;
				"QKL_OUTAP1"	,"QKL_DTOUT1"	,"QKL_OUTAP2" 	,;
				"QKL_DTOUT2"	}

//Ponto de entrada para alteracao do aCposAlt
If ExistBlock("QPP160ALT")
	aCposAlt := ExecBlock("QPP160ALT",.F., .f., {aCposAlt})
EndIf

//Monta Enchoice Modelo3
DEFINE MSDIALOG oDlg TITLE cCadastro ; // //"Plano de Controle"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

aButtons := {	{ "EDIT" , { || QPP160APRO(nOpc) }          , OemToAnsi(STR0007), OemToAnsi(STR0010) },;
				{ "NEXT" , { || QPP160EVOL(nOpc),oDlg:End()}, OemToAnsi(STR0019), OemToAnsi(STR0020) } } //"Evoluir o Plano"###"Evolui"

//Ponto de Entrada criado para inclusao de botoes auxiliares na enchoicebar
If ExistBlock("QPPAPBUTAUX")
	aButtons := ExecBlock("QPPAPBUTAUX",.f., .f., {nOpc,aButtons})
EndIf

EnchoiceBar(oDlg,{||lOk := PP160TudOk(), Iif(lOk,oDlg:End(),)},{||oDlg:End()}, , aButtons)

RegToMemory("QKL",.F.)						                           

oGetPlan := MsMGet():New("QKL",nReg,nOpc,,,,,{014,003,IF(aSize[4]<=206,100,140),aSize[3]},,,,,,oDlg)
oGetPlan:oBox:Align := CONTROL_ALIGN_TOP

//Monta vetor aHeader a ser utilizado na getdados
PP160Ahead("QKM")

nUsado	:= Len(aHeader)

PP160Acols(nOpc)

DbSelectArea("QKM")						

oGet := MSGetDados():New(138,00,198,333, nOpc,"PP160LinOk","PP160TudOk","+QKM_ITEM",.T.,,,,nTamGet)
If SetMDIChild()
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif	

ACTIVATE MSDIALOG oDlg ON INIT(oGet:oBrowse:Refresh())

If lOk
	A160Grav(nOpc)
	If ExistBlock("QPP160GRV")
		ExecBlock("QPP160GRV", .f., .f., {nOpc,nReg})
	EndIf
Endif

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PPA160Excl  ³ Autor ³ Robson Ramiro A.Olivei³ Data ³20.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para Exclusao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PPA160Excl(ExpC1,ExpN1,ExpN2)                                ³±±
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
Function PPA160Excl(cAlias,nReg,nOpc)
Local aButtons := {}
Local oDlg     := NIL

Private aCols    := {}
Private aHeader  := {}
Private aSize    := MsAdvSize()
Private nUsado   := 0
Private oGet     := NIL
Private oGetPlan := NIL

If !QPPVldExc(QKL->QKL_REV,QKL->QKL_APRFOR)
	Return
Endif

DbSelectArea(cAlias)

//Monta Enchoice Modelo3
DEFINE MSDIALOG oDlg TITLE cCadastro; // //"Plano de Controle"
						FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

aButtons := {	{ "EDIT"	  , { || QPP160APRO(nOpc) }	, OemToAnsi(STR0007), OemToAnsi(STR0010) },; //"Aprovar / Limpar"###"Apro/Lim"
				{ "BMPVISUAL" , { || QPPR160() }		, OemToAnsi(STR0008), OemToAnsi(STR0011) }}  //"Visualizar/Imprimir"###"Vis/Prn"

//Ponto de Entrada criado para inclusao de botoes auxiliares na enchoicebar 
If ExistBlock("QPPAPBUTAUX")
	aButtons := ExecBlock("QPPAPBUTAUX",.f., .f., {nOpc,aButtons})
EndIf

EnchoiceBar(oDlg,{|| A160Dele(),oDlg:End()},{||oDlg:End()}, , aButtons)

RegToMemory("QKL")						

oGetPlan := MsMGet():New("QKL",nReg,nOpc,,,,,{014,003,IF(aSize[4]<=206,100,140),aSize[3]},,,,,,oDlg)
oGetPlan:oBox:Align := CONTROL_ALIGN_TOP		

//Monta vetor aHeader a ser utilizado na getdados
PP160Ahead("QKM")

nUsado	:= Len(aHeader)

PP160Acols(nOpc)

oGet := MSGetDados():New(138,00,198,333, nOpc,"AllwaysTrue","AllwaysTrue","+QKM_ITEM",.T.)

If SetMDIChild()
	oGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Endif	

ACTIVATE MSDIALOG oDlg ON INIT(oGet:oBrowse:Refresh())

If ExistBlock("QPP160GRV")
	ExecBlock("QPP160GRV", .f., .f., {nOpc,nReg})
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³PP160Acols³ Autor ³ Robson Ramiro A. Olive³ Data ³ 20.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Carrega vetor aCols para a GetDados                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q010Acols()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP160Acols(nOpc)
Local nI       := 0
Local nPos     := 0
Local nPosNCAR := aScan(aHeader,{ |x| AllTrim(x[2])== "QKM_NCAR" })
Local nPosNOPE := aScan(aHeader,{ |x| AllTrim(x[2])== "QKM_NOPE" })

//Montagem do aCols
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

	nPos			:= aScan(aHeader,{ |x| AllTrim(x[2])== "QKM_ITEM" })
	aCols[1,nPos]	:= StrZero(1,Len(aCols[1,nPos]))
	
	aCols[1,nUsado+1] := .F.	

Else
	
	DbSelectArea("QKM")
	DbSetOrder(3) 
	DbSeek(xFilial("QKM")+QKL->QKL_PECA+QKL->QKL_REV+QKL->QKL_TPPRO)

	Do While QKM->(!Eof()) .and. xFilial() == QKL->QKL_FILIAL     	.and.;
		 QKM->QKM_PECA+QKM->QKM_REV == QKL->QKL_PECA+QKL->QKL_REV

		If QKL->QKL_TPPRO <> QKM->QKM_TPPRO
			DbSkip()
			Loop
		EndIf

		aAdd(aCols,Array(nUsado+1))

		For nI := 1 to nUsado
		
			If Upper(AllTrim(aHeader[nI,10])) != "V" 	// Campo Real
				aCols[Len(aCols),nI] := FieldGet(FieldPos(aHeader[nI,2]))
			Else										// Campo Virtual
				cCpo := AllTrim(Upper(aHeader[nI,2]))
				aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2])

				If cCPO == "QKM_DESOPE"
					aCols[Len(aCols),nI] := Posicione("QKK",2,xFilial()+QKL->QKL_PECA+QKL->QKL_REV+aCols[Len(aCols),nPosNOPE],"QKK_DESC")
				Elseif cCPO == "QKM_DESCAR"
					aCols[Len(aCols),nI] := Posicione("QK2",2,xFilial()+QKL->QKL_PECA+QKL->QKL_REV+aCols[Len(aCols),nPosNCAR],"QK2_DESC")
				Endif
				
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
±±³Funcao    ³PP160Ahead³ Autor ³ Robson Ramiro A. Olive³ Data ³ 20.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta Ahead para aCols                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP160Ahead()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PP160Ahead(cAlias)
Local aStruAlias := FWFormStruct(3, cAlias)[3]
Local nX := 0

aHeader := {}
nUsado 	:= 0

For nX := 1 To Len(aStruAlias)
	//Ignora campos que nao devem aparecer na getdados	
	If  Upper(AllTrim(aStruAlias[nX,1])) == "QKM_PECA" 	.or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKM_REV"   .or. ;
		Upper(AllTrim(aStruAlias[nX,1])) == "QKM_TPPRO"
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
±±³Funcao    ³ A160Grav ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 20.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao - Incl./Alter.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A160Grav(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A160Grav(nOpc)
Local nCpo       := 0
Local bCampo     := {|nCPO| Field(nCPO) }
Local cAtividade := "05 " // Definido no ID - QKZ
Local lGraOk     := .T.   // Indica se todas as gravacoes obtiveram sucesso
Local nCont      := 0
Local nIt        := 0
Local nNumItem   := 1     // Contador para os Itens
Local nPosDel    := Len(aHeader) + 1

Begin Transaction

	DbSelectArea("QKL")
	DbSetOrder(1)

	If INCLUI
		RecLock("QKL",.T.)
	Else
		RecLock("QKL",.F.)
	Endif

	For nCont := 1 To FCount()

		If "FILIAL"$Field(nCont)
			FieldPut(nCont,xFilial("QKL"))
		Else
			FieldPut(nCont,M->&(EVAL(bCampo,nCont)))
		Endif

	Next nCont

	//Campos nao informados
	QKL->QKL_REVINV := Inverte(QKL->QKL_REV)

	If !Empty(QKL->QKL_DTAFOR) .and. !Empty(QKL->QKL_APRFOR)
		QPP_CRONO(QKL->QKL_PECA,QKL->QKL_REV,cAtividade) // QPPXFUN - Atualiza Cronograma
	Endif

	MsUnLock()
	FKCOMMIT()

	DbSelectArea("QKM")    
	DbSetOrder(3)
		
	For nIt := 1 To Len(aCols)

		If !aCols[nIt, nPosDel]  // Verifica se o item foi deletado

			If ALTERA
				If DbSeek(xFilial("QKM")+ M->QKL_PECA + M->QKL_REV + M->QKL_TPPRO + StrZero(nIt,Len(QKM->QKM_ITEM)))
					RecLock("QKM",.F.)
				Else
					RecLock("QKM",.T.)
				Endif			
			Else	                   
				RecLock("QKM",.T.)
			Endif
				
			For nCpo := 1 To Len(aHeader)
				If aHeader[nCpo, 10] <> "V"
					QKM->(FieldPut(FieldPos(Trim(aHeader[nCpo, 2])),aCols[nIt, nCpo]))
				EndIf
			Next nCpo
			
			//Campos Chave nao informados
			QKM->QKM_FILIAL	 := xFilial("QKM")
			QKM->QKM_PECA 	 := M->QKL_PECA
			QKM->QKM_REV 	 := M->QKL_REV
			QKM->QKM_REVINV	 := Inverte(QKL->QKL_REV)
			QKM->QKM_TPPRO	 := QKL->QKL_TPPRO																				
		
			//Controle de itens do acols
			QKM->QKM_ITEM := StrZero(nNumItem,Len(QKM->QKM_ITEM))

			nNumItem++

			MsUnlock()
		Else
			If DbSeek(xFilial("QKM")+ M->QKL_PECA + M->QKL_REV + M->QKL_TPPRO + StrZero(nIt,Len(QKM->QKM_ITEM)) )
				RecLock("QKM",.F.)
				DbDelete() 
				MsUnlock()
			Endif
		Endif

	Next nIt
	FKCOMMIT()

End Transaction
				
Return lGraOk


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A160Dele ³ Autor ³ Robson Ramiro A Olivei³ Data ³ 20.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Exclusao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A160Dele(ExpC1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Exp1N = Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function A160Dele()

DbSelectArea("QKM")
DbSetOrder(3)
If DbSeek(xFilial("QKM")+ QKL->QKL_PECA + QKL->QKL_REV + QKL->QKL_TPPRO )

	Do While !Eof() .and. ;
		QKL->QKL_PECA + QKL->QKL_REV + QKL->QKL_TPPRO == QKM_PECA + QKM_REV + QKM_TPPRO
		
		RecLock("QKM",.F.)
		DbDelete()
		MsUnLock()
		FKCOMMIT()
		DbSkip()
		
	Enddo

Endif

DbSelectArea("QKL")

RecLock("QKL",.F.)
DbDelete()
MsUnLock()        
FKCOMMIT()				
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PP160LinOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 20.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para mudanca/inclusao de linhas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP160LinOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function PP160LinOk()
Local cNxtPos     := " "
Local cOrgPLCItem := (GetMv("MV_QORGPLC",.T.,"2"))
Local lRetorno    := .T.
Local nCont       := 0
Local nPosItem    := aScan(aHeader, { |x| AllTrim(x[2]) == "QKM_ITEM" })
Local nLenItem    := Len(aCols[n,nPosItem]) //Pega o Tamanho do Item
Local nPosDel     := Len(aHeader) + 1
Local nPosNCAR    := aScan(aHeader, { |x| AllTrim(x[2]) == "QKM_NCAR" })
Local nPosNOPE    := aScan(aHeader, { |x| Upper(AllTrim(x[2])) == "QKM_NOPE" })

//verifica se ao menos 1 amostra foi preenchida
If Empty(aCols[n,nPosNCAR]) .and. !aCols[n, nPosDel]
	lRetorno := .F.
	Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
EndIf

If cOrgPLCItem == "1"  // Organiza por Item 
	cNxtPos:= STRZERO(VAL(aCols[n,nPosItem]),nLenItem)+AllTrim(aCols[n,nPosNOPE])
	
	//Organiza Posiciona e Refaz Itens no Acols baseada na operacao
	If lRetorno
		nCont := 1
		aCols := aSort(aCols,,,{|x,y| STRZERO(VAL(x[nPosItem]),nLenItem)+x[nPosNOPE] < STRZERO(VAL(y[nPosItem]),nLenItem)+y[nPosNOPE]})  // organizo o array    
		oGet:oBrowse:Refresh() 
		oGet:oBrowse:nAt:= Ascan(aCols,{|x| STRZERO(VAL(x[nPosItem]),nLenItem)+AllTrim(x[nPosNOPE]) == cNxtPos}) // Coloco na  posição desejada
		Aeval(aCols,{ |x| x[nPosItem]:= strzero(nCont++,nLenItem)  } ) // Refaz a numeracao do Item
		oGet:oBrowse:Refresh()    
	Endif
Elseif cOrgPLCItem == "2" // Default organiza por  operacao  organização alfanumérica
	cNxtPos:= AllTrim(aCols[n,nPosNOPE])+STRZERO(VAL(aCols[n,nPosItem]),nLenItem)
	
	//Organiza Posiciona e Refaz Itens no Acols
	If lRetorno
		nCont := 1
		aCols := aSort(aCols,,,{|x,y| x[nPosNOPE]+STRZERO(VAL(x[nPosItem]),nLenItem) < y[nPosNOPE]+STRZERO(VAL(y[nPosItem]),nLenItem)})  // Organizo o array
		oGet:oBrowse:Refresh()
		oGet:oBrowse:nAt:= Ascan(aCols,{|x| AllTrim(x[nPosNOPE])+STRZERO(VAL(x[nPosItem]),nLenItem) == cNxtPos}) // Coloco na  posição desejada
		Aeval(aCols,{ |x| x[nPosItem]:= strzero(nCont++,nLenItem)  } ) // Refaz a numeracao do Item
		oGet:oBrowse:Refresh()
	Endif
Else //Default organiza por  operacao  organização Numérica	
	
	//Organiza Posiciona e Refaz Itens no Acols	
	If lRetorno
		nCont := 1
		aCols := aSort(aCols,,,{|x,y| Val(x[nPosNOPE]) < Val(y[nPosNOPE])})	// Ordenacao Numerica do aCols pela Operacao
		aCols := aSort(aCols,,,{|x,y| Val(x[nPosNOPE]) < Val(y[nPosNOPE])})	// Ordenacao Numerica do aCols pela Operacao
		Aeval(aCols,{|x| x[nPosItem]:= StrZero(nCont++,nLenItem)})	   			// Refaz a numeracao do Item
		oGet:oBrowse:Refresh()
	Endif 
EndIf	
Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PP160TudOk³ Autor ³ Robson Ramiro A. Olive³ Data ³ 20.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consistencia para inclusao/alteracao geral                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PP160TudOk                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Function PP160TudOk()
Local lRetorno := .T.
Local nIt      := 0
Local nPosDel  := Len(aHeader) + 1
Local nPosNCAR := aScan(aHeader, { |x| AllTrim(x[2]) == "QKM_NCAR" })
Local nTot     := 0

//Verifica se na inclusao existe a peca + revisao
If INCLUI
	lRetorno := QPAVLDIN()
Endif

If lRetorno
	For nIt := 1 To Len(aCols)
		If aCols[nIt, nPosDel]
			nTot ++
		Endif
	Next nIt
	
	If !PP160LinOk() // Executo somente para organizar o acols
		lRetorno := .F.
	EndIf
	
	For nIt := 1 To Len(aCols)		
		//verifica se ao menos 1 amostra foi preenchida
		If Empty(aCols[nIt,nPosNCAR]) .and. !aCols[nIt, nPosDel]
			lRetorno := .F.
			Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
		EndIf
	Next nIt
	                
	If Empty(M->QKL_PECA) .or. Empty(M->QKL_REV) .or. nTot == Len(aCols)
		lRetorno := .F.
		Help(" ",1,"QPPAOBRIG")  // Campos obrigatorios
	EndIf
Endif

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPP160APRO³ Autor ³ Robson Ramiro A.Olivei³ Data ³ 20.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprova / Limpa                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPP160APRO(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do mBrowse									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPP160APRO(nOpc)
If nOpc == 3 .or. nOpc == 4
	DbSelectArea("QAA")
	DbSetOrder(6)
	If Dbseek(Upper(cUserName))
		M->QKL_DTAFOR := Iif(Empty(M->QKL_DTAFOR), dDataBase, CtoD(" / / "))
		M->QKL_APRFOR := Iif(Empty(M->QKL_APRFOR), cUserName, Space(50))
	Else
		messagedlg(STR0013) //"O usuário logado não está cadastrado no cadastro de usuários do módulo, portanto não poderá ser o aprovador"
	Endif	
Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QPAVLDIN  ³ Autor ³ Rafael S. Bernardi    ³ Data ³ 31/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se existem planos para essa peca                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPAVLDIN()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPA160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QPAVLDIN()
Local aArea  := GetArea()
Local aCombo := QPP160CBOX()
Local lRet   := .T.
Local nIt    := 0

If INCLUI
	DBSelectArea("QKL")
	DBSetOrder(1)
	If(QKL->(DBSeek(xFilial("QKL") + M->QKL_PECA + M->QKL_REV + M->QKL_TPPRO)))
		Help("",1,"JAGRAVADO")
		lRet := .F.
	EndIf
Endif	                                   
If INCLUI
	DBSelectArea("QKL")
	DBSetOrder(1) 
	For nIt := 1 To Len(aCombo)
		If(QKL->(MSSeek( xFilial("QKL") + M->QKL_PECA + M->QKL_REV + AllTrim(STR(nIt)) ))) // Posiciono no ultimo
		    If VAL(QKL->QKL_TPPRO) <> 0
				Help("",1,"QJAEXTPPR")
				lRet := .F.	              
			EndIf
		Endif
	Next
EndIf
RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPP160EVOLºAutor  ³Cicero Cruz         º Data ³  08/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que evolui o Plano nos estados -  Prototipo -> Pre- º±±
±±º          ³ lancamento -> Producao                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA160                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QPP160EVOL(nOpc)
Local aCombo := {} // Opções do ComboBox
Local aRet   := {} // Array de retorno
Local nIt    := 0  // Posição da opção escolhida

If Val(QKL->QKL_TPPRO) <> 0 .AND. nOpc == 4 
    //"STR0014 - Antes de executar este deve-se salvar o Plano de Controle, deseja salvar S/N."
	//"STR0015 - Atenção"
	If MsgYesNo( OemToAnsi(STR0014), OemToAnsi(STR0015)) .AND. PP160TudOk()
		// Gravo o Plano 
		A160Grav(nOpc)
		aCombo := QPP160CBOX()
		If Len(aCombo) >= 1
			// Monta Combo e oferece as alternativas
    	    aRet := QPPMONOPT(Val(QKL->QKL_TPPRO),aCombo)  
        	// Bloqueio o Plano                 
	        If aRet[1]
				nIt := aScan(aCombo, { |x| AllTrim(x) == AllTrim(aRet[2]) })
        		M->QKL_TPPRO := Alltrim(Str(nIt))

			    // Evoluo o Plano
				INCLUI := .T.
				A160Grav(3)	    
				INCLUI := .F.
    	    EndIf
    	EndIf
    EndIf
Else
	If Val(QKL->QKL_TPPRO) == 0
		Help("",1,"QNAOEVOLU")
	EndIf	
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPP160CBOXºAutor  ³Cicero Cruz         º Data ³  08/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que copia os valores do CBOX                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA160                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPP160CBOX()
Local aArea  := GetArea()
Local aRet   := {}
Local cTexto := ""
//1=Prototipo;2=Pre-Lancamento;3=Producao

cTexto := QAGetX3Cmb("QKL_TPPRO")
	
While !Empty(cTexto)
	nTexto:= At("=",cTexto)
	If nTexto > 0
		cTexto := Subs(cTexto,nTexto+1,Len(cTexto))
		nTexto:= At(";",cTexto)
		If nTexto > 0          
			cCombo := Subs(cTexto,1,nTexto-1)
			If !("Nao Evolui" $ cCombo)
				AAdd( aRet , cCombo  )
			EndIf
			cTexto := Subs(cTexto,nTexto+1,Len(cTexto))
		EndIf
	Else
		AAdd( aRet , cTexto  )
		cTexto := ""
	EndIf
EndDo
RestArea(aArea)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QPPMONOPT ºAutor  ³Cicero Cruz         º Data ³  08/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a Opção de evolução do plano                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QPPA160                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QPPMONOPT(nOptAtu,aCombo)
Local aItens := {}   // Itens Filtrados
Local cCombo := ""   // Opção escolhida
Local lOk    := .F.  // Clicado botão OK
Local nI     := 0    // Variavel Local do For
Local oCombo := Nil  // Objeto de tela 
Local oDlg   := Nil  // Objeto de tela 

For nI := 1 To Len(aCombo)
	If nI > nOptAtu
		AAdd( aItens , aCombo[nI]  )
	EndIf	
Next

If Len(aItens) >= 1         
	cCombo := aItens[1]

	DEFINE MSDIALOG oDlg FROM	35,37 TO 140,300 TITLE OemToAnsi(STR0017) PIXEL	//"Opções para Evolução de Fase de Produção"
	
	@ 017,005 COMBOBOX oCombo VAR cCombo ITEMS aItens SIZE 71, 50 OF oDlg PIXEL
	
	DEFINE SBUTTON FROM 011, 090 TYPE 1 ENABLE OF oDlg Action (lOk:=.T.,oDlg:End())
	DEFINE SBUTTON FROM 024, 090 TYPE 2 ENABLE OF oDlg Action (lOk:=.F.,oDlg:End())
	
	ACTIVATE MSDIALOG oDlg Centered
Else
	MsgInfo(STR0018) //"Não há mais opções de Evolução de fase de produção para esta peça."
EndIf
	
Return {lOk,cCombo}
