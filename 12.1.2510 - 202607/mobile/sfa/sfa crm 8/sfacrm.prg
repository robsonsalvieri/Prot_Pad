#INCLUDE "sfacrm.ch"
#include "eADVPL.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SfaCrm()            ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo Principal do SFA CRM               	 			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function SFACRM()
Local oDlg, oMnu
Local oItem,oSay, oBtnEmp
Local lSenha   := .T.
Local cProd    := ""
Local aPrdPrefix := {}
Local cMeter   := ""
Local nMeterFiles := 0
Local oSayFile, oMeterFiles
Local cSfaCfg := "2"
Local cSfaDrt := "2"
Local aEmp := {}
Local nEmp := 1
Local lEmp := .F., lArq := .F., lSync := .F.
Local cSfaMsg := "F"
Local nPosPeso := 0  
Local aSenhaObj   := {}
Local cSenha := "F" 

SET DATE BRITISH 
SET DELETE ON

Public cEmpresa := ""
Public cFilial := ""
Public cSufixo := ""
PUBLIC nLastProd := 0
PUBLIC nI:=0
//Arrays e variaveis usadas na tela de produtos
Public aProduto := {}
Public cUltGrupo:= ""
Public aGrupo := {}, nGrupo := 1
Public cCalcProtheus := ""
Public nPagProd := 0,  cQtdDec := ""
Public cSfaPeso	:= "F"
Public cUmPeso	:= "1"
//Variavel para identificar se o equipamento possui touchscreen
Public lNotTouch	:= .F.
#IFNDEF __PALM__
	lNotTouch		:= !(IsTouch())
#ENDIF

// Verifica arquivo de Empresas
If !OpenEmp(aEmp)
	InitSync()
	Return .F.
EndIf
//Desabilita tela de senha (T/F)
dbSelectArea("HCF")
DbSetorder(1)
dbgotop()
If dbSeek(RetFilial("HCF")+"MV_SFASENH")
   cSenha := AllTrim(HCF->HCF_VALOR)
EndIf

If cSenha == "F"
   If !Senha(aEmp)
	  Return Nil
   EndIf     
EndIf

// Verifica ultimo sincronismo
If !VrfPerm()
	InitSync()
	Return .F.
EndIf                                                 

If cSenha == "T" // TELA DE SENHA DESABILITADA
   MsgStatus(STR0026) //"Abrindo Tabelas... Aguarde"
	If !Empty(cEmpresa) 
		ChoiceEmp(aEmp, nEmp, aSenhaObj)
		cCodVend    := HA3->HA3_COD
		cNomeVend   := HA3->HA3_NREDUZ
	EndIf
	OpenFiles(oSayFile, oMeterFiles, nMeterFiles)
	ClearStatus()
EndIf

CtrFaixa()

//Alteracao para forcar a abertura da tela de mensagens do vendedor
If Select("HMV") > 0
	cSfaMsg := SFGetMv("MV_SFAMSG",.F.,"F")
	If cSfaMsg =="T"
		InitMensagem()
	ElseIf cSfaMsg =="F"
		MsgVendedor()
	EndIF
EndIf

SetPrefix(aPrdPrefix)

// Parametro para opcao Config
cSfaCfg := SFGetMv("MV_SFACFG",.F.,"2")

// Parametro para opcao DirtyTable
cSfaDrt := SFGetMv("MV_SFADRT",.F.,"2")



DEFINE DIALOG oDlg TITLE "SFA-CRM"

ADD MENUBAR oMnu CAPTION STR0001 OF oDlg //"Principal"
ADD MENUITEM oItem CAPTION STR0002 ACTION VisitaNegocio() OF oMnu //"Visitas de Negócios"
ADD MENUITEM oItem CAPTION STR0003 ACTION FechamentoDia() OF oMnu //"Fechamento do Dia"
ADD MENUITEM oItem CAPTION STR0004 ACTION GetProduto(cProd,aPrdPrefix) of oMnu //"Cons. Produtos"
//ADD MENUITEM oItem CAPTION "Gerencimento do Vendedor" ACTION GerenciaVendas() OF oMnu
ADD MENUITEM oItem CAPTION STR0005 ACTION InitCliente() OF oMnu //"Clientes"

