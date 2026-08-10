#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA070.CH"

static _WHEN_CHASSI := ""
static _WHEN_BLOCK := .F.

static oLogVEIA070

static aSA1Fill
static oSoConfig

static oVW0_VEIA071
static oVW0_VEIA072

//Static cMVMIL0006 := GetNewPar("MV_MIL0006","")
static aNoCopy    := {"VV1_BBDALT","VV1_BBDEL","VV1_BBDINC","VV1_BBEQTY","VV1_BBINST","VV1_BBINTG","VV1_BBPEND","VV1_BBRFID","VV1_BBSTST","VV1_BBSTTY","VV1_BBSYNC","VV1_BBYARD","VV1_CGCODE","VV1_CHAINT","VV1_CHASSI","VV1_CLIULV","VV1_CLJULV","VV1_DATPED","VV1_DTDPCP","VV1_DTDUCP","VV1_DTEFAB","VV1_DTPCOM","VV1_DTUCOM","VV1_FILULV","VV1_LJPANT","VV1_LOCRID","VV1_NOMVEN","VV1_NUMTRA","VV1_OBSERV","VV1_PEDFAB","VV1_PLAVEI","VV1_RENAVA","VV1_SOLCID","VV1_TRACPA","VV1_ULTKIL","VV1_ULTTRI","VV1_VEND"}
//Static lMVMIL0185 := GetNewPar("MV_MIL0185",.F.)

/*/{Protheus.doc} VEIA070
	Cadastro de veículos MVC (VV1)

	@type function
	@author Vinicius Gati
	@since 28/07/2023
/*/
Function VEIA070()
	Local oBrowse
	// Instanciamento da Classe de Browse
	oBrowse := BrowseDef()
	oBrowse:Activate()
Return

Static Function BrowseDef()
	Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VV1')
	oBrowse:SetDescription(STR0001) // 'Cadastro Veículo'
Return oBrowse

Static Function ModelDef()
	Local oStruVV1 := FWFormStruct( 1, 'VV1' )
	Local oModel
	Local bAuxRelacao
	local aAuxTrigger
	//Local lGravaFrota := SuperGetMv("MV_MIL0175",, .F.)
	//Local oReplicar := VA070022C_Replicar()
	//Local oModRoda  := oReplicar:GetModel()

	FWMemoVirtual( oStruVV1,{ { 'VV1_OBSMEM' , 'VV1_OBSERV' } } ) 

	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VE1",1,xFilial("VE1")+VV1->VV1_CODMAR,"VE1_DESMAR")' )
	oStruVV1:SetProperty('VV1_DESMAR', MODEL_FIELD_INIT, bAuxRelacao )
	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VV2",1,xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI,"VV2_DESMOD")' )
	oStruVV1:SetProperty('VV1_DESMOD', MODEL_FIELD_INIT, bAuxRelacao )
	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VV7",1,xFilial("VV7")+VV1->VV1_CARROC,"VV7_DESCRI")' )
	oStruVV1:SetProperty('VV1_DESCAR', MODEL_FIELD_INIT, bAuxRelacao )
	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VVC",1,XFILIAL("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORFXA,"VVC_DESCRI")' )
	oStruVV1:SetProperty('VV1_DESCFX', MODEL_FIELD_INIT, bAuxRelacao )
	//bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VF0",1,XFILIAL("VF0")+VV1->VV1_CODMAR+VV1->VV1_PLAREV,"VF0_DESPLA")' )
	//oStruVV1:SetProperty('VV1_DESPLA', MODEL_FIELD_INIT, bAuxRelacao )
	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("SA1",1,xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU,"A1_NREDUZ")' )
	oStruVV1:SetProperty('VV1_NOMPRO', MODEL_FIELD_INIT, bAuxRelacao )
	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("VVN",1,xFilial("VVN")+VV1->VV1_TPGREX+VV1->VV1_CODMAR+VV1->VV1_CODGAR,"VVN_DESCRI")' )
	oStruVV1:SetProperty('VV1_DESCRI', MODEL_FIELD_INIT, bAuxRelacao )

	// 0=Estoque;1=Vendido;2=Em Transito;3=Remessa;4=Consignado;5=Transferido;6=Reservado;7=Progresso;8=Pedido
	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID , 'Vazio() .or. Pertence("012345678")' )
	oStruVV1:SetProperty('VV1_SITVEI', MODEL_FIELD_VALID, bAuxValid )
	//

	bAuxRelacao := FWBuildFeature( STRUCT_FEATURE_INIPAD , 'Posicione("SA1",1,xFilial("SA1")+VV1->VV1_PROATU+VV1->VV1_LJPATU,"A1_NREDUZ")' )
	oStruVV1:SetProperty('VV1_NOMPRO', MODEL_FIELD_INIT, bAuxRelacao )

	// Os campos VV1_ROTINA, VV1_AUXFIL , VV1_AUXMOV sao campos adicionados manualmente na MODEL pois são utilizados somente para 
	// conseguir gravar corretamente na tabela de LOG a rotina e a ultima movimentacao do veiculo ...

	
		oStruVV1:AddField(;
			'VV1_ROTINA',; // cTitulo - 'Legenda'
			'',; // cTooltip
			'VV1_ROTINA',; // cIdField
			'C',; // cTipo
			TamSX3("VW0_ROTINA")[1],; // nTamanho
			0,; // nDecimal
			,; // bValid
			,; // bWhen
			{},; // aValues
			.F.,; // lObrigat
			FWBuildFeature( STRUCT_FEATURE_INIPAD, "'VEIA070'"),; // bInit
			.F.,; // lKey
			.F.,; // lNoUpd
			.T.,; // lVirtual
			) // cValid
	

	oStruVV1:AddField(;
		'Filial Aux.',; // cTitulo - 'Legenda'
		'',; // cTooltip
		'VV1_AUXFIL',; // cIdField
		'C',; // cTipo
		FWSizeFilial(),; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		,; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

	oStruVV1:AddField(;
		'Mov. Aux.',; // cTitulo - 'Legenda'
		'',; // cTooltip
		'VV1_AUXMOV',; // cIdField
		'C',; // cTipo
		TamSX3("VV0_NUMTRA")[1],; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		,; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

	if VV1->(FieldPos("VV1_BBSTTY")) <> 0

		aAuxTrigger := FwStruTrigger(;
			"VV1_ESTVEI" ,; // Campo Dominio
			"VV1_BBSTTY" ,; // Campo de Contradominio
			"IIF( FWFldGet('VV1_ESTVEI') == '0' , '1' , '2' )",; // Regra de Preenchimento
			.f. ,; // Se posicionara ou nao antes da execucao do gatilhos
			,; // Alias da tabela a ser posicionada
			,; // Ordem da tabela a ser posicionada
			,; // Chave de busca da tabela a ser posicionada
			"! Empty(FWFldGet('VV1_ESTVEI'))" ,; // Condicao para execucao do gatilho
			NIL ) // Sequencia do gatilho (usado para identificacao no caso de erro)
		
		oStruVV1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
	endif

	if VV1->(FieldPos("VV1_BBEQTY")) <> 0

		aAuxTrigger := FwStruTrigger(;
			"VV1_LJPATU" ,; // Campo Dominio
			"VV1_BBEQTY" ,; // Campo de Contradominio
			"'1'",; // Regra de Preenchimento
			.f. ,; // Se posicionara ou nao antes da execucao do gatilhos
			,; // Alias da tabela a ser posicionada
			,; // Ordem da tabela a ser posicionada
			,; // Chave de busca da tabela a ser posicionada
			"! Empty(FWFldGet('VV1_LJPATU')) .and. Empty(FWFldGet('VV1_BBEQTY'))" ,; // Condicao para execucao do gatilho
			NIL ) // Sequencia do gatilho (usado para identificacao no caso de erro)

		oStruVV1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	endif

	//bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID , 'Vazio() .or. ExistCPO("SA1",FWFldGet("VV1_PROATU"),1)' )
	//oStruVV1:SetProperty('VV1_PROATU', MODEL_FIELD_VALID, bAuxValid )

	//aAuxTrigger := FwStruTrigger(;
	//	"VV1_LJPATU" ,; // Campo Dominio
	//	"VV1_NOMPRO" ,; // Campo de Contradominio
	//	"SA1->A1_NREDUZ",; // Regra de Preenchimento
	//	.T. ,; // Se posicionara ou nao antes da execucao do gatilhos
	//	"SA1" ,; // Alias da tabela a ser posicionada
	//	1 ,; // Ordem da tabela a ser posicionada
	//	"xFilial('SA1') + FWFldGet('VV1_PROATU') + FwFldGet('VV1_LJPATU')",; // Chave de busca da tabela a ser posicionada
	//	"!Empty(FWFldGet('VV1_LJPATU'))" ,; // Condicao para execucao do gatilho
	//	NIL ) // Sequencia do gatilho (usado para identificacao no caso de erro)   	
	//oStruVV1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])		

	//bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID , 'ExistCPO("SA1",FWFldGet("VV1_PROATU")+alltrim(FWFldGet("VV1_LJPATU")),1)' )
	//oStruVV1:SetProperty('VV1_LJPATU', MODEL_FIELD_VALID, bAuxValid )

	aAuxTrigger := FwStruTrigger("VV1_PRCADA","VV1_PRUSUA","RetCodUsr()",.F.,"",,,"FWFldGet('VV1_PRCADA')=='1' .AND. Empty(FWFldGet('VV1_PRUSUA'))")
	oStruVV1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	aAuxTrigger := FwStruTrigger("VV1_PRUSUA","VV1_PRNUSA","Left(UsrRetName(FWFldGet('VV1_PRUSUA')),25)",.F.)
	oStruVV1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	aAuxTrigger := FwStruTrigger("VV1_MODVEI","VV1_DESMOD","VV2->VV2_DESMOD",.F.,"",,,"!Empty(FWFldGet('VV1_CODMAR'))")
	oStruVV1:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	// A rotina VEIA140 cria um veiculo com o minimo de informacao 
	If IsInCallStack("VEIA140") .or. IsInCallStack("VEIA162") .or. IsInCallStack("VEIXX030") .or. IsInCallStack("VEIXX002")//.or. IsInCallStack("VEIXX001") .or. IsInCallStack("VEIXX000")
		oStruVV1:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .f.)
		oStruVV1:SetProperty( 'VV1_CHASSI' , MODEL_FIELD_WHEN, {|| .t. })

		bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID , 'Vazio() .or. Pertence("012345678")' )
		oStruVV1:SetProperty('VV1_SITVEI', MODEL_FIELD_VALID, bAuxValid )
	
		bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID , 'Vazio() .or. ExistCPO("SA1",FWFldGet("VV1_PROATU"),1,,,.F.)' )
		oStruVV1:SetProperty('VV1_PROATU', MODEL_FIELD_VALID, bAuxValid )

		bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID , 'Vazio() .or. ExistCPO("SA1",FWFldGet("VV1_PROATU")+alltrim(FWFldGet("VV1_LJPATU")),1,,,.F.)' )
		oStruVV1:SetProperty('VV1_LJPATU', MODEL_FIELD_VALID, bAuxValid )
	Else
		// Verifica se o ambiente esta integrado com o Blackbird
		if GetNewPar("MV_MIL0185",.f.) == .t. 
			oStruVV1:SetProperty('VV1_PROATU', MODEL_FIELD_OBRIGAT, .T. )
			oStruVV1:SetProperty('VV1_LJPATU', MODEL_FIELD_OBRIGAT, .T. )
		Endif
	EndIf

	oModel := MPFormModel():New('VEIA070' )
	oModel:AddFields( 'MODEL_VV1', /*cOwner*/, oStruVV1)
	oModel:SetDescription( STR0002 ) // 'Modelo de dados de Veículo'
	oModel:GetModel( 'MODEL_VV1' ):SetDescription( STR0003 ) // 'Dados do Veículo'

	oModel:SetPrimaryKey( { "VV1_FILIAL", "VV1_CHAINT" } )

	oModel:InstallEvent("DEF",, VEIA070EVDEF():New()) // Eventos de PE - Compatibilidade com o VEIXA010

	oModel:InstallEvent("PE",, VEIA070EVPE():New()) // Eventos de PE - Compatibilidade com o VEIXA010

	oModel:getModel( 'MODEL_VV1' ):setFldNoCopy( aNoCopy )	// campos p/ não copiar

	//oModel:AddGrid( 'REPLICAR', 'MODEL_VV1', oModRoda , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )
	//oModel:GetModel('REPLICAR'):SetDescription( "Outros Veículos" ) // 
	//oModel:GetModel('REPLICAR'):SetNoDeleteLine( .F. )
	//oModel:GetModel('REPLICAR'):SetOptional( .T. )
