
#include "protheus.ch"

function OFAGVmiPedido()
return .t.

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  12/06/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiPedido
	Interface DMS - 5 da definição do VMI

	{<br>
	  "data": {<br>
	    "dealerLegalNumber": "99.999.999/0001-99",<br>
	    "extractionDateTime": "2016-11-23T10:45:00+03:00",<br>
	    "order": {<br>
	      "orderId": "34562",<br>
	      "orderDate": "2016-11-23",<br>
	      "orderType": "STOCK_ORDER",<br>
	      "supplierLegalNumber": "00.000.000/0001-00",<br>
	      "supplierName": "NOME FANTASIA DO FORNECEDOR",<br>
	      "items": [<br>
	        {<br>
	          "sourceLocation": "REPVT03",<br>
	          "orderLineNumber": "1",<br>
	          "partNumber": "1444437P",<br>
	          "receivedDate": "2016-11-23",<br>
	          "requestedQuantity": 1.5,<br>
	          "receivedQuantity": 1.5,<br>
	          "canceledQuantity": 1.5,<br>
	          "lineStatus": "OPEN"<br>
	        }<br>
	      ]<br>
	    }<br>
	  }<br>
	}<br>

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiPedido from OFAGVmiBase
	Data cIntName
	Method New() CONSTRUCTOR
	Method Trigger()
	Method TriggerDer()
	Method GetDadosPedido()
EndClass

Method New() Class OFAGVmiPedido
	_Super:New()
	AADD(::aMapValid, {"data"                                 , "V005"})
	AADD(::aMapValid, {"data:order:orderID"                   , "Obri"})
	AADD(::aMapValid, {"data:order:orderDate"                 , "Obri"})
	AADD(::aMapValid, {"data:order:orderDate"                 , "Date"})
	AADD(::aMapValid, {"data:order:orderType"                 , "V004"})
	AADD(::aMapValid, {"data:order:supplierLegalNumber"       , "Obri"})
	AADD(::aMapValid, {"data:order:items:orderLineNumber"     , "Obri"})
	AADD(::aMapValid, {"data:order:items:partNumber"          , "Obri"})
	AADD(::aMapValid, {"data:order:items:requestedQuantity"   , "Obri"})
	AADD(::aMapValid, {"data:order:items:lineStatus"          , "Obri"})
	AADD(::aMapValid, {"data:order:items:sourceLocation"      , "V005"})
	::cIntName := "DMS-3"
return self

/*/{Protheus.doc} Trigger
	Evento de envio de dados do PEDIDO (NF Entrada), modelo DMS-3 do VMI

	@author Vinicius Gati
	@since 21/06/2017
/*/
Method Trigger(oParams) Class OFAGVmiPedido
	Local lCargaIni := oParams:GetBool('INICIALIZACAO', .F.)
	Local cCoord    := ""
	Local oSqlHlp   := DMS_SqlHelper():New()
	local oArHlp    := DMS_ArrayHelper():New()
	Local oJson     := DMS_DataContainer():New()
	Local cIdPedido := oParams:GetValue("CODIGO") // DOC + SERIE + FORNECEDOR + LOJA
	Local cQuery    := ""
	Local cConcat   := FG_CONVSQL("CONCATENA")
	Local oVmiPars  := OFAGVmiParametros():New()
	Local cGrupos   := oVmiPars:todosGrupos() // Retorna TODOS os Grupos (Originais e Paralelos) para serem utilizados nas Querys
	Local aArquiv   := oParams:GetValue("ARQUIVOS",{})

	If len(aArquiv) == 0
		aAdd(aArquiv,{ oSqlHlp:NoLock("SB1")      , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ ""                         , ""             }) // 02 = SB2
		aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		aAdd(aArquiv,{ oSqlHlp:NoLock("SF4")      , xFilial("SF4") }) // 04 = SF4
		aAdd(aArquiv,{ oSqlHlp:NoLock("SD1")      , xFilial("SD1") }) // 05 = SD1
		aAdd(aArquiv,{ ""                         , ""             }) // 06 = VS1
		aAdd(aArquiv,{ ""                         , ""             }) // 07 = VS3
		aAdd(aArquiv,{ ""                         , ""             }) // 08 = VO1
		aAdd(aArquiv,{ ""                         , ""             }) // 09 = VO2
		aAdd(aArquiv,{ ""                         , ""             }) // 10 = VO3
		aAdd(aArquiv,{ ""                         , ""             }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	cQuery := "SELECT SD1.R_E_C_N_O_ AS RECSD1 "
	cQuery += "  FROM "+aArquiv[05,1] // SD1
	cQuery += "  JOIN "+aArquiv[04,1] // SF4
	cQuery += "    ON SF4.F4_FILIAL = '"+aArquiv[04,2]+"'"
	cQuery += "   AND SF4.F4_CODIGO = SD1.D1_TES"
	cQuery += "   AND SF4.F4_OPEMOV IN ('01','03') "
	cQuery += "   AND SF4.F4_ESTOQUE = 'S' "
	cQuery += "   AND SF4.D_E_L_E_T_ = ' '"
	cQuery += "  JOIN "+aArquiv[01,1] // SB1
	cQuery += "    ON SB1.B1_FILIAL = '"+aArquiv[01,2]+"'"
	cQuery += "   AND SB1.B1_COD = SD1.D1_COD "
	cQuery += "   AND SB1.B1_GRUPO IN ("+cGrupos+")"
	cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SD1.D1_FILIAL = '"+aArquiv[05,2]+"'"
	cQuery += "   AND ( SD1.D1_DOC "+cConcat+" SD1.D1_SERIE "+cConcat+" SD1.D1_FORNECE "+cConcat+" SD1.D1_LOJA ) = '"+cIdPedido+"'"
	cQuery += "   AND SD1.D_E_L_E_T_ = ' '"
	
	if !lCargaIni
		SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
	EndIf

	If FM_SQL(cQuery) > 0
		oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
		oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))
		oJson:SetValue("order", self:GetDadosPedido( cIdPedido , cQuery ))
		cCoord := self:oVmiJson:Persist( self:cIntName , oParams , {oJson} , , lCargaIni )
		if !lCargaIni
			self:TriggerDer(oJson:GetValue("order"):GetValue('items'), cCoord)
		end
	EndIf

