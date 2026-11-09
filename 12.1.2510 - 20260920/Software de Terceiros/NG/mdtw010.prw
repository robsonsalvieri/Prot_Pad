#INCLUDE "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTW010
Workflow de eventos CIPA ( MDTA111 )

@type   Function

@author Eduardo Mussi
@since  23/06/2026

@return Nil
/*/
//-------------------------------------------------------------------
Function MDTW010()

	Local aEvtAtual  := {}
	Local aEvtFuturo := {}
	Local cTo        := AllTrim( SuperGetMV( 'MV_NGEVCP', .F., '' ) ) // Parâmetro com o e-mail que receberá os eventos CIPA
	Local lLoadMdt   := .T.

	// Utilizada no processo MDTCarTNW
	Private nDiasAntes := SuperGetMv( 'MV_CIPADIA', .T., '10' )
	Private lCpoSetor  := fVldCpoSet()

	If !Empty( cTo )

		// Eventos Pendentes
		aEvtAtual := MDTCarTNW( lLoadMdt, .F., .F. )

		If Len( aEvtAtual ) > 0

			MDTEnviaWF( aEvtAtual, cTo, 'Mandatos CIPA - Eventos Pendentes' )

		EndIf

	EndIf

	FwFreeArray( aEvtAtual )
	FwFreeArray( aEvtFuturo )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} fVldCpoSet
Verifica se existe algum registro na TNC que possua o centro de 
custo preenchido

@type   Function

@author Eduardo Mussi
@since  23/06/2026

@return Lógico, Define se existe algum registro com CC preenchido
/*/
//-------------------------------------------------------------------
Static Function fVldCpoSet()

	Local cAliasQry := GetNextAlias()
	Local lReturn   := .F.

	BeginSQL Alias cAliasQry
	
		SELECT Count(*) AS nRegCC
			FROM %table:TNN%
		WHERE TNN_FILIAL = %xFilial:TNN%
		AND   TNN_CC <> ''
		AND   %NotDel%
	
	EndSQL

	If (cAliasQry)->( !EoF() ) .And. (cAliasQry)->nRegCC > 0

		lReturn   := .T.

	EndIf
	
	(cAliasQry)->( dbCloseArea() ) 

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} ProtheusDoc
Monta o workflow partir do array de eventos (aEvents)

@type   Function

@author Eduardo Mussi
@since  24/06/2026
@param  aEvents , Array   , Eventos a serem enviados via WF
@param  cTo     , Caracter, Destinatário
@param  cSubject, Caracter, Assunto do e-mail

@return Nil
/*/
//-------------------------------------------------------------------
Static Function MDTEnviaWF( aEvents, cTo, cSubject )

	Local aArea      := FwGetArea()
	Local cDir       := AllTrim( SuperGetMV( 'MV_WFDIR', Nil, '' ) )// Diretorio Onde se Encontra o Workflow
	Local nEvents    := 0
	Local oProcess

	// Caso usuário não tenha informado a barar no final do diretório no parametro(MV_WFDIR), adiciona a barra manualmente
	If Substr( cDir, Len( cDir ), 1 ) != '\'

		cDir += '\'

	Endif

	// Inicialize a classe TWFProcess e assinale a variável objeto oProcess:
	oProcess := TWFProcess():New( 'MDTW010', cSubject )
	oProcess:NewTask( cSubject, cDir + 'MDTW010.html' )
	oProcess:cSubject := dtoc( MsDate() ) + ' - ' + cSubject
	oProcess:UserSiga := ''
	oProcess:bReturn  := ''
	
	aAdd( oProcess:oHtml:ValByName( 'TNW.TITULO' ), cSubject )
	For nEvents := 1 To Len( aEvents )
	
		aAdd( oProcess:oHtml:ValByName( 'TNW1.SEQUEN' ), aEvents[ nEvents, 1 ] )
		aAdd( oProcess:oHtml:ValByName( 'TNW1.DESTIP' ), aEvents[ nEvents, 2 ] )
		aAdd( oProcess:oHtml:ValByName( 'TNW1.CODIGO' ), aEvents[ nEvents, 3 ] )
		aAdd( oProcess:oHtml:ValByName( 'TNW1.DTINIC' ), aEvents[ nEvents, 5 ] )
		
		If lCpoSetor

			aAdd( oProcess:oHtml:ValByName( 'TNW1.CC'     ), aEvents[ nEvents, 7 ] )
			aAdd( oProcess:oHtml:ValByName( 'TNW1.CODORI' ), aEvents[ nEvents, 8 ] )

		Else
			
			aAdd( oProcess:oHtml:ValByName( 'TNW1.CC'     ), '' )
			aAdd( oProcess:oHtml:ValByName( 'TNW1.CODORI' ), aEvents[ nEvents, 7 ] )

		EndIf

	Next nEvents
	
	oProcess:cTo := cTo
	oProcess:Start() // Envia email
	oProcess:Finish()
	
	FwRestArea( aArea )

Return
