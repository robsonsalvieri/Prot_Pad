#Include 'Totvs.ch'
#Include 'MNTCHAT.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTCHAT
Rotina do chabot SIGAMNT/SIGAGFR

@type   Function

@author Eduardo Henrique Mussi
@since  30/07/2024

/*/
//-------------------------------------------------------------------
Function MNTCHAT()

	FwCallApp( 'gestaomnt' )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProtheusDoc
Inserir descrição

@type   Function

@author Eduardo Mussi
@since  30/06/2024

@param  oWebChannel, objeto  , Objeto TWebEngine
@param  cType      , caracter, Define qual processo será executado
@param  cContent   , caracter, Recebe conteúdo do front a ser processado

@return Lógico, padrão da funcionalidade.
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel, cType, cContent )
	
	Local cMsg := ''

    Do Case
        Case cType == 'msgActionChatMnt'
			cMsg := fProcData( cContent )

			oWebChannel:AdvPLToJS( 'msgActionChatMnt', cMsg )

		Case cType == 'rotaItemMenu'
			oWebChannel:AdvPLToJS('rotaItemMenu', 'chatbot')
    End

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fProcData
Realiza processamento das informações recebidas do front, executando os
processos solicitados quando necessário.

@type   Function

@author Eduardo Mussi
@since  30/07/2024

@param  cContent, caracter, conteúdo recebido do front

@return caracter, mensagem que será apresentada no chat ao usuário
/*/
//-------------------------------------------------------------------
Static Function fProcData( cContent )
	
	Local oJson      := JsonObject():New()
	Local cRet       := ''
	Local cTitle     := STR0001 // O.S. Corretiva
	Local aDataIA    := {}
	Local aProcess   := {}
	Local aSymptoms  := {}
	Local aGeneric   := {}
	Local nRecInSTJ  := 0
	Local nOperation := 0
	Local lFinish    := .F.
	Local lPrev      := .F.
	Local lProcSS    := .F.
	Local lImpOS     := .F.

	Private aTrocaF3 := {}
	// Utilizado como private no processo de alteração/finalização de O.S.
	Private cCode    := ''

	oJson:FromJson( cContent )

	If oJson['action'] == 'CREATE_ORDER'
		ALTERA := .F.
		nOperation := 3
		cTitle += STR0002 // - Inclusão
	ElseIf oJson['action'] == 'UPDATE_ORDER'
		ALTERA := .T.
		nOperation := 4
		cTitle += STR0003 //- Alteração
	ElseIf oJson['action'] == 'CANCEL_ORDER'
		ALTERA := .T.
		nOperation := 5
		cTitle += STR0004 //- Cancelamento
	ElseIf oJson['action'] == 'FINISH_ORDER'
		ALTERA := .T.
		nOperation := 4
		cTitle += STR0005 //- Finalizar O.S.
		lFinish := .T.
	ElseIf oJson['action'] = 'PRINT_ORDER'
		cTitle += STR0005 //- Imprimir O.S.
		lImpOS := .T.
	ElseIf oJson['action'] == 'CREATE_SERVICE_REQUEST' .Or. oJson['action'] == 'DISTRIBUTE_SERVICE_REQUEST' .Or. oJson['action'] == 'FINISH_SERVICE_REQUEST' .Or. oJson['action'] == 'CANCEL_SERVICE_REQUEST';
		.Or. oJson['action'] == 'DELETE_SERVICE_REQUEST' .Or. oJson['action'] == 'CREATE_ORDER_FROM_SERVICE_REQUEST'
		lProcSS    := .T.
	EndIf

	If oJson:HasProperty( 'fields' )
		If !lProcSS
			If nOperation == 3
				
				nRecInSTJ := 1

				If oJson['fields']:HasProperty( 'equipment' ) .And. !Empty( oJson[ 'fields', 'equipment' ] )
					
					aAdd( aProcess, { 'TJ_CODBEM', PadR( oJson[ 'fields', 'equipment' ], FwTamSX3( 'TJ_CODBEM' )[ 1 ] ) } )
					
					// Inibe o usuário a informar contador para um bem que não possua contador.
					dbSelectArea( 'ST9' )
					dbSetOrder( 1 )
					If MsSeek( FwxFilial( 'ST9' ) + oJson[ 'fields', 'equipment' ] ) .And. ST9->T9_TEMCONT == 'S'

						If oJson['fields']:HasProperty( 'counter' ) 
							aAdd( aProcess, { 'TJ_POSCONT', Val( oJson['fields', 'counter' ] ) } )
						EndIf

						If oJson['fields']:HasProperty( 'startdate' ) 
							aGeneric   := StrTokArr( oJson[ 'fields', 'startdate' ], ' ' )
						ElseIf oJson['fields']:HasProperty( 'counterdate' ) 
							aGeneric   := StrTokArr( oJson[ 'fields', 'counterdate' ], ' ' )
						EndIf
						
						If !Empty( aGeneric )
							aAdd( aProcess, { 'TJ_DTORIGI', StoD( aGeneric[ 1 ] ) } )
							If Len( aGeneric ) > 1
								aAdd( aProcess, { 'TJ_HORACO1',  aGeneric[ 2 ] } )
							EndIf
						EndIf

					EndIf

				EndIf

				// Cenário que o aGeneric estiver vazio é quando o bem/veiculo não possuir contador
				If Empty( aGeneric ) .And. oJson['fields']:HasProperty( 'startdate' )
					aGeneric   := StrTokArr( oJson[ 'fields', 'startdate' ], ' ' )
					aAdd( aProcess, { 'TJ_DTORIGI', StoD( aGeneric[ 1 ] ) } )
				EndIf
				
				If oJson['fields']:HasProperty( 'service' ) .And. !Empty( oJson[ 'fields', 'service' ] )
					
					aAdd( aProcess, { 'TJ_SERVICO', PadR( oJson[ 'fields', 'service' ], FwTamSX3( 'TJ_SERVICO' )[ 1 ] ) } )
					
					lPrev := fVldSerOS( oJson[ 'fields', 'service' ], .T., @aProcess )
					
				EndIf

				If oJson['fields']:HasProperty( 'observation' ) 
					aAdd( aProcess, { 'TJ_OBSERVA', oJson[ 'fields', 'observation' ] } )
				EndIf

				aAdd( aDataIA, { 'STJ', aClone( aProcess ) } )

				If oJson['fields']:HasProperty( 'inputs' )
					fAddInp( oJson, @aDataIA )
				EndIf

			ElseIf nOperation == 4 .Or. nOperation == 5 .Or. lImpOS
				
				If oJson['fields']:HasProperty( 'code' )
				
					dbSelectArea( 'STJ' )
					dbSetOrder( 1 )
					If MsSeek( FwxFilial( 'STJ' ) + oJson[ 'fields', 'code' ] )
						
						If STJ->TJ_SITUACA == 'C'
							cRet := STR0006 + STJ->TJ_ORDEM + STR0007 // Ordem de serviço ## já se encontra cancelada.
						ElseIf STJ->TJ_TERMINO == 'S'
							cRet := STR0006 + STJ->TJ_ORDEM + STR0008 // Ordem de serviço ## já se encontra finalizada.
						Else
							nRecInSTJ := STJ->( Recno() )
						EndIf

					Else
						cRet := STR0006 + oJson[ 'fields', 'code' ] + STR0009 // Ordem de serviço ## não encontrada, por favor verifique o número informado.'
					EndIf

				EndIf
				
			EndIf
			
			If nRecInSTJ > 0
				
				If lPrev 
					
					If oJson['fields']:HasProperty( 'equipment' )
						
						dbSelectArea( 'STF' )
						dbSetOrder( 1 )
						If MsSeek( FwxFilial( 'STF' ) + oJson[ 'fields', 'equipment' ] + oJson[ 'fields', 'service' ] )
							cCode := NG410INC( 'STF', 1, 3, .T., aDataIA )
						Else
							cRet  := STR0010 // 'Não foi possível localizar nenhuma manutenção com os dados fornecidos.'
						EndIf

					Else
						
						cRet := STR0011 // 'Para a abertura de uma ordem de serviço preventiva, é necessário informar o código do bem e um serviço.'

					EndIf

				ElseIf lImpOS

					If NGIMP675(,,.F.,,nRecInSTJ)
						cRet := "Ordem de serviço impressa"
					Else
						cRet := "Ordem de serviço não impressa"
					EndIF
				
				Else
					
					If !lFinish
					
						cCode := NG420INC( 'STJ', nRecInSTJ, nOperation, , , , .T., cTitle, aDataIA )
					
					Else

						dbSelectArea( 'STJ' )
						dbGoTo( nRecInSTJ )
						MsgRun( STR0012, STR0013,{ || MNTA435( STJ->TJ_ORDEM, 1 ) } ) // 'Carregando O.S.' ## 'Aguarde'

					EndIf

				EndIf
					
			EndIf
		Else
			
			If oJson['action'] == 'CREATE_SERVICE_REQUEST'

				nOperation := 3
				cTipoSS280 := Space( FwTamSX3( 'TQB_CODBEM' )[ 1 ] )

				If oJson['fields']:HasProperty( 'equipment' ) 
					cCodBem280 := PadR( oJson[ 'fields', 'equipment' ], FwTamSX3( 'TQB_CODBEM' )[ 1 ] )
				EndIf

				If !Empty( cCodBem280 )
					If !Empty( Posicione( 'ST9', 1, FwxFilial( 'ST9' ) + cCodBem280, 'T9_NOME' ) )
						cTipoSS280 := 'B'
					ElseIf !Empty( Posicione( 'TAF', 1, FwxFilial( 'TAF' ) + cCodBem280, 'TAF_NOMNIV' ) )
						cTipoSS280 := 'L'
					Else
						// Caso não encontre um bem ou uma localização limpa a variável responsável por popular o campo TQB_CODBEM.
						cCodBem280 := ''
					Endif
				Else
					// Tratamento realizado para não buscar relacionamentos com o campo TQB_CODBEM caso o valor conteúdo seja vazio.
					cCodBem280 := NIl
				EndIf
				
				If oJson['fields']:HasProperty( 'costcenter' ) 
					aAdd( aProcess, { 'TQB_CCUSTO', oJson[ 'fields', 'costcenter' ] } )
				EndIf

				If oJson['fields']:HasProperty( 'workcenter' ) 
					aAdd( aProcess, { 'TQB_CENTRA', oJson[ 'fields', 'workcenter' ] } )
				EndIf

				If oJson['fields']:HasProperty( 'extension' ) 
					aAdd( aProcess, { 'TQB_RAMAL', oJson[ 'fields', 'extension' ] } )
				EndIf

				If oJson['fields']:HasProperty( 'service' )
					aAdd( aProcess, { 'TQB_CDSERV', PadR( oJson[ 'fields', 'service' ], FwTamSX3( 'TQB_CDSERV' )[ 1 ] ) } )
				EndIf

				If oJson['fields']:HasProperty( 'counter' ) 
					aAdd( aProcess, { 'TQB_POSCON', oJson[ 'fields', 'counter' ] } )
				EndIf

				If oJson['fields']:HasProperty( 'secondcounter' ) 
					aAdd( aProcess, { 'TQB_POSCO2', oJson[ 'fields', 'secondcounter' ] } )
				EndIf

				If oJson['fields']:HasProperty( 'description' ) 
					aAdd( aProcess, { 'TQB_DESCSS', DecodeUTF8( oJson[ 'fields', 'description' ] ) } )
				EndIf
				
				aAdd( aProcess, { 'TQB_ORIGEM', 'CHATBOT' } )
				
				aAdd( aDataIA, { 'TQB', aClone( aProcess ) } )

				cCode := MNTA280IN( 3, 1, 'Solicitação de Serviço', 1, aDataIA )

			ElseIf oJson['action'] == 'DISTRIBUTE_SERVICE_REQUEST'

				nOperation := 4

				If oJson['fields']:HasProperty( 'code' )
				
					dbSelectArea( 'TQB' )
					dbSetOrder( 1 )
					If MsSeek( FwxFilial( 'TQB' ) + oJson[ 'fields', 'code' ] )
						
						If TQB->TQB_SOLUCA == 'A'

							If oJson['fields']:HasProperty( 'executor' ) .And. !Empty( oJson[ 'fields', 'executor' ] )
								aAdd( aProcess, { 'TQB_CDEXEC', oJson[ 'fields', 'executor' ] } )
								aAdd( aProcess, { 'TQB_NMEXEC', Posicione( 'TQ4', 1, FwxFilial( 'TQ4' ) + oJson[ 'fields', 'executor' ], 'TQ4_NMEXEC' ) } )
							Else
								aAdd( aProcess, { 'TQB_CDEXEC', Space( FwTamSX3( 'TQB_CDEXEC' )[ 1 ] ) } )
							EndIf
							
							If oJson['fields']:HasProperty( 'priorityservicerequest' )
								aAdd( aProcess, { 'TQB_PRIORI', oJson[ 'fields', 'priorityservicerequest' ] } )
							EndIf

							aAdd( aProcess, { 'TQB_ORIGEM', 'CHATBOT' } )
							
							aAdd( aDataIA, { 'TQB', aClone( aProcess ) } )

							cCode := MNTA280IN( 4, 2, STR0015, , aDataIA ) // 'Distribuição de S.S.'

						ElseIf TQB->TQB_SOLUCA == 'D'
							
							cRet := STR0014 + oJson[ 'fields', 'code' ] + ' já se encontra como distribuída.'
						
						ElseIf TQB->TQB_SOLUCA == 'C'
							
							cRet := STR0014 + oJson[ 'fields', 'code' ] + ' não pode ser distribuída, pois encontra-se cancelada.'

						ElseIf TQB->TQB_SOLUCA == 'E'
							
							cRet := STR0014 + oJson[ 'fields', 'code' ] + ' não pode ser distribuída, pois encontra-se fechada.'

						EndIf
					Else
						cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0009 // 'Solicitação de serviço ' ## ' não encontrada, por favor verifique o número informado.'
					EndIf
				Else
					cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0009 // 'Solicitação de serviço ' ## ' não encontrada, por favor verifique o número informado.'
				EndIf
			
			ElseIf oJson['action'] == 'CANCEL_SERVICE_REQUEST'
				
				nOperation := 5

				If oJson['fields']:HasProperty( 'code' )
				
					dbSelectArea( 'TQB' )
					dbSetOrder( 1 )
					If MsSeek( FwxFilial( 'TQB' ) + oJson[ 'fields', 'code' ] )
						If TQB->TQB_SOLUCA == 'D'
							If MNTA290CAN( 'Cancelamento S.S.' )
								cRet := STR0014  + oJson[ 'fields', 'code' ] + STR0017 // 'Solicitação de serviço ' ## ' foi cancelada com sucesso.'
							EndIf
						Else
							cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0018 // 'Solicitação de serviço ' ## ' não pode ser cancelada, pois ainda não foi distribuída.'
						EndIf
					Else
						cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0009 // 'Solicitação de serviço ' ## ' não encontrada, por favor verifique o número informado.'
					EndIf
				Else
					cRet := STR0020 // 'Não foi possível identificar o número da S.S.. Por favor, tente novamente!'
				EndIf

			ElseIf oJson['action'] == 'FINISH_SERVICE_REQUEST'
				
				nOperation := 4
				lFinish    := .T.

				If oJson['fields']:HasProperty( 'code' )

					dbSelectArea( 'TQB' )
					dbSetOrder( 1 )
					If MsSeek( FwxFilial( 'TQB' ) + oJson[ 'fields', 'code' ] )

						If TQB->TQB_SOLUCA == 'D'

							If oJson['fields']:HasProperty( 'costcenter' ) 
								aAdd( aProcess, { 'TQB_CCUSTO', oJson[ 'fields', 'costcenter' ] } )
							EndIf

							If oJson['fields']:HasProperty( 'extension' ) 
								aAdd( aProcess, { 'TQB_RAMAL', oJson[ 'fields', 'extension' ] } )
							EndIf

							If oJson['fields']:HasProperty( 'date' )  
								aGeneric   := StrTokArr( oJson[ 'fields', 'date' ], ' ' )
								aAdd( aProcess, { 'TQB_DTFECH', StoD( aGeneric[ 1 ] ) } )
								aAdd( aProcess, { 'TQB_HOFECH', aGeneric[ 2 ] } )
							EndIf
							
							If oJson['fields']:HasProperty( 'time' ) 
								aAdd( aProcess, { 'TQB_TEMPO', oJson[ 'fields', 'time' ] } )
							EndIf

							If oJson['fields']:HasProperty( 'description' ) 
								aAdd( aProcess, { 'TQB_DESCSO', oJson[ 'fields', 'description' ] } )
							EndIf
							
							aAdd( aDataIA, { 'TQB', aClone( aProcess ) } )

							If MNTA290FEC( 'Fechamento de S.S.', , aDataIA )
								cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0021 // Solicitação de serviço ' ## ' foi fechada com sucesso.'	
							EndIf

						Else
							If TQB->TQB_SOLUCA == 'E'
								cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0022 // 'Solicitação de serviço ' ## ' não pode ser fechada, pois já se encontra fechada.' 
							ElseIf TQB->TQB_SOLUCA == 'C'
								cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0023 // 'Solicitação de serviço ' ## ' não pode ser fechada, pois encontra-se cancelada.' 
							ElseIf TQB->TQB_SOLUCA == 'A'
								cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0024 // 'Solicitação de serviço ' ## ' não pode ser fechada, pois não está distribuída.' 
							EndIf
						EndIf

					Else
						cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0009 // 'Solicitação de serviço ' ## ' não encontrada, por favor verifique o número informado.'
					EndIf

				Else
					cRet := 'Não foi possível identificar o número da S.S.. Por favor, tente novamente!'
				EndIf

			ElseIf oJson['action'] == 'DELETE_SERVICE_REQUEST'

				If oJson['fields']:HasProperty( 'code' )
				
					dbSelectArea( 'TQB' )
					dbSetOrder( 1 )
					If MsSeek( FwxFilial( 'TQB' ) + oJson[ 'fields', 'code' ] )
						
						If TQB->TQB_SOLUCA == 'A'
							nOperation := 5
							lFinish    := .T.

							cCode := MNTA280IN( 5, , 'Exclusão de S.S.' )

						ElseIf TQB->TQB_SOLUCA == 'E'
							cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0016 // 'A Solicitação de serviço ' ## ' não pode ser excluída, pois encontra-se fechada.'
						ElseIf TQB->TQB_SOLUCA == 'C'
							cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0019 // 'A Solicitação de serviço ' ## ' não pode ser excluída, pois encontra-se cancelada.'
						ElseIf TQB->TQB_SOLUCA == 'D'
							cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0033 // 'A Solicitação de serviço ' ## ' não pode ser excluída, pois encontra-se distribuída.'
						EndIf	
					Else
						cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0009 // 'Solicitação de serviço ' ## ' não encontrada, por favor verifique o número informado.'
					EndIf
				Else
					cRet := STR0020 // 'Não foi possível identificar o número da S.S.. Por favor, tente novamente'
				EndIf
			ElseIf oJson['action'] == 'CREATE_ORDER_FROM_SERVICE_REQUEST'
				

				If oJson['fields']:HasProperty( 'code' )
				
					dbSelectArea( 'TQB' )
					dbSetOrder( 1 )
					If MsSeek( FwxFilial( 'TQB' ) + oJson[ 'fields', 'code' ] )
						
						If TQB->TQB_SOLUCA == 'D'
							nOperation := 5
							lFinish    := .T.
							CCADASTRO  := STR0025 // 'Geração de O.S. '
							aRotina    := {}
							ASMENU     := {}

							MNTA295GOS( .F., @cRet )

						Else
							cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0026 // 'Solicitação de serviço ' ## ' não está distribuída. Para gerar uma Ordem de Serviço, é necessário que a Solicitação de Serviço seja previamente distribuída.'
						EndIf	
					Else
						cRet := STR0014 + oJson[ 'fields', 'code' ] + STR0009 // 'Solicitação de serviço ' ## ' não encontrada, por favor verifique o número informado.'
					EndIf
				Else
					cRet := STR0020 //'Não foi possível identificar o número da S.S.. Por favor, tente novamente'
				EndIf
			EndIf
			
		EndIf

	EndIf

	

	If !Empty( cCode )
		
		If lProcSS
			cRet := STR0014 // 'Solicitação de serviço '
		Else
			cRet := STR0006 // 'Ordem de serviço '
		EndIf

		If nOperation == 3
			cRet += cCode + STR0027 // ' incluída com sucesso!'
		ElseIf nOperation == 4
			If lFinish
				cRet += cCode + STR0028 // ' finalizada com sucesso!'
			Else
				If lProcSS
					cRet += cCode + ' distribuída com sucesso!'
				Else
					cRet += cCode + STR0029 // ' alterada com sucesso!'
				EndIf
			EndIf
		ElseIf nOperation == 5
			If lFinish
				cRet += cCode + STR0030 // ' excluída com sucesso!'
			Else
				cRet += cCode + STR0031 //' cancelada com sucesso!'
			EndIf
		EndIf

	ElseIf Empty( cRet )
		cRet := STR0032 // 'Não houve uma ação, pois a tela foi cancelada. Deseja realizar mais alguma ação?'
	EndIf

	conout(  'MSG EXECIA - ' + cRet )

	FWFreeArray( aDataIA )
	FWFreeArray( aProcess )
	FWFreeArray( aSymptoms )
	FWFreeArray( aGeneric )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fAddInp
