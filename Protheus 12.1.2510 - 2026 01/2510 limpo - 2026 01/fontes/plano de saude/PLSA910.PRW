
#INCLUDE "plsa910.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "MSGRAPHI.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA910 ³ Autor ³ Eduardo Motta          ³ Data ³ 30.07.01 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Simulacao de Venda                                         ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSA910()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA910
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina    	:= MenuDef()							
PRIVATE cCadastro 	:= OemtoAnsi(STR0006) //"Simulacao de Venda"
PRIVATE cCadNv2 	:= OemtoAnsi(STR0006) //"Simulacao de Venda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama funcao de Browse...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SUS->(DbSetOrder(2))
SUS->(dbGoTop())
SUS->(mBrowse(06,01,22,75,"SUS",,,20))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL910MOV ³ Autor ³ Eduardo Motta         ³ Data ³ 30.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de Manutencao dos Prospects x Propostas             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PL910MOV(cAlias,nReg,nOpc)                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL910MOV(cAlias,nReg,nOpc)
Local oDlg
Local nControl := 0,nControl2 := 0,nControl3:=0,nControl4:=0
Local aPages:= {}, aTitles:= {}, aFolders:={}
Local aPages2:= {}, aTitles2:= {}, aFolders2:={}
Local aPages3:= {}, aTitles3:= {}, aFolders3:={}
Local aPages4:= {}, aTitles4:= {}, aFolders4:={}
Local nOpca := 0
Local aVetGet02a:={}
Local aVetGet02b:={}
Local aVetGet03:={}
Local aVetGet03A:={}
Local aVetGet04:={}
Local oFolder,oFolder2,oFolder3,oFolder4
Local aChav02a := {}
Local aChav02b := {}
Local aChav03  := {}
Local aChav04  := {}
Local aChavBL9 := {}
Local aComp1   := {{""}}
Local aComp2   := {{""}}
Local oComp1
Local oComp2
Local oFont
Local aHeadBLC := {}
Local aColsBLC := {}
Local nPosC
Local nI,nJ
Local aVetBLC 	:= {}
Local nPosSeq	:= 0
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}

Private aSvATela := {{},{},{}}
Private aSvAGets := {{},{},{}}
Private aTela :={}
Private aGets :={}
Private oGet02a
Private oGet02b
Private oGet03
Private oGet03A
Private oGet04
PRIVATE aHeader := {}
PRIVATE aCols   := {}
PRIVATE n       := 1

nOpc := aRotina[nOpc,4]

aFolders  := {OemtoAnsi(STR0007),OemtoAnsi(STR0008),OemtoAnsi(STR0009),OemtoAnsi(STR0010),OemtoAnsi(STR0011)} //"Prospects"###"Funcionarios"###"Propostas"###"Concorrencia"###"Comparativo"
aFolders2 := {OemtoAnsi(STR0012),OemtoAnsi(STR0013)} //"Analitico"###"Sintetico"
aFolders3 := {OemtoAnsi(STR0009)} //"Propostas"
aFolders4 := {OemtoAnsi(STR0009),OemtoAnsi(STR0014)} //"Propostas"###"Tabela de Preco"

SetEnch("")
For nI := 1 to Len(aFolders)
	Aadd(aTitles,OemtoAnsi(aFolders[nI]))
	Aadd(aPages,"HEADER "+Trim(Str(nI,2)))
	nControl++
Next
For nI := 1 to Len(aFolders2)
	Aadd(aTitles2,OemtoAnsi(aFolders2[nI]))
	Aadd(aPages2,"HEADER "+Trim(Str(nI,2)))
	nControl2++
Next
For nI := 1 to Len(aFolders3)
	Aadd(aTitles3,OemtoAnsi(aFolders3[nI]))
	Aadd(aPages3,"HEADER "+Trim(Str(nI,2)))
	nControl3++
Next
For nI := 1 to Len(aFolders4)
	Aadd(aTitles4,OemtoAnsi(aFolders4[nI]))
	Aadd(aPages4,"HEADER "+Trim(Str(nI,2)))
	nControl4++
Next

dbSelectArea("SUS")
DbSetOrder(1)
If nOpc == 3   // inclusao
	RegToMemory('SUS',.T.)
Else
	RegToMemory('SUS',.F.)
EndIf

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T., .F. )	

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel
oFolder := TFolder():New(aPosObj[1][1],aPosObj[1][2],aTitles,aPages,oDlg,,,,.T.,.F.,aPosObj[1][3],aPosObj[1][4],)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 01 - DADOS GERAIS                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
oEnc01:= MsMGet():New("SUS" ,nReg ,nOpc,,,,,{3,3,aPosObj[1][4]-15,aPosObj[1][3]-4},,,,,,oFolder:aDialogs[1],,,.F.,"aSvATela[1]")
aSvATela[1] := aClone(aTela)
aSvAGets[1] := aClone(aGets)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 02 - FUNCIONARIOS                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder2 := TFolder():New(3,3,aTitles2,aPages2,oFolder:aDialogs[2],,,,.T.,.F.,aPosObj[1][3]-8,aPosObj[1][4]-18,)

aHeader := {}
aCols   := {}

Store Header "BL4" TO aHeader For .T.
If nOpc == K_Incluir
	Store COLS Blank "BL4" TO aCols FROM aHeader
Else
	DbSelectArea("BL4")
	DbSetOrder(1)
	If MsSeek(xFilial("BL4")+SUS->US_COD+SUS->US_LOJA)
		Store COLS "BL4" TO aCols FROM aHeader VETTRAB aVetGet02a While xFilial("BL4") == BL4->BL4_FILIAL .and. SUS->US_COD == BL4->BL4_CODIGO .and. SUS->US_LOJA == BL4->BL4_LOJA
	Else
		Store COLS Blank "BL4" TO aCols FROM aHeader
	EndIf
