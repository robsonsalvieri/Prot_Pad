#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV511
backoffice.sv.fin.AdvancePayments - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 10/02/2025
/*/ 
Function FINSV511()

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fin.AdvancePayments' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

