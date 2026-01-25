#include "eADVPL.ch"
#include "FDCL001.ch"
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
if dbSeek(RetFilial("HCF")+"MV_SFCADCL")
    cCadCli:=AllTrim(HCF->HCF_VALOR)
Endif	

aAdd(aCampo, STR0001) //"Codigo"
aAdd(aCampo, STR0002)  //"Nome"
aAdd(aCampo, STR0003)  //"CnPj"


DEFINE DIALOG oDlg TITLE STR0004 //"Manutenção de Clientes"

//@ 18,02 LISTBOX oLbx VAR nCliente ITEMS aCliente SIZE 145,70 of oDlg
@ 18,02 BROWSE oBrw SIZE 142,70  NO SCROLL ACTION ClickClient(@nCliente,aCliente,oBrw) OF oDlg
SET BROWSE oBrw ARRAY aCliente
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0005 WIDTH 42 //"Código"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0006 WIDTH 20 //"Loja"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER "Nome" WIDTH 120
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4 HEADER STR0003 WIDTH 120 //"CnPj"

@ 15,144 BUTTON oSobeBt CAPTION UP_ARROW SYMBOL SIZE 10,12 ACTION SobeCli(aCliente, nCliente, oBrw, nTop,nCargMax,nCampo) of oDlg
@ 35,144 BUTTON oEsqBt CAPTION LEFT_ARROW SYMBOL SIZE 10,12 ACTION GridLeft(oBrw) of oDlg
@ 55,144 BUTTON oDirBt CAPTION RIGHT_ARROW SYMBOL SIZE 10,12 ACTION GridRight(oBrw) of oDlg
@ 75,144 BUTTON oDesceBt CAPTION DOWN_ARROW SYMBOL SIZE 10,12 ACTION DesceCli(aCliente, nCliente, oBrw, nTop,nCargMax,nCampo) of oDlg
@ 90,02 SAY oSay PROMPT STR0007 BOLD of oDlg //"Pesquisar por: "
@ 90,72 COMBOBOX oCbx VAR nCampo ITEMS aCampo SIZE 50,40 ACTION CLOrder(@nCliente,oBrw,aCliente,nTop,nCargMax,nCampo) of oDlg
@ 105,02 GET oPesquisaTx VAR cPesquisa of oDlg
#ifdef __Palm__ 
  @ 120,02 BUTTON oPesquisaBt CAPTION BTN_BITMAP_SEARCH SYMBOL SIZE 45,12 ACTION PesquisaCli(@cPesquisa, oPesquisaTx, oBrw, aCliente, nCliente, nTop, aCampo, nCampo,nCargMax) of oDlg
#else  
  @ 120,02 BUTTON oPesquisaBt CAPTION STR0008 SIZE 45,12 ACTION PesquisaCli(@cPesquisa, oPesquisaTx, oBrw, aCliente, nCliente, nTop, aCampo, nCampo,nCargMax) of oDlg //"Pesquisar"
#endif 
@ 140,02 BUTTON oIncluirBt CAPTION STR0009 SIZE 30,12 ACTION ClMan(1,@nTop,aCliente,nCliente,oBrw,nCargMax,nCampo) of oDlg //"Incluir"
@ 140,35 BUTTON oAlterarBt CAPTION STR0010 SIZE 35,12 ACTION ClMan(2,@nTop,aCliente,nCliente,oBrw,nCargMax,nCampo) of oDlg //"Alterar"
@ 140,73 BUTTON oDetalhesBt CAPTION STR0011 SIZE 40,12 ACTION ClMan(3,@nTop,aCliente, nCliente,oBrw,nCargMax) of oDlg //"Detalhes"
@ 140,117 BUTTON oRetornarBt CAPTION STR0012 SIZE 40,12 ACTION CloseDialog() of oDlg //"Retornar"

dbSelectArea("HA1")
dbSetOrder(nCampo)
dbGoTop()
nTop := HA1->(Recno())

nCargMax := GridRows(oBrw)
For i:= 1 to nCargMax
//	aAdd(aCliente, AllTrim(HA1->HA1_NOME))
	aAdd(aCliente, {HA1->HA1_COD,HA1->HA1_LOJA,AllTrim(HA1->HA1_NOME),HA1->HA1_CGC})
	If Eof()
		break
	Endif
	dbSkip()
Next

SetArray(oBrw,aCliente)

// Aplica as Permissoes nos Objetos
If cCadCli="2"
	DisableControl(oIncluirBt)
Elseif cCadCli="3"
	DisableControl(oIncluirBt)
	DisableControl(oAlterarBt)
Endif

ACTIVATE DIALOG oDlg

Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ InitParam(  )       ³Autor: Marcelo Vieira³ Data ³15.01.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Inicia o Modulo de Clientes               	 			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function InitParam()
Local oCol, oBrw, oDlg, oRetornarBt
Local aParametro:={}

DEFINE DIALOG oDlg TITLE STR0013 //"Consulta Parametros"

@ 18,02 BROWSE oBrw SIZE 143,115 OF oDlg
SET BROWSE oBrw ARRAY aParametro
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0014 WIDTH 75 //"Parametro"
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0015 WIDTH 30 //"Valor"
@ 140,105 BUTTON oRetornarBt CAPTION STR0012 SIZE 40,12 ACTION CloseDialog() of oDlg //"Retornar"

ACCrgPar(aParametro)

SetArray(oBrw,aParametro)

ACTIVATE DIALOG oDlg

Return nil
