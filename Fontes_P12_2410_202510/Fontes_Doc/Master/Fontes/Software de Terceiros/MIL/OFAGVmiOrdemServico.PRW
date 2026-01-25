#include "protheus.ch"

function OFAGVmiOrdemServico()
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

/*/{Protheus.doc} OFAGVmiOrdemServico
	Interface DMS - 4 da definição do VMI
	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiOrdemServico from OFAGVmiBase
	Data cIntName
	Data oSqlHlp
	Data oVmi

	Method New() CONSTRUCTOR
	Method Trigger()
	Method TriggerDer()
	Method GetOS()
	Method GetItems()

EndClass

Method New() Class OFAGVmiOrdemServico
	_Super:New()
	::cIntName := "DMS-4"
	::oSqlHlp := DMS_SqlHelper():New()
	AADD(::aMapValid, {"data:order:items:sourceLocation"      , "V005"})
	AADD(::aMapValid, {"data:order:orderType"                 , "V007"})
	AADD(::aMapValid, {"data:order:orderType"                 , "Obri"})
	AADD(::aMapValid, {"data:order:items:unusualSale"         , "V011"})
	AADD(::aMapValid, {"data:order:items:lineStatus"          , "V009"})
	AADD(::aMapValid, {"data:order:items:lineStatus"          , "Obri"})
	AADD(::aMapValid, {"data:order:orderId"                   , "Obri"})
	AADD(::aMapValid, {"data:order:deliveredDealerLegalNumber", "Obri"})
	AADD(::aMapValid, {"data:order:orderDate"                 , "Obri"})
	AADD(::aMapValid, {"data:order:items:sourceLocation"      , "Obri"})
	AADD(::aMapValid, {"data:order:items:orderLineNumber"     , "Obri"})
	AADD(::aMapValid, {"data:order:items:partNumber"          , "Obri"})
	AADD(::aMapValid, {"data:order:items:receivedDate"        , "Obri"})
	AADD(::aMapValid, {"data:order:items:requestedQuantity"   , "Obri"})
	AADD(::aMapValid, {"data:order:items:receivedQuantity"    , "Obri"})
	AADD(::aMapValid, {"data:order:items:openQuantity"        , "Obri"})
return self

/*/{Protheus.doc} Trigger
	Dispara evento para envio de dados ao VMI, interface DMS-4

	@author Vinicius Gati
	@since 22/06/2017
	@param oParams, DMS_DataContainer, com os dados: NUMERO_OS
/*/
Method Trigger(oParams) Class OFAGVmiOrdemServico
	Local lCargaIni := oParams:GetBool('INICIALIZACAO', .F.)
	Local cOrigem   := oParams:GetValue("ORIGEM")
	Local oJson := DMS_DataContainer():New()
	Local cCoord := ""
	Local cVO1_NUMOSV := oParams:GetValue("NUMERO_OS")
	Local lCancelam   := ( oParams:GetValue("ORIGEM") == "OFIOM150_DMS4_OS" )
	Local aArquiv     := oParams:GetValue("ARQUIVOS",{})

	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ ""                         , ""             }) // 02 = SB2
		aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ ""                         , ""             }) // 06 = VS1
		aAdd(aArquiv,{ ""                         , ""             }) // 07 = VS3
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VO1") , xFilial("VO1") }) // 08 = VO1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VO2") , xFilial("VO2") }) // 09 = VO2
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VO3") , xFilial("VO3") }) // 10 = VO3
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SD2") , xFilial("SD2") }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	if self:oVmiJson:Exist(oParams)
		return 'ja_gerado'
	endif

	self:oVmi := OFAGVmi():New()

	dbSelectArea("VO1")
	dbSetOrder(1)
	if MsSeek( aArquiv[08,2] + cVO1_NUMOSV)
		if ( !lCargaIni .and. cOrigem == "OFIXX100_DMS4_OS" ) .or. ( lCargaIni .and. VO1->VO1_TEMFEC == "S" ) .or. lCancelam // [ Não é carga Inicial e é Fechamento de OS ] ou [ É carga inicial e já fechou a OS ] ou [ Cancelamento da OS ]
			If !lCargaIni
				SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
			EndIf
			oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
			oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))
			oJson:SetValue("order", self:GetOS(cVO1_NUMOSV,lCancelam,aArquiv,lCargaIni))
			if ValType( oJson:GetValue("order", Nil) ) == "U" // não envia se não gerou dados
				return "0"
			end
			if LEN( oJson:GetValue("order"):GetValue("items") ) == 0
				return "0" // nenhum item elegível.
			end
			cCoord := self:oVmiJson:Persist( self:cIntName , oParams , {oJson} , , lCargaIni )
			if !lCargaIni
				self:TriggerDer(oJson:GetValue('order'):GetValue('items'), cCoord)
			end
		endif
	end
Return cCoord

/*/{Protheus.doc} TriggerDer
	Engatilha os eventos derivados para atualizar AGCO
	é feito de 7 em 7 peças para melhorar performance de geração e envio de jsons

	@author Vinicius Gati
	@since 21/06/2017
