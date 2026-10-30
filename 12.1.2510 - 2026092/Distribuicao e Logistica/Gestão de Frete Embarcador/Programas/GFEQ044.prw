#Include "protheus.ch"
#Include "quicksearch.ch"

QSSTRUCT GFEQ044 DESCRIPTION "Documentos de Carga em Trânsito" MODULE 78  

QSMETHOD INIT QSSTRUCT GFEQ044
	QSTABLE "GW1" JOIN "GU3" ON "GU3_CDEMIT = GW1_EMISDC"

	//-- campos do SX3 e indices do SIX
	QSPARENTFIELD 'GW1_NRDC' INDEX ORDER 8

	//-- campos do SX3
	QSFIELD 'GW1_FILIAL'
	QSFIELD 'GW1_CDTPDC'
	QSFIELD 'GW1_DTEMIS'
	QSFIELD 'GW1_SERDC'
	QSFIELD 'GW1_NRDC'
	QSFIELD 'GW1_EMISDC' LABEL 'Cod Emissor'
	QSFIELD 'GU3_NMEMIT' LABEL 'Emissor'

	//-- acoes do menudef, MVC ou qualquer   rotina
	QSACTION MENUDEF "GFEC040" OPERATION 2 LABEL "Visualizar"
	QSFILTER "Em trânsito" WHERE "GW1_SIT = '4' AND GW1_DTSAI != ''"
Return	
