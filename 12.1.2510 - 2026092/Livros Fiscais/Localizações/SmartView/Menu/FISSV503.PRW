#INCLUDE 'totvs.ch'

/*/{Protheus.doc} FISSV503
Llamada al objeto de negocios backoffice.sv.fis.districtfiles de SmartView 
mediante la función totvs.framework.treports.callTReports  
@type function
@version 12.1.2410  
@author Laura Medina
@since 22/12/2025
/*/ 
Function FISSV503( )

	Local lSuccess as logical
	Local oSmartView as object

	If ( GetRpoRelease( ) >= '12.1.2410' ) 
		oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fis.districtfiles' )
		oSmartView:setShowWizard( .T. )
		lSuccess := oSmartView:executeSmartView( .T. )

		If !lSuccess
			FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, {} )
		EndIf
		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return


