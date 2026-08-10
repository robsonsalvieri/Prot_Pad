#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdB2R
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdB2R
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdB2R
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdB2R
Return _Super:execute()