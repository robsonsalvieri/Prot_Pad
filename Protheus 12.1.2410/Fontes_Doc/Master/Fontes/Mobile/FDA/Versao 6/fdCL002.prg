#include "FDCL002.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CLChangeColun()     ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Altera a Ordem das Colunas do Browse do Cliente 			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function CLChangeColun(nCliente,oBrw,nCampo)
Local oCol
nCliente:= 1
GridReset(oBrw)

if nCampo == 1
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0001 WIDTH 42 //"Código"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0002 WIDTH 20 //"Loja"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0003 WIDTH 120 //"Nome"
Elseif nCampo == 2
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0003 WIDTH 120 //"Nome"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0001 WIDTH 42 //"Código"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0002 WIDTH 20 //"Loja"
Else
    ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4 HEADER STR0004 WIDTH 120      // 01/06/04 //"CnPj"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0003 WIDTH 120 //"Nome"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0001 WIDTH 42 //"Código"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0002 WIDTH 20 //"Loja"
Endif	

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CLMan()             ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao de manutencao do cadastro de clientes               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpCli - (1-Inclusao, 2-Alteracao, 3-Detalhes);			  ³±±
±±³			 ³ aCliente - Array do Listbox de clientes					  ³±±
±±³ 		 ³ nCliente - Posição do Cliente selecionado				  ³±±
±±³ 		 ³ nCargMax - Numero maxio de clientes por pagina			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function CLMan(nOpCli,nTop,aCliente,nCliente,oBrw,nCargMax,nCampo)

Local oDlg, oSay, oCliPrinc, oCliEnd, oRetornarBt, oGravarBt, oExcluirBt
Local oCodCli, oLojaCli, oBtnTipo, oTipo, oRazao, oFantasia, oEndereco, oBairro, oCep
Local oCidade, oUF, oTel, oCNPJ, oIE, oEmail
Local cCodCli:=space(6), cLojaCli:=space(2), cCliente := space(12), cTipo:=space(1)
Local cRazao := space(40), cFantasia := space(20), cEndereco := space(40)
Local cBairro := space(30), cCep := space(8), cCidade := space(15), cUF := space(2) 
Local cTel := space(15), cCNPJ := space(15),cIE := space(18), cEmail := space(30)
Local cNomeCli := aCliente[nCliente,3]
Local nTipo:=0, aTipo:={}, nUF:=1, aUF :={}

if nOpCli ==1
	if !CrgProxCli(@cCodCli) 
	    Return Nil
	Endif
	cNomeCli	:= ""
	cLojaCli	:= "01"
Else

	dbSelectArea("HA1")
	dbSetOrder(1)
//	dbSeek(cNomeCli)
	dbSeek(aCliente[nCliente,1]+aCliente[nCliente,2])	

	If HA1->(Found())
		cCodCli		:= HA1->A1_COD
		cLojaCli	:= HA1->A1_LOJA
		cTipo		:= HA1->A1_TIPO
		cRazao 		:= HA1->A1_NOME
		cFantasia 	:= HA1->A1_NREDUZ
		cEndereco 	:= HA1->A1_END
		cBairro		:= HA1->A1_BAIRRO
		cCep 		:= HA1->A1_CEP
		cCidade 	:= HA1->A1_MUN
		cUF 		:= HA1->A1_EST
		cTel 		:= HA1->A1_TEL
		cCNPJ 		:= HA1->A1_CGC
		cIE 		:= HA1->A1_INSCR
		cEmail		:= HA1->A1_EMAIL
	EndIf
Endif

// carrega o Array dos Estados
LoadUF(@aUF, nUf, cUf)

if nOpCli==1 
	DEFINE DIALOG oDlg TITLE STR0005 //"Inclusão do Cliente"
Elseif nOpCli == 2  
	If HA1->A1_STATUS == "N" .And. !HA1->(IsDirty())		//Transmitido
		MsgAlert(STR0006,STR0007) //"Cliente novo já transmitido, não será possível alterá-lo."###"Aviso"
		return nil
	Endif
	DEFINE DIALOG oDlg TITLE STR0008 //"Alteração do Cliente"
