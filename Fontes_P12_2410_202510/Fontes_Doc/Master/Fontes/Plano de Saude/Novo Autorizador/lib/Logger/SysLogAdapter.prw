#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe abstrata que define quais os metodos obrigatorios do log
    @type  Class
    @author victor.silva
    @since 20181114
/*/
Class SysLogAdapter

    Method New()
    Method formatMessage(oLog, cMsg)

EndClass

Method New() Class SysLogAdapter
Return self

Method formatMessage(oLog, cMsg, cMsgId, nLevel, nFacility) Class SysLogAdapter
    oLog:cMsg := FWTimeStamp(5, Date(), Time()) + ' '
    oLog:cMsg += oLog:facility(nFacility) + '.' + oLog:level(nLevel) + chr(9)
    oLog:cMsg += oLog:cHostName + "(" + oLog:cServerAddress + ") "
    oLog:cMsg += oLog:cProcName + ' '
    oLog:cMsg += oLog:cTenantId + ' '
    oLog:cMsg += cMsgId + ' '
    oLog:cMsg += cMsg + ' '
Return
//