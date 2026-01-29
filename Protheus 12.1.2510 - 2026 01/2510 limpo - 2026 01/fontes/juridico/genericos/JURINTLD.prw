#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "JURINTLD.CH"

Static _lLDSincOn   := .F. // Indica se a sincronização com o LD foi online
Static _cModeloSinc := ""  // Modelo que teve sincronização online com o LD

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIntLD
Realiza operações de forma online na integração Protheus x Legaldesk

@param  cOperacao, Operação da requisição (DELETE, POST, PUT) ou STATUS para sincronização de bloqueio
@param  cModelo  , ID do modelo de dados
@param  cCodLD   , Código Legaldesk do registro
@param  nRecnoEnt, Recno do registro
@param  lSincFila, Indica se força o envio do registro pra fila de sincronização 
                   mesmo fazendo a sincronização online (importante para mudança de STATUS)
                   .T. - Força o envio do registro
                   .F. - Não força o envio, ou seja, obedece a definição da própria rotina
@param  aHeader  , Header adicional (se necessário para algum modelo específico)

@return lRet     , Indica se o registro no protheus pode ser excluído

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Function JurIntLD(cOperacao, cModelo, cCodLD, nRecnoEnt, lSincFila, aHeader)
Local lRet        := .T.

Default cOperacao := ""
Default cModelo   := ""
Default cCodLD    := ""
Default nRecnoEnt := 0
Default lSincFila := .F.
Default aHeader   := {}

	_lLDSincOn   := .F.
	_cModeloSinc := ""

	If !JurIsRest() .And. FWAliasInDic("OI9") // Somente execução via Protheus e com os parâmetros preenchidos
		Processa( {|| lRet := JRunIntLD(cOperacao, cModelo, cCodLD, nRecnoEnt, lSincFila, aHeader) }, STR0001, STR0002, .F. )  // "Aguarde" - "Sincronizando registro"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRunIntLD
Processamento da requisição no Legaldesk para operações (exclusão) de registros

@param  cOperacao, Operação da requisição 
                   DELETE - Operação para exclusão de registro
                   POST   - Operação para inclusão de registro
                   PUT    - Operação para alteração de registro
                   STATUS - Operação para sincronização de específica do Status/Situação do registro
@param  cModelo  , ID do modelo de dados
@param  cCodLD   , Código Legaldesk do registro
@param  nRecnoEnt, Recno do registro
@param  lSincFila, Indica se força o envio do registro pra fila de sincronização 
                   mesmo fazendo a sincronização online (importante para mudança de STATUS)
                   .T. - Força o envio do registro
                   .F. - Não força o envio, ou seja, obedece a definição da própria rotina
@param  aHeader  , Header adicional (se necessário para algum modelo específico)

@return lRet     , Indica se o registro no protheus pode ser excluído/alterado/incluído

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Static Function JRunIntLD(cOperacao, cModelo, cCodLD, nRecnoEnt, lSincFila, aHeader)
Local lRet     := .T.
Local oRest    := Nil
Local cHost    := SuperGetMV("MV_JLDURL", .F., "")      // URL de integração com LD - HostName (Base)
Local cUser    := SuperGetMV("MV_JLDUSR", .F., "")      // Usuário de integração com LD
Local cPwd     := SuperGetMV("MV_JLDPWD", .F., "")      // Senha do usuário de integração com LD
Local cServico := JIntLDAPI(cModelo, cOperacao, cCodLD) // EndPoint (Serviço)

	If !Empty(cHost) .And. !Empty(cServico) .And. !Empty(cUser) .And. !Empty(cPwd)

		oRest := FWRest():New(cHost)
		oRest:SetTimeOut(2) // Tempo de espera para resposta do servidor (2 segundos)

		aAdd(aHeader, "Content-Type: application/json")
		aAdd(aHeader, "Authorization: Basic " + Encode64(cUser + ":" + cPwd))

		ProcRegua(0)
		IncProc()

		If cOperacao == "STATUS"

			oRest:SetPath(cServico) // Seta o endpoint
			oRest:SetPostParams(JIntLDBody(cModelo, nRecnoEnt, cOperacao)) // Seta os parâmetros (body) da requisição

			oRest:Post(aHeader) // Efetiva a requisição - Por padrão os endpoints de mudança de STATUS do LD usam o verbo POST

		ElseIf cOperacao == "DELETE"

			oRest:SetPath(cServico) // Seta o endpoint

			oRest:Delete(aHeader, cHost + cServico) // Efetiva a requisição

		EndIf

		lRet := JIntLDResult(oRest, cModelo, cOperacao, cCodLD, lSincFila) // Obtem o result e faz o tratamento necessário em caso de erro
		
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JLDSincOn
Indica se a sincronização será online.

