#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSTAFST2.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE N_TAFKEY			01
#DEFINE N_TAFTICKET			02
#DEFINE N_ST2_OK			03
#DEFINE N_ST2_STATUS		04
#DEFINE N_XERP_OK			05
#DEFINE N_XERP_STATUS		06
#DEFINE N_XERP_COD_ERR		07
#DEFINE N_XERP_TIK_ERR		08
#DEFINE N_XERP_DET_ERR		09
#DEFINE N_TAF_STATUS		10
#DEFINE N_TAF_ACTIVE		11
#DEFINE N_ST2_PRIORIT		12
#DEFINE N_ST2_QUEUE			13
#DEFINE N_ST2_OWNER			14
#DEFINE N_ST2_PREDECES		15
#DEFINE N_ST2_FILTRAN		16
#DEFINE N_ST2_COMP			17
#DEFINE N_TAF_PROTOCOL		18
#DEFINE N_TAF_DEL_TYPE		19

#DEFINE N_TAM_RESPONSE 		19

STATIC MAXSIZE_FILE 	:= 850000 //bytes
STATIC MAXGET_EVENTOS	:= 500

//----------------------------------------------------------------------------
/*/{Protheus.doc} WSTAFST2
WS para o recebimento de registros de integração para modulo TAF utilizando
a tabela compartilhada TAFST2.


@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
@link http://tdn.totvs.com/pages/viewpage.action?spaceKey=TAF&title=Web+Service+REST

/*/
//---------------------------------------------------------------------------
WSRESTFUL WSTAFST2 DESCRIPTION STR0001 //"Serviço de Integração ERP x TAF" 

	WSDATA ticketCode 		AS STRING
	WSDATA registryKey 		AS STRING
	WSDATA sourceBranch 	AS STRING
	WSDATA startRecNo		AS INTEGER
	WSDATA searchMode 		AS INTEGER
	WSDATA queryElements 	AS INTEGER
	WSDATA lotQuantity 		AS INTEGER
	WSDATA returnRetResponse AS BOOLEAN


	WSMETHOD GET 		DESCRIPTION STR0002 PRODUCES APPLICATION_JSON //"Método para consulta dos registros integrados utilizando o TafTicket ou TafKey. "
	WSMETHOD POST 		DESCRIPTION STR0003 PRODUCES APPLICATION_JSON //"Método de Remessa para integração de registros na tabela compartilhada TAFST2."
	WSMETHOD DELETE 	DESCRIPTION STR0004 PRODUCES APPLICATION_JSON //"Método de Exclusão de registros utilizando o TafTicket."

END WSRESTFUL

