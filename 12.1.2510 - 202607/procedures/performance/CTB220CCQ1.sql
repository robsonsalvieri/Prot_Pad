-- =============================================
-- Author:		TOTVS
-- Create date: 13/03/2026
-- Description:	Consolidacao Geral de Empresas
-- =============================================
CREATE PROCEDURE CTB220CCQ1_##
(
   @IN_EMPORI        Char( 'CT2_EMPORI' ),
   @IN_FILIALDEST    Char( 'CT2_FILIAL' ),
   @IN_TPSALDO       Char( 'CT2_TPSALD' ),
   @IN_DATA          Char( 08 ),
   @IN_LMOEDAESP     Char( 01 ),
   @IN_MOEDA         Char( 'CT2_MOEDLC' ),
   @IN_LOTE          Char( 'CT2_LOTE' ),
   @IN_SUBLOTE       Char( 'CT2_SBLOTE' ),
   @IN_DOC           Char( 'CT2_DOC' ),
   @IN_MAXLINHA      Integer,
   @IN_FILIAIS       VARCHAR(20),
   @IN_LCTBJOB       Char( 01 ),
   @IN_TRANSACTION   Char( 01 ),
   @OUT_LOTE         Char( 'CT2_LOTE' ) OutPut,
   @OUT_DOC          Char( 'CT2_DOC' ) OutPut, 
   @OUT_CONT         Integer OutPut 
)
AS 
Declare @cFilial_CT2 Char( 'CT2_FILIAL' )
Declare @cFilial_CQ3 Char( 'CQ3_FILIAL' )
Declare @cFilial_CQ5 Char( 'CQ5_FILIAL' )
Declare @cFilial_CQ1 Char( 'CQ1_FILIAL' )
Declare @cFilial_CTF Char( 'CTF_FILIAL' )
Declare @cFilial_CQ7 Char( 'CQ7_FILIAL' )
Declare @cFilial_CQA Char( 'CQA_FILIAL' ) 
Declare @cFilAnt     Char( 'CT2_FILIAL' )
Declare @cData       Char( 08 )
Declare @cDataAnt    Char( 08 )
Declare @cAux1       Char( 01 )
Declare @lPrim       Char( 01 )
Declare @cDc         Char( 01 )
Declare @cManual     Char( 01 )
Declare @cRotina     VarChar( 10 )
Declare @cAglut      Char( 01 )
Declare @cCrConv     Char( 01 )
Declare @iRecno      integer
Declare @iRecnoCTF   integer
Declare @iMaxLinha   integer
Declare @iLinha      integer
Declare @iAux        integer
Declare @iContador   integer
Declare @cSubLote    Char( 03 )
Declare @cHist       Char( 'CT2_HIST' )
Declare @cSeqHis     Char( 'CT2_SEQHIS' )
Declare @cSeqLan     Char( 'CT2_SEQLAN' )
Declare @cDoc        Char( 'CT2_DOC' )
Declare @cDocAux     Char( 'CT2_DOC' )
Declare @cLote       Char( 'CT2_LOTE' )
Declare @cLoteAux    Char( 'CT2_LOTE' )
Declare @cConta      Char( 'CT2_DEBITO' )
Declare @cContaDeb   Char( 'CT2_DEBITO' )
Declare @cContaCrd   Char( 'CT2_DEBITO' )
Declare @cContaAnt   Char( 'CT2_DEBITO' )
Declare @cContaCQ3   Char( 'CT2_DEBITO' )
Declare @cCustoCQ3   Char( 'CT2_CCD' )
Declare @cCustoCQ5   Char( 'CT2_CCD' )
Declare @cItemCQ5    Char( 'CT2_ITEMD' )
Declare @cMoeda      Char( 'CT2_MOEDLC' )
Declare @cMoeda1     Char( 'CT2_MOEDLC' )
Declare @cMoedaAnt   Char( 'CT2_MOEDLC' )
Declare @cLinha      Char( 'CT2_LINHA' )
Declare @cLinhaAux   Char( 'CT2_LINHA' )
Declare @cTpSald     Char( 'CT2_TPSALD' )   
Declare @cTpSaldAnt  Char( 'CT2_TPSALD' )
Declare @nValor      Float
Declare @nValor1     Float
Declare @nDebito     Float
Declare @nCredit     Float
Declare @nDebitoCQ3  Float
Declare @nCreditCQ3  Float
Declare @nDebitoCQ7  Float
Declare @nCreditCQ7  Float
Declare @nDebitoCQ7A Float
Declare @nCreditCQ7A Float
Declare @iLinha1     Integer
Declare @lCriaLinha  Char(01)
Declare @nTotDebCQ5A Float
Declare @nTotCrdCQ5A Float
Declare @nTotDebCQ3  Float
Declare @nTotCrdCQ3  Float
Declare @nTotDebCQ5  Float
Declare @nTotCrdCQ5  Float
Declare @nTotDeb     Float
Declare @nTotCrd     Float
Declare @nRTotDeb    Float
Declare @nRTotCrd    Float
DECLARE @cDelete     CHAR(1) 
Declare @cAliasTable CHAR(3)
Declare @nBind       Integer

##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
   DECLARE @cPostgres1 CHAR( 1 )
   DECLARE @cPostgres3 CHAR( 1 )
   DECLARE @nfim_CUR FLOAT 
##ENDIF_003

##IF_004({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})  
   DECLARE @cOracle1 CHAR( 1 )
   DECLARE @cOracle3 CHAR( 1 )
##ENDIF_004

DECLARE @cExecSql VARCHAR( 1 )
--query 2 
DECLARE @cExecSql2 VARCHAR( 1 )
--query 3 
DECLARE @cExecSql3 VARCHAR( 1 )
--query 4
DECLARE @cExecSql4 VARCHAR( 1 )

##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
   DECLARE @cParams VARCHAR( 1 )
   DECLARE @cParams2 VARCHAR( 1 )
   DECLARE @cParams3 VARCHAR( 1 )
   DECLARE @cParams4 VARCHAR( 1 )
