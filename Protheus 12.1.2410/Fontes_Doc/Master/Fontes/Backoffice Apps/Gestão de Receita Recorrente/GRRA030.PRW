#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#include "GRRXDefs.ch"
#include "GRRA030.ch"

//-------------------------- GRRA030 --------------------------------
// Funções para movimentações dos títulos financeiros relacionados ao GRR.
//-------------------------------------------------------------------

// campos do array de título financeiro
#DEFINE FFIN_VALUE         "_VALOR"   
#DEFINE FFIN_DUEDATE       "_VENCTO"   

//-------------------------------------
/*/{Protheus.doc} GRRProcNFS
Processamento da Nota Fiscal de Saída que utiliza condição de pagamento recorrente.

@param 		cKeySF2, caracter, Chave unica da nota fiscal de saida

@return 	logico, Nota processada para GRR com sucesso
@since  	01/08/2022
@version	P12
/*/
//-------------------------------------
Function GRRProcNFS( cKeySF2 )
	Local aArea 	    := GetArea()
	Local lRet      	:= .T.
	Local cAliasQry 	:= GetNextAlias()
	Local nPerTxAdmF  	:= SuperGetMV( "MV_GRRPTXA", .T., 8.5 ) //Taxa da transacao
	Local nDaysDAdmF	:= SuperGetMV( "MV_GRRDVEN", .T., 28 ) //Recebimento / Pagamento (D+28)
	Local nValueTxAdmF	:= 0
	Local nValueAR		:= 0 
	Local dDueDate 		:= cTod("//")
	Local lTxAdmPay		:= SuperGetMV( "MV_GRRTXPG", .T., .T. )

	If ( !FWIsInCallStack( "GRRA060A" ) )
		SF2->( DBSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If SF2->( MSSeek( cKeySF2 ) )
			
			SE4->( DBSetOrder(1) )
			If SE4->( MSSeek( xFilial("SE4") + SF2->F2_COND )) .And. SE4->E4_PAGGRR  

				//Baixa os títulos associado ao documento de saida sem movimentação bancaria
				lRet := DownARNFS( SF2->F2_FILIAL, SF2->F2_PREFIXO, SF2->F2_DOC , MVNOTAFIS )

				If lRet 
					BeginSQL Alias cAliasQry

						SELECT	E1_FILIAL, E1_PREFIXO, E1_PARCELA, E1_NUM, E1_NATUREZ, E1_VALOR, E1_VENCTO, E1_VENCREA
						FROM 	%Table:SE1% SE1 
						WHERE	SE1.%NotDel% AND 
								SE1.E1_FILORIG = %Exp:SF2->F2_FILIAL% AND
								SE1.E1_PREFIXO = %Exp:SF2->F2_PREFIXO% AND
								SE1.E1_NUM = %Exp:SF2->F2_DOC% AND 
								SE1.E1_TIPO =  %Exp:MVNOTAFIS% 
						ORDER BY E1_PARCELA
					EndSQL

					While ( cAliasQry )->( !Eof() )	 

						dDueDate := sTod(( cAliasQry )->E1_VENCTO)

						//Data prevista para pagamento pela Adm. Financeira
						If nDaysDAdmF > 0
							dDueDate += nDaysDAdmF 
						EndIf 

						//Percentual previsto para cobrança da taxa da transação.
						If nPerTxAdmF > 0
							nValueTxAdmF	:= ( cAliasQry )->E1_VALOR * nPerTxAdmF / 100 
						EndIf

						If lTxAdmPay
							nValueAR := ( cAliasQry )->E1_VALOR
						else
							nValueAR := ( cAliasQry )->E1_VALOR - nValueTxAdmF  
						EndIf
						
						lRet := NewAReceivable(( cAliasQry )->E1_FILIAL, "GRR", ( cAliasQry )->E1_NUM, MVPROVIS, ( cAliasQry )->E1_PARCELA, nValueAR ,dDueDate,;
										I18N( STR0001, { AllTrim( SF2->F2_DOC ), AllTrim( SF2->F2_SERIE )} ),  ( cAliasQry )->E1_NATUREZ )	//"NFS: #1 Serie: #2"

						If lTxAdmPay .And. lRet .And. nValueTxAdmF > 0
							lRet := NewAPayment( ( cAliasQry )->E1_FILIAL, "GRR", ( cAliasQry )->E1_NUM, ( cAliasQry )->E1_PARCELA, MVPROVIS,;
										nValueTxAdmF, dDueDate, I18N( STR0002, { AllTrim( SF2->F2_DOC ), AllTrim( SF2->F2_SERIE )} ), ( cAliasQry )->E1_NATUREZ )	//"TX AdmFin NFS: #1 Serie: #2"
						EndIf 

						If !lRet
							Exit  
						EndIf
						( cAliasQry )->(DBSkip())  
					End
				EndIf
			EndIf
		EndIf
	ENDIF
	
	RestArea( aArea )
	FWFreeArray( aArea )

Return lRet

//-------------------------------------
/*/{Protheus.doc} GRRProcTit
Processamento do Titulo tiliza condição de pagamento recorrente.

@param 		cKeySE1, caracter, Chave unica do titulo financeiro

@return 	logico, Titulo processada para GRR com sucesso
@since  	01/08/2022
@version	P12
/*/
//-------------------------------------
Function GRRProcTit( aKeySE1 )
	Local aArea 	    := GetArea()
	Local lRet      	:= .F.
	Local nPerTxAdmF  	:= SuperGetMV( "MV_GRRPTXA", .T., 8.5 ) //Taxa da transacao
	Local nDaysDAdmF	:= SuperGetMV( "MV_GRRDVEN", .T., 28 ) //Recebimento / Pagamento (D+28)
	Local nValueTxAdmF	:= 0
	Local nValueAR		:= 0 
	Local dDueDate 		:= cTod("//")
	Local lTxAdmPay		:= SuperGetMV( "MV_GRRTXPG", .T., .T. )
	Local aBankPart		:= StrToArray( SuperGetMv( "MV_GRRBPAY",, "ADY|ADYEN|ADYEN" ), "|" )
	Local cFilAnt       := PadR( aKeySE1[2], TamSX3( "E1_FILIAL" )[1] ) 
	Local cPrefixo      := PadR( aKeySE1[3], TamSX3( "E1_PREFIXO" )[1] ) 
	Local cNum  	    := PadR( aKeySE1[4], TamSX3( "E1_NUM" )[1] ) 
	Local cParcela      := PadR( aKeySE1[5], TamSX3( "E1_PARCELA" )[1] ) 
	Local cTipo		    := PadR( aKeySE1[6], TamSX3( "E1_TIPO" )[1] ) 

	If Len( aBankPart ) == 3
		DBSelectArea( 'SA6' )
		DBSetOrder(1)	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
		
		cBank 		:= PadR( aBankPart[1], TamSX3( "A6_COD" )[1] ) 
		cBankUnit	:= PadR( aBankPart[2], TamSX3( "A6_AGENCIA" )[1] ) 
		cBankAcc	:= PadR( aBankPart[3], TamSX3( "A6_NUMCON" )[1] ) 
		
		If DBSeek( xFilial( 'SA6' ) + cBank + cBankUnit + cBankAcc )
			cBank		:= SA6->A6_COD
			cBankUnit	:= SA6->A6_AGENCIA
			cBankAcc	:= SA6->A6_NUMCON 
		EndIf  
	EndIf 

	SE1->( DBSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

	IF SE1->( MSSeek( cFilAnt + cPrefixo + cNum + cParcela + cTipo))

		//Baixa os títulos associado ao documento de saida sem movimentação bancaria
		lRet := DownARTit({cBank, cBankUnit, cBankAcc})

		If lRet 

			dDueDate := SE1->E1_VENCTO

			//Data prevista para pagamento pela Adm. Financeira
			If nDaysDAdmF > 0
				dDueDate += nDaysDAdmF 
			EndIf 

			//Percentual previsto para cobrança da taxa da transação.
			If nPerTxAdmF > 0
				nValueTxAdmF	:= SE1->E1_VALOR * nPerTxAdmF / 100 
			EndIf

			If lTxAdmPay
				nValueAR := SE1->E1_VALOR
			else
				nValueAR := SE1->E1_VALOR - nValueTxAdmF  
			EndIf

			
			lRet := NewAReceivable(SE1->E1_FILIAL, "GRR", SE1->E1_NUM, MVPROVIS, SE1->E1_PARCELA, nValueAR ,dDueDate,;
							"Baixa de titulo GRR."  ,  SE1->E1_NATUREZ) 

			If lTxAdmPay .And. lRet .And. nValueTxAdmF > 0
				lRet := NewAPayment( SE1->E1_FILIAL, "GRR", SE1->E1_NUM, SE1->E1_PARCELA, MVPROVIS,;
							nValueTxAdmF, dDueDate, "TX AdmFin GRR", SE1->E1_NATUREZ )
			EndIf 
		EndIf

	EndIf
	
	RestArea( aArea )
	FWFreeArray( aArea )

Return lRet

//-------------------------------------
/*/{Protheus.doc}  DownARNFS
Baixa titulos a receber em nome do cliente associado a nota fiscal de saida.

@param 		cFilOrig, caracter, Filial do documento
@param 		cPrefix, caracter, Prefixo do titulo
@param 		cNum, caracter, Numero do titulo
@param 		cType, caracter, Tipo do titulo

@return 	Logico, Informa se os titulos foram baixados
@author 	Squad NT
@since  	01/08/2022
@version	P12
/*/
//-------------------------------------
Static Function DownARNFS( cFilOrig, cPrefix, cNum, cType )
	Local aArea		:= GetArea()
	Local aDown 	:= {}
	Local cAliasQry := GetNextAlias()
	Local aErroAuto	:= {}
	Local lRet 		:= .T.
	Local aParam 	:= {}
	Local cBank		:= ""
	Local cBankUnit	:= ""
	Local cBankAcc	:= ""
	Local aBankPart	:= StrToArray( SuperGetMv( "MV_GRRBPAY",, "ADY|ADYEN|ADYEN" ), "|" )

	Private lMsErroAuto		:= .F. 
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.	

	If Len( aBankPart ) == 3
		DBSelectArea( 'SA6' )
		DBSetOrder(1)	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
		
		cBank 		:= PadR( aBankPart[1], TamSX3( "A6_COD" )[1] ) 
		cBankUnit	:= PadR( aBankPart[2], TamSX3( "A6_AGENCIA" )[1] ) 
		cBankAcc	:= PadR( aBankPart[3], TamSX3( "A6_NUMCON" )[1] ) 
		
		If DBSeek( xFilial( 'SA6' ) + cBank + cBankUnit + cBankAcc )
			cBank		:= SA6->A6_COD
			cBankUnit	:= SA6->A6_AGENCIA
			cBankAcc	:= SA6->A6_NUMCON 
		EndIf  
	EndIf 

	BeginSQL Alias cAliasQry

		SELECT	E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_NATUREZ,E1_VALOR
		FROM 	%Table:SE1% SE1
		WHERE	SE1.%NotDel% AND
				SE1.E1_FILORIG = %Exp:cFilOrig% AND
				SE1.E1_PREFIXO = %Exp:cPrefix% AND
				SE1.E1_NUM = %Exp:cNum% AND
				SE1.E1_TIPO = %Exp:cType% 
	EndSQL

	DBSelectArea( 'SE1' )
	SE1->( DBSetOrder( 1 ) ) 	//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
	While ( cAliasQry )->( !Eof() )	

        If SE1->( MsSeek( cFilOrig + cPrefix  + cNum  + ( cAliasQry )->E1_PARCELA + cType ) ) 
			DownARTit( { cBank, cBankUnit, cBankAcc } )
		EndIf

		( cAliasQry )->( DBSkip() )
	End

	( cAliasQry )->( DBCloseArea() )

	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aDown )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
Return lRet

//-------------------------------------
/*/{Protheus.doc}  DownARTit
Baixa titulos a receber em nome do cliente associado a nota fiscal de saida.

@param 		cFilOrig, caracter, Filial do documento
@param 		cPrefix, caracter, Prefixo do titulo
@param 		cNum, caracter, Numero do titulo
@param 		cType, caracter, Tipo do titulo

@return 	Logico, Informa se os titulos foram baixados
@author 	Squad NT
@since  	01/08/2022
@version	P12
/*/
//-------------------------------------
Static Function DownARTit( aBank )
	Local aDown 	:= {}
	Local cError	:= ""
	Local lRet 		:= .T.
	Local aParam 	:= {}

	Private lMsErroAuto		:= .F. 
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.	


		aDown := {	{ "E1_PREFIXO"	, SE1->E1_PREFIXO			,Nil	 },;
					{ "E1_NUM"		, SE1->E1_NUM				,Nil	 },;
					{ "E1_TIPO"		, SE1->E1_TIPO				,Nil	 },;
					{ "E1_PARCELA"	, SE1->E1_PARCELA			,Nil	 },; 
					{ "E1_CLIENTE"	, SE1->E1_CLIENTE			,Nil	 },;
					{ "E1_LOJA"		, SE1->E1_LOJA				,Nil	 },;
					{ "E1_NATUREZ"	, SE1->E1_NATUREZ			,Nil	 },;
					{ "AUTMOTBX"    , "GRR"                  	,Nil     },; 
					{ "AUTBANCO"    , aBank[1]                 	,Nil     },;
					{ "AUTAGENCIA"  , aBank[2]               	,Nil     },;
					{ "AUTCONTA"    , aBank[3]           		,Nil     },;
					{ "AUTDTBAIXA"  , dDataBase              	,Nil     },;
					{ "AUTDTCREDITO", dDataBase              	,Nil     },;
					{ "AUTHIST"     , "Baixa Automática GRR"    ,Nil     },; 
					{ "AUTVALREC"   , SE1->E1_VALOR   			,Nil     }} 


		aParam := { "SE1", "DownARTit" , aDown }
					
		MSExecAuto( { |x,y| Fina070( x, y ) }, aDown, 3 ) 

		lRet := GRRAutoError( @cError, "DownARTit" )

Return lRet

//-------------------------------------
/*/{Protheus.doc} NewAReceivable
Gera titulo a receber em nome da administradora de crédito.

@param 		cFilOrig, caracter, Filial do documento
@param 		cPrefix, caracter, Prefixo do titulo Original
@param 		cNum, caracter, Numero do titulo Original
@param 		cType, caracter, Tipo do titulo Original
@param		cInstallment, caracter, Parcela do titulo
@param 		nValue, caracter, Valor do titulo
@param 		dDueDate, caracter, Vencimento
@param 		cHist, caracter, Historico
@param		cNature, caracter, Código da Natureza (Receita)

@return 	logico, título gerado com sucesso
@author 	Squad NT
@since  	01/08/2022
@version	P12
/*/
//-------------------------------------
Static Function NewAReceivable(cFilOrig, cPrefix, cNum, cType, cInstallment, nValue, dDueDate, cHist, cNature)
	Local aArea 	    := GetArea()
	Local aAuto 	    := {}
	Local lRet 		    := .T.
	Local cCustomer	    := SuperGetMV( "MV_GRRCPAY", .T., "" )
	Local cUnit 	    := ''
	Local aErroAuto	    := {}
	Local cError 	    := ""
	Local dIssueDate	:= cTod("//")
	Local aParam        := {}

	Default cPrefix     	:= "GRR"
	Default cNum	    	:= ProxTitulo( "SE1", "GRR" )
	Default cType	    	:= "DP"
	Default cInstallment	:= " " //Caso haja mais de uma parcela utilizar o parametro MV_1DUP

	Private lMsErroAuto		:= .F. 
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.	

	If !Empty( cCustomer )
		cUnit 		:= SubStr( cCustomer, TamSX3( 'A1_COD' )[1] + 2, TamSX3( 'A1_LOJA' )[1] )
		cCustomer	:= SubStr( cCustomer, 1, TamSX3( 'A1_COD' )[1] )
	else
		lRet := .F.
	EndIf 

	If lRet

		dIssueDate := IIF( dDatabase > dDueDate, dDueDate, dDatabase )
		aAuto  := { { "E1_PREFIXO" 	, cPrefix         			, Nil },;
					{ "E1_NUM"      , cNum        			    , Nil },;
					{ "E1_PARCELA"	, cInstallment				, Nil },;
					{ "E1_TIPO"     , cType          			, Nil },;
					{ "E1_CLIENTE"  , cCustomer          		, Nil },;
					{ "E1_LOJA"     , cUnit              		, Nil },;
					{ "E1_NATUREZ"  , cNature					, Nil },;
					{ "E1_EMISSAO"  , dIssueDate				, Nil },;
					{ "E1_VENCTO"   , dDueDate					, Nil },;
					{ "E1_VENCREA"  , dDueDate			    	, Nil },;
					{ "E1_HIST"     , cHist             		, Nil },;
					{ "E1_BOLETO"   , "2" 	            		, Nil },;					
					{ "E1_VALOR"    , nValue             		, Nil }}

		aParam := {"SE1", "NewAReceivable" , aAuto}

		MsExecAuto( { |x,y| FINA040( x, y ) } , aAuto, 3 )    

		lRet := GRRAutoError( @cError, "NewAReceivable" )
	EndIf

	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aAuto )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
