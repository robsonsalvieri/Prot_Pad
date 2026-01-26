#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APTA100APIB.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )
#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

/*
{Protheus.doc} laborProcessTaxes
API de Pagamentos do Processo trabalhista
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
*/

WSRESTFUL laborProcessTaxes DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para Pagamentos do Processo trabalhista"
	WSDATA companyId	 	As String
	WSDATA branchId	     	As String
	WSDATA fields	     	As String Optional
	WSDATA page			 	As Integer Optional
	WSDATA pageSize		 	As Integer Optional
	WSDATA order	     	As String Optional
	WSDATA id				As String Optional
	WSDATA perApurPagto		As String Optional
	WSDATA cpfTrab			As String Optional
	WSDATA ideSeqProc		As String Optional

	WSMETHOD POST;
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0002 + "S-1.3")); // "Inclui Pagamentos do Processo trabalhista S-1.3"
	WSSYNTAX "/api/rh/v3/laborProcessTaxes" ;
	PATH "/api/rh/v3/laborProcessTaxes" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD GET ALL;
	DESCRIPTION oEmToAnsi(STR0015 + "S-1.3"); // "Retorna uma lista resumida de pagamentos/tributos de um Processo Trabalhista no layout S-1.3"
	WSSYNTAX "/api/rh/v3/laborProcessTaxes" ;
	PATH "/api/rh/v3/laborProcessTaxes" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD GET BYID ;
	DESCRIPTION oEmToAnsi(STR0016 + "S-1.3"); // "Retorna as informações detalhadas de pagamentos/tributos de um Processo Trabalhista no layout S-1.3"
	WSSYNTAX "/api/rh/v3/laborProcessTaxes/{id}" ;
	PATH "/api/rh/v3/laborProcessTaxes/{id}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD PUT;
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0022 + "S-1.3")); // "Altera pagamentos/tributos do Processo Trabalhista no layout S-1.3"
	WSSYNTAX "/api/rh/v3/laborProcessTaxes/{id}" ;
	PATH "/api/rh/v3/laborProcessTaxes/{id}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

	WSMETHOD DELETE;
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0025 + "S-1.3")); // "Exclusão do Processo Trabalhista no layout S-1.3"
	WSSYNTAX "/api/rh/v3/laborProcessTaxes/{id}" ;
	PATH "/api/rh/v3/laborProcessTaxes/{id}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v2"

END WSRESTFUL

// Insere um Processo trabalhista
/*/{Protheus.doc} POST
TODO Método responsável pela inclusão do Pagamento do Processo trabalhista leiaute S-1.3
@author  martins.marcio
@since   06/09/2024
@version 12.1.2410
@return return, return_description
/*/
WSMETHOD POST QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcessTaxes

	Local oJson    		as OBJECT
	Local oBody    		as OBJECT
	Local cBody    		as Character
	Local cErroMsg 		as Character
	Local lRetorno 		as Logical
	Local cRetorno 		as Character
	Local cVersEnvio 	as Character

	Private cId        as Character
	Private cCompanyId as Character
	Private cBranchId  as Character
	Private cNrProcTra as Character
	Private cCpfTrab   as Character
	Private cPerApurPg as Character
	Private cCompetenc as Character
	Private oError
	Private bError      := {|e| oError := e, Break(e)}
	Private bErrorBlock := ErrorBlock( bError )
	Private aUrlParam   := ::aUrlParms

	BEGIN SEQUENCE

	oBody		:= JsonObject():New()
	cBody		:= Self:GetContent()
	lRetorno	:= .F.
	cErroMsg	:= oBody:FromJSON(DecodeUtf8(cBody))
	cVersEnvio	:= "9.3"

	If len(Self:aQueryString) >= 2
		Self:aQueryString[2, 2] := alltrim(Self:aQueryString[2, 2])
	EndIf

	fSetQryPar(Self:aQueryString)
	// Valida os parâmetros recebidos na mensagem
	If !fCheckInfor()
		lRet := .F.
		Return lRet
	EndIf

	//Valida dados da mensagem/contrato da API
	If cErroMsg != Nil  .Or. Len(oBody:GetNames()) == 0  .Or. !(ValType(oBody['items']) == "A" .And. !Empty(oBody['items']))
		fSendMess(400,STR0003,.T.,400,STR0004,,) //"Corpo da mensagem inválido ou inexistente. Verifique a Informação e envie novamente." ## "Erro na validação do recebimento da mensagem"
		return (lRetorno)
	Else
		oJson := oBody['items'][1]
	EndIf

		aEval({'RE0', 'RD0', 'E0H', 'E0I'},{|x|CHKFILE(x)})

		// GRAVA DADOS NAS TABELAS
		lRetorno := fGrv2501(3, oJson, @cErroMsg, cVersEnvio)

		If lRetorno
			cId			:= cEmpAnt + ";" + cFilant + ";" + cNrProcTra + ";" + fDtToJson(cPerApurPg) //"companyId;branchId;nrProcTrab;perApurPgto"
			cRetorno	:=  fSendJson(oJson,cId)
			::SetResponse(cRetorno)
		Else
			aLog := {cErroMsg}
			fSendMess(400,STR0005,.T.,400,ArrTokStr(aLog),,) // "Não foi possível concluir esta operação. Verifique!"
		EndIf

	RECOVER
		//ErrorBlock(bErrorBlock)
		//fSendMess(500,oError:Description,.T.,500,STR0007,,) //"Ocorreu uma falha no retorno da Informação."
		//fSendMess(500,"Falha crítica",.T.,500,STR0007,,) //"Ocorreu uma falha no retorno da Informação."
		//lRetorno := .F.
	END SEQUENCE

	FreeObj(oBody)

Return (lRetorno)

// Retorna lista de pagamentos/tributos do processo trabalhista S-2501 S-1.3
/*/{Protheus.doc} GET ALL
Método responsável pelo retorno de todos os pagamentos do processo
@author  martins.marcio
@since   06/09/2024
@version 12.1.2410
@return return, return_description
/*/
WSMETHOD GET ALL QUERYPARAM companyId, branchId, page, pageSize, order, nrProcTrab, perApurPagto, cpfTrab, ideSeqProc HEADERPARAM authorization WSSERVICE laborProcessTaxes

	Local cResponse As Character
	Local lRet 		:= .T.
	Local oJsonData := JsonObject():new()
	Local cVersEnvio	:= "9.3"

	Private cBranchId  as Character
	Private cCompanyId as Character
	Private cCpfTrab   as Character
	Private cNrProcTra as Character
	Private cOrder     as Character
	Private cPerApurPg as Character
	Private nNumePage := PAGE_DEFAULT
	Private nPageSize := PAGESIZE_DEFAULT
	Private cIdSqPr	  := ""

	BEGIN SEQUENCE

		fResetErrorHandler()

		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If !fCheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		aEval({'RE0', 'RD0', 'E0H', 'E0I'},{|x|CHKFILE(x)})

		fResetErrorHandler()

		// Obtem json com os dados a serem retornados
		lRet := getAll2501(@oJsonData, cVersEnvio)

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

// Retorna pagamentos/tributos do processo trabalhista S-2501
/*/{Protheus.doc} GET BY ID
Método responsável pelo retorno de tributos/pagamentos de um Processo Trabalhista específico leiaute S-1.3
@author  martins.marcio
@since   04/09/2024
@version 12.1.2410
@return return, return_description
/*/
WSMETHOD GET BYID QUERYPARAM companyId, branchId, id HEADERPARAM authorization WSSERVICE laborProcessTaxes

	Local cResponse 	:= ""
	Local lRet 			:= .T.
	Local oJsonData 	:= JsonObject():new()
	Local aParms		:= {}
	Local aInfoPar		:= {}
	Local cVersEnvio	:= "9.3"

	DEFAULT Self:aUrlParms := {}

	Private aUrlParam	:= ::aUrlParms
	Private cCompanyId	:= ""
	Private cBranchId	:= ""
	Private cProcessId	:= ""
	Private cPerApurPg	:= ""
	Private cCpfTrab	:= ""
	Private nTamIdSqPr	:= 3
	Private cIdSqPr		:= ""
	BEGIN SEQUENCE

		aParms := StrTokArr2(Self:aUrlParms[1],";",.T.)

		fResetErrorHandler()
		fSetErrorHandler(OemToAnsi(STR0018)) // "Id do processo inválido, a chave deve respeitar a estrutura companyId;branchId;nrProcTrab;perApurPagto."
		If !Empty(Self:aUrlParms) .And. !Empty(aParms) .And. Len(aParms) >= 4
			cProcessId	:= aParms[3]
			cPerApurPg	:= aParms[4]
			cPerApurPg	:= fJToD(cPerApurPg,"C")
			aAdd(aInfoPar, {"COMPANYID", aParms[1]})
			aAdd(aInfoPar, {"BRANCHID", aParms[2]})
			aAdd(aInfoPar, {"NRPROCTRAB", aParms[3]})
			aAdd(aInfoPar, {"PERAPURPAGTO", aParms[4]})
			nTamIdSqPr	:= FWSX3Util():GetFieldStruct( "E0H_IDSQPR")[3]
			cIdSqPr		:= PADR(cValToChar(-1), nTamIdSqPr)
			If Len(aParms) >= 5 .And. !Empty(aParms[5])
				cIdSqPr := PADR(AllTrim(aParms[5]), nTamIdSqPr)
			EndIf
		Else
			fSendMess(400,OemToAnsi(STR0005),.T.,400,OemToAnsi(STR0018),,) // "Não foi possível concluir esta operação. Verifique!"
		EndIf

		fSetQryPar(aInfoPar)

		// Valida os parâmetros recebidos na mensagem
		If !fCheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		aEval({'RE0', 'RD0', 'E0H', 'E0I'},{|x|CHKFILE(x)})

		fResetErrorHandler()

		// Obtem json com os dados a serem retornados
		lRet := f2501ById3(@oJsonData, cVersEnvio)

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

// Altera um pagamentos/tributos do Processo Trabalhista
/*/{Protheus.doc} PUT
Método responsável pela alteração de pagamentos/tributos do Processo Trabalhista leiaute S-1.3
@author  martins.marcio
@since   02/09/2024
@version 12.1.2410
@return return, return_description
/*/
WSMETHOD PUT QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcessTaxes

	Local oJson    		as OBJECT
	Local oBody   		as OBJECT
	Local cBody    		as Character
	Local cErroMsg 		as Character
	Local lRetorno 		as Logical
	Local cVersEnvio 	as Character

	Private aUrlParam := ::aUrlParms
	Private cId        as Character
	Private cCompanyId as Character
	Private cBranchId  as Character
	Private cNrProcTra as Character
	Private cPerApurPg as Character
	Private cCpfTrab   as Character
	Private cIdSqPrOld as Character
	Private oError
	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )

	BEGIN SEQUENCE

		cRetorno	:= ""
		oBody		:= JsonObject():New()
		cBody		:= Self:GetContent()
		lRetorno	:= .F.
		cErroMsg	:= oBody:FromJSON(DecodeUTF8(cBody))
		cVersEnvio	:= "9.3"

		//Valida dados da mensagem/contrato da API
		If cErroMsg != Nil  .Or. Len(oBody:GetNames()) == 0 .Or. !(ValType(oBody['items']) == "A" .And. !Empty(oBody['items']))
			fSendMess(400,STR0003,.T.,400,STR0004,,) //"Corpo da mensagem inválido ou inexistente. Verifique a informação e envie novamente." ## "Erro na validação do recebimento da mensagem"
			return (lRetorno)
		Else
			oJson := oBody['items'][1]
		EndIf

		If !Empty(Self:aUrlParms) .And. !Empty(Self:aUrlParms[1])
			cCompanyId	:= If(cCompanyId == Nil, StrTokArr2(Self:aUrlParms[1],";",.T.)[1],cCompanyId)
			cBranchId	:= If(cBranchId == Nil, StrTokArr2(Self:aUrlParms[1],";",.T.)[2],cBranchId)
			If Len(StrTokArr2(Self:aUrlParms[1],";",.T.)) >= 4
				cNrProcTra	:= StrTokArr2(Self:aUrlParms[1],";",.T.)[3]
				cPerApurPg	:= StrTokArr2(Self:aUrlParms[1],";",.T.)[4]
				cPerApurPg	:= fJToD(cPerApurPg,"C")
				//ideSeqProc: caso não tenha sido informado, serão buscadas sequencia igual a -1
				cIdSqPrOld		:= cValToChar(-1)
				If Len(StrTokArr2(Self:aUrlParms[1],";",.T.)) >= 5 .And. !Empty(StrTokArr2(Self:aUrlParms[1],";",.T.)[5])
					cIdSqPrOld := StrTokArr2(Self:aUrlParms[1],";",.T.)[5]
					cIdSqPrOld := AllTrim(cIdSqPrOld)
				EndIf
			EndIf
		Else
			fSendMess(400,OemToAnsi(STR0005),.T.,400,OemToAnsi(STR0018),,) // "Não foi possível concluir esta operação. Verifique!"
		EndIf

		fSetQryPar(Self:aQueryString)

		// Valida os parâmetros recebidos na mensagem
		If !fCheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		cId := cCompanyId + ";" + cBranchId + ";" + RTrim(cNrProcTra) + ";" + fDtToJson(cPerApurPg) //"companyId;branchId;nrProcTrab;perApurPagto"

		aEval({'RE0', 'RD0', 'E0H', 'E0I'},{|x|CHKFILE(x)})

		// GRAVA DADOS NAS TABELAS
		lRetorno := fGrv2501(4, oJson, @cErroMsg, cVersEnvio)

		If lRetorno
			cRetorno :=  fSendJson(oBody,cId)
			::SetResponse(cRetorno)
		Else
			aLog := {cErroMsg}
			fSendMess(400,STR0005,.T.,400,ArrTokStr(aLog),,) // "Não foi possível concluir esta operação. Verifique!"
		EndIf

		//RECOVER
			//ErrorBlock(bErrorBlock)
			//fSendMess(500,oError:Description,.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."
			//fSendMess(500,"Falha crítica",.T.,500,STR0009,,) //"Ocorreu uma falha no retorno da informação."
			//lRetorno := .F.
	END SEQUENCE

	FreeObj(oBody)

