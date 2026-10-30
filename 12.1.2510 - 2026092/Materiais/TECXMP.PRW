#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
/*/
{Protheus.doc} meuposto
Endpoint do aplicativo Meu Posto - Versão 2.
Retorna parâmetros do sistema (SX6) em JSON.
@author levy.santos
@since 09/03/2025
@version 1.0
/*/
//------------------------------------------------------------------------------
WSRESTFUL meuposto DESCRIPTION "Meu Posto - API v2"

	WSDATA filial    as STRING
	WSDATA imei      as STRING
	WSDATA matricula as STRING

	WSMETHOD GET 	params        		DESCRIPTION "Retorna parâmetros SX6"     										PATH "v2/parametros"		PRODUCES APPLICATION_JSON
	WSMETHOD GET 	searchImei			DESCRIPTION "Consulta IMEI do dispositivo e retorna os funcionários atrelados"	PATH "v2/consultaImei"		PRODUCES APPLICATION_JSON
	WSMETHOD GET 	photoFunc			DESCRIPTION "Retorna foto do funcionário (SRA)"        							PATH "v2/fotoFuncionario"	PRODUCES APPLICATION_JSON
	WSMETHOD POST 	checkin          	DESCRIPTION "Registra marcação (ABB/T40)" 										PATH "v2/checkin"           PRODUCES APPLICATION_JSON

END WSRESTFUL

//------------------------------------------------------------------------------
/*/
{Protheus.doc} params
Endpoint que retorna os valores dos parâmetros do Protheus (tabela SX6).

@return Retorna valores dos parâmetros para configuração do aplicativo Meu Posto
@author     levy.santos
@since      09/03/2025
@version	1.0
/*/
//------------------------------------------------------------------------------
WSMETHOD GET params WSREST meuposto
	Local oBtns := JsonObject():New()
	Local oJson := JsonObject():New()

	::SetContentType("application/json;charset=UTF-8")

	oJson["modoUso"]      := SuperGetMV("MV_GSMDUSO", .F., "1")
	oJson["modoCheckin"]  := SuperGetMV("MV_GSMDCHK", .F., "1")
	oJson["exibirBotoes"] := SuperGetMV("MV_GSEXBBT", .F., .T.)
	oJson["numeroBotoes"] := SuperGetMV("MV_GSNMRBT", .F., 4)

	oBtns["btn1"] := SuperGetMV("MV_GSDSCB1", .F., "Entrada")
	oBtns["btn2"] := SuperGetMV("MV_GSDSCB2", .F., "Pausa")
	oBtns["btn3"] := SuperGetMV("MV_GSDSCB3", .F., "Retorno")
	oBtns["btn4"] := SuperGetMV("MV_GSDSCB4", .F., "Saída")

	oJson["textoBotoes"] := oBtns

	Self:SetResponse(EncodeUTF8(oJson:toJSON()))

Return .T.

