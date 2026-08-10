#include "protheus.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc) TECSV003
services.sv.gs.tecsv003 - SmartView - TECR988 - Relatorio de postos vagos/descobertos
@type function
@version 12.1.2210
@author breno.gomes
@since 16/05/2025
/*/
//-------------------------------------------------------------------
Function TECSV003()

    Local lSuccess as Logical
    Local oSmartView as object
    
    If( TecVldSmart() )

        oSmartView := totvs.framework.smartview.callSmartView():new("services.sv.gs.tecsv003")
        lSuccess   := oSmartView:executeSmartView(.T.)

        If !lSuccess
            FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } )
        EndIf
        oSmartView:Destroy()
        freeObj( oSmartView )
        
    EndIf    

Return
