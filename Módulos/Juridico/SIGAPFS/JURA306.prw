#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"
#INCLUDE 'JURA306.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA306()
Acompanhamento das solicitações de ocorrencias do jurídico

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Function JURA306()

Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0001 ) // "Acompanhamento de solicitações de ocorrencias"
	oBrowse:SetAlias( "OI7" )
	oBrowse:SetMenuDef( 'JURA306' )
	oBrowse:SetLocate()

	oBrowse:AddLegend("OI7_STATUS == '1'", "ORANGE", STR0002)  // "Pendente"
	oBrowse:AddLegend("OI7_STATUS == '2'", "GRAY",   STR0003)  // "Cancelado"
	oBrowse:AddLegend("OI7_STATUS == '3'", "BLUE",   STR0004)  // "Em processamento"
	oBrowse:AddLegend("OI7_STATUS == '4'", "WHITE",  STR0005)  // "Concluído sem cobrança"
	oBrowse:AddLegend("OI7_STATUS == '5'", "YELLOW", STR0006)  // "Pendente Faturamento"
	oBrowse:AddLegend("OI7_STATUS == '6'", "GREEN",  STR0007)  // "Faturado"
	oBrowse:AddLegend("OI7_STATUS == '7'", "VIOLET", STR0008)  // "Em faturamento" 
	oBrowse:AddLegend("OI7_STATUS == '8'", "RED",    STR0017)  // "Pendente de revisão"

	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
	1 - Pesquisa e Posiciona em um Banco de Dados
	2 - Simplesmente Mostra os Campos
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.JURA306' OPERATION OP_VISUALIZAR ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0010 ACTION 'J306AtuSt()'     OPERATION OP_VISUALIZAR ACCESS 0 // "Atualizar solicitações"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Modelo de dados de Acompanhamento de solicitações de ocorrencias

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA306" )
Local oStructOI7 := FWFormStruct( 2, "OI7" )

	oStructOI7:RemoveField( "OI7_IDSOL" )
	oStructOI7:RemoveField( "OI7_URLREQ" )
	oStructOI7:RemoveField( "OI7_BODY" )

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA306_VIEW", oStructOI7, "OI7MASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA306_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0001 ) // "Acompanhamento de solicitações de ocorrencias"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Acompanhamento de solicitações de ocorrencias

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructOI7 := FWFormStruct( 1, "OI7" )

	oModel:= MPFormModel():New( "JURA306", /*Pre-Validacao*/, {|oX|J306TudoOk(oX)}/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
	oModel:AddFields( "OI7MASTER", NIL, oStructOI7, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0001 ) //"Acompanhamento de solicitações de ocorrencias"
	oModel:GetModel( "OI7MASTER" ):SetDescription( STR0001 ) // "Acompanhamento de solicitações de ocorrencias"

	JurSetRules( oModel, 'OI7MASTER',, 'OI7' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J306TudoOk(oMdl)
Validação de dados da rotina de acompanhamento de solicitações de 
ocorrencias do juridico

@param oMdl  - Modelo de dados
@return lRet - Indicas se o modelo é valido

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Function J306TudoOk(oMdl)

Local lRet      := .F.
Local cEntidade := oMdl:GetValue("OI7MASTER", "OI7_ENTIDA")

	If cEntidade $ "1|2"
		lRet := .T.
	else
		lRet := JurMsgErro( STR0011 ) // "A entidade é inválida! Valores válidos 1=Processo / 2= Atos processuais."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J306Status(cStatus)
Responsável por compor os itens no combo box do campo OI7_STATUS

@param cStatus       - Indica o status atual do registro
@retrunr cCboxStatus - Descrição dos status

@since 28/10/2022
/*/
//-------------------------------------------------------------------
Function J306Status( cStatus )

Local cCboxStatus := ""

	cCboxStatus := "1=" + STR0002 + ";"  // "1=Pendente"
	cCboxStatus += "2=" + STR0003 + ";"  // "2=Cancelado"
	cCboxStatus += "3=" + STR0004 + ";"  // "3=Em processamento"
	cCboxStatus += "4=" + STR0005 + ";"  // "4=Concluído sem cobrança"
	cCboxStatus += "5=" + STR0006 + ";"  // "5=Pendente Faturamento"
	cCboxStatus += "6=" + STR0007 + ";"  // "6=Faturado"
	cCboxStatus += "7=" + STR0008 + ";"  // "7=Em faturamento"
	cCboxStatus += "8=" + STR0017 + ";"  // "8=Pendente de revisão"

Return cCboxStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} J305vldSts( cStatus )
Responsável pela validação no preenchimento do campo OI7_STATUS

@param  cStatus - Indica o status da solicitação
					1=Pendente
					2=Cancelado
					3=Em processamento
					4=Concluído sem cobrança
					5=Pendente Faturamento
					6=Faturado
					7=Em faturamento
					8=Pendente de revisão"
@return lRet    - Indica se o valor é válido
/*/
//-------------------------------------------------------------------
Function J305vldSts( cStatus )

Local lRet := .F.

	If Empty( cStatus ) .AND. VALTYPE(M->OI7_STATUS) <> "U"
		cStatus := M->OI7_STATUS
	EndIf

	lRet := cStatus $ "12345678"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J306Reenv()
Responsável por reenviar a solicitação para a Azure

@return .T.
@since 01/11/2022
/*/
//-------------------------------------------------------------------
Function J306Reenv()

Local cCodT    := SuperGetMv('MV_JCFGOCO',, '')
Local oSolicit := JsonObject():New()
Local cBody    := OI7->OI7_BODY
Local cStatus  := OI7->OI7_STATUS
Local cMsg     := OI7->OI7_MSG
Local aSolicit := {}
Local aErros   := {}
Local lRet     := .T.
Local cUrlReq  := "https://api.totvsjuridico.totvs.com.br/api/ocorrencia/new/"+ Encode64(cCodT)

	If cStatus == "7" .AND. !Empty(cMsg)

		ProcRegua( 1 )
		IncProc( STR0012 ) // "Reenviando solicitação"

		oSolicit:fromJson(cBody)
		aAdd( aSolicit, oSolicit )

		aErros := aClone(J305SolAz(aSolicit, cCodT))

		If Len(aErros) > 0
			lRet := .F.
			FWAlertWarning( STR0013 ) // "Não foi possível realizar o reenvio. Tente novamente mais tarde!"
		Else
			lRet := J305MonSol(aSolicit, 4, aErros, cUrlReq)

			If lRet
				FWAlertSuccess( STR0014 ) // "Solicitação reenviada com sucesso!"
			EndIf
		EndIf
		aSize(aSolicit, 0)

	Else
		FWAlertWarning( STR0015 ) // "Não é possível reenviar solicitações com status diferente de 7=Pendente de revisão."
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J306AtuSt()
Responsável por chamar a função de atualização das solicitações

@return .T.
@since 16/12/2022
/*/
//--------------------------
Function J306AtuSt()
	Processa({|| JURA308() })
Return
