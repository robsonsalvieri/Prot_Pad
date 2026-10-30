#INCLUDE "BADEFINITION.CH"

NEW ENTITY AUDDESPESA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAuditDespesa
Visualiza as informações das auditorias das despesas.

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAAuditDespesa from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAAuditDespesa
	_Super:Setup("AuditoriaDespesa", FACT, "O0I")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Helio Leal
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAuditDespesa
	Local cQuery := ""

	cQuery +=	" SELECT  <<KEY_COMPANY>> AS BK_EMPRESA," + ;
					" <<KEY_FILIAL_O0I_FILPRO>>         AS BK_FILIAL," + ;          // Filial do Processo
					" <<KEY_NSR_NSR_FILIAL+O0I_CTPDES>> AS BK_TIPO_DESPESA," + ;    // Código do Tipo
					" <<KEY_O0E_O0E_FILIAL+O0I_MARCA>>  AS BK_MARCA," + ;           // Data da Marca
				    " <<KEY_NSZ_O0I_FILPRO+O0I_CAJURI>> AS BK_PROCESSO_JUR, " + ;   // Código Interno 
					" O0I_DATA," + ;                                                // Data da Despesa
					" O0I_VALOR, " + ;                                                // Valor da Despesa
					" <<CODE_INSTANCE>> AS INSTANCIA " +;
				" FROM <<O0I_COMPANY>> O0I" + ;
				" INNER JOIN <<O0E_COMPANY>> O0E" + ; // Marca
					" ON O0E_MARCA = O0I_MARCA" + ;
					" AND O0E_FILIAL = <<SUBSTR_O0E_O0I_FILIAL>>" + ;
					" AND O0E.D_E_L_E_T_ = ' '" + ;
				" LEFT JOIN <<NSR_COMPANY>> NSR" + ; // Tipo despesa
					" ON NSR_COD = O0I_CTPDES" + ;
					" AND NSR_FILIAL = <<SUBSTR2_NSR_NSZ_O0I_FILPRO>> " + ;
					" AND NSR.D_E_L_E_T_ = ' ' " + ;				
				" WHERE O0I.D_E_L_E_T_ = ' ' " + ;
				    " <<AND_XFILIAL_O0I_FILIAL>> "
Return cQuery
