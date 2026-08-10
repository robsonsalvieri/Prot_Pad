#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdCoes
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdCoes
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdCoes
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdCoes
Return nil