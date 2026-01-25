#INCLUDE "FDME001.ch"
#include "eADVPL.ch"    
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ InitMercha()        ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo de Merchandising   	 			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function InitMercha(cCodCli, cLojaCli, cCodCon)
Local oDlg, oFldCamp, oFldScr //oFldDet
Local oBrwCamp, oBrwScr, oBtnAvan, oBtnCanc //oBrwDet
Local aCamp := {}, aDet := {}, aScr := {}
Local oCol
/******************************************/
/* Excluir isso, pois nao tenho o projeto */
/* Completo por isso preciso executar isso*/
/* O fonte esta no fim desse arquivo      */
/******************************************/
//alert("Chamei TEMPRESPOST")
//TempRespost()
/******************************************/

                                       
if Empty(cCodCli)
//	InitCliente(@cCodCli,@cLojaCli)
Endif
if Empty(cCodCon)
//	InitContat(cCodCli,cLojaCli,cCodCon)
Endif         

dbSelectArea("HA1")
dbSetorder(1)
dbSeek(RetFilial("HA1")+cCodCli+cLojaCli)

dbSelectArea("HU5")
dbSetorder(1)
dbSeek(RetFilial("HU5")+cCodCli+cLojaCli+cCodCon)

MECrgCamp(aCamp,)

DEFINE DIALOG oDlg TITLE STR0001 //"Merchandising"

@ 15,01 SAY HA1->HA1_COD + "/" + HA1->HA1_LOJA + " | " + AllTrim(HA1->HA1_NOME) OF oDlg
@ 27,01 SAY HU5->HU5_CODCON + " | " + AllTrim(HU5->HU5_CONTAT) OF oDlg

ADD FOLDER oFldCamp CAPTION STR0002  OF oDlg //"Campanhas"
@ 42,02 SAY STR0003 OF oFldCamp //"Escolha a Campanha:"
@ 54,02 BROWSE oBrwCamp SIZE 156,60 ON CLICK MEClickCamp(aCamp,oBrwCamp,aScr,oBrwScr) OF oFldCamp
SET BROWSE oBrwCamp ARRAY aCamp
ADD COLUMN oCol TO oBrwCamp ARRAY ELEMENT 1 HEADER STR0004 WIDTH 40 //"Cód."
ADD COLUMN oCol TO oBrwCamp ARRAY ELEMENT 2 HEADER STR0005 WIDTH 150 //"Descr."

ADD FOLDER oFldScr CAPTION STR0006  OF oDlg //"Pesquisa"
@ 42,02 SAY STR0007 OF oFldScr //"Escolha a Pesquisa:"
@ 54,02 BROWSE oBrwScr SIZE 156,60 OF oFldScr
SET BROWSE oBrwScr ARRAY aScr
ADD COLUMN oCol TO oBrwScr ARRAY ELEMENT 1 HEADER STR0004 WIDTH 40 //"Cód."
ADD COLUMN oCol TO oBrwScr ARRAY ELEMENT 2 HEADER STR0005 WIDTH 150 //"Descr."

/*
ADD FOLDER oFldDet CAPTION "Detalhe"  OF oDlg
@ 42,02 BROWSE oBrwDet SIZE 156,72 OF oFldDet
SET BROWSE oBrwDet ARRAY aDet
ADD COLUMN oCol TO oBrwDet ARRAY ELEMENT 1 HEADER "" WIDTH 40
ADD COLUMN oCol TO oBrwDet ARRAY ELEMENT 2 HEADER "" WIDTH 150
*/

@130,40 BUTTON oBtnCanc CAPTION  BTN_BITMAP_CANCEL SYMBOL ACTION CloseDialog() SIZE 50,12 of oDlg
@130,100 BUTTON oBtnAvan CAPTION STR0008 ACTION InitPergunta(aScr,oBrwScr) SIZE 50,12 of oDlg //"Iniciar >"

MEClickCamp(aCamp,oBrwCamp,aScr,oBrwScr)

ACTIVATE DIALOG oDlg

Return Nil      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MEUnicEsc ºAutor  ³ Marcos Daniel      º Data ³  29/01/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ MODELO DE TELA DE UNICA ESCOLHA                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PalmTop                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MEUnicEsc(cCodScr,aPergC,nPergC,tIni,lScript, cTitle)
Local oDlg, oBtnCa, oBtnGr, oBtnAv, oBtnAn, oGetPerg, oBrw
Local aRespI 	:= {}
Local lTipo		:= .T.
Local cRespI	:=""
Local nResp		:= 1
LOCAL nCol := 0, nX := 1
Local oCol

