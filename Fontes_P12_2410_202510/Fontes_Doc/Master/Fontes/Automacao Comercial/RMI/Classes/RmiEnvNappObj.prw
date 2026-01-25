#INCLUDE "TOTVS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FILEIO.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiEnvNappObj
Classe responsável pelo envio de dados ao NAPP

@type       Class
@author     Eduardo Sales
@since      12/09/2025
@version    P12
/*/
//-------------------------------------------------------------------
Class RmiEnvNappObj From RmiEnviaObj

	Data aMhrRec                as Array
	Data nQtdList               as Numeric
	Data cBodylist              as Character    	//Corpo da mensagem que será enviada para o sistema de destino
	Data cToken                 as Character    	//Token de autenticação
	Data cFileName              as Character    	//Nome do arquivo retornado para envio
	Data cUrlToken				as Character		//Url para a geração do token
	Data cUser					as Character		//Usuário para a autenticação da solicitação
	Data cPassword				as Character		//Senha para a autenticação da solicitação
	Data cUrlUpload		   		as Character    	//Url para obter o link de upload do arquivo .json
	Data cUrlFile               as Character    	//Url para envio do arquivo .json
	
	Method New()                                	//Metodo construtor da Classe

	Method GeraToken(cUrlToken, cUser, cPassword)	//Metodo que ira gerar o token de autenticação
	Method Processa()                           	//Metodo que ira controlar o processamento dos envios em lista
	Method Envia()                              	//Metodo responsavel por enviar a mensagens ao NAPP
	Method Consulta()                           	//Consulta as publicações disponiveis para o envio para um determinado processo com base nos LOTE's abertos
	Method TrataRetorno(cJson, nTipo)				//Trata o retorno do lote
	Method GetURLFile()								//Retorna a URL para envio do arquivo .json
	Method MontaBody(cPath, cFileName)				//Monta o body do envio
	Method SalvaConfig()							//Salva o token nas configurações do assinante

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@author     Eduardo Sales
@since      12/09/2025
@version    P12
@param      cProcesso, caractere, Processo que esta em execução
/*/
//-------------------------------------------------------------------
Method New(cProcesso, cAssinante) Class RmiEnvNappObj
	
	_Super:New(cAssinante, cProcesso)

	If Self:lSucesso

		If Self:oConfAssin:hasProperty("configNAPP")
			//Recupera URL de autenticação, usuário e senha das configurações
			Self:cUrlToken := IIF(Self:oConfAssin["configNAPP"]:hasProperty("url_token")	, Self:oConfAssin["configNAPP"]["url_token"]  	, "")
			Self:cUser     := IIF(Self:oConfAssin["configNAPP"]:hasProperty("usuario")    	, Self:oConfAssin["configNAPP"]["usuario"]    	, "")
			Self:cPassword := IIF(Self:oConfAssin["configNAPP"]:hasProperty("senha")      	, Self:oConfAssin["configNAPP"]["senha"]		, "")

			//Recupera URL de upload do arquivo
			Self:cUrlUpload := IIF(Self:oConfAssin["configNAPP"]:hasProperty("url_upload")	, Self:oConfAssin["configNAPP"]["url_upload"]	, "")
		EndIf
		
		If cProcesso <> "WIZARD"
			Self:GeraToken(Self:cUrlToken, Self:cUser, Self:cPassword)
			Self:Processa()
		EndIf

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraToken
Metodo que ira gerar o token de autenticação

