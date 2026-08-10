CREATE PROCEDURE TAF613V_##(
    @IN_FILIAL  CHAR('T8Q_FILIAL'),
    @IN_KEYREG  CHAR(255),
    @IN_NEWID   CHAR('T8Q_ID'),
    @IN_PARGER  CHAR('T8Q_CODIGO'),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Vers�o      -  <v> Protheus P12 </v>
    Programa    -  <s> TAFA613V </s>
    Descricao   -  <d> Integra��o entre ERP Livros Fiscais X TAF (SPED) - Tributos gen�ricos </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedur
                        @IN_KEYREG - R_E_C_N_O_ do registro a ser integrado
                        @IN_NEWID - Id do registro a ser integrado
                        @IN_PARGER - C�digo do registro a ser integrado </ri>
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execu��o da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel -  <r> Melkz Siqueira < /r>
    Data        -  <dt> 04/11/2024 </dt>
--------------------------------------------------------------------------------------------------------------------- */
DECLARE @FILIAL_T8Q VARCHAR('T8Q_FILIAL') 
DECLARE @TRIB_F2E   VARCHAR('F2E_TRIB')
DECLARE @DESC_F2E   VARCHAR('F2E_DESC')
DECLARE @ESFERA_F2E VARCHAR('F2E_ESFERA')
DECLARE @ESPECI_F2E VARCHAR('F2E_ESPECIE')

BEGIN
    SELECT @OUT_RESULT  = '0'

    EXEC XFILIAL_## 'T8Q', @IN_FILIAL, @FILIAL_T8Q OUTPUT

    SELECT  
        @TRIB_F2E = F2E.F2E_TRIB,
        @ESFERA_F2E = F2E.F2E_ESFERA,
        @ESPECI_F2E = F2E.F2E_ESPECI,
        @DESC_F2E = F2E.F2E_DESC  
        FROM F2E### F2E
        WHERE F2E.R_E_C_N_O_ = CONVERT(INTEGER, @IN_KEYREG)

    BEGIN TRANSACTION

        IF @IN_PARGER = ' '
            BEGIN
                UPDATE T8Q###
                    SET 
                        T8Q_DESCRI = @DESC_F2E,
                        T8Q_CODIGO = @TRIB_F2E, 
                        T8Q_ESFERA = @ESFERA_F2E,
                        T8Q_ESPECI = @ESPECI_F2E
                    WHERE T8Q_FILIAL = @FILIAL_T8Q
                        AND T8Q_ID = @IN_NEWID
                        AND D_E_L_E_T_ = ' '
            END
        ELSE
            BEGIN
                INSERT INTO T8Q### (
                    T8Q_FILIAL,
                    T8Q_ID,
                    T8Q_CODIGO,
                    T8Q_DESCRI,
                    T8Q_ESFERA,
                    T8Q_ESPECI
                ) VALUES (
                    @FILIAL_T8Q,
                    @IN_NEWID,
                    @TRIB_F2E,
                    @DESC_F2E,
                    @ESFERA_F2E,
                    @ESPECI_F2E
                )
            END

    COMMIT TRANSACTION

    SELECT @OUT_RESULT = '1'
END