Return oModel

Static Function ViewDef()
	Local oModel   := FWLoadModel( 'VEIA070' )
	Local oStruVV1 := FWFormStruct( 2, 'VV1' )
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_VV1', oStruVV1, 'MODEL_VV1' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_VV1', 'TELA' )
Return oView

/*/{Protheus.doc} VA0700133_Pacote
	Abre a Tela para seleção do pacote(Configuração de Veículo)

	@author Rubens Takahashi
	@since 20/07/2022
	@type function
/*/
Function VA0700133_Pacote(cAlias,nReg,nOpc)
	
	local aCfgsPacote := {}
	local aCfgs := {}
	local lConfirm := .f.
	local lProc := .f.

	dbSelectArea("VV1")

	if ! softlock("VV1")
		return .f.
	endif

	If GetNewPar("MV_MIL0168","0") == "1" // Trabalha com Pacote de Configuração ? 
	
		aCfgsPacote := VEIA242( VV1->VV1_CODMAR , VV1->VV1_MODVEI , VV1->VV1_SEGMOD , VV1->VV1_CHAINT , .t. , @lConfirm, .t. )
		If lConfirm
			VA380GRVCFG(VV1->VV1_CHAINT, aCfgsPacote[4], aCfgsPacote[3], aCfgsPacote[1]) // Configuração, Valor de Venda, Cód. Pacote
			lProc := .t.
		EndIf

	Else

		VV2->(DbSeek( xFilial('VV2') + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD ))

		aCfgsPacote := VA380CONFIG(VV1->VV1_CHAINT, VV1->VV1_CODMAR, VV2->VV2_GRUMOD, @aCfgs , VV1->VV1_MODVEI , VV1->VV1_SEGMOD )
		if aCfgsPacote != nil
			VA380GRVCFG( VV1->VV1_CHAINT , aCfgsPacote[1], aCfgsPacote[2] ) // Configuração, Valor de Venda
			lProc := .t.
		Endif

	EndIf

	vv1->(msunlock())

	if lProc
		MsgInfo(STR0006)	// "Pacote alterado."
	endif


Return

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.VEIA070' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.VEIA070' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina Title STR0009 Action 'VIEWDEF.VEIA070' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina Title STR0010 Action 'VIEWDEF.VEIA070' OPERATION 5 ACCESS 0 // 'Excluir'
	ADD OPTION aRotina Title STR0011 Action 'VIEWDEF.VEIA070' OPERATION 8 ACCESS 0 // 'Imprimir'
	ADD OPTION aRotina Title STR0012 Action 'VIEWDEF.VEIA070A' OPERATION 9 ACCESS 0 // 'Replicar'
	ADD OPTION aRotina Title STR0013 Action 'VA0700133_Pacote' OPERATION 4 ACCESS 0 // 'Pacote'
	ADD OPTION aRotina Title STR0014 Action 'VA0700153_IncluirKMHorimetro' OPERATION 4 ACCESS 0 // 'Incluir KM/Horimetro'

	//if cMVMIL0006 == "JD" .and. lMVMIL0185
	if OA2610123_integraDynamics(.f.)
		ADD OPTION aRotina Title STR0015 Action 'VA0700033_TransmitirBlackBird' OPERATION 4 ACCESS 0 // 'Transmitir Blackbird'
		ADD OPTION aRotina Title STR0016 Action 'VA0700053_ExcluirBlackbird' OPERATION 4 ACCESS 0 // 'Excluir Blackbird'
		ADD OPTION aRotina Title STR0017 Action 'VA0700043_LogTransmissao' OPERATION 9 ACCESS 0	// 'Log Comun. Blackbird'
		ADD OPTION aRotina Title STR0019 Action 'VA070_PENDBB' OPERATION 2 ACCESS 0 // 'Pendência Integração Blackbird'
		ADD OPTION aRotina Title STR0020 Action 'VA070_MOVBB' OPERATION 2 ACCESS 0 // 'Cons. Movimentação - Blackbird'
	endif
	ADD OPTION aRotina Title STR0021 Action 'VA0700213_RastreamentoVeiculo' OPERATION 2 ACCESS 0 // 'Rastreamento de Veiculo'
	ADD OPTION aRotina Title STR0049 Action 'VA0700251_Avaliacoes' OPERATION 2 ACCESS 0 // Avaliações do Veículo

	If FWIsAdmin( __cUserID )
		ADD OPTION aRotina Title STR0050 Action 'VA0700263_ReprocessaStatus' OPERATION 4 ACCESS 0 // Reprocessa Status
	endif

Return aRotina

Function VA0700263_ReprocessaStatus(cAlias,nReg,nOpc)
	FGX_AMOVVEI(xFilial("VV1"),VV1->VV1_CHASSI, "VA0700263_ReprocessaStatus" )
	FWAlertInfo(STR0051) // "Status Reprocessado."
Return

Function VA070_MOVBB(cAlias,nReg,nOpc)
	VC1500083_ConsultaMovExterno(VV1->VV1_CHAINT)
Return


Function VA0700213_RastreamentoVeiculo(cAlias,nReg,nOpc)

	if VV1->(Eof())
		Return
	endif

	VEIVC140(,VV1->VV1_CHAINT)
Return

