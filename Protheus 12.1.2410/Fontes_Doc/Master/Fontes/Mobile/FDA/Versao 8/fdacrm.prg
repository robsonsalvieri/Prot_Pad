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
SET DATE BRITISH 
SET DELETE ON

Public cEmpresa := ""
PUBLIC nLastProd := 0
PUBLIC nI:=0   
//Arrays e variaveis usadas na tela de produtos
Public aProduto := {}
Public cUltGrupo:= ""
Public aGrupo := {}, nGrupo := 1
Public cCalcProtheus := ""

//Verifica Permissao de Acesso do Usuario pela ultima Sincronizacao
//If !VrfPerm()
//  Return Nil
//EndIf

If !OpenEmp()
	Return .F.
EndIf

If !Senha()
	Return Nil
EndIf

CtrFaixa()
MsgVendedor()
SetPrefix(aPrdPrefix)

DEFINE DIALOG oDlg TITLE "SFA-CRM"

ADD MENUBAR oMnu CAPTION "Principal" OF oDlg
ADD MENUITEM oItem CAPTION "Visitas de Negócios" ACTION VisitaNegocio() OF oMnu
ADD MENUITEM oItem CAPTION "Fechamento do Dia" ACTION FechamentoDia() OF oMnu
ADD MENUITEM oItem CAPTION "Cons. Produtos" ACTION GetProduto(cProd,aPrdPrefix) of oMnu
//ADD MENUITEM oItem CAPTION "Gerencimento do Vendedor" ACTION GerenciaVendas() OF oMnu
ADD MENUITEM oItem CAPTION "Clientes" ACTION InitCliente() OF oMnu
ADD MENUITEM oItem CAPTION "Metas" ACTION InitMetas() OF oMnu
ADD MENUITEM oItem CAPTION "Mensagem" ACTION InitMensagem() OF oMnu
ADD MENUITEM oItem CAPTION "Config" ACTION InitConfig() OF oMnu

//Ponto de Entrada: Novas Funcoes e Telas no SFA CRM
#IFDEF _PEPR0002_                
	//Objetivo: 
	//Retorno: 
	uRet := PEPR0002(oDlg,oMnu)
#ENDIF

ADD MENUITEM oItem CAPTION "Sair" ACTION CloseDialog() OF oMnu

@ 75,50 SAY "SFA-CRM" BOLD LARGE OF oDlg
#ifdef __PALM__
	@ 90,51 SAY "for PalmOS" OF oDlg
#else
	@ 90,51 SAY "for PocketPC" OF oDlg
#endif
//@ 117,03 SAY oSay PROMPT  "Versão 6.0.1d" OF oDlg
@ 117,03 SAY oSay PROMPT  "Versão em Desenvolvimento (nao distribuir)" OF oDlg
@ 127,03 SAY oSay PROMPT  "Data: 27/08/2003" OF oDlg
@ 147,03 SAY oSay PROMPT  "Microsiga Software S/A" OF oDlg

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
Local nMeterFiles := 0
Local oDlgSenha,oBtnSenha
Local oSay,oGet, oSayFile, oMeterFiles
Local nTimes      := 3
Local nTry        := 1

dbSelectArea("HA3")
dbGoTop()
if HA3->(Eof())
	MsgStop("Vendedor Inválido","Acesso")
	Return .F.
endif

DEFINE DIALOG oDlgSenha TITLE "Senha do Usuario"
@ 21,05  SAY oSay PROMPT  "Sales Force Automation - CRM" BOLD OF oDlgSenha
@ 41,19  SAY oSay PROMPT  "Vendedor :" BOLD OF oDlgSenha
@ 41,75  SAY oSay PROMPT  HA3->HA3_NREDUZ OF oDlgSenha
@ 61,37  SAY oSay PROMPT  "Código: " BOLD  OF oDlgSenha
@ 61,75  SAY oSay PROMPT  HA3->HA3_COD OF oDlgSenha
@ 81,38  SAY oSay PROMPT  "Senha :" BOLD OF oDlgSenha
@ 81,75  GET oGet VAR cSenha PASSWORD OF oDlgSenha
@ 96,20  SAY oSayFile PROMPT "" OF oDlgSenha
@ 108,20 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 OF oDlgSenha
@ 121,54 BUTTON oBtnSenha CAPTION "Avançar"  ACTION VldSenha(cSenha, nTry, nTimes, oSayFile, oMeterFiles, nMeterFiles) SIZE 65,17 OF oDlgSenha
@ 143,06 SAY oSay PROMPT  "Microsiga Software S/A" OF oDlgSenha

HideControl(oSayFile)
HideControl(oMeterFiles)

SetFocus(oGet)
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
dbGoTop()
cVend := Alltrim(HA3->HA3_NREDUZ) + ", favor verificar se há novas mensagens para você no menu Principal, opção Mensagem."
//cMsgEmp  := HA3->HA3_MSGEMP
//cMsgVend := HA3->HA3_MSGVEN

DEFINE DIALOG oDlg TITLE "Mensagens"

//@ 22,2 TO 72,155 CAPTION "Mensagem da Empresa" OF oDlg
//@ 27,5 GET oGet VAR cMsgEmp MULTILINE READONLY VSCROLL NO UNDERLINE SIZE 145,50 OF oDlg
@ 27,5 GET oGet VAR cVend MULTILINE READONLY VSCROLL NO UNDERLINE SIZE 145,80 OF oDlg

//@ 82,2 TO 132,155 CAPTION "Mensagem para o Vendedor:" OF oDlg
//@ 87,5 GET oGet VAR cMsgVend MULTILINE READONLY VSCROLL NO UNDERLINE SIZE 145,50 OF oDlg

@ 138,48 BUTTON oBtn CAPTION "Avançar"  ACTION CloseDialog() SIZE 65,17 OF oDlg

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
If dbSeek(RetFilial("HCF")+"MV_SFPROPR")
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