#INCLUDE 'protheus.ch'

/*/{Protheus.doc} CTBSV811
backoffice.sv.ctb.accountbytaxdocument - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 28/11/2024
/*/ 
Function CTBSV811( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.ctb.accountbytaxdocument' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf( !lSuccess, FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ), '' )

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

