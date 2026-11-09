#include 'Totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAW110
Realiza busca dos eventos do SGA

@type   Function

@author Eduardo Mussi
@since  13/07/2026

@return Nil
/*/
//-------------------------------------------------------------------
Function SGAW110()

	Local aEvents   := {}
	Local cAliasQry := GetNextAlias()

	BeginSQL Alias cAliasQry
	
		SELECT DISTINCT QAA.QAA_LOGIN, QAA.QAA_EMAIL 
			FROM %table:QAA% QAA 
		INNER JOIN %table:TAQ% TAQ 
			ON  QAA.QAA_FILIAL = %xFilial:QAA%
			AND ( QAA.QAA_LOGIN  = TAQ.TAQ_USUARI OR TAQ.TAQ_USUARI = '*' )
			AND QAA.QAA_LOGIN != ''
			AND QAA.%NotDel%
		WHERE TAQ.TAQ_FILIAL = %xFilial:TAQ%
		  AND ( TAQ_MOSTRA != 'N' )
		  AND TAQ.%NotDel%
		
	EndSQL

	Do While (cAliasQry)->( !EoF() )
		
		aEvents := SgCarTAQ( (cAliasQry)->QAA_LOGIN )

		If !Empty( aEvents )
			
			// Ajusta array para trazer da menor para maior data
			aSort( aEvents,,, { | x, y | x[ 5 ] < y[ 5 ] } )

			SGASendWF( aEvents, (cAliasQry)->QAA_LOGIN, (cAliasQry)->QAA_EMAIL ) 

		EndIf

		(cAliasQry)->( dbSkip() )

	EndDo

	(cAliasQry)->( dbCloseArea() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SGASendWF
Monta o workflow partir do array de eventos (aEvents)

@type   Function

@author Eduardo Mussi
@since  13/07/2026
@param  aReminders, Array   , Eventos a serem enviados via WF
@param  cUser     , Caracter, Usuário( TNW->TNW_LOGIN )
@param  cTo       , Caracter, E-mail do destinatário

@return Nil
/*/
//-------------------------------------------------------------------
Static Function SGASendWF( aEvents, cUser, cTo )

	Local cDir      := AllTrim( SuperGetMV( 'MV_WFDIR', Nil, '' ) )// Diretorio Onde se Encontra o Workflow
	Local cSubject  := 'Controle de eventos - SGA'
	Local nEvents   := 0
	Local oProcess
		
	// Caso usuário não tenha informado a barar no final do diretório no parametro(MV_WFDIR), adiciona a barra manualmente
	If Substr( cDir, Len( cDir ), 1 ) != '\'

		cDir += '\'

	Endif

	// Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
	oProcess := TWFProcess():New( 'sgaw110', cSubject )
	oProcess:NewTask( cSubject, cDir + 'sgaw110.html' )
	oProcess:cSubject := dtoc( MsDate() ) + ' - ' + cSubject
	oProcess:UserSiga := ''
	oProcess:bReturn  := ''
	
	aAdd( oProcess:oHtml:ValByName( 'TAQ.USU' ), cUser )

	For nEvents := 1 To Len(aEvents)

		aAdd( oProcess:oHtml:ValByName( 'TAQ1.PENDEN' ), aEvents[ nEvents, 1 ] )
		aAdd( oProcess:oHtml:ValByName( 'TAQ1.DESC'   ), aEvents[ nEvents, 2 ] )
		aAdd( oProcess:oHtml:ValByName( 'TAQ1.ORDEM'  ), aEvents[ nEvents, 3 ] )
		aAdd( oProcess:oHtml:ValByName( 'TAQ1.DATA'   ), aEvents[ nEvents, 5 ] )

	Next nEvents
	
	oProcess:cTo := cTo
	oProcess:Start() // Envia email
	oProcess:Finish()

	
	
Return
