#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'

#DEFINE MODEL_NAME 'CRMA980'
#DEFINE FEATURE_CODE "INTEGRACAO_RECEITUARIO"
#DEFINE TCO_REPOSITORY agd.TCORepository.agdTCORepository
#DEFINE TCODEPARA_SERVICE agd.TCODeParaService.agdTCODeParaService

/*/{Protheus.doc} AGDXREC
Realiza validações para permitir ou não a geração de transação no EAI de acordo com Cliente alterado.
Rotina utilizada no valid (XX4_EXPFIL) dos adapters de integração com o TAC.
@type function
@version 12
@author lindembergson.pacheco
@since 19/12/2025
@param cOpcao, character, opcao para validacao
@return logical, resultado da validação
/*/
Function AGDXREC()
	Local lRet := .F.

	if SUPERGETMV("MV_SIGAAGD", .f., .f.)
		If Upper(FunName()) == MODEL_NAME
			lRet := VDCLIEPROP()
		Endif
	endif
	
Return lRet

/*/{Protheus.doc} vDentrada
Valida se algum cliente no cadastro de propriedade(NEP) é propriedade ou produtor
Validação especifica para o CRMA980
@type function
@version 12
@author lindembergson.pacheco
@since 19/12/2025
@return logical, resultado da validação
/*/
Static Function VDCLIEPROP()

	Local oModelAct  := FwModelActive()
	Local cCodeInteg := ""
	Local cAlias 	:= ""
	Local cField 	:= ""
	Local lRet      := .F.
	Local oTCOService	:= nil
	Local cInternalId	:= ""

	If oModelAct == Nil;
			.Or. ValType(oModelAct) != "O";
			.Or. ! oModelAct:IsActive();
			.Or. oModelAct:GetId() != MODEL_NAME
		Return .F.
	EndIf

	If oModelAct:GetOperation() == MODEL_OPERATION_UPDATE

		oTCOService	:= TCODEPARA_SERVICE():new()

		cCodeInteg := getCodInt()
		//BUSCANDO CLIENTE PROPRIEDADE
		dbSelectArea("NEP")
		NEP->(dbSetOrder(1))
		If NEP->(dbSeek(FWxFilial("NEP") + SA1->A1_COD + SA1->A1_LOJA))
			cAlias 	:= "NEP"
			cField 	:= "NEP_CODCLI"
			cInternalId	:= oTCOService:formatInternalIdPropriedade(NEP->NEP_CODCLI, NEP->NEP_LOJCLI)
			if !Empty(oTCOService:getExternalID(cCodeInteg, cAlias, cField, cInternalId))
				lRet := .T.
			endIf
		endif

		//BUSCANDO CLIENTE PRODUTOR
		dbSelectArea("NEP")
		NEP->(dbSetOrder(2))
		If NEP->(dbSeek(FWxFilial("NEP") + SA1->A1_COD + SA1->A1_LOJA))
			cAlias 	:= "SA1"
			cField 	:= "A1_COD"
			cInternalId	:= oTCOService:formatInternalIDcliente(NIL, NIL, NEP->NEP_CLIPRO, NEP->NEP_LOJPRO)
			if !Empty(oTCOService:getExternalID(cCodeInteg, cAlias, cField, cInternalId))
				lRet := .T.
			endIf
		endif

		FWfreeObj(oTCOService)
	EndIf


Return lRet


/*/{Protheus.doc} getCodInt
Retorna o codigo de identificação da integração com AgroReceitas
@type function
@version 12
@author lindembergson.pacheco
@since 19/12/2025
@return character, codigo integracao AgroReceitas
/*/
Static Function getCodInt()
	Local oTCOrepo	:= TCO_REPOSITORY():New()
	Local oFtClass	:= oTCOrepo:getFeatureClassById(FEATURE_CODE)
	Local cCodeInteg := oFtClass:getIdentificaoIntegracao()
	FwFreeObj(oTCOrepo)
	FwFreeObj(oFtClass)
Return cCodeInteg
