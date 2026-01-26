CREATE PROCEDURE TAF613M_##(
    @IN_FILIAL CHAR('F4_FILIAL'),
    @IN_MV_SPEDNAT VARCHAR(3),
    @IN_PROCESSO CHAR(36),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*-----------------------------------------------------------------------------------------------------------------------------
    Versao     -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613M </s>
    Descricao   -  <d> Integraùùo entre ERP Livros Fiscais X TAF (SPED)Tabela(SF4)CD1/C1N(TAF))-NOP (Natureza de Operaùùo)</d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure </ri> 
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execuùùo da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Washington Miranda </r>
    Data        :  <dt> 13/09/2023 </dt>
    Descriùùo das bases de dados.
    SF4(Cadastro de TES-Tabela protheus) X CD1(Natureza da Operaùùo/Prestaùùo) X C1N(TAF) Natureza de Operaùùo. 
    F4_FILIAL= CD1_FILIAL Codigo da FIlial no Protheus
    Nessa issue DSERTAF4-264 iremos trabalhar com o cadastro de natureza de operaùùo (CD1/SF4) para enviar para o TAF (C1N).

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
DECLARE @CF_F4          VARCHAR('F4_CF')
DECLARE @NATOPER_F4     CHAR('F4_NATOPER')
DECLARE @DESCR_CD1      VARCHAR('CD1_DESCR')
DECLARE @DESCRI_X5      VARCHAR('X5_DESCRI')
DECLARE @CODNAT_C1N     VARCHAR('C1N_CODNAT')
DECLARE @DESNAT_C1N     VARCHAR('C1N_DESNAT')
DECLARE @ID_C1N         CHAR('C1N_ID')

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
            SF4.F4_CODIGO,
            SF4.F4_TEXTO,
            SF4.F4_CF,
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
                    
        ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
            AND (V80.V80_ALIAS IS NULL 
                OR V80.V80_STAMP <= CONVERT(VARCHAR('V80_STAMP'), SF4.S_T_A_M_P_, 21))
        ##ENDIF_001

        ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
            AND (V80.V80_ALIAS IS NULL 
                OR V80.V80_STAMP <= TO_CHAR(SF4.S_T_A_M_P_, 'DD.MM.YYYY HH24:MI:SS.FF'))
        ##ENDIF_002

        ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
            AND (V80.V80_ALIAS IS NULL 
                OR V80.V80_STAMP <= TO_CHAR(SF4.S_T_A_M_P_, 'YYYY-MM-DD HH24:MI:SS.MS'))
        ##ENDIF_003

    FOR READ ONLY
    OPEN NATOP_UPDATE

    FETCH NATOP_UPDATE
        INTO
            @CODIGO_F4,
            @TEXTO_F4,
            @CF_F4,
            @NATOPER_F4,
            @DESCR_CD1,
            @DESCRI_X5

    BEGIN TRANSACTION
    
    /*                       
        Author: Washington Mirana - Data 20-09-2023.
    Apùs o While, eu coloco a regra que define da onde  buscaremos tanto o cùdigo e descriùùo
    da Natureza. Pois conforme a regra podemos buscar das seguintes tabelas..
    SF4(TES),CD1(Natureza da Operaùùo), SX5(Tabelas das tabelas).
    
        Sùo 3 Regras definidas .

        1)Quando o campo(F4_NATOPER) estiver preenchida, pegar a descriùùo  da tabela CD1(Natureza da Operaùùo)
        Obs:Pegar o cùdigo da tabela SF4(TES), campo F4_CF, quando o campo F4_NATOPER  nùo estiver
        preenchido.
        
        2)Quando o  parùmetro MV_SPEDNAT estier falso(.F.), eu pego o codigo da
        propria tabela SF4(TES)e campo F4_NATOPER, e a descriùùo ,pego do campo F4_TEXTO

        3) Quando o parùmetro MV_SPEDNAT estiver True(.T.), eu pego o codigo 
        da tabela SF4(TES), campo F4_CF, e a descriùùo da tabela SX5, X5_TABELA='13' E campo X5_Descri.
        E quando o F4_NATOPER estiver preenchido, eu pego   a descriùùo da tabela CD1(Natueza da Operaùùo),
        campo CD1_DESCR.
    
    */
    
    WHILE @@FETCH_STATUS = 0 
        BEGIN
            SELECT @UPDATE = '1'

            IF @NATOPER_F4 <> ' '
                BEGIN
                    SELECT @CODNAT_C1N = LTRIM(RTRIM(@NATOPER_F4)) 
                    SELECT @DESNAT_C1N = @DESCR_CD1  
                END

            IF @IN_MV_SPEDNAT = '.F.'
                BEGIN
                    SELECT @CODNAT_C1N = @CODIGO_F4 
                    SELECT @DESNAT_C1N = @TEXTO_F4 
                END

            IF @IN_MV_SPEDNAT = '.T.'
                BEGIN
                    SELECT @CODNAT_C1N = @CF_F4 
                    SELECT @DESNAT_C1N = @DESCRI_X5 
                END

            UPDATE C1N### 
                SET
                    C1N_DESNAT = @DESNAT_C1N
                WHERE D_E_L_E_T_ = ' ' 
                    AND C1N_FILIAL = @FILIAL_C1N
                    AND C1N_CODNAT = @CODNAT_C1N
            
            FETCH NATOP_UPDATE
                INTO
                    @CODIGO_F4,
                    @TEXTO_F4,
                    @CF_F4,
                    @NATOPER_F4,
                    @DESCR_CD1,
                    @DESCRI_X5 
    END

    COMMIT TRANSACTION

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
            SF4.F4_CF,
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
            @CF_F4,
            @NATOPER_F4,
            @DESCR_CD1,
            @DESCRI_X5 

    BEGIN TRANSACTION

    WHILE @@FETCH_STATUS = 0
        BEGIN 
            SELECT @UPDATE = '1'

            IF @NATOPER_F4 <> ' '
                BEGIN
                    SELECT @CODNAT_C1N = LTRIM(RTRIM(@NATOPER_F4))
                    SELECT @DESNAT_C1N = @DESCR_CD1  
                END

            IF @IN_MV_SPEDNAT = '.F.'
                BEGIN
                    SELECT @CODNAT_C1N = @CODIGO_F4 
                    SELECT @DESNAT_C1N = @TEXTO_F4 
                END

            IF @IN_MV_SPEDNAT = '.T.'
                BEGIN
                    SELECT @CODNAT_C1N = @CF_F4 
                    SELECT @DESNAT_C1N = @DESCRI_X5 
                END

            EXEC TAF613K_## @ID_C1N OUTPUT

            IF @ID_C1N <> ' '
                BEGIN
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
                END
                
            FETCH NATOP_INSERT 
                INTO
                    @CODIGO_F4,
                    @TEXTO_F4,
                    @CF_F4,
                    @NATOPER_F4,
                    @DESCR_CD1,
                    @DESCRI_X5 
        END

    COMMIT TRANSACTION

    CLOSE NATOP_INSERT
    DEALLOCATE NATOP_INSERT

    IF @UPDATE = '1'
        BEGIN
            EXEC TAF613G_## @IN_FILIAL, @C1N, @SF4, @RESULT_V80 OUTPUT
        END

    SELECT @OUT_RESULT = '1'
END
