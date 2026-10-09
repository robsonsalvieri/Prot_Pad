#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RSKDefs.ch"    
#INCLUDE "RSKA030.CH"

Static cErrorMsg := ""  
  
//-------------------------------------
/*/{Protheus.doc}  RSKDesdobr
Baixa titulos do cliente e gera titulos em nome da supplier

@param 		aDocumentos: 	Array de documentos com a seguinte estrutura
							aDocumentos[x][1]: Filial do documento
							aDocumentos[x][2]: Numero do documento
							aDocumentos[x][3]: id
							aDocumentos[x][4]: Codigo do Retorno
							aDocumentos[x][5]: Mensagem do Retorno
							aDocumentos[x][6]: Codigo da transacao
							aDocumentos[x][7]: Boleto em base64
							aDocumentos[x][8]: Valor total de taxas
							aDocumentos[x][9]: Valor total das parcelas
							aDocumentos[x][10]: Data de pagamento
							aDocumentos[x][11][y],[1]: Numero da parcela 
							aDocumentos[x][11][y],[2]: Data de vencimento da parcela
							aDocumentos[x][11][y],[3]: Valor da parcela
							aDocumentos[x][11][y],[4]: Valor de recebimento parceiro
							aDocumentos[x][11][y],[5]: Data de recebimento parceiro
							aDocumentos[x][11][y],[6]: Id tipo de taxa
							aDocumentos[x][11][y],[7]: Tipo de taxa Parcela
							aDocumentos[x][11][y],[8]: Valor da taxa Parcela
							aDocumentos[x][11][y],[9]: Valor da taxa da parcela em reais
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return 	Logico, Informa se os titulos foram baixados
@author 	jose.delmondes
@since  	25/05/2020 
@version	P12
/*/
//-------------------------------------
Function RSKDesdobr( aDocumentos As Array, lAutomato As Logical ,cHost As Character, nType As Numeric ) 
	Local aArea		    As Array
	Local aTitulos	    As Array
	Local aItem 	    As Array
	Local lContinue     As Logical
	Local nX 		    As Numeric
	Local nY 		    As Numeric
	Local nTaxas	    As Numeric
	Local nValTit	    As Numeric
	Local cFilDoc	    As Character
	Local cDoc 		    As Character
	Local cCodRet	    As Character
	Local cMsgRet	    As Character
	Local cNFStatus	    As Character
	Local cCmdInv	    As Character
	Local cIdTransP	    As Character
	Local cBoleto	    As Character
	Local dDataVenc	    As Date
	Local oModel	    As Object
	Local oMdlAR1	    As Object
	Local aErrorMd	    As Array
	Local cFilSE2 	    As Character
	Local cNumSE2	    As Character
	Local cParcDef	    As Character
	Local cHist		    As Character
	Local cIdNatInc	    As Character
	Local cIdNatExp	    As Character
	Local lUnfolding    As Logical
	Local aRecSE1Ori    As Array
	Local nQtdVend      As Numeric
	Local nQtdParcelas  As Numeric
	Local cSE1Enum	    As Character
	Local cParDef 	    As Character
	Local cDefaultParc  As Character

	Default lAutomato := .F.

	aArea		 := GetArea() 
	aTitulos	 := {}
	aItem 		 := {}
	lContinue 	 := .T.
	nX 			 := 0
	nY 			 := 0
	nTaxas		 := 0  
	nValTit		 := 0
	cFilDoc		 := ""
	cDoc 		 := ""  
	cCodRet		 := ""
	cMsgRet		 := ""
	cNFStatus	 := ""
	cCmdInv		 := ""
	cIdTransP	 := ""
	cBoleto		 := ""
	dDataVenc	 := cTod("//")
	oModel		 := Nil  
	oMdlAR1		 := Nil 
	aErrorMd	 := {}
	cFilSE2 	 := xFilial( "SE2" )
	cNumSE2		 := ""
	cParcDef	 := "" //Caso haja mais de uma parcela utilizar o parametro MV_1DUP
	cHist		 := ""
	cIdNatInc	 := RskSeekNature( INCOME_NATURE )		// 1=Receita            
	cIdNatExp	 := RskSeekNature( EXPENSE_NATURE )		// 2=Despesa
	lUnfolding   := SuperGetMv( "MV_RSKDESD", , .T. )    
	aRecSE1Ori   := {}
	nQtdVend  	 := fa440CntVen()
	nQtdParcelas := 0
	cSE1Enum	 := ""
	cParDef 	 := ""
	cDefaultParc := SuperGetMv("MV_1DUP",.F.,"1")

	DBSelectArea( 'AR1' )
	DBSetOrder(1)	//AR1_FILIAL+AR1_COD

	For nX := 1 To Len( aDocumentos )
		lContinue 	:= .T.
		cNFStatus	:= " "
		cErrorMsg 	:= " "
		aRecSE1Ori  := {}
		cFilDoc		:= aDocumentos[nX][ UPD_I_BRANCH ]		// [1]-filial
		cDoc 		:= aDocumentos[nX][ UPD_I_INVOICE ]		// [2]-numero do documento
		cCmdInv		:= aDocumentos[nX][ UPD_I_INVOICEID ]	// [3]-id da fatura  
		cCodRet		:= aDocumentos[nX][ UPD_I_RETURN ]		// [4]-codigo do retorno  
		cMsgRet		:= aDocumentos[nX][ UPD_I_MESSAGE ]		// [5]-mensagem do retorno
		cIdTransP	:= aDocumentos[nX][ UPD_I_TRANSACTION ]	// [6]-codigo da transação  

		aTitulos := {}

		If AR1->( DBSeek( xFilial( 'AR1' ) + cDoc ) ) 
			If AR1->AR1_STATUS != AR1_STT_APPROVED // 2=Aprovada
				If cCodRet == "000"                                                                        
				
					BEGIN TRANSACTION
						cBoleto   := aDocumentos[nX][ UPD_I_BANKSLIP ]				// [7]-boleto em base64  
						nTaxas 	  := aDocumentos[nX][ UPD_I_TOTAL_FEE ]				// [8]-valor total das taxas  
						nValTit	  := aDocumentos[nX][ UPD_I_TOTAL_PARC ] + nTaxas	// [9]-valor total das parcelas 
						dDataVenc := SToD( aDocumentos[nX][ UPD_I_RECEIPT_DT ] )	// [10]-data recebimento parceiro 
						cHist	  := "Mais Neg. NFS: " + alltrim(AR1->AR1_DOC) + " / " + alltrim(AR1->AR1_SERIE)      

						cSE1Enum := ProxTitulo( "SE1", "OFF" )

						If lUnfolding 
							lContinue := RSKBaixa( AR1->AR1_FILNF, AR1->AR1_PREFIX, AR1->AR1_DOC, 'NF', AR1->AR1_COD , @aRecSE1Ori, AR1->AR1_CONDPG, cSE1Enum, 'OFF'  )
						EndIf

						If lContinue .And. lUnfolding

							If aDocumentos[nX][UPD_I_ISSUERTYPE] == '2' // [13]-tipo de recibo do emissor
								cParDef	 	 := cDefaultParc
								nQtdParcelas := Len( aDocumentos[nX][ UPD_I_PARCELS ] )

								For nY := 01 To nQtdParcelas
									dDataVenc := SToD(aDocumentos[nX][UPD_I_PARCELS][nY][PARCEL_AMOUNTDT]) // [5]-Data de recebimento parceiro
									nValTit	  := aDocumentos[nX][UPD_I_PARCELS][nY][PARCEL_RECAMOUNT] + aDocumentos[nX][UPD_I_PARCELS][nY][PARCEL_RSVALUE] // [4]-Valor de recebimento parceiro + [9]-Valor da taxa da parcela em reais
									aItem     := RSKPrinc( AR1->AR1_FILNF, AR1->AR1_PREFIX, AR1->AR1_DOC, 'NF', nValTit, dDataVenc, cHist, cIdNatInc, { aRecSE1Ori[nY] }, nQtdVend, cSE1Enum, cParDef )
									If Len( aItem ) > 0
										aAdd( aTitulos, aItem )   
									Else 
										lContinue := .F.
										nY 		  := nQtdParcelas
									EndIf
									cParDef	:= MAParcela(cParDef)
								Next

							Else
								aItem := RSKPrinc( AR1->AR1_FILNF, AR1->AR1_PREFIX, AR1->AR1_DOC, 'NF', nValTit, dDataVenc, cHist, cIdNatInc, aRecSE1Ori, nQtdVend, cSE1Enum, cParDef )
								If Len( aItem ) > 0
									aAdd( aTitulos, aItem )   
								Else 
									lContinue := .F. 
								EndIf
							EndIf
						EndIf

						If lContinue .And. lUnfolding .And. nTaxas > 0
							cNumSE2 := ProxTitulo( "SE2", "OFF" )
							
							If aDocumentos[nX][UPD_I_ISSUERTYPE] == '2' // [13]-tipo de recibo do emissor
								cParcDef	 := cDefaultParc
								nQtdParcelas := Len( aDocumentos[nX][ UPD_I_PARCELS ] )

								For nY := 01 To nQtdParcelas
									dDataVenc := SToD(aDocumentos[nX][UPD_I_PARCELS][nY][PARCEL_AMOUNTDT]) // [5]-Data de recebimento parceiro
									nTaxas	  := aDocumentos[nX][UPD_I_PARCELS][nY][PARCEL_RSVALUE] 	   // [9]-Valor da taxa da parcela em reais
									aItem	  := RSKTaxa( cFilSE2, "OFF", cNumSE2, cParcDef, "MN+", nTaxas, dDataVenc, cHist, cIdNatExp )    
									If Len( aItem ) > 0
										aAdd( aTitulos, aItem )   
									Else 
										lContinue := .F.
										nY 		  := nQtdParcelas
									EndIf
									cParcDef := MAParcela(cParcDef)
								Next

							Else						
								aItem	:= RSKTaxa( cFilSE2, "OFF", cNumSE2, cParcDef, "MN+", nTaxas, dDataVenc, cHist, cIdNatExp )    
								If Len( aItem ) > 0
									aAdd( aTitulos, aItem )    
								Else 
									lContinue := .F.
								EndIf 
							EndIf
						EndIf
						
						If lContinue
							lContinue := RskNFSMovFin( aDocumentos[nX] , aTitulos )
							If !lContinue
								cErrorMsg := STR0006 // "Movimentos Financeiros da nota não foram gerados na AR2." 
							EndIf
						EndIf
						
						If lContinue
							lContinue := RSKGrvBol( cBoleto, AR1->AR1_COD )
							If !lContinue
								cErrorMsg := STR0007 // "Boleto da nota não foi gerado."
							EndIf
						EndIf

						If lContinue
							cNFStatus	:= AR1_STT_APPROVED		// 2=Aprovado  
						Else
							DisarmTransaction()  
							cNFStatus	:= AR1_STT_FLIMSY 	// 5=Inconsistencia no processamento do Erp.
						EndIf

					END TRANSACTION
				Else
					cNFStatus := AR1_STT_REJECTED	// 3=Rejeitada
					cErrorMsg := STR0005 // "Nota retornou Rejeitada da Supplier."
				EndIf

				oModel := FwLoadModel( "RSKA020" ) 
				oModel:SetOperation( MODEL_OPERATION_UPDATE )
				oModel:Activate()   

				If oModel:IsActive() 
					oMdlAR1 := oModel:GetModel( "AR1MASTER" )  
					
					oMdlAR1:SetValue( "AR1_STATUS", cNFStatus )   
					oMdlAR1:SetValue( "AR1_TCKTRA", cIdTransP ) 
					oMdlAR1:SetValue( "AR1_CMDINV", cCmdInv )
					
					If cNFStatus != AR1_STT_FLIMSY
						oMdlAR1:SetValue( "AR1_STARSK", STARSK_RECEIVED )  // 3=Recebido
						oMdlAR1:SetValue( "AR1_OBSPAR", cMsgRet + If(!Empty(cErrorMsg), " " + cErrorMsg, "") )
					Else
						oMdlAR1:SetValue( "AR1_OBSPAR" , STR0001 + Chr(10) + cErrorMsg + Chr(10) + STR0002 )	//"Não foi possível realizar as movimentações financeiras para este documento de saída."###"***** Será realizado uma nova tentativa *****"
					EndIf
					
					oMdlAR1:SetValue( "AR1_DTAVAL" , FWTimeStamp( 1, Date(), Time() ) )
					
					If oModel:VldData()
						oModel:CommitData() 
						If lContinue 
							RSKConfPlat( cHost, nType, {aDocumentos[nX]}, lAutomato )
						EndIf
					Else
						aErrorMd := oModel:GetErrorMessage()
						LogMsg( "RSKDesdobr", 23, 6, 1,"", "", "RSKDesdobr -> " + aErrorMd[6] )
					EndIf  
				EndIf
			Else
				RSKConfPlat( cHost, nType, {aDocumentos[nX]}, lAutomato ) 
			EndIf
		EndIf
	Next nX

	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aTitulos )
	FWFreeArray( aItem )
	FWFreeArray( aErrorMd )
	FWFreeArray( aRecSE1Ori )
	FreeObj( oModel )
	FreeObj( oMdlAR1 )  
