#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1117.CH"
#INCLUDE "TBICONN.CH"

Function LOJA1117()
Return Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura do Dados para Envio.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT OutData
	WSDATA NewOutTrans as Array Of OutTrans		OPTIONAL
ENDWSSTRUCT
                                  	
WSSTRUCT OutTrans
	WSDATA NewOutReg as Array of OutReg		OPTIONAL
ENDWSSTRUCT

WSSTRUCT OutReg
	WSDATA Transacao		AS STRING OPTIONAL
	WSDATA Registro			AS STRING OPTIONAL
	WSDATA Sequencia		AS STRING OPTIONAL
	WSDATA TipoCampo		AS STRING OPTIONAL
	WSDATA Nome				AS STRING OPTIONAL
	WSDATA Valor			AS STRING OPTIONAL
	WSDATA Tipo				AS STRING OPTIONAL
	WSDATA Origem			AS STRING OPTIONAL
	WSDATA ServWeb			AS STRING OPTIONAL
	WSDATA Modulo			AS STRING OPTIONAL
	WSDATA StatusT			AS STRING OPTIONAL
	WSDATA SitPro			AS STRING OPTIONAL
	WSDATA Processo			AS STRING OPTIONAL
	WSDATA DataOut			AS DATE   OPTIONAL
	WSDATA TotReg			AS STRING OPTIONAL
	WSDATA Pacote			AS STRING OPTIONAL
ENDWSSTRUCT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estrutura dos Dados para Retorno.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT InData
	WSDATA NewInTrans as Array Of InTrans		OPTIONAL
ENDWSSTRUCT

WSSTRUCT InTrans
	WSDATA NewInReg as Array of InReg		OPTIONAL
ENDWSSTRUCT

WSSTRUCT InReg
	WSDATA Transacao		AS STRING OPTIONAL
	WSDATA Registro			AS STRING OPTIONAL
	WSDATA Sequencia		AS STRING OPTIONAL
	WSDATA TipoCampo		AS STRING OPTIONAL
	WSDATA Nome				AS STRING OPTIONAL
	WSDATA Valor			AS STRING OPTIONAL
	WSDATA Tipo				AS STRING OPTIONAL
	WSDATA Origem			AS STRING OPTIONAL
	WSDATA ServWeb			AS STRING OPTIONAL
	WSDATA Modulo			AS STRING OPTIONAL
	WSDATA StatusT			AS STRING OPTIONAL
	WSDATA SitPro			AS STRING OPTIONAL
	WSDATA Processo			AS STRING OPTIONAL
	WSDATA DataIn			AS DATE   OPTIONAL
	WSDATA TotReg			AS STRING OPTIONAL
	WSDATA Pacote			AS STRING OPTIONAL
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºWebService³LJWIntegracaoºAutor  ³Vendas Clientes  º Data ³  04/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Web Service responsavel pelo recebimento e gravacao dos    º±±
±±º          ³ dados de Integracao na tabela de Entrada.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSSERVICE LJWIntegracao DESCRIPTION STR0001					//"Integração da Venda Off-Line."
	WSDATA aOutData				As OutData	OPTIONAL		//Dados para Gravacao na Tabela de Entrada
	WSDATA aInData				As InData	OPTIONAL		//Dados para Envio da Tabela de Saida
	WSDATA cAmbiente			As String					//Ambiente de Origem da Transacao
	WSDATA lExporta				As Boolean					//Define se realiza a exportacao dos Dados de Saida
	WSDATA cFil					As String					//Define se realiza a exportacao dos Dados de Saida
	WSDATA cEmp					As String					//Define se realiza a exportacao dos Dados de Saida


	WSMETHOD Connect	DESCRIPTION STR0002					//"Envio e Recepção de dados da Integração."
ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Metodo   ³ Connect   ºAutor  ³Vendas Clientes    º Data ³  04/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recebe os dados, faz a gravacao na tabela de Entrada e ex- º±±
±±º          ³ porta os dados de saida.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD Connect WSRECEIVE lExporta, cAmbiente, aOutData, cFil, cEmp WSSEND aInData WSSERVICE LJWIntegracao

