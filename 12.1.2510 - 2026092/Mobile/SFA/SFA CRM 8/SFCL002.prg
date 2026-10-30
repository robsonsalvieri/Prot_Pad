#INCLUDE "SFCL002.ch" 
#include "eADVPL.ch"
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
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0001 WIDTH 42  //"Código"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0002 WIDTH 20  //"Loja"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0003 WIDTH 120 //"Nome"
Elseif nCampo == 2
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0003 WIDTH 120 //"Nome"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0001 WIDTH 42  //"Código"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0002 WIDTH 20  //"Loja"
Else
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 4 HEADER STR0031 WIDTH 120 //"Cnpj"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER STR0003 WIDTH 120 //"Nome"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER STR0001 WIDTH 42  //"Código"
	ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER STR0002 WIDTH 20  //"Loja"
Endif

Return Nil


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CLMan()             ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao de manutencao do cadastro de clientes               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpCli - (1-Inclusao, 2-Alteracao, 3-Detalhes);		      ³±±
±±³			 ³ aCliente - Array do Listbox de clientes		              ³±±
±±³ 		 ³ nCliente - Posição do Cliente selecionado	              ³±±
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
Local oCidade, oUF, oTel, oCGC, oIE, oEmail
Local cCodCli:=space(6), cLojaCli:=space(2)//, cCliente := space(12), cTipo:=space(1)
//Local cRazao := space(40), cFantasia := space(20), cEndereco := space(40)
//Local cBairro := space(30), cCep := space(8), cCidade := space(15), cUF := space(2)
//Local cTel := space(15), cCGC := space(15),cIE := space(18), cEmail := space(30)
Local cNomeCli := aCliente[nCliente,3]
Local nTipo:=0, aTipo:={}, nUF:=1, aUF :={}

Local aEnableCtl	:= {}
Local cEnableCtl	:= ""
Local nI			:= 0 

Local aCliObj		:={}
Local aCliCtrl		:={} 

//Variaveis para controle de Tela
Local nLin			:= 0		
Local nPosini 	:= 18
Local nDistObj	:= 12
Local nPosBtn	:= 132

If lNotTouch
	nPosini		:= 10
	nDistObj	:= 15
	nPosBtn	:= 140
EndIf

Aadd(aCliCtrl,{"HA1_COD"		,Space(06)	,.F.})
Aadd(aCliCtrl,{"HA1_LOJA"		,Space(02)	,.F.})
Aadd(aCliCtrl,{"HA1_TIPO"		,Space(01)	,.T.})
Aadd(aCliCtrl,{"HA1_NOME"		,Space(40)	,.T.})
Aadd(aCliCtrl,{"HA1_NREDUZ"		,Space(20)	,.T.})
Aadd(aCliCtrl,{"HA1_TEL"		,Space(15)	,.T.})
Aadd(aCliCtrl,{"HA1_CGC"		,Space(15)	,.T.})
Aadd(aCliCtrl,{"HA1_INSCR" 		,Space(18)	,.T.})
Aadd(aCliCtrl,{"HA1_EMAIL"		,Space(30)	,.T.})
Aadd(aCliCtrl,{"HA1_END"		,Space(40)	,.T.})
Aadd(aCliCtrl,{"HA1_BAIRRO"		,Space(30)	,.T.})
Aadd(aCliCtrl,{"HA1_CEP"		,Space(08)	,.T.})
Aadd(aCliCtrl,{"HA1_MUN"		,Space(15)	,.T.})
Aadd(aCliCtrl,{"HA1_EST"		,Space(02)	,.T.})

If nOpCli ==1
	If !CrgProxCli(@cCodCli)
		Return Nil
	Endif
	aCliCtrl[1,2]	:= cCodCli
	aCliCtrl[4,2]	:= Space(40)
	aCliCtrl[2,2]	:= "01"