Else	
	DEFINE DIALOG oDlg TITLE STR0009 //"Detalhes do Cliente"
Endif

ADD FOLDER oCliPrinc CAPTION STR0010 OF oDlg // Folder de Informacoes principais //"Principal"
@ 18,02 SAY oSay PROMPT STR0011 of oCliPrinc //"Cliente: "
@ 18,74 SAY oSay PROMPT "-" of oCliPrinc
@ 30,02 SAY oSay PROMPT STR0012 of oCliPrinc //"Raz. Social: "
@ 42,02 SAY oSay PROMPT STR0013 of oCliPrinc //"Fantasia: "
@ 54,02 SAY oSay PROMPT STR0014 of oCliPrinc //"Tel.: "
@ 66,02 SAY oSay PROMPT STR0015 of oCliPrinc //"CNPJ: "
@ 78,02 SAY oSay PROMPT STR0016 of oCliPrinc //"IE: "
@ 90,02 SAY oSay PROMPT STR0017 of oCliPrinc //"E-mail: "


ADD FOLDER oCliEnd CAPTION STR0018 OF oDlg // Folder de Informacoes de Endereco //"Endereco"
@ 18,02 SAY oSay PROMPT STR0019 of oCliEnd //"Endereço: "
@ 30,02 SAY oSay PROMPT STR0020 of oCliEnd //"Bairro: "
@ 42,02 SAY oSay PROMPT STR0021 of oCliEnd //"CEP: "
@ 54,02 SAY oSay PROMPT STR0022 of oCliEnd //"Cidade: "
@ 66,02 SAY oSay PROMPT STR0023 of oCliEnd //"UF: "

@ 126,100 BUTTON oRetornarBt CAPTION BTN_BITMAP_CANCEL SYMBOL ACTION CloseDialog() SIZE 50,12 of oDlg

if nOpCli==3 

	// Principal
	@ 18,35 GET oCodCli VAR cCodCli READONLY NO UNDERLINE of oCliPrinc
	@ 18,82 GET oLojaCli VAR cLojaCli READONLY NO UNDERLINE of oCliPrinc
	@ 18,103 SAY oSay PROMPT STR0024 of oCliPrinc //"Tipo: "
	@ 18,133 GET oTipo VAR cTipo READONLY NO UNDERLINE of oCliPrinc
	@ 30,50 GET oRazao VAR cRazao READONLY NO UNDERLINE of oCliPrinc
	@ 42,50 GET oFantasia VAR cFantasia READONLY NO UNDERLINE of oCliPrinc
	@ 54,50 GET oTel VAR cTel READONLY NO UNDERLINE of oCliPrinc
	@ 66,50 GET oCNPJ VAR cCNPJ READONLY NO UNDERLINE of oCliPrinc
	@ 78,50 GET oIE VAR cIE READONLY NO UNDERLINE of oCliPrinc
	@ 90,35 GET oEmail VAR cEmail READONLY NO UNDERLINE of oCliPrinc

	// Endereco
	@ 18,50 GET oEndereco VAR cEndereco READONLY NO UNDERLINE of oCliEnd
	@ 30,50 GET oBairro VAR cBairro READONLY NO UNDERLINE SIZE 55,12 of oCliEnd
	@ 42,50 GET oCep VAR cCep READONLY NO UNDERLINE of oCliEnd
	@ 54,35 GET oCidade VAR cCidade READONLY NO UNDERLINE of oCliEnd
	@ 66,50 GET oUF VAR cUF READONLY NO UNDERLINE of oCliEnd

