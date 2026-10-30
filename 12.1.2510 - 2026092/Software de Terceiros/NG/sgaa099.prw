#INCLUDE 'Totvs.ch'
#INCLUDE 'FWMVCDEF.ch'

Static cSendMTR
Static lCanMTRSin
Static lRetMTRSin
Static lIntFat

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA099
Cadastro de Manifesto

@type   Function

@author Eduardo Mussi
@since  12/02/2025

@return Nil
/*/
//-------------------------------------------------------------------
Function SGAA099()

	Local oBrowse
	
	Private cRetPriF3 := ''
	Private cRetSegF3 := ''
	Private cSINFun   := 'SGAA099F3()'
	Private cSINRet1  := 'SGAA099F3R(1)'
	Private cSINRet2  := 'SGAA099F3R(2)'
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( 'TAT' )
	oBrowse:SetMenuDef( 'SGAA099' )
	oBrowse:SetDescription( 'Manifestos' )
	oBrowse:Activate()
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções de menu

@type   Function

@author Eduardo Mussi
@since  12/02/2025

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

	Local aRotina := FWMVCMenu( 'SGAA099' ) // Inicializa MenuDef com todas as opções

	//aAdd( aRotina, { 'Retorna Manifesto', 'ManReturn()', 0 , 4 } )
	aAdd( aRotina, { 'Enviar p/ Sinir', 'Processa( { || SendForSin() } )', 0 , 3 } )
	aAdd( aRotina, { 'Cancelamento', 'Processa( { || CanMTRSin() } )', 0 , 4 } )
	aAdd( aRotina, { 'Download manifesto', 'ManPdfDown()', 0 , 6 } )
	aAdd( aRotina, { 'Carga Inicial Códigos Ibama', 'Processa( { || ImpCodIb() } )', 0, 3 } )

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ManReturn
Responsável por chamar a tela de retorno do manifesto

@type   Function

@author Eduardo Mussi
@since  07/07/2025

@return Nil
/*/
//-------------------------------------------------------------------
Function ManReturn()

	Local oModRet099 := FWLoadModel( 'SGAA099' )
	
	oModRet099:SetOperation( 4 )
	oModRet099:Activate() 

	FWExecView( 'Retorna Manifesto', 'SGAA099', 4,,,,,,,,, oModRet099 )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SendForSin
Envio do MTR cadastrado somente no protheus para cadastro no SINIR

@type   Function

@author Eduardo Mussi
@since  09/12/2025

@return Nil
/*/
//-------------------------------------------------------------------
Function SendForSin()

	If TAT->( RecCount() ) > 0
		
		If TAT->TAT_STATUS == '1' .And. Empty( TAT->TAT_NUMMTR )

			SendMTRSin( FWModelActive() )

		Else

			Help( ' ', 1, 'Atenção',, 'Esse Manifesto não pode ser enviado para o Sinir.', 1, 0,,,,,, { 'Para que o Manifesto possa ser enviado ao Sinir, o campo ' + Rtrim( FwX3Titulo( 'TAT_STATUS' ) ) + ' deverá estar como "1 - Em Elaboração" e o campo ' + Rtrim( FwX3Titulo( 'TAT_NUMMTR' ) ) + ' não deverá ser informado.' } )

		EndIf

	Else

		Help( ' ', 1, 'Atenção',, 'Não há dados para envio.', 1, 0 )

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ManPdfDown
Executa processo de baixar e salvar o manifesto em PDF.

@type   Function

@author Eduardo Mussi
@since  03/07/2025

@return Nil
/*/
//-------------------------------------------------------------------
Function ManPdfDown()
	
	ManDownDoc( TAT->TAT_NUMMTR )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados TAT

@type   Function

@author Eduardo Mussi
@since  12/02/2025

