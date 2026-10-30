#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV512
backoffice.sv.fin.collectors - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 09/12/2024
/*/ 
Function FINSV512()

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fin.collectors' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

