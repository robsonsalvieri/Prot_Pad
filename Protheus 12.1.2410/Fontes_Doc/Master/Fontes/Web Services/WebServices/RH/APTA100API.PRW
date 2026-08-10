#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APTA100API.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )
#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

Static oStatmE0B

/*
{Protheus.doc} laborProcess
API de Processos trabalhistas
@author  martins.marcio
@since   20/10/2022
@version 12.1.33
*/

WSRESTFUL laborProcess DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para Processos trabalhistas"
	WSDATA companyId	 	As String
	WSDATA branchId	     	As String
	WSDATA fields	     	As String
	WSDATA page			 	As Integer Optional
	WSDATA pageSize		 	As Integer Optional
	WSDATA order	     	As String
	WSDATA laborProcessId 	As String Optional

	WSMETHOD POST;
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0002 + STR0042 + "S-1.3")); // "Inclui um Processo trabalhista no layout S-1.3"
	WSSYNTAX "/api/rh/v3/laborProcess" ;
	PATH "/api/rh/v3/laborProcess" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD GET BYID;
	DESCRIPTION oEmToAnsi(STR0025 + STR0042 + "S-1.3"); // "Retorna as informações de um Processo trabalhista no layout S-1.3" /VERIICAR
	WSSYNTAX "/api/rh/v3/laborProcess/{laborProcessId}" ;
	PATH "/api/rh/v3/laborProcess/{laborProcessId}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD GET ALL;
	DESCRIPTION oEmToAnsi(STR0026); // "Retorna uma lista de Processos trabalhistas"
	WSSYNTAX "/api/rh/v3/laborProcess" ;
	PATH "/api/rh/v3/laborProcess" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD PUT;
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0033 + STR0042 + "S-1.3")); // "Altera um Processo trabalhista no layout S-1.3"
	WSSYNTAX "/api/rh/v3/laborProcess/{id}" ;
	PATH "/api/rh/v3/laborProcess/{id}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD DELETE;
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0039)); // "Exclusão do Processo trabalhista"
	WSSYNTAX "/api/rh/v3/laborProcess/{id}" ;
	PATH "/api/rh/v3/laborProcess/{id}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

END WSRESTFUL

// Retorna Processos trabalhistas
/*/{Protheus.doc} GET BY ID v S-1.3
Método responsável pelo retorno de um Processo Trabalhista específico no layout S-1.3
@author  martins.marcio
@since   20/08/2024
@version 12.1.2310
@return return, return_description
/*/
WSMETHOD GET BYID WSRECEIVE companyId, branchId, laborProcessId HEADERPARAM authorization WSSERVICE laborProcess

	Local cResponse := ""
	Local lRet 		:= .T.
	Local oJsonData := JsonObject():new()
	Local cVersEnvio := "9.3"
	Private aUrlParam	:= ::aUrlParms

	DEFAULT Self:aUrlParms := {}

	Private cCompanyId	:= ""
	Private cBranchId	:= ""
	Private cProcessId	:= ""
	Private cCpfTrab	:= ""
	Private cSeqTrab	:= ""

	BEGIN SEQUENCE

		fResetErrorHandler()
		fSetErrorHandler(OemToAnsi(STR0030)) // "Id do processo inválido, a chave deve respeitar a estrutura companyId;branchId;nrProcTrab;cpfTrab;ideSeqTrab."
		If !Empty(Self:aUrlParms) .And. !Empty(Self:aUrlParms[1]) .And. Len(StrTokArr2(Self:aUrlParms[1],";",.T.)) >= 4
			cProcessId	:= StrTokArr2(Self:aUrlParms[1],";",.T.)[3]
			cCpfTrab	:= StrTokArr2(Self:aUrlParms[1],";",.T.)[4]
			If Len(StrTokArr2(Self:aUrlParms[1],";",.T.)) >= 5
				cSeqTrab	:= StrTokArr2(Self:aUrlParms[1],";",.T.)[5]
			EndIf
		Else
			fSendMess(400,OemToAnsi(STR0012),.T.,400,OemToAnsi(STR0030),,) // "Não foi possível concluir esta operação. Verifique!" // "Id do processo inválido, a chave deve respeitar a estrutura companyId;branchId;nrProcTrab;cpfTrab."
		EndIf

		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		fResetErrorHandler()

		// Obtem json com os dados a serem retornados
		lRet := fGetById(@oJsonData, cVersEnvio)

		// Compress String And Set Response
		cResponse := fCompress(@oJsonData)
		::SetResponse(cResponse)

	// RECOVER
	// 	lRet := .F.
	// 	ErrorBlock(bErrorBlock)
	// 	fSendError(500,oError:Description,.T.,500,STR0009,,) // STR0009: "Ocorreu uma falha no retorno da Informação."
	END SEQUENCE

	FreeObj(oJsonData)

Return lRet

// Retorna Processos trabalhistas
/*/{Protheus.doc} GET ALL
Método responsável pelo retorno de todos os processos cadastrados
@author  martins.marcio
@since   20/08/2024
@version 12.1.2310
@return return, return_description
/*/
WSMETHOD GET ALL QUERYPARAM companyId, branchId, page, pageSize, order, nrProcTrab HEADERPARAM authorization WSSERVICE laborProcess

	Local cResponse As Character
	Local lRet 		:= .T.
	Local oJsonData := JsonObject():new()

	Private cCompanyId	As Character
	Private cBranchId	As Character
	Private cProcessId	As Character
	Private cCpfTrab	As Character
	Private cSeqTrab	As Character
	Private cOrder		As Character
	//Private cFields		As Character
	Private nNumePage	:= PAGE_DEFAULT
	Private nPageSize	:= PAGESIZE_DEFAULT

	BEGIN SEQUENCE

		fResetErrorHandler()

		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		fResetErrorHandler()

		// Obtem json com os dados a serem retornados
		lRet := fGetAll(@oJsonData)

		// Compress String And Set Responser
		cResponse := fCompress(@oJsonData)
		::SetResponse(cResponse)

	// RECOVER
	// 	lRet := .F.
	// 	ErrorBlock(bErrorBlock)
	// 	fSendError(500,oError:Description,.T.,500,STR0009,,) // STR0009: "Ocorreu uma falha no retorno da Informação."
	END SEQUENCE

	FreeObj(oJsonData)

Return lRet

// Insere um Processo trabalhista no Layout S-1.3 ou superior
/*/{Protheus.doc} POST
 TODO Método responsável pela inclusão de um Processo trabalhista no Layout S-1.3 ou superior
@author  martins.marcio
@since   21/08/2024
@version 12.1.2310
@return return, return_description
/*/

WSMETHOD POST QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcess

	Local oJson As OBJECT
	Local oBody As OBJECT
	Local cBody As Character
	Local cErroMsg As Character
	Local lRetorno As Logical
	Local cRetorno := ""
	Local aLog := {}
	Local cVersEnvio := "9.3"

	Private cId As Character
	Private cCompanyId As Character
	Private cBranchId As Character
	Private cProcessId As Character
	Private cCpfTrab As Character
	Private cSeqTrab	As Character

	Private oError
	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )

	BEGIN SEQUENCE

		oBody		:= JsonObject():New()
		cBody		:= Self:GetContent()
		lRetorno	:= .F.
		cErroMsg	:= oBody:FromJSON(DecodeUtf8(cBody))

		//Valida dados da mensagem/contrato da API
		If cErroMsg != Nil  .Or. Len(oBody:GetNames()) == 0  .Or. !(ValType(oBody['items']) == "A" .And. !Empty(oBody['items']))
			fSendMess(400,STR0005,.T.,400,STR0015,,) //"Corpo da mensagem inválido ou inexistente. Verifique a informação e envie novamente." ## "Erro na validação do recebimento da mensagem"
			return (lRetorno)
		Else
			oJson := oBody['items'][1]
		EndIf

		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If !fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		cProcessId	:= oJson['infoProcesso']['nrProcTrab']
		cCpfTrab	:= AllTrim(oJson['ideTrab']['cpfTrab'])
		cId 		:= cCompanyId + ";" + cBranchId + ";" + cProcessId + ";" + cCpfTrab //"companyId;branchId;processId;cpfTrab"

		If RE0->(ColumnPos("RE0_IDSQPR")) > 0
			cVersEnvio := "9.3.4"
		EndIf

		//Não está permitida a inclusão de um registro pela tela:
		aAdd(aLog, oEmToAnsi(STR0041)) //"Para a inclusão de Processo utilize a rotina Manutenção de Processos Trabalhistas do módulo SGAGPE (APTA100)."
		fSendMess(403, oEmToAnsi(STR0040),.T.,403,ArrTokStr(aLog),,) //"A inclusão não é permitida por esta rotina."
		lRet := .F.
		Return lRet

		// GRAVA DADOS NAS TABELAS
		lRetorno := fGrvTab(3, oJson, @cErroMsg, cVersEnvio)

		If lRetorno
			cRetorno :=  fSendJson(oBody,cId)
			::SetResponse(cRetorno)
		Else
			aLog := {cErroMsg}
			fSendMess(400,STR0012,.T.,400,ArrTokStr(aLog),,) // "não foi possível concluir esta operação. Verifique!"
		EndIf

		// RECOVER
			//ErrorBlock(bErrorBlock)
			//fSendMess(500,oError:Description,.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da Informação."
		// 	fSendMess(500,"Falha crítica",.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da Informação."
		// 	lRetorno := .F.
	END SEQUENCE

Return (lRetorno)

// Altera um Processo trabalhista
/*/{Protheus.doc} PUT
Método responsável pela alteração de um Processo trabalhista no layout S-1.3 ou superior
@author  martins.marcio
@since   21/08/2024
@version 12.1.2310
@return return, return_description
/*/
WSMETHOD PUT QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcess

	Local oJson As OBJECT
	Local oBody As OBJECT
	Local cBody As Character
	Local cErroMsg As Character
	Local lRetorno As Logical
	Local cRetorno := ""
	Local cVersEnvio := "9.3"

	Private cId As Character
	Private cCompanyId As Character
	Private cBranchId As Character
	Private cProcessId As Character
	Private cCpfTrab As Character
	Private cSeqTrab As Character
	Private oError
	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )

	BEGIN SEQUENCE

		oBody		:= JsonObject():New()
		cBody		:= Self:GetContent()
		lRetorno	:= .F.
		cErroMsg	:= oBody:FromJSON(DecodeUtf8(cBody))

		//Valida dados da mensagem/contrato da API
		If cErroMsg != Nil  .Or. Len(oBody:GetNames()) == 0 .Or. !(ValType(oBody['items']) == "A" .And. !Empty(oBody['items']))
			fSendMess(400,STR0005,.T.,400,STR0015,,) //"Corpo da mensagem inválido ou inexistente. Verifique a informação e envie novamente." ## "Erro na validação do recebimento da mensagem"
			return (lRetorno)
		Else
			oJson := oBody['items'][1]
		EndIf

		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If ! fcheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		cProcessId	:= oJson['infoProcesso']['nrProcTrab']
		cCpfTrab	:= AllTrim(oJson['ideTrab']['cpfTrab'])
		cId			:= cCompanyId + ";" + cBranchId + ";" + cProcessId + ";" + cCpfTrab //"companyId;branchId;processId;cpfTrab"

		If RE0->(ColumnPos("RE0_IDSQPR")) > 0
			cVersEnvio := "9.3.4"
		EndIf

		// GRAVA DADOS NAS TABELAS
		lRetorno := fGrvTab(4, oJson, @cErroMsg, cVersEnvio)

		If lRetorno
			cRetorno :=  fSendJson(oBody, cId)
			::SetResponse(cRetorno)
		Else
			aLog := {cErroMsg}
			fSendMess(400,STR0012,.T.,400,ArrTokStr(aLog),,) // "Não foi possível concluir esta operação. Verifique!"
		EndIf

		//RECOVER
			//ErrorBlock(bErrorBlock)
			//fSendMess(500,oError:Description,.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."
			//fSendMess(500,"Falha crítica",.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."
			//lRetorno := .F.
	END SEQUENCE

	FreeObj(oBody)

