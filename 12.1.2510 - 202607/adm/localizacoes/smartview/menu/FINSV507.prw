#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV507
@Description backoffice.sv.fin.exchangeratedifferenceCXC - SmartView
@type function
@version 12.1.2410  
@author Leonardo Pereira
@since 13/12/2024
/*/ 
Function FINSV507( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fin.exchangeratedifferenceCXC' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf( !lSuccess, FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ), '' )

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return
