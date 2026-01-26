#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdCrit
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdCrit
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdCrit
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdCrit
Return _Super:execute()