#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdB8M
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdB8M
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdB8M
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdB8M
Return _Super:execute()