Else
	// Principal
	@ 18,35 GET oCodCli VAR cCodCli READONLY of oCliPrinc
	@ 18,80 GET oLojaCli VAR cLojaCli SIZE 25,12 READONLY of oCliPrinc
	@ 17,100 BUTTON oBtnTipo CAPTION STR0025 ACTION TipoCli(@cTipo,oTipo) SIZE 25,12 of oCliPrinc //"Tipo:"
	@ 18,130 GET oTipo VAR cTipo SIZE 20,12 of oCliPrinc
	@ 30,50 GET oRazao VAR cRazao SIZE 110,12 of oCliPrinc
	@ 42,50 GET oFantasia VAR cFantasia SIZE 110,12 of oCliPrinc
	@ 54,50 GET oTel VAR cTel  SIZE 80,12 of oCliPrinc
	@ 66,50 GET oCNPJ VAR cCNPJ SIZE 80,12 of oCliPrinc 
	@ 78,50 GET oIE VAR cIE SIZE 90,12 of oCliPrinc
	@ 90,35 GET oEmail VAR cEmail SIZE 120,12 of oCliPrinc

	// Endereco
	@ 18,45 GET oEndereco VAR cEndereco SIZE 100,12 of oCliEnd
	@ 30,45 GET oBairro VAR cBairro SIZE 75,12 of oCliEnd
	@ 42,45 GET oCep VAR cCep SIZE 70,12 of oCliEnd
	@ 54,45 GET oCidade VAR cCidade SIZE 92,12 of oCliEnd
	@ 66,45 COMBOBOX oUF VAR nUF ITEMS aUF SIZE 80,50 ACTION AtualUf(aUf, @cUf, nUf) of oCliEnd
//	@ 66,50 GET oUF VAR cUF of oCliEnd
	//PICTURE "@!"
	@ 126,55 BUTTON oGravarBt CAPTION BTN_BITMAP_GRAVAR SYMBOL ACTION GrvCliente(nOpCli,cCodCli,cLojaCli,cTipo,cRazao,cFantasia,cEndereco,cBairro,cCep,cCidade,cUF,cTel,cCNPJ,cIE,cEmail,@nTop,aCliente,nCliente,oBrw,nCargMax,nCampo) SIZE 50,12 of oDlg
	If nOpCli == 2 .And. HA1->A1_STATUS == "N"
		@ 126,01 BUTTON oExcluirBt CAPTION STR0026 ACTION ExcCliente(cCodCli,cLojaCli,@nTop,aCliente,nCliente,oBrw,nCargMax,nCampo) SIZE 50,12 of oDlg //"Excluir"
	Endif
Endif 

//Ponto de Entrada: Complemento da tela de manutencao de Clientes
#IFDEF PECL0001
	//Objetivo: acrescentar campos
	//Retorno: 
	uRet := PECL0001()
#ENDIF

ACTIVATE DIALOG oDlg

Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ TipoCli()           ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao de selecao do tipo de clientes                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function TipoCli(cTipo,oTipo)
Local oDlg, oSay
Local aTipo	:= {}, nTipo:= 0, oLbxTipo, oBtnRet

dbSelectArea("HX5")
dbSetOrder(1)
dbSeek("TC")

While !Eof() .And. HX5->X5_TABELA == "TC" 
	AADD(aTipo,AllTrim(HX5->X5_CHAVE) + "-"	+ AllTrim(HX5->X5_DESCRI))
	dbSkip()
Enddo

DEFINE DIALOG oDlg TITLE STR0027 //"Tipo do Cliente"

@ 22,02 SAY oSay PROMPT STR0028 of oDlg //"Escolha: "
@ 35,02 LISTBOX oLbxTipo VAR nTipo ITEMS aTipo SIZE 150,100 OF oDlg
@ 140,110 BUTTON oBtnRet CAPTION STR0029 ACTION FecTipoCli(aTipo,nTipo,@cTipo,oTipo) SIZE 40,15 of oDlg //"Retornar"

ACTIVATE DIALOG oDlg

Return Nil
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FecTipoCli()        ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Fecha janela do Tipo de Cliente           	 			     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FecTipoCli(aTipo,nTipo,cTipo,oTipo)
if nTipo>0
	cTipo	:=Substr(aTipo[nTipo],1,at("-",aTipo[nTipo])-1)
	SetText(oTipo,cTipo)
Endif    
CloseDialog()
Return Nil