Para isso a variável _lLDSincOn deve ser .T., e o modelo recebido
por parâmetro deve ser o mesmo gravado na variável _cModeloSinc, que 
foram preenchidas na função JIntLDResult.

Isso é necessário pois alguns modelos enviam mais de um registro pra fila. 
Como o JURA159 (Participantes), que envia natureza e fornecedor, antes
de enviar o próprio participante. Com isso precisamos saber qual é
o modelo para indicar a sincronização online para o modelo correto.

@return  _lLDSincOn .And. cModelo == _cModeloSinc
         - Se .T. sincronização online
         - Se .F. sincronização offline (via fila de sincronização)

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Function JLDSincOn(cModelo)
Return _lLDSincOn .And. cModelo == _cModeloSinc

//-------------------------------------------------------------------
/*/{Protheus.doc} JLDSincOff
Restaura o conteúdo das variáveis _lLDSincOn e _cModeloSinc

@Obs Necessário quando é feito a exclusão do registro e em seguida
     uma nova inclusão para que seja feito a sincronização offline.

@author  Jorge Martins
@since   14/06/2023
/*/
//-------------------------------------------------------------------
Function JLDSincOff()
	_lLDSincOn   := .F.
	_cModeloSinc := ""
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIntLDLog
Gera o log com dados do modelo e da pilha de chamadas para o registro
que ficou com a chave em branco

@param  cModelo      , ID do modelo de dados
@param  cOper        , Operação (verbo) da requisição
@param  cResult      , Resultado da requisição
@param  cErrorResult , Mensagem de erro da requisição (Ex. 404 Not Found)
@param  cCodLD       , Código Legaldesk do registro

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Static Function JIntLDLog(cModelo, cOper, cResult, cErrorResult, cCodLD)
Local cLog      := ""
Local aPart     := JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__cUserId), {"RD0_CODIGO", "RD0_SIGLA", "RD0_NOME"})
Local cData     := Date()
Local cHora     := Time()
Local cDataHora := cValToChar(cData) + " - " + cHora
	
	If Len(aPart) == 3
		cPart := AllTrim(aPart[1]) + " - " + AllTrim(aPart[2]) + " - " + AllTrim(aPart[3])
	EndIf

	cLog += STR0015 + cOper        + CRLF // "Operação: "
	cLog += STR0016 + cPart        + CRLF // "Participante: "
	cLog += STR0017 + cDataHora    + CRLF // "Data e hora de envio: "
	cLog += STR0014 + cErrorResult + CRLF // "Erro: "
	If !Empty(cResult)
		cLog += STR0018 + cResult         // "Complemento do erro: "
	EndIf

	// Faz a gravação do arquivo no protheus_data
	JIntSavelog(cLog, cModelo, cCodLD, cData, cHora)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIntSavelog
Cria o arquivo de log na pasta JURLOGSYNCONLINE dentro da protheus_data

@param  cLog   , Texto de log
@param  cModelo, ID do modelo de dados
@param  cCodLD , Código Legaldesk do registro
@param  cData  , Data atual
@param  cHora  , Horário atual