@type       Method
@author     Eduardo Sales
@since      12/09/2025
@version    P12
@param      cUrlToken, caractere, Url para a geração do token
@param      cUser, caractere, Usuario para a autenticação da solicitação
@param      cPassword, caractere, Senha para a autenticação da solicitação
/*/
//-------------------------------------------------------------------
Method GeraToken(cUrlToken, cUser, cPassword) Class RmiEnvNappObj

	Local oRest		:= Nil
	Local cJson     := ""
	Local aHeader   := {}

	If Empty(cUrlToken) .Or. Empty(cUser) .Or. Empty(cPassword)
		Self:lSucesso := .F.
		LjGrvLog(" RmiEnvNappObj ", "Não foram encontrados os dados para autenticação, verifique as configurações do assinante!")
	EndIf

	If Self:lSucesso

		// Monta o JSON de autenticação
		BeginContent var cJson
			{
				"username": "%Exp:cUser%",
				"password": "%Exp:cPassword%"
			}
		EndContent

		oRest := FWRest():New("")
		oRest:SetPath(cUrlToken)
		oRest:SetPostParams(EncodeUTF8(cJson))
		aAdd(aHeader, "Content-Type:application/json")

		If oRest:Post(aHeader)
			Self:lSucesso := .T.
			Self:TrataRetorno(oRest:GetResult(), 0) //0 - Token
		Else
			Self:lSucesso := .F.
			Self:cRetorno := oRest:GetLastError() + " - [" + cUrlToken + "]"
			LjGrvLog(" RmiEnvNappObj ", "Não teve sucesso retorno => " ,{Self:cRetorno}) 
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Processa
Metodo que ira controlar o processamento dos envios em lista

@type       Method
@author     Eduardo Sales
@since      12/09/2025
@version    P12
/*/
//-------------------------------------------------------------------
Method Processa() Class RmiEnvNappObj

	Local nX            := 0
	Local lCtrlMd5      := AttIsMemberOf(Self, "cMD5", .T.) .And. AttIsMemberOf(Self, "lEnvDuplic", .T. ) .And. AttIsMemberOf(Self, "nMhqRec", .T. )
	Local aAreaMhq      := MHQ->(GetArea())
	Local lBkpSucesso   := .T.

	Self:cBodyList      := ''
	Self:aMhrRec        := {}
	
	//Carrega a distribuições que devem ser enviadas
    Self:SetaProcesso(Self:cProcesso)

	If Self:lSucesso
		Self:Consulta()
	EndIf
	
	If Self:lSucesso .And. !Empty(Self:cAliasQuery)
	
		While !(Self:cAliasQuery)->(Eof())

			If Self:lSucesso
				
				While !(Self:cAliasQuery)->(Eof())
					
					Self:lSucesso := .T.
					Self:cRetorno := ""
					Self:cBody    := ""

					//Posiciona na publicação
					MHQ->(DbSetOrder(1))  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE
					MHQ->(DbGoTo((Self:cAliasQuery)->RECNO_PUB))

					Self:cOrigem     := MHQ->MHQ_ORIGEM
					Self:cEvento     := MHQ->MHQ_EVENTO //1=Upsert, 2=Delete, 3=Inutilização
					Self:cChaveUnica := MHQ->MHQ_CHVUNI
					Self:cIdExt      := allTrim(MHQ->MHQ_IDEXT)

					If lCtrlMd5
						Self:nMhqRec := MHQ->(Recno())
					EndIf 
					
					//Carrega o layout com os dados da publicação
					If Self:lSucesso                            
						//Carrega a publicação que será distribuida
						Self:cPublica := AllTrim(MHQ->MHQ_MENSAG)
						If Self:oPublica == Nil
							Self:oPublica := JsonObject():New()
						EndIf
						If !Empty(Alltrim(Self:cPublica))
							Self:oPublica:FromJson(Self:cPublica)                                
							Self:CarregaBody()
						Else
							Self:lSucesso := .F.
							Self:cRetorno := "campo MHQ_MENSAG em branco MHQ_UUID -> "+ MHQ->MHQ_UUID    
						EndIf    
					EndIf

					// -- se For um envio duplicado não incluo na lista de envio
					If (lCtrlMd5 .And. !Self:lEnvDuplic) .Or. !lCtrlMd5
						Self:cBodyList += IIF(Empty(Self:cBodyList), "[" + Self:cBody, "," + Self:cBody)
					EndIf 
					
					Aadd(Self:aMhrRec,{})
					Aadd(Self:aMhrRec[Len(Self:aMhrRec)],(Self:cAliasQuery)->RECNO_DIS)
					Aadd(Self:aMhrRec[Len(Self:aMhrRec)],Self:cBody)
					Aadd(self:aMhrRec[Len(self:aMhrRec)],Self:cIdRetaguarda)
					Aadd(Self:aMhrRec[Len(Self:aMhrRec)],Self:lSucesso)
					Aadd(Self:aMhrRec[Len(Self:aMhrRec)],Self:cRetorno)
					
					If lCtrlMd5
						Aadd(Self:aMhrRec[Len(Self:aMhrRec)],Self:cMD5)
						Aadd(Self:aMhrRec[Len(Self:aMhrRec)],Self:lEnvDuplic)
					EndIf 
					
					Self:nMhrRec := (Self:cAliasQuery)->RECNO_DIS
					
					If !Empty(Self:cBodyList)
						Self:lSucesso := .T.
						Self:cRetorno := ""
					EndIf 

					(Self:cAliasQuery)->(DbSkip())
					
				EndDo

				Self:cBodyList += "]"

			EndIf
			
 			If Self:lSucesso .AND. !Empty(Self:cBodyList)
				Self:cBody := Self:cBodyList                            
				Self:GetURLFile()	//Define a URL / Arquivo para envio do Json
				Self:Envia() 		//Fazer envio do json
				lBkpSucesso := Self:lSucesso
			EndIf    
			
			MHR->(DbSetOrder(1)) //MHR_FILIAL + MHR_CASSIN + MHR_CPROCE
			For nX := 1 To Len(Self:aMhrRec)
				MHR->( DbGoTo(Self:aMhrRec[nX][1] ))
				Self:cBody          := Self:aMhrRec[nX][2] //Grava Body na linha MHR
				Self:cChaveUnica    := Posicione("MHQ", 7, xFilial("MHQ") + MHR->MHR_UIDMHQ, "MHQ_CHVUNI") //Ajusta Chave unica quando é lista.
				
				If lBkpSucesso
					Self:lSucesso := Self:aMhrRec[nX][4] // Se estiver com erro gravar o motivo.   
				EndIf
				
				If lCtrlMd5
					Self:cMD5 := Self:aMhrRec[nX][6] // Md5 exclusivo do registro
					Self:lEnvDuplic := Self:aMhrRec[nX][7] // Md5 exclusivo do registro
				EndIf 

				Self:cRetorno := IIF(!Empty(Self:aMhrRec[nX][5]),Self:aMhrRec[nX][5],Self:cRetorno)// Gravar o motivo do erro
				If !MHR->(Eof())                        
					//Atualiza dados na tabela MHR
       				_Super:atualizaMHR(IIF( Self:lSucesso, "2", IIF(Self:lEnvDuplic, "R", "3") ))
				EndIf
			Next

			Self:aMhrRec 	:= {}
			Self:cBodyList	:= ""
			Self:lSucesso  	:= .T. 

			If (Self:cAliasQuery)->(Eof())
				Self:Consulta()
			Endif              
		EndDo

		(Self:cAliasQuery)->(DbCloseArea())

	EndIf

	RestArea(aAreaMHQ)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Metodo responsavel por enviar a mensagens ao NAPP

