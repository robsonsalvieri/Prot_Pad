#INCLUDE "SFPR001.ch"
#include "eADVPL.ch"
Function GetProduto(cProduto)
Local lRet := .f., oDlg, oGrupo, aGrupo := {}, nGrupo := 1
Local oProd, cDesc := "", cCod := ""
Local cDescD := ""
Local cUN := "", nQTD := 0, nEnt := 0
Local nICM := 0, nIPI := 0, nEst := 0, nPrc:=0.00 , oBrw, oBox
Local cPesq := Space(40)
Local oCtrl, aControls := { {},{},{} }
Local oCod, oDesc, lCodigo := .t., lDesc := .f.
Local aPrecos := {}
Local oCol

MsgStatus(STR0001) //"Aguarde..."
HBM->(dbGoTop())
While !HBM->(EoF())
   AADD(aGrupo,HBM->BM_GRUPO + " - " + AllTrim(HBM->BM_DESC))
   HBM->(dbSkip())
end                     

HB1->(dbSetOrder(3))

ClearStatus()
DEFINE DIALOG oDlg TITLE STR0002  //"Produto"

@ 20,2 SAY STR0003 OF oDlg //"Grupo:"
@ 18,32 COMBOBOX oGrupo VAR nGrupo ITEM aGrupo ACTION PRBrowse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,0,3) SIZE 125,50 OF oDlg
@ 33,2 SAY STR0004 OF oDlg //"Produto:"
@ 33,40 BUTTON oCtrl CAPTION Chr(6) ACTION PRBrowse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,0,3) SYMBOL OF oDlg
@ 33,56 GET oProd VAR cDesc READONLY NO UNDERLINE SIZE 105,15 OF oDlg
@ 50,2 TO 140,158 oBox CAPTION STR0005 OF oDlg //"Detalhes"
@ 55,5 SAY oCtrl PROMPT STR0006 OF oDlg //"Código:"
AADD(aControls[1],oCtrl)
@ 55,35 GET oCtrl VAR cCod READONLY NO UNDERLINE SIZE 85,15 OF oDlg
AADD(aControls[1],oCtrl)
@ 53,122 BUTTON oCtrl CAPTION STR0007 ACTION PRChange(aControls,2,oBox) SIZE 30,12 OF oDlg //"Preços"
AADD(aControls[1],oCtrl)
@ 70,5 GET oCtrl VAR cDescD MULTILINE READONLY NO UNDERLINE SIZE 145,25 OF oDlg
AADD(aControls[1],oCtrl)
@ 95,5 SAY oCtrl PROMPT STR0008 OF oDlg  //"Unidade:"
AADD(aControls[1],oCtrl)
@ 95,45 SAY oCtrl PROMPT cUN OF oDlg
AADD(aControls[1],oCtrl)
@ 95,75 SAY oCtrl PROMPT STR0009 OF oDlg //"Qt.Embal:"
AADD(aControls[1],oCtrl)
@ 95,120 SAY oCtrl PROMPT nQTD OF oDlg
AADD(aControls[1],oCtrl)
@ 105,5 SAY oCtrl PROMPT STR0010 OF oDlg //"Entrega:"
AADD(aControls[1],oCtrl)
@ 105,45 SAY oCtrl PROMPT nEnt OF oDlg
AADD(aControls[1],oCtrl)
@ 115,5 SAY oCtrl PROMPT STR0011 OF oDlg  //"ICMS:"
AADD(aControls[1],oCtrl)
@ 115,45 SAY oCtrl PROMPT nICM OF oDlg
AADD(aControls[1],oCtrl)
@ 115,75 SAY oCtrl PROMPT STR0012 OF oDlg //"IPI:"
AADD(aControls[1],oCtrl)
@ 115,120 SAY oCtrl PROMPT nIPI  OF oDlg
AADD(aControls[1],oCtrl)
@ 125,5 SAY oCtrl PROMPT STR0013 OF oDlg //"Estoque:"
AADD(aControls[1],oCtrl)
@ 125,45 SAY oCtrl PROMPT nEst OF oDlg
AADD(aControls[1],oCtrl)

@ 70,5 BROWSE oBrw SIZE 145,65 OF oDlg
SET BROWSE oBrw ARRAY aPrecos
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0014 WIDTH 50 //"Tabela"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0015 WIDTH 50 PICTURE "@E 999,999.99" ALIGN RIGHT //"Valor"
AADD(aControls[2],oBrw)
@ 55,110 BUTTON oCtrl CAPTION STR0005 ACTION PRChange(aControls,1,oBox) OF oDlg //"Detalhes"
AADD(aControls[2],oCtrl)
@ 55,05 SAY oCtrl PROMPT STR0016 OF oDlg //"Preço1: "
AADD(aControls[2],oCtrl)
@ 55,05 SAY oCtrl PROMPT nPrc  OF oDlg
AADD(aControls[2],oCtrl)

