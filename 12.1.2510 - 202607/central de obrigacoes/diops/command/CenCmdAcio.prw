#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} CenCmdAcio
    Classe abstrata para execução de comandos
    @type  Class
    @author everton.mateus
    @since 20190320
/*/
Class CenCmdAcio
	
    Data oExecutor
    
    Method New(oExecutor) Constructor
    Method execute()
    
EndClass

Method New(oExecutor) Class CenCmdAcio
    self:oExecutor := oExecutor
Return self

Method execute() Class CenCmdAcio
Return nil