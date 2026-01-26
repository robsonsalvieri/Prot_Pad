#INCLUDE "protheus.ch"
#INCLUDE "RSKDefs.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RSKA070.CH"

Static _oHshQryAS       := FWHashMap():New()
Static _cRSKCustomer    := SuperGetMV( "MV_RSKCPAY", .T., "" )
Static _cRSKSNcc        := SuperGetMv( "MV_RSKSNCC", .F., "" )
Static _nSeqLog         := 0

//------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKMovAftSales
Função para atualizar AR2 - Movimentações x NF da carteira Off Balance - Gravar Bonificações e Prorrogações

@param aItens, array, dados de pos-venda 
    [1] = tenantId - ID do Tenant na Plataforma e Fluig
    [2] = platformId - PK da plataforma posteriormente enviada no POST para conclusão da sincronia da parcela
    [3] = erpId - Id de identificação do Titulo ( ArInvoiceInstallment )
    [4] = date - Data do movimento (dataHoraConclusaoProcessamento da API Supplier) com pattern AAAAMMDD
    [5] = operation - tipo de operação ( numero )
            Opções:
                0-Antecipação
                1-Baixa de título
                2-Estorno da baixa do título
                3-Coobrigação
                4-Divergencia comercial
                8-Recompra
                11-Prorrogação de vencimentos
                12-Bonificação
                13-Devolução
                14-Liberação de NCC  
                20-Conciliação bancária 
    [6] - history - Descrição do histórico
    [7] - localAmount - Valor bruto da operação - valor original da parcela ( numero )
    [8] = feeAmount - Valor do custo da operação ( numero )
    [9] = debitDate - data do débito do parceiro ( Data em que ocorrerá o débito do valor ao parceiro )
    [10] = creditUnits - Array com a relação de notas de credito e seu valor a ser compensado.
        [1] = Id de identificação da Nota de Crédito ( ArInvoiceInstalment ) - ERPID
        [2] = empresa - ERPID
        [3] = filial - ERPID
        [4] = prefixo - ERPID
        [5] = numero do titulo - ERPID
        [6] = parcela - ERPID
        [7] = tipo - ERPID
        [8] = Valor a ser compensado utilizando essa nota de crédito ( numero )
    [11] = creditAmount - Valor da soma das NCCs utilizadas nessa operação ( Terá valor apenas quando a operação for 12-Bonificação - numero )
    [12] = discountAmount - Valor do desconto a ser aplicado ( Terá valor apenas quando a operação for 12-Bonificação - numero )
    [13] = feeAmountOrigin - Estorno da taxa de antecipação ( Terá valor apenas quando a operação for 4-Divergência comercial ou 13-Devolução - numero )
    [14] = newDueDate - Nova data de vencimento
    [15] = debitAmount - Valor do Debito a ser pago pelo parceiro a Supplier
	[16] = totalDebitAmount - Valor Total do Debito a ser pago pelo parceiro a Supplier contempla Taxas
	[17] = receiptType - Tipo de Recebimento parceiro ("2" - Pagamento Contra-Vencimento, "3" - Antecipado - Pagamento em D+N)
	[18] = filial
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author  Marcia Junko
@since   29/10/2020
/*/
//------------------------------------------------------------------------------------------------------------
Function RSKMovAftSales( aItens As Array, lAutomato As Logical, cHost As Character, nType As Numeric )
	Local aArea      As Array
	Local aMovements As Array
	Local aDevol     As Array
	Local nMov       As Numeric
	Local nDev       As Numeric
	Local cIDAR4     As Character

	Default lAutomato := .F.

	aArea      := GetArea()
	aMovements := {}
	aDevol     := {}
	nMov       := 0
	nDev       := 0
	cIDAR4     := ""

	IF Empty( _cRSKCustomer )
		Return
	EndIf

	//-------------------------------------------------------------------------------
	// Cria um identificador para o log
	//-------------------------------------------------------------------------------
	cIDAR4     := RSKAR4IDLog()

	//-------------------------------------------------------------------------------
	// Separa os títulos por tipo de movimento
	//-------------------------------------------------------------------------------
	LogMsg("RSKMovAftSales", 23, 6, 1, "", "", "RSKMovAftSales => " + STR0017 +  cIDAR4 ) //"Processando Pos Faturamento LogId: "
	aMovements := RskGroupMovements(cIDAR4, aItens)

	_nSeqLog   := 0
	//-------------------------------------------------------------------------------
	// Ordena por tipo de movimento
	//-------------------------------------------------------------------------------
	aSort(aMovements,,,{|x,y| x[ AFTER_GRP_TYPE ] < y[ AFTER_GRP_TYPE ]})   // [1]-Tipo de movimento

	If !Empty( cIDAR4 )
		For nMov := 1 To Len(aMovements)
			Do Case
			Case aMovements[nMov][ AFTER_GRP_TYPE ] == PV_DEV      // [1]-Tipo de movimento ### 13=Devolução
				aDevol := RskVldDev( cIDAR4, aMovements[nMov][ AFTER_GRP_ITEMS ] )      // [2]-Array itens do movimento
				If !Empty(aDevol)
					For nDev := 1 To Len(aDevol)
						BEGIN TRANSACTION
							RskProcMov( cIDAR4, aMovements[nMov][ AFTER_GRP_TYPE ], aDevol[nDev][ AFTER_DEV_ITEMS ], cHost, nType, lAutomato )   // [1]-Tipo de movimento ### [3]-Array com as notas de entrada
						END TRANSACTION
					Next
				Else
					LogMsg("RSKMovAftSales", 23, 6, 1, "", "", "RSKMovAftSales => " +  STR0018 + cIDAR4 )  //"Falha em processar as devolucoes LogId: "
				EndIf
			Case ( aMovements[nMov][ AFTER_GRP_TYPE ] == PV_PRO .Or. aMovements[nMov][ AFTER_GRP_TYPE ] == PV_BON )       	// [1]-Tipo de movimento ### 11=Prorrogação ### 12=Bonificação
				RskProcMov( cIDAR4, aMovements[nMov][ AFTER_GRP_TYPE ], aMovements[nMov][ AFTER_GRP_ITEMS ], cHost, nType, lAutomato ) // [1]-Tipo de movimento ### [2]-Array itens do movimento
			Case ( aMovements[nMov][ AFTER_GRP_TYPE ] == PV_LIB_NCC )      // [1]-Tipo de movimento ### 14=Libera NCC
				RskNCCRelease(cIDAR4, aMovements[nMov][ AFTER_GRP_ITEMS ], cHost, nType, lAutomato )      // [2]-Array itens do movimento
			End Case
		Next
	EndIf

	LogMsg("RSKMovAftSales", 23, 6, 1, "", "", "RSKMovAftSales => " + STR0019 + cIDAR4 )  //"Fim Pos Faturamento LogId: "

	RestArea( aArea )
	FWFreeArray( aArea )
	FWFreeArray( aMovements )
	FWFreeArray( aDevol )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskVldDev
Valida se todas as devoluções enviada pelo Pos Faturamento estão no Documento
de Entrada (NCC)

@param cIDAR4, caracter, Id do lote de processamento
@param aMovements, array, Movimentos do tipo devolução, onde:
    [1] - chave 
    [2] - array com os dados do item ( posição do aItens)
    [3] - valor bruto da operação
    [4] - valor do custo da operação
    [5] - estorno da taxa de antecipação
    [6] - ERPID
    [7] - nota de crédito

@return aDevol , array, Retorna as devoluções agrupada por Documento de Entrada (NCC), sendo:
    [1] - chave
    [2] - quantidade de notas
    [3] - array com as notas de entrada
@author Squad NT TechFin
@since  06/11/2020
/*/
//--------------------------------------------------------------------------------------
Static Function RskVldDev( cIDAR4 As Character, aMovements As Array ) As Array
	Local aArea         As Array
	Local aAreaSE1      As Array
	Local aDevol        As Array
	Local aErpId        As Array
	Local aErpIdNCC     As Array
	Local aErpIdComp    As Array
	Local oQryNCC       As Object
	Local oQryNFS       As Object
	Local nCountNFS     As Numeric
	Local nMov          As Numeric
	Local nDev          As Numeric
	Local nARInv        As Numeric
	Local nCountDel     As Numeric
	Local nPosFind      As Numeric
	Local nLenPrefix    As Numeric
	Local nLenNum       As Numeric
	Local nLenInst      As Numeric
	Local nLenType      As Numeric
	Local cKeyNCC       As Character
	Local cTempNCC      As Character
	Local cTempNFS      As Character
	Local cBranchSE1    As Character
	Local cPrefix       As Character
	Local cInvoice      As Character
	Local cInstallment  As Character
	Local cInvoice_Type As Character

	aArea         := GetArea()
	aAreaSE1      := SE1->( GetArea() )
	aDevol        := {}
	aErpId        := {}
	aErpIdNCC     := {}
	aErpIdComp    := {}
	oQryNCC       := Nil
	oQryNFS       := Nil
	nCountNFS     := 0
	nMov          := 0
	nDev          := 0
	nARInv        := 0
	nCountDel     := 0
	nPosFind      := 0
	nLenPrefix    := TamSX3("E1_PREFIXO")[1]
	nLenNum       := TamSx3("E1_NUM")[1]
	nLenInst      := TamSx3("E1_PARCELA")[1]
	nLenType      := TamSx3("E1_TIPO")[1]
	cTempNCC      := GetNextAlias()
	cTempNFS      := GetNextAlias()
	cKeyNCC       := ""
	cBranchSE1    := ""
	cPrefix       := ""
	cInvoice      := ""
	cInstallment  := ""
	cInvoice_Type := ""

	SE1->(DBSetOrder(1))    //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

	For nMov := 1 To Len(aMovements)
		aErpId          := StrToKArr2(aMovements[nMov][ AFTER_ARR_KEY ],"|",.T.)    // [1]-chave
		aErpIdNCC       := StrToKArr2(aMovements[nMov][ AFTER_ARR_CUNIT ],"|",.T.)  // [7]-nota de credito
		cBranchSE1      := Padr(aErpIdNCC[ERPID_BRANCH]    ,FwSizeFilial())         // [2]-filial
		cPrefix         := Padr(aErpIdNCC[ERPID_PREFIX]    ,nLenPrefix)             // [3]-prefixo
		cInvoice        := Padr(aErpIdNCC[ERPID_INVOICE]   ,nLenNum)                // [4]-número do título
		cInstallment    := Padr(aErpIdNCC[ERPID_PARCEL]    ,nLenInst)               // [5]-parcela
		cInvoice_Type   := Padr(aErpIdNCC[ERPID_TYPE]      ,nLenType)               // [6]-tipo

		If SE1->(MsSeek( cBranchSE1+ cPrefix + cInvoice + cInstallment + cInvoice_Type ))
			oQryNCC  := GetQuery( "QTmpNCCOri" )
			oQryNCC:SetString( 1, aErpId[2] )           //Filial do titulo  (Documento de Origem)
			oQryNCC:SetString( 2, aErpId[3] )           //Prefixo do título   (Documento de Origem)
			oQryNCC:SetString( 3, aErpId[4] )           //Número do título   (Documento de Origem)
			oQryNCC:SetString( 4, SE1->E1_FILORIG )     //Filial de Origem (Documento de Entrada)
			oQryNCC:SetString( 5, SE1->E1_SERIE )       //Serie da NCC (Documento de Entrada)
			oQryNCC:SetString( 6, SE1->E1_NUM )         //Número da NCC (Documento de Entrada)
			oQryNCC:SetString( 7, SE1->E1_CLIENTE )     //Cliente da NCC (Documento de Entrada)
			oQryNCC:SetString( 8, SE1->E1_LOJA )        //Loja do cliente da NCC (Documento de Entrada)

			MPSysOpenQuery( oQryNCC:GetFixQuery(), cTempNCC )

			If (cTempNCC)->(!Eof())
				cKeyNCC     := SE1->E1_FILIAL + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
				nPosFind    := aScan(aDevol, {|x| x[ AFTER_DEV_KEY ] == cKeyNCC })  // [1]-Chave
				aErpIdComp  := StrToKArr2( aMovements[nMov][ AFTER_ARR_ERPID ], "|", .T.)   // [6]-ERPID
				If nPosFind == 0
					oQryNFS     := GetQuery( "QCountNFS" )
					oQryNFS:SetString(1,(cTempNCC)->F1_FILIAL)
					oQryNFS:SetString(2,(cTempNCC)->F1_DOC)
					oQryNFS:SetString(3,(cTempNCC)->F1_SERIE)
					oQryNFS:SetString(4,(cTempNCC)->F1_FORNECE)
					oQryNFS:SetString(5,(cTempNCC)->F1_LOJA)
					oQryNFS:SetString(6,aErpIdComp[2])
					oQryNFS:SetString(7,aErpIdComp[3])
					oQryNFS:SetString(8,aErpIdComp[4])
					oQryNFS:SetString(9,aErpIdComp[5])
					oQryNFS:SetString(10,aErpIdComp[6])

					MPSysOpenQuery( oQryNFS:GetFixQuery(), cTempNFS )
					nCountNFS := (cTempNFS)->TOTAL
					(cTempNFS)->(DBCloseArea())

					aAdd(aDevol,{cKeyNCC,nCountNFS,{aMovements[nMov]}})
				Else
					aAdd(aDevol[nPosFind][ AFTER_DEV_ITEMS ], aMovements[nMov])     // [3]-Array com as notas de entrada
				EndIf
			EndIf

			(cTempNCC)->(DBCloseArea())
		EndIf
	Next

	//-------------------------------------------------------------------------------
	// Valida se a NCC possui todas as NF's de origem envida pelo Pos Faturamento
	//-------------------------------------------------------------------------------
	For nDev := 1 To Len(aDevol)
		If aDevol[nDev] != Nil .And. aDevol[nDev][ AFTER_DEV_COUNT ] != Len( aDevol[nDev][ AFTER_DEV_ITEMS ] )      // [2]-Quantidade de notas ### [3]-Array com as notas de entrada
			For nARInv := 1 To Len( aDevol[nDev][3][1][2] )
				_nSeqLog++
				RSKAR4MakeLog(  aDevol[nDev][3][1][2][nARInv], AFTERSALES, cIDAR4, _nSeqLog, + STR0004 + Chr(10) + "NCC: " + aDevol[nDev][ AFTER_DEV_KEY ])  //"O Pos Faturamento não enviou todas as devoluções associada a este título. " ### [1]-Chave
			Next
			aDel(aDevol,nDev)
			nDev --
			nCountDel++
		EndIf
	Next

	aSize(aDevol,Len(aDevol)-nCountDel)

	RestArea( aArea )
	RestArea( aAreaSE1 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aErpId )
	FWFreeArray( aErpIdNCC )
	FWFreeArray( aErpIdComp )
	FreeObj(oQryNFS)
	FreeObj(oQryNCC)