@author  Jorge Martins
@since   17/05/2023
/*/
//-------------------------------------------------------------------
Static Function JIntSavelog(cLog, cModelo, cCodLD, cData, cHora)
Local cPath       := "\JURLOGSYNCONLINE\"
Local cFileName   := ""
Local nHandle     := -1
Local lChangeCase := .F.
Local lCreated    := .T.

	cData := DtoS(cData)
	cHora := StrTran(cHora, ":", "")

	If !ExistDir(cPath, Nil, lChangeCase)
		// Cria pasta JURLOGSYNCONLINE caso não exista
		lCreated := MakeDir(cPath, Nil, lChangeCase) == 0
	EndIf

	If lCreated
		// Formato do nome do arquivo: JURA070_20230201_172123_098767546365679892
		cFileName := cModelo + "_" + cData + "_" + cHora + "_" + AllTrim(cCodLD) + ".txt"
		nHandle   := FCreate(cPath + cFileName, Nil, Nil, lChangeCase)
		
		If nHandle == -1 // Erro ao criar arquivo
			JurLogMsg(i18N(STR0019, {cData, cHora})) // "#1 - #2 - Falha ao criar o arquivo de log!"
		Else
			FWrite(nHandle, cLog)
			FClose(nHandle)
		EndIf
	Else
		JurLogMsg(i18N(STR0020, {cData, cTime})) // "#1 - #2 - Falha ao criar o dirétorio de log!"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIntLDAPI
Obtém a API conforme operação e modelo no cadastro de URL's da integração
com o LD.

@param  cModelo  , ID do modelo de dados
@param  cOperacao, Operação da requisição 
                   DELETE - Operação para exclusão de registro
                   POST   - Operação para inclusão de registro
                   PUT    - Operação para alteração de registro
                   STATUS - Operação para sincronização de específica do Status/Situação do registro
@param  cCodLD   , Código Legaldesk do registro

@return cAPI     , cAPI da integração

@author  Jorge Martins
@since   09/11/2023
/*/
//-------------------------------------------------------------------
Static Function JIntLDAPI(cModelo, cOperacao, cCodLD)
Local cAPI   := ""
Local cCampo := IIf(cOperacao == "DELETE", "OI9_DELETE", "OI9_STATUS")

	cAPI := AllTrim(JurGetDados("OI9", 1, xFilial("OI9") + cModelo, cCampo)) // Ex: "/api/v1/UpdateByCodigo/Profissional"

	cAPI := JTrataServ(cAPI, cCodLD)

Return cAPI

//-------------------------------------------------------------------
/*/{Protheus.doc} JTrataServ
Faz o tratamento do trecho do serviço (Endpoint) para substituir a 
flag #CODLD# da URL pelo código Legaldesk do registro (caso tenha).
Obs: É feito o uso dessa flag, para sabermos exatamente o ponto
     onde o código Legaldesk deve ser adicionado ao montar a URL.

@param  cServico, EndPoint da URL (Ex: "/API/v1/ODataGERALADV/CasoViews('#CODLD#')")
@param  cCodLD  , Código Legaldesk do registro

@return cServico, EndPoint da URL com o código Legaldesk correto 
                  (Ex: "/API/v1/ODataGERALADV/CasoViews('633DD2BA-4B7F-9163-8A7E-9C58AA445FB8')")

@author  Jorge Martins
@since   09/11/2023
/*/
//-------------------------------------------------------------------
Static Function JTrataServ(cServico, cCodLD)

	If !Empty(cServico) .And. !Empty(cCodLD) .And. at("#CODLD#", cServico) > 0
		cServico := Replace(cServico, "#CODLD#", cCodLD)
	EndIf

Return cServico

//-------------------------------------------------------------------
/*/{Protheus.doc} JIntLDBody
Monta os parâmetros (body) da requisição, conforme a identificação
do modelo

@param  cModelo  , ID do modelo de dados
@param  nRecnoEnt, Recno do registro
@param  cOperacao, Operação da requisição 
                   DELETE - Operação para exclusão de registro
                   POST   - Operação para inclusão de registro
                   PUT    - Operação para alteração de registro
                   STATUS - Operação para sincronização de específica do Status/Situação do registro

@return cBody, Body da requisição

@author  Jorge Martins
@since   09/11/2023
/*/
//-------------------------------------------------------------------
Static Function JIntLDBody(cModelo, nRecnoEnt, cOperacao)
Local cBody := ""

	If cModelo == "JURA159"
		cBody := JBody159(nRecnoEnt, cOperacao)
	EndIf

Return cBody

//-------------------------------------------------------------------
/*/{Protheus.doc} JBody159
Monta os parâmetros (body) da requisição de mudança de STATUS do
cadastro de participantes (JURA159)

@param  nRecnoEnt, Recno do registro
@param  cOperacao, Operação da requisição 
                   DELETE - Operação para exclusão de registro
                   POST   - Operação para inclusão de registro
                   PUT    - Operação para alteração de registro
                   STATUS - Operação para sincronização de específica do Status/Situação do registro

@return cBody, Body da requisição

@author  Jorge Martins
@since   09/11/2023
/*/
//-------------------------------------------------------------------
Static Function JBody159(nRecnoEnt, cOperacao)
Local aArea      := GetArea()
Local cDataSaida := ""

	If cOperacao == "STATUS"
		If M->RD0_MSBLQL == "1" // Ativo = 1-Não - Está BLOQUEANDO o participante
			cDataSaida := DToS(IIf(Empty(M->RD0_DTADEM), Date(), M->RD0_DTADEM))
		Else // Ativo = 2-Sim - Está ATIVANDO o participante
			cDataSaida := ""
		EndIf

		cBody := '{'
		cBody +=    '"conditions": {"Codigo":"' + M->RD0_CODIGO + '"},'
		cBody +=    '"values": {"DataSaida":"' + cDataSaida + '"}'
		cBody += '}'
	EndIf

	RestArea(aArea)

