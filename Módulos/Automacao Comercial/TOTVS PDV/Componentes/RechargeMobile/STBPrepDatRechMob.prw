#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"    
#INCLUDE "STBPREPDATRECHMOB.CH"
#DEFINE __FORMATEF	"CC;CD"

//-------------------------------------------------------------------
/*/{Protheus.doc} STDRechMob
Prepara as informações referente a recarga para serem gravadas na retaguarda

@param   	cCodeItem Codigo do item de recarga
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	Nil
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STBRechMob(oRetTran)

Local oDlgVA		:= Nil							//Objeto da tela
Local oDlgChq		:= Nil							//Objeto da tela
Local lBotaoOK		:= .F.							//Variavel de retorno
Local lCancela		:= .F.							//Variavel de cancelamento
Local nVezes 		:= 0							//Parametro da Tela
Local nCont			:= 0							//Parametro da Tela
Local aFontes		:= {}							//Configuração de fontes para tela
Local aDados		:= {}							//Dados da transacao
Local aDadosChq		:= {}							//Dados do TEF
Local cNatureza 	:= ""
Local lLjMExeParam	:= FindFunction("LjMExeParam")
Local cDocTEF 		:= ""
Local cNSUTEF 		:= "" 							//NSU TEF
Local lIsCartao		:= .F.							//Se o pagamento é em cartão
Local oTEF20 		:= STBGetTef()					//Objeto TEF
Local aAdmSel		:= {}							//Array da administradora financeira selecionada
Local nCodRet		:= 0							//Codigo do retorno do RemoteExecute
Local uRet			:= Nil							//Mensagem de retorno do RemoteExecute
Local lLgSerNFisc 	:= SLG->(ColumnPos("LG_SERNFIS")) > 0 
Local cPrefTit		:= "" 							//Prefixo do título
Local aNotas		:= {}							//Array com numeração de NFce
Local nCupom		:= 0							//Numero do cupom Fiscal
Local cMsgLog		:= ""							//Log de Mensagem
Local lFisPrint		:= STFGetCfg("lUseECF")			//usa impressora fiscal
Local aIsFinanProp	:= {}							//Armazena se é financeira própria, e se não for armazena o código do cliente
Local dDtVcRCel		:= CTOD('  /  /    ')			//Data de vencimento Recarga de Celular

Default oRetTran		:= Nil

ParamType 0 Var  oRetTran   As Object	   Default Nil


//Testo se é nfce para pegar o numero do cupom pelo ljxdnota
cPrefTit := STFGetStat("LG_SERIE")
nCupom 	 := oRetTran:nCupom
If !lFisPrint
	If lLgSerNFisc .AND. !Empty(cPrefTit := STFGetStation("SERNFIS"))
		LjxDNota( cPrefTit , 3, .F., 1, @aNotas,,,,,,,,,,,,,"DOCNF" )  // DOC/SERIE

		If Len(aNotas) > 0 .AND. Len(aNotas[1]) > 1
			nCupom := Val(aNotas[1][2])
		Else
			LjGrvLog( "STBRecCorBank2","Falha ao obter numeração de Série Não Fiscal, será mantido o número da última venda " + Str(nCupom) )				
		EndIf

		
	Else
		cMsgLog := STR0030 //"Para realizar a Recarga Não-Fiscal é necessário criar e informar o campo LG_SERNFIS, criado no compatibilizador U_UPDLO111"
		STFMessage("STBRechMob", "ALERT", cMsgLog)
		STFShowMessage("STBRechMob")	
		LjGrvLog( "STBRechMob",cMsgLog)	
	EndIf
EndIf

aDados := 		{	{STR0001	, cPrefTit}											,; //01 //"Serie"
					{STR0002	, nCupom}											,; //02 //"No Cupom"
					{STR0003	, LjParcela(1, SuperGetMV("MV_1DUP"))}				,; //03 //"Parcela"
					{STR0004	, Nil}												,; //04 //"Nat. Opera."
					{STR0005	, SuperGetMV("MV_CLIPAD",, "")}						,; //05 //"Client Padr"
					{STR0006	, SuperGetMV("MV_LOJAPAD",, "")}					,; //06 //"Loja"
					{STR0007	, dDataBase}										,; //07 //"Dt. Emissao"
					{STR0008	, dDataBase}										,; //08 //"Dt. Venc."
					{STR0009	, "RECARGA DE CELULAR " +;
									 Iif(GetAPOInfo("LOJA1934.PRW")[4] >= Ctod("01/12/2017"),oRetTran:oRetorno:cCelular + " - ","- ") +;	//Número do Telefone e Estação no Histórico
									 STFGetStation("CODIGO")},; 				    //09 //"Historico"
					{STR0010	, 1}												,; //10 //"Moeda"
					{STR0011	, "LOJXTEF"}										,; //11 //"Rotina"
					{STR0012	, oRetTran:oRetorno:nValor}							,; //12 //"Val. Rec."
					{STR0013	, xNumCaixa()}										,; //13 //"Caixa"
					{STR0014	, Nil}												,; //14 //"Tip Form Pg"
					{"Doc TEF"	, ""}												,; //15 "Doc TEF"
					{"NSU TEF"	, ""}												,; //16 "NSU  TEF"
					{"AdminFin"	, ""}												,; //17 "Adm financeira"
					{"NumMov"	, AllTrim(STDNumMov())}}								   //18 "Numero do movimento"
					
aDadosChq	:= 	{ {	0								,; 
					dDatabase						,; 
					1								,; 
					Space(TamSx3("EF_BANCO")[1])	,;
					Space(TamSx3("EF_AGENCIA")[1])	,; 
					Space(TamSx3("EF_CONTA")[1])	,;
					Space(TamSx3("EF_NUM")[1])		,;
					Space(TamSx3("EF_COMP")[1])		,;
   	            	Space(TamSx3("L4_RG")[1])		,;
   	            	Space(TamSx3("L4_TELEFON")[1])	,;
   	            	.F.								,;
   	            	.F.								,;
   	            	SuperGetMV("MV_SIMB1")			,;
   	            	Space(TamSx3("EF_EMITENT")[1])}	,;
               		Array(14)						,; 
               		{ .F., .F., .F.					,;
                	.T., .T., .T.					,;
                	.T., .F., .F.					,;
                	.F., .F., .F.					,;
                	.F., .F. }						,;
       	       		{ 	STR0015						,; 	//"Valor do Titulo"
       	       			STR0016						,; 	//"Data do Vencimento"
       	       			STR0017 					,;	//"Parcela"
       	       			STR0018						,;  //"Banco"
       	       			STR0019						,; 	//"Agência"
       	       			STR0020						,;	//"Conta"
       	       			STR0021						,;  //"Num.Cheque"
					 	STR0022						,; 	//"Compensação"
					 	STR0023						,; 	//"RG"
					 	STR0024						,; 	//"Telefone"
					 	STR0025						,; 	//"Utiliza nas próximas parcelas"
					 	STR0026						,; 	//"Cheque de Terceiro"
					 	STR0027						,;  //"Moeda"
					 	STR0028  					}} 	//"Emitente"
																
If Alltrim(oRetTran:oRetorno:cForma) == "1"
	aDados[14][2] 	:= SuperGetMV("MV_SIMB1")
ElseIf  Alltrim(oRetTran:oRetorno:cForma) == "2"
	aDados[14][2]	:= "CH"
ElseIf  Alltrim(oRetTran:oRetorno:cForma) == "3" 
	aDados[14][2]	:= "CD" 
	cDocTEF 		:= oRetTran:oRetorno:cNsuAutor
	cNSUTEF 		:= oRetTran:oRetorno:cNsu
ElseIf  Alltrim(oRetTran:oRetorno:cForma) == "4"  
	aDados[14][2]	:= "CC" 
	cDocTEF 		:= oRetTran:oRetorno:cNsuAutor
	cNSUTEF 		:= oRetTran:oRetorno:cNsu
EndIf

If aDados[14][2] $ __FORMATEF
	lIsCartao := .T.
	aDados[15][2] := LjRmvChEs(cDocTEF) 
	aDados[16][2] := LjRmvChEs(cNSUTEF)

	If Len(oRetTran:oRetorno:aAdmin) > 0
		aDados[17][2] := oRetTran:oRetorno:aAdmin[1,1]
	Else
		//Chama tela para seleção da Administradora
		aAdmSel := STICrdSlAdm( oTEF20:oConfig:aAdmin, oRetTran:oRetorno:nValor )		
		If Len(aAdmSel) == 1
			oRetTran:oRetorno:aAdmin := aClone(aAdmSel)
			aDados[17][2] := PadR(aAdmSel[1][1], TamSX3("AE_COD")[1])
			LjGrvLog(Nil, "Adm.Fin. escolhida: ", aAdmSel[1][3])
			If FindFunction("STDIsFinPr")
				//Retornar se é administradora propria
				aIsFinanProp := STDIsFinPr(aDados[17][2])
				//Se não for financeira propria, grava o titulo para a administradora.
				If !aIsFinanProp[1][1]
					aDados[05][2] := aIsFinanProp[1][2]
				EndIf 
			EndIf
		Else
			LjGrvLog(Nil, "Nenhuma Adm.Fin. escolhida" )
		EndIf		
	EndIf

	If aDados[14][2] == "CC"				
		cNatureza := "MV_NATCART"
	Else
		cNatureza := "MV_NATTEF"
	EndIf
ElseIf aDados[14][2] == "CH"
	cNatureza := "MV_NATCHEQ"
		
	aFontes := STFDefFont()
	
	LjTelaCheq(	@oDlgChq	, STR0029	, @oDlgVA		, @aDadosChq	, ;			 //"DADOS DO CHEQUE"
					@aFontes 	, @lBotaoOK			, @lCancela 	, @nVezes		, ;
					@nCont 	)		
		
ElseIf aDados[14][2] == SuperGetMV("MV_SIMB1")
	cNatureza :=  "MV_NATDINH"
EndIf

If  lLjMExeParam
	cNatureza := LjMExeParam(cNatureza) 
Else
	cNatureza := SuperGetMV(cNatureza)
	If Left(cNatureza, 1) == "&"
		cNatureza := &(SubStr(cNatureza, 2))
	EndIf
EndIf

aDados[4][2] := cNatureza

dDtVcRCel := Iif(aDados[14][2] == SuperGetMV("MV_SIMB1"),aDados[8][2],DataValida(aDados[8][2]))

//Efetua geração do titulo de recarga na retaguarda
STBRemoteExecute(	"INCTITRCEL",;
							{	aDados[1][2]			, AllTrim(Str(aDados[2][2])), aDados[3][2]	, aDados[14][2]	,;
							 	aDados[4][2] 			, aDados[5][2] 				, aDados[6][2]	, aDados[7][2] 	,;
							 	dDtVcRCel				, aDados[9][2]				, aDados[10][2]	, aDados[11][2]	,;
							 	aDados[12][2]			, aDados[13][2]				, aDadosChq[1,4], aDadosChq[1,5],;
							 	aDadosChq[1,6] 			, aDadosChq[1,7]			, aDadosChq[1,8], aDadosChq[1,9],;
							 	aDadosChq[1,10]			, aDadosChq[1,12]			, aDados[15][2] , aDados[16][2]	,;
							 	aDados[17][2] 			, lIsCartao					, aDados[18][2];
							},;
							Nil	,.T., @uRet,/*cType*/,/*cKeyOri*/,@nCodRet;
						)
						