Else
	
	dbSelectArea("HA1")
	dbSetOrder(1)
	If dbSeek(RetFilial("HA1") + aCliente[nCliente,1]+aCliente[nCliente,2])

		aCliCtrl[1,2]		:= HA1->HA1_COD
		aCliCtrl[2,2]		:= HA1->HA1_LOJA
		aCliCtrl[3,2]		:= HA1->HA1_TIPO
		aCliCtrl[4,2]		:= ALLTRIM(HA1->HA1_NOME)+Replicate(" ",TamADVC("HA1_NOME",1)-Len(Alltrim(HA1->HA1_NOME)))
		aCliCtrl[5,2]		:= ALLTRIM(HA1->HA1_NREDUZ)+Replicate(" ",TamADVC("HA1_NREDUZ",1)-Len(Alltrim(HA1->HA1_NREDUZ)))
		aCliCtrl[6,2]		:= ALLTRIM(HA1->HA1_TEL)+Replicate(" ",TamADVC("HA1_TEL",1)-Len(Alltrim(HA1->HA1_TEL)))
		aCliCtrl[7,2]		:= HA1->HA1_CGC
		aCliCtrl[8,2]		:= HA1->HA1_INSCR
		aCliCtrl[9,2]		:= ALLTRIM(HA1->HA1_EMAIL)+Replicate(" ",TamADVC("HA1_EMAIL",1)-Len(Alltrim(HA1->HA1_EMAIL)))
		aCliCtrl[10,2]		:= ALLTRIM(HA1->HA1_END)+Replicate(" ",TamADVC("HA1_END",1)-Len(Alltrim(HA1->HA1_END)))
		aCliCtrl[11,2]		:= ALLTRIM(HA1->HA1_BAIRRO)+Replicate(" ",TamADVC("HA1_BAIRRO",1)-Len(Alltrim(HA1->HA1_BAIRRO)))
		aCliCtrl[12,2]		:= ALLTRIM(HA1->HA1_CEP)+Replicate(" ",TamADVC("HA1_CEP",1)-Len(Alltrim(HA1->HA1_CEP)))
		aCliCtrl[13,2]		:= ALLTRIM(HA1->HA1_MUN)+Replicate(" ",TamADVC("HA1_MUN",1)-Len(Alltrim(HA1->HA1_MUN)))
		aCliCtrl[14,2]		:= HA1->HA1_EST

	EndIf
Endif

// carrega o Array dos Estados
LoadUF(@aUF, nUf, aCliCtrl[14,2])

If nOpCli==1
	DEFINE DIALOG oDlg TITLE STR0004 //"Inclusão do Cliente"
Elseif nOpCli == 2
	If HA1->HA1_STATUS == "N" .And. !HA1->(IsDirty())		//Transmitido
		MsgAlert(STR0005,STR0006) //"Cliente novo já transmitido, não será possível alterá-lo."###"Aviso"
		return nil
	Endif
	DEFINE DIALOG oDlg TITLE STR0007 //"Alteracão do Cliente"
Else
	DEFINE DIALOG oDlg TITLE STR0008 //"Detalhes do Cliente"
Endif

nLin := nPosIni

ADD FOLDER oCliPrinc CAPTION STR0009 OF oDlg // Folder de Informacoes principais //"Principal"
@ nLin,02 SAY oSay PROMPT STR0010 of oCliPrinc //"Cliente: "
@ nLin,74 SAY oSay PROMPT "-" of oCliPrinc
nLin += nDistObj
@ nLin,02 SAY oSay PROMPT STR0011 of oCliPrinc //"Raz. Social: "
nLin += nDistObj
@ nLin,02 SAY oSay PROMPT STR0012 of oCliPrinc //"Fantasia: "
nLin += nDistObj
@ nLin,02 SAY oSay PROMPT STR0013 of oCliPrinc //"Tel.: "
nLin += nDistObj
@ nLin,02 SAY oSay PROMPT STR0014 of oCliPrinc //"CGC: "
nLin += nDistObj
@ nLin,02 SAY oSay PROMPT STR0015 of oCliPrinc //"IE: "
nLin += nDistObj
@ nLin,02 SAY oSay PROMPT STR0016 of oCliPrinc //"E-mail: "

nLin := nPosIni

