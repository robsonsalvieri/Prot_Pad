#include "Protheus.ch"
#include "ESTMSGEXPROT.CH"

/*/{Protheus.doc} MsgExpRot
	Apresenta uma tela informando que a rotina sera descontinuada
	@type  Function
	@author reynaldo
	@since 30/06/2021
	@version 1.0
	@param cExpirFunc, caracter, nome da rotina que deve ser descontinuada
	@param cDescrFunc, caracter, descricaod a rotina e nome da rotina que substitui a rotina descontinuada
	@param cExpiraData, caracter, data de experira??o a ser informada deve estar no formato AAAAMMDD
	@param cEndWeb, caracter, endere?o http referente a rotina que esta sendo descontinuada
/*/
Function MsgExpRot(cExpirFunc as character, cDescrFunc as character, cEndWeb as character, cExpiraData as character, nPauseDays as numeric, cBlocData as character, lTReport as logical, lMsgBlock as logical)
Local dDate      as date
Local oProfile   as object
Local aLoad      as array
Local cShow      as character
Local lCheck     as logical

Default lTReport := .F.

//
// Data de expiração da rotina
//
DEFAULT cExpiraData := "20220404"

//
// numero de dias que pode ser desabilitada a mensagem
//
DEFAULT nPauseDays := 30

//Data a partir da qual a rotina está bloqueada
Default cBlocData := '20220801'

// Exibe ou nao texto informando que a rotina sera/foi bloqueada a partir da data de bloqueio
Default lMsgBlock := .T.

dDate := Date()
oProfile := FwProFile():New()
oProfile:SetTask("ESTExpired") //Nome da sess?o
oProfile:SetType(cExpirFunc) //Valor
aLoad := oProfile:Load()
If Empty(aLoad)
	cShow := "00000000"
Else
	cShow := aLoad[1]
Endif

// reseta o controle de nPauseDays dias e volta apresentar a tela de advertencia
If cShow <> "00000000" .and. STOD(cShow) + nPauseDays <= dDate
	cShow := "00000000"
	oProfile:SetProfile({cShow})
	oProfile:Save()
ENDIF

If cShow == "00000000"
	lCheck := DlgExpRot(cExpiraData, nPauseDays, cDescrFunc, cEndWeb, cBlocData, lTReport, lMsgBlock, cExpirFunc)

	If lCheck
		cShow := dtos(date())
		oProfile:SetProfile({cShow})
		oProfile:Save()
	EndIf

EndIf

oProfile:Destroy()
oProfile := nil
aLoad := aSize(aLoad,0)
aLoad := nil

RETURN

/*/{Protheus.doc} DlgExpRot
	Apresenta uma tela informando que a rotina sera descontinuada
	@type  Function
	@author reynaldo
	@since 30/06/2021
	@version 1.0
	@param cExpiraData, caracter, data de experiração a ser informada deve estar no formato AAAAMMDD
	@param nPauseDays, numeric, numero de dias que a mensagem pode ser ocultada
	@param cDescrFunc, caracter, descricaod a rotina e nome da rotina que substitui a rotina descontinuada
	@param cEndWeb, caracter, endere?o http referente a rotina que esta sendo descontinuada
	@return lCheck, logico, Verdadeiro se foi escolhido para desabilitar a mensagem por 3O dias
/*/
Static Function DlgExpRot(cExpiraData as character, nPauseDays as numeric, cDescrFunc as character, cEndWeb as character, cBlocData as character, lTReport as logical, lMsgBlock as logical, cExpirFunc as character)
local oSay1    as object
local oSay2    as object
local oSay3    as object
local oSay4    as object
local oSay5    as object
local oCheck1  as object
local oModal   as object
Local cMsg1    as character
Local cMsg2    as character
Local cMsg3    as character
Local cMsg4    as character
Local cMsg5    as character
Local cRelease as character
Local cMsgRel  as character
Local lCheck   as logical
Local nPosLine as numeric
Local bLine    as block

cRelease := GetRPORelease() 

If cExpirFunc == "MATA280"
	cMsgRel := "12.1.2210."
Else
	If cExpirFunc == "MATA045"
		cMsgRel := "12.1.2410."
	Else
		cMsgRel := "12.1.33."
	EndIf
EndIf


