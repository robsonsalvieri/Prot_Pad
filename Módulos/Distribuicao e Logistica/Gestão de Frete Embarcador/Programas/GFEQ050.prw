#Include "protheus.ch"
#include "quicksearch.ch"

QSSTRUCT GFEQ050 DESCRIPTION "Romaneios" MODULE 78 

QSMETHOD INIT QSSTRUCT GFEQ050
	QSTABLE "GWN" JOIN "GU3" ON "GU3_CDEMIT = GWN_CDTRP"
	
	//-- campos do SX3 e indices do SIX
	QSPARENTFIELD 'GU3_NMEMIT'  INDEX ORDER 2 LABEL "Transportador"
	QSPARENTFIELD 'GWN_NRROM'  INDEX ORDER 1
	
	//-- campos do SX3
	QSFIELD 'GWN_FILIAL'
	QSFIELD 'GWN_NRROM'
	QSFIELD 'GU3_NMEMIT' LABEL 'Transportador'
	QSFIELD 'GWN_CDTPOP'
	QSFIELD 'GWN_DTIMPL'
	
	//-- acoes do menudef, MVC ou qualquer rotina
	QSACTION MENUDEF "GFEC050" OPERATION 2 LABEL "Visualizar"
	
	QSFILTER "Calculados"     WHERE "GWN_SIT = '2' AND GWN_CALC = '1'"
	QSFILTER "Não Calculados" WHERE "GWN_SIT IN ('1', '2') AND GWN_CALC != '1' "
Return