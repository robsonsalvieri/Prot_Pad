#INCLUDE "BADEFINITION.CH"

NEW ENTITY VOLITEMEXPEDICAO
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BAVolumeExpedicaoItem
Visualiza as informações de Volume de Expedição por Item
 
@author   jackson.werka
@since    17/08/2018
/*/
//-------------------------------------------------------------------
Class BAVolumeExpedicaoItem from BAEntity
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
Method Setup( ) Class BAVolumeExpedicaoItem
	_Super:Setup("VolumeExpedicaoItem", FACT, "D12")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.
 
@author  jackson.werka
@since   17/08/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAVolumeExpedicaoItem
Local cQuery := ""
 
	cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA,"
	cQuery +=       " <<KEY_FILIAL_D12_FILIAL>> AS BK_FILIAL,"
	cQuery +=       " <<KEY_SB1_B1_FILIAL+D12_PRODUT>> AS BK_ITEM,"
	cQuery +=       " <<KEY_SAH_AH_FILIAL+B1_UM>> AS BK_UNIDADE_DE_MEDIDA,"
	cQuery +=       " <<KEY_SX5_SX502.X5_FILIAL+B1_TIPO>> AS BK_FAMILIA_MATERIAL,"
	cQuery +=       " <<KEY_SBM_BM_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE,"
	cQuery +=       " <<KEY_DC8_DC8_FILIAL+DC8_TPESTR>> AS BK_TIPO_EST_FISICA,"
	cQuery +=       " <<KEY_DC8_DC8_FILIAL+DC8_CODEST>> AS BK_ESTRUTURA_FISICA,"
	cQuery +=       " COUNT( DISTINCT D12.D12_IDMOV ) AS QTD_MOVIMENTOS,"
	cQuery +=       " SUM( D12.D12_QTDMOV ) AS QTD_ITENS,"
	cQuery +=       " SUM( D12.D12_QTDMOV * SB1.B1_PESBRU ) AS PESO_BRUTO,"
	cQuery +=       " SUM( ( SB5.B5_COMPRLC * SB5.B5_LARGLC * SB5.B5_ALTURLC ) * ( CASE WHEN SB5.B5_UMIND = '1' THEN D12.D12_QTDMOV ELSE D12.D12_QTDMO2 END ) ) AS VOLUME_M3,"
	cQuery +=       " D12.D12_DTGERA AS DATA_EXTRACAO"
	cQuery += "  FROM <<D12_COMPANY>> D12"
	cQuery += " INNER JOIN <<SB1_COMPANY>> SB1"
	cQuery += "    ON SB1.B1_FILIAL = <<SUBSTR_SB1_D12_FILIAL>>"
	cQuery += "   AND SB1.B1_COD = D12.D12_PRODUT"
	cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<SB5_COMPANY>> SB5"
	cQuery += "    ON SB5.B5_FILIAL = <<SUBSTR_SB5_D12_FILIAL>>"
	cQuery += "   AND SB5.B5_COD = D12.D12_PRODUT"
	cQuery += "   AND SB5.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<SBE_COMPANY>> SBE"
	cQuery += "    ON SBE.BE_FILIAL = <<SUBSTR_SBE_D12_FILIAL>>"
	cQuery += "   AND SBE.BE_LOCAL = D12.D12_LOCORI"
	cQuery += "   AND SBE.BE_LOCALIZ = D12.D12_ENDORI"
	cQuery += "   AND SBE.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<DC8_COMPANY>> DC8"
	cQuery += "    ON DC8.DC8_FILIAL = <<SUBSTR_DC8_BE_FILIAL>>"
	cQuery += "   AND DC8.DC8_CODEST = SBE.BE_ESTFIS"
	cQuery += "   AND DC8.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<SX5_COMPANY>> SX502" 
	cQuery += "    ON SX502.X5_FILIAL = <<SUBSTR_SX5_B1_FILIAL>>"
	cQuery += "   AND SX502.X5_TABELA = '02'"
	cQuery += "   AND SX502.X5_CHAVE = SB1.B1_TIPO"
	cQuery += "   AND SX502.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<SBM_COMPANY>> SBM"
	cQuery += "    ON SBM.BM_FILIAL = <<SUBSTR_SBM_B1_FILIAL>>"
	cQuery += "   AND SBM.BM_GRUPO = SB1.B1_GRUPO"
	cQuery += "   AND SBM.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<SAH_COMPANY>> SAH"
	cQuery += "    ON SAH.AH_FILIAL = <<SUBSTR_SAH_B1_FILIAL>>"
	cQuery += "   AND SAH.AH_UNIMED = SB1.B1_UM"
	cQuery += "   AND SAH.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D12.D12_ATUEST = '1'"
	cQuery += "   AND D12.D12_STATUS <> '0'"
	cQuery += "   AND D12.D12_ORIGEM = 'SC9'"
	cQuery +=   " AND D12.D12_DTGERA >= <<START_DATE>>"
	cQuery +=   " AND D12.D12_DTGERA <= <<FINAL_DATE>>"
	cQuery += "   AND D12.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY D12.D12_FILIAL,"
	cQuery +=          " D12.D12_ORIGEM,"
	cQuery +=          " D12.D12_PRODUT,"
	cQuery +=          " DC8.DC8_FILIAL,"
	cQuery +=          " DC8.DC8_CODEST,"
	cQuery +=          " DC8.DC8_TPESTR,"
	cQuery +=          " D12.D12_DTGERA,"
	cQuery +=          " SB1.B1_FILIAL,"
	cQuery +=          " SB1.B1_UM,"
	cQuery +=          " SB1.B1_TIPO,"
	cQuery +=          " SB1.B1_GRUPO,"
	cQuery +=          " SX502.X5_FILIAL,"
	cQuery +=          " SBM.BM_FILIAL,"
	cQuery +=          " SAH.AH_FILIAL"
Return cQuery