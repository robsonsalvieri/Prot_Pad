#INCLUDE "AGDA040.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE SOLICITACAO_RECEITA_REPOSITORY agd.solicitacaoReceitaRepository.agdSolicitacaoReceitaRepository

/*/{Protheus.doc} AGDA040
Rotina para Cadastro de Solicitação de Receita
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 25/09/2025
/*/
Function AGDA040()
	Local oMBrowse := Nil

	If .Not. TableInDic('NET')
		MsgNextRel()
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NET" )
	oMBrowse:SetDescription( STR0001 ) //#"Solicitação de Receita"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Definição do menu
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 25/09/2025
@return Array, array com o menu da rotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.AGDA040' OPERATION 2 ACCESS 0 //#"Visualizar"
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.AGDA040' OPERATION 3 ACCESS 0 //#"Incluir"
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.AGDA040' OPERATION 4 ACCESS 0 //#"Alterar"
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.AGDA040' OPERATION 5 ACCESS 0 //#"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de dados
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 25/09/2025
@return Object, modelo de dados
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNET  := FwFormStruct( 1, "NET" )
	Local oStruNEU	:= FwFormStruct( 1, "NEU" )
	Local oEvent        := AGDA040EVT():New()

	oModel := MpFormModel():New( "AGDA040")
	oModel:SetDescription( STR0001 ) //##"Solicitação de Receita"

	oStruNEU:SetProperty( "NEU_CODIGO" 	, MODEL_FIELD_INIT 	, {| | M->NET_CODIGO } )

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA040_NET", , oStruNET)
	oModel:GetModel( "AGDA040_NET" ):SetDescription( STR0006 ) //#"Dados Solicitação de Receita"
	oModel:SetPrimaryKey( { "NET_FILIAL", "NET_CODIGO" } )

	oModel:AddGrid( "AGDA040_NEU", "AGDA040_NET", oStruNEU)
	oModel:GetModel( "AGDA040_NEU" ):SetDescription( STR0007 ) //#"Itens Solicitação de Receita"

	//Atribui um relacionamento de Pai X Filho
	oModel:SetRelation( 'AGDA040_NEU', {{'NEU_FILIAL', 'xFilial("NEU")'},{ 'NEU_CODIGO', 'NET_CODIGO' },{ 'NEU_NUMPED', 'NET_NUMPED' }}, NEU->(IndexKey( 1 ) ) )

	oModel:GetModel( "AGDA040_NEU" ):SetUniqueLine( { 'NEU_ITEM' } )
	oModel:GetModel( "AGDA040_NEU" ):SetOptional( .F. )
	oModel:GetModel('AGDA040_NEU'):SetUseOldGrid(.T.)

	oModel:InstallEvent("AGDA040EVT", /*cOwner*/, oEvent)
Return oModel

