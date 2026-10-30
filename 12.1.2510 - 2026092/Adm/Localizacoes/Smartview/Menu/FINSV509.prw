#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV509
backoffice.sv.fin.paymentorderaccounting - SmartView
@type function
@version 12.1.23410  
@author Marcelo Hruschka
@since 30/10/2024
/*/ 
Function FINSV509( )

	Local lSuccess as logical
	Local oSmartView as object

		If ( GetRpoRelease( ) >= '12.1.2410' )
			oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fin.paymentorderaccounting' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

