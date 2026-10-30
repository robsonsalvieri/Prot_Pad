#INCLUDE "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} SGAS110
Schedule responsável por chamar a função que monta os lembretes da
agenda médica

@type   Function

@author Eduardo Mussi
@since  14/07/2026

@return Nil
/*/
//-------------------------------------------------------------------
Function SGAS110()
	
	// Antes de chamar WF atualiza os eventos do SGA.
	SgaChkDem()

	// Chama o WF responsável por verificar os eventos e posteriormente enviar os e-mails
	SGAW110()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Execução de Parâmetros na Definição do Schedule

@type   Function

@author Eduardo Mussi
@since  14/07/2026

@return  aParam, Array, Contém as definições de parâmetros
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Return { 'P', 'PARAMDEF', '', {}, 'Controle de Eventos - SGA', .T., .T. }