Local cTransOri		:= ""										//Transacao Origem
Local aNumTranMD7	:= {}										//Array que guarda o Numero da Transacao MD7
Local aArea			:= {}
Local nI			:= 0										//Contador
Local nItens		:= 0										//Quantidade de Itens por Transacao
Local nJ			:= 0										//Contador
Local nTrans		:= 0										//Quantidade de Transacoes
Local nTamMD7TRANS	:= 0
Local lLock			:= .T.										//Define se reserva um numero de Transacao
Local lRetorno		:= .T.										//Retorno do Metodo
Local lPrepEnv		:= If (FindFunction("LjPreparaWs"),  LjPreparaWs(Self:cEmp, Self:cFil), .F.) //faz prepare Environment 
Local lLimpaMD6		:= .F.										//Sinaliza se pode por STATUS = 2 na tabela MD6
Local oEntIn		:= LJCEntEntrada():New()					//Entidade Entrada
Local oCloneIn		:= oEntIn:Clonar()							//Guarda a Estrutura
Local oESxAmb		:= LJCEntSaidaAmb():New()					//Entidade Saida x Ambiente
Local oDSxAmb													//Dados Saida x Ambiente
Local oGrvESxAmb	:= oESxAmb:Clonar()							//Guarda a Estrutura para gravacao do Status
Local oESaida		:= LJCEntSaida():New()						//Entidade Saida
Local oDSaida													//Dados Saida
Local oTrans													//Controle de Transacoes
Local lLJImAut		:= SuperGetMV("MV_LJIMAUT", NIL, .F.)		//Gravacao dos Dados da Tabela de Entrada
Local lPrcTrn		:= .F.										//Indica que a transacao deve ser processada
Local cNumTrn		:= ""										//Numero da transacao de entrada
Local oEntPsq													//Objeto para pesquisa de pacotes
Local oPacAnt													//Objeto com os pacotes de entrada da mesma transacao
Local cUsr			:= ""										//Utilizado para embaralhar campo
Local cNum			:= ""										//Utilizado para embaralhar campo
Local oLJCConWS		:= LJCConexaoWS():LJRemCharEsp()
Local lMD7TamMD6	:= MD7->(FieldPos("MD7_TAMMD6")) > 0		//verifica se o campo MD7_TAMMD6 existe (UPDLO104)
Local nBytes		:= 0
Local nBytesAux		:= 0

If !Empty(::aOutData:NewOutTrans)
	nTrans := Len(::aOutData:NewOutTrans)
	
	ConOut("LOJA1117 - 01 - " + Time() + STR0013 + ::aOutData:NewOutTrans[1]:NewOutReg[1]:Transacao + STR0005 + ::cAmbiente)	//" Verificando a existencia de pacotes para a transacao: ", " do Ambiente: "
	
	//Busca o numero da transacao do pacote anterior
	oEntPsq := LJCEntEntrada():New()
	oEntPsq:DadosSet("MD8_ORIGEM", ::aOutData:NewOutTrans[1]:NewOutReg[1]:Origem)
	oEntPsq:DadosSet("MD8_TRORI" , ::aOutData:NewOutTrans[1]:NewOutReg[1]:Transacao)
	oEntPsq:DadosSet("MD8_PACOTE", "001")
	
	oPacAnt := oEntPsq:Consultar(2) //MD8_ORIGEM+MD8_TRORI+MD8_PACOTE
	
	//Mantem o numero da transacao de entrada caso exista um pacote anterior para a mesma transacao
	If oPacAnt:Count() > 0
		cNumTrn := oPacAnt:Elements(1):DadosGet("MD8_TRANS")
	EndIf
EndIf

ConOut("LOJA1117 - 02 - " + Time() + " - " + STR0003 + ::cAmbiente)		//"Importando dados do Ambiente: "

