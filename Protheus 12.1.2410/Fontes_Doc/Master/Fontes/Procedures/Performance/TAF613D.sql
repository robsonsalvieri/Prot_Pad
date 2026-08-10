CREATE PROCEDURE TAF613D_##(
    @IN_FILIAL CHAR('AH_FILIAL'),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613D </s>
    Descricao   -  <d> Integraùùo entre ERP Livros Fiscais X TAF (SPED) - Plano de Contas </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure </ri> 
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execuùùo da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Daniel Aguilar </r>
    Data        :  <dt> 24/08/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */

DECLARE @C1O           CHAR(3)
DECLARE @V80           CHAR(3)
DECLARE @CT1           CHAR(3)
DECLARE @C2R           CHAR(3)
DECLARE @RESULT_C1O    CHAR(1)
DECLARE @RESULT_V80    CHAR(1)
DECLARE @UPDATE        CHAR(1)
DECLARE @COD_CTA       CHAR('C1O_CODIGO')
DECLARE @FILIAL_C1O    VARCHAR('C1O_FILIAL')
DECLARE @FILIAL_V80    VARCHAR('V80_FILIAL')
DECLARE @FILIAL_CT1    VARCHAR('CT1_FILIAL')
DECLARE @FILIAL_C2R    VARCHAR('C2R_FILIAL')
DECLARE @ID_C1O        VARCHAR('C1O_ID')
DECLARE @DT_ALT        VARCHAR('C1O_DTALT')
DECLARE @COD_NAT       VARCHAR('C1O_CODNAT')
DECLARE @IND_CTA       VARCHAR('C1O_INDCTA')
DECLARE @NIVEL         VARCHAR('C1O_NIVEL')
DECLARE @NOME_CTA      VARCHAR('C1O_DESCRI')
DECLARE @COD_CTA_REF   VARCHAR('C1O_CTAREF')
DECLARE @CNPJ_EST      VARCHAR('C1O_CNPJ')
DECLARE @COD_CTA_SUP   VARCHAR('C1O_CTASUP')
DECLARE @DATA_CRIACAO  VARCHAR('C1O_DTCRIA')
DECLARE @NATUREZA      VARCHAR('C1O_NATURE')

