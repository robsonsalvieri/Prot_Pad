#INCLUDE "BADEFINITION.CH"

NEW ENTITY  43PFMENT
            
//----------------------------------------------------------------------------------
/*{Protheus.doc } BAReceita
Visualiza a receita da Transportadora considerando os documentos emitidos pela mesma
Não são considerados os documentos de coleta e documentos de apoio.

@author Leandro Paulino
@since  23/11/2018     
/*/
//----------------------------------------------------------------------------------

Class TMSPerformanceEntrega from BAEntity
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
Method Setup() Class TMSPerformanceEntrega
    _Super:Setup("TMS Performance Entrega", FACT, "DT6")

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
Method BuildQuery() Class TMSPerformanceEntrega

    Local cQuery := ""

    //Receitas de Transporte

    cQuery +=   " SELECT    <<KEY_COMPANY>>                                 AS BK_EMPRESA       ,"
    cQuery +=   "           <<KEY_FILIAL_DT6_FILIAL>>                       AS BK_FILIAL        ,"
    cQuery +=   "           DT6_DATEMI                                      AS DATA_EMISSAO     , " 
    cQuery +=   "           <<KEY_SA1_REM.A1_FILIAL+DT6_CLIREM+DT6_LOJREM>> AS BK_REMETENTE     ," //Cliente Rementente
    cQuery +=   "           <<KEY_SA1_DES.A1_FILIAL+DT6_CLIDES+DT6_LOJDES>> AS BK_DESTINATARIO  ," //Cliente Destinatiario
    cQuery +=   "           <<KEY_SA1_DEV.A1_FILIAL+DT6_CLIDEV+DT6_LOJDEV>> AS BK_DEVEDOR       ," //Cliente Devedor
    cQuery +=   "           <<KEY_DUY_DUYORI.DUY_FILIAL+DT6_CDRORI>>        AS BK_CDRORI        ," //--Regiao de Origem
    cQuery +=   "           <<KEY_DUY_DUYDES.DUY_FILIAL+DT6_CDRDES>>        AS BK_CDRDES        ," //--Regiao de Destino        
    cQuery +=   "           <<KEY_DDB_DDB_FILIAL+DDB_CODNEG>>               AS BK_CODNEG        ," //--Codigo da Negociacao
    cQuery +=   "           <<KEY_SX5_SX5.X5_FILIAL+DT6_SERVIC>>            AS BK_SERNEG        ," //--Servico da Negociacao      
    cQuery +=   "           <<KEY_FILIAL_DT6_FILORI>>                       AS BK_FILIAL_ORIGEM ,"//--Filial de Origem
    cQuery +=   "           <<KEY_FILIAL_DT6_FILDES>>                       AS BK_FILIAL_DESTINO,"//--Filial de Destino
    cQuery +=   "           <<KEY_FILIAL_DT6_FILDOC>>                       AS BK_FILIAL_DOCTO  ,"//--Filial do documento
    
    //--DIMENSOES MANUAIS
    cQuery +=   "           <<KEY_###_DT6_DOCTMS>>                          AS BK_DOCTMS        ," //--Tipo de Documento    
    cQuery +=   "           <<KEY_###_DT6_TIPTRA>>                          AS BK_TIPTRA        ," //--Tipo de Transporte
    //--FIM 
    
    cQuery +=   "           DT6.DT6_DOC                                     AS DOCUMENTO        ,"
    cQuery +=   "           DT6.DT6_SERIE                                   AS SERIE            ,"
    cQuery +=   "           DT6.DT6_PRZENT                                  AS PRAZO_ENTREGA    ,"
    cQuery +=   "           DT6.DT6_DATENT                                  AS DATA_ENTREGA     ,"
    cQuery +=   "           CASE WHEN DT6.DT6_PRZENT < DT6.DT6_DATENT THEN 'FORA DO PRAZO' ELSE 'DENTRO DO PRAZO'                 END AS BK_STATUS    , "
    cQuery +=   "           CASE WHEN REM.A1_COD_MUN = ' ' THEN <<KEY_CC2_REM.A1_EST>> ELSE <<KEY_CC2_REM.A1_EST+REM.A1_COD_MUN>> END AS BK_REGIAO_REM, "
    cQuery +=   "           CASE WHEN DES.A1_COD_MUN = ' ' THEN <<KEY_CC2_DES.A1_EST>> ELSE <<KEY_CC2_DES.A1_EST+DES.A1_COD_MUN>> END AS BK_REGIAO_DES, "
    cQuery +=   "           CASE WHEN DEV.A1_COD_MUN = ' ' THEN <<KEY_CC2_DEV.A1_EST>> ELSE <<KEY_CC2_DEV.A1_EST+DEV.A1_COD_MUN>> END AS BK_REGIAO_DEV, "
    cQuery +=   "           CASE WHEN DUYDEV.DUY_CODMUN = ' ' THEN <<KEY_CC2_DUYDEV.DUY_EST>> ELSE <<KEY_CC2_DUYDEV.DUY_EST+DUYDEV.DUY_CODMUN>> END AS BK_REGIAO_CDRCAL, "
    cQuery +=   "           CASE WHEN DUYORI.DUY_CODMUN = ' ' THEN <<KEY_CC2_DUYORI.DUY_EST>> ELSE <<KEY_CC2_DUYORI.DUY_EST+DUYORI.DUY_CODMUN>> END AS BK_REGIAO_CDRORI, "
    cQuery +=   "			<<KEY_MOEDA_DT6_MOEDA>> AS BK_MOEDA, "
	cQuery +=   "			<<CODE_INSTANCE>>       AS INSTANCIA "
    
    cQuery +=   " FROM      <<DT6_COMPANY>> DT6                                                  " 
   
    //--CLIENTE REMETENTE
    cQuery +=   "   LEFT JOIN <<SA1_COMPANY>> REM                                                " 
    cQuery +=   "           ON  REM.A1_FILIAL       = <<SUBSTR_SA1_DT6_FILIAL>>                  " 
    cQuery +=   "           AND REM.A1_COD          = DT6.DT6_CLIREM                             " 
    cQuery +=   "           AND REM.A1_LOJA         = DT6.DT6_LOJREM                             " 
    cQuery +=   "           AND REM.D_E_L_E_T_	    = ' '                                        " 
   
    //--CLIENTE DESTINATARIO
    cQuery +=   "   LEFT JOIN <<SA1_COMPANY>> DES                                                " 
    cQuery +=   "           ON  DES.A1_FILIAL       = <<SUBSTR_SA1_DT6_FILIAL>>                  " 
    cQuery +=   "           AND DES.A1_COD          = DT6.DT6_CLIDES                             " 
    cQuery +=   "           AND DES.A1_LOJA		    = DT6.DT6_LOJDES                             " 
    cQuery +=   "           AND DES.D_E_L_E_T_	= ' '                                            " 
   
    //--CLIENTE DEVEDOR
    cQuery +=   "   LEFT JOIN <<SA1_COMPANY>> DEV                                                " 
    cQuery +=   "           ON  DEV.A1_FILIAL       = <<SUBSTR_SA1_DT6_FILIAL>>                  " 
    cQuery +=   "           AND	DEV.A1_COD		    = DT6.DT6_CLIDEV                             " 
    cQuery +=   "           AND DEV.A1_LOJA		    = DT6.DT6_LOJDEV                             " 
    cQuery +=   "           AND DEV.D_E_L_E_T_      = ' '                                        " 
    
    //--REGIAO DE ORIGEM
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYORI                                             "
    cQuery +=   "           ON  DUYORI.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYORI.DUY_GRPVEN      = DT6.DT6_CDRORI                          "
    cQuery +=   "           AND DUYORI.D_E_L_E_T_      = ' '                                     "
    
    //--REGIAO DE DESTINO
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYDES                                             "
    cQuery +=   "           ON  DUYDES.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYDES.DUY_GRPVEN      = DT6.DT6_CDRDES                          "
    cQuery +=   "           AND DUYDES.D_E_L_E_T_      = ' '                                     "

    //--REGIÃO DE CALCULO
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYDEV                                             "
    cQuery +=   "           ON  DUYDEV.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYDEV.DUY_GRPVEN      = DT6.DT6_CDRCAL                          "
    cQuery +=   "           AND DUYDEV.D_E_L_E_T_      = ' '                                     "
    
    //--CODIGO DA NEGOCIACAO
    cQuery +=   "   LEFT JOIN <<DDB_COMPANY>> DDB                                                "
    cQuery +=   "           ON  DDB.DDB_FILIAL          = <<SUBSTR_DDB_DT6_FILIAL>>              "
    cQuery +=   "           AND DDB.DDB_CODNEG          = DT6.DT6_CODNEG                         "    
    cQuery +=   "           AND DDB.D_E_L_E_T_          = ' '                                    "
    
    //--SERVICO DA NEGOCIACAO
    cQuery +=   "   INNER JOIN <<SX5_COMPANY>> SX5                                               "
    cQuery +=   "           ON  SX5.X5_FILIAL           = <<SUBSTR_SX5_DT6_FILIAL>>              "
    cQuery +=   "           AND SX5.X5_TABELA           = 'L4'                                   "
    cQuery +=   "           AND SX5.X5_CHAVE            = DT6.DT6_SERVIC                         "  
    cQuery +=   "           AND SX5.D_E_L_E_T_          = ' '                                    "
    
        
    cQuery +=   "   WHERE DT6.DT6_DATEMI BETWEEN <<START_DATE>> AND <<FINAL_DATE>>               " 
    cQuery +=   "           AND DT6.D_E_L_E_T_ = ' '                                             "
    cQuery +=   "           AND DT6.DT6_DATENT <> ' '                                            "
    cQuery +=   "           AND DT6.DT6_SERIE       <> 'COL'                                     " 
    cQuery +=   "           AND DT6.DT6_SERIE       <> 'PED'                                     " 
    cQuery +=   "   <<AND_XFILIAL_DT6_FILIAL>>       


Return cQuery
