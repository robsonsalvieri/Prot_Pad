#INCLUDE "AGDXHIST.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AGDA020
Rotina de historico de ações nas tabelas do modulo SIGAAGD
@type function
@version P12
@author claudineia.reinert
@since 12/11/2024
/*/
Function AGDXHIST(cTabela,cChave,nSubStr)
	Local oBrowse := NIL
	Local cFil := ""
	Default nSubStr := 0

	If nSubStr > 0
		cFil := "NE0->NE0_TABLE = '"+cTabela+"' .And. SubStr(NE0->NE0_CHAVE,1,"+cValtoChar(nSubStr)+") = '"+cChave+"'"
	else
		cFil := "NE0_TABLE = '"+cTabela+"' .And. NE0_CHAVE = '"+cChave+"'"
	EndIf

	DbSelectArea("NE0")
	oBrowse    := FWMBrowse():New()
	oBrowse:SetAlias('NE0')
	oBrowse:SetDescription(Alltrim(FWX2Nome(cTabela))+" - " + STR0001 ) //#"Histórico"
	oBrowse:SetFilterDefault(cFil)
	oBrowse:DisableDetails()
	oBrowse:SetMenuDef( "AGDXHIST" )
	oBrowse:Activate()

Return Nil

Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002 , "ViewDef.AGDXHIST", 0, 2, 0, Nil } ) //"Visualizar"

Return aRotina

Static Function ModelDef()
	Local oStruNE0 := FWFormStruct( 1, "NE0" )
	Local oModel := MPFormModel():New( "AGDXHIST" )

	oModel:AddFields( 'AGDXHIST_NE0', Nil, oStruNE0 )
	oModel:SetDescription( FWX2Nome("NE0") )

Return oModel

Static Function ViewDef()
	Local oStruNE0 := FWFormStruct( 2, 'NE0' )
	Local oModel   := FWLoadModel( 'AGDXHIST' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NE0', oStruNE0, 'AGDXHIST_NE0' )
	oView:CreateHorizontalBox( 'TELA'  , 100 )
	oView:SetOwnerView( 'VIEW_NE0', 'TELA'   )

Return oView

/*/{Protheus.doc} AGDGRAVAHIS
Função para gravação do historico de ação(NE0) em um registro de uma tabela, podendo exibir ou não uma tela ao usuario antes da gravação
@type function
@version P12.1.2410
@author claudineia.reinert
@since 16/12/2024
@param cTitMsg, character, Titulo da tela 
@param cTabela, character, Codigo da tabela
@param cChave, character, Chave da tabela, dados do indice unico da tabela para posterior uso em filtro dos dados
@param cAcao, character, Ação realizada no registro, campo de texto livre. Ex: INCLUIR / ALTERAR/ EXCLUIR / CONFIRMAR / APROVAR / REJEITAR, ETC..... , 
@param lTela, logical, se apresenta a tela(.T.) ao usuario ou não(.F.)
@param cMsgObs, character, Observação/mensagem para gravação, esta variavel é usada quando não apresenta tela ao usuario, sendo opcional seu preenchimento.
@return Logical, .T. ou .F., Quando grava sem apresentação de tela, ou, quando apresenta a tela e usuario confirma retornará valor .T., caso usuario cancele a tela retornará .F.
/*/
Function AGDGRAVAHIS(cTitMsg,cTabela,cChave,cAcao,lTela,cMsgObs)
	Local aArea    	:= GetArea()
	Local nOpcao   	:= 2
	Local cMsgMemo 	:= TamSX3("NE0_MSGOBS")
	Local cNomUsu  	:= ""
	Local dDate	   	:= dDataBase
	Local oMsg     	:= nil
	Local lRet	   	:= .F.
	Local oModel	:= nil
	Local cTheme	:= ""
	Local lIsDark	:= .F.

	Default cMsgObs := ""
	Default lTela   := .t.

	DbSelectArea("NE0")

	If IsBlind() //sem tela
		lTela := .F.
	EndIf

	If lTela
		cNomUsu := UsrRetName(RetCodUsr())
		cTheme := totvs.framework.css.getNewWebAppTheme()
		lIsDark := iif(!empty(cTheme) .and. cTheme == "DARK", .T., .F.) //Valida se o tema ativo é o dark

		If lIsDark
			oDlg := TDialog():New(350,406,638,795,cTitMsg,,,,,,,,,.T.)
		Else
			oDlg := TDialog():New(350,406,638,795,cTitMsg,,,,,CLR_BLACK,CLR_WHITE,,,.t.)
		EndIf
		oDlg:lEscClose := .f.

		@ 038,008 SAY FWSX3Util():GetDescription('NE0_DATA') PIXEL //"Data"
		@ 038,024 MSGET dDate OF oDlg PIXEL WHEN .f.

		@ 038,076 SAY FWSX3Util():GetDescription('NE0_NOMUSU') PIXEL //"Usuário"
		@ 038,116 MSGET cNomUsu OF oDlg PIXEL WHEN .f.

		@ 058,008 SAY FWSX3Util():GetDescription('NE0_MSGOBS') PIXEL
		@ 070,008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 172,062 PIXEL VALID NaoVazio(cMsgMemo)

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcao := 1, oDlg:End()},{|| nOpcao := 0,oDlg:End()}) CENTERED
	Else
		nOpcao   := 1
		cMsgMemo := cMsgObs
	EndIf

	If nOpcao == 1
		cNomUsu := UsrRetName(RetCodUsr())

		oModel := FwLoadModel('AGDXHIST')
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oNE0 := oModel:GetModel('AGDXHIST_NE0')
		If oModel:Activate()
			oNE0:LoadValue('NE0_FILIAL',	xFilial("NE0") )
			oNE0:LoadValue('NE0_TABLE', 	cTabela )
			oNE0:LoadValue('NE0_CHAVE',		cChave )
			oNE0:LoadValue('NE0_ACAO', 		cAcao )
			oNE0:LoadValue('NE0_DATA', 		dDataBase )
			oNE0:LoadValue('NE0_HORA', 		Time() )
			oNE0:LoadValue('NE0_NOMUSU',	cNomUsu )
			oNE0:LoadValue('NE0_MSGOBS',	cMsgMemo )

			If (lRet := oModel:VldData())
				oModel:CommitData()
				lRet := .T.
			Else
				lRet := .F.
			Endif
		Else
			lRet := .F.
		Endif

	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGDXHISTGM
Interface para o usuario definir a mensagem que sera gravada na tabela de histórico
@type function
@version 12
@author jc.maldonado
@since 05/06/2025
@return character, mensagem digitada pelo usuário
/*/
Function AGDXHISTGM(cTitMsg)
	Local oDlg     := nil
	Local cTheme   := totvs.framework.css.getNewWebAppTheme()
	Local dDate	   := dDataBase
	Local cNomUsu  := UsrRetName(RetCodUsr())
	Local oMsg     := nil
	Local cMsgMemo := criaVar("NE0_MSGOBS")
	Local cMsg     := ""

	default cTitMsg := STR0003 //"Motivo"

	oDlg := TDialog():New(350,406,638,795,cTitMsg,,,,,,,,,.T.)
	oDlg:lEscClose := .f.

	If !empty(cTheme) .and. cTheme == "DARK" //Valida se o tema ativo é o dark
		oDlg:nClrPane := CLR_BLACK
		oDlg:nClrText := CLR_WHITE
	EndIf

	@ 038, 008 SAY FWSX3Util():GetDescription('NE0_DATA') PIXEL
	@ 038, 024 MSGET dDate OF oDlg PIXEL WHEN .f.

	@ 038, 076 SAY FWSX3Util():GetDescription('NE0_NOMUSU') PIXEL
	@ 038, 116 MSGET cNomUsu OF oDlg PIXEL WHEN .f.

	@ 058, 008 SAY FWSX3Util():GetDescription('NE0_MSGOBS') PIXEL
	@ 070, 008 GET oMsg Var cMsgMemo OF oDlg Multiline Size 172, 062 PIXEL VALID NaoVazio(cMsgMemo)

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| cMsg := cMsgMemo, oDlg:End()}, {|| oDlg:End()}) CENTERED
return cMsg
