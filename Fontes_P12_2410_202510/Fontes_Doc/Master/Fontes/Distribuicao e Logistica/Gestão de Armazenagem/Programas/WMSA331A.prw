#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA331A.CH"

#DEFINE CABECALHO "DB_DOC/DB_CLIFOR/DB_LOJA/DB_CARGA/SDBSERVIC/SDBDESSER/SDBTAREFA/SDBDESTAR"
#DEFINE GRID "DB_ATIVID/DB_DESATI/DB_RECHUM/SDBNOMFUN/DB_DATA/DB_HRINI/DB_DATAFIM/DB_HRFIM"

Static cStatProb  := SuperGetMV('MV_RFSTPRO', .F., '2')
Static cStatManu  := SuperGetMV('MV_RFSTMAN', .F., 'M') //-- DB_STATUS indicando Atividade Manual
Static dDataVazia := CTOD("  /  /    ")

//Esta função é só para o TDS reconhecer o fonte e poder gerar patch
Function WMSA331ADUMMY()
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe Machado de Oliveira
@since 11/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruSDB  := FWFormStruct( 1, 'SDB')
Local oStruGrid := FWFormStruct( 1, 'SDB')
Local oModel    := MPFormModel():New('WMSA331A',,{|oModel| PosVal(oModel) },{|oModel| GravaDados(oModel)} )
Local cStatInte := SuperGetMV('MV_RFSTINT', .F., '3') //-- DB_STATUS indicando Atividade Interrompida
Local cStatAExe := SuperGetMV('MV_RFSTAEX', .F., '4') //-- DB_STATUS indicando Atividade A Executar
Local aColsSX3  := {}

Private cIdMovtoAt := "" //Variável private utilizada na consulta de saldo da validação de finalização da movimentação

DbSelectArea('SDB')

