#INCLUDE "TOTVS.ch"
#INCLUDE "AGDI034.ch"

#DEFINE CONTRATO_REPOSITORY totvs.protheus.agrobusiness.agd.ContractACLRepository
#DEFINE CONTRATO_ACL_SERVICE totvs.protheus.agrobusiness.agd.ContractACLService
#DEFINE ID_SERVICE totvs.protheus.agrobusiness.agd.IdService
#DEFINE CONTRATO_ACL_BIND_SERVICE totvs.protheus.agrobusiness.agd.ContractACLBindService

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
	Local oCtrService := nil
	Local lRet:= .T.

	Default lPerg := .T.

	if SUPERGETMV("MV_SIGAAGD", .f., .f.) .and. SUPERGETMV("MV_AGDCTOG", .f., .f.)

		If lPerg
			lRet:= AGDI034PG()
		endif
		if lRet
			dbSelectArea('NEF')
			NEF->(dbSetOrder(2)) //NEF_FILIAL+NEF_CTREXT
			If NEF->(dbSeek(NJR->(NJR_FILIAL + NJR_CODCTR)))
				oCtrService :=  CONTRATO_ACL_BIND_SERVICE():New(NEF->(NEF_FILIAL + NEF_IDCTR + NEF_CODBRT + NEF_ITECTR))
				If InTransaction()
					oCtrService:deleteVinculoContrato(.F.,STR0004)
				else
					BEGIN TRANSACTION
						oCtrService:deleteVinculoContrato(.F.,STR0004)
						If !oCtrService:isSuccess()
							DisarmTransaction()
						EndIf
					END TRANSACTION
				EndIf
				If !oCtrService:isSuccess()
					AGDHELP(STR0001, STR0005 + Chr(13) + Chr(10) + oCtrService:getMessageError()) //"Ajuda" "Erro ao remover vínculo do contrato com a negociação do módulo 54-SIGAAGD."
					lRet := .F.
				endif
			endif
		endif
	endif

	FreeObj(oCtrService)
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

	if SUPERGETMV("MV_SIGAAGD", .f., .f.) .and. AGDI034NEF() .and. !IsBlind()
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
