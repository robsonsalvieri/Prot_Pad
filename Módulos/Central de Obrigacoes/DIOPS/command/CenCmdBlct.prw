#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdBlct
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdBlct
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdBlct
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdBlct
Return nil