//------------------------------------------------------------------------------
/*/
{Protheus.doc} searchImei
Obtém a lista de funcionários com base no IMEI do dispositivo.
@param imei     IMEI do dispositivo (obrigatório)

@return Retorna a lista dos funcionários com base no IMEI do dispositivo.
@author     levy.santos
@since      16/03/2025
@version	1.0
/*/
//------------------------------------------------------------------------------
WSMETHOD GET searchImei WSREST meuposto
	Local aResults         := {}
	Local cContrato        := ""
	Local cImei            := AllTrim(::imei)
	Local cLocal           := ""
	Local cNivelInstalacao := ""
	Local cPosto           := ""
	Local cQry             := ""
	Local cRetImei         := ""
	Local cTmp             := GetNextAlias()
	Local cValorNivel      := ""
	Local oItem            := JsonObject():New()
	Local oJson            := JsonObject():New()
	Local oQry             := Nil

	::SetContentType("application/json;charset=UTF-8")

	If Empty(cImei)
		SetRestFault(400, "Parâmetro IMEI é obrigatório.")
		Return .F.
	EndIf

	cQry := " SELECT TFS.TFS_FILIAL, "
	cQry += " TFS.TFS_IMEI AS IMEI, "
	cQry += " CASE "
	cQry +=     " WHEN  TFS.TFS_NIVEL = 1 THEN 'Posto' "
	cQry +=     " WHEN  TFS.TFS_NIVEL = 2 THEN 'Local' "
	cQry +=     " WHEN  TFS.TFS_NIVEL = 3 THEN 'Contrato' "
	cQry +=     " ELSE 'Indefinido' "
	cQry +=     " END AS NIVEL, "
	cQry += " TFG.TFG_CODPAI AS POSTO, "
	cQry += " TFL.TFL_CODIGO AS LOCAL_ATENDIMENTO, "
	cQry += " TFL.TFL_CODPAI AS CONTRATO, "
	cQry += " TFS.TFS_DTAPON AS DATA_IMPLANTACAO "
	cQry += " FROM " + RetSqlName("TFS") + " AS TFS "
	cQry += " JOIN " + RetSqlName("TFL") + " AS TFL "
	cQry +=     " ON TFL.TFL_FILIAL = TFS.TFS_FILIAL "
	cQry +=     " AND TFL.TFL_CODIGO = TFS.TFS_CODTFL "
	cQry +=     " AND TFL.D_E_L_E_T_ = ' ' "
	cQry += " JOIN " + RetSqlName("TFG") + " AS TFG "
	cQry +=     " ON TFG.TFG_FILIAL = TFS.TFS_FILIAL "
	cQry +=     " AND TFG.TFG_COD = TFS.TFS_CODTFG "
	cQry +=     " AND TFG.D_E_L_E_T_ = ' ' "
	cQry += " WHERE TFS.TFS_MOV = 1 "
	cQry +=     " AND TFS.TFS_IMEI = ? "
	cQry +=     " AND TFS.D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)
	oQry := FwExecStatement():New(cQry)

	oQry:SetString(1, cImei)

	cTmp := oQry:OpenAlias()
	oQry:Destroy()
	FwFreeObj(oQry)

	While !(cTmp)->(Eof())
		cRetImei := (cTmp)->IMEI
		cNivelInstalacao := AllTrim((cTmp)->NIVEL)
		cPosto := (cTmp)->POSTO
		cLocal := (cTmp)->LOCAL_ATENDIMENTO
		cContrato := (cTmp)->CONTRATO
		(cTmp)->(DbSkip())
	EndDo
	(cTmp)->(DbCloseArea())

	If cRetImei == ""
		SetRestFault(404, "IMEI não encontrado.")
		Return .F.
	EndIf

	cQry := " SELECT "
	cQry += " ABB.ABB_FILIAL, "
	cQry += " TFF.TFF_COD AS POSTO, "
	cQry += " TFL.TFL_CODIGO AS LOCAL_ATENDIMENTO, "
	cQry += " TFL.TFL_CODPAI AS CONTRATO, "
	cQry += " ABB.ABB_CODTEC, "
	cQry += " AA1.AA1_CDFUNC AS MATRICULA, "
	cQry += " AA1.AA1_NOMTEC, "
	cQry += " SRA.RA_NOME, "
	cQry += " SRA.RA_CIC, "
	cQry += " SRA.RA_FILIAL, "
	cQry += " SRA.RA_ADMISSA, "
	cQry += " SRA.RA_DEMISSA, "
	cQry += " SRA.RA_BITMAP, "
	cQry += " MAX(ABB.ABB_DTFIM) AS ULTIMA_ALOCACAO "
	cQry += " FROM " + RetSqlName("ABB") + " AS ABB "
	cQry += " INNER JOIN " + RetSqlName("ABQ") + " AS ABQ ON ABQ.ABQ_CONTRT + ABQ.ABQ_ITEM + ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL "
	cQry +=     " AND ABQ.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN " + RetSqlName("TFF") + " AS TFF ON TFF.TFF_FILIAL = ABQ.ABQ_FILTFF "
	cQry +=     " AND TFF.TFF_COD = ABQ.ABQ_CODTFF "
	cQry +=     " AND TFF.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN " + RetSqlName("TFL") + " AS TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQry +=     " AND TFL.TFL_FILIAL = TFF.TFF_FILIAL "
	cQry +=     " AND TFL.D_E_L_E_T_ = ' ' "
	cQry += " INNER JOIN " + RetSqlName("AA1") + " AS AA1 ON AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	cQry +=     " AND AA1.D_E_L_E_T_ = ' ' "
	cQry += " LEFT JOIN " + RetSqlName("SRA") + " AS SRA ON SRA.RA_MAT = AA1.AA1_CDFUNC "
	cQry +=     " AND SRA.RA_FILIAL = AA1.AA1_FUNFIL "
	cQry +=     " AND SRA.D_E_L_E_T_ = ' ' "
	cQry += " WHERE ABB.D_E_L_E_T_ = ' ' "

	//SE NÍVEL = POSTO
	If cNivelInstalacao == "Posto"
		cQry += " AND TFF.TFF_COD = ? "
		cValorNivel := cPosto
	EndIf

	//SE NÍVEL = LOCAL
	If cNivelInstalacao == "Local"
		cQry += " AND TFL.TFL_CODIGO = ? "
		cValorNivel := cLocal
	EndIf

	//SE NÍVEL = CONTRATO
	If cNivelInstalacao == "Contrato"
		cQry += " AND TFL.TFL_CODPAI = ? "
		cValorNivel := cContrato
	EndIf
	
	cQry += " GROUP BY "
	cQry +=     " ABB.ABB_FILIAL, "
	cQry +=     " TFF.TFF_COD, "
	cQry +=     " TFL.TFL_CODIGO, "
	cQry +=     " TFL.TFL_CODPAI, "
	cQry +=     " AA1.AA1_NOMTEC, "
	cQry +=     " SRA.RA_NOME, "
	cQry +=     " SRA.RA_CIC, "
	cQry +=     " SRA.RA_FILIAL, "
	cQry +=     " SRA.RA_ADMISSA, "
	cQry += 	" SRA.RA_DEMISSA, "
	cQry +=     " AA1.AA1_CDFUNC, "
	cQry +=     " ABB.ABB_CODTEC, "
	cQry +=     " SRA.RA_BITMAP "

	cQry := ChangeQuery(cQry)
	oQry := FwExecStatement():New(cQry)

	oQry:SetString(1, cValorNivel)

	cTmp := oQry:OpenAlias()
	oQry:Destroy()
	FwFreeObj(oQry)

	While !(cTmp)->(Eof())
		oItem := JsonObject():New()
		oItem["codTec"] := (cTmp)->ABB_CODTEC
		oItem["matricula"] := (cTmp)->MATRICULA
		oItem["filialSRA"] := (cTmp)->RA_FILIAL
		oItem["nome"] := AllTrim((cTmp)->RA_NOME)
		oItem["cpf"] := AllTrim((cTmp)->RA_CIC)
		oItem["admissao"] := AllTrim((cTmp)->RA_ADMISSA)
		oItem["demissao"] := AllTrim((cTmp)->RA_DEMISSA)
		oItem["bitmap"] := AllTrim((cTmp)->RA_BITMAP)
		AAdd(aResults, oItem)
		(cTmp)->(DbSkip())
	EndDo
	(cTmp)->(DbCloseArea())

	oJson := JsonObject():New()

	oJson["nivelInstalacao"] := cNivelInstalacao
	oJson["results"] := aResults
	Self:SetResponse(EncodeUTF8(oJson:toJSON()))

