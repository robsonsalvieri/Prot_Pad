#INCLUDE "protheus.ch"
#INCLUDE "RSKDefs.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RSKA080.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} RSKBankConciliation
Funcao que realiza conciliação financeira da NFS Mais Negocios.

@param aData, array, Dados da concialiação bancaria
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT TechFin
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Function RSKBankConciliation( aData As Array, lAutomato As Logical, cHost As Character, nType As Numeric )
	Local aArea 		As Array
	Local aAreaAR4 		As Array
	Local aAreaSA6 		As Array
	Local aConciliation As Array
	Local aImpError 	As Array
	Local aBnkEvents 	As Array
	Local aRetPE 		As Array
	Local aCustom 		As Array
	Local aBankPart		As Array
	Local aInstallments As Array
	Local aCustomItem 	As Array
	Local aMovType 		As Array
	Local nMovType 		As Numeric
	Local nLenData 		As Numeric
	Local nX 			As Numeric
	Local nLenBank 		As Numeric
	Local nLenBBranch 	As Numeric
	Local nLenAccount 	As Numeric
	Local nAmount 		As Numeric
	Local nFeePaid 		As Numeric
	Local nPosInst 		As Numeric
	Local nStrLen 		As Numeric
	Local nPosEvent 	As Numeric
	Local nSizeItem 	As Numeric
	Local nFeeOri       As Numeric
	Local nAntecFee     As Numeric
	Local oModel 		As Object
	Local oQryAnt 		As Object
	Local oQryNFS 		As Object
	Local cRetMessage 	As Character
	Local cBank 		As Character
	Local cBankPart 	As Character
	Local cBnkBranch 	As Character
	Local cBnkPartBch 	As Character
	Local cBnkAccount 	As Character
	Local cBnkPartAcc 	As Character
	Local cQryAnt 		As Character
	Local cQryNFS 		As Character
	Local cInstallment 	As Character
	Local cItemLog 		As Character
	Local cBranchAR1 	As Character
	Local cBranchAR4 	As Character
	Local cIDAR4 		As Character
	Local cTempAnt 		As Character
	Local cTempNFS 		As Character
	Local cObservacao 	As Character
	Local lPEBankCon 	As Logical
	Local lProcBnkEvt 	As Logical
	Local lBnkAccDig 	As Logical
	Local lContraVencto As Logical
	Local lProcBaixa 	As Logical
	Local lDtMovFin 	As Logical
	Local lExistAR4 	As Logical
	Local lSttError 	As Logical
	Local nRecAR4 		As Numeric
	Local lBxDtFin 		As Logical
	Local lProrrog 		As Logical
	Local lCtaPonte     As Logical
	Local lAntecipac    As Logical
	Local lAr2DataOr    As Logical
	Local lAr2ReqCode   As Logical
	Local dDataConci    As Date
	Local aDtTransf     As Array
	Local nQtdDtTran    As Numeric
	Local nY            As Numeric
	Local nSldTransf    As Numeric
	Local cIdNatInc	    As Character
	Local cIdNatExp	    As Character
	Local cDocTran	    As Character
	Local aTransfBCO    As Array
	Local cBnkTransf    As Character
	Local cAgyTransf    As Character
	Local cAccTransf    As Character
	Local aErroAuto     As Array
	Local cLogMsg       As Character
	Local dDataBkp      As Date

	Private lMsErroAuto    As Logical
	Private lMsHelpAuto    As Logical
	Private lAutoErrNoFile As Logical

	Default lAutomato := .F.

	aArea         := GetArea()
	aAreaAR4      := AR4->( GetArea() )
	aAreaSA6      := SA6->( GetArea() )
	aConciliation := {}
	aImpError     := {}
	aBnkEvents    := {}
	aRetPE        := {}
	aCustom       := {}
	aBankPart	  := {}
	aInstallments := RskInstallments(100)
	aCustomItem   := {}
	aMovType      := {}
	nMovType      := 0
	nLenData      := 0
	nX            := 0
	nLenBank      := TamSX3( "A6_COD" )[1]
	nLenBBranch   := TamSX3( "A6_AGENCIA" )[1]
	nLenAccount   := TamSX3( "A6_NUMCON" )[1]
	nAmount       := 0
	nFeePaid      := 0
	nPosInst      := 0
	nStrLen       := 0
	nPosEvent     := 0
	nSizeItem     := TamSX3( "AR4_ITEM" )[1]
	oModel        := Nil
	oQryAnt       := Nil
	oQryNFS       := Nil
	cRetMessage   := ""
	cBank         := ""
	cBankPart     := ""
	cBnkBranch    := ""
	cBnkPartBch   := ""
	cBnkAccount   := ""
	cBnkPartAcc   := ""
	cQryAnt       := ""
	cQryNFS       := ""
	cInstallment  := ""
	cItemLog      := ""
	cBranchAR1    := xFilial("AR1")
	cBranchAR4    := xFilial("AR4")
	cIDAR4        := RSKAR4IDLog()
	cTempAnt      := GetNextAlias()
	cTempNFS      := GetNextAlias()
	cObservacao   := ""
	lPEBankCon    := ExistBlock("RskBankCon")
	lProcBnkEvt   := .T.
	lBnkAccDig    := .F.
	lContraVencto := .F.
	lProcBaixa    := .F.
	lDtMovFin     := .T.
	lExistAR4     := .F.
	lSttError     := .F.
	nRecAR4       := 0
	lBxDtFin      := .F.
	lProrrog      := .F.
	lCtaPonte     := .F.
	lAntecipac    := .F.
	lAr2DataOr    := AR2->( ColumnPos( "AR2_DATAOR" ) ) > 0
	lAr2ReqCode   := AR2->( ColumnPos( "AR2_REQCOD" ) ) > 0
	dDataConci    := dDataBase
	aDtTransf     := {}
	nQtdDtTran    := 0
	nY            := 0
	nSldTransf    := 0
	cIdNatInc     := ""
	cIdNatExp     := ""
	cDocTran      := ""
	aTransfBCO    := {}
	cBnkTransf    := ""
	cAgyTransf    := ""
	cAccTransf    := ""
	aErroAuto     := {}
	cLogMsg       := ""
	nFeeOri       := 0
	nAntecFee     := 0

  	lMsErroAuto    := .F.
    lMsHelpAuto    := .T.
	lAutoErrNoFile := .T.

	SuperGetMV()
	aBankPart  := StrToArray( SuperGetMv( "MV_RSKBPAY",, "SUP|SUPPL|SUPPLIER" ), "|" )
	lBnkAccDig := SuperGetMv("MV_RSKCDIG",.F.,.F.)
	lBxDtFin   := SuperGetMv("MV_BXDTFIN",,"1") == "2"
	lCtaPonte  := SuperGetMV("MV_RSKTPCO", .F., 0 ) == 1

	If lPEBankCon
		aRetPE := ExecBlock("RskBankCon", .F., .F.,{ 1, Nil })

		If ValType(aRetPE) == "A"
			aBnkEvents := aRetPE
		EndIf
	EndIf

	oModel      := FwLoadModel( "RSKA020" )
	nLenData    := Len( aData )
	aDueARInv   := cTod("//")
	nValARInv   := 0

	AR1->( DBSetOrder(3) ) //AR1_FILIAL+AR1_CGCCLI+AR1_TCKTRA
	SA6->( DBSetOrder(1) ) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	AR4->( DbSetOrder(2) ) //AR4_FILIAL+AR4_IDORIG

	If Len( aBankPart ) == 3 .Or. Len( aBankPart ) == 6
		cBankPart   := PadR( aBankPart[BANKP_CODE], nLenBank )
		cBnkPartBch	:= PadR( aBankPart[BANKP_AGENCY], nLenBBranch )
		cBnkPartAcc := PadR( aBankPart[BANKP_ACCOUNT], nLenAccount )

		If SA6->( DBSeek( xFilial("SA6") + cBankPart + cBnkPartBch + cBnkPartAcc ) )
			cBankPart	:= SA6->A6_COD
			cBnkPartBch	:= SA6->A6_AGENCIA
			cBnkPartAcc := SA6->A6_NUMCON
		EndIf
	EndIf

	If lCtaPonte
		If Len( aBankPart ) == 6 .And. SA6->( MsSeek( xFilial("SA6") + PadR( aBankPart[BANKJ_CODE], nLenBank ) + PadR( aBankPart[BANKJ_AGENCY], nLenBBranch ) + PadR( aBankPart[BANKJ_ACCOUNT], nLenAccount ) ) )
			cBankPart	:= SA6->A6_COD
			cBnkPartBch	:= SA6->A6_AGENCIA
			cBnkPartAcc := SA6->A6_NUMCON
		EndIf

		cBnkTransf  := cBankPart
		cAgyTransf  := cBnkPartBch
		cAccTransf  := cBnkPartAcc
		aBankPart   := StrToArray( SuperGetMv( "MV_RSKBPTR",, "SUP|SUPPL|PONTE" ), "|" )
		cBankPart   := PadR( aBankPart[BANKP_CODE], nLenBank )
		cBnkPartBch	:= PadR( aBankPart[BANKP_AGENCY], nLenBBranch )
		cBnkPartAcc := PadR( aBankPart[BANKP_ACCOUNT], nLenAccount )

		If SA6->( MsSeek( xFilial("SA6") + cBankPart + cBnkPartBch + cBnkPartAcc ) )
			cBank       := SA6->A6_COD
			cBnkBranch  := SA6->A6_AGENCIA
			cBnkAccount := SA6->A6_NUMCON
		EndIf
	EndIf

	If !Empty( cBankPart ) .And. !Empty( cBnkPartBch ) .And. !Empty( cBnkPartAcc )

		aSort( aData,,,{ |x, y| ( x[ BANK_EVENT_TYPE ] + x[ BANK_TRANS_CODE ] + x[ BANK_PARCEL ]  < y[ BANK_EVENT_TYPE ] + y[ BANK_TRANS_CODE ] + y[ BANK_PARCEL ] ) } )

		cQryNFS := " SELECT AR1.AR1_COD,AR1.AR1_DOC, AR1.AR1_SERIE, AR1.AR1_TCKTRA, AR2.AR2_FILIAL, AR2.AR2_COD, AR2.AR2_MOV, " +;
			"AR2.AR2_FILTIT, AR2.AR2_PREFIX, AR2.AR2_NUMTIT, AR2.AR2_PARC, AR2.AR2_TIPO, " + ;
			"AR2.AR2_CLIENT, AR2.AR2_LOJA, AR2.AR2_VALOR, AR2.AR2_DATATI, AR2.AR2_FORNEC, AR2.AR2_LOJFOR "
		If lAr2DataOr
			cQryNFS += ", AR2.AR2_DATAOR "
		EndIf
		cQryNFS += 	" FROM " + RetSqlName( "AR1" ) + " AR1 " + ;
			" INNER JOIN " + RetSqlName( "AR2" ) + " AR2 " + ;
			" ON AR2.AR2_FILIAL = AR1.AR1_FILIAL " + ;
			" AND AR2.AR2_COD = AR1.AR1_COD " + ;
			" AND AR2.D_E_L_E_T_ = ' ' " +;
			" WHERE AR1.AR1_FILIAL = ? " + ;
			" AND AR1.AR1_CGCCLI = ? " + ;
			" AND AR1.AR1_TCKTRA = ? " + ;
			" AND AR2.AR2_MOV = ? " + ;
			" AND ( AR2.AR2_PARC = ? OR AR2.AR2_PARC = ? )" + ;
			" AND AR2.AR2_TIPO = ? " +;
			" AND AR1.D_E_L_E_T_ = ' ' "
		If lAr2ReqCode
			cQryNFS += " AND ( AR2_REQCOD = ? OR AR2_REQCOD = ? )"
		EndIf

		cQryNFS := ChangeQuery( cQryNFS )
		oQryNFS := FWPreparedStatement():New( cQryNFS )
		
		//Antecipação
		cQryAnt := " SELECT AR2.AR2_FILIAL, AR2.AR2_FILTIT, AR2.AR2_PREFIX, AR2.AR2_NUMTIT, AR2.AR2_PARC, AR2.AR2_TIPO, " + ;
			" AR2.AR2_CLIENT, AR2.AR2_LOJA, AR2.AR2_VALOR, AR2.AR2_DATATI, AR2.AR2_FORNEC, AR2.AR2_LOJFOR, AR1.AR1_DOC, AR1.AR1_SERIE " + ;
			" FROM " + RetSqlName( "AR2" ) + " AR2 " + ;
			" INNER JOIN " + RetSqlName( "AR1" ) + " AR1 " + ;
			" ON AR1.AR1_FILIAL = AR2.AR2_FILIAL " + ;
			" AND AR1.AR1_COD = AR2.AR2_COD " + ;
			" AND AR1.D_E_L_E_T_ = ' ' " +;
			" WHERE AR2.AR2_FILIAL = ? " + ;
			" AND AR2.AR2_COD = ? " + ;
			" AND AR2.AR2_TITORI = ? " +;
			" AND AR2.AR2_MOV = 'C' " + ;
			" AND AR2.D_E_L_E_T_ = ' ' "

		cQryAnt := ChangeQuery( cQryAnt )
		oQryAnt := FWPreparedStatement():New( cQryAnt )

		For nX := 1 To nLenData

			aConciliation := aClone( aData[nX] )
			lContraVencto := .F.
			lProcBaixa    := .F.
			lProrrog      := .F.
			If lPEBankCon
				lProcBnkEvt := aScan(aBnkEvents, {|x| AllTrim(x) == aConciliation[ BANK_EVENT_TYPE ]} ) == 0
			EndIf

			//------------------------------------------------------------------------------
			// Processa os eventos
			//------------------------------------------------------------------------------
			If lProcBnkEvt

				//------------------------------------------------------------------------------
				// Verifica se é um reprocessamento da conciliação
				//------------------------------------------------------------------------------				
				lDtMovFin  := .T.
				lExistAR4  := .F.
				lSttError  := .F.
				nRecAR4    := 0
				dDataConci := SToD( aConciliation[ BANK_DATE ] )
				If AR4->( MsSeek( cBranchAR4 + aConciliation[ BANK_ENTRY_ID ] ) )
					lExistAR4 := .T.
					nRecAR4   := AR4->( Recno() )
					If AR4->AR4_STATUS == AR4_STT_ERROR //3=Corrigir
						lDtMovFin := Iif(lBxDtFin, DtMovFin( SToD( aConciliation[ BANK_DATE ] ),,"1" ), .T.)  
						lSttError := .T.
					EndIf
				EndIf

				//------------------------------------------------------------------------------
				// Eventos que ficarão como recepcionados no log.
				//------------------------------------------------------------------------------
				If aConciliation[ BANK_EVENT_TYPE ] $ "BXSLDN|CRESUB|DEBFLO|DEBNF|DEBSUB|DEPCLI|ERFSUB|FTLOSS|LRFSUB|PGASUB|RCREDI|SLDAN"
					cRetMessage := " "
					RSKAR4MakeLog( aConciliation, CONCILIATION, cIDAR4, nX, cRetMessage, , nRecAR4 ) // Eventos de divergências comerciais. Precisa confirmar na plataforma Risk.
				ElseIf lExistAR4 .And. lSttError .And. !lDtMovFin
					cRetMessage := I18N( STR0032, { DToC( SToD( aConciliation[ BANK_DATE ] ) ) } )   //"Período do módulo financeiro está fechado para movimentos do dia #1. Verifique os parâmetros MV_DATAFIN e MV_BXDTFIN."
					RSKAR4MakeLog( aConciliation, CONCILIATION, cIDAR4, nX, cRetMessage, , lContraVencto, nRecAR4 ) // Precisa confirmar na plataforma Risk.
				Else
					If aConciliation [ BANK_FUTURE ] == "N"

						nPosInst        := aScan(aInstallments, {|x| x[1] == aConciliation[ BANK_PARCEL ]})
						aConciliation   := aClone( aData[nX] )

						If nPosInst > 0

							If !lExistAR4 .Or. (lExistAR4 .And. lSttError)
								If Len( aBankPart ) == 6
									If PadR( aConciliation[BANK_CODE], nLenBank ) == PadR( aBankPart[BANKJ_CODE], nLenBank ) .And.;
											PadR( aConciliation[BANK_AGENCY], nLenBBranch ) == PadR( aBankPart[BANKJ_AGENCY], nLenBBranch ) .And.;
											PadR( aConciliation[BANK_ACCOUNT], nLenAccount ) == PadR( aBankPart[BANKJ_ACCOUNT], nLenAccount )

										If SA6->( DBSeek( xFilial("SA6") + cBankPart + cBnkPartBch + cBnkPartAcc ) )
											cBankPart	:= SA6->A6_COD
											cBnkPartBch	:= SA6->A6_AGENCIA
											cBnkPartAcc := SA6->A6_NUMCON

											cBank       := SA6->A6_COD
											cBnkBranch  := SA6->A6_AGENCIA
											cBnkAccount := SA6->A6_NUMCON
										EndIf
									EndIf
								EndIf
								If Empty(cBank)
									cBank   := PadR( aConciliation[ BANK_CODE ], nLenBank )
									nStrLen := At( "-", aConciliation[ BANK_AGENCY ] ) - 1

									If nStrLen <= 0
										nStrLen := Len( aConciliation[ BANK_AGENCY] )
									EndIf

									cBnkBranch  := PadR( Substr( aConciliation[ BANK_AGENCY]  , 1, nStrLen ) , nLenBBranch )

									If lBnkAccDig
										cBnkAccount := PadR( StrTran( aConciliation[ BANK_ACCOUNT ], "-", "" ), nLenAccount )
									Else
										nStrLen := At( "-", aConciliation[ BANK_ACCOUNT ] ) - 1

										If nStrLen <= 0
											nStrLen := Len( aConciliation[ BANK_ACCOUNT ] )
										EndIf

										cBnkAccount := PadR( Substr( aConciliation[ BANK_ACCOUNT] , 1, nStrLen ) , nLenAccount )
									EndIf
								EndIf

								cRetMessage := ""
								cObservacao := ""

								If ( cBankPart == cBank .And. cBnkPartBch == cBnkBranch .And. cBnkPartAcc == cBnkAccount )

									If SA6->( MsSeek( xFilial( "SA6" ) + cBank + cBnkBranch + cBnkAccount ) )

										cInstallment := aInstallments[nPosInst][2]

										oQryNFS:SetString( 1, cBranchAR1 )
										oQryNFS:SetString( 2, aConciliation[ BANK_CUST_CNPJ ] )
										oQryNFS:SetString( 3, aConciliation[ BANK_TRANS_CODE ] )
										If lAr2ReqCode
											oQryNFS:SetString( 8, aConciliation[ BANK_REQUEST_CODE ] ) // [39] - Código da Solicitação
											oQryNFS:SetString( 9, " " )
										EndIf

										BEGIN TRANSACTION
											Do Case
												//------------------------------------------------------------------------------
												// Crédito por implantação de faturamento
												//------------------------------------------------------------------------------
											Case aConciliation[ BANK_EVENT_TYPE ] == "IMPL"

												nAmount := 0

												oQryNFS:SetString( 4, "1") 			//1=Principal / 2=Taxa (Realiza a baixas a receber / pagar)
												oQryNFS:SetString( 5, cInstallment) //Caso título seja parcelado
												oQryNFS:SetString( 6, " ") 			//Parcela Unica
												oQryNFS:SetString( 7, "DP")			//Tipo

												cQryNFS := oQryNFS:GetFixQuery()
												MPSysOpenQuery( cQryNFS, cTempNFS )

												If ( cTempNFS )->( !Eof() )
													If "1" <> aConciliation[ BANK_PARCEL ] .And. Empty( (cTempNFS)->AR2_PARC )
														If aScan(aImpError, {|x| x == aConciliation[ BANK_TRANS_CODE ] } ) > 0
															cRetMessage := STR0028 + CRLF +; //"Não foi possível realizar a conciliação automática deste título."
															STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
														EndIf
													Else
														If aConciliation[BANK_ENTRY_TYPE] == "1"
															//------------------------------------------------------------------------------
															// Faz a implantação na primeira parcela
															//------------------------------------------------------------------------------													
															If Empty( (cTempNFS)->AR2_PARC )
																aEval( aData,{| x |  IIF( x[ BANK_TRANS_CODE ] == aConciliation[ BANK_TRANS_CODE ] .And. x[ BANK_EVENT_TYPE ] == aConciliation[ BANK_EVENT_TYPE ], nAmount += x[ BANK_PARC_MAIN ], 0 ) } )
															Else
																nAmount 	  := aConciliation[ BANK_PARC_MAIN ]
																lContraVencto := .T.
															EndIf
															If (cTempNFS)->AR2_VALOR == nAmount
																cRetMessage := RskPayARInv( cTempNFS, cBank, cBnkBranch, cBnkAccount, sTod( aConciliation[ BANK_DATE ] ), nAmount, @cObservacao )
																lProcBaixa  := .T.
															Else
																cRetMessage := STR0001 + CRLF +; //"Não foi possível baixar o recebimento deste título."
																STR0002 + CRLF +; //"Valor de recebimento está divergente."
																STR0025 + cValToChar( (cTempNFS)->AR2_VALOR ) + CRLF +;  //"Valor do título: "
																STR0026 + cValToChar(nAmount) + CRLF +; //"Valor recebido: "
																STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
															EndIf
														Else
															cRetMessage := STR0001 + CRLF +; //"Não foi possível baixar o recebimento deste título."
															STR0004 + CRLF +; //"O tipo do título (pagamento / recebimento) enviado pela Supplier está divergente com o título no financeiro."
															STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
														EndIf
													EndIf
												Else
													cRetMessage := STR0005 + aConciliation[ BANK_TRANS_CODE ] + "." //"Não foi possível implantar a Nota Fiscal Mais Negócio para transação Supplier número: "
												EndIf

												( cTempNFS )->( DBCloseArea() )

												If Empty(cRetMessage) .And. lProcBaixa
													nFeePaid  := 0
													nFeeOri   := 0
													nAntecFee := 0

													oQryNFS:SetString( 4, "2") 			//1=Principal / 2=Taxa (Realiza a baixas a receber / pagar)
													oQryNFS:SetString( 5, cInstallment) //Caso título seja parcelado
													oQryNFS:SetString( 6, " ") 			//Parcela Unica
													oQryNFS:SetString( 7, "MN+")

													cQryNFS := oQryNFS:GetFixQuery()
													MPSysOpenQuery( cQryNFS, cTempNFS )

													If ( cTempNFS )->( !Eof() )														
														lAntecipac := lAr2DataOr .And. !Empty( (cTempNFS)->AR2_DATAOR )
														
														If aConciliation[BANK_ENTRY_TYPE] == "1"
															If Empty( (cTempNFS)->AR2_PARC )
																aEval( aData,{| x |  IIF( x[ BANK_TRANS_CODE ] == aConciliation[ BANK_TRANS_CODE ] .And. x[ BANK_EVENT_TYPE ] == aConciliation[ BANK_EVENT_TYPE ], nFeePaid += x[ BANK_PARC_COST ] , 0 ) } )
															Else
																nFeePaid	  := aConciliation[ BANK_PARC_MAIN ] - Abs( aConciliation[ BANK_ENTRY_VALUE ] )
															EndIf
															nAmount := nFeePaid
															If lAntecipac
																nFeeOri     += (cTempNFS)->AR2_VALOR
																cRetMessage := RskPayAPInv( cTempNFS, cBank, cBnkBranch, cBnkAccount, sTod( aConciliation[ BANK_DATE ] ), nFeeOri, nFeeOri, , @cObservacao )
															ElseIf (cTempNFS)->AR2_VALOR == nAmount
																cRetMessage := RskPayAPInv( cTempNFS, cBank, cBnkBranch, cBnkAccount, sTod( aConciliation[ BANK_DATE ] ), nAmount, nFeePaid, , @cObservacao )
															Else
																cRetMessage := STR0010 + CRLF +; //"Não foi possível baixar o pagamento deste título."
																STR0011 + CRLF +; //"Valor de pagamento está divergente."
																STR0025 + cValToChar( (cTempNFS)->AR2_VALOR ) + CRLF +; //"Valor do título: "
																STR0027 + cValToChar(nAmount) + CRLF +; //"Valor pago: "
																STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
															EndIf
														Else
															cRetMessage := STR0010 + CRLF +; //"Não foi possível baixar o pagamento deste título."
															STR0004 + CRLF +; //"O tipo do título (pagamento / recebimento) enviado pela Supplier está divergente com o título no financeiro."
															STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
														EndIf
														
														//Taxas de Antecipação
														If Empty(cRetMessage) .And. lAntecipac															

															oQryAnt:SetString( 1, (cTempNFS)->AR2_FILIAL )
															oQryAnt:SetString( 2, (cTempNFS)->AR2_COD )
															oQryAnt:SetString( 3, (cTempNFS)->AR2_FILTIT + '|' + (cTempNFS)->AR2_PREFIX + '|' + (cTempNFS)->AR2_NUMTIT + '|' + (cTempNFS)->AR2_PARC + '|' + (cTempNFS)->AR2_TIPO + '|' + (cTempNFS)->AR2_FORNEC + '|' + (cTempNFS)->AR2_LOJFOR )

															cQryAnt := oQryAnt:GetFixQuery()
															MPSysOpenQuery( cQryAnt, cTempAnt )
															If ( cTempAnt )->( !Eof() )
																If Round( nFeeOri + (cTempAnt)->AR2_VALOR, 2 ) == Round( nFeePaid, 2 )
																	nAntecFee   := (cTempAnt)->AR2_VALOR
																	cRetMessage := RskPayAPInv( cTempAnt, cBank, cBnkBranch, cBnkAccount, sTod( aConciliation[ BANK_DATE ] ), nAntecFee, nAntecFee, , @cObservacao )
																Else
																	cRetMessage := STR0035 //"O valor total das taxas baixadas está divergente do valor das taxas informado pela Supplier."
																EndIf
															Else
																cRetMessage := STR0036 //"A taxa de antecipação não foi encontrada."
															EndIf
															
															( cTempAnt )->( DBCloseArea() )															
														EndIf
													ElseIf .Not. lContraVencto
														cRetMessage := STR0005 + aConciliation[ BANK_TRANS_CODE ] + "." //"Não foi possível implantar a Nota Fiscal Mais Negócio para transação Supplier número: "
													EndIf

													( cTempNFS )->( DBCloseArea() )
												EndIf

												If !Empty(cRetMessage)
													If aScan(aImpError, {|x| x == aConciliation[ BANK_TRANS_CODE ] } ) == 0
														AADD(aImpError, aConciliation[ BANK_TRANS_CODE ] )
													EndIf												
												EndIf
												//------------------------------------------------------------------------------
												// Débito por lançamento de bonificação / Taxa por Prorrogação de Vencimentos
												//------------------------------------------------------------------------------
											Case aConciliation[ BANK_EVENT_TYPE ] $ "BONIFI|RPASSP|RPASSI"

												nFeePaid := Abs( aConciliation[ BANK_ENTRY_VALUE ] )

												If aConciliation[ BANK_EVENT_TYPE ] == "BONIFI"
													oQryNFS:SetString( 4, "3") //3=Bonificação
													If EmpTy( aConciliation[ BANK_EXTRAINFO ] )
														nFeePaid := Abs( aConciliation[ BANK_PARC_CALC ] )
													EndIf
												Else
													oQryNFS:SetString( 4, "4" ) //4=Prorrogacao
													lProrrog := .T.
												EndIf

												oQryNFS:SetString( 5, cInstallment) //Caso título seja parcelado
												oQryNFS:SetString( 6, " ") // ou Parcela unica
												oQryNFS:SetString( 7, "MN+")

												cQryNFS := oQryNFS:GetFixQuery()
												MPSysOpenQuery( cQryNFS, cTempNFS )

												nAmount := nFeePaid
												If ( cTempNFS )->( !Eof() )
													If aConciliation[BANK_ENTRY_TYPE] == "2"
														If ( !lProrrog .And. ( cTempNFS )->AR2_VALOR == nAmount ) .Or. ( lProrrog .And. ( cTempNFS )->AR2_VALOR >= nAmount )
															cRetMessage := RskPayAPInv( cTempNFS, cBank, cBnkBranch, cBnkAccount, sTod( aConciliation[ BANK_DATE ] ), nAmount, nFeePaid, aConciliation[ BANK_EVENT_TYPE ], @cObservacao )  
														Else
															cRetMessage := STR0010 + CRLF +; //"Não foi possível baixar o pagamento deste título."
															STR0011 + CRLF +; //"Valor de pagamento está divergente."
															STR0025 + cValToChar( (cTempNFS)->AR2_VALOR ) + CRLF +; //"Valor do título: "
															STR0027 + cValToChar(nAmount) + CRLF +; //"Valor pago: "
															STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
														EndIf
													Else
														cRetMessage := STR0010 + CRLF +; //"Não foi possível baixar o pagamento deste título."
														STR0004 + CRLF +; //"O tipo do título (pagamento / recebimento) enviado pela Supplier está divergente com o título no financeiro."
														STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
													EndIf
												ElseIf nAmount > 0
													If aConciliation[ BANK_EVENT_TYPE ] == "BONIFI"
														cRetMessage := STR0022  //"Não foi possível localizar o evento de bonificação na Nota Fiscal Mais Negócio para transação Supplier número: "
													Else
														cRetMessage := STR0012  //"Não foi possível localizar o evento de prorrogação na Nota Fiscal Mais Negócio para transação Supplier número: "
													EndIf

													cRetMessage += aConciliation[ BANK_TRANS_CODE ] + "."
												EndIf

												( cTempNFS )->( DBCloseArea() )

												//------------------------------------------------------------------------------
												// Débito por cancelamento total
												//------------------------------------------------------------------------------
											Case aConciliation[ BANK_EVENT_TYPE ] == "CANCE"

												aMovType := {"5","A"} //5=Devolução ou A=Cancelamento

												For nMovType := 1 To 2

													nAmount     := aConciliation[ BANK_PARC_MAIN  ]
													nFeePaid    := Abs( aConciliation[ BANK_ENTRY_VALUE ] )

													oQryNFS:SetString( 4, aMovType[nMovType]) //5=Devolução ou A=Cancelamento
													oQryNFS:SetString( 5, cInstallment) //Caso título seja parcelado
													oQryNFS:SetString( 6, " ") // ou Parcela unica
													oQryNFS:SetString( 7, "DP")

													cQryNFS := oQryNFS:GetFixQuery()
													MPSysOpenQuery( cQryNFS, cTempNFS )

													If ( cTempNFS )->( !Eof() )
														If aConciliation[BANK_ENTRY_TYPE] == "2"
															If ( cTempNFS )->AR2_VALOR == nAmount
																cRetMessage := RskPayAPInv( cTempNFS,  cBank, cBnkBranch, cBnkAccount, sTod( aConciliation[ BANK_DATE ] ), nAmount, nFeePaid, @cObservacao )  
																Exit
															Else
																cRetMessage := STR0010 + CRLF +; //"Não foi possível baixar o pagamento deste título."
																STR0011 + CRLF +; //"Valor de pagamento está divergente."
																STR0025 + cValToChar( (cTempNFS)->AR2_VALOR ) + CRLF +; //"Valor do título: "
																STR0027 + cValToChar(nAmount) + CRLF +; //"Valor pago: "
																STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
															EndIf
														Else
															cRetMessage := STR0010 + CRLF +; //"Não foi possível baixar o pagamento deste título."
															STR0004 + CRLF +; //"O tipo do título (pagamento / recebimento) enviado pela Supplier está divergente com o título no financeiro."
															STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
														EndIf
													Else
														cRetMessage := STR0013 + aConciliation[ BANK_TRANS_CODE ] + "."   //"Não foi possível localizar o evento de devolução / cancelamento na Nota Fiscal Mais Negócio para transação Supplier número: "
													EndIf

													( cTempNFS )->( DBCloseArea() )

												Next

												//------------------------------------------------------------------------------
												// Débito por cancelamento parcial.
												//------------------------------------------------------------------------------
											Case aConciliation[ BANK_EVENT_TYPE ] == "CANCEP"

												aMovType := {"5","A"} //5=Devolução ou A=Cancelamento

												For nMovType := 1 To 2

													If EmpTy( aConciliation[ BANK_EXTRAINFO ] )
														nFeePaid := Abs( aConciliation[ BANK_PARC_CALC ] )
													Else
														nFeePaid := Abs( aConciliation[ BANK_ENTRY_VALUE ] )
													EndIf
													nAmount := nFeePaid

													oQryNFS:SetString( 4, aMovType[nMovType]) //5=Devolução ou A=Cancelamento
													oQryNFS:SetString( 5, cInstallment) //Caso título seja parcelado
													oQryNFS:SetString( 6, " ") // ou Parcela unica
													oQryNFS:SetString( 7, "MN-")

													cQryNFS := oQryNFS:GetFixQuery()
													MPSysOpenQuery( cQryNFS, cTempNFS )

													//Pega o valor da taxa MN- bater com saldo título principal.
													If ( cTempNFS )->( !Eof() )
														nAmount += (cTempNFS)->AR2_VALOR
													EndIf

													( cTempNFS )->( DBCloseArea() )

													oQryNFS:SetString( 4, aMovType[nMovType] )
													oQryNFS:SetString( 5, cInstallment) //Caso título seja parcelado
													oQryNFS:SetString( 6, " ") // ou Parcela unica
													oQryNFS:SetString( 7, "DP")

													cQryNFS := oQryNFS:GetFixQuery()
													MPSysOpenQuery( cQryNFS, cTempNFS )

													If ( cTempNFS )->( !Eof() )
														If aConciliation[BANK_ENTRY_TYPE] == "2"
															If ( cTempNFS )->AR2_VALOR == nAmount
																cRetMessage := RskPayAPInv( cTempNFS, cBank, cBnkBranch, cBnkAccount, sTod( aConciliation[ BANK_DATE ] ), nAmount, nFeePaid, @cObservacao )  
																Exit
															Else
																cRetMessage := STR0010 + CRLF +; //"Não foi possível baixar o pagamento deste título."
																STR0011 + CRLF +; //"Valor de pagamento está divergente."
																STR0025 + cValToChar( (cTempNFS)->AR2_VALOR ) + CRLF +; //"Valor do título: "
																STR0027 + cValToChar(nAmount) + CRLF +; //"Valor pago: "
																STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
															EndIf
														Else
															cRetMessage := STR0010 + CRLF +; //"Não foi possível baixar o pagamento deste título."
															STR0004 + CRLF +; //"O tipo do título (pagamento / recebimento) enviado pela Supplier está divergente com o título no financeiro."
															STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
														EndIf
													ElseIf nAmount > 0
														cRetMessage := STR0013 + aConciliation[ BANK_TRANS_CODE ] + "."   //"Não foi possível localizar o evento de devolução / cancelamento na Nota Fiscal Mais Negócio para transação Supplier número: "
													EndIf

													( cTempNFS )->( DBCloseArea() )

												Next

												//------------------------------------------------------------------------------
												// Taxa por Cancelamento de Contrato
												//------------------------------------------------------------------------------
											Case aConciliation[ BANK_EVENT_TYPE ] == "RPASSC"

												aMovType := {"5","A"} //5=Devolução ou A=Cancelamento

												For nMovType := 1 To 2

													If EmpTy( aConciliation[ BANK_EXTRAINFO ] ) .And. aConciliation[ BANK_DEVOL_TYPE ] == 'CANCEP'
														nFeePaid := Abs( aConciliation[ BANK_PARC_CALC ] )
													Else
														nFeePaid := Abs( aConciliation[ BANK_ENTRY_VALUE ] )
													EndIf
													nAmount := nFeePaid

													oQryNFS:SetString( 4, aMovType[nMovType]) //5=Devolução ou A=Cancelamento
													oQryNFS:SetString( 5, cInstallment) //Caso título seja parcelado
													oQryNFS:SetString( 6, " ") // ou Parcela unica
													oQryNFS:SetString( 7, "MN+")

													cQryNFS := oQryNFS:GetFixQuery()
													MPSysOpenQuery( cQryNFS, cTempNFS )

													If ( cTempNFS )->( !Eof() )
														If aConciliation[BANK_ENTRY_TYPE] == "2"
															If ( cTempNFS )->AR2_VALOR == nAmount
																cRetMessage := RskPayAPInv( cTempNFS,  cBank, cBnkBranch, cBnkAccount, sTod( aConciliation[ BANK_DATE ] ), nAmount, nFeePaid, @cObservacao )  
																Exit
															Else
																cRetMessage := STR0010 + CRLF +; //"Não foi possível baixar o pagamento deste título."
																STR0011 + CRLF +; //"Valor de pagamento está divergente."
																STR0025 + cValToChar( (cTempNFS)->AR2_VALOR ) + CRLF +; //"Valor do título: "
																STR0027 + cValToChar(nAmount) + CRLF +; //"Valor pago: "
																STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
															EndIf
														Else
															cRetMessage := STR0010 + CRLF +; //"Não foi possível baixar o pagamento deste título."
															STR0004 + CRLF +; //"O tipo do título (pagamento / recebimento) enviado pela Supplier está divergente com o título no financeiro."
															STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "
														EndIf
													ElseIf nAmount > 0 .And. ( aMovType[nMovType] == "5" .And. AR1->(MSSeek( cBranchAR1 + aConciliation[ BANK_CUST_CNPJ ] + aConciliation[ BANK_TRANS_CODE ] )) .And.;
															AR1->AR1_STATUS <> "4" )
														cRetMessage := STR0014 + aConciliation[ BANK_TRANS_CODE ] + "." //"Não foi possível localizar o evento taxa de cancelamento de contrato na Nota Fiscal Mais Negócio para transação Supplier número: "
													EndIf

													( cTempNFS )->( DBCloseArea() )

												Next

											OtherWise
												cRetMessage := I18N( STR0017, { aConciliation[ BANK_EVENT_TYPE ] } ) + CRLF +;  //"Evento: #1 - Não suportada pela conciliação automática."
												STR0003 + aConciliation[ BANK_TRANS_CODE ] + "." //"Transação Supplier: "

											EndCase

											If !Empty( cRetMessage )
												DisarmTransaction()
											EndIf

										END TRANSACTION
										
										RSKAR4MakeLog( aConciliation, CONCILIATION, cIDAR4, nX, cRetMessage, ,lContraVencto, nRecAR4, cObservacao )

									Else
										RSKAR4MakeLog( aConciliation, CONCILIATION, cIDAR4, nX, I18N( STR0006, { AllTrim(cBank), AllTrim(cBnkBranch), AllTrim(cBnkAccount) } ), , /*lContraVencto*/ , nRecAR4 )    //"Banco: #1 Agência: #2 Conta: #3 não encontrada no cadastro de banco do financeiro."
									EndIf

								Else
									RSKAR4MakeLog( aConciliation, CONCILIATION, cIDAR4, nX, I18N( STR0007, { AllTrim(cBank), AllTrim(cBnkBranch), AllTrim(cBnkAccount) } ), , /*lContraVencto*/ , nRecAR4 )   //"Banco: #1 Agência: #2 Conta: #3 informada pela Supplier não foi relacionada no parâmetro MV_RSKBPAY."
								EndIf
							EndIf
						Else
							RSKAR4MakeLog( aConciliation, CONCILIATION, cIDAR4, nX, STR0018, , /*lContraVencto*/, nRecAR4 ) //"Não foi possível comparar parcela do título enviada pela supplier com a parcela do título cadastrada no financeiro."
						EndIf
					Else
						RSKAR4MakeLog( aConciliation, CONCILIATION, cIDAR4, nX, STR0024 + dToc( sTod( aConciliation[ BANK_DATE ] ) ) )    //"Movimentação financeira será efetuada em: "
					EndIf
				EndIf

			Else
				RSKAR4MakeLog( aConciliation, CONCILIATION, cIDAR4, nX, STR0030, AR4_STT_CUSTOM ) //"Lançamento será tratado por customização..."

				cItemLog    := StrZero( nX, nSizeItem )
				aCustomItem := {cBranchAR4, cIDAR4, cItemLog, aClone( aConciliation ) }
				nPosEvent   := aScan(aCustom, {|x| x[1] == aConciliation[ BANK_EVENT_TYPE ] })

				If nPosEvent == 0
					aAdd(aCustom,{aConciliation[ BANK_EVENT_TYPE ], {aCustomItem} } )
				Else
					aAdd(aCustom[nPosEvent][2],aCustomItem)
				EndIf

			EndIf

			// Realiza a confirmação de leitura do registro na plataforma Risk. Na conciliação serão confirmados todos os registros.
			RSKConfPlat( cHost, nType, {aData[nX]}, lAutomato )
			If aScan( aDtTransf, {|x| (x) == dDataConci} ) == 0
				AADD( aDtTransf, dDataConci )
			EndIf

		Next nX
	EndIf

	If lCtaPonte
		aSort( aDtTransf )
		nQtdDtTran := Len( aDtTransf )
		cIdNatInc  := SuperGetMv("MV_RSKNTTR",,"MNTRANSFCR")  // 1=Receita
		cIdNatExp  := SuperGetMv("MV_RSKNTTD",,"MNTRANSFDB")  // 2=Despesa
		nRecAR4    := 0
		cIDAR4     := RSKAR4IDLog()
		dDataBkp   := dDataBase
		For nY := 1 To nQtdDtTran
			lMsErroAuto := .F.
			cLogMsg     := ""
			cDocTran    := SubStr(StrTran(AllTrim(DToS(Date())) + Alltrim(Str(Seconds())), ".", ""), 3, TamSX3("E5_NUMCHEQ")[1])
			nSldTransf  := RecSalBco( cBank, cBnkBranch, cBnkAccount, aDtTransf[ nY ] )
			If nSldTransf > 0
				dDataBase  := aDtTransf[ nY ]
				aTransfBCO := {	{"CBCOORIG"  , cBank                     ,Nil},;
								{"CAGENORIG" , cBnkBranch                ,Nil},;
								{"CCTAORIG"  , cBnkAccount               ,Nil},;
								{"CNATURORI" , cIdNatExp                 ,Nil},;
								{"CBCODEST"  , cBnkTransf                ,Nil},;
								{"CAGENDEST" , cAgyTransf                ,Nil},;
								{"CCTADEST"  , cAccTransf                ,Nil},;
								{"CNATURDES" , cIdNatInc                 ,Nil},;
								{"CTIPOTRAN" , "R$"                      ,Nil},;
								{"CDOCTRAN"  , cDocTran                  ,Nil},;
								{"NVALORTRAN", nSldTransf                ,Nil},;
								{"CHIST100"  , STR0034				     ,Nil},;
								{"NAGLUTINA" , 2                         ,Nil},; //1=Sim;2=Não
								{"NCTBONLINE", 1                         ,Nil},; //1=Sim;2=Não
								{"DDATACRED" , aDtTransf[ nY ]           ,Nil};
							  }

		        MSExecAuto( { |x,y,z| FinA100(x,y,z) }, 0, aTransfBCO, 7 )

				If lMsErroAuto
					aErroAuto := GetAutoGRLog()
                    If Len(aErroAuto) > 0
                        aEval( aErroAuto, {|x| cLogMsg += x } )
                    EndIf   
					RSKAR4MakeLog( aConciliation, CONCILIATION, cIDAR4, nY, cLogMsg, AR4_STT_ERROR )
				EndIf
			EndIf
		Next
		dDataBase := dDataBkp
	EndIf

	If lPEBankCon .And. !Empty( aCustom )
		ExecBlock("RskBankCon", .F., .F.,{ 2, aCustom })
	EndIf

	RestArea( aArea )
	RestArea( aAreaAR4 )
	RestArea( aAreaSA6 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaAR4 )	
	FWFreeArray( aAreaSA6 )
	FWFreeArray( aConciliation )
	FWFreeArray( aImpError )
	FwFreeArray( aBnkEvents )
	FWFreeArray( aRetPE )
	FWFreeArray( aCustom )
	FWFreeArray( aBankPart )
	FWFreeArray( aInstallments )
	FWFreeArray( aCustomItem )
	FwFreeArray( aMovType )
	FwFreeArray( aDtTransf )
	FwFreeArray( aTransfBCO )
	FwFreeArray( aErroAuto )

	FreeObj( oQryAnt )
	FreeObj( oQryNFS )
	FreeObj( oModel )
Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskPayARInv
Funcao que realiza baixa do título a receber da NFS Mais Negocio.

