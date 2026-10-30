CREATE PROCEDURE CTBA231B_## (
   @IN_CFILIAL  CHAR( 'CT2_FILIAL' ),
	@IN_LMOEDESP CHAR( 1 ),
	@IN_CLOTE	 CHAR( 'CT2_LOTE' ),
	@IN_CSBLOTE	 CHAR( 'CT2_SBLOTE' ),
	@IN_CDOC	    CHAR( 'CT2_DOC' ),
	@IN_NMAXLIN  INTEGER,
   @IN_TRANSACTION CHAR(1),
   @OUT_RET	INTEGER OUTPUT ) AS

DECLARE @cFILORI      CHAR( 'CT2_FILIAL' )
DECLARE @cFILIAL_CTF  CHAR( 'CT2_FILIAL' )
DECLARE @cFILIAL_CT2  CHAR( 'CT2_FILIAL' )
DECLARE @cMOEDA       CHAR( 'CT2_MOEDLC' )
DECLARE @cCTADES      CHAR( 'CT2_DEBITO' )
DECLARE @cCCDES       CHAR( 'CT2_CCD' )
DECLARE @cITEMDE      CHAR( 'CT2_ITEMD' )
DECLARE @cCLVLDE      CHAR( 'CT2_CLVLDB' )
DECLARE @cLOTE        CHAR( 'CT2_LOTE' )
DECLARE @cSUB         CHAR( 'CT2_SBLOTE' )
DECLARE @cDOC         CHAR( 'CT2_DOC' )
DECLARE @cLINHA       CHAR( 'CT2_LINHA' )
DECLARE @cSeqIdx      CHAR( 'CT2_SEQIDX' )
DECLARE @cCTADEB      CHAR( 'CT2_DEBITO' )
DECLARE @cCTACRD      CHAR( 'CT2_DEBITO' )
DECLARE @cCUSDEB      CHAR( 'CT2_CCD' )
DECLARE @cCUSCRD      CHAR( 'CT2_CCD' )
DECLARE @cITEMDEB     CHAR( 'CT2_ITEMD' )
DECLARE @cITEMCRD     CHAR( 'CT2_ITEMD' )
DECLARE @cCLVLCRD     CHAR( 'CT2_CLVLDB' )
DECLARE @cCLVLDEB     CHAR( 'CT2_CLVLDB' )

DECLARE @cTPSALD      CHAR( 1 )
DECLARE @dDATA        CHAR( 8 )
DECLARE @cEMPORI      CHAR( 2 )
DECLARE @dDTLP        CHAR( 8 )
DECLARE @cLP          CHAR( 1 )
DECLARE @cTipo        CHAR( 1 )

DECLARE @nDEBITO      FLOAT
DECLARE @nCREDIT      FLOAT
DECLARE @nRDEBITO      FLOAT
DECLARE @nRCREDIT      FLOAT
DECLARE @nVALOR       FLOAT
DECLARE @nRECCTF      INTEGER
DECLARE @nI           INTEGER
DECLARE @nFLAG        INTEGER
DECLARE @nCRIA        INTEGER
DECLARE @iRecno       INTEGER
DECLARE @nLINDEB      INTEGER
DECLARE @nLINCRD      INTEGER
DECLARE @nLINHA       INTEGER
DECLARE @fim_CUR      INTEGER 

