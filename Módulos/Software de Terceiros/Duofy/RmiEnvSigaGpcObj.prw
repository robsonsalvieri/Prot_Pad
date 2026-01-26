#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "RMIENVPDVSYNCOBJ.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnvLiveObj
Classe responsável pelo envio de dados ao Live

/*/
//-------------------------------------------------------------------
Class RmiEnvSigaGpcObj From RmiEnviaObj

	Data aProcessos             as Array        //Array com todos os processos de envio ativos para abertura de lote
	Data aMhrRec                as Array
	Data nQtdList               as Numeric
	Data cBodylist              as Character    //Corpo da mensagem que será enviada para o sistema de destino
	Data cFormasDesk			as Character	//Formas de pagamento do ERP x PDV
	Data cFilEnv				as Character	//Filial da publicação


	Method New()                                //Metodo construtor da Classe

	Method PreExecucao()                //Metodo para gerar o token no PDV Sync
	Method PosExecucao()                //Metodo com as regras para efetuar algum tratamento depois de ser feito o envio.
	Method Envia()                      //Metodo responsavel por enviar a mensagens ao PDVSync

	Method Grava(cStatus,cId)			//Metodo que ira registrar os envios realizados ao sistema de destino

	Method Consulta()                   //Consulta as publicações disponiveis para o envio para um determinado processo com base nos LOTE's abertos
	Method Processa(aStDados,cFilPub)           //Metodo que ira controlar o processamento dos envios em lista
	Method precedencia()                //Metodo para tratamento de precedencia
	Method AtualizaParam()			  	//Metodo para atualizar os parametros
	Method GetParamValue()			  	//Metodo para pegar o valor do parametro
	Method GetInfoCondicao()			//Metodo para pegar informações da condição de pagamento

	Method getHeader(cCompanyId)                  //Metodo para carregar o header enviado em cada requisição (token)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso) Class RmiEnvSigaGpcObj

	_Super:New("SIGAGPC", cProcesso)

	If self:lSucesso

		self:lLoteIdRet := .F.
		self:aProcessos         := {}
		self:cFilEnv	:= ""
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo para gerar o token no PDV Sync

@author  Bruno Almeida
@Date    21/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnvSigaGpcObj

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Metodo responsavel por enviar a mensagens ao PDVSync

@author  Bruno Almeida
@Date    21/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvSigaGpcObj

	Local oJsonObj
	Local cJsonAux
	Local cCompanies := ""
	Local cUrl 		 := ""
	Local cId 		 := ""

	//Inteligencia poderá ser feita na classe filha - default em Rest com Json
	If Self:lSucesso

		//Inteligencia poderá ser feita na classe filha - default em Rest com Json
		If Self:oEnvia == Nil
			Self:oEnvia := FWRest():New("")
			Self:oEnvia:nTimeOut := self:nTimeOut
		EndIf

		If Self:oConfProce:hasProperty("companies")
			If	Substr(Self:oConfProce["companies"],1,1) == "&"
				cCompanies := &(AllTrim(SubStr(Self:oConfProce["companies"],2)))
			Else
				cCompanies := Self:oConfProce["companies"]
			EndIf
		EndIf

		if self:oConfAssin:hasProperty("url")
			If	Substr(Self:oConfAssin["url"],1,1) == "&"
				cUrl := &(AllTrim(SubStr(Self:oConfAssin["url"],2)))
			Else
				cUrl := Self:oConfAssin["url"]
			EndIf
			cUrl += '/queue/'+cCompanies+'_in'
			Self:oEnvia:SetPath( cUrl )
		endif

		oJsonObj := JsonObject():New()
		oJsonObj['id'] := (cId := FWUUIDV4(.T.))
		oJsonObj['entity'] := Self:oConfProce["entity"]//oEntityDataLoad:cEntityName
		oJsonObj['dataArray'] := {}
		oJsonObj['companies'] := {cCompanies}

		cJsonAux := oJsonObj:ToJson()
		cJsonAux := StrTran(cJsonAux, '"dataArray":[]', '"dataArray":[' + Self:cBody + ']')

		Self:cBody := cJsonAux

		Self:oEnvia:SetPostParams(EncodeUTF8(Self:cBody))
		LjGrvLog(" RmiEnvSigaGpcObj ", "Method Envia() no oEnvia:SetPostParams(cBody) " ,{Self:cBody})

		//Carrega o aHeader
		self:getHeader(cCompanies)

		LjGrvLog(" RmiEnvSigaGpcObj ", "Retorno do método getHeader: " ,{self:aHeader})

		If Self:oEnvia:Post( self:aHeader )
			Self:lSucesso := .T.
			Self:cRetorno := Self:oEnvia:oResponseH:cStatusCode
			LjGrvLog(" RmiEnvSigaGpcObj ", "Enviado com sucesso!" ,{Self:oEnvia:oResponseH:cStatusCode})
		Else
			Self:cRetorno := Self:oEnvia:GetResult()
			Self:lSucesso := Empty(Self:cRetorno)
			if !Self:lSucesso
				Self:cRetorno := Self:oEnvia:GetLastError() + " - [" + Self:oConfProce["entity"] + "]" + CRLF
				Self:cRetorno += IIF( ValType(self:oEnvia:CRESULT) == "C", self:oEnvia:CRESULT, "Detalhe do erro não retornado." )
				LjGrvLog(" RmiEnvSigaGpcObj ", "Não teve sucesso retorno => " ,{Self:cRetorno})
			endif
		EndIf

		self:Grava(,cId)

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira atualizar a situação da distribuição e gravar o de/para

@author  Bruno Almeida
@Date    15/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Grava(cStatus,cId) Class RmiEnvSigaGpcObj

	Default cStatus     := IIF( self:lSucesso, "2", "3" )     //1=A processar, 2=Processado, 3=Erro, 6=Aguardando Confirmação R=Repetido
	Default cId         := ""

	Begin Transaction

		RecLock("MHR", .T.)

		MHR->MHR_FILIAL := xFilial("MHR")
		MHR->MHR_CPROCE := self:cProcesso
		MHR->MHR_CASSIN := self:cAssinante
		MHR->MHR_TENTAT := "1"
		MHR->MHR_DATPRO := Date()
		MHR->MHR_HORPRO := Time()
		MHR->MHR_STATUS := cStatus             //1=A Processar;2=Processada;3=Erro
		MHR->MHR_UIDMHQ := cId    //Id de referência do Envio dos dados para a fila
		MHR->MHR_ENVIO := self:cBody //Corpo da mensagem que foi enviada para o sistema de destino
		MHR->MHR_RETORNO := self:cRetorno //Retorno do sistema de destino
		MHR->MHR_IDRET := Self:oEnvia:oResponseH:cStatusCode

		MHR->( MsUnLock() )

	End Transaction

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PosExecucao
Metodo com as regras para efetuar algum tratamento depois de ser feito o envio.

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method PosExecucao() Class RmiEnvSigaGpcObj

	aStDados := {}
	self:AtualizaParam()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Consulta
Metodo que efetua consulta das distribuições a enviar

@author  Lucas Novais (lNovais)
@version 1.0
/*/
//-------------------------------------------------------------------
Method Consulta() Class RmiEnvSigaGpcObj

	Local cDB       := AllTrim( TcGetDB() )
	Local cQuant    := "1000"
	Local cSelect   := IIF( cDB == "MSSQL"            , " TOP " + cQuant          , "" )
	Local cWhere    := IIF( cDB == "ORACLE"           , " AND ROWNUM <= " + cQuant, "" )
	Local cLimit    := IIF( !(cDB $ "MSSQL|ORACLE")   , " LIMIT " + cQuant        , "" )

	LjGrvLog(" RmiEnviaObj ", "Antes da execução do metodo consulta", FWTimeStamp(2))

	//Carrega a distribuições que devem ser enviadas
	LjGrvLog("RmiEnviaObj", "Conectado com banco de dados: " + cDB)

	self:cAliasQuery := GetNextAlias()

	self:cQuery      := "SELECT "
	self:cQuery      += cSelect
	self:cQuery      += " MHQ_CPROCE, MHQ.R_E_C_N_O_ AS RECNO_PUB, MHR.R_E_C_N_O_ AS RECNO_DIS "
	self:cQuery      += " FROM " + RetSqlName("MHQ") + " MHQ INNER JOIN " + RetSqlName("MHR") + " MHR "
	self:cQuery      += " ON MHQ_FILIAL = MHR_FILIAL AND MHQ_UUID = MHR_UIDMHQ "

	If !Empty(self:cProcesso)
		self:cQuery  += " AND MHQ_CPROCE = '" + self:cProcesso + "'"
	EndIf

	self:cQuery      += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "'"
	self:cQuery      += " AND MHR_CASSIN = '" + self:cAssinante + "'"
	self:cQuery      += " AND ( MHR_STATUS = '1'"                         //1=A processar, 2=Processado, 3=Erro
	self:cQuery += " )"
	self:cQuery += " AND MHR.D_E_L_E_T_ = ' ' "
	self:cQuery += " AND MHQ.D_E_L_E_T_ = ' ' "

	//Ajuste envia PdvSync para nao repetir itens na lista.
	If self:nMhrRec > 0
		self:cQuery      += " AND MHR.R_E_C_N_O_ > "+Alltrim(STR(self:nMhrRec))
	EndIf

	self:cQuery      += cWhere

	self:cQuery      += " ORDER BY MHR.R_E_C_N_O_"

	self:cQuery      += cLimit

	ljGrvLog("RmiEnvObj", "Query com registros que serão enviados:", self:cQuery)

	DbUseArea(.T., "TOPCONN", TcGenQry( , , self:cQuery), self:cAliasQuery, .T., .F.)

	LjGrvLog(" RmiEnviaObj ", "Apos executar a query do metodo consulta", FWTimeStamp(2))

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Processa
Metodo que ira controlar o processamento dos envios em lista