Return (lRetorno)

//-------------------------------------------------------------------
// Exclusão do Processo trabalhista Layout S-1.3
/*/{Protheus.doc} DELETE
Método responsável pela exclusão de um Processo trabalhista
@author  martins.marcio
@since   09/09/2024
@version 12.1.2410
@return return, return_description
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST laborProcessTaxes
	Local lRet 			:= .T.
	Local cResponse		:= ""
	Local aParms		:= {}
	Local aInfoPar		:= {}
	Local aLog			:= {}
	Local oJsonData := JsonObject():new()
	Local cVersEnvio	:= "9.3"

	DEFAULT Self:aUrlParms := {}

	Private aUrlParam	:= ::aUrlParms
	Private cCompanyId	:= ""
	Private cBranchId	:= ""
	Private cProcessId	:= ""
	Private cPerApurPg	:= ""
	Private nTamIdSqPr	:= FWSX3Util():GetFieldStruct( "E0H_IDSQPR")[3]
	Private cIdSqPr		:= PADR(cValToChar(-1), nTamIdSqPr)

	BEGIN SEQUENCE

		aParms := StrTokArr2(Self:aUrlParms[1],";",.T.)

		fResetErrorHandler()
		fSetErrorHandler(OemToAnsi(STR0018)) // "Id do processo inválido, a chave deve respeitar a estrutura companyId;branchId;nrProcTrab;perApurPagto."
		If !Empty(Self:aUrlParms) .And. !Empty(aParms) .And. Len(aParms) >= 4
			cCompanyId	:= aParms[1]
			cBranchId	:= aParms[2]
			cProcessId	:= aParms[3]
			cPerApurPg	:= aParms[4]
			cPerApurPg	:= fJToD(cPerApurPg,"C")
			aAdd(aInfoPar, {"COMPANYID", aParms[1]})
			aAdd(aInfoPar, {"BRANCHID", aParms[2]})
			aAdd(aInfoPar, {"NRPROCTRAB", aParms[3]})
			aAdd(aInfoPar, {"PERAPURPAGTO", aParms[4]})
			If Len(aParms) >= 5 .And. !Empty(aParms[5])
				cIdSqPr := PADR(AllTrim(aParms[5]), nTamIdSqPr)
			EndIf
		Else
			fSendMess(400,OemToAnsi(STR0005),.T.,400,OemToAnsi(STR0018),,) // "Não foi possível concluir esta operação. Verifique!"
			lRet := .F.
			Return lRet
		EndIf

		fSetQryPar(aInfoPar)

		// Valida os parâmetros recebidos na mensagem
		If !fCheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		aEval({'RE0', 'RD0', 'E0H', 'E0I'},{|x|CHKFILE(x)})

		fResetErrorHandler()

		// Valida Exclusão
		lRet := fDel2501(@oJsonData,cCompanyId,cBranchId,cProcessId,cPerApurPg,cVersEnvio)

		If !lRet
			aAdd(aLog, oJsonData['message'])
			fSendMess(oJsonData['code'], oJsonData['title'], .T., oJsonData['code'], ArrTokStr(aLog),,)
		Else
			// Compress String And Set Response
			cResponse := fCompress(@oJsonData)
			::SetResponse(cResponse)
		EndIf

	// RECOVER
	// 	lRet := .F.
	// 	ErrorBlock(bErrorBlock)
	// 	fSendError(500,oError:Description,.T.,500,STR0009,,) // STR0009: "Ocorreu uma falha no retorno da Informação."
	END SEQUENCE

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrv2501
Atualiza tabelas com base no json recebido no body da mensagem
@author  martins.marcio
@since   03/09/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function fGrv2501(nOpc, oJson, cErroMsg, cVersEnvio)
	Local aCalcTrib  := {}
	Local aIdeTrab   := {}
	Local aInfCRCntr := {}
	Local aInfCRIRRF := {}
	Local aInfoE0H   := {}
	Local aInfoE0I   := {}
	Local aInfIRCE0H := {}
	Local cChvRE0    := ""
	Local lAchouCPF  := .F.
	Local lRet       := .T.
	Local nI         := 0
	Local nX         := 0
	Local nY         := 0
	Local nZ         := 0
	Local cInfCIR	:= ""
	Local cTpCR 	:= ""
	Local cInfCR1 	:= ""
	Local cInfCR2 	:= ""
	Local cChar		:= ""
	Local cTipoCr	:= ""
	Local lTudoOk	:= .F.

	DEFAULT nOpc     := 3
	DEFAULT oJson    := ""
	DEFAULT cErroMsg := ""
	DEFAULT cVersEnvio	:= "9.3"

	Private cMsgErrGrv	:= ""
	Private cNrInsc		:= ""
	Private nTpInsc		:= 0
	Private aInfDepIR	:= {}
	Private nTamIdSqPr	:= FWSX3Util():GetFieldStruct( "E0H_IDSQPR")[3]
	Private nTamProJu	:= FWSX3Util():GetFieldStruct( "RE0_PROJUD")[3]
	Private cIdSqPr		:= PADR(cValToChar(-1), nTamIdSqPr)

	DbSelectArea("RE0")
	If RE0->(ColumnPos("RE0_IDSQPR")) > 0
		cVersEnvio	:= "9.3.4"
	EndIf

	Begin Transaction

		If ValType(oJson) == "J"

			cNrProcTra	:= oJson['ideProc']['nrProcTrab']
			cPerApurPg	:= fJToD(oJson['ideProc']['perApurPgto'],"C")
			If Empty(cPerApurPg)
				cErroMsg := OemToAnsi(STR0008) //"Período de apuração(perApurPgto) inválido, verifique."
				lRet := .F.
				DisarmTransaction()
				BREAK
			EndIf
			If oJson['ideProc']:hasProperty("ideSeqProc")
				cIdSqPr := PADR(AllTrim(Str(oJson['ideProc']['ideSeqProc'])), nTamIdSqPr)
			EndIf
			// Verifica a existência do processo
			cChvRE0	:= xFilial("RE0") + PADR(cNrProcTra, nTamProJu)
			RE0->(DbSetOrder(8)) //RE0_FILIAL+RE0_PROJUD+RE0_IDSQPR
			If !RE0->( DbSeek(cChvRE0) )
				cErroMsg := OemToAnsi(STR0010) + cNrProcTra + OemToAnsi(STR0011) // "O processo (" ## ") não existe na tabela RE0, verifique!"
				lRet := .F.
				DisarmTransaction()
				BREAK
			Else

				If nOpc == 4 //Alteracao
					//Limpa registros, resíduos de execuções anteriores
					cIdSqPrOld := PADR(cIdSqPrOld, nTamIdSqPr)

					While RE0->( !Eof() .And. RE0_FILIAL+RE0_PROJUD == cChvRE0)
						fApagaReg("E0H", 2, xFilial("E0H") + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg, cIdSqPrOld) //2-E0H_FILIAL+E0H_PRONUM+E0H_RECLAM+E0H_PERAP+E0H_IDSQPR+E0H_COMPET
						fApagaReg("E0I", 3, xFilial("E0I") + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg, cIdSqPrOld) //3-E0I_FILIAL+E0I_PRONUM+E0I_RECLAM+E0I_PERAP+E0I_IDSQPR+E0I_COMPET+E0I_TIPO+E0I_IDTRIB
						RE0->(DBSkip())
					EndDo
				EndIf

				aIdeTrab := oJson['ideTrab']
				If !Empty(aIdeTrab)

					For nI := 1 To Len(aIdeTrab)

						lAchouCPF	:= .F.

						cCpfTrab := aIdeTrab[nI]['cpfTrab']

						// Pode existir mais de um registro na RE0 para o mesmo RE0_PROJUD/RE0_RECLAM..
						//o indice que agora contém o campo RE0_IDSQPR garante que vamos posicionar na primeira sequencia para o reclamante.
						If RE0->( DbSeek(cChvRE0) )
							// Verifica se o cpfTrab corresponde com o CPF do reclamante na tabela RD0
							While RE0->( !Eof() .And. RE0_FILIAL+RE0_PROJUD == cChvRE0) .And. !lAchouCPF
								If AllTrim(Posicione("RD0", 1, xFilial("RD0") + RE0->RE0_RECLAM, "RD0_CIC")) == cCpfTrab
									lAchouCPF := .T.
									EXIT
								EndIf
								RE0->(DBSkip())
							EndDo
							If !lAchouCPF
								cErroMsg := OemToAnsi(STR0012) + cCpfTrab + OemToAnsi(STR0013) // "O CPF do trabalhador(cpfTrab) ### não corresponde com o CPF do reclamante do processo."
								lRet := .F.
								DisarmTransaction()
								BREAK
							EndIf
						EndIf

						//Grava um registro específico na E0H para guardar a observação da tag ideProc/obs
						cProcObs := oJson['ideProc']['obs']
						If !Empty(cProcObs)
							fGrvObsPer(cProcObs, cVersEnvio)
						EndIf

						aCalcTrib := aIdeTrab[nI]['calcTrib']
						If !Empty(aCalcTrib)
							For nX := 1 To Len(aCalcTrib)
								cCompetenc := fJToD(aCalcTrib[nX]['perRef'],"C")
								If Empty(cCompetenc)
									cErroMsg := OemToAnsi(STR0009) //"Período de competência(perRef) inválido, verifique."
									lRet := .F.
									DisarmTransaction()
									BREAK
								EndIf

								//E0H - Trib. Processo por Período
								aInfoE0H := {}
								aAdd(aInfoE0H,{ "04", "E0H_PERAP",	 	cPerApurPg	})
								aAdd(aInfoE0H,{ "05", "E0H_COMPET",		cCompetenc })
								aAdd(aInfoE0H,{ "06", "E0H_IDSQPR",	 	cIdSqPr })
								aAdd(aInfoE0H,{ "07", "E0H_BSINSS",		aCalcTrib[nX]['vrBcCpMensal'] })
								aAdd(aInfoE0H,{ "08", "E0H_BS13",		aCalcTrib[nX]['vrBcCp13'] })

								If !Empty(aInfoE0H)
									lRet := fGrvE0H(aInfoE0H, cCompetenc, cPerApurPg, cIdSqPr)
								EndIf

								//E0I - Contribuição Patronal
								aInfCRCntr := aCalcTrib[nX]['infoCRContrib']
								If !Empty(aInfCRCntr)
									For nY := 1 To Len(aInfCRCntr)
										cTipoCr := cValToChar(aInfCRCntr[nY]['tpCR'])
										aInfoE0I := {}
										aAdd(aInfoE0I,{ "04", "E0I_PERAP",		cPerApurPg })
										aAdd(aInfoE0I,{ "05", "E0I_COMPET",		cCompetenc })
										aAdd(aInfoE0I,{ "06", "E0I_IDSQPR",		cIdSqPr })
										aAdd(aInfoE0I,{ "07", "E0I_TIPO",		"2" }) //1=IRRF (infoCRIRRF) ;2=Contribuição Patronal (infoCRContrib)
										aAdd(aInfoE0I,{ "09", "E0I_TPCR",		cTipoCr }) // E0I_TIPO 2 calcTrib > infoCRContrib > tpCR - Numérico
										aAdd(aInfoE0I,{ "10", "E0I_VRCR",		aInfCRCntr[nY]['vrCR'] })
										lRet := fGrvE0I(aInfoE0I, cCompetenc, cPerApurPg, "2", If(nOpc == 3, .T.,.F.), cTipoCr, cIdSqPr)
									Next nY
								EndIf
							Next nX
						EndIf

						//E0H - ideTrab/infoIRComplem
						aInfDepIR	:= {}
						aInfIRCE0H	:= {}
						If aIdeTrab[nI]:hasProperty("infoIRComplem")
							aAdd(aInfIRCE0H,{ "04", "E0H_PERAP",		cPerApurPg })
							aAdd(aInfIRCE0H,{ "05", "E0H_COMPET",		"999999" })
							aAdd(aInfIRCE0H,{ "06", "E0H_IDSQPR",		cIdSqPr })
							aAdd(aInfIRCE0H,{ "10", "E0H_MEM",	aIdeTrab[nI]['infoIRComplem']:toJSON() })

							If !Empty(aInfIRCE0H)
								lRet := fGrvE0H(aInfIRCE0H, "999999", cPerApurPg, cIdSqPr)
							EndIf

							// Os dependentes informados em infoIRComplem/infoDep são carregados ANTES
							// para que seja possível validar a existência cada um dos CPFs (dependentes de IR)
							// que serão lidos em: dedDepen | penAlim | dedSusp
							If aIdeTrab[nI]['infoIRComplem']:hasProperty("infoDep")
								aInfDepIR := aIdeTrab[nI]['infoIRComplem']['infoDep']
							EndIf

						EndIf

						//E0I - IRRF
						aInfCRIRRF := aIdeTrab[nI]['infoCRIRRF']
						If !Empty(aInfCRIRRF)
							cCompetenc	:= "999999"
							For nZ := 1 To Len(aInfCRIRRF)

								//Valida CPF dos dependentes informados
								lRet := fValidDep(aInfCRIRRF[nZ], @cErroMsg)
								If !lRet
									//"Para dependentes cadastrados no eSocial (S-2200/S-2205/S-2300) este CPF deve ser incluído no cadastro de Dependentes(GPEA020). "
									//"Nos demais casos o dependente deve ser incluído no grupo infoIRComplem/infoDep onde são informados os dependentes não cadastrados no eSocial. "
									cErroMsg += oEmToAnsi(STR0031)
									cErroMsg += oEmToAnsi(STR0032)
									DisarmTransaction()
									BREAK
								EndIf

								cTipoCr	 := aInfCRIRRF[nZ]['tpCR']
								aInfoE0I := {}
								aAdd(aInfoE0I,{ "04", "E0I_PERAP",		cPerApurPg })
								aAdd(aInfoE0I,{ "05", "E0I_COMPET",		cCompetenc})
								aAdd(aInfoE0I,{ "06", "E0I_IDSQPR",		cIdSqPr })
								aAdd(aInfoE0I,{ "07", "E0I_TIPO",		"1" }) //1=IRRF (infoCRIRRF) ;2=Contribuição Patronal (infoCRContrib)
								aAdd(aInfoE0I,{ "09", "E0I_TPCR",		cTipoCr }) // E0I_TIPO 1 infoCRIRRF - tpCR String
								aAdd(aInfoE0I,{ "10", "E0I_VRCR",		aInfCRIRRF[nZ]['vrCR'] })

								// Copia o bloco inteiro para dentro do campo memo
								cInfCIR := RhAToJson({aIdeTrab[nI]['infoCRIRRF'][nZ]}, "infoCRIRRF")
								cChar 	:= Substr(cInfCIR,24,1)
								If !(cChar == '"') // Já foi realizado tratativa para conversão para String
									cTpCR   := Substr(cInfCIR,24,6)
									cInfCR1	:= Substr(cInfCIR,1,23)
									cInfCR2	:= Substr(cInfCIR,30,Len(cInfCIR))
									cInfCIR	:= cInfCR1 + '"' + cTpCR + '"' + cInfCR2
								EndIf
								aAdd(aInfoE0I,{ "10", "E0I_MEM", cInfCIR })

								lRet := fGrvE0I(aInfoE0I, cCompetenc, cPerApurPg, "1", If(nOpc == 3, .T.,.F.), cTipoCr, cIdSqPr)
							Next nZ
						EndIf

					Next nI
				EndIf

			EndIf

		EndIf

		// Tratamento para o robo ADVPR, grava o json correspondente ao S-2501 que foi gravado nas tabelas E0H e E0I
		If Type("lRobo") == "L" .And. lRobo
			//Inicializa as variaveis private do get byId
			Private cProcessId	:= cNrProcTra
			//Private cPerApurPg	:= cPerApurPg // mesmo nome da private utilizada nesse método
			Private cIdSqP		:= cIdSqPr
			Private oJsonData
			f2501ById3(@oJsonData)
			If ValType( oJsonData ) == "J"
				GrvJsnArq(oJsonData:toJSON(), "S2501", "GRV", cProcessId + "_" + cIdSqP)
			EndIf
		EndIf

		lTudoOk := .T.
	End Transaction

	If lRet .And. !lTudoOk
		cErroMsg := OemToAnsi(STR0041) //"Erro inesperado, certifique-se que foram aplicadas as ultimas atualizações de dicionário."
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function RhAToJson
Funcão genérica para converter ARRAY para JSON de forma que facilite sua manipulação
@author  martins.marcio
@since   09/09/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function RhAToJson(aArrayX, cNomeInfo)

	Local oObjRet	as OBJECT
	Local oSubObj	as OBJECT
	Local cJsRet := ""

	DEFAULT aArrayX		:= {}
	DEFAULT cNomeInfo	:= ""

	If !Empty(aArrayX)
		oObjRet	:= JsonObject():new()
			oSubObj	:= JsonObject():new()
			oSubObj[cNomeInfo] := aArrayX
		oObjRet['cJsRet'] := oSubObj
		cJsRet := oObjRet['cJsRet']:toJSON()
		FreeObj( oSubObj )
		FreeObj( oObjRet )
	EndIf

Return cJsRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fazQry2501
Processa a Query e retorna alias com os registros do evento S-2501
*Também utilizada pela API do S-2555
Variaveis Private utilizadas: [cOrder, cNrProcTra, cCpfTrab, cPerApurPg, cIdSqPr, nNumePage, nPageSize]
@author  martins.marcio
@since   18/09/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function fazQry2501(cVersEnvio)

	Local cQuery  	 	:= ""
	Local cDataBase		:= TcGetDB()
	Local cQrAlias 		:= ""
	Local cOrdQry		:= ""
	Local oStatement	:= Nil
	Local nParamOrder	:= 1
	Local cFil2501		:= ""
	Local cItemIni		:= Alltrim(Str((nNumePage - 1) * nPageSize + 1))
	Local cItemFim		:= Alltrim(Str((nNumePage * nPageSize)))

	DEFAULT cVersEnvio	:= "9.3"

	// Obtem a ordenação que será utilizada para paginação.
	// * Apesar do retorno ser dinâmico, a função f2501OrdQry() filtra as colunas
	// para que sejam retornadas apenas colunas que serão válidas para a query.
	// ** Descartada a possibilidade de SQL Injection através da variável cOrdQry.
	cOrdQry := f2501OrdQry(cOrder, cVersEnvio)
	dbSelectArea("RE0")

	If cVersEnvio >= "9.3"
		cFil2501		:= xFilial("E0H", xFilial("RE0"))
		// Create Paging Control
		cQuery := "		SELECT JSO.* FROM ( "

		cQuery += IIf(cDataBase == "ORACLE"		,"	SELECT ROWNUM ITEMNUMBER, COUNT(1) OVER() AS TOTALNUMBER, DADOS.*  ",;
					IIf(cDataBase == "POSTGRES"	,"	SELECT ROW_NUMBER() OVER( " + cOrdQry + " ) ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER, DADOS.* ",;
												"	SELECT ROW_NUMBER() OVER( " + cOrdQry + " ) ITEMNUMBER, COUNT(1) OVER() TOTALNUMBER, DADOS.* ")) //MSSQL

		cQuery += "			FROM (	"
		cQuery += "			SELECT  DISTINCT E0H.E0H_PERAP PERAPURPAGTO, RE0.RE0_PROJUD NRPROCTRAB"
		If !IsInCallStack("getAll2555")
			cQuery += "					, E0H.E0H_IDSQPR IDESEQPROC"
		EndIf

		cQuery += "			FROM "+ RetSqlName("RE0") + " RE0"
		cQuery += "			LEFT JOIN "+ RetSqlName("RD0") + " RD0 ON RE0.RE0_RECLAM = RD0.RD0_CODIGO"
		cQuery += "			LEFT JOIN "+ RetSqlName("E0H") + " E0H ON E0H.E0H_PRONUM = RE0.RE0_NUM AND E0H.E0H_RECLAM = RE0.RE0_RECLAM"
		cQuery += "			WHERE RE0.D_E_L_E_T_ = ? "
		cQuery += "			AND   RE0.RE0_FILIAL = ? "
		cQuery += "			AND   RD0.D_E_L_E_T_ = ? "
		cQuery += "			AND   RD0.RD0_FILIAL = ? "
		cQuery += "			AND   E0H.D_E_L_E_T_ = ? "
		cQuery += "			AND   E0H.E0H_FILIAL = ? "
		If !Empty(cNrProcTra)
			cQuery += "			AND   RE0.RE0_PROJUD = ? "
		EndIf
		If !Empty(cCpfTrab)
			cQuery += "			AND   RD0.RD0_CIC = ? "
		EndIf
		If !Empty(cPerApurPg)
			cQuery += "			AND   E0H.E0H_PERAP = ? "
		EndIf
		If !Empty(cIdSqPr)
			cQuery += "			AND   E0H.E0H_IDSQPR = ? "
		EndIf

		cQuery += "			) DADOS "

		cQuery += "			) JSO"
		cQuery += "	        WHERE JSO.ITEMNUMBER BETWEEN ? AND ? "

		cQuery += cOrdQry //ORDER BY
	Else
		cFil2501		:= xFilial("E0E", xFilial("RE0"))
		// Create Paging Control
		cQuery := "		SELECT JSO.* FROM ( "

		cQuery += IIf(cDataBase == "ORACLE"		,"	SELECT ROWNUM ITEMNUMBER, COUNT(1) OVER() AS TOTALNUMBER, DADOS.*  ",;
					IIf(cDataBase == "POSTGRES"	,"	SELECT ROW_NUMBER() OVER( " + cOrdQry + " ) ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER, DADOS.* ",;
												"	SELECT ROW_NUMBER() OVER( " + cOrdQry + " ) ITEMNUMBER, COUNT(1) OVER() TOTALNUMBER, DADOS.* ")) //MSSQL

		cQuery += "			FROM (	"
		cQuery += "			SELECT  DISTINCT E0E.E0E_PERAP PERAPURPAGTO,"
		cQuery += "					RE0.RE0_PROJUD NRPROCTRAB"

		cQuery += "			FROM "+ RetSqlName("RE0") + " RE0"
		cQuery += "			LEFT JOIN "+ RetSqlName("RD0") + " RD0 ON RE0.RE0_RECLAM = RD0.RD0_CODIGO"
		cQuery += "			LEFT JOIN "+ RetSqlName("E0E") + " E0E ON E0E.E0E_PRONUM = RE0.RE0_NUM AND E0E.E0E_RECLAM = RE0.RE0_RECLAM"
		cQuery += "			WHERE RE0.D_E_L_E_T_ = ? "
		cQuery += "			AND   RE0.RE0_FILIAL = ? "
		cQuery += "			AND   RD0.D_E_L_E_T_ = ? "
		cQuery += "			AND   RD0.RD0_FILIAL = ? "
		cQuery += "			AND   E0E.D_E_L_E_T_ = ? "
		cQuery += "			AND   E0E.E0E_FILIAL = ? "
		If !Empty(cNrProcTra)
			cQuery += "			AND   RE0.RE0_PROJUD = ? "
		EndIf
		If !Empty(cCpfTrab)
			cQuery += "			AND   RD0.RD0_CIC = ? "
		EndIf
		If !Empty(cPerApurPg)
			cQuery += "			AND   E0E.E0E_PERAP = ? "
		EndIf

		cQuery += "			) DADOS "

		cQuery += "			) JSO"
		cQuery += "	        WHERE JSO.ITEMNUMBER BETWEEN ? AND ? "

		cQuery += cOrdQry //ORDER BY
	EndIf

	cQuery := ChangeQuery(cQuery)

	oStatement := FwExecStatement():New(cQuery)
	oStatement:SetString(nParamOrder++, " " )								// 1
	oStatement:SetString(nParamOrder++, xFilial("RE0") )					// 2
	oStatement:SetString(nParamOrder++, " " )								// 3
	oStatement:SetString(nParamOrder++, xFilial("RD0", xFilial("RE0")) )	// 4
	oStatement:SetString(nParamOrder++, " " )								// 5
	oStatement:SetString(nParamOrder++, cFil2501 )							// 6

	If !Empty(cNrProcTra)
		oStatement:SetString(nParamOrder++, cNrProcTra )					// 7?
	EndIf
	If !Empty(cCpfTrab)
		oStatement:SetString(nParamOrder++, cCpfTrab )						// 8?
	EndIf
	If !Empty(cPerApurPg)
		oStatement:SetString(nParamOrder++, cPerApurPg )					// 9?
	EndIf
	If cVersEnvio >= "9.3" .And. !Empty(cIdSqPr)
		oStatement:SetString(nParamOrder++, cIdSqPr )						// 10?
	EndIf
	oStatement:SetString(nParamOrder++, cItemIni ) 							// 11?
	oStatement:SetString(nParamOrder++, cItemFim )							// 12?

	// Executa a query e retorna o alias criado
	cQrAlias := oStatement:OpenAlias()

Return cQrAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} function getAll2501
Retorna json com a lista de Pagamentos do Processo trabalhista
@author  martins.marcio
@since   16/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function getAll2501(oJsonData, cVersEnvio)

	Local lRet 		 	:= .T.
	Local oItemData
	Local aItemQry		:= {}
	Local oCabecData	:= JsonObject():new()
	Local cIdTab		:= ""
	Local cQrAlias 		:= ""
	Local cFilEnv		:= ""
	Local cChv2555		:= ""
	Local nHas2555		:= 0
	Local cRegAnt		:= ""

	DEFAULT cVersEnvio	:= "9.2"

	Private lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

	//Identificando Filial de Envio
	fGp23Cons(/*@aFilInTaf*/, /*@aArrayFil*/, @cFilEnv)

	cQrAlias := fazQry2501(cVersEnvio)

	(cQrAlias)->(DBGoTop())

	// Get items Properties
	While (cQrAlias)->(!Eof())
		If lMiddleware
			If (cQrAlias)->NRPROCTRAB + (cQrAlias)->PERAPURPAGTO <> cRegAnt
				cChv2555 := cFilEnv + (cQrAlias)->NRPROCTRAB + (cQrAlias)->PERAPURPAGTO + "S2555"
				fPrepChvMid(cFilEnv, (cQrAlias)->PERAPURPAGTO, @cChv2555)
			EndIf
		Else
			cChv2555 := PADR((cQrAlias)->NRPROCTRAB, 20) + ";" + (cQrAlias)->PERAPURPAGTO
		EndIf
		nHas2555 := IIf(gpeHas2555(cChv2555, /*nIndice*/, /*cEmpEnv*/, cFilEnv, /*cStatus*/, lMiddleware), 1, 0)

		oItemData := JsonObject():new()
		oItemData["nrProcTrab"]			:= (cQrAlias)->NRPROCTRAB
		oItemData["perApurPgto"]		:= fDtToJson((cQrAlias)->PERAPURPAGTO)
		cIdTab		:= cEmpAnt					+ ";"
		cIdTab		+= cFilAnt					+ ";"
		cIdTab		+= RTrim((cQrAlias)->NRPROCTRAB)	+ ";"
		cIdTab		+= fDtToJson((cQrAlias)->PERAPURPAGTO)
		If cVersEnvio >= "9.3"
			cIdTab += ";" + (cQrAlias)->IDESEQPROC
			oItemData["ideSeqProc"]		:= Val((cQrAlias)->IDESEQPROC)
			oItemData["hasS2555"]		:= nHas2555
		EndIf
		oItemData["id"]					:= cIdTab

		AAdd(aItemQry, oItemData )

		oCabecData["hasNext"] 		  := Iif((cQrAlias)->ITEMNUMBER >= (cQrAlias)->TOTALNUMBER, .F., .T.)

		cRegAnt := (cQrAlias)->NRPROCTRAB + (cQrAlias)->PERAPURPAGTO
		(cQrAlias)->(DBSkip())
	EndDo

	oCabecData["items"] := aItemQry
	oJsonData := oCabecData

	fResetErrorHandler()
	(cQrAlias)->(DbCloseArea())
	FreeObj(oCabecData)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function f2501ById2
