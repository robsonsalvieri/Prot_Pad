#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdComp
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdComp
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdComp
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdComp
Return nil