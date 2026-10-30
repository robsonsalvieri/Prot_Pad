#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "STBCORRESPONDENTBANKING.CH"

//-------------------------------------------------------------------
/*/ {Protheus.doc} STBRecCorBank
Prepara dados para gravacao do Correspondente Bancario nas funcoes financeiras.

@param   	oRetCB			Objeto com retorno da transacao CB no TEF
@param   cSimbCoin		Simblo da moeda
@param   cNumCup 		Numero do cupom	
@param   cPref 			Prefixo do título
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STBRecCorBank( oRetCB , cSimbCoin , cNumCup, cPref )

Local cParcela		:= LjParcela(1, SuperGetMV("MV_1DUP"))		// Parcela
Local cNumCupFis		:= ""											// Numero do cupom fiscal
Local cNatureza		:= ""											// Natureza da operacao
Local cCliente		:= SuperGetMV("MV_CLIPAD",, "")				// Cliente padrao
Local cLoja			:= SuperGetMV("MV_LOJAPAD",, "")			// Loja padrao
Local dEmiss			:= dDataBase									// Data de emissao
Local dVencto			:= dDataBase									// Data de vencimento
Local cHist			:= "CORRESP. BANC." + " - " + STFGetStation("CODIGO")	// Historico da operacao  "CORRESPONDENTE BANCARIO"
Local nMoeda			:= 1											// Tipo da moeda
Local cPrw			:= "LOJXTEF"									// Programa que gerou o lancamento
Local nValOperac		:= 0										 	// Valor da operacao    
Local cPortado		:= xNumCaixa()								// Caixa que realizou a opercao
Local cTipo			:= ""					   						// Sigla da forma de pagamento
Local aDataCB			:= {}											// Array com dados do CB para gerar financeiro
Local cBanco 			:= Space(TamSX3("EF_BANCO")[1])		   		// Banco do cliente
Local cAgencia		:= Space(TamSX3("EF_AGENCIA")[1])			// Agencia
Local cConta			:= Space(TamSX3("EF_CONTA")[1])				// Conta
Local cNumChq			:= Space(TamSX3("EF_NUM")[1])				// Numero do Cheque
Local cCompensa		:= Space(TamSX3("EF_COMP")[1])				// Compensação
Local cRg				:= Space(TamSX3("EF_RG")[1]	)    			// Rg do cliente
Local cTel			:= Space(TamSX3("EF_TEL")[1])           	// Telefone
Local lTerceiro		:= .F.											// Indica se o cheque e de terceiro
Local lRet			:= .F.                                // Controla o retorno da funcao
Local lRetRmtExc		:= .F.                                // Controla o retorno da funcao
Local cLabelDoc    	:= ""                                	// Contem a string de Label quando o pagamento for com cheque
Local cNsuSitef    	:= ""										  	// Numero de NSU-Sitef de pagamento
Local aNotas		:= {}							//Array com numeração de NFce
Local cCupom		:= ""							//Numero do cupom Fiscal
Local cMsgLog		:= ""							//Log de Mensagem
Local lLgSerNFisc := SLG->(ColumnPos("LG_SERNFIS")) > 0 
Local lFisPrint		:= STFGetCfg("lUseECF")			//usa impressora fiscal

Default oRetCB		:= Nil
Default cSimbCoin	:= ""
Default cNumCup		:= ""
Default cPref    	:= ""


ParamType 0  Var oRetCB			AS Object		Default Nil
ParamType 1  Var cSimbCoin 	AS Character	Default ""
ParamType 2  Var cNumCup 		AS Character	Default ""
ParamType 3  Var cPref 		AS Character	Default ""

If Empty(cPref)
	//Rotina anterior, o numero do cupom é o numero do ecf e já veio incrementado
	cPref := STFGetStat("LG_SERIE")
	
	If !lFisPrint
		If lLgSerNFisc .AND. !Empty(cPref := STFGetStation("SERNFIS"))
			LjxDNota( cPref , 3, .F., 1, @aNotas ,,,,,,,,,,,,, "DOCNF")  // DOC/SERIE
			
			If Len(aNotas) > 0 .AND. Len(aNotas[1]) > 1
				cNumCup := aNotas[1][2]
			Else
				LjGrvLog( "STBRecCorBank2","Falha ao obter numeração de Série Não Fiscal, será mantido o número da última venda " + cNumCup )				
			EndIf
		Else
			cMsgLog :=  STR0003 //"Para transações em Correspondente Bancário é necessário criar e informar o campo LG_SERNFIS, criado no compatibilizador U_UPDLO111"
			STFMessage("STBRecCorBank", "ALERT", cMsgLog)
			STFShowMessage("STBRecCorBank")	
			LjGrvLog( "STBRecCorBank",cMsgLog)	
		EndIf
	EndIf

EndIf


// Monta informacoes da transacao TEF
cNsuSitef    	:= oRetCB:CAUTORIZ 			// Numero de NSU-Sitef de pagamento 
nValOperac 	:= oRetCB:NVLRTOTCB 			// Pega Valor do Titulo
cTipo 			:= AllTrim(cSimbCoin)		// Simbolo da moeda utilizada no pagamento pelo TEF
cNatureza 		:= STGetDscPag( cTipo )		// Natureza da operacao

//Itau e BB So realizam pagamento a vista

If cTipo == "CD"
	cNatureza 		:= SuperGetMV("MV_NATTEF")
EndIf

If cTipo == "CH"

	cTel				:= IIF(Valtype(oRetCB:cTelefone)== "N", Str(oRetCB:cTelefone), oRetCB:cTelefone)
	cBanco 			:= STR(oRetCB:NBANCO		)
	cAgencia			:= STR(oRetCB:NAGENCIA	)
	cConta				:= STR(oRetCB:NCONTA		)
	cNumChq			:= STR(oRetCB:NCHEQUE	)
	cCompensa			:= STR(oRetCB:NCOMPENSA	)
	
EndIf	


// Realizado comunicacao via componente de comunicacao STBRemoteExecute 
// Efetua a gravacao do cancelamento no server 
lContinua := STBRemoteExecute( "LjTefGrvCB" , { cPref		, cNumCup		, cParcela		, cTipo		, ;
														cNatureza	, cCliente		, cLoja		, dEmiss		, ;
														dVencto	, cHist		, nMoeda		, cPrw			, ;
														nValOperac	, cPortado		, cBanco 		, cAgencia		, ;
														cConta 	, cNumChq		, cCompensa 	, cRg 			, ;
														cTel		, lTerceiro 	, cNsuSitef				  }	, ;													
														NIL, .T. , @lRetRmtExc )

// Se nao executou a rotina no BackOffice
If !lContinua .OR. !lRetRmtExc
   	STFMessage("STCorBank","STOP", STR0002 ) //"Atencao, Nao foi possivel gravar as infomacões financeiras do Correspondente Bancário, será gravado em modo de contingência" 
EndIf      

Return lRet  






// Todo Tirar essa rotina e colocar para buscar do model
// TODO  
Function STGetDscPag(cTypePag)

Local cDescription := ""			// Descricao da forma de pagamento

Default cTypePag := ""				// Tipo de pagamento a ser pesquisado

//Pega a descricao da forma de pagamento no SX5
DbSelectArea("SX5")
DbSeek(xFilial("SX5") + "24")
//Procura a forma na tabela 24
While !Eof() .AND. SX5->X5_FILIAL == xFilial("SX5") .AND. SX5->X5_TABELA == "24"
    //Verifica se encontrou a forma
	If AllTrim(SX5->X5_CHAVE) == cTypePag
		//Guarda a descricao da forma
		cDescription := Alltrim(SX5->X5_DESCRI)
		Exit
	EndIf	
	DbSkip()
End 

Return cDescription

//-------------------------------------------------------------------
/*/ {Protheus.doc} STBGrvCorBkn
Gravacao do correspondente bancario