//----------------------------------------------------------------------------
/*/{Protheus.doc} GET
Método de consulta principal do Serviço WSTAFST2.

@ticketCode	- Parâmetro para retorno das informações filtrando o resultado
pelo TAFTICKET, obrigatório caso registryKey não seja informado.

@registryKey	- Parâmetro para retorno das informações filtrando o resultado
pelo TAFKEY, obrigatório caso ticketCode não seja informado.

@sourceBranch	- Codigo da Filial do ERP (TAFFIL), opcional

@startRecNo	- RecNo Inicial que a consulta deve considerar para o filtro dos
Registros.

@searchMode 	- Modo de pesquisa, quando não informado o response retorna
todos os TAFKEYs relacionados a busca, quando igual a 1 retorna a última
ocorrência do TAFKEY, quando igual a 2 retorna a última ocorrência válida
do TAFKEY. Este parâmetro é útil quando o mesmo TAFKEY é enviado em vários
TAFTICKET diferentes

@queryElements -  Determina se o método deve retornar os erros dos registros
com statusCode igual a 3 (Erros retornados pelo RET e gravados no TSS), o
retorno será atribuído no grupo streamingErrors. Quando a tag não é informada
os erros são retornados por Default.
Valores validos: 0 - Desabilita, 1 - Habilita.

@lotQuantity - Determina a quantidade de registros que devem ser retornados
por lote.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
WSMETHOD GET QUERYPARAM ticketCode, registryKey, sourceBranch, startRecNo, searchMode, queryElements, lotQuantity, returnRetResponse WSREST  WSTAFST2

	Local aQryParam
	Local lRet
	Local nI
	Local cUId
	Local aRetorno
	Local cFuncIPC
	Local cFuncREST 
	Local cChave
	Local cValorR
	Local cResponse
	Local cCodtoUuid
	Local cThreadId

	cFuncIPC  	:= ""
	cFuncREST 	:= "TAFWST2GET"
	cChave 		:= "GET"
	cValorR 	:= "respGET"
	cResponse	:= ""
	cThreadId   := StrZero(ThreadID(),6)

	::sourceBranch := IIf (ValType(::sourceBranch) == "U","",::sourceBranch) 
	::registryKey := IIf (ValType(::registryKey) == "U","",::registryKey) 
	::ticketCode := IIf (ValType(::ticketCode) == "U","",::ticketCode) 

	//Não dá para estimar o tamanho do TAFKEY, ele pode ter 1 posicão ou 100. 
	//Por conta do RM utilizar o ID do evento como TAFKEY o mesmo utiliza 36 posições
	//A Funcão FWUUID só aceita 25 posições, as demias posicoes sao truncadas.
	cCodtoUuid := cThreadId
	cCodtoUuid += PadR(Right(AllTrim(::registryKey),14),14,'0')
	cCodtoUuid += PadR(Right(AllTrim(::ticketCode),5),5,'0')

	cUId := FWUUID(Lower(cCodtoUuid)) 

	VarSetUID(cUId, .T.)
	TafConOut(CRLF + 'tafuuid_request: ' + cUId ;
				+ ' | ticketCode:' + ::ticketCode ;
				+ ' | registryKey:' + ::registryKey ;
				+ ' | sourceBranch:' + ::sourceBranch ; 
				+ ' | ThreadId:' + cThreadId)

	aQryParam	:= {}
	aRetorno	:= {}

	::SetContentType("application/json")

	aAdd(aQryParam,::ticketCode)
	aAdd(aQryParam,::registryKey)
	aAdd(aQryParam,::startRecNo)
	aAdd(aQryParam,::searchMode)
	aAdd(aQryParam,::sourceBranch)
	aAdd(aQryParam,::queryElements)
	aAdd(aQryParam,::lotQuantity)
	aAdd(aQryParam,::returnRetResponse)

	 

	If WSST2ValFil(::sourceBranch,@cFuncIPC)

	   TAFCALLIPC(cFuncIPC,cFuncREST,cUId,cChave,cValorR,aQryParam)

	  	lRet2 := VarGetAD(cUId,cValorR,@aRetorno)

	  	If !Empty(aRetorno)
			If aRetorno[1]
				For nI := 1 To Len(aRetorno[2])
					cResponse += aRetorno[2][nI]
				Next nI
				::Self:SetResponse(cResponse)
				TafConOut(CRLF + 'tafuuid_response: ' + cUId + ' | ' + cResponse + ' | ' + 'threadId' + cThreadId)
				lRet := .T.
			Else
				SetRestFault(aRetorno[3],aRetorno[4])
				lRet := .F.
			EndIf
		EndIf

		aSize(aRetorno,0)
		VarCleanX(cUId)
	Else
		::Self:SetResponse(getErrResponse("803",STR0024 + "sourceBranch (TAFFIL) " + STR0025)) ////"O valor do campo "#" não está cadastro no complemento de empresas."
		lRet := .T.
	EndIf

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFWST2GET
Função de consulta do serviço WSTAFST2.
Essa função é chamada pelo serviço TAF_CFGJOB via IPGo, está implementação
é utilizada exclusivamente nos serviços REST do TAF.

@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap
@cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@aQryParam - Parâmetros de entrada do método GET.

@author Evandro dos Santos O. Teixeira
@since 30/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFWST2GET(cUId,cChave,cValorR,aQryParam)

	Local cTabST2		:= "TAFST2"
	Local cTabXErp		:= "TAFXERP"
	Local cMod			:= ""
	Local cMsgErr		:= ""
	Local cAliasTaf		:= ""
	Local cAliasSt2		:= getNextAlias()
	Local cAliasTrb		:= getNextAlias()
	Local cAliasXErp	:= getNextAlias()
	Local cXmlResponse	:= ""
	Local cFilTAF		:= ""
	Local cUUIDFil		:= "tafJobID"
	Local cChaveFil		:= "keyTafJob"
	Local cIdEntidade	:= ""
	Local cFilBkp 		:= ""
	Local cEmpTaf		:= ""
	Local cStatusGov	:= ""
	Local cStsConsultar	:= ""
	Local nX			:= 0
	Local nLastRecNo	:= 0
	Local nMaxRecNo		:= 0
	Local nSizeFile		:= 0
	Local nCodErr		:= 0
	Local nQtdEvt		:= 0
	Local nPosStatus	:= 0
	Local aErros		:= {}
	Local aAuxRegs		:= {}
	Local aErrosXErp	:= {}
	Local aResponse		:= {}
	Local aErrosRET		:= {}
	Local aEmpresas		:= {}
	Local aRetorno		:= Array(4)
	Local aAreaSM0		:= Array(4)
	Local lVirgula		:= .F.
	Local lLastReg		:= .F.
	Local lValido		:= .F.
	Local lOk			:= .T.
	Local lErpOwner		:= .F.
	Local lFilTran		:= .F.
	Local lCosultTrans	:= SuperGetMv('MV_TAFWSCT',.F.,.F.) // Habilita consulta a regitros Transmitidos (Status Igual a 2), por default somente é consultado os inconsitentes
	Local lPredeces		:= .F.
	Local lComplem		:= .F.
	Local lOpenV2H		:= .T.
	Local cXmlRetTSS	:= ""

	Local ticketCode		:= aQryParam[1]
	Local registryKey		:= aQryParam[2]
	Local startRecNo 		:= aQryParam[3]
	Local searchMode		:= aQryParam[4]
	Local sourceBranch		:= aQryParam[5]
	Local queryElements		:= aQryParam[6]
	Local lotQuantity		:= aQryParam[7]
	Local returnRetResponse	:= aQryParam[8]
	Local lEnableQryElements:= .T.
	Local lRetResponse		:= returnRetResponse

	Do Case
		Case ValType(startRecNo) == "U"
			nCodErr := 701
			cMsgErr := STR0038 //"É obrigatório o envio do parâmetro startRecNo "
			lOk := .F.
		Case Empty(AllTrim(ticketCode)) .And. Empty(AllTrim(registryKey))
			nCodErr := 701
			cMsgErr := STR0006 //"É obrigatório o envio do parâmetro ticketCode ou registryKey"
			lOk := .F.
		Case ValType(searchMode) != "U"
			If !Empty(searchMode) .Or. searchMode == 0
				If searchMode != 1 .And. searchMode != 2
					nCodErr := 703
					cMsgErr := STR0009 //"O parâmetro searchMode deve ser preenchido com 1 ou 2."
					lOk := .F.
				Else
					lLastReg := searchMode == 1 .Or. searchMode == 2
					lValido  := searchMode == 2
				EndIf
			EndIf
	EndCase

	If ValType(queryElements) == "N"
		lEnableQryElements := IIf(queryElements == 0,.F.,.T.)
	EndIf

	If ValType(lotQuantity) == "N"
		MAXGET_EVENTOS := lotQuantity
	EndIf

	//Esse Trecho é executado somente para garantir que os campos TAFPRIORIT e TAFSTQUEUE
	//existem, quando o Release 12.1.7 não for mais suportado essa validação pode ser retirada.
	If lOk
		If TAFTabInteg(cTabST2,cAliasST2,@aErros)
			If TAFTabInteg(cTabXErp,cAliasXErp,@aErros)
				lErpOwner	:= (cAliasSt2)->( FieldPos("TAFOWNER") ) > 0
				lPredeces	:= (cAliasST2)->( FieldPos("TAFREGPRED") ) > 0
				lFilTran	:= (cAliasSt2)->( FieldPos("TAFFILTRAN") ) > 0
				lComplem	:= (cAliasSt2)->( FieldPos("TAFCOMP") ) > 0
				(cAliasSt2)->(dbCloseArea())
			Else
				nCodErr := 702
				cMsgErr := STR0008 //"Erro na Criacao/Abertura da tabela TAFXERP."
				lOk := .F.
			EndIf
		Else
			nCodErr := 702
			cMsgErr := STR0007 ///"Erro na Criacao/Abertura da tabela TAFST2."
			lOk := .F.
		EndIf
	EndIf

	If lOk

		aErrosXErp	:= TAFCodErr()

		nMaxRecNo := TAFLastRcN(ticketCode,registryKey,lValido,startRecNo,sourceBranch)
		cMod := xSelMod(ticketCode,registryKey)

		setResponse(aResponse,'{',@nSizeFile)

		If cMod == "key"
			setResponse(aResponse,' "type" : "registryKey"'			,@nSizeFile)
			setResponse(aResponse,',"code" : "' + registryKey + '"'	,@nSizeFile)
		Else
			setResponse(aResponse,' "type" : "ticketCode"'				,@nSizeFile)
			setResponse(aResponse,',"code" : "' + ticketCode 	+ '"'	,@nSizeFile)
		EndIf

		setResponse(aResponse,',"items" : [',@nSizeFile)

		If nMaxRecNo > 0 .And. consultaRegs(ticketCode,registryKey,@cAliasTrb,lLastReg,lValido,startRecNo,sourceBranch,lErpOwner,lPredeces,lFilTran, lComplem)

			cFilBkp  := cFilAnt 
			aAreaSM0 := SM0->(GetArea())
			
			While (cAliasTrb)->(!Eof())

				If nSizeFile <= MAXSIZE_FILE .And. nQtdEvt < MAXGET_EVENTOS
					aAuxRegs := Array(N_TAM_RESPONSE)
					//ConOut("Contador Thread " + AllTrim(Str(ThreadID())) + " : " + AllTrim(Str(nQtdEvt)))

					aAuxRegs[N_TAFKEY] 			:= (cAliasTrb)->TAFKEY
					aAuxRegs[N_TAFTICKET] 		:= (cAliasTrb)->TAFTICKET
					aAuxRegs[N_ST2_OK] 			:= .T.
					aAuxRegs[N_ST2_STATUS] 		:= (cAliasTrb)->ST2_STATUS

					If !Empty((cAliasTrb)->RECXERP)
						aAuxRegs[N_XERP_STATUS] 	:= (cAliasTrb)->XERP_STATUS

						If aAuxRegs[N_XERP_STATUS] $ "123"
							aAuxRegs[N_XERP_OK] 		:= .T.
							If seekTAF((cAliasTrb)->ALIAS_TAF,@cAliasTaf,(cAliasTrb)->RECNO_TAF,sourceBranch,(cAliasTrb)->FILIALERP,cUUIDFil,cChaveFil)
								If !Empty((cAliasTrb)->XERP_CODERR) .AND. (cAliasTrb)->XERP_CODERR == "000026"
									aAuxRegs[N_TAF_STATUS] 		:= ""
									aAuxRegs[N_TAF_PROTOCOL]	:= ""
								Else
									if TAFColumnPos( cAliasTaf + "_STATUS" )
										aAuxRegs[N_TAF_STATUS] 	:= (cAliasTaf)->&(cAliasTaf+"_STATUS")
									else
										aAuxRegs[N_TAF_STATUS] 	:= "0"
									endif

									if TAFColumnPos( cAliasTaf + "_ATIVO")
										aAuxRegs[N_TAF_ACTIVE] 	:= IIf((cAliasTaf)->&(cAliasTaf+"_ATIVO") == '2',.F.,.T.)
									else
										aAuxRegs[N_TAF_ACTIVE] 	:= .T.
									endif

									if TAFColumnPos( cAliasTaf + "_PROTUL")
										aAuxRegs[N_TAF_PROTOCOL]	:= (cAliasTaf)->&(cAliasTaf+"_PROTUL")
									else
										aAuxRegs[N_TAF_PROTOCOL]	:= ""
									endif

									If cAliasTaf == 'CMJ'
										aAuxRegs[N_TAF_DEL_TYPE]	:= "1"
									EndIf
								EndIf
								
							Else

								aAuxRegs[N_TAF_STATUS] 		:= ""
								aAuxRegs[N_TAF_PROTOCOL]	:= ""
								cMsgErr := "Registro nao localizado, verifique se na requisicao esta sendo enviado o paramentro sourceBranch " 
								cMsgErr += "e se a chave prepareIn esta configurada corretamente. TafKey: " + (cAliasTrb)->TAFKEY  + " - TafTicket: " + (cAliasTrb)->TAFTICKET
								TafConOut(cMsgErr)

								If (cAliasTaf == 'CMJ' .Or. cAliasTaf == 'V7J') .And. (cAliasTrb)->RECNO_TAF == 0
									aAuxRegs[N_TAF_DEL_TYPE]	:= "0"
								EndIf
							EndIf 
						Else
							aAuxRegs[N_XERP_OK] 		:= .F.
							aAuxRegs[N_XERP_COD_ERR]	:= (cAliasTrb)->XERP_CODERR
							aAuxRegs[N_XERP_TIK_ERR]	:= getErrXERP((cAliasTrb)->XERP_CODERR,aErrosXErp)

							(cAliasXErp)->(dbGoTo((cAliasTrb)->RECXERP))
							aAuxRegs[N_XERP_DET_ERR] := retiraQuebra((cAliasXErp)->TAFERR)
							aAuxRegs[N_ST2_PRIORIT] := (cAliasTrb)->PRIORITY
							aAuxRegs[N_ST2_QUEUE] := (cAliasTrb)->STQUEUE

							If lErpOwner
								aAuxRegs[N_ST2_OWNER] := (cAliasTrb)->TAFOWNER
							EndIf

							If lPredeces
								aAuxRegs[N_ST2_PREDECES]	:= (cAliasTrb)->TAFREGPRED
							EndIf

							If lFilTran
								aAuxRegs[N_ST2_FILTRAN] := (cAliasTrb)->TAFFILTRAN
							EndIf

							If lComplem
								aAuxRegs[N_ST2_COMP] := (cAliasTrb)->TAFCOMP
							EndIf

							aAuxRegs[N_TAF_PROTOCOL]	:= ""

						EndIf
					Else
						aAuxRegs[N_XERP_OK] 		:= .F.
					EndIf

					IIf (lVirgula,setResponse(aResponse,',',@nSizeFile),lVirgula := .T.)

					setItensResponse(aResponse,aClone(aAuxRegs),cMod,ticketCode,registryKey,@nSizeFile,.F.)
					nLastRecNo := (cAliasTrb)->RECST2

					//Posição com erros retornados no RET/TSS
					setResponse(aResponse,',"streamingErrors" : ['	,@nSizeFile)

					If (lRetResponse .OR. lEnableQryElements) .And. !Empty((cAliasTrb)->RECXERP)
													
						If lCosultTrans
							cStsConsultar := "2|3"
						Else
							cStsConsultar := "3"
						EndIf

						If lRetResponse
							cStsConsultar += "|4"
						EndIf

						If aAuxRegs[N_XERP_STATUS] $ "123" .And. AllTrim(aAuxRegs[N_TAF_STATUS]) $ cStsConsultar

							If Empty(cFilTAF) //Só preciso fazer 1 vez por lote

								If Empty(sourceBranch)
									//Tratamento para legado, hoje o sourceBranch é obrigatorio.
									sourceBranch := AllTrim((cAliasTrb)->FILIALERP)
								EndIf 

								If VarGetA(cUUIDFil,cChaveFil,@aEmpresas)
									WsSearchDePara(sourceBranch,aEmpresas,@cEmpTaf,.T.,@cFilTAF)
									If !Empty(cFilTAF) 
										SM0->(MsSeek(cEmpTaf+AllTrim(cFilTAF)))
										cFilAnt := SM0->M0_CODFIL
									EndIf 
								Else
									TafConOut("Nao foi possivel localizar a Filial do TAF para o retorno das inconssistencias do RET. ")
								Endif
							EndIf

							//Retorna erros do RET/TSS						
							aErrosRET := GetErroTSS(( cAliasTrb )->TAFTPREG,( cAliasTrb )->RECNO_TAF,cFilTAF,@cStatusGov,lCosultTrans,@cIdEntidade,(cAliasTrb)->ALIAS_TAF,lOpenV2H,lRetResponse,@cXmlRetTSS)
							cXmlResponse := cXmlRetTSS
							If Len(aErrosRET) >= 1 .and. ValType(aErrosRET[1]) == "A" 
								For nX := 1 To Len(aErrosRET)
									If nX > 1
										setResponse(aResponse,','						,@nSizeFile)
									EndIf
									setResponse(aResponse,'{"streamingErrorCode" : "' + aErrosRET[nX][1] + '"' ,@nSizeFile)
									setResponse(aResponse,',"streamingErrorDetail" : "' + aErrosRET[nX][2] + '"}' ,@nSizeFile)
								Next

								If lCosultTrans .And. cStatusGov == "6"

									//Se o Registro já estiver OK atualizo o status em tempo de execução.
									//Necessario que o parametro MV_TAFWSCT esteja habilitado.
									nPosStatus := aScan(aResponse,{|x|"statusCode" $ AllTrim(x)})
									If nPosStatus > 0
										aAuxRegs[N_TAF_STATUS] 	:= "4"
										aResponse[nPosStatus] 	:= ',"statusCode" : "4"'
										aResponse[nPosStatus+1] := ',"statusDescription" : "' + getTafDStatus("4") + '"'
										aResponse[nPosStatus+1] := ',"receiptNumber" : ""'
									EndIf

								EndIf
							EndIf
 
						EndIf
					EndIf

					setResponse(aResponse,']',@nSizeFile)
							
					If lRetResponse .and. Len(aErrosRET) > 0 .and. ValType(aErrosRET[1]) != "A" 
						aXmlRet := aClone(aErrosRET)

						If Len(aXmlRet) >= 1 .and. !Empty(aXmlRet[12])
							cXmlResponse := Encode64(aXmlRet[12])
						EndIf

					Else
						cXmlResponse := Encode64(cXmlResponse)

					EndIf

					setResponse(aResponse,',"xmlRetResponse" : "'+ cXmlResponse +'"'	,@nSizeFile)

					setResponse(aResponse,'}',@nSizeFile)

					//Flag de Segurança, no BD Progress não consigo utilizar o SELECT TOP
					//por esse motivo tenho que abortar o laço quando é requisitado somente
					//o ultimo registro. (quando é enviado o parâmetro searchMode)
					If lLastReg .And. !Empty(registryKey)
						Exit
					EndIf
				Else
					Exit
				EndIf

				nQtdEvt++
				(cAliasTrb)->(dbSkip())
				aSize(aAuxRegs,0)
			EndDo

			cFilAnt := cFilBkp 
			RestArea(aAreaSM0)

			nLastRecNo := IIf (nLastRecNo == 0,nLastRecNo := nMaxRecNo,nLastRecNo)

		Else

			cMsgErr := STR0005 //"Chave de busca não encontrada na tabela compartilhada TAFST2. "

			aAuxRegs 					:= Array(N_TAM_RESPONSE)
			aAuxRegs[N_TAFKEY] 			:= ticketCode
			aAuxRegs[N_TAFTICKET] 		:= registryKey
			aAuxRegs[N_ST2_OK] 			:= .F.
			aAuxRegs[N_ST2_STATUS] 		:= .F.
			aAuxRegs[N_XERP_TIK_ERR] 	:= ''
			aAuxRegs[N_XERP_DET_ERR] 	:= cMsgErr

			setItensResponse(aResponse,aClone(aAuxRegs),cMod,ticketCode,registryKey,@nSizeFile)
			aSize(aAuxRegs,0)

		EndIf

		setResponse(aResponse,']'												,@nSizeFile)
		setResponse(aResponse,',"lastRecNo" : ' + AllTrim(Str(nLastRecNo))		,@nSizeFile)
		setResponse(aResponse,',"maxRecNo" : ' + AllTrim(Str(nMaxRecNo))		,@nSizeFile)
		setResponse(aResponse,'}'												,@nSizeFile)
	EndIf

	If Select(cAliasTrb) > 0
		(cAliasTrb)->(dbCloseArea())
	EndIf
	If Select(cAliasXErp) > 0
		(cAliasXErp)->(dbCloseArea())
	EndIf

	aRetorno[1] := lOk
	aRetorno[2] := aResponse
	aRetorno[3] := nCodErr
	aRetorno[4] := cMsgErr

	TAFFinishWS(cChave,cUId,cValorR,aRetorno ,3)

Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} retiraQuebra
Troca a quebra de linha CRLF para \n

@param cString - String a ser normalizada

@author Evandro dos Santos Oliveira
@since 14/06/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function retiraQuebra(cString)

	Local cDescRet := ""

	cDescRet := StrTran(cString,Chr(13)+Chr(10),"\n")
Return (cDescRet)

//----------------------------------------------------------------------------
/*/{Protheus.doc} GetErroTSS
Função para buscar erros no retorno do RET, consulta no TSS

