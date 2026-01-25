#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FATSV100
backoffice.sv.com.importlist - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 12/11/2024
/*/ 
Function MATSV142( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.com.importlist' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf( !lSuccess, FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ), '' )

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

