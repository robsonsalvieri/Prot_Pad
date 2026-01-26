#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FATSV501
backoffice.sv.fat.SalesOrder - SmartView
@type function
@version 12.1.2310  
@author Leonardo Pereira
@since 18/03/2024
/*/ 
Function FATSV501( )

    Local lSuccess as logical
    Local oSmartView as object
 
    If ( GetRpoRelease( ) >= '12.1.2210' )
        oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fat.SalesOrder' )
        oSmartView:setShowWizard( .T. )
        lSuccess := oSmartView:executeSmartView( .T. )
        IIf(!lSuccess,Conout(oSmartView:getError()),"")
        oSmartView:destroy( )
    EndIf

    freeObj( oSmartView )

Return