ADD MENUITEM oItem CAPTION STR0025 ACTION StatFinanc() OF oMnu // Posicao Financeira

ADD MENUITEM oItem CAPTION STR0006 ACTION InitMetas() OF oMnu //"Metas"
ADD MENUITEM oItem CAPTION STR0007 ACTION InitMensagem() OF oMnu //"Mensagem"
If cSfaCfg = "1"
	ADD MENUITEM oItem CAPTION "Config" ACTION InitConfig() OF oMnu
Endif
If cSfaDrt = "1"
	ADD MENUITEM oItem CAPTION STR0021 ACTION DirtyTable() OF oMnu
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Menu Principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("SFACRM01")
	ExecBlock("SFACRM01", .F., .F., {oItem, oMnu })
EndIf

ADD MENUITEM oItem CAPTION "Sync" ACTION InitSync(oSayFile, oMeterFiles, nMeterFiles) OF oMnu
ADD MENUITEM oItem CAPTION STR0009 ACTION CloseDialog() OF oMnu //"Sair"

@ 47,20 GET oSayFile VAR cMeter READONLY NO UNDERLINE SIZE 120,15 OF oDlg
@ 62,20 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 OF oDlg

If lNotTouch

	@ 40,60 SAY "SFA-CRM" BOLD LARGE OF oDlg
	#ifdef __PALM__
		@ 60,61 SAY "for PalmOS" OF oDlg
	#else
		@ 60,61 SAY "for PocketPC" OF oDlg
	#endif
	@ 75,03 SAY oSay PROMPT  STR0010 + GetVer() OF oDlg //"Versão 6.0.1i"
	@ 90,03 SAY oSay PROMPT  "Versão da Lib - " + GetRTVer() OF oDlg //"Versão 6.0.1i"
	//@ 117,03 SAY oSay PROMPT  "Versão em Desenvolvimento (nao distribuir)" OF oDlg
	@ 105,03 SAY oSay PROMPT  STR0011 OF oDlg //"Data: 22/03/2004"
	
	@ 120,03 BUTTON oBtnEmp CAPTION  STR0022 + "/" + STR0023 + cEmpresa + "/" + cFilial ACTION ChangeEmp(oSayFile, oMeterFiles, nMeterFiles, oBtnEmp) OF oDlg
	@ 142,03 SAY oSay PROMPT  STR0024 OF oDlg
Else
	@ 75,50 SAY "SFA-CRM" BOLD LARGE OF oDlg
	#ifdef __PALM__
		@ 90,51 SAY "for PalmOS" OF oDlg
	#else
		@ 90,51 SAY "for PocketPC" OF oDlg
	#endif
	@ 102,03 SAY oSay PROMPT  STR0010 + GetVer() OF oDlg //"Versão 6.0.1i"
	@ 112,03 SAY oSay PROMPT  "Versão da Lib - " + GetRTVer() OF oDlg //"Versão 6.0.1i"
	//@ 117,03 SAY oSay PROMPT  "Versão em Desenvolvimento (nao distribuir)" OF oDlg
	@ 122,03 SAY oSay PROMPT  STR0011 OF oDlg //"Data: 22/03/2004"
	@ 134,03 BUTTON oBtnEmp CAPTION  STR0022 + "/" + STR0023 + cEmpresa + "/" + cFilial ACTION ChangeEmp(oSayFile, oMeterFiles, nMeterFiles, oBtnEmp) OF oDlg
	@ 147,03 SAY oSay PROMPT  STR0024 OF oDlg
EndIf

HideControl(oSayFile)
HideControl(oMeterFiles)

ACTIVATE DIALOG oDlg