//Realiza a Gravação da SE5 para recarga de celular
If ExistFunc("STDGrvSE5")
	STDGrvSE5(aDados[13][2],aDados[7][2],aDados[9][2],aDados[14][2],aDados[10][2],aDados[12][2],aDados[4][2],aDados[11][2])
EndIf
If nCodRet == -101 .OR. nCodRet == -108	
	LjGrvLog( "Recargar_Celular","Servidor PDV nao Preparado. Funcionalidade nao existe ou host responsavel não associado - INCTITRCEL ")	
	LjGrvLog( "Recargar_Celular","Cadastre a funcionalidade e vincule ao Host da Retaguarda - INCTITRCEL  ")
	STDIncRecM(aDados, aDadosChq, aDados[14][2])
EndIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBProdRec
Valida se o produto é um item de recarga ou não

@param   	cCodeItem Codigo do item de recarga
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	lRet - .T. ou .F. produto é um item de recarga ou não
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STBProdRec(cCodeItem)

Local cMvLjPRec 	:= SuperGetMV("MV_LJPREC", Nil, "") 	//Retorna o codigo do produto para recarga
Local lRet			:= .F.										//Retorno da função

ParamType 0 Var cCodeItem As Character Default ""

Default cCodeItem := ""

If !Empty( cMvLjPRec ) .AND. Alltrim(cCodeItem) $ Alltrim(cMvLjPRec)
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet
