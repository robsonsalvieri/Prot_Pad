CREATE PROCEDURE TAF613I_##(
    @IN_FILIAL CHAR('CTT_FILIAL'),
    @IN_PROCESSO CHAR(36),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Vers„o      -  <v> Protheus P12 </v>
    Programa    -  <s> TAFA613C </s>
    Descricao   -  <d> Integraùùo entre ERP Livros Fiscais X TAF (SPED) - Centro de Custos </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execuùùo da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Josù Riquelmo </r>
    Data        :  <dt> 31/08/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */
DECLARE @V80            CHAR(3)
DECLARE @C1P            CHAR(3)
DECLARE @CTT            CHAR(3)
DECLARE @UPDATE         CHAR(1)
DECLARE @RESULT_V80     CHAR(1)
DECLARE @ID_C1P         VARCHAR('C1P_ID')
DECLARE @FILIAL_C1P     VARCHAR('C1P_FILIAL')
DECLARE @FILIAL_CTT     VARCHAR('CTT_FILIAL') 
DECLARE @FILIAL_V80     VARCHAR('V80_FILIAL') 
DECLARE @DT_ALT         VARCHAR('C1P_DTALT')
DECLARE @COD_CUS        VARCHAR('C1P_CODCUS')
DECLARE @DESC_CUS       VARCHAR('C1P_CCUS')
DECLARE @SEQUENCIA      INTEGER

BEGIN
    SELECT @OUT_RESULT      = '0'
    SELECT @RESULT_V80      = '0'
    SELECT @UPDATE          = '0'
    SELECT @C1P             = 'C1P'
    SELECT @CTT             = 'CTT'
    SELECT @V80             = 'V80'
    SELECT @SEQUENCIA       = 0
    
    EXEC XFILIAL_## @C1P, @IN_FILIAL, @FILIAL_C1P OUTPUT
    EXEC XFILIAL_## @CTT, @IN_FILIAL, @FILIAL_CTT OUTPUT
    EXEC XFILIAL_## @V80, @IN_FILIAL, @FILIAL_V80 OUTPUT

    /*FAZ O UPDATE SOMENTE DOS CENTRO DE CUSTOS QUE EXISTEM NA V80/CTT E TAMBùM EXISTEM NA C1P*/
    DECLARE CENTER_UPDATE INSENSITIVE CURSOR FOR
        SELECT 
            CTT.CTT_DTEXIS DT_ALT, 
            CTT.CTT_CUSTO  COD_CUS,
            CTT.CTT_DESC01 DESC_CUS
            FROM CTT### CTT
            LEFT JOIN C1P### C1P
                ON C1P.D_E_L_E_T_ = ' ' 
                AND C1P.C1P_FILIAL = @FILIAL_C1P
                AND CTT.CTT_CUSTO = C1P.C1P_CODCUS
            LEFT JOIN V80### V80
                ON V80.D_E_L_E_T_ = ' '
                    AND V80.V80_FILIAL = @FILIAL_V80
                    AND V80.V80_ALIAS = 'C1P'
            WHERE CTT.D_E_L_E_T_ = ' ' 
                AND CTT.CTT_FILIAL =  @FILIAL_CTT

                ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                    AND (V80.V80_ALIAS IS NULL 
                        OR V80.V80_STAMP <= CONVERT(VARCHAR('V80_STAMP'), CTT.S_T_A_M_P_, 21))
                ##ENDIF_001

                ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
                    AND (V80.V80_ALIAS IS NULL 
                        OR V80.V80_STAMP <= TO_CHAR(CTT.S_T_A_M_P_, 'DD.MM.YYYY HH24:MI:SS.FF'))
                ##ENDIF_002

                ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
                    AND (V80.V80_ALIAS IS NULL 
                        OR V80.V80_STAMP <= TO_CHAR(CTT.S_T_A_M_P_, 'YYYY-MM-DD HH24:MI:SS.MS'))
                ##ENDIF_003
              

    FOR READ ONLY
    OPEN CENTER_UPDATE

    FETCH CENTER_UPDATE
        INTO
            @DT_ALT,
            @COD_CUS,
            @DESC_CUS

    BEGIN TRANSACTION

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            SELECT @UPDATE = '1'
        
            UPDATE C1P###
                SET 
                    C1P_DTALT = @DT_ALT,
                    C1P_CODCUS = @COD_CUS,
                    C1P_CCUS = @DESC_CUS
                WHERE D_E_L_E_T_ = ' ' 
                    AND C1P_FILIAL = @FILIAL_C1P
                    AND C1P_CODCUS = @COD_CUS

            FETCH CENTER_UPDATE
                INTO
                    @DT_ALT,
                    @COD_CUS,
                    @DESC_CUS
        END

    COMMIT TRANSACTION

    CLOSE CENTER_UPDATE
    DEALLOCATE CENTER_UPDATE

    IF @UPDATE = '1'
        BEGIN
            EXEC TAF613G_## @IN_FILIAL, @C1P, @CTT, @RESULT_V80 OUTPUT
        END

    SELECT @UPDATE = '0'
    
    /*FAZ O UPDATE SOMENTE DOS CENTRO DE CUSTOS QUE EXISTEM NA SD1/SD2/CTT E N√O EXISTEM NA C1P*/
    DECLARE CENTER_INSERT INSENSITIVE CURSOR FOR
        SELECT 
            CTT.CTT_DTEXIS DT_ALT, 
            CTT.CTT_CUSTO  COD_CUS,
            CTT.CTT_DESC01 DESC_CUS
            FROM CTT### CTT
            LEFT JOIN C1P### C1P
                ON C1P.D_E_L_E_T_ = ' ' 
                AND C1P.C1P_FILIAL = @FILIAL_C1P
                AND CTT.CTT_CUSTO = C1P.C1P_CODCUS
            WHERE CTT.D_E_L_E_T_ = ''
                AND CTT.CTT_FILIAL =  @FILIAL_CTT
                AND C1P.C1P_CODCUS IS NULL 
           
    FOR READ ONLY    
    OPEN CENTER_INSERT

    FETCH CENTER_INSERT 
        INTO
            @DT_ALT,
            @COD_CUS,
            @DESC_CUS

    BEGIN TRANSACTION

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            SELECT @UPDATE = '1'
            SELECT @SEQUENCIA = @SEQUENCIA + 1
            
            EXEC TAF613J_## @IN_FILIAL, @IN_PROCESSO, 'TAF613I', 'C1P', @SEQUENCIA, @ID_C1P OUTPUT

           IF @ID_C1P <> ''
                BEGIN
                    INSERT INTO C1P### (
                        C1P_FILIAL, 
                        C1P_ID,
                        C1P_DTALT, 
                        C1P_CODCUS,
                        C1P_CCUS 
                    
                    ) VALUES (
                        @FILIAL_C1P,
                        @ID_C1P,
                        @DT_ALT,
                        @COD_CUS,
                        @DESC_CUS
                    )
                END

            FETCH CENTER_INSERT 
                INTO
                    @DT_ALT,
                    @COD_CUS,
                    @DESC_CUS
        END

    COMMIT TRANSACTION

    CLOSE CENTER_INSERT
    DEALLOCATE CENTER_INSERT
    
    IF @UPDATE = '1'
       BEGIN
            EXEC TAF613G_## @IN_FILIAL, @C1P, @CTT, @RESULT_V80 OUTPUT
        END

    SELECT @OUT_RESULT = '1' /*A STORED PROCEDURE RETORNA 1 CASO TUDO TENHA EXECUTADO ATù AQUI SEM ERROS*/
END
