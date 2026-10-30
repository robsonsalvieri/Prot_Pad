#INCLUDE "BADEFINITION.CH"

NEW ENTITY CONTABI

//-------------------------------------------------------------------
/*/{Protheus.doc} BAContab
A tabela fato Contabilidade apresenta informacoes das contas
contabeis relacionadas a contabilidade realizada.

@author  Helio Leal
@since   12/03/2018
/*/
//-------------------------------------------------------------------
Class BAContab from BAEntity
    Method Setup( ) CONSTRUCTOR
    Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Helio Leal
@since   12/03/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAContab
    _Super:Setup("Contabilidade", FACT, "CQ1")
    
    //---------------------------------------------------------
	// Define que a extracao da entidade sera por mes
	//---------------------------------------------------------
	_Super:SetTpExtr( BYMONTH )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Helio Leal
@since   12/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAContab
    Local cQuery := ""
    
    cQuery := "SELECT BK_EMPRESA, BK_FILIAL, BK_CONTA, NORMAL, CTARES, TIPOCONTA, GRUPO, NATCTA, CT1DTEXSF, DESCCTA, DATA, " + ;
              " <<FORMATVALUE(SALDOANTDB,16,2)>> AS SALDOANTDB," +;
              " <<FORMATVALUE(SALDOANTCR,16,2)>> AS SALDOANTCR," +;
              " <<FORMATVALUE(SALDODEB,16,2)>> AS SALDODEB," +;
              " <<FORMATVALUE(SALDOCRD,16,2)>> AS SALDOCRD, " +;
			  " <<CODE_INSTANCE>> AS INSTANCIA, " +;
			  " <<KEY_MOEDA_COD_MOEDA>> AS BK_MOEDA, " +;
			  " 0 AS TAXA_MOEDA " +;
              " FROM (" + ;
              " SELECT DISTINCT <<KEY_COMPANY>> AS BK_EMPRESA" + ; 
                               ",<<KEY_FILIAL_CQ1_FILIAL>> AS BK_FILIAL" + ;
		                       ",<<KEY_CT1_CT1_FILIAL+CQ1_CONTA>> AS BK_CONTA" + ;
		                       ",CT1_NORMAL AS NORMAL" + ;
		                       ",CT1_RES AS CTARES" + ;
		                       ",CT1_CLASSE AS TIPOCONTA" + ;
		                       ",CT1_GRUPO AS GRUPO" + ;
		                       ",CT1_NATCTA AS NATCTA" + ;
		                       ",CT1_DTEXSF AS CT1DTEXSF" + ;
		                       ",CT1_DESC01 AS DESCCTA" + ;
		                       ",<<FINAL_DATE>> AS DATA" + ;
		                       ",(SELECT CASE" + ; 
							           " WHEN SUM(CQ1_DEBITO) IS NULL THEN 0" + ;
							           " ELSE SUM(CQ1_DEBITO)" + ;
							           " END AS SALDOANTDB" + ;
		                       " FROM <<CQ1_COMPANY>> CQ11" + ;
		                      " WHERE CQ11.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
			                    " AND CQ11.CQ1_TPSALD = '1'" + ;
			                    " AND CQ11.CQ1_DATA < <<START_DATE>>" + ;
			                    " AND CQ11.D_E_L_E_T_ = ' '" + ;
			                    " AND CQ11.CQ1_FILIAL = CQ1.CQ1_FILIAL" +;
			                    " AND CQ11.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOANTDB" + ;
		                        ",(SELECT CASE" + ; 
					                     " WHEN SUM(CQ1_CREDIT) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_CREDIT)" + ;
					                     " END AS SALDOANTCR" + ;
			                      " FROM <<CQ1_COMPANY>> CQ12" + ;
			                     " WHERE CQ12.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ12.CQ1_TPSALD = '1'" + ;
				                   " AND CQ12.CQ1_DATA < <<START_DATE>>" + ;
				                   " AND CQ12.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ12.CQ1_FILIAL = CQ1.CQ1_FILIAL" + ;
				                   " AND CQ12.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOANTCR" + ;
		                       ",(SELECT CASE" + ; 
					                     " WHEN SUM(CQ1_DEBITO) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_DEBITO)" + ;
					                     " END AS SALDODEB" + ;
			                      " FROM <<CQ1_COMPANY>> CQ13" + ; 
			                     " WHERE CQ13.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ13.CQ1_TPSALD = '1'" + ;
				                   " AND CQ13.CQ1_DATA >= <<START_DATE>>" + ;
				                   " AND CQ13.CQ1_DATA <= <<FINAL_DATE>>" + ;
				                   " AND CQ13.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ13.CQ1_FILIAL = CQ1.CQ1_FILIAL" + ;
				                   " AND CQ13.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDODEB" + ;
		                       ",(SELECT CASE" + ;
					                     " WHEN SUM(CQ1_CREDIT) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_CREDIT)" + ;
					                     " END AS SALDOCRD" + ;
			                      " FROM <<CQ1_COMPANY>> CQ14" + ;
			                     " WHERE CQ14.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ14.CQ1_TPSALD = '1'" + ;
				                   " AND CQ14.CQ1_DATA >= <<START_DATE>>" + ;
				                   " AND CQ14.CQ1_DATA <= <<FINAL_DATE>>" + ;
				                   " AND CQ14.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ14.CQ1_FILIAL = CQ1.CQ1_FILIAL" +; 
				                   " AND CQ14.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOCRD " + ;
								",CQ1.CQ1_MOEDA AS COD_MOEDA" +;   
	             " FROM <<CQ1_COMPANY>> CQ1" + ;
	            " INNER JOIN <<CT1_COMPANY>> CT1" + ;
	               " ON CT1_FILIAL = <<SUBSTR_CT1_CQ1_FILIAL>>" + ;
		          " AND CT1_CONTA = CQ1_CONTA" + ;
		          " AND CT1.D_E_L_E_T_ = ' '" + ;
	            " WHERE CQ1.D_E_L_E_T_ = ' '" + ;
	            " <<AND_XFILIAL_CQ1_FILIAL>>) SALDOARQ" + ;
        " WHERE (SALDOANTDB - SALDOANTCR <> 0 OR SALDODEB <> 0 OR SALDOCRD <> 0)"

Return cQuery