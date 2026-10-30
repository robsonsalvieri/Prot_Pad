#INCLUDE 'protheus.ch'

/*/{Protheus.doc} FINSV994
@Description backoffice.sv.fis.additionaltaxsettings - SmartView
@type function
@version 12.1.2410  
@author Leonardo Pereira
@since 27/12/2024
/*/ 
Function FISSV994( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' )
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fis.additionaltaxsettings' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		IIf( !lSuccess, FwLogMsg( 'INFO', ' ', 'INFO', FunName( ), '', '01', oSmartView:getError( ), 0, 0, { } ), '' )

		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return