Return Nil

//-------------------------------------
/*/{Protheus.doc}  AR1Baixa
Baixa titulos a receber em nome do cliente

@param 		cFilOrig: Filial do documento
@param 		cPrefixo: Prefixo do titulo
@param 		cNum: Numero do titulo
@param 		cTipo: Tipo do titulo
@param 		cCod: Código de identificação da NFS Mais Negócios
@param 		@aRecSE1Ori, recebe o array para o preenchimento dos recnos das parcelas dos títulos originais
@param 		cCondPgto, condição de pagamento da nota fiscal
@param      cSE1Enum, Proximo numero prefixo OFF
@param      cSE1Pref, Prefixo OFF
@return 	Logico, Informa se os titulos foram baixados
@author 	jose.delmondes
@since  	25/05/2020
@version	P12
/*/
//-------------------------------------
Static Function RSKBaixa( cFilOrig As Character, cPrefixo As Character, cNum As Character, cTipo As Character, cCod As Character, aRecSE1Ori As Numeric, cCondPgto As Character, cSE1Num As Character, cSE1Pref As Character ) As Logical
	Local aArea				As Array
	Local aAreaSE1			As Array
	Local aBaixa 			As Array
	Local cAliasQry 		As Character
	Local aErroAuto			As Array
	Local nI 				As Numeric
	Local cError			As Character
	Local lRet 				As Logical
	Local aParam 			As Array
	Local lFirstInstallment As Logical
	Local lRskPedAdt        As Logical
	Local lPEFinGrv         As Logical

	Private lMsErroAuto	   As Logical
	Private lAutoErrNoFile As Logical
	Private lMsHelpAuto    As Logical

	aArea			  := GetArea()
	aAreaSE1		  := SE1->( GetArea() )
	aBaixa 			  := {}
	cAliasQry 		  := GetNextAlias()
	aErroAuto		  := {}
	nI 				  := 0
	cError			  := ""
	lRet 			  := .T.
	aParam 			  := {}
	lFirstInstallment := .T.
	lRskPedAdt        := RskPedAdt(cCondPgto)
	lPEFinGrv         := EXISTBLOCK("RskFinGrv")

	lMsErroAuto		:= .F. 
	lAutoErrNoFile	:= .T.
	lMsHelpAuto   	:= .T.	

	BeginSQL Alias cAliasQry

		SELECT	E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_NATUREZ,E1_VALOR, R_E_C_N_O_ 
		FROM 	%Table:SE1% SE1
		WHERE	SE1.%NotDel% AND
				SE1.E1_FILORIG = %Exp:cFilOrig% AND
				SE1.E1_PREFIXO = %Exp:cPrefixo% AND
				SE1.E1_NUM = %Exp:cNum% AND
				SE1.E1_TIPO = %Exp:cTipo%
		ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	EndSQL

	While ( cAliasQry )->( !EOF() )	   
		//------------------------------------------------------------------------
		// Condição de pagamento com Adiantamento não deve baixar a primeira parcela
		//------------------------------------------------------------------------
		If lFirstInstallment .And. lRskPedAdt
			lFirstInstallment := .F.
			( cAliasQry )->( DbSkip() )
			Loop
		EndIf

		aBaixa :={	{ "E1_PREFIXO"	, cPrefixo					,Nil	 },;
					{ "E1_NUM"		, cNum						,Nil	 },;
					{ "E1_TIPO"		, cTipo						,Nil	 },;
					{ "E1_PARCELA"	, ( cAliasQry )->E1_PARCELA	,Nil	 },;
					{ "E1_CLIENTE"	, ( cAliasQry )->E1_CLIENTE	,Nil	 },;
					{ "E1_LOJA"		, ( cAliasQry )->E1_LOJA	,Nil	 },;
					{ "E1_NATUREZ"	, ( cAliasQry )->E1_NATUREZ	,Nil	 },;
					{ "AUTMOTBX"    , "OFF"                  	,Nil     },;
					{ "AUTDTBAIXA"  , dDataBase              	,Nil     },;
					{ "AUTDTCREDITO", dDataBase              	,Nil     },;
					{ "AUTHIST"     , STR0003			    	,Nil     },; //"Baixa Supplier-OFF"
					{ "AUTVALREC"   , ( cAliasQry )->E1_VALOR   ,Nil     }}

		aParam := {'SE1', 'BAIXACLI' , aBaixa}

		IF lPEFinGrv
			aBaixa := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
		ENDIF		
					
		MSExecAuto( { |x,y| Fina070( x, y ) }, aBaixa, 3 )	 

		If lMsErroAuto
			lRet := .F.
			aErroAuto := GetAutoGRLog()
			For nI := 1 To Len( aErroAuto ) 
				cError += aErroAuto[nI]
			Next nI
			LogMsg( "RSKBaixa", 23, 6, 1, "", "", "RSKBaixa -> " + cError )
			cErrorMsg := cError
			Exit
		Else
			SE1->(dbgoto(( cAliasQry )->R_E_C_N_O_))

			RECLOCK("SE1", .F.)
				SE1->E1_HIST := "Baixa NF Mais Neg.: " +  Alltrim(cSE1Num) + " / " + AllTrim(cSE1Pref)
			MSUNLOCK()

			AADD( aRecSE1Ori, ( cAliasQry )->R_E_C_N_O_ )
		EndIf

		( cAliasQry )->( dbSkip() )
	EndDo

	( cAliasQry )->( dbCloseArea() )

	RestArea( aArea )
	RestArea( aAreaSE1 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aBaixa )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
