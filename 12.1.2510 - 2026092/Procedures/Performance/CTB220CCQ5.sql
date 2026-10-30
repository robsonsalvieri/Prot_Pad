-- =============================================
-- Author:		TOTVS
-- Create date: 13/03/2026
-- Description:	Consolidacao Geral de Empresas
-- =============================================
CREATE PROCEDURE CTB220CCQ5_##
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
Declare @cFilial_CTF Char( 'CTF_FILIAL' )
Declare @cFilial_CQ7 Char( 'CQ7_FILIAL' )
Declare @cFilial_CQ5 Char( 'CQ5_FILIAL' )
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
Declare @cItem       Char( 'CT2_ITEMD' )
Declare @cItemDeb    Char( 'CT2_ITEMD' )
Declare @cItemCrd    Char( 'CT2_ITEMD' )
Declare @cItemAnt    Char( 'CT2_ITEMD' )
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
Declare @nTotDeb     Float
Declare @nTotCrd     Float
Declare @nRTotDeb    Float
Declare @nRTotCrd    Float
Declare @iLinha1     Integer
Declare @lCriaLinha  Char(01)

Declare @cAliasTable CHAR(3)
DECLARE @cExecSql VARCHAR( 1 )
##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
   DECLARE @cPostgres1 CHAR( 1 )
   DECLARE @nfim_CUR FLOAT 
##ENDIF_003

##IF_004({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})  
   DECLARE @cOracle1 CHAR( 1 )
##ENDIF_004

