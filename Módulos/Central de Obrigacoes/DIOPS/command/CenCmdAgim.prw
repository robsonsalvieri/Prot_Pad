#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdAgim
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdAgim
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdAgim
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdAgim
Return nil