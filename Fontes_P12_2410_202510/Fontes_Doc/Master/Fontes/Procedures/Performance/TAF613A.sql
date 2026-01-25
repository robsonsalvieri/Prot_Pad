CREATE PROCEDURE TAF613A_##(
    @IN_FILIAL CHAR('B1_FILIAL'),
    @IN_PENDING_STATUS CHAR('C20_STATUS'),
    @IN_ATUDOC CHAR('C20_ATUDOC'),
    @IN_MV_ICMPAD FLOAT,
    @IN_MV_BLKTP00 VARCHAR(255),
    @IN_MV_BLKTP01 VARCHAR(255),
    @IN_MV_BLKTP02 VARCHAR(255),
    @IN_MV_BLKTP03 VARCHAR(255),
    @IN_MV_BLKTP04 VARCHAR(255),
    @IN_MV_BLKTP06 VARCHAR(255),
    @IN_MV_BLKTP10 VARCHAR(255),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAFA613A </s>
    Descricao   -  <d> Integração entre ERP Livros Fiscais X TAF (SPED) - Produtos </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
                        @IN_PENDING_STATUS - Status do Documento Fiscal pendente para Integração (C20_STATUS)
                        @IN_ATUDOC - Status de atualização do documento: 1 - Inclusão; 2 - Cancelamento; 3 - Exclusão; 4 = Complemento 
                        @IN_MV_ICMPAD - Conteúdo do parâmetro MV_ICMPAD 
                        @IN_MV_BLKTP00 - Conteúdo do parâmetro MV_BLKTP00 
                        @IN_MV_BLKTP01 - Conteúdo do parâmetro MV_BLKTP01 
                        @IN_MV_BLKTP02 - Conteúdo do parâmetro MV_BLKTP02 
                        @IN_MV_BLKTP03 - Conteúdo do parâmetro MV_BLKTP03 
                        @IN_MV_BLKTP04 - Conteúdo do parâmetro MV_BLKTP04 
                        @IN_MV_BLKTP06 - Conteúdo do parâmetro MV_BLKTP06 
                        @IN_MV_BLKTP10 - Conteúdo do parâmetro MV_BLKTP10 </ri>  
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execução da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Melkz Siqueira </r>
    Data        :  <dt> 24/07/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */

DECLARE @SB1            CHAR(3)
DECLARE @SFT            CHAR(3)
DECLARE @C20            CHAR(3)
DECLARE @C1L            CHAR(3)
DECLARE @C1J            CHAR(3)
DECLARE @C0A            CHAR(3)
DECLARE @CDN            CHAR(3)
DECLARE @C3X            CHAR(3)
DECLARE @C03            CHAR(3)
DECLARE @T5E            CHAR(3)
DECLARE @T5F            CHAR(3)
DECLARE @T71            CHAR(3)
DECLARE @F2Q            CHAR(3)
DECLARE @SB5            CHAR(3)
DECLARE @C0B            CHAR(3)
DECLARE @C3Z            CHAR(3)
DECLARE @C8C            CHAR(3)
DECLARE @FILIAL_SB1     VARCHAR('B1_FILIAL') 
DECLARE @FILIAL_SFT     VARCHAR('FT_FILIAL') 
DECLARE @FILIAL_C20     VARCHAR('C20_FILIAL')
DECLARE @FILIAL_C1L     VARCHAR('C1L_FILIAL')
DECLARE @FILIAL_C1J     VARCHAR('C1J_FILIAL')
DECLARE @FILIAL_C0A     VARCHAR('C0A_FILIAL')
DECLARE @FILIAL_CDN     VARCHAR('CDN_FILIAL')
DECLARE @FILIAL_C3X     VARCHAR('C3X_FILIAL')
DECLARE @FILIAL_C03     VARCHAR('C03_FILIAL')
DECLARE @FILIAL_T5E     VARCHAR('T5E_FILIAL')
DECLARE @FILIAL_T5F     VARCHAR('T5F_FILIAL')
DECLARE @FILIAL_T71     VARCHAR('T71_FILIAL')
DECLARE @FILIAL_F2Q     VARCHAR('F2Q_FILIAL')
DECLARE @FILIAL_SB5     VARCHAR('B5_FILIAL')
DECLARE @FILIAL_C0B     VARCHAR('C0B_FILIAL')
DECLARE @FILIAL_C3Z     VARCHAR('C3Z_FILIAL')
DECLARE @FILIAL_C8C     VARCHAR('C8C_FILIAL')
DECLARE @ID_C1L         VARCHAR('C1L_ID')
DECLARE @COD_ITEM       VARCHAR('C1L_CODIGO')
DECLARE @DESCR_ITEM     VARCHAR('C1L_DESCRI')
DECLARE @COD_BARRA      VARCHAR('C1L_CODBAR')
DECLARE @UNID_INV       VARCHAR('C1L_UM')
DECLARE @TIPO_ITEM      VARCHAR('B1_TIPO')
DECLARE @TIPO_ITEM_ID   VARCHAR('C1L_TIPITE')
DECLARE @COD_NCM        VARCHAR('C1L_CODNCM')
DECLARE @COD_GEN        VARCHAR('C1L_CODGEN')
DECLARE @COD_LST        VARCHAR('C1L_CODSER')
DECLARE @COD_COMB       VARCHAR('C1L_CODANP')
DECLARE @COD_GRU        VARCHAR('C1L_CODIND')
DECLARE @ORIGEM         VARCHAR('C1L_ORIMER') 
DECLARE @DT_INCLUSAO    VARCHAR('C1L_DTINCL')      
DECLARE @ESTOQUE        VARCHAR('C1L_ESTOQ')  
DECLARE @COD_CFQ        VARCHAR('C1L_IDCFQ')  
DECLARE @COD_SERV_MUN   CHAR('C1L_SRVMUN')
DECLARE @COD_SERV_MUN_A CHAR('C1L_SRVMUN') 
DECLARE @COD_SERV_MUN_B CHAR('C1L_SRVMUN')       
DECLARE @TP_PRD         VARCHAR('C1L_TPPRD') 
DECLARE @COD_CNM        VARCHAR('C1L_IDCNM')  
DECLARE @COD_GLP        VARCHAR('C1L_IDGLP')  
DECLARE @COD_AFE        VARCHAR('C1L_IDAFE')  
DECLARE @COD_UM         VARCHAR('C1L_IDUM') 
DECLARE @COD_CERTIF     VARCHAR('C1L_CERTIF')  
DECLARE @CEST           VARCHAR('C1L_IDCEST')  
DECLARE @TIP_SERV       VARCHAR('C1L_IDTSER')  
DECLARE @ALIQ_ICMS      DECIMAL('C1L_ALQICM')
DECLARE @ALIQ_IPI       DECIMAL('C1L_ALQIPI')
DECLARE @RED_BC_ICMS    DECIMAL('C1L_REDBC')
DECLARE @PROD_ATU       VARCHAR('C1L_FILIAL;C1L_CODIGO')
DECLARE @PROD_ANT       VARCHAR('C1L_FILIAL;C1L_CODIGO')