Function VA070_PENDBB(cAlias,nReg,nOpc)
	local cAlVQL := "TVQL"
	Local oFVisLogPend

	nOps := 2

	if VV1->VV1_BBPEND <> "1"
		FMX_HELP("VA0070ERR003",STR0022)	// "Registro não possui pendência de integração com o Blackbird."
		return .t.
	endif

	oFVisLogPend := OFVisualizaDados():New("VA070BBPEND", STR0023)	// "Pendências para integração com o Blackbird"

	oFVisLogPend:AddHeaderMGET({;
		{'TIPO'    , "C" },;
		{'TAMANHO' , TamSX3("VV1_CHAINT")[1]},;
		{'CAMPO'   , 'VA0870CHAINT' },;
		{'TITULO'  , RetTitle("VV1_CHAINT")},;
		{'VALOR'   , VV1->VV1_CHAINT} ;
	})
	oFVisLogPend:AddHeaderMGET({;
		{'TIPO'    , "C" },;
		{'TAMANHO' , TamSX3("VV1_CHASSI")[1]},;
		{'CAMPO'   , 'VA0870CHASSI' },;
		{'TITULO'  , RetTitle("VV1_CHASSI")},;
		{'VALOR'   , VV1->VV1_CHASSI} ;
	})

	oFVisLogPend:AddColumn({{"TITULO", RetTitle("VQL_DATAI")} , {"TAMANHO", TamSX3("VQL_DATAI")[1]} , {"TIPO","D"} })
	oFVisLogPend:AddColumn({{"TITULO", RetTitle("VQL_HORAI")} , {"TAMANHO", TamSX3("VQL_HORAI")[1]} , {"TIPO","N"} , {"PICTURE","@R 99:99"}})
	oFVisLogPend:AddColumn({{"TITULO", RetTitle("VQL_TIPO")} , {"TAMANHO", TamSX3("VQL_TIPO")[1]}})
	oFVisLogPend:AddColumn({{"TITULO", RetTitle("VQL_DADOS")} , {"TAMANHO", TamSX3("VQL_DADOS")[1]}})

	cSQL := "SELECT * " +;
		" FROM " + RetSQLName("VQL") + " VQL " +;
		" WHERE VQL_FILIAL = '" + xFilial("VQL") + "' " +;
		" AND VQL.VQL_AGROUP = 'VA070-SMO-EQ'" +;
		" AND VQL.VQL_FILORI = '" + xFilial("VV1") + "' " +;
		" AND VQL.VQL_CODVQL = '" + VV1->VV1_CHAINT + "'" +;
		" AND VQL.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAlVQL, .F., .T. )
	Do While !(cAlVQL)->( Eof() )

		oFVisLogPend:AddDataRow(;
			{;
				StoD((cAlVQL)->VQL_DATAI),;
				(cAlVQL)->VQL_HORAI,;
				(cAlVQL)->VQL_TIPO,;
				(cAlVQL)->VQL_DADOS;
			};
		)

		(cAlVQL)->(DbSkip())
	EndDo
	(cAlVQL)->(dbCloseArea())

	If oFVisLogPend:HasData()
		oFVisLogPend:Activate()
	EndIf

Return


/*/{Protheus.doc} VA0700021_WHEN
Executa o WHEN dos campos validando se o Veiculo 
possui movimentação de Entrada do Tipo Produção 
ou qualquer movimentação de Saida Válida

@author Andre Luis Almeida
@since 23/04/2020
@version undefined
@type function
/*/
Function VA0700021_WHEN(cCampo)
Local aArea    := GetArea()
Local cChassi  := ""
Local lRet     := .T.
Local oModel   := FWModelActive()
Local oModelVV1:= oModel:GetModel('MODEL_VV1')
Local nOper    := oModel:GetOperation()
Local cWhenCpo := GeTSX3Cache(cCampo,"X3_WHEN") // utilizado para manter o WHEN
Local cQuery   := ""
//
If nOper == MODEL_OPERATION_UPDATE
	cChassi := oModelVV1:GetValue('VV1_CHASSI')
	If ! Empty(cChassi)

		if _WHEN_CHASSI == cChassi
			if _WHEN_BLOCK
				cWhenCpo := ".F."
			endif
		else
			//
			_WHEN_CHASSI := cChassi
			//
			VV1->(dbSetOrder(2))
			if VV1->(msSeek(xFilial("VV1") + cChassi)) .and. VV1->VV1_SITVEI == "8"
				// Se o status do veiculo for PEDIDO, segue regra do WHEN do dicionario
			else
				//
				cQuery += "SELECT VVF.R_E_C_N_O_ AS REC"
				cQuery += "  FROM "+RetSqlName("VVG")+" VVG"
				cQuery += "  JOIN "+RetSqlName("VVF")+" VVF ON ( VVG.VVG_FILIAL=VVF.VVF_FILIAL AND VVG.VVG_TRACPA=VVF.VVF_TRACPA AND VVF.D_E_L_E_T_=' ' ) "
				cQuery += " WHERE VVG.VVG_CHASSI='"+cChassi+"'"
				cQuery += "   AND VVF.VVF_TIPDOC = '3'" // Existe uma Entrada com o TIPDOC = '3' - Tipo Produção
				cQuery += "   AND VVG.D_E_L_E_T_ = ' '"
				//
				cQuery += " UNION "
				//
				cQuery += "SELECT VV0.R_E_C_N_O_ AS REC"
				cQuery += "  FROM "+RetSqlName("VVA")+" VVA"
				cQuery += "  JOIN "+RetSqlName("VV0")+" VV0 ON ( VVA.VVA_FILIAL=VV0.VV0_FILIAL AND VVA.VVA_NUMTRA=VV0.VV0_NUMTRA AND VV0.D_E_L_E_T_=' ' ) "
				cQuery += " WHERE VVA.VVA_CHASSI='"+cChassi+"'"
				cQuery += "   AND VV0.VV0_SITNFI='1'" // Existe uma Saida com SITNFI = '1' - Valida
				cQuery += "   AND VVA.D_E_L_E_T_=' '"
				//
				If FM_SQL(cQuery) > 0 // Possui registro que impede alteracoes nos campos
					cWhenCpo := ".F." // Não deixar alterar o campo
					_WHEN_BLOCK := .t.
				else
					_WHEN_BLOCK := .f.
				EndIf
				//
			endif

		endif
	EndIf
EndIf
//
If !Empty(cWhenCpo)
	lRet := &(cWhenCpo)
EndIf
//
RestArea(aArea)
Return lRet


Function VA0700033_TransmitirBlackBird(cAlias,nReg,nOpc,lExibeHelp,aErro, lMsgRun, lCheckPend)
	Local oEquip
	Local oMessage
	Local nRecVV1 := VV1->(Recno())
	//Local cAlinha := ""
	Local lRetorno := .t.
	Local cTipo := 'create'
	Local aPendencia
	local lTransmitido := .f.
	local lUsaModel := .t.
	Local oModel

	Default lExibeHelp := .t.
	Default lMsgRun := .t.
	Default lCheckPend := .t. // Parametro utilizado somente na implantação. No mais nao alterar parametro

	if OA2610123_integraDynamics(.f.) == .f.
		return .t.
	endif

	if VV1->(FieldPos("VV1_BBRFID")) == 0
		return .t.
	endif

	if VV1->(FieldPos("VV1_MSBLQL")) .and. VV1->VV1_MSBLQL == '1'
		return .t.
	endif

	if VV1->VV1_BBINTG == "2"
		FMX_HELP("VA0070ERR002",STR0024,STR0025)		// "Registro configurado para não ser sincronizado com o Blackbird"		"Verifique o conteúdo do campo de integração."
		return .t.
	endif
	
	if empty(VV1->VV1_BBRFID)
		reclock("VV1",.f.)
		VV1->VV1_BBRFID := FWUUIDV4(.t.)
		VV1->(MSUnlock())
	endif	

	if VV1->VV1_BBSYNC == "1"
		if lExibeHelp
			FMX_HELP("VA0070ERR001",STR0026)	// "Registro já está sincronizado com a John Deere."
		endif
		//Conout(cAlinha + STR0027 )	// "VA0300033_TransmitirBlackBird -> Nao e necessario enviar o registro"
		return .t.
	endif

	if lCheckPend
	
		if VA0700183_PendenciaBlackbird(VV1->VV1_CHAINT,@aPendencia)

			VA0700193_RegistraPendenciaBlackbird(VV1->VV1_CHAINT, aPendencia)

			if lExibeHelp
				FMX_HELP("VA0070ERR004",STR0028,STR0029)	// "Registro com pendência(s) para integração com o Blackbird."		"Verifique o log de pendências de integração."
			endif

			return .t.
		else
			VA07000203_LimpaPendeniaBlackbird(VV1->VV1_CHAINT)
		endif
	else
 		if VV1->VV1_BBPEND == "1"
			return .t.
		endif
	endif
	
	CursorWait()

	//Conout(cAlinha + "VA0300033_TransmitirBlackBird -> " + VV1->VV1_CHASSI)

	//Conout(" ")

	VV1->(dbGoTo(nRecVV1))
	if VV1->VV1_BBINTG == "1"
		//Conout(cAlinha + "___  __             __          ___         __   __                 __   __       ___  ___ ")
		//Conout(cAlinha + " |  |__)  /\  |\ | /__`  |\/| |  |  | |\ | |  \ /  \    __    |  | |__) |  \  /\   |  |__  ")
		//Conout(cAlinha + " |  |  \ /~~\ | \| .__/  |  | |  |  | | \| |__/ \__/          \__/ |    |__/ /~~\  |  |___ ")
		//Conout(cAlinha + "                                                                                           ")
		cTipo := 'update'
	else
		//Conout(cAlinha + "___  __             __          ___         __   __            __   __   ___      ___  ___ ")
		//Conout(cAlinha + " |  |__)  /\  |\ | /__`  |\/| |  |  | |\ | |  \ /  \    __    /  ` |__) |__   /\   |  |__  ")
		//Conout(cAlinha + " |  |  \ /~~\ | \| .__/  |  | |  |  | | \| |__/ \__/          \__, |  \ |___ /~~\  |  |___ ")
		//Conout(cAlinha + "                                                                                           ")
		cTipo := 'create'
	endif

	//Conout(" ")

	oEquip := OFSoEquipment():New()
	oEquip := oEquip:FindByRecno( VV1->(recno()) )

	// ------------------------------------------------------------------------------------------------------------- //
	// ATENCAO                                                                                                       //
	// Para equipments em pedido, nao podemos utilizar a Model pois provavelmente campos obrigatórios estarão vazios //
	// ------------------------------------------------------------------------------------------------------------- //
	if VV1->VV1_SITVEI == "8"
		lUsaModel := .F.
	endif

	if lUsaModel
		oModel := FWLoadModel("VEIA070")
		oModel:setOperation(MODEL_OPERATION_UPDATE)

		if ! oModel:Activate()
			Return .f.
		endif

		oModel:SetValue("MODEL_VV1", "VV1_BBINTG", "1" )
		oModel:SetValue("MODEL_VV1", "VV1_BBSYNC", "1" )
		oModel:SetValue("MODEL_VV1", "VV1_BBDEL" , "0" )
		if empty(oModel:GetValue("MODEL_VV1","VV1_BBDINC"))
			oModel:SetValue("MODEL_VV1", "VV1_BBDINC", FGX_Timestamp() )
		endif
		oModel:SetValue("MODEL_VV1", "VV1_BBDALT", FGX_Timestamp() )
		lContinua := oModel:VldData()
	else 
		lContinua := RecLock("VV1",.f.)
	endif

	If lContinua
		if cTipo == 'create'