Return cBody

//-------------------------------------------------------------------
/*/{Protheus.doc} JIntLDResult
Obtem o result da requisição e faz o tratamento necessário em caso de erro.
Em caso de erro faz a geração de um arquivo de log.

Também é feita a avaliação das variáveis lSincFila e _lLDSincOn, para definir
se será necessário fazer a integração via fila de sincronização, já que em
casos de erros ou em alteração de STATUS (caso tenha sido alterada mais alguma
informação no modelo de dados além do Status) o registro será
enviado para a fila, para sincronizar o restante das informações.

@param  oRest    , Objeto FwRest da requisição com o LD
@param  cModelo  , ID do modelo de dados
@param  cOperacao, Operação da requisição 
                   DELETE - Operação para exclusão de registro
                   POST   - Operação para inclusão de registro
                   PUT    - Operação para alteração de registro
                   STATUS - Operação para sincronização de específica do Status/Situação do registro
@param  cCodLD   , Código Legaldesk do registro
@param  lSincFila, Indica se força o envio do registro pra fila de sincronização 
                   mesmo fazendo a sincronização online (importante para mudança de STATUS)
                   .T. - Força o envio do registro
                   .F. - Não força o envio, ou seja, obedece a definição da própria rotina

@return lRet     , Indica se o registro no protheus pode ser excluído/alterado/incluído

@author  Jorge Martins
@since   09/11/2023
/*/
//-------------------------------------------------------------------
Static Function JIntLDResult(oRest, cModelo, cOperacao, cCodLD, lSincFila)
Local cCodeResult  := oRest:GetHTTPCode()
Local lResult2xx   := Substr(cCodeResult, 1, 1) == "2"
Local lResult5xx   := Substr(cCodeResult, 1, 1) == "5"
Local cProblema    := ""
Local cSolucao     := ""
Local cErrorResult := ""
Local nValid       := 0
Local oResult      := Nil
Local lRet         := .T.
Local cEvento      := JGetEvento(cOperacao) // Indica o texto da operação - Ex: incluir, alterar, excluir

	Do Case
		Case lResult2xx // Resultados válidos -- Resultados 2xx
			
			If lSincFila
				// Vai realizar a operação no registro e vai adicionar na NYS, pois pode haver algum complemento do modelo que precise ser sincronizado
				_lLDSincOn   := .F. // Indica que não houve sincronização online
				_cModeloSinc := ""  // Limpa variável de modelo já que não houve sincronização online
			Else
				// Vai realizar a operação no registro e NÃO vai adicionar na NYS
				_lLDSincOn   := .T.     // Indica que houve sincronização online
				_cModeloSinc := cModelo // Indica o modelo dessa sincronização, para ser identificado corretamente na J170GRAVA
			EndIf
		
		Case cCodeResult == "404" .Or. lResult5xx // 404 ou Erros 5xx
			// 404 - Not Found - Se não encontrar o registro na exclusão online
			// 5xx - Problemas na conexão

			// Vai realizar a operação no registro e vai adicionar na NYS
			_lLDSincOn   := .F. // Indica que não houve sincronização online
			_cModeloSinc := ""  // Limpa variável de modelo já que não houve sincronização online

			// Inclui arquivo de Log
			JIntLDLog(cModelo, cOperacao, oRest:GetResult(), oRest:GetLastError(), cCodLD)

		Case cCodeResult == "401" // Unauthorized - Usuário ou senha incorretos
			cProblema := I18N(STR0003, {cEvento}) // "Não foi possível #1 o registro devido a falha na autenticação (usuário ou senha inválidos) durante a sincronização dos dados com o LEGALDESK"
			cSolucao  := STR0004 // "Contate a equipe técnica para verificar o preenchimento dos parâmetros MV_JLDUSR e MV_JLDPWD. Após o ajuste, refaça a operação."

		Case cCodeResult == "403" // Forbidden - Usuário sem direito de acesso
			cProblema := I18N(STR0005, {cEvento}) // "Não foi possível #1 o registro devido a permissão de acesso durante a sincronização dos dados com o LEGALDESK"
			cSolucao  := STR0006 // "Contate a equipe técnica para verificar no LEGALDESK a permissão do usuário (indicado no parâmetro MV_JLDUSR). Após o ajuste, refaça a operação."

		Case Empty(cCodeResult) .And. Empty(oRest:GetResult()) // URL inválida
			If "HOST NOT FOUND" $ Upper(oRest:GetLastError())
				cProblema := I18N(STR0007, {cEvento}) // "Não foi possível #1 o registro devido a falha na conexão durante a sincronização dos dados com o LEGALDESK"
				cSolucao  := STR0008 // "Contate a equipe técnica para verificar o preenchimento do parâmetro MV_JLDURL. Após o ajuste, refaça a operação."
			Else
				// Vai realizar a operação no registro e vai adicionar na NYS
				_lLDSincOn   := .F. // Indica que não houve sincronização online
				_cModeloSinc := ""  // Limpa variável de modelo já que não houve sincronização online

				// Inclui arquivo de Log
				JIntLDLog(cModelo, cOperacao, oRest:GetResult(), oRest:GetLastError(), cCodLD)
			EndIf

		Case cCodeResult == "405" // Method Not Allowed - Erro de CORS
			cProblema := I18N(STR0024, {cEvento})// "Não foi possível #1 o registro devido a configuração de CORS (Cross-Origin Resource Sharing) durante a sincronização dos dados com o LEGALDESK."
			cSolucao  := STR0025 // "Contate a equipe técnica para verificar no Servidor LEGALDESK a configuração de CORS para permitir requisições do Protheus. Após o ajuste, refaça a operação."

		Case cCodeResult == "400" .And. !Empty(oRest:GetResult()) // Alguma validação no LD impede a operação

			oResult := JsonObject():New()
			oResult:FromJSON(oRest:GetResult())

			If oResult <> Nil .And. ValType(oResult) == "J" // JsonObject
				If oResult["result"] <> Nil .And. ;
					oResult["result"]["detail"] <> Nil .And. ; 
					oResult["result"]["detail"]["validations"] <> Nil .And. ValType(oResult["result"]["detail"]["validations"]) == "A"
					For nValid := 1 To Len(oResult["result"]["detail"]["validations"])
						cErrorResult += CRLF + DecodeUTF8(oResult["result"]["detail"]["validations"][nValid]["errorMessage"])
					Next
				Else
					If oResult["result"] <> Nil .And. oResult["result"]["message"] <> Nil .And. ValType(oResult["result"]["message"]) == "C"
						cErrorResult += CRLF + DecodeUTF8(oResult["result"]["message"])
					EndIf
				EndIf
			EndIf

			cProblema := I18N(STR0011, {cEvento}) + CRLF + CRLF + STR0012 + cErrorResult // "Não foi possível #1 o registro devido a regra não atendida durante a sincronização dos dados com o LEGALDESK. " - "Regra: "
			cSolucao  := STR0013 // "Contate a equipe técnica para verificar as regras no LEGALDESK."

	End Case

	If !Empty(cProblema)
		cProblema += " - " + STR0014 + oRest:GetLastError() // "Erro: "
		lRet := JurMsgErro(cProblema,, cSolucao)
		// Inclui arquivo de Log
		JIntLDLog(cModelo, cOperacao, oRest:GetResult(), oRest:GetLastError(), cCodLD)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetEvento
Indica o texto a ser usado nas mensagens conforme a operação

@param  cOperacao, Operação da requisição 
                   DELETE - Operação para exclusão de registro
                   POST   - Operação para inclusão de registro
                   PUT    - Operação para alteração de registro
                   STATUS - Operação para sincronização de específica do Status/Situação do registro

@return cEvento, Texto do evento: alterar, excluir ou incluir

@author  Jorge Martins
@since   09/11/2023
/*/
//-------------------------------------------------------------------
Static Function JGetEvento(cOperacao)
Local cEvento := ""

	Do Case
		Case cOperacao $ "PUT|STATUS"
			cEvento := STR0021 // "alterar"
		Case cOperacao == "DELETE"
			cEvento := STR0022 // "excluir"
		Case cOperacao == "POST"
			cEvento := STR0023 // "incluir"
	End Case

Return cEvento
