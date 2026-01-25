
/* -----------------------------------------------------------------------------------------
    CTB201 - GERA MOV................................................... 
       +--> ECDCHVMOV - Ponto de entrada que altera a chave............. 
       +--> CTBS011C - GetDtp()-Verifica se tem apuracao nessa Data....... 
       +--> CTBS011E - Grava CSB.......................................... 
               +--> CTBS011F - Grava CSL.................................. 
       +--> CTBS011D - Grava CSA.......................................... 
   ----------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus 9.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBS011.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Funcao do Siga  -      ProcMov()
    Entrada         - <ri> @IN_EMP     - Empresa Corrente
                           @IN_FILIAL  - Filial Corrente
                           @IN_DATAI   - Data Inicial
                           @IN_DATAF   - Data Final
                           @IN_MOEDA   - Moeda escolhida
                           @IN_TPSALD  - Tipo de Saldo a gerar movimento
                           @IN_CONTAI  - Conta Inicial do Range
                           @IN_CONTAF  - Conta Final do Range
                           @IN_CODREV  - Codigo da revisao
                           @IN_PROCUSTO - Se '1', gravo CT2_CCD, se '0' gravo ' '
                           @IN_LCUSTO   - Se '1, gravo o CCusto, '0' nao gravo CCusto <ri/>
                           @IN_TPLIVRO  - Tipo de Livro                           
    Saida           - <o>  @OUT_RESULT - Indica o termino OK da procedure </ro>
    Responsavel :     <r> totvs  	</r>
    Data        :     26/02/2010
   -------------------------------------------------------------------------------------- */

-- Procedure creation 
--PROCEDURE CT11PROCPA
CREATE PROCEDURE CTBS011A_## (
    @IN_EMP Char( 'CT2_EMPORI' )  , 
    @IN_FILIAL Char( 'CT2_FILIAL' )  , 
    @IN_DATAI Char( 08 ) , 
    @IN_DATAF Char( 08 ) , 
    @IN_MOEDA Char( 'CT2_MOEDLC' ) , 
    @IN_TPSALD Char( 'CT2_TPSALD' ) , 
    @IN_CONTAI Char( 'CT1_CONTA' ) , 
    @IN_CONTAF Char( 'CT1_CONTA' ) , 
    @IN_CODREV Char( 'CSA_CODREV' ) , 
    @IN_PRODCUSTO Char( 01 ) , 
    @IN_ENTREF Char( 02 ) , 
    @IN_TPLIVRO Char( 01 ) , 
    @IN_CATPSALD VarChar( 200 ) , 
    @IN_CAFILS VarChar( 2000 ) , 
    @IN_CMOEDESC Char( 3 ) ,
    @IN_LCW0  Char( 01 ),
    @IN_TAMFILCT2  Integer,
    @IN_TAMTOTCT2  Integer,
    @IN_LMOEDFUN  Char( 01 ),
    @IN_VLLFUN  Float ,
    @IN_ADDVLL  Float,
    @IN_LCSQ   Char( 01 ),
    @IN_CTPMOED Char( 'CTP_MOEDA' ) , 
    @IN_LENTREF Char( 01 ),
    @IN_CCODPLA Char( 'CVD_CODPLA' ) ,
    @IN_CVERPLA Char( 'CVD_VERSAO' ) ,
    @OUT_RESULT Char( 01 )  output ) AS
 