//			Conout(cAlinha + "VA0300033_TransmitirBlackBird -> CREATED ")
			oMessage := OFSoEquipmentCreatedInDbsMessage():New(oEquip)
		else
//			Conout(cAlinha + "VA0300033_TransmitirBlackBird -> UPDATED ")
			oMessage := OFSoEquipmentUpdatedInDbsMessage():New(oEquip)
		endif

		if lMsgRun
			FWMsgRun(, {|oSay| oMessage:Send() }, STR0030, STR0031 + VV1->VV1_BBRFID)	// "John Deere - Blackbird"		"Atualizando Equipamento - "
		else
			oMessage:Send()
		endif

		lTransmitido := (oMessage:oSoRequest:GetHTTPResponse() == 200)
		if lTransmitido
			if lUsaModel
				oModel:CommitData()
			else
				Reclock("VV1",.F.)
				VV1->VV1_BBINTG := "1"
				VV1->VV1_BBSYNC := "1"
				VV1->VV1_BBDEL  := "0"
				if empty(VV1->VV1_BBDINC)
					VV1->VV1_BBDINC := FGX_Timestamp()
				endif
				VV1->VV1_BBDALT := FGX_Timestamp()
				VV1->(msUnlock())
			endif

			// Verifica se existe algum registro de horimetro ah ser enviado ...
			VV1->(dbGoTo(nRecVV1))
			VA0700123_SendMeter(VV1->VV1_CHAINT)

			// Ajusta Options como transmitido 
			VA0700163_AdjustOptions(VV1->VV1_CHAINT)

		endif

	else
		aErro := oModel:GetErrorMessage()
		lRetorno := .f.
	endif

	if lUsaModel
		oModel:DeActivate()
	endif

	CursorArrow()
	if lTransmitido
		if lExibeHelp
			MsgInfo(STR0032)	// "Registro transmitido"
		endif
	else
		if lExibeHelp
			MsgInfo(STR0033)	// "Falha na transmissão do registro. Consulte o log de transmissão."
		endif
	endif
	
Return lRetorno




Function VA0700043_LogTransmissao(cAlias,nReg,nOpc,lExibeHelp)

	local cOriKey := VV1->VV1_BBRFID

	OFIA262("@ VK5_ORITAB = 'VV1' AND VK5_ORIKEY = '" + cOriKey + "' ", "EQUIPMENT")

Return


Function VA0700053_ExcluirBlackbird(cAlias,nReg,nOpc,lExibeHelp)

	Local oEquip
	Local oEquipIntg
	Local oMessage
	//local oModel
	Local nRecVV1 := VV1->(Recno())

	//local cAlinha := ""

	Default lExibeHelp := .t.

	//Conout(cAlinha + " ")
	//Conout(cAlinha + "VA0700053_ExcluirBlackbird")
	//Conout(cAlinha + " ")

	if OA2610123_integraDynamics(.f.) == .f.
		return .t.
	endif

	if VV1->VV1_BBINTG <>"1"
		if lExibeHelp
			FMX_HELP("VA031ERR002",STR0034)	// "Registro não esta integrado com o Blackbird."
//			Conout(cAlinha + "VA0700053_ExcluirBlackbird - Registro nao esta integrado com o Blackbird.")
		endif
		Return .f.
	EndIf

	//Conout(cAlinha + "___  __             __          ___         __   __            __   ___       ___ ___  ___ ")
	//Conout(cAlinha + " |  |__)  /\  |\ | /__`  |\/| |  |  | |\ | |  \ /  \    __    |  \ |__  |    |__   |  |__  ")
	//Conout(cAlinha + " |  |  \ /~~\ | \| .__/  |  | |  |  | | \| |__/ \__/          |__/ |___ |___ |___  |  |___ ")
	//Conout(cAlinha + "                                                                                           ")
	//Conout(cAlinha + " ")

	CursorWait()

	oEquip := OFSoEquipment():New()
	oEquipIntg := oEquip:FindByRecnoDel( VV1->(recno()))

	oMessage := OFSoEquipmentRemovedInDbsMessage():New(oEquipIntg)

	FWMsgRun(, {|oSay| oMessage:Send() }, STR0030, STR0035 + VV1->VV1_BBRFID)	// "John Deere - Blackbird"		"Removendo Equip - "

	If oMessage:oSoRequest:GetHTTPResponse() == 200

		dbSelectArea("VV1")
		recLock("VV1",.F.,.T.)
		VV1->VV1_BBINTG := "0"
		VV1->VV1_BBSYNC := "0"
		VV1->VV1_BBDEL  := "1"
		VV1->VV1_BBDALT := FGX_Timestamp()
		msUnlock()

//		dbSelectArea("VV1")
//		recLock("VV1",.F.,.T.)
//		VV1->VV1_BBINTG := "0"
//		VV1->VV1_BBSYNC := "0"
//		VV1->VV1_BBDEL := "1"
//		msUnlock()
//		oModel := FWLoadModel("VEIA070")
//		oModel:setOperation(MODEL_OPERATION_UPDATE)
//
//		if ! oModel:Activate()
//			Return .f.
//		endif
//
//		oModel:SetValue("MODEL_VV1", "VV1_BBINTG", "0" )
//		oModel:SetValue("MODEL_VV1", "VV1_BBSYNC", "0" )
//		oModel:SetValue("MODEL_VV1", "VV1_BBDEL" , "1" )
//		oModel:SetValue("MODEL_VV1", "VV1_BBDALT", FGX_Timestamp() )
//
//		If oModel:VldData()
//			oModel:CommitData()
//		endif
//		oModel:DeActivate()

		// Verifica se existe algum registro de horimetro ah ser enviado ...
		VV1->(dbGoTo(nRecVV1))

		CursorArrow()
		IF lExibeHelp
			MsgInfo(STR0036)	// "Registro excluido."
		endif
	Else
		if lExibeHelp
			MsgInfo(STR0033)	// "Falha na transmissão do registro. Consulte o log de transmissão."
		endif
	EndIf

Return

/*/{Protheus.doc} VA0700063_PosVV1Chaint
	Posiciona VV1 por Chaint

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Function VA0700063_PosVV1Chaint(cChave)

	Local lRetorno := .f.

	VV1->(dbSetOrder(1)) // CHAINT
	lRetorno := VV1->(msSeek(xFilial("VV1") + cChave))

Return lRetorno 

/*/{Protheus.doc} VA0700073_PosVV1Chassi
	Posiciona VV1 por Chassi

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Function VA0700073_PosVV1Chassi(cChave)

	Local lRetorno := .f.

	VV1->(dbSetOrder(2)) // chassi
	lRetorno := VV1->(msSeek(xFilial("VV1") + cChave))

Return lRetorno 

/*/{Protheus.doc} VA0700073_PosVV1Chassi
	Posiciona VV1 por Chassi

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Function VA0700093_AtualizaVV1(oVV1AuxModel, aFldAtu)

	local nPosFld
	local lRetorno := .t.

	//Conout(" ")
	//Conout(" ")
	//Conout("---------------------")
	//Conout("VA0700093_AtualizaVV1")
	//Conout(" ")

	for nPosFld := 1 to Len(aFldAtu)
		//Conout(aFldAtu[nPosFld,1] + " -> [" + cValToChar(aFldAtu[nPosFld,2]) + "]")
		if ! oVV1AuxModel:SetValue( "MODEL_VV1", aFldAtu[nPosFld,1], aFldAtu[nPosFld,2] )
			FMX_SetValMostraErro(oVV1AuxModel)
			lRetorno := .f.
			Exit
		endif
	next nPosFld
	//Conout(" ")

Return lRetorno

/*/{Protheus.doc} VA0700103_InclusaoNovoChassi
	Abre uma tela para inclusao de um novo chassi com o chassi ja digitado e bloqueia a edicao do chassi

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Function VA0700103_InclusaoNovoChassi(cChassiDig)

	local oExec070

	local oModel070
	local oView070

	local aButtons
	
	local oStruVV1View

	CursorWait()
	oModel070:= FWLoadModel("VEIA070")
	oModel070:SetOperation(MODEL_OPERATION_INSERT)
	If ! oModel070:Activate()
		MostraErro()
		CursorArrow()
		Return .f.
	EndIf

	oAux := oModel070:getModel( "MODEL_VV1" ):getStruct()
	aAux := oAux:GetFields()


	oView070 := FWLoadView("VEIA070")
	oView070:SetModel(oModel070)
	oView070:SetOperation(MODEL_OPERATION_INSERT)

	oStruVV1View := oView070:GetViewStruct( 'VIEW_VV1' )
	oStruVV1View:SetProperty( 'VV1_CHASSI' , MVC_VIEW_CANCHANGE, .f.)

	oModel070:setValue("MODEL_VV1","VV1_CHASSI",cChassiDig)

	aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
					{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}				,;
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }


	oExec070 := FWViewExec():New()
	oExec070:setTitle(STR0037)	// "Inclusão de Veículos"
	oExec070:setView(oView070)
	oExec070:SetReduction(20)
	oExec070:setOperation(MODEL_OPERATION_INSERT)
	oExec070:SetButtons(aButtons)
	oExec070:openView(.f.)

	nButPress := oExec070:getButtonPress()

	lRetorno := (nButPress == 0)

	oExec070:DeActivate()

	