Return lRet

//-------------------------------------
/*/{Protheus.doc} NewAPayment
Gera titulo de taxas em nome do provedor

@param 		cFilOrig, caracter, Filial do documento
@param 		cPrefix, caracter, Prefixo do titulo
@param 		cNum, caracter, Numero do titulo
@param 		cInstallment, caracter, Parcela do titulo
@param 		cType, caracter, Tipo do titulo
@param 		nValue, caracter, Valor das taxas
@param 		dDueDate, caracter, Vencimento
@param 		cHist, caracter, Historico
@param		cNature, caracter, Código da Natureza (Despesa)

@return 	logico, título gerado com sucesso
@author 	Squad NT
@since  	02/08/2022
@version	P12
/*/
//-------------------------------------
Static Function NewAPayment( cFilOrig, cPrefix, cNum, cInstallment, cType, nValue, dDueDate, cHist, cNature )
	Local aArea 		:= GetArea()
	Local aAuto 		:= {}
	Local cAliasQry 	:= GetNextAlias()
	Local cSupplier		:= SuperGetMV( "MV_GRRFPAY", .T., "" )
	Local cUnit 		:= ''
	Local lRet 			:= .T.
	Local aErroAuto		:= {}
	Local cError 		:= ""
	Local dIssueDate	:= cTod("//")
	Local aParam 		:= {}

	Default cPrefix     	:= "GRR"
	Default cNum	    	:= ProxTitulo( "SE2", "GRR" )
	Default cType	    	:= "DP"
	Default cInstallment	:= " " //Caso haja mais de uma parcela utilizar o parametro MV_1DUP

	Private lMsErroAuto		:= .F. 
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.	

	If !Empty( cSupplier )
		cUnit 		:= SubStr( cSupplier, TamSX3( 'A2_COD' )[1] + 2, TamSX3( 'A2_LOJA' )[1] )
		cSupplier 	:= SubStr( cSupplier, 1, TamSX3( 'A2_COD' )[1] )
	else
		lRet	:= .F.
	EndIf
	
	If lRet

		BeginSQL Alias cAliasQry
	
			SELECT	A2_COD, A2_LOJA  
			FROM 	%Table:SA2% SA2
			WHERE	SA2.%NotDel% AND
					SA2.A2_FILIAL  = %Exp:xFilial( "SA2", cFilOrig )% AND
					SA2.A2_COD = %Exp:cSupplier% AND
					SA2.A2_LOJA  = %Exp:cUnit%
	
		EndSQL

		If ( cAliasQry )->( !Eof() )	
			dIssueDate := IIF( dDatabase > dDueDate, dDueDate, dDatabase )
			aAuto  := {{ "E2_PREFIXO"	, cPrefix					, Nil },; 
						{ "E2_NUM"      , cNum        				, Nil },; 
						{ "E2_PARCELA"  , cInstallment				, Nil },;
						{ "E2_TIPO"     , cType            			, Nil },; 
						{ "E2_FORNECE"  , ( cAliasQry )->A2_COD     , Nil },;
						{ "E2_LOJA"     , ( cAliasQry )->A2_LOJA    , Nil },;
						{ "E2_NATUREZ"  , cNature					, Nil },;
						{ "E2_HIST"     , cHist	            		, Nil },;  
						{ "E2_EMISSAO"  , dIssueDate				, Nil },;
						{ "E2_VENCTO"   , dDueDate					, Nil },;
						{ "E2_VENCREA"  , dDueDate					, Nil },;
						{ "E2_VALOR"    , nValue             		, Nil }}

			aParam := { "SE2", "NewAPayment" , aAuto }

			MsExecAuto( { |x,y| FINA050( x, y ) } , aAuto, 3 ) 

			lRet := GRRAutoError( @cError, "NewAPayment" )			
		EndIf

		( cAliasQry )->( DBCloseArea() )
	EndIf 

