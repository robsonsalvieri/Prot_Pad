#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

Static cVerSMART := "V.12.1.17.004.201901"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSETUP
Métodos WS do TAFSAAS   

@author TAFSAAS
@since 16/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

WSRESTFUL TAFSETUP DESCRIPTION "TAFSETUP"
	
// Métodos GET
WSMETHOD GET  status    DESCRIPTION "status"          		PRODUCES APPLICATION_JSON 

// Métodos POST
WSMETHOD POST tafsetup 	DESCRIPTION "tafsetup"   	  		PRODUCES APPLICATION_JSON

// Post JOBS
WSMETHOD POST jobs		DESCRIPTION "JOBS" PATH "/jobs"   	PRODUCES APPLICATION_JSON
	

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET Nome GET
Ping Data/Horário

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/TAFSETUP

@author TAFSAAS
@since 10/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET status WSREST TAFSETUP

	Local jResponse := JsonObject():New()

	Self:SetContentType("application/json")

	PrepEnv( '01', '0000000000', "TAFSETUP" )

	Conout(cVerSMART + "|" + FWTimeStamp(3) + " - TAFSETUP|Requisição de consulta ao WS/REST")

	Conout(CRLF)
	Conout('  _____   _    _     __     _____    _______ ')
	Conout(' / ____| | \  / |   /__\   |  __ \  |__   __|')
	Conout('| (___   |  \/  |  /|__|\  | |__) |    | |   ')
	Conout(' \___ \  | |\/| | |  __  | |  _  /     | |   ')
	Conout(' ____) | | |  | | | |  | | | | \ \     | |   ')
	Conout('|_____/  |_|  |_| |_|  |_| |_|  \_\    |_|   ')
	Conout(CRLF)	
	Conout(cVerSMART + "|" + FWTimeStamp(3) + " - TAFSETUP|Inicio do processo de setup do SMART")

	jResponse['memory']		:= GetSrvMemInfo()
	jResponse['build']		:= GetBuild()
	jResponse['environment']:= GetEnvServer()
	jResponse['tss']		:= TSSOK()
	jResponse['time']		:= FWTimeStamp(3)

	Self:SetResponse(FwJsonSerialize(jResponse))

	// Realiza a gravação do Json de entrada já convertido.
	cArquivo := TAFGrvJSON(FwJsonSerialize((jResponse)),.F.)

	Conout(cVerSMART + "|" + FWTimeStamp(3) + " - TAFSETUP|Requisição de consulta ao WS/REST - Concluido!" + CRLF + CRLF + "Arquivo gerado: " + cArquivo )

	FWClrHTTPAuth()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST POSTXXX
POST

@example POST   -> http://127.0.0.1:9090/rest/TAFSETUP
@example HEADER -> Authorization:  Basic Usuário+Senha Encode64 
@example BODY   ->
Documentação : http://tdn.totvs.com/display/TAF/Web+Service+REST+-+TAFSETUP

@author Marcelo Araujo Dente
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------

WSMETHOD POST TAFSETUP WSREST TAFSETUP
Local jWSTAF     := JsonObject():New()
Local cRetFunc   := ""
local lContinue  := .F.
Local cPost 	 := ""                                                                            
Local cArquivo 	 := ""

Conout(CRLF)
Conout('  _____   _    _     __     _____    _______ ')
Conout(' / ____| | \  / |   /__\   |  __ \  |__   __|')
Conout('| (___   |  \/  |  /|__|\  | |__) |    | |   ')
Conout(' \___ \  | |\/| | |  __  | |  _  /     | |   ')
Conout(' ____) | | |  | | | |  | | | | \ \     | |   ')
Conout('|_____/  |_|  |_| |_|  |_| |_|  \_\    |_|   ')
Conout(CRLF)
Conout(cVerSMART + "|" + FWTimeStamp(3) + " - TAFSETUP|Inicio do processo de setup do SMART| V12.1.17.003")
Conout(CRLF)
	                                                                   
cPost	:= Self:GetContent()

lContinue := (cPost == Nil)

If lContinue
	Self:SetContentType("application/json")
	Self:SetResponse("Invalid POST - Erro no envio das informações para o SETUP")

	Conout(cVerSMART + "|" + FWTimeStamp(3) + " - Erro no envio das informações para o SETUP| application/json - Invalid POST")	
Else
	cPost	:= StrTran(cPost,"\/","/")
	cPost	:= StrTran(cPost,Chr(13) + Chr(10),"")
	cPost	:= DecodeUtf8( cPost )

	If !Empty( cPost )
		// Realiza a gravação do Json de entrada já convertido.
		cArquivo := TAFGrvJSON(cPost,.T.)

		If !Empty(cArquivo)
			Conout(cVerSMART + "|" + FWTimeStamp(3) + " - TAFSETUP|Realizado a gravação do JSON de entrada. Verificar na pasta system o arquivo: " + cArquivo )
		Endif

		// realiza a conversão do Json para processamento do Setup
		jWSTAF:FromJson(cPost)

		// realiza o cadastramento das informações encaminhadas pelos ERPs
		cRetFunc:= TAFSET(jWSTAF)

		// retorno do processamento
		Self:SetContentType("application/json")
		Self:SetResponse(FwJsonSerialize((cRetFunc)))

		// Realiza a gravação do Json de entrada já convertido.
		cArquivo := TAFGrvJSON(FwJsonSerialize((cRetFunc)),.F.)
		If !Empty(cArquivo)
			Conout(cVerSMART + "|" + FWTimeStamp(3) + " - TAFSETUP|Realizado a gravação do JSON de retorno. Verificar na pasta system o arquivo: " + cArquivo )
		Endif
	Else
		Self:SetContentType("application/json")
		Self:SetResponse("Invalid POST - Erro no envio das informações para o SETUP apos o decode")
		Conout(cVerSMART + "|" + FWTimeStamp(3) + " - Erro no envio das informações para o SETUP apos o decode| application/json - Invalid POST")	
	Endif