Retorna informações detalhadas de pagamento/tributos de um processo trabalhista no Layout S-1.2
@author  martins.marcio
@since   16/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function f2501ById2(oJsonData, cVersEnvio)

	Local aCalcTrib  := {}
	Local aIdeTrab   := {}
	Local aInfCRIRRF := {}
	Local aItemQry   := {}
	Local aTrabList  := {}
	Local cChaveE0F  := ""
	Local cIdTab     := ""
	Local cQrAlias   := GetNextAlias()
	Local cQuery     := ""
	Local cInfIRCom	 := ""
	Local lRet       := .T.
	Local nX         := 0
	Local oCabecData := JsonObject():New()
	Local oIdeProc
	Local oIdeTrab
	Local oItemData
	Local oInfoIRCom
	Local lMemo		:= .F.
	Local oStatement := Nil
	Local nParamOrder := 1

	Default cVersEnvio	:= "9.2"

	fSetErrorHandler(oEmToAnsi(STR0020)) // "Não foi possível realizar a query SQL."

	cQuery += "SELECT DISTINCT RD0.RD0_CIC CPFTRAB,"
	cQuery += "	RE0.R_E_C_N_O_ RECNO"

	cQuery += "		FROM "+ RetSqlName("RE0") + " RE0"
	cQuery += "		LEFT JOIN "+ RetSqlName("RD0") + " RD0 ON RE0.RE0_RECLAM = RD0.RD0_CODIGO"
	cQuery += "		LEFT JOIN "+ RetSqlName("E0E") + " E0E ON E0E.E0E_PRONUM = RE0.RE0_NUM AND E0E.E0E_RECLAM = RE0.RE0_RECLAM"

	cQuery += "		WHERE RE0.RE0_FILIAL = '" + xFilial("RE0") + "'"
	cQuery += "		AND   RE0.RE0_PROJUD = ? "
	cQuery += "		AND   E0E.E0E_PERAP	 = ? "
	cQuery += "		AND   RE0.D_E_L_E_T_ = ' '	"
	cQuery += "		AND   RD0.RD0_FILIAL = '" + xFilial("RD0", xFilial("RE0")) + "'"
	cQuery += "		AND   E0E.E0E_FILIAL = '" + xFilial("E0E", xFilial("RE0")) + "'"
	cQuery += "		AND   RD0.D_E_L_E_T_ = ' '	"
	cQuery += "		AND   E0E.D_E_L_E_T_ = ' '	"

	cQuery := ChangeQuery(cQuery)
	oStatement := FwExecStatement():New(cQuery)
	oStatement:SetString(nParamOrder++, cProcessId )						// 1
	oStatement:SetString(nParamOrder++, cPerApurPg )						// 2

	// Executa a query e retorna o alias criado
    cQrAlias := oStatement:OpenAlias()

	(cQrAlias)->(DBGoTop())

	While (cQrAlias)->(!Eof())
		aAdd(aTrabList, {(cQrAlias)->CPFTRAB, (cQrAlias)->RECNO} )
		(cQrAlias)->(DBSkip())
	EndDo
	(cQrAlias)->(DbCloseArea())

	fResetErrorHandler()
	fSetErrorHandler(oEmToAnsi(STR0021)) // "Erro ao montar o objeto json para retorno."

	oItemData := JsonObject():new()
	oItemData['excluidoERP'] := "N"
	oItemData['companyId'] := cEmpAnt
	oItemData['branchId'] := cFilAnt
		oIdeProc := JsonObject():new()
		oIdeProc['nrProcTrab']	:= AllTrim(cProcessId)
		oIdeProc['perApurPgto']	:= fDtToJson(cPerApurPg)
	oItemData['ideProc'] := oIdeProc
	FreeObj(oIdeProc)

	lMemo	:= .T.

	If !Empty(aTrabList)
		DbSelectArea("RE0")
		For nX :=1 To Len(aTrabList)
			oIdeTrab := JsonObject():new()
			oIdeTrab['cpfTrab'] := aTrabList[nX][1]

			RE0->(DbGoTo(aTrabList[nX][2]))

			aCalcTrib := fGetCTrib(cVersEnvio)
			oIdeTrab['calcTrib'] := aCalcTrib
			cChaveE0F 	:= xFilial("E0F",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg + "999999"
			cChaveE0F += "1" //1=IRRF;2=Contribuição Patronal
			aInfCRIRRF	:= fGetE0F(cChaveE0F, cVersEnvio, lMemo, "1")

			oIdeTrab['infoCRIRRF'] := aInfCRIRRF

			cInfIRCom := fGetIRCom(cVersEnvio) //E0E_CMEM (E0E_COMPET = '999999'))
			If !Empty(cInfIRCom)
				oInfoIRCom := JsonObject():new()
				cErroMsg := oInfoIRCom:FromJSON(cInfIRCom)
				oIdeTrab['infoIRComplem'] := oInfoIRCom
				FreeObj(oInfoIRCom)
			Else
				oIdeTrab['infoIRComplem'] := getObjVazio("infoIRComplem")
			EndIf

			aAdd(aIdeTrab, oIdeTrab)
			FreeObj(oIdeTrab)
		Next nX
		oItemData['ideProc']['obs']	:= fGetObsE0E()
	EndIf
	oItemData['ideTrab'] := aIdeTrab

	cIdTab		:= cEmpAnt		+ ";"
	cIdTab		+= cFilAnt		+ ";"
	cIdTab		+= RTrim(cProcessId)	+ ";"
	cIdTab		+= fDtToJson(cPerApurPg)
	oItemData["id"] := cIdTab
	AAdd(aItemQry, oItemData )
	FreeObj(oItemData)

	oCabecData["hasNext"] 		  := .F.

	oCabecData["items"] := aItemQry
	oJsonData := oCabecData
	FreeObj(oCabecData)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function f2501ById3
Retorna informações detalhadas de pagamento/tributos de um processo trabalhista no Layout S-1.3
@author  martins.marcio
@since   04/09/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function f2501ById3(oJsonData, cVersEnvio)

	Local aCalcTrib  := {}
	Local aIdeTrab   := {}
	Local aInfCRIRRF := {}
	Local aItemQry   := {}
	Local aTrabList  := {}
	Local cChaveE0I  := ""
	Local cIdTab     := ""
	Local cQrAlias   := ""
	Local cQuery     := ""
	Local cInfIRCom	 := ""
	Local lRet       := .T.
	Local nX         := 0
	Local oCabecData := JsonObject():New()
	Local oIdeProc
	Local oIdeTrab
	Local oItemData
	Local oInfoIRCom
	Local lMemo	:= .F.
	Local oStatement := Nil
	Local nParamOrder := 1

	Default cVersEnvio	:= "9.3"

	fSetErrorHandler(oEmToAnsi(STR0020)) // "Não foi possível realizar a query SQL."

	cQuery += "SELECT DISTINCT RD0.RD0_CIC CPFTRAB,"
	cQuery += "	RE0.R_E_C_N_O_ RECNO"

	cQuery += "		FROM "+ RetSqlName("RE0") + " RE0"
	cQuery += "		LEFT JOIN "+ RetSqlName("RD0") + " RD0 ON RE0.RE0_RECLAM = RD0.RD0_CODIGO"
	cQuery += "		LEFT JOIN "+ RetSqlName("E0H") + " E0H ON E0H.E0H_PRONUM = RE0.RE0_NUM AND E0H.E0H_RECLAM = RE0.RE0_RECLAM"

	cQuery += "		WHERE RE0.RE0_FILIAL = ? "
	cQuery += "		AND   RE0.RE0_PROJUD = ? "
	cQuery += "		AND   E0H.E0H_PERAP	 = ? "
	cQuery += "		AND   E0H.E0H_IDSQPR = ? "
	cQuery += "		AND   RD0.RD0_FILIAL = ? "
	cQuery += "		AND   E0H.E0H_FILIAL = ? "
	cQuery += "		AND   RE0.D_E_L_E_T_ = ? "
	cQuery += "		AND   RD0.D_E_L_E_T_ = ? "
	cQuery += "		AND   E0H.D_E_L_E_T_ = ? "

	cQuery := ChangeQuery(cQuery)
	oStatement := FwExecStatement():New(cQuery)
	oStatement:SetString(nParamOrder++, xFilial("RE0"))					// 1
	oStatement:SetString(nParamOrder++, cProcessId)						// 2
	oStatement:SetString(nParamOrder++, cPerApurPg)						// 3
	oStatement:SetString(nParamOrder++, cIdSqPr)						// 4
	oStatement:SetString(nParamOrder++, xFilial("RD0", xFilial("RE0")))	// 5
	oStatement:SetString(nParamOrder++, xFilial("E0H", xFilial("RE0"))) // 6
	oStatement:SetString(nParamOrder++, " ")							// 7
	oStatement:SetString(nParamOrder++, " ")							// 8
	oStatement:SetString(nParamOrder++, " ")							// 9

	// Executa a query e retorna o alias criado
    cQrAlias := oStatement:OpenAlias()
	(cQrAlias)->(DBGoTop())

	While (cQrAlias)->(!Eof())
		aAdd(aTrabList, {(cQrAlias)->CPFTRAB, (cQrAlias)->RECNO} )
		(cQrAlias)->(DBSkip())
	EndDo
	(cQrAlias)->(DbCloseArea())

	fResetErrorHandler()
	fSetErrorHandler(oEmToAnsi(STR0021)) // "Erro ao montar o objeto json para retorno."

	oItemData := JsonObject():new()
	oItemData['companyId'] := cEmpAnt
	oItemData['branchId'] := cFilAnt
	oItemData['excluidoERP'] := "N"
	oItemData['hasS2555'] := IIf(gpeHas2555(), 1, 0)
		oIdeProc := JsonObject():new()
		oIdeProc['nrProcTrab']	:= AllTrim(cProcessId)
		oIdeProc['perApurPgto']	:= fDtToJson(cPerApurPg)
		oIdeProc['ideSeqProc']	:= Val(cIdSqPr)
	oItemData['ideProc'] := oIdeProc
	FreeObj(oIdeProc)

	lMemo	:= .T.

	If !Empty(aTrabList)
		DbSelectArea("RE0")
		For nX :=1 To Len(aTrabList)
			oIdeTrab := JsonObject():new()
			oIdeTrab['cpfTrab'] := aTrabList[nX][1]

			RE0->(DbGoTo(aTrabList[nX][2]))

			aCalcTrib := fGetCTrib(cVersEnvio)
			oIdeTrab['calcTrib'] := aCalcTrib
			cChaveE0I 	:= xFilial("E0I",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg + cIdSqPr + "999999"
			cChaveE0I += "1" //1=IRRF;2=Contribuição Patronal
			aInfCRIRRF	:= fGetE0I(cChaveE0I, cVersEnvio, lMemo, "1")

			oIdeTrab['infoCRIRRF'] := aInfCRIRRF

			cInfIRCom := fGetIRCom(cVersEnvio) //E0H_CMEM (E0H_COMPET = '999999'))
			If !Empty(cInfIRCom)
				oInfoIRCom := JsonObject():new()
				cErroMsg := oInfoIRCom:FromJSON(cInfIRCom)
				oIdeTrab['infoIRComplem'] := oInfoIRCom
				FreeObj(oInfoIRCom)
			Else
				oIdeTrab['infoIRComplem'] := getObjVazio("infoIRComplem")
			EndIf

			aAdd(aIdeTrab, oIdeTrab)
			FreeObj(oIdeTrab)
		Next nX
		oItemData['ideProc']['obs']	:= fGetObsE0H()
	EndIf
	oItemData['ideTrab'] := aIdeTrab

	cIdTab		:= cEmpAnt		+ ";"
	cIdTab		+= cFilAnt		+ ";"
	cIdTab		+= RTrim(cProcessId)	+ ";"
	cIdTab		+= fDtToJson(cPerApurPg) + ";"
	cIdTab		+= cIdSqPr
	oItemData["id"] := cIdTab
	AAdd(aItemQry, oItemData )
	FreeObj(oItemData)

	oCabecData["hasNext"] 		  := .F.

	oCabecData["items"] := aItemQry
	oJsonData := oCabecData
	FreeObj(oCabecData)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetCTrib
Retorna array calcTrib
@author  martins.marcio
@since  16/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetCTrib(cVersEnvio)
	Local aCalcTrib  := {}
	Local aInfCRCntr := {}
	Local cChaveE0E  := ""
	Local cChaveE0F  := ""
	Local cChaveE0H  := ""
	Local cChaveE0I  := ""
	Local oCalcTrib

	Default cVersEnvio	:= "9.2"

	If cVersEnvio >= "9.3" //S-1.3 utiliza E0H/E0I
		DbSelectArea("E0H")
		E0H->(DbSetOrder(2)) //E0H_FILIAL+E0H_PRONUM+E0H_RECLAM+E0H_PERAP+E0H_IDSQPR+E0H_COMPET
		cChaveE0H := xFilial("E0H",RE0->RE0_FILIAL) + RE0->RE0_NUM  + RE0->RE0_RECLAM + cPerApurPg + cIdSqPr
		If E0H->(DbSeek(cChaveE0H))
			While E0H->(!Eof() .And. E0H_FILIAL+E0H_PRONUM+E0H_RECLAM+E0H->E0H_PERAP+E0H_IDSQPR == cChaveE0H)
				// Competência 999999 é utilizada apenas para guardar o grupo <infoIRComplem>
				// Registro deve ser ignorado nesse laço
				If E0H->E0H_COMPET == "999999"
					E0H->(DBSkip())
					LOOP
				EndIf
				oCalcTrib := JsonObject():new()
				oCalcTrib['perRef']			:= fDtToJson(E0H->E0H_COMPET)
				oCalcTrib['vrBcCpMensal']	:= E0H->E0H_BSINSS
				oCalcTrib['vrBcCp13']		:= E0H->E0H_BS13

				cChaveE0I	:= cChaveE0H + E0H->E0H_COMPET
				cChaveE0I	+= "2" //1=IRRF;2=Contribuição Patronal
				aInfCRCntr	:= fGetE0I(cChaveE0I,cVersEnvio, .F. , "2")
				oCalcTrib['infoCRContrib']	:= aInfCRCntr
				aAdd(aCalcTrib, oCalcTrib)
				FreeObj(oCalcTrib)
				E0H->(DBSkip())
			EndDO
		EndIf
	Else //S-1.2 utiliza E0E/E0F
		DbSelectArea("E0E")
		E0E->(DbSetOrder(1)) //E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP+E0E_COMPET
		cChaveE0E := xFilial("E0E",RE0->RE0_FILIAL) + RE0->RE0_NUM  + RE0->RE0_RECLAM + cPerApurPg
		If E0E->(DbSeek(cChaveE0E))
			While E0E->(!Eof() .And. E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E->E0E_PERAP == cChaveE0E)
				// Competência 999999 é utilizada apenas para guardar o grupo <infoIRComplem>
				// Registro deve ser ignorado nesse laço
				If E0E->E0E_COMPET == "999999"
					E0E->(DBSkip())
					LOOP
				EndIf
				oCalcTrib := JsonObject():new()
				oCalcTrib['perRef']			:= fDtToJson(E0E->E0E_COMPET)
				oCalcTrib['vrBcCpMensal']	:= E0E->E0E_BSINSS
				oCalcTrib['vrBcCp13']		:= E0E->E0E_BS13

				cChaveE0F	:= cChaveE0E + E0E->E0E_COMPET
				cChaveE0F	+= "2" //1=IRRF;2=Contribuição Patronal
				aInfCRCntr	:= fGetE0F(cChaveE0F,cVersEnvio, .F. , "2")
				oCalcTrib['infoCRContrib']	:= aInfCRCntr
				aAdd(aCalcTrib, oCalcTrib)
				FreeObj(oCalcTrib)
				E0E->(DBSkip())
			EndDO
		EndIf
	EndIf

Return aCalcTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0F
Retorna array de objetos da tabela E0F
@author  martins.marcio
@since  17/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetE0F(cChaveE0F,cVersEnvio,lMemo, cTipo)

	Local oItem
	Local oInfoCRIRRF
	Local cJMemoE0F 	:= ""
	Local cErroMsg		:= ""
	Local aRet			:= {}

	DEFAULT cChaveE0F	:= ""
	DEFAULT cVersEnvio	:= "9.2"
	DEFAULT lMemo		:= .F.
	DEFAULT cTipo		:= ""

	DbSelectArea("E0F")
	E0F->(DbSetOrder(1)) // E0F_FILIAL+E0F_PRONUM+E0F_RECLAM+E0F_PERAP+E0F_COMPET+E0F_TIPO+E0F_IDTRIB
	If E0F->( DbSeek(cChaveE0F) )
		While E0F->(!Eof() .And. E0F_FILIAL+E0F_PRONUM+E0F_RECLAM+E0F_PERAP+E0F_COMPET+E0F_TIPO == cChaveE0F)
			If lMemo
				oInfoCRIRRF := JsonObject():new()
				cJMemoE0F := EncodeUtf8(MSMM(E0F->E0F_CMEM,,,,3,,,"E0F",,"RDY"))
				cErroMsg := oInfoCRIRRF:FromJSON(cJMemoE0F)
				If Empty(cErroMsg)
					aAdd(aRet, oInfoCRIRRF['infoCRIRRF'][1])
				EndIf
				FreeObj(oInfoCRIRRF)
			Else
				oItem := JsonObject():new()
				// E0F_TIPO 1 infoCRIRRF - tpCR String
				// E0F_TIPO 2 calcTrib > infoCRContrib > tpCR - Numérico
				oItem['tpCR'] := If(cTipo == "1",E0F->E0F_TPCR, VAL(E0F->E0F_TPCR))
				oItem['vrCR'] := E0F->E0F_VRCR
				aAdd(aRet, oItem)
				FreeObj(oItem)
			EndIf
			E0F->(DBSkip())
		EndDo
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0I
Retorna array de objetos da tabela E0I
@author  martins.marcio
@since  17/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetE0I(cChaveE0I,cVersEnvio,lMemo, cTipo)

	Local oItem
	Local oInfoCRIRRF
	Local cJMemoE0I 	:= ""
	Local cErroMsg		:= ""
	Local aRet			:= {}

	DEFAULT cChaveE0I	:= ""
	DEFAULT cVersEnvio	:= "9.3"
	DEFAULT lMemo		:= .F.
	DEFAULT cTipo		:= ""

	DbSelectArea("E0I")
	E0I->(DbSetOrder(3)) // E0I_FILIAL+E0I_PRONUM+E0I_RECLAM+E0I_PERAP+E0I_IDSQPR+E0I_COMPET+E0I_TIPO+E0I_IDTRIB
	If E0I->( DbSeek(cChaveE0I) )
		While E0I->(!Eof() .And. E0I_FILIAL+E0I_PRONUM+E0I_RECLAM+E0I_PERAP+E0I_IDSQPR+E0I_COMPET+E0I_TIPO == cChaveE0I)
			If lMemo
				oInfoCRIRRF := JsonObject():new()
				cJMemoE0I := EncodeUtf8(MSMM(E0I->E0I_CMEM,,,,3,,,"E0I",,"RDY"))
				cErroMsg := oInfoCRIRRF:FromJSON(cJMemoE0I)
				If Empty(cErroMsg)
					aAdd(aRet, oInfoCRIRRF['infoCRIRRF'][1])
				EndIf
				FreeObj(oInfoCRIRRF)
			Else
				oItem := JsonObject():new()
				// E0I_TIPO 1 infoCRIRRF - tpCR String
				// E0I_TIPO 2 calcTrib > infoCRContrib > tpCR - Numérico
				oItem['tpCR'] := If(cTipo == "1",E0I->E0I_TPCR, VAL(E0I->E0I_TPCR))
				oItem['vrCR'] := E0I->E0I_VRCR
				aAdd(aRet, oItem)
				FreeObj(oItem)
			EndIf
			E0I->(DBSkip())
		EndDo
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function getObjVazio
Retorna um objeto vazio quando não forem encontrados dados nas tabelas
@author  raquel.andrade
@since  28/08/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function getObjVazio(cTipoObj)
	Local xObjRet
	Local oJson
	Local cTxt := ""

	DEFAULT cTipoObj := ""

	If !Empty(cTipoObj)
		Do Case
			Case cTipoObj == "infoIRComplem" // E0E
				oJson := JsonObject():new()
				cTxt := '{ "dtLaudo": "", "infoDep": [] }'
				oJson:FromJSON(cTxt)
				xObjRet := oJson
				FreeObj(oJson)
		EndCase
	EndIf

Return xObjRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetObsE0E
Retorna observação da tabela E0E
@author  martins.marcio
@since  17/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetObsE0E(cChaveE0E)
	Local cRet	:= ""
	Local cReclam	:= "OBSERV"
	Local cCompet	:= "OBSERV"

	DEFAULT cChaveE0E	:= xFilial("E0E",RE0->RE0_FILIAL) + RE0->RE0_NUM  + cReclam + cPerApurPg + cCompet

	DbSelectArea("E0E")
	E0E->(DbSetOrder(1)) //E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP+E0E_COMPET
	If E0E->( DbSeek(cChaveE0E) )
		cRet := EncodeUtf8(MSMM(E0E->E0E_CMEM,,,,3,,,"E0E",,"RDY"))
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetObsE0H
Retorna observação da tabela E0H
@author  martins.marcio
@since  04/09/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function fGetObsE0H(cChaveE0H)
	Local cRet	:= ""
	Local cReclam	:= "OBSERV"
	Local cCompet	:= "OBSERV"

	DEFAULT cChaveE0H	:= xFilial("E0H",RE0->RE0_FILIAL) + RE0->RE0_NUM  + cReclam + cPerApurPg + cCompet + cIdSqPr

	DbSelectArea("E0H")
	E0H->(DbSetOrder(1)) //1-E0H_FILIAL+E0H_PRONUM+E0H_RECLAM+E0H_PERAP+E0H_COMPET+E0H_IDSQPR
	If E0H->( DbSeek(cChaveE0H) )
		cRet := EncodeUtf8(MSMM(E0H->E0H_CMEM,,,,3,,,"E0H",,"RDY"))
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fValidDep
Valida a existência dos CPFs de dependentes informados dentro do grupo infoCRIRRF
Esses CPFs devem ser de dependentes cadastrados no eSocial (Tabela SRB) ou no grupo infoDep
@author  martins.marcio
@since  06/09/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fValidDep(aInfCRIRRF, cErroMsg)

	Local lRet	:= .T.
	Local nW	:= 0
	Local nU 	:= 0
	Local _nK	:= 0
	Local _nJ	:= 0
	Local _nV	:= 0
	Local _nB	:= 0
	Local cCpfDep := ""
	Local aInfoVlr := {}
	DEFAULT aInfCRIRRF	:= {}
	DEFAULT cErroMsg	:= ""

	//infoCRIRRF['dedDepen'][x]['cpfDep'] - Dedução do rendimento tributável relativa a dependentes
	If aInfCRIRRF:hasProperty("dedDepen") .And. valType(aInfCRIRRF['dedDepen']) == "A" .And. Len(aInfCRIRRF['dedDepen']) > 0
		For nU := 1 To Len(aInfCRIRRF['dedDepen'])
			cCpfDep := aInfCRIRRF['dedDepen'][nU]['cpfDep']
			If Empty(aInfDepIR) .Or. aScan( aInfDepIR , { |x| x['cpfDep'] == cCpfDep } ) == 0
				//Se não encontrou no grupo infoDep, verifica se o dependente existe na tabela SRB
				If !checkDepRB(cCpfTrab, cCpfDep)
					//"Não existe dependente cadastrado com o CPF( XXXX ) para o trabalhador( XXXX ). "
					//"Verifique os campos relativos à Dedução do Rendimento Tributável Relativa a Dependentes(dedDepen)."
					cErroMsg := oEmToAnsi(STR0026) + cCpfDep + oEmToAnsi(STR0027) + cCpfTrab + "). "
					cErroMsg += oEmToAnsi(STR0028)
					Return .F.
				EndIf
			EndIf
		Next nU
	EndIf

	//infoCRIRRF['penAlim'][x]['cpfDep'] - Informação dos beneficiários da pensão alimentícia.
	If aInfCRIRRF:hasProperty("penAlim") .And. valType(aInfCRIRRF['penAlim']) == "A" .And. Len(aInfCRIRRF['penAlim']) > 0
		For nW := 1 To Len(aInfCRIRRF['penAlim'])
			cCpfDep := aInfCRIRRF['penAlim'][nW]['cpfDep']
			If Empty(aInfDepIR) .Or. aScan( aInfDepIR , { |x| x['cpfDep'] == cCpfDep } ) == 0
				//Se não encontrou no grupo infoDep, verifica se o dependente existe na tabela SRB
				If !checkDepRB(cCpfTrab, cCpfDep)
					//"Não existe dependente cadastrado com o CPF( XXXX ) para o trabalhador( XXXX ). "
					//"Verifique os campos relativos aos Beneficiários da Pensão Alimentícia(penAlim)."
					cErroMsg := oEmToAnsi(STR0026) + cCpfDep + oEmToAnsi(STR0027) + cCpfTrab + "). "
					cErroMsg += oEmToAnsi(STR0029)
					Return .F.
				EndIf
			EndIf
		Next nW
	EndIf

	//infoCRIRRF['infoProcRet'][x]['infoValores'][x]['dedSusp'][x]['benefPen'][x]['cpfDep']
	If aInfCRIRRF:hasProperty("infoProcRet") .And. valType(aInfCRIRRF['infoProcRet']) == "A" .And. Len(aInfCRIRRF['infoProcRet']) > 0
		aInfoVlr := {}
		For _nK := 1 To Len(aInfCRIRRF['infoProcRet'])
			If aInfCRIRRF['infoProcRet'][_nK]:hasProperty("infoValores")
				aInfoVlr := aInfCRIRRF['infoProcRet'][_nK]['infoValores']
			EndIf
			If ValType(aInfoVlr) == "A" .And. Len(aInfoVlr) > 0
				For _nJ := 1 To Len(aInfoVlr)
					If aInfoVlr[_nJ]:hasProperty("dedSusp")
						aDedSusp := aInfoVlr[_nJ]['dedSusp']
					EndIf
					If ValType(aDedSusp) == "A" .And. Len(aDedSusp) > 0
						For _nV := 1 To Len(aDedSusp)
							If aDedSusp[_nV]:hasProperty("benefPen")
								aBenefPen := aDedSusp[_nV]['benefPen']
							EndIf
							If ValType(aBenefPen) == "A" .And. Len(aBenefPen) > 0
								For _nB := 1 To Len(aBenefPen)
									cCpfDep := aBenefPen[_nB]['cpfDep']
									If Empty(aInfDepIR) .Or. aScan( aInfDepIR , { |x| x['cpfDep'] == cCpfDep } ) == 0
										//Se não encontrou no grupo infoDep, verifica se o dependente existe na tabela SRB
										If !checkDepRB(cCpfTrab, cCpfDep)
											//"Não existe dependente cadastrado com o CPF( XXXX ) para o trabalhador( XXXX ). "
											//"Verifique os campos relativos às Deduções Suspensas por Dependentes e Beneficiários da Pensão Alimentícia(benefPen). "
											cErroMsg := oEmToAnsi(STR0026) + cCpfDep + oEmToAnsi(STR0027) + cCpfTrab + "). "
											cErroMsg += oEmToAnsi(STR0030)
											Return .F.
										EndIf
									EndIf
								Next _nB
							EndIf
						Next _nV
					EndIf
				Next _nJ
			EndIf
		Next _nK
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function checkDepRB
Valida a existência do CPF no cadastro de dependentes (SRB)
@author  martins.marcio
@since  06/09/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function checkDepRB(cCpfTrab, cCpfDep)

	Local cChvSra	:= ""
	Local cQryAlias := GetNextAlias()
	Local lRet		:= .F.

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

		cChvSra	:= (cQryAlias)->RA_FILIAL + (cQryAlias)->RA_MAT

		DbSelectArea("SRB")
		SRB->(DbSetOrder(1)) //RB_FILIAL, RB_MAT, RB_COD
		If SRB->( DbSeek(cChvSra) )
			While !SRB->(Eof()) .And. SRB->RB_FILIAL + SRB->RB_MAT == cChvSra
				If cCpfDep == SRB->RB_CIC
					lRet := .T.
				EndIf
				SRB->(dbskip())
			EndDo
		EndIf
	EndIf

	(cQryAlias)->(DbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetIRCom
Retorna as informações do grupo ideTrab/infoIRComplem
Informações relacionadas à retenção na fonte, aos rendimentos tributáveis e não tributáveis, deduções e/ou isenções, etc.,
de acordo com a legislação aplicada ao imposto de renda.
@author  martins.marcio
@since  05/09/2023
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetIRCom(cVersEnvio)
	Local cRet		:= ""
	Local cCompet	:= "999999"
	Local cChaveIR	:= ""

	DEFAULT cVersEnvio	:= "9.2"

	If cVersEnvio >= "9.3"
		cChaveIR	:= xFilial("E0H",RE0->RE0_FILIAL) + RE0->RE0_NUM  + RE0->RE0_RECLAM + cPerApurPg + cCompet + cIdSqPr
		DbSelectArea("E0H")
		E0H->(DbSetOrder(1)) //1-E0H_FILIAL+E0H_PRONUM+E0H_RECLAM+E0H_PERAP+E0H_COMPET+E0H_IDSQPR
		If E0H->( DbSeek(cChaveIR) )
			cRet := EncodeUtf8(MSMM(E0H->E0H_CMEM,,,,3,,,"E0H",,"RDY"))
		EndIf
	Else
		cChaveIR	:= xFilial("E0E",RE0->RE0_FILIAL) + RE0->RE0_NUM  + RE0->RE0_RECLAM + cPerApurPg + cCompet
		DbSelectArea("E0E")
		E0E->(DbSetOrder(1)) //1-E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP+E0E_COMPET
		If E0E->( DbSeek(cChaveIR) )
			cRet := EncodeUtf8(MSMM(E0E->E0E_CMEM,,,,3,,,"E0E",,"RDY"))
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function f2501OrdQry
Retorna a ordenação a ser utilizada na query
@author  martins.marcio
@since  16/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function f2501OrdQry(cApiOrder, cVersEnvio)
	Local cQryRet	:= " "
	Local aQryOrd	:= {}
	Local nI		:= 0
	Local cCpoOrd	:= ""
	Local lUsaSeq	:= .F.

	DEFAULT cApiOrder	:= ""
	DEFAULT cVersEnvio	:= "9.2"

	lUsaSeq := (cVersEnvio >= "9.3" .And. !IsInCallStack("getAll2555"))

	If !Empty(cApiOrder)
		aQryOrd := StrTokArr( cApiOrder , ',' )
		For nI := 1 To Len(aQryOrd)
			cCpoOrd := AllTrim(Upper(strTran(aQryOrd[nI], "-", "")))

			If cCpoOrd $ "NRPROCTRAB|PERAPURPAGTO" .Or. ( cCpoOrd == "IDESEQPROC" .And. lUsaSeq)
				cQryRet += cCpoOrd
				cQryRet += IIf(LEFT(AllTrim(aQryOrd[nI]),1) == "-", " DESC,", ",")
			EndIf
		Next nI
	EndIf

	If Empty(cQryRet)
		cQryRet := " ORDER BY NRPROCTRAB, PERAPURPAGTO "
		If lUsaSeq
			cQryRet += ", IDESEQPROC "
		EndIf
	Else
		cQryRet := Left(cQryRet,(Len(cQryRet)-1))  // Retira a virgula do final da string
		cQryRet := " ORDER BY " + cQryRet
	EndIf

Return cQryRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvObsPer
Grava observação na tabela E0E
@author  martins.marcio
@since   17/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvObsPer(cProcObs, cVersEnvio)
	Local lRet      := .T.
	Local cChaveObs := ""
	Local cReclam	:= "OBSERV"
	Local cCompet	:= "OBSERV"
	Local aArea 	:= GetArea()

	DEFAULT cProcObs	:= ""
	DEFAULT cVersEnvio	:= "9.2"

	If cVersEnvio >= "9.3"
		DbSelectArea("E0H")
		E0H->(DbSetOrder(1)) //1-E0H_FILIAL+E0H_PRONUM+E0H_RECLAM+E0H_PERAP+E0H_COMPET+E0H_IDSQPR
		cChaveObs := xFilial("E0H",RE0->RE0_FILIAL) + RE0->RE0_NUM + cReclam + cPerApurPg + cCompet + cIdSqPr
		If !E0H->( DbSeek(cChaveObs ) )
			RecLock("E0H", .T.)
			E0H_FILIAL	:= xFilial("E0H",RE0->RE0_FILIAL)
			E0H_PRONUM	:= RE0->RE0_NUM
			E0H_RECLAM	:= cReclam
			E0H_PERAP	:= cPerApurPg
			E0H_COMPET	:= cCompet
			E0H_IDSQPR	:= cIdSqPr
		Else
			RecLock("E0H", .F.)
		EndIf
		MsMm(E0H->E0H_CMEM, /*nTam*/, /*nLin*/, cProcObs, 1		, /*nTabSize*/, /*lWrap*/, "E0H" , "E0H_CMEM", "RDY")
		E0H->(MsUnlock())
	Else
		DbSelectArea("E0E")
		E0E->(DbSetOrder(1)) //E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP+E0E_COMPET
		cChaveObs := xFilial("E0E",RE0->RE0_FILIAL) + RE0->RE0_NUM + cReclam + cPerApurPg + cCompet
		If !E0E->( DbSeek(cChaveObs ) )
			RecLock("E0E", .T.)
			E0E_FILIAL	:= xFilial("E0E",RE0->RE0_FILIAL)
			E0E_PRONUM	:= RE0->RE0_NUM
			E0E_RECLAM	:= cReclam
			E0E_PERAP	:= cPerApurPg
			E0E_COMPET	:= cCompet
		else
			RecLock("E0E", .F.)
		EndIf
		MsMm(E0E->E0E_CMEM, /*nTam*/, /*nLin*/, cProcObs, 1		, /*nTabSize*/, /*lWrap*/, "E0E" , "E0E_CMEM", "RDY")
		E0E->(MsUnlock())
	EndIf
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0E
Grava dados na tabela E0E
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0E(aInfoE0E, cCompetenc, cPerApurPg)
	Local lRet      := .T.
	Local nI        := 0
	Local cChaveE0E := ""
	Local aArea := GetArea()

	DEFAULT aInfoE0E	:= {}
	DEFAULT cCompetenc	:= Space(6)
	DEFAULT cPerApurPg	:= Space(6)

	DbSelectArea("E0E")
	E0E->(DbSetOrder(1)) //E0E_FILIAL+E0E_PRONUM+E0E_RECLAM+E0E_PERAP+E0E_COMPET
	cChaveE0E := xFilial("E0E",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg + cCompetenc
	If !E0E->( DbSeek(cChaveE0E ) )
		RecLock("E0E", .T.)
		E0E->E0E_FILIAL	:= xFilial("E0E",RE0->RE0_FILIAL)	//01
		E0E->E0E_PRONUM	:= RE0->RE0_NUM						//02
		E0E->E0E_RECLAM	:= RE0->RE0_RECLAM					//03
	else
		RecLock("E0E", .F.)
	EndIf

	For nI := 1 To Len(aInfoE0E)
		If aInfoE0E[nI][2] == "E0E_MEM" // Campo memo
			MsMm(fgetCdMemo(aInfoE0E[nI][2])[2], /*nTam*/, /*nLin*/, aInfoE0E[nI][3], 1, /*nTabSize*/, /*lWrap*/, "E0E", fgetCdMemo(aInfoE0E[nI][2])[1], "RDY")
			RecLock("E0E", .F.) // Garante o lock após o MSMM
		Else
			&(aInfoE0E[nI][2]) := aInfoE0E[nI][3]
		EndIf
	Next nI
	E0E->(MsUnlock())
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0H
Grava dados na tabela E0H
@author  martins.marcio
@since   03/09/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function fGrvE0H(aInfoE0H, cCompetenc, cPerApurPg, cIdSqPr)
	Local lRet		:= .T.
	Local nI		:= 0
	Local cChaveE0H	:= ""
	Local aArea		:= GetArea()

	DEFAULT aInfoE0H	:= {}
	DEFAULT cCompetenc	:= Space(6)
	DEFAULT cPerApurPg	:= Space(6)
	DEFAULT cIdSqPr		:= PADR(cValToChar(-1), nTamIdSqPr)

	DbSelectArea("E0H")
	E0H->(DbSetOrder(1)) //E0H_FILIAL+E0H_PRONUM+E0H_RECLAM+E0H_PERAP+E0H_COMPET+E0H_IDSQPR
	cChaveE0H := xFilial("E0H",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg + cCompetenc + cIdSqPr
	If !E0H->( DbSeek(cChaveE0H ) )
		RecLock("E0H", .T.)
		E0H->E0H_FILIAL	:= xFilial("E0H", RE0->RE0_FILIAL)	//01
		E0H->E0H_PRONUM	:= RE0->RE0_NUM						//02
		E0H->E0H_RECLAM	:= RE0->RE0_RECLAM					//03
	Else
		RecLock("E0H", .F.)
	EndIf

	For nI := 1 To Len(aInfoE0H)
		If aInfoE0H[nI][2] == "E0H_MEM" // Campo memo
			MsMm(fgetCdMemo(aInfoE0H[nI][2])[2], /*nTam*/, /*nLin*/, aInfoE0H[nI][3], 1, /*nTabSize*/, /*lWrap*/, "E0H", fgetCdMemo(aInfoE0H[nI][2])[1], "RDY")
			RecLock("E0H", .F.) // Garante o lock após o MSMM
		Else
			&(aInfoE0H[nI][2]) := aInfoE0H[nI][3]
		EndIf
	Next nI
	E0H->(MsUnlock())
	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0F
Grava dados na tabela E0F
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0F(aInfoE0F, cCompetenc, cPerApurPg, cTipo, lSoInclui, cTipoCr)
	Local lRet      := .T.
	Local nI        := 0
	Local cChaveE0F := ""

	DEFAULT aInfoE0F	:= {}
	DEFAULT cCompetenc	:= Space(6)
	DEFAULT cPerApurPg	:= Space(6)
	DEFAULT cTipo		:= "0"
	DEFAULT lSoInclui	:= .F.
	DEFAULT cTipoCr		:= ""

	If !Empty(cTipoCr)
		DbSelectArea("E0F")
		// E0F_FILIAL+E0F_PRONUM+E0F_RECLAM+E0F_PERAP+E0F_COMPET+E0F_TIPO+E0F_TPCR
		E0F->(DbSetOrder(2))
		cChaveE0F := xFilial("E0F",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg + cCompetenc + cTipo + cTipoCr
		If !E0F->( DbSeek(cChaveE0F ) )
			RecLock("E0F", .T.)
			E0F->E0F_FILIAL	:= xFilial("E0F",RE0->RE0_FILIAL)	//01
			E0F->E0F_PRONUM	:= RE0->RE0_NUM						//02
			E0F->E0F_RECLAM	:= RE0->RE0_RECLAM					//03
			E0F->E0F_IDTRIB	:= GetSX8Num("E0F","E0F_IDTRIB")	//07
		Else
			RecLock("E0F", .F.)
			E0F->E0F_VRCR := 0
		EndIf

		For nI := 1 To Len(aInfoE0F)
			If aInfoE0F[nI][2] == "E0F_VRCR"
				&(aInfoE0F[nI][2]) += aInfoE0F[nI][3]
			ElseIf aInfoE0F[nI][2] == "E0F_MEM" // Campo memo
				MsMm(fgetCdMemo(aInfoE0F[nI][2])[2], /*nTam*/, /*nLin*/, aInfoE0F[nI][3], 1, /*nTabSize*/, /*lWrap*/, "E0F", fgetCdMemo(aInfoE0F[nI][2])[1], "RDY", /*cCpochave*/ , /*cRealAlias*/, lSoInclui)
				RecLock("E0F", .F.) // Garante o lock após o MSMM
			Else
				&(aInfoE0F[nI][2]) := aInfoE0F[nI][3]
			EndIf
		Next nI
		E0F->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvE0I
Grava dados na tabela E0I
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGrvE0I(aInfoE0I, cCompetenc, cPerApurPg, cTipo, lSoInclui, cTipoCr, cIdSqPr)
	Local lRet      := .T.
	Local nI        := 0
	Local cChaveE0I := ""

	DEFAULT aInfoE0I	:= {}
	DEFAULT cCompetenc	:= Space(6)
	DEFAULT cPerApurPg	:= Space(6)
	DEFAULT cTipo		:= "0"
	DEFAULT lSoInclui	:= .F.
	DEFAULT cTipoCr		:= ""
	DEFAULT cIdSqPr		:= PADR(cValToChar(-1), nTamIdSqPr)

	If !Empty(cTipoCr)
		DbSelectArea("E0I")
		//2- E0I_FILIAL+E0I_PRONUM+E0I_RECLAM+E0I_PERAP+E0I_COMPET+E0I_IDSQPR+E0I_TIPO+E0I_TPCR+E0I_IDTRIB
		E0I->(DbSetOrder(2))
		cChaveE0I := xFilial("E0I",RE0->RE0_FILIAL) + RE0->RE0_NUM + RE0->RE0_RECLAM + cPerApurPg + cCompetenc + cIdSqPr + cTipo + cTipoCr
		If !E0I->( DbSeek(cChaveE0I ) )
			RecLock("E0I", .T.)
			E0I->E0I_FILIAL	:= xFilial("E0I",RE0->RE0_FILIAL)	//01
			E0I->E0I_PRONUM	:= RE0->RE0_NUM						//02
			E0I->E0I_RECLAM	:= RE0->RE0_RECLAM					//03
			E0I->E0I_IDTRIB	:= GetSX8Num("E0I","E0I_IDTRIB")	//08
		Else
			RecLock("E0I", .F.)
			E0I->E0I_VRCR := 0
		EndIf

		For nI := 1 To Len(aInfoE0I)
			If aInfoE0I[nI][2] == "E0I_VRCR"
				&(aInfoE0I[nI][2]) += aInfoE0I[nI][3]
			ElseIf aInfoE0I[nI][2] == "E0I_MEM" // Campo memo
				MsMm(fgetCdMemo(aInfoE0I[nI][2])[2], /*nTam*/, /*nLin*/, aInfoE0I[nI][3], 1, /*nTabSize*/, /*lWrap*/, "E0I", fgetCdMemo(aInfoE0I[nI][2])[1], "RDY", /*cCpochave*/ , /*cRealAlias*/, lSoInclui)
				RecLock("E0I", .F.) // Garante o lock após o MSMM
			Else
				&(aInfoE0I[nI][2]) := aInfoE0I[nI][3]
			EndIf
		Next nI
		E0I->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fJToD
Converte a data encontrada no json para o formato Date do Protheus
@author  martins.marcio
@since   09/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fJToD(cDateJson, cDtType)
	Local dRet        := sToD("")

	DEFAULT cDateJson := ""
	DEFAULT cDtType   := "D"

	dRet := IIf(cDtType =="D", sToD( StrTran( cDateJson, "-", "" ) ), StrTran( cDateJson, "-", "" ))

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since   10/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fSendMess(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode      := 500
	DEFAULT cMessage   := STR0006 // "Erro desconhecido no processo!"
	DEFAULT lJson      := .T.
	DEFAULT nStatus    := 500
	Default cDetailMsg := STR0006 // "Erro desconhecido no processo!"
	Default cHelpUrl   := ""
	DEFAULT aDetails   := {}

	SetRestFault(nCode,EncodeUTF8(OemToAnsi(cMessage)),lJson,nStatus,EncodeUTF8(OemToAnsi(cDetailMsg)),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendJson
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since  10/11/2022
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
@since   10/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor()

	Local cMessage	:= ""
	Local lRet		:= .T.

	If Empty(cCompanyId)
		cMessage := oEmToAnsi(STR0014) + "companyId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	ElseIf Empty(cBranchId)
		cMessage := oEmToAnsi(STR0014) + "branchId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	EndIf

	If !Empty(cCompanyId)
		cCompanyId := Alltrim(cCompanyId)
	Endif

	If Empty(cMessage)
		If ! FWFilExist(cCompanyId,cBranchId)
			cMessage := oEmToAnsi(STR0014) + "companyId + branchId " //"Falha ao validar as informações básicas da assinatura. Informação: "
		EndIf
	EndIf

	If ! Empty(cMessage)
		fSendError(400,cMessage,.T.,400,cMessage,,)
		lRet := .F.
	EndIf

	/* Persiste parâmetros específicos do GET ALL */
	If IsInCallStack("GET_ALL")
		//  Se nPageSize vazio, maior que PAGESIZE_DEFAULT ou negativo assume o DEFAULT
		If ( Empty(nPageSize)) .OR. ( nPageSize > PAGESIZE_DEFAULT ) .OR. ( nPageSize < 1 )
			nPageSize := PAGESIZE_DEFAULT
		EndIf
		// Se nPage vazio ou negativo assume o DEFAULT
		If ( Empty(nNumePage)) .OR. ( nNumePage < 1 )
			nNumePage := PAGE_DEFAULT
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSetQryPar
Carrega os valores dos parâmetros de query
@author  martins.marcio
@since  10/11/2022
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
				cNrProcTra := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "CPFTRAB"
				cCpfTrab := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PERAPURPAGTO"
				cPerApurPg := fJToD(aQueryString[nX][2], "C")
			Case UPPER(AllTrim(aQueryString[nX][1])) == "IDESEQPROC" .And. !Empty(aQueryString[nX][2])
				cIdSqPr := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "ORDER"
				cOrder := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PAGE"
				nNumePage := aQueryString[nX][2]
			Case UPPER(AllTrim(aQueryString[nX][1])) == "PAGESIZE"
				nPageSize := aQueryString[nX][2]
			// Case UPPER(AllTrim(aQueryString[nX][1])) == "FIELDS"
			// 	cFields := aQueryString[nX][2]
		EndCase
	Next nX

Return .T.

/*/{Protheus.doc} getCodMemo
Retorna o campo codigo do campo Memo
@since	10/11/2022
@autor	martins.marcio
@version P12
/*/
Static Function fgetCdMemo(cNomeMemo)
	Local aCodMemo    := {"", ""}
	Default cNomeMemo := ""

	If AllTrim(cNomeMemo) == "E0E_MEM"
		aCodMemo := {"E0E_CMEM", E0E->E0E_CMEM }
	ElseIf AllTrim(cNomeMemo) == "E0F_MEM"
		aCodMemo := {"E0F_CMEM", E0F->E0F_CMEM }
	ElseIf AllTrim(cNomeMemo) == "E0H_MEM"
		aCodMemo := {"E0H_CMEM", E0H->E0H_CMEM }
	ElseIf AllTrim(cNomeMemo) == "E0I_MEM"
		aCodMemo := {"E0I_CMEM", E0I->E0I_CMEM }
	EndIf

Return aCodMemo

//-------------------------------------------------------------------
/*/{Protheus.doc} function SendError
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since  10/11/2022
@version 12.1.23
/*/
//-------------------------------------------------------------------
Static Function fSendError(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode      := 500
	DEFAULT cMessage   := STR0007
	DEFAULT lJson      := .T.
	DEFAULT nStatus    := 500
	Default cDetailMsg := STR0007
	Default cHelpUrl   := ""
	DEFAULT aDetails   := {}

	SetRestFault(nCode,encodeUTF8(cMessage),lJson,nStatus,encodeUTF8(cDetailMsg),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fDel2501
Executa Exclusão do evento S-2501 caso Status for diferente de 4*3*2
@author  raquel.andrade
@since  14/12/2023
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Function fDel2501(oJsonData, cCompanyId, cBranchId, cNrProcesso, cPerApurPg, cVersEnvio)
	Local aInfoC	 	:= {}
	Local aArea			:= {}
	Local cChvRE0		:= ""
	Local cStatus		:= ""
	Local cStatPred		:= ""
	Local cQuery		:= ""
	Local cChaveE0F		:= ""
	Local cChaveE0I		:= ""
	Local cNrProcTra	:= ""
	Local cRjeKey		:= ""
	Local cChaveMid		:= ""
	Local cTpInsc		:= ""
	Local cNrInsc		:= "0"
	Local cProcBsc		:= ""
	Local cAliasQry1	:= ""
	Local cAliasQry2	:= ""
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .And. Findfunction("fVerMW"), fVerMW(), .F. )
	Local lS1000		:= .F.
	Local lAdmPubl		:= .F.
	Local lRet			:= .F.
	Local lContinua		:= .F.
	Local oStatmt01		:= Nil
	Local oStatmt02		:= Nil
	Local nTamProJu	:= FWSX3Util():GetFieldStruct( "RE0_PROJUD")[3]

	DEFAULT oJsonData 	:= JsonObject():New()
	DEFAULT cCompanyId	:= ""
	DEFAULT cBranchId	:= ""
	DEFAULT cNrProcesso	:= ""
	DEFAULT cPerApurPg	:= ""
	DEFAULT cVersEnvio	:= "9.3"

	// Verifica status do registro S-2501
	If lMiddleware
		// Verifica os predecessores - evento S1000
		aArea		 := SM0->(GetArea())
		fPosFil( cCompanyId, cBranchId )

		cStatPred := "-1"
		lS1000 := fVld1000( AnoMes(dDataBase), @cStatPred )

		If lS1000
			aInfoC   := fXMLInfos()
			If Len(aInfoC) >= 4
				cTpInsc  := aInfoC[1]
				lAdmPubl := aInfoC[4]
				cNrInsc  := aInfoC[2]
			EndIf

			cStatus := "-1"
			cProcBsc	:= PadR(cNrProcesso,TamSX3("RE0_PROJUD")[1])
			cRjeKey		:= Padr( cBranchId + cProcBsc + cPerApurPg, fTamRJEKey(), " ")
			cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2501" + cRjeKey
			// RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI+DTOS(RJE_DTG)
			GetInfRJE( 2, cChaveMid, @cStatus)
			lContinua := lRet := .T.
		Else
			oJsonData["code"]		:= 403
			oJsonData["message"]	:= OemToAnsi(STR0040)// "Não será possível realizar a exclusão. Verifique o status do evento S-1000"
			oJsonData["title"]		:= OemToAnsi(STR0039) // "Registro do evento S-1000"
			lContinua := lRet := .F.
		EndIf
		RestArea(aArea)
	Else
		cStatus := TAFGetStat( "S-2501", PadR(cNrProcesso,20) + ";" + cPerApurPg, cCompanyId, cBranchId, 5 )//V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_ATIVO
		lContinua	:= .T.
	EndIf

	If lContinua
		If cStatus $ '4*2*3'
			lRet := .F.
			oJsonData["code"]		:= 403
			oJsonData["message"]	:= OemToAnsi(STR0023) // "Para realizar a exclusão desse registro é necessário gerar o evento S-3500, utilize a rotina Geração de Eventos Trabalhistas do módulo SIGAGPE (GPEM038)"
			oJsonData["title"]		:= OemToAnsi(STR0024) // "Registro já transmitido!"
		ElseIf If(lMiddleware, cStatus == "1", Empty(cStatus)) .Or. cStatus == "-1"
			// Tenta localizar Código do Processo na tabela RE0
			cChvRE0	:= xFilial("RE0", cBranchId) + PadR(cNrProcesso, nTamProJu)
			DbSelectArea("RE0")
			RE0->(DbSetOrder(8)) //RE0_FILIAL+RE0_PROJUD+RE0_IDSQPR
			If RE0->(dbSeek(cChvRE0))
				Begin Transaction
					While RE0->( !Eof() .And. RE0_FILIAL+RE0_PROJUD == cChvRE0)
					cNrProcTra	:= RE0->RE0_NUM
					If cVersEnvio >= "9.3"
						If oStatmt01 == Nil
							// Exclui Trib. Processo por Período
							cQuery := "SELECT E0H.E0H_FILIAL, E0H.E0H_PRONUM, E0H.E0H_PERAP, E0H.E0H_IDSQPR, E0H.E0H_RECLAM, E0H.E0H_COMPET ,E0H.E0H_CMEM "
							cQuery += "FROM " + RetSqlName('E0H') + " E0H "
							cQuery += "WHERE E0H.E0H_FILIAL = ? "
							cQuery +=	"AND E0H.E0H_PRONUM = ? "
							cQuery +=	"AND E0H.E0H_PERAP = ? "
							cQuery +=	"AND E0H.E0H_IDSQPR = ? "
							cQuery += 	"AND E0H.D_E_L_E_T_ = ? "
							cQuery += "ORDER BY E0H_FILIAL, E0H_PRONUM, E0H_RECLAM, E0H_PERAP, E0H_IDSQPR"

							cQuery := ChangeQuery(cQuery)
							oStatmt01 := FwExecStatement():New(cQuery)
						EndIf
						oStatmt01:SetString(1, xFilial("E0H", cBranchId))
						oStatmt01:SetString(2, cNrProcTra)
						oStatmt01:SetString(3, cPerApurPg)
						oStatmt01:SetString(4, cIdSqPr)
						oStatmt01:SetString(5, " " )

						// Executa a query e retorna o alias criado
						cAliasQry1 := oStatmt01:OpenAlias()
						dbSelectArea("E0H")
						dbSetOrder(2)	//E0H_FILIAL+E0H_PRONUM+E0H_RECLAM+E0H_PERAP+E0H_IDSQPR+E0H_COMPET
						While (cAliasQry1)->(!EoF())
							cChaveE0H := (cAliasQry1)->E0H_FILIAL + (cAliasQry1)->E0H_PRONUM  + (cAliasQry1)->E0H_RECLAM + (cAliasQry1)->E0H_PERAP + (cAliasQry1)->E0H_IDSQPR
							cRDYChave := (cAliasQry1)->E0H_CMEM
							IF !Empty(cRDYChave)
								// Realiza Exclusão de campo MEMO
								MSMM(cRDYChave,,,,2,,,"E0H",,"RDY")
							EndIf
							If E0H->(dbSeek(cChaveE0H))
								RecLock("E0H",.F.)
								E0H->(dbDelete())
								E0H->(MsUnlock())
							EndIf
							(cAliasQry1)->(DBSkip())
						EndDo
						(cAliasQry1)->(dbCloseArea())

						// Exclui Tributos do Processo
						cRDYChave	:= ""
						If oStatmt02 == Nil
							cQuery := "SELECT E0I.E0I_FILIAL, E0I.E0I_PRONUM, E0I.E0I_PERAP, E0I.E0I_IDSQPR, E0I.E0I_RECLAM, E0I.E0I_COMPET ,E0I.E0I_CMEM "
							cQuery += "FROM " + RetSqlName('E0I') + " E0I "
							cQuery += "WHERE E0I.E0I_FILIAL = '" + xFilial("E0I", cBranchId) + "' "
							cQuery +=	"AND E0I.E0I_PRONUM = ? "
							cQuery +=	"AND E0I.E0I_PERAP = ? "
							cQuery +=	"AND E0I.E0I_IDSQPR = ? "
							cQuery += 	"AND E0I.D_E_L_E_T_ = ' ' "
							cQuery += " ORDER BY E0I_FILIAL, E0I_PRONUM, E0I_RECLAM, E0I_PERAP, E0I_IDSQPR"

							cQuery := ChangeQuery(cQuery)
							oStatmt02 := FwExecStatement():New(cQuery)
						EndIf
						oStatmt02:SetString(1, cNrProcTra)						// 1
						oStatmt02:SetString(2, cPerApurPg)						// 2
						oStatmt02:SetString(3, cIdSqPr)							// 3

						// Executa a query e retorna o alias criado
						cAliasQry2 := oStatmt02:OpenAlias()
						dbSelectArea("E0I")
						dbSetOrder(3) //E0I_FILIAL+E0I_PRONUM+E0I_RECLAM+E0I_PERAP+E0I_IDSQPR+E0I_COMPET+E0I_TIPO+E0I_IDTRIB
						While (cAliasQry2)->(!EoF())
							cChaveE0I := (cAliasQry2)->E0I_FILIAL + (cAliasQry2)->E0I_PRONUM  + (cAliasQry2)->E0I_RECLAM + (cAliasQry2)->E0I_PERAP + (cAliasQry2)->E0I_IDSQPR
							cRDYChave := (cAliasQry2)->E0I_CMEM
							IF !Empty(cRDYChave)
								// Realiza Exclusão de campo MEMO
								MSMM(cRDYChave,,,,2,,,"E0I",,"RDY")
							EndIf
							If E0I->(dbSeek(cChaveE0I))
								RecLock("E0I",.F.)
								E0I->(dbDelete())
								E0I->(MsUnlock())
							EndIf
							(cAliasQry2)->(DBSkip())
						EndDo
						(cAliasQry2)->(dbCloseArea())
					Else
						If oStatmt01 == Nil
							// Exclui Trib. Processo por Período
							cQuery := "SELECT E0E.E0E_FILIAL, E0E.E0E_PRONUM, E0E.E0E_PERAP, E0E.E0E_RECLAM, E0E.E0E_COMPET ,E0E.E0E_CMEM "
							cQuery += "FROM " + RetSqlName('E0E') + " E0E "
							cQuery += "WHERE E0E.E0E_FILIAL = '" + xFilial("E0E", cBranchId) + "' "
							cQuery +=	"AND E0E.E0E_PRONUM = ? "
							cQuery +=	"AND E0E.E0E_PERAP = ? "
							cQuery += 	"AND E0E.D_E_L_E_T_ = ' ' "
							cQuery += "ORDER BY E0E_FILIAL, E0E_PRONUM, E0E_RECLAM, E0E_PERAP"

							cQuery := ChangeQuery(cQuery)
							oStatmt01 := FwExecStatement():New(cQuery)
						EndIf
						oStatmt01:SetString(1, cNrProcTra)						// 1
						oStatmt01:SetString(2, cPerApurPg)						// 2

						// Executa a query e retorna o alias criado
						cAliasQry1 := oStatmt01:OpenAlias()
						dbSelectArea("E0E")
						dbSetOrder(1)
						While (cAliasQry1)->(!EoF())
							cChaveE0E := (cAliasQry1)->E0E_FILIAL + (cAliasQry1)->E0E_PRONUM  + (cAliasQry1)->E0E_RECLAM + (cAliasQry1)->E0E_PERAP
							cRDYChave := (cAliasQry1)->E0E_CMEM
							IF !Empty(cRDYChave)
								// Realiza Exclusão de campo MEMO
								MSMM(cRDYChave,,,,2,,,"E0E",,"RDY")
							EndIf
							If E0E->(dbSeek(cChaveE0E))
								RecLock("E0E",.F.)
								E0E->(dbDelete())
								E0E->(MsUnlock())
							EndIf
							(cAliasQry1)->(DBSkip())
						EndDo
						(cAliasQry1)->(dbCloseArea())

						// Exclui Tributos do Processo
						cRDYChave	:= ""
						If oStatmt02 == Nil
							cQuery := "SELECT E0F.E0F_FILIAL, E0F.E0F_PRONUM, E0F.E0F_PERAP, E0F.E0F_RECLAM, E0F.E0F_COMPET ,E0F.E0F_CMEM "
							cQuery += "FROM " + RetSqlName('E0F') + " E0F "
							cQuery += "WHERE E0F.E0F_FILIAL = '" + xFilial("E0F", cBranchId) + "' "
							cQuery +=	"AND E0F.E0F_PRONUM = ? "
							cQuery +=	"AND E0F.E0F_PERAP = ? "
							cQuery += 	"AND E0F.D_E_L_E_T_ = ' ' "
							cQuery += " ORDER BY E0F_FILIAL, E0F_PRONUM, E0F_RECLAM, E0F_PERAP"

							cQuery := ChangeQuery(cQuery)
							oStatmt02 := FwExecStatement():New(cQuery)
						EndIf
						oStatmt02:SetString(1, cNrProcTra )						// 1
						oStatmt02:SetString(2, cPerApurPg )						// 2

						// Executa a query e retorna o alias criado
						cAliasQry2 := oStatmt02:OpenAlias()
						dbSelectArea("E0F")
						dbSetOrder(1)
						While (cAliasQry2)->(!EoF())
							cChaveE0F := (cAliasQry2)->E0F_FILIAL + (cAliasQry2)->E0F_PRONUM  + (cAliasQry2)->E0F_RECLAM + (cAliasQry2)->E0F_PERAP
							cRDYChave := (cAliasQry2)->E0F_CMEM
							IF !Empty(cRDYChave)
								// Realiza Exclusão de campo MEMO
								MSMM(cRDYChave,,,,2,,,"E0F",,"RDY")
							EndIf
							If E0F->(dbSeek(cChaveE0F))
								RecLock("E0F",.F.)
								E0F->(dbDelete())
								E0F->(MsUnlock())
							EndIf
							(cAliasQry2)->(DBSkip())
						EndDo
						(cAliasQry2)->(dbCloseArea())
					EndIf
					RE0->(DBSkip())
					EndDo
					lRet	:= .T.

				End Transaction

			Else
				lRet := .F.
				oJsonData["code"]		:= 400
				// "Processo não possui dados válidos no Cadastro de Processos - verificar Código do Processo (RE0_NUM)."
				oJsonData["message"]	:= OemToAnsi(STR0038)
			EndIf
		EndIf
	EndIf
	FreeObj(oStatmt01)
	FreeObj(oStatmt02)

	// Tratamento para o robo ADVPR, grava o json do get byId pós exclusão
	If Type("lRobo") == "L" .And. lRobo
		//Inicializa as variaveis private do get byId
		Private cProcessId	:= cNrProcesso
		//Private cPerApurPg	:= cPerApurPg // mesmo nome da private utilizada nesse método
		Private cIdSqP		:= cIdSqPr
		Private oJsonById	:= JsonObject():New()
		f2501ById3(@oJsonById)
		If ValType( oJsonById ) == "J"
			GrvJsnArq(oJsonById:toJSON(), "S2501", "DEL", cProcessId + "_" + cIdSqP)
		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fApagaReg
Limpa registros, resíduos de execuções anteriores
@author  martins.marcio
@since  18/12/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function fApagaReg(cAlias, nIndice, cChave, cIdSqPr)

	Local aArea		:= GetArea()
	Local cCPOsChv	:= "###->###_FILIAL+###->###_PRONUM+###->###_RECLAM+###->###_PERAP"
	Local cRDYChave	:= ""
	Local cCpoSeq	:= ""
	Local cChaveObs	:= ""
	Local nTamReclam := FWSX3Util():GetFieldStruct( "RE0_RECLAM")[3]
	Local nTamCompet := FWSX3Util():GetFieldStruct( "E0H_COMPET")[3]

	DEFAULT cAlias	:= ""
	DEFAULT nIndice := 1
	DEFAULT cChave	:= ""
	DEFAULT cIdSqPr	:= ""

	If cAlias $ "E0H|E0I" //A partir da S-1.3 precisa considerar a sequencia antes de apagar nas tabelas
		cCpoSeq	:= StrTran( "###->###_IDSQPR", "###", cAlias )
	EndIf
	If !Empty(cAlias) .And. !Empty(cChave)

		cCPOsChv := StrTran( cCPOsChv, "###", cAlias )

		DbSelectArea(cAlias)
		DbSetOrder(nIndice)
		If DbSeek(cChave)
			While (cAlias)->( !Eof() .And. &(cCPOsChv) == cChave)
				If (Empty(cCpoSeq) .Or. AllTrim(&(cCpoSeq)) == AllTrim(cIdSqPr)) .And. (cAlias)->( RecLock(cAlias,.F.) )
					If cAlias $ "E0H|E0I"
						cRDYChave := If(cAlias == "E0H", (cAlias)->E0H_CMEM, (cAlias)->E0I_CMEM)
					Else
						cRDYChave := If(cAlias == "E0E", (cAlias)->E0E_CMEM, (cAlias)->E0F_CMEM)
					EndIf
					IF !Empty(cRDYChave)
						// Realiza Exclusão de campo MEMO
						MSMM(cRDYChave,,,,2,,,cAlias,,"RDY")
					EndIf
					(cAlias)->(DbDelete())
					(cAlias)->(MsUnlock())
				EndIf
				(cAlias)->(DBSkip())
			EndDo
		EndIf

		//Apaga Observação S-1.3
		If cAlias == "E0H"
			//2-E0H_FILIAL+E0H_PRONUM+E0H_RECLAM+E0H_PERAP+E0H_IDSQPR+E0H_COMPET
			cChaveObs := xFilial("E0H") + RE0->RE0_NUM + PADR("OBSERV", nTamReclam) + cPerApurPg + cIdSqPr + PADR("OBSERV", nTamCompet)
			If (cAlias)->( Dbseek(cChaveObs))
				If (cAlias)->( RecLock(cAlias,.F.) )
					cRDYChave := (cAlias)->E0H_CMEM
					If !Empty(cRDYChave)
						// Realiza Exclusão de campo MEMO
						MSMM(cRDYChave,,,,2,,,cAlias,,"RDY")
					EndIf
					(cAlias)->(DbDelete())
					(cAlias)->(MsUnlock())
				EndIf
			EndIf
		EndIf

	EndIf

	RestArea( aArea )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function gpeHas2555
Verifica se existe evento S-2555(Consolidação) para o S-2501
@author  martins.marcio
@since  09/09/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function gpeHas2555(cChave, nIndice, cEmpEnv, cFilEnv, cStatus, lMiddleware)

	Local lRet		:= .F.

	DEFAULT cChave		:= ""
	DEFAULT cEmpEnv		:= cEmpAnt
	DEFAULT cFilEnv		:= cFilAnt
	DEFAULT cStatus		:= ""
	DEFAULT lMiddleware	:= .F.

	cFilEnv := IIf(Empty(cFilEnv), cFilAnt, cFilEnv)

	If !Empty(cChave)
		If lMiddleware
			DEFAULT nIndice := 2 //RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( nIndice, cChave, @cStatus )
			lRet := IIf(!Empty(cStatus) .And. cStatus <> "-1", .T., .F.)
		Else
			DEFAULT nIndice := 4 //T8I_FILIAL+T8I_NRPROC+T8I_PERAPU+T8I_ATIVO
			cStatus := TAFGetStat( "S-2555", cChave, cEmpEnv, cFilEnv, nIndice)
			lRet := IIf(cStatus <> "-1", .T., .F.)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fPrepChvMid
Prepara chave para consulta do evento S-2555 no Middleware
@author  martins.marcio
@since  16/10/2024
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function fPrepChvMid(cFilEnv, cPerap, cChv2555)

	Local aArea		:= GetArea()
	Local aInfoC	:= {}
	Local lRet		:= .F.
	Local cTpInsc	:= ""
	Local cNrInsc	:= "0"
	Local lAdmPubl	:= .F.

	DEFAULT cFilEnv  := cFilAnt
	DEFAULT cPerap	 := ""
	DEFAULT cChv2555 := ""

	If !Empty(cPerap)
		fPosFil( cEmpAnt, cFilEnv )

		aInfoC := fXMLInfos(cPerap)
		If Len(aInfoC) >= 4
			cTpInsc  := aInfoC[1]
			cNrInsc  := aInfoC[2]
			lAdmPubl := aInfoC[4]
			lRet := .T.
		EndIf
	EndIf
	cChv2555 := cTpInsc + PADR( IIf( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2555" + Padr(cChv2555, 40, " ")
	RestArea( aArea )

Return lRet

/*/{Protheus.doc} GrvJsnArq
Grava arquivo XML
@Author	martins.marcio
@Since 04/04/2025
@Version 1.0
/*/
Function GrvJsnArq(cTexto, cEvento, cMetodo, cChaveProc)

	Local nHandle		:= 0
	Local cFileTxt		:= ""
	Local cFile			:= ""
	Local cStartPath	:= GetSrvProfString( "StartPath", "" )
	Local cBarra		:= Iif( GetRemoteType() == 2, "/", "\" ) //2-Linux 1-Windows

	Default	cTexto		:= ""
	Default	cEvento		:= ""
	Default	cMetodo		:= ""
	Default	cChaveProc	:= ""

	cTexto := RHJsnFormt(cTexto)

	If ! Empty(cStartPath) .And. ( SubStr( cStartPath, Len( cStartPath ), 1 ) <> cBarra )
		cStartPath +=	cBarra
	EndIf

	cFile	:= "GPE_JSON_" + DToS(dDataBase) + "_" + StrTran(Time(), ":", "")
	cFile	+= Iif( !Empty(cEvento), "_" + cEvento, "") + Iif( !Empty(cMetodo), "_" + cMetodo, "")
	cFile	+= Iif( !Empty(cChaveProc), "_" + AllTrim(cChaveProc), "")
	cFile	:= AllTrim(cFile) + "_" + StrZero(Len(aFilesJs) + 1, 4) + ".json"

	cFileTxt := cStartPath+cFile

	nHandle := MsFCreate(cFileTxt)

	If nHandle > 0
		Aadd(aFilesJs, cFile)
		WrtStrTxt(nHandle, cTexto)
	EndIf

	FClose(nHandle)

Return()

/*/{Protheus.doc} RHJsnFormt
Formata o JSON para facilitar a leitura
@Author	martins.marcio
@Since 04/04/2025
@Version 1.0
/*/
Function RHJsnFormt(cJSONString)
	Local cStrRet	:= ""
	Local nIndent	:= 0
	Local cChar		:= ""
	Local lInString	:= .F.
	Local nPos		:= 1
	Local nLen		:= Len(cJSONString)

	While nPos <= nLen
		cChar := SubStr(cJSONString, nPos, 1)

		Do Case
			Case cChar == '"'
				lInString := !lInString
				cStrRet += cChar
			Case !lInString .And. cChar == '{'
				cStrRet += cChar + CRLF + Space(nIndent * 2)
				nIndent++
				cStrRet += Space(nIndent * 2)
			Case !lInString .And. cChar == '}'
				nIndent--
				cStrRet += CRLF + Space(nIndent * 2) + cChar
			Case !lInString .And. cChar == ','
				cStrRet += cChar + CRLF + Space(nIndent * 2)
			Case !lInString .And. cChar == ':'
				cStrRet += cChar + " "
			Otherwise
				cStrRet += cChar
		EndCase

		nPos++
	EndDo

Return cStrRet
