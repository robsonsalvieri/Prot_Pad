CREATE PROCEDURE TAF613M_##(
    @IN_FILIAL CHAR('F4_FILIAL'),
    @IN_MV_SPEDNAT VARCHAR(3),
    @IN_PROCESSO CHAR(36),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*-----------------------------------------------------------------------------------------------------------------------------
    Versao     -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613M </s>
    Descricao   -  <d> Integração entre ERP Livros Fiscais X TAF (SPED)Tabela(SF4)C1N(TAF))-NOP (Natureza de Operação)</d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure </ri> 
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execução da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Washington Miranda </r>
    Data        :  <dt> 13/09/2023 </dt>
    Descrição das bases de dados.
    SF4(Cadastro de TES-Tabela protheus) X C1N(TAF) Natureza de Operação. 
    F4_FILIAL= CD1_FILIAL Codigo da FIlial no Protheus
    Nessa issue DSERTAF4-264 iremos trabalhar com o cadastro de natureza de operação (SF4) para enviar para o TAF (C1N).
---------------------------------------------------------------------------------------------------------------------------------*/
DECLARE @C1N            CHAR(3) 
DECLARE @V80            CHAR(3)
DECLARE @CD1            CHAR(3) 
DECLARE @SF4            CHAR(3)
DECLARE @SX5            CHAR(3)
DECLARE @UPDATE         CHAR(1)
DECLARE @RESULT_V80     CHAR(1)
DECLARE @FILIAL_CD1     VARCHAR('CD1_FILIAL')
DECLARE @FILIAL_C1N     VARCHAR('C1N_FILIAL') 
DECLARE @FILIAL_V80     VARCHAR('V80_FILIAL')
DECLARE @FILIAL_SF4     VARCHAR('F4_FILIAL')
DECLARE @FILIAL_SX5     VARCHAR('X5_FILIAL')
DECLARE @CODIGO_F4      VARCHAR('F4_CODIGO')
DECLARE @TEXTO_F4       VARCHAR('F4_TEXTO')
DECLARE @NATOPER_F4     CHAR('F4_NATOPER')
DECLARE @DESCR_CD1      VARCHAR('CD1_DESCR')
DECLARE @DESCRI_X5      VARCHAR('X5_DESCRI')
DECLARE @CODNAT_C1N     VARCHAR('C1N_CODNAT')
DECLARE @DESNAT_C1N     VARCHAR('C1N_DESNAT')
DECLARE @ID_C1N         CHAR('C1N_ID')
DECLARE @TABELA         CHAR(3)
DECLARE @CODNAT         VARCHAR('C1N_CODNAT')
DECLARE @DESCNAT        VARCHAR('C1N_DESNAT')

