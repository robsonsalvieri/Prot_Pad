#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA061.CH"

Static _CCARGO_
STATIC _CCODTFF_
Static _CCODTXS_
STATIC _CENTGPE_
STATIC _CESCALA_
Static _CFILENT_
Static _CFILLOC_
Static _CFUNCAO_
STATIC _CLOCAL_
STATIC _CPLAN_
STATIC _CTURNO_
Static _lFacilit_
Static _lPercDesc := .F.
Static _lRevisao_
STATIC _OMDLTFF_
STATIC _REGTUR_
Static aBenefEx   := {}
Static aBenRev    := {}
Static oMdlOrc    := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT352TDX()

Vinculo de beneficios

@sample 	AT352TDX()
@param		ExpC1 Entidade
@return	ExpL	Verdadeiro / Falso
@since		18/05/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function AT352TDX(oMdl, lModo, lDelTFF)

	Local aRevisao   := {}
	Local cCodCri    := ""
	Local lOk        := .T.
	Local nK         := 0
	Local nOperation := Nil
	Local oMdlTFF    := Nil
	Local oMdlTFL    := Nil

	Default lModo   := .F.
	Default lDelTFF := .F.

	_lFacilit_ := lModo
	_lPercDesc := TDZ->(ColumnPos("TDZ_PERC") > 0) .AND. TDZ->(ColumnPos("TDZ_NICKPE") > 0)
	_lRevisao_ := .F.
	oMdlOrc    := oMdl

	If _lFacilit_
		oMdlTFF		:= oMdl:GetModel("TXSDETAIL")
		nOperation	:= oMdl:GetOperation()
	Else
		oMdlTFL		:= oMdl:GetModel("TFL_LOC")
		oMdlTFF		:= oMdl:GetModel("TFF_RH")
		nOperation	:= oMdl:GetOperation()
	EndIf

	_CENTGPE_ := 'TDX'
	_OMDLTFF_ := oMdlTFF
	_REGTUR_  := 0
	_CPLAN_   := ''

	cCodCri := fRetCriter(,_CENTGPE_)	// Retorna o codigo do criterio ativo

	If nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_INSERT

		// Valida local de atendimento
		If !_lFacilit_ .And. Empty(oMdlTFL:GetValue("TFL_LOCAL"))
			lOk := .F.
			Help(,,'TECA352',,STR0043,1,0)	//"Local de Atendimento não informado."
		EndIf

		// Valida turno
		If lOk .And. !_lFacilit_
			If Empty(oMdlTFF:GetValue("TFF_ESCALA"))
				If Empty(oMdlTFF:GetValue("TFF_TURNO"))
					lOk := .F.
					Help(,,'TECA352',,STR0044,1,0)	//"O código do turno ou o código da escala deve ser informado."
				Else
					_CTURNO_  := oMdlTFF:GetValue("TFF_TURNO")
					_CESCALA_ := ''
				EndIf
			Else
				_CTURNO_  := ''
				_CESCALA_ := oMdlTFF:GetValue("TFF_ESCALA")
			EndIf
			
		ElseIf lOk .And. _lFacilit_
			If Empty(oMdlTFF:GetValue("TXS_ESCALA"))
				If Empty(oMdlTFF:GetValue("TXS_TURNO"))
					lOk := .F.
					Help(,,'TECA352',,STR0044,1,0)	//"O código do turno ou o código da escala deve ser informado."
				Else
					_CTURNO_  := oMdlTFF:GetValue("TXS_TURNO")
					_CESCALA_ := ''
				EndIf
			Else
				_CTURNO_  := ''
				_CESCALA_ := oMdlTFF:GetValue("TXS_ESCALA")
			EndIf
		EndIf

		If lOk
			DbSelectArea("SJS")
			SJS->(DbSetOrder(1)) //JS_FILIAL, JS_CDAGRUP, JS_TABELA, JS_SEQ
			SJS->(DbSeek(xFilial("SJS")+cCodCri+_CENTGPE_))

			If !_lFacilit_
				_CLOCAL_  := oMdlTFL:GetValue("TFL_LOCAL")
				_CCODTFF_ := oMdlTFF:GetValue("TFF_COD")
				_CPLAN_   := oMdlTFL:GetValue("TFL_PLAN")
				_CFILENT_ := oMdlTFF:GetValue("TFF_FILIAL")
				_CFILLOC_ := oMdlTFL:GetValue("TFL_FILIAL")
				_CFUNCAO_ := oMdlTFF:GetValue("TFF_FUNCAO")
				_CCARGO_  := oMdlTFF:GetValue("TFF_CARGO")
			Else
				_CFILENT_ := oMdlTFF:GetValue("TXS_FILIAL")
				_CCODTXS_ := oMdlTFF:GetValue("TXS_CODIGO")
				_CFUNCAO_ := oMdlTFF:GetValue("TXS_FUNCAO")
				_CCARGO_  := oMdlTFF:GetValue("TXS_CARGO")
			EndIf

			aRevisao  := AT870GETRE()

			// Verifica se o contrato do orcamento de servicos ainda nao foi gerado
			If _lFacilit_ .Or. Empty(oMdlTFF:GetValue("TFF_CONTRT"))
				If !lDelTFF
					FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
				Else
					oMdl352:= FWLoadModel("TECA352")
					oMdl352:SetOperation(4) //UPDATE
					oMdl352:Activate()

					oMdlSLY := oMdl352:GetModel("GPEA061_SLY")
					If oMdlSLY:Length() > 0
						For nK := 1 To oMdlSLY:Length()
							oMdlSLY:GoLine(nK)
							oMdlSLY:DeleteLine()
						Next nK
						If 	oMdl352:VldData() 		// Aplica a validações aos campos alimentados				
							oMdl352:CommitData() 	// Efetua a gravação e commit		
						EndIf	
					EndIf
					oMdl352:DeActivate()	// Desativamos o Model		
				EndIf
			Else
				If Len(aRevisao) > 0
					// Se for revisao
					_lRevisao_ := aRevisao[1][1]
					If _lRevisao_
						// Aditivo
						If aRevisao[1][2] == '1'
							// Alteracao permitido somente para item do RH de um novo local de pagamento
							If Empty(_CPLAN_)
								FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
							Else
								FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
							EndIf
						Else
							FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
						EndIf
					Else
						FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
					EndIf
				Else
					FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
				EndIf
			EndIf
		EndIf
	Else
		IF !_lFacilit_
			IF Empty(oMdlTFF:GetValue("TFF_ESCALA"))
				IF ! Empty(oMdlTFF:GetValue("TFF_TURNO"))
					_CTURNO_  := oMdlTFF:GetValue("TFF_TURNO")
					_CESCALA_ := ''
				ENDIF
			ELSE
				_CTURNO_  := ''
				_CESCALA_ := oMdlTFF:GetValue("TFF_ESCALA")
			ENDIF
		ElseIf lOk .And. _lFacilit_
			IF Empty(oMdlTFF:GetValue("TXS_ESCALA"))
				IF ! Empty(oMdlTFF:GetValue("TXS_TURNO"))
					_CTURNO_  := oMdlTFF:GetValue("TXS_TURNO")
					_CESCALA_ := ''
				ENDIF
			ELSE
				_CTURNO_  := ''
				_CESCALA_ := oMdlTFF:GetValue("TXS_ESCALA")
			ENDIF
		EndIf

		DbSelectArea("SJS")
		SJS->(DbSetOrder(1)) //JS_FILIAL, JS_CDAGRUP, JS_TABELA, JS_SEQ
		SJS->(DbSeek(xFilial("SJS")+cCodCri+_CENTGPE_))
		If !_lFacilit_
			_CLOCAL_  := oMdlTFL:GetValue("TFL_LOCAL")
			_CCODTFF_ := oMdlTFF:GetValue("TFF_COD")
			_CFILENT_ := oMdlTFF:GetValue("TFF_FILIAL")
			_CFILLOC_ := oMdlTFL:GetValue("TFL_FILIAL")
		Else
			_CFILENT_ := oMdlTFF:GetValue("TXS_FILIAL")
			_CCODTXS_ := oMdlTFF:GetValue("TXS_CODIGO")
			_CFUNCAO_ := oMdlTFF:GetValue("TXS_FUNCAO")
			_CCARGO_  := oMdlTFF:GetValue("TXS_CARGO")
		EndIf
		FWExecView(STR0002,"VIEWDEF.TECA352", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ) //"Beneficios"
	EndIf

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Vinculo de Beneficios

