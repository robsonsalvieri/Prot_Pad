#INCLUDE "Protheus.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "TBICONN.ch"

//+++++++INTEGRAÇÃO PROTHEUS GESPLAN LANÇAMENTO CONTÁBIL CTBA102 ++++++++//


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
    Local aHeader   := {} as array
	Local cResp 	:= "" as character
	Local oContent 	:= JsonObject():new()
	Local oJson 	:= JsonObject():new()
	Local lRet 		:= .T. as logical
	Local cId 		:= "" as character
	Local lIndicators := .F. as logical
	Local lAnalitico  := .F. as logical
	Local lSintetico  := .F. as logical
	Local ctempCon 	  := "TRBCONN" as character
	Local oJConexao	  :=  JsonObject():new() as object
	Local nLinha 	  := 0 as numeric
	Local cBalancete  := "" as character
	Local cCenario    := "" as character
	Local aFils       :={}
	Local cFiliais 	  := "" as character
	Local nI		  := 0  as numeric
	Local cDfDtIni    := DTOS(FirstDay(DATE()))
	Local cDfDtFim    := DTOS(LastDay(DATE()))
	Local cFilIni 	  := "" as character
	Local cFilFim 	  := "" as character
	Local cEmpresa 	  := "" as character
	Local cDataIni 	  := "" as character
	Local cDataFim 	  := "" as character
	Local cContaIni   := "" as character 
	Local cContaFim   := "" as character 
	Local cCCustoIni  := "" as character 
	Local cCCustoFim  := "" as character
	Local cItemIni    := "" as character
	Local cItemFim    := "" as character
	Local cClasseIni  := "" as character
	Local cClasseFim  := "" as character
	Local cEnt05Ini   := "" as character
	Local cEnt05Fim   := "" as character
	Local cEnt06Ini   := "" as character
	Local cEnt06Fim   := "" as character
	Local cEnt07Ini   := "" as character
	Local cEnt07Fim   := "" as character
	Local cEnt08Ini   := "" as character
	Local cEnt08Fim   := "" as character
	Local cEnt09Ini   := "" as character
	Local cEnt09Fim   := "" as character
	Local cTenantId   := "" as character
	Local cFilIndic   := "" as character

	oContent:FromJSON(oLinkMessage:RawMessage())
    cTenantId 	:= oContent['tenantId']
    oContent 	:= oContent['data']
	cId 		:= oContent['id']
	lIndicators := oContent['INDICADORES'] == 1
	lAnalitico  := oContent['BALANCETE'] == 1
	lSintetico  := oContent['BALANCETE'] == 2

	If lAnalitico .OR. lSintetico
		
		cBalancete := cValToChar(oContent["BALANCETE"])
		cCenario   := oContent["CENARIO"]	
		cEmpresa   := oContent["empresa"]
		oContent:GetJsonValue("empresa", @cEmpresa)
		oContent:GetJsonValue("CENARIO", @cCenario)
		oContent:GetJsonValue("filialInicial", @cFilIni)
		cFilFim    := iif(empty(oContent["filialFinal"]),Replicate("Z", TamSX3('CT2_FILIAL')[01]),oContent["filialFinal"])
		cDataIni   := iif(empty(oContent["dataInicial"]),SUBSTR(cDfDtIni, 7,2)+'/'+SUBSTR(cDfDtIni, 5,2)+'/'+SUBSTR(cDfDtIni, 0,4),oContent["dataInicial"])
		cDataFim   := iif(empty(oContent["dataFinal"]),SUBSTR(cDfDtFim, 7,2)+'/'+SUBSTR(cDfDtFim, 5,2)+'/'+SUBSTR(cDfDtFim, 0,4),oContent["dataFinal"])
		oContent:GetJsonValue("contaInicial", @cContaIni)
		cContaFim  := iif(empty(oContent["contaFinal"]),Replicate("Z", TamSX3('CT2_CREDIT')[01]),oContent["contaFinal"])
		oContent:GetJsonValue("cCustoInicial", @cCCustoIni)
		cCCustoFim := iif(empty(oContent["cCustoFinal"]),Replicate("Z", TamSX3('CT2_CCC')[01]),oContent["cCustoFinal"])
		oContent:GetJsonValue("itemInicial", @cItemIni)
		cItemFim   := iif(empty(oContent["itemFinal"]),Replicate("Z", TamSX3('CT2_ITEMC')[01]),oContent["itemFinal"])
		oContent:GetJsonValue("classeInicial", @cClasseIni)
		cClasseFim := iif(empty(oContent["classeFinal"]),Replicate("Z", TamSX3('CT2_CLVLCR')[01]),oContent["classeFinal"])
		oContent:GetJsonValue("ent05Inicial", @cEnt05Ini)	
		cEnt05Fim  := iif(empty(oContent["ent05Final"]),Replicate("Z", TamSX3('CT2_EC05CR')[01]),oContent["ent05Final"])
		oContent:GetJsonValue("ent06Inicial", @cEnt06Ini)
		cEnt06Fim  := iif(empty(oContent["ent06Final"]),Replicate("Z", TamSX3('CT2_EC06CR')[01]),oContent["ent06Final"])		
		oContent:GetJsonValue("ent07Inicial", @cEnt07Ini)	
		cEnt07Fim  := iif(empty(oContent["ent07Final"]),Replicate("Z", TamSX3('CT2_EC07CR')[01]),oContent["ent07Final"])	
		oContent:GetJsonValue("ent08Inicial", @cEnt08Ini)	
		cEnt08Fim  := iif(empty(oContent["ent08Final"]),Replicate("Z", TamSX3('CT2_EC08CR')[01]),oContent["ent08Final"])	
		oContent:GetJsonValue("ent09Inicial", @cEnt09Ini)	
		cEnt09Fim  := iif(empty(oContent["ent09Final"]),Replicate("Z", TamSX3('CT2_EC09CR')[01]),oContent["ent09Final"])

		oRest := BalanVldEmp(cEmpresa)
		If oRest["isok"]== .T.
			If cEmpresa <> cEmpAnt
				RpcSetType(3)
				RpcClearEnv()
				RpcSetEnv(cEmpresa, cFilIni,,,'CTB')
			endIf
			
			If lAnalitico
				oJConexao := movimContA(@ctempCon, cEmpresa,cFilIni,cFilFim,cDataIni,cDataFim,cContaIni,cContaFim,cCCustoIni,cCCustoFim,cItemIni,cItemFim,cClasseIni,cClasseFim,cEnt05Ini,cEnt05Fim,cEnt06Ini,cEnt06Fim,cEnt07Ini,cEnt07Fim,cEnt08Ini,cEnt08Fim,cEnt09Ini,cEnt09Fim)
			Else
				oJConexao := movimContS(@ctempCon, cEmpresa,cFilIni,cFilFim,cDataIni,cDataFim,cContaIni,cContaFim,cCCustoIni,cCCustoFim,cItemIni,cItemFim,cClasseIni,cClasseFim,cEnt05Ini,cEnt05Fim,cEnt06Ini,cEnt06Fim,cEnt07Ini,cEnt07Fim,cEnt08Ini,cEnt08Fim,cEnt09Ini,cEnt09Fim)
			EndIf
			If oJConexao["sucesso"]
				cResp := '['
				If lAnalitico
					While (ctempCon)->(!EOF())
						If nLinha > 0
							cResp += ','
						EndIf
						cResp += '{' +CRLF
						cResp += '"FILIAL": "'+(ctempCon)->FILIAL+'",' +CRLF
						cResp += '"ANO": "'+(ctempCon)->ANO+'",' +CRLF
						cResp += '"MES": "'+(ctempCon)->MES+'",' +CRLF
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
						cResp += '"IDLANC": "'+(ctempCon)->MSUIDT+'",' +CRLF
						cResp += '"DELETADO": "'+(ctempCon)->DELETADO+'"' +CRLF
						cResp += '}'
						nLinha++
						(ctempCon)->(DbSkip())
					End
				Else
					While (ctempCon)->(!EOF())
						If nLinha > 0
							cResp += ','
						EndIf
						cResp += '{' +CRLF
							cResp += '"FILIAL": "'+Alltrim((ctempCon)->FILIAL)+'",' +CRLF
							cResp += '"ANO": "'+(ctempCon)->ANO+'",' +CRLF
							cResp += '"MES": "'+(ctempCon)->MES+'",' +CRLF
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
					(ctempCon)->(DbSkip())
					EndDo
				EndIf
				cResp += ']'
				(ctempCon)->(DBCLOSEAREA())
				respGsp(cId,cResp,cTenantId, ,cBalancete, cCenario,cDataIni,cDataFim)
			EndIf
		Else
			cResp:= SetError040S(oRest["message"])
			respGsp(cId,cResp,cTenantId, ,cBalancete, cCenario,cDataIni,cDataFim)
		EndIf
	Else
		If lIndicators
			oRest:=BalanVldPrms(oContent, aFils)
			oContent:GetJsonValue("FILIAL_INDICADOR", @cFilIndic)
			If oRest["isok"]== .T.
				If Empty(aFils)
					aFils := StrTokArr(oContent["FILIAL"], ";")
				EndIf
				For nI := 1 To Len(aFils)
					cFiliais += aFils[nI]
					// Adiciona o separador, exceto no último elemento
					If nI < Len(aFils)
						cFiliais += ","
					EndIf
				Next
				If oRest["empresa"] <> cEmpAnt
					RpcSetType(3)
					RpcClearEnv()
					RpcSetEnv( oRest["empresa"] , aFils[1],,, 'CTB')
				EndIf
				cFilIndic:= IIf(Empty(cFilIndic),aFils[1],cFilIndic)
				If cFilIndic <> cFilant
					cFilAnt := cFilIndic
				EndIf
				cResp +=  getAllGesp(oContent,, aFils)
			Else
				cResp:= SetError040S(oRest["message"])
			EndIf
			
			respGsp(cId,cResp,cTenantId,,,,oContent["DATA_INICIAL"],oContent["DATA_FINAL"],cFiliais)

		Else
			cServer   := GetClientIP()
			cUris     := GetPvProfString( "HTTPREST", "URIs", "", GetSrvIniName() )
			nPosVirg  := AT(",",cUris) 
			cPort     := GetPvProfString( "HTTPREST", "PORT", "undefined", GetSrvIniName() ) 
			cRest     := GetPvProfString( Iif(nPosVirg > 0 ,SubStr(cUris,1,nPosVirg),cUris)  , "URL", "" , GetSrvIniName())
			cURI      := "http://" + Iif(Empty(cServer),"127.0.0.1", cServer) + ":" + cPort  // + "/rest") // URI DO SERVIÇO REST
			cResource := IiF(Len(cRest) > 1 ,cRest+"/api/ctb/balance/model1/","/api/ctb/balance/model1/"   )// RECURSO A SER CONSUMIDO
			oRest     := FwRest():New(cURI) // CLIENTE PARA CONSUMO REST
			aHeader   := {} // CABEÇALHO DA REQUISIÇÃO
			FWLogMsg("INFO", "", "CTBR040S", "", " ", , "Try connect api: " + cURI + cResource , , )

			// PREENCHE CABEÇALHO DA REQUISIÇÃO
			AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
			AAdd(aHeader, "Accept: application/json")
			// AAdd(aHeader, "tenantId: T1,D MG 01 ")

			// INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIÇÃO
			oRest:SetPath(cResource)
			
			oRest:SetPostParams(oContent:toJSON( ))

			//REALIZA O MÉTODO POST E VALIDA O RETORNO
			If (oRest:post(aHeader))
				cResp := oRest:GetResult()
				FWLogMsg("INFO", "", "CTBR040S", "", " ", , "CTBR040S SUCCESS " , , )
				respTechfin(cId,SubStr(cResp,3,Len(cResp)-4),cTenantId,cURI+cResource)
			Else
				oJson:FromJson('{"error" : "'+oRest:GetLastError()+'"}')
				cResp := oJson:toJSON()
				FWLogMsg("ERROR", "", "CTBR040S", "", " ", , "Error: "+oRest:GetLastError() , , )
				respTechfin(cId,SubStr(cResp,3,Len(cResp)-4),cTenantId,cURI+cResource)
			EndIf
		EndIf
		
		FreeObj(oContent)
		FreeObj(oRest)
	EndIf
Return lRet

Static Function SetError040S(cmessage as character)
	Local cResp as character
	Default cmessage := ""
	cResp := ' {' +CRLF 
	cResp += '"error" : "'+cmessage+'"'+CRLF
	cResp += '} '
	cResp:= FWhttpEncode(cResp)	

Return cResp

Static Function respTechfin(cId,cResp,cTenantId,cRest)
	Local oClient as object
	Local cMessage as character
	Local lSuccess as logical
	local cTimestamp := FWTimeStamp(5, DATE(), TIME())

	DEFAULT cId := ""
	oClient := FwTotvsLinkClient():New()

	BeginContent Var cMessage
	{
	"specversion": "1.0",
	"time": "%Exp:cTimestamp%" ,
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

Static Function respGsp(cId,cResp,cTenantId,aSelfil, cBalancete, cCenario,cDataini,cDatafim,cFiliais)
	Local oClient as object
	Local cMessage as character
	Local cTimestamp := FWTimeStamp(5, DATE(), TIME())
	
	DEFAULT cBalancete := "" 
	DEFAULT cCenario   := ""
	DEFAULT cId := ""
	DEFAULT cDataini := "" 
	DEFAULT cDatafim   := ""
	DEFAULT cFiliais := ""

	oClient := FwTotvsLinkClient():New()
	If !empty(cBalancete)
		BeginContent Var cMessage
		{
		"specversion": "1.0",
		"time": "%Exp:cTimestamp%" ,
		"type": "PrtBalanResp",
		"tenantId": "%Exp:cTenantId%" ,
		"id": "%Exp:cId%",
		"balancete": "%Exp:cBalancete%", 
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
		"time": "%Exp:cTimestamp%" ,
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

Static Function getAllGesp( oJBody as json, aUrlFilter as array, aFils as array )
	local afieldAPI		as array
	local cArqTmp		as character
	local cWhere        as character
	local cQryFields	as character
	local cSubQryField	as character
	local cTableNam1	as character
	local aArea 		as array
	local nImprContas   as numeric
	local cQuery   as character
	Local cAliasQry as character 
	Local nLinha  as numeric
	Local cResp as character 
	
	cWhere 		 := ""
	cQryFields	 := ""
	cSubQryField := ""
	cArqTmp		 := "" 
	aArea 		 := fwGetArea()

	Ctr040getData(oJBody,aFils , @cTableNam1,@cArqTmp)

	afieldAPI := getfieldReturnGesp()

	aEval( aFieldAPI, {|aCampo| cQryFields += aCampo[1] +", "})
	cQryFields := substr( cQryFields, 1, len(cQryFields)-2)

	cQuery:= " SELECT  " + cQryFields + " FROM " + cTableNam1 + " WHERE "

	cwhere := " CONTA <> ' ' "
	cwhere += iif( (nImprContas == 1 .or. nImprContas == 2), " AND TIPOCONTA = '" + cValToChar(nImprContas) + "' ", "")

	cQuery += cwhere + " ORDER BY CONTA"
	cQuery := ChangeQuery(cQuery)
	__queryEvent := FwExecStatement():New(cQuery)

	cAliasQry := __queryEvent:OpenAlias(GetNextAlias())
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
	
	restArea(aArea)
return cResp
