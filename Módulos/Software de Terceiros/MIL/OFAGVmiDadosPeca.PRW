#include "protheus.ch"

function OFAGVmiDadosPeca()
return .t.


/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  13/06/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiDadosPeca
	Interface DMS - 2 da definição do VMI<br>
	Exemplo:<br>
	{<br>
		"data": {<br>
			"dealerLegalNumber": "99.999.999/0001-99",<br>
			"extractionDateTime": "2016-11-23T10:45:00+03:00",<br>
			"order": {<br>
				"orderId": "34562",<br>
				"orderAgco": "AOL-123456",<br>
				"orderIdOriginal": "4567",<br>
				"deliveredDealerLegalNumber": "11.000.000/0001-00",<br>
				"orderDate": "2016-11-23",<br>
				"orderType": "STOCK_ORDER",<br>
				"supplierLegalNumber": "00.000.000/0001-00",<br>
				"supplierName": "NOME FANTASIA DO FORNECEDOR",<br>
				"filter1": "",<br>
				"filter2": "",<br>
				"filter3": "",<br>
				"items": [<br>
					{<br>
						"sourceLocation": "REPVT03",<br>
						"orderLineNumber": "1",<br>
						"partNumber": "1444437P",<br>
						"receivedDate": "2016-11-23",<br>
						"requestedQuantity": 1.5,<br>
						"receivedQuantity": 1.5,<br>
						"openQuantity": 1.5,<br>
						"canceledQuantity": 1.5,<br>
						"lineStatus": "OPEN"<br>
					}<br>
				]<br>
			}<br>
		}<br>
	}
	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiDadosPeca from OFAGVmiBase
	Data oVmiJson
	Data oSqlHlp
	Data oDPM
	Data cIntName
	Method New() CONSTRUCTOR
	Method GetDadosPeca()
	Method Trigger()
	Method TriggerDer()
EndClass

/*/{Protheus.doc} New
	Construtor simples

	@author Vinicius Gati
	@since 13/06/2017
/*/
Method New() Class OFAGVmiDadosPeca
	_Super:New()
	::cIntName := "DMS-2"
	::oSqlHlp  := DMS_SqlHelper():New()
	::oDPM     := DMS_DPM():New()
return self

/*/{Protheus.doc} Trigger
	Gera cabecalho do json, manda buscar os dados das peças grava json e retorna numero de controle, todas as classes vmi de interface terão esse método

	@param oParams, DMS_DataContainer , Traz os dados basicos para criar uma requisição de interface, neste caso peças
	@author Vinicius Gati
	@since 19/06/2017
/*/
Method Trigger(oParams) class OFAGVmiDadosPeca
	Local lCargaIni := oParams:GetBool('INICIALIZACAO', .F.)
	Local cControle := ""
	Local cSQL      := ""
	Local nCntFor   := 0
	Local oJson     := DMS_DataContainer():New()
	Local aPecas    := oParams:GetValue("PECAS")
	Local aPecasOk  := {}
	Local oVmiPars  := OFAGVmiParametros():New()
	Local cGrupos   := oVmiPars:todosGrupos() // Retorna TODOS os Grupos (Originais e Paralelos) para serem utilizados nas Querys nas Querys
	Local aArquiv   := oParams:GetValue("ARQUIVOS",{})

	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB2") , xFilial("SB2") }) // 02 = SB2
		aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ ""                         , ""             }) // 06 = VS1
		aAdd(aArquiv,{ ""                         , ""             }) // 07 = VS3
		aAdd(aArquiv,{ ""                         , ""             }) // 08 = VO1
		aAdd(aArquiv,{ ""                         , ""             }) // 09 = VO2
		aAdd(aArquiv,{ ""                         , ""             }) // 10 = VO3
		aAdd(aArquiv,{ ""                         , ""             }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	if lCargaIni
		aPecasOk := aClone(aPecas) // Carga Inicial ja faz checagem dos Itens
	Else
		For nCntFor := 1 to len(aPecas)
			cSQL := " SELECT COUNT(*) "
			cSQL += "   FROM "+aArquiv[01,1]
			cSQL += "  WHERE B1_FILIAL = '"+aArquiv[01,2]+"' "
			cSQL += "    AND B1_COD    = '"+aPecas[nCntFor]+"' "
			cSQL += "    AND B1_GRUPO IN ("+cGrupos+")"
			cSQL += "    AND D_E_L_E_T_ = ' ' "
			If FM_SQL(cSQL) > 0
				aAdd(aPecasOk,aPecas[nCntFor])
			EndIf
		Next
		SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
	EndIf

	If len(aPecasOk) > 0
		For nCntFor := 1 to len(aPecasOk)
			oJson := DMS_DataContainer():New()
			oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
			oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))
			oJson:SetValue("part", self:GetDadosPeca({aPecasOk[nCntFor]},lCargaIni,aArquiv))
			cControle := self:oVmiJson:Persist( self:cIntName , oParams , {oJson} , oParams:GetValue('NUMCONTROLE') , lCargaIni )
			if !lCargaIni
				self:TriggerDer(oJson:GetValue("part"), cControle)
			end
		Next

	EndIf
Return cControle

