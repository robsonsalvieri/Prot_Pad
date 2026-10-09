#INCLUDE "BADEFINITION.CH"

NEW ENTITY LANCCONTAB

//-------------------------------------------------------------------
/*/{Protheus.doc} BALancContab
Visualiza as informacoes dos Lancamentos Contabeis da area de Controladoria.

@author  henrique.cesar
@since   12/03/2018
/*/
//-------------------------------------------------------------------
Class BALancContab from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  henrique.cesar
@since   12/03/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BALancContab
	_Super:Setup("LancamentoContabil", FACT, "CT2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  henrique.cesar
@since   12/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BALancContab
	Local cQuery := ""
	
	cQuery :=   "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " + ;
					  	"<<KEY_FILIAL_CT2_FILIAL>> AS BK_FILIAL, " + ;
					  	"<<KEY_CT1_CT1_FILIAL+CT2_DEBITO>> AS BK_CONTA," + ;
					  	"<<KEY_FILIAL_CT2_FILORI>> AS BK_FILIAL_ORIGEM," + ;
					  	"<<KEY_CTD_CTD_FILIAL+CT2_ITEMD>> AS BK_ITEM_CONTABIL," + ;
					  	"<<KEY_CTT_CTT_FILIAL+CT2_CCD>> AS BK_CENTRO_CUSTO," + ;
					  	"<<KEY_CTH_CTH_FILIAL+CT2_CLVLDB>> AS BK_CLASSE_VALOR," + ;
					  	"CT2_DATA AS DATA," + ;
					  	"CT2_TPSALD AS TPSALD," + ;
					  	"CT2_DC AS DC," + ;
					  	"CT2_LOTE AS LOTE," + ;
					  	"CT2_SBLOTE AS SUBLOTE," + ;
					  	"CT2_DOC AS DOC," + ;
					  	"CT2_LINHA AS LINHA," + ;
					  	"CT2_CREDIT AS CONTA_PARTIDA," + ;
					  	"CT2_HIST AS HISTORICO," + ;
					  	"CT2_SEQHIS AS SEQUENCIA_HISTORICO," + ;
					  	"CT2_SEQLAN AS SEQUENCIA_AUXILIAR," + ;
					  	"<<FORMATVALUE(CT2_VALOR)>> AS VALOR_DEBITO," + ;
					  	"'0.00' AS VALOR_CREDITO," + ;
					  	"'1' AS TIPOLAN, " + ;	
						"CT2_DATATX AS DATA_TAXA," + ;
                        "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
                        "<<KEY_MOEDA_CT2_MOEDLC>> AS BK_MOEDA, " + ;
                        "COALESCE(CT2_TAXA,0) AS TAXA_MOEDA " + ;
				"FROM <<CT2_COMPANY>> CT2 " + ;
				"LEFT JOIN <<CT1_COMPANY>> CT1 " + ;// Conta Contabil
				    "ON CT1_CONTA = CT2_DEBITO " + ;
				    "AND CT1_FILIAL = <<SUBSTR_CT1_CT2_FILIAL>> " + ;
				    "AND CT1.D_E_L_E_T_ = ' '  " + ;
			    " LEFT JOIN <<CTD_COMPANY>> CTD " + ; // Item Contabil
			    	"ON CTD_FILIAL = <<SUBSTR_CTD_CT2_FILIAL>> AND " + ;
			    	" CTD_ITEM = CT2_ITEMD " + ;
			    	" AND CTD.D_E_L_E_T_ = ' ' " + ;
			    " LEFT JOIN <<CTT_COMPANY>> CTT " + ; // Centro de Custo
			    	"ON CTT_FILIAL = <<SUBSTR_CTT_CT2_FILIAL>> AND " + ;
			    	" CTT_CUSTO = CT2_CCD " + ;
			    	" AND CTT.D_E_L_E_T_ = ' ' " + ;
		    	" LEFT JOIN <<CTH_COMPANY>> CTH " + ; // Classe Valor
			    	"ON CTH_FILIAL = <<SUBSTR_CTH_CT2_FILIAL>> AND " + ;
			    	" CTH_CLVL = CT2_CLVLDB " + ;
			    	" AND CTH.D_E_L_E_T_ = ' ' " + ;
			    " WHERE CT2_DATA >= <<START_DATE>> " + ;
                   "AND CT2_DATA <= <<FINAL_DATE>> " + ;          
                   "AND (CT2_DC = '1' OR CT2_DC = '3') " + ;
                   "AND CT2_VALOR <> '0' " + ;
                   "AND CT2.D_E_L_E_T_ = ' '  " + ;
			    " <<AND_XFILIAL_CT2_FILIAL>> " + ;
				"UNION " + ; 
				"SELECT <<KEY_COMPANY>> AS BK_EMPRESA," + ; 
						"<<KEY_FILIAL_CT2_FILIAL>> AS BK_FILIAL," + ;
						"<<KEY_CT1_CT1_FILIAL+CT2_CREDIT>> AS BK_CONTA," + ;
						"<<KEY_FILIAL_CT2_FILORI>> AS BK_FILIAL_ORIGEM," + ;
					  	"<<KEY_CTD_CTD_FILIAL+CT2_ITEMC>> AS BK_ITEM_CONTABIL," + ;
					  	"<<KEY_CTT_CTT_FILIAL+CT2_CCC>> AS BK_CENTRO_CUSTO," + ;
					  	"<<KEY_CTH_CTH_FILIAL+CT2_CLVLCR>> AS BK_CLASSE_VALOR," + ;
					  	"CT2_DATA AS DATA," + ;
					  	"CT2_TPSALD AS TPSALD," + ;
					  	"CT2_DC AS DC," + ;
					  	"CT2_LOTE AS LOTE," + ;
					  	"CT2_SBLOTE AS SUBLOTE," + ;
					    "CT2_DOC AS DOC," + ;
					    "CT2_LINHA AS LINHA," + ;
					    "CT2_DEBITO AS CONTA_PARTIDA," + ;
					    "CT2_HIST AS HISTORICO," + ;
					    "CT2_SEQHIS AS SEQUENCIA_HISTORICO," + ;
					    "CT2_SEQLAN AS SEQUENCIA_AUXILIAR," + ;
					    "'0.00' AS VALOR_DEBITO," + ;
					    "<<FORMATVALUE(CT2_VALOR)>> AS VALOR_CREDITO," + ;
					    "'2' AS TIPOLAN, " + ;
                        "CT2_DATATX AS DATA_TAXA," + ;
                        "<<CODE_INSTANCE>> AS INSTANCIA, " + ;
                        "<<KEY_MOEDA_CT2_MOEDLC>> AS BK_MOEDA, " + ;
                        "COALESCE(CT2_TAXA,0) AS TAXA_MOEDA " + ;									    					    
				"FROM <<CT2_COMPANY>> CT2 " + ;
				"LEFT JOIN <<CT1_COMPANY>> CT1 " + ;//CONTA
					   "ON CT1_CONTA = CT2_CREDIT " + ;
					  "AND CT1_FILIAL = <<SUBSTR_CT1_CT2_FILIAL>> " + ;
					  "AND CT1.D_E_L_E_T_ = ' ' " + ;
			    " LEFT JOIN <<CTD_COMPANY>> CTD " + ; // Item Contabil
			    	"ON CTD_FILIAL = <<SUBSTR_CTD_CT2_FILIAL>> AND " + ;
			    	" CTD_ITEM = CT2_ITEMC " + ;
			    	" AND CTD.D_E_L_E_T_ = ' ' " + ;
			    " LEFT JOIN <<CTT_COMPANY>> CTT " + ; // Centro de Custo
			    	"ON CTT_FILIAL = <<SUBSTR_CTT_CT2_FILIAL>> AND " + ;
			    	" CTT_CUSTO = CT2_CCC " + ;
			    	" AND CTT.D_E_L_E_T_ = ' ' " + ;
		    	" LEFT JOIN <<CTH_COMPANY>> CTH " + ; // Classe Valor
			    	"ON CTH_FILIAL = <<SUBSTR_CTH_CT2_FILIAL>> AND " + ;
			    	" CTH_CLVL = CT2_CLVLCR " + ;
			    	" AND CTH.D_E_L_E_T_ = ' ' " + ;
                " WHERE CT2_DATA >= <<START_DATE>> " + ;
                   "AND CT2_DATA <= <<FINAL_DATE>> " + ; 
                   "AND (CT2_DC = '2' OR CT2_DC = '3') " + ;
                   "AND CT2_VALOR <> '0' " + ;
                   "AND CT2.D_E_L_E_T_ = ' ' " + ;
			    " <<AND_XFILIAL_CT2_FILIAL>> "
Return cQuery