Return lRetorno

/*/{Protheus.doc} VA0700153_IncluirKMHorimetro
	Abre uma tela inclusao de uma nova KM/Horimetro para o veiculo posicionado

	@author Rubens Takahashi
	@since 05/07/2022
	@type function
/*/
Function VA0700153_IncluirKMHorimetro(cAlias,nReg,nOpc)

	local oExec073 

	local oModel073
	local oView073
	local lRetorno

	local aButtons
	
	Local oStruVO0 := FWFormStruct( 2, 'VO0' , { |cField| AllTrim(Upper(cField)) $ "VO0_KILOME/VO0_HORTRI/VO0_DATA/VO0_HORA/VO0_ORIGEM/VO0_MOTIVO/VO0_OBSERV" })

	Private cMotivo := "000026" // Varivel utilizada na consulta padrao de motivos (VS0)

	If Empty(VV1->VV1_CHASSI)
		FMX_HELP("SEMCHASSI",STR0038)	// "É necessário que o veiculo tenha chassi cadastrado para atualizar a kilometragem."
		Return .F.
	Endif

	CursorWait()
	oModel073:= FWLoadModel("VEIA073")
	oModel073:SetOperation(MODEL_OPERATION_INSERT)
	If ! oModel073:Activate()
		MostraErro()
		CursorArrow()
		Return .f.
	EndIf

	oView073 := FWFormView():New()
	oView073:SetModel( oModel073 )

	oView073:CreateHorizontalBox( 'TELA_VO0' , 100 )
	oView073:AddField('2VIEW_VO0', oStruVO0, 'MODEL_VO0' )
	oView073:SetOwnerView('2VIEW_VO0','TELA_VO0')

	oView073:SetOperation(MODEL_OPERATION_INSERT)

	oModel073:setValue("MODEL_VW0","VW0_CHASSI",VV1->VV1_CHASSI)

	aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
					{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}				,;
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }


	oExec073 := FWViewExec():New()
	oExec073:setTitle(STR0039)	// "Ajuste de KM/Horímetro"
	oExec073:setView(oView073)
	oExec073:SetReduction(20)
	oExec073:setOperation(MODEL_OPERATION_INSERT)
	oExec073:SetButtons(aButtons)
	oExec073:openView(.f.)

	nButPress := oExec073:getButtonPress()

	lRetorno := (nButPress == 0)

	oExec073:DeActivate()

Return lRetorno

/*/{Protheus.doc} VA0700113_AlteracaoChassi
	Abre uma tela para edição de um veiculo posicionado

	@author Rubens Takahashi
	@since 06/04/2022
	@type function
/*/
Function VA0700113_AlteracaoChassi()

	local oExec070
	local aButtons
	Local oViewGer := FWLoadView("VEIA070")
	Local oModGer := FWLoadModel("VEIA070")

	aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
					{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil}				,;
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }

	if cPaisLoc == "ARG" .and. VV1->VV1_SITVEI == "8" .and. VV1->VV1_INDCAL == "2"
		oModGer:GetModel("MODEL_VV1"):GetStruct():SetProperty("VV1_CHASSI" , MODEL_FIELD_WHEN, {|| .T.})
		oViewGer:GetViewStruct( 'MODEL_VV1' ):SetProperty( 'VV1_CHASSI' , MVC_VIEW_CANCHANGE, .t. )
	EndIf

	oExec070 := FWViewExec():New()
	oExec070:setTitle(STR0040)	// "Alteração de Veículos"
	oExec070:setView(oViewGer)
	oExec070:setModel(oModGer)
	oExec070:setSource("VEIA070")
	oExec070:SetReduction(20)
	oExec070:setOperation(MODEL_OPERATION_UPDATE)
	oExec070:SetButtons(aButtons)
	oExec070:openView(.T.)

Return

Function VA0700123_SendMeter(cChaInt)

	VA0730023_CheckLast(cChaInt)

Return

/*/{Protheus.doc} VA070013B_GravaFrota
	Chama MVC da rotina VEIA100, Gravação/Alteração de Frota de Clientes

	@author Alecsandre Ferreira
	@since 27/06/2022
	@type function
/*/
Function VA070013B_GravaFrota(oModel, nOpc)
	Local oModelVC3
	Local oModelVV1 := oModel:GetModel("MODEL_VV1")
	Local aFldVC3 := {}
	//Local lGravaFrota := SuperGetMv("MV_MIL0175",, .F.)
	Local lGravaFrota := .F.
	Local lRegVC3 := .F.
	Local lRetMVCAuto
	Local lChaInt
	Local nRecno := 0

	If lGravaFrota .AND. !Empty(oModelVV1:GetValue('VV1_PROATU')) .AND. !Empty(oModelVV1:GetValue('VV1_LJPATU'))

		oModelVC3 := FwLoadModel("VEIA100")

		DbSelectArea("VC3")
		lChaInt := FieldPos("VC3_CHAINT") > 0

		aadd(aFldVC3, {"VC3_CODCLI", oModelVV1:GetValue('VV1_PROATU')})
		aadd(aFldVC3, {"VC3_LOJA"  , oModelVV1:GetValue('VV1_LJPATU')})
		aadd(aFldVC3, {"VC3_CODMAR", oModelVV1:GetValue('VV1_CODMAR')})
		aadd(aFldVC3, {"VC3_MODVEI", oModelVV1:GetValue('VV1_MODVEI')})
		aadd(aFldVC3, {"VC3_CHASSI", oModelVV1:GetValue('VV1_CHASSI')})

		If lChaInt
			aadd(aFldVC3, {"VC3_CHAINT", oModelVV1:GetValue('VV1_CHAINT')})
		Endif

		aadd(aFldVC3, {"VC3_FABMOD", oModelVV1:GetValue('VV1_FABMOD')})
		aadd(aFldVC3, {"VC3_QTDFRO", 1  })
		aadd(aFldVC3, {"VC3_AQUNOS", "0"})
		aadd(aFldVC3, {"VC3_PROVEI", oModelVV1:GetValue('VV1_PROVEI')}) 
		aadd(aFldVC3, {"VC3_TIPO"  , IIf(oModelVV1:GetValue('VV1_GRASEV') <> "6", "1", "0")}) // 1=Veiculo/Maquina / 0=Equipamento/AMS / 2=Outros 

		// Tratativa para erro 'variable aRotina doesn't exists'
		If Type("aRotina") == "U"
			aRotina := {}
		endif

		If nOpc == 4
			nRecno := FGX_VV1VC3(oModelVV1:GetValue('VV1_CHAINT'), oModelVV1:GetValue('VV1_CHASSI'))

			If nRecno > 0
				DbSelectArea("VC3")
				VC3->(DbGoTo(nRecno))
				lRegVC3 := .T.

				If VA070014B_AlteraTabela(aFldVC3, "VC3") 
					Return
				Endif
			Endif
		Endif

		lRetMVCAuto := FwMvcRotAuto(oModelVC3, "VC3", If(lRegVC3, 4, 3), {{'MASTER', aFldVC3}}, .F., .F.) 
		
		If !lRetMVCAuto
			MostraErro()
		endif

		oModelVC3:DeActivate()

	Endif
Return

/*/{Protheus.doc} VA070014B_AlteraTabela
	Valida a necessidade da execução de operação de alteração de um registro,
	de acordo com a tabela informada. Necessário estar posicionado no registro.

	@author Alecsandre Ferreira
	@since 30/06/2022
	@type function
	@param aFields - campos a comparar com os valores, cTabela - Alias da tabela
	@return logical
/*/
Function VA070014B_AlteraTabela(aFields, cAliasTab)
	local nLinFields

	For nLinFields := 1 to len(aFields)
		If AllTrim(aFields[nLinFields, 2]) == AllTrim(&(cAliasTab + '->' + aFields[nLinFields, 1]))
		Else
			//Conout(aFields[nLinFields, 1] + " - " + AllTrim(&(cAliasTab + '->' + aFields[nLinFields, 1]) + "->" + AllTrim(aFields[nLinFields, 2]))) 
			Return .F.
		Endif
	Next nLinFields

Return .T.


Function VA0700163_AdjustOptions(cChaInt)
	Local cQuery
	Local cAlVQE := "TMP_VQE"
	Local oModelVQE := FWLoadModel("VEIA246")

	dbSelectArea("VQE")

	cQuery := "SELECT R_E_C_N_O_ VQERECNO " +;
		" FROM " + RetSQLName("VQE") + " VQE " +;
		" WHERE VQE.VQE_FILIAL = '" + FWxFilial("VQE") + "' " +;
		  " AND VQE.VQE_CHAINT = '" + cChaInt + "' " +;
		  " AND VQE.VQE_BBSYNC = '0'" +; // Processa todos os registros que nao estao sincronizados
		  " AND VQE.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAlVQE, .F., .T. )
	While !(cAlVQE)->(Eof())
		VQE->(dbGoTo( (cAlVQE)->VQERECNO ))
		
		oModelVQE:setOperation(MODEL_OPERATION_UPDATE)
		if ! oModelVQE:Activate()
	//		Return .f.
		endif

		oModelVQE:SetValue("MODEL_VQE", "VQE_BBINTG", "1" )
		oModelVQE:SetValue("MODEL_VQE", "VQE_BBSYNC", "1" )
		if empty(oModelVQE:GetValue("MODEL_VQE","VQE_BBDINC"))
			oModelVQE:SetValue("MODEL_VQE", "VQE_BBDINC", FGX_Timestamp() )
		endif
		oModelVQE:SetValue("MODEL_VQE", "VQE_BBDALT", FGX_Timestamp() )

		If oModelVQE:VldData()
			oModelVQE:CommitData()
		endif
		oModelVQE:DeActivate()

		(cAlVQE)->(dbSkip())
	End

	(cAlVQE)->(dbCloseArea())
