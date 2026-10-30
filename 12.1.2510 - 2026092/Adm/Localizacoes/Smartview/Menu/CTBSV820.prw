#INCLUDE 'protheus.ch'

/*/{Protheus.doc} CTBSV820
backoffice.sv.ctb.balancedeterceros - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 17/12/2024
/*/ 
Function CTBSV820( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.ctb.balancedeterceros' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

