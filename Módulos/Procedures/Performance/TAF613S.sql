CREATE PROCEDURE TAF613S_##(
    @IN_FILIAL CHAR('CDT_FILIAL'),
    @IN_KEYREG VARCHAR('CCE_COD'),
    @IN_NEWID VARCHAR('C3Q_ID'),
    @OUT_RESULT CHAR(1) OUTPUT
) AS  

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613S </s>
    Descricao   -  <d> Integracao entre ERP Livros Fiscais X TAF (SPED) - Informacoes complementares </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
                        @IN_KEYREG - Chave de negocio do registro a ser pocisionado
                        @IN_NEWID - Novo a ID a ser usado na inclusao do registro </ri>
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execucao da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Daniel Aguilar </r>
    Data        :  <dt> 31/10/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */
DECLARE @C3Q            CHAR(3)
DECLARE @CCE            CHAR(3)
DECLARE @RESULT         CHAR(1)
DECLARE @ID_C3Q         CHAR('C3Q_ID')
DECLARE @FILIAL_C3Q     VARCHAR('C3Q_FILIAL')
DECLARE @FILIAL_CCE     VARCHAR('CCE_FILIAL')
DECLARE @COD_INF        VARCHAR('C3Q_CODINF')
DECLARE @TXT_COMPL      VARCHAR('C3Q_TXTCOM')

BEGIN
    SELECT @OUT_RESULT  = '0'
    SELECT @RESULT      = '0'
    SELECT @C3Q         = 'C3Q'
    SELECT @CCE         = 'CCE'

    EXEC XFILIAL_## @C3Q, @IN_FILIAL, @FILIAL_C3Q OUTPUT
    EXEC XFILIAL_## @CCE, @IN_FILIAL, @FILIAL_CCE OUTPUT

    DECLARE INFOCOMPL_UPDATE INSENSITIVE CURSOR FOR
        SELECT 
            CCE.CCE_DESCR TXT_COMPL,
            CCE.CCE_COD COD_INF,
            COALESCE(C3Q.C3Q_ID,' ') ID_C3Q
        FROM CCE### CCE
        LEFT JOIN C3Q### C3Q
            ON C3Q.D_E_L_E_T_ = ' '
                AND C3Q.C3Q_FILIAL = @FILIAL_C3Q
                AND C3Q.C3Q_CODINF = CCE.CCE_COD
        WHERE CCE.D_E_L_E_T_ = ' '
            AND CCE.CCE_FILIAL = @FILIAL_CCE
            AND CCE.CCE_COD = @IN_KEYREG

    FOR READ ONLY
    OPEN INFOCOMPL_UPDATE

    FETCH INFOCOMPL_UPDATE
        INTO
            @TXT_COMPL,
            @COD_INF,
            @ID_C3Q

    BEGIN TRANSACTION

        IF @@FETCH_STATUS = 0 
            BEGIN
                IF @ID_C3Q = ' '
                    BEGIN
                        INSERT INTO C3Q### (
                            C3Q_FILIAL, 
                            C3Q_ID,
                            C3Q_TXTCOM,
                            C3Q_CODINF                                
                        ) VALUES (
                            @FILIAL_C3Q,
                            @IN_NEWID,
                            @TXT_COMPL,
                            @COD_INF
                        )
                    END
                ELSE
                    BEGIN
                        UPDATE C3Q###
                            SET C3Q_TXTCOM = @TXT_COMPL
                            WHERE D_E_L_E_T_ = ' ' 
                                AND C3Q_FILIAL = @FILIAL_C3Q
                                AND C3Q_ID     = @IN_NEWID
                    END
                    
                SELECT @RESULT = '1'
            END

    COMMIT TRANSACTION

    CLOSE INFOCOMPL_UPDATE
    DEALLOCATE INFOCOMPL_UPDATE
    
    SELECT @OUT_RESULT = @RESULT /*A STORED PROCEDURE RETORNA 1 CASO TUDO TENHA EXECUTADO ATE AQUI SEM ERROS*/
END