@param   	
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	lRet
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STBTefGrvCB (      	cPref		, cNumTit	, cParcela	, cTipo		, ;
								cNatureza	, cCliente	, cLoja	, dEmiss	, ;
								dVencto	, cHist	, nMoeda	, cRotina	, ;
								nValtit 	, cPortado	, cBanco	, cAgencia	, ;
								cConta		, cNumChq	, cCompensa , cRg 		, ;
								cTel		, lTerceiro , cNsuSiTef )
	
Local aDados	:= {}			// Campos do SE1 que necessitam ser enviados
Local aArea	    := GetArea() //Salva a area

Private lMsErroAuto := .F. 

aDados  := {	{ "E1_PREFIXO"	,cPref						,Nil} ,;
			{ "E1_NUM"	  	,cNumTit 					,Nil} ,;
			{ "E1_PARCELA" 	,cParcela					,Nil} ,;
			{ "E1_TIPO"	 	,cTipo						,Nil} ,;
			{ "E1_NATUREZ" 	,cNatureza					,Nil} ,;
          	{ "E1_CLIENTE" 	,cCliente					,Nil} ,;
          	{ "E1_LOJA"	  	,cLoja						,Nil} ,;
          	{ "E1_EMISSAO" 	,dEmiss 					,Nil} ,;
       	{ "E1_VENCTO"  	,dVencto 					,Nil} ,;
       	{ "E1_VENCREA" 	,DataValida(dVencto)		,Nil} ,;
       	{ "E1_HIST" 	,cHist						,Nil} ,;
       	{ "E1_MOEDA" 	,nMoeda						,Nil} ,;
			{ "E1_ORIGEM"	,cRotina					,Nil} ,;
			{ "E1_FLUXO"	,"S"						,Nil} ,;
	   		{ "E1_VALOR"	,nValTit					,Nil} ,;
		   	{ "E1_PORTADO"	,cPortado					,Nil} ,;
		   	{ "E1_BCOCHQ"	,cBanco						,Nil} ,;
		   	{ "E1_AGECHQ" 	,cAgencia					,Nil} ,;
		   	{ "E1_CTACHQ"	,cConta						,Nil} ,;
		   	{ "E1_DOCTEF"	,cNsuSiTef                  ,Nil} }

