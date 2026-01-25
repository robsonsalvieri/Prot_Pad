#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"

#DEFINE LIMPEZA_TOTAL     1
#DEFINE LIMPEZA_MANUAL    2
#DEFINE LIMPEZA_POR_DATAS 3

Static _nTamSetp := Nil

/*/{Protheus.doc} PCPA152PRC
Processamento Programação da Produção

@type  WSCLASS
@author Lucas Fagundes
@since 01/02/2023
@version P12
/*/
WSRESTFUL PCPA152PRC DESCRIPTION STR0001 FORMAT APPLICATION_JSON // "Processamento Programação da Produção"
	WSDATA atual       AS BOOLEAN OPTIONAL
	WSDATA filtering   AS BOOLEAN OPTIONAL
	WSDATA page        AS INTEGER OPTIONAL
	WSDATA pageSize    AS INTEGER OPTIONAL
	WSDATA descricao   AS STRING  OPTIONAL
	WSDATA filter      AS STRING  OPTIONAL
	WSDATA programacao AS STRING  OPTIONAL

	WSMETHOD POST START;
		DESCRIPTION STR0002; // "Inicia processamento da programação da produção";
		WSSYNTAX "/api/pcp/v1/pcpa152prc/start" ;
		PATH "/api/pcp/v1/pcpa152prc/start" ;
		TTALK "v1"

	WSMETHOD GET STATUS;
		DESCRIPTION STR0003; // "Retorna o status de uma programação";
		WSSYNTAX "/api/pcp/v1/pcpa152prc/status/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152prc/status/{programacao}" ;
		TTALK "v1"

	WSMETHOD POST CANCEL;
		DESCRIPTION STR0085; //"Cancela o processamento da programação"
		WSSYNTAX "/api/pcp/v1/pcpa152prc/cancel/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152prc/cancel/{programacao}" ;
		TTALK "v1"

	WSMETHOD POST CONTINUAR;
		DESCRIPTION STR0137; // "Continua o processamento de uma programação"
		WSSYNTAX "/api/pcp/v1/pcpa152prc/continuar/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152prc/continuar/{programacao}" ;
		TTALK "v1"

	WSMETHOD GET SETUP;
		DESCRIPTION STR0206; // "Retorna os setups das programações"
		WSSYNTAX "/api/pcp/v1/pcpa152prc/setup" ;
		PATH "/api/pcp/v1/pcpa152prc/setup" ;
		TTALK "v1"

	WSMETHOD POST CLEAN;
		DESCRIPTION STR0260; // "Limpar programações"
		WSSYNTAX "/api/pcp/v1/pcpa152prc/clean" ;
		PATH "/api/pcp/v1/pcpa152prc/clean" ;
		TTALK "v1"

	WSMETHOD POST REPROCESSAR;
		DESCRIPTION STR0376; // "Reprocessa uma programação"
		WSSYNTAX "/api/pcp/v1/pcpa152prc/reprocessar/{programacao}" ;
		PATH "/api/pcp/v1/pcpa152prc/reprocessar/{programacao}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} POST START /api/pcp/v1/pcpa152prc/start
"Inicia processamento da programação da produção"

@type  WSMETHOD
@author Lucas Fagundes
@since 01/02/2023
@version P12
@return lReturn, Logico, Indica se teve sucesso na requisição.
/*/
WSMETHOD POST START WSSERVICE PCPA152PRC
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local cBody     := ""
	Local lReturn   := .T.
	Local oBody     := Nil

	Self:SetContentType("application/json")

	cBody := DecodeUTF8(Self:getContent())

	oBody := JsonObject():New()
	oBody:FromJson(cBody)

	BEGIN SEQUENCE
		aReturn := processa(oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FwFreeObj(oBody)
Return lReturn

/*/{Protheus.doc} processa
Função responsavel por iniciar o processamento

@type  Static Function
@author Lucas Fagundes
@since 01/02/2023
@version P12
@param oStart, Object, Json com o parâmetros para execução do programa.
@return aReturn, Array, Array com as informações para o retorno do rest.
/*/
Static Function processa(oStart)
	Local aError    := {}
	Local aReturn   := Array(3)
	Local oProcesso := Nil
	Local oRetorno  := JsonObject():New()

	oProcesso := PCPA152Process():executaProgramacao(Nil, oStart, .F.)

	If oProcesso:oProcError:possuiErro()
		aError := oProcesso:oProcError:getaError()

		oRetorno["message"        ] := aError[1][2]
		oRetorno["detailedMessage"] := aError[1][3]

		aReturn[1] := .F.
		aReturn[2] := 500
		aReturn[3] := oRetorno:toJson()

		FwFreeArray(aError)
		oProcesso:oProcError:destroy()
	Else
		oRetorno["items"  ] := P152GetSta(oProcesso:retornaProgramacao())
		oRetorno["hasNext"] := .F.

		If oProcesso:retornaParametro("MV_LOGCRP")
			oRetorno["_messages"] := {JsonObject():New()}
			oRetorno["_messages"][1]["message"        ] := STR0461 //"Processamento com geração de log, o desempenho será prejudicado."
			oRetorno["_messages"][1]["type"           ] := "warning"
			oRetorno["_messages"][1]["detailedMessage"] := STR0462 //"O parâmetro MV_LOGCRP está ligado e, por isso, o desempenho da rotina fica comprometido."
		EndIf

		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oRetorno:toJson()

		oProcesso:destroy()
	EndIf

	FreeObj(oStart)
	FreeObj(oProcesso)
Return aReturn

/*/{Protheus.doc} GET STATUS /api/pcp/v1/pcpa152prc/status/{programacao}
"Retorna o status de uma programação"

