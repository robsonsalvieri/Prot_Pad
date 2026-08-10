#INCLUDE "BADEFINITION.CH"

NEW ENTITY AUDGARANTIA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAuditGarantia
Visualiza as informações das auditorias garantidas.

@author  Helio Leal
@since   26/02/2018
/*/
//-------------------------------------------------------------------
Class BAAuditGarantia from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  Helio Leal
@since   26/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAAuditGarantia
	_Super:Setup("AuditoriaGarantia", FACT, "O0H")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Helio Leal
@since   26/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAuditGarantia
	Local cQuery := ""

	cQuery +=	" SELECT  <<KEY_COMPANY>> AS BK_EMPRESA," + ;
					" <<KEY_FILIAL_O0H_FILPRO>>         AS BK_FILIAL," + ;	  // Filial do Processo
					" <<KEY_NQW_NQW_FILIAL+O0H_CTPGAR>> AS BK_TIPO_GARANTIA," + ;
					" <<KEY_NW7_NW7_FILIAL+O0H_CCOMON>> AS BK_FORMA_CORRECAO," + ;
					" <<KEY_O0E_O0E_FILIAL+O0H_MARCA>>  AS BK_MARCA," + ;
	                " <<KEY_NSZ_O0H_FILPRO+O0H_CAJURI>> AS BK_PROCESSO_JUR, " +;  //Código Interno
					" O0H_MOVFIN," + ; // Tipo da Movimentação
					" O0H_DATA," + ;   // Data da Garantia
					" O0H_EMBREC," + ; // Embargo ou Recurso
					" O0H_VALOR," + ;  // Valor da Garantia
					" O0H_VLRATU," + ; // Valor da Garantia Atual
					" O0H_VCPROV," + ; // Valor Correção Garantia
					" O0H_VJPROV," + ; // Valor Juros da Garantia
					" O0H_LEVANT, " + ;  // Valor Levantamento
					" <<CODE_INSTANCE>> AS INSTANCIA " +;
				" FROM <<O0H_COMPANY>> O0H" + ;
				" INNER JOIN <<O0E_COMPANY>> O0E" + ; // Marca
					" ON O0E_MARCA = O0H_MARCA" + ;
					" AND O0E_FILIAL = <<SUBSTR_O0E_O0H_FILIAL>>" + ;
					" AND O0E.D_E_L_E_T_ = ' '" + ;
				" LEFT JOIN <<NQW_COMPANY>> NQW" + ; // Tipo garantia
					" ON NQW_COD = O0H_CTPGAR" + ;
					" AND NQW_FILIAL = <<SUBSTR2_NQW_NSZ_O0H_FILPRO>> " +;
					" AND NQW.D_E_L_E_T_ = ' ' " + ;
				" LEFT JOIN <<NW7_COMPANY>> NW7" + ; //Forma de correção
					" ON NW7_COD = O0H_CCOMON" + ;
					" AND NW7_FILIAL = <<SUBSTR2_NW7_NSZ_O0H_FILPRO>> " +;
					" AND NW7.D_E_L_E_T_ = ' ' " + ;
				" WHERE O0H.D_E_L_E_T_ = ' ' " + ;
					" <<AND_XFILIAL_O0H_FILIAL>> "

Return cQuery
