#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe abstrata que define quais os metodos obrigatorios do log
    @type  Class
    @author victor.silva
    @since 20181114
/*/
Class AbsLogger
    Data cProcName
    
    Method New()
    Method active()
    Method logMessage()

EndClass

Method New() Class AbsLogger
Return self

Method active() Class AbsLogger
Return .F.

Method logMessage() Class AbsLogger
Return .F.
//