-- =============================================
-- Author:		TOTVS
-- Create date: 13/03/2026
-- Description:	Consolidacao Geral de Empresas
-- =============================================
CREATE PROCEDURE CTB220CCQ7_##
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
Declare @cClvl       Char( 'CT2_CLVLDB' )
Declare @cClvlDeb    Char( 'CT2_CLVLDB' )
Declare @cClvlCrd    Char( 'CT2_CLVLDB' )
Declare @cClvlAnt    Char( 'CT2_CLVLDB' )
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
Declare @nRCredit    Float
Declare @nRDebito    Float
Declare @iLinha1     Integer
Declare @lCriaLinha  Char(01)

Declare @cAliasTable CHAR(3)
Declare @cExecSql VARCHAR( 1 )

##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
   Declare @cPostgres1 CHAR( 1 )
   Declare @nfim_CUR FLOAT 
##ENDIF_003

##IF_004({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})  
   Declare @cOracle1 CHAR( 1 )
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
   SELECT @cClvlAnt  = ' '
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
   SELECT @cExecSql  = ' '

   exec XFILIAL_## 'CT2', @IN_FILIALDEST, @cFilial_CT2 OutPut
   exec XFILIAL_## 'CTF', @IN_FILIALDEST, @cFilial_CTF OutPut
   exec XFILIAL_## 'CQA', @IN_FILIALDEST, @cFilial_CQA OutPut


                              ------------------- QUERY CURSOR --------

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = " Declare CUR_Ctb220CQ7 insensitive  CURSOR FOR "
   ##ENDIF_001
   SELECT @cExecSql = @cExecSql || " SELECT CQ7_FILIAL,CQ7_MOEDA,CQ7_DATA,CQ7_CONTA,CQ7_CCUSTO,CQ7_ITEM,CQ7_CLVL,SUM(CQ7_DEBITO)AS nDebito_CQ7, SUM(CQ7_CREDIT)AS nCredit_CQ7, CQ7_TPSALD FROM CQ7" || @cAliasTable
   SELECT @cExecSql = @cExecSql || " WHERE D_E_L_E_T_ = ''"
   SELECT @cExecSql = @cExecSql || " "
   SELECT @cExecSql = @cExecSql || "'' AND CQ7_FILIAL IN (SELECT TMP_FILIAL FROM  "|| @IN_FILIAIS ||" ) AND CQ7_DATA  <= ''"
   SELECT @cExecSql = @cExecSql || @IN_DATA
   SELECT @cExecSql = @cExecSql || "'' "
   
   IF @IN_TPSALDO != '*'
   BEGIN
      SELECT @cExecSql = @cExecSql || " AND CQ7_TPSALD = ''"
      SELECT @cExecSql = @cExecSql || @IN_TPSALDO 
      SELECT @cExecSql = @cExecSql || "'' "
   END
   
   IF @IN_LMOEDAESP = '1'
   BEGIN 
      SELECT @cExecSql = @cExecSql || " AND CQ7_MOEDA = ''"
      SELECT @cExecSql = @cExecSql || @IN_MOEDA 
      SELECT @cExecSql = @cExecSql || "'' "
   END

   SELECT @cExecSql = @cExecSql || " GROUP BY CQ7_FILIAL,CQ7_CONTA,CQ7_CCUSTO,CQ7_ITEM,CQ7_CLVL,CQ7_DATA,CQ7_MOEDA,CQ7_TPSALD "
   SELECT @cExecSql = @cExecSql || " ORDER BY 1, 4, 5, 6, 7, 3, 2 "

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " FOR READ ONLY "
      exec sp_executesql @cExecSql
   ##ENDIF_001

   Open CUR_Ctb220CQ7
   Fetch CUR_Ctb220CQ7 into @cFilial_CQ7, @cMoeda, @cData, @cConta, @cCusto, @cItem, @cClvl, @nDebito, @nCredit, @cTpSald

   While ( @@fetch_status = 0 ) 
   BEGIN 
      SELECT @nValor = @nCredit - @nDebito
      SELECT @iLinha1 = 1
      SELECT @lCriaLinha = '1'
      SELECT @nRDebito = Round(@nDebito, 2) 
      SELECT @nRCredit = Round(@nCredit, 2) 
      While @iLinha1 < 3 
      BEGIN
         IF ( @nRCredit  = @nRDebito ) and ( @nRCredit != 0  ) 
         BEGIN
            IF @iLinha1 = 1 
            BEGIN
               SELECT @nValor = @nCredit
               SELECT @iLinha1 = 2
            END 
            ELSE 
            BEGIN
               IF @iLinha1 = 2 
               BEGIN
                  SELECT @nValor = ( 0 - @nDebito )
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
            IF ( @cFilial_CQ7 != @cFilAnt and (@cFilAnt is not null)) 
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
                        SELECT @cAux1 = '0'
                        SELECT @cLoteAux  = @cLote
                        Exec MSSOMA1 @cLoteAux, @cAux1, @cLote OutPut
                        SELECT @cDoc = '000000'
                     END
                     SELECT @iLinha = 1
                     SELECT @iAux = Len( @cLinha )
                     exec MSSTRZERO @iLinha, @iAux, @cLinha output
                     SELECT @cDocAux = @cDoc
                     Exec MSSOMA1 @cDocAux, @cAux1, @cDoc OutPut
                  END 
                  ELSE 
                  BEGIN
                     SELECT @cAux1 = '0'
                     SELECT @cLinhaAux = @cLinha
                     Exec MSSOMA1 @cLinhaAux, @cAux1, @cLinha OutPut
                     SELECT @iLinha = @iLinha + 1
                  END
               END 
               ELSE 
               BEGIN
                  IF ( @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto or @cItemAnt != @cItem or @cClvlAnt != @cClvl ) or @lPrim  = '1' 
                  BEGIN
                     SELECT @lPrim = '0'
                     IF @iLinha = @iMaxLinha 
                     BEGIN
                        IF @cDoc = '999999' 
                        BEGIN
                           SELECT @cAux1 = '0'
                           SELECT @cLoteAux = @cLote
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
                        SELECT @cAux1 = '0'
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
               SELECT @cItemDeb  = @cItem
               SELECT @cItemCrd  = ' '
               SELECT @cClvlDeb  = @cClvl
               SELECT @cClvlCrd  = ' '
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
               SELECT @cClvlDeb  = ' '
               SELECT @cClvlCrd  = @cClvl
            END
            
            SELECT @iRecnoCTF = 0
            SELECT @iRecnoCTF = COALESCE(Min( R_E_C_N_O_), 0)
               FROM CTF###
               Where CTF_FILIAL = @cFilial_CTF
                  and CTF_DATA   = @IN_DATA
                  and CTF_LOTE   = @cLote
                  and CTF_SBLOTE = @cSubLote
                  and CTF_DOC    = @cDoc
                  and D_E_L_E_T_ = ' '
            
            IF @iRecnoCTF = 0
            BEGIN 
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

            IF @IN_LMOEDAESP = '1' and @IN_MOEDA != '01' 
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
                                   CT2_DEBITO,   CT2_CREDIT, CT2_VALOR,   CT2_HIST,   CT2_CCD,     CT2_CCC,      CT2_ITEMD,   CT2_ITEMC,
                                   CT2_CLVLDB,   CT2_CLVLCR, CT2_EMPORI,  CT2_FILORI, CT2_TPSALD,  CT2_MANUAL,   CT2_ROTINA,  CT2_AGLUT,
                                   CT2_SEQHIS,   CT2_SEQLAN, CT2_CRCONV,  R_E_C_N_O_ )
                           VALUES (@cFilial_CT2, @IN_DATA,   @cLote,      @cSubLote,  @cDoc,       @cLinha,      @cMoeda1,    @cDc,
                                   @cContaDeb,   @cContaCrd, @nValor1,    @cHist,     @cCustoDeb,  @cCustoCrd,   @cItemDeb,   @cItemCrd,
                                   @cClvlDeb,    @cClvlCrd,  @IN_EMPORI,  @cFilial_CQ7, @cTpSald, @cManual,  @cRotina,    @cAglut,
                                   @cSeqHis,     @cSeqLan,   @cCrConv,    @iRecno )
               ##CHECK_TRANSACTION_COMMIT               
            END
            SELECT @nValor = Round( @nValor, 2)
            SELECT @cCrConv   = '4'

            -- GRAVACAO DE CT2###
            SELECT @iRecno = 0
            SELECT @iRecno = COALESCE( Max( R_E_C_N_O_ ), 0 ) FROM CT2###
            SELECT @iRecno = @iRecno + 1
                        
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            INSERT INTO CT2### (CT2_FILIAL,   CT2_DATA,   CT2_LOTE,    CT2_SBLOTE, CT2_DOC,     CT2_LINHA,    CT2_MOEDLC,  CT2_DC,
                                CT2_DEBITO,   CT2_CREDIT, CT2_VALOR,   CT2_HIST,   CT2_CCD,     CT2_CCC,      CT2_ITEMD,   CT2_ITEMC,
                                CT2_CLVLDB,   CT2_CLVLCR, CT2_EMPORI,  CT2_FILORI, CT2_TPSALD,  CT2_MANUAL,   CT2_ROTINA,  CT2_AGLUT,
                                CT2_SEQHIS,   CT2_SEQLAN, CT2_CRCONV,  R_E_C_N_O_ )
                        VALUES (@cFilial_CT2, @IN_DATA,   @cLote,      @cSubLote,  @cDoc,       @cLinha,      @cMoeda ,    @cDc,
                                @cContaDeb,   @cContaCrd, @nValor,     @cHist,     @cCustoDeb,  @cCustoCrd,   @cItemDeb,   @cItemCrd,
                                @cClvlDeb,    @cClvlCrd,  @IN_EMPORI,  @cFilial_CQ7, @cTpSald, @cManual,  @cRotina,    @cAglut,
                                @cSeqHis,     @cSeqLan,   @cCrConv,    @iRecno )            
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
                     CQA_FILORI = @cFilial_CQ7 AND
                     CQA_MOEDLC = @cMoeda AND
                     D_E_L_E_T_ = ' '       
               -- So insiro o documento se ele ja nao estiver na fila
               IF @iRecno = 0 
               BEGIN
                  -- GRAVACAO DE CQA###
                  SELECT @iRecno = COALESCE(Max(R_E_C_N_O_), 0) FROM CQA###
                  SELECT @iRecno = @iRecno + 1

                  ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
                  INSERT INTO CQA### (CQA_FILIAL, CQA_FILCT2, CQA_DATA, CQA_LOTE, CQA_SBLOTE, CQA_DOC, CQA_LINHA, CQA_MOEDLC, CQA_EMPORI, CQA_FILORI, CQA_TPSALD, R_E_C_N_O_ )
                              VALUES (@cFilial_CQA, @cFilial_CT2, @IN_DATA, @cLote, @cSubLote, @cDoc, @cLinha, @cMoeda, @IN_EMPORI, @cFilial_CQ7, @cTpSald, @iRecno )
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
      SELECT @cClvlAnt  = @cClvl
      SELECT @cTpSaldAnt = @cTpSald
      SELECT @cFilAnt   = @cFilial_CQ7
      Fetch CUR_Ctb220CQ7 into @cFilial_CQ7, @cMoeda, @cData, @cConta, @cCusto, @cItem, @cClvl, @nDebito, @nCredit, @cTpSald
      IF ( @cFilial_CQ7 != @cFilAnt or @cDataAnt != @cData or @cContaAnt != @cConta or @cCustoAnt != @cCusto or @cItemAnt != @cItem or @cClvlAnt != @cClvl or @cTpSaldAnt != @cTpSald)  BEGIN
         SELECT @lPrim  = '1'
      END
   END
   Close CUR_Ctb220CQ7
   Deallocate CUR_Ctb220CQ7

   SELECT @OUT_LOTE = @cLote
   SELECT @OUT_DOC = @cDoc
   SELECT @OUT_CONT = @iContador
END 