@Return 	nil
@author	Serviços
@since 		18/05/2015
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local bLinePost := {|| .T.}
	Local bLinePre  := Nil
	Local bLoadTMP  := Nil
	Local bLoadTUR  := Nil
	Local cCodCri   := ""
	local cFilLoc   := _CFILLOC_
	Local cSeqAtu   := Space(TAMSX3("JS_SEQ")[1]) // Sequencia da Criterio da Entidade
	Local oModel    := FWLoadModel("GPEA061")
	Local oStruSJS  := FWFormModelStruct():New()
	Local oStruSLY  := oModel:GetModel("GPEA061_SLY"):getstruct() //FWFormStruct(1,"SLY")
	Local oStruTDZ  := FWFormStruct(1,"TDZ")
	Local oStruTMP  := FWFormStruct(1,"SLY")
	Local oStruZZY  := FWFormModelStruct():New()

	If !_lFacilit_
		bLinePost := { |oModel| SLY_LinhaOK(oModel) }
	EndIf

	cCodCri  := fRetCriter(,_CENTGPE_)	// Retorna o codigo do criterio ativo

	DbSelectArea("SJS")
	SJS->(DbSetOrder(1)) //JS_FILIAL, JS_CDAGRUP, JS_TABELA, JS_SEQ
	SJS->(DbSeek(xFilial("SJS")+cCodCri+_CENTGPE_))
	cSeqAtu := SJS->JS_SEQ

	bLoadTMP := { |oModel| At352FIL(1, cCodCri, cSeqAtu, oModel, cFilLoc ) }
	bLoadTUR := { |oModel| At352TUR(oModel) }
	bLinePre := { |oModel, nLine, cAction| At352VldLin(oModel, cAction)}

	// Carrega estrutura da entidade
	oStruSJS:AddTable("ZZZ",{},STR0003) // "Entidades"
	At352Stru( oStruSJS, "ZZZ", .T. )

	// Legenda Vistoria Tecnica

	oStruTMP:AddField(	AllTrim("")      ,; // [01] C Titulo do campo
						AllTrim(STR0003) ,; // [02] C ToolTip do campo "Legenda"
						"LY_LEGEND"      ,; // [03] C identificador (ID) do Field
						"C"              ,; // [04] C Tipo do campo
						15               ,; // [05] N Tamanho do campo
						0                ,; // [06] N Decimal do campo
						Nil              ,; // [07] B Code-block de validação do campo
						Nil              ,; // [08] B Code-block de validação When do campo
						Nil              ,; // [09] A Lista de valores permitido do campo
						Nil              ,; // [10] L Indica se o campo tem preenchimento obrigatório
						Nil              ,; // [11] B Code-block de inicializacao do campo
						Nil              ,; // [12] L Indica se trata de um campo chave
						Nil              ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )               // [14] L Indica se o campo é virtual

	// Carrega estrutura do turno
	oStruZZY:AddTable("ZZY",{},STR0045) // "Turnos"
	At352Stru( oStruZZY, "ZZY", .T. )

	// Cria o inicializador padrao
	oStruSJS:SetProperty("ZZZ_ENTID",MODEL_FIELD_INIT,{||At352CPL("ZZZ_ENTID") })

	// Cria o inicializador padrao dos beneficios (VINCULO)
	oStruSLY:SetProperty("LY_FILIAL" , MODEL_FIELD_INIT, {||At352CPL("LY_FILIAL") })
	oStruSLY:SetProperty("LY_AGRUP"  , MODEL_FIELD_INIT, {||At352CPL("LY_AGRUP") })
	oStruSLY:SetProperty("LY_ALIAS"  , MODEL_FIELD_INIT, {||At352CPL("LY_ALIAS") })
	oStruSLY:SetProperty("LY_FILENT" , MODEL_FIELD_INIT, {||At352CPL("LY_FILENT") })
	oStruSLY:SetProperty("LY_CHVENT" , MODEL_FIELD_INIT, {||At352CPL("LY_CHVENT",oModel) })
	oStruSLY:SetProperty("LY_DESCTIP", MODEL_FIELD_INIT, { || "" })
	oStruSLY:SetProperty("LY_DESBEN" , MODEL_FIELD_INIT, { || "" })

	oStruSLY:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	oStruSLY:SetProperty('LY_TIPO'  , MODEL_FIELD_WHEN, {|oModel|At352Res(oModel,_CPLAN_)})
	oStruSLY:SetProperty('LY_CODIGO', MODEL_FIELD_WHEN, {|oModel|At352Res(oModel,_CPLAN_)})
	oStruSLY:SetProperty('LY_DTINI' , MODEL_FIELD_WHEN, {|oModel|At352Res(oModel,_CPLAN_)})

	//Campo para controle de regra de revisao, se for true, o beneficio pertence ao legado e a linha não poderá ser excluida, e poderá ser alterada apenas data fim e valor (que valor?)

	oStruSLY:AddField(	"Legado"      ,; // [01] C Titulo do campo
						"Item legado" ,; // [02] C ToolTip do campo "Legenda"
						"LY_LEGADO"      ,; // [03] C identificador (ID) do Field
						"L"              ,; // [04] C Tipo do campo
						1               ,; // [05] N Tamanho do campo
						0                ,; // [06] N Decimal do campo
						Nil              ,; // [07] B Code-block de validação do campo
						Nil              ,; // [08] B Code-block de validação When do campo
						Nil              ,; // [09] A Lista de valores permitido do campo
						Nil              ,; // [10] L Indica se o campo tem preenchimento obrigatório
						Nil              ,; // [11] B Code-block de inicializacao do campo
						Nil              ,; // [12] L Indica se trata de um campo chave
						Nil              ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )               // [14] L Indica se o campo é virtual	

	oStruSLY:SetProperty("LY_LEGADO", MODEL_FIELD_INIT, {|| .F. })

	oStruZZY:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	oStruTMP:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	oModel := MPFormModel():New("TECA352", /*bPreValid*/, /*bTudoOK*/, {|oModel| At352Cmt( oModel ) }/*bCommiM040*/, /*bCancel*/ )
	oModel:SetDescription(STR0002) // "Critérios de benefícios"

	//MASTER - Entidade
	oModel:AddFields("SJSMASTER", /*cOwner*/, oStruSJS , /*Pre-Validacao*/,/*Pos-Validacao*/,{||})

	//GRIDS - Beneficios Vinculados
	oModel:AddGrid("TMPDETAIL", "SJSMASTER" , oStruTMP,/*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,bLoadTMP/*bLoad*/)
	oModel:GetModel("TMPDETAIL"):SetDescription(STR0030)// "Beneficios Vinculados"
	oModel:GetModel("TMPDETAIL"):SetOptional(.T.)
	oModel:GetModel("TMPDETAIL"):SetOnlyQuery(.T.)  //Seta para não realizar a gravação da tabela SLY

	//GRIDS - Turnos
	oModel:AddGrid("ZZYDETAIL", "SJSMASTER" , oStruZZY,/*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,bLoadTUR/*bLoad*/)
	oModel:GetModel("ZZYDETAIL"):SetDescription(STR0045)// "Turnos"

	//GRIDS - Beneficios
	oModel:AddGrid( "GPEA061_SLY", "ZZYDETAIL", oStruSLY, bLinePre/*bLinePre*/, bLinePost, /*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:GetModel("GPEA061_SLY"):SetDescription(STR0012)// "Beneficios"
	oModel:GetModel( 'GPEA061_SLY'):SetOptional( .T. )

	oModel:SetRelation( "GPEA061_SLY", {{"LY_FILENT", "xFilial('TFF')"},{ "LY_CHVENT", "ZZY_CHVENT" },{ 'LY_AGRUP', 'SJS->JS_CDAGRUP' }}, "LY_CHVENT" )

	// Criado para evitar Help FWFORMBEFORE - Violacao de Integridade
	oModel:addGrid('TDZDETAIL','GPEA061_SLY',oStruTDZ)
	oModel:SetRelation('TDZDETAIL', {{"TDZ_FILIAL","xFilial('TDZ')"},{"TDZ_TIPBEN" ,"LY_TIPO"}}, TDZ->(IndexKey(1)))
	oModel:GetModel('TDZDETAIL'):SetOnlyQuery()
	oModel:GetModel('TDZDETAIL'):SetOptional(.T.)

	oModel:SetPrimaryKey({})
	oModel:SetVldActivate( {|oModel| At352Vld(oModel)} )
	oModel:SetActivate( {|oModel| InitDados(oModel) } )

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface
@since   	04/05/2015
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local aCampos  := {}
	Local aCamSLY  := {}
	Local cCamSLY  := ""
	Local cX3Custo := ""
	Local nL       := 0
	Local oModel   := ModelDef()
	Local oStruSJS := Nil
	Local oStruSLY := Nil
	Local oStruTMP := Nil
	Local oStruZZY := Nil
	Local oView    := Nil

	// Carrega estrutura da Entidade
	oStruSJS := FWFormViewStruct():New()
	At352Stru( oStruSJS, "ZZZ", .F. )

	aCamSLY :=  FWSX3Util():GetAllFields( 'SLY' ,.T. )

	For nL := 1 to len(aCamSLY)
		cX3Custo := GetSx3Cache(aCamSLY[nL],"X3_PROPRI")
		If  (aCamSLY[nL] $ ("LY_TIPO|LY_DESCTIP|LY_CODIGO|LY_DESBEN|LY_PGDUT|LY_PGSAB|LY_PGDOM|LY_PGFER|LY_PGSUBS|LY_PGFALT|LY_PGAFAS|LY_PGVAC|LY_DIAS|LY_DTINI|LY_DTFIM|LY_ALIAS") .Or. cX3Custo == "U")
				cCamSLY += aCamSLY[nL] + "+"
				AADD(aCampos,{aCamSLY[nL]})
		EndIf
	Next nL

	cCamSLY :=  Left(cCamSLY,Len(cCamSLY)-1 )

	oStruTMP := FWFormStruct(2, 'SLY', {|cCpo| AllTrim(cCpo)$cCamSLY})
	oStruSLY := FWFormStruct(2, 'SLY', {|cCpo| AllTrim(cCpo)$cCamSLY})

	// Carrega estrutura do Turno
	oStruZZY := FWFormViewStruct():New()
	At352Stru( oStruZZY, "ZZY", .F. )

	oStruSLY:SetProperty('LY_TIPO' , MVC_VIEW_CANCHANGE,.T. )

	// Legenda Vistoria Tecnica
	oStruTMP:AddField(	"LY_LEGEND"         ,; // [01] C Nome do Campo
							"01"            ,; // [02] C Ordem
							AllTrim("")     ,; // [03] C Titulo do campo
							AllTrim(STR0031),; // [04] C Descrição do campo "Legenda"
							{STR0031}       ,; // [05] A Array com Help
							"C"             ,; // [06] C Tipo do campo
							"@BMP"          ,; // [07] C Picture
							Nil             ,; // [08] B Bloco de Picture Var
							""              ,; // [09] C Consulta F3
							.F.             ,; // [10] L Indica se o campo é evitável
							Nil             ,; // [11] C Pasta do campo
							Nil             ,; // [12] C Agrupamento do campo
							Nil             ,; // [13] A Lista de valores permitido do campo (Combo)
							Nil             ,; // [14] N Tamanho Maximo da maior opção do combo
							Nil             ,; // [15] C Inicializador de Browse
							.T.             ,; // [16] L Indica se o campo é virtual
							Nil ) // [17] C Picture Variável

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField('VIEW_SJS', oStruSJS, 'SJSMASTER')
	oView:AddGrid('VIEW_TMP' , oStruTMP, 'TMPDETAIL')
	oView:AddGrid('VIEW_ZZY' , oStruZZY, 'ZZYDETAIL')
	oView:AddGrid('VIEW_SLY' , oStruSLY, 'GPEA061_SLY')

	//Legenda
	oView:AddUserButton(STR0031,"",{ || At352Leg()}) //"Legenda"

	// Adiciona as visões na tela
	oView:CreateHorizontalBox( 'TOP'    , 10 )
	oView:CreateHorizontalBox( 'MIDDLE' , 35 )
	oView:CreateHorizontalBox( 'MIDDLE2', 25 )
	oView:CreateHorizontalBox( 'DOWN'   , 30 )

	// Faz a amarração das VIEWs dos modelos com as divisões na interface
	oView:SetOwnerView('VIEW_SJS', 'TOP'    )

	oView:SetOwnerView('VIEW_TMP', 'MIDDLE')
	oView:EnableTitleView( "VIEW_TMP", STR0032 )	// "Benefícios Superiores"

	oView:SetOwnerView('VIEW_ZZY', 'MIDDLE2')
	oView:EnableTitleView( "VIEW_ZZY", STR0042 )	// "Turnos do Local de Atendimento"

	oView:SetOwnerView('VIEW_SLY', 'DOWN')
	oView:EnableTitleView( "VIEW_SLY", STR0030 ) 	// "Benefícios Vinculados"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Criacao do MenuDef.

@sample 	Menudef()
@param		Nenhum
@return	 	aMenu, Array, Opção para seleção no Menu
@since		04/05/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0006 ACTION 'PesqBrw'       OPERATION 1 ACCESS 0	// "Pesquisar"
	ADD OPTION aRotina TITLE STR0033 ACTION 'VIEWDEF.TECA352' OPERATION 4 ACCESS 0	// "Alterar"

Return (aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352Stru
Carrega as estruturas para os grids da alocação

@param oStruct - Estrutura a ser alterada com os novos campos
@param cTipo   - Tipo de estrutura a ser criada (ZZZ - Entidade, ZZY - Turno)
@param lModel  - Indica se é para model ou view (.T. - Model, .F. - View)

@return	 Nil
@author	 Serviços
@since   05/05/2015
@version P12
/*/
//------------------------------------------------------------------------------
Static Function At352Stru( oStruct, cTipo, lModel )

	Default oStruct := Nil
	Default lModel  := .T.

	If lModel
		If cTipo == "ZZZ"
			oStruct:AddField(   STR0020     ,; // [01] C Titulo do campo
								STR0020     ,; // [02] C ToolTip do campo
								"ZZZ_ENTID" ,; // [03] C identificador (ID) do Field
								"C"         ,; // [04] C Tipo do campo
								30          ,; // [05] N Tamanho do campo
								0           ,; // [06] N Decimal do campo
								Nil         ,; // [07] B Code-block de validação do campo
								Nil         ,; // [08] B Code-block de validação When do campo
								Nil         ,; // [09] A Lista de valores permitido do campo
								Nil         ,; // [10] L Indica se o campo tem preenchimento obrigatório
								Nil         ,; // [11] B Code-block de inicializacao do campo
								Nil         ,; // [12] L Indica se trata de um campo chave
								.F.         ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
								.T. )          // [14] L Indica se o campo é virtual
		EndIf
		If cTipo == "ZZY"

			oStruct:AddIndex(   1           ,; //[01] Ordem do indice
								"1"         ,; //[02] ID
								"ZZY_CHVENT",; //[03] Chave do indice
								STR0046     ,; //[04] Descricao do indice
								""          ,; //[05] Expressao de lookUp dos campos de indice
								""          ,; //[06] Nickname do indice
								.T. )          //[07] Indica se o indice pode ser utilizado pela interface

			oStruct:AddField(	STR0046               ,; // [01] C Titulo do campo
								STR0046               ,; // [02] C ToolTip do campo
								"ZZY_CHVENT"          ,; // [03] C identificador (ID) do Field
								"C"                   ,; // [04] C Tipo do campo
								TAMSX3("LY_CHVENT")[1],; // [05] N Tamanho do campo
								0                     ,; // [06] N Decimal do campo
								Nil                   ,; // [07] B Code-block de validação do campo
								Nil                   ,; // [08] B Code-block de validação When do campo
								Nil                   ,; // [09] A Lista de valores permitido do campo
								Nil                   ,; // [10] L Indica se o campo tem preenchimento obrigatório
								Nil                   ,; // [11] B Code-block de inicializacao do campo
								.T.                   ,; // [12] L Indica se trata de um campo chave
								.F.                   ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
								.T. )                    // [14] L Indica se o campo é virtual

			oStruct:AddField(	STR0047              ,; // [01] C Titulo do campo
								STR0047              ,; // [02] C ToolTip do campo "Legenda"
								"ZZY_CODTFF"         ,; // [03] C identificador (ID) do Field
								"C"                  ,; // [04] C Tipo do campo
								TAMSX3("TFF_COD")[1] ,; // [05] N Tamanho do campo
								0                    ,; // [06] N Decimal do campo
								Nil                  ,; // [07] B Code-block de validação do campo
								Nil                  ,; // [08] B Code-block de validação When do campo
								Nil                  ,; // [09] A Lista de valores permitido do campo
								Nil                  ,; // [10] L Indica se o campo tem preenchimento obrigatório
								Nil                  ,; // [11] B Code-block de inicializacao do campo
								Nil                  ,; // [12] L Indica se trata de um campo chave
								.F.                  ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
								.T. )                   // [14] L Indica se o campo é virtual

			oStruct:AddField(	STR0045               ,; // [01] C Titulo do campo
								STR0045               ,; // [02] C ToolTip do campo
								"ZZY_TURNO"           ,; // [03] C identificador (ID) do Field
								"C"                   ,; // [04] C Tipo do campo
								TAMSX3("R6_TURNO")[1] ,; // [05] N Tamanho do campo
								0                     ,; // [06] N Decimal do campo
								Nil                   ,; // [07] B Code-block de validação do campo
								Nil                   ,; // [08] B Code-block de validação When do campo
								Nil                   ,; // [09] A Lista de valores permitido do campo
								Nil                   ,; // [10] L Indica se o campo tem preenchimento obrigatório
								Nil                   ,; // [11] B Code-block de inicializacao do campo
								Nil                   ,; // [12] L Indica se trata de um campo chave
								.F.                   ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
								.T. )                    // [14] L Indica se o campo é virtual

			oStruct:AddField(   STR0048              ,; // [01] C Titulo do campo
								STR0048              ,; // [02] C ToolTip do campo "Legenda"
								"ZZY_DTURNO"         ,; // [03] C identificador (ID) do Field
								"C"                  ,; // [04] C Tipo do campo
								TAMSX3("R6_DESC")[1] ,; // [05] N Tamanho do campo
								0                    ,; // [06] N Decimal do campo
								Nil                  ,; // [07] B Code-block de validação do campo
								Nil                  ,; // [08] B Code-block de validação When do campo
								Nil                  ,; // [09] A Lista de valores permitido do campo
								Nil                  ,; // [10] L Indica se o campo tem preenchimento obrigatório
								Nil                  ,; // [11] B Code-block de inicializacao do campo
								Nil                  ,; // [12] L Indica se trata de um campo chave
								.F.                  ,; // [13] L Indica se o campo pode receber valor em uma operação de update.
								.T. )                   // [14] L Indica se o campo é virtual

		EndIf
	Else
		If cTipo == "ZZZ"
			oStruct:AddField(   "ZZZ_ENTID",; // [01] C Nome do Campo
								"01"       ,; // [02] C Ordem
								STR0020    ,; // [03] C Titulo do campo
								STR0020    ,; // [04] C Descrição do campo
								Nil        ,; // [05] A Array com Help
								"C"        ,; // [06] C Tipo do campo
								""         ,; // [07] C Picture
								Nil        ,; // [08] B Bloco de Picture Var
								""         ,; // [09] C Consulta F3
								.F.        ,; // [10] L Indica se o campo é evitável
								Nil        ,; // [11] C Pasta do campo
								Nil        ,; // [12] C Agrupamento do campo
								Nil        ,; // [13] A Lista de valores permitido do campo (Combo)
								Nil        ,; // [14] N Tamanho Maximo da maior opção do combo
								Nil        ,; // [15] C Inicializador de Browse
								.T.        ,; // [16] L Indica se o campo é virtual
								Nil )         // [17] C Picture Variável
		EndIf

		If cTipo == "ZZY"
			oStruct:AddField(   "ZZY_TURNO",; // [01] C Nome do Campo
								"01"       ,; // [02] C Ordem
								STR0047    ,; // [03] C Titulo do campo
								STR0047    ,; // [04] C Descrição do campo "Legenda"
								Nil        ,; // [05] A Array com Help
								"C"        ,; // [06] C Tipo do campo
								""         ,; // [07] C Picture
								Nil        ,; // [08] B Bloco de Picture Var
								""         ,; // [09] C Consulta F3
								.F.        ,; // [10] L Indica se o campo é evitável
								Nil        ,; // [11] C Pasta do campo
								Nil        ,; // [12] C Agrupamento do campo
								Nil        ,; // [13] A Lista de valores permitido do campo (Combo)
								Nil        ,; // [14] N Tamanho Maximo da maior opção do combo
								Nil        ,; // [15] C Inicializador de Browse
								.T.        ,; // [16] L Indica se o campo é virtual
								Nil ) // [17] C Picture Variável

			oStruct:AddField(   "ZZY_DTURNO",; // [01] C Nome do Campo
								"02"        ,; // [02] C Ordem
								STR0048     ,; // [03] C Titulo do campo
								STR0048     ,; // [04] C Descrição do campo "Legenda"
								Nil         ,; // [05] A Array com Help
								"C"         ,; // [06] C Tipo do campo
								""          ,; // [07] C Picture
								Nil         ,; // [08] B Bloco de Picture Var
								""          ,; // [09] C Consulta F3
								.F.         ,; // [10] L Indica se o campo é evitável
								Nil         ,; // [11] C Pasta do campo
								Nil         ,; // [12] C Agrupamento do campo
								Nil         ,; // [13] A Lista de valores permitido do campo (Combo)
								Nil         ,; // [14] N Tamanho Maximo da maior opção do combo
								Nil         ,; // [15] C Inicializador de Browse
								.T.         ,; // [16] L Indica se o campo é virtual
								Nil )          // [17] C Picture Variável
		EndIf
	EndIf

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At352Vld
Pre validação para a ativação do model

@since 05/05/2015
@version 12
@param oModel, objeto, Model
@return lRet

/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At352Vld(oModel)

	Local lRet    := .T.
	Local lTecxRh := SuperGetMV("MV_TECXRH",,.F.)	// Define se o Gestao de Servico esta integrado com Rh do Microsiga Protheus.
	Local cCodCri := fRetCriter(,_CENTGPE_)					// Retorna o codigo do criterio ativo

	If !lTecxRh
		Help(,,'TECA352',,STR0034,1,0)//"O parâmetro de sistema de integração com o módulo de RH (MV_TECXRH) deverá estar habilitado."
		lRet := .F.
	EndIf

	If lRet .AND. Empty(cCodCri)
		Help(,,'TECA352',,STR0035,1,0)//"Não existe um critério de benefícios ativo no módulo SIGAGPE."
		lRet := .F.
	EndIf

	If lRet
		DbSelectArea("SJS")
		SJS->(DbSetOrder(1)) //JS_FILIAL, JS_CDAGRUP, JS_TABELA, JS_SEQ
		If !SJS->(DbSeek(xFilial("SJS")+cCodCri+_CENTGPE_))
		Help(,,'TECA352',, I18N( STR0020 + ' #1 ' + STR0036,{_CENTGPE_}),1,0) //'Entidade #1[Entidade]# não cadastrada no sequenciamento de critério de benefícios do módulo SIGAGPE.'
			lRet := .F.
		EndIf
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados()
Inicializa as informações da visualização da escala

@sample 	InitDados()

@param  	oModel, Objeto, objeto geral do model que será alterado

@author 	Serviços
@since 		09/06/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function InitDados(oModel)

	Local aBeneficios := GetABenTFF()
	Local cChave      := ""
	Local nI          := 0
	Local nX          := 0
	Local oMdlSJS     := oModel:GetModel("SJSMASTER")
	Local oMdlSLY     := oModel:GetModel("GPEA061_SLY")
	Local oMdlTMP     := oModel:GetModel("TMPDETAIL")
	Local oMdlZZY     := oModel:GetModel("ZZYDETAIL")

	If oModel:GetOperation() <> MODEL_OPERATION_INSERT
		For nI := 1 To oMdlTMP:Length()
			oMdlTMP:GoLine(nI)
			If ! Empty(oMdlTMP:GetValue("LY_CODIGO"))
				oMdlTMP:LoadValue("LY_DESBEN" , fInitBen(oMdlTMP))
				oMdlTMP:LoadValue("LY_DESCTIP", fInitTip(oMdlTMP))
				If ValType(oMdlTMP:GetValue("LY_DTINI")) == "C"
					oMdlTMP:LoadValue("LY_DTINI", StoD( oMdlTMP:GetValue("LY_DTINI") ) )
				EndIf
				If ValType(oMdlTMP:GetValue("LY_DTFIM")) == "C"
					oMdlTMP:LoadValue("LY_DTFIM", StoD( oMdlTMP:GetValue("LY_DTFIM") ) )
				EndIf
			Else
				oMdlTMP:LoadValue("LY_DESBEN" , "")
				oMdlTMP:LoadValue("LY_DESCTIP", "")	
			EndIf


		Next nI

		For nX := 1 To oMdlZZY:Length()
			oMdlZZY:GoLine(nX)

			For nI := 1 To oMdlSLY:Length()
				oMdlSLY:GoLine(nI)

				If ! Empty(oMdlSLY:GetValue("LY_CODIGO"))
					oMdlSLY:LoadValue("LY_DESBEN" , fInitBen(oMdlSLY))
					oMdlSLY:LoadValue("LY_DESCTIP", fInitTip(oMdlSLY))
					If ValType(oMdlSLY:GetValue("LY_DTINI")) == "C"
						oMdlSLY:LoadValue("LY_DTINI", StoD( oMdlSLY:GetValue("LY_DTINI") ) )
					EndIf
					If ValType(oMdlSLY:GetValue("LY_DTFIM")) == "C"
						oMdlSLY:LoadValue("LY_DTFIM", StoD( oMdlSLY:GetValue("LY_DTFIM") ) )
					EndIf
					//seta o campo legado
					cChave := oMdlSLY:GetValue("LY_FILIAL") + oMdlSLY:GetValue("LY_TIPO") + oMdlSLY:GetValue("LY_AGRUP") + oMdlSLY:GetValue("LY_ALIAS") + ;
								oMdlSLY:GetValue("LY_FILENT") + oMdlSLY:GetValue("LY_CHVENT") + oMdlSLY:GetValue("LY_CODIGO") + dTos(oMdlSLY:GetValue("LY_DTINI"))

					oMdlSLY:LoadValue( "LY_LEGADO", aScan(aBeneficios, {|x| x[3] == cChave }) > 0 )
				EndIf
			Next nI
		Next nX
	EndIf

	oMdlSJS:SetOnlyView(.T.)
	oMdlTMP:SetOnlyView(.T.)
	oMdlZZY:SetOnlyView(.T.)

Return(Nil)

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352FIL ( nTipo, cCdAgrup, cSeqCri, oMdl, cFilEnt )
Retorna a lista de beneficios

@param nTipo    - Tipo da Sequencia 1- Superior;2- Beneficio vinculado
@param cCdAgrup	- Codigo do Agrupamento
@param cSeqCri	- Sequencia Atual da Entidade
@param oMdl	    - modelo ativo
@param cFilEnt  - Filial da entidade

@return	aRet - Array com as informacoes dos beneficios

@author	 Serviços
@since   06/05/2015
@version P12
/*/
//------------------------------------------------------------------------------
Function At352FIL( nTipo, cCdAgrup, cSeqCri, oMdl, cFilEnt )

	Local aBenef    := {}
	Local cAliasSLY := ""
	Local cQuery    := ""
	Local nAddOr    := 0
	Local nI        := 0
	Local nOrdem    := 1
	Local nPosLeg   := aScan(oMdl:aHeader,{|x| x[2] = 'LY_LEGEND' })
	Local nPosTAB   := aScan(oMdl:aHeader,{|x| x[2] = 'LY_ALIAS' })
	Local oQuery    := Nil

	cQuery := "	SELECT SLY.LY_TIPO,"
	cQuery +=         "SLY.LY_CODIGO,"
	cQuery +=         "SLY.LY_PGDUT,"
	cQuery +=         "SLY.LY_PGSAB,"
	cQuery +=         "SLY.LY_PGDOM,"
	cQuery +=         "SLY.LY_PGFER,"
	cQuery +=         "SLY.LY_PGSUBS,"
	cQuery +=         "SLY.LY_PGFALT,"
	cQuery +=         "SLY.LY_PGAFAS,"
	cQuery +=         "SLY.LY_PGVAC,"
	cQuery +=         "SLY.LY_DIAS,"
	cQuery +=         "SLY.LY_DTINI,"
	cQuery +=         "SLY.LY_DTFIM,"
	cQuery +=         "SLY.LY_ALIAS"


	// Filtra os Beneficios da Sequencia Superior

	cQuery += "	FROM ? SLY"
	cQuery +=      " INNER JOIN ? SJS"
	cQuery +=        " ON SJS.JS_FILIAL = ?"
	cQuery +=           " AND SJS.JS_CDAGRUP = SLY.LY_AGRUP"
	cQuery +=           " AND SJS.JS_SEQ < ?"
	cQuery +=           " AND SJS.JS_TABELA = SLY.LY_ALIAS"
	cQuery +=           " AND SJS.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SLY.LY_FILIAL = ?
	cQuery +=       " AND SLY.LY_AGRUP = ?"

	cQuery +=      " AND ( "
	//Cargo
	If !Empty(_CCARGO_)
		cQuery +=              " ( SLY.LY_ALIAS = 'SQ3'"
		cQuery +=                " AND EXISTS ( SELECT 1"
		cQuery +=                             " FROM ? Q3"
		cQuery +=                             " WHERE Q3.Q3_FILIAL = SLY.LY_FILENT"
		cQuery +=                                   " AND Q3.Q3_CARGO = ?"
		cQuery +=                                   " AND Q3.Q3_CARGO = SLY.LY_CHVENT"
		cQuery +=                                   " AND Q3.D_E_L_E_T_ = ' ') )"
		nAddOr++
	EndIf
	//FUNÇÃO
	If !Empty(_CFUNCAO_)
		If nAddOr > 0
			cQuery +=        " OR "
		EndIf
		cQuery +=              " ( SLY.LY_ALIAS = 'SRJ'"
		cQuery +=                " AND EXISTS ( SELECT 1"
		cQuery +=                             " FROM ? RJ"
		cQuery +=                             " WHERE RJ.RJ_FILIAL = SLY.LY_FILENT"
		cQuery +=                                   " AND RJ.RJ_FUNCAO = ?"
		cQuery +=                                   " AND RJ.RJ_FUNCAO = SLY.LY_CHVENT"
		cQuery +=                                   " AND RJ.D_E_L_E_T_ = ' ') )"
		nAddOr++
	EndIf
	//TURNO
	If Empty(_CESCALA_)
		If nAddOr > 0
			cQuery +=        " OR "
		EndIf
		cQuery +=              " ( SLY.LY_ALIAS = 'SR6'"
		cQuery +=                " AND EXISTS ( SELECT 1"
		cQuery +=                             " FROM ? R6"
		cQuery +=                             " WHERE R6.R6_FILIAL = SLY.LY_FILENT"
		cQuery +=                                   " AND R6.R6_TURNO = ?"
		cQuery +=                                   " AND R6.R6_TURNO = SLY.LY_CHVENT"
		cQuery +=                                   " AND R6.D_E_L_E_T_ = ' ') )"
		nAddOr++
	Else
		If nAddOr > 0
			cQuery +=        " OR "
		EndIf
		cQuery +=              " ( SLY.LY_ALIAS = 'SR6'"
		cQuery +=                " AND EXISTS ( SELECT 1"
		cQuery +=                             " FROM ? R6"
		cQuery +=                                  " INNER JOIN ? TDX"
		cQuery +=                                          " ON TDX.TDX_FILIAL = ?"
		cQuery +=                                             " AND TDX.TDX_CODTDW = ?"
		cQuery +=                                             " AND TDX.TDX_TURNO = R6.R6_TURNO"
		cQuery +=                                             " AND TDX.D_E_L_E_T_ = ' '"
		cQuery +=                             " WHERE R6.R6_FILIAL = SLY.LY_FILENT"
		cQuery +=                                   " AND R6.R6_TURNO = SLY.LY_CHVENT"
		cQuery +=                                   " AND R6.D_E_L_E_T_ = ' ') )"
		nAddOr++
	EndIf

	//LOCAL DE TRABALHO
	If !Empty(_CLOCAL_)
		If nAddOr > 0
			cQuery +=        " OR "
		EndIf
		cQuery +=              " ( SLY.LY_ALIAS = 'ABS'"
		cQuery +=                " AND EXISTS (SELECT 1"
		cQuery +=                             " FROM ? ABS"
		cQuery +=                             " WHERE ABS.ABS_FILIAL = SLY.LY_FILENT"
		cQuery +=                                   " AND ABS.ABS_LOCAL = ?"
		cQuery +=                                   " AND ABS.ABS_LOCAL = SLY.LY_CHVENT"
		cQuery +=                                   " AND ABS.D_E_L_E_T_ = ' ') )"
		cQuery +=              " OR"
		cQuery +=              " ( SLY.LY_ALIAS = 'CTT'"
		cQuery +=                " AND EXISTS (SELECT 1"
		cQuery +=                             " FROM ? CTT"
		cQuery +=                                  " INNER JOIN ? ABS"
		cQuery +=                                          " ON ABS.ABS_FILIAL = ?"
		cQuery +=                                             " AND ABS.ABS_LOCAL = ?"
		cQuery +=                                             " AND (ABS.ABS_FILCC = ' ' OR ABS.ABS_FILCC = CTT.CTT_FILIAL)"
		cQuery +=                                             " AND ABS.ABS_CCUSTO = CTT.CTT_CUSTO"
		cQuery +=                                             " AND ABS.D_E_L_E_T_ = ' '"
		cQuery +=                             " WHERE CTT.CTT_FILIAL = SLY.LY_FILENT"
		cQuery +=                                   " AND ABS.ABS_CCUSTO = SLY.LY_CHVENT"
		cQuery +=                                   " AND ABS.D_E_L_E_T_ = ' ') )"
	EndIf

	If !Empty(_CFILENT_)//Filial
		If nAddOr > 0
			cQuery +=        " OR "
		EndIf
		cQuery +=              " ( SLY.LY_ALIAS = 'SM0'"
		cQuery +=                " AND SLY.LY_CHVENT = ? )"
		nAddOr++
	EndIf

	cQuery +=           ") "
	cQuery +=       " AND SLY.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SJS.JS_SEQ"

	cQuery := ChangeQuery(cQuery)
	oQuery := FwExecStatement():New(cQuery)

	oQuery:SetUnsafe( nOrdem++, RetSQLName("SLY") )
	oQuery:SetUnsafe( nOrdem++, RetSQLName("SJS") )
	oQuery:SetString( nOrdem++, xFilial("SJS") )
	oQuery:SetString( nOrdem++, cSeqCri )
	oQuery:SetString( nOrdem++, xFilial("SLY") )
	oQuery:SetString( nOrdem++, cCdAgrup)

	If !Empty(_CCARGO_)
		oQuery:SetUnsafe( nOrdem++, RetSQLName("SQ3") )
		oQuery:SetString( nOrdem++, _CCARGO_)
	EndIf
	If !Empty(_CFUNCAO_)
		oQuery:SetUnsafe( nOrdem++, RetSQLName("SRJ") )
		oQuery:SetString( nOrdem++, _CFUNCAO_)
	EndIf

	If Empty(_CESCALA_)
		oQuery:SetUnsafe( nOrdem++, RetSQLName("SR6") )
		oQuery:SetString( nOrdem++, _CTURNO_ )
	Else
		oQuery:SetUnsafe( nOrdem++, RetSQLName("SR6") )
		oQuery:SetUnsafe( nOrdem++, RetSQLName("TDX") )
		oQuery:SetString( nOrdem++, xFilial("TDX") )
		oQuery:SetString( nOrdem++, _CESCALA_)
	EndIf

	If !Empty(_CLOCAL_)
		oQuery:SetUnsafe( nOrdem++, RetSQLName("ABS") )
		oQuery:SetString( nOrdem++, _CLOCAL_)
		oQuery:SetUnsafe( nOrdem++, RetSQLName("CTT") )
		oQuery:SetUnsafe( nOrdem++, RetSQLName("ABS") )
		oQuery:SetString( nOrdem++, xFilial("ABS") )
		oQuery:SetString( nOrdem++, _CLOCAL_)
	EndIf

	If !Empty(_CFILENT_)
		oQuery:SetString( nOrdem++, _CFILENT_)
	EndIf

	cAliasSLY := oQuery:OpenAlias()

	oQuery:Destroy()
	FwFreeObj( oQuery )

	aBenef := FwLoadByAlias( oMdl, cAliasSLY )

	For nI := 1 To LEN(aBenef)
		DO CASE
			CASE aBenef[nI][2][nPosTab] == 'SM0'
				aBenef[nI][2][nPosLeg] := "BR_VERMELHO"
			CASE aBenef[nI][2][nPosTab] == 'SA1'
				aBenef[nI][2][nPosLeg] := "BR_VERDE"
			CASE aBenef[nI][2][nPosTab] == 'ABS'
				aBenef[nI][2][nPosLeg] := "BR_AMARELO"
			CASE aBenef[nI][2][nPosTab] == 'SQ3'
				aBenef[nI][2][nPosLeg] := "BR_AZUL"
			CASE aBenef[nI][2][nPosTab] == 'SRJ'
				aBenef[nI][2][nPosLeg] := "BR_LARANJA"
			CASE aBenef[nI][2][nPosTab] == 'SR6'
				aBenef[nI][2][nPosLeg] := "BR_CINZA"
			CASE aBenef[nI][2][nPosTab] == 'CTT'
				aBenef[nI][2][nPosLeg] := "BR_BRANCO"
		ENDCASE
	NEXT nI

	DbSelectArea(cAliasSLY)
	(cAliasSLY)->(DbCloseArea())

Return aBenef

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352TUR
Retorna os turnos do item do RH

@sample 	At352TUR(oModel)
@param		oModel    	- Modelo

@return	aRet - Array com as informacoes dos beneficios

@author	Serviços
@since		06/05/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At352TUR(oModel)

	Local aTurno    := {}
	Local cAlias    := ""
	Local cCodTFF   := _CCODTFF_
	Local cEscala   := _CESCALA_
	Local cQuery    := ""
	Local cTurno    := _CTURNO_
	Local nOrdem    := 1
	Local oQuery    := Nil

	Default cCodTFF := ""
	Default cEscala := ""
	Default cTurno  := ""

	If _lFacilit_
		cCodTFF := _CCODTXS_
	Endif

	// garante preenchimento em forma de string quando valor Nil nas variáveis static

	cQuery := " SELECT DISTINCT ? || SR6.R6_TURNO AS ZZY_CHVENT,"
	cQuery +=                 " ? AS ZZY_CODTFF,"
	cQuery +=                 " R6_DESC AS ZZY_DTURNO,"
	cQuery +=                 " R6_TURNO AS ZZY_TURNO"
	// Buscar o Turno da Escala
	If !Empty(cEscala)
		cQuery += " FROM ? TDX"
		cQuery +=      " JOIN ? SR6"
		cQuery +=        " ON R6_FILIAL = ?"
		cQuery +=           " AND R6_TURNO = TDX_TURNO"
		cQuery +=           " AND SR6.D_E_L_E_T_ = ' '"
		cQuery += " WHERE TDX.TDX_FILIAL = ?"
		cQuery +=       " AND TDX.TDX_CODTDW = ?"
		cQuery +=       " AND TDX.D_E_L_E_T_= ' '"
		cQuery += " ORDER BY ZZY_CHVENT"

		cQuery := ChangeQuery(cQuery)
		oQuery := FwExecStatement():New(cQuery)

		oQuery:SetString( nOrdem++, cCodTFF )
		oQuery:SetString( nOrdem++, cCodTFF )
		oQuery:SetUnsafe( nOrdem++, RetSQLName("TDX") )
		oQuery:SetUnsafe( nOrdem++, RetSQLName("SR6") )
		oQuery:SetString( nOrdem++, xFilial("SR6") )
		oQuery:SetString( nOrdem++, xFilial("TDX") )
		oQuery:SetString( nOrdem++, cEscala )
	Else
		cQuery += " FROM ? SR6"
		cQuery += " WHERE R6_FILIAL = ?"
		cQuery +=       " AND R6_TURNO = ?"
		cQuery +=       " AND SR6.D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY ZZY_CHVENT"

		cQuery := ChangeQuery(cQuery)
		oQuery := FwExecStatement():New(cQuery)

		oQuery:SetString( nOrdem++, cCodTFF )
		oQuery:SetString( nOrdem++, cCodTFF )
		oQuery:SetUnsafe( nOrdem++, RetSQLName("SR6") )
		oQuery:SetString( nOrdem++, xFilial("SR6") )
		oQuery:SetString( nOrdem++, cTurno )
	EndIf

	cAlias := oQuery:OpenAlias()
	oQuery:Destroy()
	FwFreeObj( oQuery )

	aTurno := FwLoadByAlias( oModel, cAlias )

	DbSelectArea(cAlias)
	(cAlias)->(DbCloseArea())

Return aTurno

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352ALEG
Legenda

@sample 	At352ALEG()
@author	Serviços
@since		08/05/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Function At352Leg()

	Local oLegenda  := FWLegend():New()

	oLegenda:Add("", "BR_VERMELHO", STR0039) // "Filial"
	oLegenda:Add("", "BR_VERDE"   , STR0040) // "Cliente"
	oLegenda:Add("", "BR_AMARELO" , STR0041) // "Local de Pagamento"
	oLegenda:Add("", "BR_AZUL"    , "Cargo") //Cargo
	oLegenda:Add("", "BR_LARANJA" , "Função")//Função
	oLegenda:Add("", "BR_CINZA"   , "Turno") //Turno
	oLegenda:Add("", "BR_BRANCO"  , "Centro de custo")//Centro de custo


	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352CPL()
Efetua a inicialização dos campos

@sample 	At352CPL(cCampo,oModel)
@param		cCampo	Caracter Nome do campo
@param		oModel	Objeto
@author	Serviços
@since		26/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At352CPL(cCampo,oModel)

	Local cCodCri  := fRetCriter(,_CENTGPE_)
	Local cRet     := ''
	Local oMdlZZY  := Nil

	DO CASE
		CASE cCampo == "ZZZ_ENTID"
			cRet := "TURNO DO LOCAL DE ATENDIMENTO"
		CASE cCampo == "LY_FILIAL"
			cRet := xFilial("SLY")
		CASE cCampo == "LY_AGRUP"
			cRet := cCodCri
		CASE cCampo == "LY_ALIAS"
			cRet := _CENTGPE_
		CASE cCampo == "LY_FILENT"
			cRet := xFilial("TFF")
		CASE cCampo == "LY_CHVENT"
			oMdlZZY:= oModel:GetModel("ZZYDETAIL")
			cRet := oMdlZZY:GetValue("ZZY_CHVENT")
	ENDCASE

RETURN cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At352Res()
Efetua a edição dos campos do item do RH

@sample 	At352Res(oModel,cPlan)
@param		oModel	Objeto
@param		cPlan	Caracter Codigo do Planilha
@author	Serviços
@since		26/06/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At352Res(oModel,cPlan)
	Local lRet 	:= .T.
	Local aRevis  := AT870GETRE() // Retorna os dados da revisao

	// Caso alteracao
	If oModel:GETOPERATION() = MODEL_OPERATION_UPDATE
		If !oModel:IsInserted()
			// Verifica se existe uma planilha ja cadastrada para o local de atendimento
			If _lRevisao_ .And. oModel:GetValue("LY_LEGADO")
				Return .F.
			EndIf
			If !Empty(cPlan)
				If Len(aRevis) > 0
					// Se o tipo de revisao Realinhamento nao pode ser alterado
					If aRevis[1][2] <> '1'
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

RETURN lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At352Sly(oModel)

Validação das datas dos beneficios na efetivação da revisão do contrato

@sample     At870Sly(oModel)

@return

@author     serviços
@since      01/09/2015
@version    P12
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At352Sly(oMdl740)

	Local cCodCri  := ""
	Local lRet     := .F.
	Local nI       := 0
	Local oMdl352  := Nil
	Local oMdlSly  := Nil
	Local oMdlTFF  := oMdl740:GetModel( 'TFF_RH' )
	Local oMdlTFL  := oMdl740:GetModel( 'TFL_LOC' )
	Local TFFDtFim := ""
	Local xI       := 0

	_CENTGPE_ := 'TDX'
	_REGTUR_  := 0
	_CPLAN_   := ''

	cCodCri := fRetCriter(,_CENTGPE_)	// Retorna o codigo do criterio ativo

	If Empty(oMdlTFF:GetValue("TFF_ESCALA"))
		If !Empty(oMdlTFF:GetValue("TFF_TURNO"))
			_CTURNO_  := oMdlTFF:GetValue("TFF_TURNO")
			_CESCALA_ := ''
		EndIF
	Else
		_CTURNO_  := ''
		_CESCALA_ := oMdlTFF:GetValue("TFF_ESCALA")
	EndIF

	//Posiciona no model da TECA352
	DbSelectArea("SJS")
	SJS->(DbSetOrder(1)) //JS_FILIAL, JS_CDAGRUP, JS_TABELA, JS_SEQ
	SJS->(DbSeek(xFilial("SJS")+cCodCri+_CENTGPE_))

	_CLOCAL_  := oMdlTFL:GetValue("TFL_LOCAL")
	_CCODTFF_ := oMdlTFF:GetValue("TFF_COD")

	oMdl352:=FWLoadModel( 'TECA352' )
	oMdl352:SetOperation(MODEL_OPERATION_UPDATE)
	oMdl352:Activate()

	oMdlSly:=oMdl352:GetModel('GPEA061_SLY')

	For nI:= 1 to oMdlTFF:length()
		oMdlTFF:GoLine(nI)
		TFFDtFim := oMdlTFF:GetValue("TFF_PERFIM")
		//se a TFF estiver encerrada altera a data final do recebimento dos beneficios
		If oMdlTFF:GetValue("TFF_ENCE") == '1'
			For xI:= 1 to oMdlSly:length()
				oMdlSly:GoLine(xI)
				//valida a datafim em relação a TFF
				If ! empty(oMdlSly:GetValue("LY_DTFIM"))
					If oMdlSly:GetValue("LY_DTFIM") > TFFDtFim
						oMdlSly:SetValue("LY_DTFIM",TFFDtFim )
					Endif
				Else
					oMdlSly:SetValue("LY_DTFIM",TFFDtFim )
				Endif
				lRet:=.T.
			Next xI
		Endif
		lRet:=.T.
	Next nI

	lRet := lRet .And. oMdl352:VldData() .And. oMdl352:CommitData()

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At352Cmt
@description Commit do modelo, realizado tratativa para quando for na revisão não deletar a linha no orçamento anterior
@return aBenefEx
@author Augusto Albuquerque
@since  10/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At352Cmt( oModel )
	Local aBenefTFF := {}
	Local cChaveSLY := ""
	Local lRet      := .T.
	Local lRevisa   := IsInCallStack("At870Revis")
	Local nX        := 0
	Local oMdlSLY   := oModel:GetModel( 'GPEA061_SLY' )

	aBenefTFF := GetABenTFF()

	If oModel:GetOperation() <> MODEL_OPERATION_DELETE .AND. lRevisa
		For nX := 1 to oMdlSly:length()
			oMdlSly:GoLine(nX)
			cChaveSLY := oMdlSly:GetValue("LY_FILIAL")+oMdlSly:GetValue("LY_TIPO")+oMdlSly:GetValue("LY_AGRUP")+oMdlSly:GetValue("LY_ALIAS")+oMdlSly:GetValue("LY_FILENT")+oMdlSly:GetValue("LY_CHVENT")+oMdlSly:GetValue("LY_CODIGO")+dTos(oMdlSly:GetValue("LY_DTINI"))
			If SLY->(DbSeek(cChaveSLY))
				aAdd( aBenRev, {oMdlSly:IsDeleted(),;
								{ SLY->LY_FILIAL,oMdlSly:GetValue("LY_FILIAL") },;
								{ SLY->LY_TIPO	,oMdlSly:GetValue("LY_TIPO") },;
								{ SLY->LY_AGRUP	,oMdlSly:GetValue("LY_AGRUP") },;
								{ SLY->LY_ALIAS	,oMdlSly:GetValue("LY_ALIAS")},;
								{ SLY->LY_FILENT,oMdlSly:GetValue("LY_FILENT") },;
								{ SLY->LY_CHVENT,oMdlSly:GetValue("LY_CHVENT") },;
								{ SLY->LY_CODIGO,oMdlSly:GetValue("LY_CODIGO") },;
								{ SLY->LY_PGDUT	,oMdlSly:GetValue("LY_PGDUT") },;
								{ SLY->LY_PGSAB	,oMdlSly:GetValue("LY_PGSAB") },;
								{ SLY->LY_PGDOM	,oMdlSly:GetValue("LY_PGDOM") },;
								{ SLY->LY_PGFER	,oMdlSly:GetValue("LY_PGDOM") },;
								{ SLY->LY_PGSUBS,oMdlSly:GetValue("LY_PGSUBS") },;
								{ SLY->LY_PGFALT,oMdlSly:GetValue("LY_PGFALT") },;
								{ SLY->LY_PGVAC	,oMdlSly:GetValue("LY_PGVAC") },;
								{ SLY->LY_DIAS	,oMdlSly:GetValue("LY_DIAS") },;
								{ SLY->LY_DTINI	,oMdlSly:GetValue("LY_DTINI") },;
								{ SLY->LY_DTFIM	,oMdlSly:GetValue("LY_DTFIM") },;
								{ SLY->LY_PGAFAS,oMdlSly:GetValue("LY_PGAFAS")}})
			Else
				aAdd( aBenRev, {.T.} )
			Endif
			If oMdlSly:IsDeleted()
				nPosDel := aScan(aBenefTFF,{|x| x[3] = cChaveSLY})

				If nPosDel > 0
					AADD(aBenefEx, {aBenefTFF[nPosDel,1],aBenefTFF[nPosDel,2]}) //Adiciona o RECNO a ser desdeletado do orçamento anterior à revisão.
				EndIf
			EndIf
		Next nX
	EndIf

	If _lFacilit_
		For nX := 1 to oMdlSly:length()
			oMdlSly:GoLine(nX)
			If !oMdlSly:IsDeleted() .And. oMdlSly:GetValue("LY_ALIAS") <> "TXS"
				oMdlSly:LoadValue("LY_ALIAS","TXS")
			EndIf
		Next nX
	EndIf

	lRet := FwFormCommit( oModel )

	// Se a persistência do modelo ocorrer corretamente, atualiza a planilha
	If (lRet) .And. !_lFacilit_
		AT352UpdSh(oModel)
	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At352LimpA
@description Limpa o Array estatico
@return
@author Augusto Albuquerque
@since  10/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At352LimpA()
aBenefEx := {}
aBenRev	:= {}
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetABene
@description Retorna o array estatico
@return aBenefEx
@author Augusto Albuquerque
@since  10/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GetABene()
Return aBenefEx

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetABenfs
@description Retorna o array estatico
@return aBenefEx
@author Augusto Albuquerque
@since  10/06/2021
/*/
//--------------------------------------------------------------------------------------------------------------------
Function GetABenfs()
Return aBenRev

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT352UpdSh
    Atualiza a planilha de cálculo com o valor do benefício incluído/alterado.
    @type Function
    @version 12.1.2210
    @author Guilherme Bigois
    @since 04/09/2023
    @param oModel, Object, Modelo de dados completo da rotina atual
    @return Variant, Retorno nulo fixado
/*/
//--------------------------------------------------------------------------------------------------------------------
Function AT352UpdSh(oModel As Object) As Variant
    // Variáveis locais
	Local aArea     := FwGetArea()    // Áreas anteriormente posicionadas
    Local cXML      := _OMDLTFF_:GetValue("TFF_CALCMD") // Memória (XML) de cálculo da planilha
    Local cCode     := "" // Código do benefício na RFO
    Local cType     := "" // Tipo do benefício
    Local cDesc     := "" // Descrição do benefício
    Local cConfig   := _OMDLTFF_:GetValue("TFF_PLACOD") // Configuração da planilha
	Local cConRev	:= _OMDLTFF_:GetValue("TFF_PLAREV")
    Local cNickForm := "" // Apelido do variável referente à fórmula
    Local cNickPorc := "" // Apelido do variável referente ao percentual
    Local cFormula  := "=0" // Fórmula da planilha de cálculo
	Local cQuery	:= ""
	Local cAliasTDZ := ""
	Local lObrigat  := .F.
    Local nX        := 0 // Contador do laço da tabela TCX
    Local nValue    := 0 // Valor para o benefício atual que atualizará o da planilha
    Local nLine     := 3 // Valor para o benefício atual que atualizará o da planilha
    Local oMdlSLY   := oModel:GetModel("GPEA061_SLY")    // Submodelo de benefícios vinculados (SLY)
	Local aChgLn    := oMdlSLY:GetLinesChanged()
    Local oSheet    := GsPlan():New()//FwUIWorkSheet():New(NIL, .F., NIL, 11, "PLAN_LOAD")    // Objeto da planilha XML
	Local oQuery	:= Nil
	Local nValueDesc:= 0
	Local nNickPerc := ""
	
    // Inicia a sequencia de processamento
    BEGIN SEQUENCE
        // Não executa a atualização de planilha se não houver linhas atualizadas
        If (Empty(aChgLn))
            BREAK
        EndIf

        // Gera exceção se o campo de apelido do percentual não for encontrado
        If (TDZ->(ColumnPos("TDZ_NICKVL")) == 0)
            Help(NIL, NIL, "AT352_MISSING_FIELD", NIL, 'Contate o time de suporte TOTVS ou realize a criação do campo através do SIGACFG.', 1, 0, NIL, NIL, NIL, NIL, .F.,;
                {'Campo TDZ_NICKVL não existente na base de dados.'})
            BREAK
        EndIf

        // Não executa a atualização da planilha se não for encontrada para posto atual
        If (Empty(cXML))
            BREAK
        EndIf

        // Instancia e carrega o objeto da planilha de configurações de verbas
        oSheet:LoadXMLModel(cXML)

        For nX := 1 To Len(aChgLn)
            oMdlSLY:GoLine(aChgLn[nX])
			
			cType := oMdlSLY:GetValue("LY_TIPO")
			cCode := oMdlSLY:GetValue("LY_CODIGO")

			cAliasTDZ := GetNextAlias()
		
			cQuery	:= " SELECT TDZ.TDZ_VLRDIF, TDZ.TDZ_NICK, TDZ.TDZ_FORMUL, TDZ.TDZ_NICKVL, TDZ.TDZ_OBRGT "
			If _lPercDesc
				cQuery	+= ", TDZ.TDZ_NICKPE, TDZ.TDZ_PERC "
			EndIf
			cQuery	+= " FROM ? TDZ "
			cQuery	+= " INNER JOIN ? ABW "
			cQuery	+= " ON ABW.ABW_FILIAL = ? AND ABW.ABW_CODTCW = TDZ.TDZ_CODTCW AND ABW.ABW_RESTCW = TDZ.TDZ_REVISA "
			cQuery	+= " AND ABW.D_E_L_E_T_ = ' ' "
			cQuery	+= " WHERE TDZ.TDZ_FILIAL = ? AND "
			cQuery	+= " ABW.ABW_CODIGO = ? AND "
			cQuery	+= " ABW.ABW_REVISA = ? AND "
			cQuery	+= " TDZ.TDZ_TIPBEN = ? AND "
			cQuery	+= " TDZ.TDZ_ITEM <> '001' AND "
			cQuery	+= " TDZ.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery( cQuery )
			oQuery := FwExecStatement():New( cQuery )

			oQuery:SetUnsafe( 1, RetSQLName("TDZ") )
			oQuery:SetUnsafe( 2, RetSQLName("ABW") )
			oQuery:SetString( 3, xFilial('ABW') ) //Filial
			oQuery:SetString( 4, xFilial('TDZ') ) //Filial
			oQuery:SetString( 5, cConfig ) //Contrato
			oQuery:SetString( 6, cConRev ) //Revisão do contrato
			oQuery:SetString( 7, cType ) //Tipo de benefício

			cAliasTDZ := oQuery:OpenAlias()
			oQuery:Destroy()
			oQuery := Nil

			If (cAliasTDZ)->( !EoF() )
				cNickForm := AllTrim((cAliasTDZ)->TDZ_NICK)
				cFormula := AllTrim((cAliasTDZ)->TDZ_FORMUL)
				cNickPorc := AllTrim((cAliasTDZ)->TDZ_NICKVL)
				lObrigat := (AllTrim((cAliasTDZ)->TDZ_OBRGT) <> "2")

				cDesc  := At996aDsc( cCode, cType, .T. )

				nValue := At996aVlrB( AllTrim( cCode ), cType, .T. )

				If _lPercDesc
					If nValue == 0
						nValueDesc := 0
					Else
						nValueDesc:= At996aVlrB( AllTrim( cCode ), cType, .T., "PERC" )
					EndIf
					nNickPerc := AllTrim((cAliasTDZ)->TDZ_NICKPE)
				EndIf
			
				If (!Empty(cDesc) .And. !Empty(cNickForm) .And. !Empty(cNickPorc))
					If oMdlSLY:IsDeleted()
						If oSheet:CellExists( cNickPorc )
							oSheet:SetCellValue( cNickPorc, 0 )
						EndIf
						If _lPercDesc
							If oSheet:CellExists( nNickPerc )
								oSheet:SetCellValue( nNickPerc, 0 )
							EndIf
						EndIf
					Else
						If oSheet:CellExists( cNickPorc )
							oSheet:SetCellValue( cNickPorc, nValue )
							If _lPercDesc
								If oSheet:CellExists( nNickPerc )
									oSheet:SetCellValue( nNickPerc, nValueDesc )
								EndIf
							EndIf
							/*
							//AJUSTE DE DESCRIÇÃO DO BENEFÍCIO: Como não tem nickname, pega a célula da "esquerda" do cNickPorc
							cCellName := UPPER(oSheet:GetCellPos(cNickPorc):Name)
							If AT('B', cCellName) == 1
								cCellDesc := STUFF(cCellName, 1, 1, "A")
								oSheet:SetCellValue(cCellDesc, cDesc)
							EndIf*/
						Else
							While ValType(oSheet:GetCellPos("I" + CValToChar(nLine))) == "O" .And. AllTrim( oSheet:GetCellValue( "I" + CValToChar(nLine) ) ) <> AllTrim( cDesc )
								nLine++
							End

							If !Empty( cFormula )
								cFormula := "=" + cFormula
							EndIf
							
							//DESCRIÇÃO - COLUNA I
							oSheet:addCell("I", nLine, "", "", AllTrim(cDesc), "!@")
							//VALOR - COLUNA J
							oSheet:addCell("J", nLine, cNickPorc, "", nValue, "@E 999,999,999.99")
							//FORMULA - COLUNA K
							oSheet:addCell("K", nLine, cNickForm, cFormula, 0, "@E 999,999,999.99")

							If _lPercDesc
								//FORMULA - COLUNA L
								oSheet:addCell("L", nLine, nNickPerc, "", nValueDesc, "@E 999,999,999.99")
							EndIf

						EndIf
					EndIf
				EndIf
			EndIf
			(cAliasTDZ)->(dbCloseArea())
        Next nX

        // Captura o XML atualizado
        cXML := oSheet:GetXMLModel()
        _OMDLTFF_:SetValue("TFF_CALCMD", cXML)
    END SEQUENCE

    // Remove os objetos/arrays da memória
    FwFreeArray(aArea)
    FwFreeArray(aChgLn)
Return (NIL)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At352VldLin
    Valida se o delete do benefício é permitido na revisão do contrato. Só é permitido excluir benefícios incluídos na revisão.
    @type Function
    @version 1.0
    @author Breno Gomes
    @since  26/01/2026
    @param  oModel, Object, Modelo de dados completo da rotina atual
	@param  cAction, Character, Ação sendo realizada (INSERT, UPDATE, DELETE)
    @return lRet, Logical, Indica se a ação é permitida
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At352VldLin(oModel, cAction)
	Local lRet := .T.

	If cAction == 'DELETE' .And. _lRevisao_ .And. oModel:GetValue("LY_LEGADO") 
		Help( , , 'HELP', , "Item de contrato anterior não pode ser excluído.", 1, 0 )
		lRet := .F.
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at352Model
	Retorna o modelo statico ativo do TECA740
@sample 	at352Model()
@since		06/04/2026
@author 	jack.junior
/*/
//------------------------------------------------------------------------------
Function at352Model()
Return oMdlOrc
