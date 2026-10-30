--MV_PAR14 == 1
CREATE PROCEDURE CTBA231C_## (
	@IN_HAGLUT  VARCHAR(231), 
	@IN_MVPAR05 INTEGER,	
   @IN_FILIAL  CHAR( 'CT2_FILIAL' ),
   @IN_TRANSACTION CHAR(1),
	@OUT_RET  INTEGER OUTPUT) AS

DECLARE @cFILORI  CHAR( 'CTB_FILIAL' )
DECLARE @cCODIGO	CHAR( 'CTB_CODIGO' )
DECLARE @cTPSALD	CHAR( 'CTB_TPSLDO' )
DECLARE @cCTADB	CHAR( 'CTB_CTADES' )
DECLARE @cCCDB		CHAR( 'CTB_CCDES' )
DECLARE @cITEMDB	CHAR( 'CTB_ITEMDE' )
DECLARE @cCLVLDB	CHAR( 'CTB_CLVLDE' )
DECLARE @cCTACR	CHAR( 'CTB_CTADES' )
DECLARE @cCCCR		CHAR( 'CTB_CCDES' )
DECLARE @cITEMCR	CHAR( 'CTB_ITEMDE' )
DECLARE @cCLVLCR	CHAR( 'CTB_CLVLDE' )
DECLARE @cFORMUL	CHAR( 'CTB_FORMUL' )
DECLARE @cHIST		CHAR( 'CT2_HIST' )
DECLARE @cMOEDA	CHAR( 'CT2_MOEDLC' )
DECLARE @cTIPO		CHAR( 'CT2_DC' )
DECLARE @cLOTE		CHAR( 'CT2_LOTE' )
DECLARE @cSUB		CHAR( 'CT2_SBLOTE' )
DECLARE @cDOC		CHAR( 'CT2_DOC' )
DECLARE @cLINHA	CHAR( 'CT2_LINHA' )
DECLARE @cFILIAL_CTF CHAR( 'CT2_FILIAL' )
DECLARE @cFILIAL_CT2 CHAR( 'CT2_FILIAL' )
DECLARE @cSeqIdx   CHAR( 'CT2_SEQIDX' )

DECLARE @cEMPORI  CHAR(2)
DECLARE @dDTANT	CHAR(8)
DECLARE @dDATA		CHAR(8)
DECLARE @dDTLP		CHAR(8)
DECLARE @cHAGLUT  CHAR(231)

DECLARE @nRECCTF  INTEGER
DECLARE @nI		   INTEGER
DECLARE @nVALOR	FLOAT
DECLARE @iRecno   INTEGER
DECLARE @fim_CUR  INTEGER 
DECLARE @FLEX CHAR(1) --TRATAMENTO VIA PONTO DE ENTRADA