Return lRet

//-------------------------------------
/*/{Protheus.doc} RSKPrinc
Gera titulo principal (a receber) da Supplier

@param cFilOrig: Filial do documento
@param cPrefixo: Prefixo do titulo Original
@param cNum: Numero do titulo Original
@param cTipo: Tipo do titulo Original
@param nValor: Valor do titulo
@param dDataVenc: Venciemento
@param cHist: Historico
@param cNatureza: Código da Natureza (Receita)
@param aRecSE1Ori: recnos das parcelas dos títulos a receber em nome do cliente
@param nQtdVend: Quantidade de vendedores
@param cSE1Enum: Número do Título a Receber
@param cParDef: Parcela do Título a Receber

@return	array, títulos gerados
	[1]-tipo do título gerado, sendo 1=título principal ou 2=título de taxas
	[2]-filial
	[3]-prefixo do documento
	[4]-numero do titulo
	[5]-parcela do título
	[6]-tipo do título
	[7]-código do cliente
	[8]-loja do cliente
	[9]-valor do título
	[10]-data de vencimento do título

@author  jose.delmondes
@since   25/05/2020
@version P12
/*/
//-------------------------------------
Static Function RSKPrinc( cFilOrig As Character, cPrefixo As Character, cNum As Character, cTipo As Character, nValor As Numeric, dDataVenc As Date, cHist As Character, cNatureza As Character, aRecSE1Ori As Array, nQtdVend As Numeric, cSE1Enum As Character, cParDef AS Character ) As Array
	Local aArea 	As Array
	Local aAreaSE1 	As Array
	Local aAreaSA3 	As Array
	Local aTitulo 	As Array
	Local aRet 		As Array
	Local cCliente	As Character
	Local cLoja 	As Character
	Local lContinua As Logical
	Local aErroAuto	As Array
	Local cError 	As Character
	Local nI 		As Numeric
	Local dEmissao	AS Date
	Local cPrefDef	As Character
	Local cTipDef	As Character
	Local aParam 	As Array
	Local nCntVen   As Numeric
	Local cNumVend	As Character
	Local nSumRecno As Numeric
	Local nX        As Numeric
	Local nBaseCom  As Numeric
	Local nPosBaseC As Numeric
	Local aBasComAl As Array
	Local nPosComis As Numeric

	Private lMsErroAuto	   As Logical
	Private lAutoErrNoFile As Logical
	Private lMsHelpAuto    As Logical

	aArea 	  := GetArea()
	aAreaSE1  := SE1->(GetArea())
	aAreaSA3  := SA3->(GetArea())
	aTitulo   := {}
	aRet 	  := {}
	cCliente  := SuperGetMV( "MV_RSKCPAY", .T., "" )
	cLoja 	  := ''
	lContinua := .T.
	aErroAuto := {}
	cError 	  := ""
	nI 		  := 0
	dEmissao  := cTod("//")
	cPrefDef  := "OFF"
	cTipDef	  := "DP"
	aParam 	  := {}
	nCntVen   := 0
	cNumVend  := ""
	nSumRecno := Len( aRecSE1Ori )
	nX        := 01
	nBaseCom  := 0
	nPosBaseC := 0
	aBasComAl := {}
	nPosComis := 0

	lMsErroAuto	   := .F. 
	lAutoErrNoFile := .T.
	lMsHelpAuto    := .T.	

	If !Empty( cCliente )
		cLoja 		:= SubStr( cCliente, TamSX3( 'A1_COD' )[1] + 2, TamSX3( 'A1_LOJA' )[1] )
		cCliente	:= SubStr( cCliente, 1, TamSX3( 'A1_COD' )[1] )
	Else
		lContinua := .F.
	EndIf 

	If lContinua
		dEmissao := IIF( dDatabase > dDataVenc, dDataVenc, dDatabase )
		
		aTitulo  := {{ "E1_PREFIXO"  , cPrefDef        			, Nil },;
					 { "E1_NUM"      , cSE1Enum        			, Nil },;
					 { "E1_PARCELA"  , cParDef					, Nil },;
					 { "E1_TIPO"     , cTipDef         			, Nil },;
					 { "E1_NATUREZ"  , cNatureza				, Nil },;
					 { "E1_CLIENTE"  , cCliente          		, Nil },;
					 { "E1_LOJA"     , cLoja              		, Nil },;
					 { "E1_EMISSAO"  , dEmissao					, Nil },;
					 { "E1_VENCTO"   , dDataVenc				, Nil },;
					 { "E1_VENCREA"  , dDataVenc				, Nil },;
					 { "E1_HIST"     , cHist             		, Nil },;
					 { "E1_BOLETO"   , "2" 	            		, Nil },;					
					 { "E1_VALOR"    , nValor             		, Nil }}
		
		If nSumRecno > 0 
			For nX := 01 To nSumRecno
				SE1->( DbGoTo( aRecSE1Ori[nX] ) )
				For nCntVen := 01 To nQtdVend
					If nCntVen > 9
						cNumVend := RetAsc( nCntVen, 1, .T. )
					Else
						cNumVend := cValToChar(nCntVen)
					EndIf
					If Posicione("SA3", 1, xFilial("SA3") + &("SE1->E1_VEND" + cNumVend), "A3_ALBAIXA") == 100 
						nBaseCom := SE1->(FieldGet(SE1->(FieldPos("E1_BASCOM" + cNumVend))))
						If nBaseCom > 0
							nPosBaseC := aScan( aTitulo, { |x| x[1] == "E1_BASCOM" + cNumVend } )
							If nPosBaseC == 0
								aAdd(aTitulo, {"E1_VEND" + cNumVend, SE1->(FieldGet(SE1->(FieldPos("E1_VEND" + cNumVend)))), Nil})
								aAdd(aTitulo, {"E1_COMIS" + cNumVend, SE1->(FieldGet(SE1->(FieldPos("E1_COMIS" + cNumVend)))), Nil})
								aAdd(aTitulo, {"E1_BASCOM" + cNumVend, nBaseCom, Nil})
								nPosBaseC := Len( aTitulo )
							Else
								aTitulo[nPosBaseC][02] += nBaseCom
							EndIf
							nPosComis := aScan( aBasComAl, { |x| x[1] == "E1_BASCOM" + cNumVend } )
							If nPosComis == 0
								AADD( aBasComAl, { aTitulo[ nPosBaseC ][ 01 ], nBaseCom } )
							Else
								aBasComAl[nPosComis][02] += nBaseCom
							EndIf
						EndIf
					EndIf
				Next nCntVen
			Next
		EndIf

		aParam := {'SE1', 'INCTITSUPP' , aTitulo}

		IF EXISTBLOCK("RskFinGrv")
			aTitulo := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
		ENDIF   

		MsExecAuto( { |x,y| FINA040( x, y ) } , aTitulo, 3 )   

		If !lMsErroAuto
			aRet := { BILL_MAIN, cFilAnt, cPrefDef, cSE1Enum, cParDef, cTipDef, cCliente, cLoja, nValor, dDataVenc }	// 1=Título principal
			// Acertar a base de cálculo da Comissão, de acordo com o título original.
			If Len( aBasComAl ) > 0 
				RecLock( "SE1", .F. )
				For nCntVen := 01 To Len( aBasComAl )
					&( "SE1->" + aBasComAl[ nCntVen ][ 01 ] ) := aBasComAl[ nCntVen ][ 02 ]
				Next
				SE1->( MsUnLock() )
			EndIf
		Else
			aErroAuto := GetAutoGRLog()
			For nI := 1 To Len( aErroAuto )
				cError += aErroAuto[nI] 
			Next nI
			LogMsg( "RSKPrinc", 23, 6, 1, "", "", "RSKPrinc -> " + cError )
			cErrorMsg := cError	
		EndIf
	EndIf

	RestArea( aAreaSE1 )
	RestArea( aAreaSA3 )
	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aAreaSA3 )
	FWFreeArray( aTitulo )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
	FWFreeArray( aBasComAl )