/*/
Method TriggerDer(aItems, cCoord) Class OFAGVmiOrdemServico
	Local nX     := 1
	Local aPecas := self:oArHlp:Map(aItems, {|oItem| oItem:GetValue('partNumber') })
	aPecas := self:oArHlp:Uniq(aPecas)
	For nX:= 1 to Len(aPecas)
		self:oVmi:Trigger({;
			{'EVENTO', self:oVmi:oVmiMovimentos:Inventario},;
			{'NUMCONTROLE' , cCoord                       },;
			{'ORIGEM', "DMS4_DMS1"                        },;
			{'PECAS' , {aPecas[nX]} } ;
		})
	Next
Return .T.

/*/{Protheus.doc} GetOS
	Retorna objeto data container no formato de order para VMI que sera convertido em json

	@author Vinicius Gati
	@since 03/06/2017
	@param cVO1_NUMORC, String , código da os
/*/
Method GetOS(cVO1_NUMOSV,lCancelam,aArquiv,lCargaIni) Class OFAGVmiOrdemServico
	Local aArea    := getArea()
	Local aAreaA1  := getArea('SA1')
	Local aAreaVO1 := getArea('VO1')
	Local oOrder   := Nil
	Default aArquiv := {}
	Default lCargaIni := .f.

	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ ""                         , ""             }) // 02 = SB2
		aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ ""                         , ""             }) // 06 = VS1
		aAdd(aArquiv,{ ""                         , ""             }) // 07 = VS3
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VO1") , xFilial("VO1") }) // 08 = VO1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VO2") , xFilial("VO2") }) // 09 = VO2
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VO3") , xFilial("VO3") }) // 10 = VO3
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SD2") , xFilial("SD2") }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	dbSelectArea("VO1")
	dbSetOrder(1)
	msSeek( aArquiv[08,2] + cVO1_NUMOSV)

	dbSelectArea("SA1")
	dbSetOrder(1)
	if Empty(VO1->VO1_FATPAR)
		dbSeek(xFilial('SA1')+VO1->VO1_PROVEI+VO1->VO1_LOJPRO)
	else
		dbSeek(xFilial('SA1')+VO1->VO1_FATPAR+VO1->VO1_LOJA)
	end

	// se for cliente parceiro não envia dados
	if ! self:oVmi:oVmiParametros:ClienteValido(SA1->(RECNO()))
		return Nil
	end

	oOrder := DMS_DataContainer():New({;
		{"orderId"            , aArquiv[08,2] + cVO1_NUMOSV + "_OS"  },;
		{"orderDate"          , VO1->VO1_DATABE               },;
		{"orderType"          , "W"                           },; //oficina somente
		{"customerLegalNumber", self:fmtDoc(SA1->A1_CGC)      },;
		{"items"              , self:GetItems(VO1->VO1_NUMOSV,lCancelam,aArquiv,lCargaIni)} ;
	})

	RestArea(aAreaVO1)
	RestArea(aAreaA1)
	RestArea(aArea)
Return oOrder

/*/{Protheus.doc} GetItems
	Retorna objeto data container no formato de order para VMI que serã cnvertido em json

	@author Vinicius Gati
	@since 23/06/2017
	@param cVO1_NUMOSV, String , código da Ordem de Servico
