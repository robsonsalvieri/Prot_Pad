#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FATSV100
backoffice.sv.fat.salesinvoiceaccounting - SmartView
@type function
@version 12.1.23410  
@author Marcelo Hruschka
@since 28/10/2024
/*/ 
Function FATSV100( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fat.salesinvoiceaccounting' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