@type  WSMETHOD
@author Lucas Fagundes
@since 01/02/2023
@version P12
@param 01 programacao, Caracter, Número da programação
@param 02 atual      , Lógico  , Indica se deve retornar o status somente da etapa atual
@return lReturn      , Lógico  , Indica se teve sucesso na requisição.
/*/
WSMETHOD GET STATUS PATHPARAM programacao QUERYPARAM atual WSSERVICE PCPA152PRC
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getStatus(Self:programacao, Self:atual)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getStatus
Função responsavel por obter o progresso de uma programação.
@type  Function
@author Lucas Fagundes
@since 07/02/2023
@version P12
@param 01 cProg , Caracter, Código da programação que irá buscar.
@param 02 lAtual, Lógico  , Indica se deve retornar o status somente da etapa atual.
@return aReturn, Array, Array com as informações para o retorno do rest.
/*/
Static Function getStatus(cProg, lAtual)
	Local aReturn    := Array(3)
	Local oProgresso := P152GetSta(cProg, lAtual)
	Local oReturn    := JsonObject():New()

	If oProgresso == Nil
		oReturn["message"        ] := STR0005 // "Programação não encontrada"
		oReturn["detailedMessage"] := ""

		aReturn[1] := .F.
		aReturn[2] := 404
		aReturn[3] := oReturn:toJson()
	Else
		oReturn["items"  ] := oProgresso
		oReturn["hasNext"] := .F.

		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	EndIf

	FreeObj(oProgresso)
Return aReturn

/*/{Protheus.doc} P152GetSta
Retorna o status do processamento de uma programação.

@author Lucas Fagundes
@since 06/02/2023
@version P12
@param 01 cProg , Caracter, Código da programação que irá consultar
@param 02 lAtual, Logico  , Indica se deve retornar o status somente da etapa atual.
@return oJsRet, Object, Json com o progresso das etapas
/*/
Function P152GetSta(cProg, lAtual)
	Local cAlias     := GetNextAlias()
	Local cBanco     := TCGetDB()
	Local cQryCondic := ""
	Local cQryFields := ""
	Local cQryOrder  := ""
	Local oJsAux     := Nil
	Local oJsRet     := Nil
	Default lAtual   := .F.

	cQryFields := " T4X.T4X_PROG,"   + ;
	              " T4X.T4X_STATUS," + ;
	              " T4X.T4X_DTINI,"  + ;
	              " T4X.T4X_HRINI,"  + ;
	              " T4X.T4X_DTFIM,"  + ;
	              " T4X.T4X_HRFIM,"  + ;
	              " T4X.T4X_USER,"   + ;
	              " T4Z.T4Z_ETAPA,"  + ;
	              " T4Z.T4Z_SEQ,"    + ;
	              " T4Z.T4Z_STATUS," + ;
	              " T4Z.T4Z_PERCT,"  + ;
	              " T4Z.T4Z_MSG,"    + ;
	              " T4Z.T4Z_DTINI,"  + ;
	              " T4Z.T4Z_HRINI,"  + ;
	              " T4Z.T4Z_DTFIM,"  + ;
	              " T4Z.T4Z_HRFIM,"  + ;
	              " T4Z.R_E_C_N_O_ RECT4Z," + ;
	              " (SELECT COUNT(1) "                                    + ;
	                "  FROM " + RetSqlName("T4Z") + " T4Zb "              + ;
	                " WHERE T4Zb.T4Z_FILIAL = '"  + xFilial("T4Z") + "' " + ;
	                "   AND T4Zb.T4Z_PROG   = '"  + cProg          + "' " + ;
	                "   AND T4Zb.D_E_L_E_T_ = ' ') qtdEtapas, "           + ;
	              " (SELECT SUM(T4Zc.T4Z_PERCT) "                         + ;
	                 " FROM " + RetSqlName("T4Z") + " T4Zc "              + ;
	                " WHERE T4Zc.T4Z_FILIAL = '" + xFilial("T4Z") + "' "  + ;
	                  " AND T4Zc.T4Z_PROG   = '" + cProg          + "' "  + ;
	                  " AND T4Zc.D_E_L_E_T_ = ' ') sumPercentual, "       + ;
	              " T4Z.T4Z_MSGDET "

	cQryCondic := RetSqlName("T4X") + " T4X"                 + ;
	       " LEFT OUTER JOIN " + RetSqlName("T4Z") + " T4Z"  + ;
	         " ON T4Z.T4Z_PROG   = T4X.T4X_PROG"             + ;
	        " AND T4Z.T4Z_FILIAL = '" + xFilial("T4Z") + "'" + ;
	        " AND T4Z.D_E_L_E_T_ = ' '"

	If lAtual
		cQryCondic += " AND (T4Z.T4Z_STATUS = '" + STATUS_EXECUCAO + "' "
		cQryCondic +=      " OR (T4Z.T4Z_STATUS <> '" + STATUS_CONCLUIDO + "' AND NOT EXISTS (SELECT 1 "
		cQryCondic +=                                                                         " FROM " + RetSqlName("T4Z") + " T4Zb "
		cQryCondic +=                                                                        " WHERE T4Zb.T4Z_PROG   = '" + cProg + "' "
		cQryCondic +=                                                                          " AND T4Zb.T4Z_FILIAL = '" + xFilial("T4Z")  + "' "
		cQryCondic +=                                                                          " AND T4Zb.T4Z_STATUS = '" + STATUS_EXECUCAO + "' "
		cQryCondic +=                                                                          " AND T4Zb.D_E_L_E_T_ = ' '))) "
	EndIf

	cQryCondic += " WHERE T4X.T4X_PROG   = '" + cProg          + "'" + ;
	                " AND T4X.T4X_FILIAL = '" + xFilial("T4X") + "'" + ;
	                " AND T4X.D_E_L_E_T_ = ' '"

	cQryOrder := " T4Z.T4Z_SEQ "

	If lAtual
		If Upper(cBanco) $ 'ORACLE'
			cQryCondic += " AND ROWNUM <= 1"
		ElseIf Upper(cBanco) $ 'POSTGRES'
			cQryOrder += " LIMIT 1"
		Else
			cQryFields := " TOP 1 " + cQryFields
		EndIf
	EndIf

	cQryFields := "%" + cQryFields + "%"
	cQryCondic := "%" + cQryCondic + "%"
	cQryOrder  := "%" + cQryOrder  + "%"

	BeginSql Alias cAlias
		%noparser%
		SELECT %Exp:cQryFields%
		  FROM %Exp:cQryCondic%
		 ORDER BY %Exp:cQryOrder%
	EndSql

	If (cAlias)->(!EoF())
		oJsRet := JsonObject():New()
		oJsRet["programacao"] := RTrim((cAlias)->T4X_PROG)
		oJsRet["idStatus"   ] := RTrim((cAlias)->T4X_STATUS)
		oJsRet["status"     ] := PCPA152Process():getDescricaoStatus(oJsRet["idStatus"])
		oJsRet["dataInicial"] := RTrim((cAlias)->T4X_DTINI)
		oJsRet["horaInicial"] := RTrim((cAlias)->T4X_HRINI)
		oJsRet["dataFinal"  ] := RTrim((cAlias)->T4X_DTFIM)
		oJsRet["horaFinal"  ] := RTrim((cAlias)->T4X_HRFIM)
		oJsRet["userId"     ] := RTrim((cAlias)->T4X_USER)
		oJsRet["percentual" ] := Round(((cAlias)->sumPercentual / (cAlias)->qtdEtapas), 2)
		oJsRet["etapas"     ] := {}
	EndIf

	While (cAlias)->(!EoF())
		oJsAux := JsonObject():New()
		oJsAux["etapa"      ] := RTrim((cAlias)->T4Z_ETAPA)
		oJsAux["descEtapa"  ] := PCPA152Process():getDescricaoEtapa(oJsAux["etapa"], (cAlias)->T4X_PROG)
		oJsAux["sequencia"  ] := (cAlias)->T4Z_SEQ
		oJsAux["idStatus"   ] := RTrim((cAlias)->T4Z_STATUS)
		oJsAux["status"     ] := PCPA152Process():getDescricaoStatus(oJsAux["idStatus"], oJsAux["etapa"])
		oJsAux["percentual" ] := Round((cAlias)->T4Z_PERCT, 2)
		oJsAux["mensagem"   ] := RTrim((cAlias)->T4Z_MSG)
		oJsAux["mensagemDet"] := ""
		If !Empty((cAlias)->T4Z_MSGDET)
			T4Z->(dbGoTo((cAlias)->RECT4Z))
			oJsAux["mensagemDet"] := T4Z->T4Z_MSGDET
		EndIf
		oJsAux["dataInicio" ] := SToD((cAlias)->T4Z_DTINI)
		oJsAux["horaInicio" ] := RTrim((cAlias)->T4Z_HRINI)
		oJsAux["dataFim"    ] := SToD((cAlias)->T4Z_DTFIM)
		oJsAux["horaFim"    ] := RTrim((cAlias)->T4Z_HRFIM)

		oJsAux["loadingIndeterminate"] := oJsAux["etapa"] == CHAR_ETAPAS_REDUZ_SETUP
		If oJsAux["loadingIndeterminate"]
			oJsAux["percentual"] := Nil
		EndIf

		aAdd(oJsRet["etapas"], oJsAux)
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return oJsRet

