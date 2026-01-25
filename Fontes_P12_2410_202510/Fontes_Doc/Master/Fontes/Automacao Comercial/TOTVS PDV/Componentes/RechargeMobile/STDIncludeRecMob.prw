#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STDINCLUDERECMOB.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} STDIncDatR
Grava as informações da recarga não fiscal nas tabela SE1 e SEF
@param  aDadosRM   Dados da recarga
@param  aDadosChq		Dados do cheque
@param  cTipo			Tipo de recarga
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	Retorna se gravou as Informacaos da recarga
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STDIncRecM(aDadosRM, aDadosChq, cTipo)

Local aDados			:= {} 	//Campos do SE1 que necessitam ser enviados
Local lContinue 		:= .F.	//Retorno do componente de comunicacao com a retaguarda 
Local uRet				:= Nil	//Retorno das funcoes
Local cMsg 				:= ""

Default aDadosRM 	:= {}
Default aDadosChq	:= {}
Default cTipo		:= ""

aDados := {		{ "E1_PREFIXO"	,aDadosRM[1][2]				,Nil} ,; //1
				{ "E1_NUM"	  	,AllTrim(Str(aDadosRM[2][2]))			,Nil} ,; //2
				{ "E1_PARCELA" 	,aDadosRM[3][2]				,Nil} ,;  //3
				{ "E1_TIPO"	 	,aDadosRM[14][2]			,Nil} ,; //4
				{ "E1_NATUREZ" 	,aDadosRM[4][2]				,Nil} ,; //5
          		{ "E1_CLIENTE" 	,aDadosRM[5][2]				,Nil} ,; //6
            	{ "E1_LOJA"	  	,aDadosRM[6][2]				,Nil} ,; //7
          		{ "E1_EMISSAO" 	,aDadosRM[7][2] 			,Nil} ,; //8
      			{ "E1_VENCTO"  	,aDadosRM[8][2] 			,Nil} ,; //9
      			{ "E1_VENCREA" 	,DataValida(aDadosRM[8][2])	,Nil} ,; //10
      			{ "E1_HIST" 	,aDadosRM[9][2]				,Nil} ,; //11
      			{ "E1_MOEDA" 	,aDadosRM[10][2]			,Nil} ,; //12
				{ "E1_ORIGEM"	,aDadosRM[11][2]			,Nil} ,; //13
				{ "E1_FLUXO"	,"S"						,Nil} ,; //14
		   		{ "E1_VALOR"	,aDadosRM[12][2]			,Nil} ,; //15
		   		{ "E1_PORTADO"	,aDadosRM[13][2]			,Nil} ,; //16
		   		{ "E1_BCOCHQ"	,aDadosChq[1,4]				,Nil} ,; //17
		   		{ "E1_AGECHQ" 	,aDadosChq[1,5]				,Nil} ,; //18
		   		{ "E1_CTACHQ"	,aDadosChq[1,6]				,Nil} ,; //19
		   		{ "E1_DOCTEF"	,""		              		,Nil} }//20

If Len(  aDadosRM) > 15
	aDados[20, 02] := aDadosRM[15][2]
	aAdd(aDados, {"E1_NSUTEF",  aDadosRM[16][2], NIL})
EndIf

lContinue := STBRemoteExecute(	"Fina040"		,;
									{ aDados }	,;
									Nil				,;
									.T. 			,;
									@uRet			)
									
If ValType(	uRet) = "A" .AND. Len(uRet) > 1 

	If ValType(uRet[2]) = "C"
		cMsg := uRet[2]
	EndIf

	If ValType(uRet[1]) = "L"
 							
		lContinue := uRet[1]
	EndIf
	If !lContinue			
		If Empty(cMsg)
			cMsg := STR0001 //"Problemas ao realizar a geração do Título de Contas a Receber"
		EndIf
	EndIf
EndIf

