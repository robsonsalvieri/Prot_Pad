#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV506
backoffice.sv.fin.detractions - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 17/01/2025
/*/ 
Function FINSV506()

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fin.detractions' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return