Return


/*/{Protheus.doc} VA0700183_PendenciaBlackbird
Verifica se existe alguma pendencia para integração com o Blackbird 

@author Rubens Takahashi
@since 06/12/2023
@version 1.0
@type function
/*/
Function VA0700183_PendenciaBlackbird(cChaInt,aPendencia, oAuxMod070, aAuxStru)
	
	local nX, aErro, cCpoVazio
	local cSQL
	local aArea := getArea()
	local aAreaVQ0 := VQ0->( getArea() )
	local nRecnoAux
	local cVK7REFID := ""
	Default oAuxMod070 := FWLoadModel("VEIA070")
	Default aAuxStru := oAuxMod070:getModel("MODEL_VV1"):getStruct():getFields()

	VV1->(dbSetOrder(1))
	if ! VV1->(msSeek(xFilial("VV1") + cChaInt))
		return .f.
	endif

	aPendencia := {}

	if VV1->VV1_SITVEI == "8" // Pedido
		if VV1->VV1_BBINST == "3"
			aadd(aPendencia, {"SMO_009","Chassi com Situação igual a 8=Pedido e status inventário igual a 3=Loaner." })	// STR0049 "Chassi com Situação igual a 8=Pedido e status inventário igual a 3=Loaner."
		endif

		cQuery := "select R_E_C_N_O_ RECVQ0 "
		cQuery += " from " + RetSQLName("VQ0")
		cQuery += " where VQ0_FILIAL = '" + xFilial("VQ0") + "'"
		cQuery += " and VQ0_CHASSI = '" + VV1->VV1_CHASSI + "'"
		cQuery += " and VQ0_STATUS <> '3'"	// 1=Confirmado;2=Faturado;3=Cancelado
		cQuery += " and D_E_L_E_T_  = ' '"
		nRecnoAux := FM_SQL( cQuery )

		if nRecnoAux == 0
			aadd(aPendencia, {"SMO_001",STR0041})	// "Chassi com Situação igual a 8=Pedido e sem pedido de compra (VQ0)."
		else
			VQ0->( dbGoto( nRecnoAux ) )

			if empty( VQ0->VQ0_NUMPED )
				aadd(aPendencia, {"SMO_016",STR0041 })	// "Chassi com Situação igual a 8=Pedido e sem pedido de compra (VQ0)."
			endif
			if empty( VQ0->VQ0_FILENT )
				aadd(aPendencia, {"SMO_017","Chassi com Situação igual a 8=Pedido de compra sem filial entrada (VQ0)." })	// STR0050 "Chassi com Situação igual a 8=Pedido de compra sem filial entrada (VQ0)."
			endif

			if VV1->VV1_BBINST == "1"	// Sold
				cQuery := "select VJR_RTLDAT"
				cQuery += " from " + RetSQLName("VQ0") + " VQ0"
				cQuery += " left join " + RetSQLName("VJR") + " VJR"
				cQuery += " on  VJR_FILIAL = VQ0_FILIAL"
				cQuery += " and VJR_CODVQ0 = VQ0_CODIGO"
				cQuery += " and VJR.D_E_L_E_T_  = ' '"
				cQuery += " where VQ0_FILIAL = '" + xFilial("VQ0") + "'" 
				cQuery += " and VQ0_CHASSI = '" + VV1->VV1_CHASSI + "'"
				cQuery += " and VQ0_STATUS <> '3' "
				cQuery += " and VQ0.D_E_L_E_T_  = ' ' "
				if empty( FM_SQL( cQuery ) )
					aadd(aPendencia, {"SMO_009","Equipamento vendido sem date market VJR_RTLDAT." })	// STR0054 "Equipamento vendido sem date market VJR_RTLDAT."
				endif
			endif
		endif

		VQ0->( restArea( aAreaVQ0 ) )
	endif

	if VV1->VV1_SITVEI <> "8" .and. empty(VV1->VV1_BBEQTY)
		if empty(VV1->VV1_PROATU)
			aadd(aPendencia, {"SMO_002",STR0042})	// "O equipamento sem Situação e sem Proprietário Atual."
		else
			if oSoConfig == NIL
				oSoConfig := OFSOConfig():New()
			endif

			// Verifica se o prorietario atual é a propria concessionaria 
			if oSoConfig:ClienteFilialHabilitada(VV1->VV1_PROATU, VV1->VV1_LJPATU)
				aadd(aPendencia, {"SMO_003",STR0043})	// "Equipamento pertencente ao concessionário e sem movimentação."
			endif
		endif
	endif

	if ! empty(VV1->VV1_PROATU)
		if SA1->A1_COD <> VV1->VV1_PROATU .or. SA1->A1_LOJA <> VV1->VV1_LJPATU
			cSQL := "SELECT COUNT(*) FROM " + retSQLName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = '" + VV1->VV1_PROATU + "' AND A1_LOJA = '" + VV1->VV1_LJPATU + "' AND D_E_L_E_T_ = ' '"
			if FM_SQL(cSQL) <= 0
				aadd(aPendencia, {"SMO_004",STR0044 + VV1->VV1_PROATU + "-" + VV1->VV1_LJPATU + ")."})	// "Proprietário atual não cadastrado no cadastro de clientes ("
			endif
		endif

		cSQL := "SELECT VK7_REFID FROM " + retSQLName("VK7") + " WHERE VK7_FILIAL = '" + xFilial("VK7") + "' AND VK7_A1COD = '" + VV1->VV1_PROATU + "' AND VK7_A1LOJA = '" + VV1->VV1_LJPATU + "' AND D_E_L_E_T_ = ' '"
		cVK7REFID := FM_SQL(cSQL)
		if empty( cVK7REFID )
			aadd(aPendencia, {"SMO_004","Proprietário atual não integrado (" + VV1->VV1_PROATU + "-" + VV1->VV1_LJPATU + ")."})	// "Proprietário atual não cadastrado no cadastro de clientes ("
		endif
	endif

	VE1->(dbSetOrder(1))
	if ! VE1->(msSeek(xFilial("VE1") + vv1->VV1_CODMAR))
		aadd(aPendencia, {"SMO_007","Marca não encontrada no cadastro de marca " + "(" + VV1->VV1_CODMAR + ")" })	// "Marca não encontrada no cadastro de marca."
	endif

	VV2->(dbSetOrder(1))
	if ! VV2->(msSeek(xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_SEGMOD))
		aadd(aPendencia, {"SMO_008","Modelo não encontrado no cadastro de modelo " + "([" + VV1->VV1_CODMAR + "]-[" + VV1->VV1_MODVEI + IIf( !Empty(VV1->VV1_SEGMOD) , "]-[" + VV1->VV1_SEGMOD, "" ) + "])"})	// "Modelo não encontrado no cadastro de modelo"
	endif

	if VV1->VV1_SITVEI <> "8"
		oAuxMod070:SetOperation( MODEL_OPERATION_UPDATE )
		if oAuxMod070:Activate()
			if ! oAuxMod070:getModel("MODEL_VV1"):VldData()
				
				aErro := oAuxMod070:GetErrorMessage()
				
				if aErro[5] == "OBRIGAT"
					cCpoVazio := ""
					For nX := 1 To Len(aAuxStru)
						If aAuxStru[nX][MODEL_FIELD_OBRIGAT] .and. empty(oAuxMod070:getValue("MODEL_VV1", aAuxStru[nX][MODEL_FIELD_IDFIELD]))
							cCpoVazio += aAuxStru[nX][MODEL_FIELD_IDFIELD] + ", "
						EndIf
					next nX
					cCpoVazio := Left(cCpoVazio, Len(cCpoVazio) - 2)
				 
					aadd(aPendencia, {"SMO_005",STR0045 + cCpoVazio})	// "Campos obrigatórios sem conteúdo preenchido. Campos: "
				else
					aadd(aPendencia, {"SMO_006",STR0046 + AllToChar(aErro[4]) + " - " + AllToChar(aErro[5]) + " - " + AllToChar(aErro[7])})	// "Erro de validação na Model do Equipamento(VEIA070). Detalhe: "
				endif
			endif
		endif
		oAuxMod070:DeActivate()
	endif

	if VV1->VV1_BBEQTY == "1"		// CustomerEquipment
		if empty( VV1->VV1_PROATU )
			aadd(aPendencia, {"SMO_010","Equipamento de cliente VV1_BBEQTY=1 sem cliente cadastrado." })	// STR0051 "Equipamento de cliente VV1_BBEQTY=1 sem cliente cadastrado."
		endif
		if VV1->VV1_BBINST == "2"	// "Stock"
			aadd(aPendencia, {"SMO_011","Equipamento de cliente VV1_BBEQTY=1 em estoque VV1_BBINST=2." })	// STR0052 "Equipamento de cliente VV1_BBEQTY=1 em estoque VV1_BBINST=2."
		endif

	elseif VV1->VV1_BBEQTY == "2"	// StockUnit
		if empty( VV1->VV1_LOCRID )
			aadd(aPendencia, {"SMO_012","Equipamento de estoque sem filial VV1_LOCRID." })	// STR0055 "Equipamento de estoque sem filial VV1_LOCRID."
		endif
	endif

	if VV1->VV1_BBINST == "1"	// Sold
		if empty( VV1->VV1_SOLCID )
			aadd(aPendencia, {"SMO_013","Equipamento vendido sem SoldBy VV1_SOLCID." })	// STR0053 "Equipamento vendido sem SoldBy VV1_SOLCID."
		endif
	endif

	if VV1->VV1_BBINST == "4"	// Hold
		if empty( VV1->VV1_DTHRES ) .or. empty( VV1->VV1_DTHVAL )
			aadd(aPendencia, {"SMO_014","Equipamento sem data/hora da reserva VV1_DTHRES / VV1_DTHVAL." })	// STR0056 "Equipamento sem data/hora da reserva VV1_DTHRES / VV1_DTHVAL."
		endif

		cQuery := "select 1"
		cQuery += " from " + retSqlName( "VVA" ) + " VVA"
		cQuery += " join " + retSqlName( "VV9" ) + " VV9 on VV9_FILIAL = VVA_FILIAL and VV9_NUMATE = VVA_NUMTRA and VV9.D_E_L_E_T_ = ' '"
		cQuery += " left join " + retSqlName( "SA3" ) + " SA3 on A3_FILIAL = '" + xFilial("SA3") + "' and A3_COD = VV9_VEND1 and SA3.D_E_L_E_T_ = ' '"
		cQuery += " where VVA_FILIAL = '" + xFilial("VVA") + "'"
		cQuery += " and VVA_CHAINT = '" + VV1->VV1_CHAINT + "'"
		cQuery += " and VVA.D_E_L_E_T_ = ' '"
		cQuery += " order by VVA.R_E_C_N_O_ desc"
		if empty( FM_SQL( cQuery ) )
			aadd(aPendencia, {"SMO_015","Equipamento reservado sem dados do atendimento." })	// STR0057 "Equipamento reservado sem dados do atendimento."
		endif
	endif

