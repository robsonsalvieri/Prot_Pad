#Include "PROTHEUS.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} STBReadingX
Function emite Leitura X  
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	lRet - Emissão com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBReadingX()  
	Local aRet := {}  
	
	aRet := STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STReadingX"																,;		// Nome do evento
								{})
	
	

Return Len(aRet) > 0 .and. aRet[1] == 0