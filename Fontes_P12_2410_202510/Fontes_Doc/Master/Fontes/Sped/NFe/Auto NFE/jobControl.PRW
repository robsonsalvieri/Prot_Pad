#INCLUDE "PROTHEUS.CH"  

//-----------------------------------------------------------------
/*/{Protheus.doc} jobIsRunning
Verifica se o processo esta rodando. 

@param		cJob		Nome do processo

@return		lRunning	T - Esta rodando F - Nao esta rodando

@author		Henrique Brugugnoli
@since		    18/12/2012
/*/
//------------------------------------------------------------------

function jobIsRunning( cJob )

	local nError	:= 0
	local nHdl
	local cMessage	:= ""
	local cPath	

	cPath := lower( getPathSemaforo() + cJob )
	
	if ( !file( cPath )  )
		return .F. 
	endif

	nHdl := fOpen(cPath)
	
	if ( nHdl >= 0 .and. fClose(nHdl) )
		return .F.
	else
		if (nError := fError()) == 516
			cMessage := " Thread-" + cvaltochar(ThreadId()) + ": nao foi possivel acessar o job: " + AllTrim(cPath) + " pois ja esta em uso por outro processo. fError: " + AllTrim( Str(nError) ) + " handle: " + cvaltoChar(nHdl)
			conout(cMessage)
			return .T.
		endif
		conout(" Thread-" + cvaltochar(ThreadId()) + ": falha ao liberar job: " + AllTrim( cPath ) + " Error: " + AllTrim( Str(fError()) ) + " handle: " + cvaltoChar(nHdl))	
	endif

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} jobSetRunning
Seta o job para rodar. 

@param		cJob		Nome do processo
@param		lRunning	Set para rodar ou nao o processo
@param		nHandle		Handle do arquivo de semaforo

@return		nHdl		Handle do arquivo

@author		Henrique Brugugnoli
@since		18/12/2012
/*/
//-------------------------------------------------------------------
function jobSetRunning( cJob, lRunning, nHdl ) 

	local cPath

	cPath		:= lower( getPathSemaforo() + cJob )
	
	makeDir( getPathSemaforo() )

	if ( lRunning )
		if ( file( cPath ) )			
			return fOpen(cPath, 16)	
		endif				
		return fCreate(cPath)
	endif

	
	if( !fClose(nHdl) )		
		conout( " Thread-" + cvaltochar(ThreadId()) + "- Falha ao finalizar o processo: " + allTrim( cPath ) + " nHandle: " + cvaltochar(nHdl) +   " Error: " + alltrim( str( fError() ) )  )	
	endif
	
return