// tratativa para resolver pendencias na tabela VQL, preenchendo o campo VQL_DATAF
	cCodPend := ""
	aEval( aPendencia, {|it| cCodPend += iif( ! empty(cCodPend), ",", "" ) + "'" + it[1] + "'" } )

	cQuery := "update " + retSqlName("VQL")
	cQuery += 	" set VQL_DATAF='" + DtoS(dDatabase) + "'"
	cQuery += 	", VQL_HORAF=" + strTran( left( time(), 5 ), ":", "" )
	cQuery += " where VQL_FILIAL='" + xFilial("VQL") + "'"
	cQuery += " and VQL_CODVQL='" + VV1->VV1_CHAINT + "'"
	cQuery += " and VQL_AGROUP='VA070-SMO-EQ'"
	cQuery += " and VQL_DATAF=' '"
	if ! empty( cCodPend )
		cQuery += " and VQL_TIPO not in (" + cCodPend + ")"
	endif
	cQuery += " and D_E_L_E_T_ = ' '"
	TCSqlExec( cQuery )

	restArea( aArea )
Return len(aPendencia) > 0

/*/{Protheus.doc} VA0700193_RegistraPendenciaBlackbird
Registra pendencia de integração na VQL e marca o veiculo como pendente de integração com o Blackbird

@author Rubens Takahashi
@since 06/12/2023
@version 1.0
@type function
/*/
Function VA0700193_RegistraPendenciaBlackbird( cChaInt, aPendencia, lLimpa )
local   nPosPendencia
default lLimpa := .F.

	if VV1->VV1_CHAINT <> cChaint
		VV1->(dbSetOrder(1))
		VV1->(msSeek(xFilial("VV1") + cChaInt))
	endif

	if lLimpa
		TCSqlExec("DELETE FROM " + RetSQLName("VQL") +;
			" WHERE VQL_FILIAL = '" + xFilial("VQL") + "'" +;
				" AND VQL_AGROUP = 'VA070-SMO-EQ'" +;
				" AND VQL_FILORI = '" + xFilial("VV1") + "' " +;
				" AND VQL_CODVQL = '" + cChaInt + "'")
	endif

	if oLogVEIA070 == NIL
		oLogVEIA070 := DMS_Logger():New()
	endif

	for nPosPendencia := 1 to len(aPendencia)
		oLogVEIA070:LogToTable({;
			{'VQL_AGROUP'     , 'VA070-SMO-EQ'},;
			{'VQL_TIPO'       , aPendencia[nPosPendencia,1] },;
			{'VQL_FILORI'     , xFilial("VV1") },;
			{'VQL_CODVQL'     , cChaInt },;
			{'VQL_DADOS'      , aPendencia[nPosPendencia,2] } ;
		}, .T. )
	next 

	if VV1->VV1_BBPEND <> "1"
		reclock("VV1",.f.)
		VV1->VV1_BBPEND := "1"
		VV1->(MSUnlock())
	endif

return nil

/*/{Protheus.doc} VA07000203_LimpaPendeniaBlackbird
Limpa pendecia do chassis informado

@author Rubens Takahashi
@since 06/12/2023
@version 1.0
@type function
/*/
Function VA07000203_LimpaPendeniaBlackbird(cChaint)
	if VV1->VV1_BBPEND == "1"
		reclock("VV1",.f.)
		VV1->VV1_BBPEND := "0"
		VV1->(MSUnlock())
	endif
Return


Function VA0700173_LogVW0(cPRotOrigem, cPFilUltMov, cPUltMov , aDtHrMov ,_ULTMOV_, _ESTVEI_, _SITVEI_, _PROATU_, _LJPATU_ )

	local aFldVW0 := {}
	local aFldVK9 := {}
	local lRetMVCAuto

	local nRecVV1 := VV1->(RecNo())

	default cPFilUltMov := ""
	default cPUltMov := ""
	default aDtHrMov := {} // usar somente no Initial Data Load

	default _ULTMOV_ := VV1->VV1_ULTMOV
	default _ESTVEI_ := VV1->VV1_ESTVEI
	default _SITVEI_ := VV1->VV1_SITVEI
	default _PROATU_ := VV1->VV1_PROATU
	default _LJPATU_ := VV1->VV1_LJPATU

	if ! FwAliasInDic("VK9") .or. ! FwAliasInDic("VW0")
		return nil
	endif

	if cPRotOrigem <> "VX0020073_ReservaBlackBird" .and. cPRotOrigem <> "VX0020083_CancelaReservaBlackBird" .and. cPRotOrigem <> "IMPLANTACAO_RESERVA"
		aFldVW0 := {;
			{"VW0_CHASSI" , VV1->VV1_CHASSI , NIL },;
			{"VW0_ULTMOV" , _ULTMOV_ , NIL },;
			{"VW0_ESTVEI" , _ESTVEI_ , NIL },;
			{"VW0_SITVEI" , _SITVEI_ , NIL },;
			{"VW0_FILPRO" , xFilial("SA1")  , NIL },;
			{"VW0_PROATU" , _PROATU_ , NIL },;
			{"VW0_LJPATU" , _LJPATU_ , NIL },;
			{"VW0_BBINTG" , iif( VV1->( fieldPos("VV1_BBINTG") ) > 0, VV1->VV1_BBINTG, "" ) , NIL },;
			{"VW0_ROTINA" , cPRotOrigem , NIL };
		}

		if ! empty(cPUltMov)
		
			do case 
			case _ULTMOV_ == "E"
				AADD( aFldVW0 , {"VW0_FILENT" , iif( empty(cPUltMov) , " " , cPFilUltMov) , NIL } )
				AADD( aFldVW0 , {"VW0_TRACPA" , cPUltMov , NIL })
				AADD( aFldVW0 , {"VW0_STENT" , "1" , NIL })

			case _ULTMOV_ == "S"
				AADD( aFldVW0 , {"VW0_FILSAI" , cPFilUltMov , NIL })
				AADD( aFldVW0 , {"VW0_NUMTRA" , cPUltMov , NIL })
				AADD( aFldVW0 , {"VW0_STSAI" , "1" , NIL })

			endcase

		endif

		if len(aDtHrMov) <> 0
			AADD( aFldVW0 , {"VW0_DATREG" , aDtHrMov[1] , NIL })
			AADD( aFldVW0 , {"VW0_HORREG" , aDtHrMov[2] , NIL })
		endif

		If IsBlind()
			AADD( aFldVW0 , {"VW0_USERID" , "000000" , NIL})
		EndIf

	endif

	if OA2610123_integraDynamics(.t., cFilAnt)

		aFldVK9 := {;
			{"VK9_CHASSI",VV1->VV1_CHASSI , NIL },;
			{"VK9_BBINTG",IIF(cPRotOrigem == "IMPLANTACAO" .or. cPRotOrigem == "IMPLANTACAO_RESERVA" , "0" , VV1->VV1_BBINTG)  , NIL },;
			{"VK9_BBEQTY",VV1->VV1_BBEQTY , NIL },;
			{"VK9_BBSTTY",VV1->VV1_BBSTTY , NIL },;
			{"VK9_BBINST",VV1->VV1_BBINST , NIL },;
			{"VK9_BBSTST",VV1->VV1_BBSTST , NIL },;
			{"VK9_BBYARD",VV1->VV1_BBYARD , NIL },;
			{"VK9_LOCRID",VV1->VV1_LOCRID , NIL },;
			{"VK9_SOLCID",VV1->VV1_SOLCID , NIL } ;
		}

		if IsBlind()
			AADD( aFldVK9 , {"VK9_USERID" , "000000" , NIL})
		endif

		if ! empty(cPUltMov) .AND. (alltrim(cPRotOrigem) == "VX0020073_ReservaBlackBird" .OR. alltrim(cPRotOrigem) == "IMPLANTACAO_RESERVA")
			AADD( aFldVK9 , {"VK9_FILATE" , cPFilUltMov , NIL })
			AADD( aFldVK9 , {"VK9_NUMATE" , cPUltMov , NIL })
			AADD( aFldVK9 , {"VK9_OPER" , "1" , NIL })
		endif

		if alltrim(cPRotOrigem) == "VX0020083_CancelaReservaBlackBird" .and. ! empty(cPUltMov)
			AADD( aFldVK9 , {"VK9_FILATE" , cPFilUltMov , NIL })
			AADD( aFldVK9 , {"VK9_NUMATE" , cPUltMov , NIL })
			AADD( aFldVK9 , {"VK9_OPER" , "2" , NIL })
		endif

		if len(aDtHrMov) <> 0
			AADD( aFldVK9 , {"VK9_DATREG" , aDtHrMov[1] , NIL })
			AADD( aFldVK9 , {"VK9_HORREG" , aDtHrMov[2] , NIL })
		endif

	endif

	// Mesmo passando .f. no 6 parametro, a FWMvcRotAouto estava retornando erro "variable does not exist AROTINA on FWMVCROTAUTO"
	if type("aRotina") == "U"
		aRotina := {}
	endif
	//

	if len(aFldVK9) == 0 .and. len(aFldVW0) == 0
		return
	endif
	
	if len(aFldVK9) == 0
		if oVW0_VEIA071 == NIL
			oVW0_VEIA071 := FWLoadModel("VEIA071")
		endif

		lRetMVCAuto := FwMvcRotAuto(oVW0_VEIA071,;
			"VW0",;
			3 ,;
			{ { "MODEL_VW0", aFldVW0 } },;
			/*lSeek*/ .f. ,.f.)
			
		oVW0_VEIA071:DeActivate()
	else
		if oVW0_VEIA072 == NIL
			oVW0_VEIA072 := FWLoadModel("VEIA072")
		endif
		if len(aFldVW0) == 0
			lRetMVCAuto := FwMvcRotAuto(oVW0_VEIA072,;
				"VW0",;
				3 ,;
				{ { "MODEL_VK9", aFldVK9 } },;
				/*lSeek*/ .f. ,.f.)
		else
			lRetMVCAuto := FwMvcRotAuto(oVW0_VEIA072,;
				"VW0",;
				3 ,;
				{ { "MODEL_VW0" , aFldVW0 } , {"MODEL_VK9", aFldVK9 } },;
				/*lSeek*/ .f. ,.f.)
		endif
		oVW0_VEIA072:DeActivate()
	endif

	if ! lRetMVCAuto .AND. cPRotOrigem <> "IMPLANTACAO" .and. cPRotOrigem <> "IMPLANTACAO_RESERVA"
		if ! IsBlind()
			MostraErro()
		else
			conout(MostraErro("/dirdoc", "error.log"))
		endif
	endif

	if VV1->(RecNo()) <> nRecVV1
		VV1->(dbGoTo(nRecVV1))
	endif