Return .T.

//------------------------------------------------------------------------------
/*/
	{Protheus.doc} photoFunc
	Obtém a foto do funcionário em base64.
	@param filial     Filial (obrigatório)
	@param matricula  Matrícula do funcionário (obrigatório)

	@return Retorna a foto do funcionário em formato base64 em JSON.
	@author     diego.bezerra | levy.santos
	@since      09/03/2025
	@version	2.0
/*/
//------------------------------------------------------------------------------
WSMETHOD GET photoFunc WSREST meuposto
	Local cFile      := ""
	Local cFilFunc   := AllTrim(::filial)
	Local cMatricula := AllTrim(::matricula)
	Local cQry       := ""
	Local cTmp       := ""
	Local oFile      := Nil
	Local oJson      := JsonObject():New()
	Local oQry       := Nil
	Local xFile      := Nil

	::SetContentType("application/json;charset=UTF-8")

	If Empty(cFilFunc)
		SetRestFault(400, "Parâmetro filial é obrigatório.")
		Return .F.
	EndIf

	If Empty(cMatricula)
		SetRestFault(400, "Parâmetro matrícula é obrigatório.")
		Return .F.
	EndIf

	cQry := " SELECT "
	cQry += " RA_MAT, "
	cQry += " RA_NOME, "
	cQry += " RA_CIC, "
	cQry += " RA_BITMAP "
	cQry += " FROM " + RetSqlName("SRA") + " "
	cQry += " WHERE "
	cQry +=     " RA_FILIAL = ? "
	cQry +=     " AND RA_MAT = ? "
	cQry +=     " AND RA_BITMAP <> ' ' "
	cQry +=     " AND D_E_L_E_T_ = ' ' "

	cQry := ChangeQuery(cQry)
	oQry := FwExecStatement():New(cQry)

	oQry:SetString(1, cFilFunc)
	oQry:SetString(2, cMatricula)

	cTmp := oQry:OpenAlias()
	oQry:Destroy()
	FwFreeObj(oQry)

	While !(cTmp)->(Eof())
		cFile := AllTrim((cTmp)->RA_BITMAP) + ".jpg"
		If RepExtract(AllTrim((cTmp)->RA_BITMAP), cFile) .And. File(cFile)
			oFile := FwFileReader():New(cFile)
			If oFile:Open()
				xFile := ReadAllFile(oFile:nHandlen)
				cFile := ENCODE64(xFile)
				oFile:Close()
				
				oJson := JsonObject():New()
				oJson["matricula"]   := (cTmp)->RA_MAT
				oJson["nome"]        := AllTrim((cTmp)->RA_NOME)
				oJson["CPF"]         := AllTrim((cTmp)->RA_CIC)
				oJson["fotoBase64"]  := cFile
			EndIf
			FErase(cFile)
		EndIf
		(cTmp)->(DbSkip())
	EndDo
	(cTmp)->(DbCloseArea())

	Self:SetResponse(EncodeUTF8(oJson:toJSON()))

