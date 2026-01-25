#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TGVA002.CH"

#DEFINE AGUARDANDO  "0"
#DEFINE PROCESSANDO "1"
#DEFINE SUCESSO		  "2"
#DEFINE ERRO		    "3"

//-------------------------------------------------------------------
/*/{Protheus.doc} TGVA002
	Fila de eventos dos registros integrados pelo TOTVS Gestão de
	Vendas (TGV).

	@author Danilo Salve
	@since 04/12/2020
	@version 12.1.27 ou Superior
/*/
//-------------------------------------------------------------------
Function TGVA002()
	Local oMBrowse 	:= Nil
	Local oTableAtt := TableAttDef()

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("A1T")
	oMBrowse:SetDescription(STR0001) // Monitor TGV x Pedidos de Venda
	oMBrowse:SetCanSaveArea(.T.)
	oMBrowse:SetMenudef("TGVA002")

	oMBrowse:AddLegend("A1T_STATUS == '" + AGUARDANDO 	+ "'", "WHITE"	, STR0002) // Aguardando Processamento
	oMBrowse:AddLegend("A1T_STATUS == '" + PROCESSANDO 	+ "'", "YELLOW"	, STR0003) // Processando
	oMBrowse:AddLegend("A1T_STATUS == '" + SUCESSO 		  + "'", "GREEN"	, STR0004) // Concluído
	oMBrowse:AddLegend("A1T_STATUS == '" + ERRO			    + "'", "RED"  	, STR0005) // Erro

	oMBrowse:SetAttach( .T. )
	oMBrowse:SetViewsDefault( oTableAtt:aViews )
	oMBrowse:SetTotalDefault("A1T_FILIAL","COUNT", STR0006) // Total de Registros
	oMBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef
	Disponibiliza as Visões do Browse.

	@return	    oTableAtt, Objeto,  Objetos com as Visoes e Graicos.
	@author 	Danilo Salve
	@version	12.1.27
	@since      04/02/2021
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()
	Local oView		as Object
	Local oTableAtt := FWTableAtt():New()

	oTableAtt:SetAlias("A1T")

	oView := FWDSView():New()
	oView:SetName(STR0002) 	// Aguardando Processamento
	oView:SetID(STR0002) 	  // Aguardando Processamento
	oView:SetOrder(2) 		  // A1T_FILIAL + A1T_STATUS + A1T_DTREC + A1T_HRREC
	oView:SetCollumns({"A1T_STATUS", "A1T_NUM", "A1T_DTREC", "A1T_HRREC", "A1T_TPOPER"})
	oView:SetPublic( .T. )
	oView:AddFilter(STR0002, "A1T_STATUS == '" + AGUARDANDO + "'") //Aguardando Processamento
	oTableAtt:AddView(oView)

	oView := FWDSView():New()
	oView:SetName(STR0003) 	// Processando
	oView:SetID(STR0003) 	  // Processando
	oView:SetOrder(2) 		  // A1T_FILIAL + A1T_STATUS + A1T_DTREC + A1T_HRREC
	oView:SetCollumns({"A1T_STATUS", "A1T_NUM", "A1T_DTREC", "A1T_HRREC", "A1T_TPOPER"})
	oView:SetPublic( .T. )
	oView:AddFilter(STR0003, "A1T_STATUS == '"+ PROCESSANDO + "'") // Processando
	oTableAtt:AddView(oView)

	oView := FWDSView():New()
	oView:SetName(STR0004) 	// Concluído
	oView:SetID(STR0004) 	  // Concluído
	oView:SetOrder(2) 		  // A1T_FILIAL + A1T_STATUS + A1T_DTREC + A1T_HRREC
	oView:SetCollumns({"A1T_STATUS", "A1T_NUM", "A1T_DTREC", "A1T_HRREC", "A1T_TPOPER", "A1T_DTPROC", "A1T_HRPROC"})
	oView:SetPublic( .T. )
	oView:AddFilter(STR0004, "A1T_STATUS == '"+ SUCESSO + "'") //Concluído
	oTableAtt:AddView(oView)

	oView := FWDSView():New()
	oView:SetName(STR0005) 	// Erro
	oView:SetID(STR0005) 	  // Erro
	oView:SetOrder(2) 		  // A1T_FILIAL + A1T_STATUS + A1T_DTREC + A1T_HRREC
	oView:SetCollumns({"A1T_STATUS", "A1T_NUM", "A1T_DTREC", "A1T_HRREC", "A1T_TPOPER", "A1T_DTPROC", "A1T_HRPROC"})
	oView:SetPublic( .T. )
	oView:AddFilter(STR0004, "A1T_STATUS == '" + ERRO + "'") // Erro
	oTableAtt:AddView(oView)

Return oTableAtt

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
	Menu do cadastro de clientes para localização padrão.

	@author 	Danilo Salve
	@version	12.1.27 ou Superior
	@since		04/12/2020
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina		:= {}

	ADD OPTION aRotina TITLE STR0017 	ACTION "PesqBrw"          OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0018	ACTION "VIEWDEF.TGVA002"  OPERATION 2	ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0019	ACTION "TG002Repr"        OPERATION 4	ACCESS 0 // "Reprocessar"
	ADD OPTION aRotina TITLE STR0020	ACTION "VIEWDEF.TGVA002" 	OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Modelo de dados das Notificações

    @sample		ModelDef()
    @return		ExpO - Objeto MPFormModel
    @author		Danilo Salve
    @since		18/09/2020
    @version	12.1.27