/*/{Protheus.doc} POST CANCEL /api/pcp/v1/pcpa152prc/cancel/{programacao}
Cancela o processamento da programação

@type WSMETHOD
@author Marcelo Neumann
@since 07/03/2023
@version P12
@param programacao, Caracter, Número da programação
@return lReturn   , Lógico  , Indica se teve sucesso na requisição.
/*/
WSMETHOD POST CANCEL PATHPARAM programacao WSSERVICE PCPA152PRC
	Local aReturn   := Array(3)
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local lReturn   := .T.
	Local oProcesso := Nil
	Local oReturn   := JsonObject():New()

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		If PCPA152Process():processamentoFactory(Self:programacao, FACTORY_OPC_BASE, @oProcesso)
			oProcesso:cancelaExecucao()
			oReturn["message"        ] := STR0040 //"Processamento cancelado."
			oReturn["detailedMessage"] := ""

			aReturn[1] := .T.
			aReturn[2] := 200
		Else
			oReturn["message"        ] := STR0316 // "Programação não esta em execução."
			oReturn["detailedMessage"] := ""

			aReturn[1] := .F.
			aReturn[2] := 400
		EndIf
		aReturn[3] := oReturn:toJson()
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	P152ClnStc()
Return lReturn

/*/{Protheus.doc} POST CONTINUAR /api/pcp/v1/pcpa152prc/continuar
Continua o processamento de uma programação.

@type  WSMETHOD
@author Lucas Fagundes
@since 01/02/2023
@version P12
@return lReturn, Logico, Indica se teve sucesso na requisição.
/*/
WSMETHOD POST CONTINUAR PATHPARAM programacao WSSERVICE PCPA152PRC
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local cBody     := ""
	Local lReturn   := .T.
	Local oBody     := Nil

	Self:SetContentType("application/json")

	cBody := DecodeUTF8(Self:getContent())

	oBody := JsonObject():New()
	oBody:FromJson(cBody)

	BEGIN SEQUENCE
		aReturn := continuar(Self:programacao, oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FwFreeObj(oBody)
Return lReturn

/*/{Protheus.doc} continuar
Retoma o processamento de uma programação e inicia o cálculo do tempo das operações.
@type  Static Function
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param oBody, Object, Json com os parâmetros para iniciar o calculo do tempo das operações.
@return aReturn, Array, Array com as informações da requisição
/*/
Static Function continuar(cProg, oBody)
	Local aError    := {}
	Local aReturn   := Array(3)
	Local cMsg      := ""
	Local cMsgDet   := ""
	Local lSucesso  := .T.
	Local nCode     := 0
	Local oProcesso := Nil
	Local oRetorno  := JsonObject():New()

	oProcesso := PCPA152Process():executaProgramacao(cProg, oBody, .F.)

	If oProcesso:oProcError:possuiErro()
		aError := oProcesso:oProcError:getaError()

		cMsg    := aError[1][2]
		cMsgDet := aError[1][3]

		lSucesso := .F.
		nCode    := 500

		FwFreeArray(aError)
		oProcesso:oProcError:destroy()
	Else
		cMsg    := STR0138 // "Cálculo do tempo das operações iniciado com sucesso."
		cMsgDet := ""

		lSucesso := .T.
		nCode    := 200

		oProcesso:destroy()
	EndIf

	oRetorno["message"        ] := cMsg
	oRetorno["detailedMessage"] := cMsgDet

	aReturn[1] := lSucesso
	aReturn[2] := nCode
	aReturn[3] := oRetorno:toJson()

	FreeObj(oProcesso)
	FreeObj(oRetorno)
Return aReturn

/*/{Protheus.doc} GET SETUP /api/pcp/v1/pcpa152prc/setup
Retorna os setups das programações

@type  WSMETHOD
@author Lucas Fagundes
@since 07/06/2023
@version P12
@param 01 filter   , Caracter, Filtro para o código do setup.
@param 02 descricao, Caracter, Filtro para a descrição do setup.
@param 03 page     , Numerico, Pagina que está sendo carregada.
@param 04 pageSize , Numerico, Tamanho da página.
@param 05 filtering, Logico  , Indica que está filtrando os registros cadastrados.
@return lReturn, Logico, Indica se teve sucesso na requisição.
/*/
WSMETHOD GET SETUP QUERYPARAM filter, descricao, page, pageSize, filtering WSSERVICE PCPA152PRC
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local lReturn   := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getSetup(::filter, ::descricao, ::page, ::pageSize, ::filtering)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getSetup
Retorna os setups das programações.
@type  Static Function
@author Lucas Fagundes
@since 07/06/2023
@version P12
@param 01 cCod     , Caracter, Filtro para o código do setup.
@param 02 cDesc    , Caracter, Filtro para a descrição do setup.
@param 03 nPage    , Numerico, Pagina que está sendo carregada.
@param 04 nPageSize, Numerico, Tamanho da página.
@param 05 lOnlyCad , Logico  , Indica que deve enviar apenas registros cadastrados.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getSetup(cCod, cDesc, nPage, nPageSize, lOnlyCad)
	Local aReturn   := Array(3)
	Local cAlias    := GetNextAlias()
	Local cWhere    := ""
	Local lCodInvld := .F.
	Local nCont     := 0
	Local nStart    := 0
	Local oReturn   := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20
	Default lOnlyCad  := .T.

	cWhere := /*WHERE*/ "MS_FILIAL  = '" + xFilial("SMS") + "' "
	cWhere +=      " AND D_E_L_E_T_ = ' ' "

	If !Empty(cCod)
		cCod := Upper(cCod)

		If lOnlyCad
			cWhere +=  " AND UPPER(MS_ID) LIKE '" + cCod + "%' "
		Else
			cWhere +=  " AND UPPER(MS_ID) = '" + cCod + "' "
		EndIf
	EndIf

	If !Empty(cDesc)
		cDesc := Upper(cDesc)

		cWhere +=  " AND UPPER(MS_DESC) LIKE '" + cDesc + "%' "
	EndIf

	cWhere += " ORDER BY MS_ID "

	cWhere := "%" + cWhere + "%"

	BeginSql Alias cAlias
		SELECT MS_ID, MS_DESC, MS_PARAM
		  FROM %table:SMS%
		 WHERE %Exp:cWhere%
	EndSql

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	If (cAlias)->(EoF()) .And. !lOnlyCad

		If _nTamSetp == Nil
			_nTamSetp := GetSX3Cache("MS_ID", "X3_TAMANHO")
		EndIf

		lCodInvld := Len(cCod) > _nTamSetp
		If !lCodInvld
			nCont++
			aAdd(oReturn["items"], JsonObject():New())

			oReturn["items"][nCont]["setup"     ] := cCod
			oReturn["items"][nCont]["descricao" ] := ""
			oReturn["items"][nCont]["parametros"] := ""
			oReturn["items"][nCont]["existe"    ] := .F.
		EndIf
	Else
		While (cAlias)->(!EoF())
			nCont++
			aAdd(oReturn["items"], JsonObject():New())

			oReturn["items"][nCont]["setup"     ] := (cAlias)->MS_ID
			oReturn["items"][nCont]["descricao" ] := (cAlias)->MS_DESC
			oReturn["items"][nCont]["parametros"] := (cAlias)->MS_PARAM
			oReturn["items"][nCont]["existe"    ] := .T.

			(cAlias)->(dbSkip())
			If nCont >= nPageSize
				Exit
			EndIf
		End
	EndIf

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	If lCodInvld
		oReturn["message"        ] := STR0204 // "Código informado é inválido!"
		oReturn["detailedMessage"] := I18n(STR0205, {_nTamSetp}) // "Código informado possui tamanho superior ao tamanho do campo. Informe um código com tamanho menor ou igual a #1[tamanho]# caracteres."

		aReturn[1] := .F.
		aReturn[2] := 400
		aReturn[3] := oReturn:toJson()
	Else
		If Len(oReturn["items"]) > 0
			aReturn[1] := .T.
			aReturn[2] := 200
			aReturn[3] := oReturn:toJson()
		Else
			oReturn["message"        ] := STR0141 // "Nenhum registro encontrado."
			oReturn["detailedMessage"] := ""

			aReturn[1] := .T.
			aReturn[2] := 206
			aReturn[3] := oReturn:toJson()
		EndIf
	EndIf

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} POST CLEAN /api/pcp/v1/pcpa152prc/clean
Limpa as programações