EndIf
oGet02a := TPLSBrw():New(3,3,aPosObj[1][3]-12,aPosObj[1][4]-33,nil  ,oFolder2:aDialogs[1],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BL4",nOpc,cCadNv2,nil,nil,nil,aVetGet02a)

aHeader := {}
aCols   := {}
Store Header "BL8" TO aHeader For .T.
If nOpc == K_Incluir
	Store COLS Blank "BL8" TO aCols FROM aHeader
Else
	DbSelectArea("BL8")
	DbSetOrder(1)
	If MsSeek(xFilial("BL8")+SUS->US_COD+SUS->US_LOJA)
		Store COLS "BL8" TO aCols FROM aHeader VETTRAB aVetGet02b While xFilial("BL8") == BL8->BL8_FILIAL .and. SUS->US_COD == BL8->BL8_CODIGO .and. SUS->US_LOJA == BL8->BL8_LOJA
	Else
		Store COLS Blank "BL8" TO aCols FROM aHeader
	EndIf
EndIf
oGet02b := TPLSBrw():New(3,3,aPosObj[1][3]-12,aPosObj[1][4]-33,nil  ,oFolder2:aDialogs[2],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BL8",nOpc,cCadNv2,nil,nil,nil,aVetGet02b)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 03 - Produtos (Planos)                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oFolder4 := TFolder():New(3,3,aTitles4,aPages4,oFolder:aDialogs[3],,,,.T.,.F.,aPosObj[1][3]-8,aPosObj[1][4]-18,)

aHeader := {}
aCols   := {}

Store Header "BL2" TO aHeader For .T.
If nOpc == K_Incluir
	Store COLS Blank "BL2" TO aCols FROM aHeader
Else
	DbSelectArea("BL2")
	DbSetOrder(1)
	If MsSeek(xFilial("BL2")+SUS->US_COD+SUS->US_LOJA)
		Store COLS "BL2" TO aCols FROM aHeader VETTRAB aVetGet03 While xFilial("BL2") == BL2->BL2_FILIAL .and. SUS->US_COD == BL2->BL2_CODIGO .and. SUS->US_LOJA == BL2->BL2_LOJA
	Else
		Store COLS Blank "BL2" TO aCols FROM aHeader
	EndIf
EndIf
oGet03 := TPLSBrw():New(3,3,aPosObj[1][3]-12,aPosObj[1][4]-50,nil  ,oFolder4:aDialogs[1],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BL2",nOpc,cCadNv2,nil,nil,nil,aVetGet03,,,)
nPosSeq := oGet03:PlRetPos("BL2_SEQUEN")
oGet03:bLostFocus := {||CargaComp(oComp1,oComp2,aComp1,aComp2,oGet03,oGet04)}
oGet03:bChange := { || oGet03A:ForceRefresh(oGet03) }
@ aPosObj[1][4]-47,015 BUTTON OemtoAnsi(STR0066) SIZE 65,13 PIXEL ACTION (ReTabPre()) OF oFolder4:aDialogs[1] //"Atualiza Tab.Preco"
@ aPosObj[1][4]-47,095 BUTTON OemtoAnsi(STR0015) SIZE 35,13 PIXEL ACTION (CalcSimu()) OF oFolder4:aDialogs[1] //"&Calcula"


aHeader := {}
aCols   := {}
Store Header "BL3" TO aHeader For .T.
If nOpc == K_Incluir
	Store COLS Blank "BL3" TO aCols FROM aHeader
Else
	DbSelectArea("BL3")
	DbSetOrder(1)
	If MsSeek(xFilial("BL3")+SUS->US_COD+SUS->US_LOJA)
		Store COLS "BL3" TO aCols FROM aHeader VETTRAB aVetGet03A While xFilial("BL3") == BL3->BL3_FILIAL .and. SUS->US_COD == BL3->BL3_CODIGO .and. SUS->US_LOJA == BL3->BL3_LOJA
	Else
		Store COLS Blank "BL3" TO aCols FROM aHeader
	EndIf
EndIf

oGet03A := TPLSBrw():New(3,3,aPosObj[1][3]-12,aPosObj[1][4]-33,nil  ,oFolder4:aDialogs[2],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BL3",nOpc,cCadNv2,nil,nil,nil,;
aVetGet03A,,,{|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BL3_SEQUEN",aHeader)]==oGet03:FieldGet("BL2_SEQUEN") })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 04 - CONCORRENTES                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder3 := TFolder():New(3,3,aTitles3,aPages3,oFolder:aDialogs[4],,,,.T.,.F.,aPosObj[1][3]-8,aPosObj[1][4]-18,)

aHeader := {}
aCols   := {}

Store Header "BLB" TO aHeader For .T.
If nOpc == K_Incluir
	Store COLS Blank "BLB" TO aCols FROM aHeader
Else
	DbSelectArea("BLB")
	DbSetOrder(1)
	If MsSeek(xFilial("BLB")+SUS->US_COD+SUS->US_LOJA)
		Store COLS "BLB" TO aCols FROM aHeader VETTRAB aVetGet04 While xFilial("BLB") == BLB->BLB_FILIAL .and. SUS->US_COD == BLB->BLB_CODIGO .and. SUS->US_LOJA == BLB->BLB_LOJA
	Else
		Store COLS Blank "BLB" TO aCols FROM aHeader
	EndIf
EndIf
oGet04 := TPLSBrw():New(3,3,aPosObj[1][3]-12,aPosObj[1][4]-50,nil  ,oFolder3:aDialogs[1],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BLB",nOpc,cCadNv2,nil,nil,nil,aVetGet04)
oGet04:bLostFocus := {||CargaComp(oComp1,oComp2,aComp1,aComp2,oGet03,oGet04)}
oGet04:Cargo := {}
If nOpc # 3
	oGet04:Cargo := CarrFxCon(SUS->US_COD,SUS->US_LOJA,aVetBLC)
EndIf

@ aPosObj[1][4]-47,015 BUTTON OemtoAnsi(STR0016) SIZE 35,13 PIXEL ACTION (FaixaEta(),oGet04:oBrowse:oBrowse:SetFocus() ) OF oFolder3:aDialogs[1] //"&Faixa Etaria"

Store Header "BLC" TO aHeadBLC For .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 05 - Comparativo                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE FONT oFont  NAME "Arial" SIZE 0, -26 BOLD

@ 05,10 Say OemtoAnsi(STR0017) FONT oFont Of oFolder:aDialogs[5] PIXEL //"Nossa Empresa"

@ 23,03 LISTBOX oComp1 FIELDS HEADER OemtoAnsi(STR0018) FIELDSIZES 070 SIZE (aPosObj[1][3]/2)-24,aPosObj[1][4]-39 OF oFolder:aDialogs[5] PIXEL //"Proposta"

@ 040,(aPosObj[1][3]/2)-18 BUTTON OemtoAnsi(STR0019)    SIZE 35,13 PIXEL ACTION (Compara(oComp1,oComp2,aComp1,aComp2)) OF oFolder:aDialogs[5] //"&Compara"

@ 060,(aPosObj[1][3]/2)-18 BUTTON OemtoAnsi(STR0020)    SIZE 35,13 PIXEL ACTION (Compara(oComp1,oComp2,aComp1,aComp2, .T.)) OF oFolder:aDialogs[5] //"&Grafico"

@ 05,(aPosObj[1][3]/2)+27 Say OemtoAnsi(STR0010) FONT oFont Of oFolder:aDialogs[5] PIXEL //"Concorrencia"
@ 23,(aPosObj[1][3]/2)+20 LISTBOX oComp2 FIELDS HEADER OemtoAnsi(STR0021) FIELDSIZES 070 SIZE (aPosObj[1][3]/2)-24,aPosObj[1][4]-39 OF oFolder:aDialogs[5] PIXEL //"Concorrente"
oComp1:SetArray(aComp1)
oComp1:bLine      := {|| {aComp1[oComp1:nAt,1] }}
oComp1:bLDblClick := {||.t.}
oComp1:bChange    := {||.t.}

oComp2:SetArray(aComp2)
oComp2:bLine      := {|| {aComp2[oComp2:nAt,1] }}
oComp2:bLDblClick := {||.t.}
oComp2:bChange    := {||.t.}

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| nOpca:=1,oDlg:End()},{|| nOpca:= 0,oDlg:End()} ),CargaComp(oComp1,oComp2,aComp1,aComp2,oGet03,oGet04))

If nOpca == 1 // ok
	BEGIN TRANSACTION

	PLUPTENC("SUS",nOpc)    // FOLDER 01 - PROSPECTs
	
	aChav02a := {{"BL4_CODIGO",M->US_COD},;
	{"BL4_LOJA"  ,M->US_LOJA}}
	
	aChav02b := {{"BL8_CODIGO",M->US_COD},;
	{"BL8_LOJA"  ,M->US_LOJA}}
	
	aChav03  := {{"BL2_CODIGO",M->US_COD},;
	{"BL2_LOJA"  ,M->US_LOJA}}
	
	aChav03A := {{"BL3_CODIGO",M->US_COD},;
	{"BL3_LOJA"  ,M->US_LOJA}}
	
	aChav04  := {{"BLB_CODIGO",M->US_COD},;
	{"BLB_LOJA"  ,M->US_LOJA}}
	
	oGet02a:Grava(aChav02a)
	oGet02b:Grava(aChav02b)
	oGet03:Grava(aChav03)
	oGet03A:Grava(aChav03A)
	oGet04:Grava(aChav04)
	
	If nOpc = 4 .And. nPosSeq > 0	// Alteracao Excluo precos de tabela de propostas marcadas
		For nI := 1 To Len(oGet03:aCols)
			If 	oGet03:aCols[nI][Len(oGet03:aCols[nI])] .And.;		// Deletado
				BL3->(MsSeek(xFilial("BL3") + M->US_COD + M->US_LOJA +;
				oGet03:aCols[nI][nPosSeq]))
				
				While 	! BL3->(Eof()) .And. BL3->BL3_CODIGO = M->US_COD .And.;
						BL3->BL3_LOJA = M->US_LOJA .And. BL3->BL3_SEQUEN = oGet03:aCols[nI][nPosSeq]
					BL3->(RecLock("BL3"))
					BL3->(DbDelete())
					BL3->(MsUnLock())
					BL3->(DbSkip())
				EndDo				
			Endif
		Next
	Endif
	
	aColsBLC := {}
	For nI := 1 to Len(oGet04:Cargo)
		For nJ := 1 to Len(oGet04:Cargo[nI,2])
			If oGet04:Cargo[nI,01] <> "999"
				aadd(aColsBLC,{oGet04:Cargo[nI,01],oGet04:Cargo[nI,2,nJ,01],oGet04:Cargo[nI,2,nJ,02],oGet04:Cargo[nI,2,nJ,03],oGet04:Cargo[nI,2,nJ,04]})
			Endif
			//         oGet04:Cargo[nI,01]        => Sequencia
			//         oGet04:Cargo[nI,2,nJ,01]   => Faixa Etaria
			//         oGet04:Cargo[nI,2,nJ,02]   => Tipo
			//         oGet04:Cargo[nI,2,nJ,03]   => Valor
		Next
	Next
	
	aChavBL9  := {{"BLC_CODIGO",M->US_COD},;
	{"BLC_LOJA"  ,M->US_LOJA}}
	
	PLUPTCOLS("BLC",aColsBLC,aHeadBLC,aVetBLC,nOpc,aChavBL9,.F.)
	
	END TRANSACTION
	If __lSX8
		ConfirmSX8()
	Endif
Else
	If __lSX8
		RollBackSX8()
	Endif
EndIf


Return

Static Function ReTabPre()
Private M->BL2_CODINT := oGet03:FieldGet("BL2_CODINT")
Private M->BL2_CODPRO := oGet03:FieldGet("BL2_CODPRO")
Private M->BL2_VERSAO := oGet03:FieldGet("BL2_VERSAO")
Private M->BL2_CONPAG := oGet03:FieldGet("BL2_CONPAG")
Private M->BL2_FAIFAM := oGet03:FieldGet("BL2_FAIFAM")
Private M->BL2_SEQUEN := oGet03:FieldGet("BL2_SEQUEN")
Private M->BL2_DESCON := oGet03:FieldGet("BL2_DESCON")
Pl910CarEt(,.f.)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL910Lib ³ Autor ³ Eduardo Motta         ³ Data ³ 10.05.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de liberacao/bloqueio de propostas                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PL910Lib(cAlias,nReg,nOpc)                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL910Lib(cAlias,nReg,nOpc)
Local oDlg
Local aTitles := {}
Local aFolders := {}
Local aPages := {}
Local nI
Local nControl := 0
Local nOpca := 0
Local nPosSta
Local oBmp1,oBmp2
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Private aTela :={}
Private aGets :={}
Private oGet03
Private aVetGet03 := {}
PRIVATE aHeader := {}
PRIVATE aCols   := {}
PRIVATE n       := 1
Private aChave03

aFolders  := {OemtoAnsi(STR0007),OemtoAnsi(STR0009)} //"Prospects"###"Propostas"

SetEnch("")
For nI := 1 to Len(aFolders)
	Aadd(aTitles,OemtoAnsi(aFolders[nI]))
	Aadd(aPages,"HEADER "+Trim(Str(nI,2)))
	nControl++
Next

dbSelectArea("SUS")
DbSetOrder(1)
RegToMemory('SUS',.F.)

aSize := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T., .F. )	

DEFINE MSDIALOG oDlg TITLE cCadNv2 FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel
oFolder := TFolder():New(aPosObj[1][1],aPosObj[1][2],aTitles,aPages,oDlg,,,,.T.,.F.,aPosObj[1][3],aPosObj[1][4],)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 01 - DADOS GERAIS                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
oEnc01:= MsMGet():New("SUS" ,nReg ,K_Visualizar,,,,,{3,3,aPosObj[1][4]-15,aPosObj[1][3]-4},,,,,,oFolder:aDialogs[1],,,.F.,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Folder 02 - Propostas                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aHeader := {}
aCols   := {}

Store Header "BL2" TO aHeader For .T.
If nOpc == K_Incluir
	Store COLS Blank "BL2" TO aCols FROM aHeader
Else
	DbSelectArea("BL2")
	DbSetOrder(1)
	If MsSeek(xFilial("BL2")+SUS->US_COD+SUS->US_LOJA)
		Store COLS "BL2" TO aCols FROM aHeader VETTRAB aVetGet03 While xFilial("BL2") == BL2->BL2_FILIAL .and. SUS->US_COD == BL2->BL2_CODIGO .and. SUS->US_LOJA == BL2->BL2_LOJA
	Else
		Store COLS Blank "BL2" TO aCols FROM aHeader
	EndIf
EndIf
nPosSta := GDFieldPos("BL2_STATUS",aHeader)
InsColuna(aHeader, aCols, 1, "BL2", "Status", "BL2_DESSTA", {|x|If(aCols[x,nPosSta+1]=="1","DISABLE","ENABLE")},.T.)
oGet03 := TPLSBrw():New(3,3,aPosObj[1][3]-5,aPosObj[1][4]-33,nil  ,oFolder:aDialogs[2],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,"BL2",K_Visualizar,cCadNv2,nil,nil,nil,aVetGet03,,,)

@ aPosObj[1][4]-29,015 BUTTON OemtoAnsi(STR0067)        SIZE 55,13 PIXEL ACTION (ChkStatus(oGet03)) OF oFolder:aDialogs[2] //"&Calcula" //"Libera/Bloqueia"
@ aPosObj[1][4]-26,095 BITMAP oBmp1 RESNAME "ENABLE"  OF oFolder:aDialogs[2] SIZE 25,25 NOBORDER WHEN .F. PIXEL
@ aPosObj[1][4]-26,105 SAY OemtoAnsi(STR0068)   OF oFolder:aDialogs[2] SIZE 25,25 PIXEL //"Liberada"
@ aPosObj[1][4]-26,180 BITMAP oBmp2 RESNAME "DISABLE"  OF oFolder:aDialogs[2] SIZE 25,25 NOBORDER WHEN .F. PIXEL
@ aPosObj[1][4]-26,190 SAY OemtoAnsi(STR0069)   OF oFolder:aDialogs[2] SIZE 25,25 PIXEL //"Bloqueada"

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| nOpca:=1,oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))

If nOpca == 1 // ok
   oGet03:nOpc := K_Alterar
	aChave03  := {{"BL2_CODIGO",M->US_COD},;
  	               {"BL2_LOJA"  ,M->US_LOJA}}
   oGet03:Grava(aChave03,.t.)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InsColuna ºAutor  ³Paulo Carnelossi    º Data ³  03/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inserir uma coluna nos arrays aCabAlias, aDadAlias para uso º±±
±±º          ³na browse da classe plsbrw                                  º±±
±±º          ³somente colunas caracteres, criando campo virtual - Visual  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InsColuna(aCab, aDad, nPos, cAlias, cTitle, cCampo, bRotFun, lBitMap)
Local nTamCpo, nCtd
DEFAULT lBitMap := .F.

ASIZE(aCab,Len(aCab)+1)
AINS(aCab, nPos)

For nCtd := 1 TO LEN(aDad)
	ASIZE(aDad[nCtd], Len(aDad[nCtd])+1)
	AINS(aDad[nCtd], nPos)
	aDad[nCtd][nPos] := Eval(bRotFun, nCtd)
	nTamCpo := Len(aDad[nCtd][nPos])
Next	

/*
[ 1] := SX3->X3_TITULO
[ 2] := SX3->X3_CAMPO
[ 3] := SX3->X3_PICTURE
[ 4] := SX3->X3_TAMANHO
[ 5] := SX3->X3_DECIMAL
[ 6] := SX3->X3_VALID
[ 7] := SX3->X3_USADO
[ 8] := SX3->X3_TIPO
[ 9] := SX3->X3_ARQUIVO
[10] := SX3->X3_CONTEXT
*/

aCab[nPos] := {}
aAdd(aCab[nPos], cTitle)
aAdd(aCab[nPos], cCampo)
aAdd(aCab[nPos], If(lBitMap,"@BMP","@!"))
aAdd(aCab[nPos], nTamCpo)
aAdd(aCab[nPos], 0)
aAdd(aCab[nPos], "")
aAdd(aCab[nPos], "")
aAdd(aCab[nPos], "C")
aAdd(aCab[nPos], cAlias)
aAdd(aCab[nPos], "V")

Return



Static Function ChkStatus(oGet03)
If oGet03:FieldGet("BL2_STATUS")#"2" // SE ESTIVER BLOQUEADA(=1) DESBLOQUEIA E SE ESTIVER LIBERADA(=2) A PROPOSTA SERA BLOQUEADA
   If !Empty(oGet03:FieldGet("BL2_DATVAL")) .and. oGet03:FieldGet("BL2_DATVAL") <= dDataBase
      MsgStop(OemtoAnsi(STR0070)) //" Proposta ja esta vencida e nao pode ser liberada."
   Else   
      oGet03:FieldPut("BL2_STATUS","2")
      oGet03:FieldPut("BL2_DESSTA","ENABLE")
   EndIf
Else
   oGet03:FieldPut("BL2_STATUS","1")
   oGet03:FieldPut("BL2_DESSTA","DISABLE")
EndIf
oGet03:oBrowse:oBrowse:SetFocus()
Return



Static Function CargaComp(oComp1,oComp2,aComp1,aComp2,oGet1,oGet2)
Local nI
Local bBakLine
aComp1 := {}
aComp2 := {}

For nI := 1 to Len(oGet1:aCols)
	If oGet1:aCols[nI,oGet1:ColDel()]  // se a linha estiver deletada nao considera
		Loop
	EndIf
	aadd(aComp1,{oGet1:aCols[nI,oGet1:PLRetPos("BL2_DESPRO") ],nI})
Next
If Len(aComp1) == 0
	aComp1 := {{"",0}}
EndIf
For nI := 1 to Len(oGet2:aCols)
	If oGet2:aCols[nI,oGet2:ColDel()]  // se a linha estiver deletada nao considera
		Loop
	EndIf
	aadd(aComp2,{oGet2:aCols[nI,oGet2:PLRetPos("BLB_DESPLA") ],nI})
Next
If Len(aComp2) == 0
	aComp2 := {{"",0}}
EndIf


bBakLine := oComp1:bLine
oComp1:SetArray(aComp1)
oComp1:bLine      := bBakLine
oComp1:Refresh()

bBakLine := oComp2:bLine
oComp2:SetArray(aComp2)
oComp2:bLine      := bBakLine
oComp2:Refresh()

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CalcSimu ³ Autor ³ Eduardo Motta         ³ Data ³ 14.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de calculo da simulacao de venda                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CalcSimu()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CalcSimu()
Local oDlg
Local oGeral
Local aGeral := {}
Local nI := 0
Local cSexo  := ""
Local nIdade := 0
Local nPos   := 0
Local cCodCon     := oGet03:FieldGet("BL2_CONPAG")
Local nVrContrato := oGet03:FieldGet("BL2_VLRCON")
Local nGR         := oGet03:FieldGet("BL2_GRARIS")
Local nOpca     := 0
Local cCodInt   := oGet03:aCols[oGet03:Linha(),oGet03:PlRetPos("BL2_CODINT")]
Local cCodPla   := oGet03:aCols[oGet03:Linha(),oGet03:PlRetPos("BL2_CODPRO")]
Local cDesPla   := oGet03:aCols[oGet03:Linha(),oGet03:PlRetPos("BL2_DESPRO")]
Local cDesCon   := Space(40)
Local cDesTip
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}

