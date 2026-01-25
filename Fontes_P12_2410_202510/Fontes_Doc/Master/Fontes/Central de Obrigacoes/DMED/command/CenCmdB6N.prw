#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdB6N
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdB6N
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdB6N
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdB6N
Return _Super:execute()