BEGIN
   SELECT @OUT_RET = 0
   SELECT @cLOTE = @IN_CLOTE  
   SELECT @cSUB  = @IN_CSBLOTE
   SELECT @cDOC  = @IN_CDOC

   EXEC XFILIAL_## 'CTF', @IN_CFILIAL, @cFILIAL_CTF OUTPUT
   EXEC XFILIAL_## 'CT2', @IN_CFILIAL, @cFILIAL_CT2 OUTPUT

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      UPDATE TRB
         SET 
            TRB.DEBITO  = TRB.DEBITO  - A.TOT_DEBITO,
            TRB.CREDITO = TRB.CREDITO - A.TOT_CREDITO
         FROM TRB###_36SP TRB
         INNER JOIN (
   ##ENDIF_001
   ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"}) --DEIXAR SOMENTE O SELECT E INSERIR O UPDATE NO PONTO DE ENTRADA 
      SELECT 'TRATAMENTOBANCO' TRATAMENTO FROM ( 
      /*UPDATE TRB###_36SP TRB
         SET 
            DEBITO  = TRB.DEBITO  - A.TOT_DEBITO,
            CREDITO = TRB.CREDITO - A.TOT_CREDITO
         FROM (*/
   ##ENDIF_002
            SELECT 
                  EMPORI,
                  FILORI,
                  CONTA_ORI,
                  CUSTO_ORI,
                  ITEM_ORI,
                  SUM(DEBITO)  AS TOT_DEBITO,
                  SUM(CREDITO) AS TOT_CREDITO
            FROM TRB###_36SP
            WHERE CLVL_ORI <> ' '
            GROUP BY 
                  EMPORI,
                  FILORI,
                  CONTA_ORI,
                  CUSTO_ORI,
                  ITEM_ORI
         ) A
      ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "ORACLE"})
         INNER JOIN DUAL
      ##ENDIF_003
      ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7/ORACLE"})
         ON  A.EMPORI    = TRB.EMPORI
      ##ENDIF_004
      ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES"})
         wHERE  A.EMPORI    = TRB.EMPORI
      ##ENDIF_005
         AND A.FILORI    = TRB.FILORI
         AND A.CONTA_ORI = TRB.CONTA_ORI
      ##IF_006({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
         WHERE 
      ##ENDIF_006
      ##IF_007({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
         AND
      ##ENDIF_007
      TRB.CLVL_ORI = ' '
      AND (
            -- Mesmo custo e mesmo item
            (TRB.CUSTO_ORI = A.CUSTO_ORI 
               AND TRB.ITEM_ORI = A.ITEM_ORI
               AND A.ITEM_ORI <> ' ')

         OR -- Mesmo custo, item em branco
            (TRB.CUSTO_ORI = A.CUSTO_ORI 
               AND TRB.ITEM_ORI = ' '
               AND A.CUSTO_ORI <> ' ')

         OR -- Custo em branco e item em branco
            (TRB.CUSTO_ORI = ' ' 
               AND TRB.ITEM_ORI = ' '
               AND A.CUSTO_ORI <> ' ')
         )
      ##IF_008({|| AllTrim(Upper(TcGetDB())) $ "ORACLE"})
         AND 1 = 1 --TRATADO NO PE
      ##ENDIF_008


      ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
         UPDATE TRB SET 
            TRB.DEBITO  = TRB.DEBITO  - A.TOT_DEBITO,
            TRB.CREDITO = TRB.CREDITO - A.TOT_CREDITO
         FROM TRB###_36SP TRB
         INNER JOIN (
      ##ENDIF_001
      ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"}) --DEIXAR SOMENTE O SELECT E INSERIR O UPDATE NO PONTO DE ENTRADA 
         SELECT 'TRATAMENTOBANCO' TRATAMENTO FROM ( 
         /*UPDATE TRB###_36SP TRB SET 
            DEBITO  = TRB.DEBITO  - A.TOT_DEBITO,
            CREDITO = TRB.CREDITO - A.TOT_CREDITO
         FROM  (*/
      ##ENDIF_002
            SELECT 
                  EMPORI,
                  FILORI,
                  CONTA_ORI,
                  CUSTO_ORI,
                  SUM(DEBITO)  AS TOT_DEBITO,
                  SUM(CREDITO) AS TOT_CREDITO
            FROM TRB###_36SP
            WHERE ITEM_ORI <> ' '
               AND CLVL_ORI = ' '
            GROUP BY 
                  EMPORI, 
                  FILORI, 
                  CONTA_ORI, 
                  CUSTO_ORI
         ) A
      ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "ORACLE"})
         INNER JOIN DUAL
      ##ENDIF_003
      ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7/ORACLE"})
         ON  A.EMPORI    = TRB.EMPORI
      ##ENDIF_004
      ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES"})
         WHERE A.EMPORI    = TRB.EMPORI
      ##ENDIF_005
         AND A.FILORI    = TRB.FILORI
         AND A.CONTA_ORI = TRB.CONTA_ORI
      ##IF_006({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
         WHERE
      ##ENDIF_006
      ##IF_007({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
         AND
      ##ENDIF_007
      (
            (TRB.CUSTO_ORI = A.CUSTO_ORI 
            AND TRB.ITEM_ORI = ' ' 
            AND TRB.CLVL_ORI = ' '
            AND A.CUSTO_ORI <> ' ')
         OR 
            (TRB.CUSTO_ORI = ' ' 
            AND TRB.ITEM_ORI = ' ' 
            AND TRB.CLVL_ORI = ' ')
         )
      ##IF_008({|| AllTrim(Upper(TcGetDB())) $ "ORACLE"})
         AND 1 = 1 --TRATADO NO PE
      ##ENDIF_008

   ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
      UPDATE TRB
         SET 
            TRB.DEBITO  = TRB.DEBITO  - A.TOT_DEBITO,
            TRB.CREDITO = TRB.CREDITO - A.TOT_CREDITO
         FROM TRB###_36SP TRB
         INNER JOIN (
    ##ENDIF_001
    ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"}) --DEIXAR SOMENTE O SELECT E INSERIR O UPDATE NO PONTO DE ENTRADA 
      SELECT 'TRATAMENTOBANCO' TRATAMENTO FROM ( 
      /*UPDATE TRB###_36SP TRB
         SET 
            DEBITO  = TRB.DEBITO  - A.TOT_DEBITO,
            CREDITO = TRB.CREDITO - A.TOT_CREDITO
         FROM (*/
   ##ENDIF_002
            SELECT 
                  EMPORI,
                  FILORI,
                  CONTA_ORI,
                  SUM(DEBITO)  AS TOT_DEBITO,
                  SUM(CREDITO) AS TOT_CREDITO
            FROM TRB###_36SP
            WHERE CUSTO_ORI <> ' '
               AND ITEM_ORI  = ' '
               AND CLVL_ORI  = ' '
            GROUP BY 
                  EMPORI,
                  FILORI,
                  CONTA_ORI
         ) A
      ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "ORACLE"})
         INNER JOIN DUAL
      ##ENDIF_003
      ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7/ORACLE"})
         ON  A.EMPORI    = TRB.EMPORI
      ##ENDIF_004
      ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES"})
         WHERE A.EMPORI    = TRB.EMPORI
      ##ENDIF_005
         AND A.FILORI    = TRB.FILORI
         AND A.CONTA_ORI = TRB.CONTA_ORI
      ##IF_006({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
         WHERE
      ##ENDIF_006
      ##IF_007({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
         AND
      ##ENDIF_007
      TRB.CUSTO_ORI = ' '
      AND TRB.ITEM_ORI  = ' '
      AND TRB.CLVL_ORI  = ' '
      ##IF_008({|| AllTrim(Upper(TcGetDB())) $ "ORACLE"})
         AND 1 = 1 --TRATADO NO PE
      ##ENDIF_008
   
   SELECT @OUT_RET  = 6   

   SELECT @nLINCRD = 0
   SELECT @nLINDEB = 0
   SELECT @nLINHA  = 0

   -- CURSOR DECLARATION CUR1
   DECLARE CUR1 insensitive CURSOR FOR 
   SELECT MAX(EMPORI) AS EMPORI, MAX(FILORI) AS FILORI, CDATA, MOEDA, TPSALD, CONTA, CUSTO, ITEM, CLVL, DTLP, SUM(DEBITO) AS DEBITO, SUM(CREDITO) AS CREDITO 
   FROM TRB###_36SP   
   GROUP BY CDATA, MOEDA, TPSALD, CONTA, CUSTO, ITEM, CLVL, DTLP
   ORDER BY CDATA, MOEDA, TPSALD, DTLP 
   FOR READ ONLY 
      
   OPEN CUR1      
   FETCH CUR1 INTO @cEMPORI, @cFILORI, @dDATA, @cMOEDA, @cTPSALD, @cCTADES, @cCCDES, @cITEMDE, @cCLVLDE, @dDTLP, @nDEBITO, @nCREDIT 
      WHILE (@@FETCH_STATUS  = 0 )
      BEGIN
         SELECT @nFLAG  = 1 
         SELECT @nCRIA  = 1 
         SELECT @nVALOR  = @nCREDIT  - @nDEBITO 
         SELECT @nRCREDIT = ROUND(@nCREDIT,2)
         SELECT @nRDEBITO = ROUND(@nDEBITO,2)
         WHILE (@nFLAG  < 3 )
         BEGIN
            IF ( @nRCREDIT = @nRDEBITO )  AND  @nRCREDIT <> 0  
            BEGIN 
               IF @nFLAG  = 1 
               BEGIN 
                  SELECT @nVALOR  = @nCREDIT 
                  SELECT @nFLAG  = 2 
               END 
               ELSE 
               BEGIN 
                  IF @nFLAG  = 2 
                  BEGIN 
                     SELECT @nVALOR  =  (0  - @nDEBITO ) 
                     SELECT @nFLAG  = 3 
                  END 
               END 
               SELECT @nCRIA  = 1 
            END 
            ELSE 
            BEGIN 
               IF ROUND(@nVALOR,2) <> 0 
               BEGIN 
                  SELECT @nCRIA  = 1 
               END 
               ELSE 
               BEGIN 
                  SELECT @nCRIA  = 0 
               END 
               SELECT @nFLAG  = 3 
            END 
            IF @nCRIA  = 1 
            BEGIN 
               IF @nLINHA  >= @IN_NMAXLIN
               BEGIN 
                  IF @cDOC  = '999999' 
                  BEGIN 
                     SELECT @cDOC  = '000001' 
                     IF @cLOTE  = '999999' 
                     BEGIN 
                        SELECT @OUT_RET  = 8 
                        SELECT @cLOTE  = '000001' 
                        SELECT @nI  = CONVERT( INTEGER ,@cSUB ) + 1                         

                        exec MSSTRZERO @nI, 3, @cSUB OutPut                        
                     END 
                     ELSE 
                     BEGIN 
                        SELECT @OUT_RET  = 9 
                        SELECT @nI  = CONVERT( INTEGER ,@cLOTE ) + 1                         
                        
                        exec MSSTRZERO @nI, 6, @cLOTE OutPut  
                     END 
                  END 
                  ELSE 
                  BEGIN 
                     SELECT @OUT_RET  = 10 
                     IF (@IN_LMOEDESP = '0' AND @cMOEDA  = '01') OR (@IN_LMOEDESP = '1')
                     BEGIN 
                        SELECT @nI  = CONVERT( INTEGER ,@cDOC ) + 1                         
                        
                        exec MSSTRZERO @nI, 6, @cDOC OutPut
                     END 
                  END 
                  SELECT @nLINHA   = 1
                  SELECT @OUT_RET  = 11 
               END 
               ELSE 
               BEGIN 
                  SELECT @OUT_RET  = 12 
                  IF (@IN_LMOEDESP = '0' AND @cMOEDA  = '01') OR (@IN_LMOEDESP = '1') 
                  BEGIN 
                     SELECT @nLINHA = @nLINHA + 1

                     If @nFLAG = 2 
                     BEGIN
                        SELECT @nLINCRD  = @nLINHA
                     END
                     ELSE
                     BEGIN
                        SELECT @nLINDEB  = @nLINHA                        
                     END
                  END 
               END 

               IF @nVALOR  < 0 
               BEGIN 
                  SELECT @OUT_RET  = 13 
                  SELECT @nVALOR  = @nVALOR  *  (-   1 ) 
                  SELECT @cTipo = '1'
                  SELECT @cCTADEB  = @cCTADES
                  SELECT @cCUSDEB  = @cCCDES
                  SELECT @cITEMDEB = @cITEMDE
                  SELECT @cCLVLDEB = @cCLVLDE
                  SELECT @cCTACRD  = ' '
                  SELECT @cCUSCRD  = ' '
                  SELECT @cITEMCRD  = ' '
                  SELECT @cCLVLCRD = ' '

                  exec MSSTRZERO @nLINDEB, 3, @cLINHA OutPut 
               END 
               ELSE 
               BEGIN 
                  SELECT @cCTACRD  = @cCTADES
                  SELECT @cCUSCRD  = @cCCDES
                  SELECT @cITEMCRD = @cITEMDE
                  SELECT @cCLVLCRD = @cCLVLDE
                  SELECT @cCTADEB  = ' '
                  SELECT @cCUSDEB  = ' '
                  SELECT @cITEMDEB = ' '
                  SELECT @cCLVLDEB = ' '

                  exec MSSTRZERO @nLINCRD, 3, @cLINHA OutPut 
                  SELECT @OUT_RET  = 14 
                  SELECT @cTipo = '2'
               END 

               SELECT @nRECCTF  = MIN ( R_E_C_N_O_ )
               FROM CTF### 
               WHERE CTF_FILIAL  = @cFILIAL_CTF  AND CTF_DATA  = @dDATA  AND CTF_LOTE  = @cLOTE  AND CTF_SBLOTE  = @cSUB  AND CTF_DOC  = @cDOC 
                  AND D_E_L_E_T_  = ' ' 
               IF @nRECCTF IS NULL 
               BEGIN 
                  SELECT @OUT_RET  = 7 
                  SELECT @nRECCTF  = COALESCE(MAX(R_E_C_N_O_),0) + 1 
                  FROM CTF### 
                  INSERT INTO CTF### (CTF_FILIAL, CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, CTF_LINHA, CTF_USADO, R_E_C_N_O_ ) 
                  VALUES (@cFILIAL_CTF, @dDATA, @cLOTE, @cSUB, @cDOC, @cLINHA, 'S', @nRECCTF)
               END 
               ELSE 
               BEGIN 
                  UPDATE CTF###  
                     SET CTF_LINHA  = @cLINHA 
                  WHERE R_E_C_N_O_  = @nRECCTF 
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
                  INSERT INTO CT2### (CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_MOEDLC, CT2_DC, 
                           CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, 
                           CT2_CLVLDB, CT2_CLVLCR, CT2_EMPORI, CT2_FILORI, CT2_TPSALD, 
                           CT2_DTLP, CT2_MANUAL, CT2_ROTINA, CT2_AGLUT, CT2_SEQHIS, CT2_SEQLAN, CT2_TAXA, CT2_VLR01, CT2_VLR02, 
                           CT2_VLR03, CT2_VLR04, CT2_VLR05, CT2_CRCONV, CT2_CTLSLD, R_E_C_N_O_) 
                  VALUES (@cFILIAL_CT2, @dDATA, @cLOTE, @cSUB, @cDOC, @cLINHA, @cMOEDA, @cTipo, @cCTADEB, @cCTACRD, 0, 'SALDO INICIAL', 
                        @cCUSDEB, @cCUSCRD, @cITEMDEB, @cITEMCRD, @cCLVLDEB, @cCLVLCRD, @cEMPORI, @cFILORI, @cTPSALD, @dDTLP, '1', 'CTBA231', '1', '001', 
                        @cLINHA, 0, 0, 0, 0, 0, 0, '1', '0', @iRecno)
                  ##CHECK_TRANSACTION_COMMIT
                  ##FIMTRATARECNO
               END 

               ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
               Update CT2###
                  set CT2_VALOR = CT2_VALOR + @nVALOR
                  Where R_E_C_N_O_ = @iRecno
               ##CHECK_TRANSACTION_COMMIT
            END
         END 
         SELECT @OUT_RET  = 15 
         
         SELECT @fim_CUR = 0
         FETCH CUR1 INTO @cEMPORI, @cFILORI, @dDATA, @cMOEDA, @cTPSALD, @cCTADES, @cCCDES, @cITEMDE, @cCLVLDE, @dDTLP, @nDEBITO, @nCREDIT 
      END 
   CLOSE CUR1
   DEALLOCATE CUR1

   SELECT @OUT_RET  = 1 
END 