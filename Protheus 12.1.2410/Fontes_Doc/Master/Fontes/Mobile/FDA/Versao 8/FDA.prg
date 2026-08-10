#include "eADVPL.ch"
#include "FDA.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ SfaPE()             ³Autor: Marcelo Vieira³ Data ³ 01.07.03³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Modulo Principal do SFA PE Pronta Entrega                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function FDA()
Local oDlg, oMnu
Local oItem,oSay
Local lSenha   := .T.
Local cProd    := ""
Local cEmpNome := ""
Local nMeterFiles := 0
Local oSayFile, oMeterFiles
Local aPrdPrefix := {}
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
Public ddatabase:=Date()
public MV_ESTADO
public MV_ICMPAD
Public MV_NORTE
Public MV_ESTICM                    
Public MV_IPIBRUTO
Public aCabView:={}                         

// Arrays usados para calcular valores dos impostos da nota
Public aFdaCab :={}
Public aFdaItem:={} 

SET DATE BRITISH 
SET DELETE ON

If !OpenEmp(@cEmpNome) .Or. !VrfArquivos()
	InitSync()
	Return .F.
EndIf

If !Senha()
	Return Nil
EndIf

CtrFaixa()
SetPrefix(aPrdPrefix)

DEFINE DIALOG oDlg TITLE "FDA"

ADD MENUBAR oMnu CAPTION STR0001 OF oDlg //"Principal"
ADD MENUITEM oItem CAPTION STR0002 ACTION InitCliente() OF oMnu //"Clientes"
ADD MENUITEM oItem CAPTION STR0003 ACTION GetProduto(cProd,aPrdPrefix) of oMnu //"Cons. Produtos"
ADD MENUITEM oItem CAPTION STR0004 ACTION InitMensagem() OF oMnu //"Mensagem"
ADD MENUITEM oItem CAPTION STR0005 ACTION InitParam() OF oMnu //"Cons. Parametros"
ADD MENUITEM oItem CAPTION STR0006 ACTION CloseDialog() OF oMnu //"Sair"
ADD MENUBAR oMnu CAPTION   STR0007 OF oDlg   //"Diário"
ADD MENUITEM oItem CAPTION STR0008 ACTION VisitaNegocio() OF oMnu //"Visitas de Negócios"
ADD MENUITEM oItem CAPTION STR0009 ACTION FechamentoDia() OF oMnu //"Fechamento do Dia"
ADD MENUITEM oItem CAPTION STR0010 ACTION FDARM001() OF oMnu //"Retorno mercadorias"
ADD MENUITEM oItem CAPTION STR0011 ACTION InitSync(oSayFile, oMeterFiles, nMeterFiles) OF oMnu //"Sync"

@ 45,40 SAY cEmpNome BOLD LARGE OF oDlg

#ifdef __PALM__
    @ 70,15 SAY STR0012 BOLD LARGE OF oDlg //"Fast Delivery Automation"
        @ 85,51 SAY STR0013 OF oDlg //"for PalmOS SI"
#else
    @ 75,05 SAY STR0012 BOLD LARGE OF oDlg //"Fast Delivery Automation"
	@ 90,51 SAY STR0014 OF oDlg //"for PocketPC"
#endif

@ 96,20  SAY oSayFile PROMPT "" OF oDlg
@ 108,20 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 COLOR CLR_WHITE,CLR_HRED OF oDlg

@ 117,03 SAY oSay PROMPT  STR0015+GETVER() OF oDlg //"Versão 7.0."
@ 127,03 SAY oSay PROMPT  STR0016 OF oDlg //"Data: 23/06/2004"
@ 147,03 SAY oSay PROMPT  STR0017 OF oDlg //"Microsiga Intelligence"

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
Local nTimes      := 3
Local nTry        := 1

dbSelectArea("HA3")
dbGoTop()
if HA3->(Eof())
	MsgStop(STR0018,STR0019) //"Vendedor Inválido"###"Acesso"
	Return .F.
endif

//Redimensiona o label caso o idioma seja Ingl. ou Espanhol
If Substr(STR0023,1,5) <> "Senha"
	nCol:=10
Endif

DEFINE DIALOG oDlgSenha TITLE STR0020 //"Senha do Usuario"
@ 21,05   SAY oSay PROMPT  "Fast Delivery Automation" BOLD LARGE OF oDlgSenha
@ 41,19   SAY oSay PROMPT  STR0021 BOLD OF oDlgSenha //"Vendedor :"
@ 41,75   SAY oSay PROMPT  HA3->HA3_NREDUZ OF oDlgSenha
@ 61,37   SAY oSay PROMPT  STR0022 BOLD  OF oDlgSenha //"Código: "
@ 61,75   SAY oSay PROMPT  HA3->HA3_COD OF oDlgSenha
@ 81,nCol SAY oSay PROMPT  STR0023 BOLD OF oDlgSenha //"Senha :"
@ 81,75   GET oGet VAR cSenha PASSWORD OF oDlgSenha
@ 96,20   SAY oSayFile PROMPT "" OF oDlgSenha
@ 108,20  METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 COLOR CLR_WHITE,CLR_HRED OF oDlgSenha
@ 121,54  BUTTON oBtnSenha CAPTION STR0024  ACTION VldSenha(cSenha, nTry, nTimes, oSayFile, oMeterFiles, nMeterFiles) SIZE 65,17 OF oDlgSenha //"Avançar"
@ 143,06  SAY oSay PROMPT  "Microsiga Intelligence" COLOR CLR_HBLUE,1 OF oDlgSenha

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
