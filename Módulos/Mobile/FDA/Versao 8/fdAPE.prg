#include "eADVPL.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SfaPE()             ³Autor: Marcelo Vieira³ Data ³ 01.07.03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo Principal do SFA PE Pronta Entrega                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function SFAPE()
Local oDlg, oMnu
Local oItem,oSay
Local lSenha   := .T.
Local cProd    := ""
Local cEmpNome := ""
Local nMeterFiles := 0
Local oSayFile, oMeterFiles
SET DATE BRITISH 
SET DELETE ON

Public cEmpresa := "" 
Public cFilial  := ""
PUBLIC nLastProd := 0
PUBLIC nI:=0   
//Arrays e variaveis usadas na tela de produtos
Public aProduto := {}
Public cUltGrupo:= ""
Public aGrupo := {}, nGrupo := 1
Public cCalcProtheus := ""
Public nPagProd := 0
Public nRecEst:=0

If !OpenEmp(@cEmpNome)
	Return .F.
EndIf

If !Senha()
	Return Nil
EndIf

CtrFaixa()


DEFINE DIALOG oDlg TITLE "Fast Delivery Automation"

ADD MENUBAR oMnu CAPTION "Principal" OF oDlg
ADD MENUITEM oItem CAPTION "Visitas de Negócios" ACTION VisitaNegocio() OF oMnu
ADD MENUITEM oItem CAPTION "Fechamento do Dia" ACTION FechamentoDia() OF oMnu
ADD MENUITEM oItem CAPTION "Cons. Produtos" ACTION GetProduto(cProd) of oMnu
ADD MENUITEM oItem CAPTION "Clientes" ACTION InitCliente() OF oMnu
ADD MENUITEM oItem CAPTION "Mensagem" ACTION InitMensagem() OF oMnu
ADD MENUITEM oItem CAPTION "Acerto de contas" ACTION alert("Confirma acerto de contas") OF oMnu
ADD MENUITEM oItem CAPTION "Parametros" ACTION InitParam() OF oMnu
ADD MENUITEM oItem CAPTION "Sync" ACTION InitSync(oSayFile, oMeterFiles, nMeterFiles) OF oMnu
ADD MENUITEM oItem CAPTION "Sair" ACTION CloseDialog() OF oMnu
@ 45,40 SAY cEmpNome BOLD LARGE COLOR 0,2 OF oDlg
@ 75,30 SAY "Fast Delivery Automation" BOLD LARGE COLOR 0,2  OF oDlg

#ifdef __PALM__
	@ 90,51 SAY "for PalmOS" OF oDlg
#else
	@ 90,51 SAY "for PocketPC" OF oDlg
#endif

@ 96,20  SAY oSayFile PROMPT "" OF oDlg
@ 108,20 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 OF oDlg

@ 117,03 SAY oSay PROMPT  "Versão 7.0.0" OF oDlg
@ 127,03 SAY oSay PROMPT  "Data: 21/11/2003" OF oDlg
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
@ 21,05  SAY oSay PROMPT  "FDA - Fast Delivery Automation" BOLD COLOR 0,2 OF oDlgSenha
@ 41,19  SAY oSay PROMPT  "Vendedor :" BOLD OF oDlgSenha
@ 41,75  SAY oSay PROMPT  HA3->HA3_NREDUZ OF oDlgSenha
@ 61,37  SAY oSay PROMPT  "Código: " BOLD  OF oDlgSenha
@ 61,75  SAY oSay PROMPT  HA3->HA3_COD OF oDlgSenha
@ 81,38  SAY oSay PROMPT  "Senha :" BOLD OF oDlgSenha
@ 81,75  GET oGet VAR cSenha PASSWORD OF oDlgSenha
@ 96,20  SAY oSayFile PROMPT "" OF oDlgSenha
@ 108,20 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 OF oDlgSenha
@ 121,54 BUTTON oBtnSenha CAPTION "Avançar"  ACTION VldSenha(cSenha, nTry, nTimes, oSayFile, oMeterFiles, nMeterFiles) SIZE 65,17 OF oDlgSenha
@ 143,06 SAY oSay PROMPT  "Microsiga Software S/A" COLOR 0,2 OF oDlgSenha

SetFocus(oGet)
HideControl(oSayFile)
HideControl(oMeterFiles)
ACTIVATE DIALOG oDlgSenha

Return AllTrim(cSenha) == AllTrim(HA3->HA3_SENHA)

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

