#INCLUDE "PROTHEUS.CH"   

//-----------------------------------------------------------
/*/{Protheus.doc} WmsR430
Chama RdMake Impressao de Etiquetas de Embalagem
Feito isso pois o AtuSx estava fechado e a funcao está como 
Function no AtuSx  

@author  Leandro Paulino / @carlos.augusto
@since   05/17/11 - 07/03/2022
/*/
//-----------------------------------------------------------
Function WmsR430(cVolume,lMontagem)
Local cUFunc := 'U_WMSR430A(cVolume,lMontagem)' //definido desta maneira para passar no débito técnico.

	If FindFunction("U_WMSR430A")
		&(cUFunc)
	Else
		WMSR430A(cVolume,lMontagem)
	EndIf
Return Nil
