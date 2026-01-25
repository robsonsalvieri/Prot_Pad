#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} LOCA021SC
Implementa o Schedule da Rotina de Faturamento Automatico
@type function
@version  24.10
@author Alexandre Circenis
@since 1/23/2025
/*/
FUNCTION LOCA021SC()
// Chamar o processamento Off-Line
LOCA021OFF(MV_PAR09, MV_PAR10, MV_PAR11,{})

RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
	Execucao da rotina via Schedule.
	@type Function
	@author Alexandre Circenis
	@Since 01/01/2025

	@return  aParam, parametros para rotina de schedule
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}

	aParam := 	{"P"	,;	//Tipo R para relatorio P para processo
				"LOCP003",;	//Nome do grupo de perguntas (SX1)
				Nil		,;	//cAlias (para Relatorio)
				Nil		,;	//aArray (para Relatorio)
				Nil		}	//Titulo (para Relatorio)
Return aParam
