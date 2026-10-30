#INCLUDE "Protheus.CH"
#INCLUDE "TOTVS.ch"
#INCLUDE "TBICONN.ch"

//+++++++INTEGRACAOO PROTHEUS GESPLAN BALANCETE E INDICADORES ++++++++//


Class PrtBalanReadMessageReader from LongNameClass

	method New()
	method Read()

EndClass

/*/{Protheus.doc} PrtBalanReadMessageReader::New
construtor
@type method
@author TOTVS
/*/
method New() Class PrtBalanReadMessageReader

return self

/*/{Protheus.doc} PrtBalanReadMessageReader::Read
Responsável pela leitura e processamento da mensagem.
@type method
@author TOTVS
@param oLinkMessage, object, Instância de FwTotvsLinkMesage da mensagem
@return logical, sucesso ou falha. Determina se deve ou não retirar a mensagem da fila.
/*/
method Read( oLinkMessage ) Class PrtBalanReadMessageReader 
	Local cServer   := "" as character // "localhost" // URL (IP) DO SERVIDOR
    Local cPort     := "" as character // PORTA DO SERVIÇO REST
	Local cUris     := "" as character
	Local nPosVirg  := 0  as numeric
	Local cRest     := "" as character
    Local cURI      := "" as character
    Local cResource := "" as character
    Local oRest     as object
	Local oJsonRest as object
    Local aHeader   := {} as array
	Local cResp 	:= "" as character
	Local oContent 	:= JsonObject():new()
	Local oJson 	:= JsonObject():new()
	Local lRet 		:= .T. as logical
	Local cId 		:= "" as character
	Local lIndicator := .F. as logical
	Local lAnalitic  := .F. as logical
	Local lSintetic  := .F. as logical
	Local cBalancet  := "" as character
	Local cCenario    := "" as character
	Local aFils       :={}
	Local cFiliais 	  := "" as character
	Local nI		  := 0  as numeric
	Local cDfDtIni    := DTOS(FirstDay(DATE()))
	Local cDfDtFim    := DTOS(LastDay(DATE()))
	Local cFilIni     as character
	Local cFilFim     as character
	Local cEmpresa 	  := "" as character
	Local cDataIni 	  := "" as character
	Local cDataFim 	  := "" as character
	
	Local cContaIni  as character
	Local cContaFim  as character
	Local cCustoIni  as character
	Local cCustoFim  as character
	Local cItemIni   as character
	Local cItemFim   as character
	Local cClasseIn  as character
	Local cClasseFi  as character
	Local cEnt05Ini  := "" as character
	Local cEnt05Fim  := "" as character
	Local cEnt06Ini  := "" as character
	Local cEnt06Fim  := "" as character
	Local cEnt07Ini  := "" as character
	Local cEnt07Fim  := "" as character
	Local cEnt08Ini  := "" as character
	Local cEnt08Fim  := "" as character
	Local cEnt09Ini  := "" as character
	Local cEnt09Fim  := "" as character

	Local cTenantId   := "" as character
	Local cMoeda	  := "01" as character
	Local cTpSaldo	  := "1" as character
	Local cFilIndic   := "" as character 
	Local nTamEntid	  := 0  as numeric

	oContent:FromJSON(oLinkMessage:RawMessage())
    cTenantId 	:= oContent['tenantId']
	cId 		:= iif(empty(oContent["id"]),oContent["ID"],oContent["id"])
    oContent 	:= oContent['data']
	lIndicator := oContent['INDICADORES'] == 1
	lAnalitic  := oContent['BALANCETE'] == 1
	lSintetic  := oContent['BALANCETE'] == 2

	If lAnalitic .OR. lSintetic
		
		//VARIAVEIS QUE PRECISAM SER INICIADAS INDEPENDENTE DE oRest["isok"]
		cBalancet := cValToChar(oContent["BALANCETE"])
		oContent:GetJsonValue("CENARIO", @cCenario)
		oContent:GetJsonValue("GRUPO_EMPRESA", @cEmpresa)
		cDataIni   := iif(empty(oContent["dataInicial"]),SUBSTR(cDfDtIni, 7,2)+'/'+SUBSTR(cDfDtIni, 5,2)+'/'+SUBSTR(cDfDtIni, 1,4),DTOS(CTOD(oContent["dataInicial"])))
		cDataFim   := iif(empty(oContent["dataFinal"]),SUBSTR(cDfDtFim, 7,2)+'/'+SUBSTR(cDfDtFim, 5,2)+'/'+SUBSTR(cDfDtFim, 1,4),DTOS(CTOD(oContent["dataFinal"])))
		
		//VALIDA EMPRESA ENVIADA
		oRest := BalnVldEmp(cEmpresa)
		
		If oRest["isok"]== .T.
			
			//INICIACAO DAS VARIAVEIS COM CONTEUDO DEFAULT
			
			//conta contabil
			nTamEntid := TamSX3('CT2_CREDIT')[01]
			cContaIni   := Replicate(" ", nTamEntid)   
			cContaFim   := Replicate("Z", nTamEntid)  
			//centro de custo 
			nTamEntid  := TamSX3('CT2_CCC')[01]
			cCustoIni  := Replicate(" ", nTamEntid) 
			cCustoFim  := Replicate("Z", nTamEntid) 

			//item contabil
			nTamEntid  := TamSX3('CT2_ITEMC')[01]
			cItemIni   := Replicate(" ", nTamEntid)
			cItemFim   := Replicate("Z", nTamEntid)
			//classe de valor
			nTamEntid  := TamSX3('CT2_CLVLCR')[01]
			cClasseIn  := Replicate(" ", nTamEntid)
			cClasseFi  := Replicate("Z", nTamEntid)
			
			//Filial 
			nTamEntid  := TamSX3('CT2_FILIAL')[01]
			cFilIni  := Replicate(" ", nTamEntid)
			cFilFim  := Replicate("Z", nTamEntid)

			//atualizacao com o que vier da requisicao caso o nao encontre no ocontent da requisicao a variavel permanece com o valor default
			oContent:GetJsonValue("filialInicial", @cFilIni)
			oContent:GetJsonValue("filialFinal", @cFilFim)

			oContent:GetJsonValue("contaInicial", @cContaIni)
			oContent:GetJsonValue("contaFinal", @cContaFim)
			
			oContent:GetJsonValue("cCustoInicial", @cCustoIni)
			oContent:GetJsonValue("cCustoFinal", @cCustoFim)
			
			oContent:GetJsonValue("itemInicial", @cItemIni)
			oContent:GetJsonValue("itemFinal", @cItemFim)

			oContent:GetJsonValue("classeInicial", @cClasseIn)
			oContent:GetJsonValue("classeFinal", @cClasseFi)
			
			If CT2->(FieldPos("CT2_EC05CR")) > 0
				nTamEntid  := TamSX3('CT2_EC05CR')[01]
				cEnt05Ini  := Replicate(" ", nTamEntid)
				cEnt05Fim  := Replicate("Z", nTamEntid)
				oContent:GetJsonValue("ent05Inicial", @cEnt05Ini)		
				oContent:GetJsonValue("ent05Final", @cEnt05Fim)
			EndIf
			If CT2->(FieldPos("CT2_EC06CR")) > 0
				nTamEntid  := TamSX3('CT2_EC06CR')[01]
				cEnt06Ini  := Replicate(" ", nTamEntid)
				cEnt06Fim  := Replicate("Z", nTamEntid)
				oContent:GetJsonValue("ent06Inicial", @cEnt06Ini)
				oContent:GetJsonValue("ent06Final", @cEnt06Fim)		
			EndIf	
			If CT2->(FieldPos("CT2_EC07CR")) > 0		
				nTamEntid  := TamSX3('CT2_EC07CR')[01]
				cEnt07Ini  := Replicate(" ", nTamEntid)
				cEnt07Fim  := Replicate("Z", nTamEntid)
				oContent:GetJsonValue("ent07Inicial", @cEnt07Ini)
				oContent:GetJsonValue("ent07Final", @cEnt07Fim)	
			EndIf
			If CT2->(FieldPos("CT2_EC08CR")) > 0
				nTamEntid  := TamSX3('CT2_EC08CR')[01]
				cEnt08Ini  := Replicate(" ", nTamEntid)
				cEnt08Fim  := Replicate("Z", nTamEntid)
				oContent:GetJsonValue("ent08Inicial", @cEnt08Ini)	
				oContent:GetJsonValue("ent08Final", @cEnt08Fim)	
			EndIf	
			If CT2->(FieldPos("CT2_EC09CR")) > 0
				nTamEntid  := TamSX3('CT2_EC09CR')[01]
				cEnt09Ini  := Replicate(" ", nTamEntid)
				cEnt09Fim  := Replicate("Z", nTamEntid)
				oContent:GetJsonValue("ent09Inicial", @cEnt09Ini)
				oContent:GetJsonValue("ent09Final", @cEnt09Fim)
			EndIf

			oContent:GetJsonValue("moeda", @cMoeda)
			oContent:GetJsonValue("tpsaldo", @cTpSaldo)
		
			StartJob("CTR040Bal", GetEnvServer(), .T., {cId, cTenantId, cEmpresa, cFilIni, cFilFim, ;
				cDataIni, cDataFim, cContaIni, cContaFim, cCustoIni, cCustoFim, ;
				cItemIni, cItemFim, cClasseIn, cClasseFi, ;
				cEnt05Ini, cEnt05Fim, cEnt06Ini, cEnt06Fim, cEnt07Ini, cEnt07Fim, ;
				cEnt08Ini, cEnt08Fim, cEnt09Ini, cEnt09Fim, ;
				cMoeda, cTpSaldo, cBalancet, cCenario, 8000/*nLimit*/, lAnalitic})
		Else
			cResp:= SetErr040S(oRest["message"])
			respGsp(cId,cResp,cTenantId, ,cBalancet, cCenario,cDataIni,cDataFim, , 1/*nPage*/, 1/*nTotalPgs*/)
		EndIf
	Else
		If lIndicator
			oRest:=BalnVldPrm(oContent, aFils)
			oContent:GetJsonValue("FILIAL_INDICADOR", @cFilIndic)
			If oRest["isok"]== .T.
				If Empty(aFils)
					aFils := StrTokArr(oContent["FILIAL"], ";")
				EndIf
				For nI := 1 To Len(aFils)
					cFiliais += aFils[nI]
					// Adiciona o separador, exceto no ultimo elemento
					If nI < Len(aFils)
						cFiliais += ","
					EndIf
				Next
				cFilIndic := IIf(Empty(cFilIndic),aFils[1],cFilIndic)
				StartJob("CTR040Indic", GetEnvServer(), .T., {cId, cTenantId, oRest["empresa"], ;
					aFils, cFilIndic, cFiliais, oContent["DATA_INICIAL"], oContent["DATA_FINAL"], oContent})
			Else
				cResp:= SetErr040S(oRest["message"])
				respGsp(cId,cResp,cTenantId,,,,oContent["DATA_INICIAL"],oContent["DATA_FINAL"],cFiliais)
			EndIf

		Else
			oJsonRest:=BalnVldPrm(oContent, aFils)
			If oJsonRest["isok"]== .T.
				aHeader   := {} // CABEÇALHO DA REQUISIÇÃO
				cServer   := GetClientIP()
				cUris     := GetPvProfString( "HTTPREST", "URIs", "", GetSrvIniName() )
				nPosVirg  := AT(",",cUris) 
				cPort     := GetPvProfString( "HTTPREST", "PORT", "undefined", GetSrvIniName() ) 
				cRest     := GetPvProfString( Iif(nPosVirg > 0 ,SubStr(cUris,1,nPosVirg),cUris)  , "URL", "" , GetSrvIniName())
				cURI      := "http://" + Iif(Empty(cServer),"127.0.0.1", cServer) + ":" + cPort  // + "/rest") // URI DO SERVIÇO REST
				cResource := IiF(Len(cRest) > 1 ,cRest+"/api/ctb/balance/model1/","/api/ctb/balance/model1/"   )// RECURSO A SER CONSUMIDO
				oRest     := FwRest():New(cURI) // CLIENTE PARA CONSUMO REST
				
				FWLogMsg("INFO", "", "CTBR040S", "", " ", , "Try connect api: " + cURI + cResource , , )

				// PREENCHE CABEÇALHO DA REQUISIÇÃO
				AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
				AAdd(aHeader, "Accept: application/json")
				AAdd(aHeader, "tenantId: "+ oJsonRest["empresa"])
				
				// INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIÇÃO
				oRest:SetPath(cResource)
				
				oRest:SetPostParams(oContent:toJSON( ))

				//REALIZA O MÉTODO POST E VALIDA O RETORNO
				If (oRest:post(aHeader))
					cResp := oRest:GetResult()
					FWLogMsg("INFO", "", "CTBR040S", "", " ", , "CTBR040S SUCCESS " , , )
					respTchFin(cId,SubStr(cResp,3,Len(cResp)-4),cTenantId,cURI+cResource)
				Else
					oJson:FromJson('{"error" : "'+oRest:GetLastError()+'"}')
					cResp := oJson:toJSON()
					FWLogMsg("ERROR", "", "CTBR040S", "", " ", , "Error: "+oRest:GetLastError() , , )
					respTchFin(cId,SubStr(cResp,3,Len(cResp)-4),cTenantId,cURI+cResource)
				EndIf
			Else	
				respTchFin(cId,'Error": "'+FWhttpEncode(oJsonRest["message"]),cTenantId, ' ')
			EndIf
		EndIf
	EndIf
	FreeObj(oContent)
	FreeObj(oRest)

