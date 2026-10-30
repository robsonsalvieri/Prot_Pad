#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FISSV098
backoffice.sv.fis.taxagent - SmartView
@type function
@version 12.1.2410  
@author Marcelo Hruschka
@since 11/12/2024
/*/ 
Function FISSV098() 

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fis.taxagent' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf( !lSuccess, FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ), '' )

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return

