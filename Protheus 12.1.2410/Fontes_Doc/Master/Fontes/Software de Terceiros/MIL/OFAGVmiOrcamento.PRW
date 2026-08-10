#include "protheus.ch"

function OFAGVmiOrcamento()
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

/*/{Protheus.doc} OFAGVmiOrcamento
	Interface DMS - 4 da definição do VMI
	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiOrcamento from OFAGVmiBase
	Data cIntName
	Data oSqlHlp
	Data oVmi
	Data aItemsDer
	Method New() CONSTRUCTOR
	Method Trigger()
	Method TriggerDer()
	Method TriggerLostSales()
	Method ControleVB6()
	Method GetOrder()
	Method GetType()
	Method GetItems()
	Method isFaturado()
	Method GetDtFat()
EndClass

Method New() Class OFAGVmiOrcamento
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
	::aItemsDer := {}
return self

/*/{Protheus.doc} Trigger
	Dispara evento para envio de dados ao VMI, interface DMS-4

	@author Vinicius Gati
	@since 22/06/2017
	@param oParams, DMS_DataContainer, com os dados: NUMERO_ORCAMENTO, CLIENTE e LOJA
/*/
Method Trigger(oParams) Class OFAGVmiOrcamento
	Local lCargaIni := oParams:GetBool('INICIALIZACAO', .F.)
	Local oJson  := DMS_DataContainer():New()
	Local cCoord := ""
	Local cVS1_NUMORC := oParams:GetValue("NUMERO_ORCAMENTO")
	Local lCancelam   := ( oParams:GetValue("ORIGEM") == "OFIOM220_DMS4" )
	Local lTransf     := ( oParams:GetValue("ORIGEM") == "OFIOM430_DMS1" )
	Local aArquiv   := oParams:GetValue("ARQUIVOS",{})
	Local aSeqDev   := oParams:GetValue("SEQ_DEVOLUCAO",{})
	
	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ ""                         , ""             }) // 02 = SB2
		aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VS1") , xFilial("VS1") }) // 06 = VS1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VS3") , xFilial("VS3") }) // 07 = VS3
		aAdd(aArquiv,{ ""                         , ""             }) // 08 = VO1
		aAdd(aArquiv,{ ""                         , ""             }) // 09 = VO2
		aAdd(aArquiv,{ ""                         , ""             }) // 10 = VO3
		aAdd(aArquiv,{ ""                         , ""             }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	if lCargaIni
		if self:oVmiJson:Exist(oParams)
			return 'ja_gerado'
		endif
	endif

	self:oVmi := OFAGVmi():New()

	dbSelectArea("VS1")
	dbSetOrder(1)
	msSeek( aArquiv[06,2] + cVS1_NUMORC)

	if VS1->VS1_STATUS != 'X' .and. !lCancelam .and. !lTransf
		return "0"
	endif

	if VS1->VS1_TIPORC == "3" .and. Empty(VS1->VS1_FILDES)
		return "0"
	endif

	// Pedidos não são tratados como orçamento, apenas é disparado venda perdida dele
	if VS1->VS1_TIPORC == "P" .and. !lCargaIni
		self:TriggerLostSales(cVS1_NUMORC,aArquiv)
	endif
	::aItemsDer := {}
	
	If !lCargaIni
		SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
	EndIf

	oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
	oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))
	oJson:SetValue("order", self:GetOrder(cVS1_NUMORC,lCancelam,aArquiv,aSeqDev,lTransf))
	if ValType( oJson:GetValue("order", Nil) ) == "U" // não envia se não gerou dados
		return "0"
	endif

	if LEN(oJson:GetValue("order"):GetValue("items")) > 0 // pode acontecer de um orçamento não ter peças AGCO, nesse caso nada será enviado
		If VS1->VS1_TIPORC <> "3" 
			cCoord := self:oVmiJson:Persist(self:cIntName, oParams, {oJson})
			If !lCargaIni
				self:TriggerDer(self:aItemsDer, cCoord)
			endif
		Else
			if !lCargaIni
				cCoord := self:ControleVB6() // Necessario batizar o Nro de Controle pq Orcamentos de Transferencia nao tem DMS4
				self:TriggerDer(self:aItemsDer,cCoord, lTransf)
			EndIf
		EndIf
	endif
Return cCoord

/*/{Protheus.doc} TriggerDer
	Engatilha os eventos derivados para atualizar AGCO
	é feito de 7 em 7 peças para melhorar performance de geração e envio de jsons

	@author Vinicius Gati
	@since 21/06/2017
