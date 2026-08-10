#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA028.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA028
Cadastro de Naturezas de Rendimentos,
para atender o EFD-REINF, na familia de eventos 4000.

@author		Vinicius do Prado
@since		21/02/2019
@version	1
@return		NIL
/*/
//-------------------------------------------------------------------

Function FINA028()

	Local oBrowse As Object

	If AliasInDic("FKX") .and. cPaisLoc=="BRA"
		DbSelectArea("FKX")
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('FKX')
		oBrowse:SetDescription(STR0001) //'Natureza de Rendimento'

		oBrowse:Activate()
	Else
		Help( , , "FINA028", , STR0006, 1, 0, , , , , , { STR0007 } )	// STR0006 "Atenção! Tabela Natureza de Rendimento(FKX) não existe." STR0007 "Atualizar o Dicionario de Dados."
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu de acordo com o array aRotina

@author		Vinicius do Prado
@since		21/02/2019
@version	1
@return		aRotina - Array contendo as opções de menu
/*/
//-------------------------------------------------------------------

Static Function MenuDef() As Array 

	Local aRotina As Array

	aRotina := {}

	ADD OPTION aRotina Title STR0002	Action 'VIEWDEF.FINA028' OPERATION 2 ACCESS 0	//'Visualizar'
	ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.FINA028' OPERATION 3 ACCESS 0	//'Incluir'
	ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.FINA028' OPERATION 4 ACCESS 0	//'Alterar'
	ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.FINA028' OPERATION 5 ACCESS 0	//'Excluir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela montagem do modelo de dados

@author		Vinicius do Prado
@since		21/02/2019
@version	1
@return		oModel - objeto do modelo de dados
/*/
//-------------------------------------------------------------------

Static Function ModelDef() As Object

	Local oStruFKX	As Object
	Local oStruFKZD	As Object
	Local oStruFKZI	As Object
	Local oModel	As Object
	Local aRltDed	As Array
	Local aRltIse	As Array
	Local aAux		As Array

	oStruFKX	:= FWFormStruct( 1, 'FKX' )
	oStruFKZD	:= FWFormStruct( 1, 'FKZ' )
	oStruFKZI	:= FWFormStruct( 1, 'FKZ' )
	aRltDed		:= {}
	aRltIse		:= {}
	aAux		:= {}

	oStruFKZD:AddField(	AllTrim(STR0009),;									// [01] C Titulo do campo //'Descrição'
						AllTrim(STR0009),;									// [02] C ToolTip do campo //'Descrição'
						'FKZ_DESCRD',;										// [03] C identificador (ID) do Field
						'C',;												// [04] C Tipo do campo
						240,;												// [05] N Tamanho do campo
						0,;													// [06] N Decimal do campo
						,;													// [07] B Code-block de validação do campo
						NIL,;												// [08] B Code-block de validação When do campo
						{},;												// [09] A Lista de valores permitido do campo
						NIL,;												// [10] L Indica se o campo tem preenchimento obrigatório
						,;													// [11] B Code-block de inicializacao do campo
						NIL,;												// [12] L Indica se trata de um campo chave
						NIL,;												// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )												// [14] L Indica se o campo é virtual

	oStruFKZI:AddField(	AllTrim(STR0009),;									// [01] C Titulo do campo //'Descrição'
						AllTrim(STR0009),;									// [02] C ToolTip do campo //'Descrição'
						'FKZ_DESCRI',;										// [03] C identificador (ID) do Field
						'C',;												// [04] C Tipo do campo
						240,;												// [05] N Tamanho do campo
						0,;													// [06] N Decimal do campo
						,;													// [07] B Code-block de validação do campo
						NIL,;												// [08] B Code-block de validação When do campo
						{},;												// [09] A Lista de valores permitido do campo
						NIL,;												// [10] L Indica se o campo tem preenchimento obrigatório
						,;	// [11] B Code-block de inicializacao do campo
						NIL,;												// [12] L Indica se trata de um campo chave
						NIL,;												// [13] L Indica se o campo pode receber valor em uma operação de update.
						.T. )												// [14] L Indica se o campo é virtual

	oStruFKZD:SetProperty( 'FKZ_DESCRD', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'F028Des("D")' ) )
	oStruFKZI:SetProperty( 'FKZ_DESCRI', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, 'F028Des("I")' ) )
	oStruFKZD:SetProperty( 'FKZ_CODIGO', MODEL_FIELD_OBRIGAT, .F.)
	oStruFKZI:SetProperty( 'FKZ_CODIGO', MODEL_FIELD_OBRIGAT, .F.)
	oStruFKZD:SetProperty( 'FKZ_ISENCA', MODEL_FIELD_OBRIGAT, .F.)
	oStruFKZI:SetProperty( 'FKZ_DEDUCA', MODEL_FIELD_OBRIGAT, .F.)

	oStruFKZD:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_OBRIGAT, .F.)
	oStruFKZI:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_OBRIGAT, .F.)

	oStruFKZD:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_INIT, { || "1" } )
	oStruFKZD:SetProperty( 'FKZ_ISENCA', MODEL_FIELD_INIT, { || "  " } )
	oStruFKZD:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_WHEN, { || .F. } )

	oStruFKZI:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_INIT, { || "2" } )
	oStruFKZI:SetProperty( 'FKZ_DEDUCA', MODEL_FIELD_INIT, { || "  " } )
	oStruFKZI:SetProperty( 'FKZ_DEDISE', MODEL_FIELD_WHEN, { || .F. } )

	aAux := FwStruTrigger("FKZ_DEDUCA" ,"FKZ_DESCRD" ,'Posicione("SX5",1,xFilial("SX5")+"0M"+M->FKZ_DEDUCA,"X5_DESCRI")',.F.,,,)
	oStruFKZD:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

	aAux := {}
	aAux := FwStruTrigger("FKZ_ISENCA" ,"FKZ_DESCRI" ,'Posicione("SX5",1,xFilial("SX5")+"0K"+M->FKZ_ISENCA,"X5_DESCRI")',.F.,,,)
	oStruFKZI:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'FKXMODEL', /*bPreValidacao*/, /**/, /*bCommit*/, /*bCancel*/ )
	
	oModel:AddFields( 'FKXMASTER', /*cOwner*/, oStruFKX )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'FKZDETAILD', 'FKXMASTER', oStruFKZD, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'FKZDETAILI', 'FKXMASTER', oStruFKZI, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0001 )//'Natureza de Rendimento'

	// Faz relaciomaneto entre os compomentes do model
	AAdd( aRltDed, { 'FKZ_FILIAL', 'xFilial( "FKZ" )' } )
	AAdd( aRltDed, { 'FKZ_CODIGO', 'FKX_CODIGO' } )
	AAdd( aRltDed, { 'FKZ_DEDISE', '"1"' } )

	AAdd( aRltIse, { 'FKZ_FILIAL', 'xFilial( "FKZ" )' } )
	AAdd( aRltIse, { 'FKZ_CODIGO', 'FKX_CODIGO' } )
	AAdd( aRltIse, { 'FKZ_DEDISE', '"2"' } )

	oModel:SetRelation( 'FKZDETAILD', aRltDed, FKZ->( IndexKey( 1 ) ) )	
	// Liga o controle de não repetição de linha
	oModel:GetModel( 'FKZDETAILD' ):SetUniqueLine( { 'FKZ_DEDUCA' } )

	oModel:SetRelation( 'FKZDETAILI', aRltIse, FKZ->( IndexKey( 1 ) ) )
	// Liga o controle de não repetição de linha
	oModel:GetModel( 'FKZDETAILI' ):SetUniqueLine( { 'FKZ_ISENCA' } )

	oModel:GetModel( 'FKZDETAILD' ):SetOptional( .T. )
	oModel:GetModel( 'FKZDETAILI' ):SetOptional( .T. )

	oModel:GetModel( 'FKXMASTER' ):SetDescription(STR0001)//'Natureza de Rendimento'
	oModel:GetModel( 'FKZDETAILD' ):SetDescription(STR0010)//'Deduções'
	oModel:GetModel( 'FKZDETAILI' ):SetDescription(STR0011)//'Isenções'

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela montagem da View

@author		Vinicius do Prado
@since		21/02/2019
@version	1
@return		oView - objeto da View
/*/
//-------------------------------------------------------------------

Static Function ViewDef() As Object

	Local oStruFKX	As Object
	Local oStruFKZD	As Object
	Local oStruFKZI	As Object
	Local oModel	As Object
	Local oView		As Object

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	oStruFKX	:= FWFormStruct( 2, 'FKX' )
	oStruFKZD	:= FWFormStruct( 2, 'FKZ', { |x| !ALLTRIM(x) $ "FKZ_CODIGO,FKZ_ISENCA"} )
	oStruFKZI	:= FWFormStruct( 2, 'FKZ', { |x| !ALLTRIM(x) $ "FKZ_CODIGO,FKZ_DEDUCA"} )

	oStruFKZD:AddField(	'FKZ_DESCRD',;			// [01] C Nome do Campo
						'50',;					// [02] C Ordem
						AllTrim(STR0009),;		// [03] C Titulo do campo //'Descrição'    
						AllTrim(STR0009),;		// [04] C Descrição do campo //'Descrição'    
						{STR0009},;				// [05] A Array com Help //'Descrição'    
						'C',;					// [06] C Tipo do campo
						'@!',;					// [07] C Picture
						NIL,;					// [08] B Bloco de Picture Var
						'',;					// [09] C Consulta F3
						.F.,;					// [10] L Indica se o campo é editável
						NIL,;					// [11] C Pasta do campo
						NIL,;					// [12] C Agrupamento do campo
						{},;					// [13] A Lista de valores permitido do campo (Combo)
						NIL,;					// [14] N Tamanho Maximo da maior opção do combo
						NIL,;					// [15] C Inicializador de Browse
						.T.,;					// [16] L Indica se o campo é virtual
						NIL )					// [17] C Picture Variável

	oStruFKZI:AddField(	'FKZ_DESCRI',;			// [01] C Nome do Campo
						'50',;					// [02] C Ordem
						AllTrim(STR0009),;		// [03] C Titulo do campo //'Descrição'    
						AllTrim(STR0009),;		// [04] C Descrição do campo //'Descrição'    
						{STR0009},;				// [05] A Array com Help //'Descrição'    
						'C',;					// [06] C Tipo do campo
						'@!',;					// [07] C Picture
						NIL,;					// [08] B Bloco de Picture Var
						'',;					// [09] C Consulta F3
						.F.,;					// [10] L Indica se o campo é editável
						NIL,;					// [11] C Pasta do campo
						NIL,;					// [12] C Agrupamento do campo
						{},;					// [13] A Lista de valores permitido do campo (Combo)
						NIL,;					// [14] N Tamanho Maximo da maior opção do combo
						NIL,;					// [15] C Inicializador de Browse
						.T.,;					// [16] L Indica se o campo é virtual
						NIL )					// [17] C Picture Variável

	// Cria a estrutura a ser usada na View
	oModel   := FWLoadModel( 'FINA028' )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_FKX', oStruFKX, 'FKXMASTER' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_FKZD', oStruFKZD, 'FKZDETAILD' )
	oView:AddGrid(  'VIEW_FKZI', oStruFKZI, 'FKZDETAILI' )

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'VIEWFKX' , 40 )
	oView:CreateHorizontalBox( 'VIEWFKZ' , 60 )

	//Criando a folder da grid (filhos)
	oView:CreateFolder('SHEET_DEDISE', 'VIEWFKZ')
	oView:AddSheet('SHEET_DEDISE', 'SHEET_DED', STR0010) //"Deduções"
	oView:AddSheet('SHEET_DEDISE', 'SHEET_ISE', STR0011) //"Isenções"

	//Criando os vinculos onde serão mostrado os dados
	oView:CreateHorizontalBox('VIEWFKZD', 100,,, 'SHEET_DEDISE', 'SHEET_DED' )
	oView:CreateHorizontalBox('VIEWFKZI', 100,,, 'SHEET_DEDISE', 'SHEET_ISE' )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_FKX', 'VIEWFKX' )
	oView:SetOwnerView( 'VIEW_FKZD', 'VIEWFKZD' )
	oView:SetOwnerView( 'VIEW_FKZI', 'VIEWFKZI' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F028Des
Função para gatilhar a descrição da tabela 0J e 0K

@param cTipo	- Indica de qual aba é a chamada (deducao/isencao)
@return - Retorna a descrição a ser exibida de acordo com a aba

@author		Rodrigo.Pirolo
@since		07/05/2019
@version	P12
/*/
//-------------------------------------------------------------------

