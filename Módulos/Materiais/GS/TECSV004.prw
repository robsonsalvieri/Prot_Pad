#include "protheus.ch"

/*/{Protheus.doc) CNTSVe10
backoffice.sv.gct.Contracts - SmartView
@type function
@version 12.1.2210
autor julia.marcela
@since 26/03/2024
/*/

Function TECSV004()

    Local lSuccess as Logical
    Local oSmartView as object
    
    If( TecVldSmart() )

        oSmartView := totvs.framework.smartview.callSmartView():new("services.sv.gs.tecsv004")
        lSuccess   := oSmartView:executeSmartView(.T.)

        If !lSuccess
            FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } )
        EndIf
        oSmartView:Destroy()
        freeObj( oSmartView )
        
    EndIf    

Return
