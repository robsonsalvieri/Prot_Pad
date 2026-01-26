#INCLUDE "SFCF001.ch"
#include "eADVPL.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ InitConfig()        ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo Config               	 			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function InitConfig()
Local oDlg,oCbx,oBtnRet,oChk1,oChk2,oChk3
Local aCbx:={}, nCbx:=1, lChk1 := .T., lChk2 := .F., lChk3 := .F.
Local nEscPd:=0, nEscPv:=0
Local cTable := "HCF"
                      
If !(Select("HCF")>0)
	MsgStop(STR0001 + cTable + STR0002,STR0003) //"Tabela de Configurações "###" não encontrada!"###"Aviso"
	return nil
EndIf

AADD(aCbx,STR0004) //"Produto"
//AADD(aCbx,"Pedido")

DEFINE DIALOG oDlg TITLE STR0005 //"Configuracoes dos Modulos"

@ 18,10 SAY STR0006 OF oDlg //"Escolha Modulo:"
@ 38,10 COMBOBOX oCbx VAR nCbx ITEMS aCbx ACTION CFCons(aCbx,nCbx,oChk1,@lChk1,oChk2,@lChk2,oChk3,@lChk3) SIZE 110,30 OF oDlg
@ 58,10 SAY STR0007 OF oDlg //"Escolha Tela:"
@ 78,10 CHECKBOX oChk1 VAR lChk1 CAPTION STR0008 ACTION CFGravar("1",aCbx,nCbx,oChk1,@lChk1,oChk2,@lChk2,oChk3,@lChk3) SIZE 60,12 OF oDlg //"Padrão"
@ 90,10 CHECKBOX oChk2 VAR lChk2 CAPTION STR0009 ACTION CFGravar("2",aCbx,nCbx,oChk1,@lChk1,oChk2,@lChk2,oChk3,@lChk3) SIZE 60,12 OF oDlg //"Optativo"
@ 102,10 CHECKBOX oChk3 VAR lChk3 CAPTION STR0010 ACTION CFGravar("3",aCbx,nCbx,oChk1,@lChk1,oChk2,@lChk2,oChk3,@lChk3) SIZE 60,12 OF oDlg //"Específico"
#IFDEF __PALM__
	@ 146,02 BUTTON oBtnRet CAPTION STR0011 ACTION CloseDialog() SIZE 160,12 of oDlg //"Retornar"
#ELSE
	@ 148,02 BUTTON oBtnRet CAPTION STR0011 ACTION CloseDialog() SIZE 160,12 of oDlg //"Retornar"
#ENDIF
CFCons(aCbx,nCbx,oChk1,@lChk1,oChk2,@lChk2,oChk3,@lChk3)
ACTIVATE DIALOG oDlg

Return Nil      

