#include "protheus.ch"
#include "quicksearch.ch"
#include "omsq06001.ch"

QSSTRUCT OMSQ06001 DESCRIPTION STR0001 MODULE 43 //VEICULOS EM VIAGENS
 
QSMETHOD INIT QSSTRUCT OMSQ06001

Local dData := Date()	
	QSTABLE "DTQ" JOIN "DA3" ON "DTQ_FILORI = DA3_FILVGA AND DTQ_VIAGEM = DA3_NUMVGA"// baseado no SX9
		
	// campos do SX3 e indices do SIX
	QSPARENTFIELD "DA3_COD"		INDEX ORDER 1	//Código do Veículo
	QSPARENTFIELD "DA3_PLACA"	INDEX ORDER 2	//Placa do Veículo
		
	// campos do SX3
	QSFIELD "DA3_PLACA"  LABEL STR0002			//"Placa do Caminhao"
	QSFIELD "DA3_COD"  	LABEL STR0003			//"Veiculo"	
	QSFIELD "DTQ_FILORI"	LABEL STR0004		//"Filial de Origem"
	QSFIELD "DTQ_VIAGEM"	LABEL STR0005		//"Numero da Viagem"
		
	// acoes do menudef, MVC ou qualquer rotina	
	QSACTION MENUDEF "OMSA060" OPERATION 2 LABEL STR0006	   //"Visualizar"
	
	QSFILTER STR0007 WHERE "DA3_FILVGA != '' AND DA3_NUMVGA != '' AND DTQ.DTQ_DATGER = '"+DTOS(dData)		+"'" //"Ultimo dia" 
	QSFILTER STR0008 WHERE "DA3_FILVGA != '' AND DA3_NUMVGA != '' AND DTQ.DTQ_DATGER > '"+DTOS(dData-7)  	+"'" //"Ultimos 7 dias"
	QSFILTER STR0009 WHERE "DA3_FILVGA != '' AND DA3_NUMVGA != '' AND DTQ.DTQ_DATGER > '"+DTOS(dData-30)	+"'" //"Ultimos 30 dias" 		
	QSFILTER STR0010 WHERE "DA3_FILVGA != '' AND DA3_NUMVGA != '' AND DTQ.DTQ_DATGER > '"+DTOS(dData-365)	+"'	" //"Ultimos 365 dias"
		
Return