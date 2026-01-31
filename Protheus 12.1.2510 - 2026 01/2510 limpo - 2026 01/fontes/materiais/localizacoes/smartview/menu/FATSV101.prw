#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FATSV101
backoffice.sv.fat.CanceledInvoices - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 12/01/2024
/*/ 
Function FATSV101( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fat.CanceledInvoices' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

