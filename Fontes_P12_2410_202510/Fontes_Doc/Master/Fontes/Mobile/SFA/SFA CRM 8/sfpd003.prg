#INCLUDE "SFPD001.ch"
#include "eADVPL.ch"

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD1Browse()         ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Monta List com Produtos              			   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aGrupo, nGrupo - Array e posicao do grupo, 				  ³±±
±±³			 ³ cProduto - Codigo do Produto, aPrecos - Array dos Precos,  ³±±
±±³			 ³ nOrder - Ordem											  ³±±
±±³			 ³ aControls - Array do Controles							  ³±±
±±³ 		 ³ lShow     - Status de Exibicao  		 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function PD1Browse(aGrupo,nGrupo,cProduto,aControls,oProd,aPrecos,oBox,nSetTop,nOrder)
//Local oDlg, oLbx, aProduto := {} , nProduto := 1, oBtn, oUp, oDown                    
Local oDlg, oBrwProd, nProduto := 1, oBtn, oUp, oDown, oGet
Local nTop := nSetTop, cGrupo := "", cDesc := ""
Local nPos := 0, nKey := 1
Local oCol, oBtnDir, oBtnEsq
Local cGet := ""
#IFNDEF __PALM__
Local oKeyDown, oKeyUp
#ENDIF


If nOrder==4
	If Len(aGrupo) > 0
		nPos := At("-", aGrupo[nGrupo])
		cGrupo := Substr(aGrupo[nGrupo],1,nPos-1)
	ELse
		Alert(STR0031)//"Nenhum grupo foi encontrado."
		Return nil	
	EndIf
Endif

MsgStatus(STR0001) //"Aguarde..."

DEFINE DIALOG oDlg TITLE STR0002  //"Produto"
@ 20,1 BROWSE oBrwProd SIZE 144,88 ON CLICK UpdateDesc(oGet, oBrwProd) NO SCROLL OF oDlg
SET BROWSE oBrwProd ARRAY aProduto 

If nOrder == 3
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0025 WIDTH 125 //"Cód. Fabr."
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0002 WIDTH 125 //"Produto"
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 3 HEADER STR0026 WIDTH 125 //"Descrição"
Else
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 1 HEADER STR0026 WIDTH 125 //"Descrição"
	ADD COLUMN oCol TO oBrwProd ARRAY ELEMENT 2 HEADER STR0002 WIDTH 125 //"Produto"
EndIf
	


If lNotTouch
	@ 130,15 BUTTON oBtn CAPTION STR0022 SIZE 60,15 ACTION PD1Set(aControls,@cProduto,GridRow(oBrwProd),cGrupo,oProd,aPrecos,oBox,.t.,nOrder) OF oDlg //"Ok"
	@ 130,80 BUTTON oBtn CAPTION STR0023 SIZE 60,15 ACTION CloseDialog() OF oDlg //"Cancelar"
Else
	@ 19,146 BUTTON oUp CAPTION Chr(5) SYMBOL ACTION PD1Up(@nTop,cGrupo,oBrwProd,nOrder) SIZE 13,10  OF oDlg
	@ 46,146 BUTTON oBtnDir CAPTION RIGHT_ARROW SYMBOL ACTION GridRight(oBrwProd) SIZE 13,10 OF oDlg
	@ 72,146 BUTTON oBtnEsq CAPTION LEFT_ARROW SYMBOL ACTION GridLeft(oBrwProd) SIZE 13,10 OF oDlg
	@ 98,146 BUTTON oDown CAPTION Chr(6) SYMBOL ACTION PD1Down(@nTop,cGrupo,oBrwProd,nOrder) SIZE 13,10 OF oDlg

	@ 115,01 GET oGet VAR cGet READONLY MULTILINE SIZE 150,30 OF oDlg

	@ 144,15 BUTTON oBtn CAPTION STR0022 SIZE 60,15 ACTION PD1Set(aControls,@cProduto,GridRow(oBrwProd),cGrupo,oProd,aPrecos,oBox,.t.,nOrder) OF oDlg //"Ok"
	@ 144,80 BUTTON oBtn CAPTION STR0023 SIZE 60,15 ACTION CloseDialog() OF oDlg //"Cancelar"
EndIf

PD1Load(@nTop,cGrupo,oBrwProd,.F.,nOrder,cProduto)
ClearStatus()
SetText(oGet, aProduto[1,1])
SetFocus(oGet)

#IFNDEF __PALM__
SET KEY VK_UP 	TO PdKeyMove(1, cGrupo, oBrwProd,@nTop,.f.,nOrder, oGet) IN oBrwProd OBJ oKeyUp
SET KEY VK_DOWN TO PdKeyMove(2, cGrupo, oBrwProd,@nTop,.f.,nOrder, oGet) IN oBrwProd OBJ oKeyDown
#ENDIF

ACTIVATE DIALOG oDlg

Return nil

Function PdKeyMove(nMove, cGrupo, oBrw,nTop,lFoco,nOrder, oGet)
Local nRow  := GridRow(oBrw)
Local nRows := GridRows(oBrw)
//Local oObj 

If nMove = 1 // Up
	nRow := nRow - 1
Else // Down
	nRow := nRow + 1
EndIf
If nRow > nRows
	//If Len(aProduto) > nRows
		PD1Down(@nTop,cGrupo,oBrw,nOrder)
	//EndIf
