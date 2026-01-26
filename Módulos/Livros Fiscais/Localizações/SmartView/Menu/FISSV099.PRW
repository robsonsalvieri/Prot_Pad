#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FISSV099
backoffice.sv.fis.taxzone - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 25/11/2024
/*/ 
Function FISSV099( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fis.taxzone' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf( !lSuccess, FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ), '' )

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

