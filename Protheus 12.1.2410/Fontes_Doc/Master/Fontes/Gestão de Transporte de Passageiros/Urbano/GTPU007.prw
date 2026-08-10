#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPU007.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU007
	Frotas - Urbano

	@author Silas Gomes
	@since 24/02/2024
	@version 1.0
/*/
//-------------------------------------------------------------------
Function GTPU007()

	Local oBrowse := FWMBrowse():New()
	Local aBrowse := {}

	aAdd(aBrowse, {STR0010							, "T9_CODBEM" })	//"Cód. Veículo"
	aAdd(aBrowse, {AllTrim(FWX3Titulo("T9_PLACA"))	, "T9_PLACA"  })
	aAdd(aBrowse, {AllTrim(FWX3Titulo("T9_ANOMOD"))	, "T9_ANOMOD" })
	aAdd(aBrowse, {AllTrim(FWX3Titulo("T9_ANOFAB"))	, "T9_ANOFAB" })
	aAdd(aBrowse, {AllTrim(FWX3Titulo("T9_CHASSI"))	, "T9_CHASSI" })
	aAdd(aBrowse, {AllTrim(FWX3Titulo("T9_RENAVAM")), "T9_RENAVAM"})

	oBrowse:SetDescription(STR0001) //"Cadastro Frotas - Urbano"
	oBrowse:SetAlias("ST9")
	oBrowse:SetFields(aBrowse)
	oBrowse:SetOnlyFields( { 'T9_FILIAL', 'T9_CODBEM','T9_PLACA','T9_ANOFAB','T9_ANOMOD','T9_CHASSI','T9_RENAVAM' } )
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

    @return aRotina - Estrutura
    [n,1] Nome a aparecer no cabecalho
    [n,2] Nome da Rotina associada
    [n,3] Reservado
    [n,4] Tipo de Transação a ser efetuada:
    1 - Pesquisa e Posiciona em um Banco de Dados
    2 - Simplesmente Mostra os Campos
    3 - Inclui registros no Bancos de Dados
    4 - Altera o registro corrente
    5 - Remove o registro corrente do Banco de Dados
    6 - Alteração sem inclusão de registros
    7 - Cópia
    8 - Imprimir
    [n,5] Nivel de acesso
    [n,6] Habilita Menu Funcional

    @author Silas Gomes
    @since 24/02/2024
    @version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.GTPU007", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.GTPU007", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.GTPU007", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.GTPU007", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.GTPU007", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

    Função responsavel pela definição do modelo
    @author Silas Gomes
    @since 08/02/2024
    @return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := Nil
	Local cCampos    := 'T9_FILIAL|T9_CODBEM|T9_PLACA|T9_ANOFAB|T9_ANOMOD|T9_CHASSI|T9_RENAVAM|T9_SITMAN|T9_SITBEM|T9_CATBEM|T9_NOME|T9_CALENDA|'
	Local oStructST9 := FWFormStruct( 1, "ST9", { |x| AllTrim( x ) + "|" $ cCampos } )
	Local oStructH70 := FWFormStruct( 1, "H70" )
	Local oCommit	:= GU07COMMIT():New()

	oModel  := MPFormModel():New( "GTPU007", /*Pré-Validacao*/, {|oModel| ValidModel( oModel ) }/*Pos-Validacao*/,/*Commit*/)
	oModel:InstallEvent("GU07COMMIT", /*cOwner*/, oCommit)
	oModel:SetDescription( "Frotas" ) //"Dados de frotas"

	//TABELA ST9
	oStructST9:SetProperty("T9_CODBEM",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("ST9","T9_CODBEM")'))
	oStructST9:SetProperty( "T9_PLACA",   MODEL_FIELD_OBRIGAT, .T. )
	oStructST9:SetProperty( "T9_ANOFAB",  MODEL_FIELD_OBRIGAT, .T. )
	oStructST9:SetProperty( "T9_ANOMOD",  MODEL_FIELD_OBRIGAT, .T. )
	oStructST9:SetProperty( "T9_CHASSI",  MODEL_FIELD_OBRIGAT, .T. )
	oStructST9:SetProperty( "T9_RENAVAM", MODEL_FIELD_OBRIGAT, .T. )

	//TABELA G6V
	/*oStrG6V := FWFormStruct( 1, "G6V" )

	oStrG6V:SetProperty( 'G6V_RECURS', MODEL_FIELD_NOUPD, .T. )
	oStrG6V:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. )
	oStrG6V:SetProperty( "*", MODEL_FIELD_VALID, {|| .T. } )
	oStrG6V:SetProperty( "*", MODEL_FIELD_WHEN, {|| .T. } )

	//TABELA G6W
	oStrG6W := FWFormStruct( 1, "G6W" )
	oStrG6W:AddField('','',"ANEXO" ,"BT", 15,0,,,,.F.,{|| SetIniFld()}, .F., .F., .T.)*/

	/*oStrG6W:SetProperty( '*', MODEL_FIELD_NOUPD, .F. )
	oStrG6W:SetProperty( '*', MODEL_FIELD_WHEN, {|| .T.} )
	oStrG6W:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F. )
	oStrG6W:SetProperty( 'G6W_CODG6U', MODEL_FIELD_OBRIGAT, .T. )
	oStrG6W:SetProperty( 'G6W_TPTOLE', MODEL_FIELD_OBRIGAT, .T. )
	oStrG6W:SetProperty( 'G6W_TEMPTO', MODEL_FIELD_OBRIGAT, .T. )
	oStrG6W:SetProperty( 'G6W_TPVIGE', MODEL_FIELD_OBRIGAT, .T. )
	oStrG6W:SetProperty( 'G6W_TEMPVI', MODEL_FIELD_OBRIGAT, .T. )
	oStrG6W:SetProperty( 'G6W_DTINI' , MODEL_FIELD_OBRIGAT, .T. )

	oStrG6W:AddTrigger( "G6W_CODG6U", "G6W_CODG6U", { || .T. }, {|| FieldTrigger(oModel, "G6W_CODG6U")})
	oStrG6W:AddTrigger( "G6W_DTINI" , "G6W_DTINI" , { || .T. }, {|| FieldTrigger(oModel, "G6W_DTINI") })
	oStrG6W:AddTrigger( "G6W_DTFIM" , "G6W_DTFIM" , { || .T. }, {|| FieldTrigger(oModel, "G6W_DTFIM") })*/

	
	oModel:AddFields("ST9MASTER", NIL, oStructST9, /*Pre-Validacao*/, /*Pos-Validacao*/ )   
	oModel:AddGrid( "H70DETAIL", "ST9MASTER" /*cOwner*/, oStructH70, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ ) //Dados complementares
	oModel:GetModel( "H70DETAIL" ):SetMaxLine(1)

	/*oModel:AddGrid( "G6VDETAILS", "ST9MASTER", oStrG6V )
	oModel:GetModel( "G6VDETAILS" ):SetMaxLine(1)
	oModel:GetModel( "G6VDETAILS" ):SetOptional(.T.)

	oModel:AddGrid( "G6WDETAILS", "G6VDETAILS", oStrG6W )
	oModel:GetModel( "G6WDETAILS" ):SetUniqueLine({"G6W_SEQ"})
	oModel:GetModel( "G6WDETAILS" ):SetOptional(.T.)*/

	oModel:SetRelation( 'H70DETAIL', {{ 'H70_FILIAL' , 'xFilial("H70")' }, { 'H70_CODVEI' , 'T9_CODBEM'  }}, H70->(IndexKey(1)))
	//oModel:SetRelation( 'G6VDETAILS', {{ 'G6V_FILIAL' , 'xFilial("G6V")' }, { 'G6V_TRECUR' , "'2'"        } , { 'G6V_RECURS', 'T9_CODBEM' }}, G6V->(IndexKey(2)))
	//oModel:SetRelation( 'G6WDETAILS', {{ 'G6W_FILIAL' , 'xFilial("G6W")' }, { 'G6W_CODIGO' , 'G6V_CODIGO' }}, G6W->(IndexKey(1)))

	oModel:SetPrimaryKey({"T9_CODBEM"})
	oModel:SetOptional( "H70DETAIL" , .F. )
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

    Função responsavel pela definição da view
    @type Static Function
    @author Silas Gomes
    @since 24/02/2024
    @version 1.0
    @return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
	Local cCampos  := 'T9_FILIAL|T9_CODBEM|T9_PLACA|T9_ANOFAB|T9_ANOMOD|T9_CHASSI|T9_RENAVAM|T9_SITMAN|T9_SITBEM|T9_CATBEM|T9_NOME|T9_CALENDA|'
	Local oView    := FWFormView():New()
	Local oModel   := FWLoadModel( "GTPU007" )
	Local oStrST9  := FWFormStruct( 2, "ST9", { |x| AllTrim( x ) + "|" $ cCampos } )
	Local oStrH70  := FWFormStruct( 2, "H70" )
	//Local oStrG6V   as object
	//Local oStrG6W   as object
	//Local bDblClick as block


	//oStrG6V   := FWFormStruct( 2, "G6V" )
	//oStrG6W   := FWFormStruct( 2, "G6W" )

	//bDblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField)}}

	//oStrST9:SetProperty( "T9_CODBEM", MVC_VIEW_TITULO, STR0010 ) // "Cód. Veículo"

	//oStrG6V:SetProperty( "G6V_RECURS", MVC_VIEW_CANCHANGE, .F. )

	//REMOVE OS CAMPOS
	oStrST9:RemoveField("T9_CODBEM")

	/*oStrG6V:RemoveField("G6V_CODIGO")
	oStrG6V:RemoveField("G6V_STATUS")
	oStrG6V:RemoveField("G6V_TRECUR")
	oStrG6V:RemoveField("G6V_DRECUR")

	oStrG6W:AddField("ANEXO", "00", "Anexos", "TESTE 2 DOC", {""}, "GET", "@BMP", Nil, "", .T., Nil, "", Nil, Nil, Nil, .T., Nil, .F.) // "Anexos"
	*/
	oView:SetModel( oModel )

	oView:AddField( "VIEWST9", oStrST9, "ST9MASTER" )

	oView:AddGrid( "VIEWH70", oStrH70, "H70DETAIL" )
	oView:EnableTitleView( "VIEWH70", STR0030 ) //Complemento - Dados Veículo

	/*oView:AddGrid( "VIEWG6V", oStrG6V, "G6VDETAILS" )
	oView:EnableTitleView( "VIEWG6V", STR0031 ) //"Recurso x Documentos"

	oView:AddGrid( "VIEWG6W", oStrG6W, "G6WDETAILS" )
	oView:EnableTitleView( "VIEWG6W", STR0032 ) //"Detalhes - Recurso x Documentos"
	oView:AddIncrementField("VIEWG6W", "G6W_SEQ")
	*/
	// CRIAÇÃO DE MVC - TELA
	oView:CreateHorizontalBox( 'PAINEL_SUPERIOR', 100 )
	oView:CreateFolder( 'FOLDER_SUPERIOR', 'PAINEL_SUPERIOR' )

	oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA01', STR0013 ) //'Dados Gerais'
	//oView:AddSheet( 'FOLDER_SUPERIOR', 'ABA02', STR0011 ) //'Documentos'

	oView:CreateHorizontalBox( 'FIELDS_ST9', 050,,, 'FOLDER_SUPERIOR', 'ABA01')
	oView:CreateHorizontalBox( 'FIELDS_H70', 050,,, 'FOLDER_SUPERIOR', 'ABA01')

	//oView:CreateHorizontalBox( 'FIELDS_G6V', 020,,, 'FOLDER_SUPERIOR', 'ABA02')
	//oView:CreateHorizontalBox( 'FIELDS_G6W', 080,,, 'FOLDER_SUPERIOR', 'ABA02')

	oView:SetOwnerView( 'VIEWST9', 'FIELDS_ST9' )
	oView:SetOwnerView( 'VIEWH70', 'FIELDS_H70' )
	//oView:SetOwnerView( 'VIEWG6V', 'FIELDS_G6V' )
	//oView:SetOwnerView( 'VIEWG6W', 'FIELDS_G6W' )
	//oView:SetViewProperty("VIEWG6W", "GRIDDOUBLECLICK", bDblClick)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDblClick
	Função Responsavel por receber o duplo clique na Grid VIEWG6W
	@author Mick William da Silva
	@since 22/02/2024
	@version 1.0
	@param oGrid, Objeto, View com os dados da grid
	@param  cField		, Caracter, Campo a ser tratado
	@param  nLineGrid	, Numérico, Numero da Linha da grid.
	@param  nLineModel	, Numérico, Numero da linha do model.
	@return .T.
/*/
//-------------------------------------------------------------------
Static Function SetDblClick( oGrid as object, cField as character)

	Local oView as object
	oView := FwViewActive()

	If cField == 'ANEXO'
		AttachDocs(oView)
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SetIniFld
	Função Responsavel por verificar se o anexo existe na tabela AC9
	@author Mick William da Silva
	@since 22/02/2024
	@version 1.0
	@return cValor	, Caracter, Campo a ser tratado
/*/
//-------------------------------------------------------------------
Static Function SetIniFld()

	Local cValor as character
	cValor := ''

	AC9->(dbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_

	If AC9->( dbSeek( xFilial('AC9') + 'G6W' + xFilial('G6W') + xFilial('G6W') + G6W->G6W_CODIGO + G6W->G6W_SEQ ) )
		cValor := "F5_VERD"
	Else
		cValor := 'F5_VERM'
	Endif

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} AttachDocs
	Função Responsavel para retornar o array contendo os valores do ComboBox
	@author Mick William da Silva
	@since 22/02/2024
	@version 1.0
	@param oView, Objeto, View com os dados da grid
	@return Nil
/*/
//-------------------------------------------------------------------
Static Function AttachDocs( oView as object )

	Local nRecno as character
	nRecno := oView:GetModel( 'G6WDETAILS' ):GetDataId()

	MsDocument( 'G6W', G6W->(nRecno), 3 )
	oView:GetModel('G6WDETAILS'):LoadValue( "ANEXO", SetIniFld() )
	oView:Refresh()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
	Função responsavel pelo gatilho dos campos
	@type function
	@author Silas Gomes
	@since 26/02/2024
	@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger( oModel as object, cField as character)

	Local uValor
	Local dDataIni   as character
	Local dDataFim   as character
	Local dDataMax   as character
	Local cTpVigem   as character
	Local cTpTole    as character
	Local nTempoVig  as numeric
	Local nTempoTole as numeric

	uValor     := ''
	dDataIni   := ''
	dDataFim   := ''
	dDataMax   := ''
	cTpVigem   := ''
	cTpTole    := ''
	nTempoVig  := 0
	nTempoTole := 0

	Do Case

	Case cField == 'G6W_CODG6U'
		uValor := oModel:GetModel("G6WDETAILS"):GetValue("G6W_CODG6U")

		G6U->(DbSetOrder(1))
		If G6U->(DbSeek(xFilial('G6U') + uValor))
			oModel:GetModel( "G6WDETAILS" ):SetValue( 'G6W_TPVIGE', G6U->G6U_TPVIGE )
			oModel:GetModel( "G6WDETAILS" ):SetValue( 'G6W_TEMPVI', G6U->G6U_TEMPVI )
			oModel:GetModel( "G6WDETAILS" ):SetValue( 'G6W_TPTOLE', G6U->G6U_TPTOLE )
			oModel:GetModel( "G6WDETAILS" ):SetValue( 'G6W_TEMPTO', G6U->G6U_TEMPTO )
			oModel:GetModel( "G6WDETAILS" ):SetValue( 'G6W_DTINI',  StoD(''))
		EndIf

	Case cField == 'G6W_DTINI'

		uValor := oModel:GetModel("G6WDETAILS"):GetValue("G6W_DTINI")
		dDataIni := uValor
		cTpVigem := oModel:GetModel("G6WDETAILS"):GetValue("G6W_TPVIGE")
		nTempoVig := oModel:GetModel("G6WDETAILS"):GetValue("G6W_TEMPVI")

		If cTpVigem == '1' //Dia
			dDataFim := DaySum( dDataIni, nTempoVig )
		ElseIf cTpVigem == '2' //Mes
			dDataFim := MonthSum( dDataIni, nTempoVig )
		ElseIf cTpVigem == '3' //Ano
			dDataFim := YearSum( dDataIni, nTempoVig )
		EndIf

		oModel:GetModel( "G6WDETAILS" ):SetValue( 'G6W_DTFIM', dDataFim )

	Case cField == 'G6W_DTFIM'

		uValor := oModel:GetModel("G6WDETAILS"):GetValue("G6W_DTFIM")
		dDataFim := uValor
		cTpTole := oModel:GetModel("G6WDETAILS"):GetValue("G6W_TPTOLE")
		nTempoTole := oModel:GetModel("G6WDETAILS"):GetValue("G6W_TEMPTO")

		If cTpTole == '1' //Dia
			dDataMax := DaySum( dDataFim, nTempoTole )
		ElseIf cTpTole == '2' //Mes
			dDataMax := MonthSum( dDataFim, nTempoTole )
		ElseIf cTpTole == '3' //Ano
			dDataMax := YearSum( dDataFim, nTempoTole )
		EndIf

		oModel:GetModel( "G6WDETAILS" ):SetValue( 'G6W_DTMAX', dDataMax )

		If uValor >= dDataBase
			oModel:GetModel( "G6WDETAILS" ):SetValue( 'G6W_STATUS', '1', .T. )
		Else
			oModel:GetModel( "G6WDETAILS" ):SetValue( 'G6W_STATUS', '3', .T. )
		EndIf

	EndCase

Return uValor

//-------------------------------------------------------------------
/*/{Protheus.doc}ValidModel
Funcao de validação do Model
@author Silas Gomes
@since 08/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )

	Local oModelST9  as object
	Local oModelH70  as object
	Local oQuery     as object
	Local nOperation as numeric
	Local lRet       as logical
	Local cAliasTmp  as character
	Local cQuery     as character
	Local cMsg		 as character

	Default oModel := Nil

	oModelST9      := oModel:GetModel( 'ST9MASTER' )
	oModelH70      := oModel:GetModel( 'H70DETAIL' )
	oQuery         := Nil
	nOperation     := oModel:GetOperation()
	lRet           := .T.
	cAliasTmp      := ""
	cQuery         := ""
	cMsg		   := ""
	
	If nOperation != MODEL_OPERATION_DELETE

		cQuery := " SELECT ST9.T9_FILIAL FILIAL, "
		cQuery +=        " ST9.T9_CODBEM CODIGO, "
		cQuery +=        " ST9.T9_PLACA PLACA, "
		cQuery +=        " ST9.T9_CHASSI CHASSI, "
		cQuery +=        " ST9.T9_RENAVAM RENAVAM, "
		cQuery +=        " H70.H70_PRFVEI PREFIXO, "
		cQuery +=        " H70.H70_STATUS STATUS, "
		cQuery +=        " H70.H70_ROLVEI ROLETA, "
		cQuery +=        " H70.H70_VALVEI VALIDADOR "
		cQuery += " FROM ? ST9 "
		cQuery += " INNER JOIN ? H70 "
		cQuery +=         " ON H70.H70_FILIAL = ? "
		cQuery +=            " AND H70.H70_CODVEI = ST9.T9_CODBEM "
		cQuery +=            " AND H70.D_E_L_E_T_ = '' "
		cQuery += " WHERE ST9.T9_FILIAL = ? "
		cQuery +=       " AND ST9.T9_CODBEM <> ? "
		cQuery +=       " AND H70.H70_STATUS = ? "
		cQuery +=       " AND ( ST9.T9_PLACA = ? "
		cQuery +=             " OR ST9.T9_CHASSI = ? "
		cQuery +=             " OR ST9.T9_RENAVAM = ? "
		cQuery +=             " OR H70.H70_PRFVEI = ? "

		If Empty(oModelH70:GetValue('H70_VALVEI'))
			cQuery +=             " OR H70.H70_ROLVEI = ? )"
		Else
			cQuery +=             " OR H70.H70_ROLVEI = ? "
			cQuery +=             " OR H70.H70_VALVEI = ? )"
		EndIf

		cQuery +=       " AND ST9.D_E_L_E_T_ = '' "
		
		cQuery := ChangeQuery(cQuery)
		oQuery := FWPreparedStatement():New(cQuery)
		oQuery:SetUnsafe(1, RetSqlName("ST9"))
		oQuery:SetUnsafe(2, RetSqlName("H70"))
		oQuery:SetString(3, xFilial("H70"))
		oQuery:SetString(4, xFilial("ST9"))
		oQuery:SetString(5, AllTrim(oModelST9:GetValue('T9_CODBEM')))
		oQuery:SetString(6, AllTrim(oModelH70:GetValue('H70_STATUS')))
		oQuery:SetString(7, AllTrim(oModelST9:GetValue('T9_PLACA')))
		oQuery:SetString(8, AllTrim(oModelST9:GetValue('T9_CHASSI')))
		oQuery:SetString(9, AllTrim(oModelST9:GetValue('T9_RENAVAM')))
		oQuery:SetString(10, AllTrim(oModelH70:GetValue('H70_PRFVEI')))
		oQuery:SetString(11, AllTrim(oModelH70:GetValue('H70_ROLVEI')))

		If !Empty(oModelH70:GetValue('H70_VALVEI'))
			oQuery:SetString(12, AllTrim(oModelH70:GetValue('H70_VALVEI')))
		EndIf

		cQuery := oQuery:GetFixQuery()
		cAliasTmp := MPSysOpenQuery( cQuery )

		If !(cAliasTmp)->( EOF() )

			Do Case
				Case ( AllTrim((cAliasTmp)->PREFIXO) == AllTrim(oModelH70:GetValue('H70_PRFVEI')) )
					cMsg := STR0040 + AllTrim(oModelH70:GetValue('H70_PRFVEI')) 			//"Já existe um veículo cadastrado com o Prefixo: "
				Case ( AllTrim((cAliasTmp)->ROLETA) == AllTrim(oModelH70:GetValue('H70_ROLVEI')) )
					cMsg := STR0041 														//"Já existe um veículo cadastrado com essa roleta "
				Case ( AllTrim((cAliasTmp)->RENAVAM) == AllTrim(oModelST9:GetValue('T9_RENAVAM')) )
					cMsg := STR0038 + AllTrim(oModelST9:GetValue('T9_RENAVAM')) + STR0039 	//"O Renavam " ####### " informado já pertence a outro veículo"
			EndCase

			If !Empty(oModelH70:GetValue('H70_VALVEI'))
				If AllTrim((cAliasTmp)->VALIDADOR) == AllTrim(oModelH70:GetValue('H70_VALVEI'))
					cMsg := STR0042 														//"Já existe um veículo cadastrado com esse validador "
				EndIf
			EndIf

			lRet := .F.
			oModel:SetErrorMessage( ,,,,, cMsg, STR0034,, )// cMsg - "Revise os dados do veículo preenchidos."

		EndIf	

	EndIf