@param cEvento	 	- Evento para consulta
@param nRecno		- RecNo do Registro a ser posicionado
@param cFilTAF		- Codigo da Filial do TAF
@param cStatus		- Status Retorno Governo (referencia)
@param cAliasTab	- Tabela referente ao evento 
@param lOpenV2H		- Determina se a tabela V2H deve ser aberta (@referencia)

@author Leonardo Kichitaro
@since 05/01/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Function GetErroTSS(cEvento,nRecno,cFilTAF,cStatusGov,lCosultTrans,cIdEntidade,cAliasTab,lOpenV2H,lRetResponse,cXMLTot)

Local nX
Local aRetErros
Local cErrorXML
Local cWarningXML
Local cXmlErros
Local aRetGov
Local lFound

Private oXmlErros

Default cFilTAF 	 := ""
Default cStatusGov 	 := ""
Default lCosultTrans := SuperGetMv('MV_TAFWSCT',.F.,.F.) //Habilita consulta a regitros Transmitidos (Status Igual a 2), por default somente é consultado os inconsitentes
Default lOpenV2H 	 := .T.
Default lRetResponse := .F.
Default cXMLTot 	 := ""

nX				:= 0
aRetErros		:= {}
aRetGov			:= {}
cXmlErros		:= ""
cErrorXML		:= ""
cWarningXML		:= ""
cChaveV2H		:= ""
oXmlErros		:= Nil
lFound			:= .F. 
cIdEntidade     := ""

If TAFAlsInDic("V2H")

	If lOpenV2H
		dbSelectArea("V2H")
		V2H->(dbSetOrder(2))
		lOpenV2H := .F. 
	EndIf 

	(cAliasTab)->(dbGoTo(nRecno))
	If !Eof()

		cChaveV2H := (cAliasTab)->&(cAliasTab+"_FILIAL") + StrTran(AllTrim(cEvento),"-","") + (cAliasTab)->&(cAliasTab+"_ID")+(cAliasTab)->&(cAliasTab+"_VERSAO")
		If MsSeek(cChaveV2H)

			While RTrim(cChaveV2H) == RTrim(V2H->V2H_FILIAL + V2H->V2H_IDCHVE)
				aAdd(aRetErros,{PADL(AllTrim(V2H->V2H_CODERR),3,'0'),V2H->V2H_DCERRO})
				lFound := .T. 
				V2H->(dbSkip())
			EndDo
		EndIf 
	EndIf 
EndIf 

If lFound 

	aRetGov := GetXmlTSS(cEvento,nRecno,cFilTAF,lCosultTrans,@cIdEntidade,lRetResponse)
	cXMLTot := aRetGov[12]
Else 

	aRetGov := GetXmlTSS(cEvento,nRecno,cFilTAF,lCosultTrans,@cIdEntidade,lRetResponse)
	If len(aRetGov) > 0 .and. !Empty(aRetGov[11])
		cXmlErros   := aRetGov[11]
		cStatusGov	:= aRetGov[09]

		If cStatusGov != "6" .And. !Empty(cXmlErros)
			// --> Faz o "parse" do XML para pegar somente o bloco do eSocial, pois a tag possui o retorno do governo completo
			oXmlErros := XmlParser( encodeUtf8( cXmlErros ),"", @cErrorXML, @cWarningXML )

			If Empty(cErrorXML)
				If Type("oXmlErros:_OCORRENCIAS:_OCORRENCIA") <> "U" .And. Type("oXmlErros:_OCORRENCIAS:_OCORRENCIA") == "A"
					For nX := 1 To Len(oXmlErros:_OCORRENCIAS:_OCORRENCIA)
						aAdd(aRetErros,{DeCodeUTF8(oXmlErros:_OCORRENCIAS:_OCORRENCIA[nX]:_CODIGO:Text),DeCodeUTF8(oXmlErros:_OCORRENCIAS:_OCORRENCIA[nX]:_DESCRICAO:Text)})
					Next
				ElseIf Type("oXmlErros:_OCORRENCIAS:_OCORRENCIA") <> "U" .And. Type("oXmlErros:_OCORRENCIAS:_OCORRENCIA") == "O"
					aAdd(aRetErros,{DecodeUTF8(oXmlErros:_OCORRENCIAS:_OCORRENCIA:_CODIGO:Text),DecodeUTF8(oXmlErros:_OCORRENCIAS:_OCORRENCIA:_DESCRICAO:Text)})
				EndIf			

			EndIf
		Else
			aRetErros := aClone(aRetGov)		
		EndIf
	Else
		aRetErros := aClone(aRetGov)
	EndIf

	FreeObj(oXmlErros)
	oXmlErros := Nil
EndIf 

Return aRetErros

//----------------------------------------------------------------------------
/*/{Protheus.doc} POST
O método POST segue o conceito do próprio método em qualquer outro tipo de
serviço REST, devendo seu conteúdo ser enviado no corpo da mensagem (body)
no formato json.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
WSMETHOD POST WSREST WSTAFST2

	Local lPost
	Local lRet
	Local lRet2
	Local cBody
	Local cChave
	Local cFuncIPC
	Local cFuncREST
	Local cUId
	Local cValorR
	Local cCodFilERP
	Local cCorErr
	Local cDescErr
	Local oSelf
	Local nI

	Local aRetorno


	cFuncREST 	:= "TAFWST2POST"
	cChave		:= "POST"
	cUId 		:= FWUUID(AllTrim(Str(Randomize(1,999999))))
	cValorR 	:= 'respPOST'
	cCorErr 	:= ''
	cDescErr 	:= ''

	lRet := VarSetUID(cUId, .T.)
	lPost		:=	.T.
	cBody		:=	""
  	aRetorno	:= {}
  	nI 			:= 0

  	oSelf := ::Self
	cBody := ::GetContent()

	If Empty(cBody)
		SetRestFault(704,STR0010) //"Arquivo vazio. "
		lPost := .F.
	Else
		cCodFilERP := WSGetPostFil(cBody)
		If Empty(cCodFilERP)
			::Self:SetResponse(getErrResponse("811",STR0047 + "sourceBranch (TAFFIL) " + STR0048)) //"Não foi possível identificar a filial # " no corpo da mensagem."
		Else
			If WSST2ValFil(cCodFilERP,@cFuncIPC,@cCorErr,@cDescErr)

				oSelf:SetContentType("application/json")
				TAFCALLIPC(cFuncIPC,cFuncREST,cUId,cChave,cValorR,,cBody,cCodFilERP)
			Else
				::Self:SetResponse(getErrResponse("803",STR0024 + "sourceBranch (TAFFIL) " + STR0025)) //"O valor do campo "#" não está cadastro no complemento de empresas."
			EndIf
		EndIf
	EndIf

	lRet2 := VarGetAD(cUId,cValorR,@aRetorno)

	If !Empty(aRetorno)
		If aRetorno[1]
			For nI := 1 To Len(aRetorno[2])
				oSelf:SetResponse(aRetorno[2][nI])
			Next nI
		Else
			SetRestFault(aRetorno[3],aRetorno[4])
			lPost := .F.
		EndIf
	EndIf

	aSize(aRetorno,0)
	VarCleanX(cUId)

Return lPost

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFWST2POST
Função para a execução do POST do serviço WSTAFST2.
Essa função é chamada pelo serviço TAF_CFGJOB via IPGo, está implementação
é utilizada exclusivamente nos serviços REST do TAF.

@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap.
@cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@aQryParam - Parâmetros de entrada do método GET.
@cBody - Mensagem enviada no Body do POST
@cCodFilERP - Filial do ERP

@author Evandro dos Santos O. Teixeira
@since 30/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFWST2POST(cUId,cChave,cValorR,aQryParam,cBody,cCodFilERP)

	Local cAliasST2
	Local cTabST2
	Local cMsgErr
	Local aErros
	Local nCodErr
	Local nRegsInc
	Local oJson
	Local aResponse
	Local aRetorno
	Local lPost
	Local lRet
	Local lRet2

	Default cBody		:=	""

	oJson		:=	Nil
	lPost		:=	.T.
	lRet 		:= .F.
	lRet2 		:= .F.

	cAliasST2	:= getNextAlias()
	cTabST2	:= 'TAFST2'
	cMsgErr	:= ""
	aErros		:= {}
	aRetorno	:= Array(4)
	aResponse 	:= {}
	nRegsInc	:= 0
	nCodErr	:= 0

	If FWJsonDeserialize(cBody,@oJson)
		If TAFTabInteg(cTabST2,cAliasST2,@aErros)
			tafPutSt2(oJson,cAliasST2,@nRegsInc,@aResponse,cCodFilERP)
		Else
			nCodErr := 702
			cMsgErr := STR0007 //"Erro na Criacao/Abertura da tabela TAFST2."
			TafConOut(cMsgErr)
			lPost := .F.
		EndIf
	Else
		nCodErr := 705
		cMsgErr := STR0049 //"Erro ao realizar parser da mensagem"
		TafConOut(cMsgErr)
		lPost := .F.
	EndIf

	aRetorno[1] := lPost
	aRetorno[2] := aResponse
	aRetorno[3] := nCodErr
	aRetorno[4] := cMsgErr
	lRet2 := VarSetAD(cUId,cValorR,aRetorno)

	If Select(cAliasST2) > 0
		(cAliasST2)->(dbCloseArea())
	EndIf

	TAFFinishWS(cChave,cUId,cValorR,aRetorno ,3)

	FreeObj(oJson)

Return lPost

//----------------------------------------------------------------------------
/*/{Protheus.doc} DELETE
O método DELETE permite excluir toda a cadeia de integração de um TAFTICKET;
Um ticket submetido a exclusão tem seus TAFKEYS avaliados, rastreados e
excluídos, desde a sua inclusão na TAFST2 e TAFXERP até o cadastro no TAF
caso já tenha ocorrido o Processamento.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
WSMETHOD DELETE QUERYPARAM sourceBranch WSREST WSTAFST2

	Local lRet
	Local lOk
	Local cBody
	Local cChave
	Local cFuncIPC
	Local cFuncREST
	Local cUId
	Local cValorR
	Local oSelf
	Local nI
	Local aRetorno
	Local aTicket

	Private oJson

	cFuncIPC	:= ""
	cFuncREST 	:= "TAFWST2DEL"
	cChave		:= "DELETE"
	cUId 		:= "HTTPGET_" + AllTrim(Str(Randomize(1,999)))
	cValorR 	:= 'respDEL'
	cCorErr 	:= ''

	lRet 		:= VarSetUID(cUId, .T.)
	lOk			:= .T.
	cBody		:= ""
  	aRetorno	:= {}
  	aTicket		:= {}
  	nI 			:= 0

  	oSelf := ::Self
	cBody := ::GetContent()

	::sourceBranch := IIf (ValType(::sourceBranch) == "U","",::sourceBranch)  

	oJson := JsonObject():New()
	FwJsonDeserialize(cBody, @oJson)

	If Type("oJson:deleteTicket") == "U"
		SetRestFault(704,STR0013) //"Campo deleteTicket não declarado na raiz do arquivo."
		lOk := .F.
	Else
		For nI := 1 To Len(oJson:deleteTicket)
			If Type("oJson:deleteTicket[" + AllTrim(Str(nI)) + "]:ticketCode") == "U"
				SetRestFault(704,STR0014 + AllTrim(Str(nI)) + STR0015) //"Campo ticketCode não informado ou incorreto na posição " # " do arquivo."
				lOk := .F.
				Exit
			Else
				aAdd(aTicket,oJson:deleteTicket[nI]:ticketCode)
			EndIf
		Next nI
	EndIf

	If lOK

		If WSST2ValFil(::sourceBranch,@cFuncIPC)
			TAFCALLIPC(cFuncIPC,cFuncREST,cUId,cChave,cValorR,aTicket,cBody)
		Else
			::SetResponse(getErrResponse("803",STR0024 + "sourceBranch (TAFFIL) " + STR0025)) //"O valor do campo "#" não está cadastro no complemento de empresas."
		EndIf

		lRet := VarGetAD(cUId,cValorR,@aRetorno)

		If ValType(aRetorno) != "U" .And. Len(aRetorno) > 0
			::SetResponse('{')
			If aRetorno[1]
				::SetResponse('"success" : true')
			Else
				::SetResponse('"success" : false')
			EndIf
			::SetResponse('}')
		Else
			::SetResponse('"success" : false')
			lOk := .F.
		EndIf
	EndIf

	aSize(aRetorno,0)
	VarCleanX(cUId)