If lContinue .AND. cTipo == "CH"
	uRet := NIL	
	lContinue := STBRemoteExecute(	"LJRecGrvCH",;
										{ 	aDadosChq[1,4]	, aDadosChq[1,5] 	, aDadosChq[1,6]	, aDadosChq[1,7]	,;
 											aDadosRM[12][2]	, aDadosRM[7][2]	, aDadosChq[1,8]	, aDadosChq[1,9] 	,;
                						aDadosChq[1,10]  	, aDadosChq[1,12]	, aDadosRM[1][2]	, AllTrim(Str(aDadosRM[2][2])),;
    										aDadosRM[3][2]	, aDadosRM[14][2]	},;
										Nil,;
										.T.,;
										@uRet) 	
	If ValType(uRet) = "L"
		lContinue := uRet
	EndIf

	If !lContinue
		If Empty(cMsg)
			cMsg := STR0002//"Problemas ao realizar a geração dos dados do Cheque"
		EndIf
	EndIf
EndIf
	
If lContinue .And. cTipo == SuperGetMV( "MV_SIMB1" )
	uRet := NIL	
	aDados	:= {	{ "E1_PREFIXO" 	,PadR( aDadosRM[1][2], TamSx3("E1_PREFIXO")[1])		, Nil},;// 01
					{ "E1_NUM"     	,PadR(AllTrim(Str(aDadosRM[2][2])), TamSx3("E1_NUM")[1])	, Nil},;// 02
					{ "E1_PARCELA" 	,PadR(aDadosRM[3][2], TamSx3("E1_PARCELA")[1])		, Nil},;// 03
					{ "E1_TIPO"    	,PadR( aDadosRM[14][2], TamSx3("E1_TIPO")[1])	, Nil},;// 04
					{ "E1_MOEDA"   	,aDadosRM[10][2]		, Nil},;// 05
					{ "E1_TXMOEDA"	,0						, Nil},;// 06
					{ "E1_ORIGEM"	,aDadosRM[11][2]		, Nil},;// 07
					{ "AUTVALREC"	,aDadosRM[12][2]		, Nil},;// 08
					{ "AUTMOTBX"  	,"NOR"					, Nil},;// 09
					{ "AUTDTBAIXA"	,dDataBase				, Nil},;// 10
					{ "AUTDTCREDITO",dDataBase				, Nil},;// 11
					{ "AUTHIST"   	,aDadosRM[9][2]		, Nil}} // 12
					
	lContinue := STBRemoteExecute(	"FINA070"		,;
										{ aDados, 3 }	,;
										Nil				,;
										.T. 			,;
										@uRet			)
										
	If ValType(	uRet) = "A" .AND. Len(uRet) > 1 										
		If ValType(uRet[2]) = "C"
			cMsg := uRet[2]
		EndIf
	
		If ValType(uRet[1]) = "L"	 							
			lContinue := uRet[1]
		EndIf
		
		If !lContinue
			If Empty(cMsg)
				cMsg := STR0003 //"Problemas ao realizar a baixa do título da Recarga de Celular"
			EndIf
		EndIf
	EndIf
										
EndIf

If !lContinue .AND. !Empty(cMsg)
	STFMessage("STDIncRecM", "ALERT", cMsg)
	STFShowMessage("STDIncRecM")

EndIf
	
Return lContinue



//-------------------------------------------------------------------
/*/{Protheus.doc} STDIncSE1
Grava as informações da recarga não fiscal nas tabela SE1

@param  aDadosRM   Dados da recarga
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	Retorna se gravou as Informacaos da recarga
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STDIncSE1(aDados)

Local aRet := Array(2)

Default aDados := {}

Private lMsErroAuto := .F. 

If Len(aDados) > 0
	MSExecAuto( { |x,y| Fina040( x, y ) }, aDados, 3 ) //Inclusao
	If lMsErroAuto
		CoNout(MostraErro())
		aRet[1] := .F.
		aRet[2] := MostraErro()
	Else
		aRet[1] := .T.
		aRet[2] := ""	
	EndIf

	
Else
	aRet[1] := .F.
	aRet[2] := "Array aDados chegou vazio!"
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDBxSE1
Grava a Baixa do Título gerado na SE1

@param  aDadosRM   Dados da recarga
@author  	Varejo
@version 	P11.8
@since   	15/05/2012
@return  	Retorna se gravou a baixa das Informacaos da recarga
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STDBxSE1(aDados, nOper)

Local aRet := Array(2)

Default aDados := {}
Default nOper := 3

Private lMsErroAuto := .F. 

If Len(aDados) > 0
	//Ajustando os campos chave do Título para não dar Título não localizado
	
	//Foi colocada a conversão de Data pois o FwCallFuncionality do STBRemote Execute estava retornando TimeStamp na Data, dando erro na baixa
	AEval(aDados,{|d| IIF( d[1] $ "AUTDTBAIXA|AUTDTCREDITO", d[2] := StoD(Dtos(d[2])),)})
	
	MSExecAuto( { |x,y| Fina070( x, y ) }, aDados, nOper ) //Inclusao
	If lMsErroAuto
		CoNout(MostraErro())
		aRet[1] := .F.
		aRet[2] := MostraErro()
	Else
		aRet[1] := .T.
		aRet[2] := ""			
	EndIf
Else
	aRet[1] := .F.
	aRet[2] := "Array aDados chegou vazio!"
EndIf

Return aRet
//-------------------------------------------------------------------
/*/{Protheus.doc} STDGrvSE5
Grava a  SE5 da recarda de celular não-fiscal