Endif

Conout(CRLF)
Conout(cVerSMART + "|" + FWTimeStamp(3) + " - TAFSETUP|Processo de setup do SMART Concluido")

FWClrHTTPAuth()  

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST POSTXXX
POST

@example POST   -> http://127.0.0.1:9090/rest/TAFSETUP/JOBS
@example HEADER -> Authorization:  Basic Usuário+Senha Encode64 
@example BODY   ->
Documentação : http://tdn.totvs.com/display/TAF/Web+Service+REST+-+TAFSETUP

@author Marcelo Araujo Dente
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST JOBS WSREST TAFSETUP

	Local jWSJOB      := JsonObject():New()
	Local cRetFunc	  := ""
	Local cPost := ""
	Local oTAFSchedStartup
	Local jResponse := JsonObject():New()
	Local lContinue := .F.

	PrepEnv( '01', '0000000000', "TAFSETUP" )

	cPost:=Self:GetContent()

	lContinue := cPost == Nil

	If lContinue
		Self:SetContentType("application/json")
		Self:SetResponse("Invalid POST")

		Conout(cVerSMART + "|" + FWTimeStamp(3) + " - Erro nos parametros de POST JOBS| application/json - Invalid POST")	

		Return .F.
	Else
		jWSJOB:FromJson(cPost)
	EndIf

	If jWSJOB['ativo'] == '1'

		oTAFSchedStartup := TAFSchedStartup():New()
		oTAFSchedStartup:CreateSched(.T.)

		jResponse['status'] := 'Job Ativado'
		jResponse['time'] := FWTimeStamp(3)

		Self:SetResponse(FwJsonSerialize(jResponse))

		Conout(cVerSMART + "|" + FWTimeStamp(3) + " - Job Ativado")	
		
	ElseIf jWSJOB['ativo'] == '2'

		oTAFSchedStartup := TAFSchedStartup():New()
		oTAFSchedStartup:CreateSched(.F.)

		jResponse['status'] := 'Job Desativado'
		jResponse['time'] := FWTimeStamp(3)

		Self:SetResponse(FwJsonSerialize(jResponse))

		Conout(cVerSMART + "|" + FWTimeStamp(3) + " - Job Desativado")	
	EndIf

	FreeObj(oTAFSchedStartup)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TSSOK
Verifica se Serviço do E-social esta no on-line


@author Marcelo Dente
@since 11/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TSSOK()
Local oWs  := WsSpedCfgNFe():New()
Local lRet := .T.
Local cURL := PadR(SuperGetMV("MV_TAFSURL",,"http://"),250)  
Local nI := 0

oWs:cUserToken := "TOTVS"
oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"

For nI := 1 To 3
	If !(oWs:CFGCONNECT())
		lRet := .F.
	Else
		lRet:= .T.
		Exit
	EndIf

	Sleep(1000)
Next

If !lRet
	Conout(cVerSMART + "|" + FWTimeStamp(3) + " - Não foi possivel conectar ao serviço SPEDCFGNFe.apw. Verificar configurações do TSS")	
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DBACCESSOK
	(Verifica se DBACCESS esta disponível ( provisório ))
	@type  Static Function
	@author Marcelo Dente
	@since 24/05/2018
	@version 1.0
	@return lRet, boolean, Retorna se DBACCESS está ativo
	/*/

Static Function DbAccessOK()
Local cQry := ''
Local lRet := .F.

If Select("TST")>0
	TST->(DbCloseArea())
Endif

cQry:= 'SELECT * FROM XB3010'

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TST",.F.,.T.)

DbSelectArea("TST")
TST->(dbGoTop())

If !Empty(TST->XB3_MARK01)
	lRet:= .T.
Else
	lRet:= .F.
EndIf

If !lRet
	Conout(cVerSMART + "|" + FWTimeStamp(3) + " - Não foi possivel conectar ao serviço do DbAccess. Verificar configurações.")
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGrvJSON
Rotina Generica de gravação do JSON enviado pelo ERP
Uso Geral.

@param 	cPost	   	Mensagem encaminhada pelo ERP

@sample
TAFGrvJSON( cPost )

@author Renato Campos
@since 04/09/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFGrvJSON(cPost,lEntrada)

Local cArqLog	:= "/"
Local nHdl	:= 0                           //Handle do arquivo
Local lRet := .T.

Default cPost	 := ""
Default lEntrada := .T.

//Incluo o nome do arquivo no caminho ja selecionado pelo usuario
cArqLog := Iif(lEntrada,"TAFSETUP_ENTRADA_","TAFSETUP_RETORNO_") + Alltrim(StrTran(str(seconds()),".","") ) + ".jSon"

If (nHdl := FCreate(cArqLog)) == -1
	Conout(cVerSMART + "|" + FWTimeStamp(3) + " - [TAFGrvJSON|ERRO] - Nao foi possível criar o arquivo de nome ( " + cArqLog + " )! Verifique os acessos da máquina." )
	lRet := .F.
EndIf

If lRet .And. ( FWrite(nHdl,cPost,Len(cPost)) != Len(cPost) )
	Conout(cVerSMART + "|" + FWTimeStamp(3) + " - [TAFGrvJSON|ERRO] - Ocorreu um erro na gravacao do arquivo: " + cArqLog + "." )
	lRet := .F.
EndIf

FClose(nHdl)

Return cArqLog
