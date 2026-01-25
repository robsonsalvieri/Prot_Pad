#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "GPEA960.CH"
#INCLUDE "FWMVCDEF.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} GPEA960
@type			function
@description	Programa de inicialização do Relatório DCTFWEB
@author			lidio.oliveira
@since			20/01/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Function GPEA960()

	//Verifica se a tabela RU0 existe no ambiente
	If !FWAliasInDic("RU0")
		MsgAlert( STR0001, STR0002 ) //"Tabela RU0 não disponível, execute o UPDDISTR da expedição contínua RH para a criação da tabela."
		Return
	EndIf

	//Exibe alerta sobre preenchimento da S038
	fMsgS038()

	//Abre o app do painel de conferência
	FWCallApp( "GPEA960" )

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl
@type			function
@description	Bloco de código que receberá as chamadas JavaScript.
@author			lidio.oliveira
@since			20/01/2023
@version		1.0
/*/
//---------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel, cType, cContent )

	Local cContext 		:= ""
	Local cIsTAFFull	:= "true"
	Local cJsonCompany  := ""
	Local lMiddleware	:= SuperGetMv("MV_MID",,.F.)

	//Ajuste o contexto do relatório quando for um cliente usuário do middleware
	If lMiddleware
		cContext := "gpe"
		cIsTAFFull := "false"
	EndIf

	If cType == "preLoad"
		cJsonCompany := '{ "company_code" : "' + FWGrpCompany() + '", "branch_code" : "' + FWCodFil() + '" }'
		cJsonContext := '{ "context" : "' + cContext + '" }'
		cJsonTAFFull := '{ "tafFull" : "' + cIsTAFFull + '" }'

		oWebChannel:AdvPLToJS( "setCompany", cJsonCompany )
		oWebChannel:AdvPLToJS( "setContext", cJsonContext )
		oWebChannel:AdvPLToJS( "setlIsTafFull", cJsonTAFFull )
	EndIf
	
Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} fMsgS038
@type			function
@description	Função para exibição de alerta sobre preenchimento da tabela S038.
@author  		lidio.oliveira
@since   		13/03/2023
@version		1.0
/*/
//-------------------------------------------------------------------
Static Function fMsgS038()

	Local oButton1
	Local oButton2
	Local oCheckBo1
	Local lCheckBo1 := .F.
	Local oGroup1
	Local oPanel1
	Local oSay1
	//Local oSay2
	Local cSession	:= "AvisoS038"
	Local lChkMsg 	:= fwGetProfString(cSession, "MSG_S038_" + cUserName, '', .T.) == ""
	Local cLink038	:= "https://centraldeatendimento.totvs.com/hc/pt-br/articles/13008616340887"

	Static oDlgS038

	If lChkMsg
		DEFINE MSDIALOG oDlgS038 TITLE OemToAnsi(STR0003) FROM 000, 000  TO 250, 550 COLORS 0, 16777215 PIXEL //#STR0003 = "Painel de Conferência INSS Patronal"

			@ 000, 000 MSPANEL oPanel1 SIZE 350, 250 OF oDlgS038 COLORS 0, 16777215 RAISED
			@ 005, 012 GROUP oGroup1 TO 105, 257 PROMPT OemToAnsi(STR0002) OF oPanel1 COLOR 0, 16777215 PIXEL //#STR0002 = "Atenção"

			@ 022, 017 SAY oSay1 PROMPT OemToAnsi(STR0004) SIZE 275, 075 OF oPanel1 COLORS 0, 16777215 PIXEL //#STR0004 = "Para conferência dos valores de terceiros verifique a tabela S038 (Outras Entidades) onde as"
			@ 032, 017 SAY oSay1 PROMPT OemToAnsi(STR0005) SIZE 275, 075 OF oPanel1 COLORS 0, 16777215 PIXEL //#STR0005 = "alíquotas de contribuição devem estar preenchidas de acordo com o % de cada entidade."
			@ 042, 017 SAY oSay1 PROMPT OemToAnsi(STR0006) SIZE 275, 075 OF oPanel1 COLORS 0, 16777215 PIXEL //#STR0006 = "O cálculo de folha deve ter sido executado conforme exemplo de preenchimento disponível no"
			@ 052, 017 SAY oSay1 PROMPT OemToAnsi(STR0007) SIZE 275, 075 OF oPanel1 COLORS 0, 16777215 PIXEL //#STR0007 = "link abaixo. Clique para Conferir."
			@ 080, 017 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT OEMToAnsi(STR0008) SIZE 067, 008 OF oPanel1 COLORS 0, 16777215 PIXEL //#STR0008 = "Não exibir novamente"
			@ 080, 160 BUTTON oButton1 PROMPT OemToAnsi(STR0010) SIZE 037, 012 OF oPanel1 PIXEL //STR0010 = "Abrir Link"
			@ 080, 200 BUTTON oButton2 PROMPT OemToAnsi(STR0009) SIZE 037, 012 OF oPanel1 PIXEL //#STR0009 = "OK"

			oButton1:bLClicked := {|| ShellExecute("open",cLink038,"","",1) }
			oButton2:bLClicked := {|| oDlgS038:End() }

		ACTIVATE MSDIALOG oDlgS038 CENTERED

		If lCheckBo1
			fwWriteProfString(cSession, "MSG_S038_" + cUserName, 'CHECKED', .T.)
		Endif

	Endif

Return
