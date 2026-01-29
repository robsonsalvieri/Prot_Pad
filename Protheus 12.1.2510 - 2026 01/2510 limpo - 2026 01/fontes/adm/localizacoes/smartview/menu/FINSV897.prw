#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV897
backoffice.sv.fin.commissionpayment - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 29/11/2024
/*/ 
Function FINSV897( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fin.commissionpayment' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf( !lSuccess, FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ), '' )

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

