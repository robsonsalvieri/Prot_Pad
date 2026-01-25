#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} MATA906B
	(Rotina para chamar o estorno do crédito CIAP do MATA906 através do schedule)
	@author thiagom.moreira
	@since 13/09/2024
	@version version
	@param none
	@return none
/*/
Function MATA906A()

A906Estor("SF9",,,.F.)

return


/*/{Protheus.doc} SchedDef
	(Informacoes de definicao dos parametros do schedule)

	@author thiagom.moreira
	@since 13/09/2024
	
	@Return  Array com as informacoes de definicao dos parametros do schedule
	Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
	Array[x,2] -> Caracter, Nome do Pergunte
	Array[x,3] -> Caracter, Alias(para Relatorio)
	Array[x,4] -> Array, Ordem(para Relatorio)
	Array[x,5] -> Caracter, Titulo(para Relatorio)

	@obs Essa função é chamada pela configuração do schedule.
	/*/
Static Function SchedDef()

	Local aSchedule := {}

	aSchedule := {"P",,,,}

Return aSchedule