Return .T.

//------------------------------------------------------------------------------
/*/
	{Protheus.doc} checkin
	Registra check-in/out na agenda ABB e na tabela T40.

	@param codigoAgenda  (body) Código da agenda ABB (obrigatório se semAgenda não for true)
	@param semAgenda     (body) Se true, grava apenas na T40 sem vincular à ABB (obrigatório matricula e filial)
	@param matricula     (body) Matrícula do funcionário (obrigatório quando semAgenda=true)
	@param filial        (body) Filial do funcionário (obrigatório quando semAgenda=true)
	@param tipoMarcacao  (body) 1 = entrada (check-in), 2 = saída (check-out)
	@param horario       (body) Horário da marcação "HH:MM" ou "HH:MM:SS"
	@param latitude      (body) Latitude da localização (opcional)
	@param longitude     (body) Longitude da localização (opcional)
	@param imei          (body) IMEI do celular (opcional)
	@param dataMarcacao  (body) Data da marcação YYYYMMDD (opcional; default = data atual)
	@return lRet         .T. se gravado com sucesso

	@author     levy.santos
	@since      09/03/2025
	@version	1.0
/*/
//------------------------------------------------------------------------------
// WSMETHOD POST checkin WSREST meuposto
// Local cBody     := ::GetContent()
// Local cCic      := ""
// Local cHora     := ""
// Local cInOut    := "1"
// Local cValCON   := ""
// Local dData     := Date()
// Local lRet      := .F.
// Local oBody     := JsonObject():New()
// Local oResponse := JsonObject():New()