@author  totvs
@version 1.0
/*/
//-------------------------------------------------------------------
Method Processa(aStDados,cFilPub) Class RmiEnvSigaGpcObj

	Local nX            := 0
	Local lCtrlMd5      := AttIsMemberOf(Self, "cMD5", .T.) .And. AttIsMemberOf(Self, "lEnvDuplic", .T. ) .And. AttIsMemberOf(Self, "nMhqRec", .T. )

	Default cFilPub := ""
	Default aStDados := {}

	self:cBodyList      := ''
	self:aMhrRec        := {}
	self:cFilEnv		:= cFilPub

	//Carrega a distribuições que devem ser enviadas
	self:SetaProcesso(self:cProcesso)

	If self:lSucesso .And. Len(aStDados) > 0

		For nX := 1 To Len(aStDados)

			If !self:PreExecucao()
				Exit
			EndIf

			self:lSucesso := .T.
			self:cRetorno := ""
			self:cBody    := ""

			self:cOrigem     := aStDados[nX][2]//MHQ->MHQ_ORIGEM
			self:cEvento     := aStDados[nX][4]//MHQ->MHQ_EVENTO //1=Upsert, 2=Delete, 3=Inutilização
			self:cChaveUnica := aStDados[nX][5]//MHQ->MHQ_CHVUNI
			self:cIdExt      := allTrim(aStDados[nX][11])//allTrim(MHQ->MHQ_IDEXT)

			//Carrega a publicação que será distribuida
			self:cPublica := allTrim(aStDados[nX][6])//AllTrim(MHQ->MHQ_MENSAG)
			If self:oPublica == Nil
				self:oPublica := JsonObject():New()
			EndIf
			If !Empty(Alltrim(self:cPublica))
				self:oPublica:FromJson(self:cPublica)
				self:CarregaBody()
				If !self:lSucesso
					self:cBody := ""
				EndIf
			Else
				self:lSucesso := .F.
				self:cRetorno := "campo MHQ_MENSAG em branco MHQ_UUID -> "+ aStDados[nX][10]//MHQ->MHQ_UUID
			EndIf

			if Self:lSucesso
				self:cBodyList    += IIF(Empty(self:cBodyList),self:cBody,","+self:cBody)
			EndIf

			If !Empty(self:cBodyList)
				Self:lSucesso := .T.
				self:cRetorno := ""
			EndIf
		Next

		If !Empty(self:cBodyList)
			self:cBody := self:cBodyList
			self:Envia()
		EndIf

		self:PosExecucao()  //caso o lote estiver aberto fechar.
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getHeader
Metodo para carregar o header

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method getHeader(cCompanyId) Class RmiEnvSigaGpcObj

	Local cPsw := ""

	FwFreeArray(self:aHeader)
	self:aHeader := {}

	If self:oConfAssin:hasProperty("autenticacao")

		Aadd(self:aHeader, "accept: */*")
		Aadd(self:aHeader, "Content-Type: application/json")

		cPsw := LjAuxPosic('COMPARTILHAMENTOS','CompanyID',cCompanyId,'SenhaInt')

		Aadd(self:aHeader, "user: "+cCompanyId+"_user")
		Aadd(self:aHeader, "password: "+cPsw)

	Else
		LjGrvLog(" RmiEnvSigaGpcObj ", "Credenciais de autenticação não informadas. Verifique! ")
	EndIf


Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtualizaParam
Metodo para atualizar parametros