Return aRet

//-------------------------------------
/*/{Protheus.doc} RSKTaxa
Gera os títulos de taxas (a pagar) para a Supplier

@param 		cFilOrig: Filial do documento
@param 		cPrefixo: Prefixo do titulo
@param 		cNum: Numero do titulo
@param 		cParcela: Parcela do titulo
@param 		cTipo: Tipo do titulo
@param 		nValor: Valor das taxas
@param 		dDataVenc: Vencimento
@param 		cHist: Historico
@param		cNatureza : Código da Natureza (Despesa)

@return 	array, títulos gerados, onde:
	[1]-tipo do título gerado, sendo 1=título principal ou 2=título de taxas
	[2]-filial
	[3]-prefixo do documento
	[4]-numero do titulo
	[5]-parcela do título
	[6]-tipo do título
	[7]-código do cliente
	[8]-loja do cliente
	[9]-valor do título
	[10]-data de vencimento do título

@author 	jose.delmondes
@since  	25/05/2020
@version	P12
/*/
//-------------------------------------
Function RSKTaxa( cFilOrig, cPrefixo, cNum, cParcela, cTipo, nValor, dDataVenc, cHist, cNatureza )
	Local aArea 	:= GetArea()
	Local aTitulo 	:= {}
	Local aRet 		:= {}
	Local cAliasQry := GetNextAlias()
	Local cCliente	:= SuperGetMV( "MV_RSKCPAY", .T., "" )
	Local cLoja 	:= ''
	Local lContinua := .T.
	Local aErroAuto	:= {}
	Local cError 	:= ""
	Local nI 		:= 0 
	Local dEmissao	:= cTod("//")
	Local aParam 	:= {}
	Local lLibTit 	:= SuperGetMV('MV_CTLIPAG', , .F.)
	Local dDataLib	:= CToD("//")

	Private lMsErroAuto		:= .F. 
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.	

	If !Empty( cCliente )
		cLoja 		:= SubStr( cCliente, TamSX3( 'A1_COD' )[1] + 2, TamSX3( 'A1_LOJA' )[1] )
		cCliente 	:= SubStr( cCliente, 1, TamSX3( 'A1_COD' )[1] )
	Else
		lContinua	:= .F.
	EndIf
	
	If lContinua
		
		BeginSQL Alias cAliasQry

			SELECT	A2_COD, A2_LOJA  
			FROM 	%Table:SA2% SA2
			WHERE	SA2.%NotDel% AND
					SA2.A2_FILIAL  = %Exp:xFilial( "SA2", cFilOrig )% AND
					SA2.A2_CLIENTE = %Exp:cCliente% AND
					SA2.A2_LOJCLI  = %Exp:cLoja%
		EndSQL

		If ( cAliasQry )->( !Eof() )	
			dEmissao := IIF( dDatabase > dDataVenc, dDataVenc, dDatabase )
			dDataLib := IIf(lLibTit, dDatabase, dDataLib)
			
			aTitulo  := {{ "E2_PREFIXO" , cPrefixo          		, NIL },; 
						 { "E2_NUM"      , cNum        				, NIL },; 
						 { "E2_PARCELA"  , cParcela            		, NIL },;
						 { "E2_TIPO"     , cTipo            		, NIL },; 
						 { "E2_NATUREZ"  , cNatureza				, NIL },;
						 { "E2_FORNECE"  , ( cAliasQry )->A2_COD    , NIL },;
						 { "E2_LOJA"     , ( cAliasQry )->A2_LOJA   , NIL },;
						 { "E2_HIST"     , cHist	            	, Nil },;  
						 { "E2_EMISSAO"  , dEmissao					, NIL },;
						 { "E2_VENCTO"   , dDataVenc				, NIL },;
						 { "E2_VENCREA"  , dDataVenc				, NIL },;
						 { "E2_VALOR"    , nValor             		, NIL },;
						 { "E2_DATALIB"  , dDataLib            		, NIL }}

			aParam := {'SE2', 'INCTXSUPP' , aTitulo}

			IF EXISTBLOCK("RskFinGrv")
				aTitulo := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
			ENDIF

			MsExecAuto( { |x,y| FINA050( x, y ) } , aTitulo, 3 ) 

			If !lMsErroAuto
				aRet := { BILL_FEE, cFilAnt, cPrefixo, cNum, cParcela, cTipo, ( cAliasQry )->A2_COD, ( cAliasQry )->A2_LOJA , nValor, dDataVenc }	// 2=Título de taxas
			Else
				aErroAuto := GetAutoGRLog()
				For nI := 1 To Len( aErroAuto )  
					cError += aErroAuto[nI]
				Next nI
				LogMsg( "RSKTaxa", 23, 6, 1, "", "", "RSKTaxa -> " + cError )
				cErrorMsg := cError	
			EndIf
		EndIf

		( cAliasQry )->( dbCloseArea() )
	EndIf 

	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aTitulo )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