ADD FOLDER oCliEnd CAPTION STR0017 OF oDlg // Folder de Informacoes de Endereco //"Endereco"
@ nLin,02 SAY oSay PROMPT STR0018 of oCliEnd //"Endereço: "
nLin += nDistObj
@ nLin,02 SAY oSay PROMPT STR0019 of oCliEnd //"Bairro: "
nLin += nDistObj
@ nLin,02 SAY oSay PROMPT STR0020 of oCliEnd //"CEP: "
nLin += nDistObj
@ nLin,02 SAY oSay PROMPT STR0021 of oCliEnd //"Cidade: "
nLin += nDistObj
@ nLin,02 SAY oSay PROMPT STR0022 of oCliEnd //"UF: "

@ nPosBtn,110 BUTTON oRetornarBt CAPTION STR0023 ACTION CloseDialog() SIZE 50,12 of oDlg //"Cancelar"

nLin := nPosIni

// Principal
@ nLin,35 GET oCodCli 	VAR aCliCtrl[1,2] READONLY of oCliPrinc
@ nLin,80 GET oLojaCli 	VAR aCliCtrl[2,2] SIZE 20,12 READONLY of oCliPrinc

@ nLin,105 BUTTON oBtnTipo CAPTION STR0025 ACTION TipoCli(aCliCtrl[3,2], oTipo) SIZE 25,10 of oCliPrinc //"Tipo:"
@ nLin,135 GET oTipo 		VAR aCliCtrl[3,2] SIZE 20,12 READONLY of oCliPrinc
nLin += nDistObj
@ nLin,50 GET oRazao 		VAR aCliCtrl[4,2] SIZE 110,12 of oCliPrinc
nLin += nDistObj
@ nLin,50 GET oFantasia 	VAR aCliCtrl[5,2] SIZE 110,12 of oCliPrinc
nLin += nDistObj
@ nLin,50 GET oTel 		VAR aCliCtrl[6,2]  SIZE 80,12 of oCliPrinc
nLin += nDistObj
@ nLin,50 GET oCGC 		VAR aCliCtrl[7,2] SIZE 80,12 of oCliPrinc
nLin += nDistObj
@ nLin,50 GET oIE 		VAR aCliCtrl[8,2] SIZE 90,12 of oCliPrinc
nLin += nDistObj
@ nLin,35 GET oEmail 		VAR aCliCtrl[9,2] SIZE 120,12 of oCliPrinc

nLin := nPosIni

// Endereco
@ nLin,45 GET oEndereco 	VAR aCliCtrl[10,2] SIZE 100,12 of oCliEnd
nLin += nDistObj
@ nLin,45 GET oBairro 	VAR aCliCtrl[11,2] SIZE 75,12 of oCliEnd
nLin += nDistObj
@ nLin,45 GET oCep 		VAR aCliCtrl[12,2] SIZE 70,12 of oCliEnd
nLin += nDistObj
@ nLin,45 GET oCidade 	VAR aCliCtrl[13,2] SIZE 92,12 of oCliEnd
nLin += nDistObj
@ nLin,45 COMBOBOX oUF 	VAR nUF ITEMS aUF SIZE 80,50 ACTION AtualUf(aUf, nUf, @aCliCtrl, 14) of oCliEnd // Passando Arrays com UFs, variavel com a posicao escolhida no Combo, Array de Campos, Posicao do Campos Estado no Array de Campos

aadd(aCliObj,oCodCli		)
aadd(aCliObj,oLojaCli		)
aadd(aCliObj,oTipo			)	
aadd(aCliObj,oRazao			)
aadd(aCliObj,oFantasia		)
aadd(aCliObj,oTel			) 	
aadd(aCliObj,oCGC			)
aadd(aCliObj,oIE			)
aadd(aCliObj,oEmail			)
aadd(aCliObj,oEndereco		)
aadd(aCliObj,oBairro		)
aadd(aCliObj,oCep			)
aadd(aCliObj,oCidade		)
aadd(aCliObj,oUF   			)

