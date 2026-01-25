#INCLUDE "BADEFINITION.CH"

NEW ENTITY OCUPARMAZEM
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BAOcupacaoArmazem
Visualiza as informações de Ocupação do Armazém
 
@author   jackson.werka
@since    16/08/2018
/*/
//-------------------------------------------------------------------
Class BAOcupacaoArmazem from BAEntity
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
Method Setup( ) Class BAOcupacaoArmazem
	_Super:Setup("OcupacaoArmazem", FACT, "SBE")
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.
 
@author  jackson.werka
@since   16/08/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAOcupacaoArmazem
Local cQuery := ""
 
	cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA,"
	cQuery +=       " <<KEY_FILIAL_BE_FILIAL>> AS BK_FILIAL,"
	cQuery +=       " <<KEY_SB2_B2_FILIAL+B2_LOCAL>> AS BK_DEPOSITO,"
	cQuery +=       " <<KEY_DC8_DC8_FILIAL+DC8_TPESTR>> AS BK_TIPO_EST_FISICA,"
	cQuery +=       " <<KEY_DC8_DC8_FILIAL+DC8_CODEST>> AS BK_ESTRUTURA_FISICA,"
	cQuery +=       " SBE.BE_LOCALIZ AS ENDERECO,"
	cQuery +=       " CASE WHEN SBE.BE_NRUNIT = 0 THEN 1 ELSE SBE.BE_NRUNIT END CAPAC_QTDPALETE,"
	cQuery +=       " SBE.BE_CAPACID AS CAPAC_PESO,"
	cQuery +=       " (SBE.BE_ALTURLC * SBE.BE_LARGLC * SBE.BE_COMPRLC) AS CAPAC_VOLUMEM3,"
	cQuery +=       " coalesce(UNT.D14_NRUNIT,0 ) AS OCUP_QTDPALETE,"
	cQuery +=       " coalesce(OCP.D14_QTDEST,0 ) AS OCUP_QTDITEM,"
	cQuery +=       " coalesce(OCP.D14_PESLIQ,0 ) AS OCUP_PESOLIQ,"
	cQuery +=       " coalesce(OCP.D14_PESBRU,0 ) AS OCUP_PESOBRU,"
	cQuery +=       " coalesce(OCP.D14_VOLUME,0 ) AS OCUP_VOLMUEM3,"
	cQuery +=       " <<EXTRACTION_DATE>> AS DATA_EXTRACAO"
	cQuery +=  " FROM <<SBE_COMPANY>> SBE"

	cQuery += " INNER JOIN <<DC8_COMPANY>> DC8"
	cQuery += "    ON DC8.DC8_FILIAL = <<SUBSTR_DC8_BE_FILIAL>>"
	cQuery += "   AND DC8.DC8_CODEST = SBE.BE_ESTFIS"
	cQuery += "   AND DC8.D_E_L_E_T_ = ' '"

	cQuery += "  LEFT JOIN ("

	cQuery += "SELECT D14.D14_FILIAL,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_ENDER,"
	cQuery += "       sum(D14_NRUNIT) D14_NRUNIT"
	cQuery += "  FROM ("
	cQuery += "SELECT D14.D14_FILIAL,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_ENDER,"
	cQuery += "       COUNT(DISTINCT D14.D14_IDUNIT) D14_NRUNIT"
	cQuery += "  FROM <<D14_COMPANY>> D14"
	cQuery += " WHERE D14.D14_QTDEST > 0"
	cQuery += "   AND D14.D14_IDUNIT <> ' '"
	cQuery += "   AND D14.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY D14.D14_FILIAL,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_ENDER"
	cQuery += " UNION ALL "
	cQuery += "SELECT D14.D14_FILIAL,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_ENDER,"
	cQuery += "       CASE WHEN (D14_NRUNIT - CAST(D14_NRUNIT AS INTEGER)) > 0 THEN CAST(D14_NRUNIT AS INTEGER) + 1 ELSE CAST(D14_NRUNIT AS INTEGER) END D14_NRUNIT"
	cQuery += "  FROM ("
	cQuery += "SELECT D14.D14_FILIAL,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_ENDER,"
	cQuery += "       SUM( (CASE WHEN SB5.B5_UMIND = '1' THEN D14.D14_QTDEST ELSE D14.D14_QTDES2 END) / (DC2.DC2_LASTRO*DC2.DC2_CAMADA) ) D14_NRUNIT"
	cQuery += "  FROM <<D14_COMPANY>> D14"
	cQuery += " INNER JOIN <<DC3_COMPANY>> DC3"
	cQuery += "    ON DC3.DC3_FILIAL = <<SUBSTR_DC3_D14_FILIAL>>"
	cQuery += "   AND DC3.DC3_LOCAL  = D14.D14_LOCAL"
	cQuery += "   AND DC3.DC3_CODPRO = D14.D14_PRODUT"
	cQuery += "   AND DC3.DC3_TPESTR = D14.D14_ESTFIS"
	cQuery += "   AND DC3.D_E_L_E_T_ = '  '"
	cQuery += " INNER JOIN <<DC2_COMPANY>> DC2"
	cQuery += "    ON DC2.DC2_FILIAL = <<SUBSTR_DC3_D14_FILIAL>>"
	cQuery += "   AND DC2.DC2_CODNOR = DC3.DC3_CODNOR"
	cQuery += "   AND DC2.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<SB5_COMPANY>> SB5"
	cQuery += "    ON SB5.B5_FILIAL = <<SUBSTR_SB5_D14_FILIAL>>"
	cQuery += "   AND SB5.B5_COD = D14.D14_PRODUT"
	cQuery += "   AND SB5.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D14.D14_IDUNIT = ' '"
	cQuery += "   AND D14.D14_QTDEST > 0"
	cQuery += "   AND D14.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY D14.D14_FILIAL,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_ENDER) D14"
	cQuery += ") D14"
	cQuery += " GROUP BY D14.D14_FILIAL,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_ENDER"
	cQuery += ") UNT"
	cQuery += "  ON UNT.D14_FILIAL = <<SUBSTR_D14_BE_FILIAL>>"
	cQuery += " AND UNT.D14_LOCAL  = SBE.BE_LOCAL"
	cQuery += " AND UNT.D14_ENDER  = SBE.BE_LOCALIZ"

	cQuery += "  LEFT JOIN ("
	cQuery += "SELECT D14.D14_FILIAL,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_ENDER,"
	cQuery += "       SUM( D14.D14_QTDEST ) D14_QTDEST,"
	cQuery += "       SUM( SB1.B1_PESO   * D14.D14_QTDEST ) D14_PESLIQ,"
	cQuery += "       SUM( SB1.B1_PESBRU * D14.D14_QTDEST ) D14_PESBRU,"
	cQuery += "       SUM( ( SB5.B5_COMPRLC * SB5.B5_LARGLC * SB5.B5_ALTURLC ) * ( CASE WHEN SB5.B5_UMIND = '1' THEN D14.D14_QTDEST ELSE D14.D14_QTDES2 END ) ) D14_VOLUME"
	cQuery += "  FROM <<D14_COMPANY>> D14"
	cQuery += " INNER JOIN <<SB1_COMPANY>> SB1"
	cQuery += "    ON SB1.B1_FILIAL = <<SUBSTR_SB1_D14_FILIAL>>"
	cQuery += "   AND SB1.B1_COD = D14.D14_PRODUT"
	cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN <<SB5_COMPANY>> SB5"
	cQuery += "    ON SB5.B5_FILIAL = <<SUBSTR_SB5_D14_FILIAL>>"
	cQuery += "   AND SB5.B5_COD = SB1.B1_COD"
	cQuery += "   AND SB5.D_E_L_E_T_ = ' '"
	cQuery += " WHERE D14.D14_QTDEST > 0"
	cQuery += "   AND D14.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY D14.D14_FILIAL,"
	cQuery += "       D14.D14_LOCAL,"
	cQuery += "       D14.D14_ENDER) OCP"
	cQuery += "   ON OCP.D14_FILIAL = <<SUBSTR_D14_BE_FILIAL>>"
	cQuery += "  AND OCP.D14_LOCAL  = SBE.BE_LOCAL"
	cQuery += "  AND OCP.D14_ENDER  = SBE.BE_LOCALIZ"

	cQuery += "  LEFT JOIN ("
	cQuery += "SELECT DISTINCT B2_FILIAL, B2_LOCAL FROM <<SB2_COMPANY>> WHERE D_E_L_E_T_ = ' ') SB2"
	cQuery += "  ON SB2.B2_FILIAL = <<SUBSTR_SB2_BE_FILIAL>>"
	cQuery += " AND SB2.B2_LOCAL = SBE.BE_LOCAL"

	cQuery += " WHERE SBE.D_E_L_E_T_ = ' '"
Return cQuery