@type  WSMETHOD
@author Lucas Fagundes
@since 19/07/2023
@version P12
@return lReturn, Logico, Indica se teve sucesso na requisição.
/*/
WSMETHOD POST CLEAN WSSERVICE PCPA152PRC
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local cBody     := ""
	Local lReturn   := .T.
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	cBody := DecodeUTF8(Self:getContent())

	oBody:FromJson(cBody)

	BEGIN SEQUENCE
		aReturn := limpaProg(oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FwFreeObj(oBody)
Return lReturn

/*/{Protheus.doc} limpaProg
Realiza a limpeza das programações.

@type  Static Function
@author Lucas Fagundes
@since 19/07/2023
@version P12
@param oParams, Object, Json com os parâmetros de limpeza da programação
@return aReturn, Array, Array com as informações para retorno da API.
/*/
Static Function limpaProg(oParams)
	Local aReturn  := Array(3)
	Local lSucesso := .T.
	Local oJsErro  := JsonObject():New()
	Local oReturn  := JsonObject():New()

	oReturn["existReg"] := .F.

	If oParams["searchHWF"]
		oReturn["existReg"] := searchHWF(oParams)
	Endif

	If !oReturn["existReg"]
		If atuT4X(oParams)
			lSucesso := cleanTabs(oParams, @oJsErro)
			oReturn["existReg"]  := .F.
		Else
			lSucesso := .F.
			oJsErro["message"        ] := STR0268 // "Erro ao atualizar o status da tabela T4X"
			oJsErro["detailedMessage"] := AllTrim(TcSqlError())
		EndIf
	Endif

	If lSucesso
		aReturn[1] := .T.
		aReturn[2] := 200
		aReturn[3] := oReturn:toJson()
	Else
		aReturn[1] := .F.
		aReturn[2] := 400
		aReturn[3] := oJsErro:toJson()
	EndIf

	FwFreeObj(oJsErro)
	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} atuT4X
Atualiza o status das programações que serão excluidas.
@type  Static Function
@author Lucas Fagundes
@since 26/07/2023
@version P12
@param oParams, Object, Json com os parâmetros de limpeza da programação
@return lSucesso, Logico, Indica se conseguiu atualizar com sucesso os status das programações.
/*/
Static Function atuT4X(oParams)
	Local cFilT4X    := xFilial("T4X")
	Local cFilT4Y    := ""
	Local cUpdT4X    := ""
	Local cUserId    := oParams["usuario"]
	Local lSucesso   := .T.
	Local nCleanType := oParams["opcaoLimpeza"]
	Local oUpdT4X    := FWPreparedStatement():New()

	cUpdT4X := " UPDATE " + RetSqlName("T4X")
	cUpdT4X +=    " SET T4X_STATUS =  'E', "
	cUpdT4X +=        " T4X_USER   =   ?,  "
	cUpdT4X +=        " T4X_HRINI  =   ?,  "
	cUpdT4X +=        " T4X_DTINI  =   ?   "
	cUpdT4X +=  " WHERE T4X_FILIAL =   ?   "

	If nCleanType == LIMPEZA_MANUAL
		cUpdT4X +=    " AND T4X_PROG IN (?) "
	EndIf

	If nCleanType == LIMPEZA_POR_DATAS
		cUpdT4X += " AND T4X_PROG IN (" + filtroData() + ") "
	EndIf

	oUpdT4X:setQuery(cUpdT4X)

	oUpdT4X:setString(1, cUserId) // T4X_USER
	oUpdT4X:setString(2, Time())  // T4X_HRINI

	oUpdT4X:setDate(3, Date()) // T4X_DTINI

	oUpdT4X:setString(4, cFilT4X) // T4X_FILIAL

	If nCleanType == LIMPEZA_MANUAL
		oUpdT4X:setIn(5, oParams["programacoes"]) // T4X_PROG

	ElseIf nCleanType == LIMPEZA_POR_DATAS
		cFilT4Y := xFilial("T4Y")

		oUpdT4X:setString(5, cFilT4Y)
		oUpdT4X:setString(6, oParams["dataInicial"])

		oUpdT4X:setString(7, cFilT4Y)
		oUpdT4X:setString(8, oParams["dataFinal"])

		oUpdT4X:setString(9, cFilT4X)
	EndIf

	lSucesso := TCSQLExec(oUpdT4X:getFixQuery()) >= 0

	oUpdT4X:destroy()
	FwFreeObj(oUpdT4X)