Return lRet

/*/{Protheus.doc} CTR040Bal
Executa o processamento do balancete analitico/sintetico em job isolado,
garantindo que o RpcSetEnv nao contamine a thread do listener do SmartLink.
@type Function
@author TOTVS
@param aData, array, parametros do processamento: {cId, cTenantId, cEmpresa, cFilIni, cFilFim,
       cDataIni, cDataFim, cContaIni, cContaFim, cCustoIni, cCustoFim,
       cItemIni, cItemFim, cClasseIn, cClasseFi,
       cEnt05Ini, cEnt05Fim, cEnt06Ini, cEnt06Fim, cEnt07Ini, cEnt07Fim,
       cEnt08Ini, cEnt08Fim, cEnt09Ini, cEnt09Fim,
       cMoeda, cTpSaldo, cBalancet, cCenario, nLimit, lAnalitic}
/*/
Function CTR040Bal( aData as array )
	Local cId        := aData[1]  as character
	Local cTenantId  := aData[2]  as character
	Local cEmpresa   := aData[3]  as character
	Local cFilIni    := aData[4]  as character
	Local cFilFim    := aData[5]  as character
	Local cDataIni   := aData[6]  as character
	Local cDataFim   := aData[7]  as character
	Local cContaIni  := aData[8]  as character
	Local cContaFim  := aData[9]  as character
	Local cCustoIni  := aData[10] as character
	Local cCustoFim  := aData[11] as character
	Local cItemIni   := aData[12] as character
	Local cItemFim   := aData[13] as character
	Local cClasseIn  := aData[14] as character
	Local cClasseFi  := aData[15] as character
	Local cEnt05Ini  := aData[16] as character
	Local cEnt05Fim  := aData[17] as character
	Local cEnt06Ini  := aData[18] as character
	Local cEnt06Fim  := aData[19] as character
	Local cEnt07Ini  := aData[20] as character
	Local cEnt07Fim  := aData[21] as character
	Local cEnt08Ini  := aData[22] as character
	Local cEnt08Fim  := aData[23] as character
	Local cEnt09Ini  := aData[24] as character
	Local cEnt09Fim  := aData[25] as character
	Local cMoeda     := aData[26] as character
	Local cTpSaldo   := aData[27] as character
	Local cBalancet  := aData[28] as character
	Local cCenario   := aData[29] as character
	Local nLimit     := aData[30] as numeric
	Local lAnalitic  := aData[31] as logical // obrigatorio nunca remover
	Local ctempCon   := "TRBCONN" as character
	Local oJConexao  := JsonObject():new() as object
	Local cResp      := "" as character
	Local nLinha     := 0  as numeric
	Local nLinhaTot  := 0  as numeric
	Local nPage      := 1  as numeric
	Local nTotalReg  := 1  as numeric
	Local nTotalPgs  := 1  as numeric
	Local lNFind     := .F. as logical

	RpcSetType(3)
	If RpcSetEnv(cEmpresa, "",,,'CTB')

		If lAnalitic
			oJConexao := movimContA(@ctempCon,cFilIni,cFilFim,cDataIni,cDataFim,cContaIni,cContaFim,cCustoIni,cCustoFim,cItemIni,cItemFim,cClasseIn,cClasseFi,cEnt05Ini,cEnt05Fim,cEnt06Ini,cEnt06Fim,cEnt07Ini,cEnt07Fim,cEnt08Ini,cEnt08Fim,cEnt09Ini,cEnt09Fim,cMoeda,cTpSaldo)
		Else
			oJConexao := movimContS(@ctempCon,cFilIni,cFilFim,cDataIni,cDataFim,cContaIni,cContaFim,cCustoIni,cCustoFim,cItemIni,cItemFim,cClasseIn,cClasseFi,cEnt05Ini,cEnt05Fim,cEnt06Ini,cEnt06Fim,cEnt07Ini,cEnt07Fim,cEnt08Ini,cEnt08Fim,cEnt09Ini,cEnt09Fim,cMoeda,cTpSaldo)
		EndIf

		If oJConexao["sucesso"]
			cResp := '['
			// Calcula o total de registros
			dbSelectArea(ctempCon)
			nTotalReg := (ctempCon)->(LastRec())
			nTotalPgs := Int(nTotalReg / nLimit)
			lNFind := (ctempCon)->(EOF())
			If lAnalitic
				While (ctempCon)->(!EOF())
					If nLinha > 0
						cResp += ','
					EndIf
					cResp += '{' +CRLF
					cResp += '"FILIAL": "'+(ctempCon)->FILIAL+'",' +CRLF
					cResp += '"MOEDA": "'+Alltrim((ctempCon)->MOEDA)+'",' +CRLF
					cResp += '"TIPO": "'+Alltrim((ctempCon)->TIPO)+'",' +CRLF
					cResp += '"CONTA": "'+Alltrim((ctempCon)->CONTA)+'",' +CRLF
					cResp += '"CENTRO_CUSTO": "'+Alltrim((ctempCon)->CENTRO_CUSTO)+'",' +CRLF
					cResp += '"ITEM_CONTABIL": "'+Alltrim((ctempCon)->ITEM_CONTABIL)+'",' +CRLF
					cResp += '"CLASSE_VALOR": "'+Alltrim((ctempCon)->CLASSE_VALOR)+'",' +CRLF
					cResp += '"DDATA": "'+Alltrim((ctempCon)->DDATA)+'",' +CRLF
					cResp += '"TPSALD": "'+Alltrim((ctempCon)->TPSALD)+'",' +CRLF
					cResp += '"DC": "'+Alltrim((ctempCon)->DC)+'",' +CRLF
					cResp += '"LOTE": "'+Alltrim((ctempCon)->LOTE)+'",' +CRLF
					cResp += '"SUBLOTE": "'+Alltrim((ctempCon)->SUBLOTE)+'",' +CRLF
					cResp += '"DOC": "'+Alltrim((ctempCon)->DOC)+'",' +CRLF
					cResp += '"LINHA": "'+Alltrim((ctempCon)->LINHA)+'",' +CRLF
					cResp += '"XPARTIDA": "'+Alltrim((ctempCon)->XPARTIDA)+'",' +CRLF
					cResp += '"HIST": "'+Alltrim((ctempCon)->HIST)+'",' +CRLF
					cResp += '"SEQHIS": "'+Alltrim((ctempCon)->SEQHIS)+'",' +CRLF
					cResp += '"SEQLAN": "'+Alltrim((ctempCon)->SEQLAN)+'",' +CRLF
					cResp += '"EMPORI": "'+Alltrim((ctempCon)->EMPORI)+'",' +CRLF
					cResp += '"FILORI": "'+Alltrim((ctempCon)->FILORI)+'",' +CRLF
					cResp += '"ENT05": "'+Alltrim((ctempCon)->ENT05)+'",' +CRLF
					cResp += '"ENT06": "'+Alltrim((ctempCon)->ENT06)+'",' +CRLF
					cResp += '"ENT07": "'+Alltrim((ctempCon)->ENT07)+'",' +CRLF
					cResp += '"ENT08": "'+Alltrim((ctempCon)->ENT08)+'",' +CRLF
					cResp += '"ENT09": "'+Alltrim((ctempCon)->ENT09)+'",' +CRLF
					cResp += '"VALOR": "'+cValToChar((ctempCon)->SALDO)+'",' +CRLF
					If Alltrim((ctempCon)->TIPO) =='1'
						cResp += '"IDLANC": "'+(ctempCon)->MSUIDT+'D",' +CRLF
					Else
						cResp += '"IDLANC": "'+(ctempCon)->MSUIDT+'C",' +CRLF
					EndIf
					cResp += '"DELETADO": "'+(ctempCon)->DELETADO+'"' +CRLF
					cResp += '}'
					nLinha++

					// Se atingiu o limite de registros no arquivo json, fecha e envia
					If nLinha >= nLimit
						cResp += "]"
						respGsp(cId, cResp, cTenantId, , cBalancet, cCenario, cDataIni, cDataFim, , nPage, nTotalPgs)

						// Reinicia acumulador
						cResp := "["
						nLinhaTot := nLinhaTot + nLinha
						nLinha := 0
						nPage++
					EndIf
					(ctempCon)->(DbSkip())
				End
			Else
				While (ctempCon)->(!EOF())
					If nLinha > 0
						cResp += ','
					EndIf
					cResp += '{' +CRLF
						cResp += '"FILIAL": "'+Alltrim((ctempCon)->FILIAL)+'",' +CRLF
						cResp += '"MOEDA": "'+Alltrim((ctempCon)->MOEDA)+'",' +CRLF
						cResp += '"CONTA": "'+Alltrim((ctempCon)->CONTA)+'",' +CRLF
						cResp += '"CENTRO_CUSTO": "'+Alltrim((ctempCon)->CENTRO_CUSTO)+'",' +CRLF
						cResp += '"ITEM_CONTABIL": "'+Alltrim((ctempCon)->ITEM_CONTABIL)+'",' +CRLF
						cResp += '"CLASSE_VALOR": "'+Alltrim((ctempCon)->CLASSE_VALOR)+'",' +CRLF
						cResp += '"ENT05": "'+Alltrim((ctempCon)->ENT05)+'",' +CRLF
						cResp += '"ENT06": "'+Alltrim((ctempCon)->ENT06)+'",' +CRLF
						cResp += '"ENT07": "'+Alltrim((ctempCon)->ENT07)+'",' +CRLF
						cResp += '"ENT08": "'+Alltrim((ctempCon)->ENT08)+'",' +CRLF
						cResp += '"ENT09": "'+Alltrim((ctempCon)->ENT09)+'",' +CRLF
						cResp += '"SALDO": "'+cValToChar((ctempCon)->SALDO)+'",' +CRLF
						cResp += '"DELETADO": "'+(ctempCon)->DELETADO+'"' +CRLF
					cResp += '}'
					nLinha++

					// Se atingiu o limite de registros no arquivo json, fecha e envia
					If nLinha >= nLimit
						cResp += "]"
						respGsp(cId, cResp, cTenantId, , cBalancet, cCenario, cDataIni, cDataFim, ,nPage, nTotalPgs)

						// Reinicia acumulador
						cResp := "["
						nLinhaTot := nLinhaTot + nLinha
						nLinha := 0
						nPage++
					EndIf
				(ctempCon)->(DbSkip())
				EndDo
			EndIf
			// envia o ultimo arquivo json se sobrou algo
			If nLinha > 0 .or. lNFind
				cResp += "]"
				respGsp(cId, cResp, cTenantId, , cBalancet, cCenario, cDataIni, cDataFim, , nPage, nTotalPgs)
			EndIf
			nLinhaTot := nLinhaTot + nLinha
			(ctempCon)->(DBCLOSEAREA())
		EndIf
		
		RpcClearEnv()
	EndIf