Return cCoord

/*/{Protheus.doc} TriggerDer
	Engatilha os eventos derivados para atualizar AGCO
	é feito de 7 em 7 peças para melhorar performance de geração e envio de jsons

	@author Vinicius Gati
	@since 21/06/2017
/*/
Method TriggerDer(aItems, cCoord) Class OFAGVmiPedido
		Local nX := 1
		Local oVmi := OFAGVmi():New()
		For nX:= 1 to Len(aItems)
			oItem := aItems[nX]
			// somente 1 por vez infelizmente
			oVMi:Trigger({;
				{'EVENTO', oVmi:oVmiMovimentos:Inventario },;
				{'NUMCONTROLE' , cCoord                   },;
				{'ORIGEM', "DMS3_DMS1"                    },;
				{'PECAS' , {oItem:GetValue('partNumber') }} ;
			})
		Next
Return .T.

/*/{Protheus.doc} GetPedido
	Retorna dados conforme DMS-3 com dados de um pedido ( Entrada por Compra )
	@author Vinicius Gati
	@since 21/06/2017
	@param cIdPedido, String, Código do pedido
	@param cQuerySD1, String, Query SQL do SD1
/*/
Method GetDadosPedido( cIdPedido , cQuerySD1) Class OFAGVmiPedido
	Local aArea     := GetArea()
	Local aAreaA1   := SA1->(GetArea())
	Local aAreaA2   := SA2->(GetArea())
	Local aAreaD1   := SD1->(GetArea())
	Local cAl       := "SQLSD1"
	Local lFezCabec := .f.
	Local cOrderID  := xFilial('SD1')+cIdPedido // Filial + DOC + SERIE + FORNECEDOR + LOJA
	Local oPedido   := DMS_DataContainer():New({ {"items", {} } })

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuerySD1 ), cAl, .F., .T. )
	while !( (cAl)->(eof()) )
		SD1->(DbGoto( (cAl)->( RECSD1 ) ))
		If !lFezCabec // Faz se ainda não fez o cabecalho da Compra
			oPedido:SetValue("orderId" , cOrderID)
			oPedido:SetValue("orderType", 'STOCK_ORDER')
			oPedido:SetValue("orderDate", SD1->D1_EMISSAO)
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek( xFiliAl('SA2') + SD1->D1_FORNECE + SD1->D1_LOJA )) .and. !EMPTY(SA2->A2_CGC)
				oPedido:SetValue("supplierLegalNumber", self:fmtDoc(SA2->A2_CGC))
				oPedido:SetValue("supplierName", SA2->A2_NOME)
			Else
				oPedido:remAttr("supplierLegalNumber")
				oPedido:remAttr("supplierName")
			EndIf
			lFezCabec := .t. // Faz o cabeçalho da Compra apenas uma vez
		EndIf
		oItem := DMS_DataContainer():New()
		oItem:SetValue("orderLineNumber", SD1->D1_ITEM)
		oItem:SetValue("partNumber", SD1->D1_COD)
		oItem:SetValue("receivedDate", SD1->D1_DTDIGIT)
		oItem:SetValue("requestedQuantity", SD1->D1_QUANT)
		oItem:SetValue("receivedQuantity", SD1->D1_QUANT)
		oItem:SetValue("canceledQuantity", 0 )
		oItem:SetValue("lineStatus", 'CLOSED')
		oItem:SetValue("netValue", ( SD1->D1_TOTAL - ( SD1->D1_VALICM + SD1->D1_VALIMP6 + SD1->D1_VALIMP5 + SD1->D1_ICMSCOM + SD1->D1_DIFAL ) ) ) // Valor Liquido
		oItem:SetValue("totalValue", SD1->D1_TOTAL) // Valor TOTAL
		oItem:SetValue("taxes", ( SD1->D1_VALICM + SD1->D1_VALIMP6 + SD1->D1_VALIMP5 + SD1->D1_ICMSCOM + SD1->D1_DIFAL ) ) // Valor Impostos (diferença entre Valor Liquido e TOTAL)
		oItem:SetValue("currency",'BRL')
		AADD( oPedido:GetValue('items'), oItem )
		(cAl)->(DBSkip())
	enddo
	(cAl)->(dbCloseArea())
	DbSelectArea("SD1")

	RestArea( aAreaA1 )
	RestArea( aAreaA2 )
	RestArea( aAreaD1 )
	RestArea( aArea   )
Return oPedido