//Tratamento para gravacao na Tabela de Entrada
For nI := 1 to nTrans
	Begin Transaction
		//Guarda o numero de Itens
		nItens := Len(::aOutData:NewOutTrans[nI]:NewOutReg)
		
		If Empty(cNumTrn)
			//If lLock
				//Instancia o Controle de Transacoes e Reserva o Proximo Numero
			oTrans  := LJCGetTrans():New("MD8")
			cNumTrn := oTrans:GetTrans()
			//EndIf
		EndIf
		
		//Tratamento para gravacao dos Registros
		For nJ := 1 to nItens
			
			//Recupera estrutura da Tabela
			oEntIn := oCloneIn:Clonar()
			
			//Guarda a Transacao Original
			cTransOri := ::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Transacao
			
			//Verifica se chegaram todos os pacotes da transacao
			If AllTrim(::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:ServWeb) == AllTrim(::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:TotReg)
				lPrcTrn := .T.
			Else
				lPrcTrn := .F.
			EndIf
			
			//Atribui os dados para gravacao da Tabela de Entrada
			oEntIn:DadosSet("MD8_TRANS"		,cNumTrn)
			oEntIn:DadosSet("MD8_REG"		,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Registro)
			oEntIn:DadosSet("MD8_SEQ"		,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Sequencia)
			oEntIn:DadosSet("MD8_TPCPO"		,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:TipoCampo)
			oEntIn:DadosSet("MD8_NOME"		,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Nome)
			If Len(::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Valor) == 0 
				::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Valor := Space(2) 
			EndIf                                         
			oEntIn:DadosSet("MD8_VALOR"		,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Valor)
			oEntIn:DadosSet("MD8_TIPO"		,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Tipo)
			oEntIn:DadosSet("MD8_ORIGEM"	,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Origem)
			oEntIn:DadosSet("MD8_SERVWB"	,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:ServWeb)
			oEntIn:DadosSet("MD8_MODULO"	,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Modulo)
			oEntIn:DadosSet("MD8_STATUS"	,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:StatusT)
			oEntIn:DadosSet("MD8_SITPRO"	,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:SitPro)
			oEntIn:DadosSet("MD8_PROCES"	,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Processo)
			oEntIn:DadosSet("MD8_DATA"		,DToC(dDataBase))
			oEntIn:DadosSet("MD8_TRCNT"		,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:TotReg)
			oEntIn:DadosSet("MD8_PACOTE"	,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Pacote)
			oEntIn:DadosSet("MD8_TRORI"		,::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Transacao)
			
			//Embaralha campo
			If SubStr(::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Nome, 4) == "USERLGI";
				.Or. SubStr(::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Nome, 4) == "USERLGA";
				.Or. SubStr(::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Nome, 5) == "USERGI";
				.Or. SubStr(::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Nome, 5) == "USERGA";
				
				cUsr := Left(::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Valor, 15)
				cNum := rTrim(SubStr(::aOutData:NewOutTrans[nI]:NewOutReg[nJ]:Valor, 16))
				cNum := Save4in2(Val(cNum))
				
				oEntIn:DadosSet("MD8_VALOR", Embaralha((cUsr + cNum), 0))
			EndIf
			
			//Grava tabela de Entrada
			oEntIn:Incluir()
		Next nJ
		
		If ValType(oTrans) == "O"
			//Destrava o Numero da Transacao
			oTrans:FreeTrans()
			//Pode reservar a proxima Transacao
			lLock := .T.
		EndIf
	End Transaction
Next nI

ConOut("LOJA1117 - 04 - " + Time() + " - " + STR0006 + ::cAmbiente + STR0007)		//"Dados do Ambiente: "###" importados com sucesso."

