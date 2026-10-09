CREATE PROCEDURE TAF613C_##(
    @IN_FILIAL CHAR('AH_FILIAL'),
    @IN_PROCESSO CHAR(36),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613C </s>
    Descricao   -  <d> Integra��o entre ERP Livros Fiscais X TAF (SPED) - Unidades de Medida </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure </ri> 
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execu��o da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Melkz Siqueira </r>
    Data        :  <dt> 23/08/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */

DECLARE @C1J            CHAR(3)
DECLARE @V80            CHAR(3)
DECLARE @SAH            CHAR(3)
DECLARE @UPDATE         CHAR(1)
DECLARE @RESULT_V80     CHAR(1)
DECLARE @UNID           CHAR('C1J_CODIGO')
DECLARE @FILIAL_C1J     VARCHAR('C1J_FILIAL') 
DECLARE @FILIAL_V80     VARCHAR('V80_FILIAL')
DECLARE @FILIAL_SAH     VARCHAR('AH_FILIAL') 
DECLARE @ID_C1J         VARCHAR('C1J_ID')
DECLARE @DESCR          VARCHAR('C1J_DESCRI')
DECLARE @UNID_ECF       VARCHAR('C1J_IDUMEC')
DECLARE @SEQUENCIA      INTEGER

BEGIN
    SELECT @OUT_RESULT      = '0'
    SELECT @RESULT_V80      = '0'
    SELECT @UPDATE          = '0'
    SELECT @C1J             = 'C1J'
    SELECT @V80             = 'V80'
    SELECT @SAH             = 'SAH'
    SELECT @SEQUENCIA       = 0

    EXEC XFILIAL_## @C1J, @IN_FILIAL, @FILIAL_C1J OUTPUT
    EXEC XFILIAL_## @V80, @IN_FILIAL, @FILIAL_V80 OUTPUT
    EXEC XFILIAL_## @SAH, @IN_FILIAL, @FILIAL_SAH OUTPUT

    DECLARE MEDIDA_UPDATE INSENSITIVE CURSOR FOR
        SELECT 
            SAH.AH_UNIMED UNID, 
            SAH.AH_DESCPO DESCR, 
            ' ' UNID_ECF 
            FROM SAH### SAH
            INNER JOIN C1J### C1J
                ON C1J.D_E_L_E_T_ = ' ' 
                    AND C1J.C1J_FILIAL = @FILIAL_C1J
                    AND C1J.C1J_CODIGO = SAH.AH_UNIMED
            LEFT JOIN V80### V80
                ON V80.D_E_L_E_T_ = ' '
                    AND V80.V80_FILIAL = @FILIAL_V80
                    AND V80.V80_ALIAS = 'C1J'
            WHERE SAH.D_E_L_E_T_ = ' '
                AND SAH.AH_FILIAL = @FILIAL_SAH

                ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                    AND (V80.V80_ALIAS IS NULL 
                        OR V80.V80_STAMP <= CONVERT(VARCHAR('V80_STAMP'), SAH.S_T_A_M_P_, 21))
                ##ENDIF_001

                ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
                    AND (V80.V80_ALIAS IS NULL 
                        OR V80.V80_STAMP <= TO_CHAR(SAH.S_T_A_M_P_, 'DD.MM.YYYY HH24:MI:SS.FF'))
                ##ENDIF_002

                ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
                    AND (V80.V80_ALIAS IS NULL 
                        OR V80.V80_STAMP <= TO_CHAR(SAH.S_T_A_M_P_, 'YYYY-MM-DD HH24:MI:SS.MS'))
                ##ENDIF_003

    FOR READ ONLY
    OPEN MEDIDA_UPDATE

    FETCH MEDIDA_UPDATE
        INTO
            @UNID,
            @DESCR,
            @UNID_ECF

    BEGIN TRANSACTION

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            SELECT @UPDATE = '1'

            UPDATE C1J###
                SET 
                    C1J_DESCRI = @DESCR,
                    C1J_IDUMEC = @UNID_ECF
                WHERE D_E_L_E_T_ = ' ' 
                    AND C1J_FILIAL = @FILIAL_C1J
                    AND C1J_CODIGO = @UNID

            FETCH MEDIDA_UPDATE
                INTO
                    @UNID,
                    @DESCR,
                    @UNID_ECF

        END

    COMMIT TRANSACTION

    CLOSE MEDIDA_UPDATE
    DEALLOCATE MEDIDA_UPDATE

    IF @UPDATE = '1'
        BEGIN
            EXEC TAF613G_## @IN_FILIAL, @C1J, @SAH, @RESULT_V80 OUTPUT
        END

    SELECT @UPDATE = '0'

    DECLARE MEDIDA_INSERT INSENSITIVE CURSOR FOR
        SELECT 
            SAH.AH_UNIMED UNID,
            SAH.AH_DESCPO DESCR,
            ' ' UNID_ECF 
            FROM SAH### SAH
            LEFT JOIN C1J### C1J
                ON C1J.D_E_L_E_T_ = ' '
                    AND C1J.C1J_FILIAL = @FILIAL_C1J
                    AND C1J.C1J_CODIGO = SAH.AH_UNIMED
            WHERE SAH.D_E_L_E_T_ = ' '
                AND SAH.AH_FILIAL = @FILIAL_SAH
                AND C1J.C1J_CODIGO IS NULL

    FOR READ ONLY    
    OPEN MEDIDA_INSERT

    FETCH MEDIDA_INSERT 
        INTO
            @UNID,
            @DESCR,
            @UNID_ECF

    BEGIN TRANSACTION

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            SELECT @UPDATE = '1'
            SELECT @SEQUENCIA = @SEQUENCIA + 1

            EXEC TAF613J_## @IN_FILIAL, @IN_PROCESSO, 'TAF613C', 'C1J', @SEQUENCIA, @ID_C1J OUTPUT

            IF @ID_C1J <> ' '
                BEGIN
                    INSERT INTO C1J### (
                        C1J_FILIAL,
                        C1J_ID,
                        C1J_CODIGO,
                        C1J_DESCRI,
                        C1J_IDUMEC
                    ) VALUES (
                        @FILIAL_C1J,
                        @ID_C1J,
                        @UNID,
                        @DESCR,
                        @UNID_ECF
                    )
                END

            FETCH MEDIDA_INSERT 
                INTO
                    @UNID,
                    @DESCR,
                    @UNID_ECF

        END

    COMMIT TRANSACTION

    CLOSE MEDIDA_INSERT
    DEALLOCATE MEDIDA_INSERT

    IF @UPDATE = '1'
        BEGIN
            EXEC TAF613G_## @IN_FILIAL, @C1J, @SAH, @RESULT_V80 OUTPUT
        END

    SELECT @OUT_RESULT = '1'
END
