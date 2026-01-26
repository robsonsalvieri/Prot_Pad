#INCLUDE "TOTVS.ch"
#DEFINE MOVIMENTO_CONTRATO_ACL_SERVICE agd.movimentoContratoAclService.agdMovimentoContratoAclService
#DEFINE MOVIMENTO_CONTRATO_ACL_REPOS   agd.movimentoContratoAclRepository.agdMovimentoContratoAclRepository


/*/{Protheus.doc} AGDI031
Função para registrar os documentos fiscais e romaneios de cargas vinculadas ao 
contrato de compra de grãos X Negociação a ser executada nas rotinas de romaneios
@type function
@version 12
@author Gilson.Venturi
@since 23/01/2025
@return variant, nil
/*/
Function AGDI031(cOperacao)
    Local oRepository := MOVIMENTO_CONTRATO_ACL_REPOS():New()
    Local aAreaAtu    := GetArea()

    if SUPERGETMV("MV_SIGAAGD", .f., .f.)

        If cOperacao == "E" // Entrada
            cChaveDocto := SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM)
            oRepository:findByDocumento(SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_ITEM)
        elseif cOperacao == "D" // Devolução Por Compra
            cChaveDocto := SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM )
            oRepository:findByDocumento(SD2->D2_FILIAL,SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_ITEM)
        endif

        if !oRepository:isSuccess()
            oMovtoContratoACLService := MOVIMENTO_CONTRATO_ACL_SERVICE():New(cOperacao, cChaveDocto)
            oMovtoContratoACLService:gerarMovimentosContrato()
            FreeObj(oMovtoContratoACLService)
            
        endif
    endif

    restarea(aAreaAtu)
Return nil