Função responsável por tratar os insumos da O.S.

@type   Function

@author Eduardo Mussi
@since  30/07/2024

@param  oJson  , objeto, objeto Json contendo os valores recebidos do front
@param  aDataIA, array , array responsável pelo valores a serem inputados

@return Nil
/*/
//-------------------------------------------------------------------
Static Function fAddInp( oJson, aDataIA )
	
	Local aInputs  := {}
	Local aInptAll := {}
	Local nReps
	
	// Tratamento para insumos
	For nReps := 1 To Len( oJson[ 'fields', 'inputs' ] )

		If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'taskCode' )
			aAdd( aInputs, { 'TL_TAREFA', oJson[ 'fields', 'inputs', nReps, 'taskCode' ] } )
		EndIf

		If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'taskName' )
			aAdd( aInputs, { 'TL_NOMTAR', oJson[ 'fields', 'inputs', nReps, 'taskName' ] } )
		EndIf
		
		If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'type' )
			aAdd( aInputs, { 'TL_TIPOREG', oJson[ 'fields', 'inputs', nReps, 'type' ] } )
		EndIf
		
		If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'itemCode' )
			aAdd( aInputs, { 'TL_CODIGO', oJson[ 'fields', 'inputs', nReps, 'itemCode' ] } )
			
			// Trecho responsável por adicionar a unidade do produto aos insumos inseridos
			If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'type' ) .And. oJson[ 'fields', 'inputs', nReps, 'type' ] == 'P'
				dbSelectArea( 'SB1' )
				dbSetOrder( 1 )
				If MsSeek( FwxFilial( 'SB1' ) + oJson[ 'fields', 'inputs', nReps, 'itemCode' ] )
					aAdd( aInputs, { 'TL_UNIDADE', SB1->B1_UM } )
				EndIf
			EndIf

		EndIf

		If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'itemName' ) 
			aAdd( aInputs, { 'TL_NOMCODI', oJson[ 'fields', 'inputs', nReps, 'itemName' ] } )
		EndIf

		If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'amount' )
			aAdd( aInputs, { 'TL_QUANTID', oJson[ 'fields', 'inputs', nReps, 'amount' ] } )
		EndIf

		If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'warehouse' )
			aAdd( aInputs, { 'TL_LOCAL', oJson[ 'fields', 'inputs', nReps, 'warehouse' ] } )
		EndIf

		If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'destiny' )
			aAdd( aInputs, { 'TL_DESTINO', oJson[ 'fields', 'inputs', nReps, 'destiny' ] } )
		EndIf
		
		If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'startdate' )
			aGeneric   := StrTokArr( oJson[ 'fields', 'inputs', nReps, 'startdate' ], ' ' )
			aAdd( aInputs, { 'TL_DTINICI', StoD( aGeneric[ 1 ] ) } )
			aAdd( aInputs, { 'TL_HOINICI',  aGeneric[ 2 ] } )
		EndIf

		If oJson[ 'fields', 'inputs', nReps ]:HasProperty( 'enddate' )
			aGeneric   := StrTokArr( oJson[ 'fields', 'inputs', nReps, 'enddate' ], ' ' )
			aAdd( aInputs, { 'TL_DTFIM', StoD( aGeneric[ 1 ] ) } )
			aAdd( aInputs, { 'TL_HOFIM',  aGeneric[ 2 ] } )
		EndIf

		aAdd( aInptAll, aClone( aInputs )  )
		aInputs := {}

	Next nReps
	
	aAdd( aDataIA, { 'STL', aClone( aInptAll ) } )
	
	FWFreeArray( aInputs )
	FWFreeArray( aInptAll )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldSerOS
Função responsável por capturar o nome do serviço e verificar se
o serviço é preventivo ou corretivo

@type   Function

@author Eduardo Mussi
@since  30/07/2024
@param  cService, caracter, serviço a ser validado
@param  lAddName, lógico, define se a descrição do serviço deve ser carregda 
@param  aProcess, aProcess, array responsável por armazenar a descrição do serviço

@return lógico, define se o serviço é preventivo ou corretivo
/*/
//-------------------------------------------------------------------
Static Function fVldSerOS( cService, lAddName, aProcess )

	Local lRet := .F.

	default lAddName := .F.
	
	dbSelectArea( 'ST4' )
	dbSetOrder( 1 )
	If MsSeek( FwxFilial( 'ST4' ) + cService )
		
		If lAddName
			aAdd( aProcess, { 'TJ_NOMSERV', ST4->T4_NOME } )
		EndIf

		aAdd( aProcess, { 'TJ_TIPO', ST4->T4_TIPOMAN } )
		aAdd( aProcess, { 'TJ_CODAREA', ST4->T4_CODAREA } )

		dbSelectArea( 'STE' )
		dbSetOrder( 1 )
		If MsSeek( FwxFilial( 'STE' ) + ST4->T4_TIPOMAN ) .And. STE->TE_CARACTE == 'P'
			lRet := .T.
		EndIf

	EndIf

Return lRet