Return nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Senha()             ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tela de Login do SFA              	 			          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function Senha(aEmp)
Local cSenha      := Space(8)
Local lValid      := .F.
Local nMeterFiles := 0, nCol := 37
Local oDlgSenha,oBtnSenha
Local oSay,oGet, oCodVend, oNomeVend, oSayFile, oMeterFiles
Local oCboEmp
Local aSenhaObj   := {}
Local nTimes      := 3
Local nTry        := 1
Local nEmp        := 1
Local cCodVend    := ""
Local cNomeVend   := ""
Local cMeter      := ""
Local aEmp2       := {}           


If !Empty(cEmpresa)
	ChoiceEmp(aEmp, nEmp, aSenhaObj)
	cCodVend    := HA3->HA3_COD
	cNomeVend   := HA3->HA3_NREDUZ
EndIf
//Redimensiona o label caso o idioma seja Ingl. ou Espanhol
If Substr(STR0017,1,5) <> "Senha"
	nCol:=10
Endif
DEFINE DIALOG oDlgSenha TITLE STR0014 //"Senha do Usuario"
@ 18,05 SAY oSay PROMPT  "Sales Force Automation - CRM" BOLD OF oDlgSenha

@ 60,10 SAY oSay PROMPT  STR0015 BOLD OF oDlgSenha //"Vendedor :"
aAdd(aSenhaObj, {oSay}) //(1)
@ 60,65  GET oNomeVend VAR cNomeVend SIZE 50,15 READONLY NO UNDERLINE OF oDlgSenha //HA3->HA3_NREDUZ
aAdd(aSenhaObj, {oNomeVend})  /// Nome do Vendedor (2)
@ 78,10  SAY oSay PROMPT  STR0016 BOLD  OF oDlgSenha //"Código: "
aAdd(aSenhaObj, {oSay}) //(3)
@ 78,65  GET oCodVend VAR cCodVend SIZE 50,15 READONLY NO UNDERLINE OF oDlgSenha //;HA3->HA3_COD
aAdd(aSenhaObj, {oCodVend}) // Codigo do Vendedor (4)
@ 96,10 SAY oSay PROMPT  STR0017 BOLD OF oDlgSenha //"Senha :"
aAdd(aSenhaObj, {oSay}) //(5)
@ 96,65 GET oGet VAR cSenha PASSWORD OF oDlgSenha
aAdd(aSenhaObj, {oGet}) //(6)
@ 109,10 GET oSayFile VAR cMeter READONLY NO UNDERLINE SIZE 120,15 OF oDlgSenha
aAdd(aSenhaObj, {oSayFile}) //(7)
@ 120,10 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 OF oDlgSenha
aAdd(aSenhaObj, {oMeterFiles}) //(8)
If lNotTouch
	@ 135,80 BUTTON oBtnSenha CAPTION STR0018  ACTION VldSenha(cSenha, nTry, nTimes, oSayFile, oMeterFiles, nMeterFiles) SIZE 50,17 OF oDlgSenha //"Avançar"
	aAdd(aSenhaObj, {oBtnSenha}) //(9)
	@ 135,02 SAY oSay PROMPT  STR0024 OF oDlgSenha // "Microsiga Intelligence S/A"
	aAdd(aSenhaObj, {oSay}) //(10)
Else
	@ 130,60 BUTTON oBtnSenha CAPTION STR0018  ACTION VldSenha(cSenha, nTry, nTimes, oSayFile, oMeterFiles, nMeterFiles) SIZE 50,17 OF oDlgSenha //"Avançar"
	aAdd(aSenhaObj, {oBtnSenha}) //(9)
	@ 150,02 SAY oSay PROMPT  STR0024 OF oDlgSenha // "Microsiga Intelligence S/A"
	aAdd(aSenhaObj, {oSay}) //(10)	
EndIf