RestArea( aArea )   

FWFreeArray( aArea )  
FWFreeArray( aAuto )
FWFreeArray( aErroAuto ) 
FWFreeArray( aParam )
Return lRet  

//-------------------------------------------------------------------------------
/*/{Protheus.doc} DownAPayment
Função que realiza baixa do título a pagar do processo GRR.

@param nRecNo	, numero  , Recno da SE2.
@param dDatePay	, data      , Data de pagamento
@param nAmount	, numerico  , Valor do título
@param nFeePaid	, numerico  , Valor pago

@return cRetMessage , caracter, Messagem de retorno para cada evento.

@author Squad NT
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Static Function DownAPayment( nRecNo, dDatePay, nAmount, nFeePaid, cHist )
    Local aArea         := GetArea()
    Local aAutoSE2      := {}  
    Local aErroAuto     := {}
    Local cRet          := ""     
    Local aParam        := {}
	Local aBankPart		:= StrToArray( SuperGetMv( "MV_GRRBPAY",, "ADY|ADYEN|ADYEN" ), "|" )
	Local cBank			:= ""
	Local cBankUnit		:= ""
	Local cBankAcc		:= ""

    Private lMsErroAuto		:= .F.   
    Private lAutoErrNoFile	:= .T.
    Private lMsHelpAuto   	:= .T.

	If Len( aBankPart ) == 3
		SA6->( DBSetOrder(1) )	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	
		cBank 		:= PadR( aBankPart[1], TamSX3( "A6_COD" )[1] ) 
		cBankUnit	:= PadR( aBankPart[2], TamSX3( "A6_AGENCIA" )[1] ) 
		cBankAcc	:= PadR( aBankPart[3], TamSX3( "A6_NUMCON" )[1] ) 
		
		If SA6->( DBSeek( xFilial( 'SA6' ) + cBank + cBankUnit + cBankAcc ) )
			cBank		:= SA6->A6_COD
			cBankUnit	:= SA6->A6_AGENCIA
			cBankAcc	:= SA6->A6_NUMCON 
		EndIf  
	EndIf 
	
	SE2->( DBGoTo( nRecNo ) )

	If !Empty( SE2->E2_NUM )
		If nAmount == SE2->E2_SALDO
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
							{ "AUTAGENCIA"   , cBankUnit       	, Nil },;
							{ "AUTCONTA"     , cBankAcc      	, Nil },; 
							{ "AUTVLRPG"     , nFeePaid         , Nil },;
							{ "AUTHIST"   	 , cHist 			, Nil } }
							
			aParam := { "SE2", "DownAPayment" , aAutoSE2 }

			MSExecAuto( {|x,y| FINA080( x, y ) }, aAutoSE2, 3 ) 

			GRRAutoError( @cRet, "DownAPayment", .F. )
		else
			cRet := STR0003		//"Saldo do título a pagar no financeiro diverge do valor recebido pelo provedor."
		EndIf
	else
		cRet := STR0004		//"Título a pagar não localizado no financeiro."
	EndIf

    RestArea( aArea )

    FWFreeArray( aArea )
    FWFreeArray( aAutoSE2 ) 
    FWFreeArray( aErroAuto )
    FWFreeArray( aParam )
Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} DownAReceivable
Funcao que realiza baixa do título a receber do processo GRR.

@param nRecNo	, numerico  , Recno da SE1.
@param dDatePay	, data      , Data de pagamento
@param nAmount	, numerico  , Valor do título
@param nFeePaid	, numerico  , Valor pago

@return cRetMessage , caracter, Messagem de retorno para cada evento.

@author Squad NT
@since  06/11/2020
/*/
//-----------------------------------------------------------------------------
Static Function DownAReceivable( nRecNo, dDateRec, nAmountRec, cHist )
    Local aArea         := GetArea()
    Local aAutoSE1      := {}  
    Local aErroAuto     := {}
    Local cRet          := ""     
    Local aParam        := {}
	Local aBankPart		:= StrToArray( SuperGetMv( "MV_GRRBPAY",, "ADY|ADYEN|ADYEN" ), "|" )
	Local cBank			:= ""
	Local cBankUnit		:= ""
	Local cBankAcc		:= ""

	Default cHist		:= ""
    Private lMsErroAuto		:= .F.   
    Private lAutoErrNoFile	:= .T.
    Private lMsHelpAuto   	:= .T.
	
	If Len( aBankPart ) == 3
		SA6->( DBSetOrder( 1 ) )	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	
		cBank 		:= PadR( aBankPart[1], TamSX3( "A6_COD" )[1] ) 
		cBankUnit	:= PadR( aBankPart[2], TamSX3( "A6_AGENCIA" )[1] ) 
		cBankAcc	:= PadR( aBankPart[3], TamSX3( "A6_NUMCON" )[1] ) 
		
		If SA6->( DBSeek( xFilial( 'SA6' ) + cBank + cBankUnit + cBankAcc ) )
			cBank		:= SA6->A6_COD
			cBankUnit	:= SA6->A6_AGENCIA
			cBankAcc	:= SA6->A6_NUMCON 
		EndIf  
	EndIf

	SE1->( DBGoTo( nRecNo ) )
	
 	If !Empty(SE1->E1_NUM)
		If nAmountRec == SE1->E1_SALDO
			aAutoSE1 := {   { "E1_PREFIXO"	 , SE1->E1_PREFIXO  , Nil },;
							{ "E1_NUM"		 , SE1->E1_NUM	    , Nil },;
							{ "E1_TIPO"	 	 , SE1->E1_TIPO  	, Nil },;
							{ "E1_TIPO"		 , SE1->E1_TIPO	    , Nil },;
							{ "E1_CLIENTE"	 , SE1->E1_CLIENTE  , Nil },;
							{ "E1_LOJA"		 , SE1->E1_LOJA	    , Nil },; 
							{ "AUTMOTBX"    , "NOR"             , Nil },; 
							{ "AUTBANCO"    , cBank            	, Nil },;
							{ "AUTAGENCIA"  , cBankUnit			, Nil },;
							{ "AUTCONTA"    , cBankAcc      	, Nil },;
							{ "AUTDTBAIXA"  , dDateRec         	, Nil },;
							{ "AUTDTCREDITO", dDateRec          , Nil },;
							{ "AUTVALREC"   , nAmountRec       	, Nil },;
							{ "AUTHIST"   	, cHist				, Nil } }
							
			aParam := { "SE1", "DownAReceivable" , aAutoSE1 }
	
			MSExecAuto( {|x,y| FINA070( x, y ) }, aAutoSE1, 3 )

			GRRAutoError( @cRet, "DownAReceivable", .F. )
		else
			cRet := STR0006 	//"Saldo do título a receber no financeiro está divergente com valor pago pela administradora financeira."  
		EndIf
	else
		cRet := STR0007 	//"Título a receber não localizado no financeiro."
	EndIf

    RestArea( aArea )

    FWFreeArray( aArea )
    FWFreeArray( aAutoSE1 )
    FWFreeArray( aErroAuto )
    FWFreeArray( aParam )
