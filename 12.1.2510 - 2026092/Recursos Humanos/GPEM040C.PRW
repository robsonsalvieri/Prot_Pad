#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'


/*/{Protheus.doc} GPEM040C
Cálculo rescisão complementar em lote
@author Leandro Drumond
@since 18/06/2024
@version 1.0
@see
/*/
Function GPEM040C()

	//Chama rotina de múltiplas rescisões para calcular múltiplas rescisões complementares
	GPEM040B(.T.)

Return Nil