Return lSucesso

/*/{Protheus.doc} cleanTabs
Limpa as tabelas de processamento.
@type  Static Function
@author Lucas Fagundes
@since 26/07/2023
@version P12
@param 01 oParams, Object, Json com os parâmetros de limpeza da programação.
@param 02 oJsErro, Object, Json para retornar as tabelas que tiveram erro na limpeza.
@return lSucesso, Logico, Indica se conseguiu limpar as tabelas com sucesso.
/*/
Static Function cleanTabs(oParams, oJsErro)
	Local aTabsDel   := {}
	Local aTabsErro  := {}
	Local cProgZero  := PadL(0, GetSx3Cache("T4X_PROG", "X3_TAMANHO"), "0")
	Local cQueryDel  := ""
	Local lSucesso   := .T.
	Local nCleanType := oParams["opcaoLimpeza"]
	Local nIndTab    := 0
	Local nTotTabs   := 0
	Local oDelTabs   := FWPreparedStatement():New()

	aTabsDel := {;
		{"SMR",  "MR_FILIAL",  "MR_PROG"} ,;
		{"SMT",  "MT_FILIAL",  "MT_PROG"} ,;
		{"SMF",  "MF_FILIAL",  "MF_PROG"} ,;
		{"SVM",  "VM_FILIAL",  "VM_PROG"} ,;
		{"SMK",  "MK_FILIAL",  "MK_PROG"} ,;
		{"SVY",  "VY_FILIAL",  "VY_PROG"} ,;
		{"T4Z", "T4Z_FILIAL", "T4Z_PROG"} ;
	}

	If AliasInDic("HZ7")
		aAdd(aTabsDel, {"HZ7", "HZ7_FILIAL", "HZ7_PROG"})
	EndIf

	// Ao adicionar novas tabelas para exclusão, deixar a T4Y por último. Pois é realizado o filtro de datas pela data parâmetrizada na programação.
	aAdd(aTabsDel, {"T4Y", "T4Y_FILIAL", "T4Y_PROG"})


	cQueryDel := " DELETE FROM ? "
	cQueryDel +=  " WHERE ?  = ? "
	cQueryDel +=    " AND ? != '" + cProgZero + "' "

	If nCleanType == LIMPEZA_MANUAL
		cQueryDel +=    " AND ? IN (?) "
	EndIf

	If nCleanType == LIMPEZA_POR_DATAS
		cQueryDel += " AND ? IN (" + filtroData() + ") "
	EndIf

	oDelTabs:setQuery(cQueryDel)

	If nCleanType == LIMPEZA_MANUAL
		oDelTabs:setIn(6, oParams["programacoes"]) // ?_PROG
	EndIf

	If nCleanType == LIMPEZA_POR_DATAS
		oDelTabs:setString(6, xFilial("T4Y"))         // dataInicial.T4Y_FILIAL
		oDelTabs:setString(7, oParams["dataInicial"]) // dataInicial.T4Y_VALOR

		oDelTabs:setString(8, xFilial("T4Y"))       // dataFinal.T4Y_FILIAL
		oDelTabs:setString(9, oParams["dataFinal"]) // dataFinal.T4Y_VALOR

		oDelTabs:setString(10, xFilial("T4X")) // T4X_FILIAL
	EndIf

	nTotTabs := Len(aTabsDel)
	For nIndTab := 1 To nTotTabs

		oDelTabs:setUnsafe(1, RetSqlName(aTabsDel[nIndTab][1]))   // Tabela
		oDelTabs:setUnsafe(2, aTabsDel[nIndTab][2])               // Campo Filial

		oDelTabs:setString(3, xFilial(aTabsDel[nIndTab][1])) // ?_FILIAL

		oDelTabs:setUnsafe(4, aTabsDel[nIndTab][3]) // Campo programação

		If nCleanType != LIMPEZA_TOTAL
			oDelTabs:setUnsafe(5, aTabsDel[nIndTab][3])
		EndIf

		If TCSQLExec(oDelTabs:getFixQuery()) < 0
			aAdd(aTabsErro, {aTabsDel[nIndTab][1], AllTrim(TcSqlError())})
		EndIf
	Next

	nTotTabs := Len(aTabsErro)
	If nTotTabs > 0
		lSucesso := .F.

		oJsErro["message"        ] := STR0269 //"Ocorreram erros ao excluir as seguintes tabelas:"
		oJsErro["detailedMessage"] := ""

		For nIndTab := 1 To nTotTabs
			oJsErro["message"        ] += " " + aTabsErro[nIndTab][1]
			oJsErro["detailedMessage"] += aTabsErro[nIndTab][2]

			If nIndTab < nTotTabs
				oJsErro["message"        ] += ","
				oJsErro["detailedMessage"] += Chr(13)+Chr(10) + Chr(13)+Chr(10)
			EndIf
		Next

		FwFreeArray(aTabsErro)
	EndIf

	oDelTabs:destroy()
	FwFreeObj(oDelTabs)
	FwFreeArray(aTabsDel)