/*/
Method TriggerDer(aItems, cCoord, lTransf) Class OFAGVmiOrcamento
Local nX     := 1
Default lTransf := .F. 

		For nX:= 1 to Len(aItems)
			oItem := aItems[nX]
			self:oVmi:Trigger({;
				{'EVENTO', self:oVmi:oVmiMovimentos:Inventario},;
				{'NUMCONTROLE' , cCoord                       },;
				{'ORIGEM', iif(lTransf,"OFIOM430_DMS1","DMS4_DMS1")                        },;
				{'PECAS' , {oItem:GetValue('partNumber')}     } ;
			})
		Next
Return .T.

/*/{Protheus.doc} ControleVB6
	Pega Nro de Controle do VB6

	@author Andre Luis Almeida
	@since 30/12/2019
/*/
Method ControleVB6() Class OFAGVmiOrcamento
Local cCoord := Soma1(FM_SQL("SELECT MAX(VB6_NCONTR) FROM "+RetSqlName('VB6')+" WHERE VB6_FILIAL = '"+xFilial('VB6')+"' AND D_E_L_E_T_ = ' '")) // Único para todos os aJsons que serão salvos
VB6->(dbGoTo(VB6->(Recno())))
Return cCoord

/*/{Protheus.doc} TriggerLostSales
	Dispara evento para envio de dados ao VMI, interface DMS-5 vendas perdidas para pedido

	@author Vinicius Gati
	@since 22/06/2017
	@param cVS1_NUMORC, string, numero do orcamento(pedido)
/*/
Method TriggerLostSales(cVS1_NUMORC, aArquiv) Class OFAGVmiOrcamento
	local cQuery     := ""
	local aResults   := {}
	local nX         := 0
	local oVmiParams := OFAGVmiParametros():New()
	Default aArquiv  := {}

	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ ""                         , ""             }) // 02 = SB2
		aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VS1") , xFilial("VS1") }) // 06 = VS1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VS3") , xFilial("VS3") }) // 07 = VS3
		aAdd(aArquiv,{ ""                         , ""             }) // 08 = VO1
		aAdd(aArquiv,{ ""                         , ""             }) // 09 = VO2
		aAdd(aArquiv,{ ""                         , ""             }) // 10 = VO3
		aAdd(aArquiv,{ ""                         , ""             }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	dbSelectArea("VS1")
	dbSetOrder(1)
	msSeek( aArquiv[06,2] + cVS1_NUMORC)

	cQuery += " SELECT B1_COD, VS3_QTDINI "
	cQuery += "   FROM " + aArquiv[07,1] // VS3
	cQuery += "   JOIN " + aArquiv[01,1] + " ON B1_FILIAL = '"+aArquiv[01,2]+"' AND B1_CODITE = VS3_CODITE AND B1_GRUPO = VS3_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE VS3_FILIAL = '"+aArquiv[07,2]+"' "
	cQuery += "   AND VS3_NUMORC = '"+cVS1_NUMORC+"' "
	cQuery += "   AND VS3_MOTPED = '"+oVmiParams:codVendaPerdida()+"' "
	cQuery += "   AND VS3.D_E_L_E_T_  = ' ' "
	aResults := self:oSqlHlp:GetSelectArray(cQuery, 2)

	for nX := 1 to LEN(aResults)
		self:oVMi:Trigger({;
			{'EVENTO'         , self:oVmi:oVmiMovimentos:VendaPerdida },;
			{'CODIGO_PECA'    , aResults[nX, 1]                       },;
			{'QUANTIDADE'     , aResults[nX, 2]                       },;
			{'CODIGO_CLIENTE' , VS1->VS1_CLIFAT                       },;
			{'LOJA'           , VS1->VS1_LOJA                         },;
			{'DATA'           , VS1->VS1_DATORC                       },;
			{'ORIGEM'         , "INTERNA"                             },;
			{'TIPO'           , IIf(VS1->VS1_TIPORC=='P','S','W')     } ; // S = Balcao / W = Oficina
		})
	next
Return .T.

/*/{Protheus.doc} GetOrder
	Retorna objeto data container no formato de order para VMI que serã cnvertido em json

	@author Vinicius Gati
	@since 23/06/2017
	@param cVS1_NUMORC, String , código do orçamento