aGeral := aClone(CarregaBL9())

VldCodCon(cCodCon,@cDesCon,.f.)
PlsVlrCont(@nVrContrato,@nGR,aGeral)

aSize := MsAdvSize()
aSize[7] := Round(aSize[7] * 0.92, 0)
aSize[6] := Round(aSize[6] * 0.92, 0)
aSize[5] := Round(aSize[5] * 0.92, 0)
aSize[4] := Round(aSize[4] * 0.92, 0)
aSize[3] := Round(aSize[3] * 0.92, 0)
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T., .F. )	

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0022) FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel //"Resumo da Simulacao de Venda"
oDlg:lEscClose := .F.

@ aPosObj[1][1],aPosObj[1][2] LISTBOX oGeral FIELDS HEADER OemtoAnsi(STR0023),OemtoAnsi(STR0024),OemtoAnsi(STR0025),"  %",OemtoAnsi(STR0026),"  %",OemtoAnsi(STR0027),"  %",OemtoAnsi(STR0028) FIELDSIZES 070,45,35,25,30,25,30,25,40 SIZE aPosObj[1][4]-1,aPosObj[1][3]-41 OF oDlg PIXEL //"FAIXA ETARIA"###"TIPO"###"MASCULINO"###"FEMININO"###"GERAL"###"VALOR"
oGeral:SetArray(aGeral)
oGeral:bLine      := {|| {aGeral[oGeral:nAt,1],aGeral[oGeral:nAt,9],Str(aGeral[oGeral:nAt,3],3),Str(aGeral[oGeral:nAt,4],3),Str(aGeral[oGeral:nAt,5],3),Str(aGeral[oGeral:nAt,6],3),Str(aGeral[oGeral:nAt,7],3),Str(aGeral[oGeral:nAt,8],3),TransForm(aGeral[oGeral:nAt,11],"@E 999,999,999.99") }}
oGeral:bLDblClick := {||.t.}
oGeral:bChange    := {||.t.}

@ aPosObj[1][1]+aPosObj[1][3]-35,05 Say OemtoAnsi(STR0029)                 SIZE 80,12  PIXEL of oDlg //"Plano"
@ aPosObj[1][1]+aPosObj[1][3]-37,40 MsGet cDesPla               SIZE 150,08 PIXEL of oDlg When .F.
@ aPosObj[1][1]+aPosObj[1][3]-23,05 Say OemtoAnsi(STR0030)            SIZE 80,12  PIXEL of oDlg //"Cond.Pagto"
@ aPosObj[1][1]+aPosObj[1][3]-25,40 MsGet cCodCon Picture "999" SIZE 20,08  PIXEL of oDlg F3 "B44" HASBUTTON Valid VldCodCon(cCodCon,@cDesCon) .and. PlsVlrCont(@nVrContrato,@nGR,aGeral) .and. (oGeral:Refresh(),.T.)
@ aPosObj[1][1]+aPosObj[1][3]-25,80 MsGet cDesCon               SIZE 80,08  PIXEL of oDlg When .F.

@ aPosObj[1][1]+aPosObj[1][3]-35,200 Say OemtoAnsi(STR0031) SIZE 50,12 PIXEL of oDlg //"Valor do Contrato "
@ aPosObj[1][1]+aPosObj[1][3]-37,260 MsGet nVrContrato Picture "@E 999,999,999.99" SIZE 80,08 PIXEL of oDlg WHEN .f.
@ aPosObj[1][1]+aPosObj[1][3]-23,200 Say "G.R."               SIZE 25,12 PIXEL of oDlg
@ aPosObj[1][1]+aPosObj[1][3]-25,260 MsGet nGR Picture "99"   SIZE 15,08 PIXEL of oDlg WHEN .f.

ACTIVATE MSDIALOG oDlg CENTERED  ON INIT(EnchoiceBar(oDlg, {|| nOpca:=1,oDlg:End()},{|| nOpca:= 0,oDlg:End()} )) 

If nOpca == 1
	oGet03:FieldPut("BL2_CONPAG",cCodCon)
	oGet03:FieldPut("BL2_VLRCON",nVrContrato)
	oGet03:FieldPut("BL2_GRARIS",nGR)
	oGet03:lAltered := .T.
EndIf

Return

Static Function CarregaBL9(aHeaderA,aColsA,aHeaderS,aColsS,aHeaderP,aColsP,cSequen,cFaiFam)
Local aGeral 	:= {}
Local nTotFun 	:= 0
Local nPer
Local nI
Local nSomaPerM := 0.00
Local nSomaPerF := 0.00
Local nPosM     := 0
Local nMaior    := 0.00
Local cMaior    := ""
Local nDifPer   := 0.00
Local cCodSeq
Local cCodTip
Local nRetMas	:= nRetFem := nRetDois := 0, nIdade := 0
Local cSeqBL9	:= ""
Local aFamiliar	:= {}

