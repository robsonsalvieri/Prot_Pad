#INCLUDE 'Totvs.ch'
#INCLUDE 'FWMVCDEF.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA526
Cadastro de acondicionamentos

@type   Function

@author Eduardo Mussi
@since  03/12/2024

@return Nil
/*/
//-------------------------------------------------------------------
Function SGAA526()

	Local oBrowse

	// Processamento responsável por adicionar os primeiros registros da tabela TH7.
	FWMsgRun( , { | lEnd |  fLoad() }, 'Aguarde', 'Carregando informações...' ) 

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'TH7' )
	oBrowse:SetMenuDef( 'SGAA526' )
	oBrowse:SetDescription( 'Acondicionamentos' )
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@type   Function

@author Eduardo Mussi
@since  03/12/2024

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
Return FWMVCMenu( 'SGAA526' ) // Inicializa MenuDef com todas as opções

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados TH7

@type   Function

@author Eduardo Mussi
@since  03/12/2024

@return Nil
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel     := MPFormModel():New( 'SGAA526', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/ ) // Cria o objeto do Modelo de Dados
	Local oStructTH7 := FWFormStruct( 1, 'TH7' ) // Cria objeto com a estrutura da TH7

	// Adiciona ao modelo a estrutura da TH7
	oModel:AddFields( 'SGAA526_TH7', Nil, oStructTH7, /*bPre*/, /*bPost*/, /*bLoad*/ )

	oModel:SetDescription( 'Acondicionamentos' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Responsável pela criação da interface

@type   Function

@author Eduardo Mussi
@since  03/12/2024

@return Nil
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel('SGAA526')
	Local oView  := FWFormView():New()

	// Objeto do model que irá associonar a View
	oView:SetModel( oModel )

	// Adiciona na view um item semelhante à antiga enchoice
	oView:AddField( 'SGAA526_TH7' , FWFormStruct( 2, 'TH7' ), /*cLinkID*/ )	

	// Cria um 'box' na horizontal para receber os dados
	oView:CreateHorizontalBox( 'MASTER', 100, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

	// Define os dados da view através de associação
	oView:SetOwnerView( 'SGAA526_TH7', 'MASTER' )
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ProtheusDoc
Inserir descrição

@type   Function

@author Eduardo Mussi
@since  03/12/2024
@param  cField, Tipagem, Descrição

@return Lógico, Define se poderá prosseguir com a operação
/*/
//-------------------------------------------------------------------
Function SGAA526VLD( cField )

	Local lReturn := .T.

	If cField == 'TH7_CODIGO'
		
		// Verifica se existe o código na base
		If NGIFDBSEEK( 'TH7', M->TH7_CODIGO, 1 )
		
			Help( ' ', 1, 'JAEXISTINF' )
			lReturn := .F.

		EndIf

	EndIf


Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fLoad
Função responsável pela carga inicial da tabela TH7

@type   Function

@author Eduardo Mussi
@since  10/12/2024

/*/
//-------------------------------------------------------------------
Static Function fLoad()

	Local aTH7    := {}
	Local cBranch := FwxFilial( 'TH7' )
	Local nTH7
	
	dbSelectArea( 'TH7' )
	dbSetOrder( 1 )
	If !MsSeek( cBranch + '3' )

		aAdd( aTH7, { '3', 'CONTEINER' } )
		aAdd( aTH7, { '4', 'CAÇAMBA ABERTA' } )
		aAdd( aTH7, { '5', 'CAÇAMBA FECHADA' } )
		aAdd( aTH7, { '8', 'GRANEL' } )
		aAdd( aTH7, { '9', 'TAMBOR' } )
		aAdd( aTH7, { '11', 'TANQUE' } )
		aAdd( aTH7, { '13', 'OUTROS' } )
		aAdd( aTH7, { '23', 'CILINDRO' } )
		aAdd( aTH7, { '21', 'CAIXA' } )
		aAdd( aTH7, { '22', 'CAIXA DE PAPELÃO' } )
		aAdd( aTH7, { '24', 'FARDO' } )
		aAdd( aTH7, { '25', 'PALETE' } )
		aAdd( aTH7, { '2', 'SACO PLÁSTICO' } )
		aAdd( aTH7, { '14', 'BOMBONA PLÁSTICA' } )
		aAdd( aTH7, { '26', 'BIG BAG' } )

		For nTH7 := 1 To Len( aTH7 )

			If !MsSeek( cBranch + aTH7[ nTH7, 1 ] )
				
				RecLock( 'TH7', .T. )
					TH7->TH7_FILIAL := cBranch
					TH7->TH7_CODIGO := aTH7[ nTH7, 1 ]
					TH7->TH7_DESCRI := aTH7[ nTH7, 2 ]
				TH7->( MsUnLock() )

			EndIf

		Next nTH7

	EndIf

	FWFreeArray( aTH7 )

Return
