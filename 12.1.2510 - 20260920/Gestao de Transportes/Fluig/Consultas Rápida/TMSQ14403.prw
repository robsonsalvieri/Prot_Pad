#include "protheus.ch"
#include "quicksearch.ch"
#include "tmsq14403.ch"

QSSTRUCT TMSQ14403 DESCRIPTION STR0001 MODULE 43 //VIAGENS DE ENTREGA
 
QSMETHOD INIT QSSTRUCT TMSQ14403

Local dData := Date()	
QSTABLE "DTQ" 
	
// campos do SX3 e indices do SIX
QSPARENTFIELD "DTQ_VIAGEM"						INDEX ORDER 1	//Viagem
QSPARENTFIELD "DTQ_FILORI","DTQ_VIAGEM"			INDEX ORDER 2	//"Filial de Origem+Viagem"		
QSPARENTFIELD "DTQ_ROTA"						INDEX ORDER 4	//Rota
QSPARENTFIELD "DTQ_STATUS"						INDEX ORDER 5	//Status
		
// campos do SX3
QSFIELD "DTQ_FILORI"	LABEL STR0002 //"Filial de Origem"
QSFIELD "DTQ_VIAGEM"	LABEL STR0003 //"Numero da Viagem"
QSFIELD "DTQ_ROTA"	LABEL STR0004 //"Rota"	
QSFIELD "DTQ_TIPTRA"	LABEL STR0005 //"Tipo de Transporte"	
	
// acoes do menudef, MVC ou qualquer rotina	
QSACTION MENUDEF "TMSA144C" OPERATION 2 LABEL STR0006	   //"Visualizar"

QSFILTER STR0007 WHERE "DTQ_SERTMS = '3' AND DTQ_DATGER = '"+DTOS(dData)		+"'" //"Ultimo dia" 
QSFILTER STR0008 WHERE "DTQ_SERTMS = '3' AND DTQ_DATGER > '"+DTOS(dData-7)  	+"'" //"Ultimos 7 dias"
QSFILTER STR0009 WHERE "DTQ_SERTMS = '3' AND DTQ_DATGER > '"+DTOS(dData-30)	+"'" //"Ultimo 30 dias"
QSFILTER STR0010 WHERE "DTQ_SERTMS = '3' AND DTQ_DATGER > '"+DTOS(dData-365)	+"'	" //"Ultimos 365 dias"	
		
Return