ElseIf nRow = 0
	PD1Up(@nTop,cGrupo,oBrw, nOrder)
Else
	GridSetRow(oBrw, nRow)
EndIf
//oObj := GetlastFld()
SetFocus(oGet)
Return Nil

Function UpdateDesc(oGet, oBrw)
Local nRow := GridRow(oBrw)
SetText(oGet, aProduto[nRow, 1])
SetFocus(oGet)
Return


#define LBL_CODIGO aControls[1,2]
#define LBL_DESC   aControls[1,4]
#define LBL_UM     aControls[1,6]
#define LBL_QTD    aControls[1,8]
#define LBL_ENTR   aControls[1,10]
#define LBL_DMAX   aControls[1,12]
#define LBL_ICM    aControls[1,14]
#define LBL_IPI    aControls[1,16]
#define LBL_EST    aControls[1,18]
#define BROWSE_PRC aControls[2,2]
#define LBL_PRC    aControls[2,4]

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD1Set()            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza os Texts com os valores dos campos		   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aControls - Array dos Controles,			 				  ³±±
±±³			 ³ cProduto - Codigo do Produto, aPrecos - Array dos Precos,  ³±±
±±³			 ³ nOrder - Ordem											  ³±±
±±³ 		 ³ aPrecos - Array dos Precos 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD1Set(aControls,cProduto,nProduto,cGrupo,oProd,aPrecos,oBox,lClose,nOrder)
Local cDesc      := "" 
Local nDescMax   := 0 
Local lExisteCpo := .F.
Local nTipoDesc  := 1
Local cPlvLest	 := "" 

dbSelectArea("HCF")
dbSetOrder(1)
dbSeek(RetFilial("HCF") + "MV_PLVLEST")
if !eof()
	cPlvLest := AllTrim(HCF->HCF_VALOR)
else
	cPlvLest :=	"T"  
endif

If Len(aProduto)=0
	Return Nil
Endif
cDesc:=aProduto[nProduto][2]

dbSelectArea("HB1")
If Empty(cGrupo)
	HB1->(dbSetOrder(1))
	HB1->(dbSeek(RetFilial("HB1") + cDesc))
Else
	cDesc:=aProduto[nProduto][1]
	HB1->(dbSetOrder(3))
	HB1->(dbSeek(RetFilial("HB1") + cGrupo + cDesc))
Endif

cProduto := HB1->HB1_COD

HB2->(dbSetOrder(1))
HB2->(dbSeek(RetFilial("HB2") + cProduto))

SetText(oProd,AllTrim(HB1->HB1_DESC))
SetText(LBL_CODIGO,cProduto)
If !lNotTouch
	SetText(LBL_DESC,HB1->HB1_DESC)
EndIf
SetText(LBL_UM,HB1->HB1_UM)
SetText(LBL_QTD,HB1->HB1_QE)
SetText(LBL_ENTR,HB1->HB1_PE)
SetText(LBL_ICM,HB1->HB1_PICM)
SetText(LBL_IPI,HB1->HB1_IPI)
If cPlvLest == "T"
	SetText(LBL_EST,Str(HB2->HB2_QTD,5,2) + " em " + DtoC(HB2->HB2_DATA))   
ElseIf (HB2->HB2_QTD) > 0
	SetText(LBL_EST,STR0032)
ElseIf (HB2->HB2_QTD) <= 0             
	SetText(LBL_EST,STR0033)
EndIf
SetText(LBL_PRC,HB1->HB1_PRV1)

// Posiciona produto na tabela
HPR->(dbSetOrder(1))
HPR->(dbSeek(RetFilial("HPR") + cProduto))

If HPR->(FieldPos("HPR_DESMAX")) != 0
	If HPR->(Found()) .And. HPR->HPR_DESMAX > 0
		nTipoDesc  := 1
		nDescMax   := HPR->HPR_DESMAX
	EndIf
EndIf
If HB1->(FieldPos("HB1_DESMAX")) != 0 
	If nDescMax = 0
		nTipoDesc := 2
		nDescMax  := HB1->HB1_DESMAX
	EndIf
Else
	If nDescMax = 0
		nDescMax := 100
	EndIf
Endif

SetText(LBL_DMAX ,Alltrim(Str(nDescMax,3,TamADVC("HB1_DESMAX",2))) + " %")

aSize(aPrecos,0)
HPR->(dbSeek(RetFilial("HPR") + cProduto))
If HPR->(FieldPos("HPR_DESMAX")) != 0
	lexistecpo := .t.
Endif
While (!HPR->(Eof()) .and. HPR->HPR_PROD == cProduto)
	AADD(aPrecos,{ HPR->HPR_TAB, HPR->HPR_UNI, If(lexistecpo, HPR->HPR_DESMAX, 0) } )
	HPR->(dbSkip())
end

SetArray(BROWSE_PRC,aPrecos)

PD1Change(aControls,1,oBox)
if lClose
   CloseDialog()
endif

Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PD1Descr            ³Autor:               ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Exibe a descricao do produto selecionado no listbox        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³ 		 ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function PD1Descr(oDesc,cDesc,nProduto)
cDesc := aProduto[nProduto]
SetText(oDesc,cDesc)
Return nil