Return lSucesso

/*/{Protheus.doc} filtroData
Retorna subquery que busca as programações para exclusão com filtro de data.
@type  Static Function
@author Lucas Fagundes
@since 31/07/2023
@version P12
@return cFilData, Caracter, Subquery que busca as programações com filtro de data.
/*/
Static Function filtroData()
	Local cFilData := ""

	cFilData += " SELECT T4X2.T4X_PROG "
	cFilData +=   " FROM " + RetSqlName("T4X") + " T4X2 "
	cFilData +=  " INNER JOIN " + RetSqlName("T4Y") + " dataInicial "
	cFilData +=     " ON dataInicial.T4Y_PROG   = T4X2.T4X_PROG  "
	cFilData +=    " AND dataInicial.T4Y_PARAM  = 'dataInicial' "
	cFilData +=    " AND dataInicial.D_E_L_E_T_ = ' '           "
	cFilData +=    " AND dataInicial.T4Y_FILIAL =  ? "
	cFilData +=    " AND dataInicial.T4Y_VALOR >=  ? "
	cFilData +=  " INNER JOIN " + RetSqlName("T4Y") + " dataFinal "
	cFilData +=     " ON dataFinal.T4Y_PROG   = T4X2.T4X_PROG "
	cFilData +=    " AND dataFinal.T4Y_PARAM  = 'dataFinal'  "
	cFilData +=    " AND dataFinal.D_E_L_E_T_ = ' '          "
	cFilData +=    " AND dataFinal.T4Y_FILIAL =  ? "
	cFilData +=    " AND dataFinal.T4Y_VALOR <=  ? "
	cFilData +=  " WHERE T4X2.T4X_FILIAL = ?

Return cFilData