Return

/*/{Protheus.doc} CTR040Indic
Executa o processamento dos indicadores em job isolado,
garantindo que o RpcSetEnv nao contamine a thread do listener do SmartLink.
@type Function
@author TOTVS
@param aData, array, parametros do processamento: {cId, cTenantId, cEmpresa, aFils,
       cFilIndic, cFiliais, cDataIni, cDataFim, oContent}
/*/
Function CTR040Indic( aData as array )
	Local cId       := aData[1] as character
	Local cTenantId := aData[2] as character
	Local cEmpresa  := aData[3] as character
	Local aFils     := aData[4] as array
	Local cFilIndic := aData[5] as character
	Local cFiliais  := aData[6] as character
	Local cDataIni  := aData[7] as character
	Local cDataFim  := aData[8] as character
	Local oContent  := aData[9] as object
	Local cResp     := ""       as character

	RpcSetType(3)
	If RpcSetEnv(cEmpresa, cFilIndic,,,'CTB')

		cResp += getAllGsp(oContent, aFils)
		respGsp(cId, cResp, cTenantId,,,, cDataIni, cDataFim, cFiliais)
		
		RpcClearEnv()
	EndIf
Return

Static Function SetErr040S(cmessage as character)
	Local cResp as character
	Default cmessage := ""
	cResp := ' {' +CRLF 
	cResp += '"error" : "'+cmessage+'"'+CRLF
	cResp += '} '
	cResp:= FWhttpEncode(cResp)	

