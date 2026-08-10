#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ValuePriceDefault
Funcao responsavel em solicitar e retornar o numero de COO do CF

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	cCoo - Numero do COO
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBNumCoo()     

Local cCoo := ""						// Numero do COO
Local aRet	:= {space(6) }		// Array de retorno

STFFireEvent(ProcName(0), "STGetReceipt", aRet) 
 
If Len(aRet) > 0 .AND. ValType(aRet[1]) == "C"
	cCoo := aRet[1]
EndIf

Return cCoo


//-------------------------------------------------------------------
/*/{Protheus.doc} ValuePriceDefault
Funcao responsavel em solicitar e retornar o numero de fabricacao do ECF

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	cSerie - Numero de serie
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBNumFab()

Local aRet := { space(30) }		// Array de retorno
Local cSerie := ""					// numero de serie

STFFireEvent(ProcName(0), "STGetSerie", aRet) 

If Len(aRet) > 0 .AND. ValType(aRet[1]) == "C"
	cSerie := aRet[1]
EndIf

Return cSerie


//-------------------------------------------------------------------
/*/{Protheus.doc} STBQtdeInt
Funcao responsavel em solicitar e retornar a quantidade de intervencoes do ECF

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	cCRO - Intervencoes
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBQtdeInt() 
 
Local cCRO := ""							// Intervencoes
Local aRet := {"23", space(6) }		// Array de retorno

STFFireEvent(ProcName(0), "STPrinterStatus",aRet )

If Len(aRet) > 1 .AND. ValType(aRet[2]) == "C"
	cCRO := aRet[2]
EndIf
	
Return cCRO

