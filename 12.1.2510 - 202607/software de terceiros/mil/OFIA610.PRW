#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'OFIA610.CH'

/*/{Protheus.doc} OFIA610
    Rotina Scheduler que vai atualizar pedidos John Deere de forma automatica
    alterando o numero de pedido prism para o numero do jdpoint

    @author Vinicius Gati
    @since  23/03/2026
/*/
Function OFIA610(aParam)
	//"Rotina Scheduler que vai atualizar pedidos John Deere de forma automatica alterando o numero de pedido prism para o numero do jdpoint"
	BatchProcess(STR0001,,{ || OA61000014_PROCESSO() })
Return .T.

/*/{Protheus.doc} OA61000014_PROCESSO
	Rotina que vai atualizar pedidos John Deere de forma automatica
	alterando o numero de pedido prism para o numero do jdpoint

	@author Vinicius Gati
	@since  23/03/2026
/*/
Static Function OA61000014_PROCESSO()
	Local aConfs
	Local lUsaGrps
	Local nX
	Private oLogger         := OFLogRotativo():New("OFIA610.LOG")
	Private oDpm            := OFJDRpmConfig():New()
	
	aConfs   := oDpm:GetConfigs()
	lUsaGrps := LEN(aConfs) > 0

    oLogger:Log({STR0002 + " : OFIA610"}) //Iniciando rotina

	if lUsaGrps
		for nX := 1 to len(aGrupos)
			oDpmCfg := aGrupos[nX]
			aFils := oDpmCfg:GetFiliais()
			ONJD35094_AdequaPedidosDaConfiguracao(aFils, oDpm, oLogger)
		next
	else
		aFils := oDpm:GetFiliais()
		ONJD35094_AdequaPedidosDaConfiguracao(aFils, oDpm, oLogger)
	endif
return .T.

/*/{Protheus.doc} SchedDef
	Funo padro scheduler

	@author Vinicius Gati
	@since 23/03/2026
	@type function
/*/
Static Function SchedDef()
	Local aParam := {;
		"P",;
		"",;
		"",;
		"",;
		"" ;
		}
Return aParam