BEGIN
    SELECT @OUT_RESULT      = '0'
    SELECT @RESULT_V80      = '0'
    SELECT @UPDATE          = '0'
    SELECT @CD1             = 'CD1'
    SELECT @C1N             = 'C1N'
    SELECT @SX5             = 'SX5'
    SELECT @V80             = 'V80'
    SELECT @SF4             = 'SF4'

    EXEC XFILIAL_## @C1N, @IN_FILIAL, @FILIAL_C1N OUTPUT
    EXEC XFILIAL_## @V80, @IN_FILIAL, @FILIAL_V80 OUTPUT
    EXEC XFILIAL_## @SF4, @IN_FILIAL, @FILIAL_SF4 OUTPUT
    EXEC XFILIAL_## @CD1, @IN_FILIAL, @FILIAL_CD1 OUTPUT
    EXEC XFILIAL_## @SX5, @IN_FILIAL, @FILIAL_SX5 OUTPUT

    DECLARE NATOP_UPDATE INSENSITIVE CURSOR FOR

        SELECT 
            'CD1' TABELA,
            SF4.F4_CODIGO CODNAT,
            CD1.CD1_DESCR DESCNAT,
            '' F4_NATOPER,
            '' CD1_DESCR,
            '' X5_DESCRI
        FROM CD1### CD1 
        INNER JOIN SF4### SF4
            ON SF4.D_E_L_E_T_ = ' ' 
                AND SF4.F4_FILIAL = @FILIAL_SF4
                AND SF4.F4_NATOPER = CD1.CD1_CODNAT        
        INNER JOIN C1N### C1N
            ON C1N.D_E_L_E_T_ = ' ' 
                AND C1N.C1N_FILIAL = @FILIAL_C1N
                AND C1N.C1N_CODNAT = SF4.F4_CODIGO
        LEFT JOIN V80### V80 
            ON 	V80.D_E_L_E_T_ = ' '
                AND V80.V80_FILIAL = @FILIAL_V80
                AND V80.V80_ALIAS  = @C1N
        WHERE CD1.D_E_L_E_T_ = ' '
        AND CD1.CD1_FILIAL = @FILIAL_CD1
            ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                AND (V80.V80_ALIAS IS NULL 
                    OR V80.V80_STAMP <= CONVERT(VARCHAR('V80_STAMP'), CD1.S_T_A_M_P_, 21))
            ##ENDIF_001

            ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
                AND (V80.V80_ALIAS IS NULL 
                    OR V80.V80_STAMP <= TO_CHAR(CD1.S_T_A_M_P_, 'DD.MM.YYYY HH24:MI:SS.FF'))
            ##ENDIF_002

            ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
                AND (V80.V80_ALIAS IS NULL 
                    OR V80.V80_STAMP <= TO_CHAR(CD1.S_T_A_M_P_, 'YYYY-MM-DD HH24:MI:SS.MS'))
            ##ENDIF_003

        UNION

        SELECT 
            'SF4',
            SF4.F4_CODIGO,
            SF4.F4_TEXTO,
            COALESCE(SF4.F4_NATOPER, ' '),
            CD1.CD1_DESCR,
            COALESCE(SX5.X5_DESCRI, ' ') 
        FROM SF4### SF4 
        INNER JOIN C1N### C1N
            ON C1N.D_E_L_E_T_ = ' ' 
                AND C1N.C1N_FILIAL = @FILIAL_C1N
                AND C1N.C1N_CODNAT = SF4.F4_CODIGO
        LEFT JOIN SX5### SX5
            ON SX5.D_E_L_E_T_ = ' ' 
                AND SX5.X5_FILIAL = @FILIAL_SX5
                AND SX5.X5_TABELA = '13'
                AND SX5.X5_CHAVE = SF4.F4_CF
        LEFT JOIN CD1### CD1 
            ON CD1.D_E_L_E_T_ = ' ' 
                AND CD1.CD1_FILIAL = @FILIAL_CD1
                AND CD1.CD1_CODNAT = LTRIM(RTRIM(SF4.F4_NATOPER))                
        LEFT JOIN V80### V80
            ON V80.D_E_L_E_T_ = ' '
                AND V80.V80_FILIAL = @FILIAL_V80
                AND V80.V80_ALIAS  = @C1N
        WHERE SF4.D_E_L_E_T_ = ' ' 
            AND SF4.F4_FILIAL= @FILIAL_SF4

            ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                AND (V80.V80_ALIAS IS NULL 
                    OR V80.V80_STAMP <= CONVERT(VARCHAR('V80_STAMP'), SF4.S_T_A_M_P_, 21))
            ##ENDIF_004

            ##IF_005({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
                AND (V80.V80_ALIAS IS NULL 
                    OR V80.V80_STAMP <= TO_CHAR(SF4.S_T_A_M_P_, 'DD.MM.YYYY HH24:MI:SS.FF'))
            ##ENDIF_005

            ##IF_006({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
                AND (V80.V80_ALIAS IS NULL 
                    OR V80.V80_STAMP <= TO_CHAR(SF4.S_T_A_M_P_, 'YYYY-MM-DD HH24:MI:SS.MS'))
            ##ENDIF_006

    FOR READ ONLY
    OPEN NATOP_UPDATE

    FETCH NATOP_UPDATE
        INTO
            @TABELA,
            @CODNAT,
            @DESCNAT,
            @NATOPER_F4,
            @DESCR_CD1,
            @DESCRI_X5

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            SELECT @CODNAT_C1N = @CODNAT
            SELECT @DESNAT_C1N = ' '
            SELECT @UPDATE = '1'

            IF @TABELA = 'CD1'
                BEGIN
                    SELECT @DESNAT_C1N = @DESCNAT
                END
            
            IF @TABELA = 'SF4'
                BEGIN
                    IF @NATOPER_F4 != ' '
                        BEGIN
                            SELECT @DESNAT_C1N = @DESCR_CD1
                        END                
                    ELSE IF @IN_MV_SPEDNAT = '.F.'
                        BEGIN
                            SELECT @DESNAT_C1N = @DESCNAT
                        END
                    ELSE IF @IN_MV_SPEDNAT = '.T.'
                        BEGIN
                            SELECT @DESNAT_C1N = @DESCRI_X5
                        END
                    END   

            BEGIN TRANSACTION
                UPDATE C1N### 
                    SET
                        C1N_DESNAT = @DESNAT_C1N
                    WHERE D_E_L_E_T_ = ' ' 
                        AND C1N_FILIAL = @FILIAL_C1N
                        AND C1N_CODNAT = @CODNAT_C1N
            COMMIT TRANSACTION        

            FETCH NATOP_UPDATE
                INTO
                    @TABELA,
                    @CODNAT,
                    @DESCNAT,
                    @NATOPER_F4,
                    @DESCR_CD1,
                    @DESCRI_X5
        END

    CLOSE NATOP_UPDATE
    DEALLOCATE NATOP_UPDATE

    IF @UPDATE = '1'
        BEGIN
            EXEC TAF613G_## @IN_FILIAL, @C1N, @SF4, @RESULT_V80 OUTPUT
        END

    SELECT @UPDATE = '0'

    DECLARE NATOP_INSERT INSENSITIVE CURSOR FOR
        SELECT 
            SF4.F4_CODIGO,
            SF4.F4_TEXTO,
            COALESCE(SF4.F4_NATOPER, ' '),
            COALESCE(CD1.CD1_DESCR, ' '),
            COALESCE(SX5.X5_DESCRI, ' ')
        FROM SF4### SF4 
        LEFT JOIN C1N### C1N
            ON C1N.D_E_L_E_T_ = ' ' 
                AND C1N.C1N_FILIAL = @FILIAL_C1N  
                AND C1N.C1N_CODNAT = SF4.F4_CODIGO
        LEFT JOIN SX5### SX5
            ON SX5.D_E_L_E_T_ = ' ' 
                AND SX5.X5_FILIAL = @FILIAL_SX5 
                AND SX5.X5_TABELA = '13'
                AND SX5.X5_CHAVE = SF4.F4_CF
        LEFT JOIN CD1### CD1 
            ON CD1.D_E_L_E_T_ = ' ' 
                AND CD1.CD1_FILIAL = @FILIAL_CD1
                AND CD1.CD1_CODNAT = LTRIM(RTRIM(SF4.F4_NATOPER))
        WHERE SF4.D_E_L_E_T_ = ' ' 
            AND SF4.F4_FILIAL = @FILIAL_SF4
            AND C1N.C1N_CODNAT IS NULL
                    
    FOR READ ONLY    
    OPEN NATOP_INSERT

    FETCH NATOP_INSERT 
        INTO
            @CODIGO_F4,
            @TEXTO_F4,
            @NATOPER_F4,
            @DESCR_CD1,
            @DESCRI_X5 

    WHILE @@FETCH_STATUS = 0
        BEGIN 
            SELECT @UPDATE = '1'
            select @DESNAT_C1N = ' '
            SELECT @CODNAT_C1N = @CODIGO_F4

            IF @NATOPER_F4 != ' '
                BEGIN
                    SELECT @DESNAT_C1N = @DESCR_CD1
                END                
            ELSE IF @IN_MV_SPEDNAT = '.F.'
                BEGIN
                    SELECT @DESNAT_C1N = @TEXTO_F4
                END
            ELSE IF @IN_MV_SPEDNAT = '.T.'
                BEGIN
                    SELECT @DESNAT_C1N = @DESCRI_X5
                END

            EXEC TAF613K_## @ID_C1N OUTPUT

            IF @ID_C1N <> ' '
                BEGIN
                    BEGIN TRANSACTION
                        INSERT INTO C1N### (
                            C1N_FILIAL,
                            C1N_ID,
                            C1N_CODNAT,
                            C1N_DESNAT
                        ) VALUES (
                            @FILIAL_C1N,
                            @ID_C1N,
                            @CODNAT_C1N,
                            @DESNAT_C1N           
                        )
                    COMMIT TRANSACTION
                END
                
            FETCH NATOP_INSERT 
                INTO
                    @CODIGO_F4,
                    @TEXTO_F4,
                    @NATOPER_F4,
                    @DESCR_CD1,
                    @DESCRI_X5 
        END

    CLOSE NATOP_INSERT
    DEALLOCATE NATOP_INSERT

    IF @UPDATE = '1'
        BEGIN
            EXEC TAF613G_## @IN_FILIAL, @C1N, @SF4, @RESULT_V80 OUTPUT
        END

    SELECT @OUT_RESULT = '1'
END
