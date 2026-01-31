#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdCcop
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdCcop
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdCcop
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdCcop
Return nil