/*/{Protheus.doc} ViewDef
Definição da visualização dos dados
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 25/09/2025
@return Object, Objeto de dados da View
/*/
Static Function ViewDef()

	Local oModel	:= FwLoadModel( "AGDA040" )
	Local oStruNET  := FwFormStruct( 2, "NET" )
	Local oStruNEU  := FwFormStruct( 2, "NEU" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oStruNEU:RemoveField( "NEU_CODIGO" )
	oStruNEU:RemoveField( "NEU_NUMPED" )

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NET', oStruNET, 'AGDA040_NET' )

	oView:AddGrid( 'VIEW_NEU', oStruNEU, 'AGDA040_NEU' )
	oView:AddIncrementField( 'VIEW_NEU', 'NEU_ITEM' )

	oView:CreateHorizontalBox( 'CABEC', 50 )
	oView:CreateHorizontalBox( 'GRID', 50 )

	oView:SetOwnerView( 'VIEW_NET', 'CABEC' )
	oView:SetOwnerView( 'VIEW_NEU', 'GRID' )

	oView:EnableTitleView("VIEW_NET")
	oView:EnableTitleView("VIEW_NEU")

	oView:SetCloseOnOk({||.T.})
Return oView


/*/{Protheus.doc} AGD40VDNET
Validação de campos da tabela NET via dicionário de dados SX3
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 25/09/2025
@return Logical, Valor lógico da validação, verdadeiro(.T.) ou Falso(.F.)
/*/
Function AGD40VDNET()
	Local lRet      := .T.
	Local cReadVar  := ReadVar()

	If "NET_NUMPED" $ cReadVar .And. !Empty(M->NET_NUMPED)
		lRet := AGD40VDPED()
	EndIf

Return lRet

/*/{Protheus.doc} AGD40VDPED
Função de validação ao informar campo NET_NUMPED
Carrega produtos do pedido que necessitam receituário
@type function
@version P12.1.2610
@author lindembergson.pacheco
@since 25/09/2025
@return Logical, .T. se encontrou produtos com receituário, .F. caso contrário
/*/
Function AGD40VDPED()
	Local oModel		:= NIL
	Local oNET			:= NIL
	Local oNEU			:= NIL
	Local nOperation	:= NIL
	Local cCodSolic		:= ""
	Local lTemReceita	:= .F.
	Local cPedido		:= ""
	Local cCliente		:= ""
	Local cLoja			:= ""
	Local aAreaSC9      := SC9->(GetArea())
	Local aAreaNCR		:= NCR->(GetArea())
	Local aAreaNEU		:= NEU->(GetArea())
	Local oRepository 	:= SOLICITACAO_RECEITA_REPOSITORY():New()
	Local aProdutos 	:= {}
	Local aPedProdutos	:= {}
	Local aRecProdutos	:= {}
	Local nI			:= 0

	If (oModel := FwModelActive()) != Nil;
			.AND. ValType(oModel) == "O";
			.AND. oModel:GetId() == "AGDA040"

		oModel		:= FwModelActive()
		oNET		:= oModel:GetModel("AGDA040_NET")
		oNEU		:= oModel:GetModel("AGDA040_NEU")
		nOperation	:= oModel:GetOperation()

		// Só processa na inclusão e não em modo Blind
		// If nOperation != MODEL_OPERATION_INSERT .Or. IsBlind()
		// 	Return .T.
		// EndIf
		// Obtém o número do pedido
		cPedido := AllTrim(oNET:GetValue("NET_NUMPED"))
		cCodSolic := AllTrim(oNET:GetValue("NET_CODIGO"))

		// If Empty(cPedido)
		// 	Return .T.
		// EndIf

		// Limpa grid anterior
		If oNEU:Length() > 0
			oNEU:DelAllLine()
			oNEU:ClearData()
		EndIf

		aPedProdutos	:= oRepository:getPedProdutos(cPedido)
		aRecProdutos	:= oRepository:getRecProdutos()

		if len(aPedProdutos) == 0
			If Upper(FunName()) == "AGDA040" .or. IsInCallStack( "AGDI043M" )
				AGDHELP(STR0008, STR0009, STR0010  ) //#"AJUDA" #"Este pedido não contem itens que exijam receituario agronômico." #"Verificar no cadastro dos itens a marcação de exigencia de receituário."
			endif
			Return .F.
		endif

		// Posiciona no pedido
		dbSelectArea('SC9')
		SC9->(dbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

		If !SC9->(dbSeek(xFilial('SC9') + cPedido))
			RestArea(aAreaSC9)
			RestArea(aAreaNCR)
			RestArea(aAreaNEU)¨
			If Upper(FunName()) == "AGDA040" .or. IsInCallStack( "AGDI043M" )
				if len(aPedProdutos) > 0
					AGDHELP(STR0008, STR0011, STR0012) //#"AJUDA" #"Este pedido contém itens que exijam receituario agronômico." # "Realize a liberação da quantidade dos itens que exigem receituario agronômico"
				endif
			endif
			Return .F.
		EndIf

		// // Armazena cliente e loja do primeiro registro
		cCliente := SC9->C9_CLIENTE
		cLoja    := SC9->C9_LOJA

		aProdutos		:= oRepository:setProdutos(cPedido, cCliente, cLoja, cCodSolic)

		// Adiciona produtos ao grid
		For nI := 1 To Len(aProdutos)
			lTemReceita   := .T.

			If nI > 1
				oNEU:AddLine()
			EndIf

			oNEU:SetValue("NEU_ITEM"  , StrZero(nI, TamSX3("NEU_ITEM")[1]))
			oNEU:SetValue("NEU_ITEMPE", aProdutos[nI][1]) // Item do pedido
			oNEU:SetValue("NEU_NUMPED", aProdutos[nI][2]) // Número do pedido
			oNEU:SetValue("NEU_PRODUT", aProdutos[nI][3]) // Produto
			oNEU:SetValue("NEU_UM"    , aProdutos[nI][4]) // UM
			oNEU:SetValue("NEU_QTDVEN", aProdutos[nI][5]) // Quantidade
			oNEU:SetValue("NEU_SEQLIB", aProdutos[nI][6]) // Sequencia

		Next nI

		// Posiciona na primeira linha do grid
		oNEU:GoLine(1)

		if len(aProdutos) == 0
			lTemReceita   := .F.
			if len(aPedProdutos) == len(aRecProdutos)
				If Upper(FunName()) == "AGDA040" .or. IsInCallStack( "AGDI043M" )
					AGDHELP(STR0008, STR0013) //#"AJUDA" #"Todos itens que exigem receituario agronômico já foram atendidos."
				endif
			elseif len(aPedProdutos) > len(aRecProdutos)
				If Upper(FunName()) == "AGDA040" .or. IsInCallStack( "AGDI043M" )
					AGDHELP(STR0008, STR0011, STR0012) //#"AJUDA" #"Este pedido contém itens que exijam receituario agronômico." # "Realize a liberação da quantidade dos itens que exigem receituario agronômico"
				endif
			endif
		EndIf

		// Restaura áreas
		RestArea(aAreaSC9)
		RestArea(aAreaNCR)
		RestArea(aAreaNEU)

	ENDIF

Return lTemReceita


/*/{Protheus.doc} AGDA040TRG
Funcao utilizada no gatilho do campo NET_NUMPED
@type function
@version 12
@author lindembergson.pacheco
@since 07/10/2025
/*/
Function AGDA040TRG()
	Local oModel	:= nil
	Local oView		:= nil
	Local oNET		:= nil
	Local cCultura	:= ""


	If (oModel := FwModelActive()) != Nil;
			.AND. ValType(oModel) == "O";
			.AND. oModel:GetId() == "AGDA040"

		oNET := oModel:GetModel("AGDA040_NET")

		dbSelectArea('SC9')
		SC9->(dbSetOrder(1))
		If SC9->(dbSeek(xFilial('SC9') + oNET:GetValue("NET_NUMPED")))
			oNET:SetValue('NET_CLIENT', SC9->C9_CLIENTE)
			oNET:SetValue('NET_LOJA'  , SC9->C9_LOJA)
		EndIf

		dbSelectArea('SC6')
		SC6->(dbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		If SC6->(dbSeek(xFilial('SC6') + oNET:GetValue("NET_NUMPED")))
			cCultura := SC6->C6_CULTRA
		endif

		dbSelectArea('NEQ')
		NEQ->(dbSetOrder(1)) //Filial + NUM
		If NEQ->(dbSeek(xFilial('NEQ') + oNET:GetValue("NET_NUMPED")))
			oNET:SetValue('NET_CODENG', NEQ->NEQ_CODENG)
			oNET:SetValue('NET_CULTRA', cCultura)
			oNET:SetValue('NET_LOCDES', NEQ->NEQ_CODDES)
		endif

		If (oView := FwViewActive()) != Nil;
				.AND. ValType(oView) == "O";
				.AND. oView:oModel:getId() == "AGDA040"
			oView:Refresh("VIEW_NET")
		EndIf
	EndIf

Return

/*/{Protheus.doc} IntegDef
Integradef de descarte de embalagem
@type function
@version 12
@author lindembergson.pacheco
@since 18/11/2025
@param xEnt, variant, Obejto Recebido
@param nTypeTrans, numeric, Recebimento/Envio
@param cTypeMessage, character, Tipo Mensagem
@param cVersion, character, Versão
@param cTransac, character, Tipo Transação
@param lEAIObj, logical, Formato JSON
@return variant, retorno
/*/
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage, cVersion, cTransac, lEAIObj )
Default xEnt := ""
Default nTypeTrans := ""
Default cTypeMessage := ""
Default cVersion := ""
Default cTransac := ""
Default lEAIObj := .F.

Return AGDIA040(xEnt,nTypeTrans,cTypeMessage, cVersion, cTransac, lEAIObj )