/*/
Method GetOrder(cVS1_NUMORC,lCancelam,aArquiv,aSeqDev,lTransf) Class OFAGVmiOrcamento
	Local aArea    := getArea()
	Local aAreaA1  := getArea('SA1')
	Local aAreaVS1 := getArea('VS1')
	Local oOrder   := Nil
	Default aArquiv := {}
	Default aSeqDev := {}
	Default lTransf := .F.

	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ ""                         , ""             }) // 02 = SB2
		aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VS1") , xFilial("VS1") }) // 06 = VS1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VS3") , xFilial("VS3") }) // 07 = VS3
		aAdd(aArquiv,{ ""                         , ""             }) // 08 = VO1
		aAdd(aArquiv,{ ""                         , ""             }) // 09 = VO2
		aAdd(aArquiv,{ ""                         , ""             }) // 10 = VO3
		aAdd(aArquiv,{ ""                         , ""             }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	dbSelectArea("VS1")
	dbSetOrder(1)
	msSeek( aArquiv[06,2] + cVS1_NUMORC)

	if VS1->VS1_TIPORC == "3" // transferencia
		SA1->(dbGoTo(self:oFilHlp:GetCliente(VS1->VS1_FILDES)))
	else
		dbSelectArea("SA1")
		dbSetOrder(1)
		MsSeek(xFilial('SA1')+VS1->VS1_CLIFAT+VS1->VS1_LOJA)
	endif

	// se for cliente parceiro não envia dados
	if ! self:oVmi:oVmiParametros:ClienteValido(SA1->(RECNO()))
		return Nil
	end

	cIdent := iif(VS1->VS1_TIPORC == "P", VS1->VS1_NUMORC, VS1->VS1_PEDREF)
	if Empty(cIdent)
		cIdent := VS1->VS1_NUMORC
	endif
	oOrder := DMS_DataContainer():New({;
		{"orderId"            , aArquiv[06,2] + "_" + cIdent  },;
		{"orderDate"          , VS1->VS1_DATORC                },;
		{"orderType"          , self:GetType(VS1->VS1_TIPORC)  },;
		{"customerLegalNumber", self:fmtDoc(SA1->A1_CGC)       },;
		{"items"              , self:GetItems(VS1->VS1_NUMORC,lCancelam,aArquiv,aSeqDev,lTransf) } ;
	})

	RestArea(aAreaVS1)
	RestArea(aAreaA1)
	RestArea(aArea)
Return oOrder

/*/{Protheus.doc} GetItems
	Retorna objeto data container no formato de order para VMI que serã cnvertido em json

	@author Vinicius Gati
	@since 23/06/2017
	@param cVS1_NUMORC, String , código do orçamento