BEGIN
   EXEC XFILIAL_## 'CTF', @IN_FILIAL, @cFILIAL_CTF OUTPUT
   EXEC XFILIAL_## 'CT2', @IN_FILIAL, @cFILIAL_CT2 OUTPUT

   SELECT @dDTANT='XXXXXXXX'
   SELECT @cLINHA='001'
   SELECT @OUT_RET = 6

   DECLARE CURSORCTB231 insensitive CURSOR FOR 
   SELECT MAX(EMPORI) AS EMPORI , MAX(FILORI) AS FILORI, 

   ##IF_001({|| __lMultiRot := SuperGetMV("MV_CTBMTRT",, .F.)})
      CTB_CODIGO,
   ##ENDIF_001
   
      CTB_TPSLDO, CTB_CTADB, CTB_CCDB, CTB_ITEMDB, CTB_CLVLDB, CTB_CTACR, CTB_CCCR, CTB_ITEMCR, CTB_CLVLCR,--SELECT ENTIDADES   
      SUM(VALOR) AS VALOR, CDATA,MAX(FORMUL) AS FORMUL,MAX(HAGLUT) AS HAGLUT, MAX(HIST) AS HIST, DTLP, MOEDA, TIPO
   FROM TRA###_36SP
   GROUP BY 

   ##IF_001({|| __lMultiRot})
      CTB_CODIGO,
   ##ENDIF_001

      CTB_TPSLDO, CTB_CTADB, CTB_CCDB, CTB_ITEMDB, CTB_CLVLDB, CTB_CTACR, CTB_CCCR, CTB_ITEMCR, CTB_CLVLCR,--GROUP ENTIDADES
      CDATA, DTLP, MOEDA, TIPO 
   ORDER BY CDATA 
   FOR READ ONLY 
      
   OPEN CURSORCTB231         
   FETCH CURSORCTB231 INTO @cEMPORI, @cFILORI, 
   ##IF_001({|| __lMultiRot})
      @cCODIGO,
   ##ENDIF_001   
   @cTPSALD, @cCTADB, @cCCDB, @cITEMDB, @cCLVLDB, @cCTACR, @cCCCR, @cITEMCR, @cCLVLCR, --CFETCHCUBE  @nVALOR, @dDATA, @cFORMUL, @cHAGLUT, @cHIST, @dDTLP, @cMOEDA, @cTIPO

   WHILE @@FETCH_STATUS = 0
      BEGIN
         IF @dDTANT <> @dDATA OR @cLINHA = '999'
         BEGIN
            SELECT @cLOTE = ' ' 
            SELECT @cSUB = ' '
            SELECT @cDOC = ' '
            SELECT @cLINHA = ' '
            SELECT @nRECCTF=MIN(R_E_C_N_O_), @cLOTE=MAX(CTF_LOTE), @cSUB=MAX(CTF_SBLOTE), @cDOC=MAX(CTF_DOC)
            FROM CTF###
            WHERE CTF_FILIAL= @cFILIAL_CTF
            AND CTF_DATA=@dDATA
            AND D_E_L_E_T_ = ' '

            IF @nRECCTF IS NULL
            BEGIN
               SELECT @OUT_RET=7
               SELECT @cLOTE='000001' 
               SELECT @cSUB='001'
               SELECT @cDOC='000001'
               SELECT @cLINHA='001'
               SELECT @nRECCTF=COALESCE(MAX(R_E_C_N_O_),0)+1 FROM CTF###
               INSERT INTO CTF### ( CTF_FILIAL, CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, CTF_LINHA, CTF_USADO, R_E_C_N_O_ )
               VALUES ( @cFILIAL_CTF, @dDATA, @cLOTE, @cSUB, @cDOC, @cLINHA, 'S', @nRECCTF )
            END
            ELSE
            BEGIN
               IF @cDOC='999999'
               BEGIN
                  SELECT @cDOC='000001'
                  IF @cLOTE='999999'
                  BEGIN
                     SELECT @OUT_RET=8
                     SELECT @cLOTE='000001'
                     SELECT @nI = CONVERT(INT,@cSUB)+1
                     EXEC MSSTRZERO @nI , 3 , @cSUB OUTPUT
                  END
                  ELSE
                  BEGIN
                     SELECT @OUT_RET=9
                     SELECT @nI=CONVERT(INT,@cLOTE)+1
                     EXEC MSSTRZERO @nI , 6 , @cLOTE OUTPUT
                  END
               END
               ELSE
               BEGIN
                  SELECT @OUT_RET=10
                  IF @IN_MVPAR05 = 1
                  BEGIN
                     IF @cMOEDA = '01'
                     BEGIN
                        SELECT @nI=CONVERT(INT,@cDOC)+1
                        EXEC MSSTRZERO @nI , 6 , @cDOC OUTPUT
                     END
                  END
                  ELSE
                  BEGIN
                     SELECT @nI=CONVERT(INT,@cDOC)+1
                     EXEC MSSTRZERO @nI , 6 , @cDOC OUTPUT
                  END
               END

               SELECT @cLINHA='001'

               SELECT @OUT_RET=11
               UPDATE CTF### SET CTF_LOTE=@cLOTE, CTF_SBLOTE=@cSUB, CTF_DOC=@cDOC, CTF_LINHA=@cLINHA
               WHERE R_E_C_N_O_=@nRECCTF
            END
         END
         ELSE
         BEGIN
            SELECT @OUT_RET=12
            IF @IN_MVPAR05 = 1
            BEGIN
               IF @cMOEDA = '01'
               BEGIN
                  SELECT @nI=CONVERT(INT,@cLINHA)+1
                  EXEC MSSTRZERO @nI , 3 , @cLINHA OUTPUT
               END
            END
            ELSE
            BEGIN
               SELECT @nI=CONVERT(INT,@cLINHA)+1
               EXEC MSSTRZERO @nI , 3 , @cLINHA OUTPUT
            END
            UPDATE CTF### SET CTF_LINHA=@cLINHA
            WHERE R_E_C_N_O_=@nRECCTF
         END

         IF @cFORMUL <> ' '
         BEGIN
            SELECT @cHIST= SUBSTRING(@cFORMUL,1,999)
         END
         ELSE
         BEGIN
            IF @cHAGLUT <> ' ' 
            BEGIN
               SELECT @cHIST= SUBSTRING(@cHAGLUT,1,999)
            END
         END
         IF RTRIM(@IN_HAGLUT) <> '' 
         BEGIN
            SELECT @cHIST= SUBSTRING(@IN_HAGLUT,1,999)
         END

         SELECT @OUT_RET=13
         IF @cCTADB != ' ' AND @cCTACR = ' ' 
         BEGIN
            SELECT @cTIPO = '1' 
         END
         IF @cCTADB = ' ' AND @cCTACR != ' ' 
         BEGIN
            SELECT @cTIPO = '2' 
         END 

         /* ---------------------------------------------------------------
            As tags ##UNIQUEKEY_START e ##UNIQUEKEY_END serão utilizadas para que seja possível tratar o erro quando 
            houver violação da chave única. O bloco de código para isso será inserido no parser da Engenharia, logo 
            após a MsParse() devolver o código na linguagem do banco em uso.
            -------------------------------------------------------------------------------------------------------------- */
         select @iRecno  = 0
         select @cSeqIdx = ' '
         ##UNIQUEKEY_START
         select @iRecno = COALESCE(Min(R_E_C_N_O_), 0)
            From CT2###
            Where CT2_FILIAL = @cFILIAL_CT2
               and CT2_DATA  = @dDATA
               and CT2_LOTE = @cLOTE
               and CT2_SBLOTE = @cSUB
               and CT2_DOC = @cDOC
               and CT2_LINHA = @cLINHA
               and CT2_EMPORI = @cEMPORI
               and CT2_FILORI = @cFILORI
               and CT2_MOEDLC = @cMOEDA
               and CT2_SEQIDX = @cSeqIdx
               and D_E_L_E_T_ = ' '         
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
               select @iRecno = COALESCE(Max(R_E_C_N_O_), 0) FROM CT2###
               select @iRecno = @iRecno + 1
               
               ##TRATARECNO @iRecno\
               ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
               INSERT INTO CT2### ( CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_MOEDLC, CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, --INSERT ENTIDADES
                     CT2_EMPORI, CT2_FILORI, CT2_TPSALD, CT2_DTLP, CT2_MANUAL, CT2_ROTINA, CT2_AGLUT, CT2_SEQHIS, CT2_SEQLAN, CT2_TAXA, CT2_VLR01, CT2_VLR02, CT2_VLR03, CT2_VLR04, CT2_VLR05, CT2_CRCONV, CT2_CTLSLD, R_E_C_N_O_)
               VALUES             ( @cFILIAL_CT2  , @dDATA   , @cLOTE   , @cSUB      , @cDOC   , @cLINHA   , @cMOEDA    , @cTIPO , @cCTADB    , @cCTACR    , 0 , @cHIST   , @cCCDB  , @cCCCR  , @cITEMDB  , @cITEMCR  , @cCLVLDB   , @cCLVLCR   , --VALUES ENTIDADES
                     @cEMPORI   , @cFILORI   , @cTPSALD   , @dDTLP   , '1'       , 'CTBA231' , '1'      , '001'     , @cLINHA    , 0       , 0        , 0        , 0        , 0        , 0        , '1'       , '0'       , @iRecno )
               ##CHECK_TRANSACTION_COMMIT
               ##FIMTRATARECNO
         end
         
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
         Update CT2###
            set CT2_VALOR = CT2_VALOR + @nVALOR
            Where R_E_C_N_O_ = @iRecno
         ##CHECK_TRANSACTION_COMMIT
            
         SELECT @dDTANT=@dDATA

         SELECT @OUT_RET = 15

         FETCH CURSORCTB231 INTO @cEMPORI, @cFILORI,
         ##IF_001({|| __lMultiRot})
            @cCODIGO,
         ##ENDIF_001
         @cTPSALD, @cCTADB, @cCCDB, @cITEMDB, @cCLVLDB, @cCTACR, @cCCCR, @cITEMCR, @cCLVLCR, --CFETCHCUBE  @nVALOR, @dDATA, @cFORMUL, @cHAGLUT, @cHIST, @dDTLP, @cMOEDA, @cTIPO             
      END
   CLOSE CURSORCTB231
   DEALLOCATE CURSORCTB231

   SELECT @OUT_RET=1
END