BEGIN
    SELECT @OUT_RESULT      = '0'
    SELECT @SB1             = 'SB1'
    SELECT @SFT             = 'SFT'
    SELECT @C20             = 'C20'
    SELECT @C1L             = 'C1L'
    SELECT @C1J             = 'C1J'
    SELECT @C0A             = 'C0A'
    SELECT @CDN             = 'CDN'
    SELECT @C3X             = 'C3X'
    SELECT @C03             = 'C03'
    SELECT @T5E             = 'T5E'
    SELECT @T5F             = 'T5F'
    SELECT @T71             = 'T71'
    SELECT @F2Q             = 'F2Q'
    SELECT @SB5             = 'SB5'
    SELECT @C0B             = 'C0B'
    SELECT @C3Z             = 'C3Z'
    SELECT @C8C             = 'C8C'
    SELECT @TIPO_ITEM_ID    = ' '
    SELECT @PROD_ATU        = ' '
    SELECT @PROD_ANT        = ' '

    EXEC XFILIAL_## @SB1, @IN_FILIAL, @FILIAL_SB1 OUTPUT
    EXEC XFILIAL_## @SFT, @IN_FILIAL, @FILIAL_SFT OUTPUT
    EXEC XFILIAL_## @C20, @IN_FILIAL, @FILIAL_C20 OUTPUT
    EXEC XFILIAL_## @C1L, @IN_FILIAL, @FILIAL_C1L OUTPUT
    EXEC XFILIAL_## @C1J, @IN_FILIAL, @FILIAL_C1J OUTPUT
    EXEC XFILIAL_## @C0A, @IN_FILIAL, @FILIAL_C0A OUTPUT
    EXEC XFILIAL_## @CDN, @IN_FILIAL, @FILIAL_CDN OUTPUT
    EXEC XFILIAL_## @C3X, @IN_FILIAL, @FILIAL_C3X OUTPUT
    EXEC XFILIAL_## @C03, @IN_FILIAL, @FILIAL_C03 OUTPUT
    EXEC XFILIAL_## @T5E, @IN_FILIAL, @FILIAL_T5E OUTPUT
    EXEC XFILIAL_## @T5F, @IN_FILIAL, @FILIAL_T5F OUTPUT
    EXEC XFILIAL_## @T71, @IN_FILIAL, @FILIAL_T71 OUTPUT
    EXEC XFILIAL_## @F2Q, @IN_FILIAL, @FILIAL_F2Q OUTPUT
    EXEC XFILIAL_## @SB5, @IN_FILIAL, @FILIAL_SB5 OUTPUT
    EXEC XFILIAL_## @C0B, @IN_FILIAL, @FILIAL_C0B OUTPUT
    EXEC XFILIAL_## @C3Z, @IN_FILIAL, @FILIAL_C3Z OUTPUT
    EXEC XFILIAL_## @C8C, @IN_FILIAL, @FILIAL_C8C OUTPUT

    DECLARE PRODUTOS_UPDATE INSENSITIVE CURSOR FOR
        SELECT
            SB1.B1_COD COD_ITEM,
            SB1.B1_DESC DESCR_ITEM,
            SB1.B1_CODBAR COD_BARRA,
            C1J.C1J_ID UNID_INV,
            SB1.B1_TIPO TIPO_ITEM,
            COALESCE(C0A.C0A_ID, ' ') COD_NCM,
            C3Z.C3Z_ID COD_GEN,
            COALESCE(C0B.C0B_ID, ' ') COD_LST,
            ' ' COD_COMB, 
            COALESCE(C3X.C3X_ID, ' ') COD_GRU,
            COALESCE(C03.C03_ID, ' ') ORIGEM,
            SB1.B1_DATREF DT_INCLUSAO,
            COALESCE(SB1.B1_PICM, 0) ALIQ_ICMS,
            SB1.B1_IPI ALIQ_IPI,
            0 RED_BC_ICMS,
            ' ' ESTOQUE,
            ' ' COD_CFQ,
            COALESCE(CDNA.CDN_CODLST, ' ') COD_SERV_MUN_A, 
            COALESCE(CDNB.CDN_CODLST, ' ') COD_SERV_MUN_B,
            ' ' TP_PRD,
            ' ' COD_CNM,
            COALESCE(T5E.T5E_ID, ' ') COD_GLP,
            COALESCE(T5F.T5F_ID, ' ') COD_AFE,
            ' ' COD_UM, 
            ' ' COD_CERTIF,
            COALESCE(T71.T71_ID, ' ') CEST,
            COALESCE(C8C.C8C_ID, ' ') TIP_SERV
        FROM SB1### SB1
            INNER JOIN SFT### SFT 
                ON SFT.D_E_L_E_T_ = ' '
                    AND SFT.FT_FILIAL = @FILIAL_SFT
                    AND SFT.FT_PRODUTO = SB1.B1_COD
            INNER JOIN C20### C20 
                ON C20.D_E_L_E_T_ = ' '
                    AND C20.C20_FILIAL = @FILIAL_C20
                    AND C20.C20_STATUS = @IN_PENDING_STATUS
                    AND C20.C20_ATUDOC = @IN_ATUDOC
                    AND C20.C20_NUMDOC = SFT.FT_NFISCAL
                    AND C20.C20_SERIE = SFT.FT_SERIE
                    AND C20.C20_CLIFOR = SFT.FT_CLIEFOR
                    AND C20.C20_LOJA = SFT.FT_LOJA
                    AND (C20.C20_DTES = SFT.FT_ENTRADA 
                        OR C20.C20_DTDOC = SFT.FT_EMISSAO)
            INNER JOIN C1J### C1J
                ON C1J.C1J_FILIAL = @FILIAL_C1J
                    AND C1J.C1J_CODIGO = SB1.B1_UM
                    AND C1J.D_E_L_E_T_ = ' '
            INNER JOIN C1L### C1L
                ON C1L.D_E_L_E_T_ = ' ' 
                    AND C1L.C1L_FILIAL = @FILIAL_C1L
                    AND C1L.C1L_CODIGO = SB1.B1_COD
            LEFT JOIN CDN### CDNA
                ON CDNA.CDN_FILIAL = @FILIAL_CDN
                    AND CDNA.CDN_CODISS = SB1.B1_CODISS
                    AND CDNA.CDN_PROD = SB1.B1_COD
                    AND CDNA.D_E_L_E_T_ = ' '
            LEFT JOIN CDN### CDNB
                ON CDNB.CDN_FILIAL = @FILIAL_CDN
                    AND CDNB.CDN_CODISS = SB1.B1_CODISS
                    AND CDNB.D_E_L_E_T_ = ' '
            LEFT JOIN SB5### SB5
                ON SB5.B5_FILIAL = @FILIAL_SB5
                    AND SB5.B5_COD = SB1.B1_COD
                    AND SB5.D_E_L_E_T_ = ' '
            LEFT JOIN F2Q### F2Q
                ON F2Q.F2Q_FILIAL = @FILIAL_F2Q
                    AND F2Q.F2Q_PRODUT = SB1.B1_COD
                    AND F2Q.D_E_L_E_T_ = ' '
            LEFT JOIN C8C### C8C
                ON C8C.C8C_FILIAL = @FILIAL_C8C
                    AND C8C.D_E_L_E_T_ = ' '
                    AND (C8C.C8C_CODIGO = F2Q.F2Q_TPSERV 
                        OR C8C.C8C_CODIGO = CDNA.CDN_CODLST 
                        OR C8C.C8C_CODIGO = CDNB.CDN_CODLST)
            LEFT JOIN C0A### C0A
                ON C0A.C0A_FILIAL = @FILIAL_C0A
                    AND C0A.C0A_CODIGO = SB1.B1_POSIPI
                    AND C0A.D_E_L_E_T_ = ' '
                    AND C0A.C0A_EXNCM  = ' '
            LEFT JOIN C3Z### C3Z
                ON C3Z.C3Z_FILIAL = @FILIAL_C3Z
                    AND C3Z.D_E_L_E_T_ = ' '
                    AND (C3Z.C3Z_CODIGO = SUBSTRING(SB1.B1_CODISS, 1, 2)
                        OR C3Z.C3Z_CODIGO = '00')
            LEFT JOIN C0B### C0B
                ON C0B.C0B_FILIAL = @FILIAL_C0B
                    AND C0B.D_E_L_E_T_ = ' '
                    AND (C0B.C0B_CODIGO = REPLACE(CDNA.CDN_CODLST, '.', '') 
                        OR C0B.C0B_CODIGO = REPLACE(CDNB.CDN_CODLST, '.', ''))
            LEFT JOIN C3X### C3X
                ON C3X.C3X_FILIAL = @FILIAL_C3X
                    AND C3X.C3X_CODTAB = SB5.B5_CODGRU
                    AND C3X.D_E_L_E_T_ = ' '
            LEFT JOIN C03### C03
                ON C03.C03_FILIAL = @FILIAL_C03
                    AND C03.C03_CODIGO = SB1.B1_ORIGEM
                    AND C03.D_E_L_E_T_ = ' '
            LEFT JOIN T71### T71
                ON T71.T71_FILIAL = @FILIAL_T71
                    AND T71.T71_CODIGO = SB1.B1_CEST
                    AND T71.D_E_L_E_T_ = ' '
            LEFT JOIN T5E### T5E
                ON T5E.T5E_FILIAL = @FILIAL_T5E
                    AND T5E.T5E_CODIGO = ' ' 
                    AND T5E.D_E_L_E_T_ = ' '
            LEFT JOIN T5F### T5F
                ON T5F.T5F_FILIAL = @FILIAL_T5F
                    AND T5F.T5F_CODIGO = ' '
                    AND T5F.D_E_L_E_T_ = ' '
        WHERE
            SB1.D_E_L_E_T_ = ' '
            AND SB1.B1_FILIAL = @FILIAL_SB1
        GROUP BY SB1.B1_COD, SB1.B1_DESC, SB1.B1_CODBAR, C1J.C1J_ID, SB1.B1_TIPO,
            C0A.C0A_ID, C3Z.C3Z_ID, C0B.C0B_ID, C3X.C3X_ID, C03.C03_ID, SB1.B1_DATREF,
                SB1.B1_PICM, SB1.B1_IPI, CDNA.CDN_CODLST, CDNB.CDN_CODLST, T5E.T5E_ID,
                    T5F.T5F_ID, T71.T71_ID, C8C.C8C_ID
                    
    FOR READ ONLY    
    OPEN PRODUTOS_UPDATE

    FETCH PRODUTOS_UPDATE 
        INTO
            @COD_ITEM,
            @DESCR_ITEM,
            @COD_BARRA,
            @UNID_INV,
            @TIPO_ITEM,
            @COD_NCM,
            @COD_GEN,
            @COD_LST,
            @COD_COMB,
            @COD_GRU,
            @ORIGEM,
            @DT_INCLUSAO,
            @ALIQ_ICMS,
            @ALIQ_IPI,
            @RED_BC_ICMS,
            @ESTOQUE,
            @COD_CFQ,
            @COD_SERV_MUN_A,
            @COD_SERV_MUN_B,
            @TP_PRD,
            @COD_CNM,
            @COD_GLP,
            @COD_AFE,
            @COD_UM,
            @COD_CERTIF,
            @CEST,
            @TIP_SERV

    BEGIN TRANSACTION

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                SELECT @PROD_ATU = @FILIAL_C1L + @COD_ITEM
            ##ENDIF_001
            
            ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
                SELECT @PROD_ATU = @FILIAL_C1L || @COD_ITEM
            ##ENDIF_002

            IF @PROD_ANT <> @PROD_ATU
                BEGIN
                    ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                        SELECT @PROD_ANT = @FILIAL_C1L + @COD_ITEM
                    ##ENDIF_003
                    
                    ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
                        SELECT @PROD_ANT = @FILIAL_C1L || @COD_ITEM
                    ##ENDIF_004

                    IF @COD_SERV_MUN_A <> ' '
                        BEGIN
                            SELECT @COD_SERV_MUN = @COD_SERV_MUN_A
                        END
                    ELSE
                        BEGIN
                            SELECT @COD_SERV_MUN = @COD_SERV_MUN_B
                        END

                    IF @ALIQ_ICMS = 0 
                        BEGIN
                            SELECT @ALIQ_ICMS = @IN_MV_ICMPAD
                        END
                
                    EXEC TAF613E_## @IN_FILIAL, @TIPO_ITEM, @COD_SERV_MUN, @IN_MV_BLKTP00,
                        @IN_MV_BLKTP01, @IN_MV_BLKTP02, @IN_MV_BLKTP03, @IN_MV_BLKTP04,
                        @IN_MV_BLKTP06, @IN_MV_BLKTP10, @TIPO_ITEM_ID OUTPUT

                    UPDATE C1L###
                        SET 
                            C1L_DESCRI = @DESCR_ITEM,
                            C1L_CODBAR = @COD_BARRA,
                            C1L_UM = @UNID_INV,
                            C1L_TIPITE = @TIPO_ITEM_ID,
                            C1L_CODNCM = @COD_NCM,
                            C1L_CODGEN = @COD_GEN,
                            C1L_CODSER = @COD_LST,
                            C1L_CODANP = @COD_COMB,
                            C1L_CODIND = @COD_GRU,
                            C1L_ORIMER = @ORIGEM,
                            C1L_DTINCL = @DT_INCLUSAO,
                            C1L_ALQICM = @ALIQ_ICMS,
                            C1L_ALQIPI = @ALIQ_IPI,
                            C1L_REDBC = @RED_BC_ICMS,
                            C1L_ESTOQ = @ESTOQUE,
                            C1L_IDCFQ = @COD_CFQ,
                            C1L_SRVMUN = @COD_SERV_MUN,
                            C1L_TPPRD = @TP_PRD,
                            C1L_IDCNM = @COD_CNM,
                            C1L_IDGLP = @COD_GLP,
                            C1L_IDAFE = @COD_AFE,
                            C1L_IDUM = @COD_UM,
                            C1L_CERTIF = @COD_CERTIF,
                            C1L_IDCEST = @CEST,
                            C1L_IDTSER = @TIP_SERV
                        WHERE D_E_L_E_T_ = ' ' 
                            AND C1L_FILIAL = @FILIAL_C1L 
                            AND C1L_CODIGO = @COD_ITEM
                END
                FETCH PRODUTOS_UPDATE 
                    INTO
                        @COD_ITEM,
                        @DESCR_ITEM,
                        @COD_BARRA,
                        @UNID_INV,
                        @TIPO_ITEM,
                        @COD_NCM,
                        @COD_GEN,
                        @COD_LST,
                        @COD_COMB,
                        @COD_GRU,
                        @ORIGEM,
                        @DT_INCLUSAO,
                        @ALIQ_ICMS,
                        @ALIQ_IPI,
                        @RED_BC_ICMS,
                        @ESTOQUE,
                        @COD_CFQ,
                        @COD_SERV_MUN_A,
                        @COD_SERV_MUN_B,
                        @TP_PRD,
                        @COD_CNM,
                        @COD_GLP,
                        @COD_AFE,
                        @COD_UM,
                        @COD_CERTIF,
                        @CEST,
                        @TIP_SERV
        END 

    COMMIT TRANSACTION

    CLOSE PRODUTOS_UPDATE
    DEALLOCATE PRODUTOS_UPDATE

    DECLARE PRODUTOS_INSERT INSENSITIVE CURSOR FOR
        SELECT
            SB1.B1_COD COD_ITEM,
            SB1.B1_DESC DESCR_ITEM,
            SB1.B1_CODBAR COD_BARRA,
            C1J.C1J_ID UNID_INV,
            SB1.B1_TIPO TIPO_ITEM,
            COALESCE(C0A.C0A_ID, ' ') COD_NCM,
            C3Z.C3Z_ID COD_GEN,
            COALESCE(C0B.C0B_ID, ' ') COD_LST,
            ' ' COD_COMB, 
            COALESCE(C3X.C3X_ID, ' ') COD_GRU,
            COALESCE(C03.C03_ID, ' ') ORIGEM,
            SB1.B1_DATREF DT_INCLUSAO,
            COALESCE(SB1.B1_PICM, 0) ALIQ_ICMS,
            SB1.B1_IPI ALIQ_IPI,
            0 RED_BC_ICMS,
            ' ' ESTOQUE,
            ' ' COD_CFQ,
            COALESCE(CDNA.CDN_CODLST, ' ') COD_SERV_MUN_A, 
            COALESCE(CDNB.CDN_CODLST, ' ') COD_SERV_MUN_B,
            ' ' TP_PRD,
            ' ' COD_CNM,
            COALESCE(T5E.T5E_ID, ' ') COD_GLP,
            COALESCE(T5F.T5F_ID, ' ') COD_AFE,
            ' ' COD_UM, 
            ' ' COD_CERTIF,
            COALESCE(T71.T71_ID, ' ') CEST,
            COALESCE(C8C.C8C_ID, ' ') TIP_SERV
        FROM SB1### SB1
            INNER JOIN SFT### SFT 
                ON SFT.D_E_L_E_T_ = ' '
                    AND SFT.FT_FILIAL = @FILIAL_SFT
                    AND SFT.FT_PRODUTO = SB1.B1_COD
            INNER JOIN C20### C20 
                ON C20.D_E_L_E_T_ = ' '
                    AND C20.C20_FILIAL = @FILIAL_C20
                    AND C20.C20_STATUS = @IN_PENDING_STATUS
                    AND C20.C20_ATUDOC = @IN_ATUDOC
                    AND C20.C20_NUMDOC = SFT.FT_NFISCAL
                    AND C20.C20_SERIE = SFT.FT_SERIE
                    AND C20.C20_CLIFOR = SFT.FT_CLIEFOR
                    AND C20.C20_LOJA = SFT.FT_LOJA
                    AND (C20.C20_DTES = SFT.FT_ENTRADA 
                        OR C20.C20_DTDOC = SFT.FT_EMISSAO)
            INNER JOIN C1J### C1J
                ON C1J.C1J_FILIAL = @FILIAL_C1J
                    AND C1J.C1J_CODIGO = SB1.B1_UM
                    AND C1J.D_E_L_E_T_ = ' '
            LEFT JOIN C1L### C1L
                ON C1L.D_E_L_E_T_ = ' ' 
                    AND C1L.C1L_FILIAL = @FILIAL_C1L
                    AND C1L.C1L_CODIGO = SB1.B1_COD
            LEFT JOIN CDN### CDNA
                ON CDNA.CDN_FILIAL = @FILIAL_CDN
                    AND CDNA.CDN_CODISS = SB1.B1_CODISS
                    AND CDNA.CDN_PROD = SB1.B1_COD
                    AND CDNA.D_E_L_E_T_ = ' '
            LEFT JOIN CDN### CDNB
                ON CDNB.CDN_FILIAL = @FILIAL_CDN
                    AND CDNB.CDN_CODISS = SB1.B1_CODISS
                    AND CDNB.D_E_L_E_T_ = ' '
            LEFT JOIN SB5### SB5
                ON SB5.B5_FILIAL = @FILIAL_SB5
                    AND SB5.B5_COD = SB1.B1_COD
                    AND SB5.D_E_L_E_T_ = ' '
            LEFT JOIN F2Q### F2Q
                ON F2Q.F2Q_FILIAL = @FILIAL_F2Q
                    AND F2Q.F2Q_PRODUT = SB1.B1_COD
                    AND F2Q.D_E_L_E_T_ = ' '
            LEFT JOIN C8C### C8C
                ON C8C.C8C_FILIAL = @FILIAL_C8C
                    AND C8C.D_E_L_E_T_ = ' '
                    AND (C8C.C8C_CODIGO = F2Q.F2Q_TPSERV 
                        OR C8C.C8C_CODIGO = CDNA.CDN_CODLST 
                        OR C8C.C8C_CODIGO = CDNB.CDN_CODLST)
            LEFT JOIN C0A### C0A
                ON C0A.C0A_FILIAL = @FILIAL_C0A
                    AND C0A.C0A_CODIGO = SB1.B1_POSIPI
                    AND C0A.D_E_L_E_T_ = ' '
                    AND C0A.C0A_EXNCM  = ' '
            LEFT JOIN C3Z### C3Z
                ON C3Z.C3Z_FILIAL = @FILIAL_C3Z
                    AND C3Z.D_E_L_E_T_ = ' '
                    AND (C3Z.C3Z_CODIGO = SUBSTRING(SB1.B1_CODISS, 1, 2)
                        OR C3Z.C3Z_CODIGO = '00')
            LEFT JOIN C0B### C0B
                ON C0B.C0B_FILIAL = @FILIAL_C0B
                    AND C0B.D_E_L_E_T_ = ' '
                    AND (C0B.C0B_CODIGO = REPLACE(CDNA.CDN_CODLST, '.', '') 
                        OR C0B.C0B_CODIGO = REPLACE(CDNB.CDN_CODLST, '.', ''))
            LEFT JOIN C3X### C3X
                ON C3X.C3X_FILIAL = @FILIAL_C3X
                    AND C3X.C3X_CODGRU = SB5.B5_CODGRU
                    AND C3X.D_E_L_E_T_ = ' '
            LEFT JOIN C03### C03
                ON C03.C03_FILIAL = @FILIAL_C03
                    AND C03.C03_CODIGO = SB1.B1_ORIGEM
                    AND C03.D_E_L_E_T_ = ' '
            LEFT JOIN T71### T71
                ON T71.T71_FILIAL = @FILIAL_T71
                    AND T71.T71_CODIGO = SB1.B1_CEST
                    AND T71.D_E_L_E_T_ = ' '
            LEFT JOIN T5E### T5E
                ON T5E.T5E_FILIAL = @FILIAL_T5E
                    AND T5E.T5E_CODIGO = ' ' 
                    AND T5E.D_E_L_E_T_ = ' '
            LEFT JOIN T5F### T5F
                ON T5F.T5F_FILIAL = @FILIAL_T5F
                    AND T5F.T5F_CODIGO = ' '
                    AND T5F.D_E_L_E_T_ = ' '
        WHERE
            SB1.D_E_L_E_T_ = ' '
            AND SB1.B1_FILIAL = @FILIAL_SB1
            AND C1L.C1L_CODIGO IS NULL
        GROUP BY SB1.B1_COD, SB1.B1_DESC, SB1.B1_CODBAR, C1J.C1J_ID, SB1.B1_TIPO,
            C0A.C0A_ID, C3Z.C3Z_ID, C0B.C0B_ID, C3X.C3X_ID, C03.C03_ID, SB1.B1_DATREF,
                SB1.B1_PICM, SB1.B1_IPI, CDNA.CDN_CODLST, CDNB.CDN_CODLST, T5E.T5E_ID,
                    T5F.T5F_ID, T71.T71_ID, C8C.C8C_ID 

    FOR READ ONLY    
    OPEN PRODUTOS_INSERT

    FETCH PRODUTOS_INSERT 
        INTO
            @COD_ITEM,
            @DESCR_ITEM,
            @COD_BARRA,
            @UNID_INV,
            @TIPO_ITEM,
            @COD_NCM,
            @COD_GEN,
            @COD_LST,
            @COD_COMB,
            @COD_GRU,
            @ORIGEM,
            @DT_INCLUSAO,
            @ALIQ_ICMS,
            @ALIQ_IPI,
            @RED_BC_ICMS,
            @ESTOQUE,
            @COD_CFQ,
            @COD_SERV_MUN_A,
            @COD_SERV_MUN_B,
            @TP_PRD,
            @COD_CNM,
            @COD_GLP,
            @COD_AFE,
            @COD_UM,
            @COD_CERTIF,
            @CEST,
            @TIP_SERV

    BEGIN TRANSACTION

    SELECT @PROD_ATU = ' '
    SELECT @PROD_ANT = ' '
    
    WHILE @@FETCH_STATUS = 0 
        BEGIN
            ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                SELECT @PROD_ATU = @FILIAL_C1L + @COD_ITEM
            ##ENDIF_005
            
            ##IF_006({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
                SELECT @PROD_ATU = @FILIAL_C1L || @COD_ITEM
            ##ENDIF_006

            IF @PROD_ANT <> @PROD_ATU
                BEGIN
                    ##IF_007({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                        SELECT @PROD_ANT = @FILIAL_C1L + @COD_ITEM
                    ##ENDIF_007
                    
                    ##IF_008({|| AllTrim(Upper(TcGetDB())) $ "POSTGRES/ORACLE"})
                        SELECT @PROD_ANT = @FILIAL_C1L || @COD_ITEM
                    ##ENDIF_008

                    IF @COD_SERV_MUN_A <> ' '
                        BEGIN
                            SELECT @COD_SERV_MUN = @COD_SERV_MUN_A
                        END
                    ELSE
                        BEGIN
                            SELECT @COD_SERV_MUN = @COD_SERV_MUN_B
                        END

                    IF @ALIQ_ICMS = 0 
                        BEGIN
                            SELECT @ALIQ_ICMS = @IN_MV_ICMPAD
                        END

                    EXEC TAF613K_## @ID_C1L OUTPUT
                    EXEC TAF613E_## @IN_FILIAL, @TIPO_ITEM, @COD_SERV_MUN, @IN_MV_BLKTP00,
                        @IN_MV_BLKTP01, @IN_MV_BLKTP02, @IN_MV_BLKTP03, @IN_MV_BLKTP04,
                        @IN_MV_BLKTP06, @IN_MV_BLKTP10, @TIPO_ITEM_ID OUTPUT

                    INSERT INTO C1L### (
                        C1L_FILIAL,
                        C1L_ID,
                        C1L_CODIGO,
                        C1L_DESCRI,
                        C1L_CODBAR,
                        C1L_UM,
                        C1L_TIPITE,
                        C1L_CODNCM,
                        C1L_CODGEN,
                        C1L_CODSER,
                        C1L_CODANP,
                        C1L_CODIND,
                        C1L_ORIMER,
                        C1L_DTINCL,
                        C1L_ALQICM,
                        C1L_ALQIPI,
                        C1L_REDBC,
                        C1L_ESTOQ,
                        C1L_IDCFQ,
                        C1L_SRVMUN,
                        C1L_TPPRD,
                        C1L_IDCNM,
                        C1L_IDGLP,
                        C1L_IDAFE,
                        C1L_IDUM,
                        C1L_CERTIF,
                        C1L_IDCEST,
                        C1L_IDTSER
                    ) VALUES (
                        @FILIAL_C1L,
                        @ID_C1L,
                        @COD_ITEM,
                        @DESCR_ITEM,
                        @COD_BARRA,
                        @UNID_INV,
                        @TIPO_ITEM_ID,
                        @COD_NCM,
                        @COD_GEN,
                        @COD_LST,
                        @COD_COMB,
                        @COD_GRU,
                        @ORIGEM,
                        @DT_INCLUSAO,
                        @ALIQ_ICMS,
                        @ALIQ_IPI,
                        @RED_BC_ICMS,
                        @ESTOQUE,
                        @COD_CFQ,
                        @COD_SERV_MUN,
                        @TP_PRD,
                        @COD_CNM,
                        @COD_GLP,
                        @COD_AFE,
                        @COD_UM,
                        @COD_CERTIF,
                        @CEST,
                        @TIP_SERV
                    )
                END
                FETCH PRODUTOS_INSERT 
                        INTO
                            @COD_ITEM,
                            @DESCR_ITEM,
                            @COD_BARRA,
                            @UNID_INV,
                            @TIPO_ITEM,
                            @COD_NCM,
                            @COD_GEN,
                            @COD_LST,
                            @COD_COMB,
                            @COD_GRU,
                            @ORIGEM,
                            @DT_INCLUSAO,
                            @ALIQ_ICMS,
                            @ALIQ_IPI,
                            @RED_BC_ICMS,
                            @ESTOQUE,
                            @COD_CFQ,
                            @COD_SERV_MUN_A,
                            @COD_SERV_MUN_B,
                            @TP_PRD,
                            @COD_CNM,
                            @COD_GLP,
                            @COD_AFE,
                            @COD_UM,
                            @COD_CERTIF,
                            @CEST,
                            @TIP_SERV
        END

    COMMIT TRANSACTION

    CLOSE PRODUTOS_INSERT
    DEALLOCATE PRODUTOS_INSERT

    SELECT @OUT_RESULT = '1'
END