@param cTempNFS     , caracter  , Area temporaria da NFS
@param cBank        , caracter  , Numero do banco
@param cBnkBranch   , caracter  , Agencia do banco
@param cBnkAccount  , caracter  , Conta bancaria
@param dDateRec     , data      , Data do recebimento
@param nAmountRec   , numerico  , Valor recebido
@param cObservacao  , caracter  , Observacoes na baixa do titulo

@return cRetMessage , caracter, Messagem de retorno para cada evento.

@author Squad NT TechFin
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskPayARInv( cTempNFS, cBank, cBnkBranch, cBnkAccount, dDateRec , nAmountRec, cObservacao )
	Local aArea      := GetArea()
	Local aAreaSE1   := SE1->( GetArea() )
	Local aAutoSE1   := {}
	Local aAltSE1    := {}
	Local aErroAuto  := {}
	Local cRet       := ""
	Local nI         := 0
	Local aParam     := {}
	Local nVlrAdic   := 0
	Local nLenErro   := 0

	Private lMsErroAuto		:= .F.
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.

	SE1->(DBSetOrder(1))    //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->( DBSeek( xFilial("SE1")+( cTempNFS )->AR2_PREFIX + ( cTempNFS )->AR2_NUMTIT +;
			( cTempNFS )->AR2_PARC + ( cTempNFS )->AR2_TIPO ) )

		If nAmountRec == SE1->E1_SALDO
			nVlrAdic := SE1->E1_VALJUR + SE1->E1_PORCJUR + SE1->E1_DESCFIN + SE1->E1_ACRESC + SE1->E1_DECRESC
			If nVlrAdic > 0
				aAltSE1  := {	{ "E1_PREFIXO"  , SE1->E1_PREFIXO          , NIL },; 
								{ "E1_NUM"      , SE1->E1_NUM              , NIL },; 
								{ "E1_PARCELA"  , SE1->E1_PARCELA          , NIL },;
								{ "E1_TIPO"     , SE1->E1_TIPO             , NIL },; 
								{ "E1_VALJUR"   , 0                        , NIL },;
								{ "E1_PORCJUR"  , 0                        , NIL },;
								{ "E1_DESCFIN"  , 0                        , NIL },;
								{ "E1_ACRESC"   , 0                        , NIL },;
								{ "E1_DECRESC"  , 0                        , NIL }}

				MsExecAuto( { |x,y| FINA040( x,y ) } , aAltSE1, 4 )

				If lMsErroAuto
					aErroAuto := GetAutoGRLog()
					nLenErro := Len( aErroAuto )
					For nI := 1 To nLenErro
						cRet += STR0031 + CRLF //"Não foi possível zerar o valor do Juros, Multa, Acréscimo ou Decréscimo informado no título Mais Negócios."
						cRet += aErroAuto[nI]
					Next nI
				EndIf
			EndIf

			If Empty(cRet)
				lMsErroAuto := .F.
				aAutoSE1 :={    { "E1_PREFIXO"	, SE1->E1_PREFIXO	            , Nil	   },;
								{ "E1_NUM"		, SE1->E1_NUM                   , Nil	   },;
								{ "E1_TIPO"		, SE1->E1_TIPO                  , Nil	   },;
								{ "E1_PARCELA"	, SE1->E1_PARCELA 	            , Nil	   },;
								{ "E1_CLIENTE"	, SE1->E1_CLIENTE 	            , Nil 	   },;
								{ "E1_LOJA"		, SE1->E1_LOJA		            , Nil  	   },;
								{ "AUTMOTBX"    , "NOR"                  	    , Nil      },;
								{ "AUTBANCO"    , cBank                 	    , Nil      },;
								{ "AUTAGENCIA"  , cBnkBranch               	    , Nil      },;
								{ "AUTCONTA"    , cBnkAccount           		, Nil      },;
								{ "AUTDTBAIXA"  , dDateRec                      , Nil      },;
								{ "AUTDTCREDITO", dDateRec                      , Nil      },;
								{ "AUTVALREC"   , nAmountRec                    , Nil      },;
								{ "AUTMULTA"    , 0			                    , Nil, .T. },;
								{ "AUTJUROS"    , 0			                    , Nil, .T. },;
								{ "AUTDESCONT"  , 0			                    , Nil, .T. },;
								{ "AUTHIST"     , "Conc. Supplier Ref. NFS: " + ;
								( cTempNFS )->AR1_DOC + " / " + ( cTempNFS )->AR1_SERIE, Nil    }}

				aParam := {'SE1', 'BAIXARECCONC' , aAutoSE1}

				If EXISTBLOCK("RskFinGrv")
					aAutoSE1 := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
				EndIf

				MSExecAuto( {|x,y| FINA070( x, y ) }, aAutoSE1, 3 )

				If lMsErroAuto
					aErroAuto := GetAutoGRLog()
					nLenErro := Len( aErroAuto )					
					For nI := 1 To nLenErro
						cRet += aErroAuto[nI]
					Next nI
				ElseIf ( cTempNFS )->AR2_DATATI <> DToS( dDateRec )
					cObservacao := I18N( STR0033, { DToC( dDateRec ), DToC( SToD( ( cTempNFS )->AR2_DATATI ) ) } ) //"Título baixado com data diferente do agendado na Supplier - Data da Baixa: #1 - Agendamento: #2"
				EndIf
			EndIf
		Else
			cRet := STR0019 + cValtoChar(nAmountRec) //"Saldo do título a receber no financeiro está divergente com valor pago pela Supplier."
		EndIf

	Else
		cRet := STR0029 + xFilial("SE1")+( cTempNFS )->AR2_PREFIX + ( cTempNFS )->AR2_NUMTIT +( cTempNFS )->AR2_PARC + ( cTempNFS )->AR2_TIPO //"Título a receber não localizado no financeiro. Chave: "	
	EndIf

	RestArea( aArea )
	RestArea( aAreaSE1 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aAltSE1 )
	FWFreeArray( aAutoSE1 )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskPayAPInv
