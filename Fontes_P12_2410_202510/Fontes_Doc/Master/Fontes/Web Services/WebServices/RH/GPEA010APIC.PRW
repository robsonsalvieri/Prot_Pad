#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "GPEA010APIC.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )
#DEFINE PAGESIZE_DEFAULT 2000
#DEFINE PAGE_DEFAULT     1

/*
{Protheus.doc} informationDeficiencies
API para atualização da deficiência do funcionário
@author  martins.marcio
@since   04/07/2024
@version 12.1.2310
*/

WSRESTFUL informationDeficiencies DESCRIPTION STR0001 FORMAT "application/json" //"Serviço genérico para atualização da deficiência do funcionário"
	WSDATA id	 	As String

	WSMETHOD PUT ;
	DESCRIPTION EncodeUTF8(OemToAnsi(STR0001)); // "Atualiza a deficiencia do funcionario"
	WSSYNTAX "/api/rh/v1/informationDeficiencies/{id}" ;
	PATH "/api/rh/v1/informationDeficiencies/{id}" ;
	PRODUCES 'application/json;charset=utf-8';
	TTALK "v1"

END WSRESTFUL

// Altera/Atualiza a deficiência do funcionário
/*/{Protheus.doc} PUT
Método responsável pela atualização da deficiência do funcionário
@author  martins.marcio
@since   04/07/2024
@version 12.1.2310
@return return, return_description
/*/
WSMETHOD PUT QUERYPARAM companyId, branchId HEADERPARAM authorization WSREST informationDeficiencies

	Local oJson    		as OBJECT
	Local oBody   		as OBJECT
	Local cBody    		as Character
	Local cErroMsg 		as Character
	Local lRetorno 		as Logical
	Local aIdFunc		:= {}
	Local cEmpAntBck	:= cEmpAnt
	Local cFilAntBck	:= cFilAnt

	Private aUrlParam := ::aUrlParms
	Private cId        as Character
	Private cCompanyId as Character
	Private cBranchId  as Character
	Private oError
	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )

	BEGIN SEQUENCE

		cRetorno := ""
		oBody		:= JsonObject():New()
		cBody		:= Self:GetContent()
		lRetorno	:= .F.
		cErroMsg	:= oBody:FromJSON(DecodeUTF8(cBody))

		//Valida dados da mensagem/contrato da API
		If cErroMsg != Nil  .Or. Len(oBody:GetNames()) == 0 .Or. ValType(oBody:GetNames()) <> "A"
			fSendMess(400,STR0003,.T.,400,STR0004,,) //"Corpo da mensagem inválido ou inexistente. Verifique a informação e envie novamente." ## "Erro na validação do recebimento da mensagem"
			return (lRetorno)
		Else
			oJson := oBody
		EndIf

		If !Empty(Self:aUrlParms) .And. !Empty(Self:aUrlParms[1])
			cCompanyId	:= If(cCompanyId == Nil, StrTokArr2(Self:aUrlParms[1],";",.T.)[1],cCompanyId)
			cBranchId	:= If(cBranchId == Nil, StrTokArr2(Self:aUrlParms[1],";",.T.)[2],cBranchId)
			If Len(StrTokArr2(Self:aUrlParms[1],";",.T.)) >= 3
				aIdFunc	:= StrTokArr2(StrTokArr2(Self:aUrlParms[1],";",.T.)[3],"|",.T.)
			EndIf
		Else
			fSendMess(400,OemToAnsi(STR0005),.T.,400,OemToAnsi(STR0005),,) // "Não foi possível concluir esta operação. Verifique!"
		EndIf

		fSetErrorHandler(oEmToAnsi(STR0006)) // "Erro ao preparar o ambiente com a Empresa e Filial informados!"

		// Valida os parâmetros recebidos na mensagem
		If !fCheckInfor()
			lRet := .F.
			Return lRet
		EndIf

		If cEmpAntBck <> cCompanyId .Or. cFilAntBck <> cBranchId
			fTrGrpGPE(cCompanyId, cBranchId, "SRA", "GPE")
		EndIf

		// GRAVA DADOS NAS TABELAS
		If !Empty(aIdFunc)
			lRetorno := fGrvTab( oJson, @cErroMsg, aIdFunc)
		EndIf

		If lRetorno
			cId := Self:aUrlParms[1]
			cRetorno :=  fSendJson(oBody, cId)
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

	If cEmpAntBck <> cCompanyId .Or. cFilAntBck <> cBranchId
		fTrGrpGPE(cEmpAntBck, cFilAntBck)
	EndIf

	FreeObj(oBody)

