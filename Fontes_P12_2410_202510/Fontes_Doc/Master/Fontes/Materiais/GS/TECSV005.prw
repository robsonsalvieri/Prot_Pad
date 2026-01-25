#include "protheus.ch"

/*/{Protheus.doc) CNTSVe10
backoffice.sv.gct.Contracts - SmartView
@type function
@version 12.1.2210
autor julia.marcela
@since 26/03/2024
/*/

Function TECSV005()

    Local lSuccess   as Logical
    Local oSmartView as object

    If( TecVldSmart() )

        oSmartView := totvs.framework.smartview.callSmartView():new("services.sv.gs.tecsv005")
        lSuccess := oSmartView:executeSmartView(.T.)

        If !lSuccess
            ConOut( oSmartView:getError())
        EndIf
        oSmartView:Destroy()
        freeObj(oSmartView)
    EndIf
Return