// Ponto de Entrada para Complementto da Tela de Cadastro de Clientes
// 1o Param: nOpCli (1-Inclusao, 2-Alteracao, 3-Detalhes)
// 2o Param: oDlg (Objeto da Dialog Principal)
// 3o Param: oCliPrinc (Objeto da Aba principal do Cliente)
// 4o Param: OClieEnd (Objeto da Aba de Endereco do Cliente)
// 5o Param: aCliCtrl (Array contendo os campos, objetos e campos padrao, onde poderemos agregar especificos 
// 6o Param: OClieObj (Array com todos os Objetos relacionados aos campos do aCliCtrl)
If ExistBlock("SFACL001")
	ExecBlock("SFACL001", .F., .F., {@nOpCli, @oDlg, @oCliPrinc, @oCliEnd, @aCliCtrl, @aCliObj })
EndIf

If nOpCli <> 3
	@ nPosBtn,55 BUTTON oGravarBt CAPTION STR0026 ACTION GrvCliente(nOpCli, @aCliCtrl, @aCliObj, @nTop,aCliente,nCliente,oBrw,nCargMax,nCampo) SIZE 50,12 of oDlg //"Gravar"
EndIf

If nOpCli == 2 .And. HA1->HA1_STATUS == "N"
	@ nPosBtn,01 BUTTON oExcluirBt CAPTION STR0027 ACTION ExcCliente(aCliCtrl[1,2],aCliCtrl[2,2],@nTop,aCliente,nCliente,oBrw,nCargMax,nCampo) SIZE 50,12 of oDlg //"Excluir"
Endif    

If nOpCli == 3
	For nI := 1 to Len(aCliObj)
		DisableControl(aCliObj[nI])
	Next        
	DisableControl(oBtnTipo)
ElseIf nOpCli == 2
	
	dbSelectArea("HCF")
	dbSetorder(1)
	If dbSeek(RetFilial("HCF") + "MV_SFAALCL")//Obriga a digitação da IE no cadastro de cliente.
		cEnableCtl := AllTrim(Upper(HCF->HCF_VALOR))
	Endif
	For nI := 1 to Len(cEnableCtl)
		If nI > Len(aCliCtrl)
			Exit
		EndIf
		If Substr(cEnableCtl,nI,1) == "0"
			aCliCtrl[nI+2,3] := .F.
		EndIf
	Next

	For nI := 1 to Len(aCliCtrl)
		If ! aCliCtrl[nI,3]  
		    If aCliCtrl[nI,1] == "HA1_TIPO"
				DisableControl(oBtnTipo)
			EndIf
			DisableControl(aCliObj[nI])
		EndIf
	Next

EndIf

ACTIVATE DIALOG oDlg

If nOpCli == 3
	ListaCli(@nTop, aCliente, nCliente, oBrw,nCargMax,nCampo)
Endif

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
Local aTipo	:= {}, oLbxTipo, oBtnRet
Local nTipo	:= 1
Local nX 	:= 0

dbSelectArea("HX5")
dbSetOrder(1)
dbSeek(RetFilial("HX5") + "TC")

While !Eof() .And. HX5->HX5_TABELA == "TC"
	AADD(aTipo,AllTrim(HX5->HX5_CHAVE) + "-"	+ AllTrim(HX5->HX5_DESCRI))
	If Alltrim(cTipo) == AllTrim(HX5->HX5_CHAVE)
		nTipo := len(aTipo)
		//Alert("nTipo = " + STR(nTipo))
	EndIf
	dbSkip()
Enddo

DEFINE DIALOG oDlg TITLE STR0028 //"Tipo do Cliente"

@ 22,02 SAY oSay PROMPT STR0029 of oDlg //"Escolha: "
@ 35,02 LISTBOX oLbxTipo VAR nTipo ITEMS aTipo SIZE 150,100 OF oDlg
@ 140,110 BUTTON oBtnRet CAPTION STR0030 ACTION FecTipoCli(aTipo,nTipo,@cTipo,oTipo) SIZE 40,15 of oDlg //"Retornar"

ACTIVATE DIALOG oDlg

Return Nil
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FecTipoCli()        ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Fecha janela do Tipo de Cliente           	 			  ³±±
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
