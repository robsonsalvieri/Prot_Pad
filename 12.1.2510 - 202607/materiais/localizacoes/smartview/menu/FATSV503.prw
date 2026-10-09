#INCLUDE 'protheus.ch'
#INCLUDE 'tbiconn.ch'

/*/{Protheus.doc} FATSV503
backoffice.sv.fat.DeliveryNote
@type function
@version 12.1.2510  
@author Marcelo Hruschka
@since 22/08/2024
/*/ 
Function FATSV503(lInfParam as logical)

	Local lSuccess as logical
	Local oSmartView as object
	Local lSX1SV503 as logical
	DEFAULT lInfParam := .F.

	lSX1SV503    := FWSX1Util():ExistPergunte("FATSV503")

	If !lSX1SV503
		MIAvisoSX1("FATSV503","https://tdn.totvs.com/pages/releaseview.action?pageId=980993172")
		Return
	Endif

	If ( GetRpoRelease( ) >= '12.1.2410' )

		If lInfParam
			jParams := JsonObject():new()
			jParams["parameters"] := Array(10)
			jParams["force"] := .T. //Indica se força o valor
			jParams["parameters"][01] := JsonObject():New()
			jParams["parameters"][01]["name"] := "MV_PAR01"
			jParams["parameters"][01]["value"] := SF2->F2_DOC
			jParams["parameters"][01]["visibility"] := "Disabled"
			jParams["parameters"][02] := JsonObject():New()
			jParams["parameters"][02]["name"] := "MV_PAR02"
			jParams["parameters"][02]["value"] := SF2->F2_DOC
			jParams["parameters"][02]["visibility"] := "Disabled"
			jParams["parameters"][03] := JsonObject():New()
			jParams["parameters"][03]["name"] := "MV_PAR03"
			jParams["parameters"][03]["value"] := SF2->F2_SERIE
			jParams["parameters"][03]["visibility"] := "Disabled"
			jParams["parameters"][04] := JsonObject():New()
			jParams["parameters"][04]["name"] := "MV_PAR04"
			jParams["parameters"][04]["value"] := SF2->F2_SERIE
			jParams["parameters"][04]["visibility"] := "Disabled"
			jParams["parameters"][05] := JsonObject():New()
			jParams["parameters"][05]["name"] := "MV_PAR05"
			jParams["parameters"][05]["value"] := SF2->F2_CLIENTE
			jParams["parameters"][05]["visibility"] := "Disabled"
			jParams["parameters"][06] := JsonObject():New()
			jParams["parameters"][06]["name"] := "MV_PAR06"
			jParams["parameters"][06]["value"] := SF2->F2_CLIENTE
			jParams["parameters"][06]["visibility"] := "Disabled"
			jParams["parameters"][07] := JsonObject():New()
			jParams["parameters"][07]["name"] := "MV_PAR07"
			jParams["parameters"][07]["value"] := SF2->F2_LOJA
			jParams["parameters"][07]["visibility"] := "Disabled"
			jParams["parameters"][08] := JsonObject():New()
			jParams["parameters"][08]["name"] := "MV_PAR08"
			jParams["parameters"][08]["value"] := SF2->F2_LOJA
			jParams["parameters"][08]["visibility"] := "Disabled"
			jParams["parameters"][09] := JsonObject():New()
			jParams["parameters"][09]["name"] := "MV_PAR09"
			jParams["parameters"][09]["value"] := totvs.framework.treports.date.dateToTimeStamp(SF2->F2_EMISSAO)
			jParams["parameters"][09]["visibility"] := "Disabled"
			jParams["parameters"][10] := JsonObject():New()
			jParams["parameters"][10]["name"] := "MV_PAR10"
			jParams["parameters"][10]["value"] := totvs.framework.treports.date.dateToTimeStamp(SF2->F2_EMISSAO)
			jParams["parameters"][10]["visibility"] := "Disabled"

			oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fat.DeliveryNote")
			oSmartView:setParameters(jParams)
			oSmartView:setForceParams(.T.)
			oSmartView:setShowWizard(.F.)
		Else
			oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fat.DeliveryNote' )
			oSmartView:setShowWizard( .T. )
		Endif
		lSuccess := oSmartView:executeSmartView( .T. )
		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")
		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return
