#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FATSV503
backoffice.sv.fat.DeliveryNote- SmartView
@type function
@version 12.1.2510  
@author Marcelo Hruschka
@since 22/08/2024
/*/ 
Function FATSV503( )

    Local lSuccess as logical
    Local oSmartView as object
 
    If ( GetRpoRelease( ) >= '12.1.2510' )

        oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fat.DeliveryNote' )
        oSmartView:setShowWizard( .T. )
        lSuccess := oSmartView:executeSmartView( .T. )

        IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

        oSmartView:destroy( ) 
    EndIf
    
    freeObj( oSmartView )

Return

