#INCLUDE "BADEFINITION.CH"

NEW ENTITY DISPLOTEESTOQUE
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BADispEstoqueItemLote
Visualiza as informações de Disponibilidade do Estoque por Item x Lote
 
@author   jackson.werka
@since    16/08/2018
/*/
//-------------------------------------------------------------------
Class BADispEstoqueItemLote from BAEntity
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
Method Setup( ) Class BADispEstoqueItemLote
	_Super:Setup("DispEstoqueItemLote", FACT, "SB8")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.
 
@author  jackson.werka
@since   16/08/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BADispEstoqueItemLote
Local cQuery := ""
 
	cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA,"
	cQuery +=       " <<KEY_FILIAL_B2_FILIAL>> AS BK_FILIAL,"
	cQuery +=       " <<KEY_SB2_B2_FILIAL+B2_LOCAL>> AS BK_DEPOSITO,"
	cQuery +=       " <<KEY_SB1_B1_FILIAL+B2_COD>> AS BK_ITEM,"
	cQuery +=       " <<KEY_SAH_AH_FILIAL+B1_UM>> AS BK_UNIDADE_DE_MEDIDA,"
	cQuery +=       " <<KEY_SX5_SX502.X5_FILIAL+B1_TIPO>> AS BK_FAMILIA_MATERIAL,"
	cQuery +=       " <<KEY_SBM_BM_FILIAL+B1_GRUPO>> AS BK_GRUPO_ESTOQUE,"
	cQuery +=       " SB8.B8_LOTECTL AS NUM_LOTE,"
	cQuery +=       " SB8.B8_DTVALID AS DAT_VALIDADE,"
	cQuery +=       " D14.QTD_ESTOQUE,"
	cQuery +=       " SB8.B8_EMPENHO AS QTD_EMPENHADA,"
	cQuery +=       " SB8.B8_QACLASS AS QTD_ENDERECAR,"
	cQuery +=       " D14.QTD_BLOQUEADA,"
	cQuery +=       " <<EXTRACTION_DATE>> AS DATA_EXTRACAO"
	cQuery +=  " FROM <<SB8_COMPANY>> SB8"
	cQuery += " INNER JOIN <<SB2_COMPANY>> SB2"
	cQuery += "    ON SB2.B2_FILIAL = <<SUBSTR_SB2_B8_FILIAL>>"
	cQuery += "   AND SB2.B2_LOCAL = SB8.B8_LOCAL"
	cQuery += "   AND SB2.B2_COD = SB8.B8_PRODUTO"
	cQuery += "   AND SB2.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<SB1_COMPANY>> SB1"
	cQuery += "    ON SB1.B1_FILIAL = <<SUBSTR_SB1_B8_FILIAL>>"
	cQuery += "   AND SB1.B1_COD = SB8.B8_PRODUTO"
	cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
	cQuery += "INNER JOIN ( "
	cQuery += "SELECT D14.D14_FILIAL,"
	cQuery += "       D14.D14_PRDORI,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_LOTECT,"
	cQuery += "       D14.D14_NUMLOT,"
	cQuery += "       sum(D14.D14_QTDEST) AS QTD_ESTOQUE,"
	cQuery += "       sum(D14.D14_QTDEMP+D14.D14_QTDPEM) AS QTD_EMPENHADA,"
	cQuery += "       sum(D14.D14_QTDBLQ) AS QTD_BLOQUEADA"
	cQuery += "  FROM <<D14_COMPANY>> D14"
	cQuery += " WHERE D14.D14_PRODUT = D14.D14_PRDORI"
	cQuery += "   AND D14.D14_QTDEST > 0"
	cQuery += "   AND D14.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY D14.D14_FILIAL,"
	cQuery += "       D14.D14_PRDORI,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_LOTECT,"
	cQuery += "       D14.D14_NUMLOT"
	cQuery += " UNION ALL "
	cQuery += "SELECT D14M.D14_FILIAL,"
	cQuery += "       D14M.D14_PRDORI,"
	cQuery += "       D14M.D14_LOCAL,"
	cQuery += "       D14M.D14_LOTECT,"
	cQuery += "       D14M.D14_NUMLOT,"
	cQuery += "       min(D14M.QTD_ESTOQUE) AS QTD_ESTOQUE,"
	cQuery += "       min(D14M.QTD_EMPENHADA) AS QTD_EMPENHADA,"
	cQuery += "       min(D14M.QTD_BLOQUEADA) AS QTD_BLOQUEADA"
	cQuery += "  FROM ( "
	cQuery += "SELECT D14.D14_FILIAL,"
	cQuery += "       D14.D14_PRODUT,"
	cQuery += "       D14.D14_PRDORI,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_LOTECT,"
	cQuery += "       D14.D14_NUMLOT,"
	cQuery += "       sum(D14.D14_QTDEST/D11.D11_QTMULT) AS QTD_ESTOQUE,"
	cQuery += "       sum((D14.D14_QTDEMP+D14.D14_QTDPEM)/D11.D11_QTMULT) AS QTD_EMPENHADA,"
	cQuery += "       sum(D14.D14_QTDBLQ/D11.D11_QTMULT) AS QTD_BLOQUEADA"
	cQuery += "  FROM <<D14_COMPANY>> D14"
	cQuery += " INNER JOIN <<D11_COMPANY>> D11"
	cQuery += "    ON D11.D11_FILIAL = <<SUBSTR_D11_D14_FILIAL>>"
	cQuery += "   AND D11.D11_PRDCMP = D14.D14_PRODUT"
	cQuery += "   AND D11.D11_PRDORI = D14.D14_PRDORI"
	cQuery += "   AND D11.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D14.D14_QTDEST > 0"
	cQuery += "   AND D14.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY D14.D14_FILIAL,"
	cQuery += "       D14.D14_PRODUT,"
	cQuery += "       D14.D14_PRDORI,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_LOTECT,"
	cQuery += "       D14.D14_NUMLOT) D14M"
	cQuery += " GROUP BY D14M.D14_FILIAL,"
	cQuery += "       D14M.D14_PRDORI,"
	cQuery += "       D14M.D14_LOCAL,"
	cQuery += "       D14M.D14_LOTECT,"
	cQuery += "       D14M.D14_NUMLOT) D14"
	cQuery += "    ON D14.D14_FILIAL = <<SUBSTR_D14_B8_FILIAL>>"
	cQuery += "   AND D14.D14_PRDORI = SB8.B8_PRODUTO"
	cQuery += "   AND D14.D14_LOCAL  = SB8.B8_LOCAL"
	cQuery += "   AND D14.D14_LOTECT = SB8.B8_LOTECTL"
	cQuery += "   AND D14.D14_NUMLOT = SB8.B8_NUMLOTE"
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
	cQuery += " WHERE SB8.D_E_L_E_T_ = ' '"
	cQuery += "   AND SB8.B8_SALDO > 0"
Return cQuery