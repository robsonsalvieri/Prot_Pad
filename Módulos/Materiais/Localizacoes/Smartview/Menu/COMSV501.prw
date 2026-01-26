#INCLUDE 'protheus.ch'

/*/{Protheus.doc} COMSV501
backoffice.sv.com.purchaseslist - SmartView
@type function
@version 12.1.2310
@author Leonardo Pereira
@since 18/03/2024
/*/
Function COMSV501( )

    Local lSuccess as logical
    Local oSmartView as object
 
    If ( GetRpoRelease( ) >= '12.1.2210' )
        oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.com.purchaseslist' )
        oSmartView:setShowWizard( .T. )
        lSuccess := oSmartView:executeSmartView( .T. ) 

        If !lSuccess
            FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } )
        EndIf

        oSmartView:destroy( ) 
    EndIf
    
    freeObj( oSmartView )

Return