BEGIN
    SELECT @OUT_RESULT      = '0'
    SELECT @C1O             = 'C1O'
    SELECT @V80             = 'V80'
    SELECT @CT1             = 'CT1'
    SELECT @C2R             = 'C2R'
    SELECT @NIVEL           = ' '
    SELECT @UPDATE          = '0'
    
    EXEC XFILIAL_## @C1O, @IN_FILIAL, @FILIAL_C1O OUTPUT
    EXEC XFILIAL_## @V80, @IN_FILIAL, @FILIAL_V80 OUTPUT
    EXEC XFILIAL_## @CT1, @IN_FILIAL, @FILIAL_CT1 OUTPUT
    EXEC XFILIAL_## @C2R, @IN_FILIAL, @FILIAL_C2R OUTPUT

    DECLARE CONTAS_UPDATE INSENSITIVE CURSOR FOR
        SELECT 
            CT1.CT1_DTEXIS DT_ALT,
            C2R.C2R_ID COD_NAT,
            CT1.CT1_CLASSE IND_CTA,
            CT1.CT1_CONTA COD_CTA,
            CT1.CT1_DESC01 NOME_CTA,
            ' ' COD_CTA_REF,
            ' ' CNPJ_EST,
            CT1.CT1_CTASUP COD_CTA_SUP,
            CT1.CT1_DTEXIS DATA_CRIACAO,
            CT1.CT1_NORMAL NATUREZA
            FROM CT1### CT1
            INNER JOIN C1O### C1O
                ON C1O.C1O_FILIAL = @FILIAL_C1O
                    AND C1O.C1O_CODIGO = CT1.CT1_CONTA
                    AND C1O.D_E_L_E_T_ = ' '
            LEFT JOIN V80### V80
                ON V80.V80_FILIAL = @FILIAL_V80
                    AND V80.V80_ALIAS = @C1O
                    AND V80.D_E_L_E_T_ = ' '
            INNER JOIN C2R### C2R
                ON C2R.D_E_L_E_T_ = ' '
                    AND C2R.C2R_FILIAL = @FILIAL_C2R
                    AND C2R.C2R_CODIGO = CT1.CT1_NATCTA
            WHERE CT1.CT1_FILIAL = @FILIAL_CT1
                AND CT1.D_E_L_E_T_ = ' '
                AND (CT1.CT1_BLOQ = '2'
                    OR CT1.CT1_BLOQ = ' ')

                ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                    AND (V80.V80_STAMP <= CONVERT(VARCHAR('V80_STAMP'), CT1.S_T_A_M_P_, 21)
                        OR V80.V80_ALIAS IS NULL)
                ##ENDIF_001

                ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
                   AND (V80.V80_STAMP <= TO_CHAR(CT1.S_T_A_M_P_, 'DD.MM.YYYY HH24:MI:SS.FF')
                        OR V80.V80_ALIAS IS NULL) 
                ##ENDIF_002

                ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
                   AND (V80.V80_STAMP <= TO_CHAR(CT1.S_T_A_M_P_, 'YYYY-MM-DD HH24:MI:SS.MS')
                        OR V80.V80_ALIAS IS NULL) 
                ##ENDIF_003

    FOR READ ONLY
    OPEN CONTAS_UPDATE

    FETCH CONTAS_UPDATE
        INTO
            @DT_ALT,
            @COD_NAT,
            @IND_CTA,
            @COD_CTA,
            @NOME_CTA,
            @COD_CTA_REF,
            @CNPJ_EST,
            @COD_CTA_SUP,
            @DATA_CRIACAO,
            @NATUREZA

    BEGIN TRANSACTION

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            SELECT @UPDATE = '1'

            IF @DT_ALT < '20000101'
                BEGIN
                    SELECT @DT_ALT = '20000101'
                END

            IF @DATA_CRIACAO < '20000101'
                BEGIN
                    SELECT @DATA_CRIACAO = '20000101'
                END

            EXEC TAF613F_## @IN_FILIAL, @COD_CTA, @NIVEL OUTPUT
            
            UPDATE C1O###
                SET 
                    C1O_DTALT = @DT_ALT,
                    C1O_CODNAT = @COD_NAT,
                    C1O_INDCTA = @IND_CTA,
                    C1O_NIVEL = @NIVEL,
                    C1O_DESCRI = @NOME_CTA,
                    C1O_CTAREF = @COD_CTA_REF,
                    C1O_CNPJ = @CNPJ_EST,
                    C1O_CTASUP = @COD_CTA_SUP,
                    C1O_DTCRIA = @DATA_CRIACAO,
                    C1O_NATURE = @NATUREZA
                WHERE D_E_L_E_T_ = ' ' 
                    AND C1O_FILIAL = @FILIAL_C1O
                    AND C1O_CODIGO = @COD_CTA

            FETCH CONTAS_UPDATE
                INTO
                    @DT_ALT,
                    @COD_NAT,
                    @IND_CTA,
                    @COD_CTA,
                    @NOME_CTA,
                    @COD_CTA_REF,
                    @CNPJ_EST,
                    @COD_CTA_SUP,
                    @DATA_CRIACAO,
                    @NATUREZA
        END

    COMMIT TRANSACTION

    CLOSE CONTAS_UPDATE
    DEALLOCATE CONTAS_UPDATE

    IF @UPDATE = '1'
        BEGIN
            EXEC TAF613H_## @IN_FILIAL, @RESULT_C1O OUTPUT
            EXEC TAF613G_## @IN_FILIAL, @C1O, @CT1, @RESULT_V80 OUTPUT
        END

    SELECT @UPDATE = '0'

    DECLARE CONTAS_INSERT INSENSITIVE CURSOR FOR
        SELECT 
            CT1.CT1_DTEXIS DT_ALT,
            C2R.C2R_ID COD_NAT,
            CT1.CT1_CLASSE IND_CTA,
            CT1.CT1_CONTA COD_CTA,
            CT1.CT1_DESC01 NOME_CTA,
            ' ' COD_CTA_REF,
            ' ' CNPJ_EST,
            CT1.CT1_CTASUP COD_CTA_SUP,
            CT1.CT1_DTEXIS DATA_CRIACAO,
            CT1.CT1_NORMAL NATUREZA
        FROM CT1###  CT1
        LEFT JOIN C1O### C1O
            ON C1O.C1O_FILIAL = @FILIAL_C1O 
                AND C1O.C1O_CODIGO = CT1.CT1_CONTA 
                AND C1O.D_E_L_E_T_ = ' '
        INNER JOIN C2R### C2R
            ON C2R.D_E_L_E_T_ = ' ' 
                AND C2R.C2R_FILIAL = @FILIAL_C2R 
                AND C2R.C2R_CODIGO = CT1.CT1_NATCTA
        WHERE CT1.CT1_FILIAL = @FILIAL_CT1 
            AND CT1.D_E_L_E_T_ = ' ' 
            AND (CT1.CT1_BLOQ = '2'
                OR CT1.CT1_BLOQ = ' ')
            AND C1O.C1O_CODIGO IS NULL

    FOR READ ONLY    
    OPEN CONTAS_INSERT

    FETCH CONTAS_INSERT 
        INTO
            @DT_ALT,
            @COD_NAT,
            @IND_CTA,
            @COD_CTA,
            @NOME_CTA,
            @COD_CTA_REF,
            @CNPJ_EST,
            @COD_CTA_SUP,
            @DATA_CRIACAO,
            @NATUREZA

    BEGIN TRANSACTION

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            SELECT @UPDATE = '1'

            IF @DT_ALT < '20000101'
                BEGIN
                    SELECT @DT_ALT = '20000101'
                END

            IF @DATA_CRIACAO < '20000101'
                BEGIN
                    SELECT @DATA_CRIACAO = '20000101'
                END

            EXEC TAF613F_## @IN_FILIAL, @COD_CTA, @NIVEL OUTPUT
            EXEC TAF613K_## @ID_C1O OUTPUT

            INSERT INTO C1O### (
                C1O_FILIAL,
                C1O_ID,
                C1O_DTALT,
                C1O_CODNAT,
                C1O_INDCTA,
                C1O_NIVEL,
                C1O_CODIGO,
                C1O_DESCRI,
                C1O_CTAREF,
                C1O_CNPJ,
                C1O_CTASUP,
                C1O_DTCRIA,
                C1O_NATURE
            ) VALUES (
                @FILIAL_C1O,
                @ID_C1O,
                @DT_ALT,
                @COD_NAT,
                @IND_CTA,
                @NIVEL,
                @COD_CTA,
                @NOME_CTA,
                @COD_CTA_REF,
                @CNPJ_EST,
                @COD_CTA_SUP,
                @DATA_CRIACAO,
                @NATUREZA
            )

            FETCH CONTAS_INSERT 
                INTO
                    @DT_ALT,
                    @COD_NAT,
                    @IND_CTA,
                    @COD_CTA,
                    @NOME_CTA,
                    @COD_CTA_REF,
                    @CNPJ_EST,
                    @COD_CTA_SUP,
                    @DATA_CRIACAO,
                    @NATUREZA
        END

    COMMIT TRANSACTION

    CLOSE CONTAS_INSERT
    DEALLOCATE CONTAS_INSERT

   IF @UPDATE = '1'
        BEGIN
            EXEC TAF613H_## @IN_FILIAL, @RESULT_C1O OUTPUT
            EXEC TAF613G_## @IN_FILIAL, @C1O, @CT1, @RESULT_V80 OUTPUT
        END

    SELECT @OUT_RESULT = '1'
END