@param cPortado 	Portator
@param dEmiss		Emissão da recarga
@param cHist		Historioco da SE5
@param cTipo		Tipo da SE5
@param nMoeda		Moeda da Venda
@param nValTit		Valor da recarga
@param cNatureza	Natureza da SE5
@param cOrigem		Origem da Gravação

@author  	Lucas Novais
@version 	P11.8
@since   	30/06/2017
@return  	
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STDGrvSE5(cPortado,dEmiss,cHist,cTipo,nMoeda,nValTit,cNatureza,cOrigem)

Local aArea		:= GetArea()
Local aAreaSA6 	:= SA6->(GetArea())
 
SA6->(DbSetOrder(1))
SA6->(DbSeek(xFilial("SA6") + cPortado + "."))
If SE5->(Reclock("SE5",.T.))
	REPLACE SE5->E5_FILIAL	WITH xFilial("SE5")
	REPLACE SE5->E5_DATA	WITH dEmiss
	REPLACE SE5->E5_BANCO	WITH cPortado
	REPLACE SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
	REPLACE SE5->E5_CONTA	WITH SA6->A6_NUMCON
	REPLACE SE5->E5_HISTOR	WITH cHist
	REPLACE SE5->E5_TIPO	WITH cTipo
	REPLACE SE5->E5_TIPODOC	WITH "VL"
	REPLACE SE5->E5_MOEDA	WITH StrZero(nMoeda,TAMSX3("E5_MOEDA")[1])
	REPLACE SE5->E5_VALOR	WITH nValTit
	REPLACE SE5->E5_DTDIGIT	WITH dDataBase
	REPLACE SE5->E5_DTDISPO	WITH SE5->E5_DATA
	REPLACE SE5->E5_NATUREZ	WITH cNatureza
	REPLACE SE5->E5_SITUA	WITH "TX" //Não é necessário subir para a retaguarda pois ja foi gerada anteriormente
	REPLACE SE5->E5_ORIGEM	WITH cOrigem 
	REPLACE SE5->E5_NUMMOV	WITH AllTrim(STDNumMov())
	SE5->(MsUnLock())
EndIf						

RestArea(aAreaSA6)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STDIsFinPr
Retorna se é financeira própria, e se não for armazena o código da financeira(Cliente)

@param cAdminis 	Administradora

@author  	Lucas Novais
@version 	P12.1.17
@since   	14/11/2017
@return  	aRet Array com duas posições, sendo a primeira um logico que informa se é financeira propia e a segunda que retorna o codigo da financeira(Cliente) caso não seja.
@obs     	
@sample
/*/
//-------------------------------------------------------------------
Function STDIsFinPr(cAdminis)

Local aArea		:= GetArea()
Local aAreaSAE 	:= SAE->(GetArea())
Local aRet		:= {}				//Armazena se é financeira própria, e se não for armazena o código do cliente

Default cAdminis := ""

SAE->(DbSetOrder(1))//AE_FILIAL+AE_COD                                                                                                                                                

If SAE->(DbSeek(xFilial("SAE") + cAdminis)) .AND. SAE->AE_FINPRO == "N"
	AADD(aRet,{.F.,SAE->AE_CODCLI})
Else 
	AADD(aRet,{.T.,""})	
EndIf

RestArea(aAreaSAE)
RestArea(aArea)

Return aRet

