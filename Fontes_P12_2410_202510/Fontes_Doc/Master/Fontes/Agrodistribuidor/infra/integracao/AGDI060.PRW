#INCLUDE "TOTVS.ch"
#DEFINE TITULO_FINANCEIRO_SERVICE agd.tituloFinanceiroService.agdTituloFinanceiroService

/*/{Protheus.doc} AGDI060SE1
Funcionalidade para ser usada em campo virtual do SE1 para informar se o titulo está sendo usado pelo Agro Distribuidor
@type function
@version 12
@author jean.schulze
@since 17/03/2025
@return variant, situacao do titulo
/*/
Function AGDI060SE1()
	Local cSituacao	:= ""

	if SUPERGETMV("MV_SIGAAGD", .f., .f.) 

		oService := TITULO_FINANCEIRO_SERVICE():new()
		cSituacao := oService:getSituacaoTituloAReceberBarter(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
		FreeObj(oService)

	endif
Return cSituacao

/*/{Protheus.doc} AGDI060SE2
Funcionalidade para ser usada em campo virtual do SE2 para informar se o titulo está sendo usado pelo Agro Distribuidor
@type function
@version 12
@author jean.schulze
@since 17/03/2025
@return variant, situacao do titulo
/*/
Function AGDI060SE2()
	Local cSituacao	:= ""

	if SUPERGETMV("MV_SIGAAGD", .f., .f.) 

		oService := TITULO_FINANCEIRO_SERVICE():new()
		cSituacao := oService:getSituacaoTituloAPagarBarter(SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA)
		FreeObj(oService)

	endif
Return cSituacao