@type       Method
@author     Eduardo Sales
@since      12/09/2025
@version    P12
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvNappObj
	
	Local cPath		:= "\Autocom\Integracoes\"
	Local aHeader	:= {}

	If Self:lSucesso

		Self:oEnvia := FWRest():New("")
		Self:oEnvia:SetPath(Self:cUrlFile)
		
		Self:cBody := Self:MontaBody(cPath, Self:cFileName) //Self:ConvertFile(cPath + Self:cFileName)
		Self:cBody := EncodeUTF8(Self:cBody)

		LjGrvLog(" RmiEnvNappObj ", "Method Envia() no oEnvia:SetPostParams(cBody) ", {Self:cBody})

		aAdd(aHeader, "Content-Type: plain/text")

		If Self:oEnvia:Put(aHeader, Self:cBody)
			Self:lSucesso := .T.
			Self:cRetorno := Self:oEnvia:oResponseH:cStatusCode
		Else
			Self:cRetorno := Self:oEnvia:GetLastError() + " - [" + Self:cUrlFile + "]" + CRLF
			LjGrvLog(" RmiEnvNappObj ", "Não teve sucesso retorno => ", {Self:cRetorno}) 
		EndIf

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Consulta
Metodo que efetua consulta das distribuições a enviar

@type       Method
@author     Eduardo Sales
@since      12/09/2025
@version    P12
/*/
//-------------------------------------------------------------------
Method Consulta() Class RmiEnvNappObj

	Local cDB       := AllTrim(TcGetDB())
	Local cQuant    := "1000"
	Local cSelect   := IIF(cDB == "MSSQL"           , " TOP " + cQuant          , "")
	Local cWhere    := IIF(cDB == "ORACLE"          , " AND ROWNUM <= " + cQuant, "")
	Local cLimit    := IIF(!(cDB $ "MSSQL|ORACLE")	, " LIMIT " + cQuant        , "")

	LjGrvLog(" RmiEnviaObj ", "Antes da execução do metodo consulta", FWTimeStamp(2))
	
	//Carrega a distribuições que devem ser enviadas
	LjGrvLog("RmiEnviaObj", "Conectado com banco de dados: " + cDB)

	Self:cAliasQuery := GetNextAlias()

	Self:cQuery := "SELECT "
	Self:cQuery += cSelect
	Self:cQuery += " MHQ_CPROCE, MHQ.R_E_C_N_O_ AS RECNO_PUB, MHR.R_E_C_N_O_ AS RECNO_DIS "
	Self:cQuery += " FROM " + RetSqlName("MHQ") + " MHQ INNER JOIN " + RetSqlName("MHR") + " MHR "
	Self:cQuery += " ON MHQ_FILIAL = MHR_FILIAL AND MHQ_UUID = MHR_UIDMHQ "

	If !Empty(Self:cProcesso)
		Self:cQuery += " AND MHQ_CPROCE = '" + Self:cProcesso + "'"
	EndIf    

	Self:cQuery += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "'"
	Self:cQuery += " AND MHR_CASSIN = '" + Self:cAssinante + "'"
	Self:cQuery += " AND MHR_STATUS = '1' "                         //1=A processar, 2=Processado, 3=Erro
	Self:cQuery += " AND MHR.D_E_L_E_T_ = ' ' "
	Self:cQuery += " AND MHQ.D_E_L_E_T_ = ' ' "

	//Envia para nao repetir itens na lista.
	If Self:nMhrRec > 0
		Self:cQuery      += " AND MHR.R_E_C_N_O_ > " + Alltrim(STR(Self:nMhrRec))
	EndIf
	
	Self:cQuery      += cWhere    
	Self:cQuery      += " ORDER BY MHR.R_E_C_N_O_"
	Self:cQuery      += cLimit

	LjGrvLog("RmiEnvObj", "Query com registros que serão enviados:", Self:cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry( , , Self:cQuery), Self:cAliasQuery, .T., .F.)
	LjGrvLog(" RmiEnviaObj ", "Apos executar a query do metodo consulta", FWTimeStamp(2))

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetorno
Trata o retorno do lote

@type       Method
@author     Eduardo Sales
@since      12/09/2025
@version    P12
@param      cJson, caractere, Variavel contendo o Json que sera tratado
@param      nTipo, numerico, Tipo de tratamento (0 - Token, 1 - URL)
/*/
//-------------------------------------------------------------------
Method TrataRetorno(cJson, nTipo) Class RmiEnvNappObj

    Local oRet := JsonObject():New()
    
	oRet:FromJson(DeCodeUTF8(cJson))

    LjGrvLog(" RmiEnvNappObj ", "Method TrataRetorno(): " + IIf(nTipo == 0,"Token","URL") + " de lote executado. JSON de Retorno da API NAPP : ",{cJson})

    //0 - Token
    If nTipo == 0 
		If oRet:HasProperty("access_token")
			Self:lSucesso := .T.
			Self:cToken := oRet["access_token"]
		EndIf
	//1 - URL
    ElseIf nTipo == 1
		If oRet:HasProperty("uploadFiles")
			Self:lSucesso := .T.
			Self:cFileName := oRet["uploadFiles"][1]["name"]
			Self:cUrlFile := oRet["uploadFiles"][1]["url"]
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraToken
Retorna a URL para envio do arquivo .json

