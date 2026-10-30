#INCLUDE "BADEFINITION.CH"

NEW ENTITY ANALISEPROCPEDIDOS

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAnaliseProcPedidos
Visualiza as informações dos Processos x Pedidos da area Juridica.

@author  henrique.cesar
@since   27/02/2018
/*/
//-------------------------------------------------------------------
Class BAAnaliseProcPedidos from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  henrique.cesar
@since   27/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAAnaliseProcPedidos
	_Super:Setup("AnaliseProcPedidos", FACT, "NSY")
	
	//---------------------------------------------------------
	// Define que a extração da entidade será por mês
	//---------------------------------------------------------
	_Super:SetTpExtr( BYMONTH )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author henrique.cesar
@since   27/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAnaliseProcPedidos
	Local cQuery := ""
		
	cQuery := "SELECT <<FINAL_DATE>> AS DATA, " + ;
				"<<KEY_COMPANY>> AS BK_EMPRESA, " + ;
	            "<<KEY_FILIAL_NSY_FILIAL>> AS BK_FILIAL, " + ;
				"<<KEY_NSZ_NSZ_FILIAL+NSZ_COD>> AS BK_PROCESSO_JUR, " + ;
	            "<<KEY_NYB_NYB_FILIAL+NSZ_TIPOAS>> AS BK_ASSUNTO_JURIDICO, " + ;
	            "<<KEY_NRB_NRB_FILIAL+NSZ_CAREAJ>> AS BK_AREA_JURIDICA, " + ;
	            "<<KEY_NQ6_NQ6_FILIAL+NUQ_CCOMAR>> AS BK_COMARCA, " + ;
	            "CASE WHEN (ISNULL(NUQ_CCORRE||NUQ_LCORRE, '')='') OR (RTRIM(NUQ_CCORRE||NUQ_LCORRE)='') " + ;
                    "THEN <<KEY_SA2_A22.A2_FILIAL+NSZ_CCORRE+NSZ_LCORRE>> " + ;
                    "ELSE <<KEY_SA2_SA2.A2_FILIAL+NUQ_CCORRE+NUQ_LCORRE>> " + ; 
                "END AS BK_CREDENCIADO, " + ;
				"<<KEY_NSP_NSP_FILIAL+NSY_CPEVLR>> AS BK_PEDIDOS_JURIDICO, " + ;
                "1 AS QTDE_PROCESSOS_PEDIDOS, " + ;
                "NSY_PEVLR AS VALOR_PROCESSOS_PEDIDOS, " + ;
				" <<CODE_INSTANCE>> AS INSTANCIA " +;
                "FROM <<NSY_COMPANY>> NSY " + ;                
                "INNER JOIN <<NSZ_COMPANY>> NSZ " + ; 
                  	"ON NSZ_FILIAL = <<SUBSTR_NSZ_NSZ_FILIAL>> " + ;
                  	"AND NSZ_COD = NSY_CAJURI " + ;
                  	"AND NSZ.D_E_L_E_T_ = ' ' " + ;
                "LEFT JOIN <<NUQ_COMPANY>> NUQ " + ;
                  	"ON (NUQ.NUQ_FILIAL = <<SUBSTR_NUQ_NSZ_FILIAL>> " + ;
                  	"AND NUQ.NUQ_CAJURI = NSZ.NSZ_COD " + ;
                  	"AND NUQ.NUQ_INSATU = '1' " + ;
                  	"AND NUQ.D_E_L_E_T_ = ' ' ) " + ;          	
                "LEFT JOIN <<NYB_COMPANY>> NYB " + ; //Assunto Juridico
                  	"ON (NYB.NYB_FILIAL = <<SUBSTR_NYB_NSZ_FILIAL>> " + ;
                  	"AND NYB.NYB_COD = NSZ_TIPOAS " + ;
                  	"AND NYB.D_E_L_E_T_ = ' ' ) " + ;	           	                 
              	"LEFT JOIN <<NRB_COMPANY>> NRB " + ; //Area Juridica
              	  	"ON NRB.NRB_FILIAL = <<SUBSTR_NRB_NSZ_FILIAL>> " + ;
              	  	"AND NRB.NRB_COD = NSZ_CAREAJ " + ;
              	  	"AND NRB.D_E_L_E_T_ = ' ' " + ;
				"LEFT JOIN <<NSP_COMPANY>> NSP " + ; //Pedido Jurídico
              	  	"ON NSP.NSP_FILIAL = <<SUBSTR_NSP_NSZ_FILIAL>> " + ;
              	  	"AND NSP.NSP_COD = NSY_CPEVLR " + ;
              	  	"AND NSP.D_E_L_E_T_ = ' ' " + ;
               	"LEFT JOIN <<NQ6_COMPANY>> NQ6 " + ; //Comarca 
			        "ON NQ6.NQ6_FILIAL = <<SUBSTR_NQ6_NUQ_FILIAL>> " +;
			        "AND NQ6.NQ6_COD = NUQ_CCOMAR " + ;
			        "AND NQ6.D_E_L_E_T_ = ' ' " + ;
                "LEFT JOIN <<SA2_COMPANY>> SA2 " + ; //Credenciado
                  	"ON SA2.A2_FILIAL = <<ALIAS_SA2>><<SUBSTR_SA2_NUQ_FILIAL>> " + ;
                  	"AND SA2.A2_COD = NUQ_CCORRE " + ;
                  	"AND SA2.A2_LOJA = NUQ_LCORRE " + ;
                  	"AND SA2.D_E_L_E_T_ = ' ' " + ;
                "LEFT JOIN <<SA2_COMPANY>> A22 " + ; //Credenciado
                  	"ON A22.A2_FILIAL = <<ALIAS_A22>><<SUBSTR_SA2_NSZ_FILIAL>> " + ;
                  	"AND A22.A2_COD = NSZ_CCORRE " + ;
                  	"AND A22.A2_LOJA = NSZ_LCORRE " + ;
                  	"AND A22.D_E_L_E_T_ = ' ' " + ;
                "WHERE (( NSZ_DTINCL BETWEEN <<START_DATE>> AND <<FINAL_DATE>> AND NSZ_SITUAC = '1' ) " + ;
		              "OR ( NSZ_DTENCE BETWEEN <<START_DATE>> AND <<FINAL_DATE>> AND NSZ_SITUAC = '2' )) " + ;
			          "AND NSY.D_E_L_E_T_ = ' ' " + ;
                      " <<AND_XFILIAL_NSY_FILIAL>> "

Return cQuery
