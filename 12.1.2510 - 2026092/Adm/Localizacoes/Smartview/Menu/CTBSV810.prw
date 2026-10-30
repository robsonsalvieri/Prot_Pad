#INCLUDE 'protheus.ch'

/*/{Protheus.doc} CTBSV810
backoffice.sv.ctb.groupeddiarybook - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 27/11/2024
/*/ 
Function CTBSV810( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.ctb.groupeddiarybook' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf( !lSuccess, FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ), '' )

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