Return (lOk)

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFWST2DEL
Função para a execução do DELETE do serviço WSTAFST2.
Essa função é chamada pelo serviço TAF_CFGJOB via IPGo, está implementação
é utilizada exclusivamente nos serviços REST do TAF.

@cUId	- Identificador da sessão de Variáveis Globais.
@cChave - Identificador da chave (tabela X) HashMap.
@cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@aTicket - Tickets para exclusão
@cBody - Mensagem enviada no Body do POST

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFWST2DEL(cUId,cChave,cValorR,aTicket,cBody)

	Local lRet
	lRet := .T.

	TAFDelTicket(aTicket,.T.)
	TAFFinishWS(cChave,cUId,cValorR,{.T.} ,3)

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} setItensResponse
Função responsavel por criar os itens do response de acordo com o status
dos mesmos nas tabelas TAFST2, TAFXERP e Status do TAF.

@param aResponse	- Array para atribuição do Json de Response
@param aAuxRegs	- Array com as informações para o Response
@param cMod		- Determina se chave do GET é por TafKey, TafTiket ou Ambos
@param cTicket		- TafTicket enviado na requisição
@param cKey		- TafKey enviado na requisição
@param nSizeFile	- Variavel para controle de paginação

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//----------------------------------------------------------------------------
Static Function setItensResponse(aResponse,aAuxRegs,cMod,cTicket,cKey,nSizeFile,lFechaTag)

	Local nX
	Local nJ

	Default	lFechaTag	:= .T.

	nX	:= 0
	nJ	:= 0

	setResponse(aResponse,'{',@nSizeFile)

	If aAuxRegs[N_ST2_OK] .And. aAuxRegs[N_XERP_OK]

		setResponse(aResponse,' "success" : true '					,@nSizeFile)
		setResponse(aResponse,',"proccessed" : true '					,@nSizeFile)
		setResponse(aResponse,',"description" : "' + STR0016 + '"'	,@nSizeFile) //Registro Processado.

		If cMod == "key"
			setResponse(aResponse,',"ticketCode" : "'  	+ AllTrim(aAuxRegs[N_TAFTICKET]) 	+ '"'	,@nSizeFile)
		Else
			setResponse(aResponse,',"registryKey" : "' 	+ AllTrim(aAuxRegs[N_TAFKEY]) 	+ '"'		,@nSizeFile)
		EndIf

		setResponse(aResponse,',"statusCode" : "' 			+ aAuxRegs[N_TAF_STATUS] + '"'					,@nSizeFile)
		setResponse(aResponse,',"statusDescription" : "'	+ getTafDStatus(aAuxRegs[N_TAF_STATUS]) + '"'	,@nSizeFile)
		setResponse(aResponse,',"active" : '				+ IIf(aAuxRegs[N_TAF_ACTIVE],"true","false")	,@nSizeFile)
		setResponse(aResponse,',"receiptNumber" : "'		+ aAuxRegs[N_TAF_PROTOCOL] + '"'				,@nSizeFile)

		If !Empty(aAuxRegs[N_TAF_DEL_TYPE])
			setResponse(aResponse,',"deleteType" : "'		+ aAuxRegs[N_TAF_DEL_TYPE] + '"'				,@nSizeFile)
		EndIf


	ElseIf aAuxRegs[N_ST2_OK]

		setResponse(aResponse,' "success" : true '		,@nSizeFile)
		setResponse(aResponse,',"proccessed" : false '	,@nSizeFile)

		If Empty(aAuxRegs[N_XERP_STATUS])

			If aAuxRegs[N_ST2_STATUS] == "1" .Or. aAuxRegs[N_ST2_STATUS] == "2"
				setResponse(aResponse,',"description" : "' + STR0017 + '" ',@nSizeFile) //Aguardando Processamento.
			Else
				setResponse(aResponse,',"description" : "' + STR0020 + '" ',@nSizeFile) //Registro não encontrado na tabela TAFXERP.
			EndIf

		Else

			If aAuxRegs[N_XERP_STATUS] == "9"
				setResponse(aResponse,',"description" : "' + STR0019 + '" ',@nSizeFile) //Registro Inconsistente.
			Else
				setResponse(aResponse,',"description" : " " ',@nSizeFile)
			EndIf

		EndIf

		If cMod == "key"
			setResponse(aResponse,',"ticketCode" : "'  	+ AllTrim(aAuxRegs[N_TAFTICKET]) 	+ '"',@nSizeFile)
		Else
			setResponse(aResponse,',"registryKey" : "' 	+ AllTrim(aAuxRegs[N_TAFKEY]) 	+ '"',@nSizeFile)
		EndIf

		setResponse(aResponse,',"errorCode" : "' 			+ AllTrim(aAuxRegs[N_XERP_COD_ERR]) + '"',@nSizeFile)
		setResponse(aResponse,',"errorDescription" : "' 	+ AllTrim(aAuxRegs[N_XERP_TIK_ERR]) + '"',@nSizeFile)
		setResponse(aResponse,',"errorDetail" : "' 		+ AllTrim(aAuxRegs[N_XERP_DET_ERR]) + '"',@nSizeFile)

		if !empty(aResponse[N_ST2_PRIORIT])
			setResponse(aResponse,',"registryPriority" : "' 	+ AllTrim(aAuxRegs[N_ST2_PRIORIT]) + '"',@nSizeFile)
		endif

		if !empty(aResponse[N_ST2_QUEUE])
			//Tratamento para o RM recusar de fato os registros que apesar de estarem marcados como FILA foram rejeitados
			//JBS - Afastamentos.
			if aAuxRegs[N_XERP_STATUS] == "9" .OR. aAuxRegs[N_XERP_STATUS] == "7"
				setResponse(aResponse,',"integrationQueue" : ""',@nSizeFile)
			else
				setResponse(aResponse,',"integrationQueue" : "' 	+ AllTrim(aAuxRegs[N_ST2_QUEUE]) + '"',@nSizeFile)
			endif 
		endif

		if !empty(aResponse[N_ST2_OWNER])
			setResponse(aResponse,',"erpOwner" : "' 	+ AllTrim(aAuxRegs[N_ST2_OWNER]) + '"',@nSizeFile)
		endif

		if !empty(aResponse[N_ST2_PREDECES])
			setResponse(aResponse,',"registryPredecessor" : "' 	+ AllTrim(aAuxRegs[N_ST2_PREDECES]) + '"',@nSizeFile)
		endif

		if !empty(aResponse[N_ST2_FILTRAN])
			setResponse(aResponse,',"transferBranch" : "' 	+ AllTrim(aAuxRegs[N_ST2_FILTRAN]) + '"',@nSizeFile)
		endif

		if !empty(aResponse[N_ST2_COMP])
			setResponse(aResponse,',"complement" : "' 	+ AllTrim(aAuxRegs[N_ST2_COMP]) + '"',@nSizeFile)
		endif

	Else
		setResponse(aResponse,' "success" : false'													,@nSizeFile)
		setResponse(aResponse,',"proccessed" : false '												,@nSizeFile)
		setResponse(aResponse,',"description" : "' + STR0039 + '"'									,@nSizeFile) //"Registro não encontrado na tabela TAFST2."

		If cMod == "key"
			setResponse(aResponse,',"ticketCode" : "'  	+ AllTrim(aAuxRegs[N_TAFTICKET]) + '"'	,@nSizeFile)
		Else
			setResponse(aResponse,',"registryKey" : "' 	+ AllTrim(aAuxRegs[N_TAFKEY]) + '"'		,@nSizeFile)
		EndIf

	EndIf
	if lFechaTag
		setResponse(aResponse,'}',@nSizeFile)
	endif

Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} setResponse
Realiza a atribuição do Response e soma o tamanho do conteúdo do atributo
para controle da paginação prevenindo assim erros de estouro de memória.

@param aResponse 	- Array para atribuição do Json de Response
@param cContent	- Conteudo do Response
@param nSizeFile	- Variavel para soma do conteudo (bytes)

@return Nil

@author Evandro dos Santos O. Teixeira
@since 09/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function setResponse(aResponse,cContent,nSizeFile)
	nSizeFile += Len(cContent)
	aAdd(aResponse,cContent)
Return Nil

//----------------------------------------------------------------------------
/*/{Protheus.doc} tafPutSt2
Cria o Response para o método POST e realiza a chamada para a função responsavel
por gravar os dados no TAF.

@param oJson 		- Objeto com os dados do POST no formato Json.
@param cAliasST2	- Alias da tabela compartilhada TAFST2
@param nRegsInc		- Contador para o numero de registros incluidos.
@param oClass 		- Objeto da Classe (::Self)
@param cCodFilERP	- Codigo da Filial ERP

@return lPost		- Indica se o Post pode ser confirmado.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Function tafPutSt2(oJson,cAliasST2,nRegsInc,aResponse,cCodFilERP)

	Local lPost
	Local nZ
	Local nE
	Local aError
	Local cCodGrupo

	lPost 	:= .T.
	nZ 		:= 0
	nE 		:= 0
	aError	:= {}

	Private aRotinas	:= TafRotinas(,,.T.)
	aAdd(aResponse,'{"ticketCode" : "'  + oJson:ticketCode + '"')
	aAdd(aResponse,',"registryKey" : [')

	dbSelectArea(cAliasST2)
	For nZ := 1 To Len(oJson:lote)

		If nZ > 1
			aAdd(aResponse,',')
		EndIf

		aAdd(aResponse,'{"key" : "' + oJson:lote[nZ]:registryKey + '"')
		If st2PutField(oJson:ticketCode,oJson:lote[nZ],@aError,cAliasST2,cCodFilERP,@cCodGrupo) //st2PutField(oJson:ticketCode,oJson:lote[nZ],@aError,cAliasST2)
			aAdd(aResponse,',"success" : true')
		Else
			aAdd(aResponse,',"success" : false')
			aAdd(aResponse,',"error" : [')

			For nE := 1 To Len(aError)
				If nE > 1
					aAdd(aResponse,',')
				EndIf
				aAdd(aResponse,'{"coderr" : ' +  aError[nE][1] + ', "description" : "' +  aError[nE][2] + '"}')
			Next nE
			aAdd(aResponse,']')
			aSize(aError,0)
			lPost := .F.
		EndIf
		aAdd(aResponse,'}')
	Next nZ

	nRegsInc := nZ - 1
	aAdd(aResponse,']')
	aAdd(aResponse,', "keyAmount" : ' + AllTrim(Str(nRegsInc)) +  ' }')

	aSize(aRotinas,0)

Return lPost

//----------------------------------------------------------------------------
/*/{Protheus.doc} st2PutField
Realiza a validação e grava os registros nos seus respectivos cadastros.

