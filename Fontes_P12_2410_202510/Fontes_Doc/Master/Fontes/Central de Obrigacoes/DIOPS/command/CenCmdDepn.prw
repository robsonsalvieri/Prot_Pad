#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdDepn
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdDepn
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdDepn
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdDepn
Return nil