/*/
Method GetItems(cVS1_NUMORC,lCancelam,aArquiv,aSeqDev,lTransf) Class OFAGVmiOrcamento
	Local aArea     := getArea()
	Local aAreaVS3  := getArea('VS3')
	local aItems    := {}
	local cQueryNA  := ''
	Local nSequen   := 0
	Local cStatus   := ""
	Local oVmiPars  := OFAGVmiParametros():New()
	Local cGrupos   := oVmiPars:todosGrupos() // Retorna TODOS os Grupos (Originais e Paralelos) para serem utilizados nas Querys
	Local nPosSeq   := 0
	Local nQtdDev   := 0
	Default aArquiv := {}
	Default aSeqDev := {}
	Default lTransf := .F.

	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ ""                         , ""             }) // 02 = SB2
		aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VS1") , xFilial("VS1") }) // 06 = VS1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("VS3") , xFilial("VS3") }) // 07 = VS3
		aAdd(aArquiv,{ ""                         , ""             }) // 08 = VO1
		aAdd(aArquiv,{ ""                         , ""             }) // 09 = VO2
		aAdd(aArquiv,{ ""                         , ""             }) // 10 = VO3
		aAdd(aArquiv,{ ""                         , ""             }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	dbSelectArea('VS1')
	dbSetOrder(1)
	MsSeek( aArquiv[06,2] + cVS1_NUMORC)

	dbSelectArea('VS3')
	dbSetOrder(1)
	dbSeek( aArquiv[07,2] + cVS1_NUMORC)

	do while VS3->VS3_FILIAL + VS3->VS3_NUMORC == aArquiv[07,2] + cVS1_NUMORC
		if "'"+Alltrim(VS3->VS3_GRUITE)+"'" $ cGrupos

			cB1_COD := FM_SQL("SELECT B1_COD FROM " + RetSqlName('SB1') +;
												" WHERE B1_FILIAL  = '"+aArquiv[01,2]+"'"+;
												"   AND B1_CODITE  = '"+VS3->VS3_CODITE+"'"+;
												"   AND B1_GRUPO   = '"+VS3->VS3_GRUITE+"'"+;
												"   AND D_E_L_E_T_ = ' ' ")

			if ! Empty(cB1_COD)
				nQtdEst := self:EmEstoque(cB1_COD)
				nSequen++
				dDtShip := self:GetDtFat(VS1->VS1_NUMNFI, VS1->VS1_SERNFI)
				nPosSeq := aScan( aSeqDev , { |x| x[1] == val(VS3->VS3_SEQUEN) })
				nQtdDev := IIf( nPosSeq > 0 , aSeqDev[nPosSeq,2] , 0 )
				dDtShip := IIf( nQtdDev == VS3->VS3_QTDITE , ctod("") , dDtShip ) // Caso o Item tenha sido devolvido, colocar como CANCELLED
				cStatus := iif( lTransf, "CLOSED", Iif(empty(dDtShip).or.lCancelam, "CANCELLED", "CLOSED" )) 
				oItem := DMS_DataContainer():New({;
					{"orderLineNumber"  , Alltrim(str(nSequen))                        },;
					{"partNumber"       , cB1_COD                                      },;
					{"shippedQuantity"  , VS3->VS3_QTDITE - VS3->VS3_QTDAGU - nQtdDev  },;
					{"returnedQuantity" , 0                                            },;
					{"canceledQuantity" , iif( cStatus == "CANCELLED", VS3->VS3_QTDITE, nQtdDev ) },;
					{"requestedDate"    , VS1->VS1_DATORC                              },;
					{"quantityAvailable", nQtdEst                                      },;
					{"lineStatus"       , cStatus                                      },;
					{"requestedQuantity", VS3->VS3_QTDINI-IIf(nQtdDev<VS3->VS3_QTDINI,nQtdDev,0)      },;
					{"unusualSale"      , self:UnusualSale(VS3->VS3_CODSIT)            },;
					{"shippedDate"      , IIf(!Empty(dDtShip),dDtShip,VS1->VS1_DATORC) },;
					{"netValue"         , ( VS3->VS3_VALTOT - ( VS3->VS3_ICMCAL+VS3->VS3_VALPIS+VS3->VS3_VALCOF ) ) },;
					{"totalValue"       , VS3->VS3_VALTOT                              },;
					{"taxes"            , VS3->VS3_ICMCAL+VS3->VS3_VALPIS+VS3->VS3_VALCOF },;
					{"currency"         , 'BRL'                                        } ;
				})

				/* 
					Se é o pedido usa os dados direto caso seja orçamento 
					preciso encontrar os dados do pedido para enviar 
				*/
				if !Empty(VS1->VS1_PEDREF) 
					cQueryNA := ""
					cQueryNA += " SELECT VS3_QTDINI, VS3_CODSIT, VS3_VALTOT, VS3_ICMCAL, VS3_VALPIS, VS3_VALCOF "
					cQueryNA += "   FROM " + aArquiv[07,1] // VS3
					cQueryNA += "  WHERE VS3_FILIAL = '"+VS3->VS3_FILIAL+"' "
					cQueryNA += "    AND VS3_NUMORC = '"+VS1->VS1_PEDREF+"' "
					cQueryNA += "    AND VS3_GRUITE = '"+VS3->VS3_GRUITE+"' "
					cQueryNA += "    AND VS3_CODITE = '"+VS3->VS3_CODITE+"' "
					cQueryNA += "    AND VS3_SEQUEN = '"+VS3->VS3_SEQUEN+"' "
					cQueryNA += "    AND D_E_L_E_T_ = ' ' "
					aValues := self:oSqlHlp:GetSelectArray(cQueryNA,6)
					if LEN(aValues) >= 1
						oItem:SetValue("requestedQuantity", aValues[1,1] )
						oItem:SetValue("unusualSale"      , self:UnusualSale(aValues[1,2]) )
						oItem:SetValue("netValue"         , ( aValues[1,3] - ( aValues[1,4]+aValues[1,5]+aValues[1,6] ) ) ) // Valor Liquido de Venda
						oItem:SetValue("totalValue"       , aValues[1,3] ) // Valor TOTAL de Venda
						oItem:SetValue("taxes"            , aValues[1,4]+aValues[1,5]+aValues[1,6] ) // Valor Impostos de Venda
					end
				end				
				If cStatus == "CLOSED" .or. len(aSeqDev) > 0 .or. lCancelam
					AADD(aItems, oItem)
				EndIf
				AADD(self:aItemsDer, oItem)
			end
		end

		VS3->(dbSkip())
	end

	RestArea(aAreaVS3)
	RestArea(aArea)
