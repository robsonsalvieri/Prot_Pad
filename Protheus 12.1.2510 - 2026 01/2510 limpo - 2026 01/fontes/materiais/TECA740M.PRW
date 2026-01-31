#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA740M.CH"

#DEFINE DEF_TITULO_DO_CAMPO		01	//Titulo do campo
#DEFINE DEF_TOOLTIP_DO_CAMPO	02	//ToolTip do campo
#DEFINE DEF_IDENTIFICADOR		03	//identificador (ID) do Field
#DEFINE DEF_TIPO_DO_CAMPO		04	//Tipo do campo
#DEFINE DEF_TAMANHO_DO_CAMPO	05	//Tamanho do campo
#DEFINE DEF_DECIMAL_DO_CAMPO	06	//Decimal do campo
#DEFINE DEF_CODEBLOCK_VALID		07	//Code-block de validação do campo
#DEFINE DEF_CODEBLOCK_WHEN		08	//Code-block de validação When do campo
#DEFINE DEF_LISTA_VAL			09	//Lista de valores permitido do campo
#DEFINE DEF_OBRIGAT				10	//Indica se o campo tem preenchimento obrigatório
#DEFINE DEF_CODEBLOCK_INIT		11	//Code-block de inicializacao do campo
#DEFINE DEF_CAMPO_CHAVE			12	//Indica se trata de um campo chave
#DEFINE DEF_RECEBE_VAL			13	//Indica se o campo pode receber valor em uma operação de update.
#DEFINE DEF_VIRTUAL				14	//Indica se o campo é virtual
#DEFINE DEF_VALID_USER			15	//Valid do usuario

#DEFINE DEF_ORDEM				16	//Ordem do campo
#DEFINE DEF_HELP				17	//Array com o Help dos campos
#DEFINE DEF_PICTURE				18	//Picture do campo
#DEFINE DEF_PICT_VAR			19	//Bloco de picture Var
#DEFINE DEF_LOOKUP				20	//Chave para ser usado no LooKUp
#DEFINE DEF_CAN_CHANGE			21	//Logico dizendo se o campo pode ser alterado
#DEFINE DEF_ID_FOLDER			22	//Id da Folder onde o field esta
#DEFINE DEF_ID_GROUP			23	//Id do Group onde o field esta
#DEFINE DEF_COMBO_VAL			24	//Array com os Valores do combo
#DEFINE DEF_TAM_MAX_COMBO		25	//Tamanho maximo da maior opção do combo
#DEFINE DEF_INIC_BROWSE			26	//Inicializador do Browse
#DEFINE DEF_PICTURE_VARIAVEL	27	//Picture variavel
#DEFINE DEF_INSERT_LINE			28	//Se verdadeiro, indica pulo de linha após o campo
#DEFINE DEF_WIDTH				29	//Largura fixa da apresentação do campo
#DEFINE DEF_TIPO_CAMPO_VIEW		30	//Tipo do campo

#DEFINE QUANTIDADE_DEFS			30	//Quantidade de DEFs

Static aTDZCarga:= {} //Array de carga de dados no grid (INITDADOS)
Static aFieldsTDZ := {} //Array com os campos TDZ
Static cCodTFF	:= "" //Código do Posto (TFF)
Static cConfCal := "" //Código da Configuração de cálculo
Static cXMLPla  := "" //Código da Planilha do Posto ou da configuração de cálculo
Static oPlanXml := Nil//Objeto da Planilha XML
Static oMdl740  := Nil//Modelo orçamento
Static lAparece	:= .T.//Define se aparece o botão de "Confirmar" na tela

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA740M

@description  Configuração de verbas adicionais relacionadas aos benefícios - Folha da planilha de despesas (TDZ).
@where	Outras ações do orçamento
@Param  oModel - Modelo RH (TFF)

