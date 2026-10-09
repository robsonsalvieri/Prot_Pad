#include "Protheus.ch"
#include "GCTMSGEXPROT.CH"

/*/{Protheus.doc} MsgEndRot
	Apresenta tela informando que a rotina será descontinuada
	@type  Function
	@author Jose Renato Silva Dourado de Souza jose.souza2
	@since 08/11/2021
	@version 1.0
	@param cExpirFunc, caracter, nome da rotina que deve ser descontinuada
	@param cDescrFunc, caracter, descrição da rotina e nome da rotina que substitui a rotina descontinuada
	@param cExpiraData, caracter, data de experiração a ser informada deve estar no formato AAAAMMDD
	@param cEndWeb, caracter, endereço http referente a rotina que esta sendo descontinuada
/*/
Function MsgEndRot(cExpirFunc as character, cDescrFunc as character, cEndWeb as character, cExpiraData as character, nPauseDays as numeric)
	Local dDate      as date
	Local oProfile   as object
	Local aLoad      as array
	Local cShow      as character
	Local lCheck     as logical

	// Data de expiração da rotina
	DEFAULT cExpiraData := "20220404"

	// Número de dias que pode ser desabilitada a mensagem
	DEFAULT nPauseDays := 7

	dDate := Date()
	oProfile := FwProFile():New()
	oProfile:SetTask("GCTExpired") //Nome da sesso
	oProfile:SetType(cExpirFunc) //Valor
	aLoad := oProfile:Load()
	If Empty(aLoad)
		cShow := "00000000"
	Else
		cShow := aLoad[1]
	Endif

	// Reseta o controle de nPauseDays dias e volta apresentar a tela de advertencia
	If cShow <> "00000000" .And. SToD(cShow) + nPauseDays <= dDate
		cShow := "00000000"
		oProfile:SetProfile({cShow})
		oProfile:Save()
	ENDIF

	If cShow == "00000000"
		lCheck := DlgEndRot(cExpiraData, nPauseDays, cDescrFunc, cEndWeb,cExpirFunc)

		If lCheck
			cShow := DToS(Date())
			oProfile:SetProfile({cShow})
			oProfile:Save()
		EndIf

	EndIf

	oProfile:Destroy()
	oProfile := nil
	aLoad := aSize(aLoad,0)
	aLoad := nil

Return

