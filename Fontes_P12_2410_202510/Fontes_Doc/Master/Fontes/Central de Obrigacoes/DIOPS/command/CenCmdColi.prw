#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdColi
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdColi
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdColi
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdColi
Return nil