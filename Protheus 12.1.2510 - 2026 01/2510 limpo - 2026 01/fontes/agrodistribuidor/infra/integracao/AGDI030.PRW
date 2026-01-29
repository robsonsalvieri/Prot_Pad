#INCLUDE "TOTVS.ch"
#DEFINE CONTRATO_ACL_SERVICE agd.contratoAclService.agdContratoAclService
#DEFINE ID_SERVICE agd.idService.agdIdService

/*/{Protheus.doc} AGDI030
Funcao executada pelo módulo de gestão agricola ao alterar a quantidade de um contrato
@type function
@version 12
@author jean.schulze
@since 22/01/2025
@return variant, nil
/*/
Function AGDI030()
	Local aAreaAtu 		:= GetArea()
	Local oIdService := ID_SERVICE():New()
	Local cIdCtr := oIdService:encode({ NJR->NJR_FILIAL, NJR->NJR_CODCTR })

	if SUPERGETMV("MV_AGDCTOG", .f., .f.) .and. SUPERGETMV("MV_SIGAAGD", .f., .f.)

		oContratoACLService := CONTRATO_ACL_SERVICE():New()
		oContratoACLService:getContratoByCodigoExterno(cIdCtr)

		if oContratoACLService:isSuccess()
			oResponseContrato := oContratoACLService:getResponse()
			cIdCtrAcl = oResponseContrato['filial'] + oResponseContrato['codigo'] + oResponseContrato['itemLocalContrato'] + oResponseContrato['item']
			oContratoACLService:atualizarQuantidadeContrato(cIdCtrAcl, NJR->NJR_QTDCTR)
		endif

		FreeObj(oContratoACLService)

	endif

	Restarea(aAreaAtu)
Return nil
