#include "protheus.ch"
#include "tecsv001.ch"

/*/{Protheus.doc) CNTSVe10
services.sv.gs.tecsv002 -Relatorio de atendente sem agenda - SmartView
@type function
@version 12.1.2210
@author julia.marcela
@since 26/03/2024
/*/

Function TECSV002()

    Local lSuccess   as Logical
    Local oSmartView as object

    If( TecVldSmart() )

        oSmartView := totvs.framework.smartview.callSmartView():new("services.sv.gs.tecsv002")
        lSuccess := oSmartView:executeSmartView(.T.)

        If !lSuccess
            FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } )
        EndIf
        oSmartView:Destroy()
        freeObj(oSmartView)
    EndIf
Return
