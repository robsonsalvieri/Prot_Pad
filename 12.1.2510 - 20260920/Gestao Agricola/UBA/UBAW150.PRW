#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "UBAW150.ch"

Static __BAW150P1 := Nil

WSRESTFUL UBAW150 DESCRIPTION "Serviço REST para manipulação do reporte de produção via AGRO"

	WSMETHOD POST ProductionReport   DESCRIPTION "Inclui os reporte de produção resultante do beneficiamento."		WSSYNTAX "/v1/ProductionReport/" PATH "/v1/ProductionReport/"
	WSMETHOD POST Reversal 			 DESCRIPTION "Estorna o reporte de produção resultante do beneficiamento."		WSSYNTAX "/v1/ProductionReversal/" PATH "/v1/ProductionReversal/"

END WSRESTFUL

WSMETHOD POST ProductionReport WSSERVICE UBAW150
	local aMata250   := {}
	local aMata241   := {}
	Local cBody      := " "
	Local cResponse  := " "
	local dDatalote  := Nil
	local dDatemis   := Nil
	Local lGanhoPr   := SuperGetMV("MV_GANHOPR",.F.,.T.)
	Local lPercPrm   := SuperGetMV("MV_PERCPRM",.F., 0)
	Local lPost      := .T.
	Local nDiferenca := 0
	Local nNumero    := 0
	Local nPerda     := 0
	Local nQtdApon   := 0
	Local nX  		 := 0
	Local oJson      := JsonObject():New()
	Local oJsonRet   := JsonObject():New()
	Local cErroAgro	 := ""
	Local cNumDoc	 := ""
	Local cTM250	 := ""
	Local cTM241	 := ""

	Local cMVAGRTMPR := SuperGetMV("MV_AGRTMPR",.F.,"")

	Local aCabConsumo 	:= {}
	Local aCabCoPro 	:= {}
	Local aIteConsumo 	:= {}
	Local aIteCoPro 	:= {}

	Private l250Auto 	   := .T.
	Private l240:=.F.,l250 :=.T.,l241:=.F.,l242:=.F.,l261:=.F.,l185:=.F.,l650:=.F.,l680:=.F.,l681:=.F.
	Private lMsHelpAuto := .T.
	Private lMSErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private lPerdInf       := SuperGetMV("MV_PERDINF",.F.,.F.)

	cBody := ::GetContent()

	LogMsg('UBAW150 POST_ProductionReport', 0, 0, 1, '', '', cBody)

	If __BAW150P1 == Nil
		__BAW150P1 := ExistBlock("BAW150P1")
	EndIf

	If oJson:fromJson( cBody ) <> Nil
		SetRestFault(400, EncodeUTF8(STR0001)) //##"Parâmetros do apontamento não enviados ou inválidos."
		lPost := .F.

	ElseIf Empty(oJson['productionOrderNumber'])
		SetRestFault(400, EncodeUTF8(STR0002)) //##"Ordem de Produção não informada."
		lPost := .F.

	ElseIf Empty(oJson['part_total'])
		SetRestFault(400, EncodeUTF8(STR0003)) //##"Não foi informado se o apontamento é parcial/total"
		lPost := .F.

	ElseIf Empty(oJson['reportQuantity']) //.And. empty(oJson['scrapQuantity'])
		SetRestFault(400, EncodeUTF8(STR0004)) //##"Não foi informado a quantidade a ser apontada"
		lPost := .F.

	ElseIf Alltrim(oJson['companyId']) != cEmpAnt .or. Alltrim(oJson['branchId']) != cFilAnt
		If !(PrepEnv( oJson['companyId'], oJson['branchId'] ))
			lPost := .F.
			SetRestFault( 400, EncodeUTF8( STR0015 + oJson['companyId'] + STR0016 + oJson['branchId'] + "'." ) ) //##"Falha na preparação do ambiente para a Empresa " ##" e Filial "
		EndIf
	EndIf

	dDatemis := StoD(StrTran(substr(oJson['reportDateTime'],1,10),"-",""))
	If Empty(dDatemis) .or. Empty(oJson['reportDateTime'])
		SetRestFault(400, EncodeUTF8(STR0005)) //##"Não foi informado a data de reporte da produção"
		lPost := .F.
	EndIf

	If !Empty(oJson['movimentType'])
		cTM250 := Alltrim(oJson['movimentType'])
	ElseIf !Empty(cMVAGRTMPR)
		cTM250 := Alltrim(cMVAGRTMPR)
	Else
		SetRestFault(400, EncodeUTF8(STR0006)) //##"Código do tipo de movimento de produção não informado."
		lPost := .F.
	EndIf

	If lPost

		If Len(oJson['listOfSupplyOrders']) > 0

			cNumDoc := A261RetINV(NextNumero('SD3',2,'D3_DOC',.T.))
			SD3->(dbSetOrder(2))
			SD3->(dbSeek(cFilAnt+cNumDoc))
			cMay := 'SD3'+Alltrim(cFilAnt)+cNumDoc
			While SD3->(D3_FILIAL+D3_DOC) == cFilAnt + cNumDoc .Or. !MayIUseCode(cMay)
				If SD3->D3_ESTORNO # 'S'
					cNumDoc := Soma1(cNumDoc)
					cMay := 'SD3'+Alltrim(cFilAnt)+cNumDoc
				EndIf
				SD3->(dbSkip())
			EndDo

			aIteConsumo := {}
			aIteCoPro := {}
			For nX := 1 To Len(oJson['listOfSupplyOrders'])
				If oJson['listOfSupplyOrders'][nX]['usedQuantity'] > 0
					If !Empty(oJson['listOfSupplyOrders'][nX]['movimentType'])
						cTM241 := oJson['listOfSupplyOrders'][nX]['movimentType']
					Else
						cTM241 := SuperGetMV("MV_AGRSD3S",.F., "")
					EndIf

					If Len(aCabConsumo) = 0
						aCabConsumo := {{"D3_DOC"    , cNumDoc	, Nil},;
							{"D3_TM"     , cTM241	, Nil},;
							{"D3_EMISSAO", dDatemis , Nil}}
					EndIf

					Aadd(aIteConsumo,{})
					aAdd(aIteConsumo[Len(aIteConsumo)], {"D3_COD"    , oJson['listOfSupplyOrders'][nX]['materialCode'], Nil})
					aAdd(aIteConsumo[Len(aIteConsumo)], {"D3_QUANT"  , oJson['listOfSupplyOrders'][nX]['usedQuantity'], Nil})
					aAdd(aIteConsumo[Len(aIteConsumo)], {"D3_LOCAL"  , oJson['listOfSupplyOrders'][nX]['warehouseCode'], Nil})
					aAdd(aIteConsumo[Len(aIteConsumo)], {"D3_OP"     , oJson['productionOrderNumber'], Nil})
					aAdd(aIteConsumo[Len(aIteConsumo)], {"D3_DOC"    , cNumDoc , Nil})
					If !Empty(oJson['listOfSupplyOrders'][nX]['lotCode'])
						aAdd(aIteConsumo[Len(aIteConsumo)], {"D3_LOTECTL"  , oJson['listOfSupplyOrders'][nX]['lotCode'], Nil})
					EndIf
					If !Empty(oJson['listOfSupplyOrders'][nX]['locationCode'])
						aAdd(aIteConsumo[Len(aIteConsumo)], {"D3_LOCALIZ"  , oJson['listOfSupplyOrders'][nX]['locationCode'], Nil})
					EndIf

				ElseIF oJson['listOfSupplyOrders'][nX]['usedQuantity'] < 0
					If !Empty(oJson['listOfSupplyOrders'][nX]['movimentType'])
						cTM241 := oJson['listOfSupplyOrders'][nX]['movimentType']
					Else
						cTM241 := SuperGetMV("MV_AGRSD3E",.F., "")
					EndIf

					If Len(aCabCoPro) = 0
						aCabCoPro := {	{"D3_DOC"    , cNumDoc	, Nil},;
							{"D3_TM"     , cTM241	, Nil},;
							{"D3_EMISSAO", dDatemis , Nil}}
					EndIf

					Aadd(aIteCoPro,{})
					aAdd(aIteCoPro[Len(aIteCoPro)], {"D3_COD"    , oJson['listOfSupplyOrders'][nX]['materialCode'], Nil})
					aAdd(aIteCoPro[Len(aIteCoPro)], {"D3_QUANT"  , oJson['listOfSupplyOrders'][nX]['usedQuantity']*(-1), Nil})
					aAdd(aIteCoPro[Len(aIteCoPro)], {"D3_LOCAL"  , oJson['listOfSupplyOrders'][nX]['warehouseCode'], Nil})
					aAdd(aIteCoPro[Len(aIteCoPro)], {"D3_OP"     , oJson['productionOrderNumber'], Nil})

					If !Empty(oJson['listOfSupplyOrders'][nX]['lotCode'])
						aAdd(aIteCoPro[Len(aIteCoPro)], {"D3_LOTECTL"  , oJson['listOfSupplyOrders'][nX]['lotCode'], Nil})
					EndIf
					If !Empty(oJson['listOfSupplyOrders'][nX]['lotDueDate'])
						dDatalote := FwDateTimeToLocal(oJson['lotDueDate'])[1]
						aAdd(aIteCoPro[Len(aIteCoPro)], {"D3_DTVALID"  , dDatalote, Nil})
					EndIf
					If !Empty(oJson['listOfSupplyOrders'][nX]['locationCode'])
						aAdd(aIteCoPro[Len(aIteCoPro)], {"D3_LOCALIZ"  , oJson['listOfSupplyOrders'][nX]['locationCode'], Nil})
					EndIf
				EndIf
			next nX

			If Len(aIteConsumo) > 0
				Aadd(aMata241,{aCabConsumo,aIteConsumo})
			EndIf
			If Len(aIteCoPro) > 0
				Aadd(aMata241,{aCabCoPro,aIteCoPro})
			EndIf
		EndIf

		AADD(aMata250, {"D3_TM", cTM250							, Nil})
		AADD(aMata250, {"D3_OP", oJson['productionOrderNumber']	, Nil})
		AADD(aMata250, {"APTEMP", .T.							, Nil})  ///sem empenho

		//Quando a quantidade vier em caracter, será efetuada a conversão .
		If !Empty(oJson['reportQuantity'])
			If ValType(oJson['reportQuantity']) == "C"
				If AT("," , oJson['reportQuantity']) > 0
					nQtdApon := Val(StrTran(oJson['reportQuantity'],",","."))
				Else
					nQtdApon := Val(oJson['reportQuantity'])
				EndIf
			Else
				nQtdApon := oJson['reportQuantity']
			EndIf

			AADD(aMata250, {"D3_QUANT", nQtdApon, Nil})
		Endif

		If !Empty(oJson['itemCode'])
			AADD(aMata250, {"D3_COD", oJson['itemCode'], Nil})
		EndIf

		If !Empty(oJson['outflowWarehouseCode'])
			AADD(aMata250, {"D3_LOCAL", oJson['outflowWarehouseCode'], Nil})
		EndIf

		If !empty(oJson['unitOfMeasureCode'])
			AADD(aMata250, {"D3_UM", oJson['unitOfMeasureCode'], Nil})
		EndIf

		If !Empty(cNumDoc)
			AADD(aMata250, {"D3_DOC", cNumDoc, Nil})
		EndIf

		AADD(aMata250, {'AUTPRTOTAL', 'S', Nil})

		AADD(aMata250, {"D3_EMISSAO", dDatemis, Nil})

		If !Empty(oJson['costCenter'])
			AADD(aMata250, {"D3_CC", oJson['costCenter'], Nil})
		EndIf

		If !Empty(oJson['costCenter']) //CONTA CONTABIL
			AADD(aMata250, {"D3_CONTA", oJson['costCenter'], Nil})
		EndIf

		If !Empty(oJson['unitOfMeasureCode2'])
			AADD(aMata250, {"D3_SEGUM", oJson['unitOfMeasureCode2'], Nil})
		EndIf

		If !Empty(oJson['lotCode'])
			AADD(aMata250, {"D3_LOTECTL", oJson['lotCode'], Nil})
		EndIf

		If !empty(oJson['lotDueDate'])
			dDatalote := FwDateTimeToLocal(oJson['lotDueDate'])[1]
			AADD(aMata250, {"D3_DTVALID", dDatalote, Nil})
		EndIf

		//Quando a quantidade vier em caracter, será efetuada a conversão .
		If !Empty(oJson['unitOfMeasureCode2Quantity'])
			If ValType(oJson['unitOfMeasureCode2Quantity']) == "C"

				If AT("," , oJson['unitOfMeasureCode2Quantity']) > 0
					nNumero := Val(StrTran(oJson['unitOfMeasureCode2Quantity'],",","."))
				Else
					nNumero := Val(oJson['unitOfMeasureCode2Quantity'])
				EndIf
			Else
				nNumero := oJson['unitOfMeasureCode2Quantity']
			EndIf
			AADD(aMata250, {"D3_QTSEGUM", nNumero, Nil})
		EndIf

		If !Empty(oJson['scrapQuantity'])
			If ValType(oJson['scrapQuantity']) == "C"
				If AT("," , oJson['scrapQuantity']) > 0
					nPerda := Val(StrTran(oJson['scrapQuantity'],",","."))
				Else
					nPerda := Val(oJson['scrapQuantity'])
				EndIf
			Else
				nPerda := oJson['scrapQuantity']
			EndIf

			AADD(aMata250, {"D3_PERDA", nPerda, Nil})
		EndIf

		If !Empty(oJson['service'])
			AADD(aMata250, {"D3_SERVIC", oJson['service'], Nil})
		EndIf

		AADD(aMata250, {"D3_PARCTOT", oJson['part_total'], Nil})

		//Para gerar a produção a maior quando o percentual está maior que zero
		If lGanhoPr == .F. .And. lPercPrm > 0
			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2") + oJson['productionOrderNumber']))

			If (SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA)) < (nQtdApon + If(lPerdInf,0,nPerda) )
				nDiferenca := nQtdApon + If(lPerdInf,0,nPerda) - (SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA))
				AADD(aMata250, {"D3_QTMAIOR", nDiferenca, Nil})
			EndIf
		EndIf

		If lPost

			If __BAW150P1 //ponto de entrada
				aMata250 := ExecBlock("BAW150P1", .F., .F., {aMata250})
			EndIf

			Begin Transaction
				If Len(aMata241) > 0
					For nX := 1 To Len(aMata241)
						//Chamar EXECAUTO
						MSExecAuto( { | x , y, z | Mata241( x, y, z ) }, aMata241[nX][1], aMata241[nX][2], 3 )

						If lMSErroAuto
							lPost := .F.
							SetRestFault(400, EncodeUTF8(FormataErro()))
							DisarmTransaction()
							EXIT
						EndIf
					Next nX
				EndIf

				If !lMSErroAuto //Chamar EXECAUTO
					MSExecAuto({|x,y| MATA250(x,y)}, aMata250, 3)
					If lMSErroAuto
						lPost := .F.
						SetRestFault(400, EncodeUTF8(FormataErro()))
						DisarmTransaction()
					Else
						If !empty(oJson['listOfBales']) .AND. ValType(oJson['listOfBales']) == "A" .AND. Len(oJson['listOfBales']) > 0
							If !UBAW150GTF(oJson, @cErroAgro)
								lPost := .F.
								SetRestFault(400, EncodeUTF8(cErroAgro))
								DisarmTransaction()
							EndIf
						EndIf
					EndIF
				EndIf
			End Transaction

			If lPost
				oJsonRet['status'] := (STR0007) //##"Apontamento efetuado com sucesso!"
				oJsonRet['idAppointment'] := SD3->(D3_FILIAL+D3_DOC+D3_NUMSEQ) //Indice 8 da tabela SD3

				//saldo da ordem após o apontamento
				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2") + oJson['productionOrderNumber']))

				If !Empty(SC2->C2_DATRF)
					oJsonRet['opClose'] := .T.
				Else
					oJsonRet['opClose'] := .F.
				EndIf

				oJsonRet['reportQuantity'] := SC2->C2_QUANT - SC2->C2_QUJE - If(lPerdInf,0,SC2->C2_PERDA)

				cResponse := oJsonRet:toJson()

				If lPost
					::SetResponse(EncodeUTF8(cResponse))
				EndIf
			EndIf

		EndIf
	EndIf

	FreeObj(oJson)
	aSize(aMata250, 0)

