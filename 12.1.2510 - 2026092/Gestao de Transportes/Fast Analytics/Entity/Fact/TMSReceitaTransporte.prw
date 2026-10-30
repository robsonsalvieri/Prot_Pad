#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43RECTPT

//----------------------------------------------------------------------------------
/*{Protheus.doc } TMSReceitaTransporte
Visualiza a receita da Transportadora considerando os documentos emitidos pela mesma
Não são considerados os documentos de coleta e documentos de apoio.

@author Leandro Paulino
@since  23/11/2018     
/*/
//-----------------------------------------------------------------------   -----------

Class TMSReceitaTransporte from BAEntity
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
Method Setup() Class TMSReceitaTransporte
    _Super:Setup("TMS Receita Transporte", FACT, "DT8")

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
Method BuildQuery() Class TMSReceitaTransporte

    Local cQuery := ""

    //Receitas de Transporte

    cQuery +=   " SELECT    <<KEY_COMPANY>>                                 AS BK_EMPRESA       ,"
    cQuery +=   "           <<KEY_FILIAL_DT8_FILIAL>>                       AS BK_FILIAL        ,"
    cQuery +=   "           DT6_DATEMI                                      AS DATA_EMISSAO     ," 
    cQuery +=   "           <<KEY_SA1_REM.A1_FILIAL+DT6_CLIREM+DT6_LOJREM>> AS BK_REMETENTE     ," //Cliente Rementente
    cQuery +=   "           <<KEY_SA1_DES.A1_FILIAL+DT6_CLIDES+DT6_LOJDES>> AS BK_DESTINATARIO  ," //Cliente Destinatário
    cQuery +=   "           <<KEY_SA1_DEV.A1_FILIAL+DT6_CLIDEV+DT6_LOJDEV>> AS BK_DEVEDOR       ," //Cliente Devedor
    cQuery +=   "           <<KEY_DUY_DUYORI.DUY_FILIAL+DT6_CDRORI>>        AS BK_CDRORI        ," //--Região de Origem
    cQuery +=   "           <<KEY_DUY_DUYDES.DUY_FILIAL+DT6_CDRDES>>        AS BK_CDRDES        ," //--Região de Destino    
    cQuery +=   "           <<KEY_DUY_DUYDEv.DUY_FILIAL+DT6_CDRCAL>>        AS BK_CDRCAL        ," //--Região de Destino    
    cQuery +=   "           <<KEY_DT3_DT3_FILIAL+DT8_CODPAS>>               AS BK_COMPONENTE    ," //--Código do Componente
    cQuery +=   "           <<KEY_DDB_DDB_FILIAL+DDB_CODNEG>>               AS BK_NEGOCIACAO    ," //--Código da Negociação
    cQuery +=   "           <<KEY_SX5_SX5.X5_FILIAL+DT6_SERVIC>>            AS BK_SERVICO       ," //--Serviço da Negociação    
    cQuery +=   "           <<KEY_FILIAL_DT6_FILORI>>                       AS BK_FILIAL_ORIGEM ,"//--Filial de Origem
    cQuery +=   "           <<KEY_FILIAL_DT6_FILDES>>                       AS BK_FILIAL_DESTINO,"//--Filial de Destino
    cQuery +=   "           <<KEY_FILIAL_DT6_FILDOC>>                       AS BK_FILIAL_DOCTO  ,"//--Filial do documento
    
    //--DIMENSÕES MANUAIS
    cQuery +=   "           <<KEY_###_DT6_DOCTMS>>                          AS BK_DOCTMS        ," //--Tipo de Documento    
    cQuery +=   "           <<KEY_###_DT6_TIPTRA>>                          AS BK_TIPTRA        ," //--Tipo de Transporte
    //--FIM 
    cQuery +=   "           DT8_FILDOC                                      AS FILDOC           ," 
    cQuery +=   "           DT8_DOC                                         AS DOCUMENTO        ," 
    cQuery +=   "           DT8_SERIE                                       AS SERIE            ," 
    cQuery +=   "           DT8_CODPRO                                      AS PRODUTO          ," 
    
    cQuery +=   "           CASE WHEN REM.A1_COD_MUN    = ' ' THEN <<KEY_CC2_REM.A1_EST>> ELSE <<KEY_CC2_REM.A1_EST+REM.A1_COD_MUN>> END AS BK_REGIAO_REM, "
    cQuery +=   "           CASE WHEN DES.A1_COD_MUN    = ' ' THEN <<KEY_CC2_DES.A1_EST>> ELSE <<KEY_CC2_DES.A1_EST+DES.A1_COD_MUN>> END AS BK_REGIAO_DES, "
    cQuery +=   "           CASE WHEN DEV.A1_COD_MUN    = ' ' THEN <<KEY_CC2_DEV.A1_EST>> ELSE <<KEY_CC2_DEV.A1_EST+DEV.A1_COD_MUN>> END AS BK_REGIAO_DEV, "
    cQuery +=   "           CASE WHEN DUYDEV.DUY_CODMUN = ' ' THEN <<KEY_CC2_DUYDEV.DUY_EST>> ELSE <<KEY_CC2_DUYDEV.DUY_EST+DUYDEV.DUY_CODMUN>> END AS BK_REGIAO_CDRCAL, "
    cQuery +=   "           CASE WHEN DUYORI.DUY_CODMUN = ' ' THEN <<KEY_CC2_DUYORI.DUY_EST>> ELSE <<KEY_CC2_DUYORI.DUY_EST+DUYORI.DUY_CODMUN>> END AS BK_REGIAO_CDRORI, "
    
    cQuery +=   "           <<KEY_FILIAL_DT6_FILORI>>                       AS BK_FILIAL_ORIGEM ,"     
    cQuery +=   "           <<FORMATVALUE(DT8_VALPAS)>>                     AS VALOR_COMPONENTE ," 
    cQuery +=   "           <<FORMATVALUE(DT8_VALIMP)>>                     AS VALOR_IMPOSTO    ," 
    cQuery +=   "           <<FORMATVALUE(DT8_VALTOT)>>                     AS VALOR_TOTAL,      "
    cQuery +=   "			<<KEY_MOEDA_DT6_MOEDA>>                         AS BK_MOEDA, "
	cQuery +=   "			<<CODE_INSTANCE>>                               AS INSTANCIA "

    cQuery +=   " FROM      <<DT8_COMPANY>> DT8                                                  " 
   
    //DOCUMENTOS DE TRANSPORTE - DT6        
    cQuery +=   "   INNER JOIN <<DT6_COMPANY>> DT6                                               " 
    cQuery +=   "           ON  DT6.DT6_FILIAL      = <<SUBSTR_DT6_DT8_FILIAL>>                  " 
    cQuery +=   "           AND DT6.DT6_FILDOC      = DT8.DT8_FILDOC                             " 
    cQuery +=   "           AND DT6.DT6_DOC         = DT8.DT8_DOC                                " 
    cQuery +=   "           AND DT6.DT6_SERIE       = DT8.DT8_SERIE                              " 
    cQuery +=   "           AND DT6.DT6_SERIE       <> 'COL'                                     " 
    cQuery +=   "           AND DT6.DT6_SERIE       <> 'PED'                                     " 
    cQuery +=   "           AND DT6.D_E_L_E_T_          = ' '                                    " 
   
    //--CLIENTE REMETENTE
    cQuery +=   "   INNER JOIN <<SA1_COMPANY>> REM                                               " 
    cQuery +=   "           ON  REM.A1_FILIAL       = <<SUBSTR_SA1_DT6_FILIAL>>                  " 
    cQuery +=   "           AND REM.A1_COD          = DT6.DT6_CLIREM                             " 
    cQuery +=   "           AND REM.A1_LOJA         = DT6.DT6_LOJREM                             " 
    cQuery +=   "           AND REM.D_E_L_E_T_	    = ' '                                        " 
   
    //--CLIENTE DESTINATÁRIO
    cQuery +=   "   INNER JOIN <<SA1_COMPANY>> DES                                               " 
    cQuery +=   "           ON  DES.A1_FILIAL       = <<SUBSTR_SA1_DT6_FILIAL>>                  " 
    cQuery +=   "           AND DES.A1_COD          = DT6.DT6_CLIDES                             " 
    cQuery +=   "           AND DES.A1_LOJA		    = DT6.DT6_LOJDES                             " 
    cQuery +=   "           AND DES.D_E_L_E_T_	= ' '                                            " 
   
    //--CLIENTE DEVEDOR
    cQuery +=   "   INNER JOIN <<SA1_COMPANY>> DEV                                               " 
    cQuery +=   "           ON  DEV.A1_FILIAL       = <<SUBSTR_SA1_DT6_FILIAL>>                  " 
    cQuery +=   "           AND	DEV.A1_COD		    = DT6.DT6_CLIDEV                             " 
    cQuery +=   "           AND DEV.A1_LOJA		    = DT6.DT6_LOJDEV                             " 
    cQuery +=   "           AND DEV.D_E_L_E_T_      = ' '                                        " 
    
    //--REGIÃO DE ORIGEM
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYORI                                             "
    cQuery +=   "           ON  DUYORI.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYORI.DUY_GRPVEN      = DT6.DT6_CDRORI                          "
    cQuery +=   "           AND DUYORI.D_E_L_E_T_      = ' '                                     "
    
    //--REGIÃO DE DESTINO
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYDES                                             "
    cQuery +=   "           ON  DUYDES.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYDES.DUY_GRPVEN      = DT6.DT6_CDRDES                          "
    cQuery +=   "           AND DUYDES.D_E_L_E_T_      = ' '                                     "

    //--REGIÃO DE CALCULO
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYDEV                                             "
    cQuery +=   "           ON  DUYDEV.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYDEV.DUY_GRPVEN      = DT6.DT6_CDRCAL                          "
    cQuery +=   "           AND DUYDEV.D_E_L_E_T_      = ' '                                     "


    //--CÓDIGO DO COMPONENTE
    cQuery +=   "  INNER JOIN <<DT3_COMPANY>> DT3                                                "
    cQuery +=   "           ON  DT3.DT3_FILIAL          = <<SUBSTR_DT3_DT8_FILIAL>>              "
    cQuery +=   "           AND DT3.DT3_CODPAS          = DT8.DT8_CODPAS                         "
    cQuery +=   "           AND DT3.D_E_L_E_T_          = ' '                                    "
    
    //--CÓDIGO DA NEGOCIAÇÃO
    cQuery +=   "   LEFT JOIN <<DDB_COMPANY>> DDB                                                "
    cQuery +=   "           ON  DDB.DDB_FILIAL          = <<SUBSTR_DDB_DT6_FILIAL>>              "
    cQuery +=   "           AND DDB.DDB_CODNEG          = DT6.DT6_CODNEG                         "    
    cQuery +=   "           AND DDB.D_E_L_E_T_          = ' '                                    "
    
    //--SERVIÇO DA NEGOCIAÇÃO
    cQuery +=   "   INNER JOIN <<SX5_COMPANY>> SX5                                               "
    cQuery +=   "           ON  SX5.X5_FILIAL           = <<SUBSTR_SX5_DT6_FILIAL>>              "
    cQuery +=   "           AND SX5.X5_TABELA           = 'L4'                                   "
    cQuery +=   "           AND SX5.X5_CHAVE            = DT6.DT6_SERVIC                         "  
    cQuery +=   "           AND SX5.D_E_L_E_T_          = ' '                                    "
    
        
        cQuery +=   "   WHERE DT6.DT6_DATEMI BETWEEN <<START_DATE>> AND <<FINAL_DATE>>               " 
    cQuery +=   "           AND DT8.D_E_L_E_T_ = ' '                                             "
    cQuery +=   "   <<AND_XFILIAL_DT8_FILIAL>>                                                   "
    

Return cQuery
