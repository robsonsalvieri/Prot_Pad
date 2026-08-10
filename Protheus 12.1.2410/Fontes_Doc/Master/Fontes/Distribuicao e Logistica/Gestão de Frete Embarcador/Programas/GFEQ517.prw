#Include "protheus.ch"
#include "quicksearch.ch"

QSSTRUCT GFEQ517 DESCRIPTION "Agendamentos" MODULE 78 

QSMETHOD INIT QSSTRUCT GFEQ517
	QSTABLE "GWV" JOIN "GU3" ON "GU3_CDEMIT = GWV_CDEMIT"
	
	//-- campos do SX3 e indices do SIX
	QSPARENTFIELD 'GWV_NRAGEN' INDEX ORDER 1
	QSPARENTFIELD 'GU3_NMEMIT' INDEX ORDER 2 LABEL 'Transportador'
	
	//-- campos do SX3
	QSFIELD 'GWV_FILIAL'
	QSFIELD 'GWV_NRAGEN'
	QSFIELD 'GWV_CDOPER'
	QSFIELD 'GU3_NMEMIT' LABEL 'Transportador'
	QSFIELD 'GWV_NRROM'
	QSFIELD 'GWV_PESOR'
	
	//-- acoes do menudef, MVC ou qualquer rotina
	QSACTION MENUDEF "GFEA517" OPERATION 2 LABEL "Visualizar"	
	QSFILTER "Hoje" WHERE "GWV_SIT = '1' AND GWV_DTAGEN = '" + DTOS(Date()) + "'"
	QSFILTER "Nesta semana" WHERE "GWV_SIT = '1' AND GWV_DTAGEN > '" + DTOS(Date() - Dow(Date())) + "'"+;
									  " AND GWV_DTAGEN <= '" + DTOS(Date() + (7 - Dow(Date()))) + "'"
Return