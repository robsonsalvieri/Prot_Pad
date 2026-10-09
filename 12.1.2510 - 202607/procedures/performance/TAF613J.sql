CREATE PROCEDURE TAF613J_##(
    @IN_FILIAL CHAR('V7R_FILIAL'),
    @IN_PROCESSO CHAR('V7R_PROCES'),
    @IN_PROCEDURE CHAR('V7R_PROCED'),
    @IN_TABELA CHAR('V7R_TABELA'),
    @IN_SEQUENCIA INTEGER,
    @OUT_ID CHAR('V7R_ID') OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613J </s>
    Descricao   -  <d> Integraùùo entre ERP Livros Fiscais X TAF (SPED) - Retorna o ID sequencial </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
                        @IN_PROCESSO - Processo em que o ID foi gerado
                        @IN_PROCEDURE - Procedure em que o ID foi gerado
                        @IN_TABELA - Tabela em que o ID foi gerado
                        @IN_SEQUENCIA - Sequencia do ID gerado </ri>
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execuùùo da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Daniel Aguilar </r>
    Data        :  <dt> 29/08/2023 </dt>

--------------------------------------------------------------------------------------------------------------------- */
DECLARE @FILIAL_V7R VARCHAR('V7R_FILIAL')
DECLARE @ID         CHAR('V7R_ID')
DECLARE @V7R        CHAR(3)
DECLARE @SEQUENCIA  VARCHAR('V7R_SEQUEN')

BEGIN
    SELECT @OUT_ID      = ' '
    SELECT @ID          = ' '
    SELECT @V7R         = 'V7R'
    SELECT @SEQUENCIA   = CONVERT(VARCHAR('V7R_SEQUEN'), @IN_SEQUENCIA)

    EXEC XFILIAL_## @V7R, @IN_FILIAL, @FILIAL_V7R OUTPUT
    
    SELECT @ID = V7R.V7R_ID FROM V7R### V7R 
        WHERE V7R.D_E_L_E_T_ = ' ' 
            AND V7R.V7R_FILIAL = @FILIAL_V7R 
            AND V7R.V7R_PROCES = @IN_PROCESSO
            AND V7R.V7R_PROCED = @IN_PROCEDURE 
            AND V7R.V7R_TABELA = @IN_TABELA
            AND V7R.V7R_SEQUEN = @SEQUENCIA

    BEGIN TRANSACTION

    DELETE 
        FROM V7R### 
        WHERE D_E_L_E_T_ = ' ' 
            AND V7R_FILIAL = @FILIAL_V7R
            AND V7R_PROCES = @IN_PROCESSO 
            AND V7R_PROCED = @IN_PROCEDURE 
            AND V7R_TABELA = @IN_TABELA 
            AND V7R_SEQUEN = @SEQUENCIA
            
    COMMIT TRANSACTION

    SELECT @OUT_ID = LTRIM(RTRIM(@ID))
END