@type       Method
@author     Eduardo Sales
@since      12/09/2025
@version    P12
/*/
//-------------------------------------------------------------------
Method GetURLFile() Class RmiEnvNappObj

	Local oRest		:= Nil
	Local cJson     := ""
	Local aHeader   := {}
	Local cFile 	:= "vendas_protheus.json"

	If !Empty(Self:cToken)

		BeginContent var cJson
			{
    			"files": [
					{
						"type": "vendas",
						"name": "%Exp:cFile%"
					}
				]
			}
		EndContent

		oRest := FWRest():New("")
		oRest:SetPath(Self:cUrlUpload)
		oRest:SetPostParams(EncodeUTF8(cJson))
		aAdd(aHeader, "Content-Type:application/json")
		aAdd(aHeader, "Authorization: Bearer " + Self:cToken)

		If oRest:Post(aHeader)
			Self:lSucesso := .T.
			Self:TrataRetorno(oRest:GetResult(), 1) //1 - URL
		Else
			Self:lSucesso := .F.
			Self:cRetorno := oRest:GetLastError() + " - [" + Self:cUrlUpload + "]"
			LjGrvLog(" RmiEnvNappObj ", "Não teve sucesso retorno => " ,{Self:cRetorno}) 
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaBody
Monta o body do envio para a NAPP

@type       Method
@author     Eduardo Sales
@since      12/09/2025
@version    P12
@param      cPath, caractere, Caminho onde o arquivo sera salvo temporariamente
@param      cFileName, caractere, Nome do arquivo
/*/
//-------------------------------------------------------------------
Method MontaBody(cPath, cFileName) Class RmiEnvNappObj

    Local oFile		:= Nil
	Local nSize		:= 0
	Local nHandle	:= 0
	Local cRetBody	:= ""

	If FWMakeDir(cPath)
		//Cria o arquivo para salvar o Json de envio
		nHandle := FCreate(cPath + cFileName)
		oFile := FWrite(nHandle, Self:cBody)
		FClose(nHandle)

		If File(cPath + cFileName)
			//Le o arquivo e salva o conteudo em uma variavel
			nHandle := FOpen(cPath + cFileName, FO_READWRITE + FO_SHARED)
			nSize := FSeek(nHandle, 0, FS_END)
			FSeek(nHandle, 0, FS_SET)
			FRead(nHandle, cRetBody, nSize)
			FClose(nHandle)
		EndIf
	EndIf
	
	//Apaga o arquivo Json
	If FErase(cPath + cFileName) <> 0
		LjGrvLog(" RmiEnvNappObj ", "Erro ao apagar o arquivo temporario: " + cPath + cFileName)
	EndIf

Return cRetBody

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaBody
Monta o body do envio para a NAPP

@type       Method
@author     Eduardo Sales
@since      12/09/2025
@version    P12
/*/
//-------------------------------------------------------------------
Method SalvaConfig() Class RmiEnvNappObj

    Self:oConfAssin["token"] := Self:cToken
    
    MHO->( DbSetOrder(1) )  //MHO_FILIAL + MHO_COD
    If MHO->( DbSeek( xFilial("MHO") + PadR(Self:cAssinante, TamSx3("MHO_COD")[1]) ) )
        RecLock("MHO", .F.)
            MHO->MHO_CONFIG := Self:oConfAssin:ToJson()
            MHO->MHO_TOKEN  := ""
        MHO->( MsUnLock() )
    EndIf

Return Nil