Return lPost

WSMETHOD POST Reversal WSSERVICE UBAW150
	Local lPost 		:= .T.
	Local idAppointment := ""
	Local cCodOP 		:= ""
	Local cCodDoc		:= ""
	Local cProdOP		:= ""
	Local cMsgErro 		:= ""
	Local cRecnoPRD 	:= ""
	Local cQuery      	:= ""
	Local cAliasQry 	:= ""
	Local cResponse 	:= ""
	Local cTamC2NUM	 	:= TamSX3("C2_NUM")[1]
	Local cTamC2ITEM 	:= TamSX3("C2_ITEM")[1]
	Local cTamC2SEQU 	:= TamSX3("C2_SEQUEN")[1]
	Local nX 			:= 0
	Local oJson      	:= JsonObject():New()
	Local aApont 		:= {}
	Local aMATA241 		:= {}
	Local aCabAd 		:= {}
	Local aItensAd 		:= {}
	Local aMata650 		:= {}
	Local oJsonRet   	:= JsonObject():New()

	Private lMsErroAuto := .F.
	Private lMSHelpAuto	:= .T.

	cBody := ::GetContent()

	LogMsg('UBAW150 POST_Reversal', 0, 0, 1, '', '', cBody)

	If oJson:fromJson( cBody ) <> Nil
		SetRestFault(400, EncodeUTF8(STR0001)) //##"Parâmetros do apontamento não enviados ou inválidos."
		lPost := .F.
	ElseIf Alltrim(oJson['companyId']) != cEmpAnt .or. Alltrim(oJson['branchId']) != cFilAnt
		If !(PrepEnv( oJson['companyId'], oJson['branchId'] ))
			lPost := .F.
			SetRestFault( 400, EncodeUTF8( STR0015 + oJson['companyId'] + STR0016 + oJson['branchId'] + "'." ) ) //##"Falha na preparação do ambiente para a Empresa " ##" e Filial "
		EndIf
	EndIf

	If lPost
		For nX := 1 To Len(oJson['listOfReversalAppointments'])
			idAppointment := oJson['listOfReversalAppointments'][nX]['integrationReport']
			cCodOP := oJson['productionOrderNumber'] //formata tamanho correto
			cSC2Num := substr(Alltrim(cCodOP),1,cTamC2NUM)
			cSC2Item := substr(Alltrim(cCodOP),(cTamC2NUM+1),cTamC2ITEM)
			cSC2Sequen := substr(Alltrim(cCodOP),(cTamC2NUM+cTamC2ITEM+1),cTamC2SEQU)

			DbSelectArea("SD3")
			SD3->(dbSetOrder(8))
			If SD3->(dbSeek(idAppointment )) .and. Alltrim(SD3->(D3_FILIAL+D3_DOC+D3_NUMSEQ)) == AllTrim(idAppointment) .AND. AllTrim(SD3->D3_OP) == AllTrim(cCodOP )//posiciona
				cCodDoc := SD3->D3_DOC
				cProdOP := SD3->D3_COD

				//Encontra o apontamento da produção e monta o array com os dados para estorno da produção
				If Substr(SD3->D3_CF,1,2) == "PR" .And. SD3->D3_ESTORNO <> 'S'
					cRecnoPRD := SD3->(Recno())
					Apont := {}
					lMsErroAuto := .F.
					Aadd(aApont,{"D3_DOC"	 ,SD3->D3_DOC		,Nil})
					Aadd(aApont,{"D3_OP"	 ,SD3->D3_OP		,Nil})
					Aadd(aApont,{"D3_COD"    ,SD3->D3_COD		,Nil})
					Aadd(aApont,{"D3_UM"     ,SD3->D3_UM		,Nil})
					Aadd(aApont,{"D3_QUANT"  ,SD3->D3_QUANT		,Nil})
					Aadd(aApont,{"D3_LOCAL"  ,SD3->D3_LOCAL		,Nil})
					Aadd(aApont,{"D3_CC"     ,SD3->D3_CC		,Nil})
					Aadd(aApont,{"D3_EMISSAO",SD3->D3_EMISSAO	,Nil})
					Aadd(aApont,{"D3_LOTECTL",SD3->D3_LOTECTL	,Nil})
					Aadd(aApont,{"D3_DTVALID",SD3->D3_DTVALID	,Nil})
					Aadd(aApont,{"D3_NUMSEQ" ,SD3->D3_NUMSEQ    ,Nil})
					Aadd(aApont,{"D3_CHAVE"	 ,SD3->D3_CHAVE		,Nil})
					Aadd(aApont,{'D3_LOTECTL',SD3->D3_LOTECTL	,Nil})
					Aadd(aApont,{"D3_CF"	 ,SD3->D3_CF		,Nil})
					aAdd(aApont,{"INDEX"     , 4                ,Nil})
				EndIf

				//Consulta se possui outros movimentos(requisição/devolução) manuais para o apontamento de produção com mesmo OP e DOC e monta os dados para estorno
				cAliasQry := GetNextAlias()
				cQuery := " SELECT R_E_C_N_O_ AS D3RECNO, D3_DOC,D3_TM,D3_EMISSAO,D3_COD,D3_UM,D3_QUANT, "
				cQuery += " D3_LOCAL,D3_OP,D3_CHAVE,D3_NUMSEQ,D3_PROJPMS,D3_TASKPMS,D3_LOTECTL,D3_NUMLOTE,D3_LOCALIZ "
				cQuery += " FROM "+RetSqlName("SD3")+" SD3 "
				cQuery += " WHERE D3_FILIAL = '" + FWxFilial("SD3") + "' "
				cQuery += " AND D3_DOC = '" + cCodDoc + "' "
				cQuery += " AND D3_OP = '" + cCodOP + "' "
				cQuery += " AND D3_CF in ('DE0','RE0') "
				cQuery += " AND D3_ESTORNO <> 'S' "
				cQuery += " AND SD3.D_E_L_E_T_ = '' "
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

				dbSelectArea(cAliasQry)
				While (cAliasQry)->(!Eof())  .and. AllTrim((cAliasQry)->D3_DOC) == AllTrim(cCodDoc) .AND. AllTrim((cAliasQry)->D3_OP) == AllTrim(cCodOP)
					aCabAd := {}
					aItensAd := {}

					aAdd(aCabAd, {"D3_DOC"		, (cAliasQry)->D3_DOC				,Nil 	} ) // Documento
					aAdd(aCabAd, {"D3_TM"		,(cAliasQry)->D3_TM					,Nil	})
					aAdd(aCabAd, {"D3_EMISSAO"	,(cAliasQry)->D3_EMISSAO			,Nil	})

					aAdd(aItensAd,{"D3_ESTORNO"	,"S"						,Nil})
					aAdd(aItensAd,{"D3_COD"		,(cAliasQry)->D3_COD		,Nil})
					aAdd(aItensAd,{"D3_UM"		,(cAliasQry)->D3_UM			,Nil})
					aAdd(aItensAd,{"D3_QUANT"	,(cAliasQry)->D3_QUANT		,Nil})
					aAdd(aItensAd,{"D3_LOCAL"	,(cAliasQry)->D3_LOCAL		,Nil})
					aAdd(aItensAd,{"D3_OP"		,(cAliasQry)->D3_OP			,Nil})
					aAdd(aItensAd,{"D3_CHAVE"	,(cAliasQry)->D3_CHAVE		,Nil})
					aAdd(aItensAd,{"D3_NUMSEQ"	,(cAliasQry)->D3_NUMSEQ		,Nil})
					aAdd(aItensAd,{"D3_PROJPMS"	,(cAliasQry)->D3_PROJPMS	,Nil})
					aAdd(aItensAd,{"D3_TASKPMS"	,(cAliasQry)->D3_TASKPMS	,Nil})

					//verifica se produto tem controle por lote
					If Rastro(SD3->D3_COD)
						aAdd(aItensAd,{"D3_LOTECTL"	,(cAliasQry)->D3_LOTECTL	,Nil})
						aAdd(aItensAd,{"D3_NUMLOTE"	,(cAliasQry)->D3_NUMLOTE	,Nil})
						aAdd(aItensAd,{"D3_LOCALIZ"	,(cAliasQry)->D3_LOCALIZ	,Nil})
					EndIf

					Aadd(aMata241,{ (cAliasQry)->D3RECNO, aCabAd, aItensAd} )

					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
			Else
				SetRestFault(400, EncodeUTF8(STR0009)) //##"Não foi encontrado o registro do apontamento de produção informado para realizar o estorno!"
				lPost := .F.
			EndIF
		Next

		//###############################################################################################
		//##### REALIZA O ESTORNO DAS MOVIMENTAÇÕES DE ESTOQUE E DE PRODUÇÃO ############################
		//###############################################################################################
		Begin Transaction

			If lPost .and. Len(aApont) > 0
				lMsErroAuto := .F.
				lMsHelpAuto := .T.
				MsExecAuto({|x,y| MATA250(x,y)},aApont,5) //Estorna apontamento

				If lMsErroAuto
					cMsgErro := STR0010 + FormataErro() //##"Erro no estorno do apontamento da ordem de produção. "
					SetRestFault(400, EncodeUTF8(cMsgErro))
					lPost := .F.
					DisarmTransaction()
					Break
				EndIf
			EndIf

			If lPost .and. Len(aMata241) > 0
				Pergunte("MTA240",.F.)
				For nX := 1 To Len(aMata241)
					lMsErroAuto := .F.
					lMsHelpAuto := .T.

					dbSelectArea('SD3')
					SD3->(dbGotop())
					SD3->(dbGoto( aMata241[nX][1]) ) //POSICIONA NO REGISTRO A SER ESTORNADO
					If SD3->D3_ESTORNO <> 'S' .AND. AllTrim(SD3->D3_OP) == AllTrim(cCodOP) .AND. AllTrim(SD3->D3_DOC) == AllTrim(cCodDoc)
						//CHECA OS DADOS POSICIONADO E FAZ O ESTORNO
						MSExecAuto({|x,y,z| Mata241(x,y,z)},aMata241[nX][2],{aMata241[nX][3]},6) //Estorno faz por item
						If lMsErroAuto
							cMsgErro := STR0011 + FormataErro() //##"Erro no estorno dos movimentos da ordem de produção. "
							lPost := .F.
							SetRestFault(400, EncodeUTF8(cMsgErro))
							DisarmTransaction()
							Exit
						Endif
					Endif

				Next nX
			Endif

			If lPost .and. !empty(oJson['listOfBales']) .AND. ValType(oJson['listOfBales']) == "A" .AND. Len(oJson['listOfBales']) > 0
				If !UBAW150EFD(oJson, @cMsgErro) // delete fardinhos
					lPost := .F.
					SetRestFault(400, EncodeUTF8(cMsgErro))
					DisarmTransaction()
				EndIf
			EndIf

		End Transaction

		If lPost
			oJsonRet['status'] := STR0012 //##"Estorno realizado com sucesso!"
			cResponse := oJsonRet:toJson()
			::SetResponse(EncodeUTF8(cResponse))
		EndIf

	EndIf

