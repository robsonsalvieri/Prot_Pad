#include "protheus.ch"
#include "tecsv001.ch"

/*/{Protheus.doc) CNTSVe10
services.sv.gs.tecsv001 - SmartView - Relatório de funcionario com agenda que não estejam demitidos
@type function
@version 12.1.2210
autor julia.marcela
@since 26/03/2024
/*/

Function TECSV001()

    Local oSmartView as object
    Local lSuccess   as Logical

    If( TecVldSmart() )

        oSmartView := totvs.framework.smartview.callSmartView():new("services.sv.gs.tecsv001")
        lSuccess := oSmartView:executeSmartView(.T.)

        If !lSuccess
            FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } )
        EndIf
        oSmartView:Destroy()
        freeObj(oSmartView)
    EndIf    
Return .T.
