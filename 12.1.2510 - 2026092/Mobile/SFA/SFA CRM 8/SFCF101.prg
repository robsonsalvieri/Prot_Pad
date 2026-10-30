#include "eADVPL.ch"                                                        
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CFCons()            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao que determina o tipo de consulta/inclusao para	  ³±±
±±³			 ³ produtos e pedido.                	 			          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function CFCons(aCbx,nCbx,oChk1,lChk1,oChk2,lChk2,oChk3,lChk3)
Local cOpcao:=""
dbSelectArea("HCF")
dbSetOrder(1)
if nCbx == 1 
	dbSeek(RetFilial("HCF") + "MV_SFATPRO")
Elseif nCbx == 2 
	dbSeek(RetFilial("HCF") + "MV_SFATPED")
Endif
if Found()
	cOpcao := AllTrim(HCF->HCF_VALOR)
else
	Return Nil
Endif

if cOpcao == "1"
	lChk1:= .T.
	lChk2:= .F.
	lChk3:= .F.
Elseif cOpcao == "2"
	lChk1:= .F.
	lChk2:= .T.
	lChk3:= .F.
else
	lChk1:= .F.
	lChk2:= .F.
	lChk3:= .T.
Endif
SetText(oChk1,lChk1)	          
SetText(oChk2,lChk2)	          
SetText(oChk3,lChk3)	          

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CFGravar()          ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao que grava o tipo de consulta/inclusao para	      ³±±
±±³			 ³ produtos e pedido.                	 			          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function CFGravar(cOpcao,aCbx,nCbx,oChk1,lChk1,oChk2,lChk2,oChk3,lChk3)

dbSelectArea("HCF")
dbSetOrder(1)
if nCbx == 1 
	dbSeek(RetFilial("HCF") + "MV_SFATPRO")
Elseif nCbx == 2 
	dbSeek(RetFilial("HCF") + "MV_SFATPED")
Endif
if Found()
	HCF->HCF_VALOR := cOpcao
	dbCommit()
Else
	if nCbx == 1 
		dbAppend()
		HCF->HCF_FILIAL := RetFilial("HCF")
		HCF->HCF_PARAM := "MV_SFATPRO"  
		HCF->HCF_VALOR := cOpcao
		dbCommit()
	Elseif nCbx == 2 
		dbAppend()
		HCF->HCF_FILIAL := RetFilial("HCF")
		HCF->HCF_PARAM := "MV_SFATPED"  
		HCF->HCF_VALOR := cOpcao
		dbCommit()
	Endif
Endif	

if cOpcao == "1"
	lChk2:= .F.
	lChk3:= .F.
	SetText(oChk2,lChk2)	          
	SetText(oChk3,lChk3)	          
Elseif cOpcao == "2"
	lChk1:= .F.
	lChk3:= .F.
	SetText(oChk1,lChk1)	          
	SetText(oChk3,lChk3)	          
else
	lChk1:= .F.
	lChk2:= .F.
	SetText(oChk1,lChk1)	          
	SetText(oChk2,lChk2)	          
Endif

Return Nil