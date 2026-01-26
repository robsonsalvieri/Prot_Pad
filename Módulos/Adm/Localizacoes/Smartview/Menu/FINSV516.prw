#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV516
backoffice.sv.fin.PaymentInCash - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 17/01/2025
/*/ 
Function FINSV516()

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2310' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fin.PaymentInCash' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return


