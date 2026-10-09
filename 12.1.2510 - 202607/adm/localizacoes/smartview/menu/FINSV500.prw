#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV500
backoffice.sv.fin.AccountsPayable - SmartView
@type function
@version 12.1.2210  
@author marcelo.hruschka
@since 15/04/2024
/*/ 
Function FINSV500( )

    Local lSuccess as logical
    Local oSmartView as object
 
    If ( GetRpoRelease( ) >= '12.1.2210' )
        // Titulos Pendientes por Proveedor
        oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fin.AccountsPayable' )
        oSmartView:setShowWizard( .T. )
        lSuccess := oSmartView:executeSmartView( .T. ) 
        oSmartView:destroy( )
    EndIf

    freeObj( oSmartView )

Return



