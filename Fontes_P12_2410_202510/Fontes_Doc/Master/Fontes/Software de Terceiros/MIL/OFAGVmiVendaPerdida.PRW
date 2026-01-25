#include "protheus.ch"

function OFAGVmiVendaPerdida()
return .t.

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  23/03/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiVendaPerdida
	Interface DMS - 5 da definição do VMI<br>

	{<br>
		"data": {<br>
			"dealerLegalNumber": "99.999.999/0001-99",<br>
			"extractionDateTime": "2016-11-23T10:45:00+03:00",<br>
			"order": {<br>
				"partNumber": "1444437P",<br>
				"lostSalesQuantity": 10,<br>
				"lostSalesType": "W",<br>
				"lostSalesDate": "2016-11-23"<br>
			}<br>
		}<br>
	}

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiVendaPerdida from OFAGVmiBase
	Data cIntName

	Method New() CONSTRUCTOR
	Method Trigger()
EndClass

Method New() Class OFAGVmiVendaPerdida
	_Super:New()
	AADD(::aMapValid, {"data:order:lostSalesType"      , "V007"})
	AADD(::aMapValid, {"data:order"                    , "Obri"})
	AADD(::aMapValid, {"data:order:partNumber"         , "Obri"})
	AADD(::aMapValid, {"data:order:lostSalesQuantity"  , "Obri"})
	AADD(::aMapValid, {"data:order:lostSalesType"      , "Obri"})
	AADD(::aMapValid, {"data:order:lostSalesDate"      , "Obri"})
	::cIntName := "DMS-5"
return self

/*/{Protheus.doc} Trigger
	Gera cabecalho do json, manda buscar os dados das peças grava json e retorna numero de controle, todas as classes vmi de interface terão esse método

	@param oParams, DMS_DataContainer , Traz os dados basicos para criar uma requisição de interface, neste caso peças
	@author Vinicius Gati
	@since 20/06/2017
/*/
Method Trigger(oParams) class OFAGVmiVendaPerdida
	Local oJson := DMS_DataContainer():New()

	SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
	oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
	oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))

	oLostSale := DMS_DataContainer():New({})

	oLostSale:SetValue('partNumber'       , oParams:GetValue('CODIGO_PECA'))
	oLostSale:SetValue('lostSalesQuantity', oParams:GetValue('QUANTIDADE'))
	oLostSale:SetValue('lostSalesType'    , oParams:GetValue('TIPO', 'S'))
	oLostSale:SetValue('lostSalesDate'    , oParams:GetValue('DATA', dDatabase))

	oJson:SetValue("order", oLostSale)
Return self:oVmiJson:Persist(self:cIntName, oParams, {oJson})