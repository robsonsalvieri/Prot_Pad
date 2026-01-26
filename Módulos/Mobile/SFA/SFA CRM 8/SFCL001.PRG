#INCLUDE "SFCL001.ch"
#include "eADVPL.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ InitCliente()       ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inicia o Modulo de Clientes               	 			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function InitCliente()

Local oDlg, oSay, oPesquisaTx, oBrw, oPesquisaBt
Local oIncluirBt, oAlterarBt, oDetalhesBt, oRetornarBt
Local oSobeBt, oDesceBt, oEsqBt, oDirBt, oCbx, aCampo := {}, nCampo := 1, nTop := 0
Local nCliente := 1, aCliente := {}, cPesquisa := space(30), i := 0
Local nCargMax :=6 // Carga Maxima de Linhas no ListBox
Local cCadCli:="1"
Local oCol
//USE SFHA1 ALIAS HA1 SHARED NEW VIA "LOCAL"
//dbSetIndex("CLI1")
//dbSetIndex("CLI2")
//dbGoTop()

// Permissoes de Uso do Modulo de Cliente
dbSelectArea("HCF")
if dbSeek(RetFilial("HCF") + "MV_SFCADCL")
    cCadCli:=AllTrim(HCF->HCF_VALOR)
Endif	

aCampo := {"1 - Codigo","2 - Nome","3 - CNPJ/CPF"}

/*	aAdd(aCampo, STR0001) //"Codigo"
	aAdd(aCampo, STR0002) //"Nome"	  
	aAdd(aCampo, STR0012) //"CNPJ/CPF"*/

DEFINE DIALOG oDlg TITLE STR0003 //"Manutenção de Clientes"

//@ 18,02 LISTBOX oLbx VAR nCliente ITEMS aCliente SIZE 145,70 of oDlg
@ 18,02 BROWSE oBrw SIZE 143,70  NO SCROLL ACTION ClickClient(@nCliente,aCliente,oBrw) OF oDlg
SET BROWSE oBrw ARRAY aCliente
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0004 WIDTH 42 //"Código"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0005 WIDTH 20 //"Loja"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0002 WIDTH 120 //"Nome"

If !lNotTouch
	@ 18,148 BUTTON oSobeBt CAPTION UP_ARROW SYMBOL SIZE 10,12 ACTION SobeCli(aCliente, nCliente, oBrw,@nTop,nCargMax,nCampo) of oDlg
	@ 38,148 BUTTON oEsqBt CAPTION LEFT_ARROW SYMBOL SIZE 10,12 ACTION GridLeft(oBrw) of oDlg
	@ 58,148 BUTTON oDirBt CAPTION RIGHT_ARROW SYMBOL SIZE 10,12 ACTION GridRight(oBrw) of oDlg
	@ 78,148 BUTTON oDesceBt CAPTION DOWN_ARROW SYMBOL SIZE 10,12 ACTION DesceCli(aCliente, nCliente, oBrw,@nTop,nCargMax,nCampo) of oDlg
EndIf

@ 90,02 SAY oSay PROMPT STR0006 BOLD of oDlg //"Pesquisar por: "
If lNotTouch
	@ 90,100 COMBOBOX oCbx VAR nCampo ITEMS aCampo SIZE 50,40 ACTION CLOrder(@nCliente,oBrw,aCliente,@nTop,nCargMax,nCampo) of oDlg
Else
	@ 90,72 COMBOBOX oCbx VAR nCampo ITEMS aCampo SIZE 50,40 ACTION CLOrder(@nCliente,oBrw,aCliente,@nTop,nCargMax,nCampo) of oDlg
EndIf

@ 105,02 GET oPesquisaTx VAR cPesquisa of oDlg
@ 122,02 BUTTON oPesquisaBt CAPTION STR0007 SIZE 45,12 ACTION PesquisaCli(cPesquisa, oPesquisaTx, oBrw, aCliente, nCliente, nTop, aCampo, nCampo,nCargMax) of oDlg //"Pesquisar"
@ 140,02 BUTTON oIncluirBt CAPTION STR0008 SIZE 30,12 ACTION ClMan(1,@nTop,aCliente,nCliente,oBrw,nCargMax,nCampo) of oDlg //"Incluir"
@ 140,35 BUTTON oAlterarBt CAPTION STR0009 SIZE 35,12 ACTION ClMan(2,@nTop,aCliente,nCliente,oBrw,nCargMax,nCampo) of oDlg //"Alterar"
@ 140,73 BUTTON oDetalhesBt CAPTION STR0010 SIZE 40,12 ACTION ClMan(3,@nTop,aCliente, nCliente,oBrw,nCargMax,nCampo) of oDlg //"Detalhes"
@ 140,117 BUTTON oRetornarBt CAPTION STR0011 SIZE 40,12 ACTION CloseDialog() of oDlg //"Retornar"

dbSelectArea("HA1")
dbSetOrder(nCampo)
//dbGoTop()
dbSeek(RetFilial("HA1"))
nTop := HA1->(Recno())

If lNotTouch
	nCargMax := HA1->(RecCount())
Else
	nCargMax := GridRows(oBrw)
EndIf
For i:= 1 to nCargMax
//	aAdd(aCliente, AllTrim(HA1->HA1_NOME))
	aAdd(aCliente, {HA1->HA1_COD,HA1->HA1_LOJA,AllTrim(HA1->HA1_NOME),Alltrim(HA1->HA1_CGC) })
	If Eof()
		break
	Endif
	dbSkip()
Next

SetArray(oBrw,aCliente)

// Aplica as Permissoes nos Objetos
If cCadCli="2"
	HideControl(oIncluirBt)
Elseif cCadCli="3"
	HideControl(oIncluirBt)
	HideControl(oAlterarBt)
Endif

// Ponto de Entrada antes da montagem da interface de manutenção de clientes, onde poderemos
// agregar informacoes nesta interface, desabitlitar ou esconder objetos, etc..
If ExistBlock("SFACL003")
	ExecBlock("SFACL003", .F., .F., { oIncluirBt, oAlterarBt, oDetalhesBt, oRetornarBt, oBrw, oDlg, @nTop, aCliente, nCliente, nCargMax, nCampo })
EndIf

ACTIVATE DIALOG oDlg

Return nil
