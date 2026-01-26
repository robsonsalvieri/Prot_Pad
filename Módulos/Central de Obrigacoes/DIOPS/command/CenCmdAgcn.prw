#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdAgcn
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdAgcn
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdAgcn
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdAgcn
Return nil