dbSelectArea("HUP")
dbSetOrder(2)
dbSeek(RetFilial("HUP")+cCodScr+aPergC[nPergC,1])

While !EOF() .And. HUP->HUP_FILIAL == RetFilial("HUP") .And. Alltrim(HUP->HUP_CODSCRI) == Alltrim(cCodScr) .And. Alltrim(HUP->HUP_IDTREE) == Alltrim(aPergC[nPergC,1])
	Aadd(aRespI, {HUP->HUP_CODPERG, HUP->HUP_DESC, HUP->HUP_SCORE})
	dbSkip()
Enddo
Aadd(aRespI, {"","",0})

DEFINE DIALOG oDlg TITLE cTitle

@ 015, 005 GET oGetPerg VAR aPergC[nPergC,2] MULTILINE READONLY SIZE 155, 030 OF oDlg

@ 040, 005 BROWSE oBrw SIZE 148, 090 OF oDlg

SET BROWSE oBrw ARRAY aRespI

ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0009	WIDTH 150 //"Respostas"


dbSelectArea("HRE")
dbSetOrder(1)

HRE->(dbSeek(RetFilial("HRE")+aPergC[nPergC,1]))
If HRE->(!EOF())
	For nX:=1 to Len(aRespI)
		If HRE->HRE_CODRESP == aRespI[nX,1]
			GridSetRow(oBrw, nX)
		ElseIF Empty(HRE->HRE_CODRESP)
			GridSetRow(oBrw, Len(aRespI))
		Endif
	Next
Endif

nCol := Len(Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))))
@135,144 -(nCol*3.33) SAY Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))) BOLD OF oDlg

@ 145, 005	BUTTON oBtnCa	CAPTION BTN_BITMAP_CANCEL SYMBOL ACTION MECancResp(@lScript)	OF oDlg 
@ 145, 060	BUTTON oBtnGr	CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION CloseDialog()	OF oDlg 

If nPergC != 1
//   nPergC += 1
   @ 145, 120 BUTTON oBtnAn CAPTION Chr(3) SYMBOL 	ACTION MEAntPerg(cCodScr,aPergC,@nPergC,tIni,aRespI,cRespI,oBrw,lScript) OF oDlg
EndIf

If Len(aPergC) != nPergC
   @ 145, 140 BUTTON oBtnAv CAPTION Chr(4) SYMBOL 	ACTION MEProxPerg(cCodScr,aPergC,@nPergC,tIni,aRespI,cRespI,oBrw,lScript)	OF oDlg
EndIf


ACTIVATE DIALOG oDlg

Return Nil
           


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MEMULTESC ºAutor  ³MONAEL P. RIBEIRO   º Data ³  01/29/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Desenha a tela do tipo Multiescolha para exibir a pergunta º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³  void MEDMULTESC(cCodSrc, aPergC, nPergC, cTime, cTitle)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MERCHANDISING - DJARUM                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MEMultEsc(cCodScr, aPergC, nPergC, tIni,lScript, cTitle)

LOCAL oDlg
LOCAL oBtnCa
LOCAL oBtnGr
LOCAL oBtnAv
LOCAL oBtnAn

LOCAL oBrw
LOCAL oGetP
LOCAL oCol
LOCAL aPergI := {}
LOCAL aRespI := {}
LOCAL nCol := 0
LOCAL aMark := {}
Local cRespI	:=""
Local j := 1, k := 1

dbSelectArea("HUP")            
dbSetOrder(2)

dbSeek(RetFilial("HUP")+cCodScr + aPergC[nPergC,1])

While !EOF() .And. HUP->HUP_FILIAL == RetFilial("HUP") .AND. cCodScr == HUP->HUP_CODSCRI .AND. Alltrim(HUP->HUP_IDTREE) == Alltrim(aPergC[nPergC,1])
		// adicione-o no array
      Aadd(aRespI, {HUP->HUP_CODPERG, AllTrim(HUP->HUP_DESC), HUP->HUP_SCORE, .F.}) 
      dbSkip() 
EndDo

dbSelectArea("HRE")
dbSetOrder(1)