/*/{Protheus.doc} TriggerDer
	Engatilha os eventos derivados para atualizar AGCO

	@author Andre Luis Almeida
	@since 10/12/2019
/*/
Method TriggerDer(oItem, cControle) Class OFAGVmiDadosPeca
		Local oVmi := OFAGVmi():New()
		oVMi:Trigger({;
				{'EVENTO', oVmi:oVmiMovimentos:Inventario },;
				{'NUMCONTROLE' , cControle                },;
				{'ORIGEM', "DMS2_DMS1"                    },;
				{'PECAS' , {oItem:GetValue('partNumber') }} ;
		})
Return .T.

/*/{Protheus.doc} GetDadosPeca
	Metodo que vai gerar os nós de pecas com dados necessários para atender <br>
	a interface inventario passadas por parametro

	@author Vinicius Gati
	@since 19/06/2017
	@param aPec, Array , Array Com b1_cods
/*/
Method GetDadosPeca(aPec,lCargaIni,aArquiv) class OFAGVmiDadosPeca
	local nIdx := 1
	local cSQL := ""
	local oArHlp := DMS_ArrayHelper():New()
	local aCampos := {;
		'partNumber','agcoPartNumber','description',;
		'unitOfMeasure','dealerPartsPerPackage','currencyCode',;
		'netPrice','averageCost';
	}
	Local cInPec := ""
	Local lB1_XPNAGC  :=  SB1->(FieldPos("B1_XPNAGC")) > 0 
	Default lCargaIni := .f.
	Default aArquiv   := {}

	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB2") , xFilial("SB2") }) // 02 = SB2
		aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ ""                         , ""             }) // 06 = VS1
		aAdd(aArquiv,{ ""                         , ""             }) // 07 = VS3
		aAdd(aArquiv,{ ""                         , ""             }) // 08 = VO1
		aAdd(aArquiv,{ ""                         , ""             }) // 09 = VO2
		aAdd(aArquiv,{ ""                         , ""             }) // 10 = VO3
		aAdd(aArquiv,{ ""                         , ""             }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	cSQL += "SELECT "
	cSQL += " B1_COD partNumber,
	If lB1_XPNAGC // PartNumber AGCO
		cSQL += " CASE WHEN B1_XPNAGC = ' ' THEN B1_CODITE ELSE B1_XPNAGC END agcoPartNumber, "
	Else
		cSQL += " B1_CODITE agcoPartNumber, "
	EndIf
	cSQL += " B1_DESC as description,"
	cSQL += " B1_UM as unitOfMeasure,"
	cSQL += " 1 as dealerPartsPerPackage,"
	cSQL += " 'BRL' as currencyCode,"
	cSQL += " B1_PRV1 as netPrice,"
	cSQL += " B2_CM1 as averageCost "

// Para saber se item está tendo a primeira compra sendo contemplada no dia da geração
// vemos se a data da venda é a mesma do dia, pois no parts data
// não é enviado dados de pedidos nesse caso, então a única forma de saber isso é se a venda foi no dia
// e se a quantidade de vendas total for = 1

	cSQL += "  FROM "+aArquiv[01,1] // SB1
	cSQL += "  LEFT JOIN "+aArquiv[02,1]+" ON B2_FILIAL = '"+aArquiv[02,2]+"' AND B2_COD  = B1_COD  AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' "
	cSQL += " WHERE B1_FILIAL = '"+aArquiv[01,2]+"' "
	If len(aPec) == 1
		cSQL += "   AND B1_COD = '"+aPec[1]+"' "
	Else
		cInPec := "'" + oArHlp:Join(aPec, "','") + "'"
		cSQL += "   AND B1_COD IN ("+cInPec+") AND B1_COD <> ' ' "
	EndIf

	aDados := self:oSqlHlp:GetSelect({;
		{'campos', aCampos},;
		{'query' , cSQL   } ;
	})

	If len(aDados) == 0
		DbSelectArea("SB1")
		DbSetOrder(1)
		MSSeek( xFilial("SB1") + aPec[1] )
		oDadAux := DMS_DataContainer():New()
		aAdd(oDadAux:aData,{"partNumber", aPec[1] })
		aAdd(oDadAux:aData,{"agcoPartNumber", IIf( lB1_XPNAGC .and. !Empty(SB1->B1_XPNAGC) , SB1->B1_XPNAGC , SB1->B1_CODITE ) })
		aAdd(oDadAux:aData,{"description", SB1->B1_DESC })
		aAdd(oDadAux:aData,{"unitOfMeasure", SB1->B1_UM })
		aAdd(oDadAux:aData,{"dealerPartsPerPackage", 1 })
		aAdd(oDadAux:aData,{"currencyCode", 'BRL' })
		aAdd(oDadAux:aData,{"netPrice", SB1->B1_PRV1 })
		aAdd(oDadAux:aData,{"averageCost", 0.01 })
		aAdd(aDados,oDadAux)
	EndIf

	for nIdx := 1 to Len(aDados)
		oObj := aDados[nIdx]
		if oObj:GetValue("averageCost", 0) < 0
			oObj:SetValue("averageCost", 0 )
		endif
		oObj:SetValue("description", LEFT(STRTRAN(oObj:GetValue('description'),'"',"''"), 60)) // limite não documentado
	Next

Return aDados[1]