Return cResp

/*/{Protheus.doc} respTchFin
Envia a resposta de consulta de Balancete TchFin ao barramento TOTVS Link,
montando a mensagem no formato CloudEvents (specversion 1.0) e publicando-a
via FwTotvsLinkClient na audience "PrtBalanResp".
@type function
@author Thiago Alves
@since 30/07/2026
@param cId, character, Identificador da mensagem de origem (correlationId)
@param cResp, character, Payload de dados da resposta (conteudo JSON serializado)
@param cTenantId, character, Identificador do tenant/empresa
@param cRest, character, Endpoint REST completo que originou a requisicao (URI + resource)
@return NIL, Nao retorna valor
@see FwTotvsLinkClient
@obs O campo "id" recebe valor vazio quando cId nao for informado (DEFAULT "").
     A linha de encode HTTP (FWhttpEncode) esta comentada intencionalmente.
/*/
Static Function respTchFin(cId,cResp,cTenantId,cRest)
	Local oClient as object
	Local cMessage as character
	Local lSuccess as logical
	local cStamp := FWTimeStamp(5, DATE(), TIME())

	DEFAULT cId := ""
	oClient := FwTotvsLinkClient():New()

	BeginContent Var cMessage
	{
	"specversion": "1.0",
	"time": "%Exp:cStamp%" ,
	"type": "PrtBalanResp",
	"tenantId": "%Exp:cTenantId%" ,
	"restEnd": "%Exp:cRest%" ,
	"id": "%Exp:cId%",
	"data": { "%Exp:cResp%" }
	}
	EndContent
	// cMessage := FWhttpEncode(cMessage)
	lSuccess := oClient:SendAudience("PrtBalanResp","LinkProxy", cMessage)

