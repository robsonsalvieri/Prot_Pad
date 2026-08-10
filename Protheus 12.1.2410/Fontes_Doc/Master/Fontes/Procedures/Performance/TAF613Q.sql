CREATE PROCEDURE TAF613Q_##(
    @IN_FILIAL CHAR('CCF_FILIAL'),
    @IN_KEYPROC CHAR(255),
    @IN_NEWID  CHAR('C1G_ID'),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAFA613Q </s>
    Descricao   -  <d> Integracao entre ERP Livros Fiscais X TAF (SPED) - Complemento Processos Referenciados </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
                        @IN_KEYPROC - Chave de negocio do registro a ser pocisionado
                        @IN_NEWID - Novo a ID a ser usado na inclusao do registro </ri>
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execucao da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Jose Riquelmo </r>
    Data        :  <dt> 11/10/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */
DECLARE @RESULT         CHAR(1)
DECLARE @DT_MES_INI     VARCHAR(2)
DECLARE @DT_ANO_INI     VARCHAR(4)
DECLARE @DT_MES_FIN     VARCHAR(2)
DECLARE @DT_ANO_FIN     VARCHAR(4)
DECLARE @LAST_NUM_PRO   VARCHAR(10)
DECLARE @LAST_NUM_ATU   VARCHAR(10)
DECLARE @ID_C1G         VARCHAR('C1G_ID')
DECLARE @VERSAO_C1G     VARCHAR('C1G_VERSAO')
DECLARE @IND_DEPOSITO   VARCHAR('CCF_MONINT')  
DECLARE @NUM_PRO        VARCHAR('C1G_NUMPRO')
DECLARE @IND_PRO        VARCHAR('C1G_INDPRO')
DECLARE @DT_INI_CCF     VARCHAR('CCF_DTINI')
DECLARE @DT_FIN_CCF     VARCHAR('CCF_DTFIN')
DECLARE @CODSUS_T5L     VARCHAR('T5L_CODSUS')
DECLARE @ID_VARA        VARCHAR('C1G_VARA')
DECLARE	@DT_SENT	    VARCHAR('C1G_DTSENT')
DECLARE @DT_ADM		    VARCHAR('C1G_DTADM')
DECLARE	@AC_AJUD	    VARCHAR('C1G_SECJUD')
DECLARE	@IN_RCFE	    VARCHAR('C1G_ACAJUD')
DECLARE	@IN_DESCRI	    VARCHAR('C1G_DESCRI')
DECLARE @FILIAL_C1G     VARCHAR('C1G_FILIAL')
DECLARE @FILIAL_T5L     VARCHAR('T5L_FILIAL')
DECLARE @DT_INI_C1G     VARCHAR('C1G_DTINI')
DECLARE @DT_FIN_C1G     VARCHAR('C1G_DTFIN')
DECLARE @TP_COMP        VARCHAR('C1G_TPPROC')
DECLARE @UF_VARA        VARCHAR('C1G_UFVARA')
DECLARE @CODMUNIC       VARCHAR('C1G_CODMUN')
DECLARE @FILIAL_C09     VARCHAR('C09_FILIAL')
DECLARE @FILIAL_C07     VARCHAR('C07_FILIAL')
DECLARE @FILIAL_C8S     VARCHAR('C8S_FILIAL')
DECLARE @COD_SUSP       VARCHAR('CCF_INDSUS')  
DECLARE @IND_SUSP       VARCHAR('C8S_ID')  
DECLARE @DT_DECISAO     VARCHAR('CCF_DTADM')
DECLARE @EVENTO_C1G     VARCHAR('C1G_EVENTO')  
DECLARE @ATIVO_C1G      VARCHAR('C1G_ATIVO')
DECLARE @LOGOPE_C1G     VARCHAR('C1G_LOGOPE')  
DECLARE @PROCESSO       VARCHAR('CCF_NUMERO')
DECLARE @TIPO           VARCHAR('CCF_TIPO') 
DECLARE @DATA_INI       VARCHAR('CCF_DTINI')
DECLARE @DATA_FIN       VARCHAR('CCF_DTFIN')
DECLARE @RECNO          INT

