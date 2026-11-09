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
Local oItem,oSay
Local lSenha   := .T.
Local cProd    := ""
Local aPrdPrefix := {}
Local nMeterFiles := 0
Local oSayFile, oMeterFiles, oLogo
Local cMeter  := ""
Local cSfaCfg := "1"
Local cSfaDrt := "2"
SET DATE BRITISH 
SET DELETED ON

Public cEmpresa := ""
PUBLIC nLastProd := 0
PUBLIC nI:=0   
//Arrays e variaveis usadas na tela de produtos
Public aProduto := {}
Public cUltGrupo:= ""
Public aGrupo := {}, nGrupo := 1
Public cCalcProtheus := ""
Public nPagProd := 0,  cQtdDec := ""
Public nQtdDec := 0
Public cSfaPeso := "", 	cUmPeso := ""
Public aStatCli	:= {}


// Verifica arquivo de Empresa, arquivos principais e ultimo sincronismo
If !OpenEmp() .Or. !VrfArquivos() .Or. !VrfPerm()
	InitSync()
	Return .F.
EndIf

If !Senha()
	Return Nil
EndIf


CtrFaixa()
MsgVendedor()
SetPrefix(aPrdPrefix)


// Parametro para opcao Config
dbSelectArea("HCF")
dbSetOrder(1)
If dbSeek("MV_SFACFG")
	cSfaCfg := AllTrim(HCF->CF_VALOR)
EndIf


// Parametro para opcao Config
dbSelectArea("HCF")
dbSetOrder(1)
If dbSeek("MV_SFADRT")
	cSfaDrt := AllTrim(HCF->CF_VALOR)
EndIf

// Parametro para definicao de casas decimais
dbSelectArea("HCF")
dbSetOrder(1)
If dbSeek("DECPROTHEUS")
	nQtdDec := Val(AllTrim(HCF->CF_VALOR))
Else
	nQtdDec := 2
EndIf

DEFINE DIALOG oDlg TITLE "SFA-CRM"

ADD MENUBAR oMnu CAPTION STR0001 OF oDlg //"Principal"
ADD MENUITEM oItem CAPTION STR0002 ACTION VisitaNegocio() OF oMnu //"Visitas de Negócios"
ADD MENUITEM oItem CAPTION STR0003 ACTION FechamentoDia() OF oMnu //"Fechamento do Dia"
ADD MENUITEM oItem CAPTION STR0004 ACTION GetProduto(cProd,aPrdPrefix) of oMnu //"Cons. Produtos"
ADD MENUITEM oItem CAPTION "Duplicatas" ACTION StatFinanc() OF oMnu
ADD MENUITEM oItem CAPTION STR0005 ACTION InitCliente() OF oMnu //"Clientes"
ADD MENUITEM oItem CAPTION STR0006 ACTION InitMetas() OF oMnu //"Metas"
ADD MENUITEM oItem CAPTION STR0007 ACTION InitMensagem() OF oMnu //"Mensagem"
If cSfaCfg = "1"
	ADD MENUITEM oItem CAPTION "Config" ACTION InitConfig() OF oMnu
Endif
If cSfaDrt = "1"
	ADD MENUITEM oItem CAPTION STR0021 ACTION DirtyTable() OF oMnu
Endif
ADD MENUITEM oItem CAPTION "Sync" ACTION InitSync(oSayFile, oMeterFiles, nMeterFiles) OF oMnu
ADD MENUITEM oItem CAPTION STR0009 ACTION CloseDialog() OF oMnu //"Sair"

@ 50,20 GET oSayFile VAR cMeter SIZE 120,10 OF oDlg
@ 62,20 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 OF oDlg

//@ 15,42 BUTTON oLogo CAPTION LOGO_SFA SYMBOL OF oDlg

@ 75,50 SAY "SFA-CRM" BOLD LARGE OF oDlg
#ifdef __PALM__

	@ 90,51 SAY "for PalmOS" OF oDlg
#else
	@ 90,51 SAY "for PocketPC" OF oDlg
