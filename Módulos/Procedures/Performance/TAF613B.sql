CREATE PROCEDURE TAF613B_##(
    @IN_FILIAL CHAR('B1_FILIAL'),
    @IN_PROCESSO CHAR(36),
    @IN_PENDING_STATUS CHAR('C20_STATUS'),
    @IN_ATUDOC CHAR('C20_ATUDOC'),
    @IN_MV_CSDXML VARCHAR(3),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> TAFA613B </s>
    Descricao   -  <d> Integração entre ERP Livros Fiscais X TAF (SPED) - Fatores de Conversão </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedur
                        @IN_PROCESSO - Processo em que o ID foi gerado
                        @IN_PENDING_STATUS - Status do Documento Fiscal pendente para integração (C20_STATUS)
                        @IN_ATUDOC - Status de atualização do documento: 1 - Inclusão; 2 - Cancelamento; 3 - Exclusão; 4 = Complemento 
                        @IN_MV_CSDXML - Conteúdo do parâmetro MV_CSDXML </ri> 
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execução da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Melkz Siqueira </r>
    Data        :  <dt> 17/08/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */

DECLARE @SB1            CHAR(3)
DECLARE @SFT            CHAR(3)
DECLARE @C20            CHAR(3)
DECLARE @DKA            CHAR(3)
DECLARE @DKC            CHAR(3)
DECLARE @C1J            CHAR(3)
DECLARE @C1K            CHAR(3)
DECLARE @C6X            CHAR(3)
DECLARE @ID_C1K         CHAR('C1K_ID')
DECLARE @FILIAL_SB1     VARCHAR('B1_FILIAL') 
DECLARE @FILIAL_SFT     VARCHAR('FT_FILIAL')
DECLARE @FILIAL_C20     VARCHAR('C20_FILIAL') 
DECLARE @FILIAL_DKA     VARCHAR('DKA_FILIAL')
DECLARE @FILIAL_DKC     VARCHAR('DKC_FILIAL') 
DECLARE @FILIAL_C1J     VARCHAR('C1J_FILIAL')
DECLARE @FILIAL_C1K     VARCHAR('C1K_FILIAL')
DECLARE @FILIAL_C6X     VARCHAR('C6X_FILIAL')
DECLARE @CODIGO_C1K     VARCHAR('C1K_CODIGO')
DECLARE @ID_C6X         VARCHAR('C6X_ID')
DECLARE @UNID_CONV      VARCHAR('C6X_UNCONV')
DECLARE @TIPCONV_B1     VARCHAR('B1_TIPCONV')
DECLARE @FAT_CONV       DECIMAL('C6X_FATCON')
DECLARE @CONV_B1        DECIMAL('C6X_FATCON')
DECLARE @SEQUENCIA      INTEGER

