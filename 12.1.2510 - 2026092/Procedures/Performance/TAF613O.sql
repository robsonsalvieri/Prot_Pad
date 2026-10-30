CREATE PROCEDURE TAF613O_##(
    @IN_FILIAL VARCHAR('C3R_FILIAL'),
    @IN_KEYREG VARCHAR('C3R_CODIGO'),
    @IN_NEWID  VARCHAR('C3R_ID'),
    @IN_PARGER VARCHAR('C3R_DESCRI'),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAFA613O </s>
    Descricao   -  <d> Integração entre ERP Livros Fiscais X TAF (SPED) - Informações Complementares </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
                        @IN_KEYREG - Chave de pesquisa a ser executada na procedure
                        @IN_NEWID - ID da tabela C3R, caso o mesmo não seja encontrado na busca da procedure será executado um Insert 
                        @IN_PARGER - Parametro geral, neste caso esta recebendo a descrição  
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execução da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Adilson Roberto </r>
    Data        :  <dt> 10/10/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */

DECLARE @FILIAL_C3R VARCHAR('C3R_FILIAL')
DECLARE @ID_C3R     CHAR('C3R_ID')
DECLARE @C3R        VARCHAR(3)
DECLARE @STATUS     CHAR(1)

BEGIN
    SELECT @ID_C3R      = ' '
    SELECT @C3R         = 'C3R'
    SELECT @OUT_RESULT  = '0'

    SELECT @STATUS      = '0'

    EXEC XFILIAL_## @C3R, @IN_FILIAL, @FILIAL_C3R OUTPUT

    DECLARE CADOBS_UPDATE INSENSITIVE CURSOR FOR
        SELECT C3R.C3R_ID
        FROM C3R### C3R    
        WHERE C3R.D_E_L_E_T_ = ' ' 
            AND C3R.C3R_FILIAL = @FILIAL_C3R 
            AND C3R.C3R_CODIGO = @IN_KEYREG
            AND C3R.C3R_ID = @IN_NEWID

    FOR READ ONLY
    OPEN CADOBS_UPDATE

    FETCH CADOBS_UPDATE INTO @ID_C3R          

    BEGIN TRANSACTION

    IF @@FETCH_STATUS = 0 
        BEGIN  
            IF @ID_C3R <> ' '
                BEGIN
                    UPDATE C3R### 
                        SET
                            C3R_DESCRI = @IN_PARGER
                        WHERE D_E_L_E_T_ = ' ' 
                            AND C3R_FILIAL = @FILIAL_C3R 
                            AND C3R_CODIGO = @IN_KEYREG
                            AND C3R_ID = @ID_C3R 

                    SELECT @STATUS = '1'         
                END
        END
    ELSE
        IF @@FETCH_STATUS = -1
            BEGIN
                INSERT INTO C3R### (
                    C3R_FILIAL,
                    C3R_ID,
                    C3R_CODIGO,
                    C3R_DESCRI
                    ) VALUES (
                    @FILIAL_C3R,
                    @IN_NEWID,
                    @IN_KEYREG,
                    @IN_PARGER
                    )

                    SELECT @STATUS = '1' 
            END


    COMMIT TRANSACTION
    
    CLOSE CADOBS_UPDATE
    DEALLOCATE CADOBS_UPDATE                        

    SELECT @OUT_RESULT = @STATUS

END