@param cTicket 	- tafTicket enviado na requisição
@param oJsonSt2	- Item do lote no formato Json
@param aError		- Array para a gravação de possiveis erros na estrutura do
					  aquivo. (passagem por referência)
@param cAliasST2 	- Alias da tabela compartilhada TAFST2.
@param cCodFilERP	- Codigo da filial do ERP
@param cCodGrupo	- Codigo do Grupo de Empresas TAF

@return lGrava		- Indica se o registro foi gravado com sucesso.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function  st2PutField(cTicket,oJsonSt2,aError,cAliasST2,cCodFilERP,cCodGrupo)

	Local lReturn
	Local aJsToST
	Local nX
	Local lGrava
	Local xVlrCmp
	Local xVlrTemp
	Local cFuncaoVal
	Local lExistTag
	Local lExistCmp
	Private oJsonItem

	Default aError	:= {}

	lReturn 	:= .F.
	aJsToST 	:= {}
	nX			:= 0
	lGrava		:= .T.
	lExistTag   := .T.
	lExistCmp	:= .T.
	cFuncaoVal	:= ""
	//Necessário para a utilização da função Type
	oJsonItem := oJsonSt2

	//[1]Nome do atributo json (tag)
	//[2]Nome do campo na tabela TAFST2
	//[3]Tipo do campo
	//[4]Informa se o campo/atributo é obrigatório
	//[5]Função de validação do campo


	aJsToST	:=	{	{"sourceBranch"				, 	"TAFFIL"	 	,	"C",	.T.,	"xValidFil"}	,;
						{"messageType"			, 	"TAFCODMSG"		,	"C",	.T.,	"xValTpMes"}	,;
						{"messageSequential"	, 	"TAFSEQ"		,	"C",	.T.,	"",.T.}			,;
						{"registryType"			, 	"TAFTPREG"		,	"C",	.T.,	"xValLayout"}	,;
						{"registryKey"			, 	"TAFKEY"		,	"C",	.T.,	""}				,;
						{"integrationMessage"	,	"TAFMSG"		,	"C",	.T.,	""}				,;
						{"integrationDate"		,	"TAFDATA"		,	"D",	.F.,	""}				,;
						{"integrationTime"		,	"TAFHORA"		,	"C",	.F.,	""}				,;
						{"registryPriority"		,	"TAFPRIORIT"	,	"C",	.F.,	"xValPriority"}	,;
						{"integrationQueue"		,	"TAFSTQUEUE"	,	"C",	.F.,	"xValQueue"}	,;
						{"erpOwner"				,	"TAFOWNER"		,	"C",	.F.,	""}				,;
						{"registryPredecessor"	,	"TAFREGPRED"	,	"C",	.F.,	""}		 		,;
						{"transferBranch"		,	"TAFFILTRAN"	,	"C",	.F.,	""}				,;
						{"complement"			,	"TAFCOMP"		,	"C",	.F.,	""} }

	/*
	Realiza a verificação para descobrir se já existe um TAFKEY deste evento pendente de processamento para as tabelas do TAF.
	*/
	If TafChkKey()

		BEGIN TRANSACTION

			If RecLock( cAliasST2, .T.)
				For nX := 1 To Len(aJsToST)

					xVlrCmp := ''
					lGrava  := .T.
					lExistTag := .T.

					If Type( "oJsonItem:" + aJsToST[ nX , 1 ] ) == "U"
						// 800 - Campo não existe na estrutura do JSON
						If aJsToST[ nX , 4 ]
							aAdd(aError,{"800",STR0021 + aJsToST[nX][2]+ " (" + aJsToST[nX][1] + ") " + STR0022}) //"Campo "#"não relacionado na estrutura do arquivo."
							lGrava := .F.
							//Devo sair do laço por que já na primeira ocorrência deste erro a mensagem fica invalida.
							Exit
						Endif
						lExistTag   := .F.
					Else
						xVlrCmp := &("oJsonItem:" + aJsToST[nX][1])
					Endif

					// 808 - Valida a estrutura da tabela TAFST2 em relação aos campos enviados no JSON
					if lExistTag .And. !( cAliasST2 )->( fieldPos( aJsToST[ nX , 2 ] ) )
						aAdd( aError , { "808" , noAcento( STR0045 + aJsToST[ nX , 2 ] + " (" + aJsToST[nX][1] + ") " + STR0046  ) } ) //"Estrutura da tabela TAFST2 está desatualizada. Campo: # "não existe na estrutura." "
						lGrava := .F.
					endif

					If lGrava
						If aJsToST[nX][4]
							// 801 - Validação de campo obrigatório
							If Empty(AllTrim(xVlrCmp))
								aAdd(aError,{"801",STR0021 + aJsToST[nX][2]+ " (" + aJsToST[nX][1] + ") " + STR0023}) //"O campo "#" é Obrigatório."
								lGrava := .F.
							EndIf
						EndIf
					EndIf

					If lGrava .And. lExistTag
						// Validações/Tramentos especificos dos campos
						cFuncaoVal := aJsToST[nX][5]
						If !(Empty(aJsToST[nX][5]) .Or. &cFuncaoVal.(xVlrCmp,aJsToST[nX],aError,cCodFilERP,cCodGrupo))
							lGrava := .F.
						EndIf
					Endif

					If lGrava

						if aJsToST[nX][2] == "TAFDATA"

							If Empty(AllTrim(xVlrCmp))
								xVlrCmp := dDataBase
							Else
								xVlrCmp := STOD( xVlrCmp )
							EndIf

						elseIf aJsToST[nX][2] == "TAFHORA"

							If Empty(AllTrim(xVlrCmp))
								xVlrCmp := Time()
							EndIf

						elseif aJsToST[nX][2] == "TAFMSG" //tratamento para Base64
						/*+------------------------------------------+
						| Verificação de Codificação/Criptografia  |
						+------------------------------------------+*/
							xVlrCmp := DeCode64(xVlrCmp)
							If isUTF8(xVlrCmp)
								xVlrCmp := RemoveUTF8(xVlrCmp)
							EndIf 

							xVlrTemp := DeCodeUTF8(xVlrCmp)

							If xVlrTemp != Nil 
								xVlrCmp := xVlrTemp
							EndIf 
							If xVlrCmp == Nil
								aAdd(aError,{"806",STR0040 + aJsToST[nX][2]+ " (" + aJsToST[nX][1] + ")" + STR0041}) //"O Xml Contido no campo # apresenta inconsistência na codificação ou criptografia."
								lGrava := .F.
								Exit
							EndIf

						elseif aJsToST[nX][2] == "TAFPRIORIT" .And. empty(xVlrCmp) //tratamento para o default de prioridade do registro
							xVlrCmp := '5'

						elseif aJsToST[nX][2] == "TAFSTQUEUE" //tratamento para converter o campo de fila
							xVlrCmp := iif( xVlrCmp == '1' , 'F' , '' )
						endif

						(cAliasST2)->&(aJsToST[nX][2]) := xVlrCmp

					Else
						//Se houver inconsistências saio do laço
						Exit
					EndIf

				Next nX

				If lGrava
					(cAliasST2)->TAFSTATUS := "1'
					(cAliasST2)->TAFTICKET := cTicket
					(cAliasST2)->(dbCommit(), MsUnLock())
				Else
					DISARMTRANSACTION()
				EndIf

			Else
				lGrava := .F.
			EndIf

		END TRANSACTION

	Else
		lGrava := .F.
		aAdd(aError,{"813",STR0058 + oJsonItem:registryKey + STR0059}) //"O TAFKEY # já existe na TAFST2 e encontra-se pendente de processamento ou em processamento."
	EndIf

	FreeObj(oJsonItem)

Return (lGrava)

//----------------------------------------------------------------------------
/*/{Protheus.doc} xValidFil
Função de validação das Filiais.
Verifica se a filial enviada (sourceBranch)está cadastrada na tabela de
complemento de empresa

@param xValor 		- Conteúdo do campo
@param aStruCmp		- Array com a estrutura do campo
@param aError		- Array para a gravação de possiveis erros na estrutura do
					  aquivo. (passagem por referência)
@param cCodFilERP 	- Filial do ERP
@param cCodGrupo	- Codigo do Grupo de Empresas TAF.

@return lReturn	- Indica se a filial está cadastrada no complemento de
					  empresa.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function xValidFil(xValor,aStruCmp,aError,cCodFilERP,cCodGrupo)

	Local lReturn
	Local cUUIDFil
	Local cChaveFil
	Local cEmpTAF
	Local aEmpresas

	cUUIDFil     := "tafJobID"
	cChaveFil    := "keyTafJob"
	cEmpTAF		 := ""
	lReturn		 := .T.
	aEmpresas    := {}

	//Só realizo a verificação de o valor do registro atual for diferente do cCodFilERP
	//que é o valor da filial ERP do primeiro registro do lote que já foi previamente validado.
	If AllTrim(xValor) != cCodFilERP

		If VarGetA(cUUIDFil,cChaveFil, @aEmpresas)

			//Preciso pesquisar o código do Grupo de Empresas somente 1x
			If Empty(cCodGrupo)
				WsSearchDePara(AllTrim(cCodFilERP),aEmpresas,@cCodGrupo)
			EndIf
			//Verifico se o Grupo de Empresas da filial do ERP é o mesmo para todas as mensagens
			//do lote, cCodFilERP é o valor da filial ERP do primeiro registro do lote por isso
			//o grupo de mensagens
			If WsSearchDePara(AllTrim(xValor),aEmpresas,@cEmpTAF)
				If cEmpTAF != cCodGrupo
					aAdd(aError,{"812",STR0056 + xValor + STR0057}) //"Código da Filial ERP#" não pertence ao mesmo Grupo de Empresas no TAF considerando os registros integrados anteriormente neste lote.""
					lReturn := .F.
				EndIf
			Else
				aAdd(aError,{"803",STR0024 + "sourceBranch (TAFFIL) " + STR0025}) ////"O valor do campo "#" não está cadastro no complemento de empresas."
				lReturn := .F.
			EndIf
		Else
			aAdd(aError,{"810",STR0043 + cChaveFil + STR0044}) //"Chave # de Identificação de filial não encontrada."
			lReturn := .F.
		EndIf
	EndIf

	aSize(aEmpresas,0)
	aEmpresas := Nil

Return lReturn

//----------------------------------------------------------------------------
/*/{Protheus.doc} xValTpMes
Valida o Tipo de Mensagem enviado no arquivo (messageType), o mesmo deve
ser 1 ou 2.

@param xValor 		- Conteúdo do campo
@param aStruCmp	- Array com a estrutura do campo
@param aError		- Array para a gravação de possiveis erros na estrutura do
					  aquivo. (passagem por referência)


@return lReturn	- Indica se o tipo de mensagem é valido.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function xValTpMes(xValor,aStruCmp,aError)

	Local lReturn
	Local cValor

	lReturn := .T.
	cValor := AllTrim(xValor)

	If !(cValor $ "12")
		aAdd(aError,{"802",STR0024 + aStruCmp[2]+ " (" + aStruCmp[1] + ") " + STR0026}) //"O valor do campo "#"deve ser 1 ou 2 (1=txt/2=xml)."
		lReturn := .F.
	Endif

Return lReturn

//----------------------------------------------------------------------------
/*/{Protheus.doc} xValLayout
Realiza a validação do layout enviado na integração (registryType) utilizando
a rotina de controle de funções (TafRotinas).

@param xValor 		- Conteúdo do campo
@param aStruCmp	- Array com a estrutura do campo
@param aError		- Array para a gravação de possiveis erros na estrutura do
					  aquivo. (passagem por referência)


@return lReturn	- Indica se o tipo de mensagem é valido.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function xValLayout(xValor,aStruCmp,aError)

	Local lReturn := .T.

	If (alltrim(xValor) <> 'T999') .and. (aScan(aRotinas,{|cLay|AllTrim(cLay[4]) == AllTrim(xValor)}) == 0)
		aAdd(aError,{"804",STR0027 + AllTrim(xValor) + STR0028 + aStruCmp[2]+ " (" + aStruCmp[1] + ") " + STR0029 }) //"Layout "#" campo "#"Inválido."
		lReturn := .F.
	EndIf

Return lReturn

//----------------------------------------------------------------------------
/*/{Protheus.doc} xSelMod
Determina o modo de busca que foi requisitado, o mesmo pode ser por TAFKEY,
TAFTICKET ou TAFKEY + TAFTICKET.