@author  Danilo Brito
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method AtualizaParam() Class RmiEnvSigaGpcObj
	Local oModel := Nil
	Local aParameter := {}
	Local nParameter := 0
	Local cValType := ""
	Local xValue
	Local lOk := .T.
	Local cParametro := ""
	Local xOldValue := ""
	Private INCLUI := .T.

	if self:oConfAssin:HasProperty("dataParam") .AND. self:oConfAssin['dataParam'] <> DTOS(Date())
		if self:oConfAssin:HasProperty("parametros")
			aParameter := aClone(self:oConfAssin["parametros"])

			PshSetTCad("PARAMETROS")
			oModel := FwLoadModel("LjCadAux")
			For nParameter := 1 to len(aParameter)
				xValue := self:GetParamValue(aParameter[nParameter], @cValType)

				if valtype(aParameter[nParameter][1]) == "A"
					cParametro := ArrTokStr(aParameter[nParameter][1])
				else
					cParametro := aParameter[nParameter][1]
				endif

				cNomeDestino := LjAuxPosic("PARAMETROS", "parametro", cParametro, "nome")
				if empty(cNomeDestino)
					oModel:SetOperation(MODEL_OPERATION_INSERT)
					INCLUI := .T.
				else
					xOldValue := Alltrim(LjAuxPosic("PARAMETROS", "parametro", cParametro, "valor"))
					if (xValue == xOldValue)
						LOOP
					endif

					oModel:SetOperation(MODEL_OPERATION_UPDATE)
					INCLUI := .F.
				endif
				oModel:Activate()

				oModel:LoadValue( 'MIHMASTER', "MIH_DESC"         , cParametro)
				oModel:LoadValue( 'MIHMASTER', "MIH_ATIVO"        , "1")

				oModel:LoadValue( 'MIHDETAIL', "parametro"        , cParametro)
				oModel:LoadValue( 'MIHDETAIL', "nome"        	 , aParameter[nParameter][3])
				oModel:LoadValue( 'MIHDETAIL', "tipo"             , iif(cValType=="L","boolean",iif(cValType=="N","number","string")))
				oModel:LoadValue( 'MIHDETAIL', "valor"            , xValue)

				lOk := oModel:vldData() .And. oModel:commitData()
				If !lOk
					cErro   := oModel:GetErrorMessage()[6]
					LjGrvLog("SIGAGPC:AtualizaParam", "Erro ao gravar parametro" + AllTrim(cErro))
				EndIf
				oModel:DeActivate()
			Next nParameter

			FwFreeObj(oModel)

			self:oConfAssin['dataParam'] := DTOS(Date())
			self:SalvaConfig()
		endif
	endif
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetParamValue
Metodo para pegar conteudo do parametro e converter se necessario

