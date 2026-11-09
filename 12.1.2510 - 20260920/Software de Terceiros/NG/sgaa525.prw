#INCLUDE 'Totvs.ch'
#INCLUDE 'FWMVCDEF.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA525
Cadastro de usuários SINIR

@type   Function

@author Eduardo Mussi
@since  10/12/2024

@return Nil
/*/
//-------------------------------------------------------------------
Function SGAA525()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'TH5' )
	oBrowse:SetMenuDef( 'SGAA525' )
	oBrowse:SetDescription( 'Usuários SINIR' )
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@type   Function

@author Eduardo Mussi
@since  10/12/2024

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
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( 'SGAA525' ) // Inicializa MenuDef com todas as opções

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados TH5

@type   Function

@author Eduardo Mussi
@since  10/12/2024

@return Nil
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	
	Local bCommit   := { | oModel | CommitInfo( oModel ) }
	Local oModel     := MPFormModel():New( 'SGAA525', /*bPre*/, /*bPost*/, bCommit/*bCommit*/, /*bCancel*/ ) // Cria o objeto do Modelo de Dados

	// Adiciona ao modelo a estrutura da TH5
	oModel:AddFields( 'SGAA525_TH5', Nil, FWFormStruct( 1, 'TH5' ), /*bPre*/, /*bPost*/, /*bLoad*/ )
	oModel:AddGrid( 'SGAA525_TH6', 'SGAA525_TH5', FWFormStruct( 1, 'TH6',,, .T. ) )
	oModel:SetRelation( 'SGAA525_TH6', { { 'TH6_FILIAL', 'FwxFilial( "TH6" )' }, { 'TH6_CODIGO', 'TH5_CODIGO' } }, ( 'TH6' )->( IndexKey( 1 ) ) )
	oModel:SetDescription( 'Usuários SINIR' )

	// Define que o campo TH6_CODSIN não poderá ter registros com o mesmo código
	oModel:GetModel( 'SGAA525_TH6' ):SetUniqueLine( { 'TH6_CODTH8', 'TH6_CODSIN' } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Responsável pela criação da interface

@type   Function

@author Eduardo Mussi
@since  10/12/2024

@return Nil
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel     := FWLoadModel( 'SGAA525' )
	Local oView      := FWFormView():New()
	Local oStructTH6 := FWFormStruct( 2, 'TH6',,, .T. )

	// Objeto do model que irá associonar a View
	oView:SetModel( oModel )

	// Adiciona na view um item semelhante à antiga enchoice
	oView:AddField( 'VIEW_TH5', FWFormStruct( 2, 'TH5' ), 'SGAA525_TH5' )	
	oView:AddGrid( 'VIEW_TH6' , oStructTH6              , 'SGAA525_TH6' )

	// Cria um 'box' na horizontal para receber os dados
	oView:CreateHorizontalBox( 'SUPERIOR', 30, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
	oView:CreateHorizontalBox( 'INFERIOR', 70, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
	
	// Define os dados da view através de associação
	oView:SetOwnerView( 'VIEW_TH5', 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_TH6', 'INFERIOR' )
	
	// Remove botão salvar e criar novo
	oView:SetCloseOnOk( { || .T. } )

	oStructTH6:RemoveField( 'TH6_CODIGO' )
	oStructTH6:RemoveField( 'TH5_CODIGO' )
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CommitInfo
Realiza o Commit dos dados

@type   Function

@author Eduardo Mussi
@since  16/12/2024
@param  oModel, Objeto, Objeto com o modelod e dados

@return Lógico, Define se foi feito o commit
/*/
//-------------------------------------------------------------------
Static Function CommitInfo( oModel )
	
	Local aCrip := {}

	// Realiza criptografia do campo de senha.	
	If ( oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4 ) .And.;
		TH5->TH5_SENHAC != oModel:GetValue( 'SGAA525_TH5', 'TH5_SENHAC' ) // Somente grava a senha caso seja diferente do valor salvo, se faz necessário para que não criptografe a senha já criptografada
		
		aCrip  := AESEncrypt( 0, AllTrim( oModel:GetValue( 'SGAA525_TH5', 'TH5_SENHAC' ) ) )
		oModel:SetValue( 'SGAA525_TH5', 'TH5_SENHAC', aCrip[ 2 ] + 'p.s' + aCrip[ 3 ] + 'p.s' + aCrip[ 4 ] )

	EndIf

	FwFreeArray( aCrip )

Return FwFormCommit( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA525VLD
Inserir descrição

@type   Function

@author Eduardo Mussi
@since  10/12/2024
@param  cField, Tipagem, Descrição

@return Lógico, Define se poderá prosseguir com a operação
/*/
//-------------------------------------------------------------------
Function SGAA525VLD( cField )

	Local oModel  := FWModelActive()
	Local lReturn := .T.
	
	If cField == 'TH5_CPF'
		
		lReturn := !EMpty( oModel:GetValue( 'SGAA525_TH5', 'TH5_CPF' ) ) .And. ChkCpf( oModel:GetValue( 'SGAA525_TH5', 'TH5_CPF' ) )
	
	ElseIf cField == 'TH5_MAT'

		If Empty( Posicione( 'SRA', 1, FwxFilial( 'SRA' ) + oModel:GetValue( 'SGAA525_TH5', 'TH5_MAT' ), 'RA_MAT' ) )
			
			Help( ' ', 1, 'REGNOIS' )
			lReturn := .F.

		Else
			
			If Empty( SRA->RA_CIC )
				
				Help( '', , 'Atenção', NIL, 'Funcionário informado não possui CPF. Apenas poderão ser escolhidos funcionários que posssuem CPF em seu cadastro.', 1, 0 )
				lReturn := .F.

			EndIf

		EndIf

		// responsável por limpar os campos antes de inserir um novo conteúdo( tratamento para when do campo )
		oModel:SetValue( 'SGAA525_TH5', 'TH5_NOME', Space( FwTamSX3( 'TH5_NOME' )[ 1 ] ) )
		oModel:SetValue( 'SGAA525_TH5', 'TH5_CPF', Space( FwTamSX3( 'TH5_CPF' )[ 1 ] ) )

	ElseIf cField == 'TH5_CODUSR'

		lReturn := UsrExist( oModel:GetValue( 'SGAA525_TH5', 'TH5_CODUSR' ) ) 

	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA525GAT
Função responsável por popular os campos gatilhos

@type   Function

@author Eduardo Mussi
@since  11/12/2024

@param  cDomain  , Caracter, Campo que está chamando o gatilho
@param  cContDom, Caracter, Campo de contra dominio que receberá o valor de retorno do processo.

@return Indefinido, retorna o conteúdo a ser inserido no campo

/*/
//-------------------------------------------------------------------
Function SGAA525GAT( cDomain, cContDom )
	
	Local oModel  := FWModelActive()
	Local xReturn

	If cDomain == 'TH5_MAT' .And. cContDom == 'TH5_NOME'
		
		xReturn := Posicione( 'SRA', 1, FwxFilial( 'SRA' ) + oModel:GetValue( 'SGAA525_TH5', 'TH5_MAT' ), 'RA_NOME' )
		
	ElseIf cDomain == 'TH5_MAT' .And. cContDom == 'TH5_CPF'
		
		xReturn := Posicione( 'SRA', 1, FwxFilial( 'SRA' ) + oModel:GetValue( 'SGAA525_TH5', 'TH5_MAT' ), 'RA_CIC' )
	
	ElseIf cDomain == 'TH5_USUPRO' .And. cContDom == 'TH5_NOMPRO'

		xReturn := FWSFALLUSERS( { oModel:GetValue( 'SGAA525_TH6', 'TH6_USUPRO' ) },{ 'USR_NOME' } )[ 1, 2 ]
	
	ElseIf cDomain == 'TH6_CODTH8' .And. cContDom == 'TH6_DESCRI'

		xReturn := Posicione( 'TH8', 1, FwxFilial( 'TH8' ) + oModel:GetValue( 'SGAA525_TH6', 'TH6_CODTH8' ), 'TH8_NOME' )

	EndIf

Return xReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA525WHE
Função responsável por avaliar se um campo pode ser editado

@type   Function

@author Eduardo Mussi
@since  11/12/2024
@param  cField, caracter, Campo a ser verificado

@return Lógico, define se o campo poderá ser editado
/*/
//-------------------------------------------------------------------
Function SGAA525WHE( cField )
	
	Local oModel  := FWModelActive()
	Local lReturn := .T. 
	
	If oModel:GetOperation() != 3
		
		If cField != 'TH6_USUPRO'
		
			lReturn :=  .F.

		EndIf

	Else

		If cField == 'TH5_CODIGO' .Or. cField == 'TH6_NOMPRO'

			lReturn :=  .F.

		ElseIf !Empty( oModel:GetValue( 'SGAA525_TH5', 'TH5_MAT' ) ) .And. ( cField == 'TH5_CODIGO' .Or. cField == 'TH5_NOME' .Or. cField == 'TH5_CPF' )
		
			lReturn :=  .F.

		EndIf

	EndIf

Return lReturn
 
//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA525REL
Responsável por inserir um valor inicial no campo

@type   Function

@author Eduardo Mussi
@since  11/12/2024
@param  cField, caracter, Campo a ser iniciado

@return Indefinido, retorna o valor do campo a ser iniciado
/*/
//-------------------------------------------------------------------
Function SGAA525REL( cField )

	//Local oModel  := FWModelActive()

	Local xReturn

	If cField == 'TH5_CODIGO'
		
		xReturn := GetSXENUM( 'TH5', 'TH5_CODIGO' )

	ElseIf cField == 'TH6_CODIGO'

		xReturn := GetSXENUM( 'TH6', 'TH6_CODIGO' )
	
	ElseIf cField == 'TH6_DESCRI'

		xReturn := Space( FwTamSX3( 'TH6_DESCRI' )[ 1 ] )
	//ElseIf cField == 'TH5_NOMPRO'
//
	//	xReturn := FWSFALLUSERS( { oModel:GetValue( 'SGAA525_TH6', 'TH6_USUPRO' ) },{ 'USR_NOME' } )[ 1, 2 ]
	
	EndIf

Return xReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA525INB
Inserir descrição

@type   Function

@author Eduardo Mussi
@since  XX/XX/XXXX
@param  Variavel, Tipagem, Descrição

@return Tipagem, descrição
/*/
//-------------------------------------------------------------------
Function SGAA525INB( cField )
	
	//Local oModel  := FWModelActive()
	Local xReturn := ''

	If cField == 'TH6_NOMPRO'

		If !Empty( TH6->TH6_USUPRO )
		
			xReturn := FWSFALLUSERS( { TH6->TH6_USUPRO },{ 'USR_NOME' } )[ 1, 2 ]

		EndIf

	EndIf

Return xReturn 
