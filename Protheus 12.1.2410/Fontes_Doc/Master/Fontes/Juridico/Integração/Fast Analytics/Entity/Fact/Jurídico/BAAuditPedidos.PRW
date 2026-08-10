#INCLUDE "BADEFINITION.CH"

NEW ENTITY AUDPEDIDOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAuditPedidos
Visualiza as informações das auditorias pedidos.

@since   08/05/2020
/*/
//-------------------------------------------------------------------
Class BAAuditPedidos from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@since   08/05/2020
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAAuditPedidos
	_Super:Setup("AuditoriaPedidos", FACT, "O0Y")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@since   08/05/2020
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAuditPedidos
Local cQuery := ""

	cQuery += " SELECT  <<KEY_COMPANY>>             AS BK_EMPRESA,"     +;
				" <<KEY_FILIAL_O0Y_FILPRO>>         AS BK_FILIAL,"      +;       // Filial do Processo
				" <<KEY_NQ7_NQ7_FILIAL+O0Y_PROGNO>> AS BK_PROGNOSTICO," +;
				" <<KEY_O0E_O0E_FILIAL+O0Y_MARCA>>  AS BK_MARCA,"       +;
				" <<KEY_NSZ_O0Y_FILPRO+O0Y_CAJURI>> AS BK_PROCESSO_JUR, "     +; //Código Interno
				" <<KEY_NSP_NSP_FILIAL+O0Y_CTPPED>> AS BK_PEDIDOS_JURIDICO, " +; //Código Pedido Jurídico
													" O0Y_VPEDID," +;            // Valor do pedido
													" O0Y_VATPED," +;            // Valor do pedido atualizado
													" O0Y_VPROVA," +;            // Valor provável
													" O0Y_VATPRO," +;            // Valor provável atualizado
													" O0Y_VPOSSI," +;            // Valor possível
													" O0Y_VATPOS," +;            // Valor possível atualizado
													" O0Y_VREMOT," +;            // Valor remoto
													" O0Y_VATREM," +;            // Valor remoto atualizado
													" O0Y_VINCON," +;            // Valor introverso
													" O0Y_VATINC, " +;           // Valor introverso atualizado
													" <<CODE_INSTANCE>> AS INSTANCIA " +;
			" FROM <<O0Y_COMPANY>> O0Y" + ;
				" INNER JOIN <<O0E_COMPANY>> O0E" +; // Marca
					" ON O0E_MARCA = O0Y_MARCA"   +;
					" AND O0E_FILIAL = <<SUBSTR_O0E_O0Y_FILIAL>>" +;
					" AND O0E.D_E_L_E_T_ = ' '"  +;
				" LEFT JOIN <<NQ7_COMPANY>> NQ7" +; // Prognóstico
					" ON NQ7_COD = O0Y_PROGNO"   +;
					" AND NQ7_FILIAL = <<SUBSTR2_NQ7_NSZ_O0Y_FILPRO>> " +;
					" AND NQ7.D_E_L_E_T_ = ' '"  +;
				" LEFT JOIN <<NSP_COMPANY>> NSP" +; // Pedido Juridico
					" ON NSP_COD = O0Y_CTPPED"   +;
					" AND NSP_FILIAL = <<SUBSTR2_NSP_NSZ_O0Y_FILPRO>> " +;
					" AND NSP.D_E_L_E_T_ = ' '" +;
			" WHERE O0Y.D_E_L_E_T_ = ' ' "      +;
					"<<AND_XFILIAL_O0Y_FILIAL>> "
Return cQuery