If ::lExporta .AND. lRetorno
	
	ConOut("LOJA1117 - 05 - " + Time() + " - " + STR0008 + ::cAmbiente)		//"Exportando dados para o Ambiente: "
	
	//Atribui parametros para pesquisa na Tabela Saida x Ambiente
	oESxAmb:DadosSet("MD7_STATUS", "1")
	oESxAmb:DadosSet("MD7_DEST", ::cAmbiente)
	
	//Consulta Tabela de Saida x Ambiente e atribui ao objeto oDSxAmb
	oDSxAmb:= oESxAmb:Consultar(3)			//Status + Destino
	
	//Guarda o numero de Transacoes para Exportacao
	nTrans := oDSxAmb:Count()	//quantidade de MD7

	If !lMD7TamMD6
		conout( "LOJA1117 - 06 - " + Time() + " - " + STR0014 + " MD7_TAMMD6 (UPDLO104)" )	//"Para controle do tamanho do XML, e necessario o campo"
	EndIf

	//Varre os Registros da Tabela de Saida x Ambiente
	For nI := 1 to nTrans

		//como o WebService possui a limitação, onde a string não pode ser maior que 1MB, 
		//trafegamos pacotes com uma tamanho médio de 500KB, para que haja uma folga para as tags do XML
		If lMD7TamMD6
			nBytesAux := Val( oDSxAmb:Elements(nI):DadosGet("MD7_TAMMD6") )
			If nBytesAux > 0
				If nBytes <= 524288	//500KB
					nBytes += nBytesAux
				Else
					Exit
				EndIf
			EndIf
		EndIf

		//Procura a Transacao na Tabela de Saida
		oESaida:DadosSet("MD6_TRANS", oDSxAmb:Elements(nI):DadosGet("MD7_TRANS"))
		
		//Consulta Tabela de Saida e atribui ao oDSaida
		oDSaida	:= oESaida:Consultar(1)	//Transacao + Registro + Sequencia
		
		//Verifica se existem dados para o envio
		nItens	:= oDSaida:Count()
		
		//Adiciona uma transacao
		Aadd( ::aInData:NewInTrans, WSClassNew("InTrans"))
		
		//Inicia o Array
		::aInData:NewInTrans[nI]:NewInReg := {}
		
		//Varre os registros da tabela de Saida
		For nJ := 1 to nItens
			
			//Cria a dimensao do Registro
			Aadd(::aInData:NewInTrans[nI]:NewInReg, WSClassNew("InReg"))
			
			//Adiciona o Registro para Exportacao
			::aInData:NewInTrans[nI]:NewInReg[nJ]:Transacao		:= oDSaida:Elements(nJ):DadosGet("MD6_TRANS")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:Registro		:= oDSaida:Elements(nJ):DadosGet("MD6_REG")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:Sequencia		:= oDSaida:Elements(nJ):DadosGet("MD6_SEQ")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:TipoCampo		:= oDSaida:Elements(nJ):DadosGet("MD6_TPCPO")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:Nome			:= oDSaida:Elements(nJ):DadosGet("MD6_NOME")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:Valor			:= oLJCConWS:LJRemCharEsp(oDSaida:Elements(nJ):DadosGet("MD6_VALOR"))
			::aInData:NewInTrans[nI]:NewInReg[nJ]:Tipo			:= oDSaida:Elements(nJ):DadosGet("MD6_TIPO")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:Origem		:= oDSaida:Elements(nJ):DadosGet("MD6_ORIGEM")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:ServWeb		:= oDSaida:Elements(nJ):DadosGet("MD6_SERVWB")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:Modulo		:= oDSaida:Elements(nJ):DadosGet("MD6_MODULO")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:StatusT		:= oDSaida:Elements(nJ):DadosGet("MD6_STATUS")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:SitPro		:= oDSaida:Elements(nJ):DadosGet("MD6_SITPRO")
			::aInData:NewInTrans[nI]:NewInReg[nJ]:Processo		:= oDSaida:Elements(nJ):DadosGet("MD6_PROCES")
			//::aInData:NewInTrans[nI]:NewInReg[nJ]:DataIn		:= oDSaida:Elements(nJ):DadosGet("MD6_DATA")
		Next nJ

		ConOut("LOJA1117 - 07 - " + Time() + " - " + STR0010 + ::cAmbiente)		//"Alterando Status da Tabela de Saida para o Ambiente: "
		oGrvESxAmb:DadosSet( "MD7_TRANS" , oDSxAmb:Elements(nI):DadosGet("MD7_TRANS") )
		oGrvESxAmb:DadosSet( "MD7_DEST"	 , ::cAmbiente )
		oGrvESxAmb:DadosSet( "MD7_STATUS", "2" )	//Dados Enviados

		oGrvESxAmb:Alterar(1)	//Transacao + Destino
	Next nI

	If nBytes > 0
		conout("LOJA1117 - 08 - " + Time() + " - " + STR0015 + "KB")		//"Enviado com "
	EndIf

EndIf

ConOut("LOJA1117 - 10 - " + Time() + " - " + STR0011 + ::cAmbiente)		//"Status da Tabela de Saida alterado com Sucesso."
ConOut("LOJA1117 - 11 - lLJImAut: " + IIF(lLJImAut, "T", "F"))
ConOut("LOJA1117 - 12 - cEmpAnt : " + cEmpAnt)
ConOut("LOJA1117 - 13 - cFilAnt : " + cFilAnt)

If lPrcTrn
	If lLJImAut
		ConOut("LOJA1117 - 14 - " + Time() + STR0012 )						//" - Pacote completo, iniciando job LOJA1123"
		StartJob("LOJA1123", GetEnvServer(), .F., cEmpAnt, cFilAnt) 
	EndIf
EndIf

Return(lRetorno)



//GERACAO PACOTE PAF-ECF 06/08/2010


//GERACAO PACOTE PAF-ECF 12/08/2010