@author	Anderson F. Gomes
@since	28/03/2024
/*/
//------------------------------------------------------------------------------
Function TECA740M( oModel )
	Local oView 	:= FwViewActive()
	Local aFldPai	:= oView:GetFolderActive( "ABAS", 2 ) //1-Local de Atendimento, 2-RH, 4-Totais
	Local aSaveLines:= FWSaveRows()
	Local aButtons  := {}
	Local cCodPla	:= ""
	Local cCodRev	:= ""
	Local nOk		:= 2 //0-Confirmar, 1-Cancelar
	Local lRet		:= .T.
	Local nOpc 		:= 0
	Local cTitle	:= STR0001

	If aFldPai[1] == 2 //Verifica se está na Aba de RH - Postos

		cCodPla := oModel:GetValue( "TFF_RH", "TFF_PLACOD" )
		cCodRev := oModel:GetValue( "TFF_RH", "TFF_PLAREV" )
		cXMLPla := oModel:GetValue( "TFF_RH", "TFF_CALCMD" )
		cCodTFF := oModel:GetValue( "TFF_RH", "TFF_COD" )

		oMdl740 := oModel

		If !Empty( cCodPla ) .And. !Empty( cXMLPla ) //Verifica se há planilha no Posto

			nOpc := oMdl740:GetOperation()

			//Se for visualização retira o botão de "Confirmar"
			If nOpc == 1
				lAparece := .F.
				cTitle += " - "+STR0015 //"Visualizar"
			EndIf

			aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{lAparece,Nil}/*Confirmar*/,{.T.,Nil}/*Cancelar*/,{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

			cConfCal:= Posicione( "ABW", 1, FWxFilial( "ABW" ) + cCodPla + cCodRev, "ABW_CODTCW" ) //Cód. Configuração de cálculo
		
			FwMsgRun(Nil,{||nOk := FwExecView(cTitle,; //cTitulo - "Ajuste de Verbas Adicionais - Benefícios"
											"VIEWDEF.TECA740M",; //cPrograma
											MODEL_OPERATION_INSERT,; //nOperation
											/*oOwner*/,; //oDlg
											{|| TecModFalse(!lAparece)},; //bCloseOnOK
											/*bOk*/,; //bOk
											55,; //nPercReducao
											aButtons,; //aEnableButtons
											{|| TecModFalse(.T.)},)}; //bCancel
					,Nil, STR0002)//"Carregando dados..."
			
		Else
			lRet := .F.
			MsgAlert( STR0003 )//"Carregue a planilha de preço para o posto selecionado."
		EndIf
	Else
		lRet := .F.
		MsgAlert( STR0004 )//"É necessário selecionar um posto para utilização dessa função."
	EndIf

	If nOk == 1 .Or. !lAparece
		lRet := .F.
	EndIf

	If nOk == 0 .And. lRet
		//Update da TFF (Recursos Humanos)
		FwMsgRun( Nil, { || at740MUpdt( oModel ) }, Nil, STR0014 )//"Salvando dados..."
		oView:Refresh( "VIEW_RH" ) //Refresh da view necessário caso tenha usado atalho F11
	EndIf

	at740MLimp() //Limpa variáveis estáticas

	FWRestRows( aSaveLines, oModel )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc}

@description  ModelDef

