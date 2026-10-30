#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV857
backoffice.sv.fin.banktransactionaccounting - SmartView
@type function
@version 12.1.2310  
@author Leonardo Pereira
@since 31/10/2024
/*/ 
Function FINSV857( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fin.banktransactionaccounting' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf( !lSuccess, FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ), '' )

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