Local nBL3_SEQUEN, nBL3_SEQBL9, nBL3_CODTIP, nBL3_DESCRI, nBL3_VLRMAS, nBL3_VLRFEM, nLido := 0

DEFAULT aColsA		:= oGet02a:aCols
DEFAULT aHeaderA	:= oGet02a:aHeader
DEFAULT aColsS		:= oGet02b:aCols
DEFAULT aHeaderS	:= oGet02b:aHeader
DEFAULT aColsP		:= oGet03A:aCols
DEFAULT aHeaderP	:= oGet03A:aHeader
DEFAULT cSequen		:= oGet03:FieldGet("BL2_SEQUEN")
DEFAULT cFaiFam		:= oGet03:FieldGet("BL2_FAIFAM")

nBL3_SEQUEN	:= Ascan(aHeaderP, {|x| AllTrim(x[2]) = "BL3_SEQUEN" })
nBL3_SEQBL9	:= Ascan(aHeaderP, {|x| AllTrim(x[2]) = "BL3_SEQBL9" })
nBL3_CODTIP	:= Ascan(aHeaderP, {|x| AllTrim(x[2]) = "BL3_CODTIP" })
nBL3_DESCRI	:= Ascan(aHeaderP, {|x| AllTrim(x[2]) = "BL3_DESCRI" })
nBL3_VLRMAS	:= Ascan(aHeaderP, {|x| AllTrim(x[2]) = "BL3_VLRMAS" })
nBL3_VLRFEM	:= Ascan(aHeaderP, {|x| AllTrim(x[2]) = "BL3_VLRFEM" })

For nI := 1 To Len(aColsP)
	If ! aColsP[nI][Len(aColsP[nI])] .And. aColsP[nI][nBL3_SEQUEN] = cSequen
		BL9->(MsSeek(xFilial("BL9") + aColsP[nI][nBL3_SEQBL9]))
		aadd(aGeral,{If(aColsP[nI][nBL3_SEQBL9] <> cSeqBL9,;
		BL9->BL9_DESCRI, Space(Len(BL9->BL9_DESCRI))),aColsP[nI][nBL3_SEQBL9],0,0.00,0,0.00,0,0.00,aColsP[nI][nBL3_DESCRI],aColsP[nI][nBL3_CODTIP],0.00, 0.00, aColsP[nI][nBL3_VLRMAS], aColsP[nI][nBL3_VLRFEM] })
		cSeqBL9 := aColsP[nI][nBL3_SEQBL9]
	Endif
Next

aadd(aGeral,{Left(OemtoAnsi(STR0063) + Space(Len(BL9->BL9_DESCRI)),Len(BL9->BL9_DESCRI)),; //"TOTAL"
"999", 0,0,0,0,0,0,Space(Len(BIH->BIH_DESCRI)),Space(Len(BL3->BL3_CODTIP)),0.00, 0.00, 0, 0 })

For nI := 1 To Len(aColsA)
	If aColsA[nI,Len(aColsA[1])]
		Loop
	EndIf
	
	If cFaiFam = "1"
		If (nPos := Ascan(aFamiliar, {|x| 	x[1] = aColsA[nI,GDFieldPos("BL4_NROFAM",aHeaderA)] })) = 0
			Aadd(aFamiliar, { 	aColsA[nI,GDFieldPos("BL4_NROFAM",aHeaderA)],;
								If(aColsA[nI,GDFieldPos("BL4_SEXO",aHeaderA)] = "1",;
								1, 0),;
								If(aColsA[nI,GDFieldPos("BL4_SEXO",aHeaderA)] = "2",;
								1, 0) })
								
		Else
			If aColsA[nI,GDFieldPos("BL4_SEXO",aHeaderA)] = "1"
				aFamiliar[nPos][2] ++
			Else
				aFamiliar[nPos][3] ++
			Endif
		Endif
	Else
		cCodSeq := BL4->(PlsFaixaEt(aColsA[nI,GDFieldPos("BL4_IDADE",aHeaderA)]))
		cCodTip := aColsA[nI,GDFieldPos("BL4_TIPOFU",aHeaderA)]
		If aColsA[nI,GDFieldPos("BL4_SEXO",aHeaderA)] == "1"   // sexo masculino
			nPos := aScan(aGeral,{|x|x[2]==cCodSeq .and. x[10]==cCodTip})
			If nPos # 0
				aGeral[nPos,3] := aGeral[nPos,3] + 1
				aGeral[Len(aGeral),3] ++
			EndIf
		ElseIf aColsA[nI,GDFieldPos("BL4_SEXO",aHeaderA)] == "2"  // sexo feminino
			nPos := aScan(aGeral,{|x|x[2]==cCodSeq .and. x[10]==cCodTip})
			If nPos # 0
				aGeral[nPos,5] := aGeral[nPos,5] + 1
				aGeral[Len(aGeral),5] ++
			EndIf
		EndIf
		// geral
		If aColsA[nI,GDFieldPos("BL4_SEXO",aHeaderA)] $ "12"   // sexo masculino ou feminino
			nPos := aScan(aGeral,{|x|x[2]==cCodSeq .and. x[10]==cCodTip})
			If nPos # 0
				aGeral[nPos,7] := aGeral[nPos,7] + 1
				aGeral[Len(aGeral),7] ++
			EndIf
			nTotFun++
		EndIf
	Endif
Next

For nI := 1 To Len(aColsS)
	If aColsS[nI,Len(aColsS[1])]
		Loop
	EndIf
	If cFaiFam = "1"
		If (nPos := Ascan(aFamiliar, {|x| 	x[1] = aColsS[nI,GDFieldPos("BL8_NROFAM",aHeaderS)] })) = 0
			Aadd(aFamiliar, { 	aColsS[nI,GDFieldPos("BL8_NROFAM",aHeaderS)],;
								If(aColsS[nI,GDFieldPos("BL8_SEXO",aHeaderS)] = "1",;
								aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)], 0),;
								If(aColsS[nI,GDFieldPos("BL8_SEXO",aHeaderS)] = "2",;
								aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)], 0) })
								
		Else
			If aColsS[nI,GDFieldPos("BL8_SEXO",aHeaderS)] = "1"
				aFamiliar[nPos][2] += aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)]
			Else
				aFamiliar[nPos][3] += aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)]
			Endif
		Endif
	Else
		cCodTip := aColsS[nI,GDFieldPos("BL8_TIPOFU",aHeaderS)]
		If Empty(cCodTip)
			cCodTip := "T"
		Endif
		If aColsS[nI,GDFieldPos("BL8_SEXO",aHeaderS)] == "1"   // sexo masculino
			nPos := aScan(aGeral,{|x|x[2]==aColsS[nI,GDFieldPos("BL8_FAIXAE",aHeaderS)] .and. x[10]==cCodTip})
			If nPos # 0
				aGeral[nPos,3] := aGeral[nPos,3] + aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)]
				aGeral[Len(aGeral),3] +=aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)]
			EndIf
		ElseIf aColsS[nI,PLRetPos("BL8_SEXO",aHeaderS)] == "2" // sexo feminino
			nPos := aScan(aGeral,{|x|x[2]==aColsS[nI,GDFieldPos("BL8_FAIXAE",aHeaderS)] .and. x[10]==cCodTip})
			If nPos # 0
				aGeral[nPos,5] := aGeral[nPos,5] + aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)]
				aGeral[Len(aGeral),5] +=aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)]
			EndIf
		EndIf
		// geral
		If aColsS[nI,GDFieldPos("BL8_SEXO",aHeaderS)] $ "12"   // sexo masculino ou feminino
			nPos := aScan(aGeral,{|x|x[2]==aColsS[nI,GDFieldPos("BL8_FAIXAE",aHeaderS)] .and. x[10]==cCodTip})
			If nPos # 0
				aGeral[nPos,7] := aGeral[nPos,7] + aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)]
				aGeral[Len(aGeral),7] +=aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)]
			EndIf
			nTotFun+=aColsS[nI,GDFieldPos("BL8_QUANTI",aHeaderS)]
		EndIf
	Endif
Next

If cFaiFam = "1"
	aFamiliar := ASort(aFamiliar,,, { |x,y| x[1] < y[1] })

	For nI := 1 To Len(aFamiliar)
		nPos := Ascan(aGeral, { |x| 	aFamiliar[nI][2] + aFamiliar[nI][3] >=;
										Val(Left(x[9], 3)) .And.;
										aFamiliar[nI][2] + aFamiliar[nI][3] <=;
										Val(Subs(x[9], 7, 3)) })
		If nPos > 0										
			aGeral[nPos,3] += aFamiliar[nI][2]
			aGeral[nPos,5] += aFamiliar[nI][3]

			aGeral[Len(aGeral),3] += aFamiliar[nI][2]
			aGeral[Len(aGeral),5] += aFamiliar[nI][3]
			aGeral[nPos,7] := aGeral[nPos,7] + aFamiliar[nI][2] + aFamiliar[nI][3]
			aGeral[Len(aGeral),7] += aFamiliar[nI][2] + aFamiliar[nI][3]
			nTotFun += aFamiliar[nI][2] + aFamiliar[nI][3]
		Endif
	Next
Endif
		

For nI := 1 to Len(aGeral) - 1
	// masculino
	If aGeral[nI,3] >= nMaior
		nPosM   := nI
		nMaior  := aGeral[nI,3]
		cMaior  := "M"  // o maior valor e' masculino
	EndIf
	nPer := (aGeral[nI,3]*100) / nTotFun
	aGeral[nI,4] := Round(nPer,0)
	aGeral[Len(aGeral),4] += nPer
	nSomaPerM += aGeral[nI,4]
	
	// feminino
	If aGeral[nI,6] >= nMaior
		nPosM   := nI
		nMaior  := aGeral[nI,6]
		cMaior  := "F"  // o maior valor e' feminino
	EndIf
	nPer := (aGeral[nI,5]*100) / nTotFun
	aGeral[nI,6] := Round(nPer,0)
	aGeral[Len(aGeral),6] += nPer
	nSomaPerF += aGeral[nI,6]
	
	// geral
	nPer := (aGeral[nI,7]*100) / nTotFun
	aGeral[nI,8] := Round(nPer,0)
Next

If (nSomaPerF+nSomaPerM) # 100.00 .and. nMaior > 0.00
	nDifPer := 100.00 - (nSomaPerM+nSomaPerF)
	If cMaior == "M"  // se o maior for masculino grava no aGeral masculino
		aGeral[nPosM,4]+=nDifPer
		aGeral[Len(aGeral),4] += nDifPer
	ElseIf cMaior == "F"  // se o maior for feminino grava no aGeral feminino
		aGeral[nPosM,6]+=nDifPer
		aGeral[Len(aGeral),6] += nDifPer
	EndIf
	aGeral[nPosM,8]+=nDifPer
