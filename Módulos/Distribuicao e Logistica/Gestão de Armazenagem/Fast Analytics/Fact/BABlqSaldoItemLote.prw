#INCLUDE "BADEFINITION.CH"

NEW ENTITY BLQSALITEMLOTE
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BABlqSaldoItemLote
Visualiza as informações de Bloqueio de Saldo por Item x Lote
 
@author   jackson.werka
@since    16/08/2018
/*/
//-------------------------------------------------------------------
Class BABlqSaldoItemLote from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.
 
@author  jackson.werka 
@since   16/08/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BABlqSaldoItemLote
	_Super:Setup("BlqSaldoItemLote", FACT, "D0U")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.
 
@author  jackson.werka
@since   16/08/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BABlqSaldoItemLote
Local cQuery := ""
 
	cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA,"
	cQuery +=       " <<KEY_FILIAL_B2_FILIAL>> AS BK_FILIAL,"
	cQuery +=       " <<KEY_SB2_B2_FILIAL+B2_LOCAL>> AS BK_DEPOSITO,"
	cQuery +=       " <<KEY_SB1_B1_FILIAL+B2_COD>> AS BK_ITEM,"
	cQuery +=       " <<KEY_SAH_AH_FILIAL+B1_UM>> AS BK_UNIDADE_DE_MEDIDA,"
	cQuery +=       " <<KEY_SX5_SX502.X5_FILIAL+B1_TIPO>> AS BK_FAMILIA_MATERIAL,"
	cQuery +=       " <<KEY_SBM_BM_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE,"
	cQuery +=       " D0V.D0V_LOTECT AS NUM_LOTE,"
	cQuery +=       " D0V.D0V_DTVALD AS DAT_VALIDADE,"
	cQuery +=       " <<KEY_SX5_SX5E1.X5_FILIAL+D0U_MOTIVO>> AS BK_MOTIVO_BLOQUEIO,"
	cQuery +=       " D0V.QTD_BLOQUEADA,"
	cQuery +=       " <<EXTRACTION_DATE>> AS DATA_EXTRACAO"
	cQuery +=  " FROM <<SB2_COMPANY>> SB2"
	cQuery += " INNER JOIN <<SB1_COMPANY>> SB1"
	cQuery += "    ON SB1.B1_FILIAL = <<SUBSTR_SB1_B2_FILIAL>>"
	cQuery += "   AND SB1.B1_COD = SB2.B2_COD"
	cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN ( "
	cQuery += "SELECT D0V.D0V_FILIAL,"
	cQuery += "       D0V.D0V_LOCAL,"
	cQuery += "       D0V.D0V_PRDORI,"
	cQuery += "       D0V.D0V_LOTECT,"
	cQuery += "       D0V.D0V_DTVALD,"
	cQuery += "       D0U.D0U_MOTIVO,"
	cQuery += "       sum(D0V.D0V_QTDBLQ) AS QTD_BLOQUEADA"
	cQuery += "  FROM <<D0V_COMPANY>> D0V"
	cQuery += " INNER JOIN <<D0U_COMPANY>> D0U"
	cQuery += "    ON D0U.D0U_FILIAL = <<SUBSTR_D0U_D0V_FILIAL>>"
	cQuery += "   AND D0U.D0U_IDBLOQ = D0V.D0V_IDBLOQ"
	cQuery += "   AND D0U.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D0V.D0V_PRDORI = D0V.D0V_PRODUT"
	cQuery += "   AND D0V.D0V_QTDBLQ > 0"
	cQuery += "   AND D0V.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY D0V.D0V_FILIAL,"
	cQuery += "       D0V.D0V_LOCAL,"
	cQuery += "       D0V.D0V_PRDORI,"
	cQuery += "       D0V.D0V_LOTECT,"
	cQuery += "       D0V.D0V_DTVALD,"
	cQuery += "       D0U.D0U_MOTIVO"
	cQuery += " UNION ALL "
	cQuery += " SELECT D0VM.D0V_FILIAL,"
	cQuery += "       D0VM.D0V_LOCAL,"
	cQuery += "       D0VM.D0V_PRDORI,"
	cQuery += "       D0VM.D0V_LOTECT,"
	cQuery += "       D0VM.D0V_DTVALD,"
	cQuery += "       D0VM.D0U_MOTIVO,"
	cQuery += "       MIN(D0VM.D0V_QTDBLQ) AS QTD_BLOQUEADA"
	cQuery += "  FROM ( "
	cQuery += "SELECT D0V.D0V_FILIAL,"
	cQuery += "       D0V.D0V_LOCAL,"
	cQuery += "       D0V.D0V_PRDORI,"
	cQuery += "       D0V.D0V_PRODUT,"
	cQuery += "       D0V.D0V_LOTECT,"
	cQuery += "       D0V.D0V_DTVALD,"
	cQuery += "       D0U.D0U_MOTIVO,"
	cQuery += "       sum(D0V.D0V_QTDBLQ/D11.D11_QTMULT) AS D0V_QTDBLQ"
	cQuery += "  FROM <<D0V_COMPANY>> D0V"
	cQuery += " INNER JOIN <<D0U_COMPANY>> D0U"
	cQuery += "    ON D0U.D0U_FILIAL = <<SUBSTR_D0U_D0V_FILIAL>>"
	cQuery += "   AND D0U.D0U_IDBLOQ = D0V.D0V_IDBLOQ
	cQuery += "   AND D0U.D_E_L_E_T_ = ' '
	cQuery += " INNER JOIN <<D11_COMPANY>> D11 
	cQuery += "    ON D11.D11_FILIAL = <<SUBSTR_D11_D0V_FILIAL>>"
	cQuery += "   AND D11.D11_PRDCMP = D0V.D0V_PRODUT"
	cQuery += "   AND D11.D11_PRDORI = D0V.D0V_PRDORI"
	cQuery += "   AND D11.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D0V.D0V_QTDBLQ > 0"
	cQuery += "   AND D0V.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY D0V.D0V_FILIAL,"
	cQuery += "       D0V.D0V_LOCAL,"
	cQuery += "       D0V.D0V_PRDORI,"
	cQuery += "       D0V.D0V_PRODUT,"
	cQuery += "       D0V.D0V_LOTECT,"
	cQuery += "       D0V.D0V_DTVALD,"
	cQuery += "       D0U.D0U_MOTIVO ) D0VM"
	cQuery += " GROUP BY D0VM.D0V_FILIAL,"
	cQuery += "       D0VM.D0V_LOCAL,"
	cQuery += "       D0VM.D0V_PRDORI,"
	cQuery += "       D0VM.D0V_LOTECT,"
	cQuery += "       D0VM.D0V_DTVALD,"
	cQuery += "       D0VM.D0U_MOTIVO ) D0V"
	cQuery += "    ON D0V.D0V_FILIAL = <<SUBSTR_D0V_B2_FILIAL>>"
	cQuery += "   AND D0V.D0V_LOCAL = SB2.B2_LOCAL"
	cQuery += "   AND D0V.D0V_PRDORI = SB2.B2_COD"
	cQuery += "  LEFT JOIN <<SX5_COMPANY>> SX502" 
	cQuery += "    ON SX502.X5_FILIAL = <<SUBSTR_SX5_B1_FILIAL>>"
	cQuery += "   AND SX502.X5_TABELA = '02'"
	cQuery += "   AND SX502.X5_CHAVE = SB1.B1_TIPO"
	cQuery += "   AND SX502.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<SX5_COMPANY>> SX5E1" 
	cQuery += "    ON SX502.X5_FILIAL = <<SUBSTR_SX5_B1_FILIAL>>"
	cQuery += "   AND SX502.X5_TABELA = 'E1'"
	cQuery += "   AND SX502.X5_CHAVE = D0V.D0U_MOTIVO"
	cQuery += "   AND SX502.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<SBM_COMPANY>> SBM"
	cQuery += "    ON SBM.BM_FILIAL = <<SUBSTR_SBM_B1_FILIAL>>"
	cQuery += "   AND SBM.BM_GRUPO = SB1.B1_GRUPO"
	cQuery += "   AND SBM.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN <<SAH_COMPANY>> SAH"
	cQuery += "    ON SAH.AH_FILIAL = <<SUBSTR_SAH_B1_FILIAL>>"
	cQuery += "   AND SAH.AH_UNIMED = SB1.B1_UM"
	cQuery += "   AND SAH.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SB2.D_E_L_E_T_ = ' '"
Return cQuery