#INCLUDE "PROTHEUS.CH"
#INCLUDE "OFIA615.ch"

/*/{Protheus.doc} OFIA615
	Funcao utilizada para chamada da aplicacao PO-UI "dms-prioatendimento"
	@type  Function
	@author Bruno Forcato
	@since 10/05/2025
	/*/
function OFIA615()
	if FindFunction("OFIW128")
		FwCallApp('dms-prioatendimento')
	else
		FMX_HELP(STR0001, STR0002) // "AVISO", "Fontes Necessários Não Compilados"
	endif
return