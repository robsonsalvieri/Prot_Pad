#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//--------------------------------------------------------
/*/{Protheus.doc} STFUseCmc7
Retorna se utiliza leitura de CMC7

@param   	
@author  	Varejo
@version 	P11.8
@since   	01/03/2013
@return	lRet - Retorna se utiliza leitura de CMC7 	
@obs     
@sample
/*/
//--------------------------------------------------------
Function STFUseCmc7()

Local lRet := .F.  //Retorno

aRet := STFFireEvent( ProcName(0), "STCMC7Use", {} ) 
lRet := Len(aRet) > 0 .AND. ValType(aRet[1]) == "L" .AND. aRet[1]

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} STFUsePrtCh
Retorna se utiliza impressao de cheque

@param   	
@author  	Varejo
@version 	P11.8
@since   	01/03/2013
@return	lRet  - 	Retorna se utiliza impressao de cheque
@obs     
@sample
/*/
//--------------------------------------------------------
Function STFUsePrtCh()

Local lRet := .F.  //Retorno

aRet := STFFireEvent( ProcName(0), "STCheckUse", {} )
lRet := Len(aRet) > 0 .AND. ValType(aRet[1]) == "L" .AND. aRet[1]

Return lRet