@param cTicket 	- tafTicket informado na requisição
@param cKey		- tafKey informado na requisição

@return cMod		- Modo de Pesquisa

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function xSelMod(cTicket,cKey)

	Local cMod

	Default cTicket 	:= ""
	Default cKey 		:= ""

	cMod := ""

	If !Empty(AllTrim(cTicket)) .And. !Empty(AllTrim(cKey))
		cMod := 'both'
	ElseIf !Empty(AllTrim(cTicket)) .And. Empty(AllTrim(cKey))
		cMod := 'ticket'
	Else
		cMod := 'key'
	EndIf

Return cMod

//----------------------------------------------------------------------------
/*/{Protheus.doc} consultaRegs
Realiza a consulta dos registros para retorno do método GET.

@param cTicket 		- tafTicket enviado na requisição
@param cKey	 		- tafKey enviado na requisição
@param cAliasTrb 		- Alias que a consulta deve utilizar para retorno das informações
@param lLast			- Filtro para retorno somente do ultimo item.
@param lValido			- Filtro para retorno somente dos registros válidos.
@param nStartRecNo	- RecNo Inicial para a consulta
@param sourceBranch 	- Filial do ERP
@param lErpOwner		- Informa se o campo TAFOWNER existe na tabela
@param lPredeces		- Informa se o campo TAFREGPRED existe na tabela
@param lFilTran		- Informa se o campo TAFFILTRAN existe na tabela
@param lComplem	- Informa se o campo TAFCOMP existe na tabela

@return lRet	- Informa se a consulta retorno dados.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function consultaRegs(cTicket,cKey,cAliasTrb,lLast,lValido,nStartRecNo,sourceBranch,lErpOwner,lPredeces,lFilTran, lComplem)

	Local cQry
	Local cTafTicket
	Local cTafKey
	Local cWhere
	Local cJoin
	Local cBanco
	Local aRecs
	Local lRet
	Local nLastRecNo
	Local cQryMRecNo
	Local cQryTafKey
	Local nQtdTafKey 

	cQry 		:= ""
	cTafTicket	:= ""
	cTafKey		:= ""
	cWhere		:= ""
	cJoin		:= ""
	cBanco		:= ""
	cQryMRecNo  := ""
	cQryTafKey  := ""
	aRecs		:= {}
	lRet		:= .F.
	nLastRecno  := 0
	nQtdTafKey  := 0
	
	Default lLast		 	:= .F.
	Default lValido			:= .F.
	Default cTicket 		:= ""
	Default cKey 	  		:= ""
	Default sourceBranch	:= ""
	Default lErpOwner		:= .F.
	Default lPredeces		:= .F.
	Default lFilTran		:= .F.
	Default lComplem		:= .F.

	cTafTicket	:= AllTrim(cTicket)
	cTafKey 	:= AllTrim(cKey)
	cBanco		:= Upper(AllTrim(TcGetDB()))

	If !Empty(cTafTicket) .And.  !Empty(cTafKey)

		cWhere := " ST2.TAFTICKET =  '" + cTafTicket +  "'"
		cWhere += " AND ST2.TAFKEY = '" + cTafKey + "'"
	ElseIf !Empty(cTafTicket)

		cWhere := " ST2.TAFTICKET =  '" + cTafTicket +  "'"
	Else

		cWhere := " ST2.TAFKEY = '" + cTafKey + "'"
		cWhere += " AND ST2.D_E_L_E_T_ <> '*'"

		//25-05-2020 - Quando a consulta é somente por TAFKEY, verifico se existe + de 1 ocorrencia do mesmo
		//Caso o resultado seja maior que 0 é realizado uma junção a mais na query.
		cQryTafKey := " SELECT COUNT(R_E_C_N_O_) QTDKEY "
		cQryTafKey += " FROM TAFST2 ST2 "
		cQryTafKey += " WHERE "

		If !Empty(sourceBranch)
			cQryTafKey += " TAFFIL = '" + sourceBranch + "'"
			cQryTafKey += " AND "
		EndIf

		cQryTafKey += " D_E_L_E_T_ = ' ' "

		TCQuery cQryTafKey New Alias 'rsMaxXERP'
		nQtdTafKey := rsMaxXERP->QTDKEY
		rsMaxXERP->(dbCloseArea())

	EndIf

	If !Empty(sourceBranch)
		cWhere += " AND ST2.TAFFIL = '" + sourceBranch + "'"
	EndIf

	If lValido
		cWhere += " AND ST2.TAFSTATUS = '3' AND XERP.TAFSTATUS IN ('1','2','3') "
	EndIf

	cWhere += " AND ST2.R_E_C_N_O_ >= " + AllTrim(Str(nStartRecNo))
	cWhere += " AND ST2.D_E_L_E_T_ <> '*'"

	cJoin := " LEFT JOIN TAFXERP XERP ON  ST2.TAFKEY = XERP.TAFKEY "

	If !Empty(cTicket)
		cJoin += " AND ST2.TAFTICKET = XERP.TAFTICKET "
	Endif 

	//21/04/2020 - Evandro dos Santos Oliveira
	//Incluido consulta para pegar o ultimo recno da TAFXERP somente quando o registro correspondente na TAFST2 estiver processado
	//(status 3), isso se faz necessário para quando o registro estiver com status 1 na TAFST2 não seja realizado JOIN com a TAXERP
	//evitando assim que seja retornado o status de um registro com mesmo TAFKEY e reitado RET enviado anteriormente.
	If lLast .And. nQtdTafKey > 0

		If cBanco == "ORACLE"

			//25-05-2020 - Evandro dos Santos - Condição para banco ORACLE por conta da Limitação da versão 11G
			cQryMRecNo := " SELECT MAX(R_E_C_N_O_) MAXRECNO "
			cQryMRecNo += " FROM TAFXERP "
			cQryMRecNo += " WHERE " 
			cQryMRecNo += " TAFKEY = '" + AllTrim(cTafKey) + "'" 

			If lValido
				cQryMRecNo +=  " AND TAFSTATUS IN ('1','2','3') "
			EndIf

			cQryMRecNo += " AND D_E_L_E_T_ = ' ' "

			TCQuery cQryMRecNo New Alias 'rsMaxXERP'
			nLastRecno := rsMaxXERP->MAXRECNO
			rsMaxXERP->(dbCloseArea())

			cJoin += " AND XERP.R_E_C_N_O_ = " + cValToChar(nLastRecno)
		Else

			cJoin += " AND XERP.R_E_C_N_O_ =  (" 
			cJoin += " SELECT MAX(R_E_C_N_O_) FROM TAFXERP MAXERP WHERE XERP.TAFKEY = MAXERP.TAFKEY AND MAXERP.D_E_L_E_T_ = ' ' " 

		EndIf


		If lValido
			cJoin +=  " AND XERP.TAFSTATUS IN ('1','2','3') "
		EndIf		

		If cBanco != "ORACLE"
			cJoin += ") "
		EndIf 

	EndIf 
	
	cJoin += " AND ST2.TAFSTATUS = '3' "
	cJoin += " AND XERP.D_E_L_E_T_ <> '*' "

	If lLast .And. !Empty(cTafKey) //Se o cTafKey estiver vazio quer dizer que a consulta é por lote, neste caso não posso dar select top e o condicional para retornar o ultimo está no WHERE
		If !( cBanco $ ( "INFORMIX|ORACLE|DB2|OPENEDGE|MYSQL|POSTGRES" ) )
			cQry := " SELECT TOP 1 ST2.TAFFIL TAFFIL "
		ElseIf cBanco == "INFORMIX"
			cQry := " SELECT FIRST 1 ST2.TAFFIL TAFFIL "
		Else
			cQry := " SELECT ST2.TAFFIL TAFFIL "
		EndIf
	Else
		cQry := " SELECT ST2.TAFFIL TAFFIL "
	EndIf

	cQry += ", ST2.R_E_C_N_O_ 	RECST2 "
	cQry += ", XERP.R_E_C_N_O_ 	RECXERP "
	cQry += ", ST2.TAFSTATUS 	ST2_STATUS "
	cQry += ", ST2.TAFSEQ 		ST2_SEQ "
	cQry += ", ST2.TAFKEY 		TAFKEY "
	cQry += ", ST2.TAFTICKET 	TAFTICKET "
	cQry += ", ST2.TAFSTQUEUE 	STQUEUE "
	cQry += ", ST2.TAFPRIORIT 	PRIORITY "
	cQry += ", ST2.TAFTPREG		TAFTPREG"
	cQry += ", ST2.TAFFIL		FILIALERP"

	If lErpOwner
		cQry += ", ST2.TAFOWNER 	TAFOWNER "
	EndIf

	If lPredeces
		cQry += ", ST2.TAFREGPRED TAFREGPRED "
	EndIf

	If lFilTran
		cQry += ", ST2.TAFFILTRAN TAFFILTRAN "
	EndIf

	If lComplem
		cQry += ", ST2.TAFCOMP TAFCOMP "
	EndIf

	cQry += ", XERP.TAFCODERR 	XERP_CODERR "
	cQry += ", XERP.TAFSTATUS 	XERP_STATUS "


	cQry += ", XERP.TAFALIAS  	ALIAS_TAF "
	cQry += ", XERP.TAFRECNO	RECNO_TAF "

	cQry += " FROM TAFST2 ST2 "
	cQry += cJoin
 	cQry += " WHERE "
 	cQry += cWhere

	If lLast .And. !Empty(cTafKey) //Se o cTafKey estiver vazio quer dizer que a consulta é por lote, neste caso não posso dar select top e o condicional para retornar o ultimo está no WHERE
		If cBanco == "DB2"
			cQry += " ORDER BY ST2.R_E_C_N_O_ DESC  "
			cQry += " FETCH FIRST 1 ROWS ONLY "

		Elseif cBanco $ "POSTGRES|MYSQL"
			cQry += " ORDER BY ST2.R_E_C_N_O_ DESC LIMIT 1 "
		Else
			cQry += " ORDER BY ST2.R_E_C_N_O_ DESC "
		Endif
	Else
		cQry += " ORDER BY ST2.R_E_C_N_O_
	EndIf

 	If lLast .And. cBanco == "ORACLE" .And. !Empty(cTafKey) //Se o cTafKey estiver vazio quer dizer que a consulta é por lote, neste caso não posso dar select top e o condicional para retornar o ultimo está no WHERE

 		cQryAux := cQry

 		//Para o Oracle preciso executar a query utilizando o DESC e só depois usar o ROWNUM
 		//caso contrario ele primeiro pega a linha e depois ordena, retornando  o primeiro registro ao
 		//inves do ultimo.

 		cQry := " SELECT * FROM ( "
 		cQry += cQryAux
 		cQry += " ) TEMP "
 		cQry += " WHERE  ROWNUM <= 1 "

	EndIf

	cQry := ChangeQuery(cQry)
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) ,cAliasTrb)

	lRet := !Empty((cAliasTrb)->RECST2)

Return (lRet)

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFLastRcN
Retorna o Numero do Ultimo RecNo de acordo com a chave

@param cTicket 		- tafTicket enviado na requisição
@param cKey	 		- tafKey enviado na requisição
@param lValido		- Filtro para retorno somente dos registros válidos.
@param nStartRecNo	- RecNo Inicial para a consulta
@param sourceBranch - Filial do Erp

@return nMaxRec	- Maior RecNo da Consulta

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFLastRcN(cTicket,cKey,lValido,nStartRecNo,sourceBranch, lGPE)

	Local cQry           := ""
	Local cWhere         := ""
	Local cTafTicket     := ""
	Local cTafKey        := ""
	Local cJoin          := ""     
	Local nMaxRec        := 0
	Local cFilTAF        := ""

	Default cTicket	     := ""
	Default cKey 	     := ""
	Default lValido      := .F.
	Default nStartRecNo  := 1
	Default sourceBranch := ""
	Default lGPE         := .F.

	cTafTicket	:= AllTrim(cTicket)
	cTafKey 	:= AllTrim(cKey)

	If !Empty(cTafTicket) .And.  !Empty(cTafKey)

		cWhere := " ST2.TAFTICKET =  '" + cTafTicket +  "'"
		cWhere += " AND ST2.TAFKEY = '" + cTafKey + "'"
	ElseIf !Empty(cTafTicket)

		cWhere := " ST2.TAFTICKET =  '" + cTafTicket +  "'"
	Else

		cWhere := " ST2.TAFKEY = '" + cTafKey + "'"
	EndIf

	If !Empty(sourceBranch)
		
		If lGPE
			cFilTAF      := FTafGetFil(sourceBranch)
			sourceBranch := AllTrim(Posicione('C1E',3,xFilial('C1E') + Padr( cFilTAF, TamSX3( "C1E_FILTAF" )[1] ) + "1", 'C1E_CODFIL'))
		EndIf
		
		cWhere += " AND ST2.TAFFIL = '" + sourceBranch + "'"
	EndIf

	If lValido
		cWhere += " AND ST2.TAFSTATUS = '3' AND XERP.TAFSTATUS IN ('1','2','3') "
	EndIf

	cWhere += " AND ST2.R_E_C_N_O_ >= " + AllTrim(Str(nStartRecNo))
	cWhere += " AND ST2.D_E_L_E_T_ <> '*'"

	cJoin := " LEFT JOIN TAFXERP XERP ON  ST2.TAFKEY = XERP.TAFKEY "
	cJoin += " AND ST2.TAFTICKET = XERP.TAFTICKET "
	cJoin += " AND XERP.D_E_L_E_T_ <> '*' "

	cQry := " SELECT MAX(ST2.R_E_C_N_O_) RECNO"
	cQry += " FROM TAFST2 ST2 "
	cQry += cJoin
 	cQry += " WHERE "
 	cQry += cWhere

	//cQry := ChangeQuery(cQry)

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) ,"MAXST2")

	nMaxRec := MAXST2->RECNO

	MAXST2->(dbCloseArea())

Return (nMaxRec)

//----------------------------------------------------------------------------
/*/{Protheus.doc} seekTAF
Realiza o posicionamento do registro no TAF.
Essa função é executada dentro de um laço que percorre a tabela TAFXERP,
por esse motivo é solicitado o TAFALIAS da TAFXERP e o alias a ser posicionado
evitando o uso desnecessário do dbSelectArea já que os registros costumam
a estar em ordem de alias.