// // Variáveis do Body
// Local cCodigoAgenda := ""
// Local cDataMar      := ""
// Local cFilCheckin       := ""
// Local cHorario      := ""
// Local cImei         := ""
// Local cLatitude     := ""
// Local cLongitude    := ""
// Local cMatricula    := ""
// Local lSemAgenda    := .F.
// Local nTipoMarcacao := 0

// ::SetContentType("application/json;charset=UTF-8")

// If Empty(cBody) .Or. oBody:FromJson(cBody) == Nil
// 	SetRestFault(400, "Corpo da requisição inválido.")
// Return .F.
// EndIf

// // Extração de dados com tratamento de tipos
// cCodigoAgenda := AllTrim(cValToChar(If(oBody:HasProperty("codigoAgenda"), oBody["codigoAgenda"], "")))
// cDataMar      := AllTrim(cValToChar(If(oBody:HasProperty("dataMarcacao"), oBody["dataMarcacao"], "")))
// cFilCheckin       := AllTrim(cValToChar(If(oBody:HasProperty("filial"), oBody["filial"], "")))
// cHorario      := AllTrim(cValToChar(If(oBody:HasProperty("horario"), oBody["horario"], "")))
// cImei         := AllTrim(cValToChar(If(oBody:HasProperty("imei"), oBody["imei"], "")))
// cLatitude     := AllTrim(cValToChar(If(oBody:HasProperty("latitude"), oBody["latitude"], "")))
// cLongitude    := AllTrim(cValToChar(If(oBody:HasProperty("longitude"), oBody["longitude"], "")))
// cMatricula    := AllTrim(cValToChar(If(oBody:HasProperty("matricula"), oBody["matricula"], "")))
// lSemAgenda    := If(oBody:HasProperty("semAgenda"), oBody["semAgenda"] == .T. .Or. oBody["semAgenda"] == 1, .F.)
// nTipoMarcacao := Val(cValToChar(If(oBody:HasProperty("tipoMarcacao"), oBody["tipoMarcacao"], "0")))

// cHora  := PadL(Left(cHorario, 5), 5, "0")
// cInOut := If(nTipoMarcacao == 1, "1", "2")
// dData  := If(!Empty(cDataMar), STOD(cDataMar), Date())

// // --- LÓGICA 1: SEM AGENDA (Grava apenas T40) ---
// If lSemAgenda
// 	DbSelectArea("SRA")
// 	SRA->(DbSetOrder(1))
// 	If !SRA->(DbSeek(xFilial("SRA") + cMatricula))
// 		SetRestFault(404, "Funcionário não encontrado.")
// 		Return .F.
// 	EndIf

// 	cCic := AllTrim(SRA->RA_CIC)
// 	If TableInDic("T40")
// 		cValCON := "SAG" + DToS(dData) + StrTran(cHora, ":", "") + Right(StrZero(Seconds() * 10, 6), 4)
// 		DbSelectArea("T40")
// 		RecLock("T40", .T.)
// 		T40->T40_FILIAL := xFilial("T40")
// 		T40->T40_DATMAR := dData
// 		T40->T40_VALCON := cValCON
// 		T40->T40_CIC    := cCic
// 		T40->T40_NUMMAR := cHora + "O" + If(!Empty(cLatitude), "I", "O")
// 		T40->T40_LATITU := cLatitude
// 		T40->T40_LONGIT := cLongitude
// 		T40->T40_IMEI   := cImei
// 		T40->T40_AGEINT := " "
// 		T40->(MsUnlock())
// 	EndIf
// 	lRet := .T.