@author	Anderson F. Gomes
@since	28/03/2024
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel    := Nil
	Local oStruTCW	:= FWFormStruct( 1, 'TCW' , {|cCpo| !(AllTrim( cCpo ) $ "TCW_FILIAL|TCW_DSCCCT|TCW_NCKCUS|TCW_CUSTO|TCW_NICKLI|TCW_FORLIQ|TCW_NICKBR|TCW_FORBRT|TCW_FILIAL") }, .F./* lViewUsado */, .T. /* lVirtual */)
	Local oStruTDZ	:= FWFormStruct( 1, 'TDZ' , {|cCpo| !(AllTrim( cCpo ) $ "TDZ_FILIAL|TDZ_ITEM|TDZ_TABELA|TDZ_DSCBEN") }, .F./* lViewUsado */, .T. /* lVirtual */)
	Local bCmtModel := { |oModel| at740MCmmt( oModel ) }
	Local bPreLinTDZ:= { |oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| preLinTDZ( oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue ) }

	aFieldsTDZ := oStruTDZ:GetFields()

	oStruTCW:SetProperty("TCW_DESCRI", MODEL_FIELD_WHEN, {|| .F.})
	oStruTCW:SetProperty("TCW_CODCCT", MODEL_FIELD_WHEN, {|| .F.})
	
	oStruTDZ:SetProperty("*",MODEL_FIELD_WHEN,{||.F.})
	oStruTDZ:SetProperty("TDZ_VLRDIF",MODEL_FIELD_WHEN,{||.T.})
	oStruTDZ:SetProperty("TDZ_CODSLY", MVC_VIEW_ORDEM, "01")
	oStruTDZ:SetProperty("TDZ_DESCRI", MVC_VIEW_ORDEM, "02")
	oStruTDZ:SetProperty("TDZ_OBRGT", MVC_VIEW_ORDEM, "03")
	oStruTDZ:SetProperty("TDZ_VALOR", MVC_VIEW_ORDEM, "04")
	oStruTDZ:SetProperty("TDZ_VLRDIF", MVC_VIEW_ORDEM, "05")

	oModel := MPFormModel():New( "TECA740M", /*<bPre>*/, /*bPosModel*/, bCmtModel, /*<bCancel>*/ )
	oModel:SetDescription(STR0001) //"Ajuste de Verbas Adicionais - Benefícios"

	oModel:AddFields( "TCWMASTER", /*cOwner*/, oStruTCW, /*<bPre>*/, /*<bPost>*/, /*bLoadField*/ )
	oModel:GetModel( "TCWMASTER"):SetDescription( STR0001 ) //"Ajuste de Verbas Adicionais - Benefícios"
	oModel:SetPrimaryKey( { "TCW_FILIAL", "TCW_CODIGO" } )

	oModel:AddGrid( "TDZDETAIL", "TCWMASTER", oStruTDZ, bPreLinTDZ, /*<bLinePost>*/, /*<bPre>*/, /*<bLinePost>*/, /*bLoadGrid*/)
	oModel:GetModel( "TDZDETAIL" ):SetDescription (STR0005 ) //"Benefícios"

	If (TDZ->(ColumnPos('TDZ_REVISA')) > 0)
		oModel:SetRelation("TDZDETAIL", {{"TDZ_FILIAL","xFilial('TDZ')"}, {"TDZ_CODTCW","TCW_CODIGO"}, {"TDZ_REVISA","TCW_REVISA"}}, TDZ->(IndexKey(1)))
	Else
		oModel:SetRelation("TDZDETAIL", {{"TDZ_FILIAL","xFilial('TDZ')"}, {"TDZ_CODTCW","TCW_CODIGO"}}, TDZ->(IndexKey(1)))
	EndIf

	oModel:GetModel( "TDZDETAIL" ):SetOnlyQuery( .T. )
	oModel:GetModel( "TDZDETAIL" ):SetOptional( .T. )

	oModel:SetActivate( { |oModel| InitDados( oModel ) } )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc}

@description  ViewDef