BEGIN
    SELECT @OUT_RESULT      = '0'
    SELECT @EVENTO_C1G      = 'I'
    SELECT @ATIVO_C1G       = '1'
    SELECT @LOGOPE_C1G      = '2'
    SELECT @LAST_NUM_PRO    = ' '
    SELECT @RECNO           = 0

    SELECT 
        @PROCESSO = CCF.CCF_NUMERO, 
        @TIPO = CCF.CCF_TIPO
        FROM CCF### CCF 
        WHERE CCF.R_E_C_N_O_ = CONVERT(INTEGER, @IN_KEYPROC)

    EXEC XFILIAL_## 'C1G', @IN_FILIAL, @FILIAL_C1G OUTPUT
    EXEC XFILIAL_## 'T5L', @IN_FILIAL, @FILIAL_T5L OUTPUT
    EXEC XFILIAL_## 'C09', @IN_FILIAL, @FILIAL_C09 OUTPUT
    EXEC XFILIAL_## 'C07', @IN_FILIAL, @FILIAL_C07 OUTPUT
    EXEC XFILIAL_## 'C8S', @IN_FILIAL, @FILIAL_C8S OUTPUT

    DECLARE PROCESS INSENSITIVE CURSOR FOR
        SELECT 
            CCF.CCF_NUMERO NUM_PRO,
            CCF.CCF_TIPO IND_PRO,
            CCF.CCF_DTINI DT_INI_CCF,
            CCF.CCF_DTFIN DT_FIN_CCF,
            CCF.CCF_IDVARA ID_VARA,
            CCF.CCF_DTSENT DT_SENT,
            CCF.CCF_DTADM DT_ADM,
            CCF.CCF_IDSEJU AC_AJUD,
            CCF.CCF_NATAC IN_RCFE,
            CCF.CCF_DESCJU IN_DESCRI,
            COALESCE(C8S.C8S_ID, ' ') IND_SUSP,
            CCF.CCF_INDSUS COD_SUSP,
            COALESCE(CCF.CCF_DTADM, ' ') DT_DECISAO,
            CCF.CCF_MONINT IND_DEPOSITO,
            COALESCE(C1G.C1G_ID, ' ') ID_C1G,
            COALESCE(C1G.C1G_VERSAO, ' ') VERSAO_C1G,
            CCF.CCF_TPCOMP TP_COMP,
            COALESCE(C09.C09_ID, ' ') UF_VARA,
            COALESCE(C07.C07_ID, ' ') CODMUNIC,
            COALESCE(T5L.T5L_CODSUS, ' ') CODSUS_T5L
            FROM CCF### CCF
		    LEFT JOIN C09### C09
                ON C09.C09_FILIAL = @FILIAL_C09
		            AND C09.C09_UF = CCF.CCF_UF
		            AND C09.D_E_L_E_T_ = ' '
		    LEFT JOIN C07### C07
		        ON C07.C07_FILIAL = @FILIAL_C07
		            AND C07.C07_UF = C09.C09_ID
                    AND C07.C07_CODIGO = CCF.CCF_CODMUN
		            AND C07.D_E_L_E_T_ = ' '
            LEFT JOIN C8S### C8S
                ON C8S.C8S_FILIAL = @FILIAL_C8S
                    AND C8S.C8S_CODIGO = CCF.CCF_SUSEXI
                    AND C8S.D_E_L_E_T_ = ' '
		    LEFT JOIN C1G### C1G
		        ON C1G.C1G_FILIAL = @FILIAL_C1G
		            AND C1G.C1G_NUMPRO = CCF.CCF_NUMERO
                    AND C1G.C1G_INDPRO = CCF.CCF_TIPO
		            AND C1G.D_E_L_E_T_ = ' '
		    LEFT JOIN T5L### T5L
		        ON T5L.T5L_FILIAL = @FILIAL_T5L
		            AND T5L.T5L_ID = C1G.C1G_ID
                    AND T5L.T5L_VERSAO = C1G.C1G_VERSAO
					AND T5L.T5L_CODSUS = CCF.CCF_INDSUS
		            AND T5L.D_E_L_E_T_ = ' '
            WHERE CCF.CCF_NUMERO = @PROCESSO
                AND CCF.CCF_TIPO = @TIPO
                AND CCF.D_E_L_E_T_ = ' '

    FOR READ ONLY    
    OPEN PROCESS

    FETCH PROCESS 
        INTO
            @NUM_PRO,
            @IND_PRO,
            @DT_INI_CCF,
            @DT_FIN_CCF,
            @ID_VARA,
            @DT_SENT,
            @DT_ADM,
            @AC_AJUD,
            @IN_RCFE,
            @IN_DESCRI,
            @IND_SUSP,
            @COD_SUSP,
            @DT_DECISAO,
            @IND_DEPOSITO,
            @ID_C1G,
            @VERSAO_C1G,
            @TP_COMP,
            @UF_VARA,
            @CODMUNIC,
            @CODSUS_T5L

    WHILE @@FETCH_STATUS = 0 
        BEGIN
            SELECT @DT_ANO_INI = SUBSTRING(@DT_INI_CCF, 1, 4)
            SELECT @DT_MES_INI = SUBSTRING(@DT_INI_CCF, 5, 2)
            SELECT @DT_ANO_FIN = SUBSTRING(@DT_FIN_CCF, 1, 4)
            SELECT @DT_MES_FIN = SUBSTRING(@DT_FIN_CCF, 5, 2)

            ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                SELECT @DT_INI_C1G = @DT_MES_INI + @DT_ANO_INI    
                SELECT @DT_FIN_C1G = @DT_MES_FIN + @DT_ANO_FIN
            ##ENDIF_001

            ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "ORACLE/POSTGRES"})
                SELECT @DT_INI_C1G = @DT_MES_INI || @DT_ANO_INI   
                SELECT @DT_FIN_C1G = @DT_MES_FIN || @DT_ANO_FIN 
            ##ENDIF_002

            IF ltrim(rtrim(@ID_C1G)) = '' OR ltrim(rtrim(@CODSUS_T5L)) = ''
                BEGIN
                    IF ltrim(rtrim(@ID_C1G)) = '' AND @NUM_PRO <> @LAST_NUM_PRO  
                        BEGIN
                            BEGIN TRANSACTION

                                INSERT INTO C1G### (
                                    C1G_FILIAL,
                                    C1G_ID,
                                    C1G_NUMPRO, 
                                    C1G_INDPRO,
                                    C1G_DTINI, 
                                    C1G_DTFIN,
                                    C1G_VARA,
                                    C1G_DTSENT,
                                    C1G_DTADM,
                                    C1G_SECJUD,
                                    C1G_ACAJUD,
                                    C1G_DESCRI,
                                    C1G_TPPROC,
                                    C1G_UFVARA,
                                    C1G_CODMUN,
                                    C1G_EVENTO,
                                    C1G_ATIVO,
                                    C1G_LOGOPE 
                                ) VALUES (
                                    @FILIAL_C1G,
                                    @IN_NEWID,
                                    @NUM_PRO,
                                    @IND_PRO,
                                    @DT_INI_C1G,
                                    @DT_FIN_C1G,
                                    @ID_VARA,
                                    @DT_SENT,
                                    @DT_ADM,
                                    @AC_AJUD,
                                    @IN_RCFE,
                                    @IN_DESCRI,
                                    @TP_COMP,
                                    @UF_VARA,
                                    @CODMUNIC,
                                    @EVENTO_C1G,
                                    @ATIVO_C1G, 
                                    @LOGOPE_C1G
                                )

                            COMMIT TRANSACTION 
                        END             
                        
                    IF (ltrim(rtrim(@IND_SUSP)) <> '' OR ltrim(rtrim(@CODSUS_T5L)) = '') 
                        BEGIN
                            ##UNIQUEKEY_START

                                SELECT @RECNO = COALESCE(MIN(T5L.R_E_C_N_O_), 0) FROM T5L### T5L 
                                    WHERE T5L.T5L_FILIAL = @FILIAL_T5L 
                                        AND T5L.T5L_ID = @IN_NEWID 
                                        AND T5L.T5L_VERSAO = @VERSAO_C1G
                                        AND T5L.T5L_CODSUS = @COD_SUSP
                                        AND T5L.D_E_L_E_T_ = ' '

                            ##UNIQUEKEY_END

                            IF @RECNO = 0
                                BEGIN
                                    SELECT @RECNO = ISNULL(MAX(T5L.R_E_C_N_O_), 0) FROM T5L### T5L
                                    SELECT @RECNO = @RECNO + 1

                                    ##TRATARECNO @RECNO\

                                        BEGIN TRANSACTION

                                            INSERT INTO T5L### (
                                                T5L_FILIAL,
                                                T5L_ID,
                                                T5L_CODSUS, 
                                                T5L_INDDEC,
                                                T5L_DTDEC,
                                                T5L_INDDEP,
                                                R_E_C_N_O_
                                            ) VALUES (
                                                @FILIAL_T5L,
                                                @IN_NEWID,
                                                @COD_SUSP,
                                                @IND_SUSP,
                                                @DT_DECISAO,
                                                @IND_DEPOSITO,
                                                @RECNO
                                            )
                                        
                                        COMMIT TRANSACTION 

                                    ##FIMTRATARECNO
                                END
                            ELSE
                                BEGIN
                                    BEGIN TRANSACTION

                                        UPDATE T5L###
                                            SET T5L_INDDEC = @IND_SUSP,
                                                T5L_DTDEC = @DT_DECISAO,
                                                T5L_INDDEP = @IND_DEPOSITO
                                            WHERE R_E_C_N_O_ = @RECNO

                                    COMMIT TRANSACTION 
                                END

                        END

                END
            ELSE
                BEGIN
                    IF @NUM_PRO <> @LAST_NUM_PRO  
                        BEGIN
                            SELECT @LOGOPE_C1G = '6'

                            BEGIN TRANSACTION

                                UPDATE C1G### 
                                    SET
                                        C1G_NUMPRO = @NUM_PRO,
                                        C1G_INDPRO = @IND_PRO,
                                        C1G_DTINI = @DT_INI_C1G,
                                        C1G_DTFIN = @DT_FIN_C1G,
                                        C1G_VARA = @ID_VARA,
                                        C1G_DTSENT = @DT_SENT,
                                        C1G_DTADM = @DT_ADM,
                                        C1G_SECJUD = @AC_AJUD,
                                        C1G_ACAJUD = @IN_RCFE,
                                        C1G_DESCRI = @IN_DESCRI,
                                        C1G_TPPROC = @TP_COMP,
                                        C1G_UFVARA = @UF_VARA,
                                        C1G_CODMUN = @CODMUNIC,
                                        C1G_EVENTO = @EVENTO_C1G,
                                        C1G_ATIVO = @ATIVO_C1G,
                                        C1G_LOGOPE = @LOGOPE_C1G
                                    WHERE C1G_FILIAL = @FILIAL_C1G
                                        AND C1G_ID = @ID_C1G
                                        AND D_E_L_E_T_ = ' '

                            COMMIT TRANSACTION 
                        END             
                        
                    IF ltrim(rtrim(@IND_SUSP)) <> '' 
                        BEGIN
                            BEGIN TRANSACTION

                                UPDATE T5L### 
                                    SET
                                        T5L_CODSUS = @COD_SUSP, 
                                        T5L_INDDEC = @IND_SUSP,
                                        T5L_DTDEC = @DT_DECISAO,
                                        T5L_INDDEP = @IND_DEPOSITO
                                    WHERE T5L_FILIAL = @FILIAL_T5L 
                                        AND T5L_ID = @ID_C1G 
                                        AND T5L_VERSAO = @VERSAO_C1G
                                        AND T5L_CODSUS = @COD_SUSP
                                        AND D_E_L_E_T_ = ' '

                            COMMIT TRANSACTION       
                        END
                END

            SELECT @LAST_NUM_PRO = @NUM_PRO

            FETCH PROCESS 
                INTO
                    @NUM_PRO,
                    @IND_PRO,
                    @DT_INI_CCF,
                    @DT_FIN_CCF,
                    @ID_VARA,
                    @DT_SENT,
                    @DT_ADM,
                    @AC_AJUD,
                    @IN_RCFE,
                    @IN_DESCRI,
                    @IND_SUSP,
                    @COD_SUSP,
                    @DT_DECISAO,
                    @IND_DEPOSITO,
                    @ID_C1G,
                    @VERSAO_C1G,
                    @TP_COMP,
                    @UF_VARA,
                    @CODMUNIC,
                    @CODSUS_T5L
        END

    CLOSE PROCESS
    DEALLOCATE PROCESS

    SELECT @OUT_RESULT = '1'
END