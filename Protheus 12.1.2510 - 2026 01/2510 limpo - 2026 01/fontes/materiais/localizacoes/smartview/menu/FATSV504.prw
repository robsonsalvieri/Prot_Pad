#INCLUDE 'protheus.ch'
#INCLUDE 'topconn.ch'
/*/{Protheus.doc} FATSV504
backoffice.sv.fat.LayoutIssuedDocuments
@type function
@version 12.1.2510  
@author Marcelo Hruschka
@since 22/12/2025
/*/ 
Function FATSV504(lInfParam as logical)

	Local lSuccess as logical
	Local oSmartView as object
	Local lSX1SV504 as logical
	Local cAlias as character
	DEFAULT lInfParam := .F.

	lSX1SV504    := FWSX1Util():ExistPergunte("FATSV504")
	cAlias := ALIAS()

	If !lSX1SV504
		IF ExistFunc("MIAvisoSX1")
			MIAvisoSX1("FATSV504","https://tdn.totvs.com/pages/releaseview.action?pageId=1021183527")
		Endif
		Return
	Endif
	If ( GetRpoRelease( ) >= '12.1.2410' )

		If lInfParam .And. cAlias $ "SF1,SF2"
			jParams := JsonObject():new()
			jParams["parameters"] := Array(6)
			jParams["force"] := .T. //Indica se força o valor
			jParams["parameters"][01] := JsonObject():New()
			jParams["parameters"][01]["name"] := "MV_PAR01"
			jParams["parameters"][01]["value"] := IIF(cAlias=="SF1",SF1->F1_DOC,SF2->F2_DOC)
			jParams["parameters"][01]["visibility"] := "Disabled"
			jParams["parameters"][02] := JsonObject():New()
			jParams["parameters"][02]["name"] := "MV_PAR02"
			jParams["parameters"][02]["value"] := IIF(cAlias=="SF1",SF1->F1_DOC,SF2->F2_DOC)
			jParams["parameters"][02]["visibility"] := "Disabled"
			jParams["parameters"][03] := JsonObject():New()
			jParams["parameters"][03]["name"] := "MV_PAR03"
			jParams["parameters"][03]["value"] := IIF(cAlias=="SF1",SF1->F1_SERIE,SF2->F2_SERIE)
			jParams["parameters"][03]["visibility"] := "Disabled"
			jParams["parameters"][04] := JsonObject():New()
			jParams["parameters"][04]["name"] := "MV_PAR04"
			jParams["parameters"][04]["value"] := IIF(cAlias=="SF1",SF2->F2_SERIE,SF2->F2_SERIE)
			jParams["parameters"][04]["visibility"] := "Disabled"
			jParams["parameters"][05] := JsonObject():New()
			jParams["parameters"][05]["name"] := "MV_PAR05"
			jParams["parameters"][05]["value"] := totvs.framework.treports.date.dateToTimeStamp(IIF(cAlias=="SF1",SF1->F1_EMISSAO,SF2->F2_EMISSAO))
			jParams["parameters"][05]["visibility"] := "Disabled"
			jParams["parameters"][06] := JsonObject():New()
			jParams["parameters"][06]["name"] := "MV_PAR06"
			jParams["parameters"][06]["value"] := totvs.framework.treports.date.dateToTimeStamp(IIF(cAlias=="SF1",SF1->F1_EMISSAO,SF2->F2_EMISSAO))
			jParams["parameters"][06]["visibility"] := "Disabled"

			If cFunName == "MATA467N"
				oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fat.LayoutIssuedDocuments.SalesInvoice.rep.mex","report")
			ElseIf cFunName == "MATA465N" .And. cAlias == "SF2"
				oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fat.LayoutIssuedDocuments.DebitNote.rep.mex","report")
			ElseIf cFunName == "MATA465N" .And. cAlias == "SF1"
				oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fat.LayoutIssuedDocuments.CreditNote.rep.mex","report")
			Endif
			oSmartView:setParameters(jParams)
			oSmartView:setForceParams(.T.)
			oSmartView:setShowWizard(.F.)
		Else
			oSmartView := totvs.framework.smartview.callSmartView():new( 'backoffice.sv.fat.LayoutIssuedDocuments' )
			oSmartView:setShowWizard( .T. )
		Endif
		lSuccess := oSmartView:executeSmartView( .T. )
		IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")
		oSmartView:destroy( )
	EndIf

	freeObj( oSmartView )

Return