@param cAliasXErp 		- Alias da tabela no campo TAFALIAS na tabela TAFXERP
@param cAliasTaf	 	- Alias do registro a ser posicionado
@param nRecno		 	- RecNo do Registro a ser posicionado
@param sourceBranch 	- Filial do ERP enviada na requisição
@param cFilERP			- Filial do ERP encontrada no campo TAFFIL da tabela TAFST2

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function seekTAF(cAliasXErp,cAliasTaf,nRecno,sourceBranch,cFilERP,cUUIDFil,cChaveFil)

	Local aEmpresas := {}
	Local lOk := .T.
	Local cEmpTaf := ""
	Local cFilTaf := ""


	If Empty(sourceBranch)
		IF VarGetA(cUUIDFil,cChaveFil,@aEmpresas)

			WsSearchDePara(cFilERP,aEmpresas,@cEmpTaf,.T.,@cFilTAF)
			If cEmpTaf != FWGrpCompany()
				lOk := .F.
			EndIf 
		Else
			TafConOut("Nao foi possivel localizar a Filial do TAF para o retorno das inconssistencias do RET. ")
		Endif
	EndIf 

	If lOk

		//Evito ficar abrindo a área desnecessariamente
		If cAliasTaf != cAliasXErp
			cAliasTaf := cAliasXErp
			dbSelectArea(cAliasTaf)
			dbSetOrder(1)
		EndIf

		(cAliasTaf)->(dbGoTo(nRecno))
		If (cAliasTaf)->(Eof())
			lOk := .F. 
		EndIF 
	EndIf 

Return lOk

//----------------------------------------------------------------------------
/*/{Protheus.doc} getErrXERP
Retorna a descrição do erro conforme array aErrosErr alimentado pela função
TAFCodErr.

@param cCodErr 		- Código do Erro
@param aErrosXErp	 	- Array com a Descrição dos erros

@return cDescErr		- Descrição do Erro.

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function getErrXERP(cCodErr,aErrosXErp)

	Local nPos
	Local cDescErr

	nPos := 0
	cDescErr := ""

	nPos :=  aScan(aErrosXErp,{|x|x[1] == AllTrim(cCodErr)})

	If nPos > 0
		cDescErr := aErrosXErp[nPos][2]
	EndIf
	cDescErr := retiraQuebra(cDescErr)
Return (cDescErr)

//----------------------------------------------------------------------------
/*/{Protheus.doc} RemoveUTF8
Retira a Identificação de codificação UTF8 do inicio do XML.
É realizado este tratamento para que os Xmls fiquem na TAFST2 iguais idependente
da tecnologia utilizada na integração.

@param cXml - Xml do Evento

@return cXmlRet - Xml Sem a Tag de Encode.

@author Evandro dos Santos O. Teixeira
@since 11/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function RemoveUTF8(cXml)

	Local nStart
	Local cXmlRet

	nStart  := 0
	cXmlRet := ""

	nStart := AT(">",cXml)
	cXmlRet := Substr(cXml,nStart+1,Len(cXml)-(nStart))
	cXmlRet := StrTran(cXmlRet,Chr(13),"")
	cXmlRet := StrTran(cXmlRet,Chr(10),"")

Return cXmlRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} isUTF8
Verifica se o Xml está com codificação UTF-8

@param cXml - Xml do Evento

@return logico - valor booleano

@author Evandro dos Santos O. Teixeira
@since 11/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function isUTF8(cXml)
Return ('ENCODING="UTF-8"' $ Upper(cXml))

//----------------------------------------------------------------------------
/*/{Protheus.doc} xValPriority
Valida o código de prioridade enviado na mensagem JSON

@param xValor 		- Conteúdo do campo
@param aStruCmp		- Array com a estrutura do campo
@param aError		- Array para a gravação de possiveis erros na estrutura do
					  aquivo. (passagem por referência)

@return lReturn	- Indica se o código de prioridade é valido.

@author Luccas Curcio
@since 08/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
static function xValPriority( xValor , aStruCmp , aError )

local	lRet
local	aCodePriority
local	cPrioritys
local	nX

lRet			:=	.T.
aCodePriority	:=	{}
cPrioritys		:=	''
nX				:=	1

if findFunction('TAFIsPriority') .and. !( TAFIsPriority( xValor ) )

	aCodePriority	:=	TAFGetPriority()

	for nX := 1 to len( aCodePriority )
		cPrioritys += aCodePriority[ nX , 1 ] + ' - ' + aCodePriority[ nX , 2 ] + ', '
	next nX

	cPrioritys := subStr( cPrioritys , 1 , len( cPrioritys ) - 2 )

	aAdd( aError , { "805" , noAcento( STR0050 + xValor + STR0051 + cPrioritys ) } ) //"Código de Prioridade inválido! Código enviado: # . Códigos válidos:'"
	lRet	:=	.F.

endif

return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} xValQueue
Valida o código de fila enviado na mensagem JSON

@param xValor 		- Conteúdo do campo
@param aStruCmp		- Array com a estrutura do campo
@param aError		- Array para a gravação de possiveis erros na estrutura do
					  aquivo. (passagem por referência)

@return lReturn	- Indica se o código de fila é valido.

@author Luccas Curcio
@since 17/05/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
static function xValQueue( xValor , aStruCmp , aError )

local lRet

lRet :=	.T.

return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFTabInteg
Faz a abertura das tabelas auxiliares de integração (TAFST2,TAFXERP etc..)

@param cNomeTab  - Nome da Tabela
@param cAliasTab - Alias da Tabela


@return aErros	- Possiveis Erros na Criação/Abertura da Tabela.

@author Evandro dos Santos Oliveira
@since 18/09/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFTabInteg(cNomeTab,cAliasTab,aErros)

	Local nTry
	Local lRet

	Default cNomeTab  := ""
	Default cAliasTab := ""
	Default aErros    := {}

	nTry    := 5
	nCount	:= 1
	lRet 	:= .T.

	While nCount <= nTry

		//Tenho que zerar por que estara preenchido cada vez que falhar a abertura da tabela
		If !Empty(aErros)
			aSize(aErros,0)
		Endif

		xTAFCriaTB(,,cNomeTab,cAliasTab,,,,,,,, @aErros,)

		If Empty(aErros)
			Exit
		Else
			TafConOut( STR0054 + cNomeTab +  " - "  + AllTrim(Str(nCount)) + "/" + AllTrim(Str(nTry))) //"Tentativa de abertura da tabela "
			//Espero meio segundo antes de uma nova tentativa
			Sleep(500)

			//Garanto que o Alias não está aberto
			If Select(cAliasTab) > 0
				(cAliasTab)->(dbCloseArea())
			EndIf
		EndIf
		nCount++
	EndDo

	If nCount >= nTry
		TafConOut(STR0055 + cNomeTab) //"Esgotadas as tentativas de abertura de tabela. Alias: "
		lRet := .F.
	EndIf

Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} WSST2ValFil
Realiza a validação da Filial do ERP e determina qual empresa do TAF
deve executar o processamento utilizado a Thread "startada" a mesma.

@sourceBranch - Filial do ERP
@cFuncIPC - Função utilizada para preparar o ambiente para a empresa TAF.


@author Evandro dos Santos O. Teixeira
@since 14/12/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Function WSST2ValFil( sourceBranch, cFuncIPC, cCodErr, cDescription, lRetFilTAF, cFilTAF, cEmpProc )

	Local cUUIDFil
	Local cChaveFil
	Local cEmpTaf
	Local aEmpresas
	Local lValido

	Default sourceBranch	:=	""
	Default cCodErr			:=	""
	Default cDescription	:=	""
	Default lRetFilTAF		:=	.F.
	Default cFilTAF			:=	""
	Default cEmpProc		:=	""

	cUUIDFil     := "tafJobID"
	cChaveFil    := "keyTafJob"
	cEmpTaf		 := ""
	aEmpresas	 := {}
	aRetorno	 := Array(4)

	lValido		 := .T.

	If Empty(sourceBranch)
		//Para manter o legado quando não é informado o atributo sourceBranch
		//executo na empresa cadastrada na chave PrepareIn da seção TAF_CFGJOB
		If VarGetA(cUUIDFil,cChaveFil, @aEmpresas)
			If Len(aEmpresas) > 0
				cFuncIPC := "TAF_ACCEPT_" +  aEmpresas[1][1]
				cEmpTAF	:=	 aEmpresas[1][1]
				cFilTAF	:=	aEmpresas[1][2][1][2]
			Else
				cCodErr := "809"
				cDescription := STR0042 //"Não há configuração de empresas na chave PrepareIn seção TAF_CFGJOB."
				lValido := .F.
			EndIf
		Else
			cCodErr := "810"
			cDescription := STR0043 + cChaveFil + STR0044 // "Chave # de Identificação de filial não encontrada."
			lValido := .F.
		EndIf
	Else
		//Seção tafJobID (cUUIDFil) criada no fonte TAF_CFGJOB
		If VarGetA(cUUIDFil,cChaveFil, @aEmpresas)

			If WsSearchDePara( sourceBranch, aEmpresas, @cEmpTAF, lRetFilTAF, @cFilTAF )
				cFuncIPC := "TAF_ACCEPT_" +  cEmpTaf
			Else
				cCodErr := "803"
				cDescription := "O contéudo informado no parâmetro sourceBranch não está cadastrado no Complemento de Empresas."
				lValido := .F.
			EndIf
		Else
			cCodErr := "810"
			cDescription := STR0043 + cChaveFil + STR0044 // "Chave # de Identificação de filial não encontrada."
			lValido := .F.
		EndIf
	EndIf
	cEmpProc := cEmpTAF

	aSize(aEmpresas,0)
	aEmpresas := Nil

Return (lValido)

Function TAFSearchFils(sourceBranch,aEmpresas,cEmpTAF,lRetFilTAF,cFilTAF)
Return WsSearchDePara(sourceBranch,aEmpresas,cEmpTAF,lRetFilTAF,cFilTAF)

//----------------------------------------------------------------------------
/*/{Protheus.doc} WsSearchDePara
Realiza Busca da Filial no Cache criado pela função TAFGetDePara
no fonte TAF_CFGJOB.