Return cRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} GrrNFSAut
Geração do documento de saida por meio de um pedido de venda liberado.

@param cCustomer	, caracter  , Codigo do cliente
@param cUnit		, caracter  , Loja
@param cSalesOrder	, caracter  , Codigo do pedido

@return cRet , caracter, Nota fiscal gerada

@author Squad NT
@since  05/08/2022
/*/
//-----------------------------------------------------------------------------
Function GrrNFSAut(cCustomer, cUnit, cSalesOrder)
Local aAreaAnt	:= GetArea()
Local aAreaSC5	:= SC5->( GetArea() ) 
Local aAreaSC6	:= SC6->( GetArea() )
Local aAreaSC9	:= SC9->( GetArea() )
Local aAreaSE4	:= SE4->( GetArea() )
Local aAreaSB1	:= SB1->( GetArea() )
Local aAreaSB2	:= SB2->( GetArea() )
Local aAreaSF4	:= SF4->( GetArea() )
Local aPvlNfs	:= {}
Local nPrcVen	:= 0
Local nSizeNF	:= TamSX3( "F2_DOC" )[1]
Local nSizeSerie := TamSX3( "F2_SERIE" )[1]
Local nSizeCustomer := TamSX3( "F2_CLIENTE" )[1]
Local nSizeUnit := TamSX3( "F2_LOJA" )[1]
Local cSerie	:= SuperGetMv( "MV_GRRNFSE",, "UNI" ) 
Local cNota		:= ""
Local cFilSC6	:= ""


SC5->( DbSetOrder(3) ) //C5_FILIAL, C5_CLIENTE, C5_LOJACLI, C5_NUM
SC9->( DBSetOrder(2) ) //C9_FILIAL, C9_CLIENTE, C9_LOJA, C9_PEDIDO, C9_ITEM
SC6->( DbSetOrder(1) ) //C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO

If SC5->( MsSeek( xFilial('SC5') + cCustomer + cUnit + cSalesOrder ) )

	cFilSC6 := xFilial( "SC6" ) 
	If SC6->( MsSeek( cFilSC6 + SC5->C5_NUM ) )
		
		While SC6->( !Eof() ) .And. SC6->C6_FILIAL + SC6->C6_NUM == cFilSC6 + SC5->C5_NUM
			
			If SC9->( MsSeek( xFilial('SC9') + SC5->C5_CLIENTE + SC5->C5_LOJACLI + SC6->C6_NUM + SC6->C6_ITEM ) )
				
				If Empty( SC9->C9_BLEST ) .And. Empty( SC9->C9_BLCRED ) .And. SC9->C9_BLWMS $ "05,06,07,  "
					// Posiciona na condicao de pagamento
					SE4->( DBSetOrder(1) )	//E4_FILIAL+E4_CODIGO
					SE4->( MsSeek( xFilial('SE4') + SC5->C5_CONDPAG, .F. )) 

					// Posiciona no produto
					SB1->( DBSetOrder(1) )	//B1_FILIAL+B1_COD
					SB1->( MsSeek( xFilial('SB1') + SC6->C6_PRODUTO, .F. ))

					// Posiciona no saldo em estoque
					SB2->( DBSetOrder(1) )	//B2_FILIAL+B2_COD+B2_LOCAL
					SB2->( MsSeek( xFilial('SB2') + SC6->C6_PRODUTO + SC6->C6_LOCAL, .F. ))

					// Posiciona no TES
					SF4->( DBSetOrder(1) ) 	//F4_FILIAL+F4_CODIGO
					SF4->( MsSeek( xFilial('SF4') + SC6->C6_TES, .F. ))

					nPrcVen := SC9->C9_PRCVEN
					//Converte o valor unitario em Reais quando pedido em outra moeda
					If ( SC5->C5_MOEDA <> 1 ) 
						nPrcVen := xMoeda( SC9->C9_PRCVEN, SC5->C5_MOEDA, 1, dDataBase )
					EndIf

					// Monta array para gerar a nota fiscal
					Aadd( aPvlNfs, { SC9->C9_PEDIDO,;
									SC9->C9_ITEM,;
									SC9->C9_SEQUEN,;
									SC9->C9_QTDLIB,;
									nPrcVen,;
									SC9->C9_PRODUTO,;
									.F.,;
									SC9->(RecNo()),;
									SC5->(RecNo()),;
									SC6->(RecNo()),;
									SE4->(RecNo()),;
									SB1->(RecNo()),;
									SB2->(RecNo()),;
									SF4->(RecNo()),;
									SC6->C6_LOCAL,;
									0,;
									SC9->C9_QTDLIB2} )
				EndIf
			EndIf
			SC6->( DBSkip() )
		EndDo
	EndIf
EndIf

If !Empty( aPvlNfs )	
	Pergunte( "MT460A",.F. )
	cNota := MaPvlNfs( aPvlNfs, cSerie, MV_PAR01==1, MV_PAR02==1, MV_PAR03==1, MV_PAR04==1, MV_PAR05==1, MV_PAR07, MV_PAR08, MV_PAR15==1, MV_PAR16==2 )
	SX6->( MSRUnlock() )
	
	If !Empty(cNota)
		DbSelectArea("SF2")
		SF2->( DbSetOrder( 1 ) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If SF2->(MSSeek( xFilial( "SF2" ) + Padr( cNota, nSizeNF ) + Padr( cSerie, nSizeSerie ) + Padr( cCustomer, nSizeCustomer ) + Padr( cUnit, nSizeUnit ) ) )
			LogMsg( "GrrNFAuto", 23, 6, 1, "", "", "GrrNFAuto ->" + I18N( STR0008, { cNota } ) )	//"Nota gerada #1"
			
			RecLock( "SF2", .F. )
				SF2->F2_DUPL := AllTrim( cNota )
			SF2->( MsUnLock() )
		Else
			// -------------------------------------------------------------
			// Limpa a variável de controle, pois não conseguiu encontrar o registro.
			// -------------------------------------------------------------	
			cNota := ''
		EndIf
	EndIf
EndIf

RestArea( aAreaSF4 )
RestArea( aAreaSB2 )
RestArea( aAreaSB1 )
RestArea( aAreaSE4 )
RestArea( aAreaSC9 )
RestArea( aAreaSC6 )
RestArea( aAreaSC5 )
RestArea( aAreaAnt )

FWFreeArray( aAreaSF4 )
FWFreeArray( aAreaSB2 )
FWFreeArray( aAreaSB1 )
FWFreeArray( aAreaSE4 )
FWFreeArray( aAreaSC9 )
FWFreeArray( aAreaSC6 )
FWFreeArray( aAreaSC5 )
FWFreeArray( aAreaAnt )
FWFreeArray( aPvlNfs )
Return cNota

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeQueryModel
Função responsável por criar a query base para localizar as informações do pedido de 
venda a partir do guid da fatura.

@param cOper, caracter, Identifica qual a query será retornada

@return caracter, String contendo a query base a ser executada.
@author  Marcia Junko
@since   23/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function MakeQueryModel( cOper )
    Local cQuery := ''
	Local cAuxQuery := ''
    
	cAuxQuery := " SELECT R_E_C_N_O_ ID " + ;
			" FROM " + RetSqlName( "SE1" ) + " SE1 " + ;
			" WHERE	E1_FILORIG = ? " + ;
				" AND E1_PREFIXO = ? " + ;
				" AND E1_NUM = ? " + ;
				" AND E1_TIPO = ? " + ;
				" AND D_E_L_E_T_ = ' ' "

    If cOper == 'QGRR030_AR'
		cQuery := cAuxQuery
    ElseIf cOper == 'QGRR030_AP'
		cQuery := StrTran( cAuxQuery, 'SE1', 'SE2' )
        cQuery := StrTran( cQuery, 'E1_', 'E2_' )
	EndIf
Return cQuery

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRFinPrediction
Avalia o tipo dos títulos financeiros e atualiza\transforma em títulos firmes com os 
valores da plataforma.

@param cKeySF2, caracter, chave da nota
@param cKeySE1, caracter, chave do título
@param oEvent, objetct, dados do evento que está sendo processado
@param cKeyBill, caracter, chave do título quando a origem é GRRI110

@return boolean, titulo efetivado com sucessso.
@author  Marcia Junko
@since   23/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRFinPrediction( cKeySF2, cKeySE1, oEvent, cKeyBill )
	Local aSvAlias	:= GetArea()
    Local aARInfo 	:= {}
    Local aAPInfo 	:= {}
    Local cData 	:= '' 
    Local nAPValue 	:= 0 
    Local nI 		:= 0
	Local nId 		:= 0
	Local lTxAdmPay	:= SuperGetMV( "MV_GRRTXPG", .T., .T. )
	Local lOk		:= .T.
	Local lSeek		:= .F. 
	Local cFilOrig	:= "" 
	Local cPrefix	:= ""
	Local cNum		:= ""

	Default cKeySF2  := ""
	Default cKeySE1  := ""
	Default cKeyBill := ""

	If !Empty(cKeySF2)
		SF2->( DBSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		lSeek := SF2->( MSSeek( cKeySF2 ) )
		If lSeek
			cFilOrig	:= SF2->F2_FILIAL
			cPrefix 	:= "GRR"
			cNum		:= SF2->F2_DOC
		EndIf
	ElseIf !Empty(cKeySE1)
		SE1->( DBSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
		lSeek := SE1->( MSSeek( cKeySE1 ) )
		If lSeek
			cFilOrig	:= SE1->E1_FILIAL
			cPrefix 	:= SE1->E1_PREFIXO
			cNum		:= SE1->E1_NUM
		EndIf	
	Else
		SE1->( DBSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
		lSeek := SE1->( MSSeek( cKeyBill ) )
		If lSeek
			cFilOrig	:= SE1->E1_FILIAL
			cPrefix 	:= "GRR"
			cNum		:= SE1->E1_NUM
		EndIf	
	EndIf

	If lSeek

        cData := GRRTreatData( oEvent:postingDate )
        cData := StrTran( cData, '-', '' )

        Aadd( aARInfo, { FFIN_VALUE, IIF(lTxAdmPay, oEvent:transactionValue, oEvent:postingValue) } )
        Aadd( aARInfo, { FFIN_DUEDATE, stod( cData ) } )

        For nI := 1 to len( oEvent:settlementFees )
            nAPValue += oEvent:settlementFees[ nI ]:amount
        Next
        Aadd( aAPInfo, { FFIN_VALUE, nAPValue } )
        Aadd( aAPInfo, { FFIN_DUEDATE, stod( cData )  } )

		//---------------------------------------------------------
		// Pesquisa pelo título firme a receber
		//---------------------------------------------------------
		nId := GRRFindFinancial( GRR_AR, cFilOrig, cPrefix, cNum, MVPROVIS)
		If nId > 0
            MsgAlert( STR0010 )	//"Transforma o título provisório a receber em firme."
			//---------------------------------------------------------
            // Transforma os títulos provisórios em firmes de acordo 
            // com os valores de provisão enviados pelo provedor.
            //---------------------------------------------------------
			lOk := GRRProvinReal( GRR_AR, cFilOrig, cPrefix, cNum, MVPROVIS, aARInfo )
		EndIf
		
		If lOk .And. lTxAdmPay
			//---------------------------------------------------------
			// Pesquisa pelo título firme a pagar ( taxa )
			//---------------------------------------------------------
			nId := GRRFindFinancial( GRR_AP, cFilOrig, cPrefix, cNum, MVPROVIS)
			If nId > 0
				MsgAlert( STR0012 )	//"Transforma o título provisório a pagar da taxa do provedor em firme."
				
				//---------------------------------------------------------
				// Transforma os títulos provisórios em firmes de acordo 
				// com os valores de provisão enviados pelo provedor.
				//---------------------------------------------------------
				lOk := GRRProvinReal( GRR_AP, cFilOrig, cPrefix, cNum, MVPROVIS, aAPInfo )
			EndIf
		EndIf
	EndIf

	If !Empty( aSvAlias )
		RestArea( aSvAlias )
	EndIf

	FWFreeArray( aSvAlias )
	FWFreeArray( aARInfo )
	FWFreeArray( aAPInfo )
Return lOk

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRProvinReal
Efetiva um titulo provisorio em firme com os valores enviados pela plataforma.

@param nExecType, number, indica o tipo de título a transformar para firme, onde 1=título
	a receber e 2=título a pagar.
@param cFilOrig, caracter, Filial do documento
@param cPrefix, caracter, Prefixo do titulo
@param cNum, caracter, Numero do titulo
@param cType, caracter, Tipo do titulo
@param aInfo, array, Vetor com as informações da plataforma.

@return boolean, titulo efetivado com sucessso.
@author  Marcia Junko
@since   24/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRProvinReal( nExecType, cFilOrig, cPrefix, cNum, cType, aInfo )
	Local cAlias 	:= ''
	Local nId		:= 0
	Local lOk 		:= .T.

	Default cType 	:= MVPROVIS

	nId := GRRFindFinancial( nExecType, cFilOrig, cPrefix, cNum, cType )

	If nExecType == GRR_AR
		cAlias := 'SE1'
	Else
		cAlias := 'SE2'
	EndIf

	If nId > 0
		lOk := ExecProvInReal( cAlias, nId, aInfo )
	EndIf
Return lOk

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecProvInReal
Roda a ExecAuto para transformar um título provisório em firme.

@param cAlias, caracter, Alias da tabela que está sendo movimentada
@param nRecno, number, Recno do registro para ser posicionado
@param aInfo, array, Vetor com as informações da plataforma.
@param lAutomato, boolean, Indica que a função está sendo chamada pela automação

@return boolean, titulo efetivado com sucessso.
@author  Marcia Junko
@since   24/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function ExecProvInReal( cAlias, nRecno, aInfo, lAutomato )
	Local aSvAlias := GetArea()
	Local aAuto := {}
	Local aProv := {}
	Local aFields := {}
	Local nI := 0
	Local nPos := 0
	Local cError := ''
	Local lOk := .T.

	Default lAutomato := .F. 

	Private lMsErroAuto		:= .F. 
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.	

	( cAlias )->( DBGoTo( nRecno ) )

	aFields := { "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_CLIENTE", "E1_LOJA", "E1_NATUREZ", ;
		"E1_EMISSAO", "E1_VENCTO", "E1_VENCREA", "E1_HIST", "E1_BOLETO", "E1_VALOR" }

	aProvFields := { "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_CLIENTE", "E1_LOJA" }

	If cAlias == 'SE2'
		//---------------------------------------------------------
		// Troca os prefixos do array de campos
		//---------------------------------------------------------
		ChangePrefix( @aFields, 'E1_', 'E2_' ) 
		
		nPos := Ascan( aFields, {|x| x== "E2_CLIENTE" })
		aFields[ nPos ] := "E2_FORNECE"

		nPos := Ascan( aFields, {|x| x== "E2_BOLETO" })
		aDel( aFields, nPos )
		aSize( aFields, len( aFields ) - 1 )

		//---------------------------------------------------------
		// Troca os prefixos do array de campos provisórios
		//---------------------------------------------------------
		ChangePrefix( @aProvFields, 'E1_', 'E2_' ) 
		
		nPos := Ascan( aProvFields, {|x| x== "E2_CLIENTE" })
		aProvFields[ nPos ] := "E2_FORNECE"
	EndIf

	//---------------------------------------------------------
	// Monta o array para a execauto
	//---------------------------------------------------------
	For nI := 1 to len( aFields )
		aAdd( aAuto, { aFields[ nI ], ( cAlias )->&( aFields[ nI ] ), NIL } )
	Next
	nPos := Ascan( aAuto, {|x| "_TIPO" $ Alltrim( x[1] )  } )
	aAuto[ nPos ][ 2 ] := Iif( cAlias == "SE1", "DP", "TX" )

	If ( nPos := Ascan( aAuto, {|x| "_BOLETO" $ Alltrim( x[1] ) } ) ) > 0
		aAuto[ nPos ][ 2 ] := "2"
	EndIf
	 
	//---------------------------------------------------------
	// Atribui os valores encaminhados pela plataforma
	//---------------------------------------------------------
	For nI := 1 to len( aInfo )
		If ( nPos := Ascan( aAuto, {|x| aInfo[ nI ][ 1 ] $ Alltrim( x[1] ) } ) ) > 0
			aAuto[ nPos ][ 2 ] := aInfo[ nI ][2]
		EndIf
		If aInfo[ nI ][ 1 ] $ '_VENCTO'
			If ( nPos := Ascan( aAuto, {|x| '_VENCREA' $ Alltrim( x[1] ) } ) ) > 0
				aAuto[ nPos ][ 2 ] := aInfo[ nI ][2]
			EndIf
		EndIf
	Next

	//---------------------------------------------------------
	// Monta o array de provisório para a execauto
	//---------------------------------------------------------
	aAdd( aProv, { } )
	For nI := 1 to len( aProvFields )
		aAdd( aProv[1], { aProvFields[ nI ], ( cAlias )->&(aProvFields[ nI ] ), NIL } )
	Next

	aParam := { cAlias , "ExecProvInReal" , aAuto } 

	//---------------------------------------------------------
	// Chama a execauto para transformar o título provisório em 
	// firme.
	//---------------------------------------------------------
	If cAlias == "SE1"
		MSExecAuto({|x,y,z| FINA040(x,y,z) }, aAuto, 6, aProv )
	else
		MsExecAuto({|a,b,c,d,e,f,g,h,i,j| FINA050(a,b,c,d,e,f,g,h,i,j) }, aAuto,, 6,,,,,, aProv )
	EndIf	

	lOK := GRRAutoError( @cError, "ExecProvInReal" )
	
	RestArea( aSvAlias )
	
	FWFreeArray( aSvAlias )
	FWFreeArray( aAuto )
	FWFreeArray( aProv )
	FWFreeArray( aFields )
Return lOK

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSettleBill
Realiza a baixa do título financeiro.

@param cKeySF2, caracter, chave da nota
@param cKeySE1, caracter, chave do título
@param oEvent, objetct, dados do evento que está sendo processado
@param cKeyBill, caracter, chave do título quando a origem é GRRI110

@return boolean, titulo efetivado com sucessso.
@author  Marcia Junko
@since   23/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRSettleBill( cKeySF2, cKeySE1, oEvent, cKeyBill )
	Local aSvAlias	:= GetArea()
	Local aInfo := {}
	Local lTxAdmPay	:= SuperGetMV( "MV_GRRTXPG", .T., .T. )
	Local lOk		:= .T.
	Local cFilOrig	:= ""
	Local cPrefix	:= ""
	Local cNum		:= ""
	Local lSeek		:= .F.

	Default cKeySF2  := ""
	Default cKeySE1  := ""
	Default cKeyBill := ""

	If !Empty(cKeySF2)
		SF2->( DBSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		lSeek := SF2->( MSSeek( cKeySF2 ) )
		If lSeek
			cFilOrig	:= SF2->F2_FILIAL
			cPrefix 	:= "GRR"
			cNum		:= SF2->F2_DOC
		EndIf
	ElseIf !Empty(cKeySE1)
		SE1->( DBSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
		lSeek := SE1->( MSSeek( cKeySE1 ) )
		If lSeek
			cFilOrig	:= SE1->E1_FILIAL
			cPrefix 	:= SE1->E1_PREFIXO
			cNum		:= SE1->E1_NUM
		EndIf
	Else
		SE1->( DBSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
		lSeek := SE1->( MSSeek( cKeyBill ) )
		If lSeek
			cFilOrig	:= SE1->E1_FILIAL
			cPrefix 	:= "GRR"
			cNum		:= SE1->E1_NUM
		EndIf
	EndIf

	If lSeek
		cData := GRRTreatData( oEvent:postingDate )
		cData := StrTran( cData, '-', '' )

		Aadd( aInfo, { "AUTMOTBX", "NOR" } )
		Aadd( aInfo, { "AUTDTBAIXA", stod( cData ) } )
		Aadd( aInfo, { "AUTDTCREDITO", stod( cData ) } )
		
		Aadd( aInfo, { "AUTVALREC", IIF(lTxAdmPay, oEvent:transactionValue, oEvent:postingValue) } )

		If !Empty( oEvent:detail )
			Aadd( aInfo, { "AUTHIST", oEvent:detail  } )
		EndIf

		lOk := GRRSettleExec( GRR_AR, cFilOrig, cPrefix, cNum, 'DP', aInfo, oEvent )

		If lOk .And. lTxAdmPay
			aInfo := {}
			Aadd( aInfo, { "AUTMOTBX", "DEB" } )
			Aadd( aInfo, { "AUTDTBAIXA", stod( cData ) } )
			Aadd( aInfo, { "AUTDTDEB", stod( cData ) } )
			Aadd( aInfo, { "AUTVLRPG", oEvent:settlementFees[1]:amount } )
			If !Empty( oEvent:detail )
				Aadd( aInfo, { "AUTHIST", oEvent:detail  } )
			EndIf
			lOk := GRRSettleExec( GRR_AP, cFilOrig, cPrefix, cNum, 'TX', aInfo, oEvent )
		EndIf
	EndIf

	RestArea( aSvAlias )
	
	FWFreeArray( aSvAlias )
	FWFreeArray( aInfo )
Return lOk


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRSettleExec
Efetiva a baixa do título com as informações da plataforma.

@param nExecType, number, indica o tipo de título a transformar para firme, onde 1=título
	a receber e 2=título a pagar.
@param cFilOrig, caracter, Filial do documento
@param cPrefix, caracter, Prefixo do titulo
@param cNum, caracter, Numero do titulo
@param cType, caracter, Tipo do titulo
@param aInfo, array, Vetor com as informações da plataforma.
@param oEvent, objetct, dados do evento que está sendo processado
@param lAutomato, boolean, Indica que a função está sendo chamada pela automação

@return boolean, titulo efetivado com sucessso.
@author  Marcia Junko
@since   24/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRSettleExec( nExecType, cFilOrig, cPrefix, cNum, cType, aInfo, oEvent, lAutomato )
    Local aARInfo	:= {}
    Local aAPInfo	:= {}
	Local cAlias 	:= ''
    Local cData 	:= ''
    Local nAPValue	:= 0
	Local nValue 	:= 0
    Local nI 		:= 0
	Local nId 		:= 0
	Local lOk 		:= .T.
	Local lTxAdmPay	:= SuperGetMV( "MV_GRRTXPG", .T., .T. )

	Default cType 	:= MVPROVIS
	Default lAutomato := .F.

	nId := GRRFindFinancial( nExecType, cFilOrig, cPrefix, cNum, cType )
	
	//---------------------------------------------------------
	// Se não tiver o título firme, verifica se ele ainda está
	// como provisório e transforma ele em firme.
	//---------------------------------------------------------
	If nId == 0
		cData := GRRTreatData( oEvent:postingDate )
		cData := StrTran( cData, '-', '' )

		Aadd( aARInfo, { FFIN_VALUE, IIF(lTxAdmPay, oEvent:transactionValue, oEvent:postingValue) } )
		Aadd( aARInfo, { FFIN_DUEDATE, stod( cData ) } )

		For nI := 1 to len( oEvent:settlementFees )
			nAPValue += oEvent:settlementFees[ nI ]:amount
		Next
		Aadd( aAPInfo, { FFIN_VALUE, nAPValue } ) 
		Aadd( aAPInfo, { FFIN_DUEDATE, stod( cData )  } )
		
		GRRProvinReal( nExecType, cFilOrig, cPrefix, cNum, MVPROVIS, Iif( nExecType == 1, aARInfo, aAPInfo ) )

		If nExecType == GRR_AP
			nValue := nAPValue
		EndIf
		//---------------------------------------------------------
		// procura o título firme
		//---------------------------------------------------------
		nId := GRRFindFinancial( nExecType, cFilOrig, cPrefix, cNum, cType )
	EndIf
	

	If nExecType == GRR_AR
		cAlias := 'SE1'
	Else
		cAlias := 'SE2'
	EndIf

	iF nId > 0
		lOk := ExecSettle( cAlias, nId, oEvent, aInfo, nValue, lAutomato )		
	End

    FWFreeArray( aARInfo )
    FWFreeArray( aAPInfo )
Return lOk

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecSettle
Roda a ExecAuto para baixa do título financeiro

@param calias, caracter, Alias da tabela que está sendo movimentada
@param nRecno, number, Recno do registro para ser posicionado
@param oEvent, object, objeto do evento de conciliação
@param aInfo, array, Vetor com as informações da plataforma.
@param nValue, number, Valor do saldo a verificar
@param lAutomato, boolean, Indica que a função está sendo chamada pela automação

@return boolean, titulo baixado com sucessso.
@author  Marcia Junko
@since   26/01/2023
/*/
//-------------------------------------------------------------------------------------
Static Function ExecSettle( cAlias, nRecno, oEvent, aInfo, nValue, lAutomato )
	Local aSvAlias := GetArea()
	Local aSettleFields := {}
	Local aAuto := {}
	Local aProv := {}
	Local aFields := {}
	Local aParam := {}
	Local nI := 0
	Local nPos := 0
	Local nAmount := 0
    Local cRet := ""     
	Local cBank	:= ""
	Local cBankUnit := ""
	Local cBankAcc := ""
	Local lOk := .T.
	Local bExec := {|x,y| FINA070( x, y ) } //bloco que será executado pelo MsExecAuto
	Local lTxAdmPay	:= SuperGetMV( "MV_GRRTXPG", .T., .T. )
	Default nValue := 0
	Default lAutomato := .F.

	Private lMsErroAuto		:= .F.   
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.	
	
	If nValue == 0 
		If cAlias == "SE1"
			nAmount := IIF(lTxAdmPay, oEvent:transactionValue, oEvent:postingValue)    
		Else
			For nI := 1 to len( oEvent:settlementFees )
				nAmount += oEvent:settlementFees[ nI ]:amount
			Next
		EndIf 
	Else
		nAmount := nValue
	EndIf

	cBank := PadR( oEvent:bankCode, TamSX3( "A6_COD" )[1] ) 
	cBankUnit := PadR( oEvent:bankBranchCode, TamSX3( "A6_AGENCIA" )[1] ) 
	cBankAcc := PadR( oEvent:bankAccountNumber, TamSX3( "A6_NUMCON" )[1] ) 

	( cAlias )->( DBGoTo( nRecno ) )

	If !Empty( ( cAlias )->&( PrefixoCpo( cAlias ) + "_NUM"  ) )
		If nAmount == ( cAlias )->&( PrefixoCpo( cAlias ) + "_SALDO" )
			aFields := { "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_CLIENTE", "E1_LOJA", "E1_NATUREZA" }

			aSettleFields := { "AUTBANCO", "AUTAGENCIA", "AUTCONTA" }

			//---------------------------------------------------------
			// Troca os prefixos do array de campos
			//---------------------------------------------------------
			If cAlias == 'SE2'
				ChangePrefix( @aFields, 'E1_', 'E2_' ) 

				nPos := Ascan( aFields, {|x| x== "E2_CLIENTE" })
				aFields[ nPos ] := "E2_FORNECE"
				bExec := {|x,y| FINA080( x, y ) }
			EndIf
			
			//---------------------------------------------------------
			// Monta o array para a execauto
			//---------------------------------------------------------
			For nI := 1 to len( aFields )
				aAdd( aAuto, { aFields[ nI ], ( cAlias )->&( aFields[ nI ] ), NIL } )
			Next
			
			For nI := 1 to len( aSettleFields )
				aAdd( aAuto, { aSettleFields[ nI ], '', NIL } )
			Next
				
			If ( nPos := Ascan( aAuto, {|x| "AUTBANCO" $ Alltrim( x[1] ) } ) ) > 0
				aAuto[ nPos ][ 2 ] := cBank
			EndIf

			If ( nPos := Ascan( aAuto, {|x| "AUTAGENCIA" $ Alltrim( x[1] )  } ) ) > 0
				aAuto[ nPos ][ 2 ] := cBankUnit 
			EndIf

			If ( nPos := Ascan( aAuto, {|x| "AUTCONTA" $ Alltrim( x[1] ) } ) ) > 0 
				aAuto[ nPos ][ 2 ] := cBankAcc
			EndIf

			
			//---------------------------------------------------------
			// Atribui os valores encaminhados pela plataforma
			//---------------------------------------------------------
			For nI := 1 to len( aInfo )
				aAdd( aAuto, { aInfo[ nI ][1], aInfo[ nI ][2], NIL } )
			Next

			aParam := { cAlias , Iif( cAlias == "SE1", "AR", "AP" ) + "SettleBill" , aAuto } 

			//---------------------------------------------------------
			// Chama a execauto para baixar os títulos
			//---------------------------------------------------------
			MSExecAuto( bExec, aAuto, 3 )			

			GRRAutoError( @cRet, "ExecSettle", .F. )
		else
			cRet := STR0013		//"Saldo do título no financeiro diverge do valor informado pelo provedor."  
		EndIf
	else
		cRet := STR0007		//"Título a receber não localizado no financeiro."
	EndIf

	iF !Empty( cRet )
		lOK := .F.
		LogMsg( "ExecSettle", 23, 6, 1, "", "", cRet )
	EndIf

	RestArea( aSvAlias )
	
	FWFreeArray( aSvAlias )
	FWFreeArray( aAuto )
	FWFreeArray( aProv )
	FWFreeArray( aFields )
	FWFreeArray( aSettleFields )
	FWFreeArray( aParam )