-- Declaration of variables
DECLARE @cFilial_CT2 Char( 'CT2_FILIAL' )
DECLARE @cFilial_CTC Char( 'CTC_FILIAL' )
DECLARE @cFilial_CT8 Char( 'CT8_FILIAL' )
DECLARE @cFilial_CSA Char( 'CSA_FILIAL' )
DECLARE @cFilial_CSB Char( 'CSB_FILIAL' )
DECLARE @cAux Char( 03 )
DECLARE @cCT2_FILIAL Char( 'CT2_FILIAL' )
DECLARE @cCT2_DATA Char( 'CT2_DATA' )
DECLARE @cCT2_LOTE Char( 'CT2_LOTE' )
DECLARE @cCT2_SBLOTE Char( 'CT2_SBLOTE' )
DECLARE @cCT2_DOC Char( 'CT2_DOC' )
DECLARE @cCT2_SEQLAN Char( 'CT2_SEQLAN' )
DECLARE @cCT2_EMPORI Char( 'CT2_EMPORI' )
DECLARE @cCT2_FILORI Char( 'CT2_FILORI' )
DECLARE @cCT2_MOEDLC Char( 'CT2_MOEDLC' )
DECLARE @cCT2_SEQHIS Char( 'CT2_SEQIDX' )
DECLARE @cCT2_LINHA Char( 'CT2_LINHA' )
DECLARE @cCT2_DC Char( 'CT2_DC' )
DECLARE @cCT2_DEBITO Char( 'CT2_DEBITO' )
DECLARE @cCT2_CREDIT Char( 'CT2_CREDIT' )
DECLARE @cCT2_HP Char( 'CT2_HP' )
DECLARE @cCT2_HIST Char( 'CT2_HIST' )
DECLARE @cCT2_CCD Char( 'CT2_CCD' )
DECLARE @cCT2_CCC Char( 'CT2_CCC' )
DECLARE @cCT2_DTLP Char( 'CT2_DTLP' )
DECLARE @cCT2_TPSALD Char( 'CT2_TPSALD' )

DECLARE @nCT2_VALOR Float
DECLARE @nCT2_VLCSA Float
DECLARE @cCT2_CODPAR Char( 'CT2_CODPAR' )
DECLARE @cChave VarChar( 'CSA_NUMLOT' )
DECLARE @cChaveAux VarChar( 'CSA_NUMLOT' )
DECLARE @cChaveTot VarChar( 'CSA_NUMLOT' )
DECLARE @cCSB_NUMARQ VarChar( 'CSB_NUMARQ' )
DECLARE @cDc Char( 01 )
DECLARE @cCSA_INDTIP Char( 'CSA_INDTIP' )
DECLARE @cRet Char( 01 )
DECLARE @cCT8_IDENT Char( 'CT8_IDENT' )
DECLARE @cExtHIST VarChar( 'CT2_HIST' )
DECLARE @nLenHist Integer
DECLARE @iNroRegs1 Integer
DECLARE @iTranCount Integer
DECLARE @iRecno Integer
DECLARE @iRecnoD Integer
DECLARE @iRecnoC Integer
DECLARE @iRecnoCSA Integer
DECLARE @NCONT Integer
DECLARE @iFoundCSQ Integer
DECLARE @cCSQ_DTEXT Char( 008 )
DECLARE @cExecSql nvarchar(MAX)

##IF_001({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
   DECLARE @cCursorProcMov Char( 1 )
   DECLARE @nfim_CUR FLOAT 
##ENDIF_001

##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})      
   DECLARE @cCursorProcMov CHAR( 1 )
##ENDIF_002


