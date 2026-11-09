#INCLUDE "PROTHEUS.CH"

static cNumOsStatic

/*/{Protheus.doc} OFIA636
	Funcao utilizada para chamada da aplicacao de Apontamento de Tarefa
	
	@type  Function
	@author Bruno Forcato
	@since 21/01/2026
	/*/
function OFIA636(cNumOs)
	cNumOsStatic := cNumOs
	FwCallApp('dms-apontamentodertarefa')
return

/*/{Protheus.doc} JsToAdvpl
	Funcao que recebe e manda mensagens para o poui por WebChannel

	@type  Function
	@author Bruno Forcato
	@since 21/01/2026
	/*/
Static Function JsToAdvpl(oWebChannel, cType, cContent)
    Do Case
        Case cType == 'INIT_OS'
            oWebChannel:AdvplToJs('RECEIVE_OS', cNumOsStatic)
		Case cType == 'INIT_MECANICO'
			oWebChannel:AdvplToJs('RECEIVE_MECANICO', OFA636001_VerificaMecanicoLogadoProdutivo())
    EndCase
Return .T.

/*/{Protheus.doc} OFA636001_VerificaMecanicoLogadoProdutivo
	Funcao utilizada para verificar se o usuario logado é um mecanico produtivo
	@type  Function
	@author Bruno Forcato
	@since 26/01/2026
/*/
function OFA636001_VerificaMecanicoLogadoProdutivo()
	VAI->(DBSetOrder(4))
	VAI->(MSSeek(xFilial('VAI')+ __cUserID))

	if VAI->VAI_FUNPRO == '1'
		return VAI->VAI_CODTEC
	endif
return ""