Return( lRet )
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GU07COMMIT
@description Classe interna implementando o FWModelEvent, para execução de função durante o commit.
@author Breno Gomes
@since 30/01/2025
@version 1.0
/*/
//--------------------------------------------------------------------------------------------------------------------
Class GU07COMMIT FROM FWModelEvent
	Method New()
	Method BeforeTTS() //quando ocorrer as ações do commit antes  da transação.
End Class

//---------------------------------------------------------
Method New() Class GU07COMMIT
Return

//---------------------------------------------------------
Method BeforeTTS(oModel) Class GU07COMMIT
Local nOperation     := oModel:GetOperation()
Local oModelST9      := oModel:GetModel( 'ST9MASTER' )
Local oModelH70      := oModel:GetModel( 'H70DETAIL' )
	
	If nOperation != MODEL_OPERATION_DELETE
		If nOperation == MODEL_OPERATION_INSERT
			oModelST9:LoadValue('T9_CATBEM', '4')
		EndIf
		If oModelH70:GetValue('H70_STATUS') == '1'
			oModelST9:LoadValue('T9_SITMAN', 'A')
			oModelST9:LoadValue('T9_SITBEM', 'A')

		ElseIf oModelH70:GetValue('H70_STATUS') == '2'
			oModelST9:LoadValue('T9_SITMAN', 'I')
			oModelST9:LoadValue('T9_SITBEM', 'I')

		EndIf
	EndIf

Return

