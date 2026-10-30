#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43MOVCAR

//----------------------------------------------------------------------------------
/*{Protheus.doc } 43MOVCAR
Visualiza os documentos emitidos pela transportadora.
N�o s�o considerados os documentos de coleta e documentos de apoio.

@author Leandro Paulino
@since  23/11/2018     
/*/
//----------------------------------------------------------------------------------

Class TMSMovimentacaoCarga from BAEntity
    Method Setup() CONSTRUCTOR  
    Method BuildQuery() 
EndClass


//----------------------------------------------------------------------------------
/*{Protheus.doc } Setup
Construtor Padr�o


@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method Setup() Class TMSMovimentacaoCarga

    _Super:Setup("TMS Movimentacao Carga", FACT, "DT6")

    //-----------------------------------------------------------
    //Define que a extra��o da entidade ser� feita por um per�odo
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
Method BuildQuery() Class TMSMovimentacaoCarga


    Local cQuery := ""

    //Receitas de Transporte
    cQuery +=   " SELECT    <<KEY_COMPANY>>                                 AS BK_EMPRESA       ,"
    cQuery +=   "           <<KEY_FILIAL_DT6_FILIAL>>                       AS BK_FILIAL        ,"
    cQuery +=   "           DT6_DATEMI                                      AS DATA_EMISSAO     , " 
    cQuery +=   "           <<KEY_SA1_REM.A1_FILIAL+DT6_CLIREM+DT6_LOJREM>> AS BK_REMETENTE     ," //Cliente Rementente
    cQuery +=   "           <<KEY_SA1_DES.A1_FILIAL+DT6_CLIDES+DT6_LOJDES>> AS BK_DESTINATARIO  ," //Cliente Destinat�rio
    cQuery +=   "           <<KEY_SA1_DEV.A1_FILIAL+DT6_CLIDEV+DT6_LOJDEV>> AS BK_DEVEDOR       ," //Cliente Devedor
    cQuery +=   "           <<KEY_DUY_DUYORI.DUY_FILIAL+DT6_CDRORI>>        AS BK_CDRORI        ," //--Regi�o de Origem
    cQuery +=   "           <<KEY_DUY_DUYDES.DUY_FILIAL+DT6_CDRDES>>        AS BK_CDRDES        ," //--Regi�o de Destino        
    cQuery +=   "           <<KEY_DDB_DDB_FILIAL+DDB_CODNEG>>               AS BK_CODNEG        ," //--C�digo da Negocia��o
    cQuery +=   "           <<KEY_SX5_SX5.X5_FILIAL+DT6_SERVIC>>            AS BK_SERNEG        ," //--Servi�o da Negocia��o    
    cQuery +=   "           <<KEY_FILIAL_DT6_FILORI>>                       AS BK_FILIAL_ORIGEM ,"//--Filial de Origem
    cQuery +=   "           <<KEY_FILIAL_DT6_FILDES>>                       AS BK_FILIAL_DESTINO,"//--Filial de Destino
    cQuery +=   "           <<KEY_FILIAL_DT6_FILDOC>>                       AS BK_FILIAL_DOCTO  ,"//--Filial do documento
    
    //--DIMENS�ES MANUAIS
    cQuery +=   "           <<KEY_###_DT6_DOCTMS>>                          AS BK_DOCTMS        ," //--Tipo de Documento    
    cQuery +=   "           <<KEY_###_DT6_TIPTRA>>                          AS BK_TIPTRA        ," //--Tipo de Transporte
    //--FIM DIMENS�ES MMANUAIS
    
    cQuery +=   "           CASE WHEN REM.A1_COD_MUN = ' ' THEN <<KEY_CC2_REM.A1_EST>> ELSE <<KEY_CC2_REM.A1_EST+REM.A1_COD_MUN>> END AS BK_REGIAO_REM, "
    cQuery +=   "           CASE WHEN DES.A1_COD_MUN = ' ' THEN <<KEY_CC2_DES.A1_EST>> ELSE <<KEY_CC2_DES.A1_EST+DES.A1_COD_MUN>> END AS BK_REGIAO_DES, "
    cQuery +=   "           CASE WHEN DEV.A1_COD_MUN = ' ' THEN <<KEY_CC2_DEV.A1_EST>> ELSE <<KEY_CC2_DEV.A1_EST+DEV.A1_COD_MUN>> END AS BK_REGIAO_DEV, "
    cQuery +=   "           CASE WHEN DUYCAL.DUY_CODMUN = ' ' THEN <<KEY_CC2_DUYCAL.DUY_EST>> ELSE <<KEY_CC2_DUYCAL.DUY_EST+DUYCAL.DUY_CODMUN>> END AS BK_REGIAO_CDRCAL, "
    cQuery +=   "           CASE WHEN DUYORI.DUY_CODMUN = ' ' THEN <<KEY_CC2_DUYORI.DUY_EST>> ELSE <<KEY_CC2_DUYORI.DUY_EST+DUYORI.DUY_CODMUN>> END AS BK_REGIAO_CDRORI, "
    
    
    cQuery +=   "           DT6_FILDOC                                      AS FILIAL_DOCUMENTO ," 
    cQuery +=   "           DT6_DOC                                         AS DOCUMENTO        ," 
    cQuery +=   "           DT6_SERIE                                       AS SERIE            ," 
    cQuery +=   "           <<FORMATVALUE(DT6_PESO)>>                       AS PESO             ," 
    cQuery +=   "           <<FORMATVALUE(DT6_PESOM3)>>                     AS PESO_CUBADO      ," 
    cQuery +=   "           <<FORMATVALUE(DT6_METRO3)>>                     AS PESO_M3          ," 
    cQuery +=   "           <<FORMATVALUE(DT6_VOLORI)>>                     AS VOLUME           ," 
    cQuery +=   "           <<FORMATVALUE(DT6_VALMER)>>                     AS VALOR_MERCADORIA ," 
    cQuery +=   "           <<FORMATVALUE(DT6_VALTOT)>>                     AS VALOR_TOTAL,      "
    cQuery +=   "			<<KEY_MOEDA_DT6_MOEDA>> AS BK_MOEDA, "
	cQuery +=   "			<<CODE_INSTANCE>>	AS INSTANCIA "

    cQuery +=   " FROM      <<DT6_COMPANY>> DT6                                                  " 
   
    //--CLIENTE REMETENTE
    cQuery +=   "   INNER JOIN <<SA1_COMPANY>> REM                                               " 
    cQuery +=   "           ON  REM.A1_FILIAL       = <<SUBSTR_SA1_DT6_FILIAL>>                  " 
    cQuery +=   "           AND REM.A1_COD          = DT6.DT6_CLIREM                             " 
    cQuery +=   "           AND REM.A1_LOJA         = DT6.DT6_LOJREM                             " 
    cQuery +=   "           AND REM.D_E_L_E_T_	    = ' '                                        " 
   
    //--CLIENTE DESTINAT�RIO
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
    
    //--REGI�O DE ORIGEM
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYORI                                             "
    cQuery +=   "           ON  DUYORI.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYORI.DUY_GRPVEN      = DT6.DT6_CDRORI                          "
    cQuery +=   "           AND DUYORI.D_E_L_E_T_      = ' '                                     "
    
    //--REGI�O DE DESTINO
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYDES                                             "
    cQuery +=   "           ON  DUYDES.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYDES.DUY_GRPVEN      = DT6.DT6_CDRDES                          "
    cQuery +=   "           AND DUYDES.D_E_L_E_T_      = ' '                                     "

    //--REGI�O DE CALCULO
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYCAL                                             "
    cQuery +=   "           ON  DUYCAL.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYCAL.DUY_GRPVEN      = DT6.DT6_CDRCAL                          "
    cQuery +=   "           AND DUYCAL.D_E_L_E_T_      = ' '                                     "
    
    //--C�DIGO DA NEGOCIA��O
    cQuery +=   "   LEFT JOIN <<DDB_COMPANY>> DDB                                                "
    cQuery +=   "           ON  DDB.DDB_FILIAL          = <<SUBSTR_DDB_DT6_FILIAL>>              "
    cQuery +=   "           AND DDB.DDB_CODNEG          = DT6.DT6_CODNEG                         "    
    cQuery +=   "           AND DDB.D_E_L_E_T_          = ' '                                    "
    
    //--SERVI�O DA NEGOCIA��O
    cQuery +=   "   INNER JOIN <<SX5_COMPANY>> SX5                                               "
    cQuery +=   "           ON  SX5.X5_FILIAL           = <<SUBSTR_SX5_DT6_FILIAL>>              "
    cQuery +=   "           AND SX5.X5_TABELA           = 'L4'                                   "
    cQuery +=   "           AND SX5.X5_CHAVE            = DT6.DT6_SERVIC                         "  
    cQuery +=   "           AND SX5.D_E_L_E_T_          = ' '                                    "
            
    cQuery +=   "   WHERE DT6.DT6_DATEMI BETWEEN <<START_DATE>> AND <<FINAL_DATE>>               "     
    cQuery +=   "           AND DT6.DT6_DOCTMS          <> '1'                                   "
    cQuery +=   "           AND DT6.D_E_L_E_T_          = ' '                                    "
    cQuery +=   "   <<AND_XFILIAL_DT6_FILIAL>>                                                   "
    

Return cQuery
