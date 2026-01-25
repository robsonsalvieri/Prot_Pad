CREATE PROCEDURE TAF613P_##(
    @IN_FILIAL VARCHAR('CDE_FILIAL'),
    @IN_KEYREG VARCHAR('LG_PDV'),
    @IN_NEWID VARCHAR('C0W_ID'),
    @OUT_RESULT CHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613P </s>
    Descricao   -  <d> Integração entre ERP Livros Fiscais X TAF (SPED) - Cadastro do ECF / SAT-CFE </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
                        @IN_KEYREG - Chave de negocio do registro a ser pocisionado
                        @IN_NEWID - Novo a ID a ser usado na inclusao do registro </ri>
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execução da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Carlos Eduardo Silva </r>
    Data        :  <dt> 27/09/2023 </dt>
--------------------------------------------------------------------------------------------------------------------- */
DECLARE @C0W            CHAR(3)
DECLARE @SLG            CHAR(3)
DECLARE @RESULT         CHAR(1)
DECLARE @ID_C0W         CHAR('C0W_ID')
DECLARE @FILIAL_SLG     VARCHAR('LG_FILIAL') 
DECLARE @FILIAL_C0W     VARCHAR('C0W_FILIAL') 
DECLARE @ECF_CODIGO     VARCHAR('C0W_CODIGO')
DECLARE @ECF_DESCRI     VARCHAR('C0W_DESCRI')
DECLARE @ECF_MODEQUIP   VARCHAR('C0W_ECFMOD')
DECLARE @ECF_NUMSERIE   VARCHAR('C0W_ECFFAB')

BEGIN
    SELECT @OUT_RESULT  = '0'
    SELECT @RESULT      = '0'
    SELECT @C0W         = 'C0W'
    SELECT @SLG         = 'SLG'

    EXEC XFILIAL_## @C0W, @IN_FILIAL, @FILIAL_C0W OUTPUT 
    EXEC XFILIAL_## @SLG, @IN_FILIAL, @FILIAL_SLG OUTPUT

    DECLARE SLG_QUERY INSENSITIVE CURSOR FOR
        SELECT 
            SLG.LG_CODIGO,  
            SLG.LG_SERPDV,
            '2D' MODELO,
            SLG.LG_NOME,
            COALESCE(C0W.C0W_ID, ' ') ID_C0W
            FROM SLG### SLG
		    LEFT JOIN C0W### C0W
		        ON C0W.D_E_L_E_T_ = ' '
		            AND C0W.C0W_FILIAL = @FILIAL_C0W
                    AND C0W.C0W_CODIGO = SLG.LG_CODIGO
		            AND C0W.C0W_ECFMOD = '2D'
		            AND C0W.C0W_ECFFAB = SLG.LG_SERPDV
                    AND C0W.C0W_ECFCX = SLG.LG_PDV
            WHERE SLG.D_E_L_E_T_ = ' '
                AND SLG.LG_FILIAL = @FILIAL_SLG
                AND SLG.LG_PDV = @IN_KEYREG

    FOR READ ONLY
    OPEN SLG_QUERY

    FETCH SLG_QUERY 
        INTO 
            @ECF_CODIGO,
            @ECF_NUMSERIE,
            @ECF_MODEQUIP,
            @ECF_DESCRI,
            @ID_C0W

    BEGIN TRANSACTION

    IF @@FETCH_STATUS = 0
        BEGIN  
            IF @ID_C0W = ' '
                BEGIN
                    INSERT INTO C0W### (
                        C0W_FILIAL,
                        C0W_ID,
                        C0W_CODIGO,
                        C0W_DESCRI,
                        C0W_ECFMOD,
                        C0W_ECFFAB,
                        C0W_ECFCX
                    ) VALUES (
                        @FILIAL_C0W,
                        @IN_NEWID,
                        @ECF_CODIGO,
                        @ECF_DESCRI,
                        @ECF_MODEQUIP,
                        @ECF_NUMSERIE,
                        @ECF_CODIGO
                    )
                END
            ELSE 
                BEGIN
                    UPDATE C0W### 
                        SET
                            C0W_DESCRI = @ECF_DESCRI
                        WHERE D_E_L_E_T_ = ' ' 
                            AND C0W_FILIAL = @FILIAL_C0W 
                            AND C0W_ID = @ID_C0W     
                END

            SELECT @RESULT = '1'
        END

    COMMIT TRANSACTION

    CLOSE SLG_QUERY
    DEALLOCATE SLG_QUERY

    SELECT @OUT_RESULT = @RESULT
END