Return lOK

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRNewFinancial
Roda a ExecAuto para baixa do título financeiro

@param nExecType, number, indica o tipo de título a transformar para firme, onde 1=título
	a receber e 2=título a pagar.
@@param 	cFilOrig, caracter, Filial do documento
@param 		cPrefix, caracter, Prefixo do titulo
@param 		cNum, caracter, Numero do titulo
@param 		cInstallment, caracter, Parcela do titulo
@param 		cType, caracter, Tipo do titulo
@param 		nValue, caracter, Valor das taxas
@param 		dDueDate, caracter, Vencimento
@param 		cHist, caracter, Historico
@param		cNature, caracter, Código da Natureza (Despesa)

@return boolean, titulo efetivado com sucessso.
@author  Marcia Junko
@since   26/01/2023
/*/
//-------------------------------------------------------------------------------------

Function GRRNewFinancial( nTypeExec, cFilOrig, cPrefix, cNum, cInstallment, cType, nValue, dDueDate, cHist, cNature )
	Local lOK := .T.

	If nTypeExec == GRR_AR 
		lOk := NewAReceivable( cFilOrig, cPrefix, cNum, cType, cInstallment, nValue, dDueDate, cHist, cNature )
	else
		lOk := NewAPayment( cFilOrig, cPrefix, cNum, cInstallment, cType, nValue, dDueDate, cHist, cNature )
	EndIf
Return lOK

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRPayFinancial
Realiza a baixa do título financeiro

@param nExecType, number, indica o tipo de título para efetuar a baixa, onde 1=título
	a receber e 2=título a pagar.
@param nRecNo	, numerico  , Recno da SE1.
@param dDatePay	, data      , Data de pagamento
@param nValue	, numerico  , Valor pago
@param cHist, caracter, Historico

@return boolean, titulo efetivado com sucessso.
@author  Marcia Junko
@since   26/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRPayFinancial( nTypeExec, nRecNo, dDatePay, nValue, cHist )
	Local lOK := .T.
	Local cRet := ''

	If nTypeExec == GRR_AR
		cRet := DownAReceivable( nRecNo, dDatePay, nValue, cHist )
	else
		cRet := DownAPayment( nRecNo, dDatePay, nValue, nValue ,cHist )
	EndIf

	If !Empty( cRet )
		lOk := .F.
		LogMsg( "GRRPayFinancial", 23, 6, 1, "", "", "GRRPayFinancial -> " + cRet )
	EndIf
Return lOK

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRFindFinancial
Função que procura o título financeiro de acordo com as informações passadaas

@param nExecType, number, indica o tipo de título a transformar para firme, onde 1=título
	a receber e 2=título a pagar.
@param cFilOrig, caracter, Filial do documento
@param cPrefix, caracter, Prefixo do titulo
@param cNum, caracter, Numero do titulo
@param cType, caracter, Tipo do titulo

@return number, R_E_C_N_O_ do registro na HRH
@author  Marcia Junko
@since   27/01/2023
/*/
//-------------------------------------------------------------------------------------
Function GRRFindFinancial( nExecType, cFilOrig, cPrefix, cNum, cType )
	Local aSvAlias := Getarea()
    Local nID := 0
	Local cQryName 	:= ''
	Local cQryAlias := ''
	Local oQuery

	Default cType 	:= MVPROVIS

	If nExecType == GRR_AR
		cQryName := 'QGRR030_AR'
	Else
		cQryName := 'QGRR030_AP'
	EndIf

	oQuery := GRRGetQuery( cQryName )
	oQuery:SetString( 1, cFilOrig ) 
	oQuery:SetString( 2, Alltrim( cPrefix ) )
	oQuery:SetString( 3, Alltrim( cNum ) )
	oQuery:SetString( 4, Alltrim( cType ) )

	cQryAlias := MPSysOpenQuery( oQuery:GetFixQuery() )

	If ( cQryAlias )->( !Eof() )	   
		nId := ( cQryAlias )->ID 
	EndIf
	( cQryAlias )->( DBCloseArea() )

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FreeObj( oQuery )
Return nId

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ChangePrefix
Executa a troca de prefixo em campos contidos em um vetor.

