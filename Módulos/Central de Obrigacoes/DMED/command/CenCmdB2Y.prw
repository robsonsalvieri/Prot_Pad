#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdB2Y
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdB2Y
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdB2Y
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdB2Y
Return _Super:execute()