#endif

@ 117,03 SAY oSay PROMPT  STR0010 + GETVER() OF oDlg //"Versão 6.0.1i"
//@ 117,03 SAY oSay PROMPT  "Versão em Desenvolvimento (nao distribuir)" OF oDlg
@ 127,03 SAY oSay PROMPT  STR0011 OF oDlg //"Data: 22/03/2004"
@ 147,03 SAY oSay PROMPT  "Microsiga Software S/A" OF oDlg

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
Function Senha()
Local cSenha      := Space(8)
Local lValid      := .F.
Local nMeterFiles := 0, nCol := 38
Local oDlgSenha,oBtnSenha
Local oSay,oGet, oSayFile, oMeterFiles
Local cMeter      := ""
Local nTimes      := 3
Local nTry        := 1

dbSelectArea("HA3")
dbGoTop()
if HA3->(Eof())
	MsgStop(STR0012,STR0013) //"Vendedor Inválido"###"Acesso"
	Return .F.
endif

//Redimensiona o label caso o idioma seja Ingl. ou Espanhol
If Substr(STR0017,1,5) <> "Senha"
	nCol:=10
Endif

DEFINE DIALOG oDlgSenha TITLE STR0014 //"Senha do Usuario"
@ 21,05  SAY oSay PROMPT  "Sales Force Automation - CRM" BOLD OF oDlgSenha
@ 41,19  SAY oSay PROMPT  STR0015 BOLD OF oDlgSenha //"Vendedor :"
@ 41,75  SAY oSay PROMPT  HA3->A3_NREDUZ OF oDlgSenha
@ 61,37  SAY oSay PROMPT  STR0016 BOLD  OF oDlgSenha //"Código: "
@ 61,75  SAY oSay PROMPT  HA3->A3_COD OF oDlgSenha
@ 81,nCol SAY oSay PROMPT  STR0017 BOLD OF oDlgSenha //"Senha :"
@ 81,75  GET oGet VAR cSenha PASSWORD OF oDlgSenha
@ 96,20  GET oSayFile VAR cMeter SIZE 120,10 OF oDlgSenha
@ 108,20 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 OF oDlgSenha
@ 121,54 BUTTON oBtnSenha CAPTION STR0018  ACTION VldSenha(cSenha, nTry, nTimes, oSayFile, oMeterFiles, nMeterFiles) SIZE 65,17 OF oDlgSenha //"Avançar"
@ 143,06 SAY oSay PROMPT  "Microsiga Software S/A" OF oDlgSenha

HideControl(oSayFile)
HideControl(oMeterFiles)

SetFocus(oGet)
ACTIVATE DIALOG oDlgSenha


Return AllTrim(cSenha) == AllTrim(HA3->A3_SENHA)


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
dbGoTop()
cVend := Alltrim(HA3->A3_NREDUZ) + STR0019 //", favor verificar se há novas mensagens para você no menu Principal, opção Mensagem."
//cMsgEmp  := HA3->A3_MSGEMP
//cMsgVend := HA3->A3_MSGVEN

DEFINE DIALOG oDlg TITLE STR0020 //"Mensagens"

//@ 22,2 TO 72,155 CAPTION "Mensagem da Empresa" OF oDlg
//@ 27,5 GET oGet VAR cMsgEmp MULTILINE READONLY VSCROLL NO UNDERLINE SIZE 145,50 OF oDlg
@ 27,5 GET oGet VAR cVend MULTILINE READONLY VSCROLL NO UNDERLINE SIZE 145,80 OF oDlg

//@ 82,2 TO 132,155 CAPTION "Mensagem para o Vendedor:" OF oDlg
//@ 87,5 GET oGet VAR cMsgVend MULTILINE READONLY VSCROLL NO UNDERLINE SIZE 145,50 OF oDlg

@ 138,48 BUTTON oBtn CAPTION STR0018  ACTION CloseDialog() SIZE 65,17 OF oDlg //"Avançar"

ACTIVATE DIALOG oDlg

Return Nil