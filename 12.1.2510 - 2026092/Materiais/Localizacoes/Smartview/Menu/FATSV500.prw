#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FATSV500
backoffice.sv.fat.FinancialMovements - SmartView
@type function
@version 12.1.2310  
@author Leonardo Pereira
@since 18/03/2024
/*/ 
Function FATSV500( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2210' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fat.financialmovements' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return