BEGIN
    SELECT @OUT_RESULT      = '0'
    SELECT @SB1             = 'SB1'
    SELECT @SFT             = 'SFT'
    SELECT @C20             = 'C20'
    SELECT @DKA             = 'DKA'
    SELECT @DKC             = 'DKC'
    SELECT @C1J             = 'C1J'
    SELECT @C1K             = 'C1K'
    SELECT @C6X             = 'C6X'
    SELECT @SEQUENCIA      = 0

    EXEC XFILIAL_## @SB1, @IN_FILIAL, @FILIAL_SB1 OUTPUT
    EXEC XFILIAL_## @SFT, @IN_FILIAL, @FILIAL_SFT OUTPUT
    EXEC XFILIAL_## @C20, @IN_FILIAL, @FILIAL_C20 OUTPUT
    EXEC XFILIAL_## @DKA, @IN_FILIAL, @FILIAL_DKA OUTPUT
    EXEC XFILIAL_## @DKC, @IN_FILIAL, @FILIAL_DKC OUTPUT
    EXEC XFILIAL_## @C1J, @IN_FILIAL, @FILIAL_C1J OUTPUT
    EXEC XFILIAL_## @C1K, @IN_FILIAL, @FILIAL_C1K OUTPUT
    EXEC XFILIAL_## @C6X, @IN_FILIAL, @FILIAL_C6X OUTPUT

    DECLARE FATOR_UPDATE INSENSITIVE CURSOR FOR
        SELECT
            C1K.C1K_ID,
            C1JB.C1J_ID UNID_CONV,
            SB1.B1_TIPCONV,
            SB1.B1_CONV,
            DKA.DKA_FATOR FAT_CONV
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
            LEFT JOIN DKC### DKC 
                ON DKC.D_E_L_E_T_ = ' '
                    AND DKC.DKC_FILIAL = @FILIAL_DKC 
                    AND DKC.DKC_DOC = SFT.FT_NFISCAL
                    AND DKC.DKC_SERIE = SFT.FT_SERIE
                    AND DKC.DKC_FORNEC = SFT.FT_CLIEFOR
                    AND DKC.DKC_LOJA = SFT.FT_LOJA
                    AND DKC.DKC_ITEMNF = SFT.FT_ITEM
            LEFT JOIN DKA### DKA 
                ON DKA.D_E_L_E_T_ = ' '
                    AND DKA.DKA_FILIAL = @FILIAL_DKA
                    AND DKA.DKA_DOC = DKC.DKC_DOC
                    AND DKA.DKA_SERIE = DKC.DKC_SERIE
                    AND DKA.DKA_FORNEC = DKC.DKC_FORNEC
                    AND DKA.DKA_LOJA = DKC.DKC_LOJA
                    AND DKA.DKA_ITXML = DKC.DKC_ITXML
            INNER JOIN C1J### C1JA
                ON C1JA.D_E_L_E_T_ = ' '
                    AND C1JA.C1J_FILIAL = @FILIAL_C1J
                    AND (C1JA.C1J_CODIGO = COALESCE(DKA.DKA_UM, ' ') 
                        OR C1JA.C1J_CODIGO = SB1.B1_UM)
            INNER JOIN C1J### C1JB
                ON C1JB.D_E_L_E_T_ = ' '
                    AND C1JB.C1J_FILIAL = @FILIAL_C1J
                    AND (C1JB.C1J_CODIGO = COALESCE(DKA.DKA_UMXML, ' ') 
                        OR C1JB.C1J_CODIGO = SB1.B1_SEGUM)
            INNER JOIN C1K### C1K 
                ON C1K.D_E_L_E_T_ = ' '
                    AND C1K.C1K_FILIAL = @FILIAL_C1K
                    AND C1K.C1K_CODIGO = C1JA.C1J_ID
            INNER JOIN C6X### C6X 
                ON C6X.D_E_L_E_T_ = ' '
                    AND C6X.C6X_FILIAL = @FILIAL_C6X
                    AND C6X.C6X_ID = C1K.C1K_ID
                    AND C6X.C6X_UNCONV = C1JB.C1J_ID
            WHERE 
                SB1.D_E_L_E_T_ = ' '
                    AND SB1.B1_FILIAL = @FILIAL_SB1
            GROUP BY C1K.C1K_ID, C1JB.C1J_ID, SB1.B1_TIPCONV, SB1.B1_CONV, DKA.DKA_FATOR

    FOR READ ONLY
    OPEN FATOR_UPDATE

    FETCH FATOR_UPDATE
        INTO
            @ID_C1K,
            @UNID_CONV,
            @TIPCONV_B1,
            @CONV_B1,
            @FAT_CONV

    BEGIN TRANSACTION

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            SELECT @ID_C6X = @ID_C1K

            IF @IN_MV_CSDXML <> '.T.' OR (@IN_MV_CSDXML = '.T.' AND @FAT_CONV = 0)
                BEGIN
                    IF @TIPCONV_B1 = 'D'
                        BEGIN
                            SELECT @FAT_CONV = CONVERT(DECIMAL('C6X_FATCON'), (1 / @CONV_B1))
                        END
                    ELSE
                        BEGIN
                            SELECT @FAT_CONV = @CONV_B1
                        END
                END     
            
            UPDATE C6X###
                SET 
                    C6X_UNCONV = @UNID_CONV,
                    C6X_FATCON = @FAT_CONV
                WHERE D_E_L_E_T_ = ' ' 
                    AND C6X_FILIAL = @FILIAL_C6X
                    AND C6X_ID = @ID_C6X

            FETCH FATOR_UPDATE
                INTO
                    @ID_C1K,
                    @UNID_CONV,
                    @TIPCONV_B1,
                    @CONV_B1,
                    @FAT_CONV
        END

    COMMIT TRANSACTION

    CLOSE FATOR_UPDATE
    DEALLOCATE FATOR_UPDATE

    DECLARE FATOR_INSERT INSENSITIVE CURSOR FOR
        SELECT
            COALESCE(C1K.C1K_ID, ' ') C1K_ID,
            C1JA.C1J_ID,
            C1JB.C1J_ID UNID_CONV,
            SB1.B1_TIPCONV,
            SB1.B1_CONV,
            DKA.DKA_FATOR FAT_CONV
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
            LEFT JOIN DKC### DKC 
                ON DKC.D_E_L_E_T_ = ' '
                    AND DKC.DKC_FILIAL = @FILIAL_DKC 
                    AND DKC.DKC_DOC = SFT.FT_NFISCAL
                    AND DKC.DKC_SERIE = SFT.FT_SERIE
                    AND DKC.DKC_FORNEC = SFT.FT_CLIEFOR
                    AND DKC.DKC_LOJA = SFT.FT_LOJA
                    AND DKC.DKC_ITEMNF = SFT.FT_ITEM
            LEFT JOIN DKA### DKA 
                ON DKA.D_E_L_E_T_ = ' '
                    AND DKA.DKA_FILIAL = @FILIAL_DKA
                    AND DKA.DKA_DOC = DKC.DKC_DOC
                    AND DKA.DKA_SERIE = DKC.DKC_SERIE
                    AND DKA.DKA_FORNEC = DKC.DKC_FORNEC
                    AND DKA.DKA_LOJA = DKC.DKC_LOJA
                    AND DKA.DKA_ITXML = DKC.DKC_ITXML
            INNER JOIN C1J### C1JA
                ON C1JA.D_E_L_E_T_ = ' '
                    AND C1JA.C1J_FILIAL = @FILIAL_C1J
                    AND (C1JA.C1J_CODIGO = COALESCE(DKA.DKA_UM, ' ') 
                        OR C1JA.C1J_CODIGO = SB1.B1_UM)
            INNER JOIN C1J### C1JB
                ON C1JB.D_E_L_E_T_ = ' '
                    AND C1JB.C1J_FILIAL = @FILIAL_C1J
                    AND (C1JB.C1J_CODIGO = COALESCE(DKA.DKA_UMXML, ' ') 
                        OR C1JB.C1J_CODIGO = SB1.B1_SEGUM)
            LEFT JOIN C1K### C1K 
                ON C1K.D_E_L_E_T_ = ' '
                    AND C1K.C1K_FILIAL = @FILIAL_C1K
                    AND C1K.C1K_CODIGO = C1JA.C1J_ID
            LEFT JOIN C6X### C6X 
                ON C6X.D_E_L_E_T_ = ' '
                    AND C6X.C6X_FILIAL = @FILIAL_C6X
                    AND C6X.C6X_ID = C1K.C1K_ID
                    AND C6X.C6X_UNCONV = C1JB.C1J_ID
            WHERE 
                SB1.D_E_L_E_T_ = ' '
                    AND SB1.B1_FILIAL = @FILIAL_SB1
                    AND C6X.C6X_ID IS NULL
            GROUP BY C1K.C1K_ID, C1JA.C1J_ID, C1JB.C1J_ID, SB1.B1_TIPCONV, SB1.B1_CONV, DKA.DKA_FATOR
            
    FOR READ ONLY    
    OPEN FATOR_INSERT

    FETCH FATOR_INSERT
        INTO
            @ID_C1K,
            @CODIGO_C1K,
            @UNID_CONV,
            @TIPCONV_B1,
            @CONV_B1,
            @FAT_CONV

    BEGIN TRANSACTION

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            IF @ID_C1K = ' '
                BEGIN
                    SELECT @SEQUENCIA = @SEQUENCIA + 1

                    EXEC TAF613J_## @IN_FILIAL, @IN_PROCESSO, 'TAF613B', 'C1K', @SEQUENCIA, @ID_C1K OUTPUT

                    IF @ID_C1K <> ' '
                        BEGIN
                            INSERT INTO C1K### (
                                C1K_FILIAL,
                                C1K_ID,
                                C1K_CODIGO
                            ) VALUES (
                                @FILIAL_C1K,
                                @ID_C1K,
                                @CODIGO_C1K
                            )
                        END
                        
                END

            IF @IN_MV_CSDXML <> '.T.' OR (@IN_MV_CSDXML = '.T.' AND @FAT_CONV = 0)
                BEGIN
                    IF @TIPCONV_B1 = 'D'
                        BEGIN
                            SELECT @FAT_CONV = CONVERT(DECIMAL('C6X_FATCON'), (1 / @CONV_B1))
                        END
                    ELSE
                        BEGIN
                            SELECT @FAT_CONV = @CONV_B1
                        END
                END   

            SELECT @ID_C6X = @ID_C1K
            
            INSERT INTO C6X### (
                C6X_FILIAL,
                C6X_ID,
                C6X_UNCONV,
                C6X_FATCON
            ) VALUES (
                @FILIAL_C6X,
                @ID_C6X,
                @UNID_CONV,
                @FAT_CONV
            )

            FETCH FATOR_INSERT 
                INTO
                    @ID_C1K,
                    @CODIGO_C1K,
                    @UNID_CONV,
                    @TIPCONV_B1,
                    @CONV_B1,
                    @FAT_CONV
        END

    COMMIT TRANSACTION

    CLOSE FATOR_INSERT
    DEALLOCATE FATOR_INSERT

    SELECT @OUT_RESULT = '1'
END