oModal := FWDialogModal():New()
oModal:SetCloseButton( .F. )
oModal:SetEscClose( .F. )
oModal:setTitle(STR0001) //"Comunicado Ciclo de Vida de Sofware - TOTVS Linha Protheus"

//define a altura e largura da janela em pixel
oModal:setSize(180, 250)

oModal:createDialog()

oModal:AddButton( STR0002, {||oModal:DeActivate()}, STR0002, , .T., .F., .T., )

oContainer := TPanel():New( ,,, oModal:getPanelMain() )
oContainer:Align := CONTROL_ALIGN_ALLCLIENT
If DToS(Date()) < cExpiraData
	cMsg1 := i18n(If(lTReport,STR0013,STR0003),{cValToChar(stod(cExpiraData))}) // "Esta rotina será descontinuada e terá sua manutenção encerrada em #1[04/04/2022]#."
Else
	If cExpirFunc == "MATA280"
		cMsg1 := i18n(STR0018,{cValToChar(stod(cExpiraData))}) // "Esta rotina foi descontinuada e sua interface ADVPL teve a manutenção encerrada em #1[04/04/2022]#."
	Else
		cMsg1 := i18n(If(lTReport,STR0016,STR0011),{cValToChar(stod(cExpiraData))}) // "Esta rotina foi descontinuada e teve sua manutenção encerrada em #1[04/04/2022]#."
	EndIf
EndIf
If cExpirFunc != "MATA045"
	If lMsgBlock
		If cRelease != '12.1.027' .And. DToS(Date()) >= cBlocData
			cMsg5 := i18n(STR0012,{cValToChar(stod(cBlocData))}) + cMsgRel //"Sua utilização foi bloqueada a partir de #1[01/08/2022]#, a partir da release 12.1.33"
		Else
			cMsg5 := i18n(STR0010,{cValToChar(stod(cBlocData))}) + cMsgRel //"Sua utilização será bloqueada a partir de #1[01/08/2022]#, a partir da release 12.1.33"
		EndIf
	EndIf
EndIf
If lTReport
	cMsg2 := If(DToS(Date()) < cExpiraData,STR0014,STR0017)
Else
	cMsg2 := i18n(STR0004, {cDescrFunc} ) //"A rotina que a substituirá é a #1[Movimentação Múltipla(MATA241)]#, já disponivel em nosso produto."
EndIf
cMsg4 := STR0005 //"Para maiores informações, favor contatar o administrador do sistema ou seu ESN TOTVS.",)

nPosLine := 10
bLine := {|| nPosLine += 20}
oSay1 := TSay():New(nPosLine,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
If cExpirFunc != "MATA045"
	If lMsgBlock
		If !lTReport
			oSay5 := TSay():New(Eval(bLine),10,{||cMsg5 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
		EndIf
	EndIf
EndIf
oSay2 := TSay():New(Eval(bLine),10,{||cMsg2 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

cMsg3 := If(lTReport,Alltrim(STR0015),AllTrim(STR0006))+space(01) // "Para conhecer mais sobre a convergência entre essas rotinas, "
If ! Empty(cEndWeb)
	cMsg3 += "<b><a target='_blank' href='"+cEndWeb+"'> "
	cMsg3 += Alltrim(STR0007) // "clique aqui"
	cMsg3 += " </a></b>."
	cMsg3 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"
	oSay3 := TSay():New(Eval(bLine),10,{||cMsg3},oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
	oSay3:bLClicked := {|| MsgRun( STR0008, "URL",{|| ShellExecute("open",cEndWeb,"","",1) } ) } // "Abrindo o link... Aguarde..."
EndIf
oSay4 := TSay():New(Eval(bLine),10,{||cMsg4 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

lCheck := .F.
If cExpirFunc == "MATA045"
	oCheck1 := TCheckBox():New(110,10,i18n(STR0019) ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,220,21,,,,,,,,.T.,,,) // "Não apresentar esta mensagem no mês atual."
Else
	oCheck1 := TCheckBox():New(110,10,i18n(STR0009,{strzero(nPauseDays,2)}) ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,220,21,,,,,,,,.T.,,,) // "Não apresentar esta mensagem nos próximos #1[30]# dias."
EndIf
oModal:Activate()

Return lCheck

