#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43OcoTpt

//----------------------------------------------------------------------------------
/*{Protheus.doc } TMSOCORRENCIASTRANSPORTE
Apresenta as ocorrencias apontadas no SIGATMS.

@author Leandro Paulino
@since  23/11/2018     
/*/
//----------------------------------------------------------------------------------

Class TMSOCORRENCIASTRANSPORTE from BAEntity
    Method Setup() CONSTRUCTOR  
    Method BuildQuery() 
EndClass


//----------------------------------------------------------------------------------
/*{Protheus.doc } Setup
Construtor Padrao
@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method Setup() Class TMSOCORRENCIASTRANSPORTE
    _Super:Setup("TMS Ocorrencias Transporte", FACT, "DT8")

    //-----------------------------------------------------------
    //Define que a extracao da entidade, sera feita por um periodo
    //------------------------------------------------------------
        
Return

//----------------------------------------------------------------------------------
/*{Protheus.doc} BuildQuery
Contr�i a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa

@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method BuildQuery() Class TMSOcorrenciasTransporte

    Local cQuery := ""

    //Ocorrencias de Transporte

    cQuery +=   " SELECT    <<KEY_COMPANY>>                                 AS BK_EMPRESA           ,"
    cQuery +=   "           <<KEY_FILIAL_DUA_FILIAL>>                       AS BK_FILIAL            ,"
    cQuery +=   "           DUA_DATOCO                                      AS DATA_OCORRENCIA      ,"     
    cQuery +=   "           DUA_HOROCO                                      AS HORA_OCORRENCIA      ,"
    cQuery +=   "           <<KEY_FILIAL_DUA_FILOCO>>                       AS FILIAL_OCORRENCIA    ,"
    cQuery +=   "           DUA_NUMOCO                                      AS NUMERO_OCORRENCIA    ,"
    cQuery +=   "           DUA_VIAGEM                                      AS NUMERO_VIAGEM        ," 
    cQuery +=   "           DUA_SEQOCO                                      AS SEQUENCIA_OCORRENCIA ," 
    cQuery +=   "           DUA_CODOCO                                      AS CODIGO_OCORRENCA     ,"     
    cQuery +=   "           <<KEY_DT2_DT2.DT2_FILIAL+DT2_TIPOCO>>           AS TIPO_OCORRENCA       ,"     
    
    cQuery +=   "           <<KEY_SA1_REM.A1_FILIAL+DT6_CLIREM+DT6_LOJREM>> AS BK_REMETENTE         ," //Cliente Rementente
    cQuery +=   "           <<KEY_SA1_DES.A1_FILIAL+DT6_CLIDES+DT6_LOJDES>> AS BK_DESTINATARIO      ," //Cliente Destinat�rio
    cQuery +=   "           <<KEY_SA1_DEV.A1_FILIAL+DT6_CLIDEV+DT6_LOJDEV>> AS BK_DEVEDOR           ," //Cliente Devedor

    cQuery +=   "           <<KEY_DUY_DUYORI.DUY_FILIAL+DT6_CDRORI>>        AS BK_CDRORI            ," //--Regi�o de Origem
    cQuery +=   "           <<KEY_DUY_DUYDES.DUY_FILIAL+DT6_CDRDES>>        AS BK_CDRDES            ," //--Regi�o de Destino    
    cQuery +=   "           <<KEY_DDB_DDB_FILIAL+DDB_CODNEG>>               AS BK_CODNEG            ," //--C�digo da Negocia��o
    cQuery +=   "           <<KEY_SX5_SX5.X5_FILIAL+DT6_SERVIC>>            AS BK_SERNEG            ," //--Servi�o da Negocia��o    
    cQuery +=   "           <<KEY_FILIAL_DT6_FILORI>>                       AS BK_FILIAL_ORIGEM     ,"//--Filial de Origem
    cQuery +=   "           <<KEY_FILIAL_DT6_FILDES>>                       AS BK_FILIAL_DESTINO    ,"//--Filial de Destino

    //--DIMENSOES MANUAIS   
    cQuery +=   "           <<KEY_###_DT6_DOCTMS>>                          AS BK_DOCTMS            ," //--Tipo de Documento    
    cQuery +=   "           <<KEY_###_DT6_TIPTRA>>                          AS BK_TIPTRA            ," //--Tipo de Transporte
    cQuery +=   "           <<KEY_###_DT6_SERTMS>>                          AS BK_SERTMS            ," //--Serviço TMS
    //--FIM 
    
    cQuery +=   "           CASE WHEN REM.A1_COD_MUN    = ' ' THEN <<KEY_CC2_REM.A1_EST>> ELSE <<KEY_CC2_REM.A1_EST+REM.A1_COD_MUN>> END AS BK_REGIAO_REM, "
    cQuery +=   "           CASE WHEN DES.A1_COD_MUN    = ' ' THEN <<KEY_CC2_DES.A1_EST>> ELSE <<KEY_CC2_DES.A1_EST+DES.A1_COD_MUN>> END AS BK_REGIAO_DES, "
    cQuery +=   "           CASE WHEN DEV.A1_COD_MUN    = ' ' THEN <<KEY_CC2_DEV.A1_EST>> ELSE <<KEY_CC2_DEV.A1_EST+DEV.A1_COD_MUN>> END AS BK_REGIAO_DEV, "
    cQuery +=   "           CASE WHEN DUYCAL.DUY_CODMUN = ' ' THEN <<KEY_CC2_DUYCAL.DUY_EST>> ELSE <<KEY_CC2_DUYCAL.DUY_EST+DUYCAL.DUY_CODMUN>> END AS BK_REGIAO_CDRCAL, "
    cQuery +=   "           CASE WHEN DUYORI.DUY_CODMUN = ' ' THEN <<KEY_CC2_DUYORI.DUY_EST>> ELSE <<KEY_CC2_DUYORI.DUY_EST+DUYORI.DUY_CODMUN>> END AS BK_REGIAO_CDRORI, "
          
    cQuery +=   "           DUA_FILDOC                                      AS FILIAL_DOCUMENTO ," 
    cQuery +=   "           DUA_DOC                                         AS DOCUMENTO        ," 
    cQuery +=   "           DUA_SERIE                                       AS SERIE,"
    cQuery +=   "			<<CODE_INSTANCE>>       AS INSTANCIA, "
    cQuery +=   "			<<KEY_MOEDA_DT6_MOEDA>> AS BK_MOEDA "

    cQuery +=   " FROM      <<DUA_COMPANY>> DUA                                                  "
   
    //--TIPOS DE OCORRENCIA - DT2

    cQuery +=   "   INNER JOIN <<DT2_COMPANY>>   DT2                                             "
    cQuery +=   "           ON  DT2.DT2_FILIAL       = <<SUBSTR_DT2_DUA_FILIAL>>                     "
    cQuery +=   "           AND DT2.DT2_CODOCO       = DUA.DUA_CODOCO                            "
    cQuery +=   "           AND DT2.D_E_L_E_T_       = ' '                                       "
    
    //DOCUMENTOS DE TRANSPORTE - DT6        
    cQuery +=   "   LEFT JOIN <<DT6_COMPANY>> DT6                                                " 
    cQuery +=   "           ON  DUA.DUA_FILIAL      = <<SUBSTR_DT6_DUA_FILIAL>>                  " 
    cQuery +=   "           AND DUA.DUA_FILDOC      = DT6.DT6_FILDOC                             " 
    cQuery +=   "           AND DUA.DUA_DOC         = DT6.DT6_DOC                                " 
    cQuery +=   "           AND DUA.DUA_SERIE       = DT6.DT6_SERIE                              " 
    cQuery +=   "           AND DUA.DUA_SERIE       <> 'COL'                                     " 
    cQuery +=   "           AND DUA.DUA_SERIE       <> 'PED'                                     " 
    cQuery +=   "           AND DUA.D_E_L_E_T_      = ' '                                        " 
    
    //--CLIENTE REMETENTE
    cQuery +=   "   LEFT JOIN <<SA1_COMPANY>> REM                                               " 
    cQuery +=   "           ON  REM.A1_FILIAL       = <<SUBSTR_SA1_DT6_FILIAL>>                  " 
    cQuery +=   "           AND REM.A1_COD          = DT6.DT6_CLIREM                             " 
    cQuery +=   "           AND REM.A1_LOJA         = DT6.DT6_LOJREM                             " 
    cQuery +=   "           AND REM.D_E_L_E_T_	    = ' '                                        " 
   
    //--CLIENTE DESTINATARIO
    cQuery +=   "   LEFT JOIN <<SA1_COMPANY>> DES                                               " 
    cQuery +=   "           ON  DES.A1_FILIAL       = <<SUBSTR_SA1_DT6_FILIAL>>                  " 
    cQuery +=   "           AND DES.A1_COD          = DT6.DT6_CLIDES                             " 
    cQuery +=   "           AND DES.A1_LOJA		    = DT6.DT6_LOJDES                             " 
    cQuery +=   "           AND DES.D_E_L_E_T_	= ' '                                            " 
   
    //--CLIENTE DEVEDOR
    cQuery +=   "   LEFT JOIN <<SA1_COMPANY>> DEV                                               " 
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
    
    //--REGIAO DE CALCULO
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYCAL                                             "
    cQuery +=   "           ON  DUYCAL.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYCAL.DUY_GRPVEN      = DT6.DT6_CDRDES                          "
    cQuery +=   "           AND DUYCAL.D_E_L_E_T_      = ' '                                     "
    
    //--CODIGO DA NEGOCIACAO
    cQuery +=   "   LEFT JOIN <<DDB_COMPANY>> DDB                                                "
    cQuery +=   "           ON  DDB.DDB_FILIAL          = <<SUBSTR_DDB_DT6_FILIAL>>              "
    cQuery +=   "           AND DDB.DDB_CODNEG          = DT6.DT6_CODNEG                         "        
    cQuery +=   "           AND DDB.D_E_L_E_T_          = ' '                                    "
  
    //--SERVICO DA NEGOCIACAO
    cQuery +=   "   LEFT JOIN <<SX5_COMPANY>> SX5                                               "
    cQuery +=   "           ON  SX5.X5_FILIAL           = <<SUBSTR_SX5_DT6_FILIAL>>              "
    cQuery +=   "           AND SX5.X5_TABELA           = 'L4'                                   "
    cQuery +=   "           AND SX5.X5_CHAVE            = DT6.DT6_SERVIC                         "  
    cQuery +=   "           AND SX5.D_E_L_E_T_          = ' '                                    "
            
    cQuery +=   "   WHERE DUA.DUA_DATOCO BETWEEN <<START_DATE>> AND <<FINAL_DATE>>           " 
    cQuery +=   "           AND DUA.D_E_L_E_T_ = ' '                                             "
    cQuery +=   "   <<AND_XFILIAL_DUA_FILIAL>>                                                   "
    
Return cQuery