Return (lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGrvTab
Atualiza tabelas com base no json recebido no body da mensagem
@author  martins.marcio
@since   04/07/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function fGrvTab(oJson, cErroMsg, aIdFunc)
	Local nI		:= 0
	Local lRet		:= .F.
	Local aCampos	:= {}
	Local nTamFil	:= TamSX3("RA_FILIAL")[1]
	Local nTamMAT	:= TamSX3("RA_MAT")[1]
	Local cPORTDEF	:= ""

	// RA_PORTDEF
	Local cDefFisica		:= "*" //#1
	Local cDefAuditiva		:= "*" //#2
	Local cDefVisual		:= "*" //#3
	Local cDefMental		:= "*" //#4
	Local cDefIntelectual	:= "*" //#5
	Local cReabReadap		:= "*" //#6

	DEFAULT oJson    := ""
	DEFAULT cErroMsg := ""
	DEFAULT aIdFunc	 := {}

	Begin Transaction
		If ValType(oJson) == "J"
			aCampos := oJson:GetNames()
			//Verifica Funcionario
			DBSelectArea("SRA")
			DBSetOrder(1)
			If !(Len(aIdFunc) >= 3) .Or. !(DBseek(PADR(aIdFunc[2], nTamFil) + PADR(aIdFunc[3], nTamMAT)))
				//ID do Funcionário(employeeId) que compõe o ID recebido(a) na URL da requisição não corresponde a um funcionário válido no Protheus (Tabela SRA).
				cErroMsg += STR0007 + CRLF
				lRet		:= .F.
				DisarmTransaction()
				BREAK
			Endif
			For nI := 1 To Len(aCampos)
				Do Case
					Case UPPER(aCampos[nI]) == "DEFFISICA" .And. oJson[aCampos[nI]] == "S" //defFisica
						cDefFisica := "1"
					Case UPPER(aCampos[nI]) == "DEFAUDITIVA" .And. oJson[aCampos[nI]] == "S" //defAuditiva
						cDefAuditiva := "2"
					Case UPPER(aCampos[nI]) == "DEFVISUAL" .And. oJson[aCampos[nI]] == "S" //defVisual
						cDefVisual := "3"
					Case UPPER(aCampos[nI]) == "DEFMENTAL" .And. oJson[aCampos[nI]] == "S" //defMental
						cDefMental := "4"
					Case UPPER(aCampos[nI]) == "DEFINTELECTUAL" .And. oJson[aCampos[nI]] == "S" //defIntelectual
						cDefIntelectual := "5"
					Case UPPER(aCampos[nI]) == "REABREADAP" .And. oJson[aCampos[nI]] == "S" //reabReadap
						cReabReadap := "6"
				End Case
			Next nI
			cPORTDEF := cDefFisica + cDefAuditiva + cDefVisual + cDefMental + cDefIntelectual + cReabReadap
			If RecLock("SRA", .F.)
				RA_PORTDEF	:= cPORTDEF
				lRet		:= .T.
				SRA->(MsUnlock())
			EndIf
		EndIf

	End Transaction

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since   04/07/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function fSendMess(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode      := 500
	DEFAULT cMessage   := STR0008 // "Erro desconhecido no processo!"
	DEFAULT lJson      := .T.
	DEFAULT nStatus    := 500
	Default cDetailMsg := STR0008 // "Erro desconhecido no processo!"
	Default cHelpUrl   := ""
	DEFAULT aDetails   := {}

	SetRestFault(nCode,EncodeUTF8(OemToAnsi(cMessage)),lJson,nStatus,EncodeUTF8(OemToAnsi(cDetailMsg)),cHelpUrl,aDetails)

Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendJson
Gera as mensagens para o retorno REST/JSON
@author  martins.marcio
@since   04/07/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function fSendJson(ojson, cId)
	Local cJson	:= ""
	ojson["id"] := cId

	cJson :=  FWJsonSerialize(ojson, .F., .F., .T.)

Return (cJson)

//-------------------------------------------------------------------
/*/{Protheus.doc} function fcheckInfor
Valida as informações recebidas na assinatura da mensagem
@author  martins.marcio
@since   04/07/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function fcheckInfor()

	Local cMessage	:= ""
	Local lRet		:= .T.

	If Empty(cCompanyId)
		cMessage := oEmToAnsi(STR0009) + "companyId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	ElseIf Empty(cBranchId)
		cMessage := oEmToAnsi(STR0009) + "branchId" //"Falha ao validar as informações básicas da assinatura. Informação: "
	EndIf

	If !Empty(cCompanyId)
		cCompanyId := Alltrim(cCompanyId)
	Endif

	If Empty(cMessage)
		If ! FWFilExist(cCompanyId,cBranchId)
			cMessage := oEmToAnsi(STR0009) + "companyId + branchId " //"Falha ao validar as informações básicas da assinatura. Informação: "
		EndIf
	EndIf

	If ! Empty(cMessage)
		fSendError(400,cMessage,.T.,400,cMessage,,)
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function SendError
Gera as mensagens de erro tratados para o retorno REST/JSON
@author  martins.marcio
@since   04/07/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function fSendError(nCode,cMessage,lJson,nStatus,cDetailMsg,cHelpUrl,aDetails)

	DEFAULT nCode      := 500
	DEFAULT cMessage   := STR0010
	DEFAULT lJson      := .T.
	DEFAULT nStatus    := 500
	Default cDetailMsg := STR0010
	Default cHelpUrl   := ""
	DEFAULT aDetails   := {}

	SetRestFault(nCode,encodeUTF8(cMessage),lJson,nStatus,encodeUTF8(cDetailMsg),cHelpUrl,aDetails)

Return (.T.)
