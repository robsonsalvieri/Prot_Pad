#include 'mdtw020.ch'
#include 'Totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ProtheusDoc
Realiza busca de lembretes de agendamento médico

@type   Function

@author Eduardo Mussi
@since  03/07/2026

@param  [cUserTNW], caracter, Usuário( TNW->TNW_LOGIN )

@return Nil
/*/
//-------------------------------------------------------------------
Function MDTW020( cUserTNW )

	Local aReminders := {}
	Local cAliasQry  := GetNextAlias()
	Local cEmail     := ''
	Local nUsers     := 0
	
	Default cUserTNW := ''

	If Empty( cUserTNW )

		BeginSQL Alias cAliasQry
		
			SELECT DISTINCT TNW_LOGIN 
				FROM %table:TNW% 
			WHERE TNW_FILIAL = %xFilial:TNW%
			  AND TNW_LOGIN != 'CIPA'
			  AND TNW_CODIGO = ''
			  AND %NotDel%
		
		EndSQL

		Do While (cAliasQry)->( !EoF() )

			AgendaLemb( .T., @aReminders, (cAliasQry)->TNW_LOGIN )

			(cAliasQry)->( dbSkip() )

		EndDo

		(cAliasQry)->( dbCloseArea() )
	
	EndIf
	
	For nUsers := 1 To Len( aReminders )

		If !Empty( aReminders[ nUsers, 4 ] )

			cEmail := aReminders[ nUsers, 4 ]

		Else

			PswOrder( 2 ) // Seta indice por Usuário

			If PswSeek( aReminders[ nUsers, 1 ], .T. ) // Localiza Usuario

				cEmail := AllTrim( PswRet()[ 1, 14 ] )

			EndIf

		EndIf
		
		If !Empty( cEmail ) //.And. !Empty( aReminders[ nUsers, 5, 1 ] )

			MDTEnviaWF( aReminders[ nUsers, 5 ], aReminders[ nUsers, 3 ], cEmail ) 

		EndIf

		cEmail := ''

	Next nUsers

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProtheusDoc
Monta o workflow partir do array de lembretes (aReminders)

@type   Function

@author Eduardo Mussi
@since  24/06/2026
@param  aReminders, Array   , Eventos a serem enviados via WF
@param  cUser     , Caracter, Usuário( TNW->TNW_LOGIN )
@param  cTo       , Caracter, E-mail do destinatário

@return Nil
/*/
//-------------------------------------------------------------------
Static Function MDTEnviaWF( aReminders, cUser, cTo )

	Local cDir       := AllTrim( SuperGetMV( 'MV_WFDIR', Nil, '' ) )// Diretorio Onde se Encontra o Workflow
	Local cSubject   := STR0001 // 'Agenda de lembretes'
	Local nRemind    := 0
	Local oProcess

	// Caso usuário não tenha informado a barar no final do diretório no parametro(MV_WFDIR), adiciona a barra manualmente
	If Substr( cDir, Len( cDir ), 1 ) != '\'

		cDir += '\'

	Endif

	// Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
	oProcess := TWFProcess():New( 'MDTW020', cSubject )
	oProcess:NewTask( cSubject, cDir + 'MDTW020.html' )
	oProcess:cSubject := dtoc( MsDate() ) + ' - ' + cSubject
	oProcess:UserSiga := ''
	oProcess:bReturn  := ''
	
	aAdd( oProcess:oHtml:ValByName( 'TNW.USUARIO' ), AllTrim( cUser ) )
	For nRemind := 1 To Len( aReminders )
		
		If Empty( aReminders[ nRemind ] )

			aAdd( oProcess:oHtml:ValByName( 'TNW1.LEMBRETE' ), STR0002 ) // 'Atenção: Você tem um lembrete sem mensagem cadastrada.'

		Else

			aAdd( oProcess:oHtml:ValByName( 'TNW1.LEMBRETE' ), aReminders[ nRemind ] )

		EndIf
		
	Next nEvents
	
	oProcess:cTo := cTo
	oProcess:Start() // Envia email
	oProcess:Finish()
	
Return