/*/{Protheus.doc} searchHWF
Procura OPs abertas antes de efetivar a limpeza.
@type  Static Function
@author Jefferson Possidonio
@since 23/05/2024
@version P12
@param oParams, Object, Json com os parâmetros de limpeza da programação
@return lRet, Logico, Indica se encontrou algum registro.
/*/
Static Function searchHWF(oParams)
	Local cAlias   := GetNextAlias()
	Local cFilT4X  := xFilial("T4X")
	Local cQuery   := ""
	Local lRet	   := .F.
	Local oGetHWF  := FWPreparedStatement():New()
	Local nCleanType := oParams["opcaoLimpeza"]

	cQuery := " SELECT 1 "
	cQuery +=   " FROM " + RetSqlName("HWF") + " HWF"
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2"
	cQuery += 	  " ON SC2.C2_FILIAL = '" + xFilial("SC2") + "'"
	cQuery +=    " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
	cQuery += 	 " AND SC2.C2_DATRF = ' '"
	cQuery += 	 " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "'"
	cQuery +=    " AND HWF.D_E_L_E_T_ = ' ' "

	If nCleanType == LIMPEZA_MANUAL
		cQuery +=    " AND HWF.HWF_PROG IN (?) "
	ElseIf nCleanType == LIMPEZA_POR_DATAS
		cQuery += 	 " AND HWF.HWF_PROG IN (" + filtroData() + ") "
	Else
		cQuery += 	 " AND HWF.HWF_PROG IN (SELECT T4X.T4X_PROG "
		cQuery +=                           " FROM " + RetSqlName("T4X") + " T4X "
		cQuery +=              	           " WHERE T4X.T4X_FILIAL = '" + cFilT4X + "' "
		cQuery +=                	         " AND T4X.T4X_STATUS != 'E' "
		cQuery +=                	         " AND T4X.D_E_L_E_T_ = ' ') "
	EndIf

	oGetHWF:setQuery(cQuery)

	If nCleanType == LIMPEZA_MANUAL
		oGetHWF:setIn(1, oParams["programacoes"])
	ElseIf nCleanType == LIMPEZA_POR_DATAS
		cFilT4Y := xFilial("T4Y")

		oGetHWF:setString(1, cFilT4Y)
		oGetHWF:setString(2, oParams["dataInicial"])

		oGetHWF:setString(3, cFilT4Y)
		oGetHWF:setString(4, oParams["dataFinal"])

		oGetHWF:setString(5, CFILT4X)
	EndIf

	cQuery := oGetHWF:GetFixQuery() //Retorna a query com os parâmetros já tratados e substituídos.
	cAlias := MPSysOpenQuery(cQuery, cAlias) //Abre um alias com a query informada.

	lRet := (cAlias)->(!Eof())

	(cAlias)->(dbCloseArea())

	oGetHWF:destroy()
	FwFreeObj(oGetHWF)

Return lRet

/*/{Protheus.doc} POST REPROCESSAR /api/pcp/v1/pcpa152prc/reprocessar/{programacao}
Inicia o reprocessamento das alocações de uma programação.

@type  WSMETHOD
@author Lucas Fagundes
@since 08/11/2023
@version P12
@return lReturn, Logico, Indica se teve sucesso na requisição.
/*/
WSMETHOD POST REPROCESSAR PATHPARAM programacao WSSERVICE PCPA152PRC
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRC"), Break(oError)})
	Local cBody     := ""
	Local lReturn   := .T.
	Local oBody     := Nil

	Self:SetContentType("application/json")

	cBody := DecodeUTF8(Self:getContent())

	oBody := JsonObject():New()
	oBody:FromJson(cBody)

	BEGIN SEQUENCE
		aReturn := reprocessa(Self:programacao, oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FwFreeObj(oBody)
Return lReturn

/*/{Protheus.doc} reprocessa
Inicia o reprocessamento de uma programação.

@type  Static Function
@author Lucas Fagundes
@since 08/11/2023
@version P12
@param cProg , Caracter, Código da programação que irá reprocessar.
@param oStart, Object  , Objeto com os parâmetros para reprocessar a programação.
@return aReturn, Array, Array com as informações para retorno da API.
/*/
Static Function reprocessa(cProg, oStart)
	Local aReturn := Array(3)
	Local aError := {}
	Local cMsg := ""
	Local cMsgDet := ""
	Local lSucesso := .T.
	Local nCode := 0
	Local oRetorno := JsonObject():New()

	oProcesso := PCPA152Process():executaProgramacao(cProg, oStart, .T.)

	If oProcesso:oProcError:possuiErro()
		aError := oProcesso:oProcError:getaError()

		cMsg    := aError[1][2]
		cMsgDet := aError[1][3]

		lSucesso := .F.
		nCode    := 500

		FwFreeArray(aError)
		oProcesso:oProcError:destroy()
	Else
		cMsg    := STR0377 // "Reprocessamento iniciado com sucesso."
		cMsgDet := ""

		lSucesso := .T.
		nCode    := 200

		oProcesso:destroy()
	EndIf

	oRetorno["message"        ] := cMsg
	oRetorno["detailedMessage"] := cMsgDet

	aReturn[1] := lSucesso
	aReturn[2] := nCode
	aReturn[3] := oRetorno:toJson()

	FreeObj(oProcesso)
	FreeObj(oRetorno)
Return aReturn