BEGIN
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
   SELECT @cItemAnt  = ' '
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
   
   exec XFILIAL_## 'CT2', @IN_FILIALDEST, @cFilial_CT2 OutPut
   exec XFILIAL_## 'CTF', @IN_FILIALDEST, @cFilial_CTF OutPut
   exec XFILIAL_## 'CQA', @IN_FILIALDEST, @cFilial_CQA OutPut
   
   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = " Declare CUR_CTB220CQ5 insensitive  CURSOR FOR "
   ##ENDIF_001
   SELECT @cExecSql = @cExecSql || " SELECT A.CQ5_FILIAL, A.CQ5_MOEDA, A.CQ5_DATA, A.CQ5_CONTA, A.CQ5_CCUSTO, A.CQ5_ITEM, "
   SELECT @cExecSql = @cExecSql || " COALESCE(Sum(CQ5_DEBITO),0) AS DEB_CQ5, COALESCE(Sum(CQ5_CREDIT),0) AS CRD_CQ5, "
   SELECT @cExecSql = @cExecSql || " COALESCE(SUM(B.TOT_DEB_CQ7),0) AS DEB_CQ7, COALESCE(SUM(B.TOT_CRED_CQ7),0) AS CRD_CQ7, "
   SELECT @cExecSql = @cExecSql || " A.CQ5_TPSALD "
   SELECT @cExecSql = @cExecSql || " FROM CQ5" || @cAliasTable || " A "
   SELECT @cExecSql = @cExecSql || " LEFT JOIN ( SELECT CQ7_FILIAL,CQ7_CONTA,CQ7_CCUSTO,CQ7_ITEM,CQ7_MOEDA,CQ7_DATA,COALESCE(SUM(CQ7_DEBITO),0) AS TOT_DEB_CQ7, "
   SELECT @cExecSql = @cExecSql || " COALESCE(SUM(CQ7_CREDIT),0) AS TOT_CRED_CQ7, CQ7_TPSALD FROM CQ7" || @cAliasTable || " WHERE "
   SELECT @cExecSql = @cExecSql || " D_E_L_E_T_ = ''" 
   SELECT @cExecSql = @cExecSql || " '' AND CQ7_TPSALD = ''" 
   SELECT @cExecSql = @cExecSql ||  @IN_TPSALDO 
   SELECT @cExecSql = @cExecSql || "'' "
   SELECT @cExecSql = @cExecSql || " GROUP BY CQ7_FILIAL,CQ7_CONTA,CQ7_CCUSTO,CQ7_ITEM,CQ7_MOEDA,CQ7_DATA,CQ7_TPSALD) B "
   SELECT @cExecSql = @cExecSql || " ON  B.CQ7_FILIAL = A.CQ5_FILIAL AND B.CQ7_CONTA = A.CQ5_CONTA AND B.CQ7_CCUSTO = A.CQ5_CCUSTO "
   SELECT @cExecSql = @cExecSql || " AND B.CQ7_ITEM = A.CQ5_ITEM AND B.CQ7_MOEDA = A.CQ5_MOEDA AND B.CQ7_DATA = A.CQ5_DATA "
   SELECT @cExecSql = @cExecSql || " WHERE  A.D_E_L_E_T_ = ''"
   SELECT @cExecSql = @cExecSql || " '' AND CQ5_FILIAL IN (SELECT TMP_FILIAL FROM "|| @IN_FILIAIS ||" ) AND CQ5_DATA <= ''"
   SELECT @cExecSql = @cExecSql || @IN_DATA 
   SELECT @cExecSql = @cExecSql || "'' "
   
   IF @IN_TPSALDO != '*'
   BEGIN
      SELECT @cExecSql = @cExecSql || " AND CQ5_TPSALD = ''"
      SELECT @cExecSql = @cExecSql || @IN_TPSALDO 
      SELECT @cExecSql = @cExecSql || "'' "
   END
       
   IF @IN_LMOEDAESP = '1'
   BEGIN 
      SELECT @cExecSql = @cExecSql || " AND CQ5_MOEDA = ''"
      SELECT @cExecSql = @cExecSql || @IN_MOEDA 
      SELECT @cExecSql = @cExecSql || "'' "
   END

   SELECT @cExecSql = @cExecSql || " Group By A.CQ5_FILIAL,A.CQ5_CONTA,A.CQ5_CCUSTO,A.CQ5_ITEM,A.CQ5_DATA,A.CQ5_MOEDA,A.CQ5_TPSALD "
   SELECT @cExecSql = @cExecSql || " Order By A.CQ5_FILIAL,A.CQ5_CONTA,A.CQ5_CCUSTO,A.CQ5_ITEM,A.CQ5_DATA,A.CQ5_MOEDA,A.CQ5_TPSALD "


   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " FOR READ ONLY "
      exec sp_executesql @cExecSql
   ##ENDIF_001
   
   Open CUR_CTB220CQ5
   Fetch CUR_CTB220CQ5 INTO @cFilial_CQ5, @cMoeda, @cData, @cConta, @cCusto, @cItem, @nDebito, @nCredit, @nDebitoCQ7, @nCreditCQ7, @cTpSald

   While ( @@fetch_status = 0 ) BEGIN

      SELECT @nTotDeb =  @nDebito - @nDebitoCQ7 
      SELECT @nTotCrd =  @nCredit - @nCreditCQ7 
      SELECT @nValor  = ( @nTotCrd - @nTotDeb )

      SELECT @nRTotDeb = Round(@nTotDeb, 2)
      SELECT @nRTotCrd = Round(@nTotCrd, 2) 
      SELECT @iLinha1 = 1
      SELECT @lCriaLinha = '1'
      While @iLinha1 < 3 BEGIN
         If ( @nRTotCrd  = @nRTotDeb ) AND ( @nRTotCrd != 0  ) BEGIN
            If @iLinha1 = 1 BEGIN
               SELECT @nValor = @nTotCrd
               SELECT @iLinha1 = 2
            END ELSE BEGIN
               If @iLinha1 = 2 BEGIN
                  SELECT @nValor = ( 0 - @nTotDeb )
                  SELECT @iLinha1 = 3
               END
            END
            SELECT @lPrim = '1' 
            SELECT @lCriaLinha = '1'
         END ELSE BEGIN
            If Round(@nValor, 2) != 0 BEGIN
               SELECT @lCriaLinha = '1'
            END ELSE BEGIN
               SELECT @lCriaLinha = '0'
            END
            SELECT @iLinha1 = 3
         END
         If @lCriaLinha = '1' 
         BEGIN
            SELECT @iContador = 1 
            If ( @cFilial_CQ5 != @cFilAnt AND (@cFilAnt is not null) ) 
            BEGIN
               If @cDoc = '999999' 
               BEGIN
                  SELECT @cAux1     = '0'
                  SELECT @cLoteAux  = @cLote
                  Exec MSSOMA1  @cLoteAux, @cAux1, @cLote OutPut
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
               If @IN_LMOEDAESP = '1' 
               BEGIN
                  If @iLinha = @iMaxLinha 
                  BEGIN
                     If @cDoc = '999999' 
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
                  If ( @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto or @cItemAnt != @cItem) or @lPrim  = '1' 
                  BEGIN
                     SELECT @lPrim = '0'
                     If @iLinha = @iMaxLinha 
                     BEGIN
                        If @cDoc = '999999' 
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
            If @nValor < 0 
            BEGIN
               SELECT @cDc = '1'
               SELECT @cContaDeb = @cConta
               SELECT @cContaCrd = ' '
               SELECT @cCustoDeb = @cCusto
               SELECT @cCustoCrd = ' '
               SELECT @cItemDeb  = @cItem
               SELECT @cItemCrd  = ' '
               SELECT @nValor    = @nValor * ( -1 )
            END 
            ELSE 
            BEGIN
               SELECT @cDc = '2'
               SELECT @cContaDeb = ' '
               SELECT @cContaCrd = @cConta
               SELECT @cCustoDeb = ' '
               SELECT @cCustoCrd = @cCusto
               SELECT @cItemDeb  = ' '
               SELECT @cItemCrd  = @cItem
            END
            SELECT @iRecnoCTF = 0
            SELECT @iRecnoCTF = COALESCE(Min(R_E_C_N_O_), 0)
               FROM CTF###
               WHERE CTF_FILIAL = @cFilial_CTF
                  AND CTF_DATA   = @IN_DATA
                  AND CTF_LOTE   = @cLote
                  AND CTF_SBLOTE = @cSubLote
                  AND CTF_DOC    = @cDoc
                  AND D_E_L_E_T_ = ' '

            If @iRecnoCTF = 0
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
               WHERE R_E_C_N_O_ = @iRecnoCTF
            END
            If @IN_LMOEDAESP = '1' AND @IN_MOEDA != '01' 
            BEGIN
               SELECT @cMoeda1 = '01'
               SELECT @nValor1 = 0
               SELECT @cCrConv   = '5'

               -- GRAVACAO DE CT2###
               SELECT @iRecno = 0
               SELECT @iRecno = COALESCE( Max( R_E_C_N_O_ ), 0 ) FROM CT2###
               SELECT @iRecno = @iRecno + 1

               ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
               INSERT INTO CT2### (CT2_FILIAL,   CT2_DATA,     CT2_LOTE,    CT2_SBLOTE, CT2_DOC,    CT2_LINHA,  CT2_MOEDLC, CT2_DC,
                                   CT2_DEBITO,   CT2_CREDIT,   CT2_VALOR,   CT2_HIST,   CT2_CCD,    CT2_CCC,    CT2_ITEMD,  CT2_ITEMC,
                                   CT2_EMPORI,   CT2_FILORI,   CT2_TPSALD,  CT2_MANUAL, CT2_ROTINA, CT2_AGLUT,
                                   CT2_SEQHIS,   CT2_SEQLAN,   CT2_CRCONV,  R_E_C_N_O_ )
                           VALUES (@cFilial_CT2, @IN_DATA,     @cLote,      @cSubLote,  @cDoc,      @cLinha,    @cMoeda1,   @cDc,
                                   @cContaDeb,   @cContaCrd,   @nValor1,    @cHist,     @cCustoDeb, @cCustoCrd, @cItemDeb,  @cItemCrd,
                                   @IN_EMPORI,   @cFilial_CQ5, @cTpSald,    @cManual,   @cRotina,   @cAglut,
                                   @cSeqHis,     @cSeqLan,     @cCrConv,    @iRecno )
               ##CHECK_TRANSACTION_COMMIT               
            END
            SELECT @nValor = Round( @nValor, 2)
            SELECT @cCrConv   = '4'

            -- GRAVACAO DE CT2###
            SELECT @iRecno = 0
            SELECT @iRecno = COALESCE( Max( R_E_C_N_O_ ), 0 ) FROM CT2###
            SELECT @iRecno = @iRecno + 1
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            INSERT INTO CT2### (CT2_FILIAL,   CT2_DATA,     CT2_LOTE,    CT2_SBLOTE, CT2_DOC,    CT2_LINHA,  CT2_MOEDLC, CT2_DC,
                                CT2_DEBITO,   CT2_CREDIT,   CT2_VALOR,   CT2_HIST,   CT2_CCD,    CT2_CCC,    CT2_ITEMD,  CT2_ITEMC,
                                CT2_EMPORI,   CT2_FILORI,   CT2_TPSALD,  CT2_MANUAL, CT2_ROTINA, CT2_AGLUT,
                                CT2_SEQHIS,   CT2_SEQLAN,   CT2_CRCONV,  R_E_C_N_O_ )
                        VALUES (@cFilial_CT2, @IN_DATA,     @cLote,      @cSubLote,  @cDoc,      @cLinha,    @cMoeda,    @cDc,
                                @cContaDeb,   @cContaCrd,   @nValor,     @cHist,     @cCustoDeb, @cCustoCrd, @cItemDeb,  @cItemCrd,
                                @IN_EMPORI,   @cFilial_CQ5, @cTpSald,    @cManual,   @cRotina,   @cAglut,
                                @cSeqHis,     @cSeqLan,     @cCrConv,    @iRecno )
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
                     CQA_FILORI = @cFilial_CQ5 AND
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
                              VALUES (@cFilial_CQA, @cFilial_CT2, @IN_DATA, @cLote, @cSubLote, @cDoc, @cLinha, @cMoeda, @IN_EMPORI, @cFilial_CQ5, @cTpSald, @iRecno )
                  ##CHECK_TRANSACTION_COMMIT
               END
            END           
         END
      END
      SELECT @cMoedaAnt = @cMoeda
      SELECT @cDataAnt  = @cData
      SELECT @cContaAnt = @cConta
      SELECT @cCustoAnt = @cCusto
      SELECT @cItemAnt  = @cItem
      SELECT @cFilAnt   = @cFilial_CQ5
      SELECT @cTpSaldAnt = @cTpSald

      Fetch CUR_CTB220CQ5 INTO @cFilial_CQ5, @cMoeda, @cData, @cConta, @cCusto, @cItem, @nDebito, @nCredit, @nDebitoCQ7, @nCreditCQ7, @cTpSald
      
      If ( @cFilial_CQ5 != @cFilAnt or @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto or @cItemAnt != @cItem or @cTpSald != @cTpSaldAnt) 
      BEGIN
         SELECT @lPrim  = '1'
      END
   END
   Close CUR_CTB220CQ5
   Deallocate CUR_CTB220CQ5

   SELECT @OUT_LOTE = @cLote
   SELECT @OUT_DOC = @cDoc
   SELECT @OUT_CONT = @iContador
END 

