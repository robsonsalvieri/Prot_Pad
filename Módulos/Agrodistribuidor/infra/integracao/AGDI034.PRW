#INCLUDE "TOTVS.ch"
#INCLUDE "AGDI034.ch"

#DEFINE CONTRATO_REPOSITORY agd.contratoAclRepository.agdContratoAclRepository
#DEFINE CONTRATO_ACL_SERVICE agd.contratoAclService.agdContratoAclService
#DEFINE ID_SERVICE agd.idService.agdIdService

/*/{Protheus.doc} AGDI034
Função executada pelo modulo Gestao Agricola ao cancelar/excluir contrato de compra.
@type function
@version P12
@author scheronlini.martins
@since 17/03/2025
@return logical , return_true or false
/*/
Function AGDI034(lPerg)
	Local aAreaAtu  := GetArea()
	Local oCtrReposi := nil
	Local lRet:= .T.

	Default lPerg := .T.

	if SUPERGETMV("MV_SIGAAGD", .f., .f.) .and. SUPERGETMV("MV_AGDCTOG", .f., .f.)

		If lPerg
			lRet:= AGDI034PG()
		endif
		if lRet
			dbSelectArea('NEF')
			NEF->(dbSetOrder(2))	//Filial + CRTEXT
			If NEF->(dbSeek(NJR->(NJR_FILIAL + NJR_CODCTR)))
				oCtrReposi :=  CONTRATO_REPOSITORY():New(NEF->(NEF_FILIAL + NEF_CODBRT + NEF_ITECTR + NEF_ITEM))
				oCtrReposi:Delete()
			endif
		endif
	endif

	FreeObj(oCtrReposi)
	restarea(aAreaAtu)

Return lRet

/*/{Protheus.doc} AGDI034PG
Funcao responsavel por mostrar alerta sim/não para continuar a execução. 
@type function
@version P12
@author scheronlini.martins
@since 18/03/2025
@return logical , return_true or false
/*/
Function AGDI034PG()
	Local lRet := .T.

	if SUPERGETMV("MV_SIGAAGD", .f., .f.) .and. AGDI034NEF()
		If !FWAlertYesNo(STR0002, "") //"Este contrato possui Negociação vinculado ao módulo 54-SIGAAGD, ao executar o Cancelamento/Exclusão, o vinculo será desfeito com a negociação. Deseja prosseguir ?"
			AGDHELP(STR0001, STR0003) //"Ajuda", // "Processo cancelado pelo usuário."
			lRet:= .F.
		endif
	endif

Return lRet

/*/{Protheus.doc} AGDI034NEF
Funcao responsavel por procurar na tabela de vinculo um determinado contrato. 
@type function
@version  P12
@author scheronlini.martins
@since 18/03/2025
@return logical , return_true or false
/*/
static Function AGDI034NEF()
	Local oContratoACLService := nil
	Local lRet:= .F.
	Local oIdService := ID_SERVICE():New()
	Local cIdContrato := oIdService:encode({ NJR->NJR_FILIAL, NJR->NJR_CODCTR })

	oContratoACLService := CONTRATO_ACL_SERVICE():New()
	oContratoACLService:getContratoByCodigoExterno(cIdContrato)

	if oContratoACLService:isSuccess()
		oResponseContrato := oContratoACLService:getResponse()
		lRet := .T.
	endif

Return lRet