/*/
Method GetItems(cVO1_NUMOSV,lCancelam,aArquiv,lCargaIni) Class OFAGVmiOrdemServico
	local aItems  := {}
	local aDevols := {}
	local cAl     := GetNextAlias()
	local cQuery  := ""
	local nIdx    := 1
	local nIdx2   := 1
	Local cStatus := IIf(lCancelam,"CANCELLED","CLOSED") // faturado ou não
	Local cB1_COD := "INICIAL"
	Private oVmiPars  := OFAGVmiParametros():New()
	Private oVmi      := OFAGVmi():New()
	Private cGrupos   := oVmiPars:todosGrupos() // Retorna TODOS os Grupos (Originais e Paralelos) para serem utilizados nas Querys
	Default aArquiv   := {}
	Default lCargaIni := .f.

	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ ""                         , ""             }) // 02 = SB2
		aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ ""                         , ""             }) // 06 = VS1
		aAdd(aArquiv,{ ""                         , ""             }) // 07 = VS3
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VO1") , xFilial("VO1") }) // 08 = VO1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VO2") , xFilial("VO2") }) // 09 = VO2
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VO3") , xFilial("VO3") }) // 10 = VO3
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SD2") , xFilial("SD2") }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	cQuery += "SELECT VO2.VO2_DEVOLU , VO1.VO1_DATABE , VO1.VO1_STATUS , SB1.B1_COD ,"
	cQuery += "       VO3.VO3_QTDREQ , VO3.VO3_NUMNFI , VO3.VO3_SERNFI , VO3.VO3_DATFEC , VO3.VO3_CODSIT , VO3.R_E_C_N_O_ AS RECVO3 ,"
	cQuery += "       SD2.D2_QUANT , SD2.D2_TOTAL , SD2.D2_VALICM , SD2.D2_VALIMP6 , SD2.D2_VALIMP5 , SD2.D2_ICMSCOM , SD2.D2_DIFAL "
	cQuery += "  FROM " + aArquiv[08,1] // VO1
	cQuery += "  JOIN " + aArquiv[09,1] + " ON VO2.VO2_FILIAL = '"+aArquiv[09,2]+"' AND VO2.VO2_NUMOSV = VO1.VO1_NUMOSV AND VO2.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN " + aArquiv[10,1] + " ON VO3.VO3_FILIAL = '"+aArquiv[10,2]+"' AND VO3.VO3_NUMOSV = VO2.VO2_NUMOSV AND VO3.VO3_NOSNUM = VO2.VO2_NOSNUM "+IIf(!lCancelam," AND VO3.VO3_DATFEC != ' ' ","")+" AND VO3.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN " + aArquiv[01,1] + " ON SB1.B1_FILIAL  = '"+aArquiv[01,2]+"' AND SB1.B1_GRUPO = VO3.VO3_GRUITE AND SB1.B1_CODITE = VO3.VO3_CODITE AND SB1.B1_GRUPO IN ("+cGrupos+") AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  JOIN " + aArquiv[11,1] + " ON SD2.D2_FILIAL  = '"+aArquiv[11,2]+"' AND SD2.D2_DOC = VO3.VO3_NUMNFI AND SD2.D2_SERIE = VO3.VO3_SERNFI AND SD2.D2_COD = SB1.B1_COD AND SD2.D_E_L_E_T_"+IIf(!lCancelam," = ' ' ", " <> ' ' ")
	cQuery += " WHERE VO1.VO1_FILIAL = '"+aArquiv[08,2]+"' "
	cQuery += "   AND VO1.VO1_NUMOSV = '"+cVO1_NUMOSV+"' "
	cQuery += "   AND VO1.D_E_L_E_T_ = ' ' "
	If lCargaIni
		cQuery += "ORDER BY SB1.B1_COD "
	EndIf
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl, .F., .T. )
	while !( (cAl)->(eof()) )
		If lCargaIni // Quando Carga Inicial deve criar apenas um registro no VB6 correspondente a um VO3 (Requisição) por Produto ( Quantidade do SD2 )
			if !Empty((cAl)->B1_COD) .and. cB1_COD <> (cAl)->B1_COD .and. (cAl)->VO2_DEVOLU <> "0"
				cB1_COD := (cAl)->B1_COD
				oItem := DMS_DataContainer():New({;
					{"orderLineNumber"  , STR((cAl)->RECVO3) },; // usarei recno aqui, pois nao existe sequencia nas requisicoes oficina
					{"partNumber"       , (cAl)->B1_COD     },;
					{"shippedDate"      , STOD( (cAl)->VO3_DATFEC )},;
					{"shippedQuantity"  , (cAl)->D2_QUANT },;
					{"requestedQuantity", (cAl)->D2_QUANT },;
					{"reservedQuantity" , IIf(lCancelam,0,(cAl)->D2_QUANT) },;
					{"requestedDate"    , STOD( (cAl)->VO1_DATABE )},;
					{"returnedQuantity" , 0                 },;
					{"canceledQuantity" , 0                 },;
					{"lineStatus"       , cStatus           },;
					{"unusualSale"      , self:UnusualSale((cAl)->VO3_CODSIT) },;
					{"netValue"         , ( (cAl)->D2_TOTAL - ( (cAl)->D2_VALICM + (cAl)->D2_VALIMP6 + (cAl)->D2_VALIMP5 + (cAl)->D2_ICMSCOM + (cAl)->D2_DIFAL ) ) },;
					{"totalValue"       , (cAl)->D2_TOTAL     },;
					{"taxes"            , ( (cAl)->D2_VALICM + (cAl)->D2_VALIMP6 + (cAl)->D2_VALIMP5 + (cAl)->D2_ICMSCOM + (cAl)->D2_DIFAL ) },;
					{"currency"         , 'BRL'             } ;
				})
				AADD(aItems, oItem)
			endif
			(cAl)->(DBSkip())
			Loop // pula pq quando Carga Inicial deve fazer apenas um registro no VO3 (Requisição) por Produto ( Quantidade do SD2 )
		EndIf
		// se for devolucao vou adicionar em um vetor pra depois abater como qtd retornada... pra ficar legal e condizente os dados
		if (cAl)->VO2_DEVOLU == '0' .and. !lCancelam
			AADD(aDevols, { (cAl)->B1_COD, (cAl)->VO3_QTDREQ })
		else
			if !Empty((cAl)->B1_COD)
				oItem := DMS_DataContainer():New({;
					{"orderLineNumber"  , STR((cAl)->RECVO3) },; // usarei recno aqui, pois nao existe sequencia nas requisicoes oficina
					{"partNumber"       , (cAl)->B1_COD     },;
					{"shippedDate"      , STOD( (cAl)->VO3_DATFEC )},;
					{"shippedQuantity"  , (cAl)->VO3_QTDREQ },;
					{"requestedQuantity", (cAl)->VO3_QTDREQ },;
					{"reservedQuantity" , IIf(lCancelam,0,(cAl)->VO3_QTDREQ) },;
					{"requestedDate"    , STOD( (cAl)->VO1_DATABE )},;
					{"returnedQuantity" , 0                 },;
					{"canceledQuantity" , 0                 },;
					{"lineStatus"       , cStatus           },;
					{"unusualSale"      , self:UnusualSale((cAl)->VO3_CODSIT) },;
					{"netValue"         , ( (cAl)->D2_TOTAL - ( (cAl)->D2_VALICM + (cAl)->D2_VALIMP6 + (cAl)->D2_VALIMP5 + (cAl)->D2_ICMSCOM + (cAl)->D2_DIFAL ) ) },;
					{"totalValue"       , (cAl)->D2_TOTAL     },;
					{"taxes"            , ( (cAl)->D2_VALICM + (cAl)->D2_VALIMP6 + (cAl)->D2_VALIMP5 + (cAl)->D2_ICMSCOM + (cAl)->D2_DIFAL ) },;
					{"currency"         , 'BRL'             } ;
				})
				AADD(aItems, oItem)
			endif
		endif
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DbCloseArea())

	if LEN(aDevols) > 0
		// devoluções
		for nIdx := 1 to LEN(aItems)
			nIdx2 := ASCAN(aDevols, {|aDev| aDev[1] == aItems[nIdx]:GetValue("partNumber") })
			if nIdx2 > 0
				nQtdRet := aItems[nIdx]:GetValue("returnedQuantity")
				aItems[nIdx]:SetValue("returnedQuantity", nQtdRet + aDevols[nIdx2][2])
				nQtdRes := aItems[nIdx]:GetValue("reservedQuantity")
				aItems[nIdx]:SetValue("reservedQuantity", nQtdRes - aDevols[nIdx2][2])
				if aItems[nIdx]:GetValue("reservedQuantity", 0) < 0
					aItems[nIdx]:SetValue("reservedQuantity", 0)
				endif
				aDevols[nIdx2][1] := "***" // retira o codigo da peça para nao utilizar mais a linha referente a devolução
			endif
		next
	endif

	If !lCancelam
		For nIdx := 1 to LEN(aItems)
			If aItems[nIdx]:GetValue("reservedQuantity", 0) == 0
				aItems[nIdx]:SetValue("lineStatus", "CANCELLED") // Quando devolveu tudo -> Cancelou o registro
			EndIf
		Next
	EndIf

Return aItems
