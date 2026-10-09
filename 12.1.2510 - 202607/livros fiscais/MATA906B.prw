#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} MATA906B
	(Rotina para chamar a apropriação de crédito CIAP do MATA906 através do schedule)
	@author thiagom.moreira
	@since 13/09/2024
	@version version
	@param none
	@return none
/*/
Function MATA906B()
	PRIVATE cFilOri   := FWCodFil()
	
	DbSelectArea ("SF9")
	SF9->(DbSetOrder (1))
	SF9->(DbSeek (xFilial ("SF9")+MV_PAR09, .T.))
	Do While !(SF9->(Eof ())) .And.;
		(xFilial ("SF9")==SF9->F9_FILIAL .And. SF9->F9_CODIGO<=MV_PAR10)
    	a906Aprop("SF9",SF9->(Recno()),,,.T.,.F.,)
		SF9->(DbSkip())
	EndDo
	SF9->(DbCloseArea())
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
	Array[x,6] -> Caracter, Nome do relatório (parametro 1 do metodo new da classe TReport)
	Array[x,7] -> Logico, Indica se o agendamento pode ser cadastrado como sempre ativo
	Array[x,8] -> Logico, Indica que o agendamento pode ser realizado por filiais

	@obs Essa função é chamada pela configuração do schedule.

	@change 12.03.2026 - DSERFISE-15440 - Inclusão dos parâmetros de range de filiais e opção de agrupamento de filiais
	/*/
Static Function SchedDef()

	Local aSchedule := {}

	aSchedule := {"P","MTA906",,,,,.T.,.T.}

Return aSchedule