@author	Anderson F. Gomes
@since	28/03/2024
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel 	:= ModelDef()
	Local oStruTCW	:= FWFormStruct( 2, 'TCW' , {|cCpo| !(AllTrim( cCpo ) $ "TCW_FILIAL|TCW_DSCCCT|TCW_NCKCUS|TCW_CUSTO|TCW_NICKLI|TCW_FORLIQ|TCW_NICKBR|TCW_FORBRT|TCW_FILIAL") }, .F./* lViewUsado */, .T. /* lVirtual */)
	Local oStruTDZ	:= FWFormStruct( 2, 'TDZ' , {|cCpo| !(AllTrim( cCpo ) $ "TDZ_FILIAL|TDZ_ITEM|TDZ_TABELA|TDZ_DSCBEN") }, .F./* lViewUsado */, .T. /* lVirtual */)
	Local oView     := Nil

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( "VIEW_CAB", oStruTCW, "TCWMASTER" )
	oView:AddGrid( "VIEW_GRID", oStruTDZ, "TDZDETAIL" )

	oView:CreateHorizontalBox( "CONFIG_TCW", 15 )
	oView:CreateHorizontalBox( "CONFIG_TDZ", 85 )

	oView:SetOwnerView( "VIEW_CAB", "CONFIG_TCW" )
	oView:SetOwnerView( "VIEW_GRID", "CONFIG_TDZ" )

	oView:SetDescription( STR0005 ) //"Verbas"

	oStruTDZ:RemoveField( "TDZ_CODIGO" )
	oStruTDZ:RemoveField( "TDZ_NICK" )
	oStruTDZ:RemoveField( "TDZ_NICKVL" )
	oStruTDZ:RemoveField( "TDZ_FORMUL" )
	oStruTDZ:RemoveField( "TDZ_TIPBEN" )
	oStruTDZ:RemoveField( "TDZ_CODSLY" )
	oStruTDZ:RemoveField( "TDZ_CODTCW" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	Anderson F. Gomes
		V2 - Serviços
@since	28/03/2024
/*/
//-------------------------------------------------------------------
Static Function InitDados( oModel )
	Local cFilTCW	:= xFilial( "TCW" )
	Local cQuery	:= ""
	Local cAliasTDZ := GetNextALias()
	Local nLinha	:= 1
	Local nX		:= 0
	Local oQuery	:= Nil
	Local oMdlTCW 	:= oModel:GetModel( "TCWMASTER" )
	Local oMdlTDZ 	:= oModel:GetModel( "TDZDETAIL" )
	Local nValPlan	:= 0
	Local cField 	:= ""
	Local cType		:= ""

	oPlanXml := FWUIWorkSheet():New( , .F., , 11, "PLAN_LOAD" )
	oPlanXml:LoadXmlModel( cXMLPla )

	//Preenchimento Field (Cabeçalho)
	oMdlTCW:LoadValue( "TCW_CODIGO", AllTrim( Posicione( "TCW", 1, cFilTCW + cConfCal, "TCW_CODIGO" ) ) )
	oMdlTCW:LoadValue( "TCW_DESCRI", AllTrim( Posicione( "TCW", 1, cFilTCW + cConfCal, "TCW_DESCRI" ) ) )
	oMdlTCW:LoadValue( "TCW_CODCCT", AllTrim( Posicione( "TCW", 1, cFilTCW + cConfCal, "TCW_CODCCT" ) ) )

	oMdlTDZ:SetNoInsertLine(.F.)
    oMdlTDZ:SetNoDeleteLine(.F.)

	cQuery	:= " SELECT * "
	cQuery	+= " FROM ? TDZ "
	cQuery	+= " WHERE TDZ.TDZ_FILIAL = ? AND "
	cQuery	+= " TDZ.TDZ_CODTCW = ? AND "
	cQuery	+= " TDZ.D_E_L_E_T_ = ' ' "

	//Prepara a query:
	oQuery := FwPreparedStatement():New(cQuery)

	oQuery:SetNumeric( 1, RetSQLName("TDZ") ) //Filial
	oQuery:SetString( 2, xFilial('TDZ') ) //Filial
	oQuery:SetString( 3, cConfCal ) //Contrato

	cQuery := oQuery:GetFixQuery()
	MPSysOpenQuery(cQuery, cAliasTDZ)

	(cAliasTDZ)->( DbGoTop() )
	While (cAliasTDZ)->(!Eof())
		TDZ->(DbGoTo((cAliasTDZ)->R_E_C_N_O_))
		If (AllTrim((cAliasTDZ)->TDZ_NICK) != "TOTAL_BENEFICIOS")
			If nLinha > 1
				nLinha := oMdlTDZ:AddLine()
			EndIf
			oMdlTDZ:GoLine( nLinha )
			For nX := 1 To Len(aFieldsTDZ)
				cField := aFieldsTDZ[nX][MODEL_FIELD_IDFIELD]
				cType := AllTrim(aFieldsTDZ[nX][MODEL_FIELD_TIPO])
				//Carga dos campos
				If AllTrim(cField) == "TDZ_VLRDIF"
					If oPlanXml:CellExists( AllTrim( (cAliasTDZ)->TDZ_NICKVL ) )
						nValPlan := oPlanXml:GetCellValue( AllTrim( (cAliasTDZ)->TDZ_NICKVL ) )
						If ValType( nValPlan ) != "N" //Tratamento para typemismatch:
							nValPlan := Val( nValPlan )
						EndIf
						oMdlTDZ:LoadValue( "TDZ_VLRDIF", nValPlan )
						AADD(aTDZCarga, {(cAliasTDZ)->TDZ_CODIGO, nValPlan})
					Else
						//Obrigatório = Não -> Carrega o valor TDZ_VALOR zerado
						If (cAliasTDZ)->TDZ_OBRGT != "1"
							oMdlTDZ:LoadValue( "TDZ_VLRDIF", 0 )
							AADD(aTDZCarga, {(cAliasTDZ)->TDZ_CODIGO, 0})
						Else
							oMdlTDZ:LoadValue( "TDZ_VLRDIF", (cAliasTDZ)->TDZ_VLRDIF )
							AADD(aTDZCarga, {(cAliasTDZ)->TDZ_CODIGO, (cAliasTDZ)->TDZ_VLRDIF})
						EndIf
					EndIf
				ElseIf AllTrim(cField) == "TDZ_DESCRI"
					oMdlTDZ:LoadValue( "TDZ_DESCRI", At996aDsc((cAliasTDZ)->TDZ_CODSLY,(cAliasTDZ)->TDZ_TIPBEN, .T. ))
				ElseIf cType == "M"
					oMdlTDZ:LoadValue( cField, TDZ->&(cField) )
				ElseIf cType == "D"
					oMdlTDZ:LoadValue( cField, STOD((cAliasTDZ)->&(cField)))
				Else
					If !(AllTrim( cField ) $ "TDZ_FILIAL|TDZ_ITEM|TDZ_TABELA|TDZ_DSCBEN")
						oMdlTDZ:LoadValue( cField, (cAliasTDZ)->&(cField) )
					EndIf
				EndIf
			Next nX
			nLinha++
		EndIf
		(cAliasTDZ)->(dbSkip())
	EndDo

	//Limpeza:
	(cAliasTDZ)->(dbCloseArea())
	oQuery:Destroy()
	FwFreeObj(oQuery)

	oMdlTDZ:SetNoInsertLine( .T. )
	oMdlTDZ:SetNoDeleteLine( .T. )
	oMdlTDZ:SetNoUpdateLine( .F. )

	If !lAparece
		oMdlTDZ:SetNoUpdateLine(.T.)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} preLinTDZ
@description Pré validação da linha Grid TDZ

@Param: oGridModel - Modelo do GRID
		nLine - Número da linha atual
		cAction - Ação ("UNDELETE"/"DELETE"/"SETVALUE"/"CANSETVALUE")
		cIDField - ID do campo que está tentando ser atualizado
		xValue - Valor que está sendo atribuido
		xCurrentValue - Valor que está atualmente no campo

@author	Anderson F. Gomes
@since	28/03/2024
/*/
//-------------------------------------------------------------------
Static Function preLinTDZ(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet := .T.
	Local nValor := 0

	If cAction == "SETVALUE"
		If cIDField == "TDZ_VLRDIF"
			nValor := oGridModel:GetValue("TDZ_VALOR")
			If xValue <> 0 .AND. xValue < nValor
				lRet := .F.
				Help( Nil, Nil, "preLinTDZ", Nil, STR0009, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0010 + cValtoChar(nValor) + "." } )//"O Valor do campo não pode ser menor do que o estabelecido na CCT."#"O valor deve ser igual ou maior que X."
			EndIf
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740MCmmt
	Realizar a gravação dos dados na planilha - XML Planilha nova no posto (TFF)
@sample 	at740MCmmt()
@since		28/03/2024
@return 	oModel, Object, instância do modelo de dados MpFormModel
@author 	Anderson F. Gomes
/*/
//------------------------------------------------------------------------------
Static Function at740MCmmt( oModel )
	Local lRet		:= .T.
	Local lObrigat  := .T.
	Local nLine 	:= 3
	Local nX		:= 0
	Local cFormula	:= "=0"
	Local cNickForm := ""
	Local cNickPorc := ""
	Local cDesc     := ""
	Local oMdlTDZ 	:= oModel:GetModel( "TDZDETAIL" )

	For nX := 1 To oMdlTDZ:Length()
		oMdlTDZ:GoLine( nX )

		nValue := oMdlTDZ:GetValue("TDZ_VLRDIF")
		nPos := aScan(aTDZCarga, {|x| AllTrim(x[1]) == oMdlTDZ:GetValue("TDZ_CODIGO")  })
		If nPos > 0 
			If nValue != aTDZCarga[nPos][2]
				cNickForm := AllTrim( oMdlTDZ:GetValue( "TDZ_NICK" ) )
				cFormula := AllTrim( oMdlTDZ:GetValue( "TDZ_FORMUL" ) )
				cNickPorc := AllTrim( oMdlTDZ:GetValue( "TDZ_NICKVL" ) )
				lObrigat := ( AllTrim( oMdlTDZ:GetValue( "TDZ_OBRGT" ) ) <> "2" )
				cDesc  := AllTrim( oMdlTDZ:GetValue( "TDZ_DESCRI" ) )

				If ( !Empty( cDesc ) .And. !Empty( cNickForm ) .And. !Empty( cNickPorc ) )
					If lObrigat .And. oPlanXml:CellExists( cNickPorc )
						oPlanXml:SetCellValue( cNickPorc, nValue )
					Else
						nLine 	:= 3
						While ValType( oPlanXml:GetCell( "I" + CValToChar( nLine ) ) ) == "O" .And. AllTrim( oPlanXml:GetCellValue( "I" + CValToChar( nLine ) ) ) <> AllTrim( cDesc )
							nLine++
						End

						If !Empty( cFormula )
							cFormula := "=" + cFormula
						EndIf

						oPlanXml:SetCellValue( "I" + CValToChar( nLine ), cDesc, NIL, .T. )

						oPlanXml:SetNickName( "J" + CValToChar( nLine ), cNickPorc )
						oPlanXml:SetCellValue( "J" + CValToChar( nLine ), nValue, NIL, .T. )

						oPlanXml:SetNickName( "K" + CValToChar( nLine ), cNickForm )
						oPlanXml:SetCellValue( "K" + CValToChar( nLine ), cFormula, NIL, .T. )
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX

	cXMLPla := oPlanXml:GetXmlModel(,,,,.F.,.T.,.F.)

	If ExistBlock("at740MXml")
		ExecBlock("at740MXml",.F.,.F.,{oMdlTDZ,cXMLPla})
	EndIf

	oModel:DeActivate()

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740MLimp
	Limpa variáveis estáticas
@sample 	at740MLimp()
@since		28/03/2024
@author 	Anderson F. Gomes
/*/
//------------------------------------------------------------------------------
Static Function at740MLimp()
	aTDZCarga := {}
	aFieldsTDZ := {}
	cXMLPla	  := ""
	cConfCal  := ""
	cCodTFF	  := ""
	oPlanXml  := Nil
	oMdl740	  := Nil
	lAparece  := .T.
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} at740MUpdt
	Realiza a atualização dos totais e xml da planilha (POSTO TFF - RH)
