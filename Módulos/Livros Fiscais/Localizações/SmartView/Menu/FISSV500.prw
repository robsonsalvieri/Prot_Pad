#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FISSV500
backoffice.sv.fis.PurchasesSales - SmartView
@type function
@version 12.1.2310  
@author Leonardo Pereira
@since 18/03/2024
/*/ 
Function FISSV500( )

    Local lSuccess as logical
    Local oSmartView as object
 
    If ( GetRpoRelease( ) >= '12.1.2410' )
        oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fis.PurchasesSales' )
        oSmartView:setShowWizard( .T. )
        lSuccess := oSmartView:executeSmartView( .T. )
        IIf(!lSuccess,ConOut(oSmartView:getError(), 0, 0, { } ),"")
        oSmartView:destroy( ) 
    EndIf
    
    freeObj( oSmartView )

Return
