#INCLUDE "BADEFINITION.CH"

NEW ENTITY 43INDTPT

//----------------------------------------------------------------------------------
/*{Protheus.doc } BAReceita
Visualiza a receita da Transportadora considerando os documentos emitidos pela mesma
N„o s„o considerados os documentos de coleta e documentos de apoio.

@author Leandro Paulino
@since  23/11/2018     
/*/
//----------------------------------------------------------------------------------

Class TMSIndenizacaoTransporte from BAEntity
    Method Setup() CONSTRUCTOR  
    Method BuildQuery() 
EndClass


//----------------------------------------------------------------------------------
/*{Protheus.doc } Setup
Construtor Padr„o


@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method Setup() Class TMSIndenizacaoTransporte
    _Super:Setup("TMS Indenizacao Transporte", FACT, "DUB")

    //-----------------------------------------------------------
    //Define que a extraÁ„o da entidade ser· feita por um perÌodo
    //------------------------------------------------------------
    
Return

//----------------------------------------------------------------------------------
/*{Protheus.doc} BuildQuery
ContrÛi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa

@author Leandro Paulino
@since  23/11/2018
/*/
//----------------------------------------------------------------------------------
Method BuildQuery() Class TMSIndenizacaoTransporte


    Local cQuery := ""

    //Receitas de Transporte
    cQuery +=   " SELECT    <<KEY_COMPANY>>                                 AS BK_EMPRESA           ,"
    cQuery +=   "           <<KEY_FILIAL_DUB_FILIAL>>                       AS BK_FILIAL            ,"
    cQuery +=   "           DUB.DUB_DATRID                                  AS DATA_REGISTRO        ,"//--Data do Registro de IndenizaÁ„o
    cQuery +=   "           DUB.DUB_HORRID                                  AS HORA_REGISTRO        ,"//--Hora do Registro de IndenizaÁ„o 
    cQuery +=   "           DUB.DUB_ITEM                                    AS ITEM                 ,"//--Item
    cQuery +=   "           DUB.DUB_FILRID                                  AS FILIAL_REGISTRO      ,"//--Filial do Registro de IndenizaÁ„o
    cQuery +=   "           DUB.DUB_NUMRID                                  AS NUMERO_REGISTRO      ,"//--Numero do Registro de IndenizaÁ„o
    cQuery +=   "           <<KEY_DU3_DU3.DU3_FILIAL+DUB.DUB_COMSEG>>       AS RAMO_SEGURO          ,"//--Ramo de Seguro (Criar Dimens„o de Ramo de Seguro???)
    cQuery +=   "           <<KEY_DT2_DT2.DT2_FILIAL+DUB.DUB_CODOCO>>       AS BK_CODIGO_OCORRENCIA ,"//--Codigo Ocorrencia
    cQuery +=   "           DUB.DUB_NUMPRO                                  AS NUMERO_PROCESSO      ,"//--Numero do processo
    cQuery +=   "           <<KEY_DUY_DUYORI.DUY_FILIAL+DT6_CDRORI>>        AS BK_CDRORI            ,"//--Codigo da Regiao de origem
    cQuery +=   "           <<KEY_DUY_DUYDES.DUY_FILIAL+DT6_CDRDES>>        AS BK_CDRDES            ,"//--Regiùo de Origem
    cQuery +=   "           <<KEY_###_DUB_STATUS>>                          AS BK_STATUS_INDENIZACAO,"//--Status IndenizaÁ„o

    cQuery +=   "           <<KEY_SA1_SA1.A1_FILIAL+DUB_CODCLI+DUB_LOJCLI>> AS BK_CLIENTE           ,"//--Cliente
    cQuery +=   "           DUB.DUB_QTDOCO                                  AS QUANTIDADE_OCORRENCIA,"//--Quantidade de Ocorrencias
    cQuery +=   "           DUB.DUB_VALPRE                                  AS VALOR_PREJUIZO       ,"//--Valor do PrejuÌzo
    cQuery +=   "           DUB.DUB_VALIND                                  AS VALOR_INDENIZADO     ,"//--Valor da IndenizaÁ„o
    cQuery +=   "           DUB.DUB_DATVEN                                  AS DATA_VENCIMENTO      ,"//--Data do Vencimento
    cQuery +=   "           DUB.DUB_DATENC                                  AS DATA_ENCERRAMENTO    ,"//--Data de Encerramento
    
    cQuery +=   "           DUB_FILDOC                                      AS BK_FILIAL_DOCTO          ,"//--Filial do documento
    cQuery +=   "           DUB_DOC                                         AS BK_NUMERO_DOCUMENTO      ,"//--Numero do Documento
    cQuery +=   "           DUB_SERIE                                       AS BK_SERIE                 ,"//--Serie do documento

    //--DIMENS’ES MANUAIS
    cQuery +=   "           <<KEY_###_DUB_STATUS>>                          AS BK_STATUS                ," //--Status do Registro"
    cQuery +=   "           <<KEY_###_DT6_DOCTMS>>                          AS BK_DOCTMS                ," //--Tipo de Documento    
    cQuery +=   "           <<KEY_###_DT6_TIPTRA>>                          AS BK_TIPTRA                ," //--Tipo de Transporte    
    cQuery +=   "           <<KEY_###_DT2_RESOCO>>                          AS RESPONSAVEL_OCORRENCIA   ," //--Respons·vel OcorrÍncia
    
    //--FIM DIMENS’ES MANUAIS
    cQuery +=   "           CASE WHEN SA1.A1_COD_MUN = ' ' THEN <<KEY_CC2_SA1.A1_EST>> ELSE <<KEY_CC2_SA1.A1_EST+SA1.A1_COD_MUN>> END AS BK_REGIAO_CLI, "
    cQuery +=   "           CASE WHEN REM.A1_COD_MUN    = ' ' THEN <<KEY_CC2_REM.A1_EST>> ELSE <<KEY_CC2_REM.A1_EST+REM.A1_COD_MUN>> END AS BK_REGIAO_REM, "
    cQuery +=   "           CASE WHEN DES.A1_COD_MUN    = ' ' THEN <<KEY_CC2_DES.A1_EST>> ELSE <<KEY_CC2_DES.A1_EST+DES.A1_COD_MUN>> END AS BK_REGIAO_DES, "
    cQuery +=   "           CASE WHEN DEV.A1_COD_MUN    = ' ' THEN <<KEY_CC2_DEV.A1_EST>> ELSE <<KEY_CC2_DEV.A1_EST+DEV.A1_COD_MUN>> END AS BK_REGIAO_DEV, "
    cQuery +=   "           CASE WHEN DUYCAL.DUY_CODMUN = ' ' THEN <<KEY_CC2_DUYCAL.DUY_EST>> ELSE <<KEY_CC2_DUYCAL.DUY_EST+DUYCAL.DUY_CODMUN>> END AS BK_REGIAO_CDRCAL, "
    cQuery +=   "           CASE WHEN DUYORI.DUY_CODMUN = ' ' THEN <<KEY_CC2_DUYORI.DUY_EST>> ELSE <<KEY_CC2_DUYORI.DUY_EST+DUYORI.DUY_CODMUN>> END AS BK_REGIAO_CDRORI, "
    
    cQuery +=   "			<<KEY_MOEDA_DT6_MOEDA>> AS BK_MOEDA, "
	cQuery +=   "			<<CODE_INSTANCE>>	AS INSTANCIA "
    
    cQuery +=   " FROM      <<DUB_COMPANY>> DUB                                                  " 

    cQuery +=   "   INNER JOIN <<DT6_COMPANY>> DT6                                               "
    cQuery +=   "           ON  DT6.DT6_FILIAL      = <<SUBSTR_DT6_DUB_FILIAL>>                  "
    cQuery +=   "           AND DT6.DT6_FILDOC      = DUB.DUB_FILDOC                             "
    cQuery +=   "           AND DT6.DT6_DOC         = DUB.DUB_DOC                                "
    cQuery +=   "           AND DT6.DT6_SERIE       = DUB.DUB_SERIE                              "
   

    //--RAMO SEGURO
    cQuery +=   "   LEFT JOIN <<DU3_COMPANY>> DU3                                                "
    cQuery +=   "           ON  DU3.DU3_FILIAL      = <<SUBSTR_DU3_DUB_FILIAL>>                  "
    cQuery +=   "           AND DU3.DU3_COMSEG      = DUB.DUB_COMSEG                             "
    cQuery +=   "           AND DU3.D_E_L_E_T_  = ' '                                            "  
    //--OCORR NCIA
    cQuery +=   "   LEFT JOIN <<DT2_COMPANY>> DT2                                                "
    cQuery +=   "           ON  DT2.DT2_FILIAL      = <<SUBSTR_DT2_DUB_FILIAL>>                  "
    cQuery +=   "           AND DT2.DT2_CODOCO      = DUB.DUB_CODOCO                             "
    CqUERY +=   "           AND DT2.D_E_L_E_T_      = ' '                                        "   
    //--CLIENTE
    cQuery +=   "   LEFT JOIN <<SA1_COMPANY>> SA1                                                " 
    cQuery +=   "           ON  SA1.A1_FILIAL       = <<SUBSTR_SA1_DUB_FILIAL>>                  " 
    cQuery +=   "           AND SA1.A1_COD          = DUB.DUB_CODCLI                             " 
    cQuery +=   "           AND SA1.A1_LOJA         = DUB.DUB_LOJCLI                             " 
    cQuery +=   "           AND SA1.D_E_L_E_T_	    = ' '                                        " 
   
    //--REGI√O DE ORIGEM
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYORI                                             "
    cQuery +=   "           ON  DUYORI.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYORI.DUY_GRPVEN      = DT6.DT6_CDRORI                          "
    cQuery +=   "           AND DUYORI.D_E_L_E_T_      = ' '                                     "
    
    //--REGI√O DE DESTINO
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYDES                                             "
    cQuery +=   "           ON  DUYDES.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYDES.DUY_GRPVEN      = DT6.DT6_CDRDES                          "
    cQuery +=   "           AND DUYDES.D_E_L_E_T_      = ' '                                     "
    
    //--REGI√O DE DESTINO
    cQuery +=   "   LEFT JOIN <<DUY_COMPANY>> DUYCAL                                             "
    cQuery +=   "           ON  DUYCAL.DUY_FILIAL      = <<SUBSTR_DUY_DT6_FILIAL>>               "    
    cQuery +=   "           AND DUYCAL.DUY_GRPVEN      = DT6.DT6_CDRDES                          "
    cQuery +=   "           AND DUYCAL.D_E_L_E_T_      = ' '                                     "
    
    //--CLIENTE REMETENTE
    cQuery +=   "   LEFT JOIN <<SA1_COMPANY>> REM                                               " 
    cQuery +=   "           ON  REM.A1_FILIAL       = <<SUBSTR_SA1_DT6_FILIAL>>                  " 
    cQuery +=   "           AND REM.A1_COD          = DT6.DT6_CLIREM                             " 
    cQuery +=   "           AND REM.A1_LOJA         = DT6.DT6_LOJREM                             " 
    cQuery +=   "           AND REM.D_E_L_E_T_	    = ' '                                        " 
   
    //--CLIENTE DESTINATÔøΩRIO
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
    

    
    //--C”DIGO DA NEGOCIA«√O
    cQuery +=   "   LEFT JOIN <<DDB_COMPANY>> DDB                                                "
    cQuery +=   "           ON  DDB.DDB_FILIAL          = <<SUBSTR_DDB_DT6_FILIAL>>              "
    cQuery +=   "           AND DDB.DDB_CODNEG          = DT6.DT6_CODNEG                         "    
    cQuery +=   "           AND DDB.D_E_L_E_T_          = ' '                                    "
    
    //--SERVI«O DA NEGOCIA«√O
    cQuery +=   "   INNER JOIN <<SX5_COMPANY>> SX5                                               "
    cQuery +=   "           ON  SX5.X5_FILIAL           = <<SUBSTR_SX5_DT6_FILIAL>>              "
    cQuery +=   "           AND SX5.X5_TABELA           = 'L4'                                   "
    cQuery +=   "           AND SX5.X5_CHAVE            = DT6.DT6_SERVIC                         "  
    cQuery +=   "           AND SX5.D_E_L_E_T_          = ' '                                    "
    
        
    cQuery +=   "   WHERE DUB.DUB_DATRID BETWEEN <<START_DATE>> AND <<FINAL_DATE>>               "     
    cQuery +=   "           AND DUB.D_E_L_E_T_          = ' '                                    "
    cQuery +=   "   <<AND_XFILIAL_DUB_FILIAL>>                                                   "
    

Return cQuery