@sourceBranch - Filial do Erp
@aEmpresas - Array com o De/Para de Empresas TAF x ERP
@cEmpTAF - (referência) Variavel para retorno do Grupo de Empresas
correspondente ao sourceBranch.
@lRetFilTAF - Define se deve retornar também a Filial do Taf no parametro cFilTAF
@cFilTAF 	- (referência) Filial do TAF se lRetFilTAF for True


@author Evandro dos Santos O. Teixeira
@since 14/12/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Function WsSearchDePara(sourceBranch,aEmpresas,cEmpTAF,lRetFilTAF,cFilTAF)

	Local nPosEmpTAF
	Local nX
	Local lFound
	Local aEmpsSM0
	Local aEmpsProf
	Local cCodEmp
	Local cNomeEmp
	Local cModoC1E
	Local cModoCR9
	Local cUUIDFil
	Local cChaveFil
	Local cEmpPos

	cUUIDFil   := "tafJobID"
	cChaveFil  := "keyTafJob"

	Default cFilTAF := ""
	Default lRetFilTAF := .F.

	nPosEmpTAF   := 0
	nX			 := 0
	lFound		 := .F.
	aEmpsProf	 := {}

	lFound := foundBranch(sourceBranch,aEmpresas,lRetFilTAF,@cFilTaf,@cEmpTaf)

	If !lFound

		aEmpsSM0 := TafGetEmps()
		aEmpsProf := TafGetProfEmp(aEmpsSM0)

		If Len(aEmpsProf) > 0

			For nX := 1 To Len(aEmpsProf)

				cCodEmp  := aEmpsProf[nX][1]
				cNomeEmp := aEmpsProf[nX][2]
				lFound := .F.

				cEmpPos := aEmpsProf[1][1]
				If FWGrpCompany() != cEmpPos
					RpcSetType( 3 )
					RpcSetEnv(cEmpPos,,,,"TAF","WSTAFST2",,,,.T.,)
				EndIf 

				If cCodEmp != cEmpPos
					EmpOpenFile("C1E","C1E",7,.T.,cCodEmp, @cModoC1E )
					EmpOpenFile("CR9","CR9",2,.T.,cCodEmp, @cModoCR9 )
				Else

					dbSelectArea("C1E")
					C1E->(dbSetOrder(7))

					dbSelectArea("CR9")
					CR9->(dbSetOrder(2))

				EndIf

				If C1E->(MsSeek(xFilial("C1E")+PADR(AllTrim(sourceBranch),GetSx3Cache("C1E_CODFIL","X3_TAMANHO"))+"1"))

					If getPosEmpresa(cCodEmp,aEmpresas,@nPosEmpTAF)
						cEmpTaf := cCodEmp
						cFilTaf := C1E->C1E_FILTAF
						aAdd(aEmpresas[nPosEmpTAF][2],{sourceBranch,C1E->C1E_FILTAF})
						lFound := .T.
						nX := Len(aEmpsProf) + 1
						Exit
					EndIf
				EndIf

				If !lFound

					If CR9->( MsSeek( xFilial("CR9") + PadR( AllTrim(sourceBranch), GetSx3Cache("C1E_CODFIL","X3_TAMANHO") ) + "1" ) )
						//Somente encontrar o item na CR9 não é garantia que a filial é valida
						//preciso posicionar na C1E utilizando o ID+VERSAO e verificar se a filial é ativa
						//e recuperar a filial do TAF
						C1E->(dbSetOrder(2))
						If C1E->(MsSeek(xFilial("C1E")+CR9->CR9_ID+CR9->CR9_VERSAO+"1"))

							If getPosEmpresa(cCodEmp,aEmpresas,@nPosEmpTAF)
								cEmpTaf := cCodEmp
								cFilTaf := C1E->C1E_FILTAF
								aAdd(aEmpresas[nPosEmpTAF][2],{sourceBranch,C1E->C1E_FILTAF})
								lFound := .T.
								nX := Len(aEmpsProf) + 1
								Exit
							EndIf
						EndIf
					EndIf

				EndIf

				C1E->(dbCloseArea())
				CR9->(dbCloseArea())

			Next nX
		EndIf

		If lFound

			If VarSetAD(cUUIDFil, cChaveFil, aEmpresas)

				TafConout("Atualizado De/Para de Filiais: " + cUUIDFil + " chave "+ cChaveFil + ". SourceBranch: " + sourceBranch)
			Else

				TafConout("Erro na Atualizacao do De/Para de Filiais: " + cUUIDFil + " chave "+ cChaveFil + ". SourceBranch: " + sourceBranch)
			EndIf
		EndIf

	EndIf

	aSize(aEmpsProf,0)

Return (lFound)

//----------------------------------------------------------------------------
/*/{Protheus.doc} foundBranch
Realiza Busca da Filial no Cache criado pela função TAFGetDePara
no fonte TAF_CFGJOB.

@sourceBranch - Filial do Erp
@aEmpresas - Array com o De/Para de Empresas TAF x ERP
@lRetFilTAF - Define se deve retornar também a Filial do Taf no parametro cFilTAF
@cFilTAF 	- (referência) Filial do TAF se lRetFilTAF for True
@cEmpTaf 	- (referência) Codigo do Grupo de Empresa


@author Evandro dos Santos O. Teixeira
@since 20/05/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function foundBranch(sourceBranch,aEmpresas,lRetFilTAF,cFilTaf,cEmpTaf)

	Local nX
	Local nPosEmpTAF
	Local lReturn

	Default cFilTaf := ""
	Default cEmpTaf := ""

	nX := 0
	nPosEmpTAF := 0
	lReturn := .F.

	/*+------------------------------------------------------------+
		| Estrutura do Array de De/Para:  		 				   |
		|											               |
		| aEmpresas[n] - Array						               |
		| aEmpresas[n][1] - Empresa     			               |
		| aEmpresas[n][2] - Array					               |
		| aEmpresas[n][2][n][1] - Filial ERP  		               |
		| aEmpresas[n][2][n][2] - Filial TAF		               |
		+----------------------------------------------------------+*/
	For nX := 1 To Len(aEmpresas)

		nPosEmpTAF := aScan(aEmpresas[nX][2],{|emps|AllTrim(emps[1]) == AllTrim(sourceBranch)})

		If (nPosEmpTAF > 0)
			cEmpTAF := aEmpresas[nX][1] //Tenho que pegar o Grupo de Empresas pq é o sufixo que
			//está sendo utilizando para identificar as threads.

			If lRetFilTAF
				cFilTAF := aEmpresas[nX][2][nPosEmpTAF][2] // Filial do TAF
			EndIf

			nX := Len(aEmpresas) + 1 //força a saida do laço pq já achei a empresa
			lReturn := .T.
		EndIf

	Next nX

Return lReturn

//----------------------------------------------------------------------------
/*/{Protheus.doc} getPosEmpresa
Retorna a Posicição no array da empresa informada em cCompany

@cCompany - Codigo da Empresa a ser pesquisada
@aEmpresas - Array com o De/Para de Empresas TAF x ERP
@nPosEmpTAF - Retorna posicação da empresa no array aEmpresas

@lReturn - Retorna se a empresa foi localizada no array

@author Evandro dos Santos O. Teixeira
@since 20/05/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function getPosEmpresa(cCompany,aEmpresas,nPosEmpTAF)

	Local lReturn

	Default cCompany := ""
	Default nPosEmpTAF := 0

	nX := 0
	lReturn := .F.

	/*+------------------------------------------------------------+
		| Estrutura do Array de De/Para:  		 				   |
		|											               |
		| aEmpresas[n] - Array						               |
		| aEmpresas[n][1] - Empresa     			               |
		| aEmpresas[n][2] - Array					               |
		| aEmpresas[n][2][n][1] - Filial ERP  		               |
		| aEmpresas[n][2][n][2] - Filial TAF		               |
		+----------------------------------------------------------+*/

		nPosEmpTAF := aScan(aEmpresas[1],{|emps|AllTrim(emps) == AllTrim(cCompany)})

		If (nPosEmpTAF > 0)
			lReturn := .T.
		EndIf

Return lReturn

//----------------------------------------------------------------------------
/*/{Protheus.doc} WSGetPostFil
Recupera a filial do primeiro registro de um lote
Obs: Essa função foi criada para evitar o uso do FWJsonDeserialize antes da
chamada IPC, evitando assim o uso da função 2x

@cJasonBody - Mensagem contida no body do POST

@author Evandro dos Santos O. Teixeira
@since 14/12/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Function WSGetPostFil(cJasonBody)

	Default  cJasonBody := ""

	nPos := At("sourceBranch",cJasonBody)
	cCodFil := Substr(cJasonBody,nPos-1)
	nPos := At(",",cCodFil)
	If nPos > 0
		cCodFil := Substr(cCodFil,1,nPos-1)
	Else
		nTamJson := Len(AllTrim(cJasonBody))
		cCodFil := Substr(cCodFil,1,nTamJson-2)
	EndIf

	nPos := At(":",cCodFil)
	cCodFil := Substr(cCodFil,nPos+1)
	cCodFil := StrTran(cCodFil,'"','')
	cCodFil := AllTrim(cCodFil)

Return cCodFil

//----------------------------------------------------------------------------
/*/{Protheus.doc} getErrResponse
Cria Json de resposta para as mensagens com erro.

@cCodErr - Codigo do Erro
@cDescription - Descrição do Erro

@author Evandro dos Santos O. Teixeira
@since 14/12/2017
@version 1.0
/*/
//---------------------------------------------------------------------------
Static Function getErrResponse(cCodErr,cDescription)

	Local cResponse := ""
	Default cCodErr := ""
	Default cDescription := ""

	cResponse := '{'
	cResponse += '"coderr" : ' + cCodErr
	cResponse += ','
	cResponse += '"description" : "' + cDescription  + '"'
	cResponse += '}'

Return (cResponse)

//----------------------------------------------------------------------------
/*/{Protheus.doc} TafChkKey
Rotina para checar se já existe um TAFKEY pendente de processamento
ou em processamento na TAFST2
@author Diego Santos
@since 10/08/2018
@version 1.0
/*/
//---------------------------------------------------------------------------
Function TafChkKey( cFilTaf, cTpReg, cTafKey )

Local lRet 			:= .T.
Local cAlsTmpTaf	:= GetNextAlias()
Local cTmpQry		:= ""

Default cFilTaf     := oJsonItem:SourceBranch
Default cTpReg      := oJsonItem:registryType
Default cTafKey     := oJsonItem:registryKey

cTmpQry := "SELECT TAFKEY FROM TAFST2 "
cTmpQry += "WHERE "
cTmpQry += "TAFFIL 		= '" + cFilTaf + "' AND "
cTmpQry += "TAFTPREG 	= '" + cTpReg  + "' AND "
cTmpQry += "TAFKEY 		= '" + StrTran(cTafKey, "'", "''") + "' AND "
cTmpQry += "TAFCODMSG 	= '2' 		AND "
cTmpQry += "TAFSTATUS IN ('1','2') 	AND "
cTmpQry += "D_E_L_E_T_ = ' '"

cTmpQry := ChangeQuery(cTmpQry)

dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cTmpQry) ,cAlsTmpTaf)

If (cAlsTmpTaf)->(!Eof())
	lRet := .F.
EndIf

(cAlsTmpTaf)->(DbCloseArea())

Return lRet