EndIf
aGeral[Len(aGeral),8] := Round(aGeral[Len(aGeral),4], 0) + Round(aGeral[Len(aGeral),6], 0)

Return aGeral


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FaixaEta ³ Autor ³ Eduardo Motta         ³ Data ³ 14.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de digitacao da faixa etaria do concorrente         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FaixaEta()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FaixaEta()
Local oDlg
Local oGeral
Local aGeral
Local nOpca  := 0
Local nValor := 0.00
Local aCargo := aClone(oGet04:Cargo)
Local nI
Local nPos
Local cCodSeq
Local cCodTip
Local nPosC
Local cSequen := oGet04:aCols[oGet04:Linha(),oGet04:PlRetPos("BLB_SEQUEN")]
Local nVrContrato := 0.00
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}

aGeral := aClone(CarregaBL9())

nPosC := aScan(aCargo,{|x|x[1]==cSequen })

VlrConco(aGeral,cSequen,aCargo,oGet03:FieldGet("BL2_FAIFAM"))

aSize := MsAdvSize()
aSize[7] := Round(aSize[7] * 0.92, 0)
aSize[6] := Round(aSize[6] * 0.92, 0)
aSize[5] := Round(aSize[5] * 0.92, 0)
aSize[4] := Round(aSize[4] * 0.92, 0)
aSize[3] := Round(aSize[3] * 0.92, 0)
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T., .F. )	

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0022) FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel //"Resumo da Simulacao de Venda"
oDlg:lEscClose := .F.

@ aPosObj[1][1],aPosObj[1][2] LISTBOX oGeral FIELDS HEADER OemtoAnsi(STR0023),OemtoAnsi(STR0024),OemtoAnsi(STR0025),"  %",OemtoAnsi(STR0026),"  %",OemtoAnsi(STR0027),"  %",OemtoAnsi(STR0028) FIELDSIZES 070,45,35,25,30,25,30,25,40 SIZE aPosObj[1][4]-1,aPosObj[1][3]-16 OF oDlg PIXEL //"FAIXA ETARIA"###"TIPO"###"MASCULINO"###"FEMININO"###"GERAL"###"VALOR"
oGeral:SetArray(aGeral)
oGeral:bLine      := {|| {aGeral[oGeral:nAt,1],aGeral[oGeral:nAt,9],Str(aGeral[oGeral:nAt,3],3),Str(aGeral[oGeral:nAt,4],3),Str(aGeral[oGeral:nAt,5],3),Str(aGeral[oGeral:nAt,6],3),Str(aGeral[oGeral:nAt,7],3),Str(aGeral[oGeral:nAt,8],3),TransForm(aGeral[oGeral:nAt,11],"@E 999,999,999.99") }}
oGeral:bLDblClick := {||PlsEditCell(aGeral[oGeral:nAt,11],oGeral,"@E 999,999,999.99",9,{||.T.},aGeral,11,{||aGeral[oGeral:nAt,7]>0.00})}
oGeral:bChange    := {||.t.}

ACTIVATE MSDIALOG oDlg CENTERED  ON INIT(EnchoiceBar(oDlg, {|| nOpca:=1,oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))

If nOpca == 1
	nPos := nPosC
	If nPosC == 0
		aCargo := { { cSequen, {} } }
		nPos := 1
	Endif
	For nI := 1 to Len(aGeral) - 1
		If nI > Len(aCargo[nPos][2])
			aadd(aCargo[nPos][2],{aGeral[nI,2],aGeral[nI,10],aGeral[nI,11],.F.} )
		Else 
			aCargo[nPos][2][nI] := {aGeral[nI,2],aGeral[nI,10],aGeral[nI,11],aCargo[nPosC][2][nI][4]}
		Endif
		nVrContrato+=aGeral[nI,11]
	Next
	If nPosC == 0
		aadd(oGet04:Cargo,AClone(aCargo[nPos]))
	Else
		oGet04:Cargo := aClone(aCargo)
	EndIf
	oGet04:FieldPut("BLB_VRCONT",nVrcontrato)
	//   oGet04:Refresh()
EndIf

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PlsEditCell     ³ Autor ³ Eduardo Motta  ³ Data ³16.08.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de edicao de celula em listbox.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ uValor    - Valor da variavel                              ³±±
±±³          ³ oBrowse   - Objeto listbox                                 ³±±
±±³          ³ cPict     - Picture da edicao                              ³±±
±±³          ³ nCol      - Coluna da edicao                               ³±±
±±³          ³ bValid    - Code Block de validacao do campo               ³±±
±±³          ³ aArray    - Array listado no listbox                       ³±±
±±³          ³ nElem     - Elemento a ser editado no array                ³±±
±±³          ³ bWhen     - Code Block com a condicao WHEN                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsEditCell(uValor,oBrowse,cPict,nCol,bValid,aArray,nElem,bWhen)
Local oDlg
Local oRect
Local oGet1
Local oBtn
Local cMacro := ''
Local nRow   := oBrowse:nAt
Local oOwner := oBrowse:oWnd
Local cValid
Local lOk    := .F.

DEFAULT nElem := nCol
DEFAULT bWhen := {||.T.}

Private bChange
Private bValidCell

If ! Eval(bWhen)
	Return .F.
EndIf

bValidCell := If(bValid==NIL,{||.T.},bValid)
cValid := 'Eval(bValidCell)'

bChange := { ||  uValor := &cMacro,oBrowse:aArray[nRow,nCol] := &cMacro }
oRect := tRect():New(0,0,0,0)      // obtem as coordenadas da celula (lugar onde
oBrowse:GetCellRect(nCol,,oRect)   // a janela de edicao deve ficar)
aDim  := {oRect:nTop,oRect:nLeft,oRect:nBottom,oRect:nRight}

DEFINE MSDIALOG oDlg OF oOwner  FROM 0, 0 TO 0, 0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL

cMacro := "M->CELL"
&cMacro:= uValor
cPict  := cPict

@ 0,0 MSGET oGet1 VAR &(cMacro) SIZE 0,0 OF oDlg FONT oOwner:oFont PICTURE cPict PIXEL HASBUTTON VALID (&cValid .and. (lOk := .T.,.T.))
oGet1:Move(-2,-2, (aDim[ 4 ] - aDim[ 2 ]) + 4, aDim[ 3 ] - aDim[ 1 ] + 4 )

@ 0,0 BUTTON oBtn PROMPT "ze" SIZE 0,0 OF oDlg
oBtn:bGotFocus := {|| oDlg:nLastKey := VK_RETURN, oDlg:End(0)}

oGet1:cReadVar  := cMacro

ACTIVATE MSDIALOG oDlg ON INIT oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

If lOk
	aArray[nRow,nElem] := &cMacro
	oBrowse:nAt := nRow
	SetFocus(oBrowse:hWnd)
	oBrowse:Refresh()
EndIf

Return lOk



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlsVlrCont³ Autor ³ Wagner Mobile Costa   ³ Data ³ 09.09.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que efetua o calculo do valor da simulacao de venda ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PlsVlrCont()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PlsVlrCont(nVrContrato,nGR,aGeral)
Local nI :=0

nVrContrato := 0
For nI := 1 to Len(aGeral) - 1
	aGeral[nI,11] += (aGeral[nI,3] * aGeral[nI, Len(aGeral[nI]) - 1])
	aGeral[nI,11] += (aGeral[nI,5] * aGeral[nI, Len(aGeral[nI])])
	
	aGeral[Len(aGeral),11] += aGeral[nI,11]
	
	nVrContrato += aGeral[nI,11]
Next

If	SUS->(FieldPos("US_FORMULA")) > 0 .and. ;
    ! Empty(M->US_FORMULA)
	nGR := Formula(M->US_FORMULA)
	If ValType(nGr) <> "N"
		nGr := 0
	Endif
Else
	nGR := 0
Endif

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VldCodCon ³ Autor ³ Eduardo Motta         ³ Data ³ 14.08.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de validacao da condicao de pagamento.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ VldCodCon(cCodCon,cDesCon)                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldCodCon(cCodCon,cDesCon,lHelp)
Local lRet := .T.
DEFAULT lHelp := .T.
While .T.
	BJ1->(DbSetOrder(1))
	If ! BJ1->(MsSeek(xFilial()+cCodCon))
		If lHelp
			Help(" ",1,"REGNOIS")
		EndIf
		lRet := .F.
		Exit
	EndIf
	cDesCon := BJ1->BJ1_DESCRI
	Exit
EndDo
Return lRet



Static Function Compara(oComp1,oComp2,aComp1,aComp2,lGrafico,nCbx)
Local oDlg
Local oGeral
Local aGeral
Local nI
Local nPos
Local nPosC
Local nLinGet03   := aComp1[oComp1:nAt,2]
Local nLinGet04   := aComp2[oComp2:nAt,2]
Local cCodCon     := ""
Local nVrContrato := 0.00
Local nGR         := 0
Local aCargo2 	:= aClone(oGet04:Cargo)
Local cSequen 	:= oGet04:FieldGet("BLB_SEQUEN",nLinGet04)
Local cCodSeq 	:= ""
Local cCodTip 	:= ""
Local aCbx 		:= { OemtoAnsi(STR0032),OemtoAnsi(STR0033),OemtoAnsi(STR0034),OemtoAnsi(STR0035),OemtoAnsi(STR0036),OemtoAnsi(STR0037),; //"Linha"###"Area"###"Pontos"###"Barras"###"Piramide"###"Cilindro"
OemtoAnsi(STR0038),OemtoAnsi(STR0039),OemtoAnsi(STR0040),; //"Barras Horizontal"###"Piramide Horizontal"###"Cilindro Horizontal"
OemtoAnsi(STR0041),OemtoAnsi(STR0042),OemtoAnsi(STR0043),OemtoAnsi(STR0044),OemtoAnsi(STR0045),OemtoAnsi(STR0046) } //"Pizza"###"Forma"###"Linha rapida"###"Flexas"###"GANTT"###"Bolha"
Local cCbx
Local oGraphic, nSerie
Local aCompara 	:= { 	{OemtoAnsi(STR0018),OemtoAnsi(STR0047),OemtoAnsi(STR0048)},; //"Proposta"###"Concorrente 1"###"Concorrente 2"
{ 0, 0, 0 } }
LOCAL lNovaDlg := .T.
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}

Private oOk     := LoadBitmap(GetResources(), "ENABLE")
Private oNo     := LoadBitmap(GetResources(), "DISABLE")
Private oIgual  := LoadBitmap(GetResources(), "BR_AMARELO")