PRShowHide(aControls,2,.f.)

@ 70,5 GET oCtrl VAR cPesq SIZE 150,15 OF oDlg
AADD(aControls[3],oCtrl)
@ 85,5 CHECKBOX oCod VAR lCodigo CAPTION STR0017 ACTION PROrder(oCod, oDesc, lCodigo, .t.) OF oDlg //"Por Código"
AADD(aControls[3],oCod)
@ 97,5 CHECKBOX oDesc VAR lDesc CAPTION STR0018 ACTION PROrder(oCod, oDesc, lDesc ,.f.) OF oDlg //"Por Descrição"
AADD(aControls[3],oDesc)
@ 115,5 BUTTON oCtrl CAPTION STR0019 ACTION PRFind(cPesq,lCodigo,aGrupo,@nGrupo,@cProduto,aControls,oProd,aPrecos,oBox) OF oDlg //"Buscar"
AADD(aControls[3],oCtrl)
@ 115,50 BUTTON oCtrl CAPTION STR0020 ACTION PRChange(aControls,1,oBox) OF oDlg //"Retornar"
AADD(aControls[3],oCtrl)

PRShowHide(aControls,3,.f.)

@ 144,2   BUTTON oCtrl CAPTION STR0021 ACTION PREnd(@lRet,cProduto) SIZE 50,15 OF oDlg //"Ok"
AADD(aControls[1],oCtrl)
AADD(aControls[2],oCtrl)
@ 144,55  BUTTON oCtrl CAPTION STR0022 ACTION CloseDialog() SIZE 50,15 OF oDlg //"Cancelar"
@ 144,108 BUTTON oCtrl CAPTION STR0023 ACTION PRChange(aControls,3,oBox) SIZE 50,15 OF oDlg //"Pesquisar"
AADD(aControls[1],oCtrl)
AADD(aControls[2],oCtrl)


ACTIVATE DIALOG oDlg

Return lRet


Function PRShowHide(aControls, nOpt,lShow )
Local i

For i := 1 to Len(aControls[nOpt])
   if lShow
      ShowControl(aControls[nOpt,i])
   else
      HideControl(aControls[nOpt,i])
   endif
Next
Return nil

Function PRChange(aControls,nOpt,oBox)

if nOpt == 1
  PRShowHide(aControls,2,.f. )
  PRShowHide(aControls,3,.f. )
  PRShowHide(aControls,1,.t. )
  SetText(oBox,STR0005) //"Detalhes"
elseif nOpt == 2
  PRShowHide(aControls,1,.f. )
  PRShowHide(aControls,3,.f. )
  PRShowHide(aControls,2,.t. )
  SetText(oBox,STR0007) //"Preços"
else
  PRShowHide(aControls,1,.f. )
  PRShowHide(aControls,2,.f. )
  PRShowHide(aControls,3,.t. )
  SetText(oBox,STR0023) //"Pesquisar"
endif

Return nil

Function PROrder(oCod, oDesc, lVar,isCod)

if isCod
  SetText(oDesc,!lVar)
else
  SetText(oCod,!lVar)
endif

Return nil

Function PRBrowse(aGrupo,nGrupo,cProduto,aControls,oProd,aPrecos,oBox,nSetTop,nOrder)
Local oDlg, oLbx, aProduto := {} , nProduto := 1, oBtn, oUp, oDown
Local nTop := nSetTop, cGrupo := ""

if nOrder==3
	cGrupo := Substr(aGrupo[nGrupo],1,4)
Endif
MsgStatus(STR0001) //"Aguarde..."

DEFINE DIALOG oDlg TITLE STR0002  //"Produto"

@ 20,1 LISTBOX oLbx VAR nProduto ITEM aProduto SIZE 144,125 OF oDlg
@ 144,15 BUTTON oBtn CAPTION STR0021 SIZE 60,15 ACTION PRSet(aControls,@cProduto,aProduto[nProduto],oProd,aPrecos,oBox,.t.) OF oDlg //"Ok"
@ 144,80 BUTTON oBtn CAPTION STR0022 SIZE 60,15 ACTION CloseDialog() OF oDlg //"Cancelar"
@ 19,146 BUTTON oUp CAPTION Chr(5) SYMBOL ACTION PRUp(@nTop,cGrupo,aProduto,oLbx,nOrder) SIZE 13,10  OF oDlg
@ 130,146 BUTTON oDown CAPTION Chr(6) SYMBOL ACTION PRDown(@nTop,cGrupo,aProduto,oLbx,nOrder) SIZE 13,10 OF oDlg