BEGIN
   SELECT @NCONT  = 0 
   SELECT @cAux  = 'CT2' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CT2 output 
   SELECT @cAux  = 'CTC' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CTC output 
   SELECT @cChave  = '' 
   SELECT @cChaveAux  = '' 
   SELECT @cChaveTot  = '' 
   SELECT @cCSB_NUMARQ  = '' 
   SELECT @iRecno  = 0 
   SELECT @iRecnoD  = 0 
   SELECT @iRecnoC  = 0 
   SELECT @iRecnoCSA  = 0 
   SELECT @iNroRegs1  = 0 
   SELECT @OUT_RESULT  = '0' 
   SELECT @cDc  = '' 
   SELECT @cCSA_INDTIP  = '' 
   SELECT @cRet  = '0' 
   SELECT @cCT8_IDENT  = ' ' 
   SELECT @iFoundCSQ  = 0 
   SELECT @cExecSql = ''
    
   -- Cursor declaration CUR_PROCMOV
   ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
       SELECT @cExecSql = @cExecSql || ' DECLARE cCursorProcMov insensitive CURSOR FOR '  
   ##ENDIF_003
      SELECT @cExecSql = @cExecSql || ' SELECT T2.CT2_FILIAL , T2.CT2_DATA , T2.CT2_LOTE , T2.CT2_SBLOTE , T2.CT2_DOC , T2.CT2_SEQLAN , T2.CT2_EMPORI , T2.CT2_FILORI , '
      SELECT @cExecSql = @cExecSql || 'T2.CT2_MOEDLC , T2.CT2_SEQHIS , T2.CT2_LINHA , T2.CT2_DC , T2.CT2_DEBITO , T2.CT2_CREDIT , T2.CT2_HP , T2.CT2_HIST , '
      SELECT @cExecSql = @cExecSql || 'T2.CT2_CCD , T2.CT2_CCC , T2.CT2_DTLP , T2.CT2_TPSALD , T2.CT2_VALOR , T2.CT2_CODPAR '
      SELECT @cExecSql = @cExecSql || ' FROM CTC### T1 inner join CT2### T2 ON T1.CTC_FILIAL  = T2.CT2_FILIAL  and T1.CTC_DATA  = T2.CT2_DATA  and T1.CTC_LOTE  = T2.CT2_LOTE '
      SELECT @cExecSql = @cExecSql || ' and T1.CTC_SBLOTE  = T2.CT2_SBLOTE  and T1.CTC_DOC  = T2.CT2_DOC  and T1.CTC_MOEDA  = T2.CT2_MOEDLC and T1.CTC_TPSALD  = T2.CT2_TPSALD ' 
      SELECT @cExecSql = @cExecSql || " WHERE T1.CTC_DATA  between ''"
      SELECT @cExecSql = @cExecSql || @IN_DATAI 
      SELECT @cExecSql = @cExecSql || "'' and ''"
      SELECT @cExecSql = @cExecSql || @IN_DATAF
      SELECT @cExecSql = @cExecSql || "'' and T1.CTC_MOEDA  = ''"
      SELECT @cExecSql = @cExecSql || @IN_MOEDA   
      SELECT @cExecSql = @cExecSql || "'' and T1.CTC_TPSALD IN ("
      SELECT @cExecSql = @cExecSql || @IN_CATPSALD 
      SELECT @cExecSql = @cExecSql || " ) "
      SELECT @cExecSql = @cExecSql || " and T1.D_E_L_E_T_  = '' "
      SELECT @cExecSql = @cExecSql || "'' and T2.CT2_FILIAL IN ("
      SELECT @cExecSql = @cExecSql || @IN_CAFILS 
      SELECT @cExecSql = @cExecSql || " ) "  
      SELECT @cExecSql = @cExecSql || " and (((T2.CT2_DEBITO between ''"
      SELECT @cExecSql = @cExecSql || @IN_CONTAI 
      SELECT @cExecSql = @cExecSql || "'' and ''"
      SELECT @cExecSql = @cExecSql || @IN_CONTAF
      SELECT @cExecSql = @cExecSql || "'' ) or (T2.CT2_CREDIT between ''"
      SELECT @cExecSql = @cExecSql || @IN_CONTAI 
      SELECT @cExecSql = @cExecSql || "'' and ''"
      SELECT @cExecSql = @cExecSql || @IN_CONTAF 
      SELECT @cExecSql = @cExecSql || "''  )) or T2.CT2_DC  = ''"
      SELECT @cExecSql = @cExecSql || '4'
      SELECT @cExecSql = @cExecSql || "'' )  "
      SELECT @cExecSql = @cExecSql || " and T2.D_E_L_E_T_  = '' "
      SELECT @cExecSql = @cExecSql || "'' ORDER BY T2.CT2_FILIAL , T2.CT2_DATA , T2.CT2_LOTE , T2.CT2_SBLOTE , T2.CT2_DOC , T2.CT2_SEQLAN , T2.CT2_EMPORI , T2.CT2_FILORI , " 
      SELECT @cExecSql = @cExecSql || " T2.CT2_MOEDLC , T2.CT2_SEQHIS "
   
   ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      SELECT @cExecSql = @cExecSql || " FOR READ ONLY "
      exec sp_executesql @cExecSql
      OPEN cCursorProcMov
   ##ENDIF_004     

   ##IF_005({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})   
      OPEN cCursorProcMov
   ##ENDIF_005

   ##IF_006({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
      OPEN cCursorProcMov --Nao tirar de dentro do IF - sera substituido no pos compile
   ##ENDIF_006 



   FETCH cCursorProcMov 
    INTO @cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_SEQLAN , @cCT2_EMPORI , @cCT2_FILORI , 
          @cCT2_MOEDLC , @cCT2_SEQHIS , @cCT2_LINHA , @cCT2_DC , @cCT2_DEBITO , @cCT2_CREDIT , @cCT2_HP , @cCT2_HIST , @cCT2_CCD , 
          @cCT2_CCC , @cCT2_DTLP , @cCT2_TPSALD , @nCT2_VALOR , @cCT2_CODPAR 
   WHILE ( (@@fetch_status  = 0 ) )
   BEGIN
      SELECT @iFoundCSQ  = 0 
      SELECT @cCSQ_DTEXT  = ' ' 
      SELECT @cAux  = 'CT8' 
      EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CT8 output 
      SELECT @cAux  = 'CSA' 
      EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CSA output 
      SELECT @cAux  = 'CSB' 
      EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CSB output 
      SELECT @iNroRegs1  = @iNroRegs1  + 1 

      IF @IN_CMOEDESC = 'FCO'
      BEGIN
         SELECT @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_TPSALD
      END
      ELSE
      BEGIN
         IF @cCT2_DTLP  != ' ' 
         BEGIN 
            SELECT @cChave  = @cCT2_FILIAL  || @cCT2_DATA  || @cCT2_LOTE || @cCT2_SBLOTE  || 'APURACAO' 
         END 
         ELSE 
         BEGIN
         ##IF_007({ || GetNewPar('MV_CTBSDOC', .F.) == .T.})
            SELECT @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC
         ##ELSE_007
            SELECT @cChave = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE
         ##ENDIF_007
         END
      END
      EXEC ECDCHVMOV_## @cChave , @cChaveAux output 

      IF @cChaveAux  != ' ' 
      BEGIN 
         SELECT @cChave  = @cChaveAux 
      END 
      IF @cCT2_TPSALD  = @IN_TPSALD 
      BEGIN 
         SELECT @cCSA_INDTIP  = 'N' 
      END 
      --TRATAR MOED
      IF @IN_CMOEDESC = 'FCO'
      BEGIN
         IF @cCT2_TPSALD = 'ECD_TIP_X_LANC'
         BEGIN
            SELECT @cCSA_INDTIP = 'X'
         END
         ELSE
         BEGIN 
            IF @cCT2_TPSALD = 'ECD_TIP_F_LANC'
            BEGIN
               SELECT @cCSA_INDTIP = 'F'
            END
            ELSE 
            BEGIN
               IF @cCT2_TPSALD = 'ECD_TIP_TR_LANC'
               BEGIN
                  SELECT @cCSA_INDTIP = 'TR'
               END
               ELSE
               BEGIN 
                  IF @cCT2_TPSALD = 'ECD_TIP_TF_LANC'
                  BEGIN
                     SELECT @cCSA_INDTIP = 'TF'
                  END
                  ELSE 
                  BEGIN
                     IF @cCT2_TPSALD = 'ECD_TIP_TS_LANC'
                     BEGIN
                        SELECT @cCSA_INDTIP = 'TS'
                     END
                     ELSE 
                     BEGIN
                        IF @cCT2_TPSALD = 'ECD_TIP_EF_LANC'
                        BEGIN
                           SELECT @cCSA_INDTIP = 'EF'
                        END
                        ELSE 
                        BEGIN
                           IF @cCT2_TPSALD = 'ECD_TIP_IF_LANC'
                           BEGIN
                              SELECT @cCSA_INDTIP = 'IF'
                           END
                           ELSE 
                           BEGIN
                              IF @cCT2_TPSALD = 'ECD_TIP_IS_LANC'
                              BEGIN
                                 SELECT @cCSA_INDTIP = 'IS'
                              END
                           END
                        END
                     END
                  END
               END
            END
         END
      END

      SELECT @cRet  = '0' 
      IF @cCT2_DTLP  != ' ' 
      BEGIN 
         --PROCEDURE CT11DTLP
         EXEC CTBS011C_## @IN_EMP , @cCT2_FILIAL , @cCT2_DATA , @cCT2_MOEDLC , @cCT2_TPSALD , @cCT2_LOTE , @cCT2_SBLOTE , 
                @cCT2_DOC , @cCT2_EMPORI , @cCT2_FILORI , @IN_LCW0 ,@IN_TAMFILCT2 ,@IN_TAMTOTCT2 , @cRet output 
         IF @cRet  = '1' 
         BEGIN 
            SELECT @cCSA_INDTIP  = 'E' 
         END 
      END 
      ##IF_008({|| AliasInDic('CSQ')})
         ##FIELDP01( 'CSQ.CSQ_DTEXT' )
            ##FIELDP02( 'CSA.CSA_DTEXT' )
               ##FIELDP03( 'CSB.CSB_DTEXT' )
                  IF @cRet  = '0' 
                  BEGIN 
                     SELECT @iFoundCSQ  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ), @cCSQ_DTEXT  = COALESCE ( CSQ_DTEXT , ' ' )
                     FROM CSQ###
                     WHERE CSQ_FILIAL  = @cCT2_FILIAL  and CSQ_DATA  = @cCT2_DATA  and CSQ_LOTE  = @cCT2_LOTE  and CSQ_SBLOTE  = @cCT2_SBLOTE 
                        and CSQ_DOC  = @cCT2_DOC  and CSQ_LINHA  = @cCT2_LINHA  and CSQ_EMPORI  = @cCT2_EMPORI  and CSQ_FILORI  = @cCT2_FILORI 
                        and D_E_L_E_T_  = ' ' 
                     GROUP BY R_E_C_N_O_ , CSQ_DTEXT 
                  END 
                  IF @iFoundCSQ  != 0 
                  BEGIN 
                     SELECT @cCSA_INDTIP  = 'X' 
                  END 
               ##ENDFIELDP03
            ##ENDFIELDP02
         ##ENDFIELDP01
      ##ENDIF_008
      IF @iNroRegs1  = 1 
      BEGIN 
         begin tran 
         SELECT @iNroRegs1  = @iNroRegs1 
      END 
      IF  (ROUND ( @nCT2_VALOR , 2 ) != 0.00 )  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '2'  or @cCT2_DC  = '3' ) 
      BEGIN 
         SELECT @iRecnoCSA  = 0 
         SELECT @cChave  = RTRIM ( @cChave )
         SELECT @cChaveTot  = 'TROCAR  cChaveTot'
         SELECT @iRecnoCSA  = COALESCE ( MIN ( R_E_C_N_O_ ), 0 )
           FROM CSA### 
           WHERE CSA_FILIAL  = @cFilial_CSA  and CSA_CODREV  = @IN_CODREV  and CSA_DTLANC  = @cCT2_DATA  and CSA_DTEXT  = @cCSQ_DTEXT 
            and CSA_NUMLOT  = @cChaveTot  and D_E_L_E_T_  = ' ' 
         IF  (ROUND ( @nCT2_VALOR , 2 ) != 0.00 )  and  (@cCT2_DC  = '1'  or @cCT2_DC  = '3' ) 
         BEGIN 
            SELECT @nCT2_VLCSA  = ROUND ( @nCT2_VALOR , 2 )
         END 
         ELSE 
         BEGIN 
            SELECT @nCT2_VLCSA  = 0 
         END 
         IF @cCT2_DTLP  = ' '  and @IN_TPLIVRO  = 'A' 
         BEGIN 
            IF @iRecnoCSA  = 0 
            BEGIN 
               SELECT @cCSQ_DTEXT = IsNull(@cCSQ_DTEXT, ' ')
               --PROCEDURE CT11POPCSA_
               EXEC CTBS011D_## @cFilial_CSA , @IN_CODREV , @cChave , @cCT2_DATA , @nCT2_VLCSA , @cCSA_INDTIP , @cCSQ_DTEXT, @IN_LMOEDFUN ,@IN_VLLFUN , @IN_ADDVLL , @IN_LCSQ
            END 
            ELSE 
            BEGIN 
               UPDATE CSA###
                  SET CSA_VLLCTO  = CSA_VLLCTO  + ROUND ( @nCT2_VLCSA , 2 )
                WHERE R_E_C_N_O_  = @iRecnoCSA 
            END 
         END 
         IF @IN_TPLIVRO  != 'A' 
         BEGIN 
            IF @iRecnoCSA  = 0 
            BEGIN 
               SELECT @cCSQ_DTEXT = IsNull(@cCSQ_DTEXT, ' ')
               --PROCEDURE CT11POPCSA_
               EXEC CTBS011D_## @cFilial_CSA , @IN_CODREV , @cChave , @cCT2_DATA , @nCT2_VLCSA , @cCSA_INDTIP , @cCSQ_DTEXT , @IN_LMOEDFUN ,@IN_VLLFUN , @IN_ADDVLL , @IN_LCSQ
            END 
            ELSE 
            BEGIN 
               UPDATE CSA###
                  SET CSA_VLLCTO  = CSA_VLLCTO  + ROUND ( @nCT2_VLCSA , 2 )
                WHERE R_E_C_N_O_  = @iRecnoCSA 
            END 
         END 
      END 
      IF @cCT2_DC  != '4' 
      BEGIN 
         SELECT @iRecnoD  = 0 
         SELECT @iRecnoC  = 0 
      END 
      IF  ( (@cCT2_DC  = '1'  or @cCT2_DC  = '3' )  and  (@cCT2_DEBITO  between @IN_CONTAI and @IN_CONTAF ) ) 
      BEGIN 
         SELECT @cDc  = 'D' 
         IF @IN_CMOEDESC = 'FCO'
         BEGIN
            SELECT @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_TPSALD||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI 
         END
         ELSE 
         BEGIN
            SELECT @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI
         END
         
         IF @cCT2_DTLP  = ' '  and @IN_TPLIVRO  = 'A' 
         BEGIN 
            IF @IN_PRODCUSTO  = '0' 
            BEGIN 
               SELECT @cCT2_CCD  = ' ' 
            END 
            SELECT @cCSQ_DTEXT = IsNull(@cCSQ_DTEXT, ' ')
            --PROCEDURE CT11POPCSB_
            EXEC CTBS011E_## @IN_FILIAL , @IN_CODREV , @cChave , @cCT2_LINHA , @cCT2_DEBITO , @cCT2_CCD , @cDc , @cCT2_HP , 
                   @cCT2_HIST , @nCT2_VALOR , @cCSQ_DTEXT  , 0,0,0,0, @cCT2_CODPAR , @cCSB_NUMARQ , @cCT2_DATA , @IN_PRODCUSTO , @IN_ENTREF ,
                   @IN_LMOEDFUN , @IN_CTPMOED , @IN_LCSQ  , @IN_LENTREF , @IN_CCODPLA , @IN_CVERPLA , 
                   @iRecnoD output 
         END 
         IF @IN_TPLIVRO  != 'A' 
         BEGIN 
            IF @IN_PRODCUSTO  = '0' 
            BEGIN 
               SELECT @cCT2_CCD  = ' ' 
            END 
            SELECT @cCSQ_DTEXT = IsNull(@cCSQ_DTEXT, ' ')
            --PROCEDURE CT11POPCSB_
            EXEC CTBS011E_## @IN_FILIAL , @IN_CODREV , @cChave , @cCT2_LINHA , @cCT2_DEBITO , @cCT2_CCD , @cDc , @cCT2_HP , 
                   @cCT2_HIST , @nCT2_VALOR , @cCSQ_DTEXT ,0,0,0,0,@cCT2_CODPAR , @cCSB_NUMARQ , @cCT2_DATA , @IN_PRODCUSTO , @IN_ENTREF , 
                   @IN_LMOEDFUN , @IN_CTPMOED , @IN_LCSQ , @IN_LENTREF , @IN_CCODPLA , @IN_CVERPLA , 
                   @iRecnoD output 
         END 
      END 
      IF  ( (@cCT2_DC  = '2'  or @cCT2_DC  = '3' )  and  (@cCT2_CREDIT  between @IN_CONTAI and @IN_CONTAF ) ) 
      BEGIN 
         SELECT @cDc  = 'C' 
         IF @IN_CMOEDESC = 'FCO'
         BEGIN
            SELECT @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_TPSALD||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI 
         END
         ELSE
         BEGIN
            SELECT @cCSB_NUMARQ = @cCT2_FILIAL||@cCT2_DATA||@cCT2_LOTE||@cCT2_SBLOTE||@cCT2_DOC||@cCT2_LINHA||@cCT2_SEQLAN||@cDc||@cCT2_MOEDLC||@cCT2_TPSALD||@cCT2_EMPORI||@cCT2_FILORI
         END
         IF @cCT2_DTLP  = ' '  and @IN_TPLIVRO  = 'A' 
         BEGIN 
            IF @IN_PRODCUSTO  = '0' 
            BEGIN 
               SELECT @cCT2_CCD  = ' ' 
            END 
            SELECT @cCSQ_DTEXT = IsNull(@cCSQ_DTEXT, ' ')
            --PROCEDURE CT11POPCSB_
            EXEC CTBS011E_## @IN_FILIAL , @IN_CODREV , @cChave , @cCT2_LINHA , @cCT2_CREDIT , @cCT2_CCC , @cDc , @cCT2_HP , 
                   @cCT2_HIST , @nCT2_VALOR , @cCSQ_DTEXT  ,0,0,0,0,@cCT2_CODPAR , @cCSB_NUMARQ , @cCT2_DATA , @IN_PRODCUSTO , @IN_ENTREF , 
                   @IN_LMOEDFUN ,@IN_CTPMOED , @IN_LCSQ , @IN_LENTREF , @IN_CCODPLA , @IN_CVERPLA , 
                   @iRecnoC output 
         END 
         IF @IN_TPLIVRO  != 'A' 
         BEGIN 
            IF @IN_PRODCUSTO  = '0' 
            BEGIN 
               SELECT @cCT2_CCD  = ' ' 
            END 
            SELECT @cCSQ_DTEXT = IsNull(@cCSQ_DTEXT, ' ')
            --PROCEDURE CT11POPCSB_
            EXEC CTBS011E_## @IN_FILIAL , @IN_CODREV , @cChave , @cCT2_LINHA , @cCT2_CREDIT , @cCT2_CCC , @cDc , @cCT2_HP , 
                   @cCT2_HIST , @nCT2_VALOR , @cCSQ_DTEXT  ,0,0,0,0,@cCT2_CODPAR , @cCSB_NUMARQ , @cCT2_DATA , @IN_PRODCUSTO , @IN_ENTREF ,
                   @IN_LMOEDFUN, @IN_CTPMOED , @IN_LCSQ , @IN_LENTREF , @IN_CCODPLA , @IN_CVERPLA , 
                   @iRecnoC output 
         END 
      END 
      IF @cCT2_DC  = '4' 
      BEGIN 
         IF @iRecnoD  > 0 
         BEGIN 
            UPDATE CSB###
               SET CSB_HISTOR  = SUBSTRING ( RTRIM ( LTRIM ( CSB_HISTOR )) || ' ' || RTRIM ( LTRIM ( @cCT2_HIST )), 1 , 254254 )
             WHERE R_E_C_N_O_  = @iRecnoD 
         END 
         IF @iRecnoC  > 0 
         BEGIN 
            UPDATE CSB###
               SET CSB_HISTOR  = SUBSTRING ( RTRIM ( LTRIM ( CSB_HISTOR )) || ' ' || RTRIM ( LTRIM ( @cCT2_HIST )), 1 , 254254 )
             WHERE R_E_C_N_O_  = @iRecnoC 
         END 
      END 
      IF @iNroRegs1  >= 10000 
      BEGIN 
         commit tran 
         SELECT @iNroRegs1  = 0 
      END 
      FETCH cCursorProcMov 
       INTO @cCT2_FILIAL , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_SEQLAN , @cCT2_EMPORI , @cCT2_FILORI , 
             @cCT2_MOEDLC , @cCT2_SEQHIS , @cCT2_LINHA , @cCT2_DC , @cCT2_DEBITO , @cCT2_CREDIT , @cCT2_HP , @cCT2_HIST , 
             @cCT2_CCD , @cCT2_CCC , @cCT2_DTLP , @cCT2_TPSALD , @nCT2_VALOR , @cCT2_CODPAR 
   END 
   CLOSE cCursorProcMov
   DEALLOCATE cCursorProcMov
   IF @iNroRegs1  > 0 
   BEGIN 
       SELECT @OUT_RESULT  = '9'  
   END 
   SELECT @OUT_RESULT  = '1' 
END 