Return aDevol

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskGroupMovements
Retorna a quantidade de NFS Mais Negocios no Documento de Entrada.

@param aItens, array, Itens do Pos Faturamento

@return aGroupMov , array, Dados do Pos Faturamento agrupado por título a receber, sendo:
    [1] - tipo de movimento
    [2] - itens do movimento
        [1] - chave 
        [2] - array com os dados do item ( posição do aItens)
        [3] - valor bruto da operação
        [4] - valor do custo da operação
        [5] - estorno da taxa de antecipação
        [6] - ERPID
        [7] - nota de crédito
        [8] - debitAmount
@author Squad NT TechFin
@since  06/11/2020
/*/
//--------------------------------------------------------------------------------------
Static Function RskGroupMovements(cIDAR4, aItens)
	Local nItem         := 0
	Local aERPId        := {}
	Local nPosMov       := 0
	Local nTAmount      := 0
	Local nDebAmount    := 0
	Local nTFees        := 0
	Local nTFeesOri     := 0
	Local nPosErpId     := 0
	Local cGroupKey     := ""
	Local aGroupMov     := {}
	Local cCreditUnit   := ""

	For nItem := 1 To Len(aItens)
		aErpId := StrToKArr2(aItens[nItem][ AFTER_ERPID ],"|",.T.)      // [3]-ID de identificação do título
		If !Empty(aErpId)
			If aErpId[ ERPID_TYPE ] $ AllTrim(MVNOTAFIS) + "|" + AllTrim(MV_CRNEG)  // [6]-Tipo ### "NF|NCC"
				cCreditUnit := ""
				nPosMov     := aScan(aGroupMov,{|x| x[1] == aItens[nItem][AFTER_MOVTYPE] })     // [5]-tipo de operação
				cGroupKey   := aErpId[ ERPID_COMPANY ] + "|" + aErpId[ ERPID_BRANCH ] +"|"+ aErpId[ ERPID_PREFIX ] +"|"+ aErpId[ ERPID_INVOICE ]    // [1]-empresa ### [2]-filial ### [3]-prefixo ### [4]-número do título
				nTAmount    := aItens[nItem][AFTER_LOCALAMOUNT]         // [7]-valor bruto da operação
				nTFees      := aItens[nItem][AFTER_FEEAMOUNT]           // [8]-valor do custo da operação
				nTFeesOri   := aItens[nItem][AFTER_FEEAMOUNTORIGIN]     // [13]- estorno da taxa de antecipação
				nDebAmount  := aItens[nItem][AFTER_DEBITAMOUNT]    		// [15]-Valor do Debito a ser pago pelo parceiro a Supplier

				//-------------------------------------------------------------------------------
				// Pega NCC da nota de entrada relacionada com título de origem.
				//-------------------------------------------------------------------------------
				If !Empty( aItens[nItem][AFTER_CREDITUNITS] )           // [10]-Array com a relação de notas de credito e seu valor a ser compensado.
					cCreditUnit := aItens[nItem][AFTER_CREDITUNITS][1][1]
				EndIf

				If nPosMov == 0
					aAdd(aGroupMov,{aItens[nItem][AFTER_MOVTYPE],{{cGroupKey,{aItens[nItem]},nTAmount,nTFees,nTFeesOri,aItens[nItem][ AFTER_ERPID ],cCreditUnit, nDebAmount}}})     // [5]-tipop de operação ### [3]-ID de identificação
				Else
					//-------------------------------------------------------------------------------
					// Caso haja NCC associada a parcela considera na NCC também como chave.
					//-------------------------------------------------------------------------------
					nPosErpId := aScan(aGroupMov[nPosMov][ AFTER_GRP_ITEMS ], {|x| x[ AFTER_ARR_KEY ] == cGroupKey .And. cCreditUnit == x[ AFTER_ARR_CUNIT ] })     // [2]-Array items do movimento ### [1]-Chave ### [7]-nota de crédito
					If nPosErpId == 0
						aAdd(aGroupMov[nPosMov][ AFTER_GRP_ITEMS ], {cGroupKey,{aItens[nItem]},nTAmount,nTFees,nTFeesOri,aItens[nItem][ AFTER_ERPID ],cCreditUnit, nDebAmount})     // [2]-Array items do movimento ### [3]-ID de identificação
					Else
						aAdd(aGroupMov[nPosMov][ AFTER_GRP_ITEMS ][nPosErpId][ AFTER_ARR_DATA ],aItens[nItem])      // [2]-Array items do movimento ### [2]-array com os dados do item
						aGroupMov[nPosMov][ AFTER_GRP_ITEMS ][nPosErpId][ AFTER_ARR_AMOUNT ]  	 += nTAmount        // [2]-Array items do movimento ### [3]-valor bruto da operação
						aGroupMov[nPosMov][ AFTER_GRP_ITEMS ][nPosErpId][ AFTER_ARR_FEE ]     	 += nTFees          // [2]-Array items do movimento ### [4]-Valor do custo da operação
						aGroupMov[nPosMov][ AFTER_GRP_ITEMS ][nPosErpId][ AFTER_ARR_FEEORI ]  	 += nTFeesOri       // [2]-Array items do movimento ### [5]-Estorno da taxa de antecipação
						aGroupMov[nPosMov][ AFTER_GRP_ITEMS ][nPosErpId][ AFTER_ARR_DEBAMOUNT ]  += nDebAmount      // [2]-Array items do movimento ### [8]-debitAmount
					EndIf
				EndIf
			Else
				_nSeqLog++
				RSKAR4MakeLog( aItens[nItem], AFTERSALES, cIDAR4, _nSeqLog, STR0016) //"Somente títulos a receber do tipo NF / NCC é processado no Pos-Faturamento."
			EndIf
		EndIf
	Next

Return aGroupMov

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskProcMov
Funcao que realiza movimentações na NFS Mais Negocios a pagar para
o processo de pos vendas

@param cIDAR4, caracter, Id do lote de processamento
@param nTypeMov, numerico, Tipo de movimento
@param aMovements, array, Movimentos.
@param cHost, caracter, URL da plataforma onde será executado os endpoints
@param nType, number, tipo de ação que será executada
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT TechFin
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskProcMov( cIDAR4 As Character, nTypeMov As Numeric, aMovements As Array, cHost As Character, nType As Numeric, lAutomato As Logical )
	Local aArea 		As Array
	Local aAreaSE1 		As Array
	Local aAreaAR1 		As Array
	Local aAreaSF1 		As Array
	Local aAreaSD1 		As Array
	Local aCustomer 	As Array
	Local aSupplier 	As Array
	Local aErroAuto 	As Array
	Local aERPId 		As Array
	Local aARInvFirst 	As Array
	Local aARInv 		As Array
	Local aMakeLog 		As Array
	Local oModel 		As Object
	Local oMdlAR2 		As Object
	Local nFeeAmount 	As Numeric
	Local nDiscAmount 	As Numeric
	Local nMov 			As Numeric
	Local nARInv 		As Numeric
	Local nMakeLog 		As Numeric
	Local nLenPrefix 	As Numeric
	Local nLenNum 		As Numeric
	Local nLenInst 		As Numeric
	Local nLenType 		As Numeric
	Local nTAmount 		As Numeric
	Local nTFees 		As Numeric
	Local nTFeesOri 	As Numeric
	Local nLocalAmount 	As Numeric
	Local nFeeAmtOri 	As Numeric
	Local cTypeMov 		As Character
	Local cErrorMsg 	As Character
	Local cPrefix 		As Character
	Local cMovPrefix 	As Character
	Local cInvoice 		As Character
	Local cSupID 		As Character
	Local cSupBranch 	As Character
	Local cInvoice_Type As Character
	Local cInstallment 	As Character
	Local cFilNFDev 	As Character
	Local cNumNFDev 	As Character
	Local cSerNFDev 	As Character
	Local cHist 		As Character
	Local cTitIdOri 	As Character
	Local cPlatfId 		As Character
	Local cBranchSE1 	As Character
	Local cFilSD1 		As Character
	Local cFilAR1 		As Character
	Local cFilSE2 		As Character
	Local cFilSF2 		As Character
	Local cIdNatExp 	As Character
	Local cNumSE2 		As Character
	Local lAddLine 		As Logical
	Local lItemError 	As Logical
	Local dFeeDate 		As Date
	Local aErpIdNCC 	As Array
	Local cFilNCC 		As Character
	Local cPrNCC 		As Character
	Local cInvNCC 		As Character
	Local cInstNCC 		As Character
	Local cInvtNCC 		As Character
	Local cReqCode 		As Character

	aArea         := GetArea()
	aAreaSE1      := SE1->( GetArea() )
	aAreaAR1      := AR1->( GetArea() )
	aAreaSF1      := SF1->( GetArea() )
	aAreaSD1      := SD1->( GetArea() )
	aCustomer     := {}
	aSupplier     := {}
	aErroAuto     := {}
	aERPId        := {}
	aARInvFirst   := {}
	aARInv        := {}
	aMakeLog      := {}
	oModel        := Nil
	oMdlAR2       := Nil
	nFeeAmount    := 0
	nDiscAmount   := 0
	nMov          := 0
	nARInv        := 0
	nMakeLog      := 0
	nLenPrefix    := TamSX3("E1_PREFIXO")[1]
	nLenNum       := TamSx3("E1_NUM")[1]
	nLenInst      := TamSx3("E1_PARCELA")[1]
	nLenType      := TamSx3("E1_TIPO")[1]
	nTAmount      := 0
	nTFees        := 0
	nTFeesOri     := 0
	nLocalAmount  := 0
	nFeeAmtOri    := 0
	cTypeMov      := ""
	cErrorMsg     := ""
	cPrefix       := ""
	cMovPrefix    := ""
	cInvoice      := ""
	cSupID        := ""
	cSupBranch    := ""
	cInvoice_Type := ""
	cInstallment  := ""
	cFilNFDev     := ""
	cNumNFDev     := ""
	cSerNFDev     := ""
	cHist         := ""
	cTitIdOri     := ""
	cPlatfId      := ""
	cBranchSE1    := ""
	cFilSD1       := xFilial("SD1")
	cFilAR1       := xFilial("AR1")
	cFilSE2       := xFilial("SE2")
	cFilSF2       := xFilial("SF2")
	cIdNatExp	  := RskSeekNature( EXPENSE_NATURE )
	cNumSE2       := ""
	lAddLine      := .F.
	lItemError    := .F.
	dFeeDate      := cTod("//")
	aErpIdNCC     := {}
	cFilNCC       := ""
	cPrNCC        := ""
	cInvNCC       := ""
	cInstNCC      := ""
	cInvtNCC      := ""
	cReqCode      := ""

	Do Case
	Case nTypeMov == PV_PRO     // 11=Prorrogação de vencimentos
		cMovPrefix := "PRO"
		cTypeMov := AR2_MOV_EXTENSION   // 4=Prorrogação
	Case nTypeMov == PV_BON     // 12=Bonificação
		cMovPrefix := "BON"
		cTypeMov := AR2_MOV_BONUS   // 3=Bonificação
	Case nTypeMov == PV_DEV     // 13=Devolução
		cMovPrefix := "DEV"
		cTypeMov := AR2_MOV_DEVOLUTION  // 5=Devolução
	EndCase

	SE1->( DBSetOrder(1) )      //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	AR1->( DBSetOrder(2) )      //AR1_FILIAL+AR1_FILNF+AR1_DOC+AR1_SERIE+AR1_CLIENT+AR1_LOJA
	SF1->( DBSetOrder(1) )      //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	SD1->( DBSetOrder(19) )     //D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA

	aCustomer := StrToKArr2( _cRSKCustomer, "|", .T. )

	If Len(aCustomer) == 2
		aSupplier := RskGetSupplier(aCustomer[1], aCustomer[2])
	EndIf

	If !Empty( aSupplier )
		cSupID     := aSupplier[1]
		cSupBranch := aSupplier[2]

		For nMov := 1 To Len(aMovements)
			aMakeLog    := {}
			aARInvFirst := StrToKArr2( aMovements[nMov][ AFTER_ARR_ERPID ], "|", .T.)   // [6]-ERPID
			aARInv      := aMovements[nMov][ AFTER_ARR_DATA ]       // [2]-array com os dados do item
			nTAmount    := aMovements[nMov][ AFTER_ARR_AMOUNT ]     // [3]-valor bruto da operação
			nTFees      := aMovements[nMov][ AFTER_ARR_FEE ]        // [4]-Valor do custo da operação
			nTFeesOri   := aMovements[nMov][ AFTER_ARR_FEEORI ]     // [5]-Estorno da taxa de antecipação
			lItemError  := .F.
			cErrorMsg   := ""
			oModel		:= Nil

			BEGIN TRANSACTION
				cBranchSE1      := Padr(aARInvFirst[ERPID_BRANCH]    ,FwSizeFilial())   // [2]-filial
				cPrefix         := Padr(aARInvFirst[ERPID_PREFIX]    ,nLenPrefix)       // [3]-prefixo
				cInvoice        := Padr(aARInvFirst[ERPID_INVOICE]   ,nLenNum)          // [4]-número do título
				cInstallment    := Padr(aARInvFirst[ERPID_PARCEL]    ,nLenInst)         // [5]-parcela
				cInvoice_Type   := Padr(aARInvFirst[ERPID_TYPE]      ,nLenType)         // [6]-tipo

				//-------------------------------------------------------------------------------
				// Posiciona no título para para encontrar nota mais negocios pela serie.
				// (***Prefixo do título pode ser diferente da serie da nota)
				//-------------------------------------------------------------------------------
				If SE1->(MsSeek( cBranchSE1 + cPrefix + cInvoice + cInstallment + cInvoice_Type ))
					If AR1->(MsSeek( cFilAR1 + cFilSF2 + SE1->E1_NUM + SE1->E1_SERIE ))
						oModel := FWLoadModel("RSKA020")
						oModel:SetOperation(MODEL_OPERATION_UPDATE)
						oModel:Activate()

						If oModel:IsActive()
							For nARInv := 1 To Len(aARInv)
								If Empty( cErrorMsg )
									aERPId          := StrToKArr2( aARInv[nARInv][AFTER_ERPID], "|", .T.)
									cBranchSE1      := Padr(aERPId[ERPID_BRANCH]  ,FwSizeFilial())      // [2]-filial
									cPrefix         := Padr(aERPId[ERPID_PREFIX]  ,nLenPrefix)          // [3]-prefixo
									cInvoice        := Padr(aERPId[ERPID_INVOICE] ,nLenNum)             // [4]-número do título
									cInstallment    := Padr(aERPId[ERPID_PARCEL]  ,nLenInst)            // [5]-parcela
									cInvoice_Type   := Padr(aERPId[ERPID_TYPE]    ,nLenType)            // [6]-tipo

									cPlatfId        := aARInv[nARInv][AFTER_PLATFORMID]                 // [2]-PK da tataforma
									nLocalAmount    := aARInv[nARInv][AFTER_LOCALAMOUNT]                // [7]-Valor bruto da operação
									If aARInv[nARInv][AFTER_MOVTYPE] == PV_DEV .Or. aARInv[nARInv][AFTER_MOVTYPE] == PV_BON  // 13=Devolução / 12=Bonificação
										nDiscAmount := aARInv[nARInv][AFTER_DEBITAMOUNT] + aARInv[nARInv][AFTER_FEEAMOUNTORIGIN]                // [15]-Valor do desconto a ser aplicado + [13]- estorno da taxa de antecipação
										cReqCode    := aARInv[nARInv][AFTER_REQUESTCODE]                // [18]-Request Code (Código da Solicitação)
									Else
										nDiscAmount := aARInv[nARInv][AFTER_DISCOUNTAMOUNT]             // [12]-Valor do desconto a ser aplicado
									EndIf
									dFeeDate        := sTod(aARInv[nARInv][AFTER_DEBITDATE])            // [9]-data do débito do parceiro
									nFeeAmount      := aARInv[nARInv][AFTER_FEEAMOUNT]                  // [8]-Valor do custo da operação
									nFeeAmtOri      := aARInv[nARInv][AFTER_FEEAMOUNTORIGIN]            // [13]- estorno da taxa de antecipação

									If SE1->(MsSeek( cBranchSE1 + cPrefix + cInvoice + cInstallment + cInvoice_Type ))
										oMdlAR2 := oModel:GetModel("AR2DETAIL")

										If !oMdlAR2:SeekLine({{"AR2_IDTITP", cPlatfId }})
											cNumSE2         := ProxTitulo( "SE2", cMovPrefix)
											cHist           := "Ref. NFS: " + AllTrim(AR1->AR1_DOC) + " / " + AllTrim(AR1->AR1_SERIE) + IIF(!Empty(cInstallment)," Parc.: " + AllTrim(cInstallment),"")
											cTitIdOri       := AllTrim(SE1->E1_FILIAL) + "|" + AllTrim(SE1->E1_PREFIXO) + "|" + AllTrim(SE1->E1_NUM) + "|" + AllTrim(SE1->E1_PARCELA) + "|" + AllTrim(SE1->E1_TIPO)

											//-------------------------------------------------------------------------------
											// Para devolucao associa NFE na movimentação Mais Negócios.
											//-------------------------------------------------------------------------------
											If aARInv[nARInv][AFTER_MOVTYPE] == PV_DEV        // 13=Devolução
												If nARInv == 1
													If SD1->( MsSeek(cFilSD1 + AR1->AR1_DOC + AR1->AR1_SERIE + AR1->AR1_CLIENT + AR1->AR1_LOJA) )
														cFilNFDev := SD1->D1_FILIAL
														cNumNFDev := SD1->D1_DOC
														cSerNFDev := SD1->D1_SERIE

														aErpIdNCC	:= StrToKArr2(aMovements[nMov][ AFTER_ARR_CUNIT ],"|",.T.)  // [7]-nota de credito
														cFilNCC		:= Padr(aErpIdNCC[ERPID_BRANCH]    ,FwSizeFilial())         // [2]-filial
														cPrNCC		:= Padr(aErpIdNCC[ERPID_PREFIX]    ,nLenPrefix)             // [3]-prefixo
														cInvNCC		:= Padr(aErpIdNCC[ERPID_INVOICE]   ,nLenNum)                // [4]-número do título
														cInstNCC	:= Padr(aErpIdNCC[ERPID_PARCEL]    ,nLenInst)               // [5]-parcela
														cInvtNCC	:= Padr(aErpIdNCC[ERPID_TYPE]      ,nLenType)               // [6]-tipo

														cErrorMsg := RskNCCDown(oMdlAR2,cFilNCC,cPrNCC,cInvNCC,cInstNCC,cInvtNCC, nTAmount)
													EndIf
												EndIf

												//-------------------------------------------------------------------------------
												// Gera taxa com valor total da devolução para Supplier. (Por parcela)
												//-------------------------------------------------------------------------------
												If Empty(cErrorMsg)
													cErrorMsg   := RskNewTax(cMovPrefix, cNumSE2, cInstallment, "DP", cSupID, cSupBranch, nDiscAmount, dFeeDate, cHist, cIdNatExp )
													If Empty(cErrorMsg)
														lAddLine    := RskAddAR2(oMdlAR2, cTypeMov, cFilSE2, cMovPrefix, cNumSE2, cInstallment, "DP", , ,;
															nDiscAmount, dFeeDate, cTitIdOri, cPlatfId, cFilNFDev, cNumNFDev, cSerNFDev, cSupID, cSupBranch, cReqCode)
														If !lAddLine
															cErrorMsg := oModel:GetErrorMessage()[6]
														EndIf
													EndIf
												EndIf

											EndIf

											//-------------------------------------------------------------------------------
											// Geracao da taxa da operacao. (taxa do serviço mais negocios)
											//-------------------------------------------------------------------------------
											If Empty(cErrorMsg) .And. nFeeAmount != 0
												cErrorMsg   := RskNewTax(cMovPrefix, cNumSE2, cInstallment, "MN+", cSupID, cSupBranch, nFeeAmount, dFeeDate, cHist, cIdNatExp)
												If Empty(cErrorMsg)
													lAddLine := RskAddAR2(oMdlAR2, cTypeMov, cFilSE2, cMovPrefix, cNumSE2, cInstallment, "MN+", , ,;
														nFeeAmount, dFeeDate, cTitIdOri, cPlatfId, cFilNFDev, cNumNFDev, cSerNFDev, cSupID, cSupBranch, cReqCode)
													If !lAddLine
														cErrorMsg := oModel:GetErrorMessage()[6]
													EndIf
												EndIf
											EndIf

											//-------------------------------------------------------------------------------
											// Geracao da taxa de estorno da antecipação (taxa de desconto mais negocios)
											//-------------------------------------------------------------------------------
											If  aARInv[nARInv][AFTER_MOVTYPE] == PV_DEV .And. Empty(cErrorMsg) .And. nFeeAmtOri != 0      // 13=Devolução
												cErrorMsg   := RskNewTax(cMovPrefix, cNumSE2, cInstallment, "MN-", cSupID, cSupBranch, nFeeAmtOri, dFeeDate, cHist, cIdNatExp)
												If Empty(cErrorMsg)
													lAddLine := RskAddAR2(oMdlAR2, cTypeMov, cFilSE2, cMovPrefix, cNumSE2, cInstallment, "MN-", , ,;
														nFeeAmtOri, dFeeDate, cTitIdOri, cPlatfId, cFilNFDev, cNumNFDev, cSerNFDev, cSupID, cSupBranch, cReqCode)
													If !lAddLine
														cErrorMsg := oModel:GetErrorMessage()[6]
													EndIf
												EndIf
											EndIf

											//-------------------------------------------------------------------------------
											// No caso da bonificacao gerar como taxa o valor bonificado.
											//-------------------------------------------------------------------------------
											If nTypeMov == PV_BON .And. Empty(cErrorMsg) .And. nDiscAmount != 0       // 12=Bonificação
												cErrorMsg   := RskNewTax(cMovPrefix, cNumSE2, cInstallment, "MN+", cSupID, cSupBranch, nDiscAmount, dFeeDate, cHist, cIdNatExp)
												If Empty(cErrorMsg)
													lAddLine := RskAddAR2(oMdlAR2, cTypeMov, cFilSE2, cMovPrefix, cNumSE2, cInstallment, "MN+", , ,;
														nDiscAmount, dFeeDate, cTitIdOri, cPlatfId, , , , cSupID, cSupBranch, cReqCode)
													If !lAddLine
														cErrorMsg := oModel:GetErrorMessage()[6]
													EndIf
												EndIf
											EndIf
										EndIf
									Else
										cErrorMsg := STR0001 //"Título a receber não foi encontrado na movimentação NFS Mais Negócios."
									EndIf
								EndIf

								//-------------------------------------------------------------------------------
								// Disarma a transação das parcelas para gerar o log fora da transação em caso de erro.
								//-------------------------------------------------------------------------------
								If !Empty(cErrorMsg) .And. !lItemError
									DisarmTransaction()
								EndIf

								_nSeqLog++
								aAdd(aMakeLog,{aARInv[nARInv], AFTERSALES, cIDAR4, _nSeqLog, cErrorMsg})

								//-------------------------------------------------------------------------------
								// Caso haja falha numa parcela do título não processar as demais.
								// ( Gerar log generico para demais as parcelas. )
								//-------------------------------------------------------------------------------
								If !Empty(cErrorMsg)
									lItemError  := .T.
									cErrorMsg := STR0007 //"Não foi possível processar todas as parcelas deste título."
								EndIf
							Next
						EndIf
					EndIf
				EndIf

			END TRANSACTION

			//-------------------------------------------------------------------------------
			// Gera o log fora da transação.
			//-------------------------------------------------------------------------------
			For nMakeLog := 1 To Len(aMakeLog)
				RSKAR4MakeLog( aMakeLog[nMakeLog][1], aMakeLog[nMakeLog][2], aMakeLog[nMakeLog][3], aMakeLog[nMakeLog][4], aMakeLog[nMakeLog][5] )
			Next
			If oModel <> Nil .And. oModel:VldData() .And. !lItemError
				oModel:CommitData()
				RSKConfPlat( cHost, nType, aMovements[nMov][ AFTER_ARR_DATA ], lAutomato )
			EndIf
		Next
	EndIf

	RestArea( aArea )
	RestArea( aAreaSE1 )
	RestArea( aAreaAR1 )
	RestArea( aAreaSF1 )
	RestArea( aAreaSD1 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aAreaAR1 )
	FWFreeArray( aAreaSF1 )
	FWFreeArray( aAreaSD1 )
	FWFreeArray( aCustomer )
	FWFreeArray( aERPId )
	FWFreeArray( aErroAuto )
	FwFreeArray( aARInvFirst )
	FwFreeArray( aErpIdNCC )
	FreeObj( oModel )
	FreeObj( oMdlAR2 )
Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskNCCDown
Funcao que realiza baixa da NCC 

@param oMdlAR2, objeto, Modelo da tabela AR2
@param cFilTit, caracter, Filial do título
@param cPrefix, caracter, Prefixo do título
@param cNumTit, caracter, Número do título
@param cParTit, caracter, Parcela do título
@param cTpTit, caracter, Tipo do título
@param nAmount, numerico, Valor a ser baixado

@return cRet, caracter, Messagem de retorno para cada evento.

@author Squad NT TechFin
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskNCCDown( oMdlAR2 As Object, cFilTit As Character, cPrfTit As Character, cNumTit As Character, cParTit As Character, cTpTit As Character, nAmount As Numeric ) As Character
	Local aArea     As Array
	Local aAreaSE1  As Array
	Local aAutoSE1  As Array
	Local aErroAuto As Array
	Local cStatus   As Character
	Local nBalance  As Numeric
	Local cRet      As Character
	Local lRet      As Logical
	Local nLog      As Numeric
	Local aParam    As Array

	Private lMsErroAuto		As Logical
	Private lAutoErrNoFile	As Logical
	Private lMsHelpAuto   	As Logical

	aArea     := GetArea()
	aAreaSE1  := SE1->( GetArea() )
	aAutoSE1  := {}
	aErroAuto := {}
	cStatus   := AR2_MOV_PARTIAL_NCC      // 8=NCC Baixa Parcial
	nBalance  := 0
	cRet      := ""
	lRet      := .T.
	nLog      := 0
	aParam    := {}

	lMsErroAuto		:= .F.
	lAutoErrNoFile	:= .T.
	lMsHelpAuto   	:= .T.

	SE1->( DBSetOrder(1) )  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SA6->( DBSetOrder(1) )  //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

	If SE1->(MsSeek( cFilTit + cPrfTit + cNumTit + cParTit + cTpTit ))
		nBalance := SE1->E1_SALDO
		aAutoSE1 :={    {"E1_PREFIXO"	,SE1->E1_PREFIXO,Nil	},;
			{"E1_NUM"		,SE1->E1_NUM                ,Nil	},;
			{"E1_TIPO"		,SE1->E1_TIPO               ,Nil	},;
			{"E1_PARCELA"	,SE1->E1_PARCELA            ,Nil	},;
			{"E1_CLIENTE"	,SE1->E1_CLIENTE            ,Nil	},;
			{"E1_LOJA"		,SE1->E1_LOJA		        ,Nil	},;
			{"E1_SITUACA"	,"0"	        	        ,Nil	},;
			{"AUTMOTBX"    	,"OFF"                  	,Nil    },;
			{"AUTDTBAIXA"  	,dDataBase                  ,Nil    },;
			{"AUTDTCREDITO"	,dDataBase                  ,Nil    },;
			{"AUTJUROS"    	,0                          ,Nil,.T.},;
			{"AUTVALREC"   	,nAmount                    ,Nil    },;
			{"AUTHIST"     	,STR0006 ,Nil    }} //"Devolução Mais Negócios"

		aParam := {'SE1', 'BAIXANCC' , aAutoSE1}

		IF EXISTBLOCK("RskFinGrv")
			aAutoSE1 := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
		ENDIF

		MSExecAuto({|x,y| FINA070(x,y)},aAutoSE1,3)

		If !lMsErroAuto
			If nAmount >= nBalance
				cStatus := AR2_MOV_TOTAL_NCC    // 9=NCC Baixa Total
			EndIf
			lRet := RskAddAR2(oMdlAR2, cStatus, SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,SE1->E1_CLIENTE,;
				SE1->E1_LOJA, nAmount, SE1->E1_VENCTO, , , SE1->E1_FILIAL, SE1->E1_NUM, SE1->E1_SERIE )
			If !lRet
				cRet := oMdlAR2:GetModel():GetErrorMessage()[6]
			EndIf
		Else
			aErroAuto := GetAutoGRLog()
			For nLog := 1 To Len(aErroAuto)
				cRet += aErroAuto[nLog]
			Next
		EndIf
	EndIf

	RestArea( aArea )
	RestArea( aAreaSE1 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aAutoSE1 )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskNewTax
Funcao que realiza movimentações na NFS Mais Negocios a pagar para
o processo de pos vendas

@param cPrefix      , caracter, Prefixo do título
@param cNum         , caracter, Número do título
@param cInstallment , caracter, Parcela do título
@param cType        , caracter, Tipo do título
@param cSupID      , caracter, Codigo do fornecedor
@param cSupBranch  , caracter, Loja do fornecedor
@param nFeeAmount   , caracter, Valor da Taxa
@param dDueDate     , caracter, Vencimento da taxa
@param cHist        , caracter, Historico do movimento
@param cNatureza    , caracter, Código da natureza

@return cRetMessage , caracter, Messagem de retorno para cada evento.
@author Squad NT TechFin
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------

Static Function RskNewTax(cPrefix, cNum, cInstallment, cType, cSupID, cSupBranch, nFeeAmount, dDueDate, cHist, cNatureza)
	Local aArea 	        := GetArea()
	Local aAutoSE2      	:= {}
	Local aErroAuto 	    := {}
	Local cRet 		        := ""
	Local nLog 		        := 0
	Local dIssue	        := CToD("//")
	Local aParam            := {}
	Local lLibTit   		:= SuperGetMV('MV_CTLIPAG', , .F.)
	Local dDataLib   		:= CToD("//")

	Private lMsErroAuto		:= .F.
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.

	Default cHist           := ""

	dIssue   := IIf(dDatabase > dDueDate, dDueDate, dDatabase)
	dDataLib := IIf(lLibTit, dDatabase, dDataLib)
	aAutoSE2 := {{ "E2_PREFIXO"  , cPrefix         		    , Nil },;
				 { "E2_NUM"      , cNum        				, Nil },;
				 { "E2_PARCELA"  , cInstallment             , Nil },;
				 { "E2_TIPO"     , cType           			, Nil },;
				 { "E2_NATUREZ"  , cNatureza	            , Nil },;
				 { "E2_FORNECE"  , cSupID                   , Nil },;
				 { "E2_LOJA"     , cSupBranch               , Nil },;
				 { "E2_EMISSAO"  , dIssue					, Nil },;
				 { "E2_VENCTO"   , dDueDate					, Nil },;
				 { "E2_VENCREA"  , dDueDate					, Nil },;
				 { "E2_HIST"     , cHist                    , Nil },;
				 { "E2_VALOR"    , nFeeAmount             	, Nil },;
				 { "E2_DATALIB"  , dDataLib            		, NIL }}

	aParam := {'SE2', 'INCTXPOSV' , aAutoSE2}

	IF EXISTBLOCK("RskFinGrv")
		aAutoSE2 := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
	ENDIF

	MsExecAuto( { |x,y| FINA050(x,y)} , aAutoSE2, 3)

	If lMsErroAuto
		aErroAuto := GetAutoGRLog()
		For nLog := 1 To Len(aErroAuto)
			cRet += aErroAuto[nLog]
		Next
	EndIf

	RestArea(aArea)
	FWFreeArray(aArea)
	FWFreeArray(aAutoSE2)
	FWFreeArray(aErroAuto)
	FWFreeArray(aParam)
Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskNCCRelease
Funcao que faz a liberação da NCC.

@param cIDAR4, caracter, Id do lote de processamento
@param aMovements, array, Movimentos.
@param cHost, caracter, URL da plataforma onde será executado os endpoints
@param nType, number, tipo de ação que será executada
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT TechFin
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskNCCRelease( cIDAR4 As Character, aMovements As Array, cHost As Character, nType As Numeric, lAutomato As Logical )
	Local aArea         As Array
	Local aAreaSE1      As Array
	Local aAreaAR1      As Array
	Local aCustomer     As Array
	Local aErroAuto     As Array
	Local aNCC          As Array
	Local aAutoSE1      As Array
	Local aERPId        As Array
	Local oModel        As Object
	Local oMdlAR2       As Object
	Local oQryNCC       As Object
	Local cBranchSE1    As Character
	Local cTempNCC      As Character
	Local cPrefix       As Character
	Local cInvoice      As Character
	Local cError        As Character
	Local cPlatfId      As Character
	Local cErrorMsg     As Character
	Local cInstallment  As Character
	Local cInvoice_Type As Character
	Local lAddLine      As Logical
	Local lRet          As Logical
	Local nX            As Numeric
	Local nMov          As Numeric
	Local nLenPrefix    As Numeric
	Local nLenNum       As Numeric
	Local nLenInst      As Numeric
	Local nLenType      As Numeric
	Local aParam        As Array

	Private lMsErroAuto		:= .F.
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.

	aArea         := GetArea()
	aAreaSE1      := SE1->( GetArea() )
	aAreaAR1      := AR1->( GetArea() )
	aCustomer     := {}
	aErroAuto     := {}
	aNCC          := {}
	aAutoSE1      := {}
	aERPId        := {}
	oModel        := Nil
	oMdlAR2       := Nil
	oQryNCC       := Nil
	cBranchSE1    := ""
	cTempNCC      := GetNextAlias()
	cPrefix       := ""
	cInvoice      := ""
	cError        := ""
	cPlatfId      := ""
	cErrorMsg     := ""
	cInstallment  := ""
	cInvoice_Type := ""
	lAddLine      := .F.
	lRet          := .T.
	nX            := 0
	nMov          := 0
	nLenPrefix    := TamSX3("E1_PREFIXO")[1]
	nLenNum       := TamSx3("E1_NUM")[1]
	nLenInst      := TamSx3("E1_PARCELA")[1]
	nLenType      := TamSx3("E1_TIPO")[1]
	aParam        := {}

	For nMov := 1 To Len(aMovements)
		BEGIN TRANSACTION
			cErrorMsg     := ""
			aNCC          := AClone(aMovements[nMov][2][1])
			aERPId        := StrToKArr2(aNCC[AFTER_ERPID], "|", .T.)
			cBranchSE1    := Padr(aERPId[ERPID_BRANCH]  ,FwSizeFilial())      // [2]-filial
			cPrefix       := Padr(aERPId[ERPID_PREFIX]  ,nLenPrefix)          // [3]-prefixo
			cInvoice      := Padr(aERPId[ERPID_INVOICE] ,nLenNum)             // [4]-número do título
			cInstallment  := Padr(aERPId[ERPID_PARCEL]  ,nLenInst)            // [5]-parcela
			cInvoice_Type := Padr(aERPId[ERPID_TYPE]    ,nLenType)            // [6]-tipo
			cPlatfId      := aNCC[AFTER_PLATFORMID]                           // [2]-PK da tataforma
			lRet          := .T.

			oQryNCC  := GetQuery( "QNCCRelease" )
			oQryNCC:SetString(1,cBranchSE1)
			oQryNCC:SetString(2,cPrefix)
			oQryNCC:SetString(3,cInstallment)
			oQryNCC:SetString(4,cInvoice)
			oQryNCC:SetString(5,cInvoice_Type)

			MPSysOpenQuery( oQryNCC:GetFixQuery(), cTempNCC )

			If (cTempNCC)->(!Eof())
				SE1->(DBGoTo((cTempNCC)->E1_RECNO))
				AR1->(DBGoTo((cTempNCC)->AR1_RECNO))

				If SE1->E1_SITUACA == _cRSKSNcc
					If SE1->E1_SALDO == aNCC[AFTER_LOCALAMOUNT]     // [7]-Valor bruto da operação

						aAutoSE1 :={    {"E1_PREFIXO"	,SE1->E1_PREFIXO    ,Nil	},;
							{"E1_NUM"		,SE1->E1_NUM        ,Nil	},;
							{"E1_TIPO"		,SE1->E1_TIPO       ,Nil	},;
							{"E1_PARCELA"	,SE1->E1_PARCELA	,Nil	},;
							{"E1_CLIENTE"	,SE1->E1_CLIENTE	,Nil	},;
							{"E1_LOJA"		,SE1->E1_LOJA	    ,Nil	},;
							{"E1_SITUACA"   ,"0"                ,Nil    }}

						aParam := {'SE1', 'LIBNCC' , aAutoSE1}

						IF EXISTBLOCK("RskFinGrv")
							aAutoSE1 := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
						ENDIF

						MsExecAuto( { |x,y| FINA040( x, y ) } , aAutoSE1, 4 )

						If lMsErroAuto
							lRet        := .F.
							aErroAuto   := GetAutoGRLog()
							For nX := 1 To Len( aErroAuto )
								cError += aErroAuto[ nX ]
							Next
							cErrorMsg := cError
						EndIf

						If lRet
							oModel := FWLoadModel("RSKA020")
							oModel:SetOperation(MODEL_OPERATION_UPDATE)
							oModel:Activate()

							If oModel:IsActive()
								oMdlAR2 := oModel:GetModel("AR2DETAIL")

								If !oMdlAR2:SeekLine({{"AR2_IDTITP", cPlatfId }})
									lAddLine := RskAddAR2(oMdlAR2, "7", SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,SE1->E1_CLIENTE,;
										SE1->E1_LOJA, aNCC[AFTER_LOCALAMOUNT], SE1->E1_VENCTO, , cPlatfId, SE1->E1_FILIAL, SE1->E1_NUM, SE1->E1_SERIE )     // [7]-Valor bruto da operação

									If lAddLine .And. oModel:VldData()
										oModel:CommitData()
									Else
										cErrorMsg := oModel:GetErrorMessage()[6]
										lRet        := .F.
									EndIf
								EndIf
							Else
								cErrorMsg := oModel:GetErrorMessage()[6]
								lRet        := .F.
							EndIf
						EndIf
					Else
						cErrorMsg := I18N( STR0002, { AllTrim( cPrefix ), AllTrim( cInvoice ) } )    //"Valor do título diferente com o valor salvo no financeiro Prefixo: #1 / Número: #2"
					EndIf
				Else
					cErrorMsg := I18N( STR0003, { _cRSKSNcc, AllTrim( cPrefix ), AllTrim( cInvoice ) } )     //"Título não está na carteira: #1  Prefixo: #2 / Número: #3"
				EndIf

				If !lRet
					DisarmTransaction()
				EndIf
			Else
				cErrorMsg := STR0001 //"Título a receber não foi encontrado na movimentação NFS Mais Negócios."
			EndIf

		END TRANSACTION
		_nSeqLog++
		RSKAR4MakeLog(aNCC, AFTERSALES, cIDAR4, _nSeqLog, cErrorMsg)
		If lRet
			RSKConfPlat( cHost, nType, aMovements[nMov][ AFTER_ARR_DATA ], lAutomato )
		EndIf
	Next

	RestArea( aArea )
	RestArea( aAreaSE1 )
	RestArea( aAreaAR1 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aAreaAR1 )
	FWFreeArray( aCustomer )
	FWFreeArray( aERPId )
	FWFreeArray( aErroAuto )
	FWFreeArray( aAutoSE1 )
	FWFreeArray( aParam )
	FWFreeArray( aNCC )
	FreeObj( oModel )
	FreeObj( oMdlAR2 )
	FreeObj( oQryNCC )
Return Nil

//------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKBlockNCC
Função para atualizar o movimento de bloqueio de NCC na AR2

@param cSE1Key, caracter, chave de pesquisa do título a receber

@author  Marcia Junko
@since   29/10/2020
/*/
//------------------------------------------------------------------------------------------------------------
Function RSKBlockNCC( cSE1Key As Character )
	Local aArea     As Array
	Local aAreaSE1  As Array
	Local aAreaSF2  As Array
	Local aAreaAR1  As Array
	Local lAddLine  As Logical
	Local oModel    As Object
	Local oMdlAR2   As Object
	Local oQuerySD1 As Object
	Local cQyrSD1   As Character
	Local cTmpSD1   As Character
	Local cCartDev  As Character

	aArea     := GetArea()
	aAreaSE1  := SE1->( GetArea() )
	aAreaSF2  := SF2->( GetArea() )
	aAreaAR1  := AR1->( GetArea() )
	lAddLine  := .F.
	oModel    := Nil
	oMdlAR2   := Nil
	oQuerySD1 := Nil
	cQyrSD1   := ""
	cTmpSD1   := GetNextAlias()
	cCartDev  := SuperGetMv( "MV_RSKSNCC", .F., "" )

	SE1->( DBSetOrder(1) )  //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	SF2->( DBSetOrder(1) )  //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	AR1->( DBSetOrder(2) )  //AR1_FILIAL+AR1_FILNF+AR1_DOC+AR1_SERIE+AR1_CLIENT+AR1_LOJA

	If SE1->( MSSeek( cSE1Key ) )
		cCartDev := PadR( cCartDev, TamSX3( "E1_SITUACA" )[1] )

		//-------------------------------------------------------------------------------
		// Gera lancamento na NFS Mais Negócios somente titulo bloqueado na Carteira de Devolução .
		//-------------------------------------------------------------------------------
		If SE1->E1_SITUACA == cCartDev
			cQyrSD1 := " SELECT DISTINCT D1_FILIAL, D1_NFORI, D1_SERIORI, D1_FORNECE, D1_LOJA " + ;
				" FROM " + RetSqlName( "SD1" ) + " SD1 " + ;
				" WHERE D1_FILIAL = ? " + ;
				" AND D1_DOC = ? " + ;
				" AND D1_SERIE = ? " + ;
				" AND D1_FORNECE = ? " + ;
				" AND D1_LOJA = ? " + ;
				" AND D1_NFORI <> ' ' " + ;
				" AND D1_SERIORI <> ' ' " + ;
				" AND SD1.D_E_L_E_T_ = ' ' "

			cQyrSD1   := ChangeQuery( cQyrSD1 )
			oQuerySD1 := FWPreparedStatement():New(cQyrSD1)
			oQuerySD1:SetString( 1, xFilial( 'SD1' ) )
			oQuerySD1:SetString( 2, SE1->E1_NUM )
			oQuerySD1:SetString( 3, SE1->E1_SERIE )
			oQuerySD1:SetString( 4, SE1->E1_CLIENTE )
			oQuerySD1:SetString( 5, SE1->E1_LOJA )
			cQyrSD1  := oQuerySD1:GetFixQuery()

			MPSysOpenQuery( cQyrSD1, cTmpSD1 )

			oModel := FWLoadModel( "RSKA020" )

			While ( cTmpSD1 )->( !Eof() )
				If SF2->( DBSeek( ( cTmpSD1 )->D1_FILIAL + ( cTmpSD1 )->D1_NFORI + ( cTmpSD1 )->D1_SERIORI + ( cTmpSD1 )->D1_FORNECE + ( cTmpSD1 )->D1_LOJA ) )
					If AR1->( DBSeek( xFilial( "AR1" ) + SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
						If AR1->AR1_STATUS == AR1_STT_APPROVED .Or. AR1->AR1_STATUS == AR1_STT_ERRORCANCERP  // 2=Aprovado ### 9=Erro no Cancelamento ERP
							oModel:SetOperation( MODEL_OPERATION_UPDATE )
							oModel:Activate()

							If oModel:IsActive()
								oMdlAR2 := oModel:GetModel( "AR2DETAIL" )

								lAddLine := RskAddAR2( oMdlAR2, AR2_MOV_BLOCK_NCC, SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE,;
									SE1->E1_LOJA , SE1->E1_VALOR, SE1->E1_VENCTO, , , SD1->D1_FILIAL, SE1->E1_NUM, SE1->E1_SERIE  )

								If lAddLine .And. oModel:VldData()
									oModel:CommitData()
								EndIf
							EndIf
							oModel:DeActivate()
						EndIf
					EndIf
				EndIf
				( cTmpSD1 )->( DBSkip() )
			EndDo
			( cTmpSD1 )->( DBCloseArea() )

			oModel:Destroy()
		EndIf
	EndIf

	RestArea( aArea )
	RestArea( aAreaSE1 )
	RestArea( aAreaSF2 )
	RestArea( aAreaAR1 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aAreaSF2 )
	FWFreeArray( aAreaAR1 )
	FreeObj( oModel )
	FreeObj( oMdlAR2 )
	FreeObj( oQuerySD1 )
Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskAddAR2
Funcao que adiciona linha no grid a Movimentação Mais Negócios.

@param oMdlAR2      , objeto    , Grido da Movimentação Mais Negócios
@param cTypeMov     , caracter  , Tipo de movimento
@param cFilInv      , caracter  , Filial do título
@param cNumInv      , caracter  , Número do título
@param cInstallment , caracter  , Parcela do título
@param cType        , caracter  , Tipo do título
@param cCustomer    , caracter  , Codigo do cliente.
@param cUnit        , caracter  , Loja do cliente.
@param nAmount      , caracter  , Valor do título
@param dDueDate     , caracter  , Vencimento do título
@param cPlatfId     , caracter  , Guid de integração da plataforma Antecipa
@param cFilNFDev    , caracter  , Filial de devolução
@param cNumNFDev    , caracter  , Número da NF de devolução
@param cSerNFDev    , caracter  , Serie da NF de devolução
@param cSupID       , caracter  , Codigo do fornecedor
@param cSupBranch   , caracter  , Loja do fornecedor
@param cReqCode     , caracter  , RequestCode (Código da Solicitação)

@return lRet, lógico, status da atualização da linha na Tabela AR2 
@author Squad NT TechFin
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Function RskAddAR2( oMdlAR2 As Object, cTypeMov As Character, cFilInv As Character, cPrefix As Character, cNumInv As Character, cInstallment As Character, cType As Character, cCustomer As Character, cUnit As Character, nAmount As Numeric,;
 dDueDate As Date, cTitIdOri As Character, cPlatfId As Character, cFilNFDev As Character, cNumNFDev As Character, cSerNFDev As Character, cSupID As Character, cSupBranch As Character, cReqCode As Character ) As Logical
	Local nLinLen   As Numeric
	Local cNewItem  As Character
	Local lRet      As Logical

	nLinLen  := 0
	cNewItem := ""
	lRet     := .T.

	Default cCustomer  := ""
	Default cUnit      := ""
	Default cPlatfId   := ""
	Default cFilNFDev  := ""
	Default cNumNFDev  := ""
	Default cSerNFDev  := ""
	Default cSupID     := ""
	Default cSupBranch := ""
	Default cReqCode   := ""

	If oMdlAR2:IsEmpty()
		cNewItem := StrZero( 1, TAMSX3( "AR2_ITEM" )[1] )
	Else
		nLinLen := oMdlAR2:Length()
		oMdlAR2:GoLine( nLinLen )

		cNewItem    := Soma1( oMdlAR2:GetValue( "AR2_ITEM" ) )
		lRet        := oMdlAR2:AddLine() > nLinLen
	EndIf

	If lRet
		oMdlAR2:SetValue( "AR2_ITEM"     , cNewItem )
		oMdlAR2:SetValue( "AR2_MOV"      , cTypeMov )  //"1=Receber (R);2=Taxa (P);3=Bonificação (P);4=Prorrogação (P);5=Devolução (P);6=Bloqueia NCC (R);7=Libera NCC (R);8=NCC Baixa Parcial (R);9=NCC Baixa Total (R);A=Cancelada (P);B=NCC Inativa (R);C=Taxa Antecipação (P)"
		oMdlAR2:SetValue( "AR2_FILTIT"   , cFilInv )
		oMdlAR2:SetValue( "AR2_PREFIX"   , cPrefix )
		oMdlAR2:SetValue( "AR2_NUMTIT"   , cNumInv )
		oMdlAR2:SetValue( "AR2_PARC"     , cInstallment )   //Parcela do titulo
		oMdlAR2:SetValue( "AR2_TIPO"     , cType )

		If cTypeMov $ "2|3|4|5|A|C"
			oMdlAR2:SetValue( "AR2_FORNEC"   , cSupID )
			oMdlAR2:SetValue( "AR2_LOJFOR"   , cSupBranch )
		Else
			oMdlAR2:SetValue( "AR2_CLIENT"   , cCustomer )
			oMdlAR2:SetValue( "AR2_LOJA"     , cUnit )
		EndIf

		oMdlAR2:SetValue( "AR2_VALOR"    , nAmount )    //Valor do titulo
		oMdlAR2:SetValue( "AR2_DATATI"   , dDueDate )      //Vencimento do titulo
		oMdlAR2:SetValue( "AR2_TITORI"   , cTitIdOri )
		oMdlAR2:SetValue( "AR2_IDTITP"   , cPlatfId )
		oMdlAR2:SetValue( "AR2_FILNFD"   , cFilNFDev )
		oMdlAR2:SetValue( "AR2_NFDEV"    , cNumNFDev )
		oMdlAR2:SetValue( "AR2_SERDEV"   , cSerNFDev )
		If AR2->( ColumnPos( "AR2_REQCOD" ) ) > 0
			oMdlAR2:SetValue( "AR2_REQCOD"   , cReqCode )
		EndIf
		lRet := oMdlAR2:VldLineData()
	EndIf

Return lRet

//------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKNCCAnalyze
Função para avaliar se a NCC deve ser bloqueada por estar referenciada a alguma NF da carteira Off Balance 

@param      cSerie, character, Série da Nota fiscal de devolução
@param      cNumero, character, Numero da Nota fiscal de devolução
@param      cCliente, character, Código do cliente 
@param      cLoja, character, Código da loja do cliente 

@return     cCarteira, character, Carteira que a NCC será atribuida.
@author  Marcia Junko
@since   28/10/2020
/*/
//------------------------------------------------------------------------------------------------------------
Function RSKNCCAnalyze( cSerie As Character, cNumero As Character, cCliente As Character, cLoja As Character ) As Character
	Local aSvAlias   As Array
	Local aAreaAR0   As Array
	Local aAreaAR1   As Array
	Local cCartDev   As Character
	Local cCarteira  As Character
	Local cQuery     As Character
	Local cAliasTMP  As Character
	Local cStatusAR1 As Character
	Local oMdl020    As Object
	Local oMdlAR1    As Object
	Local oMdl010    As Object
	Local oMdlAR0    As Object
	Local oQueryAR1  As Object

	aSvAlias   := GetArea()
	aAreaAR0   := AR0->( GetArea() )
	aAreaAR1   := AR1->( GetArea() )
	cCartDev   := ""
	cCarteira  := ""
	cQuery     := ""
	cAliasTMP  := ""
	cStatusAR1 := AR1_STT_APPROVED + '|' + AR1_STT_REJECTED + '|' + AR1_STT_CANCELED + '|' + AR1_STT_ERRORCANCERP // 2=Aprovado ### 3=Rejeitada ### 4=Cancelada ### 9=Erro no Cancelamento ERP
	oMdl020    := Nil
	oMdlAR1    := Nil
	oMdl010    := Nil
	oMdlAR0    := Nil
	oQueryAR1  := Nil

	AR0->(DBSetOrder(3))    //AR0_FILIAL+AR0_FILNFS+AR0_NUMNFS+AR0_SERNFS
	AR1->(DBSetOrder(1))    //AR1_FILIAL+AR1_COD

	cCartDev    := SuperGetMv( "MV_RSKSNCC", .F., "" )
	cCarteira   := "0"

	If !( Empty( cCartDev)  )
		cAliasTMP := GetNextAlias()

		cQuery := "SELECT AUX.AR1_FILIAL, AUX.AR1_COD, AUX.AR1_STATUS FROM " + RetSqlName( "SD1" ) + " SD1 " + ;
			"INNER JOIN " + RetSqlName( "AR1" ) + " AUX  " + ;
			"ON AR1_FILIAL = ? " + ;
			"AND AUX.AR1_CLIENT = D1_FORNECE  " + ;
			"AND AUX.AR1_LOJA = D1_LOJA  " + ;
			"AND AUX.AR1_DOC = D1_NFORI " + ;
			"AND AUX.AR1_SERIE = D1_SERIORI  " + ;
			"AND AUX.AR1_STATUS IN ? " + ;
			"AND AUX.D_E_L_E_T_ = ' '  " + ;
			"WHERE D1_FILIAL = ? " + ;
			"AND D1_TIPO = 'D' " + ;
			"AND D1_DOC = ? " + ;
			"AND D1_SERIE = ? " + ;
			"AND D1_FORNECE = ? " + ;
			"AND D1_LOJA = ? " + ;
			"AND SD1.D_E_L_E_T_ =  ' '"

		cQuery    := ChangeQuery( cQuery )
		oQueryAR1 := FWPreparedStatement():New(cQuery)

		oQueryAR1:SetString( 1, xFilial( 'AR1' ) )
		oQueryAR1:SetUnsafe( 2, FormatIn( cStatusAR1, "|" ) )
		oQueryAR1:SetString( 3, xFilial( 'SD1' ) )
		oQueryAR1:SetString( 4, cNumero )
		oQueryAR1:SetString( 5, cSerie )
		oQueryAR1:SetString( 6, cCliente )
		oQueryAR1:SetString( 7, cLoja )

	    cQuery := oQueryAR1:GetFixQuery()
		MPSysOpenQuery( cQuery, cAliasTMP )

		If ( cAliasTMP )->( !Eof() )
			If ( cAliasTMP )->AR1_STATUS ==  AR1_STT_APPROVED .Or. ( cAliasTMP )->AR1_STATUS == AR1_STT_ERRORCANCERP  // 2=Aprovado ### 9=Erro no Cancelamento ERP
				cCarteira := cCartDev
			Else
				If AR1->( DBSeek(( cAliasTMP )->AR1_FILIAL + ( cAliasTMP )->AR1_COD ) )
					oMdl020 := FWLoadModel("RSKA020")
					oMdl020:SetOperation(MODEL_OPERATION_UPDATE)
					oMdl020:Activate()

					If oMdl020:IsActive()
						oMdlAR1 := oMdl020:GetModel("AR1MASTER")
						If oMdlAR1:GetValue("AR1_STATUS") != AR1_STT_CANCELED   // 4=Cancelada
							oMdlAR1:SetValue("AR1_STATUS", AR1_STT_CANCELED)    // 4=Cancelada
							If oMdl020:VldData()
								oMdl020:CommitData()
							EndIf
						EndIf
					EndIf

					oMdl020:DeActivate()
					oMdl020:Destroy()

					//-------------------------------------------------------------------------------
					// Cancelamento do ticket.
					//-------------------------------------------------------------------------------
					If AR0->(DBSeek(xFilial("AR0") + AR1->AR1_FILNF + AR1->AR1_DOC + AR1->AR1_SERIE ))
						oMdl010 := FWLoadModel("RSKA010")
						oMdl010:SetOperation(MODEL_OPERATION_UPDATE)
						oMdl010:Activate()

						If oMdl010:IsActive()
							oMdlAR0 := oMdl010:GetModel("AR0MASTER")
							oMdlAR0:SetValue("AR0_STATUS", AR0_STT_CANCELED ) // 4=Cancelado
							//-------------------------------------------------------------------------------
							// Retorna para 1 para enviar o Status Cancelado.
							//-------------------------------------------------------------------------------
							oMdlAR0:SetValue("AR0_STARSK", STARSK_SUBMIT )  // 1=Enviar
							If oMdl010:VldData()
								oMdl010:CommitData()
							EndIf
						EndIf

						oMdl010:DeActivate()
						oMdl010:Destroy()
					EndIf
				EndIf
			EndIf
		EndIf
		( cAliasTMP )->( DBCloseArea() )
	EndIf

	cCarteira := PadR( cCarteira, TamSX3( "E1_SITUACA" )[1] )

	RestArea( aSvAlias )
	RestArea( aAreaAR0 )
	RestArea( aAreaAR1 )

	FWFreeArray( aSvAlias )
	FWFreeArray( aAreaAR0 )
	FWFreeArray( aAreaAR1 )
	FreeObj(oMdl020)
	FreeObj(oMdlAR1)
	FreeObj(oMdl010)
	FreeObj(oMdlAR0)
	FreeObj(oQueryAR1)
Return cCarteira

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskVdLNDev
Validação da linha da nota de entrada durante a devolução da NF de Origem.

@param cFilSD2      , caracter, Filial do item da NF de Origem
@param cNFSNumOri   , caracter, Número de NF de Origem
@param cNFSSerOri   , caracter, Serie da NF de Origem
@param cCodCli      , caracter, Código do cliente
@param cLojCli      , caracter, Loja do cliente

@return lRet , logico, Retorna se o NF de Origem pode ser devolvida.

@author Squad NT TechFin
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Function RskVdLNDev(cFilSD2, cNFSNumOri, cNFSSerOri, cCodCli, cLojCli)
	Local aArea := GetArea()
	Local aAreaAR1 := AR1->( GetArea() )
	Local lRet  := .T.

	AR1->(DBSetOrder(2))    //AR1_FILIAL+AR1_FILNF+AR1_DOC+AR1_SERIE+AR1_CLIENT+AR1_LOJA
	If AR1->(MSSeek(xFilial("AR1") + cFilSD2 + cNFSNumOri + cNFSSerOri + cCodCli + cLojCli))
		If !(AR1->AR1_STATUS $ '"' + AR1_STT_APPROVED + '|' + AR1_STT_REJECTED + '|' + AR1_STT_CANCELED + '|' + AR1_STT_ERRORCANCERP + '|' + AR1_STT_CANCREPROSUP + ' | ' + AR1_STT_CANSUPOK + '"')     // 2=Aprovada ### 3=Rejeitada ### 4=Cancelada ### 9=Erro no Cancelamento ERP ### A=Cancelamento Reprovado Supplier ### C=NF Cancelada na Supplier
			lRet := .F.

			Do Case
			Case AR1->AR1_STATUS == AR1_STT_AWAIT   // 0=Aguardando envio
				Help( "", 1, "RskVdLNFDev", ,I18N( STR0008, { AllTrim( AR1->AR1_DOC ), AllTrim( AR1->AR1_SERIE ) } );
					, 1, 0,,,,,, { STR0009 } )  //"NF de Origem Mais Negócios Número: #1 Série: #2 está com status de Aguardando Envio."  # "Aguarde o envio para realizar a devolução ou remova esta NF de Origem dos itens."
			Case AR1->AR1_STATUS == AR1_STT_ANALYSIS    // 1=Em análise
				Help( "", 1, "RskVdLNFDev", , I18N( STR0010, { AllTrim( AR1->AR1_DOC ), AllTrim( AR1->AR1_SERIE ) } ) ;
					, 1, 0,,,,,, { STR0011 } ) //"NF de Origem Mais Negócios Número: #1 Série: #2 está com status Em Análise." # "Aguarde o processamento para realizar a devolução ou remova esta NF de Origem dos itens."
			Case AR1->AR1_STATUS == AR1_STT_FLIMSY      // 5=Inconsistente
				Help( "", 1, "RskVdLNFDev", , I18N( STR0012, { AllTrim( AR1->AR1_DOC ), AllTrim( AR1->AR1_SERIE ) } ) ;
					, 1, 0,,,,,, { STR0013 } ) //"NF de Origem Mais Negócios Número: #1 Série: #2 está com status Inconsistente." # "Aguarde o reprocessamento para realizar a devolução ou remova esta NF de Origem dos itens."
			Case AR1->AR1_STATUS $ '"' + AR1_STT_CANCELING + '|' + AR1_STT_CANCELINGSEF + '|' + AR1_STT_CANCELINGSUP + '"' // 6=Em cancelamento ### 7=Em cancelamento Sefaz ### 8=Em cancelamento Supplier
				Help( "", 1, "RskVdLNFDev", ,I18N( STR0020, { AllTrim( AR1->AR1_DOC ), AllTrim( AR1->AR1_SERIE ) , X3CboxDesc("AR1_STATUS", AllTrim(AR1->AR1_STATUS)) } );
					, 1, 0,,,,,, { STR0011 } )  //"NF de Origem Mais Negócios Número: #1 Série: #2 está com status #3."  # "Aguarde o processamento para realizar a devolução ou remova esta NF de Origem dos itens."
			OtherWise
				Help( "", 1, "RskVdLNFDev", , I18N( STR0014, { AllTrim( AR1->AR1_DOC ), AllTrim( AR1->AR1_SERIE ) } ) ;
					, 1, 0,,,,,, { STR0015 } ) //"Não será possível realizar a devolução da NF de Origem Mais Negócios Número: #1 Serie: #2" # "Remova esta NF de Origem dos itens para realizar a devolução."
			EndCase
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaAR1)
	FwFreeArray(aArea)
	FwFreeArray(aAreaAR1)
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CreateQueryModel
Função responsável por criar a query base de acordo com a operação solicitada.
As querys devem ser montadas respeitando o conceito da função FWPreparedStatement().

@param cOper, caracter, Identifica qual a query será montada

@return object, Objeto contendo a query base a ser executada.
@author Marcia Junko
@since 03/09/2020
/*/
//----------------------------------------------------------------------------------
Static Function CreateQueryModel( cOper As Character ) As Object
	Local oPrepare As Object
	Local cQuery   As Character

	oPrepare := Nil
	cQuery   := ""

	Do Case
	Case cOper == "QTmpNCCOri"
		cQuery := "SELECT DISTINCT F1_FILIAL, F1_SERIE, F1_DOC, "
		cQuery += "F1_FORNECE, F1_LOJA "
		cQuery += "FROM " + RetSqlName("SE1") + " SE1 "
		cQuery += "INNER JOIN " + RetSqlName("SD1") + " SD1 "
		cQuery += "ON  SD1.D1_FILORI = SE1.E1_FILORIG "
		cQuery += "AND SD1.D1_NFORI = SE1.E1_NUM "
		cQuery += "AND SD1.D1_SERIORI = SE1.E1_SERIE "
		cQuery += "AND SD1.D1_FORNECE = SE1.E1_CLIENTE "
		cQuery += "AND SD1.D1_LOJA = SE1.E1_LOJA "
		cQuery += "AND SD1.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("SF1") + " SF1 "
		cQuery += "ON  SF1.F1_FILIAL = SD1.D1_FILIAL  "
		cQuery += "AND SF1.F1_DOC = SD1.D1_DOC "
		cQuery += "AND SF1.F1_SERIE = SD1.D1_SERIE "
		cQuery += "AND SF1.F1_FORNECE = SD1.D1_FORNECE "
		cQuery += "AND SF1.F1_LOJA = SD1.D1_LOJA "
		cQuery += "AND SF1.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE SE1.E1_FILIAL = ? "
		cQuery += "AND SE1.E1_PREFIXO = ? "
		cQuery += "AND SE1.E1_NUM = ? "
		cQuery += "AND SE1.D_E_L_E_T_ = ' ' "
		cQuery += "AND SD1.D1_FILIAL = ? "
		cQuery += "AND SD1.D1_SERIE = ? "
		cQuery += "AND SD1.D1_DOC = ? "
		cQuery += "AND SE1.E1_CLIENTE = ? "
		cQuery += "AND SE1.E1_LOJA = ? "

	Case cOper == "QCountNFS"
		cQuery := "SELECT COUNT( DISTINCT D1_FILIAL || D1_NFORI || D1_SERIORI ) TOTAL "
		cQuery += "FROM " + RetSqlName("SD1") + " SD1 "
		cQuery += "INNER JOIN " + RetSqlName("AR1") + " AR1 "
		cQuery += "ON SD1.D1_FILIAL = AR1.AR1_FILNF "
		cQuery += "AND SD1.D1_NFORI = AR1.AR1_DOC "
		cQuery += "AND SD1.D1_SERIORI = AR1.AR1_SERIE "
		cQuery += "AND SD1.D1_FORNECE = AR1.AR1_CLIENT "
		cQuery += "AND SD1.D1_LOJA = AR1.AR1_LOJA "
		cQuery += "AND AR1.D_E_L_E_T_ = ' ' "
		cQuery += "INNER JOIN " + RetSqlName("SE1") + " SE1 "
		cQuery += "ON AR1.AR1_FILNF = SE1.E1_FILORIG "
		cQuery += "AND AR1.AR1_SERIE = SE1.E1_SERIE "
		cQuery += "AND AR1.AR1_DOC = SE1.E1_NUM "
		cQuery += "AND AR1.AR1_CLIENT = SE1.E1_CLIENTE "
		cQuery += "AND AR1.AR1_LOJA = SE1.E1_LOJA "
		cQuery += "AND SE1.D_E_L_E_T_ = ' ' "		
		cQuery += "WHERE D1_FILIAL = ? "
		cQuery += "AND SD1.D1_DOC = ? "
		cQuery += "AND SD1.D1_SERIE = ? "
		cQuery += "AND SD1.D1_FORNECE = ? "
		cQuery += "AND SD1.D1_LOJA = ? "
		cQuery += "AND SE1.E1_FILIAL = ? "
		cQuery += "AND SE1.E1_PREFIXO = ? "
		cQuery += "AND SE1.E1_NUM = ? "
		cQuery += "AND SE1.E1_PARCELA = ? "
		cQuery += "AND SE1.E1_TIPO = ? "
		cQuery += "AND SD1.D_E_L_E_T_ = ' ' "

	Case cOper == "QNCCRelease"
		cQuery := " SELECT  SE1.R_E_C_N_O_ E1_RECNO, AR1.R_E_C_N_O_ AR1_RECNO, AR2.R_E_C_N_O_ AR2_RECNO  "
		cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
		cQuery += " INNER JOIN  " + RetSqlName("AR2") + " AR2 "
		cQuery += " ON E1_FILORIG = AR2_FILNFD  AND E1_NUM = AR2_NFDEV "
		cQuery += " AND E1_SERIE = AR2_SERDEV "
		cQuery += " AND AR2_MOV = '" + AR2_MOV_BLOCK_NCC + "' "     // Bloqueia NCC
		cQuery += " AND AR2.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN  " + RetSqlName("AR1") + " AR1 "
		cQuery += " ON AR2_FILIAL = AR1_FILIAL  AND AR2_COD = AR1_COD"
		cQuery += " AND AR1.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE E1_FILIAL = ? "
		cQuery += " AND E1_PREFIXO = ? "
		cQuery += " AND E1_PARCELA = ? "
		cQuery += " AND E1_NUM = ? "
		cQuery += " AND E1_TIPO = ? "
		cQuery += " AND E1_ORIGEM = '" + PadR("MATA100",TamSX3("E1_ORIGEM")[1]) +  "'"
		cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
	End Case

	cQuery      := ChangeQuery( cQuery )
	
	oPrepare    := FWPreparedStatement():New( cQuery )
	_oHshQryAS:Put(oPrepare, cOper)
Return oPrepare


//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetQuery
Função responsável por verificar no cache se a query já foi executada anteriormente.
Caso ainda não tenha sido executada, cria a query base de acordo com a operação que
está sendo executada.

@param cOper, caracter, Identifica qual a query será retornada

@return object, Objeto contendo a query a ser executada.
@author Marcia Junko
@since 03/09/2020
/*/
//----------------------------------------------------------------------------------
Static Function GetQuery( cOper )
	Local oPrepare := Nil

	If !_oHshQryAS:ContainsKey( cOper )
		oPrepare := CreateQueryModel( cOper )
	Else
		oPrepare := _oHshQryAS:get( cOper )
	EndIf
Return oPrepare

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RskDelNcc
Função responsável por RetornaR mensagem de alerta para exclusão de devolução TOTVS 
Mais Negocios.  

@author Lucas Silva Vieira
@since 15/03/2023
/*/
//----------------------------------------------------------------------------------
Function RskDelNcc()
	Local cTemp 	As Character
	Local aArea 	As Array 

	cTemp := QNccDel()   
	aArea := (GetArea())

	If (cTemp)->(!EOF())	
        Help( "", 1, STR0022,, STR0023, 1, 0,,,,,, { STR0024 } )  //RSKDELNCC #Essa nota está integrada com a Supplier. #Após a confirmação de exclusão desta Nota Fiscal, todo o ajuste financeiro deste processo deverá ser realizado de forma manual.	 
    Endif

	(cTemp)->(DBCloseArea())
	RestArea(aArea)
	FwFreeArray(aArea)
Return 

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RskIntNcc
Função responsável Atualiza o status para NCC Inativa

@author Lucas Silva Vieira
@since 20/03/2023
/*/
//----------------------------------------------------------------------------------
Function RskIntNcc() 
	Local oModel    	As Object
	Local oMdlAR2		As Object
	Local aArea 		As Array 
	Local aGetAr1		As Array
	Local aGetAr2		As Array	
	Local cTemp			As Character
	
	cTemp  	:= QNccDel()   
	aArea := (GetArea())
	aGetAr1 := AR1->(GetArea())
	aGetAr2 := AR2->(GetArea())
	AR2->(DBSetOrder(1))
	AR1->(DBSetOrder(1))

    If (cTemp)->(!EOF())
		AR1->( DbGoTo( ( cTemp )->( RECNOAR1 ) ) )
		AR2->( DbGoTo( ( cTemp )->( RECNOAR2 ) ) )
		oModel := FwLoadModel( "RSKA020" ) 
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()   
		If oModel:IsActive() 
			oMdlAR2 := oModel:GetModel("AR2DETAIL")
			If oMdlAR2:SeekLine({ {"AR2_ITEM", (cTemp)->AR2_ITEM }})
				oMdlAR2:GoLine( oMdlAR2:nLine )
				oMdlAR2:SetValue( "AR2_MOV", AR2_MOV_NCCINATV )   
				If oModel:VldData()
					oModel:CommitData() 
				EndIf 
			EndIf 
		Endif
		oModel:Destroy()
	Endif

	(cTemp)->(DBCloseArea())

	RestArea(aArea)
	RestArea(aGetAr1)
	RestArea(aGetAr2)
	FreeObj( oModel )
	FreeObj( oMdlAR2 )
	FwFreeArray(aArea)
	FwFreeArray(aGetAr1)
	FwFreeArray(aGetAr2)
Return 

/*/{Protheus.doc} QNccDel
Função responsável por executar a query para buscar a nota de devolução na AR2

@return cTemp, Character, resultado da query 
@author Lucas Silva Vieira
@since 20/03/2023
/*/
//----------------------------------------------------------------------------------
Static Function QNccDel() As Character
	Local oStatement    As Object
    Local cQuery        As Character

		cQuery := " SELECT AR1.R_E_C_N_O_ RECNOAR1,  AR2.R_E_C_N_O_ RECNOAR2, AR2_FILIAL, AR2_COD, AR2_ITEM"
		cQuery += " FROM " + RetSqlName("AR1") + " AR1 "
		cQuery += " INNER JOIN " + RetSqlName("AR2") + " AR2 ON AR2_FILIAL=AR1_FILIAL AND AR2_COD=AR1_COD AND AR2.D_E_L_E_T_ = ' ' AND AR2_FILIAL=?"
		cQuery += " INNER JOIN  " + RetSqlName("SF1") + " SF1 ON SF1.F1_FILIAL = AR2.AR2_FILNFD "
		cQuery += " AND SF1.F1_DOC = AR2.AR2_NFDEV AND SF1.F1_SERIE = AR2.AR2_SERDEV "
		cQuery += " AND SF1.F1_FORNECE = AR2.AR2_CLIENT AND SF1.F1_LOJA = AR2.AR2_LOJA "
        cQuery += " AND SF1.D_E_L_E_T_ = ' '"
		cQuery += " WHERE SF1.F1_FILIAL = ? "
		cQuery += " AND SF1.F1_DOC = ? "
		cQuery += " AND SF1.F1_SERIE = ? "
		cQuery += " AND SF1.F1_FORNECE = ? "
		cQuery += " AND SF1.F1_LOJA = ? "
        cQuery += " AND AR1.D_E_L_E_T_ = ' '"
        cQuery += " AND AR1_FILIAL = ?"

        cQuery := ChangeQuery( cQuery )
        oStatement := FWPreparedStatement():New(cQuery)

		oStatement:SetString(1,xFilial("AR2"))
		oStatement:SetString(2,SF1->F1_FILIAL)
		oStatement:SetString(3,SF1->F1_DOC)
		oStatement:SetString(4,SF1->F1_SERIE)
		oStatement:SetString(5,SF1->F1_FORNECE)
		oStatement:SetString(6,SF1->F1_LOJA)
		oStatement:SetString(7,xFilial("AR1"))

		cQuery := oStatement:GetFixQuery()
		cTemp := MPSysOpenQuery( cQuery )

		FreeObj(oStatement)

Return cTemp
