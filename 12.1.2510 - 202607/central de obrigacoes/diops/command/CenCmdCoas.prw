#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdCoas
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdCoas
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdCoas
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdCoas
Return nil