Return (lRetorno)

// Exclusão do Processo trabalhista
/*/{Protheus.doc} DELETE
Método responsável pela exclusão de um Processo trabalhista
@author  martins.marcio
@since   21/08/2024
@version 12.1.2310
@return return, return_description
/*/
WSMETHOD DELETE QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcess
	Local aLog := {}
	Local lRetorno := .F.

	aAdd(aLog, OemToAnsi(STR0037)) //Não é possível realizar a exclusão através desta tela, utilize a rotina de Cadastro de Processos do módulo SIGAGPE (APTA100).
	fSendMess(403,OemToAnsi(STR0038),.T.,403,ArrTokStr(aLog),,) //"A exclusão não é permitida por esta rotina."

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvTab
Atualiza tabelas com base no json recebido no body da mensagem
@author  martins.marcio
@since   24/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvTab(nOpc, oJson, cErroMsg, cVersEnvio)
	Local lRet		:= .T.
	Local aInfoRE0	:= {}
	Local aInfoRE1	:= {}
	Local aInfoE0B	:= {}
	Local aInfoE0C	:= {}
	Local aInfoE0D	:= {}
	Local nI		:= 0
	Local nX		:= 0
	Local nUnic		:= 0
	Local nExterno	:= 0
	Local aInfoE0A	:= {}
	Local aInfoE0G	:= {}
	Local aUnicE0B	:= {}
	Local cChvUnic	:= ""
	Local cChaveE0B := ""
	Local lAchouCPF	:= .F.
	Local cChvRE0	:= ""
	Local aIdePeriod := {}
	Local cE0DCompet := ""
	Local aJUniCtr	:= {}
	Local aMudCateg	:= {}
	Local lExterno	:= .F.
	Local cChvVara	:= ""
	Local aAbonos	:= {}
	Local cAbonos	:= ""
	Local nTipoInsc	:= ""
	Local nTpCCP	:= ""
	Local nIdVara	:= 0
	Local cProjud	:= ""
	Local cReclam	:= ""
	Local lTudoOk	:= .F.
	Local cCpoChvRE0 := "RE0_FILIAL+RE0_PROJUD"
	Local cMateSoc	:= ""

	DEFAULT nOpc	:= 3
	DEFAULT oJson	:= ""
	DEFAULT cErroMsg := ""
	DEFAULT cVersEnvio := "9.2"

	Private cMsgErrGrv := ""
	Private nTpInsc := 0
	Private cNrInsc	:= ""
	Private cIdPrVinc := ""
	Private nTamIdSqPr	:= 3

	Begin Transaction

		If ValType(oJson) == "J"
			//RE0 - Processos
			If oJson['infoProcesso']:hasProperty("ideResp")
				nTipoInsc := oJson['infoProcesso']['ideResp']['tpInsc']
				aAdd(aInfoRE0,{ "RE0", "RE0_TPINSC", If(nTipoInsc <= 0 , "", cValtoChar(nTipoInsc))})
				aAdd(aInfoRE0,{ "RE0", "RE0_NINSC",		oJson['infoProcesso']['ideResp']['nrInsc'] })

				If cVersEnvio >= "9.3"
					If oJson['infoProcesso']['ideResp']:hasProperty("dtAdmRespDir") .And. !Empty(oJson['infoProcesso']['ideResp']['dtAdmRespDir'])
						aAdd(aInfoRE0,{ "RE0", "RE0_RESPDT", fJToD(oJson['infoProcesso']['ideResp']['dtAdmRespDir']) })
					EndIf
					If oJson['infoProcesso']['ideResp']:hasProperty("matRespDir") .And. !Empty(oJson['infoProcesso']['ideResp']['matRespDir'])
						aAdd(aInfoRE0,{ "RE0", "RE0_RESPAD", oJson['infoProcesso']['ideResp']['matRespDir'] })
					EndIf
				EndIf
			EndIf

			aAdd(aInfoRE0,{ "RE0", "RE0_TPPROC", If(cValtoChar(oJson['infoProcesso']['origem']) == "1", "J", "A") })
			aAdd(aInfoRE0,{ "RE0", "RE0_PROJUD",	oJson['infoProcesso']['nrProcTrab'] })
			aAdd(aInfoRE0,{ "RE0", "RE0_OBS", 		oJson['infoProcesso']['obsProcTrab'] })

			aAdd(aInfoRE0,{ "RE0", "RE0_DTDECI", 	fJToD(oJson['infoProcesso']['dadosCompl']['infoProcJud']['dtSent']) }) //D
			aAdd(aInfoRE1,{ "RE1", "RE1_UF"	, 		oJson['infoProcesso']['dadosCompl']['infoProcJud']['ufVara'] })
			aAdd(aInfoRE1,{ "RE1", "RE1_CODMUN", 	cValtoChar(oJson['infoProcesso']['dadosCompl']['infoProcJud']['codMunic']) })
			aAdd(aInfoRE1,{ "RE1", "RE1_IDVARA", 	cValtoChar(oJson['infoProcesso']['dadosCompl']['infoProcJud']['idVara']) })

			aAdd(aInfoRE0,{ "RE0", "RE0_DTCCP",		fJToD(oJson['infoProcesso']['dadosCompl']['infoCCP']['dtCCP']) }) //D

			nTpCCP := oJson['infoProcesso']['dadosCompl']['infoCCP']['tpCCP']
			aAdd(aInfoRE0,{ "RE0", "RE0_TPCCP", 	If(nTpCCP  <= 0 , "", cValtoChar(nTpCCP))})
			aAdd(aInfoRE0,{ "RE0", "RE0_CNPJCC", 	oJson['infoProcesso']['dadosCompl']['infoCCP']['cnpjCCP'] })

			cProjud := PadR( oJson['infoProcesso']['nrProcTrab'], FWSX3Util():GetFieldStruct( "RE0_PROJUD")[3])
			cChvRE0	:= xFilial("RE0") + cProjud
			If cVersEnvio >= "9.3.4"
				If oJson['ideTrab']:hasProperty("ideSeqTrab")
					nTamIdSqPr	:= FWSX3Util():GetFieldStruct( "RE0_IDSQPR")[3]
					If oJson['ideTrab']['ideSeqTrab'] <= 0 //RE0_IDSQPR
						//A tela envia -1 quando a sequencia não estiver preenchida, 0 é um valor reservado
						cSeqTrab	:= SPACE(nTamIdSqPr)
					Else
						cSeqTrab	:= StrZero(oJson['ideTrab']['ideSeqTrab'], nTamIdSqPr)
					EndIf
					cChvRE0		:= cChvRE0 + cSeqTrab
					cCpoChvRE0	:= "RE0_FILIAL+RE0_PROJUD+RE0_IDSQPR"
					aAdd(aInfoRE0,{ "RE0",	"RE0_IDSQPR",	cSeqTrab })
				EndIf
				cId		:= cCompanyId + ";" + cBranchId + ";" + cProcessId + ";" + cCpfTrab + ";" + AllTrim(Str(oJson['ideTrab']['ideSeqTrab'])) //"companyId;branchId;processId;cpfTrab;ideSeqTrab"
			EndIf

			// Verifica a existência do Processo / Sequencia
			DbSelectArea("RE0")
			RE0->(DbSetOrder(8)) //RE0_FILIAL+RE0_PROJUD+RE0_IDSQPR
			If !RE0->( DbSeek(cChvRE0) )
				cErroMsg := OemToAnsi(STR0022) + cProjud + "-" + cSeqTrab + OemToAnsi(STR0023) // "O processo (" ## ") não existe na tabela RE0, verifique!"
				lRet := .F.
			Else
				//Verifica se o cpfTrab corresponde com o CPF do reclamante na tabela RD0
				While RE0->( !Eof() .And. &(cCpoChvRE0) == cChvRE0) .And. !lAchouCPF
					If AllTrim(Posicione("RD0", 1, xFilial("RD0") + RE0_RECLAM, "RD0_CIC")) == cCpfTrab
						cReclam := RE0->RE0_RECLAM
						lAchouCPF := .T.
						EXIT
					EndIf
					RE0->(DBSkip())
				EndDo
				If !lAchouCPF
					cErroMsg := OemToAnsi(STR0028) + cCpfTrab + OemToAnsi(STR0029) // "O CPF do trabalhador(cpfTrab) ### não corresponde com o CPF do reclamante do processo."
					lRet := .F.
					DisarmTransaction()
					BREAK
				EndIf

				// RE0 - Cadastro de Processos
				// * A partir desse ponto a RE0 não deve ser desposicionada pois a gravação das tabelas filhas será realizada com base no RE0_PRONUM atual.
				If !Empty(aInfoRE0)
					lRet := fGrvRE0( aInfoRE0, cProjud, cReclam ) // >> Altera tabela RE0
				EndIf

				// RE1 - Cadastro de Vara
				If lRet .And. !Empty(aInfoRE1)
					cChvVara	:= oJson['infoProcesso']['dadosCompl']['infoProcJud']['ufVara'] + ;
								Padl(cValToChar(oJson['infoProcesso']['dadosCompl']['infoProcJud']['codMunic']), FWSX3Util():GetFieldStruct( "RE1_CODMUN")[3], "0")
					nIdVara		:= oJson['infoProcesso']['dadosCompl']['infoProcJud']['idVara']
					lRet := fGrvRE1( cProjud, nIdVara, cChvVara, cReclam ) // >> Valida tabela RE1
					If !lRet
						cErroMsg := cMsgErrGrv
						DisarmTransaction()
						BREAK
					EndIf
				EndIf

				If nOpc == 4 //Alteracao
					//Limpa registros, resíduos de execuções anteriores
					fApagaReg("E0A", 1, xFilial("E0A") + RE0->RE0_NUM + RE0->RE0_RECLAM)
					fApagaReg("E0B", 2, xFilial("E0B") + RE0->RE0_NUM + RE0->RE0_RECLAM)
					fApagaReg("E0C", 1, xFilial("E0C") + RE0->RE0_NUM + RE0->RE0_RECLAM)
					fApagaReg("E0D", 1, xFilial("E0D") + RE0->RE0_NUM + RE0->RE0_RECLAM)
					fApagaReg("E0G", 1, xFilial("E0G") + RE0->RE0_NUM + RE0->RE0_RECLAM)
				EndIf

				// infoContr
				If oJson['ideTrab']:hasProperty("infoContr") .And. ValType(oJson['ideTrab']['infoContr']) == "A" .And. !Empty(oJson['ideTrab']['infoContr'])
					For nI:= 1 to Len(oJson['ideTrab']['infoContr'])
						If 	lRet
							//E0B - Processo por Vinculo inFoContr
							aInfoE0B := {}
							aAdd(aInfoE0B,{ "09", "E0B_TPCONT", cValtoChar(oJson['ideTrab']['infoContr'][nI]['tpContr']) })
							aAdd(aInfoE0B,{ "10", "E0B_INDCON", oJson['ideTrab']['infoContr'][nI]['indContr'] }) // N se ideResp for informado
							aAdd(aInfoE0B,{ "11", "E0B_DTADMO", fJToD(oJson['ideTrab']['infoContr'][nI]['dtAdmOrig'],"C") }) // Data como caracter no dicionario
							aAdd(aInfoE0B,{ "12", "E0B_INDREI", oJson['ideTrab']['infoContr'][nI]['indReint'] })
							aAdd(aInfoE0B,{ "13", "E0B_INDCAT", oJson['ideTrab']['infoContr'][nI]['indCateg'] })
							aAdd(aInfoE0B,{ "14", "E0B_INDNAT", oJson['ideTrab']['infoContr'][nI]['indNatAtiv'] })
							aAdd(aInfoE0B,{ "15", "E0B_INDMDE", oJson['ideTrab']['infoContr'][nI]['indMotDeslig'] })
							cMateSoc := PADR(oJson['ideTrab']['infoContr'][nI]['matricula'], FWSX3Util():GetFieldStruct( "E0B_CODUNI")[3])
							aAdd(aInfoE0B,{ "06", "E0B_CODUNI", cMateSoc })
							aAdd(aInfoE0B,{ "07", "E0B_CATEFD", cValtoChar(oJson['ideTrab']['infoContr'][nI]['codCateg']) })
							aAdd(aInfoE0B,{ "08", "E0B_DTITSV", fJToD(oJson['ideTrab']['infoContr'][nI]['dtInicio']) }) //D

							If !Empty(aInfoE0B)
								cChaveE0B := xFilial("E0B") + RE0->RE0_NUM + RE0->RE0_RECLAM
								cChaveE0B += cMateSoc  //E0B_CODUNI
								cChaveE0B += PADR(oJson['ideTrab']['infoContr'][nI]['codCateg'], FWSX3Util():GetFieldStruct( "E0B_CATEFD")[3]) //E0B_CATEFD
								cChaveE0B += fJToD(oJson['ideTrab']['infoContr'][nI]['dtInicio'],"C") //E0B_DTITSV

								If oJson['ideTrab']['infoContr'][nI]:hasProperty("infoCompl")
									aAdd(aInfoE0G,{ "2", "E0G_MEM", oJson['ideTrab']['infoContr'][nI]['infoCompl']:toJSON() })
									lExterno	:= .T.
								EndIf

								If cVersEnvio >= "9.3.4"
									//Garante que a matricula(E0B_CODUNI) não existe em outra sequencia do mesmo processo
									If fMatInE0B(cMateSoc, @cErroMsg)
										lRet := .F.
										DisarmTransaction()
										BREAK
									EndIf
								EndIf

								lRet := fGrvE0B(aInfoE0B, cChaveE0B, lExterno) // >> Grava na tabela E0B

								nTpInsc := cValToChar(oJson['ideTrab']['infoContr'][nI]['ideEstab']['tpInsc'])
								cNrInsc	:= oJson['ideTrab']['infoContr'][nI]['ideEstab']['nrInsc']

								// E0A - Mudança de Categoria
								aMudCateg := oJson['ideTrab']['infoContr'][nI]['mudCategAtiv']
								If ValType(aMudCateg) == "A"  .And. !Empty(aMudCateg)
									For nX := 1 to Len(aMudCateg)
										If !Empty(aMudCateg[nX]['dtMudCategAtiv'])
											aInfoE0A := {}
											aAdd(aInfoE0A,{ "10", "E0A_NCAT",	cValtoChar(aMudCateg[nX]['codCateg']) })
											aAdd(aInfoE0A,{ "11", "E0A_NATUR",	cValtoChar(aMudCateg[nX]['natAtividade']) })
											aAdd(aInfoE0A,{ "09", "E0A_DTALT",	fJToD(aMudCateg[nX]['dtMudCategAtiv']) })
											lRet := fGrvE0A(aInfoE0A) // >> Grava na tabela E0A
										EndIf
									Next nX
								EndIf

								//E0B - Unicidade de Contrato
								// Guarda tudo no aUnicE0B para gravação na função fGrvUnic
								aJUniCtr := oJson['ideTrab']['infoContr'][nI]['unicContr']
								If ValType(aJUniCtr) == "A" .And. !Empty(aJUniCtr)
									For nUnic := 1 to Len(aJUniCtr)
										If !Empty(aJUniCtr[nUnic]['matUnic'])
											cChvUnic := xFilial("E0B") + RE0->RE0_NUM + RE0->RE0_RECLAM
											cChvUnic += PADR(aJUniCtr[nUnic]['matUnic'], GetSx3Cache( "E0B_CODUNI", "X3_TAMANHO" ))	//E0B_CODUNI
											cChvUnic += PADR(cValtoChar(aJUniCtr[nUnic]['codCateg']), GetSx3Cache( "E0B_CATEFD", "X3_TAMANHO" ))	//E0B_CATEFD
											cChvUnic += fJToD(aJUniCtr[nUnic]['dtInicio'],"C") 										//E0B_DTITSV
											aAdd( aUnicE0B, { E0B->(Recno()), cChvUnic } )
										EndIf
									Next nUnic
								EndIf

								//E0C - Valores Evento S-2500 infoVlr
								aInfoE0C := {}
								aAdd(aInfoE0C,{ "07", "E0C_COMPIN", fJToD(oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['compIni'],"C")})
								aAdd(aInfoE0C,{ "08", "E0C_COMFIM", fJToD(oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['compFim'],"C")})
								aAdd(aInfoE0C,{ "09", "E0C_REPPRO", cValtoChar(oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['indReperc'])})
								aAdd(aInfoE0C,{ "16", "E0C_INDENS", oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['indenSD']})
								aAdd(aInfoE0C,{ "17", "E0C_ABONO", oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['indenAbono']})

								aAbonos := oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['abono']
								If !Empty(aAbonos)
									cAbonos := fPrepAbon(aAbonos)
									aAdd(aInfoE0C,{ "18", "E0C_MEMO", cAbonos})
								EndIf

								If !Empty(aInfoE0C)
									lRet := fGrvE0C(aInfoE0C) // >> Grava na tabela E0C
								EndIf

								//E0D - Valores mensais S-2500 idePeriodo
								aIdePeriod := oJson['ideTrab']['infoContr'][nI]['ideEstab']['infoVlr']['idePeriodo']
								If ValType(aIdePeriod) == "A" .And. !Empty(aIdePeriod)
									For nX := 1 To Len(aIdePeriod)
										aInfoE0D := {}
										cE0DCompet := fJToD(aIdePeriod[nX]['perRef'],"C")
										aAdd(aInfoE0D,{ "07", "E0D_COMPET", cE0DCompet})
										aAdd(aInfoE0D,{ "08", "E0D_GRAUEX", cValtoChar(aIdePeriod[nX]['baseCalculo']['infoAgNocivo']['grauExp'])})
										aAdd(aInfoE0D,{ "09", "E0D_BCINSS", aIdePeriod[nX]['baseCalculo']['vrBcCpMensal']})
										aAdd(aInfoE0D,{ "10", "E0D_BCCP13", aIdePeriod[nX]['baseCalculo']['vrBcCp13']})
										aAdd(aInfoE0D,{ "18", "E0D_FGTSPR", aIdePeriod[nX]['infoFGTS']['vrBcFGTSProcTrab']})
										aAdd(aInfoE0D,{ "19", "E0D_FGTSSE", aIdePeriod[nX]['infoFGTS']['vrBcFGTSSefip']})
										aAdd(aInfoE0D,{ "20", "E0D_FGTSAN", aIdePeriod[nX]['infoFGTS']['vrBcFGTSDecAnt']})
										aAdd(aInfoE0D,{ "16", "E0D_CODCAT", cValtoChar(aIdePeriod[nX]['baseMudCateg']['codCateg'])})
										aAdd(aInfoE0D,{ "17", "E0D_BCCPRE", aIdePeriod[nX]['baseMudCateg']['vrBcCPrev']})
										If cVersEnvio >= "9.3" .And. aIdePeriod[nX]:hasProperty("infoInterm")
											If !Empty(aIdePeriod[nX]['infoInterm'])
												aAdd(aInfoE0D,{ "21", "E0D_MEMO", RhAToJson(aIdePeriod[nX]['infoInterm'],"infoInterm")})
											EndIf
										EndIf
										lRet := fGrvE0D(aInfoE0D, cE0DCompet) // >> Grava na tabela E0D
									Next nX
								EndIf

								If lExterno
									For nExterno := 1 to Len(aInfoE0G)
										lRet := fGrvE0G(aInfoE0G[nExterno], cIdPrVinc) // >> Grava na tabela E0G
									Next nExterno
								EndIf

							EndIf
						EndIf
					Next nI
				EndIf

				If !Empty(aUnicE0B)
					lRet := fGrvUnic(aUnicE0B) // >> Grava TODAS as unicidades identificadas (E0B)
				EndIf
			EndIf
		EndIf
		lTudoOk := .T.
	End Transaction

	If lRet .And.!lTudoOk
		cErroMsg := OemToAnsi(STR0044) //"Erro inesperado, certifique-se que foram aplicadas as ultimas atualizações de dicionário."
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvRE0
Altera dados na tabela RE0 - Cadastro de Processos
@author  martins.marcio
@since   26/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvRE0(aInfoRE0, cNrProcTra, cReclam)
	Local lRet	:= .T.
	Local nI	:= 0

	DEFAULT aInfoRE0	:= {}
	Default cNrProcTra	:= ""
	Default cReclam		:= ""

	If RE0->RE0_PROJUD == cNrProcTra .And. RE0->RE0_RECLAM == cReclam
		RecLock("RE0", .F.)
		For nI := 1 To Len(aInfoRE0)
			If aInfoRE0[nI][2] == "RE0_OBS" // Campo memo
				MsMm(fgetCdMemo(aInfoRE0[nI][2])[2], /*nTam*/, /*nLin*/, aInfoRE0[nI][3], 1, /*nTabSize*/, /*lWrap*/, "RE0", fgetCdMemo(aInfoRE0[nI][2])[1], "RE6")
				RecLock("RE0", .F.) // Garante o lock após o MSMM
			Else
				&(aInfoRE0[nI][2]) := aInfoRE0[nI][3]
			EndIf
		Next nI
		RE0->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvRE1