Return aItems

/*/{Protheus.doc} GetType
	Converte o tipo do orçamento conforme documentado no VMI

	@author Vinicius Gati
	@since 23/06/2017
	@param cType, String , VS1_TIPORC
/*/
Method GetType(cVS1_TIPORC) Class OFAGVmiOrcamento
	do case
	case cVS1_TIPORC == 'P'
		return 'S'
	case cVS1_TIPORC == '1'
		return 'S'
	case cVS1_TIPORC == '2'
		return 'W'
	case cVS1_TIPORC == '3'
		return 'T'
	end
Return 'S'

/*/{Protheus.doc} isFaturado
	Retorna se o orçamento foi faturado

	@type function
	@author Vinicius Gati
	@since 11/09/2019
/*/
Method isFaturado(cFili, cNumOrc) Class OFAGVmiOrcamento
	local cNumNfi := ""
	local cQuery := " SELECT VS1_NUMNFI "
	cQuery += "   FROM "+self:oSqlHlp:NoLock('VS1')
	cQuery += "  WHERE VS1_FILIAL = '"+cFili+"' "
	cQuery += "    AND VS1_NUMORC = '"+cNumOrc+"' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	cNumNfi := fm_sql(cQuery)
	if ! Empty(cNumNfi)
		return .T. /* Faturado? */	
	endif
Return .F.

/*/{Protheus.doc} GetDtFat
	Data de faturamento

	@type function
	@author Vinicius Gati
	@since 11/09/2019
/*/
Method GetDtFat(cNumNfi, cSerNfi) Class OFAGVmiOrcamento
	local dData := ctod("")
	cArea := GetArea()
	dbSelectArea('SD2')
	dbSetOrder(3)
	if MsSeek(xFilial('SD2')+cNumNfi+cSerNfi)
		dData := SD2->D2_EMISSAO
	endif
	RestArea(cArea)
Return dData
