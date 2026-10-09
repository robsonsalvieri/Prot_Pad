--MV_PAR14 <> 1 
CREATE PROCEDURE CTBA231D_## (
	@IN_HAGLUT  VARCHAR(231), 
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
DECLARE @cSUBLOTE CHAR( 'CT2_SBLOTE' )
DECLARE @cSUBLNEW	CHAR( 'CT2_SBLOTE' )
DECLARE @cFILIAL_CTF CHAR( 'CT2_FILIAL' )
DECLARE @cFILIAL_CT2 CHAR( 'CT2_FILIAL' )

DECLARE @cEMPORI  CHAR(2)
DECLARE @dDTANT	CHAR(8)
DECLARE @dDATA		CHAR(8)
DECLARE @dDTLP		CHAR(8)
DECLARE @cHAGLUT  CHAR(231)

DECLARE @nRECCTF  INTEGER
DECLARE @nREC_CT2	INTEGER
DECLARE @nFLAG   	INTEGER
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
   SELECT EMPORI , FILORI, 
   
   ##IF_001({|| __lMultiRot := SuperGetMV("MV_CTBMTRT",, .F.)})
      CTB_CODIGO,
   ##ENDIF_001
   
      CTB_TPSLDO, 
      MAX(CTB_CTADB) AS CTB_CTADB, MAX(CTB_CCDB) AS CTB_CCDB,MAX(CTB_ITEMDB) AS CTB_ITEMDB, MAX(CTB_CLVLDB) AS CTB_CLVLDB,
      MAX(CTB_CTACR) AS CTB_CTACR ,MAX(CTB_CCCR) AS CTB_CCCR, MAX(CTB_ITEMCR) AS CTB_ITEMCR,MAX(CTB_CLVLCR) AS CTB_CLVLCR, --SELECT ENTIDADES
      VALOR, CDATA,MAX(FORMUL) AS FORMUL,MAX(HAGLUT) AS HAGLUT, HIST, DTLP, MOEDA, TIPO, LOTE , SBLOTE , DOC , LINHA 
   FROM TRA###_36SP
   GROUP BY EMPORI, FILORI, 

   ##IF_001({|| __lMultiRot})
      CTB_CODIGO, 
   ##ENDIF_001   
      
   CTB_TPSLDO, VALOR, CDATA, HIST, DTLP, MOEDA, TIPO, LOTE, SBLOTE, DOC, LINHA, REC    
   ORDER BY CDATA 
   FOR READ ONLY 
   
   OPEN CURSORCTB231   
   FETCH CURSORCTB231 INTO @cEMPORI, @cFILORI, 
   ##IF_001({|| __lMultiRot})
      @cCODIGO,
   ##ENDIF_001   
   @cTPSALD, @cCTADB, @cCCDB, @cITEMDB, @cCLVLDB, @cCTACR, @cCCCR, @cITEMCR, @cCLVLCR, --CFETCHCUBE  @nVALOR, @dDATA, @cFORMUL, @cHAGLUT, @cHIST, @dDTLP, @cMOEDA, @cTIPO, @cLOTE, @cSUB, @cDOC, @cLINHA

   WHILE @@FETCH_STATUS = 0
   BEGIN
      SELECT @cSUBLOTE = @cSUB 
      SELECT @nFLAG = 1
      WHILE @nFLAG < 100 
      BEGIN 
         SELECT @nREC_CT2 =MIN(R_E_C_N_O_)
         FROM CT2###
         WHERE CT2_FILIAL = @cFILIAL_CT2
         AND CT2_DATA   = @dDATA
         AND CT2_LOTE   = @cLOTE
         AND CT2_SBLOTE = @cSUBLOTE
         AND CT2_DOC    = @cDOC
         AND CT2_LINHA  = @cLINHA
         AND CT2_EMPORI = @cEMPORI
         AND CT2_FILORI = @cFILORI
         AND CT2_MOEDLC = @cMOEDA
         AND D_E_L_E_T_ = ' ' 
         IF @nREC_CT2 IS NULL
         BEGIN 
            IF @cSUB != @cSUBLOTE  
            BEGIN 
               INSERT INTO TRU###_36SP ( CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_SBLNEW) 
               VALUES ( @cFILIAL_CT2, @dDATA, @cLOTE, @cSUB, @cDOC, @cSUBLOTE )    
               SELECT @cSUB=@cSUBLOTE              
            END 				  
            SELECT @nFLAG=100 
         END 
         ELSE 
         BEGIN                
            SELECT @cSUBLNEW = MIN(CT2_SBLNEW) 
            FROM TRU###_36SP
            WHERE CT2_FILIAL = @cFILIAL_CT2
            AND CT2_DATA = @dDATA
            AND CT2_LOTE = @cLOTE
            AND CT2_SBLOTE = @cSUBLOTE
            AND CT2_DOC = @cDOC               
            AND CT2_EMPORI = @cEMPORI
            AND CT2_FILORI = @cFILORI
            AND D_E_L_E_T_ = ' '
            
            IF @cSUBLNEW IS NOT NULL 
            BEGIN 
               SELECT @cSUB = @cSUBLNEW 
               SELECT @nFLAG=100 
            END 
            ELSE 
            BEGIN 
               IF @nFLAG = 1
               BEGIN
                  SELECT @cSUBLOTE = '9' || SUBSTRING(@cSUB, 2, 2)
               END
               ELSE IF @nFLAG = 2
               BEGIN
                  SELECT @cSUBLOTE = '8' || SUBSTRING(@cSUB, 2, 2)
               END
               ELSE IF @nFLAG = 3
               BEGIN
                  SELECT @cSUBLOTE = '7' || SUBSTRING(@cSUB, 2, 2)
               END
               ELSE IF @nFLAG = 4
               BEGIN
                  SELECT @cSUBLOTE = '6' || SUBSTRING(@cSUB, 2, 2)
               END
               ELSE IF @nFLAG = 5
               BEGIN
                  SELECT @cSUBLOTE = '5' || SUBSTRING(@cSUB, 2, 2)
               END
               ELSE IF @nFLAG = 6
               BEGIN
                  SELECT @cSUBLOTE = '4' || SUBSTRING(@cSUB, 2, 2)
               END
               ELSE IF @nFLAG = 7
               BEGIN
                  SELECT @cSUBLOTE = '3' || SUBSTRING(@cSUB, 2, 2)
               END
               ELSE IF @nFLAG = 8
               BEGIN
                  SELECT @cSUBLOTE = '2' || SUBSTRING(@cSUB, 2, 2)
               END
               ELSE IF @nFLAG = 9
               BEGIN
                  SELECT @cSUBLOTE = '1' || SUBSTRING(@cSUB, 2, 2)
               END
               ELSE IF @nFLAG > 9
               BEGIN
                  SELECT @cSUBLOTE = '9' || SUBSTRING(CONVERT(CHAR(2), @nFLAG), 1, 2)
               END
               SELECT @nFLAG = @nFLAG + 1
            END
         END
      END

      SELECT @nRECCTF = MIN(R_E_C_N_O_)
         FROM CTF###
         WHERE CTF_FILIAL= @cFILIAL_CTF
            AND CTF_DATA = @dDATA
            AND CTF_LOTE = @cLOTE
            AND CTF_SBLOTE = @cSUB
            AND CTF_DOC = @cDOC		
            AND D_E_L_E_T_ = ' '

      IF @nRECCTF IS NULL
      BEGIN
         SELECT @OUT_RET=7
         SELECT @nRECCTF=COALESCE(MAX(R_E_C_N_O_),0)+1 FROM CTF###
         INSERT INTO CTF### ( CTF_FILIAL, CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, CTF_LINHA, CTF_USADO, R_E_C_N_O_ )
         VALUES ( @cFILIAL_CTF, @dDATA, @cLOTE, @cSUB, @cDOC, @cLINHA, 'S', @nRECCTF )
      END
      ELSE
      BEGIN
         UPDATE CTF### SET CTF_LINHA=@cLINHA
         WHERE R_E_C_N_O_=@nRECCTF AND @cLINHA>CTF_LINHA
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

      select @iRecno = COALESCE(Max(R_E_C_N_O_), 0) + 1 FROM CT2###
      
      ##TRATARECNO @iRecno\
      ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
      INSERT INTO CT2### ( CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_MOEDLC, CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, --INSERT ENTIDADES
            CT2_EMPORI, CT2_FILORI, CT2_TPSALD, CT2_DTLP, CT2_MANUAL, CT2_ROTINA, CT2_AGLUT, CT2_SEQHIS, CT2_SEQLAN, CT2_TAXA, CT2_VLR01, CT2_VLR02, CT2_VLR03, CT2_VLR04, CT2_VLR05, CT2_CRCONV, CT2_CTLSLD, R_E_C_N_O_)
      VALUES             ( @cFILIAL_CT2  , @dDATA   , @cLOTE   , @cSUB      , @cDOC   , @cLINHA   , @cMOEDA    , @cTIPO , @cCTADB    , @cCTACR    , 0 , @cHIST   , @cCCDB  , @cCCCR  , @cITEMDB  , @cITEMCR  , @cCLVLDB   , @cCLVLCR   , --VALUES ENTIDADES
            @cEMPORI   , @cFILORI   , @cTPSALD   , @dDTLP   , '1'       , 'CTBA231' , '1'      , '001'     , @cLINHA    , 0       , 0        , 0        , 0        , 0        , 0        , '1'       , '0'       , @iRecno )
      ##CHECK_TRANSACTION_COMMIT
      ##FIMTRATARECNO
      
      SELECT @dDTANT=@dDATA

      SELECT @OUT_RET = 15
      
      SELECT @fim_CUR = 0
      FETCH CURSORCTB231 INTO @cEMPORI, @cFILORI,
      ##IF_001({|| __lMultiRot})
         @cCODIGO,
      ##ENDIF_001
      @cTPSALD, @cCTADB, @cCCDB, @cITEMDB, @cCLVLDB, @cCTACR, @cCCCR, @cITEMCR, @cCLVLCR, --CFETCHCUBE  @nVALOR, @dDATA, @cFORMUL, @cHAGLUT, @cHIST, @dDTLP, @cMOEDA, @cTIPO, @cLOTE, @cSUB, @cDOC, @cLINHA
   END
   CLOSE CURSORCTB231
   DEALLOCATE CURSORCTB231

   SELECT @OUT_RET=1
END