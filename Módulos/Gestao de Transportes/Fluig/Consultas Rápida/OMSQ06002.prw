#include "protheus.ch"
#include "quicksearch.ch"
#include "omsq06002.ch"

QSSTRUCT OMSQ06002 DESCRIPTION STR0001 MODULE 43 //VEICULOS EM FILIAIS
 
QSMETHOD INIT QSSTRUCT OMSQ06002

QSTABLE "DA3" LEFT JOIN "DUT" ON "DA3_TIPVEI = DUT_TIPVEI" // baseado no SX9
			
// campos do SX3 e indices do SIX
QSPARENTFIELD "DA3_COD"		INDEX ORDER 1	//Código do Veículo
QSPARENTFIELD "DA3_PLACA"	INDEX ORDER 2	//Placa do Veículo

// campos do SX3
QSFIELD "DA3_PLACA"	LABEL STR0002			//"Placa do Caminhao"
QSFIELD "DA3_COD"		LABEL STR0003		//"Codigo do Veiculo"
QSFIELD "DUT_DESCRI"	LABEL STR0010		//"Descrição do tipo de Veiculo"
	

// acoes do menudef, MVC ou qualquer rotina
QSACTION MENUDEF "OMSA060" OPERATION 2 LABEL STR0009	   //"Visualizar"

QSFILTER STR0006 WHERE "DA3.DA3_FILATU <> '' AND DA3_FROVEI = '1' " //Frota Propria
QSFILTER STR0007 WHERE "DA3.DA3_FILATU <> '' AND DA3_FROVEI = '2' " //Frota de Terceiros
QSFILTER STR0008 WHERE "DA3.DA3_FILATU <> '' AND DA3_FROVEI = '3' " //Frota de Agregados
			
Return