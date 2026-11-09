-- =============================================
-- Author:		TOTVS
-- Create date: 13/03/2026
-- Description:	Consolidacao Geral de Empresas
-- =============================================
CREATE PROCEDURE CTB220CCQ3_##
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
as 
Declare @cFilial_CT2 Char( 'CT2_FILIAL' )
Declare @cFilial_CQ3 Char( 'CQ3_FILIAL' )
Declare @cFilial_CQ5 Char( 'CQ5_FILIAL' )
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
Declare @cSubLote    Char( 'CT2_SBLOTE' )
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
Declare @cCusto      Char( 'CT2_CCD' )
Declare @cCustoDeb   Char( 'CT2_CCD' )
Declare @cCustoCrd   Char( 'CT2_CCD' )
Declare @cCustoAnt   Char( 'CT2_CCD' )
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
Declare @nDebitoCQ7  Float
Declare @nCreditCQ7  Float
Declare @nTotDebCQ5  Float
Declare @nTotCrdCQ5  Float
Declare @nTotDeb     Float
Declare @nTotCrd     Float
Declare @nRTotDeb    Float
Declare @nRTotCrd    Float
Declare @iLinha1     Integer
Declare @lCriaLinha  Char(01)
Declare @cDelete     CHAR(1) 
Declare @cValue1     CHAR(1)
Declare @cValue0     CHAR(1)
Declare @cAliasTable CHAR(3)
Declare @nBind       Integer


##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})   
   Declare @cPostgres3 CHAR( 1 )
   Declare @nfim_CUR FLOAT 
##ENDIF_003

##IF_004({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})     
   Declare @cOracle3 CHAR( 1 )
##ENDIF_004

Declare @cExecSql VARCHAR( 1 )
--query 2 
Declare @cExecSql2 VARCHAR( 1 )

##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
   Declare @cParams VARCHAR( 1 )
   Declare @cParams2 VARCHAR( 1 )
##ENDIF_004

