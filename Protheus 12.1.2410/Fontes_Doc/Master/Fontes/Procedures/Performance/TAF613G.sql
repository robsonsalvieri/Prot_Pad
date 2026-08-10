CREATE PROCEDURE TAF613G_##(
    @IN_FILIAL CHAR('V80_FILIAL'),
    @IN_ALIAS_TAF VARCHAR('V80_ALIAS'),
    @IN_ALIAS_ERP VARCHAR('V80_ALIERP'),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613G </s>
    Descricao   -  <d> Integração entre ERP Livros Fiscais X TAF (SPED) - Atualização da ultima modificação da tabela na V80 </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
                        @IN_ALIAS_TAF - ALIAS do TAF 
                        @IN_ALIAS_ERP - ALIAS do ERP </ri>
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execução da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Daniel Aguilar </r>
    Data        :  <dt> 25/08/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */
DECLARE @V80            CHAR(3)
DECLARE @COMPARTILHADA  CHAR(1)
DECLARE @FILIAL_V80     VARCHAR('V80_FILIAL')
DECLARE @FILIAL_TAF     CHAR('V80_FILIAL')
DECLARE @FILIAL_ERP     CHAR('V80_FILIAL')
DECLARE @STAMP          VARCHAR('V80_STAMP')
DECLARE @RECNO          INT

BEGIN
    SELECT @V80           = 'V80'
    SELECT @COMPARTILHADA = '0'
    SELECT @RECNO         = 0

    ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
        SELECT @STAMP = CONVERT(VARCHAR('V80_STAMP'), GETDATE(), 21)
    ##ENDIF_001

    ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
       SELECT @STAMP = SUBSTR(TO_CHAR(SYSTIMESTAMP, 'DD.MM.YYYY HH24:MI:SS.FF'), 1, 23)
    ##ENDIF_002

    ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
       SELECT @STAMP = SUBSTR(TO_CHAR(LOCALTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.MS'), 1, 23)
    ##ENDIF_003

    EXEC XFILIAL_## @V80, @IN_FILIAL, @FILIAL_V80 OUTPUT
    EXEC XFILIAL_## @IN_ALIAS_TAF, @IN_FILIAL, @FILIAL_TAF OUTPUT
    EXEC XFILIAL_## @IN_ALIAS_ERP, @IN_FILIAL, @FILIAL_ERP OUTPUT

    IF @FILIAL_TAF = ' ' AND @FILIAL_ERP = ' '
        BEGIN
          SELECT  @COMPARTILHADA = '1'
        END

    ##UNIQUEKEY_START
        SELECT @RECNO = COALESCE(MIN(V80.R_E_C_N_O_), 0) FROM V80### V80 
            WHERE V80.D_E_L_E_T_ = ' ' 
                AND V80.V80_FILIAL = @FILIAL_V80 
                AND V80.V80_ALIAS = @IN_ALIAS_TAF 
                AND V80.V80_ALIERP = @IN_ALIAS_ERP 
                AND V80.V80_COMPAR = @COMPARTILHADA
    ##UNIQUEKEY_END

    IF @RECNO = 0
        BEGIN
            SELECT @RECNO = ISNULL(MAX(V80.R_E_C_N_O_), 0) FROM V80### V80
            SELECT @RECNO = @RECNO + 1

            ##TRATARECNO @RECNO\
                BEGIN TRANSACTION

                INSERT INTO V80### (
                    V80_FILIAL,
                    V80_ALIAS,
                    V80_STAMP,
                    V80_ALIERP,
                    V80_COMPAR,
                    R_E_C_N_O_
                ) VALUES (
                    @FILIAL_V80,
                    @IN_ALIAS_TAF,
                    @STAMP,
                    @IN_ALIAS_ERP,
                    @COMPARTILHADA,
                    @RECNO
                )

                COMMIT TRANSACTION

            ##FIMTRATARECNO
        END
    ELSE
        BEGIN
            BEGIN TRANSACTION

                UPDATE V80###
                    SET V80_STAMP = @STAMP,
                        V80_ALIERP = @IN_ALIAS_ERP,
                        V80_COMPAR = @COMPARTILHADA
                    WHERE R_E_C_N_O_ = @RECNO

            COMMIT TRANSACTION
        END

    SELECT @OUT_RESULT = '1'
END