Return

Static Function respGsp(cId,cResp,cTenantId,aSelfil, cBalancet, cCenario,cDataini,cDatafim,cFiliais, nPage, nTotalPgs)
	Local oClient as object
	Local cMessage as character
	Local cStamp := FWTimeStamp(5, DATE(), TIME())
	Local lSuccess as logical
	
	DEFAULT cBalancet 	:= "" 
	DEFAULT cCenario   	:= ""
	DEFAULT cId 		:= ""
	DEFAULT cDataini    := "" 
	DEFAULT cDatafim    := ""
	DEFAULT cFiliais    := ""
	DEFAULT nPage       := 1
	DEFAULT nTotalPgs := 1

	oClient := FwTotvsLinkClient():New()
	If !empty(cBalancet)
		BeginContent Var cMessage
		{
		"specversion": "1.0",
		"time": "%Exp:cStamp%" ,
		"type": "PrtBalanResp",
		"tenantId": "%Exp:cTenantId%" ,
		"id": "%Exp:cId%",
		"balancete": "%Exp:cBalancet%", 
		"cenario": "%Exp:cCenario%", 
		"data_inicial" :"%Exp:cDataini%",
		"data_final" :"%Exp:cDatafim%",
		"data": "%Exp:cResp%" 
		}
		EndContent
	Else
		BeginContent Var cMessage
		{
		"specversion": "1.0",
		"time": "%Exp:cStamp%" ,
		"type": "PrtBalanResp",
		"tenantId": "%Exp:cTenantId%" ,
		"id": "%Exp:cId%",
		"branch" :"%Exp:cFiliais%",
		"data_inicial" :"%Exp:cDataini%",
		"data_final" :"%Exp:cDatafim%",
		"data": "%Exp:cResp%" 
		}
		EndContent
	EndIf

	cMessage := StrTran(cMessage, '"[', "[")
	cMessage := StrTran(cMessage, ']"', "]")
	cMessage := StrTran(cMessage, '""e', '"e')
	cMessage := StrTran(cMessage, '"" {', '" {')
	cMessage := StrTran(cMessage, '"" }', '" }')
	cMessage := StrTran(cMessage, '" {', '{')
	cMessage := StrTran(cMessage, '} "', '}')
	
	lSuccess := oClient:SendAudience("PrtBalanResp","LinkProxy", cMessage)