BEGIN
   SELECT @cValue1 = '1'
   SELECT @cValue0 = '0'
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
   SELECT @cCustoAnt = ' '
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
   SELECT @nTotDeb   = 0
   SELECT @nTotCrd   = 0
   SELECT @OUT_LOTE  = ''
   SELECT @OUT_DOC   = ''
   SELECT @OUT_CONT  = @iContador
   SELECT @cExecSql  = ' '
   SELECT @cExecSql2 = ' '

   exec XFILIAL_## 'CT2', @IN_FILIALDEST, @cFilial_CT2 OutPut
   exec XFILIAL_## 'CTF', @IN_FILIALDEST, @cFilial_CTF OutPut


                              ------------------- QUERY  1 CURSOR PRINCIPAL --------

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = " Declare CUR_CTB220CQ3 insensitive  CURSOR FOR "
   ##ENDIF_001
   
   SELECT @cExecSql = @cExecSql || " SELECT "
   SELECT @cExecSql = @cExecSql || "   A.CQ3_FILIAL,A.CQ3_MOEDA,A.CQ3_DATA,A.CQ3_CONTA,A.CQ3_CCUSTO,A.nDebito_CQ3,A.nCredit_CQ3, "
   SELECT @cExecSql = @cExecSql || "   COALESCE(SUM(B.CQ7_DEBITO), 0) AS nDebito_CQ7, COALESCE(SUM(B.CQ7_CREDIT), 0) AS nCredit_CQ7, A.CQ3_TPSALD "
   SELECT @cExecSql = @cExecSql || "   FROM ( "
   SELECT @cExecSql = @cExecSql || "      SELECT "
   SELECT @cExecSql = @cExecSql || "         CQ3_FILIAL,CQ3_MOEDA,CQ3_DATA,CQ3_CONTA,CQ3_CCUSTO,SUM(CQ3_DEBITO)AS nDebito_CQ3, SUM(CQ3_CREDIT)AS nCredit_CQ3, CQ3_TPSALD "
   SELECT @cExecSql = @cExecSql || "         FROM CQ3" || @cAliasTable

   -----where  com tratamento para binding de parametros-------------------------------------------
   ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " WHERE D_E_L_E_T_ = @cDelete"
      
      SELECT @cExecSql = @cExecSql || " AND CQ3_FILIAL IN (SELECT TMP_FILIAL FROM  "|| @IN_FILIAIS ||" ) "
      
      SELECT @cExecSql = @cExecSql || " AND CQ3_DATA  <= @IN_DATA "
      
      IF @IN_TPSALDO != '*'
      BEGIN
         SELECT @cExecSql = @cExecSql || " AND CQ3_TPSALD = @IN_TPSALDO "
      END

      IF @IN_LMOEDAESP = '1'
      BEGIN 
         SELECT @cExecSql = @cExecSql || " AND CQ3_MOEDA = @IN_MOEDA "
      END
   ##ENDIF_002

   
   ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @nBind = 1
      SELECT @cExecSql = @cExecSql ||" WHERE D_E_L_E_T_ = $"|| @nBind_
            
      SELECT @cExecSql = @cExecSql ||" AND CQ3_FILIAL IN (SELECT TMP_FILIAL FROM  "|| @IN_FILIAIS ||" ) "
      
      SELECT @nBind = @nBind + 1
      SELECT @cExecSql = @cExecSql ||" AND CQ3_DATA <= $"|| @nBind_
      
      IF @IN_TPSALDO != '*'
      BEGIN
         SELECT @nBind = @nBind + 1
         SELECT @cExecSql = @cExecSql ||" AND CQ3_TPSALD = $"|| @nBind_
      END

      IF @IN_LMOEDAESP = '1'
      BEGIN 
         SELECT @nBind = @nBind + 1
         SELECT @cExecSql = @cExecSql || " AND CQ3_MOEDA = $"|| @nBind_
      END
   ##ENDIF_003

   SELECT @cExecSql = @cExecSql || " GROUP BY CQ3_FILIAL,CQ3_CONTA,CQ3_CCUSTO,CQ3_MOEDA,CQ3_DATA,CQ3_TPSALD) A "
   SELECT @cExecSql = @cExecSql || " LEFT JOIN CQ7" || @cAliasTable || " B ON "
   
   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " B.D_E_L_E_T_ = @cDelete "
   ##ENDIF_004
   
   ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})      
      SELECT @nBind = @nBind + 1
      SELECT @cExecSql = @cExecSql || " B.D_E_L_E_T_ = $"|| @nBind_
   ##ENDIF_005
   
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_FILIAL = A.CQ3_FILIAL "
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_CONTA  = A.CQ3_CONTA "
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_CCUSTO = A.CQ3_CCUSTO "
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_MOEDA  = A.CQ3_MOEDA "
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_TPSALD = A.CQ3_TPSALD "
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_DATA   = A.CQ3_DATA "
   SELECT @cExecSql = @cExecSql || " GROUP BY A.CQ3_FILIAL,A.CQ3_CONTA,A.CQ3_CCUSTO,A.CQ3_DATA,A.CQ3_MOEDA,A.nDebito_CQ3,A.nCredit_CQ3, A.CQ3_TPSALD "
   SELECT @cExecSql = @cExecSql || " ORDER BY 1, 4, 5, 2, 3 "

   ----ABERTURA DO CURSOR----------------
   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " FOR READ ONLY "
      SELECT @cParams = "@cDelete CHAR(1), @IN_DATA Char( 08 ) "
      
      IF @IN_LMOEDAESP = '1'
      BEGIN 
         IF @IN_TPSALDO != '*'     
         BEGIN 
            SELECT @cParams = @cParams || ", @IN_TPSALDO Char( TROCACT2_TPSALD ), @IN_MOEDA Char( TROCACT2_MOEDLC )"
            exec sp_executesql 
               @cExecSql,
               @cParams,@cDelete,@IN_DATA,@IN_TPSALDO,@IN_MOEDA
            OPEN CUR_CTB220CQ3
         END
         ELSE
         BEGIN
            SELECT @cParams = @cParams || ", @IN_MOEDA Char( TROCACT2_MOEDLC )"
            exec sp_executesql 
               @cExecSql,
               @cParams,@cDelete,@IN_DATA,@IN_MOEDA
            OPEN CUR_CTB220CQ3
         END
      END
      ELSE
      BEGIN
         IF @IN_TPSALDO != '*'     
         BEGIN 
            SELECT @cParams = @cParams || ", @IN_TPSALDO Char( TROCACT2_TPSALD )"
            exec sp_executesql 
               @cExecSql,
               @cParams,@cDelete,@IN_DATA,@IN_TPSALDO
            OPEN CUR_CTB220CQ3            
         END
         ELSE
         BEGIN
            exec sp_executesql 
               @cExecSql,
               @cParams,@cDelete,@IN_DATA
            OPEN CUR_CTB220CQ3
         END
      END
   ##ENDIF_004

   ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      IF @IN_LMOEDAESP = '1'
      BEGIN 
         IF @IN_TPSALDO != '*'     
         BEGIN 
            OPEN CUR_CTB220CQ31
            --USING @cDelete,@IN_DATA,@IN_TPSALDO,@IN_MOEDA,@cDelete
         END
         ELSE
         BEGIN
            OPEN CUR_CTB220CQ32
            --USING @cDelete,@IN_DATA,@IN_MOEDA,@cDelete
         END
      END
      ELSE
      BEGIN
         IF @IN_TPSALDO != '*'     
         BEGIN
            OPEN CUR_CTB220CQ33
            --USING @cDelete,@IN_DATA,@IN_TPSALDO,@cDelete
         END
         ELSE
         BEGIN
            OPEN CUR_CTB220CQ34
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
      SELECT @cExecSql2 = @cExecSql2 || " and CQ5_CONTA  = @cConta and CQ5_CCUSTO = @cCusto and CQ5_MOEDA  = @cMoeda and CQ5_TPSALD = @IN_TPSALDO and CQ5_DATA = @cData "
   ##ENDIF_001
   ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @cExecSql2 = @cExecSql2 || " C Where D_E_L_E_T_ = $1 and CQ5_FILIAL = $2 "
      SELECT @cExecSql2 = @cExecSql2 || " and CQ5_CONTA  = $3 and CQ5_CCUSTO = $4 and CQ5_MOEDA = $5 and CQ5_TPSALD = $6 and CQ5_DATA = $7 "
   ##ENDIF_002

   SELECT @cExecSql2 = @cExecSql2 || " Group By CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM  ) Q5 LEFT JOIN ( "
   SELECT @cExecSql2 = @cExecSql2 || " SELECT CQ7_CONTA,CQ7_CCUSTO,CQ7_ITEM, COALESCE(SUM(CQ7_DEBITO),0) AS nDebito_CQ7, "
   SELECT @cExecSql2 = @cExecSql2 || " COALESCE(SUM(CQ7_CREDIT),0)  AS nCredit_CQ7 FROM CQ7" || @cAliasTable

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql2 = @cExecSql2 || " WHERE D_E_L_E_T_ = @cDelete AND CQ7_FILIAL = @cFilial_CQ7 "
      SELECT @cExecSql2 = @cExecSql2 || " AND CQ7_MOEDA  = @cMoeda AND CQ7_TPSALD = @IN_TPSALDO AND CQ7_DATA   = @cData "
   ##ENDIF_001
   ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
      SELECT @cExecSql2 = @cExecSql2 || " WHERE D_E_L_E_T_ = $8 AND CQ7_FILIAL = $9 "
      SELECT @cExecSql2 = @cExecSql2 || " AND CQ7_MOEDA  = $10 AND CQ7_TPSALD = $11 AND CQ7_DATA = $12 "
   ##ENDIF_002
   
   SELECT @cExecSql2 = @cExecSql2 || " GROUP BY CQ7_CONTA,CQ7_CCUSTO,CQ7_ITEM) Q7 "
   SELECT @cExecSql2 = @cExecSql2 || " ON  Q7.CQ7_CONTA  = Q5.CQ5_CONTA AND Q7.CQ7_CCUSTO = Q5.CQ5_CCUSTO AND Q7.CQ7_ITEM   = Q5.CQ5_ITEM "
   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cParams2 = "@cDelete Char(1), @cFilial_CQ5 CHAR( TROCACQ7_FILIAL ), @cConta CHAR( TROCACT2_CONTA ), "
      SELECT @cParams2 = @cParams2 || " @cCusto CHAR( TROCACT2_CCD ), "
      SELECT @cParams2 = @cParams2 || "   @cMoeda Char( TROCACT2_MOEDLC ),@cFilial_CQ7 CHAR( TROCACQ7_FILIAL ),@IN_TPSALDO Char( TROCACT2_TPSALD ), "
      SELECT @cParams2 = @cParams2 || "   @cData Char( 08 ), @nTotDebCQ5 FLOAT OUTPUT, @nTotCrdCQ5 FLOAT OUTPUT  "   
   ##ENDIF_004                              
                                       
                     ----------------------FINAL  QUERY 2 ATUALIZA @nTotDebCQ5 E @nTotCrdCQ5 -------------------


   ------------------- ABERTURA CURSOR PRINCIPAL QUERY1 -------------------
   Fetch CUR_CTB220CQ3 into @cFilial_CQ3, @cMoeda, @cData, @cConta, @cCusto, @nDebito, @nCredit, @nDebitoCQ7, @nCreditCQ7, @cTpSald

   While ( @@fetch_status = 0 ) 
   BEGIN 
      exec XFILIAL_## 'CQ7', @cFilial_CQ3, @cFilial_CQ7 OutPut
      exec XFILIAL_## 'CQ5', @cFilial_CQ3, @cFilial_CQ5 OutPut
      exec XFILIAL_## 'CQA', @cFilial_CQ3, @cFilial_CQA OutPut

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
            @cCusto = @cCusto,
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
         USING vcDelete,vcFilial_CQ5,vcConta,vcCusto, vcMoeda,vcTpSald, vcData,vcDelete,vcFilial_CQ7,vcMoeda,vcTpSald,vcData*/
      ##ENDIF_005

                   ------------------- FIM EXECUCAO QUERY 2

      SELECT @nTotDeb = @nDebito - @nDebitoCQ7 - @nTotDebCQ5
      SELECT @nTotCrd = @nCredit - @nCreditCQ7 - @nTotCrdCQ5
      SELECT @nValor = ( @nTotCrd - @nTotDeb )
      SELECT @iLinha1 = 1
      SELECT @lCriaLinha = '1'
      SELECT @nRTotDeb = Round(@nTotDeb, 2)
      SELECT @nRTotCrd = Round(@nTotCrd, 2) 
      While @iLinha1 < 3 
      BEGIN
         IF ( @nRTotCrd = @nRTotDeb ) and ( @nRTotCrd != 0  ) 
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
            IF ( @cFilial_CQ3 != @cFilAnt and (@cFilAnt is not null)) 
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
                  IF ( @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto ) or @lPrim  = '1' 
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
               SELECT @cCustoDeb = @cCusto
               SELECT @cCustoCrd = ' '
               SELECT @nValor    = @nValor * ( -1 )
            END 
            ELSE 
            BEGIN
               SELECT @cDc = '2'
               SELECT @cContaDeb = ' '
               SELECT @cContaCrd = @cConta
               SELECT @cCustoDeb = ' '
               SELECT @cCustoCrd = @cCusto
            END

            SELECT @iRecnoCTF = 0
            SELECT @iRecnoCTF = COALESCE(Min(R_E_C_N_O_), 0)
               FROM CTF###
               Where CTF_FILIAL = @cFilial_CTF
                  and CTF_DATA   = @IN_DATA
                  and CTF_LOTE   = @cLote
                  and CTF_SBLOTE = @cSubLote
                  and CTF_DOC    = @cDoc
                  and D_E_L_E_T_ = ' '

            IF @iRecnoCTF = 0
            BEGIN 
               -- GRAVACAO DE CTF###
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
               
               -- GRAVACAO DE CT2###
               SELECT @iRecno = 0
               SELECT @iRecno = COALESCE( Max( R_E_C_N_O_ ), 0 ) FROM CT2###
               SELECT @iRecno = @iRecno + 1
               
               ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
               INSERT INTO CT2### (CT2_FILIAL,   CT2_DATA,   CT2_LOTE,    CT2_SBLOTE, CT2_DOC,     CT2_LINHA,    CT2_MOEDLC, CT2_DC,
                                   CT2_DEBITO,   CT2_CREDIT, CT2_VALOR,   CT2_HIST,   CT2_CCD,     CT2_CCC,      CT2_EMPORI,  CT2_FILORI,
                                   CT2_TPSALD,   CT2_MANUAL, CT2_ROTINA,  CT2_AGLUT,  CT2_SEQHIS,  CT2_SEQLAN,   CT2_CRCONV,  R_E_C_N_O_ )
                           VALUES (@cFilial_CT2, @IN_DATA,   @cLote,      @cSubLote,  @cDoc,       @cLinha,      @cMoeda1,    @cDc,
                                   @cContaDeb,   @cContaCrd, @nValor1,    @cHist,     @cCustoDeb,  @cCustoCrd,   @IN_EMPORI,  @cFilial_CQ3,
                                   @cTpSald,     @cManual,   @cRotina,    @cAglut,    @cSeqHis,    @cSeqLan,     @cCrConv,    @iRecno )
               ##CHECK_TRANSACTION_COMMIT               
            END
            
            SELECT @nValor = Round( @nValor, 2)
            SELECT @cCrConv   = '4'

            -- GRAVACAO DE CT2###
            SELECT @iRecno = 0
            SELECT @iRecno = COALESCE( Max( R_E_C_N_O_ ), 0) FROM CT2###
            SELECT @iRecno = @iRecno + 1
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            INSERT INTO CT2### (CT2_FILIAL,   CT2_DATA,   CT2_LOTE,    CT2_SBLOTE, CT2_DOC,     CT2_LINHA,    CT2_MOEDLC,  CT2_DC,
                                CT2_DEBITO,   CT2_CREDIT, CT2_VALOR,   CT2_HIST,   CT2_CCD,     CT2_CCC,      CT2_EMPORI,  CT2_FILORI,
                                CT2_TPSALD,   CT2_MANUAL, CT2_ROTINA,  CT2_AGLUT,  CT2_SEQHIS,  CT2_SEQLAN,   CT2_CRCONV,  R_E_C_N_O_ )
                        VALUES (@cFilial_CT2, @IN_DATA,   @cLote,      @cSubLote,  @cDoc,       @cLinha,      @cMoeda ,    @cDc,
                                @cContaDeb,   @cContaCrd, @nValor,     @cHist,     @cCustoDeb,  @cCustoCrd,   @IN_EMPORI,  @cFilial_CQ3,
                                @cTpSald,     @cManual,   @cRotina,    @cAglut,    @cSeqHis,    @cSeqLan,     @cCrConv,    @iRecno )
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
                        CQA_FILORI = @cFilial_CQ3 AND
                        CQA_MOEDLC = @cMoeda AND
                        D_E_L_E_T_ = ' ' 

               -- Só insiro o documento se ele já não estiver na fila
               IF @iRecno = 0 
               BEGIN
                  -- GRAVACAO DE CQA###
                  SELECT @iRecno = COALESCE(Max(R_E_C_N_O_), 0) FROM CQA###
                  SELECT @iRecno = @iRecno + 1

                  ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                  INSERT INTO CQA### (CQA_FILIAL, CQA_FILCT2, CQA_DATA, CQA_LOTE, CQA_SBLOTE, CQA_DOC, CQA_LINHA, CQA_MOEDLC, CQA_EMPORI, CQA_FILORI, CQA_TPSALD, R_E_C_N_O_ )
                              VALUES (@cFilial_CQA, @cFilial_CT2, @IN_DATA, @cLote, @cSubLote, @cDoc, @cLinha, @cMoeda, @IN_EMPORI, @cFilial_CQ3, @cTpSald, @iRecno )
                  ##CHECK_TRANSACTION_COMMIT                  
               END
            END
         END
      END
      SELECT @cMoedaAnt = @cMoeda
      SELECT @cDataAnt  = @cData
      SELECT @cContaAnt = @cConta
      SELECT @cCustoAnt = @cCusto
      SELECT @cFilAnt   = @cFilial_CQ3
      SELECT @cTpSaldAnt = @cTpSald

      Fetch CUR_CTB220CQ3 into @cFilial_CQ3, @cMoeda, @cData, @cConta, @cCusto, @nDebito, @nCredit, @nDebitoCQ7, @nCreditCQ7, @cTpSald
      IF ( @cFilial_CQ3 != @cFilAnt or @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto or @cTpSaldAnt != @cTpSald )  BEGIN
         SELECT @lPrim  = '1'
      END
   END
   Close CUR_CTB220CQ3
   Deallocate CUR_CTB220CQ3

   SELECT @OUT_LOTE = @cLote
   SELECT @OUT_DOC = @cDoc
   SELECT @OUT_CONT = @iContador
END
