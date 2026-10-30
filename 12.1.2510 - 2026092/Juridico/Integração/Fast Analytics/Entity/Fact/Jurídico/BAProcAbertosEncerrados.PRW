#INCLUDE "BADEFINITION.CH"

NEW ENTITY PROCABERTOENCERRADO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAProcAbertosEncerrados
Visualiza as informações dos Processos Abertos e Encerrados da area Juridica.

@author  henrique.cesar
@since   27/02/2018
/*/
//-------------------------------------------------------------------
Class BAProcAbertosEncerrados from BAEntity
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
Method Setup( ) Class BAProcAbertosEncerrados
	_Super:Setup("ProcAbertosEncerrados", FACT, "NSZ")
	
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
Method BuildQuery( ) Class BAProcAbertosEncerrados
	Local cQuery := ""
	
	cQuery := "SELECT <<FINAL_DATE>> AS DATA, " + ;
                   "<<KEY_COMPANY>> AS BK_EMPRESA, " + ;
		           "<<KEY_FILIAL_NSZ.NSZ_FILIAL>> AS BK_FILIAL, " + ; 
				   "<<KEY_NSZ_NSZ_FILIAL+NSZ.NSZ_COD>> AS BK_PROCESSO_JUR, " + ;				   
		           "<<KEY_NYB_NYB_FILIAL+NSZ.NSZ_TIPOAS>> AS BK_ASSUNTO_JURIDICO, " + ; 
		           "<<KEY_NQ6_NQ6_FILIAL+NUQ_CCOMAR>> AS BK_COMARCA, " + ; 
                   "CASE WHEN (ISNULL(NUQ_CCORRE||NUQ_LCORRE, '')='') OR (RTRIM(NUQ_CCORRE||NUQ_LCORRE)='') " + ;
                   	"THEN <<KEY_SA2_A22.A2_FILIAL+NSZ.NSZ_CCORRE+NSZ.NSZ_LCORRE>> " + ;
                   	"ELSE <<KEY_SA2_SA2.A2_FILIAL+NUQ_CCORRE+NUQ_LCORRE>> " + ;
                   "END AS BK_CREDENCIADO, " + ;
                   "<<KEY_NRB_NRB_FILIAL+NSZ.NSZ_CAREAJ>> AS BK_AREA_JURIDICA, " + ;
                   "<<KEY_SA1_A1_FILIAL+NSZ.NSZ_CCLIEN+NSZ.NSZ_LCLIEN>> AS BK_CLIENTE, " + ;
                   "<<KEY_NQI_NQI_FILIAL+NSZ.NSZ_CMOENC>> AS BK_MOTIVO_ENCERRAMENTO, " + ;
                   "ISNULL(ABERTOS.TOTAL,0) AS QTDE_PROC_ABERTOS, " + ;
                   "ISNULL(FECHADOS.TOTAL,0) AS QTDE_PROC_FECHADOS, " + ;
                   " <<CODE_INSTANCE>> AS INSTANCIA " +;
              "FROM <<NSZ_COMPANY>> NSZ " + ;
              	 "LEFT JOIN ( " + ;
	                "SELECT NSZA.NSZ_COD, COUNT(NSZA.NSZ_COD) TOTAL " + ;
	                "FROM <<NSZ_COMPANY>> NSZA " + ;
	                "WHERE NSZA.NSZ_DTINCL BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
	                	"AND NSZA.NSZ_FILIAL = <<SUBSTR_NSZ_NSZ_FILIAL>> " + ;
	                	"AND NSZA.D_E_L_E_T_ = ' ' " + ;
	                  "GROUP BY NSZA.NSZ_COD) ABERTOS ON (NSZ.NSZ_COD = ABERTOS.NSZ_COD) " + ;
	             "LEFT JOIN ( " + ;
	             	"SELECT NSZF.NSZ_COD, COUNT(NSZF.NSZ_COD) TOTAL " + ;
	             	"FROM <<NSZ_COMPANY>> NSZF " + ;
	             	"WHERE NSZF.NSZ_DTENCE BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
	             		"AND NSZF.NSZ_SITUAC = '2' " + ;
	             		"AND NSZF.NSZ_FILIAL = <<SUBSTR_NSZ_NSZ_FILIAL>> " + ;
	             		"AND NSZF.D_E_L_E_T_ = ' ' " + ;
	                  "GROUP BY NSZF.NSZ_COD) FECHADOS ON (NSZ.NSZ_COD = FECHADOS.NSZ_COD) " + ;
	             "INNER JOIN <<NUQ_COMPANY>> NUQ " + ;
	             	"ON (NUQ_FILIAL = <<SUBSTR_NUQ_NSZ.NSZ_FILIAL>> " + ;
	             	"AND NUQ_CAJURI = NSZ.NSZ_COD " + ;
	             	"AND NUQ_INSATU = '1' " + ;
	             	"AND NUQ.D_E_L_E_T_ = ' ' ) " + ;
	             "LEFT JOIN <<NYB_COMPANY>> NYB " + ; //Assunto Juridico
                      "ON (NYB_FILIAL = <<SUBSTR_NYB_NSZ.NSZ_FILIAL>> " + ;
                      "AND NYB_COD = NSZ.NSZ_TIPOAS " + ;
                      "AND NYB.D_E_L_E_T_ = ' ' ) " + ;
                 "LEFT JOIN <<NQ6_COMPANY>> NQ6 " + ; //Comarca 
			          "ON NQ6_FILIAL = <<SUBSTR_NQ6_NUQ_FILIAL>> " + ;
			          "AND NQ6_COD = NUQ_CCOMAR " + ;
                      "AND NQ6.D_E_L_E_T_ = ' ' " + ;
                 "LEFT JOIN <<SA2_COMPANY>> SA2 " + ; //Credenciado
                      "ON SA2.A2_FILIAL = <<ALIAS_SA2>><<SUBSTR_SA2_NUQ_FILIAL>> " + ;
                      "AND SA2.A2_COD = NUQ_CCORRE " + ;
                      "AND SA2.A2_LOJA = NUQ_LCORRE " + ;
                      "AND SA2.D_E_L_E_T_ = ' ' " + ;
                 "LEFT JOIN <<SA2_COMPANY>> A22 " + ; //Credenciado
                      "ON A22.A2_FILIAL = <<ALIAS_A22>><<SUBSTR_SA2_NSZ.NSZ_FILIAL>> " + ;
                      "AND A22.A2_COD = NSZ.NSZ_CCORRE " + ;
                      "AND A22.A2_LOJA = NSZ.NSZ_LCORRE " + ;
                      "AND A22.D_E_L_E_T_ = ' ' " + ;
                 "LEFT JOIN <<NRB_COMPANY>> NRB " + ; //Area Juridica
              	      "ON NRB_FILIAL = <<SUBSTR_NYB_NSZ.NSZ_FILIAL>> " + ;
              	      "AND NRB_COD = NSZ.NSZ_CAREAJ " + ;
              	      "AND NRB.D_E_L_E_T_ = ' ' " + ; 
                 "LEFT JOIN <<SA1_COMPANY>> SA1 " + ;//Cliente
                 	  "ON A1_FILIAL = <<SUBSTR_SA1_NSZ.NSZ_FILIAL>> " + ;
                 	  "AND A1_COD = NSZ.NSZ_CCLIEN " + ;
                 	  "AND A1_LOJA = NSZ.NSZ_LCLIEN " + ;
                 	  "AND SA1.D_E_L_E_T_ = ' ' " + ; 
                 "LEFT JOIN <<NQI_COMPANY>> NQI " + ;//Motivo Encerramento	 
                      "ON NQI_FILIAL = <<SUBSTR_NQI_NSZ.NSZ_FILIAL>> " + ;
                      "AND NQI_COD = NSZ.NSZ_CMOENC " + ; 
                      "AND NQI.D_E_L_E_T_ = ' ' " + ;    	           	        			  
	             "WHERE COALESCE(FECHADOS.NSZ_COD, ABERTOS.NSZ_COD, '-') <> '-' " + ;
	             	"AND NSZ.D_E_L_E_T_ = ' ' " + ;
					" <<AND_XFILIAL_NSZ_FILIAL>> "
					
Return cQuery