Function F028Des( cTipo As Character ) As Character

	Local cRet		As Character
	Local oModel	As Object
	Local oModFKZ	As Object
	Local cModelId	As Character

	Default cTipo	:= ""

	If !Empty(cTipo)
		
		cRet	:= ""
		oModel	:= FwModelActive()
		
		If cTipo == "D"
			cModelId := "FKZDETAILD" 
		Else
			cModelId := "FKZDETAILI"
		EndIf
		
		If !INCLUI .and. oModel != NIL
			oModFKZ := oModel:GetModel(cModelId)
			
			If oModFKZ:length() == 0
				If cTipo == "D"
					cRet := Posicione("SX5",1,XFILIAL("SX5")+"0M"+FKZ->FKZ_DEDUCA,"X5_DESCRI")
				Else
					cRet := Posicione("SX5",1,XFILIAL("SX5")+"0K"+FKZ->FKZ_ISENCA,"X5_DESCRI")
				EndIf
			EndIf
		Endif
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa028Combo 
Função para apresentar as opções de tributo para o campo FKX_TRIBUT

@return cCombo - Indica qual tributo foi selecionado

@author		Douglas.Oliveira
@since		17/10/2022
@version	P12
/*/
//-------------------------------------------------------------------
Function Fa028Combo() as character

	Local cCombo as Character

	cCombo  := ""   

	cCombo	:= Alltrim(STR0008) //"1=IR;2=IR, PIS, COFINS, CSLL e Agreg;3=PIS e COFINS;4=IR e CSLL;5=IR, CSLL e Agreg;6=CSLL;7=PIS, COFINS e CSLL;8=PIS, COFINS, CSLL e Agreg"
																					
Return cCombo

//---------------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} FinaAtuFKX()
Função responsavel por popular a tabela FKX na inicialização do modulo SIGAFIN (auto-contida), 
através da chamada no FINXLOAD.

@sample FinaAtuFKX()
@author Vinicius do Prado
@since 20/02/19
@version 1.0

/*/
//---------------------------------------------------------------------------------------------------------
Function FinaAtuFKX()

	Local nI		As Numeric
	Local aAreaAtu	As Array
	Local aAreaFKX	As Array
	Local aAreaFKZ	As Array
	Local aFKX		As Array
	Local aFKZ		As Array
	Local cFilFKX	As Character

	nI		 := 0
	aAreaAtu := GetArea()
	aAreaFKX := FKX->(GetArea())
	aAreaFKZ := FKZ->(GetArea())
	aFKX	 := {}
	aFKZ	 := {}
	cFilFKX	 := xFilial("FKX")	

	/* Ordem dos elementos do array aFKX para gravacao da tabela FKX 
	Filial + Codigo + Descricao + FCI + 13 sal. + RRA + Ext. PF + Ext. PJ + Declarante + Tributo + Descr. Extendida */

	// - Grupo 10 - Rendimento do Trabalho e da Previdência Social
	AAdd(aFKX,{cFilFKX,"10001",STR0012,"2","1","1","1","3","3","1",STR0012}) //"Rendimento decorrente do trabalho com vínculo empregatício"
	AAdd(aFKX,{cFilFKX,"10002",STR0013,"2","2","1","1","3","2","1",STR0013}) //"Rendimento decorrente do trabalho sem vínculo empregatício"
	AAdd(aFKX,{cFilFKX,"10003",STR0014,"2","1","1","1","3","2","1",STR0014}) //"Rendimento decorrente do trabalho pago a trabalhador avulso"
	AAdd(aFKX,{cFilFKX,"10004",STR0015,"2","2","1","1","3","2","1",STR0015}) //"Participação nos lucros ou resultados (PLR)"
	AAdd(aFKX,{cFilFKX,"10005",STR0016,"2","1","1","1","3","2","1",STR0016}) //"Benefício de Regime Próprio de Previdência Social"
	AAdd(aFKX,{cFilFKX,"10006",STR0017,"2","1","1","1","3","2","1",STR0017}) //"Benefício do Regime Geral de Previdência Social"
	AAdd(aFKX,{cFilFKX,"10007",STR0018,"2","2","2","2","3","2","1",STR0019}) //"Rendimentos relativos a prestação de serviços de Transporte"## "Rendimentos relativos a prestação de serviços de Transporte Rodoviário Internacional de Carga, Auferidos por Transportador Autônomo Pessoa Física, Residente na República do Paraguai, considerado como Sociedade Unipessoal nesse País"
	AAdd(aFKX,{cFilFKX,"10008",STR0020,"2","2","1","1","3","2","1",STR0021}) //"Honorários advocatícios de sucumbência"## "Honorários advocatícios de sucumbência recebidos pelos advogados e procuradores públicos de que trata o art. 27 da Lei nº 13.327"
	AAdd(aFKX,{cFilFKX,"10009",STR0023,"2","2","2","1","3","2","1",STR0023}) //"Auxílio moradia"
	AAdd(aFKX,{cFilFKX,"10010",STR0022,"2","1","1","1","3","3","",STR0022}) //"Bolsa ao médico residente"

	// - Grupo 11 - Rendimento decorrente de Decisão Judicial
	AAdd(aFKX,{cFilFKX,"11001",STR0024,"2","1","1","1","1","3","1",STR0024}) //"Decorrente de Decisão da Justiça do Trabalho"
	AAdd(aFKX,{cFilFKX,"11002",STR0025,"2","2","1","1","1","2","1",STR0025}) //"Decorrente de Decisão da Justiça Federal"
	AAdd(aFKX,{cFilFKX,"11003",STR0026,"2","1","1","1","1","3","1",STR0027}) //"Decorrente de Decisão da Justiça dos Estados/Dist. Federal" ##"Decorrente de Decisão da Justiça dos Estados/Distrito Federal"
	AAdd(aFKX,{cFilFKX,"11004",STR0028,"2","2","1","1","1","3","1",STR0029}) //"Responsabilidade Civil - juros e indenizações" ## "Responsabilidade Civil - juros e indenizações por lucros cessantes, inclusive astreinte"
	AAdd(aFKX,{cFilFKX,"11005",STR0030,"2","2","1","3","1","3","1",STR0031}) //"Decisão Judicial Importâncias pagas por danos morais" ## "Decisão Judicial Importâncias pagas a título de indenizações por danos morais, decorrentes de sentença judicial."
	AAdd(aFKX,{cFilFKX,"11006",STR0371,"2","2","2","1","4","2","" ,STR0371}) //"Rendimentos pagos sem retenção do IR na fonte - Lei 10.833/2003"

	// - Grupo 12 - Rendimento do Capital
	AAdd(aFKX,{cFilFKX,"12001",STR0032,"2","2","1","1","1","2","" ,STR0032}) //"Lucro e Dividendo"
	AAdd(aFKX,{cFilFKX,"12002",STR0033,"2","2","2","1","3","2","1",STR0034}) //"Resgate de Previdência Complementar-Modalidade Contribuição" ## "Resgate de Previdência Complementar - Modalidade Contribuição Definida/Variável - Não Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12003",STR0035,"2","2","2","1","3","2","1",STR0036}) //"Resgate de Fundo de Aposentadoria Programada Individual" ## "Resgate de Fundo de Aposentadoria Programada Individual (Fapi)- Não Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12004",STR0037,"2","2","2","1","3","2","1",STR0038}) //"Resgate de Previdência Complementar - Modalidade Benefício" ## "Resgate de Previdência Complementar - Modalidade Benefício Definido - Não Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12005",STR0033,"2","2","2","1","3","2","1",STR0039}) //"Resgate de Previdência Complementar-Modalidade Contribuição" ## "Resgate de Previdência Complementar - Modalidade Contribuição Definida/Variável - Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12006",STR0035,"2","2","2","1","3","2","1",STR0040}) //"Resgate de Fundo de Aposentadoria Programada Individual" ## "Resgate de Fundo de Aposentadoria Programada Individual (Fapi)- Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12007",STR0041,"2","2","2","1","3","2","1",STR0042}) //"Resgate de Planos de Seguro de Vida - Cláusula de Cobertura" ## "Resgate de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência-Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12008",STR0043,"2","2","2","1","3","2","1",STR0044}) //"Resgate de Planos de Seguro de Vida-Cláusula Sobrevivência" ## "Resgate de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência - Não Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12009",STR0045,"2","1","1","1","3","2","1",STR0046}) //"Benefício de Previdência Complementar-Modalidade Contribuição" ## "Benefício de Previdência Complementar - Modalidade Contribuição Definida/Variável - Não Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12010",STR0047,"2","1","1","1","3","2","1",STR0048}) //"Benefício de Fundo de Aposentadoria Programada Individual" ## "Benefício de Fundo de Aposentadoria Programada Individual (Fapi)- Não Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12011",STR0049,"2","1","1","1","3","2","1",STR0050}) //"Benefício de Previdência Complementar-Modalidade Benefício" ## "Benefício de Previdência Complementar - Modalidade Benefício Definido - Não Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12012",STR0051,"2","1","1","1","3","2","1",STR0052}) //"Benefício de Previdência Complementar - Mod. Contribuição" ## "Benefício de Previdência Complementar - Modalidade Contribuição Definida/Variável - Optante pela Tributação Exclusiva
	AAdd(aFKX,{cFilFKX,"12013",STR0047,"2","1","1","1","3","2","1",STR0053}) //"Benefício de Fundo de Aposentadoria Programada Individual" ## "Benefício de Fundo de Aposentadoria Programada Individual (Fapi)- Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12014",STR0054,"2","1","2","1","3","2","1",STR0055}) //"Benefício de Planos de Seguro de Vida com sobrevivência" ## "Benefício de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência- Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12015",STR0054,"2","2","1","1","3","2","1",STR0056}) //"Benefício de Planos de Seguro de Vida com sobrevivência" ## "Benefício de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência - Não Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12016",STR0057,"1","2","2","1","1","2","1",STR0056}) // "Juros sobre o Capital Próprio" ## "Benefício de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência - Não Optante pela Tributação Exclusiva"
	AAdd(aFKX,{cFilFKX,"12017",STR0058,"2","2","2","1","1","2","1",STR0059}) //"Rendimento de Aplicações Financeiras de Renda Fixa" ## "Rendimento de Aplicações Financeiras de Renda Fixa, decorrentes de alienação, liquidação (total ou parcial), resgate, cessão ou repactuação do título ou aplicação"
	AAdd(aFKX,{cFilFKX,"12018",STR0060,"2","2","2","1","1","2","1",STR0061}) //"Rendimentos pela entrega de recursos à pessoa jurídica" ## "Rendimentos auferidos pela entrega de recursos à pessoa jurídica, sob qualquer forma e a qualquer título, independentemente de ser ou não a fonte pagadora instituição autorizada a funcionar pelo Banco Central"
	AAdd(aFKX,{cFilFKX,"12019",STR0062,"2","2","2","1","1","2","1",STR0063}) //"Rendimentos predeterminados obtidos em operações conjugadas" ## "Rendimentos predeterminados obtidos em operações conjugadas realizadas: nos mercados de opções de compra e venda em bolsas de valores, de mercadorias e de futuros (box); no mercado a termo nas bolsas de valores, de mercadorias e de futuros, em operações de venda coberta esem ajustes diários, e no mercado de balcão."
	AAdd(aFKX,{cFilFKX,"12020",STR0064,"2","2","2","1","1","2","1",STR0065}) //"Rendimentos obtidos nas operações de transf. de dívidas" ## "Rendimentos obtidos nas operações de transferência de dívidas realizadas com instituição financeira e outras instituições autorizadas a funcionar pelo Banco Central do Brasil"
	AAdd(aFKX,{cFilFKX,"12021",STR0066,"2","2","2","1","1","2","1",STR0067}) //"Rendimentos periódicos produzidos por título ou aplicação" ## "Rendimentos periódicos produzidos por título ou aplicação, bem como qualquer remuneração adicional aos rendimentos prefixados" 
	AAdd(aFKX,{cFilFKX,"12022",STR0068,"2","2","2","1","1","2","1",STR0069}) ///"Rendimentos nas operações de mútuo de recursos financeiros" ## "Rendimentos auferidos nas operações de mútuo de recursos financeiros entre pessoa física e pessoa jurídica e entre pessoas jurídicas, inclusive controladoras, controladas, coligadas e interligadas"
	AAdd(aFKX,{cFilFKX,"12023",STR0070,"2","2","2","3","1","2","1",STR0071}) //"Rendimentos em operações de adiantamento sobre contr.câmbio" ## "Rendimentos auferidos em operações de adiantamento sobre contratos de câmbio de exportação, não sacado (trava de câmbio), bem como operações com export notes, com debêntures, com depósitos voluntários para garantia de instância e com depósitos judiciais ou administrativos, quando seu levantamento se der em favor do depositante"
	AAdd(aFKX,{cFilFKX,"12024",STR0072,"2","2","2","1","1","2","1",STR0073}) //"Rendimentos nas operações de mútuo e de compra vinculada" ## "Rendimentos obtidos nas operações de mútuo e de compra vinculada à revenda tendo por objeto ouro, ativo financeiro"
	AAdd(aFKX,{cFilFKX,"12025",STR0074,"2","2","2","1","1","2","1",STR0074}) //"Rendimentos auferidos em contas de depósitos de poupança"
	AAdd(aFKX,{cFilFKX,"12026",STR0075,"2","2","2","1","1","2","1",STR0076}) //"Rendimentos sobre juros produzidos por letras hipotecárias" ## "Rendimentos auferidos sobre juros produzidos por letras hipotecárias"
	AAdd(aFKX,{cFilFKX,"12027",STR0077,"2","2","2","1","1","2","1",STR0078})//"Rendimentos ou ganhos decorrentes da negociação de títulos" ## "Rendimentos ou ganhos decorrentes da negociação de títulos ou valores mobiliários de renda fixa em bolsas de valores, de mercadorias, de futuros e assemelhadas"
	AAdd(aFKX,{cFilFKX,"12028",STR0079,"2","2","2","1","1","2","1",STR0080}) //"Rendimentos aplic. finan. de renda fixa ou renda variável" ## "Rendimentos auferidos em outras aplicações financeiras de renda fixa ou de renda variável"
	AAdd(aFKX,{cFilFKX,"12029",STR0081,"1","2","2","1","1","2","1",STR0081}) //"Rendimentos auferidos em Fundo de Investimento"
	AAdd(aFKX,{cFilFKX,"12030",STR0082,"1","2","2","1","1","2","1",STR0083}) //"Rendimentos auferidos em Fundos de investimento em quotas" ## "Rendimentos auferidos em Fundos de investimento em quotas de fundos de investimento"
	AAdd(aFKX,{cFilFKX,"12031",STR0084,"1","2","2","1","1","2","1",STR0085}) //"Rendimentos por aplic. em fundos de investimento em ações" ## "Rendimentos produzidos por aplicações em fundos de investimento em ações"
	AAdd(aFKX,{cFilFKX,"12032",STR0086,"1","2","2","1","1","2","1",STR0087}) //"Rendimentos por aplic. em fundos de investimento em quotas" ## "Rendimentos produzidos por aplicações em fundos de investimento em quotas defundos de investimento em ações"
	AAdd(aFKX,{cFilFKX,"12033",STR0088,"1","2","2","1","1","2","1",STR0089}) //"Rendimentos por aplic. em Fundos Mútuos de Privatização" ## "Rendimentos produzidos por aplicações em Fundos Mútuos de Privatização com recursos do Fundo de Garantia por Tempo de Serviço (FGTS)
	AAdd(aFKX,{cFilFKX,"12034",STR0088,"1","2","2","1","1","2","1",STR0090}) //"Rendimentos por aplic. em Fundos Mútuos de Privatização" ## "Rendimentos auferidos pela carteira dos Fundos de Investimento Imobiliário"
	AAdd(aFKX,{cFilFKX,"12035",STR0091,"1","2","2","1","1","2","1",STR0092}) //"Rendimentos distr. pelo Fundo de Invest. Imob. aos cotistas" ##  "Rendimentos distribuídos pelo Fundo de Investimento Imobiliário aos seus cotistas"
	AAdd(aFKX,{cFilFKX,"12036",STR0093,"1","2","2","1","1","2","1",STR0094}) //"Rendimento no resgate de cotas na liq. do Fundo de Invest." ## "Rendimento auferido pelo cotista no resgate de cotas na liquidação do Fundo de Investimento Imobiliário"
	AAdd(aFKX,{cFilFKX,"12037",STR0095,"1","2","2","1","1","2","1",STR0096}) //"Rendimentos pela carteira dos Fundos de Invest. Imobiliário" ## "Rendimentos auferidos pela carteira dos Fundos de Investimento Imobiliário Distribuição semestral"
	AAdd(aFKX,{cFilFKX,"12038",STR0097,"1","2","2","1","1","2","1",STR0098}) //"Rendimentos distribuídos pelo Fundo de Invest. Imobiliário" ## "Rendimentos distribuídos pelo Fundo de Investimento Imobiliário aos seus cotistas - Distribuição semestral"
	AAdd(aFKX,{cFilFKX,"12039",STR0099,"1","2","2","1","1","2","1",STR0100}) //"Rendimento pelo cotista no resgate de cotas na liquidação" ## "Rendimento auferido pelo cotista no resgate de cotas na liquidação do Fundo de Investimento Imobiliário Distribuição semestral"
	AAdd(aFKX,{cFilFKX,"12040",STR0101,"1","2","2","1","1","3","1",STR0102}) //"Rendimentos e ganhos de capital distr. pelo Fundo Invest." ## "Rendimentos e ganhos de capital distribuídos pelo Fundo de Investimento Cultural e Artístico (Ficart)"
	AAdd(aFKX,{cFilFKX,"12041",STR0103,"1","2","2","1","1","3","1",STR0104}) //"Rendimentos e ganhos de capital distribuídos (Funcines)" ## "Rendimentos e ganhos de capital distribuídos pelo Fundo de Financiamento da Indústria Cinematográfica Nacional (Funcines)"
	AAdd(aFKX,{cFilFKX,"12043",STR0107,"1","2","2","1","1","2","1",STR0108}) //"Ganho de capital decorrente da integralização de cotas" ## "Ganho de capital decorrente da integralização de cotas de fundos ou clubes de investimento por meio da entrega de ativos financeiros"
	AAdd(aFKX,{cFilFKX,"12044",STR0109,"1","2","2","1","1","2","1",STR0110}) //"Distribuição de Juros sobre o Capital Próprio" ## "Distribuição de Juros sobre o Capital Próprio pela companhia emissora de ações objeto de empréstimo"
	AAdd(aFKX,{cFilFKX,"12045",STR0111,"2","2","2","1","1","2","1",STR0111}) //"Rendimentos de Partes Beneficiárias ou de Fundador"
	AAdd(aFKX,{cFilFKX,"12046",STR0112,"2","2","2","1","1","2","1",STR0112}) //"Rendimentos auferidos em operações de swap"
	AAdd(aFKX,{cFilFKX,"12047",STR0113,"2","2","2","1","1","3","1",STR0114}) //"Rendimentos auferidos em operações day trade" ## "Rendimentos auferidos em operações day trade realizadas em bolsa de valores, de mercadorias, de futuros e assemelhadas"
	AAdd(aFKX,{cFilFKX,"12048",STR0115,"2","2","2","1","1","3","1",STR0116}) //"Rendimento decorrente de operação exceto day trade" ## "Rendimento decorrente de Operação realizada em bolsas de valores, de mercadorias, de futuros, e assemelhadas, exceto day trade"
	AAdd(aFKX,{cFilFKX,"12049",STR0117,"2","2","2","1","1","3","1",STR0118}) //"Rendimento decorrente de oper. realizada no merc. de balcão" ## "Rendimento decorrente de Operação realizada no mercado de balcão, com intermediação, tendo por objeto ações, ouro ativo financeiro e outros valores mobiliários negociados no mercado à vista"
	AAdd(aFKX,{cFilFKX,"12050",STR0119,"2","2","2","1","1","3","1",STR0120}) //"Rendimento decorrente de oper. realizada em merc. liquid." ## "Rendimento decorrente de Operação realizada em mercados de liquidação futura fora de bolsa"
	AAdd(aFKX,{cFilFKX,"12051",STR0119,"1","2","2","4","4","2","1",STR0121}) //"Rendimento decorrente de oper. realizada em merc. liquid." ## "Rendimentos de debêntures emitidas por sociedade de propósito específico conforme previsto no art. 2º da Lei nº 12.431 de 2011"
	AAdd(aFKX,{cFilFKX,"12052",STR0367,"1","2","2","1","1","2","1",STR0368}) //"Juros sobre o Capital Próprio cujos beneficiários não esteja" ## "Juros sobre o Capital Próprio cujos beneficiários não estejam identificados no momento do registro contábil"
	AAdd(aFKX,{cFilFKX,"12099",STR0122,"1","2","2","1","1","2","1",STR0122}) //"Demais rendimentos de Capital"

	// - Grupo 13 - Rendimento de Direitos (Royalties)
	AAdd(aFKX,{cFilFKX,"13001",STR0123,"2","2","1","1","2","3","1",STR0123}) //"Rendimentos de Aforamento"
	AAdd(aFKX,{cFilFKX,"13002",STR0124,"2","2","1","1","2","3","1",STR0124}) //"Rendimentos de Locação ou Sublocação" 
	AAdd(aFKX,{cFilFKX,"13003",STR0125,"2","2","1","1","2","3","1",STR0125}) //"Rendimentos de Arrendamento ou Subarrendamento"
	AAdd(aFKX,{cFilFKX,"13004",STR0126,"2","2","1","1","2","3","1",STR0127}) //"Importâncias pagas por terceiro por conta do locador do bem" ## "Importâncias pagas por terceiros por conta do locador do bem (juros, comissões etc.)"
	AAdd(aFKX,{cFilFKX,"13005",STR0128,"2","2","1","1","2","3","1",STR0129}) //"Importâncias pagas ao locador pelo contrato celebrado" ## "Importâncias pagas ao locador pelo contrato celebrado (luvas, prêmios etc.)"
	AAdd(aFKX,{cFilFKX,"13006",STR0130,"2","2","1","1","2","3","1",STR0131}) //"Benfeitorias e quaisquer melhoramentos feitos no bem locado" ## "Benfeitorias e quaisquer melhoramentos realizados no bem locado"
	AAdd(aFKX,{cFilFKX,"13007",STR0132,"2","2","1","1","2","3","1",STR0132}) //"Juros decorrente da alienação a prazo de bens"
	AAdd(aFKX,{cFilFKX,"13008",STR0133,"2","2","1","1","2","3","1",STR0134}) //"Rendimentos de Direito de Uso ou Passagem de Terrenos" ## "Rendimentos de Direito de Uso ou Passagem de Terrenos e de aproveitamento de águas"
	AAdd(aFKX,{cFilFKX,"13009",STR0135,"2","2","1","1","2","3","1",STR0136}) //"Rendimentos de Direito de colher ou extrair rec. vegetais" ## "Rendimentos de Direito de colher ou extrair recursos vegetais, pesquisar e extrair recursos minerais"
	AAdd(aFKX,{cFilFKX,"13010",STR0137,"2","2","1","1","2","3","1",STR0137}) //"Rendimentos de Direito Autoral"
	AAdd(aFKX,{cFilFKX,"13011",STR0137,"2","2","1","1","2","3","1",STR0138}) //"Rendimentos de Direito Autoral" ## "Rendimentos de Direito Autoral (quando não percebidos pelo autor ou criador da obra)"
	AAdd(aFKX,{cFilFKX,"13012",STR0139,"2","2","1","1","2","3","1",STR0139}) //"Rendimentos de Direito de Imagem"
	AAdd(aFKX,{cFilFKX,"13013",STR0140,"2","2","1","1","2","3","1",STR0141}) //"Rendimentos de Direito sobre películas cinematográficas" ## "Rendimentos de Direito sobre películas cinematográficas, Obras Audiovisuais, e Videofônicas"
	AAdd(aFKX,{cFilFKX,"13014",STR0142,"2","2","1","1","2","3","1",STR0143}) //"Rendimento de Direito relativo a radiodifusão" ## "Rendimento de Direito relativo a radiodifusão de sons e imagens e serviço de comunicação eletrônica de massa por assinatura"
	AAdd(aFKX,{cFilFKX,"13015",STR0144,"2","2","1","1","2","3","1",STR0144}) //"Rendimentos de Direito de Conjuntos Industriais e Invenções"
	AAdd(aFKX,{cFilFKX,"13016",STR0145,"2","2","1","1","2","3","1",STR0146}) //"Rendimento de Direito de marcas de indústria e comércio" ## "Rendimento de Direito de marcas de indústria e comércio, patentes de invenção e processo ou fórmulas de fabricação"
	AAdd(aFKX,{cFilFKX,"13017",STR0147,"2","2","1","1","2","3","1",STR0146}) // "Importâncias pagas por terc. por conta cedente dos direitos" ## "Rendimento de Direito de marcas de indústria e comércio, patentes de invenção e processo ou fórmulas de fabricação"
	AAdd(aFKX,{cFilFKX,"13018",STR0148,"2","2","1","1","2","3","1",STR0149}) //"Importâncias pagas cedente do direito, pelo contr.celebrado" ## "Importâncias pagas ao cedente do direito, pelo contrato celebrado (luvas, prêmios etc.)"
	AAdd(aFKX,{cFilFKX,"13019",STR0148,"2","2","1","1","2","3","1",STR0150}) //"Importâncias pagas cedente do direito, pelo contr.celebrado" ## "Despesas para conservação dos direitos cedidos (quando compensadas pelo uso do bem ou direito)"
	AAdd(aFKX,{cFilFKX,"13020",STR0151,"2","2","1","1","2","3","1",STR0152}) //"Juros de mora e quaisquer outras comp.pelo atraso no pagto." ## "Juros de mora e quaisquer outras compensações pelo atraso no pagamento de royalties decorrente de prestação de serviço"
	AAdd(aFKX,{cFilFKX,"13021",STR0151,"2","2","1","1","2","3","1",STR0153}) //"Juros de mora e quaisquer outras comp.pelo atraso no pagto." ## "Juros de mora e quaisquer outras compensações pelo atraso no pagamento de royalties decorrente de aquisição de bens"
	AAdd(aFKX,{cFilFKX,"13022",STR0154,"2","2","1","1","2","3","1",STR0155}) //"Juros decorrente da alienação a prazo de direitos" ## "Juros decorrente da alienação a prazo de direitos decorrente de prestação de serviço"
	AAdd(aFKX,{cFilFKX,"13023",STR0154,"2","2","1","1","2","3","1",STR0156}) //"Juros decorrente da alienação a prazo de direitos" ## "Juros decorrente da alienação a prazo de direitos decorrente de aquisição de bens"
	AAdd(aFKX,{cFilFKX,"13024",STR0157,"2","2","2","3","2","2","1",STR0158}) //"Alienação de bens e direitos do ativo não circulante-Brasil" ## "Alienação de bens e direitos do ativo não circulante localizados no Brasil"
	AAdd(aFKX,{cFilFKX,"13025",STR0159,"2","2","1","1","2","3","1",STR0160}) //"Rendimento de transferência de atleta profissional" ## "Rendimento de Direito decorrente da transferência de atleta profissional"
	AAdd(aFKX,{cFilFKX,"13026",STR0161,"2","2","1","1","2","","1",STR0162}) //"Juros e comissões de parc. dos créditos do inciso XI" ## "Juros e comissões correspondentes à parcela dos créditos de que trata o inciso XI do art. 1º da Lei nº 9.481, de 1997, não aplicada no financiamento de exportações"
	AAdd(aFKX,{cFilFKX,"13098",STR0164,"2","2","1","1","2","3","1",STR0164}) //"Demais rendimentos de Direito"
	AAdd(aFKX,{cFilFKX,"13099",STR0163,"2","2","1","1","2","3","1",STR0163}) //"Demais rendimentos de Royalties"

	// - Grupo 14 - Prêmios e demais rendimentos
	AAdd(aFKX,{cFilFKX,"14001",STR0165,"2","2","2","1","1","3","1",STR0166}) //"Prêmios distribuídos, sob a forma de bens e serviços" ## "Prêmios distribuídos, sob a forma de bens e serviços, mediante loterias, concursos e sorteios, exceto a distribuição realizada por meio de vale-brinde"
	AAdd(aFKX,{cFilFKX,"14002",STR0167,"2","2","2","1","1","3","1",STR0168}) //"Prêmios distribuídos, sob a forma de dinheiro" ## "Prêmios distribuídos, sob a forma de dinheiro, mediante loterias, concursos e sorteios, exceto os de antecipação nos títulos de capitalização e os de amortização e resgate das ações das sociedades anônimas"
	AAdd(aFKX,{cFilFKX,"14003",STR0169,"2","2","2","1","1","3","1",STR0169}) //"Prêmios de Proprietários e Criadores de Cavalos de Corrida"
	AAdd(aFKX,{cFilFKX,"14004",STR0170,"2","2","2","1","1","3","1",STR0171}) //"Benefícios liq.mediante sorteio de títulos de capitalização" ## "Benefícios líquidos mediante sorteio de títulos de capitalização, sem amortização antecipada"
	AAdd(aFKX,{cFilFKX,"14005",STR0172,"2","2","2","1","1","3","1",STR0173}) //"Benefícios líquidos resultantes da amortização antecipada" ## "Benefícios líquidos resultantes da amortização antecipada, mediante sorteio, dos títulos de capitalização e benefícios atribuídos aos portadores de títulos de capitalização nos lucros da empresa emitente"
	AAdd(aFKX,{cFilFKX,"14006",STR0165,"2","2","2","1","1","3","1",STR0174}) //"Prêmios distribuídos, sob a forma de bens e serviços" ## "Prêmios distribuídos, sob a forma de bens e serviços, mediante sorteios de jogos de bingo permanente ou eventual"
	AAdd(aFKX,{cFilFKX,"14007",STR0175,"2","2","2","1","1","3","1",STR0176}) //"Prêmios distr.dinheiro, obtido mediante sort.de jogos bingo" ## "Prêmios distribuídos, em dinheiro, obtido mediante sorteios de jogos de bingo permanente ou eventual"
	AAdd(aFKX,{cFilFKX,"14008",STR0177,"2","2","2","1","1","3","1",STR0178}) //"Importâncias de multas e qualquer outra vantagem" ## "Importâncias correspondentes a multas e qualquer outra vantagem, ainda que a título de indenização, em virtude de rescisão de contrato"
	AAdd(aFKX,{cFilFKX,"14099",STR0179,"2","2","2","1","1","3","1",STR0180}) //"Demais Benefícios Liq.decorrentes de título capitalização" ## "Demais Benefícios Líquidos decorrentes de título de capitalização"

	// - Grupo 15 - Rendimento Pago/Creditado a Pessoa Jurídica
	AAdd(aFKX,{cFilFKX,"15001",STR0181,"2","2","2","3","4","2","1",STR0182}) // "Importâncias pagas ou creditadas a cooperativas de trabalho" ## "Importâncias pagas ou creditadas a cooperativas de trabalho relativas a serviços pessoais que lhes forem prestados por associados destas ou colocados à disposição"
	AAdd(aFKX,{cFilFKX,"15002",STR0181,"2","2","2","3","4","2","2",STR0183}) //"Importâncias pagas ou creditadas a cooperativas de trabalho" ## "Importâncias pagas ou creditadas a associações de profissionais ou assemelhadas, relativas a serviços pessoais que lhes forem prestados por associados destas ou colocados à disposição"
	AAdd(aFKX,{cFilFKX,"15003",STR0184,"2","2","2","3","4","2","2",STR0185}) //"Remuneração de Serviços de adm.de bens ou negócios em geral" ## "Remuneração de Serviços de administração de bens ou negócios em geral, exceto consórcios ou fundos mútuos para aquisição de bens"
	AAdd(aFKX,{cFilFKX,"15004",STR0186,"2","2","2","3","4","2","2",STR0186}) //"Remuneração de Serviços de advocacia"
	AAdd(aFKX,{cFilFKX,"15005",STR0187,"2","2","2","3","4","2","2",STR0187}) //"Remuneração de Serviços de análise clínica laboratorial"
	AAdd(aFKX,{cFilFKX,"15006",STR0188,"2","2","2","3","4","2","2",STR0188}) //"Remuneração de Serviços de análises técnicas"
	AAdd(aFKX,{cFilFKX,"15007",STR0189,"2","2","2","3","4","2","2",STR0189}) //"Remuneração de Serviços de arquitetura"
	AAdd(aFKX,{cFilFKX,"15008",STR0190,"2","2","2","3","4","2","2",STR0191}) //"Remuneração de Serviços de assessoria e consultoria técnica" ## "Remuneração de Serviços de assessoria e consultoria técnica, exceto serviço de assistência técnica prestado a terceiros e concernente a ramo de indústria ou comércio explorado pelo prestador do serviço;"
	AAdd(aFKX,{cFilFKX,"15009",STR0192,"2","2","2","3","4","2","2",STR0192}) //"Remuneração de Serviços de assistência social;"
	AAdd(aFKX,{cFilFKX,"15010",STR0193,"2","2","2","3","4","2","2",STR0193}) //"Remuneração de Serviços de auditoria;"
	AAdd(aFKX,{cFilFKX,"15011",STR0194,"2","2","2","3","4","2","2",STR0194}) //"Remuneração de Serviços de avaliação e perícia;"
	AAdd(aFKX,{cFilFKX,"15012",STR0195,"2","2","2","3","4","2","2",STR0195}) //"Remuneração de Serviços de biologia e biomedicina;"
	AAdd(aFKX,{cFilFKX,"15013",STR0196,"2","2","2","3","4","2","2",STR0196}) //"Remuneração de Serviços de cálculo em geral"
	AAdd(aFKX,{cFilFKX,"15014",STR0197,"2","2","2","3","4","2","2",STR0197}) ///"Remuneração de Serviços de consultoria"
	AAdd(aFKX,{cFilFKX,"15015",STR0198,"2","2","2","3","4","2","2",STR0198}) //"Remuneração de Serviços de contabilidade"
	AAdd(aFKX,{cFilFKX,"15016",STR0199,"2","2","2","3","4","2","2",STR0199}) //"Remuneração de Serviços de desenho técnico"
	AAdd(aFKX,{cFilFKX,"15017",STR0200,"2","2","2","3","4","2","2",STR0200}) //"Remuneração de Serviços de economia"
	AAdd(aFKX,{cFilFKX,"15018",STR0201,"2","2","2","3","4","2","2",STR0201}) //"Remuneração de Serviços de elaboração de projetos"
	AAdd(aFKX,{cFilFKX,"15019",STR0202,"2","2","2","3","4","2","2",STR0203}) //"Remuneração de Serviços de engenharia" ## "Remuneração de Serviços de engenharia, exceto construção de estradas, pontes, prédios e obras assemelhada"
	AAdd(aFKX,{cFilFKX,"15020",STR0204,"2","2","2","3","4","2","2",STR0204}) //"Remuneração de Serviços de ensino e treinamento"
	AAdd(aFKX,{cFilFKX,"15021",STR0205,"2","2","2","3","4","2","2",STR0205}) //"Remuneração de Serviços de estatística"
	AAdd(aFKX,{cFilFKX,"15022",STR0206,"2","2","2","3","4","2","2",STR0206}) //"Remuneração de Serviços de fisioterapia"
	AAdd(aFKX,{cFilFKX,"15023",STR0207,"2","2","2","3","4","2","2",STR0207}) //"Remuneração de Serviços de fonoaudiologia"
	AAdd(aFKX,{cFilFKX,"15024",STR0208,"2","2","2","3","4","2","2",STR0208}) //"Remuneração de Serviços de geologia"
	AAdd(aFKX,{cFilFKX,"15025",STR0209,"2","2","2","3","4","2","2",STR0209}) //"Remuneração de Serviços de leilão"
	AAdd(aFKX,{cFilFKX,"15026",STR0210,"2","2","2","3","4","2","2",STR0211}) // "Remuneração serv. med. exceto aquela prest.por ambulatório" ## "Remuneração de Serviços de medicina, exceto aquela prestada por ambulatório, banco de sangue, casa de saúde, casa de recuperação ou repouso sob orientação médica, hospital e pronto-socorro"
	AAdd(aFKX,{cFilFKX,"15027",STR0212,"2","2","2","3","4","2","2",STR0212}) //"Remuneração de Serviços de nutricionismo e dietética"
	AAdd(aFKX,{cFilFKX,"15028",STR0213,"2","2","2","3","4","2","2",STR0213}) //"Remuneração de Serviços de odontologia"
	AAdd(aFKX,{cFilFKX,"15029",STR0214,"2","2","2","3","4","2","2",STR0215}) //"Remuneração de Serviços de organização de feiras amostras" ## "Remuneração de Serviços de organização de feiras de amostras, congressos, seminários, simpósios e congêneres"
	AAdd(aFKX,{cFilFKX,"15030",STR0216,"2","2","2","3","4","2","2",STR0216}) //"Remuneração de Serviços de pesquisa em geral"
	AAdd(aFKX,{cFilFKX,"15031",STR0217,"2","2","2","3","4","2","2",STR0217}) //"Remuneração de Serviços de planejamento"
	AAdd(aFKX,{cFilFKX,"15032",STR0218,"2","2","2","3","4","2","2",STR0218}) //"Remuneração de Serviços de programação"
	AAdd(aFKX,{cFilFKX,"15033",STR0219,"2","2","2","3","4","2","2",STR0219}) //"Remuneração de Serviços de prótese"
	AAdd(aFKX,{cFilFKX,"15034",STR0220,"2","2","2","3","4","2","2",STR0220}) //"Remuneração de Serviços de psicologia e psicanálise"
	AAdd(aFKX,{cFilFKX,"15035",STR0221,"2","2","2","3","4","2","2",STR0221}) //"Remuneração de Serviços de química"
	AAdd(aFKX,{cFilFKX,"15036",STR0222,"2","2","2","3","4","2","2",STR0222}) //"Remuneração de Serviços de radiologia e radioterapia"
	AAdd(aFKX,{cFilFKX,"15037",STR0223,"2","2","2","3","4","2","2",STR0223}) //"Remuneração de Serviços de relações públicas"
	AAdd(aFKX,{cFilFKX,"15038",STR0224,"2","2","2","3","4","2","2",STR0224}) //"Remuneração de Serviços de serviço de despachante"
	AAdd(aFKX,{cFilFKX,"15039",STR0225,"2","2","2","3","4","2","2",STR0225}) //"Remuneração de Serviços de terapêutica ocupacional"
	AAdd(aFKX,{cFilFKX,"15040",STR0226,"2","2","2","3","4","2","2",STR0227}) //"Remuneração de Serviços de trad. ou interpretação comercial" ##  "Remuneração de Serviços de tradução ou interpretação comercial"
	AAdd(aFKX,{cFilFKX,"15041",STR0228,"2","2","2","3","4","2","2",STR0228}) //"Remuneração de Serviços de urbanismo"
	AAdd(aFKX,{cFilFKX,"15042",STR0229,"2","2","2","3","4","2","2",STR0229}) //"Remuneração de Serviços de veterinária"
	AAdd(aFKX,{cFilFKX,"15043",STR0230,"2","2","2","3","4","2","2",STR0230}) //"Remuneração de Serviços de Limpeza"
	AAdd(aFKX,{cFilFKX,"15044",STR0231,"2","2","2","3","4","2","2",STR0232}) //"Remuneração de Serviços de Conservação e Manutenção" ## "Remuneração de Serviços de Conservação e Manutenção, exceto reformas e obras assemelhadas"
	AAdd(aFKX,{cFilFKX,"15045",STR0233,"2","2","2","3","4","2","2",STR0234}) //"Remuneração de Serviços de Seg, Vig. e Transp. de valores" ## "Remuneração de Serviços de Segurança, Vigilância e Transporte de valores"
	AAdd(aFKX,{cFilFKX,"15046",STR0235,"2","2","2","3","4","2","2",STR0235}) //"Remuneração de Serviços Locação de Mão de obra"
	AAdd(aFKX,{cFilFKX,"15047",STR0236,"2","2","2","3","4","2","2",STR0237}) //"Remuneração de Serviços de Assessoria Creditícia"  ## "Remuneração de Serviços de Assessoria Creditícia, Mercadológica, Gestão de Crédito, Seleção e Riscos e Administração de Contas a Pagar e a Receber"
	AAdd(aFKX,{cFilFKX,"15048",STR0238,"2","2","2","3","4","2","3",STR0238}) //"Pagamentos Referentes à Aquisição de Autopeças"
	AAdd(aFKX,{cFilFKX,"15049",STR0239,"2","2","2","3","4","2","",STR0239}) //"Pagamentos a entidades imunes ou isentas IN RFB 1.234/2012"
	AAdd(aFKX,{cFilFKX,"15050",STR0240,"2","2","2","3","4","2","4",STR0241}) //"Pagamento a título de transporte internacional" ## "Pagamento a título de transporte internacional de valores efetuado por empresas nacionais estaleiros navais brasileiros nas atividades de conservação, modernização, conversão e reparo de embarcações pré-registradas ou registradas no Registro Especial Brasileiro (REB)"
	AAdd(aFKX,{cFilFKX,"15051",STR0242,"2","2","2","3","4","2","1",STR0243}) //"Pagamento efetuado a empresas estrangeiras transp.valores" ## "Pagamento efetuado a empresas estrangeiras de transporte de valores"
	AAdd(aFKX,{cFilFKX,"15052",STR0369,"2","2","2","3","4","2","1",STR0370}) //"Demais comissões, corretagens, ou qualquer outra importância" ## "Demais comissões, corretagens, ou qualquer outra importância paga/creditada pela representação comercial ou pela mediação na realização de negócios civis e comerciais, que não se enquadrem nas situações listadas nos códigos do grupo 20" 
	AAdd(aFKX,{cFilFKX,"15099",STR0244,"2","2","2","3","4","2","2",STR0245}) //"Demais Rendimentos de serviços técnicos" ## "Demais Rendimentos de serviços técnicos, de assistência técnica, de assistência administrativa e semelhantes"
    
	// - Grupo 16 - Demais Rendimentos de Residentes ou domiciliados no Exterior
	AAdd(aFKX,{cFilFKX,"16001",STR0246,"2","2","2","2","2","3","1",STR0247}) //"Rendimentos de serviços técnicos" ## "Rendimentos de serviços técnicos, de assistência técnica, de assistência administrativa e semelhantes"
	AAdd(aFKX,{cFilFKX,"16002",STR0248,"2","2","2","2","2","3","1",STR0248}) //"Demais Rendimentos de juros e comissões"
	AAdd(aFKX,{cFilFKX,"16003",STR0249,"2","2","2","3","2","3","1",STR0249}) //"Rendimento pago a companhia de navegação aérea e marítima"
	AAdd(aFKX,{cFilFKX,"16004",STR0250,"2","2","2","2","2","3","1",STR0251}) //"Rendimento de Direito relativo a exploração de obras" ## "Rendimento de Direito relativo a exploração de obras audiovisuais estrangeiras, radiodifusão de sons e imagens e serviço de comunicação eletrônica de massa por assinatura"
	AAdd(aFKX,{cFilFKX,"16005",STR0252,"2","2","2","2","2","3","1",STR0252}) //"Demais Rendimentos de qualquer natureza"
	AAdd(aFKX,{cFilFKX,"16006",STR0253,"2","2","2","2","2","3","" ,STR0253}) //"Demais Rendimentos sujeitos à Alíquota Zero"

	// - Grupo 17 - Rendimentos pagos/creditados EXCLUSIVAMENTE por órgãos da administração federal direta, autarquias e
	//              fundações federais, empresas públicas, sociedades de economia mista e demais entidades em que a União, direta
	//				ou indiretamente detenha a maioria do capital social sujeito a voto, e que recebam recursos do Tesouro Nacional
	AAdd(aFKX,{cFilFKX,"17001",STR0254,"2","2","","3","4","2","2",STR0254}) //"Alimentação"
	AAdd(aFKX,{cFilFKX,"17002",STR0255,"2","2","","3","4","2","2",STR0255}) //"Energia elétrica"
	AAdd(aFKX,{cFilFKX,"17003",STR0256,"2","2","","3","4","2","2",STR0256}) //"Serviços prestados com emprego de materiais"
	AAdd(aFKX,{cFilFKX,"17004",STR0257,"2","2","","3","4","2","2",STR0257}) //"Construção Civil por empreitada com emprego de materiais"
	AAdd(aFKX,{cFilFKX,"17005",STR0258,"2","2","","3","4","2","2",STR0259}) //"Serviços hospitalares de que trata o art. 30" ## "Serviços hospitalares de que trata o art. 30 da Instrução Normativa RFB nº 1.234, de 11 de janeiro de 2012"
	AAdd(aFKX,{cFilFKX,"17006",STR0260,"2","2","","3","4","2","2",STR0261}) //"Transporte de cargas, exceto da natureza de rend. 17017" ## "Transporte de cargas, exceto os relacionados na natureza de rendimento 17017"
	AAdd(aFKX,{cFilFKX,"17007",STR0262,"2","2","","3","4","2","2",STR0263}) //"Serviços de auxílio diagnóstico e terapia" ## "Serviços de auxílio diagnóstico e terapia, patologia clínica, imagenologia, anatomia patológica e citopatológica, medicina nuclear e análises e patologias clínicas, exames por métodos gráficos, procedimentos endoscópicos, radioterapia, quimioterapia, diálise e oxigenoterapia hiperbárica de que trata o art. 31 e parágrafo único da Instrução Normativa RFB nº 1.234, de 2012"
	AAdd(aFKX,{cFilFKX,"17008",STR0264,"2","2","","3","4","2","2",STR0265}) //"Produtos farm, de perf, de toucador ou de higiene pessoal" ## "Produtos farmacêuticos, de perfumaria, de toucador ou de higiene pessoal adquiridos de produtor, importador, distribuidor ou varejista, exceto os relacionados nas naturezas de rendimento de 17019 a 17022"
	AAdd(aFKX,{cFilFKX,"17009",STR0266,"2","2","","3","4","2","2",STR0266}) //"Mercadorias e bens em geral"
	AAdd(aFKX,{cFilFKX,"17010",STR0267,"2","2","","3","4","2","2",STR0268}) //"Gasolina, inclusive de aviação, óleo diesel, gás liquefeito" ## "Gasolina, inclusive de aviação, óleo diesel, gás liquefeito de petróleo (GLP), combustíveis derivados de petróleo ou de gás natural, querosene de aviação (QAV), e demais produtos derivados de petróleo, adquiridos de refinarias de petróleo, de demais produtores, de importadores, de distribuidor ou varejista"
	AAdd(aFKX,{cFilFKX,"17011",STR0269,"2","2","","3","4","2","2",STR0270}) //"Álcool etílico hidratado, inclusive para fins carburantes"  ## "Álcool etílico hidratado, inclusive para fins carburantes, adquirido diretamente de produtor, importador ou do distribuidor"
	AAdd(aFKX,{cFilFKX,"17012",STR0271,"2","2","","3","4","2","2",STR0271}) //"Biodiesel adquirido de produtor ou importador"
	AAdd(aFKX,{cFilFKX,"17013",STR0272,"2","2","","3","4","2","5",STR0273}) //"Gasolina, exceto gasolina de aviação,óleo diesel e gás liq." ## "Gasolina, exceto gasolina de aviação, óleo diesel e gás liquefeito de petróleo (GLP), derivados de petróleo ou de gás natural e querosene de aviação adquiridos de distribuidores e comerciantes varejistas"
	AAdd(aFKX,{cFilFKX,"17014",STR0274,"2","2","","3","4","2","5",STR0275}) //"Álcool etílico hidratado nacional" ## "Álcool etílico hidratado nacional, inclusive para fins carburantes adquirido de comerciante varejista"
	AAdd(aFKX,{cFilFKX,"17015",STR0276,"2","2","","3","4","2","5",STR0277}) //"Biodiesel adquirido de distrib. e comerciantes varejistas" ## "Biodiesel adquirido de distribuidores e comerciantes varejistas"
	AAdd(aFKX,{cFilFKX,"17016",STR0278,"2","2","","3","4","2","5",STR0279}) //"Biodiesel adq. prod.detentor reg. selo Combustível Social" ## "Biodiesel adquirido de produtor detentor regular do selo Combustível Social, fabricado a partir de mamona ou fruto, caroço ou amêndoa de palma produzidos nas regiões norte e nordeste e no semiárido, por agricultor familiar enquadrado noPrograma Nacional de Fortalecimento da Agricultura Familiar (Pronaf)"
	AAdd(aFKX,{cFilFKX,"17017",STR0280,"2","2","","3","4","2","5",STR0281}) //"Transporte inter. de cargas efetuado por empresas nacionais" ## "Transporte internacional de cargas efetuado por empresas nacionais"
	AAdd(aFKX,{cFilFKX,"17018",STR0282,"2","2","","3","4","2","5",STR0283}) //"Estaleiros navais brasileiros nas atividades de Construção" ## "Estaleiros navais brasileiros nas atividades de Construção, conservação, modernização, conversão e reparo de embarcações préregistradas ou registradas no REB"
	AAdd(aFKX,{cFilFKX,"17019",STR0284,"2","2","","3","4","2","5",STR0285}) //"Produtos de perfumaria, de toucador e de higiene pessoal" ## "Produtos de perfumaria, de toucador e de higiene pessoal a que se refere o § 1º do art. 22 da Instrução Normativa RFB nº 1.234, de 2012, adquiridos de distribuidores e de comerciantes varejistas"
	AAdd(aFKX,{cFilFKX,"17020",STR0286,"2","2","","3","4","2","5",STR0287}) //"Produtos a que se refere o § 2º do art. 22" ## "Produtos a que se refere o § 2º do art. 22 da Instrução Normativa RFB nº 1.234, de 2012"
	AAdd(aFKX,{cFilFKX,"17021",STR0288,"2","2","","3","4","2","5",STR0289}) //"Produtos de que tratam as alíneas c a k" ## "Produtos de que tratam as alíneas c a k do inciso I do art. 5º da Instrução Normativa RFB nº 1.234, de 2012"
	AAdd(aFKX,{cFilFKX,"17022",STR0290,"2","2","","3","4","2","5",STR0291}) //"Outros produtos ou serviços beneficiados com isenção" ## "Outros produtos ou serviços beneficiados com isenção, não incidência ou alíquotas zero da Cofins e da Contribuição para o PIS/Pasep, observado o disposto no § 5º do art. 2º da Instrução Normativa RFB nº 1.234, de 2012"
	AAdd(aFKX,{cFilFKX,"17023",STR0292,"2","2","","3","4","2","2",STR0293}) //"Passagens aéreas, rodov. e demais serv. transp. passageiros" ## "Passagens aéreas, rodoviárias e demais serviços de transporte de passageiros, inclusive, tarifa de embarque, exceto transporte internacional de passageiros, efetuado por empresas nacionais"
	AAdd(aFKX,{cFilFKX,"17024",STR0294,"2","2","","3","4","2","5",STR0295}) //"Transporte intern. passageiros efetuado por empr. nacionais" ## "Transporte internacional de passageiros efetuado por empresas nacionais"
	AAdd(aFKX,{cFilFKX,"17025",STR0296,"2","2","","3","4","2","2",STR0297}) //"Serviços prestados por associações profissionais" ## "Serviços prestados por associações profissionais ou assemelhadas e cooperativas"
	AAdd(aFKX,{cFilFKX,"17026",STR0298,"2","2","","3","4","2","2",STR0299}) //"Serviços prestados por bancos comerciais" ## "Serviços prestados por bancos comerciais, bancos de investimento, bancos de desenvolvimento, caixas econômicas, sociedades de crédito, financiamento e investimento, sociedades de crédito imobiliário, e câmbio, distribuidoras de títulos e valores mobiliários, empresas de arrendamento mercantil, cooperativas de crédito, empresas de seguros privados e de capitalização e entidades abertas de previdência complementar"
	AAdd(aFKX,{cFilFKX,"17027",STR0300,"2","2","","3","4","2","2",STR0300}) //"Seguro Saúde"
	AAdd(aFKX,{cFilFKX,"17028",STR0301,"2","2","","3","4","2","2",STR0301}) //"Serviços de abastecimento de água"
	AAdd(aFKX,{cFilFKX,"17029",STR0302,"2","2","","3","4","2","2",STR0302}) //"Telefone"
	AAdd(aFKX,{cFilFKX,"17030",STR0303,"2","2","","3","4","2","2",STR0303}) //"Correio e telégrafos"
	AAdd(aFKX,{cFilFKX,"17031",STR0304,"2","2","","3","4","2","2",STR0304}) //"Vigilância"
	AAdd(aFKX,{cFilFKX,"17032",STR0305,"2","2","","3","4","2","2",STR0305}) //"Limpeza"
	AAdd(aFKX,{cFilFKX,"17033",STR0306,"2","2","","3","4","2","2",STR0306}) //"Locação de mão de obra"
	AAdd(aFKX,{cFilFKX,"17034",STR0307,"2","2","","3","4","2","2",STR0307}) //"Intermediação de negócios"
	AAdd(aFKX,{cFilFKX,"17035",STR0308,"2","2","","3","4","2","2",STR0309}) //"Administração, locação ou cessão de bens imóveis" ## "Administração, locação ou cessão de bens imóveis, móveis e direitos de qualquer natureza"
	AAdd(aFKX,{cFilFKX,"17036",STR0310,"2","2","","3","4","2","2",STR0310}) //"Factoring"
	AAdd(aFKX,{cFilFKX,"17037",STR0311,"2","2","","3","4","2","2",STR0312}) //"Plano de saúde humano, veterinário ou odontológico" ## "Plano de saúde humano, veterinário ou odontológico com valores fixos por servidor, por empregado ou por animal"
	AAdd(aFKX,{cFilFKX,"17038",STR0313,"2","2","","3","4","2","8",STR0314}) //"Pagamento efetuado a soc.cooperativa pelo forn. de bens" ## "Pagamento efetuado a sociedade cooperativa pelo fornecimento de bens, conforme art. 24, da IN 1234/12."
	AAdd(aFKX,{cFilFKX,"17039",STR0315,"2","2","","3","4","2","" ,STR0316}) //"Pagamento a Cooperativa de produção" ## "Pagamento a Cooperativa de produção, em relação aos atos decorrentes da comercialização ou da industrialização de produtos de seus associados, excetuado o previsto no §§ 1º e 2º do art. 25 da IN 1.234/12"
	AAdd(aFKX,{cFilFKX,"17040",STR0296,"2","2","","3","4","2","2",STR0317}) //"Serviços prestados por associações profissionais" ## "Serviços prestados por associações profissionais ou assemelhadas e cooperativas que envolver parcela de serviços fornecidos por terceiros não cooperados ou não associados, contratados ou conveniados, para cumprimento de contratos Serviços prestados com emprego de materiais, inclusive o de que trata a alínea C do Inciso II do art. 27 da IN 1.1234."
	AAdd(aFKX,{cFilFKX,"17041",STR0296,"2","2","","3","4","2","2",STR0318}) //"Serviços prestados por associações profissionais" ## "Serviços prestados por associações profissionais ou assemelhadas e cooperativas que envolver parcela de serviços fornecidos por terceiros não cooperados ou não associados, contratados ou conveniados, para cumprimento de contratos - Demais serviços"
	AAdd(aFKX,{cFilFKX,"17042",STR0319,"2","2","","3","4","2","2",STR0320}) //"Pagamentos efetuados às associações e às cooperativas" ## "Pagamentos efetuados às associações e às cooperativas de médicos e de odontólogos, relativamente às importâncias recebidas a título de comissão, taxa de administração ou de adesão ao plano"
	AAdd(aFKX,{cFilFKX,"17043",STR0321,"2","2","","3","4","2","2",STR0322}) //"Pagamento efetuado a sociedade cooperativa de produção" ## "Pagamento efetuado a sociedade cooperativa de produção, em relação aos atos decorrentes da comercialização ou de industrialização, pelas cooperativas agropecuárias e de pesca, de produtos adquiridos de não associados, agricultores, pecuaristas ou pescadores, para completar lotes destinados aoa cumprimento de contratos ou para suprir capacidade ociosa de suas instalações industriais, conforme § 1º do art. 25, da IN 1234/12."
	AAdd(aFKX,{cFilFKX,"17044",STR0323,"2","2","","3","4","2","7",STR0324}) //"Pagamento referente a aluguel de imóvel" ## "Pagamento referente a aluguel de imóvel quando efetuado à entidade aberta de previdência complementar sem fins lucrativos, de que trata o art 34, § 2º da IN 1.234/2012."
	AAdd(aFKX,{cFilFKX,"17045",STR0325,"2","2","","3","4","2","4",STR0326}) //"Serviços prestados por cooperativas de radiotaxi" ##  "Serviços prestados por cooperativas de radiotaxi, bem como àquelas cujos cooperados se dediquem a serviços relacionados a atividades culturais e demais cooperativas de serviços, conforme art. 5º A, da IN RFB 1.234/2012."
	AAdd(aFKX,{cFilFKX,"17046",STR0327,"2","2","","3","4","2","2",STR0328}) // "Pagamento efetuado na aquisição de bem imóvel" ## "Pagamento efetuado na aquisição de bem imóvel, quando o vendedor for pessoa jurídica que exerce a atividade de compra e venda de imóveis, ou quando se tratar de imóveis adquiridos de entidades abertas de previdência complementar com fins lucrativos, conforme art. 23, inc I, da IN RFB 1234/2012."
	AAdd(aFKX,{cFilFKX,"17047",STR0327,"2","2","","3","4","2","5",STR0329}) //"Pagamento efetuado na aquisição de bem imóvel" ## "Pagamento efetuado na aquisição de bem imóvel adquirido pertencente ao ativo não circulante da empresa vendedora, conforme art. 23, inc II da IN RFB 1234/2012."
	AAdd(aFKX,{cFilFKX,"17048",STR0327,"2","2","","3","4","2","7",STR0330}) //"Pagamento efetuado na aquisição de bem imóvel" ## "Pagamento efetuado na aquisição de bem imóvel adquirido de entidade aberta de previdência complementar sem fins lucrativos, conforme art. 23, inc III, da IN RFB 1234/2012."
	AAdd(aFKX,{cFilFKX,"17049",STR0331,"2","2","","3","4","2","2",STR0332}) //"Propaganda e Publ. em desconformidade ao art 16 da IN RFB" ## "Propaganda e Publicidade, em desconformidade ao art 16 da IN RFB 1234/2012, referente ao § 4º do citado artigo."
	AAdd(aFKX,{cFilFKX,"17050",STR0333,"2","2","","3","4","2","8",STR0334}) //"Propaganda e Publ. em conformidade ao art 16 da IN RFB" ## "Propaganda e Publicidade, em conformidade ao art 16 da IN RFB 1234/2012, referente ao § 4º do citado artigo."
	AAdd(aFKX,{cFilFKX,"17099",STR0335,"2","2","","3","4","2","2",STR0335}) //"Demais serviços"

	// - Grupo 18 - Rendimentos pagos/creditados EXCLUSIVAMENTE por órgãos, autarquias e fundações dos estados, do Distrito Federal e dos municípios
	AAdd(aFKX,{cFilFKX,"18001",STR0336,"2","2","","3","4","2","8",STR0337}) //"Fornecimento de bens, nos termos do art.33 da Lei nº 10.833" ## "Fornecimento de bens, nos termos do art.33 da Lei nº 10.833, de 2003"
	AAdd(aFKX,{cFilFKX,"18002",STR0338,"2","2","","3","4","2","8",STR0339}) //"Prestação de serviços em geral, nos termos do art. 33" ## "Prestação de serviços em geral, nos termos do art. 33 da Lei nº 10.833, de 2003"
	AAdd(aFKX,{cFilFKX,"18003",STR0340,"2","2","","3","4","2","6",STR0341}) //"Transporte internacional de cargas ou de passageiros" ## "Transporte internacional de cargas ou de passageiros efetuados por empresas nacionais, aos estaleiros navais brasileiros e na aquisição de produtos isentos ou com Alíquota zero da Cofins e Pis/Pasep, conforme art. 4º, da IN SRF nº 475 de 2004."
	AAdd(aFKX,{cFilFKX,"18004",STR0342,"2","2","","3","4","2","3",STR0343}) //"Pagamentos efetuados às cooperativas" ## "Pagamentos efetuados às cooperativas, em relação aos atos cooperativos, conforme art. 5º, da IN SRF nº 475 de 2004."
	AAdd(aFKX,{cFilFKX,"18005",STR0344,"2","2","","3","4","2","6",STR0345}) //"Aquisição de imóvel pertencente a ativo permanente" ## "Aquisição de imóvel pertencente a ativo permanente da empresa vendedora, conforme art. 19, II, da IN SRF nº 475 de 2004."
	AAdd(aFKX,{cFilFKX,"18006",STR0346,"2","2","","3","4","2","3",STR0347}) //"Pagamentos efetuados às sociedades cooperativas" ## "Pagamentos efetuados às sociedades cooperativas, pelo fornecimento de bens ou serviços, conforme art. 24, II, da IN SRF nº 475 de 2004."
	AAdd(aFKX,{cFilFKX,"18007",STR0348,"2","2","","3","4","2","" ,STR0349}) //"Pagamentos efetuados à sociedade cooperativa de produção" ## "Pagamentos efetuados à sociedade cooperativa de produção, em relação aos atos decorrentes da comercialização ou industrialização de produtos de seus associados, conforme art. 25, da IN SRF nº 475 de 2004."
	AAdd(aFKX,{cFilFKX,"18008",STR0350,"2","2","","3","4","2","8",STR0351}) //"Pagamentos efetuados às cooperativas de trabalho" ## "Pagamentos efetuados às cooperativas de trabalho, pela prestação de serviços pessoais prestados pelos cooperados, nos termos do art. 26, da IN SRF nº 475 de 2004."

	// - Grupo 19 - Pagamento a Beneficiário não Identificado Uso exclusivo para o evento R-4040
	AAdd(aFKX,{cFilFKX,"19001",STR0352,"2","2","","4","3","2","1",STR0353}) //"Pagamento de remuneração indireta a Benef. não identificado" ## "Pagamento de remuneração indireta a Beneficiário não identificado"
	AAdd(aFKX,{cFilFKX,"19009",STR0354,"2","2","","4","3","2","1",STR0354}) //"Pagamento a Beneficiário não identificado"

	// - Grupo 20 - Rendimentos a Pessoa Jurídica Retenção no recebimento
	AAdd(aFKX,{cFilFKX,"20001",STR0355,"2","2","2","3","4","2","1",STR0355}) //"Rendimento de Serviços de propaganda e publicidade"
	AAdd(aFKX,{cFilFKX,"20002",STR0356,"2","2","2","3","4","2","1",STR0357}) //"Importâncias a título de comissões e corretagens relativas" ## "Importâncias a título de comissões e corretagens relativas a colocação ou negociação de títulos de renda fixa"
	AAdd(aFKX,{cFilFKX,"20003",STR0356,"2","2","2","3","4","2","1",STR0358}) //"Importâncias a título de comissões e corretagens relativas" ## "Importâncias a título de comissões e corretagens relativas a operações realizadas em Bolsas de Valores e em Bolsas de Mercadorias"
	AAdd(aFKX,{cFilFKX,"20004",STR0356,"2","2","2","3","4","2","1",STR0359}) //"Importâncias a título de comissões e corretagens relativas" ## "Importâncias a título de comissões e corretagens relativas a distribuição de emissão de valores mobiliários, quando a pessoa jurídica atuar como agente da companhia emissora"
	AAdd(aFKX,{cFilFKX,"20005",STR0356,"2","2","2","3","4","2","1",STR0360}) //"Importâncias a título de comissões e corretagens relativas" ## "Importâncias a título de comissões e corretagens relativas a operações de câmbio"
	AAdd(aFKX,{cFilFKX,"20006",STR0356,"2","2","2","3","4","2","1",STR0361}) //"Importâncias a título de comissões e corretagens relativas" ## "Importâncias a título de comissões e corretagens relativas a vendas de passagens, excursões ou viagens"
	AAdd(aFKX,{cFilFKX,"20007",STR0356,"2","2","2","3","4","2","1",STR0362}) //"Importâncias a título de comissões e corretagens relativas" ## "Importâncias a título de comissões e corretagens relativas a administração de cartões de crédito"
	AAdd(aFKX,{cFilFKX,"20008",STR0356,"2","2","2","3","4","2","1",STR0363}) //"Importâncias a título de comissões e corretagens relativas" ## "Importâncias a título de comissões e corretagens relativas a prestação de serviços de distribuição de refeições pelo sistema de refeições-convênio"
	AAdd(aFKX,{cFilFKX,"20009",STR0356,"2","2","2","3","4","2","1",STR0364}) //"Importâncias a título de comissões e corretagens relativas" ## "Importâncias a título de comissões e corretagens relativas a prestação de serviço de administração de convênios"
	AAdd(aFKX,{cFilFKX,"20010",STR0365,"2","2","2","3","4","2","1",STR0366}) //"Demais Importâncias a título de comissões, corretagens" ## "Demais Importâncias a título de comissões, corretagens, ou qualquer outra importância paga/creditada pela representação comercial ou pela mediação na realização de negócios civis e comerciais"

	// Dedução Grupo 10 - Rendimento do Trabalho e da Previdência Social
	AAdd(aFKZ,{cFilFKX,"10001","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10001","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10001","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10001","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"10001","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10001","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"10002","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10002","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10002","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"10003","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10003","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10003","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"10004","1","5 ","  "})
	
	AAdd(aFKZ,{cFilFKX,"10005","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10005","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10005","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10005","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10005","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"10006","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"10006","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10006","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10006","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10006","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"10008","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"10008","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"10008","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"10008","1","7 ","  "})

	// Dedução Grupo 11 - Rendimento decorrente de Decisão Judicial
	AAdd(aFKZ,{cFilFKX,"11001","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"11001","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"11001","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"11002","1","1 ","  "})

	AAdd(aFKZ,{cFilFKX,"11003","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"11003","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"11003","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"11003","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"11003","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"11003","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"11004","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"11004","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"11004","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"11004","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"11004","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"11004","1","7 ","  "})

	// Dedução Grupo 12 - Rendimento do Capital
	AAdd(aFKZ,{cFilFKX,"12009","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"12009","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"12009","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"12009","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"12009","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"12010","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"12010","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"12010","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"12010","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"12010","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"12011","1","2 ","  "})
	AAdd(aFKZ,{cFilFKX,"12011","1","3 ","  "})
	AAdd(aFKZ,{cFilFKX,"12011","1","4 ","  "})
	AAdd(aFKZ,{cFilFKX,"12011","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"12011","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"12045","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"12045","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"12045","1","7 ","  "})

	// Dedução Grupo 13 - Rendimento de Direitos (Royalties)
	AAdd(aFKZ,{cFilFKX,"13001","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13001","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13001","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13002","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13002","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13002","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13003","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13003","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13003","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13004","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13004","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13004","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13005","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13005","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13005","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13006","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13006","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13006","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13007","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13007","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13007","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13008","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13008","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13008","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13009","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13009","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13009","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13010","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13010","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13010","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13011","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13011","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13011","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13012","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13012","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13012","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13013","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13013","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13013","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13014","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13014","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13014","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13015","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13015","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13015","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13016","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13016","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13016","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13017","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13017","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13017","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13018","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13018","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13018","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13019","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13019","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13019","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13020","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13020","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"13021","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13021","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"13022","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13022","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"13023","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13023","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"13025","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13025","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13025","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13026","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13026","1","5 ","  "})

	AAdd(aFKZ,{cFilFKX,"13098","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13098","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13098","1","7 ","  "})

	AAdd(aFKZ,{cFilFKX,"13099","1","1 ","  "})
	AAdd(aFKZ,{cFilFKX,"13099","1","5 ","  "})
	AAdd(aFKZ,{cFilFKX,"13099","1","7 ","  "})


	// Isenção Grupo 10 - Rendimento do Trabalho e da Previdência Social
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","5 "})
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"10001","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"10002","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"10002","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"10002","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"10002","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"10002","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"10003","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"10003","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"10003","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"10003","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"10003","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"10005","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"10005","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"10005","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"10006","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"10006","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"10006","2","  ","99"})

	// Isenção Grupo 11 - Rendimento decorrente de Decisão Judicial
	AAdd(aFKZ,{cFilFKX,"11001","2","  ","10"})
	AAdd(aFKZ,{cFilFKX,"11001","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"11002","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"11002","2","  ","10"})

	AAdd(aFKZ,{cFilFKX,"11003","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"11003","2","  ","10"})

	// Isenção Grupo 12 - Rendimento do Capital
	AAdd(aFKZ,{cFilFKX,"12002","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12002","2","  ","11"})

	AAdd(aFKZ,{cFilFKX,"12003","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12003","2","  ","11"})

	AAdd(aFKZ,{cFilFKX,"12004","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12004","2","  ","11"})

	AAdd(aFKZ,{cFilFKX,"12005","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12005","2","  ","11"})

	AAdd(aFKZ,{cFilFKX,"12006","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12006","2","  ","11"})

	AAdd(aFKZ,{cFilFKX,"12007","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12007","2","  ","11"})

	AAdd(aFKZ,{cFilFKX,"12009","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"12009","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12009","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12009","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"12010","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"12010","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12010","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12010","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"12011","2","  ","1 "})
	AAdd(aFKZ,{cFilFKX,"12011","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12011","2","  ","7 "})
	AAdd(aFKZ,{cFilFKX,"12011","2","  ","99"})

	AAdd(aFKZ,{cFilFKX,"12012","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12012","2","  ","7 "})

	AAdd(aFKZ,{cFilFKX,"12013","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12013","2","  ","7 "})

	AAdd(aFKZ,{cFilFKX,"12014","2","  ","6 "})
	AAdd(aFKZ,{cFilFKX,"12014","2","  ","7 "})

	// Isenção Grupo 13 - Rendimento de direitos
	AAdd(aFKZ,{cFilFKX,"13010","2","  ","2 "})
	AAdd(aFKZ,{cFilFKX,"13010","2","  ","3 "})
	AAdd(aFKZ,{cFilFKX,"13010","2","  ","4 "})
	AAdd(aFKZ,{cFilFKX,"13010","2","  ","8 "})
	AAdd(aFKZ,{cFilFKX,"13010","2","  ","99"})


	DbSelectArea("FKX")
	FKX->(DbSetOrder(1)) //FKX_FILIAL + FKX_CODIGO
	FKX->(DbGoTop())

	For nI := 1 To Len(aFKX)
		If !FKX->(DbSeek(aFKX[nI,1] + aFKX[nI,2]))
			FKX->(RecLock("FKX",.T.))
				FKX->FKX_FILIAL := aFKX[nI,1]
				FKX->FKX_CODIGO	:= aFKX[nI,2]
				FKX->FKX_DESCR	:= aFKX[nI,3]
				FKX->FKX_FCI	:= aFKX[nI,4]
				FKX->FKX_DECSAL	:= aFKX[nI,5]
				FKX->FKX_RRA	:= aFKX[nI,6]
				FKX->FKX_EXTPF 	:= aFKX[nI,7]
				FKX->FKX_EXTPJ 	:= aFKX[nI,8]
				FKX->FKX_TPDECL	:= aFKX[nI,9]			
				FKX->FKX_TRIBUT	:= aFKX[nI,10]
				FKX->FKX_DESEXT	:= aFKX[nI,11]
			FKX->(MsUnlock())
		EndIf
	Next nI

	DbSelectArea("FKZ")
	FKZ->(DbSetOrder(1)) //FKZ_FILIAL + FKZ_CODIGO + FKZ_DEDISE + FKZ_DEDUCA + FKZ_ISENCA
	FKZ->(DbGoTop())

	For nI := 1 To Len(aFKZ)
		If !FKZ->( DbSeek( aFKZ[nI,1] + aFKZ[nI,2] + aFKZ[nI,3] + aFKZ[nI,4] + aFKZ[nI,5] ) )
			FKZ->( RecLock("FKZ",.T.) )
				FKZ->FKZ_FILIAL	:= aFKZ[nI,1]
				FKZ->FKZ_CODIGO	:= aFKZ[nI,2]
				FKZ->FKZ_DEDISE	:= aFKZ[nI,3]
				FKZ->FKZ_DEDUCA	:= aFKZ[nI,4]
				FKZ->FKZ_ISENCA	:= aFKZ[nI,5]
			FKZ->( MsUnlock() )
		EndIf
	Next nI

	RestArea(aAreaFKZ)
	RestArea(aAreaFKX)
	RestArea(aAreaAtu)

Return()
