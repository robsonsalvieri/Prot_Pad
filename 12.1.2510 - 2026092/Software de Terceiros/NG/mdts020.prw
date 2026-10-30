#INCLUDE "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MDTS010
Schedule responsável por chamar a função que monta os lembretes da
agenda médica

@type   Function

@author Eduardo Mussi
@since  06/07/2026

@return Nil
/*/
//-------------------------------------------------------------------
Function MDTS020()

	MDTW020()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule

@type   Function

@author Eduardo Mussi
@since  06/07/2026

@return  aParam, Array, Contém as definições de parâmetros
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Return { 'P', 'PARAMDEF', '', {}, 'Agenda de Lembretes', .T., .T. }