Return


/*/{Protheus.doc} VA070022C_Replicar
Estrutura do Grid
@type function
@version 1.0
@author cristiamRossi
@since 1/8/2024
@return object, Estrutura de campos p/ Grid
/*/
function VA070022C_Replicar()
	local oRetorno  := OFDMSStruct():New()

	oRetorno:AddFieldDictionary( "VV1" , "VV1_CHASSI" , { { 'cIdField' , 'CHASSI' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } , { 'bValid' , FWBuildFeature( STRUCT_FEATURE_VALID , 'Vazio() .or. VA070023C_Valid_Chassi(FWFldGet("CHASSI"))' ) } } )

	if VA070027H_ValidaX3Nivel("VV1_PLAVEI")
		oRetorno:AddFieldDictionary( "VV1" , "VV1_PLAVEI" , { { 'cIdField' , 'PLAVEI' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } } )
	Endif

	if VA070027H_ValidaX3Nivel("VV1_RENAVA")
		oRetorno:AddFieldDictionary( "VV1" , "VV1_RENAVA" , { { 'cIdField' , 'RENAVA' } , { 'lVirtual', .t. } , { 'lCanChange' , .t. } } )
	Endif

return oRetorno


/*/{Protheus.doc} VA070023C_Valid_Chassi
Validação se o chassi está em duplicidade
@type function
@version 1.0
@author cristiamRossi
@since 1/8/2024
@param cChassi, character, número do chassi para verificação
@return logical, se o chassi está Ok (.T.) ou em duplicidade (.F.)
/*/
function VA070023C_Valid_Chassi( cChassi )
local lRet   := .T.
local oModelVV1 := fwModelActive()
local oModelRep := oModelVV1:getModel("REPLICAR")
local nI
local aLinhas   := FWSaveRows()
local aArea     := getArea()
local cAlias    := getNextAlias()

	if cChassi == FWFldGet("VV1_CHASSI")
		FMX_HELP( "VA0070ERR023A", STR0047, STR0048 )	// "Chassi já informado."		"Informe outro Chassi"
		lRet := .F.
		return lRet
	else
		beginSQL alias cAlias
			select VV1_CHAINT
			from %table:VV1% VV1
			where VV1_FILIAL <> 'ZZ'
			and   VV1_CHASSI = %exp:cChassi%
			and   VV1.%notdel%
		endSQL

		lRet := (cAlias)->( eof() )
		(cAlias)->( dbCloseArea())
		restArea( aArea )
		if ! lRet
			FMX_HELP( "VA0070ERR023B", STR0047, STR0048 )	// "Chassi já informado."		"Informe outro Chassi"
			return lRet
		endif
	endif

	for nI := 1 to oModelRep:Length()
		oModelRep:goLine(nI)
//		if ! oModelRep:isDeleted() .and. aLinhas[1,2] != nI
		if aLinhas[1,2] != nI
			if cChassi == oModelRep:getValue("CHASSI")
				FMX_HELP( "VA0070ERR023C", STR0047, STR0048 )	// "Chassi já informado."		"Informe outro Chassi"
				lRet := .F.
				exit
			endif
		endif
	next

	FWRestRows( aLinhas )
return lRet


/*/{Protheus.doc} VA070024C_InclusaoReplica
Rotina auxiliar para Copiar (replica) de Veículos, usando o GRID da view VEIA070A.prw
@type function
@version 1.0
@author cristiamRossi
@since 1/8/2024
@param cChassi, character, Número do Chassi
@param cPlaca, character, Placa do Veículo
@param cRenavam, character, Número Renavam
@return logical, Sucesso ou fracasso na inclusão
/*/
Function VA070024C_InclusaoReplica( cChassi, cPlaca, cRenavam )
local   oModel070  := FWLoadModel("VEIA070")
local   lRet       := .T.
local   nI
local   aCpoPossiv := FWFormStruct(3,"VV1")
default cChassi    := ""
default cPlaca     := ""
default cRenavam   := ""

	cursorWait()
	oModel070:SetOperation( MODEL_OPERATION_INSERT )
	if ! oModel070:Activate()
		MostraErro()
		CursorArrow()
		return .F.
	endif

	for nI := 1 to len(aCpoPossiv[1])
		if ! aCpoPossiv[ 1, nI, 14 ] .and. aScan(aNoCopy, alltrim( aCpoPossiv[1,nI,3] ) ) == 0
			oModel070:loadValue( "MODEL_VV1", aCpoPossiv[1,nI,3], VV1->( fieldGet( fieldPos( aCpoPossiv[1,nI,3] ) ) ) )
		endif
	next

	oModel070:setValue( "MODEL_VV1", "VV1_CHASSI", cChassi )
	oModel070:setValue( "MODEL_VV1", "VV1_PLAVEI", cPlaca )
	oModel070:setValue( "MODEL_VV1", "VV1_RENAVA", cRenavam )

	if ( lRet := oModel070:VldData() )
		lRet := oModel070:CommitData()
	else
		aErro := oModel070:GetErrorMessage()
		oErro := JsonObject():New()
		oErro["form_id"] :=  cValToChar(aErro[01])
		oErro["field_id"] :=  cValToChar(aErro[02])
		oErro["form_error_id"] :=  cValToChar(aErro[03])
		oErro["field_error_id"] :=  cValToChar(aErro[04])
		oErro["error_id"] :=  cValToChar(aErro[05])
		oErro["error_message"] :=  cValToChar(aErro[06])
		oErro["solution_message"] :=  cValToChar(aErro[07])
		oErro["value_to"] :=  cValToChar(aErro[08])
		oErro["before_from"] :=  cValToChar(aErro[09])
		cErro := oErro:toJson()
	endif

	oModel070:DeActivate()
	CursorArrow()	
Return lRet

/*/{Protheus.doc} VA0700251_Avaliacoes
Lista as Avaliações do Veiculo - USADO

@author Andre Luis Almeida
@since 16/10/2024
@version 1.0
@type function
/*/
Function VA0700251_Avaliacoes()
	VEIVA610(,VV1->VV1_CHASSI)
Return

/*/{Protheus.doc} VA070027H_ValidaX3Nivel
Função para validar o nivel dos campos com o nivel do usuário

@author João Victor Silva
@since 29/05/2025
@version 1.0
@type Function
/*/

Function VA070027H_ValidaX3Nivel(cCampo)

	Local lRet := .f. 
	Default cCampo := ""

	If GetSX3Cache(cCampo, "X3_NIVEL") <= cNivel
		lRet := .t.
	Endif

Return lRet