DEFAULT lGrafico := .F.
DEFAULT nCbx	 := 4

While lNovaDlg
lNovaDlg := .F.

cCbx := aCbx[nCbx]
aGeral := aClone(CarregaBL9(Nil,Nil,Nil,Nil,oGet03A:aHeader,oGet03A:aCols,oGet03:FieldGet("BL2_SEQUEN",nLinGet03)))

//carrega valores da proposta
cCodCon      := oGet03:FieldGet("BL2_CONPAG",nLinGet03)
nVrContrato  := oGet03:FieldGet("BL2_VLRCON",nLinGet03)
nGR          := oGet03:FieldGet("BL2_GRARIS",nLinGet03)
VldCodCon(cCodCon,"")
PlsVlrCont(@nVrContrato,@nGR,aGeral)

//carrega valores do concorrente

VlrConco(aGeral,cSequen,aCargo2,oGet03:FieldGet("BL2_FAIFAM",nLinGet03),12)

aSize := MsAdvSize()
aSize[7] := Round(aSize[7] * 0.92, 0)
aSize[6] := Round(aSize[6] * 0.92, 0)
aSize[5] := Round(aSize[5] * 0.92, 0)
aSize[4] := Round(aSize[4] * 0.92, 0)
aSize[3] := Round(aSize[3] * 0.92, 0)
aObjects := {}       
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T., .F. )	

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0049) FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel //"Comparacao de Propostas"
oDlg:lEscClose := .F.

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

If lGrafico
	@ 000, 000 BITMAP oBmp RESNAME "ProjetoAP" oF oDlg SIZE 50, 250 NOBORDER WHEN .F. PIXEL
	@ 015, 055 MSGRAPHIC oGraphic SIZE aPosObj[1][4]-64, aPosObj[1][3]-60 OF oDlg PIXEL
	
	oGraphic:SetMargins( 2, 8, 8, 8 )
	
	oGraphic:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	oGraphic:SetTitle( "", "", CLR_HRED , A_LEFTJUST , GRP_TITLE )
	oGraphic:SetTitle( OemtoAnsi(STR0050), "", CLR_GREEN, A_RIGHTJUS , GRP_FOOT  ) //"Comparacao de proposta com concorrencia"
	oGraphic:SetLegenProp( GRP_SCRTOP, CLR_YELLOW, GRPLASTVAL, .F.)
	
	nSerie   := oGraphic:CreateSerie(nCbx)
	oGraphic:Add(nSerie, nVrContrato,OemtoAnsi(STR0018), CLR_GREEN) //"Proposta"
	aCompara[2][1] := Trans(nVrContrato, "@E 999,999.99")
	
	
	oGraphic:Add(nSerie, oGet04:FieldGet("BLB_VRCONT",1),OemtoAnsi(STR0047), CLR_YELLOW) //"Concorrente 1"
	aCompara[2][2] := Trans(oGet04:FieldGet("BLB_VRCONT",1), "@E 999,999.99")
	
	If Len(oGet04:aCols) > 1
		oGraphic:Add(nSerie, oGet04:FieldGet("BLB_VRCONT",2),OemtoAnsi(STR0048), CLR_RED) //"Concorrente 2"
		aCompara[2][3] := Trans(oGet04:FieldGet("BLB_VRCONT",2), "@E 999,999.99")
	Else
		aCompara[2][3] := "0,00"
	Endif
	
	@ aPosObj[1][1]+aPosObj[1][3]-59, 075 	SAY OemtoAnsi(STR0051)	OF oDlg FONT oBold PIXEL //"Tipo de grafico"
	@ aPosObj[1][1]+aPosObj[1][3]-47, 075 	MSCOMBOBOX oSer VAR cCbx ITEMS aCbx SIZE 077, 120 OF oDlg;
				PIXEL ON CHANGE	(nCbx := oSer:nAt, oDlg:End(), lNovaDlg := .T.)
	@ aPosObj[1][1]+aPosObj[1][3]-49, 154 	BUTTON OemtoAnsi(STR0052) SIZE 40,14 OF oDlg PIXEL ACTION Ctb020Graph(oGraphic, OemtoAnsi(STR0053), nSerie) //"Rotacao &-"###"ROTACAO-"
	@ aPosObj[1][1]+aPosObj[1][3]-49, 196 	BUTTON OemtoAnsi(STR0054) SIZE 40,14 OF oDlg PIXEL ACTION Ctb020Graph(oGraphic, OemtoAnsi(STR0055), nSerie) //"Rotacao &+"###"ROTACAO+"
	@ aPosObj[1][1]+aPosObj[1][3]-49, 238 	BUTTON o3D PROMPT "2D" SIZE 40,14 OF oDlg PIXEL ACTION Ctb020Graph(oGraphic, "EFEITO", o3D)
	@ aPosObj[1][1]+aPosObj[1][3]-49, 281 	BUTTON OemtoAnsi(STR0056) SIZE 40,14 OF oDlg PIXEL ACTION GrafSavBmp( oGraphic ) //"&Salva BMP"
	
	@ aPosObj[1][1]+aPosObj[1][3]-32, 030 	TO aPosObj[1][1]+aPosObj[1][3]-31 ,400 LABEL '' OF oDlg  PIXEL
	@ aPosObj[1][1]+aPosObj[1][3]-26, 196 	BUTTON OemtoAnsi(STR0057) SIZE 40,12 OF oDlg PIXEL ACTION CtbGrafPrint(oGraphic,OemtoAnsi(STR0058),{OemtoAnsi(STR0058)},aCompara, .F.) //"Imprimir"###"Comparacao com a Concorrencia"###"Comparacao com a Concorrencia"
	@ aPosObj[1][1]+aPosObj[1][3]-26, 238 	BUTTON OemtoAnsi(STR0059) SIZE 40,12 OF oDlg PIXEL ACTION PmsGrafMail(oGraphic,OemtoAnsi(STR0058),{OemtoAnsi(STR0058)},aCompara) //"&E-mail"###"Comparacao com a Concorrencia"###"Comparacao com a Concorrencia"
	@ aPosObj[1][1]+aPosObj[1][3]-26, 281 	BUTTON OemtoAnsi(STR0064) SIZE 40,12 OF oDlg PIXEL ACTION oDlg:End() //"&Sair"
Else
	@ aPosObj[1][1],aPosObj[1][2] LISTBOX oGeral FIELDS HEADER "",OemtoAnsi(STR0023),OemtoAnsi(STR0024),OemtoAnsi(STR0025),"  %",OemtoAnsi(STR0026),"  %",OemtoAnsi(STR0027),"  %",OemtoAnsi(STR0028),OemtoAnsi(STR0021) FIELDSIZES 10,030,45,35,25,30,25,30,25,40,40,40 SIZE aPosObj[1][4]-1,aPosObj[1][3]-31 OF oDlg PIXEL //"FAIXA ETARIA"###"MASCULINO"###"FEMININO"###"GERAL"###"VALOR"###"CONCORRENTE" //"TIPO"
	oGeral:SetArray(aGeral)
	oGeral:bLine      := {|| { RetBitMap(aGeral,oGeral),aGeral[oGeral:nAt,1],aGeral[oGeral:nAt,9],Str(aGeral[oGeral:nAt,3],3),Str(aGeral[oGeral:nAt,4],3),Str(aGeral[oGeral:nAt,5],3),Str(aGeral[oGeral:nAt,6],3),Str(aGeral[oGeral:nAt,7],3),Str(aGeral[oGeral:nAt,8],3),TransForm(aGeral[oGeral:nAt,11],"@E 999,999,999.99"),TransForm(aGeral[oGeral:nAt,12],"@E 999,999,999.99") }}
	oGeral:bChange    := {||.t.}
	
	@ aPosObj[1][1]+aPosObj[1][3]-25,008 BITMAP oBmp RESNAME "ENABLE"  OF oDlg SIZE 25,25 NOBORDER WHEN .F. PIXEL
	@ aPosObj[1][1]+aPosObj[1][3]-25,018 	SAY oTpColuna1 Var OemtoAnsi(STR0060) OF oDlg; //"Proposta melhor"
	COLOR CLR_BLACK FONT oBold PIXEL
	@ aPosObj[1][1]+aPosObj[1][3]-25,((aPosObj[1][2]+aPosObj[1][4])/2)-35 BITMAP oBmp RESNAME "BR_AMARELO"  OF oDlg SIZE 25,25 NOBORDER WHEN .F. PIXEL
	@ aPosObj[1][1]+aPosObj[1][3]-25,((aPosObj[1][2]+aPosObj[1][4])/2)-25	SAY oTpColuna2 Var OemtoAnsi(STR0061) OF oDlg; //"Empate"
	COLOR CLR_BLACK FONT oBold PIXEL
	@ aPosObj[1][1]+aPosObj[1][3]-25,aPosObj[1][2]+aPosObj[1][4]-85 BITMAP oBmp RESNAME "DISABLE"  OF oDlg SIZE 25,25 NOBORDER WHEN .F. PIXEL
	@ aPosObj[1][1]+aPosObj[1][3]-25,aPosObj[1][2]+aPosObj[1][4]-75	SAY oTpColuna3 Var OemtoAnsi(STR0062) OF oDlg COLOR CLR_BLACK; //"Concorrente melhor"
	FONT oBold PIXEL
	
Endif

