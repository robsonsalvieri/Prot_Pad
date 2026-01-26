#INCLUDE 'protheus.ch'

/*/{Protheus.doc} CNTSV031
backoffice.sv.fis.FinancialSettlements_par - SmartView
@type function
@version 12.1.2310  
@author Leonardo Pereira
@since 18/03/2024
/*/ 
Function CNTSV031( )

    Local lSuccess as logical
    Local oSmartView as object
 
    If ( GetRpoRelease( ) >= '12.1.2310' )
        oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.gct.ContractMeasurements' )
        oSmartView:setShowWizard( .T. )
        lSuccess := oSmartView:executeSmartView( .T. ) 
        IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")
        oSmartView:destroy( ) 
        freeObj( oSmartView )
    EndIf
    
Return