Funcao que realiza baixa do título a pagar da NFS Mais Negocio.

@param cTempNFS     , caracter  , Area temporaria da NFS
@param cBank        , caracter  , Numero do banco
@param cBnkBranch   , caracter  , Agencia do banco
@param cBnkAccount  , caracter  , Conta bancaria
@param dDateRec     , data      , Data de pagamento
@param nAmountRec   , numerico  , Valor do título
@param nFeePaid     , numerico  , Valor pago
@param cEventType   , caracter  , Tipo do evento
@param cObservacao  , caracter  , Observacoes na baixa do titulo

@return cRetMessage , caracter, Messagem de retorno para cada evento.

@author Squad NT TechFin
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskPayAPInv( cTempNFS, cBank, cBnkBranch, cBnkAccount, dDatePay, nAmount, nFeePaid, cEventType, cObservacao )
	Local aArea         := GetArea()
	Local aAreaSE2      := SE2->( GetArea() )
	Local aAltSE2       := {}
	Local aAutoSE2      := {}
	Local aErroAuto     := {}
	Local cRet          := ""
	Local nI            := 0
	Local cHistor       := ""
	Local cSupID        := ""
	Local cSupBranch    := ""
	Local aParam        := {}
	Local nVlrAdic      := 0
	Local nLenErro      := 0
	Local lLibTit   	:= SuperGetMV('MV_CTLIPAG', , .F.)
	Local dDataLib  	:= CToD("//")
	Local lProrrog      := .F.

	Private lMsErroAuto		:= .F.
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.

	Default cEventType := ""
	
	lProrrog := cEventType $ "RPASSP|RPASSI"

	If !Empty( ( cTempNFS )->AR2_CLIENTE ) .And. !Empty( ( cTempNFS )->AR2_LOJA )
		cSupID      := ( cTempNFS )->AR2_CLIENTE
		cSupBranch  := ( cTempNFS )->AR2_LOJA
	Else
		cSupID      := ( cTempNFS )->AR2_FORNEC
		cSupBranch  := ( cTempNFS )->AR2_LOJFOR
	EndIf

	SE2->(DBSetOrder(1))    //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	If SE2->(DBSeek(xFilial("SE2") + ( cTempNFS )->AR2_PREFIX + ( cTempNFS )->AR2_NUMTIT+;
			( cTempNFS )->AR2_PARC + ( cTempNFS )->AR2_TIPO + cSupID + cSupBranch ))

		If ( !lProrrog .And. nAmount == SE2->E2_SALDO ) .Or. ( lProrrog .And. nAmount <= SE2->E2_SALDO )			
			nVlrAdic := SE2->E2_VALJUR + SE2->E2_PORCJUR + SE2->E2_ACRESC + SE2->E2_DECRESC
			If nVlrAdic > 0

				dDataLib := IIf(lLibTit, dDatabase, dDataLib)
				aAltSE2  := {	{ "E2_PREFIXO"  , SE2->E2_PREFIXO          , NIL },; 
								{ "E2_NUM"      , SE2->E2_NUM              , NIL },; 
								{ "E2_PARCELA"  , SE2->E2_PARCELA          , NIL },;
								{ "E2_TIPO"     , SE2->E2_TIPO             , NIL },; 
								{ "E2_FORNECE"  , SE2->E2_FORNECE          , NIL },;
								{ "E2_LOJA"     , SE2->E2_LOJA             , NIL },;
								{ "E2_VALJUR"   , 0                        , NIL },;
								{ "E2_PORCJUR"  , 0                        , NIL },;
								{ "E2_ACRESC"   , 0                        , NIL },;
								{ "E2_DECRESC"  , 0                        , NIL },;
								{ "E2_DATALIB"  , dDataLib                 , NIL }}

				MsExecAuto( { |x,y,z| FINA050( x,y,z ) } , aAltSE2, , 4)

				If lMsErroAuto
					aErroAuto := GetAutoGRLog()
					nLenErro := Len( aErroAuto )
					For nI := 1 To nLenErro
						cRet += STR0031 + CRLF //"Não foi possível zerar o valor do Juros, Multa, Acréscimo ou Decréscimo informado no título Mais Negócios."
						cRet += aErroAuto[nI]
					Next nI
				EndIf
			EndIf
			
			If Empty(cRet)
				If lProrrog
					If cEventType == "RPASSI"
						cHistor := "Conc. Supplier IOF NFS: "
					Else
						cHistor := "Conc. Supplier Taxa NFS: "
					EndIf
				Else
					cHistor := "Conc. Supplier Ref. NFS: "
				EndIf

				lMsErroAuto := .F.
				aAutoSE2 := {   { "E2_PREFIXO"	 , SE2->E2_PREFIXO  , Nil },;
								{ "E2_NUM"		 , SE2->E2_NUM	    , Nil },;
								{ "E2_PARCELA"	 , SE2->E2_PARCELA  , Nil },;
								{ "E2_TIPO"		 , SE2->E2_TIPO	    , Nil },;
								{ "E2_FORNECE"	 , SE2->E2_FORNECE  , Nil },;
								{ "E2_LOJA"		 , SE2->E2_LOJA	    , Nil },;
								{ "AUTMOTBX"     , "DEB"            , Nil },;
								{ "AUTDTBAIXA"   , dDatePay         , Nil },;
								{ "AUTDTDEB"     , dDatePay         , Nil },;
								{ "AUTBANCO"     , cBank            , Nil },;
								{ "AUTAGENCIA"   , cBnkBranch       , Nil },;
								{ "AUTCONTA"     , cBnkAccount      , Nil },;
								{ "AUTVLRPG"     , nFeePaid         , Nil },;
								{ "AUTMULTA"     , 0			    , Nil },;
								{ "AUTJUROS"     , 0			    , Nil },;
								{ "AUTDESCONT"   , 0			    , Nil },;
								{ "AUTHIST"   	 , cHistor + ( cTempNFS )->AR1_DOC + " / " + ( cTempNFS )->AR1_SERIE  , Nil } }

				aParam := {'SE2', 'BAIXAPGCONC' , aAutoSE2}
				
				If EXISTBLOCK("RskFinGrv")
					aAutoSE2 := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
				EndIf

				MSExecAuto( {|x,y| FINA080( x,y ) }, aAutoSE2, 3 )

				If lMsErroAuto
					aErroAuto := GetAutoGRLog()
					nLenErro := Len( aErroAuto )
					For nI := 1 To nLenErro
						cRet += aErroAuto[nI]
					Next nI
				ElseIf ( cTempNFS )->AR2_DATATI <> DToS( dDatePay )
					cObservacao := I18N( STR0033, { DToC( dDatePay ), DToC( SToD( ( cTempNFS )->AR2_DATATI ) ) } ) //"Título baixado com data diferente do agendado na Supplier - Data da Baixa: #1 - Agendamento: #2"
				EndIf				
			EndIf
		Else
			cRet := STR0021 + cValToChar(nAmount) //"Saldo do título a pagar no financeiro está divergente com valor recebido pela Supplier."
		EndIf
	Else
		cRet := STR0020 + xFilial("SE2") + ( cTempNFS )->AR2_PREFIX + ( cTempNFS )->AR2_NUMTIT + ( cTempNFS )->AR2_PARC + ( cTempNFS )->AR2_TIPO + cSupID + cSupBranch  //"Título a pagar não localizado no financeiro. Chave"
	EndIf

	RestArea( aArea )
	RestArea( aAreaSE2 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE2 )
	FWFreeArray( aAltSE2 )
	FWFreeArray( aAutoSE2 )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
Return cRet
