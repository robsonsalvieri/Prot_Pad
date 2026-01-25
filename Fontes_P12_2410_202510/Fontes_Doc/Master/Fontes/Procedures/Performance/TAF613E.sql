CREATE PROCEDURE TAF613E_##(
    @IN_FILIAL CHAR('C2M_FILIAL'),
    @IN_CODIGO CHAR('C2M_CODIGO'),
    @IN_COD_SERV_MUN CHAR('C1L_SRVMUN'),
    @IN_MV_BLKTP00 VARCHAR(255),
    @IN_MV_BLKTP01 VARCHAR(255),
    @IN_MV_BLKTP02 VARCHAR(255),
    @IN_MV_BLKTP03 VARCHAR(255),
    @IN_MV_BLKTP04 VARCHAR(255),
    @IN_MV_BLKTP06 VARCHAR(255),
    @IN_MV_BLKTP10 VARCHAR(255),
    @OUT_RESULT VARCHAR('C2M_ID') OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613E </s>
    Descricao   -  <d> Retorna o ID do Tipo do Item</d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
                        @IN_CODIGO - Cùdigo de Tipo do Item Fiscal
                        @IN_COD_SERV_MUN - Cùdigo do serviùo do municùpio
                        @IN_MV_BLKTP00 - Conteùdo do parùmetro MV_BLKTP00 
                        @IN_MV_BLKTP01 - Conteùdo do parùmetro MV_BLKTP01 
                        @IN_MV_BLKTP02 - Conteùdo do parùmetro MV_BLKTP02 
                        @IN_MV_BLKTP03 - Conteùdo do parùmetro MV_BLKTP03 
                        @IN_MV_BLKTP04 - Conteùdo do parùmetro MV_BLKTP04 
                        @IN_MV_BLKTP06 - Conteùdo do parùmetro MV_BLKTP06 
                        @IN_MV_BLKTP10 - Conteùdo do parùmetro MV_BLKTP10 </ri>  
    Saida       -  <ro> @OUT_RESULT - ID do Tipo do Item </ro>
    Responsavel :  <r> Melkz Siqueira </r>
    Data        :  <dt> 24/07/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */

DECLARE @C2M        CHAR(3)
DECLARE @SX6        CHAR(3)
DECLARE @TIPO       CHAR('C2M_CODIGO')
DECLARE @FILIAL_C2M CHAR('C2M_FILIAL')
DECLARE @FILIAL_SX6 CHAR('C2M_FILIAL')

BEGIN
    SELECT @C2M         = 'C2M'
    SELECT @OUT_RESULT  = ' '
    SELECT @TIPO        = ' '

    IF @IN_COD_SERV_MUN <> ' '
        BEGIN
            SELECT @TIPO = '09'
        END
    ELSE
        BEGIN
            IF @IN_CODIGO = 'MC'
                BEGIN
                    SELECT @TIPO = '07'
                END

            IF @IN_CODIGO = 'AI'
                BEGIN
                    SELECT @TIPO = '08'
                END

            ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                IF @IN_CODIGO = 'ME' OR @IN_MV_BLKTP00 LIKE '%' + @IN_CODIGO + '%'
                    BEGIN
                        SELECT @TIPO = '00'
                    END

                IF @IN_CODIGO = 'EM' OR @IN_MV_BLKTP02 LIKE '%' + @IN_CODIGO + '%'
                    BEGIN
                        SELECT @TIPO = '02'
                    END

                IF @IN_CODIGO = 'MP' OR @IN_MV_BLKTP01 LIKE '%' + @IN_CODIGO + '%'
                    BEGIN
                        SELECT @TIPO = '01'
                    END

                IF @IN_CODIGO = 'OI' OR @IN_MV_BLKTP10 LIKE '%' + @IN_CODIGO + '%'
                    BEGIN
                        SELECT @TIPO = '10'
                    END

                IF @IN_CODIGO = 'PA' OR @IN_MV_BLKTP04 LIKE '%' + @IN_CODIGO + '%'
                    BEGIN
                        SELECT @TIPO = '04'
                    END

                IF @IN_CODIGO = 'PI' OR @IN_MV_BLKTP06 LIKE '%' + @IN_CODIGO + '%'
                    BEGIN
                        SELECT @TIPO = '06'
                    END

                IF @IN_CODIGO = 'PP' OR @IN_MV_BLKTP03 LIKE '%' + @IN_CODIGO + '%'
                    BEGIN
                        SELECT @TIPO = '03'
                    END

                IF @IN_CODIGO = 'SP' OR @IN_MV_BLKTP04 LIKE '%' + @IN_CODIGO + '%'
                    BEGIN
                        SELECT @TIPO = '05'
                    END
            ##ENDIF_001

            ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "ORACLE/POSTGRES"})
                IF @IN_CODIGO = 'ME' OR @IN_MV_BLKTP00 LIKE '%' || @IN_CODIGO || '%'
                    BEGIN
                        SELECT @TIPO = '00'
                    END

                IF @IN_CODIGO = 'EM' OR @IN_MV_BLKTP02 LIKE '%' || @IN_CODIGO || '%'
                    BEGIN
                        SELECT @TIPO = '02'
                    END

                IF @IN_CODIGO = 'MP' OR @IN_MV_BLKTP01 LIKE '%' || @IN_CODIGO || '%'
                    BEGIN
                        SELECT @TIPO = '01'
                    END

                IF @IN_CODIGO = 'OI' OR @IN_MV_BLKTP10 LIKE '%' || @IN_CODIGO || '%'
                    BEGIN
                        SELECT @TIPO = '10'
                    END

                IF @IN_CODIGO = 'PA' OR @IN_MV_BLKTP04 LIKE '%' || @IN_CODIGO || '%'
                    BEGIN
                        SELECT @TIPO = '04'
                    END

                IF @IN_CODIGO = 'PI' OR @IN_MV_BLKTP06 LIKE '%' || @IN_CODIGO || '%'
                    BEGIN
                        SELECT @TIPO = '06'
                    END

                IF @IN_CODIGO = 'PP' OR @IN_MV_BLKTP03 LIKE '%' || @IN_CODIGO || '%'
                    BEGIN
                        SELECT @TIPO = '03'
                    END

                IF @IN_CODIGO = 'SP' OR @IN_MV_BLKTP04 LIKE '%' || @IN_CODIGO || '%'
                    BEGIN
                        SELECT @TIPO = '05'
                    END
            ##ENDIF_002
            
        END

    IF @IN_CODIGO <> ' ' AND @TIPO <> ' '
        BEGIN
            EXEC XFILIAL_## @C2M, @IN_FILIAL, @FILIAL_C2M OUTPUT
            
            SELECT @OUT_RESULT = COALESCE(C2M.C2M_ID, ' ') 
                FROM C2M### C2M 
                WHERE C2M.D_E_L_E_T_ = ' ' 
                    AND C2M.C2M_FILIAL = @FILIAL_C2M 
                    AND C2M.C2M_CODIGO = @TIPO
        END

END