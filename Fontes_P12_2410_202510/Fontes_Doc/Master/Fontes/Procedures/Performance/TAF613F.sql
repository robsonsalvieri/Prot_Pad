CREATE PROCEDURE TAF613F_##(
    @IN_FILIAL CHAR('C1O_FILIAL'),
    @IN_COD_CTA CHAR('C1O_CODIGO'),
    @OUT_RESULT VARCHAR('C1O_NIVEL') OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613F </s>
    Descricao   -  <d> Integraùùo entre ERP Livros Fiscais X TAF (SPED) - Nivel de Contas </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
                        @IN_COD_CTA - Codigo da conta a ser executada a procedure </ri>
    Saida       -  <ro> @OUT_RESULT - Retorna o nùvel da conta </ro>
    Responsavel :  <r> Daniel Aguilar </r>
    Data        :  <dt> 24/08/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */
DECLARE @CT1        CHAR(3)
DECLARE @FILIAL_CT1 VARCHAR('CT1_FILIAL')
DECLARE @CTASUP_CT1 CHAR('CT1_CTASUP')
DECLARE @CTASUP     CHAR('CT1_CTASUP')
DECLARE @NIVEL      INTEGER

BEGIN
    SELECT @CT1     = 'CT1'
    SELECT @CTASUP  = ' '
    SELECT @NIVEL   = 1

    EXEC XFILIAL_## @CT1, @IN_FILIAL, @FILIAL_CT1 OUTPUT

    SELECT @CTASUP_CT1 = CT1.CT1_CTASUP
        FROM CT1### CT1
        WHERE CT1.D_E_L_E_T_ = ' '
            AND CT1.CT1_FILIAL = @FILIAL_CT1
            AND CT1.CT1_CONTA = @IN_COD_CTA 

    WHILE @CTASUP_CT1 <> ' '
        BEGIN
            SELECT @NIVEL = @NIVEL + 1
            
            SELECT @CTASUP = CT1.CT1_CTASUP 
                FROM CT1### CT1 
                WHERE CT1.D_E_L_E_T_ = ' '
                    AND CT1.CT1_FILIAL = @FILIAL_CT1
                    AND CT1.CT1_CONTA = @CTASUP_CT1

            SELECT @CTASUP_CT1 = @CTASUP
        END

    SELECT @OUT_RESULT = CONVERT(VARCHAR('C1O_NIVEL'), @NIVEL)
END