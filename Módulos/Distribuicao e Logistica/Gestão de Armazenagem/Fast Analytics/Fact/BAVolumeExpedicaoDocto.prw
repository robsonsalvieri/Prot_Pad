#INCLUDE "BADEFINITION.CH"

NEW ENTITY VOLDOCTOEXPEDICAO
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BAVolumeExpedicaoDocto
Visualiza as informações de Volume de Expedição por Documento
 
@author   jackson.werka
@since    17/08/2018
/*/
//-------------------------------------------------------------------
Class BAVolumeExpedicaoDocto from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.
 
@author  jackson.werka
@since   17/08/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAVolumeExpedicaoDocto
	_Super:Setup("VolumeExpedicaoDocto", FACT, "D12")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.
 
@author  jackson.werka
@since   17/08/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAVolumeExpedicaoDocto
Local cQuery := ""
 
	cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA,"
	cQuery +=       " <<KEY_FILIAL_D12_FILIAL>> AS BK_FILIAL,"
	cQuery +=       " DCF.DCF_CARGA AS CARGA_EXPED,"
	cQuery +=       " DCF.DCF_DOCTO AS DOCUMENTO,"
	cQuery +=       " <<KEY_SA1_A1_FILIAL+DCF_CLIFOR+DCF_LOJA>> AS BK_CLIENTE,"
	cQuery +=       " SUM(DCR.DCR_QUANT) AS QTD_ITENS,"
	cQuery +=       " D12.D12_DTGERA AS DATA_EXTRACAO"
	cQuery += "  FROM <<D12_COMPANY>> D12"
	cQuery += " INNER JOIN <<DCR_COMPANY>> DCR"
	cQuery += "    ON DCR.DCR_FILIAL = <<SUBSTR_DCR_D12_FILIAL>>"
	cQuery += "   AND DCR.DCR_IDORI  = D12.D12_IDDCF"
	cQuery += "   AND DCR.DCR_IDMOV  = D12.D12_IDMOV"
	cQuery += "   AND DCR.DCR_IDOPER = D12.D12_IDOPER"
	cQuery += "   AND DCR.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<DCF_COMPANY>> DCF"
	cQuery += "    ON DCF.DCF_FILIAL = <<SUBSTR_DCF_DCR_FILIAL>>"
	cQuery += "   AND DCF.DCF_ID = DCR.DCR_IDDCF"
	cQuery += "   AND DCF.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<SA1_COMPANY>> SA1"
	cQuery += "    ON SA1.A1_FILIAL = <<SUBSTR_SA1_DCF_FILIAL>>"
	cQuery += "   AND SA1.A1_COD = DCF.DCF_CLIFOR"
	cQuery += "   AND SA1.A1_LOJA = DCF.DCF_LOJA"
	cQuery += "   AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D12.D12_ATUEST = '1'"
	cQuery +=   " AND D12.D12_STATUS <> '0'"
	cQuery +=   " AND D12.D12_ORIGEM = 'SC9'"
	cQuery +=   " AND D12.D12_DTGERA >= <<START_DATE>>"
	cQuery +=   " AND D12.D12_DTGERA <= <<FINAL_DATE>>"
	cQuery +=   " AND D12.D_E_L_E_T_ = ' '"
	cQuery += "GROUP BY D12.D12_FILIAL,"
	cQuery += "      DCF.DCF_CARGA,"
	cQuery += "      DCF.DCF_DOCTO,"
	cQuery += "      DCF.DCF_CLIFOR,"
	cQuery += "      DCF.DCF_LOJA,"
	cQuery += "      D12.D12_DTGERA,"
	cQuery += "      SA1.A1_FILIAL"
Return cQuery