#INCLUDE "TOTVS.ch"
#DEFINE NAMESPACEAGRO totvs.protheus.agrobusiness.agd

/*/{Protheus.doc} AGDI030
Funcao executada pelo módulo de gestão agricola ao alterar a quantidade de um contrato
@type function
@version 12
@author jean.schulze
@since 22/01/2025
@return variant, nil
/*/
Function AGDI030()
	Local aAreaAtu 	 := GetArea()
	Local oIdService := nil
	Local cIdCtr     := ""

	if SUPERGETMV("MV_AGDCTOG", .f., .f.) .and. SUPERGETMV("MV_SIGAAGD", .f., .f.)

		oIdService := NAMESPACEAGRO.IdService():New()
		cIdCtr := oIdService:encode({ NJR->NJR_FILIAL, NJR->NJR_CODCTR })

		oContratoACLService := NAMESPACEAGRO.ContractACLService():New()
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