@return Nil
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	
	Local bCommit    := { | oModel | CommitInfo( oModel ) }
	Local oModel     := MPFormModel():New( 'SGAA099', /*bPre*/, {|oModel| fMPosValid( oModel ) }/*bPost*/, bCommit/*bCommit*/, /*bCancel*/ ) // Cria o objeto do Modelo de Dados
	Local oStructTAT := FWFormStruct( 1, 'TAT' )

	cSendMTR := SuperGetMV( 'MV_NGENVSN', .F., '3' )
	lIntFat  := SuperGetMv( 'MV_NGSGAFA', .F., '2' ) == '1'

	// Adiciona ao modelo a estrutura da TAT
	oModel:AddFields( 'SGAA099_TAT', Nil, oStructTAT, /*bPre*/, /*bPost*/, /*bLoad*/ )
	oModel:AddGrid( 'SGAA099_TAY', 'SGAA099_TAT', FWFormStruct( 1, 'TAY',,, .T. ) )
	oModel:SetRelation( 'SGAA099_TAY', { { 'TAY_FILIAL', 'FwxFilial( "TAY" )' }, { 'TAY_CODCOM', 'TAT_CODCOM' } }, ( 'TAY' )->( IndexKey( 1 ) ) )
	oModel:SetDescription( 'Manifesto' )

	// Define que o campo TAY_CODRES não poderá ter registros com o mesmo código
	oModel:GetModel( 'SGAA099_TAY' ):SetUniqueLine( { 'TAY_IBAMA' } )

	// Verifica se permite realizar a operação selecionada
	oModel:SetVldActivate( { | oModel | fMVldAct( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Responsável pela criação da interface

@type   Function

@author Eduardo Mussi
@since  12/02/2025

@return Nil
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel     := FWLoadModel( 'SGAA099' )
	Local oView      := FWFormView():New()
	Local oStructTAT := FWFormStruct( 2, 'TAT' )
	Local oStructTAY := FWFormStruct( 2, 'TAY',,, .T. )

	//lCanMTRSin := IsInCallStack( 'CanMTRSin' )
	//lRetMTRSin := IsInCallStack( 'ManReturn' )

	// Objeto do model que irá associonar a View
	oView:SetModel( oModel )

	// Remoção dos campos de NF caso o ambiente não possua integração com Faturamento
	If !lIntFat
		oStructTAT:RemoveField( 'TAT_CONPAG' )
		oStructTAT:RemoveField( 'TAT_NUM'    )
		oStructTAT:RemoveField( 'TAT_MENNOT' )
		oStructTAT:RemoveField( 'TAT_DESPAD' )
		oStructTAT:RemoveField( 'TAT_VOLUM1' )
		oStructTAT:RemoveField( 'TAT_PBRUTO' )
		oStructTAT:RemoveField( 'TAT_FORNNF' )
		oStructTAT:RemoveField( 'TAT_NOMDES' )
		oStructTAT:RemoveField('TAT_PREVEN'  )
		oStructTAT:RemoveField('TAT_MENPAD'  )
		oStructTAT:RemoveField('TAT_PESOL'   )
		oStructTAT:RemoveField('TAT_TPDEST'  )
		oStructTAT:RemoveField('TAT_LOJANF'  )
	EndIf

	// Somente serão apresentados esses campos quando for executado o processo de retorno/recebimento do manifesto
	If !lRetMTRSin
		oStructTAT:RemoveField( 'TAT_DTEREC' )
		oStructTAT:RemoveField( 'TAT_RESPRE' )
		oStructTAT:RemoveField( 'TAT_OBSDES' )
		oStructTAY:RemoveField( 'TAY_QTDREC' )
		oStructTAY:RemoveField( 'TAY_JUSTIF' )
		oStructTAY:RemoveField( 'TAY_CORRET' )
	EndIf

	// Remove o campo de ser visualizado para posteriormente adicionar o valor ao salvar
	oStructTAY:RemoveField( 'TAY_CODCOM' )

	// Adiciona na view um item semelhante à antiga enchoice
	oView:AddField( 'VIEW_TAT', oStructTAT, 'SGAA099_TAT' )	
	oView:AddGrid( 'VIEW_TAY' , oStructTAY, 'SGAA099_TAY' )

	// Cria um 'box' na horizontal para receber os dados
	oView:CreateHorizontalBox( 'SUPERIOR', 70, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
	oView:CreateHorizontalBox( 'INFERIOR', 30, /*cIDOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
	
	// Define os dados da view através de associação
	oView:SetOwnerView( 'VIEW_TAT', 'SUPERIOR' )
    oView:SetOwnerView( 'VIEW_TAY', 'INFERIOR' )
	
	// Remove botão salvar e criar novo
	oView:SetCloseOnOk( { || .T. } )

	If lCanMTRSin
		
		oStructTAT:SetProperty( 'TAT_JUSCAN', MODEL_FIELD_OBRIGAT, .T. )

		// Posiciona no Folder de cancelamento
		oView:SetAfterViewActivate( { | oView | fSelFol( oView, 7 ) } )

	ElseIf lRetMTRSin
		
		oStructTAT:RemoveField( 'TAT_JUSCAN' )
		
		// Posiciona no Folder do recptor
		oView:SetAfterViewActivate( { | oView | fSelFol( oView, 5 ) } )

	Else
		
		// Caso seja visualização apresenta a aba de cancelamento.
		If oModel:GetOperation() != 2 .And. oStructTAT:HasField( 'TAT_JUSCAN' )
		
			oStructTAT:RemoveField( 'TAT_JUSCAN' )

		EndIf

	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} CommitInfo
Realiza o Commit dos dados

@type   Function

@author Eduardo Mussi
@since  16/04/2025
@param  oModel, Objeto, Objeto com o modelod e dados

@return Lógico, Define se foi feito o commit
/*/
//-------------------------------------------------------------------
Static Function CommitInfo( oModel )

Return FwFormCommit( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} fMVldAct
Executa funções pre-valid

@type   Function

@author Eduardo Mussi
@since  15/12/2025

@param  oModel, Objeto, Modelo de dados do MVC.

@return Lógico, Define se pode seguir
/*/
//-------------------------------------------------------------------
Static Function fMVldAct( oModel )

	Local lReturn := .T.

	// Declara variáveis para uso no processo da criação da View do posValid
	lCanMTRSin := IsInCallStack( 'CanMTRSin' )
	lRetMTRSin := IsInCallStack( 'ManReturn' )
	
	If lRetMTRSin
		
		If TAT->TAT_STATUS == '3'
			
			oModel:SetErrorMessage( '', '', '', '', 'Atenção', 'Este Manifesto não pode ser retornado, pois já foi finalizado!' )
			lReturn := .F.
		
		ElseIf TAT->TAT_STATUS == '4'
			
			oModel:SetErrorMessage( '', '', '', '', 'Atenção', 'Este Manifesto não pode ser retornado, pois já foi cancelado!' )
			lReturn := .F.

		EndIf

	ElseIf lCanMTRSin

		If TAT->TAT_STATUS == '4'

			oModel:SetErrorMessage( '', '', '', '', 'Atenção', 'Este manifesto não pode ser cancelado, pois já foi cancelado!' )
			lReturn := .F.

		EndIf

	ElseIf oModel:GetOperation() == 5 .And. !Empty( TAT->TAT_NUMMTR )

		If !fVldDel( AllTrim( TAT->TAT_NUMMTR ) )
			
			oModel:SetErrorMessage( '', '', '', '', 'Atenção', 'Este manifesto não pode ser excluído, pois já foi cadastrado no Sinir!' )
			lReturn := .F.

		EndIf

	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldDel
Verifica se o Manifesto pode ser deletado

@type   Function

@author Eduardo Mussi
@since  15/12/2025
@param  cNumMTR, Caracter, Numero do MTR

@return Lógico, Define se pode seguir
/*/
//-------------------------------------------------------------------
Static Function fVldDel( cNumMTR )
	
	Local lReturn := .T.
	Local oObjResp

	Conout( '[ NUMERO MTR PARA VALIDAR - ' + cNumMTR + ']' )

	oObjResp := SendSGAMTR( , 3, Posicione( 'TH8', 2, FwxFilial( 'TH8' ) + '1' + FWGrpCompany() + FWCodFil(), 'TH8_CODSIN' ), cNumMTR )
	
	If oObjResp:hasProperty( 'erro' )
		
		lReturn  := oObjResp[ 'erro' ]

	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fMPosValid
Função responsável por enviar os dados ao sinir após a validação do 
modelo

@type   Function

@author Eduardo Mussi
@since  17/06/2025

@param  oModel, Objeto, Modelo de dados do MVC.

@return Lógico, define se todas as validações foram atendidas pelo sinir
/*/
//-------------------------------------------------------------------
Static Function fMPosValid( oModel )

	Local lReturn   := .T.
	Local cNumMTR   := ''
	Local nLine     := 0
	Local oModelTAY := oModel:GetModel( 'SGAA099_TAY' )
	
	// Somente executa validações caso não seja uma exclusão
	If oModel:GetOperation() != 5
	
		For nLine := 1 To oModelTAY:GetQTDLine()

			oModelTAY:GoLine( nLine )

			// verificar quando a classe do residuo for igual a 1 os campos de numero ONU, classe de risco se tornam obrigatórios
			If AllTrim( oModelTAY:GetValue( 'TAY_CLASSE' ) ) == '1'
				
				If Empty( oModelTAY:GetValue( 'TAY_NUMONU' ) )
					
					Help( ' ', 1, 'Atenção',, 'O campo ' + Rtrim( FWX3Titulo( 'TAY_NUMONU' ) ) + ' não foi preenchido. Este campo se torna obrigatório quando o resíduo informado for de classe 1.', 1 , 0,,,,,, { 'Preencha o campo ' + Rtrim( FWX3Titulo( 'TAY_NUMONU' ) ) + ' com base no resíduo informado!'})
					lReturn := .F.

				ElseIf Empty( oModelTAY:GetValue( 'TAY_CLARIS' ) )
					
					Help( ' ', 1, 'Atenção',, 'O campo ' + Rtrim( FWX3Titulo( 'TAY_CLARIS' ) ) + ' não foi preenchido. Este campo se torna obrigatório quando o resíduo informado for de classe 1.', 1 , 0,,,,,, { 'Preencha o campo ' + Rtrim( FWX3Titulo( 'TAY_CLARIS' ) ) + ' com base no resíduo informado!'})
					lReturn := .F.

				ElseIf Empty( oModelTAY:GetValue( 'TAY_NMEMBA' ) )
					
					Help( ' ', 1, 'Atenção',, 'O campo ' + Rtrim( FWX3Titulo( 'TAY_NMEMBA' ) ) + ' não foi preenchido. Este campo se torna obrigatório quando o resíduo informado for de classe 1.', 1 , 0,,,,,, { 'Preencha o campo ' + Rtrim( FWX3Titulo( 'TAY_NMEMBA' ) ) + ' com base no resíduo informado!'})
					lReturn := .F.

				ElseIf Empty( oModelTAY:GetValue( 'TAY_GRPEMB' ) )
				
					Help( ' ', 1, 'Atenção',, 'O campo ' + Rtrim( FWX3Titulo( 'TAY_GRPEMB' ) ) + ' não foi preenchido. Este campo se torna obrigatório quando o resíduo informado for de classe 1.', 1 , 0,,,,,, { 'Preencha o campo ' + Rtrim( FWX3Titulo( 'TAY_GRPEMB' ) ) + ' com base no resíduo informado!'})
					lReturn := .F.

				EndIf

			EndIf
			
		Next nLine
			
		If lReturn
			
			oModel:LoadValue( 'SGAA099_TAY', 'TAY_CODCOM', oModel:GetValue( 'SGAA099_TAT', 'TAT_CODCOM' ) )
			
			If cSendMTR != '3'
			
				If !lRetMTRSin .And. !lCanMTRSin .And. ( cSendMTR == '1' .Or. ( cSendMTR == '2' .And. MsgYesNo( 'Deseja enviar o manifesto ao SINIR?', 'Manifesto' ) ) )
					
					If oModel:GetOperation() == 3

						oModel:SetValue( 'SGAA099_TAY', 'TAY_CORRET', '2' )
						
						// Caso o numero do manifesto seja preenchido, entende-se que o manifesto já existe e não envia para o sinir, apenas inclui no protheus.
						If Empty( oModel:GetValue( 'SGAA099_TAT', 'TAT_NUMMTR' ) )
							
							If !Empty( cNumMTR := SendMTRSin( oModel ) )
							
								// Após retorno do SINIR atribuir o Manifesto gerado na TAT.
								oModel:SetValue( 'SGAA099_TAT', 'TAT_NUMMTR', cNumMTR )
								Conout( 'NUMERO DO MTR RETORNADO DO SINIR - ' + cNumMTR )

							Else
							
								lReturn := .F.
								Conout( 'Não foi possivel gerar o manifesto' )
							
							EndIf

						EndIf

					EndIf

				ElseIf lRetMTRSin

					Conout( 'Passou no retorno do manifesto' )

					If lReturn := SendReturnMTR( oModel )
						
						oModel:SetValue( 'SGAA099_TAT', 'TAT_STATUS', '3' )

					EndIf

				ElseIf lCanMTRSin
					
					Conout( 'Passou no cancelamento do manifesto' )

					If ( lReturn := SendCanMTR( oModel ) )

						oModel:SetValue( 'SGAA099_TAT', 'TAT_STATUS', '4' )

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fSelFol
Função responsável por selecionar o folder de justificativa quando 
for opção de cancelamento do manifesto

@type   Function

@author Eduardo Mussi
@since  22/04/2025
@param  oView, objeto, objeto da view
@param  nFolder, numérico, numero do folder a ser posicionado

/*/
//-------------------------------------------------------------------
Static Function fSelFol( oView, nFolder )
	
	If !lIntFat .And. nFolder == 7
		
		oView:aViews[ 1, 3 ]:oFolder:nOption := 6

	Else
		
		oView:aViews[ 1, 3 ]:oFolder:nOption := nFolder

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SendMTRSin
Envia dados do MTR para SINIR

@type   Function

@author Eduardo Mussi
@since  19/12/2024
@param  oModel, objeto, objeto do modelo de dados

@return cNumMTR, código manifesto gerado pelo sinir
/*/
//-------------------------------------------------------------------
Function SendMTRSin( oModel )
	
	Local aManifest := {}
	Local cNumMTR   := ''
	Local oObjMTR   := JsonObject():New()
	Local oObjList  := JsonObject():New()
	Local oObjTrans := JsonObject():New()
	Local oObjDest  := JsonObject():New()
	Local oObjArmT  := JsonObject():New()
	Local oModelTAY := oModel:GetModel( 'SGAA099_TAY' )
	Local nLine     := 0

	Default oModel  := FWModelActive()

	// Transportador - TAT_CDTRAN / A2_CGC
	oObjTrans[ 'unidade' ] := AllTrim( oModel:GetValue( 'SGAA099_TAT', 'TAT_UNSTRA' ) )
	
	// Caso tipo de transporte seja proprio, pega a empresa e filial logada
	If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '1'
		oObjTrans[ 'cpfCnpj' ] := fPullSM0( 'M0_CGC', oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )
	Else
		oObjTrans[ 'cpfCnpj' ] := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 'A4_CGC' )
	EndIf

	// Armazenador temporário
	oObjArmT[ 'unidade' ] := oModel:GetValue( 'SGAA099_TAT', 'TAT_UNARMT' )
	oObjArmT[ 'cpfCnpj' ] := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_CGC' )
	
	// Destinador - TAT_CODREC / A2_CGC	
	oObjDest[ 'unidade' ] := AllTrim( oModel:GetValue( 'SGAA099_TAT', 'TAT_UNSDES' ) )
	oObjDest[ 'cpfCnpj' ] := fGetCGC( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ) )

	For nLine := 1 To oModelTAY:GetQTDLine()
		
		oModelTAY:GoLine( nLine )
		
		// Adiciona uma posição do Manifesto
		aAdd( aManifest, oObjList )

		aManifest[ nLine, 'marQuantidade'   ] := oModelTAY:GetValue( 'TAY_QUANTI' )
		aManifest[ nLine, 'resCodigoIbama'  ] := AllTrim( oModelTAY:GetValue( 'TAY_IBAMA' ) )  
		aManifest[ nLine, 'uniCodigo'       ] := fGetUn( oModelTAY:GetValue( 'TAY_UNIDAD' ) )  
		aManifest[ nLine, 'traCodigo'       ] := fGetTr( AllTrim( oModelTAY:GetValue( 'TAY_TRATA' ) ) )
		aManifest[ nLine, 'tieCodigo'       ] := fGetEst( oModelTAY:GetValue( 'TAY_ESTADO' ) )
		aManifest[ nLine, 'tiaCodigo'       ] := Val( oModelTAY:GetValue( 'TAY_ACOND' ) )
		aManifest[ nLine, 'claCodigo'       ] := Val( oModelTAY:GetValue( 'TAY_CLASSE' ) )
		
		// Lista dos campos que não são obrigatórios
		If oModelTAY:GetValue( 'TAY_DENSID' ) > 0
			aManifest[ nLine, 'marDensidade'        ] := oModelTAY:GetValue( 'TAY_DENSID' )
		EndIf

		If !Empty( oModelTAY:GetValue( 'TAY_NUMONU' ) )
			aManifest[ nLine, 'marNumeroONU'        ] := oModelTAY:GetValue( 'TAY_NUMONU' )
		EndIf

		If !Empty( oModelTAY:GetValue( 'TAY_CLARIS' ) )
			aManifest[ nLine, 'marClasseRisco'      ] := oModelTAY:GetValue( 'TAY_CLARIS' )
		EndIf

		If !Empty( oModelTAY:GetValue( 'TAY_NMEMBA' ) )
			aManifest[ nLine, 'marNomeEmbarque'     ] := oModelTAY:GetValue( 'TAY_NMEMBA' )
		EndIf

		If Val( oModelTAY:GetValue( 'TAY_GRPEMB' ) ) > 0
			aManifest[ nLine, 'greCodigo'           ] := Val( oModelTAY:GetValue( 'TAY_GRPEMB' ) )
		EndIf

		If !Empty( oModelTAY:GetValue( 'TAY_CODINT' ) )
			aManifest[ nLine, 'marCodigoInterno'    ] := oModelTAY:GetValue( 'TAY_CODINT' )
		EndIf

		If !Empty( oModelTAY:GetValue( 'TAY_OBSERV' ) )
			aManifest[ nLine, 'observacoes'         ] := EncodeUtf8( oModelTAY:GetValue( 'TAY_OBSERV' ) )
		EndIf

	Next nLine

	oObjMTR[ 'tipoManifesto' ] := oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' )
	oObjMTR[ 'dataExpedicao' ] := '' // TAT->TAT_DTCOMP + TAT->TAT_HRCOMP
	oObjMTR[ 'nomeMotorista' ] := AllTrim( oModel:GetValue( 'SGAA099_TAT', 'TAT_NOMMOT' ) )
	oObjMTR[ 'placaVeiculo'  ] := oModel:GetValue( 'SGAA099_TAT', 'TAT_PLACA' )
	oObjMTR[ 'observacoes'   ] := EncodeUtf8( oModel:GetValue( 'SGAA099_TAT', 'TAT_OBSGER' ) )
	oObjMTR[ 'transportador' ] := oObjTrans
	oObjMTR[ 'destinador'    ] := oObjDest
	oObjMTR[ 'armazenadorTemporario'  ] := oObjArmT
	oObjMTR[ 'listaManifestoResiduos' ] := aManifest
	
	Conout( '[' + oObjMTR:ToJson() + ']')

	cNumMTR := SendSGAMTR( '[' + oObjMTR:ToJson() + ']', 1, AllTrim( oModel:GetValue( 'SGAA099_TAT', 'TAT_UNSGER' ) ) )
	
	FwFreeObj( oObjMTR )
	FwFreeObj( oObjList )
	FwFreeObj( oObjTrans )
	FwFreeObj( oObjDest )

Return cNumMTR

//-------------------------------------------------------------------
/*/{Protheus.doc} SendReturnMTR
Responsável por montar o Json e chamar a requisição do sinir de 
Retorno em Lote

@type   Function

@author Eduardo Mussi
@since  07/07/2025
@param  oModel, objeto, Objeto do modelo de dados ativos

@return Lógico, Define se o processo de retorno foi executado com sucesso
/*/
//-------------------------------------------------------------------
Static Function SendReturnMTR( oModel )

	Local aListRes  := {}
	Local lReturn   := .T.
	Local oObjMTR   := JsonObject():New()
	Local oObjList  := JsonObject():New()
	Local oModelTAY := oModel:GetModel( 'SGAA099_TAY' )

	oObjMTR[ 'manNumero'       ] := AllTrim( oModel:GetValue( 'SGAA099_TAT', 'TAT_NUMMTR' ) )
	oObjMTR[ 'dataRecebimento' ] := fCompDate( oModel:GetValue( 'SGAA099_TAT', 'TAT_DTEREC' ) )
	oObjMTR[ 'nomeMotorista'   ] := AllTrim( oModel:GetValue( 'SGAA099_TAT', 'TAT_NOMMOT' ) )
	oObjMTR[ 'placaVeiculo'    ] := AllTrim( oModel:GetValue( 'SGAA099_TAT', 'TAT_PLACA' ) )
	oObjMTR[ 'nomeResponsavelRecebimento' ] := AllTrim( oModel:GetValue( 'SGAA099_TAT', 'TAT_RESPRE' ) )

	// o Recebimento poderá ser feito por um armazenador temporário ou um destinador, tem que entender melhor os cenários para pegar corretamente a observação.
	// Neste momento utilizará o campo de observação do destinador
	oObjMTR[ 'observacoes' ] := EncodeUtf8( oModel:GetValue( 'SGAA099_TAT', 'TAT_OBSDES' ) )

	aAdd( aListRes, oObjList )

	aListRes[ 1, 'resCodigoIbama'         ] := AllTrim( oModelTAY:GetValue( 'TAY_IBAMA', 1 ) )
	aListRes[ 1, 'marQuantidade'          ] := oModelTAY:GetValue( 'TAY_QTDREC', 1 )
	aListRes[ 1, 'quantidadeRecebida ' ] := oModelTAY:GetValue( 'TAY_QTDREC', 1 )
	aListRes[ 1, 'uniCodigo'              ] := fGetUn( oModelTAY:GetValue( 'TAY_UNIDAD', 1 ) ) 
	aListRes[ 1, 'traCodigo'              ] := Val( oModelTAY:GetValue( 'TAY_TRATA', 1 ) )
	aListRes[ 1, 'tieCodigo'              ] := fGetEst( oModelTAY:GetValue( 'TAY_ESTADO', 1 ) ) 
	aListRes[ 1, 'tiaCodigo'              ] := Val( oModelTAY:GetValue( 'TAY_ACOND', 1 ) )
	aListRes[ 1, 'claCodigo'              ] := Val( oModelTAY:GetValue( 'TAY_CLASSE', 1 ) )

	// Somente informar este campo caso a quantidade recebida for divergente da informada na geração
	If oModelTAY:GetValue( 'TAY_QUANTI', 1 ) != oModelTAY:GetValue( 'TAY_QTDREC', 1 )
		
		aListRes[ 1, 'marJustificativa' ] := EncodeUtf8( oModel:GetValue( 'SGAA099_TAT', 'TAY_JUSTIF' ) )
		
	EndIf
	
	oObjMTR[ 'listaManifestoResiduos' ] := aListRes

	Conout( '[' + oObjMTR:ToJson() + ']')

	lReturn := SendSGAMTR(  '[' + oObjMTR:ToJson() + ']', 4 )

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetCGC
Função responsável por buscar o CNPJ do destinador

@type   Function

@author Eduardo Mussi
@since  09/06/2025
@param  cCodeDes, caracter, código do destinador/receptor

@return Tipagem, descrição
/*/
//-------------------------------------------------------------------
Static Function fGetCGC( cCodeDes )

	Local cCNPJ := ''

	dbSelectArea( 'TB5' )
	dbSetOrder( 1 )
	If MsSeek( FwxFilial( 'TB5' ) + cCodeDes )
		dbSelectArea( 'SA2' )
		dbSetOrder( 1 )
		If MsSeek( FwxFilial( 'SA2' ) + TB5->TB5_FORNEC + TB5->TB5_LOJA )
			cCNPJ := SA2->A2_CGC
		EndIf
	EndIf

Return cCNPJ

//-------------------------------------------------------------------
/*/{Protheus.doc} SendCanMTR
Responsável por enviar o cancelamento de um manifesto

@type   Function

@author Eduardo Mussi
@since  22/04/2025
@param  oModel, Objeto, Modelo de dados

@return Lógico, Define se o cancelamento ocorreu
/*/
//-------------------------------------------------------------------
Static Function SendCanMTR( oModel )

	Local oObjMTR := JsonObject():New()
	Local lReturn := .T.
	
	oObjMTR[ 'manNumero' ] := AllTrim( oModel:GetValue( 'SGAA099_TAT', 'TAT_NUMMTR' ) )
	oObjMTR[ 'justificativa' ] := oModel:GetValue( 'SGAA099_TAT', 'TAT_JUSCAN' )

	Conout( '[' + oObjMTR:ToJson() + ']' )

	lReturn := SendSGAMTR( oObjMTR:ToJson(), 2, AllTrim( oModel:GetValue( 'SGAA099_TAT', 'TAT_UNSGER' ) ) )

	FwFreeObj( oObjMTR )

Return lReturn
//-------------------------------------------------------------------
/*/{Protheus.doc} CanMTRSin
Cancelar um manifesto

@type   Function

@author Eduardo Mussi
@since  22/04/2025

@return Nil
/*/
//-------------------------------------------------------------------
Function CanMTRSin()

	Local oModCan099 := FWLoadModel( 'SGAA099' )
	
	oModCan099:SetOperation( 4 )
	oModCan099:Activate() 

	FWExecView( 'Cancelamento', 'SGAA099', 4,,,,,,,,, oModCan099 )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA099VLD
Inserir descrição

@type   Function

@author Eduardo Mussi
@since  12/02/2025
@param  cField, Tipagem, Descrição

@return Lógico, Define se poderá prosseguir com a operação
/*/
//-------------------------------------------------------------------
Function SGAA099VLD( cField )

	Local oModel  := FWModelActive()
	Local lReturn := .T.
	
	// Mudar para Do Case.
	If cField == 'TAT_DTCOMP'
		
		lReturn := oModel:GetValue( 'SGAA099_TAT', 'TAT_DTCOMP' ) <= dDataBase

	ElseIf cField == 'TAT_HRCOMP' 
		
		lReturn := ValHora( oModel:GetValue( 'SGAA099_TAT', 'TAT_HRCOMP' ) ) .And.  oModel:GetValue( 'SGAA099_TAT', 'TAT_HRCOMP' ) <= Substr( Time(), 1, 5 )

	ElseIf cField == 'TAT_NUMMTR'
		
		lReturn := !NGIFDBSEEK( 'TAT', FwxFilial( 'TAT' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_NUMMTR' ), 3 ) //SG530EXMTR()

	ElseIf cField == 'TAT_STATUS'
		
		If oModel:GetValue( 'SGAA099_TAT', 'TAT_STATUS' ) $ '1/2/3/4'

			If FWFldGet( 'TAT_STATUS' ) == '1' .And. oModel:GetValue( 'SGAA099_TAT', 'TAT_STATUS' ) == '3'

				Help(' ',1, 'Atenção',, 'Operação não permitida, pois o manifesto deve ser enviado primeiro para o status de 2=Expedição.', 2, 0 ) 
				lReturn :=  .F.

			ElseIf lIntFat .and. FWFldGet( 'TAT_STATUS' ) != '1' .And. oModel:GetValue( 'SGAA099_TAT', 'TAT_STATUS' ) == '1'
				
				Help(' ',1, 'Atenção',, 'Operação não permitida, pois já houve inclusão de Pedido de Nota Fiscal.', 2, 0 )
				lReturn :=  .F.

			EndIf
		Else
			lReturn :=  .F.
		EndIf

	ElseIf cField == 'TAT_UNSGER'

		lReturn := ExistCpo( 'TH8', '1' + oModel:GetValue( 'SGAA099_TAT', 'TAT_UNSGER' ), 5 )

	ElseIf cField == 'TAT_TPTRAN'
		
		If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '1'
			
			
			//cCodTrans := oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' )
			oModel:SetValue( 'SGAA099_TAT', 'TAT_LICTRA', Space( FwTamSX3( 'TAT_LICTRA' )[ 1 ] ) )
			oModel:SetValue( 'SGAA099_TAT', 'TAT_NOMMOT', Space( FwTamSX3( 'TAT_NOMMOT' )[ 1 ] ) )
			
			// Variavel de Filtragem do F3 de veículos
			cCodTrans := fGetCodeTR( @lReturn )

			If !Empty( cCodTrans ) .And. !lReturn
				
				Help( ' ', 1, 'Atenção',, 'Transportadora invativa!', 2, 0 )
				oModel:LoadValue( 'SGAA099_TAT', 'TAT_TPTRAN', Space( FwTamSX3( 'TAT_TPTRAN' )[ 1 ] ) )

			ElseIf Empty( cCodTrans ) .And. lReturn
				
				Help( ' ', 1, 'Atenção',, 'Transportadora não cadastrada com o mesmo CNPJ da filial logada.', 2, 0 )
				lReturn := .F.
				oModel:LoadValue( 'SGAA099_TAT', 'TAT_TPTRAN', Space( FwTamSX3( 'TAT_TPTRAN' )[ 1 ] ) )

			EndIf

		ElseIf oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '2'
				cCodTrans := oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' )
				oModel:SetValue( 'SGAA099_TAT', 'TAT_LICTRA', Space( FwTamSX3( 'TAT_LICTRA' )[ 1 ] ) )
				oModel:SetValue( 'SGAA099_TAT', 'TAT_NOMMOT', Space( FwTamSX3( 'TAT_NOMMOT' )[ 1 ] ) )
		Else
			
			lReturn := .F.

		EndIf
	
	ElseIf cField == 'TAT_UNSTRA'

		lReturn := ExistCpo( 'TH8', '2' + oModel:GetValue( 'SGAA099_TAT', 'TAT_UNSTRA' ), 5 )

	ElseIf cField == 'TAT_CDTRAN'
		
		If ExistCpo( 'TDL', oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ) )
			
			dbSelectArea( 'TDL' )
			dbSetOrder( 1 )
			If MsSeek( FwxFilial( 'TDL' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ) ) .And. TDL->TDL_STATUS == '2'

				Help(' ', 1, 'Atenção',, 'A Transportadora se encontra inativa no sistema', 2, 0 )
				lReturn :=  .F.

			Else

				// Variavel de Filtragem do F3 de veículos
				cCodTrans := oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' )
				
			EndIf

		Else

			lReturn := .F.

		EndIf

	ElseIf cField == 'TAT_LICTRA'
		
		lReturn := ExistCpo( 'TA0', oModel:GetValue( 'SGAA099_TAT', 'TAT_LICTRA' ) )

	ElseIf cField == 'TAT_CODMOT'
		
		lReturn := ExistCpo( 'DA4', oModel:GetValue( 'SGAA099_TAT', 'TAT_CODMOT' ) )

	ElseIf cField == 'TAT_UNARMT'

		lReturn := ExistCpo( 'TH8', '3' + oModel:GetValue( 'SGAA099_TAT', 'TAT_UNARMT' ), 5 )

	ElseIf cField == 'TAT_CODREC'
		
		lReturn := .T.//fValRes( oModel ) //SG530VAL()

	ElseIf cField == 'TAT_CONPAG'
		
		lReturn := ExistCpo( 'SE4', oModel:GetValue( 'SGAA099_TAT', 'TAT_CONPAG' ) )

	ElseIf cField == 'TAT_MENPAD'
		
		lReturn := Empty( oModel:GetValue( 'SGAA099_TAT', 'TAT_MENPAD' ) ) .Or. ExistCpo( 'SM4', oModel:GetValue( 'SGAA099_TAT', 'TAT_MENPAD' ) )

	ElseIf cField == 'TAT_VOLUM1'
		
		lReturn := Empty( oModel:GetValue( 'SGAA099_TAT', 'TAT_VOLUM1' ) ) .Or. Positivo(oModel:GetValue( 'SGAA099_TAT', 'TAT_VOLUM1' ) )

	ElseIf cField == 'TAT_PESOL'
			
		lReturn := Empty( oModel:GetValue( 'SGAA099_TAT', 'TAT_PESOL' ) ) .Or. Positivo(oModel:GetValue( 'SGAA099_TAT', 'TAT_VOLUM1' ) )

	ElseIf cField == 'TAT_PBRUTO'
		
		lReturn := mpty( oModel:GetValue( 'SGAA099_TAT', 'TAT_PBRUTO' ) ) .Or. Positivo(oModel:GetValue( 'SGAA099_TAT', 'TAT_VOLUM1' ) )

	ElseIf cField == 'TAT_TPDEST'
		
		If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPDEST' ) $ '1/2'

			If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPDEST' ) == '1'
				
				aTrocaF3 := { { 'TAT_FORNNF', 'FOR' } }

			Else

				aTrocaF3 := { { 'TAT_FORNNF', 'SA1' } }

			EndIf

			oModel:SetValue( 'SGAA099_TAT', 'TAT_FORNNF', Space( FwTamSX3( 'TAT_FORNNF' )[ 1 ] ) )
			oModel:SetValue( 'SGAA099_TAT', 'TAT_LOJANF', Space( FwTamSX3( 'TAT_LOJANF' )[ 1 ] ) )
			oModel:SetValue( 'SGAA099_TAT', 'TAT_NOMDES', Space( FwTamSX3( 'TAT_NOMDES' )[ 1 ] ) )
			
		Else

			lReturn := .F.

		EndIf

	ElseIf cField == 'TAT_FORNNF'
		
		If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPDEST' ) == '1'
			
			lReturn := ExistCpo( 'SA2', oModel:GetValue( 'SGAA099_TAT', 'TAT_FORNNF' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_LOJANF' ) )

		Else
			
			lReturn := ExistCpo( 'SA1', oModel:GetValue( 'SGAA099_TAT', 'TAT_FORNNF' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_LOJANF' ) )

		EndIf
		
		If lReturn
		
			oModel:SetValue( 'SGAA099_TAT', 'TAT_NOMDES', SG280RELA( oModel:GetValue( 'SGAA099_TAT', 'TAT_TPDEST' ), oModel:GetValue( 'SGAA099_TAT', 'TAT_FORNNF' ), oModel:GetValue( 'SGAA099_TAT', 'TAT_LOJANF' ),'NOME' ) )

		EndIf
	
	ElseIf cField == 'TAT_CDARMT'

		lReturn := ExistCpo( 'SA4', oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ) )
	
	ElseIf cField == 'TAT_UNSDES'
		
		// Ao passar pelo Valid estará posicionado na TH8 com base no retorno do F3 do campo TAT_UNSDES
		lReturn := ExistCpo( 'TB5', TH8->TH8_FORDES + TH8->TH8_LOJA, 3 )

	ElseIf cField == 'TAY_CLASSE'

		lReturn := ExistCpo( 'TCS', oModel:GetValue( 'SGAA099_TAY', 'TAY_CLASSE' ) )

	ElseIf cField == 'TAY_DENSID'

		lReturn := oModel:GetValue( 'SGAA099_TAY', 'TAY_DENSID' ) > 0
	
	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA099GAT
Função responsável por popular os campos gatilhos

@type   Function

@author Eduardo Mussi
@since  20/02/2025

@param  cDomain  , Caracter, Campo que está chamando o gatilho
@param  cContDom, Caracter, Campo de contra dominio que receberá o valor de retorno do processo.

@return Indefinido, retorna o conteúdo a ser inserido no campo

/*/
//-------------------------------------------------------------------
Function SGAA099GAT( cDomain, cContDom )
	
	Local oModel  := FWModelActive()
	Local xReturn

	// Mudar para Do Case.
	If cDomain == 'TAT_UNSGER' .And. cContDom == 'TAT_EMPGER'
		
		xReturn := Posicione( 'TH8', 5, FwxFilial( 'TH8' ) + '1' + oModel:GetValue( 'SGAA099_TAT', 'TAT_UNSGER' ), 'TH8_CODEMP' )

	ElseIf cDomain == 'TAT_UNSGER' .And. cContDom == 'TAT_FILGER'
		
		xReturn := Posicione( 'TH8', 5, FwxFilial( 'TH8' ) + '1' + oModel:GetValue( 'SGAA099_TAT', 'TAT_UNSGER' ), 'TH8_FILEMP' )

	ElseIf cDomain == 'TAT_FILGER' .And. cContDom == 'TAT_NOMGER' 
		
		xReturn := fPullSM0( 'M0_NOMECOM', oModel:GetOperation() == 3, oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPGER' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_FILGER' ) )

	ElseIf cDomain == 'TAT_FILGER' .And. cContDom == 'TAT_ENDGER' 
		
		xReturn := fPullSM0( 'M0_ENDCOB', oModel:GetOperation() == 3, oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPGER' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_FILGER' ) )

	ElseIf cDomain == 'TAT_FILGER' .And. cContDom == 'TAT_CIDGER' 
		
		xReturn := fPullSM0( 'M0_CIDCOB', oModel:GetOperation() == 3, oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPGER' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_FILGER' ) )

	ElseIf cDomain == 'TAT_FILGER' .And. cContDom == 'TAT_ESTGER' 
		
		xReturn := fPullSM0( 'M0_ESTCOB', oModel:GetOperation() == 3, oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPGER' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_FILGER' ) )

	ElseIf cDomain == 'TAT_FILGER' .And. cContDom == 'TAT_TELGER' 
		
		xReturn := fPullSM0( 'M0_TEL', oModel:GetOperation() == 3, oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPGER' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_FILGER' ) )
	
	ElseIf cDomain ==  'TAT_UNSTRA' .And. cContDom == 'TAT_CDTRAN'

		xReturn := Posicione( 'TH8', 5, FwxFilial( 'TH8' ) + '2' + oModel:GetValue( 'SGAA099_TAT', 'TAT_UNSTRA' ), 'TH8_FORTRA' )

	ElseIf cDomain == 'TAT_CDTRAN' .And. cContDom == 'TAT_NOMTRA'
		
		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 'A4_NOME')

	ElseIf cDomain == 'TAT_CDTRAN' .And. cContDom == 'TAT_ENDTRA'
		
		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 'A4_END')
		
	ElseIf cDomain == 'TAT_CDTRAN' .And. cContDom == 'TAT_CIDTRA'
		
		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 'A4_MUN')

	ElseIf cDomain == 'TAT_CDTRAN' .And. cContDom == 'TAT_ESTTRA'
		
		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 'A4_EST')

	ElseIf cDomain == 'TAT_CDTRAN' .And. cContDom == 'TAT_TELTRA'
		
		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 'A4_TEL')

	ElseIf cDomain == 'TAT_CDTRAN' .And. cContDom == 'TAT_LICTRA'
		
		xReturn := Posicione( 'TDL', 1, FwxFilial( 'TDL' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 'TDL_CODLAM')

	ElseIf cDomain == 'TAT_CODMOT' .And. cContDom == 'TAT_NOMMOT'
		
		xReturn := Posicione( 'DA4', 1, FwxFilial( 'DA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CODMOT' ), 'DA4_NOME')

	ElseIf cDomain == 'TAT_MENPAD' .And. cContDom == 'TAT_DESPAD'
		
		xReturn := Posicione( 'SM4', 1, FwxFilial( 'SM4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_MENPAD' ), 'M4_DESCR')

	ElseIf cDomain == 'TAT_CODREC' .And. cContDom == 'TAT_NOMREC'

		xReturn := SG280INFD( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'NOME' )

	ElseIf cDomain == 'TAT_CODREC' .And. cContDom == 'TAT_ENDREC'

		xReturn := SG280INFD( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'END' )

	ElseIf cDomain == 'TAT_CODREC' .And. cContDom == 'TAT_TELREC'

		xReturn := SG280INFD( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'TEL' )

	ElseIf cDomain == 'TAT_CODREC' .And. cContDom == 'TAT_CIDREC'

		xReturn := SG280INFD( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'MUN' )

	ElseIf cDomain == 'TAT_CODREC' .And. cContDom == 'TAT_ESTREC'

		xReturn := SG280INFD( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'EST' )

	ElseIf cDomain == 'TAT_CODREC' .And. cContDom == 'TAT_LICREC'

		xReturn := Posicione( 'TB5', 1, FwxFilial( 'TB5' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'TB5_CODLAM' )
	
	ElseIf cDomain == 'TAT_TPTRAN'

		If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '1'
			
			If cContDom == 'TAT_CDTRAN'
				
				xReturn := fGetCodeTR()
			
			ElseIf cContDom == 'TAT_UNSTRA' 
			
				xReturn := Posicione( 'TH8', 4, FwxFilial( 'TH8' ) + '2' + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 'TH8_CODSIN' )
			
			ElseIf cContDom == 'TAT_NOMTRA'
				
				xReturn := fPullSM0( 'M0_NOMECOM', oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )
				
			ElseIf cContDom == 'TAT_ENDTRA'
				
				xReturn := fPullSM0( 'M0_ENDCOB' , oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )
				
			ElseIf cContDom == 'TAT_CIDTRA'
				
				xReturn := fPullSM0( 'M0_CIDCOB' , oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )
				
			ElseIf cContDom == 'TAT_ESTTRA'
				
				xReturn := fPullSM0( 'M0_ESTCOB' , oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )
				
			ElseIf cContDom == 'TAT_TELTRA'
				
				xReturn := fPullSM0( 'M0_TEL'    , oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )
				
			EndIf

		Else
		
			If cContDom == 'TAT_CDTRAN'
				
				xReturn := Space( FwTamSX3( 'TAT_NOMTRA' )[ 1 ] )
				
			ElseIf cContDom == 'TAT_NOMTRA'
				
				xReturn := Space( FwTamSX3( 'TAT_ENDTRA' )[ 1 ] )
				
			ElseIf cContDom == 'TAT_ENDTRA'
				
				xReturn := Space( FwTamSX3( 'TAT_CIDTRA' )[ 1 ] )
				
			ElseIf cContDom == 'TAT_CIDTRA'
				
				xReturn := Space( FwTamSX3( 'TAT_ESTTRA' )[ 1 ] )
				
			ElseIf cContDom == 'TAT_ESTTRA'
				
				xReturn := Space( FwTamSX3( 'TAT_TELTRA' )[ 1 ] )
				
			ElseIf cContDom == 'TAT_TELTRA'
				
				xReturn := Space( FwTamSX3( 'TAT_CODMOT' )[ 1 ] )
				
			EndIf

		EndIf
	
	ElseIf cDomain ==  'TAT_UNARMT' .And. cContDom == 'TAT_CDARMT'

		xReturn := Posicione( 'TH8', 5, FwxFilial( 'TH8' ) + '3' + oModel:GetValue( 'SGAA099_TAT', 'TAT_UNARMT' ), 'TH8_FORTRA' )

	ElseIf cDomain == 'TAT_CDARMT'
		
		If cContDom == 'TAT_NMARMT'
			
			xReturn := Posicione( 'SA4', 1,FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_NOME' )
			
		ElseIf cContDom == 'TAT_ENARMT'
			
			xReturn := Posicione( 'SA4', 1,FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_END' )
			
		ElseIf cContDom == 'TAT_TLARMT'
			
			xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_TEL' )
			
		ElseIf cContDom == 'TAT_MUARMT'
			
			xReturn := Posicione( 'SA4', 1,FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_MUN' )
			
		ElseIf cContDom == 'TAT_UFARMT'
			
			xReturn := Posicione( 'SA4', 1,FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_EST' )
			
		EndIf
	
	ElseIf cDomain == 'TAT_UNSDES' .And. cContDom == 'TAT_CODREC'

		// Ao passar pelo gatilho estará posicionado na TH8 com base no retorno do F3 do campo TAT_UNSDES
		xReturn := Posicione( 'TB5', 3, FwxFilial( 'TB5' ) + TH8->TH8_FORDES + TH8->TH8_LOJA, 'TB5_CODIGO' )

	ElseIf cDomain == 'TAT_CDVEIT' .And. cContDom == 'TAT_PLACA'

		xReturn := fGetPlate( oModel:GetValue( 'SGAA099_TAT', 'TAT_CDVEIT' ) )

	ElseIf cDomain == 'TAY_IBAMA' .And. cContDom == 'TAY_DESCRI'

		xReturn := Posicione( 'TFC', 2, FwxFilial( 'TFC' ) + oModel:GetValue( 'SGAA099_TAY', 'TAY_IBAMA' ), 'TFC_DESCRI' )

	ElseIf cDomain == 'TAY_IBAMA' .And. cContDom == 'TAY_UNIDAD'

		xReturn := Posicione( 'TFC', 2, FwxFilial( 'TFC' ) + oModel:GetValue( 'SGAA099_TAY', 'TAY_IBAMA' ), 'TFC_MEDIDA' )

	ElseIf cDomain == 'TAY_ACOND' .And. cContDom == 'TAY_DESCAC'

		xReturn := Posicione( 'TH7', 1, FwxFilial( 'TH7' ) + oModel:GetValue( 'SGAA099_TAY', 'TAY_ACOND' ), 'TH7_DESCRI' )

	ElseIf cDomain == 'TAY_TRATA' .And. cContDom == 'TAY_DESCTR'

		xReturn :=  Posicione( 'SX5', 1, FwxFilial( 'SX5' ) + 'DY' + oModel:GetValue( 'SGAA099_TAY', 'TAY_TRATA' ), 'X5_DESCRI' ) 
	
	ElseIf cDomain == 'TAY_CLASSE' .And. cContDom == 'TAY_DESCLA'
		
		xReturn := Posicione( 'TCS', 1, FwxFilial( 'TCS' ) + oModel:GetValue( 'SGAA099_TAY', 'TAY_CLASSE' ), 'TCS_DESCRI' )

	ElseIf cDomain == 'TAY_NUMONU' .And. cContDom == 'TAY_DESONU'

		xReturn := '' //Posicione( 'DY3', 1, FwxFilial( 'DY3' ) + oModel:GetValue( 'SGAA099_TAY', 'TAY_NUMONU' ), 'DY3_DESCRI' )

	ElseIf cDomain == 'TAY_NUMONU' .And. cContDom == 'TAY_CLARIS'

		xReturn := ''//Posicione( 'DY3', 1, FwxFilial( 'DY3' ) + oModel:GetValue( 'SGAA099_TAY', 'TAY_NUMONU' ), 'DY3_CLASSE' )

	ElseIf cDomain == 'TAY_NUMONU' .And. cContDom == 'TAY_GRPEMB'

		xReturn := ''//Posicione( 'DY3', 1, FwxFilial( 'DY3' ) + oModel:GetValue( 'SGAA099_TAY', 'TAY_NUMONU' ), 'DY3_GRPEMB' )
	
	EndIf

Return xReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA099WHE
Função responsável por avaliar se um campo pode ser editado

@type   Function

@author Eduardo Mussi
@since  19/02/2025
@param  cField, caracter, Campo a ser verificado

@return Lógico, define se o campo poderá ser editado
/*/
//-------------------------------------------------------------------
Function SGAA099WHE( cField )
	
	Local oModel  := FWModelActive()
	Local lReturn := .T.
	
	If lRetMTRSin
		
		// Somente permite alterar os campos referentes ao processo de retorno/recebimento de manifesto
		If cField != 'TAT_RESPRE' .And. cField != 'TAT_DTRTRA' .And. cField != 'TAT_DTEREC'
			
			lReturn := .F.

		EndIf
		
	Else

		If cField == 'TAT_NUMMTR' .Or.cField == 'TAT_TPTRAN' .Or.;
				cField == 'TAT_CODREC' .Or. cField == 'TAT_RESPRE' .Or. cField == 'TAT_CARGRR' .Or. cField == 'TAT_RESPTR'

			lReturn := oModel:GetValue( 'SGAA099_TAT', 'TAT_STATUS' ) == '1'

		ElseIf cField == 'TAT_UNSTRA' .Or. cField == 'TAT_NOMMOT' .Or. cField == 'TAT_PLACA'
			
			lReturn := oModel:GetValue( 'SGAA099_TAT', 'TAT_STATUS' ) == '1' .And. oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '2'

		ElseIf cField == 'TAT_LICTRA' .Or. cField == 'TAT_CODMOT' .Or. cField == 'TAT_CDVEIT'

			lReturn := oModel:GetValue( 'SGAA099_TAT', 'TAT_STATUS' ) == '1' .And. oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '1'

		ElseIf cField == 'TAT_CONPAG' .Or. cField == 'TAT_PREVEN' .Or. cField == 'TAT_MENNOT' .Or. cField == 'TAT_MENPAD' .Or.;
			cField == 'TAT_ESPEC1' .Or. cField == 'TAT_VOLUM1' .Or. cField == 'TAT_PESOL'  .Or. cField == 'TAT_PBRUTO' .Or. cField == 'TAT_TPDEST' .Or.;
			cField == 'TAT_FORNNF' .Or. cField == 'TAT_LOJANF'

			lReturn := oModel:GetValue( 'SGAA099_TAT', 'TAT_STATUS' ) == '1' .And. lIntFat

		ElseIf cField == 'TAT_NMARMT' .Or. cField == 'TAT_ENARMT' .Or. cField == 'TAT_TLARMT' .Or. cField == 'TAT_UFARMT' .Or. cField == 'TAT_MUARMT' .Or.;
				cField == 'TAT_FAARMT' .Or. cField == 'TAT_CDTRAN'

			lReturn := .F.

		EndIf

	EndIf

Return lReturn
 
//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA099REL
Responsável por inserir um valor inicial no campo

@type   Function

@author Eduardo Mussi
@since  19/02/2025
@param  cField, caracter, Campo a ser iniciado

@return Indefinido, retorna o valor do campo a ser iniciado
/*/
//-------------------------------------------------------------------
Function SGAA099REL( cField )

	Local oModel  := FWModelActive()
	Local xReturn
	
	If cField == 'TAT_CODCOM'
		
		xReturn := GETSXENUM( 'TAT', 'TAT_CODCOM' )
	
	ElseIf cField == 'TAT_CODCOM'

		xReturn := GETSXENUM( 'TAT', 'TAT_CODCOM' )

	ElseIf cField == 'TAT_DTALTE'

		xReturn := dDataBase

	ElseIf cField == 'TAT_HRALTE'

		xReturn := SubStr( Time(), 1, 5 )

	ElseIf cField == 'TAT_FILGER'

		xReturn := ''

	ElseIf cField == 'TAT_NOMGER'

		xReturn := fPullSM0( 'M0_NOMECOM', oModel:GetOperation() == 3, oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPGER' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_FILGER' ) )

	ElseIf cField == 'TAT_ENDGER'

		xReturn := fPullSM0( 'M0_ENDCOB', oModel:GetOperation() == 3, oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPGER' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_FILGER' ) )

	ElseIf cField == 'TAT_CIDGER'

		xReturn := fPullSM0( 'M0_CIDCOB', oModel:GetOperation() == 3, oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPGER' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_FILGER' ) )

	ElseIf cField == 'TAT_ESTGER'

		xReturn := fPullSM0( 'M0_ESTCOB', oModel:GetOperation() == 3, oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPGER' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_FILGER' ) )

	ElseIf cField == 'TAT_TELGER'

		xReturn := fPullSM0( 'M0_TEL', oModel:GetOperation() == 3, oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPGER' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_FILGER' ) )

	ElseIf cField == 'TAT_EMPTRA'

		IF oModel:GetOperation() == 3
		
			xReturn := FWGrpCompany() // cEmpAnt

		Else
	
			xReturn := oModel:GetValue( 'SGAA099_TAT', 'TAT_EMPTRA' )

		EndIf

	ElseIf cField == 'TAT_FILTRA'

		IF oModel:GetOperation() == 3
		
			xReturn := FWGrpCompany()

		EndIf

	ElseIf cField == 'TAT_NOMTRA'

		If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '1'
			
			xReturn := fPullSM0( 'M0_NOMECOM', oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )

		ElseIf !Empty( oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) )

			xReturn := NGSEEK( 'SA4', oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 1, 'SA4->A4_NOME' )
		
		Else
			
			xReturn := Space( FwTamSX3( cField )[ 1 ] )

		EndIf

	ElseIf cField == 'TAT_ENDTRA'

		If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '1'
			
			xReturn := fPullSM0( 'M0_ENDCOB', oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )

		ElseIf !Empty( oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) )

			xReturn := NGSEEK( 'SA4', oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 1, 'SA4->A4_END' )
		
		Else
			
			xReturn := Space( FwTamSX3( cField )[ 1 ] )
		
		EndIf

	ElseIf cField == 'TAT_CIDTRA'

		If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '1'
			
			xReturn := fPullSM0( 'M0_CIDCOB', oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )

		ElseIf !Empty( oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) )

			xReturn := NGSEEK( 'SA4', oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 1, 'SA4->A4_MUN' )

		Else
			
			xReturn := Space( FwTamSX3( cField )[ 1 ] )

		EndIf

	ElseIf cField == 'TAT_ESTTRA'

		If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '1'
			
			xReturn := fPullSM0( 'M0_ESTCOB', oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )

		ElseIf !Empty( oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) )

			xReturn := NGSEEK( 'SA4', oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 1, 'SA4->A4_EST' )
		
		Else
			
			xReturn := Space( FwTamSX3( cField )[ 1 ] )

		EndIf

	ElseIf cField == 'TAT_TELTRA'

		If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) == '1'
			
			xReturn := fPullSM0( 'M0_TEL', oModel:GetOperation() == 3, FWGrpCompany() + FWCodFil() )

		ElseIf !Empty( oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' ) )

			xReturn := NGSEEK( 'SA4', oModel:GetValue( 'SGAA099_TAT', 'TAT_CDTRAN' ), 1, 'SA4->A4_TEL' )
		
		Else
			
			xReturn := Space( FwTamSX3( cField )[ 1 ] )

		EndIf

	ElseIf cField == 'TAT_TPTRAN'

		If oModel:GetOperation() == 3 
			
			xReturn := '1'

		Else
			
			xReturn := oModel:GetValue( 'SGAA099_TAT', 'TAT_TPTRAN' )

		EndIf

	ElseIf cField == 'TAT_PREVEN'

		xReturn := 0
	
	ElseIf cField == 'TAT_STATUS'

		If oModel:GetOperation() == 3 
			
			xReturn := '1'

		Else
			
			xReturn := oModel:GetValue( 'SGAA099_TAT', 'TAT_STATUS' )

		EndIf
	
	ElseIf cField == 'TAT_DTCOMP'
		
		If oModel:GetOperation() == 3 
			
			xReturn := dDataBase

		Else
			
			xReturn := oModel:GetValue( 'SGAA099_TAT', 'TAT_DTCOMP' )

		EndIf

	ElseIf cField == 'TAT_HRCOMP'

		If oModel:GetOperation() == 3 
			
			xReturn := SubStr( Time(), 1, 5 )

		Else
			
			xReturn := oModel:GetValue( 'SGAA099_TAT', 'TAT_HRCOMP' )

		EndIf

	ElseIf cField == 'TAT_NOMREC'

		xReturn := SG280INFD( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'NOME' )

	ElseIf cField == 'TAT_ENDREC'

		xReturn := SG280INFD( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'END' )

	ElseIf cField == 'TAT_CIDREC'

		xReturn := SG280INFD( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'TEL' )

	ElseIf cField == 'TAT_ESTREC'

		xReturn := SG280INFD( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'MUN' )

	ElseIf cField == 'TAT_TELREC'

		xReturn := SG280INFD( oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'EST' )

	ElseIf cField == 'TAT_LICREC'

		xReturn := Posicione( 'TB5', 1, FwxFilial( 'TB5' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' ), 'TB5_CODLAM' )

	ElseIf cField == 'TAT_DESPAD'

		xReturn := '' //Validar

	ElseIf cField == 'TAT_NOMDES'

		xReturn := '' //validar

	ElseIf cField == 'TAT_EMPGER'

		If oModel:GetOperation() == 3
			
			xReturn := FWGrpCompany()

		Else
			
			xReturn := TAT->TAT_EMPGER

		EndIf

	ElseIf cField == 'TAT_NMARMT'
		
		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_NOME' )

	ElseIf cField == 'TAT_ENARMT'
		
		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_END' )

	ElseIf cField == 'TAT_TLARMT'
		
		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_TEL' )
	
	ElseIf cField == 'TAT_MUARMT'
		
		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_MUN' )
	
	ElseIf cField == 'TAT_UFARMT'

		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_EST' )

	Elseif cField == 'TAT_FAARMT'
		
		xReturn := Posicione( 'SA4', 1, FwxFilial( 'SA4' ) + oModel:GetValue( 'SGAA099_TAT', 'TAT_CDARMT' ), 'A4_TELEX' )
	
	ElseIf cField == 'TAT_TPDEST'

		xReturn := '1'

	ElseIf cField == 'TAY_DESCRI'
		
		If oModel:GetOperation() == 3
		
			xReturn := ''

		Else
			
			xReturn := Posicione( 'TFC', 2, FwxFilial( 'TFC' ) + TAY->TAY_IBAMA, 'TFC_DESCRI' )
		
		EndIf

	ElseIf cField == 'TAY_DESCAC'
		
		If oModel:GetOperation() == 3
		
			xReturn := ''

		Else
			
			xReturn := Posicione( 'TH7', 1, FwxFilial( 'TH7' ) + TAY->TAY_ACOND, 'TH7_DESCRI' )
		
		EndIf

	ElseIf cField == 'TAY_DESCTR'
		
		If oModel:GetOperation() == 3
			
			xReturn := ''

		Else

			xReturn := Posicione( 'SX5', 1, FwxFilial( 'SX5' ) + 'DY' + TAY->TAY_TRATA, 'X5_DESCRI' ) 

		EndIf
	
	ElseIf cField == 'TAY_UNIDAD'

		xReturn := ''

	EndIf

Return xReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA099INB
Função responsável por inicializar os valores dos campos no browse

@type   Function

@author Eduardo Mussi
@since  28/05/2025
@param  cField, caracter, Campo a ser carregado

@return Indefinido, Retorna o conteúdo de inicialização do campo
/*/
//-------------------------------------------------------------------
Function SGAA099INB( cField )

	Local xReturn
	
	If cField == 'TAT_NOMGER'

		xReturn := fPullSM0( 'M0_NOMECOM', .F., TAT->TAT_EMPGER + TAT->TAT_FILGER )

	ElseIf cField == 'TAT_NOMTRA'

		xReturn := NGSEEK( 'SA4', TAT->TAT_CDTRAN, 1, 'SA4->A4_NOME' )

	ElseIf cField == 'TAT_NMARMT'

		xReturn := Posicione( 'SA4', 1,FwxFilial( 'SA4' ) + TAT->TAT_CDARMT, 'A4_NOME' )

	ElseIf cField == 'TAT_NOMREC'
		
		xReturn := SG280INFD( TAT->TAT_CODREC, 'NOME' )

	ElseIf cField == 'TAY_DESCRI'
		
		xReturn := '' // TAX_DESCRE - IF(SB1->(DBSEEK(XFILIAL("SB1")+TAX->TAX_CODRES)),SB1->B1_DESC,"")

	ElseIf cField == 'TAY_CLASSE'
		
		xReturn := ''

	ElseIf cField == 'TAY_DENSID'
		
		xReturn := ''

	EndIf

Return xReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fPullSM0
Busca informações na SM0

@type   Function

@author Eduardo Mussi
@since  20/02/2025

@param  cField , Caracter, campo a ser retornado
@param  lNewReg, Lógico  , Define se é inclusão de um novo registro
@param  cKey   , Caracter, Chave de busca( Empresa + Filial )

@return Caracter, Retorna conteúdo da SM0.
/*/
//-------------------------------------------------------------------
Static Function fPullSM0( cField, lNewReg, cKey )

	Local cEmpSM0 := ''
	Local cFilSM0 := ''
 	Local cReturn := ''

	// Validar funcionalidade
	If lNewReg
		
		cEmpSM0 := FWGrpCompany()
		cFilSM0 := FWCodFil()
		
	Else
		
		cEmpSM0 := TAT->TAT_EMPGER
		cFilSM0 := TAT->TAT_FILGER
		
	EndIf

	If !Empty( NGSEEKSM0( cKey, { cField } ) )
	
		cReturn := NGSEEKSM0( cEmpSM0 + cFilSM0, { cField } )[ 1 ]

	EndIf

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fValRes
Inserir descrição

@type   Function

@author Eduardo Mussi
@since  20/02/2025
@param  oModel, Objeto, Objeto ativo do modelo MVC

@return Lógico, Retorna a validação executada no campo TAT_CODREC
/*/
//-------------------------------------------------------------------
Static Function fValRes( oModel )

	Local lReturn := .T.
	Local cCodRec := oModel:GetValue( 'SGAA099_TAT', 'TAT_CODREC' )

	If ExistCpo( 'TB5', cCodRec )
		
		dbSelectArea( 'TC4' )
		dbSetOrder( 1 )
		If MsSeek( FwxFilial( 'TC4' ) + cCodRec + oModel:GetValue( 'SGAA099_TAY', 'TAY_CODRES' ) )
			
			If SuperGetMv( 'MV_NGSGAFA', .F., '2' ) == '1'
			
				dbSelectArea( 'TB5' )
				dbSetOrder( 1 )
				If MsSeek( FwxFilial( 'TB5' ) + cCodRec )
					
					If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPDEST' ) != TB5->TB5_TPRECE .Or. M->TAT_FORNNF != TB5->TB5_FORNEC
					
						If NGIFDBSEEK( 'TA0', TB5->TB5_CODLAM, 1 )
					
							If TA0->TA0_DTVENC >= dDataBase

								oModel:SetValue( 'SGAA099_TAT', 'TAT_TPDEST', TB5->TB5_TPRECE )
								oModel:SetValue( 'SGAA099_TAT', 'TAT_FORNNF', TB5->TB5_FORNEC )
								oModel:SetValue( 'SGAA099_TAT', 'TAT_LOJANF', TB5->TB5_LOJA   )
								oModel:SetValue( 'SGAA099_TAT', 'TAT_NOMDES', SG280INFD( cCodRec, 'NOME' ) )

							Else
								
								Help( ' ', 1, 'Atenção',, 'O receptor se encontra com a data de validade expirada.', 1, 0,,,,,, { 'Por favor, selecione outro receptor.' } )
								lReturn := .F.

							EndIf

						EndIf

					EndIf

					If oModel:GetValue( 'SGAA099_TAT', 'TAT_TPDEST' ) == '1'
						aTrocaF3 := { { 'TAT_FORNNF', 'FOR' } }
					Else
						aTrocaF3 := { { 'TAT_FORNNF', 'SA1' } }
					EndIf

				EndIf

			EndIf
			
		Else
		
			Help( ' ', 1, 'Atenção',, 'O Receptor não possui licenciamento para este resíduo.', 1, 0,,,,,, { 'Por favor, Selecione outro receptor.' } )
			lReturn := .F.
		
		EndIf

	Else
		
		lReturn := .F.

	EndIf

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} TATFILF3
Função responsável por criar o filtro da consulta BIDTAT.

@type   Function

@author Eduardo Mussi
@since  17/03/2025

@return caracter, Filtro a ser aplicado no F3
/*/
//-------------------------------------------------------------------
Function TATFILF3()

	Local oModel  := FWModelActive()

Return BID->BID_FILIAL == FwxFilial( 'BID' ) .And. BID->BID_EST == oModel:GetValue( 'SGAA099_TAT', 'TAT_UFARMT' )


//-------------------------------------------------------------------
/*/{Protheus.doc} fGetPlate
Busca pela placa do veiculo

@type   Function

@author Eduardo Mussi
@since  19/12/2024
@param  cAsset, caracter, Código do veiculo

@return caracter, placa do veiculo
/*/
//-------------------------------------------------------------------
Static Function fGetPlate( cAsset )

	Local cPlate := ''

	dbSelectArea( 'TDM' )
	dbSetOrder( 1 )
	If MsSeek( FwxFilial( 'TDM' ) + cAsset )
		
		dbSelectArea( 'DA3' )
		dbSetOrder( 1 )
		If MsSeek( FwxFilial( 'DA3' ) + TDM->TDM_CODVEI )
			
			cPlate := DA3->DA3_PLACA

		EndIf

	EndIf

Return cPlate

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetEst
Valida o código do estado entre Protheus x Sinir

@type   Function

@author Eduardo Mussi
@since  19/12/2024
@param  cValue, caracter, Código do estado do Protheus

@return numérico, retorna o Código do estado do SINIR
/*/
//-------------------------------------------------------------------
Static Function fGetEst( cValue )

	Local nState  := 0

	/*---------------------------------------------+
	| Protheus  | Descrição | Sinir  | Descrição   |
    | 1         | Sólido    | 4      | Sólido      |
    | 2         | Líquido   | 2      | Líquido     |
    | 3         | Gasoso    | 3      | Gasoso      |
    | 4         | Pastoso   | 1      | Semisólido  |
	+----------------------------------------------*/

	// 1=Solido;2=Liquido;3=Gasoso;4=Pastoso
	If cValue == '1'
		nState := 4
	ElseIf cValue == '2'
		nState := 3
	ElseIf cValue == '3'
		nState := 2
	ElseIf cValue == '4'
		nState := 1
	EndIf

Return nState

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetUn
Valida a unidade entre Protheus x Sinir

@type   Function

@author Eduardo Mussi
@since  03/02/2025
@param  cValue, Caracter, código da medida no Protheus

@return nValue, número do sinir correspondente ao código do Protheus
/*/
//-------------------------------------------------------------------
Static Function fGetUn( cValue )

	Local nValue := 0

	conout( 'cValue - ' + cValue )
	
	If cValue == 'L '
		
		nValue := 21

	ElseIf cValue == 'M3'
		
		nValue := 20

	ElseIf cValue == 'KG'
		
		nValue := 2

	ElseIf cValue == 'TL'
		
		nValue := 3
	
	ElseIf cValue == 'UN'
		
		nValue := 1
		
	EndIf
	
	Conout( 'nvalue - ' + cValToChar( nValue ) )
	
Return nValue

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetTr
Valida tratamento entre os códigos do Protheus e Sinir.

@type   Function

@author Eduardo Mussi
@since  12/12/2025
@param  cTrata, Caracter, Código do tratamento do Protheus

@return Numérico, retorna o código do tratamento no sinir
/*/
//-------------------------------------------------------------------
Static Function fGetTr( cTrata )

	Local nTrata := Val( cTrata )
	
	If cTrata == '004'
		
		nTrata := 60
	
	ElseIf cTrata == '005'
		
		nTrata := 43

	ElseIf cTrata == '007'
		
		nTrata := 26

	EndIf

Return nTrata

//-------------------------------------------------------------------
/*/{Protheus.doc} fCompDate
Responsável por realizar a compatibilização da data para envio ao sinir

@type   Function

@author Eduardo Mussi
@since  10/07/2025
@param  dDate, data, data a ser convertida

@return Numérico, data no formato Unix TimeStamp
/*/
//-------------------------------------------------------------------
Static Function fCompDate( dDate )

	Local cDate     := FWTimeStamp( 4, dDate, SubStr( Time(), 1, 8 ) )
	Local nSizeDate := Len( cDate )
	Local nUnixDate := 0
	
	If nSizeDate == 13
		
		nUnixDate := Val( cDate ) - 10800 // -10800 é referente ao GMT - 3
	
	ElseIf nSizeDate < 13
		
		nAddZero  := 13 - nSizeDate
		nUnixDate := Val( cDate + Replicate( '0', nAddZero ) ) - 10800 // -10800 é referente ao GMT - 3

	EndIf

Return nUnixDate

//---------------------------------------------------------------------
/*/{Protheus.doc} SGAA099F3
Função responsável por criar um F3 com duas tabelas baseado no valor
informado no campo TH8_TIPO

@author Eduardo Mussi
@since  10/09/2025

@return Lógico, valida se o conteúdo informado existe na tabela em questão
/*/
//---------------------------------------------------------------------
Function SGAA099F3()
    
    Local lRet
    //Local oModel  := FWModelActive()

	lRet := ConPad1( ,,, 'NGEMFI',,, .F. )

	If lRet
		
		cRetPriF3 := SM0->M0_CODIGO                                                                                                                                                                                                                                            
		cRetSegF3 := SM0->M0_CODFIL                                                                                                                                                                                                                                            

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAA099F3R
Função responsável por retornar os conteúdos da consulta padrão feita
na função SGAA099F3.

@type   Function

@author Eduardo Mussi
@since  10/09/2025
@param  nReturn, Numérico, 1 - primeiro retorno / 2 - segundo retorno

@return Caracter, Retorna conteúdo selecionado no F3.
/*/
//-------------------------------------------------------------------
Function SGAA099F3R( nReturn )

    Local cReturn

    If nReturn == 1

        cReturn := cRetPriF3
    
    Else

        cReturn := cRetSegF3

    EndIf

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetCodeTR
Busca código da transportadora através do CNPJ

@type   Function

@author Eduardo Mussi
@since  07/11/2025
@param  [lActive], Lógico, Define se a transportadora esta ativa

@return Caracter, Código da transportadora
/*/
//-------------------------------------------------------------------
Static Function fGetCodeTR( lActive )
	
	Local cCodeTR := ''
	Local cCgcEmp := NGSEEKSM0( cEmpAnt + cFilAnt, { 'M0_CGC' } )[ 1 ]

	Default lActive := .F.

	If !Empty( cCgcEmp )

		dbSelectArea( 'SA4' )
		dbSetOrder( 3 )
		If dbSeek( FwxFilial( 'SA4' ) + cCgcEmp )

			dbSelectArea( 'TDL' )
			dbSetOrder( 1 )
			If dbSeek( FwxFilial( 'TDL' ) + SA4->A4_COD )
					
				cCodeTR := TDL->TDL_CODTRA
				lActive := TDL->TDL_STATUS == '1'

			EndIf

		EndIf

	EndIf
	
Return cCodeTR

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpCodIb
Carga inicial dos códigos do Ibama

@type   Function

@author Eduardo Mussi
@since  29/11/2024

/*/
//-------------------------------------------------------------------
Function ImpCodIb()

	Local aCodIb     := {}
	Local cBranchTFC := FwxFilial( 'TFC' )
	Local nCode      := 0
	Local nTotCod    := 0
	Local oModel

	aAdd( aCodIb, { "1","Resíduos da prospecção e exploração de minas e pedreiras, bem como de tratamentos físicos e químicos das matérias extraídas:","","" } )
	aAdd( aCodIb, { "0101","Resíduos da mineração: ","","" } )
	aAdd( aCodIb, { "010101","Resíduos da extração de minérios metálicos","","KG" } )
	aAdd( aCodIb, { "010102","Resíduos da extração de minérios não metálicos","","KG" } )
	aAdd( aCodIb, { "0103","Resíduos da transformação física e química de minérios metálicos: ","","" } )
	aAdd( aCodIb, { "010304(*)","Rejeitados geradores de ácidos, resultantes da transformação de sulfuretos","Perigoso ","KG" } )
	aAdd( aCodIb, { "010305(*)","Outros rejeitados contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "010306","Rejeitados não abrangidos em 01 03 04 e 01 03 05","","KG" } )
	aAdd( aCodIb, { "010307(*)","Outros resíduos contendo substâncias perigosas, resultantes da transformação física e química de minérios metálicos","Perigoso ","KG" } )
	aAdd( aCodIb, { "010308","Poeiras e pós não abrangidos em 01 03 07","","KG" } )
	aAdd( aCodIb, { "010309","Lamas vermelhas da produção de alumina não abrangidas em 01 03 07","","KG" } )
	aAdd( aCodIb, { "010399","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0104","Resíduos da transformação física e química de minérios não metálicos:","","" } )
	aAdd( aCodIb, { "010407(*)","Resíduos contendo substâncias perigosas, resultantes da transformação física e química de minérios não metálicos","Perigoso ","KG" } )
	aAdd( aCodIb, { "010408","Cascalhos e fragmentos de rocha não abrangidos em 01 04 07","","KG" } )
	aAdd( aCodIb, { "010409","Areias e argilas","","KG" } )
	aAdd( aCodIb, { "010410","Poeiras e pós não abrangidos em 01 04 07","","KG" } )
	aAdd( aCodIb, { "010412","Rejeitados e outros resíduos, resultantes da lavagem e limpeza de minérios, não abrangidos em 01 04 07","","KG" } )
	aAdd( aCodIb, { "010413","Resíduos do corte e serragem de pedra não abrangidos em 01 04 07","","KG" } )
	aAdd( aCodIb, { "010499","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0105","Lodos e outros resíduos de perfuração: ","","" } )
	aAdd( aCodIb, { "010504","Lodos e outros resíduos de perfuração contendo água doce","","KG" } )
	aAdd( aCodIb, { "010505(*)","Lodos e outros resíduos de perfuração contendo hidrocarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "010506(*)","Lodos e outros resíduos de perfuração contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "010507","Lodos e outros resíduos de perfuração contendo sais de bário não abrangidos em 01 05 05 e 01 05 06","","KG" } )
	aAdd( aCodIb, { "010508","Lodos e outros resíduos de perfuração contendo cloretos não abrangidos em 01 05 05 e 01 05 06","","KG" } )
	aAdd( aCodIb, { "010599","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "2","Resíduos da agricultura, horticultura, aquicultura, silvicultura, caça e pesca, e da preparação e processamento de produtos alimentares:","","" } )
	aAdd( aCodIb, { "0201","Resíduos da agricultura, horticultura, aquicultura, silvicultura, caça e pesca: ","","" } )
	aAdd( aCodIb, { "020101","Lodos provenientes da lavagem e limpeza ","","KG" } )
	aAdd( aCodIb, { "020102","Resíduos de tecidos animais","","KG" } )
	aAdd( aCodIb, { "020103","Resíduos de tecidos vegetais","","KG" } )
	aAdd( aCodIb, { "020104","Resíduos de plásticos (excluindo embalagens)","","KG" } )
	aAdd( aCodIb, { "020106","Fezes, urina e estrume de animais (incluindo palha suja), efluentes recolhidos separadamente e tratados noutro local","","KG" } )
	aAdd( aCodIb, { "020107","Resíduos silvícolas","","KG" } )
	aAdd( aCodIb, { "020108(*)","Resíduos agrotóxicos e afins (agro-químicos) contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "020109","Resíduos agrotóxicos e afins (agro-químicos) não abrangidos em 02 01 08","","KG" } )
	aAdd( aCodIb, { "020110","Resíduos metálicos, como por exemplo, estruturas metálicas, sucatas metálicas, varas e cabos utilizados em campo","","KG" } )
	aAdd( aCodIb, { "020199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0202","Resíduos da preparação e processamento de carne, peixe e outros produtos alimentares de origem animal: ","","" } )
	aAdd( aCodIb, { "020201","Lodos provenientes da lavagem e limpeza","","KG" } )
	aAdd( aCodIb, { "020202","Resíduos de tecidos animais e orgânico de processo (sebo, soro, ossos, sangue, etc.)","","KG" } )
	aAdd( aCodIb, { "020203","Materiais impróprios para consumo ou processamento","","KG" } )
	aAdd( aCodIb, { "020204","Lodos do tratamento local de efluentes","","KG" } )
	aAdd( aCodIb, { "020299","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0203","Resíduos da preparação e processamento de frutos, legumes, cereais, óleos alimentares, cacau, café, chá e tabaco; resíduos da produção de conservas; resíduos da produção de levedura e extrato de levedura e da preparação e fermentação de melaços:","","" } )
	aAdd( aCodIb, { "020301","Lodos de lavagem, limpeza, descasque, centrifugação e separação","","KG" } )
	aAdd( aCodIb, { "020302","Resíduos de agentes conservantes","","KG" } )
	aAdd( aCodIb, { "020303","Resíduos da extração por solventes","","KG" } )
	aAdd( aCodIb, { "020304","Materiais impróprios para consumo ou processamento","","KG" } )
	aAdd( aCodIb, { "020305","Lodos do tratamento local de efluentes","","KG" } )
	aAdd( aCodIb, { "020399","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0204","Resíduos do processamento de açúcar: ","","" } )
	aAdd( aCodIb, { "020403","Lodos do tratamento local de efluentes","","KG" } )
	aAdd( aCodIb, { "020404","Vinhaça","","KG" } )
	aAdd( aCodIb, { "020405","Bagaço de cana-de-açúcar","","KG" } )
	aAdd( aCodIb, { "020499","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0205","Resíduos da indústria de lacticínios: ","","" } )
	aAdd( aCodIb, { "020501","Materiais impróprios para consumo ou processamento","","KG" } )
	aAdd( aCodIb, { "020502","Lodos do tratamento local de efluentes","","KG" } )
	aAdd( aCodIb, { "020599","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0206","Resíduos da indústria de panificação e confeitaria: ","","" } )
	aAdd( aCodIb, { "020601","Materiais impróprios para consumo ou processamento","","KG" } )
	aAdd( aCodIb, { "020602","Resíduos de agentes conservantes","","KG" } )
	aAdd( aCodIb, { "020603","Lodos do tratamento local de efluentes","","KG" } )
	aAdd( aCodIb, { "020699","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0207","Resíduos da produção de bebidas alcoólicas e não alcoólicas (excluindo café, chá e cacau): - ","","" } )
	aAdd( aCodIb, { "020701","Resíduos da lavagem, limpeza e redução mecânica das matérias-primas","","KG" } )
	aAdd( aCodIb, { "020702","Resíduos da destilação de álcool","","KG" } )
	aAdd( aCodIb, { "020703","Resíduos de tratamentos químicos","","KG" } )
	aAdd( aCodIb, { "020704","Materiais impróprios para consumo ou processamento","","KG" } )
	aAdd( aCodIb, { "020705","Lodos do tratamento local de efluentes","","KG" } )
	aAdd( aCodIb, { "020799","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "3","Resíduos do processamento de madeira e da fabricação de painéis, mobiliário, papel e celulose:","","" } )
	aAdd( aCodIb, { "0301","Resíduos do processamento de madeira e fabricação de painéis e mobiliário: ","","" } )
	aAdd( aCodIb, { "030101","Resíduos do descasque da madeira","","KG" } )
	aAdd( aCodIb, { "030104(*)","Serragem, aparas, fitas de aplainamento, madeira, aglomerados e folheados, contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "030105","Serragem, aparas, fitas de aplainamento, madeira, aglomerados e folheados não abrangidos em 03 01 04","","KG" } )
	aAdd( aCodIb, { "030199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0302","Resíduos da preservação da madeira: ","","" } )
	aAdd( aCodIb, { "030201(*)","Produtos orgânicos não halogenados de preservação da madeira","Perigoso ","KG" } )
	aAdd( aCodIb, { "030202(*)","Agentes organoclorados de preservação da madeira","Perigoso ","KG" } )
	aAdd( aCodIb, { "030203(*)","Agentes organometálicos de preservação da madeira","Perigoso ","KG" } )
	aAdd( aCodIb, { "030204(*)","Agentes inorgânicos de preservação da madeira","Perigoso ","KG" } )
	aAdd( aCodIb, { "030205(*)","Outros agentes de preservação da madeira contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "030206(*)","Efluentes líquidos e resíduos originados no processo de preservação da madeira, provenientes de plantas que utilizam formulações contendo creosoto, com exceção dos efluentes líquidos dos processos de preservação da madeira que usam creosoto e/ou pentaclorofenol","Perigoso ","KG" } )
	aAdd( aCodIb, { "030207(*)","Efluentes líquidos e resíduos originados no processo de preservação da madeira, provenientes de plantas que utilizam ou tenham utilizado formulações clorofenólicas, com exceção dos efluentes líquidos dos processos de preservação da madeira que utilizam creosoto e/ou pentaclorofenol","Perigoso ","KG" } )
	aAdd( aCodIb, { "030208(*)","Efluentes líquidos e resíduos originados no processo de preservação da madeira, provenientes de plantas que utilizam conservantes inorgânicos contendo arsênio ou cromo, com exceção dos efluentes líquidos dos processos de preservação da madeira que usam creosoto e/ou pentaclorofenol","Perigoso ","KG" } )
	aAdd( aCodIb, { "030299","Agentes de preservação da madeira não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0303","Resíduos da produção e da transformação de papel e celulose: ","","" } )
	aAdd( aCodIb, { "030301","Resíduos do descasque de madeira e resíduos de madeira","","KG" } )
	aAdd( aCodIb, { "030302","Lodos da lixívia verde (provenientes da valorização da lixívia de cozimento ou licor negro)","","KG" } )
	aAdd( aCodIb, { "030305","Lodos de branqueamento, provenientes da reciclagem de papel","","KG" } )
	aAdd( aCodIb, { "030307","Rejeitos mecanicamente separados da fabricação de pasta a partir de papel e papelão usado","","KG" } )
	aAdd( aCodIb, { "030308","Resíduos da triagem de papel e papelão destinado a reciclagem","","KG" } )
	aAdd( aCodIb, { "030309","Resíduos de lodos de cal","","KG" } )
	aAdd( aCodIb, { "030310","Rejeitos de fibras e lodos de fibras, fillers e revestimentos, provenientes da separação mecânica","","KG" } )
	aAdd( aCodIb, { "030311","Lodos do tratamento local de efluentes não abrangidas em 03 03 10","","KG" } )
	aAdd( aCodIb, { "030399","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "4","Resíduos da indústria do couro e produtos de couro e da indústria têxtil:","","" } )
	aAdd( aCodIb, { "0401","Resíduos das indústrias do couro e produtos de couro: ","","" } )
	aAdd( aCodIb, { "040101","Resíduos das operações de descarna e divisão de tripa","","KG" } )
	aAdd( aCodIb, { "040102","Resíduos da operação de calagem","","KG" } )
	aAdd( aCodIb, { "040103(*)","Resíduos de desengorduramento contendo solventes sem fase aquosa","Perigoso ","KG" } )
	aAdd( aCodIb, { "040104","Licores de curtimenta contendo cromo","","L" } )
	aAdd( aCodIb, { "040105","Licores de curtimenta sem cromo","","L" } )
	aAdd( aCodIb, { "040106","Lodos, em especial do tratamento local de efluentes, contendo cromo","","KG" } )
	aAdd( aCodIb, { "040107","Lodos, em especial do tratamento local de efluentes, sem cromo","","KG" } )
	aAdd( aCodIb, { "040108","Aparas, serragem e pós de couro provenientes de couros curtidos ao cromo","","KG" } )
	aAdd( aCodIb, { "040109","Resíduos da confecção e acabamentos","","KG" } )
	aAdd( aCodIb, { "040110","Lodo do caleiro","","KG" } )
	aAdd( aCodIb, { "040111(*)","Lodos provenientes do tratamento de efluentes líquidos originados no processo de curtimento de couros ao cromo","Perigoso ","KG" } )
	aAdd( aCodIb, { "040199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0402","Resíduos da indústria têxtil:","","" } )
	aAdd( aCodIb, { "040209","Resíduos de materiais têxteis (têxteis impregnados, elastômeros, plastômeros)","","KG" } )
	aAdd( aCodIb, { "040210","Matéria orgânica de produtos naturais (por exemplo, gordura, cera)","","KG" } )
	aAdd( aCodIb, { "040214(*)","Resíduos dos acabamentos, contendo solventes orgânicos ou contaminados","Perigoso ","KG" } )
	aAdd( aCodIb, { "040215","Resíduos dos acabamentos não abrangidos em 04 02 14","","KG" } )
	aAdd( aCodIb, { "040216(*)","Corantes e pigmentos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "040217","Corantes e pigmentos não abrangidos em 04 02 16","","KG" } )
	aAdd( aCodIb, { "040219(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "040220","Lodos do tratamento local de efluentes não abrangidas em 04 02 19","","KG" } )
	aAdd( aCodIb, { "040221","Resíduos de fibras têxteis não processadas","","KG" } )
	aAdd( aCodIb, { "040222","Resíduos de fibras têxteis processadas","","KG" } )
	aAdd( aCodIb, { "040299","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "5","Resíduos da refinação de petróleo, da purificação de gás natural e do tratamento pirolítico do carvão:","","" } )
	aAdd( aCodIb, { "0501","Resíduos da refinação de petróleo: ","","" } )
	aAdd( aCodIb, { "050102(*)","Lodos de dessalinização","Perigoso ","KG" } )
	aAdd( aCodIb, { "050103(*)","Resíduos provenientes de fundos de tanques empregados na indústria de refino de petróleo, inclusive os sedimentos  do tanque de armazenamento de óleo cru","Perigoso ","KG" } )
	aAdd( aCodIb, { "050104(*)","Lodos alquílicas ácidas","Perigoso ","KG" } )
	aAdd( aCodIb, { "050105(*)","Derrames de hidrocarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "050106(*)","Lodos contendo hidrocarbonetos provenientes de operações de manutenção das instalações ou equipamentos, inclusive lodos provenientes de separadores e da limpeza dos tubos dos trocadores de calor","Perigoso ","KG" } )
	aAdd( aCodIb, { "050107(*)","Alcatrões ácidos","Perigoso ","KG" } )
	aAdd( aCodIb, { "050108(*)","Outros alcatrões","Perigoso ","KG" } )
	aAdd( aCodIb, { "050109(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "050110","Lodos do tratamento local de efluentes não abrangidas em 05 01 09","","KG" } )
	aAdd( aCodIb, { "050111(*)","Resíduos da limpeza de combustíveis com bases","Perigoso ","KG" } )
	aAdd( aCodIb, { "050112(*)","Hidrocarbonetos contendo ácidos","Perigoso ","KG" } )
	aAdd( aCodIb, { "050113","Lodos do tratamento de água para abastecimento de caldeiras","","KG" } )
	aAdd( aCodIb, { "050114","Resíduos de colunas de arrefecimento","","KG" } )
	aAdd( aCodIb, { "050115(*)","Argilas de filtração usadas","Perigoso ","KG" } )
	aAdd( aCodIb, { "050116","Resíduos contendo enxofre da dessulfuração de petróleo","","KG" } )
	aAdd( aCodIb, { "050117","Betumes","","KG" } )
	aAdd( aCodIb, { "050118(*)","Sólidos provenientes da emulsão residual oleosa, inclusive o sobrenadante proveniente de separadores tipo DAF (Dissolved Air Flotation)","Perigoso ","KG" } )
	aAdd( aCodIb, { "050199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0506","Resíduos do tratamento pirolítico do carvão:","","" } )
	aAdd( aCodIb, { "050601(*)","Alcatrões ácidos","Perigoso ","KG" } )
	aAdd( aCodIb, { "050603(*)","Outros alcatrões ","Perigoso ","KG" } )
	aAdd( aCodIb, { "050604","Resíduos de colunas de arrefecimento","","KG" } )
	aAdd( aCodIb, { "050605(*)","Resíduos provenientes dos tanques e lagoas de produção do coque, incluindo os resíduos da coqueificação do carvão ","Perigoso ","KG" } )
	aAdd( aCodIb, { "050606(*)","Resíduos provenientes da recuperação e destilação de subprodutos do coque produzidos a partir do carvão","Perigoso ","KG" } )
	aAdd( aCodIb, { "050607(*)","Resíduos provenientes dos sistemas de tratamento de gases dos processos de coqueificação do carvão e da obtenção de subprodutos de coque produzidos a partir de carvão ","Perigoso ","KG" } )
	aAdd( aCodIb, { "050608(*)","Lodo calcário da destilação da amônia proveniente das operações de coqueificação","Perigoso ","KG" } )
	aAdd( aCodIb, { "050699","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0507","Resíduos da purificação e transporte de gás natural:","","" } )
	aAdd( aCodIb, { "050701(*)","Resíduos contendo mercúrio","Perigoso ","KG" } )
	aAdd( aCodIb, { "050702","Resíduos contendo enxofre","","KG" } )
	aAdd( aCodIb, { "050799","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "6","Resíduos de processos químicos inorgânicos:","","" } )
	aAdd( aCodIb, { "0601","Resíduos da fabricação, formulação, distribuição e utilização de ácidos:","","" } )
	aAdd( aCodIb, { "060101(*)","Ácido sulfúrico e ácido sulfuroso","Perigoso ","KG" } )
	aAdd( aCodIb, { "060102(*)","Ácido clorídrico","Perigoso ","KG" } )
	aAdd( aCodIb, { "060103(*)","Ácido fluorídrico","Perigoso ","KG" } )
	aAdd( aCodIb, { "060104(*)","Ácido fosfórico e ácido fosforoso","Perigoso ","KG" } )
	aAdd( aCodIb, { "060105(*)","Ácido nítrico e ácido nitroso","Perigoso ","KG" } )
	aAdd( aCodIb, { "060106(*)","Outros ácidos","Perigoso ","KG" } )
	aAdd( aCodIb, { "060199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0602","Resíduos da fabricação, formulação, distribuição e utilização de bases: ","","" } )
	aAdd( aCodIb, { "060201(*)","Hidróxido de cálcio","Perigoso ","KG" } )
	aAdd( aCodIb, { "060203(*)","Hidróxido de amônio","Perigoso ","KG" } )
	aAdd( aCodIb, { "060204(*)","Hidróxidos de sódio e de potássio","Perigoso ","KG" } )
	aAdd( aCodIb, { "060205(*)","Outras bases","Perigoso ","KG" } )
	aAdd( aCodIb, { "060299","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0603","Resíduos do fabricação, formulação, distribuição e utilização de sais e suas soluções e de óxidos metálicos: ","","" } )
	aAdd( aCodIb, { "060311(*)","Sais no estado sólido e em soluções contendo cianetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "060313(*)","Sais no estado sólido e em soluções contendo metais pesados","Perigoso ","KG" } )
	aAdd( aCodIb, { "060314","Sais no estado sólido e em soluções não abrangidos em 06 03 11 e  06 03 13","","KG" } )
	aAdd( aCodIb, { "060315(*)","Óxidos metálicos contendo metais pesados","Perigoso ","KG" } )
	aAdd( aCodIb, { "060316","Óxidos metálicos não abrangidos em 06 03 15","","KG" } )
	aAdd( aCodIb, { "060399","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0604","Resíduos contendo metais não abrangidos em 06 03:","","" } )
	aAdd( aCodIb, { "060403(*)","Resíduos contendo arsênio","Perigoso ","KG" } )
	aAdd( aCodIb, { "060404(*)","Resíduos contendo mercúrio","Perigoso ","KG" } )
	aAdd( aCodIb, { "060405(*)","Resíduos contendo outros metais pesados ","Perigoso ","KG" } )
	aAdd( aCodIb, { "060499","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0605","Lodos do tratamento local de efluentes: ","","" } )
	aAdd( aCodIb, { "060502(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "060503","Lodos do tratamento local de efluentes não abrangidas em 06 05 02","","KG" } )
	aAdd( aCodIb, { "0606","Resíduos da fabricação, formulação, distribuição e utilização de produtos e processos químicos do enxofre e de processos de dessulfuração: ","","" } )
	aAdd( aCodIb, { "060602(*)","Resíduos contendo sulfuretos perigosos","Perigoso ","KG" } )
	aAdd( aCodIb, { "060603","Resíduos contendo sulfuretos não abrangidos em 06 06 02","","KG" } )
	aAdd( aCodIb, { "060699","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0607","Resíduos da fabricação, formulação, distribuição e utilização de halogênios e processos químicos dos halogênios: ","","" } )
	aAdd( aCodIb, { "060701(*)","Resíduos de eletrólise contendo amianto","Perigoso ","KG" } )
	aAdd( aCodIb, { "060702(*)","Resíduos de carvão ativado utilizado na produção do cloro","Perigoso ","KG" } )
	aAdd( aCodIb, { "060703(*)","Lodos de sulfato de bário contendo mercúrio","Perigoso ","KG" } )
	aAdd( aCodIb, { "060704(*)","Soluções e ácidos, por exemplo, ácido de contato","Perigoso ","KG" } )
	aAdd( aCodIb, { "060705(*)","Lodos de purificação de salmoura e lodos provenientes do tratamento de efluentes líquidos originados no processo de produção de cloro em células de mercúrio - ","Perigoso ","KG" } )
	aAdd( aCodIb, { "060799","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0609","Resíduos do fabricação, formulação, distribuição e utilização de produtos e processos químicos do fósforo:","","" } )
	aAdd( aCodIb, { "060902","Escórias com fósforo","","KG" } )
	aAdd( aCodIb, { "060903(*)","Resíduos cálcicos de reação contendo ou contaminados com substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "060904","Resíduos cálcicos de reação não abrangidos em 06 09 03","","KG" } )
	aAdd( aCodIb, { "060999","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0610","Resíduos do fabricação, formulação, distribuição e utilização de produtos e processos químicos do azoto e da fabricação de fertilizantes:","","" } )
	aAdd( aCodIb, { "061002(*)","Resíduos contendo substâncias perigosas","","KG" } )
	aAdd( aCodIb, { "061099","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0611","Resíduos da fabricação de pigmentos inorgânicos e opacificantes:","","" } )
	aAdd( aCodIb, { "061101","Resíduos cálcicos de reação da produção de dióxido de titânio","","KG" } )
	aAdd( aCodIb, { "061102(*)","Lodos provenientes do tratamento de efluentes líquidos originados no processo de produção do pigmento branco de dióxido de titânio, por meio do método de cloretos, a partir de minérios que contenham cromo","Perigoso ","KG" } )
	aAdd( aCodIb, { "061103(*)","Resíduos da fabricação e de locais de armazenamento de cloreto férrico a partir de ácidos formados durante a produção do dióxido de titânio, utilizando o processo de ilmenitecloreto","Perigoso ","KG" } )
	aAdd( aCodIb, { "061104(*)","Lodo de tratamento de efluentes líquidos originados na produção dos seguintes pigmentos: laranja e amarelo de cromo, laranja de molibdato, amarelo de zinco, verde de cromo, verde de óxido de cromo (anidro e hidratado), e azul de ferro","Perigoso ","KG" } )
	aAdd( aCodIb, { "061199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0613","Resíduos de processos químicos inorgânicos não anteriormente especificados: ","","" } )
	aAdd( aCodIb, { "061301(*)","Produtos inorgânicos de proteção das plantas, agentes de preservação  da madeira e outros biocidas","Perigoso ","KG" } )
	aAdd( aCodIb, { "061302(*)","Carvão ativado usado (exceto 06 07 02)","Perigoso ","KG" } )
	aAdd( aCodIb, { "061303","Negro de fumo","","KG" } )
	aAdd( aCodIb, { "061304(*)","Resíduos do processamento do amianto, incluindo pós e fibras","Perigoso ","KG" } )
	aAdd( aCodIb, { "061305(*)","Fuligem","Perigoso ","KG" } )
	aAdd( aCodIb, { "061399","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "7","Resíduos de processos químicos orgânicos:","","" } )
	aAdd( aCodIb, { "0701","Resíduos da fabricação, formulação, distribuição e utilização de produtos químicos orgânicos de base: ","","" } )
	aAdd( aCodIb, { "070101(*)","Líquidos de lavagem e efluentes de processo aquosos","Perigoso ","L" } )
	aAdd( aCodIb, { "070103(*)","Solventes, líquidos de lavagem e efluentes orgânicos halogenados","Perigoso ","L" } )
	aAdd( aCodIb, { "070104(*)","Outros solventes, líquidos de lavagem e efluentes orgânicos","Perigoso ","L" } )
	aAdd( aCodIb, { "070107(*)","Resíduos de destilação e resíduos de reação halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070108(*)","Outros resíduos de destilação e resíduos de reação","Perigoso ","KG" } )
	aAdd( aCodIb, { "070109(*)","Absorventes usados e tortas de filtro halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070110(*)","Outros absorventes usados e tortas de filtro","Perigoso ","KG" } )
	aAdd( aCodIb, { "070111(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "070112","Lodos do tratamento local de efluentes não abrangidas em 07 01 11","","KG" } )
	aAdd( aCodIb, { "070199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0702","Resíduos do fabricação, formulação, distribuição e utilização de plásticos, borracha e fibras sintéticas: ","","" } )
	aAdd( aCodIb, { "070201(*)","Líquidos de lavagem e efluentes de processos aquosos","Perigoso ","L" } )
	aAdd( aCodIb, { "070203(*)","Solventes, líquidos de lavagem e efluentes orgânicos halogenados","Perigoso ","L" } )
	aAdd( aCodIb, { "070204(*)","Outros solventes, líquidos de lavagem e efluentes orgânicos","Perigoso ","L" } )
	aAdd( aCodIb, { "070207(*)","Resíduos de destilação e resíduos de reação halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070208(*)","Outros resíduos de destilação e resíduos de reação","Perigoso ","KG" } )
	aAdd( aCodIb, { "070209(*)","Absorventes usados e tortas de filtro halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070210(*)","Outros absorventes usados e tortas de filtro","Perigoso ","KG" } )
	aAdd( aCodIb, { "070211(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "070212","Lodos do tratamento local de efluentes não abrangidas em 07 02 11","","KG" } )
	aAdd( aCodIb, { "070213","Resíduos e refugos de plásticos","","KG" } )
	aAdd( aCodIb, { "070214(*)","Resíduos de aditivos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "070215","Resíduos de aditivos não abrangidos em 07 02 14","","KG" } )
	aAdd( aCodIb, { "070216(*)","Resíduos contendo silicones perigosos","Perigoso ","KG" } )
	aAdd( aCodIb, { "070217","Resíduos contendo silicones que não os mencionados na rubrica 07 02 16","","KG" } )
	aAdd( aCodIb, { "070299","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0703","Resíduos do fabricação, formulação, distribuição e utilização de corantes e pigmentos orgânicos (exceto 06 11): - ","","" } )
	aAdd( aCodIb, { "070301(*)","Líquidos de lavagem e efluentes de processo aquosos","Perigoso ","L" } )
	aAdd( aCodIb, { "070303(*)","Solventes, líquidos de lavagem e efluentes orgânicos halogenados","Perigoso ","L" } )
	aAdd( aCodIb, { "070304(*)","Outros solventes, líquidos de lavagem e efluentes orgânicos","Perigoso ","L" } )
	aAdd( aCodIb, { "070307(*)","Resíduos de destilação e resíduos de reação halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070308(*)","Outros resíduos de destilação e resíduos de reação","Perigoso ","KG" } )
	aAdd( aCodIb, { "070309(*)","Absorventes usados e tortas de filtro halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070310(*)","Outros absorventes usados e tortas de filtro","Perigoso ","KG" } )
	aAdd( aCodIb, { "070311(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "070312","Lodos do tratamento local de efluentes não abrangidas em 07 03 11","","KG" } )
	aAdd( aCodIb, { "070399","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0704","Resíduos do fabricação, formulação, distribuição e utilização de produtos orgânicos de proteção das plantas (exceto 02 01 08 e 02 01 09), agente de preservação da madeira (exceto 03 02) e outros biocidas: ","","" } )
	aAdd( aCodIb, { "070401(*)","Líquidos de lavagem e efluentes de processo aquosos","Perigoso ","L" } )
	aAdd( aCodIb, { "070403(*)","Solventes, líquidos de lavagem e efluentes orgânicos halogenados","Perigoso ","L" } )
	aAdd( aCodIb, { "070404(*)","Outros solventes, líquidos de lavagem e efluentes orgânicos","Perigoso ","L" } )
	aAdd( aCodIb, { "070407(*)","Resíduos de destilação e resíduos de reação halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070408(*)","Outros resíduos de destilação e resíduos de reação","Perigoso ","KG" } )
	aAdd( aCodIb, { "070409(*)","Absorventes usados e tortas de filtro halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070410(*)","Outros absorventes usados e tortas de filtro","Perigoso ","KG" } )
	aAdd( aCodIb, { "070411(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "070412","Lodos do tratamento local de efluentes não abrangidas em 07 04 11","","KG" } )
	aAdd( aCodIb, { "070413(*)","Resíduos sólidos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "070499","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0705","Resíduos da fabricação, formulação, distribuição e utilização de produtos farmacêuticos: ","","" } )
	aAdd( aCodIb, { "070501(*)","Líquidos de lavagem e efluentes de processo aquosos","Perigoso ","L" } )
	aAdd( aCodIb, { "070503(*)","Solventes, líquidos de lavagem e efluentes orgânicos halogenados","Perigoso ","L" } )
	aAdd( aCodIb, { "070504(*)","Outros solventes, líquidos de lavagem e efluentes orgânicos","Perigoso ","L" } )
	aAdd( aCodIb, { "070505(*)","Lodos provenientes do tratamento de efluentes líquidos originados no processo de produção de compostos arseniacais ou organoarseniacais","Perigoso ","KG" } )
	aAdd( aCodIb, { "070506(*)","Resíduos de fundo de destilação originados na etapa de destilação de compostos anilínicos empregados na produção de compostos arseniacais ou organoarseniacais","Perigoso ","KG" } )
	aAdd( aCodIb, { "070507(*)","Resíduos de destilação e resíduos de reação halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070508(*)","Outros resíduos de destilação e resíduos de reação","Perigoso ","KG" } )
	aAdd( aCodIb, { "070509(*)","Carvão ativo usado proveniente da etapa de descoloração da produção de compostos arseniacais ou organoarseniacais","Perigoso ","KG" } )
	aAdd( aCodIb, { "070510(*)","Absorventes usados e tortas de filtro, halogenados ou não-halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070511(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "070512","Lodos do tratamento local de efluentes não abrangidas em 07 05 11","","KG" } )
	aAdd( aCodIb, { "070513(*)","Resíduos sólidos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "070514","Resíduos sólidos não abrangidos em 07 05 13","","KG" } )
	aAdd( aCodIb, { "070599","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0706","Resíduos da fabricação, formulação, distribuição e utilização de gorduras, sabões, detergentes, desinfetantes e cosméticos: ","","" } )
	aAdd( aCodIb, { "070601(*)","Líquidos de lavagem e efluentes de processo aquosos","Perigoso ","L" } )
	aAdd( aCodIb, { "070603(*)","Solventes, líquidos de lavagem e efluentes orgânicos halogenados","Perigoso ","L" } )
	aAdd( aCodIb, { "070604(*)","Outros solventes, líquidos de lavagem e efluentes orgânicos","Perigoso ","L" } )
	aAdd( aCodIb, { "070607(*)","Resíduos de destilação e resíduos de reação halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070608(*)","Outros resíduos de destilação e resíduos de reação","Perigoso ","KG" } )
	aAdd( aCodIb, { "070609(*)","Absorventes usados e tortas de filtro halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070610(*)","Outros absorventes usados e tortas de filtro","Perigoso ","KG" } )
	aAdd( aCodIb, { "070611(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "070612","Lodos do tratamento local de efluentes não abrangidas em 07 06 11","","KG" } )
	aAdd( aCodIb, { "070699","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0707","Resíduos da fabricação, formulação, distribuição e utilização da química fina e de produtos químicos não anteriormente especificados: ","","" } )
	aAdd( aCodIb, { "070701(*)","Líquidos de lavagem e efluentes de processo aquosos","Perigoso ","L" } )
	aAdd( aCodIb, { "070703(*)","Solventes, líquidos de lavagem e efluentes orgânicos halogenados","Perigoso ","L" } )
	aAdd( aCodIb, { "070704(*)","Outros solventes, líquidos de lavagem e efluentes orgânicos","Perigoso ","L" } )
	aAdd( aCodIb, { "070707(*)","Resíduos de destilação e resíduos de reação halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070708(*)","Outros resíduos de destilação e resíduos de reação","Perigoso ","KG" } )
	aAdd( aCodIb, { "070709(*)","Absorventes usados e tortas de filtro halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "070710(*)","Outros absorventes usados e tortas de filtro","Perigoso ","KG" } )
	aAdd( aCodIb, { "070711(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "070712","Lodos do tratamento local de efluentes não abrangidas em 07 07 11","","KG" } )
	aAdd( aCodIb, { "070799","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "8","Resíduos da fabricação, formulação, distribuição e utilização de revestimentos (tintas,  vernizes e esmaltes vítreos), colas, vedantes e tintas de impressão:","","" } )
	aAdd( aCodIb, { "0801","Resíduos da fabricação, formulação, distribuição e utilização e remoção de tintas e vernizes: ","","" } )
	aAdd( aCodIb, { "080111(*)","Resíduos de tintas e vernizes contendo solventes orgânicos ou outras substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "080112","Resíduos de tintas e vernizes não abrangidos em 08 01 11","","KG" } )
	aAdd( aCodIb, { "080113(*)","Lodos de tintas e vernizes contendo solventes orgânicos ou outras substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "080114","Lodos de tintas e vernizes não abrangidas em 08 01 13","","KG" } )
	aAdd( aCodIb, { "080115(*)","Lodos aquosas contendo tintas e vernizes com solventes orgânicos ou outras substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "080116","Lodos aquosas contendo tintas e vernizes não abrangidas em 08 01 15","","KG" } )
	aAdd( aCodIb, { "080117(*)","Resíduos da remoção de tintas e vernizes contendo solventes orgânicos ou outras substâncias perigosas ","Perigoso ","KG" } )
	aAdd( aCodIb, { "080118","Resíduos da remoção de tintas e vernizes não abrangidos em 08 01 17","","KG" } )
	aAdd( aCodIb, { "080119(*)","Suspensões aquosas contendo tintas ou vernizes com solventes orgânicos ou outras substâncias perigosas","Perigoso ","L" } )
	aAdd( aCodIb, { "080120","Suspensões aquosas contendo tintas e vernizes não abrangidas em 08 01 19","","L" } )
	aAdd( aCodIb, { "080121(*)","Resíduos de produtos de remoção de tintas e vernizes","Perigoso ","KG" } )
	aAdd( aCodIb, { "080122(*)","Lodos ou poeiras provenientes do sistema de controle de emissão de gases empregado na produção de tintas","Perigoso ","KG" } )
	aAdd( aCodIb, { "080199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0802","Resíduos da fabricação, formulação, distribuição e utilização de outros revestimentos  (incluindo materiais cerâmicos): ","","" } )
	aAdd( aCodIb, { "080201","Resíduos de revestimentos na forma pulverulenta","","KG" } )
	aAdd( aCodIb, { "080202","Lodos aquosas contendo materiais cerâmicos","","KG" } )
	aAdd( aCodIb, { "080203","Suspensões aquosas contendo materiais cerâmicos","","L" } )
	aAdd( aCodIb, { "080204(*)","Resíduos de revestimentos contendo amianto ","Perigoso ","KG" } )
	aAdd( aCodIb, { "080299","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0803","Resíduos da fabricação, formulação, distribuição e utilização de tintas de impressão:","","" } )
	aAdd( aCodIb, { "080307","Lodos aquosas contendo tintas de impressão","","KG" } )
	aAdd( aCodIb, { "080308","Resíduos líquidos aquosos contendo tintas de impressão","","L" } )
	aAdd( aCodIb, { "080312(*)","Resíduos de tintas de impressão contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "080313","Resíduos de tintas não abrangidos em 08 03 12","","KG" } )
	aAdd( aCodIb, { "080314(*)","Lodos de tintas de impressão contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "080315","Lodos de tintas de impressão não abrangidas em 08 03 14","","KG" } )
	aAdd( aCodIb, { "080316(*)","Resíduos de soluções de água régia","Perigoso ","L" } )
	aAdd( aCodIb, { "080317(*)","Resíduos de tonner de impressão contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "080318","Resíduos de tonner de impressão não abrangidos em 08 03 17","","KG" } )
	aAdd( aCodIb, { "080319(*)","Óleos de dispersão","Perigoso ","L" } )
	aAdd( aCodIb, { "080399","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0804","Resíduos da fabricação, formulação, distribuição e utilização de colas e vedantes (incluindo produtos impermeabilizantes):","","" } )
	aAdd( aCodIb, { "080409(*)","Resíduos de colas ou vedantes contendo solventes orgânicos ou outras substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "080410","Resíduos de colas ou vedantes não abrangidos em 08 04 09","","KG" } )
	aAdd( aCodIb, { "080411(*)","Lodos de colas ou vedantes contendo solventes orgânicos ou outras substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "080412","Lodos de colas ou vedantes não abrangidas em 08 04 11","","KG" } )
	aAdd( aCodIb, { "080413(*)","Lodos aquosos contendo colas ou vedantes com solventes orgânicos ou outras substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "080414","Lodos aquosos contendo colas ou vedantes não abrangidas em 08 04 13","","KG" } )
	aAdd( aCodIb, { "080415(*)","Resíduos líquidos aquosos contendo colas ou vedantes com solventes orgânicos ou outras substâncias perigosas","Perigoso ","L" } )
	aAdd( aCodIb, { "080416","Resíduos líquidos aquosos contendo colas ou vedantes não abrangidos em 08 04 15","","L" } )
	aAdd( aCodIb, { "080417(*)","Óleo de resina","Perigoso ","L" } )
	aAdd( aCodIb, { "080499","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "0805","Outros resíduos não anteriormente especificados em 08: ","","" } )
	aAdd( aCodIb, { "0805 01(*)","Resíduos de isocianatos","Perigoso ","KG" } )
	aAdd( aCodIb, { "9","Resíduos da indústria fotográfica:","","" } )
	aAdd( aCodIb, { "0901","Resíduos da indústria fotográfica:","","" } )
	aAdd( aCodIb, { "090101(*)","Banhos de revelação e ativação de base aquosa","Perigoso ","L" } )
	aAdd( aCodIb, { "090102(*)","Banhos de revelação de chapas litográficas de impressão de base aquosa","Perigoso ","L" } )
	aAdd( aCodIb, { "090103(*)","Banhos de revelação à base de solventes","Perigoso ","L" } )
	aAdd( aCodIb, { "090104(*)","Banhos de fixação","Perigoso ","L" } )
	aAdd( aCodIb, { "090105(*)","Banhos de branqueamento e de fixadores de branqueamento","Perigoso ","L" } )
	aAdd( aCodIb, { "090106(*)","Resíduos contendo prata do tratamento local de resíduos fotográficos","Perigoso ","KG" } )
	aAdd( aCodIb, { "090107","Película e papel fotográfico com prata ou compostos de prata","","KG" } )
	aAdd( aCodIb, { "090108","Película e papel fotográfico sem prata ou compostos de prata","","KG" } )
	aAdd( aCodIb, { "090113(*)","Resíduos líquidos aquosos da recuperação local de prata não abrangidos em 09 01 06","Perigoso ","L" } )
	aAdd( aCodIb, { "090199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "10","Resíduos de processos térmicos:","","" } )
	aAdd( aCodIb, { "1001","Resíduos de centrais elétricas e de outras instalações de combustão (exceto 19): ","","" } )
	aAdd( aCodIb, { "100101","Cinzas, escórias e poeiras de caldeiras (excluída as poeiras de caldeiras abrangidas em 10 01 04)","","KG" } )
	aAdd( aCodIb, { "100102","Cinzas voláteis da combustão de carvão","","KG" } )
	aAdd( aCodIb, { "100103","Cinzas voláteis da combustão de turfa ou madeira não tratada","","KG" } )
	aAdd( aCodIb, { "100104(*)","Cinzas voláteis e poeiras de caldeiras da combustão de hidrocarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "100105","Resíduos cálcicos de reação, na forma sólida, provenientes da dessulfuração de gases de combustão","","KG" } )
	aAdd( aCodIb, { "100107","Resíduos cálcicos de reação, na forma de lodos, provenientes da dessulfuração de gases de combustão","","KG" } )
	aAdd( aCodIb, { "100109(*)","Ácido sulfúrico","Perigoso ","KG" } )
	aAdd( aCodIb, { "100113(*)","Cinzas voláteis da combustão de hidrocarbonetos emulsionados utilizados como combustível","Perigoso ","KG" } )
	aAdd( aCodIb, { "100114(*)","Cinzas, escórias e poeiras de caldeiras de co-incineração contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100115","Cinzas, escórias e poeiras de caldeiras de co-incineração não abrangidas em 10 01 14","","KG" } )
	aAdd( aCodIb, { "100116(*)","Cinzas voláteis de co-incineração contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100117","Cinzas voláteis de co-incineração não abrangidas em 10 01 16","","KG" } )
	aAdd( aCodIb, { "100118(*)","Resíduos de lavagem de gases contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100119","Resíduos de lavagem de gases não abrangidos em 10 01 05, 10 01 07 e 10 01 18","","KG" } )
	aAdd( aCodIb, { "100120(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100121","Lodos do tratamento local de efluentes não abrangidas em 10 01 20","","KG" } )
	aAdd( aCodIb, { "100122(*)","Lodos aquosas provenientes da limpeza de caldeiras contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100123","Lodos aquosas provenientes da limpeza de caldeiras não abrangidas em 10 01 22","","KG" } )
	aAdd( aCodIb, { "100124","Areias de leitos fluidizados","","KG" } )
	aAdd( aCodIb, { "100125","Resíduos do armazenamento de combustíveis e da preparação de centrais elétricas a carvão","","KG" } )
	aAdd( aCodIb, { "100126","Resíduos do tratamento da água de arrefecimento","","KG" } )
	aAdd( aCodIb, { "100199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1002","Resíduos da indústria do ferro e do aço:","","" } )
	aAdd( aCodIb, { "100201","Escória e outros desperdícios da fabricação do ferro e do aço","","KG" } )
	aAdd( aCodIb, { "100202","Escórias de altos-fornos granulada (areia de escória) proveniente da fabricação do ferro e do aço","","KG" } )
	aAdd( aCodIb, { "100203(*)","Lodos ou poeiras provenientes do sistema de controle de emissão de gases empregado na produção de aço primário em fornos elétricos","Perigoso ","KG" } )
	aAdd( aCodIb, { "100207(*)","Resíduos sólidos do tratamento de gases contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100208","Resíduos sólidos do tratamento de gases não abrangidos em 10 02 07","","KG" } )
	aAdd( aCodIb, { "100210","Escamas de laminagem","","KG" } )
	aAdd( aCodIb, { "100211(*)","Resíduos do tratamento da água de arrefecimento contendo hidrocarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "100212","Resíduos do tratamento da água de arrefecimento não abrangidos em 10 02 11","","KG" } )
	aAdd( aCodIb, { "100213(*)","Lodos e tortas de filtro do tratamento de gases contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100214","Lodos e tortas de filtro do tratamento de gases não abrangidos em 10 02 13","","KG" } )
	aAdd( aCodIb, { "100215","Outras lodos e tortas de filtro","","KG" } )
	aAdd( aCodIb, { "100216(*)","Poeiras provenientes do sistema de controle de emissão de gases empregado nos fornos Cubilot empregados na fundição de ferro","Perigoso ","KG" } )
	aAdd( aCodIb, { "100299","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1003","Resíduos da pirometalurgia do alumínio: ","","" } )
	aAdd( aCodIb, { "100302","Resíduos de ânodos","","KG" } )
	aAdd( aCodIb, { "100303(*)","Cátodos usados provenientes da redução de alumínio primário - ","Perigoso ","KG" } )
	aAdd( aCodIb, { "100304(*)","Escórias da produção primária","Perigoso ","KG" } )
	aAdd( aCodIb, { "100305(*)","Resíduos provenientes do desmonte das cubas de redução empregadas na produção de alumínio primário","Perigoso ","KG" } )
	aAdd( aCodIb, { "100306","Resíduos de alumina","","KG" } )
	aAdd( aCodIb, { "100308(*)","Escórias salinas da produção secundária","Perigoso ","KG" } )
	aAdd( aCodIb, { "100309(*)","Impurezas negras da produção secundária","Perigoso ","KG" } )
	aAdd( aCodIb, { "100315(*)","Escumas inflamáveis ou que, em contato com a água, libertam gases inflamáveis em quantidades perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100316","Escumas não abrangidas em 10 03 15","","KG" } )
	aAdd( aCodIb, { "100317(*)","Resíduos da fabricação de ânodos contendo alcatrão","Perigoso ","KG" } )
	aAdd( aCodIb, { "100318","Resíduos da fabricação de ânodos contendo carbono, não abrangidos em 10 03 17","","KG" } )
	aAdd( aCodIb, { "100319(*)","Poeiras de gases de combustão contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100320","Poeiras de gases de combustão não abrangidas em 10 03 19","","KG" } )
	aAdd( aCodIb, { "100321(*)","Outras partículas e poeiras (incluindo poeiras da trituração de escórias) contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100322","Outras partículas e poeiras (incluindo poeiras da trituração de escórias) não abrangidas em 10 03 21","","KG" } )
	aAdd( aCodIb, { "100323(*)","Resíduos sólidos do tratamento de gases contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100324","Resíduos sólidos do tratamento de gases não abrangidos em 10 03 23","","KG" } )
	aAdd( aCodIb, { "100325(*)","Lodos e tortas de filtro do tratamento de gases contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100326","Lodos e tortas de filtro do tratamento de gases não abrangidos em 10 03 25","","KG" } )
	aAdd( aCodIb, { "100327(*)","Resíduos do tratamento da água de arrefecimento contendo hidrocarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "100328","Resíduos do tratamento da água de arrefecimento não abrangidos em 10 03 27","","KG" } )
	aAdd( aCodIb, { "100329(*)","Resíduos do tratamento das escórias salinas e do tratamento das impurezas negras contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100330","Resíduos do tratamento das escórias salinas e do tratamento das impurezas negras não abrangidos em 10 03 29","","KG" } )
	aAdd( aCodIb, { "100399","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1004","Resíduos da pirometalurgia do chumbo:","","" } )
	aAdd( aCodIb, { "100401(*)","Escórias da produção primária e secundária","Perigoso ","KG" } )
	aAdd( aCodIb, { "100402(*)","Impurezas e escumas da produção primária e secundária","Perigoso ","KG" } )
	aAdd( aCodIb, { "100403(*)","Arseniato de cálcio","Perigoso ","KG" } )
	aAdd( aCodIb, { "100404(*)","Lodos, lixívias ou poeiras provenientes do sistema de controle de emissão de gases empregado na produção primária e secundária do chumbo","Perigoso ","KG" } )
	aAdd( aCodIb, { "100405(*)","Outras partículas e poeiras","Perigoso ","KG" } )
	aAdd( aCodIb, { "100406(*)","Resíduos sólidos do tratamento de gases","Perigoso ","KG" } )
	aAdd( aCodIb, { "100407(*)","Lodos e tortas de filtro do tratamento de gases","Perigoso ","KG" } )
	aAdd( aCodIb, { "100409(*)","Resíduos do tratamento da água de arrefecimento contendo hidrocarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "100410","Resíduos do tratamento da água de arrefecimento não abrangidos em 10 04 09","","KG" } )
	aAdd( aCodIb, { "100499","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1005","Resíduos da pirometalurgia do zinco:","","" } )
	aAdd( aCodIb, { "100501","Escórias da produção primária e secundária","","KG" } )
	aAdd( aCodIb, { "100502(*)","Lodos calcários de ânodos eletrolíticos originados na produção de zinco primário","Perigoso ","KG" } )
	aAdd( aCodIb, { "100503(*)","Poeiras de gases de combustão","Perigoso ","KG" } )
	aAdd( aCodIb, { "100504","Outras partículas e poeiras não perigosas","","KG" } )
	aAdd( aCodIb, { "100505(*)","Resíduos sólidos do tratamento de gases","Perigoso ","KG" } )
	aAdd( aCodIb, { "100506(*)","Lodos e tortas de filtro do tratamento de gases","Perigoso ","KG" } )
	aAdd( aCodIb, { "100507(*)","Resíduos provenientes da unidade cádmio (óxido de ferro) do processo de produção de zinco primário","Perigoso ","KG" } )
	aAdd( aCodIb, { "100508(*)","Resíduos do tratamento da água de arrefecimento contendo hidrocarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "100509","Resíduos do tratamento da água de arrefecimento não abrangidos em 10 05 08","","KG" } )
	aAdd( aCodIb, { "100510(*)","Impurezas e escumas inflamáveis ou que, em contato com a água, libertam gases inflamáveis em quantidades perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100511","Impurezas e escumas não abrangidas em 10 05 10","","KG" } )
	aAdd( aCodIb, { "100599","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1006","Resíduos da pirometalurgia do cobre:","","" } )
	aAdd( aCodIb, { "100601","Escórias da produção primária e secundária.","","KG" } )
	aAdd( aCodIb, { "100602","Impurezas e escumas da produção primária e secundária","","KG" } )
	aAdd( aCodIb, { "100603(*)","Poeiras de gases de combustão","Perigoso ","KG" } )
	aAdd( aCodIb, { "100604","Outras partículas e poeiras não perigosas","","KG" } )
	aAdd( aCodIb, { "100606(*)","Resíduos sólidos do tratamento de gases","Perigoso ","KG" } )
	aAdd( aCodIb, { "100607(*)","Lodos e tortas de filtro do tratamento de gases","Perigoso ","KG" } )
	aAdd( aCodIb, { "100609(*)","Resíduos do tratamento da água de arrefecimento contendo hidrocarbonetos, incluindo  lamas e lodos do adensamento da purga ácida do processo de produção de cobre primário","Perigoso ","KG" } )
	aAdd( aCodIb, { "100610","Resíduos do tratamento da água de arrefecimento não abrangidos em 10 06 09","","KG" } )
	aAdd( aCodIb, { "100699","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1007","Resíduos da pirometalurgia da prata, do ouro e da platina:","","" } )
	aAdd( aCodIb, { "100701","Escórias da produção primária e secundária","","KG" } )
	aAdd( aCodIb, { "100702","Impurezas e escumas da produção primária e secundária","","KG" } )
	aAdd( aCodIb, { "100703","Resíduos sólidos do tratamento de gases","","KG" } )
	aAdd( aCodIb, { "100704","Outras partículas e poeiras não perigosas","","KG" } )
	aAdd( aCodIb, { "100705","Lodos e tortas de filtro do tratamento de gases","","KG" } )
	aAdd( aCodIb, { "100707(*)","Resíduos do tratamento da água de arrefecimento contendo hidrocarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "100708","Resíduos do tratamento da água de arrefecimento não abrangidos em 10 07 07","","KG" } )
	aAdd( aCodIb, { "100799","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1008","Resíduos da pirometalurgia de outros metais não ferrosos:","","" } )
	aAdd( aCodIb, { "100804","Partículas e poeiras não perigosas","","KG" } )
	aAdd( aCodIb, { "100808(*)","Escórias salinas da produção primária e secundária","Perigoso ","KG" } )
	aAdd( aCodIb, { "100809","Outras escórias","","KG" } )
	aAdd( aCodIb, { "100810(*)","Impurezas e escumas inflamáveis ou que, em contato com a água, libertam gases inflamáveis em quantidades perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100811","Impurezas e escumas não abrangidas em 10 08 10","","KG" } )
	aAdd( aCodIb, { "100812(*)","Resíduos da fabricação de ânodos contendo alcatrão","Perigoso ","KG" } )
	aAdd( aCodIb, { "100813","Resíduos da fabricação de ânodos contendo carbono não abrangidos em 10 08 12","","KG" } )
	aAdd( aCodIb, { "100814","Resíduos de ânodos","","KG" } )
	aAdd( aCodIb, { "100815(*)","Poeiras de gases de combustão contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100816","Poeiras de gases de combustão não abrangidas em 10 08 15","","KG" } )
	aAdd( aCodIb, { "100817(*)","Lodos e tortas de filtro do tratamento de gases de combustão contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100818","Lodos e tortas de filtro do tratamento de gases de combustão não abrangidos em 10 08 17","","KG" } )
	aAdd( aCodIb, { "100819(*)","Resíduos do tratamento da água de arrefecimento contendo hidrocarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "100820","Resíduos do tratamento da água de arrefecimento não abrangidos em 10 08 19","","KG" } )
	aAdd( aCodIb, { "100899","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1009","Resíduos da fundição de peças ferrosas: ","","" } )
	aAdd( aCodIb, { "100903","Escórias do forno","","KG" } )
	aAdd( aCodIb, { "100905(*)","Moldes e modelos e moldes de fundição não vazados contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100906","Moldes e modelos e moldes de fundição não vazados não abrangidos em 10 09 05","","KG" } )
	aAdd( aCodIb, { "100907(*)","Moldes e modelos e moldes de fundição vazados contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100908","Moldes e modelos e moldes de fundição vazados não abrangidos em 10 09 07","","KG" } )
	aAdd( aCodIb, { "100909(*)","Poeiras de gases de combustão contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100910","Poeiras de gases de combustão não abrangidas em 10 09 09","","KG" } )
	aAdd( aCodIb, { "100911(*)","Outras partículas contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100912","Outras partículas não abrangidas em 10 09 11","","KG" } )
	aAdd( aCodIb, { "100913(*)","Resíduos de aglutinantes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100914","Resíduos de aglutinantes não abrangidos em 10 09 13","","KG" } )
	aAdd( aCodIb, { "100915(*)","Resíduos de agentes indicadores de fendas e trincas contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "100916","Resíduos de agentes indicadores de fendas e trincas não abrangidos em 10 09 15","","KG" } )
	aAdd( aCodIb, { "100999","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1010","Resíduos da fundição de peças não ferrosas: ","","" } )
	aAdd( aCodIb, { "101003","Escórias do forno","","KG" } )
	aAdd( aCodIb, { "101005(*)","Moldes e modelos e moldes de fundição não vazados contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101006","Moldes e modelos e moldes de fundição não vazados não abrangidos em 10 10 05","","KG" } )
	aAdd( aCodIb, { "101007(*)","Moldes e modelos e moldes de fundição vazados contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101008","Moldes e modelos e moldes de fundição vazados não abrangidos em 10 10 07","","KG" } )
	aAdd( aCodIb, { "101009(*)","Poeiras de gases de combustão contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101010","Poeiras de gases de combustão não abrangidas em 10 10 09","","KG" } )
	aAdd( aCodIb, { "101011(*)","Outras partículas contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101012","Outras partículas não abrangidas em 10 10 11","","KG" } )
	aAdd( aCodIb, { "101013(*)","Resíduos de aglutinantes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101014","Resíduos de aglutinantes não abrangidos em 10 10 13","","KG" } )
	aAdd( aCodIb, { "101015(*)","Resíduos de agentes indicadores de fendas e trincas contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101016","Resíduos de agentes indicadores de fendas e trincas não abrangidos em 10 10 15","","KG" } )
	aAdd( aCodIb, { "101099","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1011","Resíduos da fabricação do vidro e de produtos de vidro: ","","" } )
	aAdd( aCodIb, { "101103","Resíduos de materiais fibrosos à base de vidro","","KG" } )
	aAdd( aCodIb, { "101105","Partículas e poeiras","","KG" } )
	aAdd( aCodIb, { "101109(*)","Resíduos da preparação da mistura (antes do processo térmico) contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101110","Resíduos da preparação da mistura (antes do processo térmico) não abrangidos em 10 11 09","","KG" } )
	aAdd( aCodIb, { "101111(*)","Resíduos de vidro em pequenas partículas e em pó de vidro contendo metais pesados (por exemplo, tubos catódicos)","Perigoso ","KG" } )
	aAdd( aCodIb, { "101112","Resíduos de vidro não abrangidos em 10 11 11","","KG" } )
	aAdd( aCodIb, { "101113(*)","Lodos de polimento e retificação de vidro contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101114","Lodos de polimento e retificação de vidro não abrangidas em 10 11 13","","KG" } )
	aAdd( aCodIb, { "101115(*)","Resíduos sólidos do tratamento de gases de combustão contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101116","Resíduos sólidos do tratamento de gases de combustão não abrangidos em 10 11 15","","KG" } )
	aAdd( aCodIb, { "101117(*)","Lodos e tortas de filtro do tratamento de gases de combustão contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101118","Lodos e tortas de filtro do tratamento de gases de combustão não abrangidos em 10 11 17","","KG" } )
	aAdd( aCodIb, { "101119(*)","Resíduos sólidos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101120","Resíduos sólidos do tratamento local de efluentes não abrangidos em 10 11 19","","KG" } )
	aAdd( aCodIb, { "101199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1012","Resíduos da fabricação de peças cerâmicas, tijolos, ladrilhos, telhas e produtos de construção:","","" } )
	aAdd( aCodIb, { "101201","Resíduos da preparação da mistura (antes do processo térmico)","","KG" } )
	aAdd( aCodIb, { "101203","Partículas e poeiras","","KG" } )
	aAdd( aCodIb, { "101205","Lodos e tortas de filtro do tratamento de gases","","KG" } )
	aAdd( aCodIb, { "101206","Moldes fora de uso","","KG" } )
	aAdd( aCodIb, { "101208","Resíduos da fabricação de peças cerâmicas, tijolos, ladrilhos, telhas e produtos de construção (após o processo térmico)","","KG" } )
	aAdd( aCodIb, { "101209(*)","Resíduos sólidos do tratamento de gases contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101210","Resíduos sólidos do tratamento de gases não abrangidos em 10 12 09","","KG" } )
	aAdd( aCodIb, { "101211(*)","Resíduos de vitrificação contendo metais pesados","Perigoso ","KG" } )
	aAdd( aCodIb, { "101212","Resíduos de vitrificação não abrangidos em 10 12 11","","KG" } )
	aAdd( aCodIb, { "101213","Lodos do tratamento local de efluentes","","KG" } )
	aAdd( aCodIb, { "101299","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1013","Resíduos da fabricação de cimento, cal e gesso e de artigos e produtos fabricados a partir deles: ","","" } )
	aAdd( aCodIb, { "101301","Resíduos da preparação da mistura antes do processo térmico","","KG" } )
	aAdd( aCodIb, { "101304","Resíduos da calcinação e hidratação da cal","","KG" } )
	aAdd( aCodIb, { "101306","Partículas e poeiras (exceto 10 13 12 e 10 13 13)","","KG" } )
	aAdd( aCodIb, { "101307","Lodos e tortas de filtro do tratamento de gases","","KG" } )
	aAdd( aCodIb, { "101309(*)","Resíduos da fabricação de fibrocimento contendo amianto","Perigoso ","KG" } )
	aAdd( aCodIb, { "101310","Resíduos da fabricação de fibrocimento não abrangidos em 10 13 09","","KG" } )
	aAdd( aCodIb, { "101311","Resíduos de materiais compósitos à base de cimento não abrangidos em 10 13 09 e 10 13 10","","KG" } )
	aAdd( aCodIb, { "101312(*)","Resíduos sólidos do tratamento de gases contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "101313","Resíduos sólidos do tratamento de gases não abrangidos em 10 13 12","","KG" } )
	aAdd( aCodIb, { "101314","Resíduos de cimento e de lodos de cimento","","KG" } )
	aAdd( aCodIb, { "101399","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1014","Resíduos de crematórios: ","","" } )
	aAdd( aCodIb, { "101401(*)","Resíduos de limpeza de gases contendo mercúrio","Perigoso ","KG" } )
	aAdd( aCodIb, { "11","Resíduos de tratamentos químicos e revestimentos de metais e outros materiais; resíduos da hidrometalurgia de metais não ferrosos:","","" } )
	aAdd( aCodIb, { "1101","Resíduos de tratamentos químicos de superfície e revestimentos de metais e outros materiais (por exemplo, galvanização, zincagem, decapagem, contrastação, fosfatação, desengorduramento alcalino, anodização): ","","" } )
	aAdd( aCodIb, { "110104(*)","Banho de decapagem exaurido proveniente das operações de acabamento do aço","Perigoso ","L" } )
	aAdd( aCodIb, { "110105(*)","Ácidos de decapagem","Perigoso ","KG" } )
	aAdd( aCodIb, { "110106(*)","Ácidos não anteriormente especificados","Perigoso ","KG" } )
	aAdd( aCodIb, { "110107(*)","Bases de decapagem","Perigoso ","KG" } )
	aAdd( aCodIb, { "110108(*)","Lodos de fosfatação","Perigoso ","KG" } )
	aAdd( aCodIb, { "110109(*)","Lodos e tortas de filtro contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "110110","Lodos e tortas de filtro não abrangidos em 11 01 09","","KG" } )
	aAdd( aCodIb, { "110111(*)","Soluções exauridas, lodos e líquidos de lavagem aquosos contendo cianeto e/ou outras substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "110112","Líquidos de lavagem aquosos não abrangidos em 11 01 11","","L" } )
	aAdd( aCodIb, { "110113(*)","Resíduos de desengorduramento contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "110114","Resíduos de desengorduramento não abrangidos em 11 01 13","","KG" } )
	aAdd( aCodIb, { "110115(*)","Eluatos e lodos de sistemas de membranas ou de permuta iônica contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "110116(*)","Resinas de permuta iônica saturadas ou usadas","Perigoso ","KG" } )
	aAdd( aCodIb, { "110198(*)","Outros resíduos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "110199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1102","Resíduos de processos hidrometalúrgicos de metais não ferrosos: ","","" } )
	aAdd( aCodIb, { "110202(*)","Lodos da hidrometalurgia do zinco","Perigoso ","KG" } )
	aAdd( aCodIb, { "110203","Resíduos da produção de ânodos dos processos eletrolíticos aquosos","","KG" } )
	aAdd( aCodIb, { "110205(*)","Resíduos de processos hidrometalúrgicos do cobre contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "110206","Resíduos de processos hidrometalúrgicos do cobre não abrangidos em 11 02 05","","KG" } )
	aAdd( aCodIb, { "110207(*)","Outros resíduos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "110299","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1103","Lodos e sólidos de processos de têmpera:","","" } )
	aAdd( aCodIb, { "110301(*)","Resíduos contendo cianetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "110302(*)","Outros resíduos","Perigoso ","KG" } )
	aAdd( aCodIb, { "110303(*)","Lodos originados no tratamento de efluentes líquidos provenientes dos banhos de têmpera das operações de tratamento térmico de metais nos quais são utilizados cianetos;","Perigoso ","KG" } )
	aAdd( aCodIb, { "1105","Resíduos de processos de galvanização a quente: ","","" } )
	aAdd( aCodIb, { "110501","Escórias e cinzas de zinco não perigosas","","KG" } )
	aAdd( aCodIb, { "110502(*)","Cinzas de zinco contendo cádmio ou chumbo","Perigoso ","KG" } )
	aAdd( aCodIb, { "110503(*)","Resíduos sólidos do tratamento de gases","Perigoso ","KG" } )
	aAdd( aCodIb, { "110504(*)","Fluxantes usados","Perigoso ","KG" } )
	aAdd( aCodIb, { "110599","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "12","Resíduos da moldagem e do tratamento físico e mecânico de superfície de metais e plásticos:","","" } )
	aAdd( aCodIb, { "1201","Resíduos da moldagem e do tratamento físico e mecânico de superfície de metais e plásticos:","","" } )
	aAdd( aCodIb, { "120101","Aparas e limalhas de metais ferrosos","","KG" } )
	aAdd( aCodIb, { "120102","Poeiras e partículas de metais ferrosos","","KG" } )
	aAdd( aCodIb, { "120103","Aparas e limalhas de metais não ferrosos","","KG" } )
	aAdd( aCodIb, { "120104","Poeiras e partículas de metais não ferrosos","","KG" } )
	aAdd( aCodIb, { "120105","Aparas de matérias plásticas","","KG" } )
	aAdd( aCodIb, { "120106(*)","Óleos minerais de corte e usinagem com halogênios (exceto emulsões, misturas e soluções)","Perigoso ","L" } )
	aAdd( aCodIb, { "120107(*)","Óleos minerais de corte e usinagem sem halogênios (exceto emulsões, misturas e soluções)","Perigoso ","L" } )
	aAdd( aCodIb, { "120108(*)","Emulsões, misturas e soluções de corte e usinagem com halogênios","Perigoso ","L" } )
	aAdd( aCodIb, { "120109(*)","Emulsões e soluções de corte e usinagem sem halogênios","Perigoso ","L" } )
	aAdd( aCodIb, { "120110(*)","Óleos sintéticos de corte e usinagem","Perigoso ","L" } )
	aAdd( aCodIb, { "120112(*)","Ceras e gorduras usadas","Perigoso ","KG" } )
	aAdd( aCodIb, { "120113","Resíduos de soldadura","","KG" } )
	aAdd( aCodIb, { "120114(*)","Lodos de usinagem contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "120115","Lodos de usinagem não abrangidas em 12 01 14","","KG" } )
	aAdd( aCodIb, { "120116(*)","Resíduos de materiais de polimento contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "120117","Resíduos de materiais de polimento não abrangidos em 12 01 16","","KG" } )
	aAdd( aCodIb, { "120118(*)","Lodos metálicos (lodos de retificação, superacabamento e lixamento) contendo óleo","Perigoso ","KG" } )
	aAdd( aCodIb, { "120119(*)","Óleos de usinagem facilmente biodegradáveis","Perigoso ","L" } )
	aAdd( aCodIb, { "120120(*)","Mós e materiais de retificação usados contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "120121","Mós e materiais de retificação usados não abrangidos em 12 01 20","","KG" } )
	aAdd( aCodIb, { "120199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1203","Resíduos de processos de desengorduramento a água e a vapor (exceto 11): ","","" } )
	aAdd( aCodIb, { "120301(*)","Líquidos de lavagem aquosos","Perigoso ","L" } )
	aAdd( aCodIb, { "120302(*)","Resíduos de desengorduramento a vapor","Perigoso ","KG" } )
	aAdd( aCodIb, { "13","Óleos usados e resíduos de combustíveis líquidos (exceto óleos alimentares e capítulos 05, 12 e 19):","","" } )
	aAdd( aCodIb, { "1301","Óleos hidráulicos usados: ","","" } )
	aAdd( aCodIb, { "130101(*)","Óleos hidráulicos contendo PCB ([i])","Perigoso ","L" } )
	aAdd( aCodIb, { "130104(*)","Emulsões cloradas","Perigoso ","L" } )
	aAdd( aCodIb, { "130105(*)","Emulsões não cloradas","Perigoso ","L" } )
	aAdd( aCodIb, { "130109(*)","Óleos hidráulicos minerais clorados","Perigoso ","L" } )
	aAdd( aCodIb, { "130110(*)","Óleos hidráulicos minerais não clorados","Perigoso ","L" } )
	aAdd( aCodIb, { "130111(*)","Óleos hidráulicos sintéticos","Perigoso ","L" } )
	aAdd( aCodIb, { "130112(*)","Óleos hidráulicos facilmente biodegradáveis","Perigoso ","L" } )
	aAdd( aCodIb, { "130113(*)","Outros óleos hidráulicos","Perigoso ","L" } )
	aAdd( aCodIb, { "1302","Óleos de motores, transmissões e lubrificação usados ou contaminados:","","" } )
	aAdd( aCodIb, { "130201(*)","Óleos de motores, transmissões e lubrificação usados ou contaminados","Perigoso ","L" } )
	aAdd( aCodIb, { "130299(*)","Outros óleos de motores, transmissões e lubrificação","Perigoso ","L" } )
	aAdd( aCodIb, { "1303","Óleos isolantes, de refrigeração e de transmissão de calor usados: ","","" } )
	aAdd( aCodIb, { "130301(*)","Óleos de isolamento térmico, de refrigeração e de transmissão de calor usados, fluidos dielétricos e resíduos contaminados com bifenilas policloradas (PCB)","Perigoso ","L" } )
	aAdd( aCodIb, { "130306(*)","Óleos minerais isolantes, de refrigeração e de transmissão de calor clorados, não abrangidos em 13 03 01","Perigoso ","L" } )
	aAdd( aCodIb, { "130307(*)","Óleos minerais isolantes, de refrigeração e de transmissão de calor não clorados","Perigoso ","L" } )
	aAdd( aCodIb, { "130308(*)","Óleos sintéticos isolantes, de refrigeração e de transmissão de calor","Perigoso ","L" } )
	aAdd( aCodIb, { "130309(*)","Óleos facilmente biodegradáveis isolantes, de refrigeração e de transmissão de calor","Perigoso ","L" } )
	aAdd( aCodIb, { "130310(*)","Outros óleos isolantes, de refrigeração e de transmissão de calor","Perigoso ","L" } )
	aAdd( aCodIb, { "1304","Óleos bunker usados de navios:","","" } )
	aAdd( aCodIb, { "130401(*)","Óleos bunker de navios de navegação interior","Perigoso ","L" } )
	aAdd( aCodIb, { "130402(*)","Óleos bunker provenientes das canalizações dos cais","Perigoso ","L" } )
	aAdd( aCodIb, { "130403(*)","Óleos bunker de outros tipos de navios","Perigoso ","L" } )
	aAdd( aCodIb, { "1305","Conteúdo de separadores óleo/água: ","","" } )
	aAdd( aCodIb, { "130501(*)","Resíduos sólidos provenientes de desarenadores e de separadores óleo/ água","Perigoso ","KG" } )
	aAdd( aCodIb, { "130502(*)","Lodo proveniente dos separadores óleo/água","Perigoso ","KG" } )
	aAdd( aCodIb, { "130503(*)","Lodo proveniente do interceptor","Perigoso ","KG" } )
	aAdd( aCodIb, { "130506(*)","Óleos provenientes dos separadores óleo/água","Perigoso ","L" } )
	aAdd( aCodIb, { "130507(*)","Água com óleo proveniente dos separadores óleo/água","Perigoso ","L" } )
	aAdd( aCodIb, { "130508(*)","Misturas de resíduos provenientes de desarenadores e de separadores óleo/água","Perigoso ","KG" } )
	aAdd( aCodIb, { "1307","Resíduos de combustíveis líquidos:","","" } )
	aAdd( aCodIb, { "130701(*)","Fuelóleo e óleo diesel","Perigoso ","L" } )
	aAdd( aCodIb, { "130702(*)","Gasolina","Perigoso ","L" } )
	aAdd( aCodIb, { "130703(*)","Outros combustíveis (incluindo misturas)","Perigoso ","L" } )
	aAdd( aCodIb, { "1308","Outros óleos usados não anteriormente especificados:","","" } )
	aAdd( aCodIb, { "130801(*)","Lodos ou emulsões de dessalinização","Perigoso ","KG" } )
	aAdd( aCodIb, { "130802(*)","Outras emulsões e misturas","Perigoso ","KG" } )
	aAdd( aCodIb, { "130899(*)","Outros resíduos não anteriormente especificados","Perigoso ","KG" } )
	aAdd( aCodIb, { "14","Resíduos de solventes, fluidos de refrigeração e gases propulsores orgânicos (exceto 07 e 08):","","" } )
	aAdd( aCodIb, { "1406","Resíduos de solventes, fluidos de refrigeração e gases propulsores de espumas/ aerossóis orgânicos: ","","" } )
	aAdd( aCodIb, { "140601(*)","Clorofluorcarbonetos (CFC), HCFC, HFC","Perigoso ","KG" } )
	aAdd( aCodIb, { "140602(*)","Outros solventes e misturas de solventes halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "140603(*)","Outros solventes e misturas de solventes","Perigoso ","KG" } )
	aAdd( aCodIb, { "140604(*)","Lodos ou resíduos sólidos contendo solventes halogenados","Perigoso ","KG" } )
	aAdd( aCodIb, { "140605(*)","Lodos ou resíduos sólidos contendo outros solventes","Perigoso ","KG" } )
	aAdd( aCodIb, { "15","Resíduos de embalagens; absorventes, panos de limpeza, materiais filtrantes e vestuário de proteção não anteriormente especificados:","","" } )
	aAdd( aCodIb, { "1501","Embalagens (incluindo resíduos urbanos e equiparados de embalagens, recolhidos separadamente)([ii]):","","" } )
	aAdd( aCodIb, { "150101","Embalagens de papel e cartão","","KG" } )
	aAdd( aCodIb, { "150102","Embalagens de plástico","","KG" } )
	aAdd( aCodIb, { "150103","Embalagens de madeira","","KG" } )
	aAdd( aCodIb, { "150104","Embalagens de metal","","KG" } )
	aAdd( aCodIb, { "150105","Embalagens longa-vida","","KG" } )
	aAdd( aCodIb, { "150106","Misturas de embalagens","","KG" } )
	aAdd( aCodIb, { "150107","Embalagens de vidro","","KG" } )
	aAdd( aCodIb, { "150109","Embalagens têxteis","","KG" } )
	aAdd( aCodIb, { "150110(*)","Embalagens de qualquer um dos tipos acima descritos contendo ou contaminadas por resíduos de substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "150111(*)","Embalagens de metal, incluindo recipientes vazios sob pressão, com uma matriz porosa sólida perigosa (por exemplo, amianto) ","Perigoso ","KG" } )
	aAdd( aCodIb, { "1502","Absorventes, materiais filtrantes, panos de limpeza e vestuário de proteção: ","","" } )
	aAdd( aCodIb, { "150202(*)","Absorventes, materiais filtrantes (incluindo filtros de óleo não anteriormente especificados), panos de limpeza e vestuário de proteção, contaminados por substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "150203","Absorventes, materiais filtrantes, panos de limpeza e vestuário de proteção não abrangidos em 15 02 02","","KG" } )
	aAdd( aCodIb, { "16","Resíduos não especificados em outros capítulos desta Lista:","","" } )
	aAdd( aCodIb, { "1601","Veículos em fim de vida de diferentes meios de transporte (incluindo máquinas todo o terreno) e resíduos do desmantelamento/desmanche de veículos em fim de vida e da manutenção de veículos (exceto 13, 14, 16 06 e 16 08): ","","" } )
	aAdd( aCodIb, { "160103(*)","Veículos em fim de vida","Perigoso ","KG" } )
	aAdd( aCodIb, { "160104","Veículos em fim de vida esvaziados de líquidos e outros componentes perigosos","","KG" } )
	aAdd( aCodIb, { "160106(*)","Resíduo proveniente da trituração de veículos em fim de vida (Ash Shredder Residue)","Perigoso ","KG" } )
	aAdd( aCodIb, { "160107(*)","Filtros de óleo automotivos","Perigoso ","KG" } )
	aAdd( aCodIb, { "160108(*)","Componentes e peças contendo mercúrio","Perigoso ","KG" } )
	aAdd( aCodIb, { "160109(*)","Componentes e peças contendo PCB","Perigoso ","KG" } )
	aAdd( aCodIb, { "160110(*)","Componentes explosivos, por exemplo, almofadas de ar (air bags)","Perigoso ","KG" } )
	aAdd( aCodIb, { "160111(*)","Pastilhas de freio contendo amianto","Perigoso ","KG" } )
	aAdd( aCodIb, { "160112","Pastilhas de freio não abrangidas em 16 01 11","","KG" } )
	aAdd( aCodIb, { "160113(*)","Fluidos de freio","Perigoso ","KG" } )
	aAdd( aCodIb, { "160114(*)","Fluidos anticongelantes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "160115","Fluidos anticongelantes não abrangidos em 16 01 14","","KG" } )
	aAdd( aCodIb, { "160116","Recipientes para gás liquefeito sob pressão","","KG" } )
	aAdd( aCodIb, { "160117","Sucatas metálicas ferrosas","","KG" } )
	aAdd( aCodIb, { "160118","Sucatas metálicas não ferrosas","","KG" } )
	aAdd( aCodIb, { "160119","Plástico","","KG" } )
	aAdd( aCodIb, { "160120","Vidro","","KG" } )
	aAdd( aCodIb, { "160121(*)","Componentes perigosos não abrangidos em 16 01 07 a 16 01 11, 16 01 13 e 16 01 14","Perigoso ","KG" } )
	aAdd( aCodIb, { "160122","Componentes não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "160123","Pneus inservíveis/usados aeronáuticos","","KG" } )
	aAdd( aCodIb, { "160124","Pneus inservíveis/usados de automóveis","","KG" } )
	aAdd( aCodIb, { "160125","Pneus inservíveis/usados de bicicletas","","KG" } )
	aAdd( aCodIb, { "160126","Pneus inservíveis/usados de caminhões/ônibus","","KG" } )
	aAdd( aCodIb, { "160127","Pneus inservíveis/usados de motocicletas","","KG" } )
	aAdd( aCodIb, { "160128","Pneus inservíveis/usados de tratores","","KG" } )
	aAdd( aCodIb, { "160129","Pneus inservíveis/usados outras aplicações","","KG" } )
	aAdd( aCodIb, { "160199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1602","Resíduos de equipamento elétrico e eletrônico: ","","" } )
	aAdd( aCodIb, { "160209(*)","Transformadores, capacitores e demais equipamentos elétricos contendo PCB","Perigoso ","KG" } )
	aAdd( aCodIb, { "160210(*)","Equipamento fora de uso contendo ou contaminado por PCB não abrangido em 16 02 09","Perigoso ","KG" } )
	aAdd( aCodIb, { "160211(*)","Equipamento fora de uso contendo clorofluorcarbonetos, HCFC, HFC","Perigoso ","KG" } )
	aAdd( aCodIb, { "160212(*)","Equipamento fora de uso contendo amianto livre","Perigoso ","KG" } )
	aAdd( aCodIb, { "160213(*)","Equipamento fora de uso contendo componentes perigosos não abrangidos em 16 02 09 a 16 02 12","Perigoso ","KG" } )
	aAdd( aCodIb, { "160214","Equipamento fora de uso não abrangido em 16 02 09 a 16 02 13","","KG" } )
	aAdd( aCodIb, { "160215(*)","Componentes perigosos retirados de equipamento fora de uso","Perigoso ","KG" } )
	aAdd( aCodIb, { "160216","Componentes retirados de equipamento fora de uso não abrangidos em 16 02 15","","KG" } )
	aAdd( aCodIb, { "1603","Produtos fora de especificação e produtos vencidos ou não utilizados:","","" } )
	aAdd( aCodIb, { "160303(*)","Resíduos inorgânicos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "160304","Resíduos inorgânicos não abrangidos em 16 03 03","","KG" } )
	aAdd( aCodIb, { "160305(*)","Resíduos orgânicos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "160306","Resíduos orgânicos não abrangidos em 16 03 05","","KG" } )
	aAdd( aCodIb, { "1604","Resíduos de explosivos:","","" } )
	aAdd( aCodIb, { "160401(*)","Resíduos de munições","Perigoso ","KG" } )
	aAdd( aCodIb, { "160402(*)","Resíduos de fogo de artifício","Perigoso ","KG" } )
	aAdd( aCodIb, { "160403(*)","Lodos provenientes do tratamento de efluentes líquidos originados no processamento e produção de explosivos","Perigoso ","KG" } )
	aAdd( aCodIb, { "160405(*)","Carvão usado proveniente do tratamento de efluentes líquidos que contenham explosivos–","Perigoso ","KG" } )
	aAdd( aCodIb, { "160406(*)","Água rosa/vermelha proveniente das operações de TNT","Perigoso ","L" } )
	aAdd( aCodIb, { "160499(*)","Outros resíduos de explosivos","Perigoso ","KG" } )
	aAdd( aCodIb, { "1605","Gases em recipientes sob pressão e produtos químicos fora de uso: ","","" } )
	aAdd( aCodIb, { "160504(*)","Gases em recipientes sob pressão (incluindo freons e halons) contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "160505","Gases em recipientes sob pressão não abrangidos em 16 05 04","","KG" } )
	aAdd( aCodIb, { "160506(*)","Produtos químicos de laboratório contendo ou compostos por substâncias perigosas, incluindo misturas de produtos químicos de laboratório","Perigoso ","KG" } )
	aAdd( aCodIb, { "160507(*)","Produtos químicos inorgânicos de laboratório contendo ou compostos por substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "160508(*)","Produtos químicos orgânicos fora de uso contendo ou compostos por substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "160509","Produtos químicos fora de uso não abrangidos em 16 05 06, 16 05 07 ou 16 05 08","","KG" } )
	aAdd( aCodIb, { "1606","Pilhas, baterias e acumuladores elétricos: ","","" } )
	aAdd( aCodIb, { "160601(*)","Bateria e acumuladores elétricos à base de chumbo e seus resíduos, incluindo os plásticos provenientes da carcaça externa da bateria","Perigoso ","KG" } )
	aAdd( aCodIb, { "160602(*)","Bateria e acumuladores elétricos de níquel-cádmio e seus resíduos","Perigoso ","KG" } )
	aAdd( aCodIb, { "160603(*)","Pilhas contendo mercúrio","Perigoso ","KG" } )
	aAdd( aCodIb, { "160604","Pilhas alcalinas (exceto 16 06 03) ([iii])","","KG" } )
	aAdd( aCodIb, { "160605","Outras pilhas, baterias e acumuladores","","KG" } )
	aAdd( aCodIb, { "160606(*)","Eletrólitos de pilhas e acumuladores recolhidos separadamente","Perigoso ","KG" } )
	aAdd( aCodIb, { "1607","Resíduos da limpeza de tanques de transporte, de depósitos de armazenagem e de barris (exceto 05 e 13): ","","" } )
	aAdd( aCodIb, { "160708(*)","Resíduos contendo hidrocarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "160709(*)","Resíduos contendo outras substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "160799","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1608","Catalisadores usados:","","" } )
	aAdd( aCodIb, { "160801","Catalisadores usados contendo ouro, prata, rênio, ródio, paládio, irídio ou platina (exceto 16 08 07)","","KG" } )
	aAdd( aCodIb, { "160802(*)","Catalisadores usados contendo metais de transição ([iv]) ou compostos de metais de transição perigosos","Perigoso ","KG" } )
	aAdd( aCodIb, { "160803","Catalisadores usados contendo metais de transição ou compostos de metais de transição não especificados de outra forma","","KG" } )
	aAdd( aCodIb, { "160804","Catalisadores usados de cracking catalítico em leito fluidizado (exceto 16 08 99)","","KG" } )
	aAdd( aCodIb, { "160805(*)","Catalisadores usados contendo ácido fosfórico","Perigoso ","KG" } )
	aAdd( aCodIb, { "160806(*)","Líquidos usados utilizados como catalisadores","Perigoso ","L" } )
	aAdd( aCodIb, { "160807(*)","Catalisadores  usados provenientes do reator de hidrocloração utilizado na produção de 1,1,1-tricloroetano","Perigoso ","KG" } )
	aAdd( aCodIb, { "160808(*)","Catalisador gasto proveniente do hidrotratamento das operações de refino de petróleo, incluindo leitos usados para dessulfurizar as alimentações para outros reatores catalíticos (este código não inclui o meio de suporte inerte)","Perigoso ","KG" } )
	aAdd( aCodIb, { "160899(*)","Outros catalisadores usados contaminados com substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "1609","Substâncias oxidantes: ","","" } )
	aAdd( aCodIb, { "160901(*)","Permanganatos, por exemplo, permanganato de potássio","Perigoso ","KG" } )
	aAdd( aCodIb, { "160902(*)","Cromatos, por exemplo, cromato de potássio, dicromato de potássio ou de sódio","Perigoso ","KG" } )
	aAdd( aCodIb, { "160903(*)","Peróxidos, por exemplo, água oxigenada","Perigoso ","KG" } )
	aAdd( aCodIb, { "160904(*)","Substâncias oxidantes não anteriormente especificadas","Perigoso ","KG" } )
	aAdd( aCodIb, { "1610","Resíduos líquidos aquosos destinados a serem tratados noutro local: ","","" } )
	aAdd( aCodIb, { "161001(*)","Resíduos líquidos aquosos contendo substâncias perigosas","Perigoso ","L" } )
	aAdd( aCodIb, { "161002","Resíduos líquidos aquosos não abrangidos em 16 10 01","","L" } )
	aAdd( aCodIb, { "161003(*)","Concentrados aquosos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "161004","Concentrados aquosos não abrangidos em 16 10 03","","KG" } )
	aAdd( aCodIb, { "1611","Resíduos de revestimentos de fornos e refratários:","","" } )
	aAdd( aCodIb, { "161101(*)","Revestimentos de fornos e refratários à base de carbono provenientes de processos metalúrgicos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "161102","Revestimentos de fornos e refratários à base de carbono não abrangidos em 16 11 01","","KG" } )
	aAdd( aCodIb, { "161103(*)","Outros revestimentos de fornos e refratários provenientes de processos metalúrgicos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "161104","Outros revestimentos de fornos e refratários não abrangidos em 16 11 03","","KG" } )
	aAdd( aCodIb, { "161105(*)","Revestimentos de fornos e refratários provenientes de processos não metalúrgicos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "161106","Revestimentos de fornos e refratários provenientes de processos não metalúrgicos não abrangidos em 16 11 05","","KG" } )
	aAdd( aCodIb, { "17","Resíduos de construção e demolição (incluindo solos escavados de locais contaminados):","","" } )
	aAdd( aCodIb, { "1701","Cimento, tijolos, ladrilhos, telhas e materiais cerâmicos:","","" } )
	aAdd( aCodIb, { "170101","Resíduos de cimento","","KG" } )
	aAdd( aCodIb, { "170102","Tijolos","","KG" } )
	aAdd( aCodIb, { "170103","Ladrilhos, telhas e materiais cerâmicos","","KG" } )
	aAdd( aCodIb, { "170106(*)","Misturas ou frações separadas de cimento, tijolos, ladrilhos, telhas e materiais cerâmicos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "170107","Misturas de cimento, tijolos, ladrilhos, telhas e materiais cerâmicos não abrangidas em 17 01 06","","KG" } )
	aAdd( aCodIb, { "1702","Madeira, vidro e plástico: ","","" } )
	aAdd( aCodIb, { "170201","Madeira","","KG" } )
	aAdd( aCodIb, { "170202","Vidro","","KG" } )
	aAdd( aCodIb, { "170203","Plástico","","KG" } )
	aAdd( aCodIb, { "170204(*)","Vidro, plástico e madeira, misturados ou não, contendo ou contaminados com substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "1703","Misturas betuminosas, asfalto e produtos de alcatrão: ","","" } )
	aAdd( aCodIb, { "170301(*)","Misturas betuminosas contendo alcatrão","Perigoso ","KG" } )
	aAdd( aCodIb, { "170302","Misturas betuminosas não abrangidas em 17 03 01","","KG" } )
	aAdd( aCodIb, { "170303(*)","Asfalto e produtos de alcatrão","Perigoso ","KG" } )
	aAdd( aCodIb, { "1704","Sucatas metálicas (incluindo ligas): ","","" } )
	aAdd( aCodIb, { "170401","Cobre, bronze e latão","","KG" } )
	aAdd( aCodIb, { "170402","Alumínio","","KG" } )
	aAdd( aCodIb, { "170403","Chumbo","","KG" } )
	aAdd( aCodIb, { "170404","Zinco","","KG" } )
	aAdd( aCodIb, { "170405","Ferro e aço","","KG" } )
	aAdd( aCodIb, { "170406","Estanho","","KG" } )
	aAdd( aCodIb, { "170407","Mistura de sucatas","","KG" } )
	aAdd( aCodIb, { "170409(*)","Resíduos metálicos contaminados com substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "170410(*)","Cabos contendo hidrocarbonetos, alcatrão ou outras substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "170411","Cabos não abrangidos em 17 04 10","","KG" } )
	aAdd( aCodIb, { "170412","Magnésio","","KG" } )
	aAdd( aCodIb, { "170413","Níquel","","KG" } )
	aAdd( aCodIb, { "1705","Solos (incluindo solos escavados de locais contaminados), rochas e lodos de dragagem:","","" } )
	aAdd( aCodIb, { "170502(*)","Solos e rochas contendo contaminados combifenilas policloradas (PCB)","Perigoso ","KG" } )
	aAdd( aCodIb, { "170503(*)","Solos e rochas contendo outras substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "170504","Solos e rochas não abrangidos em 17 05 03","","KG" } )
	aAdd( aCodIb, { "170505(*)","Lodos de dragagem contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "170506","Lodos de dragagem não abrangidas em 17 05 05","","KG" } )
	aAdd( aCodIb, { "170507(*)","Britas de linhas ferroviárias contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "170508","Britas de linhas de ferroviárias  não abrangidos em 17 05 07","","KG" } )
	aAdd( aCodIb, { "170509(*)","Resíduos resultantes da incineração ou tratamento térmico de solos contaminados por substâncias orgânicas perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "1706","Materiais de isolamento e materiais de construção contendo amianto: ","","" } )
	aAdd( aCodIb, { "170601(*)","Materiais de isolamento contendo amianto","Perigoso ","KG" } )
	aAdd( aCodIb, { "170603(*)","Outros materiais de isolamento contendo ou constituídos por substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "170604","Materiais de isolamento não abrangidos em 17 06 01 e 17 06 03","","KG" } )
	aAdd( aCodIb, { "170605(*)","Materiais de construção contendo amianto (por exemplo, telhas, tubos, etc.) ","Perigoso ","KG" } )
	aAdd( aCodIb, { "1708","Materiais de construção à base de gesso: ","","" } )
	aAdd( aCodIb, { "170801(*)","Materiais de construção à base de gesso contaminados com substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "170802","Materiais de construção à base de gesso não abrangidos em 17 08 01","","KG" } )
	aAdd( aCodIb, { "1709","Outros resíduos de construção e demolição:","","" } )
	aAdd( aCodIb, { "170901(*)","Resíduos de construção e demolição contendo mercúrio","Perigoso ","KG" } )
	aAdd( aCodIb, { "170902(*)","Resíduos de construção e demolição contendo PCB (por exemplo, vedantes com PCB, revestimentos de piso à base de resinas com PCB, condensadores de uso doméstico com PCB)","Perigoso ","KG" } )
	aAdd( aCodIb, { "170903(*)","Outros resíduos de construção e demolição (incluindo misturas de resíduos) contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "170904","Mistura de resíduos de construção e demolição não abrangidos em 17 09 01, 17 09 02 e 17 09 03","","KG" } )
	aAdd( aCodIb, { "18","Resíduos dos serviços de saúde","","" } )
	aAdd( aCodIb, { "1801","Resíduos com a possível presença de agentes  biológicos que, por suas características de maior virulência ou concentração, podem apresentar risco de infecção:","","" } )
	aAdd( aCodIb, { "180101(*)","Culturas e estoques de microrganismos; resíduos de fabricação de produtos  biológicos, exceto os hemoderivados; descarte de vacinas de microrganismos vivos ou atenuados; meios de cultura e instrumentais utilizados para transferência, inoculação ou mistura de culturas; resíduos de laboratórios de  manipulação genética","Perigoso ","KG" } )
	aAdd( aCodIb, { "180102(*)","Resíduos resultantes da atenção à saúde de indivíduos ou animais, com suspeita ou certeza de contaminação biológica por agentes com elevado risco individual e elevado risco para a comunidade, microrganismos com relevância epidemiológica e risco de disseminação ou causador de doença emergente que se torne epidemiologicamente importante ou cujo mecanismo de transmissão seja desconhecido","Perigoso ","KG" } )
	aAdd( aCodIb, { "180103(*)","Bolsas transfusionais contendo sangue ou hemocomponentes rejeitadas por contaminação ou por má conservação, ou com prazo de validade vencido, e aquelas oriundas de coleta incompleta","Perigoso ","KG" } )
	aAdd( aCodIb, { "180104(*)","Sobras de amostras de laboratório contendo sangue ou líquidos corpóreos, recipientes e materiais resultantes do processo de assistência à saúde, contendo sangue ou líquidos corpóreos na forma livre","Perigoso ","KG" } )
	aAdd( aCodIb, { "180105(*)","Carcaças, peças anatômicas, vísceras e outros resíduos provenientes de animais submetidos a processos de experimentação com inoculação de microorganismos, bem como suas forrações, e os cadáveres de animais suspeitos de serem portadores de microrganismos de relevância epidemiológica e com risco de disseminação, que foram submetidos ou não a estudo anátomo-patológico ou con?rmação diagnóstica","Perigoso ","KG" } )
	aAdd( aCodIb, { "180106(*)","Peças anatômicas (membros) do ser humano; produto de fecundação sem sinais vitais, com peso menor que 500 gramas ou estatura menor que 25 cm ou idade gestacional menor que 20 semanas, que não tenham valor científico ou legal e não tenha havido requisição pelo paciente ou familiares","Perigoso ","KG" } )
	aAdd( aCodIb, { "180107(*)","Kits de linhas arteriais, endovenosas e dialisadores, quando descartados;","Perigoso ","KG" } )
	aAdd( aCodIb, { "180108(*)","Filtros de ar e gases aspirados de área contaminada; membrana filtrante de equipamento médico hospitalar e de pesquisa, entre outros similares","Perigoso ","KG" } )
	aAdd( aCodIb, { "180109(*)","Sobras de amostras de laboratório e seus recipientes contendo fezes, urina e secreções, provenientes de pacientes que não contenham e nem sejam suspeitos de conter agentes com elevado risco individual e elevado risco para a comunidade, e nem apresentem relevância epidemiológica e risco de disseminação, ou microrganismo causador de doença emergente que se torne epidemiologicamente importante ou cujo mecanismo de transmissão seja desconhecido ou com suspeita de contaminação com príons","Perigoso ","KG" } )
	aAdd( aCodIb, { "180110(*)","Resíduos de tecido adiposo proveniente de lipoaspiração, lipoescultura ou outro procedimento de cirurgia plástica que gere este  tipo de resíduo","Perigoso ","KG" } )
	aAdd( aCodIb, { "180111(*)","Recipientes e materiais resultantes do processo de assistência à saúde, que não contenha sangue ou líquidos corpóreos na forma livre","Perigoso ","KG" } )
	aAdd( aCodIb, { "180112(*)","Peças anatômicas (órgãos e tecidos) e outros resíduos provenientes de procedimentos cirúrgicos ou de estudos anátomo-patológicos ou de confirmação diagnóstica","Perigoso ","KG" } )
	aAdd( aCodIb, { "180113(*)","Carcaças, peças anatômicas, vísceras e outros resíduos provenientes de animais não submetidos a processos de experimentação com inoculação de microorganismos, bem como suas forrações","Perigoso ","KG" } )
	aAdd( aCodIb, { "180114(*)","Bolsas transfusionais vazias ou com  volume residual pós-transfusão","Perigoso ","KG" } )
	aAdd( aCodIb, { "180115(*)","Órgãos, tecidos, fluidos  orgânicos, materiais perfurocortantes ou escarificantes e demais materiais resultantes da atenção à saúde de indivíduos ou animais, com suspeita ou certeza de contaminação com príons","Perigoso ","KG" } )
	aAdd( aCodIb, { "1802","Resíduos contendo substâncias químicas que podem apresentar risco à saúde  pública ou ao meio ambiente, dependendo de suas características de inflamabilidade, corrosividade, reatividade e toxicidade:","","" } )
	aAdd( aCodIb, { "180201(*)","Produtos hormonais e produtos antimicrobianos; citostáticos; antineoplásicosimunossupressores; digitálicos; imunomoduladores; anti-retrovirais, quando descartados por serviços de saúde, farmácias, drogarias e distribuidores de medicamentos ou apreendidos e os resíduos e insumos farmacêuticos dos medicamentos sujeitos a controle especial","Perigoso ","KG" } )
	aAdd( aCodIb, { "180202(*)","Resíduos de saneantes, desinfetantes, desinfestantes; resíduos contendo metais pesados; reagentes para laboratório, inclusive os recipientes contaminados por estes","Perigoso ","KG" } )
	aAdd( aCodIb, { "180203(*)","Efluentes de processadores de imagem (reveladores e fixadores)","Perigoso ","L" } )
	aAdd( aCodIb, { "180204(*)","Efluentes dos equipamentos automatizados utilizados em análises clínicas","Perigoso ","L" } )
	aAdd( aCodIb, { "180205(*)","Outros produtos considerados perigosos","Perigoso ","KG" } )
	aAdd( aCodIb, { "1803","Materiais resultantes de atividades humanas que contenham radionuclídeos:","","" } )
	aAdd( aCodIb, { "180301(*)","Materiais resultantes de laboratórios de pesquisa e ensino na área de saúde, laboratórios de análises clínicas e serviços de medicina nuclear e radioterapia que contenham radionuclídeos em quantidade superior aos limites de eliminação ([v])","Perigoso ","KG" } )
	aAdd( aCodIb, { "1804","Materiais perfurocortantes ou escarificantes:","","" } )
	aAdd( aCodIb, { "180401(*)","Materiais perfurocortantes ou escarificantes, tais como: lâminas de barbear, agulhas, escalpes, ampolas de vidro, brocas, limas endodônticas, pontas diamantadas, lâminas de bisturi, lancetas; tubos capilares; micropipetas; lâminas e lamínulas; espátulas; e todos os utensílios de vidro quebrados no laboratório (pipetas, tubos de coleta sanguínea e placas de Petri) e outros similares","Perigoso ","KG" } )
	aAdd( aCodIb, { "19","Resíduos de instalações de gestão de resíduos, de estações de tratamento de águas  residuais e da preparação de água para consumo humano e água para consumo industrial:","","" } )
	aAdd( aCodIb, { "1901","Resíduos da incineração ou pirólise de resíduos: ","","" } )
	aAdd( aCodIb, { "190102","Materiais ferrosos removidos das cinzas","","KG" } )
	aAdd( aCodIb, { "190105(*)","Tortas de filtro provenientes do tratamento de gases","Perigoso ","KG" } )
	aAdd( aCodIb, { "190106(*)","Resíduos líquidos aquosos provenientes do tratamento de gases e outros resíduos líquidos aquosos","Perigoso ","L" } )
	aAdd( aCodIb, { "190107(*)","Resíduos sólidos provenientes do tratamento de gases","Perigoso ","KG" } )
	aAdd( aCodIb, { "190110(*)","Carvão ativado usado proveniente do tratamento de gases de combustão","Perigoso ","KG" } )
	aAdd( aCodIb, { "190111(*)","Cinzas e escórias contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190112","Cinzas e escórias não abrangidas em 19 01 11","","KG" } )
	aAdd( aCodIb, { "190113(*)","Cinzas voláteis contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190114","Cinzas voláteis não abrangidas em 19 01 13","","KG" } )
	aAdd( aCodIb, { "190115(*)","Cinzas de caldeiras contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190116","Cinzas de caldeiras não abrangidas em 19 01 15","","KG" } )
	aAdd( aCodIb, { "190117(*)","Resíduos de pirólise contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190118","Resíduos de pirólise não abrangidos em 19 01 17","","KG" } )
	aAdd( aCodIb, { "190119","Areias de leitos fluidizados","","KG" } )
	aAdd( aCodIb, { "190199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1902","Resíduos de tratamentos físico-químicos de resíduos (por exemplo, descromagem, descianetização, neutralização): ","","" } )
	aAdd( aCodIb, { "190203","Misturas de resíduos contendo apenas resíduos não perigosos","","KG" } )
	aAdd( aCodIb, { "190204(*)","Misturas de resíduos contendo, pelo menos, um resíduo perigoso","Perigoso ","KG" } )
	aAdd( aCodIb, { "190205(*)","Lodos de tratamento físico-químico contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190206","Lodos de tratamento físico-químico não abrangidas em 19 02 05","","KG" } )
	aAdd( aCodIb, { "190207(*)","Óleos e concentrados da separação","Perigoso ","L" } )
	aAdd( aCodIb, { "190208(*)","Resíduos combustíveis líquidos contendo substâncias perigosas","Perigoso ","L" } )
	aAdd( aCodIb, { "190209(*)","Resíduos combustíveis sólidos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190210","Resíduos combustíveis não abrangidos em 19 02 08 e 19 02 09","","KG" } )
	aAdd( aCodIb, { "190211(*)","Outros resíduos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190299","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1903","Resíduos solidificados/estabilizados:","","" } )
	aAdd( aCodIb, { "190304(*)","Resíduos assinalados como perigosos, parcialmente estabilizados","Perigoso ","KG" } )
	aAdd( aCodIb, { "190305","Resíduos estabilizados não abrangidos em 19 03 04","","KG" } )
	aAdd( aCodIb, { "190306(*)","Resíduos assinalados como perigosos, solidificados","Perigoso ","KG" } )
	aAdd( aCodIb, { "190307","Resíduos solidificados não abrangidos em 19 03 06","","KG" } )
	aAdd( aCodIb, { "1904","Resíduos vitrificados e resíduos da vitrificação: ","","" } )
	aAdd( aCodIb, { "190401","Resíduos vitrificados","","KG" } )
	aAdd( aCodIb, { "190402(*)","Cinzas voláteis e outros resíduos do tratamento de gases de combustão","Perigoso ","KG" } )
	aAdd( aCodIb, { "190403(*)","Fase sólida não vitrificada","Perigoso ","KG" } )
	aAdd( aCodIb, { "190404","Resíduos líquidos aquosos da têmpera de resíduos vitrificados","","L" } )
	aAdd( aCodIb, { "1905","Resíduos do tratamento aeróbio de resíduos sólidos: ","","" } )
	aAdd( aCodIb, { "190501","Fração não compostada de resíduos urbanos e equiparados","","KG" } )
	aAdd( aCodIb, { "190502","Fração não compostada de resíduos animais e vegetais","","KG" } )
	aAdd( aCodIb, { "190503","Composto fora de especificação","","KG" } )
	aAdd( aCodIb, { "190599","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1906","Resíduos do tratamento anaeróbio de resíduos: ","","" } )
	aAdd( aCodIb, { "190603","Lodo do tratamento anaeróbio de resíduos urbanos e equiparados","","KG" } )
	aAdd( aCodIb, { "190604","Lamas e lodos de digestores de tratamento anaeróbio de resíduos urbanos e equiparados","","KG" } )
	aAdd( aCodIb, { "190605","Lodo do tratamento anaeróbio de resíduos animais e vegetais","","KG" } )
	aAdd( aCodIb, { "190606","Lamas e lodos de digestores de tratamento anaeróbio de resíduos animais e vegetais","","KG" } )
	aAdd( aCodIb, { "190699","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1907","Lixiviados de aterros: ","","" } )
	aAdd( aCodIb, { "190702(*)","Lixiviados ou líquidos percolados de aterros contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190703","Lixiviados ou líquidos percolados de aterros não abrangidos em 19 07 02","","KG" } )
	aAdd( aCodIb, { "1908","Resíduos de estações de tratamento de efluentes (ETE) não anteriormente especificados:","","" } )
	aAdd( aCodIb, { "190801","Resíduos retirados da fase de gradeamento","","KG" } )
	aAdd( aCodIb, { "190802","Resíduos do desarenamento","","KG" } )
	aAdd( aCodIb, { "190805","Lodos do tratamento de efluentes urbanos","","KG" } )
	aAdd( aCodIb, { "190806(*)","Resinas de troca iônica, saturadas ou usadas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190807(*)","Soluções e lodos da regeneração de colunas de permuta iônica","Perigoso ","KG" } )
	aAdd( aCodIb, { "190808(*)","Resíduos de sistemas de membranas contendo metais pesados","Perigoso ","KG" } )
	aAdd( aCodIb, { "190809","Misturas de gorduras e óleos, da separação óleo/água, contendo apenas óleos e gorduras alimentares","","L" } )
	aAdd( aCodIb, { "190810(*)","Misturas de gorduras e óleos, da separação óleo/água, não abrangidas em 19 08 09","Perigoso ","L" } )
	aAdd( aCodIb, { "190811(*)","Lodos do tratamento biológico de efluentes industriais contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190812","Lodos do tratamento biológico de efluentes industriais não abrangidas em 19 08 11","","KG" } )
	aAdd( aCodIb, { "190813(*)","Lodos de outros tratamentos de efluentes industriais contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "190814","Lodos de outros tratamentos de efluentes industriais não abrangidas em 19 08 13","","KG" } )
	aAdd( aCodIb, { "190899","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1909","Resíduos de estações de tratamento de água (ETA) para consumo humano ou de água para consumo industrial:","","" } )
	aAdd( aCodIb, { "190901","Resíduos retirados da fase de gradeamento","","KG" } )
	aAdd( aCodIb, { "190902","Lodos de clarificação da água","","KG" } )
	aAdd( aCodIb, { "190903","Lodos de descarbonatação","","KG" } )
	aAdd( aCodIb, { "190904","Carvão ativado usado","","KG" } )
	aAdd( aCodIb, { "190905","Resinas de troca iônica, saturadas ou usadas","","KG" } )
	aAdd( aCodIb, { "190906","Soluções e lodos da regeneração de colunas de troca iônica","","KG" } )
	aAdd( aCodIb, { "190999","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1910","Resíduos da trituração de resíduos contendo metais:","","" } )
	aAdd( aCodIb, { "191001","Resíduos de ferro ou aço","","KG" } )
	aAdd( aCodIb, { "191002","Resíduos não ferrosos","","KG" } )
	aAdd( aCodIb, { "191003(*)","Frações leves e poeiras contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "191004","Frações leves e poeiras não abrangidas em 19 10 03","","KG" } )
	aAdd( aCodIb, { "191005(*)","Outras frações contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "191006","Outras frações não abrangidas em 19 10 05","","KG" } )
	aAdd( aCodIb, { "1911","Resíduos da regeneração de óleos: ","","" } )
	aAdd( aCodIb, { "191101(*)","Argilas de filtração usadas","Perigoso ","KG" } )
	aAdd( aCodIb, { "191102(*)","Borras ácidas","Perigoso ","KG" } )
	aAdd( aCodIb, { "191103(*)","Resíduos líquidos aquosos","Perigoso ","L" } )
	aAdd( aCodIb, { "191104(*)","Resíduos da limpeza de combustíveis com bases","Perigoso ","KG" } )
	aAdd( aCodIb, { "191105(*)","Lodos do tratamento local de efluentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "191106","Lodos do tratamento local de efluentes não abrangidas em 19 11 05","","KG" } )
	aAdd( aCodIb, { "191107(*)","Resíduos da limpeza de gases de combustão","Perigoso ","KG" } )
	aAdd( aCodIb, { "191199","Outros resíduos não anteriormente especificados","","KG" } )
	aAdd( aCodIb, { "1912","Resíduos do tratamento mecânico de resíduos (por exemplo, triagem, trituração, compactação, peletização) não anteriormente especificados: ","","" } )
	aAdd( aCodIb, { "191201","Papel e cartão","","KG" } )
	aAdd( aCodIb, { "191202","Metais ferrosos","","KG" } )
	aAdd( aCodIb, { "191203","Metais não ferrosos","","KG" } )
	aAdd( aCodIb, { "191204","Plásticos","","KG" } )
	aAdd( aCodIb, { "191205","Vidro","","KG" } )
	aAdd( aCodIb, { "191206(*)","Madeira contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "191207","Madeira não abrangida em 19 12 06","","KG" } )
	aAdd( aCodIb, { "191208","Têxteis","","KG" } )
	aAdd( aCodIb, { "191209","Substâncias minerais (por exemplo, areia, rochas)","","KG" } )
	aAdd( aCodIb, { "191210","Resíduos combustíveis (combustíveis derivados de resíduos)","","KG" } )
	aAdd( aCodIb, { "191211","Borrachas - ","","KG" } )
	aAdd( aCodIb, { "191212(*)","Outros resíduos (incluindo misturas de materiais) do tratamento mecânico de resíduos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "191213","Outros resíduos (incluindo misturas de materiais) do tratamento mecânico de resíduos não abrangidos em 19 12 12","","KG" } )
	aAdd( aCodIb, { "1913","Resíduos da descontaminação de solos e águas freáticas:","","" } )
	aAdd( aCodIb, { "191301(*)","Resíduos sólidos da descontaminação de solos contendo substâncias  perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "191302","Resíduos sólidos da descontaminação de solos não abrangidos em 19 13 01","","KG" } )
	aAdd( aCodIb, { "191303(*)","Lodos da descontaminação de solos contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "191304","Lodos da descontaminação de solos não abrangidas em 19 13 03","","KG" } )
	aAdd( aCodIb, { "191305(*)","Lodos da descontaminação de águas freáticas contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "191306","Lodos da descontaminação de águas freáticas não abrangidas em 19 13 05","","KG" } )
	aAdd( aCodIb, { "191307(*)"," Resíduos líquidos aquosos e concentrados aquosos da descontaminação de águas freáticas contendo substâncias perigosas","Perigoso ","L" } )
	aAdd( aCodIb, { "191308","Resíduos líquidos aquosos e concentrados aquosos da descontaminação de águas freáticas não abrangidos em 19 13 07","","L" } )
	aAdd( aCodIb, { "20","Resíduos sólidos urbanos e equiparados (resíduos domésticos, do comércio, indústria e serviços), incluindo as frações provenientes da coleta seletiva:","","" } )
	aAdd( aCodIb, { "2001","Resíduos provenientes da coleta seletiva de resíduos sólidos urbanos (exceto 15 01):","","" } )
	aAdd( aCodIb, { "200101","Papel e cartão","","KG" } )
	aAdd( aCodIb, { "200102","Vidro","","KG" } )
	aAdd( aCodIb, { "200108","Resíduos biodegradáveis de cozinhas e cantinas","","KG" } )
	aAdd( aCodIb, { "200110","Roupas","","KG" } )
	aAdd( aCodIb, { "200111","Têxteis","","KG" } )
	aAdd( aCodIb, { "200113(*)","Solventes","Perigoso ","KG" } )
	aAdd( aCodIb, { "200114(*)","Ácidos","Perigoso ","KG" } )
	aAdd( aCodIb, { "200115(*)","Resíduos alcalinos","Perigoso ","KG" } )
	aAdd( aCodIb, { "200117(*)","Produtos químicos para fotografia","Perigoso ","KG" } )
	aAdd( aCodIb, { "200119(*)","Pesticidas","Perigoso ","KG" } )
	aAdd( aCodIb, { "200121(*)","Lâmpadas fluorescentes, de vapor de sódio e mercúrio e de luz mista","Perigoso ","Un." } )
	aAdd( aCodIb, { "200123(*)","Produtos eletroeletrônicos fora de uso contendo clorofluorcarbonetos","Perigoso ","KG" } )
	aAdd( aCodIb, { "200125","Óleos e gorduras alimentares","","L" } )
	aAdd( aCodIb, { "200126(*)","Óleos e gorduras não abrangidos em 20 01 25","Perigoso ","L" } )
	aAdd( aCodIb, { "200127(*)","Tintas, produtos adesivos, colas e resinas contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "200128","Tintas, produtos adesivos, colas e resinas não abrangidos em 20 01 27","","KG" } )
	aAdd( aCodIb, { "200129(*)"," Detergentes contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "200130","Detergentes não abrangidos em 20 01 29","","KG" } )
	aAdd( aCodIb, { "200131(*)"," Medicamentos citotóxicos e citostáticos","Perigoso ","KG" } )
	aAdd( aCodIb, { "200132","Medicamentos não abrangidos em 20 01 31","","KG" } )
	aAdd( aCodIb, { "200133(*)"," Pilhas e acumuladores abrangidos em 16 06 01, 16 06 02 ou 16 06 03 e pilhas e acumuladores não separados contendo essas pilhas ou acumuladores","Perigoso ","KG" } )
	aAdd( aCodIb, { "200134","Pilhas e acumuladores não abrangidos em 20 01 33","","KG" } )
	aAdd( aCodIb, { "200135(*)"," Produtos eletroeletrônicos e seus componentes fora de uso não abrangido em 20 01 21 ou 20 01 23 contendo componentes perigosos ([vi])","Perigoso ","KG" } )
	aAdd( aCodIb, { "200136","Produtos eletroeletrônicos e seus componentes fora de uso não abrangido em 20 01 21, 20 01 23 ou 20 01 35","","KG" } )
	aAdd( aCodIb, { "200137(*)"," Madeira contendo substâncias perigosas","Perigoso ","KG" } )
	aAdd( aCodIb, { "200138","Madeira não abrangida em 20 01 37","","KG" } )
	aAdd( aCodIb, { "200139","Plásticos","","KG" } )
	aAdd( aCodIb, { "200140","Metais","","KG" } )
	aAdd( aCodIb, { "200141","Resíduos da limpeza de chaminés","","KG" } )
	aAdd( aCodIb, { "200199","Outras frações não anteriormente especificadas","","KG" } )
	aAdd( aCodIb, { "2002","Resíduos de limpeza urbana:","","" } )
	aAdd( aCodIb, { "200201","Resíduos de varrição, limpeza de logradouros e vias públicas e outros serviços de limpeza urbana biodegradáveis","","KG" } )
	aAdd( aCodIb, { "200202","Terras e pedras","","KG" } )
	aAdd( aCodIb, { "200203","Outros resíduos de varrição, limpeza de logradouros e vias públicas e outros serviços de limpeza urbana não biodegradáveis","","KG" } )
	aAdd( aCodIb, { "2003","Outros resíduos dos serviços públicos de saneamento básico e equiparados:","","" } )
	aAdd( aCodIb, { "200301","Outros resíduos urbanos e equiparados, incluindo misturas de resíduos","","KG" } )
	aAdd( aCodIb, { "200302","Resíduos de mercados públicos e feiras","","KG" } )
	aAdd( aCodIb, { "200303","Resíduos da limpeza de ruas e de galerias de drenagem pluvial","","KG" } )
	aAdd( aCodIb, { "200304","Lodos de fossas sépticas","","KG" } )
	aAdd( aCodIb, { "200306","Resíduos da limpeza de esgotos, bueiros e bocas-de-lobo","","KG" } )
	aAdd( aCodIb, { "200399","Resíduos urbanos e equiparados não anteriormente especificados","","KG" } )

	nTotCod := Len( aCodIb )
	ProcRegua( nTotCod )

	dbSelectArea( 'TFC' )
	dbSetOrder( 2 )

	For nCode := 1 To Len( aCodIb )
	
		IncProc( 'Processando informações ' + cValToChar( nCode ) + '/' + cValToChar( nTotCod )   )

		// Apenas realiza o cadastro dos códigos do Ibama não encontrados em base
		If !MsSeek( cBranchTFC + aCodIb[ nCode, 1 ] )
			
			oModel := FwLoadModel( 'SGAA780' )
			oModel:SetOperation( 3 )
			oModel:Activate()

			// TODO: Tratar cenários para os campos TFC_MEDIDA / TFC_PERIGO / TFC_DESCCO em que os clientes não possuírem os campos em base
			oModel:SetValue( 'TFCMASTER', 'TFC_IBAMA' , aCodIb[ nCode, 1 ] )
			oModel:SetValue( 'TFCMASTER', 'TFC_MEDIDA', aCodIb[ nCode, 4 ] )
			
			// Caso o campo venha preenchido signifca que o Resíduo é perigoso
			If !Empty( aCodIb[ nCode, 3 ] )
				oModel:SetValue( 'TFCMASTER', 'TFC_PERIGO', '1' )
			EndIf

			// Tratamento para que ao identificar que a descrição excede os 150 caracteres, adiciona a descrição por completa no campo MEMO.
			If Len( aCodIb[ nCode, 2 ] ) > 150
				oModel:SetValue( 'TFCMASTER', 'TFC_DESCRI', SubStr( aCodIb[ nCode, 2 ], 1, 150 ) )
				oModel:SetValue( 'TFCMASTER', 'TFC_DESCCO', aCodIb[ nCode, 2 ] )
			Else
				oModel:SetValue( 'TFCMASTER', 'TFC_DESCRI', aCodIb[ nCode, 2 ] )
			EndIf

			If oModel:VldData()
				oModel:CommitData()
			Else
				VarInfo( 'Erro ao incluir Código do Ibama ', oModel:GetErrorMessage() )
				RollBackSXE( 'TFC', 'TFC_CODIBA' )
			EndIf

			oModel:DeActivate()
			oModel:Destroy()
			oModel := NIL
		
		EndIf
		
	Next nCode

	FwFreeArray( aCodIb )

Return