/*/{Protheus.doc} DlgEndRot
	Apresenta tela informando que a rotina será descontinuada
	@type  Function
	@author Jose Renato Silva Dourado de Souza jose.souza2
	@since 08/11/2021
	@version 1.0
	@param cExpiraData, caracter, data de experiração a ser informada deve estar no formato AAAAMMDD
	@param nPauseDays, numeric, numero de dias que a mensagem pode ser ocultada
	@param cDescrFunc, caracter, descricão da rotina e nome da rotina que substitui a rotina descontinuada
	@param cEndWeb, caracter, endereço http referente a rotina que esta sendo descontinuada
	@param cExpirFunc, caracter, nome da rotina que deve ser descontinuada
	@return lCheck, logico, Verdadeiro se foi escolhido para desabilitar a mensagem por 07 dias
/*/
Static Function DlgEndRot(cExpiraData as character, nPauseDays as numeric, cDescrFunc as character, cEndWeb as character, cExpirFunc as character)
	Local oSay1		as object
	Local oSay2		as object
	Local oSay3		as object
	Local oSay4		as object
	Local oCheck1	as object
	Local oModal	as object
	Local cMsg1		as character
	Local cMsg2		as character
	Local cMsg3		as character
	Local cMsg4		as character
	Local cSTR1		as character
	Local cSTR2		as character
	Local lCheck	as logical
	Local lRotinExp	as logical

	cSTR1 := ""
	cSTR2 := ""
	cMsg3 := STR0005 // "Para maiores informações, favor contatar o administrador do sistema ou seu ESN TOTVS."
	lCheck := .F.

	lRotinExp := Date() >= Stod(cExpiraData)

	Do Case
		Case cExpirFunc == "CNTA120"
			cSTR1	:= IIF(lRotinExp,STR0010,STR0003) // "Esta rotina foi descontinuada e teve sua manutenção encerrada em 04/04/2022. Sua utilização será bloqueada a partir de 01/08/2022, a partir do release 12.1.33" # "Esta rotina será descontinuada e terá sua manutenção encerrada em 04/04/2022. Sua utilização será bloqueada a partir de 01/08/2022, a partir da release 12.1.33"                                                                                                                                                                                                                                                                                                                                                   
			cSTR2	:= IIF(lRotinExp,STR0011,STR0004) // "A rotina que a substituiu é a Nova Medição(CNTA121), já disponível em nosso produto." # "A rotina que a substituirá é a Nova Medição(CNTA121), já disponível em nosso produto."                                                                                                                                                                                                                                                                                                                                                                                                                             
			
		Case cExpirFunc == "CNTA170"
			cSTR1	:= IIF(lRotinExp,STR0014,STR0012) // "Esta rotina foi descontinuada e teve sua manutenção encerrada em 07/04/2025. Sua utilização sera bloqueada a partir de 07/04/025, a partir do release 12.1.2410" # "Esta rotina será descontinuada e terá sua manutenção encerrada em 07/04/2025. Sua utilização sera bloqueada a partir de 07/04/2025, a partir do release 12.1.2410"                                                                                                                                                                                                                                                                                                                                                 
			cSTR2	:= IIF(lRotinExp,STR0015,STR0013) // "A rotina que a substituiu é a Documentos(CNTA171), já disponível em nosso produto" # "A rotina que a substituirá é a Documentos(CNTA171), já disponível em nosso produto."
			
		Case cExpirFunc $ "CNTR010|CNTR020|CNTR030|CNTR031|CNTR040|CNTR050|CNTR121|CNTR300"
			cSTR1	:= Alltrim(STR0016) // "Com a missão de aumentar a capacidade competitiva de seus clientes, a TOTVS vem constantemente trabalhando na evolução funcional e tecnológica de seus produtos e, por esse motivo, comunicamos que este relatório foi descontinuado em <i>31/10/2024</i>, a partir da release 12.1.2410 e terá o uso bloqueado no release 12.1.2510<br/><br/> a partir do dia #1."
			cSTR2	:= Alltrim(STR0017) // "O código fonte deste relatório está disponível para download no Portal do Cliente TOTVS (utilizar o campo Categoria com a opção Programa Fonte de Relatório)."
			cMsg3 	:= Alltrim(STR0020) // "Indicamos a utilização da nova ferramenta para extração de dados do ERP, o Smart View. Clique no link abaixo e conheça todos os detalhes dessa <b>poderosa ferramenta</b>!" 

		Case cExpirFunc == "GCTSCHED"	
			cSTR1	:= Alltrim(STR0018)// "Foi identificado que o parâmetro MV_CNSCHED, utilizado para o alerta de vencimento de contratos, encontra-se configurado de forma incorreta. Comunicamos que este parâmetro será descontinuado a partir da release 12.1.2610 e nas versões posteriores. "
			cSTR2	:= Alltrim(STR0019)// "A rotina que a substituiu é a #1 e já está disponível em nosso produto."
	EndCase

	If !Empty(cSTR1) .And. !Empty(cSTR2)
		oModal := FWDialogModal():New()
		oModal:SetCloseButton( .F. )
		oModal:SetEscClose( .F. )
		oModal:SetTitle(STR0001) //"Comunicado Ciclo de Vida de Sofware - TOTVS Linha Protheus"

		//Define a altura e largura da janela em pixel
		oModal:setSize(180, 250)

		oModal:createDialog()

		oModal:AddButton( STR0002, {||oModal:DeActivate()}, STR0002, , .T., .F., .T., )

		oContainer := TPanel():New( ,,, oModal:getPanelMain() )
		oContainer:Align := CONTROL_ALIGN_ALLCLIENT

		cMsg1	:= i18n(cSTR1,{cValToChar(SToD(cExpiraData))})
		cMsg2	:= i18n(cSTR2, {cDescrFunc} )

		oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,220,40,,,,,,.T.)
		oSay2 := TSay():New( 50,10,{||cMsg2 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
		oSay3 := TSay():New( 70,10,{||cMsg3 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)

		If ! Empty(cEndWeb)

			cMsg4 := "<b>Link: <u><a target='_blank' href='"+cEndWeb+"'> " + cEndWeb + ".</a></u></b>"
			cMsg4 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;' >" + ' ' +"</span>"

			oSay4 := TSay():New( 90,10,{||cMsg4 },oContainer,,,,,,.T.,,,220,20,,,,,,.T.)
			oSay4:bLClicked := {|| MsgRun( STR0008, "URL",{|| ShellExecute("open",cEndWeb,"","",1) } ) } // "Abrindo o link... Aguarde..."
		EndIf

		oCheck1 := TCheckBox():New(110,10,i18n(STR0009,{strzero(nPauseDays,2)}) ,{|x|If(Pcount()==0,lCheck,lCheck:=x)},oContainer,220,21,,,,,,,,.T.,,,) // "Não apresentar esta mensagem nos proximos [07] dias."

		oModal:Activate()
	EndIf

Return lCheck