Grava dados na tabela RE1 - Cadastro de Varas
@author  martins.marcio
@since   26/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvRE1(cNrProcTra , nIdVara, cChvVara, cReclam)

	Local lRet			:= .F.

	DEFAULT cNrProcTra	:= ""
	DEFAULT nIdVara		:= 0
	DEFAULT cChvVara	:= ""
	Default cReclam		:= ""

	//Verifica se a vara está correta
	DbSelectArea("RE1")
	RE1->(DbSetOrder(1)) //RE1_FILIAL+RE1_COMAR+RE1_VARA
	If RE1->( DbSeek(xFilial("RE1") + RE0->RE0_COMAR) )
		While !RE1->(Eof()) .And. RE1->RE1_FILIAL + RE1->RE1_COMAR == xFilial("RE1") + RE0->RE0_COMAR
			If Val(RE1->RE1_IDVARA) == nIdVara .And. RE1->RE1_UF + RE1->RE1_CODMUN == cChvVara
				lRet := .T.
				Exit
			EndIf
			RE1->(dbskip())
		EndDo
	EndIf

	If lRet
		cNewVara	:= RE1->RE1_VARA
		DbSelectArea("RE0")
		If RE0->RE0_PROJUD == cNrProcTra .And. RE0->RE0_RECLAM == cReclam
			If RE0->RE0_VARA <> cNewVara
				RecLock("RE0", .F.)
				RE0->RE0_VARA := cNewVara
				RE0->RE0_COMAR := RE1->RE1_COMAR
				RE0->(MsUnlock())
			EndIf
		EndIf
	Else
		//"Não existe Vara relacionada à Unidade Federal e Cód. de Município informados cadastrada em que o processo tramitou. "
		//"Cadastrar Vara com os dados correspondentes vincular ao processo."
		cMsgErrGrv := OemToAnsi(STR0034)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvSRB
Grava dados na tabela SRB - Dependentes
@author  raquel.andrade
@since   08/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvSRB(aInfoSRB , cChvSra)
	Local lRet		:= .T.
	Local lExDep	:= .F.

	DEFAULT aInfoSRB	:= {}
	DEFAULT cChvSra		:= ""

	DbSelectArea("SRB")
	SRB->(DbSetOrder(1)) //RB_FILIAL, RB_MAT, RB_COD
	If SRB->( DbSeek(cChvSra) )
		While !SRB->(Eof()) .And. SRB->RB_FILIAL + SRB->RB_MAT == cChvSra
			If aInfoSRB[1] == SRB->RB_CIC .And. aInfoSRB[2] == SRB->RB_TPDEP
				lExDep := .T.
				RecLock("SRB", .F.)
				SRB->RB_DESCDEP	:= AllTrim(aInfoSRB[3])
				SRB->(MsUnlock())
				Exit
			EndIf
			SRB->(dbskip())
		EndDo

		If !lExDep
			//"Dados Incompatíveis no Cadastro de Dependente para o CPF informado - "
			cMsgErrGrv := OemToAnsi(STR0035) + aInfoSRB[1]
			lRet := .F.
		EndIf
	Else
		//"Não existe Dependente cadastrado com os dados informados. Para trabalhadores que possuem informação no evento S-2190, S-2200 ou S-2300, novos dependentes devem ser incluídos acessando o cadastro de Dependentes(GPEA020)."
		cMsgErrGrv := OemToAnsi(STR0036)
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fBscChSRA
Busca chave Filial + Matrícula na SRA - Cadastro de Funcionários
@author  raquel.andrade
@since   08/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fBscChSRA(cCpfTrab)
	Local cChave	:= ""
	Local cFilFunc	:= ""
	Local cMatFunc	:= ""
	Local cQryAlias := GetNextAlias()

	DEFAULT cCpfTrab	:= ""

	BeginSql alias cQryAlias
		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_CIC, SRA.RA_DEMISSA, SRA.RA_SITFOLH, SRA.RA_ADMISSA
		FROM %table:SRA% SRA
		WHERE SRA.RA_CIC = %exp:cCpfTrab%  AND
		SRA.RA_DEMISSA = '' AND
		SRA.RA_SITFOLH = ''AND
		SRA.%notDel%
		ORDER BY SRA.RA_ADMISSA DESC
	EndSql

	If (cQryAlias)->(!Eof())
		cFilFunc	:= (cQryAlias)->RA_FILIAL
		cMatFunc	:= (cQryAlias)->RA_MAT
	EndIf

	(cQryAlias)->(DbCloseArea())

	cChave	:= cFilFunc + cMatFunc

Return cChave

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0B
Grava dados na tabela E0B
@author  martins.marcio
@since   26/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0B(aInfoE0B, cChaveE0B, lExterno)
	Local lRet	:= .T.
	Local nZ	:= 0
	Local cIdVinc	:= ""

	DEFAULT aInfoE0B	:= {}
	DEFAULT cChaveE0B	:= ""
	DEFAULT lExterno	:= .F.

	DbSelectArea("E0B")
	E0B->(DbSetOrder(2)) // E0B_FILIAL+E0B_PRONUM+E0B_RECLAM+E0B_CODUNI+E0B_CATEFD+E0B_DTITSV+E0B_IDVINC
	If !E0B->( DbSeek(cChaveE0B ) )
		RecLock("E0B", .T.)
		cIdVinc			:= GetSx8Num("E0B","E0B_IDVINC")
		E0B->E0B_FILIAL	:= xFilial("E0B",RE0->RE0_FILIAL)	//01
		E0B->E0B_PRONUM	:= RE0->RE0_NUM						//02
		E0B->E0B_RECLAM	:= RE0->RE0_RECLAM					//03
		E0B->E0B_IDVINC	:= cIdVinc							//04
		E0B->E0B_EXT	:= If(lExterno, "1","2")
	Else
		RecLock("E0B", .F.)
		cIdVinc	:= E0B->E0B_IDVINC
	EndIf

	cIdPrVinc	:= If(Empty(cIdPrVinc), cIdVinc,cIdPrVinc)

	For nZ := 1 To Len(aInfoE0B)
		&(aInfoE0B[nZ][2]) := aInfoE0B[nZ][3]
	Next nZ
	E0B->(MsUnlock())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvUnic
Grava unicidade de contrato na tabela E0B
@author  martins.marcio
@since   27/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvUnic(aUnicE0B)
	Local lRet	:= .T.
	Local nZ	:= 0
	Local aArea := GetArea()
	Local cChave	:= ""
	Local cIdVinc	:= ""
	Local nRecFilh	:= 0

	DEFAULT aUnicE0B	:= {}

	If !Empty(aUnicE0B)
		DbSelectArea("E0B")
		For nZ := 1 To Len(aUnicE0B)
			cChave	:= aUnicE0B[nZ][2]
			cIdVinc	:= Posicione("E0B", 2, cChave, "E0B_IDVINC") //E0B_FILIAL+E0B_PRONUM+E0B_RECLAM+E0B_CODUNI+E0B_CATEFD+E0B_DTITSV+E0B_IDVINC
			If !Empty(cIdVinc)
				nRecFilh := aUnicE0B[nZ][1]
				DbGoTo(nRecFilh)
				RecLock("E0B", .F.)
				E0B_VININC	:= cIdVinc // E0B_IDVINC do vinculo E0B principal
				E0B->(MsUnlock())
			else
				lRet := .F.
				cMsgErrGrv := OemToAnsi(STR0021) //"não foi possível encontrar o registro pai da unicidade de contrato."
			EndIf
		Next nZ
	EndIf
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0C
Grava dados na tabela E0C
@author  martins.marcio
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0C(aInfoE0C)
	Local lRet	:= .T.
	Local nY	:= 0

	DEFAULT aInfoE0C	:= {}

	If !Empty(aInfoE0C)
		DbSelectArea("E0C")
		E0C->(DbSetOrder(1)) // E0C_FILIAL+E0C_PRONUM+E0C_RECLAM+E0C_IDVINC+E0C_TPINSC+E0C_NINSC
		If !E0C->( DbSeek(xFilial("E0C",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC + nTpInsc + cNrInsc ) )
			RecLock("E0C", .T.)
			E0C_FILIAL	:= xFilial("E0C",RE0->RE0_FILIAL)	//01
			E0C_PRONUM	:= RE0->RE0_NUM						//02
			E0C_RECLAM	:= RE0->RE0_RECLAM					//03
			E0C_IDVINC	:= E0B->E0B_IDVINC					//04
			E0C_TPINSC	:= nTpInsc							//05
			E0C_NINSC	:= cNrInsc							//06
		Else
			RecLock("E0C", .F.)
		EndIf

		For nY := 1 To Len(aInfoE0C)
			If aInfoE0C[nY][2] == "E0C_MEMO"
				MsMm(fgetCdMemo(aInfoE0C[nY][2])[2], /*nTam*/, /*nLin*/, aInfoE0C[nY][3], 1, /*nTabSize*/, /*lWrap*/, "E0C", fgetCdMemo(aInfoE0C[nY][2])[1], "RDY")
				RecLock("E0C", .F.) // Garante o lock após o MSMM
			Else
				&(aInfoE0C[nY][2]) := aInfoE0C[nY][3]
			EndIf
		Next nY
		E0C->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0D
Grava dados na tabela E0D
@author  martins.marcio
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0D(aInfoE0D, cE0DCompet)
	Local lRet	:= .T.
	Local nY	:= 0

	DEFAULT aInfoE0D	:= {}
	DEFAULT cE0DCompet	:= ""

	If !Empty(aInfoE0D)
		DbSelectArea("E0D")
		E0D->(DbSetOrder(1)) // E0D_FILIAL+E0D_PRONUM+E0D_RECLAM+E0D_IDVINC+E0D_TPINSC+E0D_NINSC+E0D_COMPET
		If !E0D->( DbSeek(xFilial("E0D",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC + cValToChar(nTpInsc) + cNrInsc + cE0DCompet ) )
			RecLock("E0D", .T.)
			E0D_FILIAL	:= xFilial("E0D",RE0->RE0_FILIAL)	//01
			E0D_PRONUM	:= RE0->RE0_NUM						//02
			E0D_RECLAM	:= RE0->RE0_RECLAM					//03
			E0D_IDVINC	:= E0B->E0B_IDVINC					//04
			E0D_TPINSC	:= nTpInsc							//05
			E0D_NINSC 	:= cNrInsc							//06
		Else
			RecLock("E0D", .F.)
		EndIf

		For nY := 1 To Len(aInfoE0D)
			If aInfoE0D[nY][2] == "E0D_MEMO"
				MsMm(fgetCdMemo(aInfoE0D[nY][2])[2], /*nTam*/, /*nLin*/, aInfoE0D[nY][3], 1, /*nTabSize*/, /*lWrap*/, "E0D", fgetCdMemo(aInfoE0D[nY][2])[1], "RDY")
				RecLock("E0D", .F.) // Garante o lock após o MSMM
			Else
				&(aInfoE0D[nY][2]) := aInfoE0D[nY][3]
			EndIf
		Next nY
		E0D->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0G
Grava dados na tabela E0G
@author  martins.marcio
@since   26/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0G(aInfoE0G, cIdPrVinc)
	Local lRet		:= .T.
	Local cIdBusca	:= ""

	DEFAULT aInfoE0G	:= {}
	DEFAULT cIdPrVinc	:= ""

	If !Empty(aInfoE0G)
		// Quando for dados de dependentes, sempre deve usar o IDVINC do PRIMEIRO VÍNCULO
		// É dessa forma que os valores são buscados no GET
		cIdBusca	:= If(aInfoE0G[1] == "1",cIdPrVinc,E0B->E0B_IDVINC)
		DbSelectArea("E0G")
		E0G->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC+E0G_TPINF+E0G_IDEXT
		If !E0G->( DbSeek(xFilial("E0G",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cIdBusca + aInfoE0G[1]) )
			RecLock("E0G", .T.)
			E0G_FILIAL	:= xFilial("E0G",RE0->RE0_FILIAL)	//01
			E0G_PRONUM	:= RE0->RE0_NUM						//02
			E0G_RECLAM	:= RE0->RE0_RECLAM					//03
			E0G_IDVINC	:= cIdBusca					//04
			E0G_IDEXT	:= GetSX8Num("E0G","E0G_IDEXT")		//05
			E0G_TPINF	:= aInfoE0G[1] // 1 - Dados de Dependente, 2 - Dados de Inf. Complementar

		Else
			RecLock("E0G", .F.)
		EndIf

		MsMm(fgetCdMemo(aInfoE0G[2])[2], /*nTam*/, /*nLin*/, aInfoE0G[3], 1, /*nTabSize*/, /*lWrap*/, "E0G", fgetCdMemo(aInfoE0G[2])[1], "RDY")

		E0G->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0A
Grava dados na tabela E0A
@author  martins.marcio
@since   26/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0A(aInfoE0A)
	Local lRet		:= .T.
	Local nY		:= 0
	Local cChaveE0A	:= ""
	Local cDtAlt	:= ""

	DEFAULT aInfoE0A	:= {}

	If !Empty(aInfoE0A)
		cDtAlt	:= dtoS(aInfoE0A[3][3])
		cChaveE0A	:= xFilial("E0A",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC + cDtAlt
		DbSelectArea("E0A")
		E0A->(DbSetOrder(1)) // E0A_FILIAL+E0A_PRONUM+E0A_RECLAM+E0A_IDVINC+E0A_DTALT+E0A_IDMUD
		If !E0A->( DbSeek(cChaveE0A ) )
			RecLock("E0A", .T.)
			E0A_FILIAL	:= xFilial("E0A",RE0->RE0_FILIAL)	//01
			E0A_PRONUM	:= RE0->RE0_NUM						//02
			E0A_RECLAM	:= RE0->RE0_RECLAM					//03
			E0A_IDVINC	:= E0B->E0B_IDVINC					//04
			E0A_IDMUD	:= GetSX8Num("E0A","E0A_IDMUD")		//05
			E0A_CODUNI	:= E0B->E0B_CODUNI					//06
			E0A_CATEFD	:= E0B->E0B_CATEFD					//07
			E0A_DTTSVE	:= E0B->E0B_DTITSV					//08
		Else
			RecLock("E0A", .F.)
		EndIf

		For nY := 1 To Len(aInfoE0A)
			&(aInfoE0A[nY][2]) := aInfoE0A[nY][3]
		Next nY
		E0A->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fJToD
Converte a data encontrada no json para o formato Date do Protheus
@author  martins.marcio
@since   25/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fJToD(cDateJson, cDtType)
	Local dRet := sToD("")
	DEFAULT cDateJson := ""
	DEFAULT cDtType	  := "D"

	dRet := IIf(cDtType =="D", sToD( StrTran( cDateJson, "-", "" ) ), StrTran( cDateJson, "-", "" ))

Return dRet

/*/{Protheus.doc} getCodMemo
Retorna o campo codigo do campo Memo
@since	25/10/2022
@autor	martins.marcio
@version P12
/*/
Function fgetCdMemo(cNomeMemo)
	Local aCodMemo := {"", ""}
	Default cNomeMemo := ""

	If AllTrim(cNomeMemo) == "RE0_OBS"
		aCodMemo := {"RE0_COBS", RE0->RE0_COBS }
	ElseIf AllTrim(cNomeMemo) == "E0G_MEM"
		aCodMemo := {"E0G_CMEM", E0G->E0G_CMEM }
	ElseIf AllTrim(cNomeMemo) == "E0C_MEMO"
		aCodMemo := {"E0C_CMEM", E0C->E0C_CMEM }
	ElseIf AllTrim(cNomeMemo) == "E0D_MEMO"
		aCodMemo := {"E0D_CMEM", E0D->E0D_CMEM }
	EndIf

Return aCodMemo

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since   27/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSendMess(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode := 500
	DEFAULT cMessage := STR0006 // "Erro desconhecido no processo!"
	DEFAULT lJson := .T.
	DEFAULT nStatus := 500
	Default cDetailMsg := STR0006 // "Erro desconhecido no processo!"
	Default cHelpUrl := ""
	DEFAULT aDetails := {}

	SetRestFault(nCode,EncodeUTF8(OemToAnsi(cMessage)),lJson,nStatus,EncodeUTF8(OemToAnsi(cDetailMsg)),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendJson
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since  27/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSendJson(ojson,cId)
	Local cJson			:= ""
	//Local lcompact := .F.

	// If Type("Self:GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(Self:GetHeader('Accept-Encoding') )
	// 	lCompact := .T.
	// EndIf

	ojson["id"] := cId

	// If(lCompact)
	// 	cJson := fCompress(ojson)
	// Else
		cJson :=  FWJsonSerialize(ojson, .F., .F., .T.)
	// Endif

Return (cJson)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckInfor
Valida as informações recebidas na assinatura da mensagem
@author  martins.marcio
@since   01/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor()

	Local cMessage	:= ""
	Local lRet		:= .T.

	If Empty(cCompanyId)
		cMessage := oEmToAnsi(STR0024) + "companyId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	ElseIf Empty(cBranchId)
		cMessage := oEmToAnsi(STR0024) + "branchId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	EndIf

	If Empty(cMessage)
		If ! FWFilExist(cCompanyId,cBranchId)
			cMessage := oEmToAnsi(STR0024) + "companyId + branchId " //"Falha ao validar as informações básicas da assinatura. Informação: "
		EndIf
	EndIf

	If ! Empty(cMessage)
		fSendError(400,cMessage,.T.,400,cMessage,,)
		lRet := .F.
	EndIf

	/* Persiste parâmetros específicos do GET ALL */
	If IsInCallStack("GET_ALL")
		//  se nPageSize vazio, maior que PAGESIZE_DEFAULT ou negativo assume o DEFAULT
		If ( Empty(nPageSize)) .OR. ( nPageSize > PAGESIZE_DEFAULT ) .OR. ( nPageSize < 1 )
			nPageSize := PAGESIZE_DEFAULT
		EndIf
		// se nPage vazio ou negativo assume o DEFAULT
		If ( Empty(nNumePage)) .OR. ( nNumePage < 1 )
			nNumePage := PAGE_DEFAULT
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetById
Retorna o processo trabalhista desejado
@author  martins.marcio
@since   01/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetById(oJsonData, cVersEnvio)

	Local cQuery  	 	:= ""
	Local lRet 		 	:= .T.
	Local oItemData
	Local aItemQry		:= {}
	Local oCabecData	:= JsonObject():new()
	Local cIdTab		:= ""
	Local cQrAlias 		:= GetNextAlias()
	Local oInfoProc
	Local oIdeResp
	Local oInfoPrJud
	Local oInfoCCP
	Local oDadCompl
	Local oIdeTrab
	Local aInfoContr	:= {}
	Local nIdVara		:= 0
	Local nCodMunic		:= 0
	Local cUfVara		:= ""
	Local nSeqTrab		:= 0
	Local nTamIdSqPr	:= 0

	DEFAULT cVersEnvio := "9.3"
	If RE0->(ColumnPos("RE0_IDSQPR")) > 0
		cVersEnvio := "9.3.4"
	EndIf

	fSetErrorHandler(oEmToAnsi(STR0031)) // "não foi possível realizar a query SQL."

	cQuery += "SELECT 	RE0.RE0_FILIAL BRANCHID,"
	cQuery += "		RE0.RE0_TPPROC ORIGEM,"
	cQuery += "		RE0.RE0_PROJUD NRPROCTRAB,"
	If cVersEnvio >= "9.3.4"
		cQuery += "		RE0.RE0_IDSQPR IDESEQTRAB,"
	EndIf
	cQuery += "		RE0.RE0_DTDECI DTSENT,"
	cQuery += "		RD0.RD0_CIC CPFTRAB,"
	cQuery += "		RE0.RE0_DTCCP DTCCP,"
	cQuery += "		RE0.RE0_TPCCP TPCCP,"
	cQuery += "		RE0.RE0_CNPJCC CNPJCCP,"

	cQuery += "		RE0.R_E_C_N_O_ RECNO"

	cQuery += "		FROM "+ RetSqlName("RE0") + " RE0"
	cQuery += "		LEFT JOIN "+ RetSqlName("RD0") + " RD0 ON RE0.RE0_RECLAM = RD0.RD0_CODIGO"
	cQuery += "		WHERE RE0.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   RE0.RE0_FILIAL = '" + xFilial("RE0") + "'"
	cQuery += "			AND   RE0.RE0_PROJUD = '" + cProcessId + "'"
	cQuery += "			AND   RD0.RD0_CIC = '" + cCpfTrab + "'"
	If cVersEnvio >= "9.3.4"
		nTamIdSqPr := FWSX3Util():GetFieldStruct( "RE0_IDSQPR")[3]
		cSeqTrab := IIf(Val(cSeqTrab) > 0, StrZero(Val(cSeqTrab), nTamIdSqPr), SPACE(nTamIdSqPr))
		cQuery += "			AND   RE0.RE0_IDSQPR = '" + cSeqTrab + "'"
	EndIf
	cQuery += "			AND   RD0.RD0_FILIAL = '" + xFilial("RD0", xFilial("RE0")) + "'"
	cQuery += "			AND   RD0.D_E_L_E_T_ = ' '	"

	cQuery := ChangeQuery(cQuery)
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cQrAlias, .T., .T. )

	(cQrAlias)->(DBGoTop())

	// Get items Properties
	If (cQrAlias)->(!Eof())
		fSetErrorHandler(oEmToAnsi(STR0031)) // "Erro ao montar o objeto json para retorno."

		cIdTab		:= cEmpAnt					+ ";"
		cIdTab		+= cFilAnt					+ ";"
		cIdTab		+= (cQrAlias)->NRPROCTRAB	+ ";"
		cIdTab		+= (cQrAlias)->CPFTRAB
		If cVersEnvio >= "9.3.4"
			nSeqTrab	:= IIf(!Empty((cQrAlias)->IDESEQTRAB), Val((cQrAlias)->IDESEQTRAB), -1)
			cIdTab		+= ";" + cValToChar(nSeqTrab)
		EndIf

		DbSelectArea("RE0")
		RE0->(DbGoTo((cQrAlias)->RECNO))

			oInfoProc	:= JsonObject():new()
				oIdeResp := JsonObject():new()
				If !Empty(RE0->RE0_TPINSC) .Or. !Empty(RE0->RE0_NINSC)
					oIdeResp['tpInsc'] := Val(RE0->RE0_TPINSC)
					oIdeResp['nrInsc'] := RE0->RE0_NINSC
				EndIf
				If cVersEnvio >= "9.3"
					oIdeResp['dtAdmRespDir']	:= fDtToJson(RE0->RE0_RESPDT)
					oIdeResp['matRespDir']		:= AllTrim(RE0->RE0_RESPAD)
				EndIf
			oInfoProc['ideResp'] := oIdeResp
			FreeObj(oIdeResp)
			oInfoProc['origem'] := If((cQrAlias)->ORIGEM == "J", 1, 2)
			oInfoProc['nrProcTrab'] := AllTrim((cQrAlias)->NRPROCTRAB)
			oInfoProc['obsProcTrab'] := EncodeUtf8(MSMM(RE0->RE0_COBS,,,,3,,,"RE0",,"RE6"))
				oDadCompl := JsonObject():new()
					oInfoPrJud := JsonObject():new()
					oInfoPrJud['dtSent']	:= fDtToJson((cQrAlias)->DTSENT)
					If !Empty(RE0->RE0_VARA)
						DbSelectArea("RE1")
						If RE1->(DbSeek(xFilial("RE1", xFilial("RE0")) + RE0->RE0_COMAR + RE0->RE0_VARA ))
							nIdVara		:= Val(RE1->RE1_IDVARA)
							nCodMunic	:= Val(RE1->RE1_CODMUN)
							cUfVara		:= AllTrim(RE1->RE1_UF)
						EndIf
					EndIf
					oInfoPrJud['ufVara']	:= cUfVara
					oInfoPrJud['codMunic']	:= nCodMunic
					oInfoPrJud['idVara']	:= nIdVara
				oDadCompl['infoProcJud'] := oInfoPrJud
				FreeObj(oInfoPrJud)
					oInfoCCP := JsonObject():new()
					If oInfoProc['origem'] == 2
						oInfoCCP['dtCCP']	:= fDtToJson((cQrAlias)->DTCCP)
						oInfoCCP['tpCCP']	:= Val((cQrAlias)->TPCCP)
						oInfoCCP['cnpjCCP']	:= (cQrAlias)->CNPJCCP
					EndIf
				oDadCompl['infoCCP'] := oInfoCCP
				FreeObj(oInfoCCP)
			oInfoProc['dadosCompl'] := oDadCompl
			FreeObj(oDadCompl)

			oIdeTrab	:= JsonObject():new()
			oIdeTrab['cpfTrab'] := cCpfTrab
			DbSelectArea("RD0")
			RD0->(DbSetOrder(6))
			cChvRD0	:= xFilial("RD0") + cCpfTrab + RE0->RE0_RECLAM
			If RD0->(DbSeek(cChvRD0))
				oIdeTrab['nmTrab'] := IIF(!Empty(RD0->RD0_NOME), Left(Alltrim(RD0->RD0_NOME), 70), Alltrim(RD0->RD0_NOME) )
				oIdeTrab['dtNascto'] := fDtToJson(RD0->RD0_DTNASC)
			Else
				oIdeTrab['nmTrab']	 := ""
				oIdeTrab['dtNascto'] := ""
			EndIf

			If cVersEnvio >= "9.3.4"
				oIdeTrab['ideSeqTrab'] := nSeqTrab
			EndIf

			//E0B - infoContr
			aInfoContr := fGetInfCtr(xFilial("E0B") + RE0->RE0_NUM + RE0->RE0_RECLAM, @oIdeTrab, cCpfTrab, cVersEnvio)
			oIdeTrab['infoContr'] := aInfoContr

		oItemData := JsonObject():new()
		oItemData['companyId']	:= cEmpAnt
		oItemData['branchId']	:= cFilAnt
		oItemData['excluidoERP'] := "N"
		oItemData['infoProcesso'] := oInfoProc
		FreeObj(oInfoProc)
		oItemData['ideTrab'] := oIdeTrab
		FreeObj(oIdeTrab)
		oItemData["id"] := cIdTab

		AAdd(aItemQry, oItemData )

		oCabecData["hasNext"] 		  := .F.

	EndIf

	oCabecData["items"] := aItemQry
	oJsonData := oCabecData
	FreeObj(oCabecData)

	fResetErrorHandler()
	(cQrAlias)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetAll
Retorna json com a lista de Processos trabalhistas
@author  martins.marcio
@since   01/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetAll(oJsonData, cVersEnvio)

	Local cQuery  	 	:= ""
	Local lRet 		 	:= .T.
	Local oItemData
	Local aItemQry		:= {}
	Local oCabecData	:= JsonObject():new()
	Local cIdTab		:= ""
	Local cDataBase		:= TcGetDB()
	Local cQrAlias 		:= GetNextAlias()
	Local cOrdQry		:= fOrdQry(cOrder)
	Local nSeqTrab		:= 0
	Local nTamIdSqPr	:= 0

	DEFAULT cVersEnvio := IIf(RE0->(ColumnPos("RE0_IDSQPR")) > 0, "9.3.4", "9.3" )

	dbSelectArea("RE0")

	// Create Paging Control
	cQuery := "		SELECT JSO.* FROM ( "

	cQuery += IIf(cDataBase == "ORACLE"		,"	SELECT ROWNUM ITEMNUMBER, COUNT(1) OVER() AS TOTALNUMBER, DADOS.*  ",;
				IIf(cDataBase == "POSTGRES"	,"	SELECT ROW_NUMBER() OVER( " + cOrdQry + " ) ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER, DADOS.* ",;
											"	SELECT ROW_NUMBER() OVER( " + cOrdQry + " ) ITEMNUMBER, COUNT(1) OVER() TOTALNUMBER, DADOS.* ")) //MSSQL

	cQuery += "			FROM (	"
	cQuery += "			SELECT 	RE0.RE0_FILIAL BRANCHID,"
	cQuery += "					RE0.RE0_TPPROC ORIGEM,"
	cQuery += "					RE0.RE0_PROJUD NRPROCTRAB,"
	If cVersEnvio >= "9.3.4"
		cQuery += "					RE0.RE0_IDSQPR IDESEQTRAB,"
	EndIf
	cQuery += "					RD0.RD0_CIC CPFTRAB,"
	cQuery += "					RD0.RD0_NOME NMTRAB,"
	cQuery += "					RD0.R_E_C_N_O_ RECNO"

	cQuery += "			FROM "+ RetSqlName("RE0") + " RE0"
	cQuery += "			LEFT JOIN "+ RetSqlName("RD0") + " RD0 ON RE0.RE0_RECLAM = RD0.RD0_CODIGO"
	cQuery += "			WHERE RE0.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   RE0.RE0_FILIAL = '" + xFilial("RE0") + "'"
	cQuery += "			AND   RD0.D_E_L_E_T_ = ' '	"
	cQuery += "			AND   RD0.RD0_FILIAL = '" + xFilial("RD0", xFilial("RE0")) + "'"
	If !Empty(cProcessId)
		cQuery += "			AND   RE0.RE0_PROJUD = '" + cProcessId + "'"
	EndIf
	If !Empty(cCpfTrab)
		cQuery += "			AND   RD0.RD0_CIC = '" + cCpfTrab + "'"
	EndIf
	If !Empty(cSeqTrab) .And. cVersEnvio >= "9.3.4"
		nTamIdSqPr := FWSX3Util():GetFieldStruct( "RE0_IDSQPR")[3]
		cSeqTrab := IIf(Val(cSeqTrab) > 0, StrZero(Val(cSeqTrab), nTamIdSqPr), SPACE(nTamIdSqPr))
		cQuery += "			AND   RE0.RE0_IDSQPR = '" + cSeqTrab + "'"
	EndIf

	cQuery += "			) DADOS "

	cQuery += "			) JSO"
	cQuery += "	        WHERE JSO.ITEMNUMBER BETWEEN " + Alltrim(Str((nNumePage - 1) * nPageSize + 1)) + " AND " + Alltrim(Str((nNumePage * nPageSize))) + " "

	cQuery += cOrdQry //ORDER BY

	cQuery := ChangeQuery(cQuery)
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cQrAlias, .T., .T. )

	(cQrAlias)->(DBGoTop())

	If lRet
		// Get items Properties
		While (cQrAlias)->(!Eof())
			oItemData := JsonObject():new()
			cIdTab		:= cEmpAnt					+ ";"
			cIdTab		+= cFilAnt					+ ";"
			cIdTab		+= (cQrAlias)->NRPROCTRAB	+ ";"
			cIdTab		+= (cQrAlias)->CPFTRAB
			If cVersEnvio >= "9.3.4"
				nSeqTrab := IIf(!Empty((cQrAlias)->IDESEQTRAB), Val((cQrAlias)->IDESEQTRAB), -1)
				cIdTab		+= ";" + cValToChar(nSeqTrab)
			EndIf

			oItemData["companyId"]			:= cEmpAnt
			oItemData["branchId"]			:= (cQrAlias)->BRANCHID
			oItemData["origem"]				:= If((cQrAlias)->ORIGEM == "J", 1, 2)
			oItemData["nrProcTrab"]			:= (cQrAlias)->NRPROCTRAB
			If cVersEnvio >= "9.3.4"
				oItemData["ideSeqTrab"]		:= nSeqTrab
			EndIf
			oItemData["cpfTrab"]			:= (cQrAlias)->CPFTRAB
			oItemData["nmTrab"]				:= AllTrim((cQrAlias)->NMTRAB)
			oItemData["id"]					:= cIdTab

			AAdd(aItemQry, oItemData )

			oCabecData["hasNext"] 		  := Iif((cQrAlias)->ITEMNUMBER >= (cQrAlias)->TOTALNUMBER, .F., .T.)

			(cQrAlias)->(DBSkip())
		EndDo

		oCabecData["items"] := aItemQry
		oJsonData := oCabecData
	EndIf

	fResetErrorHandler()
	(cQrAlias)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fOrdQry
Retorna o filtro para ser utilizado na query
@author  martins.marcio
@since  01/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fOrdQry(cApiOrder)
	Local cQryRet	:= " "
	Local aQryFilt	:= {}
	Local nI		:= 0
	Local cCpoOrd	:= ""

	DEFAULT cApiOrder := ""

	If !Empty(cApiOrder)
		aQryFilt := StrTokArr( cApiOrder , ',' )
		For nI := 1 To Len(aQryFilt)
			cCpoOrd := AllTrim(Upper(strTran(aQryFilt[nI], "-", "")))

			If cCpoOrd $ "ORIGEM;NRPROCTRAB;CPFTRAB"
				cQryRet += cCpoOrd
				cQryRet += IIf(LEFT(AllTrim(aQryFilt[nI]),1) == "-", " DESC,", ",")
			EndIf
		Next nI
	EndIf

	If Empty(cQryRet)
		cQryRet := " ORDER BY ORIGEM, NRPROCTRAB, CPFTRAB "
	Else
		cQryRet := Left(cQryRet,(Len(cQryRet)-1))  // Retira a virgula do final da string
		cQryRet := " ORDER BY " + cQryRet
	EndIf

Return cQryRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetInfCtr
Retorna um array de infoContr
@author  martins.marcio
@since  07/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetInfCtr(cChaveE0B, oIdeTrab, cCpfTrab, cVersEnvio)
	Local aInfoContr := {}
	Local oInfoContr
	Local oInfoCompl
	Local oMudCateg
	Local aMudCateg := {}
	Local cErroMsg
	Local cJMemoE0G := ""
	Local cChaveE0A	:= ""
	Local aUniContr	:= {}
	Local oIdeEstab
	Local oInfoVlr
	Local aIdePer := {}
	Local oIdePer
	Local cChaveE0D	:= ""
	Local oBsCalc
	Local oAgNociv
	Local oInfoFGTS
	Local oBsMudCat
	Local oInfoInterm
	Local cMemoE0D	:= ""
	Local cErrMemo	:= ""
	Local nRecE0B
	Local cIdPrVinc	:= ""
	Local cAbonos	:= ""

	DEFAULT cChaveE0B := xFilial("E0B") + RE0->RE0_NUM + RE0->RE0_RECLAM
	DEFAULT cVersEnvio := "9.2"

	DbSelectArea("E0B")
	E0B->(DbSetOrder(2)) // E0B_FILIAL+E0B_PRONUM+E0B_RECLAM+E0B_CODUNI+E0B_CATEFD+E0B_DTITSV+E0B_IDVINC
	If E0B->( DbSeek(cChaveE0B ) )//#empty infoContr[] := aInfoContr
		cIdPrVinc	:= E0B->E0B_IDVINC

		While E0B->( !Eof() .And. E0B_FILIAL+E0B_PRONUM+E0B_RECLAM == cChaveE0B)
			oInfoContr := JsonObject():new()
			oInfoContr['tpContr']		:= Val(E0B->E0B_TPCONT)
			oInfoContr['indContr']		:= E0B->E0B_INDCON
			oInfoContr['dtAdmOrig']		:= fDtToJson(E0B->E0B_DTADMO)
			oInfoContr['indReint']		:= E0B->E0B_INDREI
			oInfoContr['indCateg']		:= E0B->E0B_INDCAT
			oInfoContr['indNatAtiv']	:= E0B->E0B_INDNAT
			oInfoContr['indMotDeslig']	:= E0B->E0B_INDMDE
			oInfoContr['matricula']		:= AllTrim(E0B->E0B_CODUNI)
			oInfoContr['codCateg']		:= Val(E0B->E0B_CATEFD)
			oInfoContr['dtInicio']		:= fDtToJson(E0B->E0B_DTITSV)

			nRecE0B		:= E0B->( Recno() )
			aUniContr := fGetUnic(E0B->E0B_VININC)
			E0B->( dbGoTo(nRecE0B) )

			// Informações Complementares
			DbSelectArea("E0G")
			E0G->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC+E0G_TPINF+E0G_IDEXT
			If E0G->( DbSeek(xFilial("E0G",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC + "2" ) )
				oInfoCompl := JsonObject():new()
				cJMemoE0G := EncodeUtf8(MSMM(E0G->E0G_CMEM,,,,3,,,"E0G",,"RDY"))
				cErroMsg := oInfoCompl:FromJSON(cJMemoE0G)
			Else
				oInfoCompl := getEmptyObj("infoCompl",cVersEnvio)
			EndIf
			oInfoContr['infoCompl'] := oInfoCompl

			aMudCateg := {}
			DbSelectArea("E0A")
			E0A->(DbSetOrder(1)) // E0A_FILIAL+E0A_PRONUM+E0A_RECLAM+E0A_IDVINC+E0A_IDMUD
			cChaveE0A := xFilial("E0A",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC
			If E0A->( DbSeek( cChaveE0A ) ) //#empty mudCategAtiv[] := aMudCateg
				While E0A->( !Eof() .And. E0A_FILIAL+E0A_PRONUM+E0A_RECLAM+E0A_IDVINC == cChaveE0A)
					oMudCateg := JsonObject():new()
					oMudCateg['codCateg']		:= Val(E0A->E0A_NCAT)
					oMudCateg['natAtividade']	:= Val(E0A->E0A_NATUR)
					oMudCateg['dtMudCategAtiv']	:= fDtToJson(E0A->E0A_DTALT)
					aAdd(aMudCateg, oMudCateg)
					E0A->(DBSkip())
				EndDo
			Else
				aMudCateg := getEmptyObj("mudCategAtiv")
			EndIf
			oInfoContr['mudCategAtiv'] := aMudCateg

			oInfoContr['unicContr'] := aUniContr

			oIdeEstab := JsonObject():new()
			oInfoVlr := JsonObject():new()
			DbSelectArea("E0C")
			E0C->(DbSetOrder(1)) // E0C_FILIAL+E0C_PRONUM+E0C_RECLAM+E0C_IDVINC+E0C_TPINSC+E0C_NINSC
			If E0C->( DbSeek(xFilial("E0C",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC ) ) //#empty infoVlr{} := oInfoVlr
				oIdeEstab['tpInsc']			:= Val(E0C->E0C_TPINSC)
				oIdeEstab['nrInsc']			:= E0C->E0C_NINSC
				oInfoVlr['compIni']			:= fDtToJson(E0C->E0C_COMPIN)
				oInfoVlr['compFim']			:= fDtToJson(E0C->E0C_COMFIM)
				oInfoVlr['indReperc']		:= Val(E0C->E0C_REPPRO)
				oInfoVlr['indenSD']			:= E0C->E0C_INDENS
				oInfoVlr['indenAbono']		:= E0C->E0C_ABONO
				cAbonos := EncodeUtf8(MSMM(E0C->E0C_CMEM,,,,3,,,"E0C",,"RDY"))
				oInfoVlr['abono']			:= IIf(empty(cAbonos), {}, fGetAbonos(cAbonos))

				DbSelectArea("E0D")
				E0D->(DbSetOrder(1)) // E0D_FILIAL+E0D_PRONUM+E0D_RECLAM+E0D_IDVINC+E0D_TPINSC+E0D_NINSC+E0D_COMPET
				cChaveE0D := xFilial("E0D",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + E0B->E0B_IDVINC + E0C->E0C_TPINSC + E0C->E0C_NINSC
				aIdePer := {}
				If E0D->( DbSeek( cChaveE0D ) )  //#empty idePeriodo[] := aIdePer
					While E0D->( !Eof() .And. E0D_FILIAL+E0D_PRONUM+E0D_RECLAM+E0D_IDVINC+E0D_TPINSC+E0D_NINSC == cChaveE0D)
						oIdePer := JsonObject():new()
						oIdePer['perRef'] := fDtToJson(E0D->E0D_COMPET)
							oBsCalc  := JsonObject():new()
							oBsCalc['vrBcCpMensal'] := E0D->E0D_BCINSS
							oBsCalc['vrBcCp13'] 	:= E0D->E0D_BCCP13
								oAgNociv := JsonObject():new()
								oAgNociv['grauExp']	:= Val(E0D->E0D_GRAUEX)
							oBsCalc['infoAgNocivo']	:= oAgNociv
						oIdePer['baseCalculo'] := oBsCalc
							oInfoFGTS := JsonObject():new()
							oInfoFGTS['vrBcFGTSProcTrab']	:= E0D->E0D_FGTSPR
							oInfoFGTS['vrBcFGTSSefip']		:= E0D->E0D_FGTSSE
							oInfoFGTS['vrBcFGTSDecAnt']		:= E0D->E0D_FGTSAN
						oIdePer['infoFGTS'] := oInfoFGTS
							oBsMudCat := JsonObject():new()
								oBsMudCat['codCateg']		:= Val(E0D->E0D_CODCAT)
								oBsMudCat['vrBcCPrev']		:= E0D->E0D_BCCPRE
						oIdePer['baseMudCateg'] := oBsMudCat
							If cVersEnvio >= "9.3"
								oInfoInterm := JsonObject():new()
								cMemoE0D := EncodeUtf8(MSMM(E0D->E0D_CMEM,,,,3,,,"E0D",,"RDY"))
								cErrMemo := oInfoInterm:FromJSON(cMemoE0D)
								If !Empty(cMemoE0D) .And. Empty(cErrMemo) //Se estiver tudo certo, cErrMemo estará como NIL
									oIdePer['infoInterm'] := oInfoInterm['infoInterm']
								Else
									oIdePer['infoInterm'] := {}
								EndIf
							EndIf
						aAdd(aIdePer, oIdePer)
						E0D->(DBSkip())
					EndDo
				Else
					aIdePer := getEmptyObj("idePeriodo")
				EndIf
				oInfoVlr['idePeriodo'] := aIdePer
			Else
				oInfoVlr := getEmptyObj('infoVlr')
			EndIf
			oIdeEstab['infoVlr'] := oInfoVlr

			oInfoContr['ideEstab'] := oIdeEstab

			aAdd(aInfoContr, oInfoContr)
			E0B->(DBSkip())
		EndDo
	Else
		aInfoContr := getEmptyObj("infoContr")
	EndIf

Return aInfoContr

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetUnic
Carrega a unicidade de contrato e retorna no array
@author  martins.marcio
@since   07/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetUnic(cIdVincPai)

	Local aArea		:= GetArea()
	Local cChvE0B	:= ""
	Local oUnicCtr	:= JsonObject():new()
	Local aUniContr	:= {}
	Local lTemUnic	:= .F.

	DEFAULT cIdVincPai	:= ""

	If !Empty(cIdVincPai)
		DbSelectArea("E0B")
		cChvE0B := E0B_FILIAL + E0B_PRONUM + E0B_RECLAM + cIdVincPai
		E0B->(DbSetOrder(1)) // E0B_FILIAL+E0B_PRONUM+E0B_RECLAM+E0B_IDVINC
		If E0B->( DbSeek(cChvE0B ) )
			lTemUnic := .T.
			oUnicCtr['matUnic']		:= E0B->E0B_CODUNI
			oUnicCtr['codCateg']	:= Val(E0B->E0B_CATEFD)
			oUnicCtr['dtInicio']	:= fDtToJson(E0B->E0B_DTITSV)
		 	aAdd(aUniContr, oUnicCtr)
		EndIf
	EndIf

	RestArea( aArea )

Return aUniContr


//-------------------------------------------------------------------
/*/{Protheus.doc} function fSetQryPar
Carrega os valores dos parâmetros de query
@author  martins.marcio
@since  01/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSetQryPar(aQueryString)

	Local nX as Numeric
	DEFAULT aQueryString := {}

	For nX := 1 To Len(aQueryString)
		Do Case
			Case UPPER(AllTrim(aQueryString[nX][1])) == "COMPANYID"
				cCompanyId := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "BRANCHID"
				cBranchId := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "NRPROCTRAB"
				cProcessId := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "IDESEQTRAB"
				cSeqTrab := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "CPFTRAB"
				cCpfTrab := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "ORDER"
				cOrder := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PAGE"
				nNumePage := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PAGESIZE"
				nPageSize := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "FIELDS"
				cFields := aQueryString[nX][2]
		EndCase
	Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function fDtToJson
Converte data para o formato utilizado no json
@author  martins.marcio
@since  07/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function fDtToJson(cStrDate)
	Local cJsonDt	:= ""
	DEFAULT cStrDate := ""
	If ValType(cStrDate) == "D"
		cStrDate := DTOS(cStrDate)
	EndIf
	cStrDate := AllTrim(cStrDate)
	Do Case
		Case Len(cStrDate) == 8
			cJsonDt := SubStr(cStrDate,1,4) + "-" + SubStr(cStrDate,5,2) + "-" + SubStr(cStrDate,7,2)
		Case Len(cStrDate) == 6
			cJsonDt := SubStr(cStrDate,1,4) + "-" + SubStr(cStrDate,5,2)
	EndCase
Return cJsonDt

//-------------------------------------------------------------------
/*/{Protheus.doc} function getEmptyObj
Retorna um objeto vazio quando não forem encontrados dados nas tabelas
@author  martins.marcio
@since  07/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function getEmptyObj(cTipoObj, cVersEnvio)
	Local xObjRet
	Local oJson
	Local cTxt := ""

	DEFAULT cTipoObj := ""
	DEFAULT cVersEnvio := "9.2"
	If !Empty(cTipoObj)
		Do Case
			Case cTipoObj == "idePeriodo" 	 //E0D
				xObjRet := {}

			Case cTipoObj == "infoVlr" // E0C
				oJson := JsonObject():new()
				cTxt := '{ "compIni": "", "compFim": "", "repercProc": 0, "vrRemun": 0, "vrAPI": 0, "vr13API": 0, "vrInden": 0, "vrBaseIndenFGTS": 0, "pagDiretoResc": "", "idePeriodo": [] }'
				oJson:FromJSON(cTxt)
				oJson['idePeriodo'] := getEmptyObj("idePeriodo")
				xObjRet := oJson

			Case cTipoObj == "mudCategAtiv" //E0A
				xObjRet := {}

			Case cTipoObj == "infoCompl" // E0G
				oJson := JsonObject():new()
				cTxt := '{ "codCBO": "", "natAtividade": -1, "remuneracao": [], "infoVinc": { "tpRegTrab": 0, "tpRegPrev": 0, "dtAdm": "", "tmpParc": -1, "duracao": { "tpContr": 0, "dtTerm": "", "clauAssec": "", "objDet": "" }, "observacoes": [ ], "sucessaoVinc": { "tpInsc": 0, "nrInsc": "", "matricAnt": "", "dtTransf": "" }, "infoDeslig": { "dtDeslig": "", "mtvDeslig": "", "dtProjFimAPI": "", "pensAlim": -1, "percALiment": -1, "vrAlim": -1 } }, "infoTerm": { "dtTerm": "", "mtvDesligTSV": "" } } }'
				oJson:FromJSON(cTxt)
				xObjRet := oJson

			Case cTipoObj == "infoContr" //E0B
				xObjRet := {}

		EndCase
	EndIf

Return xObjRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function SendError
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since  07/11/2022
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fSendError(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode := 500
	DEFAULT cMessage := STR0009
	DEFAULT lJson := .T.
	DEFAULT nStatus := 500
	Default cDetailMsg := STR0009
	Default cHelpUrl := ""
	DEFAULT aDetails := {}

	SetRestFault(nCode,encodeUTF8(cMessage),lJson,nStatus,encodeUTF8(cDetailMsg),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fApagaReg
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since  02/12/2022
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fApagaReg(cAlias, nIndice, cChave)

	Local aArea		:= GetArea()
	Local cCPOsChv	:= "###->###_FILIAL+###->###_PRONUM+###->###_RECLAM"
	Local cRDYChave	:= ""

	DEFAULT cAlias	:= ""
	DEFAULT nIndice := 1
	DEFAULT cChave	:= ""

	If !Empty(cAlias) .And. !Empty(cChave)

		cCPOsChv := StrTran( cCPOsChv, "###", cAlias )

		DbSelectArea(cAlias)
		DbSetOrder(1)
		If DbSeek(cChave)
			While (cAlias)->( !Eof() .And. &(cCPOsChv) == cChave)
				If (cAlias)->( RecLock(cAlias,.F.) )
					If cAlias $ "E0C|E0G"
						cRDYChave := IIf(cAlias == "E0C", (cAlias)->E0C_CMEM, (cAlias)->E0G_CMEM )
					EndIf
					If !Empty(cRDYChave)
						// Realiza Exclusão de campo MEMO
						MSMM(cRDYChave,,,,2,,,cAlias,,"RDY")
					EndIf
					(cAlias)->(DbDelete())
					(cAlias)->(MsUnlock())
				EndIf
				(cAlias)->(DBSkip())
			EndDo
		EndIf
	EndIf

	RestArea( aArea )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function fPrepAbon
Prepara o array de abonos para ser gravado na tabela E0C - E0C_MEMO
@author  martins.marcio
@since   24/08/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fPrepAbon(aAbonos)
	Local nW	:= 0
	Local cAbonos := ""

	DEFAULT aAbonos := {}

	For nW := 1 To Len(aAbonos)
		cAbonos += aAbonos[nW]:toJSON() + ","
	Next nW

	If Right(cAbonos,1) == ","
		cAbonos := Left(cAbonos,Len(cAbonos)-1)
	EndIf

	cAbonos := '{"abono": [' + cAbonos + ']}'

Return cAbonos

//-------------------------------------------------------------------
/*/{Protheus.doc} function fApagaReg
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since  24/08/2023
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fGetAbonos(cAbonos)

	Local oAbonos	:= JsonObject():new()
	Local aAbono	:= {}

	DEFAULT cAbonos := ""
	oAbonos:FromJSON(cAbonos)
	aAbono := oAbonos['abono']

Return aAbono

//-------------------------------------------------------------------
/*/{Protheus.doc} function fMatInE0B
Garante que a matricula(E0B_CODUNI) não existe em outra sequencia do processo
@author  martins.marcio
@since  19/08/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function fMatInE0B(cMateSoc, cErroMsg)
	Local lRet       := .F.
	Local cQuery     := ""
	Local cAliasQry1 := ""
	Local cSeqErr    := ""

	DEFAULT cMateSoc  := ""
	DEFAULT cErroMsg  := ""
	DEFAULT oStatmE0B := Nil

	If oStatmE0B == Nil
		cQuery := "SELECT RE0_NUM, RE0_PROJUD, RE0_IDSQPR "
		cQuery += "FROM " + RetSqlName('RE0') + " RE0 "
		cQuery += "LEFT OUTER JOIN "+ RetSqlName('E0B') + " E0B ON E0B_FILIAL = ? AND E0B_PRONUM = RE0_NUM "
		cQuery += "WHERE RE0.RE0_PROJUD = ? "
		cQuery +=	"AND RE0.RE0_IDSQPR <> ? "
		cQuery +=	"AND E0B.E0B_CODUNI = ? "
		cQuery += 	"AND RE0.D_E_L_E_T_ = ? "
		cQuery += 	"AND E0B.D_E_L_E_T_ = ? "

		cQuery := ChangeQuery(cQuery)
		oStatmE0B := FwExecStatement():New(cQuery)
	EndIf
	oStatmE0B:SetString(1, xFilial("E0B", RE0->RE0_FILIAL))
	oStatmE0B:SetString(2, RE0->RE0_PROJUD)
	oStatmE0B:SetString(3, RE0->RE0_IDSQPR)
	oStatmE0B:SetString(4, cMateSoc)
	oStatmE0B:SetString(5, " " )
	oStatmE0B:SetString(6, " " )

	// Executa a query e retorna o alias criado
	cAliasQry1 := oStatmE0B:OpenAlias()
	While (cAliasQry1)->(!EoF())
		lRet := .T.
		cSeqErr += (cAliasQry1)->RE0_IDSQPR + ";"
		(cAliasQry1)->(DBSkip())
	EndDo
	(cAliasQry1)->(dbCloseArea())

	If !Empty(cSeqErr)
		// "A matricula do eSocial '###' já existe na(s) sequencia(s) [###] do processo '###'. Não será possível gravar o registro."
		cErroMsg := OemToAnsi(STR0045) + cMateSoc + OemToAnsi(STR0046) + cSeqErr + OemToAnsi(STR0047) + AllTrim(RE0->RE0_PROJUD) + OemToAnsi(STR0048)
	EndIf

Return lRet