@param @aArray, array, indica o array onde o prefixo deve ser substituído
@param cFind, caracter, Prefixo a pesquisar
@param cReplace, caracter, Prefixo de substituição

@author  Marcia Junko
@since   26/04/2024
/*/
//-------------------------------------------------------------------------------------
Static Function ChangePrefix( aArray, cFind, cReplace )
	Local nI := 0

	For nI := 1 to len( aArray )
		aArray[ nI ] := StrTran( aArray[ nI ], cFind, cReplace )
	Next	
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeAPBatchFee
Função que cria o título a pagar baixado contra o provedor referente a taxa do lote.

@param oResult, object, conteúdo do response
@param aInvoices, array, informações de nota
@param cKeySE1, string, chave do titulo a receber

@return boolean, indica se processou a taxa do lote.
@author  Marcia Junko
@since   20/01/2023
/*/
//-------------------------------------------------------------------------------------
Function MakeAPBatchFee( oResult, aInvoices, cKeySE1 )
    Local aSvAlias  := GetArea()
    Local nValue    := 0
    Local nId       := 0
    Local cBKPFil   := ''
    Local cNum      := ''
    Local cHist     := ''
    Local cData     := ''
    Local lOk       := .T.
    Local cFilOrig  := ""
    Local cPrefix   := ""
    Local cNumAR    := ""

    //---------------------------------------------------------
    // Armazena a informação da filial logada
    //---------------------------------------------------------
    cBKPFil := cFilAnt

    If !Empty(aInvoices)
		SF2->( DBSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If SF2->( MSSeek( aInvoices[1] ) )
			cFilOrig	:= SF2->F2_FILIAL
			cPrefix 	:= "GRR"
			cNumAR		:= SF2->F2_DOC
		EndIf
	Else
		SE1->( DBSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
		If SE1->( MSSeek( cKeySE1 ) )
			cFilOrig	:= SE1->E1_FILIAL
			cPrefix 	:= SE1->E1_PREFIXO
			cNumAR		:= SE1->E1_NUM
		EndIf
	EndIf 

    If !Empty(cNumAR) 

        nId := GRRFindFinancial( GRR_AR, cFilOrig, cPrefix, Alltrim( cNumAR ), "DP" )

        If nId > 0
            SE1->( DBGoto( nId ) )
        
            cData   := GRRTreatData( oResult[ 'conciliationDate' ] )
            cData   := StrTran( cData, '-', '' )
            cNum    := ProxTitulo( "SE2", "GRB" )
            nValue  := oResult[ 'batchFee' ]
            cHist   := I18N( STR0009, { cData } )    //"Taxa de transação do lote #1 do GRR."

            lOk := GRRNewFinancial( GRR_AP, SE1->E1_FILORIG, 'GRB', cNum, '', "TX",;
                                        nValue, stod( cData ), cHist, SE1->E1_NATUREZ )

            If lOk
                nId := GRRFindFinancial( GRR_AP, cFilOrig, "GRB", cNum, "TX" )

                If nId > 0 
                    lOk := GRRPayFinancial( GRR_AP, nId, stod( cData ), nValue, cHist )

                    If lOk
                        LogMsg( "MakeAPBatchFee", 23, 3, 1, "", "", I18N( STR0010, { cData } ) )   //"Gera o título a pagar baixado com o valor da taxa do lote de #1"
                    EndIf
                EndIf
            EndIf
            
        EndIf

	EndIf
    
    //---------------------------------------------------------
    // Volta a informação da filial logada
    //---------------------------------------------------------
    cFilAnt := cBKPFil

    If !Empty( aSvAlias )
        RestArea( aSvAlias )
    EndIf

    FWFreeArray( aSvAlias )
Return lOk