@author  Danilo Brito
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method GetParamValue(aParameter, cValType) Class RmiEnvSigaGpcObj

	Local xValue
	Local nParameter := 1
	Local lExprConvArray := valtype(aParameter[4]) == "A"
	Local cExprConv := ""

	cValType := valtype(aParameter[2])

	if cValType == "C"
		xValue := Alltrim(GetMv(aParameter[1],.F.,aParameter[2]))
		cExprConv := aParameter[4]
	elseif cValType == "N"
		xValue := cValToChar(GetMv(aParameter[1],.F.,aParameter[2]))
		cExprConv := aParameter[4]
	elseif cValType == "L"
		xValue := iif(GetMv(aParameter[1],.F.,aParameter[2]),"true","false")
		cExprConv := aParameter[4]
	elseif cValType == "A"
		xValue := self:GetParamValue({aParameter[1][nParameter], aParameter[2][nParameter], "", iif(lExprConvArray,aParameter[4][nParameter],"")}, @cValType)
		for nParameter := 2 to len(aParameter[1])
			if len(aParameter) >= 5 .AND. !empty(aParameter[5]) //separador
				xValue += aParameter[5]
			endif
			xValue += self:GetParamValue({aParameter[1][nParameter], aParameter[2][nParameter], "", iif(lExprConvArray,aParameter[4][nParameter],"")}, @cValType)
		next nParameter
		if len(aParameter) >= 5 .AND. !empty(aParameter[5]) //separador
			cValType := "C" //forço ser string
		endif
		if lExprConvArray
			cExprConv := ""
		else
			cExprConv := aParameter[4]
			lExprConvArray := .F.
		endif
	endif

	//regra de conversão
	if !empty(cExprConv)
		xValue := &(cExprConv)
		cValType := valtype(xValue)
		if cValType == "N"
			xValue := cValToChar(xValue)
		elseif cValType == "L"
			xValue := iif(xValue,"true","false")
		endif
	endif

Return xValue


//-------------------------------------------------------------------
/*/{Protheus.doc} GetInfoCondicao
Metodo para pegar a condição de pagamento

@param nOpc		Tipo de retorno: 1=Qtd Parcelas;2=Data Vencimento;3=Valor Parcela
@param cCondic	Código da condição de pagamento

@author  Danilo Brito
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method GetInfoCondicao(nOpc, cCondic) Class RmiEnvSigaGpcObj

	Local aParc
	Local nParc
	Local xRet

	aParc := condicao(100,PadR(cCondic,TamSX3("E4_CODIGO")[1]),0.00,dDatabase,0.00,{},,0)
	nParc := Len(aParc)
	if nParc <= 0
		nParc := 1
	endif

	if nOpc == 1
		xRet := nParc
	elseif nOpc == 2
		if Len(aParc) > 0
			xRet := aParc[1][1]
		else
			xRet := dDatabase
		endif
	elseif nOpc == 3
		if Len(aParc) > 0
			xRet := aParc[1][2]
		else
			xRet := 0.00
		endif
	endif

Return xRet