If Len(aEmp) > 1
	@ 37,10  SAY oSay PROMPT  STR0022 BOLD OF oDlgSenha //"Empresa :"
	@ 37,60 COMBOBOX oCboEmp VAR nEmp ITEMS aEmp ACTION ChoiceEmp(aEmp, nEmp, aSenhaObj) SIZE 80,30 OF oDlgSenha
Else
	@ 37,10  SAY oSay PROMPT  STR0022 BOLD OF oDlgSenha //"Empresa :"
	@ 37,60  SAY oSay PROMPT aEmp[1] OF oDlgSenha
EndIf

If Empty(cEmpresa)
	For ni := 1 To Len(aSenhaObj)
		HideControl(aSenhaObj[ni,1])
	Next
Else
	HideControl(oSayFile)
	HideControl(oMeterFiles)
	SetFocus(oGet)
EndIf

	ACTIVATE DIALOG oDlgSenha

Return AllTrim(cSenha) == AllTrim(HA3->HA3_SENHA)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ MsgVendedor()       ³Autor: Paulo Amaral  ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tela das Mensagens Iniciais para o vendedor                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function MsgVendedor()
Local oDlg, oGet, oBtn//, cMsgEmp, cMsgVend,
Local cVend := ""
dbSelectArea("HA3")
dbSeek(RetFilial("HA3"))
//dbGoTop()
cVend := Alltrim(HA3->HA3_NREDUZ) + STR0019 //", favor verificar se há novas mensagens para você no menu Principal, opção Mensagem."
//cMsgEmp  := HA3->HA3_MSGEMP
//cMsgVend := HA3->HA3_MSGVEN

DEFINE DIALOG oDlg TITLE STR0020 //"Mensagens"

//@ 22,2 TO 72,155 CAPTION "Mensagem da Empresa" OF oDlg
//@ 27,5 GET oGet VAR cMsgEmp MULTILINE READONLY VSCROLL NO UNDERLINE SIZE 145,50 OF oDlg
@ 27,5 GET oGet VAR cVend MULTILINE READONLY VSCROLL NO UNDERLINE SIZE 145,80 OF oDlg

//@ 82,2 TO 132,155 CAPTION "Mensagem para o Vendedor:" OF oDlg
//@ 87,5 GET oGet VAR cMsgVend MULTILINE READONLY VSCROLL NO UNDERLINE SIZE 145,50 OF oDlg

@ 138,48 BUTTON oBtn CAPTION STR0018  ACTION CloseDialog() SIZE 65,17 OF oDlg //"Avançar"

ACTIVATE DIALOG oDlg

Return Nil
          

// Verifica a Utilizacao do Prefixo na Consulta de Produtos
Function SetPrefix(aPrdPrefix)
Local cPrdPrefix := ""
Local cPrefix := ""
Local nPos := 0
Local nPreTimes := 0
Local nPreLen := 0

dbSelectArea("HCF")
dbSetorder(1)
If dbSeek(RetFilial("HCF") + "MV_SFPROPR")
	cPrdPrefix := AllTrim(HCF->HCF_VALOR)
	cPrdPrefix += ","

	// Parametro 1 = Prefixo
	nPos := At(",", cPrdPrefix)
	cPrefix := SubStr(cPrdPrefix, 1 , nPos - 1)
	cPrdPrefix := SubStr(cPrdPrefix, nPos + 1, Len(cPrdPrefix))
	
	// Parametro 2 = Numero de Vezes
	nPos := At(",", cPrdPrefix)
	nPreTimes := Val(SubStr(cPrdPrefix, 1 , nPos - 1))
	cPrdPrefix := SubStr(cPrdPrefix, nPos + 1, Len(cPrdPrefix))
	
	// Parametro 3 = tamanho maximo da string
	nPos := At(",", cPrdPrefix)
	nPreLen := Val(SubStr(cPrdPrefix, 1 , nPos - 1))

	aAdd(aPrdPrefix, {cPrefix, nPreTimes, nPreLen})
Else
	aAdd(aPrdPrefix, {"", "", ""})
Endif

Return nil
