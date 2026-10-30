#INCLUDE "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAS010
Schedule responsável por chamar a função que checa o vencimento 
da demanda para gerar pendencia.

@type   Function

@author Eduardo Mussi
@since  17/06/2026


@return Lógico, Retorna para Schedule
/*/
//-------------------------------------------------------------------
Function SGAS010()

	SgaChkDem()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule

@type   Function

@author Eduardo Mussi
@since  17/06/2026

@return  aParam, Array, Contém as definições de parâmetros
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Return { 'P', 'PARAMDEF', '', {}, 'Vencimento de Demanda', .T., .T. }
