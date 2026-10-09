#INCLUDE "BADEFINITION.CH"

NEW ENTITY PROCANDAMENTO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAProcAndamento
Visualiza as informações dos Processos em Andamento da área Juridica.

@author  Angelo Lee
@since   27/02/2018
/*/
//-------------------------------------------------------------------
Class BAProcAndamento from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  Angelo Lee
@since   27/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAProcAndamento
	_Super:Setup("ProcAndamento", FACT, "NSZ")
	
	//---------------------------------------------------------
	// Define que a extração da entidade será por mês
	//---------------------------------------------------------
	_Super:SetTpExtr( BYMONTH )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Angelo Lee
@since   27/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAProcAndamento
	Local cQuery := ""
	
	cQuery := "SELECT <<FINAL_DATE>> AS DATA, " + ;
				"<<KEY_COMPANY>> AS BK_EMPRESA, " + ;
		        "<<KEY_FILIAL_NSZ_FILIAL>> AS BK_FILIAL, " + ; 
				"<<KEY_NSZ_NSZ_FILIAL+NSZ_COD>> AS BK_PROCESSO_JUR, " + ;
		        "<<KEY_NYB_NYB_FILIAL+NSZ_TIPOAS>> AS BK_ASSUNTO_JURIDICO, " + ; 
                "<<KEY_NRB_NRB_FILIAL+NSZ_CAREAJ>> AS BK_AREA_JURIDICA, " + ;
		        "<<KEY_NQ6_NQ6_FILIAL+NUQ_CCOMAR>> AS BK_COMARCA, " + ; 
                "CASE WHEN (ISNULL(NUQ_CCORRE||NUQ_LCORRE, '')='') OR (RTRIM(NUQ_CCORRE||NUQ_LCORRE)='') " + ;
                  "THEN <<KEY_SA2_A22.A2_FILIAL+NSZ_CCORRE+NSZ_LCORRE>> " + ;
                  "ELSE <<KEY_SA2_SA2.A2_FILIAL+NUQ_CCORRE+NUQ_LCORRE>> " + ;
                "END AS BK_CREDENCIADO, " + ;
                "1 AS QTDE_PROCESSOS, " + ;
				" <<CODE_INSTANCE>> AS INSTANCIA " +;
              "FROM <<NSZ_COMPANY>> NSZ " + ;
              "INNER JOIN <<NUQ_COMPANY>> NUQ " + ;
                	"ON (NUQ_FILIAL = <<SUBSTR_NUQ_NSZ_FILIAL>> " + ;
		            "AND NUQ_CAJURI = NSZ_COD " + ;
		            "AND NUQ_INSATU = '1' " + ;
		            "AND NUQ.D_E_L_E_T_ = ' ' ) " + ;
              "LEFT JOIN <<NQ6_COMPANY>> NQ6 " + ;
                	"ON (NQ6_FILIAL = <<SUBSTR_NQ6_NSZ_FILIAL>> " + ;
                	"AND NQ6_COD = NUQ.NUQ_CCOMAR " + ;
                	"AND NQ6.D_E_L_E_T_ = ' ' ) " + ;
              "LEFT JOIN <<SA2_COMPANY>> SA2 " + ;
		            "ON (SA2.A2_FILIAL = <<ALIAS_SA2>><<SUBSTR_SA2_NUQ_FILIAL>> " + ;
		            "AND SA2.A2_COD = NUQ_CCORRE " + ;
                	"AND SA2.A2_LOJA = NUQ_LCORRE " + ;
                	"AND SA2.D_E_L_E_T_ = ' ' ) " + ;
              "LEFT JOIN <<SA2_COMPANY>> A22 " + ; 
		            "ON (A22.A2_FILIAL = <<ALIAS_A22>><<SUBSTR_SA2_NSZ_FILIAL>> " + ;
		            "AND A22.A2_COD = NSZ_CCORRE " + ;
                	"AND A22.A2_LOJA = NSZ_LCORRE " + ;
                	"AND A22.D_E_L_E_T_ = ' ' ) " + ;
              "LEFT JOIN <<NYB_COMPANY>> NYB " + ; 
		            "ON (NYB_FILIAL = <<SUBSTR_NYB_NSZ_FILIAL>> " + ;
		            "AND NYB_COD = NSZ_TIPOAS " + ;
		            "AND NYB.D_E_L_E_T_ = ' ' ) " + ;
              "LEFT JOIN <<NRB_COMPANY>> NRB " + ; 
		            "ON (NRB_FILIAL = <<SUBSTR_NRB_NSZ_FILIAL>> " + ;
		            "AND NRB_COD = NSZ_CAREAJ " + ;
		            "AND NRB.D_E_L_E_T_ = ' ' ) " + ;
              "WHERE(NSZ.NSZ_DTINCL <= <<FINAL_DATE>> AND (NSZ.NSZ_SITUAC = '1' OR NSZ.NSZ_DTENCE > <<FINAL_DATE>>)) " + ;    
              		"AND NSZ.D_E_L_E_T_ = ' ' " + ;
              		" <<AND_XFILIAL_NSZ_FILIAL>> "
					
Return cQuery
