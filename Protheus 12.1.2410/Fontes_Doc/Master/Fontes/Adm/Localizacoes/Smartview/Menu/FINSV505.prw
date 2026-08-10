#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV325
backoffice.sv.fin.clientscollectors - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 03/02/2025
/*/ 
Function FINSV505()

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2310' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fin.customerAaccountStatement' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