PRLoad(@nTop,cGrupo,aProduto,oLbx)
ClearStatus()

ACTIVATE DIALOG oDlg


Return nil


Function PRLoad(nTop,cGrupo,aProduto,oLbx)
Local i       
Local nCargMax:=GetListRows(oLbx)
if nTop == 0 
  HB1->(dbSetOrder(3))
  HB1->(dbSeek(cGrupo))
  if !HB1->(Eof())
    nTop := HB1->(Recno())
  endif
else
  HB1->(dbGoTo(nTop))
endif
aSize(aProduto,0)
For i := 1 to nCargMax
   if !HB1->(Eof()) .and. (HB1->B1_GRUPO == cGrupo .Or. Empty(cGrupo))
	  AADD(aProduto,AllTrim(HB1->B1_DESC))
   else
	  break
   endif
   HB1->(dbSkip())
Next
SetArray(oLbx,aProduto)
Return nil

Function PRDown(nTop,cGrupo,aProduto,oLbx,nOrder)

HB1->(dbGoTo(nTop))
HB1->(dbSkip(GetListRows(oLbx)))
if ( !HB1->(Eof()) .and. ( nOrder != 3 .OR. HB1->B1_GRUPO == cGrupo) )
   nTop := HB1->(Recno())
else
   return nil
endif
Return PRLoad(@nTop,cGrupo,aProduto,oLbx)

Function PRUp(nTop,cGrupo,aProduto,oLbx,nOrder)

HB1->(dbGoTo(nTop))
HB1->(dbSkip(-GetListRows(oLbx)))
if nOrder != 3 .OR. HB1->B1_GRUPO == cGrupo 
   nTop := HB1->(Recno())
else
   return nil
endif
Return PRLoad(@nTop,cGrupo,aProduto,oLbx)

#define LBL_CODIGO aControls[1,2]
#define LBL_DESC   aControls[1,4]
#define LBL_UM     aControls[1,6]
#define LBL_QTD    aControls[1,8]
#define LBL_ENTR   aControls[1,10]
#define LBL_ICM    aControls[1,12]
#define LBL_IPI    aControls[1,14]
#define LBL_EST    aControls[1,16]
#define BROWSE_PRC aControls[2,1]
#define LBL_PRC    aControls[2,4]

Function PRSet(aControls,cProduto,cDesc,oProd,aPrecos,oBox,lClose)
HB1->(dbSetOrder(2))
HB1->(dbSeek(cDesc))
cProduto := HB1->B1_COD

If Select("HB2") != 0
    HB2->(dbSetOrder(1))
    HB2->(dbSeek(cProduto))
    cEst := Str(HB2->HB2_QTD,6,2) + " em " + DtoC(HB2->HB2_DATA)
Else
    cEst := HB1->B1_EST
EndIf

SetText(oProd,AllTrim(HB1->B1_DESC))
SetText(LBL_CODIGO,cProduto)
SetText(LBL_DESC,HB1->B1_DESC)
SetText(LBL_UM,HB1->B1_UM)
SetText(LBL_QTD,HB1->B1_QE)
SetText(LBL_ENTR,HB1->B1_PE)
SetText(LBL_ICM,HB1->B1_PICM)
SetText(LBL_IPI,HB1->B1_IPI)
SetText(LBL_EST,cEst)
SetText(LBL_PRC,HB1->B1_PRC01)

aSize(aPrecos,0)
HPR->(dbSeek(cProduto))
While (!HPR->(Eof()) .and. HPR->PR_PROD == cProduto)
  AADD(aPrecos,{ HPR->PR_TAB, HPR->PR_UNI } )
  HPR->(dbSkip())
end

SetArray(BROWSE_PRC,aPrecos)
PRChange(aControls,1,oBox)
if lClose
   CloseDialog()
endif

Return nil

Function PRFind(cPesq,lCodigo,aGrupo,nGrupo,cProduto,aControls,oProd,aPrecos,oBox)
Local nOrder := if(lCodigo,1,2)     
    
HB1->(dbSetOrder(nOrder))
if HB1->(dbSeek(cPesq))
	PRBrowse(aGrupo,nGrupo,@cProduto,aControls,oProd,aPrecos,oBox,HB1->(Recno()),nOrder)
else
    MsgStop(STR0024,STR0025) //"Produto não localizado!"###"Pesquisa Produto"
endif
Return nil

Function PREnd(lRet,cProduto)

lRet := if ( Len(cProduto) > 0 , .t., .f.)
CloseDialog()
Return nil