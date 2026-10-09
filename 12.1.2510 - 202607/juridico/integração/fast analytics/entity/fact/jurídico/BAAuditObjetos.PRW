#INCLUDE "BADEFINITION.CH"

NEW ENTITY AUDOBJETOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAuditObjetos
Visualiza as informações das auditorias objetos.

@author  Helio Leal
@since   26/02/2018
/*/
//-------------------------------------------------------------------
Class BAAuditObjetos from BAEntity
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
Method Setup( ) Class BAAuditObjetos
	_Super:Setup("AuditoriaObjetos", FACT, "O0G")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Helio Leal
@since   26/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAuditObjetos
	Local cQuery := ""

	cQuery +=	" SELECT  <<KEY_COMPANY>> AS BK_EMPRESA," + ;
					" <<KEY_FILIAL_O0G_FILPRO>>         AS BK_FILIAL," + ; // Filial do Processo
					" <<KEY_NQ7_NQ7_FILIAL+O0G_CPROG>>  AS BK_PROGNOSTICO," + ;
					" <<KEY_NQQ_NQQ_FILIAL+O0G_CDECPE>> AS BK_DECISAO," + ;
					" <<KEY_O03_O03_FILIAL+O0G_CBASED>> AS BK_BASE_DECISAO," + ;
					" <<KEY_NW7_NW7_FILIAL+O0G_CCOMON>> AS BK_FORMA_CORRECAO," + ;
					" <<KEY_O07_O07_FILIAL+O0G_COD+O0G_CFUPRO+O0G_CCLFUN>> AS BK_FUNDAMENTOS_OBJETO," + ;
					" <<KEY_O0E_O0E_FILIAL+O0G_MARCA>>  AS BK_MARCA," + ;
					" <<KEY_NSZ_O0G_FILPRO+O0G_CAJURI>> AS BK_PROCESSO_JUR, " +;  //Código Interno
					" <<KEY_NSP_NSP_FILIAL+O0G_CPEVLR>> AS BK_PEDIDOS_JURIDICO, " + ; //Código Pedido Jurídico
					" O0G_PEDATA," + ; // Data do Objeto
					" O0G_DTJURO," + ; // Data Juros Objeto
					" O0G_PEVLR," + ;  // Valor do Objeto
					" O0G_PEINVL," + ; // Objeto Inestimável
					" O0G_CCORPE," + ; // Valor de Correção
					" O0G_CJURPE," + ; // Valor de Juros
					" O0G_MULATU," + ; // Valor Multa Objeto Atual
					" O0G_PEVLRA," + ; // Valor do Objeto Atual
					" O0G_CCLFUN, " + ;  // Código da Classificação
					" <<CODE_INSTANCE>> AS INSTANCIA " +;
				" FROM <<O0G_COMPANY>> O0G" + ;
					" INNER JOIN <<O0E_COMPANY>> O0E" + ; // Marca
						" ON O0E_MARCA = O0G_MARCA" + ;
						" AND O0E_FILIAL = <<SUBSTR_O0E_O0G_FILIAL>>" + ;
						" AND O0E.D_E_L_E_T_ = ' '" + ;
					" LEFT JOIN <<NQ7_COMPANY>> NQ7" + ; // Prognóstico
						" ON NQ7_COD = O0G_CPROG" + ;
				    	" AND NQ7_FILIAL = <<SUBSTR2_NQ7_NSZ_O0G_FILPRO>> " +;
						" AND NQ7.D_E_L_E_T_ = ' '" + ;
					" LEFT JOIN <<NQQ_COMPANY>> NQQ" + ; //Decisão 
						" ON NQQ_COD = O0G_CDECPE" + ;
						" AND NQQ_FILIAL = <<SUBSTR2_NQQ_NSZ_O0G_FILPRO>> " +;
						" AND NQQ.D_E_L_E_T_ = ' '" + ;
					" LEFT JOIN <<O03_COMPANY>> O03" + ; // Base de decisão
						" ON O03_COD = O0G_CBASED" + ;
						" AND O03_FILIAL = <<SUBSTR2_O03_NSZ_O0G_FILPRO>> " +;
						" AND O03.D_E_L_E_T_ = ' '" + ;
					" LEFT JOIN <<NW7_COMPANY>> NW7" + ; // Forma de correção
						" ON NW7_COD = O0G_CCOMON" + ; 
						" AND NW7_FILIAL = <<SUBSTR2_NW7_NSZ_O0G_FILPRO>> " +;
						" AND NW7.D_E_L_E_T_ = ' '" + ;
					" LEFT JOIN <<NSP_COMPANY>> NSP" + ; // Pedido Juridico
						" ON NSP_COD = O0G_CPEVLR" + ; 
						" AND NSP_FILIAL = <<SUBSTR2_NSP_NSZ_O0G_FILPRO>> " +;
						" AND NSP.D_E_L_E_T_ = ' '" + ;
					" LEFT JOIN <<O07_COMPANY>> O07" + ; // Fundamentos de objetos
						" ON O07_COBJET = O0G_COD   " + ;
						" AND O07_CFUPRO = O0G_CFUPRO" + ;
						" AND O07_CCLFUN = O0G_CCLFUN" + ;
						" AND O07_FILIAL = <<SUBSTR2_O07_NSZ_O0G_FILPRO>> " +;
						" AND O07.D_E_L_E_T_ = ' ' " + ;
				" WHERE O0G.D_E_L_E_T_ = ' ' " + ;
						"<<AND_XFILIAL_O0G_FILIAL>> "
Return cQuery