Return lPost

/*/{Protheus.doc} FormataErro
Função para reunir e formatar as mensagens de erro para exibir no APP
@type function
@version  P12
@author Parffit Jim Balsanelli | claudineia.reinert
@since 21/02/2024
@return Character, String com o erro formatado
/*/
Static Function FormataErro()

	Local nCount    := 0
	Local aErroAuto := {}
	Local cLogErro  := ""

	aErroAuto := GetAutoGRLog()
	For nCount := 1 To Len(aErroAuto)
		If AT(':=',aErroAuto[nCount]) > 0 .And. AT('< --',aErroAuto[nCount]) < 1
			Loop
		EndIf
		If AT("------", aErroAuto[nCount]) > 0
			Loop
		EndIf
		//Retorna somente a mensagem de erro (Help) e o valor que está inválido, sem quebras de linha e sem tags '<>'
		If !Empty(cLogErro)
			cLogErro += " "
		EndIf
		cLogErro += AllTrim(StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|"))
	Next nCount

Return cLogErro

/*/{Protheus.doc} UBAW150GTF
Grava um registro na tabela DXI e N9D, conforme os dados vindo da integração com o beneficiamento agnóstico
Grava via RECLOCK pois não usa UBA protheus, populando a DXI e N9D para posterior uso no originação.
@type function
@version P12
@author claudineia.reinert
@since 21/02/2024
@param oJson, object, Json com os dados da integração 
@param cMsgErro, Character, Variavel por referencia para retornar mensagem de erro se houver
@return Logical, variavel logica de retorno de sucesso(.T.) ou falha(.F.)
/*/
Static Function UBAW150GTF(oJson,cMsgErro)
	Local lRet := .T.
	Local nX := 0
	Local dDataBen := ''
	Local cHoraBen := ''
	Local cCodSaf  := ''
	Local cCodEtq  := ''

	cMsgErro  := ''

	DbSelectArea("DXI")
	dbSetOrder(1)
	For nX := 1 to LEN(oJson['listOfBales'])
		lRet := .F. //para garantir que gravou pois foi enviado dados para gravar
		dDataBen := StoD(StrTran(substr(oJson['listOfBales'][nX]['reportDateTime'],1,10),"-",""))
		cHoraBen := substr(oJson['listOfBales'][nX]['reportDateTime'],12,TamSx3("DXI_HORA")[1])
		cCodSaf := cValToChar(oJson['listOfBales'][nX]['crop'])
		cCodEtq := cValToChar(oJson['listOfBales'][nX]['baleTag'])
		If !DXI->(MsSeek(FWxFilial("DXI")+PadR(cCodSaf,TamSX3("DXI_SAFRA")[1])+PadR(cCodEtq,TamSX3("DXI_ETIQ")[1])))
			RecLock("DXI", .T.)
			DXI->DXI_FILIAL := FWxFilial("DXI")
			DXI->DXI_SAFRA 	:= cValToChar(oJson['listOfBales'][nX]['crop'])
			DXI->DXI_ETIQ 	:= cValToChar(oJson['listOfBales'][nX]['baleTag'])
			DXI->DXI_CODIGO := cValToChar(oJson['listOfBales'][nX]['baleCode'])
			DXI->DXI_FARDAO := cValToChar(oJson['listOfBales'][nX]['bigBaleCode'])
			DXI->DXI_CODPRO := cValToChar(oJson['listOfBales'][nX]['materialCode'])
			DXI->DXI_PSBRUT := VAL(cValToChar(oJson['listOfBales'][nX]['grossWeight']))
			DXI->DXI_PSLIQU := VAL(cValToChar(oJson['listOfBales'][nX]['netWeight']))
			DXI->DXI_PSESTO := VAL(cValToChar(oJson['listOfBales'][nX]['netWeight']))
			DXI->DXI_LOTE   := cValToChar(oJson['listOfBales'][nX]['lotCode'])
			DXI->DXI_DATA 	:= dDataBen
			DXI->DXI_HORA 	:= cHoraBen
			DXI->DXI_LOCAL 	:= cValToChar(oJson['outflowWarehouseCode'])
			DXI->DXI_DATATU := dDataBase
			DXI->DXI_HORATU := Substr( Time(), 1, TamSx3("DXI_HORA")[1] )
			DXI->DXI_STATUS := "10"
			DXI->(MsUnlock())

			aMovFrd :=  {{	;
				{"N9D_FILIAL", FwxFilial("N9D")	},;
				{"N9D_SAFRA" , DXI->DXI_SAFRA  	},;
				{"N9D_FARDO" , DXI->DXI_ETIQ	},;
				{"N9D_TIPMOV", "01" 			},;
				{"N9D_PESINI", DXI->DXI_PSLIQU 	},;
				{"N9D_PESFIM", DXI->DXI_PSLIQU	},;
				{"N9D_DATA"  , dDAtaBase 		},;
				{"N9D_STATUS", "2" 				},;
				{"N9D_ENTLOC", DXI->DXI_PRDTOR 	},;
				{"N9D_LOJLOC", DXI->DXI_LJPRO 	},;
				{"N9D_CODROM", DXL->DXL_CODROM 	},;
				{"N9D_FILORG", FwxFilial("DXI")	},;
				{"N9D_CODFAR", DXI->DXI_CODIGO	},;
				{"N9D_LOTECT", DXI->DXI_LOTE	},;
				{"N9D_LOCAL" , DXI->DXI_LOCAL	} ;
				}}

			If !(GrvMovN9D("Inclui", aMovFrd, '', @cMsgErro))
				cMsgErro := STR0013 + "("+DXI->(DXI_FILIAL+DXI_SAFRA+DXI_ETIQ)+") " + cMsgErro //##"Erro na gravação do fardinho na tabela N9D. "
				lRet := .F.
				exit //sai do for e retorna .F. para reportar problema
			Else
				lRet := .T.
			EndIf

		Else
			cMsgErro := STR0008 + "("+DXI->(DXI_FILIAL+DXI_SAFRA+DXI_ETIQ)+")" //##"Erro! Fardinho já cadastrado na tabela DXI."
			lRet := .F.
			exit //sai do for e retorna .F. para reportar problema
		EndIf
	next nX

Return lRet

/*/{Protheus.doc} UBAW150EFD
Exclui registros na tabela DXI e ND9 referente aos fardinhos, conforme os dados vindos da integração com o beneficiamento agnóstico
Exclui via RECLOCK pois não usa UBA protheus.
@type function
@version P12
@author claudineia.reinert
@since 20/03/2024
@param oJson, object, Json com os dados da integração 
@param cMsgErro, Character, Variavel por referencia para retornar mensagem de erro se houver
@return Logical, variavel logica de retorno de sucesso(.T.) ou falha(.F.)
/*/
Static Function UBAW150EFD(oJson,cMsgErro)
	Local lRet 		:= .T.
	Local nX 		:= 0
	Local cCodSaf  	:= ''
	Local cCodEtq  	:= ''
	Local aChaveN9D := {}

	cMsgErro  := ''

	DbSelectArea("DXI")
	dbSetOrder(1)
	For nX := 1 to LEN(oJson['listOfBales'])
		cCodSaf := Alltrim(cValToChar(oJson['listOfBales'][nX]['crop']))
		cCodEtq := Alltrim(cValToChar(oJson['listOfBales'][nX]['baleTag']))
		If DXI->(dbSeek(FWxFilial("DXI") + PadR(cCodSaf, TamSX3("DXI_SAFRA")[1]) + PadR(cCodEtq, TamSX3("DXI_ETIQ")[1]) ))
			aChaveN9D := {{DXI->DXI_FILIAL},{DXI->DXI_SAFRA},{DXI->DXI_ETIQ},{"01"}}
			If !(GrvMovN9D("Exclui", , aChaveN9D, @cMsgErro))
				cMsgErro := STR0014 + "("+DXI->(DXI_FILIAL+DXI_SAFRA+DXI_ETIQ)+"). " + cMsgErro //##"Erro na exclusão do fardinho na tabela N9D. "
				lRet := .F.
				exit //sai do for e retorna .F. para reportar problema
			Else
				If RecLock("DXI", .F.) // Procura o registro e abre a gravação
					DXI->(DbDelete())
					DXI->(MsUnlock())
				EndIf
				lRet := .T.
			EndIf
		Else
			cMsgErro := STR0017 + "("+FWxFilial("DXI")+cCodSaf+cCodEtq+")" //##"Erro! Fardinho/Etiqueta não encontrado na tabela DXI."
			lRet := .F.
			exit //sai do for e retorna .F. para reportar problema
		EndIf
	next nX

Return lRet

/*/{Protheus.doc} GrvMovN9D
Função para gravação do registro na tabela N9D-movimento dos fardos
@type function
@version  P12
@author claudineia.reinert
@since 20/03/2024
@param cAcao, character, Ação podendo der "Incluir" ou "Excluir"
@param aMovFrd, array, Array com os campos e seus dados para gravação na tabela
@param aChaveMov, array, Chave para pesquisa do registro na tabela
@param cMsgErro, character, Variavel por referencia para retornar mensagem de erro se houver
@return Logical, variavel logica de retorno de sucesso(.T.) ou falha(.F.)
/*/
Static Function GrvMovN9D(cAcao, aMovFrd, aChaveMov, cMsgErro)

	Local aArea     	:= GetArea()
	Local lRet 			:= .T.
	Local aRet			:= {}

	Default aChaveMov 	:= {}

	if cAcao == "Inclui"
		aRet := AGRMOVFARD(aMovFrd, 1)
	elseIf cAcao == "Exclui"
		aRet := AGRMOVFARD(aMovFrd, 3, 5, aChaveMov)
	endIf

	if aRet[2] <> ""
		lRet := .F.
		cMsgErro := aRet[2]
	endIf

	RestArea(aArea)

Return lRet