Return aRet   

//-------------------------------------
/*/{Protheus.doc} RSKGrvBol
Grava boleto no banco de conhecimento

@param 		cFile: arquivo pdf em base 64
@param 		cDoc: codigo do documento

@return 	logico, informa se o boleto foi gravado 
@author 	jose.delmondes
@since  	04/06/2020
@version	P12
/*/
//-------------------------------------
Static Function RSKGrvBol( cFile As Character, cDoc As Character ) As Logical
	Local cDirDocs As Character
	Local cName    As Character
	Local lRet 	   As Logical
	Local nStack   As Numeric
	Local nHandle  As Numeric
	Local lMultDir As Logical

	lMultDir := MsMultDir()
	cDirDocs := MsDocPath( lMultDir )
	cName  	 := StrTran( xFilial( 'AR1' ) + cDoc + '_boleto.pdf', ' ', '_' )
	lRet 	 := .T.
	nStack	 := GetSX8Len()
	//------------------------------------------------------------------------------
	//-- Cria o documento no diretorio do banco de conhecimento
	//------------------------------------------------------------------------------
	nHandle  := FCREATE( cDirDocs + "\" + cName , 0 )

	If nHandle == -1
		lRet := .F.
	else
		//------------------------------------------------------------------------------
		//-- Escreve documento
		//------------------------------------------------------------------------------
		FWRITE( nHandle , Decode64( cFile ) ) 
		
		//------------------------------------------------------------------------------
		//-- Valida criacao do documento
		//------------------------------------------------------------------------------
		If FCLOSE( nHandle ) .And. File( cDirDocs + "\" + cName )
			//------------------------------------------------------------------------------
			//-- Grava tabelas do banco de conhecimento
			//------------------------------------------------------------------------------
			RecLock( "ACB" , .T. )
				ACB->ACB_FILIAL := xFilial( "ACB") 
				ACB->ACB_CODOBJ := GetSX8Num( "ACB" , "ACB_CODOBJ" )
				ACB->ACB_OBJETO := cName
				ACB->ACB_DESCRI := STR0004 //'Boleto'
				If lMultDir
					ACB->ACB_PATH := cDirDocs
				EndIf
			ACB->( MsUnlock() )

			RecLock( "AC9", .T. )
				AC9->AC9_FILIAL := xFilial( "AC9" )
				AC9->AC9_FILENT := xFilial( "AR1" )
				AC9->AC9_ENTIDA := "AR1"
				AC9->AC9_CODENT := xFilial( 'AR1' ) + cDoc
				AC9->AC9_CODOBJ := ACB->ACB_CODOBJ
			AC9->( MsUnlock() )

			//------------------------------------------------------------------------------
			//-- Confirma num. sequencial
			//------------------------------------------------------------------------------
			While GetSX8Len() > nStack 
				ConfirmSX8()
			End
		else		
			lRet = .F.
		EndIf 
	EndIf
Return lRet  

//-------------------------------------------------------------------------------
/*/
	{Protheus.doc} RskAntecMn
	Função que processa o retorno das Antecipações do Mais Negócios

	@param oAntecMn, Object, Objeto que contem o retorno da API
    @param nType, number, identifica qual a entidade está semdo executada.
    @param cHost, Character, endereço onde está a plataforma
	
	@author  Claudio Yoshio Muramatsu
	@since   07/02/2024
	@version 1.0
/*/
//-----------------------------------------------------------------------------
Function RskAntecMn( oAntecMn As Object, nType As Numeric, cHost As Character )
	Local aArea      As Array
	Local aAreaAR1   As Array
	Local aAreaAR2   As Array
	Local aErpIDItem As Array
	Local aInstallms As Array
	Local aErrorMd   As Array
	Local aParcNota  As Array
	Local cQryNFS 	 As Character
	Local cFilAR2    As Character
	Local cFilSE2    As Character
	Local cHist      As Character
	Local cInstallme As Character
	Local cIdNatExp  As Character
	Local cNumSE2    As Character
	Local cParcDef   As Character
	Local cParcela   As Character
	Local cTempNFS   As Character
	Local cErpId     As Character
	Local cNota 	 As Character
	Local cTitOri    As Character
	Local nLenAntec  As Numeric
	Local nQtdParc   As Numeric
	Local nContFor   As Numeric
	Local nCntParc   As Numeric
	Local nTaxas 	 As Numeric
	Local nLenTaxas  As Numeric
	Local nX         As Numeric
	Local nY         As Numeric
	Local nPosInst   As Numeric
	Local dDataVenc  As Date
	Local oQryNFS 	 As Object
	Local oModel 	 As Object
	Local oMdlAR2 	 As Object
	Local lContinue  As Logical
	Local lFirst 	 As Logical

	aArea      := GetArea()
	aAreaAR1   := AR1->(GetArea())
	aAreaAR2   := AR2->(GetArea())
	aErpIDItem := {}
	aInstallms := RskInstallments(100)
	aErrorMd   := {}
	aParcNota  := {}
	cQryNFS    := ""
	cFilAR2    := xFilial("AR2")
	cFilSE2    := xFilial("SE2")
	cHist      := ""
	cInstallme := ""
	cIdNatExp  := RskSeekNature( EXPENSE_NATURE ) // 2=Despesa
	cNumSE2    := ""
	cParcDef   := SuperGetMv( "MV_1DUP", .F., "1" )
	cParcela   := ""
	cTempNFS   := GetNextAlias()
	cErpId     := ""
	cNota 	   := ""
	cTitOri    := ""
	nLenAntec  := Len( oAntecMn )
	nTaxas 	   := 0
	nLenTaxas  := 01
	nCntFor    := 0
	nCntParc := 0
	nQtdParc := 0
	nContFor := 0
	nX         := 01
	nY         := 01
	nPosInst   := 01
	dDataVenc  := CToD("//")
	oQryNFS	   := Nil
	oModel 	   := Nil
	oMdlAR2    := Nil
	lContinue  := .T.
	lFirst     := .T.

	AR1->(DBSetOrder(1))
	AR2->(DBSetOrder(1))

	For nX := 01 To nLenAntec
		lContinue  := .T.

		If oAntecMn[nX]['typePartnerReceipt'] <> "2" // Diferente de Contra Vencimento
			lContinue := .F.
			if cNota <> Alltrim(oAntecMn[ nX, 'erpId' ]) .AND. !lFirst .And. nTaxas > 0
				lContinue := .T.
				nX--
			Endif
			cNota := Alltrim(oAntecMn[ nX, 'erpId' ])
			lFirst := .F.
			If !lContinue
				nQtdParc := Len(oAntecMn[nX]['reversalRate'])
				For nY := 01 To nQtdParc
					If oAntecMn[nX]['reversalRate'][nY]['idTipoTaxa'] == "6" // Taxa de Antecipação do Antecipado
						nTaxas += oAntecMn[nX]['reversalRate'][nY]['valorTaxaEmReais'] // Valor da taxa da parcela em reais
						aadd(aParcNota, oAntecMn[nX])
					Endif
				Next
			Endif
			If nX == nLenAntec
				lContinue := .T.
			Endif
		Endif

		If lContinue
			dDataVenc  := SToD( StrTran( Subs( oAntecMn[nX]['datePartnerReceipt'], 1, At( 'T', oAntecMn[nX]['datePartnerReceipt'] ) - 1 ), '-', '') )
			nPosInst   := aScan( aInstallms, {|x| x[1] == cValToChar( oAntecMn[nX]['numberInstallment'] ) } )
			cInstallme := aInstallms[nPosInst][2]
			aErpIDItem := StrToKArr2( oAntecMn[ nX, 'erpId' ], '|', .T. )
			cQryNFS    := "SELECT AR2.AR2_FILIAL, AR2.AR2_COD, AR2.AR2_ITEM, AR2.AR2_FILTIT, AR2.AR2_PREFIX, AR2.AR2_NUMTIT, AR2.AR2_PARC, AR2.AR2_TIPO, AR2.AR2_CLIENT, AR2.AR2_LOJA, AR2.AR2_FORNEC, AR2.AR2_LOJFOR, AR2_DATAOR " + ;
						  "FROM " + RetSqlName( "AR2" ) + " AR2 " + ;
						  "WHERE AR2.AR2_FILIAL = ? " + ;
						  "AND AR2.AR2_COD = ? " + ;
						  "AND AR2.AR2_MOV = ? " + ;
						  "AND ( AR2.AR2_PARC = ? OR AR2.AR2_PARC = ? )" + ;
						  "AND AR2.AR2_TIPO = ? " +;
						  "AND AR2.D_E_L_E_T_ = ' ' "

			cQryNFS := ChangeQuery( cQryNFS )
			oQryNFS := FWPreparedStatement():New( cQryNFS )

			If cErpId <> oAntecMn[ nX, 'erpId' ]
				cNumSE2  := ProxTitulo( "SE2", "OFF" )
				cParcela := cParcDef
				cErpId   := oAntecMn[ nX, 'erpId' ]
			EndIf

			BEGIN TRANSACTION

				oQryNFS:SetString( 1, cFilAR2 )
				oQryNFS:SetString( 2, aErpIDItem[ 03 ] )
				oQryNFS:SetString( 3, "1") 			//"1=Receber (R);2=Taxa (P);3=Bonificação (P);4=Prorrogação (P);5=Devolução (P);6=Bloqueia NCC (R);7=Libera NCC (R);8=NCC Baixa Parcial (R);9=NCC Baixa Total (R);A=Cancelada (P);B=NCC Inativa (R);C=Taxa Antecipação (P)"
				oQryNFS:SetString( 4, cInstallme)   //Caso título seja parcelado
				oQryNFS:SetString( 5, " ") 			//Parcela Unica
				oQryNFS:SetString( 6, "DP")			//Tipo
				cQryNFS := oQryNFS:GetFixQuery()
				MPSysOpenQuery( cQryNFS, cTempNFS )

				If Empty( ( cTempNFS )->AR2_DATAOR )

					AR1->( MsSeek( xFilial( 'AR1' ) + ( cTempNFS )->AR2_COD ) )
					oModel:= FWLoadModel( 'RSKA020' )
					oModel:SetOperation( MODEL_OPERATION_UPDATE )
					oModel:Activate()
					// Altera o vencimento do Contas a Receber
					lContinue := RskSE1AltV( ( cTempNFS )->AR2_PREFIX, ( cTempNFS )->AR2_NUMTIT, ( cTempNFS )->AR2_PARC, ( cTempNFS )->AR2_TIPO, ( cTempNFS )->AR2_CLIENT, ( cTempNFS )->AR2_LOJA, dDataVenc )
					If lContinue
						lContinue := .F.
						AR2->( MsSeek( ( cTempNFS )->AR2_FILIAL + ( cTempNFS )->AR2_COD + ( cTempNFS )->AR2_ITEM ) )
						If oModel:Activate()
							oMdlAR2:= oModel:GetModel("AR2DETAIL")
							If oMdlAR2:SeekLine({ {"AR2_ITEM", AR2->AR2_ITEM } })
								oMdlAR2:GoLine( oMdlAR2:nLine )
								oMdlAR2:SetValue( "AR2_DATAOR"  , AR2->AR2_DATATI )
								oMdlAR2:SetValue( "AR2_DATATI"  , dDataVenc )

								oQryNFS:SetString( 1, cFilAR2 )
								oQryNFS:SetString( 2, aErpIDItem[ 03 ] )
								oQryNFS:SetString( 3, "2") 			//"1=Receber (R);2=Taxa (P);3=Bonificação (P);4=Prorrogação (P);5=Devolução (P);6=Bloqueia NCC (R);7=Libera NCC (R);8=NCC Baixa Parcial (R);9=NCC Baixa Total (R);A=Cancelada (P);B=NCC Inativa (R);C=Taxa Antecipação (P)"
								oQryNFS:SetString( 4, cInstallme)   //Caso título seja parcelado
								oQryNFS:SetString( 5, " ") 			//Parcela Unica
								oQryNFS:SetString( 6, "MN+")		//Tipo
								cQryNFS := oQryNFS:GetFixQuery()
								MPSysOpenQuery( cQryNFS, cTempNFS )
								// Alterar o vencimento do Contas a Pagar (Taxas)
								lContinue := RskSE2AltV( ( cTempNFS )->AR2_PREFIX, ( cTempNFS )->AR2_NUMTIT, ( cTempNFS )->AR2_PARC, ( cTempNFS )->AR2_TIPO, ( cTempNFS )->AR2_FORNEC, ( cTempNFS )->AR2_LOJFOR, dDataVenc )
								AR2->( MsSeek( ( cTempNFS )->AR2_FILIAL + ( cTempNFS )->AR2_COD + ( cTempNFS )->AR2_ITEM ) )
								If lContinue .And. oMdlAR2:SeekLine({ {"AR2_ITEM", AR2->AR2_ITEM } })
									oMdlAR2:GoLine( oMdlAR2:nLine )
									oMdlAR2:SetValue( "AR2_DATAOR"  , AR2->AR2_DATATI )
									oMdlAR2:SetValue( "AR2_DATATI"  , dDataVenc )
								EndIf							
							EndIf
						EndIf
					EndIf

					If lContinue
						nLenTaxas := Len( oAntecMn[nX]['reversalRate'] )
						cTitOri   := oMdlAR2:GetValue( "AR2_FILTIT" ) + "|" + oMdlAR2:GetValue( "AR2_PREFIX" ) + "|" + oMdlAR2:GetValue( "AR2_NUMTIT" ) + "|" + oMdlAR2:GetValue( "AR2_PARC" ) + "|" + oMdlAR2:GetValue( "AR2_TIPO" ) + "|" + oMdlAR2:GetValue( "AR2_FORNEC" ) + "|" + oMdlAR2:GetValue( "AR2_LOJFOR" )
						For nY := 01 To nLenTaxas
							If oAntecMn[nX]['reversalRate'][nY]['idTipoTaxa'] == "6" //6-ANTECIPACAO_REAGEND
								cHist := "Mais Neg. NFS: " + AllTrim(AR1->AR1_DOC) + " / " + AllTrim(AR1->AR1_SERIE)
								If nTaxas == 0
									nTaxas := oAntecMn[nX]['reversalRate'][nY]['valorTaxaEmReais']
								Endif
								aItem := RSKTaxa( cFilSE2, "OFF", cNumSE2, cParcela, "MN+", nTaxas, dDataVenc, cHist, cIdNatExp )
								If Len( aItem ) == 0
									lContinue := .F.
								EndIf
								If lContinue
									lContinue := RskAddAR2(oMdlAR2, AR2_MOV_FEEANTPGTO, cFilSE2, 'OFF', cNumSE2, cParcela, "MN+", , , nTaxas, dDataVenc, cTitOri, , , , , ( cTempNFS )->AR2_FORNEC, ( cTempNFS )->AR2_LOJFOR )
									If lContinue .And. oModel:VldData()
										oModel:CommitData()
										cParcela := MAParcela( cParcela )
									Else
										aErrorMd := oModel:GetErrorMessage()
										LogMsg( "RskAntecMn", 23, 6, 1, "", "", "RskAntecMn -> " + aErrorMd[6] )
									EndIf
								Else
									LogMsg( "RskAntecMn", 23, 6, 1, "", "", "RskAntecMn -> " + STR0011 ) // "Ocorreu um erro na inclusão das novas Taxas! Verifique."
								EndIf
							EndIf
						Next nY
					Else
						LogMsg( "RskAntecMn", 23, 6, 1, "", "", "RskAntecMn -> " + STR0012 ) // "Ocorreu um erro na alteração no vencimento dos títulos! Verifique."
					EndIf

					If !lContinue
						DisarmTransaction()
					EndIf
				EndIf
			END TRANSACTION
			nTaxas := 0

			// Envia a confirmação para a plataforma
			( cTempNFS )->( DBCloseArea() )
			If lContinue
				nCntParc := Len(aParcNota)
				If nCntParc > 0
					For nContFor := 1 to nCntParc
						RSKConfPlat( cHost, nType, { aParcNota[ nContFor ] } )
					Next
					aParcNota := {}
				Else
					RSKConfPlat( cHost, nType, { oAntecMn[ nX ] } )
				Endif
			EndIf
		Endif
	Next nX

	RestArea( aArea )
	RestArea( aAreaAR1 )
	RestArea( aAreaAR2 )

	FwFreeArray( aArea )
	FwFreeArray( aAreaAR1 )
	FwFreeArray( aAreaAR2 )
	FwFreeArray( aInstallms )
	FwFreeArray( aErpIDItem )
	FwFreeArray( aErrorMd )
	FwFreeArray( aParcNota )

	FwFreeObj( oAntecMn )
	FwFreeObj( oQryNFS )
	FwFreeObj( oModel )
	FwFreeObj( oMdlAR2 )
Return

//-------------------------------------
/*/
	{Protheus.doc} RskSE1AltV
	Função para alteração do vencimento para os títulos Supplier

	@param cPrefixo , Character, Prefixo do Título que irá processar
	@param cNum     , Character, Numero do Título que irá processar
	@param cParcela , Character, Parcela dp Título que irá processar
	@param cTipo    , Character, Tipo do Título que irá processar
	@param cCliente , Character, Cliente do Título que irá processar
	@param cLoja    , Character, Loja do Título que irá processar
	@param dDataVenc, Date     , Vencimento que será alterado no Título

	@return  Lógico, que ocorreu com sucesso a alteração do título.
	@author  Daniel Moda
	@since   15/02/2024
	@version 1.0
/*/
//-------------------------------------
Static Function RskSE1AltV( cPrefixo As Character, cNum As Character, cParcela As Character, cTipo As Character, cCliente As Character, cLoja As Character, dDataVenc As Date ) As Logical
	Local aArea     As Array
	Local aAreaSE1  As Array
	Local aTitulo   As Array
	Local aErroAuto As Array
	Local cError    As Character
	Local cFilSE1   As Character
	Local nI        As Numeric
	Local lRet      As Logical

	Private lMsErroAuto    As Logical
	Private lAutoErrNoFile As Logical
	Private lMsHelpAuto    As Logical

	aArea     := GetArea()
	aAreaSE1  := SE1->(GetArea())
	aTitulo   := {}
	aErroAuto := {}
	cError    := ""
	cFilSE1   := xFilial("SE1")
	nI        := 0
	lRet      := .T.

	lMsErroAuto    := .F. 
	lAutoErrNoFile := .T.
	lMsHelpAuto    := .T.	

    SE1->( DbSetOrder(1) )
    If SE1->( MsSeek( cFilSE1 + cPrefixo + cNum + cParcela + cTipo ) )
		
		aTitulo  := {{ "E1_PREFIXO"  , cPrefixo  , Nil },;
					 { "E1_NUM"      , cNum      , Nil },;
					 { "E1_PARCELA"  , cParcela	 , Nil },;
					 { "E1_TIPO"     , cTipo     , Nil },;
					 { "E1_CLIENTE"  , cCliente  , Nil },;
					 { "E1_LOJA"     , cLoja     , Nil },;
					 { "E1_VENCTO"   , dDataVenc , Nil },;
					 { "E1_VENCREA"  , dDataVenc , Nil }}
		
		MsExecAuto( { |x,y| FINA040( x, y ) } , aTitulo, 4 ) // 4-Alteração

		If lMsErroAuto
			lRet      := .F.
			aErroAuto := GetAutoGRLog()
			For nI := 1 To Len( aErroAuto )
				cError += aErroAuto[nI] 
			Next nI
			LogMsg( "RskAltVenc", 23, 6, 1, "", "", "RskAltVenc -> " + cError )
		EndIf
	Else
		LogMsg( "RskAltVenc", 23, 6, 1, "", "", "RskAltVenc -> " + cFilSE1 + cPrefixo + cNum + cParcela + cTipo + " - " + STR0010 ) // // "Título não encontrado!"
		lRet := .F.
    EndIf

	RestArea( aArea )
	RestArea( aAreaSE1 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aTitulo )
	FWFreeArray( aErroAuto )
Return lRet

//-------------------------------------
/*/
	{Protheus.doc} RskSE2AltV
	Função para alteração do vencimento para os títulos Supplier

	@param cPrefixo    , Character, Prefixo do Título que irá processar
	@param cNum        , Character, Numero do Título que irá processar
	@param cParcela    , Character, Parcela dp Título que irá processar
	@param cTipo       , Character, Tipo do Título que irá processar
	@param cFornecedor , Character, Fornecedor do Título que irá processar
	@param cLoja       , Character, Loja do Título que irá processar
	@param dDataVenc   , Date     , Vencimento que será alterado no Título

	@return  Lógico, que ocorreu com sucesso a alteração do título.
	@author  Daniel Moda
	@since   15/02/2024
	@version 1.0
/*/
//-------------------------------------
Static Function RskSE2AltV( cPrefixo As Character, cNum As Character, cParcela As Character, cTipo As Character, cFornecedor As Character, cLoja As Character, dDataVenc As Date ) As Logical
	Local aArea     As Array
	Local aAreaSE2  As Array
	Local aTitulo   As Array
	Local aErroAuto As Array
	Local cError    As Character
	Local cFilSE2   As Character
	Local nI        As Numeric
	Local lRet      As Logical
	Local dDtBasBkp As Date

	Private lMsErroAuto    As Logical
	Private lAutoErrNoFile As Logical
	Private lMsHelpAuto    As Logical

	aArea     := GetArea()
	aAreaSE2  := SE2->(GetArea())
	aTitulo   := {}
	aErroAuto := {}
	cError    := ""
	cFilSE2   := xFilial("SE2")
	nI        := 0
	lRet      := .T.
	dDtBasBkp := dDataBase

	lMsErroAuto    := .F. 
	lAutoErrNoFile := .T.
	lMsHelpAuto    := .T.	

    SE2->( DbSetOrder(1) )
    If SE2->( MsSeek( cFilSE2 + cPrefixo + cNum + cParcela + cTipo + cFornecedor + cLoja ) )
		dDataBase := SE2->E2_EMISSAO
		aTitulo   :={{ "E2_PREFIXO"  , cPrefixo       , Nil },;
					 { "E2_NUM"      , cNum           , Nil },;
					 { "E2_PARCELA"  , cParcela	      , Nil },;
					 { "E2_TIPO"     , cTipo          , Nil },;
					 { "E2_VENCTO"   , dDataVenc      , Nil },;
					 { "E2_VENCREA"  , dDataVenc      , Nil }}
		
		MsExecAuto( {|x,y,Z| FINA050(x,y,Z)} , aTitulo,, 4 ) //4-Alteração

		If lMsErroAuto
			lRet      := .F.
			aErroAuto := GetAutoGRLog()
			For nI := 1 To Len( aErroAuto )
				cError += aErroAuto[nI] 
			Next nI
			LogMsg( "RskSE2AltV", 23, 6, 1, "", "", "RskSE2AltV -> " + cError )
		EndIf
	Else
		LogMsg( "RskSE2AltV", 23, 6, 1, "", "", "RskSE2AltV -> " + cFilSE2 + cPrefixo + cNum + cParcela + cTipo + cFornecedor + cLoja + " - " + STR0010 ) // "Título não encontrado!"
		lRet := .F.
    EndIf

	dDataBase := dDtBasBkp
	RestArea( aArea )
	RestArea( aAreaSE2 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE2 )
	FWFreeArray( aTitulo )
	FWFreeArray( aErroAuto )
Return lRet