/*/
//------------------------------------------------------------------------------
Static Function ModelDef() as Object
	Local oModel      as Object
	Local bPosVldMdl  := {|oModel| TG02PVALID(oModel) }
	Local oStructA1T  := FWFormStruct(1,'A1T',/*bAvalCampo*/,/*lViewUsado*/)

	oModel:= MPFormModel():New( "TGVA002",/*bPreValidacao*/,bPosVldMdl,/*bCommit*/,/*bCancel*/)
	oModel:AddFields("A1TMASTER",/*cOwner*/,oStructA1T,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:GetModel("A1TMASTER"):SetDescription("A1T")
	oModel:SetDescription(STR0001) //"Monitor Integração TOTVS Gestão de Vendas"
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Interface do modelo de dados de Controle de Integracao TGV para localização padrão.

	@author 	Squad CRM / FAT
	@version	12.1.27 ou Superior
	@since		04/12/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView
	Local oModel 		:= ModelDef()
	Local oStructA1T	:= FWFormStruct(2,"A1T",/*bAvalCampo*/,/*lViewUsado*/)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_A1T",oStructA1T,"A1TMASTER")

Return oView

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TG02PVALID
	Pos-Validadao do Model(MPFormModel).

	@sample	  TG02PVALID(oModel)
	@param		ExpO1 - Model do Controle de Privilegios do Registro (MPFormModel).
	@return	  ExpL - Verdadeiro / Falso
	@author		Danilo Salve
	@since		04/12/2020
/*/
//------------------------------------------------------------------------------
Static Function TG02PVALID( oModel )
	Local aArea		:= GetArea()
	Local aAreaA1T	:= A1T->(GetArea())
	Local lRetorno	:= .T.
	Local nOperation := oModel:GetOperation()

	If nOperation ==  MODEL_OPERATION_INSERT
		A1T->(DbSetOrder(1))
		If A1T->(DbSeek(FWxFilial("A1T") + oModel:GetValue( 'A1TMASTER', 'A1T_NUM' )))
			lRetorno := .F.
			oModel:SetErrorMessage("", "A1T_NUM", oModel:GetId() , "", "TG02PVALID", STR0021, STR0022)
		Endif
	EndIf

	RestArea(aAreaA1T)
	RestArea(aArea)

	aSize(aAreaA1T, 0)
	aSize(aArea, 0)

Return lRetorno

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TG002Repr
	Retorna o status dos registros com erro de processamento
	para aguardando processamento

	@sample	TG002Repr()
	@return	ExpL - Verdadeiro / Falso
	@author		Danilo Salve
	@since		14/12/2020
/*/
//------------------------------------------------------------------------------
Function TG002Repr()
	Local aArea 	:= GetArea()
	Local aAreaA1T 	:= A1T->(GetArea())

	If A1T->A1T_STATUS == '3'
		Processa( {|| TG02Proc() }, STR0007, STR0008,.F.) //Aguarde... / Carregando registro
	Else
		Help(NIL, NIL, STR0009, NIL, STR0010, 1, 0, NIL, NIL,; //"Registro Inválido" / "Status Invalido"
		NIL, NIL, NIL, { STR0011 }) //"Esta Ação é permita somente para registros com Erro de Processamento"
	Endif

	RestArea(aAreaA1T)
	RestArea(aArea)

	aSize(aAreaA1T, 0)
	aSize(aArea, 0)
Return

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TG02Proc
	Retorna o status dos registro para aguardando processamento

	@sample	TG02Proc(.T.)
	@return	ExpL - Verdadeiro / Falso
	@author		Danilo Salve
	@since		14/12/2020
/*/
//------------------------------------------------------------------------------
Static Function TG02Proc()
	Local lContinua := .T.
	Local oModel	as Object
	Local oModelA1T as Object

	Default cStatus := "1"
	Default cError	:= ""

	oModel := FWLoadModel("TGVA002")
	oModelA1T := oModel:GetModel("A1TMASTER")
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oModel:Activate()

	If oModel:IsActive()
		IncProc(STR0012) //"Alterando registro..."
		oModelA1T:SetValue("A1T_STATUS", '0')
		oModelA1T:SetValue("A1T_ERROR", '')
		oModelA1T:SetValue("A1T_DTPROC", CtoD('  /  /    '))
		oModelA1T:SetValue("A1T_HRPROC", '     ')
		If !(oModel:VldData() .And. oModel:CommitData())
			lContinua := .F.
		Endif
	Else
		lContinua := .F.
	EndIf

	If lContinua
		Help('', 1, OemToAnsi( STR0013 ),, OemToAnsi( STR0014 ) , 1, 0)
	Else
		Help('', 1, OemToAnsi( STR0015 ),, OemToAnsi( STR0016 ) , 1, 0)
	EndIf

	oModel:DeActivate()

	FreeObj(oModelA1T)
	FreeObj(oModel)
Return