buscarSX3('DB_SERVIC',,@aColsSX3)
oStruSDB:AddField( aColsSX3[1],;												// [01] C Titulo do campo
					aColsSX3[1],;												// [02] C ToolTip do campo
					'SDBSERVIC',;												// [03] C identificador (ID) do Field
					'C',;														// [04] C Tipo do campo
					aColsSX3[3],;												// [05] N Tamanho do campo
					aColsSX3[4],;												// [06] N Decimal do campo
					NIL,;														// [07] B Code-block de validação do campo
					{||.F.},;													// [08] B Code-block de validação When do campo
					NIL,;														// [09] A Lista de valores permitido do campo
					NIL,;														// [10] L Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD, "SDB->DB_SERVIC" ),;	// [11] B Code-block de inicializacao do campo
					NIL,;														// [12] L Indica se trata de um campo chave
					.F.,;														// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )														// [14] L Indica se o campo é virtual

buscarSX3('DB_DESSER',,@aColsSX3)
oStruSDB:AddField( aColsSX3[1],;																// [01] C Titulo do campo
					aColsSX3[1],;																// [02] C ToolTip do campo
					'SDBDESSER',;																// [03] C identificador (ID) do Field
					'C',;																		// [04] C Tipo do campo
					aColsSX3[3],;																// [05] N Tamanho do campo
					aColsSX3[4],;																// [06] N Decimal do campo
					NIL,;																		// [07] B Code-block de validação do campo
					{||.F.},;																	// [08] B Code-block de validação When do campo
					NIL,;																		// [09] A Lista de valores permitido do campo
					NIL,;																		// [10] L Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD, "Tabela('L4',SDB->DB_SERVIC,.F.)" ),;// [11] B Code-block de inicializacao do campo
					NIL,;																		// [12] L Indica se trata de um campo chave
					.F.,;																		// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )																		// [14] L Indica se o campo é virtual

buscarSX3('DB_TAREFA',,@aColsSX3)
oStruSDB:AddField( aColsSX3[1],;												// [01] C Titulo do campo
					aColsSX3[1],;												// [02] C ToolTip do campo
					'SDBTAREFA',;												// [03] C identificador (ID) do Field
					'C',;														// [04] C Tipo do campo
					aColsSX3[3],;												// [05] N Tamanho do campo
					aColsSX3[4],;												// [06] N Decimal do campo
					NIL,;														// [07] B Code-block de validação do campo
					{||.F.},;													// [08] B Code-block de validação When do campo
					NIL,;														// [09] A Lista de valores permitido do campo
					NIL,;														// [10] L Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD, "SDB->DB_TAREFA" ),;	// [11] B Code-block de inicializacao do campo
					NIL,;														// [12] L Indica se trata de um campo chave
					.F.,;														// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )														// [14] L Indica se o campo é virtual

buscarSX3('DB_DESTAR',,@aColsSX3)
oStruSDB:AddField( aColsSX3[1],;																// [01] C Titulo do campo
					aColsSX3[1],;																// [02] C ToolTip do campo
					'SDBDESTAR',;																// [03] C identificador (ID) do Field
					'C',;																		// [04] C Tipo do campo
					aColsSX3[3],;																// [05] N Tamanho do campo
					aColsSX3[4],;																// [06] N Decimal do campo
					NIL,;																		// [07] B Code-block de validação do campo
					{||.F.},;																	// [08] B Code-block de validação When do campo
					NIL,;																		// [09] A Lista de valores permitido do campo
					NIL,;																		// [10] L Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD, "Tabela('L2',SDB->DB_TAREFA,.F.)" ),;// [11] B Code-block de inicializacao do campo
					NIL,;																		// [12] L Indica se trata de um campo chave
					.F.,;																		// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )																		// [14] L Indica se o campo é virtual

buscarSX3('DB_NOMFUN',,@aColsSX3)
oStruGrid:AddField( aColsSX3[1],;																								// [01] C Titulo do campo
					aColsSX3[1],;																								// [02] C ToolTip do campo
					'SDBNOMFUN',;																								// [03] C identificador (ID) do Field
					'C',;																										// [04] C Tipo do campo
					aColsSX3[3],;																								// [05] N Tamanho do campo
					aColsSX3[4],;																								// [06] N Decimal do campo
					NIL,;																										// [07] B Code-block de validação do campo
					NIL,;																										// [08] B Code-block de validação When do campo
					NIL,;																										// [09] A Lista de valores permitido do campo
					NIL,;																										// [10] L Indica se o campo tem preenchimento obrigatório
					FwBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('DCD',1,xFilial('DCD')+SDB->DB_RECHUM,'DCD_NOMFUN')" ),;	// [11] B Code-block de inicializacao do campo
					NIL,;																										// [12] L Indica se trata de um campo chave
					.F.,;																										// [13] L Indica se o campo pode receber valor em uma operação de update.
					.T. )																										// [14] L Indica se o campo é virtual


oStruGrid:SetProperty("DB_RECHUM",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .Or. ExistCpo('DCD')" ))
oStruGrid:AddTrigger("DB_RECHUM","SDBNOMFUN",{|| .T. },{|| Posicione('DCD',1,xFilial('DCD')+M->DB_RECHUM,'DCD_NOMFUN')  }  )

oStruGrid:SetProperty("DB_DATA",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "M->DB_DATA <= M->DB_DATAFIM" ))
oStruGrid:SetProperty("DB_HRINI",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "IIF(M->DB_DATA == M->DB_DATAFIM,M->DB_HRINI <= M->DB_HRFIM,.T.)" ))

oStruGrid:SetProperty("DB_DATAFIM",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "M->DB_DATA <= M->DB_DATAFIM" ))
oStruGrid:SetProperty("DB_HRFIM",MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, "IIF(M->DB_DATA == M->DB_DATAFIM,M->DB_HRINI <= M->DB_HRFIM,.T.)" ))

oModel:AddFields('SDBMASTER',/*cOwner*/,oStruSDB)
oModel:GetModel('SDBMASTER'):SetOnlyView()
oModel:GetModel('SDBMASTER'):SetPrimaryKey( { 'DB_FILIAL','DB_DOC','DB_CLIFOR','DB_LOJA','DB_CARGA' } )

oModel:AddGrid('SDBDETAIL','SDBMASTER', oStruGrid)
oModel:SetRelation('SDBDETAIL',IIF(Type("aParArr331") != "U",aParArr331,{})           , SDB->( IndexKey(15) ))
oModel:GetModel( 'SDBDETAIL' ):SetLoadFilter( , "(DB_STATUS = '"+cStatProb+"' OR DB_STATUS = '"+cStatInte+"' OR DB_STATUS = '"+cStatAExe+"')" )

oModel:GetModel('SDBDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('SDBDETAIL'):SetNoInsertLine(.T.)

oModel:SetActivate({|oModel| InitFields(oModel) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe Machado de Oliveira
@since 11/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel    := FWLoadModel( 'WMSA331A' )
Local oStruSDB  := FWFormStruct( 2, 'SDB', { |cCampo| AllTrim( cCampo ) $ CABECALHO } ,/*lViewUsado*/ )
Local oStruGrid := FWFormStruct( 2, 'SDB', { |cCampo| AllTrim( cCampo ) $ GRID } ,/*lViewUsado*/ )
Local oView     := FWFormView():New()
Local aColsSX3  := {}

buscarSX3('DB_SERVIC',,@aColsSX3)
oStruSDB:AddField( 'SDBSERVIC',; 	// [01] C Nome do Campo
					'AB',;			// [02] C Ordem
					aColsSX3[1],;	// [03] C Titulo do campo
					aColsSX3[1],;	// [04] C Descrição do campo
					NIL,;			// [05] A Array com Help
					'C',;			// [06] C Tipo do campo
					aColsSX3[2],;	// [07] C Picture
					NIL,;			// [08] B Bloco de Picture Var
					'',;			// [09] C Consulta F3
					.F.,;			// [10] L Indica se o campo é evitável
					NIL,;			// [11] C Pasta do campo
					NIL,;			// [12] C Agrupamento do campo
					NIL,;			// [13] A Lista de valores permitido do campo (Combo)
					NIL,;			// [14] N Tamanho Maximo da maior opção do combo
					NIL,;			// [15] C Inicializador de Browse
					.T.,;			// [16] L Indica se o campo é virtual
					NIL)			// [17] C Picture Variável

buscarSX3('DB_DESSER',,@aColsSX3)
oStruSDB:AddField( 'SDBDESSER',;	//[01] C Nome do Campo
					'AC',;			//[02] C Ordem
					aColsSX3[1],;	//[03] C Titulo do campo
					aColsSX3[1],;	//[04] C Descrição do campo
					NIL,;			//[05] A Array com Help
					'C',;			//[06] C Tipo do campo
					aColsSX3[2],;	//[07] C Picture
					NIL,;			//[08] B Bloco de Picture Var
					'',;			//[09] C Consulta F3
					.F.,;			//[10] L Indica se o campo é evitável
					NIL,;			//[11] C Pasta do campo
					NIL,;			//[12] C Agrupamento do campo
					NIL,;			//[13] A Lista de valores permitido do campo (Combo)
					NIL,;			//[14] N Ta	manho Maximo da maior opção do combo
					NIL,;			//[15] C Inicializador de Browse
					.T.,;			//[16] L Indica se o campo é virtual
					NIL)			//[17] C Picture Variável

buscarSX3('DB_TAREFA',,@aColsSX3)
oStruSDB:AddField( 'SDBTAREFA',; 	// [01] C Nome do Campo
					'AD',;			// [02] C Ordem
					aColsSX3[1],;	// [03] C Titulo do campo
					aColsSX3[1],;	// [04] C Descrição do campo
					NIL,;			// [05] A Array com Help
					'C',;			// [06] C Tipo do campo
					aColsSX3[2],;	// [07] C Picture
					NIL,;			// [08] B Bloco de Picture Var
					'',;			// [09] C Consulta F3
					.F.,;			// [10] L Indica se o campo é evitável
					NIL,;			// [11] C Pasta do campo
					NIL,;			// [12] C Agrupamento do campo
					NIL,;			// [13] A Lista de valores permitido do campo (Combo)
					NIL,;			// [14] N Tamanho Maximo da maior opção do combo
					NIL,;			// [15] C Inicializador de Browse
					.T.,;			// [16] L Indica se o campo é virtual
					NIL)			// [17] C Picture Variável

buscarSX3('DB_DESTAR',,@aColsSX3)
oStruSDB:AddField( 'SDBDESTAR',; 	// [01] C Nome do Campo
					'AE',;			// [02] C Ordem
					aColsSX3[1],;	// [03] C Titulo do campo
					aColsSX3[1],;	// [04] C Descrição do campo
					NIL,;			// [05] A Array com Help
					'C',;			// [06] C Tipo do campo
					aColsSX3[2],;	// [07] C Picture
					NIL,;			// [08] B Bloco de Picture Var
					'',;			// [09] C Consulta F3
					.F.,;			// [10] L Indica se o campo é evitável
					NIL,;			// [11] C Pasta do campo
					NIL,;			// [12] C Agrupamento do campo
					NIL,;			// [13] A Lista de valores permitido do campo (Combo)
					NIL,;			// [14] N Tamanho Maximo da maior opção do combo
					NIL,;			// [15] C Inicializador de Browse
					.T.,;			// [16] L Indica se o campo é virtual
					NIL)			// [17] C Picture Variável

buscarSX3('DB_NOMFUN',,@aColsSX3)
oStruGrid:AddField( 'SDBNOMFUN',; 	// [01] C Nome do Campo
					'06',;			// [02] C Ordem
					aColsSX3[1],;	// [03] C Titulo do campo
					aColsSX3[1],;	// [04] C Descrição do campo
					NIL,;			// [05] A Array com Help
					'C',;			// [06] C Tipo do campo
					aColsSX3[2],;	// [07] C Picture
					NIL,;			// [08] B Bloco de Picture Var
					'',;			// [09] C Consulta F3
					.F.,;			// [10] L Indica se o campo é evitável
					NIL,;			// [11] C Pasta do campo
					NIL,;			// [12] C Agrupamento do campo
					NIL,;			// [13] A Lista de valores permitido do campo (Combo)
					NIL,;			// [14] N Tamanho Maximo da maior opção do combo
					NIL,;			// [15] C Inicializador de Browse
					.T.,;			// [16] L Indica se o campo é virtual
					NIL)			// [17] C Picture Variável

oStruGrid:SetProperty("DB_ATIVID" ,MVC_VIEW_ORDEM,"03")
oStruGrid:SetProperty("DB_ATIVID" ,MVC_VIEW_CANCHANGE,.F.)

oStruGrid:SetProperty("DB_DESATI" ,MVC_VIEW_ORDEM,"04")
oStruGrid:SetProperty("DB_DESATI" ,MVC_VIEW_CANCHANGE,.F.)

oStruGrid:SetProperty("DB_RECHUM" ,MVC_VIEW_ORDEM,"05")
oStruGrid:SetProperty("DB_RECHUM" ,MVC_VIEW_LOOKUP,"DCD")

oStruGrid:SetProperty("DB_DATA"   ,MVC_VIEW_ORDEM,"07")
oStruGrid:SetProperty("DB_HRINI"  ,MVC_VIEW_ORDEM,"08")
oStruGrid:SetProperty("DB_DATAFIM",MVC_VIEW_ORDEM,"09")
oStruGrid:SetProperty("DB_HRFIM"  ,MVC_VIEW_ORDEM,"10")

oView:SetModel( oModel )
oView:AddField('VIEW_SDB',oStruSDB,'SDBMASTER')
oView:AddGrid('VIEW_GRID',oStruGrid,'SDBDETAIL')

oView:CreateHorizontalBox('FIELDSSDB',15)
oView:CreateHorizontalBox('GRIDSDB',85)

oView:SetOwnerView('VIEW_SDB','FIELDSSDB')
oView:SetOwnerView('VIEW_GRID','GRIDSDB')

oView:SetCloseOnOk({||.T.})

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} InitFields
Atribui os valores aos campos

@author Felipe Machado de Oliveira
@since 13/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function InitFields(oModel)
Local nI         := 1
Local oModelGrid := oModel:GetModel('SDBDETAIL')
Local cHoraIni   := SubStr(Time(),1,TamSX3("DB_HRINI")[1])
Local cHoraFim   := SubStr(Time(),1,TamSX3("DB_HRFIM")[1])

For nI := 1 To oModelGrid:length()
	oModelGrid:GoLine(nI)

	If Empty(oModelGrid:GetValue("DB_RECHUM",nI))
		oModelGrid:SetValue("DB_RECHUM",__cUserId)
	EndIf

	If oModelGrid:GetValue("DB_DATA",nI) == CTOD("  /  /    ")
		oModelGrid:SetValue("DB_DATA",dDataBase)
	EndIf

	If Empty(oModelGrid:GetValue("DB_HRINI",nI))
		oModelGrid:SetValue("DB_HRINI",cHoraIni)
	EndIf

	If oModelGrid:GetValue("DB_DATAFIM",nI) == CTOD("  /  /    ")
		oModelGrid:SetValue("DB_DATAFIM",dDataBase)
	EndIf

	If Empty(oModelGrid:GetValue("DB_HRFIM",nI))
		oModelGrid:SetValue("DB_HRFIM",cHoraFim)
	EndIf

Next nI

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} PosVal
Pós validação do modelo de dados equivale ao TodoOk

@author Felipe Machado de Oliveira
@since 13/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PosVal(oModel)
Local lRet := .T.
Local nI := 1
Local oModelGrid := oModel:GetModel('SDBDETAIL')

For nI := 1 To oModelGrid:Length()
	oModelGrid:GoLine(nI)

	If Empty(oModelGrid:GetValue("DB_RECHUM",nI))
		Help('',1,'WMSA33103',,STR0001+AllTrim(buscarSX3('DB_RECHUM'))+STR0002,4,1) //"O campo "###" não foi preenchido!"
		lRet := .F.
		Exit
	EndIf

	If lRet .And. oModelGrid:GetValue("DB_DATA",nI) == CTOD("  /  /    ")
		Help('',1,'WMSA33104',,STR0001+AllTrim(buscarSX3('DB_DATA'))+STR0002,4,1) //"O campo "###" não foi preenchido!"
		lRet := .F.
		Exit
	EndIf

	If lRet .And. (Empty(oModelGrid:GetValue("DB_HRINI",nI)) .Or. oModelGrid:GetValue("DB_HRINI",nI) == "  :  ")
		Help('',1,'WMSA33105',,STR0001+AllTrim(buscarSX3('DB_HRINI'))+STR0002,4,1) //"O campo "###" não foi preenchido!"
		lRet := .F.
		Exit
	EndIf

	If lRet .And. oModelGrid:GetValue("DB_DATAFIM",nI) == CTOD("  /  /    ")
		Help('',1,'WMSA33106',,STR0001+AllTrim(buscarSX3('DB_DATAFIM'))+STR0002,4,1) //"O campo "###" não foi preenchido!"
		lRet := .F.
		Exit
	EndIf

	If lRet .And. (Empty(oModelGrid:GetValue("DB_HRFIM",nI)) .Or. oModelGrid:GetValue("DB_HRINI",nI) == "  :  ")
		Help('',1,'WMSA33107',,STR0001+AllTrim(buscarSX3('DB_HRFIM'))+STR0002,4,1) //"O campo "###" não foi preenchido!"
		lRet := .F.
		Exit
	EndIf

	If lRet .And. oModelGrid:GetValue("DB_DATA",nI) > oModelGrid:GetValue("DB_DATAFIM",nI)
		Help('',1,'WMSA33108',,STR0003,4,1) //"Data e hora inicial deve ser menor que data e hora final !"
		lRet := .F.
		Exit
	EndIf

	If lRet .And. oModelGrid:GetValue("DB_DATA",nI) == oModelGrid:GetValue("DB_DATAFIM",nI)
		If oModelGrid:GetValue("DB_HRINI",nI) > oModelGrid:GetValue("DB_HRFIM",nI)
			Help('',1,'WMSA33109',,STR0003,4,1) //"Data e hora inicial deve ser menor que data e hora final !"
			lRet := .F.
			Exit
		EndIf
	EndIf
Next nI

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GravaDados
Finalização das movimentações

@author Felipe Machado de Oliveira
@since 13/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GravaDados(oModel)
Return FwFormCommit(oModel, {|oModel| BeforeCommit(oModel)},,,{|oModel| InTTS(oModel)})

/*/{Protheus.doc} BeforeCommit
Ajusta status das movimentações antes de efetivar o commit
@author amanda.vieira
@since 26/06/2020
@param oModel, objeto, modelo de dados
/*/
Static Function BeforeCommit(oModel)
Local lRet    := .T.
Local cFunExe := ""
Local dDtUsa261  := CtoD("31/05/2023")
Private lWmsMovPkg := .F.

	DC5->(DbSetOrder(1)) //-- DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
	DC5->(MsSeek(xFilial('DC5')+SDB->DB_SERVIC+SDB->DB_ORDTARE))
	SX5->(DbSetOrder(1))
	SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
	cFunExe := AllTrim(Upper(SX5->(X5Descri())))

	If 'DLAPANHE' $ cFunExe; //Apanhe
		.Or. 'DLGXABAST' $ cFunExe //(Re)Abastecimento
		If 'DLGXABAST' $ cFunExe
			lWmsMovPkg := .T.
		EndIf
		//quando a data dos fontes abaixo for maior que dDtUsa261 a rotina de finalização da movimentaão pro WMS atual estará efetuando um 
		//execauto do mata261 desta forma nao faz sentido mais a validação no mata260.
		If GetApoInfo("MATA261.PRX")[4] < dDtUsa261 .OR. GetApoInfo("WMSXFUNA.PRW")[4] < dDtUsa261
			lRet := ValidarSaida(oModel) //Rose retirado validação pois ira usar o mata261
		EndIf
	ElseIf 'DLCONFSAI' $ cFunExe //Conferência Expedição
		lRet := ValidarConf(oModel)
	EndIf

	If lRet
		oModel:SetValue("DB_QTDLID",oModel:GetValue('DB_QUANT'))
		oModel:SetValue("DB_STATUS",cStatManu)
	Else
		oModel:LoadValue("DB_STATUS",cStatProb)
		oModel:LoadValue("DB_HRINI","")
		oModel:LoadValue("DB_HRFIM","")
		oModel:LoadValue("DB_DATAFIM",dDataVazia)
	EndIf
Return .T.

/*/{Protheus.doc} ValidarSaida
Valida se saída pode ser realizada
@author amanda.vieira
@since 26/06/2020
@param oModel, objeto, modelo de dados
@return lRet, lógico, se retorno .T. a saída do produto pode ser realizada
/*/
Static Function ValidarSaida(oModel)
Local lRet := .T.

	cIdMovtoAt := SDB->DB_IDMOVTO // Variável private que será utilizada na consulta de saldo

	lRet := a260WMSTOK(oModel:GetValue("DB_PRODUTO"),;
					   oModel:GetValue("DB_PRODUTO"),;
					   oModel:GetValue("DB_LOCAL"),;
					   oModel:GetValue("DB_LOCAL"),;
					   oModel:GetValue("DB_QUANT"),; 
					   oModel:GetValue("DB_QTSEGUM"),;
					   dDataBase,;
					   oModel:GetValue("DB_LOTECTL"),;
					   oModel:GetValue("DB_LOCALIZ"),;
					   oModel:GetValue("DB_ENDDES"),; 
					   oModel:GetValue("DB_NUMLOTE"),;
					   "",;
					   oModel:GetValue("DB_DOC"))
Return lRet

/*/{Protheus.doc} ValidarConf
Valida se a conferência de saída pode ser realizada,
verificando se existe alguma tarefa de separação com problema
@author amanda.vieira
@since 26/06/2020
@param oModel, objeto, modelo de dados
@param nI, numérico, linha posicionada do modelo
@return lRet, lógico, se retorno .T. a conferêcia saída do produto pode ser realizada
/*/
Static Function ValidarConf(oModel)
Local lRet := .T.
Local nI := 0
Local nLineAtu := oModel:nLine

	oModel:GoLine(1)
	For nI := 1 To oModel:Length()
		oModel:GoLine(nI)
		If oModel:GetValue("DB_STATUS") == cStatProb
			If (oModel:GetValue("DB_SERVIC") == SDB->DB_SERVIC .And. ;
				oModel:GetValue("DB_ORDTARE") <> SDB->DB_ORDTARE .And. ;
				oModel:GetValue("DB_PRODUTO") == SDB->DB_PRODUTO .And.;
				oModel:GetValue("DB_LOTECTL") == SDB->DB_LOTECTL .And.;
				oModel:GetValue("DB_NUMLOTE") == SDB->DB_NUMLOTE .And.;
				oModel:GetValue("DB_ESTORNO") == " " .And. ;
				oModel:GetValue("DB_ATUEST") == "N")
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nI
	oModel:GoLine(nLineAtu)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Função para atualização das informações complementares com base na
atividade que está sendo finalizada pelo monitor de serviços
@author squad WMS
@param oModel, objeto, modelo de dados
@return lRet, lógico, se retorno .T. indica que o commit pode ser realizado
/*/
Static Function InTTS(oModel)
Local lRet    := .T.
Local cFunExe := ""
Local nI := 0
Local oModelGrid := oModel:GetModel('SDBDETAIL')

	DC5->(DbSetOrder(1)) //-- DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
	SX5->(DbSetOrder(1))

	For nI := 1 To oModelGrid:Length()
		oModelGrid:GoLine(nI)
		
		DC5->(MsSeek(xFilial('DC5')+oModelGrid:GetValue('DB_SERVIC')+oModelGrid:GetValue('DB_ORDTARE')))
		SX5->(MsSeek(xFilial('SX5')+'L6'+DC5->DC5_FUNEXE))
		cFunExe := AllTrim(Upper(SX5->(X5Descri())))

		SDB->(DbGoTo(oModelGrid:ADATAMODEL[nI][4]))
		
		If 'DLENDERECA' $ cFunExe; //Endereçamento
			.Or. 'DLTRANSFER' $ cFunExe; //Transferencia
			.Or. 'DLDESFRAG'  $ cFunExe; //Desfragmentação(Transferencia)
			.Or. 'DLCROSSDOC' $ cFunExe  //Cross Docking
			lRet := DLV080GrIn(.F.)
		ElseIf 'DLAPANHE' $ cFunExe; //Apanhe
			.Or. 'DLGXABAST' $ cFunExe //(Re)Abastecimento
			If !(oModelGrid:GetValue('DB_STATUS') == cStatProb)
				lRet := DLVGrSaida(cFunExe,,.F.)
			EndIf
		ElseIf 'DLCONFSAI' $ cFunExe //Conferência Expedição
			If !(oModelGrid:GetValue('DB_STATUS') == cStatProb)
				lRet := FinCofExp()
			EndIf
		EndIf
	Next nI
Return lRet

//Função para finalizar o processo de conferência via coletor
//Efetua o tratamento do parametro MV_WMSLPVC
//Liberação do pedido de venda na convocação. 1-Na Separação;2-Na Conferência.
Static Function FinCofExp(nRecno)
Local aAreaAnt  := GetArea()
Local lRet      := .F.
Local cQuery    := ""
Local cAliasQry := ""
Local lFinConf := .F.
Local lCarga    := WmsCarga(SDB->DB_CARGA)

	//Verifica se existe alguma atividade do documento sem finalizar
	//Só efetua a liberação do pedido de venda na última atividade
	cQuery := "SELECT DISTINCT 1"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
	cQuery +=   " AND DB_ORDTARE = '"+SDB->DB_ORDTARE+"'"
	cQuery +=   " AND DB_TAREFA  = '"+SDB->DB_TAREFA+"'"
	cQuery +=   " AND DB_ATIVID  = '"+SDB->DB_ATIVID+"'"
	If lCarga
		cQuery += " AND DB_CARGA = '"+SDB->DB_CARGA+"'"
	Else
		cQuery += " AND DB_DOC   = '"+SDB->DB_DOC+"'"
	EndIf
	cQuery += " AND DB_STATUS NOT IN ('1','M')"
	cQuery += " AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry  := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	lFinConf := (cAliasQry)->(Eof())
	(cAliasQry)->(DbCloseArea())

	If lFinConf 
		//Somente finaliza conferência se não existem mais movimentações pendentes e a liberação for na conferência
		lRet := .T.

		If DC5->DC5_LIBPED   == '2'
			cQuery := "SELECT SC9.R_E_C_N_O_ RECNOSC9"
			cQuery +=  " FROM "+RetSqlName("SDB")+" SDB, "+RetSqlName("SC9")+" SC9"
			cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
			cQuery +=   " AND DB_ESTORNO = ' '"
			cQuery +=   " AND DB_ATUEST  = 'N'"
			cQuery +=   " AND DB_SERVIC  = '"+SDB->DB_SERVIC+"'"
			cQuery +=   " AND DB_ORDTARE = '"+SDB->DB_ORDTARE+"'"
			cQuery +=   " AND DB_TAREFA  = '"+SDB->DB_TAREFA+"'"
			cQuery +=   " AND DB_ATIVID  = '"+SDB->DB_ATIVID+"'"
			If lCarga
				cQuery += " AND DB_CARGA = '"+SDB->DB_CARGA+"'"
			Else
				cQuery += " AND DB_DOC   = '"+SDB->DB_DOC+"'"
			EndIf
			cQuery += " AND DB_STATUS IN ('1','M')"
			cQuery += " AND SDB.D_E_L_E_T_  = ' '"
			cQuery += " AND C9_FILIAL  = '"+xFilial("SC9")+"'"
			If lCarga
				cQuery += " AND C9_CARGA  = '"+SDB->DB_CARGA+"'"
			Else
				cQuery += " AND C9_PEDIDO = '"+SDB->DB_DOC+"'"
				cQuery += " AND C9_ITEM   = DB_SERIE"
			EndIf
			cQuery += " AND C9_PRODUTO = DB_PRODUTO"
			cQuery += " AND C9_SERVIC  = DB_SERVIC"
			cQuery += " AND C9_LOTECTL = DB_LOTECTL"
			cQuery += " AND C9_IDDCF   = DB_IDDCF"
			cQuery += " AND C9_BLWMS   = '01'"
			cQuery += " AND C9_BLEST   = '  '"
			cQuery += " AND C9_BLCRED  = '  '"
			cQuery += " AND SC9.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			While (cAliasQry)->(!Eof())
				SC9->(DbGoTo((cAliasQry)->RECNOSC9)) //-- Posiciona no registro do SC9 correspondente
				RecLock("SC9", .F.)
				SC9->C9_BLWMS := "05"
				SC9->(MsUnlock())
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf

RestArea(aAreaAnt)
Return lRet