MSExecAuto( { |x,y| Fina040( x, y ) }, aDados, 3 ) //Inclusao

If cTipo == "CH"
	LJRecGrvCH( cBanco  , cAgencia , cConta   , cNumChq	,;
 					nValTit , dEmiss   , cCompensa, cRG    	,;
                cTel    , lTerceiro, cPref	  , cNumTit	,;
    			cParcela, cTipo  )
 	RecLock("SEF", .F.)
 	REPLACE SEF->EF_CLIENTE WITH cCliente
 	REPLACE SEF->EF_LOJACLI WITH SA1->A1_LOJA
 	REPLACE SEF->EF_EMITENT	WITH SA1->A1_NOME
 	REPLACE SEF->EF_NUMNOTA	WITH cNumTit
 	REPLACE SEF->EF_SERIE	WITH cPref
 	MSUnlock()
EndIf
	
If cTipo == SuperGetMV( "MV_SIMB1" )
	aDados	:= {	{ "E1_PREFIXO" 	,E1_PREFIXO			, Nil},	;// 01
					{ "E1_NUM"     	,E1_NUM				, Nil},	;// 02
					{ "E1_PARCELA" 	,E1_PARCELA			, Nil},	;// 03
					{ "E1_TIPO"    	,E1_TIPO			, Nil},	;// 04
					{ "E1_MOEDA"    ,E1_MOEDA			, Nil},	;// 05
					{ "E1_TXMOEDA"	,E1_TXMOEDA			, Nil},	;// 06
					{ "E1_ORIGEM"	,E1_ORIGEM			, Nil},	;// 07
					{ "AUTVALREC"	,E1_VALOR  			, Nil},	;// 06
					{ "AUTMOTBX"  	,"NOR"				, Nil},	;// 07
					{ "AUTDTBAIXA"	,dDataBase			, Nil},	;// 08
					{ "AUTDTCREDITO",dDataBase			, Nil},	;// 09
					{ "AUTHIST"   	,cHist				, Nil}  }// 13
    
	// Verifica se deu algum erro no MSExecAuto anterior
	If !lMsErroAuto
		
		MSExecAuto( { |x,y| FINA070( x, y ) }, aDados, 3 )
		
	Else
		DisarmTransaction()
	EndIf
Endif
	
lRet := .T.

RestArea( aArea )
	
Return( lRet )


