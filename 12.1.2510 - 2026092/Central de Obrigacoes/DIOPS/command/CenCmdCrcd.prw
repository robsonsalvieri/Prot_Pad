#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdCrcd
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdCrcd
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdCrcd
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdCrcd
Return nil