ACTIVATE MSDIALOG oDlg CENTERED  ON INIT(EnchoiceBar(oDlg, {|| nOpca:=1,oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))
enddo
Return


Static Function RetBitMap(aGeral,oGeral)
Local oObj
If aGeral[oGeral:nAt,11] < aGeral[oGeral:nAt,12]
	oObj := oOk
Else
	If aGeral[oGeral:nAt,11] == aGeral[oGeral:nAt,12]
		oObj :=  oIgual
	Else
		oObj := oNo
	EndIf
EndIf
Return oObj


Static Function CarrFxCon(cCod,cLoja,aVetBLC)
Local aCargo := {}
BLC->(DbSetOrder(1))
BLC->(MsSeek(xFilial()+cCod+cLoja))
While !BLC->(Eof()) .and. xFilial("BLC") == BLC->BLC_FILIAL .and. BLC->BLC_CODIGO == cCod .and. BLC->BLC_LOJA == cLoja
	nPosC := AScan(aCargo,{|x|x[1]==BLC->BLC_SEQUEN})
	If nPosC == 0
		aadd(aCargo,{BLC->BLC_SEQUEN,{{BLC->BLC_FAIXAE,BLC->BLC_TIPO,BLC->BLC_VALOR,.F.}}})
	Else
		aadd(aCargo[nPosC,2],{BLC->BLC_FAIXAE,BLC->BLC_TIPO,BLC->BLC_VALOR,.F.})
	EndIf
	If ValType(aVetBLC)=="A"
		aadd(aVetBLC,BLC->(Recno()))
	EndIf
	BLC->(DbSkip())
EndDo

Return aCargo


Static Function VlrConco(aGeral,cSequen,aCargo,cFaiFam,nPosConc)
Local nPosC
Local nI
Local cCodSeq
Local cCodTip
Local nPos
DEFAULT nPosConc := 11

nPosC := aScan(aCargo,{|x|x[1]==cSequen })

If nPosC # 0
	For nI := 1 to Len(aCargo[nPosC,2])
		If nI > Len(aGeral) - 1
			aCargo[nPosC][2,nI,4] := .T.	// Marco como deletado
			Loop
		Endif

		If cFaiFam = "1"		// Faixa Familiar
			aGeral[nI,nPosConc] := aCargo[nPosC][2,nI,3]
			aGeral[Len(aGeral),nPosConc] += aCargo[nPosC][2,nI,3]
		Else
			cCodSeq := aCargo[nPosC][2,nI,1]
			cCodTip := aCargo[nPosC][2,nI,2]
			nPos    := aScan(aGeral,{|x|x[2]==cCodSeq .and. x[10]==cCodTip})
			If nPos # 0
				aGeral[nPos,nPosConc] := aCargo[nPosC][2,nI,3]
				aGeral[Len(aGeral),nPosConc] += aCargo[nPosC][2,nI,3]
			EndIf
		Endif
		aCargo[nPosC][2,nI,4] := .F.
	Next
EndIf
Return

/*

aHeaderA := (STORE COLS DO ARQUIVO DE FUNCIONARIOS ANALITICO)
aHeaderS := (STORE COLS DO ARQUIVO DE FUNCIONARIOS SINTETICO)

nVrCotrato := 0
nGrauRisco := 0
aGeral := aClone(Plsa910BL9(aHeaderA,aColsA,aHeaderS,aColsS))
PlsVlrCont(@nVrContrato,@nGrauRisco,aGeral)

aDadosCon := Plsa910BLC(SUS->US_COD,SUS->US_LOJA)
CRIAR NO A GERAL A COLUNA 12
For nI := 1 to Len(aGeral)  // adiciona mais uma coluna para se colocar o valor da concorrencia
aadd(aGeral[nI],0.00)
Next

Plsa910Con(aGeral,cSequen,aDadosCon,12)

*/


// funcoes usadas no relatorio de simulacao de venda
Function Plsa910BL9(aHeaderA,aColsA,aHeaderS,aColsS,aHeaderP,aColsP,cSequen,cFaiFam)
Return CarregaBL9(aHeaderA,aColsA,aHeaderS,aColsS,aHeaderP,aColsP,cSequen,cFaiFam)

Function Plsa910BLC(cCod,cLoja,aVetBLC)
Return CarrFxCon(cCod,cLoja,aVetBLC)

Function Plsa910Con(aGeral,cSequen,aCargo,cFaiFam,nPosConc)
Return VlrConco(aGeral,cSequen,aCargo,cFaiFam,nPosConc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pl910CarEt³ Autor ³ Wagner Mobile Costa   ³ Data ³ 19.09.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para carga dos valores por faixa etaria             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Pl910CarEt(cCodCon,cDesCon)                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pl910CarEt(lCarFam,lGetDados)

Local aRegPrd, nRegPrd
Local nRetMas		:= nRetFem := nRetDois := 0, nIdade := 0
Local nBL3_SEQUEN   := oGet03A:PlRetPos("BL3_SEQUEN")
Local nBL3_SEQBL9   := oGet03A:PlRetPos("BL3_SEQBL9")
Local nBL3_CODTIP   := oGet03A:PlRetPos("BL3_CODTIP")
Local nBL3_DESCRI   := oGet03A:PlRetPos("BL3_DESCRI")
Local nBL3_IIDADE 	:= oGet03A:PlRetPos("BL3_IDADEI")
Local nBL3_FIDADE 	:= oGet03A:PlRetPos("BL3_IDADEF")
Local nBL3_VLRMAS 	:= oGet03A:PlRetPos("BL3_VLRMAS")
Local nBL3_VLRFEM 	:= oGet03A:PlRetPos("BL3_VLRFEM")
Local nBL3_QTDMIN 	:= oGet03A:PlRetPos("BL3_QTDMIN")
Local nBL3_QTDMAX 	:= oGet03A:PlRetPos("BL3_QTDMAX"), nLido := nCol := nDel := 0
Local nCols, aColsC	:= AClone(aCols)
Local nValDes := 0.00
Local nPerDes := 0.00
Local aRegPrd2 := {}
Local aDes := {}
Local nPosMas,nPosFem,nPosDois
Local nValMas,nValFem,nValDois
Local aGeral := {}
Local nQtdUsu
Local aArea := GetArea()

DEFAULT lCarFam := .F.
DEFAULT lGetDados := .T.

If 	Empty(M->BL2_CODINT) .Or. Empty(M->BL2_CODPRO) .Or.;
	Empty(M->BL2_VERSAO) .Or. Empty(M->BL2_CONPAG)
	Return .T.
Endif

aGeral := CarregaBL9()

If lGetDados
   If ! PlsVldGd({"BL2_CODINT", "BL2_CODPRO", "BL2_VERSAO", "BL2_CONPAG","BL2_FAIFAM"})
      Return .F.
   Endif
EndIf   

If lCarFam
	BJ1->(MsSeek(xFilial("BJ1") + M->BL2_CONPAG))
	If BJ1->BJ1_FAIFAM = "2"
		M->BL2_FAIFAM := "0"	// Nao
	Else
		M->BL2_FAIFAM := BJ1->BJ1_FAIFAM
	Endif
Endif

aRegPrd	:= 	PLSCOBPrd(M->BL2_CODINT, M->BL2_CODPRO, M->BL2_VERSAO, M->BL2_CONPAG,;
			M->BL2_FAIFAM)

// busca os descontos da faixa etaria
// temporariamente nao estou considerando a quantidade de usuarios da faixa

oGet03A:ForceRefresh(oGet03A)
oGet03A:lAltered := .T.

If Len(oGet03A:aCols) > 1
	For nCols := 1 To Len(oGet03A:aCols)
		If oGet03A:aCols[nCols][nBL3_SEQUEN] = M->BL2_SEQUEN	// Marco como
			oGet03A:aCols[nCols][Len(oGet03A:aCols[nCols])] := .T.			// deletado
		Endif
	Next
Endif

If Len(oGet03A:aCols) = 1
	nLido := 0
Else
	nLido := Len(oGet03A:aCols)
Endif

If M->BL2_FAIFAM = "1"		// Faixa Familiar
	aRegPrd := AClone(ASort(aRegPrd,,, { |x,y| x[7] < y[7] }))
	
	For nRegPrd := 1 To Len(aRegPrd)
		If (nDel := Ascan(oGet03A:aCols, {|x| 	x[nBL3_SEQUEN] = M->BL2_SEQUEN .And.;
				   								x[Len(x)] })) > 0
			nCol := nDel
			oGet03A:aCols[nCol][Len(oGet03A:aCols[nCol])] := .F.
		Else
			nLido ++
			nCol := nLido
		Endif
		
		If nCol > Len(oGet03A:aCols)
			Aadd(oGet03A:aCols, AClone(oGet03A:aCols[1]))
		Endif
			
		oGet03A:aCols[nCol][nBL3_SEQUEN] := M->BL2_SEQUEN
		oGet03A:aCols[nCol][nBL3_SEQBL9] := Space(Len(BL9->BL9_SEQUEN))
		oGet03A:aCols[nCol][nBL3_DESCRI] := StrZero(aRegPrd[nRegPrd][7], 3) + OemtoAnsi(STR0071) + StrZero(aRegPrd[nRegPrd][8], 3) + OemtoAnsi(STR0072) //" a "###" Usuarios"
		oGet03A:aCols[nCol][nBL3_VLRMAS] := aRegPrd[nRegPrd][5]
		oGet03A:aCols[nCol][nBL3_VLRFEM] := aRegPrd[nRegPrd][5]
		oGet03A:aCols[nCol][nBL3_IIDADE] := 0
		oGet03A:aCols[nCol][nBL3_FIDADE] := 0
		oGet03A:aCols[nCol][nBL3_QTDMIN] := aRegPrd[nRegPrd][7]
		oGet03A:aCols[nCol][nBL3_QTDMAX] := aRegPrd[nRegPrd][8]

		If Len(oGet03A:aVetNoFil) < Len(oGet03A:aCols)
			aadd(oGet03A:aVetNoFil,0)  // inclui 0 no vettrab indicando que e' um registro novo
		Endif
		If Len(oGet03A:aVetTrab) < Len(oGet03A:aCols)
			aadd(oGet03A:aVetTrab,0)  // inclui 0 no vettrab indicando que e' um registro novo
		Endif
	Next
Else
	BL9->(DbSetOrder(1))
	BL9->(MsSeek(xFilial()))
	While !BL9->(Eof()) .and. BL9->BL9_FILIAL == xFilial("BL9")
		BIH->(DbSetOrder(1))
		BIH->(MsSeek(xFilial()))
		While !BIH->(Eof())
			nPosMas := Ascan(aRegPrd, { |x|	(x[1] = BIH->BIH_CODTIP .Or. Empty(x[1])) .And.;
			x[2] = "1" .And.;
			(BL9->BL9_IDADEF >= x[3] .And. x[4] >= BL9->BL9_IDADEF) })
			
			nPosFem := Ascan(aRegPrd, { |x|	(x[1] = BIH->BIH_CODTIP .Or. Empty(x[1])) .And.;
			x[2] = "2" .And.;
			(BL9->BL9_IDADEF >= x[3] .And. x[4] >= BL9->BL9_IDADEF) })

			nPosDois := Ascan(aRegPrd, { |x|(x[1] = BIH->BIH_CODTIP .Or. Empty(x[1])) .And.;
			(Empty(x[2]) .Or. x[2] = "3") .And.;
			(BL9->BL9_IDADEF >= x[3] .And. x[4] >= BL9->BL9_IDADEF) })
			nValMas  := 0.00
			nValFem  := 0.00
			nValDois := 0.00
			If nPosMas > 0
				nValMas := aRegPrd[nPosMas][5]	// Valor da Faixa Masculino
			Endif
			If nPosFem > 0
				nValFem := aRegPrd[nPosFem][5]	// Valor da Faixa Feminina
			Endif
			If nPosDois > 0
				nValDois := aRegPrd[nPosDois][5]	// Valor da Faixa Feminina/Masculino
			Endif

			If (nDel := Ascan(oGet03A:aCols, {|x| 	x[nBL3_SEQUEN] = M->BL2_SEQUEN .And.;
					   								x[Len(x)] })) > 0
				nCol := nDel
				oGet03A:aCols[nCol][Len(oGet03A:aCols[nCol])] := .F.
			Else
				nLido ++
				nCol := nLido
			Endif
	
			If nCol > Len(oGet03A:aCols)
				Aadd(oGet03A:aCols, AClone(oGet03A:aCols[1]))
			Endif
			
			oGet03A:aCols[nCol][nBL3_SEQUEN] := M->BL2_SEQUEN
			oGet03A:aCols[nCol][nBL3_SEQBL9] := BL9->BL9_SEQUEN
			oGet03A:aCols[nCol][nBL3_CODTIP] := BIH->BIH_CODTIP
			oGet03A:aCols[nCol][nBL3_DESCRI] := BIH->BIH_DESCRI
			oGet03A:aCols[nCol][nBL3_IIDADE] := nIdade
			oGet03A:aCols[nCol][nBL3_FIDADE] := BL9->BL9_IDADEF
			oGet03A:aCols[nCol][nBL3_QTDMIN] := 0
			oGet03A:aCols[nCol][nBL3_QTDMAX] := 0
			oGet03A:aCols[nCol][nBL3_VLRMAS] := If(nPosMas > 0, nValMas, nValDois)
			oGet03A:aCols[nCol][nBL3_VLRFEM] := If(nPosFEM > 0, nValFEM, nValDois)
			oGet03A:FieldPut("BL3_MASORI",oGet03A:aCols[nCol][nBL3_VLRMAS],nCol)
			oGet03A:FieldPut("BL3_FEMORI",oGet03A:aCols[nCol][nBL3_VLRFEM],nCol)
			oGet03A:aCols[nCol][nBL3_VLRFEM] := If(nPosFEM > 0, nValFEM, nValDois)
            
            nPosaGer := aScan(aGeral,{|x|x[2]==BL9->BL9_SEQUEN .and. x[10]==BIH->BIH_CODTIP})
            If nPosaGer # 0
               nQtdUsu := aGeral[nPosaGer,3]+aGeral[nPosaGer,5]
            Else
               nQtdUsu := 0
            EndIf   
            If nPosMas > 0 .or. nPosDois > 0
               aDes    := RetDesconto(M->BL2_CODINT, M->BL2_CODPRO, M->BL2_VERSAO, M->BL2_CONPAG,aRegPrd[If(nPosMas>0,nPosMas,nPosDois)],nQtdUsu)
               nPerDes := aDes[1]
               nValDes := aDes[2]
   			   If nPerDes # 0.00
 	              oGet03A:aCols[nCol][nBL3_VLRMAS] := oGet03A:aCols[nCol][nBL3_VLRMAS] * (1-(nPerDes/100))
			   ElseIf nValDes # 0.00
	              oGet03A:aCols[nCol][nBL3_VLRMAS] := oGet03A:aCols[nCol][nBL3_VLRMAS] - nValDes
			   EndIf
               oGet03A:aCols[nCol][nBL3_VLRMAS] := oGet03A:aCols[nCol][nBL3_VLRMAS] * (1-(M->BL2_DESCON/100))
  		  	   oGet03A:FieldPut("BL3_MASDES",oGet03A:FieldGet("BL3_MASORI",nCol)-oGet03A:FieldGet("BL3_VLRMAS",nCol),nCol)
			EndIf   

            If nPosFem > 0 .or. nPosDois > 0
               aDes    := RetDesconto(M->BL2_CODINT, M->BL2_CODPRO, M->BL2_VERSAO, M->BL2_CONPAG,aRegPrd[If(nPosFem>0,nPosFem,nPosDois)],nQtdUsu)
               nPerDes := aDes[1]
               nValDes := aDes[2]
		       If nPerDes # 0.00
 	              oGet03A:aCols[nCol][nBL3_VLRFEM] := oGet03A:aCols[nCol][nBL3_VLRFEM] * (1-(nPerDes/100))
			   ElseIf nValDes # 0.00
	              oGet03A:aCols[nCol][nBL3_VLRFEM] := oGet03A:aCols[nCol][nBL3_VLRFEM] - nValDes
			   EndIf
               oGet03A:aCols[nCol][nBL3_VLRFEM] := oGet03A:aCols[nCol][nBL3_VLRFEM] * (1-(M->BL2_DESCON/100))
  		  	   oGet03A:FieldPut("BL3_FEMDES",oGet03A:FieldGet("BL3_FEMORI",nCol)-oGet03A:FieldGet("BL3_VLRFEM",nCol),nCol)
			EndIf   
			   
			If Len(oGet03A:aVetNoFil) < Len(oGet03A:aCols)
				aadd(oGet03A:aVetNoFil,0)  // inclui 0 no vettrab indicando que e' um registro novo
			Endif
			If Len(oGet03A:aVetTrab) < Len(oGet03A:aCols)
				aadd(oGet03A:aVetTrab,0)  // inclui 0 no vettrab indicando que e' um registro novo
			Endif
			
			BIH->(DbSkip())
		EndDo
		nIdade := BL9->BL9_IDADEF + 1
		BL9->(DbSkip())
	EndDo
Endif

oGet03A:ForceRefresh(oGet03A)
aCols := AClone(AColsC)
RestArea(aArea)

Return .T.



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetDesconto |Autor³ Eduardo Motta         ³ Data ³ 11.05.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna desconto da faixa etaria                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RetDesconto(cCodPro,cVerPro,cCodFor,aReg)                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
OBS: a Estrutura do aRet e' a mesma da retornada pela funcao PlsCobPrd
aReg[1] - TIPO USUARIO
aReg[2] - Sexo
aReg[3] - Idade Inicial
aReg[4] - Idade Final
aReg[5] - Valor da Faixa
aReg[6] - Cobranca Familiar = 1-Sim 0-Nao
aReg[7] - Quantidade Minima
aReg[8] - Quantidade Maxima
aReg[9] - Codigo da faixa para relacionar BB3 com BFS

Retorno: aRet[1] - Percentual de desconto
         aRet[2] - Valor de desconto
/*/
Static Function RetDesconto(cCodInt,cCodPro,cVerPro,cCodFor,aReg,nQtdUsu)
Local aRet := {0.00,0.00}

BFS->(DbSetOrder(1))
BFS->(MsSeek(xFilial()+cCodInt+cCodPro+cVerPro+cCodFor+aReg[9]+aReg[1]))
While ! BFS->(Eof()) .and. xFilial("BFS")+cCodInt+cCodPro+cVerPro+cCodFor+aReg[9]+aReg[1] == BFS->(BFS_FILIAL+BFS_CODIGO+BFS_VERSAO+BFS_CODFOR+BFS_CODFAI+BFS_TIPUSR)
   If nQtdUsu >= BFS->BFS_QTDDE .and. nQtdUsu <= BFS->BFS_QTDATE .and. dDatabase >= BFS->BFS_DATDE .and. (dDataBase <= BFS->BFS_DATATE .or. Empty(BFS->BFS_DATATE))
      aRet[1] := BFS->BFS_PERCEN
      aRet[2] := BFS->BFS_VALOR
      If BFS->BFS_TIPO=="2"
         aRet[1] := aRet[1] * -1
         aRet[2] := aRet[2] * -1
      EndIf
   EndIf   
   BFS->(DbSkip())
EndDo

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pl910BlDs ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 23.09.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna descricao do campo da tabela de preco              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Pl910BlDs()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pl910BlDs()

Local cDescri := ""

If BL3->BL3_QTDMIN > 0
	cDescri := StrZero(BL3->BL3_QTDMIN, 3) + OemtoAnsi(STR0071) + StrZero(BL3->BL3_QTDMAX, 3) + OemtoAnsi(STR0072) //" a "###" Usuarios"
Else
	cDescri := Posicione("BIH", 1, xFilial("BLH") + BL3->BL3_CODTIP, "BIH_DESCRI")
Endif

Return cDescri



/*
NOVO CALCULO
   nCol := Len(oGet03a:aCols)+1
   For nI := 1 to Len(aRegPrd)
      BIH->(DbSetOrder(1))
	  BIH->(MsSeek(xFilial()))
	  While !BIH->(Eof()) .and. BIH->BIH_FILIAL==xFilial("BIH")
         Aadd(oGet03A:aCols, AClone(oGet03A:aCols[1]))
			
     	 oGet03A:aCols[nCol][nBL3_SEQUEN] := M->BL2_SEQUEN
         oGet03A:aCols[nCol][nBL3_SEQBL9] := StrZero(nI,3)
 	     oGet03A:aCols[nCol][nBL3_CODTIP] := aRegPrd[nI,1]
 	     oGet03A:aCols[nCol][nBL3_DESCRI] := BIH->BIH_DESCRI
	     oGet03A:aCols[nCol][nBL3_IIDADE] := aRegPrd[nI,3]
	     oGet03A:aCols[nCol][nBL3_FIDADE] := aRegPrd[nI,4]
	     oGet03A:aCols[nCol][nBL3_QTDMIN] := 0
	     oGet03A:aCols[nCol][nBL3_QTDMAX] := 0
	     oGet03A:aCols[nCol][nBL3_VLRMAS] := aRegPrd[nI,5]
	     oGet03A:aCols[nCol][nBL3_VLRFEM] := aRegPrd[nI,5]
	     oGet03A:aCols[nCol][Len(oGet03A:aHeader)+1] := .F.

	     If Len(oGet03A:aVetNoFil) < Len(oGet03A:aCols)
	        aadd(oGet03A:aVetNoFil,0)  // inclui 0 no vettrab indicando que e' um registro novo
  	     Endif
	     If Len(oGet03A:aVetTrab) < Len(oGet03A:aCols)
	 	    aadd(oGet03A:aVetTrab,0)  // inclui 0 no vettrab indicando que e' um registro novo
	     Endif
	     nCol++
	     BIH->(DbSkip())
	  EndDo   
   Next
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³08/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Private aRotina := { 	{ OemtoAnsi(STR0001)	,'AxPesqui' , 0, K_Pesquisar , 0, .F.},; //"Pesquisar"
						{ OemtoAnsi(STR0002)	,'pl910Mov' , 0, K_Visualizar, 0, Nil},; //"Visualizar"
						{ OemtoAnsi(STR0003)	,'pl910Mov' , 0, K_Incluir   , 0, Nil},; //"Incluir"
						{ OemtoAnsi(STR0004)	,'pl910Mov' , 0, K_Alterar   , 0, Nil},; //"Alterar"
						{ OemtoAnsi(STR0065)	,'pl910Lib' , 0, K_Alterar   , 0, Nil},; //"Liberacao"
						{ OemtoAnsi(STR0005)	,'pl910Mov' , 0, K_Excluir   , 0, Nil} } //"Excluir"
Return(aRotina)