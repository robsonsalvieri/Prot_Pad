#INCLUDE "TOTVS.CH"

#DEFINE NAMESPACEAGD totvs.protheus.agrobusiness.agd


/*/{Protheus.doc} AGDI140
Realiza atualizacao do cooperado relacionado ao titulo baixado
@type function
@version 12
@author carlos.augusto
@since 07/07/2026
@param nRecnoSE1, numeric, Record number da SE1
@return variant 
/*/
Function AGDI140(nRecnoSE1)
	Local aAreaSE1 := SE1->(GetArea())
	Local lRet     := TableInDic('NF3') .And. TableInDic('NF4') .And. TableInDic('NF5') .And. TableInDic('NF6')
	Local lSIGAAGD := SuperGetMv("MV_SIGAAGD",.F.,.F.)
	Local oQuotaRepository := Nil

	If lSIGAAGD .And. lRet .And. !FwIsInCallStack("A460Liquid")
		DbSelectArea("NF3")
		DbSelectArea("NF4")
		DbSelectArea("NF5")
		DbSelectArea("NF6")
		SE1->(DbGoto(nRecnoSE1))

		oQuotaRepository := NAMESPACEAGD.QuotaRepository():New()
		oQuotaRepository:activateCooperatorQuotaByAccountReceivable(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_STATUS)

		RestArea(aAreaSE1)

		FreeObj(oQuotaRepository)
	EndIf

Return
