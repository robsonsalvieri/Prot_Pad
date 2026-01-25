#INCLUDE "BADEFINITION.CH"

NEW ENTITY ORCADO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAOrcado
TIPO DE SALDO
A tabela fato Orcado apresenta informacoes dos tipo de saldos
contabeis relacionadas ao lancamento contabil.

@author  Totvs
@since   12/02/2019
/*/
//-------------------------------------------------------------------
Class BAOrcado from BAEntity
    Method Setup( ) CONSTRUCTOR
    Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Totvs
@since   12/02/2019
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAOrcado
    _Super:Setup("Orcado", FACT, "CQ1")
    
    //---------------------------------------------------------
	// Define que a extracao da entidade sera por mes
	//---------------------------------------------------------
	_Super:SetTpExtr( BYMONTH )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Totvs
@since   12/02/2019
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAOrcado
    Local cQuery := ""
    
    cQuery := "SELECT *" + ;
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
		                       ",(SELECT CASE" + ; // TIPO DE SALDO REAL
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
				                   " AND CQ14.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOCRD" + ;
				               ",(SELECT CASE" + ; // TIPO DE SALDO PREVISTO
					                     " WHEN SUM(CQ1_DEBITO) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_DEBITO)" + ;
					                     " END AS SALDOANTDB" + ;
			                      " FROM <<CQ1_COMPANY>> CQ15" + ;
			                     " WHERE CQ15.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ15.CQ1_TPSALD = '2'" + ;
				                   " AND CQ15.CQ1_DATA < <<START_DATE>>" + ;
				                   " AND CQ15.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ15.CQ1_FILIAL = CQ1.CQ1_FILIAL" +;
				                   " AND CQ15.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOANTDBP" + ;
		                       ",(SELECT CASE" + ; 
					                     " WHEN SUM(CQ1_CREDIT) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_CREDIT)" + ;
					                     " END AS SALDOANTCR" + ;
			                      " FROM <<CQ1_COMPANY>> CQ16" + ;
			                     " WHERE CQ16.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ16.CQ1_TPSALD = '2'" + ;
				                   " AND CQ16.CQ1_DATA < <<START_DATE>>" + ;
				                   " AND CQ16.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ16.CQ1_FILIAL = CQ1.CQ1_FILIAL" + ;
				                   " AND CQ16.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOANTCRP" + ;
		                       ",(SELECT CASE" + ; 
					                     " WHEN SUM(CQ1_DEBITO) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_DEBITO)" + ;
					                     " END AS SALDODEB" + ;
			                      " FROM <<CQ1_COMPANY>> CQ17" + ; 
			                     " WHERE CQ17.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ17.CQ1_TPSALD = '2'" + ;
				                   " AND CQ17.CQ1_DATA >= <<START_DATE>>" + ;
				                   " AND CQ17.CQ1_DATA <= <<FINAL_DATE>>" + ;
				                   " AND CQ17.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ17.CQ1_FILIAL = CQ1.CQ1_FILIAL" + ;
				                   " AND CQ17.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDODEBP" + ;
		                       ",(SELECT CASE" + ;
					                     " WHEN SUM(CQ1_CREDIT) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_CREDIT)" + ;
					                     " END AS SALDOCRD" + ;
			                      " FROM <<CQ1_COMPANY>> CQ18" + ;
			                     " WHERE CQ18.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ18.CQ1_TPSALD = '2'" + ;
				                   " AND CQ18.CQ1_DATA >= <<START_DATE>>" + ;
				                   " AND CQ18.CQ1_DATA <= <<FINAL_DATE>>" + ;
				                   " AND CQ18.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ18.CQ1_FILIAL = CQ1.CQ1_FILIAL" +; 
				                   " AND CQ18.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOCRDP" + ;
				               ",(SELECT CASE" + ; // TIPO DE SALDO EMPENHADO
					                     " WHEN SUM(CQ1_DEBITO) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_DEBITO)" + ;
					                     " END AS SALDOANTDB" + ;
			                      " FROM <<CQ1_COMPANY>> CQ19" + ;
			                     " WHERE CQ19.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ19.CQ1_TPSALD = '4'" + ;
				                   " AND CQ19.CQ1_DATA < <<START_DATE>>" + ;
				                   " AND CQ19.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ19.CQ1_FILIAL = CQ1.CQ1_FILIAL" +;
				                   " AND CQ19.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOANTDBE" + ;
		                       ",(SELECT CASE" + ; 
					                     " WHEN SUM(CQ1_CREDIT) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_CREDIT)" + ;
					                     " END AS SALDOANTCR" + ;
			                      " FROM <<CQ1_COMPANY>> CQ110" + ;
			                     " WHERE CQ110.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ110.CQ1_TPSALD = '4'" + ;
				                   " AND CQ110.CQ1_DATA < <<START_DATE>>" + ;
				                   " AND CQ110.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ110.CQ1_FILIAL = CQ1.CQ1_FILIAL" + ;
				                   " AND CQ110.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOANTCRE" + ;
		                       ",(SELECT CASE" + ; 
					                     " WHEN SUM(CQ1_DEBITO) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_DEBITO)" + ;
					                     " END AS SALDODEB" + ;
			                      " FROM <<CQ1_COMPANY>> CQ111" + ; 
			                     " WHERE CQ111.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ111.CQ1_TPSALD = '4'" + ;
				                   " AND CQ111.CQ1_DATA >= <<START_DATE>>" + ;
				                   " AND CQ111.CQ1_DATA <= <<FINAL_DATE>>" + ;
				                   " AND CQ111.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ111.CQ1_FILIAL = CQ1.CQ1_FILIAL" + ;
				                   " AND CQ111.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDODEBE" + ;
		                       ",(SELECT CASE" + ;
					                     " WHEN SUM(CQ1_CREDIT) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_CREDIT)" + ;
					                     " END AS SALDOCRD" + ;
			                      " FROM <<CQ1_COMPANY>> CQ112" + ;
			                     " WHERE CQ112.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ112.CQ1_TPSALD = '4'" + ;
				                   " AND CQ112.CQ1_DATA >= <<START_DATE>>" + ;
				                   " AND CQ112.CQ1_DATA <= <<FINAL_DATE>>" + ;
				                   " AND CQ112.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ112.CQ1_FILIAL = CQ1.CQ1_FILIAL" +; 
				                   " AND CQ112.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOCRDE" + ;
				               ",(SELECT CASE" + ; // TIPO DE SALDO ORCADO
					                     " WHEN SUM(CQ1_DEBITO) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_DEBITO)" + ;
					                     " END AS SALDOANTDB" + ;
			                      " FROM <<CQ1_COMPANY>> CQ113" + ;
			                     " WHERE CQ113.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ113.CQ1_TPSALD = '0'" + ;
				                   " AND CQ113.CQ1_DATA < <<START_DATE>>" + ;
				                   " AND CQ113.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ113.CQ1_FILIAL = CQ1.CQ1_FILIAL" +;
				                   " AND CQ113.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOANTDBO" + ;
		                       ",(SELECT CASE" + ; 
					                     " WHEN SUM(CQ1_CREDIT) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_CREDIT)" + ;
					                     " END AS SALDOANTCR" + ;
			                      " FROM <<CQ1_COMPANY>> CQ114" + ;
			                     " WHERE CQ114.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ114.CQ1_TPSALD = '0'" + ;
				                   " AND CQ114.CQ1_DATA < <<START_DATE>>" + ;
				                   " AND CQ114.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ114.CQ1_FILIAL = CQ1.CQ1_FILIAL" + ;
				                   " AND CQ114.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOANTCRO" + ;
		                       ",(SELECT CASE" + ; 
					                     " WHEN SUM(CQ1_DEBITO) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_DEBITO)" + ;
					                     " END AS SALDODEB" + ;
			                      " FROM <<CQ1_COMPANY>> CQ115" + ; 
			                     " WHERE CQ115.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ115.CQ1_TPSALD = '0'" + ;
				                   " AND CQ115.CQ1_DATA >= <<START_DATE>>" + ;
				                   " AND CQ115.CQ1_DATA <= <<FINAL_DATE>>" + ;
				                   " AND CQ115.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ115.CQ1_FILIAL = CQ1.CQ1_FILIAL" + ;
				                   " AND CQ115.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDODEBO" + ;
		                       ",(SELECT CASE" + ;
					                     " WHEN SUM(CQ1_CREDIT) IS NULL THEN 0" + ;
					                     " ELSE SUM(CQ1_CREDIT)" + ;
					                     " END AS SALDOCRD" + ;
			                      " FROM <<CQ1_COMPANY>> CQ116" + ;
			                     " WHERE CQ116.CQ1_CONTA = CQ1.CQ1_CONTA" + ;
				                   " AND CQ116.CQ1_TPSALD = '0'" + ;
				                   " AND CQ116.CQ1_DATA >= <<START_DATE>>" + ;
				                   " AND CQ116.CQ1_DATA <= <<FINAL_DATE>>" + ;
				                   " AND CQ116.D_E_L_E_T_ = ' '" + ;
				                   " AND CQ116.CQ1_FILIAL = CQ1.CQ1_FILIAL" +; 
				                   " AND CQ116.CQ1_MOEDA = CQ1.CQ1_MOEDA) AS SALDOCRDO" + ;
								",<<CODE_INSTANCE>> AS INSTANCIA " +;
                                ",<<KEY_MOEDA_CQ1.CQ1_MOEDA>> AS BK_MOEDA " +;
                                ",0 AS TAXA_MOEDA " +;   
	             " FROM <<CQ1_COMPANY>> CQ1" + ;
	            " INNER JOIN <<CT1_COMPANY>> CT1" + ;
	               " ON CT1_FILIAL = <<SUBSTR_CT1_CQ1_FILIAL>>" + ;
		          " AND CT1_CONTA = CQ1_CONTA" + ;
		          " AND CT1.D_E_L_E_T_ = ' '" + ;
	            " WHERE CQ1.D_E_L_E_T_ = ' '" + ;
	            " <<AND_XFILIAL_CQ1_FILIAL>>) SALDOARQ" + ;
        " WHERE (SALDOANTDB - SALDOANTCR <> 0 OR SALDODEB <> 0 OR SALDOCRD <> 0)" + ;
        	"OR (SALDOANTDBO - SALDOANTCRO <> 0 OR SALDODEBO <> 0 OR SALDOCRDO <> 0)" + ;
        	"OR (SALDOANTDBE - SALDOANTCRE <> 0 OR SALDODEBE <> 0 OR SALDOCRDE <> 0)" + ;
        	"OR (SALDOANTDBP - SALDOANTCRP <> 0 OR SALDODEBP <> 0 OR SALDOCRDP <> 0)"
        	
Return cQuery