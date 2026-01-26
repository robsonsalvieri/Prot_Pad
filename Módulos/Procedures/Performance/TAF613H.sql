CREATE PROCEDURE TAF613H_##(
    @IN_FILIAL CHAR('C1O_FILIAL'),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613H </s>
    Descricao   -  <d> Integraùùo entre ERP Livros Fiscais X TAF (SPED) - Atualizaùùo do campo C1O_CTASUP </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure </ri>
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execuùùo da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Daniel Aguilar </r>
    Data        :  <dt> 29/08/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */
DECLARE @C1O CHAR(3)
DECLARE @FILIAL_C1O VARCHAR('C1O_FILIAL')
DECLARE @RECNO INT
DECLARE @CTASUP_C1O VARCHAR('C1O_CTASUP')

BEGIN
    SELECT @OUT_RESULT  = '0'
    SELECT @C1O         = 'C1O'

    EXEC XFILIAL_## @C1O, @IN_FILIAL, @FILIAL_C1O OUTPUT

    DECLARE CONTAS_SUP_UPDATE INSENSITIVE CURSOR FOR
        SELECT C1OA.C1O_ID C1O_CTASUP, C1O.R_E_C_N_O_
            FROM C1O### C1O
            INNER JOIN C1O### C1OA
                ON C1OA.D_E_L_E_T_ = ' '
                    AND C1OA.C1O_FILIAL = @FILIAL_C1O
                    AND C1OA.C1O_CODIGO = C1O.C1O_CTASUP
            WHERE C1O.D_E_L_E_T_ = ' '
                AND C1O.C1O_FILIAL = @FILIAL_C1O
                AND C1O.C1O_CTASUP <> ' '

    FOR READ ONLY
    OPEN CONTAS_SUP_UPDATE

    FETCH CONTAS_SUP_UPDATE INTO @CTASUP_C1O, @RECNO

    BEGIN TRANSACTION

        WHILE @@FETCH_STATUS = 0 
            BEGIN
                UPDATE C1O### 
                    SET C1O_CTASUP = @CTASUP_C1O
                    WHERE R_E_C_N_O_ = @RECNO
    
                FETCH CONTAS_SUP_UPDATE INTO @CTASUP_C1O, @RECNO
            END

    COMMIT TRANSACTION

    CLOSE CONTAS_SUP_UPDATE
    DEALLOCATE CONTAS_SUP_UPDATE

    SELECT @OUT_RESULT = '1'
END