if dbSeek(RetFilial("HRE")+aPergC[nPergC,1])
   While !EOF() .And. HRE->HRE_FILIAL == RetFilial("HRE") .AND. HRE->HRE_CODPERG == aPergC[nPergC,1]
         Aadd(aMark, {aPergC[nPergC,1], HRE->HRE_CODRESP})
         dbSkip()
   EndDo
   
   For j:=1 To Len(aMark)
       For k:=1 To Len(aRespI)
           // HUP->HUP_CODPERG == HRE->HRE_CODRESP and HUP->HUP_IDTREE == HUP->HUP_CODPERG da Pergunta
           if aRespI[k,1] == aMark[j,2] .AND. aPergC[nPergC,1] == aMark[j,1]
              // esta marcado
              aRespI[k,4] := .T.
           EndIf
       Next
   Next
   
Endif

DEFINE DIALOG oDlg TITLE cTitle 

@015,005 GET oGetP VAR aPergC[nPergC,2] MULTILINE READONLY SIZE 155, 030 OF oDlg 
@040,005 BROWSE oBrw SIZE 155,090 OF oDlg
SET BROWSE oBrw ARRAY aRespI
//campo logico do Array
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4 HEADER "" WIDTH 10 MARK      
//campo descricao da resposta do array   
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0010 WIDTH 50    //"Resposta"

nCol := Len(Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))))
@135,144 -(nCol*3.33) SAY Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))) BOLD OF oDlg

@145,05 BUTTON oBtnCa CAPTION  BTN_BITMAP_CANCEL SYMBOL  ACTION MECancResp(@lScript) OF oDlg 
@145,60 BUTTON oBtnGr CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION MEGrvResp(cCodScr,aPergC,tIni,@lScript) OF oDlg 

If nPergC != 1
//   nPergC+=1 
   @145,120 BUTTON oBtnAn CAPTION Chr(3) SYMBOL ACTION MEAntPerg(cCodScr, aPergC, @nPergC, tIni, aRespI,cRespI,oBrw,lScript) OF oDlg
EndIf

If Len(aPergC) != nPergC
   @145,140 BUTTON oBtnAv CAPTION Chr(4) SYMBOL ACTION MEProxPerg(cCodScr, aPergC, @nPergC, tIni, aRespI,cRespI,oBrw,lScript) OF oDlg
EndIf

ACTIVATE DIALOG oDlg

Return NIL                    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MEDISSERT ºAutor  ³MONAEL P. RIBEIRO   º Data ³  01/29/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Desenha a tela do tipo dissertativa para exibir a pergunta º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³  void MEDISSERT(cCodScr, aPergC, nPergC, tIni, cTitle)     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MERCHANDISING - DJARUM                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MEDISSERT(cCodScr, aPergC, nPergC, tIni,lScript, cTitle)

LOCAL oDlg
LOCAL oGetP
LOCAL oGetR
LOCAL oBtnCa
LOCAL oBtnGr
LOCAL oBtnAv
LOCAL oBtnAn
Local cRespI := space(Len(HUK->HUK_RESMEMO))
Local aRespI
Local oBrw
Local nCol := 0

//Aadd(aRespI, space(Len(HUK->HUK_RESMEMO)))
//Aadd(aRespI, "")

dbSelectArea("HRE")
dbSetOrder(1)
if dbSeek(RetFilial("HRE")+aPergC[nPergC,1])
   cRespI := AllTrim(HRE->HRE_RESMEMO)
EndIf

DEFINE DIALOG oDlg TITLE cTitle

@15,05 GET oGetP VAR aPergC[nPergC,2] READONLY MULTILINE SIZE 155, 030 OF oDlg
@40,05 GET oGetR VAR cRespI MULTILINE VSCROLL SIZE 155,090 OF oDlg

nCol := Len(Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))))
@135,144 -(nCol*3.33) SAY Alltrim(Str(nPergC)) + "/" + Alltrim(Str(Len(aPergC))) BOLD OF oDlg

@145,005 BUTTON oBtnCa CAPTION  BTN_BITMAP_CANCEL SYMBOL  ACTION MECancResp(@lScript) OF oDlg 
@145,060 BUTTON oBtnGr CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION MEGrvResp(cCodScr,aPergC,tIni,@lScript) OF oDlg 

If nPergC != 1
  @145,120 BUTTON oBtnAn CAPTION Chr(3) SYMBOL	ACTION MEAntPerg(cCodScr, aPergC, @nPergC, tIni, aRespI, cRespI,oBrw,lScript) OF oDlg
EndIf

If Len(aPergC) != nPergC
   @145,140 BUTTON oBtnAv CAPTION Chr(4) SYMBOL	ACTION MEProxPerg(cCodScr, aPergC, @nPergC, tIni, aRespI, cRespI,oBrw,lScript) OF oDlg
EndIf


ACTIVATE DIALOG oDlg

Return NIL