// 	// --- LÓGICA 2: COM AGENDA (ABB + T40) ---
// Else
// 	DbSelectArea("ABB")
// 	ABB->(DbSetOrder(8)) // ABB_FILIAL + ABB_CODIGO
// 	If !ABB->(DbSeek(xFilial("ABB") + cCodigoAgenda))
// 		SetRestFault(404, "Agenda não encontrada.")
// 		Return .F.
// 	EndIf

// 	// Validações de Agenda
// 	If ABB->(FieldPos("ABB_ATIVO")) > 0 .And. ABB->ABB_ATIVO <> "1"
// 		SetRestFault(400, "Agenda inativa.")
// 		Return .F.
// 	EndIf

// 	// Atualização da ABB
// 	If ExistFunc("TecAtuABB")
// 		lRet := TecAtuABB(cCodigoAgenda, cInOut, cHora, dData, ABB->ABB_FILIAL, .F., Nil, .F.)
// 	Else
// 		RecLock("ABB", .F.)
// 		If cInOut == "1"
// 			ABB->ABB_CHEGOU := "S"
// 			ABB->ABB_HRCHIN := cHora
// 		Else
// 			ABB->ABB_ATENDE := "1"
// 			ABB->ABB_HRCOUT := cHora
// 			ABB->ABB_SAIU   := "S"
// 		EndIf
// 		ABB->(MsUnlock())
// 		lRet := .T.
// 	EndIf

// 	// Gravação Coordenadas e T40 se ABB atualizada
// 	If lRet
// 		RecLock("ABB", .F.)
// 		If cInOut == "1"
// 			ABB->ABB_LATIN := cLatitude
// 			ABB->ABB_LONIN := cLongitude
// 		Else
// 			ABB->ABB_LATOUT := cLatitude
// 			ABB->ABB_LONOUT := cLongitude
// 		EndIf
// 		ABB->(MsUnlock())

// 		// Busca CPF para T40
// 		DbSelectArea("AA1")
// 		AA1->(DbSetOrder(7)) // AA1_FILIAL+AA1_CODTEC
// 		If AA1->(DbSeek(xFilial("AA1") + ABB->ABB_CODTEC))
// 			DbSelectArea("SRA")
// 			SRA->(DbSetOrder(1))
// 			If SRA->(DbSeek(xFilial("SRA") + AA1->AA1_CDFUNC))
// 				cCic := SRA->RA_CIC
// 			EndIf
// 		EndIf

// 		If !Empty(cCic) .And. TableInDic("T40")
// 			cValCON := If(cInOut == "1", ABB->ABB_MARENT, ABB->ABB_MARSAI)
// 			DbSelectArea("T40")
// 			RecLock("T40", .T.)
// 			T40->T40_FILIAL := xFilial("T40")
// 			T40->T40_DATMAR := dData
// 			T40->T40_VALCON := cValCON
// 			T40->T40_CIC    := cCic
// 			T40->T40_NUMMAR := cHora + "O"
// 			T40->T40_LATITU := cLatitude
// 			T40->T40_LONGIT := cLongitude
// 			T40->T40_AGEINT := "S"
// 			T40->(MsUnlock())
// 		EndIf
// 	EndIf
// EndIf

// If lRet
// 	oResponse["success"] := .T.
// 	oResponse["horario"] := cHora
// 	Self:SetResponse(EncodeUTF8(oResponse:toJSON()))
// Else
// 	SetRestFault(500, "Erro ao processar checkin.")
// EndIf

// Return lRet


Static Function ReadAllFile(nHandle)
    Local cBuff := Space(2048)
    Local cData := ""
    Local nLido := 0

    While (nLido := FRead(nHandle, @cBuff, Len(cBuff))) > 0
        cData += Left(cBuff, nLido)
    EndDo
Return cData