##ENDIF_004

BEGIN
   SELECT @cDelete = ' '
   SELECT @cAliasTable = @IN_EMPORI || '0'
   SELECT @cLote     = @IN_LOTE
   SELECT @cSubLote  = @IN_SUBLOTE
   SELECT @cDoc      = @IN_DOC
   SELECT @iRecno    = 0
   SELECT @iRecnoCTF = 0
   SELECT @iLinha    = 1
   SELECT @iContador = 0
   SELECT @cLinha    = '000'
   SELECT @cLinhaAux = '000'
   SELECT @cAux1     = '0'
   SELECT @cMoedaAnt = ' '
   SELECT @cDataAnt  = ' '
   SELECT @cContaAnt = ' '
   SELECT @lPrim     = '1'
   SELECT @cHist     = 'Saldo Inicial'
   SELECT @cManual   = '1'
   SELECT @cRotina   = 'CTBA101'
   SELECT @cAglut    = '2'
   SELECT @cSeqHis   = '001'
   SELECT @cSeqLan   = ''
   SELECT @cCrConv   = '4'
   SELECT @iMaxLinha = @IN_MAXLINHA
   SELECT @nValor    = 0
   SELECT @iAux      = 0
   SELECT @OUT_LOTE  = ''
   SELECT @OUT_DOC   = ''
   SELECT @OUT_CONT  = @iContador
   SELECT @cExecSql = ' '
   SELECT @cExecSql2 = ' '
   SELECT @cExecSql3 = ' '
   SELECT @cExecSql4 = ' '

   exec XFILIAL_## 'CT2', @IN_FILIALDEST, @cFilial_CT2 OutPut
   exec XFILIAL_## 'CTF', @IN_FILIALDEST, @cFilial_CTF OutPut


                              ------------------- QUERY  1 CURSOR PRINCIPAL --------

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = " Declare CUR_CTB220CQ1 insensitive  CURSOR FOR "
   ##ENDIF_001

   SELECT @cExecSql = @cExecSql || " SELECT "
   SELECT @cExecSql = @cExecSql || "   A.CQ1_FILIAL,A.CQ1_MOEDA,A.CQ1_DATA,A.CQ1_CONTA,A.nDebito_CQ1,A.nCredit_CQ1, "
   SELECT @cExecSql = @cExecSql || "   COALESCE(SUM(B.CQ7_DEBITO), 0) AS nDebito_CQ7, COALESCE(SUM(B.CQ7_CREDIT), 0) AS nCredit_CQ7, "
   SELECT @cExecSql = @cExecSql || "   A.CQ1_TPSALD "
   SELECT @cExecSql = @cExecSql || "   FROM ( "
   SELECT @cExecSql = @cExecSql || "      SELECT "
   SELECT @cExecSql = @cExecSql || "         CQ1_FILIAL,CQ1_MOEDA,CQ1_DATA,CQ1_CONTA,SUM(CQ1_DEBITO)AS nDebito_CQ1, SUM(CQ1_CREDIT)AS nCredit_CQ1, CQ1_TPSALD "
   SELECT @cExecSql = @cExecSql || "         FROM CQ1" || @cAliasTable

   -----where  com tratamento para binding de parametros-------------------------------------------
   ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " WHERE D_E_L_E_T_ = @cDelete" 
      
      SELECT @cExecSql = @cExecSql || " AND CQ1_FILIAL IN (SELECT TMP_FILIAL FROM  "|| @IN_FILIAIS ||" ) "
      
      SELECT @cExecSql = @cExecSql || " AND CQ1_DATA  <= @IN_DATA "
      
      IF @IN_TPSALDO != '*'
      BEGIN
         SELECT @cExecSql = @cExecSql || "AND CQ1_TPSALD = @IN_TPSALDO "
      END

      IF @IN_LMOEDAESP = '1'
      BEGIN 
         SELECT @cExecSql = @cExecSql || " AND CQ1_MOEDA = @IN_MOEDA "
      END
   ##ENDIF_002
   
   ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      
      SELECT @nBind = 1
      SELECT @cExecSql = @cExecSql ||" WHERE D_E_L_E_T_ = $"||@nBind_
      SELECT @cExecSql = @cExecSql ||" AND CQ1_FILIAL IN (SELECT TMP_FILIAL FROM  "|| @IN_FILIAIS ||" ) "
      
      SELECT @nBind = @nBind + 1
      SELECT @cExecSql = @cExecSql ||" AND CQ1_DATA  <= $"||@nBind_
      
      IF @IN_TPSALDO != '*'
      BEGIN
         SELECT @nBind = @nBind + 1
         SELECT @cExecSql = @cExecSql ||" AND CQ1_TPSALD = $"||@nBind_
      END   

      IF @IN_LMOEDAESP = '1'
      BEGIN 
         SELECT @nBind = @nBind + 1
         SELECT @cExecSql = @cExecSql || " AND CQ1_MOEDA = $"||@nBind_
      END
   ##ENDIF_003

   SELECT @cExecSql = @cExecSql || " GROUP BY CQ1_FILIAL,CQ1_CONTA,CQ1_DATA,CQ1_MOEDA,CQ1_TPSALD) A "
   SELECT @cExecSql = @cExecSql || " LEFT JOIN CQ7" || @cAliasTable|| " B ON "
   
   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " B.D_E_L_E_T_ = @cDelete "
   ##ENDIF_004
   
   ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})     
      SELECT @nBind = @nBind + 1
      SELECT @cExecSql = @cExecSql || " B.D_E_L_E_T_ = $"||@nBind_         
   ##ENDIF_005
   
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_FILIAL = A.CQ1_FILIAL "
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_CONTA  = A.CQ1_CONTA "
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_MOEDA  = A.CQ1_MOEDA "
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_DATA   = A.CQ1_DATA "
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_TPSALD = A.CQ1_TPSALD "
   SELECT @cExecSql = @cExecSql || " GROUP BY A.CQ1_FILIAL,A.CQ1_CONTA,A.CQ1_DATA,A.CQ1_MOEDA,A.nDebito_CQ1,A.nCredit_CQ1,A.CQ1_TPSALD "
   SELECT @cExecSql = @cExecSql || " ORDER BY 1, 4, 3, 2 "

   ----ABERTURA DO CURSOR----------------
   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " FOR READ ONLY "
      SELECT @cParams = "@cDelete CHAR(1), @IN_DATA Char( 08 )"
      
      IF @IN_TPSALDO != '*'
      BEGIN
         SELECT @cParams = @cParams || ", @IN_TPSALDO Char( TROCACT2_TPSALD )"
      END
      
      IF @IN_LMOEDAESP = '1'
      BEGIN 
         SELECT @cParams = @cParams || ", @IN_MOEDA Char( TROCACT2_MOEDLC )"         
      END

      IF @IN_LMOEDAESP = '1'
      BEGIN 
         IF @IN_TPSALDO != '*'
         BEGIN
             exec sp_executesql 
                @cExecSql,
                @cParams,@cDelete,@IN_DATA,@IN_TPSALDO,@IN_MOEDA
             OPEN CUR_CTB220CQ1         
         END
         ELSE
         BEGIN
            exec sp_executesql 
               @cExecSql,
               @cParams,@cDelete,@IN_DATA,@IN_MOEDA
            OPEN CUR_CTB220CQ1         
         END
      END
      ELSE
      BEGIN
         IF @IN_TPSALDO != '*'
         BEGIN
             exec sp_executesql 
                @cExecSql,
                @cParams,@cDelete,@IN_DATA,@IN_TPSALDO
             OPEN CUR_CTB220CQ1
         END
         ELSE
         BEGIN
            exec sp_executesql 
               @cExecSql,
               @cParams,@cDelete,@IN_DATA
            OPEN CUR_CTB220CQ1
         END
      END
   ##ENDIF_004

   ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      IF @IN_LMOEDAESP = '1'
      BEGIN 
         IF @IN_TPSALDO != '*'
         BEGIN
            OPEN CUR_CTB220CQ11
            --USING @cDelete,@IN_DATA,@IN_TPSALDO,@IN_MOEDA,@cDelete,@IN_TPSALDO
         END
         ELSE
         BEGIN
            OPEN CUR_CTB220CQ12
            --USING @cDelete,@IN_DATA,@IN_MOEDA,@cDelete
         END
      END
      ELSE
      BEGIN
         IF @IN_TPSALDO != '*'
         BEGIN
            OPEN CUR_CTB220CQ13
            --USING @cDelete,@IN_DATA,@IN_TPSALDO,@cDelete,@IN_TPSALDO
         END
         ELSE
         BEGIN
            OPEN CUR_CTB220CQ14
            --USING @cDelete,@IN_DATA,@cDelete
         END
      END
   ##ENDIF_005
                                       
                    ----------------------FINAL QUERY  1 CURSOR PRINCIPAL --------


                     -------------------QUERY 2 ATUALIZA @nTotDebCQ5 E @nTotCrdCQ5 --------

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql2 = " SELECT @nTotDebCQ5 = COALESCE(SUM( COALESCE(Q5.nDebito_CQ5,0) - COALESCE(Q7.nDebito_CQ7,0) ),0), "
      SELECT @cExecSql2 =  @cExecSql2 || " @nTotCrdCQ5 = COALESCE(SUM( COALESCE(Q5.nCredit_CQ5,0) - COALESCE(Q7.nCredit_CQ7,0) ),0) FROM( "
   ##ENDIF_001
   ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @cExecSql2 = " SELECT COALESCE(SUM( COALESCE(Q5.nDebito_CQ5,0) - COALESCE(Q7.nDebito_CQ7,0) ),0), "
      SELECT @cExecSql2 =  @cExecSql2 || " COALESCE(SUM( COALESCE(Q5.nCredit_CQ5,0) - COALESCE(Q7.nCredit_CQ7,0) ),0) FROM( "
   ##ENDIF_002
   
   SELECT @cExecSql2 =  @cExecSql2 || " SELECT CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM, COALESCE(SUM(CQ5_DEBITO),0)AS nDebito_CQ5 , "
   SELECT @cExecSql2 =  @cExecSql2 || " COALESCE(SUM(CQ5_CREDIT),0) AS nCredit_CQ5 FROM CQ5" || @cAliasTable

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql2 = @cExecSql2 || " C Where D_E_L_E_T_ = @cDelete and CQ5_FILIAL = @cFilial_CQ5 "
      SELECT @cExecSql2 = @cExecSql2 || " and CQ5_CONTA  = @cConta and CQ5_MOEDA  = @cMoeda and CQ5_TPSALD = @cTpSald and CQ5_DATA = @cData "
   ##ENDIF_001
   ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @cExecSql2 = @cExecSql2 || " C Where D_E_L_E_T_ = $1 and CQ5_FILIAL = $2 "
      SELECT @cExecSql2 = @cExecSql2 || " and CQ5_CONTA  = $3 and CQ5_MOEDA = $4 and CQ5_TPSALD = $5 and CQ5_DATA = $6 "
   ##ENDIF_002

   SELECT @cExecSql2 = @cExecSql2 || " Group By CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM  ) Q5 LEFT JOIN ( "
   SELECT @cExecSql2 = @cExecSql2 || " SELECT CQ7_CONTA,CQ7_CCUSTO,CQ7_ITEM, COALESCE(SUM(CQ7_DEBITO),0) AS nDebito_CQ7, "
   SELECT @cExecSql2 = @cExecSql2 || " COALESCE(SUM(CQ7_CREDIT),0)  AS nCredit_CQ7 FROM CQ7" || @cAliasTable

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql2 = @cExecSql2 || " WHERE D_E_L_E_T_ = @cDelete AND CQ7_FILIAL = @cFilial_CQ7 "
      SELECT @cExecSql2 = @cExecSql2 || " AND CQ7_MOEDA  = @cMoeda AND CQ7_TPSALD = @cTpSald AND CQ7_DATA   = @cData "
   ##ENDIF_001
   ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @cExecSql2 = @cExecSql2 || " WHERE D_E_L_E_T_ = $7 AND CQ7_FILIAL = $8 "
      SELECT @cExecSql2 = @cExecSql2 || " AND CQ7_MOEDA  = $9 AND CQ7_TPSALD = $10 AND CQ7_DATA = $11 "
   ##ENDIF_002
   
   SELECT @cExecSql2 = @cExecSql2 || " GROUP BY CQ7_CONTA,CQ7_CCUSTO,CQ7_ITEM) Q7 "
   SELECT @cExecSql2 = @cExecSql2 || " ON  Q7.CQ7_CONTA  = Q5.CQ5_CONTA AND Q7.CQ7_CCUSTO = Q5.CQ5_CCUSTO AND Q7.CQ7_ITEM   = Q5.CQ5_ITEM "

   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cParams2 = "@cDelete Char(1), @cFilial_CQ5 CHAR( TROCACQ7_FILIAL ), @cConta CHAR( TROCACT2_CONTA ), "
      SELECT @cParams2 = @cParams2 || " @cCustoCQ5 CHAR( TROCACT2_CCD ), @cItemCQ5  CHAR( TROCACT2_ITEMD) , "
      SELECT @cParams2 = @cParams2 || "   @cMoeda Char( TROCACT2_MOEDLC ),@cFilial_CQ7 CHAR( TROCACQ7_FILIAL ),@cTpSald Char( TROCACT2_TPSALD ), "
      SELECT @cParams2 = @cParams2 || "   @cData Char( 08 ), @nTotDebCQ5 FLOAT OUTPUT, @nTotCrdCQ5 FLOAT OUTPUT  "   
   ##ENDIF_004                              
                                       
                     ----------------------FINAL  QUERY 2 ATUALIZA @nTotDebCQ5 E @nTotCrdCQ5 -------------------



                     ----------------------QUERY 3 ATUALIZA 3 ABERTURA DE CURSOR CUR_CTB220CQ3 -------------------

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql3 = " Declare CUR_CTB220CQ3 insensitive cursor  for "
   ##ENDIF_001
   SELECT @cExecSql3 = @cExecSql3 || " SELECT E.CQ3_CONTA, E.CQ3_CCUSTO, Sum(CQ3_DEBITO) TOT_DEB_CQ3, Sum(CQ3_CREDIT) TOT_CRED_CQ3, "
   SELECT @cExecSql3 = @cExecSql3 || " COALESCE(H.TOT_DEB_CQ7,0) TOT_DEB_CQ7, COALESCE(H.TOT_CRED_CQ7,0) TOT_CRED_CQ7 "
   SELECT @cExecSql3 = @cExecSql3 || "  FROM CQ3" || @cAliasTable || " E LEFT JOIN ("
   SELECT @cExecSql3 = @cExecSql3 || " SELECT CQ7_CONTA,CQ7_CCUSTO,COALESCE (SUM(CQ7_DEBITO),0)  AS TOT_DEB_CQ7, "
   SELECT @cExecSql3 = @cExecSql3 || " COALESCE (SUM(CQ7_CREDIT),0)  AS TOT_CRED_CQ7 FROM CQ7" || @cAliasTable || " WHERE "

   ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql3 = @cExecSql3 || " CQ7_FILIAL = @cFilial_CQ7 AND CQ7_MOEDA = @cMoeda AND "
      SELECT @cExecSql3 = @cExecSql3 || " CQ7_TPSALD = @cTpSald AND CQ7_DATA = @cData AND D_E_L_E_T_ = @cDelete "
   ##ENDIF_002 
   ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @cExecSql3 = @cExecSql3 || " CQ7_FILIAL = $1 AND CQ7_MOEDA = $2 AND "
      SELECT @cExecSql3 = @cExecSql3 || " CQ7_TPSALD = $3 AND CQ7_DATA = $4 AND D_E_L_E_T_ = $5 "
   ##ENDIF_003     
   
   SELECT @cExecSql3 = @cExecSql3 || " GROUP BY CQ7_CONTA, CQ7_CCUSTO ) H ON H.CQ7_CONTA  = E.CQ3_CONTA AND H.CQ7_CCUSTO = E.CQ3_CCUSTO WHERE "
   
   ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql3 = @cExecSql3 || " E.D_E_L_E_T_ = @cDelete AND E.CQ3_FILIAL = @cFilial_CQ3 "
      SELECT @cExecSql3 = @cExecSql3 || " AND E.CQ3_CONTA  = @cConta AND E.CQ3_MOEDA = @cMoeda "
      SELECT @cExecSql3 = @cExecSql3 || " AND E.CQ3_TPSALD = @cTpSald AND E.CQ3_DATA = @cData "
   ##ENDIF_003
   ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @cExecSql3 = @cExecSql3 || " E.D_E_L_E_T_ = $6 AND E.CQ3_FILIAL = $7 "
      SELECT @cExecSql3 = @cExecSql3 || " AND E.CQ3_CONTA  = $8 AND E.CQ3_MOEDA = $9 "
      SELECT @cExecSql3 = @cExecSql3 || " AND E.CQ3_TPSALD = $10 AND E.CQ3_DATA = $11 "
   ##ENDIF_003 

   SELECT @cExecSql3 = @cExecSql3 || " GROUP BY E.CQ3_CONTA,E.CQ3_CCUSTO, H.TOT_DEB_CQ7,H.TOT_CRED_CQ7 ORDER BY 1,2 "

   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql3 = @cExecSql3 || " FOR READ ONLY "
      SELECT @cParams3 = "@cFilial_CQ7 CHAR( TROCACQ7_FILIAL ),@cMoeda Char( TROCACT2_MOEDLC ),@cTpSald Char( TROCACT2_TPSALD ),@cData Char( 08 ),@cDelete Char(1),@cFilial_CQ3 CHAR(TROCACQ7_FILIAL),@cConta CHAR( TROCACT2_CONTA ) "
   ##ENDIF_004

                   ----------------------FINAL  QUERY 3 ABERTURA DE CURSOR CUR_CTB220CQ3 -------------------


                  ---------------------- QUERY 4 ATUALIZA @nTotDebCQ5A E @nTotCrdCQ5A -------------------

   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql4 = @cExecSql4 || " SELECT @nTotDebCQ5A = COALESCE(SUM(F.TOT_DEB - COALESCE(G.TOT_DEB,0)),0),"
      SELECT @cExecSql4 = @cExecSql4 || " @nTotCrdCQ5A = COALESCE(SUM(F.TOT_CRED - COALESCE(G.TOT_CRED,0)),0) FROM ( " 
   ##ENDIF_004
   ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @cExecSql4 = @cExecSql4 || " SELECT COALESCE(SUM(F.TOT_DEB - COALESCE(G.TOT_DEB,0)),0), "
      SELECT @cExecSql4 = @cExecSql4 || " COALESCE(SUM(F.TOT_CRED - COALESCE(G.TOT_CRED,0)),0) FROM ( "
   ##ENDIF_005

   SELECT @cExecSql4 = @cExecSql4 || " SELECT CQ5_CONTA,CQ5_CCUSTO,CQ5_ITEM, COALESCE(SUM(CQ5_DEBITO),0)  AS TOT_DEB,"
   SELECT @cExecSql4 = @cExecSql4 || "  COALESCE(SUM(CQ5_CREDIT),0) AS TOT_CRED FROM CQ5" || @cAliasTable || " WHERE "

   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql4 = @cExecSql4 || " CQ5_FILIAL = @cFilial_CQ5 AND CQ5_CONTA = @cContaCQ3 "
      SELECT @cExecSql4 = @cExecSql4 || " AND CQ5_CCUSTO = @cCustoCQ3 AND CQ5_MOEDA = @cMoeda "
      SELECT @cExecSql4 = @cExecSql4 || " AND CQ5_TPSALD = @cTpSald AND CQ5_DATA = @cData AND D_E_L_E_T_ = @cDelete "
   ##ENDIF_004
   ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @cExecSql4 = @cExecSql4 || " CQ5_FILIAL = $1 AND CQ5_CONTA = $2 AND CQ5_CCUSTO = $3 "
      SELECT @cExecSql4 = @cExecSql4 || "  AND CQ5_MOEDA = $4 AND CQ5_TPSALD = $5 AND CQ5_DATA = $6 AND D_E_L_E_T_ = $7"
   ##ENDIF_005

   SELECT @cExecSql4 = @cExecSql4 || " GROUP BY CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM ) F"
   SELECT @cExecSql4 = @cExecSql4 || " LEFT JOIN ( SELECT CQ7_CONTA,CQ7_CCUSTO,CQ7_ITEM, " 
   SELECT @cExecSql4 = @cExecSql4 || " COALESCE(SUM(CQ7_DEBITO),0) AS TOT_DEB,COALESCE(SUM(CQ7_CREDIT),0) AS TOT_CRED"
   SELECT @cExecSql4 = @cExecSql4 || " FROM CQ7" || @cAliasTable || " WHERE "


   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql4 = @cExecSql4 || " CQ7_FILIAL = @cFilial_CQ7 AND CQ7_MOEDA = @cMoeda "
      SELECT @cExecSql4 = @cExecSql4 || " AND CQ7_TPSALD = @cTpSald AND CQ7_DATA = @cData AND D_E_L_E_T_ = @cDelete "
   ##ENDIF_004
   ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @cExecSql4 = @cExecSql4 || " CQ7_FILIAL = $8 AND CQ7_MOEDA = $9 AND CQ7_TPSALD = $10"
      SELECT @cExecSql4 = @cExecSql4 || " AND CQ7_DATA = $11 AND D_E_L_E_T_ = $12 "
   ##ENDIF_005

   SELECT @cExecSql4 = @cExecSql4 || " GROUP BY CQ7_CONTA, CQ7_CCUSTO, CQ7_ITEM ) G "
   SELECT @cExecSql4 = @cExecSql4 || " ON G.CQ7_CONTA  = F.CQ5_CONTA AND G.CQ7_CCUSTO = F.CQ5_CCUSTO "
   SELECT @cExecSql4 = @cExecSql4 || " AND G.CQ7_ITEM   = F.CQ5_ITEM "

   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cParams4 = " @cFilial_CQ5 CHAR( TROCACQ7_FILIAL ), @cContaCQ3 CHAR( TROCACT2_CONTA ), "
      SELECT @cParams4 = @cParams4 || " @cCustoCQ3 CHAR( TROCACT2_CCD ), @cMoeda Char( TROCACT2_MOEDLC ), "
      SELECT @cParams4 = @cParams4 || " @cTpSald Char( TROCACT2_TPSALD ),@cData Char( 08 ), @cDelete Char(1), "
      SELECT @cParams4 = @cParams4 || " @cFilial_CQ7 CHAR( TROCACQ7_FILIAL ), @nTotDebCQ5A FLOAT OUTPUT, @nTotCrdCQ5A FLOAT OUTPUT  "
   ##ENDIF_004


                  ----------------------FINAL  QUERY 4 ATUALIZA @nTotDebCQ5A E @nTotCrdCQ5A -------------------

   ------------------- ABERTURA CURSOR PRINCIPAL QUERY1 -------------------
   Fetch CUR_CTB220CQ1 into @cFilial_CQ1, @cMoeda, @cData, @cConta, @nDebito, @nCredit,@nDebitoCQ7,@nCreditCQ7, @cTpSald

   While ( @@fetch_status = 0 ) 
   BEGIN 
      exec XFILIAL_## 'CQ7', @cFilial_CQ1, @cFilial_CQ7 OutPut
      exec XFILIAL_## 'CQ5', @cFilial_CQ1, @cFilial_CQ5 OutPut
      exec XFILIAL_## 'CQ3', @cFilial_CQ1, @cFilial_CQ3 OutPut
      exec XFILIAL_## 'CQA', @cFilial_CQ1, @cFilial_CQA OutPut

      SELECT @nTotDebCQ5 = 0
      SELECT @nTotCrdCQ5 = 0

      -------------------  EXECUTA QUERY 2 ATUALIZA @nTotDebCQ5 E @nTotCrdCQ5 -------------------
      ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
         EXEC sp_executesql
            @cExecSql2,
            @cParams2,
            @cDelete = @cDelete,
            @cFilial_CQ5 = @cFilial_CQ5,
            @cConta = @cConta,
            @cCustoCQ5 = @cCustoCQ5,
            @cItemCQ5 = @cItemCQ5,
            @cMoeda = @cMoeda,
            @cFilial_CQ7 = @cFilial_CQ7,
            @cTpSald = @cTpSald,
            @cData = @cData,
            @nTotDebCQ5 = @nTotDebCQ5 OUTPUT,
            @nTotCrdCQ5 = @nTotCrdCQ5 OUTPUT
      ##ENDIF_001

      ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
         exec sp_executesql @cExecSql2
         /*EXECUTE @cExecSql2
         INTO @nTotDebCQ5, @nTotCrdCQ5
         USING vcDelete,vcFilial_CQ5,vcConta, vcMoeda,vcTpSald, vcData,vcDelete,vcFilial_CQ7,vcMoeda,vcTpSald,vcData*/
      ##ENDIF_005

                   ------------------- FIM EXECUCAO QUERY 2

      SELECT @nDebitoCQ3 = 0
      SELECT @nCreditCQ3 = 0
      SELECT @nTotDebCQ3 = 0
      SELECT @nTotCrdCQ3 = 0
      
      --------------------- EXECUTA QUERY 3 ABERTURA DE CURSOR  CUR_CTB220CQ3

      ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
            exec sp_executesql 
               @cExecSql3,
               @cParams3,
               @cFilial_CQ7,@cMoeda,@cTpSald,@cData,@cDelete,@cFilial_CQ3,@cConta
            OPEN CUR_CTB220CQ3
      ##ENDIF_004
      ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
            OPEN CUR_CTB220CQ3 
            -- FOR EXECUTE @cExecSql3 USING vcFilial_CQ7,vcMoeda,vcTpSald,vcData,vcDelete,vcDelete,vcFilial_CQ3,vcConta,vcMoeda,vcTpSald,vcData
      ##ENDIF_005

      ---------------------FINAL  EXECUTA QUERY 3 ABERTURA DE CURSOR  CUR_CTB220CQ3

      Fetch CUR_CTB220CQ3 into @cContaCQ3, @cCustoCQ3, @nDebitoCQ3, @nCreditCQ3,@nDebitoCQ7A,@nCreditCQ7A

      While ( @@fetch_status = 0 ) 
      BEGIN
      -- LACO EM CUR_CTB220CQ3

         SELECT @nTotDebCQ5A = 0
         SELECT @nTotCrdCQ5A = 0
         
         ------------------------------------------ EXECUTA QUERY 4 ATUALIZA @nTotDebCQ5A @nTotCrdCQ5A

         ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
            EXEC sp_executesql
               @cExecSql4,
               @cParams4,
               @cFilial_CQ5 = @cFilial_CQ5,
               @cContaCQ3 = @cContaCQ3,
               @cCustoCQ3 = @cCustoCQ3,
               @cMoeda = @cMoeda,
               @cTpSald = @cTpSald,
               @cData = @cData,
               @cDelete = @cDelete,
               @cFilial_CQ7 = @cFilial_CQ7,
               @nTotDebCQ5A = @nTotDebCQ5A OUTPUT,
               @nTotCrdCQ5A = @nTotCrdCQ5A OUTPUT
         ##ENDIF_001
         ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
            exec sp_executesql @cExecSql4
            /*INTO @nTotDebCQ5A, @nTotCrdCQ5A
            USING vcFilial_CQ5,vcContaCQ3,vcCustoCQ3,vcMoeda,IN_TPSALDO, vcData,vcDelete, vcFilial_CQ7,vcMoeda,IN_TPSALDO,vcData,vcDelete */
         ##ENDIF_005

         -------------------------------------FINAL EXECUTA QUERY 4 ATUALIZA @nTotDebCQ5A @nTotCrdCQ5A


         SELECT @nTotDebCQ3 = @nTotDebCQ3 + ( @nDebitoCQ3 - @nTotDebCQ5A - @nDebitoCQ7A )
         SELECT @nTotCrdCQ3 = @nTotCrdCQ3 + ( @nCreditCQ3 - @nTotCrdCQ5A - @nCreditCQ7A )
         Fetch CUR_CTB220CQ3 into @cContaCQ3, @cCustoCQ3, @nDebitoCQ3, @nCreditCQ3,@nDebitoCQ7A,@nCreditCQ7A
      END  -- FIM CQ3
      Close CUR_CTB220CQ3
      Deallocate CUR_CTB220CQ3
      
      ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES"})
         SELECT @troca_postgres = 0
      ##ENDIF_005

      SELECT @nTotDeb = ( @nDebito - @nDebitoCQ7 - @nTotDebCQ3 - @nTotDebCQ5 )
      SELECT @nTotCrd = ( @nCredit - @nCreditCQ7 - @nTotCrdCQ3 - @nTotCrdCQ5 )
      SELECT @nValor = @nTotCrd - @nTotDeb
      SELECT @iLinha1 = 1
      SELECT @lCriaLinha = '1'
      SELECT @nRTotCrd = Round(@nTotCrd, 2)
      SELECT @nRTotDeb = Round(@nTotDeb, 2)
      While @iLinha1 < 3 
      BEGIN
         IF ( @nRTotCrd  = @nRTotDeb ) and ( @nRTotCrd != 0  ) 
         BEGIN
            IF @iLinha1 = 1 
            BEGIN
               SELECT @nValor = @nTotCrd
               SELECT @iLinha1 = 2
            END 
            ELSE 
            BEGIN
               IF @iLinha1 = 2 
               BEGIN
                  SELECT @nValor = ( 0 - @nTotDeb )
                  SELECT @iLinha1 = 3
               END
            END
            SELECT @lPrim = '1'
            SELECT @lCriaLinha = '1'
         END 
         ELSE 
         BEGIN
            IF Round(@nValor, 2) != 0 
            BEGIN
               SELECT @lCriaLinha = '1'
            END 
            ELSE 
            BEGIN
               SELECT @lCriaLinha = '0'
            END
            SELECT @iLinha1 = 3
         END
         IF @lCriaLinha = '1' 
         BEGIN
            SELECT @iContador = 1
            IF ( @cFilial_CQ1 != @cFilAnt and (@cFilAnt is not null)) 
            BEGIN
               IF @cDoc = '999999' 
               BEGIN
                  SELECT @cAux1     = '0'
                  SELECT @cLoteAux  = @cLote
                  Exec MSSOMA1 @cLoteAux, @cAux1, @cLote OutPut
                  SELECT @cDoc = '000000'
               END
               SELECT @iLinha = 1
               SELECT @iAux   = Len( @cLinha )
               exec MSSTRZERO @iLinha, @iAux, @cLinha output
               SELECT @cAux1     = '0'
               SELECT @cDocAux   = @cDoc
               Exec MSSOMA1 @cDocAux, @cAux1, @cDoc OutPut
            END 
            ELSE 
            BEGIN
      	      IF @IN_LMOEDAESP = '1' 
               BEGIN
                  IF @iLinha = @iMaxLinha 
                  BEGIN
                     IF @cDoc = '999999' 
                     BEGIN
                        SELECT @cAux1     = '0'
                        SELECT @cLoteAux  = @cLote
                        Exec MSSOMA1 @cLoteAux, @cAux1, @cLote OutPut
                        SELECT @cDoc = '000000'
                     END
                     SELECT @iLinha = 1
                     SELECT @iAux   = Len( @cLinha )
                     exec MSSTRZERO @iLinha, @iAux, @cLinha output
                     SELECT @cDocAux   = @cDoc
                     Exec MSSOMA1 @cDocAux, @cAux1, @cDoc OutPut
                  END 
                  ELSE 
                  BEGIN
                     SELECT @cAux1     = '0'
                     SELECT @cLinhaAux = @cLinha
                     Exec MSSOMA1 @cLinhaAux, @cAux1, @cLinha OutPut
                     SELECT @iLinha = @iLinha + 1
                  END
               END 
               ELSE 
               BEGIN
                  IF ( @cDataAnt != @cData or @cContaAnt != @cConta ) or @lPrim  = '1' 
                  BEGIN
                     SELECT @lPrim = '0'
                     IF @iLinha = @iMaxLinha 
                     BEGIN
                        IF @cDoc = '999999' 
                        BEGIN
                           SELECT @cAux1     = '0'
                           SELECT @cLoteAux  = @cLote
                           Exec MSSOMA1 @cLoteAux, @cAux1, @cLote OutPut
                           SELECT @cDoc = '000000'
                        END
                        SELECT @iLinha = 1
                        SELECT @iAux   = Len( @cLinha )
                        exec MSSTRZERO @iLinha, @iAux, @cLinha output
                        SELECT @cDocAux   = @cDoc
                        Exec MSSOMA1 @cDocAux, @cAux1, @cDoc OutPut
                     END 
                     ELSE 
                     BEGIN
                        SELECT @cAux1     = '0'
                        SELECT @cLinhaAux = @cLinha
                        Exec MSSOMA1 @cLinhaAux, @cAux1, @cLinha OutPut
                        SELECT @iLinha = @iLinha + 1
                     END
                  END
               END
            END
            SELECT @cSeqLan = @cLinha
            IF @nValor < 0 
            BEGIN
               SELECT @cDc = '1'
               SELECT @cContaDeb = @cConta
               SELECT @cContaCrd = ' '
               SELECT @nValor    = @nValor * ( -1 )
            END 
            ELSE 
            BEGIN
               SELECT @cDc = '2'
               SELECT @cContaDeb = ' '
               SELECT @cContaCrd = @cConta
            END
            SELECT @iRecnoCTF = R_E_C_N_O_
               FROM CTF###
               Where CTF_FILIAL = @cFilial_CTF
                  and CTF_DATA   = @IN_DATA
                  and CTF_LOTE   = @cLote
                  and CTF_SBLOTE = @cSubLote
                  and CTF_DOC    = @cDoc
                  and D_E_L_E_T_ = ' '

            IF @iRecnoCTF is Null 
            BEGIN 
               
               -- GRAVACAO DE CTF
               SELECT @iRecnoCTF = 0
               SELECT @iRecnoCTF = COALESCE(Max( R_E_C_N_O_), 0) FROM CTF###
               SELECT @iRecnoCTF = @iRecnoCTF + 1
               
               ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
               INSERT INTO CTF### ( CTF_FILIAL,   CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, CTF_LINHA, R_E_C_N_O_ )
                           VALUES ( @cFilial_CTF, @IN_DATA, @cLote,   @cSubLote,  @cDoc,   @cLinha,   @iRecnoCTF )
               ##CHECK_TRANSACTION_COMMIT               
            END 
            ELSE 
            BEGIN
               Update CTF###
               Set CTF_LINHA = @cLinha
               Where R_E_C_N_O_ = @iRecnoCTF
            END
            IF @IN_LMOEDAESP   = '1' and @IN_MOEDA != '01' 
            BEGIN
               SELECT @cMoeda1 = '01'
               SELECT @nValor1 = 0
               SELECT @cCrConv = '5'
               
               -- GRAVACAO DE CT2
               SELECT @iRecno = 0
               SELECT @iRecno = COALESCE( Max( R_E_C_N_O_ ), 0 ) FROM CT2###
               SELECT @iRecno = @iRecno + 1

               ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
               INSERT INTO CT2### (CT2_FILIAL,   CT2_DATA,   CT2_LOTE,    CT2_SBLOTE, CT2_DOC,     CT2_LINHA,    CT2_MOEDLC, CT2_DC,
                                   CT2_DEBITO,   CT2_CREDIT, CT2_VALOR,   CT2_HIST,   CT2_EMPORI,  CT2_FILORI,   CT2_TPSALD, CT2_MANUAL,
                                   CT2_ROTINA,   CT2_AGLUT,  CT2_SEQHIS,  CT2_SEQLAN, CT2_CRCONV,  R_E_C_N_O_ )
                           VALUES (@cFilial_CT2, @IN_DATA,   @cLote,      @cSubLote,  @cDoc,       @cLinha,      @cMoeda1,    @cDc,
                                   @cContaDeb,   @cContaCrd, @nValor1,    @cHist,     @IN_EMPORI,  @cFilial_CQ1, @cTpSald, @cManual,
                                   @cRotina,     @cAglut,    @cSeqHis,    @cSeqLan,   @cCrConv,    @iRecno )
               ##CHECK_TRANSACTION_COMMIT               
            END
            SELECT @nValor = Round( @nValor, 2)
            SELECT @cCrConv   = '4'

            --GRAVACAO DE CT2
            SELECT @iRecno = 0
            SELECT @iRecno = COALESCE( Max( R_E_C_N_O_ ), 0 ) FROM CT2###
            SELECT @iRecno = @iRecno + 1
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            INSERT INTO CT2### (CT2_FILIAL,   CT2_DATA,   CT2_LOTE,    CT2_SBLOTE, CT2_DOC,     CT2_LINHA,    CT2_MOEDLC,  CT2_DC,
                                CT2_DEBITO,   CT2_CREDIT, CT2_VALOR,   CT2_HIST,   CT2_EMPORI,  CT2_FILORI,   CT2_TPSALD,  CT2_MANUAL,
                                CT2_ROTINA,   CT2_AGLUT,  CT2_SEQHIS,  CT2_SEQLAN, CT2_CRCONV,  R_E_C_N_O_ )
                        VALUES (@cFilial_CT2, @IN_DATA,   @cLote,      @cSubLote,  @cDoc,       @cLinha,      @cMoeda ,    @cDc,
                                @cContaDeb,   @cContaCrd, @nValor,     @cHist,     @IN_EMPORI,  @cFilial_CQ1, @cTpSald, @cManual,
                                @cRotina,     @cAglut,    @cSeqHis,    @cSeqLan,   @cCrConv,    @iRecno )
            ##CHECK_TRANSACTION_COMMIT            

            IF @IN_LCTBJOB = '1'
            BEGIN
               SELECT @iRecno = 0              
               SELECT @iRecno = COALESCE(Min(R_E_C_N_O_), 0) FROM CQA###
                     WHERE CQA_FILIAL = @cFilial_CQA AND
                           CQA_FILCT2 = @cFilial_CT2 AND
                           CQA_DATA   = @IN_DATA AND
                           CQA_LOTE   = @cLote AND
                           CQA_SBLOTE = @cSubLote AND
                           CQA_DOC    = @cDoc AND
                           CQA_LINHA  = @cLinha AND
                           CQA_TPSALD = @cTpSald AND
                           CQA_EMPORI = @IN_EMPORI AND
                           CQA_FILORI = @cFilial_CQ1 AND
                           CQA_MOEDLC = @cMoeda AND
                           D_E_L_E_T_ = ' ' 
            
               -- Só insiro o documento se ele já não estiver na fila
               IF @iRecno = 0 
               BEGIN
                  -- GRAVACAO DE CQA          
                  SELECT @iRecno = COALESCE(Max(R_E_C_N_O_), 0) FROM CQA###
                  SELECT @iRecno = @iRecno + 1
                  
                  ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                  INSERT INTO CQA### (CQA_FILIAL, CQA_FILCT2, CQA_DATA, CQA_LOTE, CQA_SBLOTE, CQA_DOC, CQA_LINHA, CQA_MOEDLC, CQA_EMPORI, CQA_FILORI, CQA_TPSALD, R_E_C_N_O_ )
                              VALUES (@cFilial_CQA, @cFilial_CT2, @IN_DATA, @cLote, @cSubLote, @cDoc, @cLinha, @cMoeda, @IN_EMPORI, @cFilial_CQ1, @cTpSald, @iRecno )
                  ##CHECK_TRANSACTION_COMMIT                  
               END              
            END
                  
         END
      END
      
      SELECT @cMoedaAnt = @cMoeda
      SELECT @cDataAnt  = @cData
      SELECT @cContaAnt = @cConta
      SELECT @cFilAnt   = @cFilial_CQ7
      SELECT @cTpSaldAnt = @cTpSald

      Fetch CUR_CTB220CQ1 into @cFilial_CQ1, @cMoeda, @cData, @cConta, @nDebito, @nCredit, @nDebitoCQ7 , @nCreditCQ7, @cTpSald 
      IF ( @cFilial_CQ1 != @cFilAnt or @cDataAnt != @cData or @cContaAnt != @cConta or @cTpSaldAnt != @cTpSald)  BEGIN
         SELECT @lPrim  = '1'
      END
   END
   Close CUR_CTB220CQ1
   Deallocate CUR_CTB220CQ1

   SELECT @OUT_LOTE = @cLote
   SELECT @OUT_DOC = @cDoc
   SELECT @OUT_CONT = @iContador
END 