Return

//transformar em genericas

Static Function getAllGsp( oJBody as json,  aFils as array )
	local afieldAPI		as array
	local cArqTmp		as character
	local cWhere        as character
	local cQryField		as character
	local cTableNa		as character
	local aArea 		as array
	local cQuery   as character
	Local cAliasQry as character 
	Local nLinha  as numeric
	Local cResp as character 
	Local oQryEvent as object
	
	cWhere 		 := ""
	cQryField	 := ""
	cArqTmp		 := "" 
	aArea 		 := fwGetArea()

	Ctr040GetDt(oJBody,aFils , @cTableNa,@cArqTmp)

	afieldAPI := getFldGesp()

	aEval( aFieldAPI, {|aCampo| cQryField += aCampo[1] +", "})
	cQryField := substr( cQryField, 1, len(cQryField)-2)

	// CA2050: cTableNa (origem: Ctr040GetDt — identificador de tabela interna, não entrada de usuário)
	// CA2050: cQryField (origem: getFldGesp() — lista de colunas internas, não entrada de usuário)
	// NOSONAR
	cQuery:= " SELECT  " + cQryField + " FROM " + cTableNa + " WHERE "

	cwhere := " CONTA <> ' ' "

	cQuery += cwhere + " ORDER BY CONTA"
	cQuery := ChangeQuery(cQuery)
	oQryEvent := FwExecStatement():New(cQuery)
	cAliasQry := oQryEvent:OpenAlias(GetNextAlias())
	nLinha := 0
	cResp := '['
	WHILE (cAliasQry)->( !EOF() )
		If nLinha > 0
			cResp += ','
		EndIf
		cResp += '{' +CRLF
			cResp += '"codigo_externo": "'+(cAliasQry)->CONTA+'",' +CRLF
			cResp += '"saldo_anterior": '+cValToChar((cAliasQry)->SALDOANT)+',' +CRLF
			cResp += '"debito": '+cValToChar((cAliasQry)->SALDODEB)+',' +CRLF
			cResp += '"credito": '+cValToChar((cAliasQry)->SALDOCRD)+',' +CRLF
			cResp += '"saldo_atual": '+cValToChar((cAliasQry)->SALDOATU) +CRLF
		cResp += '}'
		nLinha++
		(cAliasQry)->(dbSkip())
	ENDDO
	cResp += ']'

	(cAliasQry)->(dbCloseArea())
	CTBGerClean()
	oQryEvent:Destroy()
	restArea(aArea)
return cResp