@sample 	at740MUpdt()
@since		28/03/2024
@author 	Anderson F. Gomes
/*/
//------------------------------------------------------------------------------
Static Function at740MUpdt( oModel )
	Local nTotRh	:= 0
	Local nTotPlan	:= 0
	Local oMdlRh  	:= oModel:GetModel( "TFF_RH" )

	oPlanXml:LoadXMLModel( cXMLPla )

	If oPlanXml:CellExists( "TOTAL_CUSTO" )
		nTotRh := oPlanXml:GetCellValue( "TOTAL_CUSTO" )
	Endif
	If oPlanXml:CellExists( "TOTAL_BRUTO" )
		nTotPlan := oPlanXml:GetCellValue( "TOTAL_BRUTO" )
	Endif

	//Pega planilha atualizada
	oPlanXml:Refresh(.T.)
	cXMLPla := oPlanXml:GetXmlModel(,,,,.F.,.T.,.F.)

	oMdlRh:SetValue( "TFF_CALCMD", cXMLPla )
	oMdlRh:SetValue( "TFF_PRCVEN", Round( nTotRh, TamSX3( "TFF_PRCVEN" )[2] ) )
	oMdlRh:SetValue( "TFF_TOTPLA", Round( nTotPlan, TamSX3( "TXS_TOTPLA" )[2] ) )

	If ExistBlock("at740MUpd")
		ExecBlock("at740MUpd",.F.,.F.,{oMdlRh,oPlanXml})
	EndIf

Return
