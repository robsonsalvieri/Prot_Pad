#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43Ociosi

//----------------------------------------------------------------------------------
/*{Protheus.doc } BAReceita
Visualiza a receita da Transportadora considerando os documentos emitidos pela mesma
Não são considerados os documentos de coleta e documentos de apoio.

@author Leandro Paulino
@since  23/11/2018     
/*/
//----------------------------------------------------------------------------------

Class TMSOciosidadeVeiculo from BAEntity
    Method Setup() CONSTRUCTOR  
    Method BuildQuery() 
EndClass


//----------------------------------------------------------------------------------
/*{Protheus.doc } Setup
Construtor Padrão


@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method Setup() Class TMSOciosidadeVeiculo
    _Super:Setup("TMS Ociosidade Veiculo", FACT, "DTW")

    //-----------------------------------------------------------
    //Define que a extração da entidade será feita por um período
    //------------------------------------------------------------
    
Return

//----------------------------------------------------------------------------------
/*{Protheus.doc} BuildQuery
Contrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa

@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method BuildQuery() Class TMSOciosidadeVeiculo


    Local cQuery    := ""
    Local cAtivisai := SuperGetMv("MV_ATIVSAI",,'')
    Local cAtiviChg := SuperGetMv("MV_ATIVCHG",,'')
                       
    //Receitas de Transporte
    cQuery +=   " SELECT  DISTINCT <<KEY_COMPANY>>                              AS BK_EMPRESA           ,"
    cQuery +=   "           <<KEY_FILIAL_DTW_FILIAL>>                           AS BK_FILIAL            ,"
    //cQuery +=   "           <<KEY_DA3_DA3_FILIAL+DA3_COD>>                    AS BK_CODIGO_VEICULO    ,"    
    cQuery +=   "           DTW.DTW_FILORI                                      AS FILIAL_ORIGEM        ,"//--Filial de Origem
    cQuery +=   "           DTW.DTW_VIAGEM                                      AS NUMERO_VIAGEM        ,"//--Hora do Registro de Indenização 
    cQuery +=   "           <<KEY_DA3_DA3CAVALO.DA3_FILIAL+DTR.DTR_CODVEI>>   AS CODIGO_CAVALO        ,"//--Codigo Veiculo
    cQuery +=   "           <<KEY_DA3_DA3REBOQUE1.DA3_FILIAL+DTR.DTR_CODRB1>> AS CODIGO_REBOQUE1      ,"//--Codigo Reboque 1
    cQuery +=   "           <<KEY_DA3_DA3REBOQUE2.DA3_FILIAL+DTR.DTR_CODRB2>> AS CODIGO_REBOQUE2      ,"//--Codigo Reboque 2
    cQuery +=   "           <<KEY_DA3_DA3REBOQUE3.DA3_FILIAL+DTR.DTR_CODRB3>> AS CODIGO_REBOQUE3      ,"//--Codigo Reboque 3
    
    
    cQuery +=   " ( SELECT TOP(1)   CASE WHEN DTW_DATREA = ' ' THEN ' ' ELSE CONCAT( CONVERT( DATE , DTW_DATREA ) , ' ' , DTW_HORREA ) END         "
    cQuery +=   "       FROM <<DTW_COMPANY>> DTWH                                                    "
	cQuery +=   "           WHERE DTW_FILORI = DTW.DTW_FILORI                                        "
    cQuery +=   "               AND DTW_VIAGEM   = DTW.DTW_VIAGEM                                    "
	cQuery +=   "               AND DTW_ATIVID = '" + cAtivisai + "'                                 "
	cQuery +=   "               AND DTW_CODCLI = ''                                                  "
	cQuery +=   "               AND DTW_LOJCLI = ''                                                  "
	cQuery +=   "               AND DTWH.D_E_L_E_T_ = ''  ) AS 'DATAHORASAIDA' ,                     "
	
	cQuery +=   " ( SELECT TOP(1)   CASE WHEN DTW_DATREA = ' ' THEN ' ' ELSE CONCAT( CONVERT( DATE , DTW_DATREA ) , ' ' , DTW_HORREA )  END         "
	cQuery +=   "       FROM <<DTW_COMPANY>> DTWH                                                    "
	cQuery +=   "           WHERE DTW_FILORI = DTW.DTW_FILORI                                        "
    cQuery +=   "               AND DTW_VIAGEM   = DTW.DTW_VIAGEM                                    "
	cQuery +=   "               AND DTW_ATIVID = '" + cAtiviChg + "'                                 "
	cQuery +=   "               AND DTW_CODCLI = ''                                                  "
	cQuery +=   "               AND DTW_LOJCLI = ''                                                  "
	cQuery +=   "               AND DTWH.D_E_L_E_T_ = ''  ) AS 'DATAHORACHEGADA' ,                   "

    cQuery +=   "			<<CODE_INSTANCE>>	AS INSTANCIA "

    cQuery +=   "   FROM    <<DTW_COMPANY>> DTW                                                      "

    cQuery +=   "   INNER JOIN <<DTR_COMPANY>> DTR                                                   "
    cQuery +=   "       ON  DTR.DTR_FILIAL  = <<SUBSTR_DTR_DTW_FILIAL>>                              " 
    cQuery +=   "       AND DTR.DTR_FILORI  = DTW.DTW_FILORI                                         "
    cQuery +=   "       AND DTR.DTR_VIAGEM  = DTW.DTW_VIAGEM                                         "
    cQuery +=   "       AND DTR.D_E_L_E_T_  = ' '                                                    "

    cQuery +=   "   INNER JOIN <<DA3_COMPANY>> DA3CAVALO                                             "
    cQuery +=   "       ON  DA3CAVALO.DA3_FILIAL  = <<SUBSTR_DA3_DTR_FILIAL>>                        " 
    cQuery +=   "       AND DA3CAVALO.DA3_COD     = DTR.DTR_CODVEI                                   "    
    cQuery +=   "       AND DA3CAVALO.D_E_L_E_T_ = ' '                                               "

    cQuery +=   "   LEFT JOIN <<DA3_COMPANY>> DA3REBOQUE1                                            "
    cQuery +=   "       ON  DA3REBOQUE1.DA3_FILIAL  = <<SUBSTR_DA3_DTR_FILIAL>>                      " 
    cQuery +=   "       AND DA3REBOQUE1.DA3_COD     = DTR.DTR_CODRB1                                 "    
    cQuery +=   "       AND DA3REBOQUE1.D_E_L_E_T_ = ' '                                             "

    cQuery +=   "   LEFT JOIN <<DA3_COMPANY>> DA3REBOQUE2                                           "
    cQuery +=   "       ON  DA3REBOQUE2.DA3_FILIAL  = <<SUBSTR_DA3_DTW_FILIAL>>                     " 
    cQuery +=   "       AND DA3REBOQUE2.DA3_COD     = DTR.DTR_CODRB2                                "    
    cQuery +=   "       AND DA3REBOQUE2.D_E_L_E_T_ = ' '                                            "

    cQuery +=   "   LEFT JOIN <<DA3_COMPANY>> DA3REBOQUE3                                          "
    cQuery +=   "       ON  DA3REBOQUE3.DA3_FILIAL  = <<SUBSTR_DA3_DTW_FILIAL>>                     " 
    cQuery +=   "       AND DA3REBOQUE3.DA3_COD     = DTR.DTR_CODRB3                                "    
    cQuery +=   "       AND DA3REBOQUE3.D_E_L_E_T_ = ' '                                            "

    cQuery +=   "   WHERE DTW_DATREA BETWEEN <<START_DATE>> AND <<FINAL_DATE>>                       " 
    cQuery +=   "           AND DTW.DTW_CODCLI = ''                                                  "
    cQuery +=   "           AND DTW.DTW_LOJCLI = ''                                                  " 
    cQuery +=   "           AND DTW.DTW_ATIVID IN ('" + cAtiviChg+ "','" + cAtivisai + "' )          " 
    cQuery +=   "           AND DTW.D_E_L_E_T_ = ''	                                                 "
    cQuery +=   "   <<AND_XFILIAL_DTW_FILIAL>>                                                       "
	
Return cQuery
