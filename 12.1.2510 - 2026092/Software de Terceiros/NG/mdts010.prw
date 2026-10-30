#INCLUDE "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTS010
Schedule responsável por chamar a função que verifica os eventos
da cipa

@type   Function

@author Eduardo Mussi
@since  26/06/2026


@return Lógico, Retorna para Schedule
/*/
//-------------------------------------------------------------------
Function MDTS010()
	
	MDTW010()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule

@type   Function

@author Eduardo Mussi
@since  26/06/2026

@return  aParam, Array, Contém as definições de parâmetros
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Return { 'P', 'PARAMDEF', '', {}, 'Eventos CIPA', .T., .T. }
